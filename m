From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 5/6] sky2: 88E8059 support
Date: Thu, 29 Oct 2009 09:37:09 -0700
Message-ID: <20091029163849.491142214@vyatta.com>
References: <20091029163704.793246334@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57321 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753774AbZJ2QjX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2009 12:39:23 -0400
Content-Disposition: inline; filename=sky2-yukon-ul_2.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tentative support for newer Marvell hardware including
the Yukon-2 Optima chip. Do not have hatdware to test this yet,
code is based on vendor driver.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sky2.c	2009-10-28 11:02:38.031251525 -0700
+++ b/drivers/net/sky2.c	2009-10-28 11:02:44.719000693 -0700
@@ -140,6 +140,7 @@ static DEFINE_PCI_DEVICE_TABLE(sky2_id_t
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x436D) }, /* 88E8055 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4370) }, /* 88E8075 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4380) }, /* 88E8057 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4381) }, /* 88E8059 */
 	{ 0 }
 };
 
@@ -603,6 +604,16 @@ static void sky2_phy_init(struct sky2_hw
 		/* apply workaround for integrated resistors calibration */
 		gm_phy_write(hw, port, PHY_MARV_PAGE_ADDR, 17);
 		gm_phy_write(hw, port, PHY_MARV_PAGE_DATA, 0x3f60);
+	} else if (hw->chip_id == CHIP_ID_YUKON_OPT && hw->chip_rev == 0) {
+		/* apply fixes in PHY AFE */
+		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 0x00ff);
+
+		/* apply RDAC termination workaround */
+		gm_phy_write(hw, port, 24, 0x2800);
+		gm_phy_write(hw, port, 23, 0x2001);
+
+		/* set page register back to 0 */
+		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 0);
 	} else if (hw->chip_id != CHIP_ID_YUKON_EX &&
 		   hw->chip_id < CHIP_ID_YUKON_SUPR) {
 		/* no effect on Yukon-XL */
@@ -2133,6 +2144,25 @@ out:
 	spin_unlock(&sky2->phy_lock);
 }
 
+/* Special quick link interrupt (Yukon-2 Optima only) */
+static void sky2_qlink_intr(struct sky2_hw *hw)
+{
+	struct sky2_port *sky2 = netdev_priv(hw->dev[0]);
+	u32 imask;
+	u16 phy;
+
+	/* disable irq */
+	imask = sky2_read32(hw, B0_IMSK);
+	imask &= ~Y2_IS_PHY_QLNK;
+	sky2_write32(hw, B0_IMSK, imask);
+
+	/* reset PHY Link Detect */
+	phy = sky2_pci_read16(hw, PSM_CONFIG_REG4);
+	sky2_pci_write16(hw, PSM_CONFIG_REG4, phy | 1);
+
+	sky2_link_up(sky2);
+}
+
 /* Transmit timeout is only called if we are running, carrier is up
  * and tx queue is full (stopped).
  */
@@ -2803,6 +2833,9 @@ static int sky2_poll(struct napi_struct 
 	if (status & Y2_IS_IRQ_PHY2)
 		sky2_phy_intr(hw, 1);
 
+	if (status & Y2_IS_PHY_QLNK)
+		sky2_qlink_intr(hw);
+
 	while ((idx = sky2_read16(hw, STAT_PUT_IDX)) != hw->st_idx) {
 		work_done += sky2_status_intr(hw, work_limit - work_done, idx);
 
@@ -2852,6 +2885,7 @@ static u32 sky2_mhz(const struct sky2_hw
 	case CHIP_ID_YUKON_EX:
 	case CHIP_ID_YUKON_SUPR:
 	case CHIP_ID_YUKON_UL_2:
+	case CHIP_ID_YUKON_OPT:
 		return 125;
 
 	case CHIP_ID_YUKON_FE:
@@ -2941,6 +2975,7 @@ static int __devinit sky2_init(struct sk
 		break;
 
 	case CHIP_ID_YUKON_UL_2:
+	case CHIP_ID_YUKON_OPT:
 		hw->flags = SKY2_HW_GIGABIT
 			| SKY2_HW_ADV_POWER_CTL;
 		break;
@@ -3031,6 +3066,46 @@ static void sky2_reset(struct sky2_hw *h
 		sky2_pci_write32(hw, PCI_DEV_REG3, P_CLK_MACSEC_DIS);
 	}
 
+	if (hw->chip_id == CHIP_ID_YUKON_OPT) {
+		u16 reg;
+		u32 msk;
+
+		if (hw->chip_rev == 0) {
+			/* disable PCI-E PHY power down (set PHY reg 0x80, bit 7 */
+			sky2_write32(hw, Y2_PEX_PHY_DATA, (0x80UL << 16) | (1 << 7));
+
+			/* set PHY Link Detect Timer to 1.1 second (11x 100ms) */
+			reg = 10;
+		} else {
+			/* set PHY Link Detect Timer to 0.4 second (4x 100ms) */
+			reg = 3;
+		}
+
+		reg <<= PSM_CONFIG_REG4_TIMER_PHY_LINK_DETECT_BASE;
+
+		/* reset PHY Link Detect */
+		sky2_pci_write16(hw, PSM_CONFIG_REG4,
+				 reg | PSM_CONFIG_REG4_RST_PHY_LINK_DETECT);
+		sky2_pci_write16(hw, PSM_CONFIG_REG4, reg);
+
+
+		/* enable PHY Quick Link */
+		msk = sky2_read32(hw, B0_IMSK);
+		msk |= Y2_IS_PHY_QLNK;
+		sky2_write32(hw, B0_IMSK, msk);
+
+		/* check if PSMv2 was running before */
+		reg = sky2_pci_read16(hw, PSM_CONFIG_REG3);
+		if (reg & PCI_EXP_LNKCTL_ASPMC) {
+			int cap = pci_find_capability(pdev, PCI_CAP_ID_EXP);
+			/* restore the PCIe Link Control register */
+			sky2_pci_write16(hw, cap + PCI_EXP_LNKCTL, reg);
+		}
+
+		/* re-enable PEX PM in PEX PHY debug reg. 8 (clear bit 12) */
+		sky2_write32(hw, Y2_PEX_PHY_DATA, PEX_DB_ACCESS | (0x08UL << 16));
+	}
+
 	/* Clear I2C IRQ noise */
 	sky2_write32(hw, B2_I2C_IRQ, 1);
 
@@ -4451,9 +4526,11 @@ static const char *sky2_name(u8 chipid, 
 		"FE+",		/* 0xb8 */
 		"Supreme",	/* 0xb9 */
 		"UL 2",		/* 0xba */
+		"Unknown",	/* 0xbb */
+		"Optima",	/* 0xbc */
 	};
 
-	if (chipid >= CHIP_ID_YUKON_XL && chipid < CHIP_ID_YUKON_UL_2)
+	if (chipid >= CHIP_ID_YUKON_XL && chipid < CHIP_ID_YUKON_OPT)
 		strncpy(buf, name[chipid - CHIP_ID_YUKON_XL], sz);
 	else
 		snprintf(buf, sz, "(chip %#x)", chipid);

-- 

