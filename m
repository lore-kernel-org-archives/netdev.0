From: Doug Berger <opendmb@gmail.com>
Subject: [PATCH net-next 4/9] net: bcmgenet: move NAPI initialization to ring initialization
Date: Wed, 25 Oct 2017 15:04:14 -0700
Message-ID: <20171025220419.24951-5-opendmb@gmail.com>
References: <20171025220419.24951-1-opendmb@gmail.com>
Cc: Doug Berger <opendmb@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171025220419.24951-1-opendmb@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since each ring has its own NAPI instance it might as well be
initialized along with the other ring context.

Signed-off-by: Doug Berger <opendmb@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 42 +++++---------------------
 1 file changed, 8 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 3da177fa2659..9ce6671e8916 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -2081,6 +2081,10 @@ static void bcmgenet_init_tx_ring(struct bcmgenet_priv *priv,
 				  TDMA_WRITE_PTR);
 	bcmgenet_tdma_ring_writel(priv, index, end_ptr * words_per_bd - 1,
 				  DMA_END_ADDR);
+
+	/* Initialize Tx NAPI */
+	netif_napi_add(priv->dev, &ring->napi, bcmgenet_tx_poll,
+		       NAPI_POLL_WEIGHT);
 }
 
 /* Initialize a RDMA ring */
@@ -2112,6 +2116,10 @@ static int bcmgenet_init_rx_ring(struct bcmgenet_priv *priv,
 	if (ret)
 		return ret;
 
+	/* Initialize Rx NAPI */
+	netif_napi_add(priv->dev, &ring->napi, bcmgenet_rx_poll,
+		       NAPI_POLL_WEIGHT);
+
 	bcmgenet_rdma_ring_writel(priv, index, 0, RDMA_PROD_INDEX);
 	bcmgenet_rdma_ring_writel(priv, index, 0, RDMA_CONS_INDEX);
 	bcmgenet_rdma_ring_writel(priv, index, 1, DMA_MBUF_DONE_THRESH);
@@ -2136,20 +2144,6 @@ static int bcmgenet_init_rx_ring(struct bcmgenet_priv *priv,
 	return ret;
 }
 
-static void bcmgenet_init_tx_napi(struct bcmgenet_priv *priv)
-{
-	unsigned int i;
-	struct bcmgenet_tx_ring *ring;
-
-	for (i = 0; i < priv->hw_params->tx_queues; ++i) {
-		ring = &priv->tx_rings[i];
-		netif_tx_napi_add(priv->dev, &ring->napi, bcmgenet_tx_poll, 64);
-	}
-
-	ring = &priv->tx_rings[DESC_INDEX];
-	netif_tx_napi_add(priv->dev, &ring->napi, bcmgenet_tx_poll, 64);
-}
-
 static void bcmgenet_enable_tx_napi(struct bcmgenet_priv *priv)
 {
 	unsigned int i;
@@ -2263,9 +2257,6 @@ static void bcmgenet_init_tx_queues(struct net_device *dev)
 	bcmgenet_tdma_writel(priv, dma_priority[1], DMA_PRIORITY_1);
 	bcmgenet_tdma_writel(priv, dma_priority[2], DMA_PRIORITY_2);
 
-	/* Initialize Tx NAPI */
-	bcmgenet_init_tx_napi(priv);
-
 	/* Enable Tx queues */
 	bcmgenet_tdma_writel(priv, ring_cfg, DMA_RING_CFG);
 
@@ -2275,20 +2266,6 @@ static void bcmgenet_init_tx_queues(struct net_device *dev)
 	bcmgenet_tdma_writel(priv, dma_ctrl, DMA_CTRL);
 }
 
-static void bcmgenet_init_rx_napi(struct bcmgenet_priv *priv)
-{
-	unsigned int i;
-	struct bcmgenet_rx_ring *ring;
-
-	for (i = 0; i < priv->hw_params->rx_queues; ++i) {
-		ring = &priv->rx_rings[i];
-		netif_napi_add(priv->dev, &ring->napi, bcmgenet_rx_poll, 64);
-	}
-
-	ring = &priv->rx_rings[DESC_INDEX];
-	netif_napi_add(priv->dev, &ring->napi, bcmgenet_rx_poll, 64);
-}
-
 static void bcmgenet_enable_rx_napi(struct bcmgenet_priv *priv)
 {
 	unsigned int i;
@@ -2391,9 +2368,6 @@ static int bcmgenet_init_rx_queues(struct net_device *dev)
 	ring_cfg |= (1 << DESC_INDEX);
 	dma_ctrl |= (1 << (DESC_INDEX + DMA_RING_BUF_EN_SHIFT));
 
-	/* Initialize Rx NAPI */
-	bcmgenet_init_rx_napi(priv);
-
 	/* Enable rings */
 	bcmgenet_rdma_writel(priv, ring_cfg, DMA_RING_CFG);
 
-- 
2.14.1
