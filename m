From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net 4/4] bnx2x: Prevent "timeout waiting for state X"
Date: Sun, 17 Nov 2013 08:59:29 +0200
Message-ID: <1384671569-30105-5-git-send-email-yuvalmin@broadcom.com>
References: <1384671569-30105-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, dmitry@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4196 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751265Ab3KQG7o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Nov 2013 01:59:44 -0500
In-Reply-To: <1384671569-30105-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

Current driver release rtnl lock in between DCB re-configuration.
As a result, other flows (e.g., mtu config) may enter in between and fail
due to halted tx path for dcb configuration.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      | 1 -
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c  | 5 -----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 9 ++++-----
 3 files changed, 4 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index c5e375d..8471478 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1376,7 +1376,6 @@ enum {
 	BNX2X_SP_RTNL_RX_MODE,
 	BNX2X_SP_RTNL_HYPERVISOR_VLAN,
 	BNX2X_SP_RTNL_TX_STOP,
-	BNX2X_SP_RTNL_TX_RESUME,
 };
 
 struct bnx2x_prev_path_list {
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
index fcf2761..fdace20 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
@@ -778,11 +778,6 @@ void bnx2x_dcbx_set_params(struct bnx2x *bp, u32 state)
 
 		/* ets may affect cmng configuration: reinit it in hw */
 		bnx2x_set_local_cmng(bp);
-
-		set_bit(BNX2X_SP_RTNL_TX_RESUME, &bp->sp_rtnl_state);
-
-		schedule_delayed_work(&bp->sp_rtnl_task, 0);
-
 		return;
 	case BNX2X_DCBX_STATE_TX_RELEASED:
 		DP(BNX2X_MSG_DCB, "BNX2X_DCBX_STATE_TX_RELEASED\n");
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 1d799ee..0fb1677 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -5235,18 +5235,18 @@ static void bnx2x_eq_int(struct bnx2x *bp)
 
 		case EVENT_RING_OPCODE_STOP_TRAFFIC:
 			DP(BNX2X_MSG_SP | BNX2X_MSG_DCB, "got STOP TRAFFIC\n");
+			bnx2x_dcbx_set_params(bp, BNX2X_DCBX_STATE_TX_PAUSED);
 			if (f_obj->complete_cmd(bp, f_obj,
 						BNX2X_F_CMD_TX_STOP))
 				break;
-			bnx2x_dcbx_set_params(bp, BNX2X_DCBX_STATE_TX_PAUSED);
 			goto next_spqe;
 
 		case EVENT_RING_OPCODE_START_TRAFFIC:
 			DP(BNX2X_MSG_SP | BNX2X_MSG_DCB, "got START TRAFFIC\n");
+			bnx2x_dcbx_set_params(bp, BNX2X_DCBX_STATE_TX_RELEASED);
 			if (f_obj->complete_cmd(bp, f_obj,
 						BNX2X_F_CMD_TX_START))
 				break;
-			bnx2x_dcbx_set_params(bp, BNX2X_DCBX_STATE_TX_RELEASED);
 			goto next_spqe;
 
 		case EVENT_RING_OPCODE_FUNCTION_UPDATE:
@@ -9714,11 +9714,10 @@ sp_rtnl_not_reset:
 			       &bp->sp_rtnl_state))
 		bnx2x_pf_set_vfs_vlan(bp);
 
-	if (test_and_clear_bit(BNX2X_SP_RTNL_TX_STOP, &bp->sp_rtnl_state))
+	if (test_and_clear_bit(BNX2X_SP_RTNL_TX_STOP, &bp->sp_rtnl_state)) {
 		bnx2x_dcbx_stop_hw_tx(bp);
-
-	if (test_and_clear_bit(BNX2X_SP_RTNL_TX_RESUME, &bp->sp_rtnl_state))
 		bnx2x_dcbx_resume_hw_tx(bp);
+	}
 
 	/* work which needs rtnl lock not-taken (as it takes the lock itself and
 	 * can be called from other contexts as well)
-- 
1.8.1.227.g44fe835
