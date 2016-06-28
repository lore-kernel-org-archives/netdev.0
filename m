From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Subject: [PATCH net 1/1] qed: Protect the doorbell BAR with the write barriers.
Date: Tue, 28 Jun 2016 07:46:03 -0400
Message-ID: <1467114363-16948-1-git-send-email-sudarsana.kalluru@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@qlogic.com>,
	<sudarsana.kalluru@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:16728 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753009AbcF1Mad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 08:30:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SPQ doorbell is currently protected with the compilation barrier. Under the
stress scenarios, we may get into a state where (due to the weak ordering)
several ramrod doorbells were written to the BAR with an out-of-order
producer values. Need to change the barrier type to a write barrier to make
sure that the write buffer is flushed after each doorbell.

Signed-off-by: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_spq.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_spq.c b/drivers/net/ethernet/qlogic/qed/qed_spq.c
index 67d9893..b122f60 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_spq.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_spq.c
@@ -213,19 +213,15 @@ static int qed_spq_hw_post(struct qed_hwfn *p_hwfn,
 	SET_FIELD(db.params, CORE_DB_DATA_AGG_VAL_SEL,
 		  DQ_XCM_CORE_SPQ_PROD_CMD);
 	db.agg_flags = DQ_XCM_CORE_DQ_CF_CMD;
-
-	/* validate producer is up to-date */
-	rmb();
-
 	db.spq_prod = cpu_to_le16(qed_chain_get_prod_idx(p_chain));
 
-	/* do not reorder */
-	barrier();
+	/* make sure the SPQE is updated before the doorbell */
+	wmb();
 
 	DOORBELL(p_hwfn, qed_db_addr(p_spq->cid, DQ_DEMS_LEGACY), *(u32 *)&db);
 
 	/* make sure doorbell is rang */
-	mmiowb();
+	wmb();
 
 	DP_VERBOSE(p_hwfn, QED_MSG_SPQ,
 		   "Doorbelled [0x%08x, CID 0x%08x] with Flags: %02x agg_params: %02x, prod: %04x\n",
-- 
1.8.3.1
