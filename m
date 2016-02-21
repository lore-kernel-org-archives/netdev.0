From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 5/5] bnx2x: Fix 84833 phy command handler
Date: Sun, 21 Feb 2016 15:07:29 +0200
Message-ID: <1456060049-10678-6-git-send-email-Yuval.Mintz@qlogic.com>
References: <1456060049-10678-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:32279 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751162AbcBURpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Feb 2016 12:45:15 -0500
In-Reply-To: <1456060049-10678-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current initialization sequence is lacking, causing some configurations
to fail.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c | 81 +++++++++++++++---------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h  |  4 ++
 2 files changed, 56 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 8779f15..1fb8010 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -10117,15 +10117,20 @@ static int bnx2x_84858_cmd_hdlr(struct bnx2x_phy *phy,
 
 static int bnx2x_84833_cmd_hdlr(struct bnx2x_phy *phy,
 				struct link_params *params, u16 fw_cmd,
-				u16 cmd_args[], int argc)
+				u16 cmd_args[], int argc, int process)
 {
 	int idx;
 	u16 val;
 	struct bnx2x *bp = params->bp;
-	/* Write CMD_OPEN_OVERRIDE to STATUS reg */
-	bnx2x_cl45_write(bp, phy, MDIO_CTL_DEVAD,
-			MDIO_848xx_CMD_HDLR_STATUS,
-			PHY84833_STATUS_CMD_OPEN_OVERRIDE);
+	int rc = 0;
+
+	if (process == PHY84833_MB_PROCESS2) {
+		/* Write CMD_OPEN_OVERRIDE to STATUS reg */
+		bnx2x_cl45_write(bp, phy, MDIO_CTL_DEVAD,
+				 MDIO_848xx_CMD_HDLR_STATUS,
+				 PHY84833_STATUS_CMD_OPEN_OVERRIDE);
+	}
+
 	for (idx = 0; idx < PHY848xx_CMDHDLR_WAIT; idx++) {
 		bnx2x_cl45_read(bp, phy, MDIO_CTL_DEVAD,
 				MDIO_848xx_CMD_HDLR_STATUS, &val);
@@ -10135,15 +10140,27 @@ static int bnx2x_84833_cmd_hdlr(struct bnx2x_phy *phy,
 	}
 	if (idx >= PHY848xx_CMDHDLR_WAIT) {
 		DP(NETIF_MSG_LINK, "FW cmd: FW not ready.\n");
+		/* if the status is CMD_COMPLETE_PASS or CMD_COMPLETE_ERROR
+		 * clear the status to CMD_CLEAR_COMPLETE
+		 */
+		if (val == PHY84833_STATUS_CMD_COMPLETE_PASS ||
+		    val == PHY84833_STATUS_CMD_COMPLETE_ERROR) {
+			bnx2x_cl45_write(bp, phy, MDIO_CTL_DEVAD,
+					 MDIO_848xx_CMD_HDLR_STATUS,
+					 PHY84833_STATUS_CMD_CLEAR_COMPLETE);
+		}
 		return -EINVAL;
 	}
-
-	/* Prepare argument(s) and issue command */
-	for (idx = 0; idx < argc; idx++) {
-		bnx2x_cl45_write(bp, phy, MDIO_CTL_DEVAD,
-				MDIO_848xx_CMD_HDLR_DATA1 + idx,
-				cmd_args[idx]);
+	if (process == PHY84833_MB_PROCESS1 ||
+	    process == PHY84833_MB_PROCESS2) {
+		/* Prepare argument(s) */
+		for (idx = 0; idx < argc; idx++) {
+			bnx2x_cl45_write(bp, phy, MDIO_CTL_DEVAD,
+					 MDIO_848xx_CMD_HDLR_DATA1 + idx,
+					 cmd_args[idx]);
+		}
 	}
+
 	bnx2x_cl45_write(bp, phy, MDIO_CTL_DEVAD,
 			MDIO_848xx_CMD_HDLR_COMMAND, fw_cmd);
 	for (idx = 0; idx < PHY848xx_CMDHDLR_WAIT; idx++) {
@@ -10157,24 +10174,30 @@ static int bnx2x_84833_cmd_hdlr(struct bnx2x_phy *phy,
 	if ((idx >= PHY848xx_CMDHDLR_WAIT) ||
 	    (val == PHY84833_STATUS_CMD_COMPLETE_ERROR)) {
 		DP(NETIF_MSG_LINK, "FW cmd failed.\n");
-		return -EINVAL;
+		rc = -EINVAL;
 	}
-	/* Gather returning data */
-	for (idx = 0; idx < argc; idx++) {
-		bnx2x_cl45_read(bp, phy, MDIO_CTL_DEVAD,
-				MDIO_848xx_CMD_HDLR_DATA1 + idx,
-				&cmd_args[idx]);
+	if (process == PHY84833_MB_PROCESS3 && rc == 0) {
+		/* Gather returning data */
+		for (idx = 0; idx < argc; idx++) {
+			bnx2x_cl45_read(bp, phy, MDIO_CTL_DEVAD,
+					MDIO_848xx_CMD_HDLR_DATA1 + idx,
+					&cmd_args[idx]);
+		}
 	}
-	bnx2x_cl45_write(bp, phy, MDIO_CTL_DEVAD,
-			MDIO_848xx_CMD_HDLR_STATUS,
-			PHY84833_STATUS_CMD_CLEAR_COMPLETE);
-	return 0;
+	if (val == PHY84833_STATUS_CMD_COMPLETE_ERROR ||
+	    val == PHY84833_STATUS_CMD_COMPLETE_PASS) {
+		bnx2x_cl45_write(bp, phy, MDIO_CTL_DEVAD,
+				 MDIO_848xx_CMD_HDLR_STATUS,
+				 PHY84833_STATUS_CMD_CLEAR_COMPLETE);
+	}
+	return rc;
 }
 
 static int bnx2x_848xx_cmd_hdlr(struct bnx2x_phy *phy,
 				struct link_params *params,
 				u16 fw_cmd,
-				u16 cmd_args[], int argc)
+					   u16 cmd_args[], int argc,
+					   int process)
 {
 	struct bnx2x *bp = params->bp;
 
@@ -10187,7 +10210,7 @@ static int bnx2x_848xx_cmd_hdlr(struct bnx2x_phy *phy,
 					    argc);
 	} else {
 		return bnx2x_84833_cmd_hdlr(phy, params, fw_cmd, cmd_args,
-					    argc);
+					    argc, process);
 	}
 }
 
@@ -10214,7 +10237,7 @@ static int bnx2x_848xx_pair_swap_cfg(struct bnx2x_phy *phy,
 
 	status = bnx2x_848xx_cmd_hdlr(phy, params,
 				      PHY848xx_CMD_SET_PAIR_SWAP, data,
-				      PHY848xx_CMDHDLR_MAX_ARGS);
+				      2, PHY84833_MB_PROCESS2);
 	if (status == 0)
 		DP(NETIF_MSG_LINK, "Pairswap OK, val=0x%x\n", data[1]);
 
@@ -10303,8 +10326,8 @@ static int bnx2x_8483x_disable_eee(struct bnx2x_phy *phy,
 	DP(NETIF_MSG_LINK, "Don't Advertise 10GBase-T EEE\n");
 
 	/* Prevent Phy from working in EEE and advertising it */
-	rc = bnx2x_848xx_cmd_hdlr(phy, params,
-				  PHY848xx_CMD_SET_EEE_MODE, &cmd_args, 1);
+	rc = bnx2x_848xx_cmd_hdlr(phy, params, PHY848xx_CMD_SET_EEE_MODE,
+				  &cmd_args, 1, PHY84833_MB_PROCESS1);
 	if (rc) {
 		DP(NETIF_MSG_LINK, "EEE disable failed.\n");
 		return rc;
@@ -10321,8 +10344,8 @@ static int bnx2x_8483x_enable_eee(struct bnx2x_phy *phy,
 	struct bnx2x *bp = params->bp;
 	u16 cmd_args = 1;
 
-	rc = bnx2x_848xx_cmd_hdlr(phy, params,
-				  PHY848xx_CMD_SET_EEE_MODE, &cmd_args, 1);
+	rc = bnx2x_848xx_cmd_hdlr(phy, params, PHY848xx_CMD_SET_EEE_MODE,
+				  &cmd_args, 1, PHY84833_MB_PROCESS1);
 	if (rc) {
 		DP(NETIF_MSG_LINK, "EEE enable failed.\n");
 		return rc;
@@ -10443,7 +10466,7 @@ static int bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 		cmd_args[3] = PHY84833_CONSTANT_LATENCY;
 		rc = bnx2x_848xx_cmd_hdlr(phy, params,
 					  PHY848xx_CMD_SET_EEE_MODE, cmd_args,
-					  PHY848xx_CMDHDLR_MAX_ARGS);
+					  4, PHY84833_MB_PROCESS1);
 		if (rc)
 			DP(NETIF_MSG_LINK, "Cfg AutogrEEEn failed.\n");
 	}
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
index d27d40e..a43dea2 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
@@ -7339,6 +7339,10 @@ Theotherbitsarereservedandshouldbezero*/
 #define PHY84833_STATUS_CMD_NOT_OPEN_FOR_CMDS		0x0040
 #define PHY84833_STATUS_CMD_CLEAR_COMPLETE		0x0080
 #define PHY84833_STATUS_CMD_OPEN_OVERRIDE		0xa5a5
+/* Mailbox Process */
+#define PHY84833_MB_PROCESS1				1
+#define PHY84833_MB_PROCESS2				2
+#define PHY84833_MB_PROCESS3				3
 
 /* Mailbox status set used by 84858 only */
 #define PHY84858_STATUS_CMD_RECEIVED			0x0001
-- 
1.9.3
