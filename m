From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 1/5] net/appletalk: push down BKL into a atalk_dgram_ops
Date: Thu,  5 Nov 2009 15:37:26 +0100
Message-ID: <1257431850-20874-2-git-send-email-arnd@arndb.de>
References: <1257431850-20874-1-git-send-email-arnd@arndb.de>
Cc: David Miller <davem@davemloft.net>, John Kacur <jkacur@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757377AbZKEOhq@vger.kernel.org>
In-Reply-To: <1257431850-20874-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Making the BKL usage explicit in appletalk makes it more
obvious where it is used, reduces code size and helps
getting rid of the BKL in common code.

I did not analyse how to kill lock_kernel from appletalk
entirely, this will involve either proving that it's not
needed, or replacing with a proper mutex or spinlock,
after finding out which data structures are protected
by the lock.

Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Cc: David S. Miller <davem@davemloft.net>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 net/appletalk/ddp.c |  105 +++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 77 insertions(+), 28 deletions(-)

diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index b1a4290..3b831c0 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1054,11 +1054,13 @@ static int atalk_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
 
+	lock_kernel();
 	if (sk) {
 		sock_orphan(sk);
 		sock->sk = NULL;
 		atalk_destroy_socket(sk);
 	}
+	unlock_kernel();
 	return 0;
 }
 
@@ -1134,6 +1136,7 @@ static int atalk_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	struct sockaddr_at *addr = (struct sockaddr_at *)uaddr;
 	struct sock *sk = sock->sk;
 	struct atalk_sock *at = at_sk(sk);
+	int err;
 
 	if (!sock_flag(sk, SOCK_ZAPPED) ||
 	    addr_len != sizeof(struct sockaddr_at))
@@ -1142,37 +1145,44 @@ static int atalk_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	if (addr->sat_family != AF_APPLETALK)
 		return -EAFNOSUPPORT;
 
+	lock_kernel();
 	if (addr->sat_addr.s_net == htons(ATADDR_ANYNET)) {
 		struct atalk_addr *ap = atalk_find_primary();
 
+		err = -EADDRNOTAVAIL;
 		if (!ap)
-			return -EADDRNOTAVAIL;
+			goto out;
 
 		at->src_net  = addr->sat_addr.s_net = ap->s_net;
 		at->src_node = addr->sat_addr.s_node= ap->s_node;
 	} else {
+		err = -EADDRNOTAVAIL;
 		if (!atalk_find_interface(addr->sat_addr.s_net,
 					  addr->sat_addr.s_node))
-			return -EADDRNOTAVAIL;
+			goto out;
 
 		at->src_net  = addr->sat_addr.s_net;
 		at->src_node = addr->sat_addr.s_node;
 	}
 
 	if (addr->sat_port == ATADDR_ANYPORT) {
-		int n = atalk_pick_and_bind_port(sk, addr);
+		err = atalk_pick_and_bind_port(sk, addr);
 
-		if (n < 0)
-			return n;
+		if (err < 0)
+			goto out;
 	} else {
 		at->src_port = addr->sat_port;
 
+		err = -EADDRINUSE;
 		if (atalk_find_or_insert_socket(sk, addr))
-			return -EADDRINUSE;
+			goto out;
 	}
 
 	sock_reset_flag(sk, SOCK_ZAPPED);
-	return 0;
+	err = 0;
+out:
+	unlock_kernel();
+	return err;
 }
 
 /* Set the address we talk to */
@@ -1182,6 +1192,7 @@ static int atalk_connect(struct socket *sock, struct sockaddr *uaddr,
 	struct sock *sk = sock->sk;
 	struct atalk_sock *at = at_sk(sk);
 	struct sockaddr_at *addr;
+	int err;
 
 	sk->sk_state   = TCP_CLOSE;
 	sock->state = SS_UNCONNECTED;
@@ -1206,12 +1217,15 @@ static int atalk_connect(struct socket *sock, struct sockaddr *uaddr,
 #endif
 	}
 
+	lock_kernel();
+	err = -EBUSY;
 	if (sock_flag(sk, SOCK_ZAPPED))
 		if (atalk_autobind(sk) < 0)
-			return -EBUSY;
+			goto out;
 
+	err = -ENETUNREACH;
 	if (!atrtr_get_dev(&addr->sat_addr))
-		return -ENETUNREACH;
+		goto out;
 
 	at->dest_port = addr->sat_port;
 	at->dest_net  = addr->sat_addr.s_net;
@@ -1219,7 +1233,10 @@ static int atalk_connect(struct socket *sock, struct sockaddr *uaddr,
 
 	sock->state  = SS_CONNECTED;
 	sk->sk_state = TCP_ESTABLISHED;
-	return 0;
+	err = 0;
+out:
+	unlock_kernel();
+	return err;
 }
 
 /*
@@ -1232,17 +1249,21 @@ static int atalk_getname(struct socket *sock, struct sockaddr *uaddr,
 	struct sockaddr_at sat;
 	struct sock *sk = sock->sk;
 	struct atalk_sock *at = at_sk(sk);
+	int err;
 
+	lock_kernel();
+	err = -ENOBUFS;
 	if (sock_flag(sk, SOCK_ZAPPED))
 		if (atalk_autobind(sk) < 0)
-			return -ENOBUFS;
+			goto out;
 
 	*uaddr_len = sizeof(struct sockaddr_at);
 	memset(&sat.sat_zero, 0, sizeof(sat.sat_zero));
 
 	if (peer) {
+		err = -ENOTCONN;
 		if (sk->sk_state != TCP_ESTABLISHED)
-			return -ENOTCONN;
+			goto out;
 
 		sat.sat_addr.s_net  = at->dest_net;
 		sat.sat_addr.s_node = at->dest_node;
@@ -1253,9 +1274,23 @@ static int atalk_getname(struct socket *sock, struct sockaddr *uaddr,
 		sat.sat_port	    = at->src_port;
 	}
 
+	err = 0;
 	sat.sat_family = AF_APPLETALK;
 	memcpy(uaddr, &sat, sizeof(sat));
-	return 0;
+
+out:
+	unlock_kernel();
+	return err;
+}
+
+static unsigned int atalk_poll(struct file *file, struct socket *sock,
+			   poll_table *wait)
+{
+	int err;
+	lock_kernel();
+	err = datagram_poll(file, sock, wait);
+	unlock_kernel();
+	return err;
 }
 
 #if defined(CONFIG_IPDDP) || defined(CONFIG_IPDDP_MODULE)
@@ -1563,23 +1598,28 @@ static int atalk_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr
 	if (len > DDP_MAXSZ)
 		return -EMSGSIZE;
 
+	lock_kernel();
 	if (usat) {
+		err = -EBUSY;
 		if (sock_flag(sk, SOCK_ZAPPED))
 			if (atalk_autobind(sk) < 0)
-				return -EBUSY;
+				goto out;
 
+		err = -EINVAL;
 		if (msg->msg_namelen < sizeof(*usat) ||
 		    usat->sat_family != AF_APPLETALK)
-			return -EINVAL;
+			goto out;
 
+		err = -EPERM;
 		/* netatalk didn't implement this check */
 		if (usat->sat_addr.s_node == ATADDR_BCAST &&
 		    !sock_flag(sk, SOCK_BROADCAST)) {
-			return -EPERM;
+			goto out;
 		}
 	} else {
+		err = -ENOTCONN;
 		if (sk->sk_state != TCP_ESTABLISHED)
-			return -ENOTCONN;
+			goto out;
 		usat = &local_satalk;
 		usat->sat_family      = AF_APPLETALK;
 		usat->sat_port	      = at->dest_port;
@@ -1603,8 +1643,9 @@ static int atalk_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr
 
 		rt = atrtr_find(&at_hint);
 	}
+	err = ENETUNREACH;
 	if (!rt)
-		return -ENETUNREACH;
+		goto out;
 
 	dev = rt->dev;
 
@@ -1614,7 +1655,7 @@ static int atalk_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr
 	size += dev->hard_header_len;
 	skb = sock_alloc_send_skb(sk, size, (flags & MSG_DONTWAIT), &err);
 	if (!skb)
-		return err;
+		goto out;
 
 	skb->sk = sk;
 	skb_reserve(skb, ddp_dl->header_length);
@@ -1637,7 +1678,8 @@ static int atalk_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr
 	err = memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len);
 	if (err) {
 		kfree_skb(skb);
-		return -EFAULT;
+		err = -EFAULT;
+		goto out;
 	}
 
 	if (sk->sk_no_check == 1)
@@ -1676,7 +1718,8 @@ static int atalk_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr
 			rt = atrtr_find(&at_lo);
 			if (!rt) {
 				kfree_skb(skb);
-				return -ENETUNREACH;
+				err = -ENETUNREACH;
+				goto out;
 			}
 			dev = rt->dev;
 			skb->dev = dev;
@@ -1696,7 +1739,9 @@ static int atalk_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr
 	}
 	SOCK_DEBUG(sk, "SK %p: Done write (%Zd).\n", sk, len);
 
-	return len;
+out:
+	unlock_kernel();
+	return err ? : len;
 }
 
 static int atalk_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
@@ -1708,10 +1753,13 @@ static int atalk_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr
 	int copied = 0;
 	int offset = 0;
 	int err = 0;
-	struct sk_buff *skb = skb_recv_datagram(sk, flags & ~MSG_DONTWAIT,
+	struct sk_buff *skb;
+
+	lock_kernel();
+	skb = skb_recv_datagram(sk, flags & ~MSG_DONTWAIT,
 						flags & MSG_DONTWAIT, &err);
 	if (!skb)
-		return err;
+		goto out;
 
 	/* FIXME: use skb->cb to be able to use shared skbs */
 	ddp = ddp_hdr(skb);
@@ -1739,6 +1787,9 @@ static int atalk_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr
 	}
 
 	skb_free_datagram(sk, skb);	/* Free the datagram. */
+
+out:
+	unlock_kernel();
 	return err ? : copied;
 }
 
@@ -1827,7 +1878,7 @@ static struct net_proto_family atalk_family_ops = {
 	.owner		= THIS_MODULE,
 };
 
-static const struct proto_ops SOCKOPS_WRAPPED(atalk_dgram_ops) = {
+static const struct proto_ops atalk_dgram_ops = {
 	.family		= PF_APPLETALK,
 	.owner		= THIS_MODULE,
 	.release	= atalk_release,
@@ -1836,7 +1887,7 @@ static const struct proto_ops SOCKOPS_WRAPPED(atalk_dgram_ops) = {
 	.socketpair	= sock_no_socketpair,
 	.accept		= sock_no_accept,
 	.getname	= atalk_getname,
-	.poll		= datagram_poll,
+	.poll		= atalk_poll,
 	.ioctl		= atalk_ioctl,
 #ifdef CONFIG_COMPAT
 	.compat_ioctl	= atalk_compat_ioctl,
@@ -1851,8 +1902,6 @@ static const struct proto_ops SOCKOPS_WRAPPED(atalk_dgram_ops) = {
 	.sendpage	= sock_no_sendpage,
 };
 
-SOCKOPS_WRAP(atalk_dgram, PF_APPLETALK);
-
 static struct notifier_block ddp_notifier = {
 	.notifier_call	= ddp_device_event,
 };
-- 
1.6.3.3
