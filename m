From: Varun Prakash <varun@chelsio.com>
Subject: [target-pending 03/12] cxgb4: large receive offload support
Date: Sun, 13 Mar 2016 18:58:53 +0530
Message-ID: <f30ea410aba3915f259b5bd024a67ba54e06e306.1457872112.git.varun@chelsio.com>
References: <cover.1457872112.git.varun@chelsio.com>
Cc: target-devel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, swise@opengridcomputing.com,
	indranil@chelsio.com, kxie@chelsio.com, hariprasad@chelsio.com,
	varun@chelsio.com
To: nab@linux-iscsi.org
Return-path: <target-devel-owner@vger.kernel.org>
In-Reply-To: <cover.1457872112.git.varun@chelsio.com>
In-Reply-To: <cover.1457872112.git.varun@chelsio.com>
References: <cover.1457872112.git.varun@chelsio.com>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

add large receive offload(LRO) support
for upper layer drivers.

Signed-off-by: Varun Prakash <varun@chelsio.com>
Signed-off-by: Nicholas Bellinger <nab@linux-iscsi.org>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      | 14 ++++++++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 42 ++++++++++++++++++-------
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |  6 ++++
 drivers/net/ethernet/chelsio/cxgb4/sge.c        | 12 +++++--
 4 files changed, 60 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 6206de9..92086a0 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -511,6 +511,15 @@ struct pkt_gl {
 
 typedef int (*rspq_handler_t)(struct sge_rspq *q, const __be64 *rsp,
 			      const struct pkt_gl *gl);
+typedef void (*rspq_flush_handler_t)(struct sge_rspq *q);
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
@@ -535,6 +544,8 @@ struct sge_rspq {                   /* state for an SGE response queue */
 	struct adapter *adap;
 	struct net_device *netdev;  /* associated net device */
 	rspq_handler_t handler;
+	rspq_flush_handler_t flush_handler;
+	struct t4_lro_mgr lro_mgr;
 #ifdef CONFIG_NET_RX_BUSY_POLL
 #define CXGB_POLL_STATE_IDLE		0
 #define CXGB_POLL_STATE_NAPI		BIT(0) /* NAPI owns this poll */
@@ -1114,7 +1125,8 @@ int t4_mgmt_tx(struct adapter *adap, struct sk_buff *skb);
 int t4_ofld_send(struct adapter *adap, struct sk_buff *skb);
 int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
 		     struct net_device *dev, int intr_idx,
-		     struct sge_fl *fl, rspq_handler_t hnd, int cong);
+		     struct sge_fl *fl, rspq_handler_t hnd,
+		     rspq_flush_handler_t flush_handler, int cong);
 int t4_sge_alloc_eth_txq(struct adapter *adap, struct sge_eth_txq *txq,
 			 struct net_device *dev, struct netdev_queue *netdevq,
 			 unsigned int iqid);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index d6cfa90..050f215 100644
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
@@ -653,6 +660,7 @@ static int uldrx_handler(struct sge_rspq *q, const __be64 *rsp,
 			 const struct pkt_gl *gl)
 {
 	struct sge_ofld_rxq *rxq = container_of(q, struct sge_ofld_rxq, rspq);
+	int ret;
 
 	/* FW can send CPLs encapsulated in a CPL_FW4_MSG.
 	 */
@@ -660,10 +668,19 @@ static int uldrx_handler(struct sge_rspq *q, const __be64 *rsp,
 	    ((const struct cpl_fw4_msg *)(rsp + 1))->type == FW_TYPE_RSSCPL)
 		rsp += 2;
 
-	if (ulds[q->uld].rx_handler(q->adap->uld_handle[q->uld], rsp, gl)) {
+	if (q->flush_handler)
+		ret = ulds[q->uld].lro_rx_handler(q->adap->uld_handle[q->uld],
+						  rsp, gl, &q->lro_mgr,
+						  &q->napi);
+	else
+		ret = ulds[q->uld].rx_handler(q->adap->uld_handle[q->uld],
+					      rsp, gl);
+
+	if (ret) {
 		rxq->stats.nomem++;
 		return -1;
 	}
+
 	if (gl == NULL)
 		rxq->stats.imm++;
 	else if (gl == CXGB4_MSG_AN)
@@ -980,7 +997,7 @@ static void enable_rx(struct adapter *adap)
 
 static int alloc_ofld_rxqs(struct adapter *adap, struct sge_ofld_rxq *q,
 			   unsigned int nq, unsigned int per_chan, int msi_idx,
-			   u16 *ids)
+			   u16 *ids, bool lro)
 {
 	int i, err;
 
@@ -990,7 +1007,9 @@ static int alloc_ofld_rxqs(struct adapter *adap, struct sge_ofld_rxq *q,
 		err = t4_sge_alloc_rxq(adap, &q->rspq, false,
 				       adap->port[i / per_chan],
 				       msi_idx, q->fl.size ? &q->fl : NULL,
-				       uldrx_handler, 0);
+				       uldrx_handler,
+				       lro ? uldrx_flush_handler : NULL,
+				       0);
 		if (err)
 			return err;
 		memset(&q->stats, 0, sizeof(q->stats));
@@ -1020,7 +1039,7 @@ static int setup_sge_queues(struct adapter *adap)
 		msi_idx = 1;         /* vector 0 is for non-queue interrupts */
 	else {
 		err = t4_sge_alloc_rxq(adap, &s->intrq, false, adap->port[0], 0,
-				       NULL, NULL, -1);
+				       NULL, NULL, NULL, -1);
 		if (err)
 			return err;
 		msi_idx = -((int)s->intrq.abs_id + 1);
@@ -1040,7 +1059,7 @@ static int setup_sge_queues(struct adapter *adap)
 	 *    new/deleted queues.
 	 */
 	err = t4_sge_alloc_rxq(adap, &s->fw_evtq, true, adap->port[0],
-			       msi_idx, NULL, fwevtq_handler, -1);
+			       msi_idx, NULL, fwevtq_handler, NULL, -1);
 	if (err) {
 freeout:	t4_free_sge_resources(adap);
 		return err;
@@ -1058,6 +1077,7 @@ freeout:	t4_free_sge_resources(adap);
 			err = t4_sge_alloc_rxq(adap, &q->rspq, false, dev,
 					       msi_idx, &q->fl,
 					       t4_ethrx_handler,
+					       NULL,
 					       t4_get_mps_bg_map(adap,
 								 pi->tx_chan));
 			if (err)
@@ -1083,19 +1103,19 @@ freeout:	t4_free_sge_resources(adap);
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
-	ALLOC_OFLD_RXQS(s->iscsitrxq, s->niscsitq, j, s->iscsit_rxq);
-	ALLOC_OFLD_RXQS(s->rdmarxq, s->rdmaqs, 1, s->rdma_rxq);
+	ALLOC_OFLD_RXQS(s->iscsirxq, s->iscsiqsets, j, s->iscsi_rxq, false);
+	ALLOC_OFLD_RXQS(s->iscsitrxq, s->niscsitq, j, s->iscsit_rxq, true);
+	ALLOC_OFLD_RXQS(s->rdmarxq, s->rdmaqs, 1, s->rdma_rxq, false);
 	j = s->rdmaciqs / adap->params.nports; /* rdmaq queues per channel */
-	ALLOC_OFLD_RXQS(s->rdmaciq, s->rdmaciqs, j, s->rdma_ciq);
+	ALLOC_OFLD_RXQS(s->rdmaciq, s->rdmaciqs, j, s->rdma_ciq, false);
 
 #undef ALLOC_OFLD_RXQS
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
index 2f80e32..d97a81f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
@@ -213,6 +213,7 @@ struct l2t_data;
 struct net_device;
 struct pkt_gl;
 struct tp_tcp_stats;
+struct t4_lro_mgr;
 
 struct cxgb4_range {
 	unsigned int start;
@@ -284,6 +285,11 @@ struct cxgb4_uld_info {
 			  const struct pkt_gl *gl);
 	int (*state_change)(void *handle, enum cxgb4_state new_state);
 	int (*control)(void *handle, enum cxgb4_control control, ...);
+	int (*lro_rx_handler)(void *handle, const __be64 *rsp,
+			      const struct pkt_gl *gl,
+			      struct t4_lro_mgr *lro_mgr,
+			      struct napi_struct *napi);
+	void (*lro_flush)(struct t4_lro_mgr *);
 };
 
 int cxgb4_register_uld(enum cxgb4_uld type, const struct cxgb4_uld_info *p);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index b3a31af..3ba4b0c 100644
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
@@ -2638,6 +2642,10 @@ int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
 	iq->size--;                           /* subtract status entry */
 	iq->netdev = dev;
 	iq->handler = hnd;
+	iq->flush_handler = flush_hnd;
+
+	memset(&iq->lro_mgr, 0, sizeof(struct t4_lro_mgr));
+	skb_queue_head_init(&iq->lro_mgr.lroq);
 
 	/* set offset to -1 to distinguish ingress queues without FL */
 	iq->offset = fl ? 0 : -1;
-- 
2.0.2
