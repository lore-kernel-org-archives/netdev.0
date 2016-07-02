From: Lijun Ou <oulijun@huawei.com>
Subject: [PATCH v11 16/22] IB/hns: Add ah operations support
Date: Sat, 2 Jul 2016 17:39:18 +0800
Message-ID: <1467452364-66522-17-git-send-email-oulijun@huawei.com>
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

This patch was for implementing of address handle operations.
It includes three verbs that create ah, query ah and destroy
ah. They is completed independently by RoCE driver.

Signed-off-by: Wei Hu <xavier.huwei@huawei.com>
Signed-off-by: Nenglong Zhao <zhaonenglong@hisilicon.com>
Signed-off-by: Lijun Ou <oulijun@huawei.com>
---
PATCH v11:
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
 drivers/infiniband/hw/hns/hns_roce_ah.c     | 128 ++++++++++++++++++++++++++++
 drivers/infiniband/hw/hns/hns_roce_device.h |  30 +++++++
 drivers/infiniband/hw/hns/hns_roce_main.c   |   5 ++
 3 files changed, 163 insertions(+)
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_ah.c

diff --git a/drivers/infiniband/hw/hns/hns_roce_ah.c b/drivers/infiniband/hw/hns/hns_roce_ah.c
new file mode 100644
index 0000000..24f79ee
--- /dev/null
+++ b/drivers/infiniband/hw/hns/hns_roce_ah.c
@@ -0,0 +1,128 @@
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
+#include <rdma/ib_addr.h>
+#include <rdma/ib_cache.h>
+#include "hns_roce_device.h"
+
+#define HNS_ROCE_PORT_NUM_SHIFT		24
+#define HNS_ROCE_VLAN_SL_BIT_MASK	7
+#define HNS_ROCE_VLAN_SL_SHIFT		13
+
+struct ib_ah *hns_roce_create_ah(struct ib_pd *ibpd, struct ib_ah_attr *ah_attr)
+{
+	struct hns_roce_dev *hr_dev = to_hr_dev(ibpd->device);
+	struct device *dev = &hr_dev->pdev->dev;
+	struct ib_gid_attr gid_attr;
+	struct hns_roce_ah *ah;
+	u16 vlan_tag = 0xffff;
+	struct in6_addr in6;
+	union ib_gid sgid;
+	int ret;
+
+	ah = kzalloc(sizeof(*ah), GFP_ATOMIC);
+	if (!ah)
+		return ERR_PTR(-ENOMEM);
+
+	/* Get mac address */
+	memcpy(&in6, ah_attr->grh.dgid.raw, sizeof(ah_attr->grh.dgid.raw));
+	if (rdma_is_multicast_addr(&in6))
+		rdma_get_mcast_mac(&in6, ah->av.mac);
+	else
+		memcpy(ah->av.mac, ah_attr->dmac, sizeof(ah_attr->dmac));
+
+	/* Get source gid */
+	ret = ib_get_cached_gid(ibpd->device, ah_attr->port_num,
+				ah_attr->grh.sgid_index, &sgid, &gid_attr);
+	if (ret) {
+		dev_err(dev, "get sgid failed! ret = %d\n", ret);
+		kfree(ah);
+		return ERR_PTR(ret);
+	}
+
+	if (gid_attr.ndev) {
+		if (is_vlan_dev(gid_attr.ndev))
+			vlan_tag = vlan_dev_vlan_id(gid_attr.ndev);
+		dev_put(gid_attr.ndev);
+	}
+
+	if (vlan_tag < 0x1000)
+		vlan_tag |= (ah_attr->sl & HNS_ROCE_VLAN_SL_BIT_MASK) <<
+			     HNS_ROCE_VLAN_SL_SHIFT;
+
+	ah->av.port_pd = cpu_to_be32(to_hr_pd(ibpd)->pdn | (ah_attr->port_num <<
+				     HNS_ROCE_PORT_NUM_SHIFT));
+	ah->av.gid_index = ah_attr->grh.sgid_index;
+	ah->av.vlan = cpu_to_le16(vlan_tag);
+	dev_dbg(dev, "gid_index = 0x%x,vlan = 0x%x\n", ah->av.gid_index,
+		ah->av.vlan);
+
+	if (ah_attr->static_rate)
+		ah->av.stat_rate = IB_RATE_10_GBPS;
+
+	memcpy(ah->av.dgid, ah_attr->grh.dgid.raw, HNS_ROCE_GID_SIZE);
+	ah->av.sl_tclass_flowlabel = cpu_to_le32(ah_attr->sl <<
+						 HNS_ROCE_SL_SHIFT);
+
+	return &ah->ibah;
+}
+
+int hns_roce_query_ah(struct ib_ah *ibah, struct ib_ah_attr *ah_attr)
+{
+	struct hns_roce_ah *ah = to_hr_ah(ibah);
+
+	memset(ah_attr, 0, sizeof(*ah_attr));
+
+	ah_attr->sl = le32_to_cpu(ah->av.sl_tclass_flowlabel) >>
+				  HNS_ROCE_SL_SHIFT;
+	ah_attr->port_num = le32_to_cpu(ah->av.port_pd) >>
+					HNS_ROCE_PORT_NUM_SHIFT;
+	ah_attr->static_rate = ah->av.stat_rate;
+	ah_attr->ah_flags = IB_AH_GRH;
+	ah_attr->grh.traffic_class = le32_to_cpu(ah->av.sl_tclass_flowlabel) >>
+						 HNS_ROCE_TCLASS_SHIFT;
+	ah_attr->grh.flow_label = le32_to_cpu(ah->av.sl_tclass_flowlabel) &
+					      HNS_ROCE_FLOW_LABLE_MASK;
+	ah_attr->grh.hop_limit = ah->av.hop_limit;
+	ah_attr->grh.sgid_index = ah->av.gid_index;
+	memcpy(ah_attr->grh.dgid.raw, ah->av.dgid, HNS_ROCE_GID_SIZE);
+
+	return 0;
+}
+
+int hns_roce_destroy_ah(struct ib_ah *ah)
+{
+	kfree(to_hr_ah(ah));
+
+	return 0;
+}
diff --git a/drivers/infiniband/hw/hns/hns_roce_device.h b/drivers/infiniband/hw/hns/hns_roce_device.h
index 2e8dad1..46474da 100644
--- a/drivers/infiniband/hw/hns/hns_roce_device.h
+++ b/drivers/infiniband/hw/hns/hns_roce_device.h
@@ -49,6 +49,11 @@
 #define HNS_ROCE_AEQE_VEC_NUM			1
 #define HNS_ROCE_AEQE_OF_VEC_NUM		1
 
+/* 4G/4K = 1M */
+#define HNS_ROCE_SL_SHIFT			29
+#define HNS_ROCE_TCLASS_SHIFT			20
+#define HNS_ROCE_FLOW_LABLE_MASK		0xfffff
+
 #define HNS_ROCE_MAX_PORTS			6
 #define HNS_ROCE_MAX_GID_NUM			16
 #define HNS_ROCE_GID_SIZE			16
@@ -215,6 +220,22 @@ struct hns_roce_raq_table {
 	struct hns_roce_buf_list	*e_raq_buf;
 };
 
+struct hns_roce_av {
+	__le32      port_pd;
+	u8          gid_index;
+	u8          stat_rate;
+	u8          hop_limit;
+	__le32      sl_tclass_flowlabel;
+	u8          dgid[HNS_ROCE_GID_SIZE];
+	u8          mac[6];
+	__le16      vlan;
+};
+
+struct hns_roce_ah {
+	struct ib_ah		ibah;
+	struct hns_roce_av	av;
+};
+
 struct hns_roce_cmd_context {
 	struct completion	done;
 	int			result;
@@ -397,6 +418,11 @@ static inline struct hns_roce_pd *to_hr_pd(struct ib_pd *ibpd)
 	return container_of(ibpd, struct hns_roce_pd, ibpd);
 }
 
+static inline struct hns_roce_ah *to_hr_ah(struct ib_ah *ibah)
+{
+	return container_of(ibah, struct hns_roce_ah, ibah);
+}
+
 static inline void hns_roce_write64_k(__be32 val[2], void __iomem *dest)
 {
 	__raw_writeq(*(u64 *) val, dest);
@@ -444,6 +470,10 @@ int hns_roce_bitmap_alloc_range(struct hns_roce_bitmap *bitmap, int cnt,
 void hns_roce_bitmap_free_range(struct hns_roce_bitmap *bitmap,
 				unsigned long obj, int cnt);
 
+struct ib_ah *hns_roce_create_ah(struct ib_pd *pd, struct ib_ah_attr *ah_attr);
+int hns_roce_query_ah(struct ib_ah *ibah, struct ib_ah_attr *ah_attr);
+int hns_roce_destroy_ah(struct ib_ah *ah);
+
 struct ib_pd *hns_roce_alloc_pd(struct ib_device *ib_dev,
 				struct ib_ucontext *context,
 				struct ib_udata *udata);
diff --git a/drivers/infiniband/hw/hns/hns_roce_main.c b/drivers/infiniband/hw/hns/hns_roce_main.c
index 8d85cda..221af17 100644
--- a/drivers/infiniband/hw/hns/hns_roce_main.c
+++ b/drivers/infiniband/hw/hns/hns_roce_main.c
@@ -600,6 +600,11 @@ static int hns_roce_register_device(struct hns_roce_dev *hr_dev)
 	ib_dev->alloc_pd		= hns_roce_alloc_pd;
 	ib_dev->dealloc_pd		= hns_roce_dealloc_pd;
 
+	/* AH */
+	ib_dev->create_ah		= hns_roce_create_ah;
+	ib_dev->query_ah		= hns_roce_query_ah;
+	ib_dev->destroy_ah		= hns_roce_destroy_ah;
+
 	ret = ib_register_device(ib_dev, NULL);
 	if (ret) {
 		dev_err(dev, "ib_register_device failed!\n");
-- 
1.9.1
