From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 2/2 v2] net: bcmgenet: call bcmgenet_dma_teardown in bcmgenet_fini_dma
Date: Mon, 22 Sep 2014 11:54:43 -0700
Message-ID: <1411412083-9370-3-git-send-email-f.fainelli@gmail.com>
References: <1411412083-9370-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:47621 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754613AbaIVSzF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 14:55:05 -0400
Received: by mail-pd0-f181.google.com with SMTP id r10so5000760pdi.40
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2014 11:55:04 -0700 (PDT)
In-Reply-To: <1411412083-9370-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should not be manipulaging the DMA_CTRL registers directly by writing
0 to them to disable DMA. This is an operation that needs to be timed to
make sure the DMA engines have been properly stopped since their state
machine stops on a packet boundary, not immediately.

Make sure that tha bcmgenet_fini_dma() calls bcmgenet_dma_teardown() to
ensure a proper DMA engine state. As a result, we need to reorder the
function bodies to resolve the use dependency.

Fixes: 1c1008c793fa ("net: bcmgenet: add main driver file")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v2:
- properly re-order bcmgenet_dma_teardown to resolve the use dependency

 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 105 ++++++++++++-------------
 1 file changed, 52 insertions(+), 53 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 11a96437862d..5cc9cae21ed5 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1744,13 +1744,63 @@ static void bcmgenet_init_multiq(struct net_device *dev)
 	bcmgenet_tdma_writel(priv, reg, DMA_CTRL);
 }
 
+static int bcmgenet_dma_teardown(struct bcmgenet_priv *priv)
+{
+	int ret = 0;
+	int timeout = 0;
+	u32 reg;
+
+	/* Disable TDMA to stop add more frames in TX DMA */
+	reg = bcmgenet_tdma_readl(priv, DMA_CTRL);
+	reg &= ~DMA_EN;
+	bcmgenet_tdma_writel(priv, reg, DMA_CTRL);
+
+	/* Check TDMA status register to confirm TDMA is disabled */
+	while (timeout++ < DMA_TIMEOUT_VAL) {
+		reg = bcmgenet_tdma_readl(priv, DMA_STATUS);
+		if (reg & DMA_DISABLED)
+			break;
+
+		udelay(1);
+	}
+
+	if (timeout == DMA_TIMEOUT_VAL) {
+		netdev_warn(priv->dev, "Timed out while disabling TX DMA\n");
+		ret = -ETIMEDOUT;
+	}
+
+	/* Wait 10ms for packet drain in both tx and rx dma */
+	usleep_range(10000, 20000);
+
+	/* Disable RDMA */
+	reg = bcmgenet_rdma_readl(priv, DMA_CTRL);
+	reg &= ~DMA_EN;
+	bcmgenet_rdma_writel(priv, reg, DMA_CTRL);
+
+	timeout = 0;
+	/* Check RDMA status register to confirm RDMA is disabled */
+	while (timeout++ < DMA_TIMEOUT_VAL) {
+		reg = bcmgenet_rdma_readl(priv, DMA_STATUS);
+		if (reg & DMA_DISABLED)
+			break;
+
+		udelay(1);
+	}
+
+	if (timeout == DMA_TIMEOUT_VAL) {
+		netdev_warn(priv->dev, "Timed out while disabling RX DMA\n");
+		ret = -ETIMEDOUT;
+	}
+
+	return ret;
+}
+
 static void bcmgenet_fini_dma(struct bcmgenet_priv *priv)
 {
 	int i;
 
 	/* disable DMA */
-	bcmgenet_rdma_writel(priv, 0, DMA_CTRL);
-	bcmgenet_tdma_writel(priv, 0, DMA_CTRL);
+	bcmgenet_dma_teardown(priv);
 
 	for (i = 0; i < priv->num_tx_bds; i++) {
 		if (priv->tx_cbs[i].skb != NULL) {
@@ -2109,57 +2159,6 @@ err_clk_disable:
 	return ret;
 }
 
-static int bcmgenet_dma_teardown(struct bcmgenet_priv *priv)
-{
-	int ret = 0;
-	int timeout = 0;
-	u32 reg;
-
-	/* Disable TDMA to stop add more frames in TX DMA */
-	reg = bcmgenet_tdma_readl(priv, DMA_CTRL);
-	reg &= ~DMA_EN;
-	bcmgenet_tdma_writel(priv, reg, DMA_CTRL);
-
-	/* Check TDMA status register to confirm TDMA is disabled */
-	while (timeout++ < DMA_TIMEOUT_VAL) {
-		reg = bcmgenet_tdma_readl(priv, DMA_STATUS);
-		if (reg & DMA_DISABLED)
-			break;
-
-		udelay(1);
-	}
-
-	if (timeout == DMA_TIMEOUT_VAL) {
-		netdev_warn(priv->dev, "Timed out while disabling TX DMA\n");
-		ret = -ETIMEDOUT;
-	}
-
-	/* Wait 10ms for packet drain in both tx and rx dma */
-	usleep_range(10000, 20000);
-
-	/* Disable RDMA */
-	reg = bcmgenet_rdma_readl(priv, DMA_CTRL);
-	reg &= ~DMA_EN;
-	bcmgenet_rdma_writel(priv, reg, DMA_CTRL);
-
-	timeout = 0;
-	/* Check RDMA status register to confirm RDMA is disabled */
-	while (timeout++ < DMA_TIMEOUT_VAL) {
-		reg = bcmgenet_rdma_readl(priv, DMA_STATUS);
-		if (reg & DMA_DISABLED)
-			break;
-
-		udelay(1);
-	}
-
-	if (timeout == DMA_TIMEOUT_VAL) {
-		netdev_warn(priv->dev, "Timed out while disabling RX DMA\n");
-		ret = -ETIMEDOUT;
-	}
-
-	return ret;
-}
-
 static void bcmgenet_netif_stop(struct net_device *dev)
 {
 	struct bcmgenet_priv *priv = netdev_priv(dev);
-- 
1.9.1
