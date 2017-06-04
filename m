From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 02/11] qed: Create L2 queue database
Date: Sun, 4 Jun 2017 13:31:00 +0300
Message-ID: <20170604103109.3082-3-Yuval.Mintz@cavium.com>
References: <20170604103109.3082-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0062.outbound.protection.outlook.com ([104.47.33.62]:52192
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751139AbdFDKbd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 4 Jun 2017 06:31:33 -0400
In-Reply-To: <20170604103109.3082-1-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First step in allowing a single PF/VF to open multiple queues on
the same queue zone is to add per-hwfn database of queue-cids
as a two-dimensional array where entry would be according to
[queue zone][internal index].

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed.h     |  3 ++
 drivers/net/ethernet/qlogic/qed/qed_dev.c | 24 +++++++--
 drivers/net/ethernet/qlogic/qed/qed_l2.c  | 86 +++++++++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_l2.h  |  6 +++
 drivers/net/ethernet/qlogic/qed/qed_vf.c  |  5 ++
 drivers/net/ethernet/qlogic/qed/qed_vf.h  | 12 +++++
 6 files changed, 133 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index ffc0807..cfb5758 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -533,6 +533,9 @@ struct qed_hwfn {
 	u8 dcbx_no_edpm;
 	u8 db_bar_no_edpm;
 
+	/* L2-related */
+	struct qed_l2_info *p_l2_info;
+
 	struct qed_ptt *p_arfs_ptt;
 
 	struct qed_simd_fp_handler	simd_proto_handler[64];
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 2d88d48..e983113 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -154,8 +154,11 @@ void qed_resc_free(struct qed_dev *cdev)
 {
 	int i;
 
-	if (IS_VF(cdev))
+	if (IS_VF(cdev)) {
+		for_each_hwfn(cdev, i)
+			qed_l2_free(&cdev->hwfns[i]);
 		return;
+	}
 
 	kfree(cdev->fw_data);
 	cdev->fw_data = NULL;
@@ -183,6 +186,7 @@ void qed_resc_free(struct qed_dev *cdev)
 			qed_ooo_free(p_hwfn);
 		}
 		qed_iov_free(p_hwfn);
+		qed_l2_free(p_hwfn);
 		qed_dmae_info_free(p_hwfn);
 		qed_dcbx_info_free(p_hwfn);
 	}
@@ -848,8 +852,14 @@ int qed_resc_alloc(struct qed_dev *cdev)
 	u32 line_count;
 	int i, rc = 0;
 
-	if (IS_VF(cdev))
+	if (IS_VF(cdev)) {
+		for_each_hwfn(cdev, i) {
+			rc = qed_l2_alloc(&cdev->hwfns[i]);
+			if (rc)
+				return rc;
+		}
 		return rc;
+	}
 
 	cdev->fw_data = kzalloc(sizeof(*cdev->fw_data), GFP_KERNEL);
 	if (!cdev->fw_data)
@@ -960,6 +970,10 @@ int qed_resc_alloc(struct qed_dev *cdev)
 		if (rc)
 			goto alloc_err;
 
+		rc = qed_l2_alloc(p_hwfn);
+		if (rc)
+			goto alloc_err;
+
 #ifdef CONFIG_QED_LL2
 		if (p_hwfn->using_ll2) {
 			rc = qed_ll2_alloc(p_hwfn);
@@ -1011,8 +1025,11 @@ void qed_resc_setup(struct qed_dev *cdev)
 {
 	int i;
 
-	if (IS_VF(cdev))
+	if (IS_VF(cdev)) {
+		for_each_hwfn(cdev, i)
+			qed_l2_setup(&cdev->hwfns[i]);
 		return;
+	}
 
 	for_each_hwfn(cdev, i) {
 		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
@@ -1030,6 +1047,7 @@ void qed_resc_setup(struct qed_dev *cdev)
 
 		qed_int_setup(p_hwfn, p_hwfn->p_main_ptt);
 
+		qed_l2_setup(p_hwfn);
 		qed_iov_setup(p_hwfn);
 #ifdef CONFIG_QED_LL2
 		if (p_hwfn->using_ll2)
diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index 93dd781..9d57911 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -65,6 +65,92 @@
 #define QED_MAX_SGES_NUM 16
 #define CRC32_POLY 0x1edc6f41
 
+struct qed_l2_info {
+	u32 queues;
+	unsigned long **pp_qid_usage;
+
+	/* The lock is meant to synchronize access to the qid usage */
+	struct mutex lock;
+};
+
+int qed_l2_alloc(struct qed_hwfn *p_hwfn)
+{
+	struct qed_l2_info *p_l2_info;
+	unsigned long **pp_qids;
+	u32 i;
+
+	if (p_hwfn->hw_info.personality != QED_PCI_ETH &&
+	    p_hwfn->hw_info.personality != QED_PCI_ETH_ROCE)
+		return 0;
+
+	p_l2_info = kzalloc(sizeof(*p_l2_info), GFP_KERNEL);
+	if (!p_l2_info)
+		return -ENOMEM;
+	p_hwfn->p_l2_info = p_l2_info;
+
+	if (IS_PF(p_hwfn->cdev)) {
+		p_l2_info->queues = RESC_NUM(p_hwfn, QED_L2_QUEUE);
+	} else {
+		u8 rx = 0, tx = 0;
+
+		qed_vf_get_num_rxqs(p_hwfn, &rx);
+		qed_vf_get_num_txqs(p_hwfn, &tx);
+
+		p_l2_info->queues = max_t(u8, rx, tx);
+	}
+
+	pp_qids = kzalloc(sizeof(unsigned long *) * p_l2_info->queues,
+			  GFP_KERNEL);
+	if (!pp_qids)
+		return -ENOMEM;
+	p_l2_info->pp_qid_usage = pp_qids;
+
+	for (i = 0; i < p_l2_info->queues; i++) {
+		pp_qids[i] = kzalloc(MAX_QUEUES_PER_QZONE / 8, GFP_KERNEL);
+		if (!pp_qids[i])
+			return -ENOMEM;
+	}
+
+	return 0;
+}
+
+void qed_l2_setup(struct qed_hwfn *p_hwfn)
+{
+	if (p_hwfn->hw_info.personality != QED_PCI_ETH &&
+	    p_hwfn->hw_info.personality != QED_PCI_ETH_ROCE)
+		return;
+
+	mutex_init(&p_hwfn->p_l2_info->lock);
+}
+
+void qed_l2_free(struct qed_hwfn *p_hwfn)
+{
+	u32 i;
+
+	if (p_hwfn->hw_info.personality != QED_PCI_ETH &&
+	    p_hwfn->hw_info.personality != QED_PCI_ETH_ROCE)
+		return;
+
+	if (!p_hwfn->p_l2_info)
+		return;
+
+	if (!p_hwfn->p_l2_info->pp_qid_usage)
+		goto out_l2_info;
+
+	/* Free until hit first uninitialized entry */
+	for (i = 0; i < p_hwfn->p_l2_info->queues; i++) {
+		if (!p_hwfn->p_l2_info->pp_qid_usage[i])
+			break;
+		kfree(p_hwfn->p_l2_info->pp_qid_usage[i]);
+	}
+
+	kfree(p_hwfn->p_l2_info->pp_qid_usage);
+
+out_l2_info:
+	kfree(p_hwfn->p_l2_info);
+	p_hwfn->p_l2_info = NULL;
+}
+
 void qed_eth_queue_cid_release(struct qed_hwfn *p_hwfn,
 			       struct qed_queue_cid *p_cid)
 {
diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.h b/drivers/net/ethernet/qlogic/qed/qed_l2.h
index 6f44229..8606bbf 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.h
@@ -277,6 +277,8 @@ void qed_get_vport_stats(struct qed_dev *cdev, struct qed_eth_stats *stats);
 
 void qed_reset_vport_stats(struct qed_dev *cdev);
 
+#define MAX_QUEUES_PER_QZONE    (sizeof(unsigned long) * 8)
+
 struct qed_queue_cid {
 	/* 'Relative' is a relative term ;-). Usually the indices [not counting
 	 * SBs] would be PF-relative, but there are some cases where that isn't
@@ -302,6 +304,10 @@ struct qed_queue_cid {
 	struct qed_hwfn *p_owner;
 };
 
+int qed_l2_alloc(struct qed_hwfn *p_hwfn);
+void qed_l2_setup(struct qed_hwfn *p_hwfn);
+void qed_l2_free(struct qed_hwfn *p_hwfn);
+
 void qed_eth_queue_cid_release(struct qed_hwfn *p_hwfn,
 			       struct qed_queue_cid *p_cid);
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_vf.c b/drivers/net/ethernet/qlogic/qed/qed_vf.c
index 3703b22..29d7407 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_vf.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_vf.c
@@ -1363,6 +1363,11 @@ void qed_vf_get_num_rxqs(struct qed_hwfn *p_hwfn, u8 *num_rxqs)
 	*num_rxqs = p_hwfn->vf_iov_info->acquire_resp.resc.num_rxqs;
 }
 
+void qed_vf_get_num_txqs(struct qed_hwfn *p_hwfn, u8 *num_txqs)
+{
+	*num_txqs = p_hwfn->vf_iov_info->acquire_resp.resc.num_txqs;
+}
+
 void qed_vf_get_port_mac(struct qed_hwfn *p_hwfn, u8 *port_mac)
 {
 	memcpy(port_mac,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_vf.h b/drivers/net/ethernet/qlogic/qed/qed_vf.h
index 6786208..d7b9c90 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_vf.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_vf.h
@@ -684,6 +684,14 @@ void qed_vf_get_link_caps(struct qed_hwfn *p_hwfn,
 void qed_vf_get_num_rxqs(struct qed_hwfn *p_hwfn, u8 *num_rxqs);
 
 /**
+ * @brief Get number of Rx queues allocated for VF by qed
+ *
+ *  @param p_hwfn
+ *  @param num_txqs - allocated RX queues
+ */
+void qed_vf_get_num_txqs(struct qed_hwfn *p_hwfn, u8 *num_txqs);
+
+/**
  * @brief Get port mac address for VF
  *
  * @param p_hwfn
@@ -956,6 +964,10 @@ static inline void qed_vf_get_num_rxqs(struct qed_hwfn *p_hwfn, u8 *num_rxqs)
 {
 }
 
+static inline void qed_vf_get_num_txqs(struct qed_hwfn *p_hwfn, u8 *num_txqs)
+{
+}
+
 static inline void qed_vf_get_port_mac(struct qed_hwfn *p_hwfn, u8 *port_mac)
 {
 }
-- 
2.9.4
