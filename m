From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Subject: [PATCH V3 net-next 04/21] net-next/hinic: Initialize api cmd hw
Date: Thu, 3 Aug 2017 17:54:10 +0800
Message-ID: <89bdad284ba0a07f9a99dd137e9920141e8620d9.1501752425.git.aviad.krawczyk@huawei.com>
References: <cover.1501752425.git.aviad.krawczyk@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <bc.y@huawei.com>, <victor.gissin@huawei.com>,
        <aviad.krawczyk@huawei.com>, <zhaochen6@huawei.com>,
        <tony.qu@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([45.249.212.189]:9905 "EHLO
        szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751900AbdHCJ5V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 05:57:21 -0400
In-Reply-To: <cover.1501752425.git.aviad.krawczyk@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update the hardware about api cmd resources and initialize it.

Signed-off-by: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Signed-off-by: Zhao Chen <zhaochen6@huawei.com>
---
 .../net/ethernet/huawei/hinic/hinic_hw_api_cmd.c   | 173 ++++++++++++++++++++-
 .../net/ethernet/huawei/hinic/hinic_hw_api_cmd.h   |  38 +++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_csr.h   |  25 +++
 3 files changed, 235 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_api_cmd.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_api_cmd.c
index b2f6bd8..874a262 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_api_cmd.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_api_cmd.c
@@ -13,6 +13,7 @@
  *
  */
 
+#include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/errno.h>
 #include <linux/pci.h>
@@ -21,8 +22,12 @@
 #include <linux/dma-mapping.h>
 #include <linux/bitops.h>
 #include <linux/err.h>
+#include <linux/jiffies.h>
+#include <linux/delay.h>
+#include <linux/log2.h>
 #include <asm/byteorder.h>
 
+#include "hinic_hw_csr.h"
 #include "hinic_hw_if.h"
 #include "hinic_hw_api_cmd.h"
 
@@ -35,8 +40,157 @@
 		(((cell_size) >= API_CMD_CELL_SIZE_MIN) ? \
 		 (1 << (fls(cell_size - 1))) : API_CMD_CELL_SIZE_MIN)
 
+#define API_CMD_CELL_SIZE_VAL(size)             \
+		ilog2((size) >> API_CMD_CELL_SIZE_SHIFT)
+
 #define API_CMD_BUF_SIZE                        2048
 
+#define API_CMD_TIMEOUT                 1000
+
+enum api_cmd_xor_chk_level {
+	XOR_CHK_DIS = 0,
+
+	XOR_CHK_ALL = 3,
+};
+
+/**
+ * api_cmd_hw_restart - restart the chain in the HW
+ * @chain: the API CMD specific chain to restart
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+static int api_cmd_hw_restart(struct hinic_api_cmd_chain *chain)
+{
+	struct hinic_hwif *hwif = chain->hwif;
+	unsigned long end;
+	u32 reg_addr, val;
+	int err = -ETIMEDOUT;
+
+	/* Read Modify Write */
+	reg_addr = HINIC_CSR_API_CMD_CHAIN_REQ_ADDR(chain->chain_type);
+	val = hinic_hwif_read_reg(hwif, reg_addr);
+
+	val = HINIC_API_CMD_CHAIN_REQ_CLEAR(val, RESTART);
+	val |= HINIC_API_CMD_CHAIN_REQ_SET(1, RESTART);
+
+	hinic_hwif_write_reg(hwif, reg_addr, val);
+
+	end = jiffies + msecs_to_jiffies(API_CMD_TIMEOUT);
+	do {
+		val = hinic_hwif_read_reg(hwif, reg_addr);
+
+		if (!HINIC_API_CMD_CHAIN_REQ_GET(val, RESTART)) {
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
+ * api_cmd_ctrl_init - set the control register of a chain
+ * @chain: the API CMD specific chain to set control register for
+ **/
+static void api_cmd_ctrl_init(struct hinic_api_cmd_chain *chain)
+{
+	struct hinic_hwif *hwif = chain->hwif;
+	u32 reg_addr, ctrl;
+	u16 cell_size;
+
+	/* Read Modify Write */
+	reg_addr = HINIC_CSR_API_CMD_CHAIN_CTRL_ADDR(chain->chain_type);
+
+	cell_size = API_CMD_CELL_SIZE_VAL(chain->cell_size);
+
+	ctrl = hinic_hwif_read_reg(hwif, reg_addr);
+
+	ctrl =  HINIC_API_CMD_CHAIN_CTRL_CLEAR(ctrl, RESTART_WB_STAT) &
+		HINIC_API_CMD_CHAIN_CTRL_CLEAR(ctrl, XOR_ERR)   &
+		HINIC_API_CMD_CHAIN_CTRL_CLEAR(ctrl, AEQE_EN)   &
+		HINIC_API_CMD_CHAIN_CTRL_CLEAR(ctrl, XOR_CHK_EN) &
+		HINIC_API_CMD_CHAIN_CTRL_CLEAR(ctrl, CELL_SIZE);
+
+	ctrl |= HINIC_API_CMD_CHAIN_CTRL_SET(1, XOR_ERR) |
+		HINIC_API_CMD_CHAIN_CTRL_SET(XOR_CHK_ALL, XOR_CHK_EN) |
+		HINIC_API_CMD_CHAIN_CTRL_SET(cell_size, CELL_SIZE);
+
+	hinic_hwif_write_reg(hwif, reg_addr, ctrl);
+}
+
+/**
+ * api_cmd_set_status_addr - set the status address of a chain in the HW
+ * @chain: the API CMD specific chain to set in HW status address for
+ **/
+static void api_cmd_set_status_addr(struct hinic_api_cmd_chain *chain)
+{
+	struct hinic_hwif *hwif = chain->hwif;
+	u32 addr, val;
+
+	addr = HINIC_CSR_API_CMD_STATUS_HI_ADDR(chain->chain_type);
+	val = upper_32_bits(chain->wb_status_paddr);
+	hinic_hwif_write_reg(hwif, addr, val);
+
+	addr = HINIC_CSR_API_CMD_STATUS_LO_ADDR(chain->chain_type);
+	val = lower_32_bits(chain->wb_status_paddr);
+	hinic_hwif_write_reg(hwif, addr, val);
+}
+
+/**
+ * api_cmd_set_num_cells - set the number cells of a chain in the HW
+ * @chain: the API CMD specific chain to set in HW the number of cells for
+ **/
+static void api_cmd_set_num_cells(struct hinic_api_cmd_chain *chain)
+{
+	struct hinic_hwif *hwif = chain->hwif;
+	u32 addr, val;
+
+	addr = HINIC_CSR_API_CMD_CHAIN_NUM_CELLS_ADDR(chain->chain_type);
+	val  = chain->num_cells;
+	hinic_hwif_write_reg(hwif, addr, val);
+}
+
+/**
+ * api_cmd_head_init - set the head of a chain in the HW
+ * @chain: the API CMD specific chain to set in HW the head for
+ **/
+static void api_cmd_head_init(struct hinic_api_cmd_chain *chain)
+{
+	struct hinic_hwif *hwif = chain->hwif;
+	u32 addr, val;
+
+	addr = HINIC_CSR_API_CMD_CHAIN_HEAD_HI_ADDR(chain->chain_type);
+	val = upper_32_bits(chain->head_cell_paddr);
+	hinic_hwif_write_reg(hwif, addr, val);
+
+	addr = HINIC_CSR_API_CMD_CHAIN_HEAD_LO_ADDR(chain->chain_type);
+	val = lower_32_bits(chain->head_cell_paddr);
+	hinic_hwif_write_reg(hwif, addr, val);
+}
+
+/**
+ * api_cmd_chain_hw_clean - clean the HW
+ * @chain: the API CMD specific chain
+ **/
+static void api_cmd_chain_hw_clean(struct hinic_api_cmd_chain *chain)
+{
+	struct hinic_hwif *hwif = chain->hwif;
+	u32 addr, ctrl;
+
+	addr = HINIC_CSR_API_CMD_CHAIN_CTRL_ADDR(chain->chain_type);
+
+	ctrl = hinic_hwif_read_reg(hwif, addr);
+	ctrl = HINIC_API_CMD_CHAIN_CTRL_CLEAR(ctrl, RESTART_WB_STAT) &
+		HINIC_API_CMD_CHAIN_CTRL_CLEAR(ctrl, XOR_ERR)   &
+		HINIC_API_CMD_CHAIN_CTRL_CLEAR(ctrl, AEQE_EN)   &
+		HINIC_API_CMD_CHAIN_CTRL_CLEAR(ctrl, XOR_CHK_EN) &
+		HINIC_API_CMD_CHAIN_CTRL_CLEAR(ctrl, CELL_SIZE);
+
+	hinic_hwif_write_reg(hwif, addr, ctrl);
+}
+
 /**
  * api_cmd_chain_hw_init - initialize the chain in the HW
  * @chain: the API CMD specific chain to initialize in HW
@@ -45,7 +199,23 @@
  **/
 static int api_cmd_chain_hw_init(struct hinic_api_cmd_chain *chain)
 {
-	/* should be implemented */
+	struct hinic_hwif *hwif = chain->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	int err;
+
+	api_cmd_chain_hw_clean(chain);
+
+	api_cmd_set_status_addr(chain);
+
+	err = api_cmd_hw_restart(chain);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to restart API CMD HW\n");
+		return err;
+	}
+
+	api_cmd_ctrl_init(chain);
+	api_cmd_set_num_cells(chain);
+	api_cmd_head_init(chain);
 	return 0;
 }
 
@@ -373,6 +543,7 @@ static void api_chain_free(struct hinic_api_cmd_chain *chain)
  **/
 static void api_cmd_destroy_chain(struct hinic_api_cmd_chain *chain)
 {
+	api_cmd_chain_hw_clean(chain);
 	api_cmd_destroy_cells(chain, chain->num_cells);
 	api_chain_free(chain);
 }
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_api_cmd.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_api_cmd.h
index 9c7d1e5..0c83b80 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_api_cmd.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_api_cmd.h
@@ -20,6 +20,44 @@
 
 #include "hinic_hw_if.h"
 
+#define HINIC_API_CMD_CHAIN_REQ_RESTART_SHIFT                   1
+
+#define HINIC_API_CMD_CHAIN_REQ_RESTART_MASK                    0x1
+
+#define HINIC_API_CMD_CHAIN_REQ_SET(val, member)                \
+	(((u32)(val) & HINIC_API_CMD_CHAIN_REQ_##member##_MASK) << \
+	 HINIC_API_CMD_CHAIN_REQ_##member##_SHIFT)
+
+#define HINIC_API_CMD_CHAIN_REQ_GET(val, member)                \
+	(((val) >> HINIC_API_CMD_CHAIN_REQ_##member##_SHIFT) &  \
+	 HINIC_API_CMD_CHAIN_REQ_##member##_MASK)
+
+#define HINIC_API_CMD_CHAIN_REQ_CLEAR(val, member)              \
+	((val) & (~(HINIC_API_CMD_CHAIN_REQ_##member##_MASK     \
+	 << HINIC_API_CMD_CHAIN_REQ_##member##_SHIFT)))
+
+#define HINIC_API_CMD_CHAIN_CTRL_RESTART_WB_STAT_SHIFT          1
+#define HINIC_API_CMD_CHAIN_CTRL_XOR_ERR_SHIFT                  2
+#define HINIC_API_CMD_CHAIN_CTRL_AEQE_EN_SHIFT                  4
+#define HINIC_API_CMD_CHAIN_CTRL_AEQ_ID_SHIFT                   8
+#define HINIC_API_CMD_CHAIN_CTRL_XOR_CHK_EN_SHIFT               28
+#define HINIC_API_CMD_CHAIN_CTRL_CELL_SIZE_SHIFT                30
+
+#define HINIC_API_CMD_CHAIN_CTRL_RESTART_WB_STAT_MASK           0x1
+#define HINIC_API_CMD_CHAIN_CTRL_XOR_ERR_MASK                   0x1
+#define HINIC_API_CMD_CHAIN_CTRL_AEQE_EN_MASK                   0x1
+#define HINIC_API_CMD_CHAIN_CTRL_AEQ_ID_MASK                    0x3
+#define HINIC_API_CMD_CHAIN_CTRL_XOR_CHK_EN_MASK                0x3
+#define HINIC_API_CMD_CHAIN_CTRL_CELL_SIZE_MASK                 0x3
+
+#define HINIC_API_CMD_CHAIN_CTRL_SET(val, member)               \
+	(((u32)(val) & HINIC_API_CMD_CHAIN_CTRL_##member##_MASK) << \
+	 HINIC_API_CMD_CHAIN_CTRL_##member##_SHIFT)
+
+#define HINIC_API_CMD_CHAIN_CTRL_CLEAR(val, member)             \
+	((val) & (~(HINIC_API_CMD_CHAIN_CTRL_##member##_MASK    \
+	 << HINIC_API_CMD_CHAIN_CTRL_##member##_SHIFT)))
+
 enum hinic_api_cmd_chain_type {
 	HINIC_API_CMD_WRITE_TO_MGMT_CPU = 2,
 
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_csr.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_csr.h
index c3440a9..0c100ee 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_csr.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_csr.h
@@ -33,4 +33,29 @@
 #define HINIC_CSR_PPF_ELECTION_ADDR(idx)                \
 	(HINIC_ELECTION_BASE +  (idx) * HINIC_PPF_ELECTION_STRIDE)
 
+/* API CMD registers */
+#define HINIC_CSR_API_CMD_BASE                          0xF000
+
+#define HINIC_CSR_API_CMD_STRIDE                        0x100
+
+#define HINIC_CSR_API_CMD_CHAIN_HEAD_HI_ADDR(idx)       \
+	(HINIC_CSR_API_CMD_BASE + 0x0 + (idx) * HINIC_CSR_API_CMD_STRIDE)
+
+#define HINIC_CSR_API_CMD_CHAIN_HEAD_LO_ADDR(idx)       \
+	(HINIC_CSR_API_CMD_BASE + 0x4 + (idx) * HINIC_CSR_API_CMD_STRIDE)
+
+#define HINIC_CSR_API_CMD_STATUS_HI_ADDR(idx)           \
+	(HINIC_CSR_API_CMD_BASE + 0x8 + (idx) * HINIC_CSR_API_CMD_STRIDE)
+
+#define HINIC_CSR_API_CMD_STATUS_LO_ADDR(idx)           \
+	(HINIC_CSR_API_CMD_BASE + 0xC + (idx) * HINIC_CSR_API_CMD_STRIDE)
+
+#define HINIC_CSR_API_CMD_CHAIN_NUM_CELLS_ADDR(idx)     \
+	(HINIC_CSR_API_CMD_BASE + 0x10 + (idx) * HINIC_CSR_API_CMD_STRIDE)
+
+#define HINIC_CSR_API_CMD_CHAIN_CTRL_ADDR(idx)          \
+	(HINIC_CSR_API_CMD_BASE + 0x14 + (idx) * HINIC_CSR_API_CMD_STRIDE)
+
+#define HINIC_CSR_API_CMD_CHAIN_REQ_ADDR(idx)           \
+	(HINIC_CSR_API_CMD_BASE + 0x20 + (idx) * HINIC_CSR_API_CMD_STRIDE)
 #endif
-- 
1.9.1
