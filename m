From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: net: [PATCH] Optimize non-gso test checks
Date: Wed, 20 Jan 2010 18:00:33 +0530
Message-ID: <20100120123033.28183.78883.sendpatchset@krkumar2.in.ibm.com>
Cc: netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp08.au.ibm.com ([202.81.31.141]:60655 "EHLO
	e23smtp08.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932094Ab0ATMah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 07:30:37 -0500
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp08.au.ibm.com (8.14.3/8.13.1) with ESMTP id o0KNUZSw030853
	for <netdev@vger.kernel.org>; Thu, 21 Jan 2010 10:30:35 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o0KCPppe1638494
	for <netdev@vger.kernel.org>; Wed, 20 Jan 2010 23:25:51 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o0KCUZHn017243
	for <netdev@vger.kernel.org>; Wed, 20 Jan 2010 23:30:35 +1100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

Avoid checking twice whether skb needs to be linearized, if one
skb_linearize was already done.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 net/core/dev.c |   29 +++++++++++++++++------------
 1 file changed, 17 insertions(+), 12 deletions(-)

diff -ruNp org/net/core/dev.c new/net/core/dev.c
--- org/net/core/dev.c	2010-01-18 14:53:02.000000000 +0530
+++ new/net/core/dev.c	2010-01-20 17:58:33.000000000 +0530
@@ -1982,6 +1982,21 @@ static inline int __dev_xmit_skb(struct 
 	return rc;
 }
 
+/*
+ * Returns true if either:
+ *	1. skb has frag_list and the device doesn't support FRAGLIST, or
+ *	2. skb is fragmented and the device does not support SG, or if
+ *	   at least one of fragments is in highmem and device does not
+ *	   support DMA from it.
+ */
+static inline int skb_needs_linearize(struct sk_buff *skb,
+				      struct net_device *dev)
+{
+	return (skb_has_frags(skb) && !(dev->features & NETIF_F_FRAGLIST)) ||
+	       (skb_shinfo(skb)->nr_frags && (!(dev->features & NETIF_F_SG) ||
+					      illegal_highdma(dev, skb)));
+}
+
 /**
  *	dev_queue_xmit - transmit a buffer
  *	@skb: buffer to transmit
@@ -2018,18 +2033,8 @@ int dev_queue_xmit(struct sk_buff *skb)
 	if (netif_needs_gso(dev, skb))
 		goto gso;
 
-	if (skb_has_frags(skb) &&
-	    !(dev->features & NETIF_F_FRAGLIST) &&
-	    __skb_linearize(skb))
-		goto out_kfree_skb;
-
-	/* Fragmented skb is linearized if device does not support SG,
-	 * or if at least one of fragments is in highmem and device
-	 * does not support DMA from it.
-	 */
-	if (skb_shinfo(skb)->nr_frags &&
-	    (!(dev->features & NETIF_F_SG) || illegal_highdma(dev, skb)) &&
-	    __skb_linearize(skb))
+	/* Convert a paged skb to linear, if required */
+	if (skb_needs_linearize(skb, dev) && __skb_linearize(skb))
 		goto out_kfree_skb;
 
 	/* If packet is not checksummed and device does not support
