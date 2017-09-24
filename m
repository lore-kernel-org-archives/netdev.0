From: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v2 net-next 3/4] qed: Fix maximum number of CQs for iWARP
Date: Sun, 24 Sep 2017 12:09:44 +0300
Message-ID: <1506244185-2129-4-git-send-email-Michal.Kalderon@cavium.com>
References: <1506244185-2129-1-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        Ariel Elior <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1506244185-2129-1-git-send-email-Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The maximum number of CQs supported is bound to the number
of connections supported, which differs between RoCE and iWARP.

This fixes a crash that occurred in iWARP when running 1000 sessions
using perftest.

Fixes: 67b40dccc45 ("qed: Implement iWARP initialization, teardown and qp operations")

Signed-off-by: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Ariel Elior <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
---
 drivers/net/ethernet/qlogic/qed/qed_rdma.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_rdma.c b/drivers/net/ethernet/qlogic/qed/qed_rdma.c
index 4f46f28..c8c4b39 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_rdma.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_rdma.c
@@ -209,11 +209,11 @@ static int qed_rdma_alloc(struct qed_hwfn *p_hwfn,
 		goto free_pd_map;
 	}
 
-	/* Allocate bitmap for cq's. The maximum number of CQs is bounded to
-	 * twice the number of QPs.
+	/* Allocate bitmap for cq's. The maximum number of CQs is bound to
+	 * the number of connections we support. (num_qps in iWARP or
+	 * num_qps/2 in RoCE).
 	 */
-	rc = qed_rdma_bmap_alloc(p_hwfn, &p_rdma_info->cq_map,
-				 p_rdma_info->num_qps * 2, "CQ");
+	rc = qed_rdma_bmap_alloc(p_hwfn, &p_rdma_info->cq_map, num_cons, "CQ");
 	if (rc) {
 		DP_VERBOSE(p_hwfn, QED_MSG_RDMA,
 			   "Failed to allocate cq bitmap, rc = %d\n", rc);
@@ -222,10 +222,10 @@ static int qed_rdma_alloc(struct qed_hwfn *p_hwfn,
 
 	/* Allocate bitmap for toggle bit for cq icids
 	 * We toggle the bit every time we create or resize cq for a given icid.
-	 * The maximum number of CQs is bounded to  twice the number of QPs.
+	 * Size needs to equal the size of the cq bmap.
 	 */
 	rc = qed_rdma_bmap_alloc(p_hwfn, &p_rdma_info->toggle_bits,
-				 p_rdma_info->num_qps * 2, "Toggle");
+				 num_cons, "Toggle");
 	if (rc) {
 		DP_VERBOSE(p_hwfn, QED_MSG_RDMA,
 			   "Failed to allocate toogle bits, rc = %d\n", rc);
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
