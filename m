From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 5/5] qed: Manage with less memory regions for RoCE
Date: Mon, 3 Apr 2017 12:21:13 +0300
Message-ID: <1491211273-10910-6-git-send-email-Yuval.Mintz@cavium.com>
References: <1491211273-10910-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ram Amrani <Ram.Amrani@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:51526 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752609AbdDCJWD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Apr 2017 05:22:03 -0400
In-Reply-To: <1491211273-10910-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ram Amrani <Ram.Amrani@cavium.com>

It's possible some configurations would prevent driver from utilizing
all the Memory Regions due to a lack of ILT lines.
In such a case, calculate how many memory regions would have to be
dropped due to limit, and manage without those.

Signed-off-by: Ram Amrani <Ram.Amrani@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_cxt.c  | 113 +++++++++++++++++++++--------
 drivers/net/ethernet/qlogic/qed/qed_cxt.h  |  15 +++-
 drivers/net/ethernet/qlogic/qed/qed_dev.c  |  33 ++++++++-
 drivers/net/ethernet/qlogic/qed/qed_main.c |   1 -
 include/linux/qed/qed_if.h                 |   1 -
 5 files changed, 125 insertions(+), 38 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_cxt.c b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
index 8db0234..485b8b2 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_cxt.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
@@ -543,7 +543,22 @@ static u32 qed_ilt_get_dynamic_line_cnt(struct qed_hwfn *p_hwfn,
 	return lines_to_skip;
 }
 
-int qed_cxt_cfg_ilt_compute(struct qed_hwfn *p_hwfn)
+static struct qed_ilt_client_cfg *qed_cxt_set_cli(struct qed_ilt_client_cfg
+						  *p_cli)
+{
+	p_cli->active = false;
+	p_cli->first.val = 0;
+	p_cli->last.val = 0;
+	return p_cli;
+}
+
+static struct qed_ilt_cli_blk *qed_cxt_set_blk(struct qed_ilt_cli_blk *p_blk)
+{
+	p_blk->total_size = 0;
+	return p_blk;
+}
+
+int qed_cxt_cfg_ilt_compute(struct qed_hwfn *p_hwfn, u32 *line_count)
 {
 	struct qed_cxt_mngr *p_mngr = p_hwfn->p_cxt_mngr;
 	u32 curr_line, total, i, task_size, line;
@@ -567,7 +582,8 @@ int qed_cxt_cfg_ilt_compute(struct qed_hwfn *p_hwfn)
 		   p_hwfn->my_id, p_hwfn->p_cxt_mngr->pf_start_line);
 
 	/* CDUC */
-	p_cli = &p_mngr->clients[ILT_CLI_CDUC];
+	p_cli = qed_cxt_set_cli(&p_mngr->clients[ILT_CLI_CDUC]);
+
 	curr_line = p_mngr->pf_start_line;
 
 	/* CDUC PF */
@@ -576,7 +592,7 @@ int qed_cxt_cfg_ilt_compute(struct qed_hwfn *p_hwfn)
 	/* get the counters for the CDUC and QM clients  */
 	qed_cxt_cdu_iids(p_mngr, &cdu_iids);
 
-	p_blk = &p_cli->pf_blks[CDUC_BLK];
+	p_blk = qed_cxt_set_blk(&p_cli->pf_blks[CDUC_BLK]);
 
 	total = cdu_iids.pf_cids * CONN_CXT_SIZE(p_hwfn);
 
@@ -590,7 +606,7 @@ int qed_cxt_cfg_ilt_compute(struct qed_hwfn *p_hwfn)
 							       ILT_CLI_CDUC);
 
 	/* CDUC VF */
-	p_blk = &p_cli->vf_blks[CDUC_BLK];
+	p_blk = qed_cxt_set_blk(&p_cli->vf_blks[CDUC_BLK]);
 	total = cdu_iids.per_vf_cids * CONN_CXT_SIZE(p_hwfn);
 
 	qed_ilt_cli_blk_fill(p_cli, p_blk, curr_line,
@@ -604,7 +620,7 @@ int qed_cxt_cfg_ilt_compute(struct qed_hwfn *p_hwfn)
 				     ILT_CLI_CDUC);
 
 	/* CDUT PF */
-	p_cli = &p_mngr->clients[ILT_CLI_CDUT];
+	p_cli = qed_cxt_set_cli(&p_mngr->clients[ILT_CLI_CDUT]);
 	p_cli->first.val = curr_line;
 
 	/* first the 'working' task memory */
@@ -613,7 +629,7 @@ int qed_cxt_cfg_ilt_compute(struct qed_hwfn *p_hwfn)
 		if (!p_seg || p_seg->count == 0)
 			continue;
 
-		p_blk = &p_cli->pf_blks[CDUT_SEG_BLK(i)];
+		p_blk = qed_cxt_set_blk(&p_cli->pf_blks[CDUT_SEG_BLK(i)]);
 		total = p_seg->count * p_mngr->task_type_size[p_seg->type];
 		qed_ilt_cli_blk_fill(p_cli, p_blk, curr_line, total,
 				     p_mngr->task_type_size[p_seg->type]);
@@ -628,7 +644,8 @@ int qed_cxt_cfg_ilt_compute(struct qed_hwfn *p_hwfn)
 		if (!p_seg || p_seg->count == 0)
 			continue;
 
-		p_blk = &p_cli->pf_blks[CDUT_FL_SEG_BLK(i, PF)];
+		p_blk =
+		    qed_cxt_set_blk(&p_cli->pf_blks[CDUT_FL_SEG_BLK(i, PF)]);
 
 		if (!p_seg->has_fl_mem) {
 			/* The segment is active (total size pf 'working'
@@ -673,7 +690,7 @@ int qed_cxt_cfg_ilt_compute(struct qed_hwfn *p_hwfn)
 		/* 'working' memory */
 		total = p_seg->count * p_mngr->task_type_size[p_seg->type];
 
-		p_blk = &p_cli->vf_blks[CDUT_SEG_BLK(0)];
+		p_blk = qed_cxt_set_blk(&p_cli->vf_blks[CDUT_SEG_BLK(0)]);
 		qed_ilt_cli_blk_fill(p_cli, p_blk,
 				     curr_line, total,
 				     p_mngr->task_type_size[p_seg->type]);
@@ -682,7 +699,8 @@ int qed_cxt_cfg_ilt_compute(struct qed_hwfn *p_hwfn)
 				     ILT_CLI_CDUT);
 
 		/* 'init' memory */
-		p_blk = &p_cli->vf_blks[CDUT_FL_SEG_BLK(0, VF)];
+		p_blk =
+		    qed_cxt_set_blk(&p_cli->vf_blks[CDUT_FL_SEG_BLK(0, VF)]);
 		if (!p_seg->has_fl_mem) {
 			/* see comment above */
 			line = p_cli->vf_blks[CDUT_SEG_BLK(0)].start_line;
@@ -710,8 +728,8 @@ int qed_cxt_cfg_ilt_compute(struct qed_hwfn *p_hwfn)
 	}
 
 	/* QM */
-	p_cli = &p_mngr->clients[ILT_CLI_QM];
-	p_blk = &p_cli->pf_blks[0];
+	p_cli = qed_cxt_set_cli(&p_mngr->clients[ILT_CLI_QM]);
+	p_blk = qed_cxt_set_blk(&p_cli->pf_blks[0]);
 
 	qed_cxt_qm_iids(p_hwfn, &qm_iids);
 	total = qed_qm_pf_mem_size(p_hwfn->rel_pf_id, qm_iids.cids,
@@ -735,7 +753,7 @@ int qed_cxt_cfg_ilt_compute(struct qed_hwfn *p_hwfn)
 	p_cli->pf_total_lines = curr_line - p_blk->start_line;
 
 	/* SRC */
-	p_cli = &p_mngr->clients[ILT_CLI_SRC];
+	p_cli = qed_cxt_set_cli(&p_mngr->clients[ILT_CLI_SRC]);
 	qed_cxt_src_iids(p_mngr, &src_iids);
 
 	/* Both the PF and VFs searcher connections are stored in the per PF
@@ -749,7 +767,7 @@ int qed_cxt_cfg_ilt_compute(struct qed_hwfn *p_hwfn)
 
 		total = roundup_pow_of_two(local_max);
 
-		p_blk = &p_cli->pf_blks[0];
+		p_blk = qed_cxt_set_blk(&p_cli->pf_blks[0]);
 		qed_ilt_cli_blk_fill(p_cli, p_blk, curr_line,
 				     total * sizeof(struct src_ent),
 				     sizeof(struct src_ent));
@@ -760,11 +778,11 @@ int qed_cxt_cfg_ilt_compute(struct qed_hwfn *p_hwfn)
 	}
 
 	/* TM PF */
-	p_cli = &p_mngr->clients[ILT_CLI_TM];
+	p_cli = qed_cxt_set_cli(&p_mngr->clients[ILT_CLI_TM]);
 	qed_cxt_tm_iids(p_hwfn, p_mngr, &tm_iids);
 	total = tm_iids.pf_cids + tm_iids.pf_tids_total;
 	if (total) {
-		p_blk = &p_cli->pf_blks[0];
+		p_blk = qed_cxt_set_blk(&p_cli->pf_blks[0]);
 		qed_ilt_cli_blk_fill(p_cli, p_blk, curr_line,
 				     total * TM_ELEM_SIZE, TM_ELEM_SIZE);
 
@@ -776,7 +794,7 @@ int qed_cxt_cfg_ilt_compute(struct qed_hwfn *p_hwfn)
 	/* TM VF */
 	total = tm_iids.per_vf_cids + tm_iids.per_vf_tids;
 	if (total) {
-		p_blk = &p_cli->vf_blks[0];
+		p_blk = qed_cxt_set_blk(&p_cli->vf_blks[0]);
 		qed_ilt_cli_blk_fill(p_cli, p_blk, curr_line,
 				     total * TM_ELEM_SIZE, TM_ELEM_SIZE);
 
@@ -793,8 +811,8 @@ int qed_cxt_cfg_ilt_compute(struct qed_hwfn *p_hwfn)
 	total = qed_cxt_get_srq_count(p_hwfn);
 
 	if (total) {
-		p_cli = &p_mngr->clients[ILT_CLI_TSDM];
-		p_blk = &p_cli->pf_blks[SRQ_BLK];
+		p_cli = qed_cxt_set_cli(&p_mngr->clients[ILT_CLI_TSDM]);
+		p_blk = qed_cxt_set_blk(&p_cli->pf_blks[SRQ_BLK]);
 		qed_ilt_cli_blk_fill(p_cli, p_blk, curr_line,
 				     total * SRQ_CXT_SIZE, SRQ_CXT_SIZE);
 
@@ -803,13 +821,50 @@ int qed_cxt_cfg_ilt_compute(struct qed_hwfn *p_hwfn)
 		p_cli->pf_total_lines = curr_line - p_blk->start_line;
 	}
 
+	*line_count = curr_line - p_hwfn->p_cxt_mngr->pf_start_line;
+
 	if (curr_line - p_hwfn->p_cxt_mngr->pf_start_line >
-	    RESC_NUM(p_hwfn, QED_ILT)) {
-		DP_ERR(p_hwfn, "too many ilt lines...#lines=%d\n",
-		       curr_line - p_hwfn->p_cxt_mngr->pf_start_line);
+	    RESC_NUM(p_hwfn, QED_ILT))
 		return -EINVAL;
+
+	return 0;
+}
+
+u32 qed_cxt_cfg_ilt_compute_excess(struct qed_hwfn *p_hwfn, u32 used_lines)
+{
+	struct qed_ilt_client_cfg *p_cli;
+	u32 excess_lines, available_lines;
+	struct qed_cxt_mngr *p_mngr;
+	u32 ilt_page_size, elem_size;
+	struct qed_tid_seg *p_seg;
+	int i;
+
+	available_lines = RESC_NUM(p_hwfn, QED_ILT);
+	excess_lines = used_lines - available_lines;
+
+	if (!excess_lines)
+		return 0;
+
+	if (p_hwfn->hw_info.personality != QED_PCI_ETH_ROCE)
+		return 0;
+
+	p_mngr = p_hwfn->p_cxt_mngr;
+	p_cli = &p_mngr->clients[ILT_CLI_CDUT];
+	ilt_page_size = ILT_PAGE_IN_BYTES(p_cli->p_size.val);
+
+	for (i = 0; i < NUM_TASK_PF_SEGMENTS; i++) {
+		p_seg = qed_cxt_tid_seg_info(p_hwfn, i);
+		if (!p_seg || p_seg->count == 0)
+			continue;
+
+		elem_size = p_mngr->task_type_size[p_seg->type];
+		if (!elem_size)
+			continue;
+
+		return (ilt_page_size / elem_size) * excess_lines;
 	}
 
+	DP_NOTICE(p_hwfn, "failed computing excess ILT lines\n");
 	return 0;
 }
 
@@ -1893,13 +1948,12 @@ int qed_cxt_get_cid_info(struct qed_hwfn *p_hwfn, struct qed_cxt_info *p_info)
 }
 
 static void qed_rdma_set_pf_params(struct qed_hwfn *p_hwfn,
-				   struct qed_rdma_pf_params *p_params)
+				   struct qed_rdma_pf_params *p_params,
+				   u32 num_tasks)
 {
-	u32 num_cons, num_tasks, num_qps, num_mrs, num_srqs;
+	u32 num_cons, num_qps, num_srqs;
 	enum protocol_type proto;
 
-	num_mrs = min_t(u32, RDMA_MAX_TIDS, p_params->num_mrs);
-	num_tasks = num_mrs;	/* each mr uses a single task id */
 	num_srqs = min_t(u32, 32 * 1024, p_params->num_srqs);
 
 	switch (p_hwfn->hw_info.personality) {
@@ -1928,7 +1982,7 @@ static void qed_rdma_set_pf_params(struct qed_hwfn *p_hwfn,
 	}
 }
 
-int qed_cxt_set_pf_params(struct qed_hwfn *p_hwfn)
+int qed_cxt_set_pf_params(struct qed_hwfn *p_hwfn, u32 rdma_tasks)
 {
 	/* Set the number of required CORE connections */
 	u32 core_cids = 1; /* SPQ */
@@ -1940,9 +1994,10 @@ int qed_cxt_set_pf_params(struct qed_hwfn *p_hwfn)
 	switch (p_hwfn->hw_info.personality) {
 	case QED_PCI_ETH_ROCE:
 	{
-		qed_rdma_set_pf_params(p_hwfn,
-				       &p_hwfn->
-				       pf_params.rdma_pf_params);
+			qed_rdma_set_pf_params(p_hwfn,
+					       &p_hwfn->
+					       pf_params.rdma_pf_params,
+					       rdma_tasks);
 		/* no need for break since RoCE coexist with Ethernet */
 	}
 	case QED_PCI_ETH:
diff --git a/drivers/net/ethernet/qlogic/qed/qed_cxt.h b/drivers/net/ethernet/qlogic/qed/qed_cxt.h
index 8b01032..f34b288 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_cxt.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_cxt.h
@@ -105,19 +105,28 @@ u32 qed_cxt_get_proto_cid_count(struct qed_hwfn *p_hwfn,
  * @brief qed_cxt_set_pf_params - Set the PF params for cxt init
  *
  * @param p_hwfn
- *
+ * @param rdma_tasks - requested maximum
  * @return int
  */
-int qed_cxt_set_pf_params(struct qed_hwfn *p_hwfn);
+int qed_cxt_set_pf_params(struct qed_hwfn *p_hwfn, u32 rdma_tasks);
 
 /**
  * @brief qed_cxt_cfg_ilt_compute - compute ILT init parameters
  *
  * @param p_hwfn
+ * @param last_line
  *
  * @return int
  */
-int qed_cxt_cfg_ilt_compute(struct qed_hwfn *p_hwfn);
+int qed_cxt_cfg_ilt_compute(struct qed_hwfn *p_hwfn, u32 *last_line);
+
+/**
+ * @brief qed_cxt_cfg_ilt_compute_excess - how many lines can be decreased
+ *
+ * @param p_hwfn
+ * @param used_lines
+ */
+u32 qed_cxt_cfg_ilt_compute_excess(struct qed_hwfn *p_hwfn, u32 used_lines);
 
 /**
  * @brief qed_cxt_mngr_alloc - Allocate and init the context manager struct
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index b48c80ec4..2498785 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -848,8 +848,10 @@ int qed_resc_alloc(struct qed_dev *cdev)
 #ifdef CONFIG_QED_LL2
 	struct qed_ll2_info *p_ll2_info;
 #endif
+	u32 rdma_tasks, excess_tasks;
 	struct qed_consq *p_consq;
 	struct qed_eq *p_eq;
+	u32 line_count;
 	int i, rc = 0;
 
 	if (IS_VF(cdev))
@@ -871,7 +873,7 @@ int qed_resc_alloc(struct qed_dev *cdev)
 		/* Set the HW cid/tid numbers (in the contest manager)
 		 * Must be done prior to any further computations.
 		 */
-		rc = qed_cxt_set_pf_params(p_hwfn);
+		rc = qed_cxt_set_pf_params(p_hwfn, RDMA_MAX_TIDS);
 		if (rc)
 			goto alloc_err;
 
@@ -883,9 +885,32 @@ int qed_resc_alloc(struct qed_dev *cdev)
 		qed_init_qm_info(p_hwfn);
 
 		/* Compute the ILT client partition */
-		rc = qed_cxt_cfg_ilt_compute(p_hwfn);
-		if (rc)
-			goto alloc_err;
+		rc = qed_cxt_cfg_ilt_compute(p_hwfn, &line_count);
+		if (rc) {
+			DP_NOTICE(p_hwfn,
+				  "too many ILT lines; re-computing with less lines\n");
+			/* In case there are not enough ILT lines we reduce the
+			 * number of RDMA tasks and re-compute.
+			 */
+			excess_tasks =
+			    qed_cxt_cfg_ilt_compute_excess(p_hwfn, line_count);
+			if (!excess_tasks)
+				goto alloc_err;
+
+			rdma_tasks = RDMA_MAX_TIDS - excess_tasks;
+			rc = qed_cxt_set_pf_params(p_hwfn, rdma_tasks);
+			if (rc)
+				goto alloc_err;
+
+			rc = qed_cxt_cfg_ilt_compute(p_hwfn, &line_count);
+			if (rc) {
+				DP_ERR(p_hwfn,
+				       "failed ILT compute. Requested too many lines: %u\n",
+				       line_count);
+
+				goto alloc_err;
+			}
+		}
 
 		/* CID map / ILT shadow table / T2
 		 * The talbes sizes are determined by the computations above
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index d4edb99..634e7a2 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -877,7 +877,6 @@ static void qed_update_pf_params(struct qed_dev *cdev,
 		params->rdma_pf_params.num_qps = QED_ROCE_QPS;
 		params->rdma_pf_params.min_dpis = QED_ROCE_DPIS;
 		/* divide by 3 the MRs to avoid MF ILT overflow */
-		params->rdma_pf_params.num_mrs = RDMA_MAX_TIDS;
 		params->rdma_pf_params.gl_pi = QED_ROCE_PROTOCOL_INDEX;
 	}
 
diff --git a/include/linux/qed/qed_if.h b/include/linux/qed/qed_if.h
index 8e0065c..625f80f 100644
--- a/include/linux/qed/qed_if.h
+++ b/include/linux/qed/qed_if.h
@@ -263,7 +263,6 @@ struct qed_rdma_pf_params {
 	 * the doorbell BAR).
 	 */
 	u32 min_dpis;		/* number of requested DPIs */
-	u32 num_mrs;		/* number of requested memory regions */
 	u32 num_qps;		/* number of requested Queue Pairs */
 	u32 num_srqs;		/* number of requested SRQ */
 	u8 roce_edpm_mode;	/* see QED_ROCE_EDPM_MODE_ENABLE */
-- 
1.9.3
