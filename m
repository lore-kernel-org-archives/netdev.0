From: Selvin Xavier <selvin.xavier@broadcom.com>
Subject: [PATCH V2  19/22] bnxt_re: Support debugfs
Date: Thu,  8 Dec 2016 22:48:13 -0800
Message-ID: <1481266096-23331-20-git-send-email-selvin.xavier@broadcom.com>
References: <1481266096-23331-1-git-send-email-selvin.xavier@broadcom.com>
Cc: netdev@vger.kernel.org, Selvin Xavier <selvin.xavier@broadcom.com>,
        Eddie Wai <eddie.wai@broadcom.com>,
        Devesh Sharma <devesh.sharma@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
To: dledford@redhat.com, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lpdvsmtp01.broadcom.com ([192.19.211.62]:45711 "EHLO
        relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932261AbcLIGsi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 01:48:38 -0500
In-Reply-To: <1481266096-23331-1-git-send-email-selvin.xavier@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch exports some of the FW debug counters

Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
Signed-off-by: Devesh Sharma <devesh.sharma@broadcom.com>
Signed-off-by: Somnath Kotur <somnath.kotur@broadcom.com>
Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Signed-off-by: Selvin Xavier <selvin.xavier@broadcom.com>
---
 drivers/infiniband/hw/bnxtre/bnxt_re_debugfs.c | 159 +++++++++++++++++++++++++
 drivers/infiniband/hw/bnxtre/bnxt_re_debugfs.h |  48 ++++++++
 drivers/infiniband/hw/bnxtre/bnxt_re_main.c    |   8 +-
 3 files changed, 213 insertions(+), 2 deletions(-)
 create mode 100644 drivers/infiniband/hw/bnxtre/bnxt_re_debugfs.c
 create mode 100644 drivers/infiniband/hw/bnxtre/bnxt_re_debugfs.h

diff --git a/drivers/infiniband/hw/bnxtre/bnxt_re_debugfs.c b/drivers/infiniband/hw/bnxtre/bnxt_re_debugfs.c
new file mode 100644
index 0000000..b38c83a
--- /dev/null
+++ b/drivers/infiniband/hw/bnxtre/bnxt_re_debugfs.c
@@ -0,0 +1,159 @@
+/*
+ * Broadcom NetXtreme-E RoCE driver.
+ *
+ * Copyright (c) 2016, Broadcom. All rights reserved.  The term
+ * Broadcom refers to Broadcom Limited and/or its subsidiaries.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * BSD license below:
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ *
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in
+ *    the documentation and/or other materials provided with the
+ *    distribution.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS''
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
+ * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
+ * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS
+ * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
+ * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
+ * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
+ * IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ * Description: DebugFS specifics
+ */
+
+#include <linux/module.h>
+#include <linux/interrupt.h>
+#include <linux/debugfs.h>
+#include <linux/seq_file.h>
+#include <linux/netdevice.h>
+
+#include <rdma/ib_verbs.h>
+#include "bnxt_re_hsi.h"
+#include "bnxt_ulp.h"
+#include "bnxt_qplib_res.h"
+#include "bnxt_qplib_sp.h"
+#include "bnxt_qplib_fp.h"
+#include "bnxt_qplib_rcfw.h"
+
+#include "bnxt_re.h"
+#include "bnxt_re_debugfs.h"
+
+static struct dentry *bnxt_re_debugfs_root;
+static struct dentry *bnxt_re_debugfs_info;
+
+static ssize_t bnxt_re_debugfs_clear(struct file *fil, const char __user *u,
+				     size_t size, loff_t *off)
+{
+	return size;
+}
+
+static int bnxt_re_debugfs_show(struct seq_file *s, void *unused)
+{
+	struct bnxt_re_dev *rdev;
+
+	seq_puts(s, "bnxt_re debug info:\n");
+
+	mutex_lock(&bnxt_re_dev_lock);
+	list_for_each_entry(rdev, &bnxt_re_dev_list, list) {
+		struct ctx_hw_stats *stats = rdev->qplib_ctx.stats.dma;
+
+		seq_printf(s, "=====[ IBDEV %s ]=============================\n",
+			   rdev->ibdev.name);
+		if (rdev->netdev)
+			seq_printf(s, "\tlink state: %s\n",
+				   test_bit(__LINK_STATE_START,
+					    &rdev->netdev->state) ?
+				   (test_bit(__LINK_STATE_NOCARRIER,
+					     &rdev->netdev->state) ?
+				    "DOWN" : "UP") : "DOWN");
+		seq_printf(s, "\tMax QP: 0x%x\n", rdev->dev_attr.max_qp);
+		seq_printf(s, "\tMax SRQ: 0x%x\n", rdev->dev_attr.max_srq);
+		seq_printf(s, "\tMax CQ: 0x%x\n", rdev->dev_attr.max_cq);
+		seq_printf(s, "\tMax MR: 0x%x\n", rdev->dev_attr.max_mr);
+		seq_printf(s, "\tMax MW: 0x%x\n", rdev->dev_attr.max_mw);
+
+		seq_printf(s, "\tActive QP: %d\n",
+			   atomic_read(&rdev->qp_count));
+		seq_printf(s, "\tActive SRQ: %d\n",
+			   atomic_read(&rdev->srq_count));
+		seq_printf(s, "\tActive CQ: %d\n",
+			   atomic_read(&rdev->cq_count));
+		seq_printf(s, "\tActive MR: %d\n",
+			   atomic_read(&rdev->mr_count));
+		seq_printf(s, "\tActive MW: %d\n",
+			   atomic_read(&rdev->mw_count));
+		seq_printf(s, "\tRx Pkts: %lld\n",
+			   stats ? stats->rx_ucast_pkts : 0);
+		seq_printf(s, "\tRx Bytes: %lld\n",
+			   stats ? stats->rx_ucast_bytes : 0);
+		seq_printf(s, "\tTx Pkts: %lld\n",
+			   stats ? stats->tx_ucast_pkts : 0);
+		seq_printf(s, "\tTx Bytes: %lld\n",
+			   stats ? stats->tx_ucast_bytes : 0);
+		seq_printf(s, "\tRecoverable Errors: %lld\n",
+			   stats ? stats->tx_bcast_pkts : 0);
+		seq_puts(s, "\n");
+	}
+	mutex_unlock(&bnxt_re_dev_lock);
+	return 0;
+}
+
+static int bnxt_re_debugfs_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, bnxt_re_debugfs_show, NULL);
+}
+
+static int bnxt_re_debugfs_release(struct inode *inode, struct file *file)
+{
+	return single_release(inode, file);
+}
+
+static const struct file_operations bnxt_re_dbg_ops = {
+	.owner		= THIS_MODULE,
+	.open		= bnxt_re_debugfs_open,
+	.read		= seq_read,
+	.write		= bnxt_re_debugfs_clear,
+	.llseek		= seq_lseek,
+	.release	= bnxt_re_debugfs_release,
+};
+
+void bnxt_re_debugfs_remove(void)
+{
+	debugfs_remove_recursive(bnxt_re_debugfs_root);
+	bnxt_re_debugfs_root = NULL;
+}
+
+void bnxt_re_debugfs_init(void)
+{
+	bnxt_re_debugfs_root = debugfs_create_dir(ROCE_DRV_MODULE_NAME, NULL);
+	if (IS_ERR_OR_NULL(bnxt_re_debugfs_root)) {
+		dev_dbg(NULL, "%s: Unable to create debugfs root directory ",
+			ROCE_DRV_MODULE_NAME);
+		dev_dbg(NULL, "with err 0x%lx", PTR_ERR(bnxt_re_debugfs_root));
+		return;
+	}
+	bnxt_re_debugfs_info = debugfs_create_file("info", 0400,
+						   bnxt_re_debugfs_root, NULL,
+						   &bnxt_re_dbg_ops);
+	if (IS_ERR_OR_NULL(bnxt_re_debugfs_info)) {
+		dev_dbg(NULL, "%s: Unable to create debugfs info node ",
+			ROCE_DRV_MODULE_NAME);
+		dev_dbg(NULL, "with err 0x%lx", PTR_ERR(bnxt_re_debugfs_info));
+		bnxt_re_debugfs_remove();
+	}
+}
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_re_debugfs.h b/drivers/infiniband/hw/bnxtre/bnxt_re_debugfs.h
new file mode 100644
index 0000000..06ba5cd
--- /dev/null
+++ b/drivers/infiniband/hw/bnxtre/bnxt_re_debugfs.h
@@ -0,0 +1,48 @@
+/*
+ * Broadcom NetXtreme-E RoCE driver.
+ *
+ * Copyright (c) 2016, Broadcom. All rights reserved.  The term
+ * Broadcom refers to Broadcom Limited and/or its subsidiaries.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * BSD license below:
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ *
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in
+ *    the documentation and/or other materials provided with the
+ *    distribution.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS''
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
+ * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
+ * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS
+ * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
+ * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
+ * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
+ * IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ * Description: DebugFS header
+ */
+
+#ifndef __BNXT_RE_DEBUGFS__
+#define __BNXT_RE_DEBUGFS__
+
+extern struct list_head bnxt_re_dev_list;
+extern struct mutex bnxt_re_dev_lock;
+
+void bnxt_re_debugfs_init(void);
+void bnxt_re_debugfs_remove(void);
+
+#endif
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_re_main.c b/drivers/infiniband/hw/bnxtre/bnxt_re_main.c
index f3ce02c..3b3a063 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_re_main.c
+++ b/drivers/infiniband/hw/bnxtre/bnxt_re_main.c
@@ -60,6 +60,7 @@
 #include "bnxt_qplib_fp.h"
 #include "bnxt_qplib_rcfw.h"
 #include "bnxt_re.h"
+#include "bnxt_re_debugfs.h"
 #include "bnxt_re_ib_verbs.h"
 #include "bnxt.h"
 static char version[] =
@@ -72,8 +73,8 @@ MODULE_LICENSE("Dual BSD/GPL");
 MODULE_VERSION(ROCE_DRV_MODULE_VERSION);
 
 /* globals */
-static struct list_head bnxt_re_dev_list = LIST_HEAD_INIT(bnxt_re_dev_list);
-static DEFINE_MUTEX(bnxt_re_dev_lock);
+struct list_head bnxt_re_dev_list = LIST_HEAD_INIT(bnxt_re_dev_list);
+DEFINE_MUTEX(bnxt_re_dev_lock);
 static struct workqueue_struct *bnxt_re_wq;
 
 /* for handling bnxt_en callbacks later */
@@ -1264,6 +1265,7 @@ static int __init bnxt_re_mod_init(void)
 	if (!bnxt_re_wq)
 		return -ENOMEM;
 
+	bnxt_re_debugfs_init();
 	INIT_LIST_HEAD(&bnxt_re_dev_list);
 
 	rc = register_netdevice_notifier(&bnxt_re_netdev_notifier);
@@ -1275,6 +1277,7 @@ static int __init bnxt_re_mod_init(void)
 	return 0;
 
 err_netdev:
+	bnxt_re_debugfs_remove();
 	destroy_workqueue(bnxt_re_wq);
 
 	return rc;
@@ -1282,6 +1285,7 @@ static int __init bnxt_re_mod_init(void)
 static void __exit bnxt_re_mod_exit(void)
 {
 	unregister_netdevice_notifier(&bnxt_re_netdev_notifier);
+	bnxt_re_debugfs_remove();
 	if (bnxt_re_wq)
 		destroy_workqueue(bnxt_re_wq);
 }
-- 
2.5.5
