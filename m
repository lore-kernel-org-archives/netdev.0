From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 1/2] in-kernel sockets API - ver2
Date: Mon, 19 Jun 2006 12:15:03 -0700
Message-ID: <1150744504.2816.24.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:37790 "EHLO e3.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S932569AbWFSTQD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2006 15:16:03 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5JJFwfM022663
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Mon, 19 Jun 2006 15:15:58 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5JJFuvd289520
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 19 Jun 2006 15:15:58 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5JJFuZu003868
	for <netdev@vger.kernel.org>; Mon, 19 Jun 2006 15:15:56 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch implements wrapper functions that provide a convenient way to
access the sockets API for in-kernel users like sunrpc, cifs & ocsf2 etc
and any future users.
	
The only change from the version i submitted last week is the renaming of
kernel_ioctl to kernel_sock_ioctl.

I left the exports to use EXPORT_SYMBOL() to match with the existing
interfaces sock_create_kern(), kernel_sendmsg(), kernel_recvmsg etc.

Thanks
Sridhar

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
Acked-by: James Morris <jmorris@namei.org>

diff --git a/include/linux/net.h b/include/linux/net.h
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -208,6 +208,25 @@ extern int   	     kernel_recvmsg(struct
 				    struct kvec *vec, size_t num,
 				    size_t len, int flags);
 
+extern int kernel_bind(struct socket *sock, struct sockaddr *addr,
+		       int addrlen);
+extern int kernel_listen(struct socket *sock, int backlog);
+extern int kernel_accept(struct socket *sock, struct socket **newsock,
+			 int flags);
+extern int kernel_connect(struct socket *sock, struct sockaddr *addr,
+			  int addrlen, int flags);
+extern int kernel_getsockname(struct socket *sock, struct sockaddr *addr,
+			      int *addrlen);
+extern int kernel_getpeername(struct socket *sock, struct sockaddr *addr,
+			      int *addrlen);
+extern int kernel_getsockopt(struct socket *sock, int level, int optname,
+			     char *optval, int *optlen);
+extern int kernel_setsockopt(struct socket *sock, int level, int optname,
+			     char *optval, int optlen);
+extern int kernel_sendpage(struct socket *sock, struct page *page, int offset,
+			   size_t size, int flags);
+extern int kernel_sock_ioctl(struct socket *sock, int cmd, unsigned long arg);
+
 #ifndef CONFIG_SMP
 #define SOCKOPS_WRAPPED(name) name
 #define SOCKOPS_WRAP(name, fam)
diff --git a/net/socket.c b/net/socket.c
--- a/net/socket.c
+++ b/net/socket.c
@@ -2160,6 +2160,109 @@ static long compat_sock_ioctl(struct fil
 }
 #endif
 
+int kernel_bind(struct socket *sock, struct sockaddr *addr, int addrlen)
+{
+	return sock->ops->bind(sock, addr, addrlen);
+}
+
+int kernel_listen(struct socket *sock, int backlog)
+{
+	return sock->ops->listen(sock, backlog);
+}
+
+int kernel_accept(struct socket *sock, struct socket **newsock, int flags)
+{
+	struct sock *sk = sock->sk;
+	int err;
+
+	err = sock_create_lite(sk->sk_family, sk->sk_type, sk->sk_protocol,
+			       newsock);
+	if (err < 0)
+		goto done;
+
+	err = sock->ops->accept(sock, *newsock, flags);
+	if (err < 0) {
+		sock_release(*newsock);
+		goto done;
+	}
+
+	(*newsock)->ops = sock->ops;
+
+done:
+	return err;
+}
+
+int kernel_connect(struct socket *sock, struct sockaddr *addr, int addrlen,
+                   int flags)
+{
+	return sock->ops->connect(sock, addr, addrlen, flags);
+}
+
+int kernel_getsockname(struct socket *sock, struct sockaddr *addr,
+			 int *addrlen)
+{
+	return sock->ops->getname(sock, addr, addrlen, 0);
+}
+
+int kernel_getpeername(struct socket *sock, struct sockaddr *addr,
+			 int *addrlen)
+{
+	return sock->ops->getname(sock, addr, addrlen, 1);
+}
+
+int kernel_getsockopt(struct socket *sock, int level, int optname,
+			char *optval, int *optlen)
+{
+	mm_segment_t oldfs = get_fs();
+	int err;
+
+	set_fs(KERNEL_DS);
+	if (level == SOL_SOCKET)
+		err = sock_getsockopt(sock, level, optname, optval, optlen);
+	else
+		err = sock->ops->getsockopt(sock, level, optname, optval,
+					    optlen);
+	set_fs(oldfs);
+	return err;
+}
+
+int kernel_setsockopt(struct socket *sock, int level, int optname,
+			char *optval, int optlen)
+{
+	mm_segment_t oldfs = get_fs();
+	int err;
+
+	set_fs(KERNEL_DS);
+	if (level == SOL_SOCKET)
+		err = sock_setsockopt(sock, level, optname, optval, optlen);
+	else
+		err = sock->ops->setsockopt(sock, level, optname, optval,
+					    optlen);
+	set_fs(oldfs);
+	return err;
+}
+
+int kernel_sendpage(struct socket *sock, struct page *page, int offset,
+		    size_t size, int flags)
+{
+	if (sock->ops->sendpage)
+		return sock->ops->sendpage(sock, page, offset, size, flags);
+
+	return sock_no_sendpage(sock, page, offset, size, flags);
+}
+
+int kernel_sock_ioctl(struct socket *sock, int cmd, unsigned long arg)
+{
+	mm_segment_t oldfs = get_fs();
+	int err;
+
+	set_fs(KERNEL_DS);
+	err = sock->ops->ioctl(sock, cmd, arg);
+	set_fs(oldfs);
+
+	return err;
+}
+
 /* ABI emulation layers need these two */
 EXPORT_SYMBOL(move_addr_to_kernel);
 EXPORT_SYMBOL(move_addr_to_user);
@@ -2176,3 +2279,13 @@ EXPORT_SYMBOL(sock_wake_async);
 EXPORT_SYMBOL(sockfd_lookup);
 EXPORT_SYMBOL(kernel_sendmsg);
 EXPORT_SYMBOL(kernel_recvmsg);
+EXPORT_SYMBOL(kernel_bind);
+EXPORT_SYMBOL(kernel_listen);
+EXPORT_SYMBOL(kernel_accept);
+EXPORT_SYMBOL(kernel_connect);
+EXPORT_SYMBOL(kernel_getsockname);
+EXPORT_SYMBOL(kernel_getpeername);
+EXPORT_SYMBOL(kernel_getsockopt);
+EXPORT_SYMBOL(kernel_setsockopt);
+EXPORT_SYMBOL(kernel_sendpage);
+EXPORT_SYMBOL(kernel_sock_ioctl);




