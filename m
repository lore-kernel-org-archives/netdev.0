From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Subject: [PATCH V6 17/21] net-next/hinic: Add cmdq completion handler
Date: Thu, 17 Aug 2017 20:25:25 +0800
Message-ID: <4d806afa897c4c1346049b8585c85c0ebc7835ba.1502972068.git.aviad.krawczyk@huawei.com>
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

Add cmdq completion handler for getting a notification about the
completion of cmdq commands.

Signed-off-by: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Signed-off-by: Zhao Chen <zhaochen6@huawei.com>
---
 drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.c | 297 +++++++++++++++++++++-
 drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.h |  12 +
 2 files changed, 308 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.c
index d8c0807..8d72762 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.c
@@ -40,12 +40,31 @@
 #include "hinic_hw_io.h"
 #include "hinic_hw_dev.h"
 
+#define CMDQ_CEQE_TYPE_SHIFT                    0
+
+#define CMDQ_CEQE_TYPE_MASK                     0x7
+
+#define CMDQ_CEQE_GET(val, member)              \
+			(((val) >> CMDQ_CEQE_##member##_SHIFT) \
+			 & CMDQ_CEQE_##member##_MASK)
+
+#define CMDQ_WQE_ERRCODE_VAL_SHIFT              20
+
+#define CMDQ_WQE_ERRCODE_VAL_MASK               0xF
+
+#define CMDQ_WQE_ERRCODE_GET(val, member)       \
+			(((val) >> CMDQ_WQE_ERRCODE_##member##_SHIFT) \
+			 & CMDQ_WQE_ERRCODE_##member##_MASK)
+
 #define CMDQ_DB_PI_OFF(pi)              (((u16)LOWER_8_BITS(pi)) << 3)
 
 #define CMDQ_DB_ADDR(db_base, pi)       ((db_base) + CMDQ_DB_PI_OFF(pi))
 
 #define CMDQ_WQE_HEADER(wqe)            ((struct hinic_cmdq_header *)(wqe))
 
+#define CMDQ_WQE_COMPLETED(ctrl_info)   \
+			HINIC_CMDQ_CTRL_GET(ctrl_info, HW_BUSY_BIT)
+
 #define FIRST_DATA_TO_WRITE_LAST        sizeof(u64)
 
 #define CMDQ_DB_OFF                     SZ_2K
@@ -145,6 +164,22 @@ void hinic_free_cmdq_buf(struct hinic_cmdqs *cmdqs,
 	pci_pool_free(cmdqs->cmdq_buf_pool, cmdq_buf->buf, cmdq_buf->dma_addr);
 }
 
+static unsigned int cmdq_wqe_size_from_bdlen(enum bufdesc_len len)
+{
+	unsigned int wqe_size = 0;
+
+	switch (len) {
+	case BUFDESC_LCMD_LEN:
+		wqe_size = WQE_LCMD_SIZE;
+		break;
+	case BUFDESC_SCMD_LEN:
+		wqe_size = WQE_SCMD_SIZE;
+		break;
+	}
+
+	return wqe_size;
+}
+
 static void cmdq_set_sge_completion(struct hinic_cmdq_completion *completion,
 				    struct hinic_cmdq_buf *buf_out)
 {
@@ -211,6 +246,15 @@ static void cmdq_set_lcmd_bufdesc(struct hinic_cmdq_wqe_lcmd *wqe_lcmd,
 	hinic_set_sge(&wqe_lcmd->buf_desc.sge, buf_in->dma_addr, buf_in->size);
 }
 
+static void cmdq_set_direct_wqe_data(struct hinic_cmdq_direct_wqe *wqe,
+				     void *buf_in, u32 in_size)
+{
+	struct hinic_cmdq_wqe_scmd *wqe_scmd = &wqe->wqe_scmd;
+
+	wqe_scmd->buf_desc.buf_len = in_size;
+	memcpy(wqe_scmd->buf_desc.data, buf_in, in_size);
+}
+
 static void cmdq_set_lcmd_wqe(struct hinic_cmdq_wqe *wqe,
 			      enum cmdq_cmd_type cmd_type,
 			      struct hinic_cmdq_buf *buf_in,
@@ -239,6 +283,36 @@ static void cmdq_set_lcmd_wqe(struct hinic_cmdq_wqe *wqe,
 	cmdq_set_lcmd_bufdesc(wqe_lcmd, buf_in);
 }
 
+static void cmdq_set_direct_wqe(struct hinic_cmdq_wqe *wqe,
+				enum cmdq_cmd_type cmd_type,
+				void *buf_in, u16 in_size,
+				struct hinic_cmdq_buf *buf_out, int wrapped,
+				enum hinic_cmd_ack_type ack_type,
+				enum hinic_mod_type mod, u8 cmd, u16 prod_idx)
+{
+	struct hinic_cmdq_direct_wqe *direct_wqe = &wqe->direct_wqe;
+	enum completion_format complete_format;
+	struct hinic_cmdq_wqe_scmd *wqe_scmd;
+
+	wqe_scmd = &direct_wqe->wqe_scmd;
+
+	switch (cmd_type) {
+	case CMDQ_CMD_SYNC_SGE_RESP:
+		complete_format = COMPLETE_SGE;
+		cmdq_set_sge_completion(&wqe_scmd->completion, buf_out);
+		break;
+	case CMDQ_CMD_SYNC_DIRECT_RESP:
+		complete_format = COMPLETE_DIRECT;
+		wqe_scmd->completion.direct_resp = 0;
+		break;
+	}
+
+	cmdq_prepare_wqe_ctrl(wqe, wrapped, ack_type, mod, cmd, prod_idx,
+			      complete_format, DATA_DIRECT, BUFDESC_SCMD_LEN);
+
+	cmdq_set_direct_wqe_data(direct_wqe, buf_in, in_size);
+}
+
 static void cmdq_wqe_fill(void *dst, void *src)
 {
 	memcpy(dst + FIRST_DATA_TO_WRITE_LAST, src + FIRST_DATA_TO_WRITE_LAST,
@@ -352,6 +426,52 @@ static int cmdq_sync_cmd_direct_resp(struct hinic_cmdq *cmdq,
 	return 0;
 }
 
+static int cmdq_set_arm_bit(struct hinic_cmdq *cmdq, void *buf_in,
+			    u16 in_size)
+{
+	struct hinic_cmdq_wqe *curr_cmdq_wqe, cmdq_wqe;
+	u16 curr_prod_idx, next_prod_idx;
+	struct hinic_wq *wq = cmdq->wq;
+	struct hinic_hw_wqe *hw_wqe;
+	int wrapped, num_wqebbs;
+
+	/* Keep doorbell index correct */
+	spin_lock(&cmdq->cmdq_lock);
+
+	/* WQE_SIZE = WQEBB_SIZE, we will get the wq element and not shadow*/
+	hw_wqe = hinic_get_wqe(wq, WQE_SCMD_SIZE, &curr_prod_idx);
+	if (IS_ERR(hw_wqe)) {
+		spin_unlock(&cmdq->cmdq_lock);
+		return -EBUSY;
+	}
+
+	curr_cmdq_wqe = &hw_wqe->cmdq_wqe;
+
+	wrapped = cmdq->wrapped;
+
+	num_wqebbs = ALIGN(WQE_SCMD_SIZE, wq->wqebb_size) / wq->wqebb_size;
+	next_prod_idx = curr_prod_idx + num_wqebbs;
+	if (next_prod_idx >= wq->q_depth) {
+		cmdq->wrapped = !cmdq->wrapped;
+		next_prod_idx -= wq->q_depth;
+	}
+
+	cmdq_set_direct_wqe(&cmdq_wqe, CMDQ_CMD_SYNC_DIRECT_RESP, buf_in,
+			    in_size, NULL, wrapped, HINIC_CMD_ACK_TYPE_CMDQ,
+			    HINIC_MOD_COMM, CMDQ_SET_ARM_CMD, curr_prod_idx);
+
+	/* The data that is written to HW should be in Big Endian Format */
+	hinic_cpu_to_be32(&cmdq_wqe, WQE_SCMD_SIZE);
+
+	/* cmdq wqe is not shadow, therefore wqe will be written to wq */
+	cmdq_wqe_fill(curr_cmdq_wqe, &cmdq_wqe);
+
+	cmdq_set_db(cmdq, HINIC_CMDQ_SYNC, next_prod_idx);
+
+	spin_unlock(&cmdq->cmdq_lock);
+	return 0;
+}
+
 static int cmdq_params_valid(struct hinic_cmdq_buf *buf_in)
 {
 	if (buf_in->size > HINIC_CMDQ_MAX_DATA_SIZE)
@@ -389,13 +509,188 @@ int hinic_cmdq_direct_resp(struct hinic_cmdqs *cmdqs,
 }
 
 /**
+ * hinic_set_arm_bit - set arm bit for enable interrupt again
+ * @cmdqs: the cmdqs
+ * @q_type: type of queue to set the arm bit for
+ * @q_id: the queue number
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+int hinic_set_arm_bit(struct hinic_cmdqs *cmdqs,
+		      enum hinic_set_arm_qtype q_type, u32 q_id)
+{
+	struct hinic_cmdq *cmdq = &cmdqs->cmdq[HINIC_CMDQ_SYNC];
+	struct hinic_hwif *hwif = cmdqs->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	struct hinic_cmdq_arm_bit arm_bit;
+	int err;
+
+	arm_bit.q_type = q_type;
+	arm_bit.q_id   = q_id;
+
+	err = cmdq_set_arm_bit(cmdq, &arm_bit, sizeof(arm_bit));
+	if (err) {
+		dev_err(&pdev->dev, "Failed to set arm for qid %d\n", q_id);
+		return err;
+	}
+
+	return 0;
+}
+
+static void clear_wqe_complete_bit(struct hinic_cmdq *cmdq,
+				   struct hinic_cmdq_wqe *wqe)
+{
+	u32 header_info = be32_to_cpu(CMDQ_WQE_HEADER(wqe)->header_info);
+	unsigned int bufdesc_len, wqe_size;
+	struct hinic_ctrl *ctrl;
+
+	bufdesc_len = HINIC_CMDQ_WQE_HEADER_GET(header_info, BUFDESC_LEN);
+	wqe_size = cmdq_wqe_size_from_bdlen(bufdesc_len);
+	if (wqe_size == WQE_LCMD_SIZE) {
+		struct hinic_cmdq_wqe_lcmd *wqe_lcmd = &wqe->wqe_lcmd;
+
+		ctrl = &wqe_lcmd->ctrl;
+	} else {
+		struct hinic_cmdq_direct_wqe *direct_wqe = &wqe->direct_wqe;
+		struct hinic_cmdq_wqe_scmd *wqe_scmd;
+
+		wqe_scmd = &direct_wqe->wqe_scmd;
+		ctrl = &wqe_scmd->ctrl;
+	}
+
+	/* clear HW busy bit */
+	ctrl->ctrl_info = 0;
+
+	wmb();  /* verify wqe is clear */
+}
+
+/**
+ * cmdq_arm_ceq_handler - cmdq completion event handler for arm command
+ * @cmdq: the cmdq of the arm command
+ * @wqe: the wqe of the arm command
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+static int cmdq_arm_ceq_handler(struct hinic_cmdq *cmdq,
+				struct hinic_cmdq_wqe *wqe)
+{
+	struct hinic_cmdq_direct_wqe *direct_wqe = &wqe->direct_wqe;
+	struct hinic_cmdq_wqe_scmd *wqe_scmd;
+	struct hinic_ctrl *ctrl;
+	u32 ctrl_info;
+
+	wqe_scmd = &direct_wqe->wqe_scmd;
+	ctrl = &wqe_scmd->ctrl;
+	ctrl_info = be32_to_cpu(ctrl->ctrl_info);
+
+	/* HW should toggle the HW BUSY BIT */
+	if (!CMDQ_WQE_COMPLETED(ctrl_info))
+		return -EBUSY;
+
+	clear_wqe_complete_bit(cmdq, wqe);
+
+	hinic_put_wqe(cmdq->wq, WQE_SCMD_SIZE);
+	return 0;
+}
+
+static void cmdq_update_errcode(struct hinic_cmdq *cmdq, u16 prod_idx,
+				int errcode)
+{
+	if (cmdq->errcode[prod_idx])
+		*cmdq->errcode[prod_idx] = errcode;
+}
+
+/**
+ * cmdq_arm_ceq_handler - cmdq completion event handler for sync command
+ * @cmdq: the cmdq of the command
+ * @cons_idx: the consumer index to update the error code for
+ * @errcode: the error code
+ **/
+static void cmdq_sync_cmd_handler(struct hinic_cmdq *cmdq, u16 cons_idx,
+				  int errcode)
+{
+	u16 prod_idx = cons_idx;
+
+	spin_lock(&cmdq->cmdq_lock);
+	cmdq_update_errcode(cmdq, prod_idx, errcode);
+
+	wmb();  /* write all before update for the command request */
+
+	if (cmdq->done[prod_idx])
+		complete(cmdq->done[prod_idx]);
+	spin_unlock(&cmdq->cmdq_lock);
+}
+
+static int cmdq_cmd_ceq_handler(struct hinic_cmdq *cmdq, u16 ci,
+				struct hinic_cmdq_wqe *cmdq_wqe)
+{
+	struct hinic_cmdq_wqe_lcmd *wqe_lcmd = &cmdq_wqe->wqe_lcmd;
+	struct hinic_status *status = &wqe_lcmd->status;
+	struct hinic_ctrl *ctrl = &wqe_lcmd->ctrl;
+	int errcode;
+
+	if (!CMDQ_WQE_COMPLETED(be32_to_cpu(ctrl->ctrl_info)))
+		return -EBUSY;
+
+	errcode = CMDQ_WQE_ERRCODE_GET(be32_to_cpu(status->status_info), VAL);
+
+	cmdq_sync_cmd_handler(cmdq, ci, errcode);
+
+	clear_wqe_complete_bit(cmdq, cmdq_wqe);
+	hinic_put_wqe(cmdq->wq, WQE_LCMD_SIZE);
+	return 0;
+}
+
+/**
  * cmdq_ceq_handler - cmdq completion event handler
  * @handle: private data for the handler(cmdqs)
  * @ceqe_data: ceq element data
  **/
 static void cmdq_ceq_handler(void *handle, u32 ceqe_data)
 {
-	/* should be implemented */
+	enum hinic_cmdq_type cmdq_type = CMDQ_CEQE_GET(ceqe_data, TYPE);
+	struct hinic_cmdqs *cmdqs = (struct hinic_cmdqs *)handle;
+	struct hinic_cmdq *cmdq = &cmdqs->cmdq[cmdq_type];
+	struct hinic_cmdq_header *header;
+	struct hinic_hw_wqe *hw_wqe;
+	int err, set_arm = 0;
+	u32 saved_data;
+	u16 ci;
+
+	/* Read the smallest wqe size for getting wqe size */
+	while ((hw_wqe = hinic_read_wqe(cmdq->wq, WQE_SCMD_SIZE, &ci))) {
+		if (IS_ERR(hw_wqe))
+			break;
+
+		header = CMDQ_WQE_HEADER(&hw_wqe->cmdq_wqe);
+		saved_data = be32_to_cpu(header->saved_data);
+
+		if (HINIC_SAVED_DATA_GET(saved_data, ARM)) {
+			/* arm_bit was set until here */
+			set_arm = 0;
+
+			if (cmdq_arm_ceq_handler(cmdq, &hw_wqe->cmdq_wqe))
+				break;
+		} else {
+			set_arm = 1;
+
+			hw_wqe = hinic_read_wqe(cmdq->wq, WQE_LCMD_SIZE, &ci);
+			if (IS_ERR(hw_wqe))
+				break;
+
+			if (cmdq_cmd_ceq_handler(cmdq, ci, &hw_wqe->cmdq_wqe))
+				break;
+		}
+	}
+
+	if (set_arm) {
+		struct hinic_hwif *hwif = cmdqs->hwif;
+		struct pci_dev *pdev = hwif->pdev;
+
+		err = hinic_set_arm_bit(cmdqs, HINIC_SET_ARM_CMDQ, cmdq_type);
+		if (err)
+			dev_err(&pdev->dev, "Failed to set arm for CMDQ\n");
+	}
 }
 
 /**
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.h
index e11a4f0..b355834 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.h
@@ -100,6 +100,10 @@ enum hinic_cmdq_type {
 	HINIC_MAX_CMDQ_TYPES,
 };
 
+enum hinic_set_arm_qtype {
+	HINIC_SET_ARM_CMDQ,
+};
+
 enum hinic_cmd_ack_type {
 	HINIC_CMD_ACK_TYPE_CMDQ,
 };
@@ -110,6 +114,11 @@ struct hinic_cmdq_buf {
 	size_t          size;
 };
 
+struct hinic_cmdq_arm_bit {
+	u32     q_type;
+	u32     q_id;
+};
+
 struct hinic_cmdq_ctxt_info {
 	u64     curr_wqe_page_pfn;
 	u64     wq_block_pfn;
@@ -167,6 +176,9 @@ int hinic_cmdq_direct_resp(struct hinic_cmdqs *cmdqs,
 			   enum hinic_mod_type mod, u8 cmd,
 			   struct hinic_cmdq_buf *buf_in, u64 *out_param);
 
+int hinic_set_arm_bit(struct hinic_cmdqs *cmdqs,
+		      enum hinic_set_arm_qtype q_type, u32 q_id);
+
 int hinic_init_cmdqs(struct hinic_cmdqs *cmdqs, struct hinic_hwif *hwif,
 		     void __iomem **db_area);
 
-- 
1.9.1
