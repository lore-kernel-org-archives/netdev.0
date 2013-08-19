From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net 1/6] bnx2x: dropless flow control not always
 functional
Date: Mon, 19 Aug 2013 09:11:56 +0300
Message-ID: <1376892721-10410-2-git-send-email-yuvalmin@broadcom.com>
References: <1376892721-10410-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2733 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750892Ab3HSGMR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Aug 2013 02:12:17 -0400
In-Reply-To: <1376892721-10410-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

Since commit 3deb816 "bnx2x: Add a periodic task for link PHY events"
link state changes can be detected not only via the attention flow but also
from the periodic task.
If the link state will change in such a manner (i.e., via the periodic task),
dropless flow-control will not be configured.

This patch remedies the issue, adding the missing configuration to all required
flows.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 36 +++++++++++++++---------
 1 file changed, 23 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 955d6cf..c009f19 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -2261,6 +2261,23 @@ static void bnx2x_set_requested_fc(struct bnx2x *bp)
 		bp->link_params.req_fc_auto_adv = BNX2X_FLOW_CTRL_BOTH;
 }
 
+static void bnx2x_init_dropless_fc(struct bnx2x *bp)
+{
+	u32 pause_enabled = 0;
+
+	if (!CHIP_IS_E1(bp) && bp->dropless_fc && bp->link_vars.link_up) {
+		if (bp->link_vars.flow_ctrl & BNX2X_FLOW_CTRL_TX)
+			pause_enabled = 1;
+
+		REG_WR(bp, BAR_USTRORM_INTMEM +
+			   USTORM_ETH_PAUSE_ENABLED_OFFSET(BP_PORT(bp)),
+		       pause_enabled);
+	}
+
+	DP(NETIF_MSG_IFUP | NETIF_MSG_LINK, "dropless_fc is %s\n",
+	   pause_enabled ? "enabled" : "disabled");
+}
+
 int bnx2x_initial_phy_init(struct bnx2x *bp, int load_mode)
 {
 	int rc, cfx_idx = bnx2x_get_link_cfg_idx(bp);
@@ -2294,6 +2311,8 @@ int bnx2x_initial_phy_init(struct bnx2x *bp, int load_mode)
 
 		bnx2x_release_phy_lock(bp);
 
+		bnx2x_init_dropless_fc(bp);
+
 		bnx2x_calc_fc_adv(bp);
 
 		if (bp->link_vars.link_up) {
@@ -2315,6 +2334,8 @@ void bnx2x_link_set(struct bnx2x *bp)
 		bnx2x_phy_init(&bp->link_params, &bp->link_vars);
 		bnx2x_release_phy_lock(bp);
 
+		bnx2x_init_dropless_fc(bp);
+
 		bnx2x_calc_fc_adv(bp);
 	} else
 		BNX2X_ERR("Bootcode is missing - can not set link\n");
@@ -2556,20 +2577,9 @@ static void bnx2x_link_attn(struct bnx2x *bp)
 
 	bnx2x_link_update(&bp->link_params, &bp->link_vars);
 
-	if (bp->link_vars.link_up) {
-
-		/* dropless flow control */
-		if (!CHIP_IS_E1(bp) && bp->dropless_fc) {
-			int port = BP_PORT(bp);
-			u32 pause_enabled = 0;
-
-			if (bp->link_vars.flow_ctrl & BNX2X_FLOW_CTRL_TX)
-				pause_enabled = 1;
+	bnx2x_init_dropless_fc(bp);
 
-			REG_WR(bp, BAR_USTRORM_INTMEM +
-			       USTORM_ETH_PAUSE_ENABLED_OFFSET(port),
-			       pause_enabled);
-		}
+	if (bp->link_vars.link_up) {
 
 		if (bp->link_vars.mac_type != MAC_TYPE_EMAC) {
 			struct host_port_stats *pstats;
-- 
1.8.1.227.g44fe835
