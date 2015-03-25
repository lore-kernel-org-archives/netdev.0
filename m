From: Petri Gynther <pgynther@google.com>
Subject: [PATCH net-next 6/7] net: bcmgenet: rework Rx NAPI code
Date: Wed, 25 Mar 2015 12:35:15 -0700 (PDT)
Message-ID: <20150325193515.354C12201FB@puck.mtv.corp.google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com, jaedon.shin@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f202.google.com ([209.85.213.202]:32806 "EHLO
	mail-ig0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752599AbbCYTfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 15:35:17 -0400
Received: by igjz20 with SMTP id z20so2458911igj.0
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 12:35:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce new bcmgenet functions to handle the NAPI calls to:
netif_napi_add()
napi_enable()
napi_disable()
netif_napi_del()

Signed-off-by: Petri Gynther <pgynther@google.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 68 +++++++++++++++++---------
 1 file changed, 45 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 367006d..dc3b1fa 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1544,6 +1544,25 @@ next:
 	return rxpktprocessed;
 }
 
+/* Rx NAPI polling method */
+static int bcmgenet_rx_poll(struct napi_struct *napi, int budget)
+{
+	struct bcmgenet_priv *priv = container_of(napi,
+			struct bcmgenet_priv, napi);
+	unsigned int work_done;
+
+	work_done = bcmgenet_desc_rx(priv, DESC_INDEX, budget);
+
+	if (work_done < budget) {
+		napi_complete(napi);
+		bcmgenet_intrl2_0_writel(priv, UMAC_IRQ_RXDMA_BDONE |
+					 UMAC_IRQ_RXDMA_PDONE,
+					 INTRL2_CPU_MASK_CLEAR);
+	}
+
+	return work_done;
+}
+
 /* Assign skb to RX DMA descriptor. */
 static int bcmgenet_alloc_rx_buffers(struct bcmgenet_priv *priv,
 				     struct bcmgenet_rx_ring *ring)
@@ -1951,6 +1970,26 @@ static void bcmgenet_init_tx_queues(struct net_device *dev)
 	bcmgenet_tdma_writel(priv, dma_ctrl, DMA_CTRL);
 }
 
+static void bcmgenet_init_rx_napi(struct bcmgenet_priv *priv)
+{
+	netif_napi_add(priv->dev, &priv->napi, bcmgenet_rx_poll, 64);
+}
+
+static void bcmgenet_enable_rx_napi(struct bcmgenet_priv *priv)
+{
+	napi_enable(&priv->napi);
+}
+
+static void bcmgenet_disable_rx_napi(struct bcmgenet_priv *priv)
+{
+	napi_disable(&priv->napi);
+}
+
+static void bcmgenet_fini_rx_napi(struct bcmgenet_priv *priv)
+{
+	netif_napi_del(&priv->napi);
+}
+
 /* Initialize Rx queues
  *
  * Queues 0-15 are priority queues. Hardware Filtering Block (HFB) can be
@@ -2000,6 +2039,9 @@ static int bcmgenet_init_rx_queues(struct net_device *dev)
 	ring_cfg |= (1 << DESC_INDEX);
 	dma_ctrl |= (1 << (DESC_INDEX + DMA_RING_BUF_EN_SHIFT));
 
+	/* Initialize Rx NAPI */
+	bcmgenet_init_rx_napi(priv);
+
 	/* Enable rings */
 	bcmgenet_rdma_writel(priv, ring_cfg, DMA_RING_CFG);
 
@@ -2083,6 +2125,7 @@ static void __bcmgenet_fini_dma(struct bcmgenet_priv *priv)
 
 static void bcmgenet_fini_dma(struct bcmgenet_priv *priv)
 {
+	bcmgenet_fini_rx_napi(priv);
 	bcmgenet_fini_tx_napi(priv);
 
 	__bcmgenet_fini_dma(priv);
@@ -2147,25 +2190,6 @@ static int bcmgenet_init_dma(struct bcmgenet_priv *priv)
 	return 0;
 }
 
-/* NAPI polling method*/
-static int bcmgenet_poll(struct napi_struct *napi, int budget)
-{
-	struct bcmgenet_priv *priv = container_of(napi,
-			struct bcmgenet_priv, napi);
-	unsigned int work_done;
-
-	work_done = bcmgenet_desc_rx(priv, DESC_INDEX, budget);
-
-	if (work_done < budget) {
-		napi_complete(napi);
-		bcmgenet_intrl2_0_writel(priv, UMAC_IRQ_RXDMA_BDONE |
-					 UMAC_IRQ_RXDMA_PDONE,
-					 INTRL2_CPU_MASK_CLEAR);
-	}
-
-	return work_done;
-}
-
 /* Interrupt bottom half */
 static void bcmgenet_irq_task(struct work_struct *work)
 {
@@ -2507,7 +2531,7 @@ static void bcmgenet_netif_start(struct net_device *dev)
 	struct bcmgenet_priv *priv = netdev_priv(dev);
 
 	/* Start the network engine */
-	napi_enable(&priv->napi);
+	bcmgenet_enable_rx_napi(priv);
 	bcmgenet_enable_tx_napi(priv);
 
 	umac_enable_set(priv, CMD_TX_EN | CMD_RX_EN, true);
@@ -2613,10 +2637,9 @@ static void bcmgenet_netif_stop(struct net_device *dev)
 	struct bcmgenet_priv *priv = netdev_priv(dev);
 
 	netif_tx_stop_all_queues(dev);
-	napi_disable(&priv->napi);
 	phy_stop(priv->phydev);
-
 	bcmgenet_intr_disable(priv);
+	bcmgenet_disable_rx_napi(priv);
 	bcmgenet_disable_tx_napi(priv);
 
 	/* Wait for pending work items to complete. Since interrupts are
@@ -3018,7 +3041,6 @@ static int bcmgenet_probe(struct platform_device *pdev)
 	dev->watchdog_timeo = 2 * HZ;
 	dev->ethtool_ops = &bcmgenet_ethtool_ops;
 	dev->netdev_ops = &bcmgenet_netdev_ops;
-	netif_napi_add(dev, &priv->napi, bcmgenet_poll, 64);
 
 	priv->msg_enable = netif_msg_init(-1, GENET_MSG_DEFAULT);
 
-- 
2.2.0.rc0.207.ga3a616c
