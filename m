From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 6/7] appletalk: remove the BKL
Date: Wed,  2 Mar 2011 00:13:10 +0100
Message-ID: <1299021191-17961-7-git-send-email-arnd@arndb.de>
References: <1299021191-17961-1-git-send-email-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1299021191-17961-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This changes appletalk to use lock_sock instead of
lock_kernel for serialization. I tried to make sure
that we don't hold the socket lock during sleeping
functions, but I did not try to prove whether the
locks are necessary in the first place.

Compile-tested only.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Cc: David Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---
 drivers/net/appletalk/Kconfig |    1 -
 net/appletalk/ddp.c           |   40 ++++++++++++++++------------------------
 2 files changed, 16 insertions(+), 25 deletions(-)

diff --git a/drivers/net/appletalk/Kconfig b/drivers/net/appletalk/Kconfig
index 0b376a9..f5a8916 100644
--- a/drivers/net/appletalk/Kconfig
+++ b/drivers/net/appletalk/Kconfig
@@ -3,7 +3,6 @@
 #
 config ATALK
 	tristate "Appletalk protocol support"
-	depends on BKL # waiting to be removed from net/appletalk/ddp.c
 	select LLC
 	---help---
 	  AppleTalk is the protocol that Apple computers can use to communicate
diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index c410b93..3d4f4b0 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -54,7 +54,6 @@
 #include <linux/capability.h>
 #include <linux/module.h>
 #include <linux/if_arp.h>
-#include <linux/smp_lock.h>
 #include <linux/termios.h>	/* For TIOCOUTQ/INQ */
 #include <linux/compat.h>
 #include <linux/slab.h>
@@ -1052,13 +1051,13 @@ static int atalk_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
 
-	lock_kernel();
+	lock_sock(sk);
 	if (sk) {
 		sock_orphan(sk);
 		sock->sk = NULL;
 		atalk_destroy_socket(sk);
 	}
-	unlock_kernel();
+	release_sock(sk);
 	return 0;
 }
 
@@ -1143,7 +1142,7 @@ static int atalk_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	if (addr->sat_family != AF_APPLETALK)
 		return -EAFNOSUPPORT;
 
-	lock_kernel();
+	lock_sock(sk);
 	if (addr->sat_addr.s_net == htons(ATADDR_ANYNET)) {
 		struct atalk_addr *ap = atalk_find_primary();
 
@@ -1179,7 +1178,7 @@ static int atalk_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	sock_reset_flag(sk, SOCK_ZAPPED);
 	err = 0;
 out:
-	unlock_kernel();
+	release_sock(sk);
 	return err;
 }
 
@@ -1215,7 +1214,7 @@ static int atalk_connect(struct socket *sock, struct sockaddr *uaddr,
 #endif
 	}
 
-	lock_kernel();
+	lock_sock(sk);
 	err = -EBUSY;
 	if (sock_flag(sk, SOCK_ZAPPED))
 		if (atalk_autobind(sk) < 0)
@@ -1233,7 +1232,7 @@ static int atalk_connect(struct socket *sock, struct sockaddr *uaddr,
 	sk->sk_state = TCP_ESTABLISHED;
 	err = 0;
 out:
-	unlock_kernel();
+	release_sock(sk);
 	return err;
 }
 
@@ -1249,7 +1248,7 @@ static int atalk_getname(struct socket *sock, struct sockaddr *uaddr,
 	struct atalk_sock *at = at_sk(sk);
 	int err;
 
-	lock_kernel();
+	lock_sock(sk);
 	err = -ENOBUFS;
 	if (sock_flag(sk, SOCK_ZAPPED))
 		if (atalk_autobind(sk) < 0)
@@ -1277,17 +1276,7 @@ static int atalk_getname(struct socket *sock, struct sockaddr *uaddr,
 	memcpy(uaddr, &sat, sizeof(sat));
 
 out:
-	unlock_kernel();
-	return err;
-}
-
-static unsigned int atalk_poll(struct file *file, struct socket *sock,
-			   poll_table *wait)
-{
-	int err;
-	lock_kernel();
-	err = datagram_poll(file, sock, wait);
-	unlock_kernel();
+	release_sock(sk);
 	return err;
 }
 
@@ -1596,7 +1585,7 @@ static int atalk_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr
 	if (len > DDP_MAXSZ)
 		return -EMSGSIZE;
 
-	lock_kernel();
+	lock_sock(sk);
 	if (usat) {
 		err = -EBUSY;
 		if (sock_flag(sk, SOCK_ZAPPED))
@@ -1651,7 +1640,9 @@ static int atalk_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr
 			sk, size, dev->name);
 
 	size += dev->hard_header_len;
+	release_sock(sk);
 	skb = sock_alloc_send_skb(sk, size, (flags & MSG_DONTWAIT), &err);
+	lock_sock(sk);
 	if (!skb)
 		goto out;
 
@@ -1738,7 +1729,7 @@ static int atalk_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr
 	SOCK_DEBUG(sk, "SK %p: Done write (%Zd).\n", sk, len);
 
 out:
-	unlock_kernel();
+	release_sock(sk);
 	return err ? : len;
 }
 
@@ -1753,9 +1744,10 @@ static int atalk_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr
 	int err = 0;
 	struct sk_buff *skb;
 
-	lock_kernel();
 	skb = skb_recv_datagram(sk, flags & ~MSG_DONTWAIT,
 						flags & MSG_DONTWAIT, &err);
+	lock_sock(sk);
+
 	if (!skb)
 		goto out;
 
@@ -1787,7 +1779,7 @@ static int atalk_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr
 	skb_free_datagram(sk, skb);	/* Free the datagram. */
 
 out:
-	unlock_kernel();
+	release_sock(sk);
 	return err ? : copied;
 }
 
@@ -1887,7 +1879,7 @@ static const struct proto_ops atalk_dgram_ops = {
 	.socketpair	= sock_no_socketpair,
 	.accept		= sock_no_accept,
 	.getname	= atalk_getname,
-	.poll		= atalk_poll,
+	.poll		= datagram_poll,
 	.ioctl		= atalk_ioctl,
 #ifdef CONFIG_COMPAT
 	.compat_ioctl	= atalk_compat_ioctl,
-- 
1.7.1
