From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 11/17] sky2: use MII defines
Date: Tue, 08 May 2007 20:50:00 -0700
Message-ID: <20070509035030.079175041@linux-foundation.org>
References: <20070509034949.624934448@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:40030 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1033077AbXEIEEF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 00:04:05 -0400
Cc: Greg KH <greg@kroah.com>
Content-Disposition: inline; filename=use-mii-defines.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To make driver easier to understand, use the PHY register definitions
from standard mii.h include file rather than those inherited from sk98lin.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |   62 +++++++++----------
 drivers/net/sky2.h |  166 ++++-------------------------------------------------
 2 files changed, 43 insertions(+), 185 deletions(-)

--- sky2-2.6.21.orig/drivers/net/sky2.c	2007-05-08 10:29:17.000000000 -0700
+++ sky2-2.6.21/drivers/net/sky2.c	2007-05-08 10:29:21.000000000 -0700
@@ -268,17 +268,17 @@ static void sky2_gmac_reset(struct sky2_
 /* flow control to advertise bits */
 static const u16 copper_fc_adv[] = {
 	[FC_NONE]	= 0,
-	[FC_TX]		= PHY_M_AN_ASP,
-	[FC_RX]		= PHY_M_AN_PC,
-	[FC_BOTH]	= PHY_M_AN_PC | PHY_M_AN_ASP,
+	[FC_TX]		= ADVERTISE_PAUSE_ASYM,
+	[FC_RX]		= ADVERTISE_PAUSE_CAP,
+	[FC_BOTH]	= ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM,
 };
 
 /* flow control to advertise bits when using 1000BaseX */
 static const u16 fiber_fc_adv[] = {
-	[FC_BOTH] = PHY_M_P_BOTH_MD_X,
-	[FC_TX]   = PHY_M_P_ASYM_MD_X,
-	[FC_RX]	  = PHY_M_P_SYM_MD_X,
-	[FC_NONE] = PHY_M_P_NO_PAUSE_X,
+	[FC_NONE] = 0,
+	[FC_TX]   = ADVERTISE_1000XPAUSE,
+	[FC_RX]	  = ADVERTISE_1000XPSE_ASYM,
+	[FC_BOTH] = ADVERTISE_1000XPAUSE | ADVERTISE_1000XPSE_ASYM,
 };
 
 /* flow control to GMA disable bits */
@@ -360,69 +360,67 @@ static void sky2_phy_init(struct sky2_hw
 			/* for SFP-module set SIGDET polarity to low */
 			ctrl = gm_phy_read(hw, port, PHY_MARV_PHY_CTRL);
 			ctrl |= PHY_M_FIB_SIGD_POL;
-			gm_phy_write(hw, port, PHY_MARV_CTRL, ctrl);
+			gm_phy_write(hw, port, MII_BMCR, ctrl);
 		}
 
 		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, pg);
 	}
 
-	ctrl = PHY_CT_RESET;
+	ctrl = BMCR_RESET;
 	ct1000 = 0;
-	adv = PHY_AN_CSMA;
+	adv = ADVERTISE_CSMA;
 	reg = 0;
 
 	if (sky2->autoneg == AUTONEG_ENABLE) {
 		if (sky2_is_copper(hw)) {
 			if (sky2->advertising & ADVERTISED_1000baseT_Full)
-				ct1000 |= PHY_M_1000C_AFD;
+				ct1000 |= ADVERTISE_1000FULL;
 			if (sky2->advertising & ADVERTISED_1000baseT_Half)
-				ct1000 |= PHY_M_1000C_AHD;
+				ct1000 |= ADVERTISE_1000HALF;
 			if (sky2->advertising & ADVERTISED_100baseT_Full)
-				adv |= PHY_M_AN_100_FD;
+				adv |= ADVERTISE_100FULL;
 			if (sky2->advertising & ADVERTISED_100baseT_Half)
-				adv |= PHY_M_AN_100_HD;
+				adv |= ADVERTISE_100HALF;
 			if (sky2->advertising & ADVERTISED_10baseT_Full)
-				adv |= PHY_M_AN_10_FD;
+				adv |= ADVERTISE_10FULL;
 			if (sky2->advertising & ADVERTISED_10baseT_Half)
-				adv |= PHY_M_AN_10_HD;
+				adv |= ADVERTISE_10HALF;
 
 			adv |= copper_fc_adv[sky2->flow_mode];
 		} else {	/* special defines for FIBER (88E1040S only) */
 			if (sky2->advertising & ADVERTISED_1000baseT_Full)
-				adv |= PHY_M_AN_1000X_AFD;
+				adv |= ADVERTISE_1000XFULL;
 			if (sky2->advertising & ADVERTISED_1000baseT_Half)
-				adv |= PHY_M_AN_1000X_AHD;
+				adv |= ADVERTISE_1000XHALF;
 
 			adv |= fiber_fc_adv[sky2->flow_mode];
 		}
 
 		/* Restart Auto-negotiation */
-		ctrl |= PHY_CT_ANE | PHY_CT_RE_CFG;
+		ctrl |= BMCR_ANRESTART | BMCR_ANENABLE;
 	} else {
 		/* forced speed/duplex settings */
-		ct1000 = PHY_M_1000C_MSE;
 
 		/* Disable auto update for duplex flow control and speed */
 		reg |= GM_GPCR_AU_ALL_DIS;
 
 		switch (sky2->speed) {
 		case SPEED_1000:
-			ctrl |= PHY_CT_SP1000;
+			ctrl |= BMCR_SPEED1000;
 			reg |= GM_GPCR_SPEED_1000;
 			break;
 		case SPEED_100:
-			ctrl |= PHY_CT_SP100;
+			ctrl |= BMCR_SPEED100;
 			reg |= GM_GPCR_SPEED_100;
 			break;
 		}
 
 		if (sky2->duplex == DUPLEX_FULL) {
 			reg |= GM_GPCR_DUP_FULL;
-			ctrl |= PHY_CT_DUP_MD;
+			ctrl |= BMCR_FULLDPLX;
 		} else if (sky2->speed < SPEED_1000)
 			sky2->flow_mode = FC_NONE;
 
-
  		reg |= gm_fc_disable[sky2->flow_mode];
 
 		/* Forward pause packets to GMAC? */
@@ -435,10 +433,10 @@ static void sky2_phy_init(struct sky2_hw
 	gma_write16(hw, port, GM_GP_CTRL, reg);
 
 	if (hw->chip_id != CHIP_ID_YUKON_FE)
-		gm_phy_write(hw, port, PHY_MARV_1000T_CTRL, ct1000);
+		gm_phy_write(hw, port, MII_CTRL1000, ct1000);
 
-	gm_phy_write(hw, port, PHY_MARV_AUNE_ADV, adv);
-	gm_phy_write(hw, port, PHY_MARV_CTRL, ctrl);
+	gm_phy_write(hw, port, MII_ADVERTISE, adv);
+	gm_phy_write(hw, port, MII_BMCR, ctrl);
 
 	/* Setup Phy LED's */
 	ledctrl = PHY_M_LED_PULS_DUR(PULS_170MS);
@@ -661,8 +659,8 @@ static void sky2_mac_init(struct sky2_hw
 		do {
 			sky2_write8(hw, SK_REG(1, GMAC_CTRL), GMC_RST_SET);
 			sky2_write8(hw, SK_REG(1, GMAC_CTRL), GMC_RST_CLR);
-		} while (gm_phy_read(hw, 1, PHY_MARV_ID0) != PHY_MARV_ID0_VAL ||
-			 gm_phy_read(hw, 1, PHY_MARV_ID1) != PHY_MARV_ID1_Y2 ||
+		} while (gm_phy_read(hw, 1, MII_PHYSID1) != ID1_MARVELL ||
+			 gm_phy_read(hw, 1, MII_PHYSID2) != ID2_Y2 ||
 			 gm_phy_read(hw, 1, PHY_MARV_INT_MASK) != 0);
 	}
 
@@ -1762,9 +1760,9 @@ static int sky2_autoneg_done(struct sky2
 	unsigned port = sky2->port;
 	u16 advert, lpa;
 
-	advert = gm_phy_read(hw, port, PHY_MARV_AUNE_ADV);
-	lpa = gm_phy_read(hw, port, PHY_MARV_AUNE_LP);
-	if (lpa & PHY_M_AN_RF) {
+	advert = gm_phy_read(hw, port, MII_ADVERTISE);
+	lpa = gm_phy_read(hw, port, MII_LPA);
+	if (lpa & LPA_RFAULT) {
 		printk(KERN_ERR PFX "%s: remote fault", sky2->netdev->name);
 		return -1;
 	}
--- sky2-2.6.21.orig/drivers/net/sky2.h	2007-05-08 10:29:05.000000000 -0700
+++ sky2-2.6.21/drivers/net/sky2.h	2007-05-08 10:29:21.000000000 -0700
@@ -851,32 +851,18 @@ enum {
  * Marvel-PHY Registers, indirect addressed over GMAC
  */
 enum {
-	PHY_MARV_CTRL		= 0x00,/* 16 bit r/w	PHY Control Register */
-	PHY_MARV_STAT		= 0x01,/* 16 bit r/o	PHY Status Register */
-	PHY_MARV_ID0		= 0x02,/* 16 bit r/o	PHY ID0 Register */
-	PHY_MARV_ID1		= 0x03,/* 16 bit r/o	PHY ID1 Register */
-	PHY_MARV_AUNE_ADV	= 0x04,/* 16 bit r/w	Auto-Neg. Advertisement */
-	PHY_MARV_AUNE_LP	= 0x05,/* 16 bit r/o	Link Part Ability Reg */
-	PHY_MARV_AUNE_EXP	= 0x06,/* 16 bit r/o	Auto-Neg. Expansion Reg */
-	PHY_MARV_NEPG		= 0x07,/* 16 bit r/w	Next Page Register */
-	PHY_MARV_NEPG_LP	= 0x08,/* 16 bit r/o	Next Page Link Partner */
 	/* Marvel-specific registers */
-	PHY_MARV_1000T_CTRL	= 0x09,/* 16 bit r/w	1000Base-T Control Reg */
-	PHY_MARV_1000T_STAT	= 0x0a,/* 16 bit r/o	1000Base-T Status Reg */
-	PHY_MARV_EXT_STAT	= 0x0f,/* 16 bit r/o	Extended Status Reg */
 	PHY_MARV_PHY_CTRL	= 0x10,/* 16 bit r/w	PHY Specific Ctrl Reg */
 	PHY_MARV_PHY_STAT	= 0x11,/* 16 bit r/o	PHY Specific Stat Reg */
 	PHY_MARV_INT_MASK	= 0x12,/* 16 bit r/w	Interrupt Mask Reg */
 	PHY_MARV_INT_STAT	= 0x13,/* 16 bit r/o	Interrupt Status Reg */
 	PHY_MARV_EXT_CTRL	= 0x14,/* 16 bit r/w	Ext. PHY Specific Ctrl */
-	PHY_MARV_RXE_CNT	= 0x15,/* 16 bit r/w	Receive Error Counter */
+
 	PHY_MARV_EXT_ADR	= 0x16,/* 16 bit r/w	Ext. Ad. for Cable Diag. */
-	PHY_MARV_PORT_IRQ	= 0x17,/* 16 bit r/o	Port 0 IRQ (88E1111 only) */
+
 	PHY_MARV_LED_CTRL	= 0x18,/* 16 bit r/w	LED Control Reg */
 	PHY_MARV_LED_OVER	= 0x19,/* 16 bit r/w	Manual LED Override Reg */
-	PHY_MARV_EXT_CTRL_2	= 0x1a,/* 16 bit r/w	Ext. PHY Specific Ctrl 2 */
-	PHY_MARV_EXT_P_STAT	= 0x1b,/* 16 bit r/w	Ext. PHY Spec. Stat Reg */
-	PHY_MARV_CABLE_DIAG	= 0x1c,/* 16 bit r/o	Cable Diagnostic Reg */
+
 	PHY_MARV_PAGE_ADDR	= 0x1d,/* 16 bit r/w	Extended Page Address Reg */
 	PHY_MARV_PAGE_DATA	= 0x1e,/* 16 bit r/w	Extended Page Data Reg */
 
@@ -888,133 +874,16 @@ enum {
 	PHY_MARV_FE_SPEC_2	= 0x1c,/* 16 bit r/w	Specific Control Reg. 2 */
 };
 
-enum {
-	PHY_CT_RESET	= 1<<15, /* Bit 15: (sc)	clear all PHY related regs */
-	PHY_CT_LOOP	= 1<<14, /* Bit 14:	enable Loopback over PHY */
-	PHY_CT_SPS_LSB	= 1<<13, /* Bit 13:	Speed select, lower bit */
-	PHY_CT_ANE	= 1<<12, /* Bit 12:	Auto-Negotiation Enabled */
-	PHY_CT_PDOWN	= 1<<11, /* Bit 11:	Power Down Mode */
-	PHY_CT_ISOL	= 1<<10, /* Bit 10:	Isolate Mode */
-	PHY_CT_RE_CFG	= 1<<9, /* Bit  9:	(sc) Restart Auto-Negotiation */
-	PHY_CT_DUP_MD	= 1<<8, /* Bit  8:	Duplex Mode */
-	PHY_CT_COL_TST	= 1<<7, /* Bit  7:	Collision Test enabled */
-	PHY_CT_SPS_MSB	= 1<<6, /* Bit  6:	Speed select, upper bit */
-};
-
-enum {
-	PHY_CT_SP1000	= PHY_CT_SPS_MSB, /* enable speed of 1000 Mbps */
-	PHY_CT_SP100	= PHY_CT_SPS_LSB, /* enable speed of  100 Mbps */
-	PHY_CT_SP10	= 0,		  /* enable speed of   10 Mbps */
-};
-
-enum {
-	PHY_ST_EXT_ST	= 1<<8, /* Bit  8:	Extended Status Present */
-
-	PHY_ST_PRE_SUP	= 1<<6, /* Bit  6:	Preamble Suppression */
-	PHY_ST_AN_OVER	= 1<<5, /* Bit  5:	Auto-Negotiation Over */
-	PHY_ST_REM_FLT	= 1<<4, /* Bit  4:	Remote Fault Condition Occured */
-	PHY_ST_AN_CAP	= 1<<3, /* Bit  3:	Auto-Negotiation Capability */
-	PHY_ST_LSYNC	= 1<<2, /* Bit  2:	Link Synchronized */
-	PHY_ST_JAB_DET	= 1<<1, /* Bit  1:	Jabber Detected */
-	PHY_ST_EXT_REG	= 1<<0, /* Bit  0:	Extended Register available */
-};
-
-enum {
-	PHY_I1_OUI_MSK	= 0x3f<<10, /* Bit 15..10:	Organization Unique ID */
-	PHY_I1_MOD_NUM	= 0x3f<<4, /* Bit  9.. 4:	Model Number */
-	PHY_I1_REV_MSK	= 0xf, /* Bit  3.. 0:	Revision Number */
-};
-
 /* different Marvell PHY Ids */
 enum {
-	PHY_MARV_ID0_VAL= 0x0141, /* Marvell Unique Identifier */
+	ID1_MARVELL= 0x0141, /* Marvell Unique Identifier */
 
-	PHY_BCOM_ID1_A1	= 0x6041,
-	PHY_BCOM_ID1_B2	= 0x6043,
-	PHY_BCOM_ID1_C0	= 0x6044,
-	PHY_BCOM_ID1_C5	= 0x6047,
-
-	PHY_MARV_ID1_B0	= 0x0C23, /* Yukon 	(PHY 88E1011) */
-	PHY_MARV_ID1_B2	= 0x0C25, /* Yukon-Plus (PHY 88E1011) */
-	PHY_MARV_ID1_C2	= 0x0CC2, /* Yukon-EC	(PHY 88E1111) */
-	PHY_MARV_ID1_Y2	= 0x0C91, /* Yukon-2	(PHY 88E1112) */
-	PHY_MARV_ID1_FE = 0x0C83, /* Yukon-FE   (PHY 88E3082 Rev.A1) */
-	PHY_MARV_ID1_ECU= 0x0CB0, /* Yukon-ECU  (PHY 88E1149 Rev.B2?) */
-};
-
-/* Advertisement register bits */
-enum {
-	PHY_AN_NXT_PG	= 1<<15, /* Bit 15:	Request Next Page */
-	PHY_AN_ACK	= 1<<14, /* Bit 14:	(ro) Acknowledge Received */
-	PHY_AN_RF	= 1<<13, /* Bit 13:	Remote Fault Bits */
-
-	PHY_AN_PAUSE_ASYM = 1<<11,/* Bit 11:	Try for asymmetric */
-	PHY_AN_PAUSE_CAP = 1<<10, /* Bit 10:	Try for pause */
-	PHY_AN_100BASE4	= 1<<9, /* Bit 9:	Try for 100mbps 4k packets */
-	PHY_AN_100FULL	= 1<<8, /* Bit 8:	Try for 100mbps full-duplex */
-	PHY_AN_100HALF	= 1<<7, /* Bit 7:	Try for 100mbps half-duplex */
-	PHY_AN_10FULL	= 1<<6, /* Bit 6:	Try for 10mbps full-duplex */
-	PHY_AN_10HALF	= 1<<5, /* Bit 5:	Try for 10mbps half-duplex */
-	PHY_AN_CSMA	= 1<<0, /* Bit 0:	Only selector supported */
-	PHY_AN_SEL	= 0x1f, /* Bit 4..0:	Selector Field, 00001=Ethernet*/
-	PHY_AN_FULL	= PHY_AN_100FULL | PHY_AN_10FULL | PHY_AN_CSMA,
-	PHY_AN_ALL	= PHY_AN_10HALF | PHY_AN_10FULL |
-		  	  PHY_AN_100HALF | PHY_AN_100FULL,
-};
-
-/*****  PHY_BCOM_1000T_STAT	16 bit r/o	1000Base-T Status Reg *****/
-/*****  PHY_MARV_1000T_STAT	16 bit r/o	1000Base-T Status Reg *****/
-enum {
-	PHY_B_1000S_MSF	= 1<<15, /* Bit 15:	Master/Slave Fault */
-	PHY_B_1000S_MSR	= 1<<14, /* Bit 14:	Master/Slave Result */
-	PHY_B_1000S_LRS	= 1<<13, /* Bit 13:	Local Receiver Status */
-	PHY_B_1000S_RRS	= 1<<12, /* Bit 12:	Remote Receiver Status */
-	PHY_B_1000S_LP_FD	= 1<<11, /* Bit 11:	Link Partner can FD */
-	PHY_B_1000S_LP_HD	= 1<<10, /* Bit 10:	Link Partner can HD */
-									/* Bit  9..8:	reserved */
-	PHY_B_1000S_IEC	= 0xff, /* Bit  7..0:	Idle Error Count */
-};
-
-/** Marvell-Specific */
-enum {
-	PHY_M_AN_NXT_PG	= 1<<15, /* Request Next Page */
-	PHY_M_AN_ACK	= 1<<14, /* (ro)	Acknowledge Received */
-	PHY_M_AN_RF	= 1<<13, /* Remote Fault */
-
-	PHY_M_AN_ASP	= 1<<11, /* Asymmetric Pause */
-	PHY_M_AN_PC	= 1<<10, /* MAC Pause implemented */
-	PHY_M_AN_100_T4	= 1<<9, /* Not cap. 100Base-T4 (always 0) */
-	PHY_M_AN_100_FD	= 1<<8, /* Advertise 100Base-TX Full Duplex */
-	PHY_M_AN_100_HD	= 1<<7, /* Advertise 100Base-TX Half Duplex */
-	PHY_M_AN_10_FD	= 1<<6, /* Advertise 10Base-TX Full Duplex */
-	PHY_M_AN_10_HD	= 1<<5, /* Advertise 10Base-TX Half Duplex */
-	PHY_M_AN_SEL_MSK =0x1f<<4,	/* Bit  4.. 0: Selector Field Mask */
-};
-
-/* special defines for FIBER (88E1011S only) */
-enum {
-	PHY_M_AN_ASP_X	= 1<<8, /* Asymmetric Pause */
-	PHY_M_AN_PC_X	= 1<<7, /* MAC Pause implemented */
-	PHY_M_AN_1000X_AHD	= 1<<6, /* Advertise 10000Base-X Half Duplex */
-	PHY_M_AN_1000X_AFD	= 1<<5, /* Advertise 10000Base-X Full Duplex */
-};
-
-/* Pause Bits (PHY_M_AN_ASP_X and PHY_M_AN_PC_X) encoding */
-enum {
-	PHY_M_P_NO_PAUSE_X	= 0<<7,/* Bit  8.. 7:	no Pause Mode */
-	PHY_M_P_SYM_MD_X	= 1<<7, /* Bit  8.. 7:	symmetric Pause Mode */
-	PHY_M_P_ASYM_MD_X	= 2<<7,/* Bit  8.. 7:	asymmetric Pause Mode */
-	PHY_M_P_BOTH_MD_X	= 3<<7,/* Bit  8.. 7:	both Pause Mode */
-};
-
-/*****  PHY_MARV_1000T_CTRL	16 bit r/w	1000Base-T Control Reg *****/
-enum {
-	PHY_M_1000C_TEST	= 7<<13,/* Bit 15..13:	Test Modes */
-	PHY_M_1000C_MSE	= 1<<12, /* Manual Master/Slave Enable */
-	PHY_M_1000C_MSC	= 1<<11, /* M/S Configuration (1=Master) */
-	PHY_M_1000C_MPD	= 1<<10, /* Multi-Port Device */
-	PHY_M_1000C_AFD	= 1<<9, /* Advertise Full Duplex */
-	PHY_M_1000C_AHD	= 1<<8, /* Advertise Half Duplex */
+	ID2_B0	= 0x0C23, /* Yukon 	(PHY 88E1011) */
+	ID2_B2	= 0x0C25, /* Yukon-Plus (PHY 88E1011) */
+	ID2_C2	= 0x0CC2, /* Yukon-EC	(PHY 88E1111) */
+	ID2_Y2	= 0x0C91, /* Yukon-2	(PHY 88E1112) */
+	ID2_FE  = 0x0C83, /* Yukon-FE   (PHY 88E3082 Rev.A1) */
+	ID2_ECU = 0x0CB0, /* Yukon-ECU  (PHY 88E1149 Rev.B2?) */
 };
 
 /*****  PHY_MARV_PHY_CTRL	16 bit r/w	PHY Specific Ctrl Reg *****/
@@ -1031,9 +900,7 @@ enum {
 	PHY_M_PC_SQE_T_ENA	= 1<<2, /* SQE Test Enabled */
 	PHY_M_PC_POL_R_DIS	= 1<<1, /* Polarity Reversal Disabled */
 	PHY_M_PC_DIS_JABBER	= 1<<0, /* Disable Jabber */
-};
 
-enum {
 	PHY_M_PC_EN_DET		= 2<<8,	/* Energy Detect (Mode 1) */
 	PHY_M_PC_EN_DET_PLUS	= 3<<8, /* Energy Detect Plus (Mode 2) */
 };
@@ -1292,15 +1159,8 @@ enum {
 	LED_PAR_CTRL_INACT	= 0x0f
 };
 
-/*****,PHY_MARV_FE_SPEC_2		16 bit r/w	Specific Control Reg. 2 *****/
-enum {
-	PHY_M_FESC_DIS_WAIT	= 1<<2, /* Disable TDR Waiting Period */
-	PHY_M_FESC_ENA_MCLK	= 1<<1, /* Enable MAC Rx Clock in sleep mode */
-	PHY_M_FESC_SEL_CL_A	= 1<<0, /* Select Class A driver (100B-TX) */
-};
-
 /* for Yukon-2 Gigabit Ethernet PHY (88E1112 only) */
-/*****  PHY_MARV_PHY_CTRL (page 1)		16 bit r/w	Fiber Specific Ctrl *****/
+/*  PHY_MARV_PHY_CTRL (page 1)		16 bit r/w	Fiber Specific Ctrl */
 enum {
 	PHY_M_FIB_FORCE_LNK	= 1<<10,/* Force Link Good */
 	PHY_M_FIB_SIGD_POL	= 1<<9,	/* SIGDET Polarity */
@@ -1308,7 +1168,7 @@ enum {
 };
 
 /* for Yukon-2 Gigabit Ethernet PHY (88E1112 only) */
-/*****  PHY_MARV_PHY_CTRL (page 2)		16 bit r/w	MAC Specific Ctrl *****/
+/*  PHY_MARV_PHY_CTRL (page 2)		16 bit r/w	MAC Specific Ctrl */
 enum {
 	PHY_M_MAC_MD_MSK	= 7<<7, /* Bit  9.. 7: Mode Select Mask */
 	PHY_M_MAC_MD_AUTO	= 3,/* Auto Copper/1000Base-X */
@@ -1317,7 +1177,7 @@ enum {
 };
 #define PHY_M_MAC_MODE_SEL(x)	(((x)<<7) & PHY_M_MAC_MD_MSK)
 
-/*****  PHY_MARV_PHY_CTRL (page 3)		16 bit r/w	LED Control Reg. *****/
+/*  PHY_MARV_PHY_CTRL (page 3)		16 bit r/w	LED Control Reg. */
 enum {
 	PHY_M_LEDC_LOS_MSK	= 0xf<<12,/* Bit 15..12: LOS LED Ctrl. Mask */
 	PHY_M_LEDC_INIT_MSK	= 0xf<<8, /* Bit 11.. 8: INIT LED Ctrl. Mask */

--

