From: Lijun Ou <oulijun@huawei.com>
Subject: [PATCH v5 15/21] IB/hns: Add PD operations support
Date: Sat, 23 Apr 2016 18:26:53 +0800
Message-ID: <1461407219-72027-16-git-send-email-oulijun@huawei.com>
References: <1461407219-72027-1-git-send-email-oulijun@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <gongyangming@huawei.com>,
	<xiaokun@huawei.com>, <tangchaofei@huawei.com>,
	<oulijun@huawei.com>, <haifeng.wei@huawei.com>,
	<yisen.zhuang@huawei.com>, <yankejian@huawei.com>,
	<lisheng011@huawei.com>, <charles.chenxin@huawei.com>
To: <dledford@redhat.com>, <sean.hefty@intel.com>,
	<hal.rosenstock@gmail.com>, <davem@davemloft.net>,
	<jeffrey.t.kirsher@intel.com>, <jiri@mellanox.com>,
	<ogerlitz@mellanox.com>, <linuxarm@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461407219-72027-1-git-send-email-oulijun@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch added the verbs to operate PD. It mainly includes
the functions of allocating PD and deallocating PD.

Signed-off-by: Lijun Ou <oulijun@huawei.com>
Signed-off-by: Wei Hu(Xavier) <xavier.huwei@huawei.com>
---
 drivers/infiniband/hw/hns/hns_roce_device.h | 17 ++++++++
 drivers/infiniband/hw/hns/hns_roce_main.c   |  8 +++-
 drivers/infiniband/hw/hns/hns_roce_pd.c     | 62 +++++++++++++++++++++++++++++
 3 files changed, 86 insertions(+), 1 deletion(-)

diff --git a/drivers/infiniband/hw/hns/hns_roce_device.h b/drivers/infiniband/hw/hns/hns_roce_device.h
index e871c60..68d78e9 100644
--- a/drivers/infiniband/hw/hns/hns_roce_device.h
+++ b/drivers/infiniband/hw/hns/hns_roce_device.h
@@ -116,6 +116,11 @@ struct hns_roce_ucontext {
 	struct hns_roce_uar	uar;
 };
 
+struct hns_roce_pd {
+	struct ib_pd ibpd;
+	u32          pdn;
+};
+
 struct hns_roce_bitmap {
 	/* Bitmap Traversal last a bit which is 1 */
 	u32            last;
@@ -384,6 +389,11 @@ static inline struct hns_roce_ucontext
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
@@ -431,6 +441,13 @@ int hns_roce_bitmap_alloc_range(struct hns_roce_bitmap *bitmap, int cnt,
 void hns_roce_bitmap_free_range(struct hns_roce_bitmap *bitmap, u32 obj,
 				int cnt);
 
+struct ib_pd *hns_roce_alloc_pd(struct ib_device *ib_dev,
+				struct ib_ucontext *context,
+				struct ib_udata *udata);
+int hns_roce_pd_alloc(struct hns_roce_dev *hr_dev, u32 *pdn);
+void hns_roce_pd_free(struct hns_roce_dev *hr_dev, u32 pdn);
+int hns_roce_dealloc_pd(struct ib_pd *pd);
+
 void hns_roce_cq_completion(struct hns_roce_dev *hr_dev, u32 cqn);
 void hns_roce_cq_event(struct hns_roce_dev *hr_dev, u32 cqn, int event_type);
 void hns_roce_qp_event(struct hns_roce_dev *hr_dev, u32 qpn, int event_type);
diff --git a/drivers/infiniband/hw/hns/hns_roce_main.c b/drivers/infiniband/hw/hns/hns_roce_main.c
index 9c111ec..eeae944 100644
--- a/drivers/infiniband/hw/hns/hns_roce_main.c
+++ b/drivers/infiniband/hw/hns/hns_roce_main.c
@@ -585,7 +585,9 @@ int hns_roce_register_device(struct hns_roce_dev *hr_dev)
 	ib_dev->uverbs_cmd_mask		=
 		(1ULL << IB_USER_VERBS_CMD_GET_CONTEXT) |
 		(1ULL << IB_USER_VERBS_CMD_QUERY_DEVICE) |
-		(1ULL << IB_USER_VERBS_CMD_QUERY_PORT);
+		(1ULL << IB_USER_VERBS_CMD_QUERY_PORT) |
+		(1ULL << IB_USER_VERBS_CMD_ALLOC_PD) |
+		(1ULL << IB_USER_VERBS_CMD_DEALLOC_PD);
 
 	/* HCA||device||port */
 	ib_dev->modify_device		= hns_roce_modify_device;
@@ -599,6 +601,10 @@ int hns_roce_register_device(struct hns_roce_dev *hr_dev)
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
index fb0f7c65..57739eb 100644
--- a/drivers/infiniband/hw/hns/hns_roce_pd.c
+++ b/drivers/infiniband/hw/hns/hns_roce_pd.c
@@ -17,6 +17,28 @@
 #include "hns_roce_common.h"
 #include "hns_roce_device.h"
 
+int hns_roce_pd_alloc(struct hns_roce_dev *hr_dev, u32 *pdn)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	u32 pd_number;
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
+void hns_roce_pd_free(struct hns_roce_dev *hr_dev, u32 pdn)
+{
+	hns_roce_bitmap_free(&hr_dev->pd_bitmap, pdn);
+}
+
 int hns_roce_init_pd_table(struct hns_roce_dev *hr_dev)
 {
 	return hns_roce_bitmap_init(&hr_dev->pd_bitmap, hr_dev->caps.num_pds,
@@ -29,6 +51,46 @@ void hns_roce_cleanup_pd_table(struct hns_roce_dev *hr_dev)
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
+		if (ib_copy_to_udata(udata, &pd->pdn, sizeof(__u32))) {
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
