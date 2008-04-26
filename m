From: Ulrich Drepper <drepper@redhat.com>
Subject: [PATCH] paccept, socket, socketpair w/flags
Date: Sat, 26 Apr 2008 18:24:25 -0400
Message-ID: <200804262224.m3QMOP3a006296@devserv.devel.redhat.com>
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759502AbYDZWZN@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This version of the patch hopefully integrates all of the requested
changes:

- the sock_map_fd interface is changed and all in-tree users changed.
  No additional function anymore

- there is a helper function to convert the new socket flags into
  file flags.  Shared by all three functions

- the new accept interface is now paccept() which adds the flag
  parameter as well as a signal mask.

- not changed from the last version: the paccet() function takes
  a flags parameter with the same value as the ORed flags for
  socket() and socketpair().  Seems cleaner.


I tried to write the paccept() code as similar as possible to the
pselect() code.  It seems to work.  Somebody might want to look over
it, though.

Unless somebody has more interface requests I'd hope this version is
ready for integration.

As usual, a test program is included.  Adjust for archs != x86/x86-64.


#include <fcntl.h>
#include <pthread.h>
#include <signal.h>
#include <stdio.h>
#include <unistd.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/syscall.h>

#define SOCK_CLOEXEC 0x40000000

#ifdef __x86_64__
#define __NR_paccept 288
#elif __i386__
#define SYS_PACCEPT     18
#define USE_SOCKETCALL 1
#else
#error "define syscall numbers for this architecture"
#endif

#define PORT 57392

static pthread_barrier_t b;
static int status;

static void *
tf (void *arg)
{
  pthread_barrier_wait (&b);
  int s = socket (AF_INET, SOCK_STREAM, 0);
  struct sockaddr_in sin;
  sin.sin_family = AF_INET;
  sin.sin_addr.s_addr = htonl (INADDR_LOOPBACK);
  sin.sin_port = htons (PORT);
  connect (s, (const struct sockaddr *) &sin, sizeof (sin));
  close (s);
  pthread_barrier_wait (&b);

  pthread_barrier_wait (&b);
  s = socket (AF_INET, SOCK_STREAM, 0);
  sin.sin_family = AF_INET;
  sin.sin_addr.s_addr = htonl (INADDR_LOOPBACK);
  sin.sin_port = htons (PORT + 1);
  connect (s, (const struct sockaddr *) &sin, sizeof (sin));
  close (s);
  return NULL;
}

static void
h(int sig)
{
  _exit(status);
}

int
main (void)
{
  int s;
  int s2;
  int sp[2];

  s = socket (PF_UNIX, SOCK_STREAM, 0);

  if (s < 0)
    {
      puts ("socket failed");
      status = 1;
    }
  else
    {
      int fl = fcntl (s, F_GETFD);
      if ((fl & FD_CLOEXEC) != 0)
	{
	  puts ("socket did set CLOEXEC");
	  status = 1;
	}

      close (s);
    }

  s = socket (PF_UNIX, SOCK_STREAM|SOCK_CLOEXEC, 0);

  if (s < 0)
    {
      puts ("socket(SOCK_CLOEXEC) failed");
      status = 1;
    }
  else
    {
      int fl = fcntl (s, F_GETFD);
      if ((fl & FD_CLOEXEC) == 0)
	{
	  puts ("socket(SOCK_CLOEXEC) did not set CLOEXEC");
	  status = 1;
	}

      close (s);
    }

  if (socketpair (PF_UNIX, SOCK_STREAM, 0, sp) < 0)
    {
      puts ("socketpair failed");
      status = 1;
    }
  else
    {
      int fl1 = fcntl (sp[0], F_GETFD);
      int fl2 = fcntl (sp[1], F_GETFD);
      if ((fl1 & FD_CLOEXEC) != 0 || (fl2 & FD_CLOEXEC) != 0)
	{
	  puts ("socketpair did set CLOEXEC");
	  status = 1;
	}

      close (sp[0]);
      close (sp[1]);
    }

  if (socketpair (PF_UNIX, SOCK_STREAM|SOCK_CLOEXEC, 0, sp) < 0)
    {
      puts ("socketpair(SOCK_CLOEXEC) failed");
      status = 1;
    }
  else
    {
      int fl1 = fcntl (sp[0], F_GETFD);
      int fl2 = fcntl (sp[1], F_GETFD);
      if ((fl1 & FD_CLOEXEC) == 0 || (fl2 & FD_CLOEXEC) == 0)
	{
	  puts ("socketpair(SOCK_CLOEXEC) did not set CLOEXEC");
	  status = 1;
	}

      close (sp[0]);
      close (sp[1]);
    }

  pthread_barrier_init (&b, NULL, 2);
  
  struct sockaddr_in sin;
  pthread_t th;
  if (pthread_create (&th, NULL, tf, NULL) != 0)
    {
      puts ("pthread_create failed");
      status = 1;
    }
  else
    {
      int s = socket (AF_INET, SOCK_STREAM, 0);
      sin.sin_family = AF_INET;
      sin.sin_addr.s_addr = htonl (INADDR_LOOPBACK);
      sin.sin_port = htons (PORT);
      bind (s, (struct sockaddr *) &sin, sizeof (sin));
      listen (s, SOMAXCONN);

      pthread_barrier_wait (&b);

      s2 = accept (s, NULL, 0);
      if (s2 < 0)
	{
	  puts ("accept failed");
	  status = 1;
	}
      else
	{
	  int fl = fcntl (s2, F_GETFD);
	  if ((fl & FD_CLOEXEC) != 0)
	    {
	      puts ("accept did set CLOEXEC");
	      status = 1;
	    }

	  close (s2);
        }

      close (s);

      pthread_barrier_wait (&b);

      sin.sin_family = AF_INET;
      sin.sin_addr.s_addr = htonl (INADDR_LOOPBACK);
      sin.sin_port = htons (PORT + 1);
      s = socket (AF_INET, SOCK_STREAM, 0);
      bind (s, (struct sockaddr *) &sin, sizeof (sin));
      listen (s, SOMAXCONN);

      pthread_barrier_wait (&b);

#if USE_SOCKETCALL
      s2 = syscall (__NR_socketcall, SYS_PACCEPT, s, NULL, 0, NULL, 0, SOCK_CLOEXEC);
#else
      s2 = syscall (__NR_paccept, s, NULL, 0, NULL, 0, SOCK_CLOEXEC);
#endif
      if (s2 < 0)
	{
	  puts ("paccept failed");
	  status = 1;
	}
      else
	{
	  int fl = fcntl (s2, F_GETFD);
	  if ((fl & FD_CLOEXEC) == 0)
	    {
	      puts ("paccept did not set CLOEXEC");
	      status = 1;
	    }

	  close (s2);
        }

      close (s);
    }

  sigblock(sigmask(SIGALRM));

  struct sigaction sa;
  sa.sa_handler = h;
  sigemptyset(&sa.sa_mask);
  sa.sa_flags = 0;
  sigaction(SIGALRM, &sa, NULL);

  sigset_t ss;
  sigprocmask(SIG_SETMASK, NULL, &ss);
  sigdelset(&ss, SIGALRM);
  alarm(2);

  sin.sin_family = AF_INET;
  sin.sin_addr.s_addr = htonl (INADDR_LOOPBACK);
  sin.sin_port = htons (PORT + 2);
  s = socket (AF_INET, SOCK_STREAM, 0);
  bind (s, (struct sockaddr *) &sin, sizeof (sin));
  listen (s, SOMAXCONN);

#if USE_SOCKETCALL
  s2 = syscall (__NR_socketcall, SYS_PACCEPT, s, NULL, 0, &ss, 8, 0);
#else
  s2 = syscall (__NR_paccept, s, NULL, 0, &ss, 8, 0);
#endif

  // Should not be reached.
  printf ("paccept returned with %d\n", s2);
  return 1;
}



 include/asm-x86/unistd_64.h |    2 
 include/linux/net.h         |    8 +++
 include/linux/syscalls.h    |    2 
 net/9p/trans_fd.c           |    2 
 net/compat.c                |   52 ++++++++++++++++++++--
 net/sctp/socket.c           |    2 
 net/socket.c                |  102 +++++++++++++++++++++++++++++++++++++-------
 7 files changed, 148 insertions(+), 22 deletions(-)


Signed-off-by: Ulrich Drepper <drepper@redhat.com>

diff --git a/include/asm-x86/unistd_64.h b/include/asm-x86/unistd_64.h
index fe26e36..d751135 100644
--- a/include/asm-x86/unistd_64.h
+++ b/include/asm-x86/unistd_64.h
@@ -639,6 +639,8 @@ __SYSCALL(__NR_fallocate, sys_fallocate)
 __SYSCALL(__NR_timerfd_settime, sys_timerfd_settime)
 #define __NR_timerfd_gettime			287
 __SYSCALL(__NR_timerfd_gettime, sys_timerfd_gettime)
+#define __NR_paccept				288
+__SYSCALL(__NR_paccept, sys_paccept)
 
 
 #ifndef __NO_STUBS
diff --git a/include/linux/net.h b/include/linux/net.h
index 71f7dd5..5110e1b 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -46,6 +46,7 @@ struct net;
 #define SYS_GETSOCKOPT	15		/* sys_getsockopt(2)		*/
 #define SYS_SENDMSG	16		/* sys_sendmsg(2)		*/
 #define SYS_RECVMSG	17		/* sys_recvmsg(2)		*/
+#define SYS_PACCEPT	18		/* sys_paccept(2)		*/
 
 typedef enum {
 	SS_FREE = 0,			/* not allocated		*/
@@ -91,6 +92,9 @@ enum sock_type {
 	SOCK_SEQPACKET	= 5,
 	SOCK_DCCP	= 6,
 	SOCK_PACKET	= 10,
+
+	/* Flag values, ORed to the types above.  */
+	SOCK_CLOEXEC	= 0x40000000
 };
 
 #define SOCK_MAX (SOCK_PACKET + 1)
@@ -208,10 +212,12 @@ extern int   	     sock_sendmsg(struct socket *sock, struct msghdr *msg,
 				  size_t len);
 extern int	     sock_recvmsg(struct socket *sock, struct msghdr *msg,
 				  size_t size, int flags);
-extern int 	     sock_map_fd(struct socket *sock);
+extern int 	     sock_map_fd(struct socket *sock, int flags);
 extern struct socket *sockfd_lookup(int fd, int *err);
 #define		     sockfd_put(sock) fput(sock->file)
 extern int	     net_ratelimit(void);
+extern long	     do_accept(int fd, struct sockaddr __user *upeer_sockaddr,
+			       int __user *upeer_addrlen, int flags);
 
 #define net_random()		random32()
 #define net_srandom(seed)	srandom32((__force u32)seed)
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 8df6d13..14ba94c 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -407,6 +407,8 @@ asmlinkage long sys_getsockopt(int fd, int level, int optname,
 asmlinkage long sys_bind(int, struct sockaddr __user *, int);
 asmlinkage long sys_connect(int, struct sockaddr __user *, int);
 asmlinkage long sys_accept(int, struct sockaddr __user *, int __user *);
+asmlinkage long sys_paccept(int, struct sockaddr __user *, int __user *,
+			    const sigset_t *, size_t, int);
 asmlinkage long sys_getsockname(int, struct sockaddr __user *, int __user *);
 asmlinkage long sys_getpeername(int, struct sockaddr __user *, int __user *);
 asmlinkage long sys_send(int, void __user *, size_t, unsigned);
diff --git a/net/9p/trans_fd.c b/net/9p/trans_fd.c
index f624dff..25931c0 100644
--- a/net/9p/trans_fd.c
+++ b/net/9p/trans_fd.c
@@ -1173,7 +1173,7 @@ static int p9_socket_open(struct p9_trans *trans, struct socket *csocket)
 	int fd, ret;
 
 	csocket->sk->sk_allocation = GFP_NOIO;
-	fd = sock_map_fd(csocket);
+	fd = sock_map_fd(csocket, 0);
 	if (fd < 0) {
 		P9_EPRINTK(KERN_ERR, "p9_socket_open: failed to map fd\n");
 		return fd;
diff --git a/net/compat.c b/net/compat.c
index 80013fb..f82bbc2 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -523,9 +523,10 @@ asmlinkage long compat_sys_getsockopt(int fd, int level, int optname,
 }
 /* Argument list sizes for compat_sys_socketcall */
 #define AL(x) ((x) * sizeof(u32))
-static unsigned char nas[18]={AL(0),AL(3),AL(3),AL(3),AL(2),AL(3),
+static unsigned char nas[19]={AL(0),AL(3),AL(3),AL(3),AL(2),AL(3),
 				AL(3),AL(3),AL(4),AL(4),AL(4),AL(6),
-				AL(6),AL(2),AL(5),AL(5),AL(3),AL(3)};
+				AL(6),AL(2),AL(5),AL(5),AL(3),AL(3),
+				AL(6)};
 #undef AL
 
 asmlinkage long compat_sys_sendmsg(int fd, struct compat_msghdr __user *msg, unsigned flags)
@@ -538,13 +539,52 @@ asmlinkage long compat_sys_recvmsg(int fd, struct compat_msghdr __user *msg, uns
 	return sys_recvmsg(fd, (struct msghdr __user *)msg, flags | MSG_CMSG_COMPAT);
 }
 
+asmlinkage long compat_sys_paccept(int fd, struct sockaddr __user *upeer_sockaddr,
+				   int __user *upeer_addrlen,
+				   const compat_sigset_t __user *sigmask,
+				   compat_size_t sigsetsize, int flags)
+{
+	compat_sigset_t ss32;
+	sigset_t ksigmask, sigsaved;
+	int ret;
+
+	if (sigmask) {
+		if (sigsetsize != sizeof(compat_sigset_t))
+			return -EINVAL;
+		if (copy_from_user(&ss32, sigmask, sizeof(ss32)))
+			return -EFAULT;
+		sigset_from_compat(&ksigmask, &ss32);
+
+		sigdelsetmask(&ksigmask, sigmask(SIGKILL)|sigmask(SIGSTOP));
+		sigprocmask(SIG_SETMASK, &ksigmask, &sigsaved);
+	}
+
+	ret = do_accept(fd, upeer_sockaddr, upeer_addrlen, flags);
+
+	if (ret == -ERESTARTNOHAND) {
+		/*
+		 * Don't restore the signal mask yet. Let do_signal() deliver
+		 * the signal on the way back to userspace, before the signal
+		 * mask is restored.
+		 */
+		if (sigmask) {
+			memcpy(&current->saved_sigmask, &sigsaved,
+			       sizeof(sigsaved));
+			set_thread_flag(TIF_RESTORE_SIGMASK);
+		}
+	} else if (sigmask)
+		sigprocmask(SIG_SETMASK, &sigsaved, NULL);
+
+	return ret;
+}
+
 asmlinkage long compat_sys_socketcall(int call, u32 __user *args)
 {
 	int ret;
 	u32 a[6];
 	u32 a0, a1;
 
-	if (call < SYS_SOCKET || call > SYS_RECVMSG)
+	if (call < SYS_SOCKET || call > SYS_PACCEPT)
 		return -EINVAL;
 	if (copy_from_user(a, args, nas[call]))
 		return -EFAULT;
@@ -565,7 +605,7 @@ asmlinkage long compat_sys_socketcall(int call, u32 __user *args)
 		ret = sys_listen(a0, a1);
 		break;
 	case SYS_ACCEPT:
-		ret = sys_accept(a0, compat_ptr(a1), compat_ptr(a[2]));
+		ret = do_accept(a0, compat_ptr(a1), compat_ptr(a[2]), 0);
 		break;
 	case SYS_GETSOCKNAME:
 		ret = sys_getsockname(a0, compat_ptr(a1), compat_ptr(a[2]));
@@ -605,6 +645,10 @@ asmlinkage long compat_sys_socketcall(int call, u32 __user *args)
 	case SYS_RECVMSG:
 		ret = compat_sys_recvmsg(a0, compat_ptr(a1), a[2]);
 		break;
+	case SYS_PACCEPT:
+		ret = compat_sys_paccept(a0, compat_ptr(a1), compat_ptr(a[2]),
+					 compat_ptr(a[3]), a[4], a[5]);
+		break;
 	default:
 		ret = -EINVAL;
 		break;
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index e7e3baf..5034b1d 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3812,7 +3812,7 @@ static int sctp_getsockopt_peeloff(struct sock *sk, int len, char __user *optval
 		goto out;
 
 	/* Map the socket to an unused fd that can be returned to the user.  */
-	retval = sock_map_fd(newsock);
+	retval = sock_map_fd(newsock, 0);
 	if (retval < 0) {
 		sock_release(newsock);
 		goto out;
diff --git a/net/socket.c b/net/socket.c
index 66c4a8c..c593c60 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -348,11 +348,11 @@ static struct dentry_operations sockfs_dentry_operations = {
  *	but we take care of internal coherence yet.
  */
 
-static int sock_alloc_fd(struct file **filep)
+static int sock_alloc_fd(struct file **filep, int flags)
 {
 	int fd;
 
-	fd = get_unused_fd();
+	fd = get_unused_fd_flags(flags);
 	if (likely(fd >= 0)) {
 		struct file *file = get_empty_filp();
 
@@ -395,10 +395,10 @@ static int sock_attach_fd(struct socket *sock, struct file *file)
 	return 0;
 }
 
-int sock_map_fd(struct socket *sock)
+int sock_map_fd(struct socket *sock, int flags)
 {
 	struct file *newfile;
-	int fd = sock_alloc_fd(&newfile);
+	int fd = sock_alloc_fd(&newfile, flags);
 
 	if (likely(fd >= 0)) {
 		int err = sock_attach_fd(sock, newfile);
@@ -1213,16 +1213,30 @@ int sock_create_kern(int family, int type, int protocol, struct socket **res)
 	return __sock_create(&init_net, family, type, protocol, res, 1);
 }
 
+static int sock_to_file_flags(int *sflags)
+{
+	int fflags = 0;
+
+	/* Extract the close-on-exec flag.  */
+	if ((*sflags & SOCK_CLOEXEC) != 0) {
+		fflags |= O_CLOEXEC;
+		*sflags &= ~SOCK_CLOEXEC;
+	}
+
+	return fflags;
+}
+
 asmlinkage long sys_socket(int family, int type, int protocol)
 {
 	int retval;
 	struct socket *sock;
+	int fflags = sock_to_file_flags(&type);
 
 	retval = sock_create(family, type, protocol, &sock);
 	if (retval < 0)
 		goto out;
 
-	retval = sock_map_fd(sock);
+	retval = sock_map_fd(sock, fflags);
 	if (retval < 0)
 		goto out_release;
 
@@ -1245,6 +1259,7 @@ asmlinkage long sys_socketpair(int family, int type, int protocol,
 	struct socket *sock1, *sock2;
 	int fd1, fd2, err;
 	struct file *newfile1, *newfile2;
+	int fflags = sock_to_file_flags(&type);
 
 	/*
 	 * Obtain the first socket and check if the underlying protocol
@@ -1263,13 +1278,13 @@ asmlinkage long sys_socketpair(int family, int type, int protocol,
 	if (err < 0)
 		goto out_release_both;
 
-	fd1 = sock_alloc_fd(&newfile1);
+	fd1 = sock_alloc_fd(&newfile1, fflags);
 	if (unlikely(fd1 < 0)) {
 		err = fd1;
 		goto out_release_both;
 	}
 
-	fd2 = sock_alloc_fd(&newfile2);
+	fd2 = sock_alloc_fd(&newfile2, fflags);
 	if (unlikely(fd2 < 0)) {
 		err = fd2;
 		put_filp(newfile1);
@@ -1400,13 +1415,18 @@ asmlinkage long sys_listen(int fd, int backlog)
  *	clean when we restucture accept also.
  */
 
-asmlinkage long sys_accept(int fd, struct sockaddr __user *upeer_sockaddr,
-			   int __user *upeer_addrlen)
+long do_accept(int fd, struct sockaddr __user *upeer_sockaddr,
+	       int __user *upeer_addrlen, int flags)
 {
 	struct socket *sock, *newsock;
 	struct file *newfile;
 	int err, len, newfd, fput_needed;
 	char address[MAX_SOCK_ADDR];
+	int fflags = sock_to_file_flags(&flags);
+
+	/* So far no additional flags are recognized.  */
+	if (unlikely(flags != 0))
+		return -EINVAL;
 
 	sock = sockfd_lookup_light(fd, &err, &fput_needed);
 	if (!sock)
@@ -1425,7 +1445,7 @@ asmlinkage long sys_accept(int fd, struct sockaddr __user *upeer_sockaddr,
 	 */
 	__module_get(newsock->ops->owner);
 
-	newfd = sock_alloc_fd(&newfile);
+	newfd = sock_alloc_fd(&newfile, fflags);
 	if (unlikely(newfd < 0)) {
 		err = newfd;
 		sock_release(newsock);
@@ -1478,6 +1498,50 @@ out_fd:
 	goto out_put;
 }
 
+asmlinkage long sys_paccept(int fd, struct sockaddr __user *upeer_sockaddr,
+			    int __user *upeer_addrlen,
+			    const sigset_t __user *sigmask,
+			    size_t sigsetsize, int flags)
+{
+	sigset_t ksigmask, sigsaved;
+	int ret;
+
+	if (sigmask) {
+		/* XXX: Don't preclude handling different sized sigset_t's.  */
+		if (sigsetsize != sizeof(sigset_t))
+			return -EINVAL;
+		if (copy_from_user(&ksigmask, sigmask, sizeof(ksigmask)))
+			return -EFAULT;
+
+		sigdelsetmask(&ksigmask, sigmask(SIGKILL)|sigmask(SIGSTOP));
+		sigprocmask(SIG_SETMASK, &ksigmask, &sigsaved);
+        }
+
+	ret = do_accept(fd, upeer_sockaddr, upeer_addrlen, flags);
+
+	if (ret < 0 && signal_pending(current)) {
+		/*
+		 * Don't restore the signal mask yet. Let do_signal() deliver
+		 * the signal on the way back to userspace, before the signal
+		 * mask is restored.
+		 */
+		if (sigmask) {
+			memcpy(&current->saved_sigmask, &sigsaved,
+			       sizeof(sigsaved));
+			set_thread_flag(TIF_RESTORE_SIGMASK);
+		}
+	} else if (sigmask)
+		sigprocmask(SIG_SETMASK, &sigsaved, NULL);
+
+	return ret;
+}
+
+asmlinkage long sys_accept(int fd, struct sockaddr __user *upeer_sockaddr,
+			   int __user *upeer_addrlen)
+{
+	return do_accept(fd, upeer_sockaddr, upeer_addrlen, 0);
+}
+
 /*
  *	Attempt to connect to a socket with the server address.  The address
  *	is in user space so we verify it is OK and move it to kernel space.
@@ -1988,10 +2052,11 @@ out:
 
 /* Argument list sizes for sys_socketcall */
 #define AL(x) ((x) * sizeof(unsigned long))
-static const unsigned char nargs[18]={
+static const unsigned char nargs[19]={
 	AL(0),AL(3),AL(3),AL(3),AL(2),AL(3),
 	AL(3),AL(3),AL(4),AL(4),AL(4),AL(6),
-	AL(6),AL(2),AL(5),AL(5),AL(3),AL(3)
+	AL(6),AL(2),AL(5),AL(5),AL(3),AL(3),
+	AL(6)
 };
 
 #undef AL
@@ -2010,7 +2075,7 @@ asmlinkage long sys_socketcall(int call, unsigned long __user *args)
 	unsigned long a0, a1;
 	int err;
 
-	if (call < 1 || call > SYS_RECVMSG)
+	if (call < 1 || call > SYS_PACCEPT)
 		return -EINVAL;
 
 	/* copy_from_user should be SMP safe. */
@@ -2039,8 +2104,8 @@ asmlinkage long sys_socketcall(int call, unsigned long __user *args)
 		break;
 	case SYS_ACCEPT:
 		err =
-		    sys_accept(a0, (struct sockaddr __user *)a1,
-			       (int __user *)a[2]);
+		    do_accept(a0, (struct sockaddr __user *)a1,
+			      (int __user *)a[2], 0);
 		break;
 	case SYS_GETSOCKNAME:
 		err =
@@ -2087,6 +2152,13 @@ asmlinkage long sys_socketcall(int call, unsigned long __user *args)
 	case SYS_RECVMSG:
 		err = sys_recvmsg(a0, (struct msghdr __user *)a1, a[2]);
 		break;
+	case SYS_PACCEPT:
+		err =
+		    sys_paccept(a0, (struct sockaddr __user *)a1,
+			        (int __user *)a[2],
+				(const sigset_t __user *) a[3],
+				a[4], a[5]);
+		break;
 	default:
 		err = -EINVAL;
 		break;
