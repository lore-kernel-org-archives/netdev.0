From: Mika Westerberg <mika.westerberg@iki.fi>
Subject: [PATCH v2 5/5] net: ep93xx_eth: fix DMA API violations
Date: Thu,  2 Jun 2011 21:59:38 +0300
Message-ID: <a0d2d13698ea27f671a077c9f47b7ce855054a47.1307040443.git.mika.westerberg@iki.fi>
References: <f20d8fe52f823e7e65423720c53f2935d3e08967.1307040443.git.mika.westerberg@iki.fi>
Cc: linux-arm-kernel@lists.infradead.org, kernel@wantstofly.org,
	hsweeten@visionengravers.com, ryan@bluewatersys.com,
	Mika Westerberg <mika.westerberg@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:61050 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753372Ab1FBTCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 15:02:00 -0400
Received: by mail-ew0-f46.google.com with SMTP id 4so414248ewy.19
        for <netdev@vger.kernel.org>; Thu, 02 Jun 2011 12:02:00 -0700 (PDT)
In-Reply-To: <f20d8fe52f823e7e65423720c53f2935d3e08967.1307040443.git.mika.westerberg@iki.fi>
In-Reply-To: <f20d8fe52f823e7e65423720c53f2935d3e08967.1307040443.git.mika.westerberg@iki.fi>
References: <f20d8fe52f823e7e65423720c53f2935d3e08967.1307040443.git.mika.westerberg@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Russell King said:
>
> So, to summarize what its doing:
>
> 1. It allocates buffers for rx and tx.
> 2. It maps them with dma_map_single().
>       This transfers ownership of the buffer to the DMA device.
> 3. In ep93xx_xmit,
> 3a. It copies the data into the buffer with skb_copy_and_csum_dev()
>       This violates the DMA buffer ownership rules - the CPU should
>       not be writing to this buffer while it is (in principle) owned
>       by the DMA device.
> 3b. It then calls dma_sync_single_for_cpu() for the buffer.
>       This transfers ownership of the buffer to the CPU, which surely
>       is the wrong direction.
> 4. In ep93xx_rx,
> 4a. It calls dma_sync_single_for_cpu() for the buffer.
>       This at least transfers the DMA buffer ownership to the CPU
>       before the CPU reads the buffer
> 4b. It then uses skb_copy_to_linear_data() to copy the data out.
>       At no point does it transfer ownership back to the DMA device.
> 5. When the driver is removed, it dma_unmap_single()'s the buffer.
>       This transfers ownership of the buffer to the CPU.
> 6. It frees the buffer.
>
> While it may work on ep93xx, it's not respecting the DMA API rules,
> and with DMA debugging enabled it will probably encounter quite a few
> warnings.

This patch fixes these violations.

Signed-off-by: Mika Westerberg <mika.westerberg@iki.fi>
Acked-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/arm/ep93xx_eth.c |   19 +++++++++++++------
 1 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/drivers/net/arm/ep93xx_eth.c b/drivers/net/arm/ep93xx_eth.c
index 56b51a1..c2a7847 100644
--- a/drivers/net/arm/ep93xx_eth.c
+++ b/drivers/net/arm/ep93xx_eth.c
@@ -285,11 +285,14 @@ static int ep93xx_rx(struct net_device *dev, int processed, int budget)
 
 		skb = dev_alloc_skb(length + 2);
 		if (likely(skb != NULL)) {
+			struct ep93xx_rdesc *rxd = &ep->descs->rdesc[entry];
 			skb_reserve(skb, 2);
-			dma_sync_single_for_cpu(ep->dma_dev,
-						ep->descs->rdesc[entry].buf_addr,
+
+			dma_sync_single_for_cpu(ep->dma_dev, rxd->buf_addr,
 						length, DMA_FROM_DEVICE);
 			skb_copy_to_linear_data(skb, ep->rx_buf[entry], length);
+			dma_sync_single_for_device(ep->dma_dev, rxd->buf_addr,
+						length, DMA_FROM_DEVICE);
 			skb_put(skb, length);
 			skb->protocol = eth_type_trans(skb, dev);
 
@@ -351,6 +354,7 @@ poll_some_more:
 static int ep93xx_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ep93xx_priv *ep = netdev_priv(dev);
+	struct ep93xx_tdesc *txd;
 	int entry;
 
 	if (unlikely(skb->len > MAX_PKT_SIZE)) {
@@ -362,11 +366,14 @@ static int ep93xx_xmit(struct sk_buff *skb, struct net_device *dev)
 	entry = ep->tx_pointer;
 	ep->tx_pointer = (ep->tx_pointer + 1) & (TX_QUEUE_ENTRIES - 1);
 
-	ep->descs->tdesc[entry].tdesc1 =
-		TDESC1_EOF | (entry << 16) | (skb->len & 0xfff);
+	txd = &ep->descs->tdesc[entry];
+
+	txd->tdesc1 = TDESC1_EOF | (entry << 16) | (skb->len & 0xfff);
+	dma_sync_single_for_cpu(ep->dma_dev, txd->buf_addr, skb->len,
+				DMA_TO_DEVICE);
 	skb_copy_and_csum_dev(skb, ep->tx_buf[entry]);
-	dma_sync_single_for_cpu(ep->dma_dev, ep->descs->tdesc[entry].buf_addr,
-				skb->len, DMA_TO_DEVICE);
+	dma_sync_single_for_device(ep->dma_dev, txd->buf_addr, skb->len,
+				   DMA_TO_DEVICE);
 	dev_kfree_skb(skb);
 
 	spin_lock_irq(&ep->tx_pending_lock);
-- 
1.7.4.4

