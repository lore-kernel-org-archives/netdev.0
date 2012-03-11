From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH] net: get rid of some pointless casts to sockaddr
Date: Sun, 11 Mar 2012 15:51:50 -0700
Message-ID: <1331506310-16613-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:38588 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753602Ab2CKW5x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Mar 2012 18:57:53 -0400
Received: by dajr28 with SMTP id r28so4267560daj.19
        for <netdev@vger.kernel.org>; Sun, 11 Mar 2012 15:57:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =C5=BBenczykowski <maze@google.com>

The following 4 functions:
  move_addr_to_kernel
  move_addr_to_user
  verify_iovec
  verify_compat_iovec
are always effectively called with a sockaddr_storage.

Make this explicit by changing their signature.

This removes a large number of casts from sockaddr_storage to sockaddr.

Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
---
 include/linux/socket.h |    4 ++--
 include/net/compat.h   |    2 +-
 net/compat.c           |    2 +-
 net/core/iovec.c       |    2 +-
 net/socket.c           |   36 ++++++++++++++----------------------
 5 files changed, 19 insertions(+), 27 deletions(-)

diff --git a/include/linux/socket.h b/include/linux/socket.h
index d0e77f607a79..da2d3e2543f3 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -326,11 +326,11 @@ extern int csum_partial_copy_fromiovecend(unsigne=
d char *kdata,
 					  int offset,=20
 					  unsigned int len, __wsum *csump);
=20
-extern int verify_iovec(struct msghdr *m, struct iovec *iov, struct so=
ckaddr *address, int mode);
+extern int verify_iovec(struct msghdr *m, struct iovec *iov, struct so=
ckaddr_storage *address, int mode);
 extern int memcpy_toiovec(struct iovec *v, unsigned char *kdata, int l=
en);
 extern int memcpy_toiovecend(const struct iovec *v, unsigned char *kda=
ta,
 			     int offset, int len);
-extern int move_addr_to_kernel(void __user *uaddr, int ulen, struct so=
ckaddr *kaddr);
+extern int move_addr_to_kernel(void __user *uaddr, int ulen, struct so=
ckaddr_storage *kaddr);
 extern int put_cmsg(struct msghdr*, int level, int type, int len, void=
 *data);
=20
 struct timespec;
diff --git a/include/net/compat.h b/include/net/compat.h
index 9ee75edcc295..a974ae92d182 100644
--- a/include/net/compat.h
+++ b/include/net/compat.h
@@ -41,7 +41,7 @@ extern int compat_sock_get_timestampns(struct sock *,=
 struct timespec __user *);
 #endif /* defined(CONFIG_COMPAT) */
=20
 extern int get_compat_msghdr(struct msghdr *, struct compat_msghdr __u=
ser *);
-extern int verify_compat_iovec(struct msghdr *, struct iovec *, struct=
 sockaddr *, int);
+extern int verify_compat_iovec(struct msghdr *, struct iovec *, struct=
 sockaddr_storage *, int);
 extern asmlinkage long compat_sys_sendmsg(int,struct compat_msghdr __u=
ser *,unsigned);
 extern asmlinkage long compat_sys_sendmmsg(int, struct compat_mmsghdr =
__user *,
 					   unsigned, unsigned);
diff --git a/net/compat.c b/net/compat.c
index 6def90e0a112..64b4515a64e6 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -79,7 +79,7 @@ int get_compat_msghdr(struct msghdr *kmsg, struct com=
pat_msghdr __user *umsg)
=20
 /* I've named the args so it is easy to tell whose space the pointers =
are in. */
 int verify_compat_iovec(struct msghdr *kern_msg, struct iovec *kern_io=
v,
-		   struct sockaddr *kern_address, int mode)
+		   struct sockaddr_storage *kern_address, int mode)
 {
 	int tot_len;
=20
diff --git a/net/core/iovec.c b/net/core/iovec.c
index c40f27e7d208..7e7aeb01de45 100644
--- a/net/core/iovec.c
+++ b/net/core/iovec.c
@@ -35,7 +35,7 @@
  *	in any case.
  */
=20
-int verify_iovec(struct msghdr *m, struct iovec *iov, struct sockaddr =
*address, int mode)
+int verify_iovec(struct msghdr *m, struct iovec *iov, struct sockaddr_=
storage *address, int mode)
 {
 	int size, ct, err;
=20
diff --git a/net/socket.c b/net/socket.c
index 28a96af484b4..12a48d846223 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -181,7 +181,7 @@ static DEFINE_PER_CPU(int, sockets_in_use);
  *	invalid addresses -EFAULT is returned. On a success 0 is returned.
  */
=20
-int move_addr_to_kernel(void __user *uaddr, int ulen, struct sockaddr =
*kaddr)
+int move_addr_to_kernel(void __user *uaddr, int ulen, struct sockaddr_=
storage *kaddr)
 {
 	if (ulen < 0 || ulen > sizeof(struct sockaddr_storage))
 		return -EINVAL;
@@ -209,7 +209,7 @@ int move_addr_to_kernel(void __user *uaddr, int ule=
n, struct sockaddr *kaddr)
  *	specified. Zero is returned for a success.
  */
=20
-static int move_addr_to_user(struct sockaddr *kaddr, int klen,
+static int move_addr_to_user(struct sockaddr_storage *kaddr, int klen,
 			     void __user *uaddr, int __user *ulen)
 {
 	int err;
@@ -1449,7 +1449,7 @@ SYSCALL_DEFINE3(bind, int, fd, struct sockaddr __=
user *, umyaddr, int, addrlen)
=20
 	sock =3D sockfd_lookup_light(fd, &err, &fput_needed);
 	if (sock) {
-		err =3D move_addr_to_kernel(umyaddr, addrlen, (struct sockaddr *)&ad=
dress);
+		err =3D move_addr_to_kernel(umyaddr, addrlen, &address);
 		if (err >=3D 0) {
 			err =3D security_socket_bind(sock,
 						   (struct sockaddr *)&address,
@@ -1556,7 +1556,7 @@ SYSCALL_DEFINE4(accept4, int, fd, struct sockaddr=
 __user *, upeer_sockaddr,
 			err =3D -ECONNABORTED;
 			goto out_fd;
 		}
-		err =3D move_addr_to_user((struct sockaddr *)&address,
+		err =3D move_addr_to_user(&address,
 					len, upeer_sockaddr, upeer_addrlen);
 		if (err < 0)
 			goto out_fd;
@@ -1605,7 +1605,7 @@ SYSCALL_DEFINE3(connect, int, fd, struct sockaddr=
 __user *, uservaddr,
 	sock =3D sockfd_lookup_light(fd, &err, &fput_needed);
 	if (!sock)
 		goto out;
-	err =3D move_addr_to_kernel(uservaddr, addrlen, (struct sockaddr *)&a=
ddress);
+	err =3D move_addr_to_kernel(uservaddr, addrlen, &address);
 	if (err < 0)
 		goto out_put;
=20
@@ -1645,7 +1645,7 @@ SYSCALL_DEFINE3(getsockname, int, fd, struct sock=
addr __user *, usockaddr,
 	err =3D sock->ops->getname(sock, (struct sockaddr *)&address, &len, 0=
);
 	if (err)
 		goto out_put;
-	err =3D move_addr_to_user((struct sockaddr *)&address, len, usockaddr=
, usockaddr_len);
+	err =3D move_addr_to_user(&address, len, usockaddr, usockaddr_len);
=20
 out_put:
 	fput_light(sock->file, fput_needed);
@@ -1677,7 +1677,7 @@ SYSCALL_DEFINE3(getpeername, int, fd, struct sock=
addr __user *, usockaddr,
 		    sock->ops->getname(sock, (struct sockaddr *)&address, &len,
 				       1);
 		if (!err)
-			err =3D move_addr_to_user((struct sockaddr *)&address, len, usockad=
dr,
+			err =3D move_addr_to_user(&address, len, usockaddr,
 						usockaddr_len);
 		fput_light(sock->file, fput_needed);
 	}
@@ -1716,7 +1716,7 @@ SYSCALL_DEFINE6(sendto, int, fd, void __user *, b=
uff, size_t, len,
 	msg.msg_controllen =3D 0;
 	msg.msg_namelen =3D 0;
 	if (addr) {
-		err =3D move_addr_to_kernel(addr, addr_len, (struct sockaddr *)&addr=
ess);
+		err =3D move_addr_to_kernel(addr, addr_len, &address);
 		if (err < 0)
 			goto out_put;
 		msg.msg_name =3D (struct sockaddr *)&address;
@@ -1779,7 +1779,7 @@ SYSCALL_DEFINE6(recvfrom, int, fd, void __user *,=
 ubuf, size_t, size,
 	err =3D sock_recvmsg(sock, &msg, size, flags);
=20
 	if (err >=3D 0 && addr !=3D NULL) {
-		err2 =3D move_addr_to_user((struct sockaddr *)&address,
+		err2 =3D move_addr_to_user(&address,
 					 msg.msg_namelen, addr, addr_len);
 		if (err2 < 0)
 			err =3D err2;
@@ -1933,13 +1933,9 @@ static int __sys_sendmsg(struct socket *sock, st=
ruct msghdr __user *msg,
=20
 	/* This will also move the address data into kernel space */
 	if (MSG_CMSG_COMPAT & flags) {
-		err =3D verify_compat_iovec(msg_sys, iov,
-					  (struct sockaddr *)&address,
-					  VERIFY_READ);
+		err =3D verify_compat_iovec(msg_sys, iov, &address, VERIFY_READ);
 	} else
-		err =3D verify_iovec(msg_sys, iov,
-				   (struct sockaddr *)&address,
-				   VERIFY_READ);
+		err =3D verify_iovec(msg_sys, iov, &address, VERIFY_READ);
 	if (err < 0)
 		goto out_freeiov;
 	total_len =3D err;
@@ -2143,13 +2139,9 @@ static int __sys_recvmsg(struct socket *sock, st=
ruct msghdr __user *msg,
 	uaddr =3D (__force void __user *)msg_sys->msg_name;
 	uaddr_len =3D COMPAT_NAMELEN(msg);
 	if (MSG_CMSG_COMPAT & flags) {
-		err =3D verify_compat_iovec(msg_sys, iov,
-					  (struct sockaddr *)&addr,
-					  VERIFY_WRITE);
+		err =3D verify_compat_iovec(msg_sys, iov, &addr, VERIFY_WRITE);
 	} else
-		err =3D verify_iovec(msg_sys, iov,
-				   (struct sockaddr *)&addr,
-				   VERIFY_WRITE);
+		err =3D verify_iovec(msg_sys, iov, &addr, VERIFY_WRITE);
 	if (err < 0)
 		goto out_freeiov;
 	total_len =3D err;
@@ -2166,7 +2158,7 @@ static int __sys_recvmsg(struct socket *sock, str=
uct msghdr __user *msg,
 	len =3D err;
=20
 	if (uaddr !=3D NULL) {
-		err =3D move_addr_to_user((struct sockaddr *)&addr,
+		err =3D move_addr_to_user(&addr,
 					msg_sys->msg_namelen, uaddr,
 					uaddr_len);
 		if (err < 0)
--=20
1.7.7.3
