From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2.6.28] gianfar: Fix DMA unmap invocations
Date: Wed, 12 Nov 2008 10:07:11 -0600
Message-ID: <1226506031-8414-1-git-send-email-afleming@freescale.com>
Cc: jeff@garzik.org, Andy Fleming <afleming@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:38137 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750845AbYKLQH2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 11:07:28 -0500
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by az33egw02.freescale.net (8.12.11/az33egw02) with ESMTP id mACG7DGW001344
	for <netdev@vger.kernel.org>; Wed, 12 Nov 2008 09:07:24 -0700 (MST)
Received: from ld0175-tx32.am.freescale.net (ld0175-tx32.am.freescale.net [10.82.19.125])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id mACG7C18019048
	for <netdev@vger.kernel.org>; Wed, 12 Nov 2008 10:07:12 -0600 (CST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We weren't unmapping DMA memory, which will break when gianfar gets used
on systems with more than 32-bits of memory.  Also, it's just plain wrong.

Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/gianfar.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 83a5cb6..c4af949 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1407,6 +1407,10 @@ static int gfar_clean_tx_ring(struct net_device *dev)
 		if (bdp->status & TXBD_DEF)
 			dev->stats.collisions++;
 
+		/* Unmap the DMA memory */
+		dma_unmap_single(&priv->dev->dev, bdp->bufPtr,
+				bdp->length, DMA_TO_DEVICE);
+
 		/* Free the sk buffer associated with this TxBD */
 		dev_kfree_skb_irq(priv->tx_skbuff[priv->skb_dirtytx]);
 
@@ -1666,6 +1670,9 @@ int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit)
 
 		skb = priv->rx_skbuff[priv->skb_currx];
 
+		dma_unmap_single(&priv->dev->dev, bdp->bufPtr,
+				priv->rx_buffer_size, DMA_FROM_DEVICE);
+
 		/* We drop the frame if we failed to allocate a new buffer */
 		if (unlikely(!newskb || !(bdp->status & RXBD_LAST) ||
 				 bdp->status & RXBD_ERR)) {
@@ -1674,14 +1681,8 @@ int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit)
 			if (unlikely(!newskb))
 				newskb = skb;
 
-			if (skb) {
-				dma_unmap_single(&priv->dev->dev,
-						bdp->bufPtr,
-						priv->rx_buffer_size,
-						DMA_FROM_DEVICE);
-
+			if (skb)
 				dev_kfree_skb_any(skb);
-			}
 		} else {
 			/* Increment the number of packets */
 			dev->stats.rx_packets++;
-- 
1.5.4.GIT

