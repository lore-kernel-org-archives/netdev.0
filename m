From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net 2/2] bnx2x: Fix SFP+ misconfiguration in iSCSI boot
 scenario
Date: Fri, 8 Mar 2013 01:27:34 +0200
Message-ID: <1362698854-6786-3-git-send-email-yanivr@broadcom.com>
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
	id S933459Ab3CGV3Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Mar 2013 16:29:16 -0500
In-Reply-To: <1362698854-6786-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a problem in which iSCSI-boot installation fails when switching SFP+ boot
port and moving the SFP+ module prior to boot. The SFP+ insertion triggers an
interrupt which configures the SFP+ module wrongly before interface is loaded.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |    6 +++++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h |    1 +
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 032d48e..3985533 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -8647,7 +8647,9 @@ void bnx2x_handle_module_detect_int(struct link_params *params)
 						MDIO_WC_DEVAD,
 						MDIO_WC_REG_DIGITAL5_MISC6,
 						&rx_tx_in_reset);
-				if (!rx_tx_in_reset) {
+				if ((!rx_tx_in_reset) &&
+				    (params->link_flags &
+				     PHY_INITIALIZED)) {
 					bnx2x_warpcore_reset_lane(bp, phy, 1);
 					bnx2x_warpcore_config_sfi(phy, params);
 					bnx2x_warpcore_reset_lane(bp, phy, 0);
@@ -12528,6 +12530,7 @@ int bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 	vars->mac_type = MAC_TYPE_NONE;
 	vars->phy_flags = 0;
 	vars->check_kr2_recovery_cnt = 0;
+	params->link_flags = PHY_INITIALIZED;
 	/* Driver opens NIG-BRB filters */
 	bnx2x_set_rx_filter(params, 1);
 	/* Check if link flap can be avoided */
@@ -12692,6 +12695,7 @@ int bnx2x_lfa_reset(struct link_params *params,
 	struct bnx2x *bp = params->bp;
 	vars->link_up = 0;
 	vars->phy_flags = 0;
+	params->link_flags &= ~PHY_INITIALIZED;
 	if (!params->lfa_base)
 		return bnx2x_link_reset(params, vars, 1);
 	/*
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
index f92fcf7..56c2aae 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
@@ -309,6 +309,7 @@ struct link_params {
 				req_flow_ctrl is set to AUTO */
 	u16 link_flags;
 #define LINK_FLAGS_INT_DISABLED		(1<<0)
+#define PHY_INITIALIZED		(1<<1)
 	u32 lfa_base;
 };
 
-- 
1.7.7.1
