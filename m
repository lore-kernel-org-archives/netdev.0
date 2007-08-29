From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 04/12] sky2: dont restrict config space access
Date: Wed, 29 Aug 2007 12:58:13 -0700
Message-ID: <20070829195842.866285555@linux-foundation.org>
References: <20070829193922.078561651@linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:47731 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754937AbXH2UBf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 16:01:35 -0400
Content-Disposition: inline; filename=sky2-no-cfg-disable
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Take out the code that protects driver from accessing the
PCI config space. 
We are old enough to run with scissors now.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |    9 ---------
 1 file changed, 9 deletions(-)

--- a/drivers/net/sky2.c	2007-08-29 11:40:09.000000000 -0700
+++ b/drivers/net/sky2.c	2007-08-29 11:40:53.000000000 -0700
@@ -603,7 +603,6 @@ static void sky2_phy_power(struct sky2_h
 	if (hw->chip_id == CHIP_ID_YUKON_XL && hw->chip_rev > 1)
 		onoff = !onoff;
 
-	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
 	reg1 = sky2_pci_read32(hw, PCI_DEV_REG1);
 	if (onoff)
 		/* Turn off phy power saving */
@@ -613,7 +612,6 @@ static void sky2_phy_power(struct sky2_h
 
 	sky2_pci_write32(hw, PCI_DEV_REG1, reg1);
 	sky2_pci_read32(hw, PCI_DEV_REG1);
-	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
 	udelay(100);
 }
 
@@ -681,11 +679,9 @@ static void sky2_wol_init(struct sky2_po
 	sky2_write16(hw, WOL_REGS(port, WOL_CTRL_STAT), ctrl);
 
 	/* Turn on legacy PCI-Express PME mode */
-	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
 	reg1 = sky2_pci_read32(hw, PCI_DEV_REG1);
 	reg1 |= PCI_Y2_PME_LEGACY;
 	sky2_pci_write32(hw, PCI_DEV_REG1, reg1);
-	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
 
 	/* block receiver */
 	sky2_write8(hw, SK_REG(port, RX_GMF_CTRL_T), GMF_RST_SET);
@@ -2386,10 +2382,8 @@ static void sky2_hw_intr(struct sky2_hw 
 			dev_err(&hw->pdev->dev, "PCI hardware error (0x%x)\n",
 			        pci_err);
 
-		sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
 		sky2_pci_write16(hw, PCI_STATUS,
 				 pci_err | PCI_STATUS_ERROR_BITS);
-		sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
 	}
 
 	if (status & Y2_IS_PCI_EXP) {
@@ -2403,11 +2397,8 @@ static void sky2_hw_intr(struct sky2_hw 
 				pex_err);
 
 		/* clear the interrupt */
-		sky2_write32(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
 		sky2_pci_write32(hw, PEX_UNC_ERR_STAT,
 				       0xffffffffUL);
-		sky2_write32(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
-
 		if (pex_err & PEX_FATAL_ERRORS) {
 			u32 hwmsk = sky2_read32(hw, B0_HWE_IMSK);
 			hwmsk &= ~Y2_IS_PCI_EXP;
@@ -2670,7 +2661,6 @@ static void sky2_reset(struct sky2_hw *h
 	/* clear PCI errors, if any */
 	status = sky2_pci_read16(hw, PCI_STATUS);
 
-	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
 	sky2_pci_write16(hw, PCI_STATUS, status | PCI_STATUS_ERROR_BITS);
 
 
@@ -2693,8 +2683,6 @@ static void sky2_reset(struct sky2_hw *h
 				     | GMC_BYP_RETR_ON);
 	}
 
-	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
-
 	/* Clear I2C IRQ noise */
 	sky2_write32(hw, B2_I2C_IRQ, 1);
 

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

