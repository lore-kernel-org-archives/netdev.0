From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net 1/2] bnx2x: Fix intermittent long KR2 link up time
Date: Fri, 8 Mar 2013 01:27:33 +0200
Message-ID: <1362698854-6786-2-git-send-email-yanivr@broadcom.com>
References: <1362698854-6786-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1862 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933428Ab3CGV3L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Mar 2013 16:29:11 -0500
In-Reply-To: <1362698854-6786-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a KR2 device is connected to a KR link-partner, sometimes it requires
disabling KR2 for the link to come up. To get a KR2 link up later, in case no
base pages are seen, the KR2 is restored. The problem was that some link
partners cleared their advertised BP/NP after around two seconds, causing the
driver to disable/enable KR2 link all the time.
The fix was to wait at least 5 seconds before checking KR2 recovery.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |   11 +++++++++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h |    3 ++-
 2 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 31c5787..032d48e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -12527,6 +12527,7 @@ int bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 	vars->flow_ctrl = BNX2X_FLOW_CTRL_NONE;
 	vars->mac_type = MAC_TYPE_NONE;
 	vars->phy_flags = 0;
+	vars->check_kr2_recovery_cnt = 0;
 	/* Driver opens NIG-BRB filters */
 	bnx2x_set_rx_filter(params, 1);
 	/* Check if link flap can be avoided */
@@ -13411,6 +13412,7 @@ static void bnx2x_disable_kr2(struct link_params *params,
 	vars->link_attr_sync &= ~LINK_ATTR_SYNC_KR2_ENABLE;
 	bnx2x_update_link_attr(params, vars->link_attr_sync);
 
+	vars->check_kr2_recovery_cnt = CHECK_KR2_RECOVERY_CNT;
 	/* Restart AN on leading lane */
 	bnx2x_warpcore_restart_AN_KR(phy, params);
 }
@@ -13439,6 +13441,15 @@ static void bnx2x_check_kr2_wa(struct link_params *params,
 		return;
 	}
 
+	/* Once KR2 was disabled, wait 5 seconds before checking KR2 recovery
+	 * since some switches tend to reinit the AN process and clear the
+	 * advertised BP/NP after ~2 seconds causing the KR2 to be disabled
+	 * and recovered many times
+	 */
+	if (vars->check_kr2_recovery_cnt > 0) {
+		vars->check_kr2_recovery_cnt--;
+		return;
+	}
 	lane = bnx2x_get_warpcore_lane(phy, params);
 	CL22_WR_OVER_CL45(bp, phy, MDIO_REG_BANK_AER_BLOCK,
 			  MDIO_AER_BLOCK_AER_REG, lane);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
index be5c195..f92fcf7 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
@@ -342,7 +342,8 @@ struct link_vars {
 	u32 link_status;
 	u32 eee_status;
 	u8 fault_detected;
-	u8 rsrv1;
+	u8 check_kr2_recovery_cnt;
+#define CHECK_KR2_RECOVERY_CNT	5
 	u16 periodic_flags;
 #define PERIODIC_FLAGS_LINK_EVENT	0x0001
 
-- 
1.7.7.1
