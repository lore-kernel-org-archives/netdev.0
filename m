From: Petri Gynther <pgynther@google.com>
Subject: [PATCH net-next 3/7] net: bcmgenet: simplify bcmgenet_init_dma()
Date: Wed, 25 Mar 2015 12:35:11 -0700 (PDT)
Message-ID: <20150325193511.F0B1E2201FB@puck.mtv.corp.google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com, jaedon.shin@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f74.google.com ([209.85.213.74]:32914 "EHLO
	mail-yh0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752276AbbCYTfN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 15:35:13 -0400
Received: by yhoc41 with SMTP id c41so2136528yho.0
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 12:35:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do the two kcalloc() calls first, before proceeding into Rx/Tx DMA init.
Makes the error case handling much simpler.

Signed-off-by: Petri Gynther <pgynther@google.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 33 +++++++++++++-------------
 1 file changed, 17 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 550bf98..1c9f9b4 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -2050,9 +2050,6 @@ static int bcmgenet_init_dma(struct bcmgenet_priv *priv)
 
 	netif_dbg(priv, hw, priv->dev, "%s\n", __func__);
 
-	/* Init rDma */
-	bcmgenet_rdma_writel(priv, DMA_MAX_BURST_LENGTH, DMA_SCB_BURST_SIZE);
-
 	/* Initialize common Rx ring structures */
 	priv->rx_bds = priv->base + priv->hw_params->rdma_offset;
 	priv->num_rx_bds = TOTAL_DESC;
@@ -2066,25 +2063,13 @@ static int bcmgenet_init_dma(struct bcmgenet_priv *priv)
 		cb->bd_addr = priv->rx_bds + i * DMA_DESC_SIZE;
 	}
 
-	/* Initialize Rx queues */
-	ret = bcmgenet_init_rx_queues(priv->dev);
-	if (ret) {
-		netdev_err(priv->dev, "failed to initialize Rx queues\n");
-		bcmgenet_free_rx_buffers(priv);
-		kfree(priv->rx_cbs);
-		return ret;
-	}
-
-	/* Init tDma */
-	bcmgenet_tdma_writel(priv, DMA_MAX_BURST_LENGTH, DMA_SCB_BURST_SIZE);
-
 	/* Initialize common TX ring structures */
 	priv->tx_bds = priv->base + priv->hw_params->tdma_offset;
 	priv->num_tx_bds = TOTAL_DESC;
 	priv->tx_cbs = kcalloc(priv->num_tx_bds, sizeof(struct enet_cb),
 			       GFP_KERNEL);
 	if (!priv->tx_cbs) {
-		__bcmgenet_fini_dma(priv);
+		kfree(priv->rx_cbs);
 		return -ENOMEM;
 	}
 
@@ -2093,6 +2078,22 @@ static int bcmgenet_init_dma(struct bcmgenet_priv *priv)
 		cb->bd_addr = priv->tx_bds + i * DMA_DESC_SIZE;
 	}
 
+	/* Init rDma */
+	bcmgenet_rdma_writel(priv, DMA_MAX_BURST_LENGTH, DMA_SCB_BURST_SIZE);
+
+	/* Initialize Rx queues */
+	ret = bcmgenet_init_rx_queues(priv->dev);
+	if (ret) {
+		netdev_err(priv->dev, "failed to initialize Rx queues\n");
+		bcmgenet_free_rx_buffers(priv);
+		kfree(priv->rx_cbs);
+		kfree(priv->tx_cbs);
+		return ret;
+	}
+
+	/* Init tDma */
+	bcmgenet_tdma_writel(priv, DMA_MAX_BURST_LENGTH, DMA_SCB_BURST_SIZE);
+
 	/* Initialize Tx queues */
 	bcmgenet_init_tx_queues(priv->dev);
 
-- 
2.2.0.rc0.207.ga3a616c
