From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net 2/6] bnx2x: Change DCB context handling
Date: Mon, 19 Aug 2013 09:11:57 +0300
Message-ID: <1376892721-10410-3-git-send-email-yuvalmin@broadcom.com>
References: <1376892721-10410-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1723 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750986Ab3HSGMX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Aug 2013 02:12:23 -0400
In-Reply-To: <1376892721-10410-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

After notification that DCBX configuration has ended arrived to the driver,
the driver configured the FW/HW in sleepless context.
As a result, it was possible to reach a race (mostly with CNIC registration)
in which the configuration will return a timeout, failing to set the DCBX
results correctly.

This patch moves the configuration following the DCBX end into the slowpath
RTNL task (i.e., sleepless context protected by the RTNL lock), allowing the
configuration to cope with such races.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |  2 ++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c  | 40 +++++++++++++++++++-----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h  |  3 ++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |  6 ++++
 4 files changed, 43 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index ce9b387..00b88cb 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1333,6 +1333,8 @@ enum {
 	BNX2X_SP_RTNL_VFPF_CHANNEL_DOWN,
 	BNX2X_SP_RTNL_VFPF_STORM_RX_MODE,
 	BNX2X_SP_RTNL_HYPERVISOR_VLAN,
+	BNX2X_SP_RTNL_TX_STOP,
+	BNX2X_SP_RTNL_TX_RESUME,
 };
 
 struct bnx2x_prev_path_list {
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
index f9122f2..d537d51 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
@@ -30,10 +30,8 @@
 #include "bnx2x_dcb.h"
 
 /* forward declarations of dcbx related functions */
-static int bnx2x_dcbx_stop_hw_tx(struct bnx2x *bp);
 static void bnx2x_pfc_set_pfc(struct bnx2x *bp);
 static void bnx2x_dcbx_update_ets_params(struct bnx2x *bp);
-static int bnx2x_dcbx_resume_hw_tx(struct bnx2x *bp);
 static void bnx2x_dcbx_get_ets_pri_pg_tbl(struct bnx2x *bp,
 					  u32 *set_configuration_ets_pg,
 					  u32 *pri_pg_tbl);
@@ -425,30 +423,52 @@ static void bnx2x_pfc_set_pfc(struct bnx2x *bp)
 		bnx2x_pfc_clear(bp);
 }
 
-static int bnx2x_dcbx_stop_hw_tx(struct bnx2x *bp)
+int bnx2x_dcbx_stop_hw_tx(struct bnx2x *bp)
 {
 	struct bnx2x_func_state_params func_params = {NULL};
+	int rc;
 
 	func_params.f_obj = &bp->func_obj;
 	func_params.cmd = BNX2X_F_CMD_TX_STOP;
 
+	__set_bit(RAMROD_COMP_WAIT, &func_params.ramrod_flags);
+	__set_bit(RAMROD_RETRY, &func_params.ramrod_flags);
+
 	DP(BNX2X_MSG_DCB, "STOP TRAFFIC\n");
-	return bnx2x_func_state_change(bp, &func_params);
+
+	rc = bnx2x_func_state_change(bp, &func_params);
+	if (rc) {
+		BNX2X_ERR("Unable to hold traffic for HW configuration\n");
+		bnx2x_panic();
+	}
+
+	return rc;
 }
 
-static int bnx2x_dcbx_resume_hw_tx(struct bnx2x *bp)
+int bnx2x_dcbx_resume_hw_tx(struct bnx2x *bp)
 {
 	struct bnx2x_func_state_params func_params = {NULL};
 	struct bnx2x_func_tx_start_params *tx_params =
 		&func_params.params.tx_start;
+	int rc;
 
 	func_params.f_obj = &bp->func_obj;
 	func_params.cmd = BNX2X_F_CMD_TX_START;
 
+	__set_bit(RAMROD_COMP_WAIT, &func_params.ramrod_flags);
+	__set_bit(RAMROD_RETRY, &func_params.ramrod_flags);
+
 	bnx2x_dcbx_fw_struct(bp, tx_params);
 
 	DP(BNX2X_MSG_DCB, "START TRAFFIC\n");
-	return bnx2x_func_state_change(bp, &func_params);
+
+	rc = bnx2x_func_state_change(bp, &func_params);
+	if (rc) {
+		BNX2X_ERR("Unable to resume traffic after HW configuration\n");
+		bnx2x_panic();
+	}
+
+	return rc;
 }
 
 static void bnx2x_dcbx_2cos_limit_update_ets_config(struct bnx2x *bp)
@@ -744,7 +764,9 @@ void bnx2x_dcbx_set_params(struct bnx2x *bp, u32 state)
 			if (IS_MF(bp))
 				bnx2x_link_sync_notify(bp);
 
-			bnx2x_dcbx_stop_hw_tx(bp);
+			set_bit(BNX2X_SP_RTNL_TX_STOP, &bp->sp_rtnl_state);
+
+			schedule_delayed_work(&bp->sp_rtnl_task, 0);
 
 			return;
 		}
@@ -757,7 +779,9 @@ void bnx2x_dcbx_set_params(struct bnx2x *bp, u32 state)
 		/* ets may affect cmng configuration: reinit it in hw */
 		bnx2x_set_local_cmng(bp);
 
-		bnx2x_dcbx_resume_hw_tx(bp);
+		set_bit(BNX2X_SP_RTNL_TX_RESUME, &bp->sp_rtnl_state);
+
+		schedule_delayed_work(&bp->sp_rtnl_task, 0);
 
 		return;
 	case BNX2X_DCBX_STATE_TX_RELEASED:
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h
index 125bd1b..804b8f6 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h
@@ -199,4 +199,7 @@ extern const struct dcbnl_rtnl_ops bnx2x_dcbnl_ops;
 int bnx2x_dcbnl_update_applist(struct bnx2x *bp, bool delall);
 #endif /* BCM_DCBNL */
 
+int bnx2x_dcbx_stop_hw_tx(struct bnx2x *bp);
+int bnx2x_dcbx_resume_hw_tx(struct bnx2x *bp);
+
 #endif /* BNX2X_DCB_H */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index c009f19..b8d7c3b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -9655,6 +9655,12 @@ sp_rtnl_not_reset:
 			       &bp->sp_rtnl_state))
 		bnx2x_pf_set_vfs_vlan(bp);
 
+	if (test_and_clear_bit(BNX2X_SP_RTNL_TX_STOP, &bp->sp_rtnl_state))
+		bnx2x_dcbx_stop_hw_tx(bp);
+
+	if (test_and_clear_bit(BNX2X_SP_RTNL_TX_RESUME, &bp->sp_rtnl_state))
+		bnx2x_dcbx_resume_hw_tx(bp);
+
 	/* work which needs rtnl lock not-taken (as it takes the lock itself and
 	 * can be called from other contexts as well)
 	 */
-- 
1.8.1.227.g44fe835
