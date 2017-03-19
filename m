From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 6/9] qed: Deprecate VF multiple queue-stop
Date: Sun, 19 Mar 2017 13:08:17 +0200
Message-ID: <1489921700-6850-7-git-send-email-Yuval.Mintz@cavium.com>
References: <1489921700-6850-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:45813 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752006AbdCSLIx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Mar 2017 07:08:53 -0400
In-Reply-To: <1489921700-6850-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PF<->VF interface allows for the VF to request
multiple queues closure via a single message, but this has
never been used by any official driver.

We now deprecate this option, forcing each queue close
to arrive via a different command; This would be required
for future TLVs that are going to extend the queue TLVs with
additional information on a per-queue basis.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_sriov.c | 104 ++++++++++++++++------------
 drivers/net/ethernet/qlogic/qed/qed_vf.h    |   4 ++
 2 files changed, 62 insertions(+), 46 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index 7547a23..f8498a3 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -2118,57 +2118,53 @@ static void qed_iov_vf_mbx_start_txq(struct qed_hwfn *p_hwfn,
 
 static int qed_iov_vf_stop_rxqs(struct qed_hwfn *p_hwfn,
 				struct qed_vf_info *vf,
-				u16 rxq_id, u8 num_rxqs, bool cqe_completion)
+				u16 rxq_id, bool cqe_completion)
 {
 	struct qed_vf_q_info *p_queue;
 	int rc = 0;
-	int qid;
 
-	if (rxq_id + num_rxqs > ARRAY_SIZE(vf->vf_queues))
+	if (!qed_iov_validate_rxq(p_hwfn, vf, rxq_id,
+				  QED_IOV_VALIDATE_Q_ENABLE)) {
+		DP_VERBOSE(p_hwfn,
+			   QED_MSG_IOV,
+			   "VF[%d] Tried Closing Rx 0x%04x which is inactive\n",
+			   vf->relative_vf_id, rxq_id);
 		return -EINVAL;
+	}
 
-	for (qid = rxq_id; qid < rxq_id + num_rxqs; qid++) {
-		p_queue = &vf->vf_queues[qid];
-
-		if (!p_queue->p_rx_cid)
-			continue;
+	p_queue = &vf->vf_queues[rxq_id];
 
-		rc = qed_eth_rx_queue_stop(p_hwfn,
-					   p_queue->p_rx_cid,
-					   false, cqe_completion);
-		if (rc)
-			return rc;
+	rc = qed_eth_rx_queue_stop(p_hwfn,
+				   p_queue->p_rx_cid,
+				   false, cqe_completion);
+	if (rc)
+		return rc;
 
-		vf->vf_queues[qid].p_rx_cid = NULL;
-		vf->num_active_rxqs--;
-	}
+	p_queue->p_rx_cid = NULL;
+	vf->num_active_rxqs--;
 
-	return rc;
+	return 0;
 }
 
 static int qed_iov_vf_stop_txqs(struct qed_hwfn *p_hwfn,
-				struct qed_vf_info *vf, u16 txq_id, u8 num_txqs)
+				struct qed_vf_info *vf, u16 txq_id)
 {
-	int rc = 0;
 	struct qed_vf_q_info *p_queue;
-	int qid;
+	int rc = 0;
 
-	if (txq_id + num_txqs > ARRAY_SIZE(vf->vf_queues))
+	if (!qed_iov_validate_txq(p_hwfn, vf, txq_id,
+				  QED_IOV_VALIDATE_Q_ENABLE))
 		return -EINVAL;
 
-	for (qid = txq_id; qid < txq_id + num_txqs; qid++) {
-		p_queue = &vf->vf_queues[qid];
-		if (!p_queue->p_tx_cid)
-			continue;
+	p_queue = &vf->vf_queues[txq_id];
 
-		rc = qed_eth_tx_queue_stop(p_hwfn, p_queue->p_tx_cid);
-		if (rc)
-			return rc;
+	rc = qed_eth_tx_queue_stop(p_hwfn, p_queue->p_tx_cid);
+	if (rc)
+		return rc;
 
-		p_queue->p_tx_cid = NULL;
-	}
+	p_queue->p_tx_cid = NULL;
 
-	return rc;
+	return 0;
 }
 
 static void qed_iov_vf_mbx_stop_rxqs(struct qed_hwfn *p_hwfn,
@@ -2177,20 +2173,28 @@ static void qed_iov_vf_mbx_stop_rxqs(struct qed_hwfn *p_hwfn,
 {
 	u16 length = sizeof(struct pfvf_def_resp_tlv);
 	struct qed_iov_vf_mbx *mbx = &vf->vf_mbx;
-	u8 status = PFVF_STATUS_SUCCESS;
+	u8 status = PFVF_STATUS_FAILURE;
 	struct vfpf_stop_rxqs_tlv *req;
 	int rc;
 
-	/* We give the option of starting from qid != 0, in this case we
-	 * need to make sure that qid + num_qs doesn't exceed the actual
-	 * amount of queues that exist.
+	/* There has never been an official driver that used this interface
+	 * for stopping multiple queues, and it is now considered deprecated.
+	 * Validate this isn't used here.
 	 */
 	req = &mbx->req_virt->stop_rxqs;
-	rc = qed_iov_vf_stop_rxqs(p_hwfn, vf, req->rx_qid,
-				  req->num_rxqs, req->cqe_completion);
-	if (rc)
-		status = PFVF_STATUS_FAILURE;
+	if (req->num_rxqs != 1) {
+		DP_VERBOSE(p_hwfn, QED_MSG_IOV,
+			   "Odd; VF[%d] tried stopping multiple Rx queues\n",
+			   vf->relative_vf_id);
+		status = PFVF_STATUS_NOT_SUPPORTED;
+		goto out;
+	}
 
+	rc = qed_iov_vf_stop_rxqs(p_hwfn, vf, req->rx_qid,
+				  req->cqe_completion);
+	if (!rc)
+		status = PFVF_STATUS_SUCCESS;
+out:
 	qed_iov_prepare_resp(p_hwfn, p_ptt, vf, CHANNEL_TLV_STOP_RXQS,
 			     length, status);
 }
@@ -2201,19 +2205,27 @@ static void qed_iov_vf_mbx_stop_txqs(struct qed_hwfn *p_hwfn,
 {
 	u16 length = sizeof(struct pfvf_def_resp_tlv);
 	struct qed_iov_vf_mbx *mbx = &vf->vf_mbx;
-	u8 status = PFVF_STATUS_SUCCESS;
+	u8 status = PFVF_STATUS_FAILURE;
 	struct vfpf_stop_txqs_tlv *req;
 	int rc;
 
-	/* We give the option of starting from qid != 0, in this case we
-	 * need to make sure that qid + num_qs doesn't exceed the actual
-	 * amount of queues that exist.
+	/* There has never been an official driver that used this interface
+	 * for stopping multiple queues, and it is now considered deprecated.
+	 * Validate this isn't used here.
 	 */
 	req = &mbx->req_virt->stop_txqs;
-	rc = qed_iov_vf_stop_txqs(p_hwfn, vf, req->tx_qid, req->num_txqs);
-	if (rc)
-		status = PFVF_STATUS_FAILURE;
+	if (req->num_txqs != 1) {
+		DP_VERBOSE(p_hwfn, QED_MSG_IOV,
+			   "Odd; VF[%d] tried stopping multiple Tx queues\n",
+			   vf->relative_vf_id);
+		status = PFVF_STATUS_NOT_SUPPORTED;
+		goto out;
+	}
+	rc = qed_iov_vf_stop_txqs(p_hwfn, vf, req->tx_qid);
+	if (!rc)
+		status = PFVF_STATUS_SUCCESS;
 
+out:
 	qed_iov_prepare_resp(p_hwfn, p_ptt, vf, CHANNEL_TLV_STOP_TXQS,
 			     length, status);
 }
diff --git a/drivers/net/ethernet/qlogic/qed/qed_vf.h b/drivers/net/ethernet/qlogic/qed/qed_vf.h
index 7da0b16..105c0ed 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_vf.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_vf.h
@@ -275,6 +275,8 @@ struct vfpf_stop_rxqs_tlv {
 	struct vfpf_first_tlv first_tlv;
 
 	u16 rx_qid;
+
+	/* this field is deprecated and should *always* be set to '1' */
 	u8 num_rxqs;
 	u8 cqe_completion;
 	u8 padding[4];
@@ -285,6 +287,8 @@ struct vfpf_stop_txqs_tlv {
 	struct vfpf_first_tlv first_tlv;
 
 	u16 tx_qid;
+
+	/* this field is deprecated and should *always* be set to '1' */
 	u8 num_txqs;
 	u8 padding[5];
 };
-- 
1.9.3
