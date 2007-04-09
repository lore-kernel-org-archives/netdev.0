From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] skge: fix wake on lan
Date: Mon, 9 Apr 2007 15:32:45 -0700
Message-ID: <20070409153245.122a793c@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:34835 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753575AbXDIWnl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Apr 2007 18:43:41 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Need to rework wake on lan code to setup properly and get activated
on shutdown (and suspend), not when ethtool is run.

This does not need to go to stable queue because wake on lan
was not even included in 2.6.20 (or earlier versions).

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- skge.orig/drivers/net/skge.c
+++ skge/drivers/net/skge.c
@@ -163,27 +163,46 @@ static void skge_wol_init(struct skge_po
 {
 	struct skge_hw *hw = skge->hw;
 	int port = skge->port;
-	enum pause_control save_mode;
-	u32 ctrl;
+	u16 ctrl;
 
-	/* Bring hardware out of reset */
 	skge_write16(hw, B0_CTST, CS_RST_CLR);
 	skge_write16(hw, SK_REG(port, GMAC_LINK_CTRL), GMLC_RST_CLR);
 
-	skge_write8(hw, SK_REG(port, GPHY_CTRL), GPC_RST_CLR);
-	skge_write8(hw, SK_REG(port, GMAC_CTRL), GMC_RST_CLR);
+	/* Turn on Vaux */
+	skge_write8(hw, B0_POWER_CTRL,
+		    PC_VAUX_ENA | PC_VCC_ENA | PC_VAUX_ON | PC_VCC_OFF);
 
-	/* Force to 10/100 skge_reset will re-enable on resume	 */
-	save_mode = skge->flow_control;
-	skge->flow_control = FLOW_MODE_SYMMETRIC;
+	/* WA code for COMA mode -- clear PHY reset */
+	if (hw->chip_id == CHIP_ID_YUKON_LITE &&
+	    hw->chip_rev >= CHIP_REV_YU_LITE_A3) {
+		u32 reg = skge_read32(hw, B2_GP_IO);
+		reg |= GP_DIR_9;
+		reg &= ~GP_IO_9;
+		skge_write32(hw, B2_GP_IO, reg);
+	}
 
-	ctrl = skge->advertising;
-	skge->advertising &= ~(ADVERTISED_1000baseT_Half|ADVERTISED_1000baseT_Full);
+	skge_write32(hw, SK_REG(port, GPHY_CTRL),
+		     GPC_DIS_SLEEP |
+		     GPC_HWCFG_M_3 | GPC_HWCFG_M_2 | GPC_HWCFG_M_1 | GPC_HWCFG_M_0 |
+		     GPC_ANEG_1 | GPC_RST_SET);
+
+	skge_write32(hw, SK_REG(port, GPHY_CTRL),
+		     GPC_DIS_SLEEP |
+		     GPC_HWCFG_M_3 | GPC_HWCFG_M_2 | GPC_HWCFG_M_1 | GPC_HWCFG_M_0 |
+		     GPC_ANEG_1 | GPC_RST_CLR);
 
-	skge_phy_reset(skge);
+	skge_write32(hw, SK_REG(port, GMAC_CTRL), GMC_RST_CLR);
+
+	/* Force to 10/100 skge_reset will re-enable on resume	 */
+	gm_phy_write(hw, port, PHY_MARV_AUNE_ADV,
+		     PHY_AN_100FULL | PHY_AN_100HALF |
+		     PHY_AN_10FULL | PHY_AN_10HALF| PHY_AN_CSMA);
+	/* no 1000 HD/FD */
+	gm_phy_write(hw, port, PHY_MARV_1000T_CTRL, 0);
+	gm_phy_write(hw, port, PHY_MARV_CTRL,
+		     PHY_CT_RESET | PHY_CT_SPS_LSB | PHY_CT_ANE |
+		     PHY_CT_RE_CFG | PHY_CT_DUP_MD);
 
-	skge->flow_control = save_mode;
-	skge->advertising = ctrl;
 
 	/* Set GMAC to no flow control and auto update for speed/duplex */
 	gma_write16(hw, port, GM_GP_CTRL,
@@ -227,12 +246,10 @@ static int skge_set_wol(struct net_devic
 	struct skge_port *skge = netdev_priv(dev);
 	struct skge_hw *hw = skge->hw;
 
-	if (wol->wolopts & wol_supported(hw))
+	if (wol->wolopts & ~wol_supported(hw))
 		return -EOPNOTSUPP;
 
 	skge->wol = wol->wolopts;
-	if (!netif_running(dev))
-		skge_wol_init(skge);
 	return 0;
 }
 
@@ -2535,11 +2552,12 @@ static int skge_down(struct net_device *
 		printk(KERN_INFO PFX "%s: disabling interface\n", dev->name);
 
 	netif_stop_queue(dev);
-	netif_carrier_off(dev);
+
 	if (hw->chip_id == CHIP_ID_GENESIS && hw->phy_type == SK_PHY_XMAC)
 		del_timer_sync(&skge->link_timer);
 
 	netif_poll_disable(dev);
+	netif_carrier_off(dev);
 
 	spin_lock_irq(&hw->hw_lock);
 	hw->intr_mask &= ~portmask[port];
@@ -3766,21 +3784,6 @@ static void __devexit skge_remove(struct
 }
 
 #ifdef CONFIG_PM
-static int vaux_avail(struct pci_dev *pdev)
-{
-	int pm_cap;
-
-	pm_cap = pci_find_capability(pdev, PCI_CAP_ID_PM);
-	if (pm_cap) {
-		u16 ctl;
-		pci_read_config_word(pdev, pm_cap + PCI_PM_PMC, &ctl);
-		if (ctl & PCI_PM_CAP_AUX_POWER)
-			return 1;
-	}
-	return 0;
-}
-
-
 static int skge_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct skge_hw *hw  = pci_get_drvdata(pdev);
@@ -3802,10 +3805,6 @@ static int skge_suspend(struct pci_dev *
 		wol |= skge->wol;
 	}
 
-	if (wol && vaux_avail(pdev))
-		skge_write8(hw, B0_POWER_CTRL,
-			    PC_VAUX_ENA | PC_VCC_ENA | PC_VAUX_ON | PC_VCC_OFF);
-
 	skge_write32(hw, B0_IMSK, 0);
 	pci_enable_wake(pdev, pci_choose_state(pdev, state), wol);
 	pci_set_power_state(pdev, pci_choose_state(pdev, state));
@@ -3851,6 +3850,28 @@ out:
 }
 #endif
 
+static void skge_shutdown(struct pci_dev *pdev)
+{
+	struct skge_hw *hw  = pci_get_drvdata(pdev);
+	int i, wol = 0;
+
+	for (i = 0; i < hw->ports; i++) {
+		struct net_device *dev = hw->dev[i];
+		struct skge_port *skge = netdev_priv(dev);
+
+		if (skge->wol)
+			skge_wol_init(skge);
+		wol |= skge->wol;
+	}
+
+	pci_enable_wake(pdev, PCI_D3hot, wol);
+	pci_enable_wake(pdev, PCI_D3cold, wol);
+
+	pci_disable_device(pdev);
+	pci_set_power_state(pdev, PCI_D3hot);
+
+}
+
 static struct pci_driver skge_driver = {
 	.name =         DRV_NAME,
 	.id_table =     skge_id_table,
@@ -3860,6 +3881,7 @@ static struct pci_driver skge_driver = {
 	.suspend = 	skge_suspend,
 	.resume = 	skge_resume,
 #endif
+	.shutdown =	skge_shutdown,
 };
 
 static int __init skge_init_module(void)
