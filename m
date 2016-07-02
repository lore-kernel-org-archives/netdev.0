From: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v11 15/22] IB/hns: Add PD operations support
Date: Sat, 2 Jul 2016 17:39:17 +0800
Message-ID: <1467452364-66522-16-git-send-email-oulijun@huawei.com>
References: <1467452364-66522-1-git-send-email-oulijun@huawei.com>
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
In-Reply-To: <1467452364-66522-1-git-send-email-oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch added the verbs to operate PD. It mainly includes
the functions of allocating PD and deallocating PD.

Signed-off-by: Wei Hu <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Nenglong Zhao <zhaonenglong-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Signed-off-by: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
PATCH v11/v10/v9/v8/v7/v6:
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
index f9288ff..2e8dad1 100644
--- a/drivers/infiniband/hw/hns/hns_roce_device.h
+++ b/drivers/infiniband/hw/hns/hns_roce_device.h
@@ -126,6 +126,11 @@ struct hns_roce_ucontext {
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
@@ -387,6 +392,11 @@ static inline struct hns_roce_ucontext
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
@@ -434,6 +444,11 @@ int hns_roce_bitmap_alloc_range(struct hns_roce_bitmap *bitmap, int cnt,
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
index 5dfab0b..8d85cda 100644
--- a/drivers/infiniband/hw/hns/hns_roce_main.c
+++ b/drivers/infiniband/hw/hns/hns_roce_main.c
@@ -580,7 +580,9 @@ static int hns_roce_register_device(struct hns_roce_dev *hr_dev)
 	ib_dev->uverbs_cmd_mask		=
 		(1ULL << IB_USER_VERBS_CMD_GET_CONTEXT) |
 		(1ULL << IB_USER_VERBS_CMD_QUERY_DEVICE) |
-		(1ULL << IB_USER_VERBS_CMD_QUERY_PORT);
+		(1ULL << IB_USER_VERBS_CMD_QUERY_PORT) |
+		(1ULL << IB_USER_VERBS_CMD_ALLOC_PD) |
+		(1ULL << IB_USER_VERBS_CMD_DEALLOC_PD);
 
 	/* HCA||device||port */
 	ib_dev->modify_device		= hns_roce_modify_device;
@@ -594,6 +596,10 @@ static int hns_roce_register_device(struct hns_roce_dev *hr_dev)
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
index 6b55aea..16271b5 100644
--- a/drivers/infiniband/hw/hns/hns_roce_pd.c
+++ b/drivers/infiniband/hw/hns/hns_roce_pd.c
@@ -33,6 +33,28 @@
 #include <linux/platform_device.h>
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
@@ -45,6 +67,46 @@ void hns_roce_cleanup_pd_table(struct hns_roce_dev *hr_dev)
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

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
