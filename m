From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net-next 2/5] qede: qede_poll refactoring
Date: Thu, 30 Jun 2016 02:35:19 -0400
Message-ID: <1467268522-24589-3-git-send-email-manish.chopra@qlogic.com>
References: <1467268522-24589-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:34726 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751695AbcF3HTv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 03:19:51 -0400
In-Reply-To: <1467268522-24589-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch cleanups qede_poll() routine a bit
and allows qede_poll() to do single iteration to handle
TX completion [As under heavy TX load qede_poll() might
run for indefinite time in the while(1) loop for TX
completion processing and cause CPU stuck].

Signed-off-by: Manish <manish.chopra@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede_main.c | 77 +++++++++++++---------------
 1 file changed, 35 insertions(+), 42 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index f476cd0..ab811e2 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -1597,56 +1597,49 @@ next_cqe: /* don't consume bd rx buffer */
 
 static int qede_poll(struct napi_struct *napi, int budget)
 {
-	int work_done = 0;
 	struct qede_fastpath *fp = container_of(napi, struct qede_fastpath,
-						 napi);
+						napi);
 	struct qede_dev *edev = fp->edev;
+	int rx_work_done = 0;
+	u8 tc;
 
-	while (1) {
-		u8 tc;
-
-		for (tc = 0; tc < edev->num_tc; tc++)
-			if (qede_txq_has_work(&fp->txqs[tc]))
-				qede_tx_int(edev, &fp->txqs[tc]);
-
-		if (qede_has_rx_work(fp->rxq)) {
-			work_done += qede_rx_int(fp, budget - work_done);
-
-			/* must not complete if we consumed full budget */
-			if (work_done >= budget)
-				break;
-		}
+	for (tc = 0; tc < edev->num_tc; tc++)
+		if (qede_txq_has_work(&fp->txqs[tc]))
+			qede_tx_int(edev, &fp->txqs[tc]);
+
+	rx_work_done = qede_has_rx_work(fp->rxq) ?
+			qede_rx_int(fp, budget) : 0;
+	if (rx_work_done < budget) {
+		qed_sb_update_sb_idx(fp->sb_info);
+		/* *_has_*_work() reads the status block,
+		 * thus we need to ensure that status block indices
+		 * have been actually read (qed_sb_update_sb_idx)
+		 * prior to this check (*_has_*_work) so that
+		 * we won't write the "newer" value of the status block
+		 * to HW (if there was a DMA right after
+		 * qede_has_rx_work and if there is no rmb, the memory
+		 * reading (qed_sb_update_sb_idx) may be postponed
+		 * to right before *_ack_sb). In this case there
+		 * will never be another interrupt until there is
+		 * another update of the status block, while there
+		 * is still unhandled work.
+		 */
+		rmb();
 
 		/* Fall out from the NAPI loop if needed */
-		if (!(qede_has_rx_work(fp->rxq) || qede_has_tx_work(fp))) {
-			qed_sb_update_sb_idx(fp->sb_info);
-			/* *_has_*_work() reads the status block,
-			 * thus we need to ensure that status block indices
-			 * have been actually read (qed_sb_update_sb_idx)
-			 * prior to this check (*_has_*_work) so that
-			 * we won't write the "newer" value of the status block
-			 * to HW (if there was a DMA right after
-			 * qede_has_rx_work and if there is no rmb, the memory
-			 * reading (qed_sb_update_sb_idx) may be postponed
-			 * to right before *_ack_sb). In this case there
-			 * will never be another interrupt until there is
-			 * another update of the status block, while there
-			 * is still unhandled work.
-			 */
-			rmb();
-
-			if (!(qede_has_rx_work(fp->rxq) ||
-			      qede_has_tx_work(fp))) {
-				napi_complete(napi);
-				/* Update and reenable interrupts */
-				qed_sb_ack(fp->sb_info, IGU_INT_ENABLE,
-					   1 /*update*/);
-				break;
-			}
+		if (!(qede_has_rx_work(fp->rxq) ||
+		      qede_has_tx_work(fp))) {
+			napi_complete(napi);
+
+			/* Update and reenable interrupts */
+			qed_sb_ack(fp->sb_info, IGU_INT_ENABLE,
+				   1 /*update*/);
+		} else {
+			rx_work_done = budget;
 		}
 	}
 
-	return work_done;
+	return rx_work_done;
 }
 
 static irqreturn_t qede_msix_fp_int(int irq, void *fp_cookie)
-- 
2.7.2
