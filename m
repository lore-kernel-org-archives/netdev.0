From: "Ariel Elior" <ariele@broadcom.com>
Subject: [PATCH net-next v4 18/22] bnx2x: Support of PF driver of a VF
 close request
Date: Sun, 30 Dec 2012 21:57:18 +0200
Message-ID: <1356897442-3063-19-git-send-email-ariele@broadcom.com>
References: <1356897442-3063-1-git-send-email-ariele@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Ariel Elior" <ariele@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3268 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755214Ab2L3TzG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Dec 2012 14:55:06 -0500
In-Reply-To: <1356897442-3063-1-git-send-email-ariele@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 'close' command is the opposite of an init request. Here the
queues of the VF are closed (if any are opened) and released.
This flow applies the 'q_teardown' flow on all the queues.
The VF state is changed by this request.
Interrupts are disabled for the VF when closed.

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c |   97 +++++++++++++++++++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h |    4 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c  |   27 ++++++
 3 files changed, 128 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index 9fd43c0..3dd3a6a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -139,6 +139,11 @@ enum bnx2x_vfop_mcast_state {
 	   BNX2X_VFOP_MCAST_CHK_DONE
 };
 
+enum bnx2x_vfop_close_state {
+	   BNX2X_VFOP_CLOSE_QUEUES,
+	   BNX2X_VFOP_CLOSE_HW
+};
+
 enum bnx2x_vfop_rxmode_state {
 	   BNX2X_VFOP_RXMODE_CONFIG,
 	   BNX2X_VFOP_RXMODE_DONE
@@ -2300,6 +2305,28 @@ static void bnx2x_vf_qtbl_set_q(struct bnx2x *bp, u8 abs_vfid, u8 qid,
 	REG_WR(bp, reg, val);
 }
 
+static void bnx2x_vf_clr_qtbl(struct bnx2x *bp, struct bnx2x_virtf *vf)
+{
+	int i;
+
+	for_each_vfq(vf, i)
+		bnx2x_vf_qtbl_set_q(bp, vf->abs_vfid,
+				    vfq_qzone_id(vf, vfq_get(vf, i)), false);
+}
+
+static void bnx2x_vf_igu_disable(struct bnx2x *bp, struct bnx2x_virtf *vf)
+{
+	u32 val;
+
+	/* clear the VF configuration - pretend */
+	bnx2x_pretend_func(bp, HW_VF_HANDLE(bp, vf->abs_vfid));
+	val = REG_RD(bp, IGU_REG_VF_CONFIGURATION);
+	val &= ~(IGU_VF_CONF_MSI_MSIX_EN | IGU_VF_CONF_SINGLE_ISR_EN |
+		 IGU_VF_CONF_FUNC_EN | IGU_VF_CONF_PARENT_MASK);
+	REG_WR(bp, IGU_REG_VF_CONFIGURATION, val);
+	bnx2x_pretend_func(bp, BP_ABS_FUNC(bp));
+}
+
 u8 bnx2x_vf_max_queue_cnt(struct bnx2x *bp, struct bnx2x_virtf *vf)
 {
 	return min_t(u8, min_t(u8, vf_sb_count(vf), BNX2X_CIDS_PER_VF),
@@ -2469,6 +2496,76 @@ int bnx2x_vf_init(struct bnx2x *bp, struct bnx2x_virtf *vf, dma_addr_t *sb_map)
 	return 0;
 }
 
+/* VFOP close (teardown the queues, delete mcasts and close HW) */
+static void bnx2x_vfop_close(struct bnx2x *bp, struct bnx2x_virtf *vf)
+{
+	struct bnx2x_vfop *vfop = bnx2x_vfop_cur(bp, vf);
+	struct bnx2x_vfop_args_qx *qx = &vfop->args.qx;
+	enum bnx2x_vfop_close_state state = vfop->state;
+	struct bnx2x_vfop_cmd cmd = {
+		.done = bnx2x_vfop_close,
+		.block = false,
+	};
+
+	if (vfop->rc < 0)
+		goto op_err;
+
+	DP(BNX2X_MSG_IOV, "vf[%d] STATE: %d\n", vf->abs_vfid, state);
+
+	switch (state) {
+	case BNX2X_VFOP_CLOSE_QUEUES:
+
+		if (++(qx->qid) < vf_rxq_count(vf)) {
+			vfop->rc = bnx2x_vfop_qdown_cmd(bp, vf, &cmd, qx->qid);
+			if (vfop->rc)
+				goto op_err;
+			return;
+		}
+
+		/* remove multicasts */
+		vfop->state = BNX2X_VFOP_CLOSE_HW;
+		vfop->rc = bnx2x_vfop_mcast_cmd(bp, vf, &cmd, NULL, 0, false);
+		if (vfop->rc)
+			goto op_err;
+		return;
+
+	case BNX2X_VFOP_CLOSE_HW:
+
+		/* disable the interrupts */
+		DP(BNX2X_MSG_IOV, "disabling igu\n");
+		bnx2x_vf_igu_disable(bp, vf);
+
+		/* disable the VF */
+		DP(BNX2X_MSG_IOV, "clearing qtbl\n");
+		bnx2x_vf_clr_qtbl(bp, vf);
+
+		goto op_done;
+	default:
+		bnx2x_vfop_default(state);
+	}
+op_err:
+	BNX2X_ERR("VF[%d] CLOSE error: rc %d\n", vf->abs_vfid, vfop->rc);
+op_done:
+	vf->state = VF_ACQUIRED;
+	DP(BNX2X_MSG_IOV, "set state to acquired\n");
+	bnx2x_vfop_end(bp, vf, vfop);
+}
+
+int bnx2x_vfop_close_cmd(struct bnx2x *bp,
+			 struct bnx2x_virtf *vf,
+			 struct bnx2x_vfop_cmd *cmd)
+{
+	struct bnx2x_vfop *vfop = bnx2x_vfop_add(bp, vf);
+	if (vfop) {
+		vfop->args.qx.qid = -1; /* loop */
+		bnx2x_vfop_opset(BNX2X_VFOP_CLOSE_QUEUES,
+				 bnx2x_vfop_close, cmd->done);
+		return bnx2x_vfop_transition(bp, vf, bnx2x_vfop_close,
+					     cmd->block);
+	}
+	return -ENOMEM;
+}
+
 void bnx2x_lock_vf_pf_channel(struct bnx2x *bp, struct bnx2x_virtf *vf,
 			      enum channel_tlvs tlv)
 {
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
index 9f0099c..d2a65d6 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
@@ -657,6 +657,10 @@ int bnx2x_vfop_rxmode_cmd(struct bnx2x *bp,
 			  struct bnx2x_vfop_cmd *cmd,
 			  int qid, unsigned long accept_flags);
 
+int bnx2x_vfop_close_cmd(struct bnx2x *bp,
+			 struct bnx2x_virtf *vf,
+			 struct bnx2x_vfop_cmd *cmd);
+
 int bnx2x_vf_idx_by_abs_fid(struct bnx2x *bp, u16 abs_vfid);
 u8 bnx2x_vf_max_queue_cnt(struct bnx2x *bp, struct bnx2x_virtf *vf);
 /* VF FLR helpers */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
index af30eb4..e8d3d8c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
@@ -804,6 +804,30 @@ static void bnx2x_vf_mbx_teardown_q(struct bnx2x *bp, struct bnx2x_virtf *vf,
 		bnx2x_vf_mbx_resp(bp, vf);
 }
 
+/* Done handler for 'close' operation: send response and reopen the
+ * channel.
+ */
+static void bnx2x_vf_mbx_close_done(struct bnx2x *bp, struct bnx2x_virtf *vf)
+{
+	bnx2x_vf_mbx_resp(bp, vf);
+	bnx2x_vf_enable_mbx(bp, vf->abs_vfid);
+}
+
+static void bnx2x_vf_mbx_close_vf(struct bnx2x *bp, struct bnx2x_virtf *vf,
+				  struct bnx2x_vf_mbx *mbx)
+{
+	struct bnx2x_vfop_cmd cmd = {
+		.done = bnx2x_vf_mbx_close_done,
+		.block = false,
+	};
+
+	DP(BNX2X_MSG_IOV, "VF[%d] VF_CLOSE\n", vf->abs_vfid);
+
+	vf->op_rc = bnx2x_vfop_close_cmd(bp, vf, &cmd);
+	if (vf->op_rc)
+		bnx2x_vf_mbx_close_done(bp, vf);
+}
+
 /* dispatch request */
 static void bnx2x_vf_mbx_request(struct bnx2x *bp, struct bnx2x_virtf *vf,
 				  struct bnx2x_vf_mbx *mbx)
@@ -834,6 +858,9 @@ static void bnx2x_vf_mbx_request(struct bnx2x *bp, struct bnx2x_virtf *vf,
 		case CHANNEL_TLV_TEARDOWN_Q:
 			bnx2x_vf_mbx_teardown_q(bp, vf, mbx);
 			break;
+		case CHANNEL_TLV_CLOSE:
+			bnx2x_vf_mbx_teardown_q(bp, vf, mbx);
+			break;
 		}
 
 	} else {
-- 
1.7.9.GIT
