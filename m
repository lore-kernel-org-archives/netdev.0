From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 1/2] cxgb4: Move offload Rx queue allocation to separate function
Date: Wed,  4 Mar 2015 18:16:27 +0530
Message-ID: <1425473188-13346-2-git-send-email-hariprasad@chelsio.com>
References: <1425473188-13346-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com,
	swise@opengridcomputing.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:28370 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758956AbbCDMlA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 07:41:00 -0500
In-Reply-To: <1425473188-13346-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds a common function for all Rx queue allocation.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   73 +++++++++++------------
 1 files changed, 35 insertions(+), 38 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index a22cf93..836e411 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -957,6 +957,28 @@ static void enable_rx(struct adapter *adap)
 	}
 }
 
+static int alloc_ofld_rxqs(struct adapter *adap, struct sge_ofld_rxq *q,
+			   unsigned int nq, unsigned int per_chan, int msi_idx,
+			   u16 *ids)
+{
+	int i, err;
+
+	for (i = 0; i < nq; i++, q++) {
+		if (msi_idx > 0)
+			msi_idx++;
+		err = t4_sge_alloc_rxq(adap, &q->rspq, false,
+				       adap->port[i / per_chan],
+				       msi_idx, q->fl.size ? &q->fl : NULL,
+				       uldrx_handler);
+		if (err)
+			return err;
+		memset(&q->stats, 0, sizeof(q->stats));
+		if (ids)
+			ids[i] = q->rspq.abs_id;
+	}
+	return 0;
+}
+
 /**
  *	setup_sge_queues - configure SGE Tx/Rx/response queues
  *	@adap: the adapter
@@ -1018,51 +1040,26 @@ freeout:	t4_free_sge_resources(adap);
 
 	j = s->ofldqsets / adap->params.nports; /* ofld queues per channel */
 	for_each_ofldrxq(s, i) {
-		struct sge_ofld_rxq *q = &s->ofldrxq[i];
-		struct net_device *dev = adap->port[i / j];
-
-		if (msi_idx > 0)
-			msi_idx++;
-		err = t4_sge_alloc_rxq(adap, &q->rspq, false, dev, msi_idx,
-				       q->fl.size ? &q->fl : NULL,
-				       uldrx_handler);
-		if (err)
-			goto freeout;
-		memset(&q->stats, 0, sizeof(q->stats));
-		s->ofld_rxq[i] = q->rspq.abs_id;
-		err = t4_sge_alloc_ofld_txq(adap, &s->ofldtxq[i], dev,
+		err = t4_sge_alloc_ofld_txq(adap, &s->ofldtxq[i],
+					    adap->port[i / j],
 					    s->fw_evtq.cntxt_id);
 		if (err)
 			goto freeout;
 	}
 
-	for_each_rdmarxq(s, i) {
-		struct sge_ofld_rxq *q = &s->rdmarxq[i];
+#define ALLOC_OFLD_RXQS(firstq, nq, per_chan, ids) do { \
+	err = alloc_ofld_rxqs(adap, firstq, nq, per_chan, msi_idx, ids); \
+	if (err) \
+		goto freeout; \
+	if (msi_idx > 0) \
+		msi_idx += nq; \
+} while (0)
 
-		if (msi_idx > 0)
-			msi_idx++;
-		err = t4_sge_alloc_rxq(adap, &q->rspq, false, adap->port[i],
-				       msi_idx, q->fl.size ? &q->fl : NULL,
-				       uldrx_handler);
-		if (err)
-			goto freeout;
-		memset(&q->stats, 0, sizeof(q->stats));
-		s->rdma_rxq[i] = q->rspq.abs_id;
-	}
+	ALLOC_OFLD_RXQS(s->ofldrxq, s->ofldqsets, j, s->ofld_rxq);
+	ALLOC_OFLD_RXQS(s->rdmarxq, s->rdmaqs, 1, s->rdma_rxq);
+	ALLOC_OFLD_RXQS(s->rdmaciq, s->rdmaciqs, 1, s->rdma_ciq);
 
-	for_each_rdmaciq(s, i) {
-		struct sge_ofld_rxq *q = &s->rdmaciq[i];
-
-		if (msi_idx > 0)
-			msi_idx++;
-		err = t4_sge_alloc_rxq(adap, &q->rspq, false, adap->port[i],
-				       msi_idx, q->fl.size ? &q->fl : NULL,
-				       uldrx_handler);
-		if (err)
-			goto freeout;
-		memset(&q->stats, 0, sizeof(q->stats));
-		s->rdma_ciq[i] = q->rspq.abs_id;
-	}
+#undef ALLOC_OFLD_RXQS
 
 	for_each_port(adap, i) {
 		/*
-- 
1.7.1
