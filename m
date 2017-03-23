From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 5/6] qed: Don't waste SBs unused by RoCE
Date: Thu, 23 Mar 2017 15:50:19 +0200
Message-ID: <1490277020-31208-6-git-send-email-Yuval.Mintz@cavium.com>
References: <1490277020-31208-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:45273 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S933674AbdCWNup (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 09:50:45 -0400
In-Reply-To: <1490277020-31208-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When RoCE is enabled on a given L2 interface, the interrupt lines
are divided equally between L2 and RoCE -
But in case number of lines needed for RoCE is limited by number
of available CNQs, we can utilize the additional lines for L2.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 8b5df71..6bdac4f 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -1550,7 +1550,7 @@ static void qed_hw_set_feat(struct qed_hwfn *p_hwfn)
 {
 	u32 *feat_num = p_hwfn->hw_info.feat_num;
 	struct qed_sb_cnt_info sb_cnt_info;
-	int num_features = 1;
+	u32 non_l2_sbs = 0;
 
 	if (IS_ENABLED(CONFIG_QED_RDMA) &&
 	    p_hwfn->hw_info.personality == QED_PCI_ETH_ROCE) {
@@ -1558,15 +1558,16 @@ static void qed_hw_set_feat(struct qed_hwfn *p_hwfn)
 		 * the status blocks equally between L2 / RoCE but with
 		 * consideration as to how many l2 queues / cnqs we have.
 		 */
-		num_features++;
-
 		feat_num[QED_RDMA_CNQ] =
-			min_t(u32, RESC_NUM(p_hwfn, QED_SB) / num_features,
+			min_t(u32, RESC_NUM(p_hwfn, QED_SB) / 2,
 			      RESC_NUM(p_hwfn, QED_RDMA_CNQ_RAM));
+
+		non_l2_sbs = feat_num[QED_RDMA_CNQ];
 	}
 
-	feat_num[QED_PF_L2_QUE] = min_t(u32, RESC_NUM(p_hwfn, QED_SB) /
-						num_features,
+	feat_num[QED_PF_L2_QUE] = min_t(u32,
+					RESC_NUM(p_hwfn, QED_SB) -
+					non_l2_sbs,
 					RESC_NUM(p_hwfn, QED_L2_QUEUE));
 
 	memset(&sb_cnt_info, 0, sizeof(sb_cnt_info));
@@ -1578,11 +1579,11 @@ static void qed_hw_set_feat(struct qed_hwfn *p_hwfn)
 
 	DP_VERBOSE(p_hwfn,
 		   NETIF_MSG_PROBE,
-		   "#PF_L2_QUEUES=%d VF_L2_QUEUES=%d #ROCE_CNQ=%d #SBS=%d num_features=%d\n",
+		   "#PF_L2_QUEUES=%d VF_L2_QUEUES=%d #ROCE_CNQ=%d #SBS=%d\n",
 		   (int)FEAT_NUM(p_hwfn, QED_PF_L2_QUE),
 		   (int)FEAT_NUM(p_hwfn, QED_VF_L2_QUE),
 		   (int)FEAT_NUM(p_hwfn, QED_RDMA_CNQ),
-		   RESC_NUM(p_hwfn, QED_SB), num_features);
+		   RESC_NUM(p_hwfn, QED_SB));
 }
 
 static enum resource_id_enum qed_hw_get_mfw_res_id(enum qed_resources res_id)
-- 
1.9.3
