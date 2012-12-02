From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 05/13] bnx2x: Correct advertised speed/duplex
Date: Sun, 2 Dec 2012 16:05:49 +0200
Message-ID: <1354457157-4730-6-git-send-email-yuvalmin@broadcom.com>
References: <1354457157-4730-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2490 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753190Ab2LBOFJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Dec 2012 09:05:09 -0500
In-Reply-To: <1354457157-4730-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If link is down due to management (and not due to actual phy link being lost),
driver should still behave as if the link is down; Querying via ethtool about
speed/duplex state should result in 'UNKNOWN' (same behaviour as when link is
actually down).

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index c7270c0..277f17e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -231,18 +231,14 @@ static int bnx2x_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		cmd->advertising &= ~(ADVERTISED_10000baseT_Full);
 	}
 
-	if ((bp->state == BNX2X_STATE_OPEN) && (bp->link_vars.link_up)) {
-		if (!(bp->flags & MF_FUNC_DIS)) {
-			ethtool_cmd_speed_set(cmd, bp->link_vars.line_speed);
+	if ((bp->state == BNX2X_STATE_OPEN) && bp->link_vars.link_up &&
+	    !(bp->flags & MF_FUNC_DIS)) {
 			cmd->duplex = bp->link_vars.duplex;
-		} else {
-			ethtool_cmd_speed_set(
-				cmd, bp->link_params.req_line_speed[cfg_idx]);
-			cmd->duplex = bp->link_params.req_duplex[cfg_idx];
-		}
 
 		if (IS_MF(bp) && !BP_NOMCP(bp))
 			ethtool_cmd_speed_set(cmd, bnx2x_get_mf_speed(bp));
+		else
+			ethtool_cmd_speed_set(cmd, bp->link_vars.line_speed);
 	} else {
 		cmd->duplex = DUPLEX_UNKNOWN;
 		ethtool_cmd_speed_set(cmd, SPEED_UNKNOWN);
-- 
1.7.1
