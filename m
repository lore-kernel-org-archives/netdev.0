From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2.6.26] gianfar: Fix skb allocation strategy
Date: Tue, 22 Apr 2008 17:18:29 -0500
Message-ID: <1208902709-23557-1-git-send-email-afleming@freescale.com>
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	Andy Fleming <afleming@freescale.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:62173 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754581AbYDVWSf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2008 18:18:35 -0400
Received: from az33smr02.freescale.net (az33smr02.freescale.net [10.64.34.200])
	by az33egw02.freescale.net (8.12.11/az33egw02) with ESMTP id m3MMIVZA014364
	for <netdev@vger.kernel.org>; Tue, 22 Apr 2008 15:18:32 -0700 (MST)
Received: from ld0175-tx32.am.freescale.net (ld0175-tx32.am.freescale.net [10.82.19.125])
	by az33smr02.freescale.net (8.13.1/8.13.0) with ESMTP id m3MMIUrW026135
	for <netdev@vger.kernel.org>; Tue, 22 Apr 2008 17:18:30 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gianfar was unable to handle failed skb allocation for rx buffers, so
we were spinning until it succeeded.  Actually, it was worse--we were
spinning for a long time, and then silently failing.  Instead, we take
Stephen Hemminger's suggestion to try the allocation earlier, and drop the
packet if it failed.

We also make a couple of tweaks to how buffer descriptors are set up.

Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/gianfar.c |  100 ++++++++++++++++++++++++++++++++-----------------
 1 files changed, 65 insertions(+), 35 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index c8c3df7..015ce3e 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -98,7 +98,6 @@
 #include "gianfar_mii.h"
 
 #define TX_TIMEOUT      (1*HZ)
-#define SKB_ALLOC_TIMEOUT 1000000
 #undef BRIEF_GFAR_ERRORS
 #undef VERBOSE_GFAR_ERRORS
 
@@ -115,7 +114,9 @@ static int gfar_enet_open(struct net_device *dev);
 static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static void gfar_timeout(struct net_device *dev);
 static int gfar_close(struct net_device *dev);
-struct sk_buff *gfar_new_skb(struct net_device *dev, struct rxbd8 *bdp);
+struct sk_buff *gfar_new_skb(struct net_device *dev);
+static void gfar_new_rxbdp(struct net_device *dev, struct rxbd8 *bdp,
+		struct sk_buff *skb);
 static int gfar_set_mac_address(struct net_device *dev);
 static int gfar_change_mtu(struct net_device *dev, int new_mtu);
 static irqreturn_t gfar_error(int irq, void *dev_id);
@@ -783,14 +784,21 @@ int startup_gfar(struct net_device *dev)
 
 	rxbdp = priv->rx_bd_base;
 	for (i = 0; i < priv->rx_ring_size; i++) {
-		struct sk_buff *skb = NULL;
+		struct sk_buff *skb;
 
-		rxbdp->status = 0;
+		skb = gfar_new_skb(dev);
 
-		skb = gfar_new_skb(dev, rxbdp);
+		if (!skb) {
+			printk(KERN_ERR "%s: Can't allocate RX buffers\n",
+					dev->name);
+
+			goto err_rxalloc_fail;
+		}
 
 		priv->rx_skbuff[i] = skb;
 
+		gfar_new_rxbdp(dev, rxbdp, skb);
+
 		rxbdp++;
 	}
 
@@ -916,6 +924,7 @@ rx_irq_fail:
 tx_irq_fail:
 	free_irq(priv->interruptError, dev);
 err_irq_fail:
+err_rxalloc_fail:	
 rx_skb_fail:
 	free_skb_resources(priv);
 tx_skb_fail:
@@ -1328,18 +1337,37 @@ static irqreturn_t gfar_transmit(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-struct sk_buff * gfar_new_skb(struct net_device *dev, struct rxbd8 *bdp)
+static void gfar_new_rxbdp(struct net_device *dev, struct rxbd8 *bdp,
+		struct sk_buff *skb)
+{
+	struct gfar_private *priv = netdev_priv(dev);
+	u32 * status_len = (u32 *)bdp;
+	u16 flags;
+
+	bdp->bufPtr = dma_map_single(&dev->dev, skb->data,
+			priv->rx_buffer_size, DMA_FROM_DEVICE);
+
+	flags = RXBD_EMPTY | RXBD_INTERRUPT;
+
+	if (bdp == priv->rx_bd_base + priv->rx_ring_size - 1)
+		flags |= RXBD_WRAP;
+
+	eieio();
+
+	*status_len = (u32)flags << 16;
+}
+
+
+struct sk_buff * gfar_new_skb(struct net_device *dev)
 {
 	unsigned int alignamount;
 	struct gfar_private *priv = netdev_priv(dev);
 	struct sk_buff *skb = NULL;
-	unsigned int timeout = SKB_ALLOC_TIMEOUT;
 
 	/* We have to allocate the skb, so keep trying till we succeed */
-	while ((!skb) && timeout--)
-		skb = dev_alloc_skb(priv->rx_buffer_size + RXBUF_ALIGNMENT);
+	skb = netdev_alloc_skb(dev, priv->rx_buffer_size + RXBUF_ALIGNMENT);
 
-	if (NULL == skb)
+	if (!skb)
 		return NULL;
 
 	alignamount = RXBUF_ALIGNMENT -
@@ -1350,15 +1378,6 @@ struct sk_buff * gfar_new_skb(struct net_device *dev, struct rxbd8 *bdp)
 	 */
 	skb_reserve(skb, alignamount);
 
-	bdp->bufPtr = dma_map_single(&dev->dev, skb->data,
-			priv->rx_buffer_size, DMA_FROM_DEVICE);
-
-	bdp->length = 0;
-
-	/* Mark the buffer empty */
-	eieio();
-	bdp->status |= (RXBD_EMPTY | RXBD_INTERRUPT);
-
 	return skb;
 }
 
@@ -1544,10 +1563,31 @@ int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit)
 	bdp = priv->cur_rx;
 
 	while (!((bdp->status & RXBD_EMPTY) || (--rx_work_limit < 0))) {
+		struct sk_buff *newskb;
 		rmb();
+
+		/* Add another skb for the future */
+		newskb = gfar_new_skb(dev);
+
 		skb = priv->rx_skbuff[priv->skb_currx];
 
-		if ((bdp->status & RXBD_LAST) && !(bdp->status & RXBD_ERR)) {
+		/* We drop the frame if we failed to allocate a new buffer */
+		if (unlikely(!newskb || !(bdp->status & RXBD_LAST) ||
+				 bdp->status & RXBD_ERR)) {
+			count_errors(bdp->status, dev);
+
+			if (unlikely(!newskb))
+				newskb = skb;
+
+			if (skb) {
+				dma_unmap_single(&priv->dev->dev,
+						bdp->bufPtr,
+						priv->rx_buffer_size,
+						DMA_FROM_DEVICE);
+
+				dev_kfree_skb_any(skb);
+			}
+		} else {
 			/* Increment the number of packets */
 			dev->stats.rx_packets++;
 			howmany++;
@@ -1558,23 +1598,14 @@ int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit)
 			gfar_process_frame(dev, skb, pkt_len);
 
 			dev->stats.rx_bytes += pkt_len;
-		} else {
-			count_errors(bdp->status, dev);
-
-			if (skb)
-				dev_kfree_skb_any(skb);
-
-			priv->rx_skbuff[priv->skb_currx] = NULL;
 		}
 
 		dev->last_rx = jiffies;
 
-		/* Clear the status flags for this buffer */
-		bdp->status &= ~RXBD_STATS;
+		priv->rx_skbuff[priv->skb_currx] = newskb;
 
-		/* Add another skb for the future */
-		skb = gfar_new_skb(dev, bdp);
-		priv->rx_skbuff[priv->skb_currx] = skb;
+		/* Setup the new bdp */
+		gfar_new_rxbdp(dev, bdp, newskb);
 
 		/* Update to the next pointer */
 		if (bdp->status & RXBD_WRAP)
@@ -1584,9 +1615,8 @@ int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit)
 
 		/* update to point at the next skb */
 		priv->skb_currx =
-		    (priv->skb_currx +
-		     1) & RX_RING_MOD_MASK(priv->rx_ring_size);
-
+		    (priv->skb_currx + 1) &
+		    RX_RING_MOD_MASK(priv->rx_ring_size);
 	}
 
 	/* Update the current rxbd pointer to be the next one */
-- 
1.5.4.GIT

