From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 2/4] qed: Share additional information with qedf
Date: Fri, 2 Jun 2017 08:58:31 +0300
Message-ID: <20170602055833.21814-3-Yuval.Mintz@cavium.com>
References: <20170602055833.21814-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-scsi@vger.kernel.org>, <nilesh.javali@cavium.com>,
        <chad.dupuis@cavium.com>, <saurav.kashyap@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20170602055833.21814-1-Yuval.Mintz@cavium.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Share several new tidbits with qedf:
 - wwpn & wwnn
 - Absolute pf-id [this one is actually meant for qedi as well]
 - Number of available CQs

While we're at it, now that qedf will be aware of the available CQs
we can add some validation on the inputs it provides.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c  |  8 +++++++-
 drivers/net/ethernet/qlogic/qed/qed_fcoe.c | 14 ++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_main.c |  2 ++
 include/linux/qed/qed_fcoe_if.h            |  5 +++++
 include/linux/qed/qed_if.h                 |  2 ++
 5 files changed, 30 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 7649f35..2d88d48 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -2071,16 +2071,22 @@ static void qed_hw_set_feat(struct qed_hwfn *p_hwfn)
 							 QED_VF_L2_QUE));
 	}
 
+	if (p_hwfn->hw_info.personality == QED_PCI_FCOE)
+		feat_num[QED_FCOE_CQ] =  min_t(u32, sb_cnt.cnt,
+					       RESC_NUM(p_hwfn,
+							QED_CMDQS_CQS));
+
 	if (p_hwfn->hw_info.personality == QED_PCI_ISCSI)
 		feat_num[QED_ISCSI_CQ] = min_t(u32, sb_cnt.cnt,
 					       RESC_NUM(p_hwfn,
 							QED_CMDQS_CQS));
 	DP_VERBOSE(p_hwfn,
 		   NETIF_MSG_PROBE,
-		   "#PF_L2_QUEUES=%d VF_L2_QUEUES=%d #ROCE_CNQ=%d ISCSI_CQ=%d #SBS=%d\n",
+		   "#PF_L2_QUEUES=%d VF_L2_QUEUES=%d #ROCE_CNQ=%d FCOE_CQ=%d ISCSI_CQ=%d #SBS=%d\n",
 		   (int)FEAT_NUM(p_hwfn, QED_PF_L2_QUE),
 		   (int)FEAT_NUM(p_hwfn, QED_VF_L2_QUE),
 		   (int)FEAT_NUM(p_hwfn, QED_RDMA_CNQ),
+		   (int)FEAT_NUM(p_hwfn, QED_FCOE_CQ),
 		   (int)FEAT_NUM(p_hwfn, QED_ISCSI_CQ),
 		   (int)sb_cnt.cnt);
 }
diff --git a/drivers/net/ethernet/qlogic/qed/qed_fcoe.c b/drivers/net/ethernet/qlogic/qed/qed_fcoe.c
index 3fc4ff2..df195c0 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_fcoe.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_fcoe.c
@@ -141,6 +141,15 @@ qed_sp_fcoe_func_start(struct qed_hwfn *p_hwfn,
 	p_data = &p_ramrod->init_ramrod_data;
 	fcoe_pf_params = &p_hwfn->pf_params.fcoe_pf_params;
 
+	/* Sanity */
+	if (fcoe_pf_params->num_cqs > p_hwfn->hw_info.feat_num[QED_FCOE_CQ]) {
+		DP_ERR(p_hwfn,
+		       "Cannot satisfy CQ amount. CQs requested %d, CQs available %d. Aborting function start\n",
+		       fcoe_pf_params->num_cqs,
+		       p_hwfn->hw_info.feat_num[QED_FCOE_CQ]);
+		return -EINVAL;
+	}
+
 	p_data->mtu = cpu_to_le16(fcoe_pf_params->mtu);
 	tmp = cpu_to_le16(fcoe_pf_params->sq_num_pbl_pages);
 	p_data->sq_num_pages_in_pbl = tmp;
@@ -739,6 +748,11 @@ static int qed_fill_fcoe_dev_info(struct qed_dev *cdev,
 	info->secondary_bdq_rq_addr =
 	    qed_fcoe_get_secondary_bdq_prod(hwfn, BDQ_ID_RQ);
 
+	info->wwpn = hwfn->mcp_info->func_info.wwn_port;
+	info->wwnn = hwfn->mcp_info->func_info.wwn_node;
+
+	info->num_cqs = FEAT_NUM(hwfn, QED_FCOE_CQ);
+
 	return rc;
 }
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index ac3bdcd..baebd59 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -269,6 +269,8 @@ int qed_fill_dev_info(struct qed_dev *cdev,
 		if (QED_LEADING_HWFN(cdev)->hw_info.b_wol_support ==
 		    QED_WOL_SUPPORT_PME)
 			dev_info->wol_support = true;
+
+		dev_info->abs_pf_id = QED_LEADING_HWFN(cdev)->abs_pf_id;
 	} else {
 		qed_vf_get_fw_version(&cdev->hwfns[0], &dev_info->fw_major,
 				      &dev_info->fw_minor, &dev_info->fw_rev,
diff --git a/include/linux/qed/qed_fcoe_if.h b/include/linux/qed/qed_fcoe_if.h
index bd6bcb8..1e015c5 100644
--- a/include/linux/qed/qed_fcoe_if.h
+++ b/include/linux/qed/qed_fcoe_if.h
@@ -24,6 +24,11 @@ struct qed_dev_fcoe_info {
 
 	void __iomem *primary_dbq_rq_addr;
 	void __iomem *secondary_bdq_rq_addr;
+
+	u64 wwpn;
+	u64 wwnn;
+
+	u8 num_cqs;
 };
 
 struct qed_fcoe_params_offload {
diff --git a/include/linux/qed/qed_if.h b/include/linux/qed/qed_if.h
index 607e1c5..e29c6f7 100644
--- a/include/linux/qed/qed_if.h
+++ b/include/linux/qed/qed_if.h
@@ -360,6 +360,8 @@ struct qed_dev_info {
 	bool		vxlan_enable;
 	bool		gre_enable;
 	bool		geneve_enable;
+
+	u8		abs_pf_id;
 };
 
 enum qed_sb_type {
-- 
2.9.4
