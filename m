From: Petri Gynther <pgynther@google.com>
Subject: [PATCH net-next 5/7] net: bcmgenet: rework Tx NAPI code
Date: Wed, 25 Mar 2015 12:35:14 -0700 (PDT)
Message-ID: <20150325193514.14CE82201FB@puck.mtv.corp.google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com, jaedon.shin@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f201.google.com ([209.85.160.201]:32883 "EHLO
	mail-yk0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752401AbbCYTfP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 15:35:15 -0400
Received: by ykbq200 with SMTP id q200so2132012ykb.0
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 12:35:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce new bcmgenet functions to handle the NAPI calls to:
netif_napi_add()
napi_enable()
napi_disable()
netif_napi_del()

Signed-off-by: Petri Gynther <pgynther@google.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 80 ++++++++++++++++++++------
 1 file changed, 62 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 68873be..367006d 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1733,7 +1733,6 @@ static void bcmgenet_init_tx_ring(struct bcmgenet_priv *priv,
 
 	spin_lock_init(&ring->lock);
 	ring->priv = priv;
-	netif_napi_add(priv->dev, &ring->napi, bcmgenet_tx_poll, 64);
 	ring->index = index;
 	if (index == DESC_INDEX) {
 		ring->queue = 0;
@@ -1777,17 +1776,6 @@ static void bcmgenet_init_tx_ring(struct bcmgenet_priv *priv,
 				  TDMA_WRITE_PTR);
 	bcmgenet_tdma_ring_writel(priv, index, end_ptr * words_per_bd - 1,
 				  DMA_END_ADDR);
-
-	napi_enable(&ring->napi);
-}
-
-static void bcmgenet_fini_tx_ring(struct bcmgenet_priv *priv,
-				  unsigned int index)
-{
-	struct bcmgenet_tx_ring *ring = &priv->tx_rings[index];
-
-	napi_disable(&ring->napi);
-	netif_napi_del(&ring->napi);
 }
 
 /* Initialize a RDMA ring */
@@ -1835,6 +1823,62 @@ static int bcmgenet_init_rx_ring(struct bcmgenet_priv *priv,
 	return ret;
 }
 
+static void bcmgenet_init_tx_napi(struct bcmgenet_priv *priv)
+{
+	unsigned int i;
+	struct bcmgenet_tx_ring *ring;
+
+	for (i = 0; i < priv->hw_params->tx_queues; ++i) {
+		ring = &priv->tx_rings[i];
+		netif_napi_add(priv->dev, &ring->napi, bcmgenet_tx_poll, 64);
+	}
+
+	ring = &priv->tx_rings[DESC_INDEX];
+	netif_napi_add(priv->dev, &ring->napi, bcmgenet_tx_poll, 64);
+}
+
+static void bcmgenet_enable_tx_napi(struct bcmgenet_priv *priv)
+{
+	unsigned int i;
+	struct bcmgenet_tx_ring *ring;
+
+	for (i = 0; i < priv->hw_params->tx_queues; ++i) {
+		ring = &priv->tx_rings[i];
+		napi_enable(&ring->napi);
+	}
+
+	ring = &priv->tx_rings[DESC_INDEX];
+	napi_enable(&ring->napi);
+}
+
+static void bcmgenet_disable_tx_napi(struct bcmgenet_priv *priv)
+{
+	unsigned int i;
+	struct bcmgenet_tx_ring *ring;
+
+	for (i = 0; i < priv->hw_params->tx_queues; ++i) {
+		ring = &priv->tx_rings[i];
+		napi_disable(&ring->napi);
+	}
+
+	ring = &priv->tx_rings[DESC_INDEX];
+	napi_disable(&ring->napi);
+}
+
+static void bcmgenet_fini_tx_napi(struct bcmgenet_priv *priv)
+{
+	unsigned int i;
+	struct bcmgenet_tx_ring *ring;
+
+	for (i = 0; i < priv->hw_params->tx_queues; ++i) {
+		ring = &priv->tx_rings[i];
+		netif_napi_del(&ring->napi);
+	}
+
+	ring = &priv->tx_rings[DESC_INDEX];
+	netif_napi_del(&ring->napi);
+}
+
 /* Initialize Tx queues
  *
  * Queues 0-3 are priority-based, each one has 32 descriptors,
@@ -1895,6 +1939,9 @@ static void bcmgenet_init_tx_queues(struct net_device *dev)
 	bcmgenet_tdma_writel(priv, dma_priority[1], DMA_PRIORITY_1);
 	bcmgenet_tdma_writel(priv, dma_priority[2], DMA_PRIORITY_2);
 
+	/* Initialize Tx NAPI */
+	bcmgenet_init_tx_napi(priv);
+
 	/* Enable Tx queues */
 	bcmgenet_tdma_writel(priv, ring_cfg, DMA_RING_CFG);
 
@@ -2036,12 +2083,7 @@ static void __bcmgenet_fini_dma(struct bcmgenet_priv *priv)
 
 static void bcmgenet_fini_dma(struct bcmgenet_priv *priv)
 {
-	int i;
-
-	bcmgenet_fini_tx_ring(priv, DESC_INDEX);
-
-	for (i = 0; i < priv->hw_params->tx_queues; i++)
-		bcmgenet_fini_tx_ring(priv, i);
+	bcmgenet_fini_tx_napi(priv);
 
 	__bcmgenet_fini_dma(priv);
 }
@@ -2466,6 +2508,7 @@ static void bcmgenet_netif_start(struct net_device *dev)
 
 	/* Start the network engine */
 	napi_enable(&priv->napi);
+	bcmgenet_enable_tx_napi(priv);
 
 	umac_enable_set(priv, CMD_TX_EN | CMD_RX_EN, true);
 
@@ -2574,6 +2617,7 @@ static void bcmgenet_netif_stop(struct net_device *dev)
 	phy_stop(priv->phydev);
 
 	bcmgenet_intr_disable(priv);
+	bcmgenet_disable_tx_napi(priv);
 
 	/* Wait for pending work items to complete. Since interrupts are
 	 * disabled no new work will be scheduled.
-- 
2.2.0.rc0.207.ga3a616c
