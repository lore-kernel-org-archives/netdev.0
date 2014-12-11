From: Karen Xie <kxie@chelsio.com>
Subject: [PATCH net v9 3/7] cxgb4/cxgb4i: set the max. pdu length in
 firmware
Date: Thu, 11 Dec 2014 07:25:46 -0800
Message-ID: <201412111525.sBBFPkiO012939@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kxie@chelsio.com, hariprasad@chelsio.com, anish@chelsio.com,
	hch@infradead.org, James.Bottomley@HansenPartnership.com,
	michaelc@cs.wisc.edu, davem@davemloft.net
To: linux-scsi@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:9115 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755167AbaLKP0d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 10:26:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karen Xie <kxie@chelsio.com>

Programs the firmware of the maximum outgoing iscsi pdu length per connection.

Signed-off-by: Karen Xie <kxie@chelsio.com>
---
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c |   69 +++++++++++++++++++++++++++---------
 1 files changed, 51 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index 3409756..743a350 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -529,6 +529,7 @@ enum fw_flowc_mnem {
 	FW_FLOWC_MNEM_RCVNXT,
 	FW_FLOWC_MNEM_SNDBUF,
 	FW_FLOWC_MNEM_MSS,
+	FW_FLOWC_MNEM_TXDATAPLEN_MAX,
 };
 
 struct fw_flowc_mnemval {
diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
index abee611..5f31eb7 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
@@ -75,6 +75,7 @@ typedef void (*cxgb4i_cplhandler_func)(struct cxgbi_device *, struct sk_buff *);
 static void *t4_uld_add(const struct cxgb4_lld_info *);
 static int t4_uld_rx_handler(void *, const __be64 *, const struct pkt_gl *);
 static int t4_uld_state_change(void *, enum cxgb4_state state);
+static inline int send_tx_flowc_wr(struct cxgbi_sock *);
 
 static const struct cxgb4_uld_info cxgb4i_uld_info = {
 	.name = DRV_MODULE_NAME,
@@ -391,6 +392,12 @@ static void send_abort_req(struct cxgbi_sock *csk)
 
 	if (unlikely(csk->state == CTP_ABORTING) || !skb || !csk->cdev)
 		return;
+
+	if (!cxgbi_sock_flag(csk, CTPF_TX_DATA_SENT)) {
+		send_tx_flowc_wr(csk);
+		cxgbi_sock_set_flag(csk, CTPF_TX_DATA_SENT);
+	}
+
 	cxgbi_sock_set_state(csk, CTP_ABORTING);
 	cxgbi_sock_set_flag(csk, CTPF_ABORT_RPL_PENDING);
 	cxgbi_sock_purge_write_queue(csk);
@@ -493,20 +500,40 @@ static inline unsigned int calc_tx_flits_ofld(const struct sk_buff *skb)
 	return flits + sgl_len(cnt);
 }
 
-static inline void send_tx_flowc_wr(struct cxgbi_sock *csk)
+#define FLOWC_WR_NPARAMS_MIN   9
+static inline int tx_flowc_wr_credits(int *nparamsp, int *flowclenp)
+{
+	int nparams, flowclen16, flowclen;
+
+	nparams = FLOWC_WR_NPARAMS_MIN;
+	flowclen = offsetof(struct fw_flowc_wr, mnemval[nparams]);
+	flowclen16 = DIV_ROUND_UP(flowclen, 16);
+	flowclen = flowclen16 * 16;
+	/*
+	 * Return the number of 16-byte credits used by the FlowC request.
+	 * Pass back the nparams and actual FlowC length if requested.
+	 */
+	if (nparamsp)
+		*nparamsp = nparams;
+	if (flowclenp)
+		*flowclenp = flowclen;
+
+	return flowclen16;
+}
+
+static inline int send_tx_flowc_wr(struct cxgbi_sock *csk)
 {
 	struct sk_buff *skb;
 	struct fw_flowc_wr *flowc;
-	int flowclen, i;
+	int nparams, flowclen16, flowclen;
 
-	flowclen = 80;
+	flowclen16 = tx_flowc_wr_credits(&nparams, &flowclen);
 	skb = alloc_wr(flowclen, 0, GFP_ATOMIC);
 	flowc = (struct fw_flowc_wr *)skb->head;
 	flowc->op_to_nparams =
-		htonl(FW_WR_OP(FW_FLOWC_WR) | FW_FLOWC_WR_NPARAMS(8));
+		htonl(FW_WR_OP(FW_FLOWC_WR) | FW_FLOWC_WR_NPARAMS(nparams));
 	flowc->flowid_len16 =
-		htonl(FW_WR_LEN16(DIV_ROUND_UP(72, 16)) |
-				FW_WR_FLOWID(csk->tid));
+		htonl(FW_WR_LEN16(flowclen16) | FW_WR_FLOWID(csk->tid));
 	flowc->mnemval[0].mnemonic = FW_FLOWC_MNEM_PFNVFN;
 	flowc->mnemval[0].val = htonl(csk->cdev->pfvf);
 	flowc->mnemval[1].mnemonic = FW_FLOWC_MNEM_CH;
@@ -525,11 +552,9 @@ static inline void send_tx_flowc_wr(struct cxgbi_sock *csk)
 	flowc->mnemval[7].val = htonl(csk->advmss);
 	flowc->mnemval[8].mnemonic = 0;
 	flowc->mnemval[8].val = 0;
-	for (i = 0; i < 9; i++) {
-		flowc->mnemval[i].r4[0] = 0;
-		flowc->mnemval[i].r4[1] = 0;
-		flowc->mnemval[i].r4[2] = 0;
-	}
+	flowc->mnemval[8].mnemonic = FW_FLOWC_MNEM_TXDATAPLEN_MAX;
+	flowc->mnemval[8].val = 16384;
+
 	set_queue(skb, CPL_PRIORITY_DATA, csk);
 
 	log_debug(1 << CXGBI_DBG_TOE | 1 << CXGBI_DBG_SOCK,
@@ -539,6 +564,8 @@ static inline void send_tx_flowc_wr(struct cxgbi_sock *csk)
 		csk->advmss);
 
 	cxgb4_ofld_send(csk->cdev->ports[csk->port_id], skb);
+
+	return flowclen16;
 }
 
 static inline void make_tx_data_wr(struct cxgbi_sock *csk, struct sk_buff *skb,
@@ -599,6 +626,7 @@ static int push_tx_frames(struct cxgbi_sock *csk, int req_completion)
 		int dlen = skb->len;
 		int len = skb->len;
 		unsigned int credits_needed;
+		int flowclen16 = 0;
 
 		skb_reset_transport_header(skb);
 		if (is_ofld_imm(skb))
@@ -613,6 +641,17 @@ static int push_tx_frames(struct cxgbi_sock *csk, int req_completion)
 					sizeof(struct fw_ofld_tx_data_wr),
 					16);
 
+		/*
+		 * Assumes the initial credits is large enough to support
+		 * fw_flowc_wr plus largest possible first payload
+		 */
+		if (!cxgbi_sock_flag(csk, CTPF_TX_DATA_SENT)) {
+			flowclen16 = send_tx_flowc_wr(csk);
+			csk->wr_cred -= flowclen16;
+			csk->wr_una_cred += flowclen16;
+			cxgbi_sock_set_flag(csk, CTPF_TX_DATA_SENT);
+		}
+
 		if (csk->wr_cred < credits_needed) {
 			log_debug(1 << CXGBI_DBG_PDU_TX,
 				"csk 0x%p, skb %u/%u, wr %d < %u.\n",
@@ -622,7 +661,7 @@ static int push_tx_frames(struct cxgbi_sock *csk, int req_completion)
 		}
 		__skb_unlink(skb, &csk->write_queue);
 		set_queue(skb, CPL_PRIORITY_DATA, csk);
-		skb->csum = credits_needed;
+		skb->csum = credits_needed + flowclen16;
 		csk->wr_cred -= credits_needed;
 		csk->wr_una_cred += credits_needed;
 		cxgbi_sock_enqueue_wr(csk, skb);
@@ -633,12 +672,6 @@ static int push_tx_frames(struct cxgbi_sock *csk, int req_completion)
 			csk->wr_cred, csk->wr_una_cred);
 
 		if (likely(cxgbi_skcb_test_flag(skb, SKCBF_TX_NEED_HDR))) {
-			if (!cxgbi_sock_flag(csk, CTPF_TX_DATA_SENT)) {
-				send_tx_flowc_wr(csk);
-				skb->csum += 5;
-				csk->wr_cred -= 5;
-				csk->wr_una_cred += 5;
-			}
 			len += cxgbi_ulp_extra_len(cxgbi_skcb_ulp_mode(skb));
 			make_tx_data_wr(csk, skb, dlen, len, credits_needed,
 					req_completion);
