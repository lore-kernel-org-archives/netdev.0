From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net v2 4/4] bnxt_en: Implement missing tx timeout reset logic.
Date: Wed, 9 Dec 2015 19:35:44 -0500
Message-ID: <1449707744-7844-5-git-send-email-mchan@broadcom.com>
References: <1449707744-7844-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:47318 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752864AbbLJAfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 19:35:55 -0500
In-Reply-To: <1449707744-7844-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The reset logic calls bnxt_close_nic() and bnxt_open_nic() under rtnl_lock
from bnxt_sp_task.  BNXT_STATE_IN_SP_TASK must be cleared before calling
bnxt_close_nic() to avoid deadlock.

v2: Fixed white space error.  Thanks Dave.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index f5f4489..0c2c3f5 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -5031,8 +5031,10 @@ static void bnxt_dbg_dump_states(struct bnxt *bp)
 static void bnxt_reset_task(struct bnxt *bp)
 {
 	bnxt_dbg_dump_states(bp);
-	if (netif_running(bp->dev))
-		bnxt_tx_disable(bp); /* prevent tx timout again */
+	if (netif_running(bp->dev)) {
+		bnxt_close_nic(bp, false, false);
+		bnxt_open_nic(bp, false, false);
+	}
 }
 
 static void bnxt_tx_timeout(struct net_device *dev)
@@ -5111,8 +5113,16 @@ static void bnxt_sp_task(struct work_struct *work)
 		bnxt_hwrm_tunnel_dst_port_free(
 			bp, TUNNEL_DST_PORT_FREE_REQ_TUNNEL_TYPE_VXLAN);
 	}
-	if (test_and_clear_bit(BNXT_RESET_TASK_SP_EVENT, &bp->sp_event))
-		bnxt_reset_task(bp);
+	if (test_and_clear_bit(BNXT_RESET_TASK_SP_EVENT, &bp->sp_event)) {
+		/* bnxt_reset_task() calls bnxt_close_nic() which waits
+		 * for BNXT_STATE_IN_SP_TASK to clear.
+		 */
+		clear_bit(BNXT_STATE_IN_SP_TASK, &bp->state);
+		rtnl_lock();
+		bnxt_reset_task(bp);
+		set_bit(BNXT_STATE_IN_SP_TASK, &bp->state);
+		rtnl_unlock();
+	}
 
 	smp_mb__before_atomic();
 	clear_bit(BNXT_STATE_IN_SP_TASK, &bp->state);
-- 
1.8.3.1
