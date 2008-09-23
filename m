From: David Miller <davem@davemloft.net>
Subject: [PATCH]: Use skb_queue_head in de4x5 driver...
Date: Tue, 23 Sep 2008 00:21:01 -0700 (PDT)
Message-ID: <20080923.002101.227089368.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60596
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750966AbYIWHVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 03:21:14 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id A2111C8C181
	for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 00:21:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


More by-hand SKB list management elimination...

de4x5: Use skb_queue_head instead of by-hand implementation.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/tulip/de4x5.c |   38 ++++++++------------------------------
 1 files changed, 8 insertions(+), 30 deletions(-)

diff --git a/drivers/net/tulip/de4x5.c b/drivers/net/tulip/de4x5.c
index 617ef41..6444cbe 100644
--- a/drivers/net/tulip/de4x5.c
+++ b/drivers/net/tulip/de4x5.c
@@ -832,7 +832,7 @@ struct de4x5_private {
 	s32 csr14;                          /* Saved SIA TX/RX Register     */
 	s32 csr15;                          /* Saved SIA General Register   */
 	int save_cnt;                       /* Flag if state already saved  */
-	struct sk_buff *skb;                /* Save the (re-ordered) skb's  */
+	struct sk_buff_head queue;          /* Save the (re-ordered) skb's  */
     } cache;
     struct de4x5_srom srom;                 /* A copy of the SROM           */
     int cfrv;				    /* Card CFRV copy */
@@ -1128,6 +1128,7 @@ de4x5_hw_init(struct net_device *dev, u_long iobase, struct device *gendev)
 	printk("      which has an Ethernet PROM CRC error.\n");
 	return -ENXIO;
     } else {
+	skb_queue_head_init(&lp->cache.queue);
 	lp->cache.gepc = GEP_INIT;
 	lp->asBit = GEP_SLNK;
 	lp->asPolarity = GEP_SLNK;
@@ -1487,7 +1488,7 @@ de4x5_queue_pkt(struct sk_buff *skb, struct net_device *dev)
 	}
     } else if (skb->len > 0) {
 	/* If we already have stuff queued locally, use that first */
-	if (lp->cache.skb && !lp->interrupt) {
+	if (!skb_queue_empty(&lp->cache.queue) && !lp->interrupt) {
 	    de4x5_put_cache(dev, skb);
 	    skb = de4x5_get_cache(dev);
 	}
@@ -1580,7 +1581,7 @@ de4x5_interrupt(int irq, void *dev_id)
 
     /* Load the TX ring with any locally stored packets */
     if (!test_and_set_bit(0, (void *)&lp->cache.lock)) {
-	while (lp->cache.skb && !netif_queue_stopped(dev) && lp->tx_enable) {
+	while (!skb_queue_empty(&lp->cache.queue) && !netif_queue_stopped(dev) && lp->tx_enable) {
 	    de4x5_queue_pkt(de4x5_get_cache(dev), dev);
 	}
 	lp->cache.lock = 0;
@@ -3679,11 +3680,7 @@ de4x5_free_tx_buffs(struct net_device *dev)
     }
 
     /* Unload the locally queued packets */
-    while (lp->cache.skb) {
-	dev_kfree_skb(de4x5_get_cache(dev));
-    }
-
-    return;
+    __skb_queue_purge(&lp->cache.queue);
 }
 
 /*
@@ -3781,43 +3778,24 @@ static void
 de4x5_put_cache(struct net_device *dev, struct sk_buff *skb)
 {
     struct de4x5_private *lp = netdev_priv(dev);
-    struct sk_buff *p;
-
-    if (lp->cache.skb) {
-	for (p=lp->cache.skb; p->next; p=p->next);
-	p->next = skb;
-    } else {
-	lp->cache.skb = skb;
-    }
-    skb->next = NULL;
 
-    return;
+    __skb_queue_tail(&lp->cache.queue, skb);
 }
 
 static void
 de4x5_putb_cache(struct net_device *dev, struct sk_buff *skb)
 {
     struct de4x5_private *lp = netdev_priv(dev);
-    struct sk_buff *p = lp->cache.skb;
-
-    lp->cache.skb = skb;
-    skb->next = p;
 
-    return;
+    __skb_queue_head(&lp->cache.queue, skb);
 }
 
 static struct sk_buff *
 de4x5_get_cache(struct net_device *dev)
 {
     struct de4x5_private *lp = netdev_priv(dev);
-    struct sk_buff *p = lp->cache.skb;
 
-    if (p) {
-	lp->cache.skb = p->next;
-	p->next = NULL;
-    }
-
-    return p;
+    return __skb_dequeue(&lp->cache.queue);
 }
 
 /*
-- 
1.5.6.5

