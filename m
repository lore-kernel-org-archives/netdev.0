From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/17)  protocol sendmsg/revmsg prototype
Date: Fri, 9 Jan 2004 13:26:58 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040109132658.01aa28dd@linux.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

When sendmsg (or recvmsg) system call is processed, the total size of
the message is calculated as unsigned (size_t), but then passed through as integer in the protocol switch table. This leads to possible problems
when protocols only check size > pmtu and size could potentially be negative.

The protocols work around this (mostly) today by checking for
less than zero or recasting, but the right thing is to change
protocol switch to pass it through as size_t. This doesn't change the
user ABI for sendmsg/recvmsg.

The first patch changes the prototype, and causes all the protocols to
generate warnings that are cleared up in the next sixteen.

This was found by Chris Wright who raised it a potential DOS attack point.

diff -Nru a/include/linux/net.h b/include/linux/net.h
--- a/include/linux/net.h	Mon Dec  8 16:19:31 2003
+++ b/include/linux/net.h	Mon Dec  8 16:19:31 2003
@@ -120,9 +120,9 @@
 	int		(*getsockopt)(struct socket *sock, int level,
 				      int optname, char __user *optval, int __user *optlen);
 	int		(*sendmsg)   (struct kiocb *iocb, struct socket *sock,
-				      struct msghdr *m, int total_len);
+				      struct msghdr *m, size_t total_len);
 	int		(*recvmsg)   (struct kiocb *iocb, struct socket *sock,
-				      struct msghdr *m, int total_len,
+				      struct msghdr *m, size_t total_len,
 				      int flags);
 	int		(*mmap)	     (struct file *file, struct socket *sock,
 				      struct vm_area_struct * vma);
@@ -151,13 +151,13 @@
 				 struct socket **res);
 extern void	     sock_release(struct socket *sock);
 extern int   	     sock_sendmsg(struct socket *sock, struct msghdr *msg,
-				  int len);
+				  size_t len);
 extern int	     sock_recvmsg(struct socket *sock, struct msghdr *msg,
-				  int size, int flags);
+				  size_t size, int flags);
 extern int	     sock_readv_writev(int type, struct inode *inode,
 				       struct file *file,
 				       const struct iovec *iov, long count,
-				       long size);
+				       size_t size);
 extern int 	     sock_map_fd(struct socket *sock);
 extern struct socket *sockfd_lookup(int fd, int *err);
 #define		     sockfd_put(sock) fput(sock->file)
@@ -216,9 +216,9 @@
 			 char *optval, int optlen), (sock, level, optname, optval, optlen)) \
 SOCKCALL_WRAP(name, getsockopt, (struct socket *sock, int level, int optname, \
 			 char *optval, int *optlen), (sock, level, optname, optval, optlen)) \
-SOCKCALL_WRAP(name, sendmsg, (struct kiocb *iocb, struct socket *sock, struct msghdr *m, int len), \
+SOCKCALL_WRAP(name, sendmsg, (struct kiocb *iocb, struct socket *sock, struct msghdr *m, size_t len), \
 	      (iocb, sock, m, len)) \
-SOCKCALL_WRAP(name, recvmsg, (struct kiocb *iocb, struct socket *sock, struct msghdr *m, int len, int flags), \
+SOCKCALL_WRAP(name, recvmsg, (struct kiocb *iocb, struct socket *sock, struct msghdr *m, size_t len, int flags), \
 	      (iocb, sock, m, len, flags)) \
 SOCKCALL_WRAP(name, mmap, (struct file *file, struct socket *sock, struct vm_area_struct *vma), \
 	      (file, sock, vma)) \
diff -Nru a/include/net/sock.h b/include/net/sock.h
--- a/include/net/sock.h	Mon Dec  8 16:19:31 2003
+++ b/include/net/sock.h	Mon Dec  8 16:19:31 2003
@@ -418,10 +418,10 @@
 					int optname, char *optval, 
 					int *option);  	 
 	int			(*sendmsg)(struct kiocb *iocb, struct sock *sk,
-					   struct msghdr *msg, int len);
+					   struct msghdr *msg, size_t len);
 	int			(*recvmsg)(struct kiocb *iocb, struct sock *sk,
 					   struct msghdr *msg,
-					int len, int noblock, int flags, 
+					size_t len, int noblock, int flags, 
 					int *addr_len);
 	int			(*sendpage)(struct sock *sk, struct page *page,
 					int offset, size_t size, int flags);
@@ -624,9 +624,9 @@
 extern int			sock_no_setsockopt(struct socket *, int, int,
 						   char *, int);
 extern int                      sock_no_sendmsg(struct kiocb *, struct socket *,
-						struct msghdr *, int);
+						struct msghdr *, size_t);
 extern int                      sock_no_recvmsg(struct kiocb *, struct socket *,
-						struct msghdr *, int, int);
+						struct msghdr *, size_t, int);
 extern int			sock_no_mmap(struct file *file,
 					     struct socket *sock,
 					     struct vm_area_struct *vma);
diff -Nru a/net/core/sock.c b/net/core/sock.c
--- a/net/core/sock.c	Mon Dec  8 16:19:31 2003
+++ b/net/core/sock.c	Mon Dec  8 16:19:31 2003
@@ -966,13 +966,13 @@
 }
 
 int sock_no_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
-		    int flags)
+		    size_t len)
 {
 	return -EOPNOTSUPP;
 }
 
 int sock_no_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
-		    int len, int flags)
+		    size_t len, int flags)
 {
 	return -EOPNOTSUPP;
 }
diff -Nru a/net/socket.c b/net/socket.c
--- a/net/socket.c	Mon Dec  8 16:19:31 2003
+++ b/net/socket.c	Mon Dec  8 16:19:31 2003
@@ -523,7 +523,8 @@
 	sock->file=NULL;
 }
 
-static inline int __sock_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg, int size)
+static inline int __sock_sendmsg(struct kiocb *iocb, struct socket *sock, 
+				 struct msghdr *msg, size_t size)
 {
 	struct sock_iocb *si = kiocb_to_siocb(iocb);
 	int err;
@@ -540,7 +541,7 @@
 	return sock->ops->sendmsg(iocb, sock, msg, size);
 }
 
-int sock_sendmsg(struct socket *sock, struct msghdr *msg, int size)
+int sock_sendmsg(struct socket *sock, struct msghdr *msg, size_t size)
 {
 	struct kiocb iocb;
 	int ret;
@@ -553,7 +554,8 @@
 }
 
 
-static inline int __sock_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg, int size, int flags)
+static inline int __sock_recvmsg(struct kiocb *iocb, struct socket *sock, 
+				 struct msghdr *msg, size_t size, int flags)
 {
 	int err;
 	struct sock_iocb *si = kiocb_to_siocb(iocb);
@@ -571,7 +573,8 @@
 	return sock->ops->recvmsg(iocb, sock, msg, size, flags);
 }
 
-int sock_recvmsg(struct socket *sock, struct msghdr *msg, int size, int flags)
+int sock_recvmsg(struct socket *sock, struct msghdr *msg, 
+		 size_t size, int flags)
 {
 	struct kiocb iocb;
 	int ret;
@@ -668,7 +671,7 @@
 }
 
 int sock_readv_writev(int type, struct inode * inode, struct file * file,
-		      const struct iovec * iov, long count, long size)
+		      const struct iovec * iov, long count, size_t size)
 {
 	struct msghdr msg;
 	struct socket *sock;
