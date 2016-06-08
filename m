From: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [RESEND PATCH v9 09/22] IB/hns: Add hca support
Date: Wed, 8 Jun 2016 14:44:44 +0800
Message-ID: <1465368297-82118-10-git-send-email-oulijun@huawei.com>
References: <1465368297-82118-1-git-send-email-oulijun@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	<ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1465368297-82118-1-git-send-email-oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch mainly setup hca for RoCE. It will do a series of
initial works, as follows:
    1. init uar table, allocate uar resource
    2. init pd table
    3. init cq table
    4. init mr table
    5. init qp table

Signed-off-by: Wei Hu <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Nenglong Zhao <zhaonenglong-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Signed-off-by: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 drivers/infiniband/hw/hns/hns_roce_alloc.c  | 128 +++++++++++++++++
 drivers/infiniband/hw/hns/hns_roce_cq.c     |  22 +++
 drivers/infiniband/hw/hns/hns_roce_device.h |  69 +++++++++
 drivers/infiniband/hw/hns/hns_roce_icm.c    |  88 ++++++++++++
 drivers/infiniband/hw/hns/hns_roce_icm.h    |   7 +
 drivers/infiniband/hw/hns/hns_roce_main.c   |  79 +++++++++++
 drivers/infiniband/hw/hns/hns_roce_mr.c     | 210 ++++++++++++++++++++++++++++
 drivers/infiniband/hw/hns/hns_roce_pd.c     |  88 ++++++++++++
 drivers/infiniband/hw/hns/hns_roce_qp.c     |  30 ++++
 9 files changed, 721 insertions(+)
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_alloc.c
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_mr.c
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_pd.c

diff --git a/drivers/infiniband/hw/hns/hns_roce_alloc.c b/drivers/infiniband/hw/hns/hns_roce_alloc.c
new file mode 100644
index 0000000..d2932c1
--- /dev/null
+++ b/drivers/infiniband/hw/hns/hns_roce_alloc.c
@@ -0,0 +1,128 @@
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
+#include <linux/bitmap.h>
+#include <linux/dma-mapping.h>
+#include <linux/errno.h>
+#include <linux/mm.h>
+#include <linux/slab.h>
+#include <linux/vmalloc.h>
+#include "hns_roce_device.h"
+
+int hns_roce_bitmap_alloc(struct hns_roce_bitmap *bitmap, unsigned long *obj)
+{
+	int ret = 0;
+
+	spin_lock(&bitmap->lock);
+	*obj = find_next_zero_bit(bitmap->table, bitmap->max, bitmap->last);
+	if (*obj >= bitmap->max) {
+		bitmap->top = (bitmap->top + bitmap->max + bitmap->reserved_top)
+			       & bitmap->mask;
+		*obj = find_first_zero_bit(bitmap->table, bitmap->max);
+	}
+
+	if (*obj < bitmap->max) {
+		set_bit(*obj, bitmap->table);
+		bitmap->last = (*obj + 1);
+		if (bitmap->last == bitmap->max)
+			bitmap->last = 0;
+		*obj |= bitmap->top;
+	} else {
+		ret = -1;
+	}
+
+	spin_unlock(&bitmap->lock);
+
+	return ret;
+}
+
+void hns_roce_bitmap_free(struct hns_roce_bitmap *bitmap, unsigned long obj)
+{
+	hns_roce_bitmap_free_range(bitmap, obj, 1);
+}
+
+void hns_roce_bitmap_free_range(struct hns_roce_bitmap *bitmap,
+				unsigned long obj, int cnt)
+{
+	int i;
+
+	obj &= bitmap->max + bitmap->reserved_top - 1;
+
+	spin_lock(&bitmap->lock);
+	for (i = 0; i < cnt; i++)
+		clear_bit(obj + i, bitmap->table);
+
+	bitmap->last = min(bitmap->last, obj);
+	bitmap->top = (bitmap->top + bitmap->max + bitmap->reserved_top)
+		       & bitmap->mask;
+	spin_unlock(&bitmap->lock);
+}
+
+int hns_roce_bitmap_init(struct hns_roce_bitmap *bitmap, u32 num, u32 mask,
+			 u32 reserved_bot, u32 reserved_top)
+{
+	u32 i;
+
+	if (num != roundup_pow_of_two(num))
+		return -EINVAL;
+
+	bitmap->last = 0;
+	bitmap->top = 0;
+	bitmap->max = num - reserved_top;
+	bitmap->mask = mask;
+	bitmap->reserved_top = reserved_top;
+	spin_lock_init(&bitmap->lock);
+	bitmap->table = kcalloc(BITS_TO_LONGS(bitmap->max), sizeof(long),
+				GFP_KERNEL);
+	if (!bitmap->table)
+		return -ENOMEM;
+
+	for (i = 0; i < reserved_bot; ++i)
+		set_bit(i, bitmap->table);
+
+	return 0;
+}
+
+void hns_roce_bitmap_cleanup(struct hns_roce_bitmap *bitmap)
+{
+	kfree(bitmap->table);
+}
+
+void hns_roce_cleanup_bitmap(struct hns_roce_dev *hr_dev)
+{
+	hns_roce_cleanup_qp_table(hr_dev);
+	hns_roce_cleanup_cq_table(hr_dev);
+	hns_roce_cleanup_mr_table(hr_dev);
+	hns_roce_cleanup_pd_table(hr_dev);
+	hns_roce_cleanup_uar_table(hr_dev);
+}
diff --git a/drivers/infiniband/hw/hns/hns_roce_cq.c b/drivers/infiniband/hw/hns/hns_roce_cq.c
index 42a3c98..52179fb 100644
--- a/drivers/infiniband/hw/hns/hns_roce_cq.c
+++ b/drivers/infiniband/hw/hns/hns_roce_cq.c
@@ -75,3 +75,25 @@ void hns_roce_cq_event(struct hns_roce_dev *hr_dev, u32 cqn, int event_type)
 	if (atomic_dec_and_test(&cq->refcount))
 		complete(&cq->free);
 }
+
+int hns_roce_init_cq_table(struct hns_roce_dev *hr_dev)
+{
+	struct hns_roce_cq_table *cq_table = &hr_dev->cq_table;
+	int ret;
+
+	spin_lock_init(&cq_table->lock);
+	INIT_RADIX_TREE(&cq_table->tree, GFP_ATOMIC);
+
+	ret = hns_roce_bitmap_init(&cq_table->bitmap, hr_dev->caps.num_cqs,
+				   hr_dev->caps.num_cqs - 1,
+				   hr_dev->caps.reserved_cqs, 0);
+	if (ret)
+		return ret;
+
+	return 0;
+}
+
+void hns_roce_cleanup_cq_table(struct hns_roce_dev *hr_dev)
+{
+	hns_roce_bitmap_cleanup(&hr_dev->cq_table.bitmap);
+}
diff --git a/drivers/infiniband/hw/hns/hns_roce_device.h b/drivers/infiniband/hw/hns/hns_roce_device.h
index f7d9e0c..2b42bb6 100644
--- a/drivers/infiniband/hw/hns/hns_roce_device.h
+++ b/drivers/infiniband/hw/hns/hns_roce_device.h
@@ -111,6 +111,38 @@ enum {
 	HNS_ROCE_CMD_SUCCESS			= 1,
 };
 
+struct hns_roce_uar {
+	u64		pfn;
+	unsigned long	index;
+};
+
+struct hns_roce_bitmap {
+	/* Bitmap Traversal last a bit which is 1 */
+	unsigned long		last;
+	unsigned long		top;
+	unsigned long		max;
+	unsigned long		reserved_top;
+	unsigned long		mask;
+	spinlock_t		lock;
+	unsigned long		*table;
+};
+
+/* Order bitmap length -- bit num compute formula: 1 << (max_order - order) */
+/* Order = 0: bitmap is biggest, order = max bitmap is least (only a bit) */
+/* Every bit repesent to a partner free/used status in bitmap */
+/*
+* Initial, bits of other bitmap are all 0 except that a bit of max_order is 1
+* Bit = 1 represent to idle and available; bit = 0: not available
+*/
+struct hns_roce_buddy {
+	/* Members point to every order level bitmap */
+	unsigned long **bits;
+	/* Represent to avail bits of the order level bitmap */
+	u32            *num_free;
+	int             max_order;
+	spinlock_t      lock;
+};
+
 struct hns_roce_icm_table {
 	/* ICM type: 0 = qpc 1 = mtt 2 = cqc 3 = srq 4 = other */
 	u32		type;
@@ -127,6 +159,8 @@ struct hns_roce_icm_table {
 };
 
 struct hns_roce_mr_table {
+	struct hns_roce_bitmap		mtpt_bitmap;
+	struct hns_roce_buddy		mtt_buddy;
 	struct hns_roce_icm_table	mtt_table;
 	struct hns_roce_icm_table	mtpt_table;
 };
@@ -144,13 +178,19 @@ struct hns_roce_cq {
 	struct completion		free;
 };
 
+struct hns_roce_uar_table {
+	struct hns_roce_bitmap bitmap;
+};
+
 struct hns_roce_qp_table {
+	struct hns_roce_bitmap		bitmap;
 	spinlock_t			lock;
 	struct hns_roce_icm_table	qp_table;
 	struct hns_roce_icm_table	irrl_table;
 };
 
 struct hns_roce_cq_table {
+	struct hns_roce_bitmap		bitmap;
 	spinlock_t			lock;
 	struct radix_tree_root		tree;
 	struct hns_roce_icm_table	table;
@@ -282,6 +322,9 @@ struct hns_roce_hw {
 struct hns_roce_dev {
 	struct ib_device	ib_dev;
 	struct platform_device  *pdev;
+	struct hns_roce_uar     priv_uar;
+	spinlock_t		sm_lock;
+	spinlock_t		cq_db_lock;
 	spinlock_t		bt_cmd_lock;
 	struct hns_roce_ib_iboe iboe;
 
@@ -297,6 +340,8 @@ struct hns_roce_dev {
 	u32                     hw_rev;
 
 	struct hns_roce_cmdq	cmd;
+	struct hns_roce_bitmap    pd_bitmap;
+	struct hns_roce_uar_table uar_table;
 	struct hns_roce_mr_table  mr_table;
 	struct hns_roce_cq_table  cq_table;
 	struct hns_roce_qp_table  qp_table;
@@ -319,6 +364,11 @@ static inline struct hns_roce_qp
 				 qpn & (hr_dev->caps.num_qps - 1));
 }
 
+int hns_roce_init_uar_table(struct hns_roce_dev *dev);
+int hns_roce_uar_alloc(struct hns_roce_dev *dev, struct hns_roce_uar *uar);
+void hns_roce_uar_free(struct hns_roce_dev *dev, struct hns_roce_uar *uar);
+void hns_roce_cleanup_uar_table(struct hns_roce_dev *dev);
+
 int hns_roce_cmd_init(struct hns_roce_dev *hr_dev);
 void hns_roce_cmd_cleanup(struct hns_roce_dev *hr_dev);
 void hns_roce_cmd_event(struct hns_roce_dev *hr_dev, u16 token, u8 status,
@@ -326,9 +376,28 @@ void hns_roce_cmd_event(struct hns_roce_dev *hr_dev, u16 token, u8 status,
 int hns_roce_cmd_use_events(struct hns_roce_dev *hr_dev);
 void hns_roce_cmd_use_polling(struct hns_roce_dev *hr_dev);
 
+int hns_roce_init_pd_table(struct hns_roce_dev *hr_dev);
+int hns_roce_init_mr_table(struct hns_roce_dev *hr_dev);
 int hns_roce_init_eq_table(struct hns_roce_dev *hr_dev);
+int hns_roce_init_cq_table(struct hns_roce_dev *hr_dev);
+int hns_roce_init_qp_table(struct hns_roce_dev *hr_dev);
 
+void hns_roce_cleanup_pd_table(struct hns_roce_dev *hr_dev);
+void hns_roce_cleanup_mr_table(struct hns_roce_dev *hr_dev);
 void hns_roce_cleanup_eq_table(struct hns_roce_dev *hr_dev);
+void hns_roce_cleanup_cq_table(struct hns_roce_dev *hr_dev);
+void hns_roce_cleanup_qp_table(struct hns_roce_dev *hr_dev);
+
+int hns_roce_bitmap_alloc(struct hns_roce_bitmap *bitmap, unsigned long *obj);
+void hns_roce_bitmap_free(struct hns_roce_bitmap *bitmap, unsigned long obj);
+int hns_roce_bitmap_init(struct hns_roce_bitmap *bitmap, u32 num, u32 mask,
+			 u32 reserved_bot, u32 resetrved_top);
+void hns_roce_bitmap_cleanup(struct hns_roce_bitmap *bitmap);
+void hns_roce_cleanup_bitmap(struct hns_roce_dev *hr_dev);
+int hns_roce_bitmap_alloc_range(struct hns_roce_bitmap *bitmap, int cnt,
+				int align, unsigned long *obj);
+void hns_roce_bitmap_free_range(struct hns_roce_bitmap *bitmap,
+				unsigned long obj, int cnt);
 
 void hns_roce_cq_completion(struct hns_roce_dev *hr_dev, u32 cqn);
 void hns_roce_cq_event(struct hns_roce_dev *hr_dev, u32 cqn, int event_type);
diff --git a/drivers/infiniband/hw/hns/hns_roce_icm.c b/drivers/infiniband/hw/hns/hns_roce_icm.c
index 7404a6f..cfd7b96 100644
--- a/drivers/infiniband/hw/hns/hns_roce_icm.c
+++ b/drivers/infiniband/hw/hns/hns_roce_icm.c
@@ -361,6 +361,94 @@ int hns_roce_unmap_icm(struct hns_roce_dev *hr_dev,
 	return ret;
 }
 
+int hns_roce_table_get(struct hns_roce_dev *hr_dev,
+		       struct hns_roce_icm_table *table, unsigned long obj)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	int ret = 0;
+	unsigned long i;
+
+	i = (obj & (table->num_obj - 1)) / (HNS_ROCE_TABLE_CHUNK_SIZE /
+	     table->obj_size);
+
+	mutex_lock(&table->mutex);
+
+	if (table->icm[i]) {
+		++table->icm[i]->refcount;
+		goto out;
+	}
+
+	table->icm[i] = hns_roce_alloc_icm(hr_dev,
+				  HNS_ROCE_TABLE_CHUNK_SIZE >> PAGE_SHIFT,
+				  (table->lowmem ? GFP_KERNEL :
+						   GFP_HIGHUSER) | __GFP_NOWARN,
+				  table->coherent);
+	if (!table->icm[i]) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	/* Inform icm entry mem pa(128K/page, pa starting address)for hw */
+	if (hns_roce_map_icm(hr_dev, table, obj)) {
+		ret = -ENODEV;
+		dev_err(dev, "map icm table failed.\n");
+		goto out;
+	}
+
+	++table->icm[i]->refcount;
+out:
+	mutex_unlock(&table->mutex);
+	return ret;
+}
+
+void hns_roce_table_put(struct hns_roce_dev *hr_dev,
+			struct hns_roce_icm_table *table, unsigned long obj)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	unsigned long i;
+
+	i = (obj & (table->num_obj - 1)) /
+	    (HNS_ROCE_TABLE_CHUNK_SIZE / table->obj_size);
+
+	mutex_lock(&table->mutex);
+
+	if (--table->icm[i]->refcount == 0) {
+		/* Clear base address table */
+		if (hns_roce_unmap_icm(hr_dev, table, obj))
+			dev_warn(dev, "unmap icm table failed.\n");
+
+		hns_roce_free_icm(hr_dev, table->icm[i], table->coherent);
+		table->icm[i] = NULL;
+	}
+
+	mutex_unlock(&table->mutex);
+}
+
+int hns_roce_table_get_range(struct hns_roce_dev *hr_dev,
+			     struct hns_roce_icm_table *table,
+			     unsigned long start, unsigned long end)
+{
+	unsigned long inc = HNS_ROCE_TABLE_CHUNK_SIZE / table->obj_size;
+	unsigned long i = 0;
+	int ret = 0;
+
+	/* Allocate MTT entry memory according to chunk(128K) */
+	for (i = start; i <= end; i += inc) {
+		ret = hns_roce_table_get(hr_dev, table, i);
+		if (ret)
+			goto fail;
+	}
+
+	return 0;
+
+fail:
+	while (i > start) {
+		i -= inc;
+		hns_roce_table_put(hr_dev, table, i);
+	}
+	return ret;
+}
+
 int hns_roce_init_icm_table(struct hns_roce_dev *hr_dev,
 			    struct hns_roce_icm_table *table, u32 type,
 			    unsigned long obj_size, unsigned long nobj,
diff --git a/drivers/infiniband/hw/hns/hns_roce_icm.h b/drivers/infiniband/hw/hns/hns_roce_icm.h
index 719b64e..3432608 100644
--- a/drivers/infiniband/hw/hns/hns_roce_icm.h
+++ b/drivers/infiniband/hw/hns/hns_roce_icm.h
@@ -74,6 +74,13 @@ struct hns_roce_icm_iter {
 
 void hns_roce_free_icm(struct hns_roce_dev *hr_dev,
 		       struct hns_roce_icm *icm, int coherent);
+int hns_roce_table_get(struct hns_roce_dev *hr_dev,
+		       struct hns_roce_icm_table *table, unsigned long obj);
+void hns_roce_table_put(struct hns_roce_dev *hr_dev,
+			struct hns_roce_icm_table *table, unsigned long obj);
+int hns_roce_table_get_range(struct hns_roce_dev *hr_dev,
+			     struct hns_roce_icm_table *table,
+			     unsigned long start, unsigned long end);
 int hns_roce_init_icm_table(struct hns_roce_dev *hr_dev,
 			    struct hns_roce_icm_table *table, u32 type,
 			    unsigned long obj_size, unsigned long nobj,
diff --git a/drivers/infiniband/hw/hns/hns_roce_main.c b/drivers/infiniband/hw/hns/hns_roce_main.c
index 2158a26..d4dc38c 100644
--- a/drivers/infiniband/hw/hns/hns_roce_main.c
+++ b/drivers/infiniband/hw/hns/hns_roce_main.c
@@ -201,6 +201,75 @@ err_unmap_mtt:
 }
 
 /**
+* hns_roce_setup_hca - setup host channel adapter
+* @hr_dev: pointer to hns roce device
+* Return : int
+*/
+int hns_roce_setup_hca(struct hns_roce_dev *hr_dev)
+{
+	int ret;
+	struct device *dev = &hr_dev->pdev->dev;
+
+	spin_lock_init(&hr_dev->sm_lock);
+	spin_lock_init(&hr_dev->cq_db_lock);
+	spin_lock_init(&hr_dev->bt_cmd_lock);
+
+	ret = hns_roce_init_uar_table(hr_dev);
+	if (ret) {
+		dev_err(dev, "Failed to initialize uar table. aborting\n");
+		return ret;
+	}
+
+	ret = hns_roce_uar_alloc(hr_dev, &hr_dev->priv_uar);
+	if (ret) {
+		dev_err(dev, "Failed to allocate priv_uar.\n");
+		goto err_uar_table_free;
+	}
+
+	ret = hns_roce_init_pd_table(hr_dev);
+	if (ret) {
+		dev_err(dev, "Failed to init protected domain table.\n");
+		goto err_uar_alloc_free;
+	}
+
+	ret = hns_roce_init_mr_table(hr_dev);
+	if (ret) {
+		dev_err(dev, "Failed to init memory region table.\n");
+		goto err_pd_table_free;
+	}
+
+	ret = hns_roce_init_cq_table(hr_dev);
+	if (ret) {
+		dev_err(dev, "Failed to init completion queue table.\n");
+		goto err_mr_table_free;
+	}
+
+	ret = hns_roce_init_qp_table(hr_dev);
+	if (ret) {
+		dev_err(dev, "Failed to init queue pair table.\n");
+		goto err_cq_table_free;
+	}
+
+	return 0;
+
+err_cq_table_free:
+	hns_roce_cleanup_cq_table(hr_dev);
+
+err_mr_table_free:
+	hns_roce_cleanup_mr_table(hr_dev);
+
+err_pd_table_free:
+	hns_roce_cleanup_pd_table(hr_dev);
+
+err_uar_alloc_free:
+	hns_roce_uar_free(hr_dev, &hr_dev->priv_uar);
+
+err_uar_table_free:
+	hns_roce_cleanup_uar_table(hr_dev);
+	return ret;
+}
+
+/**
 * hns_roce_probe - RoCE driver entrance
 * @pdev: pointer to platform device
 * Return : int
@@ -272,6 +341,15 @@ static int hns_roce_probe(struct platform_device *pdev)
 		goto error_failed_init_icm;
 	}
 
+	ret = hns_roce_setup_hca(hr_dev);
+	if (ret) {
+		dev_err(dev, "setup hca fail!\n");
+		goto error_failed_setup_hca;
+	}
+
+error_failed_setup_hca:
+	hns_roce_cleanup_icm(hr_dev);
+
 error_failed_init_icm:
 	if (hr_dev->cmd_mod)
 		hns_roce_cmd_use_polling(hr_dev);
@@ -301,6 +379,7 @@ static int hns_roce_remove(struct platform_device *pdev)
 {
 	struct hns_roce_dev *hr_dev = platform_get_drvdata(pdev);
 
+	hns_roce_cleanup_bitmap(hr_dev);
 	hns_roce_cleanup_icm(hr_dev);
 
 	if (hr_dev->cmd_mod)
diff --git a/drivers/infiniband/hw/hns/hns_roce_mr.c b/drivers/infiniband/hw/hns/hns_roce_mr.c
new file mode 100644
index 0000000..4ce4a6b
--- /dev/null
+++ b/drivers/infiniband/hw/hns/hns_roce_mr.c
@@ -0,0 +1,210 @@
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
+#include <linux/init.h>
+#include <linux/errno.h>
+#include <linux/slab.h>
+#include <linux/platform_device.h>
+#include "hns_roce_device.h"
+
+static int hns_roce_buddy_alloc(struct hns_roce_buddy *buddy, int order,
+				unsigned long *seg)
+{
+	int o;
+	u32 m;
+
+	spin_lock(&buddy->lock);
+
+	for (o = order; o <= buddy->max_order; ++o) {
+		if (buddy->num_free[o]) {
+			m = 1 << (buddy->max_order - o);
+			*seg = find_first_bit(buddy->bits[o], m);
+			if (*seg < m)
+				goto found;
+		}
+	}
+	spin_unlock(&buddy->lock);
+	return -1;
+
+ found:
+	clear_bit(*seg, buddy->bits[o]);
+	--buddy->num_free[o];
+
+	while (o > order) {
+		--o;
+		*seg <<= 1;
+		set_bit(*seg ^ 1, buddy->bits[o]);
+		++buddy->num_free[o];
+	}
+
+	spin_unlock(&buddy->lock);
+
+	*seg <<= order;
+	return 0;
+}
+
+static void hns_roce_buddy_free(struct hns_roce_buddy *buddy, unsigned long seg,
+				int order)
+{
+	seg >>= order;
+
+	spin_lock(&buddy->lock);
+
+	while (test_bit(seg ^ 1, buddy->bits[order])) {
+		clear_bit(seg ^ 1, buddy->bits[order]);
+		--buddy->num_free[order];
+		seg >>= 1;
+		++order;
+	}
+
+	set_bit(seg, buddy->bits[order]);
+	++buddy->num_free[order];
+
+	spin_unlock(&buddy->lock);
+}
+
+static int hns_roce_buddy_init(struct hns_roce_buddy *buddy, int max_order)
+{
+	int i, s;
+
+	buddy->max_order = max_order;
+	spin_lock_init(&buddy->lock);
+
+	buddy->bits = kzalloc((buddy->max_order + 1) * sizeof(long *),
+			       GFP_KERNEL);
+	buddy->num_free = kzalloc((buddy->max_order + 1) * sizeof(int *),
+				   GFP_KERNEL);
+	if (!buddy->bits || !buddy->num_free)
+		goto err_out;
+
+	for (i = 0; i <= buddy->max_order; ++i) {
+		s = BITS_TO_LONGS(1 << (buddy->max_order - i));
+		buddy->bits[i] = kmalloc_array(s, sizeof(long), GFP_KERNEL);
+		if (!buddy->bits[i])
+			goto err_out_free;
+
+		bitmap_zero(buddy->bits[i], 1 << (buddy->max_order - i));
+	}
+
+	set_bit(0, buddy->bits[buddy->max_order]);
+	buddy->num_free[buddy->max_order] = 1;
+
+	return 0;
+
+err_out_free:
+	for (i = 0; i <= buddy->max_order; ++i)
+		kfree(buddy->bits[i]);
+
+err_out:
+	kfree(buddy->bits);
+	kfree(buddy->num_free);
+	return -ENOMEM;
+}
+
+static void hns_roce_buddy_cleanup(struct hns_roce_buddy *buddy)
+{
+	int i;
+
+	for (i = 0; i <= buddy->max_order; ++i)
+		kfree(buddy->bits[i]);
+
+	kfree(buddy->bits);
+	kfree(buddy->num_free);
+}
+
+static int hns_roce_alloc_mtt_range(struct hns_roce_dev *hr_dev, int order,
+				    unsigned long *seg)
+{
+	struct hns_roce_mr_table *mr_table = &hr_dev->mr_table;
+	int ret = 0;
+
+	ret = hns_roce_buddy_alloc(&mr_table->mtt_buddy, order, seg);
+	if (ret == -1)
+		return -1;
+
+	if (hns_roce_table_get_range(hr_dev, &mr_table->mtt_table, *seg,
+				     *seg + (1 << order) - 1)) {
+		hns_roce_buddy_free(&mr_table->mtt_buddy, *seg, order);
+		return -1;
+	}
+
+	return 0;
+}
+
+int hns_roce_init_mr_table(struct hns_roce_dev *hr_dev)
+{
+	struct hns_roce_mr_table *mr_table = &hr_dev->mr_table;
+	struct device *dev = &hr_dev->pdev->dev;
+	unsigned long first_seg;
+	int ret = 0;
+
+	ret = hns_roce_bitmap_init(&mr_table->mtpt_bitmap,
+				   hr_dev->caps.num_mtpts,
+				   hr_dev->caps.num_mtpts - 1,
+				   hr_dev->caps.reserved_mrws, 0);
+	if (ret)
+		return ret;
+
+	ret = hns_roce_buddy_init(&mr_table->mtt_buddy,
+				  ilog2(hr_dev->caps.num_mtt_segs));
+	if (ret)
+		goto err_buddy;
+
+	if (hr_dev->caps.reserved_mtts) {
+		if (hns_roce_alloc_mtt_range(hr_dev,
+			fls(hr_dev->caps.reserved_mtts - 1),
+			&first_seg) == -1) {
+			dev_err(dev, "MTT table of order %d is too small.\n",
+				mr_table->mtt_buddy.max_order);
+			ret = -ENOMEM;
+			goto err_reserve_mtts;
+		}
+	}
+
+	return 0;
+
+err_reserve_mtts:
+	hns_roce_buddy_cleanup(&mr_table->mtt_buddy);
+
+err_buddy:
+	hns_roce_bitmap_cleanup(&mr_table->mtpt_bitmap);
+	return ret;
+}
+
+void hns_roce_cleanup_mr_table(struct hns_roce_dev *hr_dev)
+{
+	struct hns_roce_mr_table *mr_table = &hr_dev->mr_table;
+
+	hns_roce_buddy_cleanup(&mr_table->mtt_buddy);
+	hns_roce_bitmap_cleanup(&mr_table->mtpt_bitmap);
+}
diff --git a/drivers/infiniband/hw/hns/hns_roce_pd.c b/drivers/infiniband/hw/hns/hns_roce_pd.c
new file mode 100644
index 0000000..6ad38f2
--- /dev/null
+++ b/drivers/infiniband/hw/hns/hns_roce_pd.c
@@ -0,0 +1,88 @@
+/*
+ * Copyright (c) 2016 Hisilicon Limited.
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
+#include <asm/page.h>
+#include <linux/init.h>
+#include <linux/platform_device.h>
+#include <linux/slab.h>
+#include <rdma/ib_smi.h>
+#include <rdma/ib_umem.h>
+#include <rdma/ib_user_verbs.h>
+#include "hns_roce_common.h"
+#include "hns_roce_device.h"
+
+int hns_roce_init_pd_table(struct hns_roce_dev *hr_dev)
+{
+	return hns_roce_bitmap_init(&hr_dev->pd_bitmap, hr_dev->caps.num_pds,
+				    hr_dev->caps.num_pds - 1,
+				    hr_dev->caps.reserved_pds, 0);
+}
+
+void hns_roce_cleanup_pd_table(struct hns_roce_dev *hr_dev)
+{
+	hns_roce_bitmap_cleanup(&hr_dev->pd_bitmap);
+}
+
+int hns_roce_uar_alloc(struct hns_roce_dev *hr_dev, struct hns_roce_uar *uar)
+{
+	struct resource *res;
+	int ret = 0;
+	/* Using bitmap to manager UAR index */
+	ret = hns_roce_bitmap_alloc(&hr_dev->uar_table.bitmap, &uar->index);
+	if (ret == -1)
+		return -ENOMEM;
+
+	uar->index = (uar->index - 1) % hr_dev->caps.phy_num_uars + 1;
+
+	res = platform_get_resource(hr_dev->pdev, IORESOURCE_MEM, 0);
+	uar->pfn = ((res->start) >> PAGE_SHIFT) + uar->index;
+
+	return 0;
+}
+
+void hns_roce_uar_free(struct hns_roce_dev *hr_dev, struct hns_roce_uar *uar)
+{
+	hns_roce_bitmap_free(&hr_dev->uar_table.bitmap, uar->index);
+}
+
+int hns_roce_init_uar_table(struct hns_roce_dev *hr_dev)
+{
+	return hns_roce_bitmap_init(&hr_dev->uar_table.bitmap,
+				    hr_dev->caps.num_uars,
+				    hr_dev->caps.num_uars - 1,
+				    hr_dev->caps.reserved_uars, 0);
+}
+
+void hns_roce_cleanup_uar_table(struct hns_roce_dev *hr_dev)
+{
+	hns_roce_bitmap_cleanup(&hr_dev->uar_table.bitmap);
+}
diff --git a/drivers/infiniband/hw/hns/hns_roce_qp.c b/drivers/infiniband/hw/hns/hns_roce_qp.c
index a826c11..273849a 100644
--- a/drivers/infiniband/hw/hns/hns_roce_qp.c
+++ b/drivers/infiniband/hw/hns/hns_roce_qp.c
@@ -37,6 +37,8 @@
 #include <rdma/ib_pack.h>
 #include "hns_roce_device.h"
 
+#define SQP_NUM				12
+
 void hns_roce_qp_event(struct hns_roce_dev *hr_dev, u32 qpn, int event_type)
 {
 	struct hns_roce_qp_table *qp_table = &hr_dev->qp_table;
@@ -61,3 +63,31 @@ void hns_roce_qp_event(struct hns_roce_dev *hr_dev, u32 qpn, int event_type)
 	if (atomic_dec_and_test(&qp->refcount))
 		complete(&qp->free);
 }
+
+int hns_roce_init_qp_table(struct hns_roce_dev *hr_dev)
+{
+	struct hns_roce_qp_table *qp_table = &hr_dev->qp_table;
+	int reserved_from_top = 0;
+	int ret;
+
+	spin_lock_init(&qp_table->lock);
+	INIT_RADIX_TREE(&hr_dev->qp_table_tree, GFP_ATOMIC);
+
+	/* A port include two SQP, six port total 12 */
+	ret = hns_roce_bitmap_init(&qp_table->bitmap, hr_dev->caps.num_qps,
+				   hr_dev->caps.num_qps - 1,
+				   hr_dev->caps.sqp_start + SQP_NUM,
+				   reserved_from_top);
+	if (ret) {
+		dev_err(&hr_dev->pdev->dev, "qp bitmap init failed!error=%d\n",
+			ret);
+		return ret;
+	}
+
+	return 0;
+}
+
+void hns_roce_cleanup_qp_table(struct hns_roce_dev *hr_dev)
+{
+	hns_roce_bitmap_cleanup(&hr_dev->qp_table.bitmap);
+}
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
