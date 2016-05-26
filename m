From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 4/8] qed: Fix allocation in interrupt context
Date: Thu, 26 May 2016 11:01:20 +0300
Message-ID: <1464249684-976-5-git-send-email-Yuval.Mintz@qlogic.com>
References: <1464249684-976-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:60332 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753242AbcEZIBp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 04:01:45 -0400
In-Reply-To: <1464249684-976-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>

Commit 39651abd2814 ("qed: add support for dcbx") is re-configuring
the QM hw-block as part of its sequence. This is done in attention
handling context which is non-sleepable, yet memory is allocated in
this flow using GFP_KERNEL.

Signed-off-by: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c | 27 ++++++++++++++++-----------
 1 file changed, 16 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 089016f..7aeed2f 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -155,7 +155,7 @@ void qed_resc_free(struct qed_dev *cdev)
 	}
 }
 
-static int qed_init_qm_info(struct qed_hwfn *p_hwfn)
+static int qed_init_qm_info(struct qed_hwfn *p_hwfn, bool b_sleepable)
 {
 	u8 num_vports, vf_offset = 0, i, vport_id, num_ports, curr_queue = 0;
 	struct qed_qm_info *qm_info = &p_hwfn->qm_info;
@@ -182,23 +182,28 @@ static int qed_init_qm_info(struct qed_hwfn *p_hwfn)
 
 	/* PQs will be arranged as follows: First per-TC PQ then pure-LB quete.
 	 */
-	qm_info->qm_pq_params = kzalloc(sizeof(*qm_info->qm_pq_params) *
-					num_pqs, GFP_KERNEL);
+	qm_info->qm_pq_params = kcalloc(num_pqs,
+					sizeof(struct init_qm_pq_params),
+					b_sleepable ? GFP_KERNEL : GFP_ATOMIC);
 	if (!qm_info->qm_pq_params)
 		goto alloc_err;
 
-	qm_info->qm_vport_params = kzalloc(sizeof(*qm_info->qm_vport_params) *
-					   num_vports, GFP_KERNEL);
+	qm_info->qm_vport_params = kcalloc(num_vports,
+					   sizeof(struct init_qm_vport_params),
+					   b_sleepable ? GFP_KERNEL
+						       : GFP_ATOMIC);
 	if (!qm_info->qm_vport_params)
 		goto alloc_err;
 
-	qm_info->qm_port_params = kzalloc(sizeof(*qm_info->qm_port_params) *
-					  MAX_NUM_PORTS, GFP_KERNEL);
+	qm_info->qm_port_params = kcalloc(MAX_NUM_PORTS,
+					  sizeof(struct init_qm_port_params),
+					  b_sleepable ? GFP_KERNEL
+						      : GFP_ATOMIC);
 	if (!qm_info->qm_port_params)
 		goto alloc_err;
 
-	qm_info->wfq_data = kcalloc(num_vports, sizeof(*qm_info->wfq_data),
-				    GFP_KERNEL);
+	qm_info->wfq_data = kcalloc(num_vports, sizeof(struct qed_wfq_data),
+				    b_sleepable ? GFP_KERNEL : GFP_ATOMIC);
 	if (!qm_info->wfq_data)
 		goto alloc_err;
 
@@ -299,7 +304,7 @@ int qed_qm_reconf(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 	qed_qm_info_free(p_hwfn);
 
 	/* initialize qed's qm data structure */
-	rc = qed_init_qm_info(p_hwfn);
+	rc = qed_init_qm_info(p_hwfn, false);
 	if (rc)
 		return rc;
 
@@ -388,7 +393,7 @@ int qed_resc_alloc(struct qed_dev *cdev)
 			goto alloc_err;
 
 		/* Prepare and process QM requirements */
-		rc = qed_init_qm_info(p_hwfn);
+		rc = qed_init_qm_info(p_hwfn, true);
 		if (rc)
 			goto alloc_err;
 
-- 
1.9.3
