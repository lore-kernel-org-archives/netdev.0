From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 2/3] bnxt_en: Fix RTNL lock usage on bnxt_update_link().
Date: Wed, 25 Jan 2017 02:55:08 -0500
Message-ID: <1485330909-12037-3-git-send-email-michael.chan@broadcom.com>
References: <1485330909-12037-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:35000 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751323AbdAYHzW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 02:55:22 -0500
Received: by mail-pf0-f172.google.com with SMTP id f144so56660620pfa.2
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 23:55:21 -0800 (PST)
In-Reply-To: <1485330909-12037-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bnxt_update_link() is called from multiple code paths.  Most callers,
such as open, ethtool, already hold RTNL.  Only the caller bnxt_sp_task()
does not.  So it is a bug to take RTNL inside bnxt_update_link().

Fix it by removing the RTNL inside bnxt_update_link().  The function
now expects the caller to always hold RTNL.

In bnxt_sp_task(), call bnxt_rtnl_lock_sp() before calling
bnxt_update_link().  We also need to move the call to the end of
bnxt_sp_task() since it will be clearing the BNXT_STATE_IN_SP_TASK bit.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 37 +++++++++++++++----------------
 1 file changed, 18 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 30d7d64..69b0fce 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -5314,17 +5314,12 @@ static int bnxt_update_link(struct bnxt *bp, bool chng_link_state)
 	if ((link_info->support_auto_speeds | diff) !=
 	    link_info->support_auto_speeds) {
 		/* An advertised speed is no longer supported, so we need to
-		 * update the advertisement settings.  See bnxt_reset() for
-		 * comments about the rtnl_lock() sequence below.
+		 * update the advertisement settings.  Caller holds RTNL
+		 * so we can modify link settings.
 		 */
-		clear_bit(BNXT_STATE_IN_SP_TASK, &bp->state);
-		rtnl_lock();
 		link_info->advertising = link_info->support_auto_speeds;
-		if (test_bit(BNXT_STATE_OPEN, &bp->state) &&
-		    (link_info->autoneg & BNXT_AUTONEG_SPEED))
+		if (link_info->autoneg & BNXT_AUTONEG_SPEED)
 			bnxt_hwrm_set_link_setting(bp, true, false);
-		set_bit(BNXT_STATE_IN_SP_TASK, &bp->state);
-		rtnl_unlock();
 	}
 	return 0;
 }
@@ -6231,7 +6226,6 @@ static void bnxt_reset(struct bnxt *bp, bool silent)
 static void bnxt_sp_task(struct work_struct *work)
 {
 	struct bnxt *bp = container_of(work, struct bnxt, sp_task);
-	int rc;
 
 	set_bit(BNXT_STATE_IN_SP_TASK, &bp->state);
 	smp_mb__after_atomic();
@@ -6245,16 +6239,6 @@ static void bnxt_sp_task(struct work_struct *work)
 
 	if (test_and_clear_bit(BNXT_RX_NTP_FLTR_SP_EVENT, &bp->sp_event))
 		bnxt_cfg_ntp_filters(bp);
-	if (test_and_clear_bit(BNXT_LINK_CHNG_SP_EVENT, &bp->sp_event)) {
-		if (test_and_clear_bit(BNXT_LINK_SPEED_CHNG_SP_EVENT,
-				       &bp->sp_event))
-			bnxt_hwrm_phy_qcaps(bp);
-
-		rc = bnxt_update_link(bp, true);
-		if (rc)
-			netdev_err(bp->dev, "SP task can't update link (rc: %x)\n",
-				   rc);
-	}
 	if (test_and_clear_bit(BNXT_HWRM_EXEC_FWD_REQ_SP_EVENT, &bp->sp_event))
 		bnxt_hwrm_exec_fwd_req(bp);
 	if (test_and_clear_bit(BNXT_VXLAN_ADD_PORT_SP_EVENT, &bp->sp_event)) {
@@ -6284,6 +6268,21 @@ static void bnxt_sp_task(struct work_struct *work)
 	/* These functions below will clear BNXT_STATE_IN_SP_TASK.  They
 	 * must be the last functions to be called before exiting.
 	 */
+	if (test_and_clear_bit(BNXT_LINK_CHNG_SP_EVENT, &bp->sp_event)) {
+		int rc = 0;
+
+		if (test_and_clear_bit(BNXT_LINK_SPEED_CHNG_SP_EVENT,
+				       &bp->sp_event))
+			bnxt_hwrm_phy_qcaps(bp);
+
+		bnxt_rtnl_lock_sp(bp);
+		if (test_bit(BNXT_STATE_OPEN, &bp->state))
+			rc = bnxt_update_link(bp, true);
+		bnxt_rtnl_unlock_sp(bp);
+		if (rc)
+			netdev_err(bp->dev, "SP task can't update link (rc: %x)\n",
+				   rc);
+	}
 	if (test_and_clear_bit(BNXT_RESET_TASK_SP_EVENT, &bp->sp_event))
 		bnxt_reset(bp, false);
 
-- 
1.8.3.1
