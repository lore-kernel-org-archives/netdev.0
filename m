From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 06/18] bnx2x: napi_poll budget check
Date: Mon, 02 Mar 2009 19:59:45 +0200
Message-ID: <1236016785.7723.77.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3946 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755765AbZCBSAf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 13:00:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 06/18] bnx2x: napi_poll budget check

Check the napi_poll budget only when updating it. Also add a comment to explain
the rmb

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   22 ++++++++++++++++++----
 1 files changed, 18 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index a66536e..e0851a7 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -10068,14 +10068,27 @@ static int bnx2x_poll(struct napi_struct *napi, int budget)
 	if (bnx2x_has_tx_work(fp))
 		bnx2x_tx_int(fp);
 
-	if (bnx2x_has_rx_work(fp))
+	if (bnx2x_has_rx_work(fp)) {
 		work_done = bnx2x_rx_int(fp, budget);
 
-	rmb(); /* BNX2X_HAS_WORK() reads the status block */
+		/* must not complete if we consumed full budget */
+		if (work_done >= budget)
+			goto poll_again;
+	}
 
-	/* must not complete if we consumed full budget */
-	if ((work_done < budget) && !BNX2X_HAS_WORK(fp)) {
+	/* BNX2X_HAS_WORK() reads the status block, thus we need to
+	 * ensure that status block indices have been actually read
+	 * (bnx2x_update_fpsb_idx) prior to this check (BNX2X_HAS_WORK)
+	 * so that we won't write the "newer" value of the status block to IGU
+	 * (if there was a DMA right after BNX2X_HAS_WORK and
+	 * if there is no rmb, the memory reading (bnx2x_update_fpsb_idx)
+	 * may be postponed to right before bnx2x_ack_sb). In this case
+	 * there will never be another interrupt until there is another update
+	 * of the status block, while there is still unhandled work.
+	 */
+	rmb();
 
+	if (!BNX2X_HAS_WORK(fp)) {
 #ifdef BNX2X_STOP_ON_ERROR
 poll_panic:
 #endif
@@ -10087,6 +10100,7 @@ poll_panic:
 			     le16_to_cpu(fp->fp_c_idx), IGU_INT_ENABLE, 1);
 	}
 
+poll_again:
 	return work_done;
 }
 
-- 
1.5.4.3




