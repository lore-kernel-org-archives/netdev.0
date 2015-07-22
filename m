From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 3/6] bnx2x: Add 84858 phy support
Date: Wed, 22 Jul 2015 09:16:24 +0300
Message-ID: <1437545787-22097-4-git-send-email-Yuval.Mintz@qlogic.com>
References: <1437545787-22097-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yaniv Rosner <Yaniv.Rosner@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:19242 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755388AbbGVGRH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 02:17:07 -0400
In-Reply-To: <1437545787-22097-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yaniv Rosner <Yaniv.Rosner@qlogic.com>

This adds support to a new copper phy.

Signed-off-by: Yaniv Rosner <Yaniv.Rosner@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h  |   3 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c | 244 ++++++++++++++++++-----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h  |  58 +++---
 3 files changed, 232 insertions(+), 73 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index a838b6e..5425de0 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -731,6 +731,7 @@ struct port_hw_cfg {		    /* port 0: 0x12c  port 1: 0x2bc */
 		#define PORT_HW_CFG_XGXS_EXT_PHY2_TYPE_BCM8722       0x00000f00
 		#define PORT_HW_CFG_XGXS_EXT_PHY2_TYPE_BCM54616      0x00001000
 		#define PORT_HW_CFG_XGXS_EXT_PHY2_TYPE_BCM84834      0x00001100
+		#define PORT_HW_CFG_XGXS_EXT_PHY2_TYPE_BCM84858      0x00001200
 		#define PORT_HW_CFG_XGXS_EXT_PHY2_TYPE_FAILURE       0x0000fd00
 		#define PORT_HW_CFG_XGXS_EXT_PHY2_TYPE_NOT_CONN      0x0000ff00
 
@@ -788,6 +789,7 @@ struct port_hw_cfg {		    /* port 0: 0x12c  port 1: 0x2bc */
 		#define PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8722        0x00000f00
 		#define PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM54616       0x00001000
 		#define PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84834       0x00001100
+		#define PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84858       0x00001200
 		#define PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT_WC      0x0000fc00
 		#define PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE        0x0000fd00
 		#define PORT_HW_CFG_XGXS_EXT_PHY_TYPE_NOT_CONN       0x0000ff00
@@ -2253,6 +2255,7 @@ struct shmem2_region {
 	u32 reserved4;				/* Offset 0x150 */
 	u32 link_attr_sync[PORT_MAX];		/* Offset 0x154 */
 	#define LINK_ATTR_SYNC_KR2_ENABLE	0x00000001
+	#define LINK_ATTR_84858			0x00000002
 	#define LINK_SFP_EEPROM_COMP_CODE_MASK	0x0000ff00
 	#define LINK_SFP_EEPROM_COMP_CODE_SHIFT		 8
 	#define LINK_SFP_EEPROM_COMP_CODE_SR	0x00001000
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 7f9ec51..d946bba 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -9654,6 +9654,13 @@ static void bnx2x_8727_link_reset(struct bnx2x_phy *phy,
 /******************************************************************/
 /*		BCM8481/BCM84823/BCM84833 PHY SECTION	          */
 /******************************************************************/
+static int bnx2x_is_8483x_8485x(struct bnx2x_phy *phy)
+{
+	return ((phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833) ||
+		(phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84834) ||
+		(phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84858));
+}
+
 static void bnx2x_save_848xx_spirom_version(struct bnx2x_phy *phy,
 					    struct bnx2x *bp,
 					    u8 port)
@@ -9668,8 +9675,7 @@ static void bnx2x_save_848xx_spirom_version(struct bnx2x_phy *phy,
 	};
 	u16 fw_ver1;
 
-	if ((phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833) ||
-	    (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84834)) {
+	if (bnx2x_is_8483x_8485x(phy)) {
 		bnx2x_cl45_read(bp, phy, MDIO_CTL_DEVAD, 0x400f, &fw_ver1);
 		bnx2x_save_spirom_version(bp, port, fw_ver1 & 0xfff,
 				phy->ver_addr);
@@ -9751,8 +9757,7 @@ static void bnx2x_848xx_set_led(struct bnx2x *bp,
 		bnx2x_cl45_write(bp, phy, reg_set[i].devad, reg_set[i].reg,
 				 reg_set[i].val);
 
-	if ((phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833) ||
-	    (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84834))
+	if (bnx2x_is_8483x_8485x(phy))
 		offset = MDIO_PMA_REG_84833_CTL_LED_CTL_1;
 	else
 		offset = MDIO_PMA_REG_84823_CTL_LED_CTL_1;
@@ -9770,8 +9775,7 @@ static void bnx2x_848xx_specific_func(struct bnx2x_phy *phy,
 	struct bnx2x *bp = params->bp;
 	switch (action) {
 	case PHY_INIT:
-		if ((phy->type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833) &&
-		    (phy->type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84834)) {
+		if (!bnx2x_is_8483x_8485x(phy)) {
 			/* Save spirom version */
 			bnx2x_save_848xx_spirom_version(phy, bp, params->port);
 		}
@@ -9903,8 +9907,7 @@ static int bnx2x_848xx_cmn_config_init(struct bnx2x_phy *phy,
 	/* Always write this if this is not 84833/4.
 	 * For 84833/4, write it only when it's a forced speed.
 	 */
-	if (((phy->type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833) &&
-	     (phy->type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84834)) ||
+	if (!bnx2x_is_8483x_8485x(phy) ||
 	    ((autoneg_val & (1<<12)) == 0))
 		bnx2x_cl45_write(bp, phy,
 			 MDIO_AN_DEVAD,
@@ -9951,8 +9954,86 @@ static int bnx2x_8481_config_init(struct bnx2x_phy *phy,
 	return bnx2x_848xx_cmn_config_init(phy, params, vars);
 }
 
-#define PHY84833_CMDHDLR_WAIT 300
-#define PHY84833_CMDHDLR_MAX_ARGS 5
+#define PHY848xx_CMDHDLR_WAIT 300
+#define PHY848xx_CMDHDLR_MAX_ARGS 5
+
+static int bnx2x_84858_cmd_hdlr(struct bnx2x_phy *phy,
+				struct link_params *params,
+				u16 fw_cmd,
+				u16 cmd_args[], int argc)
+{
+	int idx;
+	u16 val;
+	struct bnx2x *bp = params->bp;
+
+	/* Step 1: Poll the STATUS register to see whether the previous command
+	 * is in progress or the system is busy (CMD_IN_PROGRESS or
+	 * SYSTEM_BUSY). If previous command is in progress or system is busy,
+	 * check again until the previous command finishes execution and the
+	 * system is available for taking command
+	 */
+
+	for (idx = 0; idx < PHY848xx_CMDHDLR_WAIT; idx++) {
+		bnx2x_cl45_read(bp, phy, MDIO_CTL_DEVAD,
+				MDIO_848xx_CMD_HDLR_STATUS, &val);
+		if ((val != PHY84858_STATUS_CMD_IN_PROGRESS) &&
+		    (val != PHY84858_STATUS_CMD_SYSTEM_BUSY))
+			break;
+		usleep_range(1000, 2000);
+	}
+	if (idx >= PHY848xx_CMDHDLR_WAIT) {
+		DP(NETIF_MSG_LINK, "FW cmd: FW not ready.\n");
+		return -EINVAL;
+	}
+
+	/* Step2: If any parameters are required for the function, write them
+	 * to the required DATA registers
+	 */
+
+	for (idx = 0; idx < argc; idx++) {
+		bnx2x_cl45_write(bp, phy, MDIO_CTL_DEVAD,
+				 MDIO_848xx_CMD_HDLR_DATA1 + idx,
+				 cmd_args[idx]);
+	}
+
+	/* Step3: When the firmware is ready for commands, write the 'Command
+	 * code' to the CMD register
+	 */
+	bnx2x_cl45_write(bp, phy, MDIO_CTL_DEVAD,
+			 MDIO_848xx_CMD_HDLR_COMMAND, fw_cmd);
+
+	/* Step4: Once the command has been written, poll the STATUS register
+	 * to check whether the command has completed (CMD_COMPLETED_PASS/
+	 * CMD_FOR_CMDS or CMD_COMPLETED_ERROR).
+	 */
+
+	for (idx = 0; idx < PHY848xx_CMDHDLR_WAIT; idx++) {
+		bnx2x_cl45_read(bp, phy, MDIO_CTL_DEVAD,
+				MDIO_848xx_CMD_HDLR_STATUS, &val);
+		if ((val == PHY84858_STATUS_CMD_COMPLETE_PASS) ||
+		    (val == PHY84858_STATUS_CMD_COMPLETE_ERROR))
+			break;
+		usleep_range(1000, 2000);
+	}
+	if ((idx >= PHY848xx_CMDHDLR_WAIT) ||
+	    (val == PHY84858_STATUS_CMD_COMPLETE_ERROR)) {
+		DP(NETIF_MSG_LINK, "FW cmd failed.\n");
+		return -EINVAL;
+	}
+	/* Step5: Once the command has completed, read the specficied DATA
+	 * registers for any saved results for the command, if applicable
+	 */
+
+	/* Gather returning data */
+	for (idx = 0; idx < argc; idx++) {
+		bnx2x_cl45_read(bp, phy, MDIO_CTL_DEVAD,
+				MDIO_848xx_CMD_HDLR_DATA1 + idx,
+				&cmd_args[idx]);
+	}
+
+	return 0;
+}
+
 static int bnx2x_84833_cmd_hdlr(struct bnx2x_phy *phy,
 				struct link_params *params, u16 fw_cmd,
 				u16 cmd_args[], int argc)
@@ -9962,16 +10043,16 @@ static int bnx2x_84833_cmd_hdlr(struct bnx2x_phy *phy,
 	struct bnx2x *bp = params->bp;
 	/* Write CMD_OPEN_OVERRIDE to STATUS reg */
 	bnx2x_cl45_write(bp, phy, MDIO_CTL_DEVAD,
-			MDIO_84833_CMD_HDLR_STATUS,
+			MDIO_848xx_CMD_HDLR_STATUS,
 			PHY84833_STATUS_CMD_OPEN_OVERRIDE);
-	for (idx = 0; idx < PHY84833_CMDHDLR_WAIT; idx++) {
+	for (idx = 0; idx < PHY848xx_CMDHDLR_WAIT; idx++) {
 		bnx2x_cl45_read(bp, phy, MDIO_CTL_DEVAD,
-				MDIO_84833_CMD_HDLR_STATUS, &val);
+				MDIO_848xx_CMD_HDLR_STATUS, &val);
 		if (val == PHY84833_STATUS_CMD_OPEN_FOR_CMDS)
 			break;
 		usleep_range(1000, 2000);
 	}
-	if (idx >= PHY84833_CMDHDLR_WAIT) {
+	if (idx >= PHY848xx_CMDHDLR_WAIT) {
 		DP(NETIF_MSG_LINK, "FW cmd: FW not ready.\n");
 		return -EINVAL;
 	}
@@ -9979,42 +10060,62 @@ static int bnx2x_84833_cmd_hdlr(struct bnx2x_phy *phy,
 	/* Prepare argument(s) and issue command */
 	for (idx = 0; idx < argc; idx++) {
 		bnx2x_cl45_write(bp, phy, MDIO_CTL_DEVAD,
-				MDIO_84833_CMD_HDLR_DATA1 + idx,
+				MDIO_848xx_CMD_HDLR_DATA1 + idx,
 				cmd_args[idx]);
 	}
 	bnx2x_cl45_write(bp, phy, MDIO_CTL_DEVAD,
-			MDIO_84833_CMD_HDLR_COMMAND, fw_cmd);
-	for (idx = 0; idx < PHY84833_CMDHDLR_WAIT; idx++) {
+			MDIO_848xx_CMD_HDLR_COMMAND, fw_cmd);
+	for (idx = 0; idx < PHY848xx_CMDHDLR_WAIT; idx++) {
 		bnx2x_cl45_read(bp, phy, MDIO_CTL_DEVAD,
-				MDIO_84833_CMD_HDLR_STATUS, &val);
+				MDIO_848xx_CMD_HDLR_STATUS, &val);
 		if ((val == PHY84833_STATUS_CMD_COMPLETE_PASS) ||
-			(val == PHY84833_STATUS_CMD_COMPLETE_ERROR))
+		    (val == PHY84833_STATUS_CMD_COMPLETE_ERROR))
 			break;
 		usleep_range(1000, 2000);
 	}
-	if ((idx >= PHY84833_CMDHDLR_WAIT) ||
-		(val == PHY84833_STATUS_CMD_COMPLETE_ERROR)) {
+	if ((idx >= PHY848xx_CMDHDLR_WAIT) ||
+	    (val == PHY84833_STATUS_CMD_COMPLETE_ERROR)) {
 		DP(NETIF_MSG_LINK, "FW cmd failed.\n");
 		return -EINVAL;
 	}
 	/* Gather returning data */
 	for (idx = 0; idx < argc; idx++) {
 		bnx2x_cl45_read(bp, phy, MDIO_CTL_DEVAD,
-				MDIO_84833_CMD_HDLR_DATA1 + idx,
+				MDIO_848xx_CMD_HDLR_DATA1 + idx,
 				&cmd_args[idx]);
 	}
 	bnx2x_cl45_write(bp, phy, MDIO_CTL_DEVAD,
-			MDIO_84833_CMD_HDLR_STATUS,
+			MDIO_848xx_CMD_HDLR_STATUS,
 			PHY84833_STATUS_CMD_CLEAR_COMPLETE);
 	return 0;
 }
 
-static int bnx2x_84833_pair_swap_cfg(struct bnx2x_phy *phy,
-				   struct link_params *params,
-				   struct link_vars *vars)
+static int bnx2x_848xx_cmd_hdlr(struct bnx2x_phy *phy,
+				struct link_params *params,
+				u16 fw_cmd,
+				u16 cmd_args[], int argc)
+{
+	struct bnx2x *bp = params->bp;
+
+	if ((phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84858) ||
+	    (REG_RD(bp, params->shmem2_base +
+		    offsetof(struct shmem2_region,
+			     link_attr_sync[params->port])) &
+	     LINK_ATTR_84858)) {
+		return bnx2x_84858_cmd_hdlr(phy, params, fw_cmd, cmd_args,
+					    argc);
+	} else {
+		return bnx2x_84833_cmd_hdlr(phy, params, fw_cmd, cmd_args,
+					    argc);
+	}
+}
+
+static int bnx2x_848xx_pair_swap_cfg(struct bnx2x_phy *phy,
+				     struct link_params *params,
+				     struct link_vars *vars)
 {
 	u32 pair_swap;
-	u16 data[PHY84833_CMDHDLR_MAX_ARGS];
+	u16 data[PHY848xx_CMDHDLR_MAX_ARGS];
 	int status;
 	struct bnx2x *bp = params->bp;
 
@@ -10030,8 +10131,9 @@ static int bnx2x_84833_pair_swap_cfg(struct bnx2x_phy *phy,
 	/* Only the second argument is used for this command */
 	data[1] = (u16)pair_swap;
 
-	status = bnx2x_84833_cmd_hdlr(phy, params,
-		PHY84833_CMD_SET_PAIR_SWAP, data, PHY84833_CMDHDLR_MAX_ARGS);
+	status = bnx2x_848xx_cmd_hdlr(phy, params,
+				      PHY848xx_CMD_SET_PAIR_SWAP, data,
+				      PHY848xx_CMDHDLR_MAX_ARGS);
 	if (status == 0)
 		DP(NETIF_MSG_LINK, "Pairswap OK, val=0x%x\n", data[1]);
 
@@ -10120,8 +10222,8 @@ static int bnx2x_8483x_disable_eee(struct bnx2x_phy *phy,
 	DP(NETIF_MSG_LINK, "Don't Advertise 10GBase-T EEE\n");
 
 	/* Prevent Phy from working in EEE and advertising it */
-	rc = bnx2x_84833_cmd_hdlr(phy, params,
-		PHY84833_CMD_SET_EEE_MODE, &cmd_args, 1);
+	rc = bnx2x_848xx_cmd_hdlr(phy, params,
+				  PHY848xx_CMD_SET_EEE_MODE, &cmd_args, 1);
 	if (rc) {
 		DP(NETIF_MSG_LINK, "EEE disable failed.\n");
 		return rc;
@@ -10138,8 +10240,8 @@ static int bnx2x_8483x_enable_eee(struct bnx2x_phy *phy,
 	struct bnx2x *bp = params->bp;
 	u16 cmd_args = 1;
 
-	rc = bnx2x_84833_cmd_hdlr(phy, params,
-		PHY84833_CMD_SET_EEE_MODE, &cmd_args, 1);
+	rc = bnx2x_848xx_cmd_hdlr(phy, params,
+				  PHY848xx_CMD_SET_EEE_MODE, &cmd_args, 1);
 	if (rc) {
 		DP(NETIF_MSG_LINK, "EEE enable failed.\n");
 		return rc;
@@ -10157,7 +10259,7 @@ static int bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 	u8 port, initialize = 1;
 	u16 val;
 	u32 actual_phy_selection;
-	u16 cmd_args[PHY84833_CMDHDLR_MAX_ARGS];
+	u16 cmd_args[PHY848xx_CMDHDLR_MAX_ARGS];
 	int rc = 0;
 
 	usleep_range(1000, 2000);
@@ -10182,8 +10284,7 @@ static int bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 
 	/* Wait for GPHY to come out of reset */
 	msleep(50);
-	if ((phy->type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833) &&
-	    (phy->type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84834)) {
+	if (!bnx2x_is_8483x_8485x(phy)) {
 		/* BCM84823 requires that XGXS links up first @ 10G for normal
 		 * behavior.
 		 */
@@ -10194,7 +10295,19 @@ static int bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 		bnx2x_program_serdes(&params->phy[INT_PHY], params, vars);
 		vars->line_speed = temp;
 	}
+	/* Check if this is actually BCM84858 */
+	if (phy->type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84858) {
+		u16 hw_rev;
 
+		bnx2x_cl45_read(bp, phy, MDIO_AN_DEVAD,
+				MDIO_AN_REG_848xx_ID_MSB, &hw_rev);
+		if (hw_rev == BCM84858_PHY_ID) {
+			params->link_attr_sync |= LINK_ATTR_84858;
+			bnx2x_update_link_attr(params, params->link_attr_sync);
+		}
+	}
+
+	/* Set dual-media configuration according to configuration */
 	bnx2x_cl45_read(bp, phy, MDIO_CTL_DEVAD,
 			MDIO_CTL_REG_84823_MEDIA, &val);
 	val &= ~(MDIO_CTL_REG_84823_MEDIA_MAC_MASK |
@@ -10239,18 +10352,17 @@ static int bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 	DP(NETIF_MSG_LINK, "Multi_phy config = 0x%x, Media control = 0x%x\n",
 		   params->multi_phy_config, val);
 
-	if ((phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833) ||
-	    (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84834)) {
-		bnx2x_84833_pair_swap_cfg(phy, params, vars);
+	if (bnx2x_is_8483x_8485x(phy)) {
+		bnx2x_848xx_pair_swap_cfg(phy, params, vars);
 
 		/* Keep AutogrEEEn disabled. */
 		cmd_args[0] = 0x0;
 		cmd_args[1] = 0x0;
 		cmd_args[2] = PHY84833_CONSTANT_LATENCY + 1;
 		cmd_args[3] = PHY84833_CONSTANT_LATENCY;
-		rc = bnx2x_84833_cmd_hdlr(phy, params,
-			PHY84833_CMD_SET_EEE_MODE, cmd_args,
-			PHY84833_CMDHDLR_MAX_ARGS);
+		rc = bnx2x_848xx_cmd_hdlr(phy, params,
+					  PHY848xx_CMD_SET_EEE_MODE, cmd_args,
+					  PHY848xx_CMDHDLR_MAX_ARGS);
 		if (rc)
 			DP(NETIF_MSG_LINK, "Cfg AutogrEEEn failed.\n");
 	}
@@ -10304,8 +10416,7 @@ static int bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 		vars->eee_status &= ~SHMEM_EEE_SUPPORTED_MASK;
 	}
 
-	if ((phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833) ||
-	    (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84834)) {
+	if (bnx2x_is_8483x_8485x(phy)) {
 		/* Bring PHY out of super isolate mode as the final step. */
 		bnx2x_cl45_read_and_write(bp, phy,
 					  MDIO_CTL_DEVAD,
@@ -10437,8 +10548,7 @@ static u8 bnx2x_848xx_read_status(struct bnx2x_phy *phy,
 				LINK_STATUS_LINK_PARTNER_10GXFD_CAPABLE;
 
 		/* Determine if EEE was negotiated */
-		if ((phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833) ||
-		    (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84834))
+		if (bnx2x_is_8483x_8485x(phy))
 			bnx2x_eee_an_resolve(phy, params, vars);
 	}
 
@@ -11844,6 +11954,40 @@ static const struct bnx2x_phy phy_84834 = {
 	.phy_specific_func = (phy_specific_func_t)bnx2x_848xx_specific_func
 };
 
+static const struct bnx2x_phy phy_84858 = {
+	.type		= PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84858,
+	.addr		= 0xff,
+	.def_md_devad	= 0,
+	.flags		= FLAGS_FAN_FAILURE_DET_REQ |
+			    FLAGS_REARM_LATCH_SIGNAL,
+	.rx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
+	.tx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
+	.mdio_ctrl	= 0,
+	.supported	= (SUPPORTED_100baseT_Half |
+			   SUPPORTED_100baseT_Full |
+			   SUPPORTED_1000baseT_Full |
+			   SUPPORTED_10000baseT_Full |
+			   SUPPORTED_TP |
+			   SUPPORTED_Autoneg |
+			   SUPPORTED_Pause |
+			   SUPPORTED_Asym_Pause),
+	.media_type	= ETH_PHY_BASE_T,
+	.ver_addr	= 0,
+	.req_flow_ctrl	= 0,
+	.req_line_speed	= 0,
+	.speed_cap_mask	= 0,
+	.req_duplex	= 0,
+	.rsrv		= 0,
+	.config_init	= (config_init_t)bnx2x_848x3_config_init,
+	.read_status	= (read_status_t)bnx2x_848xx_read_status,
+	.link_reset	= (link_reset_t)bnx2x_848x3_link_reset,
+	.config_loopback = (config_loopback_t)NULL,
+	.format_fw_ver	= (format_fw_ver_t)bnx2x_848xx_format_ver,
+	.hw_reset	= (hw_reset_t)bnx2x_84833_hw_reset_phy,
+	.set_link_led	= (set_link_led_t)bnx2x_848xx_set_link_led,
+	.phy_specific_func = (phy_specific_func_t)bnx2x_848xx_specific_func
+};
+
 static const struct bnx2x_phy phy_54618se = {
 	.type		= PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM54618SE,
 	.addr		= 0xff,
@@ -12130,6 +12274,9 @@ static int bnx2x_populate_ext_phy(struct bnx2x *bp,
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84834:
 		*phy = phy_84834;
 		break;
+	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84858:
+		*phy = phy_84858;
+		break;
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM54616:
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM54618SE:
 		*phy = phy_54618se;
@@ -12186,9 +12333,7 @@ static int bnx2x_populate_ext_phy(struct bnx2x *bp,
 	}
 	phy->mdio_ctrl = bnx2x_get_emac_base(bp, mdc_mdio_access, port);
 
-	if (((phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833) ||
-	     (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84834)) &&
-	    (phy->ver_addr)) {
+	if (bnx2x_is_8483x_8485x(phy) && (phy->ver_addr)) {
 		/* Remove 100Mb link supported for BCM84833/4 when phy fw
 		 * version lower than or equal to 1.39
 		 */
@@ -13283,6 +13428,7 @@ static int bnx2x_ext_phy_common_init(struct bnx2x *bp, u32 shmem_base_path[],
 		break;
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833:
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84834:
+	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84858:
 		/* GPIO3's are linked, and so both need to be toggled
 		 * to obtain required 2us pulse.
 		 */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
index b7d33a1..f18bf51 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
@@ -7242,6 +7242,9 @@ Theotherbitsarereservedandshouldbezero*/
 #define MDIO_AN_REG_8481_LEGACY_MII_CTRL	0xffe0
 #define MDIO_AN_REG_8481_MII_CTRL_FORCE_1G	0x40
 #define MDIO_AN_REG_8481_LEGACY_MII_STATUS	0xffe1
+#define MDIO_AN_REG_848xx_ID_MSB		0xffe2
+#define BCM84858_PHY_ID					0x600d
+#define MDIO_AN_REG_848xx_ID_LSB		0xffe3
 #define MDIO_AN_REG_8481_LEGACY_AN_ADV		0xffe4
 #define MDIO_AN_REG_8481_LEGACY_AN_EXPANSION	0xffe6
 #define MDIO_AN_REG_8481_1000T_CTRL		0xffe9
@@ -7285,31 +7288,31 @@ Theotherbitsarereservedandshouldbezero*/
 #define MDIO_84833_TOP_CFG_FW_NO_EEE		0x1f81
 #define MDIO_84833_TOP_CFG_XGPHY_STRAP1			0x401a
 #define MDIO_84833_SUPER_ISOLATE		0x8000
-/* These are mailbox register set used by 84833. */
-#define MDIO_84833_TOP_CFG_SCRATCH_REG0			0x4005
-#define MDIO_84833_TOP_CFG_SCRATCH_REG1			0x4006
-#define MDIO_84833_TOP_CFG_SCRATCH_REG2			0x4007
-#define MDIO_84833_TOP_CFG_SCRATCH_REG3			0x4008
-#define MDIO_84833_TOP_CFG_SCRATCH_REG4			0x4009
-#define MDIO_84833_TOP_CFG_SCRATCH_REG26		0x4037
-#define MDIO_84833_TOP_CFG_SCRATCH_REG27		0x4038
-#define MDIO_84833_TOP_CFG_SCRATCH_REG28		0x4039
-#define MDIO_84833_TOP_CFG_SCRATCH_REG29		0x403a
-#define MDIO_84833_TOP_CFG_SCRATCH_REG30		0x403b
-#define MDIO_84833_TOP_CFG_SCRATCH_REG31		0x403c
-#define MDIO_84833_CMD_HDLR_COMMAND	MDIO_84833_TOP_CFG_SCRATCH_REG0
-#define MDIO_84833_CMD_HDLR_STATUS	MDIO_84833_TOP_CFG_SCRATCH_REG26
-#define MDIO_84833_CMD_HDLR_DATA1	MDIO_84833_TOP_CFG_SCRATCH_REG27
-#define MDIO_84833_CMD_HDLR_DATA2	MDIO_84833_TOP_CFG_SCRATCH_REG28
-#define MDIO_84833_CMD_HDLR_DATA3	MDIO_84833_TOP_CFG_SCRATCH_REG29
-#define MDIO_84833_CMD_HDLR_DATA4	MDIO_84833_TOP_CFG_SCRATCH_REG30
-#define MDIO_84833_CMD_HDLR_DATA5	MDIO_84833_TOP_CFG_SCRATCH_REG31
+/* These are mailbox register set used by 84833/84858. */
+#define MDIO_848xx_TOP_CFG_SCRATCH_REG0			0x4005
+#define MDIO_848xx_TOP_CFG_SCRATCH_REG1			0x4006
+#define MDIO_848xx_TOP_CFG_SCRATCH_REG2			0x4007
+#define MDIO_848xx_TOP_CFG_SCRATCH_REG3			0x4008
+#define MDIO_848xx_TOP_CFG_SCRATCH_REG4			0x4009
+#define MDIO_848xx_TOP_CFG_SCRATCH_REG26		0x4037
+#define MDIO_848xx_TOP_CFG_SCRATCH_REG27		0x4038
+#define MDIO_848xx_TOP_CFG_SCRATCH_REG28		0x4039
+#define MDIO_848xx_TOP_CFG_SCRATCH_REG29		0x403a
+#define MDIO_848xx_TOP_CFG_SCRATCH_REG30		0x403b
+#define MDIO_848xx_TOP_CFG_SCRATCH_REG31		0x403c
+#define MDIO_848xx_CMD_HDLR_COMMAND	(MDIO_848xx_TOP_CFG_SCRATCH_REG0)
+#define MDIO_848xx_CMD_HDLR_STATUS	(MDIO_848xx_TOP_CFG_SCRATCH_REG26)
+#define MDIO_848xx_CMD_HDLR_DATA1	(MDIO_848xx_TOP_CFG_SCRATCH_REG27)
+#define MDIO_848xx_CMD_HDLR_DATA2	(MDIO_848xx_TOP_CFG_SCRATCH_REG28)
+#define MDIO_848xx_CMD_HDLR_DATA3	(MDIO_848xx_TOP_CFG_SCRATCH_REG29)
+#define MDIO_848xx_CMD_HDLR_DATA4	(MDIO_848xx_TOP_CFG_SCRATCH_REG30)
+#define MDIO_848xx_CMD_HDLR_DATA5	(MDIO_848xx_TOP_CFG_SCRATCH_REG31)
 
-/* Mailbox command set used by 84833. */
-#define PHY84833_CMD_SET_PAIR_SWAP			0x8001
-#define PHY84833_CMD_GET_EEE_MODE			0x8008
-#define PHY84833_CMD_SET_EEE_MODE			0x8009
-/* Mailbox status set used by 84833. */
+/* Mailbox command set used by 84833/84858 */
+#define PHY848xx_CMD_SET_PAIR_SWAP			0x8001
+#define PHY848xx_CMD_GET_EEE_MODE			0x8008
+#define PHY848xx_CMD_SET_EEE_MODE			0x8009
+/* Mailbox status set used by 84833 only */
 #define PHY84833_STATUS_CMD_RECEIVED			0x0001
 #define PHY84833_STATUS_CMD_IN_PROGRESS			0x0002
 #define PHY84833_STATUS_CMD_COMPLETE_PASS		0x0004
@@ -7320,6 +7323,13 @@ Theotherbitsarereservedandshouldbezero*/
 #define PHY84833_STATUS_CMD_CLEAR_COMPLETE		0x0080
 #define PHY84833_STATUS_CMD_OPEN_OVERRIDE		0xa5a5
 
+/* Mailbox status set used by 84858 only */
+#define PHY84858_STATUS_CMD_RECEIVED			0x0001
+#define PHY84858_STATUS_CMD_IN_PROGRESS			0x0002
+#define PHY84858_STATUS_CMD_COMPLETE_PASS		0x0004
+#define PHY84858_STATUS_CMD_COMPLETE_ERROR		0x0008
+#define PHY84858_STATUS_CMD_SYSTEM_BUSY			0xbbbb
+
 
 /* Warpcore clause 45 addressing */
 #define MDIO_WC_DEVAD					0x3
-- 
1.9.3
