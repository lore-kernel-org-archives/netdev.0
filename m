From: Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net 2/2] qed: Correct rdma params configuration
Date: Wed, 9 Nov 2016 22:48:44 +0200
Message-ID: <1478724524-16940-3-git-send-email-Yuval.Mintz@cavium.com>
References: <1478724524-16940-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>, Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1478724524-16940-1-git-send-email-Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ram Amrani <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>

Previous fix has broken RoCE support as the rdma_pf_params are now
being set into the parameters only after the params are alrady assigned
into the hw-function.

Fixes: 0189efb8f4f8 ("qed*: Fix Kconfig dependencies with INFINIBAND_QEDR")
Signed-off-by: Ram Amrani <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
---
 drivers/net/ethernet/qlogic/qed/qed_main.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index c418360..333c744 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -839,20 +839,19 @@ static void qed_update_pf_params(struct qed_dev *cdev,
 {
 	int i;
 
+	if (IS_ENABLED(CONFIG_QED_RDMA)) {
+		params->rdma_pf_params.num_qps = QED_ROCE_QPS;
+		params->rdma_pf_params.min_dpis = QED_ROCE_DPIS;
+		/* divide by 3 the MRs to avoid MF ILT overflow */
+		params->rdma_pf_params.num_mrs = RDMA_MAX_TIDS;
+		params->rdma_pf_params.gl_pi = QED_ROCE_PROTOCOL_INDEX;
+	}
+
 	for (i = 0; i < cdev->num_hwfns; i++) {
 		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
 
 		p_hwfn->pf_params = *params;
 	}
-
-	if (!IS_ENABLED(CONFIG_QED_RDMA))
-		return;
-
-	params->rdma_pf_params.num_qps = QED_ROCE_QPS;
-	params->rdma_pf_params.min_dpis = QED_ROCE_DPIS;
-	/* divide by 3 the MRs to avoid MF ILT overflow */
-	params->rdma_pf_params.num_mrs = RDMA_MAX_TIDS;
-	params->rdma_pf_params.gl_pi = QED_ROCE_PROTOCOL_INDEX;
 }
 
 static int qed_slowpath_start(struct qed_dev *cdev,
-- 
1.9.3

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
