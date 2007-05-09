From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 02/17] sky2: dont restrict config space access
Date: Tue, 08 May 2007 20:49:51 -0700
Message-ID: <20070509035028.100258486@linux-foundation.org>
References: <20070509034949.624934448@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:38171 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1032936AbXEIEDf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 00:03:35 -0400
Cc: Greg KH <greg@kroah.com>
Content-Disposition: inline; filename=sky2-no-cfg-disable
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Take out the code that protects driver from accessing the
PCI config space. We are old enough to run with scissors now.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |   11 -----------
 1 file changed, 11 deletions(-)

--- sky2-2.6.21.orig/drivers/net/sky2.c	2007-05-08 10:06:39.000000000 -0700
+++ sky2-2.6.21/drivers/net/sky2.c	2007-05-08 10:28:50.000000000 -0700
@@ -556,7 +556,6 @@ static void sky2_phy_power(struct sky2_h
 	if (hw->chip_id == CHIP_ID_YUKON_XL && hw->chip_rev > 1)
 		onoff = !onoff;
 
-	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
 	reg1 = sky2_pci_read32(hw, PCI_DEV_REG1);
 	if (onoff)
 		/* Turn off phy power saving */
@@ -566,7 +565,6 @@ static void sky2_phy_power(struct sky2_h
 
 	sky2_pci_write32(hw, PCI_DEV_REG1, reg1);
 	sky2_pci_read32(hw, PCI_DEV_REG1);
-	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
 	udelay(100);
 }
 
@@ -634,11 +632,9 @@ static void sky2_wol_init(struct sky2_po
 	sky2_write16(hw, WOL_REGS(port, WOL_CTRL_STAT), ctrl);
 
 	/* Turn on legacy PCI-Express PME mode */
-	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
 	reg1 = sky2_pci_read32(hw, PCI_DEV_REG1);
 	reg1 |= PCI_Y2_PME_LEGACY;
 	sky2_pci_write32(hw, PCI_DEV_REG1, reg1);
-	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
 
 	/* block receiver */
 	sky2_write8(hw, SK_REG(port, RX_GMF_CTRL_T), GMF_RST_SET);
@@ -2292,10 +2288,8 @@ static void sky2_hw_intr(struct sky2_hw 
 			dev_err(&hw->pdev->dev, "PCI hardware error (0x%x)\n",
 			        pci_err);
 
-		sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
 		sky2_pci_write16(hw, PCI_STATUS,
 				 pci_err | PCI_STATUS_ERROR_BITS);
-		sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
 	}
 
 	if (status & Y2_IS_PCI_EXP) {
@@ -2309,10 +2303,8 @@ static void sky2_hw_intr(struct sky2_hw 
 				pex_err);
 
 		/* clear the interrupt */
-		sky2_write32(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
 		sky2_pci_write32(hw, PEX_UNC_ERR_STAT,
 				       0xffffffffUL);
-		sky2_write32(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
 
 		if (pex_err & PEX_FATAL_ERRORS) {
 			u32 hwmsk = sky2_read32(hw, B0_HWE_IMSK);
@@ -2564,7 +2556,6 @@ static void sky2_reset(struct sky2_hw *h
 	/* clear PCI errors, if any */
 	status = sky2_pci_read16(hw, PCI_STATUS);
 
-	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
 	sky2_pci_write16(hw, PCI_STATUS, status | PCI_STATUS_ERROR_BITS);
 
 
@@ -2582,8 +2573,6 @@ static void sky2_reset(struct sky2_hw *h
 		sky2_write8(hw, SK_REG(i, GMAC_LINK_CTRL), GMLC_RST_CLR);
 	}
 
-	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
-
 	/* Clear I2C IRQ noise */
 	sky2_write32(hw, B2_I2C_IRQ, 1);
 

--

