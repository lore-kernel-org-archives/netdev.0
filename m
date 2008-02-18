From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2.6.25] gianfar: don't pass NULL dev ptr to DMA ops
Date: Mon, 18 Feb 2008 17:24:30 -0600
Message-ID: <1203377070-19870-1-git-send-email-afleming@freescale.com>
Cc: Becky Bruce <bgill@freescale.com>,
	Becky Bruce <becky.bruce@freescale.com>
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:40591 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755031AbYBRXYu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2008 18:24:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Becky Bruce <bgill@freescale.com>

Change all dma op invocations in gianfar.c to actually pass in the
device pointer.  Currently, the value is ignored, but it will be
used going forward as we implement archdata for 32-bit powerpc.

Signed-off-by: Becky Bruce <becky.bruce@freescale.com>
Acked-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/gianfar.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 0431e9e..9a5160b 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -605,7 +605,7 @@ void stop_gfar(struct net_device *dev)
 
 	free_skb_resources(priv);
 
-	dma_free_coherent(NULL,
+	dma_free_coherent(&dev->dev,
 			sizeof(struct txbd8)*priv->tx_ring_size
 			+ sizeof(struct rxbd8)*priv->rx_ring_size,
 			priv->tx_bd_base,
@@ -626,7 +626,7 @@ static void free_skb_resources(struct gfar_private *priv)
 	for (i = 0; i < priv->tx_ring_size; i++) {
 
 		if (priv->tx_skbuff[i]) {
-			dma_unmap_single(NULL, txbdp->bufPtr,
+			dma_unmap_single(&priv->dev->dev, txbdp->bufPtr,
 					txbdp->length,
 					DMA_TO_DEVICE);
 			dev_kfree_skb_any(priv->tx_skbuff[i]);
@@ -643,7 +643,7 @@ static void free_skb_resources(struct gfar_private *priv)
 	if(priv->rx_skbuff != NULL) {
 		for (i = 0; i < priv->rx_ring_size; i++) {
 			if (priv->rx_skbuff[i]) {
-				dma_unmap_single(NULL, rxbdp->bufPtr,
+				dma_unmap_single(&priv->dev->dev, rxbdp->bufPtr,
 						priv->rx_buffer_size,
 						DMA_FROM_DEVICE);
 
@@ -708,7 +708,7 @@ int startup_gfar(struct net_device *dev)
 	gfar_write(&regs->imask, IMASK_INIT_CLEAR);
 
 	/* Allocate memory for the buffer descriptors */
-	vaddr = (unsigned long) dma_alloc_coherent(NULL,
+	vaddr = (unsigned long) dma_alloc_coherent(&dev->dev,
 			sizeof (struct txbd8) * priv->tx_ring_size +
 			sizeof (struct rxbd8) * priv->rx_ring_size,
 			&addr, GFP_KERNEL);
@@ -919,7 +919,7 @@ err_irq_fail:
 rx_skb_fail:
 	free_skb_resources(priv);
 tx_skb_fail:
-	dma_free_coherent(NULL,
+	dma_free_coherent(&dev->dev,
 			sizeof(struct txbd8)*priv->tx_ring_size
 			+ sizeof(struct rxbd8)*priv->rx_ring_size,
 			priv->tx_bd_base,
@@ -1053,7 +1053,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* Set buffer length and pointer */
 	txbdp->length = skb->len;
-	txbdp->bufPtr = dma_map_single(NULL, skb->data,
+	txbdp->bufPtr = dma_map_single(&dev->dev, skb->data,
 			skb->len, DMA_TO_DEVICE);
 
 	/* Save the skb pointer so we can free it later */
@@ -1332,7 +1332,7 @@ struct sk_buff * gfar_new_skb(struct net_device *dev, struct rxbd8 *bdp)
 	 */
 	skb_reserve(skb, alignamount);
 
-	bdp->bufPtr = dma_map_single(NULL, skb->data,
+	bdp->bufPtr = dma_map_single(&dev->dev, skb->data,
 			priv->rx_buffer_size, DMA_FROM_DEVICE);
 
 	bdp->length = 0;
-- 
1.5.4.23.gef5b9

