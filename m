From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next] cxgb4: only free allocated fls
Date: Mon,  4 Aug 2014 17:01:30 +0530
Message-ID: <1407151890-12278-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	kumaras@chelsio.com, anish@chelsio.com,
	swise@opengridcomputing.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:57454
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751887AbaHDLZ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2014 07:25:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h |    1 +
 drivers/net/ethernet/chelsio/cxgb4/sge.c   |   35 ++++++++++++++++-----------
 2 files changed, 22 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 4615621..c9b922c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -866,6 +866,7 @@ void t4_os_link_changed(struct adapter *adap, int port_id, int link_stat);
 void *t4_alloc_mem(size_t size);
 
 void t4_free_sge_resources(struct adapter *adap);
+void t4_free_ofld_rxqs(struct adapter *adap, int n, struct sge_ofld_rxq *q);
 irq_handler_t t4_intr_handler(struct adapter *adap);
 netdev_tx_t t4_eth_xmit(struct sk_buff *skb, struct net_device *dev);
 int t4_ethrx_handler(struct sge_rspq *q, const __be64 *rsp,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 8bae1aa..b0bba32 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -2480,6 +2480,22 @@ static void free_rspq_fl(struct adapter *adap, struct sge_rspq *rq,
 }
 
 /**
+ *      t4_free_ofld_rxqs - free a block of consecutive Rx queues
+ *      @adap: the adapter
+ *      @n: number of queues
+ *      @q: pointer to first queue
+ *
+ *      Release the resources of a consecutive block of offload Rx queues.
+ */
+void t4_free_ofld_rxqs(struct adapter *adap, int n, struct sge_ofld_rxq *q)
+{
+	for ( ; n; n--, q++)
+		if (q->rspq.desc)
+			free_rspq_fl(adap, &q->rspq,
+				     q->fl.size ? &q->fl : NULL);
+}
+
+/**
  *	t4_free_sge_resources - free SGE resources
  *	@adap: the adapter
  *
@@ -2490,12 +2506,12 @@ void t4_free_sge_resources(struct adapter *adap)
 	int i;
 	struct sge_eth_rxq *eq = adap->sge.ethrxq;
 	struct sge_eth_txq *etq = adap->sge.ethtxq;
-	struct sge_ofld_rxq *oq = adap->sge.ofldrxq;
 
 	/* clean up Ethernet Tx/Rx queues */
 	for (i = 0; i < adap->sge.ethqsets; i++, eq++, etq++) {
 		if (eq->rspq.desc)
-			free_rspq_fl(adap, &eq->rspq, &eq->fl);
+			free_rspq_fl(adap, &eq->rspq,
+				     eq->fl.size ? &eq->fl : NULL);
 		if (etq->q.desc) {
 			t4_eth_eq_free(adap, adap->fn, adap->fn, 0,
 				       etq->q.cntxt_id);
@@ -2506,18 +2522,9 @@ void t4_free_sge_resources(struct adapter *adap)
 	}
 
 	/* clean up RDMA and iSCSI Rx queues */
-	for (i = 0; i < adap->sge.ofldqsets; i++, oq++) {
-		if (oq->rspq.desc)
-			free_rspq_fl(adap, &oq->rspq, &oq->fl);
-	}
-	for (i = 0, oq = adap->sge.rdmarxq; i < adap->sge.rdmaqs; i++, oq++) {
-		if (oq->rspq.desc)
-			free_rspq_fl(adap, &oq->rspq, &oq->fl);
-	}
-	for (i = 0, oq = adap->sge.rdmaciq; i < adap->sge.rdmaciqs; i++, oq++) {
-		if (oq->rspq.desc)
-			free_rspq_fl(adap, &oq->rspq, &oq->fl);
-	}
+	t4_free_ofld_rxqs(adap, adap->sge.ofldqsets, adap->sge.ofldrxq);
+	t4_free_ofld_rxqs(adap, adap->sge.rdmaqs, adap->sge.rdmarxq);
+	t4_free_ofld_rxqs(adap, adap->sge.rdmaciqs, adap->sge.rdmaciq);
 
 	/* clean up offload Tx queues */
 	for (i = 0; i < ARRAY_SIZE(adap->sge.ofldtxq); i++) {
-- 
1.7.1
