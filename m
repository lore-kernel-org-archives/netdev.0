From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 4/6] bnx2x: revised link register access
Date: Wed, 20 Jun 2012 11:49:33 +0300
Message-ID: <1340182175-916-5-git-send-email-yuvalmin@broadcom.com>
References: <1340182175-916-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Yaniv Rosner" <yaniv.rosner@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1812 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755647Ab2FTIvt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2012 04:51:49 -0400
In-Reply-To: <1340182175-916-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a semantic change, cleaning some sections in which the bnx2x
handles the phy's registers.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Yaniv Rosner <yaniv.rosner@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |  238 +++++++++-------------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h |    5 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h  |    1 +
 3 files changed, 100 insertions(+), 144 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 17ddb9f..fc7ff06 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -3755,44 +3755,35 @@ static u8 bnx2x_ext_phy_resolve_fc(struct bnx2x_phy *phy,
 static void bnx2x_warpcore_enable_AN_KR(struct bnx2x_phy *phy,
 					struct link_params *params,
 					struct link_vars *vars) {
-	u16 val16 = 0, lane, bam37 = 0;
-	struct bnx2x *bp = params->bp;
+	u16 val16 = 0, lane, i;
+	struct bnx2x *bp = params->bp;
+	static struct bnx2x_reg_set reg_set[] = {
+		{MDIO_WC_DEVAD, MDIO_WC_REG_SERDESDIGITAL_CONTROL1000X2, 0x7},
+		{MDIO_AN_DEVAD, MDIO_WC_REG_PAR_DET_10G_CTRL, 0},
+		{MDIO_WC_DEVAD, MDIO_WC_REG_CL72_USERB0_CL72_MISC1_CONTROL, 0},
+		{MDIO_WC_DEVAD, MDIO_WC_REG_XGXSBLK1_LANECTRL0, 0xff},
+		{MDIO_WC_DEVAD, MDIO_WC_REG_XGXSBLK1_LANECTRL1, 0x5555},
+		{MDIO_PMA_DEVAD, MDIO_WC_REG_IEEE0BLK_AUTONEGNP, 0x0},
+		{MDIO_WC_DEVAD, MDIO_WC_REG_RX66_CONTROL, 0x7415},
+		{MDIO_WC_DEVAD, MDIO_WC_REG_SERDESDIGITAL_MISC2, 0x6190},
+		/* Disable Autoneg: re-enable it after adv is done. */
+		{MDIO_AN_DEVAD, MDIO_WC_REG_IEEE0BLK_MIICNTL, 0}
+	};
 	DP(NETIF_MSG_LINK, "Enable Auto Negotiation for KR\n");
 	/* Set to default registers that may be overriden by 10G force */
-	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
-			 MDIO_WC_REG_SERDESDIGITAL_CONTROL1000X2, 0x7);
-	bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD,
-			 MDIO_WC_REG_PAR_DET_10G_CTRL, 0);
-	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
-			 MDIO_WC_REG_CL72_USERB0_CL72_MISC1_CONTROL, 0);
-	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
-			MDIO_WC_REG_XGXSBLK1_LANECTRL0, 0xff);
-	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
-			MDIO_WC_REG_XGXSBLK1_LANECTRL1, 0x5555);
-	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD,
-			 MDIO_WC_REG_IEEE0BLK_AUTONEGNP, 0x0);
-	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
-			 MDIO_WC_REG_RX66_CONTROL, 0x7415);
-	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
-			 MDIO_WC_REG_SERDESDIGITAL_MISC2, 0x6190);
-	/* Disable Autoneg: re-enable it after adv is done. */
-	bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD,
-			 MDIO_WC_REG_IEEE0BLK_MIICNTL, 0);
+	for (i = 0; i < sizeof(reg_set)/sizeof(struct bnx2x_reg_set); i++)
+		bnx2x_cl45_write(bp, phy, reg_set[i].devad, reg_set[i].reg,
+				 reg_set[i].val);
 
 	/* Check adding advertisement for 1G KX */
 	if (((vars->line_speed == SPEED_AUTO_NEG) &&
 	     (phy->speed_cap_mask & PORT_HW_CFG_SPEED_CAPABILITY_D0_1G)) ||
 	    (vars->line_speed == SPEED_1000)) {
-		u16 sd_digital;
+		u32 addr = MDIO_WC_REG_SERDESDIGITAL_CONTROL1000X2;
 		val16 |= (1<<5);
 
 		/* Enable CL37 1G Parallel Detect */
-		bnx2x_cl45_read(bp, phy, MDIO_WC_DEVAD,
-			MDIO_WC_REG_SERDESDIGITAL_CONTROL1000X2, &sd_digital);
-		bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
-			 MDIO_WC_REG_SERDESDIGITAL_CONTROL1000X2,
-				 (sd_digital | 0x1));
-
+		bnx2x_cl45_read_or_write(bp, phy, MDIO_WC_DEVAD, addr, 0x1);
 		DP(NETIF_MSG_LINK, "Advertize 1G\n");
 	}
 	if (((vars->line_speed == SPEED_AUTO_NEG) &&
@@ -3802,7 +3793,7 @@ static void bnx2x_warpcore_enable_AN_KR(struct bnx2x_phy *phy,
 		val16 |= (1<<7);
 		/* Enable 10G Parallel Detect */
 		bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD,
-				MDIO_WC_REG_PAR_DET_10G_CTRL, 1);
+				 MDIO_WC_REG_PAR_DET_10G_CTRL, 1);
 
 		DP(NETIF_MSG_LINK, "Advertize 10G\n");
 	}
@@ -3836,10 +3827,9 @@ static void bnx2x_warpcore_enable_AN_KR(struct bnx2x_phy *phy,
 		   offsetof(struct shmem_region, dev_info.
 			    port_hw_config[params->port].default_cfg)) &
 	    PORT_HW_CFG_ENABLE_BAM_ON_KR_ENABLED) {
-		bnx2x_cl45_read(bp, phy, MDIO_WC_DEVAD,
-				MDIO_WC_REG_DIGITAL6_MP5_NEXTPAGECTRL, &bam37);
-		bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
-			MDIO_WC_REG_DIGITAL6_MP5_NEXTPAGECTRL, bam37 | 1);
+		bnx2x_cl45_read_or_write(bp, phy, MDIO_WC_DEVAD,
+					 MDIO_WC_REG_DIGITAL6_MP5_NEXTPAGECTRL,
+					 1);
 		DP(NETIF_MSG_LINK, "Enable CL37 BAM on KR\n");
 	}
 
@@ -3853,11 +3843,8 @@ static void bnx2x_warpcore_enable_AN_KR(struct bnx2x_phy *phy,
 		DP(NETIF_MSG_LINK, "Enable AN KR work-around\n");
 		vars->rx_tx_asic_rst = MAX_KR_LINK_RETRY;
 	}
-	bnx2x_cl45_read(bp, phy, MDIO_WC_DEVAD,
-			MDIO_WC_REG_DIGITAL5_MISC7, &val16);
-
-	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
-			 MDIO_WC_REG_DIGITAL5_MISC7, val16 | 0x100);
+	bnx2x_cl45_read_or_write(bp, phy, MDIO_WC_DEVAD,
+				 MDIO_WC_REG_DIGITAL5_MISC7, 0x100);
 
 	/* Over 1G - AN local device user page 1 */
 	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
@@ -3874,50 +3861,35 @@ static void bnx2x_warpcore_set_10G_KR(struct bnx2x_phy *phy,
 				      struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
-	u16 val;
-
-	/* Disable Autoneg */
-	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
-			 MDIO_WC_REG_SERDESDIGITAL_CONTROL1000X2, 0x7);
-
-	bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD,
-			 MDIO_WC_REG_PAR_DET_10G_CTRL, 0);
-
-	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
-			 MDIO_WC_REG_CL72_USERB0_CL72_MISC1_CONTROL, 0x3f00);
-
-	bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD,
-			 MDIO_WC_REG_AN_IEEE1BLK_AN_ADVERTISEMENT1, 0);
-
-	bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD,
-			 MDIO_WC_REG_IEEE0BLK_MIICNTL, 0x0);
-
-	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
-			MDIO_WC_REG_DIGITAL3_UP1, 0x1);
-
-	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
-			 MDIO_WC_REG_DIGITAL5_MISC7, 0xa);
-
-	/* Disable CL36 PCS Tx */
-	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
-			MDIO_WC_REG_XGXSBLK1_LANECTRL0, 0x0);
-
-	/* Double Wide Single Data Rate @ pll rate */
-	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
-			MDIO_WC_REG_XGXSBLK1_LANECTRL1, 0xFFFF);
-
-	/* Leave cl72 training enable, needed for KR */
-	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD,
+	u16 i;
+	static struct bnx2x_reg_set reg_set[] = {
+		/* Disable Autoneg */
+		{MDIO_WC_DEVAD, MDIO_WC_REG_SERDESDIGITAL_CONTROL1000X2, 0x7},
+		{MDIO_AN_DEVAD, MDIO_WC_REG_PAR_DET_10G_CTRL, 0},
+		{MDIO_WC_DEVAD, MDIO_WC_REG_CL72_USERB0_CL72_MISC1_CONTROL,
+			0x3f00},
+		{MDIO_AN_DEVAD, MDIO_WC_REG_AN_IEEE1BLK_AN_ADVERTISEMENT1, 0},
+		{MDIO_AN_DEVAD, MDIO_WC_REG_IEEE0BLK_MIICNTL, 0x0},
+		{MDIO_WC_DEVAD, MDIO_WC_REG_DIGITAL3_UP1, 0x1},
+		{MDIO_WC_DEVAD, MDIO_WC_REG_DIGITAL5_MISC7, 0xa},
+		/* Disable CL36 PCS Tx */
+		{MDIO_WC_DEVAD, MDIO_WC_REG_XGXSBLK1_LANECTRL0, 0x0},
+		/* Double Wide Single Data Rate @ pll rate */
+		{MDIO_WC_DEVAD, MDIO_WC_REG_XGXSBLK1_LANECTRL1, 0xFFFF},
+		/* Leave cl72 training enable, needed for KR */
+		{MDIO_PMA_DEVAD,
 		MDIO_WC_REG_PMD_IEEE9BLK_TENGBASE_KR_PMD_CONTROL_REGISTER_150,
-		0x2);
+		0x2}
+	};
+
+	for (i = 0; i < sizeof(reg_set)/sizeof(struct bnx2x_reg_set); i++)
+		bnx2x_cl45_write(bp, phy, reg_set[i].devad, reg_set[i].reg,
+				 reg_set[i].val);
 
 	/* Leave CL72 enabled */
-	bnx2x_cl45_read(bp, phy, MDIO_WC_DEVAD,
-			 MDIO_WC_REG_CL72_USERB0_CL72_MISC1_CONTROL,
-			 &val);
-	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
-			 MDIO_WC_REG_CL72_USERB0_CL72_MISC1_CONTROL,
-			 val | 0x3800);
+	bnx2x_cl45_read_or_write(bp, phy, MDIO_WC_DEVAD,
+				 MDIO_WC_REG_CL72_USERB0_CL72_MISC1_CONTROL,
+				 0x3800);
 
 	/* Set speed via PMA/PMD register */
 	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD,
@@ -3953,16 +3925,12 @@ static void bnx2x_warpcore_set_10G_XFI(struct bnx2x_phy *phy,
 	struct bnx2x *bp = params->bp;
 	u16 misc1_val, tap_val, tx_driver_val, lane, val;
 	/* Hold rxSeqStart */
-	bnx2x_cl45_read(bp, phy, MDIO_WC_DEVAD,
-			MDIO_WC_REG_DSC2B0_DSC_MISC_CTRL0, &val);
-	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
-			 MDIO_WC_REG_DSC2B0_DSC_MISC_CTRL0, (val | 0x8000));
+	bnx2x_cl45_read_or_write(bp, phy, MDIO_WC_DEVAD,
+				 MDIO_WC_REG_DSC2B0_DSC_MISC_CTRL0, 0x8000);
 
 	/* Hold tx_fifo_reset */
-	bnx2x_cl45_read(bp, phy, MDIO_WC_DEVAD,
-			MDIO_WC_REG_SERDESDIGITAL_CONTROL1000X3, &val);
-	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
-			 MDIO_WC_REG_SERDESDIGITAL_CONTROL1000X3, (val | 0x1));
+	bnx2x_cl45_read_or_write(bp, phy, MDIO_WC_DEVAD,
+				 MDIO_WC_REG_SERDESDIGITAL_CONTROL1000X3, 0x1);
 
 	/* Disable CL73 AN */
 	bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD, MDIO_AN_REG_CTRL, 0);
@@ -3974,10 +3942,8 @@ static void bnx2x_warpcore_set_10G_XFI(struct bnx2x_phy *phy,
 			 MDIO_WC_REG_FX100_CTRL1, (val & 0xFFFA));
 
 	/* Disable 100FX Idle detect */
-	bnx2x_cl45_read(bp, phy, MDIO_WC_DEVAD,
-			MDIO_WC_REG_FX100_CTRL3, &val);
-	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
-			 MDIO_WC_REG_FX100_CTRL3, (val | 0x0080));
+	bnx2x_cl45_read_or_write(bp, phy, MDIO_WC_DEVAD,
+				 MDIO_WC_REG_FX100_CTRL3, 0x0080);
 
 	/* Set Block address to Remote PHY & Clear forced_speed[5] */
 	bnx2x_cl45_read(bp, phy, MDIO_WC_DEVAD,
@@ -4038,16 +4004,12 @@ static void bnx2x_warpcore_set_10G_XFI(struct bnx2x_phy *phy,
 			 tx_driver_val);
 
 	/* Enable fiber mode, enable and invert sig_det */
-	bnx2x_cl45_read(bp, phy, MDIO_WC_DEVAD,
-			MDIO_WC_REG_SERDESDIGITAL_CONTROL1000X1, &val);
-	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
-			 MDIO_WC_REG_SERDESDIGITAL_CONTROL1000X1, val | 0xd);
+	bnx2x_cl45_read_or_write(bp, phy, MDIO_WC_DEVAD,
+				 MDIO_WC_REG_SERDESDIGITAL_CONTROL1000X1, 0xd);
 
 	/* Set Block address to Remote PHY & Set forced_speed[5], 40bit mode */
-	bnx2x_cl45_read(bp, phy, MDIO_WC_DEVAD,
-			MDIO_WC_REG_DIGITAL4_MISC3, &val);
-	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
-			 MDIO_WC_REG_DIGITAL4_MISC3, val | 0x8080);
+	bnx2x_cl45_read_or_write(bp, phy, MDIO_WC_DEVAD,
+				 MDIO_WC_REG_DIGITAL4_MISC3, 0x8080);
 
 	/* Enable LPI pass through */
 	DP(NETIF_MSG_LINK, "Configure WC for LPI pass through\n");
@@ -4245,40 +4207,35 @@ static void bnx2x_warpcore_clear_regs(struct bnx2x_phy *phy,
 				      u16 lane)
 {
 	struct bnx2x *bp = params->bp;
-	u16 val16;
-
+	u16 i;
+	static struct bnx2x_reg_set wc_regs[] = {
+		{MDIO_AN_DEVAD, MDIO_AN_REG_CTRL, 0},
+		{MDIO_WC_DEVAD, MDIO_WC_REG_FX100_CTRL1, 0x014a},
+		{MDIO_WC_DEVAD, MDIO_WC_REG_FX100_CTRL3, 0x0800},
+		{MDIO_WC_DEVAD, MDIO_WC_REG_DIGITAL4_MISC3, 0x8008},
+		{MDIO_WC_DEVAD, MDIO_WC_REG_SERDESDIGITAL_CONTROL1000X1,
+			0x0195},
+		{MDIO_WC_DEVAD, MDIO_WC_REG_SERDESDIGITAL_CONTROL1000X2,
+			0x0007},
+		{MDIO_WC_DEVAD, MDIO_WC_REG_SERDESDIGITAL_CONTROL1000X3,
+			0x0002},
+		{MDIO_WC_DEVAD, MDIO_WC_REG_SERDESDIGITAL_MISC1, 0x6000},
+		{MDIO_WC_DEVAD, MDIO_WC_REG_TX_FIR_TAP, 0x0000},
+		{MDIO_WC_DEVAD, MDIO_WC_REG_IEEE0BLK_MIICNTL, 0x2040},
+		{MDIO_WC_DEVAD, MDIO_WC_REG_COMBO_IEEE0_MIICTRL, 0x0140}
+	};
 	/* Set XFI clock comp as default. */
-	bnx2x_cl45_read(bp, phy, MDIO_WC_DEVAD,
-			MDIO_WC_REG_RX66_CONTROL, &val16);
-	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
-			 MDIO_WC_REG_RX66_CONTROL, val16 | (3<<13));
+	bnx2x_cl45_read_or_write(bp, phy, MDIO_WC_DEVAD,
+				 MDIO_WC_REG_RX66_CONTROL, (3<<13));
+
+	for (i = 0; i < sizeof(wc_regs)/sizeof(struct bnx2x_reg_set); i++)
+		bnx2x_cl45_write(bp, phy, wc_regs[i].devad, wc_regs[i].reg,
+				 wc_regs[i].val);
 
-	bnx2x_warpcore_reset_lane(bp, phy, 1);
-	bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD, MDIO_AN_REG_CTRL, 0);
-	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
-			 MDIO_WC_REG_FX100_CTRL1, 0x014a);
-	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
-			 MDIO_WC_REG_FX100_CTRL3, 0x0800);
-	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
-			 MDIO_WC_REG_DIGITAL4_MISC3, 0x8008);
-	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
-			 MDIO_WC_REG_SERDESDIGITAL_CONTROL1000X1, 0x0195);
-	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
-			 MDIO_WC_REG_SERDESDIGITAL_CONTROL1000X2, 0x0007);
-	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
-			 MDIO_WC_REG_SERDESDIGITAL_CONTROL1000X3, 0x0002);
-	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
-			 MDIO_WC_REG_SERDESDIGITAL_MISC1, 0x6000);
 	lane = bnx2x_get_warpcore_lane(phy, params);
 	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
-			 MDIO_WC_REG_TX_FIR_TAP, 0x0000);
-	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
 			 MDIO_WC_REG_TX0_TX_DRIVER + 0x10*lane, 0x0990);
-	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
-			 MDIO_WC_REG_IEEE0BLK_MIICNTL, 0x2040);
-	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
-			 MDIO_WC_REG_COMBO_IEEE0_MIICTRL, 0x0140);
-	bnx2x_warpcore_reset_lane(bp, phy, 0);
+
 }
 
 static int bnx2x_get_mod_abs_int_cfg(struct bnx2x *bp,
@@ -4606,12 +4563,9 @@ static void bnx2x_set_warpcore_loopback(struct bnx2x_phy *phy,
 		CL22_WR_OVER_CL45(bp, phy, MDIO_REG_BANK_AER_BLOCK,
 				  MDIO_AER_BLOCK_AER_REG, 0);
 		/* Enable 1G MDIO (1-copy) */
-		bnx2x_cl45_read(bp, phy, MDIO_WC_DEVAD,
-				MDIO_WC_REG_XGXSBLK0_XGXSCONTROL,
-				&val16);
-		bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
-				MDIO_WC_REG_XGXSBLK0_XGXSCONTROL,
-				val16 | 0x10);
+		bnx2x_cl45_read_or_write(bp, phy, MDIO_WC_DEVAD,
+					 MDIO_WC_REG_XGXSBLK0_XGXSCONTROL,
+					 0x10);
 		/* Set 1G loopback based on lane (1-copy) */
 		lane = bnx2x_get_warpcore_lane(phy, params);
 		bnx2x_cl45_read(bp, phy, MDIO_WC_DEVAD,
@@ -4624,16 +4578,12 @@ static void bnx2x_set_warpcore_loopback(struct bnx2x_phy *phy,
 		bnx2x_set_aer_mmd(params, phy);
 	} else {
 		/* 10G & 20G */
-		bnx2x_cl45_read(bp, phy, MDIO_WC_DEVAD,
-				MDIO_WC_REG_COMBO_IEEE0_MIICTRL, &val16);
-		bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
-				MDIO_WC_REG_COMBO_IEEE0_MIICTRL, val16 |
-				 0x4000);
+		bnx2x_cl45_read_or_write(bp, phy, MDIO_WC_DEVAD,
+					 MDIO_WC_REG_COMBO_IEEE0_MIICTRL,
+					 0x4000);
 
-		bnx2x_cl45_read(bp, phy, MDIO_WC_DEVAD,
-				MDIO_WC_REG_IEEE0BLK_MIICNTL, &val16);
-		bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
-				MDIO_WC_REG_IEEE0BLK_MIICNTL, val16 | 0x1);
+		bnx2x_cl45_read_or_write(bp, phy, MDIO_WC_DEVAD,
+					 MDIO_WC_REG_IEEE0BLK_MIICNTL, 0x1);
 	}
 }
 
@@ -10820,7 +10770,7 @@ static u8 bnx2x_54618se_read_status(struct bnx2x_phy *phy,
 
 	/* Get speed operation status */
 	bnx2x_cl22_read(bp, phy,
-			0x19,
+			MDIO_REG_GPHY_AUX_STATUS,
 			&legacy_status);
 	DP(NETIF_MSG_LINK, "54618SE read_status: 0x%x\n", legacy_status);
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
index cd1f271..7b6051b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
@@ -125,6 +125,11 @@ typedef void (*set_link_led_t)(struct bnx2x_phy *phy,
 			       struct link_params *params, u8 mode);
 typedef void (*phy_specific_func_t)(struct bnx2x_phy *phy,
 				    struct link_params *params, u32 action);
+struct bnx2x_reg_set {
+	u8  devad;
+	u16 reg;
+	u16 val;
+};
 
 struct bnx2x_phy {
 	u32 type;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
index a78e356..f371e3c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
@@ -7160,6 +7160,7 @@ Theotherbitsarereservedandshouldbezero*/
 #define MDIO_REG_GPHY_EEE_1G		(0x1 << 2)
 #define MDIO_REG_GPHY_EEE_100		(0x1 << 1)
 #define MDIO_REG_GPHY_EEE_RESOLVED		0x803e
+#define MDIO_REG_GPHY_AUX_STATUS			0x19
 #define MDIO_REG_INTR_STATUS				0x1a
 #define MDIO_REG_INTR_MASK				0x1b
 #define MDIO_REG_INTR_MASK_LINK_STATUS			(0x1 << 1)
-- 
1.7.9.rc2
