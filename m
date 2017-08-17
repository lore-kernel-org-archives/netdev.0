From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Subject: [PATCH V6 11/21] net-next/hinic: Add wq
Date: Thu, 17 Aug 2017 20:25:19 +0800
Message-ID: <fbd6e1d0a72cfcb0e944defe7f6e7a08a4d98c70.1502972068.git.aviad.krawczyk@huawei.com>
References: <cover.1502972068.git.aviad.krawczyk@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <bc.y@huawei.com>, <victor.gissin@huawei.com>,
        <aviad.krawczyk@huawei.com>, <zhaochen6@huawei.com>,
        <tony.qu@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1502972068.git.aviad.krawczyk@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Create work queues for being used by the queue pairs.

Signed-off-by: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Signed-off-by: Zhao Chen <zhaochen6@huawei.com>
---
 drivers/net/ethernet/huawei/hinic/Makefile       |   4 +-
 drivers/net/ethernet/huawei/hinic/hinic_common.h |  25 ++
 drivers/net/ethernet/huawei/hinic/hinic_hw_io.c  |  69 ++-
 drivers/net/ethernet/huawei/hinic/hinic_hw_io.h  |   6 +
 drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h  |  14 +
 drivers/net/ethernet/huawei/hinic/hinic_hw_wq.c  | 517 +++++++++++++++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_wq.h  |  86 ++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_wqe.h | 253 +++++++++++
 8 files changed, 969 insertions(+), 5 deletions(-)
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_common.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_wq.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_wq.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_wqe.h

diff --git a/drivers/net/ethernet/huawei/hinic/Makefile b/drivers/net/ethernet/huawei/hinic/Makefile
index f60c449..0575a34 100644
--- a/drivers/net/ethernet/huawei/hinic/Makefile
+++ b/drivers/net/ethernet/huawei/hinic/Makefile
@@ -1,5 +1,5 @@
 obj-$(CONFIG_HINIC) += hinic.o
 
 hinic-y := hinic_main.o hinic_tx.o hinic_rx.o hinic_port.o hinic_hw_dev.o \
-	   hinic_hw_io.o hinic_hw_mgmt.o hinic_hw_api_cmd.o hinic_hw_eqs.o \
-	   hinic_hw_if.o
+	   hinic_hw_io.o hinic_hw_wq.o hinic_hw_mgmt.o hinic_hw_api_cmd.o \
+	   hinic_hw_eqs.o hinic_hw_if.o
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_common.h b/drivers/net/ethernet/huawei/hinic/hinic_common.h
new file mode 100644
index 0000000..6a83c15
--- /dev/null
+++ b/drivers/net/ethernet/huawei/hinic/hinic_common.h
@@ -0,0 +1,25 @@
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
+#ifndef HINIC_COMMON_H
+#define HINIC_COMMON_H
+
+struct hinic_sge {
+	u32             hi_addr;
+	u32             lo_addr;
+	u32             len;
+};
+
+#endif
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_io.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_io.c
index ebe28ee..1bf944e 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_io.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_io.c
@@ -20,6 +20,8 @@
 #include <linux/slab.h>
 
 #include "hinic_hw_if.h"
+#include "hinic_hw_wqe.h"
+#include "hinic_hw_wq.h"
 #include "hinic_hw_qp.h"
 #include "hinic_hw_io.h"
 
@@ -38,8 +40,33 @@ static int init_qp(struct hinic_func_to_io *func_to_io,
 		   struct msix_entry *sq_msix_entry,
 		   struct msix_entry *rq_msix_entry)
 {
-	/* should be implemented */
+	struct hinic_hwif *hwif = func_to_io->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	int err;
+
+	qp->q_id = q_id;
+
+	err = hinic_wq_allocate(&func_to_io->wqs, &func_to_io->sq_wq[q_id],
+				HINIC_SQ_WQEBB_SIZE, HINIC_SQ_PAGE_SIZE,
+				HINIC_SQ_DEPTH, HINIC_SQ_WQE_MAX_SIZE);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to allocate WQ for SQ\n");
+		return err;
+	}
+
+	err = hinic_wq_allocate(&func_to_io->wqs, &func_to_io->rq_wq[q_id],
+				HINIC_RQ_WQEBB_SIZE, HINIC_RQ_PAGE_SIZE,
+				HINIC_RQ_DEPTH, HINIC_RQ_WQE_SIZE);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to allocate WQ for RQ\n");
+		goto err_rq_alloc;
+	}
+
 	return 0;
+
+err_rq_alloc:
+	hinic_wq_free(&func_to_io->wqs, &func_to_io->sq_wq[q_id]);
+	return err;
 }
 
 /**
@@ -50,7 +77,10 @@ static int init_qp(struct hinic_func_to_io *func_to_io,
 static void destroy_qp(struct hinic_func_to_io *func_to_io,
 		       struct hinic_qp *qp)
 {
-	/* should be implemented */
+	int q_id = qp->q_id;
+
+	hinic_wq_free(&func_to_io->wqs, &func_to_io->rq_wq[q_id]);
+	hinic_wq_free(&func_to_io->wqs, &func_to_io->sq_wq[q_id]);
 }
 
 /**
@@ -70,7 +100,7 @@ int hinic_io_create_qps(struct hinic_func_to_io *func_to_io,
 {
 	struct hinic_hwif *hwif = func_to_io->hwif;
 	struct pci_dev *pdev = hwif->pdev;
-	size_t qps_size;
+	size_t qps_size, wq_size;
 	int i, j, err;
 
 	qps_size = num_qps * sizeof(*func_to_io->qps);
@@ -78,6 +108,20 @@ int hinic_io_create_qps(struct hinic_func_to_io *func_to_io,
 	if (!func_to_io->qps)
 		return -ENOMEM;
 
+	wq_size = num_qps * sizeof(*func_to_io->sq_wq);
+	func_to_io->sq_wq = devm_kzalloc(&pdev->dev, wq_size, GFP_KERNEL);
+	if (!func_to_io->sq_wq) {
+		err = -ENOMEM;
+		goto err_sq_wq;
+	}
+
+	wq_size = num_qps * sizeof(*func_to_io->rq_wq);
+	func_to_io->rq_wq = devm_kzalloc(&pdev->dev, wq_size, GFP_KERNEL);
+	if (!func_to_io->rq_wq) {
+		err = -ENOMEM;
+		goto err_rq_wq;
+	}
+
 	for (i = 0; i < num_qps; i++) {
 		err = init_qp(func_to_io, &func_to_io->qps[i], i,
 			      &sq_msix_entries[i], &rq_msix_entries[i]);
@@ -93,6 +137,12 @@ int hinic_io_create_qps(struct hinic_func_to_io *func_to_io,
 	for (j = 0; j < i; j++)
 		destroy_qp(func_to_io, &func_to_io->qps[j]);
 
+	devm_kfree(&pdev->dev, func_to_io->rq_wq);
+
+err_rq_wq:
+	devm_kfree(&pdev->dev, func_to_io->sq_wq);
+
+err_sq_wq:
 	devm_kfree(&pdev->dev, func_to_io->qps);
 	return err;
 }
@@ -111,6 +161,9 @@ void hinic_io_destroy_qps(struct hinic_func_to_io *func_to_io, int num_qps)
 	for (i = 0; i < num_qps; i++)
 		destroy_qp(func_to_io, &func_to_io->qps[i]);
 
+	devm_kfree(&pdev->dev, func_to_io->rq_wq);
+	devm_kfree(&pdev->dev, func_to_io->sq_wq);
+
 	devm_kfree(&pdev->dev, func_to_io->qps);
 }
 
@@ -128,10 +181,19 @@ int hinic_io_init(struct hinic_func_to_io *func_to_io,
 		  struct hinic_hwif *hwif, u16 max_qps, int num_ceqs,
 		  struct msix_entry *ceq_msix_entries)
 {
+	struct pci_dev *pdev = hwif->pdev;
+	int err;
+
 	func_to_io->hwif = hwif;
 	func_to_io->qps = NULL;
 	func_to_io->max_qps = max_qps;
 
+	err = hinic_wqs_alloc(&func_to_io->wqs, 2 * max_qps, hwif);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to allocate WQS for IO\n");
+		return err;
+	}
+
 	return 0;
 }
 
@@ -141,4 +203,5 @@ int hinic_io_init(struct hinic_func_to_io *func_to_io,
  **/
 void hinic_io_free(struct hinic_func_to_io *func_to_io)
 {
+	hinic_wqs_free(&func_to_io->wqs);
 }
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_io.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_io.h
index 7cdcffd..6cacb8e 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_io.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_io.h
@@ -20,11 +20,17 @@
 #include <linux/pci.h>
 
 #include "hinic_hw_if.h"
+#include "hinic_hw_wq.h"
 #include "hinic_hw_qp.h"
 
 struct hinic_func_to_io {
 	struct hinic_hwif       *hwif;
 
+	struct hinic_wqs        wqs;
+
+	struct hinic_wq         *sq_wq;
+	struct hinic_wq         *rq_wq;
+
 	struct hinic_qp         *qps;
 	u16                     max_qps;
 };
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h
index 64330fb..4031728 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h
@@ -16,6 +16,18 @@
 #ifndef HINIC_HW_QP_H
 #define HINIC_HW_QP_H
 
+#include <linux/types.h>
+#include <linux/sizes.h>
+
+#define HINIC_SQ_WQEBB_SIZE                     64
+#define HINIC_RQ_WQEBB_SIZE                     32
+
+#define HINIC_SQ_PAGE_SIZE                      SZ_4K
+#define HINIC_RQ_PAGE_SIZE                      SZ_4K
+
+#define HINIC_SQ_DEPTH                          SZ_4K
+#define HINIC_RQ_DEPTH                          SZ_4K
+
 struct hinic_sq {
 	/* should be implemented */
 };
@@ -27,6 +39,8 @@ struct hinic_rq {
 struct hinic_qp {
 	struct hinic_sq         sq;
 	struct hinic_rq         rq;
+
+	u16     q_id;
 };
 
 #endif
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_wq.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_wq.c
new file mode 100644
index 0000000..88d370e
--- /dev/null
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_wq.c
@@ -0,0 +1,517 @@
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
+#include <linux/slab.h>
+#include <linux/atomic.h>
+#include <linux/semaphore.h>
+#include <linux/errno.h>
+#include <linux/vmalloc.h>
+#include <asm/byteorder.h>
+
+#include "hinic_hw_if.h"
+#include "hinic_hw_wq.h"
+
+#define WQS_BLOCKS_PER_PAGE             4
+
+#define WQ_BLOCK_SIZE                   4096
+#define WQS_PAGE_SIZE                   (WQS_BLOCKS_PER_PAGE * WQ_BLOCK_SIZE)
+
+#define WQS_MAX_NUM_BLOCKS              128
+#define WQS_FREE_BLOCKS_SIZE(wqs)       (WQS_MAX_NUM_BLOCKS * \
+					 sizeof((wqs)->free_blocks[0]))
+
+#define WQ_SIZE(wq)                     ((wq)->q_depth * (wq)->wqebb_size)
+
+#define WQ_PAGE_ADDR_SIZE               sizeof(u64)
+#define WQ_MAX_PAGES                    (WQ_BLOCK_SIZE / WQ_PAGE_ADDR_SIZE)
+
+#define WQ_BASE_VADDR(wqs, wq)          \
+			((void *)((wqs)->page_vaddr[(wq)->page_idx]) \
+				+ (wq)->block_idx * WQ_BLOCK_SIZE)
+
+#define WQ_BASE_PADDR(wqs, wq)          \
+			((wqs)->page_paddr[(wq)->page_idx] \
+				+ (wq)->block_idx * WQ_BLOCK_SIZE)
+
+#define WQ_BASE_ADDR(wqs, wq)           \
+			((void *)((wqs)->shadow_page_vaddr[(wq)->page_idx]) \
+				+ (wq)->block_idx * WQ_BLOCK_SIZE)
+
+/**
+ * queue_alloc_page - allocate page for Queue
+ * @hwif: HW interface for allocating DMA
+ * @vaddr: virtual address will be returned in this address
+ * @paddr: physical address will be returned in this address
+ * @shadow_vaddr: VM area will be return here for holding WQ page addresses
+ * @page_sz: page size of each WQ page
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+static int queue_alloc_page(struct hinic_hwif *hwif, u64 **vaddr, u64 *paddr,
+			    void ***shadow_vaddr, size_t page_sz)
+{
+	struct pci_dev *pdev = hwif->pdev;
+	dma_addr_t dma_addr;
+
+	*vaddr = dma_zalloc_coherent(&pdev->dev, page_sz, &dma_addr,
+				     GFP_KERNEL);
+	if (!*vaddr) {
+		dev_err(&pdev->dev, "Failed to allocate dma for wqs page\n");
+		return -ENOMEM;
+	}
+
+	*paddr = (u64)dma_addr;
+
+	/* use vzalloc for big mem */
+	*shadow_vaddr = vzalloc(page_sz);
+	if (!*shadow_vaddr)
+		goto err_shadow_vaddr;
+
+	return 0;
+
+err_shadow_vaddr:
+	dma_free_coherent(&pdev->dev, page_sz, *vaddr, dma_addr);
+	return -ENOMEM;
+}
+
+/**
+ * wqs_allocate_page - allocate page for WQ set
+ * @wqs: Work Queue Set
+ * @page_idx: the page index of the page will be allocated
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+static int wqs_allocate_page(struct hinic_wqs *wqs, int page_idx)
+{
+	return queue_alloc_page(wqs->hwif, &wqs->page_vaddr[page_idx],
+				&wqs->page_paddr[page_idx],
+				&wqs->shadow_page_vaddr[page_idx],
+				WQS_PAGE_SIZE);
+}
+
+/**
+ * wqs_free_page - free page of WQ set
+ * @wqs: Work Queue Set
+ * @page_idx: the page index of the page will be freed
+ **/
+static void wqs_free_page(struct hinic_wqs *wqs, int page_idx)
+{
+	struct hinic_hwif *hwif = wqs->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+
+	dma_free_coherent(&pdev->dev, WQS_PAGE_SIZE,
+			  wqs->page_vaddr[page_idx],
+			  (dma_addr_t)wqs->page_paddr[page_idx]);
+	vfree(wqs->shadow_page_vaddr[page_idx]);
+}
+
+static int alloc_page_arrays(struct hinic_wqs *wqs)
+{
+	struct hinic_hwif *hwif = wqs->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	size_t size;
+
+	size = wqs->num_pages * sizeof(*wqs->page_paddr);
+	wqs->page_paddr = devm_kzalloc(&pdev->dev, size, GFP_KERNEL);
+	if (!wqs->page_paddr)
+		return -ENOMEM;
+
+	size = wqs->num_pages * sizeof(*wqs->page_vaddr);
+	wqs->page_vaddr = devm_kzalloc(&pdev->dev, size, GFP_KERNEL);
+	if (!wqs->page_vaddr)
+		goto err_page_vaddr;
+
+	size = wqs->num_pages * sizeof(*wqs->shadow_page_vaddr);
+	wqs->shadow_page_vaddr = devm_kzalloc(&pdev->dev, size, GFP_KERNEL);
+	if (!wqs->shadow_page_vaddr)
+		goto err_page_shadow_vaddr;
+
+	return 0;
+
+err_page_shadow_vaddr:
+	devm_kfree(&pdev->dev, wqs->page_vaddr);
+
+err_page_vaddr:
+	devm_kfree(&pdev->dev, wqs->page_paddr);
+	return -ENOMEM;
+}
+
+static void free_page_arrays(struct hinic_wqs *wqs)
+{
+	struct hinic_hwif *hwif = wqs->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+
+	devm_kfree(&pdev->dev, wqs->shadow_page_vaddr);
+	devm_kfree(&pdev->dev, wqs->page_vaddr);
+	devm_kfree(&pdev->dev, wqs->page_paddr);
+}
+
+static int wqs_next_block(struct hinic_wqs *wqs, int *page_idx,
+			  int *block_idx)
+{
+	int pos;
+
+	down(&wqs->alloc_blocks_lock);
+
+	wqs->num_free_blks--;
+
+	if (wqs->num_free_blks < 0) {
+		wqs->num_free_blks++;
+		up(&wqs->alloc_blocks_lock);
+		return -ENOMEM;
+	}
+
+	pos = wqs->alloc_blk_pos++;
+	pos &= WQS_MAX_NUM_BLOCKS - 1;
+
+	*page_idx = wqs->free_blocks[pos].page_idx;
+	*block_idx = wqs->free_blocks[pos].block_idx;
+
+	wqs->free_blocks[pos].page_idx = -1;
+	wqs->free_blocks[pos].block_idx = -1;
+
+	up(&wqs->alloc_blocks_lock);
+	return 0;
+}
+
+static void wqs_return_block(struct hinic_wqs *wqs, int page_idx,
+			     int block_idx)
+{
+	int pos;
+
+	down(&wqs->alloc_blocks_lock);
+
+	pos = wqs->return_blk_pos++;
+	pos &= WQS_MAX_NUM_BLOCKS - 1;
+
+	wqs->free_blocks[pos].page_idx = page_idx;
+	wqs->free_blocks[pos].block_idx = block_idx;
+
+	wqs->num_free_blks++;
+
+	up(&wqs->alloc_blocks_lock);
+}
+
+static void init_wqs_blocks_arr(struct hinic_wqs *wqs)
+{
+	int page_idx, blk_idx, pos = 0;
+
+	for (page_idx = 0; page_idx < wqs->num_pages; page_idx++) {
+		for (blk_idx = 0; blk_idx < WQS_BLOCKS_PER_PAGE; blk_idx++) {
+			wqs->free_blocks[pos].page_idx = page_idx;
+			wqs->free_blocks[pos].block_idx = blk_idx;
+			pos++;
+		}
+	}
+
+	wqs->alloc_blk_pos = 0;
+	wqs->return_blk_pos = pos;
+	wqs->num_free_blks = pos;
+
+	sema_init(&wqs->alloc_blocks_lock, 1);
+}
+
+/**
+ * hinic_wqs_alloc - allocate Work Queues set
+ * @wqs: Work Queue Set
+ * @max_wqs: maximum wqs to allocate
+ * @hwif: HW interface for use for the allocation
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+int hinic_wqs_alloc(struct hinic_wqs *wqs, int max_wqs,
+		    struct hinic_hwif *hwif)
+{
+	struct pci_dev *pdev = hwif->pdev;
+	int err, i, page_idx;
+
+	max_wqs = ALIGN(max_wqs, WQS_BLOCKS_PER_PAGE);
+
+	if (max_wqs > WQS_MAX_NUM_BLOCKS)  {
+		dev_err(&pdev->dev, "Invalid max_wqs = %d\n", max_wqs);
+		return -EINVAL;
+	}
+
+	wqs->hwif = hwif;
+	wqs->num_pages = max_wqs / WQS_BLOCKS_PER_PAGE;
+
+	if (alloc_page_arrays(wqs)) {
+		dev_err(&pdev->dev,
+			"Failed to allocate mem for page addresses\n");
+		return -ENOMEM;
+	}
+
+	for (page_idx = 0; page_idx < wqs->num_pages; page_idx++) {
+		err = wqs_allocate_page(wqs, page_idx);
+		if (err) {
+			dev_err(&pdev->dev, "Failed wq page allocation\n");
+			goto err_wq_allocate_page;
+		}
+	}
+
+	wqs->free_blocks = devm_kzalloc(&pdev->dev, WQS_FREE_BLOCKS_SIZE(wqs),
+					GFP_KERNEL);
+	if (!wqs->free_blocks) {
+		err = -ENOMEM;
+		goto err_alloc_blocks;
+	}
+
+	init_wqs_blocks_arr(wqs);
+	return 0;
+
+err_alloc_blocks:
+err_wq_allocate_page:
+	for (i = 0; i < page_idx; i++)
+		wqs_free_page(wqs, i);
+
+	free_page_arrays(wqs);
+	return err;
+}
+
+/**
+ * hinic_wqs_free - free Work Queues set
+ * @wqs: Work Queue Set
+ **/
+void hinic_wqs_free(struct hinic_wqs *wqs)
+{
+	struct hinic_hwif *hwif = wqs->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	int page_idx;
+
+	devm_kfree(&pdev->dev, wqs->free_blocks);
+
+	for (page_idx = 0; page_idx < wqs->num_pages; page_idx++)
+		wqs_free_page(wqs, page_idx);
+
+	free_page_arrays(wqs);
+}
+
+/**
+ * alloc_wqes_shadow - allocate WQE shadows for WQ
+ * @wq: WQ to allocate shadows for
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+static int alloc_wqes_shadow(struct hinic_wq *wq)
+{
+	struct hinic_hwif *hwif = wq->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	size_t size;
+
+	size = wq->num_q_pages * wq->max_wqe_size;
+	wq->shadow_wqe = devm_kzalloc(&pdev->dev, size, GFP_KERNEL);
+	if (!wq->shadow_wqe)
+		return -ENOMEM;
+
+	size = wq->num_q_pages * sizeof(wq->prod_idx);
+	wq->shadow_idx = devm_kzalloc(&pdev->dev, size, GFP_KERNEL);
+	if (!wq->shadow_idx)
+		goto err_shadow_idx;
+
+	return 0;
+
+err_shadow_idx:
+	devm_kfree(&pdev->dev, wq->shadow_wqe);
+	return -ENOMEM;
+}
+
+/**
+ * free_wqes_shadow - free WQE shadows of WQ
+ * @wq: WQ to free shadows from
+ **/
+static void free_wqes_shadow(struct hinic_wq *wq)
+{
+	struct hinic_hwif *hwif = wq->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+
+	devm_kfree(&pdev->dev, wq->shadow_idx);
+	devm_kfree(&pdev->dev, wq->shadow_wqe);
+}
+
+/**
+ * free_wq_pages - free pages of WQ
+ * @hwif: HW interface for releasing dma addresses
+ * @wq: WQ to free pages from
+ * @num_q_pages: number pages to free
+ **/
+static void free_wq_pages(struct hinic_wq *wq, struct hinic_hwif *hwif,
+			  int num_q_pages)
+{
+	struct pci_dev *pdev = hwif->pdev;
+	int i;
+
+	for (i = 0; i < num_q_pages; i++) {
+		void **vaddr = &wq->shadow_block_vaddr[i];
+		u64 *paddr = &wq->block_vaddr[i];
+		dma_addr_t dma_addr;
+
+		dma_addr = (dma_addr_t)be64_to_cpu(*paddr);
+		dma_free_coherent(&pdev->dev, wq->wq_page_size, *vaddr,
+				  dma_addr);
+	}
+
+	free_wqes_shadow(wq);
+}
+
+/**
+ * alloc_wq_pages - alloc pages for WQ
+ * @hwif: HW interface for allocating dma addresses
+ * @wq: WQ to allocate pages for
+ * @max_pages: maximum pages allowed
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+static int alloc_wq_pages(struct hinic_wq *wq, struct hinic_hwif *hwif,
+			  int max_pages)
+{
+	struct pci_dev *pdev = hwif->pdev;
+	int i, err, num_q_pages;
+
+	num_q_pages = ALIGN(WQ_SIZE(wq), wq->wq_page_size) / wq->wq_page_size;
+	if (num_q_pages > max_pages) {
+		dev_err(&pdev->dev, "Number wq pages exceeds the limit\n");
+		return -EINVAL;
+	}
+
+	if (num_q_pages & (num_q_pages - 1)) {
+		dev_err(&pdev->dev, "Number wq pages must be power of 2\n");
+		return -EINVAL;
+	}
+
+	wq->num_q_pages = num_q_pages;
+
+	err = alloc_wqes_shadow(wq);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to allocate wqe shadow\n");
+		return err;
+	}
+
+	for (i = 0; i < num_q_pages; i++) {
+		void **vaddr = &wq->shadow_block_vaddr[i];
+		u64 *paddr = &wq->block_vaddr[i];
+		dma_addr_t dma_addr;
+
+		*vaddr = dma_zalloc_coherent(&pdev->dev, wq->wq_page_size,
+					     &dma_addr, GFP_KERNEL);
+		if (!*vaddr) {
+			dev_err(&pdev->dev, "Failed to allocate wq page\n");
+			goto err_alloc_wq_pages;
+		}
+
+		/* HW uses Big Endian Format */
+		*paddr = cpu_to_be64(dma_addr);
+	}
+
+	return 0;
+
+err_alloc_wq_pages:
+	free_wq_pages(wq, hwif, i);
+	return -ENOMEM;
+}
+
+/**
+ * hinic_wq_allocate - Allocate the WQ resources from the WQS
+ * @wqs: WQ set from which to allocate the WQ resources
+ * @wq: WQ to allocate resources for it from the WQ set
+ * @wqebb_size: Work Queue Block Byte Size
+ * @wq_page_size: the page size in the Work Queue
+ * @q_depth: number of wqebbs in WQ
+ * @max_wqe_size: maximum WQE size that will be used in the WQ
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+int hinic_wq_allocate(struct hinic_wqs *wqs, struct hinic_wq *wq,
+		      u16 wqebb_size, u16 wq_page_size, u16 q_depth,
+		      u16 max_wqe_size)
+{
+	struct hinic_hwif *hwif = wqs->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	u16 num_wqebbs_per_page;
+	int err;
+
+	if (wqebb_size == 0) {
+		dev_err(&pdev->dev, "wqebb_size must be > 0\n");
+		return -EINVAL;
+	}
+
+	if (wq_page_size == 0) {
+		dev_err(&pdev->dev, "wq_page_size must be > 0\n");
+		return -EINVAL;
+	}
+
+	if (q_depth & (q_depth - 1)) {
+		dev_err(&pdev->dev, "WQ q_depth must be power of 2\n");
+		return -EINVAL;
+	}
+
+	num_wqebbs_per_page = ALIGN(wq_page_size, wqebb_size) / wqebb_size;
+
+	if (num_wqebbs_per_page & (num_wqebbs_per_page - 1)) {
+		dev_err(&pdev->dev, "num wqebbs per page must be power of 2\n");
+		return -EINVAL;
+	}
+
+	wq->hwif = hwif;
+
+	err = wqs_next_block(wqs, &wq->page_idx, &wq->block_idx);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to get free wqs next block\n");
+		return err;
+	}
+
+	wq->wqebb_size = wqebb_size;
+	wq->wq_page_size = wq_page_size;
+	wq->q_depth = q_depth;
+	wq->max_wqe_size = max_wqe_size;
+	wq->num_wqebbs_per_page = num_wqebbs_per_page;
+
+	wq->block_vaddr = WQ_BASE_VADDR(wqs, wq);
+	wq->shadow_block_vaddr = WQ_BASE_ADDR(wqs, wq);
+	wq->block_paddr = WQ_BASE_PADDR(wqs, wq);
+
+	err = alloc_wq_pages(wq, wqs->hwif, WQ_MAX_PAGES);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to allocate wq pages\n");
+		goto err_alloc_wq_pages;
+	}
+
+	atomic_set(&wq->cons_idx, 0);
+	atomic_set(&wq->prod_idx, 0);
+	atomic_set(&wq->delta, q_depth);
+	wq->mask = q_depth - 1;
+
+	return 0;
+
+err_alloc_wq_pages:
+	wqs_return_block(wqs, wq->page_idx, wq->block_idx);
+	return err;
+}
+
+/**
+ * hinic_wq_free - Free the WQ resources to the WQS
+ * @wqs: WQ set to free the WQ resources to it
+ * @wq: WQ to free its resources to the WQ set resources
+ **/
+void hinic_wq_free(struct hinic_wqs *wqs, struct hinic_wq *wq)
+{
+	free_wq_pages(wq, wqs->hwif, wq->num_q_pages);
+
+	wqs_return_block(wqs, wq->page_idx, wq->block_idx);
+}
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_wq.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_wq.h
new file mode 100644
index 0000000..7c114da
--- /dev/null
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_wq.h
@@ -0,0 +1,86 @@
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
+#ifndef HINIC_HW_WQ_H
+#define HINIC_HW_WQ_H
+
+#include <linux/types.h>
+#include <linux/semaphore.h>
+#include <linux/atomic.h>
+
+#include "hinic_hw_if.h"
+
+struct hinic_free_block {
+	int     page_idx;
+	int     block_idx;
+};
+
+struct hinic_wq {
+	struct hinic_hwif       *hwif;
+
+	int             page_idx;
+	int             block_idx;
+
+	u16             wqebb_size;
+	u16             wq_page_size;
+	u16             q_depth;
+	u16             max_wqe_size;
+	u16             num_wqebbs_per_page;
+
+	/* The addresses are 64 bit in the HW */
+	u64             block_paddr;
+	void            **shadow_block_vaddr;
+	u64             *block_vaddr;
+
+	int             num_q_pages;
+	u8              *shadow_wqe;
+	u16             *shadow_idx;
+
+	atomic_t        cons_idx;
+	atomic_t        prod_idx;
+	atomic_t        delta;
+	u16             mask;
+};
+
+struct hinic_wqs {
+	struct hinic_hwif       *hwif;
+	int                     num_pages;
+
+	/* The addresses are 64 bit in the HW */
+	u64                     *page_paddr;
+	u64                     **page_vaddr;
+	void                    ***shadow_page_vaddr;
+
+	struct hinic_free_block *free_blocks;
+	int                     alloc_blk_pos;
+	int                     return_blk_pos;
+	int                     num_free_blks;
+
+	/* Lock for getting a free block from the WQ set */
+	struct semaphore        alloc_blocks_lock;
+};
+
+int hinic_wqs_alloc(struct hinic_wqs *wqs, int num_wqs,
+		    struct hinic_hwif *hwif);
+
+void hinic_wqs_free(struct hinic_wqs *wqs);
+
+int hinic_wq_allocate(struct hinic_wqs *wqs, struct hinic_wq *wq,
+		      u16 wqebb_size, u16 wq_page_size, u16 q_depth,
+		      u16 max_wqe_size);
+
+void hinic_wq_free(struct hinic_wqs *wqs, struct hinic_wq *wq);
+
+#endif
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_wqe.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_wqe.h
new file mode 100644
index 0000000..d727c4d
--- /dev/null
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_wqe.h
@@ -0,0 +1,253 @@
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
+#ifndef HINIC_HW_WQE_H
+#define HINIC_HW_WQE_H
+
+#include "hinic_common.h"
+
+#define HINIC_SQ_CTRL_BUFDESC_SECT_LEN_SHIFT    0
+#define HINIC_SQ_CTRL_TASKSECT_LEN_SHIFT        16
+#define HINIC_SQ_CTRL_DATA_FORMAT_SHIFT         22
+#define HINIC_SQ_CTRL_LEN_SHIFT                 29
+
+#define HINIC_SQ_CTRL_BUFDESC_SECT_LEN_MASK     0xFF
+#define HINIC_SQ_CTRL_TASKSECT_LEN_MASK         0x1F
+#define HINIC_SQ_CTRL_DATA_FORMAT_MASK          0x1
+#define HINIC_SQ_CTRL_LEN_MASK                  0x3
+
+#define HINIC_SQ_CTRL_QUEUE_INFO_MSS_SHIFT      13
+
+#define HINIC_SQ_CTRL_QUEUE_INFO_MSS_MASK       0x3FFF
+
+#define HINIC_SQ_CTRL_SET(val, member)          \
+		(((u32)(val) & HINIC_SQ_CTRL_##member##_MASK) \
+		 << HINIC_SQ_CTRL_##member##_SHIFT)
+
+#define HINIC_SQ_CTRL_GET(val, member)          \
+		(((val) >> HINIC_SQ_CTRL_##member##_SHIFT) \
+		 & HINIC_SQ_CTRL_##member##_MASK)
+
+#define HINIC_SQ_TASK_INFO0_L2HDR_LEN_SHIFT     0
+#define HINIC_SQ_TASK_INFO0_L4_OFFLOAD_SHIFT    8
+#define HINIC_SQ_TASK_INFO0_INNER_L3TYPE_SHIFT  10
+#define HINIC_SQ_TASK_INFO0_VLAN_OFFLOAD_SHIFT  12
+#define HINIC_SQ_TASK_INFO0_PARSE_FLAG_SHIFT    13
+/* 1 bit reserved */
+#define HINIC_SQ_TASK_INFO0_TSO_FLAG_SHIFT      15
+#define HINIC_SQ_TASK_INFO0_VLAN_TAG_SHIFT      16
+
+#define HINIC_SQ_TASK_INFO0_L2HDR_LEN_MASK      0xFF
+#define HINIC_SQ_TASK_INFO0_L4_OFFLOAD_MASK     0x3
+#define HINIC_SQ_TASK_INFO0_INNER_L3TYPE_MASK   0x3
+#define HINIC_SQ_TASK_INFO0_VLAN_OFFLOAD_MASK   0x1
+#define HINIC_SQ_TASK_INFO0_PARSE_FLAG_MASK     0x1
+/* 1 bit reserved */
+#define HINIC_SQ_TASK_INFO0_TSO_FLAG_MASK       0x1
+#define HINIC_SQ_TASK_INFO0_VLAN_TAG_MASK       0xFFFF
+
+#define HINIC_SQ_TASK_INFO0_SET(val, member)    \
+		(((u32)(val) & HINIC_SQ_TASK_INFO0_##member##_MASK) <<  \
+		 HINIC_SQ_TASK_INFO0_##member##_SHIFT)
+
+/* 8 bits reserved */
+#define HINIC_SQ_TASK_INFO1_MEDIA_TYPE_SHIFT    8
+#define HINIC_SQ_TASK_INFO1_INNER_L4_LEN_SHIFT  16
+#define HINIC_SQ_TASK_INFO1_INNER_L3_LEN_SHIFT  24
+
+/* 8 bits reserved */
+#define HINIC_SQ_TASK_INFO1_MEDIA_TYPE_MASK     0xFF
+#define HINIC_SQ_TASK_INFO1_INNER_L4_LEN_MASK   0xFF
+#define HINIC_SQ_TASK_INFO1_INNER_L3_LEN_MASK   0xFF
+
+#define HINIC_SQ_TASK_INFO1_SET(val, member)    \
+		(((u32)(val) & HINIC_SQ_TASK_INFO1_##member##_MASK) <<  \
+		 HINIC_SQ_TASK_INFO1_##member##_SHIFT)
+
+#define HINIC_SQ_TASK_INFO2_TUNNEL_L4_LEN_SHIFT 0
+#define HINIC_SQ_TASK_INFO2_OUTER_L3_LEN_SHIFT  12
+#define HINIC_SQ_TASK_INFO2_TUNNEL_L4TYPE_SHIFT 19
+/* 1 bit reserved */
+#define HINIC_SQ_TASK_INFO2_OUTER_L3TYPE_SHIFT  22
+/* 8 bits reserved */
+
+#define HINIC_SQ_TASK_INFO2_TUNNEL_L4_LEN_MASK  0xFFF
+#define HINIC_SQ_TASK_INFO2_OUTER_L3_LEN_MASK   0x7F
+#define HINIC_SQ_TASK_INFO2_TUNNEL_L4TYPE_MASK  0x3
+/* 1 bit reserved */
+#define HINIC_SQ_TASK_INFO2_OUTER_L3TYPE_MASK   0x3
+/* 8 bits reserved */
+
+#define HINIC_SQ_TASK_INFO2_SET(val, member)    \
+		(((u32)(val) & HINIC_SQ_TASK_INFO2_##member##_MASK) <<  \
+		 HINIC_SQ_TASK_INFO2_##member##_SHIFT)
+
+/* 31 bits reserved */
+#define HINIC_SQ_TASK_INFO4_L2TYPE_SHIFT        31
+
+/* 31 bits reserved */
+#define HINIC_SQ_TASK_INFO4_L2TYPE_MASK         0x1
+
+#define HINIC_SQ_TASK_INFO4_SET(val, member)    \
+		(((u32)(val) & HINIC_SQ_TASK_INFO4_##member##_MASK) << \
+		 HINIC_SQ_TASK_INFO4_##member##_SHIFT)
+
+#define HINIC_RQ_CQE_STATUS_RXDONE_SHIFT        31
+
+#define HINIC_RQ_CQE_STATUS_RXDONE_MASK         0x1
+
+#define HINIC_RQ_CQE_STATUS_GET(val, member)    \
+		(((val) >> HINIC_RQ_CQE_STATUS_##member##_SHIFT) & \
+		 HINIC_RQ_CQE_STATUS_##member##_MASK)
+
+#define HINIC_RQ_CQE_STATUS_CLEAR(val, member)  \
+		((val) & (~(HINIC_RQ_CQE_STATUS_##member##_MASK << \
+		 HINIC_RQ_CQE_STATUS_##member##_SHIFT)))
+
+#define HINIC_RQ_CQE_SGE_LEN_SHIFT              16
+
+#define HINIC_RQ_CQE_SGE_LEN_MASK               0xFFFF
+
+#define HINIC_RQ_CQE_SGE_GET(val, member)       \
+		(((val) >> HINIC_RQ_CQE_SGE_##member##_SHIFT) & \
+		 HINIC_RQ_CQE_SGE_##member##_MASK)
+
+#define HINIC_RQ_CTRL_BUFDESC_SECT_LEN_SHIFT    0
+#define HINIC_RQ_CTRL_COMPLETE_FORMAT_SHIFT     15
+#define HINIC_RQ_CTRL_COMPLETE_LEN_SHIFT        27
+#define HINIC_RQ_CTRL_LEN_SHIFT                 29
+
+#define HINIC_RQ_CTRL_BUFDESC_SECT_LEN_MASK     0xFF
+#define HINIC_RQ_CTRL_COMPLETE_FORMAT_MASK      0x1
+#define HINIC_RQ_CTRL_COMPLETE_LEN_MASK         0x3
+#define HINIC_RQ_CTRL_LEN_MASK                  0x3
+
+#define HINIC_RQ_CTRL_SET(val, member)          \
+		(((u32)(val) & HINIC_RQ_CTRL_##member##_MASK) << \
+		 HINIC_RQ_CTRL_##member##_SHIFT)
+
+#define HINIC_SQ_WQE_SIZE(nr_sges)              \
+		(sizeof(struct hinic_sq_ctrl) + \
+		 sizeof(struct hinic_sq_task) + \
+		 (nr_sges) * sizeof(struct hinic_sq_bufdesc))
+
+#define HINIC_MAX_SQ_BUFDESCS           17
+
+#define HINIC_SQ_WQE_MAX_SIZE           320
+#define HINIC_RQ_WQE_SIZE               32
+
+enum hinic_l4offload_type {
+	HINIC_L4_OFF_DISABLE            = 0,
+	HINIC_TCP_OFFLOAD_ENABLE        = 1,
+	HINIC_SCTP_OFFLOAD_ENABLE       = 2,
+	HINIC_UDP_OFFLOAD_ENABLE        = 3,
+};
+
+enum hinic_vlan_offload {
+	HINIC_VLAN_OFF_DISABLE = 0,
+	HINIC_VLAN_OFF_ENABLE  = 1,
+};
+
+enum hinic_pkt_parsed {
+	HINIC_PKT_NOT_PARSED = 0,
+	HINIC_PKT_PARSED     = 1,
+};
+
+enum hinic_outer_l3type {
+	HINIC_OUTER_L3TYPE_UNKNOWN              = 0,
+	HINIC_OUTER_L3TYPE_IPV6                 = 1,
+	HINIC_OUTER_L3TYPE_IPV4_NO_CHKSUM       = 2,
+	HINIC_OUTER_L3TYPE_IPV4_CHKSUM          = 3,
+};
+
+enum hinic_media_type {
+	HINIC_MEDIA_UNKNOWN = 0,
+};
+
+enum hinic_l2type {
+	HINIC_L2TYPE_ETH = 0,
+};
+
+enum hinc_tunnel_l4type {
+	HINIC_TUNNEL_L4TYPE_UNKNOWN = 0,
+};
+
+struct hinic_sq_ctrl {
+	u32     ctrl_info;
+	u32     queue_info;
+};
+
+struct hinic_sq_task {
+	u32     pkt_info0;
+	u32     pkt_info1;
+	u32     pkt_info2;
+	u32     ufo_v6_identify;
+	u32     pkt_info4;
+	u32     zero_pad;
+};
+
+struct hinic_sq_bufdesc {
+	struct hinic_sge sge;
+	u32     rsvd;
+};
+
+struct hinic_sq_wqe {
+	struct hinic_sq_ctrl            ctrl;
+	struct hinic_sq_task            task;
+	struct hinic_sq_bufdesc         buf_descs[HINIC_MAX_SQ_BUFDESCS];
+};
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
+struct hinic_rq_ctrl {
+	u32     ctrl_info;
+};
+
+struct hinic_rq_cqe_sect {
+	struct hinic_sge        sge;
+	u32                     rsvd;
+};
+
+struct hinic_rq_bufdesc {
+	u32     hi_addr;
+	u32     lo_addr;
+};
+
+struct hinic_rq_wqe {
+	struct hinic_rq_ctrl            ctrl;
+	u32                             rsvd;
+	struct hinic_rq_cqe_sect        cqe_sect;
+	struct hinic_rq_bufdesc         buf_desc;
+};
+
+struct hinic_hw_wqe {
+	/* HW Format */
+	union {
+		struct hinic_sq_wqe     sq_wqe;
+		struct hinic_rq_wqe     rq_wqe;
+	};
+};
+
+#endif
-- 
1.9.1
