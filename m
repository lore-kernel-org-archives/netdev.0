From: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>
Subject: [PATCH 2/2] udp: cleanup __udp6_lib_mcast_deliver
Date: Thu, 5 Nov 2009 20:33:59 +0200
Message-ID: <200911052033.59795.lgrijincu@ixiacom.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_Xqx8KvWaU9sr7Th"
Cc: opurdila@ixiacom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:6482 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758037AbZKESdz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 13:33:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--Boundary-00=_Xqx8KvWaU9sr7Th
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit


__udp6_lib_mcast_deliver always returned 0.
It's caller can return 0 explicitly to make things clearer.

Also, we don't need the spin_lock() on the hslot to free the skb.

kfree_skb() assumes that the frame is being dropped after a failure
and notes that. Replace it with consume_skb().

Signed-off-by: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>
---
 net/ipv6/udp.c |   16 +++++++++-------
 1 files changed, 9 insertions(+), 7 deletions(-)


--Boundary-00=_Xqx8KvWaU9sr7Th
Content-Type: text/plain;
  charset="utf-8";
  name="0002-udp-cleanup-__udp6_lib_mcast_deliver.patch"
Content-Transfer-Encoding: 8bit
Content-Disposition: inline;
	filename="0002-udp-cleanup-__udp6_lib_mcast_deliver.patch"

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index d3b59d7..5f17fef 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -446,7 +446,7 @@ static struct sock *udp_v6_mcast_next(struct net *net, struct sock *sk,
  * Note: called only from the BH handler context,
  * so we don't need to lock the hashes.
  */
-static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
+static void __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 		struct in6_addr *saddr, struct in6_addr *daddr,
 		struct udp_table *udptable)
 {
@@ -460,8 +460,9 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 	dif = inet6_iif(skb);
 	sk = udp_v6_mcast_next(net, sk, uh->dest, daddr, uh->source, saddr, dif);
 	if (!sk) {
-		kfree_skb(skb);
-		goto out;
+		spin_unlock(&hslot->lock);
+		consume_skb(skb);
+		return;
 	}
 
 	sk2 = sk;
@@ -483,9 +484,8 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 	else
 		sk_add_backlog(sk, skb);
 	bh_unlock_sock(sk);
-out:
+
 	spin_unlock(&hslot->lock);
-	return 0;
 }
 
 static inline int udp6_csum_init(struct sk_buff *skb, struct udphdr *uh,
@@ -568,9 +568,11 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	/*
 	 *	Multicast receive code
 	 */
-	if (ipv6_addr_is_multicast(daddr))
-		return __udp6_lib_mcast_deliver(net, skb,
+	if (ipv6_addr_is_multicast(daddr)) {
+		__udp6_lib_mcast_deliver(net, skb,
 				saddr, daddr, udptable);
+		return 0;
+	}
 
 	/* Unicast */
 

--Boundary-00=_Xqx8KvWaU9sr7Th--


