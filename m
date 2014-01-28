From: Yaniv Rosner <yanivr@broadcom.com>
Subject: [PATCH net] bnx2x: Fix generic option settings
Date: Tue, 28 Jan 2014 17:28:51 +0200
Message-ID: <1390922931-2137-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Yaniv Rosner <yanivr@broadcom.com>,
	Ariel Elior <ariele@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:26558 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755259AbaA1P3B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jan 2014 10:29:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When user tried to change generic options using "ethtool -s" command, while SFP
module is plugged out or during module detection, the command would have failed
with "Unsupported port type" message. The fix is to ignore the port option in 
case it's same as the current port configuration.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
---
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |   78 ++++++++++----------
 1 files changed, 38 insertions(+), 40 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 92a467f..38fc794 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -358,49 +358,47 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 	cfg_idx = bnx2x_get_link_cfg_idx(bp);
 	old_multi_phy_config = bp->link_params.multi_phy_config;
-	switch (cmd->port) {
-	case PORT_TP:
-		if (bp->port.supported[cfg_idx] & SUPPORTED_TP)
-			break; /* no port change */
-
-		if (!(bp->port.supported[0] & SUPPORTED_TP ||
-		      bp->port.supported[1] & SUPPORTED_TP)) {
-			DP(BNX2X_MSG_ETHTOOL, "Unsupported port type\n");
-			return -EINVAL;
-		}
-		bp->link_params.multi_phy_config &=
-			~PORT_HW_CFG_PHY_SELECTION_MASK;
-		if (bp->link_params.multi_phy_config &
-		    PORT_HW_CFG_PHY_SWAPPED_ENABLED)
-			bp->link_params.multi_phy_config |=
-			PORT_HW_CFG_PHY_SELECTION_SECOND_PHY;
-		else
-			bp->link_params.multi_phy_config |=
-			PORT_HW_CFG_PHY_SELECTION_FIRST_PHY;
-		break;
-	case PORT_FIBRE:
-	case PORT_DA:
-		if (bp->port.supported[cfg_idx] & SUPPORTED_FIBRE)
-			break; /* no port change */
-
-		if (!(bp->port.supported[0] & SUPPORTED_FIBRE ||
-		      bp->port.supported[1] & SUPPORTED_FIBRE)) {
+	if (cmd->port != bnx2x_get_port_type(bp)) {
+		switch (cmd->port) {
+		case PORT_TP:
+			if (!(bp->port.supported[0] & SUPPORTED_TP ||
+			      bp->port.supported[1] & SUPPORTED_TP)) {
+				DP(BNX2X_MSG_ETHTOOL,
+				   "Unsupported port type\n");
+				return -EINVAL;
+			}
+			bp->link_params.multi_phy_config &=
+				~PORT_HW_CFG_PHY_SELECTION_MASK;
+			if (bp->link_params.multi_phy_config &
+			    PORT_HW_CFG_PHY_SWAPPED_ENABLED)
+				bp->link_params.multi_phy_config |=
+				PORT_HW_CFG_PHY_SELECTION_SECOND_PHY;
+			else
+				bp->link_params.multi_phy_config |=
+				PORT_HW_CFG_PHY_SELECTION_FIRST_PHY;
+			break;
+		case PORT_FIBRE:
+		case PORT_DA:
+			if (!(bp->port.supported[0] & SUPPORTED_FIBRE ||
+			      bp->port.supported[1] & SUPPORTED_FIBRE)) {
+				DP(BNX2X_MSG_ETHTOOL,
+				   "Unsupported port type\n");
+				return -EINVAL;
+			}
+			bp->link_params.multi_phy_config &=
+				~PORT_HW_CFG_PHY_SELECTION_MASK;
+			if (bp->link_params.multi_phy_config &
+			    PORT_HW_CFG_PHY_SWAPPED_ENABLED)
+				bp->link_params.multi_phy_config |=
+				PORT_HW_CFG_PHY_SELECTION_FIRST_PHY;
+			else
+				bp->link_params.multi_phy_config |=
+				PORT_HW_CFG_PHY_SELECTION_SECOND_PHY;
+			break;
+		default:
 			DP(BNX2X_MSG_ETHTOOL, "Unsupported port type\n");
 			return -EINVAL;
 		}
-		bp->link_params.multi_phy_config &=
-			~PORT_HW_CFG_PHY_SELECTION_MASK;
-		if (bp->link_params.multi_phy_config &
-		    PORT_HW_CFG_PHY_SWAPPED_ENABLED)
-			bp->link_params.multi_phy_config |=
-			PORT_HW_CFG_PHY_SELECTION_FIRST_PHY;
-		else
-			bp->link_params.multi_phy_config |=
-			PORT_HW_CFG_PHY_SELECTION_SECOND_PHY;
-		break;
-	default:
-		DP(BNX2X_MSG_ETHTOOL, "Unsupported port type\n");
-		return -EINVAL;
 	}
 	/* Save new config in case command complete successfully */
 	new_multi_phy_config = bp->link_params.multi_phy_config;
-- 
1.7.1
