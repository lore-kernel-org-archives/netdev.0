From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 12/13] bnx2x: fix 'Ethtool -A' when autoneg
Date: Sun, 2 Dec 2012 16:05:56 +0200
Message-ID: <1354457157-4730-13-git-send-email-yuvalmin@broadcom.com>
References: <1354457157-4730-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1646 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753996Ab2LBOFY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Dec 2012 09:05:24 -0500
In-Reply-To: <1354457157-4730-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When configuring pauses using 'ethtool -A', the requested values have
effect when used together with autoneg (up to this point, when configured
for autoneg, driver ignored requested pause configuration)

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h  |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   49 ++++++++++++----------
 2 files changed, 28 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index ad28074..32c3ab7 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -144,7 +144,7 @@ u32 bnx2x_fw_command(struct bnx2x *bp, u32 command, u32 param);
  * @bp:		driver handle
  * @load_mode:	current mode
  */
-u8 bnx2x_initial_phy_init(struct bnx2x *bp, int load_mode);
+int bnx2x_initial_phy_init(struct bnx2x *bp, int load_mode);
 
 /**
  * bnx2x_link_set - configure hw according to link parameters structure.
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index ab65f34..c8ec3fc 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -2103,22 +2103,25 @@ void bnx2x_calc_fc_adv(struct bnx2x *bp)
 	}
 }
 
-u8 bnx2x_initial_phy_init(struct bnx2x *bp, int load_mode)
+static void bnx2x_set_requested_fc(struct bnx2x *bp)
 {
-	if (!BP_NOMCP(bp)) {
-		u8 rc;
-		int cfx_idx = bnx2x_get_link_cfg_idx(bp);
-		u16 req_line_speed = bp->link_params.req_line_speed[cfx_idx];
-		/*
-		 * Initialize link parameters structure variables
-		 * It is recommended to turn off RX FC for jumbo frames
-		 * for better performance
-		 */
-		if (CHIP_IS_E1x(bp) && (bp->dev->mtu > 5000))
-			bp->link_params.req_fc_auto_adv = BNX2X_FLOW_CTRL_TX;
-		else
-			bp->link_params.req_fc_auto_adv = BNX2X_FLOW_CTRL_BOTH;
+	/* Initialize link parameters structure variables
+	 * It is recommended to turn off RX FC for jumbo frames
+	 *  for better performance
+	 */
+	if (CHIP_IS_E1x(bp) && (bp->dev->mtu > 5000))
+		bp->link_params.req_fc_auto_adv = BNX2X_FLOW_CTRL_TX;
+	else
+		bp->link_params.req_fc_auto_adv = BNX2X_FLOW_CTRL_BOTH;
+}
 
+int bnx2x_initial_phy_init(struct bnx2x *bp, int load_mode)
+{
+	int rc, cfx_idx = bnx2x_get_link_cfg_idx(bp);
+	u16 req_line_speed = bp->link_params.req_line_speed[cfx_idx];
+
+	if (!BP_NOMCP(bp)) {
+		bnx2x_set_requested_fc(bp);
 		bnx2x_acquire_phy_lock(bp);
 
 		if (load_mode == LOAD_DIAG) {
@@ -2147,11 +2150,11 @@ u8 bnx2x_initial_phy_init(struct bnx2x *bp, int load_mode)
 
 		bnx2x_calc_fc_adv(bp);
 
-		if (CHIP_REV_IS_SLOW(bp) && bp->link_vars.link_up) {
+		if (bp->link_vars.link_up) {
 			bnx2x_stats_handle(bp, STATS_EVENT_LINK_UP);
 			bnx2x_link_report(bp);
-		} else
-			queue_delayed_work(bnx2x_wq, &bp->period_task, 0);
+		}
+		queue_delayed_work(bnx2x_wq, &bp->period_task, 0);
 		bp->link_params.req_line_speed[cfx_idx] = req_line_speed;
 		return rc;
 	}
@@ -10315,11 +10318,13 @@ static void __devinit bnx2x_link_settings_requested(struct bnx2x *bp)
 
 		bp->link_params.req_flow_ctrl[idx] = (link_config &
 					 PORT_FEATURE_FLOW_CONTROL_MASK);
-		if ((bp->link_params.req_flow_ctrl[idx] ==
-		     BNX2X_FLOW_CTRL_AUTO) &&
-		    !(bp->port.supported[idx] & SUPPORTED_Autoneg)) {
-			bp->link_params.req_flow_ctrl[idx] =
-				BNX2X_FLOW_CTRL_NONE;
+		if (bp->link_params.req_flow_ctrl[idx] ==
+		    BNX2X_FLOW_CTRL_AUTO) {
+			if (!(bp->port.supported[idx] & SUPPORTED_Autoneg))
+				bp->link_params.req_flow_ctrl[idx] =
+							BNX2X_FLOW_CTRL_NONE;
+			else
+				bnx2x_set_requested_fc(bp);
 		}
 
 		BNX2X_DEV_INFO("req_line_speed %d  req_duplex %d req_flow_ctrl 0x%x advertising 0x%x\n",
-- 
1.7.1
