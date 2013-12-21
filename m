From: Ravi Patel <rapatel@apm.com>
Subject: [PATCH V2 4/4] misc: xgene: Add error handling for APM X-Gene SoC Queue Manager/Traffic Manager
Date: Fri, 20 Dec 2013 18:57:31 -0800
Message-ID: <1387594651-25771-5-git-send-email-rapatel@apm.com>
References: <1387594651-25771-1-git-send-email-rapatel@apm.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	jcm@redhat.com, patches@apm.com, Ravi Patel <rapatel@apm.com>,
	Keyur Chudgar <kchudgar@apm.com>
To: arnd@arndb.de, gregkh@linuxfoundation.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og111.obsmtp.com ([64.18.0.22]:50364 "HELO
	exprod5og111.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753771Ab3LUC5s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 21:57:48 -0500
Received: by mail-pd0-f171.google.com with SMTP id z10so3248995pdj.30
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 18:57:47 -0800 (PST)
In-Reply-To: <1387594651-25771-1-git-send-email-rapatel@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for error handling in APM X-Gene SoC Queue
  Manager/Traffic Manager.

Signed-off-by: Ravi Patel <rapatel@apm.com>
Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
---
 drivers/misc/xgene/qmtm/Makefile           |    2 +-
 drivers/misc/xgene/qmtm/xgene_qmtm_error.c |  283 ++++++++++++++++++++++++++++
 drivers/misc/xgene/qmtm/xgene_qmtm_main.c  |    6 +-
 drivers/misc/xgene/qmtm/xgene_qmtm_main.h  |    4 +
 4 files changed, 293 insertions(+), 2 deletions(-)
 create mode 100644 drivers/misc/xgene/qmtm/xgene_qmtm_error.c

diff --git a/drivers/misc/xgene/qmtm/Makefile b/drivers/misc/xgene/qmtm/Makefile
index 68c2a86..8448253 100644
--- a/drivers/misc/xgene/qmtm/Makefile
+++ b/drivers/misc/xgene/qmtm/Makefile
@@ -4,4 +4,4 @@
 
 obj-$(CONFIG_XGENE_QMTM) += xgene-qmtm.o
 
-xgene-qmtm-objs := xgene_qmtm_main.o xgene_qmtm_storm.o
+xgene-qmtm-objs := xgene_qmtm_main.o xgene_qmtm_storm.o xgene_qmtm_error.o
diff --git a/drivers/misc/xgene/qmtm/xgene_qmtm_error.c b/drivers/misc/xgene/qmtm/xgene_qmtm_error.c
new file mode 100644
index 0000000..5b4f4a9
--- /dev/null
+++ b/drivers/misc/xgene/qmtm/xgene_qmtm_error.c
@@ -0,0 +1,283 @@
+/*
+ * AppliedMicro X-Gene SOC Queue Manager/Traffic Manager driver
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
+#include <linux/interrupt.h>
+#include "xgene_qmtm_main.h"
+
+#define QM_INTERRUPT_ADDR		0x00000124
+#define QM_INTERRUPTMASK_ADDR		0x00000128
+#define QUEUE_NOT_EMPTYMASK_MASK	0x80000000
+#define ACR_FIFO_CRITICALMASK_MASK	0x00000008
+#define QPCORE_ACR_ERRORMASK_MASK	0x00000004
+#define DEQ_AXI_ERRORMASK_MASK		0x00000002
+#define PBM_DEC_ERRORMASK_MASK		0x00000001
+
+#define CSR_PBM_ERRINF_ADDR		0x00000134
+#define  ACR_QID_RD(src)		(((src) & 0x00ffc000)>>14)
+#define  QID_RD(src)			(((src) & 0x000003ff))
+
+#define CSR_MSGRD_ERRINF_ADDR		0x00000138
+
+#define CSR_ERRQ_ADDR			0x00000218
+#define  UNEXPECTED_EN_SET(dst, src) \
+	(((dst) & ~0x80000000) | (((u32)(src)<<31) & 0x80000000))
+#define  UNEXPECTED_QID_SET(dst, src) \
+	(((dst) & ~0x03ff0000) | (((u32)(src)<<16) & 0x03ff0000))
+#define  EXPECTED_EN_SET(dst, src) \
+	(((dst) & ~0x00008000) | (((u32)(src)<<15) & 0x00008000))
+#define  EXPECTED_QID_SET(dst, src) \
+	(((dst) & ~0x000003ff) | (((u32)(src)) & 0x000003ff))
+
+/* QMTM Error Reporting */
+enum xgene_qmtm_lerr {
+	QMTM_NO_ERR,
+	QMTM_MSG_SIZE_ERR,
+	QMTM_HOP_COUNT_ERR,
+	QMTM_VQ_ENQ_ERR,
+	QMTM_DISABLEDQ_ENQ_ERR,
+	QMTM_Q_OVERFLOW_ERR,
+	QMTM_ENQUEUE_ERR,
+	QMTM_DEQUEUE_ERR,
+};
+
+/* Parse Error Message received on Error Queue */
+static void xgene_qmtm_error_msg(struct xgene_qmtm_qinfo *qinfo,
+				 struct xgene_qmtm_msg32 *msg)
+{
+	struct xgene_qmtm_msg16 *msg16 = &msg->msg16;
+	struct device *dev = &qinfo->qmtm->pdev->dev;
+	u16 queue_id = qinfo->queue_id;
+
+	dev_err(dev, "Error ELErr[%d] LErr[%d] for Qid[%d]\n",
+		msg16->ELErr, msg16->LErr, queue_id);
+
+	switch (msg16->LErr) {
+	case QMTM_MSG_SIZE_ERR:
+		dev_err(dev, "Msg Size Error for Enqueue on Queue %d\n",
+			queue_id);
+		break;
+	case QMTM_HOP_COUNT_ERR:
+		dev_err(dev, "Hop count error, hop count of 3 for Queue %d\n",
+			queue_id);
+		break;
+	case QMTM_VQ_ENQ_ERR:
+		dev_err(dev, "Enqueue on Virtual Queue %d\n", queue_id);
+		break;
+	case QMTM_DISABLEDQ_ENQ_ERR:
+		dev_err(dev, "Enqueue on disabled Queue %d\n", queue_id);
+		break;
+	case QMTM_Q_OVERFLOW_ERR:
+		dev_err(dev, "Queue %d overflow, message sent to Error Queue\n",
+			queue_id);
+		break;
+	case QMTM_ENQUEUE_ERR:
+		dev_err(dev, "Enqueue Queue\n");
+		break;
+	case QMTM_DEQUEUE_ERR:
+		dev_err(dev, "Dequeue Queue\n");
+		break;
+	default:
+		dev_err(dev, "Unknown Error\n");
+		break;
+	}
+}
+
+static void xgene_qmtm_error(struct xgene_qmtm *qmtm)
+{
+	struct device *dev = &qmtm->pdev->dev;
+	struct xgene_qmtm_qinfo qinfo;
+	u32 status;
+	u32 pbm_err;
+	u32 msgrd_err;
+
+	memset(&qinfo, 0, sizeof(qinfo));
+	qinfo.qmtm = qmtm;
+
+	xgene_qmtm_rd32(qmtm, QM_INTERRUPT_ADDR, &status);
+	dev_err(dev, "error interrupt status 0x%08X\n", status);
+
+	xgene_qmtm_rd32(qmtm, CSR_PBM_ERRINF_ADDR, &pbm_err);
+	dev_err(dev, "CSR PBM ERRINF (0x%X) value 0x%08X\n",
+		CSR_PBM_ERRINF_ADDR, pbm_err);
+
+	xgene_qmtm_rd32(qmtm, CSR_MSGRD_ERRINF_ADDR, &msgrd_err);
+	dev_err(dev, "CSR MSGRD ERRINF (0x%X) value 0x%08X\n",
+		CSR_MSGRD_ERRINF_ADDR, msgrd_err);
+
+	qinfo.queue_id = QID_RD(msgrd_err);
+	dev_err(dev, "DEQ QID %d\n", qinfo.queue_id);
+	xgene_qmtm_read_qstate(&qinfo);
+	print_hex_dump(KERN_ERR, "DEQSTATE ", DUMP_PREFIX_ADDRESS, 16, 4,
+		       qinfo.qstate, sizeof(qinfo.qstate), 1);
+
+	qinfo.queue_id = ACR_QID_RD(msgrd_err);
+	dev_err(dev, "ENQ QID %d\n", qinfo.queue_id);
+	xgene_qmtm_read_qstate(&qinfo);
+	print_hex_dump(KERN_INFO, "ENQSTATE ", DUMP_PREFIX_ADDRESS, 16, 4,
+		       qinfo.qstate, sizeof(qinfo.qstate), 1);
+
+	xgene_qmtm_wr32(qmtm, QM_INTERRUPT_ADDR, status);
+}
+
+static irqreturn_t xgene_qmtm_error_intr(int irq, void *qdev)
+{
+	xgene_qmtm_error((struct xgene_qmtm *)qdev);
+
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t xgene_qmtm_error_queue_intr(int irq, void *qdev)
+{
+	struct xgene_qmtm_msg64 msg;
+	struct xgene_qmtm_qinfo *qinfo = (struct xgene_qmtm_qinfo *)qdev;
+	struct xgene_qmtm *qmtm = qinfo->qmtm;
+	struct device *dev = &qmtm->pdev->dev;
+	u16 queue_id = qinfo->queue_id;
+	u8 qmtm_ip = qinfo->qmtm_ip;
+	int rc;
+
+	rc = xgene_qmtm_dequeue_msg(qinfo->qdesc, &msg);
+	if (rc < 0) {
+		/* Return if invalid interrupt */
+		dev_err(dev, "QMTM%d QID %d PBN %d IRQ %d spurious\n",
+			qmtm_ip, queue_id, qinfo->pbn, irq);
+		return IRQ_HANDLED;
+	}
+
+	xgene_qmtm_error(qmtm);
+	dev_err(dev, "QMTM%d Error: QID %d\n", qmtm_ip, queue_id);
+	print_hex_dump(KERN_INFO, "Err q MSG: ", DUMP_PREFIX_ADDRESS,
+		       16, 4, &msg, msg.msg32_1.msg16.NV ? 64 : 32, 1);
+	xgene_qmtm_error_msg(qinfo, &msg.msg32_1);
+
+	return IRQ_HANDLED;
+}
+
+int xgene_qmtm_enable_error(struct xgene_qmtm *qmtm)
+{
+	struct device *dev = &qmtm->pdev->dev;
+	struct xgene_qmtm_qinfo qinfo;
+	int rc = 0;
+	u32 val;
+	u16 irq = platform_get_irq(qmtm->pdev, 0);
+	u8 qmtm_ip = qmtm->qmtm_ip;
+
+	if (irq) {
+		u32 mask;
+
+		memset(qmtm->error_irq_s, 0, sizeof(qmtm->error_irq_s));
+		snprintf(qmtm->error_irq_s, sizeof(qmtm->error_irq_s),
+			 "%s_Err", qmtm->idev->name);
+
+		rc = devm_request_irq(dev, irq, xgene_qmtm_error_intr, 0,
+				      qmtm->error_irq_s, qmtm);
+		if (rc < 0) {
+			dev_err(dev, "request_irq %d failed for %s (%d)\n",
+				irq, qmtm->error_irq_s, rc);
+			return rc;
+		}
+
+		qmtm->error_irq = irq;
+
+		/* Enable QM hardware interrupts */
+		mask = ~(u32) (PBM_DEC_ERRORMASK_MASK
+			       | ACR_FIFO_CRITICALMASK_MASK
+			       | QUEUE_NOT_EMPTYMASK_MASK
+			       | DEQ_AXI_ERRORMASK_MASK
+			       | QPCORE_ACR_ERRORMASK_MASK);
+		xgene_qmtm_wr32(qmtm, QM_INTERRUPTMASK_ADDR, mask);
+	}
+
+	if (qmtm_ip == QMTM3)
+		return rc;
+
+	memset(&qinfo, 0, sizeof(qinfo));
+	qinfo.sdev = qmtm->idev;
+	qinfo.qaccess = QACCESS_ALT;
+	qinfo.qtype = QTYPE_PQ;
+	qinfo.qsize = QSIZE_2KB;
+	qinfo.flags = XGENE_SLAVE_DEFAULT_FLAGS;
+
+	/* create error queue */
+	rc = xgene_qmtm_set_qinfo(&qinfo);
+	if (rc < 0) {
+		dev_err(dev, "QMTM %d unable to configure error queue\n",
+			qmtm_ip);
+		return rc;
+	}
+
+	qmtm->error_qinfo = qmtm->qinfo[qinfo.queue_id];
+	memset(qmtm->error_queue_irq_s, 0, sizeof(qmtm->error_queue_irq_s));
+	snprintf(qmtm->error_queue_irq_s, sizeof(qmtm->error_queue_irq_s),
+		 "%s_ErQ", qmtm->idev->name);
+
+	rc = devm_request_irq(dev, qinfo.qdesc->irq,
+			      xgene_qmtm_error_queue_intr,
+			      0, qmtm->error_queue_irq_s, qmtm->error_qinfo);
+	if (rc < 0) {
+		dev_err(dev, "request_irq %d failed for %s (%d)\n",
+			qinfo.qdesc->irq, qmtm->error_queue_irq_s, rc);
+		xgene_qmtm_clr_qinfo(&qinfo);
+		qmtm->error_qinfo = NULL;
+		return rc;
+	}
+
+	val = 0;
+	val = UNEXPECTED_EN_SET(val, 1);
+	val = UNEXPECTED_QID_SET(val, qinfo.queue_id);
+	val = EXPECTED_EN_SET(val, 1);
+	val = EXPECTED_QID_SET(val, qinfo.queue_id);
+	xgene_qmtm_wr32(qmtm, CSR_ERRQ_ADDR, val);
+
+	return rc;
+}
+
+void xgene_qmtm_disable_error(struct xgene_qmtm *qmtm)
+{
+	struct xgene_qmtm_qinfo *error_qinfo = qmtm->error_qinfo;
+	struct device *dev = &qmtm->pdev->dev;
+
+	/* Free QMTM Error IRQ */
+	if (qmtm->error_irq) {
+		u32 mask;
+
+		/* Disable QM hardware interrupts */
+		mask = PBM_DEC_ERRORMASK_MASK
+		    | ACR_FIFO_CRITICALMASK_MASK
+		    | QUEUE_NOT_EMPTYMASK_MASK
+		    | DEQ_AXI_ERRORMASK_MASK | QPCORE_ACR_ERRORMASK_MASK;
+		xgene_qmtm_wr32(qmtm, QM_INTERRUPTMASK_ADDR, mask);
+		devm_free_irq(dev, qmtm->error_irq, qmtm);
+		qmtm->error_irq = 0;
+	}
+
+	if (error_qinfo) {
+		struct xgene_qmtm_qinfo qinfo;
+
+		/* Free QMTM Error Queue IRQ */
+		devm_free_irq(dev, error_qinfo->qdesc->irq, error_qinfo);
+
+		/* Delete error queue */
+		qinfo.sdev = error_qinfo->qmtm->idev;
+		qinfo.queue_id = error_qinfo->queue_id;
+		xgene_qmtm_clr_qinfo(&qinfo);
+		qmtm->error_qinfo = NULL;
+
+		/* Unassign error queue */
+		xgene_qmtm_wr32(qmtm, CSR_ERRQ_ADDR, 0);
+	}
+}
diff --git a/drivers/misc/xgene/qmtm/xgene_qmtm_main.c b/drivers/misc/xgene/qmtm/xgene_qmtm_main.c
index cda63e0..833ff82 100644
--- a/drivers/misc/xgene/qmtm/xgene_qmtm_main.c
+++ b/drivers/misc/xgene/qmtm/xgene_qmtm_main.c
@@ -588,13 +588,17 @@ static int xgene_qmtm_enable(struct xgene_qmtm *qmtm)
 		qmtm->write_qstate(&qinfo);
 	}
 
-	return rc;
+	/* Enable error reporting */
+	return xgene_qmtm_enable_error(qmtm);
 }
 
 static int xgene_qmtm_disable(struct xgene_qmtm *qmtm)
 {
 	u32 queue_id;
 
+	/* Disable error reporting */
+	xgene_qmtm_disable_error(qmtm);
+
 	for (queue_id = 0; queue_id < qmtm->max_queues; queue_id++) {
 		if (qmtm->qinfo[queue_id]) {
 			dev_err(&qmtm->pdev->dev,
diff --git a/drivers/misc/xgene/qmtm/xgene_qmtm_main.h b/drivers/misc/xgene/qmtm/xgene_qmtm_main.h
index d937462..2a60225 100644
--- a/drivers/misc/xgene/qmtm/xgene_qmtm_main.h
+++ b/drivers/misc/xgene/qmtm/xgene_qmtm_main.h
@@ -129,6 +129,10 @@ enum xgene_qmtm_fp_mode {
 void xgene_qmtm_wr32(struct xgene_qmtm *qmtm, u32 offset, u32 data);
 void xgene_qmtm_rd32(struct xgene_qmtm *qmtm, u32 offset, u32 *data);
 
+/* QMTM Error handling */
+int xgene_qmtm_enable_error(struct xgene_qmtm *qmtm);
+void xgene_qmtm_disable_error(struct xgene_qmtm *qmtm);
+
 struct xgene_qmtm_sdev *storm_qmtm_get_sdev(char *name);
 
 #endif /* __XGENE_QMTM_MAIN_H__ */
-- 
1.7.9.5
