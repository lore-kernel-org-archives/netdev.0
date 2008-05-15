From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/5] sky2: split phy power into two functions
Date: Wed, 14 May 2008 17:04:15 -0700
Message-ID: <20080515000433.062985443@vyatta.com>
References: <20080515000412.984337700@vyatta.com>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:49974 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760314AbYEOAI3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2008 20:08:29 -0400
Content-Disposition: inline; filename=sky2-power-split.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Later changes add more code to PHY power changes so refactor now.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
This can wait for next release (#upstream) and go in -mm

--- a/drivers/net/sky2.c	2008-05-14 16:29:44.000000000 -0700
+++ b/drivers/net/sky2.c	2008-05-14 16:29:46.000000000 -0700
@@ -619,28 +619,35 @@ static void sky2_phy_init(struct sky2_hw
 		gm_phy_write(hw, port, PHY_MARV_INT_MASK, PHY_M_DEF_MSK);
 }
 
-static void sky2_phy_power(struct sky2_hw *hw, unsigned port, int onoff)
+static const u32 phy_power[] = { PCI_Y2_PHY1_POWD, PCI_Y2_PHY2_POWD };
+static const u32 coma_mode[] = { PCI_Y2_PHY1_COMA, PCI_Y2_PHY2_COMA };
+
+static void sky2_phy_power_up(struct sky2_hw *hw, unsigned port)
 {
 	u32 reg1;
-	static const u32 phy_power[] = { PCI_Y2_PHY1_POWD, PCI_Y2_PHY2_POWD };
-	static const u32 coma_mode[] = { PCI_Y2_PHY1_COMA, PCI_Y2_PHY2_COMA };
 
 	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
 	reg1 = sky2_pci_read32(hw, PCI_DEV_REG1);
-	/* Turn on/off phy power saving */
-	if (onoff)
-		reg1 &= ~phy_power[port];
-	else
-		reg1 |= phy_power[port];
+	reg1 &= ~phy_power[port];
 
-	if (onoff && hw->chip_id == CHIP_ID_YUKON_XL && hw->chip_rev > 1)
+	if (hw->chip_id == CHIP_ID_YUKON_XL && hw->chip_rev > 1)
 		reg1 |= coma_mode[port];
 
 	sky2_pci_write32(hw, PCI_DEV_REG1, reg1);
 	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
 	sky2_pci_read32(hw, PCI_DEV_REG1);
+}
+
+static void sky2_phy_power_down(struct sky2_hw *hw, unsigned port)
+{
+	u32 reg1;
+
+	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
+	reg1 = sky2_pci_read32(hw, PCI_DEV_REG1);
+	reg1 |= phy_power[port];
 
-	udelay(100);
+	sky2_pci_write32(hw, PCI_DEV_REG1, reg1);
+	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
 }
 
 /* Force a renegotiation */
@@ -675,8 +682,11 @@ static void sky2_wol_init(struct sky2_po
 
 	sky2->advertising &= ~(ADVERTISED_1000baseT_Half|ADVERTISED_1000baseT_Full);
 	sky2->flow_mode = FC_NONE;
-	sky2_phy_power(hw, port, 1);
-	sky2_phy_reinit(sky2);
+
+	spin_lock_bh(&sky2->phy_lock);
+	sky2_phy_power_up(hw, port);
+	sky2_phy_init(hw, port);
+	spin_unlock_bh(&sky2->phy_lock);
 
 	sky2->flow_mode = save_mode;
 	sky2->advertising = ctrl;
@@ -781,6 +791,7 @@ static void sky2_mac_init(struct sky2_hw
 	sky2_write8(hw, SK_REG(port, GMAC_IRQ_MSK), GMAC_DEF_MSK);
 
 	spin_lock_bh(&sky2->phy_lock);
+	sky2_phy_power_up(hw, port);
 	sky2_phy_init(hw, port);
 	spin_unlock_bh(&sky2->phy_lock);
 
@@ -1385,8 +1396,6 @@ static int sky2_up(struct net_device *de
 	if (!sky2->rx_ring)
 		goto err_out;
 
-	sky2_phy_power(hw, port, 1);
-
 	sky2_mac_init(hw, port);
 
 	/* Register is number of 4K blocks on internal RAM buffer. */
@@ -1767,7 +1776,7 @@ static int sky2_down(struct net_device *
 	sky2_write8(hw, SK_REG(port, RX_GMF_CTRL_T), GMF_RST_SET);
 	sky2_write8(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_RST_SET);
 
-	sky2_phy_power(hw, port, 0);
+	sky2_phy_power_down(hw, port);
 
 	netif_carrier_off(dev);
 

-- 

