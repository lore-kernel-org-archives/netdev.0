From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 07/10] ftgmac100: Directly receive into sk_buffs
Date: Thu,  6 Apr 2017 11:02:49 +1000
Message-ID: <20170406010252.29208-8-benh@kernel.crashing.org>
References: <20170406010252.29208-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:44665 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756315AbdDFBoL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Apr 2017 21:44:11 -0400
In-Reply-To: <20170406010252.29208-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current driver receive path allocates pages and stashes
them into SKB fragments. This is not particularly useful as
we don't support jumbo frames (which wouldn't be great with
the small FIFOs on all the known implementations) anyway.

It also makes us flush the caches and allocate more memory
for RX than necessary.

So set our RX buf to our max packet size instead (which we
bump to 1536 bytes to account for packets with vlan tags
etc...) like most other ethernet drivers.

Then allocate skbs when populating the receive ring and DMA
directly into them.

This simplifies the RX path further.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 142 ++++++++++++-------------------
 1 file changed, 56 insertions(+), 86 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 95d46db..86bda0a 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -41,8 +41,8 @@
 #define RX_QUEUE_ENTRIES	256	/* must be power of 2 */
 #define TX_QUEUE_ENTRIES	512	/* must be power of 2 */
 
-#define MAX_PKT_SIZE		1518
-#define RX_BUF_SIZE		PAGE_SIZE	/* must be smaller than 0x3fff */
+#define MAX_PKT_SIZE		1536
+#define RX_BUF_SIZE		MAX_PKT_SIZE	/* must be smaller than 0x3fff */
 
 struct ftgmac100_descs {
 	struct ftgmac100_rxdes rxdes[RX_QUEUE_ENTRIES];
@@ -58,7 +58,7 @@ struct ftgmac100 {
 	dma_addr_t descs_dma_addr;
 
 	/* Rx ring */
-	struct page *rx_pages[RX_QUEUE_ENTRIES];
+	struct sk_buff *rx_skbs[RX_QUEUE_ENTRIES];
 	unsigned int rx_pointer;
 	u32 rxdes0_edorr_mask;
 
@@ -291,13 +291,6 @@ static bool ftgmac100_rxdes_packet_ready(struct ftgmac100_rxdes *rxdes)
 	return rxdes->rxdes0 & cpu_to_le32(FTGMAC100_RXDES0_RXPKT_RDY);
 }
 
-static void ftgmac100_rxdes_set_dma_own(const struct ftgmac100 *priv,
-					struct ftgmac100_rxdes *rxdes)
-{
-	/* clear status bits */
-	rxdes->rxdes0 &= cpu_to_le32(priv->rxdes0_edorr_mask);
-}
-
 #define RXDES0_ANY_ERROR		( \
 	FTGMAC100_RXDES0_RX_ERR		| \
 	FTGMAC100_RXDES0_CRC_ERR	| \
@@ -369,58 +362,45 @@ static inline bool ftgmac100_rxdes_csum_err(struct ftgmac100_rxdes *rxdes)
 					      FTGMAC100_RXDES1_IP_CHKSUM_ERR));
 }
 
-static inline struct page **ftgmac100_rxdes_page_slot(struct ftgmac100 *priv,
-						      struct ftgmac100_rxdes *rxdes)
-{
-	return &priv->rx_pages[rxdes - priv->descs->rxdes];
-}
-
-/*
- * rxdes2 is not used by hardware. We use it to keep track of page.
- * Since hardware does not touch it, we can skip cpu_to_le32()/le32_to_cpu().
- */
-static void ftgmac100_rxdes_set_page(struct ftgmac100 *priv,
-				     struct ftgmac100_rxdes *rxdes,
-				     struct page *page)
-{
-	*ftgmac100_rxdes_page_slot(priv, rxdes) = page;
-}
-
-static struct page *ftgmac100_rxdes_get_page(struct ftgmac100 *priv,
-					     struct ftgmac100_rxdes *rxdes)
-{
-	return *ftgmac100_rxdes_page_slot(priv, rxdes);
-}
-
-static int ftgmac100_alloc_rx_page(struct ftgmac100 *priv,
-				   struct ftgmac100_rxdes *rxdes, gfp_t gfp)
+static int ftgmac100_alloc_rx_buf(struct ftgmac100 *priv, unsigned int entry,
+				  struct ftgmac100_rxdes *rxdes, gfp_t gfp)
 {
 	struct net_device *netdev = priv->netdev;
-	struct page *page;
+	struct sk_buff *skb;
 	dma_addr_t map;
 	int err;
 
-	page = alloc_page(gfp);
-	if (!page) {
+	skb = netdev_alloc_skb_ip_align(netdev, RX_BUF_SIZE);
+	if (unlikely(!skb)) {
 		if (net_ratelimit())
-			netdev_err(netdev, "failed to allocate rx page\n");
+			netdev_warn(netdev, "failed to allocate rx skb\n");
 		err = -ENOMEM;
 		map = priv->rx_scratch_dma;
+	} else {
+		map = dma_map_single(priv->dev, skb->data, RX_BUF_SIZE,
+				     DMA_FROM_DEVICE);
+		if (unlikely(dma_mapping_error(priv->dev, map))) {
+			if (net_ratelimit())
+				netdev_err(netdev, "failed to map rx page\n");
+			dev_kfree_skb_any(skb);
+			map = priv->rx_scratch_dma;
+			skb = NULL;
+			err = -ENOMEM;
+		}
 	}
 
-	map = dma_map_page(priv->dev, page, 0, RX_BUF_SIZE, DMA_FROM_DEVICE);
-	if (unlikely(dma_mapping_error(priv->dev, map))) {
-		if (net_ratelimit())
-			netdev_err(netdev, "failed to map rx page\n");
-		__free_page(page);
-		err = -ENOMEM;
-		map = priv->rx_scratch_dma;
-		page = NULL;
-	}
+	/* Store skb */
+	priv->rx_skbs[entry] = skb;
 
-	ftgmac100_rxdes_set_page(priv, rxdes, page);
+	/* Store DMA address into RX desc */
 	ftgmac100_rxdes_set_dma_addr(rxdes, map);
-	ftgmac100_rxdes_set_dma_own(priv, rxdes);
+
+	/* Ensure the above is ordered vs clearing the OWN bit */
+	dma_wmb();
+
+	/* Clean rxdes0 (which resets own bit) */
+	rxdes->rxdes0 &= cpu_to_le32(priv->rxdes0_edorr_mask);
+
 	return 0;
 }
 
@@ -451,7 +431,6 @@ static bool ftgmac100_rx_packet(struct ftgmac100 *priv, int *processed)
 	struct net_device *netdev = priv->netdev;
 	struct ftgmac100_rxdes *rxdes;
 	struct sk_buff *skb;
-	struct page *page;
 	unsigned int pointer, size;
 	dma_addr_t map;
 
@@ -474,20 +453,12 @@ static bool ftgmac100_rx_packet(struct ftgmac100 *priv, int *processed)
 		goto drop;
 	}
 
-	/* If the packet had no buffer (failed to allocate earlier)
+	/* If the packet had no skb (failed to allocate earlier)
 	 * then try to allocate one and skip
 	 */
-	page = ftgmac100_rxdes_get_page(priv, rxdes);
-	if (!page) {
-		ftgmac100_alloc_rx_page(priv, rxdes, GFP_ATOMIC);
-		goto drop;
-	}
-
-	/* start processing */
-	skb = netdev_alloc_skb_ip_align(netdev, 128);
-	if (unlikely(!skb)) {
-		if (net_ratelimit())
-			netdev_err(netdev, "rx skb alloc failed\n");
+	skb = priv->rx_skbs[pointer];
+	if (!unlikely(skb)) {
+		ftgmac100_alloc_rx_buf(priv, pointer, rxdes, GFP_ATOMIC);
 		goto drop;
 	}
 
@@ -512,33 +483,31 @@ static bool ftgmac100_rx_packet(struct ftgmac100 *priv, int *processed)
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
 
-	map = ftgmac100_rxdes_get_dma_addr(rxdes);
-
-	dma_unmap_page(priv->dev, map, RX_BUF_SIZE, DMA_FROM_DEVICE);
-
+	/* Grab received size annd transfer to skb */
 	size = ftgmac100_rxdes_data_length(rxdes);
-	skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags, page, 0, size);
+	skb_put(skb, size);
 
-	skb->len += size;
-	skb->data_len += size;
-	skb->truesize += PAGE_SIZE;
+	/* Tear down DMA mapping, do necessary cache management */
+	map = ftgmac100_rxdes_get_dma_addr(rxdes);
+#if defined(CONFIG_ARM) && !defined(CONFIG_ARM_DMA_USE_IOMMU)
+	/* When we don't have an iommu, we can save cycles by not
+	 * invalidating the cache for the part of the packet that
+	 * wasn't received.
+	 */
+	dma_unmap_single(priv->dev, map, size, DMA_FROM_DEVICE);
+#else
+	dma_unmap_single(priv->dev, map, RX_BUF_SIZE, DMA_FROM_DEVICE);
+#endif
 
-	ftgmac100_alloc_rx_page(priv, rxdes, GFP_ATOMIC);
 
+	/* Resplenish rx ring */
+	ftgmac100_alloc_rx_buf(priv, pointer, rxdes, GFP_ATOMIC);
 	priv->rx_pointer = ftgmac100_next_rx_pointer(pointer);
 
-	/* Small frames are copied into linear part of skb to free one page */
-	if (skb->len <= 128) {
-		skb->truesize -= PAGE_SIZE;
-		__pskb_pull_tail(skb, skb->len);
-	} else {
-		/* We pull the minimum amount into linear part */
-		__pskb_pull_tail(skb, ETH_HLEN);
-	}
 	skb->protocol = eth_type_trans(skb, netdev);
 
 	netdev->stats.rx_packets++;
-	netdev->stats.rx_bytes += skb->len;
+	netdev->stats.rx_bytes += size;
 
 	/* push packet to protocol stack */
 	if (skb->ip_summed == CHECKSUM_NONE)
@@ -772,14 +741,15 @@ static void ftgmac100_free_buffers(struct ftgmac100 *priv)
 	/* Free all RX buffers */
 	for (i = 0; i < RX_QUEUE_ENTRIES; i++) {
 		struct ftgmac100_rxdes *rxdes = &priv->descs->rxdes[i];
-		struct page *page = ftgmac100_rxdes_get_page(priv, rxdes);
+		struct sk_buff *skb = priv->rx_skbs[i];
 		dma_addr_t map = ftgmac100_rxdes_get_dma_addr(rxdes);
 
-		if (!page)
+		if (!skb)
 			continue;
 
-		dma_unmap_page(priv->dev, map, RX_BUF_SIZE, DMA_FROM_DEVICE);
-		__free_page(page);
+		priv->rx_skbs[i] = NULL;
+		dma_unmap_single(priv->dev, map, RX_BUF_SIZE, DMA_FROM_DEVICE);
+		dev_kfree_skb_any(skb);
 	}
 
 	/* Free all TX buffers */
@@ -854,7 +824,7 @@ static int ftgmac100_alloc_rx_buffers(struct ftgmac100 *priv)
 	for (i = 0; i < RX_QUEUE_ENTRIES; i++) {
 		struct ftgmac100_rxdes *rxdes = &priv->descs->rxdes[i];
 
-		if (ftgmac100_alloc_rx_page(priv, rxdes, GFP_KERNEL))
+		if (ftgmac100_alloc_rx_buf(priv, i, rxdes, GFP_KERNEL))
 			return -ENOMEM;
 	}
 	return 0;
-- 
2.9.3
