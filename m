From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 2/5] qed: Fix TM block ILT allocation
Date: Mon, 3 Apr 2017 12:21:10 +0300
Message-ID: <1491211273-10910-3-git-send-email-Yuval.Mintz@cavium.com>
References: <1491211273-10910-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Michal Kalderon <Michal.Kalderon@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:51517 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751460AbdDCJVv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Apr 2017 05:21:51 -0400
In-Reply-To: <1491211273-10910-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kalderon <Michal.Kalderon@cavium.com>

When configuring the HW timers block we should set the number of CIDs
up until the last CID that require timers, instead of only those CIDs
whose protocol needs timers support.

Today, the protocols that require HW timers' support have their CIDs
before any other protocol, but that would change in future [when we
add iWARP support].

Signed-off-by: Michal Kalderon <Michal.Kalderon@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_cxt.c | 32 ++++++++++++++++++++++++-------
 1 file changed, 25 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_cxt.c b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
index 1012b3c..259dafa 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_cxt.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
@@ -303,16 +303,34 @@ struct qed_tm_iids {
 	u32 per_vf_tids;
 };
 
-static void qed_cxt_tm_iids(struct qed_cxt_mngr *p_mngr,
+static void qed_cxt_tm_iids(struct qed_hwfn *p_hwfn,
+			    struct qed_cxt_mngr *p_mngr,
 			    struct qed_tm_iids *iids)
 {
-	u32 i, j;
-
-	for (i = 0; i < MAX_CONN_TYPES; i++) {
+	bool tm_vf_required = false;
+	bool tm_required = false;
+	int i, j;
+
+	/* Timers is a special case -> we don't count how many cids require
+	 * timers but what's the max cid that will be used by the timer block.
+	 * therefore we traverse in reverse order, and once we hit a protocol
+	 * that requires the timers memory, we'll sum all the protocols up
+	 * to that one.
+	 */
+	for (i = MAX_CONN_TYPES - 1; i >= 0; i--) {
 		struct qed_conn_type_cfg *p_cfg = &p_mngr->conn_cfg[i];
 
-		if (tm_cid_proto(i)) {
+		if (tm_cid_proto(i) || tm_required) {
+			if (p_cfg->cid_count)
+				tm_required = true;
+
 			iids->pf_cids += p_cfg->cid_count;
+		}
+
+		if (tm_cid_proto(i) || tm_vf_required) {
+			if (p_cfg->cids_per_vf)
+				tm_vf_required = true;
+
 			iids->per_vf_cids += p_cfg->cids_per_vf;
 		}
 
@@ -744,7 +762,7 @@ int qed_cxt_cfg_ilt_compute(struct qed_hwfn *p_hwfn)
 
 	/* TM PF */
 	p_cli = &p_mngr->clients[ILT_CLI_TM];
-	qed_cxt_tm_iids(p_mngr, &tm_iids);
+	qed_cxt_tm_iids(p_hwfn, p_mngr, &tm_iids);
 	total = tm_iids.pf_cids + tm_iids.pf_tids_total;
 	if (total) {
 		p_blk = &p_cli->pf_blks[0];
@@ -1632,7 +1650,7 @@ static void qed_tm_init_pf(struct qed_hwfn *p_hwfn)
 	u8 i;
 
 	memset(&tm_iids, 0, sizeof(tm_iids));
-	qed_cxt_tm_iids(p_mngr, &tm_iids);
+	qed_cxt_tm_iids(p_hwfn, p_mngr, &tm_iids);
 
 	/* @@@TBD No pre-scan for now */
 
-- 
1.9.3
