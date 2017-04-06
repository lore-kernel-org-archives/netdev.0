From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 6/8] qed: Inform qedi the number of possible CQs
Date: Thu, 6 Apr 2017 15:58:33 +0300
Message-ID: <1491483515-13502-7-git-send-email-Yuval.Mintz@cavium.com>
References: <1491483515-13502-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:53266 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753213AbdDFNBR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 09:01:17 -0400
In-Reply-To: <1491483515-13502-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that management firmware is capable of telling us the number of CQs
available for a given PF, qed needs to communicate the number to qedi
so it would know have many to use.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed.h       |  3 ++-
 drivers/net/ethernet/qlogic/qed/qed_dev.c   |  7 ++++++-
 drivers/net/ethernet/qlogic/qed/qed_iscsi.c | 11 +++++++++++
 include/linux/qed/qed_iscsi_if.h            |  2 ++
 4 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index d8bcc21..4896ee0 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -225,8 +225,9 @@ enum QED_FEATURE {
 	QED_PF_L2_QUE,
 	QED_VF,
 	QED_RDMA_CNQ,
-	QED_VF_L2_QUE,
+	QED_ISCSI_CQ,
 	QED_FCOE_CQ,
+	QED_VF_L2_QUE,
 	QED_MAX_FEATURES,
 };
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index fb759ba..fad7319 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -2045,12 +2045,17 @@ static void qed_hw_set_feat(struct qed_hwfn *p_hwfn)
 							 QED_VF_L2_QUE));
 	}
 
+	if (p_hwfn->hw_info.personality == QED_PCI_ISCSI)
+		feat_num[QED_ISCSI_CQ] = min_t(u32, RESC_NUM(p_hwfn, QED_SB),
+					       RESC_NUM(p_hwfn,
+							QED_CMDQS_CQS));
 	DP_VERBOSE(p_hwfn,
 		   NETIF_MSG_PROBE,
-		   "#PF_L2_QUEUES=%d VF_L2_QUEUES=%d #ROCE_CNQ=%d #SBS=%d\n",
+		   "#PF_L2_QUEUES=%d VF_L2_QUEUES=%d #ROCE_CNQ=%d ISCSI_CQ=%d #SBS=%d\n",
 		   (int)FEAT_NUM(p_hwfn, QED_PF_L2_QUE),
 		   (int)FEAT_NUM(p_hwfn, QED_VF_L2_QUE),
 		   (int)FEAT_NUM(p_hwfn, QED_RDMA_CNQ),
+		   (int)FEAT_NUM(p_hwfn, QED_ISCSI_CQ),
 		   RESC_NUM(p_hwfn, QED_SB));
 }
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_iscsi.c b/drivers/net/ethernet/qlogic/qed/qed_iscsi.c
index 38273f4..417691c 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_iscsi.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_iscsi.c
@@ -181,6 +181,15 @@ struct qed_iscsi_conn {
 	p_params = &p_hwfn->pf_params.iscsi_pf_params;
 	p_queue = &p_init->q_params;
 
+	/* Sanity */
+	if (p_params->num_queues > p_hwfn->hw_info.feat_num[QED_ISCSI_CQ]) {
+		DP_ERR(p_hwfn,
+		       "Cannot satisfy CQ amount. Queues requested %d, CQs available %d. Aborting function start\n",
+		       p_params->num_queues,
+		       p_hwfn->hw_info.resc_num[QED_ISCSI_CQ]);
+		return -EINVAL;
+	}
+
 	SET_FIELD(p_init->hdr.flags,
 		  ISCSI_SLOW_PATH_HDR_LAYER_CODE, ISCSI_SLOW_PATH_LAYER_CODE);
 	p_init->hdr.op_code = ISCSI_RAMROD_CMD_ID_INIT_FUNC;
@@ -1012,6 +1021,8 @@ static int qed_fill_iscsi_dev_info(struct qed_dev *cdev,
 	info->secondary_bdq_rq_addr =
 	    qed_iscsi_get_secondary_bdq_prod(hwfn, BDQ_ID_RQ);
 
+	info->num_cqs = FEAT_NUM(hwfn, QED_ISCSI_CQ);
+
 	return rc;
 }
 
diff --git a/include/linux/qed/qed_iscsi_if.h b/include/linux/qed/qed_iscsi_if.h
index f70bb81..3414649 100644
--- a/include/linux/qed/qed_iscsi_if.h
+++ b/include/linux/qed/qed_iscsi_if.h
@@ -67,6 +67,8 @@ struct qed_dev_iscsi_info {
 
 	void __iomem *primary_dbq_rq_addr;
 	void __iomem *secondary_bdq_rq_addr;
+
+	u8 num_cqs;
 };
 
 struct qed_iscsi_id_params {
-- 
1.9.3
