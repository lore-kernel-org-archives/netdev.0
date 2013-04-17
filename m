From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 10/14] netlink: add flow control for memory mapped I/O
Date: Wed, 17 Apr 2013 18:47:05 +0200
Message-ID: <1366217229-22705-11-git-send-email-kaber@trash.net>
References: <1366217229-22705-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60966 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936228Ab3DQQrc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 12:47:32 -0400
In-Reply-To: <1366217229-22705-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Add flow control for memory mapped RX. Since user-space usually doesn't
invoke recvmsg() when using memory mapped I/O, flow control is performed
in netlink_poll(). Dumps are allowed to continue if at least half of the
ring frames are unused.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netlink/af_netlink.c | 88 +++++++++++++++++++++++++++++++++---------------
 1 file changed, 61 insertions(+), 27 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index d120b5d..2a3e9ba 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -3,6 +3,7 @@
  *
  * 		Authors:	Alan Cox <alan@lxorguk.ukuu.org.uk>
  * 				Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
+ * 				Patrick McHardy <kaber@trash.net>
  *
  *		This program is free software; you can redistribute it and/or
  *		modify it under the terms of the GNU General Public License
@@ -110,6 +111,29 @@ static inline struct hlist_head *nl_portid_hashfn(struct nl_portid_hash *hash, u
 	return &hash->table[jhash_1word(portid, hash->rnd) & hash->mask];
 }
 
+static void netlink_overrun(struct sock *sk)
+{
+	struct netlink_sock *nlk = nlk_sk(sk);
+
+	if (!(nlk->flags & NETLINK_RECV_NO_ENOBUFS)) {
+		if (!test_and_set_bit(NETLINK_CONGESTED, &nlk_sk(sk)->state)) {
+			sk->sk_err = ENOBUFS;
+			sk->sk_error_report(sk);
+		}
+	}
+	atomic_inc(&sk->sk_drops);
+}
+
+static void netlink_rcv_wake(struct sock *sk)
+{
+	struct netlink_sock *nlk = nlk_sk(sk);
+
+	if (skb_queue_empty(&sk->sk_receive_queue))
+		clear_bit(NETLINK_CONGESTED, &nlk->state);
+	if (!test_bit(NETLINK_CONGESTED, &nlk->state))
+		wake_up_interruptible(&nlk->wait);
+}
+
 #ifdef CONFIG_NETLINK_MMAP
 static bool netlink_skb_is_mmaped(const struct sk_buff *skb)
 {
@@ -441,15 +465,48 @@ static void netlink_forward_ring(struct netlink_ring *ring)
 	} while (ring->head != head);
 }
 
+static bool netlink_dump_space(struct netlink_sock *nlk)
+{
+	struct netlink_ring *ring = &nlk->rx_ring;
+	struct nl_mmap_hdr *hdr;
+	unsigned int n;
+
+	hdr = netlink_current_frame(ring, NL_MMAP_STATUS_UNUSED);
+	if (hdr == NULL)
+		return false;
+
+	n = ring->head + ring->frame_max / 2;
+	if (n > ring->frame_max)
+		n -= ring->frame_max;
+
+	hdr = __netlink_lookup_frame(ring, n);
+
+	return hdr->nm_status == NL_MMAP_STATUS_UNUSED;
+}
+
 static unsigned int netlink_poll(struct file *file, struct socket *sock,
 				 poll_table *wait)
 {
 	struct sock *sk = sock->sk;
 	struct netlink_sock *nlk = nlk_sk(sk);
 	unsigned int mask;
+	int err;
 
-	if (nlk->cb != NULL && nlk->rx_ring.pg_vec != NULL)
-		netlink_dump(sk);
+	if (nlk->rx_ring.pg_vec != NULL) {
+		/* Memory mapped sockets don't call recvmsg(), so flow control
+		 * for dumps is performed here. A dump is allowed to continue
+		 * if at least half the ring is unused.
+		 */
+		while (nlk->cb != NULL && netlink_dump_space(nlk)) {
+			err = netlink_dump(sk);
+			if (err < 0) {
+				sk->sk_err = err;
+				sk->sk_error_report(sk);
+				break;
+			}
+		}
+		netlink_rcv_wake(sk);
+	}
 
 	mask = datagram_poll(file, sock, wait);
 
@@ -623,8 +680,7 @@ static void netlink_ring_set_copied(struct sock *sk, struct sk_buff *skb)
 	if (hdr == NULL) {
 		spin_unlock_bh(&sk->sk_receive_queue.lock);
 		kfree_skb(skb);
-		sk->sk_err = ENOBUFS;
-		sk->sk_error_report(sk);
+		netlink_overrun(sk);
 		return;
 	}
 	netlink_increment_head(ring);
@@ -1329,19 +1385,6 @@ static int netlink_getname(struct socket *sock, struct sockaddr *addr,
 	return 0;
 }
 
-static void netlink_overrun(struct sock *sk)
-{
-	struct netlink_sock *nlk = nlk_sk(sk);
-
-	if (!(nlk->flags & NETLINK_RECV_NO_ENOBUFS)) {
-		if (!test_and_set_bit(NETLINK_CONGESTED, &nlk_sk(sk)->state)) {
-			sk->sk_err = ENOBUFS;
-			sk->sk_error_report(sk);
-		}
-	}
-	atomic_inc(&sk->sk_drops);
-}
-
 static struct sock *netlink_getsockbyportid(struct sock *ssk, u32 portid)
 {
 	struct sock *sock;
@@ -1484,16 +1527,6 @@ static struct sk_buff *netlink_trim(struct sk_buff *skb, gfp_t allocation)
 	return skb;
 }
 
-static void netlink_rcv_wake(struct sock *sk)
-{
-	struct netlink_sock *nlk = nlk_sk(sk);
-
-	if (skb_queue_empty(&sk->sk_receive_queue))
-		clear_bit(NETLINK_CONGESTED, &nlk->state);
-	if (!test_bit(NETLINK_CONGESTED, &nlk->state))
-		wake_up_interruptible(&nlk->wait);
-}
-
 static int netlink_unicast_kernel(struct sock *sk, struct sk_buff *skb,
 				  struct sock *ssk)
 {
@@ -1597,6 +1630,7 @@ struct sk_buff *netlink_alloc_skb(struct sock *ssk, unsigned int size,
 err2:
 	kfree_skb(skb);
 	spin_unlock_bh(&sk->sk_receive_queue.lock);
+	netlink_overrun(sk);
 err1:
 	sock_put(sk);
 	return NULL;
-- 
1.8.1.4
