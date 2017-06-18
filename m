From: Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v2 net-next 6/7] qed: Wait for resources before FUNC_CLOSE
Date: Sun, 18 Jun 2017 14:50:34 +0300
Message-ID: <20170618115035.2156-7-Yuval.Mintz@cavium.com>
References: <20170618115035.2156-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170618115035.2156-1-Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>

Driver needs to wait for all resources to return from FW before it can send
the FUNC_CLOSE ramrod.

Signed-off-by: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
---
 drivers/net/ethernet/qlogic/qed/qed_roce.c | 35 +++++++++++++++++-------------
 1 file changed, 20 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_roce.c b/drivers/net/ethernet/qlogic/qed/qed_roce.c
index 8419dcc..7482905 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_roce.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_roce.c
@@ -372,22 +372,7 @@ static void qed_rdma_bmap_free(struct qed_hwfn *p_hwfn,
 
 static void qed_rdma_resc_free(struct qed_hwfn *p_hwfn)
 {
-	struct qed_bmap *rcid_map = &p_hwfn->p_rdma_info->real_cid_map;
 	struct qed_rdma_info *p_rdma_info = p_hwfn->p_rdma_info;
-	int wait_count = 0;
-
-	/* when destroying a_RoCE QP the control is returned to the user after
-	 * the synchronous part. The asynchronous part may take a little longer.
-	 * We delay for a short while if an async destroy QP is still expected.
-	 * Beyond the added delay we clear the bitmap anyway.
-	 */
-	while (bitmap_weight(rcid_map->bitmap, rcid_map->max_count)) {
-		msleep(100);
-		if (wait_count++ > 20) {
-			DP_NOTICE(p_hwfn, "cid bitmap wait timed out\n");
-			break;
-		}
-	}
 
 	qed_rdma_bmap_free(p_hwfn, &p_hwfn->p_rdma_info->cid_map, 1);
 	qed_rdma_bmap_free(p_hwfn, &p_hwfn->p_rdma_info->pd_map, 1);
@@ -704,6 +689,25 @@ static int qed_rdma_setup(struct qed_hwfn *p_hwfn,
 	return qed_rdma_start_fw(p_hwfn, params, p_ptt);
 }
 
+void qed_roce_stop(struct qed_hwfn *p_hwfn)
+{
+	struct qed_bmap *rcid_map = &p_hwfn->p_rdma_info->real_cid_map;
+	int wait_count = 0;
+
+	/* when destroying a_RoCE QP the control is returned to the user after
+	 * the synchronous part. The asynchronous part may take a little longer.
+	 * We delay for a short while if an async destroy QP is still expected.
+	 * Beyond the added delay we clear the bitmap anyway.
+	 */
+	while (bitmap_weight(rcid_map->bitmap, rcid_map->max_count)) {
+		msleep(100);
+		if (wait_count++ > 20) {
+			DP_NOTICE(p_hwfn, "cid bitmap wait timed out\n");
+			break;
+		}
+	}
+}
+
 static int qed_rdma_stop(void *rdma_cxt)
 {
 	struct qed_hwfn *p_hwfn = (struct qed_hwfn *)rdma_cxt;
@@ -733,6 +737,7 @@ static int qed_rdma_stop(void *rdma_cxt)
 	qed_wr(p_hwfn, p_ptt, PRS_REG_LIGHT_L2_ETHERTYPE_EN,
 	       (ll2_ethertype_en & 0xFFFE));
 
+	qed_roce_stop(p_hwfn);
 	qed_ptt_release(p_hwfn, p_ptt);
 
 	/* Get SPQ entry */
-- 
2.9.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
