From: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v10 06/22] IB/hns: Add initial cmd operation
Date: Thu, 16 Jun 2016 22:35:14 +0800
Message-ID: <1466087730-54856-7-git-send-email-oulijun@huawei.com>
References: <1466087730-54856-1-git-send-email-oulijun@huawei.com>
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
In-Reply-To: <1466087730-54856-1-git-send-email-oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch added the operation for cmd, and added some functions
for initializing eq table and selecting cmd mode.

Signed-off-by: Wei Hu <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Nenglong Zhao <zhaonenglong-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Signed-off-by: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
PATCH v9/v8/v7/v6:
- No change over the PATCH v5

PATCH v5:
- The initial patch which was redesigned based on the second patch
  in PATCH v4
---
---
 drivers/infiniband/hw/hns/hns_roce_cmd.c    | 117 ++++++++++++++++++++++++++++
 drivers/infiniband/hw/hns/hns_roce_cmd.h    |  42 ++++++++++
 drivers/infiniband/hw/hns/hns_roce_common.h |   2 +
 drivers/infiniband/hw/hns/hns_roce_device.h |  41 ++++++++++
 drivers/infiniband/hw/hns/hns_roce_main.c   |  13 ++++
 5 files changed, 215 insertions(+)
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_cmd.c
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_cmd.h

diff --git a/drivers/infiniband/hw/hns/hns_roce_cmd.c b/drivers/infiniband/hw/hns/hns_roce_cmd.c
new file mode 100644
index 0000000..64e84fe
--- /dev/null
+++ b/drivers/infiniband/hw/hns/hns_roce_cmd.c
@@ -0,0 +1,117 @@
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
+#include <linux/dma-mapping.h>
+#include <linux/dmapool.h>
+#include <linux/errno.h>
+#include <linux/init.h>
+#include <linux/interrupt.h>
+#include <linux/io.h>
+#include <linux/list.h>
+#include <linux/sched.h>
+#include <linux/slab.h>
+#include "hns_roce_common.h"
+#include "hns_roce_device.h"
+#include "hns_roce_cmd.h"
+
+#define CMD_MAX_NUM		32
+
+int hns_roce_cmd_init(struct hns_roce_dev *hr_dev)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+
+	mutex_init(&hr_dev->cmd.hcr_mutex);
+	sema_init(&hr_dev->cmd.poll_sem, 1);
+	hr_dev->cmd.use_events = 0;
+	hr_dev->cmd.toggle = 1;
+	hr_dev->cmd.max_cmds = CMD_MAX_NUM;
+	hr_dev->cmd.hcr = hr_dev->reg_base + ROCEE_MB1_REG;
+	hr_dev->cmd.pool = dma_pool_create("hns_roce_cmd", dev,
+					   HNS_ROCE_MAILBOX_SIZE,
+					   HNS_ROCE_MAILBOX_SIZE, 0);
+	if (!hr_dev->cmd.pool)
+		return -ENOMEM;
+
+	return 0;
+}
+
+void hns_roce_cmd_cleanup(struct hns_roce_dev *hr_dev)
+{
+	dma_pool_destroy(hr_dev->cmd.pool);
+}
+
+int hns_roce_cmd_use_events(struct hns_roce_dev *hr_dev)
+{
+	struct hns_roce_cmdq *hr_cmd = &hr_dev->cmd;
+	int i;
+
+	hr_cmd->context = kmalloc(hr_cmd->max_cmds *
+				  sizeof(struct hns_roce_cmd_context),
+				  GFP_KERNEL);
+	if (!hr_cmd->context)
+		return -ENOMEM;
+
+	for (i = 0; i < hr_cmd->max_cmds; ++i) {
+		hr_cmd->context[i].token = i;
+		hr_cmd->context[i].next = i + 1;
+	}
+
+	hr_cmd->context[hr_cmd->max_cmds - 1].next = -1;
+	hr_cmd->free_head = 0;
+
+	sema_init(&hr_cmd->event_sem, hr_cmd->max_cmds);
+	spin_lock_init(&hr_cmd->context_lock);
+
+	for (hr_cmd->token_mask = 1; hr_cmd->token_mask < hr_cmd->max_cmds;
+	     hr_cmd->token_mask <<= 1)
+		;
+	--hr_cmd->token_mask;
+	hr_cmd->use_events = 1;
+
+	down(&hr_cmd->poll_sem);
+
+	return 0;
+}
+
+void hns_roce_cmd_use_polling(struct hns_roce_dev *hr_dev)
+{
+	struct hns_roce_cmdq *hr_cmd = &hr_dev->cmd;
+	int i;
+
+	hr_cmd->use_events = 0;
+
+	for (i = 0; i < hr_cmd->max_cmds; ++i)
+		down(&hr_cmd->event_sem);
+
+	kfree(hr_cmd->context);
+	up(&hr_cmd->poll_sem);
+}
diff --git a/drivers/infiniband/hw/hns/hns_roce_cmd.h b/drivers/infiniband/hw/hns/hns_roce_cmd.h
new file mode 100644
index 0000000..ff8e62d
--- /dev/null
+++ b/drivers/infiniband/hw/hns/hns_roce_cmd.h
@@ -0,0 +1,42 @@
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
+#ifndef _HNS_ROCE_CMD_H
+#define _HNS_ROCE_CMD_H
+
+#include <linux/dma-mapping.h>
+
+enum {
+	HNS_ROCE_MAILBOX_SIZE		= 4096,
+};
+
+#endif /* _HNS_ROCE_CMD_H */
diff --git a/drivers/infiniband/hw/hns/hns_roce_common.h b/drivers/infiniband/hw/hns/hns_roce_common.h
index 4cc4761..595cda9 100644
--- a/drivers/infiniband/hw/hns/hns_roce_common.h
+++ b/drivers/infiniband/hw/hns/hns_roce_common.h
@@ -46,4 +46,6 @@
 
 #define ROCEE_ACK_DELAY_REG			0x14
 
+#define ROCEE_MB1_REG				0x210
+
 #endif /* _HNS_ROCE_COMMON_H */
diff --git a/drivers/infiniband/hw/hns/hns_roce_device.h b/drivers/infiniband/hw/hns/hns_roce_device.h
index e01ea34..23b7e17 100644
--- a/drivers/infiniband/hw/hns/hns_roce_device.h
+++ b/drivers/infiniband/hw/hns/hns_roce_device.h
@@ -53,6 +53,40 @@
 
 #define HNS_ROCE_MAX_PORTS			6
 
+struct hns_roce_cmd_context {
+	int			next;
+	u16			token;
+};
+
+struct hns_roce_cmdq {
+	struct dma_pool		*pool;
+	u8 __iomem		*hcr;
+	struct mutex		hcr_mutex;
+	struct semaphore	poll_sem;
+	/*
+	* Event mode: cmd register mutex protection,
+	* ensure to not exceed max_cmds and user use limit region
+	*/
+	struct semaphore	event_sem;
+	int			max_cmds;
+	spinlock_t		context_lock;
+	int			free_head;
+	struct hns_roce_cmd_context *context;
+	/*
+	* Result of get integer part
+	* which max_comds compute according a power of 2
+	*/
+	u16			token_mask;
+	/*
+	* Process whether use event mode, init default non-zero
+	* After the event queue of cmd event ready,
+	* can switch into event mode
+	* close device, switch into poll mode(non event mode)
+	*/
+	u8			use_events;
+	u8			toggle;
+};
+
 struct hns_roce_ib_iboe {
 	struct net_device      *netdevs[HNS_ROCE_MAX_PORTS];
 	u8			phy_port[HNS_ROCE_MAX_PORTS];
@@ -123,11 +157,18 @@ struct hns_roce_dev {
 	u32                     vendor_part_id;
 	u32                     hw_rev;
 
+	struct hns_roce_cmdq	cmd;
+
 	int			cmd_mod;
 	int			loop_idc;
 	struct hns_roce_hw	*hw;
 };
 
+int hns_roce_cmd_init(struct hns_roce_dev *hr_dev);
+void hns_roce_cmd_cleanup(struct hns_roce_dev *hr_dev);
+int hns_roce_cmd_use_events(struct hns_roce_dev *hr_dev);
+void hns_roce_cmd_use_polling(struct hns_roce_dev *hr_dev);
+
 extern struct hns_roce_hw hns_roce_hw_v1;
 
 #endif /* _HNS_ROCE_DEVICE_H */
diff --git a/drivers/infiniband/hw/hns/hns_roce_main.c b/drivers/infiniband/hw/hns/hns_roce_main.c
index b487b57..c9e6d37 100644
--- a/drivers/infiniband/hw/hns/hns_roce_main.c
+++ b/drivers/infiniband/hw/hns/hns_roce_main.c
@@ -57,6 +57,7 @@
 #include <rdma/ib_umem.h>
 #include <rdma/ib_user_verbs.h>
 #include <rdma/ib_verbs.h>
+#include "hns_roce_common.h"
 #include "hns_roce_device.h"
 
 static int hns_roce_get_cfg(struct hns_roce_dev *hr_dev)
@@ -176,6 +177,17 @@ static int hns_roce_probe(struct platform_device *pdev)
 
 	hns_roce_profile_init(hr_dev);
 
+	ret = hns_roce_cmd_init(hr_dev);
+	if (ret) {
+		dev_err(dev, "cmd init failed!\n");
+		goto error_failed_cmd_init;
+	}
+
+error_failed_cmd_init:
+	ret = hns_roce_engine_reset(hr_dev, false);
+	if (ret)
+		dev_err(&hr_dev->pdev->dev, "roce_engine reset fail\n");
+
 error_failed_get_cfg:
 	ib_dealloc_device(&hr_dev->ib_dev);
 
@@ -190,6 +202,7 @@ static int hns_roce_remove(struct platform_device *pdev)
 {
 	struct hns_roce_dev *hr_dev = platform_get_drvdata(pdev);
 
+	hns_roce_cmd_cleanup(hr_dev);
 	(void)hns_roce_engine_reset(hr_dev, false);
 
 	ib_dealloc_device(&hr_dev->ib_dev);
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
