From: Alex Riesen <fork0@users.sourceforge.net>
Subject: Re: select implementation not POSIX compliant?
Date: Wed, 11 Aug 2004 21:40:18 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040811194018.GA3971@steel.home>
References: <37062.66.93.180.209.1092243659.squirrel@66.93.180.209>
Reply-To: Alex Riesen <fork0@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nick Palmer <nick@sluggardy.net>, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S268187AbUHKTlQ@vger.kernel.org>
To: linux-kernel <linux-kernel@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <37062.66.93.180.209.1092243659.squirrel@66.93.180.209>
List-Id: netdev.vger.kernel.org

On linux-kernel, Nick Palmer wrote:
> I am working on porting some software from Solaris to Linux 2.6.7. I
> have run into a problem with the interaction of select and/or
> recvmsg and close in our multi-threaded application. The application
> expects that a close call on a socket that another thread is
> blocking in select and/or recvmsg on will cause select and/or
> recvmsg to return with an error. Linux does not seem to do this. (I
> also verified that the same issue exists in Linux 2.4.25, just to be
> sure it wasn't introduced in 2.6 in case you were wondering.)

It works always for stream sockets and does not at all (even with
shutdown, even using poll(2) or read(2) instead of select) for dgram
sockets.

What domain (inet, local) are your sockets in?
What type (stream, dgram)?

There will probably be a problem anyway with changing the behaviour:
there surely is lots of code, which start complaining about select and
poll finishing "unexpectedly".

I used this to check:

#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <sys/wait.h>
#include <netinet/in.h>
#include <fcntl.h>

int main(int argc, char* argv[])
{
    int status;
    int fds[2];
    fd_set set;
#if 0
    puts("stream");
    if (  socketpair(PF_LOCAL, SOCK_STREAM, 0, fds) < 0 )
#else
    puts("dgram");
    if (  socketpair(PF_LOCAL, SOCK_DGRAM, 0, fds) < 0 )
#endif
    {
	perror("socketpair");
	exit(1);
    }
    fcntl(fds[0], F_SETFL, fcntl(fds[0], F_GETFL) | O_NONBLOCK);
    fcntl(fds[1], F_SETFL, fcntl(fds[1], F_GETFL) | O_NONBLOCK);
    switch ( fork() )
    {
    case 0:
	sleep(1);
	close(fds[0]);
	shutdown(fds[1], SHUT_RD);
	close(fds[1]);
	exit(0);
	break;
    case -1:
	perror("fork");
	exit(1);
    }
    close(fds[1]);
    FD_ZERO(&set);
    FD_SET(fds[0], &set);
    select(fds[0] + 1, &set, NULL, NULL, 0);
    wait(&status);
    return 0;
}
