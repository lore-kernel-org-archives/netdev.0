From: Ulrich Drepper <drepper@redhat.com>
Subject: [PATCH 02/18] flag parameters: socket and socketpair
Date: Sun, 4 May 2008 23:42:46 -0400
Message-ID: <200805050342.m453gktl029817@devserv.devel.redhat.com>
Cc: akpm@linux-foundation.org, davidel@xmailserver.org,
	mtk.manpages@gmail.com, torvalds@linux-foundation.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52530 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757000AbYEEDn0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 May 2008 23:43:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for flag values which are ORed to the type passwd
to socket and socketpair.  The additional code is minimal.  Beside
decoding the flags with the library function introduced in a prior patch
all that has to be done is to pass the new value around.

The internal functions sock_alloc_fd and sock_map_fd get a new parameters
and all callers are changed.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>
#include <netinet/in.h>
#include <sys/socket.h>

#define PORT 57392

#define SOCK_CLOEXEC 0x40000000

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
  int coe = fcntl (fd, F_GETFD);
  if (coe == -1)
    {
      puts ("fcntl failed");
      return 1;
    }
  if (coe & FD_CLOEXEC)
    {
      puts ("socket(0) set close-on-exec flag");
      return 1;
    }
  close (fd);

  fd = socket (PF_INET, SOCK_STREAM|SOCK_CLOEXEC, 0);
  if (fd == -1)
    {
      puts ("socket(SOCK_CLOEXEC) failed");
      return 1;
    }
  coe = fcntl (fd, F_GETFD);
  if (coe == -1)
    {
      puts ("fcntl failed");
      return 1;
    }
  if ((coe & FD_CLOEXEC) == 0)
    {
      puts ("socket(SOCK_CLOEXEC) does not set close-on-exec flag");
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
      coe = fcntl (fds[i], F_GETFD);
      if (coe == -1)
        {
          puts ("fcntl failed");
          return 1;
        }
      if (coe & FD_CLOEXEC)
        {
          printf ("socketpair(0) set close-on-exec flag for fds[%d]\n", i);
          return 1;
        }
      close (fds[i]);
    }

  if (socketpair (PF_UNIX, SOCK_STREAM|SOCK_CLOEXEC, 0, fds) == -1)
    {
      puts ("socketpair(SOCK_CLOEXEC) failed");
      return 1;
    }
  for (int i = 0; i < 2; ++i)
    {
      coe = fcntl (fds[i], F_GETFD);
      if (coe == -1)
        {
          puts ("fcntl failed");
          return 1;
        }
      if ((coe & FD_CLOEXEC) == 0)
        {
          printf ("socketpair(SOCK_CLOEXEC) does not set close-on-exec flag for fds[%d]\n", i);
          return 1;
        }
      close (fds[i]);
    }

  puts ("OK");

  return 0;
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 include/linux/net.h |    5 ++++-
 net/9p/trans_fd.c   |    2 +-
 net/sctp/socket.c   |    2 +-
 net/socket.c        |   31 +++++++++++++++++++++++--------
 4 files changed, 29 insertions(+), 11 deletions(-)


Signed-off-by: Ulrich Drepper <drepper@redhat.com>

diff --git a/include/linux/net.h b/include/linux/net.h
index 71f7dd5..fcd3694 100644
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
@@ -208,7 +211,7 @@ extern int   	     sock_sendmsg(struct socket *sock, struct msghdr *msg,
 				  size_t len);
 extern int	     sock_recvmsg(struct socket *sock, struct msghdr *msg,
 				  size_t size, int flags);
-extern int 	     sock_map_fd(struct socket *sock);
+extern int 	     sock_map_fd(struct socket *sock, int flags);
 extern struct socket *sockfd_lookup(int fd, int *err);
 #define		     sockfd_put(sock) fput(sock->file)
 extern int	     net_ratelimit(void);
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
index 66c4a8c..1df03ae 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -85,6 +85,7 @@
 #include <linux/audit.h>
 #include <linux/wireless.h>
 #include <linux/nsproxy.h>
+#include <linux/flagsremap.h>
 
 #include <asm/uaccess.h>
 #include <asm/unistd.h>
@@ -348,11 +349,11 @@ static struct dentry_operations sockfs_dentry_operations = {
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
 
@@ -395,10 +396,10 @@ static int sock_attach_fd(struct socket *sock, struct file *file)
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
@@ -1213,16 +1214,25 @@ int sock_create_kern(int family, int type, int protocol, struct socket **res)
 	return __sock_create(&init_net, family, type, protocol, res, 1);
 }
 
+static const struct flags_rmap sock_file_flags_remap[] = {
+	{ SOCK_CLOEXEC, O_CLOEXEC },
+};
+
 asmlinkage long sys_socket(int family, int type, int protocol)
 {
 	int retval;
 	struct socket *sock;
+	int fflags;
+
+	type = flags_remap(sock_file_flags_remap,
+			   ARRAY_SIZE(sock_file_flags_remap),
+			   type, &fflags);
 
 	retval = sock_create(family, type, protocol, &sock);
 	if (retval < 0)
 		goto out;
 
-	retval = sock_map_fd(sock);
+	retval = sock_map_fd(sock, fflags);
 	if (retval < 0)
 		goto out_release;
 
@@ -1245,6 +1256,11 @@ asmlinkage long sys_socketpair(int family, int type, int protocol,
 	struct socket *sock1, *sock2;
 	int fd1, fd2, err;
 	struct file *newfile1, *newfile2;
+	int fflags;
+
+	type = flags_remap(sock_file_flags_remap,
+			   ARRAY_SIZE(sock_file_flags_remap),
+			   type, &fflags);
 
 	/*
 	 * Obtain the first socket and check if the underlying protocol
@@ -1263,13 +1279,13 @@ asmlinkage long sys_socketpair(int family, int type, int protocol,
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
@@ -1425,7 +1450,7 @@ asmlinkage long sys_accept(int fd, struct sockaddr __user *upeer_sockaddr,
 	 */
 	__module_get(newsock->ops->owner);
 
-	newfd = sock_alloc_fd(&newfile);
+	newfd = sock_alloc_fd(&newfile, 0);
 	if (unlikely(newfd < 0)) {
 		err = newfd;
 		sock_release(newsock);
