From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 03/11] net: bcmgenet: modularize bcmgenet_{open,close}
Date: Mon, 21 Jul 2014 15:29:21 -0700
Message-ID: <1405981769-24618-4-git-send-email-f.fainelli@gmail.com>
References: <1405981769-24618-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:34449 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754923AbaGUW3u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 18:29:50 -0400
Received: by mail-pd0-f181.google.com with SMTP id g10so8483854pdj.12
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2014 15:29:50 -0700 (PDT)
In-Reply-To: <1405981769-24618-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce a bunch of helper functions: bcmgenet_netif_start,
bcmgenet_netif_stop and bcmgenet_intr_disable to help reuse code that is
going to be necessary for suspend/resume.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 86 ++++++++++++++++----------
 1 file changed, 53 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index c037c888640d..5cab188ee323 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1488,6 +1488,17 @@ static int reset_umac(struct bcmgenet_priv *priv)
 	return 0;
 }
 
+static void bcmgenet_intr_disable(struct bcmgenet_priv *priv)
+{
+	/* Mask all interrupts.*/
+	bcmgenet_intrl2_0_writel(priv, 0xFFFFFFFF, INTRL2_CPU_MASK_SET);
+	bcmgenet_intrl2_0_writel(priv, 0xFFFFFFFF, INTRL2_CPU_CLEAR);
+	bcmgenet_intrl2_0_writel(priv, 0, INTRL2_CPU_MASK_CLEAR);
+	bcmgenet_intrl2_1_writel(priv, 0xFFFFFFFF, INTRL2_CPU_MASK_SET);
+	bcmgenet_intrl2_1_writel(priv, 0xFFFFFFFF, INTRL2_CPU_CLEAR);
+	bcmgenet_intrl2_1_writel(priv, 0, INTRL2_CPU_MASK_CLEAR);
+}
+
 static int init_umac(struct bcmgenet_priv *priv)
 {
 	struct device *kdev = &priv->pdev->dev;
@@ -1516,10 +1527,7 @@ static int init_umac(struct bcmgenet_priv *priv)
 	if (!GENET_IS_V1(priv) && !GENET_IS_V2(priv))
 		bcmgenet_rbuf_writel(priv, 1, RBUF_TBUF_SIZE_CTRL);
 
-	/* Mask all interrupts.*/
-	bcmgenet_intrl2_0_writel(priv, 0xFFFFFFFF, INTRL2_CPU_MASK_SET);
-	bcmgenet_intrl2_0_writel(priv, 0xFFFFFFFF, INTRL2_CPU_CLEAR);
-	bcmgenet_intrl2_0_writel(priv, 0, INTRL2_CPU_MASK_CLEAR);
+	bcmgenet_intr_disable(priv);
 
 	cpu_mask_clear = UMAC_IRQ_RXDMA_BDONE;
 
@@ -1986,6 +1994,23 @@ static void bcmgenet_enable_dma(struct bcmgenet_priv *priv, u32 dma_ctrl)
 	bcmgenet_tdma_writel(priv, reg, DMA_CTRL);
 }
 
+static void bcmgenet_netif_start(struct net_device *dev)
+{
+	struct bcmgenet_priv *priv = netdev_priv(dev);
+
+	/* Start the network engine */
+	napi_enable(&priv->napi);
+
+	umac_enable_set(priv, CMD_TX_EN | CMD_RX_EN, true);
+
+	if (phy_is_internal(priv->phydev))
+		bcmgenet_power_up(priv, GENET_POWER_PASSIVE);
+
+	netif_tx_start_all_queues(dev);
+
+	phy_start(priv->phydev);
+}
+
 static int bcmgenet_open(struct net_device *dev)
 {
 	struct bcmgenet_priv *priv = netdev_priv(dev);
@@ -2009,6 +2034,10 @@ static int bcmgenet_open(struct net_device *dev)
 	/* disable ethernet MAC while updating its registers */
 	umac_enable_set(priv, CMD_TX_EN | CMD_RX_EN, false);
 
+	/* Make sure we reflect the value of CRC_CMD_FWD */
+	reg = bcmgenet_umac_readl(priv, UMAC_CMD);
+	priv->crc_fwd_en = !!(reg & CMD_CRC_FWD);
+
 	bcmgenet_set_hw_addr(priv, dev->dev_addr);
 
 	if (phy_is_internal(priv->phydev)) {
@@ -2017,6 +2046,8 @@ static int bcmgenet_open(struct net_device *dev)
 		bcmgenet_ext_writel(priv, reg, EXT_EXT_PWR_MGMT);
 	}
 
+	device_set_wakeup_capable(&dev->dev, 1);
+
 	/* Disable RX/TX DMA and flush TX queues */
 	dma_ctrl = bcmgenet_dma_disable(priv);
 
@@ -2044,23 +2075,7 @@ static int bcmgenet_open(struct net_device *dev)
 		goto err_irq0;
 	}
 
-	/* Start the network engine */
-	napi_enable(&priv->napi);
-
-	umac_enable_set(priv, CMD_TX_EN | CMD_RX_EN, true);
-
-	/* Make sure we reflect the value of CRC_CMD_FWD */
-	reg = bcmgenet_umac_readl(priv, UMAC_CMD);
-	priv->crc_fwd_en = !!(reg & CMD_CRC_FWD);
-
-	device_set_wakeup_capable(&dev->dev, 1);
-
-	if (phy_is_internal(priv->phydev))
-		bcmgenet_power_up(priv, GENET_POWER_PASSIVE);
-
-	netif_tx_start_all_queues(dev);
-
-	phy_start(priv->phydev);
+	bcmgenet_netif_start(dev);
 
 	return 0;
 
@@ -2127,6 +2142,22 @@ static int bcmgenet_dma_teardown(struct bcmgenet_priv *priv)
 	return ret;
 }
 
+static void bcmgenet_netif_stop(struct net_device *dev)
+{
+	struct bcmgenet_priv *priv = netdev_priv(dev);
+
+	netif_tx_stop_all_queues(dev);
+	napi_disable(&priv->napi);
+	phy_stop(priv->phydev);
+
+	bcmgenet_intr_disable(priv);
+
+	/* Wait for pending work items to complete. Since interrupts are
+	 * disabled no new work will be scheduled.
+	 */
+	cancel_work_sync(&priv->bcmgenet_irq_work);
+}
+
 static int bcmgenet_close(struct net_device *dev)
 {
 	struct bcmgenet_priv *priv = netdev_priv(dev);
@@ -2134,13 +2165,11 @@ static int bcmgenet_close(struct net_device *dev)
 
 	netif_dbg(priv, ifdown, dev, "bcmgenet_close\n");
 
-	phy_stop(priv->phydev);
+	bcmgenet_netif_stop(dev);
 
 	/* Disable MAC receive */
 	umac_enable_set(priv, CMD_RX_EN, false);
 
-	netif_tx_stop_all_queues(dev);
-
 	ret = bcmgenet_dma_teardown(priv);
 	if (ret)
 		return ret;
@@ -2148,8 +2177,6 @@ static int bcmgenet_close(struct net_device *dev)
 	/* Disable MAC transmit. TX DMA disabled have to done before this */
 	umac_enable_set(priv, CMD_TX_EN, false);
 
-	napi_disable(&priv->napi);
-
 	/* tx reclaim */
 	bcmgenet_tx_reclaim_all(dev);
 	bcmgenet_fini_dma(priv);
@@ -2157,12 +2184,6 @@ static int bcmgenet_close(struct net_device *dev)
 	free_irq(priv->irq0, priv);
 	free_irq(priv->irq1, priv);
 
-	/* Wait for pending work items to complete - we are stopping
-	 * the clock now. Since interrupts are disabled, no new work
-	 * will be scheduled.
-	 */
-	cancel_work_sync(&priv->bcmgenet_irq_work);
-
 	if (phy_is_internal(priv->phydev))
 		bcmgenet_power_down(priv, GENET_POWER_PASSIVE);
 
@@ -2563,7 +2584,6 @@ static int bcmgenet_remove(struct platform_device *pdev)
 	return 0;
 }
 
-
 static struct platform_driver bcmgenet_driver = {
 	.probe	= bcmgenet_probe,
 	.remove	= bcmgenet_remove,
-- 
1.9.1
