From: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: [RFC 01/19] qed: Introduce iWARP personality
Date: Mon, 26 Jun 2017 21:06:51 +0300
Message-ID: <1498500429-22557-2-git-send-email-Michal.Kalderon@cavium.com>
References: <1498500429-22557-1-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        Ariel Elior <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: <michal.kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>, <ram.amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        <yuval.mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>, <ariel.elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1498500429-22557-1-git-send-email-Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

iWARP personality introduced the need for differentiating in several
places in the code whether we are RoCE, iWARP or either. This
leads to introducing new macros for querying the personality.

Signed-off-by: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Ariel Elior <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>

---
 drivers/net/ethernet/qlogic/qed/qed.h      | 26 +++++++++++++++++++++++---
 drivers/net/ethernet/qlogic/qed/qed_cxt.c  |  8 ++++----
 drivers/net/ethernet/qlogic/qed/qed_dev.c  | 12 +++++-------
 drivers/net/ethernet/qlogic/qed/qed_l2.c   |  3 +--
 drivers/net/ethernet/qlogic/qed/qed_ll2.c  |  2 +-
 drivers/net/ethernet/qlogic/qed/qed_main.c | 17 ++++++++---------
 include/linux/qed/common_hsi.h             |  2 +-
 7 files changed, 43 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index 14b08ee..22e1171 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -210,14 +210,16 @@ struct qed_tunn_update_params {
 
 /* The PCI personality is not quite synonymous to protocol ID:
  * 1. All personalities need CORE connections
- * 2. The Ethernet personality may support also the RoCE protocol
+ * 2. The Ethernet personality may support also the RoCE/iWARP protocol
  */
 enum qed_pci_personality {
 	QED_PCI_ETH,
 	QED_PCI_FCOE,
 	QED_PCI_ISCSI,
 	QED_PCI_ETH_ROCE,
-	QED_PCI_DEFAULT /* default in shmem */
+	QED_PCI_ETH_IWARP,
+	QED_PCI_ETH_RDMA,
+	QED_PCI_DEFAULT, /* default in shmem */
 };
 
 /* All VFs are symmetric, all counters are PF + all VFs */
@@ -277,6 +279,7 @@ enum qed_dev_cap {
 	QED_DEV_CAP_FCOE,
 	QED_DEV_CAP_ISCSI,
 	QED_DEV_CAP_ROCE,
+	QED_DEV_CAP_IWARP,
 };
 
 enum qed_wol_support {
@@ -286,7 +289,24 @@ enum qed_wol_support {
 
 struct qed_hw_info {
 	/* PCI personality */
-	enum qed_pci_personality	personality;
+	enum qed_pci_personality personality;
+#define QED_IS_RDMA_PERSONALITY(dev)			    \
+	((dev)->hw_info.personality == QED_PCI_ETH_ROCE ||  \
+	 (dev)->hw_info.personality == QED_PCI_ETH_IWARP || \
+	 (dev)->hw_info.personality == QED_PCI_ETH_RDMA)
+#define QED_IS_ROCE_PERSONALITY(dev)			   \
+	((dev)->hw_info.personality == QED_PCI_ETH_ROCE || \
+	 (dev)->hw_info.personality == QED_PCI_ETH_RDMA)
+#define QED_IS_IWARP_PERSONALITY(dev)			    \
+	((dev)->hw_info.personality == QED_PCI_ETH_IWARP || \
+	 (dev)->hw_info.personality == QED_PCI_ETH_RDMA)
+#define QED_IS_L2_PERSONALITY(dev)		      \
+	((dev)->hw_info.personality == QED_PCI_ETH || \
+	 QED_IS_RDMA_PERSONALITY(dev))
+#define QED_IS_FCOE_PERSONALITY(dev) \
+	((dev)->hw_info.personality == QED_PCI_FCOE)
+#define QED_IS_ISCSI_PERSONALITY(dev) \
+	((dev)->hw_info.personality == QED_PCI_ISCSI)
 
 	/* Resource Allocation scheme results */
 	u32				resc_start[QED_MAX_RESC];
diff --git a/drivers/net/ethernet/qlogic/qed/qed_cxt.c b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
index e201214..38716f7 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_cxt.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
@@ -853,7 +853,7 @@ u32 qed_cxt_cfg_ilt_compute_excess(struct qed_hwfn *p_hwfn, u32 used_lines)
 	if (!excess_lines)
 		return 0;
 
-	if (p_hwfn->hw_info.personality != QED_PCI_ETH_ROCE)
+	if (!QED_IS_RDMA_PERSONALITY(p_hwfn))
 		return 0;
 
 	p_mngr = p_hwfn->p_cxt_mngr;
@@ -1033,7 +1033,7 @@ static int qed_ilt_blk_alloc(struct qed_hwfn *p_hwfn,
 	u32 lines, line, sz_left, lines_to_skip = 0;
 
 	/* Special handling for RoCE that supports dynamic allocation */
-	if ((p_hwfn->hw_info.personality == QED_PCI_ETH_ROCE) &&
+	if (QED_IS_RDMA_PERSONALITY(p_hwfn) &&
 	    ((ilt_client == ILT_CLI_CDUT) || ilt_client == ILT_CLI_TSDM))
 		return 0;
 
@@ -1833,7 +1833,7 @@ static void qed_tm_init_pf(struct qed_hwfn *p_hwfn)
 		tm_offset += tm_iids.pf_tids[i];
 	}
 
-	if (p_hwfn->hw_info.personality == QED_PCI_ETH_ROCE)
+	if (QED_IS_RDMA_PERSONALITY(p_hwfn))
 		active_seg_mask = 0;
 
 	STORE_RT_REG(p_hwfn, TM_REG_PF_ENABLE_TASK_RT_OFFSET, active_seg_mask);
@@ -2344,7 +2344,7 @@ int qed_cxt_get_tid_mem_info(struct qed_hwfn *p_hwfn,
 		       last_cid_allocated - 1);
 
 		if (!p_hwfn->b_rdma_enabled_in_prs) {
-			/* Enable RoCE search */
+			/* Enable RDMA search */
 			qed_wr(p_hwfn, p_ptt, p_hwfn->rdma_prs_search_reg, 1);
 			p_hwfn->b_rdma_enabled_in_prs = true;
 		}
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 49667ad..68e6182 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -936,7 +936,7 @@ int qed_resc_alloc(struct qed_dev *cdev)
 
 		/* EQ */
 		n_eqes = qed_chain_get_capacity(&p_hwfn->p_spq->chain);
-		if (p_hwfn->hw_info.personality == QED_PCI_ETH_ROCE) {
+		if (QED_IS_RDMA_PERSONALITY(p_hwfn)) {
 			num_cons = qed_cxt_get_proto_cid_count(p_hwfn,
 							       PROTOCOLID_ROCE,
 							       NULL) * 2;
@@ -2057,7 +2057,7 @@ static void qed_hw_set_feat(struct qed_hwfn *p_hwfn)
 	qed_int_get_num_sbs(p_hwfn, &sb_cnt);
 
 	if (IS_ENABLED(CONFIG_QED_RDMA) &&
-	    p_hwfn->hw_info.personality == QED_PCI_ETH_ROCE) {
+	    QED_IS_RDMA_PERSONALITY(p_hwfn)) {
 		/* Roce CNQ each requires: 1 status block + 1 CNQ. We divide
 		 * the status blocks equally between L2 / RoCE but with
 		 * consideration as to how many l2 queues / cnqs we have.
@@ -2068,9 +2068,7 @@ static void qed_hw_set_feat(struct qed_hwfn *p_hwfn)
 
 		non_l2_sbs = feat_num[QED_RDMA_CNQ];
 	}
-
-	if (p_hwfn->hw_info.personality == QED_PCI_ETH_ROCE ||
-	    p_hwfn->hw_info.personality == QED_PCI_ETH) {
+	if (QED_IS_L2_PERSONALITY(p_hwfn)) {
 		/* Start by allocating VF queues, then PF's */
 		feat_num[QED_VF_L2_QUE] = min_t(u32,
 						RESC_NUM(p_hwfn, QED_L2_QUEUE),
@@ -2083,12 +2081,12 @@ static void qed_hw_set_feat(struct qed_hwfn *p_hwfn)
 							 QED_VF_L2_QUE));
 	}
 
-	if (p_hwfn->hw_info.personality == QED_PCI_FCOE)
+	if (QED_IS_FCOE_PERSONALITY(p_hwfn))
 		feat_num[QED_FCOE_CQ] =  min_t(u32, sb_cnt.cnt,
 					       RESC_NUM(p_hwfn,
 							QED_CMDQS_CQS));
 
-	if (p_hwfn->hw_info.personality == QED_PCI_ISCSI)
+	if (QED_IS_ISCSI_PERSONALITY(p_hwfn))
 		feat_num[QED_ISCSI_CQ] = min_t(u32, sb_cnt.cnt,
 					       RESC_NUM(p_hwfn,
 							QED_CMDQS_CQS));
diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index e57699b..27ea54b 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -79,8 +79,7 @@ int qed_l2_alloc(struct qed_hwfn *p_hwfn)
 	unsigned long **pp_qids;
 	u32 i;
 
-	if (p_hwfn->hw_info.personality != QED_PCI_ETH &&
-	    p_hwfn->hw_info.personality != QED_PCI_ETH_ROCE)
+	if (!QED_IS_L2_PERSONALITY(p_hwfn))
 		return 0;
 
 	p_l2_info = kzalloc(sizeof(*p_l2_info), GFP_KERNEL);
diff --git a/drivers/net/ethernet/qlogic/qed/qed_ll2.c b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
index 17f9b0a..be66f19 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_ll2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
@@ -1421,7 +1421,7 @@ int qed_ll2_establish_connection(void *cxt, u8 connection_handle)
 	if (rc)
 		goto out;
 
-	if (p_hwfn->hw_info.personality != QED_PCI_ETH_ROCE)
+	if (!QED_IS_RDMA_PERSONALITY(p_hwfn))
 		qed_wr(p_hwfn, p_ptt, PRS_REG_USE_LIGHT_L2, 1);
 
 	qed_ll2_establish_connection_ooo(p_hwfn, p_ll2_conn);
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index 16cc30b..b113996 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -237,6 +237,8 @@ static int qed_init_pci(struct qed_dev *cdev, struct pci_dev *pdev)
 int qed_fill_dev_info(struct qed_dev *cdev,
 		      struct qed_dev_info *dev_info)
 {
+	struct qed_hwfn *p_hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_hw_info *hw_info = &p_hwfn->hw_info;
 	struct qed_tunnel_info *tun = &cdev->tunnel;
 	struct qed_ptt  *ptt;
 
@@ -260,11 +262,10 @@ int qed_fill_dev_info(struct qed_dev *cdev,
 	dev_info->pci_mem_start = cdev->pci_params.mem_start;
 	dev_info->pci_mem_end = cdev->pci_params.mem_end;
 	dev_info->pci_irq = cdev->pci_params.irq;
-	dev_info->rdma_supported = (cdev->hwfns[0].hw_info.personality ==
-				    QED_PCI_ETH_ROCE);
+	dev_info->rdma_supported = QED_IS_RDMA_PERSONALITY(p_hwfn);
 	dev_info->is_mf_default = IS_MF_DEFAULT(&cdev->hwfns[0]);
 	dev_info->dev_type = cdev->type;
-	ether_addr_copy(dev_info->hw_mac, cdev->hwfns[0].hw_info.hw_mac_addr);
+	ether_addr_copy(dev_info->hw_mac, hw_info->hw_mac_addr);
 
 	if (IS_PF(cdev)) {
 		dev_info->fw_major = FW_MAJOR_VERSION;
@@ -274,8 +275,7 @@ int qed_fill_dev_info(struct qed_dev *cdev,
 		dev_info->mf_mode = cdev->mf_mode;
 		dev_info->tx_switching = true;
 
-		if (QED_LEADING_HWFN(cdev)->hw_info.b_wol_support ==
-		    QED_WOL_SUPPORT_PME)
+		if (hw_info->b_wol_support == QED_WOL_SUPPORT_PME)
 			dev_info->wol_support = true;
 
 		dev_info->abs_pf_id = QED_LEADING_HWFN(cdev)->abs_pf_id;
@@ -304,7 +304,7 @@ int qed_fill_dev_info(struct qed_dev *cdev,
 				    &dev_info->mfw_rev, NULL);
 	}
 
-	dev_info->mtu = QED_LEADING_HWFN(cdev)->hw_info.mtu;
+	dev_info->mtu = hw_info->mtu;
 
 	return 0;
 }
@@ -790,7 +790,7 @@ static int qed_slowpath_setup_int(struct qed_dev *cdev,
 				       cdev->num_hwfns;
 
 	if (!IS_ENABLED(CONFIG_QED_RDMA) ||
-	    QED_LEADING_HWFN(cdev)->hw_info.personality != QED_PCI_ETH_ROCE)
+	    !QED_IS_RDMA_PERSONALITY(QED_LEADING_HWFN(cdev)))
 		return 0;
 
 	for_each_hwfn(cdev, i)
@@ -931,8 +931,7 @@ static void qed_update_pf_params(struct qed_dev *cdev,
 	/* In case we might support RDMA, don't allow qede to be greedy
 	 * with the L2 contexts. Allow for 64 queues [rx, tx, xdp] per hwfn.
 	 */
-	if (QED_LEADING_HWFN(cdev)->hw_info.personality ==
-	    QED_PCI_ETH_ROCE) {
+	if (QED_IS_RDMA_PERSONALITY(QED_LEADING_HWFN(cdev))) {
 		u16 *num_cons;
 
 		num_cons = &params->eth_pf_params.num_cons;
diff --git a/include/linux/qed/common_hsi.h b/include/linux/qed/common_hsi.h
index a567cbf..885ae13 100644
--- a/include/linux/qed/common_hsi.h
+++ b/include/linux/qed/common_hsi.h
@@ -778,7 +778,7 @@ enum protocol_type {
 	PROTOCOLID_ROCE,
 	PROTOCOLID_CORE,
 	PROTOCOLID_ETH,
-	PROTOCOLID_RESERVED4,
+	PROTOCOLID_IWARP,
 	PROTOCOLID_RESERVED5,
 	PROTOCOLID_PREROCE,
 	PROTOCOLID_COMMON,
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
