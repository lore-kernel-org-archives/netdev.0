From: Lijun Ou <oulijun@huawei.com>
Subject: [PATCH v10 08/22] IB/hns: Add icm support
Date: Thu, 16 Jun 2016 22:35:16 +0800
Message-ID: <1466087730-54856-9-git-send-email-oulijun@huawei.com>
References: <1466087730-54856-1-git-send-email-oulijun@huawei.com>
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
In-Reply-To: <1466087730-54856-1-git-send-email-oulijun@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch mainly added icm support for RoCE. It initializes icm
which managers the relative memory blocks for RoCE. The data
structures of RoCE will be located in it. For example, CQ table,
QP table and MTPT table so on.

Signed-off-by: Wei Hu <xavier.huwei@huawei.com>
Signed-off-by: Nenglong Zhao <zhaonenglong@hisilicon.com>
Signed-off-by: Lijun Ou <oulijun@huawei.com>
---
PATCH v9/v8/v7/v6:
- No change over the PATCH v5

PATCH v5:
- The initial patch which was redesigned based on the second patch
  in PATCH v4
---
---
 drivers/infiniband/hw/hns/hns_roce_common.h |  19 ++
 drivers/infiniband/hw/hns/hns_roce_device.h |  30 ++
 drivers/infiniband/hw/hns/hns_roce_icm.c    | 460 ++++++++++++++++++++++++++++
 drivers/infiniband/hw/hns/hns_roce_icm.h    | 119 +++++++
 drivers/infiniband/hw/hns/hns_roce_main.c   |  84 +++++
 5 files changed, 712 insertions(+)
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_icm.c
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_icm.h

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
index 57184ab..ab9ba61 100644
--- a/drivers/infiniband/hw/hns/hns_roce_device.h
+++ b/drivers/infiniband/hw/hns/hns_roce_device.h
@@ -111,6 +111,26 @@ enum {
 	HNS_ROCE_CMD_SUCCESS			= 1,
 };
 
+struct hns_roce_icm_table {
+	/* ICM type: 0 = qpc 1 = mtt 2 = cqc 3 = srq 4 = other */
+	u32		type;
+	/* ICM array elment num */
+	unsigned long	num_icm;
+	/* ICM entry record obj total num */
+	unsigned long	num_obj;
+	/*Single obj size */
+	unsigned long	obj_size;
+	int		lowmem;
+	int		coherent;
+	struct mutex	mutex;
+	struct hns_roce_icm **icm;
+};
+
+struct hns_roce_mr_table {
+	struct hns_roce_icm_table	mtt_table;
+	struct hns_roce_icm_table	mtpt_table;
+};
+
 struct hns_roce_buf_list {
 	void		*buf;
 	dma_addr_t	map;
@@ -126,11 +146,14 @@ struct hns_roce_cq {
 
 struct hns_roce_qp_table {
 	spinlock_t			lock;
+	struct hns_roce_icm_table	qp_table;
+	struct hns_roce_icm_table	irrl_table;
 };
 
 struct hns_roce_cq_table {
 	spinlock_t			lock;
 	struct radix_tree_root		tree;
+	struct hns_roce_icm_table	table;
 };
 
 struct hns_roce_cmd_context {
@@ -259,6 +282,7 @@ struct hns_roce_dev {
 	struct ib_device	ib_dev;
 	struct platform_device  *pdev;
 	const char		*irq_names;
+	spinlock_t		bt_cmd_lock;
 	struct hns_roce_ib_iboe iboe;
 
 	int			irq[HNS_ROCE_MAX_IRQ_NUM];
@@ -273,6 +297,7 @@ struct hns_roce_dev {
 	u32                     hw_rev;
 
 	struct hns_roce_cmdq	cmd;
+	struct hns_roce_mr_table  mr_table;
 	struct hns_roce_cq_table  cq_table;
 	struct hns_roce_qp_table  qp_table;
 	struct hns_roce_eq_table  eq_table;
@@ -282,6 +307,11 @@ struct hns_roce_dev {
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
diff --git a/drivers/infiniband/hw/hns/hns_roce_icm.c b/drivers/infiniband/hw/hns/hns_roce_icm.c
new file mode 100644
index 0000000..86be920
--- /dev/null
+++ b/drivers/infiniband/hw/hns/hns_roce_icm.c
@@ -0,0 +1,460 @@
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
+#include <linux/errno.h>
+#include <linux/init.h>
+#include <linux/mm.h>
+#include <linux/platform_device.h>
+#include <linux/slab.h>
+#include <linux/scatterlist.h>
+#include "hns_roce_device.h"
+#include "hns_roce_icm.h"
+#include "hns_roce_common.h"
+
+#define HW_SYNC_TIMEOUT_MSECS		500
+
+#define HNS_ROCE_ICM_ALLOC_SIZE		(1 << 17)
+#define HNS_ROCE_TABLE_CHUNK_SIZE	(1 << 17)
+
+#define DMA_ADDR_T_SHIFT		12
+#define BT_CMD_SYNC_SHIFT		31
+#define BT_BA_SHIFT			32
+
+static int hns_roce_alloc_icm_pages(struct scatterlist *mem, int order,
+				    gfp_t gfp_mask)
+{
+	struct page *page;
+
+	page = alloc_pages(gfp_mask, order);
+	if (!page)
+		return -ENOMEM;
+
+	sg_set_page(mem, page, PAGE_SIZE << order, 0);
+
+	return 0;
+}
+
+static int hns_roce_alloc_icm_coherent(struct device *dev,
+				       struct scatterlist *mem, int order,
+				       gfp_t gfp_mask)
+{
+	void *buf = dma_alloc_coherent(dev, PAGE_SIZE << order,
+				       &sg_dma_address(mem), gfp_mask);
+	if (!buf)
+		return -ENOMEM;
+
+	sg_set_buf(mem, buf, PAGE_SIZE << order);
+	WARN_ON(mem->offset);
+	sg_dma_len(mem) = PAGE_SIZE << order;
+	return 0;
+}
+
+struct hns_roce_icm *hns_roce_alloc_icm(struct hns_roce_dev *hr_dev, int npages,
+					gfp_t gfp_mask, int coherent)
+{
+	struct hns_roce_icm_chunk *chunk = NULL;
+	struct hns_roce_icm *icm;
+	int cur_order;
+	int ret;
+
+	WARN_ON(coherent && (gfp_mask & __GFP_HIGHMEM));
+
+	icm = kmalloc(sizeof(*icm),
+		      gfp_mask & ~(__GFP_HIGHMEM | __GFP_NOWARN));
+	if (!icm)
+		return NULL;
+
+	icm->refcount = 0;
+	INIT_LIST_HEAD(&icm->chunk_list);
+
+	cur_order = get_order(HNS_ROCE_ICM_ALLOC_SIZE);
+
+	while (npages > 0) {
+		if (!chunk) {
+			chunk = kmalloc(sizeof(*chunk),
+				gfp_mask & ~(__GFP_HIGHMEM | __GFP_NOWARN));
+			if (!chunk)
+				goto fail;
+
+			sg_init_table(chunk->mem, HNS_ROCE_ICM_CHUNK_LEN);
+			chunk->npages = 0;
+			chunk->nsg = 0;
+			list_add_tail(&chunk->list, &icm->chunk_list);
+		}
+
+		while (1 << cur_order > npages)
+			--cur_order;
+
+		if (coherent)
+			ret = hns_roce_alloc_icm_coherent(&hr_dev->pdev->dev,
+						&chunk->mem[chunk->npages],
+						cur_order, gfp_mask);
+		else
+			ret = hns_roce_alloc_icm_pages(
+						&chunk->mem[chunk->npages],
+						cur_order, gfp_mask);
+		if (!ret) {
+			++chunk->npages;
+			if (coherent) {
+				++chunk->nsg;
+			} else if (chunk->npages == HNS_ROCE_ICM_CHUNK_LEN) {
+				chunk->nsg = dma_map_sg(&hr_dev->pdev->dev,
+						      chunk->mem, chunk->npages,
+						      DMA_BIDIRECTIONAL);
+				if (chunk->nsg <= 0)
+					goto fail;
+
+				chunk = NULL;
+			}
+			npages -= 1 << cur_order;
+		} else {
+			/*
+			* If failed on alloc 128k memory one time,
+			* no alloc small block memory,
+			* directly return fail
+			*/
+			goto fail;
+		}
+	}
+
+	if (!coherent && chunk) {
+		chunk->nsg = dma_map_sg(&hr_dev->pdev->dev, chunk->mem,
+					chunk->npages, DMA_BIDIRECTIONAL);
+		if (chunk->nsg <= 0)
+			goto fail;
+	}
+
+	return icm;
+
+fail:
+	hns_roce_free_icm(hr_dev, icm, coherent);
+	return NULL;
+}
+
+static void hns_roce_free_icm_pages(struct hns_roce_dev *hr_dev,
+				    struct hns_roce_icm_chunk *chunk)
+{
+	int i;
+
+	if (chunk->nsg > 0)
+		dma_unmap_sg(&hr_dev->pdev->dev, chunk->mem, chunk->npages,
+			     DMA_BIDIRECTIONAL);
+
+	for (i = 0; i < chunk->npages; ++i)
+		__free_pages(sg_page(&chunk->mem[i]),
+			     get_order(chunk->mem[i].length));
+}
+
+static void hns_roce_free_icm_coherent(struct hns_roce_dev *hr_dev,
+				       struct hns_roce_icm_chunk *chunk)
+{
+	int i;
+
+	for (i = 0; i < chunk->npages; ++i)
+		dma_free_coherent(&hr_dev->pdev->dev, chunk->mem[i].length,
+				  lowmem_page_address(sg_page(&chunk->mem[i])),
+				  sg_dma_address(&chunk->mem[i]));
+}
+
+void hns_roce_free_icm(struct hns_roce_dev *hr_dev, struct hns_roce_icm *icm,
+		       int coherent)
+{
+	struct hns_roce_icm_chunk *chunk, *tmp;
+
+	if (!icm)
+		return;
+
+	list_for_each_entry_safe(chunk, tmp, &icm->chunk_list, list) {
+		if (coherent)
+			hns_roce_free_icm_coherent(hr_dev, chunk);
+		else
+			hns_roce_free_icm_pages(hr_dev, chunk);
+
+		kfree(chunk);
+	}
+
+	kfree(icm);
+}
+
+static int hns_roce_map_icm(struct hns_roce_dev *hr_dev,
+			    struct hns_roce_icm_table *table, unsigned long obj)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	spinlock_t *lock = &hr_dev->bt_cmd_lock;
+	unsigned long end = 0;
+	unsigned long flags;
+	struct hns_roce_icm_iter iter;
+	void __iomem *bt_cmd;
+	u32 bt_cmd_h_val = 0;
+	u32 bt_cmd_val[2];
+	u32 bt_cmd_l = 0;
+	u64 bt_ba = 0;
+	int ret = 0;
+
+	/* Find the icm entry */
+	unsigned long i = (obj & (table->num_obj - 1)) /
+			  (HNS_ROCE_TABLE_CHUNK_SIZE / table->obj_size);
+
+	switch (table->type) {
+	case ICM_TYPE_QPC:
+		roce_set_field(bt_cmd_h_val, ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_M,
+			       ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_S, ICM_TYPE_QPC);
+		break;
+	case ICM_TYPE_MTPT:
+		roce_set_field(bt_cmd_h_val, ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_M,
+			       ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_S,
+			       ICM_TYPE_MTPT);
+		break;
+	case ICM_TYPE_CQC:
+		roce_set_field(bt_cmd_h_val, ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_M,
+			       ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_S, ICM_TYPE_CQC);
+		break;
+	case ICM_TYPE_SRQC:
+		roce_set_field(bt_cmd_h_val, ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_M,
+			       ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_S,
+			       ICM_TYPE_SRQC);
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
+	for (hns_roce_icm_first(table->icm[i], &iter);
+	     !hns_roce_icm_last(&iter); hns_roce_icm_next(&iter)) {
+		bt_ba = hns_roce_icm_addr(&iter) >> DMA_ADDR_T_SHIFT;
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
+					ret = -EBUSY;
+					return ret;
+				}
+			} else {
+				break;
+			}
+			msleep(20);
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
+static int hns_roce_unmap_icm(struct hns_roce_dev *hr_dev,
+			      struct hns_roce_icm_table *table,
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
+	case ICM_TYPE_QPC:
+		dev_dbg(dev, "UNMAP QPC BT  :\n");
+		roce_set_field(bt_cmd_h_val, ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_M,
+			       ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_S, ICM_TYPE_QPC);
+		break;
+	case ICM_TYPE_MTPT:
+		dev_dbg(dev, "UNMAP MTPT BT :\n");
+		roce_set_field(bt_cmd_h_val, ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_M,
+			       ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_S,
+			       ICM_TYPE_MTPT);
+		break;
+	case ICM_TYPE_CQC:
+		dev_dbg(dev, "UNMAP CQC BT  :\n");
+		roce_set_field(bt_cmd_h_val, ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_M,
+			       ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_S, ICM_TYPE_CQC);
+		break;
+	case ICM_TYPE_SRQC:
+		roce_set_field(bt_cmd_h_val, ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_M,
+			       ROCEE_BT_CMD_H_ROCEE_BT_CMD_MDF_S,
+			       ICM_TYPE_SRQC);
+		break;
+	default:
+		return ret;
+	}
+	roce_set_field(bt_cmd_h_val, ROCEE_BT_CMD_H_ROCEE_BT_CMD_IN_MDF_M,
+		       ROCEE_BT_CMD_H_ROCEE_BT_CMD_IN_MDF_S, obj);
+	roce_set_bit(bt_cmd_h_val, ROCEE_BT_CMD_H_ROCEE_BT_CMD_S, 1);
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
+		msleep(20);
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
+int hns_roce_init_icm_table(struct hns_roce_dev *hr_dev,
+			    struct hns_roce_icm_table *table, u32 type,
+			    unsigned long obj_size, unsigned long nobj,
+			    int reserved, int use_lowmem, int use_coherent)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	u32 chunk_size;
+	unsigned long obj_per_chunk;
+	unsigned long num_icm;
+	unsigned long i;
+
+	obj_per_chunk = HNS_ROCE_TABLE_CHUNK_SIZE / obj_size;
+	num_icm = (nobj + obj_per_chunk - 1) / obj_per_chunk;
+
+	table->icm = kcalloc(num_icm, sizeof(*table->icm), GFP_KERNEL);
+	if (!table->icm)
+		return -ENOMEM;
+
+	table->type = type;
+	table->num_icm = num_icm;
+	table->num_obj = nobj;
+	table->obj_size = obj_size;
+	table->lowmem = use_lowmem;
+	table->coherent = use_coherent;
+	mutex_init(&table->mutex);
+
+	for (i = 0; i * HNS_ROCE_TABLE_CHUNK_SIZE < reserved * obj_size; ++i) {
+		chunk_size = HNS_ROCE_TABLE_CHUNK_SIZE;
+		if ((i + 1) * HNS_ROCE_TABLE_CHUNK_SIZE > nobj * obj_size)
+			chunk_size = PAGE_ALIGN(nobj * obj_size -
+						i * HNS_ROCE_TABLE_CHUNK_SIZE);
+
+		table->icm[i] = hns_roce_alloc_icm(hr_dev,
+				chunk_size >> PAGE_SHIFT, (use_lowmem ?
+				GFP_KERNEL : GFP_HIGHUSER) | __GFP_NOWARN,
+				use_coherent);
+		if (!table->icm[i])
+			goto error_failed_alloc_icm;
+
+		if (hns_roce_map_icm(hr_dev, table,
+			i * HNS_ROCE_TABLE_CHUNK_SIZE / obj_size)) {
+			dev_err(dev, "map icm table failed.\n");
+			goto error_failed_alloc_icm;
+		}
+
+		/*
+		 * Add a reference to this ICM chunk so that it never
+		 * Gets freed (since it contains reserved firmware objects).
+		 */
+		++table->icm[i]->refcount;
+	}
+
+	return 0;
+
+error_failed_alloc_icm:
+	for (i = 0; i < num_icm; ++i)
+		if (table->icm[i]) {
+			if (hns_roce_unmap_icm(hr_dev, table,
+				i * HNS_ROCE_TABLE_CHUNK_SIZE / obj_size))
+				dev_err(dev, "unmap icm table failed.\n");
+
+			hns_roce_free_icm(hr_dev, table->icm[i], use_coherent);
+		}
+
+	kfree(table->icm);
+
+	return -ENOMEM;
+}
+
+void hns_roce_cleanup_icm_table(struct hns_roce_dev *hr_dev,
+				struct hns_roce_icm_table *table)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	unsigned long i;
+
+	for (i = 0; i < table->num_icm; ++i)
+		if (table->icm[i]) {
+			if (hns_roce_unmap_icm(hr_dev, table,
+			    i * HNS_ROCE_TABLE_CHUNK_SIZE / table->obj_size))
+				dev_err(dev, "unmap icm table failed.\n");
+
+			hns_roce_free_icm(hr_dev, table->icm[i],
+					  table->coherent);
+		}
+
+	kfree(table->icm);
+}
+
+void hns_roce_cleanup_icm(struct hns_roce_dev *hr_dev)
+{
+	hns_roce_cleanup_icm_table(hr_dev, &hr_dev->cq_table.table);
+	hns_roce_cleanup_icm_table(hr_dev, &hr_dev->qp_table.irrl_table);
+	hns_roce_cleanup_icm_table(hr_dev, &hr_dev->qp_table.qp_table);
+	hns_roce_cleanup_icm_table(hr_dev, &hr_dev->mr_table.mtpt_table);
+	hns_roce_cleanup_icm_table(hr_dev, &hr_dev->mr_table.mtt_table);
+}
diff --git a/drivers/infiniband/hw/hns/hns_roce_icm.h b/drivers/infiniband/hw/hns/hns_roce_icm.h
new file mode 100644
index 0000000..719b64e
--- /dev/null
+++ b/drivers/infiniband/hw/hns/hns_roce_icm.h
@@ -0,0 +1,119 @@
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
+#ifndef _HNS_ROCE_ICM_H
+#define _HNS_ROCE_ICM_H
+
+#include <linux/list.h>
+#include <linux/mutex.h>
+#include <linux/pci.h>
+
+enum {
+	/* MAP ICM */
+	ICM_TYPE_QPC = 0,
+	ICM_TYPE_MTPT,
+	ICM_TYPE_CQC,
+	ICM_TYPE_SRQC,
+
+	 /* UNMAP ICM */
+	ICM_TYPE_MTT,
+	ICM_TYPE_IRRL,
+};
+
+#define HNS_ROCE_ICM_CHUNK_LEN	\
+	 ((256 - sizeof(struct list_head) - 2 * sizeof(int)) /	 \
+	 (sizeof(struct scatterlist)))
+
+struct hns_roce_icm_chunk {
+	struct list_head	 list;
+	int			 npages;
+	int			 nsg;
+	struct scatterlist	 mem[HNS_ROCE_ICM_CHUNK_LEN];
+};
+
+struct hns_roce_icm {
+	struct list_head	 chunk_list;
+	int			 refcount;
+};
+
+struct hns_roce_icm_iter {
+	struct hns_roce_icm		 *icm;
+	struct hns_roce_icm_chunk	 *chunk;
+	int				 page_idx;
+};
+
+void hns_roce_free_icm(struct hns_roce_dev *hr_dev,
+		       struct hns_roce_icm *icm, int coherent);
+int hns_roce_init_icm_table(struct hns_roce_dev *hr_dev,
+			    struct hns_roce_icm_table *table, u32 type,
+			    unsigned long obj_size, unsigned long nobj,
+			    int reserved, int use_lowmem, int use_coherent);
+void hns_roce_cleanup_icm_table(struct hns_roce_dev *hr_dev,
+				struct hns_roce_icm_table *table);
+void hns_roce_cleanup_icm(struct hns_roce_dev *hr_dev);
+
+static inline void hns_roce_icm_first(struct hns_roce_icm *icm,
+				      struct hns_roce_icm_iter *iter)
+{
+	iter->icm = icm;
+	iter->chunk = list_empty(&icm->chunk_list) ? NULL :
+				 list_entry(icm->chunk_list.next,
+					    struct hns_roce_icm_chunk, list);
+	 iter->page_idx = 0;
+}
+
+static inline int hns_roce_icm_last(struct hns_roce_icm_iter *iter)
+{
+	return !iter->chunk;
+}
+
+static inline void hns_roce_icm_next(struct hns_roce_icm_iter *iter)
+{
+	if (++iter->page_idx >= iter->chunk->nsg) {
+		if (iter->chunk->list.next == &iter->icm->chunk_list) {
+			iter->chunk = NULL;
+			return;
+		}
+
+		iter->chunk = list_entry(iter->chunk->list.next,
+					 struct hns_roce_icm_chunk, list);
+		iter->page_idx = 0;
+	}
+}
+
+static inline dma_addr_t hns_roce_icm_addr(struct hns_roce_icm_iter *iter)
+{
+	return sg_dma_address(&iter->chunk->mem[iter->page_idx]);
+}
+
+#endif /*_HNS_ROCE_ICM_H*/
diff --git a/drivers/infiniband/hw/hns/hns_roce_main.c b/drivers/infiniband/hw/hns/hns_roce_main.c
index 0b9cee7..3928ebb 100644
--- a/drivers/infiniband/hw/hns/hns_roce_main.c
+++ b/drivers/infiniband/hw/hns/hns_roce_main.c
@@ -59,6 +59,7 @@
 #include <rdma/ib_verbs.h>
 #include "hns_roce_common.h"
 #include "hns_roce_device.h"
+#include "hns_roce_icm.h"
 
 static int hns_roce_get_cfg(struct hns_roce_dev *hr_dev)
 {
@@ -131,6 +132,77 @@ static void hns_roce_profile_init(struct hns_roce_dev *hr_dev)
 	hr_dev->hw->hw_profile(hr_dev);
 }
 
+static int hns_roce_init_icm(struct hns_roce_dev *hr_dev)
+{
+	int ret;
+	struct device *dev = &hr_dev->pdev->dev;
+
+	ret = hns_roce_init_icm_table(hr_dev,
+				      (void *)&hr_dev->mr_table.mtt_table,
+				      ICM_TYPE_MTT, hr_dev->caps.mtt_entry_sz,
+				      hr_dev->caps.num_mtt_segs, 0, 1, 0);
+	if (ret) {
+		dev_err(dev, "Failed to map MTT context memory, aborting.\n");
+		return ret;
+	}
+
+	ret = hns_roce_init_icm_table(hr_dev,
+				      (void *)&hr_dev->mr_table.mtpt_table,
+				      ICM_TYPE_MTPT, hr_dev->caps.mtpt_entry_sz,
+				      hr_dev->caps.num_mtpts, 0, 1, 1);
+	if (ret) {
+		dev_err(dev, "Failed to map dMPT context memory, aborting.\n");
+		goto err_unmap_mtt;
+	}
+
+	ret = hns_roce_init_icm_table(hr_dev,
+				      (void *)&hr_dev->qp_table.qp_table,
+				      ICM_TYPE_QPC, hr_dev->caps.qpc_entry_sz,
+				      hr_dev->caps.num_qps, 0, 1, 0);
+	if (ret) {
+		dev_err(dev, "Failed to map QP context memory, aborting.\n");
+		goto err_unmap_dmpt;
+	}
+
+	ret = hns_roce_init_icm_table(hr_dev,
+				      (void *)&hr_dev->qp_table.irrl_table,
+				      ICM_TYPE_IRRL,
+				      hr_dev->caps.irrl_entry_sz *
+				      hr_dev->caps.max_qp_init_rdma,
+				      hr_dev->caps.num_qps, 0, 1, 0);
+	if (ret) {
+		dev_err(dev, "Failed to map irrl_table memory, aborting.\n");
+		goto err_unmap_qp;
+	}
+
+	ret = hns_roce_init_icm_table(hr_dev,
+				      (void *)&hr_dev->cq_table.table,
+				      ICM_TYPE_CQC, hr_dev->caps.cqc_entry_sz,
+				      hr_dev->caps.num_cqs, 0, 1, 0);
+	if (ret) {
+		dev_err(dev, "Failed to map CQ context memory, aborting.\n");
+		goto err_unmap_irrl;
+	}
+
+	return 0;
+
+err_unmap_irrl:
+	hns_roce_cleanup_icm_table(hr_dev,
+				   (void *)&hr_dev->qp_table.irrl_table);
+
+err_unmap_qp:
+	hns_roce_cleanup_icm_table(hr_dev, (void *)&hr_dev->qp_table.qp_table);
+
+err_unmap_dmpt:
+	hns_roce_cleanup_icm_table(hr_dev,
+				   (void *)&hr_dev->mr_table.mtpt_table);
+
+err_unmap_mtt:
+	hns_roce_cleanup_icm_table(hr_dev, (void *)&hr_dev->mr_table.mtt_table);
+
+	return ret;
+}
+
 /**
 * hns_roce_probe - RoCE driver entrance
 * @pdev: pointer to platform device
@@ -197,6 +269,16 @@ static int hns_roce_probe(struct platform_device *pdev)
 		}
 	}
 
+	ret = hns_roce_init_icm(hr_dev);
+	if (ret) {
+		dev_err(dev, "init icm fail!\n");
+		goto error_failed_init_icm;
+	}
+
+error_failed_init_icm:
+	if (hr_dev->cmd_mod)
+		hns_roce_cmd_use_polling(hr_dev);
+
 error_failed_use_event:
 	hns_roce_cleanup_eq_table(hr_dev);
 
@@ -222,6 +304,8 @@ static int hns_roce_remove(struct platform_device *pdev)
 {
 	struct hns_roce_dev *hr_dev = platform_get_drvdata(pdev);
 
+	hns_roce_cleanup_icm(hr_dev);
+
 	if (hr_dev->cmd_mod)
 		hns_roce_cmd_use_polling(hr_dev);
 
-- 
1.9.1
