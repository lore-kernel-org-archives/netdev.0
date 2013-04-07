From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net 1/1] bnx2x: Fix KR2 rapid link flap
Date: Sun, 7 Apr 2013 18:36:23 +0300
Message-ID: <1365348983-29314-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Yaniv Rosner" <yanivr@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3269 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761413Ab3DGNhv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Apr 2013 09:37:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check KR2 recovery time at the beginning of the work-around function.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 77ebae0..0283f34 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -13437,13 +13437,7 @@ static void bnx2x_check_kr2_wa(struct link_params *params,
 {
 	struct bnx2x *bp = params->bp;
 	u16 base_page, next_page, not_kr2_device, lane;
-	int sigdet = bnx2x_warpcore_get_sigdet(phy, params);
-
-	if (!sigdet) {
-		if (!(vars->link_attr_sync & LINK_ATTR_SYNC_KR2_ENABLE))
-			bnx2x_kr2_recovery(params, vars, phy);
-		return;
-	}
+	int sigdet;
 
 	/* Once KR2 was disabled, wait 5 seconds before checking KR2 recovery
 	 * since some switches tend to reinit the AN process and clear the
@@ -13454,6 +13448,16 @@ static void bnx2x_check_kr2_wa(struct link_params *params,
 		vars->check_kr2_recovery_cnt--;
 		return;
 	}
+
+	sigdet = bnx2x_warpcore_get_sigdet(phy, params);
+	if (!sigdet) {
+		if (!(vars->link_attr_sync & LINK_ATTR_SYNC_KR2_ENABLE)) {
+			bnx2x_kr2_recovery(params, vars, phy);
+			DP(NETIF_MSG_LINK, "No sigdet\n");
+		}
+		return;
+	}
+
 	lane = bnx2x_get_warpcore_lane(phy, params);
 	CL22_WR_OVER_CL45(bp, phy, MDIO_REG_BANK_AER_BLOCK,
 			  MDIO_AER_BLOCK_AER_REG, lane);
-- 
1.7.7.1
