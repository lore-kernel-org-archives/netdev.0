From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 6/7] qed: Wait for resources before FUNC_CLOSE
Date: Thu, 15 Jun 2017 23:29:32 +0300
Message-ID: <20170615202933.20934-7-Yuval.Mintz@cavium.com>
References: <20170615202933.20934-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma@vger.kernel.org>,
        Michal Kalderon <Michal.Kalderon@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0040.outbound.protection.outlook.com ([104.47.40.40]:43017
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752449AbdFOUcY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Jun 2017 16:32:24 -0400
In-Reply-To: <20170615202933.20934-1-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kalderon <Michal.Kalderon@cavium.com>

Driver needs to wait for all resources to return from FW before it can send
the FUNC_CLOSE ramrod.

Signed-off-by: Michal Kalderon <Michal.Kalderon@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
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
