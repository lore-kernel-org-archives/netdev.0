From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net-next 4/8] bnx2x: Fix BCM84833 link and LED behavior
Date: Sun, 27 Nov 2011 20:17:57 +0200
Message-ID: <1322417881-17760-5-git-send-email-yanivr@broadcom.com>
References: <1322417881-17760-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3769 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755783Ab1K0QTA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Nov 2011 11:19:00 -0500
In-Reply-To: <1322417881-17760-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch contain several fixes for the BCM84833. This PHY is still not in bnx2x production, hence this patch can be considered as enhancement.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |  350 ++++++++++++----------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h  |   53 ++--
 2 files changed, 221 insertions(+), 182 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 91c0170..e821c4a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -4055,13 +4055,11 @@ static void bnx2x_warpcore_set_20G_DXGXS(struct bnx2x *bp,
 
 static void bnx2x_warpcore_set_sgmii_speed(struct bnx2x_phy *phy,
 					   struct link_params *params,
-					   u8 fiber_mode)
+					   u8 fiber_mode,
+					   u8 always_autoneg)
 {
 	struct bnx2x *bp = params->bp;
 	u16 val16, digctrl_kx1, digctrl_kx2;
-	u8 lane;
-
-	lane = bnx2x_get_warpcore_lane(phy, params);
 
 	/* Clear XFI clock comp in non-10G single lane mode. */
 	bnx2x_cl45_read(bp, phy, MDIO_WC_DEVAD,
@@ -4069,7 +4067,7 @@ static void bnx2x_warpcore_set_sgmii_speed(struct bnx2x_phy *phy,
 	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
 			 MDIO_WC_REG_RX66_CONTROL, val16 & ~(3<<13));
 
-	if (phy->req_line_speed == SPEED_AUTO_NEG) {
+	if (always_autoneg || phy->req_line_speed == SPEED_AUTO_NEG) {
 		/* SGMII Autoneg */
 		bnx2x_cl45_read(bp, phy, MDIO_WC_DEVAD,
 				MDIO_WC_REG_COMBO_IEEE0_MIICTRL, &val16);
@@ -4080,7 +4078,7 @@ static void bnx2x_warpcore_set_sgmii_speed(struct bnx2x_phy *phy,
 	} else {
 		bnx2x_cl45_read(bp, phy, MDIO_WC_DEVAD,
 				MDIO_WC_REG_COMBO_IEEE0_MIICTRL, &val16);
-		val16 &= 0xcfbf;
+		val16 &= 0xcebf;
 		switch (phy->req_line_speed) {
 		case SPEED_10:
 			break;
@@ -4363,7 +4361,7 @@ static void bnx2x_warpcore_config_init(struct bnx2x_phy *phy,
 		vars->phy_flags |= PHY_SGMII_FLAG;
 		DP(NETIF_MSG_LINK, "Setting SGMII mode\n");
 		bnx2x_warpcore_clear_regs(phy, params, lane);
-		bnx2x_warpcore_set_sgmii_speed(phy, params, 0);
+		bnx2x_warpcore_set_sgmii_speed(phy, params, 0, 1);
 	} else {
 		switch (serdes_net_if) {
 		case PORT_HW_CFG_NET_SERDES_IF_KR:
@@ -4391,7 +4389,8 @@ static void bnx2x_warpcore_config_init(struct bnx2x_phy *phy,
 				}
 				bnx2x_warpcore_set_sgmii_speed(phy,
 								params,
-								fiber_mode);
+								fiber_mode,
+								0);
 			}
 
 			break;
@@ -4404,7 +4403,8 @@ static void bnx2x_warpcore_config_init(struct bnx2x_phy *phy,
 				bnx2x_warpcore_set_10G_XFI(phy, params, 0);
 			} else if (vars->line_speed == SPEED_1000) {
 				DP(NETIF_MSG_LINK, "Setting 1G Fiber\n");
-				bnx2x_warpcore_set_sgmii_speed(phy, params, 1);
+				bnx2x_warpcore_set_sgmii_speed(
+						phy, params, 1, 0);
 			}
 			/* Issue Module detection */
 			if (bnx2x_is_sfp_module_plugged(phy, params))
@@ -4541,12 +4541,6 @@ static void bnx2x_set_warpcore_loopback(struct bnx2x_phy *phy,
 
 		/* Switch back to 4-copy registers */
 		bnx2x_set_aer_mmd(params, phy);
-		/* Global loopback, not recommended. */
-		bnx2x_cl45_read(bp, phy, MDIO_WC_DEVAD,
-				MDIO_WC_REG_COMBO_IEEE0_MIICTRL, &val16);
-		bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
-				MDIO_WC_REG_COMBO_IEEE0_MIICTRL, val16 |
-				0x4000);
 	} else {
 		/* 10G & 20G */
 		bnx2x_cl45_read(bp, phy, MDIO_WC_DEVAD,
@@ -9349,7 +9343,7 @@ static void bnx2x_save_848xx_spirom_version(struct bnx2x_phy *phy,
 static void bnx2x_848xx_set_led(struct bnx2x *bp,
 				struct bnx2x_phy *phy)
 {
-	u16 val;
+	u16 val, offset;
 
 	/* PHYC_CTL_LED_CTL */
 	bnx2x_cl45_read(bp, phy,
@@ -9384,14 +9378,22 @@ static void bnx2x_848xx_set_led(struct bnx2x *bp,
 			MDIO_PMA_REG_8481_LED3_BLINK,
 			0);
 
-	bnx2x_cl45_read(bp, phy,
+	/* Configure the blink rate to ~15.9 Hz */
+	bnx2x_cl45_write(bp, phy,
 			MDIO_PMA_DEVAD,
-			MDIO_PMA_REG_84823_CTL_LED_CTL_1, &val);
-	val |= MDIO_PMA_REG_84823_LED3_STRETCH_EN; /* stretch_en for LED3*/
+			MDIO_PMA_REG_84823_CTL_SLOW_CLK_CNT_HIGH,
+			MDIO_PMA_REG_84823_BLINK_RATE_VAL_15P9HZ);
 
+	if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833)
+		offset = MDIO_PMA_REG_84833_CTL_LED_CTL_1;
+	else
+		offset = MDIO_PMA_REG_84823_CTL_LED_CTL_1;
+
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, offset, &val);
+	val |= MDIO_PMA_REG_84823_LED3_STRETCH_EN; /* stretch_en for LED3*/
 	bnx2x_cl45_write(bp, phy,
-			 MDIO_PMA_DEVAD,
-			 MDIO_PMA_REG_84823_CTL_LED_CTL_1, val);
+			 MDIO_PMA_DEVAD, offset, val);
 
 	/* 'Interrupt Mask' */
 	bnx2x_cl45_write(bp, phy,
@@ -9404,7 +9406,7 @@ static int bnx2x_848xx_cmn_config_init(struct bnx2x_phy *phy,
 				       struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
-	u16 autoneg_val, an_1000_val, an_10_100_val;
+	u16 autoneg_val, an_1000_val, an_10_100_val, an_10g_val;
 	u16 tmp_req_line_speed;
 
 	tmp_req_line_speed = phy->req_line_speed;
@@ -9499,6 +9501,8 @@ static int bnx2x_848xx_cmn_config_init(struct bnx2x_phy *phy,
 		bnx2x_cl45_write(bp, phy,
 				 MDIO_AN_DEVAD, MDIO_AN_REG_8481_AUX_CTRL,
 				 (1<<15 | 1<<9 | 7<<0));
+		/* The PHY needs this set even for forced link. */
+		an_10_100_val |= (1<<8) | (1<<7);
 		DP(NETIF_MSG_LINK, "Setting 100M force\n");
 	}
 	if ((phy->req_line_speed == SPEED_10) &&
@@ -9536,6 +9540,14 @@ static int bnx2x_848xx_cmn_config_init(struct bnx2x_phy *phy,
 			DP(NETIF_MSG_LINK, "Advertising 10G\n");
 			/* Restart autoneg for 10G*/
 
+			bnx2x_cl45_read(bp, phy,
+				MDIO_AN_DEVAD,
+				MDIO_AN_REG_8481_10GBASE_T_AN_CTRL,
+				&an_10g_val);
+			bnx2x_cl45_write(bp, phy,
+				MDIO_AN_DEVAD,
+				MDIO_AN_REG_8481_10GBASE_T_AN_CTRL,
+				an_10g_val | 0x1000);
 			bnx2x_cl45_write(bp, phy,
 				 MDIO_AN_DEVAD, MDIO_AN_REG_CTRL,
 				 0x3200);
@@ -9570,74 +9582,95 @@ static int bnx2x_8481_config_init(struct bnx2x_phy *phy,
 	return bnx2x_848xx_cmn_config_init(phy, params, vars);
 }
 
-
-#define PHY84833_HDSHK_WAIT 300
-static int bnx2x_84833_pair_swap_cfg(struct bnx2x_phy *phy,
+#define PHY84833_CMDHDLR_WAIT 300
+#define PHY84833_CMDHDLR_MAX_ARGS 5
+static int bnx2x_84833_cmd_hdlr(struct bnx2x_phy *phy,
 				   struct link_params *params,
-				   struct link_vars *vars)
+		   u16 fw_cmd,
+		   u16 cmd_args[])
 {
 	u32 idx;
-	u32 pair_swap;
 	u16 val;
-	u16 data;
 	struct bnx2x *bp = params->bp;
-	/* Do pair swap */
-
-	/* Check for configuration. */
-	pair_swap = REG_RD(bp, params->shmem_base +
-			   offsetof(struct shmem_region,
-			dev_info.port_hw_config[params->port].xgbt_phy_cfg)) &
-		PORT_HW_CFG_RJ45_PAIR_SWAP_MASK;
-
-	if (pair_swap == 0)
-		return 0;
-
-	data = (u16)pair_swap;
-
 	/* Write CMD_OPEN_OVERRIDE to STATUS reg */
 	bnx2x_cl45_write(bp, phy, MDIO_CTL_DEVAD,
-			MDIO_84833_TOP_CFG_SCRATCH_REG2,
-			PHY84833_CMD_OPEN_OVERRIDE);
-	for (idx = 0; idx < PHY84833_HDSHK_WAIT; idx++) {
+			MDIO_84833_CMD_HDLR_STATUS,
+			PHY84833_STATUS_CMD_OPEN_OVERRIDE);
+	for (idx = 0; idx < PHY84833_CMDHDLR_WAIT; idx++) {
 		bnx2x_cl45_read(bp, phy, MDIO_CTL_DEVAD,
-				MDIO_84833_TOP_CFG_SCRATCH_REG2, &val);
-		if (val == PHY84833_CMD_OPEN_FOR_CMDS)
+				MDIO_84833_CMD_HDLR_STATUS, &val);
+		if (val == PHY84833_STATUS_CMD_OPEN_FOR_CMDS)
 			break;
 		msleep(1);
 	}
-	if (idx >= PHY84833_HDSHK_WAIT) {
-		DP(NETIF_MSG_LINK, "Pairswap: FW not ready.\n");
+	if (idx >= PHY84833_CMDHDLR_WAIT) {
+		DP(NETIF_MSG_LINK, "FW cmd: FW not ready.\n");
 		return -EINVAL;
 	}
 
+	/* Prepare argument(s) and issue command */
+	for (idx = 0; idx < PHY84833_CMDHDLR_MAX_ARGS; idx++) {
+		bnx2x_cl45_write(bp, phy, MDIO_CTL_DEVAD,
+				MDIO_84833_CMD_HDLR_DATA1 + idx,
+				cmd_args[idx]);
+	}
 	bnx2x_cl45_write(bp, phy, MDIO_CTL_DEVAD,
-			MDIO_84833_TOP_CFG_SCRATCH_REG4,
-			data);
-	/* Issue pair swap command */
-	bnx2x_cl45_write(bp, phy, MDIO_CTL_DEVAD,
-			MDIO_84833_TOP_CFG_SCRATCH_REG0,
-			PHY84833_DIAG_CMD_PAIR_SWAP_CHANGE);
-	for (idx = 0; idx < PHY84833_HDSHK_WAIT; idx++) {
+			MDIO_84833_CMD_HDLR_COMMAND, fw_cmd);
+	for (idx = 0; idx < PHY84833_CMDHDLR_WAIT; idx++) {
 		bnx2x_cl45_read(bp, phy, MDIO_CTL_DEVAD,
-				MDIO_84833_TOP_CFG_SCRATCH_REG2, &val);
-		if ((val == PHY84833_CMD_COMPLETE_PASS) ||
-			(val == PHY84833_CMD_COMPLETE_ERROR))
+				MDIO_84833_CMD_HDLR_STATUS, &val);
+		if ((val == PHY84833_STATUS_CMD_COMPLETE_PASS) ||
+			(val == PHY84833_STATUS_CMD_COMPLETE_ERROR))
 			break;
 		msleep(1);
 	}
-	if ((idx >= PHY84833_HDSHK_WAIT) ||
-		(val == PHY84833_CMD_COMPLETE_ERROR)) {
-		DP(NETIF_MSG_LINK, "Pairswap: override failed.\n");
+	if ((idx >= PHY84833_CMDHDLR_WAIT) ||
+		(val == PHY84833_STATUS_CMD_COMPLETE_ERROR)) {
+		DP(NETIF_MSG_LINK, "FW cmd failed.\n");
 		return -EINVAL;
 	}
+	/* Gather returning data */
+	for (idx = 0; idx < PHY84833_CMDHDLR_MAX_ARGS; idx++) {
+		bnx2x_cl45_read(bp, phy, MDIO_CTL_DEVAD,
+				MDIO_84833_CMD_HDLR_DATA1 + idx,
+				&cmd_args[idx]);
+	}
 	bnx2x_cl45_write(bp, phy, MDIO_CTL_DEVAD,
-			MDIO_84833_TOP_CFG_SCRATCH_REG2,
-			PHY84833_CMD_CLEAR_COMPLETE);
-	DP(NETIF_MSG_LINK, "Pairswap OK, val=0x%x\n", data);
+			MDIO_84833_CMD_HDLR_STATUS,
+			PHY84833_STATUS_CMD_CLEAR_COMPLETE);
 	return 0;
 }
 
 
+static int bnx2x_84833_pair_swap_cfg(struct bnx2x_phy *phy,
+				   struct link_params *params,
+				   struct link_vars *vars)
+{
+	u32 pair_swap;
+	u16 data[PHY84833_CMDHDLR_MAX_ARGS];
+	int status;
+	struct bnx2x *bp = params->bp;
+
+	/* Check for configuration. */
+	pair_swap = REG_RD(bp, params->shmem_base +
+			   offsetof(struct shmem_region,
+			dev_info.port_hw_config[params->port].xgbt_phy_cfg)) &
+		PORT_HW_CFG_RJ45_PAIR_SWAP_MASK;
+
+	if (pair_swap == 0)
+		return 0;
+
+	/* Only the second argument is used for this command */
+	data[1] = (u16)pair_swap;
+
+	status = bnx2x_84833_cmd_hdlr(phy, params,
+		PHY84833_CMD_SET_PAIR_SWAP, data);
+	if (status == 0)
+		DP(NETIF_MSG_LINK, "Pairswap OK, val=0x%x\n", data[1]);
+
+	return status;
+}
+
 static u8 bnx2x_84833_get_reset_gpios(struct bnx2x *bp,
 				      u32 shmem_base_path[],
 				      u32 chip_id)
@@ -9700,24 +9733,6 @@ static int bnx2x_84833_hw_reset_phy(struct bnx2x_phy *phy,
 	return 0;
 }
 
-static int bnx2x_84833_common_init_phy(struct bnx2x *bp,
-						u32 shmem_base_path[],
-						u32 chip_id)
-{
-	u8 reset_gpios;
-
-	reset_gpios = bnx2x_84833_get_reset_gpios(bp, shmem_base_path, chip_id);
-
-	bnx2x_set_mult_gpio(bp, reset_gpios, MISC_REGISTERS_GPIO_OUTPUT_LOW);
-	udelay(10);
-	bnx2x_set_mult_gpio(bp, reset_gpios, MISC_REGISTERS_GPIO_OUTPUT_HIGH);
-	msleep(800);
-	DP(NETIF_MSG_LINK, "84833 reset pulse on pin values 0x%x\n",
-		reset_gpios);
-
-	return 0;
-}
-
 #define PHY84833_CONSTANT_LATENCY 1193
 static int bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 				   struct link_params *params,
@@ -9726,8 +9741,8 @@ static int bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 	struct bnx2x *bp = params->bp;
 	u8 port, initialize = 1;
 	u16 val;
-	u16 temp;
-	u32 actual_phy_selection, cms_enable, idx;
+	u32 actual_phy_selection, cms_enable;
+	u16 cmd_args[PHY84833_CMDHDLR_MAX_ARGS];
 	int rc = 0;
 
 	msleep(1);
@@ -9746,6 +9761,13 @@ static int bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 		bnx2x_cl45_write(bp, phy,
 				MDIO_PMA_DEVAD,
 				MDIO_PMA_REG_CTRL, 0x8000);
+	}
+
+	bnx2x_wait_reset_complete(bp, phy, params);
+
+	/* Wait for GPHY to come out of reset */
+	msleep(50);
+	if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833) {
 		/* Bring PHY out of super isolate mode */
 		bnx2x_cl45_read(bp, phy,
 				MDIO_CTL_DEVAD,
@@ -9754,26 +9776,19 @@ static int bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 		bnx2x_cl45_write(bp, phy,
 				MDIO_CTL_DEVAD,
 				MDIO_84833_TOP_CFG_XGPHY_STRAP1, val);
-	}
-
-	bnx2x_wait_reset_complete(bp, phy, params);
-
-	/* Wait for GPHY to come out of reset */
-	msleep(50);
-
-	if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833)
 		bnx2x_84833_pair_swap_cfg(phy, params, vars);
-
-	/*
-	 * BCM84823 requires that XGXS links up first @ 10G for normal behavior
-	 */
-	temp = vars->line_speed;
-	vars->line_speed = SPEED_10000;
-	bnx2x_set_autoneg(&params->phy[INT_PHY], params, vars, 0);
-	bnx2x_program_serdes(&params->phy[INT_PHY], params, vars);
-	vars->line_speed = temp;
-
-	/* Set dual-media configuration according to configuration */
+	} else {
+		/*
+		 * BCM84823 requires that XGXS links up first @ 10G for normal
+		 * behavior.
+		 */
+		u16 temp;
+		temp = vars->line_speed;
+		vars->line_speed = SPEED_10000;
+		bnx2x_set_autoneg(&params->phy[INT_PHY], params, vars, 0);
+		bnx2x_program_serdes(&params->phy[INT_PHY], params, vars);
+		vars->line_speed = temp;
+	}
 
 	bnx2x_cl45_read(bp, phy, MDIO_CTL_DEVAD,
 			MDIO_CTL_REG_84823_MEDIA, &val);
@@ -9821,64 +9836,18 @@ static int bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 
 	/* AutogrEEEn */
 	if (params->feature_config_flags &
-		FEATURE_CONFIG_AUTOGREEEN_ENABLED) {
-		/* Ensure that f/w is ready */
-		for (idx = 0; idx < PHY84833_HDSHK_WAIT; idx++) {
-			bnx2x_cl45_read(bp, phy, MDIO_CTL_DEVAD,
-					MDIO_84833_TOP_CFG_SCRATCH_REG2, &val);
-			if (val == PHY84833_CMD_OPEN_FOR_CMDS)
-				break;
-			usleep_range(1000, 1000);
-		}
-		if (idx >= PHY84833_HDSHK_WAIT) {
-			DP(NETIF_MSG_LINK, "AutogrEEEn: FW not ready.\n");
-			return -EINVAL;
-		}
-
-		/* Select EEE mode */
-		bnx2x_cl45_write(bp, phy, MDIO_CTL_DEVAD,
-				MDIO_84833_TOP_CFG_SCRATCH_REG3,
-				0x2);
-
-		/* Set Idle and Latency */
-		bnx2x_cl45_write(bp, phy, MDIO_CTL_DEVAD,
-				MDIO_84833_TOP_CFG_SCRATCH_REG4,
-				PHY84833_CONSTANT_LATENCY + 1);
-
-		bnx2x_cl45_write(bp, phy, MDIO_CTL_DEVAD,
-				MDIO_84833_TOP_CFG_DATA3_REG,
-				PHY84833_CONSTANT_LATENCY + 1);
-
-		bnx2x_cl45_write(bp, phy, MDIO_CTL_DEVAD,
-				MDIO_84833_TOP_CFG_DATA4_REG,
-				PHY84833_CONSTANT_LATENCY);
-
-		/* Send EEE instruction to command register */
-		bnx2x_cl45_write(bp, phy, MDIO_CTL_DEVAD,
-				MDIO_84833_TOP_CFG_SCRATCH_REG0,
-				PHY84833_DIAG_CMD_SET_EEE_MODE);
-
-		/* Ensure that the command has completed */
-		for (idx = 0; idx < PHY84833_HDSHK_WAIT; idx++) {
-			bnx2x_cl45_read(bp, phy, MDIO_CTL_DEVAD,
-					MDIO_84833_TOP_CFG_SCRATCH_REG2, &val);
-			if ((val == PHY84833_CMD_COMPLETE_PASS) ||
-				(val == PHY84833_CMD_COMPLETE_ERROR))
-				break;
-			usleep_range(1000, 1000);
-		}
-		if ((idx >= PHY84833_HDSHK_WAIT) ||
-			(val == PHY84833_CMD_COMPLETE_ERROR)) {
-			DP(NETIF_MSG_LINK, "AutogrEEEn: command failed.\n");
-			return -EINVAL;
-		}
-
-		/* Reset command handler */
-		bnx2x_cl45_write(bp, phy, MDIO_CTL_DEVAD,
-			    MDIO_84833_TOP_CFG_SCRATCH_REG2,
-			    PHY84833_CMD_CLEAR_COMPLETE);
-	}
+		FEATURE_CONFIG_AUTOGREEEN_ENABLED)
+		cmd_args[0] = 0x2;
+	else
+		cmd_args[0] = 0x0;
 
+	cmd_args[1] = 0x0;
+	cmd_args[2] = PHY84833_CONSTANT_LATENCY + 1;
+	cmd_args[3] = PHY84833_CONSTANT_LATENCY;
+	rc = bnx2x_84833_cmd_hdlr(phy, params,
+		PHY84833_CMD_SET_EEE_MODE, cmd_args);
+	if (rc != 0)
+		DP(NETIF_MSG_LINK, "Cfg AutogrEEEn failed.\n");
 	if (initialize)
 		rc = bnx2x_848xx_cmn_config_init(phy, params, vars);
 	else
@@ -12368,6 +12337,63 @@ static int bnx2x_8727_common_init_phy(struct bnx2x *bp,
 	return 0;
 }
 
+static int bnx2x_84833_common_init_phy(struct bnx2x *bp,
+						u32 shmem_base_path[],
+						u32 shmem2_base_path[],
+						u8 phy_index,
+						u32 chip_id)
+{
+	u8 reset_gpios;
+	struct bnx2x_phy phy;
+	u32 shmem_base, shmem2_base, cnt;
+	s8 port = 0;
+	u16 val;
+
+	reset_gpios = bnx2x_84833_get_reset_gpios(bp, shmem_base_path, chip_id);
+	bnx2x_set_mult_gpio(bp, reset_gpios, MISC_REGISTERS_GPIO_OUTPUT_LOW);
+	udelay(10);
+	bnx2x_set_mult_gpio(bp, reset_gpios, MISC_REGISTERS_GPIO_OUTPUT_HIGH);
+	DP(NETIF_MSG_LINK, "84833 reset pulse on pin values 0x%x\n",
+		reset_gpios);
+	for (port = PORT_MAX - 1; port >= PORT_0; port--) {
+		/* This PHY is for E2 and E3. */
+		shmem_base = shmem_base_path[port];
+		shmem2_base = shmem2_base_path[port];
+		/* Extract the ext phy address for the port */
+		if (bnx2x_populate_phy(bp, phy_index, shmem_base, shmem2_base,
+				       0, &phy) !=
+		    0) {
+			DP(NETIF_MSG_LINK, "populate_phy failed\n");
+			return -EINVAL;
+		}
+
+		/* Wait for FW completing its initialization. */
+		for (cnt = 0; cnt < 1000; cnt++) {
+			bnx2x_cl45_read(bp, &phy,
+				MDIO_PMA_DEVAD,
+				MDIO_PMA_REG_CTRL, &val);
+			if (!(val & (1<<15)))
+				break;
+			msleep(1);
+		}
+		if (cnt >= 1000)
+			DP(NETIF_MSG_LINK,
+				"84833 Cmn reset timeout (%d)\n", port);
+
+		/* Put the port in super isolate mode. */
+		bnx2x_cl45_read(bp, &phy,
+				MDIO_CTL_DEVAD,
+				MDIO_84833_TOP_CFG_XGPHY_STRAP1, &val);
+		val |= MDIO_84833_SUPER_ISOLATE;
+		bnx2x_cl45_write(bp, &phy,
+				MDIO_CTL_DEVAD,
+				MDIO_84833_TOP_CFG_XGPHY_STRAP1, val);
+	}
+
+	return 0;
+}
+
+
 static int bnx2x_ext_phy_common_init(struct bnx2x *bp, u32 shmem_base_path[],
 				     u32 shmem2_base_path[], u8 phy_index,
 				     u32 ext_phy_type, u32 chip_id)
@@ -12402,7 +12428,9 @@ static int bnx2x_ext_phy_common_init(struct bnx2x *bp, u32 shmem_base_path[],
 		 * GPIO3's are linked, and so both need to be toggled
 		 * to obtain required 2us pulse.
 		 */
-		rc = bnx2x_84833_common_init_phy(bp, shmem_base_path, chip_id);
+		rc = bnx2x_84833_common_init_phy(bp, shmem_base_path,
+						shmem2_base_path,
+						phy_index, chip_id);
 		break;
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE:
 		rc = -EINVAL;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
index d5a0dde..44609de 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
@@ -6835,11 +6835,13 @@ Theotherbitsarereservedandshouldbezero*/
 #define MDIO_CTL_REG_84823_MEDIA_PRIORITY_COPPER	0x0000
 #define MDIO_CTL_REG_84823_MEDIA_PRIORITY_FIBER		0x0100
 #define MDIO_CTL_REG_84823_MEDIA_FIBER_1G			0x1000
-#define MDIO_CTL_REG_84823_USER_CTRL_REG		0x4005
-#define MDIO_CTL_REG_84823_USER_CTRL_CMS		0x0080
-
-#define MDIO_PMA_REG_84823_CTL_LED_CTL_1		0xa8e3
-#define MDIO_PMA_REG_84823_LED3_STRETCH_EN		0x0080
+#define MDIO_CTL_REG_84823_USER_CTRL_REG			0x4005
+#define MDIO_CTL_REG_84823_USER_CTRL_CMS			0x0080
+#define MDIO_PMA_REG_84823_CTL_SLOW_CLK_CNT_HIGH		0xa82b
+#define MDIO_PMA_REG_84823_BLINK_RATE_VAL_15P9HZ	0x2f
+#define MDIO_PMA_REG_84823_CTL_LED_CTL_1			0xa8e3
+#define MDIO_PMA_REG_84833_CTL_LED_CTL_1			0xa8ec
+#define MDIO_PMA_REG_84823_LED3_STRETCH_EN			0x0080
 
 /* BCM84833 only */
 #define MDIO_84833_TOP_CFG_XGPHY_STRAP1			0x401a
@@ -6850,26 +6852,35 @@ Theotherbitsarereservedandshouldbezero*/
 #define MDIO_84833_TOP_CFG_SCRATCH_REG2			0x4007
 #define MDIO_84833_TOP_CFG_SCRATCH_REG3			0x4008
 #define MDIO_84833_TOP_CFG_SCRATCH_REG4			0x4009
-#define MDIO_84833_TOP_CFG_DATA3_REG			0x4011
-#define MDIO_84833_TOP_CFG_DATA4_REG			0x4012
+#define MDIO_84833_TOP_CFG_SCRATCH_REG26		0x4037
+#define MDIO_84833_TOP_CFG_SCRATCH_REG27		0x4038
+#define MDIO_84833_TOP_CFG_SCRATCH_REG28		0x4039
+#define MDIO_84833_TOP_CFG_SCRATCH_REG29		0x403a
+#define MDIO_84833_TOP_CFG_SCRATCH_REG30		0x403b
+#define MDIO_84833_TOP_CFG_SCRATCH_REG31		0x403c
+#define MDIO_84833_CMD_HDLR_COMMAND	MDIO_84833_TOP_CFG_SCRATCH_REG0
+#define MDIO_84833_CMD_HDLR_STATUS	MDIO_84833_TOP_CFG_SCRATCH_REG26
+#define MDIO_84833_CMD_HDLR_DATA1	MDIO_84833_TOP_CFG_SCRATCH_REG27
+#define MDIO_84833_CMD_HDLR_DATA2	MDIO_84833_TOP_CFG_SCRATCH_REG28
+#define MDIO_84833_CMD_HDLR_DATA3	MDIO_84833_TOP_CFG_SCRATCH_REG29
+#define MDIO_84833_CMD_HDLR_DATA4	MDIO_84833_TOP_CFG_SCRATCH_REG30
+#define MDIO_84833_CMD_HDLR_DATA5	MDIO_84833_TOP_CFG_SCRATCH_REG31
 
 /* Mailbox command set used by 84833. */
-#define PHY84833_DIAG_CMD_PAIR_SWAP_CHANGE		0x2
+#define PHY84833_CMD_SET_PAIR_SWAP			0x8001
+#define PHY84833_CMD_GET_EEE_MODE			0x8008
+#define PHY84833_CMD_SET_EEE_MODE			0x8009
 /* Mailbox status set used by 84833. */
-#define PHY84833_CMD_RECEIVED				0x0001
-#define PHY84833_CMD_IN_PROGRESS			0x0002
-#define PHY84833_CMD_COMPLETE_PASS			0x0004
-#define PHY84833_CMD_COMPLETE_ERROR			0x0008
-#define PHY84833_CMD_OPEN_FOR_CMDS			0x0010
-#define PHY84833_CMD_SYSTEM_BOOT			0x0020
-#define PHY84833_CMD_NOT_OPEN_FOR_CMDS			0x0040
-#define PHY84833_CMD_CLEAR_COMPLETE			0x0080
-#define PHY84833_CMD_OPEN_OVERRIDE			0xa5a5
-
+#define PHY84833_STATUS_CMD_RECEIVED			0x0001
+#define PHY84833_STATUS_CMD_IN_PROGRESS			0x0002
+#define PHY84833_STATUS_CMD_COMPLETE_PASS		0x0004
+#define PHY84833_STATUS_CMD_COMPLETE_ERROR		0x0008
+#define PHY84833_STATUS_CMD_OPEN_FOR_CMDS		0x0010
+#define PHY84833_STATUS_CMD_SYSTEM_BOOT			0x0020
+#define PHY84833_STATUS_CMD_NOT_OPEN_FOR_CMDS		0x0040
+#define PHY84833_STATUS_CMD_CLEAR_COMPLETE		0x0080
+#define PHY84833_STATUS_CMD_OPEN_OVERRIDE		0xa5a5
 
-/* 84833 F/W Feature Commands */
-#define PHY84833_DIAG_CMD_GET_EEE_MODE			0x27
-#define PHY84833_DIAG_CMD_SET_EEE_MODE			0x28
 
 /* Warpcore clause 45 addressing */
 #define MDIO_WC_DEVAD					0x3
-- 
1.7.7.1
