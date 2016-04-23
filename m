From: Lijun Ou <oulijun@huawei.com>
Subject: [PATCH v5 06/21] IB/hns: Add initial cmd operation
Date: Sat, 23 Apr 2016 18:26:44 +0800
Message-ID: <1461407219-72027-7-git-send-email-oulijun@huawei.com>
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

This patch added the operation for initing cmd. In addition that,
added some functions for initing eq table and selecting cmd mode
in next stages.

Signed-off-by: Lijun Ou <oulijun@huawei.com>
Signed-off-by: Wei Hu(Xavier) <xavier.huwei@huawei.com>
---
 drivers/infiniband/hw/hns/hns_roce_cmd.c    | 92 +++++++++++++++++++++++++++++
 drivers/infiniband/hw/hns/hns_roce_cmd.h    | 19 ++++++
 drivers/infiniband/hw/hns/hns_roce_common.h |  2 +
 drivers/infiniband/hw/hns/hns_roce_device.h | 41 +++++++++++++
 drivers/infiniband/hw/hns/hns_roce_main.c   | 15 +++++
 5 files changed, 169 insertions(+)
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_cmd.c
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_cmd.h

diff --git a/drivers/infiniband/hw/hns/hns_roce_cmd.c b/drivers/infiniband/hw/hns/hns_roce_cmd.c
new file mode 100644
index 0000000..9a274de
--- /dev/null
+++ b/drivers/infiniband/hw/hns/hns_roce_cmd.c
@@ -0,0 +1,92 @@
+/*
+ * Copyright (c) 2016 Hisilicon Limited.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/of.h>
+#include <linux/of_address.h>
+#include <linux/of_platform.h>
+#include <linux/platform_device.h>
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
+	if (!hr_dev->cmd.pool) {
+		dev_err(dev, "Couldn't create mailbox pool for cmd.\n");
+		return -ENOMEM;
+	}
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
index 0000000..4e102a4
--- /dev/null
+++ b/drivers/infiniband/hw/hns/hns_roce_cmd.h
@@ -0,0 +1,19 @@
+/*
+ * Copyright (c) 2016 Hisilicon Limited.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef _HNS_ROCE_CMD_H
+#define _HNS_ROCE_CMD_H
+
+#include <linux/dma-mapping.h>
+
+enum {
+	HNS_ROCE_MAILBOX_SIZE		=  4096
+};
+
+#endif /* _HNS_ROCE_CMD_H */
diff --git a/drivers/infiniband/hw/hns/hns_roce_common.h b/drivers/infiniband/hw/hns/hns_roce_common.h
index 0f90214..84a9580 100644
--- a/drivers/infiniband/hw/hns/hns_roce_common.h
+++ b/drivers/infiniband/hw/hns/hns_roce_common.h
@@ -22,4 +22,6 @@
 
 #define ROCEE_ACK_DELAY_REG			0x14
 
+#define ROCEE_MB1_REG				0x210
+
 #endif /* _HNS_ROCE_COMMON_H */
diff --git a/drivers/infiniband/hw/hns/hns_roce_device.h b/drivers/infiniband/hw/hns/hns_roce_device.h
index e3e59d0..209c5c0 100644
--- a/drivers/infiniband/hw/hns/hns_roce_device.h
+++ b/drivers/infiniband/hw/hns/hns_roce_device.h
@@ -31,6 +31,40 @@
 
 #define ADDR_SHIFT_32				32
 
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
@@ -100,11 +134,18 @@ struct hns_roce_dev {
 	u32                     vendor_part_id;
 	u32                     hw_rev;
 
+	struct hns_roce_cmdq      cmd;
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
index 05cbc4e..03cf648 100644
--- a/drivers/infiniband/hw/hns/hns_roce_main.c
+++ b/drivers/infiniband/hw/hns/hns_roce_main.c
@@ -39,6 +39,7 @@
 #include <rdma/ib_umem.h>
 #include <rdma/ib_user_verbs.h>
 #include <rdma/ib_verbs.h>
+#include "hns_roce_common.h"
 #include "hns_roce_device.h"
 
 int hns_roce_get_cfg(struct hns_roce_dev *hr_dev)
@@ -157,8 +158,20 @@ static int hns_roce_probe(struct platform_device *pdev)
 
 	hns_roce_profile_init(hr_dev);
 
+	ret = hns_roce_cmd_init(hr_dev);
+	if (ret) {
+		dev_err(dev, "cmd init failed!\n");
+		goto error_failed_cmd_init;
+	}
+
+error_failed_cmd_init:
+	ret = hns_roce_engine_reset(hr_dev, 0);
+	if (ret)
+		dev_err(&hr_dev->pdev->dev, "roce_engine reset fail\n");
+
 error_failed_get_cfg:
 	ib_dealloc_device(&hr_dev->ib_dev);
+
 	return ret;
 }
 
@@ -171,6 +184,8 @@ static int hns_roce_remove(struct platform_device *pdev)
 	struct hns_roce_dev *hr_dev = platform_get_drvdata(pdev);
 	int ret = 0;
 
+	hns_roce_cmd_cleanup(hr_dev);
+
 	ret = hns_roce_engine_reset(hr_dev, 0);
 	if (ret)
 		return ret;
-- 
1.9.1
