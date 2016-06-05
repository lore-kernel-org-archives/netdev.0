From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 3/6] qed: Make PF more robust against malicious VF
Date: Sun, 5 Jun 2016 13:11:13 +0300
Message-ID: <1465121476-32494-4-git-send-email-Yuval.Mintz@qlogic.com>
References: <1465121476-32494-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:61099 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750993AbcFEKLh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2016 06:11:37 -0400
In-Reply-To: <1465121476-32494-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are several requests the VF can make toward the PF which the driver
would pass to firmware without checking the validity first - specifically,
opening queues and updating vports. Such configurations might cause the
firmware to assert.

This adds validation of the legality of said configurations on the PF side
before passing it onward via ramrod to firmware.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_sriov.c | 72 +++++++++++++++++++++++++++--
 1 file changed, 68 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index dbb4553..a1e40bb 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -146,6 +146,45 @@ static struct qed_vf_info *qed_iov_get_vf_info(struct qed_hwfn *p_hwfn,
 	return vf;
 }
 
+static bool qed_iov_validate_rxq(struct qed_hwfn *p_hwfn,
+				 struct qed_vf_info *p_vf, u16 rx_qid)
+{
+	if (rx_qid >= p_vf->num_rxqs)
+		DP_VERBOSE(p_hwfn,
+			   QED_MSG_IOV,
+			   "VF[0x%02x] - can't touch Rx queue[%04x]; Only 0x%04x are allocated\n",
+			   p_vf->abs_vf_id, rx_qid, p_vf->num_rxqs);
+	return rx_qid < p_vf->num_rxqs;
+}
+
+static bool qed_iov_validate_txq(struct qed_hwfn *p_hwfn,
+				 struct qed_vf_info *p_vf, u16 tx_qid)
+{
+	if (tx_qid >= p_vf->num_txqs)
+		DP_VERBOSE(p_hwfn,
+			   QED_MSG_IOV,
+			   "VF[0x%02x] - can't touch Tx queue[%04x]; Only 0x%04x are allocated\n",
+			   p_vf->abs_vf_id, tx_qid, p_vf->num_txqs);
+	return tx_qid < p_vf->num_txqs;
+}
+
+static bool qed_iov_validate_sb(struct qed_hwfn *p_hwfn,
+				struct qed_vf_info *p_vf, u16 sb_idx)
+{
+	int i;
+
+	for (i = 0; i < p_vf->num_sbs; i++)
+		if (p_vf->igu_sbs[i] == sb_idx)
+			return true;
+
+	DP_VERBOSE(p_hwfn,
+		   QED_MSG_IOV,
+		   "VF[0%02x] - tried using sb_idx %04x which doesn't exist as one of its 0x%02x SBs\n",
+		   p_vf->abs_vf_id, sb_idx, p_vf->num_sbs);
+
+	return false;
+}
+
 int qed_iov_post_vf_bulletin(struct qed_hwfn *p_hwfn,
 			     int vfid, struct qed_ptt *p_ptt)
 {
@@ -1687,12 +1726,17 @@ static void qed_iov_vf_mbx_start_rxq(struct qed_hwfn *p_hwfn,
 {
 	struct qed_queue_start_common_params params;
 	struct qed_iov_vf_mbx *mbx = &vf->vf_mbx;
-	u8 status = PFVF_STATUS_SUCCESS;
+	u8 status = PFVF_STATUS_NO_RESOURCE;
 	struct vfpf_start_rxq_tlv *req;
 	int rc;
 
 	memset(&params, 0, sizeof(params));
 	req = &mbx->req_virt->start_rxq;
+
+	if (!qed_iov_validate_rxq(p_hwfn, vf, req->rx_qid) ||
+	    !qed_iov_validate_sb(p_hwfn, vf, req->hw_sb))
+		goto out;
+
 	params.queue_id =  vf->vf_queues[req->rx_qid].fw_rx_qid;
 	params.vf_qid = req->rx_qid;
 	params.vport_id = vf->vport_id;
@@ -1710,10 +1754,12 @@ static void qed_iov_vf_mbx_start_rxq(struct qed_hwfn *p_hwfn,
 	if (rc) {
 		status = PFVF_STATUS_FAILURE;
 	} else {
+		status = PFVF_STATUS_SUCCESS;
 		vf->vf_queues[req->rx_qid].rxq_active = true;
 		vf->num_active_rxqs++;
 	}
 
+out:
 	qed_iov_vf_mbx_start_rxq_resp(p_hwfn, p_ptt, vf, status);
 }
 
@@ -1724,8 +1770,8 @@ static void qed_iov_vf_mbx_start_txq(struct qed_hwfn *p_hwfn,
 	u16 length = sizeof(struct pfvf_def_resp_tlv);
 	struct qed_queue_start_common_params params;
 	struct qed_iov_vf_mbx *mbx = &vf->vf_mbx;
+	u8 status = PFVF_STATUS_NO_RESOURCE;
 	union qed_qm_pq_params pq_params;
-	u8 status = PFVF_STATUS_SUCCESS;
 	struct vfpf_start_txq_tlv *req;
 	int rc;
 
@@ -1736,6 +1782,11 @@ static void qed_iov_vf_mbx_start_txq(struct qed_hwfn *p_hwfn,
 
 	memset(&params, 0, sizeof(params));
 	req = &mbx->req_virt->start_txq;
+
+	if (!qed_iov_validate_txq(p_hwfn, vf, req->tx_qid) ||
+	    !qed_iov_validate_sb(p_hwfn, vf, req->hw_sb))
+		goto out;
+
 	params.queue_id =  vf->vf_queues[req->tx_qid].fw_tx_qid;
 	params.vport_id = vf->vport_id;
 	params.sb = req->hw_sb;
@@ -1749,11 +1800,14 @@ static void qed_iov_vf_mbx_start_txq(struct qed_hwfn *p_hwfn,
 					 req->pbl_addr,
 					 req->pbl_size, &pq_params);
 
-	if (rc)
+	if (rc) {
 		status = PFVF_STATUS_FAILURE;
-	else
+	} else {
+		status = PFVF_STATUS_SUCCESS;
 		vf->vf_queues[req->tx_qid].txq_active = true;
+	}
 
+out:
 	qed_iov_prepare_resp(p_hwfn, p_ptt, vf, CHANNEL_TLV_START_TXQ,
 			     length, status);
 }
@@ -2180,6 +2234,16 @@ static void qed_iov_vf_mbx_vport_update(struct qed_hwfn *p_hwfn,
 	u16 length;
 	int rc;
 
+	/* Valiate PF can send such a request */
+	if (!vf->vport_instance) {
+		DP_VERBOSE(p_hwfn,
+			   QED_MSG_IOV,
+			   "No VPORT instance available for VF[%d], failing vport update\n",
+			   vf->abs_vf_id);
+		status = PFVF_STATUS_FAILURE;
+		goto out;
+	}
+
 	memset(&params, 0, sizeof(params));
 	params.opaque_fid = vf->opaque_fid;
 	params.vport_id = vf->vport_id;
-- 
1.9.3
