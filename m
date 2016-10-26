From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net] cxgb4: Fix error handling in alloc_uld_rxqs().
Date: Wed, 26 Oct 2016 13:26:38 +0530
Message-ID: <1477468598-11296-1-git-send-email-ganeshgr@chelsio.com>
Cc: hariprasad@chelsio.com, nirranjan@chelsio.com,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:59016 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752353AbcJZH4x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 03:56:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix to release resources properly in error handling path of
alloc_uld_rxqs(), This patch also removes unwanted arguments
and avoids calling the same function twice.

Fixes: 94cdb8bb993a (cxgb4: Add support for dynamic allocation
       of resources for ULD
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c | 40 ++++++++++++--------------
 1 file changed, 18 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
index 0945fa4..2471ff4 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
@@ -135,15 +135,17 @@ static int uldrx_handler(struct sge_rspq *q, const __be64 *rsp,
 }
 
 static int alloc_uld_rxqs(struct adapter *adap,
-			  struct sge_uld_rxq_info *rxq_info,
-			  unsigned int nq, unsigned int offset, bool lro)
+			  struct sge_uld_rxq_info *rxq_info, bool lro)
 {
 	struct sge *s = &adap->sge;
-	struct sge_ofld_rxq *q = rxq_info->uldrxq + offset;
-	unsigned short *ids = rxq_info->rspq_id + offset;
-	unsigned int per_chan = nq / adap->params.nports;
+	unsigned int nq = rxq_info->nrxq + rxq_info->nciq;
+	struct sge_ofld_rxq *q = rxq_info->uldrxq;
+	unsigned short *ids = rxq_info->rspq_id;
 	unsigned int bmap_idx = 0;
-	int i, err, msi_idx;
+	unsigned int per_chan;
+	int i, err, msi_idx, que_idx = 0;
+
+	per_chan = rxq_info->nrxq / adap->params.nports;
 
 	if (adap->flags & USING_MSIX)
 		msi_idx = 1;
@@ -151,12 +153,18 @@ static int alloc_uld_rxqs(struct adapter *adap,
 		msi_idx = -((int)s->intrq.abs_id + 1);
 
 	for (i = 0; i < nq; i++, q++) {
+		if (i == rxq_info->nrxq) {
+			/* start allocation of concentrator queues */
+			per_chan = rxq_info->nciq / adap->params.nports;
+			que_idx = 0;
+		}
+
 		if (msi_idx >= 0) {
 			bmap_idx = get_msix_idx_from_bmap(adap);
 			msi_idx = adap->msix_info_ulds[bmap_idx].idx;
 		}
 		err = t4_sge_alloc_rxq(adap, &q->rspq, false,
-				       adap->port[i / per_chan],
+				       adap->port[que_idx++ / per_chan],
 				       msi_idx,
 				       q->fl.size ? &q->fl : NULL,
 				       uldrx_handler,
@@ -165,29 +173,19 @@ static int alloc_uld_rxqs(struct adapter *adap,
 		if (err)
 			goto freeout;
 		if (msi_idx >= 0)
-			rxq_info->msix_tbl[i + offset] = bmap_idx;
+			rxq_info->msix_tbl[i] = bmap_idx;
 		memset(&q->stats, 0, sizeof(q->stats));
 		if (ids)
 			ids[i] = q->rspq.abs_id;
 	}
 	return 0;
 freeout:
-	q = rxq_info->uldrxq + offset;
+	q = rxq_info->uldrxq;
 	for ( ; i; i--, q++) {
 		if (q->rspq.desc)
 			free_rspq_fl(adap, &q->rspq,
 				     q->fl.size ? &q->fl : NULL);
 	}
-
-	/* We need to free rxq also in case of ciq allocation failure */
-	if (offset) {
-		q = rxq_info->uldrxq + offset;
-		for ( ; i; i--, q++) {
-			if (q->rspq.desc)
-				free_rspq_fl(adap, &q->rspq,
-					     q->fl.size ? &q->fl : NULL);
-		}
-	}
 	return err;
 }
 
@@ -205,9 +203,7 @@ setup_sge_queues_uld(struct adapter *adap, unsigned int uld_type, bool lro)
 			return -ENOMEM;
 	}
 
-	ret = !(!alloc_uld_rxqs(adap, rxq_info, rxq_info->nrxq, 0, lro) &&
-		 !alloc_uld_rxqs(adap, rxq_info, rxq_info->nciq,
-				 rxq_info->nrxq, lro));
+	ret = !(!alloc_uld_rxqs(adap, rxq_info, lro));
 
 	/* Tell uP to route control queue completions to rdma rspq */
 	if (adap->flags & FULL_INIT_DONE &&
-- 
2.1.0
