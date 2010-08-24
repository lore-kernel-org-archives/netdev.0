From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next 1/4] cxgb4: handle Rx/Tx queue ranges not starting at 0
Date: Mon, 23 Aug 2010 20:20:58 -0700
Message-ID: <1282620061-32608-2-git-send-email-dm@chelsio.com>
References: <1282620061-32608-1-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:25324 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751756Ab0HXD2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 23:28:21 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o7O3SLM4022367
	for <netdev@vger.kernel.org>; Mon, 23 Aug 2010 20:28:21 -0700
In-Reply-To: <1282620061-32608-1-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the driver assumes that queue IDs start at 0 but that's true
only for function 0.  To support operation on other functions get the
start of the queue ranges from FW and offset accordingly.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4.h      |    2 ++
 drivers/net/cxgb4/cxgb4_main.c |   24 +++++++++++++++++++-----
 drivers/net/cxgb4/sge.c        |   15 +++++++++------
 drivers/net/cxgb4/t4fw_api.h   |    5 +++++
 4 files changed, 35 insertions(+), 11 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4.h b/drivers/net/cxgb4/cxgb4.h
index 6e562c0..3ece9f5 100644
--- a/drivers/net/cxgb4/cxgb4.h
+++ b/drivers/net/cxgb4/cxgb4.h
@@ -463,6 +463,8 @@ struct sge {
 	u8 counter_val[SGE_NCOUNTERS];
 	unsigned int starve_thres;
 	u8 idma_state[2];
+	unsigned int egr_start;
+	unsigned int ingr_start;
 	void *egr_map[MAX_EGRQ];    /* qid->queue egress queue map */
 	struct sge_rspq *ingr_map[MAX_INGQ]; /* qid->queue ingress queue map */
 	DECLARE_BITMAP(starving_fl, MAX_EGRQ);
diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index c327527..6e08e2d 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -423,10 +423,11 @@ static int fwevtq_handler(struct sge_rspq *q, const __be64 *rsp,
 	if (likely(opcode == CPL_SGE_EGR_UPDATE)) {
 		const struct cpl_sge_egr_update *p = (void *)rsp;
 		unsigned int qid = EGR_QID(ntohl(p->opcode_qid));
-		struct sge_txq *txq = q->adap->sge.egr_map[qid];
+		struct sge_txq *txq;
 
+		txq = q->adap->sge.egr_map[qid - q->adap->sge.egr_start];
 		txq->restarts++;
-		if ((u8 *)txq < (u8 *)q->adap->sge.ethrxq) {
+		if ((u8 *)txq < (u8 *)q->adap->sge.ofldtxq) {
 			struct sge_eth_txq *eq;
 
 			eq = container_of(txq, struct sge_eth_txq, q);
@@ -658,6 +659,15 @@ static int setup_rss(struct adapter *adap)
 }
 
 /*
+ * Return the channel of the ingress queue with the given qid.
+ */
+static unsigned int rxq_to_chan(const struct sge *p, unsigned int qid)
+{
+	qid -= p->ingr_start;
+	return netdev2pinfo(p->ingr_map[qid]->netdev)->tx_chan;
+}
+
+/*
  * Wait until all NAPI handlers are descheduled.
  */
 static void quiesce_rx(struct adapter *adap)
@@ -2304,7 +2314,7 @@ int cxgb4_create_server(const struct net_device *dev, unsigned int stid,
 	req->peer_port = htons(0);
 	req->local_ip = sip;
 	req->peer_ip = htonl(0);
-	chan = netdev2pinfo(adap->sge.ingr_map[queue]->netdev)->tx_chan;
+	chan = rxq_to_chan(&adap->sge, queue);
 	req->opt0 = cpu_to_be64(TX_CHAN(chan));
 	req->opt1 = cpu_to_be64(CONN_POLICY_ASK |
 				SYN_RSS_ENABLE | SYN_RSS_QUEUE(queue));
@@ -2346,7 +2356,7 @@ int cxgb4_create_server6(const struct net_device *dev, unsigned int stid,
 	req->local_ip_lo = *(__be64 *)(sip->s6_addr + 8);
 	req->peer_ip_hi = cpu_to_be64(0);
 	req->peer_ip_lo = cpu_to_be64(0);
-	chan = netdev2pinfo(adap->sge.ingr_map[queue]->netdev)->tx_chan;
+	chan = rxq_to_chan(&adap->sge, queue);
 	req->opt0 = cpu_to_be64(TX_CHAN(chan));
 	req->opt1 = cpu_to_be64(CONN_POLICY_ASK |
 				SYN_RSS_ENABLE | SYN_RSS_QUEUE(queue));
@@ -3061,12 +3071,16 @@ static int adap_init0(struct adapter *adap)
 	params[2] = FW_PARAM_PFVF(L2T_END);
 	params[3] = FW_PARAM_PFVF(FILTER_START);
 	params[4] = FW_PARAM_PFVF(FILTER_END);
-	ret = t4_query_params(adap, adap->fn, adap->fn, 0, 5, params, val);
+	params[5] = FW_PARAM_PFVF(IQFLINT_START);
+	params[6] = FW_PARAM_PFVF(EQ_START);
+	ret = t4_query_params(adap, adap->fn, adap->fn, 0, 7, params, val);
 	if (ret < 0)
 		goto bye;
 	port_vec = val[0];
 	adap->tids.ftid_base = val[3];
 	adap->tids.nftids = val[4] - val[3] + 1;
+	adap->sge.ingr_start = val[5];
+	adap->sge.egr_start = val[6];
 
 	if (c.ofldcaps) {
 		/* query offload-related parameters */
diff --git a/drivers/net/cxgb4/sge.c b/drivers/net/cxgb4/sge.c
index bf38cfc..44c2e6c 100644
--- a/drivers/net/cxgb4/sge.c
+++ b/drivers/net/cxgb4/sge.c
@@ -557,7 +557,8 @@ out:	cred = q->avail - cred;
 
 	if (unlikely(fl_starving(q))) {
 		smp_wmb();
-		set_bit(q->cntxt_id, adap->sge.starving_fl);
+		set_bit(q->cntxt_id - adap->sge.egr_start,
+			adap->sge.starving_fl);
 	}
 
 	return cred;
@@ -1213,7 +1214,8 @@ static void txq_stop_maperr(struct sge_ofld_txq *q)
 {
 	q->mapping_err++;
 	q->q.stops++;
-	set_bit(q->q.cntxt_id, q->adap->sge.txq_maperr);
+	set_bit(q->q.cntxt_id - q->adap->sge.egr_start,
+		q->adap->sge.txq_maperr);
 }
 
 /**
@@ -1835,6 +1837,7 @@ static unsigned int process_intrq(struct adapter *adap)
 		if (RSPD_TYPE(rc->type_gen) == RSP_TYPE_INTR) {
 			unsigned int qid = ntohl(rc->pldbuflen_qid);
 
+			qid -= adap->sge.ingr_start;
 			napi_schedule(&adap->sge.ingr_map[qid]->napi);
 		}
 
@@ -2050,14 +2053,14 @@ int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
 	/* set offset to -1 to distinguish ingress queues without FL */
 	iq->offset = fl ? 0 : -1;
 
-	adap->sge.ingr_map[iq->cntxt_id] = iq;
+	adap->sge.ingr_map[iq->cntxt_id - adap->sge.ingr_start] = iq;
 
 	if (fl) {
 		fl->cntxt_id = ntohs(c.fl0id);
 		fl->avail = fl->pend_cred = 0;
 		fl->pidx = fl->cidx = 0;
 		fl->alloc_failed = fl->large_alloc_failed = fl->starving = 0;
-		adap->sge.egr_map[fl->cntxt_id] = fl;
+		adap->sge.egr_map[fl->cntxt_id - adap->sge.egr_start] = fl;
 		refill_fl(adap, fl, fl_cap(fl), GFP_KERNEL);
 	}
 	return 0;
@@ -2087,7 +2090,7 @@ static void init_txq(struct adapter *adap, struct sge_txq *q, unsigned int id)
 	q->stops = q->restarts = 0;
 	q->stat = (void *)&q->desc[q->size];
 	q->cntxt_id = id;
-	adap->sge.egr_map[id] = q;
+	adap->sge.egr_map[id - adap->sge.egr_start] = q;
 }
 
 int t4_sge_alloc_eth_txq(struct adapter *adap, struct sge_eth_txq *txq,
@@ -2259,7 +2262,7 @@ static void free_rspq_fl(struct adapter *adap, struct sge_rspq *rq,
 {
 	unsigned int fl_id = fl ? fl->cntxt_id : 0xffff;
 
-	adap->sge.ingr_map[rq->cntxt_id] = NULL;
+	adap->sge.ingr_map[rq->cntxt_id - adap->sge.ingr_start] = NULL;
 	t4_iq_free(adap, adap->fn, adap->fn, 0, FW_IQ_TYPE_FL_INT_CAP,
 		   rq->cntxt_id, fl_id, 0xffff);
 	dma_free_coherent(adap->pdev_dev, (rq->size + 1) * rq->iqe_len,
diff --git a/drivers/net/cxgb4/t4fw_api.h b/drivers/net/cxgb4/t4fw_api.h
index 0969f2f..940584a 100644
--- a/drivers/net/cxgb4/t4fw_api.h
+++ b/drivers/net/cxgb4/t4fw_api.h
@@ -487,6 +487,11 @@ enum fw_params_param_pfvf {
 	FW_PARAMS_PARAM_PFVF_CPMASK     = 0x25,
 	FW_PARAMS_PARAM_PFVF_OCQ_START  = 0x26,
 	FW_PARAMS_PARAM_PFVF_OCQ_END    = 0x27,
+	FW_PARAMS_PARAM_PFVF_CONM_MAP   = 0x28,
+	FW_PARAMS_PARAM_PFVF_IQFLINT_START = 0x29,
+	FW_PARAMS_PARAM_PFVF_IQFLINT_END = 0x2A,
+	FW_PARAMS_PARAM_PFVF_EQ_START	= 0x2B,
+	FW_PARAMS_PARAM_PFVF_EQ_END	= 0x2C,
 };
 
 /*
-- 
1.5.4

