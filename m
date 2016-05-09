From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 03/14] qed: Introduce VFs
Date: Mon, 9 May 2016 16:19:12 +0300
Message-ID: <1462799963-23547-4-git-send-email-Yuval.Mintz@qlogic.com>
References: <1462799963-23547-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:38864 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753312AbcEINUF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 09:20:05 -0400
In-Reply-To: <1462799963-23547-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds the qed VFs for the first time -
The vfs are limited functions, with a very different PCI bar structure
[when compared with PFs] to better impose the related security demands
associated with them.

This patch includes the logic neccesary to allow VFs to successfully probe
[without actually adding the ability to enable iov].
This includes diverging all the flows that would occur as part of the pci
probe of the driver, preventing VF from accessing registers/memories it
can't and instead utilize the VF->PF channel to query the PF for needed
information.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/Makefile          |   2 +-
 drivers/net/ethernet/qlogic/qed/qed.h             |   5 +
 drivers/net/ethernet/qlogic/qed/qed_cxt.c         | 186 +++++++++--
 drivers/net/ethernet/qlogic/qed/qed_cxt.h         |   3 +
 drivers/net/ethernet/qlogic/qed/qed_dev.c         | 182 +++++++++--
 drivers/net/ethernet/qlogic/qed/qed_hsi.h         |  47 ++-
 drivers/net/ethernet/qlogic/qed/qed_hw.c          |  12 +-
 drivers/net/ethernet/qlogic/qed/qed_init_ops.c    |   4 +
 drivers/net/ethernet/qlogic/qed/qed_int.c         | 101 +++++-
 drivers/net/ethernet/qlogic/qed/qed_int.h         |  16 +
 drivers/net/ethernet/qlogic/qed/qed_l2.c          |  57 +++-
 drivers/net/ethernet/qlogic/qed/qed_main.c        | 192 +++++++----
 drivers/net/ethernet/qlogic/qed/qed_mcp.c         |  83 ++++-
 drivers/net/ethernet/qlogic/qed/qed_mcp.h         |  27 +-
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h    |   6 +
 drivers/net/ethernet/qlogic/qed/qed_sp.h          |   2 +
 drivers/net/ethernet/qlogic/qed/qed_sp_commands.c |   8 +
 drivers/net/ethernet/qlogic/qed/qed_spq.c         |   3 +
 drivers/net/ethernet/qlogic/qed/qed_sriov.c       | 379 +++++++++++++++++++++-
 drivers/net/ethernet/qlogic/qed/qed_sriov.h       |  49 +++
 drivers/net/ethernet/qlogic/qed/qed_vf.c          | 357 ++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_vf.h          | 229 +++++++++++++
 drivers/net/ethernet/qlogic/qede/qede_main.c      |  13 +-
 include/linux/qed/common_hsi.h                    |  57 ++++
 include/linux/qed/qed_if.h                        |  10 +-
 25 files changed, 1842 insertions(+), 188 deletions(-)
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_vf.c

diff --git a/drivers/net/ethernet/qlogic/qed/Makefile b/drivers/net/ethernet/qlogic/qed/Makefile
index e11a809..a448745 100644
--- a/drivers/net/ethernet/qlogic/qed/Makefile
+++ b/drivers/net/ethernet/qlogic/qed/Makefile
@@ -3,4 +3,4 @@ obj-$(CONFIG_QED) := qed.o
 qed-y := qed_cxt.o qed_dev.o qed_hw.o qed_init_fw_funcs.o qed_init_ops.o \
 	 qed_int.o qed_main.o qed_mcp.o qed_sp_commands.o qed_spq.o qed_l2.o \
 	 qed_selftest.o
-qed-$(CONFIG_QED_SRIOV) += qed_sriov.o
+qed-$(CONFIG_QED_SRIOV) += qed_sriov.o qed_vf.o
diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index 01f9b6c..f9a3576 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -311,6 +311,8 @@ struct qed_hwfn {
 	bool				first_on_engine;
 	bool				hw_init_done;
 
+	u8				num_funcs_on_engine;
+
 	/* BAR access */
 	void __iomem			*regview;
 	void __iomem			*doorbells;
@@ -361,6 +363,7 @@ struct qed_hwfn {
 	/* True if the driver requests for the link */
 	bool				b_drv_link_init;
 
+	struct qed_vf_iov		*vf_iov_info;
 	struct qed_pf_iov		*pf_iov_info;
 	struct qed_mcp_info		*mcp_info;
 
@@ -497,6 +500,8 @@ struct qed_dev {
 #define IS_QED_SRIOV(cdev)              (!!(cdev)->p_iov_info)
 
 	unsigned long			tunn_mode;
+
+	bool				b_is_vf;
 	u32				drv_type;
 
 	struct qed_eth_stats		*reset_stats;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_cxt.c b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
index fc767c0..ac284c5 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_cxt.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
@@ -24,11 +24,13 @@
 #include "qed_hw.h"
 #include "qed_init_ops.h"
 #include "qed_reg_addr.h"
+#include "qed_sriov.h"
 
 /* Max number of connection types in HW (DQ/CDU etc.) */
 #define MAX_CONN_TYPES		PROTOCOLID_COMMON
 #define NUM_TASK_TYPES		2
 #define NUM_TASK_PF_SEGMENTS	4
+#define NUM_TASK_VF_SEGMENTS	1
 
 /* QM constants */
 #define QM_PQ_ELEMENT_SIZE	4 /* in bytes */
@@ -63,10 +65,12 @@ union conn_context {
 struct qed_conn_type_cfg {
 	u32 cid_count;
 	u32 cid_start;
+	u32 cids_per_vf;
 };
 
 /* ILT Client configuration, Per connection type (protocol) resources. */
 #define ILT_CLI_PF_BLOCKS	(1 + NUM_TASK_PF_SEGMENTS * 2)
+#define ILT_CLI_VF_BLOCKS       (1 + NUM_TASK_VF_SEGMENTS * 2)
 #define CDUC_BLK		(0)
 
 enum ilt_clients {
@@ -97,6 +101,10 @@ struct qed_ilt_client_cfg {
 	/* ILT client blocks for PF */
 	struct qed_ilt_cli_blk pf_blks[ILT_CLI_PF_BLOCKS];
 	u32 pf_total_lines;
+
+	/* ILT client blocks for VFs */
+	struct qed_ilt_cli_blk vf_blks[ILT_CLI_VF_BLOCKS];
+	u32 vf_total_lines;
 };
 
 /* Per Path -
@@ -123,6 +131,11 @@ struct qed_cxt_mngr {
 	/* computed ILT structure */
 	struct qed_ilt_client_cfg	clients[ILT_CLI_MAX];
 
+	/* total number of VFs for this hwfn -
+	 * ALL VFs are symmetric in terms of HW resources
+	 */
+	u32				vf_count;
+
 	/* Acquired CIDs */
 	struct qed_cid_acquired_map	acquired[MAX_CONN_TYPES];
 
@@ -131,37 +144,60 @@ struct qed_cxt_mngr {
 	u32				pf_start_line;
 };
 
-static u32 qed_cxt_cdu_iids(struct qed_cxt_mngr *p_mngr)
-{
-	u32 type, pf_cids = 0;
+/* counts the iids for the CDU/CDUC ILT client configuration */
+struct qed_cdu_iids {
+	u32 pf_cids;
+	u32 per_vf_cids;
+};
 
-	for (type = 0; type < MAX_CONN_TYPES; type++)
-		pf_cids += p_mngr->conn_cfg[type].cid_count;
+static void qed_cxt_cdu_iids(struct qed_cxt_mngr *p_mngr,
+			     struct qed_cdu_iids *iids)
+{
+	u32 type;
 
-	return pf_cids;
+	for (type = 0; type < MAX_CONN_TYPES; type++) {
+		iids->pf_cids += p_mngr->conn_cfg[type].cid_count;
+		iids->per_vf_cids += p_mngr->conn_cfg[type].cids_per_vf;
+	}
 }
 
 static void qed_cxt_qm_iids(struct qed_hwfn *p_hwfn,
 			    struct qed_qm_iids *iids)
 {
 	struct qed_cxt_mngr *p_mngr = p_hwfn->p_cxt_mngr;
-	int type;
+	u32 vf_cids = 0, type;
 
-	for (type = 0; type < MAX_CONN_TYPES; type++)
+	for (type = 0; type < MAX_CONN_TYPES; type++) {
 		iids->cids += p_mngr->conn_cfg[type].cid_count;
+		vf_cids += p_mngr->conn_cfg[type].cids_per_vf;
+	}
 
-	DP_VERBOSE(p_hwfn, QED_MSG_ILT, "iids: CIDS %08x\n", iids->cids);
+	iids->vf_cids += vf_cids * p_mngr->vf_count;
+	DP_VERBOSE(p_hwfn, QED_MSG_ILT,
+		   "iids: CIDS %08x vf_cids %08x\n",
+		   iids->cids, iids->vf_cids);
 }
 
 /* set the iids count per protocol */
 static void qed_cxt_set_proto_cid_count(struct qed_hwfn *p_hwfn,
 					enum protocol_type type,
-					u32 cid_count)
+					u32 cid_count, u32 vf_cid_cnt)
 {
 	struct qed_cxt_mngr *p_mgr = p_hwfn->p_cxt_mngr;
 	struct qed_conn_type_cfg *p_conn = &p_mgr->conn_cfg[type];
 
 	p_conn->cid_count = roundup(cid_count, DQ_RANGE_ALIGN);
+	p_conn->cids_per_vf = roundup(vf_cid_cnt, DQ_RANGE_ALIGN);
+}
+
+u32 qed_cxt_get_proto_cid_count(struct qed_hwfn		*p_hwfn,
+				enum protocol_type	type,
+				u32			*vf_cid)
+{
+	if (vf_cid)
+		*vf_cid = p_hwfn->p_cxt_mngr->conn_cfg[type].cids_per_vf;
+
+	return p_hwfn->p_cxt_mngr->conn_cfg[type].cid_count;
 }
 
 static void qed_ilt_cli_blk_fill(struct qed_ilt_client_cfg *p_cli,
@@ -210,10 +246,12 @@ int qed_cxt_cfg_ilt_compute(struct qed_hwfn *p_hwfn)
 	struct qed_cxt_mngr *p_mngr = p_hwfn->p_cxt_mngr;
 	struct qed_ilt_client_cfg *p_cli;
 	struct qed_ilt_cli_blk *p_blk;
-	u32 curr_line, total, pf_cids;
+	struct qed_cdu_iids cdu_iids;
 	struct qed_qm_iids qm_iids;
+	u32 curr_line, total, i;
 
 	memset(&qm_iids, 0, sizeof(qm_iids));
+	memset(&cdu_iids, 0, sizeof(cdu_iids));
 
 	p_mngr->pf_start_line = RESC_START(p_hwfn, QED_ILT);
 
@@ -224,14 +262,16 @@ int qed_cxt_cfg_ilt_compute(struct qed_hwfn *p_hwfn)
 	/* CDUC */
 	p_cli = &p_mngr->clients[ILT_CLI_CDUC];
 	curr_line = p_mngr->pf_start_line;
+
+	/* CDUC PF */
 	p_cli->pf_total_lines = 0;
 
 	/* get the counters for the CDUC and QM clients  */
-	pf_cids = qed_cxt_cdu_iids(p_mngr);
+	qed_cxt_cdu_iids(p_mngr, &cdu_iids);
 
 	p_blk = &p_cli->pf_blks[CDUC_BLK];
 
-	total = pf_cids * CONN_CXT_SIZE(p_hwfn);
+	total = cdu_iids.pf_cids * CONN_CXT_SIZE(p_hwfn);
 
 	qed_ilt_cli_blk_fill(p_cli, p_blk, curr_line,
 			     total, CONN_CXT_SIZE(p_hwfn));
@@ -239,17 +279,36 @@ int qed_cxt_cfg_ilt_compute(struct qed_hwfn *p_hwfn)
 	qed_ilt_cli_adv_line(p_hwfn, p_cli, p_blk, &curr_line, ILT_CLI_CDUC);
 	p_cli->pf_total_lines = curr_line - p_blk->start_line;
 
+	/* CDUC VF */
+	p_blk = &p_cli->vf_blks[CDUC_BLK];
+	total = cdu_iids.per_vf_cids * CONN_CXT_SIZE(p_hwfn);
+
+	qed_ilt_cli_blk_fill(p_cli, p_blk, curr_line,
+			     total, CONN_CXT_SIZE(p_hwfn));
+
+	qed_ilt_cli_adv_line(p_hwfn, p_cli, p_blk, &curr_line, ILT_CLI_CDUC);
+	p_cli->vf_total_lines = curr_line - p_blk->start_line;
+
+	for (i = 1; i < p_mngr->vf_count; i++)
+		qed_ilt_cli_adv_line(p_hwfn, p_cli, p_blk, &curr_line,
+				     ILT_CLI_CDUC);
+
 	/* QM */
 	p_cli = &p_mngr->clients[ILT_CLI_QM];
 	p_blk = &p_cli->pf_blks[0];
 
 	qed_cxt_qm_iids(p_hwfn, &qm_iids);
-	total = qed_qm_pf_mem_size(p_hwfn->rel_pf_id, qm_iids.cids, 0, 0,
-				   p_hwfn->qm_info.num_pqs, 0);
-
-	DP_VERBOSE(p_hwfn, QED_MSG_ILT,
-		   "QM ILT Info, (cids=%d, num_pqs=%d, memory_size=%d)\n",
-		   qm_iids.cids, p_hwfn->qm_info.num_pqs, total);
+	total = qed_qm_pf_mem_size(p_hwfn->rel_pf_id, qm_iids.cids,
+				   qm_iids.vf_cids, 0,
+				   p_hwfn->qm_info.num_pqs,
+				   p_hwfn->qm_info.num_vf_pqs);
+
+	DP_VERBOSE(p_hwfn,
+		   QED_MSG_ILT,
+		   "QM ILT Info, (cids=%d, vf_cids=%d, num_pqs=%d, num_vf_pqs=%d, memory_size=%d)\n",
+		   qm_iids.cids,
+		   qm_iids.vf_cids,
+		   p_hwfn->qm_info.num_pqs, p_hwfn->qm_info.num_vf_pqs, total);
 
 	qed_ilt_cli_blk_fill(p_cli, p_blk,
 			     curr_line, total * 0x1000,
@@ -358,7 +417,7 @@ static int qed_ilt_shadow_alloc(struct qed_hwfn *p_hwfn)
 	struct qed_cxt_mngr *p_mngr = p_hwfn->p_cxt_mngr;
 	struct qed_ilt_client_cfg *clients = p_mngr->clients;
 	struct qed_ilt_cli_blk *p_blk;
-	u32 size, i, j;
+	u32 size, i, j, k;
 	int rc;
 
 	size = qed_cxt_ilt_shadow_size(clients);
@@ -383,6 +442,16 @@ static int qed_ilt_shadow_alloc(struct qed_hwfn *p_hwfn)
 			if (rc != 0)
 				goto ilt_shadow_fail;
 		}
+		for (k = 0; k < p_mngr->vf_count; k++) {
+			for (j = 0; j < ILT_CLI_VF_BLOCKS; j++) {
+				u32 lines = clients[i].vf_total_lines * k;
+
+				p_blk = &clients[i].vf_blks[j];
+				rc = qed_ilt_blk_alloc(p_hwfn, p_blk, i, lines);
+				if (rc != 0)
+					goto ilt_shadow_fail;
+			}
+		}
 	}
 
 	return 0;
@@ -467,6 +536,9 @@ int qed_cxt_mngr_alloc(struct qed_hwfn *p_hwfn)
 	for (i = 0; i < ILT_CLI_MAX; i++)
 		p_mngr->clients[i].p_size.val = ILT_DEFAULT_HW_P_SIZE;
 
+	if (p_hwfn->cdev->p_iov_info)
+		p_mngr->vf_count = p_hwfn->cdev->p_iov_info->total_vfs;
+
 	/* Set the cxt mangr pointer priori to further allocations */
 	p_hwfn->p_cxt_mngr = p_mngr;
 
@@ -579,8 +651,10 @@ void qed_qm_init_pf(struct qed_hwfn *p_hwfn)
 	params.max_phys_tcs_per_port = qm_info->max_phys_tcs_per_port;
 	params.is_first_pf = p_hwfn->first_on_engine;
 	params.num_pf_cids = iids.cids;
+	params.num_vf_cids = iids.vf_cids;
 	params.start_pq = qm_info->start_pq;
-	params.num_pf_pqs = qm_info->num_pqs;
+	params.num_pf_pqs = qm_info->num_pqs - qm_info->num_vf_pqs;
+	params.num_vf_pqs = qm_info->num_vf_pqs;
 	params.start_vport = qm_info->start_vport;
 	params.num_vports = qm_info->num_vports;
 	params.pf_wfq = qm_info->pf_wfq;
@@ -610,26 +684,55 @@ static int qed_cm_init_pf(struct qed_hwfn *p_hwfn)
 static void qed_dq_init_pf(struct qed_hwfn *p_hwfn)
 {
 	struct qed_cxt_mngr *p_mngr = p_hwfn->p_cxt_mngr;
-	u32 dq_pf_max_cid = 0;
+	u32 dq_pf_max_cid = 0, dq_vf_max_cid = 0;
 
 	dq_pf_max_cid += (p_mngr->conn_cfg[0].cid_count >> DQ_RANGE_SHIFT);
 	STORE_RT_REG(p_hwfn, DORQ_REG_PF_MAX_ICID_0_RT_OFFSET, dq_pf_max_cid);
 
+	dq_vf_max_cid += (p_mngr->conn_cfg[0].cids_per_vf >> DQ_RANGE_SHIFT);
+	STORE_RT_REG(p_hwfn, DORQ_REG_VF_MAX_ICID_0_RT_OFFSET, dq_vf_max_cid);
+
 	dq_pf_max_cid += (p_mngr->conn_cfg[1].cid_count >> DQ_RANGE_SHIFT);
 	STORE_RT_REG(p_hwfn, DORQ_REG_PF_MAX_ICID_1_RT_OFFSET, dq_pf_max_cid);
 
+	dq_vf_max_cid += (p_mngr->conn_cfg[1].cids_per_vf >> DQ_RANGE_SHIFT);
+	STORE_RT_REG(p_hwfn, DORQ_REG_VF_MAX_ICID_1_RT_OFFSET, dq_vf_max_cid);
+
 	dq_pf_max_cid += (p_mngr->conn_cfg[2].cid_count >> DQ_RANGE_SHIFT);
 	STORE_RT_REG(p_hwfn, DORQ_REG_PF_MAX_ICID_2_RT_OFFSET, dq_pf_max_cid);
 
+	dq_vf_max_cid += (p_mngr->conn_cfg[2].cids_per_vf >> DQ_RANGE_SHIFT);
+	STORE_RT_REG(p_hwfn, DORQ_REG_VF_MAX_ICID_2_RT_OFFSET, dq_vf_max_cid);
+
 	dq_pf_max_cid += (p_mngr->conn_cfg[3].cid_count >> DQ_RANGE_SHIFT);
 	STORE_RT_REG(p_hwfn, DORQ_REG_PF_MAX_ICID_3_RT_OFFSET, dq_pf_max_cid);
 
+	dq_vf_max_cid += (p_mngr->conn_cfg[3].cids_per_vf >> DQ_RANGE_SHIFT);
+	STORE_RT_REG(p_hwfn, DORQ_REG_VF_MAX_ICID_3_RT_OFFSET, dq_vf_max_cid);
+
 	dq_pf_max_cid += (p_mngr->conn_cfg[4].cid_count >> DQ_RANGE_SHIFT);
 	STORE_RT_REG(p_hwfn, DORQ_REG_PF_MAX_ICID_4_RT_OFFSET, dq_pf_max_cid);
 
-	/* 5 - PF */
+	dq_vf_max_cid += (p_mngr->conn_cfg[4].cids_per_vf >> DQ_RANGE_SHIFT);
+	STORE_RT_REG(p_hwfn, DORQ_REG_VF_MAX_ICID_4_RT_OFFSET, dq_vf_max_cid);
+
 	dq_pf_max_cid += (p_mngr->conn_cfg[5].cid_count >> DQ_RANGE_SHIFT);
 	STORE_RT_REG(p_hwfn, DORQ_REG_PF_MAX_ICID_5_RT_OFFSET, dq_pf_max_cid);
+
+	dq_vf_max_cid += (p_mngr->conn_cfg[5].cids_per_vf >> DQ_RANGE_SHIFT);
+	STORE_RT_REG(p_hwfn, DORQ_REG_VF_MAX_ICID_5_RT_OFFSET, dq_vf_max_cid);
+
+	/* Connection types 6 & 7 are not in use, yet they must be configured
+	 * as the highest possible connection. Not configuring them means the
+	 * defaults will be  used, and with a large number of cids a bug may
+	 * occur, if the defaults will be smaller than dq_pf_max_cid /
+	 * dq_vf_max_cid.
+	 */
+	STORE_RT_REG(p_hwfn, DORQ_REG_PF_MAX_ICID_6_RT_OFFSET, dq_pf_max_cid);
+	STORE_RT_REG(p_hwfn, DORQ_REG_VF_MAX_ICID_6_RT_OFFSET, dq_vf_max_cid);
+
+	STORE_RT_REG(p_hwfn, DORQ_REG_PF_MAX_ICID_7_RT_OFFSET, dq_pf_max_cid);
+	STORE_RT_REG(p_hwfn, DORQ_REG_VF_MAX_ICID_7_RT_OFFSET, dq_vf_max_cid);
 }
 
 static void qed_ilt_bounds_init(struct qed_hwfn *p_hwfn)
@@ -653,6 +756,38 @@ static void qed_ilt_bounds_init(struct qed_hwfn *p_hwfn)
 	}
 }
 
+static void qed_ilt_vf_bounds_init(struct qed_hwfn *p_hwfn)
+{
+	struct qed_ilt_client_cfg *p_cli;
+	u32 blk_factor;
+
+	/* For simplicty  we set the 'block' to be an ILT page */
+	if (p_hwfn->cdev->p_iov_info) {
+		struct qed_hw_sriov_info *p_iov = p_hwfn->cdev->p_iov_info;
+
+		STORE_RT_REG(p_hwfn,
+			     PSWRQ2_REG_VF_BASE_RT_OFFSET,
+			     p_iov->first_vf_in_pf);
+		STORE_RT_REG(p_hwfn,
+			     PSWRQ2_REG_VF_LAST_ILT_RT_OFFSET,
+			     p_iov->first_vf_in_pf + p_iov->total_vfs);
+	}
+
+	p_cli = &p_hwfn->p_cxt_mngr->clients[ILT_CLI_CDUC];
+	blk_factor = ilog2(ILT_PAGE_IN_BYTES(p_cli->p_size.val) >> 10);
+	if (p_cli->active) {
+		STORE_RT_REG(p_hwfn,
+			     PSWRQ2_REG_CDUC_BLOCKS_FACTOR_RT_OFFSET,
+			     blk_factor);
+		STORE_RT_REG(p_hwfn,
+			     PSWRQ2_REG_CDUC_NUMBER_OF_PF_BLOCKS_RT_OFFSET,
+			     p_cli->pf_total_lines);
+		STORE_RT_REG(p_hwfn,
+			     PSWRQ2_REG_CDUC_VF_BLOCKS_RT_OFFSET,
+			     p_cli->vf_total_lines);
+	}
+}
+
 /* ILT (PSWRQ2) PF */
 static void qed_ilt_init_pf(struct qed_hwfn *p_hwfn)
 {
@@ -662,6 +797,7 @@ static void qed_ilt_init_pf(struct qed_hwfn *p_hwfn)
 	u32 line, rt_offst, i;
 
 	qed_ilt_bounds_init(p_hwfn);
+	qed_ilt_vf_bounds_init(p_hwfn);
 
 	p_mngr = p_hwfn->p_cxt_mngr;
 	p_shdw = p_mngr->ilt_shadow;
@@ -839,10 +975,10 @@ int qed_cxt_set_pf_params(struct qed_hwfn *p_hwfn)
 	/* Set the number of required CORE connections */
 	u32 core_cids = 1; /* SPQ */
 
-	qed_cxt_set_proto_cid_count(p_hwfn, PROTOCOLID_CORE, core_cids);
+	qed_cxt_set_proto_cid_count(p_hwfn, PROTOCOLID_CORE, core_cids, 0);
 
 	qed_cxt_set_proto_cid_count(p_hwfn, PROTOCOLID_ETH,
-				    p_params->num_cons);
+				    p_params->num_cons, 1);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/qlogic/qed/qed_cxt.h b/drivers/net/ethernet/qlogic/qed/qed_cxt.h
index c8e1f5e..078ff3f 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_cxt.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_cxt.h
@@ -51,6 +51,9 @@ enum qed_cxt_elem_type {
 	QED_ELEM_TASK
 };
 
+u32 qed_cxt_get_proto_cid_count(struct qed_hwfn *p_hwfn,
+				enum protocol_type type, u32 *vf_cid);
+
 /**
  * @brief qed_cxt_set_pf_params - Set the PF params for cxt init
  *
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 7a359c4..362e8db 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -41,10 +41,14 @@ enum BAR_ID {
 static u32 qed_hw_bar_size(struct qed_hwfn	*p_hwfn,
 			   enum BAR_ID		bar_id)
 {
-	u32	bar_reg = (bar_id == BAR_ID_0 ?
-			   PGLUE_B_REG_PF_BAR0_SIZE : PGLUE_B_REG_PF_BAR1_SIZE);
-	u32	val = qed_rd(p_hwfn, p_hwfn->p_main_ptt, bar_reg);
+	u32 bar_reg = (bar_id == BAR_ID_0 ?
+		       PGLUE_B_REG_PF_BAR0_SIZE : PGLUE_B_REG_PF_BAR1_SIZE);
+	u32 val;
 
+	if (IS_VF(p_hwfn->cdev))
+		return 1 << 17;
+
+	val = qed_rd(p_hwfn, p_hwfn->p_main_ptt, bar_reg);
 	if (val)
 		return 1 << (val + 15);
 
@@ -114,6 +118,9 @@ void qed_resc_free(struct qed_dev *cdev)
 {
 	int i;
 
+	if (IS_VF(cdev))
+		return;
+
 	kfree(cdev->fw_data);
 	cdev->fw_data = NULL;
 
@@ -144,14 +151,19 @@ void qed_resc_free(struct qed_dev *cdev)
 
 static int qed_init_qm_info(struct qed_hwfn *p_hwfn)
 {
+	u8 num_vports, vf_offset = 0, i, vport_id, num_ports, curr_queue = 0;
 	struct qed_qm_info *qm_info = &p_hwfn->qm_info;
 	struct init_qm_port_params *p_qm_port;
-	u8 num_vports, i, vport_id, num_ports;
 	u16 num_pqs, multi_cos_tcs = 1;
+	u16 num_vfs = 0;
 
+#ifdef CONFIG_QED_SRIOV
+	if (p_hwfn->cdev->p_iov_info)
+		num_vfs = p_hwfn->cdev->p_iov_info->total_vfs;
+#endif
 	memset(qm_info, 0, sizeof(*qm_info));
 
-	num_pqs = multi_cos_tcs + 1; /* The '1' is for pure-LB */
+	num_pqs = multi_cos_tcs + num_vfs + 1;	/* The '1' is for pure-LB */
 	num_vports = (u8)RESC_NUM(p_hwfn, QED_VPORT);
 
 	/* Sanity checking that setup requires legal number of resources */
@@ -187,8 +199,9 @@ static int qed_init_qm_info(struct qed_hwfn *p_hwfn)
 	vport_id = (u8)RESC_START(p_hwfn, QED_VPORT);
 
 	/* First init per-TC PQs */
-	for (i = 0; i < multi_cos_tcs; i++) {
-		struct init_qm_pq_params *params = &qm_info->qm_pq_params[i];
+	for (i = 0; i < multi_cos_tcs; i++, curr_queue++) {
+		struct init_qm_pq_params *params =
+		    &qm_info->qm_pq_params[curr_queue];
 
 		params->vport_id = vport_id;
 		params->tc_id = p_hwfn->hw_info.non_offload_tc;
@@ -196,13 +209,26 @@ static int qed_init_qm_info(struct qed_hwfn *p_hwfn)
 	}
 
 	/* Then init pure-LB PQ */
-	qm_info->pure_lb_pq = i;
-	qm_info->qm_pq_params[i].vport_id = (u8)RESC_START(p_hwfn, QED_VPORT);
-	qm_info->qm_pq_params[i].tc_id = PURE_LB_TC;
-	qm_info->qm_pq_params[i].wrr_group = 1;
-	i++;
+	qm_info->pure_lb_pq = curr_queue;
+	qm_info->qm_pq_params[curr_queue].vport_id =
+	    (u8) RESC_START(p_hwfn, QED_VPORT);
+	qm_info->qm_pq_params[curr_queue].tc_id = PURE_LB_TC;
+	qm_info->qm_pq_params[curr_queue].wrr_group = 1;
+	curr_queue++;
 
 	qm_info->offload_pq = 0;
+	/* Then init per-VF PQs */
+	vf_offset = curr_queue;
+	for (i = 0; i < num_vfs; i++) {
+		/* First vport is used by the PF */
+		qm_info->qm_pq_params[curr_queue].vport_id = vport_id + i + 1;
+		qm_info->qm_pq_params[curr_queue].tc_id =
+		    p_hwfn->hw_info.non_offload_tc;
+		qm_info->qm_pq_params[curr_queue].wrr_group = 1;
+		curr_queue++;
+	}
+
+	qm_info->vf_queues_offset = vf_offset;
 	qm_info->num_pqs = num_pqs;
 	qm_info->num_vports = num_vports;
 
@@ -220,7 +246,8 @@ static int qed_init_qm_info(struct qed_hwfn *p_hwfn)
 
 	qm_info->start_pq = (u16)RESC_START(p_hwfn, QED_PQ);
 
-	qm_info->start_vport = (u8)RESC_START(p_hwfn, QED_VPORT);
+	qm_info->num_vf_pqs = num_vfs;
+	qm_info->start_vport = (u8) RESC_START(p_hwfn, QED_VPORT);
 
 	for (i = 0; i < qm_info->num_vports; i++)
 		qm_info->qm_vport_params[i].vport_wfq = 1;
@@ -244,6 +271,9 @@ int qed_resc_alloc(struct qed_dev *cdev)
 	struct qed_eq *p_eq;
 	int i, rc = 0;
 
+	if (IS_VF(cdev))
+		return rc;
+
 	cdev->fw_data = kzalloc(sizeof(*cdev->fw_data), GFP_KERNEL);
 	if (!cdev->fw_data)
 		return -ENOMEM;
@@ -364,6 +394,9 @@ void qed_resc_setup(struct qed_dev *cdev)
 {
 	int i;
 
+	if (IS_VF(cdev))
+		return;
+
 	for_each_hwfn(cdev, i) {
 		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
 
@@ -508,7 +541,9 @@ static int qed_hw_init_common(struct qed_hwfn *p_hwfn,
 	struct qed_qm_info *qm_info = &p_hwfn->qm_info;
 	struct qed_qm_common_rt_init_params params;
 	struct qed_dev *cdev = p_hwfn->cdev;
+	u32 concrete_fid;
 	int rc = 0;
+	u8 vf_id;
 
 	qed_init_cau_rt_data(cdev);
 
@@ -558,6 +593,14 @@ static int qed_hw_init_common(struct qed_hwfn *p_hwfn,
 	qed_wr(p_hwfn, p_ptt, 0x20b4,
 	       qed_rd(p_hwfn, p_ptt, 0x20b4) & ~0x10);
 
+	for (vf_id = 0; vf_id < MAX_NUM_VFS_BB; vf_id++) {
+		concrete_fid = qed_vfid_to_concrete(p_hwfn, vf_id);
+		qed_fid_pretend(p_hwfn, p_ptt, (u16) concrete_fid);
+		qed_wr(p_hwfn, p_ptt, CCFC_REG_STRONG_ENABLE_VF, 0x1);
+	}
+	/* pretend to original PF */
+	qed_fid_pretend(p_hwfn, p_ptt, p_hwfn->rel_pf_id);
+
 	return rc;
 }
 
@@ -698,13 +741,20 @@ int qed_hw_init(struct qed_dev *cdev,
 	u32 load_code, param;
 	int rc, mfw_rc, i;
 
-	rc = qed_init_fw_data(cdev, bin_fw_data);
-	if (rc != 0)
-		return rc;
+	if (IS_PF(cdev)) {
+		rc = qed_init_fw_data(cdev, bin_fw_data);
+		if (rc != 0)
+			return rc;
+	}
 
 	for_each_hwfn(cdev, i) {
 		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
 
+		if (IS_VF(cdev)) {
+			p_hwfn->b_int_enabled = 1;
+			continue;
+		}
+
 		/* Enable DMAE in PXP */
 		rc = qed_change_pci_hwfn(p_hwfn, p_hwfn->p_main_ptt, true);
 
@@ -829,6 +879,11 @@ int qed_hw_stop(struct qed_dev *cdev)
 
 		DP_VERBOSE(p_hwfn, NETIF_MSG_IFDOWN, "Stopping hw/fw\n");
 
+		if (IS_VF(cdev)) {
+			/* To be implemented in a later patch */
+			continue;
+		}
+
 		/* mark the hw as uninitialized... */
 		p_hwfn->hw_init_done = false;
 
@@ -860,15 +915,16 @@ int qed_hw_stop(struct qed_dev *cdev)
 		usleep_range(1000, 2000);
 	}
 
-	/* Disable DMAE in PXP - in CMT, this should only be done for
-	 * first hw-function, and only after all transactions have
-	 * stopped for all active hw-functions.
-	 */
-	t_rc = qed_change_pci_hwfn(&cdev->hwfns[0],
-				   cdev->hwfns[0].p_main_ptt,
-				   false);
-	if (t_rc != 0)
-		rc = t_rc;
+	if (IS_PF(cdev)) {
+		/* Disable DMAE in PXP - in CMT, this should only be done for
+		 * first hw-function, and only after all transactions have
+		 * stopped for all active hw-functions.
+		 */
+		t_rc = qed_change_pci_hwfn(&cdev->hwfns[0],
+					   cdev->hwfns[0].p_main_ptt, false);
+		if (t_rc != 0)
+			rc = t_rc;
+	}
 
 	return rc;
 }
@@ -932,6 +988,11 @@ int qed_hw_reset(struct qed_dev *cdev)
 	for_each_hwfn(cdev, i) {
 		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
 
+		if (IS_VF(cdev)) {
+			/* Will be implemented in a later patch */
+			continue;
+		}
+
 		DP_VERBOSE(p_hwfn, NETIF_MSG_IFDOWN, "Resetting hw/fw\n");
 
 		/* Check for incorrect states */
@@ -1027,11 +1088,10 @@ static void qed_hw_set_feat(struct qed_hwfn *p_hwfn)
 static void qed_hw_get_resc(struct qed_hwfn *p_hwfn)
 {
 	u32 *resc_start = p_hwfn->hw_info.resc_start;
+	u8 num_funcs = p_hwfn->num_funcs_on_engine;
 	u32 *resc_num = p_hwfn->hw_info.resc_num;
 	struct qed_sb_cnt_info sb_cnt_info;
-	int num_funcs, i;
-
-	num_funcs = MAX_NUM_PFS_BB;
+	int i;
 
 	memset(&sb_cnt_info, 0, sizeof(sb_cnt_info));
 	qed_int_get_num_sbs(p_hwfn, &sb_cnt_info);
@@ -1238,6 +1298,51 @@ static int qed_hw_get_nvm_info(struct qed_hwfn *p_hwfn,
 	return qed_mcp_fill_shmem_func_info(p_hwfn, p_ptt);
 }
 
+static void qed_get_num_funcs(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
+{
+	u32 reg_function_hide, tmp, eng_mask;
+	u8 num_funcs;
+
+	num_funcs = MAX_NUM_PFS_BB;
+
+	/* Bit 0 of MISCS_REG_FUNCTION_HIDE indicates whether the bypass values
+	 * in the other bits are selected.
+	 * Bits 1-15 are for functions 1-15, respectively, and their value is
+	 * '0' only for enabled functions (function 0 always exists and
+	 * enabled).
+	 * In case of CMT, only the "even" functions are enabled, and thus the
+	 * number of functions for both hwfns is learnt from the same bits.
+	 */
+	reg_function_hide = qed_rd(p_hwfn, p_ptt, MISCS_REG_FUNCTION_HIDE);
+
+	if (reg_function_hide & 0x1) {
+		if (QED_PATH_ID(p_hwfn) && p_hwfn->cdev->num_hwfns == 1) {
+			num_funcs = 0;
+			eng_mask = 0xaaaa;
+		} else {
+			num_funcs = 1;
+			eng_mask = 0x5554;
+		}
+
+		/* Get the number of the enabled functions on the engine */
+		tmp = (reg_function_hide ^ 0xffffffff) & eng_mask;
+		while (tmp) {
+			if (tmp & 0x1)
+				num_funcs++;
+			tmp >>= 0x1;
+		}
+	}
+
+	p_hwfn->num_funcs_on_engine = num_funcs;
+
+	DP_VERBOSE(p_hwfn,
+		   NETIF_MSG_PROBE,
+		   "PF [rel_id %d, abs_id %d] within the %d enabled functions on the engine\n",
+		   p_hwfn->rel_pf_id,
+		   p_hwfn->abs_pf_id,
+		   p_hwfn->num_funcs_on_engine);
+}
+
 static int
 qed_get_hw_info(struct qed_hwfn *p_hwfn,
 		struct qed_ptt *p_ptt,
@@ -1296,6 +1401,8 @@ qed_get_hw_info(struct qed_hwfn *p_hwfn,
 		p_hwfn->hw_info.personality = protocol;
 	}
 
+	qed_get_num_funcs(p_hwfn, p_ptt);
+
 	qed_hw_get_resc(p_hwfn);
 
 	return rc;
@@ -1361,6 +1468,9 @@ static int qed_hw_prepare_single(struct qed_hwfn *p_hwfn,
 	p_hwfn->regview = p_regview;
 	p_hwfn->doorbells = p_doorbells;
 
+	if (IS_VF(p_hwfn->cdev))
+		return qed_vf_hw_prepare(p_hwfn);
+
 	/* Validate that chip access is feasible */
 	if (REG_RD(p_hwfn, PXP_PF_ME_OPAQUE_ADDR) == 0xffffffff) {
 		DP_ERR(p_hwfn,
@@ -1428,7 +1538,8 @@ int qed_hw_prepare(struct qed_dev *cdev,
 	int rc;
 
 	/* Store the precompiled init data ptrs */
-	qed_init_iro_array(cdev);
+	if (IS_PF(cdev))
+		qed_init_iro_array(cdev);
 
 	/* Initialize the first hwfn - will learn number of hwfns */
 	rc = qed_hw_prepare_single(p_hwfn,
@@ -1460,9 +1571,11 @@ int qed_hw_prepare(struct qed_dev *cdev,
 		 * initiliazed hwfn 0.
 		 */
 		if (rc) {
-			qed_init_free(p_hwfn);
-			qed_mcp_free(p_hwfn);
-			qed_hw_hwfn_free(p_hwfn);
+			if (IS_PF(cdev)) {
+				qed_init_free(p_hwfn);
+				qed_mcp_free(p_hwfn);
+				qed_hw_hwfn_free(p_hwfn);
+			}
 		}
 	}
 
@@ -1476,6 +1589,11 @@ void qed_hw_remove(struct qed_dev *cdev)
 	for_each_hwfn(cdev, i) {
 		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
 
+		if (IS_VF(cdev)) {
+			/* Will be implemented in a later patch */
+			continue;
+		}
+
 		qed_init_free(p_hwfn);
 		qed_hw_hwfn_free(p_hwfn);
 		qed_mcp_free(p_hwfn);
diff --git a/drivers/net/ethernet/qlogic/qed/qed_hsi.h b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
index 6ba197c..c511106 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_hsi.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
@@ -29,7 +29,7 @@ struct qed_ptt;
 enum common_event_opcode {
 	COMMON_EVENT_PF_START,
 	COMMON_EVENT_PF_STOP,
-	COMMON_EVENT_RESERVED,
+	COMMON_EVENT_VF_START,
 	COMMON_EVENT_RESERVED2,
 	COMMON_EVENT_VF_PF_CHANNEL,
 	COMMON_EVENT_RESERVED4,
@@ -44,7 +44,7 @@ enum common_ramrod_cmd_id {
 	COMMON_RAMROD_UNUSED,
 	COMMON_RAMROD_PF_START /* PF Function Start Ramrod */,
 	COMMON_RAMROD_PF_STOP /* PF Function Stop Ramrod */,
-	COMMON_RAMROD_RESERVED,
+	COMMON_RAMROD_VF_START,
 	COMMON_RAMROD_RESERVED2,
 	COMMON_RAMROD_PF_UPDATE,
 	COMMON_RAMROD_EMPTY,
@@ -573,6 +573,14 @@ union event_ring_element {
 	struct event_ring_next_addr	next_addr;
 };
 
+struct mstorm_non_trigger_vf_zone {
+	struct eth_mstorm_per_queue_stat eth_queue_stat;
+};
+
+struct mstorm_vf_zone {
+	struct mstorm_non_trigger_vf_zone non_trigger;
+};
+
 enum personality_type {
 	BAD_PERSONALITY_TYP,
 	PERSONALITY_RESERVED,
@@ -671,6 +679,16 @@ enum ports_mode {
 	MAX_PORTS_MODE
 };
 
+struct pstorm_non_trigger_vf_zone {
+	struct eth_pstorm_per_queue_stat eth_queue_stat;
+	struct regpair reserved[2];
+};
+
+struct pstorm_vf_zone {
+	struct pstorm_non_trigger_vf_zone non_trigger;
+	struct regpair reserved[7];
+};
+
 /* Ramrod Header of SPQE */
 struct ramrod_header {
 	__le32	cid /* Slowpath Connection CID */;
@@ -700,6 +718,29 @@ struct tstorm_per_port_stat {
 	struct regpair	preroce_irregular_pkt;
 };
 
+struct ustorm_non_trigger_vf_zone {
+	struct eth_ustorm_per_queue_stat eth_queue_stat;
+	struct regpair vf_pf_msg_addr;
+};
+
+struct ustorm_trigger_vf_zone {
+	u8 vf_pf_msg_valid;
+	u8 reserved[7];
+};
+
+struct ustorm_vf_zone {
+	struct ustorm_non_trigger_vf_zone non_trigger;
+	struct ustorm_trigger_vf_zone trigger;
+};
+
+struct vf_start_ramrod_data {
+	u8 vf_id;
+	u8 enable_flr_ack;
+	__le16 opaque_fid;
+	u8 personality;
+	u8 reserved[3];
+};
+
 struct atten_status_block {
 	__le32	atten_bits;
 	__le32	atten_ack;
@@ -1026,7 +1067,7 @@ enum init_phases {
 	PHASE_ENGINE,
 	PHASE_PORT,
 	PHASE_PF,
-	PHASE_RESERVED,
+	PHASE_VF,
 	PHASE_QM_PF,
 	MAX_INIT_PHASES
 };
diff --git a/drivers/net/ethernet/qlogic/qed/qed_hw.c b/drivers/net/ethernet/qlogic/qed/qed_hw.c
index a9be5a4..0ada7fd 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_hw.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_hw.c
@@ -23,6 +23,7 @@
 #include "qed_hsi.h"
 #include "qed_hw.h"
 #include "qed_reg_addr.h"
+#include "qed_sriov.h"
 
 #define QED_BAR_ACQUIRE_TIMEOUT 1000
 
@@ -236,8 +237,12 @@ static void qed_memcpy_hw(struct qed_hwfn *p_hwfn,
 		quota = min_t(size_t, n - done,
 			      PXP_EXTERNAL_BAR_PF_WINDOW_SINGLE_SIZE);
 
-		qed_ptt_set_win(p_hwfn, p_ptt, hw_addr + done);
-		hw_offset = qed_ptt_get_bar_addr(p_ptt);
+		if (IS_PF(p_hwfn->cdev)) {
+			qed_ptt_set_win(p_hwfn, p_ptt, hw_addr + done);
+			hw_offset = qed_ptt_get_bar_addr(p_ptt);
+		} else {
+			hw_offset = hw_addr + done;
+		}
 
 		dw_count = quota / 4;
 		host_addr = (u32 *)((u8 *)addr + done);
@@ -808,6 +813,9 @@ u16 qed_get_qm_pq(struct qed_hwfn *p_hwfn,
 		break;
 	case PROTOCOLID_ETH:
 		pq_id = p_params->eth.tc;
+		if (p_params->eth.is_vf)
+			pq_id += p_hwfn->qm_info.vf_queues_offset +
+				 p_params->eth.vf_id;
 		break;
 	default:
 		pq_id = 0;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_init_ops.c b/drivers/net/ethernet/qlogic/qed/qed_init_ops.c
index 3269b36..d358c3b 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_init_ops.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_init_ops.c
@@ -18,6 +18,7 @@
 #include "qed_hw.h"
 #include "qed_init_ops.h"
 #include "qed_reg_addr.h"
+#include "qed_sriov.h"
 
 #define QED_INIT_MAX_POLL_COUNT 100
 #define QED_INIT_POLL_PERIOD_US 500
@@ -128,6 +129,9 @@ int qed_init_alloc(struct qed_hwfn *p_hwfn)
 {
 	struct qed_rt_data *rt_data = &p_hwfn->rt_data;
 
+	if (IS_VF(p_hwfn->cdev))
+		return 0;
+
 	rt_data->b_valid = kzalloc(sizeof(bool) * RUNTIME_ARRAY_SIZE,
 				   GFP_KERNEL);
 	if (!rt_data->b_valid)
diff --git a/drivers/net/ethernet/qlogic/qed/qed_int.c b/drivers/net/ethernet/qlogic/qed/qed_int.c
index 2017b01..bbecfa5 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_int.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_int.c
@@ -26,6 +26,8 @@
 #include "qed_mcp.h"
 #include "qed_reg_addr.h"
 #include "qed_sp.h"
+#include "qed_sriov.h"
+#include "qed_vf.h"
 
 struct qed_pi_info {
 	qed_int_comp_cb_t	comp_cb;
@@ -2513,6 +2515,9 @@ void qed_int_cau_conf_pi(struct qed_hwfn *p_hwfn,
 	u32 sb_offset;
 	u32 pi_offset;
 
+	if (IS_VF(p_hwfn->cdev))
+		return;
+
 	sb_offset = igu_sb_id * PIS_PER_SB;
 	memset(&pi_entry, 0, sizeof(struct cau_pi_entry));
 
@@ -2542,8 +2547,9 @@ void qed_int_sb_setup(struct qed_hwfn *p_hwfn,
 	sb_info->sb_ack = 0;
 	memset(sb_info->sb_virt, 0, sizeof(*sb_info->sb_virt));
 
-	qed_int_cau_conf_sb(p_hwfn, p_ptt, sb_info->sb_phys,
-			    sb_info->igu_sb_id, 0, 0);
+	if (IS_PF(p_hwfn->cdev))
+		qed_int_cau_conf_sb(p_hwfn, p_ptt, sb_info->sb_phys,
+				    sb_info->igu_sb_id, 0, 0);
 }
 
 /**
@@ -2563,8 +2569,10 @@ static u16 qed_get_igu_sb_id(struct qed_hwfn *p_hwfn,
 	/* Assuming continuous set of IGU SBs dedicated for given PF */
 	if (sb_id == QED_SP_SB_ID)
 		igu_sb_id = p_hwfn->hw_info.p_igu_info->igu_dsb_id;
-	else
+	else if (IS_PF(p_hwfn->cdev))
 		igu_sb_id = sb_id + p_hwfn->hw_info.p_igu_info->igu_base_sb;
+	else
+		igu_sb_id = qed_vf_get_igu_sb_id(p_hwfn, sb_id);
 
 	DP_VERBOSE(p_hwfn, NETIF_MSG_INTR, "SB [%s] index is 0x%04x\n",
 		   (sb_id == QED_SP_SB_ID) ? "DSB" : "non-DSB", igu_sb_id);
@@ -2594,9 +2602,16 @@ int qed_int_sb_init(struct qed_hwfn *p_hwfn,
 	/* The igu address will hold the absolute address that needs to be
 	 * written to for a specific status block
 	 */
-	sb_info->igu_addr = (u8 __iomem *)p_hwfn->regview +
-					  GTT_BAR0_MAP_REG_IGU_CMD +
-					  (sb_info->igu_sb_id << 3);
+	if (IS_PF(p_hwfn->cdev)) {
+		sb_info->igu_addr = (u8 __iomem *)p_hwfn->regview +
+						  GTT_BAR0_MAP_REG_IGU_CMD +
+						  (sb_info->igu_sb_id << 3);
+	} else {
+		sb_info->igu_addr = (u8 __iomem *)p_hwfn->regview +
+						  PXP_VF_BAR0_START_IGU +
+						  ((IGU_CMD_INT_ACK_BASE +
+						    sb_info->igu_sb_id) << 3);
+	}
 
 	sb_info->flags |= QED_SB_INFO_INIT;
 
@@ -2783,6 +2798,9 @@ void qed_int_igu_disable_int(struct qed_hwfn *p_hwfn,
 {
 	p_hwfn->b_int_enabled = 0;
 
+	if (IS_VF(p_hwfn->cdev))
+		return;
+
 	qed_wr(p_hwfn, p_ptt, IGU_REG_PF_CONFIGURATION, 0);
 }
 
@@ -2935,9 +2953,9 @@ int qed_int_igu_read_cam(struct qed_hwfn *p_hwfn,
 			 struct qed_ptt *p_ptt)
 {
 	struct qed_igu_info *p_igu_info;
+	u32 val, min_vf = 0, max_vf = 0;
+	u16 sb_id, last_iov_sb_id = 0;
 	struct qed_igu_block *blk;
-	u32 val;
-	u16 sb_id;
 	u16 prev_sb_id = 0xFF;
 
 	p_hwfn->hw_info.p_igu_info = kzalloc(sizeof(*p_igu_info), GFP_KERNEL);
@@ -2947,12 +2965,19 @@ int qed_int_igu_read_cam(struct qed_hwfn *p_hwfn,
 
 	p_igu_info = p_hwfn->hw_info.p_igu_info;
 
-	/* Initialize base sb / sb cnt for PFs */
+	/* Initialize base sb / sb cnt for PFs and VFs */
 	p_igu_info->igu_base_sb		= 0xffff;
 	p_igu_info->igu_sb_cnt		= 0;
 	p_igu_info->igu_dsb_id		= 0xffff;
 	p_igu_info->igu_base_sb_iov	= 0xffff;
 
+	if (p_hwfn->cdev->p_iov_info) {
+		struct qed_hw_sriov_info *p_iov = p_hwfn->cdev->p_iov_info;
+
+		min_vf	= p_iov->first_vf_in_pf;
+		max_vf	= p_iov->first_vf_in_pf + p_iov->total_vfs;
+	}
+
 	for (sb_id = 0; sb_id < QED_MAPPING_MEMORY_SIZE(p_hwfn->cdev);
 	     sb_id++) {
 		blk = &p_igu_info->igu_map.igu_blocks[sb_id];
@@ -2986,14 +3011,43 @@ int qed_int_igu_read_cam(struct qed_hwfn *p_hwfn,
 					(p_igu_info->igu_sb_cnt)++;
 				}
 			}
+		} else {
+			if ((blk->function_id >= min_vf) &&
+			    (blk->function_id < max_vf)) {
+				/* Available for VFs of this PF */
+				if (p_igu_info->igu_base_sb_iov == 0xffff) {
+					p_igu_info->igu_base_sb_iov = sb_id;
+				} else if (last_iov_sb_id != sb_id - 1) {
+					if (!val) {
+						DP_VERBOSE(p_hwfn->cdev,
+							   NETIF_MSG_INTR,
+							   "First uninitialized IGU CAM entry at index 0x%04x\n",
+							   sb_id);
+					} else {
+						DP_NOTICE(p_hwfn->cdev,
+							  "Consecutive igu vectors for HWFN %x vfs is broken [jumps from %04x to %04x]\n",
+							  p_hwfn->rel_pf_id,
+							  last_iov_sb_id,
+							  sb_id); }
+					break;
+				}
+				blk->status |= QED_IGU_STATUS_FREE;
+				p_hwfn->hw_info.p_igu_info->free_blks++;
+				last_iov_sb_id = sb_id;
+			}
 		}
 	}
-
-	DP_VERBOSE(p_hwfn, NETIF_MSG_INTR,
-		   "IGU igu_base_sb=0x%x igu_sb_cnt=%d igu_dsb_id=0x%x\n",
-		   p_igu_info->igu_base_sb,
-		   p_igu_info->igu_sb_cnt,
-		   p_igu_info->igu_dsb_id);
+	p_igu_info->igu_sb_cnt_iov = p_igu_info->free_blks;
+
+	DP_VERBOSE(
+		p_hwfn,
+		NETIF_MSG_INTR,
+		"IGU igu_base_sb=0x%x [IOV 0x%x] igu_sb_cnt=%d [IOV 0x%x] igu_dsb_id=0x%x\n",
+		p_igu_info->igu_base_sb,
+		p_igu_info->igu_base_sb_iov,
+		p_igu_info->igu_sb_cnt,
+		p_igu_info->igu_sb_cnt_iov,
+		p_igu_info->igu_dsb_id);
 
 	if (p_igu_info->igu_base_sb == 0xffff ||
 	    p_igu_info->igu_dsb_id == 0xffff ||
@@ -3116,6 +3170,23 @@ void qed_int_get_num_sbs(struct qed_hwfn	*p_hwfn,
 	p_sb_cnt_info->sb_free_blk	= info->free_blks;
 }
 
+u16 qed_int_queue_id_from_sb_id(struct qed_hwfn *p_hwfn, u16 sb_id)
+{
+	struct qed_igu_info *p_info = p_hwfn->hw_info.p_igu_info;
+
+	/* Determine origin of SB id */
+	if ((sb_id >= p_info->igu_base_sb) &&
+	    (sb_id < p_info->igu_base_sb + p_info->igu_sb_cnt)) {
+		return sb_id - p_info->igu_base_sb;
+	} else if ((sb_id >= p_info->igu_base_sb_iov) &&
+		   (sb_id < p_info->igu_base_sb_iov + p_info->igu_sb_cnt_iov)) {
+		return sb_id - p_info->igu_base_sb_iov + p_info->igu_sb_cnt;
+	} else {
+		DP_NOTICE(p_hwfn, "SB %d not in range for function\n", sb_id);
+		return 0;
+	}
+}
+
 void qed_int_disable_post_isr_release(struct qed_dev *cdev)
 {
 	int i;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_int.h b/drivers/net/ethernet/qlogic/qed/qed_int.h
index c57f2e6..295df44 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_int.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_int.h
@@ -20,6 +20,12 @@
 #define IGU_PF_CONF_ATTN_BIT_EN   (0x1 << 3)    /* attention enable       */
 #define IGU_PF_CONF_SINGLE_ISR_EN (0x1 << 4)    /* single ISR mode enable */
 #define IGU_PF_CONF_SIMD_MODE     (0x1 << 5)    /* simd all ones mode     */
+/* Fields of IGU VF CONFIGRATION REGISTER */
+#define IGU_VF_CONF_FUNC_EN        (0x1 << 0)	/* function enable        */
+#define IGU_VF_CONF_MSI_MSIX_EN    (0x1 << 1)	/* MSI/MSIX enable        */
+#define IGU_VF_CONF_SINGLE_ISR_EN  (0x1 << 4)	/* single ISR mode enable */
+#define IGU_VF_CONF_PARENT_MASK    (0xF)	/* Parent PF              */
+#define IGU_VF_CONF_PARENT_SHIFT   5		/* Parent PF              */
 
 /* Igu control commands
  */
@@ -365,6 +371,16 @@ void qed_int_setup(struct qed_hwfn *p_hwfn,
 		   struct qed_ptt *p_ptt);
 
 /**
+ * @brief - Returns an Rx queue index appropriate for usage with given SB.
+ *
+ * @param p_hwfn
+ * @param sb_id - absolute index of SB
+ *
+ * @return index of Rx queue
+ */
+u16 qed_int_queue_id_from_sb_id(struct qed_hwfn *p_hwfn, u16 sb_id);
+
+/**
  * @brief - Enable Interrupt & Attention for hw function
  *
  * @param p_hwfn
diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index 31e1d51..8bcbf92 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -34,6 +34,7 @@
 #include "qed_mcp.h"
 #include "qed_reg_addr.h"
 #include "qed_sp.h"
+#include "qed_sriov.h"
 
 struct qed_rss_params {
 	u8	update_rss_config;
@@ -1580,32 +1581,53 @@ static int qed_fill_eth_dev_info(struct qed_dev *cdev,
 
 	info->num_tc = 1;
 
-	if (cdev->int_params.out.int_mode == QED_INT_MODE_MSIX) {
-		for_each_hwfn(cdev, i)
-			info->num_queues += FEAT_NUM(&cdev->hwfns[i],
-						     QED_PF_L2_QUE);
-		if (cdev->int_params.fp_msix_cnt)
-			info->num_queues = min_t(u8, info->num_queues,
-						 cdev->int_params.fp_msix_cnt);
+	if (IS_PF(cdev)) {
+		if (cdev->int_params.out.int_mode == QED_INT_MODE_MSIX) {
+			for_each_hwfn(cdev, i)
+			    info->num_queues +=
+			    FEAT_NUM(&cdev->hwfns[i], QED_PF_L2_QUE);
+			if (cdev->int_params.fp_msix_cnt)
+				info->num_queues =
+				    min_t(u8, info->num_queues,
+					  cdev->int_params.fp_msix_cnt);
+		} else {
+			info->num_queues = cdev->num_hwfns;
+		}
+
+		info->num_vlan_filters = RESC_NUM(&cdev->hwfns[0], QED_VLAN);
+		ether_addr_copy(info->port_mac,
+				cdev->hwfns[0].hw_info.hw_mac_addr);
 	} else {
-		info->num_queues = cdev->num_hwfns;
-	}
+		qed_vf_get_num_rxqs(QED_LEADING_HWFN(cdev), &info->num_queues);
+		if (cdev->num_hwfns > 1) {
+			u8 queues = 0;
 
-	info->num_vlan_filters = RESC_NUM(&cdev->hwfns[0], QED_VLAN);
-	ether_addr_copy(info->port_mac,
-			cdev->hwfns[0].hw_info.hw_mac_addr);
+			qed_vf_get_num_rxqs(&cdev->hwfns[1], &queues);
+			info->num_queues += queues;
+		}
+
+		qed_vf_get_num_vlan_filters(&cdev->hwfns[0],
+					    &info->num_vlan_filters);
+		qed_vf_get_port_mac(&cdev->hwfns[0], info->port_mac);
+	}
 
 	qed_fill_dev_info(cdev, &info->common);
 
+	if (IS_VF(cdev))
+		memset(info->common.hw_mac, 0, ETH_ALEN);
+
 	return 0;
 }
 
 static void qed_register_eth_ops(struct qed_dev *cdev,
-				 struct qed_eth_cb_ops *ops,
-				 void *cookie)
+				 struct qed_eth_cb_ops *ops, void *cookie)
 {
-	cdev->protocol_ops.eth	= ops;
-	cdev->ops_cookie	= cookie;
+	cdev->protocol_ops.eth = ops;
+	cdev->ops_cookie = cookie;
+
+	/* For VF, we start bulletin reading */
+	if (IS_VF(cdev))
+		qed_vf_start_iov_wq(cdev);
 }
 
 static int qed_start_vport(struct qed_dev *cdev,
@@ -1890,6 +1912,9 @@ static int qed_tunn_configure(struct qed_dev *cdev,
 	struct qed_tunn_update_params tunn_info;
 	int i, rc;
 
+	if (IS_VF(cdev))
+		return 0;
+
 	memset(&tunn_info, 0, sizeof(tunn_info));
 	if (tunn_params->update_vxlan_port == 1) {
 		tunn_info.update_vxlan_udp_port = 1;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index c209ed4..898347b 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -126,7 +126,7 @@ static int qed_init_pci(struct qed_dev *cdev,
 		goto err1;
 	}
 
-	if (!(pci_resource_flags(pdev, 2) & IORESOURCE_MEM)) {
+	if (IS_PF(cdev) && !(pci_resource_flags(pdev, 2) & IORESOURCE_MEM)) {
 		DP_NOTICE(cdev, "No memory region found in bar #2\n");
 		rc = -EIO;
 		goto err1;
@@ -176,12 +176,14 @@ static int qed_init_pci(struct qed_dev *cdev,
 		goto err2;
 	}
 
-	cdev->db_phys_addr = pci_resource_start(cdev->pdev, 2);
-	cdev->db_size = pci_resource_len(cdev->pdev, 2);
-	cdev->doorbells = ioremap_wc(cdev->db_phys_addr, cdev->db_size);
-	if (!cdev->doorbells) {
-		DP_NOTICE(cdev, "Cannot map doorbell space\n");
-		return -ENOMEM;
+	if (IS_PF(cdev)) {
+			cdev->db_phys_addr = pci_resource_start(cdev->pdev, 2);
+		cdev->db_size = pci_resource_len(cdev->pdev, 2);
+		cdev->doorbells = ioremap_wc(cdev->db_phys_addr, cdev->db_size);
+		if (!cdev->doorbells) {
+			DP_NOTICE(cdev, "Cannot map doorbell space\n");
+			return -ENOMEM;
+		}
 	}
 
 	return 0;
@@ -208,20 +210,32 @@ int qed_fill_dev_info(struct qed_dev *cdev,
 	dev_info->is_mf_default = IS_MF_DEFAULT(&cdev->hwfns[0]);
 	ether_addr_copy(dev_info->hw_mac, cdev->hwfns[0].hw_info.hw_mac_addr);
 
-	dev_info->fw_major = FW_MAJOR_VERSION;
-	dev_info->fw_minor = FW_MINOR_VERSION;
-	dev_info->fw_rev = FW_REVISION_VERSION;
-	dev_info->fw_eng = FW_ENGINEERING_VERSION;
-	dev_info->mf_mode = cdev->mf_mode;
+	if (IS_PF(cdev)) {
+		dev_info->fw_major = FW_MAJOR_VERSION;
+		dev_info->fw_minor = FW_MINOR_VERSION;
+		dev_info->fw_rev = FW_REVISION_VERSION;
+		dev_info->fw_eng = FW_ENGINEERING_VERSION;
+		dev_info->mf_mode = cdev->mf_mode;
+	} else {
+		qed_vf_get_fw_version(&cdev->hwfns[0], &dev_info->fw_major,
+				      &dev_info->fw_minor, &dev_info->fw_rev,
+				      &dev_info->fw_eng);
+	}
 
-	qed_mcp_get_mfw_ver(cdev, &dev_info->mfw_rev);
+	if (IS_PF(cdev)) {
+		ptt = qed_ptt_acquire(QED_LEADING_HWFN(cdev));
+		if (ptt) {
+			qed_mcp_get_mfw_ver(QED_LEADING_HWFN(cdev), ptt,
+					    &dev_info->mfw_rev, NULL);
 
-	ptt = qed_ptt_acquire(QED_LEADING_HWFN(cdev));
-	if (ptt) {
-		qed_mcp_get_flash_size(QED_LEADING_HWFN(cdev), ptt,
-				       &dev_info->flash_size);
+			qed_mcp_get_flash_size(QED_LEADING_HWFN(cdev), ptt,
+					       &dev_info->flash_size);
 
-		qed_ptt_release(QED_LEADING_HWFN(cdev), ptt);
+			qed_ptt_release(QED_LEADING_HWFN(cdev), ptt);
+		}
+	} else {
+		qed_mcp_get_mfw_ver(QED_LEADING_HWFN(cdev), NULL,
+				    &dev_info->mfw_rev, NULL);
 	}
 
 	return 0;
@@ -258,9 +272,7 @@ static int qed_set_power_state(struct qed_dev *cdev,
 
 /* probing */
 static struct qed_dev *qed_probe(struct pci_dev *pdev,
-				 enum qed_protocol protocol,
-				 u32 dp_module,
-				 u8 dp_level)
+				 struct qed_probe_params *params)
 {
 	struct qed_dev *cdev;
 	int rc;
@@ -269,9 +281,12 @@ static struct qed_dev *qed_probe(struct pci_dev *pdev,
 	if (!cdev)
 		goto err0;
 
-	cdev->protocol = protocol;
+	cdev->protocol = params->protocol;
 
-	qed_init_dp(cdev, dp_module, dp_level);
+	if (params->is_vf)
+		cdev->b_is_vf = true;
+
+	qed_init_dp(cdev, params->dp_module, params->dp_level);
 
 	rc = qed_init_pci(cdev, pdev);
 	if (rc) {
@@ -665,6 +680,35 @@ static int qed_slowpath_setup_int(struct qed_dev *cdev,
 	return 0;
 }
 
+static int qed_slowpath_vf_setup_int(struct qed_dev *cdev)
+{
+	int rc;
+
+	memset(&cdev->int_params, 0, sizeof(struct qed_int_params));
+	cdev->int_params.in.int_mode = QED_INT_MODE_MSIX;
+
+	qed_vf_get_num_rxqs(QED_LEADING_HWFN(cdev),
+			    &cdev->int_params.in.num_vectors);
+	if (cdev->num_hwfns > 1) {
+		u8 vectors = 0;
+
+		qed_vf_get_num_rxqs(&cdev->hwfns[1], &vectors);
+		cdev->int_params.in.num_vectors += vectors;
+	}
+
+	/* We want a minimum of one fastpath vector per vf hwfn */
+	cdev->int_params.in.min_msix_cnt = cdev->num_hwfns;
+
+	rc = qed_set_int_mode(cdev, true);
+	if (rc)
+		return rc;
+
+	cdev->int_params.fp_msix_base = 0;
+	cdev->int_params.fp_msix_cnt = cdev->int_params.out.num_vectors;
+
+	return 0;
+}
+
 u32 qed_unzip_data(struct qed_hwfn *p_hwfn, u32 input_len,
 		   u8 *input_buf, u32 max_size, u8 *unzip_buf)
 {
@@ -755,32 +799,38 @@ static int qed_slowpath_start(struct qed_dev *cdev,
 	if (qed_iov_wq_start(cdev))
 		goto err;
 
-	rc = request_firmware(&cdev->firmware, QED_FW_FILE_NAME,
-			      &cdev->pdev->dev);
-	if (rc) {
-		DP_NOTICE(cdev,
-			  "Failed to find fw file - /lib/firmware/%s\n",
-			  QED_FW_FILE_NAME);
-		goto err;
+	if (IS_PF(cdev)) {
+		rc = request_firmware(&cdev->firmware, QED_FW_FILE_NAME,
+				      &cdev->pdev->dev);
+		if (rc) {
+			DP_NOTICE(cdev,
+				  "Failed to find fw file - /lib/firmware/%s\n",
+				  QED_FW_FILE_NAME);
+			goto err;
+		}
 	}
 
 	rc = qed_nic_setup(cdev);
 	if (rc)
 		goto err;
 
-	rc = qed_slowpath_setup_int(cdev, params->int_mode);
+	if (IS_PF(cdev))
+		rc = qed_slowpath_setup_int(cdev, params->int_mode);
+	else
+		rc = qed_slowpath_vf_setup_int(cdev);
 	if (rc)
 		goto err1;
 
-	/* Allocate stream for unzipping */
-	rc = qed_alloc_stream_mem(cdev);
-	if (rc) {
-		DP_NOTICE(cdev, "Failed to allocate stream memory\n");
-		goto err2;
-	}
+	if (IS_PF(cdev)) {
+		/* Allocate stream for unzipping */
+		rc = qed_alloc_stream_mem(cdev);
+		if (rc) {
+			DP_NOTICE(cdev, "Failed to allocate stream memory\n");
+			goto err2;
+		}
 
-	/* Start the slowpath */
-	data = cdev->firmware->data;
+		data = cdev->firmware->data;
+	}
 
 	memset(&tunn_info, 0, sizeof(tunn_info));
 	tunn_info.tunn_mode |=  1 << QED_MODE_VXLAN_TUNN |
@@ -793,6 +843,7 @@ static int qed_slowpath_start(struct qed_dev *cdev,
 	tunn_info.tunn_clss_l2gre = QED_TUNN_CLSS_MAC_VLAN;
 	tunn_info.tunn_clss_ipgre = QED_TUNN_CLSS_MAC_VLAN;
 
+	/* Start the slowpath */
 	rc = qed_hw_init(cdev, &tunn_info, true,
 			 cdev->int_params.out.int_mode,
 			 true, data);
@@ -802,18 +853,20 @@ static int qed_slowpath_start(struct qed_dev *cdev,
 	DP_INFO(cdev,
 		"HW initialization and function start completed successfully\n");
 
-	hwfn = QED_LEADING_HWFN(cdev);
-	drv_version.version = (params->drv_major << 24) |
-			      (params->drv_minor << 16) |
-			      (params->drv_rev << 8) |
-			      (params->drv_eng);
-	strlcpy(drv_version.name, params->name,
-		MCP_DRV_VER_STR_SIZE - 4);
-	rc = qed_mcp_send_drv_version(hwfn, hwfn->p_main_ptt,
-				      &drv_version);
-	if (rc) {
-		DP_NOTICE(cdev, "Failed sending drv version command\n");
-		return rc;
+	if (IS_PF(cdev)) {
+		hwfn = QED_LEADING_HWFN(cdev);
+		drv_version.version = (params->drv_major << 24) |
+				      (params->drv_minor << 16) |
+				      (params->drv_rev << 8) |
+				      (params->drv_eng);
+		strlcpy(drv_version.name, params->name,
+			MCP_DRV_VER_STR_SIZE - 4);
+		rc = qed_mcp_send_drv_version(hwfn, hwfn->p_main_ptt,
+					      &drv_version);
+		if (rc) {
+			DP_NOTICE(cdev, "Failed sending drv version command\n");
+			return rc;
+		}
 	}
 
 	qed_reset_vport_stats(cdev);
@@ -822,13 +875,15 @@ static int qed_slowpath_start(struct qed_dev *cdev,
 
 err2:
 	qed_hw_timers_stop_all(cdev);
-	qed_slowpath_irq_free(cdev);
+	if (IS_PF(cdev))
+		qed_slowpath_irq_free(cdev);
 	qed_free_stream_mem(cdev);
 	qed_disable_msix(cdev);
 err1:
 	qed_resc_free(cdev);
 err:
-	release_firmware(cdev->firmware);
+	if (IS_PF(cdev))
+		release_firmware(cdev->firmware);
 
 	qed_iov_wq_stop(cdev, false);
 
@@ -840,17 +895,20 @@ static int qed_slowpath_stop(struct qed_dev *cdev)
 	if (!cdev)
 		return -ENODEV;
 
-	qed_free_stream_mem(cdev);
+	if (IS_PF(cdev)) {
+		qed_free_stream_mem(cdev);
 
-	qed_nic_stop(cdev);
-	qed_slowpath_irq_free(cdev);
+		qed_nic_stop(cdev);
+		qed_slowpath_irq_free(cdev);
+	}
 
 	qed_disable_msix(cdev);
 	qed_nic_reset(cdev);
 
 	qed_iov_wq_stop(cdev, true);
 
-	release_firmware(cdev->firmware);
+	if (IS_PF(cdev))
+		release_firmware(cdev->firmware);
 
 	return 0;
 }
@@ -940,6 +998,9 @@ static int qed_set_link(struct qed_dev *cdev,
 	if (!cdev)
 		return -ENODEV;
 
+	if (IS_VF(cdev))
+		return 0;
+
 	/* The link should be set only once per PF */
 	hwfn = &cdev->hwfns[0];
 
@@ -1051,10 +1112,16 @@ static void qed_fill_link(struct qed_hwfn *hwfn,
 	memset(if_link, 0, sizeof(*if_link));
 
 	/* Prepare source inputs */
-	memcpy(&params, qed_mcp_get_link_params(hwfn), sizeof(params));
-	memcpy(&link, qed_mcp_get_link_state(hwfn), sizeof(link));
-	memcpy(&link_caps, qed_mcp_get_link_capabilities(hwfn),
-	       sizeof(link_caps));
+	if (IS_PF(hwfn->cdev)) {
+		memcpy(&params, qed_mcp_get_link_params(hwfn), sizeof(params));
+		memcpy(&link, qed_mcp_get_link_state(hwfn), sizeof(link));
+		memcpy(&link_caps, qed_mcp_get_link_capabilities(hwfn),
+		       sizeof(link_caps));
+	} else {
+		memset(&params, 0, sizeof(params));
+		memset(&link, 0, sizeof(link));
+		memset(&link_caps, 0, sizeof(link_caps));
+	}
 
 	/* Set the link parameters to pass to protocol driver */
 	if (link.link_up)
@@ -1177,6 +1244,9 @@ static int qed_drain(struct qed_dev *cdev)
 	struct qed_ptt *ptt;
 	int i, rc;
 
+	if (IS_VF(cdev))
+		return 0;
+
 	for_each_hwfn(cdev, i) {
 		hwfn = &cdev->hwfns[i];
 		ptt = qed_ptt_acquire(hwfn);
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index 2f8309d..8317500 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -19,6 +19,8 @@
 #include "qed_hw.h"
 #include "qed_mcp.h"
 #include "qed_reg_addr.h"
+#include "qed_sriov.h"
+
 #define CHIP_MCP_RESP_ITER_US 10
 
 #define QED_DRV_MB_MAX_RETRIES	(500 * 1000)	/* Account for 5 sec */
@@ -787,26 +789,42 @@ int qed_mcp_handle_events(struct qed_hwfn *p_hwfn,
 	return rc;
 }
 
-int qed_mcp_get_mfw_ver(struct qed_dev *cdev,
-			u32 *p_mfw_ver)
+int qed_mcp_get_mfw_ver(struct qed_hwfn *p_hwfn,
+			struct qed_ptt *p_ptt,
+			u32 *p_mfw_ver, u32 *p_running_bundle_id)
 {
-	struct qed_hwfn *p_hwfn = &cdev->hwfns[0];
-	struct qed_ptt *p_ptt;
 	u32 global_offsize;
 
-	p_ptt = qed_ptt_acquire(p_hwfn);
-	if (!p_ptt)
-		return -EBUSY;
+	if (IS_VF(p_hwfn->cdev)) {
+		if (p_hwfn->vf_iov_info) {
+			struct pfvf_acquire_resp_tlv *p_resp;
+
+			p_resp = &p_hwfn->vf_iov_info->acquire_resp;
+			*p_mfw_ver = p_resp->pfdev_info.mfw_ver;
+			return 0;
+		} else {
+			DP_VERBOSE(p_hwfn,
+				   QED_MSG_IOV,
+				   "VF requested MFW version prior to ACQUIRE\n");
+			return -EINVAL;
+		}
+	}
 
 	global_offsize = qed_rd(p_hwfn, p_ptt,
-				SECTION_OFFSIZE_ADDR(p_hwfn->mcp_info->
-						     public_base,
+				SECTION_OFFSIZE_ADDR(p_hwfn->
+						     mcp_info->public_base,
 						     PUBLIC_GLOBAL));
-	*p_mfw_ver = qed_rd(p_hwfn, p_ptt,
-			    SECTION_ADDR(global_offsize, 0) +
-			    offsetof(struct public_global, mfw_ver));
-
-	qed_ptt_release(p_hwfn, p_ptt);
+	*p_mfw_ver =
+	    qed_rd(p_hwfn, p_ptt,
+		   SECTION_ADDR(global_offsize,
+				0) + offsetof(struct public_global, mfw_ver));
+
+	if (p_running_bundle_id != NULL) {
+		*p_running_bundle_id = qed_rd(p_hwfn, p_ptt,
+					      SECTION_ADDR(global_offsize, 0) +
+					      offsetof(struct public_global,
+						       running_bundle_id));
+	}
 
 	return 0;
 }
@@ -817,6 +835,9 @@ int qed_mcp_get_media_type(struct qed_dev *cdev,
 	struct qed_hwfn *p_hwfn = &cdev->hwfns[0];
 	struct qed_ptt  *p_ptt;
 
+	if (IS_VF(cdev))
+		return -EINVAL;
+
 	if (!qed_mcp_is_init(p_hwfn)) {
 		DP_NOTICE(p_hwfn, "MFW is not initialized !\n");
 		return -EBUSY;
@@ -951,6 +972,9 @@ int qed_mcp_get_flash_size(struct qed_hwfn *p_hwfn,
 {
 	u32 flash_size;
 
+	if (IS_VF(p_hwfn->cdev))
+		return -EINVAL;
+
 	flash_size = qed_rd(p_hwfn, p_ptt, MCP_REG_NVM_CFG4);
 	flash_size = (flash_size & MCP_REG_NVM_CFG4_FLASH_SIZE) >>
 		      MCP_REG_NVM_CFG4_FLASH_SIZE_SHIFT;
@@ -961,6 +985,37 @@ int qed_mcp_get_flash_size(struct qed_hwfn *p_hwfn,
 	return 0;
 }
 
+int qed_mcp_config_vf_msix(struct qed_hwfn *p_hwfn,
+			   struct qed_ptt *p_ptt, u8 vf_id, u8 num)
+{
+	u32 resp = 0, param = 0, rc_param = 0;
+	int rc;
+
+	/* Only Leader can configure MSIX, and need to take CMT into account */
+	if (!IS_LEAD_HWFN(p_hwfn))
+		return 0;
+	num *= p_hwfn->cdev->num_hwfns;
+
+	param |= (vf_id << DRV_MB_PARAM_CFG_VF_MSIX_VF_ID_SHIFT) &
+		 DRV_MB_PARAM_CFG_VF_MSIX_VF_ID_MASK;
+	param |= (num << DRV_MB_PARAM_CFG_VF_MSIX_SB_NUM_SHIFT) &
+		 DRV_MB_PARAM_CFG_VF_MSIX_SB_NUM_MASK;
+
+	rc = qed_mcp_cmd(p_hwfn, p_ptt, DRV_MSG_CODE_CFG_VF_MSIX, param,
+			 &resp, &rc_param);
+
+	if (resp != FW_MSG_CODE_DRV_CFG_VF_MSIX_DONE) {
+		DP_NOTICE(p_hwfn, "VF[%d]: MFW failed to set MSI-X\n", vf_id);
+		rc = -EINVAL;
+	} else {
+		DP_VERBOSE(p_hwfn, QED_MSG_IOV,
+			   "Requested 0x%02x MSI-x interrupts from VF 0x%02x\n",
+			   num, vf_id);
+	}
+
+	return rc;
+}
+
 int
 qed_mcp_send_drv_version(struct qed_hwfn *p_hwfn,
 			 struct qed_ptt *p_ptt,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.h b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
index 5f218ee..e3d5cdf 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
@@ -149,13 +149,16 @@ int qed_mcp_set_link(struct qed_hwfn   *p_hwfn,
 /**
  * @brief Get the management firmware version value
  *
- * @param cdev       - qed dev pointer
- * @param mfw_ver    - mfw version value
+ * @param p_hwfn
+ * @param p_ptt
+ * @param p_mfw_ver    - mfw version value
+ * @param p_running_bundle_id	- image id in nvram; Optional.
  *
- * @return int - 0 - operation was successul.
+ * @return int - 0 - operation was successful.
  */
-int qed_mcp_get_mfw_ver(struct qed_dev *cdev,
-			u32 *mfw_ver);
+int qed_mcp_get_mfw_ver(struct qed_hwfn *p_hwfn,
+			struct qed_ptt *p_ptt,
+			u32 *p_mfw_ver, u32 *p_running_bundle_id);
 
 /**
  * @brief Get media type value of the port.
@@ -418,6 +421,20 @@ int qed_mcp_reset(struct qed_hwfn *p_hwfn,
  * @return true iff MFW is running and mcp_info is initialized
  */
 bool qed_mcp_is_init(struct qed_hwfn *p_hwfn);
+
+/**
+ * @brief request MFW to configure MSI-X for a VF
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ * @param vf_id - absolute inside engine
+ * @param num_sbs - number of entries to request
+ *
+ * @return int
+ */
+int qed_mcp_config_vf_msix(struct qed_hwfn *p_hwfn,
+			   struct qed_ptt *p_ptt, u8 vf_id, u8 num);
+
 int qed_configure_pf_min_bandwidth(struct qed_dev *cdev, u8 min_bw);
 int qed_configure_pf_max_bandwidth(struct qed_dev *cdev, u8 max_bw);
 int __qed_configure_pf_max_bandwidth(struct qed_hwfn *p_hwfn,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h b/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
index bf4d7cc..a508b6b 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
@@ -39,6 +39,8 @@
 	0x2aae04UL
 #define  PGLUE_B_REG_INTERNAL_PFID_ENABLE_MASTER	\
 	0x2aa16cUL
+#define PGLUE_B_REG_WAS_ERROR_VF_31_0_CLR \
+	0x2aa118UL
 #define  BAR0_MAP_REG_MSDM_RAM \
 	0x1d00000UL
 #define  BAR0_MAP_REG_USDM_RAM \
@@ -111,6 +113,8 @@
 	0x009778UL
 #define  MISCS_REG_CHIP_METAL \
 	0x009774UL
+#define MISCS_REG_FUNCTION_HIDE \
+	0x0096f0UL
 #define  BRB_REG_HEADER_SIZE \
 	0x340804UL
 #define  BTB_REG_HEADER_SIZE \
@@ -119,6 +123,8 @@
 	0x1c0708UL
 #define  CCFC_REG_ACTIVITY_COUNTER \
 	0x2e8800UL
+#define CCFC_REG_STRONG_ENABLE_VF \
+	0x2e070cUL
 #define  CDU_REG_CID_ADDR_PARAMS	\
 	0x580900UL
 #define  DBG_REG_CLIENT_ENABLE \
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sp.h b/drivers/net/ethernet/qlogic/qed/qed_sp.h
index eec137f..dde69090 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_sp.h
@@ -62,6 +62,8 @@ union ramrod_data {
 	struct vport_stop_ramrod_data vport_stop;
 	struct vport_update_ramrod_data vport_update;
 	struct vport_filter_update_ramrod_data vport_filter_update;
+
+	struct vf_start_ramrod_data vf_start;
 };
 
 #define EQ_MAX_CREDIT   0xffffffff
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c b/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
index e1e2344..ed90947 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
@@ -20,6 +20,7 @@
 #include "qed_int.h"
 #include "qed_reg_addr.h"
 #include "qed_sp.h"
+#include "qed_sriov.h"
 
 int qed_sp_init_request(struct qed_hwfn *p_hwfn,
 			struct qed_spq_entry **pp_ent,
@@ -357,6 +358,13 @@ int qed_sp_pf_start(struct qed_hwfn *p_hwfn,
 				     &p_ramrod->tunnel_config);
 	p_hwfn->hw_info.personality = PERSONALITY_ETH;
 
+	if (p_hwfn->cdev->p_iov_info) {
+		struct qed_hw_sriov_info *p_iov = p_hwfn->cdev->p_iov_info;
+
+		p_ramrod->base_vf_id = (u8) p_iov->first_vf_in_pf;
+		p_ramrod->num_vfs = (u8) p_iov->total_vfs;
+	}
+
 	DP_VERBOSE(p_hwfn, QED_MSG_SPQ,
 		   "Setting event_ring_sb [id %04x index %02x], outer_tag [%d]\n",
 		   sb, sb_index,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_spq.c b/drivers/net/ethernet/qlogic/qed/qed_spq.c
index 0e439e4..acac662 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_spq.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_spq.c
@@ -387,6 +387,9 @@ static int qed_cqe_completion(
 	struct eth_slow_path_rx_cqe *cqe,
 	enum protocol_type protocol)
 {
+	if (IS_VF(p_hwfn->cdev))
+		return 0;
+
 	/* @@@tmp - it's possible we'll eventually want to handle some
 	 * actual commands that can arrive here, but for now this is only
 	 * used to complete the ramrod using the echo value on the cqe
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index 4a6af42..699d96f 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -6,12 +6,48 @@
  * this source tree.
  */
 
+#include "qed_cxt.h"
+#include "qed_hsi.h"
 #include "qed_hw.h"
+#include "qed_init_ops.h"
 #include "qed_int.h"
+#include "qed_mcp.h"
 #include "qed_reg_addr.h"
+#include "qed_sp.h"
 #include "qed_sriov.h"
 #include "qed_vf.h"
 
+/* IOV ramrods */
+static int qed_sp_vf_start(struct qed_hwfn *p_hwfn,
+			   u32 concrete_vfid, u16 opaque_vfid)
+{
+	struct vf_start_ramrod_data *p_ramrod = NULL;
+	struct qed_spq_entry *p_ent = NULL;
+	struct qed_sp_init_data init_data;
+	int rc = -EINVAL;
+
+	/* Get SPQ entry */
+	memset(&init_data, 0, sizeof(init_data));
+	init_data.cid = qed_spq_get_cid(p_hwfn);
+	init_data.opaque_fid = opaque_vfid;
+	init_data.comp_mode = QED_SPQ_MODE_EBLOCK;
+
+	rc = qed_sp_init_request(p_hwfn, &p_ent,
+				 COMMON_RAMROD_VF_START,
+				 PROTOCOLID_COMMON, &init_data);
+	if (rc)
+		return rc;
+
+	p_ramrod = &p_ent->ramrod.vf_start;
+
+	p_ramrod->vf_id = GET_FIELD(concrete_vfid, PXP_CONCRETE_FID_VFID);
+	p_ramrod->opaque_fid = cpu_to_le16(opaque_vfid);
+
+	p_ramrod->personality = PERSONALITY_ETH;
+
+	return qed_spq_post(p_hwfn, p_ent, NULL);
+}
+
 bool qed_iov_is_valid_vfid(struct qed_hwfn *p_hwfn,
 			   int rel_vf_id, bool b_enabled_only)
 {
@@ -321,6 +357,9 @@ int qed_iov_hw_info(struct qed_hwfn *p_hwfn)
 	int pos;
 	int rc;
 
+	if (IS_VF(p_hwfn->cdev))
+		return 0;
+
 	/* Learn the PCI configuration */
 	pos = pci_find_ext_capability(p_hwfn->cdev->pdev,
 				      PCI_EXT_CAP_ID_SRIOV);
@@ -376,12 +415,189 @@ static bool qed_iov_pf_sanity_check(struct qed_hwfn *p_hwfn, int vfid)
 		return false;
 
 	/* Check VF validity */
-	if (!qed_iov_is_valid_vfid(p_hwfn, vfid, true))
+	if (IS_VF(p_hwfn->cdev) || !IS_QED_SRIOV(p_hwfn->cdev) ||
+	    !IS_PF_SRIOV_ALLOC(p_hwfn))
 		return false;
 
 	return true;
 }
 
+static void qed_iov_vf_pglue_clear_err(struct qed_hwfn *p_hwfn,
+				       struct qed_ptt *p_ptt, u8 abs_vfid)
+{
+	qed_wr(p_hwfn, p_ptt,
+	       PGLUE_B_REG_WAS_ERROR_VF_31_0_CLR + (abs_vfid >> 5) * 4,
+	       1 << (abs_vfid & 0x1f));
+}
+
+static int qed_iov_enable_vf_access(struct qed_hwfn *p_hwfn,
+				    struct qed_ptt *p_ptt,
+				    struct qed_vf_info *vf)
+{
+	u32 igu_vf_conf = IGU_VF_CONF_FUNC_EN;
+	int rc;
+
+	DP_VERBOSE(p_hwfn,
+		   QED_MSG_IOV,
+		   "Enable internal access for vf %x [abs %x]\n",
+		   vf->abs_vf_id, QED_VF_ABS_ID(p_hwfn, vf));
+
+	qed_iov_vf_pglue_clear_err(p_hwfn, p_ptt, QED_VF_ABS_ID(p_hwfn, vf));
+
+	rc = qed_mcp_config_vf_msix(p_hwfn, p_ptt, vf->abs_vf_id, vf->num_sbs);
+	if (rc)
+		return rc;
+
+	qed_fid_pretend(p_hwfn, p_ptt, (u16) vf->concrete_fid);
+
+	SET_FIELD(igu_vf_conf, IGU_VF_CONF_PARENT, p_hwfn->rel_pf_id);
+	STORE_RT_REG(p_hwfn, IGU_REG_VF_CONFIGURATION_RT_OFFSET, igu_vf_conf);
+
+	qed_init_run(p_hwfn, p_ptt, PHASE_VF, vf->abs_vf_id,
+		     p_hwfn->hw_info.hw_mode);
+
+	/* unpretend */
+	qed_fid_pretend(p_hwfn, p_ptt, (u16) p_hwfn->hw_info.concrete_fid);
+
+	if (vf->state != VF_STOPPED) {
+		DP_NOTICE(p_hwfn, "VF[%02x] is already started\n",
+			  vf->abs_vf_id);
+		return -EINVAL;
+	}
+
+	/* Start VF */
+	rc = qed_sp_vf_start(p_hwfn, vf->concrete_fid, vf->opaque_fid);
+	if (rc)
+		DP_NOTICE(p_hwfn, "Failed to start VF[%02x]\n", vf->abs_vf_id);
+
+	vf->state = VF_FREE;
+
+	return rc;
+}
+
+static u8 qed_iov_alloc_vf_igu_sbs(struct qed_hwfn *p_hwfn,
+				   struct qed_ptt *p_ptt,
+				   struct qed_vf_info *vf, u16 num_rx_queues)
+{
+	struct qed_igu_block *igu_blocks;
+	int qid = 0, igu_id = 0;
+	u32 val = 0;
+
+	igu_blocks = p_hwfn->hw_info.p_igu_info->igu_map.igu_blocks;
+
+	if (num_rx_queues > p_hwfn->hw_info.p_igu_info->free_blks)
+		num_rx_queues = p_hwfn->hw_info.p_igu_info->free_blks;
+	p_hwfn->hw_info.p_igu_info->free_blks -= num_rx_queues;
+
+	SET_FIELD(val, IGU_MAPPING_LINE_FUNCTION_NUMBER, vf->abs_vf_id);
+	SET_FIELD(val, IGU_MAPPING_LINE_VALID, 1);
+	SET_FIELD(val, IGU_MAPPING_LINE_PF_VALID, 0);
+
+	while ((qid < num_rx_queues) &&
+	       (igu_id < QED_MAPPING_MEMORY_SIZE(p_hwfn->cdev))) {
+		if (igu_blocks[igu_id].status & QED_IGU_STATUS_FREE) {
+			struct cau_sb_entry sb_entry;
+
+			vf->igu_sbs[qid] = (u16)igu_id;
+			igu_blocks[igu_id].status &= ~QED_IGU_STATUS_FREE;
+
+			SET_FIELD(val, IGU_MAPPING_LINE_VECTOR_NUMBER, qid);
+
+			qed_wr(p_hwfn, p_ptt,
+			       IGU_REG_MAPPING_MEMORY + sizeof(u32) * igu_id,
+			       val);
+
+			/* Configure igu sb in CAU which were marked valid */
+			qed_init_cau_sb_entry(p_hwfn, &sb_entry,
+					      p_hwfn->rel_pf_id,
+					      vf->abs_vf_id, 1);
+			qed_dmae_host2grc(p_hwfn, p_ptt,
+					  (u64)(uintptr_t)&sb_entry,
+					  CAU_REG_SB_VAR_MEMORY +
+					  igu_id * sizeof(u64), 2, 0);
+			qid++;
+		}
+		igu_id++;
+	}
+
+	vf->num_sbs = (u8) num_rx_queues;
+
+	return vf->num_sbs;
+}
+
+static int qed_iov_init_hw_for_vf(struct qed_hwfn *p_hwfn,
+				  struct qed_ptt *p_ptt,
+				  u16 rel_vf_id, u16 num_rx_queues)
+{
+	u8 num_of_vf_avaiable_chains = 0;
+	struct qed_vf_info *vf = NULL;
+	int rc = 0;
+	u32 cids;
+	u8 i;
+
+	vf = qed_iov_get_vf_info(p_hwfn, rel_vf_id, false);
+	if (!vf) {
+		DP_ERR(p_hwfn, "qed_iov_init_hw_for_vf : vf is NULL\n");
+		return -EINVAL;
+	}
+
+	if (vf->b_init) {
+		DP_NOTICE(p_hwfn, "VF[%d] is already active.\n", rel_vf_id);
+		return -EINVAL;
+	}
+
+	/* Limit number of queues according to number of CIDs */
+	qed_cxt_get_proto_cid_count(p_hwfn, PROTOCOLID_ETH, &cids);
+	DP_VERBOSE(p_hwfn,
+		   QED_MSG_IOV,
+		   "VF[%d] - requesting to initialize for 0x%04x queues [0x%04x CIDs available]\n",
+		   vf->relative_vf_id, num_rx_queues, (u16) cids);
+	num_rx_queues = min_t(u16, num_rx_queues, ((u16) cids));
+
+	num_of_vf_avaiable_chains = qed_iov_alloc_vf_igu_sbs(p_hwfn,
+							     p_ptt,
+							     vf,
+							     num_rx_queues);
+	if (!num_of_vf_avaiable_chains) {
+		DP_ERR(p_hwfn, "no available igu sbs\n");
+		return -ENOMEM;
+	}
+
+	/* Choose queue number and index ranges */
+	vf->num_rxqs = num_of_vf_avaiable_chains;
+	vf->num_txqs = num_of_vf_avaiable_chains;
+
+	for (i = 0; i < vf->num_rxqs; i++) {
+		u16 queue_id = qed_int_queue_id_from_sb_id(p_hwfn,
+							   vf->igu_sbs[i]);
+
+		if (queue_id > RESC_NUM(p_hwfn, QED_L2_QUEUE)) {
+			DP_NOTICE(p_hwfn,
+				  "VF[%d] will require utilizing of out-of-bounds queues - %04x\n",
+				  vf->relative_vf_id, queue_id);
+			return -EINVAL;
+		}
+
+		/* CIDs are per-VF, so no problem having them 0-based. */
+		vf->vf_queues[i].fw_rx_qid = queue_id;
+		vf->vf_queues[i].fw_tx_qid = queue_id;
+		vf->vf_queues[i].fw_cid = i;
+
+		DP_VERBOSE(p_hwfn, QED_MSG_IOV,
+			   "VF[%d] - [%d] SB %04x, Tx/Rx queue %04x CID %04x\n",
+			   vf->relative_vf_id, i, vf->igu_sbs[i], queue_id, i);
+	}
+	rc = qed_iov_enable_vf_access(p_hwfn, p_ptt, vf);
+	if (!rc) {
+		vf->b_init = true;
+
+		if (IS_LEAD_HWFN(p_hwfn))
+			p_hwfn->cdev->p_iov_info->num_vfs++;
+	}
+
+	return rc;
+}
+
 static bool qed_iov_tlv_supported(u16 tlvtype)
 {
 	return CHANNEL_TLV_NONE < tlvtype && tlvtype < CHANNEL_TLV_MAX;
@@ -486,13 +702,147 @@ static void qed_iov_prepare_resp(struct qed_hwfn *p_hwfn,
 	qed_iov_send_response(p_hwfn, p_ptt, vf_info, length, status);
 }
 
-static void qed_iov_process_mbx_dummy_resp(struct qed_hwfn *p_hwfn,
-					   struct qed_ptt *p_ptt,
-					   struct qed_vf_info *p_vf)
+static void qed_iov_vf_mbx_acquire(struct qed_hwfn *p_hwfn,
+				   struct qed_ptt *p_ptt,
+				   struct qed_vf_info *vf)
 {
-	qed_iov_prepare_resp(p_hwfn, p_ptt, p_vf, CHANNEL_TLV_NONE,
-			     sizeof(struct pfvf_def_resp_tlv),
-			     PFVF_STATUS_SUCCESS);
+	struct qed_iov_vf_mbx *mbx = &vf->vf_mbx;
+	struct pfvf_acquire_resp_tlv *resp = &mbx->reply_virt->acquire_resp;
+	struct pf_vf_pfdev_info *pfdev_info = &resp->pfdev_info;
+	struct vfpf_acquire_tlv *req = &mbx->req_virt->acquire;
+	u8 i, vfpf_status = PFVF_STATUS_SUCCESS;
+	struct pf_vf_resc *resc = &resp->resc;
+
+	/* Validate FW compatibility */
+	if (req->vfdev_info.fw_major != FW_MAJOR_VERSION ||
+	    req->vfdev_info.fw_minor != FW_MINOR_VERSION ||
+	    req->vfdev_info.fw_revision != FW_REVISION_VERSION ||
+	    req->vfdev_info.fw_engineering != FW_ENGINEERING_VERSION) {
+		DP_INFO(p_hwfn,
+			"VF[%d] is running an incompatible driver [VF needs FW %02x:%02x:%02x:%02x but Hypervisor is using %02x:%02x:%02x:%02x]\n",
+			vf->abs_vf_id,
+			req->vfdev_info.fw_major,
+			req->vfdev_info.fw_minor,
+			req->vfdev_info.fw_revision,
+			req->vfdev_info.fw_engineering,
+			FW_MAJOR_VERSION,
+			FW_MINOR_VERSION,
+			FW_REVISION_VERSION, FW_ENGINEERING_VERSION);
+		vfpf_status = PFVF_STATUS_NOT_SUPPORTED;
+		goto out;
+	}
+
+	/* On 100g PFs, prevent old VFs from loading */
+	if ((p_hwfn->cdev->num_hwfns > 1) &&
+	    !(req->vfdev_info.capabilities & VFPF_ACQUIRE_CAP_100G)) {
+		DP_INFO(p_hwfn,
+			"VF[%d] is running an old driver that doesn't support 100g\n",
+			vf->abs_vf_id);
+		vfpf_status = PFVF_STATUS_NOT_SUPPORTED;
+		goto out;
+	}
+
+	memset(resp, 0, sizeof(*resp));
+
+	/* Fill in vf info stuff */
+	vf->opaque_fid = req->vfdev_info.opaque_fid;
+	vf->num_mac_filters = 1;
+	vf->num_vlan_filters = QED_ETH_VF_NUM_VLAN_FILTERS;
+
+	vf->vf_bulletin = req->bulletin_addr;
+	vf->bulletin.size = (vf->bulletin.size < req->bulletin_size) ?
+			    vf->bulletin.size : req->bulletin_size;
+
+	/* fill in pfdev info */
+	pfdev_info->chip_num = p_hwfn->cdev->chip_num;
+	pfdev_info->db_size = 0;
+	pfdev_info->indices_per_sb = PIS_PER_SB;
+
+	pfdev_info->capabilities = PFVF_ACQUIRE_CAP_DEFAULT_UNTAGGED |
+				   PFVF_ACQUIRE_CAP_POST_FW_OVERRIDE;
+	if (p_hwfn->cdev->num_hwfns > 1)
+		pfdev_info->capabilities |= PFVF_ACQUIRE_CAP_100G;
+
+	pfdev_info->stats_info.mstats.address =
+	    PXP_VF_BAR0_START_MSDM_ZONE_B +
+	    offsetof(struct mstorm_vf_zone, non_trigger.eth_queue_stat);
+	pfdev_info->stats_info.mstats.len =
+	    sizeof(struct eth_mstorm_per_queue_stat);
+
+	pfdev_info->stats_info.ustats.address =
+	    PXP_VF_BAR0_START_USDM_ZONE_B +
+	    offsetof(struct ustorm_vf_zone, non_trigger.eth_queue_stat);
+	pfdev_info->stats_info.ustats.len =
+	    sizeof(struct eth_ustorm_per_queue_stat);
+
+	pfdev_info->stats_info.pstats.address =
+	    PXP_VF_BAR0_START_PSDM_ZONE_B +
+	    offsetof(struct pstorm_vf_zone, non_trigger.eth_queue_stat);
+	pfdev_info->stats_info.pstats.len =
+	    sizeof(struct eth_pstorm_per_queue_stat);
+
+	pfdev_info->stats_info.tstats.address = 0;
+	pfdev_info->stats_info.tstats.len = 0;
+
+	memcpy(pfdev_info->port_mac, p_hwfn->hw_info.hw_mac_addr, ETH_ALEN);
+
+	pfdev_info->fw_major = FW_MAJOR_VERSION;
+	pfdev_info->fw_minor = FW_MINOR_VERSION;
+	pfdev_info->fw_rev = FW_REVISION_VERSION;
+	pfdev_info->fw_eng = FW_ENGINEERING_VERSION;
+	pfdev_info->os_type = VFPF_ACQUIRE_OS_LINUX;
+	qed_mcp_get_mfw_ver(p_hwfn, p_ptt, &pfdev_info->mfw_ver, NULL);
+
+	pfdev_info->dev_type = p_hwfn->cdev->type;
+	pfdev_info->chip_rev = p_hwfn->cdev->chip_rev;
+
+	resc->num_rxqs = vf->num_rxqs;
+	resc->num_txqs = vf->num_txqs;
+	resc->num_sbs = vf->num_sbs;
+	for (i = 0; i < resc->num_sbs; i++) {
+		resc->hw_sbs[i].hw_sb_id = vf->igu_sbs[i];
+		resc->hw_sbs[i].sb_qid = 0;
+	}
+
+	for (i = 0; i < resc->num_rxqs; i++) {
+		qed_fw_l2_queue(p_hwfn, vf->vf_queues[i].fw_rx_qid,
+				(u16 *)&resc->hw_qid[i]);
+		resc->cid[i] = vf->vf_queues[i].fw_cid;
+	}
+
+	resc->num_mac_filters = min_t(u8, vf->num_mac_filters,
+				      req->resc_request.num_mac_filters);
+	resc->num_vlan_filters = min_t(u8, vf->num_vlan_filters,
+				       req->resc_request.num_vlan_filters);
+
+	/* This isn't really required as VF isn't limited, but some VFs might
+	 * actually test this value, so need to provide it.
+	 */
+	resc->num_mc_filters = req->resc_request.num_mc_filters;
+
+	/* Fill agreed size of bulletin board in response */
+	resp->bulletin_size = vf->bulletin.size;
+
+	DP_VERBOSE(p_hwfn,
+		   QED_MSG_IOV,
+		   "VF[%d] ACQUIRE_RESPONSE: pfdev_info- chip_num=0x%x, db_size=%d, idx_per_sb=%d, pf_cap=0x%llx\n"
+		   "resources- n_rxq-%d, n_txq-%d, n_sbs-%d, n_macs-%d, n_vlans-%d\n",
+		   vf->abs_vf_id,
+		   resp->pfdev_info.chip_num,
+		   resp->pfdev_info.db_size,
+		   resp->pfdev_info.indices_per_sb,
+		   resp->pfdev_info.capabilities,
+		   resc->num_rxqs,
+		   resc->num_txqs,
+		   resc->num_sbs,
+		   resc->num_mac_filters,
+		   resc->num_vlan_filters);
+	vf->state = VF_ACQUIRED;
+
+	/* Prepare Response */
+out:
+	qed_iov_prepare_resp(p_hwfn, p_ptt, vf, CHANNEL_TLV_ACQUIRE,
+			     sizeof(struct pfvf_acquire_resp_tlv), vfpf_status);
 }
 
 static void qed_iov_process_mbx_req(struct qed_hwfn *p_hwfn,
@@ -517,7 +867,11 @@ static void qed_iov_process_mbx_req(struct qed_hwfn *p_hwfn,
 
 	/* check if tlv type is known */
 	if (qed_iov_tlv_supported(mbx->first_tlv.tl.type)) {
-		qed_iov_process_mbx_dummy_resp(p_hwfn, p_ptt, p_vf);
+		switch (mbx->first_tlv.tl.type) {
+		case CHANNEL_TLV_ACQUIRE:
+			qed_iov_vf_mbx_acquire(p_hwfn, p_ptt, p_vf);
+			break;
+		}
 	} else {
 		/* unknown TLV - this may belong to a VF driver from the future
 		 * - a version written after this PF driver was written, which
@@ -652,6 +1006,15 @@ void qed_schedule_iov(struct qed_hwfn *hwfn, enum qed_iov_wq_flag flag)
 	queue_delayed_work(hwfn->iov_wq, &hwfn->iov_task, 0);
 }
 
+void qed_vf_start_iov_wq(struct qed_dev *cdev)
+{
+	int i;
+
+	for_each_hwfn(cdev, i)
+	    queue_delayed_work(cdev->hwfns[i].iov_wq,
+			       &cdev->hwfns[i].iov_task, 0);
+}
+
 static void qed_handle_vf_msg(struct qed_hwfn *hwfn)
 {
 	u64 events[QED_VF_ARRAY_LENGTH];
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.h b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
index 1122168..4f190d2 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
@@ -21,6 +21,9 @@
 #endif
 #define IS_PF_SRIOV_ALLOC(p_hwfn)       (!!((p_hwfn)->pf_iov_info))
 
+#define QED_MAX_VF_CHAINS_PER_PF 16
+#define QED_ETH_VF_NUM_VLAN_FILTERS 2
+
 /* This struct is part of qed_dev and contains data relevant to all hwfns;
  * Initialized only if SR-IOV cpabability is exposed in PCIe config space.
  */
@@ -60,7 +63,17 @@ struct qed_iov_vf_mbx {
 	struct vfpf_first_tlv first_tlv;
 };
 
+struct qed_vf_q_info {
+	u16 fw_rx_qid;
+	u16 fw_tx_qid;
+	u8 fw_cid;
+	u8 rxq_active;
+	u8 txq_active;
+};
+
 enum vf_state {
+	VF_FREE = 0,		/* VF ready to be acquired holds no resc */
+	VF_ACQUIRED,		/* VF, acquired, but not initalized */
 	VF_STOPPED		/* VF, Stopped */
 };
 
@@ -82,6 +95,17 @@ struct qed_vf_info {
 #define QED_VF_ABS_ID(p_hwfn, p_vf)	(QED_PATH_ID(p_hwfn) ?		      \
 					 (p_vf)->abs_vf_id + MAX_NUM_VFS_BB : \
 					 (p_vf)->abs_vf_id)
+
+	u8 num_rxqs;
+	u8 num_txqs;
+
+	u8 num_sbs;
+
+	u8 num_mac_filters;
+	u8 num_vlan_filters;
+	struct qed_vf_q_info vf_queues[QED_MAX_VF_CHAINS_PER_PF];
+	u16 igu_sbs[QED_MAX_VF_CHAINS_PER_PF];
+
 };
 
 /* This structure is part of qed_hwfn and used only for PFs that have sriov
@@ -134,6 +158,26 @@ u16 qed_iov_get_next_active_vf(struct qed_hwfn *p_hwfn, u16 rel_vf_id);
 int qed_iov_hw_info(struct qed_hwfn *p_hwfn);
 
 /**
+ * @brief qed_add_tlv - place a given tlv on the tlv buffer at next offset
+ *
+ * @param p_hwfn
+ * @param p_iov
+ * @param type
+ * @param length
+ *
+ * @return pointer to the newly placed tlv
+ */
+void *qed_add_tlv(struct qed_hwfn *p_hwfn, u8 **offset, u16 type, u16 length);
+
+/**
+ * @brief list the types and lengths of the tlvs on the buffer
+ *
+ * @param p_hwfn
+ * @param tlvs_list
+ */
+void qed_dp_tlv_list(struct qed_hwfn *p_hwfn, void *tlvs_list);
+
+/**
  * @brief qed_iov_alloc - allocate sriov related resources
  *
  * @param p_hwfn
@@ -179,6 +223,7 @@ void qed_iov_wq_stop(struct qed_dev *cdev, bool schedule_first);
 int qed_iov_wq_start(struct qed_dev *cdev);
 
 void qed_schedule_iov(struct qed_hwfn *hwfn, enum qed_iov_wq_flag flag);
+void qed_vf_start_iov_wq(struct qed_dev *cdev);
 #else
 static inline u16 qed_iov_get_next_active_vf(struct qed_hwfn *p_hwfn,
 					     u16 rel_vf_id)
@@ -228,6 +273,10 @@ static inline void qed_schedule_iov(struct qed_hwfn *hwfn,
 				    enum qed_iov_wq_flag flag)
 {
 }
+
+static inline void qed_vf_start_iov_wq(struct qed_dev *cdev)
+{
+}
 #endif
 
 #define qed_for_each_vf(_p_hwfn, _i)			  \
diff --git a/drivers/net/ethernet/qlogic/qed/qed_vf.c b/drivers/net/ethernet/qlogic/qed/qed_vf.c
new file mode 100644
index 0000000..a3c8f4e
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qed/qed_vf.c
@@ -0,0 +1,357 @@
+/* QLogic qed NIC Driver
+ * Copyright (c) 2015 QLogic Corporation
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#include "qed.h"
+#include "qed_sriov.h"
+#include "qed_vf.h"
+
+static void *qed_vf_pf_prep(struct qed_hwfn *p_hwfn, u16 type, u16 length)
+{
+	struct qed_vf_iov *p_iov = p_hwfn->vf_iov_info;
+	void *p_tlv;
+
+	/* This lock is released when we receive PF's response
+	 * in qed_send_msg2pf().
+	 * So, qed_vf_pf_prep() and qed_send_msg2pf()
+	 * must come in sequence.
+	 */
+	mutex_lock(&(p_iov->mutex));
+
+	DP_VERBOSE(p_hwfn,
+		   QED_MSG_IOV,
+		   "preparing to send 0x%04x tlv over vf pf channel\n",
+		   type);
+
+	/* Reset Requst offset */
+	p_iov->offset = (u8 *)p_iov->vf2pf_request;
+
+	/* Clear mailbox - both request and reply */
+	memset(p_iov->vf2pf_request, 0, sizeof(union vfpf_tlvs));
+	memset(p_iov->pf2vf_reply, 0, sizeof(union pfvf_tlvs));
+
+	/* Init type and length */
+	p_tlv = qed_add_tlv(p_hwfn, &p_iov->offset, type, length);
+
+	/* Init first tlv header */
+	((struct vfpf_first_tlv *)p_tlv)->reply_address =
+	    (u64)p_iov->pf2vf_reply_phys;
+
+	return p_tlv;
+}
+
+static int qed_send_msg2pf(struct qed_hwfn *p_hwfn, u8 *done, u32 resp_size)
+{
+	union vfpf_tlvs *p_req = p_hwfn->vf_iov_info->vf2pf_request;
+	struct ustorm_trigger_vf_zone trigger;
+	struct ustorm_vf_zone *zone_data;
+	int rc = 0, time = 100;
+
+	zone_data = (struct ustorm_vf_zone *)PXP_VF_BAR0_START_USDM_ZONE_B;
+
+	/* output tlvs list */
+	qed_dp_tlv_list(p_hwfn, p_req);
+
+	/* need to add the END TLV to the message size */
+	resp_size += sizeof(struct channel_list_end_tlv);
+
+	/* Send TLVs over HW channel */
+	memset(&trigger, 0, sizeof(struct ustorm_trigger_vf_zone));
+	trigger.vf_pf_msg_valid = 1;
+
+	DP_VERBOSE(p_hwfn,
+		   QED_MSG_IOV,
+		   "VF -> PF [%02x] message: [%08x, %08x] --> %p, %08x --> %p\n",
+		   GET_FIELD(p_hwfn->hw_info.concrete_fid,
+			     PXP_CONCRETE_FID_PFID),
+		   upper_32_bits(p_hwfn->vf_iov_info->vf2pf_request_phys),
+		   lower_32_bits(p_hwfn->vf_iov_info->vf2pf_request_phys),
+		   &zone_data->non_trigger.vf_pf_msg_addr,
+		   *((u32 *)&trigger), &zone_data->trigger);
+
+	REG_WR(p_hwfn,
+	       (uintptr_t)&zone_data->non_trigger.vf_pf_msg_addr.lo,
+	       lower_32_bits(p_hwfn->vf_iov_info->vf2pf_request_phys));
+
+	REG_WR(p_hwfn,
+	       (uintptr_t)&zone_data->non_trigger.vf_pf_msg_addr.hi,
+	       upper_32_bits(p_hwfn->vf_iov_info->vf2pf_request_phys));
+
+	/* The message data must be written first, to prevent trigger before
+	 * data is written.
+	 */
+	wmb();
+
+	REG_WR(p_hwfn, (uintptr_t)&zone_data->trigger, *((u32 *)&trigger));
+
+	/* When PF would be done with the response, it would write back to the
+	 * `done' address. Poll until then.
+	 */
+	while ((!*done) && time) {
+		msleep(25);
+		time--;
+	}
+
+	if (!*done) {
+		DP_VERBOSE(p_hwfn, QED_MSG_IOV,
+			   "VF <-- PF Timeout [Type %d]\n",
+			   p_req->first_tlv.tl.type);
+		rc = -EBUSY;
+		goto exit;
+	} else {
+		DP_VERBOSE(p_hwfn, QED_MSG_IOV,
+			   "PF response: %d [Type %d]\n",
+			   *done, p_req->first_tlv.tl.type);
+	}
+
+exit:
+	mutex_unlock(&(p_hwfn->vf_iov_info->mutex));
+
+	return rc;
+}
+
+#define VF_ACQUIRE_THRESH 3
+#define VF_ACQUIRE_MAC_FILTERS 1
+
+static int qed_vf_pf_acquire(struct qed_hwfn *p_hwfn)
+{
+	struct qed_vf_iov *p_iov = p_hwfn->vf_iov_info;
+	struct pfvf_acquire_resp_tlv *resp = &p_iov->pf2vf_reply->acquire_resp;
+	struct pf_vf_pfdev_info *pfdev_info = &resp->pfdev_info;
+	u8 rx_count = 1, tx_count = 1, num_sbs = 1;
+	u8 num_mac = VF_ACQUIRE_MAC_FILTERS;
+	bool resources_acquired = false;
+	struct vfpf_acquire_tlv *req;
+	int rc = 0, attempts = 0;
+
+	/* clear mailbox and prep first tlv */
+	req = qed_vf_pf_prep(p_hwfn, CHANNEL_TLV_ACQUIRE, sizeof(*req));
+
+	/* starting filling the request */
+	req->vfdev_info.opaque_fid = p_hwfn->hw_info.opaque_fid;
+
+	req->resc_request.num_rxqs = rx_count;
+	req->resc_request.num_txqs = tx_count;
+	req->resc_request.num_sbs = num_sbs;
+	req->resc_request.num_mac_filters = num_mac;
+	req->resc_request.num_vlan_filters = QED_ETH_VF_NUM_VLAN_FILTERS;
+
+	req->vfdev_info.os_type = VFPF_ACQUIRE_OS_LINUX;
+	req->vfdev_info.fw_major = FW_MAJOR_VERSION;
+	req->vfdev_info.fw_minor = FW_MINOR_VERSION;
+	req->vfdev_info.fw_revision = FW_REVISION_VERSION;
+	req->vfdev_info.fw_engineering = FW_ENGINEERING_VERSION;
+
+	/* Fill capability field with any non-deprecated config we support */
+	req->vfdev_info.capabilities |= VFPF_ACQUIRE_CAP_100G;
+
+	/* pf 2 vf bulletin board address */
+	req->bulletin_addr = p_iov->bulletin.phys;
+	req->bulletin_size = p_iov->bulletin.size;
+
+	/* add list termination tlv */
+	qed_add_tlv(p_hwfn, &p_iov->offset,
+		    CHANNEL_TLV_LIST_END, sizeof(struct channel_list_end_tlv));
+
+	while (!resources_acquired) {
+		DP_VERBOSE(p_hwfn,
+			   QED_MSG_IOV, "attempting to acquire resources\n");
+
+		/* send acquire request */
+		rc = qed_send_msg2pf(p_hwfn, &resp->hdr.status, sizeof(*resp));
+		if (rc)
+			return rc;
+
+		/* copy acquire response from buffer to p_hwfn */
+		memcpy(&p_iov->acquire_resp, resp, sizeof(p_iov->acquire_resp));
+
+		attempts++;
+
+		if (resp->hdr.status == PFVF_STATUS_SUCCESS) {
+			/* PF agrees to allocate our resources */
+			if (!(resp->pfdev_info.capabilities &
+			      PFVF_ACQUIRE_CAP_POST_FW_OVERRIDE)) {
+				DP_INFO(p_hwfn,
+					"PF is using old incompatible driver; Either downgrade driver or request provider to update hypervisor version\n");
+				return -EINVAL;
+			}
+			DP_VERBOSE(p_hwfn, QED_MSG_IOV, "resources acquired\n");
+			resources_acquired = true;
+		} else if (resp->hdr.status == PFVF_STATUS_NO_RESOURCE &&
+			   attempts < VF_ACQUIRE_THRESH) {
+			DP_VERBOSE(p_hwfn,
+				   QED_MSG_IOV,
+				   "PF unwilling to fullfill resource request. Try PF recommended amount\n");
+
+			/* humble our request */
+			req->resc_request.num_txqs = resp->resc.num_txqs;
+			req->resc_request.num_rxqs = resp->resc.num_rxqs;
+			req->resc_request.num_sbs = resp->resc.num_sbs;
+			req->resc_request.num_mac_filters =
+			    resp->resc.num_mac_filters;
+			req->resc_request.num_vlan_filters =
+			    resp->resc.num_vlan_filters;
+
+			/* Clear response buffer */
+			memset(p_iov->pf2vf_reply, 0, sizeof(union pfvf_tlvs));
+		} else {
+			DP_ERR(p_hwfn,
+			       "PF returned error %d to VF acquisition request\n",
+			       resp->hdr.status);
+			return -EAGAIN;
+		}
+	}
+
+	/* Update bulletin board size with response from PF */
+	p_iov->bulletin.size = resp->bulletin_size;
+
+	/* get HW info */
+	p_hwfn->cdev->type = resp->pfdev_info.dev_type;
+	p_hwfn->cdev->chip_rev = resp->pfdev_info.chip_rev;
+
+	p_hwfn->cdev->chip_num = pfdev_info->chip_num & 0xffff;
+
+	/* Learn of the possibility of CMT */
+	if (IS_LEAD_HWFN(p_hwfn)) {
+		if (resp->pfdev_info.capabilities & PFVF_ACQUIRE_CAP_100G) {
+			DP_NOTICE(p_hwfn, "100g VF\n");
+			p_hwfn->cdev->num_hwfns = 2;
+		}
+	}
+
+	return 0;
+}
+
+int qed_vf_hw_prepare(struct qed_hwfn *p_hwfn)
+{
+	struct qed_vf_iov *p_iov;
+	u32 reg;
+
+	/* Set number of hwfns - might be overriden once leading hwfn learns
+	 * actual configuration from PF.
+	 */
+	if (IS_LEAD_HWFN(p_hwfn))
+		p_hwfn->cdev->num_hwfns = 1;
+
+	/* Set the doorbell bar. Assumption: regview is set */
+	p_hwfn->doorbells = (u8 __iomem *)p_hwfn->regview +
+					  PXP_VF_BAR0_START_DQ;
+
+	reg = PXP_VF_BAR0_ME_OPAQUE_ADDRESS;
+	p_hwfn->hw_info.opaque_fid = (u16)REG_RD(p_hwfn, reg);
+
+	reg = PXP_VF_BAR0_ME_CONCRETE_ADDRESS;
+	p_hwfn->hw_info.concrete_fid = REG_RD(p_hwfn, reg);
+
+	/* Allocate vf sriov info */
+	p_iov = kzalloc(sizeof(*p_iov), GFP_KERNEL);
+	if (!p_iov) {
+		DP_NOTICE(p_hwfn, "Failed to allocate `struct qed_sriov'\n");
+		return -ENOMEM;
+	}
+
+	/* Allocate vf2pf msg */
+	p_iov->vf2pf_request = dma_alloc_coherent(&p_hwfn->cdev->pdev->dev,
+						  sizeof(union vfpf_tlvs),
+						  &p_iov->vf2pf_request_phys,
+						  GFP_KERNEL);
+	if (!p_iov->vf2pf_request) {
+		DP_NOTICE(p_hwfn,
+			  "Failed to allocate `vf2pf_request' DMA memory\n");
+		goto free_p_iov;
+	}
+
+	p_iov->pf2vf_reply = dma_alloc_coherent(&p_hwfn->cdev->pdev->dev,
+						sizeof(union pfvf_tlvs),
+						&p_iov->pf2vf_reply_phys,
+						GFP_KERNEL);
+	if (!p_iov->pf2vf_reply) {
+		DP_NOTICE(p_hwfn,
+			  "Failed to allocate `pf2vf_reply' DMA memory\n");
+		goto free_vf2pf_request;
+	}
+
+	DP_VERBOSE(p_hwfn,
+		   QED_MSG_IOV,
+		   "VF's Request mailbox [%p virt 0x%llx phys], Response mailbox [%p virt 0x%llx phys]\n",
+		   p_iov->vf2pf_request,
+		   (u64) p_iov->vf2pf_request_phys,
+		   p_iov->pf2vf_reply, (u64)p_iov->pf2vf_reply_phys);
+
+	/* Allocate Bulletin board */
+	p_iov->bulletin.size = sizeof(struct qed_bulletin_content);
+	p_iov->bulletin.p_virt = dma_alloc_coherent(&p_hwfn->cdev->pdev->dev,
+						    p_iov->bulletin.size,
+						    &p_iov->bulletin.phys,
+						    GFP_KERNEL);
+	DP_VERBOSE(p_hwfn, QED_MSG_IOV,
+		   "VF's bulletin Board [%p virt 0x%llx phys 0x%08x bytes]\n",
+		   p_iov->bulletin.p_virt,
+		   (u64)p_iov->bulletin.phys, p_iov->bulletin.size);
+
+	mutex_init(&p_iov->mutex);
+
+	p_hwfn->vf_iov_info = p_iov;
+
+	p_hwfn->hw_info.personality = QED_PCI_ETH;
+
+	return qed_vf_pf_acquire(p_hwfn);
+
+free_vf2pf_request:
+	dma_free_coherent(&p_hwfn->cdev->pdev->dev,
+			  sizeof(union vfpf_tlvs),
+			  p_iov->vf2pf_request, p_iov->vf2pf_request_phys);
+free_p_iov:
+	kfree(p_iov);
+
+	return -ENOMEM;
+}
+
+u16 qed_vf_get_igu_sb_id(struct qed_hwfn *p_hwfn, u16 sb_id)
+{
+	struct qed_vf_iov *p_iov = p_hwfn->vf_iov_info;
+
+	if (!p_iov) {
+		DP_NOTICE(p_hwfn, "vf_sriov_info isn't initialized\n");
+		return 0;
+	}
+
+	return p_iov->acquire_resp.resc.hw_sbs[sb_id].hw_sb_id;
+}
+
+void qed_vf_get_num_rxqs(struct qed_hwfn *p_hwfn, u8 *num_rxqs)
+{
+	*num_rxqs = p_hwfn->vf_iov_info->acquire_resp.resc.num_rxqs;
+}
+
+void qed_vf_get_port_mac(struct qed_hwfn *p_hwfn, u8 *port_mac)
+{
+	memcpy(port_mac,
+	       p_hwfn->vf_iov_info->acquire_resp.pfdev_info.port_mac, ETH_ALEN);
+}
+
+void qed_vf_get_num_vlan_filters(struct qed_hwfn *p_hwfn, u8 *num_vlan_filters)
+{
+	struct qed_vf_iov *p_vf;
+
+	p_vf = p_hwfn->vf_iov_info;
+	*num_vlan_filters = p_vf->acquire_resp.resc.num_vlan_filters;
+}
+
+void qed_vf_get_fw_version(struct qed_hwfn *p_hwfn,
+			   u16 *fw_major, u16 *fw_minor,
+			   u16 *fw_rev, u16 *fw_eng)
+{
+	struct pf_vf_pfdev_info *info;
+
+	info = &p_hwfn->vf_iov_info->acquire_resp.pfdev_info;
+
+	*fw_major = info->fw_major;
+	*fw_minor = info->fw_minor;
+	*fw_rev = info->fw_rev;
+	*fw_eng = info->fw_eng;
+}
diff --git a/drivers/net/ethernet/qlogic/qed/qed_vf.h b/drivers/net/ethernet/qlogic/qed/qed_vf.h
index a0a68308..839b773 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_vf.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_vf.h
@@ -9,6 +9,22 @@
 #ifndef _QED_VF_H
 #define _QED_VF_H
 
+struct vf_pf_resc_request {
+	u8 num_rxqs;
+	u8 num_txqs;
+	u8 num_sbs;
+	u8 num_mac_filters;
+	u8 num_vlan_filters;
+	u8 num_mc_filters;
+	u16 padding;
+};
+
+struct hw_sb_info {
+	u16 hw_sb_id;
+	u8 sb_qid;
+	u8 padding[5];
+};
+
 enum {
 	PFVF_STATUS_WAITING,
 	PFVF_STATUS_SUCCESS,
@@ -52,6 +68,107 @@ struct channel_list_end_tlv {
 	u8 padding[4];
 };
 
+#define VFPF_ACQUIRE_OS_LINUX (0)
+#define VFPF_ACQUIRE_OS_WINDOWS (1)
+#define VFPF_ACQUIRE_OS_ESX (2)
+#define VFPF_ACQUIRE_OS_SOLARIS (3)
+#define VFPF_ACQUIRE_OS_LINUX_USERSPACE (4)
+
+struct vfpf_acquire_tlv {
+	struct vfpf_first_tlv first_tlv;
+
+	struct vf_pf_vfdev_info {
+#define VFPF_ACQUIRE_CAP_OBSOLETE	(1 << 0)
+#define VFPF_ACQUIRE_CAP_100G		(1 << 1) /* VF can support 100g */
+		aligned_u64 capabilities;
+		u8 fw_major;
+		u8 fw_minor;
+		u8 fw_revision;
+		u8 fw_engineering;
+		u32 driver_version;
+		u16 opaque_fid;	/* ME register value */
+		u8 os_type;	/* VFPF_ACQUIRE_OS_* value */
+		u8 padding[5];
+	} vfdev_info;
+
+	struct vf_pf_resc_request resc_request;
+
+	aligned_u64 bulletin_addr;
+	u32 bulletin_size;
+	u32 padding;
+};
+
+struct pfvf_storm_stats {
+	u32 address;
+	u32 len;
+};
+
+struct pfvf_stats_info {
+	struct pfvf_storm_stats mstats;
+	struct pfvf_storm_stats pstats;
+	struct pfvf_storm_stats tstats;
+	struct pfvf_storm_stats ustats;
+};
+
+struct pfvf_acquire_resp_tlv {
+	struct pfvf_tlv hdr;
+
+	struct pf_vf_pfdev_info {
+		u32 chip_num;
+		u32 mfw_ver;
+
+		u16 fw_major;
+		u16 fw_minor;
+		u16 fw_rev;
+		u16 fw_eng;
+
+		aligned_u64 capabilities;
+#define PFVF_ACQUIRE_CAP_DEFAULT_UNTAGGED	BIT(0)
+#define PFVF_ACQUIRE_CAP_100G			BIT(1)	/* If set, 100g PF */
+/* There are old PF versions where the PF might mistakenly override the sanity
+ * mechanism [version-based] and allow a VF that can't be supported to pass
+ * the acquisition phase.
+ * To overcome this, PFs now indicate that they're past that point and the new
+ * VFs would fail probe on the older PFs that fail to do so.
+ */
+#define PFVF_ACQUIRE_CAP_POST_FW_OVERRIDE	BIT(2)
+
+		u16 db_size;
+		u8 indices_per_sb;
+		u8 os_type;
+
+		/* These should match the PF's qed_dev values */
+		u16 chip_rev;
+		u8 dev_type;
+
+		u8 padding;
+
+		struct pfvf_stats_info stats_info;
+
+		u8 port_mac[ETH_ALEN];
+		u8 padding2[2];
+	} pfdev_info;
+
+	struct pf_vf_resc {
+#define PFVF_MAX_QUEUES_PER_VF		16
+#define PFVF_MAX_SBS_PER_VF		16
+		struct hw_sb_info hw_sbs[PFVF_MAX_SBS_PER_VF];
+		u8 hw_qid[PFVF_MAX_QUEUES_PER_VF];
+		u8 cid[PFVF_MAX_QUEUES_PER_VF];
+
+		u8 num_rxqs;
+		u8 num_txqs;
+		u8 num_sbs;
+		u8 num_mac_filters;
+		u8 num_vlan_filters;
+		u8 num_mc_filters;
+		u8 padding[2];
+	} resc;
+
+	u32 bulletin_size;
+	u32 padding;
+};
+
 #define TLV_BUFFER_SIZE                 1024
 struct tlv_buffer_size {
 	u8 tlv_buffer[TLV_BUFFER_SIZE];
@@ -59,12 +176,14 @@ struct tlv_buffer_size {
 
 union vfpf_tlvs {
 	struct vfpf_first_tlv first_tlv;
+	struct vfpf_acquire_tlv acquire;
 	struct channel_list_end_tlv list_end;
 	struct tlv_buffer_size tlv_buf_size;
 };
 
 union pfvf_tlvs {
 	struct pfvf_def_resp_tlv default_resp;
+	struct pfvf_acquire_resp_tlv acquire_resp;
 	struct tlv_buffer_size tlv_buf_size;
 };
 
@@ -86,8 +205,118 @@ struct qed_bulletin {
 
 enum {
 	CHANNEL_TLV_NONE,	/* ends tlv sequence */
+	CHANNEL_TLV_ACQUIRE,
 	CHANNEL_TLV_LIST_END,
 	CHANNEL_TLV_MAX
 };
 
+/* This data is held in the qed_hwfn structure for VFs only. */
+struct qed_vf_iov {
+	union vfpf_tlvs *vf2pf_request;
+	dma_addr_t vf2pf_request_phys;
+	union pfvf_tlvs *pf2vf_reply;
+	dma_addr_t pf2vf_reply_phys;
+
+	/* Should be taken whenever the mailbox buffers are accessed */
+	struct mutex mutex;
+	u8 *offset;
+
+	/* Bulletin Board */
+	struct qed_bulletin bulletin;
+	struct qed_bulletin_content bulletin_shadow;
+
+	/* we set aside a copy of the acquire response */
+	struct pfvf_acquire_resp_tlv acquire_resp;
+};
+
+#ifdef CONFIG_QED_SRIOV
+/**
+ * @brief Get number of Rx queues allocated for VF by qed
+ *
+ *  @param p_hwfn
+ *  @param num_rxqs - allocated RX queues
+ */
+void qed_vf_get_num_rxqs(struct qed_hwfn *p_hwfn, u8 *num_rxqs);
+
+/**
+ * @brief Get port mac address for VF
+ *
+ * @param p_hwfn
+ * @param port_mac - destination location for port mac
+ */
+void qed_vf_get_port_mac(struct qed_hwfn *p_hwfn, u8 *port_mac);
+
+/**
+ * @brief Get number of VLAN filters allocated for VF by qed
+ *
+ *  @param p_hwfn
+ *  @param num_rxqs - allocated VLAN filters
+ */
+void qed_vf_get_num_vlan_filters(struct qed_hwfn *p_hwfn,
+				 u8 *num_vlan_filters);
+
+/**
+ * @brief Set firmware version information in dev_info from VFs acquire response tlv
+ *
+ * @param p_hwfn
+ * @param fw_major
+ * @param fw_minor
+ * @param fw_rev
+ * @param fw_eng
+ */
+void qed_vf_get_fw_version(struct qed_hwfn *p_hwfn,
+			   u16 *fw_major, u16 *fw_minor,
+			   u16 *fw_rev, u16 *fw_eng);
+
+/**
+ * @brief hw preparation for VF
+ *      sends ACQUIRE message
+ *
+ * @param p_hwfn
+ *
+ * @return int
+ */
+int qed_vf_hw_prepare(struct qed_hwfn *p_hwfn);
+
+/**
+ * @brief qed_vf_get_igu_sb_id - Get the IGU SB ID for a given
+ *        sb_id. For VFs igu sbs don't have to be contiguous
+ *
+ * @param p_hwfn
+ * @param sb_id
+ *
+ * @return INLINE u16
+ */
+u16 qed_vf_get_igu_sb_id(struct qed_hwfn *p_hwfn, u16 sb_id);
+#else
+static inline void qed_vf_get_num_rxqs(struct qed_hwfn *p_hwfn, u8 *num_rxqs)
+{
+}
+
+static inline void qed_vf_get_port_mac(struct qed_hwfn *p_hwfn, u8 *port_mac)
+{
+}
+
+static inline void qed_vf_get_num_vlan_filters(struct qed_hwfn *p_hwfn,
+					       u8 *num_vlan_filters)
+{
+}
+
+static inline void qed_vf_get_fw_version(struct qed_hwfn *p_hwfn,
+					 u16 *fw_major, u16 *fw_minor,
+					 u16 *fw_rev, u16 *fw_eng)
+{
+}
+
+static inline int qed_vf_hw_prepare(struct qed_hwfn *p_hwfn)
+{
+	return -EINVAL;
+}
+
+static inline u16 qed_vf_get_igu_sb_id(struct qed_hwfn *p_hwfn, u16 sb_id)
+{
+	return 0;
+}
+#endif
+
 #endif
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 82d85cc..04b15ad 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -2285,8 +2285,9 @@ enum qede_probe_mode {
 };
 
 static int __qede_probe(struct pci_dev *pdev, u32 dp_module, u8 dp_level,
-			enum qede_probe_mode mode)
+			bool is_vf, enum qede_probe_mode mode)
 {
+	struct qed_probe_params probe_params;
 	struct qed_slowpath_params params;
 	struct qed_dev_eth_info dev_info;
 	struct qede_dev *edev;
@@ -2296,8 +2297,12 @@ static int __qede_probe(struct pci_dev *pdev, u32 dp_module, u8 dp_level,
 	if (unlikely(dp_level & QED_LEVEL_INFO))
 		pr_notice("Starting qede probe\n");
 
-	cdev = qed_ops->common->probe(pdev, QED_PROTOCOL_ETH,
-				      dp_module, dp_level);
+	memset(&probe_params, 0, sizeof(probe_params));
+	probe_params.protocol = QED_PROTOCOL_ETH;
+	probe_params.dp_module = dp_module;
+	probe_params.dp_level = dp_level;
+	probe_params.is_vf = is_vf;
+	cdev = qed_ops->common->probe(pdev, &probe_params);
 	if (!cdev) {
 		rc = -ENODEV;
 		goto err0;
@@ -2367,7 +2372,7 @@ static int qede_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 
 	qede_config_debug(debug, &dp_module, &dp_level);
 
-	return __qede_probe(pdev, dp_module, dp_level,
+	return __qede_probe(pdev, dp_module, dp_level, false,
 			    QEDE_PROBE_NORMAL);
 }
 
diff --git a/include/linux/qed/common_hsi.h b/include/linux/qed/common_hsi.h
index 8914d27..3f14c7e 100644
--- a/include/linux/qed/common_hsi.h
+++ b/include/linux/qed/common_hsi.h
@@ -285,6 +285,63 @@
 #define PXP_ILT_PAGE_SIZE_NUM_BITS_MIN	12
 #define PXP_ILT_BLOCK_FACTOR_MULTIPLIER	1024
 
+#define PXP_VF_BAR0_START_IGU                   0
+#define PXP_VF_BAR0_IGU_LENGTH                  0x3000
+#define PXP_VF_BAR0_END_IGU                     (PXP_VF_BAR0_START_IGU + \
+						 PXP_VF_BAR0_IGU_LENGTH - 1)
+
+#define PXP_VF_BAR0_START_DQ                    0x3000
+#define PXP_VF_BAR0_DQ_LENGTH                   0x200
+#define PXP_VF_BAR0_DQ_OPAQUE_OFFSET            0
+#define PXP_VF_BAR0_ME_OPAQUE_ADDRESS           (PXP_VF_BAR0_START_DQ +	\
+						 PXP_VF_BAR0_DQ_OPAQUE_OFFSET)
+#define PXP_VF_BAR0_ME_CONCRETE_ADDRESS         (PXP_VF_BAR0_ME_OPAQUE_ADDRESS \
+						 + 4)
+#define PXP_VF_BAR0_END_DQ                      (PXP_VF_BAR0_START_DQ +	\
+						 PXP_VF_BAR0_DQ_LENGTH - 1)
+
+#define PXP_VF_BAR0_START_TSDM_ZONE_B           0x3200
+#define PXP_VF_BAR0_SDM_LENGTH_ZONE_B           0x200
+#define PXP_VF_BAR0_END_TSDM_ZONE_B             (PXP_VF_BAR0_START_TSDM_ZONE_B \
+						 +			       \
+						 PXP_VF_BAR0_SDM_LENGTH_ZONE_B \
+						 - 1)
+
+#define PXP_VF_BAR0_START_MSDM_ZONE_B           0x3400
+#define PXP_VF_BAR0_END_MSDM_ZONE_B             (PXP_VF_BAR0_START_MSDM_ZONE_B \
+						 +			       \
+						 PXP_VF_BAR0_SDM_LENGTH_ZONE_B \
+						 - 1)
+
+#define PXP_VF_BAR0_START_USDM_ZONE_B           0x3600
+#define PXP_VF_BAR0_END_USDM_ZONE_B             (PXP_VF_BAR0_START_USDM_ZONE_B \
+						 +			       \
+						 PXP_VF_BAR0_SDM_LENGTH_ZONE_B \
+						 - 1)
+
+#define PXP_VF_BAR0_START_XSDM_ZONE_B           0x3800
+#define PXP_VF_BAR0_END_XSDM_ZONE_B             (PXP_VF_BAR0_START_XSDM_ZONE_B \
+						 +			       \
+						 PXP_VF_BAR0_SDM_LENGTH_ZONE_B \
+						 - 1)
+
+#define PXP_VF_BAR0_START_YSDM_ZONE_B           0x3a00
+#define PXP_VF_BAR0_END_YSDM_ZONE_B             (PXP_VF_BAR0_START_YSDM_ZONE_B \
+						 +			       \
+						 PXP_VF_BAR0_SDM_LENGTH_ZONE_B \
+						 - 1)
+
+#define PXP_VF_BAR0_START_PSDM_ZONE_B           0x3c00
+#define PXP_VF_BAR0_END_PSDM_ZONE_B             (PXP_VF_BAR0_START_PSDM_ZONE_B \
+						 +			       \
+						 PXP_VF_BAR0_SDM_LENGTH_ZONE_B \
+						 - 1)
+
+#define PXP_VF_BAR0_START_SDM_ZONE_A            0x4000
+#define PXP_VF_BAR0_END_SDM_ZONE_A              0x10000
+
+#define PXP_VF_BAR0_GRC_WINDOW_LENGTH           32
+
 /* ILT Records */
 #define PXP_NUM_ILT_RECORDS_BB 7600
 #define PXP_NUM_ILT_RECORDS_K2 11000
diff --git a/include/linux/qed/qed_if.h b/include/linux/qed/qed_if.h
index d72c832..76a6f16 100644
--- a/include/linux/qed/qed_if.h
+++ b/include/linux/qed/qed_if.h
@@ -140,6 +140,13 @@ struct qed_link_output {
 	u32	pause_config;
 };
 
+struct qed_probe_params {
+	enum qed_protocol protocol;
+	u32 dp_module;
+	u8 dp_level;
+	bool is_vf;
+};
+
 #define QED_DRV_VER_STR_SIZE 12
 struct qed_slowpath_params {
 	u32	int_mode;
@@ -207,8 +214,7 @@ struct qed_common_ops {
 	struct qed_selftest_ops *selftest;
 
 	struct qed_dev*	(*probe)(struct pci_dev *dev,
-				 enum qed_protocol protocol,
-				 u32 dp_module, u8 dp_level);
+				 struct qed_probe_params *params);
 
 	void		(*remove)(struct qed_dev *cdev);
 
-- 
1.9.3
