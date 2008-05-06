From: Ulrich Drepper <drepper@redhat.com>
Subject: [PATCH 12/18] flag parameters: NONBLOCK in socket and socketpair
Date: Tue, 6 May 2008 17:18:07 -0400
Message-ID: <200805062118.m46LI7im004072@devserv.devel.redhat.com>
Cc: akpm@linux-foundation.org, davidel@xmailserver.org,
	mtk.manpages@gmail.com, torvalds@linux-foundation.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:48590 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933079AbYEFVSx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2008 17:18:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces support for the SOCK_NONBLOCK flag in socket,
socketpair, and  paccept.  To do this the internal function sock_attach_fd
gets an additional parameter which it uses to set the appropriate flag for
the file descriptor.

Given that in modern, scalable programs almost all socket connections are
non-blocking and the minimal additional cost for the new functionality
I see no reason not to add this code.

The following test must be adjusted for architectures other than x86 and
x86-64 and in case the syscall numbers changed.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#include <fcntl.h>
#include <pthread.h>
#include <stdio.h>
#include <unistd.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/syscall.h>

#ifndef __NR_paccept
# ifdef __x86_64__
#  define __NR_paccept 288
# elif defined __i386__
#  define SYS_PACCEPT 18
#  define USE_SOCKETCALL 1
# else
#  error "need __NR_paccept"
# endif
#endif

#ifdef USE_SOCKETCALL
# define paccept(fd, addr, addrlen, mask, flags) \
  ({ long args[6] = { \
       (long) fd, (long) addr, (long) addrlen, (long) mask, 8, (long) flags }; \
     syscall (__NR_socketcall, SYS_PACCEPT, args); })
#else
# define paccept(fd, addr, addrlen, mask, flags) \
  syscall (__NR_paccept, fd, addr, addrlen, mask, 8, flags)
#endif

#define PORT 57392

#define SOCK_NONBLOCK O_NONBLOCK

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
  sin.sin_port = htons (PORT);
  connect (s, (const struct sockaddr *) &sin, sizeof (sin));
  close (s);
  pthread_barrier_wait (&b);

  return NULL;
}

int
main (void)
{
  int fd;
  fd = socket (PF_INET, SOCK_STREAM, 0);
  if (fd == -1)
    {
      puts ("socket(0) failed");
      return 1;
    }
  int fl = fcntl (fd, F_GETFL);
  if (fl == -1)
    {
      puts ("fcntl failed");
      return 1;
    }
  if (fl & O_NONBLOCK)
    {
      puts ("socket(0) set non-blocking mode");
      return 1;
    }
  close (fd);

  fd = socket (PF_INET, SOCK_STREAM|SOCK_NONBLOCK, 0);
  if (fd == -1)
    {
      puts ("socket(SOCK_NONBLOCK) failed");
      return 1;
    }
  fl = fcntl (fd, F_GETFL);
  if (fl == -1)
    {
      puts ("fcntl failed");
      return 1;
    }
  if ((fl & O_NONBLOCK) == 0)
    {
      puts ("socket(SOCK_NONBLOCK) does not set non-blocking mode");
      return 1;
    }
  close (fd);

  int fds[2];
  if (socketpair (PF_UNIX, SOCK_STREAM, 0, fds) == -1)
    {
      puts ("socketpair(0) failed");
      return 1;
    }
  for (int i = 0; i < 2; ++i)
    {
      fl = fcntl (fds[i], F_GETFL);
      if (fl == -1)
        {
          puts ("fcntl failed");
          return 1;
        }
      if (fl & O_NONBLOCK)
        {
          printf ("socketpair(0) set non-blocking mode for fds[%d]\n", i);
          return 1;
        }
      close (fds[i]);
    }

  if (socketpair (PF_UNIX, SOCK_STREAM|SOCK_NONBLOCK, 0, fds) == -1)
    {
      puts ("socketpair(SOCK_NONBLOCK) failed");
      return 1;
    }
  for (int i = 0; i < 2; ++i)
    {
      fl = fcntl (fds[i], F_GETFL);
      if (fl == -1)
        {
          puts ("fcntl failed");
          return 1;
        }
      if ((fl & O_NONBLOCK) == 0)
        {
          printf ("socketpair(SOCK_NONBLOCK) does not set non-blocking mode for fds[%d]\n", i);
          return 1;
        }
      close (fds[i]);
    }

  pthread_barrier_init (&b, NULL, 2);

  struct sockaddr_in sin;
  pthread_t th;
  if (pthread_create (&th, NULL, tf, NULL) != 0)
    {
      puts ("pthread_create failed");
      return 1;
    }

  int s = socket (AF_INET, SOCK_STREAM, 0);
  int reuse = 1;
  setsockopt (s, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof (reuse));
  sin.sin_family = AF_INET;
  sin.sin_addr.s_addr = htonl (INADDR_LOOPBACK);
  sin.sin_port = htons (PORT);
  bind (s, (struct sockaddr *) &sin, sizeof (sin));
  listen (s, SOMAXCONN);

  pthread_barrier_wait (&b);

  int s2 = paccept (s, NULL, 0, NULL, 0);
  if (s2 < 0)
    {
      puts ("paccept(0) failed");
      return 1;
    }

  fl = fcntl (s2, F_GETFL);
  if (fl & O_NONBLOCK)
    {
      puts ("paccept(0) set non-blocking mode");
      return 1;
    }
  close (s2);
  close (s);

  pthread_barrier_wait (&b);

  s = socket (AF_INET, SOCK_STREAM, 0);
  sin.sin_port = htons (PORT);
  setsockopt (s, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof (reuse));
  bind (s, (struct sockaddr *) &sin, sizeof (sin));
  listen (s, SOMAXCONN);

  pthread_barrier_wait (&b);

  s2 = paccept (s, NULL, 0, NULL, SOCK_NONBLOCK);
  if (s2 < 0)
    {
      puts ("paccept(SOCK_NONBLOCK) failed");
      return 1;
    }

  fl = fcntl (s2, F_GETFL);
  if ((fl & O_NONBLOCK) == 0)
    {
      puts ("paccept(SOCK_NONBLOCK) does not set non-blocking mode");
      return 1;
    }
  close (s2);
  close (s);

  pthread_barrier_wait (&b);
  puts ("OK");

  return 0;
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 include/linux/net.h |    3 ++-
 net/socket.c        |   20 ++++++++++----------
 2 files changed, 12 insertions(+), 11 deletions(-)


Signed-off-by: Ulrich Drepper <drepper@redhat.com>

diff --git a/include/linux/net.h b/include/linux/net.h
index b4ad432..1b35fd5 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -20,7 +20,7 @@
 
 #include <linux/wait.h>
 #include <linux/socket.h>
-#include <linux/fcntl.h>	/* For O_CLOEXEC */
+#include <linux/fcntl.h>	/* For O_CLOEXEC and O_NONBLOCK */
 #include <asm/socket.h>
 
 struct poll_table_struct;
@@ -102,6 +102,7 @@ enum sock_type {
 
 /* Flags for socket, socketpair, paccept */
 #define SOCK_CLOEXEC	O_CLOEXEC
+#define SOCK_NONBLOCK	O_NONBLOCK
 
 #endif /* ARCH_HAS_SOCKET_TYPES */
 
diff --git a/net/socket.c b/net/socket.c
index 634ad83..7cb0a5e 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -366,7 +366,7 @@ static int sock_alloc_fd(struct file **filep, int flags)
 	return fd;
 }
 
-static int sock_attach_fd(struct socket *sock, struct file *file)
+static int sock_attach_fd(struct socket *sock, struct file *file, int flags)
 {
 	struct dentry *dentry;
 	struct qstr name = { .name = "" };
@@ -388,7 +388,7 @@ static int sock_attach_fd(struct socket *sock, struct file *file)
 	init_file(file, sock_mnt, dentry, FMODE_READ | FMODE_WRITE,
 		  &socket_file_ops);
 	SOCK_INODE(sock)->i_fop = &socket_file_ops;
-	file->f_flags = O_RDWR;
+	file->f_flags = O_RDWR | (flags & O_NONBLOCK);
 	file->f_pos = 0;
 	file->private_data = sock;
 
@@ -401,7 +401,7 @@ int sock_map_fd(struct socket *sock, int flags)
 	int fd = sock_alloc_fd(&newfile, flags);
 
 	if (likely(fd >= 0)) {
-		int err = sock_attach_fd(sock, newfile);
+		int err = sock_attach_fd(sock, newfile, flags);
 
 		if (unlikely(err < 0)) {
 			put_filp(newfile);
@@ -1220,7 +1220,7 @@ asmlinkage long sys_socket(int family, int type, int protocol)
 	int flags;
 
 	flags = type & ~SOCK_TYPE_MASK;
-	if (flags & ~SOCK_CLOEXEC)
+	if (flags & ~(SOCK_CLOEXEC | SOCK_NONBLOCK))
 		return -EINVAL;
 	type &= SOCK_TYPE_MASK;
 
@@ -1228,7 +1228,7 @@ asmlinkage long sys_socket(int family, int type, int protocol)
 	if (retval < 0)
 		goto out;
 
-	retval = sock_map_fd(sock, flags & O_CLOEXEC);
+	retval = sock_map_fd(sock, flags & (O_CLOEXEC | O_NONBLOCK));
 	if (retval < 0)
 		goto out_release;
 
@@ -1254,7 +1254,7 @@ asmlinkage long sys_socketpair(int family, int type, int protocol,
 	int flags;
 
 	flags = type & ~SOCK_TYPE_MASK;
-	if (flags & ~SOCK_CLOEXEC)
+	if (flags & ~(SOCK_CLOEXEC | SOCK_NONBLOCK))
 		return -EINVAL;
 	type &= SOCK_TYPE_MASK;
 
@@ -1289,12 +1289,12 @@ asmlinkage long sys_socketpair(int family, int type, int protocol,
 		goto out_release_both;
 	}
 
-	err = sock_attach_fd(sock1, newfile1);
+	err = sock_attach_fd(sock1, newfile1, flags & O_NONBLOCK);
 	if (unlikely(err < 0)) {
 		goto out_fd2;
 	}
 
-	err = sock_attach_fd(sock2, newfile2);
+	err = sock_attach_fd(sock2, newfile2, flags & O_NONBLOCK);
 	if (unlikely(err < 0)) {
 		fput(newfile1);
 		goto out_fd1;
@@ -1420,7 +1420,7 @@ long do_accept(int fd, struct sockaddr __user *upeer_sockaddr,
 	int err, len, newfd, fput_needed;
 	char address[MAX_SOCK_ADDR];
 
-	if (flags & ~SOCK_CLOEXEC)
+	if (flags & ~(SOCK_CLOEXEC | SOCK_NONBLOCK))
 		return -EINVAL;
 
 	sock = sockfd_lookup_light(fd, &err, &fput_needed);
@@ -1447,7 +1447,7 @@ long do_accept(int fd, struct sockaddr __user *upeer_sockaddr,
 		goto out_put;
 	}
 
-	err = sock_attach_fd(newsock, newfile);
+	err = sock_attach_fd(newsock, newfile, flags & O_NONBLOCK);
 	if (err < 0)
 		goto out_fd_simple;
 
