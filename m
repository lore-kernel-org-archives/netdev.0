From: Lijun Ou <oulijun@huawei.com>
Subject: [PATCH v11 11/22] IB/hns: Add IB device registration
Date: Sat, 2 Jul 2016 17:39:13 +0800
Message-ID: <1467452364-66522-12-git-send-email-oulijun@huawei.com>
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

This patch registered IB device when loaded, and unregistered
IB device when removed.

Signed-off-by: Wei Hu <xavier.huwei@huawei.com>
Signed-off-by: Nenglong Zhao <zhaonenglong@hisilicon.com>
Signed-off-by: Lijun Ou <oulijun@huawei.com>
---
PATCH v11:
Remove hns_roce_profile_init function for one line of code
which will be called once only according to Leon Romanovsky's
comments over the [PATCH v10 5/22]:
  Link: https://lkml.org/lkml/2016/6/24/419

PATCH v10:
This fixes the comments given by Leon Romanovsky over the PATCH v9:
  Link: https://lkml.org/lkml/2016/6/9/53

PATCH v9/v8/v7/v6:
- No change over the PATCH v5

PATCH v5:
- The initial patch which was redesigned based on the second patch
  in PATCH v4
---
---
 drivers/infiniband/hw/hns/hns_roce_main.c | 45 +++++++++++++++++++++++++++++++
 1 file changed, 45 insertions(+)

diff --git a/drivers/infiniband/hw/hns/hns_roce_main.c b/drivers/infiniband/hw/hns/hns_roce_main.c
index 966e6d0..61b6ab2 100644
--- a/drivers/infiniband/hw/hns/hns_roce_main.c
+++ b/drivers/infiniband/hw/hns/hns_roce_main.c
@@ -39,6 +39,41 @@
 #include "hns_roce_device.h"
 #include "hns_roce_hem.h"
 
+static void hns_roce_unregister_device(struct hns_roce_dev *hr_dev)
+{
+	ib_unregister_device(&hr_dev->ib_dev);
+}
+
+static int hns_roce_register_device(struct hns_roce_dev *hr_dev)
+{
+	int ret;
+	struct hns_roce_ib_iboe *iboe = NULL;
+	struct ib_device *ib_dev = NULL;
+	struct device *dev = &hr_dev->pdev->dev;
+
+	iboe = &hr_dev->iboe;
+
+	ib_dev = &hr_dev->ib_dev;
+	strlcpy(ib_dev->name, "hisi_%d", IB_DEVICE_NAME_MAX);
+
+	ib_dev->owner			= THIS_MODULE;
+	ib_dev->node_type		= RDMA_NODE_IB_CA;
+	ib_dev->dma_device		= dev;
+
+	ib_dev->phys_port_cnt		= hr_dev->caps.num_ports;
+	ib_dev->local_dma_lkey		= hr_dev->caps.reserved_lkey;
+	ib_dev->num_comp_vectors	= hr_dev->caps.num_comp_vectors;
+	ib_dev->uverbs_abi_ver		= 1;
+
+	ret = ib_register_device(ib_dev, NULL);
+	if (ret) {
+		dev_err(dev, "ib_register_device failed!\n");
+		return ret;
+	}
+
+	return 0;
+}
+
 static int hns_roce_get_cfg(struct hns_roce_dev *hr_dev)
 {
 	int i;
@@ -319,6 +354,15 @@ static int hns_roce_probe(struct platform_device *pdev)
 		goto error_failed_engine_init;
 	}
 
+	ret = hns_roce_register_device(hr_dev);
+	if (ret)
+		goto error_failed_register_device;
+
+	return 0;
+
+error_failed_register_device:
+	hr_dev->hw->hw_exit(hr_dev);
+
 error_failed_engine_init:
 	hns_roce_cleanup_bitmap(hr_dev);
 
@@ -354,6 +398,7 @@ static int hns_roce_remove(struct platform_device *pdev)
 {
 	struct hns_roce_dev *hr_dev = platform_get_drvdata(pdev);
 
+	hns_roce_unregister_device(hr_dev);
 	hr_dev->hw->hw_exit(hr_dev);
 	hns_roce_cleanup_bitmap(hr_dev);
 	hns_roce_cleanup_hem(hr_dev);
-- 
1.9.1
