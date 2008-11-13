From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] reintroduce accept4
Date: Thu, 13 Nov 2008 14:57:37 -0800
Message-ID: <20081113145737.96898aaf.akpm__40043.0478308865$1226880872$gmane$org@linux-foundation.org>
References: <200810261641.m9QGfotr024285@hs20-bc2-1.build.redhat.com>
	<517f3f820811131351l1305b2d2u43ab4e0601d97f93@mail.gmail.com>
	<20081113140541.23754cad.akpm@linux-foundation.org>
	<18716.43376.534965.688695@cargo.ozlabs.ibm.com>
	<18716.43543.256621.825529@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mtk.manpages@gmail.com, subrata@linux.vnet.ibm.com,
	linux-arch@vger.kernel.org, drepper@redhat.com,
	linux-kernel@vger.kernel.org, torvalds@linux-foundation.org,
	linux-api@vger.kernel.org, linux-man@vger.kernel.org,
	davidel@xmailserver.org, netdev@vger.kernel.org, roland@redhat.com,
	oleg@tv-sign.ru, hch@lst.de, davem@davemloft.net, alan@redhat.com,
	jakub@redhat.com
To: Paul Mackerras <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:56392 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751579AbYKMW6P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 17:58:15 -0500
In-Reply-To: <18716.43543.256621.825529@cargo.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Nov 2008 09:28:39 +1100
Paul Mackerras <paulus@samba.org> wrote:

> I wrote:
> 
> > Andrew Morton writes:
> > 
> > > > I think Ulrich wanted to try to see this patch in for 2.6.28; it's
> > > > past the merge window of course, so it's up to you, but I have no
> > > > problem with that.
> > > 
> > > That's easy - I'll send it to Linus and let him decide ;)
> > 
> > Ulrich's patch only updated x86.  If you're going to send it to Linus,
> > please give us other architecture maintainers a chance to get patches
> > to you to wire it up on our architectures, and then send Linus the
> > combined patch.
> 
> Actually, any architecture that uses sys_socketcall should be OK
> already, by the looks, and that includes powerpc.
> 

Here's the latest version, for review-n-test enjoyment:

From: Ulrich Drepper <drepper@redhat.com>

Introduce a new accept4() system call.  The addition of this system call
matches analogous changes in 2.6.27 (dup3(), evenfd2(), signalfd4(),
inotify_init1(), epoll_create1(), pipe2()) which added new system calls
that differed from analogous traditional system calls in adding a flags
argument that can be used to access additional functionality.

The accept4() system call is exactly the same as accept(), except that it
adds a flags bit-mask argument.  Two flags are initially implemented. 
(Most of the new system calls in 2.6.27 also had both of these flags.)
SOCK_CLOEXEC causes the close-on-exec (FD_CLOEXEC) flag to be enabled for
the new file descriptor returned by accept4().  This is a useful security
feature to avoid leaking information in a multithreaded program where one
thread is doing an accept() at the same time as another thread is doing a
fork() plus exec().

More details here: http://udrepper.livejournal.com/20407.html "Secure File
Descriptor Handling", Ulrich Drepper) The other flag is SOCK_NONBLOCK,
which causes the O_NONBLOCK flag to be enabled on the new open file
description created by accept4().  (This flag is merely a convenience,
saving the use of additional calls fcntl(F_GETFL) and fcntl (F_SETFL) to
achieve the same result.

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

[mtk.manpages@gmail.com: rewrote changelog, updated test program]
Signed-off-by: Ulrich Drepper <drepper@redhat.com>
Tested-by: Michael Kerrisk <mtk.manpages@gmail.com>
Acked-by: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: <linux-api@vger.kernel.org>
Cc: <linux-arch@vger.kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/x86/include/asm/unistd_64.h |    4 -
 include/linux/net.h              |    6 --
 include/linux/syscalls.h         |    3 -
 kernel/sys_ni.c                  |    2 
 net/compat.c                     |   50 +-----------------
 net/socket.c                     |   80 +++--------------------------
 6 files changed, 21 insertions(+), 124 deletions(-)

diff -puN arch/x86/include/asm/unistd_64.h~reintroduce-accept4 arch/x86/include/asm/unistd_64.h
--- a/arch/x86/include/asm/unistd_64.h~reintroduce-accept4
+++ a/arch/x86/include/asm/unistd_64.h
@@ -639,8 +639,8 @@ __SYSCALL(__NR_fallocate, sys_fallocate)
 __SYSCALL(__NR_timerfd_settime, sys_timerfd_settime)
 #define __NR_timerfd_gettime			287
 __SYSCALL(__NR_timerfd_gettime, sys_timerfd_gettime)
-#define __NR_paccept				288
-__SYSCALL(__NR_paccept, sys_paccept)
+#define __NR_accept4				288
+__SYSCALL(__NR_accept4, sys_accept4)
 #define __NR_signalfd4				289
 __SYSCALL(__NR_signalfd4, sys_signalfd4)
 #define __NR_eventfd2				290
diff -puN include/linux/net.h~reintroduce-accept4 include/linux/net.h
--- a/include/linux/net.h~reintroduce-accept4
+++ a/include/linux/net.h
@@ -40,7 +40,7 @@
 #define SYS_GETSOCKOPT	15		/* sys_getsockopt(2)		*/
 #define SYS_SENDMSG	16		/* sys_sendmsg(2)		*/
 #define SYS_RECVMSG	17		/* sys_recvmsg(2)		*/
-#define SYS_PACCEPT	18		/* sys_paccept(2)		*/
+#define SYS_ACCEPT4	18		/* sys_accept4(2)		*/
 
 typedef enum {
 	SS_FREE = 0,			/* not allocated		*/
@@ -100,7 +100,7 @@ enum sock_type {
  * remaining bits are used as flags. */
 #define SOCK_TYPE_MASK 0xf
 
-/* Flags for socket, socketpair, paccept */
+/* Flags for socket, socketpair, accept4 */
 #define SOCK_CLOEXEC	O_CLOEXEC
 #ifndef SOCK_NONBLOCK
 #define SOCK_NONBLOCK	O_NONBLOCK
@@ -223,8 +223,6 @@ extern int 	     sock_map_fd(struct sock
 extern struct socket *sockfd_lookup(int fd, int *err);
 #define		     sockfd_put(sock) fput(sock->file)
 extern int	     net_ratelimit(void);
-extern long	     do_accept(int fd, struct sockaddr __user *upeer_sockaddr,
-			       int __user *upeer_addrlen, int flags);
 
 #define net_random()		random32()
 #define net_srandom(seed)	srandom32((__force u32)seed)
diff -puN include/linux/syscalls.h~reintroduce-accept4 include/linux/syscalls.h
--- a/include/linux/syscalls.h~reintroduce-accept4
+++ a/include/linux/syscalls.h
@@ -410,8 +410,7 @@ asmlinkage long sys_getsockopt(int fd, i
 asmlinkage long sys_bind(int, struct sockaddr __user *, int);
 asmlinkage long sys_connect(int, struct sockaddr __user *, int);
 asmlinkage long sys_accept(int, struct sockaddr __user *, int __user *);
-asmlinkage long sys_paccept(int, struct sockaddr __user *, int __user *,
-			    const __user sigset_t *, size_t, int);
+asmlinkage long sys_accept4(int, struct sockaddr __user *, int __user *, int);
 asmlinkage long sys_getsockname(int, struct sockaddr __user *, int __user *);
 asmlinkage long sys_getpeername(int, struct sockaddr __user *, int __user *);
 asmlinkage long sys_send(int, void __user *, size_t, unsigned);
diff -puN kernel/sys_ni.c~reintroduce-accept4 kernel/sys_ni.c
--- a/kernel/sys_ni.c~reintroduce-accept4
+++ a/kernel/sys_ni.c
@@ -31,7 +31,7 @@ cond_syscall(sys_socketpair);
 cond_syscall(sys_bind);
 cond_syscall(sys_listen);
 cond_syscall(sys_accept);
-cond_syscall(sys_paccept);
+cond_syscall(sys_accept4);
 cond_syscall(sys_connect);
 cond_syscall(sys_getsockname);
 cond_syscall(sys_getpeername);
diff -puN net/compat.c~reintroduce-accept4 net/compat.c
--- a/net/compat.c~reintroduce-accept4
+++ a/net/compat.c
@@ -725,7 +725,7 @@ EXPORT_SYMBOL(compat_mc_getsockopt);
 static unsigned char nas[19]={AL(0),AL(3),AL(3),AL(3),AL(2),AL(3),
 				AL(3),AL(3),AL(4),AL(4),AL(4),AL(6),
 				AL(6),AL(2),AL(5),AL(5),AL(3),AL(3),
-				AL(6)};
+				AL(4)};
 #undef AL
 
 asmlinkage long compat_sys_sendmsg(int fd, struct compat_msghdr __user *msg, unsigned flags)
@@ -738,52 +738,13 @@ asmlinkage long compat_sys_recvmsg(int f
 	return sys_recvmsg(fd, (struct msghdr __user *)msg, flags | MSG_CMSG_COMPAT);
 }
 
-asmlinkage long compat_sys_paccept(int fd, struct sockaddr __user *upeer_sockaddr,
-				   int __user *upeer_addrlen,
-				   const compat_sigset_t __user *sigmask,
-				   compat_size_t sigsetsize, int flags)
-{
-	compat_sigset_t ss32;
-	sigset_t ksigmask, sigsaved;
-	int ret;
-
-	if (sigmask) {
-		if (sigsetsize != sizeof(compat_sigset_t))
-			return -EINVAL;
-		if (copy_from_user(&ss32, sigmask, sizeof(ss32)))
-			return -EFAULT;
-		sigset_from_compat(&ksigmask, &ss32);
-
-		sigdelsetmask(&ksigmask, sigmask(SIGKILL)|sigmask(SIGSTOP));
-		sigprocmask(SIG_SETMASK, &ksigmask, &sigsaved);
-	}
-
-	ret = do_accept(fd, upeer_sockaddr, upeer_addrlen, flags);
-
-	if (ret == -ERESTARTNOHAND) {
-		/*
-		 * Don't restore the signal mask yet. Let do_signal() deliver
-		 * the signal on the way back to userspace, before the signal
-		 * mask is restored.
-		 */
-		if (sigmask) {
-			memcpy(&current->saved_sigmask, &sigsaved,
-			       sizeof(sigsaved));
-			set_restore_sigmask();
-		}
-	} else if (sigmask)
-		sigprocmask(SIG_SETMASK, &sigsaved, NULL);
-
-	return ret;
-}
-
 asmlinkage long compat_sys_socketcall(int call, u32 __user *args)
 {
 	int ret;
 	u32 a[6];
 	u32 a0, a1;
 
-	if (call < SYS_SOCKET || call > SYS_PACCEPT)
+	if (call < SYS_SOCKET || call > SYS_ACCEPT4)
 		return -EINVAL;
 	if (copy_from_user(a, args, nas[call]))
 		return -EFAULT;
@@ -804,7 +765,7 @@ asmlinkage long compat_sys_socketcall(in
 		ret = sys_listen(a0, a1);
 		break;
 	case SYS_ACCEPT:
-		ret = do_accept(a0, compat_ptr(a1), compat_ptr(a[2]), 0);
+		ret = sys_accept4(a0, compat_ptr(a1), compat_ptr(a[2]), 0);
 		break;
 	case SYS_GETSOCKNAME:
 		ret = sys_getsockname(a0, compat_ptr(a1), compat_ptr(a[2]));
@@ -844,9 +805,8 @@ asmlinkage long compat_sys_socketcall(in
 	case SYS_RECVMSG:
 		ret = compat_sys_recvmsg(a0, compat_ptr(a1), a[2]);
 		break;
-	case SYS_PACCEPT:
-		ret = compat_sys_paccept(a0, compat_ptr(a1), compat_ptr(a[2]),
-					 compat_ptr(a[3]), a[4], a[5]);
+	case SYS_ACCEPT4:
+		ret = sys_accept4(a0, compat_ptr(a1), compat_ptr(a[2]), a[3]);
 		break;
 	default:
 		ret = -EINVAL;
diff -puN net/socket.c~reintroduce-accept4 net/socket.c
--- a/net/socket.c~reintroduce-accept4
+++ a/net/socket.c
@@ -1425,8 +1425,8 @@ asmlinkage long sys_listen(int fd, int b
  *	clean when we restucture accept also.
  */
 
-long do_accept(int fd, struct sockaddr __user *upeer_sockaddr,
-	       int __user *upeer_addrlen, int flags)
+asmlinkage long sys_accept4(int fd, struct sockaddr __user *upeer_sockaddr,
+			    int __user *upeer_addrlen, int flags)
 {
 	struct socket *sock, *newsock;
 	struct file *newfile;
@@ -1509,66 +1509,10 @@ out_fd:
 	goto out_put;
 }
 
-#if 0
-#ifdef HAVE_SET_RESTORE_SIGMASK
-asmlinkage long sys_paccept(int fd, struct sockaddr __user *upeer_sockaddr,
-			    int __user *upeer_addrlen,
-			    const sigset_t __user *sigmask,
-			    size_t sigsetsize, int flags)
-{
-	sigset_t ksigmask, sigsaved;
-	int ret;
-
-	if (sigmask) {
-		/* XXX: Don't preclude handling different sized sigset_t's.  */
-		if (sigsetsize != sizeof(sigset_t))
-			return -EINVAL;
-		if (copy_from_user(&ksigmask, sigmask, sizeof(ksigmask)))
-			return -EFAULT;
-
-		sigdelsetmask(&ksigmask, sigmask(SIGKILL)|sigmask(SIGSTOP));
-		sigprocmask(SIG_SETMASK, &ksigmask, &sigsaved);
-        }
-
-	ret = do_accept(fd, upeer_sockaddr, upeer_addrlen, flags);
-
-	if (ret < 0 && signal_pending(current)) {
-		/*
-		 * Don't restore the signal mask yet. Let do_signal() deliver
-		 * the signal on the way back to userspace, before the signal
-		 * mask is restored.
-		 */
-		if (sigmask) {
-			memcpy(&current->saved_sigmask, &sigsaved,
-			       sizeof(sigsaved));
-			set_restore_sigmask();
-		}
-	} else if (sigmask)
-		sigprocmask(SIG_SETMASK, &sigsaved, NULL);
-
-	return ret;
-}
-#else
-asmlinkage long sys_paccept(int fd, struct sockaddr __user *upeer_sockaddr,
-			    int __user *upeer_addrlen,
-			    const sigset_t __user *sigmask,
-			    size_t sigsetsize, int flags)
-{
-	/* The platform does not support restoring the signal mask in the
-	 * return path.  So we do not allow using paccept() with a signal
-	 * mask.  */
-	if (sigmask)
-		return -EINVAL;
-
-	return do_accept(fd, upeer_sockaddr, upeer_addrlen, flags);
-}
-#endif
-#endif
-
 asmlinkage long sys_accept(int fd, struct sockaddr __user *upeer_sockaddr,
 			   int __user *upeer_addrlen)
 {
-	return do_accept(fd, upeer_sockaddr, upeer_addrlen, 0);
+	return sys_accept4(fd, upeer_sockaddr, upeer_addrlen, 0);
 }
 
 /*
@@ -2095,7 +2039,7 @@ static const unsigned char nargs[19]={
 	AL(0),AL(3),AL(3),AL(3),AL(2),AL(3),
 	AL(3),AL(3),AL(4),AL(4),AL(4),AL(6),
 	AL(6),AL(2),AL(5),AL(5),AL(3),AL(3),
-	AL(6)
+	AL(4)
 };
 
 #undef AL
@@ -2114,7 +2058,7 @@ asmlinkage long sys_socketcall(int call,
 	unsigned long a0, a1;
 	int err;
 
-	if (call < 1 || call > SYS_PACCEPT)
+	if (call < 1 || call > SYS_ACCEPT4)
 		return -EINVAL;
 
 	/* copy_from_user should be SMP safe. */
@@ -2142,9 +2086,8 @@ asmlinkage long sys_socketcall(int call,
 		err = sys_listen(a0, a1);
 		break;
 	case SYS_ACCEPT:
-		err =
-		    do_accept(a0, (struct sockaddr __user *)a1,
-			      (int __user *)a[2], 0);
+		err = sys_accept4(a0, (struct sockaddr __user *)a1,
+				  (int __user *)a[2], 0);
 		break;
 	case SYS_GETSOCKNAME:
 		err =
@@ -2191,12 +2134,9 @@ asmlinkage long sys_socketcall(int call,
 	case SYS_RECVMSG:
 		err = sys_recvmsg(a0, (struct msghdr __user *)a1, a[2]);
 		break;
-	case SYS_PACCEPT:
-		err =
-		    sys_paccept(a0, (struct sockaddr __user *)a1,
-			        (int __user *)a[2],
-				(const sigset_t __user *) a[3],
-				a[4], a[5]);
+	case SYS_ACCEPT4:
+		err = sys_accept4(a0, (struct sockaddr __user *)a1,
+				  (int __user *)a[2], a[3]);
 		break;
 	default:
 		err = -EINVAL;
_

