From: "Yaniv Rosner" <yaniv.rosner@broadcom.com>
Subject: [PATCH net-2.6 4/8] bnx2x: Clear latch indication on link reset
Date: Mon, 1 Nov 2010 17:32:34 +0200
Message-ID: <1288625554.3533.16.camel@lb-tlvb-yanivr.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3722 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755815Ab0KAMOa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Nov 2010 08:14:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When using latch indication for link change notification, need to clear it when port is unloaded, otherwise it might generate false indication on next load.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com> 
---
 drivers/net/bnx2x/bnx2x_link.c |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index fc637ce..fdd7e03 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -6938,7 +6938,7 @@ u8 bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
 		  u8 reset_ext_phy)
 {
 	struct bnx2x *bp = params->bp;
-	u8 phy_index, port = params->port;
+	u8 phy_index, port = params->port, clear_latch_ind = 0;
 	DP(NETIF_MSG_LINK, "Resetting the link of port %d\n", port);
 	/* disable attentions */
 	vars->link_status = 0;
@@ -6976,9 +6976,18 @@ u8 bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
 				params->phy[phy_index].link_reset(
 					&params->phy[phy_index],
 					params);
+			if (params->phy[phy_index].flags &
+			    FLAGS_REARM_LATCH_SIGNAL)
+				clear_latch_ind = 1;
 		}
 	}
 
+	if (clear_latch_ind) {
+		/* Clear latching indication */
+		bnx2x_rearm_latch_signal(bp, port, 0);
+		bnx2x_bits_dis(bp, NIG_REG_LATCH_BC_0 + port*4,
+			       1 << NIG_LATCH_BC_ENABLE_MI_INT);
+	}
 	if (params->phy[INT_PHY].link_reset)
 		params->phy[INT_PHY].link_reset(
 			&params->phy[INT_PHY], params);
-- 
1.7.1




