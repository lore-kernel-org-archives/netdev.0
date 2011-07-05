From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net-next 7/8] bnx2x: Add autogrEEEn support
Date: Tue, 5 Jul 2011 14:07:05 +0300
Message-ID: <1309864025.4050.86.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2049 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932066Ab1GELHS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jul 2011 07:07:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add autogrEEEn support on BCM84833 and 54618se, which allows to reduce power consumption.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_link.c |  115 +++++++++++++++++++++++++++++++++++----
 drivers/net/bnx2x/bnx2x_link.h |    1 +
 drivers/net/bnx2x/bnx2x_reg.h  |    7 +++
 3 files changed, 111 insertions(+), 12 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index d6684b3..03a2085 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -9437,6 +9437,7 @@ static int bnx2x_84833_common_init_phy(struct bnx2x *bp,
 	return 0;
 }
 
+#define PHY84833_CONSTANT_LATENCY 1193
 static int bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 				   struct link_params *params,
 				   struct link_vars *vars)
@@ -9445,7 +9446,7 @@ static int bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 	u8 port, initialize = 1;
 	u16 val;
 	u16 temp;
-	u32 actual_phy_selection, cms_enable;
+	u32 actual_phy_selection, cms_enable, idx;
 	int rc = 0;
 
 	msleep(1);
@@ -9537,24 +9538,86 @@ static int bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 	DP(NETIF_MSG_LINK, "Multi_phy config = 0x%x, Media control = 0x%x\n",
 		   params->multi_phy_config, val);
 
+	/* AutogrEEEn */
+	if (params->feature_config_flags &
+		FEATURE_CONFIG_AUTOGREEEN_ENABLED) {
+		/* Ensure that f/w is ready */
+		for (idx = 0; idx < PHY84833_HDSHK_WAIT; idx++) {
+			bnx2x_cl45_read(bp, phy, MDIO_CTL_DEVAD,
+					MDIO_84833_TOP_CFG_SCRATCH_REG2, &val);
+			if (val == PHY84833_CMD_OPEN_FOR_CMDS)
+				break;
+			usleep_range(1000, 1000);
+		}
+		if (idx >= PHY84833_HDSHK_WAIT) {
+			DP(NETIF_MSG_LINK, "AutogrEEEn: FW not ready.\n");
+			return -EINVAL;
+		}
+
+		/* Select EEE mode */
+		bnx2x_cl45_write(bp, phy, MDIO_CTL_DEVAD,
+				MDIO_84833_TOP_CFG_SCRATCH_REG3,
+				0x2);
+
+		/* Set Idle and Latency */
+		bnx2x_cl45_write(bp, phy, MDIO_CTL_DEVAD,
+				MDIO_84833_TOP_CFG_SCRATCH_REG4,
+				PHY84833_CONSTANT_LATENCY + 1);
+
+		bnx2x_cl45_write(bp, phy, MDIO_CTL_DEVAD,
+				MDIO_84833_TOP_CFG_DATA3_REG,
+				PHY84833_CONSTANT_LATENCY + 1);
+
+		bnx2x_cl45_write(bp, phy, MDIO_CTL_DEVAD,
+				MDIO_84833_TOP_CFG_DATA4_REG,
+				PHY84833_CONSTANT_LATENCY);
+
+		/* Send EEE instruction to command register */
+		bnx2x_cl45_write(bp, phy, MDIO_CTL_DEVAD,
+				MDIO_84833_TOP_CFG_SCRATCH_REG0,
+				PHY84833_DIAG_CMD_SET_EEE_MODE);
+
+		/* Ensure that the command has completed */
+		for (idx = 0; idx < PHY84833_HDSHK_WAIT; idx++) {
+			bnx2x_cl45_read(bp, phy, MDIO_CTL_DEVAD,
+					MDIO_84833_TOP_CFG_SCRATCH_REG2, &val);
+			if ((val == PHY84833_CMD_COMPLETE_PASS) ||
+				(val == PHY84833_CMD_COMPLETE_ERROR))
+				break;
+			usleep_range(1000, 1000);
+		}
+		if ((idx >= PHY84833_HDSHK_WAIT) ||
+			(val == PHY84833_CMD_COMPLETE_ERROR)) {
+			DP(NETIF_MSG_LINK, "AutogrEEEn: command failed.\n");
+			return -EINVAL;
+		}
+
+		/* Reset command handler */
+		bnx2x_cl45_write(bp, phy, MDIO_CTL_DEVAD,
+			    MDIO_84833_TOP_CFG_SCRATCH_REG2,
+			    PHY84833_CMD_CLEAR_COMPLETE);
+	}
+
 	if (initialize)
 		rc = bnx2x_848xx_cmn_config_init(phy, params, vars);
 	else
 		bnx2x_save_848xx_spirom_version(phy, params);
-	cms_enable = REG_RD(bp, params->shmem_base +
+	/* 84833 PHY has a better feature and doesn't need to support this. */
+	if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84823) {
+		cms_enable = REG_RD(bp, params->shmem_base +
 			offsetof(struct shmem_region,
 			dev_info.port_hw_config[params->port].default_cfg)) &
 			PORT_HW_CFG_ENABLE_CMS_MASK;
 
-	bnx2x_cl45_read(bp, phy, MDIO_CTL_DEVAD,
-		MDIO_CTL_REG_84823_USER_CTRL_REG, &val);
-	if (cms_enable)
-		val |= MDIO_CTL_REG_84823_USER_CTRL_CMS;
-	else
-		val &= ~MDIO_CTL_REG_84823_USER_CTRL_CMS;
-	bnx2x_cl45_write(bp, phy, MDIO_CTL_DEVAD,
-		MDIO_CTL_REG_84823_USER_CTRL_REG, val);
-
+		bnx2x_cl45_read(bp, phy, MDIO_CTL_DEVAD,
+				MDIO_CTL_REG_84823_USER_CTRL_REG, &val);
+		if (cms_enable)
+			val |= MDIO_CTL_REG_84823_USER_CTRL_CMS;
+		else
+			val &= ~MDIO_CTL_REG_84823_USER_CTRL_CMS;
+		bnx2x_cl45_write(bp, phy, MDIO_CTL_DEVAD,
+				 MDIO_CTL_REG_84823_USER_CTRL_REG, val);
+	}
 
 	return rc;
 }
@@ -10068,6 +10131,30 @@ static int bnx2x_54618se_config_init(struct bnx2x_phy *phy,
 		DP(NETIF_MSG_LINK, "Setting 10M force\n");
 	}
 
+	/* Check if we should turn on Auto-GrEEEn */
+	bnx2x_cl22_read(bp, phy, MDIO_REG_GPHY_PHYID_LSB, &temp);
+	if (temp == MDIO_REG_GPHY_ID_54618SE) {
+		if (params->feature_config_flags &
+		    FEATURE_CONFIG_AUTOGREEEN_ENABLED) {
+			temp = 6;
+			DP(NETIF_MSG_LINK, "Enabling Auto-GrEEEn\n");
+		} else {
+			temp = 0;
+			DP(NETIF_MSG_LINK, "Disabling Auto-GrEEEn\n");
+		}
+		bnx2x_cl22_write(bp, phy,
+				 MDIO_REG_GPHY_CL45_ADDR_REG, MDIO_AN_DEVAD);
+		bnx2x_cl22_write(bp, phy,
+				 MDIO_REG_GPHY_CL45_DATA_REG,
+				 MDIO_REG_GPHY_EEE_ADV);
+		bnx2x_cl22_write(bp, phy,
+				 MDIO_REG_GPHY_CL45_ADDR_REG,
+				 (0x1 << 14) | MDIO_AN_DEVAD);
+		bnx2x_cl22_write(bp, phy,
+				 MDIO_REG_GPHY_CL45_DATA_REG,
+				 temp);
+	}
+
 	bnx2x_cl22_write(bp, phy,
 			0x04,
 			an_10_100_val | fc_val);
@@ -11597,12 +11684,16 @@ int bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
 	bnx2x_set_led(params, vars, LED_MODE_OFF, 0);
 
 	if (reset_ext_phy) {
+		bnx2x_set_mdio_clk(bp, params->chip_id, port);
 		for (phy_index = EXT_PHY1; phy_index < params->num_phys;
 		      phy_index++) {
-			if (params->phy[phy_index].link_reset)
+			if (params->phy[phy_index].link_reset) {
+				bnx2x_set_aer_mmd(params,
+						  &params->phy[phy_index]);
 				params->phy[phy_index].link_reset(
 					&params->phy[phy_index],
 					params);
+			}
 			if (params->phy[phy_index].flags &
 			    FLAGS_REARM_LATCH_SIGNAL)
 				clear_latch_ind = 1;
diff --git a/drivers/net/bnx2x/bnx2x_link.h b/drivers/net/bnx2x/bnx2x_link.h
index ba4d1f7..6a7708d 100644
--- a/drivers/net/bnx2x/bnx2x_link.h
+++ b/drivers/net/bnx2x/bnx2x_link.h
@@ -250,6 +250,7 @@ struct link_params {
 #define FEATURE_CONFIG_PFC_ENABLED			(1<<1)
 #define FEATURE_CONFIG_BC_SUPPORTS_OPT_MDL_VRFY		(1<<2)
 #define FEATURE_CONFIG_BC_SUPPORTS_DUAL_PHY_OPT_MDL_VRFY	(1<<3)
+#define FEATURE_CONFIG_AUTOGREEEN_ENABLED			(1<<9)
 #define FEATURE_CONFIG_BC_SUPPORTS_SFP_TX_DISABLED		(1<<10)
 	/* Will be populated during common init */
 	struct bnx2x_phy phy[MAX_PHYS];
diff --git a/drivers/net/bnx2x/bnx2x_reg.h b/drivers/net/bnx2x/bnx2x_reg.h
index 3c7702e..005c05a 100644
--- a/drivers/net/bnx2x/bnx2x_reg.h
+++ b/drivers/net/bnx2x/bnx2x_reg.h
@@ -6792,6 +6792,8 @@ Theotherbitsarereservedandshouldbezero*/
 #define MDIO_84833_TOP_CFG_SCRATCH_REG2			0x4007
 #define MDIO_84833_TOP_CFG_SCRATCH_REG3			0x4008
 #define MDIO_84833_TOP_CFG_SCRATCH_REG4			0x4009
+#define MDIO_84833_TOP_CFG_DATA3_REG			0x4011
+#define MDIO_84833_TOP_CFG_DATA4_REG			0x4012
 
 /* Mailbox command set used by 84833. */
 #define PHY84833_DIAG_CMD_PAIR_SWAP_CHANGE		0x2
@@ -6806,6 +6808,11 @@ Theotherbitsarereservedandshouldbezero*/
 #define PHY84833_CMD_CLEAR_COMPLETE			0x0080
 #define PHY84833_CMD_OPEN_OVERRIDE			0xa5a5
 
+
+/* 84833 F/W Feature Commands */
+#define PHY84833_DIAG_CMD_GET_EEE_MODE			0x27
+#define PHY84833_DIAG_CMD_SET_EEE_MODE			0x28
+
 /* Warpcore clause 45 addressing */
 #define MDIO_WC_DEVAD					0x3
 #define MDIO_WC_REG_IEEE0BLK_MIICNTL			0x0
-- 
1.7.1







