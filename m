From: Ulrich Drepper <drepper@redhat.com>
Subject: [PATCH] alternative to sys_indirect, part 1
Date: Thu, 24 Apr 2008 00:03:56 -0400
Message-ID: <200804240403.m3O43us8028699@devserv.devel.redhat.com>
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:42161 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750748AbYDXEED (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2008 00:04:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The alternative to using sys_indirect is to create a whole bunch of new
syscalls.  Here the beginning.  These are the socket interfaces which
create file descriptors and therefore need a flags parameter to let
the caller decide about setting the close-on-exit bit.

There will be more new syscalls (e.g., a dup2 extension) but one
things after the other.

There are a few noteworthy things about the patch:

- the new syscall names are chosen by adding the number of parameters
  of the new syscall to the name.  Not very witty but this is in the
  kernel itself only.  I might still do something different at
  userlevel.

- I decided against using the O_* flags here.  Most are not useful and
  we might need the bits for something else at some time.  Hence the
  new SOCKFL_* flag.  The intend is to define SOCKFL_CLOEXEC and
  O_CLOEXEC to the same value.  In this case there is zero overhead.

- for x86 I decided to extend the socketcall instead of starting to
  use syscalls.  It's just more consistent and this consistency can
  be of advantage at userlevel.


The following is a test program which checks the new functionality of
all three new syscalls and checks the old calls haven't changed.  The
patch is against the current git tree and changes for x86 and x86-64
are included.  This would be one of the advantages of the sys_indirect
approach: no work on part of the arch maintainers needed.


#include <fcntl.h>
#include <pthread.h>
#include <stdio.h>
#include <unistd.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/syscall.h>

#ifdef __x86_64__
#define __NR_socket4 288
#define __NR_accept4 289
#define __NR_socketpair5 290
#define SOCKFL_CLOEXEC 02000000
#elif __i386__
#define SYS_SOCKET4     18
#define SYS_ACCEPT4     19
#define SYS_SOCKETPAIR5 20
#define USE_SOCKETCALL 1
#define SOCKFL_CLOEXEC 02000000
#else
#error "define error numbers for this architecture"
#endif

#define PORT 57392

static pthread_barrier_t b;

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

int
main (void)
{
  alarm (5);

  int status = 0;
  int s;
  int sp[2];

  s = socket (PF_UNIX, SOCK_STREAM, 0);

  if (s < 0)
    {
      puts ("socket failed");
      status = 1;
    }
  else
    {
      int fl = fcntl(s, F_GETFD);
      if ((fl & FD_CLOEXEC) != 0)
	{
	  puts ("socket did set CLOEXEC");
	  status = 1;
	}

      close (s);
    }

#if USE_SOCKETCALL
  s = syscall(__NR_socketcall, SYS_SOCKET4, PF_UNIX, SOCK_STREAM, 0, SOCKFL_CLOEXEC);
#else
  s = syscall(__NR_socket4, PF_UNIX, SOCK_STREAM, 0, SOCKFL_CLOEXEC);
#endif

  if (s < 0)
    {
      puts ("socket4 failed");
      status = 1;
    }
  else
    {
      int fl = fcntl(s, F_GETFD);
      if ((fl & FD_CLOEXEC) == 0)
	{
	  puts ("socket4 did not set CLOEXEC");
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
      int fl1 = fcntl(sp[0], F_GETFD);
      int fl2 = fcntl(sp[1], F_GETFD);
      if ((fl1 & FD_CLOEXEC) != 0 || (fl2 & FD_CLOEXEC) != 0)
	{
	  puts ("socketpair did set CLOEXEC");
	  status = 1;
	}

      close (sp[0]);
      close (sp[1]);
    }

#if USE_SOCKETCALL
  s = syscall(__NR_socketcall, SYS_SOCKETPAIR5, PF_UNIX, SOCK_STREAM, 0, sp, SOCKFL_CLOEXEC);
#else
  s = syscall(__NR_socketpair5, PF_UNIX, SOCK_STREAM, 0, sp, SOCKFL_CLOEXEC);
#endif
  if (s < 0)
    {
      puts ("socketpair5 failed");
      status = 1;
    }
  else
    {
      int fl1 = fcntl(sp[0], F_GETFD);
      int fl2 = fcntl(sp[1], F_GETFD);
      if ((fl1 & FD_CLOEXEC) == 0 || (fl2 & FD_CLOEXEC) == 0)
	{
	  puts ("socketpair did not set CLOEXEC");
	  status = 1;
	}

      close (sp[0]);
      close (sp[1]);
    }

  pthread_barrier_init (&b, NULL, 2);
  
  pthread_t th;
  if (pthread_create (&th, NULL, tf, NULL) != 0)
    {
      puts ("pthread_create failed");
      status = 1;
    }
  else
    {
      int s = socket (AF_INET, SOCK_STREAM, 0);
      struct sockaddr_in sin;
      sin.sin_family = AF_INET;
      sin.sin_addr.s_addr = htonl (INADDR_LOOPBACK);
      sin.sin_port = htons (PORT);
      bind (s, (struct sockaddr *) &sin, sizeof (sin));
      listen (s, SOMAXCONN);

      pthread_barrier_wait (&b);

      int s2 = accept (s, NULL, 0);
      if (s2 < 0)
	{
	  puts ("accept failed");
	  status = 1;
	}
      else
	{
	  int fl = fcntl(s2, F_GETFD);
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
      s2 = syscall (__NR_socketcall, SYS_ACCEPT4, s, NULL, 0, SOCKFL_CLOEXEC);
#else
      s2 = syscall (__NR_accept4, s, NULL, 0, SOCKFL_CLOEXEC);
#endif
      if (s2 < 0)
	{
	  puts ("accept4 failed");
	  status = 1;
	}
      else
	{
	  int fl = fcntl(s2, F_GETFD);
	  if ((fl & FD_CLOEXEC) == 0)
	    {
	      puts ("accept4 did not set CLOEXEC");
	      status = 1;
	    }

	  close (s2);
        }

      close (s);
    }

  return status;
}


Signed-off-by: Ulrich Drepper <drepper@redhat.com>

 include/asm-x86/unistd_64.h |    6 ++
 include/linux/net.h         |    3 +
 include/linux/socket.h      |    8 ++
 include/linux/syscalls.h    |    3 +
 net/compat.c                |   22 +++++---
 net/socket.c                |  118 ++++++++++++++++++++++++++++++++++++--------
 6 files changed, 133 insertions(+), 27 deletions(-)


diff --git a/include/asm-x86/unistd_64.h b/include/asm-x86/unistd_64.h
index fe26e36..0d4aed0 100644
--- a/include/asm-x86/unistd_64.h
+++ b/include/asm-x86/unistd_64.h
@@ -639,6 +639,12 @@ __SYSCALL(__NR_fallocate, sys_fallocate)
 __SYSCALL(__NR_timerfd_settime, sys_timerfd_settime)
 #define __NR_timerfd_gettime			287
 __SYSCALL(__NR_timerfd_gettime, sys_timerfd_gettime)
+#define __NR_socket4				288
+__SYSCALL(__NR_socket4, sys_socket4)
+#define __NR_accept4				289
+__SYSCALL(__NR_accept4, sys_accept4)
+#define __NR_socketpair5			290
+__SYSCALL(__NR_socketpair5, sys_socketpair5)
 
 
 #ifndef __NO_STUBS
diff --git a/include/linux/net.h b/include/linux/net.h
index 71f7dd5..5e4a774 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -46,6 +46,9 @@ struct net;
 #define SYS_GETSOCKOPT	15		/* sys_getsockopt(2)		*/
 #define SYS_SENDMSG	16		/* sys_sendmsg(2)		*/
 #define SYS_RECVMSG	17		/* sys_recvmsg(2)		*/
+#define SYS_SOCKET4	18		/* sys_socket4(2)		*/
+#define SYS_ACCEPT4	19		/* sys_accept4(2)		*/
+#define SYS_SOCKETPAIR5	20		/* sys_socketpair5(2)		*/
 
 typedef enum {
 	SS_FREE = 0,			/* not allocated		*/
diff --git a/include/linux/socket.h b/include/linux/socket.h
index bd2b30a..ceaf57f 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -32,6 +32,14 @@ extern void socket_seq_show(struct seq_file *seq);
 typedef unsigned short	sa_family_t;
 
 /*
+ * Flags for the socket functions.
+ */
+#ifndef SOCKFL_CLOEXEC
+#define SOCKFL_CLOEXEC	02000000	/* Created file descriptor(s) have
+					 * close-on-exec flag set.  */
+#endif 
+
+/*
  *	1003.1g requires sa_family_t and that sa_data is char.
  */
  
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 8df6d13..bb50a68 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -407,6 +407,7 @@ asmlinkage long sys_getsockopt(int fd, int level, int optname,
 asmlinkage long sys_bind(int, struct sockaddr __user *, int);
 asmlinkage long sys_connect(int, struct sockaddr __user *, int);
 asmlinkage long sys_accept(int, struct sockaddr __user *, int __user *);
+asmlinkage long sys_accept4(int, struct sockaddr __user *, int __user *, int);
 asmlinkage long sys_getsockname(int, struct sockaddr __user *, int __user *);
 asmlinkage long sys_getpeername(int, struct sockaddr __user *, int __user *);
 asmlinkage long sys_send(int, void __user *, size_t, unsigned);
@@ -418,7 +419,9 @@ asmlinkage long sys_recvfrom(int, void __user *, size_t, unsigned,
 				struct sockaddr __user *, int __user *);
 asmlinkage long sys_recvmsg(int fd, struct msghdr __user *msg, unsigned flags);
 asmlinkage long sys_socket(int, int, int);
+asmlinkage long sys_socket4(int, int, int, int);
 asmlinkage long sys_socketpair(int, int, int, int __user *);
+asmlinkage long sys_socketpair5(int, int, int, int __user *, int);
 asmlinkage long sys_socketcall(int call, unsigned long __user *args);
 asmlinkage long sys_listen(int, int);
 asmlinkage long sys_poll(struct pollfd __user *ufds, unsigned int nfds,
diff --git a/net/compat.c b/net/compat.c
index 80013fb..6e71b68 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -523,9 +523,10 @@ asmlinkage long compat_sys_getsockopt(int fd, int level, int optname,
 }
 /* Argument list sizes for compat_sys_socketcall */
 #define AL(x) ((x) * sizeof(u32))
-static unsigned char nas[18]={AL(0),AL(3),AL(3),AL(3),AL(2),AL(3),
+static unsigned char nas[21]={AL(0),AL(3),AL(3),AL(3),AL(2),AL(3),
 				AL(3),AL(3),AL(4),AL(4),AL(4),AL(6),
-				AL(6),AL(2),AL(5),AL(5),AL(3),AL(3)};
+				AL(6),AL(2),AL(5),AL(5),AL(3),AL(3),
+				AL(4),AL(4),AL(5)};
 #undef AL
 
 asmlinkage long compat_sys_sendmsg(int fd, struct compat_msghdr __user *msg, unsigned flags)
@@ -544,7 +545,7 @@ asmlinkage long compat_sys_socketcall(int call, u32 __user *args)
 	u32 a[6];
 	u32 a0, a1;
 
-	if (call < SYS_SOCKET || call > SYS_RECVMSG)
+	if (call < SYS_SOCKET || call > SYS_SOCKPAIR5)
 		return -EINVAL;
 	if (copy_from_user(a, args, nas[call]))
 		return -EFAULT;
@@ -553,7 +554,7 @@ asmlinkage long compat_sys_socketcall(int call, u32 __user *args)
 
 	switch (call) {
 	case SYS_SOCKET:
-		ret = sys_socket(a0, a1, a[2]);
+		ret = sys_socket4(a0, a1, a[2], 0);
 		break;
 	case SYS_BIND:
 		ret = sys_bind(a0, compat_ptr(a1), a[2]);
@@ -565,7 +566,7 @@ asmlinkage long compat_sys_socketcall(int call, u32 __user *args)
 		ret = sys_listen(a0, a1);
 		break;
 	case SYS_ACCEPT:
-		ret = sys_accept(a0, compat_ptr(a1), compat_ptr(a[2]));
+		ret = sys_accept4(a0, compat_ptr(a1), compat_ptr(a[2]), 0);
 		break;
 	case SYS_GETSOCKNAME:
 		ret = sys_getsockname(a0, compat_ptr(a1), compat_ptr(a[2]));
@@ -574,7 +575,7 @@ asmlinkage long compat_sys_socketcall(int call, u32 __user *args)
 		ret = sys_getpeername(a0, compat_ptr(a1), compat_ptr(a[2]));
 		break;
 	case SYS_SOCKETPAIR:
-		ret = sys_socketpair(a0, a1, a[2], compat_ptr(a[3]));
+		ret = sys_socketpair5(a0, a1, a[2], compat_ptr(a[3]), 0);
 		break;
 	case SYS_SEND:
 		ret = sys_send(a0, compat_ptr(a1), a[2], a[3]);
@@ -605,6 +606,15 @@ asmlinkage long compat_sys_socketcall(int call, u32 __user *args)
 	case SYS_RECVMSG:
 		ret = compat_sys_recvmsg(a0, compat_ptr(a1), a[2]);
 		break;
+	case SYS_SOCKET4:
+		ret = sys_socket4(a0, a1, a[2], a[3]);
+		break;
+	case SYS_ACCEPT4:
+		ret = sys_accept4(a0, compat_ptr(a1), compat_ptr(a[2]), a[3]);
+		break;
+	case SYS_SOCKETPAIR5:
+		ret = sys_socketpair5(a0, a1, a[2], compat_ptr(a[3]), a[4]);
+		break;
 	default:
 		ret = -EINVAL;
 		break;
diff --git a/net/socket.c b/net/socket.c
index 9b5c917..339bf5a 100644
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
+static int sock_map_fd_flags(struct socket *sock, int flags)
 {
 	struct file *newfile;
-	int fd = sock_alloc_fd(&newfile);
+	int fd = sock_alloc_fd(&newfile, flags);
 
 	if (likely(fd >= 0)) {
 		int err = sock_attach_fd(sock, newfile);
@@ -413,10 +413,15 @@ int sock_map_fd(struct socket *sock)
 	return fd;
 }
 
+int sock_map_fd(struct socket *sock)
+{
+	return sock_map_fd_flags(sock, 0);
+}
+
 static struct socket *sock_from_file(struct file *file, int *err)
 {
 	if (file->f_op == &socket_file_ops)
-		return file->private_data;	/* set in sock_map_fd */
+		return file->private_data;	/* set in sock_map_fd_flags */
 
 	*err = -ENOTSOCK;
 	return NULL;
@@ -1213,16 +1218,30 @@ int sock_create_kern(int family, int type, int protocol, struct socket **res)
 	return __sock_create(&init_net, family, type, protocol, res, 1);
 }
 
-asmlinkage long sys_socket(int family, int type, int protocol)
+asmlinkage long sys_socket4(int family, int type, int protocol, int flags)
 {
 	int retval;
 	struct socket *sock;
+	int fflags;
+
+	if ((flags & ~SOCKFL_CLOEXEC) != 0)
+		return -EINVAL;
+
+	/*
+	 * Convert socket flags into appropriate file system flags.
+	 * The compiler should completely eliminate this code and
+	 * the fflags variable if no transformation is needed.
+	 */
+	if (SOCKFL_CLOEXEC == O_CLOEXEC)
+		fflags = flags;
+	else
+		fflags = (flags & SOCKFL_CLOEXEC) ? O_CLOEXEC : 0;
 
 	retval = sock_create(family, type, protocol, &sock);
 	if (retval < 0)
 		goto out;
 
-	retval = sock_map_fd(sock);
+	retval = sock_map_fd_flags(sock, fflags);
 	if (retval < 0)
 		goto out_release;
 
@@ -1235,16 +1254,35 @@ out_release:
 	return retval;
 }
 
+asmlinkage long sys_socket(int family, int type, int protocol)
+{
+	return sys_socket4(family, type, protocol, 0);
+}
+
 /*
  *	Create a pair of connected sockets.
  */
 
-asmlinkage long sys_socketpair(int family, int type, int protocol,
-			       int __user *usockvec)
+asmlinkage long sys_socketpair5(int family, int type, int protocol,
+			        int __user *usockvec, int flags)
 {
 	struct socket *sock1, *sock2;
 	int fd1, fd2, err;
 	struct file *newfile1, *newfile2;
+	int fflags;
+
+	if ((flags & ~SOCKFL_CLOEXEC) != 0)
+		return -EINVAL;
+
+	/*
+	 * Convert socket flags into appropriate file system flags.
+	 * The compiler should completely eliminate this code and
+	 * the fflags variable if no transformation is needed.
+	 */
+	if (SOCKFL_CLOEXEC == O_CLOEXEC)
+		fflags = flags;
+	else
+		fflags = (flags & SOCKFL_CLOEXEC) ? O_CLOEXEC : 0;
 
 	/*
 	 * Obtain the first socket and check if the underlying protocol
@@ -1263,13 +1301,13 @@ asmlinkage long sys_socketpair(int family, int type, int protocol,
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
@@ -1330,6 +1368,12 @@ out_fd:
 	goto out;
 }
 
+asmlinkage long sys_socketpair(int family, int type, int protocol,
+			       int __user *usockvec)
+{
+	return sys_socketpair5(family, type, protocol, usockvec, 0);
+}
+
 /*
  *	Bind a name to a socket. Nothing much to do here since it's
  *	the protocol's responsibility to handle the local address.
@@ -1400,13 +1444,27 @@ asmlinkage long sys_listen(int fd, int backlog)
  *	clean when we restucture accept also.
  */
 
-asmlinkage long sys_accept(int fd, struct sockaddr __user *upeer_sockaddr,
-			   int __user *upeer_addrlen)
+asmlinkage long sys_accept4(int fd, struct sockaddr __user *upeer_sockaddr,
+			    int __user *upeer_addrlen, int flags)
 {
 	struct socket *sock, *newsock;
 	struct file *newfile;
 	int err, len, newfd, fput_needed;
 	char address[MAX_SOCK_ADDR];
+	int fflags;
+
+	if ((flags & ~SOCKFL_CLOEXEC) != 0)
+		return -EINVAL;
+
+	/*
+	 * Convert socket flags into appropriate file system flags.
+	 * The compiler should completely eliminate this code and
+	 * the fflags variable if no transformation is needed.
+	 */
+	if (SOCKFL_CLOEXEC == O_CLOEXEC)
+		fflags = flags;
+	else
+		fflags = (flags & SOCKFL_CLOEXEC) ? O_CLOEXEC : 0;
 
 	sock = sockfd_lookup_light(fd, &err, &fput_needed);
 	if (!sock)
@@ -1425,7 +1483,7 @@ asmlinkage long sys_accept(int fd, struct sockaddr __user *upeer_sockaddr,
 	 */
 	__module_get(newsock->ops->owner);
 
-	newfd = sock_alloc_fd(&newfile);
+	newfd = sock_alloc_fd(&newfile, fflags);
 	if (unlikely(newfd < 0)) {
 		err = newfd;
 		sock_release(newsock);
@@ -1478,6 +1536,12 @@ out_fd:
 	goto out_put;
 }
 
+asmlinkage long sys_accept(int fd, struct sockaddr __user *upeer_sockaddr,
+			   int __user *upeer_addrlen)
+{
+	return sys_accept4(fd, upeer_sockaddr, upeer_addrlen, 0);
+}
+
 /*
  *	Attempt to connect to a socket with the server address.  The address
  *	is in user space so we verify it is OK and move it to kernel space.
@@ -1988,10 +2052,11 @@ out:
 
 /* Argument list sizes for sys_socketcall */
 #define AL(x) ((x) * sizeof(unsigned long))
-static const unsigned char nargs[18]={
+static const unsigned char nargs[21]={
 	AL(0),AL(3),AL(3),AL(3),AL(2),AL(3),
 	AL(3),AL(3),AL(4),AL(4),AL(4),AL(6),
-	AL(6),AL(2),AL(5),AL(5),AL(3),AL(3)
+	AL(6),AL(2),AL(5),AL(5),AL(3),AL(3),
+	AL(4),AL(4),AL(5)
 };
 
 #undef AL
@@ -2010,7 +2075,7 @@ asmlinkage long sys_socketcall(int call, unsigned long __user *args)
 	unsigned long a0, a1;
 	int err;
 
-	if (call < 1 || call > SYS_RECVMSG)
+	if (call < 1 || call > SYS_SOCKETPAIR5)
 		return -EINVAL;
 
 	/* copy_from_user should be SMP safe. */
@@ -2026,7 +2091,7 @@ asmlinkage long sys_socketcall(int call, unsigned long __user *args)
 
 	switch (call) {
 	case SYS_SOCKET:
-		err = sys_socket(a0, a1, a[2]);
+		err = sys_socket4(a0, a1, a[2], 0);
 		break;
 	case SYS_BIND:
 		err = sys_bind(a0, (struct sockaddr __user *)a1, a[2]);
@@ -2039,8 +2104,8 @@ asmlinkage long sys_socketcall(int call, unsigned long __user *args)
 		break;
 	case SYS_ACCEPT:
 		err =
-		    sys_accept(a0, (struct sockaddr __user *)a1,
-			       (int __user *)a[2]);
+		    sys_accept4(a0, (struct sockaddr __user *)a1,
+			        (int __user *)a[2], 0);
 		break;
 	case SYS_GETSOCKNAME:
 		err =
@@ -2053,7 +2118,7 @@ asmlinkage long sys_socketcall(int call, unsigned long __user *args)
 				    (int __user *)a[2]);
 		break;
 	case SYS_SOCKETPAIR:
-		err = sys_socketpair(a0, a1, a[2], (int __user *)a[3]);
+		err = sys_socketpair5(a0, a1, a[2], (int __user *)a[3], 0);
 		break;
 	case SYS_SEND:
 		err = sys_send(a0, (void __user *)a1, a[2], a[3]);
@@ -2087,6 +2152,17 @@ asmlinkage long sys_socketcall(int call, unsigned long __user *args)
 	case SYS_RECVMSG:
 		err = sys_recvmsg(a0, (struct msghdr __user *)a1, a[2]);
 		break;
+	case SYS_SOCKET4:
+		err = sys_socket4(a0, a1, a[2], a[3]);
+		break;
+	case SYS_ACCEPT4:
+		err =
+		    sys_accept4(a0, (struct sockaddr __user *)a1,
+			        (int __user *)a[2], a[3]);
+		break;
+	case SYS_SOCKETPAIR5:
+		err = sys_socketpair5(a0, a1, a[2], (int __user *)a[3], a[4]);
+		break;
 	default:
 		err = -EINVAL;
 		break;
