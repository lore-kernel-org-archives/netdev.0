From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv3 net-next 1/3] cxgb4: Add LRO infrastructure for cxgb4i driver
Date: Wed, 13 Jan 2016 12:47:37 +0530
Message-ID: <1452669459-15082-2-git-send-email-hariprasad@chelsio.com>
References: <1452669459-15082-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, James.Bottomley@hansenpartnership.com,
	martin.petersen@oracle.com, leedom@chelsio.com, kxie@chelsio.com,
	manojmalviya@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:21897 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755063AbcAMHQI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2016 02:16:08 -0500
In-Reply-To: <1452669459-15082-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      | 15 +++++++++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 40 ++++++++++++++++++-------
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |  5 ++++
 drivers/net/ethernet/chelsio/cxgb4/sge.c        | 11 +++++--
 4 files changed, 57 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index ec6e849676c1..0c3554e41774 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -508,6 +508,16 @@ struct pkt_gl {
 
 typedef int (*rspq_handler_t)(struct sge_rspq *q, const __be64 *rsp,
 			      const struct pkt_gl *gl);
+typedef void (*rspq_flush_handler_t)(struct sge_rspq *q);
+
+/* LRO related declarations for ULD */
+struct t4_lro_mgr {
+#define MAX_LRO_SESSIONS		64
+	u8 lro_session_cnt;         /* # of sessions to aggregate */
+	unsigned long lro_pkts;     /* # of LRO super packets */
+	unsigned long lro_merged;   /* # of wire packets merged by LRO */
+	struct sk_buff_head lroq;   /* list of aggregated sessions */
+};
 
 struct sge_rspq {                   /* state for an SGE response queue */
 	struct napi_struct napi;
@@ -532,6 +542,8 @@ struct sge_rspq {                   /* state for an SGE response queue */
 	struct adapter *adap;
 	struct net_device *netdev;  /* associated net device */
 	rspq_handler_t handler;
+	rspq_flush_handler_t flush_handler;
+	struct t4_lro_mgr lro_mgr;
 #ifdef CONFIG_NET_RX_BUSY_POLL
 #define CXGB_POLL_STATE_IDLE		0
 #define CXGB_POLL_STATE_NAPI		BIT(0) /* NAPI owns this poll */
@@ -1107,7 +1119,8 @@ int t4_mgmt_tx(struct adapter *adap, struct sk_buff *skb);
 int t4_ofld_send(struct adapter *adap, struct sk_buff *skb);
 int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
 		     struct net_device *dev, int intr_idx,
-		     struct sge_fl *fl, rspq_handler_t hnd, int cong);
+		     struct sge_fl *fl, rspq_handler_t hnd,
+		     rspq_flush_handler_t flush_hnd, int cong);
 int t4_sge_alloc_eth_txq(struct adapter *adap, struct sge_eth_txq *txq,
 			 struct net_device *dev, struct netdev_queue *netdevq,
 			 unsigned int iqid);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index b8a5fb0c32d4..68c2aae88ef4 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -640,6 +640,13 @@ out:
 	return 0;
 }
 
+/* Flush the aggregated lro sessions */
+static void uldrx_flush_handler(struct sge_rspq *q)
+{
+	if (ulds[q->uld].lro_flush)
+		ulds[q->uld].lro_flush(&q->lro_mgr);
+}
+
 /**
  *	uldrx_handler - response queue handler for ULD queues
  *	@q: the response queue that received the packet
@@ -653,6 +660,8 @@ static int uldrx_handler(struct sge_rspq *q, const __be64 *rsp,
 			 const struct pkt_gl *gl)
 {
 	struct sge_ofld_rxq *rxq = container_of(q, struct sge_ofld_rxq, rspq);
+	unsigned int napi_id = q->napi.napi_id;
+	int ret;
 
 	/* FW can send CPLs encapsulated in a CPL_FW4_MSG.
 	 */
@@ -660,7 +669,15 @@ static int uldrx_handler(struct sge_rspq *q, const __be64 *rsp,
 	    ((const struct cpl_fw4_msg *)(rsp + 1))->type == FW_TYPE_RSSCPL)
 		rsp += 2;
 
-	if (ulds[q->uld].rx_handler(q->adap->uld_handle[q->uld], rsp, gl)) {
+	if (q->flush_handler)
+		ret = ulds[q->uld].lro_rx_handler(q->adap->uld_handle[q->uld],
+						  rsp, gl, &q->lro_mgr,
+						  napi_id);
+	else
+		ret = ulds[q->uld].rx_handler(q->adap->uld_handle[q->uld],
+					      rsp, gl);
+
+	if (ret) {
 		rxq->stats.nomem++;
 		return -1;
 	}
@@ -960,7 +977,7 @@ static void enable_rx(struct adapter *adap)
 
 static int alloc_ofld_rxqs(struct adapter *adap, struct sge_ofld_rxq *q,
 			   unsigned int nq, unsigned int per_chan, int msi_idx,
-			   u16 *ids)
+			   u16 *ids, bool lro)
 {
 	int i, err;
 
@@ -970,7 +987,8 @@ static int alloc_ofld_rxqs(struct adapter *adap, struct sge_ofld_rxq *q,
 		err = t4_sge_alloc_rxq(adap, &q->rspq, false,
 				       adap->port[i / per_chan],
 				       msi_idx, q->fl.size ? &q->fl : NULL,
-				       uldrx_handler, 0);
+				       uldrx_handler,
+				       lro ? uldrx_flush_handler : NULL, 0);
 		if (err)
 			return err;
 		memset(&q->stats, 0, sizeof(q->stats));
@@ -1000,7 +1018,7 @@ static int setup_sge_queues(struct adapter *adap)
 		msi_idx = 1;         /* vector 0 is for non-queue interrupts */
 	else {
 		err = t4_sge_alloc_rxq(adap, &s->intrq, false, adap->port[0], 0,
-				       NULL, NULL, -1);
+				       NULL, NULL, NULL, -1);
 		if (err)
 			return err;
 		msi_idx = -((int)s->intrq.abs_id + 1);
@@ -1020,7 +1038,7 @@ static int setup_sge_queues(struct adapter *adap)
 	 *    new/deleted queues.
 	 */
 	err = t4_sge_alloc_rxq(adap, &s->fw_evtq, true, adap->port[0],
-			       msi_idx, NULL, fwevtq_handler, -1);
+			       msi_idx, NULL, fwevtq_handler, NULL, -1);
 	if (err) {
 freeout:	t4_free_sge_resources(adap);
 		return err;
@@ -1037,7 +1055,7 @@ freeout:	t4_free_sge_resources(adap);
 				msi_idx++;
 			err = t4_sge_alloc_rxq(adap, &q->rspq, false, dev,
 					       msi_idx, &q->fl,
-					       t4_ethrx_handler,
+					       t4_ethrx_handler, NULL,
 					       t4_get_mps_bg_map(adap,
 								 pi->tx_chan));
 			if (err)
@@ -1063,18 +1081,18 @@ freeout:	t4_free_sge_resources(adap);
 			goto freeout;
 	}
 
-#define ALLOC_OFLD_RXQS(firstq, nq, per_chan, ids) do { \
-	err = alloc_ofld_rxqs(adap, firstq, nq, per_chan, msi_idx, ids); \
+#define ALLOC_OFLD_RXQS(firstq, nq, per_chan, ids, lro) do { \
+	err = alloc_ofld_rxqs(adap, firstq, nq, per_chan, msi_idx, ids, lro); \
 	if (err) \
 		goto freeout; \
 	if (msi_idx > 0) \
 		msi_idx += nq; \
 } while (0)
 
-	ALLOC_OFLD_RXQS(s->iscsirxq, s->iscsiqsets, j, s->iscsi_rxq);
-	ALLOC_OFLD_RXQS(s->rdmarxq, s->rdmaqs, 1, s->rdma_rxq);
+	ALLOC_OFLD_RXQS(s->iscsirxq, s->iscsiqsets, j, s->iscsi_rxq, true);
+	ALLOC_OFLD_RXQS(s->rdmarxq, s->rdmaqs, 1, s->rdma_rxq, false);
 	j = s->rdmaciqs / adap->params.nports; /* rdmaq queues per channel */
-	ALLOC_OFLD_RXQS(s->rdmaciq, s->rdmaciqs, j, s->rdma_ciq);
+	ALLOC_OFLD_RXQS(s->rdmaciq, s->rdmaciqs, j, s->rdma_ciq, false);
 
 #undef ALLOC_OFLD_RXQS
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
index cf711d5f15be..ef75eb3a7bff 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
@@ -212,6 +212,7 @@ struct l2t_data;
 struct net_device;
 struct pkt_gl;
 struct tp_tcp_stats;
+struct t4_lro_mgr;
 
 struct cxgb4_range {
 	unsigned int start;
@@ -283,6 +284,10 @@ struct cxgb4_uld_info {
 			  const struct pkt_gl *gl);
 	int (*state_change)(void *handle, enum cxgb4_state new_state);
 	int (*control)(void *handle, enum cxgb4_control control, ...);
+	int (*lro_rx_handler)(void *handle, const __be64 *rsp,
+			      const struct pkt_gl *gl,
+			      struct t4_lro_mgr *lro_mgr, unsigned int napi_id);
+	void (*lro_flush)(struct t4_lro_mgr *);
 };
 
 int cxgb4_register_uld(enum cxgb4_uld type, const struct cxgb4_uld_info *p);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index b4eb4680a27c..c2e50d28a58a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -2157,8 +2157,11 @@ static int process_responses(struct sge_rspq *q, int budget)
 
 	while (likely(budget_left)) {
 		rc = (void *)q->cur_desc + (q->iqe_len - sizeof(*rc));
-		if (!is_new_response(rc, q))
+		if (!is_new_response(rc, q)) {
+			if (q->flush_handler)
+				q->flush_handler(q);
 			break;
+		}
 
 		dma_rmb();
 		rsp_type = RSPD_TYPE_G(rc->type_gen);
@@ -2544,7 +2547,8 @@ static void __iomem *bar2_address(struct adapter *adapter,
  */
 int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
 		     struct net_device *dev, int intr_idx,
-		     struct sge_fl *fl, rspq_handler_t hnd, int cong)
+		     struct sge_fl *fl, rspq_handler_t hnd,
+		     rspq_flush_handler_t flush_hnd, int cong)
 {
 	int ret, flsz = 0;
 	struct fw_iq_cmd c;
@@ -2638,6 +2642,9 @@ int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
 	iq->size--;                           /* subtract status entry */
 	iq->netdev = dev;
 	iq->handler = hnd;
+	iq->flush_handler = flush_hnd;
+	memset(&iq->lro_mgr, 0, sizeof(struct t4_lro_mgr));
+	skb_queue_head_init(&iq->lro_mgr.lroq);
 
 	/* set offset to -1 to distinguish ingress queues without FL */
 	iq->offset = fl ? 0 : -1;
-- 
2.3.4
