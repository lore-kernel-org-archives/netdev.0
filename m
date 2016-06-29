From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next] cxgb4: Introduce API for sending work requests on ctrl queue via copy
Date: Wed, 29 Jun 2016 09:01:19 +0530
Message-ID: <1467171079-27193-1-git-send-email-hariprasad@chelsio.com>
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from [12.32.117.8] ([12.32.117.8]:33668 "EHLO
	stargate3.asicdesigners.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752449AbcF2D13 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 23:27:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the ctrl queue is full, just follows current path by allocating an
skb. If that fails then caller will just have to handle that case as
before.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |   1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  10 +--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |   2 +
 drivers/net/ethernet/chelsio/cxgb4/l2t.c        |  11 +--
 drivers/net/ethernet/chelsio/cxgb4/sge.c        | 108 ++++++++++++++++++++++++
 5 files changed, 118 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index b4fceb92479f..08e0c639cf90 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -1166,6 +1166,7 @@ netdev_tx_t t4_eth_xmit(struct sk_buff *skb, struct net_device *dev);
 int t4_ethrx_handler(struct sge_rspq *q, const __be64 *rsp,
 		     const struct pkt_gl *gl);
 int t4_mgmt_tx(struct adapter *adap, struct sk_buff *skb);
+int t4_mgmt_tx_direct(struct adapter *adap, const void *src, unsigned int len);
 int t4_ofld_send(struct adapter *adap, struct sk_buff *skb);
 int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
 		     struct net_device *dev, int intr_idx,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index c45de49dc963..cac8ef209f68 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -1696,8 +1696,8 @@ static void process_tid_release_list(struct work_struct *work)
  */
 void cxgb4_remove_tid(struct tid_info *t, unsigned int chan, unsigned int tid)
 {
-	struct sk_buff *skb;
 	struct adapter *adap = container_of(t, struct adapter, tids);
+	struct cpl_tid_release sreq, *req = &sreq;
 
 	WARN_ON(tid >= t->ntids);
 
@@ -1709,11 +1709,9 @@ void cxgb4_remove_tid(struct tid_info *t, unsigned int chan, unsigned int tid)
 			atomic_dec(&t->tids_in_use);
 	}
 
-	skb = alloc_skb(sizeof(struct cpl_tid_release), GFP_ATOMIC);
-	if (likely(skb)) {
-		mk_tid_release(skb, chan, tid);
-		t4_ofld_send(adap, skb);
-	} else
+	INIT_TP_WR_CPL(req, CPL_TID_RELEASE, tid);
+	req->rsvd = 0;
+	if (cxgb4_ctrl_send(adap->port[chan], req, sizeof(*req)))
 		cxgb4_queue_tid_release(t, chan, tid);
 }
 EXPORT_SYMBOL(cxgb4_remove_tid);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
index f3c58aaa932d..128efc914317 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
@@ -299,6 +299,8 @@ struct cxgb4_uld_info {
 int cxgb4_register_uld(enum cxgb4_uld type, const struct cxgb4_uld_info *p);
 int cxgb4_unregister_uld(enum cxgb4_uld type);
 int cxgb4_ofld_send(struct net_device *dev, struct sk_buff *skb);
+int cxgb4_ctrl_send(struct net_device *dev, const void *src,
+		    unsigned int len);
 unsigned int cxgb4_dbfifo_count(const struct net_device *dev, int lpfifo);
 unsigned int cxgb4_port_chan(const struct net_device *dev);
 unsigned int cxgb4_port_viid(const struct net_device *dev);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/l2t.c b/drivers/net/ethernet/chelsio/cxgb4/l2t.c
index 60a26037a1c6..e5a67cfca5bb 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/l2t.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/l2t.c
@@ -139,14 +139,8 @@ static int write_l2e(struct adapter *adap, struct l2t_entry *e, int sync)
 {
 	struct l2t_data *d = adap->l2t;
 	unsigned int l2t_idx = e->idx + d->l2t_start;
-	struct sk_buff *skb;
-	struct cpl_l2t_write_req *req;
-
-	skb = alloc_skb(sizeof(*req), GFP_ATOMIC);
-	if (!skb)
-		return -ENOMEM;
+	struct cpl_l2t_write_req sreq, *req = &sreq;
 
-	req = (struct cpl_l2t_write_req *)__skb_put(skb, sizeof(*req));
 	INIT_TP_WR(req, 0);
 
 	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_L2T_WRITE_REQ,
@@ -159,7 +153,8 @@ static int write_l2e(struct adapter *adap, struct l2t_entry *e, int sync)
 		memcpy(e->dmac, e->neigh->ha, sizeof(e->dmac));
 	memcpy(req->dst_mac, e->dmac, sizeof(req->dst_mac));
 
-	t4_mgmt_tx(adap, skb);
+	if (t4_mgmt_tx_direct(adap, req, sizeof(*req)))
+		return -ENOMEM;
 
 	if (sync && e->state != L2T_STATE_SWITCHING)
 		e->state = L2T_STATE_SYNC_WRITE;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index bad253beb8c8..8e0562f52b91 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -1056,6 +1056,30 @@ static void *inline_tx_skb_header(const struct sk_buff *skb,
 	return p;
 }
 
+static void *inline_tx_header(const void *src,
+			      const struct sge_txq *q,
+			      void *pos, int length)
+{
+	u64 *p;
+	int left = (void *)q->stat - pos;
+
+	if (likely(length <= left)) {
+		memcpy(pos, src, length);
+		pos += length;
+	} else {
+		memcpy(pos, src, left);
+		memcpy(q->desc, src + left, length - left);
+		pos = (void *)q->desc + (length - left);
+	}
+	/* 0-pad to multiple of 16 */
+	p = PTR_ALIGN(pos, 8);
+	if ((uintptr_t)p & 8) {
+		*p = 0;
+		return p + 1;
+	}
+	return p;
+}
+
 /*
  * Figure out what HW csum a packet wants and return the appropriate control
  * bits.
@@ -1431,6 +1455,47 @@ static int ctrl_xmit(struct sge_ctrl_txq *q, struct sk_buff *skb)
 	return NET_XMIT_SUCCESS;
 }
 
+static int ctrl_xmit_direct(struct sge_ctrl_txq *q,
+			    const void *src, unsigned int len)
+{
+	unsigned int ndesc;
+	struct fw_wr_hdr *wr;
+
+	if (unlikely(len > MAX_CTRL_WR_LEN)) {
+		WARN_ON(1);
+		return NET_XMIT_DROP;
+	}
+
+	ndesc = DIV_ROUND_UP(len, sizeof(struct tx_desc));
+	spin_lock(&q->sendq.lock);
+
+	if (unlikely(q->full)) {
+		struct sk_buff *skb = alloc_skb(len, GFP_ATOMIC);
+
+		if (!skb) {
+			spin_unlock(&q->sendq.lock);
+			return NET_XMIT_DROP;
+		}
+		__skb_put(skb, len);
+		memcpy(skb->data, src, len);
+		skb->priority = ndesc;                  /* save for restart */
+		__skb_queue_tail(&q->sendq, skb);
+		spin_unlock(&q->sendq.lock);
+		return NET_XMIT_CN;
+	}
+
+	wr = (struct fw_wr_hdr *)&q->q.desc[q->q.pidx];
+	inline_tx_header(src, &q->q, wr, len);
+	txq_advance(&q->q, ndesc);
+	if (unlikely(txq_avail(&q->q) < TXQ_STOP_THRES))
+		ctrlq_check_stop(q, wr);
+
+	ring_tx_db(q->adap, &q->q, ndesc);
+	spin_unlock(&q->sendq.lock);
+
+	return NET_XMIT_SUCCESS;
+}
+
 /**
  *	restart_ctrlq - restart a suspended control queue
  *	@data: the control queue to restart
@@ -1501,6 +1566,25 @@ int t4_mgmt_tx(struct adapter *adap, struct sk_buff *skb)
 }
 
 /**
+ *	t4_mgmt_tx_direct - send a management message via copy
+ *	@adap: the adapter
+ *	@src: source of work request to be copied
+ *	@len: length of work request
+ *
+ *	Send a management message through control queue 0.
+ */
+int t4_mgmt_tx_direct(struct adapter *adap, const void *src,
+		      unsigned int len)
+{
+	int ret;
+
+	local_bh_disable();
+	ret = ctrl_xmit_direct(&adap->sge.ctrlq[0], src, len);
+	local_bh_enable();
+	return net_xmit_eval(ret);
+}
+
+/**
  *	is_ofld_imm - check whether a packet can be sent as immediate data
  *	@skb: the packet
  *
@@ -1813,6 +1897,30 @@ int cxgb4_ofld_send(struct net_device *dev, struct sk_buff *skb)
 }
 EXPORT_SYMBOL(cxgb4_ofld_send);
 
+/**
+ *	cxgb4_ctrl_send - send an immediate mode WR on ctrl queue
+ *	@dev: the net device
+ *	@src: location of work request to copy
+ *	@len: WR length
+ */
+int cxgb4_ctrl_send(struct net_device *dev, const void *src,
+		    unsigned int len)
+{
+	struct adapter *adap = netdev2adap(dev);
+	unsigned int idx = cxgb4_port_chan(dev);
+	int ret;
+
+	/* Single ctrl queue is a requirement for LE workaround path */
+	if (adap->tids.nsftids)
+		idx = 0;
+
+	local_bh_disable();
+	ret = ctrl_xmit_direct(&adap->sge.ctrlq[idx], src, len);
+	local_bh_enable();
+	return net_xmit_eval(ret);
+}
+EXPORT_SYMBOL(cxgb4_ctrl_send);
+
 static inline void copy_frags(struct sk_buff *skb,
 			      const struct pkt_gl *gl, unsigned int offset)
 {
-- 
2.3.4
