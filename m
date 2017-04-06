From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 01/10] ftgmac100: Move ftgmac100_alloc_rx_page() before its users
Date: Thu,  6 Apr 2017 11:02:43 +1000
Message-ID: <20170406010252.29208-2-benh@kernel.crashing.org>
References: <20170406010252.29208-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:37907 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756271AbdDFBDJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Apr 2017 21:03:09 -0400
In-Reply-To: <20170406010252.29208-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoids a forward declaration

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 59 +++++++++++++++-----------------
 1 file changed, 28 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 88dab5f..c77a65b 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -86,9 +86,6 @@ struct ftgmac100 {
 	bool need_mac_restart;
 };
 
-static int ftgmac100_alloc_rx_page(struct ftgmac100 *priv,
-				   struct ftgmac100_rxdes *rxdes, gfp_t gfp);
-
 static void ftgmac100_set_rx_ring_base(struct ftgmac100 *priv, dma_addr_t addr)
 {
 	iowrite32(addr, priv->base + FTGMAC100_OFFSET_RXR_BADR);
@@ -399,6 +396,34 @@ static struct page *ftgmac100_rxdes_get_page(struct ftgmac100 *priv,
 	return *ftgmac100_rxdes_page_slot(priv, rxdes);
 }
 
+static int ftgmac100_alloc_rx_page(struct ftgmac100 *priv,
+				   struct ftgmac100_rxdes *rxdes, gfp_t gfp)
+{
+	struct net_device *netdev = priv->netdev;
+	struct page *page;
+	dma_addr_t map;
+
+	page = alloc_page(gfp);
+	if (!page) {
+		if (net_ratelimit())
+			netdev_err(netdev, "failed to allocate rx page\n");
+		return -ENOMEM;
+	}
+
+	map = dma_map_page(priv->dev, page, 0, RX_BUF_SIZE, DMA_FROM_DEVICE);
+	if (unlikely(dma_mapping_error(priv->dev, map))) {
+		if (net_ratelimit())
+			netdev_err(netdev, "failed to map rx page\n");
+		__free_page(page);
+		return -ENOMEM;
+	}
+
+	ftgmac100_rxdes_set_page(priv, rxdes, page);
+	ftgmac100_rxdes_set_dma_addr(rxdes, map);
+	ftgmac100_rxdes_set_dma_own(priv, rxdes);
+	return 0;
+}
+
 static int ftgmac100_next_rx_pointer(int pointer)
 {
 	return (pointer + 1) & (RX_QUEUE_ENTRIES - 1);
@@ -791,34 +816,6 @@ static int ftgmac100_xmit(struct ftgmac100 *priv, struct sk_buff *skb,
 	return NETDEV_TX_OK;
 }
 
-static int ftgmac100_alloc_rx_page(struct ftgmac100 *priv,
-				   struct ftgmac100_rxdes *rxdes, gfp_t gfp)
-{
-	struct net_device *netdev = priv->netdev;
-	struct page *page;
-	dma_addr_t map;
-
-	page = alloc_page(gfp);
-	if (!page) {
-		if (net_ratelimit())
-			netdev_err(netdev, "failed to allocate rx page\n");
-		return -ENOMEM;
-	}
-
-	map = dma_map_page(priv->dev, page, 0, RX_BUF_SIZE, DMA_FROM_DEVICE);
-	if (unlikely(dma_mapping_error(priv->dev, map))) {
-		if (net_ratelimit())
-			netdev_err(netdev, "failed to map rx page\n");
-		__free_page(page);
-		return -ENOMEM;
-	}
-
-	ftgmac100_rxdes_set_page(priv, rxdes, page);
-	ftgmac100_rxdes_set_dma_addr(rxdes, map);
-	ftgmac100_rxdes_set_dma_own(priv, rxdes);
-	return 0;
-}
-
 static void ftgmac100_free_buffers(struct ftgmac100 *priv)
 {
 	int i;
-- 
2.9.3
