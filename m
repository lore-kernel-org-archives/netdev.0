From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Subject: [PATCH V7 net-next 13/22] net-next/hinic: Set qp context
Date: Fri, 18 Aug 2017 03:04:47 +0800
Message-ID: <57a078828b98af890dd06bbf2ba3e3a632a39c5d.1502996306.git.aviad.krawczyk@huawei.com>
References: <cover.1502996306.git.aviad.krawczyk@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <bc.y@huawei.com>, <victor.gissin@huawei.com>,
        <aviad.krawczyk@huawei.com>, <zhaochen6@huawei.com>,
        <tony.qu@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1502996306.git.aviad.krawczyk@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update the nic about the resources of the queue pairs.

Signed-off-by: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Signed-off-by: Zhao Chen <zhaochen6@huawei.com>
---
 drivers/net/ethernet/huawei/hinic/Makefile         |   5 +-
 drivers/net/ethernet/huawei/hinic/hinic_common.c   |  55 ++++++
 drivers/net/ethernet/huawei/hinic/hinic_common.h   |   4 +
 drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.c  |  87 +++++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.h  |  84 ++++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c   |   4 +
 drivers/net/ethernet/huawei/hinic/hinic_hw_io.c    | 151 +++++++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_io.h    |   5 +
 drivers/net/ethernet/huawei/hinic/hinic_hw_qp.c    | 159 +++++++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h    |  11 ++
 .../net/ethernet/huawei/hinic/hinic_hw_qp_ctxt.h   | 214 +++++++++++++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_wq.h    |   9 +
 12 files changed, 786 insertions(+), 2 deletions(-)
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_common.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_qp_ctxt.h

diff --git a/drivers/net/ethernet/huawei/hinic/Makefile b/drivers/net/ethernet/huawei/hinic/Makefile
index 84815f7..289ce88b 100644
--- a/drivers/net/ethernet/huawei/hinic/Makefile
+++ b/drivers/net/ethernet/huawei/hinic/Makefile
@@ -1,5 +1,6 @@
 obj-$(CONFIG_HINIC) += hinic.o
 
 hinic-y := hinic_main.o hinic_tx.o hinic_rx.o hinic_port.o hinic_hw_dev.o \
-	   hinic_hw_io.o hinic_hw_qp.o hinic_hw_wq.o hinic_hw_mgmt.o \
-	   hinic_hw_api_cmd.o hinic_hw_eqs.o hinic_hw_if.o
+	   hinic_hw_io.o hinic_hw_qp.o hinic_hw_cmdq.o hinic_hw_wq.o \
+	   hinic_hw_mgmt.o hinic_hw_api_cmd.o hinic_hw_eqs.o hinic_hw_if.o \
+	   hinic_common.o
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_common.c b/drivers/net/ethernet/huawei/hinic/hinic_common.c
new file mode 100644
index 0000000..1915ad6
--- /dev/null
+++ b/drivers/net/ethernet/huawei/hinic/hinic_common.c
@@ -0,0 +1,55 @@
+/*
+ * Huawei HiNIC PCI Express Linux driver
+ * Copyright(c) 2017 Huawei Technologies Co., Ltd
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
+ * for more details.
+ *
+ */
+
+#include <linux/types.h>
+#include <asm/byteorder.h>
+
+#include "hinic_common.h"
+
+/**
+ * hinic_cpu_to_be32 - convert data to big endian 32 bit format
+ * @data: the data to convert
+ * @len: length of data to convert
+ **/
+void hinic_cpu_to_be32(void *data, int len)
+{
+	u32 *mem = data;
+	int i;
+
+	len = len / sizeof(u32);
+
+	for (i = 0; i < len; i++) {
+		*mem = cpu_to_be32(*mem);
+		mem++;
+	}
+}
+
+/**
+ * hinic_be32_to_cpu - convert data from big endian 32 bit format
+ * @data: the data to convert
+ * @len: length of data to convert
+ **/
+void hinic_be32_to_cpu(void *data, int len)
+{
+	u32 *mem = data;
+	int i;
+
+	len = len / sizeof(u32);
+
+	for (i = 0; i < len; i++) {
+		*mem = be32_to_cpu(*mem);
+		mem++;
+	}
+}
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_common.h b/drivers/net/ethernet/huawei/hinic/hinic_common.h
index 6a83c15..0f2f4ff 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_common.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_common.h
@@ -22,4 +22,8 @@ struct hinic_sge {
 	u32             len;
 };
 
+void hinic_cpu_to_be32(void *data, int len);
+
+void hinic_be32_to_cpu(void *data, int len);
+
 #endif
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.c
new file mode 100644
index 0000000..2fd3924
--- /dev/null
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.c
@@ -0,0 +1,87 @@
+/*
+ * Huawei HiNIC PCI Express Linux driver
+ * Copyright(c) 2017 Huawei Technologies Co., Ltd
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
+ * for more details.
+ *
+ */
+
+#include <linux/types.h>
+#include <linux/errno.h>
+
+#include "hinic_hw_if.h"
+#include "hinic_hw_cmdq.h"
+
+/**
+ * hinic_alloc_cmdq_buf - alloc buffer for sending command
+ * @cmdqs: the cmdqs
+ * @cmdq_buf: the buffer returned in this struct
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+int hinic_alloc_cmdq_buf(struct hinic_cmdqs *cmdqs,
+			 struct hinic_cmdq_buf *cmdq_buf)
+{
+	/* should be implemented */
+	return -ENOMEM;
+}
+
+/**
+ * hinic_free_cmdq_buf - free buffer
+ * @cmdqs: the cmdqs
+ * @cmdq_buf: the buffer to free that is in this struct
+ **/
+void hinic_free_cmdq_buf(struct hinic_cmdqs *cmdqs,
+			 struct hinic_cmdq_buf *cmdq_buf)
+{
+	/* should be implemented */
+}
+
+/**
+ * hinic_cmdq_direct_resp - send command with direct data as resp
+ * @cmdqs: the cmdqs
+ * @mod: module on the card that will handle the command
+ * @cmd: the command
+ * @buf_in: the buffer for the command
+ * @resp: the response to return
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+int hinic_cmdq_direct_resp(struct hinic_cmdqs *cmdqs,
+			   enum hinic_mod_type mod, u8 cmd,
+			   struct hinic_cmdq_buf *buf_in, u64 *resp)
+{
+	/* should be implemented */
+	return -EINVAL;
+}
+
+/**
+ * hinic_init_cmdqs - init all cmdqs
+ * @cmdqs: cmdqs to init
+ * @hwif: HW interface for accessing cmdqs
+ * @db_area: doorbell areas for all the cmdqs
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+int hinic_init_cmdqs(struct hinic_cmdqs *cmdqs, struct hinic_hwif *hwif,
+		     void __iomem **db_area)
+{
+	/* should be implemented */
+	return -EINVAL;
+}
+
+/**
+ * hinic_free_cmdqs - free all cmdqs
+ * @cmdqs: cmdqs to free
+ **/
+void hinic_free_cmdqs(struct hinic_cmdqs *cmdqs)
+{
+	/* should be implemented */
+}
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.h
new file mode 100644
index 0000000..c9e97ca
--- /dev/null
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.h
@@ -0,0 +1,84 @@
+/*
+ * Huawei HiNIC PCI Express Linux driver
+ * Copyright(c) 2017 Huawei Technologies Co., Ltd
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
+ * for more details.
+ *
+ */
+
+#ifndef HINIC_CMDQ_H
+#define HINIC_CMDQ_H
+
+#include <linux/types.h>
+#include <linux/spinlock.h>
+#include <linux/completion.h>
+#include <linux/pci.h>
+
+#include "hinic_hw_if.h"
+#include "hinic_hw_wq.h"
+
+#define HINIC_CMDQ_BUF_SIZE             2048
+
+enum hinic_cmdq_type {
+	HINIC_CMDQ_SYNC,
+
+	HINIC_MAX_CMDQ_TYPES,
+};
+
+struct hinic_cmdq_buf {
+	void            *buf;
+	dma_addr_t      dma_addr;
+	size_t          size;
+};
+
+struct hinic_cmdq {
+	struct hinic_wq         *wq;
+
+	enum hinic_cmdq_type    cmdq_type;
+	int                     wrapped;
+
+	/* Lock for keeping the doorbell order */
+	spinlock_t              cmdq_lock;
+
+	struct completion       **done;
+	int                     **errcode;
+
+	/* doorbell area */
+	void __iomem            *db_base;
+};
+
+struct hinic_cmdqs {
+	struct hinic_hwif       *hwif;
+
+	struct pci_pool         *cmdq_buf_pool;
+
+	struct hinic_wq         *saved_wqs;
+
+	struct hinic_cmdq_pages cmdq_pages;
+
+	struct hinic_cmdq       cmdq[HINIC_MAX_CMDQ_TYPES];
+};
+
+int hinic_alloc_cmdq_buf(struct hinic_cmdqs *cmdqs,
+			 struct hinic_cmdq_buf *cmdq_buf);
+
+void hinic_free_cmdq_buf(struct hinic_cmdqs *cmdqs,
+			 struct hinic_cmdq_buf *cmdq_buf);
+
+int hinic_cmdq_direct_resp(struct hinic_cmdqs *cmdqs,
+			   enum hinic_mod_type mod, u8 cmd,
+			   struct hinic_cmdq_buf *buf_in, u64 *out_param);
+
+int hinic_init_cmdqs(struct hinic_cmdqs *cmdqs, struct hinic_hwif *hwif,
+		     void __iomem **db_area);
+
+void hinic_free_cmdqs(struct hinic_cmdqs *cmdqs);
+
+#endif
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
index d113908..cf0e165 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
@@ -25,6 +25,7 @@
 #include "hinic_hw_if.h"
 #include "hinic_hw_eqs.h"
 #include "hinic_hw_mgmt.h"
+#include "hinic_hw_qp_ctxt.h"
 #include "hinic_hw_qp.h"
 #include "hinic_hw_io.h"
 #include "hinic_hw_dev.h"
@@ -76,6 +77,9 @@ static int get_capability(struct hinic_hwdev *hwdev,
 	/* Each QP has its own (SQ + RQ) interrupts */
 	nic_cap->num_qps = (num_irqs - (num_aeqs + num_ceqs)) / 2;
 
+	if (nic_cap->num_qps > HINIC_Q_CTXT_MAX)
+		nic_cap->num_qps = HINIC_Q_CTXT_MAX;
+
 	/* num_qps must be power of 2 */
 	nic_cap->num_qps = BIT(fls(nic_cap->num_qps) - 1);
 
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_io.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_io.c
index ad12cc7..bb4b93f 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_io.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_io.c
@@ -27,6 +27,8 @@
 #include "hinic_hw_if.h"
 #include "hinic_hw_wqe.h"
 #include "hinic_hw_wq.h"
+#include "hinic_hw_cmdq.h"
+#include "hinic_hw_qp_ctxt.h"
 #include "hinic_hw_qp.h"
 #include "hinic_hw_io.h"
 
@@ -40,6 +42,10 @@
 #define DB_IDX(db, db_base)             \
 	(((unsigned long)(db) - (unsigned long)(db_base)) / HINIC_DB_PAGE_SIZE)
 
+enum io_cmd {
+	IO_CMD_MODIFY_QUEUE_CTXT = 0,
+};
+
 static void init_db_area_idx(struct hinic_free_db_area *free_db_area)
 {
 	int i;
@@ -100,6 +106,109 @@ static void return_db_area(struct hinic_func_to_io *func_to_io,
 	up(&free_db_area->idx_lock);
 }
 
+static int write_sq_ctxts(struct hinic_func_to_io *func_to_io, u16 base_qpn,
+			  u16 num_sqs)
+{
+	struct hinic_hwif *hwif = func_to_io->hwif;
+	struct hinic_sq_ctxt_block *sq_ctxt_block;
+	struct pci_dev *pdev = hwif->pdev;
+	struct hinic_cmdq_buf cmdq_buf;
+	struct hinic_sq_ctxt *sq_ctxt;
+	struct hinic_qp *qp;
+	u64 out_param;
+	int err, i;
+
+	err = hinic_alloc_cmdq_buf(&func_to_io->cmdqs, &cmdq_buf);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to allocate cmdq buf\n");
+		return err;
+	}
+
+	sq_ctxt_block = cmdq_buf.buf;
+	sq_ctxt = sq_ctxt_block->sq_ctxt;
+
+	hinic_qp_prepare_header(&sq_ctxt_block->hdr, HINIC_QP_CTXT_TYPE_SQ,
+				num_sqs, func_to_io->max_qps);
+	for (i = 0; i < num_sqs; i++) {
+		qp = &func_to_io->qps[i];
+
+		hinic_sq_prepare_ctxt(&sq_ctxt[i], &qp->sq,
+				      base_qpn + qp->q_id);
+	}
+
+	cmdq_buf.size = HINIC_SQ_CTXT_SIZE(num_sqs);
+
+	err = hinic_cmdq_direct_resp(&func_to_io->cmdqs, HINIC_MOD_L2NIC,
+				     IO_CMD_MODIFY_QUEUE_CTXT, &cmdq_buf,
+				     &out_param);
+	if ((err) || (out_param != 0)) {
+		dev_err(&pdev->dev, "Failed to set SQ ctxts\n");
+		err = -EFAULT;
+	}
+
+	hinic_free_cmdq_buf(&func_to_io->cmdqs, &cmdq_buf);
+	return err;
+}
+
+static int write_rq_ctxts(struct hinic_func_to_io *func_to_io, u16 base_qpn,
+			  u16 num_rqs)
+{
+	struct hinic_hwif *hwif = func_to_io->hwif;
+	struct hinic_rq_ctxt_block *rq_ctxt_block;
+	struct pci_dev *pdev = hwif->pdev;
+	struct hinic_cmdq_buf cmdq_buf;
+	struct hinic_rq_ctxt *rq_ctxt;
+	struct hinic_qp *qp;
+	u64 out_param;
+	int err, i;
+
+	err = hinic_alloc_cmdq_buf(&func_to_io->cmdqs, &cmdq_buf);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to allocate cmdq buf\n");
+		return err;
+	}
+
+	rq_ctxt_block = cmdq_buf.buf;
+	rq_ctxt = rq_ctxt_block->rq_ctxt;
+
+	hinic_qp_prepare_header(&rq_ctxt_block->hdr, HINIC_QP_CTXT_TYPE_RQ,
+				num_rqs, func_to_io->max_qps);
+	for (i = 0; i < num_rqs; i++) {
+		qp = &func_to_io->qps[i];
+
+		hinic_rq_prepare_ctxt(&rq_ctxt[i], &qp->rq,
+				      base_qpn + qp->q_id);
+	}
+
+	cmdq_buf.size = HINIC_RQ_CTXT_SIZE(num_rqs);
+
+	err = hinic_cmdq_direct_resp(&func_to_io->cmdqs, HINIC_MOD_L2NIC,
+				     IO_CMD_MODIFY_QUEUE_CTXT, &cmdq_buf,
+				     &out_param);
+	if ((err) || (out_param != 0)) {
+		dev_err(&pdev->dev, "Failed to set RQ ctxts\n");
+		err = -EFAULT;
+	}
+
+	hinic_free_cmdq_buf(&func_to_io->cmdqs, &cmdq_buf);
+	return err;
+}
+
+/**
+ * write_qp_ctxts - write the qp ctxt to HW
+ * @func_to_io: func to io channel that holds the IO components
+ * @base_qpn: first qp number
+ * @num_qps: number of qps to write
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+static int write_qp_ctxts(struct hinic_func_to_io *func_to_io, u16 base_qpn,
+			  u16 num_qps)
+{
+	return (write_sq_ctxts(func_to_io, base_qpn, num_qps) ||
+		write_rq_ctxts(func_to_io, base_qpn, num_qps));
+}
+
 /**
  * init_qp - Initialize a Queue Pair
  * @func_to_io: func to io channel that holds the IO components
@@ -265,8 +374,15 @@ int hinic_io_create_qps(struct hinic_func_to_io *func_to_io,
 		}
 	}
 
+	err = write_qp_ctxts(func_to_io, base_qpn, num_qps);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to init QP ctxts\n");
+		goto err_write_qp_ctxts;
+	}
+
 	return 0;
 
+err_write_qp_ctxts:
 err_init_qp:
 	for (j = 0; j < i; j++)
 		destroy_qp(func_to_io, &func_to_io->qps[j]);
@@ -331,6 +447,8 @@ int hinic_io_init(struct hinic_func_to_io *func_to_io,
 		  struct msix_entry *ceq_msix_entries)
 {
 	struct pci_dev *pdev = hwif->pdev;
+	enum hinic_cmdq_type cmdq, type;
+	void __iomem *db_area;
 	int err;
 
 	func_to_io->hwif = hwif;
@@ -351,8 +469,34 @@ int hinic_io_init(struct hinic_func_to_io *func_to_io,
 	}
 
 	init_db_area_idx(&func_to_io->free_db_area);
+
+	for (cmdq = HINIC_CMDQ_SYNC; cmdq < HINIC_MAX_CMDQ_TYPES; cmdq++) {
+		db_area = get_db_area(func_to_io);
+		if (IS_ERR(db_area)) {
+			dev_err(&pdev->dev, "Failed to get cmdq db area\n");
+			err = PTR_ERR(db_area);
+			goto err_db_area;
+		}
+
+		func_to_io->cmdq_db_area[cmdq] = db_area;
+	}
+
+	err = hinic_init_cmdqs(&func_to_io->cmdqs, hwif,
+			       func_to_io->cmdq_db_area);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to initialize cmdqs\n");
+		goto err_init_cmdqs;
+	}
+
 	return 0;
 
+err_init_cmdqs:
+err_db_area:
+	for (type = HINIC_CMDQ_SYNC; type < cmdq; type++)
+		return_db_area(func_to_io, func_to_io->cmdq_db_area[type]);
+
+	iounmap(func_to_io->db_base);
+
 err_db_ioremap:
 	hinic_wqs_free(&func_to_io->wqs);
 	return err;
@@ -364,6 +508,13 @@ int hinic_io_init(struct hinic_func_to_io *func_to_io,
  **/
 void hinic_io_free(struct hinic_func_to_io *func_to_io)
 {
+	enum hinic_cmdq_type cmdq;
+
+	hinic_free_cmdqs(&func_to_io->cmdqs);
+
+	for (cmdq = HINIC_CMDQ_SYNC; cmdq < HINIC_MAX_CMDQ_TYPES; cmdq++)
+		return_db_area(func_to_io, func_to_io->cmdq_db_area[cmdq]);
+
 	iounmap(func_to_io->db_base);
 	hinic_wqs_free(&func_to_io->wqs);
 }
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_io.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_io.h
index 2d85a38..60d77b34 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_io.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_io.h
@@ -23,6 +23,7 @@
 
 #include "hinic_hw_if.h"
 #include "hinic_hw_wq.h"
+#include "hinic_hw_cmdq.h"
 #include "hinic_hw_qp.h"
 
 #define HINIC_DB_PAGE_SIZE      SZ_4K
@@ -60,6 +61,10 @@ struct hinic_func_to_io {
 	dma_addr_t              ci_dma_base;
 
 	struct hinic_free_db_area       free_db_area;
+
+	void __iomem                    *cmdq_db_area[HINIC_MAX_CMDQ_TYPES];
+
+	struct hinic_cmdqs              cmdqs;
 };
 
 int hinic_io_create_qps(struct hinic_func_to_io *func_to_io,
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.c
index 2b77b59..cfed040 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.c
@@ -21,13 +21,172 @@
 #include <linux/vmalloc.h>
 #include <linux/errno.h>
 #include <linux/sizes.h>
+#include <linux/atomic.h>
+#include <asm/byteorder.h>
 
+#include "hinic_common.h"
 #include "hinic_hw_if.h"
 #include "hinic_hw_wq.h"
+#include "hinic_hw_qp_ctxt.h"
 #include "hinic_hw_qp.h"
 
 #define SQ_DB_OFF               SZ_2K
 
+/* The number of cache line to prefetch Until threshold state */
+#define WQ_PREFETCH_MAX         2
+/* The number of cache line to prefetch After threshold state */
+#define WQ_PREFETCH_MIN         1
+/* Threshold state */
+#define WQ_PREFETCH_THRESHOLD   256
+
+/* size of the SQ/RQ ctxt */
+#define Q_CTXT_SIZE             48
+#define CTXT_RSVD               240
+
+#define SQ_CTXT_OFFSET(max_sqs, max_rqs, q_id)  \
+		(((max_rqs) + (max_sqs)) * CTXT_RSVD + (q_id) * Q_CTXT_SIZE)
+
+#define RQ_CTXT_OFFSET(max_sqs, max_rqs, q_id)  \
+		(((max_rqs) + (max_sqs)) * CTXT_RSVD + (max_sqs) * Q_CTXT_SIZE \
+		 + (q_id) * Q_CTXT_SIZE)
+
+#define SIZE_16BYTES(size)      (ALIGN(size, 16) >> 4)
+
+void hinic_qp_prepare_header(struct hinic_qp_ctxt_header *qp_ctxt_hdr,
+			     enum hinic_qp_ctxt_type ctxt_type,
+			     int num_queues, int max_queues)
+{
+	qp_ctxt_hdr->num_queues = num_queues;
+	qp_ctxt_hdr->queue_type = ctxt_type;
+
+	if (ctxt_type == HINIC_QP_CTXT_TYPE_SQ)
+		qp_ctxt_hdr->addr_offset = SQ_CTXT_OFFSET(max_queues,
+							  max_queues, 0);
+	else
+		qp_ctxt_hdr->addr_offset = RQ_CTXT_OFFSET(max_queues,
+							  max_queues, 0);
+
+	qp_ctxt_hdr->addr_offset = SIZE_16BYTES(qp_ctxt_hdr->addr_offset);
+
+	hinic_cpu_to_be32(qp_ctxt_hdr, sizeof(*qp_ctxt_hdr));
+}
+
+void hinic_sq_prepare_ctxt(struct hinic_sq_ctxt *sq_ctxt,
+			   struct hinic_sq *sq, u16 global_qid)
+{
+	u32 wq_page_pfn_hi, wq_page_pfn_lo, wq_block_pfn_hi, wq_block_pfn_lo;
+	u64 wq_page_addr, wq_page_pfn, wq_block_pfn;
+	u16 pi_start, ci_start;
+	struct hinic_wq *wq;
+
+	wq = sq->wq;
+	ci_start = atomic_read(&wq->cons_idx);
+	pi_start = atomic_read(&wq->prod_idx);
+
+	/* Read the first page paddr from the WQ page paddr ptrs */
+	wq_page_addr = be64_to_cpu(*wq->block_vaddr);
+
+	wq_page_pfn = HINIC_WQ_PAGE_PFN(wq_page_addr);
+	wq_page_pfn_hi = upper_32_bits(wq_page_pfn);
+	wq_page_pfn_lo = lower_32_bits(wq_page_pfn);
+
+	wq_block_pfn = HINIC_WQ_BLOCK_PFN(wq->block_paddr);
+	wq_block_pfn_hi = upper_32_bits(wq_block_pfn);
+	wq_block_pfn_lo = lower_32_bits(wq_block_pfn);
+
+	sq_ctxt->ceq_attr = HINIC_SQ_CTXT_CEQ_ATTR_SET(global_qid,
+						       GLOBAL_SQ_ID) |
+			    HINIC_SQ_CTXT_CEQ_ATTR_SET(0, EN);
+
+	sq_ctxt->ci_wrapped = HINIC_SQ_CTXT_CI_SET(ci_start, IDX) |
+			      HINIC_SQ_CTXT_CI_SET(1, WRAPPED);
+
+	sq_ctxt->wq_hi_pfn_pi =
+			HINIC_SQ_CTXT_WQ_PAGE_SET(wq_page_pfn_hi, HI_PFN) |
+			HINIC_SQ_CTXT_WQ_PAGE_SET(pi_start, PI);
+
+	sq_ctxt->wq_lo_pfn = wq_page_pfn_lo;
+
+	sq_ctxt->pref_cache =
+		HINIC_SQ_CTXT_PREF_SET(WQ_PREFETCH_MIN, CACHE_MIN) |
+		HINIC_SQ_CTXT_PREF_SET(WQ_PREFETCH_MAX, CACHE_MAX) |
+		HINIC_SQ_CTXT_PREF_SET(WQ_PREFETCH_THRESHOLD, CACHE_THRESHOLD);
+
+	sq_ctxt->pref_wrapped = 1;
+
+	sq_ctxt->pref_wq_hi_pfn_ci =
+		HINIC_SQ_CTXT_PREF_SET(ci_start, CI) |
+		HINIC_SQ_CTXT_PREF_SET(wq_page_pfn_hi, WQ_HI_PFN);
+
+	sq_ctxt->pref_wq_lo_pfn = wq_page_pfn_lo;
+
+	sq_ctxt->wq_block_hi_pfn =
+		HINIC_SQ_CTXT_WQ_BLOCK_SET(wq_block_pfn_hi, HI_PFN);
+
+	sq_ctxt->wq_block_lo_pfn = wq_block_pfn_lo;
+
+	hinic_cpu_to_be32(sq_ctxt, sizeof(*sq_ctxt));
+}
+
+void hinic_rq_prepare_ctxt(struct hinic_rq_ctxt *rq_ctxt,
+			   struct hinic_rq *rq, u16 global_qid)
+{
+	u32 wq_page_pfn_hi, wq_page_pfn_lo, wq_block_pfn_hi, wq_block_pfn_lo;
+	u64 wq_page_addr, wq_page_pfn, wq_block_pfn;
+	u16 pi_start, ci_start;
+	struct hinic_wq *wq;
+
+	wq = rq->wq;
+	ci_start = atomic_read(&wq->cons_idx);
+	pi_start = atomic_read(&wq->prod_idx);
+
+	/* Read the first page paddr from the WQ page paddr ptrs */
+	wq_page_addr = be64_to_cpu(*wq->block_vaddr);
+
+	wq_page_pfn = HINIC_WQ_PAGE_PFN(wq_page_addr);
+	wq_page_pfn_hi = upper_32_bits(wq_page_pfn);
+	wq_page_pfn_lo = lower_32_bits(wq_page_pfn);
+
+	wq_block_pfn = HINIC_WQ_BLOCK_PFN(wq->block_paddr);
+	wq_block_pfn_hi = upper_32_bits(wq_block_pfn);
+	wq_block_pfn_lo = lower_32_bits(wq_block_pfn);
+
+	rq_ctxt->ceq_attr = HINIC_RQ_CTXT_CEQ_ATTR_SET(0, EN) |
+			    HINIC_RQ_CTXT_CEQ_ATTR_SET(1, WRAPPED);
+
+	rq_ctxt->pi_intr_attr = HINIC_RQ_CTXT_PI_SET(pi_start, IDX) |
+				HINIC_RQ_CTXT_PI_SET(rq->msix_entry, INTR);
+
+	rq_ctxt->wq_hi_pfn_ci = HINIC_RQ_CTXT_WQ_PAGE_SET(wq_page_pfn_hi,
+							  HI_PFN) |
+				HINIC_RQ_CTXT_WQ_PAGE_SET(ci_start, CI);
+
+	rq_ctxt->wq_lo_pfn = wq_page_pfn_lo;
+
+	rq_ctxt->pref_cache =
+		HINIC_RQ_CTXT_PREF_SET(WQ_PREFETCH_MIN, CACHE_MIN) |
+		HINIC_RQ_CTXT_PREF_SET(WQ_PREFETCH_MAX, CACHE_MAX) |
+		HINIC_RQ_CTXT_PREF_SET(WQ_PREFETCH_THRESHOLD, CACHE_THRESHOLD);
+
+	rq_ctxt->pref_wrapped = 1;
+
+	rq_ctxt->pref_wq_hi_pfn_ci =
+		HINIC_RQ_CTXT_PREF_SET(wq_page_pfn_hi, WQ_HI_PFN) |
+		HINIC_RQ_CTXT_PREF_SET(ci_start, CI);
+
+	rq_ctxt->pref_wq_lo_pfn = wq_page_pfn_lo;
+
+	rq_ctxt->pi_paddr_hi = upper_32_bits(rq->pi_dma_addr);
+	rq_ctxt->pi_paddr_lo = lower_32_bits(rq->pi_dma_addr);
+
+	rq_ctxt->wq_block_hi_pfn =
+		HINIC_RQ_CTXT_WQ_BLOCK_SET(wq_block_pfn_hi, HI_PFN);
+
+	rq_ctxt->wq_block_lo_pfn = wq_block_pfn_lo;
+
+	hinic_cpu_to_be32(rq_ctxt, sizeof(*rq_ctxt));
+}
+
 /**
  * alloc_sq_skb_arr - allocate sq array for saved skb
  * @sq: HW Send Queue
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h
index c5ec30d..eb10bd9 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h
@@ -24,6 +24,7 @@
 #include "hinic_hw_if.h"
 #include "hinic_hw_wqe.h"
 #include "hinic_hw_wq.h"
+#include "hinic_hw_qp_ctxt.h"
 
 #define HINIC_SQ_WQEBB_SIZE                     64
 #define HINIC_RQ_WQEBB_SIZE                     32
@@ -78,6 +79,16 @@ struct hinic_qp {
 	u16     q_id;
 };
 
+void hinic_qp_prepare_header(struct hinic_qp_ctxt_header *qp_ctxt_hdr,
+			     enum hinic_qp_ctxt_type ctxt_type,
+			     int num_queues, int max_queues);
+
+void hinic_sq_prepare_ctxt(struct hinic_sq_ctxt *sq_ctxt,
+			   struct hinic_sq *sq, u16 global_qid);
+
+void hinic_rq_prepare_ctxt(struct hinic_rq_ctxt *rq_ctxt,
+			   struct hinic_rq *rq, u16 global_qid);
+
 int hinic_init_sq(struct hinic_sq *sq, struct hinic_hwif *hwif,
 		  struct hinic_wq *wq, struct msix_entry *entry, void *ci_addr,
 		  dma_addr_t ci_dma_addr, void __iomem *db_base);
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_qp_ctxt.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_qp_ctxt.h
new file mode 100644
index 0000000..376abf0
--- /dev/null
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_qp_ctxt.h
@@ -0,0 +1,214 @@
+/*
+ * Huawei HiNIC PCI Express Linux driver
+ * Copyright(c) 2017 Huawei Technologies Co., Ltd
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
+ * for more details.
+ *
+ */
+
+#ifndef HINIC_HW_QP_CTXT_H
+#define HINIC_HW_QP_CTXT_H
+
+#include <linux/types.h>
+
+#include "hinic_hw_cmdq.h"
+
+#define HINIC_SQ_CTXT_CEQ_ATTR_GLOBAL_SQ_ID_SHIFT       13
+#define HINIC_SQ_CTXT_CEQ_ATTR_EN_SHIFT                 23
+
+#define HINIC_SQ_CTXT_CEQ_ATTR_GLOBAL_SQ_ID_MASK        0x3FF
+#define HINIC_SQ_CTXT_CEQ_ATTR_EN_MASK                  0x1
+
+#define HINIC_SQ_CTXT_CEQ_ATTR_SET(val, member)         \
+	(((u32)(val) & HINIC_SQ_CTXT_CEQ_ATTR_##member##_MASK) \
+	 << HINIC_SQ_CTXT_CEQ_ATTR_##member##_SHIFT)
+
+#define HINIC_SQ_CTXT_CI_IDX_SHIFT                      11
+#define HINIC_SQ_CTXT_CI_WRAPPED_SHIFT                  23
+
+#define HINIC_SQ_CTXT_CI_IDX_MASK                       0xFFF
+#define HINIC_SQ_CTXT_CI_WRAPPED_MASK                   0x1
+
+#define HINIC_SQ_CTXT_CI_SET(val, member)               \
+	(((u32)(val) & HINIC_SQ_CTXT_CI_##member##_MASK) \
+	 << HINIC_SQ_CTXT_CI_##member##_SHIFT)
+
+#define HINIC_SQ_CTXT_WQ_PAGE_HI_PFN_SHIFT              0
+#define HINIC_SQ_CTXT_WQ_PAGE_PI_SHIFT                  20
+
+#define HINIC_SQ_CTXT_WQ_PAGE_HI_PFN_MASK               0xFFFFF
+#define HINIC_SQ_CTXT_WQ_PAGE_PI_MASK                   0xFFF
+
+#define HINIC_SQ_CTXT_WQ_PAGE_SET(val, member)          \
+	(((u32)(val) & HINIC_SQ_CTXT_WQ_PAGE_##member##_MASK) \
+	 << HINIC_SQ_CTXT_WQ_PAGE_##member##_SHIFT)
+
+#define HINIC_SQ_CTXT_PREF_CACHE_THRESHOLD_SHIFT        0
+#define HINIC_SQ_CTXT_PREF_CACHE_MAX_SHIFT              14
+#define HINIC_SQ_CTXT_PREF_CACHE_MIN_SHIFT              25
+
+#define HINIC_SQ_CTXT_PREF_CACHE_THRESHOLD_MASK         0x3FFF
+#define HINIC_SQ_CTXT_PREF_CACHE_MAX_MASK               0x7FF
+#define HINIC_SQ_CTXT_PREF_CACHE_MIN_MASK               0x7F
+
+#define HINIC_SQ_CTXT_PREF_WQ_HI_PFN_SHIFT              0
+#define HINIC_SQ_CTXT_PREF_CI_SHIFT                     20
+
+#define HINIC_SQ_CTXT_PREF_WQ_HI_PFN_MASK               0xFFFFF
+#define HINIC_SQ_CTXT_PREF_CI_MASK                      0xFFF
+
+#define HINIC_SQ_CTXT_PREF_SET(val, member)             \
+	(((u32)(val) & HINIC_SQ_CTXT_PREF_##member##_MASK) \
+	 << HINIC_SQ_CTXT_PREF_##member##_SHIFT)
+
+#define HINIC_SQ_CTXT_WQ_BLOCK_HI_PFN_SHIFT             0
+
+#define HINIC_SQ_CTXT_WQ_BLOCK_HI_PFN_MASK              0x7FFFFF
+
+#define HINIC_SQ_CTXT_WQ_BLOCK_SET(val, member)         \
+	(((u32)(val) & HINIC_SQ_CTXT_WQ_BLOCK_##member##_MASK) \
+	 << HINIC_SQ_CTXT_WQ_BLOCK_##member##_SHIFT)
+
+#define HINIC_RQ_CTXT_CEQ_ATTR_EN_SHIFT                 0
+#define HINIC_RQ_CTXT_CEQ_ATTR_WRAPPED_SHIFT            1
+
+#define HINIC_RQ_CTXT_CEQ_ATTR_EN_MASK                  0x1
+#define HINIC_RQ_CTXT_CEQ_ATTR_WRAPPED_MASK             0x1
+
+#define HINIC_RQ_CTXT_CEQ_ATTR_SET(val, member)         \
+	(((u32)(val) & HINIC_RQ_CTXT_CEQ_ATTR_##member##_MASK) \
+	 << HINIC_RQ_CTXT_CEQ_ATTR_##member##_SHIFT)
+
+#define HINIC_RQ_CTXT_PI_IDX_SHIFT                      0
+#define HINIC_RQ_CTXT_PI_INTR_SHIFT                     22
+
+#define HINIC_RQ_CTXT_PI_IDX_MASK                       0xFFF
+#define HINIC_RQ_CTXT_PI_INTR_MASK                      0x3FF
+
+#define HINIC_RQ_CTXT_PI_SET(val, member)               \
+	(((u32)(val) & HINIC_RQ_CTXT_PI_##member##_MASK) << \
+	 HINIC_RQ_CTXT_PI_##member##_SHIFT)
+
+#define HINIC_RQ_CTXT_WQ_PAGE_HI_PFN_SHIFT              0
+#define HINIC_RQ_CTXT_WQ_PAGE_CI_SHIFT                  20
+
+#define HINIC_RQ_CTXT_WQ_PAGE_HI_PFN_MASK               0xFFFFF
+#define HINIC_RQ_CTXT_WQ_PAGE_CI_MASK                   0xFFF
+
+#define HINIC_RQ_CTXT_WQ_PAGE_SET(val, member)          \
+	(((u32)(val) & HINIC_RQ_CTXT_WQ_PAGE_##member##_MASK) << \
+	 HINIC_RQ_CTXT_WQ_PAGE_##member##_SHIFT)
+
+#define HINIC_RQ_CTXT_PREF_CACHE_THRESHOLD_SHIFT        0
+#define HINIC_RQ_CTXT_PREF_CACHE_MAX_SHIFT              14
+#define HINIC_RQ_CTXT_PREF_CACHE_MIN_SHIFT              25
+
+#define HINIC_RQ_CTXT_PREF_CACHE_THRESHOLD_MASK         0x3FFF
+#define HINIC_RQ_CTXT_PREF_CACHE_MAX_MASK               0x7FF
+#define HINIC_RQ_CTXT_PREF_CACHE_MIN_MASK               0x7F
+
+#define HINIC_RQ_CTXT_PREF_WQ_HI_PFN_SHIFT              0
+#define HINIC_RQ_CTXT_PREF_CI_SHIFT                     20
+
+#define HINIC_RQ_CTXT_PREF_WQ_HI_PFN_MASK               0xFFFFF
+#define HINIC_RQ_CTXT_PREF_CI_MASK                      0xFFF
+
+#define HINIC_RQ_CTXT_PREF_SET(val, member)             \
+	(((u32)(val) & HINIC_RQ_CTXT_PREF_##member##_MASK) << \
+	 HINIC_RQ_CTXT_PREF_##member##_SHIFT)
+
+#define HINIC_RQ_CTXT_WQ_BLOCK_HI_PFN_SHIFT             0
+
+#define HINIC_RQ_CTXT_WQ_BLOCK_HI_PFN_MASK              0x7FFFFF
+
+#define HINIC_RQ_CTXT_WQ_BLOCK_SET(val, member)         \
+	(((u32)(val) & HINIC_RQ_CTXT_WQ_BLOCK_##member##_MASK) << \
+	 HINIC_RQ_CTXT_WQ_BLOCK_##member##_SHIFT)
+
+#define HINIC_SQ_CTXT_SIZE(num_sqs) (sizeof(struct hinic_qp_ctxt_header) \
+				     + (num_sqs) * sizeof(struct hinic_sq_ctxt))
+
+#define HINIC_RQ_CTXT_SIZE(num_rqs) (sizeof(struct hinic_qp_ctxt_header) \
+				     + (num_rqs) * sizeof(struct hinic_rq_ctxt))
+
+#define HINIC_WQ_PAGE_PFN_SHIFT         12
+#define HINIC_WQ_BLOCK_PFN_SHIFT        9
+
+#define HINIC_WQ_PAGE_PFN(page_addr)    ((page_addr) >> HINIC_WQ_PAGE_PFN_SHIFT)
+#define HINIC_WQ_BLOCK_PFN(page_addr)   ((page_addr) >> \
+					 HINIC_WQ_BLOCK_PFN_SHIFT)
+
+#define HINIC_Q_CTXT_MAX                \
+		((HINIC_CMDQ_BUF_SIZE - sizeof(struct hinic_qp_ctxt_header)) \
+		 / sizeof(struct hinic_sq_ctxt))
+
+enum hinic_qp_ctxt_type {
+	HINIC_QP_CTXT_TYPE_SQ,
+	HINIC_QP_CTXT_TYPE_RQ
+};
+
+struct hinic_qp_ctxt_header {
+	u16     num_queues;
+	u16     queue_type;
+	u32     addr_offset;
+};
+
+struct hinic_sq_ctxt {
+	u32     ceq_attr;
+
+	u32     ci_wrapped;
+
+	u32     wq_hi_pfn_pi;
+	u32     wq_lo_pfn;
+
+	u32     pref_cache;
+	u32     pref_wrapped;
+	u32     pref_wq_hi_pfn_ci;
+	u32     pref_wq_lo_pfn;
+
+	u32     rsvd0;
+	u32     rsvd1;
+
+	u32     wq_block_hi_pfn;
+	u32     wq_block_lo_pfn;
+};
+
+struct hinic_rq_ctxt {
+	u32     ceq_attr;
+
+	u32     pi_intr_attr;
+
+	u32     wq_hi_pfn_ci;
+	u32     wq_lo_pfn;
+
+	u32     pref_cache;
+	u32     pref_wrapped;
+
+	u32     pref_wq_hi_pfn_ci;
+	u32     pref_wq_lo_pfn;
+
+	u32     pi_paddr_hi;
+	u32     pi_paddr_lo;
+
+	u32     wq_block_hi_pfn;
+	u32     wq_block_lo_pfn;
+};
+
+struct hinic_sq_ctxt_block {
+	struct hinic_qp_ctxt_header hdr;
+	struct hinic_sq_ctxt sq_ctxt[HINIC_Q_CTXT_MAX];
+};
+
+struct hinic_rq_ctxt_block {
+	struct hinic_qp_ctxt_header hdr;
+	struct hinic_rq_ctxt rq_ctxt[HINIC_Q_CTXT_MAX];
+};
+
+#endif
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_wq.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_wq.h
index 7c114da..8ce259a 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_wq.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_wq.h
@@ -72,6 +72,15 @@ struct hinic_wqs {
 	struct semaphore        alloc_blocks_lock;
 };
 
+struct hinic_cmdq_pages {
+	/* The addresses are 64 bit in the HW */
+	u64                     page_paddr;
+	u64                     *page_vaddr;
+	void                    **shadow_page_vaddr;
+
+	struct hinic_hwif       *hwif;
+};
+
 int hinic_wqs_alloc(struct hinic_wqs *wqs, int num_wqs,
 		    struct hinic_hwif *hwif);
 
-- 
1.9.1
