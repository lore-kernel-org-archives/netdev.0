From: Baoyou Xie <baoyou.xie@linaro.org>
Subject: [PATCH 2/2] qed: remove unused function in qed_cxt.c
Date: Fri, 30 Sep 2016 16:02:54 +0800
Message-ID: <1475222574-19280-1-git-send-email-baoyou.xie@linaro.org>
Cc: everest-linux-l2@qlogic.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, arnd@arndb.de, baoyou.xie@linaro.org,
        xie.baoyou@zte.com.cn, han.fei@zte.com.cn, tang.qiang007@zte.com.cn
To: Yuval.Mintz@qlogic.com, Ariel.Elior@qlogic.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We get 3 warnings when building kernel with W=1:
drivers/net/ethernet/qlogic/qed/qed_cxt.c:1941:1: warning: no previous prototype for 'qed_cxt_dynamic_ilt_alloc' [-Wmissing-prototypes]
drivers/net/ethernet/qlogic/qed/qed_cxt.c:2158:5: warning: no previous prototype for 'qed_cxt_free_proto_ilt' [-Wmissing-prototypes]
drivers/net/ethernet/qlogic/qed/qed_cxt.c:2186:5: warning: no previous prototype for 'qed_cxt_get_task_ctx' [-Wmissing-prototypes]

In fact, these functions are unused in
drivers/net/ethernet/qlogic/qed/qed_cxt.c, but should be removed.

So this patch removes these unused functions.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/net/ethernet/qlogic/qed/qed_cxt.c | 319 ------------------------------
 1 file changed, 319 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_cxt.c b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
index d7e9b14..f12c7ea 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_cxt.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
@@ -386,24 +386,6 @@ u32 qed_cxt_get_proto_cid_count(struct qed_hwfn *p_hwfn,
 	return p_hwfn->p_cxt_mngr->conn_cfg[type].cid_count;
 }
 
-static u32 qed_cxt_get_proto_cid_start(struct qed_hwfn *p_hwfn,
-				       enum protocol_type type)
-{
-	return p_hwfn->p_cxt_mngr->acquired[type].start_cid;
-}
-
-static u32 qed_cxt_get_proto_tid_count(struct qed_hwfn *p_hwfn,
-				       enum protocol_type type)
-{
-	u32 cnt = 0;
-	int i;
-
-	for (i = 0; i < TASK_SEGMENTS; i++)
-		cnt += p_hwfn->p_cxt_mngr->conn_cfg[type].tid_seg[i].count;
-
-	return cnt;
-}
-
 static void qed_cxt_set_proto_tid_count(struct qed_hwfn *p_hwfn,
 					enum protocol_type proto,
 					u8 seg,
@@ -1933,304 +1915,3 @@ int qed_cxt_get_tid_mem_info(struct qed_hwfn *p_hwfn,
 
 	return 0;
 }
-
-/* This function is very RoCE oriented, if another protocol in the future
- * will want this feature we'll need to modify the function to be more generic
- */
-int
-qed_cxt_dynamic_ilt_alloc(struct qed_hwfn *p_hwfn,
-			  enum qed_cxt_elem_type elem_type, u32 iid)
-{
-	u32 reg_offset, shadow_line, elem_size, hw_p_size, elems_per_p, line;
-	struct qed_ilt_client_cfg *p_cli;
-	struct qed_ilt_cli_blk *p_blk;
-	struct qed_ptt *p_ptt;
-	dma_addr_t p_phys;
-	u64 ilt_hw_entry;
-	void *p_virt;
-	int rc = 0;
-
-	switch (elem_type) {
-	case QED_ELEM_CXT:
-		p_cli = &p_hwfn->p_cxt_mngr->clients[ILT_CLI_CDUC];
-		elem_size = CONN_CXT_SIZE(p_hwfn);
-		p_blk = &p_cli->pf_blks[CDUC_BLK];
-		break;
-	case QED_ELEM_SRQ:
-		p_cli = &p_hwfn->p_cxt_mngr->clients[ILT_CLI_TSDM];
-		elem_size = SRQ_CXT_SIZE;
-		p_blk = &p_cli->pf_blks[SRQ_BLK];
-		break;
-	case QED_ELEM_TASK:
-		p_cli = &p_hwfn->p_cxt_mngr->clients[ILT_CLI_CDUT];
-		elem_size = TYPE1_TASK_CXT_SIZE(p_hwfn);
-		p_blk = &p_cli->pf_blks[CDUT_SEG_BLK(QED_CXT_ROCE_TID_SEG)];
-		break;
-	default:
-		DP_NOTICE(p_hwfn, "-EINVALID elem type = %d", elem_type);
-		return -EINVAL;
-	}
-
-	/* Calculate line in ilt */
-	hw_p_size = p_cli->p_size.val;
-	elems_per_p = ILT_PAGE_IN_BYTES(hw_p_size) / elem_size;
-	line = p_blk->start_line + (iid / elems_per_p);
-	shadow_line = line - p_hwfn->p_cxt_mngr->pf_start_line;
-
-	/* If line is already allocated, do nothing, otherwise allocate it and
-	 * write it to the PSWRQ2 registers.
-	 * This section can be run in parallel from different contexts and thus
-	 * a mutex protection is needed.
-	 */
-
-	mutex_lock(&p_hwfn->p_cxt_mngr->mutex);
-
-	if (p_hwfn->p_cxt_mngr->ilt_shadow[shadow_line].p_virt)
-		goto out0;
-
-	p_ptt = qed_ptt_acquire(p_hwfn);
-	if (!p_ptt) {
-		DP_NOTICE(p_hwfn,
-			  "QED_TIME_OUT on ptt acquire - dynamic allocation");
-		rc = -EBUSY;
-		goto out0;
-	}
-
-	p_virt = dma_alloc_coherent(&p_hwfn->cdev->pdev->dev,
-				    p_blk->real_size_in_page,
-				    &p_phys, GFP_KERNEL);
-	if (!p_virt) {
-		rc = -ENOMEM;
-		goto out1;
-	}
-	memset(p_virt, 0, p_blk->real_size_in_page);
-
-	/* configuration of refTagMask to 0xF is required for RoCE DIF MR only,
-	 * to compensate for a HW bug, but it is configured even if DIF is not
-	 * enabled. This is harmless and allows us to avoid a dedicated API. We
-	 * configure the field for all of the contexts on the newly allocated
-	 * page.
-	 */
-	if (elem_type == QED_ELEM_TASK) {
-		u32 elem_i;
-		u8 *elem_start = (u8 *)p_virt;
-		union type1_task_context *elem;
-
-		for (elem_i = 0; elem_i < elems_per_p; elem_i++) {
-			elem = (union type1_task_context *)elem_start;
-			SET_FIELD(elem->roce_ctx.tdif_context.flags1,
-				  TDIF_TASK_CONTEXT_REFTAGMASK, 0xf);
-			elem_start += TYPE1_TASK_CXT_SIZE(p_hwfn);
-		}
-	}
-
-	p_hwfn->p_cxt_mngr->ilt_shadow[shadow_line].p_virt = p_virt;
-	p_hwfn->p_cxt_mngr->ilt_shadow[shadow_line].p_phys = p_phys;
-	p_hwfn->p_cxt_mngr->ilt_shadow[shadow_line].size =
-	    p_blk->real_size_in_page;
-
-	/* compute absolute offset */
-	reg_offset = PSWRQ2_REG_ILT_MEMORY +
-	    (line * ILT_REG_SIZE_IN_BYTES * ILT_ENTRY_IN_REGS);
-
-	ilt_hw_entry = 0;
-	SET_FIELD(ilt_hw_entry, ILT_ENTRY_VALID, 1ULL);
-	SET_FIELD(ilt_hw_entry,
-		  ILT_ENTRY_PHY_ADDR,
-		  (p_hwfn->p_cxt_mngr->ilt_shadow[shadow_line].p_phys >> 12));
-
-	/* Write via DMAE since the PSWRQ2_REG_ILT_MEMORY line is a wide-bus */
-	qed_dmae_host2grc(p_hwfn, p_ptt, (u64) (uintptr_t)&ilt_hw_entry,
-			  reg_offset, sizeof(ilt_hw_entry) / sizeof(u32), 0);
-
-	if (elem_type == QED_ELEM_CXT) {
-		u32 last_cid_allocated = (1 + (iid / elems_per_p)) *
-		    elems_per_p;
-
-		/* Update the relevant register in the parser */
-		qed_wr(p_hwfn, p_ptt, PRS_REG_ROCE_DEST_QP_MAX_PF,
-		       last_cid_allocated - 1);
-
-		if (!p_hwfn->b_rdma_enabled_in_prs) {
-			/* Enable RoCE search */
-			qed_wr(p_hwfn, p_ptt, p_hwfn->rdma_prs_search_reg, 1);
-			p_hwfn->b_rdma_enabled_in_prs = true;
-		}
-	}
-
-out1:
-	qed_ptt_release(p_hwfn, p_ptt);
-out0:
-	mutex_unlock(&p_hwfn->p_cxt_mngr->mutex);
-
-	return rc;
-}
-
-/* This function is very RoCE oriented, if another protocol in the future
- * will want this feature we'll need to modify the function to be more generic
- */
-static int
-qed_cxt_free_ilt_range(struct qed_hwfn *p_hwfn,
-		       enum qed_cxt_elem_type elem_type,
-		       u32 start_iid, u32 count)
-{
-	u32 start_line, end_line, shadow_start_line, shadow_end_line;
-	u32 reg_offset, elem_size, hw_p_size, elems_per_p;
-	struct qed_ilt_client_cfg *p_cli;
-	struct qed_ilt_cli_blk *p_blk;
-	u32 end_iid = start_iid + count;
-	struct qed_ptt *p_ptt;
-	u64 ilt_hw_entry = 0;
-	u32 i;
-
-	switch (elem_type) {
-	case QED_ELEM_CXT:
-		p_cli = &p_hwfn->p_cxt_mngr->clients[ILT_CLI_CDUC];
-		elem_size = CONN_CXT_SIZE(p_hwfn);
-		p_blk = &p_cli->pf_blks[CDUC_BLK];
-		break;
-	case QED_ELEM_SRQ:
-		p_cli = &p_hwfn->p_cxt_mngr->clients[ILT_CLI_TSDM];
-		elem_size = SRQ_CXT_SIZE;
-		p_blk = &p_cli->pf_blks[SRQ_BLK];
-		break;
-	case QED_ELEM_TASK:
-		p_cli = &p_hwfn->p_cxt_mngr->clients[ILT_CLI_CDUT];
-		elem_size = TYPE1_TASK_CXT_SIZE(p_hwfn);
-		p_blk = &p_cli->pf_blks[CDUT_SEG_BLK(QED_CXT_ROCE_TID_SEG)];
-		break;
-	default:
-		DP_NOTICE(p_hwfn, "-EINVALID elem type = %d", elem_type);
-		return -EINVAL;
-	}
-
-	/* Calculate line in ilt */
-	hw_p_size = p_cli->p_size.val;
-	elems_per_p = ILT_PAGE_IN_BYTES(hw_p_size) / elem_size;
-	start_line = p_blk->start_line + (start_iid / elems_per_p);
-	end_line = p_blk->start_line + (end_iid / elems_per_p);
-	if (((end_iid + 1) / elems_per_p) != (end_iid / elems_per_p))
-		end_line--;
-
-	shadow_start_line = start_line - p_hwfn->p_cxt_mngr->pf_start_line;
-	shadow_end_line = end_line - p_hwfn->p_cxt_mngr->pf_start_line;
-
-	p_ptt = qed_ptt_acquire(p_hwfn);
-	if (!p_ptt) {
-		DP_NOTICE(p_hwfn,
-			  "QED_TIME_OUT on ptt acquire - dynamic allocation");
-		return -EBUSY;
-	}
-
-	for (i = shadow_start_line; i < shadow_end_line; i++) {
-		if (!p_hwfn->p_cxt_mngr->ilt_shadow[i].p_virt)
-			continue;
-
-		dma_free_coherent(&p_hwfn->cdev->pdev->dev,
-				  p_hwfn->p_cxt_mngr->ilt_shadow[i].size,
-				  p_hwfn->p_cxt_mngr->ilt_shadow[i].p_virt,
-				  p_hwfn->p_cxt_mngr->ilt_shadow[i].p_phys);
-
-		p_hwfn->p_cxt_mngr->ilt_shadow[i].p_virt = NULL;
-		p_hwfn->p_cxt_mngr->ilt_shadow[i].p_phys = 0;
-		p_hwfn->p_cxt_mngr->ilt_shadow[i].size = 0;
-
-		/* compute absolute offset */
-		reg_offset = PSWRQ2_REG_ILT_MEMORY +
-		    ((start_line++) * ILT_REG_SIZE_IN_BYTES *
-		     ILT_ENTRY_IN_REGS);
-
-		/* Write via DMAE since the PSWRQ2_REG_ILT_MEMORY line is a
-		 * wide-bus.
-		 */
-		qed_dmae_host2grc(p_hwfn, p_ptt,
-				  (u64) (uintptr_t) &ilt_hw_entry,
-				  reg_offset,
-				  sizeof(ilt_hw_entry) / sizeof(u32),
-				  0);
-	}
-
-	qed_ptt_release(p_hwfn, p_ptt);
-
-	return 0;
-}
-
-int qed_cxt_free_proto_ilt(struct qed_hwfn *p_hwfn, enum protocol_type proto)
-{
-	int rc;
-	u32 cid;
-
-	/* Free Connection CXT */
-	rc = qed_cxt_free_ilt_range(p_hwfn, QED_ELEM_CXT,
-				    qed_cxt_get_proto_cid_start(p_hwfn,
-								proto),
-				    qed_cxt_get_proto_cid_count(p_hwfn,
-								proto, &cid));
-
-	if (rc)
-		return rc;
-
-	/* Free Task CXT */
-	rc = qed_cxt_free_ilt_range(p_hwfn, QED_ELEM_TASK, 0,
-				    qed_cxt_get_proto_tid_count(p_hwfn, proto));
-	if (rc)
-		return rc;
-
-	/* Free TSDM CXT */
-	rc = qed_cxt_free_ilt_range(p_hwfn, QED_ELEM_SRQ, 0,
-				    qed_cxt_get_srq_count(p_hwfn));
-
-	return rc;
-}
-
-int qed_cxt_get_task_ctx(struct qed_hwfn *p_hwfn,
-			 u32 tid, u8 ctx_type, void **pp_task_ctx)
-{
-	struct qed_cxt_mngr *p_mngr = p_hwfn->p_cxt_mngr;
-	struct qed_ilt_client_cfg *p_cli;
-	struct qed_ilt_cli_blk *p_seg;
-	struct qed_tid_seg *p_seg_info;
-	u32 proto, seg;
-	u32 total_lines;
-	u32 tid_size, ilt_idx;
-	u32 num_tids_per_block;
-
-	/* Verify the personality */
-	switch (p_hwfn->hw_info.personality) {
-	case QED_PCI_ISCSI:
-		proto = PROTOCOLID_ISCSI;
-		seg = QED_CXT_ISCSI_TID_SEG;
-		break;
-	default:
-		return -EINVAL;
-	}
-
-	p_cli = &p_mngr->clients[ILT_CLI_CDUT];
-	if (!p_cli->active)
-		return -EINVAL;
-
-	p_seg_info = &p_mngr->conn_cfg[proto].tid_seg[seg];
-
-	if (ctx_type == QED_CTX_WORKING_MEM) {
-		p_seg = &p_cli->pf_blks[CDUT_SEG_BLK(seg)];
-	} else if (ctx_type == QED_CTX_FL_MEM) {
-		if (!p_seg_info->has_fl_mem)
-			return -EINVAL;
-		p_seg = &p_cli->pf_blks[CDUT_FL_SEG_BLK(seg, PF)];
-	} else {
-		return -EINVAL;
-	}
-	total_lines = DIV_ROUND_UP(p_seg->total_size, p_seg->real_size_in_page);
-	tid_size = p_mngr->task_type_size[p_seg_info->type];
-	num_tids_per_block = p_seg->real_size_in_page / tid_size;
-
-	if (total_lines < tid / num_tids_per_block)
-		return -EINVAL;
-
-	ilt_idx = tid / num_tids_per_block + p_seg->start_line -
-		  p_mngr->pf_start_line;
-	*pp_task_ctx = (u8 *)p_mngr->ilt_shadow[ilt_idx].p_virt +
-		       (tid % num_tids_per_block) * tid_size;
-
-	return 0;
-}
-- 
2.7.4
