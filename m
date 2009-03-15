From: Kyle McMartin <kyle@infradead.org>
Subject: [PATCH] tulip: fix crash on iface up with shirq debug
Date: Sun, 15 Mar 2009 01:35:52 -0400
Message-ID: <20090315053552.GH3167@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: grundler@parisc-linux.org, davej@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:43752 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751968AbZCOFfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2009 01:35:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kyle McMartin <kyle@redhat.com>

Tulip is currently doing request_irq before it has done its
initialization. This is usually not a problem because it hasn't
enable interrupts yet, but with DEBUG_SHIRQ on, we call the irq handler
when registering the interrupt as a sanity check.

This can result in a NULL ptr dereference, so call tulip_init_ring
before request_irq, and add a free_ring function to do the freeing
now shared with tulip_close.

Tested with a shell loop running ifup, ifdown in a loop a few hundred
times with DEBUG_SHIRQ on.

Signed-off-by: Kyle McMartin <kyle@redhat.com>
---
diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index bee75fa..2abb5d3 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -255,6 +255,7 @@ const char tulip_media_cap[32] =
 
 static void tulip_tx_timeout(struct net_device *dev);
 static void tulip_init_ring(struct net_device *dev);
+static void tulip_free_ring(struct net_device *dev);
 static int tulip_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static int tulip_open(struct net_device *dev);
 static int tulip_close(struct net_device *dev);
@@ -502,16 +503,21 @@ tulip_open(struct net_device *dev)
 {
 	int retval;
 
-	if ((retval = request_irq(dev->irq, &tulip_interrupt, IRQF_SHARED, dev->name, dev)))
-		return retval;
-
 	tulip_init_ring (dev);
 
+	retval = request_irq(dev->irq, &tulip_interrupt, IRQF_SHARED, dev->name, dev);
+	if (retval)
+		goto free_ring;
+
 	tulip_up (dev);
 
 	netif_start_queue (dev);
 
 	return 0;
+
+free_ring:
+	tulip_free_ring (dev);
+	return retval;
 }
 
 
@@ -768,23 +774,11 @@ static void tulip_down (struct net_device *dev)
 	tulip_set_power_state (tp, 0, 1);
 }
 
-
-static int tulip_close (struct net_device *dev)
+static void tulip_free_ring (struct net_device *dev)
 {
 	struct tulip_private *tp = netdev_priv(dev);
-	void __iomem *ioaddr = tp->base_addr;
 	int i;
 
-	netif_stop_queue (dev);
-
-	tulip_down (dev);
-
-	if (tulip_debug > 1)
-		printk (KERN_DEBUG "%s: Shutting down ethercard, status was %2.2x.\n",
-			dev->name, ioread32 (ioaddr + CSR5));
-
-	free_irq (dev->irq, dev);
-
 	/* Free all the skbuffs in the Rx queue. */
 	for (i = 0; i < RX_RING_SIZE; i++) {
 		struct sk_buff *skb = tp->rx_buffers[i].skb;
@@ -803,6 +797,7 @@ static int tulip_close (struct net_device *dev)
 			dev_kfree_skb (skb);
 		}
 	}
+
 	for (i = 0; i < TX_RING_SIZE; i++) {
 		struct sk_buff *skb = tp->tx_buffers[i].skb;
 
@@ -814,6 +809,24 @@ static int tulip_close (struct net_device *dev)
 		tp->tx_buffers[i].skb = NULL;
 		tp->tx_buffers[i].mapping = 0;
 	}
+}
+
+static int tulip_close (struct net_device *dev)
+{
+	struct tulip_private *tp = netdev_priv(dev);
+	void __iomem *ioaddr = tp->base_addr;
+
+	netif_stop_queue (dev);
+
+	tulip_down (dev);
+
+	if (tulip_debug > 1)
+		printk (KERN_DEBUG "%s: Shutting down ethercard, status was %2.2x.\n",
+			dev->name, ioread32 (ioaddr + CSR5));
+
+	free_irq (dev->irq, dev);
+
+	tulip_free_ring (dev);
 
 	return 0;
 }
