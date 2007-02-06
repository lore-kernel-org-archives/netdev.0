From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 5/7] sky2: Yukon Extreme support
Date: Tue, 06 Feb 2007 10:45:43 -0800
Message-ID: <20070206184855.246345000@linux-foundation.org>
References: <20070206184538.675048000@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:45605 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965201AbXBFSxP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Feb 2007 13:53:15 -0500
Content-Disposition: inline; filename=sky2-extreme.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is basic support for the new Yukon Extreme
chip, extracted from the new vendor driver 10.0.4.3.

Since this is untested hardware, it has a big fat warning for now.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |   49 +++++++++++++++++++++++++++++++++++-----------
 drivers/net/sky2.h |   56 +++++++++++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 89 insertions(+), 16 deletions(-)

--- sky2-dev.orig/drivers/net/sky2.c	2007-02-06 10:44:23.000000000 -0800
+++ sky2-dev/drivers/net/sky2.c	2007-02-06 10:44:26.000000000 -0800
@@ -140,7 +140,7 @@
 static const char *yukon2_name[] = {
 	"XL",		/* 0xb3 */
 	"EC Ultra", 	/* 0xb4 */
-	"UNKNOWN",	/* 0xb5 */
+	"Extreme",	/* 0xb5 */
 	"EC",		/* 0xb6 */
 	"FE",		/* 0xb7 */
 };
@@ -211,7 +211,7 @@
 	else
 		sky2_write8(hw, B2_Y2_CLK_GATE, 0);
 
-	if (hw->chip_id == CHIP_ID_YUKON_EC_U) {
+	if (hw->chip_id == CHIP_ID_YUKON_EC_U || hw->chip_id == CHIP_ID_YUKON_EX) {
 		u32 reg1;
 
 		sky2_pci_write32(hw, PCI_DEV_REG3, 0);
@@ -289,8 +289,10 @@
 	struct sky2_port *sky2 = netdev_priv(hw->dev[port]);
 	u16 ctrl, ct1000, adv, pg, ledctrl, ledover, reg;
 
-	if (sky2->autoneg == AUTONEG_ENABLE &&
-	    !(hw->chip_id == CHIP_ID_YUKON_XL || hw->chip_id == CHIP_ID_YUKON_EC_U)) {
+	if (sky2->autoneg == AUTONEG_ENABLE
+	    && !(hw->chip_id == CHIP_ID_YUKON_XL
+		 || hw->chip_id == CHIP_ID_YUKON_EC_U
+		 || hw->chip_id == CHIP_ID_YUKON_EX)) {
 		u16 ectrl = gm_phy_read(hw, port, PHY_MARV_EXT_CTRL);
 
 		ectrl &= ~(PHY_M_EC_M_DSC_MSK | PHY_M_EC_S_DSC_MSK |
@@ -317,8 +319,10 @@
 			/* enable automatic crossover */
 			ctrl |= PHY_M_PC_MDI_XMODE(PHY_M_PC_ENA_AUTO);
 
-			if (sky2->autoneg == AUTONEG_ENABLE &&
-			    (hw->chip_id == CHIP_ID_YUKON_XL || hw->chip_id == CHIP_ID_YUKON_EC_U)) {
+			if (sky2->autoneg == AUTONEG_ENABLE
+			    && (hw->chip_id == CHIP_ID_YUKON_XL
+				|| hw->chip_id == CHIP_ID_YUKON_EC_U
+				|| hw->chip_id == CHIP_ID_YUKON_EX)) {
 				ctrl &= ~PHY_M_PC_DSC_MSK;
 				ctrl |= PHY_M_PC_DSC(2) | PHY_M_PC_DOWN_S_ENA;
 			}
@@ -473,7 +477,9 @@
 		/* restore page register */
 		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, pg);
 		break;
+
 	case CHIP_ID_YUKON_EC_U:
+	case CHIP_ID_YUKON_EX:
 		pg = gm_phy_read(hw, port, PHY_MARV_EXT_ADR);
 
 		/* select page 3 to access LED control register */
@@ -515,7 +521,7 @@
 
 		/* set page register to 0 */
 		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, pg);
-	} else {
+	} else if (hw->chip_id != CHIP_ID_YUKON_EX) {
 		gm_phy_write(hw, port, PHY_MARV_LED_CTRL, ledctrl);
 
 		if (sky2->autoneg == AUTONEG_DISABLE || sky2->speed == SPEED_100) {
@@ -727,7 +733,7 @@
 	sky2_write8(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_RST_CLR);
 	sky2_write16(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_OPER_ON);
 
-	if (hw->chip_id == CHIP_ID_YUKON_EC_U) {
+	if (hw->chip_id == CHIP_ID_YUKON_EC_U || hw->chip_id == CHIP_ID_YUKON_EX) {
 		sky2_write8(hw, SK_REG(port, RX_GMF_LP_THR), 768/8);
 		sky2_write8(hw, SK_REG(port, RX_GMF_UP_THR), 1024/8);
 		if (hw->dev[port]->mtu > ETH_DATA_LEN) {
@@ -1687,7 +1693,9 @@
 	sky2_write8(hw, SK_REG(port, LNK_LED_REG),
 		    LINKLED_ON | LINKLED_BLINK_OFF | LINKLED_LINKSYNC_OFF);
 
-	if (hw->chip_id == CHIP_ID_YUKON_XL || hw->chip_id == CHIP_ID_YUKON_EC_U) {
+	if (hw->chip_id == CHIP_ID_YUKON_XL
+	    || hw->chip_id == CHIP_ID_YUKON_EC_U
+	    || hw->chip_id == CHIP_ID_YUKON_EX) {
 		u16 pg = gm_phy_read(hw, port, PHY_MARV_EXT_ADR);
 		u16 led = PHY_M_LEDC_LOS_CTRL(1);	/* link active */
 
@@ -1780,14 +1788,16 @@
 	sky2->duplex = (aux & PHY_M_PS_FULL_DUP) ? DUPLEX_FULL : DUPLEX_HALF;
 
 	/* Pause bits are offset (9..8) */
-	if (hw->chip_id == CHIP_ID_YUKON_XL || hw->chip_id == CHIP_ID_YUKON_EC_U)
+	if (hw->chip_id == CHIP_ID_YUKON_XL
+	    || hw->chip_id == CHIP_ID_YUKON_EC_U
+	    || hw->chip_id == CHIP_ID_YUKON_EX)
 		aux >>= 6;
 
 	sky2->flow_status = sky2_flow(aux & PHY_M_PS_RX_P_EN,
 				      aux & PHY_M_PS_TX_P_EN);
 
 	if (sky2->duplex == DUPLEX_HALF && sky2->speed < SPEED_1000
-	    && hw->chip_id != CHIP_ID_YUKON_EC_U)
+	    && !(hw->chip_id == CHIP_ID_YUKON_EC_U || hw->chip_id == CHIP_ID_YUKON_EX))
 		sky2->flow_status = FC_NONE;
 
 	if (aux & PHY_M_PS_RX_P_EN)
@@ -2442,6 +2452,7 @@
 	switch (hw->chip_id) {
 	case CHIP_ID_YUKON_EC:
 	case CHIP_ID_YUKON_EC_U:
+	case CHIP_ID_YUKON_EX:
 		return 125;	/* 125 Mhz */
 	case CHIP_ID_YUKON_FE:
 		return 100;	/* 100 Mhz */
@@ -2474,6 +2485,14 @@
 		return -EOPNOTSUPP;
 	}
 
+	if (hw->chip_id == CHIP_ID_YUKON_EX)
+		dev_warn(&hw->pdev->dev, "this driver not yet tested on this chip type\n"
+			 "Please report success or failure to <netdev@vger.kernel.org>\n");
+
+	/* Make sure and enable all clocks */
+	if (hw->chip_id == CHIP_ID_YUKON_EX || hw->chip_id == CHIP_ID_YUKON_EC_U)
+		sky2_pci_write32(hw, PCI_DEV_REG3, 0);
+
 	hw->chip_rev = (sky2_read8(hw, B2_MAC_CFG) & CFG_CHIP_R_MSK) >> 4;
 
 	/* This rev is really old, and requires untested workarounds */
@@ -2502,7 +2521,13 @@
 
 	/* disable ASF */
 	if (hw->chip_id <= CHIP_ID_YUKON_EC) {
-		sky2_write8(hw, B28_Y2_ASF_STAT_CMD, Y2_ASF_RESET);
+		if (hw->chip_id == CHIP_ID_YUKON_EX) {
+			status = sky2_read16(hw, HCU_CCSR);
+			status &= ~(HCU_CCSR_AHB_RST | HCU_CCSR_CPU_RST_MODE |
+				    HCU_CCSR_UC_STATE_MSK);
+			sky2_write16(hw, HCU_CCSR, status);
+		} else
+			sky2_write8(hw, B28_Y2_ASF_STAT_CMD, Y2_ASF_RESET);
 		sky2_write16(hw, B0_CTST, Y2_ASF_DISABLE);
 	}
 
--- sky2-dev.orig/drivers/net/sky2.h	2007-02-06 10:44:15.000000000 -0800
+++ sky2-dev/drivers/net/sky2.h	2007-02-06 10:44:26.000000000 -0800
@@ -371,12 +371,9 @@
 
 /*	B2_CHIP_ID		 8 bit 	Chip Identification Number */
 enum {
-	CHIP_ID_GENESIS	   = 0x0a, /* Chip ID for GENESIS */
-	CHIP_ID_YUKON	   = 0xb0, /* Chip ID for YUKON */
-	CHIP_ID_YUKON_LITE = 0xb1, /* Chip ID for YUKON-Lite (Rev. A1-A3) */
-	CHIP_ID_YUKON_LP   = 0xb2, /* Chip ID for YUKON-LP */
 	CHIP_ID_YUKON_XL   = 0xb3, /* Chip ID for YUKON-2 XL */
 	CHIP_ID_YUKON_EC_U = 0xb4, /* Chip ID for YUKON-2 EC Ultra */
+	CHIP_ID_YUKON_EX   = 0xb5, /* Chip ID for YUKON-2 Extreme */
 	CHIP_ID_YUKON_EC   = 0xb6, /* Chip ID for YUKON-2 EC */
  	CHIP_ID_YUKON_FE   = 0xb7, /* Chip ID for YUKON-2 FE */
 
@@ -768,6 +765,24 @@
 	POLL_LIST_ADDR_HI= 0x0e2c,/* 32 bit	Poll. List Start Addr (high) */
 };
 
+enum {
+	SMB_CFG		 = 0x0e40, /* 32 bit	SMBus Config Register */
+	SMB_CSR		 = 0x0e44, /* 32 bit	SMBus Control/Status Register */
+};
+
+enum {
+	CPU_WDOG	 = 0x0e48, /* 32 bit	Watchdog Register  */
+	CPU_CNTR	 = 0x0e4C, /* 32 bit	Counter Register  */
+	CPU_TIM		 = 0x0e50,/* 32 bit	Timer Compare Register  */
+	CPU_AHB_ADDR	 = 0x0e54, /* 32 bit	CPU AHB Debug  Register  */
+	CPU_AHB_WDATA	 = 0x0e58, /* 32 bit	CPU AHB Debug  Register  */
+	CPU_AHB_RDATA	 = 0x0e5C, /* 32 bit	CPU AHB Debug  Register  */
+	HCU_MAP_BASE	 = 0x0e60, /* 32 bit	Reset Mapping Base */
+	CPU_AHB_CTRL	 = 0x0e64, /* 32 bit	CPU AHB Debug  Register  */
+	HCU_CCSR	 = 0x0e68, /* 32 bit	CPU Control and Status Register */
+	HCU_HCSR	 = 0x0e6C, /* 32 bit	Host Control and Status Register */
+};
+
 /* ASF Subsystem Registers (Yukon-2 only) */
 enum {
 	B28_Y2_SMB_CONFIG  = 0x0e40,/* 32 bit	ASF SMBus Config Register */
@@ -1649,6 +1664,39 @@
 	Y2_ASF_CLR_ASFI = 1<<1,	/* Clear host IRQ */
 	Y2_ASF_HOST_IRQ = 1<<0,	/* Issue an IRQ to HOST system */
 };
+/*	HCU_CCSR	CPU Control and Status Register */
+enum {
+	HCU_CCSR_SMBALERT_MONITOR= 1<<27, /* SMBALERT pin monitor */
+	HCU_CCSR_CPU_SLEEP	= 1<<26, /* CPU sleep status */
+	/* Clock Stretching Timeout */
+	HCU_CCSR_CS_TO		= 1<<25,
+	HCU_CCSR_WDOG		= 1<<24, /* Watchdog Reset */
+
+	HCU_CCSR_CLR_IRQ_HOST	= 1<<17, /* Clear IRQ_HOST */
+	HCU_CCSR_SET_IRQ_HCU	= 1<<16, /* Set IRQ_HCU */
+
+	HCU_CCSR_AHB_RST	= 1<<9, /* Reset AHB bridge */
+	HCU_CCSR_CPU_RST_MODE	= 1<<8, /* CPU Reset Mode */
+
+	HCU_CCSR_SET_SYNC_CPU	= 1<<5,
+	HCU_CCSR_CPU_CLK_DIVIDE_MSK = 3<<3,/* CPU Clock Divide */
+	HCU_CCSR_CPU_CLK_DIVIDE_BASE= 1<<3,
+	HCU_CCSR_OS_PRSNT	= 1<<2, /* ASF OS Present */
+/* Microcontroller State */
+	HCU_CCSR_UC_STATE_MSK	= 3,
+	HCU_CCSR_UC_STATE_BASE	= 1<<0,
+	HCU_CCSR_ASF_RESET	= 0,
+	HCU_CCSR_ASF_HALTED	= 1<<1,
+	HCU_CCSR_ASF_RUNNING	= 1<<0,
+};
+
+/*	HCU_HCSR	Host Control and Status Register */
+enum {
+	HCU_HCSR_SET_IRQ_CPU	= 1<<16, /* Set IRQ_CPU */
+
+	HCU_HCSR_CLR_IRQ_HCU	= 1<<1, /* Clear IRQ_HCU */
+	HCU_HCSR_SET_IRQ_HOST	= 1<<0,	/* Set IRQ_HOST */
+};
 
 /*	STAT_CTRL		32 bit	Status BMU control register (Yukon-2 only) */
 enum {

--
Stephen Hemminger <shemminger@linux-foundation.org>

