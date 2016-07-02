From: Lijun Ou <oulijun@huawei.com>
Subject: [PATCH v11 08/22] IB/hns: Add hem support
Date: Sat, 2 Jul 2016 17:39:10 +0800
Message-ID: <1467452364-66522-9-git-send-email-oulijun@huawei.com>
References: <1467452364-66522-1-git-send-email-oulijun@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <gongyangming@huawei.com>,
	<xiaokun@huawei.com>, <tangchaofei@huawei.com>,
	<oulijun@huawei.com>, <haifeng.wei@huawei.com>,
	<yisen.zhuang@huawei.com>, <yankejian@huawei.com>,
	<charles.chenxin@huawei.com>, <linuxarm@huawei.com>
To: <dledford@redhat.com>, <sean.hefty@intel.com>,
	<hal.rosenstock@gmail.com>, <davem@davemloft.net>,
	<jeffrey.t.kirsher@intel.com>, <jiri@mellanox.com>,
	<ogerlitz@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467452364-66522-1-git-send-email-oulijun@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch mainly added hem(Hardware Entry Memory) support for RoCE.
It initializes icm which managers the relative memory blocks for
RoCE. The data structures of RoCE will be located in it.
For example, CQ table, QP table and MTPT table so on.

Signed-off-by: Wei Hu <xavier.huwei@huawei.com>
Signed-off-by: Nenglong Zhao <zhaonenglong@hisilicon.com>
Signed-off-by: Lijun Ou <oulijun@huawei.com>
---
PATCH v11:
This fixes the comments given by Leon Romanovsky over the PATCH v10:
  Link: https://lkml.org/lkml/2016/6/20/50

Remove the non-essential headers according to the Leon Romanovsky's
the same comments over the [PATCH v10 3/22]:
  Link: https://lkml.org/lkml/2016/6/24/276

PATCH v10/v9/v8/v7/v6:
- No change over the PATCH v5

PATCH v5:
- The initial patch which was redesigned based on the second patch
  in PATCH v4
---
---
 drivers/infiniband/hw/hns/hns_roce_common.h |  19 ++
 drivers/infiniband/hw/hns/hns_roce_device.h |  30 +++
 drivers/infiniband/hw/hns/hns_roce_hem.c    | 334 ++++++++++++++++++++++++++++
 drivers/infiniband/hw/hns/hns_roce_hem.h    | 114 ++++++++++
 drivers/infiniband/hw/hns/hns_roce_main.c   |  77 +++++++
 5 files changed, 574 insertions(+)
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_hem.c
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_hem.h

diff --git a/drivers/infiniband/hw/hns/hns_roce_common.h b/drivers/infiniband/hw/hns/hns_roce_common.h
index 4805852..f15bf1b 100644
--- a/drivers/infiniband/hw/hns/hns_roce_common.h
+++ b/drivers/infiniband/hw/hns/hns_roce_common.h
@@ -53,6 +53,22 @@
 #define roce_set_bit(origin, shift, val) \
 	roce_set_field((origin), (1ul << (shift)), (shift), (val))
 
+#define ROCEE_BT_CMD_H_ROCEE_BT_CMD_IN_MDF_S 0
+#define ROCEE_BT_CMD_H_ROCEE_BT_CMD_IN_MDF_M   \
+	(((1UL << 19) - 1) << ROCEE_BT_CMD_H_ROCEE_BT_CMD_IN_MDF_S)
+
+#define ROCEE_BT_CMD_H_ROCEE_BT_CMD_S 19
+
+#define ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_S 20
+#define ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_M   \
+	(((1UL << 2) - 1) << ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_S)
+
+#define ROCEE_BT_CMD_H_ROCEE_BT_CMD_BA_H_S 22
+#define ROCEE_BT_CMD_H_ROCEE_BT_CMD_BA_H_M   \
+	(((1UL << 5) - 1) << ROCEE_BT_CMD_H_ROCEE_BT_CMD_BA_H_S)
+
+#define ROCEE_BT_CMD_H_ROCEE_BT_CMD_HW_SYNS_S 31
+
 #define ROCEE_CAEP_AEQC_AEQE_SHIFT_CAEP_AEQC_STATE_S 0
 #define ROCEE_CAEP_AEQC_AEQE_SHIFT_CAEP_AEQC_STATE_M   \
 	(((1UL << 2) - 1) << ROCEE_CAEP_AEQC_AEQE_SHIFT_CAEP_AEQC_STATE_S)
@@ -93,6 +109,8 @@
 #define ROCEE_SYS_IMAGE_GUID_L_REG		0xC
 #define ROCEE_SYS_IMAGE_GUID_H_REG		0x10
 
+#define ROCEE_BT_CMD_H_REG			0x204
+
 #define ROCEE_CAEP_AEQE_CONS_IDX_REG		0x3AC
 #define ROCEE_CAEP_CEQC_CONS_IDX_0_REG		0x3BC
 
@@ -105,6 +123,7 @@
 
 #define ROCEE_CAEP_CE_INTERVAL_CFG_REG		0x190
 #define ROCEE_CAEP_CE_BURST_NUM_CFG_REG		0x194
+#define ROCEE_BT_CMD_L_REG			0x200
 
 #define ROCEE_MB1_REG				0x210
 
diff --git a/drivers/infiniband/hw/hns/hns_roce_device.h b/drivers/infiniband/hw/hns/hns_roce_device.h
index c101845..8ceff5d 100644
--- a/drivers/infiniband/hw/hns/hns_roce_device.h
+++ b/drivers/infiniband/hw/hns/hns_roce_device.h
@@ -103,6 +103,26 @@ enum {
 
 #define HNS_ROCE_CMD_SUCCESS			1
 
+/* For Hardware Entry Memory */
+struct hns_roce_hem_table {
+	/* HEM type: 0 = qpc, 1 = mtt, 2 = cqc, 3 = srq, 4 = other */
+	u32		type;
+	/* HEM array elment num */
+	unsigned long	num_hem;
+	/* HEM entry record obj total num */
+	unsigned long	num_obj;
+	/*Single obj size */
+	unsigned long	obj_size;
+	int		lowmem;
+	struct mutex	mutex;
+	struct hns_roce_hem **hem;
+};
+
+struct hns_roce_mr_table {
+	struct hns_roce_hem_table	mtt_table;
+	struct hns_roce_hem_table	mtpt_table;
+};
+
 struct hns_roce_buf_list {
 	void		*buf;
 	dma_addr_t	map;
@@ -118,11 +138,14 @@ struct hns_roce_cq {
 
 struct hns_roce_qp_table {
 	spinlock_t			lock;
+	struct hns_roce_hem_table	qp_table;
+	struct hns_roce_hem_table	irrl_table;
 };
 
 struct hns_roce_cq_table {
 	spinlock_t			lock;
 	struct radix_tree_root		tree;
+	struct hns_roce_hem_table	table;
 };
 
 struct hns_roce_cmd_context {
@@ -248,6 +271,7 @@ struct hns_roce_dev {
 	struct ib_device	ib_dev;
 	struct platform_device  *pdev;
 	const char		*irq_names;
+	spinlock_t		bt_cmd_lock;
 	struct hns_roce_ib_iboe iboe;
 
 	int			irq[HNS_ROCE_MAX_IRQ_NUM];
@@ -261,6 +285,7 @@ struct hns_roce_dev {
 	u32                     hw_rev;
 
 	struct hns_roce_cmdq	cmd;
+	struct hns_roce_mr_table  mr_table;
 	struct hns_roce_cq_table  cq_table;
 	struct hns_roce_qp_table  qp_table;
 	struct hns_roce_eq_table  eq_table;
@@ -270,6 +295,11 @@ struct hns_roce_dev {
 	struct hns_roce_hw	*hw;
 };
 
+static inline void hns_roce_write64_k(__be32 val[2], void __iomem *dest)
+{
+	__raw_writeq(*(u64 *) val, dest);
+}
+
 static inline struct hns_roce_qp
 	*__hns_roce_qp_lookup(struct hns_roce_dev *hr_dev, u32 qpn)
 {
diff --git a/drivers/infiniband/hw/hns/hns_roce_hem.c b/drivers/infiniband/hw/hns/hns_roce_hem.c
new file mode 100644
index 0000000..e2e285d
--- /dev/null
+++ b/drivers/infiniband/hw/hns/hns_roce_hem.c
@@ -0,0 +1,334 @@
+/*
+ * Copyright (c) 2016 Hisilicon Limited.
+ * Copyright (c) 2007, 2008 Mellanox Technologies. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#include <linux/platform_device.h>
+#include "hns_roce_device.h"
+#include "hns_roce_hem.h"
+#include "hns_roce_common.h"
+
+#define HW_SYNC_TIMEOUT_MSECS		500
+#define HW_SYNC_SLEEP_TIME_INTERVAL	20
+
+#define HNS_ROCE_HEM_ALLOC_SIZE		(1 << 17)
+#define HNS_ROCE_TABLE_CHUNK_SIZE	(1 << 17)
+
+#define DMA_ADDR_T_SHIFT		12
+#define BT_CMD_SYNC_SHIFT		31
+#define BT_BA_SHIFT			32
+
+struct hns_roce_hem *hns_roce_alloc_hem(struct hns_roce_dev *hr_dev, int npages,
+					gfp_t gfp_mask)
+{
+	struct hns_roce_hem_chunk *chunk = NULL;
+	struct hns_roce_hem *hem;
+	struct scatterlist *mem;
+	int order;
+	void *buf;
+
+	WARN_ON(gfp_mask & __GFP_HIGHMEM);
+
+	hem = kmalloc(sizeof(*hem),
+		      gfp_mask & ~(__GFP_HIGHMEM | __GFP_NOWARN));
+	if (!hem)
+		return NULL;
+
+	hem->refcount = 0;
+	INIT_LIST_HEAD(&hem->chunk_list);
+
+	order = get_order(HNS_ROCE_HEM_ALLOC_SIZE);
+
+	while (npages > 0) {
+		if (!chunk) {
+			chunk = kmalloc(sizeof(*chunk),
+				gfp_mask & ~(__GFP_HIGHMEM | __GFP_NOWARN));
+			if (!chunk)
+				goto fail;
+
+			sg_init_table(chunk->mem, HNS_ROCE_HEM_CHUNK_LEN);
+			chunk->npages = 0;
+			chunk->nsg = 0;
+			list_add_tail(&chunk->list, &hem->chunk_list);
+		}
+
+		while (1 << order > npages)
+			--order;
+
+		/*
+		* Alloc memory one time. If failed, don't alloc small block
+		* memory, directly return fail.
+		*/
+		mem = &chunk->mem[chunk->npages];
+		buf = dma_alloc_coherent(&hr_dev->pdev->dev, PAGE_SIZE << order,
+				&sg_dma_address(mem), gfp_mask);
+		if (!buf)
+			goto fail;
+
+		sg_set_buf(mem, buf, PAGE_SIZE << order);
+		WARN_ON(mem->offset);
+		sg_dma_len(mem) = PAGE_SIZE << order;
+
+		++chunk->npages;
+		++chunk->nsg;
+		npages -= 1 << order;
+	}
+
+	return hem;
+
+fail:
+	hns_roce_free_hem(hr_dev, hem);
+	return NULL;
+}
+
+void hns_roce_free_hem(struct hns_roce_dev *hr_dev, struct hns_roce_hem *hem)
+{
+	struct hns_roce_hem_chunk *chunk, *tmp;
+	int i;
+
+	if (!hem)
+		return;
+
+	list_for_each_entry_safe(chunk, tmp, &hem->chunk_list, list) {
+		for (i = 0; i < chunk->npages; ++i)
+			dma_free_coherent(&hr_dev->pdev->dev,
+				   chunk->mem[i].length,
+				   lowmem_page_address(sg_page(&chunk->mem[i])),
+				   sg_dma_address(&chunk->mem[i]));
+		kfree(chunk);
+	}
+
+	kfree(hem);
+}
+
+static int hns_roce_set_hem(struct hns_roce_dev *hr_dev,
+			    struct hns_roce_hem_table *table, unsigned long obj)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	spinlock_t *lock = &hr_dev->bt_cmd_lock;
+	unsigned long end = 0;
+	unsigned long flags;
+	struct hns_roce_hem_iter iter;
+	void __iomem *bt_cmd;
+	u32 bt_cmd_h_val = 0;
+	u32 bt_cmd_val[2];
+	u32 bt_cmd_l = 0;
+	u64 bt_ba = 0;
+	int ret = 0;
+
+	/* Find the HEM(Hardware Entry Memory) entry */
+	unsigned long i = (obj & (table->num_obj - 1)) /
+			  (HNS_ROCE_TABLE_CHUNK_SIZE / table->obj_size);
+
+	switch (table->type) {
+	case HEM_TYPE_QPC:
+		roce_set_field(bt_cmd_h_val, ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_M,
+			       ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_S, HEM_TYPE_QPC);
+		break;
+	case HEM_TYPE_MTPT:
+		roce_set_field(bt_cmd_h_val, ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_M,
+			       ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_S,
+			       HEM_TYPE_MTPT);
+		break;
+	case HEM_TYPE_CQC:
+		roce_set_field(bt_cmd_h_val, ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_M,
+			       ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_S, HEM_TYPE_CQC);
+		break;
+	case HEM_TYPE_SRQC:
+		roce_set_field(bt_cmd_h_val, ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_M,
+			       ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_S,
+			       HEM_TYPE_SRQC);
+		break;
+	default:
+		return ret;
+	}
+	roce_set_field(bt_cmd_h_val, ROCEE_BT_CMD_H_ROCEE_BT_CMD_IN_MDF_M,
+		       ROCEE_BT_CMD_H_ROCEE_BT_CMD_IN_MDF_S, obj);
+	roce_set_bit(bt_cmd_h_val, ROCEE_BT_CMD_H_ROCEE_BT_CMD_S, 0);
+	roce_set_bit(bt_cmd_h_val, ROCEE_BT_CMD_H_ROCEE_BT_CMD_HW_SYNS_S, 1);
+
+	/* Currently iter only a chunk */
+	for (hns_roce_hem_first(table->hem[i], &iter);
+	     !hns_roce_hem_last(&iter); hns_roce_hem_next(&iter)) {
+		bt_ba = hns_roce_hem_addr(&iter) >> DMA_ADDR_T_SHIFT;
+
+		spin_lock_irqsave(lock, flags);
+
+		bt_cmd = hr_dev->reg_base + ROCEE_BT_CMD_H_REG;
+
+		end = msecs_to_jiffies(HW_SYNC_TIMEOUT_MSECS) + jiffies;
+		while (1) {
+			if (readl(bt_cmd) >> BT_CMD_SYNC_SHIFT) {
+				if (!(time_before(jiffies, end))) {
+					dev_err(dev, "Write bt_cmd err,hw_sync is not zero.\n");
+					spin_unlock_irqrestore(lock, flags);
+					return -EBUSY;
+				}
+			} else {
+				break;
+			}
+			msleep(HW_SYNC_SLEEP_TIME_INTERVAL);
+		}
+
+		bt_cmd_l = (u32)bt_ba;
+		roce_set_field(bt_cmd_h_val, ROCEE_BT_CMD_H_ROCEE_BT_CMD_BA_H_M,
+			       ROCEE_BT_CMD_H_ROCEE_BT_CMD_BA_H_S,
+			       bt_ba >> BT_BA_SHIFT);
+
+		bt_cmd_val[0] = bt_cmd_l;
+		bt_cmd_val[1] = bt_cmd_h_val;
+		hns_roce_write64_k(bt_cmd_val,
+				   hr_dev->reg_base + ROCEE_BT_CMD_L_REG);
+		spin_unlock_irqrestore(lock, flags);
+	}
+
+	return ret;
+}
+
+static int hns_roce_clear_hem(struct hns_roce_dev *hr_dev,
+			      struct hns_roce_hem_table *table,
+			      unsigned long obj)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	unsigned long end = 0;
+	unsigned long flags;
+	void __iomem *bt_cmd;
+	uint32_t bt_cmd_val[2];
+	u32 bt_cmd_h_val = 0;
+	int ret = 0;
+
+	switch (table->type) {
+	case HEM_TYPE_QPC:
+		roce_set_field(bt_cmd_h_val, ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_M,
+			       ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_S, HEM_TYPE_QPC);
+		break;
+	case HEM_TYPE_MTPT:
+		roce_set_field(bt_cmd_h_val, ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_M,
+			       ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_S,
+			       HEM_TYPE_MTPT);
+		break;
+	case HEM_TYPE_CQC:
+		roce_set_field(bt_cmd_h_val, ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_M,
+			       ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_S, HEM_TYPE_CQC);
+		break;
+	case HEM_TYPE_SRQC:
+		roce_set_field(bt_cmd_h_val, ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_M,
+			       ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_S,
+			       HEM_TYPE_SRQC);
+		break;
+	default:
+		return ret;
+	}
+	roce_set_field(bt_cmd_h_val, ROCEE_BT_CMD_H_ROCEE_BT_CMD_IN_MDF_M,
+		       ROCEE_BT_CMD_H_ROCEE_BT_CMD_IN_MDF_S, obj);
+	roce_set_bit(bt_cmd_h_val, ROCEE_BT_CMD_H_ROCEE_BT_CMD_S, 0);
+	roce_set_bit(bt_cmd_h_val, ROCEE_BT_CMD_H_ROCEE_BT_CMD_HW_SYNS_S, 1);
+	roce_set_field(bt_cmd_h_val, ROCEE_BT_CMD_H_ROCEE_BT_CMD_BA_H_M,
+		       ROCEE_BT_CMD_H_ROCEE_BT_CMD_BA_H_S, 0);
+
+	spin_lock_irqsave(&hr_dev->bt_cmd_lock, flags);
+
+	bt_cmd = hr_dev->reg_base + ROCEE_BT_CMD_H_REG;
+
+	end = msecs_to_jiffies(HW_SYNC_TIMEOUT_MSECS) + jiffies;
+	while (1) {
+		if (readl(bt_cmd) >> BT_CMD_SYNC_SHIFT) {
+			if (!(time_before(jiffies, end))) {
+				dev_err(dev, "Write bt_cmd err,hw_sync is not zero.\n");
+				spin_unlock_irqrestore(&hr_dev->bt_cmd_lock,
+						       flags);
+				return -EBUSY;
+			}
+		} else {
+			break;
+		}
+		msleep(HW_SYNC_SLEEP_TIME_INTERVAL);
+	}
+
+	bt_cmd_val[0] = 0;
+	bt_cmd_val[1] = bt_cmd_h_val;
+	hns_roce_write64_k(bt_cmd_val, hr_dev->reg_base + ROCEE_BT_CMD_L_REG);
+	spin_unlock_irqrestore(&hr_dev->bt_cmd_lock, flags);
+
+	return ret;
+}
+
+int hns_roce_init_hem_table(struct hns_roce_dev *hr_dev,
+			    struct hns_roce_hem_table *table, u32 type,
+			    unsigned long obj_size, unsigned long nobj,
+			    int use_lowmem)
+{
+	unsigned long obj_per_chunk;
+	unsigned long num_hem;
+
+	obj_per_chunk = HNS_ROCE_TABLE_CHUNK_SIZE / obj_size;
+	num_hem = (nobj + obj_per_chunk - 1) / obj_per_chunk;
+
+	table->hem = kcalloc(num_hem, sizeof(*table->hem), GFP_KERNEL);
+	if (!table->hem)
+		return -ENOMEM;
+
+	table->type = type;
+	table->num_hem = num_hem;
+	table->num_obj = nobj;
+	table->obj_size = obj_size;
+	table->lowmem = use_lowmem;
+	mutex_init(&table->mutex);
+
+	return 0;
+}
+
+void hns_roce_cleanup_hem_table(struct hns_roce_dev *hr_dev,
+				struct hns_roce_hem_table *table)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	unsigned long i;
+
+	for (i = 0; i < table->num_hem; ++i)
+		if (table->hem[i]) {
+			if (hns_roce_clear_hem(hr_dev, table,
+			    i * HNS_ROCE_TABLE_CHUNK_SIZE / table->obj_size))
+				dev_err(dev, "Clear HEM base address failed.\n");
+
+			hns_roce_free_hem(hr_dev, table->hem[i]);
+		}
+
+	kfree(table->hem);
+}
+
+void hns_roce_cleanup_hem(struct hns_roce_dev *hr_dev)
+{
+	hns_roce_cleanup_hem_table(hr_dev, &hr_dev->cq_table.table);
+	hns_roce_cleanup_hem_table(hr_dev, &hr_dev->qp_table.irrl_table);
+	hns_roce_cleanup_hem_table(hr_dev, &hr_dev->qp_table.qp_table);
+	hns_roce_cleanup_hem_table(hr_dev, &hr_dev->mr_table.mtpt_table);
+	hns_roce_cleanup_hem_table(hr_dev, &hr_dev->mr_table.mtt_table);
+}
diff --git a/drivers/infiniband/hw/hns/hns_roce_hem.h b/drivers/infiniband/hw/hns/hns_roce_hem.h
new file mode 100644
index 0000000..11b79c3
--- /dev/null
+++ b/drivers/infiniband/hw/hns/hns_roce_hem.h
@@ -0,0 +1,114 @@
+/*
+ * Copyright (c) 2016 Hisilicon Limited.
+ * Copyright (c) 2007, 2008 Mellanox Technologies. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#ifndef _HNS_ROCE_HEM_H
+#define _HNS_ROCE_HEM_H
+
+enum {
+	/* MAP HEM(Hardware Entry Memory) */
+	HEM_TYPE_QPC = 0,
+	HEM_TYPE_MTPT,
+	HEM_TYPE_CQC,
+	HEM_TYPE_SRQC,
+
+	 /* UNMAP HEM */
+	HEM_TYPE_MTT,
+	HEM_TYPE_IRRL,
+};
+
+#define HNS_ROCE_HEM_CHUNK_LEN	\
+	 ((256 - sizeof(struct list_head) - 2 * sizeof(int)) /	 \
+	 (sizeof(struct scatterlist)))
+
+struct hns_roce_hem_chunk {
+	struct list_head	 list;
+	int			 npages;
+	int			 nsg;
+	struct scatterlist	 mem[HNS_ROCE_HEM_CHUNK_LEN];
+};
+
+struct hns_roce_hem {
+	struct list_head	 chunk_list;
+	int			 refcount;
+};
+
+struct hns_roce_hem_iter {
+	struct hns_roce_hem		 *hem;
+	struct hns_roce_hem_chunk	 *chunk;
+	int				 page_idx;
+};
+
+void hns_roce_free_hem(struct hns_roce_dev *hr_dev, struct hns_roce_hem *hem);
+int hns_roce_init_hem_table(struct hns_roce_dev *hr_dev,
+			    struct hns_roce_hem_table *table, u32 type,
+			    unsigned long obj_size, unsigned long nobj,
+			    int use_lowmem);
+void hns_roce_cleanup_hem_table(struct hns_roce_dev *hr_dev,
+				struct hns_roce_hem_table *table);
+void hns_roce_cleanup_hem(struct hns_roce_dev *hr_dev);
+
+static inline void hns_roce_hem_first(struct hns_roce_hem *hem,
+				      struct hns_roce_hem_iter *iter)
+{
+	iter->hem = hem;
+	iter->chunk = list_empty(&hem->chunk_list) ? NULL :
+				 list_entry(hem->chunk_list.next,
+					    struct hns_roce_hem_chunk, list);
+	 iter->page_idx = 0;
+}
+
+static inline int hns_roce_hem_last(struct hns_roce_hem_iter *iter)
+{
+	return !iter->chunk;
+}
+
+static inline void hns_roce_hem_next(struct hns_roce_hem_iter *iter)
+{
+	if (++iter->page_idx >= iter->chunk->nsg) {
+		if (iter->chunk->list.next == &iter->hem->chunk_list) {
+			iter->chunk = NULL;
+			return;
+		}
+
+		iter->chunk = list_entry(iter->chunk->list.next,
+					 struct hns_roce_hem_chunk, list);
+		iter->page_idx = 0;
+	}
+}
+
+static inline dma_addr_t hns_roce_hem_addr(struct hns_roce_hem_iter *iter)
+{
+	return sg_dma_address(&iter->chunk->mem[iter->page_idx]);
+}
+
+#endif /*_HNS_ROCE_HEM_H*/
diff --git a/drivers/infiniband/hw/hns/hns_roce_main.c b/drivers/infiniband/hw/hns/hns_roce_main.c
index c8dff65..0872780 100644
--- a/drivers/infiniband/hw/hns/hns_roce_main.c
+++ b/drivers/infiniband/hw/hns/hns_roce_main.c
@@ -37,6 +37,7 @@
 #include <rdma/ib_user_verbs.h>
 #include "hns_roce_common.h"
 #include "hns_roce_device.h"
+#include "hns_roce_hem.h"
 
 static int hns_roce_get_cfg(struct hns_roce_dev *hr_dev)
 {
@@ -104,6 +105,70 @@ static int hns_roce_get_cfg(struct hns_roce_dev *hr_dev)
 	return 0;
 }
 
+static int hns_roce_init_hem(struct hns_roce_dev *hr_dev)
+{
+	int ret;
+	struct device *dev = &hr_dev->pdev->dev;
+
+	ret = hns_roce_init_hem_table(hr_dev, &hr_dev->mr_table.mtt_table,
+				      HEM_TYPE_MTT, hr_dev->caps.mtt_entry_sz,
+				      hr_dev->caps.num_mtt_segs, 1);
+	if (ret) {
+		dev_err(dev, "Failed to init MTT context memory, aborting.\n");
+		return ret;
+	}
+
+	ret = hns_roce_init_hem_table(hr_dev, &hr_dev->mr_table.mtpt_table,
+				      HEM_TYPE_MTPT, hr_dev->caps.mtpt_entry_sz,
+				      hr_dev->caps.num_mtpts, 1);
+	if (ret) {
+		dev_err(dev, "Failed to init MTPT context memory, aborting.\n");
+		goto err_unmap_mtt;
+	}
+
+	ret = hns_roce_init_hem_table(hr_dev, &hr_dev->qp_table.qp_table,
+				      HEM_TYPE_QPC, hr_dev->caps.qpc_entry_sz,
+				      hr_dev->caps.num_qps, 1);
+	if (ret) {
+		dev_err(dev, "Failed to init QP context memory, aborting.\n");
+		goto err_unmap_dmpt;
+	}
+
+	ret = hns_roce_init_hem_table(hr_dev, &hr_dev->qp_table.irrl_table,
+				      HEM_TYPE_IRRL,
+				      hr_dev->caps.irrl_entry_sz *
+				      hr_dev->caps.max_qp_init_rdma,
+				      hr_dev->caps.num_qps, 1);
+	if (ret) {
+		dev_err(dev, "Failed to init irrl_table memory, aborting.\n");
+		goto err_unmap_qp;
+	}
+
+	ret = hns_roce_init_hem_table(hr_dev, &hr_dev->cq_table.table,
+				      HEM_TYPE_CQC, hr_dev->caps.cqc_entry_sz,
+				      hr_dev->caps.num_cqs, 1);
+	if (ret) {
+		dev_err(dev, "Failed to init CQ context memory, aborting.\n");
+		goto err_unmap_irrl;
+	}
+
+	return 0;
+
+err_unmap_irrl:
+	hns_roce_cleanup_hem_table(hr_dev, &hr_dev->qp_table.irrl_table);
+
+err_unmap_qp:
+	hns_roce_cleanup_hem_table(hr_dev, &hr_dev->qp_table.qp_table);
+
+err_unmap_dmpt:
+	hns_roce_cleanup_hem_table(hr_dev, &hr_dev->mr_table.mtpt_table);
+
+err_unmap_mtt:
+	hns_roce_cleanup_hem_table(hr_dev, &hr_dev->mr_table.mtt_table);
+
+	return ret;
+}
+
 /**
 * hns_roce_probe - RoCE driver entrance
 * @pdev: pointer to platform device
@@ -167,6 +232,16 @@ static int hns_roce_probe(struct platform_device *pdev)
 		}
 	}
 
+	ret = hns_roce_init_hem(hr_dev);
+	if (ret) {
+		dev_err(dev, "init HEM(Hardware Entry Memory) failed!\n");
+		goto error_failed_init_hem;
+	}
+
+error_failed_init_hem:
+	if (hr_dev->cmd_mod)
+		hns_roce_cmd_use_polling(hr_dev);
+
 error_failed_use_event:
 	hns_roce_cleanup_eq_table(hr_dev);
 
@@ -192,6 +267,8 @@ static int hns_roce_remove(struct platform_device *pdev)
 {
 	struct hns_roce_dev *hr_dev = platform_get_drvdata(pdev);
 
+	hns_roce_cleanup_hem(hr_dev);
+
 	if (hr_dev->cmd_mod)
 		hns_roce_cmd_use_polling(hr_dev);
 
-- 
1.9.1
