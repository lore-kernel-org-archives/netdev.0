From: Steve Wise <swise@opengridcomputing.com>
Subject: [ofa-general] [PATCH 2.6.22 1/5] iw_cxgb3: Fix TERM codes.
Date: Thu, 26 Apr 2007 15:21:02 -0500
Message-ID: <20070426202102.24234.87832.stgit@dell3.ogc.int>
References: <20070426202057.24234.56383.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org, divy@chelsio.com,
	linux-kernel@vger.kernel.org
To: rdreier@cisco.com,jeff@garzik.org
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070426202057.24234.56383.stgit@dell3.ogc.int>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org


Fix TERM codes.

Fix TERMINATE layer, type, and ecode values based on
conformance testing.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/hw/cxgb3/iwch_qp.c |   69 ++++++++++++++++++---------=
------
 1 files changed, 38 insertions(+), 31 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb3/iwch_qp.c b/drivers/infiniband/h=
w/cxgb3/iwch_qp.c
index 0a472c9..714dddb 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_qp.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_qp.c
@@ -471,43 +471,62 @@ int iwch_bind_mw(struct ib_qp *qp,
 	return err;
 }
=20
-static void build_term_codes(int t3err, u8 *layer_type, u8 *ecode, int t=
agged)
+static inline void build_term_codes(struct respQ_msg_t *rsp_msg,
+				    u8 *layer_type, u8 *ecode)
 {
-	switch (t3err) {
+	int status =3D TPT_ERR_INTERNAL_ERR;
+	int tagged =3D 0;
+	int opcode =3D -1;
+	int rqtype =3D 0;
+	int send_inv =3D 0;
+
+	if (rsp_msg) {
+		status =3D CQE_STATUS(rsp_msg->cqe);
+		opcode =3D CQE_OPCODE(rsp_msg->cqe);
+		rqtype =3D RQ_TYPE(rsp_msg->cqe);
+		send_inv =3D (opcode =3D=3D T3_SEND_WITH_INV) ||
+		           (opcode =3D=3D T3_SEND_WITH_SE_INV);
+		tagged =3D (opcode =3D=3D T3_RDMA_WRITE) ||
+			 (rqtype && (opcode =3D=3D T3_READ_RESP));
+	}
+
+	switch (status) {
 	case TPT_ERR_STAG:
-		if (tagged =3D=3D 1) {
-			*layer_type =3D LAYER_DDP|DDP_TAGGED_ERR;
-			*ecode =3D DDPT_INV_STAG;
-		} else if (tagged =3D=3D 2) {
+		if (send_inv) {
+			*layer_type =3D LAYER_RDMAP|RDMAP_REMOTE_OP;
+			*ecode =3D RDMAP_CANT_INV_STAG;
+		} else {
 			*layer_type =3D LAYER_RDMAP|RDMAP_REMOTE_PROT;
 			*ecode =3D RDMAP_INV_STAG;
 		}
 		break;
 	case TPT_ERR_PDID:
+		*layer_type =3D LAYER_RDMAP|RDMAP_REMOTE_PROT;
+		if ((opcode =3D=3D T3_SEND_WITH_INV) ||
+		    (opcode =3D=3D T3_SEND_WITH_SE_INV))
+			*ecode =3D RDMAP_CANT_INV_STAG;
+		else
+			*ecode =3D RDMAP_STAG_NOT_ASSOC;
+		break;
 	case TPT_ERR_QPID:
+		*layer_type =3D LAYER_RDMAP|RDMAP_REMOTE_PROT;
+		*ecode =3D RDMAP_STAG_NOT_ASSOC;
+		break;
 	case TPT_ERR_ACCESS:
-		if (tagged =3D=3D 1) {
-			*layer_type =3D LAYER_DDP|DDP_TAGGED_ERR;
-			*ecode =3D DDPT_STAG_NOT_ASSOC;
-		} else if (tagged =3D=3D 2) {
-			*layer_type =3D LAYER_RDMAP|RDMAP_REMOTE_PROT;
-			*ecode =3D RDMAP_STAG_NOT_ASSOC;
-		}
+		*layer_type =3D LAYER_RDMAP|RDMAP_REMOTE_PROT;
+		*ecode =3D RDMAP_ACC_VIOL;
 		break;
 	case TPT_ERR_WRAP:
 		*layer_type =3D LAYER_RDMAP|RDMAP_REMOTE_PROT;
 		*ecode =3D RDMAP_TO_WRAP;
 		break;
 	case TPT_ERR_BOUND:
-		if (tagged =3D=3D 1) {
+		if (tagged) {
 			*layer_type =3D LAYER_DDP|DDP_TAGGED_ERR;
 			*ecode =3D DDPT_BASE_BOUNDS;
-		} else if (tagged =3D=3D 2) {
+		} else {
 			*layer_type =3D LAYER_RDMAP|RDMAP_REMOTE_PROT;
 			*ecode =3D RDMAP_BASE_BOUNDS;
-		} else {
-			*layer_type =3D LAYER_DDP|DDP_UNTAGGED_ERR;
-			*ecode =3D DDPU_MSG_TOOBIG;
 		}
 		break;
 	case TPT_ERR_INVALIDATE_SHARED_MR:
@@ -591,8 +610,6 @@ int iwch_post_terminate(struct iwch_qp *
 {
 	union t3_wr *wqe;
 	struct terminate_message *term;
-	int status;
-	int tagged =3D 0;
 	struct sk_buff *skb;
=20
 	PDBG("%s %d\n", __FUNCTION__, __LINE__);
@@ -610,17 +627,7 @@ int iwch_post_terminate(struct iwch_qp *
=20
 	/* immediate data starts here. */
 	term =3D (struct terminate_message *)wqe->send.sgl;
-	if (rsp_msg) {
-		status =3D CQE_STATUS(rsp_msg->cqe);
-		if (CQE_OPCODE(rsp_msg->cqe) =3D=3D T3_RDMA_WRITE)
-			tagged =3D 1;
-		if ((CQE_OPCODE(rsp_msg->cqe) =3D=3D T3_READ_REQ) ||
-		    (CQE_OPCODE(rsp_msg->cqe) =3D=3D T3_READ_RESP))
-			tagged =3D 2;
-	} else {
-		status =3D TPT_ERR_INTERNAL_ERR;
-	}
-	build_term_codes(status, &term->layer_etype, &term->ecode, tagged);
+	build_term_codes(rsp_msg, &term->layer_etype, &term->ecode);
 	build_fw_riwrh((void *)wqe, T3_WR_SEND,
 		       T3_COMPLETION_FLAG | T3_NOTIFY_FLAG, 1,
 		       qhp->ep->hwtid, 5);
