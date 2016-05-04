From: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v7 04/21] IB/hns: Add RoCE engine reset function
Date: Wed, 4 May 2016 20:21:01 +0800
Message-ID: <1462364478-10808-5-git-send-email-oulijun@huawei.com>
References: <1462364478-10808-1-git-send-email-oulijun@huawei.com>
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
In-Reply-To: <1462364478-10808-1-git-send-email-oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch mainly added reset flow of RoCE engine in RoCE
driver. It is necessary when RoCE is loaded and removed.

Signed-off-by: Wei Hu <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Nenglong Zhao <zhaonenglong-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Signed-off-by: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 drivers/infiniband/hw/hns/hns_roce_device.h |  7 ++++
 drivers/infiniband/hw/hns/hns_roce_hw_v1.c  | 54 +++++++++++++++++++++++++++++
 drivers/infiniband/hw/hns/hns_roce_hw_v1.h  | 17 +++++++++
 drivers/infiniband/hw/hns/hns_roce_main.c   | 16 ++++++++-
 4 files changed, 93 insertions(+), 1 deletion(-)
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_hw_v1.c
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_hw_v1.h

diff --git a/drivers/infiniband/hw/hns/hns_roce_device.h b/drivers/infiniband/hw/hns/hns_roce_device.h
index b48f518..b0b8f73 100644
--- a/drivers/infiniband/hw/hns/hns_roce_device.h
+++ b/drivers/infiniband/hw/hns/hns_roce_device.h
@@ -33,6 +33,10 @@ struct hns_roce_caps {
 	u8			num_ports;
 };
 
+struct hns_roce_hw {
+	int (*reset)(struct hns_roce_dev *hr_dev, bool enable);
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
index 0000000..1128a4c
--- /dev/null
+++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
@@ -0,0 +1,54 @@
+/*
+ * Copyright (c) 2016 Hisilicon Limited.
+ *
+ * Authors: Wei Hu <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
+ * Authors: Nenglong Zhao <zhaonenglong-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
+ * Authors: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
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
index 0000000..b58efea
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
+extern int hns_dsaf_roce_reset(struct fwnode_handle *dsaf_fwnode, bool enable);
+
+#endif
diff --git a/drivers/infiniband/hw/hns/hns_roce_main.c b/drivers/infiniband/hw/hns/hns_roce_main.c
index 1616148..a6f7147 100644
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
 
+int hns_roce_engine_reset(struct hns_roce_dev *hr_dev, bool enable)
+{
+	return hr_dev->hw->reset(hr_dev, enable);
+}
 /**
 * hns_roce_probe - RoCE driver entrance
 * @pdev: pointer to platform device
@@ -138,6 +144,12 @@ static int hns_roce_probe(struct platform_device *pdev)
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
 
@@ -152,6 +164,8 @@ static int hns_roce_remove(struct platform_device *pdev)
 {
 	struct hns_roce_dev *hr_dev = platform_get_drvdata(pdev);
 
+	(void)hns_roce_engine_reset(hr_dev, false);
+
 	ib_dealloc_device(&hr_dev->ib_dev);
 
 	return 0;
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
