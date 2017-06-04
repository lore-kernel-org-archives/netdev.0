From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 05/11] qed: Assign a unique per-queue index to queue-cid
Date: Sun, 4 Jun 2017 13:31:03 +0300
Message-ID: <20170604103109.3082-6-Yuval.Mintz@cavium.com>
References: <20170604103109.3082-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0088.outbound.protection.outlook.com ([104.47.34.88]:9018
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751045AbdFDKbt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 4 Jun 2017 06:31:49 -0400
In-Reply-To: <20170604103109.3082-1-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a queue-cid is allocated, assign an index inside that's
CID's queue-zone.

For PFs and VFS, this number is going to be unique and derive
from a per-queue-zone bitmap, while for PF's VFs queues the
number is currently going to constant; Later, we'd add the
capability of a VF to communicate such an index to its PF.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_l2.c    | 62 ++++++++++++++++++++++++++++-
 drivers/net/ethernet/qlogic/qed/qed_l2.h    |  7 ++++
 drivers/net/ethernet/qlogic/qed/qed_sriov.c | 20 ++++++++--
 drivers/net/ethernet/qlogic/qed/qed_sriov.h |  3 ++
 4 files changed, 88 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index 150a8e9..0a8d3a8 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -151,6 +151,50 @@ void qed_l2_free(struct qed_hwfn *p_hwfn)
 	p_hwfn->p_l2_info = NULL;
 }
 
+static bool qed_eth_queue_qid_usage_add(struct qed_hwfn *p_hwfn,
+					struct qed_queue_cid *p_cid)
+{
+	struct qed_l2_info *p_l2_info = p_hwfn->p_l2_info;
+	u16 queue_id = p_cid->rel.queue_id;
+	bool b_rc = true;
+	u8 first;
+
+	mutex_lock(&p_l2_info->lock);
+
+	if (queue_id > p_l2_info->queues) {
+		DP_NOTICE(p_hwfn,
+			  "Requested to increase usage for qzone %04x out of %08x\n",
+			  queue_id, p_l2_info->queues);
+		b_rc = false;
+		goto out;
+	}
+
+	first = (u8)find_first_zero_bit(p_l2_info->pp_qid_usage[queue_id],
+					MAX_QUEUES_PER_QZONE);
+	if (first >= MAX_QUEUES_PER_QZONE) {
+		b_rc = false;
+		goto out;
+	}
+
+	__set_bit(first, p_l2_info->pp_qid_usage[queue_id]);
+	p_cid->qid_usage_idx = first;
+
+out:
+	mutex_unlock(&p_l2_info->lock);
+	return b_rc;
+}
+
+static void qed_eth_queue_qid_usage_del(struct qed_hwfn *p_hwfn,
+					struct qed_queue_cid *p_cid)
+{
+	mutex_lock(&p_hwfn->p_l2_info->lock);
+
+	clear_bit(p_cid->qid_usage_idx,
+		  p_hwfn->p_l2_info->pp_qid_usage[p_cid->rel.queue_id]);
+
+	mutex_unlock(&p_hwfn->p_l2_info->lock);
+}
+
 void qed_eth_queue_cid_release(struct qed_hwfn *p_hwfn,
 			       struct qed_queue_cid *p_cid)
 {
@@ -158,6 +202,11 @@ void qed_eth_queue_cid_release(struct qed_hwfn *p_hwfn,
 	if ((p_cid->vfid == QED_QUEUE_CID_SELF) &&
 	    IS_PF(p_hwfn->cdev))
 		qed_cxt_release_cid(p_hwfn, p_cid->cid);
+
+	/* For PF's VFs we maintain the index inside queue-zone in IOV */
+	if (p_cid->vfid == QED_QUEUE_CID_SELF)
+		qed_eth_queue_qid_usage_del(p_hwfn, p_cid);
+
 	vfree(p_cid);
 }
 
@@ -230,14 +279,25 @@ _qed_eth_queue_to_cid(struct qed_hwfn *p_hwfn,
 	}
 
 out:
+	/* VF-images have provided the qid_usage_idx on their own.
+	 * Otherwise, we need to allocate a unique one.
+	 */
+	if (!p_vf_params) {
+		if (!qed_eth_queue_qid_usage_add(p_hwfn, p_cid))
+			goto fail;
+	} else {
+		p_cid->qid_usage_idx = p_vf_params->qid_usage_idx;
+	}
+
 	DP_VERBOSE(p_hwfn,
 		   QED_MSG_SP,
-		   "opaque_fid: %04x CID %08x vport %02x [%02x] qzone %04x [%04x] stats %02x [%02x] SB %04x PI %02x\n",
+		   "opaque_fid: %04x CID %08x vport %02x [%02x] qzone %04x.%02x [%04x] stats %02x [%02x] SB %04x PI %02x\n",
 		   p_cid->opaque_fid,
 		   p_cid->cid,
 		   p_cid->rel.vport_id,
 		   p_cid->abs.vport_id,
 		   p_cid->rel.queue_id,
+		   p_cid->qid_usage_idx,
 		   p_cid->abs.queue_id,
 		   p_cid->rel.stats_id,
 		   p_cid->abs.stats_id, p_cid->sb_igu_id, p_cid->sb_idx);
diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.h b/drivers/net/ethernet/qlogic/qed/qed_l2.h
index 43aeaa8..59c2ba3 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.h
@@ -306,6 +306,7 @@ struct qed_queue_cid_vf_params {
 	 */
 	bool vf_legacy;
 
+	u8 qid_usage_idx;
 };
 
 struct qed_queue_cid {
@@ -328,6 +329,12 @@ struct qed_queue_cid {
 	u8 vfid;
 	u8 vf_qid;
 
+	/* We need an additional index to differentiate between queues opened
+	 * for same queue-zone, as VFs would have to communicate the info
+	 * to the PF [otherwise PF has no way to differentiate].
+	 */
+	u8 qid_usage_idx;
+
 	/* Legacy VFs might have Rx producer located elsewhere */
 	bool b_legacy_vf;
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index 7ea00bf..c205e47 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -1942,6 +1942,15 @@ static void qed_iov_vf_mbx_start_rxq_resp(struct qed_hwfn *p_hwfn,
 	qed_iov_send_response(p_hwfn, p_ptt, vf, length, status);
 }
 
+static u8 qed_iov_vf_mbx_qid(struct qed_hwfn *p_hwfn,
+			     struct qed_vf_info *p_vf, bool b_is_tx)
+{
+	if (b_is_tx)
+		return QED_IOV_LEGACY_QID_TX;
+	else
+		return QED_IOV_LEGACY_QID_RX;
+}
+
 static void qed_iov_vf_mbx_start_rxq(struct qed_hwfn *p_hwfn,
 				     struct qed_ptt *p_ptt,
 				     struct qed_vf_info *vf)
@@ -1954,6 +1963,7 @@ static void qed_iov_vf_mbx_start_rxq(struct qed_hwfn *p_hwfn,
 	struct vfpf_start_rxq_tlv *req;
 	struct qed_sb_info sb_dummy;
 	bool b_legacy_vf = false;
+	u8 qid_usage_idx;
 	int rc;
 
 	req = &mbx->req_virt->start_rxq;
@@ -1963,13 +1973,13 @@ static void qed_iov_vf_mbx_start_rxq(struct qed_hwfn *p_hwfn,
 	    !qed_iov_validate_sb(p_hwfn, vf, req->hw_sb))
 		goto out;
 
-	/* Acquire a new queue-cid */
+	qid_usage_idx = qed_iov_vf_mbx_qid(p_hwfn, vf, false);
 	p_queue = &vf->vf_queues[req->rx_qid];
 
 	if (vf->acquire.vfdev_info.eth_fp_hsi_minor ==
 	    ETH_HSI_VER_NO_PKT_LEN_TUNN)
-		b_legacy_vf = true;
 
+	/* Acquire a new queue-cid */
 	memset(&params, 0, sizeof(params));
 	params.queue_id = p_queue->fw_rx_qid;
 	params.vport_id = vf->vport_id;
@@ -1984,6 +1994,7 @@ static void qed_iov_vf_mbx_start_rxq(struct qed_hwfn *p_hwfn,
 	vf_params.vfid = vf->relative_vf_id;
 	vf_params.vf_qid = (u8)req->rx_qid;
 	vf_params.vf_legacy = b_legacy_vf;
+	vf_params.qid_usage_idx = qid_usage_idx;
 	p_queue->p_rx_cid = qed_eth_queue_to_cid(p_hwfn, vf->opaque_fid,
 						 &params, &vf_params);
 	if (!p_queue->p_rx_cid)
@@ -2282,6 +2293,7 @@ static void qed_iov_vf_mbx_start_txq(struct qed_hwfn *p_hwfn,
 	struct qed_vf_q_info *p_queue;
 	struct qed_sb_info sb_dummy;
 	bool b_vf_legacy = false;
+	u8 qid_usage_idx;
 	int rc;
 	u16 pq;
 
@@ -2293,13 +2305,14 @@ static void qed_iov_vf_mbx_start_txq(struct qed_hwfn *p_hwfn,
 	    !qed_iov_validate_sb(p_hwfn, vf, req->hw_sb))
 		goto out;
 
-	/* Acquire a new queue-cid */
+	qid_usage_idx = qed_iov_vf_mbx_qid(p_hwfn, vf, true);
 	p_queue = &vf->vf_queues[req->tx_qid];
 
 	if (vf->acquire.vfdev_info.eth_fp_hsi_minor ==
 	    ETH_HSI_VER_NO_PKT_LEN_TUNN)
 		b_vf_legacy = true;
 
+	/* Acquire a new queue-cid */
 	params.queue_id = p_queue->fw_tx_qid;
 	params.vport_id = vf->vport_id;
 	params.stats_id = vf->abs_vf_id + 0x10;
@@ -2314,6 +2327,7 @@ static void qed_iov_vf_mbx_start_txq(struct qed_hwfn *p_hwfn,
 	vf_params.vfid = vf->relative_vf_id;
 	vf_params.vf_qid = (u8)req->tx_qid;
 	vf_params.vf_legacy = b_vf_legacy;
+	vf_params.qid_usage_idx = qid_usage_idx;
 
 	p_queue->p_tx_cid = qed_eth_queue_to_cid(p_hwfn,
 						 vf->opaque_fid,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.h b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
index 801cc00..09a9513 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
@@ -149,6 +149,9 @@ struct qed_iov_vf_mbx {
 	struct vfpf_first_tlv first_tlv;
 };
 
+#define QED_IOV_LEGACY_QID_RX (0)
+#define QED_IOV_LEGACY_QID_TX (1)
+
 struct qed_vf_q_info {
 	u16 fw_rx_qid;
 	struct qed_queue_cid *p_rx_cid;
-- 
2.9.4
