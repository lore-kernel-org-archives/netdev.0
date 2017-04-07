From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 06/12] ftgmac100: Store tx skbs in a separate array
Date: Fri,  7 Apr 2017 13:30:59 +1000
Message-ID: <20170407033105.29558-7-benh@kernel.crashing.org>
References: <20170407033105.29558-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:39162 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753740AbdDGDbn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 23:31:43 -0400
In-Reply-To: <20170407033105.29558-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rather than in the descriptor. The descriptor is mapped non-cachable
and rather slow to access.

Since to do that we need to keep track of the tx "pointer" we also
have no use of all the accesors to manipulate it, just open code
it, it's as clear and will help when adding fragmented sends.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 58 +++++++++-----------------------
 1 file changed, 15 insertions(+), 43 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 3f2172f..ff01dfb 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -544,63 +544,29 @@ static dma_addr_t ftgmac100_txdes_get_dma_addr(struct ftgmac100_txdes *txdes)
 	return le32_to_cpu(txdes->txdes3);
 }
 
-/*
- * txdes2 is not used by hardware. We use it to keep track of socket buffer.
- * Since hardware does not touch it, we can skip cpu_to_le32()/le32_to_cpu().
- */
-static void ftgmac100_txdes_set_skb(struct ftgmac100_txdes *txdes,
-				    struct sk_buff *skb)
-{
-	txdes->txdes2 = (unsigned int)skb;
-}
-
-static struct sk_buff *ftgmac100_txdes_get_skb(struct ftgmac100_txdes *txdes)
-{
-	return (struct sk_buff *)txdes->txdes2;
-}
-
 static int ftgmac100_next_tx_pointer(int pointer)
 {
 	return (pointer + 1) & (TX_QUEUE_ENTRIES - 1);
 }
 
-static void ftgmac100_tx_pointer_advance(struct ftgmac100 *priv)
-{
-	priv->tx_pointer = ftgmac100_next_tx_pointer(priv->tx_pointer);
-}
-
-static void ftgmac100_tx_clean_pointer_advance(struct ftgmac100 *priv)
-{
-	priv->tx_clean_pointer = ftgmac100_next_tx_pointer(priv->tx_clean_pointer);
-}
-
-static struct ftgmac100_txdes *ftgmac100_current_txdes(struct ftgmac100 *priv)
-{
-	return &priv->descs->txdes[priv->tx_pointer];
-}
-
-static struct ftgmac100_txdes *
-ftgmac100_current_clean_txdes(struct ftgmac100 *priv)
-{
-	return &priv->descs->txdes[priv->tx_clean_pointer];
-}
-
 static bool ftgmac100_tx_complete_packet(struct ftgmac100 *priv)
 {
 	struct net_device *netdev = priv->netdev;
 	struct ftgmac100_txdes *txdes;
+	unsigned int pointer;
 	struct sk_buff *skb;
 	dma_addr_t map;
 
 	if (priv->tx_pending == 0)
 		return false;
 
-	txdes = ftgmac100_current_clean_txdes(priv);
+	pointer = priv->tx_clean_pointer;
+	txdes = &priv->descs->txdes[pointer];
 
 	if (ftgmac100_txdes_owned_by_dma(txdes))
 		return false;
 
-	skb = ftgmac100_txdes_get_skb(txdes);
+	skb = priv->tx_skbs[pointer];
 	map = ftgmac100_txdes_get_dma_addr(txdes);
 
 	netdev->stats.tx_packets++;
@@ -609,10 +575,11 @@ static bool ftgmac100_tx_complete_packet(struct ftgmac100 *priv)
 	dma_unmap_single(priv->dev, map, skb_headlen(skb), DMA_TO_DEVICE);
 
 	dev_kfree_skb(skb);
+	priv->tx_skbs[pointer] = NULL;
 
 	ftgmac100_txdes_reset(priv, txdes);
 
-	ftgmac100_tx_clean_pointer_advance(priv);
+	priv->tx_clean_pointer = ftgmac100_next_tx_pointer(pointer);
 
 	spin_lock(&priv->tx_lock);
 	priv->tx_pending--;
@@ -634,6 +601,7 @@ static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
 	unsigned int len = (skb->len < ETH_ZLEN) ? ETH_ZLEN : skb->len;
 	struct ftgmac100 *priv = netdev_priv(netdev);
 	struct ftgmac100_txdes *txdes;
+	unsigned int pointer;
 	dma_addr_t map;
 
 	/* The HW doesn't pad small frames */
@@ -657,11 +625,12 @@ static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
 		goto drop;
 	}
 
-	txdes = ftgmac100_current_txdes(priv);
-	ftgmac100_tx_pointer_advance(priv);
+	/* Grab the next free tx descriptor */
+	pointer = priv->tx_pointer;
+	txdes = &priv->descs->txdes[pointer];
 
 	/* setup TX descriptor */
-	ftgmac100_txdes_set_skb(txdes, skb);
+	priv->tx_skbs[pointer] = skb;
 	ftgmac100_txdes_set_dma_addr(txdes, map);
 	ftgmac100_txdes_set_buffer_size(txdes, len);
 
@@ -682,6 +651,9 @@ static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
 		}
 	}
 
+	/* Update next TX pointer */
+	priv->tx_pointer = ftgmac100_next_tx_pointer(pointer);
+
 	spin_lock(&priv->tx_lock);
 	priv->tx_pending++;
 	if (priv->tx_pending == TX_QUEUE_ENTRIES)
@@ -724,7 +696,7 @@ static void ftgmac100_free_buffers(struct ftgmac100 *priv)
 	/* Free all TX buffers */
 	for (i = 0; i < TX_QUEUE_ENTRIES; i++) {
 		struct ftgmac100_txdes *txdes = &priv->descs->txdes[i];
-		struct sk_buff *skb = ftgmac100_txdes_get_skb(txdes);
+		struct sk_buff *skb = priv->tx_skbs[i];
 		dma_addr_t map = ftgmac100_txdes_get_dma_addr(txdes);
 
 		if (!skb)
-- 
2.9.3
