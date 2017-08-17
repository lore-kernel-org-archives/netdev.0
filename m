From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Subject: [PATCH V6 06/21] net-next/hinic: Add api cmd commands
Date: Thu, 17 Aug 2017 20:25:14 +0800
Message-ID: <0dabd48996d4fc8a71107fcb460fdaf26c2233b7.1502972068.git.aviad.krawczyk@huawei.com>
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

Add the api cmd commands for sending management messages to the nic.

Signed-off-by: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Signed-off-by: Zhao Chen <zhaochen6@huawei.com>
---
 .../net/ethernet/huawei/hinic/hinic_hw_api_cmd.c   | 329 ++++++++++++++++++++-
 .../net/ethernet/huawei/hinic/hinic_hw_api_cmd.h   |  65 ++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_csr.h   |   6 +
 3 files changed, 398 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_api_cmd.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_api_cmd.c
index b44ddf2..d0145c6 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_api_cmd.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_api_cmd.c
@@ -25,7 +25,9 @@
 #include <linux/jiffies.h>
 #include <linux/delay.h>
 #include <linux/log2.h>
+#include <linux/semaphore.h>
 #include <asm/byteorder.h>
+#include <asm/barrier.h>
 
 #include "hinic_hw_csr.h"
 #include "hinic_hw_if.h"
@@ -45,14 +47,313 @@
 
 #define API_CMD_BUF_SIZE                        2048
 
+/* Sizes of the members in hinic_api_cmd_cell */
+#define API_CMD_CELL_DESC_SIZE          8
+#define API_CMD_CELL_DATA_ADDR_SIZE     8
+
+#define API_CMD_CELL_ALIGNMENT          8
+
 #define API_CMD_TIMEOUT                 1000
 
+#define MASKED_IDX(chain, idx)          ((idx) & ((chain)->num_cells - 1))
+
+#define SIZE_8BYTES(size)               (ALIGN((size), 8) >> 3)
+#define SIZE_4BYTES(size)               (ALIGN((size), 4) >> 2)
+
+#define RD_DMA_ATTR_DEFAULT             0
+#define WR_DMA_ATTR_DEFAULT             0
+
+enum api_cmd_data_format {
+	SGE_DATA = 1,           /* cell data is passed by hw address */
+};
+
+enum api_cmd_type {
+	API_CMD_WRITE = 0,
+};
+
+enum api_cmd_bypass {
+	NO_BYPASS       = 0,
+	BYPASS          = 1,
+};
+
 enum api_cmd_xor_chk_level {
 	XOR_CHK_DIS = 0,
 
 	XOR_CHK_ALL = 3,
 };
 
+static u8 xor_chksum_set(void *data)
+{
+	int idx;
+	u8 *val, checksum = 0;
+
+	val = data;
+
+	for (idx = 0; idx < 7; idx++)
+		checksum ^= val[idx];
+
+	return checksum;
+}
+
+static void set_prod_idx(struct hinic_api_cmd_chain *chain)
+{
+	enum hinic_api_cmd_chain_type chain_type = chain->chain_type;
+	struct hinic_hwif *hwif = chain->hwif;
+	u32 hw_prod_idx_addr, prod_idx;
+
+	hw_prod_idx_addr = HINIC_CSR_API_CMD_CHAIN_PI_ADDR(chain_type);
+	prod_idx = hinic_hwif_read_reg(hwif, hw_prod_idx_addr);
+
+	prod_idx = HINIC_API_CMD_PI_CLEAR(prod_idx, IDX);
+
+	prod_idx |= HINIC_API_CMD_PI_SET(chain->prod_idx, IDX);
+
+	hinic_hwif_write_reg(hwif, hw_prod_idx_addr, prod_idx);
+}
+
+static u32 get_hw_cons_idx(struct hinic_api_cmd_chain *chain)
+{
+	u32 addr, val;
+
+	addr = HINIC_CSR_API_CMD_STATUS_ADDR(chain->chain_type);
+	val  = hinic_hwif_read_reg(chain->hwif, addr);
+
+	return HINIC_API_CMD_STATUS_GET(val, CONS_IDX);
+}
+
+/**
+ * chain_busy - check if the chain is still processing last requests
+ * @chain: chain to check
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+static int chain_busy(struct hinic_api_cmd_chain *chain)
+{
+	struct hinic_hwif *hwif = chain->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	u32 prod_idx;
+
+	switch (chain->chain_type) {
+	case HINIC_API_CMD_WRITE_TO_MGMT_CPU:
+		chain->cons_idx = get_hw_cons_idx(chain);
+		prod_idx = chain->prod_idx;
+
+		/* check for a space for a new command */
+		if (chain->cons_idx == MASKED_IDX(chain, prod_idx + 1)) {
+			dev_err(&pdev->dev, "API CMD chain %d is busy\n",
+				chain->chain_type);
+			return -EBUSY;
+		}
+		break;
+
+	default:
+		dev_err(&pdev->dev, "Unknown API CMD Chain type\n");
+		break;
+	}
+
+	return 0;
+}
+
+/**
+ * get_cell_data_size - get the data size of a specific cell type
+ * @type: chain type
+ *
+ * Return the data(Desc + Address) size in the cell
+ **/
+static u8 get_cell_data_size(enum hinic_api_cmd_chain_type type)
+{
+	u8 cell_data_size = 0;
+
+	switch (type) {
+	case HINIC_API_CMD_WRITE_TO_MGMT_CPU:
+		cell_data_size = ALIGN(API_CMD_CELL_DESC_SIZE +
+				       API_CMD_CELL_DATA_ADDR_SIZE,
+				       API_CMD_CELL_ALIGNMENT);
+		break;
+	default:
+		break;
+	}
+
+	return cell_data_size;
+}
+
+/**
+ * prepare_cell_ctrl - prepare the ctrl of the cell for the command
+ * @cell_ctrl: the control of the cell to set the control value into it
+ * @data_size: the size of the data in the cell
+ **/
+static void prepare_cell_ctrl(u64 *cell_ctrl, u16 data_size)
+{
+	u8 chksum;
+	u64 ctrl;
+
+	ctrl =  HINIC_API_CMD_CELL_CTRL_SET(SIZE_8BYTES(data_size), DATA_SZ)  |
+		HINIC_API_CMD_CELL_CTRL_SET(RD_DMA_ATTR_DEFAULT, RD_DMA_ATTR) |
+		HINIC_API_CMD_CELL_CTRL_SET(WR_DMA_ATTR_DEFAULT, WR_DMA_ATTR);
+
+	chksum = xor_chksum_set(&ctrl);
+
+	ctrl |= HINIC_API_CMD_CELL_CTRL_SET(chksum, XOR_CHKSUM);
+
+	/* The data in the HW should be in Big Endian Format */
+	*cell_ctrl = cpu_to_be64(ctrl);
+}
+
+/**
+ * prepare_api_cmd - prepare API CMD command
+ * @chain: chain for the command
+ * @dest: destination node on the card that will receive the command
+ * @cmd: command data
+ * @cmd_size: the command size
+ **/
+static void prepare_api_cmd(struct hinic_api_cmd_chain *chain,
+			    enum hinic_node_id dest,
+			    void *cmd, u16 cmd_size)
+{
+	struct hinic_api_cmd_cell *cell = chain->curr_node;
+	struct hinic_api_cmd_cell_ctxt *cell_ctxt;
+	struct hinic_hwif *hwif = chain->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+
+	cell_ctxt = &chain->cell_ctxt[chain->prod_idx];
+
+	switch (chain->chain_type) {
+	case HINIC_API_CMD_WRITE_TO_MGMT_CPU:
+		cell->desc = HINIC_API_CMD_DESC_SET(SGE_DATA, API_TYPE)   |
+			     HINIC_API_CMD_DESC_SET(API_CMD_WRITE, RD_WR) |
+			     HINIC_API_CMD_DESC_SET(NO_BYPASS, MGMT_BYPASS);
+		break;
+
+	default:
+		dev_err(&pdev->dev, "unknown Chain type\n");
+		return;
+	}
+
+	cell->desc |= HINIC_API_CMD_DESC_SET(dest, DEST)        |
+		      HINIC_API_CMD_DESC_SET(SIZE_4BYTES(cmd_size), SIZE);
+
+	cell->desc |= HINIC_API_CMD_DESC_SET(xor_chksum_set(&cell->desc),
+					     XOR_CHKSUM);
+
+	/* The data in the HW should be in Big Endian Format */
+	cell->desc = cpu_to_be64(cell->desc);
+
+	memcpy(cell_ctxt->api_cmd_vaddr, cmd, cmd_size);
+}
+
+/**
+ * prepare_cell - prepare cell ctrl and cmd in the current cell
+ * @chain: chain for the command
+ * @dest: destination node on the card that will receive the command
+ * @cmd: command data
+ * @cmd_size: the command size
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+static void prepare_cell(struct hinic_api_cmd_chain *chain,
+			 enum  hinic_node_id dest,
+			 void *cmd, u16 cmd_size)
+{
+	struct hinic_api_cmd_cell *curr_node = chain->curr_node;
+	u16 data_size = get_cell_data_size(chain->chain_type);
+
+	prepare_cell_ctrl(&curr_node->ctrl, data_size);
+	prepare_api_cmd(chain, dest, cmd, cmd_size);
+}
+
+static inline void cmd_chain_prod_idx_inc(struct hinic_api_cmd_chain *chain)
+{
+	chain->prod_idx = MASKED_IDX(chain, chain->prod_idx + 1);
+}
+
+/**
+ * api_cmd_status_update - update the status in the chain struct
+ * @chain: chain to update
+ **/
+static void api_cmd_status_update(struct hinic_api_cmd_chain *chain)
+{
+	enum hinic_api_cmd_chain_type chain_type;
+	struct hinic_api_cmd_status *wb_status;
+	struct hinic_hwif *hwif = chain->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	u64 status_header;
+	u32 status;
+
+	wb_status = chain->wb_status;
+	status_header = be64_to_cpu(wb_status->header);
+
+	status = be32_to_cpu(wb_status->status);
+	if (HINIC_API_CMD_STATUS_GET(status, CHKSUM_ERR)) {
+		dev_err(&pdev->dev, "API CMD status: Xor check error\n");
+		return;
+	}
+
+	chain_type = HINIC_API_CMD_STATUS_HEADER_GET(status_header, CHAIN_ID);
+	if (chain_type >= HINIC_API_CMD_MAX) {
+		dev_err(&pdev->dev, "unknown API CMD Chain %d\n", chain_type);
+		return;
+	}
+
+	chain->cons_idx = HINIC_API_CMD_STATUS_GET(status, CONS_IDX);
+}
+
+/**
+ * wait_for_status_poll - wait for write to api cmd command to complete
+ * @chain: the chain of the command
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+static int wait_for_status_poll(struct hinic_api_cmd_chain *chain)
+{
+	int err = -ETIMEDOUT;
+	unsigned long end;
+
+	end = jiffies + msecs_to_jiffies(API_CMD_TIMEOUT);
+	do {
+		api_cmd_status_update(chain);
+
+		/* wait for CI to be updated - sign for completion */
+		if (chain->cons_idx == chain->prod_idx) {
+			err = 0;
+			break;
+		}
+
+		msleep(20);
+	} while (time_before(jiffies, end));
+
+	return err;
+}
+
+/**
+ * wait_for_api_cmd_completion - wait for command to complete
+ * @chain: chain for the command
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+static int wait_for_api_cmd_completion(struct hinic_api_cmd_chain *chain)
+{
+	struct hinic_hwif *hwif = chain->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	int err;
+
+	switch (chain->chain_type) {
+	case HINIC_API_CMD_WRITE_TO_MGMT_CPU:
+		err = wait_for_status_poll(chain);
+		if (err) {
+			dev_err(&pdev->dev, "API CMD Poll status timeout\n");
+			break;
+		}
+		break;
+
+	default:
+		dev_err(&pdev->dev, "unknown API CMD Chain type\n");
+		err = -EINVAL;
+		break;
+	}
+
+	return err;
+}
+
 /**
  * api_cmd - API CMD command
  * @chain: chain for the command
@@ -65,8 +366,30 @@ enum api_cmd_xor_chk_level {
 static int api_cmd(struct hinic_api_cmd_chain *chain,
 		   enum hinic_node_id dest, u8 *cmd, u16 cmd_size)
 {
-	/* should be implemented */
-	return -EINVAL;
+	struct hinic_api_cmd_cell_ctxt *ctxt;
+	int err;
+
+	down(&chain->sem);
+	if (chain_busy(chain)) {
+		up(&chain->sem);
+		return -EBUSY;
+	}
+
+	prepare_cell(chain, dest, cmd, cmd_size);
+	cmd_chain_prod_idx_inc(chain);
+
+	wmb();  /* inc pi before issue the command */
+
+	set_prod_idx(chain);    /* issue the command */
+
+	ctxt = &chain->cell_ctxt[chain->prod_idx];
+
+	chain->curr_node = ctxt->cell_vaddr;
+
+	err = wait_for_api_cmd_completion(chain);
+
+	up(&chain->sem);
+	return err;
 }
 
 /**
@@ -491,6 +814,8 @@ static int api_chain_init(struct hinic_api_cmd_chain *chain,
 	chain->prod_idx  = 0;
 	chain->cons_idx  = 0;
 
+	sema_init(&chain->sem, 1);
+
 	cell_ctxt_size = chain->num_cells * sizeof(*chain->cell_ctxt);
 	chain->cell_ctxt = devm_kzalloc(&pdev->dev, cell_ctxt_size, GFP_KERNEL);
 	if (!chain->cell_ctxt)
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_api_cmd.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_api_cmd.h
index e8865d6..31b94d5 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_api_cmd.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_api_cmd.h
@@ -17,9 +17,22 @@
 #define HINIC_HW_API_CMD_H
 
 #include <linux/types.h>
+#include <linux/semaphore.h>
 
 #include "hinic_hw_if.h"
 
+#define HINIC_API_CMD_PI_IDX_SHIFT                              0
+
+#define HINIC_API_CMD_PI_IDX_MASK                               0xFFFFFF
+
+#define HINIC_API_CMD_PI_SET(val, member)                       \
+	(((u32)(val) & HINIC_API_CMD_PI_##member##_MASK) <<     \
+	 HINIC_API_CMD_PI_##member##_SHIFT)
+
+#define HINIC_API_CMD_PI_CLEAR(val, member)                     \
+	((val) & (~(HINIC_API_CMD_PI_##member##_MASK            \
+	 << HINIC_API_CMD_PI_##member##_SHIFT)))
+
 #define HINIC_API_CMD_CHAIN_REQ_RESTART_SHIFT                   1
 
 #define HINIC_API_CMD_CHAIN_REQ_RESTART_MASK                    0x1
@@ -58,6 +71,56 @@
 	((val) & (~(HINIC_API_CMD_CHAIN_CTRL_##member##_MASK    \
 	 << HINIC_API_CMD_CHAIN_CTRL_##member##_SHIFT)))
 
+#define HINIC_API_CMD_CELL_CTRL_DATA_SZ_SHIFT                   0
+#define HINIC_API_CMD_CELL_CTRL_RD_DMA_ATTR_SHIFT               16
+#define HINIC_API_CMD_CELL_CTRL_WR_DMA_ATTR_SHIFT               24
+#define HINIC_API_CMD_CELL_CTRL_XOR_CHKSUM_SHIFT                56
+
+#define HINIC_API_CMD_CELL_CTRL_DATA_SZ_MASK                    0x3F
+#define HINIC_API_CMD_CELL_CTRL_RD_DMA_ATTR_MASK                0x3F
+#define HINIC_API_CMD_CELL_CTRL_WR_DMA_ATTR_MASK                0x3F
+#define HINIC_API_CMD_CELL_CTRL_XOR_CHKSUM_MASK                 0xFF
+
+#define HINIC_API_CMD_CELL_CTRL_SET(val, member)                \
+	((((u64)val) & HINIC_API_CMD_CELL_CTRL_##member##_MASK) << \
+	 HINIC_API_CMD_CELL_CTRL_##member##_SHIFT)
+
+#define HINIC_API_CMD_DESC_API_TYPE_SHIFT                       0
+#define HINIC_API_CMD_DESC_RD_WR_SHIFT                          1
+#define HINIC_API_CMD_DESC_MGMT_BYPASS_SHIFT                    2
+#define HINIC_API_CMD_DESC_DEST_SHIFT                           32
+#define HINIC_API_CMD_DESC_SIZE_SHIFT                           40
+#define HINIC_API_CMD_DESC_XOR_CHKSUM_SHIFT                     56
+
+#define HINIC_API_CMD_DESC_API_TYPE_MASK                        0x1
+#define HINIC_API_CMD_DESC_RD_WR_MASK                           0x1
+#define HINIC_API_CMD_DESC_MGMT_BYPASS_MASK                     0x1
+#define HINIC_API_CMD_DESC_DEST_MASK                            0x1F
+#define HINIC_API_CMD_DESC_SIZE_MASK                            0x7FF
+#define HINIC_API_CMD_DESC_XOR_CHKSUM_MASK                      0xFF
+
+#define HINIC_API_CMD_DESC_SET(val, member)                     \
+	((((u64)val) & HINIC_API_CMD_DESC_##member##_MASK) <<   \
+	 HINIC_API_CMD_DESC_##member##_SHIFT)
+
+#define HINIC_API_CMD_STATUS_HEADER_CHAIN_ID_SHIFT              16
+
+#define HINIC_API_CMD_STATUS_HEADER_CHAIN_ID_MASK               0xFF
+
+#define HINIC_API_CMD_STATUS_HEADER_GET(val, member)            \
+	(((val) >> HINIC_API_CMD_STATUS_HEADER_##member##_SHIFT) & \
+	 HINIC_API_CMD_STATUS_HEADER_##member##_MASK)
+
+#define HINIC_API_CMD_STATUS_CONS_IDX_SHIFT                     0
+#define HINIC_API_CMD_STATUS_CHKSUM_ERR_SHIFT                   28
+
+#define HINIC_API_CMD_STATUS_CONS_IDX_MASK                      0xFFFFFF
+#define HINIC_API_CMD_STATUS_CHKSUM_ERR_MASK                    0x3
+
+#define HINIC_API_CMD_STATUS_GET(val, member)                   \
+	(((val) >> HINIC_API_CMD_STATUS_##member##_SHIFT) &     \
+	 HINIC_API_CMD_STATUS_##member##_MASK)
+
 enum hinic_api_cmd_chain_type {
 	HINIC_API_CMD_WRITE_TO_MGMT_CPU = 2,
 
@@ -122,6 +185,8 @@ struct hinic_api_cmd_chain {
 	u32                             prod_idx;
 	u32                             cons_idx;
 
+	struct semaphore                sem;
+
 	struct hinic_api_cmd_cell_ctxt  *cell_ctxt;
 
 	dma_addr_t                      wb_status_paddr;
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_csr.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_csr.h
index a9ece6d..ebbf054 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_csr.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_csr.h
@@ -56,7 +56,13 @@
 #define HINIC_CSR_API_CMD_CHAIN_CTRL_ADDR(idx)          \
 	(HINIC_CSR_API_CMD_BASE + 0x14 + (idx) * HINIC_CSR_API_CMD_STRIDE)
 
+#define HINIC_CSR_API_CMD_CHAIN_PI_ADDR(idx)            \
+	(HINIC_CSR_API_CMD_BASE + 0x1C + (idx) * HINIC_CSR_API_CMD_STRIDE)
+
 #define HINIC_CSR_API_CMD_CHAIN_REQ_ADDR(idx)           \
 	(HINIC_CSR_API_CMD_BASE + 0x20 + (idx) * HINIC_CSR_API_CMD_STRIDE)
 
+#define HINIC_CSR_API_CMD_STATUS_ADDR(idx)              \
+	(HINIC_CSR_API_CMD_BASE + 0x30 + (idx) * HINIC_CSR_API_CMD_STRIDE)
+
 #endif
-- 
1.9.1
