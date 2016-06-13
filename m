From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 02/11] bnxt_en: Add new function bnxt_reset().
Date: Mon, 13 Jun 2016 02:25:29 -0400
Message-ID: <1465799138-27529-3-git-send-email-michael.chan@broadcom.com>
References: <1465799138-27529-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34608 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964808AbcFMGZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 02:25:54 -0400
Received: by mail-pa0-f53.google.com with SMTP id bz2so42650886pad.1
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2016 23:25:53 -0700 (PDT)
In-Reply-To: <1465799138-27529-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a default VLAN is added to the VF, the VF driver needs to reset to
pick up the default VLAN ID.  We can use the same tx timeout reset logic
to do that, without the debug output.  This new function, with the
silent parameter to suppress debug output will now serve both purposes.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 34 ++++++++++++++++++++-----------
 1 file changed, 22 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 67608d5..e30c43b 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -5628,9 +5628,10 @@ static void bnxt_dbg_dump_states(struct bnxt *bp)
 	}
 }
 
-static void bnxt_reset_task(struct bnxt *bp)
+static void bnxt_reset_task(struct bnxt *bp, bool silent)
 {
-	bnxt_dbg_dump_states(bp);
+	if (!silent)
+		bnxt_dbg_dump_states(bp);
 	if (netif_running(bp->dev)) {
 		bnxt_close_nic(bp, false, false);
 		bnxt_open_nic(bp, false, false);
@@ -5681,6 +5682,23 @@ bnxt_restart_timer:
 	mod_timer(&bp->timer, jiffies + bp->current_interval);
 }
 
+/* Only called from bnxt_sp_task() */
+static void bnxt_reset(struct bnxt *bp, bool silent)
+{
+	/* bnxt_reset_task() calls bnxt_close_nic() which waits
+	 * for BNXT_STATE_IN_SP_TASK to clear.
+	 * If there is a parallel dev_close(), bnxt_close() may be holding
+	 * rtnl() and waiting for BNXT_STATE_IN_SP_TASK to clear.  So we
+	 * must clear BNXT_STATE_IN_SP_TASK before holding rtnl().
+	 */
+	clear_bit(BNXT_STATE_IN_SP_TASK, &bp->state);
+	rtnl_lock();
+	if (test_bit(BNXT_STATE_OPEN, &bp->state))
+		bnxt_reset_task(bp, silent);
+	set_bit(BNXT_STATE_IN_SP_TASK, &bp->state);
+	rtnl_unlock();
+}
+
 static void bnxt_cfg_ntp_filters(struct bnxt *);
 
 static void bnxt_sp_task(struct work_struct *work)
@@ -5717,16 +5735,8 @@ static void bnxt_sp_task(struct work_struct *work)
 		bnxt_hwrm_tunnel_dst_port_free(
 			bp, TUNNEL_DST_PORT_FREE_REQ_TUNNEL_TYPE_VXLAN);
 	}
-	if (test_and_clear_bit(BNXT_RESET_TASK_SP_EVENT, &bp->sp_event)) {
-		/* bnxt_reset_task() calls bnxt_close_nic() which waits
-		 * for BNXT_STATE_IN_SP_TASK to clear.
-		 */
-		clear_bit(BNXT_STATE_IN_SP_TASK, &bp->state);
-		rtnl_lock();
-		bnxt_reset_task(bp);
-		set_bit(BNXT_STATE_IN_SP_TASK, &bp->state);
-		rtnl_unlock();
-	}
+	if (test_and_clear_bit(BNXT_RESET_TASK_SP_EVENT, &bp->sp_event))
+		bnxt_reset(bp, false);
 
 	if (test_and_clear_bit(BNXT_HWRM_PORT_MODULE_SP_EVENT, &bp->sp_event))
 		bnxt_get_port_module_status(bp);
-- 
1.8.3.1
