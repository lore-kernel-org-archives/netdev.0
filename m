From: David Miller <davem@davemloft.net>
Subject: [PATCH 8/9] net: Don't keep around original SKB when we software
 segment GSO frames.
Date: Mon, 01 Sep 2014 15:25:15 -0700 (PDT)
Message-ID: <20140901.152515.1944476256109254437.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44742 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752529AbaIAWZP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 18:25:15 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 64604590920
	for <netdev@vger.kernel.org>; Mon,  1 Sep 2014 15:25:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Just maintain the list properly by returning the head of the remaining
SKB list from dev_hard_start_xmit().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netdevice.h |  4 +--
 net/core/dev.c            | 79 +++++++++--------------------------------------
 net/sched/sch_generic.c   |  2 +-
 3 files changed, 17 insertions(+), 68 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 47c49ba..202c25a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2828,8 +2828,8 @@ int dev_change_carrier(struct net_device *, bool new_carrier);
 int dev_get_phys_port_id(struct net_device *dev,
 			 struct netdev_phys_port_id *ppid);
 struct sk_buff *validate_xmit_skb(struct sk_buff *skb, struct net_device *dev);
-int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
-			struct netdev_queue *txq);
+struct sk_buff *dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
+				    struct netdev_queue *txq, int *ret);
 int __dev_forward_skb(struct net_device *dev, struct sk_buff *skb);
 int dev_forward_skb(struct net_device *dev, struct sk_buff *skb);
 bool is_skb_forwardable(struct net_device *dev, struct sk_buff *skb);
diff --git a/net/core/dev.c b/net/core/dev.c
index 75bc5b0..c89da4f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2485,52 +2485,6 @@ static int illegal_highdma(struct net_device *dev, struct sk_buff *skb)
 	return 0;
 }
 
-struct dev_gso_cb {
-	void (*destructor)(struct sk_buff *skb);
-};
-
-#define DEV_GSO_CB(skb) ((struct dev_gso_cb *)(skb)->cb)
-
-static void dev_gso_skb_destructor(struct sk_buff *skb)
-{
-	struct dev_gso_cb *cb;
-
-	kfree_skb_list(skb->next);
-	skb->next = NULL;
-
-	cb = DEV_GSO_CB(skb);
-	if (cb->destructor)
-		cb->destructor(skb);
-}
-
-/**
- *	dev_gso_segment - Perform emulated hardware segmentation on skb.
- *	@skb: buffer to segment
- *	@features: device features as applicable to this skb
- *
- *	This function segments the given skb and stores the list of segments
- *	in skb->next.
- */
-static int dev_gso_segment(struct sk_buff *skb, netdev_features_t features)
-{
-	struct sk_buff *segs;
-
-	segs = skb_gso_segment(skb, features);
-
-	/* Verifying header integrity only. */
-	if (!segs)
-		return 0;
-
-	if (IS_ERR(segs))
-		return PTR_ERR(segs);
-
-	skb->next = segs;
-	DEV_GSO_CB(skb)->destructor = skb->destructor;
-	skb->destructor = dev_gso_skb_destructor;
-
-	return 0;
-}
-
 /* If MPLS offload request, verify we are testing hardware MPLS features
  * instead of standard features for the netdev.
  */
@@ -2682,8 +2636,13 @@ struct sk_buff *validate_xmit_skb(struct sk_buff *skb, struct net_device *dev)
 		features &= dev->hw_enc_features;
 
 	if (netif_needs_gso(skb, features)) {
-		if (unlikely(dev_gso_segment(skb, features)))
-			goto out_kfree_skb;
+		struct sk_buff *segs;
+
+		segs = skb_gso_segment(skb, features);
+		kfree_skb(skb);
+		if (IS_ERR(segs))
+			segs = NULL;
+		skb = segs;
 	} else {
 		if (skb_needs_linearize(skb, features) &&
 		    __skb_linearize(skb))
@@ -2714,26 +2673,16 @@ out_null:
 	return NULL;
 }
 
-int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
-			struct netdev_queue *txq)
+struct sk_buff *dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
+				    struct netdev_queue *txq, int *ret)
 {
-	int rc = NETDEV_TX_OK;
-
-	if (likely(!skb->next))
-		return xmit_one(skb, dev, txq, false);
-
-	skb->next = xmit_list(skb->next, dev, txq, &rc);
-	if (likely(skb->next == NULL)) {
-		skb->destructor = DEV_GSO_CB(skb)->destructor;
-		consume_skb(skb);
-		return rc;
+	if (likely(!skb->next)) {
+		*ret = xmit_one(skb, dev, txq, false);
+		return skb;
 	}
 
-	kfree_skb(skb);
-
-	return rc;
+	return xmit_list(skb, dev, txq, ret);
 }
-EXPORT_SYMBOL_GPL(dev_hard_start_xmit);
 
 static void qdisc_pkt_len_init(struct sk_buff *skb)
 {
@@ -2945,7 +2894,7 @@ static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
 
 			if (!netif_xmit_stopped(txq)) {
 				__this_cpu_inc(xmit_recursion);
-				rc = dev_hard_start_xmit(skb, dev, txq);
+				skb = dev_hard_start_xmit(skb, dev, txq, &rc);
 				__this_cpu_dec(xmit_recursion);
 				if (dev_xmit_complete(rc)) {
 					HARD_TX_UNLOCK(dev, txq);
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index f178798..a8bf9f9 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -129,7 +129,7 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 
 	HARD_TX_LOCK(dev, txq, smp_processor_id());
 	if (!netif_xmit_frozen_or_stopped(txq))
-		ret = dev_hard_start_xmit(skb, dev, txq);
+		skb = dev_hard_start_xmit(skb, dev, txq, &ret);
 
 	HARD_TX_UNLOCK(dev, txq);
 
-- 
1.7.11.7
