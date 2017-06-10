From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH net-next 8/9] net: hns3: Add support of debugfs interface to HNS3 driver
Date: Sat, 10 Jun 2017 04:46:29 +0100
Message-ID: <20170610034630.493852-9-salil.mehta@huawei.com>
References: <20170610034630.493852-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <huangdaode@hisilicon.com>, <lipeng321@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170610034630.493852-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds the support of the debugfs interface to the driver for
debugging purposes.

Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
Signed-off-by: lipeng <lipeng321@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
Signed-off-by: Yisen Zhuang <yisen.zhuang@huawei.com>
---
 .../ethernet/hisilicon/hns3/hns3pf/hclge_debugfs.c | 188 +++++++++++++++++++++
 1 file changed, 188 insertions(+)
 create mode 100644 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_debugfs.c

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_debugfs.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_debugfs.c
new file mode 100644
index 0000000..8ef5a41
--- /dev/null
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_debugfs.c
@@ -0,0 +1,188 @@
+/*
+ * Copyright (c) 2016~2017 Hisilicon Limited.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/dma-mapping.h>
+#include <linux/debugfs.h>
+#include <linux/slab.h>
+#include <linux/pci.h>
+#include <linux/device.h>
+#include <linux/err.h>
+#include <linux/dma-direction.h>
+#include "hclge_cmd.h"
+#include "hclge_main.h"
+#include "hnae3.h"
+
+static struct dentry *hclge_dbgfs_root;
+static int hclge_dbg_usage(struct hclge_dev *hdev, char *data);
+#define HCLGE_DBG_READ_LEN	256
+
+struct hclge_support_cmd {
+	char *name;
+	int len;
+	int (*fn)(struct hclge_dev *hdev, char *data);
+	char *param;
+};
+
+static int hclge_dbg_send(struct hclge_dev *hdev, char *buf)
+{
+	struct hclge_desc desc;
+	enum hclge_cmd_status status;
+	int cnt;
+
+	cnt = sscanf(buf, "%hi %hi %i %i %i %i %i %i",
+		     &desc.opcode, &desc.flag,
+		     &desc.data[0], &desc.data[1], &desc.data[2],
+		     &desc.data[3], &desc.data[4], &desc.data[5]);
+	if (cnt != 8) {
+		dev_info(&hdev->pdev->dev,
+			 "send cmd: bad command parameter, cnt=%d\n", cnt);
+		return -EINVAL;
+	}
+
+	status = hclge_cmd_send(&hdev->hw, &desc, 1);
+	if (status) {
+		dev_info(&hdev->pdev->dev,
+			 "send comamnd fail Opcode:%x, Status:%d\n",
+			 desc.opcode, status);
+	}
+	dev_info(&hdev->pdev->dev, "get response:\n");
+	dev_info(&hdev->pdev->dev, "opcode:%04x\tflag:%04x\tretval:%04x\t\n",
+		 desc.opcode, desc.flag, desc.retval);
+	dev_info(&hdev->pdev->dev, "data[0~2]:%08x\t%08x\t%08x\n",
+		 desc.data[0], desc.data[1], desc.data[2]);
+	dev_info(&hdev->pdev->dev, "data[3-5]:%08x\t%08x\t%08x\n",
+		 desc.data[3], desc.data[4], desc.data[5]);
+	return 0;
+}
+
+const struct  hclge_support_cmd  support_cmd[] = {
+	{"send cmd", 8, hclge_dbg_send,
+		"opcode flag data0 data1 data2 data3 data4 data5"},
+	{"help", 4, hclge_dbg_usage, "no option"},
+};
+
+static int hclge_dbg_usage(struct hclge_dev *hdev, char *data)
+{
+	int i;
+
+	pr_info("supported cmd list:\n");
+	for (i = 0; i < ARRAY_SIZE(support_cmd); i++)
+		pr_info("%s: %s\n", support_cmd[i].name, support_cmd[i].param);
+
+	return 0;
+}
+
+static ssize_t hclge_dbg_cmd_read(struct file *filp, char __user *buffer,
+				  size_t count, loff_t *ppos)
+{
+	int uncopy_bytes;
+	char *buf;
+	int len;
+
+	if (*ppos != 0)
+		return 0;
+	if (count < HCLGE_DBG_READ_LEN)
+		return -ENOSPC;
+	buf = kzalloc(HCLGE_DBG_READ_LEN, GFP_KERNEL);
+	if (!buf)
+		return -ENOSPC;
+
+	len = snprintf(buf, HCLGE_DBG_READ_LEN, "%s\n",
+		       "Please echo help to cmd to get help information");
+	uncopy_bytes = copy_to_user(buffer, buf, len);
+	kfree(buf);
+
+	if (uncopy_bytes)
+		return -EFAULT;
+
+	*ppos = len;
+	return len;
+}
+
+static ssize_t hclge_dbg_cmd_write(struct file *filp, const char __user *buffer,
+				   size_t count, loff_t *ppos)
+{
+	struct hclge_dev *hdev = filp->private_data;
+	char *cmd_buf, *cmd_buf_tmp;
+	int uncopied_bytes;
+	int i;
+
+	if (*ppos != 0)
+		return 0;
+	cmd_buf = kzalloc(count + 1, GFP_KERNEL);
+	if (!cmd_buf)
+		return count;
+	uncopied_bytes = copy_from_user(cmd_buf, buffer, count);
+	if (uncopied_bytes) {
+		kfree(cmd_buf);
+		return -EFAULT;
+	}
+	cmd_buf[count] = '\0';
+
+	cmd_buf_tmp = strchr(cmd_buf, '\n');
+	if (cmd_buf_tmp) {
+		*cmd_buf_tmp = '\0';
+		count = cmd_buf_tmp - cmd_buf + 1;
+	}
+
+	for (i = 0; i < ARRAY_SIZE(support_cmd); i++) {
+		if (strncmp(cmd_buf, support_cmd[i].name,
+			    support_cmd[i].len) == 0) {
+			support_cmd[i].fn(hdev, &cmd_buf[support_cmd[i].len]);
+			break;
+		}
+	}
+
+	kfree(cmd_buf);
+	cmd_buf = NULL;
+	return count;
+}
+
+static const struct file_operations hclge_dbg_cmd_fops = {
+	.owner	= THIS_MODULE,
+	.open	= simple_open,
+	.read	= hclge_dbg_cmd_read,
+	.write	= hclge_dbg_cmd_write,
+};
+
+void hclge_dbg_init(struct hclge_dev *hdev)
+{
+	struct dentry *pfile;
+	const char *name = pci_name(hdev->pdev);
+
+	hdev->hclge_dbgfs = debugfs_create_dir(name, hclge_dbgfs_root);
+	if (!hdev->hclge_dbgfs)
+		return;
+	pfile = debugfs_create_file("cmd", 0600, hdev->hclge_dbgfs, hdev,
+				    &hclge_dbg_cmd_fops);
+	if (!pfile)
+		dev_info(&hdev->pdev->dev, "create file for %s fail\n", name);
+}
+
+void hclge_dbg_uninit(struct hclge_dev *hdev)
+{
+	debugfs_remove_recursive(hdev->hclge_dbgfs);
+	hdev->hclge_dbgfs = NULL;
+}
+
+void hclge_register_debugfs(void)
+{
+	hclge_dbgfs_root = debugfs_create_dir(HCLGE_DRIVER_NAME, NULL);
+	if (!hclge_dbgfs_root) {
+		pr_info("register debugfs for %s fail\n", HCLGE_DRIVER_NAME);
+		return;
+	}
+	pr_info("register debugfs root dir %s\n", HCLGE_DRIVER_NAME);
+}
+
+void hclge_unregister_debugfs(void)
+{
+	debugfs_remove_recursive(hclge_dbgfs_root);
+	hclge_dbgfs_root = NULL;
+}
-- 
2.7.4
