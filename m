From: Ulrich Drepper <drepper@redhat.com>
Subject: [PATCH 13/18] flag parameters: NONBLOCK in socket and socketpair
Date: Sun, 4 May 2008 23:42:46 -0400
Message-ID: <200805050342.m453gkn4029850@devserv.devel.redhat.com>
Cc: akpm@linux-foundation.org, davidel@xmailserver.org,
	mtk.manpages@gmail.com, torvalds@linux-foundation.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52493 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754780AbYEEDm6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 May 2008 23:42:58 -0400
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

#define SOCK_NONBLOCK 0x20000000

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


 include/linux/net.h |    1 +
 net/socket.c        |   13 +++++++------
 2 files changed, 8 insertions(+), 6 deletions(-)


Signed-off-by: Ulrich Drepper <drepper@redhat.com>

diff --git a/include/linux/net.h b/include/linux/net.h
index 71f7dd5..fcd3694 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -94,6 +94,7 @@ enum sock_type {
 	SOCK_PACKET	= 10,
 
 	/* Flag values, ORed to the types above.  */
+	SOCK_NONBLOCK	= 0x20000000,
 	SOCK_CLOEXEC	= 0x40000000
 };
 
diff --git a/net/socket.c b/net/socket.c
index 66c4a8c..1df03ae 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -367,7 +367,7 @@ static int sock_alloc_fd(struct file **filep)
 	return fd;
 }
 
-static int sock_attach_fd(struct socket *sock, struct file *file)
+static int sock_attach_fd(struct socket *sock, struct file *file, int flags)
 {
 	struct dentry *dentry;
 	struct qstr name = { .name = "" };
@@ -389,20 +389,20 @@ static int sock_attach_fd(struct socket *sock, struct file *file)
 	init_file(file, sock_mnt, dentry, FMODE_READ | FMODE_WRITE,
 		  &socket_file_ops);
 	SOCK_INODE(sock)->i_fop = &socket_file_ops;
-	file->f_flags = O_RDWR;
+	file->f_flags = O_RDWR | (flags & O_NONBLOCK);
 	file->f_pos = 0;
 	file->private_data = sock;
 
 	return 0;
 }
 
 int sock_map_fd(struct socket *sock, int flags)
 {
 	struct file *newfile;
 	int fd = sock_alloc_fd(&newfile, flags);
 
 	if (likely(fd >= 0)) {
-		int err = sock_attach_fd(sock, newfile);
+		int err = sock_attach_fd(sock, newfile, flags);
 
 		if (unlikely(err < 0)) {
 			put_filp(newfile);
@@ -1216,6 +1216,7 @@ int sock_create_kern(int family, int type, int protocol, struct socket **res)
 
 static const struct flags_rmap sock_file_flags_remap[] = {
 	{ SOCK_CLOEXEC, O_CLOEXEC },
+	{ SOCK_NONBLOCK, O_NONBLOCK }
 };
 
 asmlinkage long sys_socket(int family, int type, int protocol)
@@ -1292,12 +1293,12 @@ asmlinkage long sys_socketpair(int family, int type, int protocol,
 		goto out_release_both;
 	}
 
-	err = sock_attach_fd(sock1, newfile1);
+	err = sock_attach_fd(sock1, newfile1, fflags);
 	if (unlikely(err < 0)) {
 		goto out_fd2;
 	}
 
-	err = sock_attach_fd(sock2, newfile2);
+	err = sock_attach_fd(sock2, newfile2, fflags);
 	if (unlikely(err < 0)) {
 		fput(newfile1);
 		goto out_fd1;
@@ -1456,7 +1457,7 @@ long do_accept(int fd, struct sockaddr __user *upeer_sockaddr,
 		goto out_put;
 	}
 
-	err = sock_attach_fd(newsock, newfile);
+	err = sock_attach_fd(newsock, newfile, fflags);
 	if (err < 0)
 		goto out_fd_simple;
 
