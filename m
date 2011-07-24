From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH 5/6] bnx2x: fix bnx2x_stop_on_error flow in
 bnx2x_sp_rtnl_task
Date: Sun, 24 Jul 2011 16:57:46 +0300
Message-ID: <1311515866.23243.8.camel@lb-tlvb-dmitry>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Vladislav Zolotarov" <vladz@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4917 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752592Ab1GXOLF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Jul 2011 10:11:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Zolotarov <vladz@broadcom.com>


Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_main.c |   36 +++++++++++++++++++++++++-----------
 1 files changed, 25 insertions(+), 11 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 9c62092..475f66f 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -8413,31 +8413,45 @@ static void bnx2x_sp_rtnl_task(struct work_struct *work)
 	if (!netif_running(bp->dev))
 		goto sp_rtnl_exit;
 
-	if (test_and_clear_bit(BNX2X_SP_RTNL_SETUP_TC, &bp->sp_rtnl_state))
-		bnx2x_setup_tc(bp->dev, bp->dcbx_port_params.ets.num_of_cos);
-
 	/* if stop on error is defined no recovery flows should be executed */
 #ifdef BNX2X_STOP_ON_ERROR
 	BNX2X_ERR("recovery flow called but STOP_ON_ERROR defined "
 		  "so reset not done to allow debug dump,\n"
 		  "you will need to reboot when done\n");
-	goto sp_rtnl_exit;
+	goto sp_rtnl_not_reset;
 #endif
 
 	if (unlikely(bp->recovery_state != BNX2X_RECOVERY_DONE)) {
 		/*
-		 * Clear TX_TIMEOUT bit as we are going to reset the function
-		 * anyway.
+		 * Clear all pending SP commands as we are going to reset the
+		 * function anyway.
 		 */
-		smp_mb__before_clear_bit();
-		clear_bit(BNX2X_SP_RTNL_TX_TIMEOUT, &bp->sp_rtnl_state);
-		smp_mb__after_clear_bit();
+		bp->sp_rtnl_state = 0;
+		smp_mb();
+
 		bnx2x_parity_recover(bp);
-	} else if (test_and_clear_bit(BNX2X_SP_RTNL_TX_TIMEOUT,
-				    &bp->sp_rtnl_state)){
+
+		goto sp_rtnl_exit;
+	}
+
+	if (test_and_clear_bit(BNX2X_SP_RTNL_TX_TIMEOUT, &bp->sp_rtnl_state)) {
+		/*
+		 * Clear all pending SP commands as we are going to reset the
+		 * function anyway.
+		 */
+		bp->sp_rtnl_state = 0;
+		smp_mb();
+
 		bnx2x_nic_unload(bp, UNLOAD_NORMAL);
 		bnx2x_nic_load(bp, LOAD_NORMAL);
+
+		goto sp_rtnl_exit;
 	}
+#ifdef BNX2X_STOP_ON_ERROR
+sp_rtnl_not_reset:
+#endif
+	if (test_and_clear_bit(BNX2X_SP_RTNL_SETUP_TC, &bp->sp_rtnl_state))
+		bnx2x_setup_tc(bp->dev, bp->dcbx_port_params.ets.num_of_cos);
 
 sp_rtnl_exit:
 	rtnl_unlock();
-- 
1.7.2.2




