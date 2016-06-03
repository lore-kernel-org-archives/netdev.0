From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 4/4] qed: Initialize hardware for new protocols
Date: Fri, 3 Jun 2016 14:35:35 +0300
Message-ID: <1464953735-2585-5-git-send-email-Yuval.Mintz@qlogic.com>
References: <1464953735-2585-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Rajesh.Borundia@qlogic.com>, <shyam.sundar@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:65527 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932249AbcFCLgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 07:36:08 -0400
In-Reply-To: <1464953735-2585-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RoCE and iSCSI would require some added/changed hw configuration in order
to properly run; The biggest single change being the requirement of
allocating and mapping host memory for several HW blocks that aren't being
used by qede [SRC, QM, TM, etc.].

In addition, whereas qede is only using context memory for HW blocks, the
new protocol would also require task memories to be added.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed.h          |    9 +
 drivers/net/ethernet/qlogic/qed/qed_cxt.c      | 1347 +++++++++++++++++++++++-
 drivers/net/ethernet/qlogic/qed/qed_cxt.h      |   24 +
 drivers/net/ethernet/qlogic/qed/qed_dev.c      |  154 ++-
 drivers/net/ethernet/qlogic/qed/qed_hw.c       |   26 +-
 drivers/net/ethernet/qlogic/qed/qed_hw.h       |   12 +-
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h |   33 +
 7 files changed, 1535 insertions(+), 70 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index 4417f12..9a63df1 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -187,6 +187,8 @@ struct qed_hw_info {
 
 #define RESC_START(_p_hwfn, resc) ((_p_hwfn)->hw_info.resc_start[resc])
 #define RESC_NUM(_p_hwfn, resc) ((_p_hwfn)->hw_info.resc_num[resc])
+#define RESC_END(_p_hwfn, resc) (RESC_START(_p_hwfn, resc) + \
+				 RESC_NUM(_p_hwfn, resc))
 #define FEAT_NUM(_p_hwfn, resc) ((_p_hwfn)->hw_info.feat_num[resc])
 
 	u8				num_tc;
@@ -259,6 +261,7 @@ struct qed_qm_info {
 	u8				pure_lb_pq;
 	u8				offload_pq;
 	u8				pure_ack_pq;
+	u8 ooo_pq;
 	u8				vf_queues_offset;
 	u16				num_pqs;
 	u16				num_vf_pqs;
@@ -271,6 +274,7 @@ struct qed_qm_info {
 	u8				pf_wfq;
 	u32				pf_rl;
 	struct qed_wfq_data		*wfq_data;
+	u8 num_pf_rls;
 };
 
 struct storm_stats {
@@ -316,6 +320,7 @@ struct qed_hwfn {
 	bool				hw_init_done;
 
 	u8				num_funcs_on_engine;
+	u8 enabled_func_idx;
 
 	/* BAR access */
 	void __iomem			*regview;
@@ -354,6 +359,9 @@ struct qed_hwfn {
 	/* Protocol related */
 	struct qed_pf_params		pf_params;
 
+	bool b_rdma_enabled_in_prs;
+	u32 rdma_prs_search_reg;
+
 	/* Array of sb_info of all status blocks */
 	struct qed_sb_info		*sbs_info[MAX_SB_PER_PF_MIMD];
 	u16				num_sbs;
@@ -559,6 +567,7 @@ static inline u8 qed_concrete_to_sw_fid(struct qed_dev *cdev,
 }
 
 #define PURE_LB_TC 8
+#define OOO_LB_TC 9
 
 int qed_configure_vport_wfq(struct qed_dev *cdev, u16 vp_id, u32 rate);
 void qed_configure_vp_wfq_on_link_change(struct qed_dev *cdev, u32 min_pf_rate);
diff --git a/drivers/net/ethernet/qlogic/qed/qed_cxt.c b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
index ac284c5..15f55c1 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_cxt.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
@@ -39,6 +39,14 @@
 #define DQ_RANGE_SHIFT		4
 #define DQ_RANGE_ALIGN		BIT(DQ_RANGE_SHIFT)
 
+/* Searcher constants */
+#define SRC_MIN_NUM_ELEMS 256
+
+/* Timers constants */
+#define TM_SHIFT        7
+#define TM_ALIGN        BIT(TM_SHIFT)
+#define TM_ELEM_SIZE    4
+
 /* ILT constants */
 #define ILT_DEFAULT_HW_P_SIZE		3
 #define ILT_PAGE_IN_BYTES(hw_p_size)	(1U << ((hw_p_size) + 12))
@@ -56,26 +64,71 @@
 union conn_context {
 	struct core_conn_context core_ctx;
 	struct eth_conn_context eth_ctx;
+	struct iscsi_conn_context iscsi_ctx;
+	struct roce_conn_context roce_ctx;
+};
+
+/* TYPE-0 task context - iSCSI */
+union type0_task_context {
+	struct iscsi_task_context iscsi_ctx;
 };
 
+/* TYPE-1 task context - ROCE */
+union type1_task_context {
+	struct rdma_task_context roce_ctx;
+};
+
+struct src_ent {
+	u8 opaque[56];
+	u64 next;
+};
+
+#define CDUT_SEG_ALIGNMET 3	/* in 4k chunks */
+#define CDUT_SEG_ALIGNMET_IN_BYTES (1 << (CDUT_SEG_ALIGNMET + 12))
+
 #define CONN_CXT_SIZE(p_hwfn) \
 	ALIGNED_TYPE_SIZE(union conn_context, p_hwfn)
 
+#define SRQ_CXT_SIZE (sizeof(struct rdma_srq_context))
+
+#define TYPE0_TASK_CXT_SIZE(p_hwfn) \
+	ALIGNED_TYPE_SIZE(union type0_task_context, p_hwfn)
+
+/* Alignment is inherent to the type1_task_context structure */
+#define TYPE1_TASK_CXT_SIZE(p_hwfn) sizeof(union type1_task_context)
+
 /* PF per protocl configuration object */
+#define TASK_SEGMENTS   (NUM_TASK_PF_SEGMENTS + NUM_TASK_VF_SEGMENTS)
+#define TASK_SEGMENT_VF (NUM_TASK_PF_SEGMENTS)
+
+struct qed_tid_seg {
+	u32 count;
+	u8 type;
+	bool has_fl_mem;
+};
+
 struct qed_conn_type_cfg {
 	u32 cid_count;
 	u32 cid_start;
 	u32 cids_per_vf;
+	struct qed_tid_seg tid_seg[TASK_SEGMENTS];
 };
 
 /* ILT Client configuration, Per connection type (protocol) resources. */
 #define ILT_CLI_PF_BLOCKS	(1 + NUM_TASK_PF_SEGMENTS * 2)
 #define ILT_CLI_VF_BLOCKS       (1 + NUM_TASK_VF_SEGMENTS * 2)
 #define CDUC_BLK		(0)
+#define SRQ_BLK                 (0)
+#define CDUT_SEG_BLK(n)         (1 + (u8)(n))
+#define CDUT_FL_SEG_BLK(n, X)   (1 + (n) + NUM_TASK_ ## X ## _SEGMENTS)
 
 enum ilt_clients {
 	ILT_CLI_CDUC,
+	ILT_CLI_CDUT,
 	ILT_CLI_QM,
+	ILT_CLI_TM,
+	ILT_CLI_SRC,
+	ILT_CLI_TSDM,
 	ILT_CLI_MAX
 };
 
@@ -88,6 +141,7 @@ struct qed_ilt_cli_blk {
 	u32 total_size; /* 0 means not active */
 	u32 real_size_in_page;
 	u32 start_line;
+	u32 dynamic_line_cnt;
 };
 
 struct qed_ilt_client_cfg {
@@ -131,18 +185,44 @@ struct qed_cxt_mngr {
 	/* computed ILT structure */
 	struct qed_ilt_client_cfg	clients[ILT_CLI_MAX];
 
+	/* Task type sizes */
+	u32 task_type_size[NUM_TASK_TYPES];
+
 	/* total number of VFs for this hwfn -
 	 * ALL VFs are symmetric in terms of HW resources
 	 */
 	u32				vf_count;
 
+	/* total number of SRQ's for this hwfn */
+	u32 srq_count;
+
 	/* Acquired CIDs */
 	struct qed_cid_acquired_map	acquired[MAX_CONN_TYPES];
 
 	/* ILT  shadow table */
 	struct qed_dma_mem		*ilt_shadow;
 	u32				pf_start_line;
+
+	/* Mutex for a dynamic ILT allocation */
+	struct mutex mutex;
+
+	/* SRC T2 */
+	struct qed_dma_mem *t2;
+	u32 t2_num_pages;
+	u64 first_free;
+	u64 last_free;
 };
+static bool src_proto(enum protocol_type type)
+{
+	return type == PROTOCOLID_ISCSI ||
+	       type == PROTOCOLID_ROCE;
+}
+
+static bool tm_cid_proto(enum protocol_type type)
+{
+	return type == PROTOCOLID_ISCSI ||
+	       type == PROTOCOLID_ROCE;
+}
 
 /* counts the iids for the CDU/CDUC ILT client configuration */
 struct qed_cdu_iids {
@@ -161,21 +241,120 @@ static void qed_cxt_cdu_iids(struct qed_cxt_mngr *p_mngr,
 	}
 }
 
+/* counts the iids for the Searcher block configuration */
+struct qed_src_iids {
+	u32 pf_cids;
+	u32 per_vf_cids;
+};
+
+static void qed_cxt_src_iids(struct qed_cxt_mngr *p_mngr,
+			     struct qed_src_iids *iids)
+{
+	u32 i;
+
+	for (i = 0; i < MAX_CONN_TYPES; i++) {
+		if (!src_proto(i))
+			continue;
+
+		iids->pf_cids += p_mngr->conn_cfg[i].cid_count;
+		iids->per_vf_cids += p_mngr->conn_cfg[i].cids_per_vf;
+	}
+}
+
+/* counts the iids for the Timers block configuration */
+struct qed_tm_iids {
+	u32 pf_cids;
+	u32 pf_tids[NUM_TASK_PF_SEGMENTS];	/* per segment */
+	u32 pf_tids_total;
+	u32 per_vf_cids;
+	u32 per_vf_tids;
+};
+
+static void qed_cxt_tm_iids(struct qed_cxt_mngr *p_mngr,
+			    struct qed_tm_iids *iids)
+{
+	u32 i, j;
+
+	for (i = 0; i < MAX_CONN_TYPES; i++) {
+		struct qed_conn_type_cfg *p_cfg = &p_mngr->conn_cfg[i];
+
+		if (tm_cid_proto(i)) {
+			iids->pf_cids += p_cfg->cid_count;
+			iids->per_vf_cids += p_cfg->cids_per_vf;
+		}
+	}
+
+	iids->pf_cids = roundup(iids->pf_cids, TM_ALIGN);
+	iids->per_vf_cids = roundup(iids->per_vf_cids, TM_ALIGN);
+	iids->per_vf_tids = roundup(iids->per_vf_tids, TM_ALIGN);
+
+	for (iids->pf_tids_total = 0, j = 0; j < NUM_TASK_PF_SEGMENTS; j++) {
+		iids->pf_tids[j] = roundup(iids->pf_tids[j], TM_ALIGN);
+		iids->pf_tids_total += iids->pf_tids[j];
+	}
+}
+
 static void qed_cxt_qm_iids(struct qed_hwfn *p_hwfn,
 			    struct qed_qm_iids *iids)
 {
 	struct qed_cxt_mngr *p_mngr = p_hwfn->p_cxt_mngr;
-	u32 vf_cids = 0, type;
+	struct qed_tid_seg *segs;
+	u32 vf_cids = 0, type, j;
+	u32 vf_tids = 0;
 
 	for (type = 0; type < MAX_CONN_TYPES; type++) {
 		iids->cids += p_mngr->conn_cfg[type].cid_count;
 		vf_cids += p_mngr->conn_cfg[type].cids_per_vf;
+
+		segs = p_mngr->conn_cfg[type].tid_seg;
+		/* for each segment there is at most one
+		 * protocol for which count is not 0.
+		 */
+		for (j = 0; j < NUM_TASK_PF_SEGMENTS; j++)
+			iids->tids += segs[j].count;
+
+		/* The last array elelment is for the VFs. As for PF
+		 * segments there can be only one protocol for
+		 * which this value is not 0.
+		 */
+		vf_tids += segs[NUM_TASK_PF_SEGMENTS].count;
 	}
 
 	iids->vf_cids += vf_cids * p_mngr->vf_count;
+	iids->tids += vf_tids * p_mngr->vf_count;
+
 	DP_VERBOSE(p_hwfn, QED_MSG_ILT,
-		   "iids: CIDS %08x vf_cids %08x\n",
-		   iids->cids, iids->vf_cids);
+		   "iids: CIDS %08x vf_cids %08x tids %08x vf_tids %08x\n",
+		   iids->cids, iids->vf_cids, iids->tids, vf_tids);
+}
+
+static struct qed_tid_seg *qed_cxt_tid_seg_info(struct qed_hwfn *p_hwfn,
+						u32 seg)
+{
+	struct qed_cxt_mngr *p_cfg = p_hwfn->p_cxt_mngr;
+	u32 i;
+
+	/* Find the protocol with tid count > 0 for this segment.
+	 * Note: there can only be one and this is already validated.
+	 */
+	for (i = 0; i < MAX_CONN_TYPES; i++)
+		if (p_cfg->conn_cfg[i].tid_seg[seg].count)
+			return &p_cfg->conn_cfg[i].tid_seg[seg];
+	return NULL;
+}
+
+void qed_cxt_set_srq_count(struct qed_hwfn *p_hwfn, u32 num_srqs)
+{
+	struct qed_cxt_mngr *p_mgr = p_hwfn->p_cxt_mngr;
+
+	p_mgr->srq_count = num_srqs;
+}
+
+u32 qed_cxt_get_srq_count(struct qed_hwfn *p_hwfn)
+{
+	struct qed_cxt_mngr *p_mgr = p_hwfn->p_cxt_mngr;
+
+	return p_mgr->srq_count;
 }
 
 /* set the iids count per protocol */
@@ -188,6 +367,14 @@ static void qed_cxt_set_proto_cid_count(struct qed_hwfn *p_hwfn,
 
 	p_conn->cid_count = roundup(cid_count, DQ_RANGE_ALIGN);
 	p_conn->cids_per_vf = roundup(vf_cid_cnt, DQ_RANGE_ALIGN);
+
+	if (type == PROTOCOLID_ROCE) {
+		u32 page_sz = p_mgr->clients[ILT_CLI_CDUC].p_size.val;
+		u32 cxt_size = CONN_CXT_SIZE(p_hwfn);
+		u32 elems_per_page = ILT_PAGE_IN_BYTES(page_sz) / cxt_size;
+
+		p_conn->cid_count = roundup(p_conn->cid_count, elems_per_page);
+	}
 }
 
 u32 qed_cxt_get_proto_cid_count(struct qed_hwfn		*p_hwfn,
@@ -200,6 +387,37 @@ u32 qed_cxt_get_proto_cid_count(struct qed_hwfn		*p_hwfn,
 	return p_hwfn->p_cxt_mngr->conn_cfg[type].cid_count;
 }
 
+u32 qed_cxt_get_proto_cid_start(struct qed_hwfn *p_hwfn,
+				enum protocol_type type)
+{
+	return p_hwfn->p_cxt_mngr->acquired[type].start_cid;
+}
+
+u32 qed_cxt_get_proto_tid_count(struct qed_hwfn *p_hwfn,
+				enum protocol_type type)
+{
+	u32 cnt = 0;
+	int i;
+
+	for (i = 0; i < TASK_SEGMENTS; i++)
+		cnt += p_hwfn->p_cxt_mngr->conn_cfg[type].tid_seg[i].count;
+
+	return cnt;
+}
+
+static void
+qed_cxt_set_proto_tid_count(struct qed_hwfn *p_hwfn,
+			    enum protocol_type proto,
+			    u8 seg, u8 seg_type, u32 count, bool has_fl)
+{
+	struct qed_cxt_mngr *p_mngr = p_hwfn->p_cxt_mngr;
+	struct qed_tid_seg *p_seg = &p_mngr->conn_cfg[proto].tid_seg[seg];
+
+	p_seg->count = count;
+	p_seg->has_fl_mem = has_fl;
+	p_seg->type = seg_type;
+}
+
 static void qed_ilt_cli_blk_fill(struct qed_ilt_client_cfg *p_cli,
 				 struct qed_ilt_cli_blk *p_blk,
 				 u32 start_line, u32 total_size,
@@ -241,17 +459,42 @@ static void qed_ilt_cli_adv_line(struct qed_hwfn *p_hwfn,
 		   p_blk->real_size_in_page, p_blk->start_line);
 }
 
+static u32 qed_ilt_get_dynamic_line_cnt(struct qed_hwfn *p_hwfn,
+					enum ilt_clients ilt_client)
+{
+	u32 cid_count = p_hwfn->p_cxt_mngr->conn_cfg[PROTOCOLID_ROCE].cid_count;
+	struct qed_ilt_client_cfg *p_cli;
+	u32 lines_to_skip = 0;
+	u32 cxts_per_p;
+
+	if (ilt_client == ILT_CLI_CDUC) {
+		p_cli = &p_hwfn->p_cxt_mngr->clients[ILT_CLI_CDUC];
+
+		cxts_per_p = ILT_PAGE_IN_BYTES(p_cli->p_size.val) /
+		    (u32) CONN_CXT_SIZE(p_hwfn);
+
+		lines_to_skip = cid_count / cxts_per_p;
+	}
+
+	return lines_to_skip;
+}
+
 int qed_cxt_cfg_ilt_compute(struct qed_hwfn *p_hwfn)
 {
 	struct qed_cxt_mngr *p_mngr = p_hwfn->p_cxt_mngr;
+	u32 curr_line, total, i, task_size, line;
 	struct qed_ilt_client_cfg *p_cli;
 	struct qed_ilt_cli_blk *p_blk;
 	struct qed_cdu_iids cdu_iids;
+	struct qed_src_iids src_iids;
 	struct qed_qm_iids qm_iids;
-	u32 curr_line, total, i;
+	struct qed_tm_iids tm_iids;
+	struct qed_tid_seg *p_seg;
 
 	memset(&qm_iids, 0, sizeof(qm_iids));
 	memset(&cdu_iids, 0, sizeof(cdu_iids));
+	memset(&src_iids, 0, sizeof(src_iids));
+	memset(&tm_iids, 0, sizeof(tm_iids));
 
 	p_mngr->pf_start_line = RESC_START(p_hwfn, QED_ILT);
 
@@ -279,6 +522,9 @@ int qed_cxt_cfg_ilt_compute(struct qed_hwfn *p_hwfn)
 	qed_ilt_cli_adv_line(p_hwfn, p_cli, p_blk, &curr_line, ILT_CLI_CDUC);
 	p_cli->pf_total_lines = curr_line - p_blk->start_line;
 
+	p_blk->dynamic_line_cnt = qed_ilt_get_dynamic_line_cnt(p_hwfn,
+							       ILT_CLI_CDUC);
+
 	/* CDUC VF */
 	p_blk = &p_cli->vf_blks[CDUC_BLK];
 	total = cdu_iids.per_vf_cids * CONN_CXT_SIZE(p_hwfn);
@@ -293,21 +539,128 @@ int qed_cxt_cfg_ilt_compute(struct qed_hwfn *p_hwfn)
 		qed_ilt_cli_adv_line(p_hwfn, p_cli, p_blk, &curr_line,
 				     ILT_CLI_CDUC);
 
+	/* CDUT PF */
+	p_cli = &p_mngr->clients[ILT_CLI_CDUT];
+	p_cli->first.val = curr_line;
+
+	/* first the 'working' task memory */
+	for (i = 0; i < NUM_TASK_PF_SEGMENTS; i++) {
+		p_seg = qed_cxt_tid_seg_info(p_hwfn, i);
+		if (!p_seg || p_seg->count == 0)
+			continue;
+
+		p_blk = &p_cli->pf_blks[CDUT_SEG_BLK(i)];
+		total = p_seg->count * p_mngr->task_type_size[p_seg->type];
+		qed_ilt_cli_blk_fill(p_cli, p_blk, curr_line, total,
+				     p_mngr->task_type_size[p_seg->type]);
+
+		qed_ilt_cli_adv_line(p_hwfn, p_cli, p_blk, &curr_line,
+				     ILT_CLI_CDUT);
+	}
+
+	/* next the 'init' task memory (forced load memory) */
+	for (i = 0; i < NUM_TASK_PF_SEGMENTS; i++) {
+		p_seg = qed_cxt_tid_seg_info(p_hwfn, i);
+		if (!p_seg || p_seg->count == 0)
+			continue;
+
+		p_blk = &p_cli->pf_blks[CDUT_FL_SEG_BLK(i, PF)];
+
+		if (!p_seg->has_fl_mem) {
+			/* The segment is active (total size pf 'working'
+			 * memory is > 0) but has no FL (forced-load, Init)
+			 * memory. Thus:
+			 *
+			 * 1.   The total-size in the corrsponding FL block of
+			 *      the ILT client is set to 0 - No ILT line are
+			 *      provisioned and no ILT memory allocated.
+			 *
+			 * 2.   The start-line of said block is set to the
+			 *      start line of the matching working memory
+			 *      block in the ILT client. This is later used to
+			 *      configure the CDU segment offset registers and
+			 *      results in an FL command for TIDs of this
+			 *      segement behaves as regular load commands
+			 *      (loading TIDs from the working memory).
+			 */
+			line = p_cli->pf_blks[CDUT_SEG_BLK(i)].start_line;
+
+			qed_ilt_cli_blk_fill(p_cli, p_blk, line, 0, 0);
+			continue;
+		}
+		total = p_seg->count * p_mngr->task_type_size[p_seg->type];
+
+		qed_ilt_cli_blk_fill(p_cli, p_blk,
+				     curr_line, total,
+				     p_mngr->task_type_size[p_seg->type]);
+
+		qed_ilt_cli_adv_line(p_hwfn, p_cli, p_blk, &curr_line,
+				     ILT_CLI_CDUT);
+	}
+	p_cli->pf_total_lines = curr_line - p_cli->pf_blks[0].start_line;
+
+	/* CDUT VF */
+	p_seg = qed_cxt_tid_seg_info(p_hwfn, TASK_SEGMENT_VF);
+	if (p_seg && p_seg->count) {
+		/* Stricly speaking we need to iterate over all VF
+		 * task segment types, but a VF has only 1 segment
+		 */
+
+		/* 'working' memory */
+		total = p_seg->count * p_mngr->task_type_size[p_seg->type];
+
+		p_blk = &p_cli->vf_blks[CDUT_SEG_BLK(0)];
+		qed_ilt_cli_blk_fill(p_cli, p_blk,
+				     curr_line, total,
+				     p_mngr->task_type_size[p_seg->type]);
+
+		qed_ilt_cli_adv_line(p_hwfn, p_cli, p_blk, &curr_line,
+				     ILT_CLI_CDUT);
+
+		/* 'init' memory */
+		p_blk = &p_cli->vf_blks[CDUT_FL_SEG_BLK(0, VF)];
+		if (!p_seg->has_fl_mem) {
+			/* see comment above */
+			line = p_cli->vf_blks[CDUT_SEG_BLK(0)].start_line;
+			qed_ilt_cli_blk_fill(p_cli, p_blk, line, 0, 0);
+		} else {
+			task_size = p_mngr->task_type_size[p_seg->type];
+			qed_ilt_cli_blk_fill(p_cli, p_blk,
+					     curr_line, total, task_size);
+			qed_ilt_cli_adv_line(p_hwfn, p_cli, p_blk, &curr_line,
+					     ILT_CLI_CDUT);
+		}
+		p_cli->vf_total_lines = curr_line -
+		    p_cli->vf_blks[0].start_line;
+
+		/* Now for the rest of the VFs */
+		for (i = 1; i < p_mngr->vf_count; i++) {
+			p_blk = &p_cli->vf_blks[CDUT_SEG_BLK(0)];
+			qed_ilt_cli_adv_line(p_hwfn, p_cli, p_blk, &curr_line,
+					     ILT_CLI_CDUT);
+
+			p_blk = &p_cli->vf_blks[CDUT_FL_SEG_BLK(0, VF)];
+			qed_ilt_cli_adv_line(p_hwfn, p_cli, p_blk, &curr_line,
+					     ILT_CLI_CDUT);
+		}
+	}
+
 	/* QM */
 	p_cli = &p_mngr->clients[ILT_CLI_QM];
 	p_blk = &p_cli->pf_blks[0];
 
 	qed_cxt_qm_iids(p_hwfn, &qm_iids);
 	total = qed_qm_pf_mem_size(p_hwfn->rel_pf_id, qm_iids.cids,
-				   qm_iids.vf_cids, 0,
+				   qm_iids.vf_cids, qm_iids.tids,
 				   p_hwfn->qm_info.num_pqs,
 				   p_hwfn->qm_info.num_vf_pqs);
 
 	DP_VERBOSE(p_hwfn,
 		   QED_MSG_ILT,
-		   "QM ILT Info, (cids=%d, vf_cids=%d, num_pqs=%d, num_vf_pqs=%d, memory_size=%d)\n",
+		   "QM ILT Info, (cids=%d, vf_cids=%d, tids=%d, num_pqs=%d, num_vf_pqs=%d, memory_size=%d)\n",
 		   qm_iids.cids,
 		   qm_iids.vf_cids,
+		   qm_iids.tids,
 		   p_hwfn->qm_info.num_pqs, p_hwfn->qm_info.num_vf_pqs, total);
 
 	qed_ilt_cli_blk_fill(p_cli, p_blk,
@@ -317,6 +670,75 @@ int qed_cxt_cfg_ilt_compute(struct qed_hwfn *p_hwfn)
 	qed_ilt_cli_adv_line(p_hwfn, p_cli, p_blk, &curr_line, ILT_CLI_QM);
 	p_cli->pf_total_lines = curr_line - p_blk->start_line;
 
+	/* SRC */
+	p_cli = &p_mngr->clients[ILT_CLI_SRC];
+	qed_cxt_src_iids(p_mngr, &src_iids);
+
+	/* Both the PF and VFs searcher connections are stored in the per PF
+	 * database. Thus sum the PF searcher cids and all the VFs searcher
+	 * cids.
+	 */
+	total = src_iids.pf_cids + src_iids.per_vf_cids * p_mngr->vf_count;
+	if (total) {
+		u32 local_max = max_t(u32, total,
+				      SRC_MIN_NUM_ELEMS);
+
+		total = roundup_pow_of_two(local_max);
+
+		p_blk = &p_cli->pf_blks[0];
+		qed_ilt_cli_blk_fill(p_cli, p_blk, curr_line,
+				     total * sizeof(struct src_ent),
+				     sizeof(struct src_ent));
+
+		qed_ilt_cli_adv_line(p_hwfn, p_cli, p_blk, &curr_line,
+				     ILT_CLI_SRC);
+		p_cli->pf_total_lines = curr_line - p_blk->start_line;
+	}
+
+	/* TM PF */
+	p_cli = &p_mngr->clients[ILT_CLI_TM];
+	qed_cxt_tm_iids(p_mngr, &tm_iids);
+	total = tm_iids.pf_cids + tm_iids.pf_tids_total;
+	if (total) {
+		p_blk = &p_cli->pf_blks[0];
+		qed_ilt_cli_blk_fill(p_cli, p_blk, curr_line,
+				     total * TM_ELEM_SIZE, TM_ELEM_SIZE);
+
+		qed_ilt_cli_adv_line(p_hwfn, p_cli, p_blk, &curr_line,
+				     ILT_CLI_TM);
+		p_cli->pf_total_lines = curr_line - p_blk->start_line;
+	}
+
+	/* TM VF */
+	total = tm_iids.per_vf_cids + tm_iids.per_vf_tids;
+	if (total) {
+		p_blk = &p_cli->vf_blks[0];
+		qed_ilt_cli_blk_fill(p_cli, p_blk, curr_line,
+				     total * TM_ELEM_SIZE, TM_ELEM_SIZE);
+
+		qed_ilt_cli_adv_line(p_hwfn, p_cli, p_blk, &curr_line,
+				     ILT_CLI_TM);
+		p_cli->pf_total_lines = curr_line - p_blk->start_line;
+
+		for (i = 1; i < p_mngr->vf_count; i++)
+			qed_ilt_cli_adv_line(p_hwfn, p_cli, p_blk, &curr_line,
+					     ILT_CLI_TM);
+	}
+
+	/* TSDM (SRQ CONTEXT) */
+	total = qed_cxt_get_srq_count(p_hwfn);
+
+	if (total) {
+		p_cli = &p_mngr->clients[ILT_CLI_TSDM];
+		p_blk = &p_cli->pf_blks[SRQ_BLK];
+		qed_ilt_cli_blk_fill(p_cli, p_blk, curr_line,
+				     total * SRQ_CXT_SIZE, SRQ_CXT_SIZE);
+
+		qed_ilt_cli_adv_line(p_hwfn, p_cli, p_blk, &curr_line,
+				     ILT_CLI_TSDM);
+		p_cli->pf_total_lines = curr_line - p_blk->start_line;
+	}
+
 	if (curr_line - p_hwfn->p_cxt_mngr->pf_start_line >
 	    RESC_NUM(p_hwfn, QED_ILT)) {
 		DP_ERR(p_hwfn, "too many ilt lines...#lines=%d\n",
@@ -327,8 +749,122 @@ int qed_cxt_cfg_ilt_compute(struct qed_hwfn *p_hwfn)
 	return 0;
 }
 
+static void qed_cxt_src_t2_free(struct qed_hwfn *p_hwfn)
+{
+	struct qed_cxt_mngr *p_mngr = p_hwfn->p_cxt_mngr;
+	u32 i;
+
+	if (!p_mngr->t2)
+		return;
+
+	for (i = 0; i < p_mngr->t2_num_pages; i++)
+		if (p_mngr->t2[i].p_virt)
+			dma_free_coherent(&p_hwfn->cdev->pdev->dev,
+					  p_mngr->t2[i].size,
+					  p_mngr->t2[i].p_virt,
+					  p_mngr->t2[i].p_phys);
+
+	kfree(p_mngr->t2);
+	p_mngr->t2 = NULL;
+}
+
+static int qed_cxt_src_t2_alloc(struct qed_hwfn *p_hwfn)
+{
+	struct qed_cxt_mngr *p_mngr = p_hwfn->p_cxt_mngr;
+	u32 conn_num, total_size, ent_per_page, psz, i;
+	struct qed_ilt_client_cfg *p_src;
+	struct qed_src_iids src_iids;
+	struct qed_dma_mem *p_t2;
+	int rc;
+
+	memset(&src_iids, 0, sizeof(src_iids));
+
+	/* if the SRC ILT client is inactive - there are no connection
+	 * requiring the searcer, leave.
+	 */
+	p_src = &p_hwfn->p_cxt_mngr->clients[ILT_CLI_SRC];
+	if (!p_src->active)
+		return 0;
+
+	qed_cxt_src_iids(p_mngr, &src_iids);
+	conn_num = src_iids.pf_cids + src_iids.per_vf_cids * p_mngr->vf_count;
+	total_size = conn_num * sizeof(struct src_ent);
+
+	/* use the same page size as the SRC ILT client */
+	psz = ILT_PAGE_IN_BYTES(p_src->p_size.val);
+	p_mngr->t2_num_pages = DIV_ROUND_UP(total_size, psz);
+
+	/* allocate t2 */
+	p_mngr->t2 = kzalloc(p_mngr->t2_num_pages * sizeof(struct qed_dma_mem),
+			     GFP_KERNEL);
+	if (!p_mngr->t2) {
+		DP_NOTICE(p_hwfn, "Failed to allocate t2 table\n");
+		rc = -ENOMEM;
+		goto t2_fail;
+	}
+
+	/* allocate t2 pages */
+	for (i = 0; i < p_mngr->t2_num_pages; i++) {
+		u32 size = min_t(u32, total_size, psz);
+		void **p_virt = &p_mngr->t2[i].p_virt;
+
+		*p_virt = dma_alloc_coherent(&p_hwfn->cdev->pdev->dev,
+					     size,
+					     &p_mngr->t2[i].p_phys, GFP_KERNEL);
+		if (!p_mngr->t2[i].p_virt) {
+			rc = -ENOMEM;
+			goto t2_fail;
+		}
+		memset(*p_virt, 0, size);
+		p_mngr->t2[i].size = size;
+		total_size -= size;
+	}
+
+	/* Set the t2 pointers */
+
+	/* entries per page - must be a power of two */
+	ent_per_page = psz / sizeof(struct src_ent);
+
+	p_mngr->first_free = (u64) p_mngr->t2[0].p_phys;
+
+	p_t2 = &p_mngr->t2[(conn_num - 1) / ent_per_page];
+	p_mngr->last_free = (u64) p_t2->p_phys +
+	    ((conn_num - 1) & (ent_per_page - 1)) * sizeof(struct src_ent);
+
+	for (i = 0; i < p_mngr->t2_num_pages; i++) {
+		u32 ent_num = min_t(u32,
+				    ent_per_page,
+				    conn_num);
+		struct src_ent *entries = p_mngr->t2[i].p_virt;
+		u64 p_ent_phys = (u64) p_mngr->t2[i].p_phys, val;
+		u32 j;
+
+		for (j = 0; j < ent_num - 1; j++) {
+			val = p_ent_phys + (j + 1) * sizeof(struct src_ent);
+			entries[j].next = cpu_to_be64(val);
+		}
+
+		if (i < p_mngr->t2_num_pages - 1)
+			val = (u64) p_mngr->t2[i + 1].p_phys;
+		else
+			val = 0;
+		entries[j].next = cpu_to_be64(val);
+
+		conn_num -= ent_per_page;
+	}
+
+	return 0;
+
+t2_fail:
+	qed_cxt_src_t2_free(p_hwfn);
+	return rc;
+}
+
 #define for_each_ilt_valid_client(pos, clients)	\
-		for (pos = 0; pos < ILT_CLI_MAX; pos++)
+	for (pos = 0; pos < ILT_CLI_MAX; pos++)	\
+		if (!clients[pos].active) {	\
+			continue;		\
+		} else				\
 
 /* Total number of ILT lines used by this PF */
 static u32 qed_cxt_ilt_shadow_size(struct qed_ilt_client_cfg *ilt_clients)
@@ -336,12 +872,8 @@ static u32 qed_cxt_ilt_shadow_size(struct qed_ilt_client_cfg *ilt_clients)
 	u32 size = 0;
 	u32 i;
 
-	for_each_ilt_valid_client(i, ilt_clients) {
-		if (!ilt_clients[i].active)
-			continue;
-		size += (ilt_clients[i].last.val -
-			 ilt_clients[i].first.val + 1);
-	}
+	for_each_ilt_valid_client(i, ilt_clients)
+	    size += (ilt_clients[i].last.val - ilt_clients[i].first.val + 1);
 
 	return size;
 }
@@ -372,15 +904,22 @@ static int qed_ilt_blk_alloc(struct qed_hwfn *p_hwfn,
 			     u32 start_line_offset)
 {
 	struct qed_dma_mem *ilt_shadow = p_hwfn->p_cxt_mngr->ilt_shadow;
-	u32 lines, line, sz_left;
+	u32 lines, line, sz_left, lines_to_skip = 0;
+
+	/* Special handling for RoCE that supports dynamic allocation */
+	if ((p_hwfn->hw_info.personality == QED_PCI_ETH_ROCE) &&
+	    ((ilt_client == ILT_CLI_CDUT) || ilt_client == ILT_CLI_TSDM))
+		return 0;
+
+	lines_to_skip = p_blk->dynamic_line_cnt;
 
 	if (!p_blk->total_size)
 		return 0;
 
 	sz_left = p_blk->total_size;
-	lines = DIV_ROUND_UP(sz_left, p_blk->real_size_in_page);
+	lines = DIV_ROUND_UP(sz_left, p_blk->real_size_in_page) - lines_to_skip;
 	line = p_blk->start_line + start_line_offset -
-	       p_hwfn->p_cxt_mngr->pf_start_line;
+	    p_hwfn->p_cxt_mngr->pf_start_line + lines_to_skip;
 
 	for (; lines; lines--) {
 		dma_addr_t p_phys;
@@ -434,8 +973,6 @@ static int qed_ilt_shadow_alloc(struct qed_hwfn *p_hwfn)
 		   (u32)(size * sizeof(struct qed_dma_mem)));
 
 	for_each_ilt_valid_client(i, clients) {
-		if (!clients[i].active)
-			continue;
 		for (j = 0; j < ILT_CLI_PF_BLOCKS; j++) {
 			p_blk = &clients[i].pf_blks[j];
 			rc = qed_ilt_blk_alloc(p_hwfn, p_blk, i, 0);
@@ -514,6 +1051,7 @@ cid_map_fail:
 
 int qed_cxt_mngr_alloc(struct qed_hwfn *p_hwfn)
 {
+	struct qed_ilt_client_cfg *clients;
 	struct qed_cxt_mngr *p_mngr;
 	u32 i;
 
@@ -524,20 +1062,42 @@ int qed_cxt_mngr_alloc(struct qed_hwfn *p_hwfn)
 	}
 
 	/* Initialize ILT client registers */
-	p_mngr->clients[ILT_CLI_CDUC].first.reg = ILT_CFG_REG(CDUC, FIRST_ILT);
-	p_mngr->clients[ILT_CLI_CDUC].last.reg = ILT_CFG_REG(CDUC, LAST_ILT);
-	p_mngr->clients[ILT_CLI_CDUC].p_size.reg = ILT_CFG_REG(CDUC, P_SIZE);
-
-	p_mngr->clients[ILT_CLI_QM].first.reg = ILT_CFG_REG(QM, FIRST_ILT);
-	p_mngr->clients[ILT_CLI_QM].last.reg = ILT_CFG_REG(QM, LAST_ILT);
-	p_mngr->clients[ILT_CLI_QM].p_size.reg = ILT_CFG_REG(QM, P_SIZE);
-
+	clients = p_mngr->clients;
+	clients[ILT_CLI_CDUC].first.reg = ILT_CFG_REG(CDUC, FIRST_ILT);
+	clients[ILT_CLI_CDUC].last.reg = ILT_CFG_REG(CDUC, LAST_ILT);
+	clients[ILT_CLI_CDUC].p_size.reg = ILT_CFG_REG(CDUC, P_SIZE);
+
+	clients[ILT_CLI_QM].first.reg = ILT_CFG_REG(QM, FIRST_ILT);
+	clients[ILT_CLI_QM].last.reg = ILT_CFG_REG(QM, LAST_ILT);
+	clients[ILT_CLI_QM].p_size.reg = ILT_CFG_REG(QM, P_SIZE);
+
+	clients[ILT_CLI_TM].first.reg = ILT_CFG_REG(TM, FIRST_ILT);
+	clients[ILT_CLI_TM].last.reg = ILT_CFG_REG(TM, LAST_ILT);
+	clients[ILT_CLI_TM].p_size.reg = ILT_CFG_REG(TM, P_SIZE);
+
+	clients[ILT_CLI_SRC].first.reg = ILT_CFG_REG(SRC, FIRST_ILT);
+	clients[ILT_CLI_SRC].last.reg = ILT_CFG_REG(SRC, LAST_ILT);
+	clients[ILT_CLI_SRC].p_size.reg = ILT_CFG_REG(SRC, P_SIZE);
+
+	clients[ILT_CLI_CDUT].first.reg = ILT_CFG_REG(CDUT, FIRST_ILT);
+	clients[ILT_CLI_CDUT].last.reg = ILT_CFG_REG(CDUT, LAST_ILT);
+	clients[ILT_CLI_CDUT].p_size.reg = ILT_CFG_REG(CDUT, P_SIZE);
+
+	clients[ILT_CLI_TSDM].first.reg = ILT_CFG_REG(TSDM, FIRST_ILT);
+	clients[ILT_CLI_TSDM].last.reg = ILT_CFG_REG(TSDM, LAST_ILT);
+	clients[ILT_CLI_TSDM].p_size.reg = ILT_CFG_REG(TSDM, P_SIZE);
 	/* default ILT page size for all clients is 32K */
 	for (i = 0; i < ILT_CLI_MAX; i++)
 		p_mngr->clients[i].p_size.val = ILT_DEFAULT_HW_P_SIZE;
 
+	/* Initialize task sizes */
+	p_mngr->task_type_size[0] = TYPE0_TASK_CXT_SIZE(p_hwfn);
+	p_mngr->task_type_size[1] = TYPE1_TASK_CXT_SIZE(p_hwfn);
+
 	if (p_hwfn->cdev->p_iov_info)
 		p_mngr->vf_count = p_hwfn->cdev->p_iov_info->total_vfs;
+	/* Initialize the dynamic ILT allocation mutex */
+	mutex_init(&p_mngr->mutex);
 
 	/* Set the cxt mangr pointer priori to further allocations */
 	p_hwfn->p_cxt_mngr = p_mngr;
@@ -556,6 +1116,13 @@ int qed_cxt_tables_alloc(struct qed_hwfn *p_hwfn)
 		goto tables_alloc_fail;
 	}
 
+	/* Allocate the T2  table */
+	rc = qed_cxt_src_t2_alloc(p_hwfn);
+	if (rc) {
+		DP_NOTICE(p_hwfn, "Failed to allocate T2 memory\n");
+		goto tables_alloc_fail;
+	}
+
 	/* Allocate and initialize the acquired cids bitmaps */
 	rc = qed_cid_map_alloc(p_hwfn);
 	if (rc) {
@@ -576,6 +1143,7 @@ void qed_cxt_mngr_free(struct qed_hwfn *p_hwfn)
 		return;
 
 	qed_cid_map_free(p_hwfn);
+	qed_cxt_src_t2_free(p_hwfn);
 	qed_ilt_shadow_free(p_hwfn);
 	kfree(p_hwfn->p_cxt_mngr);
 
@@ -620,6 +1188,48 @@ void qed_cxt_mngr_setup(struct qed_hwfn *p_hwfn)
 #define CDUC_NCIB_MASK \
 	(CDU_REG_CID_ADDR_PARAMS_NCIB >> CDUC_NCIB_SHIFT)
 
+#define CDUT_TYPE0_CXT_SIZE_SHIFT \
+	CDU_REG_SEGMENT0_PARAMS_T0_TID_SIZE_SHIFT
+
+#define CDUT_TYPE0_CXT_SIZE_MASK		\
+	(CDU_REG_SEGMENT0_PARAMS_T0_TID_SIZE >>	\
+	 CDUT_TYPE0_CXT_SIZE_SHIFT)
+
+#define CDUT_TYPE0_BLOCK_WASTE_SHIFT \
+	CDU_REG_SEGMENT0_PARAMS_T0_TID_BLOCK_WASTE_SHIFT
+
+#define CDUT_TYPE0_BLOCK_WASTE_MASK		       \
+	(CDU_REG_SEGMENT0_PARAMS_T0_TID_BLOCK_WASTE >> \
+	 CDUT_TYPE0_BLOCK_WASTE_SHIFT)
+
+#define CDUT_TYPE0_NCIB_SHIFT \
+	CDU_REG_SEGMENT0_PARAMS_T0_NUM_TIDS_IN_BLOCK_SHIFT
+
+#define CDUT_TYPE0_NCIB_MASK				 \
+	(CDU_REG_SEGMENT0_PARAMS_T0_NUM_TIDS_IN_BLOCK >> \
+	 CDUT_TYPE0_NCIB_SHIFT)
+
+#define CDUT_TYPE1_CXT_SIZE_SHIFT \
+	CDU_REG_SEGMENT1_PARAMS_T1_TID_SIZE_SHIFT
+
+#define CDUT_TYPE1_CXT_SIZE_MASK		\
+	(CDU_REG_SEGMENT1_PARAMS_T1_TID_SIZE >>	\
+	 CDUT_TYPE1_CXT_SIZE_SHIFT)
+
+#define CDUT_TYPE1_BLOCK_WASTE_SHIFT \
+	CDU_REG_SEGMENT1_PARAMS_T1_TID_BLOCK_WASTE_SHIFT
+
+#define CDUT_TYPE1_BLOCK_WASTE_MASK		       \
+	(CDU_REG_SEGMENT1_PARAMS_T1_TID_BLOCK_WASTE >> \
+	 CDUT_TYPE1_BLOCK_WASTE_SHIFT)
+
+#define CDUT_TYPE1_NCIB_SHIFT \
+	CDU_REG_SEGMENT1_PARAMS_T1_NUM_TIDS_IN_BLOCK_SHIFT
+
+#define CDUT_TYPE1_NCIB_MASK				 \
+	(CDU_REG_SEGMENT1_PARAMS_T1_NUM_TIDS_IN_BLOCK >> \
+	 CDUT_TYPE1_NCIB_SHIFT)
+
 static void qed_cdu_init_common(struct qed_hwfn *p_hwfn)
 {
 	u32 page_sz, elems_per_page, block_waste, cxt_size, cdu_params = 0;
@@ -634,6 +1244,92 @@ static void qed_cdu_init_common(struct qed_hwfn *p_hwfn)
 	SET_FIELD(cdu_params, CDUC_BLOCK_WASTE, block_waste);
 	SET_FIELD(cdu_params, CDUC_NCIB, elems_per_page);
 	STORE_RT_REG(p_hwfn, CDU_REG_CID_ADDR_PARAMS_RT_OFFSET, cdu_params);
+
+	/* CDUT - type-0 tasks configuration */
+	page_sz = p_hwfn->p_cxt_mngr->clients[ILT_CLI_CDUT].p_size.val;
+	cxt_size = p_hwfn->p_cxt_mngr->task_type_size[0];
+	elems_per_page = ILT_PAGE_IN_BYTES(page_sz) / cxt_size;
+	block_waste = ILT_PAGE_IN_BYTES(page_sz) - elems_per_page * cxt_size;
+
+	/* cxt size and block-waste are multipes of 8 */
+	cdu_params = 0;
+	SET_FIELD(cdu_params, CDUT_TYPE0_CXT_SIZE, (cxt_size >> 3));
+	SET_FIELD(cdu_params, CDUT_TYPE0_BLOCK_WASTE, (block_waste >> 3));
+	SET_FIELD(cdu_params, CDUT_TYPE0_NCIB, elems_per_page);
+	STORE_RT_REG(p_hwfn, CDU_REG_SEGMENT0_PARAMS_RT_OFFSET, cdu_params);
+
+	/* CDUT - type-1 tasks configuration */
+	cxt_size = p_hwfn->p_cxt_mngr->task_type_size[1];
+	elems_per_page = ILT_PAGE_IN_BYTES(page_sz) / cxt_size;
+	block_waste = ILT_PAGE_IN_BYTES(page_sz) - elems_per_page * cxt_size;
+
+	/* cxt size and block-waste are multipes of 8 */
+	cdu_params = 0;
+	SET_FIELD(cdu_params, CDUT_TYPE1_CXT_SIZE, (cxt_size >> 3));
+	SET_FIELD(cdu_params, CDUT_TYPE1_BLOCK_WASTE, (block_waste >> 3));
+	SET_FIELD(cdu_params, CDUT_TYPE1_NCIB, elems_per_page);
+	STORE_RT_REG(p_hwfn, CDU_REG_SEGMENT1_PARAMS_RT_OFFSET, cdu_params);
+}
+
+/* CDU PF */
+#define CDU_SEG_REG_TYPE_SHIFT          CDU_SEG_TYPE_OFFSET_REG_TYPE_SHIFT
+#define CDU_SEG_REG_TYPE_MASK           0x1
+#define CDU_SEG_REG_OFFSET_SHIFT        0
+#define CDU_SEG_REG_OFFSET_MASK         CDU_SEG_TYPE_OFFSET_REG_OFFSET_MASK
+
+static void qed_cdu_init_pf(struct qed_hwfn *p_hwfn)
+{
+	struct qed_ilt_client_cfg *p_cli;
+	struct qed_tid_seg *p_seg;
+	u32 cdu_seg_params, offset;
+	int i;
+
+	static const u32 rt_type_offset_arr[] = {
+		CDU_REG_PF_SEG0_TYPE_OFFSET_RT_OFFSET,
+		CDU_REG_PF_SEG1_TYPE_OFFSET_RT_OFFSET,
+		CDU_REG_PF_SEG2_TYPE_OFFSET_RT_OFFSET,
+		CDU_REG_PF_SEG3_TYPE_OFFSET_RT_OFFSET
+	};
+
+	static const u32 rt_type_offset_fl_arr[] = {
+		CDU_REG_PF_FL_SEG0_TYPE_OFFSET_RT_OFFSET,
+		CDU_REG_PF_FL_SEG1_TYPE_OFFSET_RT_OFFSET,
+		CDU_REG_PF_FL_SEG2_TYPE_OFFSET_RT_OFFSET,
+		CDU_REG_PF_FL_SEG3_TYPE_OFFSET_RT_OFFSET
+	};
+
+	p_cli = &p_hwfn->p_cxt_mngr->clients[ILT_CLI_CDUT];
+
+	/* There are initializations only for CDUT during pf Phase */
+	for (i = 0; i < NUM_TASK_PF_SEGMENTS; i++) {
+		/* Segment 0 */
+		p_seg = qed_cxt_tid_seg_info(p_hwfn, i);
+		if (!p_seg)
+			continue;
+
+		/* Note: start_line is already adjusted for the CDU
+		 * segment register granularity, so we just need to
+		 * divide. Adjustment is implicit as we assume ILT
+		 * Page size is larger than 32K!
+		 */
+		offset = (ILT_PAGE_IN_BYTES(p_cli->p_size.val) *
+			  (p_cli->pf_blks[CDUT_SEG_BLK(i)].start_line -
+			   p_cli->first.val)) / CDUT_SEG_ALIGNMET_IN_BYTES;
+
+		cdu_seg_params = 0;
+		SET_FIELD(cdu_seg_params, CDU_SEG_REG_TYPE, p_seg->type);
+		SET_FIELD(cdu_seg_params, CDU_SEG_REG_OFFSET, offset);
+		STORE_RT_REG(p_hwfn, rt_type_offset_arr[i], cdu_seg_params);
+
+		offset = (ILT_PAGE_IN_BYTES(p_cli->p_size.val) *
+			  (p_cli->pf_blks[CDUT_FL_SEG_BLK(i, PF)].start_line -
+			   p_cli->first.val)) / CDUT_SEG_ALIGNMET_IN_BYTES;
+
+		cdu_seg_params = 0;
+		SET_FIELD(cdu_seg_params, CDU_SEG_REG_TYPE, p_seg->type);
+		SET_FIELD(cdu_seg_params, CDU_SEG_REG_OFFSET, offset);
+		STORE_RT_REG(p_hwfn, rt_type_offset_fl_arr[i], cdu_seg_params);
+	}
 }
 
 void qed_qm_init_pf(struct qed_hwfn *p_hwfn)
@@ -742,14 +1438,11 @@ static void qed_ilt_bounds_init(struct qed_hwfn *p_hwfn)
 
 	ilt_clients = p_hwfn->p_cxt_mngr->clients;
 	for_each_ilt_valid_client(i, ilt_clients) {
-		if (!ilt_clients[i].active)
-			continue;
 		STORE_RT_REG(p_hwfn,
 			     ilt_clients[i].first.reg,
 			     ilt_clients[i].first.val);
 		STORE_RT_REG(p_hwfn,
-			     ilt_clients[i].last.reg,
-			     ilt_clients[i].last.val);
+			     ilt_clients[i].last.reg, ilt_clients[i].last.val);
 		STORE_RT_REG(p_hwfn,
 			     ilt_clients[i].p_size.reg,
 			     ilt_clients[i].p_size.val);
@@ -786,6 +1479,33 @@ static void qed_ilt_vf_bounds_init(struct qed_hwfn *p_hwfn)
 			     PSWRQ2_REG_CDUC_VF_BLOCKS_RT_OFFSET,
 			     p_cli->vf_total_lines);
 	}
+
+	p_cli = &p_hwfn->p_cxt_mngr->clients[ILT_CLI_CDUT];
+	blk_factor = ilog2(ILT_PAGE_IN_BYTES(p_cli->p_size.val) >> 10);
+	if (p_cli->active) {
+		STORE_RT_REG(p_hwfn,
+			     PSWRQ2_REG_CDUT_BLOCKS_FACTOR_RT_OFFSET,
+			     blk_factor);
+		STORE_RT_REG(p_hwfn,
+			     PSWRQ2_REG_CDUT_NUMBER_OF_PF_BLOCKS_RT_OFFSET,
+			     p_cli->pf_total_lines);
+		STORE_RT_REG(p_hwfn,
+			     PSWRQ2_REG_CDUT_VF_BLOCKS_RT_OFFSET,
+			     p_cli->vf_total_lines);
+	}
+
+	p_cli = &p_hwfn->p_cxt_mngr->clients[ILT_CLI_TM];
+	blk_factor = ilog2(ILT_PAGE_IN_BYTES(p_cli->p_size.val) >> 10);
+	if (p_cli->active) {
+		STORE_RT_REG(p_hwfn,
+			     PSWRQ2_REG_TM_BLOCKS_FACTOR_RT_OFFSET, blk_factor);
+		STORE_RT_REG(p_hwfn,
+			     PSWRQ2_REG_TM_NUMBER_OF_PF_BLOCKS_RT_OFFSET,
+			     p_cli->pf_total_lines);
+		STORE_RT_REG(p_hwfn,
+			     PSWRQ2_REG_TM_VF_BLOCKS_RT_OFFSET,
+			     p_cli->vf_total_lines);
+	}
 }
 
 /* ILT (PSWRQ2) PF */
@@ -804,9 +1524,6 @@ static void qed_ilt_init_pf(struct qed_hwfn *p_hwfn)
 	clients = p_hwfn->p_cxt_mngr->clients;
 
 	for_each_ilt_valid_client(i, clients) {
-		if (!clients[i].active)
-			continue;
-
 		/** Client's 1st val and RT array are absolute, ILT shadows'
 		 *  lines are relative.
 		 */
@@ -837,6 +1554,137 @@ static void qed_ilt_init_pf(struct qed_hwfn *p_hwfn)
 	}
 }
 
+/* SRC (Searcher) PF */
+static void qed_src_init_pf(struct qed_hwfn *p_hwfn)
+{
+	struct qed_cxt_mngr *p_mngr = p_hwfn->p_cxt_mngr;
+	u32 rounded_conn_num, conn_num, conn_max;
+	struct qed_src_iids src_iids;
+
+	memset(&src_iids, 0, sizeof(src_iids));
+	qed_cxt_src_iids(p_mngr, &src_iids);
+	conn_num = src_iids.pf_cids + src_iids.per_vf_cids * p_mngr->vf_count;
+	if (!conn_num)
+		return;
+
+	conn_max = max_t(u32, conn_num, SRC_MIN_NUM_ELEMS);
+	rounded_conn_num = roundup_pow_of_two(conn_max);
+
+	STORE_RT_REG(p_hwfn, SRC_REG_COUNTFREE_RT_OFFSET, conn_num);
+	STORE_RT_REG(p_hwfn, SRC_REG_NUMBER_HASH_BITS_RT_OFFSET,
+		     ilog2(rounded_conn_num));
+
+	STORE_RT_REG_AGG(p_hwfn, SRC_REG_FIRSTFREE_RT_OFFSET,
+			 p_hwfn->p_cxt_mngr->first_free);
+	STORE_RT_REG_AGG(p_hwfn, SRC_REG_LASTFREE_RT_OFFSET,
+			 p_hwfn->p_cxt_mngr->last_free);
+}
+
+/* Timers PF */
+#define TM_CFG_NUM_IDS_SHIFT            0
+#define TM_CFG_NUM_IDS_MASK             0xFFFFULL
+#define TM_CFG_PRE_SCAN_OFFSET_SHIFT    16
+#define TM_CFG_PRE_SCAN_OFFSET_MASK     0x1FFULL
+#define TM_CFG_PARENT_PF_SHIFT          25
+#define TM_CFG_PARENT_PF_MASK           0x7ULL
+
+#define TM_CFG_CID_PRE_SCAN_ROWS_SHIFT  30
+#define TM_CFG_CID_PRE_SCAN_ROWS_MASK   0x1FFULL
+
+#define TM_CFG_TID_OFFSET_SHIFT         30
+#define TM_CFG_TID_OFFSET_MASK          0x7FFFFULL
+#define TM_CFG_TID_PRE_SCAN_ROWS_SHIFT  49
+#define TM_CFG_TID_PRE_SCAN_ROWS_MASK   0x1FFULL
+
+static void qed_tm_init_pf(struct qed_hwfn *p_hwfn)
+{
+	struct qed_cxt_mngr *p_mngr = p_hwfn->p_cxt_mngr;
+	u32 active_seg_mask = 0, tm_offset, rt_reg;
+	struct qed_tm_iids tm_iids;
+	u64 cfg_word;
+	u8 i;
+
+	memset(&tm_iids, 0, sizeof(tm_iids));
+	qed_cxt_tm_iids(p_mngr, &tm_iids);
+
+	/* @@@TBD No pre-scan for now */
+
+	/* Note: We assume consecutive VFs for a PF */
+	for (i = 0; i < p_mngr->vf_count; i++) {
+		cfg_word = 0;
+		SET_FIELD(cfg_word, TM_CFG_NUM_IDS, tm_iids.per_vf_cids);
+		SET_FIELD(cfg_word, TM_CFG_PRE_SCAN_OFFSET, 0);
+		SET_FIELD(cfg_word, TM_CFG_PARENT_PF, p_hwfn->rel_pf_id);
+		SET_FIELD(cfg_word, TM_CFG_CID_PRE_SCAN_ROWS, 0);
+		rt_reg = TM_REG_CONFIG_CONN_MEM_RT_OFFSET +
+		    (sizeof(cfg_word) / sizeof(u32)) *
+		    (p_hwfn->cdev->p_iov_info->first_vf_in_pf + i);
+		STORE_RT_REG_AGG(p_hwfn, rt_reg, cfg_word);
+	}
+
+	cfg_word = 0;
+	SET_FIELD(cfg_word, TM_CFG_NUM_IDS, tm_iids.pf_cids);
+	SET_FIELD(cfg_word, TM_CFG_PRE_SCAN_OFFSET, 0);
+	SET_FIELD(cfg_word, TM_CFG_PARENT_PF, 0);	/* n/a for PF */
+	SET_FIELD(cfg_word, TM_CFG_CID_PRE_SCAN_ROWS, 0);	/* scan all   */
+
+	rt_reg = TM_REG_CONFIG_CONN_MEM_RT_OFFSET +
+	    (sizeof(cfg_word) / sizeof(u32)) *
+	    (NUM_OF_VFS(p_hwfn->cdev) + p_hwfn->rel_pf_id);
+	STORE_RT_REG_AGG(p_hwfn, rt_reg, cfg_word);
+
+	/* enale scan */
+	STORE_RT_REG(p_hwfn, TM_REG_PF_ENABLE_CONN_RT_OFFSET,
+		     tm_iids.pf_cids ? 0x1 : 0x0);
+
+	/* @@@TBD how to enable the scan for the VFs */
+
+	tm_offset = tm_iids.per_vf_cids;
+
+	/* Note: We assume consecutive VFs for a PF */
+	for (i = 0; i < p_mngr->vf_count; i++) {
+		cfg_word = 0;
+		SET_FIELD(cfg_word, TM_CFG_NUM_IDS, tm_iids.per_vf_tids);
+		SET_FIELD(cfg_word, TM_CFG_PRE_SCAN_OFFSET, 0);
+		SET_FIELD(cfg_word, TM_CFG_PARENT_PF, p_hwfn->rel_pf_id);
+		SET_FIELD(cfg_word, TM_CFG_TID_OFFSET, tm_offset);
+		SET_FIELD(cfg_word, TM_CFG_TID_PRE_SCAN_ROWS, (u64) 0);
+
+		rt_reg = TM_REG_CONFIG_TASK_MEM_RT_OFFSET +
+		    (sizeof(cfg_word) / sizeof(u32)) *
+		    (p_hwfn->cdev->p_iov_info->first_vf_in_pf + i);
+
+		STORE_RT_REG_AGG(p_hwfn, rt_reg, cfg_word);
+	}
+
+	tm_offset = tm_iids.pf_cids;
+	for (i = 0; i < NUM_TASK_PF_SEGMENTS; i++) {
+		cfg_word = 0;
+		SET_FIELD(cfg_word, TM_CFG_NUM_IDS, tm_iids.pf_tids[i]);
+		SET_FIELD(cfg_word, TM_CFG_PRE_SCAN_OFFSET, 0);
+		SET_FIELD(cfg_word, TM_CFG_PARENT_PF, 0);
+		SET_FIELD(cfg_word, TM_CFG_TID_OFFSET, tm_offset);
+		SET_FIELD(cfg_word, TM_CFG_TID_PRE_SCAN_ROWS, (u64) 0);
+
+		rt_reg = TM_REG_CONFIG_TASK_MEM_RT_OFFSET +
+		    (sizeof(cfg_word) / sizeof(u32)) *
+		    (NUM_OF_VFS(p_hwfn->cdev) +
+		     p_hwfn->rel_pf_id * NUM_TASK_PF_SEGMENTS + i);
+
+		STORE_RT_REG_AGG(p_hwfn, rt_reg, cfg_word);
+		active_seg_mask |= (tm_iids.pf_tids[i] ? (1 << i) : 0);
+
+		tm_offset += tm_iids.pf_tids[i];
+	}
+
+	if (p_hwfn->hw_info.personality == QED_PCI_ETH_ROCE)
+		active_seg_mask = 0;
+
+	STORE_RT_REG(p_hwfn, TM_REG_PF_ENABLE_TASK_RT_OFFSET, active_seg_mask);
+
+	/* @@@TBD how to enable the scan for the VFs */
+}
+
 void qed_cxt_hw_init_common(struct qed_hwfn *p_hwfn)
 {
 	qed_cdu_init_common(p_hwfn);
@@ -847,7 +1695,10 @@ void qed_cxt_hw_init_pf(struct qed_hwfn *p_hwfn)
 	qed_qm_init_pf(p_hwfn);
 	qed_cm_init_pf(p_hwfn);
 	qed_dq_init_pf(p_hwfn);
+	qed_cdu_init_pf(p_hwfn);
 	qed_ilt_init_pf(p_hwfn);
+	qed_src_init_pf(p_hwfn);
+	qed_tm_init_pf(p_hwfn);
 }
 
 int qed_cxt_acquire_cid(struct qed_hwfn *p_hwfn,
@@ -968,17 +1819,439 @@ int qed_cxt_get_cid_info(struct qed_hwfn *p_hwfn,
 	return 0;
 }
 
-int qed_cxt_set_pf_params(struct qed_hwfn *p_hwfn)
+void qed_rdma_set_pf_params(struct qed_hwfn *p_hwfn,
+			    struct qed_rdma_pf_params *p_params)
 {
-	struct qed_eth_pf_params *p_params = &p_hwfn->pf_params.eth_pf_params;
+	u32 num_cons, num_tasks, num_qps, num_mrs, num_srqs;
+	enum protocol_type proto;
+
+	num_mrs = min_t(u32, RDMA_MAX_TIDS, p_params->num_mrs);
+	num_tasks = num_mrs;	/* each mr uses a single task id */
+	num_srqs = min_t(u32, 32 * 1024, p_params->num_srqs);
+
+	switch (p_hwfn->hw_info.personality) {
+	case QED_PCI_ETH_ROCE:
+		num_qps = min_t(u32, ROCE_MAX_QPS, p_params->num_qps);
+		num_cons = num_qps * 2;	/* each QP requires two connections */
+		proto = PROTOCOLID_ROCE;
+		break;
+	default:
+		return;
+	}
+
+	if (num_cons && num_tasks) {
+		qed_cxt_set_proto_cid_count(p_hwfn, proto, num_cons, 0);
+
+		/* Deliberatly passing ROCE for tasks id. This is because
+		 * iWARP / RoCE share the task id.
+		 */
+		qed_cxt_set_proto_tid_count(p_hwfn, PROTOCOLID_ROCE,
+					    QED_CXT_ROCE_TID_SEG, 1,
+					    num_tasks, false);
+		qed_cxt_set_srq_count(p_hwfn, num_srqs);
+	} else {
+		DP_INFO(p_hwfn->cdev,
+			"RDMA personality used without setting params!\n");
+	}
+}
 
+int qed_cxt_set_pf_params(struct qed_hwfn *p_hwfn)
+{
 	/* Set the number of required CORE connections */
 	u32 core_cids = 1; /* SPQ */
 
 	qed_cxt_set_proto_cid_count(p_hwfn, PROTOCOLID_CORE, core_cids, 0);
 
-	qed_cxt_set_proto_cid_count(p_hwfn, PROTOCOLID_ETH,
-				    p_params->num_cons, 1);
+	switch (p_hwfn->hw_info.personality) {
+	case QED_PCI_ETH_ROCE:
+	{
+		qed_rdma_set_pf_params(p_hwfn,
+				       &p_hwfn->
+				       pf_params.rdma_pf_params);
+		/* no need for break since RoCE coexist with Ethernet */
+	}
+	case QED_PCI_ETH:
+	{
+		struct qed_eth_pf_params *p_params =
+		    &p_hwfn->pf_params.eth_pf_params;
+
+		qed_cxt_set_proto_cid_count(p_hwfn, PROTOCOLID_ETH,
+					    p_params->num_cons, 1);
+		break;
+	}
+	case QED_PCI_ISCSI:
+	{
+		struct qed_iscsi_pf_params *p_params;
+
+		p_params = &p_hwfn->pf_params.iscsi_pf_params;
+
+		if (p_params->num_cons && p_params->num_tasks) {
+			qed_cxt_set_proto_cid_count(p_hwfn,
+						    PROTOCOLID_ISCSI,
+						    p_params->num_cons,
+						    0);
+
+			qed_cxt_set_proto_tid_count(p_hwfn,
+						    PROTOCOLID_ISCSI,
+						    QED_CXT_ISCSI_TID_SEG,
+						    0,
+						    p_params->num_tasks,
+						    true);
+		} else {
+			DP_INFO(p_hwfn->cdev,
+				"Iscsi personality used without setting params!\n");
+		}
+		break;
+	}
+	default:
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+int qed_cxt_get_tid_mem_info(struct qed_hwfn *p_hwfn,
+			     struct qed_tid_mem *p_info)
+{
+	struct qed_cxt_mngr *p_mngr = p_hwfn->p_cxt_mngr;
+	u32 proto, seg, total_lines, i, shadow_line;
+	struct qed_ilt_client_cfg *p_cli;
+	struct qed_ilt_cli_blk *p_fl_seg;
+	struct qed_tid_seg *p_seg_info;
+
+	/* Verify the personality */
+	switch (p_hwfn->hw_info.personality) {
+	case QED_PCI_ISCSI:
+		proto = PROTOCOLID_ISCSI;
+		seg = QED_CXT_ISCSI_TID_SEG;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	p_cli = &p_mngr->clients[ILT_CLI_CDUT];
+	if (!p_cli->active)
+		return -EINVAL;
+
+	p_seg_info = &p_mngr->conn_cfg[proto].tid_seg[seg];
+	if (!p_seg_info->has_fl_mem)
+		return -EINVAL;
+
+	p_fl_seg = &p_cli->pf_blks[CDUT_FL_SEG_BLK(seg, PF)];
+	total_lines = DIV_ROUND_UP(p_fl_seg->total_size,
+				   p_fl_seg->real_size_in_page);
+
+	for (i = 0; i < total_lines; i++) {
+		shadow_line = i + p_fl_seg->start_line -
+		    p_hwfn->p_cxt_mngr->pf_start_line;
+		p_info->blocks[i] = p_mngr->ilt_shadow[shadow_line].p_virt;
+	}
+	p_info->waste = ILT_PAGE_IN_BYTES(p_cli->p_size.val) -
+	    p_fl_seg->real_size_in_page;
+	p_info->tid_size = p_mngr->task_type_size[p_seg_info->type];
+	p_info->num_tids_per_block = p_fl_seg->real_size_in_page /
+	    p_info->tid_size;
+
+	return 0;
+}
+
+/* This function is very RoCE oriented, if another protocol in the future
+ * will want this feature we'll need to modify the function to be more generic
+ */
+int
+qed_cxt_dynamic_ilt_alloc(struct qed_hwfn *p_hwfn,
+			  enum qed_cxt_elem_type elem_type, u32 iid)
+{
+	u32 reg_offset, shadow_line, elem_size, hw_p_size, elems_per_p, line;
+	struct qed_ilt_client_cfg *p_cli;
+	struct qed_ilt_cli_blk *p_blk;
+	struct qed_ptt *p_ptt;
+	dma_addr_t p_phys;
+	u64 ilt_hw_entry;
+	void *p_virt;
+	int rc = 0;
+
+	switch (elem_type) {
+	case QED_ELEM_CXT:
+		p_cli = &p_hwfn->p_cxt_mngr->clients[ILT_CLI_CDUC];
+		elem_size = CONN_CXT_SIZE(p_hwfn);
+		p_blk = &p_cli->pf_blks[CDUC_BLK];
+		break;
+	case QED_ELEM_SRQ:
+		p_cli = &p_hwfn->p_cxt_mngr->clients[ILT_CLI_TSDM];
+		elem_size = SRQ_CXT_SIZE;
+		p_blk = &p_cli->pf_blks[SRQ_BLK];
+		break;
+	case QED_ELEM_TASK:
+		p_cli = &p_hwfn->p_cxt_mngr->clients[ILT_CLI_CDUT];
+		elem_size = TYPE1_TASK_CXT_SIZE(p_hwfn);
+		p_blk = &p_cli->pf_blks[CDUT_SEG_BLK(QED_CXT_ROCE_TID_SEG)];
+		break;
+	default:
+		DP_NOTICE(p_hwfn, "-EINVALID elem type = %d", elem_type);
+		return -EINVAL;
+	}
+
+	/* Calculate line in ilt */
+	hw_p_size = p_cli->p_size.val;
+	elems_per_p = ILT_PAGE_IN_BYTES(hw_p_size) / elem_size;
+	line = p_blk->start_line + (iid / elems_per_p);
+	shadow_line = line - p_hwfn->p_cxt_mngr->pf_start_line;
+
+	/* If line is already allocated, do nothing, otherwise allocate it and
+	 * write it to the PSWRQ2 registers.
+	 * This section can be run in parallel from different contexts and thus
+	 * a mutex protection is needed.
+	 */
+
+	mutex_lock(&p_hwfn->p_cxt_mngr->mutex);
+
+	if (p_hwfn->p_cxt_mngr->ilt_shadow[shadow_line].p_virt)
+		goto out0;
+
+	p_ptt = qed_ptt_acquire(p_hwfn);
+	if (!p_ptt) {
+		DP_NOTICE(p_hwfn,
+			  "QED_TIME_OUT on ptt acquire - dynamic allocation");
+		rc = -EBUSY;
+		goto out0;
+	}
+
+	p_virt = dma_alloc_coherent(&p_hwfn->cdev->pdev->dev,
+				    p_blk->real_size_in_page,
+				    &p_phys, GFP_KERNEL);
+	if (!p_virt) {
+		rc = -ENOMEM;
+		goto out1;
+	}
+	memset(p_virt, 0, p_blk->real_size_in_page);
+
+	/* configuration of refTagMask to 0xF is required for RoCE DIF MR only,
+	 * to compensate for a HW bug, but it is configured even if DIF is not
+	 * enabled. This is harmless and allows us to avoid a dedicated API. We
+	 * configure the field for all of the contexts on the newly allocated
+	 * page.
+	 */
+	if (elem_type == QED_ELEM_TASK) {
+		u32 elem_i;
+		u8 *elem_start = (u8 *)p_virt;
+		union type1_task_context *elem;
+
+		for (elem_i = 0; elem_i < elems_per_p; elem_i++) {
+			elem = (union type1_task_context *)elem_start;
+			SET_FIELD(elem->roce_ctx.tdif_context.flags1,
+				  TDIF_TASK_CONTEXT_REFTAGMASK, 0xf);
+			elem_start += TYPE1_TASK_CXT_SIZE(p_hwfn);
+		}
+	}
+
+	p_hwfn->p_cxt_mngr->ilt_shadow[shadow_line].p_virt = p_virt;
+	p_hwfn->p_cxt_mngr->ilt_shadow[shadow_line].p_phys = p_phys;
+	p_hwfn->p_cxt_mngr->ilt_shadow[shadow_line].size =
+	    p_blk->real_size_in_page;
+
+	/* compute absolute offset */
+	reg_offset = PSWRQ2_REG_ILT_MEMORY +
+	    (line * ILT_REG_SIZE_IN_BYTES * ILT_ENTRY_IN_REGS);
+
+	ilt_hw_entry = 0;
+	SET_FIELD(ilt_hw_entry, ILT_ENTRY_VALID, 1ULL);
+	SET_FIELD(ilt_hw_entry,
+		  ILT_ENTRY_PHY_ADDR,
+		  (p_hwfn->p_cxt_mngr->ilt_shadow[shadow_line].p_phys >> 12));
+
+	/* Write via DMAE since the PSWRQ2_REG_ILT_MEMORY line is a wide-bus */
+	qed_dmae_host2grc(p_hwfn, p_ptt, (u64) (uintptr_t)&ilt_hw_entry,
+			  reg_offset, sizeof(ilt_hw_entry) / sizeof(u32), 0);
+
+	if (elem_type == QED_ELEM_CXT) {
+		u32 last_cid_allocated = (1 + (iid / elems_per_p)) *
+		    elems_per_p;
+
+		/* Update the relevant register in the parser */
+		qed_wr(p_hwfn, p_ptt, PRS_REG_ROCE_DEST_QP_MAX_PF,
+		       last_cid_allocated - 1);
+
+		if (!p_hwfn->b_rdma_enabled_in_prs) {
+			/* Enable RoCE search */
+			qed_wr(p_hwfn, p_ptt, p_hwfn->rdma_prs_search_reg, 1);
+			p_hwfn->b_rdma_enabled_in_prs = true;
+		}
+	}
+
+out1:
+	qed_ptt_release(p_hwfn, p_ptt);
+out0:
+	mutex_unlock(&p_hwfn->p_cxt_mngr->mutex);
+
+	return rc;
+}
+
+/* This function is very RoCE oriented, if another protocol in the future
+ * will want this feature we'll need to modify the function to be more generic
+ */
+static int
+qed_cxt_free_ilt_range(struct qed_hwfn *p_hwfn,
+		       enum qed_cxt_elem_type elem_type,
+		       u32 start_iid, u32 count)
+{
+	u32 start_line, end_line, shadow_start_line, shadow_end_line;
+	u32 reg_offset, elem_size, hw_p_size, elems_per_p;
+	struct qed_ilt_client_cfg *p_cli;
+	struct qed_ilt_cli_blk *p_blk;
+	u32 end_iid = start_iid + count;
+	struct qed_ptt *p_ptt;
+	u64 ilt_hw_entry = 0;
+	u32 i;
+
+	switch (elem_type) {
+	case QED_ELEM_CXT:
+		p_cli = &p_hwfn->p_cxt_mngr->clients[ILT_CLI_CDUC];
+		elem_size = CONN_CXT_SIZE(p_hwfn);
+		p_blk = &p_cli->pf_blks[CDUC_BLK];
+		break;
+	case QED_ELEM_SRQ:
+		p_cli = &p_hwfn->p_cxt_mngr->clients[ILT_CLI_TSDM];
+		elem_size = SRQ_CXT_SIZE;
+		p_blk = &p_cli->pf_blks[SRQ_BLK];
+		break;
+	case QED_ELEM_TASK:
+		p_cli = &p_hwfn->p_cxt_mngr->clients[ILT_CLI_CDUT];
+		elem_size = TYPE1_TASK_CXT_SIZE(p_hwfn);
+		p_blk = &p_cli->pf_blks[CDUT_SEG_BLK(QED_CXT_ROCE_TID_SEG)];
+		break;
+	default:
+		DP_NOTICE(p_hwfn, "-EINVALID elem type = %d", elem_type);
+		return -EINVAL;
+	}
+
+	/* Calculate line in ilt */
+	hw_p_size = p_cli->p_size.val;
+	elems_per_p = ILT_PAGE_IN_BYTES(hw_p_size) / elem_size;
+	start_line = p_blk->start_line + (start_iid / elems_per_p);
+	end_line = p_blk->start_line + (end_iid / elems_per_p);
+	if (((end_iid + 1) / elems_per_p) != (end_iid / elems_per_p))
+		end_line--;
+
+	shadow_start_line = start_line - p_hwfn->p_cxt_mngr->pf_start_line;
+	shadow_end_line = end_line - p_hwfn->p_cxt_mngr->pf_start_line;
+
+	p_ptt = qed_ptt_acquire(p_hwfn);
+	if (!p_ptt) {
+		DP_NOTICE(p_hwfn,
+			  "QED_TIME_OUT on ptt acquire - dynamic allocation");
+		return -EBUSY;
+	}
+
+	for (i = shadow_start_line; i < shadow_end_line; i++) {
+		if (!p_hwfn->p_cxt_mngr->ilt_shadow[i].p_virt)
+			continue;
+
+		dma_free_coherent(&p_hwfn->cdev->pdev->dev,
+				  p_hwfn->p_cxt_mngr->ilt_shadow[i].size,
+				  p_hwfn->p_cxt_mngr->ilt_shadow[i].p_virt,
+				  p_hwfn->p_cxt_mngr->ilt_shadow[i].p_phys);
+
+		p_hwfn->p_cxt_mngr->ilt_shadow[i].p_virt = NULL;
+		p_hwfn->p_cxt_mngr->ilt_shadow[i].p_phys = 0;
+		p_hwfn->p_cxt_mngr->ilt_shadow[i].size = 0;
+
+		/* compute absolute offset */
+		reg_offset = PSWRQ2_REG_ILT_MEMORY +
+		    ((start_line++) * ILT_REG_SIZE_IN_BYTES *
+		     ILT_ENTRY_IN_REGS);
+
+		/* Write via DMAE since the PSWRQ2_REG_ILT_MEMORY line is a
+		 * wide-bus.
+		 */
+		qed_dmae_host2grc(p_hwfn, p_ptt,
+				  (u64) (uintptr_t) &ilt_hw_entry,
+				  reg_offset,
+				  sizeof(ilt_hw_entry) / sizeof(u32),
+				  0);
+	}
+
+	qed_ptt_release(p_hwfn, p_ptt);
+
+	return 0;
+}
+
+int qed_cxt_free_proto_ilt(struct qed_hwfn *p_hwfn, enum protocol_type proto)
+{
+	int rc;
+	u32 cid;
+
+	/* Free Connection CXT */
+	rc = qed_cxt_free_ilt_range(p_hwfn, QED_ELEM_CXT,
+				    qed_cxt_get_proto_cid_start(p_hwfn,
+								proto),
+				    qed_cxt_get_proto_cid_count(p_hwfn,
+								proto, &cid));
+
+	if (rc)
+		return rc;
+
+	/* Free Task CXT */
+	rc = qed_cxt_free_ilt_range(p_hwfn, QED_ELEM_TASK, 0,
+				    qed_cxt_get_proto_tid_count(p_hwfn, proto));
+	if (rc)
+		return rc;
+
+	/* Free TSDM CXT */
+	rc = qed_cxt_free_ilt_range(p_hwfn, QED_ELEM_SRQ, 0,
+				    qed_cxt_get_srq_count(p_hwfn));
+
+	return rc;
+}
+
+int qed_cxt_get_task_ctx(struct qed_hwfn *p_hwfn,
+			 u32 tid, u8 ctx_type, void **pp_task_ctx)
+{
+	struct qed_cxt_mngr *p_mngr = p_hwfn->p_cxt_mngr;
+	struct qed_ilt_client_cfg *p_cli;
+	struct qed_ilt_cli_blk *p_seg;
+	struct qed_tid_seg *p_seg_info;
+	u32 proto, seg;
+	u32 total_lines;
+	u32 tid_size, ilt_idx;
+	u32 num_tids_per_block;
+
+	/* Verify the personality */
+	switch (p_hwfn->hw_info.personality) {
+	case QED_PCI_ISCSI:
+		proto = PROTOCOLID_ISCSI;
+		seg = QED_CXT_ISCSI_TID_SEG;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	p_cli = &p_mngr->clients[ILT_CLI_CDUT];
+	if (!p_cli->active)
+		return -EINVAL;
+
+	p_seg_info = &p_mngr->conn_cfg[proto].tid_seg[seg];
+
+	if (ctx_type == QED_CTX_WORKING_MEM) {
+		p_seg = &p_cli->pf_blks[CDUT_SEG_BLK(seg)];
+	} else if (ctx_type == QED_CTX_FL_MEM) {
+		if (!p_seg_info->has_fl_mem)
+			return -EINVAL;
+		p_seg = &p_cli->pf_blks[CDUT_FL_SEG_BLK(seg, PF)];
+	} else {
+		return -EINVAL;
+	}
+	total_lines = DIV_ROUND_UP(p_seg->total_size, p_seg->real_size_in_page);
+	tid_size = p_mngr->task_type_size[p_seg_info->type];
+	num_tids_per_block = p_seg->real_size_in_page / tid_size;
+
+	if (total_lines < tid / num_tids_per_block)
+		return -EINVAL;
+
+	ilt_idx = tid / num_tids_per_block + p_seg->start_line -
+		  p_mngr->pf_start_line;
+	*pp_task_ctx = (u8 *)p_mngr->ilt_shadow[ilt_idx].p_virt +
+		       (tid % num_tids_per_block) * tid_size;
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/qlogic/qed/qed_cxt.h b/drivers/net/ethernet/qlogic/qed/qed_cxt.h
index 234c0fa..c6f6f2e 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_cxt.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_cxt.h
@@ -21,6 +21,14 @@ struct qed_cxt_info {
 	enum protocol_type	type;
 };
 
+#define MAX_TID_BLOCKS                  512
+struct qed_tid_mem {
+	u32 tid_size;
+	u32 num_tids_per_block;
+	u32 waste;
+	u8 *blocks[MAX_TID_BLOCKS];	/* 4K */
+};
+
 /**
  * @brief qed_cxt_acquire - Acquire a new cid of a specific protocol type
  *
@@ -46,8 +54,22 @@ int qed_cxt_acquire_cid(struct qed_hwfn *p_hwfn,
 int qed_cxt_get_cid_info(struct qed_hwfn *p_hwfn,
 			 struct qed_cxt_info *p_info);
 
+/**
+ * @brief qed_cxt_get_tid_mem_info
+ *
+ * @param p_hwfn
+ * @param p_info
+ *
+ * @return int
+ */
+int qed_cxt_get_tid_mem_info(struct qed_hwfn *p_hwfn,
+			     struct qed_tid_mem *p_info);
+
+#define QED_CXT_ISCSI_TID_SEG	PROTOCOLID_ISCSI
+#define QED_CXT_ROCE_TID_SEG	PROTOCOLID_ROCE
 enum qed_cxt_elem_type {
 	QED_ELEM_CXT,
+	QED_ELEM_SRQ,
 	QED_ELEM_TASK
 };
 
@@ -149,4 +171,6 @@ int qed_qm_reconf(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt);
 void qed_cxt_release_cid(struct qed_hwfn *p_hwfn,
 			 u32 cid);
 
+#define QED_CTX_WORKING_MEM 0
+#define QED_CTX_FL_MEM 1
 #endif
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 30c6d2e..e45cff4 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -161,9 +161,13 @@ static int qed_init_qm_info(struct qed_hwfn *p_hwfn, bool b_sleepable)
 	u8 num_vports, vf_offset = 0, i, vport_id, num_ports, curr_queue = 0;
 	struct qed_qm_info *qm_info = &p_hwfn->qm_info;
 	struct init_qm_port_params *p_qm_port;
+	bool init_rdma_offload_pq = false;
+	bool init_pure_ack_pq = false;
+	bool init_ooo_pq = false;
 	u16 num_pqs, multi_cos_tcs = 1;
 	u8 pf_wfq = qm_info->pf_wfq;
 	u32 pf_rl = qm_info->pf_rl;
+	u16 num_pf_rls = 0;
 	u16 num_vfs = 0;
 
 #ifdef CONFIG_QED_SRIOV
@@ -175,6 +179,25 @@ static int qed_init_qm_info(struct qed_hwfn *p_hwfn, bool b_sleepable)
 	num_pqs = multi_cos_tcs + num_vfs + 1;	/* The '1' is for pure-LB */
 	num_vports = (u8)RESC_NUM(p_hwfn, QED_VPORT);
 
+	if (p_hwfn->hw_info.personality == QED_PCI_ETH_ROCE) {
+		num_pqs++;	/* for RoCE queue */
+		init_rdma_offload_pq = true;
+		/* we subtract num_vfs because each require a rate limiter,
+		 * and one default rate limiter
+		 */
+		if (p_hwfn->pf_params.rdma_pf_params.enable_dcqcn)
+			num_pf_rls = RESC_NUM(p_hwfn, QED_RL) - num_vfs - 1;
+
+		num_pqs += num_pf_rls;
+		qm_info->num_pf_rls = (u8) num_pf_rls;
+	}
+
+	if (p_hwfn->hw_info.personality == QED_PCI_ISCSI) {
+		num_pqs += 2;	/* for iSCSI pure-ACK / OOO queue */
+		init_pure_ack_pq = true;
+		init_ooo_pq = true;
+	}
+
 	/* Sanity checking that setup requires legal number of resources */
 	if (num_pqs > RESC_NUM(p_hwfn, QED_PQ)) {
 		DP_ERR(p_hwfn,
@@ -212,12 +235,22 @@ static int qed_init_qm_info(struct qed_hwfn *p_hwfn, bool b_sleepable)
 
 	vport_id = (u8)RESC_START(p_hwfn, QED_VPORT);
 
+	/* First init rate limited queues */
+	for (curr_queue = 0; curr_queue < num_pf_rls; curr_queue++) {
+		qm_info->qm_pq_params[curr_queue].vport_id = vport_id++;
+		qm_info->qm_pq_params[curr_queue].tc_id =
+		    p_hwfn->hw_info.non_offload_tc;
+		qm_info->qm_pq_params[curr_queue].wrr_group = 1;
+		qm_info->qm_pq_params[curr_queue].rl_valid = 1;
+	}
+
 	/* First init per-TC PQs */
 	for (i = 0; i < multi_cos_tcs; i++) {
 		struct init_qm_pq_params *params =
 		    &qm_info->qm_pq_params[curr_queue++];
 
-		if (p_hwfn->hw_info.personality == QED_PCI_ETH) {
+		if (p_hwfn->hw_info.personality == QED_PCI_ETH_ROCE ||
+		    p_hwfn->hw_info.personality == QED_PCI_ETH) {
 			params->vport_id = vport_id;
 			params->tc_id = p_hwfn->hw_info.non_offload_tc;
 			params->wrr_group = 1;
@@ -237,6 +270,32 @@ static int qed_init_qm_info(struct qed_hwfn *p_hwfn, bool b_sleepable)
 	curr_queue++;
 
 	qm_info->offload_pq = 0;
+	if (init_rdma_offload_pq) {
+		qm_info->offload_pq = curr_queue;
+		qm_info->qm_pq_params[curr_queue].vport_id = vport_id;
+		qm_info->qm_pq_params[curr_queue].tc_id =
+		    p_hwfn->hw_info.offload_tc;
+		qm_info->qm_pq_params[curr_queue].wrr_group = 1;
+		curr_queue++;
+	}
+
+	if (init_pure_ack_pq) {
+		qm_info->pure_ack_pq = curr_queue;
+		qm_info->qm_pq_params[curr_queue].vport_id = vport_id;
+		qm_info->qm_pq_params[curr_queue].tc_id =
+		    p_hwfn->hw_info.offload_tc;
+		qm_info->qm_pq_params[curr_queue].wrr_group = 1;
+		curr_queue++;
+	}
+
+	if (init_ooo_pq) {
+		qm_info->ooo_pq = curr_queue;
+		qm_info->qm_pq_params[curr_queue].vport_id = vport_id;
+		qm_info->qm_pq_params[curr_queue].tc_id = DCBX_ISCSI_OOO_TC;
+		qm_info->qm_pq_params[curr_queue].wrr_group = 1;
+		curr_queue++;
+	}
+
 	/* Then init per-VF PQs */
 	vf_offset = curr_queue;
 	for (i = 0; i < num_vfs; i++) {
@@ -371,21 +430,20 @@ int qed_resc_alloc(struct qed_dev *cdev)
 		if (!p_hwfn->p_tx_cids) {
 			DP_NOTICE(p_hwfn,
 				  "Failed to allocate memory for Tx Cids\n");
-			rc = -ENOMEM;
-			goto alloc_err;
+			goto alloc_no_mem;
 		}
 
 		p_hwfn->p_rx_cids = kzalloc(rx_size, GFP_KERNEL);
 		if (!p_hwfn->p_rx_cids) {
 			DP_NOTICE(p_hwfn,
 				  "Failed to allocate memory for Rx Cids\n");
-			rc = -ENOMEM;
-			goto alloc_err;
+			goto alloc_no_mem;
 		}
 	}
 
 	for_each_hwfn(cdev, i) {
 		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
+		u32 n_eqes, num_cons;
 
 		/* First allocate the context manager structure */
 		rc = qed_cxt_mngr_alloc(p_hwfn);
@@ -434,18 +492,34 @@ int qed_resc_alloc(struct qed_dev *cdev)
 			goto alloc_err;
 
 		/* EQ */
-		p_eq = qed_eq_alloc(p_hwfn, 256);
-		if (!p_eq) {
-			rc = -ENOMEM;
+		n_eqes = qed_chain_get_capacity(&p_hwfn->p_spq->chain);
+		if (p_hwfn->hw_info.personality == QED_PCI_ETH_ROCE) {
+			num_cons = qed_cxt_get_proto_cid_count(p_hwfn,
+							       PROTOCOLID_ROCE,
+							       0) * 2;
+			n_eqes += num_cons + 2 * MAX_NUM_VFS_BB;
+		} else if (p_hwfn->hw_info.personality == QED_PCI_ISCSI) {
+			num_cons =
+			    qed_cxt_get_proto_cid_count(p_hwfn,
+							PROTOCOLID_ISCSI, 0);
+			n_eqes += 2 * num_cons;
+		}
+
+		if (n_eqes > 0xFFFF) {
+			DP_ERR(p_hwfn,
+			       "Cannot allocate 0x%x EQ elements. The maximum of a u16 chain is 0x%x\n",
+			       n_eqes, 0xFFFF);
 			goto alloc_err;
 		}
+
+		p_eq = qed_eq_alloc(p_hwfn, (u16) n_eqes);
+		if (!p_eq)
+			goto alloc_no_mem;
 		p_hwfn->p_eq = p_eq;
 
 		p_consq = qed_consq_alloc(p_hwfn);
-		if (!p_consq) {
-			rc = -ENOMEM;
-			goto alloc_err;
-		}
+		if (!p_consq)
+			goto alloc_no_mem;
 		p_hwfn->p_consq = p_consq;
 
 		/* DMA info initialization */
@@ -474,6 +548,8 @@ int qed_resc_alloc(struct qed_dev *cdev)
 
 	return 0;
 
+alloc_no_mem:
+	rc = -ENOMEM;
 alloc_err:
 	qed_resc_free(cdev);
 	return rc;
@@ -639,6 +715,7 @@ static int qed_hw_init_common(struct qed_hwfn *p_hwfn,
 	struct qed_qm_info *qm_info = &p_hwfn->qm_info;
 	struct qed_qm_common_rt_init_params params;
 	struct qed_dev *cdev = p_hwfn->cdev;
+	u16 num_pfs, pf_id;
 	u32 concrete_fid;
 	int rc = 0;
 	u8 vf_id;
@@ -687,9 +764,16 @@ static int qed_hw_init_common(struct qed_hwfn *p_hwfn,
 	qed_wr(p_hwfn, p_ptt, PSWRQ2_REG_L2P_VALIDATE_VFID, 0);
 	qed_wr(p_hwfn, p_ptt, PGLUE_B_REG_USE_CLIENTID_IN_TAG, 1);
 
-	/* Disable relaxed ordering in the PCI config space */
-	qed_wr(p_hwfn, p_ptt, 0x20b4,
-	       qed_rd(p_hwfn, p_ptt, 0x20b4) & ~0x10);
+	if (QED_IS_BB(p_hwfn->cdev)) {
+		num_pfs = NUM_OF_ENG_PFS(p_hwfn->cdev);
+		for (pf_id = 0; pf_id < num_pfs; pf_id++) {
+			qed_fid_pretend(p_hwfn, p_ptt, pf_id);
+			qed_wr(p_hwfn, p_ptt, PRS_REG_SEARCH_ROCE, 0x0);
+			qed_wr(p_hwfn, p_ptt, PRS_REG_SEARCH_TCP, 0x0);
+		}
+		/* pretend to original PF */
+		qed_fid_pretend(p_hwfn, p_ptt, p_hwfn->rel_pf_id);
+	}
 
 	for (vf_id = 0; vf_id < MAX_NUM_VFS_BB; vf_id++) {
 		concrete_fid = qed_vfid_to_concrete(p_hwfn, vf_id);
@@ -779,7 +863,8 @@ static int qed_hw_init_pf(struct qed_hwfn *p_hwfn,
 	}
 
 	/* Protocl Configuration  */
-	STORE_RT_REG(p_hwfn, PRS_REG_SEARCH_TCP_RT_OFFSET, 0);
+	STORE_RT_REG(p_hwfn, PRS_REG_SEARCH_TCP_RT_OFFSET,
+		     (p_hwfn->hw_info.personality == QED_PCI_ISCSI) ? 1 : 0);
 	STORE_RT_REG(p_hwfn, PRS_REG_SEARCH_FCOE_RT_OFFSET, 0);
 	STORE_RT_REG(p_hwfn, PRS_REG_SEARCH_ROCE_RT_OFFSET, 0);
 
@@ -1256,8 +1341,9 @@ static void qed_hw_set_feat(struct qed_hwfn *p_hwfn)
 		   num_features);
 }
 
-static void qed_hw_get_resc(struct qed_hwfn *p_hwfn)
+static int qed_hw_get_resc(struct qed_hwfn *p_hwfn)
 {
+	u8 enabled_func_idx = p_hwfn->enabled_func_idx;
 	u32 *resc_start = p_hwfn->hw_info.resc_start;
 	u8 num_funcs = p_hwfn->num_funcs_on_engine;
 	u32 *resc_num = p_hwfn->hw_info.resc_num;
@@ -1281,14 +1367,22 @@ static void qed_hw_get_resc(struct qed_hwfn *p_hwfn)
 	resc_num[QED_VPORT] = MAX_NUM_VPORTS_BB / num_funcs;
 	resc_num[QED_RSS_ENG] = ETH_RSS_ENGINE_NUM_BB / num_funcs;
 	resc_num[QED_PQ] = MAX_QM_TX_QUEUES_BB / num_funcs;
-	resc_num[QED_RL] = 8;
+	resc_num[QED_RL] = min_t(u32, 64, resc_num[QED_VPORT]);
 	resc_num[QED_MAC] = ETH_NUM_MAC_FILTERS / num_funcs;
 	resc_num[QED_VLAN] = (ETH_NUM_VLAN_FILTERS - 1 /*For vlan0*/) /
 			     num_funcs;
-	resc_num[QED_ILT] = 950;
+	resc_num[QED_ILT] = PXP_NUM_ILT_RECORDS_BB / num_funcs;
 
 	for (i = 0; i < QED_MAX_RESC; i++)
-		resc_start[i] = resc_num[i] * p_hwfn->rel_pf_id;
+		resc_start[i] = resc_num[i] * enabled_func_idx;
+
+	/* Sanity for ILT */
+	if (RESC_END(p_hwfn, QED_ILT) > PXP_NUM_ILT_RECORDS_BB) {
+		DP_NOTICE(p_hwfn, "Can't assign ILT pages [%08x,...,%08x]\n",
+			  RESC_START(p_hwfn, QED_ILT),
+			  RESC_END(p_hwfn, QED_ILT) - 1);
+		return -EINVAL;
+	}
 
 	qed_hw_set_feat(p_hwfn);
 
@@ -1318,6 +1412,8 @@ static void qed_hw_get_resc(struct qed_hwfn *p_hwfn)
 		   p_hwfn->hw_info.resc_start[QED_VLAN],
 		   p_hwfn->hw_info.resc_num[QED_ILT],
 		   p_hwfn->hw_info.resc_start[QED_ILT]);
+
+	return 0;
 }
 
 static int qed_hw_get_nvm_info(struct qed_hwfn *p_hwfn,
@@ -1484,8 +1580,8 @@ static int qed_hw_get_nvm_info(struct qed_hwfn *p_hwfn,
 
 static void qed_get_num_funcs(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 {
-	u32 reg_function_hide, tmp, eng_mask;
-	u8 num_funcs;
+	u8 num_funcs, enabled_func_idx = p_hwfn->rel_pf_id;
+	u32 reg_function_hide, tmp, eng_mask, low_pfs_mask;
 
 	num_funcs = MAX_NUM_PFS_BB;
 
@@ -1515,9 +1611,19 @@ static void qed_get_num_funcs(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 				num_funcs++;
 			tmp >>= 0x1;
 		}
+
+		/* Get the PF index within the enabled functions */
+		low_pfs_mask = (0x1 << p_hwfn->abs_pf_id) - 1;
+		tmp = reg_function_hide & eng_mask & low_pfs_mask;
+		while (tmp) {
+			if (tmp & 0x1)
+				enabled_func_idx--;
+			tmp >>= 0x1;
+		}
 	}
 
 	p_hwfn->num_funcs_on_engine = num_funcs;
+	p_hwfn->enabled_func_idx = enabled_func_idx;
 
 	DP_VERBOSE(p_hwfn,
 		   NETIF_MSG_PROBE,
@@ -1587,9 +1693,7 @@ qed_get_hw_info(struct qed_hwfn *p_hwfn,
 
 	qed_get_num_funcs(p_hwfn, p_ptt);
 
-	qed_hw_get_resc(p_hwfn);
-
-	return rc;
+	return qed_hw_get_resc(p_hwfn);
 }
 
 static int qed_get_dev_info(struct qed_dev *cdev)
diff --git a/drivers/net/ethernet/qlogic/qed/qed_hw.c b/drivers/net/ethernet/qlogic/qed/qed_hw.c
index 7363d2b..2693c30 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_hw.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_hw.c
@@ -791,16 +791,16 @@ qed_dmae_host2host(struct qed_hwfn *p_hwfn,
 }
 
 u16 qed_get_qm_pq(struct qed_hwfn *p_hwfn,
-		  enum protocol_type proto,
-		  union qed_qm_pq_params *p_params)
+		  enum protocol_type proto, union qed_qm_pq_params *p_params)
 {
 	u16 pq_id = 0;
 
-	if ((proto == PROTOCOLID_CORE || proto == PROTOCOLID_ETH) &&
-	    !p_params) {
+	if ((proto == PROTOCOLID_CORE ||
+	     proto == PROTOCOLID_ETH ||
+	     proto == PROTOCOLID_ISCSI ||
+	     proto == PROTOCOLID_ROCE) && !p_params) {
 		DP_NOTICE(p_hwfn,
-			  "Protocol %d received NULL PQ params\n",
-			  proto);
+			  "Protocol %d received NULL PQ params\n", proto);
 		return 0;
 	}
 
@@ -808,6 +808,8 @@ u16 qed_get_qm_pq(struct qed_hwfn *p_hwfn,
 	case PROTOCOLID_CORE:
 		if (p_params->core.tc == LB_TC)
 			pq_id = p_hwfn->qm_info.pure_lb_pq;
+		else if (p_params->core.tc == OOO_LB_TC)
+			pq_id = p_hwfn->qm_info.ooo_pq;
 		else
 			pq_id = p_hwfn->qm_info.offload_pq;
 		break;
@@ -817,6 +819,18 @@ u16 qed_get_qm_pq(struct qed_hwfn *p_hwfn,
 			pq_id += p_hwfn->qm_info.vf_queues_offset +
 				 p_params->eth.vf_id;
 		break;
+	case PROTOCOLID_ISCSI:
+		if (p_params->iscsi.q_idx == 1)
+			pq_id = p_hwfn->qm_info.pure_ack_pq;
+		break;
+	case PROTOCOLID_ROCE:
+		if (p_params->roce.dcqcn)
+			pq_id = p_params->roce.qpid;
+		else
+			pq_id = p_hwfn->qm_info.offload_pq;
+		if (pq_id > p_hwfn->qm_info.num_pf_rls)
+			pq_id = p_hwfn->qm_info.offload_pq;
+		break;
 	default:
 		pq_id = 0;
 	}
diff --git a/drivers/net/ethernet/qlogic/qed/qed_hw.h b/drivers/net/ethernet/qlogic/qed/qed_hw.h
index 4367363..d015570 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_hw.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_hw.h
@@ -254,6 +254,10 @@ void qed_dmae_info_free(struct qed_hwfn *p_hwfn);
 
 union qed_qm_pq_params {
 	struct {
+		u8 q_idx;
+	} iscsi;
+
+	struct {
 		u8 tc;
 	}	core;
 
@@ -262,11 +266,15 @@ union qed_qm_pq_params {
 		u8	vf_id;
 		u8	tc;
 	}	eth;
+
+	struct {
+		u8 dcqcn;
+		u8 qpid;	/* roce relative */
+	} roce;
 };
 
 u16 qed_get_qm_pq(struct qed_hwfn *p_hwfn,
-		  enum protocol_type proto,
-		  union qed_qm_pq_params *params);
+		  enum protocol_type proto, union qed_qm_pq_params *params);
 
 int qed_init_fw_data(struct qed_dev *cdev,
 		     const u8 *fw_data);
diff --git a/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h b/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
index b889585..aa08ddb 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
@@ -27,6 +27,35 @@
 #define  CDU_REG_CID_ADDR_PARAMS_NCIB			( \
 		0xff << 24)
 
+#define CDU_REG_SEGMENT0_PARAMS	\
+	0x580904UL
+#define CDU_REG_SEGMENT0_PARAMS_T0_NUM_TIDS_IN_BLOCK \
+	(0xfff << 0)
+#define CDU_REG_SEGMENT0_PARAMS_T0_NUM_TIDS_IN_BLOCK_SHIFT \
+	0
+#define CDU_REG_SEGMENT0_PARAMS_T0_TID_BLOCK_WASTE \
+	(0xff << 16)
+#define CDU_REG_SEGMENT0_PARAMS_T0_TID_BLOCK_WASTE_SHIFT \
+	16
+#define CDU_REG_SEGMENT0_PARAMS_T0_TID_SIZE \
+	(0xff << 24)
+#define CDU_REG_SEGMENT0_PARAMS_T0_TID_SIZE_SHIFT \
+	24
+#define CDU_REG_SEGMENT1_PARAMS	\
+	0x580908UL
+#define CDU_REG_SEGMENT1_PARAMS_T1_NUM_TIDS_IN_BLOCK \
+	(0xfff << 0)
+#define CDU_REG_SEGMENT1_PARAMS_T1_NUM_TIDS_IN_BLOCK_SHIFT \
+	0
+#define CDU_REG_SEGMENT1_PARAMS_T1_TID_BLOCK_WASTE \
+	(0xff << 16)
+#define CDU_REG_SEGMENT1_PARAMS_T1_TID_BLOCK_WASTE_SHIFT \
+	16
+#define CDU_REG_SEGMENT1_PARAMS_T1_TID_SIZE \
+	(0xff << 24)
+#define CDU_REG_SEGMENT1_PARAMS_T1_TID_SIZE_SHIFT \
+	24
+
 #define  XSDM_REG_OPERATION_GEN \
 	0xf80408UL
 #define  NIG_REG_RX_BRB_OUT_EN \
@@ -225,6 +254,8 @@
 	0x1f0000UL
 #define PRS_REG_MSG_INFO \
 	0x1f0a1cUL
+#define PRS_REG_ROCE_DEST_QP_MAX_PF \
+	0x1f0430UL
 #define  PSDM_REG_ENABLE_IN1 \
 	0xfa0004UL
 #define  PSEM_REG_ENABLE_IN \
@@ -233,6 +264,8 @@
 	0x280020UL
 #define  PSWRQ2_REG_CDUT_P_SIZE \
 	0x24000cUL
+#define PSWRQ2_REG_ILT_MEMORY \
+	0x260000UL
 #define  PSWHST_REG_DISCARD_INTERNAL_WRITES \
 	0x2a0040UL
 #define  PSWHST2_REG_DBGSYN_ALMOST_FULL_THR \
-- 
1.9.3
