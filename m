From: Lijun Ou <oulijun@huawei.com>
Subject: [RESEND PATCH v9 04/22] IB/hns: Add RoCE engine reset function
Date: Wed, 8 Jun 2016 14:44:39 +0800
Message-ID: <1465368297-82118-5-git-send-email-oulijun@huawei.com>
References: <1465368297-82118-1-git-send-email-oulijun@huawei.com>
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
In-Reply-To: <1465368297-82118-1-git-send-email-oulijun@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch mainly added reset flow of RoCE engine in RoCE
driver. It is necessary when RoCE is loaded and removed.

Signed-off-by: Wei Hu <xavier.huwei@huawei.com>
Signed-off-by: Nenglong Zhao <zhaonenglong@hisilicon.com>
Signed-off-by: Lijun Ou <oulijun@huawei.com>
---
 drivers/infiniband/hw/hns/hns_roce_device.h |  7 +++
 drivers/infiniband/hw/hns/hns_roce_hw_v1.c  | 72 +++++++++++++++++++++++++++++
 drivers/infiniband/hw/hns/hns_roce_hw_v1.h  | 40 ++++++++++++++++
 drivers/infiniband/hw/hns/hns_roce_main.c   | 17 ++++++-
 4 files changed, 135 insertions(+), 1 deletion(-)
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_hw_v1.c
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_hw_v1.h

diff --git a/drivers/infiniband/hw/hns/hns_roce_device.h b/drivers/infiniband/hw/hns/hns_roce_device.h
index f9de8e4..2e18488 100644
--- a/drivers/infiniband/hw/hns/hns_roce_device.h
+++ b/drivers/infiniband/hw/hns/hns_roce_device.h
@@ -56,6 +56,10 @@ struct hns_roce_caps {
 	u8			num_ports;
 };
 
+struct hns_roce_hw {
+	int (*reset)(struct hns_roce_dev *hr_dev, bool enable);
+};
+
 struct hns_roce_dev {
 	struct ib_device	ib_dev;
 	struct platform_device  *pdev;
@@ -67,6 +71,9 @@ struct hns_roce_dev {
 
 	int			cmd_mod;
 	int			loop_idc;
+	struct hns_roce_hw	*hw;
 };
 
+extern struct hns_roce_hw hns_roce_hw_v1;
+
 #endif /* _HNS_ROCE_DEVICE_H */
diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
new file mode 100644
index 0000000..198be3b
--- /dev/null
+++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
@@ -0,0 +1,72 @@
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
+ * @enable: true -- drop reset, false -- reset
+ * return 0 - success , negative --fail
+ */
+int hns_roce_v1_reset(struct hns_roce_dev *hr_dev, bool enable)
+{
+	struct device_node *dsaf_node;
+	struct device *dev = &hr_dev->pdev->dev;
+	struct device_node *np = dev->of_node;
+	int ret;
+
+	dsaf_node = of_parse_phandle(np, "dsaf-handle", 0);
+
+	if (!enable) {
+		ret = hns_dsaf_roce_reset(&dsaf_node->fwnode, false);
+	} else {
+		ret = hns_dsaf_roce_reset(&dsaf_node->fwnode, false);
+		if (ret)
+			return ret;
+
+		msleep(SLEEP_TIME_INTERVAL);
+		ret = hns_dsaf_roce_reset(&dsaf_node->fwnode, true);
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
index 0000000..ca69d0b
--- /dev/null
+++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
@@ -0,0 +1,40 @@
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
+#ifndef _HNS_ROCE_HW_V1_H
+#define _HNS_ROCE_HW_V1_H
+
+#define SLEEP_TIME_INTERVAL		20
+
+extern int hns_dsaf_roce_reset(struct fwnode_handle *dsaf_fwnode, bool enable);
+
+#endif
diff --git a/drivers/infiniband/hw/hns/hns_roce_main.c b/drivers/infiniband/hw/hns/hns_roce_main.c
index 21c5e8e..c9afcb8 100644
--- a/drivers/infiniband/hw/hns/hns_roce_main.c
+++ b/drivers/infiniband/hw/hns/hns_roce_main.c
@@ -72,7 +72,9 @@ int hns_roce_get_cfg(struct hns_roce_dev *hr_dev)
 	struct platform_device *pdev = NULL;
 	struct resource *res;
 
-	if (!of_device_is_compatible(np, "hisilicon,hns-roce-v1")) {
+	if (of_device_is_compatible(np, "hisilicon,hns-roce-v1")) {
+		hr_dev->hw = &hns_roce_hw_v1;
+	} else {
 		dev_err(dev, "device no compatible!\n");
 		return -EINVAL;
 	}
@@ -115,6 +117,11 @@ int hns_roce_get_cfg(struct hns_roce_dev *hr_dev)
 	return 0;
 }
 
+int hns_roce_engine_reset(struct hns_roce_dev *hr_dev, bool enable)
+{
+	return hr_dev->hw->reset(hr_dev, enable);
+}
+
 /**
 * hns_roce_probe - RoCE driver entrance
 * @pdev: pointer to platform device
@@ -153,6 +160,12 @@ static int hns_roce_probe(struct platform_device *pdev)
 		goto error_failed_get_cfg;
 	}
 
+	ret = hns_roce_engine_reset(hr_dev, true);
+	if (ret) {
+		dev_err(dev, "Reset roce engine failed!\n");
+		goto error_failed_get_cfg;
+	}
+
 error_failed_get_cfg:
 	ib_dealloc_device(&hr_dev->ib_dev);
 
@@ -167,6 +180,8 @@ static int hns_roce_remove(struct platform_device *pdev)
 {
 	struct hns_roce_dev *hr_dev = platform_get_drvdata(pdev);
 
+	(void)hns_roce_engine_reset(hr_dev, false);
+
 	ib_dealloc_device(&hr_dev->ib_dev);
 
 	return 0;
-- 
1.9.1
