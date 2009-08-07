From: Greg Ungerer <gerg@snapgear.com>
Subject: [PATCH] fec: fix FEC driver packet transmission breakage
Date: Fri, 7 Aug 2009 13:58:18 +1000
Message-ID: <200908070358.n773wIxB015388@localhost.localdomain>
Cc: gerg@uclinux.org, s.hauer@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.securecomputing.com ([203.24.151.4]:37259 "EHLO
	cyberguard.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932359AbZHGLvg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 07:51:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fec: fix FEC driver packet transmission breakage

Commit f0b3fbeae11a526c3d308b691684589ee37c359b breaks transmission of
packets where the skb data buffer is not memory aligned according to
FEC_ALIGNMENT. It incorrectly passes to dma_sync_single() the buffer
address directly from the skb, instead of the address calculated for
use (which may be the skb address or one of the bounce buffers).

It seems there is no use converting the cpu address of the buffer to
a physical either, since dma_map_single() expects the cpu address and
will return the dma address to use in the descriptor. So remove the use
of __pa() on the buffer address as well.

This patch is against 2.6.30-rc5. This breakage is a regression over
2.6.30, which does not have this problem.

Signed-off-by: Greg Ungerer <gerg@uclinux.org>
---

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 0d2ab43..a32230b 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -285,6 +285,7 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct fec_enet_private *fep = netdev_priv(dev);
 	struct bufdesc *bdp;
+	void *bufaddr;
 	unsigned short	status;
 	unsigned long flags;
 
@@ -312,7 +313,7 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	status &= ~BD_ENET_TX_STATS;
 
 	/* Set buffer length and buffer pointer */
-	bdp->cbd_bufaddr = __pa(skb->data);
+	bufaddr = skb->data;
 	bdp->cbd_datlen = skb->len;
 
 	/*
@@ -320,11 +321,11 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * 4-byte boundaries. Use bounce buffers to copy data
 	 * and get it aligned. Ugh.
 	 */
-	if (bdp->cbd_bufaddr & FEC_ALIGNMENT) {
+	if (((unsigned long) bufaddr) & FEC_ALIGNMENT) {
 		unsigned int index;
 		index = bdp - fep->tx_bd_base;
 		memcpy(fep->tx_bounce[index], (void *)skb->data, skb->len);
-		bdp->cbd_bufaddr = __pa(fep->tx_bounce[index]);
+		bufaddr = fep->tx_bounce[index];
 	}
 
 	/* Save skb pointer */
@@ -336,7 +337,7 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Push the data cache so the CPM does not get stale memory
 	 * data.
 	 */
-	bdp->cbd_bufaddr = dma_map_single(&dev->dev, skb->data,
+	bdp->cbd_bufaddr = dma_map_single(&dev->dev, bufaddr,
 			FEC_ENET_TX_FRSIZE, DMA_TO_DEVICE);
 
 	/* Send it on its way.  Tell FEC it's ready, interrupt when done,
