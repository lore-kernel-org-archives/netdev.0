From: Eric Wong <normalperson@yhbt.net>
Subject: Re: socket file descriptor a/m/c-timestamps broken in <= 3.8.8?
Date: Tue, 23 Apr 2013 00:30:15 +0000
Message-ID: <20130423003015.GA26858@dcvr.yhbt.net>
References: <5175CA2F.2030206@felixbecker.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Felix Becker <mail@felixbecker.name>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5175CA2F.2030206@felixbecker.name>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cc:-ing netdev (no comments of my own)

Felix Becker <mail@felixbecker.name> wrote:
> Hi,
> 
> I tried to figure out how old my TCP connections are and took a look
> at /proc/<pid>/fd/<socketfdnum> using 'ls -la' / 'stat'.
> 
> When I'm creating a new socket in my application, the time stamps
> returned by stat / ls -la are correct - as expected. After closing the
> socket, the fd isn't visible in /proc/<pid>/fd anymore - as expected.
> When creating a new socket a few minutes later (which gets the same
> number as the socket closed before), the newly created socket has the
> same time stamps (access / modify / change) as the old socket - I
> didn't expect this.
> 
> When using fstat() from <sys/stat.h> I'm getting 0 for a/m/c-time.
> Only in /proc/<pid>/fd/ i can see (the wrong) times.
> 
> I attached a test code for reproducing the issue. In my production
> environments i have new socket file descriptors which have timestamps
> indicating that they are many hours old.
> 
> Q1: is it a bug that fstat() returns 0-values for a/m/c-time?
> 
> Q2: is it a bug that a new socket, with the file descriptor number of
> an older socket which existed before, have the a/m/c-times of the old
> socket in /proc/<pid>/fd/?
> 
> Best regards
> 
> Felix
> 
> p.s. test setup is a normal x86_64 architecture (intel xeon).
> 
> =======================================================================
> // sockettest.c
> 
> #include <sys/socket.h>
> #include <time.h>
> #include <sys/stat.h>
> #include <sys/types.h>
> #include <sys/un.h>
> #include <stdlib.h>
> #include <stdio.h>
> #include <string.h>
> #include <unistd.h>
> 
> 
> void print_socket_stats(int sfd){
>    struct stat socket_stats;
>    fstat(sfd, &socket_stats);
>    printf("Socket stats for socket %d\n", sfd);
>    printf("socket stat: st_atime: %ld\n", socket_stats.st_atime);
>    printf("socket stat: st_mtime: %ld\n", socket_stats.st_mtime);
>    printf("socket stat: st_ctime: %ld\n", socket_stats.st_ctime);
> }
> 
> void print_with_time(const char* message){
>         time_t t;
>         time(&t);
>         printf("%s @ %s\n", message, ctime(&t));
> 
> }
> 
> int main(int argc, char *argv[]) {
> 
>    int sfd;
> 
>    printf("pid: %d\n", getpid());
> 
>    print_with_time("Opening socket");
>    sfd = socket(AF_UNIX, SOCK_STREAM, 0);
>    printf("opened socket: %d\n",sfd);
>    print_socket_stats(sfd);
> 
>    print_with_time("sleeping 30\n");
> 
>    sleep(30);
> 
>    printf("closing socket %d", sfd);
>    close(sfd);
> 
>    printf("closed socket: %d\n",sfd);
>    print_with_time("sleeping 61 seconds");
> 
>    sleep(61);
> 
>    print_with_time("opening new socket");
>    sfd = socket(AF_UNIX, SOCK_STREAM, 0);
>    printf("opened socket: %d\n",sfd);
>    print_socket_stats(sfd);
>    print_with_time("sleeping 999");
> 
>    sleep(999);
> }
> 
> =======================================================================
> 
> ./sockettest &
> 
> pid: 18267
> Opening socket @ Mon Apr 22 23:05:37 2013
> 
> opened socket: 3
> Socket stats for socket 3
> socket stat: st_atime: 0
> socket stat: st_mtime: 0
> socket stat: st_ctime: 0
> sleeping 30 @ Mon Apr 22 23:05:37 2013
> 
> >>> ls -la /proc/18267/fd/3
> lrwx------ 1 becker becker 64 Apr 22 23:05 /proc/18267/fd/3 ->
> socket:[210268]
> 
> 
> >>> stat /proc/18267/fd/3
>   File: `/proc/18267/fd/3' -> `socket:[210268]'
>   Size: 64              Blocks: 0          IO Block: 1024   symbolic link
> Device: 3h/3d   Inode: 52177       Links: 1
> Access: (0700/lrwx------)  Uid: ( 1001/  becker)   Gid: ( 1001/  becker)
> Access: 2013-04-22 23:05:46.179813835 +0000
> Modify: 2013-04-22 23:05:46.175813886 +0000
> Change: 2013-04-22 23:05:46.175813886 +0000
> 
> closing socket 3
> closed socket: 3
> 
> sleeping 61 seconds @ Mon Apr 22 23:06:07 2013
> 
> opening new socket @ Mon Apr 22 23:07:08 2013
> 
> opened socket: 3
> Socket stats for socket 3
> socket stat: st_atime: 0
> socket stat: st_mtime: 0
> socket stat: st_ctime: 0
> sleeping 999 @ Mon Apr 22 23:07:08 2013
> 
> 
> >>> ls -la /proc/18267/fd/3
> lrwx------ 1 becker becker 64 Apr 22 23:05 /proc/18267/fd/3 ->
> socket:[210320]
> 
> >>> stat /proc/18267/fd/3
> 
> 
> 
>   File: `/proc/18267/fd/3' -> `socket:[210320]'
>   Size: 64              Blocks: 0          IO Block: 1024   symbolic link
> Device: 3h/3d   Inode: 52177       Links: 1
> Access: (0700/lrwx------)  Uid: ( 1001/  becker)   Gid: ( 1001/  becker)
> Access: 2013-04-22 23:05:46.179813835 +0000
> Modify: 2013-04-22 23:05:46.175813886 +0000
> Change: 2013-04-22 23:05:46.175813886 +0000
> --
