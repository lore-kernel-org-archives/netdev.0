From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 03/11] qed*: L2 interface to use the SB structures directly
Date: Sun, 4 Jun 2017 13:31:01 +0300
Message-ID: <20170604103109.3082-4-Yuval.Mintz@cavium.com>
References: <20170604103109.3082-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0043.outbound.protection.outlook.com ([104.47.40.43]:44672
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751139AbdFDKbi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 4 Jun 2017 06:31:38 -0400
In-Reply-To: <20170604103109.3082-1-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Part of an effort of a cleaner seperation between qed and the protocol
drivers, the L2 interface is to use the SB structure for initialization
purposes opaquely.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_l2.c     | 32 +++++++++++++++-------------
 drivers/net/ethernet/qlogic/qed/qed_l2.h     | 24 +++++++++++++++------
 drivers/net/ethernet/qlogic/qed/qed_sriov.c  | 13 +++++++++--
 drivers/net/ethernet/qlogic/qed/qed_vf.c     |  8 +++----
 drivers/net/ethernet/qlogic/qede/qede_main.c |  4 ++--
 include/linux/qed/qed_eth_if.h               |  3 +--
 6 files changed, 52 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index 9d57911..262b2ba 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -182,9 +182,15 @@ _qed_eth_queue_to_cid(struct qed_hwfn *p_hwfn,
 	p_cid->opaque_fid = opaque_fid;
 	p_cid->cid = cid;
 	p_cid->vf_qid = vf_qid;
-	p_cid->rel = *p_params;
 	p_cid->p_owner = p_hwfn;
 
+	/* Fill in parameters */
+	p_cid->rel.vport_id = p_params->vport_id;
+	p_cid->rel.queue_id = p_params->queue_id;
+	p_cid->rel.stats_id = p_params->stats_id;
+	p_cid->sb_igu_id = p_params->p_sb->igu_sb_id;
+	p_cid->sb_idx = p_params->sb_idx;
+
 	/* Don't try calculating the absolute indices for VFs */
 	if (IS_VF(p_hwfn->cdev)) {
 		p_cid->abs = p_cid->rel;
@@ -215,10 +221,6 @@ _qed_eth_queue_to_cid(struct qed_hwfn *p_hwfn,
 		p_cid->abs.stats_id = p_cid->rel.stats_id;
 	}
 
-	/* SBs relevant information was already provided as absolute */
-	p_cid->abs.sb = p_cid->rel.sb;
-	p_cid->abs.sb_idx = p_cid->rel.sb_idx;
-
 	/* This is tricky - we're actually interested in whehter this is a PF
 	 * entry meant for the VF.
 	 */
@@ -235,7 +237,7 @@ _qed_eth_queue_to_cid(struct qed_hwfn *p_hwfn,
 		   p_cid->rel.queue_id,
 		   p_cid->abs.queue_id,
 		   p_cid->rel.stats_id,
-		   p_cid->abs.stats_id, p_cid->abs.sb, p_cid->abs.sb_idx);
+		   p_cid->abs.stats_id, p_cid->sb_igu_id, p_cid->sb_idx);
 
 	return p_cid;
 
@@ -767,7 +769,7 @@ int qed_eth_rxq_start_ramrod(struct qed_hwfn *p_hwfn,
 	DP_VERBOSE(p_hwfn, QED_MSG_SP,
 		   "opaque_fid=0x%x, cid=0x%x, rx_qzone=0x%x, vport_id=0x%x, sb_id=0x%x\n",
 		   p_cid->opaque_fid, p_cid->cid,
-		   p_cid->abs.queue_id, p_cid->abs.vport_id, p_cid->abs.sb);
+		   p_cid->abs.queue_id, p_cid->abs.vport_id, p_cid->sb_igu_id);
 
 	/* Get SPQ entry */
 	memset(&init_data, 0, sizeof(init_data));
@@ -783,8 +785,8 @@ int qed_eth_rxq_start_ramrod(struct qed_hwfn *p_hwfn,
 
 	p_ramrod = &p_ent->ramrod.rx_queue_start;
 
-	p_ramrod->sb_id = cpu_to_le16(p_cid->abs.sb);
-	p_ramrod->sb_index = p_cid->abs.sb_idx;
+	p_ramrod->sb_id = cpu_to_le16(p_cid->sb_igu_id);
+	p_ramrod->sb_index = p_cid->sb_idx;
 	p_ramrod->vport_id = p_cid->abs.vport_id;
 	p_ramrod->stats_counter_id = p_cid->abs.stats_id;
 	p_ramrod->rx_queue_id = cpu_to_le16(p_cid->abs.queue_id);
@@ -1001,8 +1003,8 @@ qed_eth_txq_start_ramrod(struct qed_hwfn *p_hwfn,
 	p_ramrod = &p_ent->ramrod.tx_queue_start;
 	p_ramrod->vport_id = p_cid->abs.vport_id;
 
-	p_ramrod->sb_id = cpu_to_le16(p_cid->abs.sb);
-	p_ramrod->sb_index = p_cid->abs.sb_idx;
+	p_ramrod->sb_id = cpu_to_le16(p_cid->sb_igu_id);
+	p_ramrod->sb_index = p_cid->sb_idx;
 	p_ramrod->stats_counter_id = p_cid->abs.stats_id;
 
 	p_ramrod->queue_zone_id = cpu_to_le16(p_cid->abs.queue_id);
@@ -2279,9 +2281,9 @@ static int qed_start_rxq(struct qed_dev *cdev,
 	}
 
 	DP_VERBOSE(cdev, (QED_MSG_SPQ | NETIF_MSG_IFUP),
-		   "Started RX-Q %d [rss_num %d] on V-PORT %d and SB %d\n",
+		   "Started RX-Q %d [rss_num %d] on V-PORT %d and SB igu %d\n",
 		   p_params->queue_id, rss_num, p_params->vport_id,
-		   p_params->sb);
+		   p_params->p_sb->igu_sb_id);
 
 	return 0;
 }
@@ -2329,9 +2331,9 @@ static int qed_start_txq(struct qed_dev *cdev,
 	}
 
 	DP_VERBOSE(cdev, (QED_MSG_SPQ | NETIF_MSG_IFUP),
-		   "Started TX-Q %d [rss_num %d] on V-PORT %d and SB %d\n",
+		   "Started TX-Q %d [rss_num %d] on V-PORT %d and SB igu %d\n",
 		   p_params->queue_id, rss_num, p_params->vport_id,
-		   p_params->sb);
+		   p_params->p_sb->igu_sb_id);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.h b/drivers/net/ethernet/qlogic/qed/qed_l2.h
index 8606bbf..6ad3644 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.h
@@ -279,14 +279,24 @@ void qed_reset_vport_stats(struct qed_dev *cdev);
 
 #define MAX_QUEUES_PER_QZONE    (sizeof(unsigned long) * 8)
 
+/* Almost identical to the qed_queue_start_common_params,
+ * but here we maintain the SB index in IGU CAM.
+ */
+struct qed_queue_cid_params {
+	u8 vport_id;
+	u16 queue_id;
+	u8 stats_id;
+};
+
 struct qed_queue_cid {
-	/* 'Relative' is a relative term ;-). Usually the indices [not counting
-	 * SBs] would be PF-relative, but there are some cases where that isn't
-	 * the case - specifically for a PF configuring its VF indices it's
-	 * possible some fields [E.g., stats-id] in 'rel' would already be abs.
-	 */
-	struct qed_queue_start_common_params rel;
-	struct qed_queue_start_common_params abs;
+	/* For stats-id, the `rel' is actually absolute as well */
+	struct qed_queue_cid_params rel;
+	struct qed_queue_cid_params abs;
+
+	/* These have no 'relative' meaning */
+	u16 sb_igu_id;
+	u8 sb_idx;
+
 	u32 cid;
 	u16 opaque_fid;
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index 5ae8827..498c83e 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -1951,6 +1951,7 @@ static void qed_iov_vf_mbx_start_rxq(struct qed_hwfn *p_hwfn,
 	u8 status = PFVF_STATUS_NO_RESOURCE;
 	struct qed_vf_q_info *p_queue;
 	struct vfpf_start_rxq_tlv *req;
+	struct qed_sb_info sb_dummy;
 	bool b_legacy_vf = false;
 	int rc;
 
@@ -1968,7 +1969,10 @@ static void qed_iov_vf_mbx_start_rxq(struct qed_hwfn *p_hwfn,
 	params.queue_id = p_queue->fw_rx_qid;
 	params.vport_id = vf->vport_id;
 	params.stats_id = vf->abs_vf_id + 0x10;
-	params.sb = req->hw_sb;
+	/* Since IGU index is passed via sb_info, construct a dummy one */
+	memset(&sb_dummy, 0, sizeof(sb_dummy));
+	sb_dummy.igu_sb_id = req->hw_sb;
+	params.p_sb = &sb_dummy;
 	params.sb_idx = req->sb_index;
 
 	p_queue->p_rx_cid = _qed_eth_queue_to_cid(p_hwfn,
@@ -2273,6 +2277,7 @@ static void qed_iov_vf_mbx_start_txq(struct qed_hwfn *p_hwfn,
 	u8 status = PFVF_STATUS_NO_RESOURCE;
 	struct vfpf_start_txq_tlv *req;
 	struct qed_vf_q_info *p_queue;
+	struct qed_sb_info sb_dummy;
 	int rc;
 	u16 pq;
 
@@ -2290,7 +2295,11 @@ static void qed_iov_vf_mbx_start_txq(struct qed_hwfn *p_hwfn,
 	params.queue_id = p_queue->fw_tx_qid;
 	params.vport_id = vf->vport_id;
 	params.stats_id = vf->abs_vf_id + 0x10;
-	params.sb = req->hw_sb;
+
+	/* Since IGU index is passed via sb_info, construct a dummy one */
+	memset(&sb_dummy, 0, sizeof(sb_dummy));
+	sb_dummy.igu_sb_id = req->hw_sb;
+	params.p_sb = &sb_dummy;
 	params.sb_idx = req->sb_index;
 
 	p_queue->p_tx_cid = _qed_eth_queue_to_cid(p_hwfn,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_vf.c b/drivers/net/ethernet/qlogic/qed/qed_vf.c
index 29d7407..877d41e 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_vf.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_vf.c
@@ -588,8 +588,8 @@ qed_vf_pf_rxq_start(struct qed_hwfn *p_hwfn,
 	req->cqe_pbl_addr = cqe_pbl_addr;
 	req->cqe_pbl_size = cqe_pbl_size;
 	req->rxq_addr = bd_chain_phys_addr;
-	req->hw_sb = p_cid->rel.sb;
-	req->sb_index = p_cid->rel.sb_idx;
+	req->hw_sb = p_cid->sb_igu_id;
+	req->sb_index = p_cid->sb_idx;
 	req->bd_max_bytes = bd_max_bytes;
 	req->stat_id = -1;
 
@@ -697,8 +697,8 @@ qed_vf_pf_txq_start(struct qed_hwfn *p_hwfn,
 	/* Tx */
 	req->pbl_addr = pbl_addr;
 	req->pbl_size = pbl_size;
-	req->hw_sb = p_cid->rel.sb;
-	req->sb_index = p_cid->rel.sb_idx;
+	req->hw_sb = p_cid->sb_igu_id;
+	req->sb_index = p_cid->sb_idx;
 
 	/* add list termination tlv */
 	qed_add_tlv(p_hwfn, &p_iov->offset,
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 00c7062..ad1e249 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -1770,7 +1770,7 @@ static int qede_start_txq(struct qede_dev *edev,
 	else
 		params.queue_id = txq->index;
 
-	params.sb = fp->sb_info->igu_sb_id;
+	params.p_sb = fp->sb_info;
 	params.sb_idx = sb_idx;
 
 	rc = edev->ops->q_tx_start(edev->cdev, rss_id, &params, phys_table,
@@ -1849,7 +1849,7 @@ static int qede_start_queues(struct qede_dev *edev, bool clear_stats)
 			memset(&q_params, 0, sizeof(q_params));
 			q_params.queue_id = rxq->rxq_id;
 			q_params.vport_id = 0;
-			q_params.sb = fp->sb_info->igu_sb_id;
+			q_params.p_sb = fp->sb_info;
 			q_params.sb_idx = RX_PI;
 
 			p_phys_table =
diff --git a/include/linux/qed/qed_eth_if.h b/include/linux/qed/qed_eth_if.h
index d66d16a..fd72056 100644
--- a/include/linux/qed/qed_eth_if.h
+++ b/include/linux/qed/qed_eth_if.h
@@ -47,8 +47,7 @@ struct qed_queue_start_common_params {
 	/* Relative, but relevant only for PFs */
 	u8 stats_id;
 
-	/* These are always absolute */
-	u16 sb;
+	struct qed_sb_info *p_sb;
 	u8 sb_idx;
 };
 
-- 
2.9.4
