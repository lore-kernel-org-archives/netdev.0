From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 2/8] r8169: move the driver probe method to the end of the driver file.
Date: Sat, 10 Mar 2012 23:19:04 +0100
Message-ID: <20120310221904.GC9692@electric-eye.fr.zoreil.com>
References: <20120310221751.GA9692@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:41079 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752673Ab2CJWUR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Mar 2012 17:20:17 -0500
Content-Disposition: inline
In-Reply-To: <20120310221751.GA9692@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c |  492 +++++++++++++++++-----------------
 1 files changed, 246 insertions(+), 246 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index ef6ef60..3455d37 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -4018,251 +4018,6 @@ static void rtl_hw_reset(struct rtl8169_private *tp)
 	}
 }
 
-static int __devinit
-rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
-{
-	const struct rtl_cfg_info *cfg = rtl_cfg_infos + ent->driver_data;
-	const unsigned int region = cfg->region;
-	struct rtl8169_private *tp;
-	struct mii_if_info *mii;
-	struct net_device *dev;
-	void __iomem *ioaddr;
-	int chipset, i;
-	int rc;
-
-	if (netif_msg_drv(&debug)) {
-		printk(KERN_INFO "%s Gigabit Ethernet driver %s loaded\n",
-		       MODULENAME, RTL8169_VERSION);
-	}
-
-	dev = alloc_etherdev(sizeof (*tp));
-	if (!dev) {
-		rc = -ENOMEM;
-		goto out;
-	}
-
-	SET_NETDEV_DEV(dev, &pdev->dev);
-	dev->netdev_ops = &rtl8169_netdev_ops;
-	tp = netdev_priv(dev);
-	tp->dev = dev;
-	tp->pci_dev = pdev;
-	tp->msg_enable = netif_msg_init(debug.msg_enable, R8169_MSG_DEFAULT);
-
-	mii = &tp->mii;
-	mii->dev = dev;
-	mii->mdio_read = rtl_mdio_read;
-	mii->mdio_write = rtl_mdio_write;
-	mii->phy_id_mask = 0x1f;
-	mii->reg_num_mask = 0x1f;
-	mii->supports_gmii = !!(cfg->features & RTL_FEATURE_GMII);
-
-	/* disable ASPM completely as that cause random device stop working
-	 * problems as well as full system hangs for some PCIe devices users */
-	pci_disable_link_state(pdev, PCIE_LINK_STATE_L0S | PCIE_LINK_STATE_L1 |
-				     PCIE_LINK_STATE_CLKPM);
-
-	/* enable device (incl. PCI PM wakeup and hotplug setup) */
-	rc = pci_enable_device(pdev);
-	if (rc < 0) {
-		netif_err(tp, probe, dev, "enable failure\n");
-		goto err_out_free_dev_1;
-	}
-
-	if (pci_set_mwi(pdev) < 0)
-		netif_info(tp, probe, dev, "Mem-Wr-Inval unavailable\n");
-
-	/* make sure PCI base addr 1 is MMIO */
-	if (!(pci_resource_flags(pdev, region) & IORESOURCE_MEM)) {
-		netif_err(tp, probe, dev,
-			  "region #%d not an MMIO resource, aborting\n",
-			  region);
-		rc = -ENODEV;
-		goto err_out_mwi_2;
-	}
-
-	/* check for weird/broken PCI region reporting */
-	if (pci_resource_len(pdev, region) < R8169_REGS_SIZE) {
-		netif_err(tp, probe, dev,
-			  "Invalid PCI region size(s), aborting\n");
-		rc = -ENODEV;
-		goto err_out_mwi_2;
-	}
-
-	rc = pci_request_regions(pdev, MODULENAME);
-	if (rc < 0) {
-		netif_err(tp, probe, dev, "could not request regions\n");
-		goto err_out_mwi_2;
-	}
-
-	tp->cp_cmd = RxChkSum;
-
-	if ((sizeof(dma_addr_t) > 4) &&
-	    !pci_set_dma_mask(pdev, DMA_BIT_MASK(64)) && use_dac) {
-		tp->cp_cmd |= PCIDAC;
-		dev->features |= NETIF_F_HIGHDMA;
-	} else {
-		rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
-		if (rc < 0) {
-			netif_err(tp, probe, dev, "DMA configuration failed\n");
-			goto err_out_free_res_3;
-		}
-	}
-
-	/* ioremap MMIO region */
-	ioaddr = ioremap(pci_resource_start(pdev, region), R8169_REGS_SIZE);
-	if (!ioaddr) {
-		netif_err(tp, probe, dev, "cannot remap MMIO, aborting\n");
-		rc = -EIO;
-		goto err_out_free_res_3;
-	}
-	tp->mmio_addr = ioaddr;
-
-	if (!pci_is_pcie(pdev))
-		netif_info(tp, probe, dev, "not PCI Express\n");
-
-	/* Identify chip attached to board */
-	rtl8169_get_mac_version(tp, dev, cfg->default_ver);
-
-	rtl_init_rxcfg(tp);
-
-	rtl_irq_disable(tp);
-
-	rtl_hw_reset(tp);
-
-	rtl_ack_events(tp, 0xffff);
-
-	pci_set_master(pdev);
-
-	/*
-	 * Pretend we are using VLANs; This bypasses a nasty bug where
-	 * Interrupts stop flowing on high load on 8110SCd controllers.
-	 */
-	if (tp->mac_version == RTL_GIGA_MAC_VER_05)
-		tp->cp_cmd |= RxVlan;
-
-	rtl_init_mdio_ops(tp);
-	rtl_init_pll_power_ops(tp);
-	rtl_init_jumbo_ops(tp);
-
-	rtl8169_print_mac_version(tp);
-
-	chipset = tp->mac_version;
-	tp->txd_version = rtl_chip_infos[chipset].txd_version;
-
-	RTL_W8(Cfg9346, Cfg9346_Unlock);
-	RTL_W8(Config1, RTL_R8(Config1) | PMEnable);
-	RTL_W8(Config5, RTL_R8(Config5) & PMEStatus);
-	if ((RTL_R8(Config3) & (LinkUp | MagicPacket)) != 0)
-		tp->features |= RTL_FEATURE_WOL;
-	if ((RTL_R8(Config5) & (UWF | BWF | MWF)) != 0)
-		tp->features |= RTL_FEATURE_WOL;
-	tp->features |= rtl_try_msi(tp, cfg);
-	RTL_W8(Cfg9346, Cfg9346_Lock);
-
-	if (rtl_tbi_enabled(tp)) {
-		tp->set_speed = rtl8169_set_speed_tbi;
-		tp->get_settings = rtl8169_gset_tbi;
-		tp->phy_reset_enable = rtl8169_tbi_reset_enable;
-		tp->phy_reset_pending = rtl8169_tbi_reset_pending;
-		tp->link_ok = rtl8169_tbi_link_ok;
-		tp->do_ioctl = rtl_tbi_ioctl;
-	} else {
-		tp->set_speed = rtl8169_set_speed_xmii;
-		tp->get_settings = rtl8169_gset_xmii;
-		tp->phy_reset_enable = rtl8169_xmii_reset_enable;
-		tp->phy_reset_pending = rtl8169_xmii_reset_pending;
-		tp->link_ok = rtl8169_xmii_link_ok;
-		tp->do_ioctl = rtl_xmii_ioctl;
-	}
-
-	mutex_init(&tp->wk.mutex);
-
-	/* Get MAC address */
-	for (i = 0; i < ETH_ALEN; i++)
-		dev->dev_addr[i] = RTL_R8(MAC0 + i);
-	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
-
-	SET_ETHTOOL_OPS(dev, &rtl8169_ethtool_ops);
-	dev->watchdog_timeo = RTL8169_TX_TIMEOUT;
-	dev->irq = pdev->irq;
-	dev->base_addr = (unsigned long) ioaddr;
-
-	netif_napi_add(dev, &tp->napi, rtl8169_poll, R8169_NAPI_WEIGHT);
-
-	/* don't enable SG, IP_CSUM and TSO by default - it might not work
-	 * properly for all devices */
-	dev->features |= NETIF_F_RXCSUM |
-		NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-
-	dev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO |
-		NETIF_F_RXCSUM | NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-	dev->vlan_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO |
-		NETIF_F_HIGHDMA;
-
-	if (tp->mac_version == RTL_GIGA_MAC_VER_05)
-		/* 8110SCd requires hardware Rx VLAN - disallow toggling */
-		dev->hw_features &= ~NETIF_F_HW_VLAN_RX;
-
-	dev->hw_features |= NETIF_F_RXALL;
-	dev->hw_features |= NETIF_F_RXFCS;
-
-	tp->hw_start = cfg->hw_start;
-	tp->event_slow = cfg->event_slow;
-
-	tp->opts1_mask = (tp->mac_version != RTL_GIGA_MAC_VER_01) ?
-		~(RxBOVF | RxFOVF) : ~0;
-
-	init_timer(&tp->timer);
-	tp->timer.data = (unsigned long) dev;
-	tp->timer.function = rtl8169_phy_timer;
-
-	tp->rtl_fw = RTL_FIRMWARE_UNKNOWN;
-
-	rc = register_netdev(dev);
-	if (rc < 0)
-		goto err_out_msi_4;
-
-	pci_set_drvdata(pdev, dev);
-
-	netif_info(tp, probe, dev, "%s at 0x%lx, %pM, XID %08x IRQ %d\n",
-		   rtl_chip_infos[chipset].name, dev->base_addr, dev->dev_addr,
-		   (u32)(RTL_R32(TxConfig) & 0x9cf0f8ff), dev->irq);
-	if (rtl_chip_infos[chipset].jumbo_max != JUMBO_1K) {
-		netif_info(tp, probe, dev, "jumbo features [frames: %d bytes, "
-			   "tx checksumming: %s]\n",
-			   rtl_chip_infos[chipset].jumbo_max,
-			   rtl_chip_infos[chipset].jumbo_tx_csum ? "ok" : "ko");
-	}
-
-	if (tp->mac_version == RTL_GIGA_MAC_VER_27 ||
-	    tp->mac_version == RTL_GIGA_MAC_VER_28 ||
-	    tp->mac_version == RTL_GIGA_MAC_VER_31) {
-		rtl8168_driver_start(tp);
-	}
-
-	device_set_wakeup_enable(&pdev->dev, tp->features & RTL_FEATURE_WOL);
-
-	if (pci_dev_run_wake(pdev))
-		pm_runtime_put_noidle(&pdev->dev);
-
-	netif_carrier_off(dev);
-
-out:
-	return rc;
-
-err_out_msi_4:
-	rtl_disable_msi(pdev, tp);
-	iounmap(ioaddr);
-err_out_free_res_3:
-	pci_release_regions(pdev);
-err_out_mwi_2:
-	pci_clear_mwi(pdev);
-	pci_disable_device(pdev);
-err_out_free_dev_1:
-	free_netdev(dev);
-	goto out;
-}
-
 static void rtl_request_uncached_firmware(struct rtl8169_private *tp)
 {
 	struct rtl_fw *rtl_fw;
@@ -6316,10 +6071,255 @@ static void __devexit rtl_remove_one(struct pci_dev *pdev)
 	pci_set_drvdata(pdev, NULL);
 }
 
+static int __devinit
+rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
+{
+	const struct rtl_cfg_info *cfg = rtl_cfg_infos + ent->driver_data;
+	const unsigned int region = cfg->region;
+	struct rtl8169_private *tp;
+	struct mii_if_info *mii;
+	struct net_device *dev;
+	void __iomem *ioaddr;
+	int chipset, i;
+	int rc;
+
+	if (netif_msg_drv(&debug)) {
+		printk(KERN_INFO "%s Gigabit Ethernet driver %s loaded\n",
+		       MODULENAME, RTL8169_VERSION);
+	}
+
+	dev = alloc_etherdev(sizeof (*tp));
+	if (!dev) {
+		rc = -ENOMEM;
+		goto out;
+	}
+
+	SET_NETDEV_DEV(dev, &pdev->dev);
+	dev->netdev_ops = &rtl8169_netdev_ops;
+	tp = netdev_priv(dev);
+	tp->dev = dev;
+	tp->pci_dev = pdev;
+	tp->msg_enable = netif_msg_init(debug.msg_enable, R8169_MSG_DEFAULT);
+
+	mii = &tp->mii;
+	mii->dev = dev;
+	mii->mdio_read = rtl_mdio_read;
+	mii->mdio_write = rtl_mdio_write;
+	mii->phy_id_mask = 0x1f;
+	mii->reg_num_mask = 0x1f;
+	mii->supports_gmii = !!(cfg->features & RTL_FEATURE_GMII);
+
+	/* disable ASPM completely as that cause random device stop working
+	 * problems as well as full system hangs for some PCIe devices users */
+	pci_disable_link_state(pdev, PCIE_LINK_STATE_L0S | PCIE_LINK_STATE_L1 |
+				     PCIE_LINK_STATE_CLKPM);
+
+	/* enable device (incl. PCI PM wakeup and hotplug setup) */
+	rc = pci_enable_device(pdev);
+	if (rc < 0) {
+		netif_err(tp, probe, dev, "enable failure\n");
+		goto err_out_free_dev_1;
+	}
+
+	if (pci_set_mwi(pdev) < 0)
+		netif_info(tp, probe, dev, "Mem-Wr-Inval unavailable\n");
+
+	/* make sure PCI base addr 1 is MMIO */
+	if (!(pci_resource_flags(pdev, region) & IORESOURCE_MEM)) {
+		netif_err(tp, probe, dev,
+			  "region #%d not an MMIO resource, aborting\n",
+			  region);
+		rc = -ENODEV;
+		goto err_out_mwi_2;
+	}
+
+	/* check for weird/broken PCI region reporting */
+	if (pci_resource_len(pdev, region) < R8169_REGS_SIZE) {
+		netif_err(tp, probe, dev,
+			  "Invalid PCI region size(s), aborting\n");
+		rc = -ENODEV;
+		goto err_out_mwi_2;
+	}
+
+	rc = pci_request_regions(pdev, MODULENAME);
+	if (rc < 0) {
+		netif_err(tp, probe, dev, "could not request regions\n");
+		goto err_out_mwi_2;
+	}
+
+	tp->cp_cmd = RxChkSum;
+
+	if ((sizeof(dma_addr_t) > 4) &&
+	    !pci_set_dma_mask(pdev, DMA_BIT_MASK(64)) && use_dac) {
+		tp->cp_cmd |= PCIDAC;
+		dev->features |= NETIF_F_HIGHDMA;
+	} else {
+		rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
+		if (rc < 0) {
+			netif_err(tp, probe, dev, "DMA configuration failed\n");
+			goto err_out_free_res_3;
+		}
+	}
+
+	/* ioremap MMIO region */
+	ioaddr = ioremap(pci_resource_start(pdev, region), R8169_REGS_SIZE);
+	if (!ioaddr) {
+		netif_err(tp, probe, dev, "cannot remap MMIO, aborting\n");
+		rc = -EIO;
+		goto err_out_free_res_3;
+	}
+	tp->mmio_addr = ioaddr;
+
+	if (!pci_is_pcie(pdev))
+		netif_info(tp, probe, dev, "not PCI Express\n");
+
+	/* Identify chip attached to board */
+	rtl8169_get_mac_version(tp, dev, cfg->default_ver);
+
+	rtl_init_rxcfg(tp);
+
+	rtl_irq_disable(tp);
+
+	rtl_hw_reset(tp);
+
+	rtl_ack_events(tp, 0xffff);
+
+	pci_set_master(pdev);
+
+	/*
+	 * Pretend we are using VLANs; This bypasses a nasty bug where
+	 * Interrupts stop flowing on high load on 8110SCd controllers.
+	 */
+	if (tp->mac_version == RTL_GIGA_MAC_VER_05)
+		tp->cp_cmd |= RxVlan;
+
+	rtl_init_mdio_ops(tp);
+	rtl_init_pll_power_ops(tp);
+	rtl_init_jumbo_ops(tp);
+
+	rtl8169_print_mac_version(tp);
+
+	chipset = tp->mac_version;
+	tp->txd_version = rtl_chip_infos[chipset].txd_version;
+
+	RTL_W8(Cfg9346, Cfg9346_Unlock);
+	RTL_W8(Config1, RTL_R8(Config1) | PMEnable);
+	RTL_W8(Config5, RTL_R8(Config5) & PMEStatus);
+	if ((RTL_R8(Config3) & (LinkUp | MagicPacket)) != 0)
+		tp->features |= RTL_FEATURE_WOL;
+	if ((RTL_R8(Config5) & (UWF | BWF | MWF)) != 0)
+		tp->features |= RTL_FEATURE_WOL;
+	tp->features |= rtl_try_msi(tp, cfg);
+	RTL_W8(Cfg9346, Cfg9346_Lock);
+
+	if (rtl_tbi_enabled(tp)) {
+		tp->set_speed = rtl8169_set_speed_tbi;
+		tp->get_settings = rtl8169_gset_tbi;
+		tp->phy_reset_enable = rtl8169_tbi_reset_enable;
+		tp->phy_reset_pending = rtl8169_tbi_reset_pending;
+		tp->link_ok = rtl8169_tbi_link_ok;
+		tp->do_ioctl = rtl_tbi_ioctl;
+	} else {
+		tp->set_speed = rtl8169_set_speed_xmii;
+		tp->get_settings = rtl8169_gset_xmii;
+		tp->phy_reset_enable = rtl8169_xmii_reset_enable;
+		tp->phy_reset_pending = rtl8169_xmii_reset_pending;
+		tp->link_ok = rtl8169_xmii_link_ok;
+		tp->do_ioctl = rtl_xmii_ioctl;
+	}
+
+	mutex_init(&tp->wk.mutex);
+
+	/* Get MAC address */
+	for (i = 0; i < ETH_ALEN; i++)
+		dev->dev_addr[i] = RTL_R8(MAC0 + i);
+	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
+
+	SET_ETHTOOL_OPS(dev, &rtl8169_ethtool_ops);
+	dev->watchdog_timeo = RTL8169_TX_TIMEOUT;
+	dev->irq = pdev->irq;
+	dev->base_addr = (unsigned long) ioaddr;
+
+	netif_napi_add(dev, &tp->napi, rtl8169_poll, R8169_NAPI_WEIGHT);
+
+	/* don't enable SG, IP_CSUM and TSO by default - it might not work
+	 * properly for all devices */
+	dev->features |= NETIF_F_RXCSUM |
+		NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+
+	dev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO |
+		NETIF_F_RXCSUM | NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+	dev->vlan_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO |
+		NETIF_F_HIGHDMA;
+
+	if (tp->mac_version == RTL_GIGA_MAC_VER_05)
+		/* 8110SCd requires hardware Rx VLAN - disallow toggling */
+		dev->hw_features &= ~NETIF_F_HW_VLAN_RX;
+
+	dev->hw_features |= NETIF_F_RXALL;
+	dev->hw_features |= NETIF_F_RXFCS;
+
+	tp->hw_start = cfg->hw_start;
+	tp->event_slow = cfg->event_slow;
+
+	tp->opts1_mask = (tp->mac_version != RTL_GIGA_MAC_VER_01) ?
+		~(RxBOVF | RxFOVF) : ~0;
+
+	init_timer(&tp->timer);
+	tp->timer.data = (unsigned long) dev;
+	tp->timer.function = rtl8169_phy_timer;
+
+	tp->rtl_fw = RTL_FIRMWARE_UNKNOWN;
+
+	rc = register_netdev(dev);
+	if (rc < 0)
+		goto err_out_msi_4;
+
+	pci_set_drvdata(pdev, dev);
+
+	netif_info(tp, probe, dev, "%s at 0x%lx, %pM, XID %08x IRQ %d\n",
+		   rtl_chip_infos[chipset].name, dev->base_addr, dev->dev_addr,
+		   (u32)(RTL_R32(TxConfig) & 0x9cf0f8ff), dev->irq);
+	if (rtl_chip_infos[chipset].jumbo_max != JUMBO_1K) {
+		netif_info(tp, probe, dev, "jumbo features [frames: %d bytes, "
+			   "tx checksumming: %s]\n",
+			   rtl_chip_infos[chipset].jumbo_max,
+			   rtl_chip_infos[chipset].jumbo_tx_csum ? "ok" : "ko");
+	}
+
+	if (tp->mac_version == RTL_GIGA_MAC_VER_27 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_28 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_31) {
+		rtl8168_driver_start(tp);
+	}
+
+	device_set_wakeup_enable(&pdev->dev, tp->features & RTL_FEATURE_WOL);
+
+	if (pci_dev_run_wake(pdev))
+		pm_runtime_put_noidle(&pdev->dev);
+
+	netif_carrier_off(dev);
+
+out:
+	return rc;
+
+err_out_msi_4:
+	rtl_disable_msi(pdev, tp);
+	iounmap(ioaddr);
+err_out_free_res_3:
+	pci_release_regions(pdev);
+err_out_mwi_2:
+	pci_clear_mwi(pdev);
+	pci_disable_device(pdev);
+err_out_free_dev_1:
+	free_netdev(dev);
+	goto out;
+}
+
 static struct pci_driver rtl8169_pci_driver = {
 	.name		= MODULENAME,
 	.id_table	= rtl8169_pci_tbl,
-	.probe		= rtl8169_init_one,
+	.probe		= rtl_init_one,
 	.remove		= __devexit_p(rtl_remove_one),
 	.shutdown	= rtl_shutdown,
 	.driver.pm	= RTL8169_PM_OPS,
-- 
1.7.7.6
