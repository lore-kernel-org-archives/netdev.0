From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 3/5] stmmac: parameters auto-tuning through HW cap reg
Date: Thu, 17 Nov 2011 08:58:00 +0100
Message-ID: <1321516682-32208-3-git-send-email-peppe.cavallaro@st.com>
References: <1321516682-32208-1-git-send-email-peppe.cavallaro@st.com>
Cc: francesco.virlinzi@st.com, srinivas.kandagatla@st.com,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:58068 "EHLO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753445Ab1KQH6V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 02:58:21 -0500
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id C964B2DB
	for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 07:58:18 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 932E41905
	for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 07:58:18 +0000 (GMT)
In-Reply-To: <1321516682-32208-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New GMAC devices (newer than the databook 3.50a) have the
HW capability register that provides which features are actually
supported by the hardware.

On old devices many information have to be passed through the
platform, for example: enhanced descriptor structure,
TX COE etc. These are mandatory to properly configure the driver.
This remains still valid because the driver has to support old
Synopsys devices but now it's also able to override them using the
values from the HW capability register if supported.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    2 +-
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |    6 ++
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   93 ++++++++++++++------
 3 files changed, 72 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 9bafa6c..a140a8f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -72,7 +72,6 @@ struct stmmac_priv {
 	spinlock_t lock;
 	spinlock_t tx_lock;
 	int wolopts;
-	int wolenabled;
 	int wol_irq;
 #ifdef CONFIG_STMMAC_TIMER
 	struct stmmac_timer *tm;
@@ -80,6 +79,7 @@ struct stmmac_priv {
 	struct plat_stmmacenet_data *plat;
 	struct stmmac_counters mmc;
 	struct dma_features dma_cap;
+	int hw_cap_support;
 };
 
 extern int stmmac_mdio_unregister(struct net_device *ndev);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index e8eff09..0395f9e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -430,6 +430,12 @@ static int stmmac_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 	struct stmmac_priv *priv = netdev_priv(dev);
 	u32 support = WAKE_MAGIC | WAKE_UCAST;
 
+	/* By default almost all GMAC devices support the WoL via
+	 * magic frame but we can disable it if the HW capability
+	 * register shows no support for pmt_magic_frame. */
+	if ((priv->hw_cap_support) && (!priv->dma_cap.pmt_magic_frame))
+		wol->wolopts &= ~WAKE_MAGIC;
+
 	if (!device_can_wakeup(priv->device))
 		return -EINVAL;
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index e079762..7f3ffd3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -805,8 +805,29 @@ static u32 stmmac_get_synopsys_id(struct stmmac_priv *priv)
 	return 0;
 }
 
-/* New GMAC chips support a new register to indicate the
- * presence of the optional feature/functions.
+/**
+ * stmmac_selec_desc_mode
+ * @dev : device pointer
+ * Description: select the Enhanced/Alternate or Normal descriptors */
+static void stmmac_selec_desc_mode(struct stmmac_priv *priv)
+{
+	if (priv->plat->enh_desc) {
+		pr_info(" Enhanced/Alternate descriptors\n");
+		priv->hw->desc = &enh_desc_ops;
+	} else {
+		pr_info(" Normal descriptors\n");
+		priv->hw->desc = &ndesc_ops;
+	}
+}
+
+/**
+ * stmmac_get_hw_features
+ * @priv : private device pointer
+ * Description:
+ *  new GMAC chip generations have a new register to indicate the
+ *  presence of the optional feature/functions.
+ *  This can be also used to override the value passed through the
+ *  platform and necessary for old MAC10/100 and GMAC chips.
  */
 static int stmmac_get_hw_features(struct stmmac_priv *priv)
 {
@@ -827,7 +848,7 @@ static int stmmac_get_hw_features(struct stmmac_priv *priv)
 			(hw_cap & DMA_HW_FEAT_RWKSEL) >> 9;
 		priv->dma_cap.pmt_magic_frame =
 			(hw_cap & DMA_HW_FEAT_MGKSEL) >> 10;
-		/*MMC*/
+		/* MMC */
 		priv->dma_cap.rmon = (hw_cap & DMA_HW_FEAT_MMCSEL) >> 11;
 		/* IEEE 1588-2002*/
 		priv->dma_cap.time_stamp =
@@ -855,8 +876,7 @@ static int stmmac_get_hw_features(struct stmmac_priv *priv)
 		priv->dma_cap.enh_desc =
 			(hw_cap & DMA_HW_FEAT_ENHDESSEL) >> 24;
 
-	} else
-		pr_debug("\tNo HW DMA feature register supported");
+	}
 
 	return hw_cap;
 }
@@ -911,6 +931,44 @@ static int stmmac_open(struct net_device *dev)
 		goto open_error;
 	}
 
+	stmmac_get_synopsys_id(priv);
+
+	priv->hw_cap_support = stmmac_get_hw_features(priv);
+
+	if (priv->hw_cap_support) {
+		pr_info(" Support DMA HW capability register");
+
+		/* We can override some gmac/dma configuration fields: e.g.
+		 * enh_desc, tx_coe (e.g. that are passed through the
+		 * platform) with the values from the HW capability
+		 * register (if supported).
+		 */
+		priv->plat->enh_desc = priv->dma_cap.enh_desc;
+		priv->plat->tx_coe = priv->dma_cap.tx_coe;
+		priv->plat->pmt = priv->dma_cap.pmt_remote_wake_up;
+
+		/* By default disable wol on magic frame if not supported */
+		if (!priv->dma_cap.pmt_magic_frame)
+			priv->wolopts &= ~WAKE_MAGIC;
+
+	} else
+		pr_info(" No HW DMA feature register supported");
+
+	/* Select the enhnaced/normal descriptor structures */
+	stmmac_selec_desc_mode(priv);
+
+	/* PMT module is not integrated in all the MAC devices. */
+	if (priv->plat->pmt) {
+		pr_info(" Remote wake-up capable\n");
+		device_set_wakeup_capable(priv->device, 1);
+	}
+
+	priv->rx_coe = priv->hw->mac->rx_coe(priv->ioaddr);
+	if (priv->rx_coe)
+		pr_info(" Checksum Offload Engine supported\n");
+	if (priv->plat->tx_coe)
+		pr_info(" Checksum insertion supported\n");
+
 	/* Create and initialize the TX/RX descriptors chains. */
 	priv->dma_tx_size = STMMAC_ALIGN(dma_txsize);
 	priv->dma_rx_size = STMMAC_ALIGN(dma_rxsize);
@@ -933,15 +991,6 @@ static int stmmac_open(struct net_device *dev)
 	/* Initialize the MAC Core */
 	priv->hw->mac->core_init(priv->ioaddr);
 
-	stmmac_get_synopsys_id(priv);
-
-	stmmac_get_hw_features(priv);
-
-	priv->rx_coe = priv->hw->mac->rx_coe(priv->ioaddr);
-	if (priv->rx_coe)
-		pr_info("stmmac: Rx Checksum Offload Engine supported\n");
-	if (priv->plat->tx_coe)
-		pr_info("\tTX Checksum insertion supported\n");
 	netdev_update_features(dev);
 
 	/* Request the IRQ lines */
@@ -1556,7 +1605,7 @@ static int stmmac_sysfs_dma_cap_read(struct seq_file *seq, void *v)
 	struct net_device *dev = seq->private;
 	struct stmmac_priv *priv = netdev_priv(dev);
 
-	if (!stmmac_get_hw_features(priv)) {
+	if (!priv->hw_cap_support) {
 		seq_printf(seq, "DMA HW features not supported\n");
 		return 0;
 	}
@@ -1764,12 +1813,6 @@ static int stmmac_mac_device_setup(struct net_device *dev)
 	if (!device)
 		return -ENOMEM;
 
-	if (priv->plat->enh_desc) {
-		device->desc = &enh_desc_ops;
-		pr_info("\tEnhanced descriptor structure\n");
-	} else
-		device->desc = &ndesc_ops;
-
 	priv->hw = device;
 	priv->hw->ring = &ring_mode_ops;
 
@@ -1843,11 +1886,6 @@ static int stmmac_dvr_probe(struct platform_device *pdev)
 
 	priv->ioaddr = addr;
 
-	/* PMT module is not integrated in all the MAC devices. */
-	if (plat_dat->pmt) {
-		pr_info("\tPMT module supported\n");
-		device_set_wakeup_capable(&pdev->dev, 1);
-	}
 	/*
 	 * On some platforms e.g. SPEAr the wake up irq differs from the mac irq
 	 * The external wake up irq can be passed through the platform code
@@ -1860,7 +1898,6 @@ static int stmmac_dvr_probe(struct platform_device *pdev)
 	if (priv->wol_irq == -ENXIO)
 		priv->wol_irq = ndev->irq;
 
-
 	platform_set_drvdata(pdev, ndev);
 
 	/* Set the I/O base addr */
@@ -1873,7 +1910,7 @@ static int stmmac_dvr_probe(struct platform_device *pdev)
 			goto out_free_ndev;
 	}
 
-	/* MAC HW revice detection */
+	/* MAC HW device detection */
 	ret = stmmac_mac_device_setup(ndev);
 	if (ret < 0)
 		goto out_plat_exit;
-- 
1.7.4.4
