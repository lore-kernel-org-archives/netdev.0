From: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>
Subject: [PATCH 1/2] udp: cleanup __udp4_lib_mcast_deliver
Date: Thu, 5 Nov 2009 20:33:21 +0200
Message-ID: <200911052033.21964.lgrijincu@ixiacom.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_xpx8K7xOINck9XK"
Cc: opurdila@ixiacom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:13698 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757262AbZKESdU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 13:33:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--Boundary-00=_xpx8K7xOINck9XK
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit


__udp4_lib_mcast_deliver always returned 0.
It's caller can return 0 explicitly to make things clearer.

Also, we don't need the spin_lock() on the hslot to free the skb.

Signed-off-by: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>
---
 net/ipv4/udp.c |   57 +++++++++++++++++++++++++++++--------------------------
 1 files changed, 30 insertions(+), 27 deletions(-)


--Boundary-00=_xpx8K7xOINck9XK
Content-Type: text/plain;
  charset="utf-8";
  name="0001-udp-cleanup-__udp4_lib_mcast_deliver.patch"
Content-Transfer-Encoding: 8bit
Content-Disposition: inline;
	filename="0001-udp-cleanup-__udp4_lib_mcast_deliver.patch"

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 4274c1c..425b2d4 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1198,12 +1198,12 @@ drop:
  *	Note: called only from the BH handler context,
  *	so we don't need to lock the hashes.
  */
-static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
+static void __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 				    struct udphdr  *uh,
 				    __be32 saddr, __be32 daddr,
 				    struct udp_table *udptable)
 {
-	struct sock *sk;
+	struct sock *sk, *sknext;
 	struct udp_hslot *hslot = udp_hashslot(udptable, net, ntohs(uh->dest));
 	int dif;
 
@@ -1211,31 +1211,32 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 	sk = sk_nulls_head(&hslot->head);
 	dif = skb->dev->ifindex;
 	sk = udp_v4_mcast_next(net, sk, uh->dest, daddr, uh->source, saddr, dif);
-	if (sk) {
-		struct sock *sknext = NULL;
-
-		do {
-			struct sk_buff *skb1 = skb;
-
-			sknext = udp_v4_mcast_next(net, sk_nulls_next(sk), uh->dest,
-						   daddr, uh->source, saddr,
-						   dif);
-			if (sknext)
-				skb1 = skb_clone(skb, GFP_ATOMIC);
-
-			if (skb1) {
-				int ret = udp_queue_rcv_skb(sk, skb1);
-				if (ret > 0)
-					/* we should probably re-process instead
-					 * of dropping packets here. */
-					kfree_skb(skb1);
-			}
-			sk = sknext;
-		} while (sknext);
-	} else
+	if (!sk) {
+		spin_unlock(&hslot->lock);
 		consume_skb(skb);
+		return;
+	}
+
+	do {
+		struct sk_buff *skb1 = skb;
+
+		sknext = udp_v4_mcast_next(net, sk_nulls_next(sk), uh->dest,
+					   daddr, uh->source, saddr,
+					   dif);
+		if (sknext)
+			skb1 = skb_clone(skb, GFP_ATOMIC);
+
+		if (skb1) {
+			int ret = udp_queue_rcv_skb(sk, skb1);
+			if (ret > 0)
+				/* we should probably re-process instead
+				 * of dropping packets here. */
+				kfree_skb(skb1);
+		}
+		sk = sknext;
+	} while (sknext);
 	spin_unlock(&hslot->lock);
-	return 0;
+	return;
 }
 
 /* Initialize UDP checksum. If exited with zero value (success),
@@ -1314,9 +1315,11 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	saddr = ip_hdr(skb)->saddr;
 	daddr = ip_hdr(skb)->daddr;
 
-	if (rt->rt_flags & (RTCF_BROADCAST|RTCF_MULTICAST))
-		return __udp4_lib_mcast_deliver(net, skb, uh,
+	if (rt->rt_flags & (RTCF_BROADCAST|RTCF_MULTICAST)) {
+		__udp4_lib_mcast_deliver(net, skb, uh,
 				saddr, daddr, udptable);
+		return 0;
+	}
 
 	sk = __udp4_lib_lookup_skb(skb, uh->source, uh->dest, udptable);
 

--Boundary-00=_xpx8K7xOINck9XK--



