From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Subject: [PATCH V2 net-next 12/21] net-next/hinic: Add qp resources
Date: Wed, 19 Jul 2017 17:19:10 +0800
Message-ID: <493b105a36b5ddcf3570ed165aedfb4d6517ee6e.1500454998.git.aviad.krawczyk@huawei.com>
References: <cover.1500454998.git.aviad.krawczyk@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <bc.y@huawei.com>, <victor.gissin@huawei.com>,
        <aviad.krawczyk@huawei.com>, <zhaochen6@huawei.com>,
        <tony.qu@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([45.249.212.188]:10320 "EHLO
        szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753461AbdGSJZS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 05:25:18 -0400
In-Reply-To: <cover.1500454998.git.aviad.krawczyk@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Create the resources for queue pair operations: doorbell area,
consumer index address and producer index address.

Signed-off-by: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Signed-off-by: Zhao Chen <zhaochen6@huawei.com>
---
 drivers/net/ethernet/huawei/hinic/Makefile      |   4 +-
 drivers/net/ethernet/huawei/hinic/hinic_hw_if.h |   1 +
 drivers/net/ethernet/huawei/hinic/hinic_hw_io.c | 167 ++++++++++++++-
 drivers/net/ethernet/huawei/hinic/hinic_hw_io.h |  27 +++
 drivers/net/ethernet/huawei/hinic/hinic_hw_qp.c | 264 ++++++++++++++++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h |  60 +++++-
 6 files changed, 518 insertions(+), 5 deletions(-)
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_qp.c

diff --git a/drivers/net/ethernet/huawei/hinic/Makefile b/drivers/net/ethernet/huawei/hinic/Makefile
index 519382b..24728f0 100644
--- a/drivers/net/ethernet/huawei/hinic/Makefile
+++ b/drivers/net/ethernet/huawei/hinic/Makefile
@@ -1,5 +1,5 @@
 obj-$(CONFIG_HINIC) += hinic.o
 
 hinic-y := hinic_main.o hinic_tx.o hinic_rx.o hinic_port.o hinic_hw_dev.o \
-	   hinic_hw_io.o hinic_hw_wq.o hinic_hw_mgmt.o hinic_hw_api_cmd.o \
-	   hinic_hw_eqs.o hinic_hw_if.o
\ No newline at end of file
+	   hinic_hw_io.o hinic_hw_qp.o hinic_hw_wq.o hinic_hw_mgmt.o \
+	   hinic_hw_api_cmd.o hinic_hw_eqs.o hinic_hw_if.o
\ No newline at end of file
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_if.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_if.h
index 88df3c0..89f71e5 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_if.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_if.h
@@ -137,6 +137,7 @@
 #define HINIC_IS_PPF(hwif)              (HINIC_FUNC_TYPE(hwif) == HINIC_PPF)
 
 #define HINIC_PCI_CFG_REGS_BAR          0
+#define HINIC_PCI_DB_BAR                4
 
 #define HINIC_PCIE_ST_DISABLE           0
 #define HINIC_PCIE_AT_DISABLE           0
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_io.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_io.c
index 419fcb0..fa789da 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_io.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_io.c
@@ -13,17 +13,93 @@
  *
  */
 
+#include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/pci.h>
 #include <linux/device.h>
 #include <linux/errno.h>
 #include <linux/slab.h>
+#include <linux/semaphore.h>
+#include <linux/dma-mapping.h>
+#include <linux/io.h>
 
 #include "hinic_hw_if.h"
 #include "hinic_hw_wq.h"
 #include "hinic_hw_qp.h"
 #include "hinic_hw_io.h"
 
+#define CI_Q_ADDR_SIZE                  sizeof(u32)
+
+#define CI_ADDR(base_addr, q_id)        ((base_addr) + \
+					 (q_id) * CI_Q_ADDR_SIZE)
+
+#define CI_TABLE_SIZE(num_qps)          ((num_qps) * CI_Q_ADDR_SIZE)
+
+#define DB_IDX(db, db_base)             \
+	(((unsigned long)(db) - (unsigned long)(db_base)) / HINIC_DB_PAGE_SIZE)
+
+static void init_db_area_idx(struct hinic_free_db_area *free_db_area)
+{
+	int i;
+
+	for (i = 0; i < HINIC_DB_MAX_AREAS; i++)
+		free_db_area->db_idx[i] = i;
+
+	free_db_area->alloc_pos = 0;
+	free_db_area->return_pos = HINIC_DB_MAX_AREAS;
+
+	free_db_area->num_free = HINIC_DB_MAX_AREAS;
+
+	sema_init(&free_db_area->idx_lock, 1);
+}
+
+static int get_db_area(struct hinic_func_to_io *func_to_io,
+		       void __iomem **db_base)
+{
+	struct hinic_free_db_area *free_db_area = &func_to_io->free_db_area;
+	int pos, idx;
+
+	down(&free_db_area->idx_lock);
+
+	free_db_area->num_free--;
+
+	if (free_db_area->num_free < 0) {
+		free_db_area->num_free++;
+		up(&free_db_area->idx_lock);
+		return -ENOMEM;
+	}
+
+	pos = free_db_area->alloc_pos++;
+	pos &= HINIC_DB_MAX_AREAS - 1;
+
+	idx = free_db_area->db_idx[pos];
+
+	free_db_area->db_idx[pos] = -1;
+
+	up(&free_db_area->idx_lock);
+
+	*db_base = func_to_io->db_base + idx * HINIC_DB_PAGE_SIZE;
+	return 0;
+}
+
+static void return_db_area(struct hinic_func_to_io *func_to_io,
+			   void __iomem *db_base)
+{
+	struct hinic_free_db_area *free_db_area = &func_to_io->free_db_area;
+	int pos, idx = DB_IDX(db_base, func_to_io->db_base);
+
+	down(&free_db_area->idx_lock);
+
+	pos = free_db_area->return_pos++;
+	pos &= HINIC_DB_MAX_AREAS - 1;
+
+	free_db_area->db_idx[pos] = idx;
+
+	free_db_area->num_free++;
+
+	up(&free_db_area->idx_lock);
+}
+
 /**
  * init_qp - Initialize a Queue Pair
  * @func_to_io: func to io channel that holds the IO components
@@ -41,6 +117,9 @@ static int init_qp(struct hinic_func_to_io *func_to_io,
 {
 	struct hinic_hwif *hwif = func_to_io->hwif;
 	struct pci_dev *pdev = hwif->pdev;
+	void *ci_addr_base = func_to_io->ci_addr_base;
+	dma_addr_t ci_dma_base = func_to_io->ci_dma_base;
+	void __iomem *db_base;
 	int err;
 
 	qp->q_id = q_id;
@@ -61,8 +140,40 @@ static int init_qp(struct hinic_func_to_io *func_to_io,
 		goto rq_alloc_err;
 	}
 
+	err = get_db_area(func_to_io, &db_base);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to get DB area for SQ\n");
+		goto get_db_err;
+	}
+
+	func_to_io->sq_db[q_id] = db_base;
+
+	err = hinic_init_sq(&qp->sq, hwif, &func_to_io->sq_wq[q_id],
+			    sq_msix_entry, CI_ADDR(ci_addr_base, q_id),
+			    CI_ADDR(ci_dma_base, q_id), db_base);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to init SQ\n");
+		goto sq_init_err;
+	}
+
+	err = hinic_init_rq(&qp->rq, hwif, &func_to_io->rq_wq[q_id],
+			    rq_msix_entry);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to init RQ\n");
+		goto rq_init_err;
+	}
+
 	return 0;
 
+rq_init_err:
+	hinic_clean_sq(&qp->sq);
+
+sq_init_err:
+	return_db_area(func_to_io, db_base);
+
+get_db_err:
+	hinic_wq_free(&func_to_io->wqs, &func_to_io->rq_wq[q_id]);
+
 rq_alloc_err:
 	hinic_wq_free(&func_to_io->wqs, &func_to_io->sq_wq[q_id]);
 	return err;
@@ -78,6 +189,11 @@ static void destroy_qp(struct hinic_func_to_io *func_to_io,
 {
 	int q_id = qp->q_id;
 
+	hinic_clean_rq(&qp->rq);
+	hinic_clean_sq(&qp->sq);
+
+	return_db_area(func_to_io, func_to_io->sq_db[q_id]);
+
 	hinic_wq_free(&func_to_io->wqs, &func_to_io->rq_wq[q_id]);
 	hinic_wq_free(&func_to_io->wqs, &func_to_io->sq_wq[q_id]);
 }
@@ -99,7 +215,8 @@ int hinic_io_create_qps(struct hinic_func_to_io *func_to_io,
 {
 	struct hinic_hwif *hwif = func_to_io->hwif;
 	struct pci_dev *pdev = hwif->pdev;
-	size_t qps_size, wq_size;
+	void *ci_addr_base;
+	size_t qps_size, wq_size, db_size, ci_table_size;
 	int i, j, err;
 
 	qps_size = num_qps * sizeof(*func_to_io->qps);
@@ -121,6 +238,26 @@ int hinic_io_create_qps(struct hinic_func_to_io *func_to_io,
 		goto rq_wq_err;
 	}
 
+	db_size = num_qps * sizeof(*func_to_io->sq_db);
+	func_to_io->sq_db = devm_kzalloc(&pdev->dev, db_size, GFP_KERNEL);
+	if (!func_to_io->sq_db) {
+		err = -ENOMEM;
+		goto sq_db_err;
+	}
+
+	ci_table_size = CI_TABLE_SIZE(num_qps);
+
+	ci_addr_base = dma_zalloc_coherent(&pdev->dev, ci_table_size,
+					   &func_to_io->ci_dma_base,
+					   GFP_KERNEL);
+	if (!ci_addr_base) {
+		dev_err(&pdev->dev, "Failed to allocate CI area\n");
+		err = -ENOMEM;
+		goto ci_base_err;
+	}
+
+	func_to_io->ci_addr_base = ci_addr_base;
+
 	for (i = 0; i < num_qps; i++) {
 		err = init_qp(func_to_io, &func_to_io->qps[i], i,
 			      &sq_msix_entries[i], &rq_msix_entries[i]);
@@ -136,6 +273,13 @@ int hinic_io_create_qps(struct hinic_func_to_io *func_to_io,
 	for (j = 0; j < i; j++)
 		destroy_qp(func_to_io, &func_to_io->qps[j]);
 
+	dma_free_coherent(&pdev->dev, ci_table_size, func_to_io->ci_addr_base,
+			  func_to_io->ci_dma_base);
+
+ci_base_err:
+	devm_kfree(&pdev->dev, func_to_io->sq_db);
+
+sq_db_err:
 	devm_kfree(&pdev->dev, func_to_io->rq_wq);
 
 rq_wq_err:
@@ -155,11 +299,19 @@ void hinic_io_destroy_qps(struct hinic_func_to_io *func_to_io, int num_qps)
 {
 	struct hinic_hwif *hwif = func_to_io->hwif;
 	struct pci_dev *pdev = hwif->pdev;
+	size_t ci_table_size;
 	int i;
 
+	ci_table_size = CI_TABLE_SIZE(num_qps);
+
 	for (i = 0; i < num_qps; i++)
 		destroy_qp(func_to_io, &func_to_io->qps[i]);
 
+	dma_free_coherent(&pdev->dev, ci_table_size, func_to_io->ci_addr_base,
+			  func_to_io->ci_dma_base);
+
+	devm_kfree(&pdev->dev, func_to_io->sq_db);
+
 	devm_kfree(&pdev->dev, func_to_io->rq_wq);
 	devm_kfree(&pdev->dev, func_to_io->sq_wq);
 
@@ -193,7 +345,19 @@ int hinic_io_init(struct hinic_func_to_io *func_to_io,
 		return err;
 	}
 
+	func_to_io->db_base = pci_ioremap_bar(pdev, HINIC_PCI_DB_BAR);
+	if (!func_to_io->db_base) {
+		dev_err(&pdev->dev, "Failed to remap IO DB area\n");
+		err = -ENOMEM;
+		goto db_ioremap_err;
+	}
+
+	init_db_area_idx(&func_to_io->free_db_area);
 	return 0;
+
+db_ioremap_err:
+	hinic_wqs_free(&func_to_io->wqs);
+	return err;
 }
 
 /**
@@ -202,5 +366,6 @@ int hinic_io_init(struct hinic_func_to_io *func_to_io,
  **/
 void hinic_io_free(struct hinic_func_to_io *func_to_io)
 {
+	iounmap(func_to_io->db_base);
 	hinic_wqs_free(&func_to_io->wqs);
 }
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_io.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_io.h
index 6cacb8e..2d85a38 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_io.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_io.h
@@ -18,11 +18,30 @@
 
 #include <linux/types.h>
 #include <linux/pci.h>
+#include <linux/semaphore.h>
+#include <linux/sizes.h>
 
 #include "hinic_hw_if.h"
 #include "hinic_hw_wq.h"
 #include "hinic_hw_qp.h"
 
+#define HINIC_DB_PAGE_SIZE      SZ_4K
+#define HINIC_DB_SIZE           SZ_4M
+
+#define HINIC_DB_MAX_AREAS      (HINIC_DB_SIZE / HINIC_DB_PAGE_SIZE)
+
+struct hinic_free_db_area {
+	int             db_idx[HINIC_DB_MAX_AREAS];
+
+	int             alloc_pos;
+	int             return_pos;
+
+	int             num_free;
+
+	/* Lock for getting db area */
+	struct semaphore        idx_lock;
+};
+
 struct hinic_func_to_io {
 	struct hinic_hwif       *hwif;
 
@@ -33,6 +52,14 @@ struct hinic_func_to_io {
 
 	struct hinic_qp         *qps;
 	u16                     max_qps;
+
+	void __iomem            **sq_db;
+	void __iomem            *db_base;
+
+	void                    *ci_addr_base;
+	dma_addr_t              ci_dma_base;
+
+	struct hinic_free_db_area       free_db_area;
 };
 
 int hinic_io_create_qps(struct hinic_func_to_io *func_to_io,
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.c
new file mode 100644
index 0000000..3d33136
--- /dev/null
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.c
@@ -0,0 +1,264 @@
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
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/pci.h>
+#include <linux/device.h>
+#include <linux/dma-mapping.h>
+#include <linux/vmalloc.h>
+#include <linux/errno.h>
+#include <linux/sizes.h>
+
+#include "hinic_hw_if.h"
+#include "hinic_hw_wq.h"
+#include "hinic_hw_qp.h"
+
+#define SQ_DB_OFF               SZ_2K
+
+/**
+ * alloc_sq_priv - allocate sq private data space
+ * @sq: HW Send Queue
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+static int alloc_sq_priv(struct hinic_sq *sq)
+{
+	struct hinic_wq *wq = sq->wq;
+	size_t priv_size = wq->q_depth * sizeof(*sq->priv);
+
+	sq->priv = vzalloc(priv_size);
+	if (!sq->priv)
+		return -ENOMEM;
+
+	return 0;
+}
+
+/**
+ * free_sq_priv - free sq private data space
+ * @sq: HW Send Queue
+ **/
+static void free_sq_priv(struct hinic_sq *sq)
+{
+	vfree(sq->priv);
+}
+
+/**
+ * alloc_rq_priv - allocate rq private data space
+ * @rq: HW Receive Queue
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+static int alloc_rq_priv(struct hinic_rq *rq)
+{
+	struct hinic_wq *wq = rq->wq;
+	size_t priv_size = wq->q_depth * sizeof(*rq->priv);
+
+	rq->priv = vzalloc(priv_size);
+	if (!rq->priv)
+		return -ENOMEM;
+
+	return 0;
+}
+
+/**
+ * free_rq_priv - free rq private data space
+ * @rq: HW Receive Queue
+ **/
+static void free_rq_priv(struct hinic_rq *rq)
+{
+	vfree(rq->priv);
+}
+
+/**
+ * hinic_init_sq - Initialize HW Send Queue
+ * @sq: HW Send Queue
+ * @hwif: HW Interface for accessing HW
+ * @wq: Work Queue for the data of the SQ
+ * @entry: msix entry for sq
+ * @ci_addr: address for reading the current HW consumer index
+ * @ci_dma_addr: dma address for reading the current HW consumer index
+ * @db_base: doorbell base address
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+int hinic_init_sq(struct hinic_sq *sq, struct hinic_hwif *hwif,
+		  struct hinic_wq *wq, struct msix_entry *entry,
+		  void *ci_addr, dma_addr_t ci_dma_addr,
+		  void __iomem *db_base)
+{
+	sq->hwif = hwif;
+
+	sq->wq = wq;
+
+	sq->irq = entry->vector;
+	sq->msix_entry = entry->entry;
+
+	sq->hw_ci_addr = ci_addr;
+	sq->hw_ci_dma_addr = ci_dma_addr;
+
+	sq->db_base = db_base + SQ_DB_OFF;
+
+	return alloc_sq_priv(sq);
+}
+
+/**
+ * hinic_clean_sq - Clean HW Send Queue's Resources
+ * @sq: Send Queue
+ **/
+void hinic_clean_sq(struct hinic_sq *sq)
+{
+	free_sq_priv(sq);
+}
+
+/**
+ * alloc_rq_cqe - allocate rq completion queue elements
+ * @rq: HW Receive Queue
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+static int alloc_rq_cqe(struct hinic_rq *rq)
+{
+	struct hinic_hwif *hwif = rq->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	struct hinic_wq *wq = rq->wq;
+	size_t cqe_dma_size, cqe_size;
+	int j, i;
+
+	cqe_size = wq->q_depth * sizeof(*rq->cqe);
+	rq->cqe = vzalloc(cqe_size);
+	if (!rq->cqe)
+		return -ENOMEM;
+
+	cqe_dma_size = wq->q_depth * sizeof(*rq->cqe_dma);
+	rq->cqe_dma = vzalloc(cqe_dma_size);
+	if (!rq->cqe_dma)
+		goto cqe_dma_arr_alloc_err;
+
+	for (i = 0; i < wq->q_depth; i++) {
+		rq->cqe[i] = dma_zalloc_coherent(&pdev->dev,
+						 sizeof(*rq->cqe[i]),
+						 &rq->cqe_dma[i], GFP_KERNEL);
+		if (!rq->cqe[i])
+			goto cqe_alloc_err;
+	}
+
+	return 0;
+
+cqe_alloc_err:
+	for (j = 0; j < i; j++)
+		dma_free_coherent(&pdev->dev, sizeof(*rq->cqe[j]), rq->cqe[j],
+				  rq->cqe_dma[j]);
+
+	vfree(rq->cqe_dma);
+
+cqe_dma_arr_alloc_err:
+	vfree(rq->cqe);
+	return -ENOMEM;
+}
+
+/**
+ * free_rq_cqe - free rq completion queue elements
+ * @rq: HW Receive Queue
+ **/
+static void free_rq_cqe(struct hinic_rq *rq)
+{
+	struct hinic_hwif *hwif = rq->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	struct hinic_wq *wq = rq->wq;
+	int i;
+
+	for (i = 0; i < wq->q_depth; i++)
+		dma_free_coherent(&pdev->dev, sizeof(*rq->cqe[i]), rq->cqe[i],
+				  rq->cqe_dma[i]);
+
+	vfree(rq->cqe_dma);
+	vfree(rq->cqe);
+}
+
+/**
+ * hinic_init_rq - Initialize HW Receive Queue
+ * @rq: HW Receive Queue
+ * @hwif: HW Interface for accessing HW
+ * @wq: Work Queue for the data of the RQ
+ * @entry: msix entry for rq
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+int hinic_init_rq(struct hinic_rq *rq, struct hinic_hwif *hwif,
+		  struct hinic_wq *wq, struct msix_entry *entry)
+{
+	struct pci_dev *pdev = hwif->pdev;
+	size_t pi_size;
+	int err;
+
+	rq->hwif = hwif;
+
+	rq->wq = wq;
+
+	rq->irq = entry->vector;
+	rq->msix_entry = entry->entry;
+
+	rq->buf_sz = HINIC_RX_BUF_SZ;
+
+	err = alloc_rq_priv(rq);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to allocate rq priv data\n");
+		return err;
+	}
+
+	err = alloc_rq_cqe(rq);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to allocate rq cqe\n");
+		goto alloc_rq_cqe_err;
+	}
+
+	/* HW requirements: Must be at least 32 bit */
+	pi_size = ALIGN(sizeof(*rq->pi_virt_addr), sizeof(u32));
+	rq->pi_virt_addr = dma_zalloc_coherent(&pdev->dev, pi_size,
+					       &rq->pi_dma_addr, GFP_KERNEL);
+	if (!rq->pi_virt_addr) {
+		dev_err(&pdev->dev, "Failed to allocate PI address\n");
+		err = -ENOMEM;
+		goto pi_virt_err;
+	}
+
+	return 0;
+
+pi_virt_err:
+	free_rq_cqe(rq);
+
+alloc_rq_cqe_err:
+	free_rq_priv(rq);
+	return err;
+}
+
+/**
+ * hinic_clean_rq - Clean HW Receive Queue's Resources
+ * @rq: HW Receive Queue
+ **/
+void hinic_clean_rq(struct hinic_rq *rq)
+{
+	struct hinic_hwif *hwif = rq->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	size_t pi_size;
+
+	pi_size = ALIGN(sizeof(*rq->pi_virt_addr), sizeof(u32));
+	dma_free_coherent(&pdev->dev, pi_size, rq->pi_virt_addr,
+			  rq->pi_dma_addr);
+
+	free_rq_cqe(rq);
+	free_rq_priv(rq);
+}
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h
index e8417d4..0da85e3 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h
@@ -18,6 +18,10 @@
 
 #include <linux/types.h>
 #include <linux/sizes.h>
+#include <linux/pci.h>
+
+#include "hinic_hw_if.h"
+#include "hinic_hw_wq.h"
 
 #define HINIC_SQ_WQEBB_SIZE                     64
 #define HINIC_RQ_WQEBB_SIZE                     32
@@ -31,12 +35,53 @@
 #define HINIC_SQ_WQE_MAX_SIZE                   320
 #define HINIC_RQ_WQE_SIZE                       32
 
+#define HINIC_RX_BUF_SZ                         2048
+
+struct hinic_rq_cqe {
+	u32     status;
+	u32     len;
+
+	u32     rsvd2;
+	u32     rsvd3;
+	u32     rsvd4;
+	u32     rsvd5;
+	u32     rsvd6;
+	u32     rsvd7;
+};
+
 struct hinic_sq {
-	/* should be implemented */
+	struct hinic_hwif       *hwif;
+
+	struct hinic_wq         *wq;
+
+	u32                     irq;
+	u16                     msix_entry;
+
+	void                    *hw_ci_addr;
+	dma_addr_t              hw_ci_dma_addr;
+
+	void __iomem            *db_base;
+
+	void                    **priv;
 };
 
 struct hinic_rq {
-	/* should be implemented */
+	struct hinic_hwif       *hwif;
+
+	struct hinic_wq         *wq;
+
+	u32                     irq;
+	u16                     msix_entry;
+
+	size_t                  buf_sz;
+
+	void                    **priv;
+
+	struct hinic_rq_cqe     **cqe;
+	dma_addr_t              *cqe_dma;
+
+	u16                     *pi_virt_addr;
+	dma_addr_t              pi_dma_addr;
 };
 
 struct hinic_qp {
@@ -46,4 +91,15 @@ struct hinic_qp {
 	u16     q_id;
 };
 
+int hinic_init_sq(struct hinic_sq *sq, struct hinic_hwif *hwif,
+		  struct hinic_wq *wq, struct msix_entry *entry, void *ci_addr,
+		  dma_addr_t ci_dma_addr, void __iomem *db_base);
+
+void hinic_clean_sq(struct hinic_sq *sq);
+
+int hinic_init_rq(struct hinic_rq *rq, struct hinic_hwif *hwif,
+		  struct hinic_wq *wq, struct msix_entry *entry);
+
+void hinic_clean_rq(struct hinic_rq *rq);
+
 #endif
-- 
1.9.1
