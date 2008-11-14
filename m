From: "Michael Kerrisk" <mtk.manpages@googlemail.com>
Subject: Re: [PATCH] reintroduce accept4
Date: Fri, 14 Nov 2008 12:40:53 -0500
Message-ID: <cfd18e0f0811140940n3efb1963qd5b1aab42dae1c1b@mail.gmail.com>
References: <200810261641.m9QGfotr024285@hs20-bc2-1.build.redhat.com>
	 <517f3f820811131351l1305b2d2u43ab4e0601d97f93@mail.gmail.com>
	 <20081113140541.23754cad.akpm@linux-foundation.org>
	 <18716.43376.534965.688695@cargo.ozlabs.ibm.com>
	 <18716.43543.256621.825529@cargo.ozlabs.ibm.com>
	 <20081113145737.96898aaf.akpm@linux-foundation.org>
Reply-To: mtk.manpages@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Paul Mackerras" <paulus@samba.org>, subrata@linux.vnet.ibm.com,
	linux-arch@vger.kernel.org, drepper@redhat.com,
	linux-kernel@vger.kernel.org, torvalds@linux-foundation.org,
	linux-api@vger.kernel.org, linux-man@vger.kernel.org,
	davidel@xmailserver.org, netdev@vger.kernel.org, roland@redhat.com,
	oleg@tv-sign.ru, hch@lst.de, davem@davemloft.net, alan@redhat.com,
	jakub@redhat.com
To: "Andrew Morton" <akpm@linux-foundation.org>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20081113145737.96898aaf.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Here's the latest version, for review-n-test enjoyment:

Andrew,

I made a few small tweaks to the changelog: wording fixes, and para
break fixes; other than that, changed the text to say that I rewrote
(rather than updated) the test program.  Please substitute it with the
following.

Cheers,

Michael

===
From: Ulrich Drepper <drepper@redhat.com>

Introduce a new accept4() system call.  The addition of this system call
matches analogous changes in 2.6.27 (dup3(), evenfd2(), signalfd4(),
inotify_init1(), epoll_create1(), pipe2()) which added new system calls
that differed from analogous traditional system calls in adding a flags
argument that can be used to access additional functionality.

The accept4() system call is exactly the same as accept(), except that
it adds a flags bit-mask argument.  Two flags are initially implemented.
(Most of the new system calls in 2.6.27 also had both of these flags.)

SOCK_CLOEXEC causes the close-on-exec (FD_CLOEXEC) flag to be enabled
for the new file descriptor returned by accept4().  This is a useful
security feature to avoid leaking information in a multithreaded
program where one thread is doing an accept() at the same time as
another thread is doing a fork() plus exec().  More details here:
http://udrepper.livejournal.com/20407.html "Secure File Descriptor Handling",
Ulrich Drepper).

The other flag is SOCK_NONBLOCK, which causes the O_NONBLOCK flag
to be enabled on the new open file description created by accept4().
(This flag is merely a convenience, saving the use of additional calls
fcntl(F_GETFL) and fcntl (F_SETFL) to achieve the same result.

Here's a test program.  Works on x86-32.  Should work on x86-64, but
I (mtk) don't have a system to hand to test with.

It tests accept4() with each of the four possible combinations of
SOCK_CLOEXEC and SOCK_NONBLOCK set/clear in 'flags', and verifies
that the appropriate flags are set on the file descriptor/open file
description returned by accept4().

I tested Ulrich's patch in this thread by applying against 2.6.28-rc2,
and it passes according to my test program.

/* test_accept4.c

  Copyright (C) 2008, Linux Foundation, written by Michael Kerrisk
       <mtk.manpages@gmail.com>

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

   return syscall(SYS_socketcall, SYS_ACCEPT4, args);
#else
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

[mtk.manpages@gmail.com: rewrote changelog and test program]
Signed-off-by: Ulrich Drepper <drepper@redhat.com>
Tested-by: Michael Kerrisk <mtk.manpages@gmail.com>
Acked-by: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: <linux-api@vger.kernel.org>
Cc: <linux-arch@vger.kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
