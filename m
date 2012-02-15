From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 3/4] stmmac: move hw init in the probe (v2)
Date: Wed, 15 Feb 2012 11:10:39 +0100
Message-ID: <1329300640-12813-3-git-send-email-peppe.cavallaro@st.com>
References: <4F3B8101.1090509@st.com>
 <1329300640-12813-1-git-send-email-peppe.cavallaro@st.com>
Cc: davem@davemloft.net, Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:51962 "EHLO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757017Ab2BOKLF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 05:11:05 -0500
In-Reply-To: <1329300640-12813-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch moves the MAC HW initialization and
the HW feature verification from the open to the probe
function as D. Miller suggested.
So the patch actually reorganizes and tidies-up some parts of
the driver and indeed fixes some problem when tune its HW features.
These can be overwritten by looking at the HW cap register at
run-time and that generated problems.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Reviewed-by: Francesco Virlinzi <francesco.virlinzi@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    3 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  189 ++++++++++----------
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c   |    6 +-
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   23 +--
 4 files changed, 105 insertions(+), 116 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 1207400..6ca2aa3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -97,4 +97,5 @@ int stmmac_resume(struct net_device *ndev);
 int stmmac_suspend(struct net_device *ndev);
 int stmmac_dvr_remove(struct net_device *ndev);
 struct stmmac_priv *stmmac_dvr_probe(struct device *device,
-				struct plat_stmmacenet_data *plat_dat);
+				     struct plat_stmmacenet_data *plat_dat,
+				     void __iomem *addr);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 970a3f4..6ee593a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -241,7 +241,7 @@ static void stmmac_adjust_link(struct net_device *dev)
 			case 1000:
 				if (likely(priv->plat->has_gmac))
 					ctrl &= ~priv->hw->link.port;
-				stmmac_hw_fix_mac_speed(priv);
+					stmmac_hw_fix_mac_speed(priv);
 				break;
 			case 100:
 			case 10:
@@ -785,7 +785,7 @@ static u32 stmmac_get_synopsys_id(struct stmmac_priv *priv)
 		u32 uid = ((hwid & 0x0000ff00) >> 8);
 		u32 synid = (hwid & 0x000000ff);
 
-		pr_info("STMMAC - user ID: 0x%x, Synopsys ID: 0x%x\n",
+		pr_info("stmmac - user ID: 0x%x, Synopsys ID: 0x%x\n",
 			uid, synid);
 
 		return synid;
@@ -869,38 +869,6 @@ static int stmmac_get_hw_features(struct stmmac_priv *priv)
 	return hw_cap;
 }
 
-/**
- * stmmac_mac_device_setup
- * @dev : device pointer
- * Description: this is to attach the GMAC or MAC 10/100
- * main core structures that will be completed during the
- * open step.
- */
-static int stmmac_mac_device_setup(struct net_device *dev)
-{
-	struct stmmac_priv *priv = netdev_priv(dev);
-
-	struct mac_device_info *device;
-
-	if (priv->plat->has_gmac)
-		device = dwmac1000_setup(priv->ioaddr);
-	else
-		device = dwmac100_setup(priv->ioaddr);
-
-	if (!device)
-		return -ENOMEM;
-
-	priv->hw = device;
-	priv->hw->ring = &ring_mode_ops;
-
-	if (device_can_wakeup(priv->device)) {
-		priv->wolopts = WAKE_MAGIC; /* Magic Frame as default */
-		enable_irq_wake(priv->wol_irq);
-	}
-
-	return 0;
-}
-
 static void stmmac_check_ether_addr(struct stmmac_priv *priv)
 {
 	/* verify if the MAC address is valid, in case of failures it
@@ -930,20 +898,8 @@ static int stmmac_open(struct net_device *dev)
 	struct stmmac_priv *priv = netdev_priv(dev);
 	int ret;
 
-	/* MAC HW device setup */
-	ret = stmmac_mac_device_setup(dev);
-	if (ret < 0)
-		return ret;
-
 	stmmac_check_ether_addr(priv);
 
-	stmmac_verify_args();
-
-	/* Override with kernel parameters if supplied XXX CRS XXX
-	 * this needs to have multiple instances */
-	if ((phyaddr >= 0) && (phyaddr <= 31))
-		priv->plat->phy_addr = phyaddr;
-
 	/* MDIO bus Registration */
 	ret = stmmac_mdio_register(dev);
 	if (ret < 0) {
@@ -976,44 +932,6 @@ static int stmmac_open(struct net_device *dev)
 		goto open_error;
 	}
 
-	stmmac_get_synopsys_id(priv);
-
-	priv->hw_cap_support = stmmac_get_hw_features(priv);
-
-	if (priv->hw_cap_support) {
-		pr_info(" Support DMA HW capability register");
-
-		/* We can override some gmac/dma configuration fields: e.g.
-		 * enh_desc, tx_coe (e.g. that are passed through the
-		 * platform) with the values from the HW capability
-		 * register (if supported).
-		 */
-		priv->plat->enh_desc = priv->dma_cap.enh_desc;
-		priv->plat->tx_coe = priv->dma_cap.tx_coe;
-		priv->plat->pmt = priv->dma_cap.pmt_remote_wake_up;
-
-		/* By default disable wol on magic frame if not supported */
-		if (!priv->dma_cap.pmt_magic_frame)
-			priv->wolopts &= ~WAKE_MAGIC;
-
-	} else
-		pr_info(" No HW DMA feature register supported");
-
-	/* Select the enhnaced/normal descriptor structures */
-	stmmac_selec_desc_mode(priv);
-
-	/* PMT module is not integrated in all the MAC devices. */
-	if (priv->plat->pmt) {
-		pr_info(" Remote wake-up capable\n");
-		device_set_wakeup_capable(priv->device, 1);
-	}
-
-	priv->rx_coe = priv->hw->mac->rx_coe(priv->ioaddr);
-	if (priv->rx_coe)
-		pr_info(" Checksum Offload Engine supported\n");
-	if (priv->plat->tx_coe)
-		pr_info(" Checksum insertion supported\n");
-
 	/* Create and initialize the TX/RX descriptors chains. */
 	priv->dma_tx_size = STMMAC_ALIGN(dma_txsize);
 	priv->dma_rx_size = STMMAC_ALIGN(dma_rxsize);
@@ -1030,14 +948,14 @@ static int stmmac_open(struct net_device *dev)
 
 	/* Copy the MAC addr into the HW  */
 	priv->hw->mac->set_umac_addr(priv->ioaddr, dev->dev_addr, 0);
+
 	/* If required, perform hw setup of the bus. */
 	if (priv->plat->bus_setup)
 		priv->plat->bus_setup(priv->ioaddr);
+
 	/* Initialize the MAC Core */
 	priv->hw->mac->core_init(priv->ioaddr);
 
-	netdev_update_features(dev);
-
 	/* Request the IRQ lines */
 	ret = request_irq(dev->irq, stmmac_interrupt,
 			 IRQF_SHARED, dev->name, dev);
@@ -1073,7 +991,7 @@ static int stmmac_open(struct net_device *dev)
 #ifdef CONFIG_STMMAC_DEBUG_FS
 	ret = stmmac_init_fs(dev);
 	if (ret < 0)
-		pr_warning("\tFailed debugFS registration");
+		pr_warning("%s: failed debugFS registration\n", __func__);
 #endif
 	/* Start the ball rolling... */
 	DBG(probe, DEBUG, "%s: DMA RX/TX processes started...\n", dev->name);
@@ -1083,6 +1001,7 @@ static int stmmac_open(struct net_device *dev)
 #ifdef CONFIG_STMMAC_TIMER
 	priv->tm->timer_start(tmrate);
 #endif
+
 	/* Dump DMA/MAC registers */
 	if (netif_msg_hw(priv)) {
 		priv->hw->mac->dump_regs(priv->ioaddr);
@@ -1805,13 +1724,77 @@ static const struct net_device_ops stmmac_netdev_ops = {
 };
 
 /**
+ *  stmmac_hw_init - Init the MAC device
+ *  @priv : pointer to the private device structure.
+ *  Description: this function detects which MAC device
+ *  (GMAC/MAC10-100) has to attached, checks the HW capability
+ *  (if supported) and sets the driver's features (for example
+ *  to use the ring or chaine mode or support the normal/enh
+ *  descriptor structure).
+ */
+static int stmmac_hw_init(struct stmmac_priv *priv)
+{
+	int ret = 0;
+	struct mac_device_info *mac;
+
+	/* Identify the MAC HW device */
+	if (priv->plat->has_gmac)
+		mac = dwmac1000_setup(priv->ioaddr);
+	else
+		mac = dwmac100_setup(priv->ioaddr);
+	if (!mac)
+		return -ENOMEM;
+
+	priv->hw = mac;
+
+	/* To use the chained or ring mode */
+	priv->hw->ring = &ring_mode_ops;
+
+	/* Get and dump the chip ID */
+	stmmac_get_synopsys_id(priv);
+
+	/* Get the HW capability (new GMAC newer than 3.50a) */
+	priv->hw_cap_support = stmmac_get_hw_features(priv);
+	if (priv->hw_cap_support) {
+		pr_info(" DMA HW capability register supported");
+
+		/* We can override some gmac/dma configuration fields: e.g.
+		 * enh_desc, tx_coe (e.g. that are passed through the
+		 * platform) with the values from the HW capability
+		 * register (if supported).
+		 */
+		priv->plat->enh_desc = priv->dma_cap.enh_desc;
+		priv->plat->tx_coe = priv->dma_cap.tx_coe;
+		priv->plat->pmt = priv->dma_cap.pmt_remote_wake_up;
+	} else
+		pr_info(" No HW DMA feature register supported");
+
+	/* Select the enhnaced/normal descriptor structures */
+	stmmac_selec_desc_mode(priv);
+
+	priv->rx_coe = priv->hw->mac->rx_coe(priv->ioaddr);
+	if (priv->rx_coe)
+		pr_info(" RX Checksum Offload Engine supported\n");
+	if (priv->plat->tx_coe)
+		pr_info(" TX Checksum insertion supported\n");
+
+	if (priv->plat->pmt) {
+		pr_info(" Wake-Up On Lan supported\n");
+		device_set_wakeup_capable(priv->device, 1);
+	}
+
+	return ret;
+}
+
+/**
  * stmmac_dvr_probe
  * @device: device pointer
  * Description: this is the main probe function used to
  * call the alloc_etherdev, allocate the priv structure.
  */
 struct stmmac_priv *stmmac_dvr_probe(struct device *device,
-					struct plat_stmmacenet_data *plat_dat)
+				     struct plat_stmmacenet_data *plat_dat,
+				     void __iomem *addr)
 {
 	int ret = 0;
 	struct net_device *ndev = NULL;
@@ -1831,10 +1814,27 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 
 	ether_setup(ndev);
 
-	ndev->netdev_ops = &stmmac_netdev_ops;
 	stmmac_set_ethtool_ops(ndev);
+	priv->pause = pause;
+	priv->plat = plat_dat;
+	priv->ioaddr = addr;
+	priv->dev->base_addr = (unsigned long)addr;
+
+	/* Verify driver arguments */
+	stmmac_verify_args();
 
-	ndev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
+	/* Override with kernel parameters if supplied XXX CRS XXX
+	 * this needs to have multiple instances */
+	if ((phyaddr >= 0) && (phyaddr <= 31))
+		priv->plat->phy_addr = phyaddr;
+
+	/* Init MAC and get the capabilities */
+	stmmac_hw_init(priv);
+
+	ndev->netdev_ops = &stmmac_netdev_ops;
+
+	ndev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
+			    NETIF_F_RXCSUM;
 	ndev->features |= ndev->hw_features | NETIF_F_HIGHDMA;
 	ndev->watchdog_timeo = msecs_to_jiffies(watchdog);
 #ifdef STMMAC_VLAN_TAG_USED
@@ -1846,8 +1846,6 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 	if (flow_ctrl)
 		priv->flow_ctrl = FLOW_AUTO;	/* RX/TX pause on */
 
-	priv->pause = pause;
-	priv->plat = plat_dat;
 	netif_napi_add(ndev, &priv->napi, stmmac_poll, 64);
 
 	spin_lock_init(&priv->lock);
@@ -1855,15 +1853,10 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 
 	ret = register_netdev(ndev);
 	if (ret) {
-		pr_err("%s: ERROR %i registering the device\n",
-		       __func__, ret);
+		pr_err("%s: ERROR %i registering the device\n", __func__, ret);
 		goto error;
 	}
 
-	DBG(probe, DEBUG, "%s: Scatter/Gather: %s - HW checksums: %s\n",
-	    ndev->name, (ndev->features & NETIF_F_SG) ? "on" : "off",
-	    (ndev->features & NETIF_F_IP_CSUM) ? "on" : "off");
-
 	return priv;
 
 error:
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index c796de9..50ad5b8 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -96,13 +96,11 @@ static int __devinit stmmac_pci_probe(struct pci_dev *pdev,
 
 	stmmac_default_data();
 
-	priv = stmmac_dvr_probe(&(pdev->dev), &plat_dat);
+	priv = stmmac_dvr_probe(&(pdev->dev), &plat_dat, addr);
 	if (!priv) {
-		pr_err("%s: main drivr probe failed", __func__);
+		pr_err("%s: main driver probe failed", __func__);
 		goto err_out;
 	}
-	priv->ioaddr = addr;
-	priv->dev->base_addr = (unsigned long)addr;
 	priv->dev->irq = pdev->irq;
 	priv->wol_irq = pdev->irq;
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 1ac8324..3aad981 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -59,16 +59,20 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
 		goto out_release_region;
 	}
 	plat_dat = pdev->dev.platform_data;
-	priv = stmmac_dvr_probe(&(pdev->dev), plat_dat);
+
+	/* Custom initialisation (if needed)*/
+	if (plat_dat->init) {
+		ret = plat_dat->init(pdev);
+		if (unlikely(ret))
+			goto out_unmap;
+	}
+
+	priv = stmmac_dvr_probe(&(pdev->dev), plat_dat, addr);
 	if (!priv) {
-		pr_err("%s: main drivr probe failed", __func__);
+		pr_err("%s: main driver probe failed", __func__);
 		goto out_unmap;
 	}
 
-	priv->ioaddr = addr;
-	/* Set the I/O base addr */
-	priv->dev->base_addr = (unsigned long)addr;
-
 	/* Get the MAC information */
 	priv->dev->irq = platform_get_irq_byname(pdev, "macirq");
 	if (priv->dev->irq == -ENXIO) {
@@ -92,13 +96,6 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
 
 	platform_set_drvdata(pdev, priv->dev);
 
-	/* Custom initialisation */
-	if (priv->plat->init) {
-		ret = priv->plat->init(pdev);
-		if (unlikely(ret))
-			goto out_unmap;
-	}
-
 	pr_debug("STMMAC platform driver registration completed");
 
 	return 0;
-- 
1.7.4.4
