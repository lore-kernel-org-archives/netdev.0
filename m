From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/2] sky2: fix Wake On Lan interaction with BIOS
Date: Wed, 23 Jan 2008 19:16:04 -0800
Message-ID: <20080123191604.55c16e86@deepthought>
References: <20080123191151.1423a045@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:54235 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752238AbYAXDUK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 22:20:10 -0500
In-Reply-To: <20080123191151.1423a045@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch disables config mode access after clearing PCI settings.
Some BIOS's seem to not do WOL if config bit still set.

Fixes: http://bugzilla.kernel.org/show_bug.cgi?id=9721

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
Please get this into 2.6.24.

--- a/drivers/net/sky2.c	2008-01-23 16:31:13.000000000 -0800
+++ b/drivers/net/sky2.c	2008-01-23 16:31:16.000000000 -0800
@@ -621,6 +621,7 @@ static void sky2_phy_power(struct sky2_h
 	static const u32 phy_power[] = { PCI_Y2_PHY1_POWD, PCI_Y2_PHY2_POWD };
 	static const u32 coma_mode[] = { PCI_Y2_PHY1_COMA, PCI_Y2_PHY2_COMA };
 
+	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
 	reg1 = sky2_pci_read32(hw, PCI_DEV_REG1);
 	/* Turn on/off phy power saving */
 	if (onoff)
@@ -632,7 +633,8 @@ static void sky2_phy_power(struct sky2_h
 		reg1 |= coma_mode[port];
 
 	sky2_pci_write32(hw, PCI_DEV_REG1, reg1);
-	reg1 = sky2_pci_read32(hw, PCI_DEV_REG1);
+	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
+	sky2_pci_read32(hw, PCI_DEV_REG1);
 
 	udelay(100);
 }
@@ -2427,6 +2429,7 @@ static void sky2_hw_intr(struct sky2_hw 
 	if (status & (Y2_IS_MST_ERR | Y2_IS_IRQ_STAT)) {
 		u16 pci_err;
 
+		sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
 		pci_err = sky2_pci_read16(hw, PCI_STATUS);
 		if (net_ratelimit())
 			dev_err(&pdev->dev, "PCI hardware error (0x%x)\n",
@@ -2434,12 +2437,14 @@ static void sky2_hw_intr(struct sky2_hw 
 
 		sky2_pci_write16(hw, PCI_STATUS,
 				      pci_err | PCI_STATUS_ERROR_BITS);
+		sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
 	}
 
 	if (status & Y2_IS_PCI_EXP) {
 		/* PCI-Express uncorrectable Error occurred */
 		u32 err;
 
+		sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
 		err = sky2_read32(hw, Y2_CFG_AER + PCI_ERR_UNCOR_STATUS);
 		sky2_write32(hw, Y2_CFG_AER + PCI_ERR_UNCOR_STATUS,
 			     0xfffffffful);
@@ -2447,6 +2452,7 @@ static void sky2_hw_intr(struct sky2_hw 
 			dev_err(&pdev->dev, "PCI Express error (0x%x)\n", err);
 
 		sky2_read32(hw, Y2_CFG_AER + PCI_ERR_UNCOR_STATUS);
+		sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
 	}
 
 	if (status & Y2_HWE_L1_MASK)
@@ -2812,6 +2818,7 @@ static void sky2_reset(struct sky2_hw *h
 	}
 
 	sky2_power_on(hw);
+	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
 
 	for (i = 0; i < hw->ports; i++) {
 		sky2_write8(hw, SK_REG(i, GMAC_LINK_CTRL), GMLC_RST_SET);
