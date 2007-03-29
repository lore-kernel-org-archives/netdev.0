From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH 2.6.21] iw_cxgb3: Fix TERM codes.
Date: Thu, 29 Mar 2007 14:21:48 -0500
Message-ID: <1175196108.23273.35.camel@stevo-desktop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: OpenFabrics General <general@lists.openfabrics.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Netdev@vger.kernel.org
To: Roland Dreier <rolandd@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Fix TERM codes.

Fix TERMINATE layer, type, and ecode values based on
conformance testing.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/hw/cxgb3/iwch_qp.c |   69 ++++++++++++++++++---------------
 1 files changed, 38 insertions(+), 31 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb3/iwch_qp.c b/drivers/infiniband/hw/cxgb3/iwch_qp.c
index 0a472c9..714dddb 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_qp.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_qp.c
@@ -471,43 +471,62 @@ int iwch_bind_mw(struct ib_qp *qp,
 	return err;
 }
 
-static void build_term_codes(int t3err, u8 *layer_type, u8 *ecode, int tagged)
+static inline void build_term_codes(struct respQ_msg_t *rsp_msg,
+				    u8 *layer_type, u8 *ecode)
 {
-	switch (t3err) {
+	int status = TPT_ERR_INTERNAL_ERR;
+	int tagged = 0;
+	int opcode = -1;
+	int rqtype = 0;
+	int send_inv = 0;
+
+	if (rsp_msg) {
+		status = CQE_STATUS(rsp_msg->cqe);
+		opcode = CQE_OPCODE(rsp_msg->cqe);
+		rqtype = RQ_TYPE(rsp_msg->cqe);
+		send_inv = (opcode == T3_SEND_WITH_INV) ||
+		           (opcode == T3_SEND_WITH_SE_INV);
+		tagged = (opcode == T3_RDMA_WRITE) ||
+			 (rqtype && (opcode == T3_READ_RESP));
+	}
+
+	switch (status) {
 	case TPT_ERR_STAG:
-		if (tagged == 1) {
-			*layer_type = LAYER_DDP|DDP_TAGGED_ERR;
-			*ecode = DDPT_INV_STAG;
-		} else if (tagged == 2) {
+		if (send_inv) {
+			*layer_type = LAYER_RDMAP|RDMAP_REMOTE_OP;
+			*ecode = RDMAP_CANT_INV_STAG;
+		} else {
 			*layer_type = LAYER_RDMAP|RDMAP_REMOTE_PROT;
 			*ecode = RDMAP_INV_STAG;
 		}
 		break;
 	case TPT_ERR_PDID:
+		*layer_type = LAYER_RDMAP|RDMAP_REMOTE_PROT;
+		if ((opcode == T3_SEND_WITH_INV) ||
+		    (opcode == T3_SEND_WITH_SE_INV))
+			*ecode = RDMAP_CANT_INV_STAG;
+		else
+			*ecode = RDMAP_STAG_NOT_ASSOC;
+		break;
 	case TPT_ERR_QPID:
+		*layer_type = LAYER_RDMAP|RDMAP_REMOTE_PROT;
+		*ecode = RDMAP_STAG_NOT_ASSOC;
+		break;
 	case TPT_ERR_ACCESS:
-		if (tagged == 1) {
-			*layer_type = LAYER_DDP|DDP_TAGGED_ERR;
-			*ecode = DDPT_STAG_NOT_ASSOC;
-		} else if (tagged == 2) {
-			*layer_type = LAYER_RDMAP|RDMAP_REMOTE_PROT;
-			*ecode = RDMAP_STAG_NOT_ASSOC;
-		}
+		*layer_type = LAYER_RDMAP|RDMAP_REMOTE_PROT;
+		*ecode = RDMAP_ACC_VIOL;
 		break;
 	case TPT_ERR_WRAP:
 		*layer_type = LAYER_RDMAP|RDMAP_REMOTE_PROT;
 		*ecode = RDMAP_TO_WRAP;
 		break;
 	case TPT_ERR_BOUND:
-		if (tagged == 1) {
+		if (tagged) {
 			*layer_type = LAYER_DDP|DDP_TAGGED_ERR;
 			*ecode = DDPT_BASE_BOUNDS;
-		} else if (tagged == 2) {
+		} else {
 			*layer_type = LAYER_RDMAP|RDMAP_REMOTE_PROT;
 			*ecode = RDMAP_BASE_BOUNDS;
-		} else {
-			*layer_type = LAYER_DDP|DDP_UNTAGGED_ERR;
-			*ecode = DDPU_MSG_TOOBIG;
 		}
 		break;
 	case TPT_ERR_INVALIDATE_SHARED_MR:
@@ -591,8 +610,6 @@ int iwch_post_terminate(struct iwch_qp *
 {
 	union t3_wr *wqe;
 	struct terminate_message *term;
-	int status;
-	int tagged = 0;
 	struct sk_buff *skb;
 
 	PDBG("%s %d\n", __FUNCTION__, __LINE__);
@@ -610,17 +627,7 @@ int iwch_post_terminate(struct iwch_qp *
 
 	/* immediate data starts here. */
 	term = (struct terminate_message *)wqe->send.sgl;
-	if (rsp_msg) {
-		status = CQE_STATUS(rsp_msg->cqe);
-		if (CQE_OPCODE(rsp_msg->cqe) == T3_RDMA_WRITE)
-			tagged = 1;
-		if ((CQE_OPCODE(rsp_msg->cqe) == T3_READ_REQ) ||
-		    (CQE_OPCODE(rsp_msg->cqe) == T3_READ_RESP))
-			tagged = 2;
-	} else {
-		status = TPT_ERR_INTERNAL_ERR;
-	}
-	build_term_codes(status, &term->layer_etype, &term->ecode, tagged);
+	build_term_codes(rsp_msg, &term->layer_etype, &term->ecode);
 	build_fw_riwrh((void *)wqe, T3_WR_SEND,
 		       T3_COMPLETION_FLAG | T3_NOTIFY_FLAG, 1,
 		       qhp->ep->hwtid, 5);

