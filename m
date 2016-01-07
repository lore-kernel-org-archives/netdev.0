From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next 3/3] cxgb4i: add iscsi LRO for chelsio t4/t5 adapters
Date: Thu,  7 Jan 2016 14:54:07 +0530
Message-ID: <1452158647-9714-4-git-send-email-hariprasad@chelsio.com>
References: <1452158647-9714-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, JBottomley@odin.com,
	martin.petersen@oracle.com, leedom@chelsio.com, kxie@chelsio.com,
	manojmalviya@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:27599 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752812AbcAGJWz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 04:22:55 -0500
In-Reply-To: <1452158647-9714-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Karen Xie <kxie@chelsio.com>
Signed-off-by: Manoj Malviya <manojmalviya@chelsio.com>
Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c | 396 +++++++++++++++++++++++++++++++++++--
 1 file changed, 382 insertions(+), 14 deletions(-)

diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
index 804806e..68e94e6 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
@@ -33,6 +33,7 @@
 static unsigned int dbg_level;
 
 #include "../libcxgbi.h"
+#include "../cxgbi_lro.h"
 
 #define	DRV_MODULE_NAME		"cxgb4i"
 #define DRV_MODULE_DESC		"Chelsio T4/T5 iSCSI Driver"
@@ -81,13 +82,6 @@ static int t4_uld_rx_handler(void *, const __be64 *, const struct pkt_gl *);
 static int t4_uld_state_change(void *, enum cxgb4_state state);
 static inline int send_tx_flowc_wr(struct cxgbi_sock *);
 
-static const struct cxgb4_uld_info cxgb4i_uld_info = {
-	.name = DRV_MODULE_NAME,
-	.add = t4_uld_add,
-	.rx_handler = t4_uld_rx_handler,
-	.state_change = t4_uld_state_change,
-};
-
 static struct scsi_host_template cxgb4i_host_template = {
 	.module		= THIS_MODULE,
 	.name		= DRV_MODULE_NAME,
@@ -1182,8 +1176,9 @@ static void do_rx_data_ddp(struct cxgbi_device *cdev,
 	}
 
 	log_debug(1 << CXGBI_DBG_TOE | 1 << CXGBI_DBG_PDU_RX,
-		"csk 0x%p,%u,0x%lx, skb 0x%p,0x%x, lhdr 0x%p.\n",
-		csk, csk->state, csk->flags, skb, status, csk->skb_ulp_lhdr);
+		"csk 0x%p,%u,0x%lx, skb 0x%p,0x%x, lhdr 0x%p, len %u.\n",
+		csk, csk->state, csk->flags, skb, status, csk->skb_ulp_lhdr,
+		ntohs(rpl->len));
 
 	spin_lock_bh(&csk->lock);
 
@@ -1212,13 +1207,13 @@ static void do_rx_data_ddp(struct cxgbi_device *cdev,
 			csk->tid, ntohs(rpl->len), cxgbi_skcb_rx_pdulen(lskb));
 
 	if (status & (1 << CPL_RX_DDP_STATUS_HCRC_SHIFT)) {
-		pr_info("csk 0x%p, lhdr 0x%p, status 0x%x, hcrc bad 0x%lx.\n",
-			csk, lskb, status, cxgbi_skcb_flags(lskb));
+		pr_info("csk 0x%p, lhdr 0x%p, status 0x%x, hcrc bad.\n",
+			csk, lskb, status);
 		cxgbi_skcb_set_flag(lskb, SKCBF_RX_HCRC_ERR);
 	}
 	if (status & (1 << CPL_RX_DDP_STATUS_DCRC_SHIFT)) {
-		pr_info("csk 0x%p, lhdr 0x%p, status 0x%x, dcrc bad 0x%lx.\n",
-			csk, lskb, status, cxgbi_skcb_flags(lskb));
+		pr_info("csk 0x%p, lhdr 0x%p, status 0x%x, dcrc bad.\n",
+			csk, lskb, status);
 		cxgbi_skcb_set_flag(lskb, SKCBF_RX_DCRC_ERR);
 	}
 	if (status & (1 << CPL_RX_DDP_STATUS_PAD_SHIFT)) {
@@ -1311,6 +1306,12 @@ static int alloc_cpls(struct cxgbi_sock *csk)
 					0, GFP_KERNEL);
 	if (!csk->cpl_abort_rpl)
 		goto free_cpls;
+
+	csk->skb_lro_hold = alloc_skb(LRO_SKB_MIN_HEADROOM, GFP_KERNEL);
+	if (unlikely(!csk->skb_lro_hold))
+		goto free_cpls;
+	memset(csk->skb_lro_hold->data, 0, LRO_SKB_MIN_HEADROOM);
+
 	return 0;
 
 free_cpls:
@@ -1539,7 +1540,7 @@ int cxgb4i_ofld_init(struct cxgbi_device *cdev)
 	cdev->csk_alloc_cpls = alloc_cpls;
 	cdev->csk_init_act_open = init_act_open;
 
-	pr_info("cdev 0x%p, offload up, added.\n", cdev);
+	pr_info("cdev 0x%p, offload up, added, f 0x%x.\n", cdev, cdev->flags);
 	return 0;
 }
 
@@ -1891,6 +1892,373 @@ static int t4_uld_state_change(void *handle, enum cxgb4_state state)
 	return 0;
 }
 
+static void proc_ddp_status(unsigned int tid, struct cpl_rx_data_ddp *cpl,
+			    struct cxgbi_rx_pdu_cb *pdu_cb)
+{
+	unsigned int status = ntohl(cpl->ddpvld);
+
+	cxgbi_rx_cb_set_flag(pdu_cb, SKCBF_RX_STATUS);
+
+	pdu_cb->ddigest = ntohl(cpl->ulp_crc);
+	pdu_cb->pdulen = ntohs(cpl->len);
+
+	if (status & (1 << CPL_RX_DDP_STATUS_HCRC_SHIFT)) {
+		pr_info("tid 0x%x, status 0x%x, hcrc bad.\n", tid, status);
+		cxgbi_rx_cb_set_flag(pdu_cb, SKCBF_RX_HCRC_ERR);
+	}
+	if (status & (1 << CPL_RX_DDP_STATUS_DCRC_SHIFT)) {
+		pr_info("tid 0x%x, status 0x%x, dcrc bad.\n", tid, status);
+		cxgbi_rx_cb_set_flag(pdu_cb, SKCBF_RX_DCRC_ERR);
+	}
+	if (status & (1 << CPL_RX_DDP_STATUS_PAD_SHIFT)) {
+		pr_info("tid 0x%x, status 0x%x, pad bad.\n", tid, status);
+		cxgbi_rx_cb_set_flag(pdu_cb, SKCBF_RX_PAD_ERR);
+	}
+	if ((status & (1 << CPL_RX_DDP_STATUS_DDP_SHIFT)) &&
+	    !cxgbi_rx_cb_test_flag(pdu_cb, SKCBF_RX_DATA)) {
+		cxgbi_rx_cb_set_flag(pdu_cb, SKCBF_RX_DATA_DDPD);
+	}
+}
+
+static void lro_skb_add_packet_rsp(struct sk_buff *skb, u8 op,
+				   const __be64 *rsp)
+{
+	struct cxgbi_rx_lro_cb *lro_cb = cxgbi_skb_rx_lro_cb(skb);
+	struct cxgbi_rx_pdu_cb *pdu_cb = cxgbi_skb_rx_pdu_cb(skb,
+						lro_cb->pdu_cnt);
+	struct cpl_rx_data_ddp *cpl = (struct cpl_rx_data_ddp *)(rsp + 1);
+
+	proc_ddp_status(lro_cb->csk->tid, cpl, pdu_cb);
+
+	lro_cb->pdu_totallen += pdu_cb->pdulen;
+	lro_cb->pdu_cnt++;
+}
+
+static void lro_skb_add_packet_gl(struct sk_buff *skb, u8 op,
+				  const struct pkt_gl *gl)
+{
+	struct cxgbi_rx_lro_cb *lro_cb = cxgbi_skb_rx_lro_cb(skb);
+	struct cxgbi_rx_pdu_cb *pdu_cb = cxgbi_skb_rx_pdu_cb(skb,
+						lro_cb->pdu_cnt);
+	struct skb_shared_info *ssi = skb_shinfo(skb);
+	int i = ssi->nr_frags;
+	unsigned int offset;
+	unsigned int len;
+
+	if (op == CPL_ISCSI_HDR) {
+		struct cpl_iscsi_hdr *cpl = (struct cpl_iscsi_hdr *)gl->va;
+
+		offset = sizeof(struct cpl_iscsi_hdr);
+		cxgbi_rx_cb_set_flag(pdu_cb, SKCBF_RX_HDR);
+
+		pdu_cb->seq = ntohl(cpl->seq);
+		len = ntohs(cpl->len);
+	} else {
+		struct cpl_rx_data *cpl = (struct cpl_rx_data *)gl->va;
+
+		offset = sizeof(struct cpl_rx_data);
+		cxgbi_rx_cb_set_flag(pdu_cb, SKCBF_RX_DATA);
+
+		len = ntohs(cpl->len);
+	}
+
+	memcpy(&ssi->frags[i], &gl->frags[0], gl->nfrags * sizeof(skb_frag_t));
+	ssi->frags[i].page_offset += offset;
+	ssi->frags[i].size -= offset;
+	ssi->nr_frags += gl->nfrags;
+	pdu_cb->frags += gl->nfrags;
+
+	skb->len += len;
+	skb->data_len += len;
+	skb->truesize += len;
+
+	for (i = 0; i < gl->nfrags; i++)
+		get_page(gl->frags[i].page);
+}
+
+static inline int cxgbi_sock_check_rx_state(struct cxgbi_sock *csk)
+{
+	if (unlikely(csk->state >= CTP_PASSIVE_CLOSE)) {
+		log_debug(1 << CXGBI_DBG_TOE | 1 << CXGBI_DBG_SOCK,
+			  "csk 0x%p,%u,0x%lx,%u, bad state.\n",
+			  csk, csk->state, csk->flags, csk->tid);
+		if (csk->state != CTP_ABORTING)
+			send_abort_req(csk);
+		return -1;
+	}
+	return 0;
+}
+
+static void do_rx_iscsi_lro(struct cxgbi_sock *csk, struct sk_buff *skb)
+{
+	struct cxgbi_rx_lro_cb *lro_cb = cxgbi_skb_rx_lro_cb(skb);
+	struct cxgbi_rx_pdu_cb *pdu_cb = cxgbi_skb_rx_pdu_cb(skb, 0);
+
+	log_debug(1 << CXGBI_DBG_TOE | 1 << CXGBI_DBG_PDU_RX,
+		  "%s: csk 0x%p,%u,0x%lx, tid %u, skb 0x%p,%u, %u.\n",
+		  __func__, csk, csk->state, csk->flags, csk->tid, skb,
+		  skb->len, skb->data_len);
+
+	cxgbi_skcb_set_flag(skb, SKCBF_RX_LRO);
+
+	spin_lock_bh(&csk->lock);
+
+	if (cxgbi_sock_check_rx_state(csk) < 0)
+		goto discard;
+
+	if (cxgbi_rx_cb_test_flag(pdu_cb, SKCBF_RX_HDR) &&
+	    pdu_cb->seq != csk->rcv_nxt) {
+		pr_info("%s, csk 0x%p, tid 0x%x, seq 0x%x != 0x%x.\n",
+			__func__, csk, csk->tid, pdu_cb->seq, csk->rcv_nxt);
+		cxgbi_lro_skb_dump(skb);
+		goto abort_conn;
+	}
+
+	/* partial pdus */
+	if (!lro_cb->pdu_cnt) {
+		lro_cb->pdu_cnt = 1;
+	} else {
+		struct cxgbi_rx_pdu_cb *pdu_cb = cxgbi_skb_rx_pdu_cb(skb,
+							lro_cb->pdu_cnt);
+
+		if (!(cxgbi_rx_cb_test_flag(pdu_cb, SKCBF_RX_STATUS)) &&
+		    pdu_cb->frags)
+			lro_cb->pdu_cnt++;
+	}
+
+	csk->rcv_nxt += lro_cb->pdu_totallen;
+
+	skb_reset_transport_header(skb);
+	__skb_queue_tail(&csk->receive_queue, skb);
+
+	cxgbi_conn_pdu_ready(csk);
+	spin_unlock_bh(&csk->lock);
+
+	return;
+
+abort_conn:
+	send_abort_req(csk);
+discard:
+	spin_unlock_bh(&csk->lock);
+	__kfree_skb(skb);
+}
+
+static struct sk_buff *lro_init_skb(struct cxgbi_sock *csk, u8 op,
+				    const struct pkt_gl *gl, const __be64 *rsp)
+{
+	struct sk_buff *skb;
+	struct cxgbi_rx_lro_cb *lro_cb;
+
+	skb = alloc_skb(LRO_SKB_MAX_HEADROOM, GFP_ATOMIC);
+	if (unlikely(!skb))
+		return NULL;
+	memset(skb->data, 0, LRO_SKB_MAX_HEADROOM);
+
+	lro_cb = cxgbi_skb_rx_lro_cb(skb);
+	cxgbi_sock_get(csk);
+	lro_cb->csk = csk;
+
+	return skb;
+}
+
+static void lro_flush(struct t4_lro_mgr *lro_mgr, struct sk_buff *skb)
+{
+	struct cxgbi_rx_lro_cb *lro_cb = cxgbi_skb_rx_lro_cb(skb);
+	struct cxgbi_sock *csk = lro_cb->csk;
+
+	 /* Update head pointer */
+	if (skb == lro_mgr->skb_head) {
+		if (!skb->next) {
+			/* Only skb in the list */
+			lro_mgr->skb_head = NULL;
+			lro_mgr->skb_tail = NULL;
+		} else {
+			lro_mgr->skb_head = skb->next;
+		}
+	} else if (skb == lro_mgr->skb_tail) {
+		/* Update tail pointer */
+		skb->prev->next = NULL;
+		lro_mgr->skb_tail = skb->prev;
+	} else {
+		skb->prev->next = skb->next;
+		skb->next->prev = skb->prev;
+	}
+
+	csk->skb_lro = NULL;
+	do_rx_iscsi_lro(csk, skb);
+	cxgbi_sock_put(csk);
+
+	lro_mgr->lro_pkts++;
+	lro_mgr->lro_session_cnt--;
+}
+
+static int lro_receive(struct cxgbi_sock *csk, u8 op, const __be64 *rsp,
+		       const struct pkt_gl *gl, struct t4_lro_mgr *lro_mgr)
+{
+	struct sk_buff *skb;
+	struct cxgbi_rx_lro_cb *lro_cb;
+	struct cxgb4_lld_info *lldi = cxgbi_cdev_priv(csk->cdev);
+
+	if (!is_t5(lldi->adapter_type))
+		return -EOPNOTSUPP;
+
+	if (!csk) {
+		pr_err("%s: csk NULL, op 0x%x.\n", __func__, op);
+		goto out;
+	}
+
+	if (csk->skb_lro)
+		goto add_packet;
+
+start_lro:
+	/* Did we reach the hash size limit */
+	if (lro_mgr->lro_session_cnt >= MAX_LRO_SESSIONS)
+		goto out;
+
+	skb = lro_init_skb(csk, op, gl, rsp);
+	csk->skb_lro = skb;
+	if (unlikely(!skb))
+		goto out;
+	lro_mgr->lro_session_cnt++;
+
+	if (lro_mgr->skb_tail) {
+		lro_mgr->skb_tail->next = skb;
+		skb->prev = lro_mgr->skb_tail;
+	} else {
+		lro_mgr->skb_head = skb;
+	}
+	lro_mgr->skb_tail = skb;
+
+	/* continue to add the packet */
+add_packet:
+	skb = csk->skb_lro;
+	lro_cb = cxgbi_skb_rx_lro_cb(skb);
+
+	/* Check if this packet can be aggregated */
+	if ((gl && ((skb_shinfo(skb)->nr_frags + gl->nfrags) >= MAX_SKB_FRAGS ||
+		    lro_cb->pdu_totallen >= LRO_FLUSH_TOTALLEN_MAX)) ||
+	    /* lro_cb->pdu_cnt must be less than MAX_SKB_FRAGS */
+	    lro_cb->pdu_cnt >= (MAX_SKB_FRAGS - 1)) {
+		lro_flush(lro_mgr, skb);
+		goto start_lro;
+	}
+
+	if (gl)
+		lro_skb_add_packet_gl(skb, op, gl);
+	else
+		lro_skb_add_packet_rsp(skb, op, rsp);
+	lro_mgr->lro_merged++;
+
+	return 0;
+
+out:
+	return -1;
+}
+
+static int t4_uld_rx_lro_handler(void *hndl, const __be64 *rsp,
+				 const struct pkt_gl *gl,
+				 struct t4_lro_mgr *lro_mgr,
+				unsigned int napi_id)
+{
+	struct cxgbi_device *cdev = hndl;
+	struct cxgb4_lld_info *lldi = cxgbi_cdev_priv(cdev);
+	struct cpl_act_establish *rpl = NULL;
+	struct cxgbi_sock *csk = NULL;
+	unsigned int tid = 0;
+	struct sk_buff *skb;
+	unsigned int op = *(u8 *)rsp;
+
+	if (lro_mgr && (op != CPL_FW6_MSG) && (op != CPL_RX_PKT) &&
+	    (op != CPL_ACT_OPEN_RPL)) {
+		/* Get the TID of this connection */
+		rpl = gl ? (struct cpl_act_establish *)gl->va :
+				(struct cpl_act_establish *)(rsp + 1);
+		tid = GET_TID(rpl);
+		csk = lookup_tid(lldi->tids, tid);
+	}
+
+	/*
+	 * Flush the LROed skb on receiving any cpl other than FW4_ACK and
+	 * CPL_ISCSI_XXX
+	 */
+	if (csk && csk->skb_lro && op != CPL_FW6_MSG && op != CPL_ISCSI_HDR &&
+	    op != CPL_ISCSI_DATA && op != CPL_RX_ISCSI_DDP) {
+		lro_flush(lro_mgr, csk->skb_lro);
+	}
+
+	if (!gl) {
+		unsigned int len;
+
+		if (op == CPL_RX_ISCSI_DDP) {
+			if (!lro_receive(csk, op, rsp, NULL, lro_mgr))
+				return 0;
+		}
+
+		len = 64 - sizeof(struct rsp_ctrl) - 8;
+		skb = alloc_wr(len, 0, GFP_ATOMIC);
+		if (!skb)
+			goto nomem;
+		skb_copy_to_linear_data(skb, &rsp[1], len);
+	} else {
+		if (unlikely(op != *(u8 *)gl->va)) {
+			pr_info("? FL 0x%p,RSS%#llx,FL %#llx,len %u.\n",
+				gl->va, be64_to_cpu(*rsp),
+				be64_to_cpu(*(u64 *)gl->va),
+				gl->tot_len);
+			return 0;
+		}
+
+		if (op == CPL_ISCSI_HDR || op == CPL_ISCSI_DATA) {
+			if (!lro_receive(csk, op, rsp, gl, lro_mgr))
+				return 0;
+		}
+
+		skb = cxgb4_pktgl_to_skb(gl, RX_PULL_LEN, RX_PULL_LEN);
+		if (unlikely(!skb))
+			goto nomem;
+	}
+
+	rpl = (struct cpl_act_establish *)skb->data;
+	op = rpl->ot.opcode;
+	log_debug(1 << CXGBI_DBG_TOE,
+		  "cdev %p, opcode 0x%x(0x%x,0x%x), skb %p.\n",
+		  cdev, op, rpl->ot.opcode_tid, ntohl(rpl->ot.opcode_tid), skb);
+
+	if (op < NUM_CPL_CMDS && cxgb4i_cplhandlers[op]) {
+		cxgb4i_cplhandlers[op](cdev, skb);
+	} else {
+		pr_err("No handler for opcode 0x%x.\n", op);
+		__kfree_skb(skb);
+	}
+	return 0;
+nomem:
+	log_debug(1 << CXGBI_DBG_TOE, "OOM bailing out.\n");
+	return 1;
+}
+
+static void t4_uld_lro_flush_all(struct t4_lro_mgr *lro_mgr)
+{
+	struct sk_buff *skb = lro_mgr->skb_head;
+	struct sk_buff *temp;
+
+	while (skb) {
+		temp = skb->next;
+		lro_flush(lro_mgr, skb);
+		skb = temp;
+	}
+	lro_mgr->skb_head = NULL;
+	lro_mgr->skb_tail = NULL;
+}
+
+static const struct cxgb4_uld_info cxgb4i_uld_info = {
+	.name = DRV_MODULE_NAME,
+	.add = t4_uld_add,
+	.rx_handler = t4_uld_rx_handler,
+	.state_change = t4_uld_state_change,
+	.lro_rx_handler = t4_uld_rx_lro_handler,
+	.lro_flush = t4_uld_lro_flush_all,
+};
+
 static int __init cxgb4i_init_module(void)
 {
 	int rc;
-- 
2.3.4
