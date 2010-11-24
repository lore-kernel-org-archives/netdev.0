From: Peppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 3/4] stmmac: convert to dev_pm_ops.
Date: Wed, 24 Nov 2010 13:38:11 +0100
Message-ID: <1290561646-9429-3-git-send-email-peppe.cavallaro@st.com>
References: <1290561646-9429-1-git-send-email-peppe.cavallaro@st.com>
 <1290561646-9429-2-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Peppe CAVALLARO <peppe.cavallaro@st.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:39099 "EHLO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754227Ab0KXMi2 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Nov 2010 07:38:28 -0500
Received: from zeta.dmz-us.st.com (ns4.st.com [167.4.80.115])
	by beta.dmz-us.st.com (STMicroelectronics) with ESMTP id BDD11160
	for <netdev@vger.kernel.org>; Wed, 24 Nov 2010 12:38:24 +0000 (GMT)
Received: from Webmail-eu.st.com (safex1hubcas1.st.com [10.75.90.14])
	by zeta.dmz-us.st.com (STMicroelectronics) with ESMTP id 2D40A1AB
	for <netdev@vger.kernel.org>; Wed, 24 Nov 2010 12:38:24 +0000 (GMT)
In-Reply-To: <1290561646-9429-2-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the PM support using the dev_pm_ops
and reviews the hibernation support.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/stmmac.h      |    1 -
 drivers/net/stmmac/stmmac_main.c |  124 ++++++++++++++++++++++----------------
 2 files changed, 71 insertions(+), 54 deletions(-)

diff --git a/drivers/net/stmmac/stmmac.h b/drivers/net/stmmac/stmmac.h
index 8ae7650..eb258e2 100644
--- a/drivers/net/stmmac/stmmac.h
+++ b/drivers/net/stmmac/stmmac.h
@@ -77,7 +77,6 @@ struct stmmac_priv {
 	spinlock_t lock;
 	int wolopts;
 	int wolenabled;
-	int shutdown;
 #ifdef CONFIG_STMMAC_TIMER
 	struct stmmac_timer *tm;
 #endif
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index b806cd3..f1dbc18 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -844,8 +844,6 @@ static int stmmac_open(struct net_device *dev)
 	if (priv->plat->tx_coe)
 		pr_info("\tTX Checksum insertion supported\n");
 
-	priv->shutdown = 0;
-
 	/* Initialise the MMC (if present) to disable all interrupts. */
 	writel(0xffffffff, priv->ioaddr + MMC_HIGH_INTR_MASK);
 	writel(0xffffffff, priv->ioaddr + MMC_LOW_INTR_MASK);
@@ -1799,61 +1797,53 @@ static int stmmac_dvr_remove(struct platform_device *pdev)
 }
 
 #ifdef CONFIG_PM
-static int stmmac_suspend(struct platform_device *pdev, pm_message_t state)
+static int stmmac_suspend(struct device *dev)
 {
-	struct net_device *dev = platform_get_drvdata(pdev);
-	struct stmmac_priv *priv = netdev_priv(dev);
+	struct net_device *ndev = dev_get_drvdata(dev);
+	struct stmmac_priv *priv = netdev_priv(ndev);
 	int dis_ic = 0;
 
-	if (!dev || !netif_running(dev))
+	if (!ndev || !netif_running(ndev))
 		return 0;
 
 	spin_lock(&priv->lock);
 
-	if (state.event == PM_EVENT_SUSPEND) {
-		netif_device_detach(dev);
-		netif_stop_queue(dev);
-		if (priv->phydev)
-			phy_stop(priv->phydev);
+	netif_device_detach(ndev);
+	netif_stop_queue(ndev);
+	if (priv->phydev)
+		phy_stop(priv->phydev);
 
 #ifdef CONFIG_STMMAC_TIMER
-		priv->tm->timer_stop();
-		if (likely(priv->tm->enable))
-			dis_ic = 1;
+	priv->tm->timer_stop();
+	if (likely(priv->tm->enable))
+		dis_ic = 1;
 #endif
-		napi_disable(&priv->napi);
-
-		/* Stop TX/RX DMA */
-		priv->hw->dma->stop_tx(priv->ioaddr);
-		priv->hw->dma->stop_rx(priv->ioaddr);
-		/* Clear the Rx/Tx descriptors */
-		priv->hw->desc->init_rx_desc(priv->dma_rx, priv->dma_rx_size,
-					     dis_ic);
-		priv->hw->desc->init_tx_desc(priv->dma_tx, priv->dma_tx_size);
-
-		/* Enable Power down mode by programming the PMT regs */
-		if (device_can_wakeup(priv->device))
-			priv->hw->mac->pmt(priv->ioaddr, priv->wolopts);
-		else
-			stmmac_disable_mac(priv->ioaddr);
-	} else {
-		priv->shutdown = 1;
-		/* Although this can appear slightly redundant it actually
-		 * makes fast the standby operation and guarantees the driver
-		 * working if hibernation is on media. */
-		stmmac_release(dev);
-	}
+	napi_disable(&priv->napi);
+
+	/* Stop TX/RX DMA */
+	priv->hw->dma->stop_tx(priv->ioaddr);
+	priv->hw->dma->stop_rx(priv->ioaddr);
+	/* Clear the Rx/Tx descriptors */
+	priv->hw->desc->init_rx_desc(priv->dma_rx, priv->dma_rx_size,
+				     dis_ic);
+	priv->hw->desc->init_tx_desc(priv->dma_tx, priv->dma_tx_size);
+
+	/* Enable Power down mode by programming the PMT regs */
+	if (device_may_wakeup(priv->device))
+		priv->hw->mac->pmt(priv->ioaddr, priv->wolopts);
+	else
+		stmmac_disable_mac(priv->ioaddr);
 
 	spin_unlock(&priv->lock);
 	return 0;
 }
 
-static int stmmac_resume(struct platform_device *pdev)
+static int stmmac_resume(struct device *dev)
 {
-	struct net_device *dev = platform_get_drvdata(pdev);
-	struct stmmac_priv *priv = netdev_priv(dev);
+	struct net_device *ndev = dev_get_drvdata(dev);
+	struct stmmac_priv *priv = netdev_priv(ndev);
 
-	if (!netif_running(dev))
+	if (!netif_running(ndev))
 		return 0;
 
 	if (priv->shutdown) {
@@ -1870,10 +1860,10 @@ static int stmmac_resume(struct platform_device *pdev)
 	 * is received. Anyway, it's better to manually clear
 	 * this bit because it can generate problems while resuming
 	 * from another devices (e.g. serial console). */
-	if (device_can_wakeup(priv->device))
+	if (device_may_wakeup(priv->device))
 		priv->hw->mac->pmt(priv->ioaddr, 0);
 
-	netif_device_attach(dev);
+	netif_device_attach(ndev);
 
 	/* Enable the MAC and DMA */
 	stmmac_enable_mac(priv->ioaddr);
@@ -1881,31 +1871,59 @@ static int stmmac_resume(struct platform_device *pdev)
 	priv->hw->dma->start_rx(priv->ioaddr);
 
 #ifdef CONFIG_STMMAC_TIMER
-	priv->tm->timer_start(tmrate);
+	if (likely(priv->tm->enable))
+		priv->tm->timer_start(tmrate);
 #endif
 	napi_enable(&priv->napi);
 
 	if (priv->phydev)
 		phy_start(priv->phydev);
 
-	netif_start_queue(dev);
+	netif_start_queue(ndev);
 
 	spin_unlock(&priv->lock);
 	return 0;
 }
-#endif
 
-static struct platform_driver stmmac_driver = {
-	.driver = {
-		   .name = STMMAC_RESOURCE_NAME,
-		   },
-	.probe = stmmac_dvr_probe,
-	.remove = stmmac_dvr_remove,
-#ifdef CONFIG_PM
+static int stmmac_freeze(struct device *dev)
+{
+	struct net_device *ndev = dev_get_drvdata(dev);
+
+	if (!ndev || !netif_running(ndev))
+		return 0;
+
+	return stmmac_release(ndev);
+}
+
+static int stmmac_restore(struct device *dev)
+{
+	struct net_device *ndev = dev_get_drvdata(dev);
+
+	if (!ndev || !netif_running(ndev))
+		return 0;
+
+	return stmmac_open(ndev);
+}
+
+static const struct dev_pm_ops stmmac_pm_ops = {
 	.suspend = stmmac_suspend,
 	.resume = stmmac_resume,
-#endif
+	.freeze = stmmac_freeze,
+	.thaw = stmmac_restore,
+	.restore = stmmac_restore,
+};
+#else
+static const struct dev_pm_ops stmmac_pm_ops;
+#endif /* CONFIG_PM */
 
+static struct platform_driver stmmac_driver = {
+	.probe = stmmac_dvr_probe,
+	.remove = stmmac_dvr_remove,
+	.driver = {
+		.name = STMMAC_RESOURCE_NAME,
+		.owner = THIS_MODULE,
+		.pm = &stmmac_pm_ops,
+	},
 };
 
 /**
-- 
1.5.5.6
