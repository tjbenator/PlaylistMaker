#!/bin/bash
########################
#V1.1
#Created by: Travis Beck
########################
#Folder name for playlists! If this is changed you have to use '-p dir' when running the script.
#playlists="" #Uncomment this line and define your playlist directory

#Audio player for -p arg. This is used to play the playlist after it is created
#eval $PLAYER $PLAYLIST
PLAYER="vlc"

#If needed later
#script=`readlink -f $0`
#script_path=`dirname $script`

EXT="*.MP3"

#Time and Date Format
date=`date +%Y-%m-%d`

#===================================================================================
#End of user configuration
#===================================================================================


#Make everything fancy
colorize()
{
        color="\e[0;34m"
        case $1 in
        "red")
                color="\e[0;35m";;
        "green")
                color="\e[0;32m";;
        "yellow")
                color="\e[0;33m";;
        "blue")
                color="\e[0;36m";;
        esac
        echo -e "$color$2\e[0m"
}

generate()
{
	#Make script case insensitive
	shopt -s nocaseglob
	mkdir -p $playlists
	if [ -d "$@" ]; then
		pushd "$@" >> /dev/null
			currentdir="$@"
			playlist_name=`basename "$PWD"`.m3u
			playlist="$playlists/$playlist_name"

			if [ -f "$playlist" ]; then
				colorize red "Removing playlist with same name"
				rm "$playlist"
			fi

			for file in $EXT; do
				if [ "$file" != "*.MP3" ] || [ "$file" != "*.WAV" ] ; then
				
					#First time create file
					if [ ! -f "$playlist" ] ;
					then
					    #colorize red "Creating Playlist file!"
					    echo "#EXTM3U" > "$playlist"
					fi
					colorize yellow "+ Adding \"$file\" to playlist"
					echo "#EXTINF:123,$file"  >> "$playlist"
					echo "$currentdir$file" >> "$playlist"
				fi
		done
	else
		colorize red "Correct usage:"
		colorize red "playlistmaker [directory]"
	fi

	#Rewind
	popd >> /dev/null
	#Make case sesitive
	shopt -u nocaseglob

	#Done
	colorize green "\"$playlist\" has been created!"
}

#MANAGE COMMANDLINE ARGS
RECUR="FALSE"
PLAY="FALSE"
while getopts rpd: OPTION
do
         case $OPTION in
          r) RECUR="TRUE" ;;
	  p) PLAY="TRUE" ;;
          d) playlists="$OPTARG"
         esac
done
shift $(( OPTIND - 1 ))  # shift past the last flag or argument

PARAM=$*


if [ -z "$playlists" ] || [ "$playlists" -ne "" ]; then
	colorize red "Playlist directory Invalid"
	colorize red "Please configure your playlist directory by editing the 'playlists' variable in this script or use '-d playlist'"; exit 0
fi 

###########################################################################
#MAIN
###########################################################################


if [ "$RECUR" = "FALSE" ]; then
	#Default Mode
	colorize green "Generating $PARAM"
	generate "$PARAM"
else
	pushd "$PARAM"
		for folder in *; do
		   if [ -d "$folder" ]; then
		      generate "$folder"
		   fi
		done
	colorize green "You have a bunch of Playlists in your playlist folder!"
fi

if [ "$PLAY" = "TRUE" ]; then
	colorize blue "PLAY: $PLAYER $playlist"
	#Play and release terminal
	eval nohup $PLAYER "'$playlist'" 2>/dev/null 1>/dev/null &
fi

echo 
colorize yellow "BYE! ENJOY YOUR PLAYLIST! YOU LAZY BASTARD :D"
echo 
