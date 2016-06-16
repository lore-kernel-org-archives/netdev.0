From: Lijun Ou <oulijun@huawei.com>
Subject: [PATCH v10 15/22] IB/hns: Add PD operations support
Date: Thu, 16 Jun 2016 22:35:23 +0800
Message-ID: <1466087730-54856-16-git-send-email-oulijun@huawei.com>
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

This patch added the verbs to operate PD. It mainly includes
the functions of allocating PD and deallocating PD.

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
 drivers/infiniband/hw/hns/hns_roce_device.h | 15 +++++++
 drivers/infiniband/hw/hns/hns_roce_main.c   |  8 +++-
 drivers/infiniband/hw/hns/hns_roce_pd.c     | 62 +++++++++++++++++++++++++++++
 3 files changed, 84 insertions(+), 1 deletion(-)

diff --git a/drivers/infiniband/hw/hns/hns_roce_device.h b/drivers/infiniband/hw/hns/hns_roce_device.h
index 0ce0729..4be4c46 100644
--- a/drivers/infiniband/hw/hns/hns_roce_device.h
+++ b/drivers/infiniband/hw/hns/hns_roce_device.h
@@ -134,6 +134,11 @@ struct hns_roce_ucontext {
 	struct hns_roce_uar	uar;
 };
 
+struct hns_roce_pd {
+	struct ib_pd		ibpd;
+	unsigned long		pdn;
+};
+
 struct hns_roce_bitmap {
 	/* Bitmap Traversal last a bit which is 1 */
 	unsigned long		last;
@@ -399,6 +404,11 @@ static inline struct hns_roce_ucontext
 	return container_of(ibucontext, struct hns_roce_ucontext, ibucontext);
 }
 
+static inline struct hns_roce_pd *to_hr_pd(struct ib_pd *ibpd)
+{
+	return container_of(ibpd, struct hns_roce_pd, ibpd);
+}
+
 static inline void hns_roce_write64_k(__be32 val[2], void __iomem *dest)
 {
 	__raw_writeq(*(u64 *) val, dest);
@@ -446,6 +456,11 @@ int hns_roce_bitmap_alloc_range(struct hns_roce_bitmap *bitmap, int cnt,
 void hns_roce_bitmap_free_range(struct hns_roce_bitmap *bitmap,
 				unsigned long obj, int cnt);
 
+struct ib_pd *hns_roce_alloc_pd(struct ib_device *ib_dev,
+				struct ib_ucontext *context,
+				struct ib_udata *udata);
+int hns_roce_dealloc_pd(struct ib_pd *pd);
+
 void hns_roce_cq_completion(struct hns_roce_dev *hr_dev, u32 cqn);
 void hns_roce_cq_event(struct hns_roce_dev *hr_dev, u32 cqn, int event_type);
 void hns_roce_qp_event(struct hns_roce_dev *hr_dev, u32 qpn, int event_type);
diff --git a/drivers/infiniband/hw/hns/hns_roce_main.c b/drivers/infiniband/hw/hns/hns_roce_main.c
index 5290f9e..12ea00c 100644
--- a/drivers/infiniband/hw/hns/hns_roce_main.c
+++ b/drivers/infiniband/hw/hns/hns_roce_main.c
@@ -603,7 +603,9 @@ static int hns_roce_register_device(struct hns_roce_dev *hr_dev)
 	ib_dev->uverbs_cmd_mask		=
 		(1ULL << IB_USER_VERBS_CMD_GET_CONTEXT) |
 		(1ULL << IB_USER_VERBS_CMD_QUERY_DEVICE) |
-		(1ULL << IB_USER_VERBS_CMD_QUERY_PORT);
+		(1ULL << IB_USER_VERBS_CMD_QUERY_PORT) |
+		(1ULL << IB_USER_VERBS_CMD_ALLOC_PD) |
+		(1ULL << IB_USER_VERBS_CMD_DEALLOC_PD);
 
 	/* HCA||device||port */
 	ib_dev->modify_device		= hns_roce_modify_device;
@@ -617,6 +619,10 @@ static int hns_roce_register_device(struct hns_roce_dev *hr_dev)
 	ib_dev->dealloc_ucontext	= hns_roce_dealloc_ucontext;
 	ib_dev->mmap			= hns_roce_mmap;
 
+	/* PD */
+	ib_dev->alloc_pd		= hns_roce_alloc_pd;
+	ib_dev->dealloc_pd		= hns_roce_dealloc_pd;
+
 	ret = ib_register_device(ib_dev, NULL);
 	if (ret) {
 		dev_err(dev, "ib_register_device failed!\n");
diff --git a/drivers/infiniband/hw/hns/hns_roce_pd.c b/drivers/infiniband/hw/hns/hns_roce_pd.c
index 6ad38f2..ce15265 100644
--- a/drivers/infiniband/hw/hns/hns_roce_pd.c
+++ b/drivers/infiniband/hw/hns/hns_roce_pd.c
@@ -40,6 +40,28 @@
 #include "hns_roce_common.h"
 #include "hns_roce_device.h"
 
+static int hns_roce_pd_alloc(struct hns_roce_dev *hr_dev, unsigned long *pdn)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	unsigned long pd_number;
+	int ret = 0;
+
+	ret = hns_roce_bitmap_alloc(&hr_dev->pd_bitmap, &pd_number);
+	if (ret == -1) {
+		dev_err(dev, "alloc pdn from pdbitmap failed\n");
+		return -ENOMEM;
+	}
+
+	*pdn = pd_number;
+
+	return 0;
+}
+
+static void hns_roce_pd_free(struct hns_roce_dev *hr_dev, unsigned long pdn)
+{
+	hns_roce_bitmap_free(&hr_dev->pd_bitmap, pdn);
+}
+
 int hns_roce_init_pd_table(struct hns_roce_dev *hr_dev)
 {
 	return hns_roce_bitmap_init(&hr_dev->pd_bitmap, hr_dev->caps.num_pds,
@@ -52,6 +74,46 @@ void hns_roce_cleanup_pd_table(struct hns_roce_dev *hr_dev)
 	hns_roce_bitmap_cleanup(&hr_dev->pd_bitmap);
 }
 
+struct ib_pd *hns_roce_alloc_pd(struct ib_device *ib_dev,
+				struct ib_ucontext *context,
+				struct ib_udata *udata)
+{
+	struct hns_roce_dev *hr_dev = to_hr_dev(ib_dev);
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_pd *pd;
+	int ret;
+
+	pd = kmalloc(sizeof(*pd), GFP_KERNEL);
+	if (!pd)
+		return ERR_PTR(-ENOMEM);
+
+	ret = hns_roce_pd_alloc(to_hr_dev(ib_dev), &pd->pdn);
+	if (ret) {
+		kfree(pd);
+		dev_err(dev, "[alloc_pd]hns_roce_pd_alloc failed!\n");
+		return ERR_PTR(ret);
+	}
+
+	if (context) {
+		if (ib_copy_to_udata(udata, &pd->pdn, sizeof(u64))) {
+			hns_roce_pd_free(to_hr_dev(ib_dev), pd->pdn);
+			dev_err(dev, "[alloc_pd]ib_copy_to_udata failed!\n");
+			kfree(pd);
+			return ERR_PTR(-EFAULT);
+		}
+	}
+
+	return &pd->ibpd;
+}
+
+int hns_roce_dealloc_pd(struct ib_pd *pd)
+{
+	hns_roce_pd_free(to_hr_dev(pd->device), to_hr_pd(pd)->pdn);
+	kfree(to_hr_pd(pd));
+
+	return 0;
+}
+
 int hns_roce_uar_alloc(struct hns_roce_dev *hr_dev, struct hns_roce_uar *uar)
 {
 	struct resource *res;
-- 
1.9.1
