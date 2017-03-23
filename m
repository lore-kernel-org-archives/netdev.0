From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 6/6] qed: Reserve VF feature before PF
Date: Thu, 23 Mar 2017 15:50:20 +0200
Message-ID: <1490277020-31208-7-git-send-email-Yuval.Mintz@cavium.com>
References: <1490277020-31208-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:46985 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933668AbdCWNut (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 09:50:49 -0400
In-Reply-To: <1490277020-31208-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Align the driver feature distribution with the flow utilized
by the management firmware - first reserve L2 queues for
VFs and use all the remaining for the PF.

The current distribution might lead to PFs with an enormous
amount of queues, but at the same time leave us with insufficient
resources for starting all VFs.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c | 27 ++++++++++++++++-----------
 1 file changed, 16 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 6bdac4f..11e45f0 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -1565,17 +1565,22 @@ static void qed_hw_set_feat(struct qed_hwfn *p_hwfn)
 		non_l2_sbs = feat_num[QED_RDMA_CNQ];
 	}
 
-	feat_num[QED_PF_L2_QUE] = min_t(u32,
-					RESC_NUM(p_hwfn, QED_SB) -
-					non_l2_sbs,
-					RESC_NUM(p_hwfn, QED_L2_QUEUE));
-
-	memset(&sb_cnt_info, 0, sizeof(sb_cnt_info));
-	qed_int_get_num_sbs(p_hwfn, &sb_cnt_info);
-	feat_num[QED_VF_L2_QUE] =
-	    min_t(u32,
-		  RESC_NUM(p_hwfn, QED_L2_QUEUE) -
-		  FEAT_NUM(p_hwfn, QED_PF_L2_QUE), sb_cnt_info.sb_iov_cnt);
+	if (p_hwfn->hw_info.personality == QED_PCI_ETH_ROCE ||
+	    p_hwfn->hw_info.personality == QED_PCI_ETH) {
+		/* Start by allocating VF queues, then PF's */
+		memset(&sb_cnt_info, 0, sizeof(sb_cnt_info));
+		qed_int_get_num_sbs(p_hwfn, &sb_cnt_info);
+		feat_num[QED_VF_L2_QUE] = min_t(u32,
+						RESC_NUM(p_hwfn, QED_L2_QUEUE),
+						sb_cnt_info.sb_iov_cnt);
+		feat_num[QED_PF_L2_QUE] = min_t(u32,
+						RESC_NUM(p_hwfn, QED_SB) -
+						non_l2_sbs,
+						RESC_NUM(p_hwfn,
+							 QED_L2_QUEUE) -
+						FEAT_NUM(p_hwfn,
+							 QED_VF_L2_QUE));
+	}
 
 	DP_VERBOSE(p_hwfn,
 		   NETIF_MSG_PROBE,
-- 
1.9.3
