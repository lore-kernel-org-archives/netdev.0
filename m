From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] bnx2x: avoid soft lockup in bnx2x_poll()
Date: Tue, 08 Dec 2015 05:54:40 -0800
Message-ID: <1449582880.7632.19.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:32830 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964804AbbLHNym (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 08:54:42 -0500
Received: by pabur14 with SMTP id ur14so12571611pab.0
        for <netdev@vger.kernel.org>; Tue, 08 Dec 2015 05:54:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Under heavy TX load, bnx2x_poll() can loop forever and trigger
soft lockup bugs.

A napi poll handler must yield after one TX completion round,
risk of livelock is too high otherwise.

Bug is very easy to trigger using a debug build, and udp flood, because
of added cpu cycles in TX completion, and we do not receive enough
packets to break the loop.

Reported-by: Willem de Bruijn <willemb@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Ariel Elior <ariel.elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |   51 +++++---------
 1 file changed, 21 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index f6634a524153..d7cc2aa7c37a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -3204,42 +3204,32 @@ int bnx2x_set_power_state(struct bnx2x *bp, pci_power_t state)
  */
 static int bnx2x_poll(struct napi_struct *napi, int budget)
 {
-	int work_done = 0;
-	u8 cos;
 	struct bnx2x_fastpath *fp = container_of(napi, struct bnx2x_fastpath,
 						 napi);
 	struct bnx2x *bp = fp->bp;
+	int rx_work_done;
+	u8 cos;
 
-	while (1) {
 #ifdef BNX2X_STOP_ON_ERROR
-		if (unlikely(bp->panic)) {
-			napi_complete(napi);
-			return 0;
-		}
+	if (unlikely(bp->panic)) {
+		napi_complete(napi);
+		return 0;
+	}
 #endif
-		for_each_cos_in_tx_queue(fp, cos)
-			if (bnx2x_tx_queue_has_work(fp->txdata_ptr[cos]))
-				bnx2x_tx_int(bp, fp->txdata_ptr[cos]);
-
-		if (bnx2x_has_rx_work(fp)) {
-			work_done += bnx2x_rx_int(fp, budget - work_done);
-
-			/* must not complete if we consumed full budget */
-			if (work_done >= budget)
-				break;
-		}
+	for_each_cos_in_tx_queue(fp, cos)
+		if (bnx2x_tx_queue_has_work(fp->txdata_ptr[cos]))
+			bnx2x_tx_int(bp, fp->txdata_ptr[cos]);
 
-		/* Fall out from the NAPI loop if needed */
-		if (!(bnx2x_has_rx_work(fp) || bnx2x_has_tx_work(fp))) {
+	rx_work_done = (bnx2x_has_rx_work(fp)) ? bnx2x_rx_int(fp, budget) : 0;
 
-			/* No need to update SB for FCoE L2 ring as long as
-			 * it's connected to the default SB and the SB
-			 * has been updated when NAPI was scheduled.
-			 */
-			if (IS_FCOE_FP(fp)) {
-				napi_complete(napi);
-				break;
-			}
+	if (rx_work_done < budget) {
+		/* No need to update SB for FCoE L2 ring as long as
+		 * it's connected to the default SB and the SB
+		 * has been updated when NAPI was scheduled.
+		 */
+		if (IS_FCOE_FP(fp)) {
+			napi_complete(napi);
+		} else {
 			bnx2x_update_fpsb_idx(fp);
 			/* bnx2x_has_rx_work() reads the status block,
 			 * thus we need to ensure that status block indices
@@ -3264,12 +3254,13 @@ static int bnx2x_poll(struct napi_struct *napi, int budget)
 				bnx2x_ack_sb(bp, fp->igu_sb_id, USTORM_ID,
 					     le16_to_cpu(fp->fp_hc_idx),
 					     IGU_INT_ENABLE, 1);
-				break;
+			} else {
+				rx_work_done = budget;
 			}
 		}
 	}
 
-	return work_done;
+	return rx_work_done;
 }
 
 /* we split the first BD into headers and data BDs
