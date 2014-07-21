From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 04/11] net: bcmgenet: add suspend/resume callbacks
Date: Mon, 21 Jul 2014 15:29:22 -0700
Message-ID: <1405981769-24618-5-git-send-email-f.fainelli@gmail.com>
References: <1405981769-24618-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:61642 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754929AbaGUW3v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 18:29:51 -0400
Received: by mail-pd0-f174.google.com with SMTP id fp1so9922964pdb.19
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2014 15:29:51 -0700 (PDT)
In-Reply-To: <1405981769-24618-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement suspend/resume callbacks in the GENET driver. This makes sure
that we de-initialize and re-initialize the hardware correctly before
entering suspend and when resuming.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v2:
- update callers of umac_enable_set to use true/false

 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 95 ++++++++++++++++++++++++++
 1 file changed, 95 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 5cab188ee323..bbd8bf326a35 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -2584,6 +2584,100 @@ static int bcmgenet_remove(struct platform_device *pdev)
 	return 0;
 }
 
+#ifdef CONFIG_PM_SLEEP
+static int bcmgenet_suspend(struct device *d)
+{
+	struct net_device *dev = dev_get_drvdata(d);
+	struct bcmgenet_priv *priv = netdev_priv(dev);
+	int ret;
+
+	if (!netif_running(dev))
+		return 0;
+
+	bcmgenet_netif_stop(dev);
+
+	netif_device_detach(dev);
+
+	/* Disable MAC receive */
+	umac_enable_set(priv, CMD_RX_EN, false);
+
+	ret = bcmgenet_dma_teardown(priv);
+	if (ret)
+		return ret;
+
+	/* Disable MAC transmit. TX DMA disabled have to done before this */
+	umac_enable_set(priv, CMD_TX_EN, false);
+
+	/* tx reclaim */
+	bcmgenet_tx_reclaim_all(dev);
+	bcmgenet_fini_dma(priv);
+
+	/* Turn off the clocks */
+	clk_disable_unprepare(priv->clk);
+
+	return 0;
+}
+
+static int bcmgenet_resume(struct device *d)
+{
+	struct net_device *dev = dev_get_drvdata(d);
+	struct bcmgenet_priv *priv = netdev_priv(dev);
+	unsigned long dma_ctrl;
+	int ret;
+	u32 reg;
+
+	if (!netif_running(dev))
+		return 0;
+
+	/* Turn on the clock */
+	ret = clk_prepare_enable(priv->clk);
+	if (ret)
+		return ret;
+
+	bcmgenet_umac_reset(priv);
+
+	ret = init_umac(priv);
+	if (ret)
+		goto out_clk_disable;
+
+	/* disable ethernet MAC while updating its registers */
+	umac_enable_set(priv, CMD_TX_EN | CMD_RX_EN, false);
+
+	bcmgenet_set_hw_addr(priv, dev->dev_addr);
+
+	if (phy_is_internal(priv->phydev)) {
+		reg = bcmgenet_ext_readl(priv, EXT_EXT_PWR_MGMT);
+		reg |= EXT_ENERGY_DET_MASK;
+		bcmgenet_ext_writel(priv, reg, EXT_EXT_PWR_MGMT);
+	}
+
+	/* Disable RX/TX DMA and flush TX queues */
+	dma_ctrl = bcmgenet_dma_disable(priv);
+
+	/* Reinitialize TDMA and RDMA and SW housekeeping */
+	ret = bcmgenet_init_dma(priv);
+	if (ret) {
+		netdev_err(dev, "failed to initialize DMA\n");
+		goto out_clk_disable;
+	}
+
+	/* Always enable ring 16 - descriptor ring */
+	bcmgenet_enable_dma(priv, dma_ctrl);
+
+	netif_device_attach(dev);
+
+	bcmgenet_netif_start(dev);
+
+	return 0;
+
+out_clk_disable:
+	clk_disable_unprepare(priv->clk);
+	return ret;
+}
+#endif /* CONFIG_PM_SLEEP */
+
+static SIMPLE_DEV_PM_OPS(bcmgenet_pm_ops, bcmgenet_suspend, bcmgenet_resume);
+
 static struct platform_driver bcmgenet_driver = {
 	.probe	= bcmgenet_probe,
 	.remove	= bcmgenet_remove,
@@ -2591,6 +2685,7 @@ static struct platform_driver bcmgenet_driver = {
 		.name	= "bcmgenet",
 		.owner	= THIS_MODULE,
 		.of_match_table = bcmgenet_match,
+		.pm	= &bcmgenet_pm_ops,
 	},
 };
 module_platform_driver(bcmgenet_driver);
-- 
1.9.1
