From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 4/6] qed: Move doorbell calculation from VF to PF
Date: Sun, 5 Jun 2016 13:11:14 +0300
Message-ID: <1465121476-32494-5-git-send-email-Yuval.Mintz@qlogic.com>
References: <1465121476-32494-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:61102 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751126AbcFEKLj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2016 06:11:39 -0400
In-Reply-To: <1465121476-32494-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Today, the VF is aware of its queues context-ids, and calculates the
doorbell address when opening its queues on its own.
The configuration of doorbells in HW can sometime in the future be changed
by the PF [hw has several configurable features that might affect doorbell
addresses, e.g., dpm support], this would break compatibility with older
VFs as their calculated doorbell addresses would be incorrect for such a
configuration.

In order to avoid such a backward compatibility failure, let the PF make
the calculation of the doorbell offset based on the context-id, and pass
that to the VF.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_sriov.c | 29 ++++++++++++++++++++++++++---
 drivers/net/ethernet/qlogic/qed/qed_vf.c    | 20 ++++++++++++--------
 2 files changed, 38 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index a1e40bb..0094f86 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -1763,11 +1763,35 @@ out:
 	qed_iov_vf_mbx_start_rxq_resp(p_hwfn, p_ptt, vf, status);
 }
 
+static void qed_iov_vf_mbx_start_txq_resp(struct qed_hwfn *p_hwfn,
+					  struct qed_ptt *p_ptt,
+					  struct qed_vf_info *p_vf, u8 status)
+{
+	struct qed_iov_vf_mbx *mbx = &p_vf->vf_mbx;
+	struct pfvf_start_queue_resp_tlv *p_tlv;
+
+	mbx->offset = (u8 *)mbx->reply_virt;
+
+	p_tlv = qed_add_tlv(p_hwfn, &mbx->offset, CHANNEL_TLV_START_TXQ,
+			    sizeof(*p_tlv));
+	qed_add_tlv(p_hwfn, &mbx->offset, CHANNEL_TLV_LIST_END,
+		    sizeof(struct channel_list_end_tlv));
+
+	/* Update the TLV with the response */
+	if (status == PFVF_STATUS_SUCCESS) {
+		u16 qid = mbx->req_virt->start_txq.tx_qid;
+
+		p_tlv->offset = qed_db_addr(p_vf->vf_queues[qid].fw_cid,
+					    DQ_DEMS_LEGACY);
+	}
+
+	qed_iov_send_response(p_hwfn, p_ptt, p_vf, sizeof(*p_tlv), status);
+}
+
 static void qed_iov_vf_mbx_start_txq(struct qed_hwfn *p_hwfn,
 				     struct qed_ptt *p_ptt,
 				     struct qed_vf_info *vf)
 {
-	u16 length = sizeof(struct pfvf_def_resp_tlv);
 	struct qed_queue_start_common_params params;
 	struct qed_iov_vf_mbx *mbx = &vf->vf_mbx;
 	u8 status = PFVF_STATUS_NO_RESOURCE;
@@ -1808,8 +1832,7 @@ static void qed_iov_vf_mbx_start_txq(struct qed_hwfn *p_hwfn,
 	}
 
 out:
-	qed_iov_prepare_resp(p_hwfn, p_ptt, vf, CHANNEL_TLV_START_TXQ,
-			     length, status);
+	qed_iov_vf_mbx_start_txq_resp(p_hwfn, p_ptt, vf, status);
 }
 
 static int qed_iov_vf_stop_rxqs(struct qed_hwfn *p_hwfn,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_vf.c b/drivers/net/ethernet/qlogic/qed/qed_vf.c
index 46751ce..9819230 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_vf.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_vf.c
@@ -440,8 +440,8 @@ int qed_vf_pf_txq_start(struct qed_hwfn *p_hwfn,
 			u16 pbl_size, void __iomem **pp_doorbell)
 {
 	struct qed_vf_iov *p_iov = p_hwfn->vf_iov_info;
+	struct pfvf_start_queue_resp_tlv *resp;
 	struct vfpf_start_txq_tlv *req;
-	struct pfvf_def_resp_tlv *resp;
 	int rc;
 
 	/* clear mailbox and prep first tlv */
@@ -459,20 +459,24 @@ int qed_vf_pf_txq_start(struct qed_hwfn *p_hwfn,
 	qed_add_tlv(p_hwfn, &p_iov->offset,
 		    CHANNEL_TLV_LIST_END, sizeof(struct channel_list_end_tlv));
 
-	resp = &p_iov->pf2vf_reply->default_resp;
+	resp = &p_iov->pf2vf_reply->queue_start;
 	rc = qed_send_msg2pf(p_hwfn, &resp->hdr.status, sizeof(*resp));
 	if (rc)
-		return rc;
+		goto exit;
 
-	if (resp->hdr.status != PFVF_STATUS_SUCCESS)
-		return -EINVAL;
+	if (resp->hdr.status != PFVF_STATUS_SUCCESS) {
+		rc = -EINVAL;
+		goto exit;
+	}
 
 	if (pp_doorbell) {
-		u8 cid = p_iov->acquire_resp.resc.cid[tx_queue_id];
+		*pp_doorbell = (u8 __iomem *)p_hwfn->doorbells + resp->offset;
 
-		*pp_doorbell = (u8 __iomem *)p_hwfn->doorbells +
-					     qed_db_addr(cid, DQ_DEMS_LEGACY);
+		DP_VERBOSE(p_hwfn, QED_MSG_IOV,
+			   "Txq[0x%02x]: doorbell at %p [offset 0x%08x]\n",
+			   tx_queue_id, *pp_doorbell, resp->offset);
 	}
+exit:
 
 	return rc;
 }
-- 
1.9.3
