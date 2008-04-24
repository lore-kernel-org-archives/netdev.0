From: Ulrich Drepper <drepper@redhat.com>
Subject: [PATCH] socket, socketpair w/flags, accept4
Date: Thu, 24 Apr 2008 14:20:47 -0400
Message-ID: <200804241820.m3OIKlMK017580@devserv.devel.redhat.com>
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:40402 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753002AbYDXSUw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2008 14:20:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If Alan's comments reflect the general opinion this patch should have
all the changes.  No new sock_map_fd_flags function and there is a
helper function to convert socket flags into file flags.

The new accept syscall is also in.   It uses the same SOCK_CLOEXEC
flags.  I think everything else is confusing.  This is an aspect
where new socket/socketpair syscalls would be better.

The code changes are really minimal.  And don't get too hung up on the
internal name of the syscall.  I think accept4 is more desriptive than
paccept since a) suffixes more easily indicate derived functionality
and b) the 4 actually indicates to the initiated what has changed.
If there are good reasons otherwise the userlevel interface can still
be something completely different.


#include <fcntl.h>
#include <pthread.h>
#include <stdio.h>
#include <unistd.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/syscall.h>

#define SOCK_CLOEXEC 0x40000000

#ifdef __x86_64__
#define __NR_accept4 288
#elif __i386__
#define SYS_ACCEPT4     18
#define USE_SOCKETCALL 1
#else
#error "define syscall numbers for this architecture"
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
      s2 = syscall (__NR_socketcall, SYS_ACCEPT4, s, NULL, 0, SOCK_CLOEXEC);
#else
      s2 = syscall (__NR_accept4, s, NULL, 0, SOCK_CLOEXEC);
#endif
      if (s2 < 0)
	{
	  puts ("accept4 failed");
	  status = 1;
	}
      else
	{
	  int fl = fcntl (s2, F_GETFD);
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



 include/asm-x86/unistd_64.h |    2 +
 include/linux/net.h         |    6 +++-
 include/linux/syscalls.h    |    1 
 net/compat.c                |   12 +++++---
 net/socket.c                |   62 +++++++++++++++++++++++++++++++++-----------
 5 files changed, 63 insertions(+), 20 deletions(-)


Signed-off-by: Ulrich Drepper <drepper@redhat.com>

diff --git a/include/asm-x86/unistd_64.h b/include/asm-x86/unistd_64.h
index fe26e36..c7e4abf 100644
--- a/include/asm-x86/unistd_64.h
+++ b/include/asm-x86/unistd_64.h
@@ -639,6 +639,8 @@ __SYSCALL(__NR_fallocate, sys_fallocate)
 __SYSCALL(__NR_timerfd_settime, sys_timerfd_settime)
 #define __NR_timerfd_gettime			287
 __SYSCALL(__NR_timerfd_gettime, sys_timerfd_gettime)
+#define __NR_accept4				288
+__SYSCALL(__NR_accept4, sys_accept4)
 
 
 #ifndef __NO_STUBS
diff --git a/include/linux/net.h b/include/linux/net.h
index 71f7dd5..133ef65 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -46,6 +46,7 @@ struct net;
 #define SYS_GETSOCKOPT	15		/* sys_getsockopt(2)		*/
 #define SYS_SENDMSG	16		/* sys_sendmsg(2)		*/
 #define SYS_RECVMSG	17		/* sys_recvmsg(2)		*/
+#define SYS_ACCEPT4	18		/* sys_accept4(2)		*/
 
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
@@ -208,7 +212,7 @@ extern int   	     sock_sendmsg(struct socket *sock, struct msghdr *msg,
 				  size_t len);
 extern int	     sock_recvmsg(struct socket *sock, struct msghdr *msg,
 				  size_t size, int flags);
-extern int 	     sock_map_fd(struct socket *sock);
+extern int 	     sock_map_fd(struct socket *sock, int flags);
 extern struct socket *sockfd_lookup(int fd, int *err);
 #define		     sockfd_put(sock) fput(sock->file)
 extern int	     net_ratelimit(void);
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 8df6d13..42f5ac0 100644
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
diff --git a/net/compat.c b/net/compat.c
index 80013fb..b28d568 100644
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
+				AL(4)};
 #undef AL
 
 asmlinkage long compat_sys_sendmsg(int fd, struct compat_msghdr __user *msg, unsigned flags)
@@ -544,7 +545,7 @@ asmlinkage long compat_sys_socketcall(int call, u32 __user *args)
 	u32 a[6];
 	u32 a0, a1;
 
-	if (call < SYS_SOCKET || call > SYS_RECVMSG)
+	if (call < SYS_SOCKET || call > SYS_ACCEPT4)
 		return -EINVAL;
 	if (copy_from_user(a, args, nas[call]))
 		return -EFAULT;
@@ -565,7 +566,7 @@ asmlinkage long compat_sys_socketcall(int call, u32 __user *args)
 		ret = sys_listen(a0, a1);
 		break;
 	case SYS_ACCEPT:
-		ret = sys_accept(a0, compat_ptr(a1), compat_ptr(a[2]));
+		ret = sys_accept4(a0, compat_ptr(a1), compat_ptr(a[2]), 0);
 		break;
 	case SYS_GETSOCKNAME:
 		ret = sys_getsockname(a0, compat_ptr(a1), compat_ptr(a[2]));
@@ -605,6 +606,9 @@ asmlinkage long compat_sys_socketcall(int call, u32 __user *args)
 	case SYS_RECVMSG:
 		ret = compat_sys_recvmsg(a0, compat_ptr(a1), a[2]);
 		break;
+	case SYS_ACCEPT4:
+		ret = sys_accept4(a0, compat_ptr(a1), compat_ptr(a[2]), a[3]);
+		break;
 	default:
 		ret = -EINVAL;
 		break;
diff --git a/net/socket.c b/net/socket.c
index 9b5c917..0859cee 100644
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
+asmlinkage long sys_accept4(int fd, struct sockaddr __user *upeer_sockaddr,
+			    int __user *upeer_addrlen, int flags)
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
@@ -1478,6 +1498,12 @@ out_fd:
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
@@ -1988,10 +2014,11 @@ out:
 
 /* Argument list sizes for sys_socketcall */
 #define AL(x) ((x) * sizeof(unsigned long))
-static const unsigned char nargs[18]={
+static const unsigned char nargs[19]={
 	AL(0),AL(3),AL(3),AL(3),AL(2),AL(3),
 	AL(3),AL(3),AL(4),AL(4),AL(4),AL(6),
-	AL(6),AL(2),AL(5),AL(5),AL(3),AL(3)
+	AL(6),AL(2),AL(5),AL(5),AL(3),AL(3),
+	AL(4)
 };
 
 #undef AL
@@ -2010,7 +2037,7 @@ asmlinkage long sys_socketcall(int call, unsigned long __user *args)
 	unsigned long a0, a1;
 	int err;
 
-	if (call < 1 || call > SYS_RECVMSG)
+	if (call < 1 || call > SYS_ACCEPT4)
 		return -EINVAL;
 
 	/* copy_from_user should be SMP safe. */
@@ -2039,8 +2066,8 @@ asmlinkage long sys_socketcall(int call, unsigned long __user *args)
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
@@ -2087,6 +2114,11 @@ asmlinkage long sys_socketcall(int call, unsigned long __user *args)
 	case SYS_RECVMSG:
 		err = sys_recvmsg(a0, (struct msghdr __user *)a1, a[2]);
 		break;
+	case SYS_ACCEPT4:
+		err =
+		    sys_accept4(a0, (struct sockaddr __user *)a1,
+			        (int __user *)a[2], a[3]);
+		break;
 	default:
 		err = -EINVAL;
 		break;
