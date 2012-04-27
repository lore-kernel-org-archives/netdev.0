From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [PATCH v2 2/4 net-next] net/ipv6/udp: UDP encapsulation: move socket locking into udpv6_queue_rcv_skb()
Date: Fri, 27 Apr 2012 14:23:59 -0400
Message-ID: <20120427182358.GF17021@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:52112 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760485Ab2D0SX7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2012 14:23:59 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to make sure that when the encap_rcv() hook is introduced it is
not called with the socket lock held, move socket locking from callers into
udpv6_queue_rcv_skb(), matching what happens in IPv4.

Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
---
 net/ipv6/udp.c |   97 +++++++++++++++++++++++++------------------------------
 1 files changed, 44 insertions(+), 53 deletions(-)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 6c0367f..bc533ea 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -558,14 +558,25 @@ int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 			goto drop;
 	}
 
+	if (sk_rcvqueues_full(sk, skb, sk->sk_rcvbuf))
+		goto drop;
+
 	skb_dst_drop(skb);
 
-	rc = __udpv6_queue_rcv_skb(sk, skb);
+	bh_lock_sock(sk);
+	rc = 0;
+	if (!sock_owned_by_user(sk))
+		rc = __udpv6_queue_rcv_skb(sk, skb);
+	else if (sk_add_backlog(sk, skb, sk->sk_rcvbuf)) {
+		bh_unlock_sock(sk);
+		goto drop;
+	}
+	bh_unlock_sock(sk);
 
 	return rc;
 drop:
-	atomic_inc(&sk->sk_drops);
 	UDP6_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
+	atomic_inc(&sk->sk_drops);
 	kfree_skb(skb);
 	return -1;
 }
@@ -614,37 +625,27 @@ static struct sock *udp_v6_mcast_next(struct net *net, struct sock *sk,
 static void flush_stack(struct sock **stack, unsigned int count,
 			struct sk_buff *skb, unsigned int final)
 {
-	unsigned int i;
+	struct sk_buff *skb1 = NULL;
 	struct sock *sk;
-	struct sk_buff *skb1;
+	unsigned int i;
 
 	for (i = 0; i < count; i++) {
-		skb1 = (i == final) ? skb : skb_clone(skb, GFP_ATOMIC);
-
 		sk = stack[i];
-		if (skb1) {
-			if (sk_rcvqueues_full(sk, skb1, sk->sk_rcvbuf)) {
-				kfree_skb(skb1);
-				goto drop;
-			}
-			bh_lock_sock(sk);
-			if (!sock_owned_by_user(sk))
-				udpv6_queue_rcv_skb(sk, skb1);
-			else if (sk_add_backlog(sk, skb1, sk->sk_rcvbuf)) {
-				kfree_skb(skb1);
-				bh_unlock_sock(sk);
-				goto drop;
-			}
-			bh_unlock_sock(sk);
-			continue;
+		if (likely(skb1 == NULL))
+			skb1 = (i == final) ? skb : skb_clone(skb, GFP_ATOMIC);
+		if (!skb1) {
+			atomic_inc(&sk->sk_drops);
+			UDP6_INC_STATS_BH(sock_net(sk), UDP_MIB_RCVBUFERRORS,
+					  IS_UDPLITE(sk));
+			UDP6_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS,
+					  IS_UDPLITE(sk));
 		}
-drop:
-		atomic_inc(&sk->sk_drops);
-		UDP6_INC_STATS_BH(sock_net(sk),
-				UDP_MIB_RCVBUFERRORS, IS_UDPLITE(sk));
-		UDP6_INC_STATS_BH(sock_net(sk),
-				UDP_MIB_INERRORS, IS_UDPLITE(sk));
+
+		if (skb1 && udpv6_queue_rcv_skb(sk, skb1) <= 0)
+			skb1 = NULL;
 	}
+	if (unlikely(skb1))
+		kfree_skb(skb1);
 }
 /*
  * Note: called only from the BH handler context,
@@ -784,39 +785,29 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	 * for sock caches... i'll skip this for now.
 	 */
 	sk = __udp6_lib_lookup_skb(skb, uh->source, uh->dest, udptable);
+	if (sk != NULL) {
+		int ret = udpv6_queue_rcv_skb(sk, skb);
+		sock_put(sk);
 
-	if (sk == NULL) {
-		if (!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb))
-			goto discard;
-
-		if (udp_lib_checksum_complete(skb))
-			goto discard;
-		UDP6_INC_STATS_BH(net, UDP_MIB_NOPORTS,
-				proto == IPPROTO_UDPLITE);
-
-		icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_PORT_UNREACH, 0);
+		/* a return value > 0 means to resubmit the input, but
+		 * it wants the return to be -protocol, or 0
+		 */
+		if (ret > 0)
+			return -ret;
 
-		kfree_skb(skb);
 		return 0;
 	}
 
-	/* deliver */
-
-	if (sk_rcvqueues_full(sk, skb, sk->sk_rcvbuf)) {
-		sock_put(sk);
+	if (!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb))
 		goto discard;
-	}
-	bh_lock_sock(sk);
-	if (!sock_owned_by_user(sk))
-		udpv6_queue_rcv_skb(sk, skb);
-	else if (sk_add_backlog(sk, skb, sk->sk_rcvbuf)) {
-		atomic_inc(&sk->sk_drops);
-		bh_unlock_sock(sk);
-		sock_put(sk);
+
+	if (udp_lib_checksum_complete(skb))
 		goto discard;
-	}
-	bh_unlock_sock(sk);
-	sock_put(sk);
+
+	UDP6_INC_STATS_BH(net, UDP_MIB_NOPORTS, proto == IPPROTO_UDPLITE);
+	icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_PORT_UNREACH, 0);
+
+	kfree_skb(skb);
 	return 0;
 
 short_packet:
-- 
1.7.4.1


-- 
"Thought is the essence of where you are now."
