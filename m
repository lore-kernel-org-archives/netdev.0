From: kaber@trash.net
Subject: [PATCH 03/11] netlink: add helper function for queueing skbs to the receive queue
Date: Sat,  3 Sep 2011 19:26:03 +0200
Message-ID: <1315070771-18576-4-git-send-email-kaber@trash.net>
References: <1315070771-18576-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56149 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753251Ab1ICR0R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Sep 2011 13:26:17 -0400
In-Reply-To: <1315070771-18576-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Consolidate skb receive queue code to allow overloading it for memory
mapped sockets.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netlink/af_netlink.c |   26 ++++++++++++++------------
 1 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index fc63ca5..a9f876b 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -153,6 +153,14 @@ static struct hlist_head *nl_pid_hashfn(struct nl_pid_hash *hash, u32 pid)
 	return &hash->table[jhash_1word(pid, hash->rnd) & hash->mask];
 }
 
+static void netlink_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
+{
+	unsigned int len = skb->len;
+
+	skb_queue_tail(&sk->sk_receive_queue, skb);
+	sk->sk_data_ready(sk, len);
+}
+
 static void netlink_sock_destruct(struct sock *sk)
 {
 	struct netlink_sock *nlk = nlk_sk(sk);
@@ -838,8 +846,7 @@ int netlink_sendskb(struct sock *sk, struct sk_buff *skb)
 {
 	int len = skb->len;
 
-	skb_queue_tail(&sk->sk_receive_queue, skb);
-	sk->sk_data_ready(sk, len);
+	netlink_queue_rcv_skb(sk, skb);
 	sock_put(sk);
 	return len;
 }
@@ -964,8 +971,7 @@ static inline int netlink_broadcast_deliver(struct sock *sk,
 	if (atomic_read(&sk->sk_rmem_alloc) <= sk->sk_rcvbuf &&
 	    !test_bit(NETLINK_CONGESTED, &nlk->state)) {
 		skb_set_owner_r(skb, sk);
-		skb_queue_tail(&sk->sk_receive_queue, skb);
-		sk->sk_data_ready(sk, skb->len);
+		netlink_queue_rcv_skb(sk, skb);
 		return atomic_read(&sk->sk_rmem_alloc) > sk->sk_rcvbuf;
 	}
 	return -1;
@@ -1689,10 +1695,8 @@ static int netlink_dump(struct sock *sk)
 
 		if (sk_filter(sk, skb))
 			kfree_skb(skb);
-		else {
-			skb_queue_tail(&sk->sk_receive_queue, skb);
-			sk->sk_data_ready(sk, skb->len);
-		}
+		else
+			netlink_queue_rcv_skb(sk, skb);
 		return 0;
 	}
 
@@ -1706,10 +1710,8 @@ static int netlink_dump(struct sock *sk)
 
 	if (sk_filter(sk, skb))
 		kfree_skb(skb);
-	else {
-		skb_queue_tail(&sk->sk_receive_queue, skb);
-		sk->sk_data_ready(sk, skb->len);
-	}
+	else
+		netlink_queue_rcv_skb(sk, skb);
 
 	if (cb->done)
 		cb->done(cb);
-- 
1.7.4.4
