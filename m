From: Mika Westerberg <mika.westerberg@iki.fi>
Subject: [PATCH 1/5] net: ep93xx_eth: pass struct device to DMA API functions
Date: Thu,  2 Jun 2011 12:38:13 +0300
Message-ID: <89df467f9811b4f869513de3ada90ce7de74c6d1.1307006502.git.mika.westerberg@iki.fi>
Cc: linux-arm-kernel@lists.infradead.org, kernel@wantstofly.org,
	hsweeten@visionengravers.com, ryan@bluewatersys.com,
	Mika Westerberg <mika.westerberg@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:32967 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932771Ab1FBJkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 05:40:33 -0400
Received: by ewy4 with SMTP id 4so216035ewy.19
        for <netdev@vger.kernel.org>; Thu, 02 Jun 2011 02:40:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We shouldn't use NULL for any DMA API functions, unless we are dealing with
ISA or EISA device. So pass correct struct dev pointer to these functions.

Signed-off-by: Mika Westerberg <mika.westerberg@iki.fi>
---
 drivers/net/arm/ep93xx_eth.c |   26 ++++++++++++++++----------
 1 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/drivers/net/arm/ep93xx_eth.c b/drivers/net/arm/ep93xx_eth.c
index 5a77001..8779d3b 100644
--- a/drivers/net/arm/ep93xx_eth.c
+++ b/drivers/net/arm/ep93xx_eth.c
@@ -159,6 +159,8 @@ struct ep93xx_priv
 	void __iomem		*base_addr;
 	int			irq;
 
+	struct device		*dma_dev;
+
 	struct ep93xx_descs	*descs;
 	dma_addr_t		descs_dma_addr;
 
@@ -284,7 +286,8 @@ static int ep93xx_rx(struct net_device *dev, int processed, int budget)
 		skb = dev_alloc_skb(length + 2);
 		if (likely(skb != NULL)) {
 			skb_reserve(skb, 2);
-			dma_sync_single_for_cpu(NULL, ep->descs->rdesc[entry].buf_addr,
+			dma_sync_single_for_cpu(ep->dma_dev,
+						ep->descs->rdesc[entry].buf_addr,
 						length, DMA_FROM_DEVICE);
 			skb_copy_to_linear_data(skb, ep->rx_buf[entry], length);
 			skb_put(skb, length);
@@ -362,7 +365,7 @@ static int ep93xx_xmit(struct sk_buff *skb, struct net_device *dev)
 	ep->descs->tdesc[entry].tdesc1 =
 		TDESC1_EOF | (entry << 16) | (skb->len & 0xfff);
 	skb_copy_and_csum_dev(skb, ep->tx_buf[entry]);
-	dma_sync_single_for_cpu(NULL, ep->descs->tdesc[entry].buf_addr,
+	dma_sync_single_for_cpu(ep->dma_dev, ep->descs->tdesc[entry].buf_addr,
 				skb->len, DMA_TO_DEVICE);
 	dev_kfree_skb(skb);
 
@@ -457,6 +460,7 @@ static irqreturn_t ep93xx_irq(int irq, void *dev_id)
 
 static void ep93xx_free_buffers(struct ep93xx_priv *ep)
 {
+	struct device *dev = ep->dma_dev;
 	int i;
 
 	for (i = 0; i < RX_QUEUE_ENTRIES; i += 2) {
@@ -464,7 +468,7 @@ static void ep93xx_free_buffers(struct ep93xx_priv *ep)
 
 		d = ep->descs->rdesc[i].buf_addr;
 		if (d)
-			dma_unmap_single(NULL, d, PAGE_SIZE, DMA_FROM_DEVICE);
+			dma_unmap_single(dev, d, PAGE_SIZE, DMA_FROM_DEVICE);
 
 		if (ep->rx_buf[i] != NULL)
 			free_page((unsigned long)ep->rx_buf[i]);
@@ -475,13 +479,13 @@ static void ep93xx_free_buffers(struct ep93xx_priv *ep)
 
 		d = ep->descs->tdesc[i].buf_addr;
 		if (d)
-			dma_unmap_single(NULL, d, PAGE_SIZE, DMA_TO_DEVICE);
+			dma_unmap_single(dev, d, PAGE_SIZE, DMA_TO_DEVICE);
 
 		if (ep->tx_buf[i] != NULL)
 			free_page((unsigned long)ep->tx_buf[i]);
 	}
 
-	dma_free_coherent(NULL, sizeof(struct ep93xx_descs), ep->descs,
+	dma_free_coherent(dev, sizeof(struct ep93xx_descs), ep->descs,
 							ep->descs_dma_addr);
 }
 
@@ -491,9 +495,10 @@ static void ep93xx_free_buffers(struct ep93xx_priv *ep)
  */
 static int ep93xx_alloc_buffers(struct ep93xx_priv *ep)
 {
+	struct device *dev = ep->dma_dev;
 	int i;
 
-	ep->descs = dma_alloc_coherent(NULL, sizeof(struct ep93xx_descs),
+	ep->descs = dma_alloc_coherent(dev, sizeof(struct ep93xx_descs),
 				&ep->descs_dma_addr, GFP_KERNEL | GFP_DMA);
 	if (ep->descs == NULL)
 		return 1;
@@ -506,8 +511,8 @@ static int ep93xx_alloc_buffers(struct ep93xx_priv *ep)
 		if (page == NULL)
 			goto err;
 
-		d = dma_map_single(NULL, page, PAGE_SIZE, DMA_FROM_DEVICE);
-		if (dma_mapping_error(NULL, d)) {
+		d = dma_map_single(dev, page, PAGE_SIZE, DMA_FROM_DEVICE);
+		if (dma_mapping_error(dev, d)) {
 			free_page((unsigned long)page);
 			goto err;
 		}
@@ -529,8 +534,8 @@ static int ep93xx_alloc_buffers(struct ep93xx_priv *ep)
 		if (page == NULL)
 			goto err;
 
-		d = dma_map_single(NULL, page, PAGE_SIZE, DMA_TO_DEVICE);
-		if (dma_mapping_error(NULL, d)) {
+		d = dma_map_single(dev, page, PAGE_SIZE, DMA_TO_DEVICE);
+		if (dma_mapping_error(dev, d)) {
 			free_page((unsigned long)page);
 			goto err;
 		}
@@ -829,6 +834,7 @@ static int ep93xx_eth_probe(struct platform_device *pdev)
 	}
 	ep = netdev_priv(dev);
 	ep->dev = dev;
+	ep->dma_dev = &pdev->dev;
 	netif_napi_add(dev, &ep->napi, ep93xx_poll, 64);
 
 	platform_set_drvdata(pdev, dev);
-- 
1.7.4.4

