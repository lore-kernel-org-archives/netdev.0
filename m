From: Lijun Ou <oulijun@huawei.com>
Subject: [PATCH v5 04/21] IB/hns: Add RoCE engine reset function
Date: Sat, 23 Apr 2016 18:26:42 +0800
Message-ID: <1461407219-72027-5-git-send-email-oulijun@huawei.com>
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

This patch mainly added RoCE engine reset process in RoCE driver.
it is necessary when RoCE was loaded and removed.

Signed-off-by: Lijun Ou <oulijun@huawei.com>
Signed-off-by: Wei Hu(Xavier) <xavier.huwei@huawei.com>
---
 drivers/infiniband/hw/hns/hns_roce_device.h |  7 ++++
 drivers/infiniband/hw/hns/hns_roce_hw_v1.c  | 54 +++++++++++++++++++++++++++++
 drivers/infiniband/hw/hns/hns_roce_hw_v1.h  | 17 +++++++++
 drivers/infiniband/hw/hns/hns_roce_main.c   | 18 ++++++++--
 4 files changed, 94 insertions(+), 2 deletions(-)
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_hw_v1.c
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_hw_v1.h

diff --git a/drivers/infiniband/hw/hns/hns_roce_device.h b/drivers/infiniband/hw/hns/hns_roce_device.h
index b48f518..24ac1a8 100644
--- a/drivers/infiniband/hw/hns/hns_roce_device.h
+++ b/drivers/infiniband/hw/hns/hns_roce_device.h
@@ -33,6 +33,10 @@ struct hns_roce_caps {
 	u8			num_ports;
 };
 
+struct hns_roce_hw {
+	int (*reset)(struct hns_roce_dev *hr_dev, u32 val);
+};
+
 struct hns_roce_dev {
 	struct ib_device	ib_dev;
 	struct platform_device  *pdev;
@@ -44,6 +48,9 @@ struct hns_roce_dev {
 
 	int			cmd_mod;
 	int			loop_idc;
+	struct hns_roce_hw	*hw;
 };
 
+extern struct hns_roce_hw hns_roce_hw_v1;
+
 #endif /* _HNS_ROCE_DEVICE_H */
diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
new file mode 100644
index 0000000..ea39e56
--- /dev/null
+++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
@@ -0,0 +1,54 @@
+/*
+ * Copyright (c) 2016 Hisilicon Limited.
+ *
+ * Authors: Wei Hu <xavier.huwei@huawei.com>
+ * Authors: Znlong <zhaonenglong@hisilicon.com>
+ * Authors: oulijun <oulijun@huawei.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/of.h>
+#include <linux/of_address.h>
+#include <linux/of_platform.h>
+#include <linux/platform_device.h>
+#include "hns_roce_device.h"
+#include "hns_roce_hw_v1.h"
+
+/**
+ * hns_roce_v1_reset - reset roce
+ * @hr_dev: roce device struct pointer
+ * @val: 1 -- drop reset, 0 -- reset
+ * return 0 - success , negative --fail
+ */
+int hns_roce_v1_reset(struct hns_roce_dev *hr_dev, u32 val)
+{
+	struct device_node *dsaf_node;
+	struct device *dev = &hr_dev->pdev->dev;
+	struct device_node *np = dev->of_node;
+	int ret;
+
+	dsaf_node = of_parse_phandle(np, "dsaf-handle", 0);
+
+	if (!val) {
+		ret = hns_dsaf_roce_reset(&dsaf_node->fwnode, 0);
+	} else {
+		ret = hns_dsaf_roce_reset(&dsaf_node->fwnode, 0);
+		if (ret)
+			return ret;
+
+		msleep(SLEEP_TIME_INTERVAL);
+		ret = hns_dsaf_roce_reset(&dsaf_node->fwnode, 1);
+	}
+
+		return ret;
+}
+
+struct hns_roce_hw hns_roce_hw_v1 = {
+	.reset = hns_roce_v1_reset,
+};
diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.h b/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
new file mode 100644
index 0000000..164041d
--- /dev/null
+++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
@@ -0,0 +1,17 @@
+/*
+ * Copyright (c) 2016 Hisilicon Limited.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef _HNS_ROCE_HW_V1_H
+#define _HNS_ROCE_HW_V1_H
+
+#define SLEEP_TIME_INTERVAL		20
+
+extern int hns_dsaf_roce_reset(struct fwnode_handle *dsaf_fwnode, u32 val);
+
+#endif
diff --git a/drivers/infiniband/hw/hns/hns_roce_main.c b/drivers/infiniband/hw/hns/hns_roce_main.c
index 5bd84f2..df3116f 100644
--- a/drivers/infiniband/hw/hns/hns_roce_main.c
+++ b/drivers/infiniband/hw/hns/hns_roce_main.c
@@ -53,7 +53,9 @@ int hns_roce_get_cfg(struct hns_roce_dev *hr_dev)
 	struct platform_device *pdev = NULL;
 	struct resource *res;
 
-	if (!of_device_is_compatible(np, "hisilicon,hns-roce-v1")) {
+	if (of_device_is_compatible(np, "hisilicon,hns-roce-v1")) {
+		hr_dev->hw = &hns_roce_hw_v1;
+	} else {
 		dev_err(dev, "device no compatible!\n");
 		return -EINVAL;
 	}
@@ -98,6 +100,10 @@ int hns_roce_get_cfg(struct hns_roce_dev *hr_dev)
 	return 0;
 }
 
+int hns_roce_engine_reset(struct hns_roce_dev *hr_dev, u32 val)
+{
+	return hr_dev->hw->reset(hr_dev, val);
+}
 /**
 * hns_roce_probe - RoCE driver entrance
 * @pdev: pointer to platform device
@@ -131,13 +137,18 @@ static int hns_roce_probe(struct platform_device *pdev)
 		ret = -EIO;
 		goto error_failed_get_cfg;
 	}
-
 	ret = hns_roce_get_cfg(hr_dev);
 	if (ret) {
 		dev_err(dev, "Get Configuration failed!\n");
 		goto error_failed_get_cfg;
 	}
 
+	ret = hns_roce_engine_reset(hr_dev, 1);
+	if (ret) {
+		dev_err(dev, "Reset roce engine failed!\n");
+		goto error_failed_get_cfg;
+	}
+
 error_failed_get_cfg:
 	ib_dealloc_device(&hr_dev->ib_dev);
 	return ret;
@@ -152,6 +163,9 @@ static int hns_roce_remove(struct platform_device *pdev)
 	struct hns_roce_dev *hr_dev = platform_get_drvdata(pdev);
 	int ret = 0;
 
+	ret = hns_roce_engine_reset(hr_dev, 0);
+	if (ret)
+		return ret;
 	ib_dealloc_device(&hr_dev->ib_dev);
 
 	return ret;
-- 
1.9.1
