From: Ravi Patel <rapatel@apm.com>
Subject: [PATCH V3 3/4] mailbox: xgene: base driver for APM X-Gene SoC QMTM
Date: Fri, 14 Feb 2014 18:22:01 -0800
Message-ID: <1392430922-24643-4-git-send-email-rapatel@apm.com>
References: <1392430922-24643-1-git-send-email-rapatel@apm.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	jcm@redhat.com, patches@apm.com, Ravi Patel <rapatel@apm.com>,
	Keyur Chudgar <kchudgar@apm.com>
To: arnd@arndb.de, gregkh@linuxfoundation.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392430922-24643-1-git-send-email-rapatel@apm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds APM X-Gene SoC Queue Manager/Traffic Manager base driver.
QMTM is requried by Ethernet, PktDMA (XOR Engine) and Security subsystems.

Signed-off-by: Ravi Patel <rapatel@apm.com>
Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
---
 MAINTAINERS                              |    9 +
 drivers/mailbox/Kconfig                  |    2 +
 drivers/mailbox/Makefile                 |    1 +
 drivers/mailbox/xgene/Kconfig            |    9 +
 drivers/mailbox/xgene/Makefile           |    7 +
 drivers/mailbox/xgene/xgene_qmtm_main.c  |  516 ++++++++++++++++++++++++++++++
 drivers/mailbox/xgene/xgene_qmtm_main.h  |  112 +++++++
 drivers/mailbox/xgene/xgene_qmtm_storm.c |  358 +++++++++++++++++++++
 include/linux/platform_data/xgene_qmtm.h |  300 +++++++++++++++++
 9 files changed, 1314 insertions(+)
 create mode 100644 drivers/mailbox/xgene/Kconfig
 create mode 100644 drivers/mailbox/xgene/Makefile
 create mode 100644 drivers/mailbox/xgene/xgene_qmtm_main.c
 create mode 100644 drivers/mailbox/xgene/xgene_qmtm_main.h
 create mode 100644 drivers/mailbox/xgene/xgene_qmtm_storm.c
 create mode 100644 include/linux/platform_data/xgene_qmtm.h

diff --git a/MAINTAINERS b/MAINTAINERS
index 2507f38..3e09f39 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -678,6 +678,15 @@ S:	Maintained
 F:	drivers/net/appletalk/
 F:	net/appletalk/
 
+APPLIEDMICRO (APM) X-GENE SOC QUEUE MANAGER/TRAFFIC MANAGER (QMTM) DRIVER
+M:	Ravi Patel <rapatel@apm.com>
+M:	Keyur Chudgar <kchudgar@apm.com>
+S:	Maintained
+F:	drivers/mailbox/xgene/
+F:	include/linux/platform_data/xgene_qmtm.h
+F:	Documentation/devicetree/bindings/mailbox/apm-xgene-qmtm.txt
+F:	Documentation/mailbox/apm-xgene-qmtm
+
 APTINA CAMERA SENSOR PLL
 M:	Laurent Pinchart <Laurent.pinchart@ideasonboard.com>
 L:	linux-media@vger.kernel.org
diff --git a/drivers/mailbox/Kconfig b/drivers/mailbox/Kconfig
index c8b5c13..52653d4 100644
--- a/drivers/mailbox/Kconfig
+++ b/drivers/mailbox/Kconfig
@@ -50,4 +50,6 @@ config OMAP_MBOX_KFIFO_SIZE
 	  Specify the default size of mailbox's kfifo buffers (bytes).
 	  This can also be changed at runtime (via the mbox_kfifo_size
 	  module parameter).
+
+source "drivers/mailbox/xgene/Kconfig"
 endif
diff --git a/drivers/mailbox/Makefile b/drivers/mailbox/Makefile
index e0facb3..6faee7e 100644
--- a/drivers/mailbox/Makefile
+++ b/drivers/mailbox/Makefile
@@ -5,3 +5,4 @@ obj-$(CONFIG_OMAP1_MBOX)	+= mailbox_omap1.o
 mailbox_omap1-objs		:= mailbox-omap1.o
 obj-$(CONFIG_OMAP2PLUS_MBOX)	+= mailbox_omap2.o
 mailbox_omap2-objs		:= mailbox-omap2.o
+obj-$(CONFIG_XGENE_MBOX)	+= xgene/
diff --git a/drivers/mailbox/xgene/Kconfig b/drivers/mailbox/xgene/Kconfig
new file mode 100644
index 0000000..0843303
--- /dev/null
+++ b/drivers/mailbox/xgene/Kconfig
@@ -0,0 +1,9 @@
+config XGENE_MBOX
+	tristate "APM X-Gene Queue Manager/Traffic Manager Mailbox"
+	depends on ARM64 || COMPILE_TEST
+	default y
+	help
+	  This option enables APM X-Gene Queue Manager Traffic Manager (QMTM)
+	  mailbox support.
+	  QMTM is required for Ethernet, PktDMA (XOR Engine) and Security
+	  Engine.
diff --git a/drivers/mailbox/xgene/Makefile b/drivers/mailbox/xgene/Makefile
new file mode 100644
index 0000000..574e1b8
--- /dev/null
+++ b/drivers/mailbox/xgene/Makefile
@@ -0,0 +1,7 @@
+#
+# Makefile for APM X-GENE Queue Manager Traffic Manager mailbox
+#
+
+obj-$(CONFIG_XGENE_MBOX) += xgene-qmtm.o
+
+xgene-qmtm-objs := xgene_qmtm_main.o xgene_qmtm_storm.o
diff --git a/drivers/mailbox/xgene/xgene_qmtm_main.c b/drivers/mailbox/xgene/xgene_qmtm_main.c
new file mode 100644
index 0000000..bc50cd9
--- /dev/null
+++ b/drivers/mailbox/xgene/xgene_qmtm_main.c
@@ -0,0 +1,516 @@
+/*
+ * AppliedMicro X-Gene SoC Queue Manager/Traffic Manager driver
+ *
+ * Copyright (c) 2013 Applied Micro Circuits Corporation.
+ * Author: Ravi Patel <rapatel@apm.com>
+ *         Keyur Chudgar <kchudgar@apm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published by
+ * the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ */
+
+#include <linux/module.h>
+#include <linux/io.h>
+#include <linux/clk.h>
+#include <linux/delay.h>
+#include <linux/slab.h>
+#include <linux/dma-mapping.h>
+#include "xgene_qmtm_main.h"
+
+#define XGENE_QMTM_DRIVER_VER	"1.0"
+#define XGENE_QMTM_DRIVER_NAME	"xgene-qmtm"
+#define XGENE_QMTM_DRIVER_DESC	"APM X-Gene QMTM driver"
+
+/* CSR Address Macros */
+#define CSR_QM_CONFIG_ADDR	0x00000004
+#define  QM_ENABLE_WR(src)	(((u32)(src)<<31) & 0x80000000)
+
+#define CSR_PBM_ADDR		0x00000008
+#define  OVERWRITE_WR(src)	(((u32)(src)<<31) & 0x80000000)
+#define  SLVID_PBN_WR(src)	(((u32)(src)) & 0x000003ff)
+
+#define CSR_PBM_BUF_WR_ADDR	0x0000000c
+#define CSR_PBM_BUF_RD_ADDR	0x00000010
+#define  PB_SIZE_WR(src)	(((u32)(src)<<31) & 0x80000000)
+#define  PREFETCH_BUF_EN_SET(dst, src) \
+	(((dst) & ~0x00200000) | (((u32)(src)<<21) & 0x00200000))
+#define  IS_FREE_POOL_SET(dst, src) \
+	(((dst) & ~0x00100000) | (((u32)(src)<<20) & 0x00100000))
+#define  TLVQ_SET(dst, src) \
+	(((dst) & ~0x00080000) | (((u32)(src)<<19) & 0x00080000))
+#define  CORRESPONDING_QNUM_SET(dst, src) \
+	(((dst) & ~0x0007fe00) | (((u32)(src)<<9) & 0x0007fe00))
+
+#define CSR_THRESHOLD0_SET1_ADDR	0x00000030
+#define CSR_THRESHOLD1_SET1_ADDR	0x00000034
+#define CSR_HYSTERESIS_ADDR		0x00000068
+#define CSR_QM_MBOX_NE_INT_MODE_ADDR	0x0000017c
+#define CSR_QMLITE_PBN_MAP_0_ADDR	0x00000228
+
+#define CSR_RECOMB_CTRL_0_ADDR		0x00000230
+#define  RECOMB_EN0_SET(dst, src) \
+	(((dst) & ~0x00000001) | (((u32)(src)) & 0x00000001))
+
+/* QMTM Diag CSR */
+#define QM_GLBL_DIAG_CSR_BASE_ADDR_OFFSET	0xd000
+#define QM_CFG_MEM_RAM_SHUTDOWN_ADDR		0x00000070
+#define QM_CFG_MEM_RAM_SHUTDOWN_DEFAULT		0xffffffff
+
+static struct of_device_id xgene_qmtm_match[] = {
+	{
+		.compatible = "apm,xgene-qmtm",
+		.data = &storm_qmtm_ops,
+	},
+	{}
+};
+MODULE_DEVICE_TABLE(of, xgene_qmtm_match);
+
+void xgene_qmtm_wr32(struct xgene_qmtm *qmtm, u32 offset, u32 data)
+{
+	writel(data, qmtm->csr_vaddr + offset);
+}
+
+void xgene_qmtm_rd32(struct xgene_qmtm *qmtm, u32 offset, u32 *data)
+{
+	*data = readl(qmtm->csr_vaddr + offset);
+}
+
+static void xgene_qmtm_pbm_get(struct xgene_mbox *mbox)
+{
+	u16 is_fp = QMTM_QTYPE_FP(mbox);
+	u16 is_vq = QMTM_QTYPE_VQ(mbox);
+	u32 val = 0;
+	u32 pbm = SLVID_PBN_WR(mbox->pbm) | OVERWRITE_WR(1);
+
+	if (mbox->qmtm->qmtm_ip == QMTM0 || mbox->qmtm->qmtm_ip == QMTM2)
+		val |= PB_SIZE_WR(1);
+
+	val = CORRESPONDING_QNUM_SET(val, mbox->qid);
+	val = IS_FREE_POOL_SET(val, is_fp);
+	val = TLVQ_SET(val, is_vq);
+	val = PREFETCH_BUF_EN_SET(val, 1);
+	xgene_qmtm_wr32(mbox->qmtm, CSR_PBM_ADDR, pbm);
+	xgene_qmtm_wr32(mbox->qmtm, CSR_PBM_BUF_WR_ADDR, val);
+}
+
+static void xgene_qmtm_pbm_put(struct xgene_mbox *mbox)
+{
+	u32 pbm = SLVID_PBN_WR(mbox->pbm) | OVERWRITE_WR(1);
+	xgene_qmtm_wr32(mbox->qmtm, CSR_PBM_ADDR, pbm);
+	xgene_qmtm_wr32(mbox->qmtm, CSR_PBM_BUF_WR_ADDR, 0);
+}
+
+/**
+ * xgene_mbox_get - Create and configure a queue
+ * @dev: device that requests this queue
+ * @s: the queue name string as given in the dt data
+ *
+ * This API will be called by APM X-Gene SoC Ethernet, PktDMA (XOR Engine),
+ * and Security Engine subsystems to create and configure a queue.
+ *
+ * Returns the mbox associated with the given phandle value,
+ * after getting a refcount to it, -ENODEV if there is no such queue,
+ * -ENOMEM if out of memory or -EINVAL for other error conditions.
+ * The caller is responsible for calling xgene_mbox_put() to release
+ * that count.
+ */
+struct xgene_mbox *xgene_mbox_get(struct device *dev, const char *s)
+{
+	struct module *module = THIS_MODULE;
+	struct xgene_mbox *mbox = ERR_PTR(-EINVAL);
+	struct xgene_qmtm *qmtm;
+	int ret;
+	struct of_phandle_args args;
+	u64 qfabric_paddr;
+	u32 qsize = 0;
+	u16 qid = 0;
+	u8 cfgqsize;
+
+	if (!dev->of_node) {
+		dev_err(dev, "Invalid device tree\n");
+		goto _err_mbox_get;
+	}
+
+	ret = of_property_match_string(dev->of_node, "mailbox-names", s);
+	if (ret < 0) {
+		mbox = ERR_PTR(-ENODEV);
+		goto _err_mbox_get;
+	}
+
+	memset(&args, 0, sizeof(args));
+	ret = of_parse_phandle_with_args(dev->of_node, "mailboxes",
+			"#mailbox-cells", ret, &args);
+	if (ret || !args.np) {
+		dev_err(dev, "failed to get mailbox in %s node\n",
+				dev->of_node->full_name);
+		goto _err_mbox_get;
+	}
+
+	if (!try_module_get(module))
+		goto _err_mbox_get;
+
+	qmtm = platform_get_drvdata(of_find_device_by_node(args.np));
+	if (qmtm == NULL) {
+		dev_err(dev, "failed to get QMTM for %s node\n",
+				dev->of_node->full_name);
+		goto _module_put;
+	}
+
+	qfabric_paddr = ((u64)args.args[0] << 32) | args.args[1];
+	if (qfabric_paddr > (qmtm->fabric_paddr |
+				((u64)(QMTM_MAX_QUEUES - 1) << 6)) ||
+			qfabric_paddr < qmtm->fabric_paddr) {
+		dev_err(dev, "Invalid qfabric address for %s node\n",
+				dev->of_node->full_name);
+		goto _module_put;
+	}
+	qid = (qfabric_paddr - qmtm->fabric_paddr) >> 6;
+
+	qsize = args.args[2];
+	switch (qsize) {
+	case 0x00200:
+		cfgqsize = QSIZE_512B;
+		break;
+	case 0x00800:
+		cfgqsize = QSIZE_2KB;
+		break;
+	case 0x04000:
+		cfgqsize = QSIZE_16KB;
+		break;
+	case 0x10000:
+		cfgqsize = QSIZE_64KB;
+		break;
+	case 0x80000:
+		cfgqsize = QSIZE_512KB;
+		break;
+	default:
+		dev_err(dev, "Unsupported queue size %d\n", qsize);
+		goto _module_put;
+	}
+
+	mbox = kzalloc(sizeof(struct xgene_mbox), GFP_KERNEL);
+	if (mbox == NULL) {
+		dev_err(dev, "Unable to allocate mbox\n");
+		goto _module_put;
+	}
+
+	mbox->qaddr = dma_zalloc_coherent(&qmtm->pdev->dev, qsize,
+		&mbox->dma, GFP_KERNEL);
+	if (mbox->qaddr == NULL) {
+		dev_err(dev, "Unable to allocate qaddr\n");
+		kfree(mbox);
+		mbox = NULL;
+		goto _module_put;
+	}
+	mbox->qsize = qsize;
+	mbox->pbm = args.args[3];
+	mbox->qid = qid;
+	mbox->slots = cfgqsize;
+	mbox->qfabric = qmtm->fabric_vaddr + (qid << 6);
+	mbox->level = mbox->qfabric + 0x2C;
+	mbox->qmtm = qmtm;
+	qmtm->ops.set_qstate(mbox);
+	xgene_qmtm_pbm_get(mbox);
+	mbox->slots = QMTM_QTYPE_FP(mbox) ? qsize / 16 : qsize / 32;
+	mbox->qstate[6] = qmtm->qmtm_ip;
+
+	if (QMTM_SLAVE_ID(mbox) == QMTM_SLAVE_ID_CPU &&
+			!QMTM_QTYPE_FP(mbox) &&
+			!QMTM_QTYPE_VQ(mbox)) {
+		u32 s, data;
+		for (s = 0; s < mbox->slots; s++) {
+			u32 *slot = (u32 *)&mbox->msg32[s];
+			slot[EMPTY_SLOT_INDEX] = EMPTY_SLOT;
+		}
+		xgene_qmtm_rd32(qmtm, CSR_QM_MBOX_NE_INT_MODE_ADDR, &data);
+		data |= (u32) (1 << (31 - QMTM_PBN(mbox)));
+		xgene_qmtm_wr32(qmtm, CSR_QM_MBOX_NE_INT_MODE_ADDR, data);
+		mbox->irq = qmtm->dequeue_irq[QMTM_PBN(mbox)];
+	}
+
+	qmtm->mbox[qid] = mbox;
+	return mbox;
+
+_module_put:
+	module_put(module);
+
+_err_mbox_get:
+	return mbox;
+}
+EXPORT_SYMBOL_GPL(xgene_mbox_get);
+
+/**
+ * xgene_mbox_put - Unconfigure and delete a queue
+ * @mbox: the mbox returned by xgene_mbox_get()
+ *
+ * This API will be called by APM X-Gene SoC Ethernet, PktDMA (XOR Engine),
+ * and Security Engine subsystems to unconfigure and delete a queue.
+ *
+ * Releases a refcount the caller received from xgene_mbox_get().
+ */
+void xgene_mbox_put(struct xgene_mbox *mbox)
+{
+	struct xgene_qmtm *qmtm = mbox->qmtm;
+	struct module *module = THIS_MODULE;
+
+	if (QMTM_SLAVE_ID(mbox) == QMTM_SLAVE_ID_CPU &&
+			!QMTM_QTYPE_FP(mbox) &&
+			!QMTM_QTYPE_VQ(mbox)) {
+		u32 data;
+		xgene_qmtm_rd32(qmtm, CSR_QM_MBOX_NE_INT_MODE_ADDR, &data);
+		data &= ~(u32) (1 << (31 - QMTM_PBN(mbox)));
+		xgene_qmtm_wr32(qmtm, CSR_QM_MBOX_NE_INT_MODE_ADDR, data);
+	}
+
+	xgene_qmtm_pbm_put(mbox);
+	qmtm->ops.clr_qstate(mbox);
+	dma_free_coherent(&qmtm->pdev->dev, mbox->qsize,
+		mbox->qaddr, mbox->dma);
+	qmtm->mbox[mbox->qid] = NULL;
+	kfree(mbox);
+	module_put(module);
+}
+EXPORT_SYMBOL_GPL(xgene_mbox_put);
+
+/**
+ * xgene_mbox_level - Read number of message in queue
+ * @mbox: read number of message for mbox
+ *
+ * This API will be called by APM X-Gene SoC Ethernet, PktDMA (XOR Engine),
+ * and Security Engine subsystems to read number of message for mbox.
+ *
+ * Returns number of messages in mbox
+ */
+u32 xgene_mbox_level(struct xgene_mbox *mbox)
+{
+	return mbox->qmtm->ops.read_level(mbox->qfabric);
+}
+EXPORT_SYMBOL_GPL(xgene_mbox_level);
+
+static int xgene_qmtm_enable(struct xgene_qmtm *qmtm)
+{
+	struct xgene_mbox mbox;
+	struct device *dev = &qmtm->pdev->dev;
+	int rc, mwait = 0, inum = 1;
+	u32 val;
+	u32 qid;
+
+	qmtm->clk = devm_clk_get(dev, NULL);
+	if (IS_ERR(qmtm->clk)) {
+		dev_err(dev, "can't get clock\n");
+		return PTR_ERR(qmtm->clk);
+	}
+
+	rc = clk_prepare_enable(qmtm->clk);
+	if (rc < 0) {
+		dev_err(dev, "clock prepare enable failed\n");
+		return rc;
+	}
+
+	xgene_qmtm_wr32(qmtm, QM_GLBL_DIAG_CSR_BASE_ADDR_OFFSET +
+			QM_CFG_MEM_RAM_SHUTDOWN_ADDR, 0);
+	do {
+		/* Wait for Memory to come out of shutdown */
+		usleep_range(1000, 2000);
+		xgene_qmtm_rd32(qmtm, QM_GLBL_DIAG_CSR_BASE_ADDR_OFFSET +
+				QM_CFG_MEM_RAM_SHUTDOWN_ADDR, &val);
+
+		if (mwait++ >= 1000) {
+			rc = -EIO;
+			dev_err(dev, "RAM not out of shutdown %d\n", rc);
+			clk_disable_unprepare(qmtm->clk);
+			return rc;
+		}
+	} while (val == QM_CFG_MEM_RAM_SHUTDOWN_DEFAULT);
+
+	rc = qmtm->ops.init(qmtm);
+	if (rc < 0) {
+		dev_err(dev, "not supported on your system\n");
+		return rc;
+	}
+
+	for (inum = qmtm->irq_start; inum < (qmtm->irq_start +
+				qmtm->irq_count); inum++) {
+		int irq = platform_get_irq(qmtm->pdev,
+			inum - qmtm->irq_start + 1);
+		if (irq < 0) {
+			dev_err(dev, "Failed to map QMTM%d PBN %d IRQ\n",
+				qmtm->qmtm_ip, inum);
+			continue;
+		}
+		qmtm->dequeue_irq[inum] = irq;
+	}
+
+	switch (qmtm->qmtm_ip) {
+	case QMTM0:
+	case QMTM2:
+		xgene_qmtm_rd32(qmtm, CSR_RECOMB_CTRL_0_ADDR, &val);
+		val = RECOMB_EN0_SET(val, 1);
+		xgene_qmtm_wr32(qmtm, CSR_RECOMB_CTRL_0_ADDR, val);
+		break;
+	case QMTM3:
+		xgene_qmtm_wr32(qmtm, CSR_QMLITE_PBN_MAP_0_ADDR, 0x00000000);
+	}
+
+	/* program threshold set 1 and all hysteresis */
+	xgene_qmtm_wr32(qmtm, CSR_THRESHOLD0_SET1_ADDR, 100);
+	xgene_qmtm_wr32(qmtm, CSR_THRESHOLD1_SET1_ADDR, 200);
+	xgene_qmtm_wr32(qmtm, CSR_HYSTERESIS_ADDR, 0xFFFFFFFF);
+
+	/* Enable QPcore */
+	xgene_qmtm_wr32(qmtm, CSR_QM_CONFIG_ADDR, QM_ENABLE_WR(1));
+
+	/* Clear all HW queue state in case they were not de-activated */
+	memset(&mbox, 0, sizeof(mbox));
+	mbox.qmtm = qmtm;
+
+	for (qid = 0; qid < QMTM_MAX_QUEUES; qid++) {
+		mbox.qid = qid;
+		qmtm->ops.clr_qstate(&mbox);
+	}
+
+	return rc;
+}
+
+static int xgene_qmtm_disable(struct xgene_qmtm *qmtm)
+{
+	u32 qid;
+
+	for (qid = 0; qid < QMTM_MAX_QUEUES; qid++) {
+		if (qmtm->mbox[qid]) {
+			dev_err(&qmtm->pdev->dev,
+				"QMTM %d Queue ID %d Resource in use\n",
+				qmtm->qmtm_ip, qid);
+			return -EAGAIN;
+		}
+	}
+
+	/* Disable QPcore */
+	xgene_qmtm_wr32(qmtm, CSR_QM_CONFIG_ADDR, QM_ENABLE_WR(0));
+	clk_disable_unprepare(qmtm->clk);
+
+	return 0;
+}
+
+static struct xgene_qmtm *xgene_alloc_qmtm(struct platform_device *pdev)
+{
+	struct xgene_qmtm *qmtm;
+
+	qmtm = devm_kzalloc(&pdev->dev, sizeof(struct xgene_qmtm), GFP_KERNEL);
+	if (qmtm == NULL) {
+		dev_err(&pdev->dev, "Unable to allocate QMTM context\n");
+		return NULL;
+	}
+
+	qmtm->pdev = pdev;
+	platform_set_drvdata(pdev, qmtm);
+	qmtm->mbox = devm_kzalloc(&pdev->dev,
+		QMTM_MAX_QUEUES * (sizeof(struct xgene_qmtm_info *)),
+		GFP_KERNEL);
+	if (qmtm->mbox == NULL) {
+		dev_err(&pdev->dev, "Unable to allocate QMTM Queue context\n");
+		return NULL;
+	}
+
+	return qmtm;
+}
+
+static int xgene_get_qmtm(struct xgene_qmtm *qmtm)
+{
+	struct platform_device *pdev = qmtm->pdev;
+	const struct of_device_id *match;
+	struct resource *res;
+
+	/* Get Match Table */
+	match = of_match_device(xgene_qmtm_match, &pdev->dev);
+	if (!match)
+		return -EINVAL;
+	memcpy(&qmtm->ops, match->data, sizeof(struct xgene_qmtm_ops));
+
+	/* Retrieve QM CSR register address and size */
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (!res) {
+		dev_err(&pdev->dev, "Failed to get QMTM CSR region\n");
+		return -ENODEV;
+	}
+
+	qmtm->csr_vaddr = devm_ioremap_resource(&pdev->dev, res);
+	if (IS_ERR(qmtm->csr_vaddr)) {
+		dev_err(&pdev->dev, "Invalid QMTM CSR region\n");
+		return PTR_ERR(qmtm->csr_vaddr);
+	}
+
+	/* Retrieve Primary Fabric address and size */
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
+	if (!res) {
+		dev_err(&pdev->dev, "Failed to get QMTM Fabric region\n");
+		return -ENODEV;
+	}
+
+	qmtm->fabric_vaddr = devm_ioremap_resource(&pdev->dev, res);
+	if (IS_ERR(qmtm->fabric_vaddr)) {
+		dev_err(&pdev->dev, "Invalid QMTM Fabric region\n");
+		return PTR_ERR(qmtm->fabric_vaddr);
+	}
+	qmtm->fabric_paddr = res->start;
+
+	if (dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(64)))
+		return dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(32));
+
+	return 0;
+}
+
+static int xgene_qmtm_probe(struct platform_device *pdev)
+{
+	struct xgene_qmtm *qmtm;
+	int rc;
+
+	qmtm = xgene_alloc_qmtm(pdev);
+	if (qmtm == NULL)
+		return -ENOMEM;
+
+	rc = xgene_get_qmtm(qmtm);
+	if (rc)
+		return rc;
+
+	return xgene_qmtm_enable(qmtm);
+}
+
+static int xgene_qmtm_remove(struct platform_device *pdev)
+{
+	struct xgene_qmtm *qmtm = platform_get_drvdata(pdev);
+	return xgene_qmtm_disable(qmtm);
+}
+
+static struct platform_driver xgene_qmtm_driver = {
+	.driver = {
+		   .name = XGENE_QMTM_DRIVER_NAME,
+		   .owner = THIS_MODULE,
+		   .of_match_table = xgene_qmtm_match,
+		   },
+	.probe = xgene_qmtm_probe,
+	.remove = xgene_qmtm_remove,
+};
+
+static int __init xgene_qmtm_init(void)
+{
+	return platform_driver_register(&xgene_qmtm_driver);
+}
+subsys_initcall(xgene_qmtm_init);
+
+static void __exit xgene_qmtm_exit(void)
+{
+	platform_driver_unregister(&xgene_qmtm_driver);
+}
+module_exit(xgene_qmtm_exit);
+
+MODULE_VERSION(XGENE_QMTM_DRIVER_VER);
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Ravi Patel <rapatel@apm.com>");
+MODULE_DESCRIPTION(XGENE_QMTM_DRIVER_DESC);
diff --git a/drivers/mailbox/xgene/xgene_qmtm_main.h b/drivers/mailbox/xgene/xgene_qmtm_main.h
new file mode 100644
index 0000000..1a9de03
--- /dev/null
+++ b/drivers/mailbox/xgene/xgene_qmtm_main.h
@@ -0,0 +1,112 @@
+/*
+ * AppliedMicro X-Gene SoC Queue Manager/Traffic Manager driver
+ *
+ * Copyright (c) 2013 Applied Micro Circuits Corporation.
+ * Author: Ravi Patel <rapatel@apm.com>
+ *         Keyur Chudgar <kchudgar@apm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published by
+ * the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ */
+
+#ifndef __XGENE_QMTM_MAIN_H__
+#define __XGENE_QMTM_MAIN_H__
+
+#include <linux/of_platform.h>
+#include <linux/platform_data/xgene_qmtm.h>
+
+/* QMTM IP Blocks */
+enum xgene_qmtm_ip {
+	QMTM0,
+	QMTM1,
+	QMTM2,
+	QMTM3,
+};
+
+#define QMTM_MAX_QUEUES	1024
+#define QMTM_MAX_PBN	32
+
+/* QMTM Queue types */
+enum xgene_qmtm_qtype {
+	QTYPE_DISABLED,		/* Queue Type is un-configured or disabled */
+	QTYPE_PQ,		/* Queue Type is Physical Work Queue */
+	QTYPE_FP,		/* Queue Type is Free Pool Queue */
+	QTYPE_VQ,		/* Queue Type is Virtual Queue */
+};
+
+/* QMTM Queue possible sizes */
+enum xgene_qmtm_qsize {
+	QSIZE_512B,
+	QSIZE_2KB,
+	QSIZE_16KB,
+	QSIZE_64KB,
+	QSIZE_512KB,
+	QSIZE_MAX,
+};
+
+struct xgene_qmtm_ops {
+	int (*init)(struct xgene_qmtm *qmtm);
+	void (*set_qstate)(struct xgene_mbox *mbox);
+	void (*clr_qstate)(struct xgene_mbox *mbox);
+	u32 (*read_level)(void *qfabric);
+};
+
+struct xgene_qmtm {
+	struct xgene_qmtm_ops ops;
+	void *csr_vaddr;
+	void *fabric_vaddr;
+	u64 fabric_paddr;
+	u16 qmtm_ip;		/* qmtm_ip, see xgene_qmtm_ip */
+	u16 irq_start;
+	u16 irq_count;
+	u16 error_irq;
+	u16 dequeue_irq[QMTM_MAX_PBN];
+	char error_irq_s[16];
+	char error_queue_irq_s[16];
+	struct xgene_mbox *(*mbox);
+	struct xgene_mbox *error_mbox;
+	struct clk *clk;
+	struct platform_device *pdev;
+};
+
+/* QMTM Slave IDs */
+enum xgene_qmtm_slave_id {
+	QMTM_SLAVE_ID_ETH0,
+	QMTM_SLAVE_ID_ETH1,
+	QMTM_SLAVE_ID_RES2,
+	QMTM_SLAVE_ID_PKTDMA,
+	QMTM_SLAVE_ID_CTX,
+	QMTM_SLAVE_ID_SEC,
+	QMTM_SLAVE_ID_CLASS,
+	QMTM_SLAVE_ID_MSLIM,
+	QMTM_SLAVE_ID_RES8,
+	QMTM_SLAVE_ID_RES9,
+	QMTM_SLAVE_ID_RESA,
+	QMTM_SLAVE_ID_RESB,
+	QMTM_SLAVE_ID_RESC,
+	QMTM_SLAVE_ID_PMPRO,
+	QMTM_SLAVE_ID_SMPRO,
+	QMTM_SLAVE_ID_CPU,
+	QMTM_SLAVE_ID_MAX,
+};
+
+/* QMTM Free Pool Queue modes */
+enum xgene_qmtm_fp_mode {
+	MSG_NO_CHANGE,
+	ROUND_ADDR,
+	REDUCE_LEN,
+	CHANGE_LEN,
+};
+
+extern struct xgene_qmtm_ops storm_qmtm_ops;
+/* QMTM CSR read/write routine */
+void xgene_qmtm_wr32(struct xgene_qmtm *qmtm, u32 offset, u32 data);
+void xgene_qmtm_rd32(struct xgene_qmtm *qmtm, u32 offset, u32 *data);
+
+#endif /* __XGENE_QMTM_MAIN_H__ */
diff --git a/drivers/mailbox/xgene/xgene_qmtm_storm.c b/drivers/mailbox/xgene/xgene_qmtm_storm.c
new file mode 100644
index 0000000..e214d28
--- /dev/null
+++ b/drivers/mailbox/xgene/xgene_qmtm_storm.c
@@ -0,0 +1,358 @@
+/**
+ * AppliedMicro X-Gene SOC Queue Manager/Traffic Manager driver
+ *
+ * Copyright (c) 2013 Applied Micro Circuits Corporation.
+ * Author: Ravi Patel <rapatel@apm.com>
+ *         Keyur Chudgar <kchudgar@apm.com>
+ *         Fushen Chen <fchen@apm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published by
+ * the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ */
+
+#include <linux/slab.h>
+#include "xgene_qmtm_main.h"
+
+#define CSR_IPBRR_ADDR		0x00000000
+#define CSR_IPBRR_QMTM0_DEFAULT	0x00000520
+#define CSR_IPBRR_QMTM1_DEFAULT	0x00000521
+#define CSR_IPBRR_QMTM2_DEFAULT	0x00000522
+#define CSR_IPBRR_QMTM3_DEFAULT	0x000005E0
+
+#define CSR_QSTATE_ADDR		0x0000006c
+#define QNUMBER_WR(src)		(((u32)(src)) & 0x000003ff)
+
+#define CSR_QSTATE_WR_0_ADDR	0x00000070
+#define CSR_QSTATE_WR_1_ADDR	0x00000074
+#define CSR_QSTATE_WR_2_ADDR	0x00000078
+#define CSR_QSTATE_WR_3_ADDR	0x0000007c
+#define CSR_QSTATE_WR_4_ADDR	0x00000080
+
+/* QMTM Queue State */
+struct storm_qmtm_csr_qstate {
+	u32 w0;
+	u32 w1;
+	u32 w2;
+	u32 w3;
+	u32 w4;
+} __packed;
+
+/*
+ * Physical or free pool queue state (pq or fp)
+ */
+struct storm_qmtm_pq_fp_qstate {
+#ifdef CONFIG_CPU_BIG_ENDIAN
+	/* register word 0 (bit 31:0) */
+	u32 cpu_notify:8;           /* 31:24 */
+	u32 cfgsaben:1;             /* 23 enable SAB broadcasting */
+	u32 cfgtmvq:10;             /* 22:13 parent vq */
+	u32 cfgtmvqen:1;            /* 12 enable pq to belong to vq */
+	u32 resize_done:1;          /* 11 */
+	u32 resize_start:1;         /* 10 */
+	u32 resize_qid:10;          /* 9:0 */
+
+	/* register word 1 (bit 63:32) */
+	u32 headptr:15;             /* 63:49 */
+	u32 nummsg:16;              /* 48:33 */
+	u32 cfgnotifyqne:1;         /* 32 enable Q not empty intr */
+
+	/* register word 2 (bit 95:64) */
+	u32 cfgstartaddrL:27;       /* 95:69 split 7/27 */
+	u32 qcoherent:1;            /* 68 */
+	u32 rid:3;                  /* 67:65 */
+	u32 cfgcrid:1;              /* 64 */
+
+	/* register word 3 (bit 127:96) */
+	u32 cfgRecombBufTimeoutL:4; /* 127:124 split 3/4 */
+	u32 cfgRecombBuf:1;         /* 123 */
+	u32 qstatelock:1;           /* 122 */
+	u32 cfgqsize:3;             /* 121:119 queue size */
+	u32 fp_mode:3;              /* 118:116 free pool mode */
+	u32 cfgacceptlerr:1;        /* 115 */
+	u32 reserved_0:1;           /* 114 */
+	u32 stashing:1;             /* 113 */
+	u32 slot_pending:8;         /* 112:105 */
+	u32 vc_chanid:2;            /* 104:103 */
+	u32 cfgstartaddrH:7;        /* 102:96 split 7/27 */
+
+	/* register word 4 (bit 159:128) */
+	u32 resv1:11;               /* 159:149 */
+	u32 cfgqtype:2;             /* 148:147 queue type */
+	u32 resv2:5;                /* 146:142 */
+	u32 half_64B_override:3;    /* 141:139 */
+	u32 resv3:4;                /* 138:135 */
+	u32 CfgSupressCmpl:1;       /* 134 */
+	u32 cfgselthrsh:3;          /* 133:131 associated threshold set */
+	u32 cfgRecombBufTimeoutH:3; /* 130:128 split 3/4 */
+#else
+	/* register word 0 (bit 31:0) */
+	u32 resize_qid:10;          /* 9:0 */
+	u32 resize_start:1;         /* 10 */
+	u32 resize_done:1;          /* 11 */
+	u32 cfgtmvqen:1;            /* 12 enable pq to belong to vq */
+	u32 cfgtmvq:10;             /* 22:13 parent vq */
+	u32 cfgsaben:1;             /* 23 enable SAB broadcasting */
+	u32 cpu_notify:8;           /* 31:24 */
+
+	/* register word 1 (bit 63:32) */
+	u32 cfgnotifyqne:1;         /* 32 enable Q not empty intr */
+	u32 nummsg:16;              /* 48:33 */
+	u32 headptr:15;             /* 63:49 */
+
+	/* register word 2 (bit 95:64) */
+	u32 cfgcrid:1;              /* 64 */
+	u32 rid:3;                  /* 67:65 */
+	u32 qcoherent:1;            /* 68 */
+	u32 cfgstartaddrL:27;       /* 95:69 split 7/27 */
+
+	/* register word 3 (bit 127:96) */
+	u32 cfgstartaddrH:7;        /* 102:96 split 7/27 */
+	u32 vc_chanid:2;            /* 104:103 */
+	u32 slot_pending:8;         /* 112:105 */
+	u32 stashing:1;             /* 113 */
+	u32 reserved_0:1;           /* 114 */
+	u32 cfgacceptlerr:1;        /* 115 */
+	u32 fp_mode:3;              /* 118:116 free pool mode */
+	u32 cfgqsize:3;             /* 121:119 queue size */
+	u32 qstatelock:1;           /* 122 */
+	u32 cfgRecombBuf:1;         /* 123 */
+	u32 cfgRecombBufTimeoutL:4; /* 127:124 split 3/4 */
+
+	/* register word 4 (bit 159:128) */
+	u32 cfgRecombBufTimeoutH:3; /* 130:128 split 3/4 */
+	u32 cfgselthrsh:3;          /* 133:131 associated threshold set */
+	u32 CfgSupressCmpl:1;       /* 134 */
+	u32 resv3:4;                /* 138:135 */
+	u32 half_64B_override:3;    /* 141:139 */
+	u32 resv2:5;                /* 146:142 */
+	u32 cfgqtype:2;             /* 148:147 queue type */
+	u32 resv1:11;               /* 159:149 */
+#endif
+} __packed;
+
+/*
+ * Virtual queue state (vq)
+ */
+struct storm_qmtm_vq_qstate {
+#ifdef CONFIG_CPU_BIG_ENDIAN
+	/* register word 0 (bit 31:0) */
+	u32 rid:3;          /* 31:29 */
+	u32 cpu_notify:8;   /* 28:21 */
+	u32 cfgcrid:1;      /* 20 critical rid config */
+	u32 cfgnotifyqne:1; /* 19 enable Q not empty intr */
+	u32 cfgsaben:1;     /* 18 enable SAB broadcasting */
+	u32 nummsg:18;      /* 17:0 */
+
+	/* register word 1 (bit 63:32) */
+	u32 q5reqvld:1;     /* 63 */
+	u32 q5txallowed:1;  /* 62 */
+	u32 q5selarb:2;     /* 61:60 */
+	u32 q6_sel:10;      /* 59:50 */
+	u32 q6reqvld:1;     /* 49 */
+	u32 q6txallowed:1;  /* 48 */
+	u32 q6selarb:2;     /* 47:46 */
+	u32 q7_sel:10;      /* 45:36 */
+	u32 q7reqvld:1;     /* 35 */
+	u32 q7txallowed:1;  /* 34 */
+	u32 q7selarb:2;     /* 33:32 */
+
+	/* register word 2 (bit 95:64) */
+	u32 q3_selL:4;      /* 95:92 split 4/6 */
+	u32 q3reqvld:1;     /* 91 */
+	u32 q3txallowed:1;  /* 90 */
+	u32 q3selarb:2;     /* 89:88 */
+	u32 q4_sel:10;      /* 87:78 */
+	u32 q4reqvld:1;     /* 77 */
+	u32 q4txallowed:1;  /* 76 */
+	u32 q4selarb:2;     /* 75:74 */
+	u32 q5_sel:10;      /* 73:64 */
+
+	/* register word 3 (bit 127:96) */
+	u32 q1_selL:8;      /* 127:120 split 2/8 */
+	u32 q1reqvld:1;     /* 119 */
+	u32 q1txallowed:1;  /* 118 */
+	u32 q1selarb:2;     /* 117:116 */
+	u32 q2_sel:10;      /* 115:106 */
+	u32 q2reqvld:1;     /* 105 */
+	u32 q2txallowed:1;  /* 104 */
+	u32 q2selarb:2;     /* 103:102 */
+	u32 q3_selH:6;      /* 101:96 split 4/6 */
+
+	/* register word 4 (bit 159:128) */
+	u32 resv1:11;       /* 159:149 */
+	u32 cfgqtype:2;     /* 148:147 queue type */
+	u32 cfgselthrsh:3;  /* 146:144 associated threshold set */
+	u32 q0_sel:10;      /* 143:134 */
+	u32 q0reqvld:1;     /* 133 */
+	u32 q0txallowed:1;  /* 132 */
+	u32 q0selarb:2;     /* 131:130 */
+	u32 q1_selH:2;      /* 129:128 split 2/8 */
+#else
+	/* register word 0 (bit 31:0) */
+	u32 nummsg:18;      /* 17:0 */
+	u32 cfgsaben:1;     /* 18 enable SAB broadcasting */
+	u32 cfgnotifyqne:1; /* 19 enable Q not empty intr */
+	u32 cfgcrid:1;      /* 20 critical rid config */
+	u32 cpu_notify:8;   /* 28:21 */
+	u32 rid:3;          /* 31:29 */
+
+	/* register word 1 (bit 63:32) */
+	u32 q7selarb:2;     /* 33:32 */
+	u32 q7txallowed:1;  /* 34 */
+	u32 q7reqvld:1;     /* 35 */
+	u32 q7_sel:10;      /* 45:36 */
+	u32 q6selarb:2;     /* 47:46 */
+	u32 q6txallowed:1;  /* 48 */
+	u32 q6reqvld:1;     /* 49 */
+	u32 q6_sel:10;      /* 59:50 */
+	u32 q5selarb:2;     /* 61:60 */
+	u32 q5txallowed:1;  /* 62 */
+	u32 q5reqvld:1;     /* 63 */
+
+	/* register word 2 (bit 95:64) */
+	u32 q5_sel:10;      /* 73:64 */
+	u32 q4selarb:2;     /* 75:74 */
+	u32 q4txallowed:1;  /* 76 */
+	u32 q4reqvld:1;     /* 77 */
+	u32 q4_sel:10;      /* 87:78 */
+	u32 q3selarb:2;     /* 89:88 */
+	u32 q3txallowed:1;  /* 90 */
+	u32 q3reqvld:1;     /* 91 */
+	u32 q3_selL:4;      /* 95:92 split 4/6 */
+
+	/* register word 3 (bit 127:96) */
+	u32 q3_selH:6;      /* 101:96 split 4/6 */
+	u32 q2selarb:2;     /* 103:102 */
+	u32 q2txallowed:1;  /* 104 */
+	u32 q2reqvld:1;     /* 105 */
+	u32 q2_sel:10;      /* 115:106 */
+	u32 q1selarb:2;     /* 117:116 */
+	u32 q1txallowed:1;  /* 118 */
+	u32 q1reqvld:1;     /* 119 */
+	u32 q1_selL:8;      /* 127:120 split 2/8 */
+
+	/* register word 4 (bit 159:128) */
+	u32 q1_selH:2;      /* 129:128 split 2/8 */
+	u32 q0selarb:2;     /* 131:130 */
+	u32 q0txallowed:1;  /* 132 */
+	u32 q0reqvld:1;     /* 133 */
+	u32 q0_sel:10;      /* 143:134 */
+	u32 cfgselthrsh:3;  /* 146:144 associated threshold set */
+	u32 cfgqtype:2;     /* 148:147 queue type */
+	u32 resv1:11;       /* 159:149 */
+#endif
+} __packed;
+
+union storm_qmtm_qstate {
+	struct storm_qmtm_csr_qstate csr;
+	struct storm_qmtm_pq_fp_qstate pq;
+	struct storm_qmtm_pq_fp_qstate fp;
+	struct storm_qmtm_vq_qstate vq;
+} __packed;
+
+/* Storm QMTM operations */
+static void storm_qmtm_write_qstate(struct xgene_mbox *mbox)
+{
+	struct xgene_qmtm *qmtm = mbox->qmtm;
+	struct storm_qmtm_csr_qstate *csr_qstate =
+	    &((union storm_qmtm_qstate *)mbox->qstate)->csr;
+
+	/* write queue number */
+	xgene_qmtm_wr32(qmtm, CSR_QSTATE_ADDR, QNUMBER_WR(mbox->qid));
+
+	/* write queue state */
+	xgene_qmtm_wr32(qmtm, CSR_QSTATE_WR_0_ADDR, csr_qstate->w0);
+	xgene_qmtm_wr32(qmtm, CSR_QSTATE_WR_1_ADDR, csr_qstate->w1);
+	xgene_qmtm_wr32(qmtm, CSR_QSTATE_WR_2_ADDR, csr_qstate->w2);
+	xgene_qmtm_wr32(qmtm, CSR_QSTATE_WR_3_ADDR, csr_qstate->w3);
+	xgene_qmtm_wr32(qmtm, CSR_QSTATE_WR_4_ADDR, csr_qstate->w4);
+}
+
+static void storm_qmtm_set_qstate(struct xgene_mbox *mbox)
+{
+	struct storm_qmtm_pq_fp_qstate *pq_fp =
+	    &((union storm_qmtm_qstate *)(mbox->qstate))->pq;
+
+	if (QMTM_QTYPE_VQ(mbox))
+		pq_fp->cfgqtype = QTYPE_VQ;
+	else if (QMTM_QTYPE_FP(mbox))
+		pq_fp->cfgqtype = QTYPE_FP;
+	else
+		pq_fp->cfgqtype = QTYPE_PQ;
+
+	/* if its a free queue, ask QMTM to set len to 0 when dealloc */
+	if (pq_fp->cfgqtype == QTYPE_FP)
+		pq_fp->fp_mode = CHANGE_LEN;
+
+	if (QMTM_SLAVE_ID(mbox) == QMTM_SLAVE_ID_ETH0 ||
+			QMTM_SLAVE_ID(mbox) == QMTM_SLAVE_ID_ETH1) {
+		pq_fp->cfgRecombBuf = 1;
+		pq_fp->cfgRecombBufTimeoutL = 0xf;
+		pq_fp->cfgRecombBufTimeoutH = 0x7;
+	}
+
+	pq_fp->cfgselthrsh = 1;
+	/*  Allow the queue to accept message with non-zero LErr */
+	pq_fp->cfgacceptlerr = 1;
+	pq_fp->qcoherent = 1;
+	pq_fp->cfgstartaddrL = (u32)((mbox->dma >> 8) & (u32)(BIT(27) - 1));
+	pq_fp->cfgstartaddrH = (u32)(mbox->dma >> 35);
+	pq_fp->cfgqsize = mbox->slots;
+	storm_qmtm_write_qstate(mbox);
+}
+
+static void storm_qmtm_clr_qstate(struct xgene_mbox *mbox)
+{
+	memset(mbox->qstate, 0, sizeof(union storm_qmtm_qstate));
+	storm_qmtm_write_qstate(mbox);
+}
+
+static u32 storm_qmtm_read_level(void *qfabric)
+{
+	return (readl(&(((u32 *)qfabric)[1])) & 0x1fffe) >> 1;
+}
+
+static int storm_qmtm_init(struct xgene_qmtm *qmtm)
+{
+	int ret = 0, val;
+	xgene_qmtm_rd32(qmtm, CSR_IPBRR_ADDR, &val);
+	switch (val) {
+	case CSR_IPBRR_QMTM0_DEFAULT:
+		qmtm->qmtm_ip = QMTM0;
+		qmtm->irq_start = 0;
+		qmtm->irq_count = 16;
+		break;
+	case CSR_IPBRR_QMTM1_DEFAULT:
+		qmtm->qmtm_ip = QMTM1;
+		qmtm->irq_start = 0;
+		qmtm->irq_count = 32;
+		break;
+	case CSR_IPBRR_QMTM2_DEFAULT:
+		qmtm->qmtm_ip = QMTM2;
+		qmtm->irq_start = 16;
+		qmtm->irq_count = 16;
+		break;
+	case CSR_IPBRR_QMTM3_DEFAULT:
+		qmtm->qmtm_ip = QMTM3;
+		qmtm->irq_start = 0;
+		qmtm->irq_count = 1;
+		break;
+	default:
+		ret = -EINVAL;
+	}
+
+	return ret;
+}
+
+struct xgene_qmtm_ops storm_qmtm_ops = {
+	.init = storm_qmtm_init,
+	.set_qstate = storm_qmtm_set_qstate,
+	.clr_qstate = storm_qmtm_clr_qstate,
+	.read_level = storm_qmtm_read_level,
+};
diff --git a/include/linux/platform_data/xgene_qmtm.h b/include/linux/platform_data/xgene_qmtm.h
new file mode 100644
index 0000000..23e630c
--- /dev/null
+++ b/include/linux/platform_data/xgene_qmtm.h
@@ -0,0 +1,300 @@
+/*
+ * AppliedMicro X-Gene SoC Queue Manager/Traffic Manager driver
+ *
+ * Copyright (c) 2013 Applied Micro Circuits Corporation.
+ * Author: Ravi Patel <rapatel@apm.com>
+ *         Keyur Chudgar <kchudgar@apm.com>
+ *         Fushen Chen <fchen@apm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published by
+ * the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ */
+
+#ifndef __XGENE_QMTM_H__
+#define __XGENE_QMTM_H__
+
+/* QMTM Data Length encoded as per QM message format */
+enum xgene_mbox_data_len {
+	DATA_LEN_256B = 0x0100,
+	DATA_LEN_1K = 0x0400,
+	DATA_LEN_2K = 0x0800,
+	DATA_LEN_4K = 0x1000,
+	DATA_LEN_16K = 0x4000,
+};
+
+enum xgene_mbox_mask_len {
+	MASK_LEN_256B = (DATA_LEN_256B - 1),
+	MASK_LEN_1K = (DATA_LEN_1K - 1),
+	MASK_LEN_2K = (DATA_LEN_2K - 1),
+	MASK_LEN_4K = (DATA_LEN_4K - 1),
+	MASK_LEN_16K = (DATA_LEN_16K - 1),
+};
+
+/* QMTM Buffer Length encoded as per QM message format */
+enum xgene_mbox_buf_len {
+	BUF_LEN_256B = 0x7000,
+	BUF_LEN_1K = 0x6000,
+	BUF_LEN_2K = 0x5000,
+	BUF_LEN_4K = 0x4000,
+	BUF_LEN_16K = 0x0000,
+};
+
+/* QMTM messaging structures */
+/* 16 byte QMTM message format */
+struct xgene_mbox_msg16 {
+#ifdef CONFIG_CPU_BIG_ENDIAN
+	/* memory word 0 (bit 31:0) */
+	u32 UserInfo;
+
+	/* memory word 1 (bit 63:32) */
+	u32 HL:1;
+	u32 LErr:3;
+	u32 RType:4;
+	u32 IN:1;
+	u32 Rv:1;
+	u32 HB:1;
+	u32 PB:1;
+	u32 LL:1;
+	u32 NV:1;
+	u32 LEI:2;
+	u32 ELErr:2;
+	u32 Rv2:2;
+	u32 FPQNum:12;
+
+	/* memory word 2 (bit 95:64) */
+	u32 DataAddrL;    /* split 10/32 */
+
+	/* memory word 3 (bit 127:96) */
+	u32 C:1;
+	u32 BufDataLen:15;
+	u32 Rv6:6;
+	u32 DataAddrH:10; /* split 10/32 */
+#else
+	/* memory word 0 (bit 31:0) */
+	u32 UserInfo;
+
+	/* memory word 1 (bit 63:32) */
+	u32 FPQNum:12;
+	u32 Rv2:2;
+	u32 ELErr:2;
+	u32 LEI:2;
+	u32 NV:1;
+	u32 LL:1;
+	u32 PB:1;
+	u32 HB:1;
+	u32 Rv:1;
+	u32 IN:1;
+	u32 RType:4;
+	u32 LErr:3;
+	u32 HL:1;
+
+	/* memory word 2 (bit 95:64) */
+	u32 DataAddrL;    /* split 10/32 */
+
+	/* memory word 3 (bit 127:96) */
+	u32 DataAddrH:10; /* split 10/32 */
+	u32 Rv6:6;
+	u32 BufDataLen:15;
+	u32 C:1;
+#endif
+} __packed;
+
+/* Higher 16 byte portion of 32 byte of QMTM message format */
+struct xgene_mbox_msg16H {
+#ifdef CONFIG_CPU_BIG_ENDIAN
+	/* memory word 4 (bit 159:128) */
+	u32 H0Info_msbL;    /* split 16/32 */
+
+	/* memory word 5 (bit 191:160) */
+	u32 HR:1;
+	u32 Rv0:1;
+	u32 DR:1;
+	u32 Rv1:1;
+	u32 TotDataLengthLinkListLSBs:12;
+	u16 H0Info_msbH; /* split 16/32 */
+
+	/* memory word 6 (bit 223:192) */
+	u32 H0Info_lsbL; /* split 16/32 */
+
+	/* memory word 7 (bit 255:224) */
+	u32 H0FPSel:4;
+	u32 H0Enq_Num:12;
+	u16 H0Info_lsbH; /* split 16/32 */
+#else
+	/* memory word 4 (bit 159:128) */
+	u32 H0Info_msbL; /* split 16/32 */
+
+	/* memory word 5 (bit 191:160) */
+	u16 H0Info_msbH; /* split 16/32 */
+	u32 TotDataLengthLinkListLSBs:12;
+	u32 Rv1:1;
+	u32 DR:1;
+	u32 Rv0:1;
+	u32 HR:1;
+
+	/* memory word 6 (bit 223:192) */
+	u32 H0Info_lsbL; /* split 16/32 */
+
+	/* memory word 7 (bit 255:224) */
+	u16 H0Info_lsbH; /* split 16/32 */
+	u32 H0Enq_Num:12;
+	u32 H0FPSel:4;
+#endif
+} __packed;
+
+/* 8 byte portion of QMTM extended (64B) message format */
+struct xgene_mbox_msg8 {
+#ifdef CONFIG_CPU_BIG_ENDIAN
+	u32 NxtDataAddrL;
+	u32 Rv1:1;
+	u32 NxtBufDataLength:15;
+	u32 NxtFPQNum:4;
+	u32 Rv2:2;
+	u32 NxtDataAddrH:10;
+#else
+	u32 NxtDataAddrL;
+	u32 NxtDataAddrH:10;
+	u32 Rv2:2;
+	u32 NxtFPQNum:4;
+	u32 NxtBufDataLength:15;
+	u32 Rv1:1;
+#endif
+} __packed;
+
+/* 8 byte Link list portion of QMTM extended (64B) message format */
+struct xgene_mbox_msg8_list {
+#ifdef CONFIG_CPU_BIG_ENDIAN
+	u32 NxtDataPtrL;
+	u8  TotDataLengthLinkListMSBs;
+	u8  NxtLinkListength;
+	u32 NxtFPQNum:4;
+	u32 Rv2:2;
+	u32 NxtDataPtrH:10;
+#else
+	u32 NxtDataPtrL;
+	u32 NxtDataPtrH:10;
+	u32 Rv2:2;
+	u32 NxtFPQNum:4;
+	u8  NxtLinkListength;
+	u8  TotDataLengthLinkListMSBs;
+#endif
+} __packed;
+
+/* This structure represents 32 byte QMTM message format */
+struct xgene_mbox_msg32 {
+	struct xgene_mbox_msg16 msg16;
+	struct xgene_mbox_msg16H msg16H;
+} __packed;
+
+ /* Higher 32 byte of QMTM extended (64B) message format */
+struct xgene_mbox_msg32H {
+	struct xgene_mbox_msg8 msg8_2;
+	struct xgene_mbox_msg8 msg8_1;
+	union {
+		struct xgene_mbox_msg8 msg8_4;
+		struct xgene_mbox_msg8_list msg8_list;
+	};
+	struct xgene_mbox_msg8 msg8_3;
+} __packed;
+
+/* 64 byte QMTM message format */
+struct xgene_mbox_msg64 {
+	struct xgene_mbox_msg32 msg32;
+	struct xgene_mbox_msg32H msg32H;
+} __packed;
+
+#ifdef CONFIG_CPU_BIG_ENDIAN
+#define xgene_mbox_msg_le32(word, words) \
+	do { \
+		int w; \
+		for (w = 0; w < words; w++) \
+			*(word + w) = cpu_to_le32(*(word + w)); \
+	} while (0)
+#else
+#define xgene_mbox_msg_le32(word, words) \
+	do {} while (0)
+#endif
+
+/* Empty Slot Soft Signature */
+#define EMPTY_SLOT_INDEX	7
+#define EMPTY_SLOT		0x22222222
+
+/* Encoding Destination QMTM (2 MSB) and Queue ID */
+#define QMTM_QUEUE_ID(q)	(((u16)(q->qstate[6]) << 10) | q->qid)
+
+/* Decoding PBM signal */
+#define QMTM_PBN(q)		(q->pbm & 0x003F)
+#define QMTM_SLAVE_ID(q)	((q->pbm & 0x03C0) >> 6)
+#define QMTM_QTYPE_FP(q)	(q->pbm & 0x0020)
+#define QMTM_QTYPE_VQ(q)	(q->pbm & 0x0400)
+
+/* Per queue state database */
+struct xgene_mbox {
+	u16 pbm;
+	u16 qid;
+	u16 qhead;
+	u16 qtail;
+	u16 slots;
+	u16 irq;
+	u32 qsize;
+	u32 pbm_state;
+	u32 qstate[7];
+	void *qfabric;
+	void *level;
+	dma_addr_t dma;
+	union {
+		void *qaddr;
+		struct xgene_mbox_msg16 *msg16;
+		struct xgene_mbox_msg32 *msg32;
+	};
+	struct xgene_qmtm *qmtm;
+};
+
+static inline u16 xgene_mbox_encode_bufdatalen(u32 len)
+{
+	if (len <= DATA_LEN_256B)
+		return BUF_LEN_256B | (len & MASK_LEN_256B);
+	else if (len <= DATA_LEN_1K)
+		return BUF_LEN_1K | (len & MASK_LEN_1K);
+	else if (len <= DATA_LEN_2K)
+		return BUF_LEN_2K | (len & MASK_LEN_2K);
+	else if (len <= DATA_LEN_4K)
+		return BUF_LEN_4K | (len & MASK_LEN_4K);
+	else if (len < DATA_LEN_16K)
+		return BUF_LEN_16K | (len & MASK_LEN_16K);
+	else
+		return BUF_LEN_16K;
+}
+
+static inline u16 xgene_mbox_encode_datalen(u32 len)
+{
+	return len & MASK_LEN_16K;
+}
+
+static inline u32 xgene_mbox_decode_datalen(u16 bufdatalen)
+{
+	switch (bufdatalen & BUF_LEN_256B) {
+	case BUF_LEN_256B:
+		return bufdatalen & MASK_LEN_256B ? : DATA_LEN_256B;
+	case BUF_LEN_1K:
+		return bufdatalen & MASK_LEN_1K ? : DATA_LEN_1K;
+	case BUF_LEN_2K:
+		return bufdatalen & MASK_LEN_2K ? : DATA_LEN_2K;
+	case BUF_LEN_4K:
+		return bufdatalen & MASK_LEN_4K ? : DATA_LEN_4K;
+	default:
+		return bufdatalen & MASK_LEN_16K ? : DATA_LEN_16K;
+	};
+}
+
+struct xgene_mbox *xgene_mbox_get(struct device *dev, const char *s);
+void xgene_mbox_put(struct xgene_mbox *mbox);
+u32 xgene_mbox_level(struct xgene_mbox *mbox);
+
+#endif /* __XGENE_QMTM_H__ */
-- 
1.7.9.5
