From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 03/10] ftgmac100: Use a scratch buffer for failed RX allocations
Date: Thu,  6 Apr 2017 11:02:45 +1000
Message-ID: <20170406010252.29208-4-benh@kernel.crashing.org>
References: <20170406010252.29208-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:37909 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756271AbdDFBDM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Apr 2017 21:03:12 -0400
In-Reply-To: <20170406010252.29208-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can occasionally fail to allocate new RX buffers at
runtime or when starting the driver. At the moment the
latter just fails to open which is fine but the former
leaves stale DMA pointers in the ring.

Instead, use a scratch page and have all RX ring descriptors
point to it by default unless a proper buffer can be allocated.

It will help later on when re-initializing the whole ring
at runtime on link changes since there is no clean failure
path there unlike open().

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 42 +++++++++++++++++++++++++++++---
 1 file changed, 38 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index ee73a57..a03cc03 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -69,6 +69,10 @@ struct ftgmac100 {
 	u32 txdes0_edotr_mask;
 	spinlock_t tx_lock;
 
+	/* Scratch page to use when rx skb alloc fails */
+	void *rx_scratch;
+	dma_addr_t rx_scratch_dma;
+
 	/* Component structures */
 	struct net_device *netdev;
 	struct device *dev;
@@ -402,12 +406,14 @@ static int ftgmac100_alloc_rx_page(struct ftgmac100 *priv,
 	struct net_device *netdev = priv->netdev;
 	struct page *page;
 	dma_addr_t map;
+	int err;
 
 	page = alloc_page(gfp);
 	if (!page) {
 		if (net_ratelimit())
 			netdev_err(netdev, "failed to allocate rx page\n");
-		return -ENOMEM;
+		err = -ENOMEM;
+		map = priv->rx_scratch_dma;
 	}
 
 	map = dma_map_page(priv->dev, page, 0, RX_BUF_SIZE, DMA_FROM_DEVICE);
@@ -415,7 +421,9 @@ static int ftgmac100_alloc_rx_page(struct ftgmac100 *priv,
 		if (net_ratelimit())
 			netdev_err(netdev, "failed to map rx page\n");
 		__free_page(page);
-		return -ENOMEM;
+		err = -ENOMEM;
+		map = priv->rx_scratch_dma;
+		page = NULL;
 	}
 
 	ftgmac100_rxdes_set_page(priv, rxdes, page);
@@ -549,6 +557,16 @@ static bool ftgmac100_rx_packet(struct ftgmac100 *priv, int *processed)
 		return true;
 	}
 
+	/* If the packet had no buffer (failed to allocate earlier)
+	 * then try to allocate one and skip
+	 */
+	page = ftgmac100_rxdes_get_page(priv, rxdes);
+	if (!page) {
+		ftgmac100_alloc_rx_page(priv, rxdes, GFP_ATOMIC);
+		ftgmac100_rx_pointer_advance(priv);
+		return true;
+	}
+
 	/* start processing */
 	skb = netdev_alloc_skb_ip_align(netdev, 128);
 	if (unlikely(!skb)) {
@@ -852,6 +870,11 @@ static void ftgmac100_free_rings(struct ftgmac100 *priv)
 	if (priv->descs)
 		dma_free_coherent(priv->dev, sizeof(struct ftgmac100_descs),
 				  priv->descs, priv->descs_dma_addr);
+
+	/* Free scratch packet buffer */
+	if (priv->rx_scratch)
+		dma_free_coherent(priv->dev, RX_BUF_SIZE,
+				  priv->rx_scratch, priv->rx_scratch_dma);
 }
 
 static int ftgmac100_alloc_rings(struct ftgmac100 *priv)
@@ -863,6 +886,14 @@ static int ftgmac100_alloc_rings(struct ftgmac100 *priv)
 	if (!priv->descs)
 		return -ENOMEM;
 
+	/* Allocate scratch packet buffer */
+	priv->rx_scratch = dma_alloc_coherent(priv->dev,
+					      RX_BUF_SIZE,
+					      &priv->rx_scratch_dma,
+					      GFP_KERNEL);
+	if (!priv->rx_scratch)
+		return -ENOMEM;
+
 	return 0;
 }
 
@@ -871,8 +902,11 @@ static void ftgmac100_init_rings(struct ftgmac100 *priv)
 	int i;
 
 	/* Initialize RX ring */
-	for (i = 0; i < RX_QUEUE_ENTRIES; i++)
-		priv->descs->rxdes[i].rxdes0 = 0;
+	for (i = 0; i < RX_QUEUE_ENTRIES; i++) {
+		struct ftgmac100_rxdes *rxdes = &priv->descs->rxdes[i];
+		ftgmac100_rxdes_set_dma_addr(rxdes, priv->rx_scratch_dma);
+		rxdes->rxdes0 = 0;
+	}
 	ftgmac100_rxdes_set_end_of_ring(priv, &priv->descs->rxdes[i - 1]);
 
 	/* Initialize TX ring */
-- 
2.9.3
