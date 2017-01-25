From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 3/3] bnxt_en: Fix RTNL lock usage on bnxt_get_port_module_status().
Date: Wed, 25 Jan 2017 02:55:09 -0500
Message-ID: <1485330909-12037-4-git-send-email-michael.chan@broadcom.com>
References: <1485330909-12037-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:33282 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751338AbdAYHzX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 02:55:23 -0500
Received: by mail-pf0-f177.google.com with SMTP id y143so56660825pfb.0
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 23:55:22 -0800 (PST)
In-Reply-To: <1485330909-12037-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bnxt_get_port_module_status() calls bnxt_update_link() which expects
RTNL to be held.  In bnxt_sp_task() that does not hold RTNL, we need to
call it with a prior call to bnxt_rtnl_lock_sp() and the call needs to
be moved to the end of bnxt_sp_task().

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 69b0fce..4fcc6a8 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -6259,9 +6259,6 @@ static void bnxt_sp_task(struct work_struct *work)
 		bnxt_hwrm_tunnel_dst_port_free(
 			bp, TUNNEL_DST_PORT_FREE_REQ_TUNNEL_TYPE_GENEVE);
 	}
-	if (test_and_clear_bit(BNXT_HWRM_PORT_MODULE_SP_EVENT, &bp->sp_event))
-		bnxt_get_port_module_status(bp);
-
 	if (test_and_clear_bit(BNXT_PERIODIC_STATS_SP_EVENT, &bp->sp_event))
 		bnxt_hwrm_port_qstats(bp);
 
@@ -6283,6 +6280,12 @@ static void bnxt_sp_task(struct work_struct *work)
 			netdev_err(bp->dev, "SP task can't update link (rc: %x)\n",
 				   rc);
 	}
+	if (test_and_clear_bit(BNXT_HWRM_PORT_MODULE_SP_EVENT, &bp->sp_event)) {
+		bnxt_rtnl_lock_sp(bp);
+		if (test_bit(BNXT_STATE_OPEN, &bp->state))
+			bnxt_get_port_module_status(bp);
+		bnxt_rtnl_unlock_sp(bp);
+	}
 	if (test_and_clear_bit(BNXT_RESET_TASK_SP_EVENT, &bp->sp_event))
 		bnxt_reset(bp, false);
 
-- 
1.8.3.1
