From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 1/3] bnxt_en: Fix bnxt_reset() in the slow path task.
Date: Wed, 25 Jan 2017 02:55:07 -0500
Message-ID: <1485330909-12037-2-git-send-email-michael.chan@broadcom.com>
References: <1485330909-12037-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:34149 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751297AbdAYHzV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 02:55:21 -0500
Received: by mail-pg0-f44.google.com with SMTP id 14so62546525pgg.1
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 23:55:21 -0800 (PST)
In-Reply-To: <1485330909-12037-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In bnxt_sp_task(), we set a bit BNXT_STATE_IN_SP_TASK so that bnxt_close()
will synchronize and wait for bnxt_sp_task() to finish.  Some functions
in bnxt_sp_task() require us to clear BNXT_STATE_IN_SP_TASK and then
acquire rtnl_lock() to prevent race conditions.

There are some bugs related to this logic. This patch refactors the code
to have common bnxt_rtnl_lock_sp() and bnxt_rtnl_unlock_sp() to handle
the RTNL and the clearing/setting of the bit.  Multiple functions will
need the same logic.  We also need to move bnxt_reset() to the end of
bnxt_sp_task().  Functions that clear BNXT_STATE_IN_SP_TASK must be the
last functions to be called in bnxt_sp_task().  The common scheme will
handle the condition properly.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 38 ++++++++++++++++++++-----------
 1 file changed, 25 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 53e686f..30d7d64 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -6200,23 +6200,32 @@ static void bnxt_timer(unsigned long data)
 	mod_timer(&bp->timer, jiffies + bp->current_interval);
 }
 
-/* Only called from bnxt_sp_task() */
-static void bnxt_reset(struct bnxt *bp, bool silent)
+static void bnxt_rtnl_lock_sp(struct bnxt *bp)
 {
-	/* bnxt_reset_task() calls bnxt_close_nic() which waits
-	 * for BNXT_STATE_IN_SP_TASK to clear.
-	 * If there is a parallel dev_close(), bnxt_close() may be holding
+	/* We are called from bnxt_sp_task which has BNXT_STATE_IN_SP_TASK
+	 * set.  If the device is being closed, bnxt_close() may be holding
 	 * rtnl() and waiting for BNXT_STATE_IN_SP_TASK to clear.  So we
 	 * must clear BNXT_STATE_IN_SP_TASK before holding rtnl().
 	 */
 	clear_bit(BNXT_STATE_IN_SP_TASK, &bp->state);
 	rtnl_lock();
-	if (test_bit(BNXT_STATE_OPEN, &bp->state))
-		bnxt_reset_task(bp, silent);
+}
+
+static void bnxt_rtnl_unlock_sp(struct bnxt *bp)
+{
 	set_bit(BNXT_STATE_IN_SP_TASK, &bp->state);
 	rtnl_unlock();
 }
 
+/* Only called from bnxt_sp_task() */
+static void bnxt_reset(struct bnxt *bp, bool silent)
+{
+	bnxt_rtnl_lock_sp(bp);
+	if (test_bit(BNXT_STATE_OPEN, &bp->state))
+		bnxt_reset_task(bp, silent);
+	bnxt_rtnl_unlock_sp(bp);
+}
+
 static void bnxt_cfg_ntp_filters(struct bnxt *);
 
 static void bnxt_sp_task(struct work_struct *work)
@@ -6266,18 +6275,21 @@ static void bnxt_sp_task(struct work_struct *work)
 		bnxt_hwrm_tunnel_dst_port_free(
 			bp, TUNNEL_DST_PORT_FREE_REQ_TUNNEL_TYPE_GENEVE);
 	}
-	if (test_and_clear_bit(BNXT_RESET_TASK_SP_EVENT, &bp->sp_event))
-		bnxt_reset(bp, false);
-
-	if (test_and_clear_bit(BNXT_RESET_TASK_SILENT_SP_EVENT, &bp->sp_event))
-		bnxt_reset(bp, true);
-
 	if (test_and_clear_bit(BNXT_HWRM_PORT_MODULE_SP_EVENT, &bp->sp_event))
 		bnxt_get_port_module_status(bp);
 
 	if (test_and_clear_bit(BNXT_PERIODIC_STATS_SP_EVENT, &bp->sp_event))
 		bnxt_hwrm_port_qstats(bp);
 
+	/* These functions below will clear BNXT_STATE_IN_SP_TASK.  They
+	 * must be the last functions to be called before exiting.
+	 */
+	if (test_and_clear_bit(BNXT_RESET_TASK_SP_EVENT, &bp->sp_event))
+		bnxt_reset(bp, false);
+
+	if (test_and_clear_bit(BNXT_RESET_TASK_SILENT_SP_EVENT, &bp->sp_event))
+		bnxt_reset(bp, true);
+
 	smp_mb__before_atomic();
 	clear_bit(BNXT_STATE_IN_SP_TASK, &bp->state);
 }
-- 
1.8.3.1
