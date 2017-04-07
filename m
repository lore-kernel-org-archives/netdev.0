From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 09/12] ftgmac100: Split tx packet freeing from ftgmac100_tx_complete_packet()
Date: Fri,  7 Apr 2017 13:31:02 +1000
Message-ID: <20170407033105.29558-10-benh@kernel.crashing.org>
References: <20170407033105.29558-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:39159 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753520AbdDGDbf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 23:31:35 -0400
In-Reply-To: <20170407033105.29558-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This moves the packet freeing to a separate function
which is also used by ftgmac100_free_buffers() and will
be used more in the error path of fragmented sends.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 38 ++++++++++++++++++--------------
 1 file changed, 21 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 31fbb75..22edd01 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -561,13 +561,29 @@ static bool ftgmac100_tx_buf_cleanable(struct ftgmac100 *priv)
 	return priv->tx_pointer != priv->tx_clean_pointer;
 }
 
+static void ftgmac100_free_tx_packet(struct ftgmac100 *priv,
+				     unsigned int pointer,
+				     struct sk_buff *skb,
+				     struct ftgmac100_txdes *txdes)
+{
+	dma_addr_t map;
+
+	map = ftgmac100_txdes_get_dma_addr(txdes);
+
+	dma_unmap_single(priv->dev, map, skb_headlen(skb), DMA_TO_DEVICE);
+
+	dev_kfree_skb(skb);
+	priv->tx_skbs[pointer] = NULL;
+
+	ftgmac100_txdes_reset(priv, txdes);
+}
+
 static bool ftgmac100_tx_complete_packet(struct ftgmac100 *priv)
 {
 	struct net_device *netdev = priv->netdev;
 	struct ftgmac100_txdes *txdes;
-	unsigned int pointer;
 	struct sk_buff *skb;
-	dma_addr_t map;
+	unsigned int pointer;
 
 	pointer = priv->tx_clean_pointer;
 	txdes = &priv->descs->txdes[pointer];
@@ -576,17 +592,9 @@ static bool ftgmac100_tx_complete_packet(struct ftgmac100 *priv)
 		return false;
 
 	skb = priv->tx_skbs[pointer];
-	map = ftgmac100_txdes_get_dma_addr(txdes);
-
 	netdev->stats.tx_packets++;
 	netdev->stats.tx_bytes += skb->len;
-
-	dma_unmap_single(priv->dev, map, skb_headlen(skb), DMA_TO_DEVICE);
-
-	dev_kfree_skb(skb);
-	priv->tx_skbs[pointer] = NULL;
-
-	ftgmac100_txdes_reset(priv, txdes);
+	ftgmac100_free_tx_packet(priv, pointer, skb, txdes);
 
 	priv->tx_clean_pointer = ftgmac100_next_tx_pointer(pointer);
 
@@ -728,13 +736,9 @@ static void ftgmac100_free_buffers(struct ftgmac100 *priv)
 	for (i = 0; i < TX_QUEUE_ENTRIES; i++) {
 		struct ftgmac100_txdes *txdes = &priv->descs->txdes[i];
 		struct sk_buff *skb = priv->tx_skbs[i];
-		dma_addr_t map = ftgmac100_txdes_get_dma_addr(txdes);
-
-		if (!skb)
-			continue;
 
-		dma_unmap_single(priv->dev, map, skb_headlen(skb), DMA_TO_DEVICE);
-		kfree_skb(skb);
+		if (skb)
+			ftgmac100_free_tx_packet(priv, i, skb, txdes);
 	}
 }
 
-- 
2.9.3
