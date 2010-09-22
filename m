From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next] stmmac: review the wake-up support
Date: Wed, 22 Sep 2010 12:38:26 +0200
Message-ID: <1285151906-14190-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog109.obsmtp.com ([207.126.144.127]:46635 "EHLO
	eu1sys200aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753781Ab0IVKir (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 06:38:47 -0400
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id DC996B5
	for <netdev@vger.kernel.org>; Wed, 22 Sep 2010 10:38:32 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 8E6A62499
	for <netdev@vger.kernel.org>; Wed, 22 Sep 2010 10:38:32 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the PM support is available this is passed
through the platform instead to be hard-coded
in the core files.
WoL on Magic Frame can be enabled by using
the ethtool support.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/common.h         |    1 -
 drivers/net/stmmac/dwmac1000_core.c |    1 -
 drivers/net/stmmac/dwmac100_core.c  |    1 -
 drivers/net/stmmac/stmmac_ethtool.c |   14 +++++++++-----
 drivers/net/stmmac/stmmac_main.c    |   26 ++++++++++++++------------
 include/linux/stmmac.h              |    1 +
 6 files changed, 24 insertions(+), 20 deletions(-)

diff --git a/drivers/net/stmmac/common.h b/drivers/net/stmmac/common.h
index 673ef86..dec7ce4 100644
--- a/drivers/net/stmmac/common.h
+++ b/drivers/net/stmmac/common.h
@@ -238,7 +238,6 @@ struct mac_device_info {
 	struct stmmac_ops	*mac;
 	struct stmmac_desc_ops	*desc;
 	struct stmmac_dma_ops	*dma;
-	unsigned int pmt;	/* support Power-Down */
 	struct mii_regs mii;	/* MII register Addresses */
 	struct mac_link link;
 };
diff --git a/drivers/net/stmmac/dwmac1000_core.c b/drivers/net/stmmac/dwmac1000_core.c
index c18c859..65667b6 100644
--- a/drivers/net/stmmac/dwmac1000_core.c
+++ b/drivers/net/stmmac/dwmac1000_core.c
@@ -239,7 +239,6 @@ struct mac_device_info *dwmac1000_setup(void __iomem *ioaddr)
 	mac->mac = &dwmac1000_ops;
 	mac->dma = &dwmac1000_dma_ops;
 
-	mac->pmt = PMT_SUPPORTED;
 	mac->link.port = GMAC_CONTROL_PS;
 	mac->link.duplex = GMAC_CONTROL_DM;
 	mac->link.speed = GMAC_CONTROL_FES;
diff --git a/drivers/net/stmmac/dwmac100_core.c b/drivers/net/stmmac/dwmac100_core.c
index 58a914b..94eeccf 100644
--- a/drivers/net/stmmac/dwmac100_core.c
+++ b/drivers/net/stmmac/dwmac100_core.c
@@ -193,7 +193,6 @@ struct mac_device_info *dwmac100_setup(void __iomem *ioaddr)
 	mac->mac = &dwmac100_ops;
 	mac->dma = &dwmac100_dma_ops;
 
-	mac->pmt = PMT_NOT_SUPPORTED;
 	mac->link.port = MAC_CONTROL_PS;
 	mac->link.duplex = MAC_CONTROL_F;
 	mac->link.speed = 0;
diff --git a/drivers/net/stmmac/stmmac_ethtool.c b/drivers/net/stmmac/stmmac_ethtool.c
index b32c16a..25a7e38 100644
--- a/drivers/net/stmmac/stmmac_ethtool.c
+++ b/drivers/net/stmmac/stmmac_ethtool.c
@@ -322,7 +322,7 @@ static void stmmac_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 	struct stmmac_priv *priv = netdev_priv(dev);
 
 	spin_lock_irq(&priv->lock);
-	if (priv->wolenabled == PMT_SUPPORTED) {
+	if (device_can_wakeup(priv->device)) {
 		wol->supported = WAKE_MAGIC;
 		wol->wolopts = priv->wolopts;
 	}
@@ -334,16 +334,20 @@ static int stmmac_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 	struct stmmac_priv *priv = netdev_priv(dev);
 	u32 support = WAKE_MAGIC;
 
-	if (priv->wolenabled == PMT_NOT_SUPPORTED)
+	if (!device_can_wakeup(priv->device))
 		return -EINVAL;
 
 	if (wol->wolopts & ~support)
 		return -EINVAL;
 
-	if (wol->wolopts == 0)
-		device_set_wakeup_enable(priv->device, 0);
-	else
+	if (wol->wolopts) {
+		pr_info("stmmac: wakeup enable\n");
 		device_set_wakeup_enable(priv->device, 1);
+		enable_irq_wake(dev->irq);
+	} else {
+		device_set_wakeup_enable(priv->device, 0);
+		disable_irq_wake(dev->irq);
+	}
 
 	spin_lock_irq(&priv->lock);
 	priv->wolopts = wol->wolopts;
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index a908f72..823b9e6 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -1568,9 +1568,8 @@ static int stmmac_mac_device_setup(struct net_device *dev)
 
 	priv->hw = device;
 
-	priv->wolenabled = priv->hw->pmt;	/* PMT supported */
-	if (priv->wolenabled == PMT_SUPPORTED)
-		priv->wolopts = WAKE_MAGIC;		/* Magic Frame */
+	if (device_can_wakeup(priv->device))
+		priv->wolopts = WAKE_MAGIC; /* Magic Frame as default */
 
 	return 0;
 }
@@ -1709,6 +1708,12 @@ static int stmmac_dvr_probe(struct platform_device *pdev)
 	priv->enh_desc = plat_dat->enh_desc;
 	priv->ioaddr = addr;
 
+	/* PMT module is not integrated in all the MAC devices. */
+	if (plat_dat->pmt) {
+		pr_info("\tPMT module supported\n");
+		device_set_wakeup_capable(&pdev->dev, 1);
+	}
+
 	platform_set_drvdata(pdev, ndev);
 
 	/* Set the I/O base addr */
@@ -1836,13 +1841,11 @@ static int stmmac_suspend(struct platform_device *pdev, pm_message_t state)
 
 		stmmac_mac_disable_tx(priv->ioaddr);
 
-		if (device_may_wakeup(&(pdev->dev))) {
-			/* Enable Power down mode by programming the PMT regs */
-			if (priv->wolenabled == PMT_SUPPORTED)
-				priv->hw->mac->pmt(priv->ioaddr, priv->wolopts);
-		} else {
+		/* Enable Power down mode by programming the PMT regs */
+		if (device_can_wakeup(priv->device))
+			priv->hw->mac->pmt(priv->ioaddr, priv->wolopts);
+		else
 			stmmac_mac_disable_rx(priv->ioaddr);
-		}
 	} else {
 		priv->shutdown = 1;
 		/* Although this can appear slightly redundant it actually
@@ -1877,9 +1880,8 @@ static int stmmac_resume(struct platform_device *pdev)
 	 * is received. Anyway, it's better to manually clear
 	 * this bit because it can generate problems while resuming
 	 * from another devices (e.g. serial console). */
-	if (device_may_wakeup(&(pdev->dev)))
-		if (priv->wolenabled == PMT_SUPPORTED)
-			priv->hw->mac->pmt(priv->ioaddr, 0);
+	if (device_can_wakeup(priv->device))
+		priv->hw->mac->pmt(priv->ioaddr, 0);
 
 	netif_device_attach(dev);
 
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index 1d8baf7..d66c617 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -37,6 +37,7 @@ struct plat_stmmacenet_data {
 	int enh_desc;
 	int tx_coe;
 	int bugged_jumbo;
+	int pmt;
 	void (*fix_mac_speed)(void *priv, unsigned int speed);
 	void (*bus_setup)(void __iomem *ioaddr);
 #ifdef CONFIG_STM_DRIVERS
-- 
1.5.5.6

