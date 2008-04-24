From: Ulrich Drepper <drepper@redhat.com>
Subject: [PATCH] alternative^2 to sys_indirect: socket, socketpair
Date: Thu, 24 Apr 2008 12:18:09 -0400
Message-ID: <200804241618.m3OGI9kd013025@devserv.devel.redhat.com>
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:60915 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752344AbYDXQSo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2008 12:18:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is a patch with just the socket and socketpair changes which uses
a new SOCK_CLOEXEC flag.  I started the flags at the high end (ignoring
the sign bit) to avoid collisions.  accept() is not changed in this
patch.


#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/syscall.h>

#define SOCK_CLOEXEC 0x40000000

#define PORT 57392

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
      int fl = fcntl(s, F_GETFD);
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
      int fl = fcntl(s, F_GETFD);
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

  if (socketpair (PF_UNIX, SOCK_STREAM|SOCK_CLOEXEC, 0, sp) < 0)
    {
      puts ("socketpair(SOCK_CLOEXEC) failed");
      status = 1;
    }
  else
    {
      int fl1 = fcntl(sp[0], F_GETFD);
      int fl2 = fcntl(sp[1], F_GETFD);
      if ((fl1 & FD_CLOEXEC) == 0 || (fl2 & FD_CLOEXEC) == 0)
	{
	  puts ("socketpair(SOCK_CLOEXEC) did not set CLOEXEC");
	  status = 1;
	}

      close (sp[0]);
      close (sp[1]);
    }

  return status;
}


 include/linux/net.h |    3 +++
 net/socket.c        |   35 +++++++++++++++++++++++++++--------
 2 files changed, 30 insertions(+), 8 deletions(-)

Signed-off-by: Ulrich Drepper <drepper@redhat.com>

diff --git a/include/linux/net.h b/include/linux/net.h
index 71f7dd5..f5dddd8 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -91,6 +91,9 @@ enum sock_type {
 	SOCK_SEQPACKET	= 5,
 	SOCK_DCCP	= 6,
 	SOCK_PACKET	= 10,
+
+	/* Flag values, ORed to the types above.  */
+	SOCK_CLOEXEC	= 0x40000000
 };
 
 #define SOCK_MAX (SOCK_PACKET + 1)
diff --git a/net/socket.c b/net/socket.c
index 9b5c917..e144f8a 100644
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
@@ -413,6 +413,11 @@ int sock_map_fd(struct socket *sock)
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
@@ -1217,12 +1222,19 @@ asmlinkage long sys_socket(int family, int type, int protocol)
 {
 	int retval;
 	struct socket *sock;
+	int fflags = 0;
+
+	/* Extract the close-on-exec flag.  */
+	if ((type & SOCK_CLOEXEC) != 0) {
+		fflags = O_CLOEXEC;
+		type &= ~SOCK_CLOEXEC;
+	}
 
 	retval = sock_create(family, type, protocol, &sock);
 	if (retval < 0)
 		goto out;
 
-	retval = sock_map_fd(sock);
+	retval = sock_map_fd_flags(sock, fflags);
 	if (retval < 0)
 		goto out_release;
 
@@ -1245,6 +1257,13 @@ asmlinkage long sys_socketpair(int family, int type, int protocol,
 	struct socket *sock1, *sock2;
 	int fd1, fd2, err;
 	struct file *newfile1, *newfile2;
+	int fflags = 0;
+
+	/* Extract the close-on-exec flag.  */
+	if ((type & SOCK_CLOEXEC) != 0) {
+		fflags = O_CLOEXEC;
+		type &= ~SOCK_CLOEXEC;
+	}
 
 	/*
 	 * Obtain the first socket and check if the underlying protocol
@@ -1263,13 +1282,13 @@ asmlinkage long sys_socketpair(int family, int type, int protocol,
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
@@ -1425,7 +1444,7 @@ asmlinkage long sys_accept(int fd, struct sockaddr __user *upeer_sockaddr,
 	 */
 	__module_get(newsock->ops->owner);
 
-	newfd = sock_alloc_fd(&newfile);
+	newfd = sock_alloc_fd(&newfile, 0);
 	if (unlikely(newfd < 0)) {
 		err = newfd;
 		sock_release(newsock);
