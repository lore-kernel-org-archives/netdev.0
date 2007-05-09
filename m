From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 07/17] sky2: use pci_config access functions
Date: Tue, 08 May 2007 20:49:56 -0700
Message-ID: <20070509035029.186529969@linux-foundation.org>
References: <20070509034949.624934448@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:46335 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1032763AbXEIEDs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 00:03:48 -0400
Cc: Greg KH <greg@kroah.com>
Content-Disposition: inline; filename=sky2-pci-func.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the PCI layer config access functions. The driver was using the
memory mapped window in device, to workaround issues accessing the
advanced error reporting registers.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |   44 ++++++++++++++++++++++----------------------
 drivers/net/sky2.h |   21 ---------------------
 2 files changed, 22 insertions(+), 43 deletions(-)

--- sky2-2.6.21.orig/drivers/net/sky2.c	2007-05-08 15:29:07.000000000 -0700
+++ sky2-2.6.21/drivers/net/sky2.c	2007-05-08 15:29:09.000000000 -0700
@@ -220,11 +220,11 @@ static void sky2_power_on(struct sky2_hw
 	if (hw->chip_id == CHIP_ID_YUKON_EC_U || hw->chip_id == CHIP_ID_YUKON_EX) {
 		u32 reg1;
 
-		sky2_pci_write32(hw, PCI_DEV_REG3, 0);
-		reg1 = sky2_pci_read32(hw, PCI_DEV_REG4);
+		pci_write_config_dword(hw->pdev, PCI_DEV_REG3, 0);
+		pci_read_config_dword(hw->pdev, PCI_DEV_REG4, &reg1);
 		reg1 &= P_ASPM_CONTROL_MSK;
-		sky2_pci_write32(hw, PCI_DEV_REG4, reg1);
-		sky2_pci_write32(hw, PCI_DEV_REG5, 0);
+		pci_write_config_dword(hw->pdev, PCI_DEV_REG4, reg1);
+		pci_write_config_dword(hw->pdev, PCI_DEV_REG5, 0);
 	}
 }
 
@@ -556,16 +556,16 @@ static void sky2_phy_power(struct sky2_h
 	/* looks like this XL is back asswards .. */
 	if (hw->chip_id == CHIP_ID_YUKON_XL && hw->chip_rev > 1)
 		onoff = !onoff;
-
-	reg1 = sky2_pci_read32(hw, PCI_DEV_REG1);
+	pci_read_config_dword(hw->pdev, PCI_DEV_REG1, &reg1);
 	if (onoff)
 		/* Turn off phy power saving */
 		reg1 &= ~phy_power[port];
 	else
 		reg1 |= phy_power[port];
 
-	sky2_pci_write32(hw, PCI_DEV_REG1, reg1);
-	sky2_pci_read32(hw, PCI_DEV_REG1);
+	pci_write_config_dword(hw->pdev, PCI_DEV_REG1, reg1);
+	pci_read_config_dword(hw->pdev, PCI_DEV_REG1, &reg1);
+
 	udelay(100);
 }
 
@@ -633,9 +633,9 @@ static void sky2_wol_init(struct sky2_po
 	sky2_write16(hw, WOL_REGS(port, WOL_CTRL_STAT), ctrl);
 
 	/* Turn on legacy PCI-Express PME mode */
-	reg1 = sky2_pci_read32(hw, PCI_DEV_REG1);
+	pci_read_config_dword(hw->pdev, PCI_DEV_REG1, &reg1);
 	reg1 |= PCI_Y2_PME_LEGACY;
-	sky2_pci_write32(hw, PCI_DEV_REG1, reg1);
+	pci_write_config_dword(hw->pdev, PCI_DEV_REG1, reg1);
 
 	/* block receiver */
 	sky2_write8(hw, SK_REG(port, RX_GMF_CTRL_T), GMF_RST_SET);
@@ -1216,9 +1216,9 @@ static int sky2_up(struct net_device *de
  		struct sky2_port *osky2 = netdev_priv(otherdev);
  		u16 cmd;
 
- 		cmd = sky2_pci_read16(hw, cap + PCI_X_CMD);
+		pci_read_config_word(hw->pdev, cap + PCI_X_CMD, &cmd);
  		cmd &= ~PCI_X_CMD_MAX_SPLIT;
- 		sky2_pci_write16(hw, cap + PCI_X_CMD, cmd);
+ 		pci_write_config_word(hw->pdev, cap + PCI_X_CMD, cmd);
 
  		sky2->rx_csum = 0;
  		osky2->rx_csum = 0;
@@ -2283,13 +2283,13 @@ static void sky2_hw_intr(struct sky2_hw 
 	if (status & (Y2_IS_MST_ERR | Y2_IS_IRQ_STAT)) {
 		u16 pci_err;
 
-		pci_err = sky2_pci_read16(hw, PCI_STATUS);
+		pci_read_config_word(pdev, PCI_STATUS, &pci_err);
 		if (net_ratelimit())
 			dev_err(&pdev->dev, "PCI hardware error (0x%x)\n",
 			        pci_err);
 
-		sky2_pci_write16(hw, PCI_STATUS,
-				 pci_err | PCI_STATUS_ERROR_BITS);
+		pci_write_config_word(pdev, PCI_STATUS,
+				      pci_err | PCI_STATUS_ERROR_BITS);
 	}
 
 	/* PCI-Express error occurred */
@@ -2513,7 +2513,7 @@ static int __devinit sky2_init(struct sk
 
 	/* Make sure and enable all clocks */
 	if (hw->chip_id == CHIP_ID_YUKON_EX || hw->chip_id == CHIP_ID_YUKON_EC_U)
-		sky2_pci_write32(hw, PCI_DEV_REG3, 0);
+		pci_write_config_dword(hw->pdev, PCI_DEV_REG3, 0);
 
 	hw->chip_rev = (sky2_read8(hw, B2_MAC_CFG) & CFG_CHIP_R_MSK) >> 4;
 
@@ -2557,9 +2557,9 @@ static void sky2_reset(struct sky2_hw *h
 	sky2_write8(hw, B0_CTST, CS_RST_CLR);
 
 	/* clear PCI errors, if any */
-	status = sky2_pci_read16(hw, PCI_STATUS);
-	sky2_pci_write16(hw, PCI_STATUS, status | PCI_STATUS_ERROR_BITS);
-
+	pci_read_config_word(hw->pdev, PCI_STATUS, &status);
+	pci_write_config_word(hw->pdev, PCI_STATUS,
+			      status | PCI_STATUS_ERROR_BITS);
 
 	sky2_write8(hw, B0_CTST, CS_MRST_CLR);
 
@@ -3631,9 +3631,9 @@ static int __devinit sky2_probe(struct p
 	 */
 	{
 		u32 reg;
-		reg = sky2_pci_read32(hw, PCI_DEV_REG2);
+		pci_read_config_dword(pdev,PCI_DEV_REG2, &reg);
 		reg &= ~PCI_REV_DESC;
-		sky2_pci_write32(hw, PCI_DEV_REG2, reg);
+		pci_write_config_dword(pdev, PCI_DEV_REG2, reg);
 	}
 #endif
 
@@ -3822,7 +3822,7 @@ static int sky2_resume(struct pci_dev *p
 
 	/* Re-enable all clocks */
 	if (hw->chip_id == CHIP_ID_YUKON_EX || hw->chip_id == CHIP_ID_YUKON_EC_U)
-		sky2_pci_write32(hw, PCI_DEV_REG3, 0);
+		pci_write_config_dword(hw->pdev, PCI_DEV_REG3, 0);
 
 	sky2_reset(hw);
 
--- sky2-2.6.21.orig/drivers/net/sky2.h	2007-05-08 15:29:07.000000000 -0700
+++ sky2-2.6.21/drivers/net/sky2.h	2007-05-08 15:29:09.000000000 -0700
@@ -1973,25 +1973,4 @@ static inline void gma_set_addr(struct s
 	gma_write16(hw, port, reg+4,(u16) addr[2] | ((u16) addr[3] << 8));
 	gma_write16(hw, port, reg+8,(u16) addr[4] | ((u16) addr[5] << 8));
 }
-
-/* PCI config space access */
-static inline u32 sky2_pci_read32(const struct sky2_hw *hw, unsigned reg)
-{
-	return sky2_read32(hw, Y2_CFG_SPC + reg);
-}
-
-static inline u16 sky2_pci_read16(const struct sky2_hw *hw, unsigned reg)
-{
-	return sky2_read16(hw, Y2_CFG_SPC + reg);
-}
-
-static inline void sky2_pci_write32(struct sky2_hw *hw, unsigned reg, u32 val)
-{
-	sky2_write32(hw, Y2_CFG_SPC + reg, val);
-}
-
-static inline void sky2_pci_write16(struct sky2_hw *hw, unsigned reg, u16 val)
-{
-	sky2_write16(hw, Y2_CFG_SPC + reg, val);
-}
 #endif

--

