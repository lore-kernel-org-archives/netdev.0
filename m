From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH net-2.6 3/4] net: Use standard structures for generic
 socket address structures.
Date: Sun, 20 Jul 2008 14:21:34 +0900 (JST)
Message-ID: <20080720.142134.58233586.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:32821 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751360AbYGTFVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2008 01:21:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use sockaddr_storage{} for generic socket address storage
and ensures proper alignment.
Use sockaddr{} for pointers to omit several casts.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/linux/socket.h |    6 ++--
 include/net/compat.h   |    2 +-
 net/compat.c           |    2 +-
 net/core/iovec.c       |    2 +-
 net/socket.c           |   82 +++++++++++++++++++++++++++---------------------
 5 files changed, 52 insertions(+), 42 deletions(-)

diff --git a/include/linux/socket.h b/include/linux/socket.h
index bd2b30a..950af63 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -306,10 +306,10 @@ extern int csum_partial_copy_fromiovecend(unsigned char *kdata,
 					  int offset, 
 					  unsigned int len, __wsum *csump);
 
-extern int verify_iovec(struct msghdr *m, struct iovec *iov, char *address, int mode);
+extern int verify_iovec(struct msghdr *m, struct iovec *iov, struct sockaddr *address, int mode);
 extern int memcpy_toiovec(struct iovec *v, unsigned char *kdata, int len);
-extern int move_addr_to_user(void *kaddr, int klen, void __user *uaddr, int __user *ulen);
-extern int move_addr_to_kernel(void __user *uaddr, int ulen, void *kaddr);
+extern int move_addr_to_user(struct sockaddr *kaddr, int klen, void __user *uaddr, int __user *ulen);
+extern int move_addr_to_kernel(void __user *uaddr, int ulen, struct sockaddr *kaddr);
 extern int put_cmsg(struct msghdr*, int level, int type, int len, void *data);
 
 #endif
diff --git a/include/net/compat.h b/include/net/compat.h
index 164cb68..5bbf8bf 100644
--- a/include/net/compat.h
+++ b/include/net/compat.h
@@ -32,7 +32,7 @@ extern int compat_sock_get_timestampns(struct sock *, struct timespec __user *);
 #endif /* defined(CONFIG_COMPAT) */
 
 extern int get_compat_msghdr(struct msghdr *, struct compat_msghdr __user *);
-extern int verify_compat_iovec(struct msghdr *, struct iovec *, char *, int);
+extern int verify_compat_iovec(struct msghdr *, struct iovec *, struct sockaddr *, int);
 extern asmlinkage long compat_sys_sendmsg(int,struct compat_msghdr __user *,unsigned);
 extern asmlinkage long compat_sys_recvmsg(int,struct compat_msghdr __user *,unsigned);
 extern asmlinkage long compat_sys_getsockopt(int, int, int, char __user *, int __user *);
diff --git a/net/compat.c b/net/compat.c
index c823f6f..6e1b03b 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -75,7 +75,7 @@ int get_compat_msghdr(struct msghdr *kmsg, struct compat_msghdr __user *umsg)
 
 /* I've named the args so it is easy to tell whose space the pointers are in. */
 int verify_compat_iovec(struct msghdr *kern_msg, struct iovec *kern_iov,
-		   char *kern_address, int mode)
+		   struct sockaddr *kern_address, int mode)
 {
 	int tot_len;
 
diff --git a/net/core/iovec.c b/net/core/iovec.c
index 755c37f..4c9c012 100644
--- a/net/core/iovec.c
+++ b/net/core/iovec.c
@@ -36,7 +36,7 @@
  *	in any case.
  */
 
-int verify_iovec(struct msghdr *m, struct iovec *iov, char *address, int mode)
+int verify_iovec(struct msghdr *m, struct iovec *iov, struct sockaddr *address, int mode)
 {
 	int size, err, ct;
 
diff --git a/net/socket.c b/net/socket.c
index 81fe825..1ba57d8 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -180,9 +180,9 @@ static DEFINE_PER_CPU(int, sockets_in_use) = 0;
  *	invalid addresses -EFAULT is returned. On a success 0 is returned.
  */
 
-int move_addr_to_kernel(void __user *uaddr, int ulen, void *kaddr)
+int move_addr_to_kernel(void __user *uaddr, int ulen, struct sockaddr *kaddr)
 {
-	if (ulen < 0 || ulen > MAX_SOCK_ADDR)
+	if (ulen < 0 || ulen > sizeof(struct sockaddr_storage))
 		return -EINVAL;
 	if (ulen == 0)
 		return 0;
@@ -208,7 +208,7 @@ int move_addr_to_kernel(void __user *uaddr, int ulen, void *kaddr)
  *	specified. Zero is returned for a success.
  */
 
-int move_addr_to_user(void *kaddr, int klen, void __user *uaddr,
+int move_addr_to_user(struct sockaddr *kaddr, int klen, void __user *uaddr,
 		      int __user *ulen)
 {
 	int err;
@@ -219,7 +219,7 @@ int move_addr_to_user(void *kaddr, int klen, void __user *uaddr,
 		return err;
 	if (len > klen)
 		len = klen;
-	if (len < 0 || len > MAX_SOCK_ADDR)
+	if (len < 0 || len > sizeof(struct sockaddr_storage))
 		return -EINVAL;
 	if (len) {
 		if (audit_sockaddr(klen, kaddr))
@@ -1342,20 +1342,20 @@ out_fd:
 asmlinkage long sys_bind(int fd, struct sockaddr __user *umyaddr, int addrlen)
 {
 	struct socket *sock;
-	char address[MAX_SOCK_ADDR];
+	struct sockaddr_storage address;
 	int err, fput_needed;
 
 	sock = sockfd_lookup_light(fd, &err, &fput_needed);
 	if (sock) {
-		err = move_addr_to_kernel(umyaddr, addrlen, address);
+		err = move_addr_to_kernel(umyaddr, addrlen, (struct sockaddr *)&address);
 		if (err >= 0) {
 			err = security_socket_bind(sock,
-						   (struct sockaddr *)address,
+						   (struct sockaddr *)&address,
 						   addrlen);
 			if (!err)
 				err = sock->ops->bind(sock,
 						      (struct sockaddr *)
-						      address, addrlen);
+						      &address, addrlen);
 		}
 		fput_light(sock->file, fput_needed);
 	}
@@ -1407,7 +1407,7 @@ asmlinkage long sys_accept(int fd, struct sockaddr __user *upeer_sockaddr,
 	struct socket *sock, *newsock;
 	struct file *newfile;
 	int err, len, newfd, fput_needed;
-	char address[MAX_SOCK_ADDR];
+	struct sockaddr_storage address;
 
 	sock = sockfd_lookup_light(fd, &err, &fput_needed);
 	if (!sock)
@@ -1446,13 +1446,13 @@ asmlinkage long sys_accept(int fd, struct sockaddr __user *upeer_sockaddr,
 		goto out_fd;
 
 	if (upeer_sockaddr) {
-		if (newsock->ops->getname(newsock, (struct sockaddr *)address,
+		if (newsock->ops->getname(newsock, (struct sockaddr *)&address,
 					  &len, 2) < 0) {
 			err = -ECONNABORTED;
 			goto out_fd;
 		}
-		err = move_addr_to_user(address, len, upeer_sockaddr,
-					upeer_addrlen);
+		err = move_addr_to_user((struct sockaddr *)&address,
+					len, upeer_sockaddr, upeer_addrlen);
 		if (err < 0)
 			goto out_fd;
 	}
@@ -1495,22 +1495,22 @@ asmlinkage long sys_connect(int fd, struct sockaddr __user *uservaddr,
 			    int addrlen)
 {
 	struct socket *sock;
-	char address[MAX_SOCK_ADDR];
+	struct sockaddr_storage address;
 	int err, fput_needed;
 
 	sock = sockfd_lookup_light(fd, &err, &fput_needed);
 	if (!sock)
 		goto out;
-	err = move_addr_to_kernel(uservaddr, addrlen, address);
+	err = move_addr_to_kernel(uservaddr, addrlen, (struct sockaddr *)&address);
 	if (err < 0)
 		goto out_put;
 
 	err =
-	    security_socket_connect(sock, (struct sockaddr *)address, addrlen);
+	    security_socket_connect(sock, (struct sockaddr *)&address, addrlen);
 	if (err)
 		goto out_put;
 
-	err = sock->ops->connect(sock, (struct sockaddr *)address, addrlen,
+	err = sock->ops->connect(sock, (struct sockaddr *)&address, addrlen,
 				 sock->file->f_flags);
 out_put:
 	fput_light(sock->file, fput_needed);
@@ -1527,7 +1527,7 @@ asmlinkage long sys_getsockname(int fd, struct sockaddr __user *usockaddr,
 				int __user *usockaddr_len)
 {
 	struct socket *sock;
-	char address[MAX_SOCK_ADDR];
+	struct sockaddr_storage address;
 	int len, err, fput_needed;
 
 	sock = sockfd_lookup_light(fd, &err, &fput_needed);
@@ -1538,10 +1538,10 @@ asmlinkage long sys_getsockname(int fd, struct sockaddr __user *usockaddr,
 	if (err)
 		goto out_put;
 
-	err = sock->ops->getname(sock, (struct sockaddr *)address, &len, 0);
+	err = sock->ops->getname(sock, (struct sockaddr *)&address, &len, 0);
 	if (err)
 		goto out_put;
-	err = move_addr_to_user(address, len, usockaddr, usockaddr_len);
+	err = move_addr_to_user((struct sockaddr *)&address, len, usockaddr, usockaddr_len);
 
 out_put:
 	fput_light(sock->file, fput_needed);
@@ -1558,7 +1558,7 @@ asmlinkage long sys_getpeername(int fd, struct sockaddr __user *usockaddr,
 				int __user *usockaddr_len)
 {
 	struct socket *sock;
-	char address[MAX_SOCK_ADDR];
+	struct sockaddr_storage address;
 	int len, err, fput_needed;
 
 	sock = sockfd_lookup_light(fd, &err, &fput_needed);
@@ -1570,10 +1570,10 @@ asmlinkage long sys_getpeername(int fd, struct sockaddr __user *usockaddr,
 		}
 
 		err =
-		    sock->ops->getname(sock, (struct sockaddr *)address, &len,
+		    sock->ops->getname(sock, (struct sockaddr *)&address, &len,
 				       1);
 		if (!err)
-			err = move_addr_to_user(address, len, usockaddr,
+			err = move_addr_to_user((struct sockaddr *)&address, len, usockaddr,
 						usockaddr_len);
 		fput_light(sock->file, fput_needed);
 	}
@@ -1591,7 +1591,7 @@ asmlinkage long sys_sendto(int fd, void __user *buff, size_t len,
 			   int addr_len)
 {
 	struct socket *sock;
-	char address[MAX_SOCK_ADDR];
+	struct sockaddr_storage address;
 	int err;
 	struct msghdr msg;
 	struct iovec iov;
@@ -1610,10 +1610,10 @@ asmlinkage long sys_sendto(int fd, void __user *buff, size_t len,
 	msg.msg_controllen = 0;
 	msg.msg_namelen = 0;
 	if (addr) {
-		err = move_addr_to_kernel(addr, addr_len, address);
+		err = move_addr_to_kernel(addr, addr_len, (struct sockaddr *)&address);
 		if (err < 0)
 			goto out_put;
-		msg.msg_name = address;
+		msg.msg_name = (struct sockaddr *)&address;
 		msg.msg_namelen = addr_len;
 	}
 	if (sock->file->f_flags & O_NONBLOCK)
@@ -1649,7 +1649,7 @@ asmlinkage long sys_recvfrom(int fd, void __user *ubuf, size_t size,
 	struct socket *sock;
 	struct iovec iov;
 	struct msghdr msg;
-	char address[MAX_SOCK_ADDR];
+	struct sockaddr_storage address;
 	int err, err2;
 	int fput_needed;
 
@@ -1663,14 +1663,15 @@ asmlinkage long sys_recvfrom(int fd, void __user *ubuf, size_t size,
 	msg.msg_iov = &iov;
 	iov.iov_len = size;
 	iov.iov_base = ubuf;
-	msg.msg_name = address;
-	msg.msg_namelen = MAX_SOCK_ADDR;
+	msg.msg_name = (struct sockaddr *)&address;
+	msg.msg_namelen = sizeof(address);
 	if (sock->file->f_flags & O_NONBLOCK)
 		flags |= MSG_DONTWAIT;
 	err = sock_recvmsg(sock, &msg, size, flags);
 
 	if (err >= 0 && addr != NULL) {
-		err2 = move_addr_to_user(address, msg.msg_namelen, addr, addr_len);
+		err2 = move_addr_to_user((struct sockaddr *)&address,
+					 msg.msg_namelen, addr, addr_len);
 		if (err2 < 0)
 			err = err2;
 	}
@@ -1790,7 +1791,7 @@ asmlinkage long sys_sendmsg(int fd, struct msghdr __user *msg, unsigned flags)
 	struct compat_msghdr __user *msg_compat =
 	    (struct compat_msghdr __user *)msg;
 	struct socket *sock;
-	char address[MAX_SOCK_ADDR];
+	struct sockaddr_storage address;
 	struct iovec iovstack[UIO_FASTIOV], *iov = iovstack;
 	unsigned char ctl[sizeof(struct cmsghdr) + 20]
 	    __attribute__ ((aligned(sizeof(__kernel_size_t))));
@@ -1828,9 +1829,13 @@ asmlinkage long sys_sendmsg(int fd, struct msghdr __user *msg, unsigned flags)
 
 	/* This will also move the address data into kernel space */
 	if (MSG_CMSG_COMPAT & flags) {
-		err = verify_compat_iovec(&msg_sys, iov, address, VERIFY_READ);
+		err = verify_compat_iovec(&msg_sys, iov,
+					  (struct sockaddr *)&address,
+					  VERIFY_READ);
 	} else
-		err = verify_iovec(&msg_sys, iov, address, VERIFY_READ);
+		err = verify_iovec(&msg_sys, iov,
+				   (struct sockaddr *)&address,
+				   VERIFY_READ);
 	if (err < 0)
 		goto out_freeiov;
 	total_len = err;
@@ -1901,7 +1906,7 @@ asmlinkage long sys_recvmsg(int fd, struct msghdr __user *msg,
 	int fput_needed;
 
 	/* kernel mode address */
-	char addr[MAX_SOCK_ADDR];
+	struct sockaddr_storage addr;
 
 	/* user mode address pointers */
 	struct sockaddr __user *uaddr;
@@ -1939,9 +1944,13 @@ asmlinkage long sys_recvmsg(int fd, struct msghdr __user *msg,
 	uaddr = (__force void __user *)msg_sys.msg_name;
 	uaddr_len = COMPAT_NAMELEN(msg);
 	if (MSG_CMSG_COMPAT & flags) {
-		err = verify_compat_iovec(&msg_sys, iov, addr, VERIFY_WRITE);
+		err = verify_compat_iovec(&msg_sys, iov,
+					  (struct sockaddr *)&addr,
+					  VERIFY_WRITE);
 	} else
-		err = verify_iovec(&msg_sys, iov, addr, VERIFY_WRITE);
+		err = verify_iovec(&msg_sys, iov,
+				   (struct sockaddr *)&addr,
+				   VERIFY_WRITE);
 	if (err < 0)
 		goto out_freeiov;
 	total_len = err;
@@ -1957,7 +1966,8 @@ asmlinkage long sys_recvmsg(int fd, struct msghdr __user *msg,
 	len = err;
 
 	if (uaddr != NULL) {
-		err = move_addr_to_user(addr, msg_sys.msg_namelen, uaddr,
+		err = move_addr_to_user((struct sockaddr *)&addr,
+					msg_sys.msg_namelen, uaddr,
 					uaddr_len);
 		if (err < 0)
 			goto out_freeiov;
-- 
1.4.4.4

