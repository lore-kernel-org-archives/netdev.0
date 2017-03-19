From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 5/9] qed: Uniform IOV queue validation
Date: Sun, 19 Mar 2017 13:08:16 +0200
Message-ID: <1489921700-6850-6-git-send-email-Yuval.Mintz@cavium.com>
References: <1489921700-6850-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:45807 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751976AbdCSLIq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Mar 2017 07:08:46 -0400
In-Reply-To: <1489921700-6850-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PF needs to validate the status of VF queues before asking firmware
to configure anything for them, but that validation is done in various
different forms - sometimes inadequate.

Add auxillary functions that can be used for testing of the queue
state and convert the various flows to use those instead of current
existing flows; Also, add missing validations where needed.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_sriov.c | 123 +++++++++++++++++++++-------
 1 file changed, 92 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index 098330e..7547a23 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -178,26 +178,59 @@ static struct qed_vf_info *qed_iov_get_vf_info(struct qed_hwfn *p_hwfn,
 	return vf;
 }
 
+enum qed_iov_validate_q_mode {
+	QED_IOV_VALIDATE_Q_NA,
+	QED_IOV_VALIDATE_Q_ENABLE,
+	QED_IOV_VALIDATE_Q_DISABLE,
+};
+
+static bool qed_iov_validate_queue_mode(struct qed_hwfn *p_hwfn,
+					struct qed_vf_info *p_vf,
+					u16 qid,
+					enum qed_iov_validate_q_mode mode,
+					bool b_is_tx)
+{
+	if (mode == QED_IOV_VALIDATE_Q_NA)
+		return true;
+
+	if ((b_is_tx && p_vf->vf_queues[qid].p_tx_cid) ||
+	    (!b_is_tx && p_vf->vf_queues[qid].p_rx_cid))
+		return mode == QED_IOV_VALIDATE_Q_ENABLE;
+
+	/* In case we haven't found any valid cid, then its disabled */
+	return mode == QED_IOV_VALIDATE_Q_DISABLE;
+}
+
 static bool qed_iov_validate_rxq(struct qed_hwfn *p_hwfn,
-				 struct qed_vf_info *p_vf, u16 rx_qid)
+				 struct qed_vf_info *p_vf,
+				 u16 rx_qid,
+				 enum qed_iov_validate_q_mode mode)
 {
-	if (rx_qid >= p_vf->num_rxqs)
+	if (rx_qid >= p_vf->num_rxqs) {
 		DP_VERBOSE(p_hwfn,
 			   QED_MSG_IOV,
 			   "VF[0x%02x] - can't touch Rx queue[%04x]; Only 0x%04x are allocated\n",
 			   p_vf->abs_vf_id, rx_qid, p_vf->num_rxqs);
-	return rx_qid < p_vf->num_rxqs;
+		return false;
+	}
+
+	return qed_iov_validate_queue_mode(p_hwfn, p_vf, rx_qid, mode, false);
 }
 
 static bool qed_iov_validate_txq(struct qed_hwfn *p_hwfn,
-				 struct qed_vf_info *p_vf, u16 tx_qid)
+				 struct qed_vf_info *p_vf,
+				 u16 tx_qid,
+				 enum qed_iov_validate_q_mode mode)
 {
-	if (tx_qid >= p_vf->num_txqs)
+	if (tx_qid >= p_vf->num_txqs) {
 		DP_VERBOSE(p_hwfn,
 			   QED_MSG_IOV,
 			   "VF[0x%02x] - can't touch Tx queue[%04x]; Only 0x%04x are allocated\n",
 			   p_vf->abs_vf_id, tx_qid, p_vf->num_txqs);
-	return tx_qid < p_vf->num_txqs;
+		return false;
+	}
+
+	return qed_iov_validate_queue_mode(p_hwfn, p_vf, tx_qid, mode, true);
 }
 
 static bool qed_iov_validate_sb(struct qed_hwfn *p_hwfn,
@@ -217,6 +250,34 @@ static bool qed_iov_validate_sb(struct qed_hwfn *p_hwfn,
 	return false;
 }
 
+static bool qed_iov_validate_active_rxq(struct qed_hwfn *p_hwfn,
+					struct qed_vf_info *p_vf)
+{
+	u8 i;
+
+	for (i = 0; i < p_vf->num_rxqs; i++)
+		if (qed_iov_validate_queue_mode(p_hwfn, p_vf, i,
+						QED_IOV_VALIDATE_Q_ENABLE,
+						false))
+			return true;
+
+	return false;
+}
+
+static bool qed_iov_validate_active_txq(struct qed_hwfn *p_hwfn,
+					struct qed_vf_info *p_vf)
+{
+	u8 i;
+
+	for (i = 0; i < p_vf->num_txqs; i++)
+		if (qed_iov_validate_queue_mode(p_hwfn, p_vf, i,
+						QED_IOV_VALIDATE_Q_ENABLE,
+						true))
+			return true;
+
+	return false;
+}
+
 static int qed_iov_post_vf_bulletin(struct qed_hwfn *p_hwfn,
 				    int vfid, struct qed_ptt *p_ptt)
 {
@@ -1826,6 +1887,16 @@ static void qed_iov_vf_mbx_stop_vport(struct qed_hwfn *p_hwfn,
 	vf->vport_instance--;
 	vf->spoof_chk = false;
 
+	if ((qed_iov_validate_active_rxq(p_hwfn, vf)) ||
+	    (qed_iov_validate_active_txq(p_hwfn, vf))) {
+		vf->b_malicious = true;
+		DP_NOTICE(p_hwfn,
+			  "VF [%02x] - considered malicious; Unable to stop RX/TX queuess\n",
+			  vf->abs_vf_id);
+		status = PFVF_STATUS_MALICIOUS;
+		goto out;
+	}
+
 	rc = qed_sp_vport_stop(p_hwfn, vf->opaque_fid, vf->vport_id);
 	if (rc) {
 		DP_ERR(p_hwfn, "qed_iov_vf_mbx_stop_vport returned error %d\n",
@@ -1837,6 +1908,7 @@ static void qed_iov_vf_mbx_stop_vport(struct qed_hwfn *p_hwfn,
 	vf->configured_features = 0;
 	memset(&vf->shadow_config, 0, sizeof(vf->shadow_config));
 
+out:
 	qed_iov_prepare_resp(p_hwfn, p_ptt, vf, CHANNEL_TLV_VPORT_TEARDOWN,
 			     sizeof(struct pfvf_def_resp_tlv), status);
 }
@@ -1893,7 +1965,8 @@ static void qed_iov_vf_mbx_start_rxq(struct qed_hwfn *p_hwfn,
 
 	req = &mbx->req_virt->start_rxq;
 
-	if (!qed_iov_validate_rxq(p_hwfn, vf, req->rx_qid) ||
+	if (!qed_iov_validate_rxq(p_hwfn, vf, req->rx_qid,
+				  QED_IOV_VALIDATE_Q_DISABLE) ||
 	    !qed_iov_validate_sb(p_hwfn, vf, req->hw_sb))
 		goto out;
 
@@ -2007,7 +2080,8 @@ static void qed_iov_vf_mbx_start_txq(struct qed_hwfn *p_hwfn,
 	memset(&params, 0, sizeof(params));
 	req = &mbx->req_virt->start_txq;
 
-	if (!qed_iov_validate_txq(p_hwfn, vf, req->tx_qid) ||
+	if (!qed_iov_validate_txq(p_hwfn, vf, req->tx_qid,
+				  QED_IOV_VALIDATE_Q_DISABLE) ||
 	    !qed_iov_validate_sb(p_hwfn, vf, req->hw_sb))
 		goto out;
 
@@ -2164,22 +2238,17 @@ static void qed_iov_vf_mbx_update_rxqs(struct qed_hwfn *p_hwfn,
 	complete_event_flg = !!(req->flags & VFPF_RXQ_UPD_COMPLETE_EVENT_FLAG);
 
 	/* Validate inputs */
-	if (req->num_rxqs + req->rx_qid > QED_MAX_VF_CHAINS_PER_PF ||
-	    !qed_iov_validate_rxq(p_hwfn, vf, req->rx_qid)) {
-		DP_INFO(p_hwfn, "VF[%d]: Incorrect Rxqs [%04x, %02x]\n",
-			vf->relative_vf_id, req->rx_qid, req->num_rxqs);
-		goto out;
-	}
-
-	for (i = 0; i < req->num_rxqs; i++) {
-		qid = req->rx_qid + i;
-		if (!vf->vf_queues[qid].p_rx_cid) {
-			DP_INFO(p_hwfn,
-				"VF[%d] rx_qid = %d isn`t active!\n",
-				vf->relative_vf_id, qid);
+	for (i = req->rx_qid; i < req->rx_qid + req->num_rxqs; i++)
+		if (!qed_iov_validate_rxq(p_hwfn, vf, i,
+					  QED_IOV_VALIDATE_Q_ENABLE)) {
+			DP_INFO(p_hwfn, "VF[%d]: Incorrect Rxqs [%04x, %02x]\n",
+				vf->relative_vf_id, req->rx_qid, req->num_rxqs);
 			goto out;
 		}
 
+	/* Prepare the handlers */
+	for (i = 0; i < req->num_rxqs; i++) {
+		qid = req->rx_qid + i;
 		handlers[i] = vf->vf_queues[qid].p_rx_cid;
 	}
 
@@ -2395,7 +2464,8 @@ void *qed_iov_search_list_tlvs(struct qed_hwfn *p_hwfn,
 
 	for (i = 0; i < table_size; i++) {
 		q_idx = p_rss_tlv->rss_ind_table[i];
-		if (!qed_iov_validate_rxq(p_hwfn, vf, q_idx)) {
+		if (!qed_iov_validate_rxq(p_hwfn, vf, q_idx,
+					  QED_IOV_VALIDATE_Q_ENABLE)) {
 			DP_VERBOSE(p_hwfn,
 				   QED_MSG_IOV,
 				   "VF[%d]: Omitting RSS due to wrong queue %04x\n",
@@ -2404,15 +2474,6 @@ void *qed_iov_search_list_tlvs(struct qed_hwfn *p_hwfn,
 			goto out;
 		}
 
-		if (!vf->vf_queues[q_idx].p_rx_cid) {
-			DP_VERBOSE(p_hwfn,
-				   QED_MSG_IOV,
-				   "VF[%d]: Omitting RSS due to inactive queue %08x\n",
-				   vf->relative_vf_id, q_idx);
-			b_reject = true;
-			goto out;
-		}
-
 		p_rss->rss_ind_table[i] = vf->vf_queues[q_idx].p_rx_cid;
 	}
 
-- 
1.9.3
