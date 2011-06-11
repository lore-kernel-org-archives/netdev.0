From: Mika Westerberg <mika.westerberg@iki.fi>
Subject: [PATCH v3 2/5] net: ep93xx_eth: pass struct device to DMA API functions
Date: Sat, 11 Jun 2011 21:39:55 +0300
Message-ID: <b69ec17080017f62baaa94bc1d21960022dc7381.1307816881.git.mika.westerberg@iki.fi>
References: <a908e30a30247a07b2352002742f291d1df0eb18.1307816881.git.mika.westerberg@iki.fi>
Cc: linux-arm-kernel@lists.infradead.org, hsweeten@visionengravers.com,
	rmallon@gmail.com, davem@davemloft.net, ynezz@true.cz,
	Mika Westerberg <mika.westerberg@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:47303 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752489Ab1FKSmi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2011 14:42:38 -0400
Received: by mail-ey0-f174.google.com with SMTP id 24so1226264eyx.19
        for <netdev@vger.kernel.org>; Sat, 11 Jun 2011 11:42:37 -0700 (PDT)
In-Reply-To: <a908e30a30247a07b2352002742f291d1df0eb18.1307816881.git.mika.westerberg@iki.fi>
In-Reply-To: <a908e30a30247a07b2352002742f291d1df0eb18.1307816881.git.mika.westerberg@iki.fi>
References: <a908e30a30247a07b2352002742f291d1df0eb18.1307816881.git.mika.westerberg@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We shouldn't use NULL for any DMA API functions, unless we are dealing with
ISA or EISA device. So pass correct struct dev pointer to these functions.

Signed-off-by: Mika Westerberg <mika.westerberg@iki.fi>
---
I modified this patch according to Hartley's comments; There is no separate
dma_dev pointer in ep93xx_priv structure but we use SET_NETDEV_DEV() to store
pointer to the platform device which we use as the device for DMA API.

Because this patch is different than the original one, I dropped all the acks
and tested-by's.

 drivers/net/arm/ep93xx_eth.c |   23 +++++++++++++----------
 1 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/drivers/net/arm/ep93xx_eth.c b/drivers/net/arm/ep93xx_eth.c
index 5a77001..f65dfb6 100644
--- a/drivers/net/arm/ep93xx_eth.c
+++ b/drivers/net/arm/ep93xx_eth.c
@@ -284,7 +284,7 @@ static int ep93xx_rx(struct net_device *dev, int processed, int budget)
 		skb = dev_alloc_skb(length + 2);
 		if (likely(skb != NULL)) {
 			skb_reserve(skb, 2);
-			dma_sync_single_for_cpu(NULL, ep->descs->rdesc[entry].buf_addr,
+			dma_sync_single_for_cpu(dev->dev.parent, ep->descs->rdesc[entry].buf_addr,
 						length, DMA_FROM_DEVICE);
 			skb_copy_to_linear_data(skb, ep->rx_buf[entry], length);
 			skb_put(skb, length);
@@ -362,7 +362,7 @@ static int ep93xx_xmit(struct sk_buff *skb, struct net_device *dev)
 	ep->descs->tdesc[entry].tdesc1 =
 		TDESC1_EOF | (entry << 16) | (skb->len & 0xfff);
 	skb_copy_and_csum_dev(skb, ep->tx_buf[entry]);
-	dma_sync_single_for_cpu(NULL, ep->descs->tdesc[entry].buf_addr,
+	dma_sync_single_for_cpu(dev->dev.parent, ep->descs->tdesc[entry].buf_addr,
 				skb->len, DMA_TO_DEVICE);
 	dev_kfree_skb(skb);
 
@@ -457,6 +457,7 @@ static irqreturn_t ep93xx_irq(int irq, void *dev_id)
 
 static void ep93xx_free_buffers(struct ep93xx_priv *ep)
 {
+	struct device *dev = ep->dev->dev.parent;
 	int i;
 
 	for (i = 0; i < RX_QUEUE_ENTRIES; i += 2) {
@@ -464,7 +465,7 @@ static void ep93xx_free_buffers(struct ep93xx_priv *ep)
 
 		d = ep->descs->rdesc[i].buf_addr;
 		if (d)
-			dma_unmap_single(NULL, d, PAGE_SIZE, DMA_FROM_DEVICE);
+			dma_unmap_single(dev, d, PAGE_SIZE, DMA_FROM_DEVICE);
 
 		if (ep->rx_buf[i] != NULL)
 			free_page((unsigned long)ep->rx_buf[i]);
@@ -475,13 +476,13 @@ static void ep93xx_free_buffers(struct ep93xx_priv *ep)
 
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
 
@@ -491,9 +492,10 @@ static void ep93xx_free_buffers(struct ep93xx_priv *ep)
  */
 static int ep93xx_alloc_buffers(struct ep93xx_priv *ep)
 {
+	struct device *dev = ep->dev->dev.parent;
 	int i;
 
-	ep->descs = dma_alloc_coherent(NULL, sizeof(struct ep93xx_descs),
+	ep->descs = dma_alloc_coherent(dev, sizeof(struct ep93xx_descs),
 				&ep->descs_dma_addr, GFP_KERNEL | GFP_DMA);
 	if (ep->descs == NULL)
 		return 1;
@@ -506,8 +508,8 @@ static int ep93xx_alloc_buffers(struct ep93xx_priv *ep)
 		if (page == NULL)
 			goto err;
 
-		d = dma_map_single(NULL, page, PAGE_SIZE, DMA_FROM_DEVICE);
-		if (dma_mapping_error(NULL, d)) {
+		d = dma_map_single(dev, page, PAGE_SIZE, DMA_FROM_DEVICE);
+		if (dma_mapping_error(dev, d)) {
 			free_page((unsigned long)page);
 			goto err;
 		}
@@ -529,8 +531,8 @@ static int ep93xx_alloc_buffers(struct ep93xx_priv *ep)
 		if (page == NULL)
 			goto err;
 
-		d = dma_map_single(NULL, page, PAGE_SIZE, DMA_TO_DEVICE);
-		if (dma_mapping_error(NULL, d)) {
+		d = dma_map_single(dev, page, PAGE_SIZE, DMA_TO_DEVICE);
+		if (dma_mapping_error(dev, d)) {
 			free_page((unsigned long)page);
 			goto err;
 		}
@@ -829,6 +831,7 @@ static int ep93xx_eth_probe(struct platform_device *pdev)
 	}
 	ep = netdev_priv(dev);
 	ep->dev = dev;
+	SET_NETDEV_DEV(dev, &pdev->dev);
 	netif_napi_add(dev, &ep->napi, ep93xx_poll, 64);
 
 	platform_set_drvdata(pdev, dev);
-- 
1.7.4.4

