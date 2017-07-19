From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Subject: [PATCH V2 net-next 11/21] net-next/hinic: Add wq
Date: Wed, 19 Jul 2017 17:19:09 +0800
Message-ID: <59668289aeac8f9a322c7ce659a3c3e15a4754e9.1500454998.git.aviad.krawczyk@huawei.com>
References: <cover.1500454998.git.aviad.krawczyk@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <bc.y@huawei.com>, <victor.gissin@huawei.com>,
        <aviad.krawczyk@huawei.com>, <zhaochen6@huawei.com>,
        <tony.qu@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1500454998.git.aviad.krawczyk@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Create work queues for being used by the queue pairs.

Signed-off-by: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Signed-off-by: Zhao Chen <zhaochen6@huawei.com>
---
 drivers/net/ethernet/huawei/hinic/Makefile      |   4 +-
 drivers/net/ethernet/huawei/hinic/hinic_hw_io.c |  68 ++-
 drivers/net/ethernet/huawei/hinic/hinic_hw_io.h |   6 +
 drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h |  17 +
 drivers/net/ethernet/huawei/hinic/hinic_hw_wq.c | 523 ++++++++++++++++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_wq.h |  86 ++++
 6 files changed, 699 insertions(+), 5 deletions(-)
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_wq.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_wq.h

diff --git a/drivers/net/ethernet/huawei/hinic/Makefile b/drivers/net/ethernet/huawei/hinic/Makefile
index ce0787c..519382b 100644
--- a/drivers/net/ethernet/huawei/hinic/Makefile
+++ b/drivers/net/ethernet/huawei/hinic/Makefile
@@ -1,5 +1,5 @@
 obj-$(CONFIG_HINIC) += hinic.o
 
 hinic-y := hinic_main.o hinic_tx.o hinic_rx.o hinic_port.o hinic_hw_dev.o \
-	   hinic_hw_io.o hinic_hw_mgmt.o hinic_hw_api_cmd.o hinic_hw_eqs.o \
-	   hinic_hw_if.o
\ No newline at end of file
+	   hinic_hw_io.o hinic_hw_wq.o hinic_hw_mgmt.o hinic_hw_api_cmd.o \
+	   hinic_hw_eqs.o hinic_hw_if.o
\ No newline at end of file
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_io.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_io.c
index 7e8c4f3..419fcb0 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_io.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_io.c
@@ -20,6 +20,7 @@
 #include <linux/slab.h>
 
 #include "hinic_hw_if.h"
+#include "hinic_hw_wq.h"
 #include "hinic_hw_qp.h"
 #include "hinic_hw_io.h"
 
@@ -38,8 +39,33 @@ static int init_qp(struct hinic_func_to_io *func_to_io,
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
+		goto rq_alloc_err;
+	}
+
 	return 0;
+
+rq_alloc_err:
+	hinic_wq_free(&func_to_io->wqs, &func_to_io->sq_wq[q_id]);
+	return err;
 }
 
 /**
@@ -50,7 +76,10 @@ static int init_qp(struct hinic_func_to_io *func_to_io,
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
@@ -70,7 +99,7 @@ int hinic_io_create_qps(struct hinic_func_to_io *func_to_io,
 {
 	struct hinic_hwif *hwif = func_to_io->hwif;
 	struct pci_dev *pdev = hwif->pdev;
-	size_t qps_size;
+	size_t qps_size, wq_size;
 	int i, j, err;
 
 	qps_size = num_qps * sizeof(*func_to_io->qps);
@@ -78,6 +107,20 @@ int hinic_io_create_qps(struct hinic_func_to_io *func_to_io,
 	if (!func_to_io->qps)
 		return -ENOMEM;
 
+	wq_size = num_qps * sizeof(*func_to_io->sq_wq);
+	func_to_io->sq_wq = devm_kzalloc(&pdev->dev, wq_size, GFP_KERNEL);
+	if (!func_to_io->sq_wq) {
+		err = -ENOMEM;
+		goto sq_wq_err;
+	}
+
+	wq_size = num_qps * sizeof(*func_to_io->rq_wq);
+	func_to_io->rq_wq = devm_kzalloc(&pdev->dev, wq_size, GFP_KERNEL);
+	if (!func_to_io->rq_wq) {
+		err = -ENOMEM;
+		goto rq_wq_err;
+	}
+
 	for (i = 0; i < num_qps; i++) {
 		err = init_qp(func_to_io, &func_to_io->qps[i], i,
 			      &sq_msix_entries[i], &rq_msix_entries[i]);
@@ -93,6 +136,12 @@ int hinic_io_create_qps(struct hinic_func_to_io *func_to_io,
 	for (j = 0; j < i; j++)
 		destroy_qp(func_to_io, &func_to_io->qps[j]);
 
+	devm_kfree(&pdev->dev, func_to_io->rq_wq);
+
+rq_wq_err:
+	devm_kfree(&pdev->dev, func_to_io->sq_wq);
+
+sq_wq_err:
 	devm_kfree(&pdev->dev, func_to_io->qps);
 	return err;
 }
@@ -111,6 +160,9 @@ void hinic_io_destroy_qps(struct hinic_func_to_io *func_to_io, int num_qps)
 	for (i = 0; i < num_qps; i++)
 		destroy_qp(func_to_io, &func_to_io->qps[i]);
 
+	devm_kfree(&pdev->dev, func_to_io->rq_wq);
+	devm_kfree(&pdev->dev, func_to_io->sq_wq);
+
 	devm_kfree(&pdev->dev, func_to_io->qps);
 }
 
@@ -128,10 +180,19 @@ int hinic_io_init(struct hinic_func_to_io *func_to_io,
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
 
@@ -141,4 +202,5 @@ int hinic_io_init(struct hinic_func_to_io *func_to_io,
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
index 64330fb..e8417d4 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h
@@ -16,6 +16,21 @@
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
+#define HINIC_SQ_WQE_MAX_SIZE                   320
+#define HINIC_RQ_WQE_SIZE                       32
+
 struct hinic_sq {
 	/* should be implemented */
 };
@@ -27,6 +42,8 @@ struct hinic_rq {
 struct hinic_qp {
 	struct hinic_sq         sq;
 	struct hinic_rq         rq;
+
+	u16     q_id;
 };
 
 #endif
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_wq.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_wq.c
new file mode 100644
index 0000000..8e13e66
--- /dev/null
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_wq.c
@@ -0,0 +1,523 @@
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
+	(void *)(((unsigned long)((wqs)->page_vaddr[(wq)->page_idx])) \
+				+ (wq)->block_idx * WQ_BLOCK_SIZE)
+
+#define WQ_BASE_PADDR(wqs, wq)          \
+			((wqs)->page_paddr[(wq)->page_idx] \
+				+ (wq)->block_idx * WQ_BLOCK_SIZE)
+
+#define WQ_BASE_ADDR(wqs, wq)           \
+			(((void *)((wqs)->shadow_page_vaddr[(wq)->page_idx])) \
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
+		goto shadow_vaddr_err;
+
+	return 0;
+
+shadow_vaddr_err:
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
+	size_t size = wqs->num_pages * sizeof(*wqs->page_paddr);
+
+	wqs->page_paddr = devm_kzalloc(&pdev->dev, size, GFP_KERNEL);
+	if (!wqs->page_paddr)
+		return -ENOMEM;
+
+	size = wqs->num_pages * sizeof(*wqs->page_vaddr);
+	wqs->page_vaddr = devm_kzalloc(&pdev->dev, size, GFP_KERNEL);
+	if (!wqs->page_vaddr)
+		goto page_vaddr_err;
+
+	size = wqs->num_pages * sizeof(*wqs->shadow_page_vaddr);
+	wqs->shadow_page_vaddr = devm_kzalloc(&pdev->dev, size, GFP_KERNEL);
+	if (!wqs->shadow_page_vaddr)
+		goto page_shadow_vaddr_err;
+
+	return 0;
+
+page_shadow_vaddr_err:
+	devm_kfree(&pdev->dev, wqs->page_vaddr);
+
+page_vaddr_err:
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
+
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
+			goto wq_allocate_page_err;
+		}
+	}
+
+	wqs->free_blocks = devm_kzalloc(&pdev->dev, WQS_FREE_BLOCKS_SIZE(wqs),
+					GFP_KERNEL);
+	if (!wqs->free_blocks) {
+		err = -ENOMEM;
+		goto alloc_blocks_err;
+	}
+
+	init_wqs_blocks_arr(wqs);
+	return 0;
+
+alloc_blocks_err:
+wq_allocate_page_err:
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
+	size_t size = wq->num_q_pages * wq->max_wqe_size;
+
+	wq->shadow_wqe = devm_kzalloc(&pdev->dev, size, GFP_KERNEL);
+	if (!wq->shadow_wqe)
+		return -ENOMEM;
+
+	size = wq->num_q_pages * sizeof(wq->prod_idx);
+	wq->shadow_idx = devm_kzalloc(&pdev->dev, size, GFP_KERNEL);
+	if (!wq->shadow_idx)
+		goto shadow_idx_err;
+
+	return 0;
+
+shadow_idx_err:
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
+ * @hwif: HW interface for freeing dma addresses
+ * @wq: WQ to free pages from
+ * @num_q_pages: number pages to free
+ **/
+static void free_wq_pages(struct hinic_hwif *hwif, struct hinic_wq *wq,
+			  int num_q_pages)
+{
+	struct pci_dev *pdev = hwif->pdev;
+	u64 *paddr;
+	int i;
+
+	paddr = wq->block_vaddr;
+
+	for (i = 0; i < num_q_pages; i++) {
+		dma_addr_t dma_addr = (dma_addr_t)be64_to_cpu(*paddr);
+		void **vaddr = &wq->shadow_block_vaddr[i];
+
+		dma_free_coherent(&pdev->dev, wq->wq_page_size, *vaddr,
+				  dma_addr);
+
+		paddr++;
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
+static int alloc_wq_pages(struct hinic_hwif *hwif, struct hinic_wq *wq,
+			  int max_pages)
+{
+	struct pci_dev *pdev = hwif->pdev;
+	u64 *paddr;
+	int i, err, num_q_pages;
+
+	paddr = wq->block_vaddr;
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
+		dma_addr_t dma_addr;
+
+		*vaddr = dma_zalloc_coherent(&pdev->dev, wq->wq_page_size,
+					     &dma_addr, GFP_KERNEL);
+		if (!*vaddr) {
+			dev_err(&pdev->dev, "Failed to allocate wq page\n");
+			goto alloc_wq_pages_err;
+		}
+
+		/* HW uses Big Endian Format */
+		*paddr = cpu_to_be64(dma_addr);
+
+		paddr++;
+	}
+
+	return 0;
+
+alloc_wq_pages_err:
+	free_wq_pages(hwif, wq, i);
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
+	err = alloc_wq_pages(wqs->hwif, wq, WQ_MAX_PAGES);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to allocate wq pages\n");
+		goto alloc_wq_pages_err;
+	}
+
+	atomic_set(&wq->cons_idx, 0);
+	atomic_set(&wq->prod_idx, 0);
+	atomic_set(&wq->delta, q_depth);
+	wq->mask = q_depth - 1;
+
+	return 0;
+
+alloc_wq_pages_err:
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
+	free_wq_pages(wqs->hwif, wq, wq->num_q_pages);
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
-- 
1.9.1
