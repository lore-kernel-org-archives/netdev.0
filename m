From: Selvin Xavier <selvin.xavier@broadcom.com>
Subject: [PATCH V2  04/22] bnxt_re: Enabling RoCE control path
Date: Thu,  8 Dec 2016 22:47:58 -0800
Message-ID: <1481266096-23331-5-git-send-email-selvin.xavier@broadcom.com>
References: <1481266096-23331-1-git-send-email-selvin.xavier@broadcom.com>
Cc: netdev@vger.kernel.org, Selvin Xavier <selvin.xavier@broadcom.com>,
        Eddie Wai <eddie.wai@broadcom.com>,
        Devesh Sharma <devesh.sharma@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
To: dledford@redhat.com, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lpdvsmtp01.broadcom.com ([192.19.211.62]:45702 "EHLO
        relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752881AbcLIGs3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 01:48:29 -0500
In-Reply-To: <1481266096-23331-1-git-send-email-selvin.xavier@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements the basic initialization for RocE HW interface.
Some of the slow path FW commands required for the HW intialization
are implemented. It also handles registration with the IB stack.

v2: Fix some of the sparse warnings

Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
Signed-off-by: Devesh Sharma <devesh.sharma@broadcom.com>
Signed-off-by: Somnath Kotur <somnath.kotur@broadcom.com>
Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Signed-off-by: Selvin Xavier <selvin.xavier@broadcom.com>
---
 drivers/infiniband/hw/bnxtre/bnxt_qplib_rcfw.c | 599 ++++++++++++++++++++
 drivers/infiniband/hw/bnxtre/bnxt_qplib_rcfw.h | 176 ++++++
 drivers/infiniband/hw/bnxtre/bnxt_qplib_res.c  | 740 +++++++++++++++++++++++++
 drivers/infiniband/hw/bnxtre/bnxt_qplib_res.h  | 165 ++++++
 drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.c   | 163 ++++++
 drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.h   |  42 ++
 drivers/infiniband/hw/bnxtre/bnxt_re.h         |  15 +
 drivers/infiniband/hw/bnxtre/bnxt_re_main.c    | 433 ++++++++++++++-
 8 files changed, 2326 insertions(+), 7 deletions(-)

diff --git a/drivers/infiniband/hw/bnxtre/bnxt_qplib_rcfw.c b/drivers/infiniband/hw/bnxtre/bnxt_qplib_rcfw.c
index 4029935..5b71acd 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_qplib_rcfw.c
+++ b/drivers/infiniband/hw/bnxtre/bnxt_qplib_rcfw.c
@@ -35,3 +35,602 @@
  *
  * Description: RDMA Controller HW interface
  */
+#include <linux/interrupt.h>
+#include <linux/spinlock.h>
+#include <linux/pci.h>
+#include "bnxt_re_hsi.h"
+#include "bnxt_qplib_res.h"
+#include "bnxt_qplib_rcfw.h"
+static void bnxt_qplib_service_creq(unsigned long data);
+
+/* Hardware communication channel */
+int bnxt_qplib_rcfw_wait_for_resp(struct bnxt_qplib_rcfw *rcfw, u16 cookie)
+{
+	u16 cbit;
+	int rc;
+
+	cookie &= RCFW_MAX_COOKIE_VALUE;
+	cbit = cookie % RCFW_MAX_OUTSTANDING_CMD;
+	if (!test_bit(cbit, rcfw->cmdq_bitmap))
+		dev_warn(&rcfw->pdev->dev,
+			 "QPLIB: CMD bit %d for cookie 0x%x is not set?",
+			 cbit, cookie);
+
+	rc = wait_event_timeout(rcfw->waitq,
+				!test_bit(cbit, rcfw->cmdq_bitmap),
+				msecs_to_jiffies(RCFW_CMD_WAIT_TIME_MS));
+	if (!rc) {
+		dev_warn(&rcfw->pdev->dev,
+			 "QPLIB: Bono Error: timeout %d msec, msg {0x%x}\n",
+			 RCFW_CMD_WAIT_TIME_MS, cookie);
+	}
+
+	return rc;
+};
+
+int bnxt_qplib_rcfw_block_for_resp(struct bnxt_qplib_rcfw *rcfw, u16 cookie)
+{
+	u32 count = -1;
+	u16 cbit;
+
+	cookie &= RCFW_MAX_COOKIE_VALUE;
+	cbit = cookie % RCFW_MAX_OUTSTANDING_CMD;
+	if (!test_bit(cbit, rcfw->cmdq_bitmap))
+		goto done;
+	do {
+		bnxt_qplib_service_creq((unsigned long)rcfw);
+	} while (test_bit(cbit, rcfw->cmdq_bitmap) && --count);
+done:
+	return count;
+};
+
+void *bnxt_qplib_rcfw_send_message(struct bnxt_qplib_rcfw *rcfw,
+				   struct cmdq_base *req, void **crsbe,
+				   u8 is_block)
+{
+	struct bnxt_qplib_crsq *crsq = &rcfw->crsq;
+	struct bnxt_qplib_cmdqe *cmdqe, **cmdq_ptr;
+	struct bnxt_qplib_hwq *cmdq = &rcfw->cmdq;
+	struct bnxt_qplib_hwq *crsb = &rcfw->crsb;
+	struct bnxt_qplib_crsqe *crsqe = NULL;
+	struct bnxt_qplib_crsbe **crsb_ptr;
+	u32 sw_prod, cmdq_prod;
+	dma_addr_t dma_addr;
+	unsigned long flags;
+	u32 size, opcode;
+	u16 cookie, cbit;
+	int pg, idx;
+	u8 *preq;
+
+retry:
+	opcode = req->opcode;
+	if (!test_bit(FIRMWARE_INITIALIZED_FLAG, &rcfw->flags) &&
+	    (opcode != CMDQ_BASE_OPCODE_QUERY_FUNC &&
+	     opcode != CMDQ_BASE_OPCODE_INITIALIZE_FW)) {
+		dev_err(&rcfw->pdev->dev,
+			"QPLIB: RCFW not initialized, reject opcode 0x%x",
+			opcode);
+		return NULL;
+	}
+
+	if (test_bit(FIRMWARE_INITIALIZED_FLAG, &rcfw->flags) &&
+	    opcode == CMDQ_BASE_OPCODE_INITIALIZE_FW) {
+		dev_err(&rcfw->pdev->dev, "QPLIB: RCFW already initialized!");
+		return NULL;
+	}
+
+	/* Cmdq are in 16-byte units, each request can consume 1 or more
+	 * cmdqe
+	 */
+	spin_lock_irqsave(&cmdq->lock, flags);
+	if (req->cmd_size > cmdq->max_elements -
+	    ((HWQ_CMP(cmdq->prod, cmdq) - HWQ_CMP(cmdq->cons, cmdq)) &
+	     (cmdq->max_elements - 1))) {
+		dev_err(&rcfw->pdev->dev, "QPLIB: RCFW: CMDQ is full!");
+		spin_unlock_irqrestore(&cmdq->lock, flags);
+		goto retry;
+	}
+
+	cookie = atomic_inc_return(&rcfw->seq_num) & RCFW_MAX_COOKIE_VALUE;
+	cbit = cookie % RCFW_MAX_OUTSTANDING_CMD;
+	if (is_block)
+		cookie |= RCFW_CMD_IS_BLOCKING;
+	req->cookie = cpu_to_le16(cookie);
+	if (test_and_set_bit(cbit, rcfw->cmdq_bitmap)) {
+		dev_err(&rcfw->pdev->dev,
+			"QPLIB: RCFW MAX outstanding cmd reached!");
+		atomic_dec(&rcfw->seq_num);
+		spin_unlock_irqrestore(&cmdq->lock, flags);
+		goto retry;
+	}
+	/* Reserve a resp buffer slot if requested */
+	if (req->resp_size && crsbe) {
+		spin_lock_irqsave(&crsb->lock, flags);
+		sw_prod = HWQ_CMP(crsb->prod, crsb);
+		crsb_ptr = (struct bnxt_qplib_crsbe **)crsb->pbl_ptr;
+		*crsbe = (void *)&crsb_ptr[CRSB_PG(sw_prod)][CRSB_IDX(sw_prod)];
+		BNXT_QPLIB_CRSB_DMA_NEXT(crsb->pbl_dma_ptr, sw_prod, dma_addr);
+		req->resp_addr = cpu_to_le64(dma_addr);
+		crsb->prod++;
+		spin_unlock_irqrestore(&crsb->lock, flags);
+
+		req->resp_size = (sizeof(struct bnxt_qplib_crsbe) +
+				  BNXT_QPLIB_CMDQE_UNITS - 1) /
+				 BNXT_QPLIB_CMDQE_UNITS;
+	}
+	cmdq_ptr = (struct bnxt_qplib_cmdqe **)cmdq->pbl_ptr;
+	preq = (u8 *)req;
+	size = req->cmd_size * BNXT_QPLIB_CMDQE_UNITS;
+	do {
+		pg = 0;
+		idx = 0;
+
+		/* Locate the next cmdq slot */
+		sw_prod = HWQ_CMP(cmdq->prod, cmdq);
+		cmdqe = &cmdq_ptr[CMDQ_PG(sw_prod)][CMDQ_IDX(sw_prod)];
+		if (!cmdqe) {
+			dev_err(&rcfw->pdev->dev,
+				"QPLIB: RCFW request failed with no cmdqe!");
+			goto done;
+		}
+		/* Copy a segment of the req cmd to the cmdq */
+		memset(cmdqe, 0, sizeof(*cmdqe));
+		memcpy(cmdqe, preq, min_t(u32, size, sizeof(*cmdqe)));
+		preq += min_t(u32, size, sizeof(*cmdqe));
+		size -= min_t(u32, size, sizeof(*cmdqe));
+		cmdq->prod++;
+	} while (size > 0);
+
+	cmdq_prod = cmdq->prod;
+	if (rcfw->flags & FIRMWARE_FIRST_FLAG) {
+		/* The very first doorbell write is required to set this flag
+		 * which prompts the FW to reset its internal pointers
+		 */
+		cmdq_prod |= FIRMWARE_FIRST_FLAG;
+		rcfw->flags &= ~FIRMWARE_FIRST_FLAG;
+	}
+	sw_prod = HWQ_CMP(crsq->prod, crsq);
+	crsqe = &crsq->crsq[sw_prod];
+	memset(crsqe, 0, sizeof(*crsqe));
+	crsq->prod++;
+	crsqe->req_size = req->cmd_size;
+
+	/* ring CMDQ DB */
+	writel(cmdq_prod, rcfw->cmdq_bar_reg_iomem +
+	       rcfw->cmdq_bar_reg_prod_off);
+	writel(RCFW_CMDQ_TRIG_VAL, rcfw->cmdq_bar_reg_iomem +
+	       rcfw->cmdq_bar_reg_trig_off);
+done:
+	spin_unlock_irqrestore(&cmdq->lock, flags);
+	/* Return the CREQ response pointer */
+	return crsqe ? &crsqe->qp_event : NULL;
+}
+
+/* Completions */
+static int bnxt_qplib_process_func_event(struct bnxt_qplib_rcfw *rcfw,
+					 struct creq_func_event *func_event)
+{
+	switch (func_event->event) {
+	case CREQ_FUNC_EVENT_EVENT_TX_WQE_ERROR:
+		break;
+	case CREQ_FUNC_EVENT_EVENT_TX_DATA_ERROR:
+		break;
+	case CREQ_FUNC_EVENT_EVENT_RX_WQE_ERROR:
+		break;
+	case CREQ_FUNC_EVENT_EVENT_RX_DATA_ERROR:
+		break;
+	case CREQ_FUNC_EVENT_EVENT_CQ_ERROR:
+		break;
+	case CREQ_FUNC_EVENT_EVENT_TQM_ERROR:
+		break;
+	case CREQ_FUNC_EVENT_EVENT_CFCQ_ERROR:
+		break;
+	case CREQ_FUNC_EVENT_EVENT_CFCS_ERROR:
+		/* SRQ ctx error, call srq_handler??
+		 * But there's no SRQ handle!
+		 */
+		break;
+	case CREQ_FUNC_EVENT_EVENT_CFCC_ERROR:
+		break;
+	case CREQ_FUNC_EVENT_EVENT_CFCM_ERROR:
+		break;
+	case CREQ_FUNC_EVENT_EVENT_TIM_ERROR:
+		break;
+	case CREQ_FUNC_EVENT_EVENT_VF_COMM_REQUEST:
+		break;
+	case CREQ_FUNC_EVENT_EVENT_RESOURCE_EXHAUSTED:
+		break;
+	default:
+		return -EINVAL;
+	}
+	return 0;
+}
+
+/* SP - CREQ Completion handlers */
+static void bnxt_qplib_service_creq(unsigned long data)
+{
+	struct bnxt_qplib_rcfw *rcfw = (struct bnxt_qplib_rcfw *)data;
+	struct bnxt_qplib_hwq *creq = &rcfw->creq;
+	struct creq_base *creqe, **creq_ptr;
+	u32 sw_cons, raw_cons;
+	unsigned long flags;
+	u32 type;
+
+	/* Service the CREQ until empty */
+	spin_lock_irqsave(&creq->lock, flags);
+	raw_cons = creq->cons;
+	while (1) {
+		sw_cons = HWQ_CMP(raw_cons, creq);
+		creq_ptr = (struct creq_base **)creq->pbl_ptr;
+		creqe = &creq_ptr[CREQ_PG(sw_cons)][CREQ_IDX(sw_cons)];
+		if (!CREQ_CMP_VALID(creqe, raw_cons, creq->max_elements))
+			break;
+
+		type = creqe->type & CREQ_BASE_TYPE_MASK;
+		switch (type) {
+		case CREQ_BASE_TYPE_QP_EVENT:
+			break;
+		case CREQ_BASE_TYPE_FUNC_EVENT:
+			if (!bnxt_qplib_process_func_event
+			    (rcfw, (struct creq_func_event *)creqe))
+				rcfw->creq_func_event_processed++;
+			else {
+				dev_warn(&rcfw->pdev->dev, "QPLIB: aeqe with");
+				dev_warn(&rcfw->pdev->dev,
+					 "QPLIB: type = 0x%x not handled",
+					 type);
+			}
+			break;
+		default:
+			dev_warn(&rcfw->pdev->dev, "QPLIB: creqe with ");
+			dev_warn(&rcfw->pdev->dev,
+				 "QPLIB: op_event = 0x%x not handled", type);
+			break;
+		}
+		raw_cons++;
+	}
+	if (creq->cons != raw_cons) {
+		creq->cons = raw_cons;
+		CREQ_DB_REARM(rcfw->creq_bar_reg_iomem, raw_cons,
+			      creq->max_elements);
+	}
+	spin_unlock_irqrestore(&creq->lock, flags);
+}
+
+static irqreturn_t bnxt_qplib_creq_irq(int irq, void *dev_instance)
+{
+	struct bnxt_qplib_rcfw *rcfw = dev_instance;
+	struct bnxt_qplib_hwq *creq = &rcfw->creq;
+	struct creq_base **creq_ptr;
+	u32 sw_cons;
+
+	/* Prefetch the CREQ element */
+	sw_cons = HWQ_CMP(creq->cons, creq);
+	creq_ptr = (struct creq_base **)rcfw->creq.pbl_ptr;
+	prefetch(&creq_ptr[CREQ_PG(sw_cons)][CREQ_IDX(sw_cons)]);
+
+	tasklet_schedule(&rcfw->worker);
+
+	return IRQ_HANDLED;
+}
+
+/* RCFW */
+int bnxt_qplib_deinit_rcfw(struct bnxt_qplib_rcfw *rcfw)
+{
+	struct creq_deinitialize_fw_resp *resp;
+	struct cmdq_deinitialize_fw req;
+	u16 cmd_flags = 0;
+
+	RCFW_CMD_PREP(req, DEINITIALIZE_FW, cmd_flags);
+	resp = (struct creq_deinitialize_fw_resp *)
+			bnxt_qplib_rcfw_send_message(rcfw, (void *)&req,
+						     NULL, 0);
+	if (!resp)
+		return -EINVAL;
+
+	if (!bnxt_qplib_rcfw_wait_for_resp(rcfw, le16_to_cpu(req.cookie)))
+		return -ETIMEDOUT;
+
+	if (RCFW_RESP_STATUS(resp) ||
+	    RCFW_RESP_COOKIE(resp) != RCFW_CMDQ_COOKIE(req))
+		return -EFAULT;
+
+	clear_bit(FIRMWARE_INITIALIZED_FLAG, &rcfw->flags);
+	return 0;
+}
+
+static int __get_pbl_pg_idx(struct bnxt_qplib_pbl *pbl)
+{
+	return (pbl->pg_size == ROCE_PG_SIZE_4K ?
+				      CMDQ_INITIALIZE_FW_QPC_PG_SIZE_PG_4K :
+		pbl->pg_size == ROCE_PG_SIZE_8K ?
+				      CMDQ_INITIALIZE_FW_QPC_PG_SIZE_PG_8K :
+		pbl->pg_size == ROCE_PG_SIZE_64K ?
+				      CMDQ_INITIALIZE_FW_QPC_PG_SIZE_PG_64K :
+		pbl->pg_size == ROCE_PG_SIZE_2M ?
+				      CMDQ_INITIALIZE_FW_QPC_PG_SIZE_PG_2M :
+		pbl->pg_size == ROCE_PG_SIZE_8M ?
+				      CMDQ_INITIALIZE_FW_QPC_PG_SIZE_PG_8M :
+		pbl->pg_size == ROCE_PG_SIZE_1G ?
+				      CMDQ_INITIALIZE_FW_QPC_PG_SIZE_PG_1G :
+				      CMDQ_INITIALIZE_FW_QPC_PG_SIZE_PG_4K);
+}
+
+int bnxt_qplib_init_rcfw(struct bnxt_qplib_rcfw *rcfw,
+			 struct bnxt_qplib_ctx *ctx, int is_virtfn)
+{
+	struct creq_initialize_fw_resp *resp;
+	struct cmdq_initialize_fw req;
+	u16 cmd_flags = 0, level;
+
+	RCFW_CMD_PREP(req, INITIALIZE_FW, cmd_flags);
+
+	/*
+	 * VFs need not setup the HW context area, PF
+	 * shall setup this area for VF. Skipping the
+	 * HW programming
+	 */
+	if (is_virtfn)
+		goto skip_ctx_setup;
+
+	level = ctx->qpc_tbl.level;
+	req.qpc_pg_size_qpc_lvl = (level << CMDQ_INITIALIZE_FW_QPC_LVL_SFT) |
+				__get_pbl_pg_idx(&ctx->qpc_tbl.pbl[level]);
+	level = ctx->mrw_tbl.level;
+	req.mrw_pg_size_mrw_lvl = (level << CMDQ_INITIALIZE_FW_MRW_LVL_SFT) |
+				__get_pbl_pg_idx(&ctx->mrw_tbl.pbl[level]);
+	level = ctx->srqc_tbl.level;
+	req.srq_pg_size_srq_lvl = (level << CMDQ_INITIALIZE_FW_SRQ_LVL_SFT) |
+				__get_pbl_pg_idx(&ctx->srqc_tbl.pbl[level]);
+	level = ctx->cq_tbl.level;
+	req.cq_pg_size_cq_lvl = (level << CMDQ_INITIALIZE_FW_CQ_LVL_SFT) |
+				__get_pbl_pg_idx(&ctx->cq_tbl.pbl[level]);
+	level = ctx->srqc_tbl.level;
+	req.srq_pg_size_srq_lvl = (level << CMDQ_INITIALIZE_FW_SRQ_LVL_SFT) |
+				__get_pbl_pg_idx(&ctx->srqc_tbl.pbl[level]);
+	level = ctx->cq_tbl.level;
+	req.cq_pg_size_cq_lvl = (level << CMDQ_INITIALIZE_FW_CQ_LVL_SFT) |
+				__get_pbl_pg_idx(&ctx->cq_tbl.pbl[level]);
+	level = ctx->tim_tbl.level;
+	req.tim_pg_size_tim_lvl = (level << CMDQ_INITIALIZE_FW_TIM_LVL_SFT) |
+				  __get_pbl_pg_idx(&ctx->tim_tbl.pbl[level]);
+	level = ctx->tqm_pde_level;
+	req.tqm_pg_size_tqm_lvl = (level << CMDQ_INITIALIZE_FW_TQM_LVL_SFT) |
+				  __get_pbl_pg_idx(&ctx->tqm_pde.pbl[level]);
+
+	req.qpc_page_dir =
+		cpu_to_le64(ctx->qpc_tbl.pbl[PBL_LVL_0].pg_map_arr[0]);
+	req.mrw_page_dir =
+		cpu_to_le64(ctx->mrw_tbl.pbl[PBL_LVL_0].pg_map_arr[0]);
+	req.srq_page_dir =
+		cpu_to_le64(ctx->srqc_tbl.pbl[PBL_LVL_0].pg_map_arr[0]);
+	req.cq_page_dir =
+		cpu_to_le64(ctx->cq_tbl.pbl[PBL_LVL_0].pg_map_arr[0]);
+	req.tim_page_dir =
+		cpu_to_le64(ctx->tim_tbl.pbl[PBL_LVL_0].pg_map_arr[0]);
+	req.tqm_page_dir =
+		cpu_to_le64(ctx->tqm_pde.pbl[PBL_LVL_0].pg_map_arr[0]);
+
+	req.number_of_qp = cpu_to_le32(ctx->qpc_tbl.max_elements);
+	req.number_of_mrw = cpu_to_le32(ctx->mrw_tbl.max_elements);
+	req.number_of_srq = cpu_to_le32(ctx->srqc_tbl.max_elements);
+	req.number_of_cq = cpu_to_le32(ctx->cq_tbl.max_elements);
+
+	req.max_qp_per_vf = cpu_to_le32(ctx->vf_res.max_qp_per_vf);
+	req.max_mrw_per_vf = cpu_to_le32(ctx->vf_res.max_mrw_per_vf);
+	req.max_srq_per_vf = cpu_to_le32(ctx->vf_res.max_srq_per_vf);
+	req.max_cq_per_vf = cpu_to_le32(ctx->vf_res.max_cq_per_vf);
+	req.max_gid_per_vf = cpu_to_le32(ctx->vf_res.max_gid_per_vf);
+
+skip_ctx_setup:
+	req.stat_ctx_id = cpu_to_le32(ctx->stats.fw_id);
+	resp = (struct creq_initialize_fw_resp *)
+			bnxt_qplib_rcfw_send_message(rcfw, (void *)&req,
+						     NULL, 0);
+	if (!resp) {
+		dev_err(&rcfw->pdev->dev,
+			"QPLIB: RCFW: INITIALIZE_FW send failed");
+		return -EINVAL;
+	}
+	if (!bnxt_qplib_rcfw_wait_for_resp(rcfw, le16_to_cpu(req.cookie))) {
+		/* Cmd timed out */
+		dev_err(&rcfw->pdev->dev,
+			"QPLIB: RCFW: INITIALIZE_FW timed out");
+		return -ETIMEDOUT;
+	}
+	if (RCFW_RESP_STATUS(resp) ||
+	    RCFW_RESP_COOKIE(resp) != RCFW_CMDQ_COOKIE(req)) {
+		dev_err(&rcfw->pdev->dev,
+			"QPLIB: RCFW: INITIALIZE_FW failed");
+		return -EINVAL;
+	}
+	set_bit(FIRMWARE_INITIALIZED_FLAG, &rcfw->flags);
+	return 0;
+}
+
+void bnxt_qplib_free_rcfw_channel(struct bnxt_qplib_rcfw *rcfw)
+{
+	bnxt_qplib_free_hwq(rcfw->pdev, &rcfw->crsb);
+	kfree(rcfw->crsq.crsq);
+	bnxt_qplib_free_hwq(rcfw->pdev, &rcfw->cmdq);
+	bnxt_qplib_free_hwq(rcfw->pdev, &rcfw->creq);
+
+	rcfw->pdev = NULL;
+}
+
+int bnxt_qplib_alloc_rcfw_channel(struct pci_dev *pdev,
+				  struct bnxt_qplib_rcfw *rcfw)
+{
+	rcfw->pdev = pdev;
+	rcfw->creq.max_elements = BNXT_QPLIB_CREQE_MAX_CNT;
+	if (bnxt_qplib_alloc_init_hwq(rcfw->pdev, &rcfw->creq, NULL, 0,
+				      &rcfw->creq.max_elements,
+				      BNXT_QPLIB_CREQE_UNITS, 0, PAGE_SIZE,
+				      HWQ_TYPE_L2_CMPL)) {
+		dev_err(&rcfw->pdev->dev,
+			"QPLIB: HW channel CREQ allocation failed");
+		goto fail;
+	}
+	rcfw->cmdq.max_elements = BNXT_QPLIB_CMDQE_MAX_CNT;
+	if (bnxt_qplib_alloc_init_hwq(rcfw->pdev, &rcfw->cmdq, NULL, 0,
+				      &rcfw->cmdq.max_elements,
+				      BNXT_QPLIB_CMDQE_UNITS, 0, PAGE_SIZE,
+				      HWQ_TYPE_CTX)) {
+		dev_err(&rcfw->pdev->dev,
+			"QPLIB: HW channel CMDQ allocation failed");
+		goto fail;
+	}
+
+	rcfw->crsq.max_elements = rcfw->cmdq.max_elements;
+	rcfw->crsq.crsq = kcalloc(rcfw->crsq.max_elements,
+				  sizeof(*rcfw->crsq.crsq), GFP_KERNEL);
+	if (!rcfw->crsq.crsq)
+		goto fail;
+
+	rcfw->crsb.max_elements = BNXT_QPLIB_CRSBE_MAX_CNT;
+	if (bnxt_qplib_alloc_init_hwq(rcfw->pdev, &rcfw->crsb, NULL, 0,
+				      &rcfw->crsb.max_elements,
+				      BNXT_QPLIB_CRSBE_UNITS, 0, PAGE_SIZE,
+				      HWQ_TYPE_CTX)) {
+		dev_err(&rcfw->pdev->dev,
+			"QPLIB: HW channel CRSB allocation failed");
+		goto fail;
+	}
+	return 0;
+
+fail:
+	bnxt_qplib_free_rcfw_channel(rcfw);
+	return -ENOMEM;
+}
+
+void bnxt_qplib_disable_rcfw_channel(struct bnxt_qplib_rcfw *rcfw)
+{
+	unsigned long indx;
+
+	/* Make sure the HW channel is stopped! */
+	synchronize_irq(rcfw->vector);
+	tasklet_disable(&rcfw->worker);
+	tasklet_kill(&rcfw->worker);
+
+	if (rcfw->requested) {
+		free_irq(rcfw->vector, rcfw);
+		rcfw->requested = false;
+	}
+	if (rcfw->cmdq_bar_reg_iomem)
+		iounmap(rcfw->cmdq_bar_reg_iomem);
+	rcfw->cmdq_bar_reg_iomem = NULL;
+
+	if (rcfw->creq_bar_reg_iomem)
+		iounmap(rcfw->creq_bar_reg_iomem);
+	rcfw->creq_bar_reg_iomem = NULL;
+
+	indx = find_first_bit(rcfw->cmdq_bitmap, rcfw->bmap_size);
+	if (indx != rcfw->bmap_size)
+		dev_err(&rcfw->pdev->dev,
+			"QPLIB: disabling RCFW with pending cmd-bit %lx", indx);
+	kfree(rcfw->cmdq_bitmap);
+	rcfw->bmap_size = 0;
+
+	rcfw->aeq_handler = NULL;
+	rcfw->vector = 0;
+}
+
+int bnxt_qplib_enable_rcfw_channel(struct pci_dev *pdev,
+				   struct bnxt_qplib_rcfw *rcfw,
+				   int msix_vector,
+				   int cp_bar_reg_off, int virt_fn,
+				   int (*aeq_handler)(struct bnxt_qplib_rcfw *,
+						      struct creq_func_event *))
+{
+	resource_size_t res_base;
+	struct cmdq_init init;
+	u16 bmap_size;
+	int rc;
+
+	/* General */
+	atomic_set(&rcfw->seq_num, 0);
+	rcfw->flags = FIRMWARE_FIRST_FLAG;
+	bmap_size = BITS_TO_LONGS(RCFW_MAX_OUTSTANDING_CMD *
+				  sizeof(unsigned long));
+	rcfw->cmdq_bitmap = kzalloc(bmap_size, GFP_KERNEL);
+	if (!rcfw->cmdq_bitmap)
+		return -ENOMEM;
+	rcfw->bmap_size = bmap_size;
+
+	/* CMDQ */
+	rcfw->cmdq_bar_reg = RCFW_COMM_PCI_BAR_REGION;
+	res_base = pci_resource_start(pdev, rcfw->cmdq_bar_reg);
+	if (!res_base)
+		return -ENOMEM;
+
+	rcfw->cmdq_bar_reg_iomem = ioremap_nocache(res_base +
+					      RCFW_COMM_BASE_OFFSET,
+					      RCFW_COMM_SIZE);
+	if (!rcfw->cmdq_bar_reg_iomem) {
+		dev_err(&rcfw->pdev->dev,
+			"QPLIB: CMDQ BAR region %d mapping failed",
+			rcfw->cmdq_bar_reg);
+		return -ENOMEM;
+	}
+
+	rcfw->cmdq_bar_reg_prod_off = virt_fn ? RCFW_VF_COMM_PROD_OFFSET :
+					RCFW_PF_COMM_PROD_OFFSET;
+
+	rcfw->cmdq_bar_reg_trig_off = RCFW_COMM_TRIG_OFFSET;
+
+	/* CRSQ */
+	rcfw->crsq.prod = 0;
+	rcfw->crsq.cons = 0;
+
+	/* CREQ */
+	rcfw->creq_bar_reg = RCFW_COMM_CONS_PCI_BAR_REGION;
+	res_base = pci_resource_start(pdev, rcfw->creq_bar_reg);
+	if (!res_base)
+		dev_err(&rcfw->pdev->dev,
+			"QPLIB: CREQ BAR region %d resc start is 0!",
+			rcfw->creq_bar_reg);
+	rcfw->creq_bar_reg_iomem = ioremap_nocache(res_base + cp_bar_reg_off,
+						   4);
+	if (!rcfw->creq_bar_reg_iomem) {
+		dev_err(&rcfw->pdev->dev,
+			"QPLIB: CREQ BAR region %d mapping failed",
+			rcfw->creq_bar_reg);
+		return -ENOMEM;
+	}
+	rcfw->creq_qp_event_processed = 0;
+	rcfw->creq_func_event_processed = 0;
+
+	rcfw->vector = msix_vector;
+	if (aeq_handler)
+		rcfw->aeq_handler = aeq_handler;
+
+	tasklet_init(&rcfw->worker, bnxt_qplib_service_creq,
+		     (unsigned long)rcfw);
+
+	rcfw->requested = false;
+	rc = request_irq(rcfw->vector, bnxt_qplib_creq_irq, 0,
+			 "bnxt_qplib_creq", rcfw);
+	if (rc) {
+		dev_err(&rcfw->pdev->dev,
+			"QPLIB: Failed to request IRQ for CREQ rc = 0x%x", rc);
+		bnxt_qplib_disable_rcfw_channel(rcfw);
+		return rc;
+	}
+	rcfw->requested = true;
+
+	init_waitqueue_head(&rcfw->waitq);
+
+	CREQ_DB_REARM(rcfw->creq_bar_reg_iomem, 0, rcfw->creq.max_elements);
+
+	init.cmdq_pbl = cpu_to_le64(rcfw->cmdq.pbl[PBL_LVL_0].pg_map_arr[0]);
+	init.cmdq_size_cmdq_lvl = cpu_to_le16(
+		((BNXT_QPLIB_CMDQE_MAX_CNT << CMDQ_INIT_CMDQ_SIZE_SFT) &
+		 CMDQ_INIT_CMDQ_SIZE_MASK) |
+		((rcfw->cmdq.level << CMDQ_INIT_CMDQ_LVL_SFT) &
+		 CMDQ_INIT_CMDQ_LVL_MASK));
+	init.creq_ring_id = cpu_to_le16(rcfw->creq_ring_id);
+
+	/* Write to the Bono mailbox register */
+	__iowrite32_copy(rcfw->cmdq_bar_reg_iomem, &init, sizeof(init) / 4);
+	return 0;
+}
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_qplib_rcfw.h b/drivers/infiniband/hw/bnxtre/bnxt_qplib_rcfw.h
index 1f63956..942fa11 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_qplib_rcfw.h
+++ b/drivers/infiniband/hw/bnxtre/bnxt_qplib_rcfw.h
@@ -39,4 +39,180 @@
 #ifndef __BNXT_QPLIB_RCFW_H__
 #define __BNXT_QPLIB_RCFW_H__
 
+#define RCFW_CMDQ_TRIG_VAL		1
+#define RCFW_COMM_PCI_BAR_REGION	0
+#define RCFW_COMM_CONS_PCI_BAR_REGION	2
+#define RCFW_COMM_BASE_OFFSET		0x600
+#define RCFW_PF_COMM_PROD_OFFSET		0x7c
+#define RCFW_VF_COMM_PROD_OFFSET	0xc
+#define RCFW_COMM_TRIG_OFFSET		0x100
+#define RCFW_COMM_SIZE			0x104
+
+#define RCFW_DBR_PCI_BAR_REGION		2
+
+#define RCFW_CMD_PREP(req, CMD, cmd_flags)				\
+	do {								\
+		memset(&(req), 0, sizeof((req)));			\
+		(req).opcode = CMDQ_BASE_OPCODE_##CMD;			\
+		(req).cmd_size = (sizeof((req)) +			\
+				BNXT_QPLIB_CMDQE_UNITS - 1) /		\
+				BNXT_QPLIB_CMDQE_UNITS;			\
+		(req).flags = cpu_to_le16(cmd_flags);			\
+	} while (0)
+
+#define RCFW_RESP_STATUS(resp)	((resp)->status)
+
+#define RCFW_CMDQ_COOKIE(req)	le16_to_cpu(req.cookie)
+
+#define RCFW_RESP_COOKIE(resp)	le16_to_cpu((resp)->cookie)
+
+#define RCFW_CMD_WAIT_TIME_MS		20000 /* 20 Seconds timeout */
+
+/* CMDQ elements */
+#define BNXT_QPLIB_CMDQE_MAX_CNT	256
+#define BNXT_QPLIB_CMDQE_UNITS		sizeof(struct bnxt_qplib_cmdqe)
+#define BNXT_QPLIB_CMDQE_CNT_PER_PG	(PAGE_SIZE / BNXT_QPLIB_CMDQE_UNITS)
+
+#define MAX_CMDQ_IDX			(BNXT_QPLIB_CMDQE_MAX_CNT - 1)
+#define MAX_CMDQ_IDX_PER_PG		(BNXT_QPLIB_CMDQE_CNT_PER_PG - 1)
+
+#define CMDQ_PG(x)			\
+	(((x) & ~MAX_CMDQ_IDX_PER_PG) / BNXT_QPLIB_CMDQE_CNT_PER_PG)
+#define CMDQ_IDX(x)			((x) & MAX_CMDQ_IDX_PER_PG)
+
+#define RCFW_MAX_OUTSTANDING_CMD	BNXT_QPLIB_CMDQE_MAX_CNT
+#define RCFW_MAX_COOKIE_VALUE		0x7FFF
+#define RCFW_CMD_IS_BLOCKING		0x8000
+
+/* Cmdq contains a fix number of a 16-Byte slots */
+struct bnxt_qplib_cmdqe {
+	u8		data[16];
+};
+
+/* CRSQ SB */
+#define BNXT_QPLIB_CRSBE_MAX_CNT	4
+#define BNXT_QPLIB_CRSBE_UNITS		sizeof(struct bnxt_qplib_crsbe)
+#define BNXT_QPLIB_CRSBE_CNT_PER_PG	(PAGE_SIZE / BNXT_QPLIB_CRSBE_UNITS)
+
+#define MAX_CRSB_IDX			(BNXT_QPLIB_CRSBE_MAX_CNT - 1)
+#define MAX_CRSB_IDX_PER_PG		(BNXT_QPLIB_CRSBE_CNT_PER_PG - 1)
+
+#define CRSB_PG(x)			\
+	(((x) & ~MAX_CRSB_IDX_PER_PG) / BNXT_QPLIB_CRSBE_CNT_PER_PG)
+#define CRSB_IDX(x)			((x) & MAX_CRSB_IDX_PER_PG)
+
+/* Crsq buf is 1024-Byte */
+struct bnxt_qplib_crsbe {
+	u8			data[1024];
+};
+
+#define BNXT_QPLIB_CRSB_DMA_NEXT(pg_map_arr, prod, dma_addr)		\
+	do {								\
+		dma_addr = pg_map_arr[(prod) / BNXT_QPLIB_CRSBE_CNT_PER_PG];\
+		dma_addr += ((prod) % BNXT_QPLIB_CRSBE_CNT_PER_PG) *	\
+			    BNXT_QPLIB_CRSBE_UNITS;			\
+	} while (0)
+
+/* CREQ */
+/* Allocate 1 per QP for async error notification for now */
+#define BNXT_QPLIB_CREQE_MAX_CNT	(64 * 1024)
+#define BNXT_QPLIB_CREQE_UNITS		16	/* 16-Bytes per prod unit */
+#define BNXT_QPLIB_CREQE_CNT_PER_PG	(PAGE_SIZE / BNXT_QPLIB_CREQE_UNITS)
+
+#define MAX_CREQ_IDX			(BNXT_QPLIB_CREQE_MAX_CNT - 1)
+#define MAX_CREQ_IDX_PER_PG		(BNXT_QPLIB_CREQE_CNT_PER_PG - 1)
+
+#define CREQ_PG(x)			\
+	(((x) & ~MAX_CREQ_IDX_PER_PG) / BNXT_QPLIB_CREQE_CNT_PER_PG)
+#define CREQ_IDX(x)			((x) & MAX_CREQ_IDX_PER_PG)
+
+#define BNXT_QPLIB_CREQE_PER_PG	(PAGE_SIZE / sizeof(struct creq_base))
+
+#define CREQ_CMP_VALID(hdr, raw_cons, cp_bit)			\
+	(!!((hdr)->v & CREQ_BASE_V) ==				\
+	   !((raw_cons) & (cp_bit)))
+
+#define CREQ_DB_KEY_CP			(0x2 << CMPL_DOORBELL_KEY_SFT)
+#define CREQ_DB_IDX_VALID		CMPL_DOORBELL_IDX_VALID
+#define CREQ_DB_IRQ_DIS			CMPL_DOORBELL_MASK
+#define CREQ_DB_CP_FLAGS_REARM		(CREQ_DB_KEY_CP |	\
+					 CREQ_DB_IDX_VALID)
+#define CREQ_DB_CP_FLAGS		(CREQ_DB_KEY_CP |	\
+					 CREQ_DB_IDX_VALID |	\
+					 CREQ_DB_IRQ_DIS)
+#define CREQ_DB_REARM(db, raw_cons, cp_bit)			\
+	writel(CREQ_DB_CP_FLAGS_REARM | ((raw_cons) & ((cp_bit) - 1)), db)
+#define CREQ_DB(db, raw_cons, cp_bit)				\
+	writel(CREQ_DB_CP_FLAGS | ((raw_cons) & ((cp_bit) - 1)), db)
+
+/* HWQ */
+struct bnxt_qplib_crsqe {
+	struct creq_qp_event	qp_event;
+	u32			req_size;
+};
+
+struct bnxt_qplib_crsq {
+	struct bnxt_qplib_crsqe	*crsq;
+	u32			prod;
+	u32			cons;
+	u32			max_elements;
+};
+
+/* RCFW Communication Channels */
+struct bnxt_qplib_rcfw {
+	struct pci_dev		*pdev;
+	int			vector;
+	struct tasklet_struct	worker;
+	bool			requested;
+	unsigned long		*cmdq_bitmap;
+	u32			bmap_size;
+	unsigned long		flags;
+#define FIRMWARE_INITIALIZED_FLAG	BIT(0)
+#define FIRMWARE_FIRST_FLAG		BIT(31)
+	wait_queue_head_t	waitq;
+	int			(*aeq_handler)(struct bnxt_qplib_rcfw *,
+					       struct creq_func_event *);
+	atomic_t		seq_num;
+
+	/* Bar region info */
+	void __iomem		*cmdq_bar_reg_iomem;
+	u16			cmdq_bar_reg;
+	u16			cmdq_bar_reg_prod_off;
+	u16			cmdq_bar_reg_trig_off;
+	u16			creq_ring_id;
+	u16			creq_bar_reg;
+	void __iomem		*creq_bar_reg_iomem;
+
+	/* Cmd-Resp and Async Event notification queue */
+	struct bnxt_qplib_hwq	creq;
+	u64			creq_qp_event_processed;
+	u64			creq_func_event_processed;
+
+	/* Actual Cmd and Resp Queues */
+	struct bnxt_qplib_hwq	cmdq;
+	struct bnxt_qplib_crsq	crsq;
+	struct bnxt_qplib_hwq	crsb;
+};
+
+void bnxt_qplib_free_rcfw_channel(struct bnxt_qplib_rcfw *rcfw);
+int bnxt_qplib_alloc_rcfw_channel(struct pci_dev *pdev,
+				  struct bnxt_qplib_rcfw *rcfw);
+void bnxt_qplib_disable_rcfw_channel(struct bnxt_qplib_rcfw *rcfw);
+int bnxt_qplib_enable_rcfw_channel(struct pci_dev *pdev,
+				   struct bnxt_qplib_rcfw *rcfw,
+				   int msix_vector,
+				   int cp_bar_reg_off, int virt_fn,
+				   int (*aeq_handler)
+					(struct bnxt_qplib_rcfw *,
+					 struct creq_func_event *));
+
+int bnxt_qplib_rcfw_block_for_resp(struct bnxt_qplib_rcfw *rcfw, u16 cookie);
+int bnxt_qplib_rcfw_wait_for_resp(struct bnxt_qplib_rcfw *rcfw, u16 cookie);
+void *bnxt_qplib_rcfw_send_message(struct bnxt_qplib_rcfw *rcfw,
+				   struct cmdq_base *req, void **crsbe,
+				   u8 is_block);
+
+int bnxt_qplib_deinit_rcfw(struct bnxt_qplib_rcfw *rcfw);
+int bnxt_qplib_init_rcfw(struct bnxt_qplib_rcfw *rcfw,
+			 struct bnxt_qplib_ctx *ctx, int is_virtfn);
 #endif /* __BNXT_QPLIB_RCFW_H__ */
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_qplib_res.c b/drivers/infiniband/hw/bnxtre/bnxt_qplib_res.c
index 178eebd..58db3a2 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_qplib_res.c
+++ b/drivers/infiniband/hw/bnxtre/bnxt_qplib_res.c
@@ -35,3 +35,743 @@
  *
  * Description: QPLib resource manager
  */
+
+#include <linux/spinlock.h>
+#include <linux/pci.h>
+#include <linux/interrupt.h>
+#include <linux/inetdevice.h>
+#include <linux/dma-mapping.h>
+#include <linux/if_vlan.h>
+#include "bnxt_re_hsi.h"
+#include "bnxt_qplib_res.h"
+#include "bnxt_qplib_sp.h"
+#include "bnxt_qplib_rcfw.h"
+
+static void bnxt_qplib_free_stats_ctx(struct pci_dev *pdev,
+				      struct bnxt_qplib_stats *stats);
+static int bnxt_qplib_alloc_stats_ctx(struct pci_dev *pdev,
+				      struct bnxt_qplib_stats *stats);
+
+/* PBL */
+static void __free_pbl(struct pci_dev *pdev, struct bnxt_qplib_pbl *pbl,
+		       bool is_umem)
+{
+	int i;
+
+	if (!is_umem) {
+		for (i = 0; i < pbl->pg_count; i++) {
+			if (pbl->pg_arr[i])
+				dma_free_coherent(&pdev->dev, pbl->pg_size,
+						  (void *)((u64)pbl->pg_arr[i] &
+						  PAGE_MASK),
+						  pbl->pg_map_arr[i]);
+			else
+				dev_warn(&pdev->dev,
+					 "QPLIB: PBL free pg_arr[%d] empty?!",
+					 i);
+			pbl->pg_arr[i] = NULL;
+		}
+	}
+	kfree(pbl->pg_arr);
+	pbl->pg_arr = NULL;
+	kfree(pbl->pg_map_arr);
+	pbl->pg_map_arr = NULL;
+	pbl->pg_count = 0;
+	pbl->pg_size = 0;
+}
+
+static int __alloc_pbl(struct pci_dev *pdev, struct bnxt_qplib_pbl *pbl,
+		       struct scatterlist *sghead, u32 pages, u32 pg_size)
+{
+	struct scatterlist *sg;
+	bool is_umem = false;
+	int i;
+
+	/* page ptr arrays */
+	pbl->pg_arr = kcalloc(pages, sizeof(void *), GFP_KERNEL);
+	if (!pbl->pg_arr)
+		return -ENOMEM;
+
+	pbl->pg_map_arr = kcalloc(pages, sizeof(dma_addr_t), GFP_KERNEL);
+	if (!pbl->pg_map_arr) {
+		kfree(pbl->pg_arr);
+		pbl->pg_arr = NULL;
+		return -ENOMEM;
+	}
+	pbl->pg_count = 0;
+	pbl->pg_size = pg_size;
+
+	if (!sghead) {
+		for (i = 0; i < pages; i++) {
+			pbl->pg_arr[i] = dma_alloc_coherent(&pdev->dev,
+							    pbl->pg_size,
+							    &pbl->pg_map_arr[i],
+							    GFP_KERNEL);
+			if (!pbl->pg_arr[i])
+				goto fail;
+			memset(pbl->pg_arr[i], 0, pbl->pg_size);
+			pbl->pg_count++;
+		}
+	} else {
+		i = 0;
+		is_umem = true;
+		for_each_sg(sghead, sg, pages, i) {
+			pbl->pg_map_arr[i] = sg_dma_address(sg);
+			pbl->pg_arr[i] = sg_virt(sg);
+			if (!pbl->pg_arr[i])
+				goto fail;
+
+			pbl->pg_count++;
+		}
+	}
+
+	return 0;
+
+fail:
+	__free_pbl(pdev, pbl, is_umem);
+	return -ENOMEM;
+}
+
+/* HWQ */
+void bnxt_qplib_free_hwq(struct pci_dev *pdev, struct bnxt_qplib_hwq *hwq)
+{
+	int i;
+
+	if (!hwq->max_elements)
+		return;
+	if (hwq->level >= PBL_LVL_MAX)
+		return;
+
+	for (i = 0; i < hwq->level + 1; i++) {
+		if (i == hwq->level)
+			__free_pbl(pdev, &hwq->pbl[i], hwq->is_user);
+		else
+			__free_pbl(pdev, &hwq->pbl[i], false);
+	}
+
+	hwq->level = PBL_LVL_MAX;
+	hwq->max_elements = 0;
+	hwq->element_size = 0;
+	hwq->prod = 0;
+	hwq->cons = 0;
+	hwq->cp_bit = 0;
+}
+
+/* All HWQs are power of 2 in size */
+int bnxt_qplib_alloc_init_hwq(struct pci_dev *pdev, struct bnxt_qplib_hwq *hwq,
+			      struct scatterlist *sghead, int nmap,
+			      u32 *elements, u32 element_size, u32 aux,
+			      u32 pg_size, enum bnxt_qplib_hwq_type hwq_type)
+{
+	u32 pages, slots, size, aux_pages = 0, aux_size = 0;
+	dma_addr_t *src_phys_ptr, **dst_virt_ptr;
+	int i, rc;
+
+	hwq->level = PBL_LVL_MAX;
+
+	if (*elements < 0)
+		return -EINVAL;
+
+	slots = roundup_pow_of_two(*elements);
+	if (aux) {
+		aux_size = roundup_pow_of_two(aux);
+		aux_pages = (slots * aux_size) / pg_size;
+		if ((slots * aux_size) % pg_size)
+			aux_pages++;
+	}
+	size = roundup_pow_of_two(element_size);
+
+	if (!sghead) {
+		hwq->is_user = false;
+		pages = (slots * size) / pg_size + aux_pages;
+		if ((slots * size) % pg_size)
+			pages++;
+		if (!pages)
+			return -EINVAL;
+	} else {
+		hwq->is_user = true;
+		pages = nmap;
+	}
+
+	/* Alloc the 1st memory block; can be a PDL/PTL/PBL */
+	if (sghead && (pages == MAX_PBL_LVL_0_PGS))
+		rc = __alloc_pbl(pdev, &hwq->pbl[PBL_LVL_0], sghead,
+				 pages, pg_size);
+	else
+		rc = __alloc_pbl(pdev, &hwq->pbl[PBL_LVL_0], NULL, 1, pg_size);
+	if (rc)
+		goto fail;
+
+	hwq->level = PBL_LVL_0;
+
+	if (pages > MAX_PBL_LVL_0_PGS) {
+		if (pages > MAX_PBL_LVL_1_PGS) {
+			/* 2 levels of indirection */
+			rc = __alloc_pbl(pdev, &hwq->pbl[PBL_LVL_1], NULL,
+					 MAX_PBL_LVL_1_PGS_FOR_LVL_2, pg_size);
+			if (rc)
+				goto fail;
+			/* Fill in lvl0 PBL */
+			dst_virt_ptr =
+				(dma_addr_t **)hwq->pbl[PBL_LVL_0].pg_arr;
+			src_phys_ptr = hwq->pbl[PBL_LVL_1].pg_map_arr;
+			for (i = 0; i < hwq->pbl[PBL_LVL_1].pg_count; i++)
+				dst_virt_ptr[PTR_PG(i)][PTR_IDX(i)] =
+					src_phys_ptr[i] | PTU_PDE_VALID;
+			hwq->level = PBL_LVL_1;
+
+			rc = __alloc_pbl(pdev, &hwq->pbl[PBL_LVL_2], sghead,
+					 pages, pg_size);
+			if (rc)
+				goto fail;
+
+			/* Fill in lvl1 PBL */
+			dst_virt_ptr =
+				(dma_addr_t **)hwq->pbl[PBL_LVL_1].pg_arr;
+			src_phys_ptr = hwq->pbl[PBL_LVL_2].pg_map_arr;
+			for (i = 0; i < hwq->pbl[PBL_LVL_2].pg_count; i++) {
+				dst_virt_ptr[PTR_PG(i)][PTR_IDX(i)] =
+					src_phys_ptr[i] | PTU_PTE_VALID;
+			}
+			if (hwq_type == HWQ_TYPE_QUEUE) {
+				/* Find the last pg of the size */
+				i = hwq->pbl[PBL_LVL_2].pg_count;
+				dst_virt_ptr[PTR_PG(i - 1)][PTR_IDX(i - 1)] |=
+								  PTU_PTE_LAST;
+				if (i > 1)
+					dst_virt_ptr[PTR_PG(i - 2)]
+						    [PTR_IDX(i - 2)] |=
+						    PTU_PTE_NEXT_TO_LAST;
+			}
+			hwq->level = PBL_LVL_2;
+		} else {
+			u32 flag = hwq_type == HWQ_TYPE_L2_CMPL ? 0 :
+						PTU_PTE_VALID;
+
+			/* 1 level of indirection */
+			rc = __alloc_pbl(pdev, &hwq->pbl[PBL_LVL_1], sghead,
+					 pages, pg_size);
+			if (rc)
+				goto fail;
+			/* Fill in lvl0 PBL */
+			dst_virt_ptr =
+				(dma_addr_t **)hwq->pbl[PBL_LVL_0].pg_arr;
+			src_phys_ptr = hwq->pbl[PBL_LVL_1].pg_map_arr;
+			for (i = 0; i < hwq->pbl[PBL_LVL_1].pg_count; i++) {
+				dst_virt_ptr[PTR_PG(i)][PTR_IDX(i)] =
+					src_phys_ptr[i] | flag;
+			}
+			if (hwq_type == HWQ_TYPE_QUEUE) {
+				/* Find the last pg of the size */
+				i = hwq->pbl[PBL_LVL_1].pg_count;
+				dst_virt_ptr[PTR_PG(i - 1)][PTR_IDX(i - 1)] |=
+								  PTU_PTE_LAST;
+				if (i > 1)
+					dst_virt_ptr[PTR_PG(i - 2)]
+						    [PTR_IDX(i - 2)] |=
+						    PTU_PTE_NEXT_TO_LAST;
+			}
+			hwq->level = PBL_LVL_1;
+		}
+	}
+	hwq->pdev = pdev;
+	spin_lock_init(&hwq->lock);
+	hwq->prod = 0;
+	hwq->cons = 0;
+	*elements = hwq->max_elements = slots;
+	hwq->element_size = size;
+
+	/* For direct access to the elements */
+	hwq->pbl_ptr = hwq->pbl[hwq->level].pg_arr;
+	hwq->pbl_dma_ptr = hwq->pbl[hwq->level].pg_map_arr;
+
+	return 0;
+
+fail:
+	bnxt_qplib_free_hwq(pdev, hwq);
+	return -ENOMEM;
+}
+
+/* Context Tables */
+void bnxt_qplib_free_ctx(struct pci_dev *pdev,
+			 struct bnxt_qplib_ctx *ctx)
+{
+	int i;
+
+	bnxt_qplib_free_hwq(pdev, &ctx->qpc_tbl);
+	bnxt_qplib_free_hwq(pdev, &ctx->mrw_tbl);
+	bnxt_qplib_free_hwq(pdev, &ctx->srqc_tbl);
+	bnxt_qplib_free_hwq(pdev, &ctx->cq_tbl);
+	bnxt_qplib_free_hwq(pdev, &ctx->tim_tbl);
+	for (i = 0; i < MAX_TQM_ALLOC_REQ; i++)
+		bnxt_qplib_free_hwq(pdev, &ctx->tqm_tbl[i]);
+	bnxt_qplib_free_hwq(pdev, &ctx->tqm_pde);
+	bnxt_qplib_free_stats_ctx(pdev, &ctx->stats);
+}
+
+/*
+ * Routine: bnxt_qplib_alloc_ctx
+ * Description:
+ *     Context tables are memories which are used by the chip fw.
+ *     The 6 tables defined are:
+ *             QPC ctx - holds QP states
+ *             MRW ctx - holds memory region and window
+ *             SRQ ctx - holds shared RQ states
+ *             CQ ctx - holds completion queue states
+ *             TQM ctx - holds Tx Queue Manager context
+ *             TIM ctx - holds timer context
+ *     Depending on the size of the tbl requested, either a 1 Page Buffer List
+ *     or a 1-to-2-stage indirection Page Directory List + 1 PBL is used
+ *     instead.
+ *     Table might be employed as follows:
+ *             For 0      < ctx size <= 1 PAGE, 0 level of ind is used
+ *             For 1 PAGE < ctx size <= 512 entries size, 1 level of ind is used
+ *             For 512    < ctx size <= MAX, 2 levels of ind is used
+ * Returns:
+ *     0 if success, else -ERRORS
+ */
+int bnxt_qplib_alloc_ctx(struct pci_dev *pdev,
+			 struct bnxt_qplib_ctx *ctx,
+			 bool virt_fn)
+{
+	int i, j, k, rc = 0;
+	int fnz_idx = -1;
+	u64 **pbl_ptr;
+
+	if (virt_fn)
+		goto stats_alloc;
+
+	/* QPC Tables */
+	ctx->qpc_tbl.max_elements = ctx->qpc_count;
+	rc = bnxt_qplib_alloc_init_hwq(pdev, &ctx->qpc_tbl, NULL, 0,
+				       &ctx->qpc_tbl.max_elements,
+				       BNXT_QPLIB_MAX_QP_CTX_ENTRY_SIZE, 0,
+				       PAGE_SIZE, HWQ_TYPE_CTX);
+	if (rc)
+		goto fail;
+
+	/* MRW Tables */
+	ctx->mrw_tbl.max_elements = ctx->mrw_count;
+	rc = bnxt_qplib_alloc_init_hwq(pdev, &ctx->mrw_tbl, NULL, 0,
+				       &ctx->mrw_tbl.max_elements,
+				       BNXT_QPLIB_MAX_MRW_CTX_ENTRY_SIZE, 0,
+				       PAGE_SIZE, HWQ_TYPE_CTX);
+	if (rc)
+		goto fail;
+
+	/* SRQ Tables */
+	ctx->srqc_tbl.max_elements = ctx->srqc_count;
+	rc = bnxt_qplib_alloc_init_hwq(pdev, &ctx->srqc_tbl, NULL, 0,
+				       &ctx->srqc_tbl.max_elements,
+				       BNXT_QPLIB_MAX_SRQ_CTX_ENTRY_SIZE, 0,
+				       PAGE_SIZE, HWQ_TYPE_CTX);
+	if (rc)
+		goto fail;
+
+	/* CQ Tables */
+	ctx->cq_tbl.max_elements = ctx->cq_count;
+	rc = bnxt_qplib_alloc_init_hwq(pdev, &ctx->cq_tbl, NULL, 0,
+				       &ctx->cq_tbl.max_elements,
+				       BNXT_QPLIB_MAX_CQ_CTX_ENTRY_SIZE, 0,
+				       PAGE_SIZE, HWQ_TYPE_CTX);
+	if (rc)
+		goto fail;
+
+	/* TQM Buffer */
+	ctx->tqm_pde.max_elements = 512;
+	rc = bnxt_qplib_alloc_init_hwq(pdev, &ctx->tqm_pde, NULL, 0,
+				       &ctx->tqm_pde.max_elements, sizeof(u64),
+				       0, PAGE_SIZE, HWQ_TYPE_CTX);
+	if (rc)
+		goto fail;
+
+	for (i = 0; i < MAX_TQM_ALLOC_REQ; i++) {
+		if (!ctx->tqm_count[i])
+			continue;
+		ctx->tqm_tbl[i].max_elements = ctx->qpc_count *
+					       ctx->tqm_count[i];
+		rc = bnxt_qplib_alloc_init_hwq(pdev, &ctx->tqm_tbl[i], NULL, 0,
+					       &ctx->tqm_tbl[i].max_elements, 1,
+					       0, PAGE_SIZE, HWQ_TYPE_CTX);
+		if (rc)
+			goto fail;
+	}
+	pbl_ptr = (u64 **)ctx->tqm_pde.pbl_ptr;
+	for (i = 0, j = 0; i < MAX_TQM_ALLOC_REQ;
+	     i++, j += MAX_TQM_ALLOC_BLK_SIZE) {
+		if (!ctx->tqm_tbl[i].max_elements)
+			continue;
+		if (fnz_idx == -1)
+			fnz_idx = i;
+		switch (ctx->tqm_tbl[i].level) {
+		case PBL_LVL_2:
+			for (k = 0; k < ctx->tqm_tbl[i].pbl[PBL_LVL_1].pg_count;
+			     k++)
+				pbl_ptr[PTR_PG(j + k)][PTR_IDX(j + k)] =
+				  cpu_to_le64(
+				    ctx->tqm_tbl[i].pbl[PBL_LVL_1].pg_map_arr[k]
+				    | PTU_PTE_VALID);
+			break;
+		case PBL_LVL_1:
+		case PBL_LVL_0:
+		default:
+			pbl_ptr[PTR_PG(j)][PTR_IDX(j)] = cpu_to_le64(
+				ctx->tqm_tbl[i].pbl[PBL_LVL_0].pg_map_arr[0] |
+				PTU_PTE_VALID);
+			break;
+		}
+	}
+	if (fnz_idx == -1)
+		fnz_idx = 0;
+	ctx->tqm_pde_level = ctx->tqm_tbl[fnz_idx].level == PBL_LVL_2 ?
+			     PBL_LVL_2 : ctx->tqm_tbl[fnz_idx].level + 1;
+
+	/* TIM Buffer */
+	ctx->tim_tbl.max_elements = ctx->qpc_count * 16;
+	rc = bnxt_qplib_alloc_init_hwq(pdev, &ctx->tim_tbl, NULL, 0,
+				       &ctx->tim_tbl.max_elements, 1,
+				       0, PAGE_SIZE, HWQ_TYPE_CTX);
+	if (rc)
+		goto fail;
+
+stats_alloc:
+	/* Stats */
+	rc = bnxt_qplib_alloc_stats_ctx(pdev, &ctx->stats);
+	if (rc)
+		goto fail;
+
+	return 0;
+
+fail:
+	bnxt_qplib_free_ctx(pdev, ctx);
+	return rc;
+}
+
+static void bnxt_qplib_free_sgid_tbl(struct bnxt_qplib_res *res,
+				     struct bnxt_qplib_sgid_tbl *sgid_tbl)
+{
+	kfree(sgid_tbl->tbl);
+	kfree(sgid_tbl->hw_id);
+	kfree(sgid_tbl->ctx);
+	sgid_tbl->tbl = NULL;
+	sgid_tbl->hw_id = NULL;
+	sgid_tbl->ctx = NULL;
+	sgid_tbl->max = 0;
+	sgid_tbl->active = 0;
+}
+
+static int bnxt_qplib_alloc_sgid_tbl(struct bnxt_qplib_res *res,
+				     struct bnxt_qplib_sgid_tbl *sgid_tbl,
+				     u16 max)
+{
+	sgid_tbl->tbl = kcalloc(max, sizeof(struct bnxt_qplib_gid), GFP_KERNEL);
+	if (!sgid_tbl->tbl)
+		return -ENOMEM;
+
+	sgid_tbl->hw_id = kcalloc(max, sizeof(u32), GFP_KERNEL);
+	if (!sgid_tbl->hw_id)
+		goto out_free1;
+
+	sgid_tbl->ctx = kcalloc(max, sizeof(void *), GFP_KERNEL);
+	if (!sgid_tbl->ctx)
+		goto out_free2;
+
+	sgid_tbl->max = max;
+	return 0;
+out_free2:
+	kfree(sgid_tbl->hw_id);
+	sgid_tbl->hw_id = NULL;
+out_free1:
+	kfree(sgid_tbl->tbl);
+	sgid_tbl->tbl = NULL;
+	return -ENOMEM;
+};
+
+static void bnxt_qplib_cleanup_sgid_tbl(struct bnxt_qplib_res *res,
+					struct bnxt_qplib_sgid_tbl *sgid_tbl)
+{
+	int i;
+
+	memset(sgid_tbl->tbl, 0, sizeof(struct bnxt_qplib_gid) * sgid_tbl->max);
+	memset(sgid_tbl->hw_id, -1, sizeof(u16) * sgid_tbl->max);
+	sgid_tbl->active = 0;
+}
+
+static void bnxt_qplib_init_sgid_tbl(struct bnxt_qplib_sgid_tbl *sgid_tbl,
+				     struct net_device *netdev)
+{
+	memset(sgid_tbl->tbl, 0, sizeof(struct bnxt_qplib_gid) * sgid_tbl->max);
+	memset(sgid_tbl->hw_id, -1, sizeof(u16) * sgid_tbl->max);
+}
+
+static void bnxt_qplib_free_pkey_tbl(struct bnxt_qplib_res *res,
+				     struct bnxt_qplib_pkey_tbl *pkey_tbl)
+{
+	if (!pkey_tbl->tbl)
+		dev_dbg(&res->pdev->dev, "QPLIB: PKEY tbl not present");
+	else
+		kfree(pkey_tbl->tbl);
+
+	pkey_tbl->tbl = NULL;
+	pkey_tbl->max = 0;
+	pkey_tbl->active = 0;
+}
+
+static int bnxt_qplib_alloc_pkey_tbl(struct bnxt_qplib_res *res,
+				     struct bnxt_qplib_pkey_tbl *pkey_tbl,
+				     u16 max)
+{
+	pkey_tbl->tbl = kcalloc(max, sizeof(u16), GFP_KERNEL);
+	if (!pkey_tbl->tbl)
+		return -ENOMEM;
+
+	pkey_tbl->max = max;
+	return 0;
+};
+
+static void bnxt_qplib_free_pd_tbl(struct bnxt_qplib_pd_tbl *pdt)
+{
+	kfree(pdt->tbl);
+	pdt->tbl = NULL;
+	pdt->max = 0;
+}
+
+static int bnxt_qplib_alloc_pd_tbl(struct bnxt_qplib_res *res,
+				   struct bnxt_qplib_pd_tbl *pdt,
+				   u32 max)
+{
+	u32 bytes;
+
+	bytes = max >> 3;
+	if (!bytes)
+		bytes = 1;
+	pdt->tbl = kmalloc(bytes, GFP_KERNEL);
+	if (!pdt->tbl)
+		return -ENOMEM;
+
+	pdt->max = max;
+	memset((u8 *)pdt->tbl, 0xFF, bytes);
+
+	return 0;
+}
+
+/* DPIs */
+int bnxt_qplib_alloc_dpi(struct bnxt_qplib_dpi_tbl *dpit,
+			 struct bnxt_qplib_dpi     *dpi,
+			 void                      *app)
+{
+	u32 bit_num;
+
+	bit_num = find_first_bit(dpit->tbl, dpit->max);
+	if (bit_num == dpit->max)
+		return -ENOMEM;
+
+	/* Found unused DPI */
+	clear_bit(bit_num, dpit->tbl);
+	dpit->app_tbl[bit_num] = app;
+
+	dpi->dpi = bit_num;
+	dpi->dbr = dpit->dbr_bar_reg_iomem + (bit_num * PAGE_SIZE);
+	dpi->umdbr = dpit->unmapped_dbr + (bit_num * PAGE_SIZE);
+
+	return 0;
+}
+
+int bnxt_qplib_dealloc_dpi(struct bnxt_qplib_res *res,
+			   struct bnxt_qplib_dpi_tbl *dpit,
+			   struct bnxt_qplib_dpi     *dpi)
+{
+	if (dpi->dpi >= dpit->max) {
+		dev_warn(&res->pdev->dev, "Invalid DPI? dpi = %d", dpi->dpi);
+		return -EINVAL;
+	}
+	if (test_and_set_bit(dpi->dpi, dpit->tbl)) {
+		dev_warn(&res->pdev->dev, "Freeing an unused DPI? dpi = %d",
+			 dpi->dpi);
+		return -EINVAL;
+	}
+	if (dpit->app_tbl)
+		dpit->app_tbl[dpi->dpi] = NULL;
+	memset(dpi, 0, sizeof(*dpi));
+
+	return 0;
+}
+
+static void bnxt_qplib_free_dpi_tbl(struct bnxt_qplib_res     *res,
+				    struct bnxt_qplib_dpi_tbl *dpit)
+{
+	kfree(dpit->tbl);
+	kfree(dpit->app_tbl);
+	if (dpit->dbr_bar_reg_iomem)
+		pci_iounmap(res->pdev, dpit->dbr_bar_reg_iomem);
+	memset(dpit, 0, sizeof(*dpit));
+}
+
+static int bnxt_qplib_alloc_dpi_tbl(struct bnxt_qplib_res     *res,
+				    struct bnxt_qplib_dpi_tbl *dpit,
+				    u32                       dbr_offset)
+{
+	u32 dbr_bar_reg = RCFW_DBR_PCI_BAR_REGION;
+	resource_size_t bar_reg_base;
+	u32 dbr_len, bytes;
+
+	if (dpit->dbr_bar_reg_iomem) {
+		dev_err(&res->pdev->dev,
+			"QPLIB: DBR BAR region %d already mapped", dbr_bar_reg);
+		return -EALREADY;
+	}
+
+	bar_reg_base = pci_resource_start(res->pdev, dbr_bar_reg);
+	if (!bar_reg_base) {
+		dev_err(&res->pdev->dev,
+			"QPLIB: BAR region %d resc start failed", dbr_bar_reg);
+		return -ENOMEM;
+	}
+
+	dbr_len = pci_resource_len(res->pdev, dbr_bar_reg) - dbr_offset;
+	if (!dbr_len || ((dbr_len & (PAGE_SIZE - 1)) != 0)) {
+		dev_err(&res->pdev->dev, "QPLIB: Invalid DBR length %d",
+			dbr_len);
+		return -ENOMEM;
+	}
+
+	dpit->dbr_bar_reg_iomem = ioremap_nocache(bar_reg_base + dbr_offset,
+						  dbr_len);
+	if (!dpit->dbr_bar_reg_iomem) {
+		dev_err(&res->pdev->dev,
+			"QPLIB: FP: DBR BAR region %d mapping failed",
+			dbr_bar_reg);
+		return -ENOMEM;
+	}
+
+	dpit->unmapped_dbr = bar_reg_base + dbr_offset;
+	dpit->max = dbr_len / PAGE_SIZE;
+
+	dpit->app_tbl = kcalloc(dpit->max, sizeof(void *), GFP_KERNEL);
+	if (!dpit->app_tbl) {
+		pci_iounmap(res->pdev, dpit->dbr_bar_reg_iomem);
+		dev_err(&res->pdev->dev,
+			"QPLIB: DPI app tbl allocation failed");
+		return -ENOMEM;
+	}
+
+	bytes = dpit->max >> 3;
+	if (!bytes)
+		bytes = 1;
+
+	dpit->tbl = kmalloc(bytes, GFP_KERNEL);
+	if (!dpit->tbl) {
+		pci_iounmap(res->pdev, dpit->dbr_bar_reg_iomem);
+		kfree(dpit->app_tbl);
+		dpit->app_tbl = NULL;
+		dev_err(&res->pdev->dev,
+			"QPLIB: DPI tbl allocation failed for size = %d",
+			bytes);
+		return -ENOMEM;
+	}
+
+	memset((u8 *)dpit->tbl, 0xFF, bytes);
+
+	return 0;
+}
+
+/* PKEYs */
+void bnxt_qplib_cleanup_pkey_tbl(struct bnxt_qplib_pkey_tbl *pkey_tbl)
+{
+	memset(pkey_tbl->tbl, 0, sizeof(u16) * pkey_tbl->max);
+	pkey_tbl->active = 0;
+}
+
+static void bnxt_qplib_init_pkey_tbl(struct bnxt_qplib_res *res,
+				     struct bnxt_qplib_pkey_tbl *pkey_tbl)
+{
+	u16 pkey = 0xFFFF;
+
+	memset(pkey_tbl->tbl, 0, sizeof(u16) * pkey_tbl->max);
+
+	/* pkey default = 0xFFFF */
+	bnxt_qplib_add_pkey(res, pkey_tbl, &pkey, false);
+}
+
+/* Stats */
+static void bnxt_qplib_free_stats_ctx(struct pci_dev *pdev,
+				      struct bnxt_qplib_stats *stats)
+{
+	if (stats->dma) {
+		dma_free_coherent(&pdev->dev, stats->size,
+				  stats->dma, stats->dma_map);
+	}
+	memset(stats, 0, sizeof(*stats));
+	stats->fw_id = -1;
+}
+
+static int bnxt_qplib_alloc_stats_ctx(struct pci_dev *pdev,
+				      struct bnxt_qplib_stats *stats)
+{
+	memset(stats, 0, sizeof(*stats));
+	stats->fw_id = -1;
+	stats->size = sizeof(struct ctx_hw_stats);
+	stats->dma = dma_alloc_coherent(&pdev->dev, stats->size,
+					&stats->dma_map, GFP_KERNEL);
+	if (!stats->dma) {
+		dev_err(&pdev->dev, "QPLIB: Stats DMA allocation failed");
+		return -ENOMEM;
+	}
+	return 0;
+}
+
+void bnxt_qplib_cleanup_res(struct bnxt_qplib_res *res)
+{
+	bnxt_qplib_cleanup_pkey_tbl(&res->pkey_tbl);
+	bnxt_qplib_cleanup_sgid_tbl(res, &res->sgid_tbl);
+}
+
+int bnxt_qplib_init_res(struct bnxt_qplib_res *res)
+{
+	bnxt_qplib_init_sgid_tbl(&res->sgid_tbl, res->netdev);
+	bnxt_qplib_init_pkey_tbl(res, &res->pkey_tbl);
+
+	return 0;
+}
+
+void bnxt_qplib_free_res(struct bnxt_qplib_res *res)
+{
+	bnxt_qplib_free_pkey_tbl(res, &res->pkey_tbl);
+	bnxt_qplib_free_sgid_tbl(res, &res->sgid_tbl);
+	bnxt_qplib_free_pd_tbl(&res->pd_tbl);
+	bnxt_qplib_free_dpi_tbl(res, &res->dpi_tbl);
+
+	res->netdev = NULL;
+	res->pdev = NULL;
+}
+
+int bnxt_qplib_alloc_res(struct bnxt_qplib_res *res, struct pci_dev *pdev,
+			 struct net_device *netdev,
+			 struct bnxt_qplib_dev_attr *dev_attr)
+{
+	int rc = 0;
+
+	res->pdev = pdev;
+	res->netdev = netdev;
+
+	rc = bnxt_qplib_alloc_sgid_tbl(res, &res->sgid_tbl, dev_attr->max_sgid);
+	if (rc)
+		goto fail;
+
+	rc = bnxt_qplib_alloc_pkey_tbl(res, &res->pkey_tbl, dev_attr->max_pkey);
+	if (rc)
+		goto fail;
+
+	rc = bnxt_qplib_alloc_pd_tbl(res, &res->pd_tbl, dev_attr->max_pd);
+	if (rc)
+		goto fail;
+
+	rc = bnxt_qplib_alloc_dpi_tbl(res, &res->dpi_tbl, dev_attr->l2_db_size);
+	if (rc)
+		goto fail;
+
+	return 0;
+fail:
+	bnxt_qplib_free_res(res);
+	return rc;
+}
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_qplib_res.h b/drivers/infiniband/hw/bnxtre/bnxt_qplib_res.h
index 5fc4107..ce122cf 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_qplib_res.h
+++ b/drivers/infiniband/hw/bnxtre/bnxt_qplib_res.h
@@ -39,4 +39,169 @@
 #ifndef __BNXT_QPLIB_RES_H__
 #define __BNXT_QPLIB_RES_H__
 
+extern const struct bnxt_qplib_gid bnxt_qplib_gid_zero;
+
+#define PTR_CNT_PER_PG		(PAGE_SIZE / sizeof(void *))
+#define PTR_MAX_IDX_PER_PG	(PTR_CNT_PER_PG - 1)
+#define PTR_PG(x)		(((x) & ~PTR_MAX_IDX_PER_PG) / PTR_CNT_PER_PG)
+#define PTR_IDX(x)		((x) & PTR_MAX_IDX_PER_PG)
+
+#define HWQ_CMP(idx, hwq)	((idx) & ((hwq)->max_elements - 1))
+
+enum bnxt_qplib_hwq_type {
+	HWQ_TYPE_CTX,
+	HWQ_TYPE_QUEUE,
+	HWQ_TYPE_L2_CMPL
+};
+
+#define MAX_PBL_LVL_0_PGS		1
+#define MAX_PBL_LVL_1_PGS		512
+#define MAX_PBL_LVL_1_PGS_SHIFT		9
+#define MAX_PBL_LVL_1_PGS_FOR_LVL_2	256
+#define MAX_PBL_LVL_2_PGS		(256 * 512)
+
+enum bnxt_qplib_pbl_lvl {
+	PBL_LVL_0,
+	PBL_LVL_1,
+	PBL_LVL_2,
+	PBL_LVL_MAX
+};
+
+#define ROCE_PG_SIZE_4K		(4 * 1024)
+#define ROCE_PG_SIZE_8K		(8 * 1024)
+#define ROCE_PG_SIZE_64K	(64 * 1024)
+#define ROCE_PG_SIZE_2M		(2 * 1024 * 1024)
+#define ROCE_PG_SIZE_8M		(8 * 1024 * 1024)
+#define ROCE_PG_SIZE_1G		(1024 * 1024 * 1024)
+
+struct bnxt_qplib_pbl {
+	u32				pg_count;
+	u32				pg_size;
+	void				**pg_arr;
+	dma_addr_t			*pg_map_arr;
+};
+
+struct bnxt_qplib_hwq {
+	struct pci_dev			*pdev;
+	/* lock to protect qplib_hwq */
+	spinlock_t			lock;
+	struct bnxt_qplib_pbl		pbl[PBL_LVL_MAX];
+	enum bnxt_qplib_pbl_lvl		level;		/* 0, 1, or 2 */
+	/* ptr for easy access to the PBL entries */
+	void				**pbl_ptr;
+	/* ptr for easy access to the dma_addr */
+	dma_addr_t			*pbl_dma_ptr;
+	u32				max_elements;
+	u16				element_size;	/* Size of each entry */
+
+	u32				prod;		/* raw */
+	u32				cons;		/* raw */
+	u8				cp_bit;
+	u8				is_user;
+};
+
+/* Tables */
+struct bnxt_qplib_pd_tbl {
+	unsigned long			*tbl;
+	u32				max;
+};
+
+struct bnxt_qplib_sgid_tbl {
+	struct bnxt_qplib_gid		*tbl;
+	u16				*hw_id;
+	u16				max;
+	u16				active;
+	void				*ctx;
+};
+
+struct bnxt_qplib_pkey_tbl {
+	u16				*tbl;
+	u16				max;
+	u16				active;
+};
+
+struct bnxt_qplib_dpi {
+	u32				dpi;
+	void __iomem			*dbr;
+	u64				umdbr;
+};
+
+struct bnxt_qplib_dpi_tbl {
+	void				**app_tbl;
+	unsigned long			*tbl;
+	u16				max;
+	void __iomem			*dbr_bar_reg_iomem;
+	u64				unmapped_dbr;
+};
+
+struct bnxt_qplib_stats {
+	dma_addr_t			dma_map;
+	void				*dma;
+	u32				size;
+	u32				fw_id;
+};
+
+struct bnxt_qplib_vf_res {
+	u32 max_qp_per_vf;
+	u32 max_mrw_per_vf;
+	u32 max_srq_per_vf;
+	u32 max_cq_per_vf;
+	u32 max_gid_per_vf;
+};
+
+#define BNXT_QPLIB_MAX_QP_CTX_ENTRY_SIZE	448
+#define BNXT_QPLIB_MAX_SRQ_CTX_ENTRY_SIZE	64
+#define BNXT_QPLIB_MAX_CQ_CTX_ENTRY_SIZE	64
+#define BNXT_QPLIB_MAX_MRW_CTX_ENTRY_SIZE	128
+
+struct bnxt_qplib_ctx {
+	u32				qpc_count;
+	struct bnxt_qplib_hwq		qpc_tbl;
+	u32				mrw_count;
+	struct bnxt_qplib_hwq		mrw_tbl;
+	u32				srqc_count;
+	struct bnxt_qplib_hwq		srqc_tbl;
+	u32				cq_count;
+	struct bnxt_qplib_hwq		cq_tbl;
+	struct bnxt_qplib_hwq		tim_tbl;
+#define MAX_TQM_ALLOC_REQ		32
+#define MAX_TQM_ALLOC_BLK_SIZE		8
+	u8				tqm_count[MAX_TQM_ALLOC_REQ];
+	struct bnxt_qplib_hwq		tqm_pde;
+	u32				tqm_pde_level;
+	struct bnxt_qplib_hwq		tqm_tbl[MAX_TQM_ALLOC_REQ];
+	struct bnxt_qplib_stats		stats;
+	struct bnxt_qplib_vf_res	vf_res;
+};
+
+struct bnxt_qplib_res {
+	struct pci_dev			*pdev;
+	struct net_device		*netdev;
+
+	struct bnxt_qplib_rcfw		*rcfw;
+
+	struct bnxt_qplib_pd_tbl	pd_tbl;
+	struct bnxt_qplib_sgid_tbl	sgid_tbl;
+	struct bnxt_qplib_pkey_tbl	pkey_tbl;
+	struct bnxt_qplib_dpi_tbl	dpi_tbl;
+};
+
+struct bnxt_qplib_dev_attr;
+
+void bnxt_qplib_free_hwq(struct pci_dev *pdev, struct bnxt_qplib_hwq *hwq);
+int bnxt_qplib_alloc_init_hwq(struct pci_dev *pdev, struct bnxt_qplib_hwq *hwq,
+			      struct scatterlist *sl, int nmap, u32 *elements,
+			      u32 elements_per_page, u32 aux, u32 pg_size,
+			      enum bnxt_qplib_hwq_type hwq_type);
+void bnxt_qplib_cleanup_res(struct bnxt_qplib_res *res);
+int bnxt_qplib_init_res(struct bnxt_qplib_res *res);
+void bnxt_qplib_free_res(struct bnxt_qplib_res *res);
+int bnxt_qplib_alloc_res(struct bnxt_qplib_res *res, struct pci_dev *pdev,
+			 struct net_device *netdev,
+			 struct bnxt_qplib_dev_attr *dev_attr);
+void bnxt_qplib_free_ctx(struct pci_dev *pdev,
+			 struct bnxt_qplib_ctx *ctx);
+int bnxt_qplib_alloc_ctx(struct pci_dev *pdev,
+			 struct bnxt_qplib_ctx *ctx,
+			 bool virt_fn);
 #endif /* __BNXT_QPLIB_RES_H__ */
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.c b/drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.c
index 667c8e1..b3d6b46 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.c
+++ b/drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.c
@@ -35,3 +35,166 @@
  *
  * Description: Slow Path Operators
  */
+
+#include <linux/interrupt.h>
+#include <linux/spinlock.h>
+#include <linux/sched.h>
+#include <linux/pci.h>
+
+#include "bnxt_re_hsi.h"
+
+#include "bnxt_qplib_res.h"
+#include "bnxt_qplib_rcfw.h"
+#include "bnxt_qplib_sp.h"
+/* Device */
+int bnxt_qplib_get_dev_attr(struct bnxt_qplib_rcfw *rcfw,
+			    struct bnxt_qplib_dev_attr *attr)
+{
+	struct cmdq_query_func req;
+	struct creq_query_func_resp *resp;
+	struct creq_query_func_resp_sb *sb;
+	u16 cmd_flags = 0;
+	u32 temp;
+	u8 *tqm_alloc;
+	int i;
+
+	RCFW_CMD_PREP(req, QUERY_FUNC, cmd_flags);
+
+	req.resp_size = sizeof(*sb) / BNXT_QPLIB_CMDQE_UNITS;
+	resp = (struct creq_query_func_resp *)
+		bnxt_qplib_rcfw_send_message(rcfw, (void *)&req, (void **)&sb,
+					     0);
+	if (!resp) {
+		dev_err(&rcfw->pdev->dev, "QPLIB: SP: QUERY_FUNC send failed");
+		return -EINVAL;
+	}
+	if (!bnxt_qplib_rcfw_wait_for_resp(rcfw, le16_to_cpu(req.cookie))) {
+		/* Cmd timed out */
+		dev_err(&rcfw->pdev->dev, "QPLIB: SP: QUERY_FUNC timed out");
+		return -ETIMEDOUT;
+	}
+	if (RCFW_RESP_STATUS(resp) ||
+	    RCFW_RESP_COOKIE(resp) != RCFW_CMDQ_COOKIE(req)) {
+		dev_err(&rcfw->pdev->dev, "QPLIB: SP: QUERY_FUNC failed ");
+		dev_err(&rcfw->pdev->dev,
+			"QPLIB: with status 0x%x cmdq 0x%x resp 0x%x",
+			RCFW_RESP_STATUS(resp), RCFW_CMDQ_COOKIE(req),
+			RCFW_RESP_COOKIE(resp));
+		return -EINVAL;
+	}
+	/* Extract the context from the side buffer */
+	attr->max_qp = le32_to_cpu(sb->max_qp);
+	attr->max_qp_rd_atom =
+		sb->max_qp_rd_atom > BNXT_QPLIB_MAX_OUT_RD_ATOM ?
+		BNXT_QPLIB_MAX_OUT_RD_ATOM : sb->max_qp_rd_atom;
+	attr->max_qp_init_rd_atom =
+		sb->max_qp_init_rd_atom > BNXT_QPLIB_MAX_OUT_RD_ATOM ?
+		BNXT_QPLIB_MAX_OUT_RD_ATOM : sb->max_qp_init_rd_atom;
+	attr->max_qp_wqes = le16_to_cpu(sb->max_qp_wr);
+	attr->max_qp_sges = sb->max_sge;
+	attr->max_cq = le32_to_cpu(sb->max_cq);
+	attr->max_cq_wqes = le32_to_cpu(sb->max_cqe);
+	attr->max_cq_sges = attr->max_qp_sges;
+	attr->max_mr = le32_to_cpu(sb->max_mr);
+	attr->max_mw = le32_to_cpu(sb->max_mw);
+
+	attr->max_mr_size = le64_to_cpu(sb->max_mr_size);
+	attr->max_pd = 64 * 1024;
+	attr->max_raw_ethy_qp = le32_to_cpu(sb->max_raw_eth_qp);
+	attr->max_ah = le32_to_cpu(sb->max_ah);
+
+	attr->max_fmr = le32_to_cpu(sb->max_fmr);
+	attr->max_map_per_fmr = le32_to_cpu(sb->max_map_per_fmr);
+
+	attr->max_srq = le16_to_cpu(sb->max_srq);
+	attr->max_srq_wqes = le32_to_cpu(sb->max_srq_wr - 1);
+	attr->max_srq_sges = sb->max_srq_sge;
+	/* Bono only reports 1 PKEY for now, but it can support > 1 */
+	attr->max_pkey = le32_to_cpu(sb->max_pkeys);
+
+	attr->max_inline_data = le32_to_cpu(sb->max_inline_data);
+	attr->l2_db_size = (sb->l2_db_space_size + 1) * PAGE_SIZE;
+	attr->max_sgid = le32_to_cpu(sb->max_gid);
+
+	strlcpy(attr->fw_ver, "20.6.28.0", sizeof(attr->fw_ver));
+
+	for (i = 0; i < MAX_TQM_ALLOC_REQ / 4; i++) {
+		temp = le32_to_cpu(sb->tqm_alloc_reqs[i]);
+		tqm_alloc = (u8 *)&temp;
+		attr->tqm_alloc_reqs[i * 4] = *tqm_alloc;
+		attr->tqm_alloc_reqs[i * 4 + 1] = *(++tqm_alloc);
+		attr->tqm_alloc_reqs[i * 4 + 2] = *(++tqm_alloc);
+		attr->tqm_alloc_reqs[i * 4 + 3] = *(++tqm_alloc);
+	}
+	return 0;
+}
+
+int bnxt_qplib_del_pkey(struct bnxt_qplib_res *res,
+			struct bnxt_qplib_pkey_tbl *pkey_tbl, u16 *pkey,
+			bool update)
+{
+	int i, rc = 0;
+
+	if (!pkey_tbl) {
+		dev_err(&res->pdev->dev, "QPLIB: PKEY table not allocated");
+		return -EINVAL;
+	}
+
+	/* Do we need a pkey_lock here? */
+	if (!pkey_tbl->active) {
+		dev_err(&res->pdev->dev,
+			"QPLIB: PKEY table has no active entries");
+		return -ENOMEM;
+	}
+	for (i = 0; i < pkey_tbl->max; i++) {
+		if (!memcmp(&pkey_tbl->tbl[i], pkey, sizeof(*pkey)))
+			break;
+	}
+	if (i == pkey_tbl->max) {
+		dev_err(&res->pdev->dev,
+			"QPLIB: PKEY 0x%04x not found in the pkey table",
+			*pkey);
+		return -ENOMEM;
+	}
+	memset(&pkey_tbl->tbl[i], 0, sizeof(*pkey));
+	pkey_tbl->active--;
+
+	/* unlock */
+	return rc;
+}
+
+int bnxt_qplib_add_pkey(struct bnxt_qplib_res *res,
+			struct bnxt_qplib_pkey_tbl *pkey_tbl, u16 *pkey,
+			bool update)
+{
+	int i, free_idx, rc = 0;
+
+	if (!pkey_tbl) {
+		dev_err(&res->pdev->dev, "QPLIB: PKEY table not allocated");
+		return -EINVAL;
+	}
+
+	/* Do we need a pkey_lock here? */
+	if (pkey_tbl->active == pkey_tbl->max) {
+		dev_err(&res->pdev->dev, "QPLIB: PKEY table is full");
+		return -ENOMEM;
+	}
+	free_idx = pkey_tbl->max;
+	for (i = 0; i < pkey_tbl->max; i++) {
+		if (!memcmp(&pkey_tbl->tbl[i], pkey, sizeof(*pkey)))
+			return -EALREADY;
+		else if (!pkey_tbl->tbl[i] && free_idx == pkey_tbl->max)
+			free_idx = i;
+	}
+	if (free_idx == pkey_tbl->max) {
+		dev_err(&res->pdev->dev,
+			"QPLIB: PKEY table is FULL but count is not MAX??");
+		return -ENOMEM;
+	}
+	/* Add PKEY to the pkey_tbl */
+	memcpy(&pkey_tbl->tbl[free_idx], pkey, sizeof(*pkey));
+	pkey_tbl->active++;
+
+	/* unlock */
+	return rc;
+}
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.h b/drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.h
index 90901c1..0b5adda 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.h
+++ b/drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.h
@@ -40,4 +40,46 @@
 #ifndef __BNXT_QPLIB_SP_H__
 #define __BNXT_QPLIB_SP_H__
 
+struct bnxt_qplib_dev_attr {
+	char				fw_ver[32];
+	u16				max_sgid;
+	u16				max_mrw;
+	u32				max_qp;
+#define BNXT_QPLIB_MAX_OUT_RD_ATOM	126
+	u32				max_qp_rd_atom;
+	u32				max_qp_init_rd_atom;
+	u32				max_qp_wqes;
+	u32				max_qp_sges;
+	u32				max_cq;
+	u32				max_cq_wqes;
+	u32				max_cq_sges;
+	u32				max_mr;
+	u64				max_mr_size;
+	u32				max_pd;
+	u32				max_mw;
+	u32				max_raw_ethy_qp;
+	u32				max_ah;
+	u32				max_fmr;
+	u32				max_map_per_fmr;
+	u32				max_srq;
+	u32				max_srq_wqes;
+	u32				max_srq_sges;
+	u32				max_pkey;
+	u32				max_inline_data;
+	u32				l2_db_size;
+	u8				tqm_alloc_reqs[MAX_TQM_ALLOC_REQ];
+};
+
+struct bnxt_qplib_gid {
+	u8				data[16];
+};
+
+int bnxt_qplib_del_pkey(struct bnxt_qplib_res *res,
+			struct bnxt_qplib_pkey_tbl *pkey_tbl, u16 *pkey,
+			bool update);
+int bnxt_qplib_add_pkey(struct bnxt_qplib_res *res,
+			struct bnxt_qplib_pkey_tbl *pkey_tbl, u16 *pkey,
+			bool update);
+int bnxt_qplib_get_dev_attr(struct bnxt_qplib_rcfw *rcfw,
+			    struct bnxt_qplib_dev_attr *attr);
 #endif /* __BNXT_QPLIB_SP_H__*/
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_re.h b/drivers/infiniband/hw/bnxtre/bnxt_re.h
index 1fe4cb3..20abc70 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_re.h
+++ b/drivers/infiniband/hw/bnxtre/bnxt_re.h
@@ -45,6 +45,11 @@
 #define BNXT_RE_REF_WAIT_COUNT		10
 #define BNXT_RE_DESC	"Broadcom NetXtreme-C/E RoCE Driver"
 
+#define BNXT_RE_MAX_QPC_COUNT		(64 * 1024)
+#define BNXT_RE_MAX_MRW_COUNT		(64 * 1024)
+#define BNXT_RE_MAX_SRQC_COUNT		(64 * 1024)
+#define BNXT_RE_MAX_CQ_COUNT		(64 * 1024)
+
 struct bnxt_re_work {
 	struct work_struct	work;
 	unsigned long		event;
@@ -54,6 +59,7 @@ struct bnxt_re_work {
 
 #define BNXT_RE_MIN_MSIX		2
 #define BNXT_RE_MAX_MSIX		16
+#define BNXT_RE_AEQ_IDX			0
 struct bnxt_re_dev {
 	struct ib_device		ibdev;
 	struct list_head		list;
@@ -72,6 +78,15 @@ struct bnxt_re_dev {
 
 	int				id;
 
+	/* RCFW Channel */
+	struct bnxt_qplib_rcfw		rcfw;
+
+	/* Device Resources */
+	struct bnxt_qplib_dev_attr	dev_attr;
+	struct bnxt_qplib_ctx		qplib_ctx;
+	struct bnxt_qplib_res		qplib_res;
+	struct bnxt_qplib_dpi		dpi_privileged;
+
 	atomic_t			qp_count;
 	struct mutex			qp_lock;	/* protect qp list */
 	struct list_head		qp_list;
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_re_main.c b/drivers/infiniband/hw/bnxtre/bnxt_re_main.c
index 029824a..add74ba 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_re_main.c
+++ b/drivers/infiniband/hw/bnxtre/bnxt_re_main.c
@@ -54,6 +54,10 @@
 
 #include "bnxt_ulp.h"
 #include "bnxt_re_hsi.h"
+#include "bnxt_qplib_res.h"
+#include "bnxt_qplib_sp.h"
+#include "bnxt_qplib_fp.h"
+#include "bnxt_qplib_rcfw.h"
 #include "bnxt_re.h"
 #include "bnxt.h"
 static char version[] =
@@ -100,7 +104,6 @@ static inline void bnxt_re_put(struct bnxt_re_dev *rdev)
 {
 	atomic_dec(&rdev->ref_count);
 }
-
 /* RoCE -> Net driver */
 
 /* Driver registration routines used to let the networking driver (bnxt_en)
@@ -185,6 +188,160 @@ static int bnxt_re_request_msix(struct bnxt_re_dev *rdev)
 	return rc;
 }
 
+static void bnxt_re_init_hwrm_hdr(struct bnxt_re_dev *rdev, struct input *hdr,
+				  u16 opcd, u16 crid, u16 trid)
+{
+	hdr->req_type = cpu_to_le16(opcd);
+	hdr->cmpl_ring = cpu_to_le16(crid);
+	hdr->target_id = cpu_to_le16(trid);
+}
+
+static void bnxt_re_fill_fw_msg(struct bnxt_fw_msg *fw_msg, void *msg,
+				int msg_len, void *resp, int resp_max_len,
+				int timeout)
+{
+	fw_msg->msg = msg;
+	fw_msg->msg_len = msg_len;
+	fw_msg->resp = resp;
+	fw_msg->resp_max_len = resp_max_len;
+	fw_msg->timeout = timeout;
+}
+
+static int bnxt_re_net_ring_free(struct bnxt_re_dev *rdev, u16 fw_ring_id,
+				 bool lock_wait)
+{
+	struct bnxt_en_dev *en_dev = rdev->en_dev;
+	struct hwrm_ring_free_input req = {0};
+	struct hwrm_ring_free_output resp;
+	struct bnxt_fw_msg fw_msg;
+	bool do_unlock = false;
+	int rc = -EINVAL;
+
+	if (!en_dev)
+		return rc;
+
+	memset(&fw_msg, 0, sizeof(fw_msg));
+	if (lock_wait) {
+		rtnl_lock();
+		do_unlock = true;
+	}
+
+	bnxt_re_init_hwrm_hdr(rdev, (void *)&req, HWRM_RING_FREE, -1, -1);
+	req.ring_type = RING_ALLOC_REQ_RING_TYPE_CMPL;
+	req.ring_id = cpu_to_le16(fw_ring_id);
+	bnxt_re_fill_fw_msg(&fw_msg, (void *)&req, sizeof(req), (void *)&resp,
+			    sizeof(resp), DFLT_HWRM_CMD_TIMEOUT);
+	rc = en_dev->en_ops->bnxt_send_fw_msg(en_dev, BNXT_ROCE_ULP, &fw_msg);
+	if (rc)
+		dev_err(rdev_to_dev(rdev),
+			"Failed to free HW ring:%d :%#x", req.ring_id, rc);
+	if (do_unlock)
+		rtnl_unlock();
+	return rc;
+}
+
+static int bnxt_re_net_ring_alloc(struct bnxt_re_dev *rdev, dma_addr_t *dma_arr,
+				  int pages, int type, u32 ring_mask,
+				  u32 map_index, u16 *fw_ring_id)
+{
+	struct bnxt_en_dev *en_dev = rdev->en_dev;
+	struct hwrm_ring_alloc_input req = {0};
+	struct hwrm_ring_alloc_output resp;
+	struct bnxt_fw_msg fw_msg;
+	int rc = -EINVAL;
+
+	if (!en_dev)
+		return rc;
+
+	memset(&fw_msg, 0, sizeof(fw_msg));
+	rtnl_lock();
+	bnxt_re_init_hwrm_hdr(rdev, (void *)&req, HWRM_RING_ALLOC, -1, -1);
+	req.enables = 0;
+	req.page_tbl_addr =  cpu_to_le64(dma_arr[0]);
+	if (pages > 1) {
+		/* Page size is in log2 units */
+		req.page_size = BNXT_PAGE_SHIFT;
+		req.page_tbl_depth = 1;
+	}
+	req.fbo = 0;
+	/* Association of ring index with doorbell index and MSIX number */
+	req.logical_id = cpu_to_le16(map_index);
+	req.length = cpu_to_le32(ring_mask + 1);
+	req.ring_type = RING_ALLOC_REQ_RING_TYPE_CMPL;
+	req.int_mode = RING_ALLOC_REQ_INT_MODE_MSIX;
+	bnxt_re_fill_fw_msg(&fw_msg, (void *)&req, sizeof(req), (void *)&resp,
+			    sizeof(resp), DFLT_HWRM_CMD_TIMEOUT);
+	rc = en_dev->en_ops->bnxt_send_fw_msg(en_dev, BNXT_ROCE_ULP, &fw_msg);
+	if (!rc)
+		*fw_ring_id = le16_to_cpu(resp.ring_id);
+
+	rtnl_unlock();
+	return rc;
+}
+
+static int bnxt_re_net_stats_ctx_free(struct bnxt_re_dev *rdev,
+				      u32 fw_stats_ctx_id, bool lock_wait)
+{
+	struct bnxt_en_dev *en_dev = rdev->en_dev;
+	struct hwrm_stat_ctx_free_input req = {0};
+	struct bnxt_fw_msg fw_msg;
+	bool do_unlock = false;
+	int rc = -EINVAL;
+
+	if (!en_dev)
+		return rc;
+
+	memset(&fw_msg, 0, sizeof(fw_msg));
+	if (lock_wait) {
+		rtnl_lock();
+		do_unlock = true;
+	}
+
+	bnxt_re_init_hwrm_hdr(rdev, (void *)&req, HWRM_STAT_CTX_FREE, -1, -1);
+	req.stat_ctx_id = cpu_to_le32(fw_stats_ctx_id);
+	bnxt_re_fill_fw_msg(&fw_msg, (void *)&req, sizeof(req), (void *)&req,
+			    sizeof(req), DFLT_HWRM_CMD_TIMEOUT);
+	rc = en_dev->en_ops->bnxt_send_fw_msg(en_dev, BNXT_ROCE_ULP, &fw_msg);
+	if (rc)
+		dev_err(rdev_to_dev(rdev),
+			"Failed to free HW stats context %#x", rc);
+
+	if (do_unlock)
+		rtnl_unlock();
+	return rc;
+}
+
+static int bnxt_re_net_stats_ctx_alloc(struct bnxt_re_dev *rdev,
+				       dma_addr_t dma_map,
+				       u32 *fw_stats_ctx_id)
+{
+	struct hwrm_stat_ctx_alloc_output resp = {0};
+	struct hwrm_stat_ctx_alloc_input req = {0};
+	struct bnxt_en_dev *en_dev = rdev->en_dev;
+	struct bnxt_fw_msg fw_msg;
+	int rc = -EINVAL;
+
+	*fw_stats_ctx_id = INVALID_STATS_CTX_ID;
+
+	if (!en_dev)
+		return rc;
+
+	memset(&fw_msg, 0, sizeof(fw_msg));
+	rtnl_lock();
+
+	bnxt_re_init_hwrm_hdr(rdev, (void *)&req, HWRM_STAT_CTX_ALLOC, -1, -1);
+	req.update_period_ms = cpu_to_le32(1000);
+	req.stats_dma_addr = cpu_to_le64(dma_map);
+	bnxt_re_fill_fw_msg(&fw_msg, (void *)&req, sizeof(req), (void *)&resp,
+			    sizeof(resp), DFLT_HWRM_CMD_TIMEOUT);
+	rc = en_dev->en_ops->bnxt_send_fw_msg(en_dev, BNXT_ROCE_ULP, &fw_msg);
+	if (!rc)
+		*fw_stats_ctx_id = le32_to_cpu(resp.stat_ctx_id);
+
+	rtnl_unlock();
+	return rc;
+}
+
 /* Device */
 
 static bool is_bnxt_re_dev(struct net_device *netdev)
@@ -248,6 +405,64 @@ static struct bnxt_en_dev *bnxt_re_dev_probe(struct net_device *netdev)
 	return en_dev;
 }
 
+static void bnxt_re_unregister_ib(struct bnxt_re_dev *rdev)
+{
+	ib_unregister_device(&rdev->ibdev);
+}
+
+static int bnxt_re_register_ib(struct bnxt_re_dev *rdev)
+{
+	struct ib_device *ibdev = &rdev->ibdev;
+
+	/* ib device init */
+	ibdev->owner = THIS_MODULE;
+	ibdev->node_type = RDMA_NODE_IB_CA;
+	strlcpy(ibdev->name, "bnxt_re%d", IB_DEVICE_NAME_MAX);
+	strlcpy(ibdev->node_desc, BNXT_RE_DESC " HCA",
+		strlen(BNXT_RE_DESC) + 5);
+	ibdev->phys_port_cnt = 1;
+
+	ibdev->num_comp_vectors	= 1;
+	ibdev->dma_device = &rdev->en_dev->pdev->dev;
+	return ib_register_device(ibdev, NULL);
+}
+
+static ssize_t show_rev(struct device *device, struct device_attribute *attr,
+			char *buf)
+{
+	struct bnxt_re_dev *rdev = to_bnxt_re_dev(device, ibdev.dev);
+
+	return scnprintf(buf, PAGE_SIZE, "0x%x\n", rdev->en_dev->pdev->vendor);
+	strcpy(buf, "bnxt_re");
+	return 0;
+}
+
+static ssize_t show_fw_ver(struct device *device, struct device_attribute *attr,
+			   char *buf)
+{
+	struct bnxt_re_dev *rdev = to_bnxt_re_dev(device, ibdev.dev);
+
+	return scnprintf(buf, PAGE_SIZE, "%s\n", rdev->dev_attr.fw_ver);
+}
+
+static ssize_t show_hca(struct device *device, struct device_attribute *attr,
+			char *buf)
+{
+	struct bnxt_re_dev *rdev = to_bnxt_re_dev(device, ibdev.dev);
+
+	return scnprintf(buf, PAGE_SIZE, "%s\n", rdev->ibdev.node_desc);
+}
+
+static DEVICE_ATTR(hw_rev, 0444, show_rev, NULL);
+static DEVICE_ATTR(fw_rev, 0444, show_fw_ver, NULL);
+static DEVICE_ATTR(hca_type, 0444, show_hca, NULL);
+
+static struct device_attribute *bnxt_re_attributes[] = {
+	&dev_attr_hw_rev,
+	&dev_attr_fw_rev,
+	&dev_attr_hca_type
+};
+
 static void bnxt_re_dev_remove(struct bnxt_re_dev *rdev)
 {
 	int i = BNXT_RE_REF_WAIT_COUNT;
@@ -310,10 +525,109 @@ static struct bnxt_re_dev *bnxt_re_dev_add(struct net_device *netdev,
 	return rdev;
 }
 
+static int bnxt_re_aeq_handler(struct bnxt_qplib_rcfw *rcfw,
+			       struct creq_func_event *aeqe)
+{
+	switch (aeqe->event) {
+	case CREQ_FUNC_EVENT_EVENT_TX_WQE_ERROR:
+		break;
+	case CREQ_FUNC_EVENT_EVENT_TX_DATA_ERROR:
+		break;
+	case CREQ_FUNC_EVENT_EVENT_RX_WQE_ERROR:
+		break;
+	case CREQ_FUNC_EVENT_EVENT_RX_DATA_ERROR:
+		break;
+	case CREQ_FUNC_EVENT_EVENT_CQ_ERROR:
+		break;
+	case CREQ_FUNC_EVENT_EVENT_TQM_ERROR:
+		break;
+	case CREQ_FUNC_EVENT_EVENT_CFCQ_ERROR:
+		break;
+	case CREQ_FUNC_EVENT_EVENT_CFCS_ERROR:
+		break;
+	case CREQ_FUNC_EVENT_EVENT_CFCC_ERROR:
+		break;
+	case CREQ_FUNC_EVENT_EVENT_CFCM_ERROR:
+		break;
+	case CREQ_FUNC_EVENT_EVENT_TIM_ERROR:
+		break;
+	default:
+		return -EINVAL;
+	}
+	return 0;
+}
+
+static void bnxt_re_cleanup_res(struct bnxt_re_dev *rdev)
+{
+	if (rdev->qplib_res.rcfw)
+		bnxt_qplib_cleanup_res(&rdev->qplib_res);
+}
+
+static int bnxt_re_init_res(struct bnxt_re_dev *rdev)
+{
+	int rc = 0;
+
+	bnxt_qplib_init_res(&rdev->qplib_res);
+
+	return rc;
+}
+
+static void bnxt_re_free_res(struct bnxt_re_dev *rdev, bool lock_wait)
+{
+	if (rdev->qplib_res.rcfw) {
+		bnxt_qplib_free_res(&rdev->qplib_res);
+		rdev->qplib_res.rcfw = NULL;
+	}
+}
+
+static int bnxt_re_alloc_res(struct bnxt_re_dev *rdev)
+{
+	int rc = 0;
+
+	/* Configure and allocate resources for qplib */
+	rdev->qplib_res.rcfw = &rdev->rcfw;
+	rc = bnxt_qplib_get_dev_attr(&rdev->rcfw, &rdev->dev_attr);
+	if (rc)
+		goto fail;
+
+	rc = bnxt_qplib_alloc_res(&rdev->qplib_res, rdev->en_dev->pdev,
+				  rdev->netdev, &rdev->dev_attr);
+	if (rc)
+		goto fail;
+
+	return 0;
+
+fail:
+	rdev->qplib_res.rcfw = NULL;
+	return rc;
+}
+
 static void bnxt_re_ib_unreg(struct bnxt_re_dev *rdev, bool lock_wait)
 {
-	int rc;
+	int i, rc;
+
+	if (test_and_clear_bit(BNXT_RE_FLAG_IBDEV_REGISTERED, &rdev->flags)) {
+		for (i = 0; i < ARRAY_SIZE(bnxt_re_attributes); i++)
+			device_remove_file(&rdev->ibdev.dev,
+					   bnxt_re_attributes[i]);
+		/* Cleanup ib dev */
+		bnxt_re_unregister_ib(rdev);
+	}
+	bnxt_re_cleanup_res(rdev);
+	bnxt_re_free_res(rdev, lock_wait);
 
+	if (test_and_clear_bit(BNXT_RE_FLAG_RCFW_CHANNEL_EN, &rdev->flags)) {
+		rc = bnxt_qplib_deinit_rcfw(&rdev->rcfw);
+		if (rc)
+			dev_warn(rdev_to_dev(rdev),
+				 "Failed to deinitialize RCFW: %#x", rc);
+		bnxt_re_net_stats_ctx_free(rdev, rdev->qplib_ctx.stats.fw_id,
+					   lock_wait);
+		bnxt_qplib_free_ctx(rdev->en_dev->pdev, &rdev->qplib_ctx);
+		bnxt_qplib_disable_rcfw_channel(&rdev->rcfw);
+		bnxt_re_net_ring_free(rdev, rdev->rcfw.creq_ring_id, lock_wait);
+		bnxt_qplib_free_rcfw_channel(&rdev->rcfw);
+	}
 	if (test_and_clear_bit(BNXT_RE_FLAG_GOT_MSIX, &rdev->flags)) {
 		rc = bnxt_re_free_msix(rdev, lock_wait);
 		if (rc)
@@ -328,6 +642,19 @@ static void bnxt_re_ib_unreg(struct bnxt_re_dev *rdev, bool lock_wait)
 	}
 }
 
+static void bnxt_re_set_resource_limits(struct bnxt_re_dev *rdev)
+{
+	u32 i;
+
+	rdev->qplib_ctx.qpc_count = BNXT_RE_MAX_QPC_COUNT;
+	rdev->qplib_ctx.mrw_count = BNXT_RE_MAX_MRW_COUNT;
+	rdev->qplib_ctx.srqc_count = BNXT_RE_MAX_SRQC_COUNT;
+	rdev->qplib_ctx.cq_count = BNXT_RE_MAX_CQ_COUNT;
+	for (i = 0; i < MAX_TQM_ALLOC_REQ; i++)
+		rdev->qplib_ctx.tqm_count[i] =
+		rdev->dev_attr.tqm_alloc_reqs[i];
+}
+
 static int bnxt_re_ib_reg(struct bnxt_re_dev *rdev)
 {
 	int i, j, rc;
@@ -348,6 +675,103 @@ static int bnxt_re_ib_reg(struct bnxt_re_dev *rdev)
 	}
 	set_bit(BNXT_RE_FLAG_GOT_MSIX, &rdev->flags);
 
+	/* Establish RCFW Communication Channel to initialize the context
+	 * memory for the function and all child VFs
+	 */
+	rc = bnxt_qplib_alloc_rcfw_channel(rdev->en_dev->pdev, &rdev->rcfw);
+	if (rc)
+		goto fail;
+
+	rc = bnxt_re_net_ring_alloc
+			(rdev, rdev->rcfw.creq.pbl[PBL_LVL_0].pg_map_arr,
+			 rdev->rcfw.creq.pbl[rdev->rcfw.creq.level].pg_count,
+			 HWRM_RING_ALLOC_CMPL, BNXT_QPLIB_CREQE_MAX_CNT - 1,
+			 rdev->msix_entries[BNXT_RE_AEQ_IDX].ring_idx,
+			 &rdev->rcfw.creq_ring_id);
+	if (rc) {
+		pr_err("Failed to allocate CREQ: %#x\n", rc);
+		goto free_rcfw;
+	}
+	rc = bnxt_qplib_enable_rcfw_channel
+				(rdev->en_dev->pdev, &rdev->rcfw,
+				 rdev->msix_entries[BNXT_RE_AEQ_IDX].vector,
+				 rdev->msix_entries[BNXT_RE_AEQ_IDX].db_offset,
+				 0, &bnxt_re_aeq_handler);
+	if (rc) {
+		pr_err("Failed to enable RCFW channel: %#x\n", rc);
+		goto free_ring;
+	}
+
+	rc = bnxt_qplib_get_dev_attr(&rdev->rcfw, &rdev->dev_attr);
+	if (rc)
+		goto disable_rcfw;
+		bnxt_re_set_resource_limits(rdev);
+
+	rc = bnxt_qplib_alloc_ctx(rdev->en_dev->pdev, &rdev->qplib_ctx, 0);
+	if (rc) {
+		pr_err("Failed to allocate QPLIB context: %#x\n", rc);
+		goto disable_rcfw;
+	}
+	rc = bnxt_re_net_stats_ctx_alloc(rdev,
+					 rdev->qplib_ctx.stats.dma_map,
+					 &rdev->qplib_ctx.stats.fw_id);
+	if (rc) {
+		pr_err("Failed to allocate stats context: %#x\n", rc);
+		goto free_ctx;
+	}
+
+	rc = bnxt_qplib_init_rcfw(&rdev->rcfw, &rdev->qplib_ctx, 0);
+	if (rc) {
+		pr_err("Failed to initialize RCFW: %#x\n", rc);
+		goto free_sctx;
+	}
+	set_bit(BNXT_RE_FLAG_RCFW_CHANNEL_EN, &rdev->flags);
+
+	/* Resources based on the 'new' device caps */
+	rc = bnxt_re_alloc_res(rdev);
+	if (rc) {
+		pr_err("Failed to allocate resources: %#x\n", rc);
+		goto fail;
+	}
+	rc = bnxt_re_init_res(rdev);
+	if (rc) {
+		pr_err("Failed to initialize resources: %#x\n", rc);
+		goto fail;
+	}
+
+	/* Register ib dev */
+	rc = bnxt_re_register_ib(rdev);
+	if (rc) {
+		pr_err("Failed to register with IB: %#x\n", rc);
+		goto fail;
+	}
+	for (i = 0; i < ARRAY_SIZE(bnxt_re_attributes); i++) {
+		rc = device_create_file(&rdev->ibdev.dev,
+					bnxt_re_attributes[i]);
+		if (rc) {
+			dev_err(rdev_to_dev(rdev),
+				"Failed to create IB sysfs: %#x", rc);
+			/* Must clean up all created device files */
+			for (j = 0; j < i; j++)
+				device_remove_file(&rdev->ibdev.dev,
+						   bnxt_re_attributes[j]);
+			bnxt_re_unregister_ib(rdev);
+			goto fail;
+		}
+	}
+	set_bit(BNXT_RE_FLAG_IBDEV_REGISTERED, &rdev->flags);
+
+	return 0;
+free_sctx:
+	bnxt_re_net_stats_ctx_free(rdev, rdev->qplib_ctx.stats.fw_id, true);
+free_ctx:
+	bnxt_qplib_free_ctx(rdev->en_dev->pdev, &rdev->qplib_ctx);
+disable_rcfw:
+	bnxt_qplib_disable_rcfw_channel(&rdev->rcfw);
+free_ring:
+	bnxt_re_net_ring_free(rdev, rdev->rcfw.creq_ring_id, true);
+free_rcfw:
+	bnxt_qplib_free_rcfw_channel(&rdev->rcfw);
 fail:
 	bnxt_re_ib_unreg(rdev, true);
 	return rc;
@@ -392,7 +816,6 @@ static void bnxt_re_remove_one(struct bnxt_re_dev *rdev)
 {
 	pci_dev_put(rdev->en_dev->pdev);
 }
-
 /* Handle all deferred netevents tasks */
 static void bnxt_re_task(struct work_struct *work)
 {
@@ -415,14 +838,10 @@ static void bnxt_re_task(struct work_struct *work)
 				"Failed to register with IB: %#x", rc);
 			break;
 	case NETDEV_UP:
-
 		break;
 	case NETDEV_DOWN:
-
 		break;
-
 	case NETDEV_CHANGE:
-
 		break;
 	default:
 		break;
-- 
2.5.5
