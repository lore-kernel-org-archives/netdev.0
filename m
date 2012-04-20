From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: change big iov allocations
Date: Fri, 20 Apr 2012 20:04:01 +0200
Message-ID: <1334945041.2395.243.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Mike Waychison <mikew@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:42513 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755891Ab2DTSEJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 14:04:09 -0400
Received: by wejx9 with SMTP id x9so6236404wej.19
        for <netdev@vger.kernel.org>; Fri, 20 Apr 2012 11:04:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

iov of more than 8 entries are allocated in sendmsg()/recvmsg() through
sock_kmalloc()

As these allocations are temporary only and small enough, it makes sense
to use plain kmalloc() and avoid sk_omem_alloc atomic overhead.

Slightly changed fast path to be even faster.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Mike Waychison <mikew@google.com>
---
 net/socket.c |   37 ++++++++++++++++---------------------
 1 file changed, 16 insertions(+), 21 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index d6c1af9..4240d6e 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1908,7 +1908,7 @@ static int __sys_sendmsg(struct socket *sock, struct msghdr __user *msg,
 	    __attribute__ ((aligned(sizeof(__kernel_size_t))));
 	/* 20 is size of ipv6_pktinfo */
 	unsigned char *ctl_buf = ctl;
-	int err, ctl_len, iov_size, total_len;
+	int err, ctl_len, total_len;
 
 	err = -EFAULT;
 	if (MSG_CMSG_COMPAT & flags) {
@@ -1917,16 +1917,13 @@ static int __sys_sendmsg(struct socket *sock, struct msghdr __user *msg,
 	} else if (copy_from_user(msg_sys, msg, sizeof(struct msghdr)))
 		return -EFAULT;
 
-	/* do not move before msg_sys is valid */
-	err = -EMSGSIZE;
-	if (msg_sys->msg_iovlen > UIO_MAXIOV)
-		goto out;
-
-	/* Check whether to allocate the iovec area */
-	err = -ENOMEM;
-	iov_size = msg_sys->msg_iovlen * sizeof(struct iovec);
 	if (msg_sys->msg_iovlen > UIO_FASTIOV) {
-		iov = sock_kmalloc(sock->sk, iov_size, GFP_KERNEL);
+		err = -EMSGSIZE;
+		if (msg_sys->msg_iovlen > UIO_MAXIOV)
+			goto out;
+		err = -ENOMEM;
+		iov = kmalloc(msg_sys->msg_iovlen * sizeof(struct iovec),
+			      GFP_KERNEL);
 		if (!iov)
 			goto out;
 	}
@@ -2005,7 +2002,7 @@ out_freectl:
 		sock_kfree_s(sock->sk, ctl_buf, ctl_len);
 out_freeiov:
 	if (iov != iovstack)
-		sock_kfree_s(sock->sk, iov, iov_size);
+		kfree(iov);
 out:
 	return err;
 }
@@ -2103,7 +2100,7 @@ static int __sys_recvmsg(struct socket *sock, struct msghdr __user *msg,
 	struct iovec iovstack[UIO_FASTIOV];
 	struct iovec *iov = iovstack;
 	unsigned long cmsg_ptr;
-	int err, iov_size, total_len, len;
+	int err, total_len, len;
 
 	/* kernel mode address */
 	struct sockaddr_storage addr;
@@ -2118,15 +2115,13 @@ static int __sys_recvmsg(struct socket *sock, struct msghdr __user *msg,
 	} else if (copy_from_user(msg_sys, msg, sizeof(struct msghdr)))
 		return -EFAULT;
 
-	err = -EMSGSIZE;
-	if (msg_sys->msg_iovlen > UIO_MAXIOV)
-		goto out;
-
-	/* Check whether to allocate the iovec area */
-	err = -ENOMEM;
-	iov_size = msg_sys->msg_iovlen * sizeof(struct iovec);
 	if (msg_sys->msg_iovlen > UIO_FASTIOV) {
-		iov = sock_kmalloc(sock->sk, iov_size, GFP_KERNEL);
+		err = -EMSGSIZE;
+		if (msg_sys->msg_iovlen > UIO_MAXIOV)
+			goto out;
+		err = -ENOMEM;
+		iov = kmalloc(msg_sys->msg_iovlen * sizeof(struct iovec),
+			      GFP_KERNEL);
 		if (!iov)
 			goto out;
 	}
@@ -2180,7 +2175,7 @@ static int __sys_recvmsg(struct socket *sock, struct msghdr __user *msg,
 
 out_freeiov:
 	if (iov != iovstack)
-		sock_kfree_s(sock->sk, iov, iov_size);
+		kfree(iov);
 out:
 	return err;
 }
