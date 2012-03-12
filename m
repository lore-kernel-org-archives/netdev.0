From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net-next 6/8] bnx2x: ethtool now returns unknown speed/duplex
Date: Mon, 12 Mar 2012 14:53:12 -0400
Message-ID: <1331578394-1153-7-git-send-email-yuvalmin@broadcom.com>
References: <1331578394-1153-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4001 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754745Ab2CLL7d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2012 07:59:33 -0400
In-Reply-To: <1331578394-1153-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previously, unless both interface and link were up, ethtool returned
the requested speed/duplex when asked for the interface's settings.
This change will now enable the driver to answer correctly (i.e., 
return unknown as its answer).

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |   29 ++++++++++++-------
 1 files changed, 18 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 9c24d53..8f8421d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -222,20 +222,23 @@ static int bnx2x_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		 (SUPPORTED_TP | SUPPORTED_FIBRE));
 	cmd->advertising = bp->port.advertising[cfg_idx];
 
-	if ((bp->state == BNX2X_STATE_OPEN) &&
-	    !(bp->flags & MF_FUNC_DIS) &&
-	    (bp->link_vars.link_up)) {
-		ethtool_cmd_speed_set(cmd, bp->link_vars.line_speed);
-		cmd->duplex = bp->link_vars.duplex;
+	if ((bp->state == BNX2X_STATE_OPEN) && (bp->link_vars.link_up)) {
+		if (!(bp->flags & MF_FUNC_DIS)) {
+			ethtool_cmd_speed_set(cmd, bp->link_vars.line_speed);
+			cmd->duplex = bp->link_vars.duplex;
+		} else {
+			ethtool_cmd_speed_set(
+				cmd, bp->link_params.req_line_speed[cfg_idx]);
+			cmd->duplex = bp->link_params.req_duplex[cfg_idx];
+		}
+
+		if (IS_MF(bp) && !BP_NOMCP(bp))
+			ethtool_cmd_speed_set(cmd, bnx2x_get_mf_speed(bp));
 	} else {
-		ethtool_cmd_speed_set(
-			cmd, bp->link_params.req_line_speed[cfg_idx]);
-		cmd->duplex = bp->link_params.req_duplex[cfg_idx];
+		cmd->duplex = DUPLEX_UNKNOWN;
+		ethtool_cmd_speed_set(cmd, SPEED_UNKNOWN);
 	}
 
-	if (IS_MF(bp))
-		ethtool_cmd_speed_set(cmd, bnx2x_get_mf_speed(bp));
-
 	cmd->port = bnx2x_get_port_type(bp);
 
 	cmd->phy_address = bp->mdio.prtad;
@@ -309,6 +312,10 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 	speed = ethtool_cmd_speed(cmd);
 
+	/* If recieved a request for an unknown duplex, assume full*/
+	if (cmd->duplex == DUPLEX_UNKNOWN)
+		cmd->duplex = DUPLEX_FULL;
+
 	if (IS_MF_SI(bp)) {
 		u32 part;
 		u32 line_speed = bp->link_vars.line_speed;
-- 
1.7.9.rc2
