From: Michal Kalderon <Michal.Kalderon@cavium.com>
Subject: [PATCH net-next 3/4] qed: Fix maximum number of CQs for iWARP
Date: Tue, 19 Sep 2017 20:26:18 +0300
Message-ID: <1505841979-26365-4-git-send-email-Michal.Kalderon@cavium.com>
References: <1505841979-26365-1-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma@vger.kernel.org>, <dledford@redhat.com>,
        Michal Kalderon <Michal.Kalderon@cavium.com>,
        Ariel Elior <Ariel.Elior@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0062.outbound.protection.outlook.com ([104.47.32.62]:63168
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751471AbdISR1e (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 19 Sep 2017 13:27:34 -0400
In-Reply-To: <1505841979-26365-1-git-send-email-Michal.Kalderon@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The maximum number of CQs supported is bound to the number
of connections supported, which differs between RoCE and iWARP.

This fixes a crash that occurred in iWARP when running 1000 sessions
using perftest.

Signed-off-by: Michal Kalderon <Michal.Kalderon@cavium.com>
Signed-off-by: Ariel Elior <Ariel.Elior@cavium.com>
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
