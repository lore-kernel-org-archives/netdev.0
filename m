From: shemminger@osdl.org
Subject: [PATCH 7/9] sky2: power down PHY when not up
Date: Mon, 28 Aug 2006 10:00:51 -0700
Message-ID: <20060828170219.598956798@localhost.localdomain>
References: <20060828170044.136391412@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:43394 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751240AbWH1SQj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2006 14:16:39 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-phy-power.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To save power, don't enable power to the PHY until device is brought up.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- sky2.orig/drivers/net/sky2.c	2006-08-28 10:00:13.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-08-28 10:00:17.000000000 -0700
@@ -195,7 +195,6 @@
 static void sky2_set_power_state(struct sky2_hw *hw, pci_power_t state)
 {
 	u16 power_control;
-	u32 reg1;
 	int vaux;
 
 	pr_debug("sky2_set_power_state %d\n", state);
@@ -228,20 +227,9 @@
 		else
 			sky2_write8(hw, B2_Y2_CLK_GATE, 0);
 
-		/* Turn off phy power saving */
-		reg1 = sky2_pci_read32(hw, PCI_DEV_REG1);
-		reg1 &= ~(PCI_Y2_PHY1_POWD | PCI_Y2_PHY2_POWD);
-
-		/* looks like this XL is back asswards .. */
-		if (hw->chip_id == CHIP_ID_YUKON_XL && hw->chip_rev > 1) {
-			reg1 |= PCI_Y2_PHY1_COMA;
-			if (hw->ports > 1)
-				reg1 |= PCI_Y2_PHY2_COMA;
-		}
-		sky2_pci_write32(hw, PCI_DEV_REG1, reg1);
-		udelay(100);
-
 		if (hw->chip_id == CHIP_ID_YUKON_EC_U) {
+			u32 reg1;
+
 			sky2_pci_write32(hw, PCI_DEV_REG3, 0);
 			reg1 = sky2_pci_read32(hw, PCI_DEV_REG4);
 			reg1 &= P_ASPM_CONTROL_MSK;
@@ -253,15 +241,6 @@
 
 	case PCI_D3hot:
 	case PCI_D3cold:
-		/* Turn on phy power saving */
-		reg1 = sky2_pci_read32(hw, PCI_DEV_REG1);
-		if (hw->chip_id == CHIP_ID_YUKON_XL && hw->chip_rev > 1)
-			reg1 &= ~(PCI_Y2_PHY1_POWD | PCI_Y2_PHY2_POWD);
-		else
-			reg1 |= (PCI_Y2_PHY1_POWD | PCI_Y2_PHY2_POWD);
-		sky2_pci_write32(hw, PCI_DEV_REG1, reg1);
-		udelay(100);
-
 		if (hw->chip_id == CHIP_ID_YUKON_XL && hw->chip_rev > 1)
 			sky2_write8(hw, B2_Y2_CLK_GATE, 0);
 		else
@@ -285,7 +264,7 @@
 	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
 }
 
-static void sky2_phy_reset(struct sky2_hw *hw, unsigned port)
+static void sky2_gmac_reset(struct sky2_hw *hw, unsigned port)
 {
 	u16 reg;
 
@@ -533,6 +512,28 @@
 		gm_phy_write(hw, port, PHY_MARV_INT_MASK, PHY_M_DEF_MSK);
 }
 
+static void sky2_phy_power(struct sky2_hw *hw, unsigned port, int onoff)
+{
+	u32 reg1;
+	static const u32 phy_power[]
+		= { PCI_Y2_PHY1_POWD, PCI_Y2_PHY2_POWD };
+
+	/* looks like this XL is back asswards .. */
+	if (hw->chip_id == CHIP_ID_YUKON_XL && hw->chip_rev > 1)
+		onoff = !onoff;
+
+	reg1 = sky2_pci_read32(hw, PCI_DEV_REG1);
+
+	if (onoff)
+		/* Turn off phy power saving */
+		reg1 &= ~phy_power[port];
+	else
+		reg1 |= phy_power[port];
+
+	sky2_pci_write32(hw, PCI_DEV_REG1, reg1);
+	udelay(100);
+}
+
 /* Force a renegotiation */
 static void sky2_phy_reinit(struct sky2_port *sky2)
 {
@@ -1088,6 +1089,8 @@
 	if (!sky2->rx_ring)
 		goto err_out;
 
+	sky2_phy_power(hw, port, 1);
+
 	sky2_mac_init(hw, port);
 
 	/* Determine available ram buffer space (in 4K blocks).
@@ -1421,7 +1424,7 @@
 	/* Stop more packets from being queued */
 	netif_stop_queue(dev);
 
-	sky2_phy_reset(hw, port);
+	sky2_gmac_reset(hw, port);
 
 	/* Stop transmitter */
 	sky2_write32(hw, Q_ADDR(txqaddr[port], Q_CSR), BMU_STOP);
@@ -1469,6 +1472,8 @@
 	imask &= ~portirq_msk[port];
 	sky2_write32(hw, B0_IMSK, imask);
 
+	sky2_phy_power(hw, port, 0);
+
 	/* turn off LED's */
 	sky2_write16(hw, B0_Y2LED, LED_STAT_OFF);
 
@@ -2403,7 +2408,7 @@
 	sky2_write32(hw, B0_HWE_IMSK, Y2_HWE_ALL_MASK);
 
 	for (i = 0; i < hw->ports; i++)
-		sky2_phy_reset(hw, i);
+		sky2_gmac_reset(hw, i);
 
 	memset(hw->st_le, 0, STATUS_LE_BYTES);
 	hw->st_idx = 0;

--
Stephen Hemminger <shemminger@osdl.org>

