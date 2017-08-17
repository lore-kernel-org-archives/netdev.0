From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Subject: [PATCH V6 16/21] net-next/hinic: Add cmdq commands
Date: Thu, 17 Aug 2017 20:25:24 +0800
Message-ID: <9ba8310ca6bc9ed8bb6bae0ce05ba0a7ae4cf87c.1502972068.git.aviad.krawczyk@huawei.com>
References: <cover.1502972068.git.aviad.krawczyk@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <bc.y@huawei.com>, <victor.gissin@huawei.com>,
        <aviad.krawczyk@huawei.com>, <zhaochen6@huawei.com>,
        <tony.qu@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1502972068.git.aviad.krawczyk@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add cmdq commands for setting queue pair contexts in the nic.

Signed-off-by: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Signed-off-by: Zhao Chen <zhaochen6@huawei.com>
---
 drivers/net/ethernet/huawei/hinic/hinic_common.c  |  25 ++
 drivers/net/ethernet/huawei/hinic/hinic_common.h  |   9 +
 drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.c | 282 +++++++++++++++++++++-
 drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.h |  38 +++
 drivers/net/ethernet/huawei/hinic/hinic_hw_io.h   |  10 +
 drivers/net/ethernet/huawei/hinic/hinic_hw_wq.c   | 194 +++++++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_wq.h   |  12 +
 drivers/net/ethernet/huawei/hinic/hinic_hw_wqe.h  | 115 +++++++++
 8 files changed, 683 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/huawei/hinic/hinic_common.c b/drivers/net/ethernet/huawei/hinic/hinic_common.c
index 1915ad6..02c74fd 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_common.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_common.c
@@ -13,6 +13,7 @@
  *
  */
 
+#include <linux/kernel.h>
 #include <linux/types.h>
 #include <asm/byteorder.h>
 
@@ -53,3 +54,27 @@ void hinic_be32_to_cpu(void *data, int len)
 		mem++;
 	}
 }
+
+/**
+ * hinic_set_sge - set dma area in scatter gather entry
+ * @sge: scatter gather entry
+ * @addr: dma address
+ * @len: length of relevant data in the dma address
+ **/
+void hinic_set_sge(struct hinic_sge *sge, dma_addr_t addr, int len)
+{
+	sge->hi_addr = upper_32_bits(addr);
+	sge->lo_addr = lower_32_bits(addr);
+	sge->len  = len;
+}
+
+/**
+ * hinic_sge_to_dma - get dma address from scatter gather entry
+ * @sge: scatter gather entry
+ *
+ * Return dma address of sg entry
+ **/
+dma_addr_t hinic_sge_to_dma(struct hinic_sge *sge)
+{
+	return (dma_addr_t)((((u64)sge->hi_addr) << 32) | sge->lo_addr);
+}
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_common.h b/drivers/net/ethernet/huawei/hinic/hinic_common.h
index 0f2f4ff..2c06b76 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_common.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_common.h
@@ -16,6 +16,11 @@
 #ifndef HINIC_COMMON_H
 #define HINIC_COMMON_H
 
+#include <linux/types.h>
+
+#define UPPER_8_BITS(data)      (((data) >> 8) & 0xFF)
+#define LOWER_8_BITS(data)      ((data) & 0xFF)
+
 struct hinic_sge {
 	u32             hi_addr;
 	u32             lo_addr;
@@ -26,4 +31,8 @@ struct hinic_sge {
 
 void hinic_be32_to_cpu(void *data, int len);
 
+void hinic_set_sge(struct hinic_sge *sge, dma_addr_t addr, int len);
+
+dma_addr_t hinic_sge_to_dma(struct hinic_sge *sge);
+
 #endif
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.c
index ec24b95..d8c0807 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.c
@@ -24,19 +24,34 @@
 #include <linux/sizes.h>
 #include <linux/atomic.h>
 #include <linux/log2.h>
+#include <linux/io.h>
+#include <linux/completion.h>
+#include <linux/err.h>
 #include <asm/byteorder.h>
+#include <asm/barrier.h>
 
+#include "hinic_common.h"
 #include "hinic_hw_if.h"
 #include "hinic_hw_eqs.h"
 #include "hinic_hw_mgmt.h"
+#include "hinic_hw_wqe.h"
 #include "hinic_hw_wq.h"
 #include "hinic_hw_cmdq.h"
 #include "hinic_hw_io.h"
 #include "hinic_hw_dev.h"
 
+#define CMDQ_DB_PI_OFF(pi)              (((u16)LOWER_8_BITS(pi)) << 3)
+
+#define CMDQ_DB_ADDR(db_base, pi)       ((db_base) + CMDQ_DB_PI_OFF(pi))
+
+#define CMDQ_WQE_HEADER(wqe)            ((struct hinic_cmdq_header *)(wqe))
+
+#define FIRST_DATA_TO_WRITE_LAST        sizeof(u64)
+
 #define CMDQ_DB_OFF                     SZ_2K
 
 #define CMDQ_WQEBB_SIZE                 64
+#define CMDQ_WQE_SIZE                   64
 #define CMDQ_DEPTH                      SZ_4K
 
 #define CMDQ_WQ_PAGE_SIZE               SZ_4K
@@ -44,6 +59,10 @@
 #define WQE_LCMD_SIZE                   64
 #define WQE_SCMD_SIZE                   64
 
+#define COMPLETE_LEN                    3
+
+#define CMDQ_TIMEOUT                    1000
+
 #define CMDQ_PFN(addr, page_size)       ((addr) >> (ilog2(page_size)))
 
 #define cmdq_to_cmdqs(cmdq)     container_of((cmdq) - (cmdq)->cmdq_type, \
@@ -58,6 +77,40 @@ enum cmdq_wqe_type {
 	WQE_SCMD_TYPE = 1,
 };
 
+enum completion_format {
+	COMPLETE_DIRECT = 0,
+	COMPLETE_SGE    = 1,
+};
+
+enum data_format {
+	DATA_SGE        = 0,
+	DATA_DIRECT     = 1,
+};
+
+enum bufdesc_len {
+	BUFDESC_LCMD_LEN = 2,   /* 16 bytes - 2(8 byte unit) */
+	BUFDESC_SCMD_LEN = 3,   /* 24 bytes - 3(8 byte unit) */
+};
+
+enum ctrl_sect_len {
+	CTRL_SECT_LEN        = 1, /* 4 bytes (ctrl) - 1(8 byte unit) */
+	CTRL_DIRECT_SECT_LEN = 2, /* 12 bytes (ctrl + rsvd) - 2(8 byte unit) */
+};
+
+enum cmdq_scmd_type {
+	CMDQ_SET_ARM_CMD = 2,
+};
+
+enum cmdq_cmd_type {
+	CMDQ_CMD_SYNC_DIRECT_RESP = 0,
+	CMDQ_CMD_SYNC_SGE_RESP    = 1,
+};
+
+enum completion_request {
+	NO_CEQ  = 0,
+	CEQ_SET = 1,
+};
+
 /**
  * hinic_alloc_cmdq_buf - alloc buffer for sending command
  * @cmdqs: the cmdqs
@@ -92,6 +145,221 @@ void hinic_free_cmdq_buf(struct hinic_cmdqs *cmdqs,
 	pci_pool_free(cmdqs->cmdq_buf_pool, cmdq_buf->buf, cmdq_buf->dma_addr);
 }
 
+static void cmdq_set_sge_completion(struct hinic_cmdq_completion *completion,
+				    struct hinic_cmdq_buf *buf_out)
+{
+	struct hinic_sge_resp *sge_resp = &completion->sge_resp;
+
+	hinic_set_sge(&sge_resp->sge, buf_out->dma_addr,
+		      buf_out->size);
+}
+
+static void cmdq_prepare_wqe_ctrl(struct hinic_cmdq_wqe *wqe, int wrapped,
+				  enum hinic_cmd_ack_type ack_type,
+				  enum hinic_mod_type mod, u8 cmd, u16 prod_idx,
+				  enum completion_format complete_format,
+				  enum data_format data_format,
+				  enum bufdesc_len buf_len)
+{
+	struct hinic_cmdq_wqe_lcmd *wqe_lcmd;
+	struct hinic_cmdq_wqe_scmd *wqe_scmd;
+	enum ctrl_sect_len ctrl_len;
+	struct hinic_ctrl *ctrl;
+	u32 saved_data;
+
+	if (data_format == DATA_SGE) {
+		wqe_lcmd = &wqe->wqe_lcmd;
+
+		wqe_lcmd->status.status_info = 0;
+		ctrl = &wqe_lcmd->ctrl;
+		ctrl_len = CTRL_SECT_LEN;
+	} else {
+		wqe_scmd = &wqe->direct_wqe.wqe_scmd;
+
+		wqe_scmd->status.status_info = 0;
+		ctrl = &wqe_scmd->ctrl;
+		ctrl_len = CTRL_DIRECT_SECT_LEN;
+	}
+
+	ctrl->ctrl_info = HINIC_CMDQ_CTRL_SET(prod_idx, PI)             |
+			  HINIC_CMDQ_CTRL_SET(cmd, CMD)                 |
+			  HINIC_CMDQ_CTRL_SET(mod, MOD)                 |
+			  HINIC_CMDQ_CTRL_SET(ack_type, ACK_TYPE);
+
+	CMDQ_WQE_HEADER(wqe)->header_info =
+		HINIC_CMDQ_WQE_HEADER_SET(buf_len, BUFDESC_LEN)            |
+		HINIC_CMDQ_WQE_HEADER_SET(complete_format, COMPLETE_FMT)   |
+		HINIC_CMDQ_WQE_HEADER_SET(data_format, DATA_FMT)           |
+		HINIC_CMDQ_WQE_HEADER_SET(CEQ_SET, COMPLETE_REQ)           |
+		HINIC_CMDQ_WQE_HEADER_SET(COMPLETE_LEN, COMPLETE_SECT_LEN) |
+		HINIC_CMDQ_WQE_HEADER_SET(ctrl_len, CTRL_LEN)              |
+		HINIC_CMDQ_WQE_HEADER_SET(wrapped, TOGGLED_WRAPPED);
+
+	saved_data = CMDQ_WQE_HEADER(wqe)->saved_data;
+	saved_data = HINIC_SAVED_DATA_CLEAR(saved_data, ARM);
+
+	if ((cmd == CMDQ_SET_ARM_CMD) && (mod == HINIC_MOD_COMM))
+		CMDQ_WQE_HEADER(wqe)->saved_data |=
+						HINIC_SAVED_DATA_SET(1, ARM);
+	else
+		CMDQ_WQE_HEADER(wqe)->saved_data = saved_data;
+}
+
+static void cmdq_set_lcmd_bufdesc(struct hinic_cmdq_wqe_lcmd *wqe_lcmd,
+				  struct hinic_cmdq_buf *buf_in)
+{
+	hinic_set_sge(&wqe_lcmd->buf_desc.sge, buf_in->dma_addr, buf_in->size);
+}
+
+static void cmdq_set_lcmd_wqe(struct hinic_cmdq_wqe *wqe,
+			      enum cmdq_cmd_type cmd_type,
+			      struct hinic_cmdq_buf *buf_in,
+			      struct hinic_cmdq_buf *buf_out, int wrapped,
+			      enum hinic_cmd_ack_type ack_type,
+			      enum hinic_mod_type mod, u8 cmd, u16 prod_idx)
+{
+	struct hinic_cmdq_wqe_lcmd *wqe_lcmd = &wqe->wqe_lcmd;
+	enum completion_format complete_format;
+
+	switch (cmd_type) {
+	case CMDQ_CMD_SYNC_SGE_RESP:
+		complete_format = COMPLETE_SGE;
+		cmdq_set_sge_completion(&wqe_lcmd->completion, buf_out);
+		break;
+	case CMDQ_CMD_SYNC_DIRECT_RESP:
+		complete_format = COMPLETE_DIRECT;
+		wqe_lcmd->completion.direct_resp = 0;
+		break;
+	}
+
+	cmdq_prepare_wqe_ctrl(wqe, wrapped, ack_type, mod, cmd,
+			      prod_idx, complete_format, DATA_SGE,
+			      BUFDESC_LCMD_LEN);
+
+	cmdq_set_lcmd_bufdesc(wqe_lcmd, buf_in);
+}
+
+static void cmdq_wqe_fill(void *dst, void *src)
+{
+	memcpy(dst + FIRST_DATA_TO_WRITE_LAST, src + FIRST_DATA_TO_WRITE_LAST,
+	       CMDQ_WQE_SIZE - FIRST_DATA_TO_WRITE_LAST);
+
+	wmb();          /* The first 8 bytes should be written last */
+
+	*(u64 *)dst = *(u64 *)src;
+}
+
+static void cmdq_fill_db(u32 *db_info,
+			 enum hinic_cmdq_type cmdq_type, u16 prod_idx)
+{
+	*db_info = HINIC_CMDQ_DB_INFO_SET(UPPER_8_BITS(prod_idx), HI_PROD_IDX) |
+		   HINIC_CMDQ_DB_INFO_SET(HINIC_CTRL_PATH, PATH)               |
+		   HINIC_CMDQ_DB_INFO_SET(cmdq_type, CMDQ_TYPE)                |
+		   HINIC_CMDQ_DB_INFO_SET(HINIC_DB_CMDQ_TYPE, DB_TYPE);
+}
+
+static void cmdq_set_db(struct hinic_cmdq *cmdq,
+			enum hinic_cmdq_type cmdq_type, u16 prod_idx)
+{
+	u32 db_info;
+
+	cmdq_fill_db(&db_info, cmdq_type, prod_idx);
+
+	/* The data that is written to HW should be in Big Endian Format */
+	db_info = cpu_to_be32(db_info);
+
+	wmb();  /* write all before the doorbell */
+
+	writel(db_info, CMDQ_DB_ADDR(cmdq->db_base, prod_idx));
+}
+
+static int cmdq_sync_cmd_direct_resp(struct hinic_cmdq *cmdq,
+				     enum hinic_mod_type mod, u8 cmd,
+				     struct hinic_cmdq_buf *buf_in,
+				     u64 *resp)
+{
+	struct hinic_cmdq_wqe *curr_cmdq_wqe, cmdq_wqe;
+	u16 curr_prod_idx, next_prod_idx;
+	int errcode, wrapped, num_wqebbs;
+	struct hinic_wq *wq = cmdq->wq;
+	struct hinic_hw_wqe *hw_wqe;
+	struct completion done;
+
+	/* Keep doorbell index correct. bh - for tasklet(ceq). */
+	spin_lock_bh(&cmdq->cmdq_lock);
+
+	/* WQE_SIZE = WQEBB_SIZE, we will get the wq element and not shadow*/
+	hw_wqe = hinic_get_wqe(wq, WQE_LCMD_SIZE, &curr_prod_idx);
+	if (IS_ERR(hw_wqe)) {
+		spin_unlock_bh(&cmdq->cmdq_lock);
+		return -EBUSY;
+	}
+
+	curr_cmdq_wqe = &hw_wqe->cmdq_wqe;
+
+	wrapped = cmdq->wrapped;
+
+	num_wqebbs = ALIGN(WQE_LCMD_SIZE, wq->wqebb_size) / wq->wqebb_size;
+	next_prod_idx = curr_prod_idx + num_wqebbs;
+	if (next_prod_idx >= wq->q_depth) {
+		cmdq->wrapped = !cmdq->wrapped;
+		next_prod_idx -= wq->q_depth;
+	}
+
+	cmdq->errcode[curr_prod_idx] = &errcode;
+
+	init_completion(&done);
+	cmdq->done[curr_prod_idx] = &done;
+
+	cmdq_set_lcmd_wqe(&cmdq_wqe, CMDQ_CMD_SYNC_DIRECT_RESP, buf_in, NULL,
+			  wrapped, HINIC_CMD_ACK_TYPE_CMDQ, mod, cmd,
+			  curr_prod_idx);
+
+	/* The data that is written to HW should be in Big Endian Format */
+	hinic_cpu_to_be32(&cmdq_wqe, WQE_LCMD_SIZE);
+
+	/* CMDQ WQE is not shadow, therefore wqe will be written to wq */
+	cmdq_wqe_fill(curr_cmdq_wqe, &cmdq_wqe);
+
+	cmdq_set_db(cmdq, HINIC_CMDQ_SYNC, next_prod_idx);
+
+	spin_unlock_bh(&cmdq->cmdq_lock);
+
+	if (!wait_for_completion_timeout(&done, CMDQ_TIMEOUT)) {
+		spin_lock_bh(&cmdq->cmdq_lock);
+
+		if (cmdq->errcode[curr_prod_idx] == &errcode)
+			cmdq->errcode[curr_prod_idx] = NULL;
+
+		if (cmdq->done[curr_prod_idx] == &done)
+			cmdq->done[curr_prod_idx] = NULL;
+
+		spin_unlock_bh(&cmdq->cmdq_lock);
+
+		return -ETIMEDOUT;
+	}
+
+	smp_rmb();      /* read error code after completion */
+
+	if (resp) {
+		struct hinic_cmdq_wqe_lcmd *wqe_lcmd = &curr_cmdq_wqe->wqe_lcmd;
+		*resp = cpu_to_be64(wqe_lcmd->completion.direct_resp);
+	}
+
+	if (errcode != 0)
+		return -EFAULT;
+
+	return 0;
+}
+
+static int cmdq_params_valid(struct hinic_cmdq_buf *buf_in)
+{
+	if (buf_in->size > HINIC_CMDQ_MAX_DATA_SIZE)
+		return -EINVAL;
+
+	return 0;
+}
+
 /**
  * hinic_cmdq_direct_resp - send command with direct data as resp
  * @cmdqs: the cmdqs
@@ -106,8 +374,18 @@ int hinic_cmdq_direct_resp(struct hinic_cmdqs *cmdqs,
 			   enum hinic_mod_type mod, u8 cmd,
 			   struct hinic_cmdq_buf *buf_in, u64 *resp)
 {
-	/* should be implemented */
-	return -EINVAL;
+	struct hinic_hwif *hwif = cmdqs->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	int err;
+
+	err = cmdq_params_valid(buf_in);
+	if (err) {
+		dev_err(&pdev->dev, "Invalid CMDQ parameters\n");
+		return err;
+	}
+
+	return cmdq_sync_cmd_direct_resp(&cmdqs->cmdq[HINIC_CMDQ_SYNC],
+					 mod, cmd, buf_in, resp);
 }
 
 /**
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.h
index 5ec59f1..e11a4f0 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.h
@@ -58,14 +58,52 @@
 			((val) & (~((u64)HINIC_CMDQ_CTXT_##member##_MASK \
 			 << HINIC_CMDQ_CTXT_##member##_SHIFT)))
 
+#define HINIC_SAVED_DATA_ARM_SHIFT                      31
+
+#define HINIC_SAVED_DATA_ARM_MASK                       0x1
+
+#define HINIC_SAVED_DATA_SET(val, member)               \
+			(((u32)(val) & HINIC_SAVED_DATA_##member##_MASK) \
+			 << HINIC_SAVED_DATA_##member##_SHIFT)
+
+#define HINIC_SAVED_DATA_GET(val, member)               \
+			(((val) >> HINIC_SAVED_DATA_##member##_SHIFT) \
+			 & HINIC_SAVED_DATA_##member##_MASK)
+
+#define HINIC_SAVED_DATA_CLEAR(val, member)             \
+			((val) & (~(HINIC_SAVED_DATA_##member##_MASK \
+			 << HINIC_SAVED_DATA_##member##_SHIFT)))
+
+#define HINIC_CMDQ_DB_INFO_HI_PROD_IDX_SHIFT            0
+#define HINIC_CMDQ_DB_INFO_PATH_SHIFT                   23
+#define HINIC_CMDQ_DB_INFO_CMDQ_TYPE_SHIFT              24
+#define HINIC_CMDQ_DB_INFO_DB_TYPE_SHIFT                27
+
+#define HINIC_CMDQ_DB_INFO_HI_PROD_IDX_MASK             0xFF
+#define HINIC_CMDQ_DB_INFO_PATH_MASK                    0x1
+#define HINIC_CMDQ_DB_INFO_CMDQ_TYPE_MASK               0x7
+#define HINIC_CMDQ_DB_INFO_DB_TYPE_MASK                 0x1F
+
+#define HINIC_CMDQ_DB_INFO_SET(val, member)             \
+			(((u32)(val) & HINIC_CMDQ_DB_INFO_##member##_MASK) \
+			 << HINIC_CMDQ_DB_INFO_##member##_SHIFT)
+
 #define HINIC_CMDQ_BUF_SIZE             2048
 
+#define HINIC_CMDQ_BUF_HW_RSVD          8
+#define HINIC_CMDQ_MAX_DATA_SIZE        (HINIC_CMDQ_BUF_SIZE - \
+					 HINIC_CMDQ_BUF_HW_RSVD)
+
 enum hinic_cmdq_type {
 	HINIC_CMDQ_SYNC,
 
 	HINIC_MAX_CMDQ_TYPES,
 };
 
+enum hinic_cmd_ack_type {
+	HINIC_CMD_ACK_TYPE_CMDQ,
+};
+
 struct hinic_cmdq_buf {
 	void            *buf;
 	dma_addr_t      dma_addr;
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_io.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_io.h
index cfc21ba..adb6417 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_io.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_io.h
@@ -32,6 +32,16 @@
 
 #define HINIC_DB_MAX_AREAS      (HINIC_DB_SIZE / HINIC_DB_PAGE_SIZE)
 
+enum hinic_db_type {
+	HINIC_DB_CMDQ_TYPE,
+	HINIC_DB_SQ_TYPE,
+};
+
+enum hinic_io_path {
+	HINIC_CTRL_PATH,
+	HINIC_DATA_PATH,
+};
+
 struct hinic_free_db_area {
 	int             db_idx[HINIC_DB_MAX_AREAS];
 
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_wq.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_wq.c
index 5a3689a..a22e201 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_wq.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_wq.c
@@ -23,9 +23,11 @@
 #include <linux/semaphore.h>
 #include <linux/errno.h>
 #include <linux/vmalloc.h>
+#include <linux/err.h>
 #include <asm/byteorder.h>
 
 #include "hinic_hw_if.h"
+#include "hinic_hw_wqe.h"
 #include "hinic_hw_wq.h"
 #include "hinic_hw_cmdq.h"
 
@@ -72,6 +74,25 @@
 			((void *)((cmdq_pages)->shadow_page_vaddr) \
 				+ (wq)->block_idx * CMDQ_BLOCK_SIZE)
 
+#define WQE_PAGE_OFF(wq, idx)   (((idx) & ((wq)->num_wqebbs_per_page - 1)) * \
+					(wq)->wqebb_size)
+
+#define WQE_PAGE_NUM(wq, idx)   (((idx) / ((wq)->num_wqebbs_per_page)) \
+					& ((wq)->num_q_pages - 1))
+
+#define WQ_PAGE_ADDR(wq, idx)           \
+			((wq)->shadow_block_vaddr[WQE_PAGE_NUM(wq, idx)])
+
+#define MASKED_WQE_IDX(wq, idx)         ((idx) & (wq)->mask)
+
+#define WQE_IN_RANGE(wqe, start, end)   \
+		(((unsigned long)(wqe) >= (unsigned long)(start)) && \
+		 ((unsigned long)(wqe) < (unsigned long)(end)))
+
+#define WQE_SHADOW_PAGE(wq, wqe)        \
+		(((unsigned long)(wqe) - (unsigned long)(wq)->shadow_wqe) \
+			/ (wq)->max_wqe_size)
+
 /**
  * queue_alloc_page - allocate page for Queue
  * @hwif: HW interface for allocating DMA
@@ -671,3 +692,176 @@ void hinic_wqs_cmdq_free(struct hinic_cmdq_pages *cmdq_pages,
 
 	cmdq_free_page(cmdq_pages);
 }
+
+static void copy_wqe_to_shadow(struct hinic_wq *wq, void *shadow_addr,
+			       int num_wqebbs, u16 idx)
+{
+	void *wqebb_addr;
+	int i;
+
+	for (i = 0; i < num_wqebbs; i++, idx++) {
+		idx = MASKED_WQE_IDX(wq, idx);
+		wqebb_addr = WQ_PAGE_ADDR(wq, idx) +
+			     WQE_PAGE_OFF(wq, idx);
+
+		memcpy(shadow_addr, wqebb_addr, wq->wqebb_size);
+
+		shadow_addr += wq->wqebb_size;
+	}
+}
+
+static void copy_wqe_from_shadow(struct hinic_wq *wq, void *shadow_addr,
+				 int num_wqebbs, u16 idx)
+{
+	void *wqebb_addr;
+	int i;
+
+	for (i = 0; i < num_wqebbs; i++, idx++) {
+		idx = MASKED_WQE_IDX(wq, idx);
+		wqebb_addr = WQ_PAGE_ADDR(wq, idx) +
+			     WQE_PAGE_OFF(wq, idx);
+
+		memcpy(wqebb_addr, shadow_addr, wq->wqebb_size);
+		shadow_addr += wq->wqebb_size;
+	}
+}
+
+/**
+ * hinic_get_wqe - get wqe ptr in the current pi and update the pi
+ * @wq: wq to get wqe from
+ * @wqe_size: wqe size
+ * @prod_idx: returned pi
+ *
+ * Return wqe pointer
+ **/
+struct hinic_hw_wqe *hinic_get_wqe(struct hinic_wq *wq, unsigned int wqe_size,
+				   u16 *prod_idx)
+{
+	int curr_pg, end_pg, num_wqebbs;
+	u16 curr_prod_idx, end_prod_idx;
+
+	*prod_idx = MASKED_WQE_IDX(wq, atomic_read(&wq->prod_idx));
+
+	num_wqebbs = ALIGN(wqe_size, wq->wqebb_size) / wq->wqebb_size;
+
+	if (atomic_sub_return(num_wqebbs, &wq->delta) <= 0) {
+		atomic_add(num_wqebbs, &wq->delta);
+		return ERR_PTR(-EBUSY);
+	}
+
+	end_prod_idx = atomic_add_return(num_wqebbs, &wq->prod_idx);
+
+	end_prod_idx = MASKED_WQE_IDX(wq, end_prod_idx);
+	curr_prod_idx = end_prod_idx - num_wqebbs;
+	curr_prod_idx = MASKED_WQE_IDX(wq, curr_prod_idx);
+
+	/* end prod index points to the next wqebb, therefore minus 1 */
+	end_prod_idx = MASKED_WQE_IDX(wq, end_prod_idx - 1);
+
+	curr_pg = WQE_PAGE_NUM(wq, curr_prod_idx);
+	end_pg = WQE_PAGE_NUM(wq, end_prod_idx);
+
+	*prod_idx = curr_prod_idx;
+
+	if (curr_pg != end_pg) {
+		void *shadow_addr = &wq->shadow_wqe[curr_pg * wq->max_wqe_size];
+
+		copy_wqe_to_shadow(wq, shadow_addr, num_wqebbs, *prod_idx);
+
+		wq->shadow_idx[curr_pg] = *prod_idx;
+		return shadow_addr;
+	}
+
+	return WQ_PAGE_ADDR(wq, *prod_idx) + WQE_PAGE_OFF(wq, *prod_idx);
+}
+
+/**
+ * hinic_put_wqe - return the wqe place to use for a new wqe
+ * @wq: wq to return wqe
+ * @wqe_size: wqe size
+ **/
+void hinic_put_wqe(struct hinic_wq *wq, unsigned int wqe_size)
+{
+	int num_wqebbs = ALIGN(wqe_size, wq->wqebb_size) / wq->wqebb_size;
+
+	atomic_add(num_wqebbs, &wq->cons_idx);
+
+	atomic_add(num_wqebbs, &wq->delta);
+}
+
+/**
+ * hinic_read_wqe - read wqe ptr in the current ci
+ * @wq: wq to get read from
+ * @wqe_size: wqe size
+ * @cons_idx: returned ci
+ *
+ * Return wqe pointer
+ **/
+struct hinic_hw_wqe *hinic_read_wqe(struct hinic_wq *wq, unsigned int wqe_size,
+				    u16 *cons_idx)
+{
+	int num_wqebbs = ALIGN(wqe_size, wq->wqebb_size) / wq->wqebb_size;
+	u16 curr_cons_idx, end_cons_idx;
+	int curr_pg, end_pg;
+
+	if ((atomic_read(&wq->delta) + num_wqebbs) > wq->q_depth)
+		return ERR_PTR(-EBUSY);
+
+	curr_cons_idx = atomic_read(&wq->cons_idx);
+
+	curr_cons_idx = MASKED_WQE_IDX(wq, curr_cons_idx);
+	end_cons_idx = MASKED_WQE_IDX(wq, curr_cons_idx + num_wqebbs - 1);
+
+	curr_pg = WQE_PAGE_NUM(wq, curr_cons_idx);
+	end_pg = WQE_PAGE_NUM(wq, end_cons_idx);
+
+	*cons_idx = curr_cons_idx;
+
+	if (curr_pg != end_pg) {
+		void *shadow_addr = &wq->shadow_wqe[curr_pg * wq->max_wqe_size];
+
+		copy_wqe_to_shadow(wq, shadow_addr, num_wqebbs, *cons_idx);
+		return shadow_addr;
+	}
+
+	return WQ_PAGE_ADDR(wq, *cons_idx) + WQE_PAGE_OFF(wq, *cons_idx);
+}
+
+/**
+ * wqe_shadow - check if a wqe is shadow
+ * @wq: wq of the wqe
+ * @wqe: the wqe for shadow checking
+ *
+ * Return true - shadow, false - Not shadow
+ **/
+static inline bool wqe_shadow(struct hinic_wq *wq, struct hinic_hw_wqe *wqe)
+{
+	size_t wqe_shadow_size = wq->num_q_pages * wq->max_wqe_size;
+
+	return WQE_IN_RANGE(wqe, wq->shadow_wqe,
+			    &wq->shadow_wqe[wqe_shadow_size]);
+}
+
+/**
+ * hinic_write_wqe - write the wqe to the wq
+ * @wq: wq to write wqe to
+ * @wqe: wqe to write
+ * @wqe_size: wqe size
+ **/
+void hinic_write_wqe(struct hinic_wq *wq, struct hinic_hw_wqe *wqe,
+		     unsigned int wqe_size)
+{
+	int curr_pg, num_wqebbs;
+	void *shadow_addr;
+	u16 prod_idx;
+
+	if (wqe_shadow(wq, wqe)) {
+		curr_pg = WQE_SHADOW_PAGE(wq, wqe);
+
+		prod_idx = wq->shadow_idx[curr_pg];
+		num_wqebbs = ALIGN(wqe_size, wq->wqebb_size) / wq->wqebb_size;
+		shadow_addr = &wq->shadow_wqe[curr_pg * wq->max_wqe_size];
+
+		copy_wqe_from_shadow(wq, shadow_addr, num_wqebbs, prod_idx);
+	}
+}
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_wq.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_wq.h
index a3c4469..f01477a 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_wq.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_wq.h
@@ -21,6 +21,7 @@
 #include <linux/atomic.h>
 
 #include "hinic_hw_if.h"
+#include "hinic_hw_wqe.h"
 
 struct hinic_free_block {
 	int     page_idx;
@@ -100,4 +101,15 @@ int hinic_wq_allocate(struct hinic_wqs *wqs, struct hinic_wq *wq,
 
 void hinic_wq_free(struct hinic_wqs *wqs, struct hinic_wq *wq);
 
+struct hinic_hw_wqe *hinic_get_wqe(struct hinic_wq *wq, unsigned int wqe_size,
+				   u16 *prod_idx);
+
+void hinic_put_wqe(struct hinic_wq *wq, unsigned int wqe_size);
+
+struct hinic_hw_wqe *hinic_read_wqe(struct hinic_wq *wq, unsigned int wqe_size,
+				    u16 *cons_idx);
+
+void hinic_write_wqe(struct hinic_wq *wq, struct hinic_hw_wqe *wqe,
+		     unsigned int wqe_size);
+
 #endif
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_wqe.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_wqe.h
index d727c4d..bc73485 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_wqe.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_wqe.h
@@ -18,6 +18,50 @@
 
 #include "hinic_common.h"
 
+#define HINIC_CMDQ_CTRL_PI_SHIFT                        0
+#define HINIC_CMDQ_CTRL_CMD_SHIFT                       16
+#define HINIC_CMDQ_CTRL_MOD_SHIFT                       24
+#define HINIC_CMDQ_CTRL_ACK_TYPE_SHIFT                  29
+#define HINIC_CMDQ_CTRL_HW_BUSY_BIT_SHIFT               31
+
+#define HINIC_CMDQ_CTRL_PI_MASK                         0xFFFF
+#define HINIC_CMDQ_CTRL_CMD_MASK                        0xFF
+#define HINIC_CMDQ_CTRL_MOD_MASK                        0x1F
+#define HINIC_CMDQ_CTRL_ACK_TYPE_MASK                   0x3
+#define HINIC_CMDQ_CTRL_HW_BUSY_BIT_MASK                0x1
+
+#define HINIC_CMDQ_CTRL_SET(val, member)                        \
+			(((u32)(val) & HINIC_CMDQ_CTRL_##member##_MASK) \
+			 << HINIC_CMDQ_CTRL_##member##_SHIFT)
+
+#define HINIC_CMDQ_CTRL_GET(val, member)                        \
+			(((val) >> HINIC_CMDQ_CTRL_##member##_SHIFT) \
+			 & HINIC_CMDQ_CTRL_##member##_MASK)
+
+#define HINIC_CMDQ_WQE_HEADER_BUFDESC_LEN_SHIFT         0
+#define HINIC_CMDQ_WQE_HEADER_COMPLETE_FMT_SHIFT        15
+#define HINIC_CMDQ_WQE_HEADER_DATA_FMT_SHIFT            22
+#define HINIC_CMDQ_WQE_HEADER_COMPLETE_REQ_SHIFT        23
+#define HINIC_CMDQ_WQE_HEADER_COMPLETE_SECT_LEN_SHIFT   27
+#define HINIC_CMDQ_WQE_HEADER_CTRL_LEN_SHIFT            29
+#define HINIC_CMDQ_WQE_HEADER_TOGGLED_WRAPPED_SHIFT     31
+
+#define HINIC_CMDQ_WQE_HEADER_BUFDESC_LEN_MASK          0xFF
+#define HINIC_CMDQ_WQE_HEADER_COMPLETE_FMT_MASK         0x1
+#define HINIC_CMDQ_WQE_HEADER_DATA_FMT_MASK             0x1
+#define HINIC_CMDQ_WQE_HEADER_COMPLETE_REQ_MASK         0x1
+#define HINIC_CMDQ_WQE_HEADER_COMPLETE_SECT_LEN_MASK    0x3
+#define HINIC_CMDQ_WQE_HEADER_CTRL_LEN_MASK             0x3
+#define HINIC_CMDQ_WQE_HEADER_TOGGLED_WRAPPED_MASK      0x1
+
+#define HINIC_CMDQ_WQE_HEADER_SET(val, member)                  \
+			(((u32)(val) & HINIC_CMDQ_WQE_HEADER_##member##_MASK) \
+			 << HINIC_CMDQ_WQE_HEADER_##member##_SHIFT)
+
+#define HINIC_CMDQ_WQE_HEADER_GET(val, member)                  \
+			(((val) >> HINIC_CMDQ_WQE_HEADER_##member##_SHIFT) \
+			 & HINIC_CMDQ_WQE_HEADER_##member##_MASK)
+
 #define HINIC_SQ_CTRL_BUFDESC_SECT_LEN_SHIFT    0
 #define HINIC_SQ_CTRL_TASKSECT_LEN_SHIFT        16
 #define HINIC_SQ_CTRL_DATA_FORMAT_SHIFT         22
@@ -143,6 +187,8 @@
 		 sizeof(struct hinic_sq_task) + \
 		 (nr_sges) * sizeof(struct hinic_sq_bufdesc))
 
+#define HINIC_SCMD_DATA_LEN             16
+
 #define HINIC_MAX_SQ_BUFDESCS           17
 
 #define HINIC_SQ_WQE_MAX_SIZE           320
@@ -184,6 +230,74 @@ enum hinc_tunnel_l4type {
 	HINIC_TUNNEL_L4TYPE_UNKNOWN = 0,
 };
 
+struct hinic_cmdq_header {
+	u32     header_info;
+	u32     saved_data;
+};
+
+struct hinic_status {
+	u32 status_info;
+};
+
+struct hinic_ctrl {
+	u32 ctrl_info;
+};
+
+struct hinic_sge_resp {
+	struct hinic_sge        sge;
+	u32                     rsvd;
+};
+
+struct hinic_cmdq_completion {
+	/* HW Format */
+	union {
+		struct hinic_sge_resp   sge_resp;
+		u64                     direct_resp;
+	};
+};
+
+struct hinic_scmd_bufdesc {
+	u32     buf_len;
+	u32     rsvd;
+	u8      data[HINIC_SCMD_DATA_LEN];
+};
+
+struct hinic_lcmd_bufdesc {
+	struct hinic_sge        sge;
+	u32                     rsvd1;
+	u64                     rsvd2;
+	u64                     rsvd3;
+};
+
+struct hinic_cmdq_wqe_scmd {
+	struct hinic_cmdq_header        header;
+	u64                             rsvd;
+	struct hinic_status             status;
+	struct hinic_ctrl               ctrl;
+	struct hinic_cmdq_completion    completion;
+	struct hinic_scmd_bufdesc       buf_desc;
+};
+
+struct hinic_cmdq_wqe_lcmd {
+	struct hinic_cmdq_header        header;
+	struct hinic_status             status;
+	struct hinic_ctrl               ctrl;
+	struct hinic_cmdq_completion    completion;
+	struct hinic_lcmd_bufdesc       buf_desc;
+};
+
+struct hinic_cmdq_direct_wqe {
+	struct hinic_cmdq_wqe_scmd      wqe_scmd;
+};
+
+struct hinic_cmdq_wqe {
+	/* HW Format */
+	union {
+		struct hinic_cmdq_direct_wqe    direct_wqe;
+		struct hinic_cmdq_wqe_lcmd      wqe_lcmd;
+	};
+};
+
 struct hinic_sq_ctrl {
 	u32     ctrl_info;
 	u32     queue_info;
@@ -245,6 +359,7 @@ struct hinic_rq_wqe {
 struct hinic_hw_wqe {
 	/* HW Format */
 	union {
+		struct hinic_cmdq_wqe   cmdq_wqe;
 		struct hinic_sq_wqe     sq_wqe;
 		struct hinic_rq_wqe     rq_wqe;
 	};
-- 
1.9.1
