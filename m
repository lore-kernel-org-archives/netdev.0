From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH v2 06/13] ftgmac100: Split ring alloc, init and rx buffer alloc
Date: Wed,  5 Apr 2017 12:28:46 +1000
Message-ID: <20170405022853.8238-7-benh@kernel.crashing.org>
References: <20170405022853.8238-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:48198 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751885AbdDECaC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Apr 2017 22:30:02 -0400
In-Reply-To: <20170405022853.8238-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, a single function is used to allocate the rings
themselves, initialize them, populate the rx ring, and
allocate the rx buffers. The same happens on free.

This splits them into separate functions. This will be
useful when properly implementing re-initialization on
link changes and error handling when the rings will be
repopulated but not freed.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 68 ++++++++++++++++++++++----------
 1 file changed, 47 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index cc6e971..0d0576f 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -792,6 +792,7 @@ static void ftgmac100_free_buffers(struct ftgmac100 *priv)
 {
 	int i;
 
+	/* Free all RX buffers */
 	for (i = 0; i < RX_QUEUE_ENTRIES; i++) {
 		struct ftgmac100_rxdes *rxdes = &priv->descs->rxdes[i];
 		struct page *page = ftgmac100_rxdes_get_page(priv, rxdes);
@@ -804,6 +805,7 @@ static void ftgmac100_free_buffers(struct ftgmac100 *priv)
 		__free_page(page);
 	}
 
+	/* Free all TX buffers */
 	for (i = 0; i < TX_QUEUE_ENTRIES; i++) {
 		struct ftgmac100_txdes *txdes = &priv->descs->txdes[i];
 		struct sk_buff *skb = ftgmac100_txdes_get_skb(txdes);
@@ -815,40 +817,54 @@ static void ftgmac100_free_buffers(struct ftgmac100 *priv)
 		dma_unmap_single(priv->dev, map, skb_headlen(skb), DMA_TO_DEVICE);
 		kfree_skb(skb);
 	}
-
-	dma_free_coherent(priv->dev, sizeof(struct ftgmac100_descs),
-			  priv->descs, priv->descs_dma_addr);
 }
 
-static int ftgmac100_alloc_buffers(struct ftgmac100 *priv)
+static void ftgmac100_free_rings(struct ftgmac100 *priv)
 {
-	int i;
+	/* Free descriptors */
+	if (priv->descs)
+		dma_free_coherent(priv->dev, sizeof(struct ftgmac100_descs),
+				  priv->descs, priv->descs_dma_addr);
+}
 
+static int ftgmac100_alloc_rings(struct ftgmac100 *priv)
+{
+	/* Allocate descriptors */
 	priv->descs = dma_zalloc_coherent(priv->dev,
 					  sizeof(struct ftgmac100_descs),
 					  &priv->descs_dma_addr, GFP_KERNEL);
 	if (!priv->descs)
 		return -ENOMEM;
 
-	/* initialize RX ring */
-	ftgmac100_rxdes_set_end_of_ring(priv,
-					&priv->descs->rxdes[RX_QUEUE_ENTRIES - 1]);
+	return 0;
+}
+
+static void ftgmac100_init_rings(struct ftgmac100 *priv)
+{
+	int i;
+
+	/* Initialize RX ring */
+	for (i = 0; i < RX_QUEUE_ENTRIES; i++)
+		priv->descs->rxdes[i].rxdes0 = 0;
+	ftgmac100_rxdes_set_end_of_ring(priv, &priv->descs->rxdes[i - 1]);
+
+	/* Initialize TX ring */
+	for (i = 0; i < TX_QUEUE_ENTRIES; i++)
+		priv->descs->txdes[i].txdes0 = 0;
+	ftgmac100_txdes_set_end_of_ring(priv, &priv->descs->txdes[i -1]);
+}
+
+static int ftgmac100_alloc_rx_buffers(struct ftgmac100 *priv)
+{
+	int i;
 
 	for (i = 0; i < RX_QUEUE_ENTRIES; i++) {
 		struct ftgmac100_rxdes *rxdes = &priv->descs->rxdes[i];
 
 		if (ftgmac100_alloc_rx_page(priv, rxdes, GFP_KERNEL))
-			goto err;
+			return -ENOMEM;
 	}
-
-	/* initialize TX ring */
-	ftgmac100_txdes_set_end_of_ring(priv,
-					&priv->descs->txdes[TX_QUEUE_ENTRIES - 1]);
 	return 0;
-
-err:
-	ftgmac100_free_buffers(priv);
-	return -ENOMEM;
 }
 
 static void ftgmac100_adjust_link(struct net_device *netdev)
@@ -1099,12 +1115,20 @@ static int ftgmac100_open(struct net_device *netdev)
 	unsigned int status;
 	int err;
 
-	err = ftgmac100_alloc_buffers(priv);
+	/* Allocate ring buffers  */
+	err = ftgmac100_alloc_rings(priv);
 	if (err) {
-		netdev_err(netdev, "failed to allocate buffers\n");
-		goto err_alloc;
+		netdev_err(netdev, "Failed to allocate descriptors\n");
+		return err;
 	}
 
+	/* Initialize the rings */
+	ftgmac100_init_rings(priv);
+
+	/* Allocate receive buffers */
+	if (ftgmac100_alloc_rx_buffers(priv))
+		goto err_alloc;
+
 	err = request_irq(netdev->irq, ftgmac100_interrupt, 0, netdev->name, netdev);
 	if (err) {
 		netdev_err(netdev, "failed to request irq %d\n", netdev->irq);
@@ -1168,8 +1192,9 @@ static int ftgmac100_open(struct net_device *netdev)
 err_hw:
 	free_irq(netdev->irq, netdev);
 err_irq:
-	ftgmac100_free_buffers(priv);
 err_alloc:
+	ftgmac100_free_buffers(priv);
+	ftgmac100_free_rings(priv);
 	return err;
 }
 
@@ -1190,6 +1215,7 @@ static int ftgmac100_stop(struct net_device *netdev)
 	ftgmac100_stop_hw(priv);
 	free_irq(netdev->irq, netdev);
 	ftgmac100_free_buffers(priv);
+	ftgmac100_free_rings(priv);
 
 	return 0;
 }
-- 
2.9.3
