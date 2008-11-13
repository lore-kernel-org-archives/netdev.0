From: "Michael Kerrisk" <mtk.manpages-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: Re: [PATCH] reintroduce accept4
Date: Thu, 13 Nov 2008 17:11:10 -0500
Message-ID: <cfd18e0f0811131411o5b47175dl36b022bc762181e5@mail.gmail.com>
References: <200810261641.m9QGfotr024285@hs20-bc2-1.build.redhat.com>
	 <517f3f820811131351l1305b2d2u43ab4e0601d97f93@mail.gmail.com>
	 <cfd18e0f0811131402j7ec6a60cq462916cc9715b9aa@mail.gmail.com>
Reply-To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Subrata Modak" <subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Ulrich Drepper" <drepper-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Davide Libenzi" <davidel-AhlLAIvw+VEjIGhXcJzhZg@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Roland McGrath" <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"Oleg Nesterov" <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>,
	"Christoph Hellwig" <hch-jcswGhMUV9g@public.gmane.org>,
	"David Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, "Alan Cox" <alan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"Jakub Jelinek" <jakub-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: "Andrew Morton" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cfd18e0f0811131402j7ec6a60cq462916cc9715b9aa-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Disposition: inline
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Here's my test program.  Works on x86-32.  Should work on x86-64, but
I don't have a system to hand to test with.

It tests accept4() with each of the four possible combinations of
SOCK_CLOEXEC and SOCK_NONBLOCK set/clear in 'flags', and verifies that
the appropriate flags are set on the file descriptor/open file
description returned by accept4().

I tested Ulrich's patch in this thread by applying against 2.6.28-rc2,
and it passes according to my test program.

/* test_accept4.c

   Copyright (C) 2008, Linux Foundation, written by Michael Kerrisk
        <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

   Licensed under the GNU GPLv2 or later.
*/
#define _GNU_SOURCE
#include <unistd.h>
#include <sys/syscall.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <stdlib.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>

#define PORT_NUM 33333

#define die(msg) do { perror(msg); exit(EXIT_FAILURE); } while (0)

/**********************************************************************/

/* The following is what we need until glibc gets a wrapper for
   accept4() */

/* Flags for socket(), socketpair(), accept4() */
#ifndef SOCK_CLOEXEC
#define SOCK_CLOEXEC    O_CLOEXEC
#endif
#ifndef SOCK_NONBLOCK
#define SOCK_NONBLOCK   O_NONBLOCK
#endif

#ifdef __x86_64__
#define SYS_accept4 288
#elif __i386__
#define USE_SOCKETCALL 1
#define SYS_ACCEPT4 18
#else
#error "Sorry -- don't know the syscall # on this architecture"
#endif

static int
accept4(int fd, struct sockaddr *sockaddr, socklen_t *addrlen, int flags)
{
    printf("Calling accept4(): flags = %x", flags);
    if (flags != 0) {
        printf(" (");
        if (flags & SOCK_CLOEXEC)
            printf("SOCK_CLOEXEC");
        if ((flags & SOCK_CLOEXEC) && (flags & SOCK_NONBLOCK))
            printf(" ");
        if (flags & SOCK_NONBLOCK)
            printf("SOCK_NONBLOCK");
        printf(")");
    }
    printf("\n");

#if USE_SOCKETCALL
    long args[6];

    args[0] = fd;
    args[1] = (long) sockaddr;
    args[2] = (long) addrlen;
    args[3] = flags;

    printf("x86-32\n"); /* XXX */
    return syscall(SYS_socketcall, SYS_ACCEPT4, args);
#else
    printf("x86-64\n"); /* XXX */
    return syscall(SYS_accept4, fd, sockaddr, addrlen, flags);
#endif
}

/**********************************************************************/


static int
do_test(int lfd, struct sockaddr_in *conn_addr,
        int closeonexec_flag, int nonblock_flag)
{
    int connfd, acceptfd;
    int fdf, flf, fdf_pass, flf_pass;
    struct sockaddr_in claddr;
    socklen_t addrlen;

    printf("=======================================\n");

    connfd = socket(AF_INET, SOCK_STREAM, 0);
    if (connfd == -1)
        die("socket");
    if (connect(connfd, (struct sockaddr *) conn_addr,
                sizeof(struct sockaddr_in)) == -1)
        die("connect");

    addrlen = sizeof(struct sockaddr_in);
    acceptfd = accept4(lfd, (struct sockaddr *) &claddr, &addrlen,
                       closeonexec_flag | nonblock_flag);
    if (acceptfd == -1) {
        perror("accept4()");
        close(connfd);
        return 0;
    }

    fdf = fcntl(acceptfd, F_GETFD);
    if (fdf == -1)
        die("fcntl:F_GETFD");
    fdf_pass = ((fdf & FD_CLOEXEC) != 0) ==
               ((closeonexec_flag & SOCK_CLOEXEC) != 0);
    printf("Close-on-exec flag is %sset (%s); ",
            (fdf & FD_CLOEXEC) ? "" : "not ",
            fdf_pass ? "OK" : "failed");

    flf = fcntl(acceptfd, F_GETFL);
    if (flf == -1)
        die("fcntl:F_GETFD");
    flf_pass = ((flf & O_NONBLOCK) != 0) ==
               ((nonblock_flag & SOCK_NONBLOCK) !=0);
    printf("nonblock flag is %sset (%s)\n",
            (flf & O_NONBLOCK) ? "" : "not ",
            flf_pass ? "OK" : "failed");

    close(acceptfd);
    close(connfd);

    printf("Test result: %s\n", (fdf_pass && flf_pass) ? "PASS" : "FAIL");
    return fdf_pass && flf_pass;
}


static int
create_listening_socket(int port_num)
{
    struct sockaddr_in svaddr;
    int lfd;
    int optval;

    memset(&svaddr, 0, sizeof(struct sockaddr_in));
    svaddr.sin_family = AF_INET;
    svaddr.sin_addr.s_addr = htonl(INADDR_ANY);
    svaddr.sin_port = htons(port_num);

    lfd = socket(AF_INET, SOCK_STREAM, 0);
    if (lfd == -1)
        die("socket");

    optval = 1;
    if (setsockopt(lfd, SOL_SOCKET, SO_REUSEADDR, &optval,
                   sizeof(optval)) == -1)
        die("setsockopt");

    if (bind(lfd, (struct sockaddr *) &svaddr,
             sizeof(struct sockaddr_in)) == -1)
        die("bind");

    if (listen(lfd, 5) == -1)
        die("listen");

    return lfd;
}


int
main(int argc, char *argv[])
{
    struct sockaddr_in conn_addr;
    int lfd;
    int port_num;
    int passed;

    passed = 1;

    port_num = (argc > 1) ? atoi(argv[1]) : PORT_NUM;

    memset(&conn_addr, 0, sizeof(struct sockaddr_in));
    conn_addr.sin_family = AF_INET;
    conn_addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    conn_addr.sin_port = htons(port_num);

    lfd = create_listening_socket(port_num);

    if (!do_test(lfd, &conn_addr, 0, 0))
        passed = 0;
    if (!do_test(lfd, &conn_addr, SOCK_CLOEXEC, 0))
        passed = 0;
    if (!do_test(lfd, &conn_addr, 0, SOCK_NONBLOCK))
        passed = 0;
    if (!do_test(lfd, &conn_addr, SOCK_CLOEXEC, SOCK_NONBLOCK))
        passed = 0;

    close(lfd);

    exit(passed ? EXIT_SUCCESS : EXIT_FAILURE);
}
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
