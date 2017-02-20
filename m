From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 02/10] qed: Read queue state before releasing buffer
Date: Mon, 20 Feb 2017 22:43:31 +0200
Message-ID: <1487623419-6442-3-git-send-email-Yuval.Mintz@cavium.com>
References: <1487623419-6442-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ram Amrani <Ram.Amrani@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:46406 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751082AbdBTU7b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 15:59:31 -0500
In-Reply-To: <1487623419-6442-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ram Amrani <Ram.Amrani@cavium.com>

Currently the state is read only after the buffers are relesed.

Signed-off-by: Ram Amrani <Ram.Amrani@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_roce.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_roce.c b/drivers/net/ethernet/qlogic/qed/qed_roce.c
index 50fdcd3..65d5b9a 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_roce.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_roce.c
@@ -1768,13 +1768,13 @@ static int qed_roce_query_qp(struct qed_hwfn *p_hwfn,
 	if (rc)
 		goto err_resp;
 
-	dma_free_coherent(&p_hwfn->cdev->pdev->dev, sizeof(*p_resp_ramrod_res),
-			  p_resp_ramrod_res, resp_ramrod_res_phys);
-
 	out_params->rq_psn = le32_to_cpu(p_resp_ramrod_res->psn);
 	rq_err_state = GET_FIELD(le32_to_cpu(p_resp_ramrod_res->err_flag),
 				 ROCE_QUERY_QP_RESP_OUTPUT_PARAMS_ERROR_FLG);
 
+	dma_free_coherent(&p_hwfn->cdev->pdev->dev, sizeof(*p_resp_ramrod_res),
+			  p_resp_ramrod_res, resp_ramrod_res_phys);
+
 	if (!(qp->req_offloaded)) {
 		/* Don't send query qp for the requester */
 		out_params->sq_psn = qp->sq_psn;
@@ -1815,9 +1815,6 @@ static int qed_roce_query_qp(struct qed_hwfn *p_hwfn,
 	if (rc)
 		goto err_req;
 
-	dma_free_coherent(&p_hwfn->cdev->pdev->dev, sizeof(*p_req_ramrod_res),
-			  p_req_ramrod_res, req_ramrod_res_phys);
-
 	out_params->sq_psn = le32_to_cpu(p_req_ramrod_res->psn);
 	sq_err_state = GET_FIELD(le32_to_cpu(p_req_ramrod_res->flags),
 				 ROCE_QUERY_QP_REQ_OUTPUT_PARAMS_ERR_FLG);
@@ -1825,6 +1822,9 @@ static int qed_roce_query_qp(struct qed_hwfn *p_hwfn,
 		GET_FIELD(le32_to_cpu(p_req_ramrod_res->flags),
 			  ROCE_QUERY_QP_REQ_OUTPUT_PARAMS_SQ_DRAINING_FLG);
 
+	dma_free_coherent(&p_hwfn->cdev->pdev->dev, sizeof(*p_req_ramrod_res),
+			  p_req_ramrod_res, req_ramrod_res_phys);
+
 	out_params->draining = false;
 
 	if (rq_err_state)
-- 
1.9.3
