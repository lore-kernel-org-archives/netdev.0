From: Lijun Ou <oulijun@huawei.com>
Subject: [PATCH v11 09/22] IB/hns: Add hca support
Date: Sat, 2 Jul 2016 17:39:11 +0800
Message-ID: <1467452364-66522-10-git-send-email-oulijun@huawei.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:44786 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751212AbcGBJZL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2016 05:25:11 -0400
In-Reply-To: <1467452364-66522-1-git-send-email-oulijun@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch mainly setup hca for RoCE. It will do a series of
initial works, as follows:
    1. init uar table, allocate uar resource
    2. init pd table
    3. init cq table
    4. init mr table
    5. init qp table

Signed-off-by: Wei Hu <xavier.huwei@huawei.com>
Signed-off-by: Nenglong Zhao <zhaonenglong@hisilicon.com>
Signed-off-by: Lijun Ou <oulijun@huawei.com>
---
PATCH v11:
This fixes the comments given by Leon Rmanovsky over the PATCH v10:
  Link: https://lkml.org/lkml/2016/6/24/450

Remove the non-essential headers according to the Leon Romanovsky's
the same comments over the [PATCH v10 3/22]:
  Link: https://lkml.org/lkml/2016/6/24/276

PATCH v10:
This fixes the comments given by Leon Romanovsky over the PATCH v9:
  Link: https://lkml.org/lkml/2016/6/9/67

PATCH v9/v8/v7/v6:
  - No change over the PATCH v5

PATCH v5:
- The initial patch which was redesigned based on the second patch
  in PATCH v4
---
---
 drivers/infiniband/hw/hns/hns_roce_alloc.c  | 123 ++++++++++++++++++
 drivers/infiniband/hw/hns/hns_roce_cq.c     |  17 +++
 drivers/infiniband/hw/hns/hns_roce_device.h |  69 ++++++++++
 drivers/infiniband/hw/hns/hns_roce_hem.c    |  87 +++++++++++++
 drivers/infiniband/hw/hns/hns_roce_hem.h    |   7 +
 drivers/infiniband/hw/hns/hns_roce_main.c   |  79 ++++++++++++
 drivers/infiniband/hw/hns/hns_roce_mr.c     | 192 ++++++++++++++++++++++++++++
 drivers/infiniband/hw/hns/hns_roce_pd.c     |  82 ++++++++++++
 drivers/infiniband/hw/hns/hns_roce_qp.c     |  30 +++++
 9 files changed, 686 insertions(+)
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_alloc.c
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_mr.c
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_pd.c

diff --git a/drivers/infiniband/hw/hns/hns_roce_alloc.c b/drivers/infiniband/hw/hns/hns_roce_alloc.c
new file mode 100644
index 0000000..b243d89
--- /dev/null
+++ b/drivers/infiniband/hw/hns/hns_roce_alloc.c
@@ -0,0 +1,123 @@
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
index a3b0e87..89e91e6 100644
--- a/drivers/infiniband/hw/hns/hns_roce_cq.c
+++ b/drivers/infiniband/hw/hns/hns_roce_cq.c
@@ -70,3 +70,20 @@ void hns_roce_cq_event(struct hns_roce_dev *hr_dev, u32 cqn, int event_type)
 	if (atomic_dec_and_test(&cq->refcount))
 		complete(&cq->free);
 }
+
+int hns_roce_init_cq_table(struct hns_roce_dev *hr_dev)
+{
+	struct hns_roce_cq_table *cq_table = &hr_dev->cq_table;
+
+	spin_lock_init(&cq_table->lock);
+	INIT_RADIX_TREE(&cq_table->tree, GFP_ATOMIC);
+
+	return hns_roce_bitmap_init(&cq_table->bitmap, hr_dev->caps.num_cqs,
+				    hr_dev->caps.num_cqs - 1,
+				    hr_dev->caps.reserved_cqs, 0);
+}
+
+void hns_roce_cleanup_cq_table(struct hns_roce_dev *hr_dev)
+{
+	hns_roce_bitmap_cleanup(&hr_dev->cq_table.bitmap);
+}
diff --git a/drivers/infiniband/hw/hns/hns_roce_device.h b/drivers/infiniband/hw/hns/hns_roce_device.h
index 8ceff5d..dc5bbc9 100644
--- a/drivers/infiniband/hw/hns/hns_roce_device.h
+++ b/drivers/infiniband/hw/hns/hns_roce_device.h
@@ -103,6 +103,38 @@ enum {
 
 #define HNS_ROCE_CMD_SUCCESS			1
 
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
 /* For Hardware Entry Memory */
 struct hns_roce_hem_table {
 	/* HEM type: 0 = qpc, 1 = mtt, 2 = cqc, 3 = srq, 4 = other */
@@ -119,6 +151,8 @@ struct hns_roce_hem_table {
 };
 
 struct hns_roce_mr_table {
+	struct hns_roce_bitmap		mtpt_bitmap;
+	struct hns_roce_buddy		mtt_buddy;
 	struct hns_roce_hem_table	mtt_table;
 	struct hns_roce_hem_table	mtpt_table;
 };
@@ -136,13 +170,19 @@ struct hns_roce_cq {
 	struct completion		free;
 };
 
+struct hns_roce_uar_table {
+	struct hns_roce_bitmap bitmap;
+};
+
 struct hns_roce_qp_table {
+	struct hns_roce_bitmap		bitmap;
 	spinlock_t			lock;
 	struct hns_roce_hem_table	qp_table;
 	struct hns_roce_hem_table	irrl_table;
 };
 
 struct hns_roce_cq_table {
+	struct hns_roce_bitmap		bitmap;
 	spinlock_t			lock;
 	struct radix_tree_root		tree;
 	struct hns_roce_hem_table	table;
@@ -270,7 +310,10 @@ struct hns_roce_hw {
 struct hns_roce_dev {
 	struct ib_device	ib_dev;
 	struct platform_device  *pdev;
+	struct hns_roce_uar     priv_uar;
 	const char		*irq_names;
+	spinlock_t		sm_lock;
+	spinlock_t		cq_db_lock;
 	spinlock_t		bt_cmd_lock;
 	struct hns_roce_ib_iboe iboe;
 
@@ -285,6 +328,8 @@ struct hns_roce_dev {
 	u32                     hw_rev;
 
 	struct hns_roce_cmdq	cmd;
+	struct hns_roce_bitmap    pd_bitmap;
+	struct hns_roce_uar_table uar_table;
 	struct hns_roce_mr_table  mr_table;
 	struct hns_roce_cq_table  cq_table;
 	struct hns_roce_qp_table  qp_table;
@@ -307,6 +352,11 @@ static inline struct hns_roce_qp
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
@@ -314,9 +364,28 @@ void hns_roce_cmd_event(struct hns_roce_dev *hr_dev, u16 token, u8 status,
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
diff --git a/drivers/infiniband/hw/hns/hns_roce_hem.c b/drivers/infiniband/hw/hns/hns_roce_hem.c
index e2e285d..a2eeb47 100644
--- a/drivers/infiniband/hw/hns/hns_roce_hem.c
+++ b/drivers/infiniband/hw/hns/hns_roce_hem.c
@@ -281,6 +281,93 @@ static int hns_roce_clear_hem(struct hns_roce_dev *hr_dev,
 	return ret;
 }
 
+int hns_roce_table_get(struct hns_roce_dev *hr_dev,
+		       struct hns_roce_hem_table *table, unsigned long obj)
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
+	if (table->hem[i]) {
+		++table->hem[i]->refcount;
+		goto out;
+	}
+
+	table->hem[i] = hns_roce_alloc_hem(hr_dev,
+				       HNS_ROCE_TABLE_CHUNK_SIZE >> PAGE_SHIFT,
+				       (table->lowmem ? GFP_KERNEL :
+					GFP_HIGHUSER) | __GFP_NOWARN);
+	if (!table->hem[i]) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	/* Set HEM base address(128K/page, pa) to Hardware */
+	if (hns_roce_set_hem(hr_dev, table, obj)) {
+		ret = -ENODEV;
+		dev_err(dev, "set HEM base address to HW failed.\n");
+		goto out;
+	}
+
+	++table->hem[i]->refcount;
+out:
+	mutex_unlock(&table->mutex);
+	return ret;
+}
+
+void hns_roce_table_put(struct hns_roce_dev *hr_dev,
+			struct hns_roce_hem_table *table, unsigned long obj)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	unsigned long i;
+
+	i = (obj & (table->num_obj - 1)) /
+	    (HNS_ROCE_TABLE_CHUNK_SIZE / table->obj_size);
+
+	mutex_lock(&table->mutex);
+
+	if (--table->hem[i]->refcount == 0) {
+		/* Clear HEM base address */
+		if (hns_roce_clear_hem(hr_dev, table, obj))
+			dev_warn(dev, "Clear HEM base address failed.\n");
+
+		hns_roce_free_hem(hr_dev, table->hem[i]);
+		table->hem[i] = NULL;
+	}
+
+	mutex_unlock(&table->mutex);
+}
+
+int hns_roce_table_get_range(struct hns_roce_dev *hr_dev,
+			     struct hns_roce_hem_table *table,
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
 int hns_roce_init_hem_table(struct hns_roce_dev *hr_dev,
 			    struct hns_roce_hem_table *table, u32 type,
 			    unsigned long obj_size, unsigned long nobj,
diff --git a/drivers/infiniband/hw/hns/hns_roce_hem.h b/drivers/infiniband/hw/hns/hns_roce_hem.h
index 11b79c3..ef7d394 100644
--- a/drivers/infiniband/hw/hns/hns_roce_hem.h
+++ b/drivers/infiniband/hw/hns/hns_roce_hem.h
@@ -69,6 +69,13 @@ struct hns_roce_hem_iter {
 };
 
 void hns_roce_free_hem(struct hns_roce_dev *hr_dev, struct hns_roce_hem *hem);
+int hns_roce_table_get(struct hns_roce_dev *hr_dev,
+		       struct hns_roce_hem_table *table, unsigned long obj);
+void hns_roce_table_put(struct hns_roce_dev *hr_dev,
+			struct hns_roce_hem_table *table, unsigned long obj);
+int hns_roce_table_get_range(struct hns_roce_dev *hr_dev,
+			     struct hns_roce_hem_table *table,
+			     unsigned long start, unsigned long end);
 int hns_roce_init_hem_table(struct hns_roce_dev *hr_dev,
 			    struct hns_roce_hem_table *table, u32 type,
 			    unsigned long obj_size, unsigned long nobj,
diff --git a/drivers/infiniband/hw/hns/hns_roce_main.c b/drivers/infiniband/hw/hns/hns_roce_main.c
index 0872780..a0818fb 100644
--- a/drivers/infiniband/hw/hns/hns_roce_main.c
+++ b/drivers/infiniband/hw/hns/hns_roce_main.c
@@ -170,6 +170,75 @@ err_unmap_mtt:
 }
 
 /**
+* hns_roce_setup_hca - setup host channel adapter
+* @hr_dev: pointer to hns roce device
+* Return : int
+*/
+static int hns_roce_setup_hca(struct hns_roce_dev *hr_dev)
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
@@ -238,6 +307,15 @@ static int hns_roce_probe(struct platform_device *pdev)
 		goto error_failed_init_hem;
 	}
 
+	ret = hns_roce_setup_hca(hr_dev);
+	if (ret) {
+		dev_err(dev, "setup hca failed!\n");
+		goto error_failed_setup_hca;
+	}
+
+error_failed_setup_hca:
+	hns_roce_cleanup_hem(hr_dev);
+
 error_failed_init_hem:
 	if (hr_dev->cmd_mod)
 		hns_roce_cmd_use_polling(hr_dev);
@@ -267,6 +345,7 @@ static int hns_roce_remove(struct platform_device *pdev)
 {
 	struct hns_roce_dev *hr_dev = platform_get_drvdata(pdev);
 
+	hns_roce_cleanup_bitmap(hr_dev);
 	hns_roce_cleanup_hem(hr_dev);
 
 	if (hr_dev->cmd_mod)
diff --git a/drivers/infiniband/hw/hns/hns_roce_mr.c b/drivers/infiniband/hw/hns/hns_roce_mr.c
new file mode 100644
index 0000000..132548c
--- /dev/null
+++ b/drivers/infiniband/hw/hns/hns_roce_mr.c
@@ -0,0 +1,192 @@
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
+#include <rdma/ib_umem.h>
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
+	return 0;
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
index 0000000..6b55aea
--- /dev/null
+++ b/drivers/infiniband/hw/hns/hns_roce_pd.c
@@ -0,0 +1,82 @@
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
+#include <linux/platform_device.h>
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
+
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
index 1d66e80..d70729d 100644
--- a/drivers/infiniband/hw/hns/hns_roce_qp.c
+++ b/drivers/infiniband/hw/hns/hns_roce_qp.c
@@ -35,6 +35,8 @@
 #include <rdma/ib_umem.h>
 #include "hns_roce_device.h"
 
+#define SQP_NUM				12
+
 void hns_roce_qp_event(struct hns_roce_dev *hr_dev, u32 qpn, int event_type)
 {
 	struct hns_roce_qp_table *qp_table = &hr_dev->qp_table;
@@ -59,3 +61,31 @@ void hns_roce_qp_event(struct hns_roce_dev *hr_dev, u32 qpn, int event_type)
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
