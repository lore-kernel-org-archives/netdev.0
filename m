From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [PATCH v2 1/4 net-next] net/ipv6/udp: UDP encapsulation: break backlog_rcv into __udpv6_queue_rcv_skb
Date: Fri, 27 Apr 2012 14:23:21 -0400
Message-ID: <20120427182321.GE17021@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:52107 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760485Ab2D0SXY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2012 14:23:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the first step in reworking the IPv6 UDP code to be structured more
like the IPv4 UDP code.  This patch creates __udpv6_queue_rcv_skb() with
the equivalent sematics to __udp_queue_rcv_skb(), and wires it up to the
backlog_rcv method.

Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
---
 net/ipv6/udp.c |   42 +++++++++++++++++++++++++++---------------
 1 files changed, 27 insertions(+), 15 deletions(-)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index d39bbc9..6c0367f 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -496,6 +496,28 @@ out:
 	sock_put(sk);
 }
 
+static int __udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
+{
+	int rc;
+
+	if (!ipv6_addr_any(&inet6_sk(sk)->daddr))
+		sock_rps_save_rxhash(sk, skb);
+
+	rc = sock_queue_rcv_skb(sk, skb);
+	if (rc < 0) {
+		int is_udplite = IS_UDPLITE(sk);
+
+		/* Note that an ENOMEM error is charged twice */
+		if (rc == -ENOMEM)
+			UDP6_INC_STATS_BH(sock_net(sk),
+					UDP_MIB_RCVBUFERRORS, is_udplite);
+		UDP6_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
+		kfree_skb(skb);
+		return -1;
+	}
+	return 0;
+}
+
 static __inline__ void udpv6_err(struct sk_buff *skb,
 				 struct inet6_skb_parm *opt, u8 type,
 				 u8 code, int offset, __be32 info     )
@@ -503,15 +525,12 @@ static __inline__ void udpv6_err(struct sk_buff *skb,
 	__udp6_lib_err(skb, opt, type, code, offset, info, &udp_table);
 }
 
-int udpv6_queue_rcv_skb(struct sock * sk, struct sk_buff *skb)
+int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	struct udp_sock *up = udp_sk(sk);
 	int rc;
 	int is_udplite = IS_UDPLITE(sk);
 
-	if (!ipv6_addr_any(&inet6_sk(sk)->daddr))
-		sock_rps_save_rxhash(sk, skb);
-
 	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto drop;
 
@@ -540,19 +559,12 @@ int udpv6_queue_rcv_skb(struct sock * sk, struct sk_buff *skb)
 	}
 
 	skb_dst_drop(skb);
-	rc = sock_queue_rcv_skb(sk, skb);
-	if (rc < 0) {
-		/* Note that an ENOMEM error is charged twice */
-		if (rc == -ENOMEM)
-			UDP6_INC_STATS_BH(sock_net(sk),
-					UDP_MIB_RCVBUFERRORS, is_udplite);
-		goto drop_no_sk_drops_inc;
-	}
 
-	return 0;
+	rc = __udpv6_queue_rcv_skb(sk, skb);
+
+	return rc;
 drop:
 	atomic_inc(&sk->sk_drops);
-drop_no_sk_drops_inc:
 	UDP6_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
 	kfree_skb(skb);
 	return -1;
@@ -1471,7 +1483,7 @@ struct proto udpv6_prot = {
 	.getsockopt	   = udpv6_getsockopt,
 	.sendmsg	   = udpv6_sendmsg,
 	.recvmsg	   = udpv6_recvmsg,
-	.backlog_rcv	   = udpv6_queue_rcv_skb,
+	.backlog_rcv	   = __udpv6_queue_rcv_skb,
 	.hash		   = udp_lib_hash,
 	.unhash		   = udp_lib_unhash,
 	.rehash		   = udp_v6_rehash,
-- 
1.7.4.1


-- 
"Thought is the essence of where you are now."
