From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next] cxgb4vf: Fix check to use new User Doorbell mechanism
Date: Thu,  9 Jul 2015 14:55:46 +0530
Message-ID: <1436433946-10735-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:10036 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750791AbbGIEM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 00:12:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we don't have access to the new User GTS (T5+), use the old doorbell
mechanism; otherwise use the new BAR2 mechanism.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index ad53e5a..1d5e77a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -1898,7 +1898,10 @@ static int napi_rx_handler(struct napi_struct *napi, int budget)
 		rspq->unhandled_irqs++;
 
 	val = CIDXINC_V(work_done) | SEINTARM_V(intr_params);
-	if (is_t4(rspq->adapter->params.chip)) {
+	/* If we don't have access to the new User GTS (T5+), use the old
+	 * doorbell mechanism; otherwise use the new BAR2 mechanism.
+	 */
+	if (unlikely(!rspq->bar2_addr)) {
 		t4_write_reg(rspq->adapter,
 			     T4VF_SGE_BASE_ADDR + SGE_VF_GTS,
 			     val | INGRESSQID_V((u32)rspq->cntxt_id));
@@ -1998,10 +2001,13 @@ static unsigned int process_intrq(struct adapter *adapter)
 	}
 
 	val = CIDXINC_V(work_done) | SEINTARM_V(intrq->intr_params);
-	if (is_t4(adapter->params.chip))
+	/* If we don't have access to the new User GTS (T5+), use the old
+	 * doorbell mechanism; otherwise use the new BAR2 mechanism.
+	 */
+	if (unlikely(!intrq->bar2_addr)) {
 		t4_write_reg(adapter, T4VF_SGE_BASE_ADDR + SGE_VF_GTS,
 			     val | INGRESSQID_V(intrq->cntxt_id));
-	else {
+	} else {
 		writel(val | INGRESSQID_V(intrq->bar2_qid),
 		       intrq->bar2_addr + SGE_UDB_GTS);
 		wmb();
-- 
2.3.4
