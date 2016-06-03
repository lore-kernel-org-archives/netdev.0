From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 1/4] qed: Revisit chain implementation
Date: Fri, 3 Jun 2016 14:35:32 +0300
Message-ID: <1464953735-2585-2-git-send-email-Yuval.Mintz@qlogic.com>
References: <1464953735-2585-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Rajesh.Borundia@qlogic.com>, <shyam.sundar@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:45135 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752648AbcFCLfx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 07:35:53 -0400
In-Reply-To: <1464953735-2585-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RoCE driver is going to need a 32-bit chain [current chain implementation
for qed* currently supports only 16-bit producer/consumer chains].

This patch adds said support, as well as doing other slight tweaks and
modifications to qed's chain API.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c         | 314 +++++++++---
 drivers/net/ethernet/qlogic/qed/qed_dev_api.h     |   8 +-
 drivers/net/ethernet/qlogic/qed/qed_sp_commands.c |   5 +-
 drivers/net/ethernet/qlogic/qed/qed_spq.c         |  40 +-
 drivers/net/ethernet/qlogic/qede/qede_main.c      |   6 +-
 include/linux/qed/qed_chain.h                     | 553 +++++++++++++---------
 include/linux/qed/qed_if.h                        |   3 +-
 7 files changed, 623 insertions(+), 306 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index e9ce6a7..151173d 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -17,6 +17,7 @@
 #include <linux/pci.h>
 #include <linux/slab.h>
 #include <linux/string.h>
+#include <linux/vmalloc.h>
 #include <linux/etherdevice.h>
 #include <linux/qed/qed_chain.h>
 #include <linux/qed/qed_if.h>
@@ -1779,92 +1780,285 @@ void qed_hw_remove(struct qed_dev *cdev)
 	qed_iov_free_hw_info(cdev);
 }
 
-int qed_chain_alloc(struct qed_dev *cdev,
-		    enum qed_chain_use_mode intended_use,
-		    enum qed_chain_mode mode,
-		    u16 num_elems,
-		    size_t elem_size,
-		    struct qed_chain *p_chain)
+static void qed_chain_free_next_ptr(struct qed_dev *cdev,
+				    struct qed_chain *p_chain)
+{
+	void *p_virt = p_chain->p_virt_addr, *p_virt_next = NULL;
+	dma_addr_t p_phys = p_chain->p_phys_addr, p_phys_next = 0;
+	struct qed_chain_next *p_next;
+	u32 size, i;
+
+	if (!p_virt)
+		return;
+
+	size = p_chain->elem_size * p_chain->usable_per_page;
+
+	for (i = 0; i < p_chain->page_cnt; i++) {
+		if (!p_virt)
+			break;
+
+		p_next = (struct qed_chain_next *)((u8 *)p_virt + size);
+		p_virt_next = p_next->next_virt;
+		p_phys_next = HILO_DMA_REGPAIR(p_next->next_phys);
+
+		dma_free_coherent(&cdev->pdev->dev,
+				  QED_CHAIN_PAGE_SIZE, p_virt, p_phys);
+
+		p_virt = p_virt_next;
+		p_phys = p_phys_next;
+	}
+}
+
+static void qed_chain_free_single(struct qed_dev *cdev,
+				  struct qed_chain *p_chain)
+{
+	if (!p_chain->p_virt_addr)
+		return;
+
+	dma_free_coherent(&cdev->pdev->dev,
+			  QED_CHAIN_PAGE_SIZE,
+			  p_chain->p_virt_addr, p_chain->p_phys_addr);
+}
+
+static void qed_chain_free_pbl(struct qed_dev *cdev, struct qed_chain *p_chain)
+{
+	void **pp_virt_addr_tbl = p_chain->pbl.pp_virt_addr_tbl;
+	u32 page_cnt = p_chain->page_cnt, i, pbl_size;
+	u8 *p_pbl_virt = p_chain->pbl.p_virt_table;
+
+	if (!pp_virt_addr_tbl)
+		return;
+
+	if (!p_chain->pbl.p_virt_table)
+		goto out;
+
+	for (i = 0; i < page_cnt; i++) {
+		if (!pp_virt_addr_tbl[i])
+			break;
+
+		dma_free_coherent(&cdev->pdev->dev,
+				  QED_CHAIN_PAGE_SIZE,
+				  pp_virt_addr_tbl[i],
+				  *(dma_addr_t *)p_pbl_virt);
+
+		p_pbl_virt += QED_CHAIN_PBL_ENTRY_SIZE;
+	}
+
+	pbl_size = page_cnt * QED_CHAIN_PBL_ENTRY_SIZE;
+	dma_free_coherent(&cdev->pdev->dev,
+			  pbl_size,
+			  p_chain->pbl.p_virt_table, p_chain->pbl.p_phys_table);
+out:
+	vfree(p_chain->pbl.pp_virt_addr_tbl);
+}
+
+void qed_chain_free(struct qed_dev *cdev, struct qed_chain *p_chain)
+{
+	switch (p_chain->mode) {
+	case QED_CHAIN_MODE_NEXT_PTR:
+		qed_chain_free_next_ptr(cdev, p_chain);
+		break;
+	case QED_CHAIN_MODE_SINGLE:
+		qed_chain_free_single(cdev, p_chain);
+		break;
+	case QED_CHAIN_MODE_PBL:
+		qed_chain_free_pbl(cdev, p_chain);
+		break;
+	}
+}
+
+static int
+qed_chain_alloc_sanity_check(struct qed_dev *cdev,
+			     enum qed_chain_cnt_type cnt_type,
+			     size_t elem_size, u32 page_cnt)
+{
+	u64 chain_size = ELEMS_PER_PAGE(elem_size) * page_cnt;
+
+	/* The actual chain size can be larger than the maximal possible value
+	 * after rounding up the requested elements number to pages, and after
+	 * taking into acount the unusuable elements (next-ptr elements).
+	 * The size of a "u16" chain can be (U16_MAX + 1) since the chain
+	 * size/capacity fields are of a u32 type.
+	 */
+	if ((cnt_type == QED_CHAIN_CNT_TYPE_U16 &&
+	     chain_size > 0x10000) ||
+	    (cnt_type == QED_CHAIN_CNT_TYPE_U32 &&
+	     chain_size > 0x100000000ULL)) {
+		DP_NOTICE(cdev,
+			  "The actual chain size (0x%llx) is larger than the maximal possible value\n",
+			  chain_size);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int
+qed_chain_alloc_next_ptr(struct qed_dev *cdev, struct qed_chain *p_chain)
 {
-	dma_addr_t p_pbl_phys = 0;
-	void *p_pbl_virt = NULL;
+	void *p_virt = NULL, *p_virt_prev = NULL;
 	dma_addr_t p_phys = 0;
-	void *p_virt = NULL;
-	u16 page_cnt = 0;
-	size_t size;
+	u32 i;
 
-	if (mode == QED_CHAIN_MODE_SINGLE)
-		page_cnt = 1;
-	else
-		page_cnt = QED_CHAIN_PAGE_CNT(num_elems, elem_size, mode);
+	for (i = 0; i < p_chain->page_cnt; i++) {
+		p_virt = dma_alloc_coherent(&cdev->pdev->dev,
+					    QED_CHAIN_PAGE_SIZE,
+					    &p_phys, GFP_KERNEL);
+		if (!p_virt) {
+			DP_NOTICE(cdev, "Failed to allocate chain memory\n");
+			return -ENOMEM;
+		}
+
+		if (i == 0) {
+			qed_chain_init_mem(p_chain, p_virt, p_phys);
+			qed_chain_reset(p_chain);
+		} else {
+			qed_chain_init_next_ptr_elem(p_chain, p_virt_prev,
+						     p_virt, p_phys);
+		}
+
+		p_virt_prev = p_virt;
+	}
+	/* Last page's next element should point to the beginning of the
+	 * chain.
+	 */
+	qed_chain_init_next_ptr_elem(p_chain, p_virt_prev,
+				     p_chain->p_virt_addr,
+				     p_chain->p_phys_addr);
+
+	return 0;
+}
+
+static int
+qed_chain_alloc_single(struct qed_dev *cdev, struct qed_chain *p_chain)
+{
+	dma_addr_t p_phys = 0;
+	void *p_virt = NULL;
 
-	size = page_cnt * QED_CHAIN_PAGE_SIZE;
 	p_virt = dma_alloc_coherent(&cdev->pdev->dev,
-				    size, &p_phys, GFP_KERNEL);
+				    QED_CHAIN_PAGE_SIZE, &p_phys, GFP_KERNEL);
 	if (!p_virt) {
-		DP_NOTICE(cdev, "Failed to allocate chain mem\n");
-		goto nomem;
+		DP_NOTICE(cdev, "Failed to allocate chain memory\n");
+		return -ENOMEM;
 	}
 
-	if (mode == QED_CHAIN_MODE_PBL) {
-		size = page_cnt * QED_CHAIN_PBL_ENTRY_SIZE;
-		p_pbl_virt = dma_alloc_coherent(&cdev->pdev->dev,
-						size, &p_pbl_phys,
-						GFP_KERNEL);
-		if (!p_pbl_virt) {
-			DP_NOTICE(cdev, "Failed to allocate chain pbl mem\n");
-			goto nomem;
-		}
+	qed_chain_init_mem(p_chain, p_virt, p_phys);
+	qed_chain_reset(p_chain);
 
-		qed_chain_pbl_init(p_chain, p_virt, p_phys, page_cnt,
-				   (u8)elem_size, intended_use,
-				   p_pbl_phys, p_pbl_virt);
-	} else {
-		qed_chain_init(p_chain, p_virt, p_phys, page_cnt,
-			       (u8)elem_size, intended_use, mode);
+	return 0;
+}
+
+static int qed_chain_alloc_pbl(struct qed_dev *cdev, struct qed_chain *p_chain)
+{
+	u32 page_cnt = p_chain->page_cnt, size, i;
+	dma_addr_t p_phys = 0, p_pbl_phys = 0;
+	void **pp_virt_addr_tbl = NULL;
+	u8 *p_pbl_virt = NULL;
+	void *p_virt = NULL;
+
+	size = page_cnt * sizeof(*pp_virt_addr_tbl);
+	pp_virt_addr_tbl = vmalloc(size);
+	if (!pp_virt_addr_tbl) {
+		DP_NOTICE(cdev,
+			  "Failed to allocate memory for the chain virtual addresses table\n");
+		return -ENOMEM;
 	}
+	memset(pp_virt_addr_tbl, 0, size);
 
-	return 0;
+	/* The allocation of the PBL table is done with its full size, since it
+	 * is expected to be successive.
+	 * qed_chain_init_pbl_mem() is called even in a case of an allocation
+	 * failure, since pp_virt_addr_tbl was previously allocated, and it
+	 * should be saved to allow its freeing during the error flow.
+	 */
+	size = page_cnt * QED_CHAIN_PBL_ENTRY_SIZE;
+	p_pbl_virt = dma_alloc_coherent(&cdev->pdev->dev,
+					size, &p_pbl_phys, GFP_KERNEL);
+	qed_chain_init_pbl_mem(p_chain, p_pbl_virt, p_pbl_phys,
+			       pp_virt_addr_tbl);
+	if (!p_pbl_virt) {
+		DP_NOTICE(cdev, "Failed to allocate chain pbl memory\n");
+		return -ENOMEM;
+	}
 
-nomem:
-	dma_free_coherent(&cdev->pdev->dev,
-			  page_cnt * QED_CHAIN_PAGE_SIZE,
-			  p_virt, p_phys);
-	dma_free_coherent(&cdev->pdev->dev,
-			  page_cnt * QED_CHAIN_PBL_ENTRY_SIZE,
-			  p_pbl_virt, p_pbl_phys);
+	for (i = 0; i < page_cnt; i++) {
+		p_virt = dma_alloc_coherent(&cdev->pdev->dev,
+					    QED_CHAIN_PAGE_SIZE,
+					    &p_phys, GFP_KERNEL);
+		if (!p_virt) {
+			DP_NOTICE(cdev, "Failed to allocate chain memory\n");
+			return -ENOMEM;
+		}
 
-	return -ENOMEM;
+		if (i == 0) {
+			qed_chain_init_mem(p_chain, p_virt, p_phys);
+			qed_chain_reset(p_chain);
+		}
+
+		/* Fill the PBL table with the physical address of the page */
+		*(dma_addr_t *)p_pbl_virt = p_phys;
+		/* Keep the virtual address of the page */
+		p_chain->pbl.pp_virt_addr_tbl[i] = p_virt;
+
+		p_pbl_virt += QED_CHAIN_PBL_ENTRY_SIZE;
+	}
+
+	return 0;
 }
 
-void qed_chain_free(struct qed_dev *cdev,
-		    struct qed_chain *p_chain)
+int qed_chain_alloc(struct qed_dev *cdev,
+		    enum qed_chain_use_mode intended_use,
+		    enum qed_chain_mode mode,
+		    enum qed_chain_cnt_type cnt_type,
+		    u32 num_elems, size_t elem_size, struct qed_chain *p_chain)
 {
-	size_t size;
+	u32 page_cnt;
+	int rc = 0;
 
-	if (!p_chain->p_virt_addr)
-		return;
+	if (mode == QED_CHAIN_MODE_SINGLE)
+		page_cnt = 1;
+	else
+		page_cnt = QED_CHAIN_PAGE_CNT(num_elems, elem_size, mode);
 
-	if (p_chain->mode == QED_CHAIN_MODE_PBL) {
-		size = p_chain->page_cnt * QED_CHAIN_PBL_ENTRY_SIZE;
-		dma_free_coherent(&cdev->pdev->dev, size,
-				  p_chain->pbl.p_virt_table,
-				  p_chain->pbl.p_phys_table);
+	rc = qed_chain_alloc_sanity_check(cdev, cnt_type, elem_size, page_cnt);
+	if (rc) {
+		DP_NOTICE(cdev,
+			  "Cannot allocate a chain with the given arguments:\n"
+			  "[use_mode %d, mode %d, cnt_type %d, num_elems %d, elem_size %zu]\n",
+			  intended_use, mode, cnt_type, num_elems, elem_size);
+		return rc;
 	}
 
-	size = p_chain->page_cnt * QED_CHAIN_PAGE_SIZE;
-	dma_free_coherent(&cdev->pdev->dev, size,
-			  p_chain->p_virt_addr,
-			  p_chain->p_phys_addr);
+	qed_chain_init_params(p_chain, page_cnt, (u8) elem_size, intended_use,
+			      mode, cnt_type);
+
+	switch (mode) {
+	case QED_CHAIN_MODE_NEXT_PTR:
+		rc = qed_chain_alloc_next_ptr(cdev, p_chain);
+		break;
+	case QED_CHAIN_MODE_SINGLE:
+		rc = qed_chain_alloc_single(cdev, p_chain);
+		break;
+	case QED_CHAIN_MODE_PBL:
+		rc = qed_chain_alloc_pbl(cdev, p_chain);
+		break;
+	}
+	if (rc)
+		goto nomem;
+
+	return 0;
+
+nomem:
+	qed_chain_free(cdev, p_chain);
+	return rc;
 }
 
-int qed_fw_l2_queue(struct qed_hwfn *p_hwfn,
-		    u16 src_id, u16 *dst_id)
+int qed_fw_l2_queue(struct qed_hwfn *p_hwfn, u16 src_id, u16 *dst_id)
 {
 	if (src_id >= RESC_NUM(p_hwfn, QED_L2_QUEUE)) {
 		u16 min, max;
 
-		min = (u16)RESC_START(p_hwfn, QED_L2_QUEUE);
+		min = (u16) RESC_START(p_hwfn, QED_L2_QUEUE);
 		max = min + RESC_NUM(p_hwfn, QED_L2_QUEUE);
 		DP_NOTICE(p_hwfn,
 			  "l2_queue id [%d] is not valid, available indices [%d - %d]\n",
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev_api.h b/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
index dde364d..f810ce4 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
@@ -245,9 +245,8 @@ int
 qed_chain_alloc(struct qed_dev *cdev,
 		enum qed_chain_use_mode intended_use,
 		enum qed_chain_mode mode,
-		u16 num_elems,
-		size_t elem_size,
-		struct qed_chain *p_chain);
+		enum qed_chain_cnt_type cnt_type,
+		u32 num_elems, size_t elem_size, struct qed_chain *p_chain);
 
 /**
  * @brief qed_chain_free - Free chain DMA memory
@@ -255,8 +254,7 @@ qed_chain_alloc(struct qed_dev *cdev,
  * @param p_hwfn
  * @param p_chain
  */
-void qed_chain_free(struct qed_dev *cdev,
-		    struct qed_chain *p_chain);
+void qed_chain_free(struct qed_dev *cdev, struct qed_chain *p_chain);
 
 /**
  * @@brief qed_fw_l2_queue - Get absolute L2 queue ID
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c b/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
index 1225064..63b93fb 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
@@ -308,6 +308,7 @@ int qed_sp_pf_start(struct qed_hwfn *p_hwfn,
 	struct qed_spq_entry *p_ent = NULL;
 	struct qed_sp_init_data init_data;
 	int rc = -EINVAL;
+	u8 page_cnt;
 
 	/* update initial eq producer */
 	qed_eq_prod_update(p_hwfn,
@@ -350,8 +351,8 @@ int qed_sp_pf_start(struct qed_hwfn *p_hwfn,
 	/* Place EQ address in RAMROD */
 	DMA_REGPAIR_LE(p_ramrod->event_ring_pbl_addr,
 		       p_hwfn->p_eq->chain.pbl.p_phys_table);
-	p_ramrod->event_ring_num_pages = (u8)p_hwfn->p_eq->chain.page_cnt;
-
+	page_cnt = (u8)qed_chain_get_page_cnt(&p_hwfn->p_eq->chain);
+	p_ramrod->event_ring_num_pages = page_cnt;
 	DMA_REGPAIR_LE(p_ramrod->consolid_q_pbl_addr,
 		       p_hwfn->p_consq->chain.pbl.p_phys_table);
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_spq.c b/drivers/net/ethernet/qlogic/qed/qed_spq.c
index acac662..ad9bf5c 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_spq.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_spq.c
@@ -343,6 +343,7 @@ struct qed_eq *qed_eq_alloc(struct qed_hwfn *p_hwfn,
 	if (qed_chain_alloc(p_hwfn->cdev,
 			    QED_CHAIN_USE_TO_PRODUCE,
 			    QED_CHAIN_MODE_PBL,
+			    QED_CHAIN_CNT_TYPE_U16,
 			    num_elem,
 			    sizeof(union event_ring_element),
 			    &p_eq->chain)) {
@@ -416,10 +417,10 @@ int qed_eth_cqe_completion(struct qed_hwfn *p_hwfn,
 ***************************************************************************/
 void qed_spq_setup(struct qed_hwfn *p_hwfn)
 {
-	struct qed_spq		*p_spq	= p_hwfn->p_spq;
-	struct qed_spq_entry	*p_virt = NULL;
-	dma_addr_t		p_phys	= 0;
-	unsigned int		i	= 0;
+	struct qed_spq *p_spq = p_hwfn->p_spq;
+	struct qed_spq_entry *p_virt = NULL;
+	dma_addr_t p_phys = 0;
+	u32 i, capacity;
 
 	INIT_LIST_HEAD(&p_spq->pending);
 	INIT_LIST_HEAD(&p_spq->completion_pending);
@@ -431,7 +432,8 @@ void qed_spq_setup(struct qed_hwfn *p_hwfn)
 	p_phys	= p_spq->p_phys + offsetof(struct qed_spq_entry, ramrod);
 	p_virt	= p_spq->p_virt;
 
-	for (i = 0; i < p_spq->chain.capacity; i++) {
+	capacity = qed_chain_get_capacity(&p_spq->chain);
+	for (i = 0; i < capacity; i++) {
 		DMA_REGPAIR_LE(p_virt->elem.data_ptr, p_phys);
 
 		list_add_tail(&p_virt->list, &p_spq->free_pool);
@@ -459,9 +461,10 @@ void qed_spq_setup(struct qed_hwfn *p_hwfn)
 
 int qed_spq_alloc(struct qed_hwfn *p_hwfn)
 {
-	struct qed_spq		*p_spq	= NULL;
-	dma_addr_t		p_phys	= 0;
-	struct qed_spq_entry	*p_virt = NULL;
+	struct qed_spq_entry *p_virt = NULL;
+	struct qed_spq *p_spq = NULL;
+	dma_addr_t p_phys = 0;
+	u32 capacity;
 
 	/* SPQ struct */
 	p_spq =
@@ -475,6 +478,7 @@ int qed_spq_alloc(struct qed_hwfn *p_hwfn)
 	if (qed_chain_alloc(p_hwfn->cdev,
 			    QED_CHAIN_USE_TO_PRODUCE,
 			    QED_CHAIN_MODE_SINGLE,
+			    QED_CHAIN_CNT_TYPE_U16,
 			    0,   /* N/A when the mode is SINGLE */
 			    sizeof(struct slow_path_element),
 			    &p_spq->chain)) {
@@ -483,11 +487,11 @@ int qed_spq_alloc(struct qed_hwfn *p_hwfn)
 	}
 
 	/* allocate and fill the SPQ elements (incl. ramrod data list) */
+	capacity = qed_chain_get_capacity(&p_spq->chain);
 	p_virt = dma_alloc_coherent(&p_hwfn->cdev->pdev->dev,
-				    p_spq->chain.capacity *
+				    capacity *
 				    sizeof(struct qed_spq_entry),
-				    &p_phys,
-				    GFP_KERNEL);
+				    &p_phys, GFP_KERNEL);
 
 	if (!p_virt)
 		goto spq_allocate_fail;
@@ -507,16 +511,18 @@ spq_allocate_fail:
 void qed_spq_free(struct qed_hwfn *p_hwfn)
 {
 	struct qed_spq *p_spq = p_hwfn->p_spq;
+	u32 capacity;
 
 	if (!p_spq)
 		return;
 
-	if (p_spq->p_virt)
+	if (p_spq->p_virt) {
+		capacity = qed_chain_get_capacity(&p_spq->chain);
 		dma_free_coherent(&p_hwfn->cdev->pdev->dev,
-				  p_spq->chain.capacity *
+				  capacity *
 				  sizeof(struct qed_spq_entry),
-				  p_spq->p_virt,
-				  p_spq->p_phys);
+				  p_spq->p_virt, p_spq->p_phys);
+	}
 
 	qed_chain_free(p_hwfn->cdev, &p_spq->chain);
 	;
@@ -871,9 +877,9 @@ struct qed_consq *qed_consq_alloc(struct qed_hwfn *p_hwfn)
 	if (qed_chain_alloc(p_hwfn->cdev,
 			    QED_CHAIN_USE_TO_PRODUCE,
 			    QED_CHAIN_MODE_PBL,
+			    QED_CHAIN_CNT_TYPE_U16,
 			    QED_CHAIN_PAGE_SIZE / 0x80,
-			    0x80,
-			    &p_consq->chain)) {
+			    0x80, &p_consq->chain)) {
 		DP_NOTICE(p_hwfn, "Failed to allocate consq chain");
 		goto consq_allocate_fail;
 	}
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 4f35247..edd2d90 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -2817,6 +2817,7 @@ static int qede_alloc_mem_rxq(struct qede_dev *edev,
 	rc = edev->ops->common->chain_alloc(edev->cdev,
 					    QED_CHAIN_USE_TO_CONSUME_PRODUCE,
 					    QED_CHAIN_MODE_NEXT_PTR,
+					    QED_CHAIN_CNT_TYPE_U16,
 					    RX_RING_SIZE,
 					    sizeof(struct eth_rx_bd),
 					    &rxq->rx_bd_ring);
@@ -2828,6 +2829,7 @@ static int qede_alloc_mem_rxq(struct qede_dev *edev,
 	rc = edev->ops->common->chain_alloc(edev->cdev,
 					    QED_CHAIN_USE_TO_CONSUME,
 					    QED_CHAIN_MODE_PBL,
+					    QED_CHAIN_CNT_TYPE_U16,
 					    RX_RING_SIZE,
 					    sizeof(union eth_rx_cqe),
 					    &rxq->rx_comp_ring);
@@ -2879,9 +2881,9 @@ static int qede_alloc_mem_txq(struct qede_dev *edev,
 	rc = edev->ops->common->chain_alloc(edev->cdev,
 					    QED_CHAIN_USE_TO_CONSUME_PRODUCE,
 					    QED_CHAIN_MODE_PBL,
+					    QED_CHAIN_CNT_TYPE_U16,
 					    NUM_TX_BDS_MAX,
-					    sizeof(*p_virt),
-					    &txq->tx_pbl);
+					    sizeof(*p_virt), &txq->tx_pbl);
 	if (rc)
 		goto err;
 
diff --git a/include/linux/qed/qed_chain.h b/include/linux/qed/qed_chain.h
index 5f8fcaa..eceaa9e 100644
--- a/include/linux/qed/qed_chain.h
+++ b/include/linux/qed/qed_chain.h
@@ -47,16 +47,56 @@ enum qed_chain_use_mode {
 	QED_CHAIN_USE_TO_CONSUME_PRODUCE,	/* Chain starts empty */
 };
 
+enum qed_chain_cnt_type {
+	/* The chain's size/prod/cons are kept in 16-bit variables */
+	QED_CHAIN_CNT_TYPE_U16,
+
+	/* The chain's size/prod/cons are kept in 32-bit variables  */
+	QED_CHAIN_CNT_TYPE_U32,
+};
+
 struct qed_chain_next {
 	struct regpair	next_phys;
 	void		*next_virt;
 };
 
+struct qed_chain_pbl_u16 {
+	u16 prod_page_idx;
+	u16 cons_page_idx;
+};
+
+struct qed_chain_pbl_u32 {
+	u32 prod_page_idx;
+	u32 cons_page_idx;
+};
+
 struct qed_chain_pbl {
+	/* Base address of a pre-allocated buffer for pbl */
 	dma_addr_t	p_phys_table;
 	void		*p_virt_table;
-	u16		prod_page_idx;
-	u16		cons_page_idx;
+
+	/* Table for keeping the virtual addresses of the chain pages,
+	 * respectively to the physical addresses in the pbl table.
+	 */
+	void **pp_virt_addr_tbl;
+
+	/* Index to current used page by producer/consumer */
+	union {
+		struct qed_chain_pbl_u16 pbl16;
+		struct qed_chain_pbl_u32 pbl32;
+	} u;
+};
+
+struct qed_chain_u16 {
+	/* Cyclic index of next element to produce/consme */
+	u16 prod_idx;
+	u16 cons_idx;
+};
+
+struct qed_chain_u32 {
+	/* Cyclic index of next element to produce/consme */
+	u32 prod_idx;
+	u32 cons_idx;
 };
 
 struct qed_chain {
@@ -64,13 +104,25 @@ struct qed_chain {
 	dma_addr_t		p_phys_addr;
 	void			*p_prod_elem;
 	void			*p_cons_elem;
-	u16			page_cnt;
+
 	enum qed_chain_mode	mode;
 	enum qed_chain_use_mode intended_use; /* used to produce/consume */
-	u16			capacity; /*< number of _usable_ elements */
-	u16			size; /* number of elements */
-	u16			prod_idx;
-	u16			cons_idx;
+	enum qed_chain_cnt_type cnt_type;
+
+	union {
+		struct qed_chain_u16 chain16;
+		struct qed_chain_u32 chain32;
+	} u;
+
+	u32 page_cnt;
+
+	/* Number of elements - capacity is for usable elements only,
+	 * while size will contain total number of elements [for entire chain].
+	 */
+	u32 capacity;
+	u32 size;
+
+	/* Elements information for fast calculations */
 	u16			elem_per_page;
 	u16			elem_per_page_mask;
 	u16			elem_unusable;
@@ -96,66 +148,69 @@ struct qed_chain {
 #define QED_CHAIN_PAGE_CNT(elem_cnt, elem_size, mode) \
 	DIV_ROUND_UP(elem_cnt, USABLE_ELEMS_PER_PAGE(elem_size, mode))
 
+#define is_chain_u16(p) ((p)->cnt_type == QED_CHAIN_CNT_TYPE_U16)
+#define is_chain_u32(p) ((p)->cnt_type == QED_CHAIN_CNT_TYPE_U32)
+
 /* Accessors */
 static inline u16 qed_chain_get_prod_idx(struct qed_chain *p_chain)
 {
-	return p_chain->prod_idx;
+	return p_chain->u.chain16.prod_idx;
 }
 
 static inline u16 qed_chain_get_cons_idx(struct qed_chain *p_chain)
 {
-	return p_chain->cons_idx;
+	return p_chain->u.chain16.cons_idx;
+}
+
+static inline u32 qed_chain_get_cons_idx_u32(struct qed_chain *p_chain)
+{
+	return p_chain->u.chain32.cons_idx;
 }
 
 static inline u16 qed_chain_get_elem_left(struct qed_chain *p_chain)
 {
 	u16 used;
 
-	/* we don't need to trancate upon assignmet, as we assign u32->u16 */
-	used = ((u32)0x10000u + (u32)(p_chain->prod_idx)) -
-		(u32)p_chain->cons_idx;
+	used = (u16) (((u32)0x10000 +
+		       (u32)p_chain->u.chain16.prod_idx) -
+		      (u32)p_chain->u.chain16.cons_idx);
 	if (p_chain->mode == QED_CHAIN_MODE_NEXT_PTR)
-		used -= p_chain->prod_idx / p_chain->elem_per_page -
-			p_chain->cons_idx / p_chain->elem_per_page;
+		used -= p_chain->u.chain16.prod_idx / p_chain->elem_per_page -
+		    p_chain->u.chain16.cons_idx / p_chain->elem_per_page;
 
-	return p_chain->capacity - used;
+	return (u16)(p_chain->capacity - used);
 }
 
-static inline u8 qed_chain_is_full(struct qed_chain *p_chain)
+static inline u32 qed_chain_get_elem_left_u32(struct qed_chain *p_chain)
 {
-	return qed_chain_get_elem_left(p_chain) == p_chain->capacity;
-}
+	u32 used;
 
-static inline u8 qed_chain_is_empty(struct qed_chain *p_chain)
-{
-	return qed_chain_get_elem_left(p_chain) == 0;
-}
+	used = (u32) (((u64)0x100000000ULL +
+		       (u64)p_chain->u.chain32.prod_idx) -
+		      (u64)p_chain->u.chain32.cons_idx);
+	if (p_chain->mode == QED_CHAIN_MODE_NEXT_PTR)
+		used -= p_chain->u.chain32.prod_idx / p_chain->elem_per_page -
+		    p_chain->u.chain32.cons_idx / p_chain->elem_per_page;
 
-static inline u16 qed_chain_get_elem_per_page(
-	struct qed_chain *p_chain)
-{
-	return p_chain->elem_per_page;
+	return p_chain->capacity - used;
 }
 
-static inline u16 qed_chain_get_usable_per_page(
-	struct qed_chain *p_chain)
+static inline u16 qed_chain_get_usable_per_page(struct qed_chain *p_chain)
 {
 	return p_chain->usable_per_page;
 }
 
-static inline u16 qed_chain_get_unusable_per_page(
-	struct qed_chain *p_chain)
+static inline u16 qed_chain_get_unusable_per_page(struct qed_chain *p_chain)
 {
 	return p_chain->elem_unusable;
 }
 
-static inline u16 qed_chain_get_size(struct qed_chain *p_chain)
+static inline u32 qed_chain_get_page_cnt(struct qed_chain *p_chain)
 {
-	return p_chain->size;
+	return p_chain->page_cnt;
 }
 
-static inline dma_addr_t
-qed_chain_get_pbl_phys(struct qed_chain *p_chain)
+static inline dma_addr_t qed_chain_get_pbl_phys(struct qed_chain *p_chain)
 {
 	return p_chain->pbl.p_phys_table;
 }
@@ -172,65 +227,63 @@ qed_chain_get_pbl_phys(struct qed_chain *p_chain)
  */
 static inline void
 qed_chain_advance_page(struct qed_chain *p_chain,
-		       void **p_next_elem,
-		       u16 *idx_to_inc,
-		       u16 *page_to_inc)
+		       void **p_next_elem, void *idx_to_inc, void *page_to_inc)
 
 {
+	struct qed_chain_next *p_next = NULL;
+	u32 page_index = 0;
 	switch (p_chain->mode) {
 	case QED_CHAIN_MODE_NEXT_PTR:
-	{
-		struct qed_chain_next *p_next = *p_next_elem;
+		p_next = *p_next_elem;
 		*p_next_elem = p_next->next_virt;
-		*idx_to_inc += p_chain->elem_unusable;
+		if (is_chain_u16(p_chain))
+			*(u16 *)idx_to_inc += p_chain->elem_unusable;
+		else
+			*(u32 *)idx_to_inc += p_chain->elem_unusable;
 		break;
-	}
 	case QED_CHAIN_MODE_SINGLE:
 		*p_next_elem = p_chain->p_virt_addr;
 		break;
 
 	case QED_CHAIN_MODE_PBL:
-		/* It is assumed pages are sequential, next element needs
-		 * to change only when passing going back to first from last.
-		 */
-		if (++(*page_to_inc) == p_chain->page_cnt) {
-			*page_to_inc = 0;
-			*p_next_elem = p_chain->p_virt_addr;
+		if (is_chain_u16(p_chain)) {
+			if (++(*(u16 *)page_to_inc) == p_chain->page_cnt)
+				*(u16 *)page_to_inc = 0;
+			page_index = *(u16 *)page_to_inc;
+		} else {
+			if (++(*(u32 *)page_to_inc) == p_chain->page_cnt)
+				*(u32 *)page_to_inc = 0;
+			page_index = *(u32 *)page_to_inc;
 		}
+		*p_next_elem = p_chain->pbl.pp_virt_addr_tbl[page_index];
 	}
 }
 
 #define is_unusable_idx(p, idx)	\
-	(((p)->idx & (p)->elem_per_page_mask) == (p)->usable_per_page)
+	(((p)->u.chain16.idx & (p)->elem_per_page_mask) == (p)->usable_per_page)
+
+#define is_unusable_idx_u32(p, idx) \
+	(((p)->u.chain32.idx & (p)->elem_per_page_mask) == (p)->usable_per_page)
+#define is_unusable_next_idx(p, idx)				 \
+	((((p)->u.chain16.idx + 1) & (p)->elem_per_page_mask) == \
+	 (p)->usable_per_page)
 
-#define is_unusable_next_idx(p, idx) \
-	((((p)->idx + 1) & (p)->elem_per_page_mask) == (p)->usable_per_page)
+#define is_unusable_next_idx_u32(p, idx)			 \
+	((((p)->u.chain32.idx + 1) & (p)->elem_per_page_mask) == \
+	 (p)->usable_per_page)
 
-#define test_ans_skip(p, idx)				\
+#define test_and_skip(p, idx)						   \
 	do {						\
-		if (is_unusable_idx(p, idx)) {		\
-			(p)->idx += (p)->elem_unusable;	\
+		if (is_chain_u16(p)) {					   \
+			if (is_unusable_idx(p, idx))			   \
+				(p)->u.chain16.idx += (p)->elem_unusable;  \
+		} else {						   \
+			if (is_unusable_idx_u32(p, idx))		   \
+				(p)->u.chain32.idx += (p)->elem_unusable;  \
 		}					\
 	} while (0)
 
 /**
- * @brief qed_chain_return_multi_produced -
- *
- * A chain in which the driver "Produces" elements should use this API
- * to indicate previous produced elements are now consumed.
- *
- * @param p_chain
- * @param num
- */
-static inline void
-qed_chain_return_multi_produced(struct qed_chain *p_chain,
-				u16 num)
-{
-	p_chain->cons_idx += num;
-	test_ans_skip(p_chain, cons_idx);
-}
-
-/**
  * @brief qed_chain_return_produced -
  *
  * A chain in which the driver "Produces" elements should use this API
@@ -240,8 +293,11 @@ qed_chain_return_multi_produced(struct qed_chain *p_chain,
  */
 static inline void qed_chain_return_produced(struct qed_chain *p_chain)
 {
-	p_chain->cons_idx++;
-	test_ans_skip(p_chain, cons_idx);
+	if (is_chain_u16(p_chain))
+		p_chain->u.chain16.cons_idx++;
+	else
+		p_chain->u.chain32.cons_idx++;
+	test_and_skip(p_chain, cons_idx);
 }
 
 /**
@@ -257,21 +313,33 @@ static inline void qed_chain_return_produced(struct qed_chain *p_chain)
  */
 static inline void *qed_chain_produce(struct qed_chain *p_chain)
 {
-	void *ret = NULL;
-
-	if ((p_chain->prod_idx & p_chain->elem_per_page_mask) ==
-	    p_chain->next_page_mask) {
-		qed_chain_advance_page(p_chain, &p_chain->p_prod_elem,
-				       &p_chain->prod_idx,
-				       &p_chain->pbl.prod_page_idx);
+	void *p_ret = NULL, *p_prod_idx, *p_prod_page_idx;
+
+	if (is_chain_u16(p_chain)) {
+		if ((p_chain->u.chain16.prod_idx &
+		     p_chain->elem_per_page_mask) == p_chain->next_page_mask) {
+			p_prod_idx = &p_chain->u.chain16.prod_idx;
+			p_prod_page_idx = &p_chain->pbl.u.pbl16.prod_page_idx;
+			qed_chain_advance_page(p_chain, &p_chain->p_prod_elem,
+					       p_prod_idx, p_prod_page_idx);
+		}
+		p_chain->u.chain16.prod_idx++;
+	} else {
+		if ((p_chain->u.chain32.prod_idx &
+		     p_chain->elem_per_page_mask) == p_chain->next_page_mask) {
+			p_prod_idx = &p_chain->u.chain32.prod_idx;
+			p_prod_page_idx = &p_chain->pbl.u.pbl32.prod_page_idx;
+			qed_chain_advance_page(p_chain, &p_chain->p_prod_elem,
+					       p_prod_idx, p_prod_page_idx);
+		}
+		p_chain->u.chain32.prod_idx++;
 	}
 
-	ret = p_chain->p_prod_elem;
-	p_chain->prod_idx++;
+	p_ret = p_chain->p_prod_elem;
 	p_chain->p_prod_elem = (void *)(((u8 *)p_chain->p_prod_elem) +
 					p_chain->elem_size);
 
-	return ret;
+	return p_ret;
 }
 
 /**
@@ -282,9 +350,9 @@ static inline void *qed_chain_produce(struct qed_chain *p_chain)
  * @param p_chain
  * @param num
  *
- * @return u16, number of unusable BDs
+ * @return number of unusable BDs
  */
-static inline u16 qed_chain_get_capacity(struct qed_chain *p_chain)
+static inline u32 qed_chain_get_capacity(struct qed_chain *p_chain)
 {
 	return p_chain->capacity;
 }
@@ -297,11 +365,13 @@ static inline u16 qed_chain_get_capacity(struct qed_chain *p_chain)
  *
  * @param p_chain
  */
-static inline void
-qed_chain_recycle_consumed(struct qed_chain *p_chain)
+static inline void qed_chain_recycle_consumed(struct qed_chain *p_chain)
 {
-	test_ans_skip(p_chain, prod_idx);
-	p_chain->prod_idx++;
+	test_and_skip(p_chain, prod_idx);
+	if (is_chain_u16(p_chain))
+		p_chain->u.chain16.prod_idx++;
+	else
+		p_chain->u.chain32.prod_idx++;
 }
 
 /**
@@ -316,21 +386,33 @@ qed_chain_recycle_consumed(struct qed_chain *p_chain)
  */
 static inline void *qed_chain_consume(struct qed_chain *p_chain)
 {
-	void *ret = NULL;
-
-	if ((p_chain->cons_idx & p_chain->elem_per_page_mask) ==
-	    p_chain->next_page_mask) {
+	void *p_ret = NULL, *p_cons_idx, *p_cons_page_idx;
+
+	if (is_chain_u16(p_chain)) {
+		if ((p_chain->u.chain16.cons_idx &
+		     p_chain->elem_per_page_mask) == p_chain->next_page_mask) {
+			p_cons_idx = &p_chain->u.chain16.cons_idx;
+			p_cons_page_idx = &p_chain->pbl.u.pbl16.cons_page_idx;
+			qed_chain_advance_page(p_chain, &p_chain->p_cons_elem,
+					       p_cons_idx, p_cons_page_idx);
+		}
+		p_chain->u.chain16.cons_idx++;
+	} else {
+		if ((p_chain->u.chain32.cons_idx &
+		     p_chain->elem_per_page_mask) == p_chain->next_page_mask) {
+			p_cons_idx = &p_chain->u.chain32.cons_idx;
+			p_cons_page_idx = &p_chain->pbl.u.pbl32.cons_page_idx;
 		qed_chain_advance_page(p_chain, &p_chain->p_cons_elem,
-				       &p_chain->cons_idx,
-				       &p_chain->pbl.cons_page_idx);
+					       p_cons_idx, p_cons_page_idx);
+		}
+		p_chain->u.chain32.cons_idx++;
 	}
 
-	ret = p_chain->p_cons_elem;
-	p_chain->cons_idx++;
+	p_ret = p_chain->p_cons_elem;
 	p_chain->p_cons_elem = (void *)(((u8 *)p_chain->p_cons_elem) +
 					p_chain->elem_size);
 
-	return ret;
+	return p_ret;
 }
 
 /**
@@ -340,16 +422,33 @@ static inline void *qed_chain_consume(struct qed_chain *p_chain)
  */
 static inline void qed_chain_reset(struct qed_chain *p_chain)
 {
-	int i;
-
-	p_chain->prod_idx	= 0;
-	p_chain->cons_idx	= 0;
-	p_chain->p_cons_elem	= p_chain->p_virt_addr;
-	p_chain->p_prod_elem	= p_chain->p_virt_addr;
+	u32 i;
+
+	if (is_chain_u16(p_chain)) {
+		p_chain->u.chain16.prod_idx = 0;
+		p_chain->u.chain16.cons_idx = 0;
+	} else {
+		p_chain->u.chain32.prod_idx = 0;
+		p_chain->u.chain32.cons_idx = 0;
+	}
+	p_chain->p_cons_elem = p_chain->p_virt_addr;
+	p_chain->p_prod_elem = p_chain->p_virt_addr;
 
 	if (p_chain->mode == QED_CHAIN_MODE_PBL) {
-		p_chain->pbl.prod_page_idx	= p_chain->page_cnt - 1;
-		p_chain->pbl.cons_page_idx	= p_chain->page_cnt - 1;
+		/* Use (page_cnt - 1) as a reset value for the prod/cons page's
+		 * indices, to avoid unnecessary page advancing on the first
+		 * call to qed_chain_produce/consume. Instead, the indices
+		 * will be advanced to page_cnt and then will be wrapped to 0.
+		 */
+		u32 reset_val = p_chain->page_cnt - 1;
+
+		if (is_chain_u16(p_chain)) {
+			p_chain->pbl.u.pbl16.prod_page_idx = (u16)reset_val;
+			p_chain->pbl.u.pbl16.cons_page_idx = (u16)reset_val;
+		} else {
+			p_chain->pbl.u.pbl32.prod_page_idx = reset_val;
+			p_chain->pbl.u.pbl32.cons_page_idx = reset_val;
+		}
 	}
 
 	switch (p_chain->intended_use) {
@@ -377,168 +476,184 @@ static inline void qed_chain_reset(struct qed_chain *p_chain)
  * @param intended_use
  * @param mode
  */
-static inline void qed_chain_init(struct qed_chain *p_chain,
-				  void *p_virt_addr,
-				  dma_addr_t p_phys_addr,
-				  u16 page_cnt,
-				  u8 elem_size,
-				  enum qed_chain_use_mode intended_use,
-				  enum qed_chain_mode mode)
+static inline void qed_chain_init_params(struct qed_chain *p_chain,
+					 u32 page_cnt,
+					 u8 elem_size,
+					 enum qed_chain_use_mode intended_use,
+					 enum qed_chain_mode mode,
+					 enum qed_chain_cnt_type cnt_type)
 {
 	/* chain fixed parameters */
-	p_chain->p_virt_addr	= p_virt_addr;
-	p_chain->p_phys_addr	= p_phys_addr;
+	p_chain->p_virt_addr = NULL;
+	p_chain->p_phys_addr = 0;
 	p_chain->elem_size	= elem_size;
-	p_chain->page_cnt	= page_cnt;
+	p_chain->intended_use = intended_use;
 	p_chain->mode		= mode;
+	p_chain->cnt_type = cnt_type;
 
-	p_chain->intended_use		= intended_use;
 	p_chain->elem_per_page		= ELEMS_PER_PAGE(elem_size);
-	p_chain->usable_per_page =
-		USABLE_ELEMS_PER_PAGE(elem_size, mode);
-	p_chain->capacity		= p_chain->usable_per_page * page_cnt;
-	p_chain->size			= p_chain->elem_per_page * page_cnt;
+	p_chain->usable_per_page = USABLE_ELEMS_PER_PAGE(elem_size, mode);
 	p_chain->elem_per_page_mask	= p_chain->elem_per_page - 1;
-
 	p_chain->elem_unusable = UNUSABLE_ELEMS_PER_PAGE(elem_size, mode);
-
 	p_chain->next_page_mask = (p_chain->usable_per_page &
 				   p_chain->elem_per_page_mask);
 
-	if (mode == QED_CHAIN_MODE_NEXT_PTR) {
-		struct qed_chain_next	*p_next;
-		u16			i;
-
-		for (i = 0; i < page_cnt - 1; i++) {
-			/* Increment mem_phy to the next page. */
-			p_phys_addr += QED_CHAIN_PAGE_SIZE;
-
-			/* Initialize the physical address of the next page. */
-			p_next = (struct qed_chain_next *)((u8 *)p_virt_addr +
-							   elem_size *
-							   p_chain->
-							   usable_per_page);
-
-			p_next->next_phys.lo	= DMA_LO_LE(p_phys_addr);
-			p_next->next_phys.hi	= DMA_HI_LE(p_phys_addr);
-
-			/* Initialize the virtual address of the next page. */
-			p_next->next_virt = (void *)((u8 *)p_virt_addr +
-						     QED_CHAIN_PAGE_SIZE);
-
-			/* Move to the next page. */
-			p_virt_addr = p_next->next_virt;
-		}
-
-		/* Last page's next should point to beginning of the chain */
-		p_next = (struct qed_chain_next *)((u8 *)p_virt_addr +
-						   elem_size *
-						   p_chain->usable_per_page);
+	p_chain->page_cnt = page_cnt;
+	p_chain->capacity = p_chain->usable_per_page * page_cnt;
+	p_chain->size = p_chain->elem_per_page * page_cnt;
 
-		p_next->next_phys.lo	= DMA_LO_LE(p_chain->p_phys_addr);
-		p_next->next_phys.hi	= DMA_HI_LE(p_chain->p_phys_addr);
-		p_next->next_virt	= p_chain->p_virt_addr;
-	}
-	qed_chain_reset(p_chain);
+	p_chain->pbl.p_phys_table = 0;
+	p_chain->pbl.p_virt_table = NULL;
+	p_chain->pbl.pp_virt_addr_tbl = NULL;
 }
 
 /**
- * @brief qed_chain_pbl_init - Initalizes a basic pbl chain
- *        struct
+ * @brief qed_chain_init_mem -
+ *
+ * Initalizes a basic chain struct with its chain buffers
+ *
  * @param p_chain
  * @param p_virt_addr	virtual address of allocated buffer's beginning
  * @param p_phys_addr	physical address of allocated buffer's beginning
- * @param page_cnt	number of pages in the allocated buffer
- * @param elem_size	size of each element in the chain
- * @param use_mode
- * @param p_phys_pbl	pointer to a pre-allocated side table
- *                      which will hold physical page addresses.
- * @param p_virt_pbl	pointer to a pre allocated side table
- *                      which will hold virtual page addresses.
+ *
  */
-static inline void
-qed_chain_pbl_init(struct qed_chain *p_chain,
-		   void *p_virt_addr,
-		   dma_addr_t p_phys_addr,
-		   u16 page_cnt,
-		   u8 elem_size,
-		   enum qed_chain_use_mode use_mode,
-		   dma_addr_t p_phys_pbl,
-		   dma_addr_t *p_virt_pbl)
+static inline void qed_chain_init_mem(struct qed_chain *p_chain,
+				      void *p_virt_addr, dma_addr_t p_phys_addr)
 {
-	dma_addr_t *p_pbl_dma = p_virt_pbl;
-	int i;
-
-	qed_chain_init(p_chain, p_virt_addr, p_phys_addr, page_cnt,
-		       elem_size, use_mode, QED_CHAIN_MODE_PBL);
+	p_chain->p_virt_addr = p_virt_addr;
+	p_chain->p_phys_addr = p_phys_addr;
+}
 
+/**
+ * @brief qed_chain_init_pbl_mem -
+ *
+ * Initalizes a basic chain struct with its pbl buffers
+ *
+ * @param p_chain
+ * @param p_virt_pbl	pointer to a pre allocated side table which will hold
+ *                      virtual page addresses.
+ * @param p_phys_pbl	pointer to a pre-allocated side table which will hold
+ *                      physical page addresses.
+ * @param pp_virt_addr_tbl
+ *                      pointer to a pre-allocated side table which will hold
+ *                      the virtual addresses of the chain pages.
+ *
+ */
+static inline void qed_chain_init_pbl_mem(struct qed_chain *p_chain,
+					  void *p_virt_pbl,
+					  dma_addr_t p_phys_pbl,
+					  void **pp_virt_addr_tbl)
+{
 	p_chain->pbl.p_phys_table = p_phys_pbl;
 	p_chain->pbl.p_virt_table = p_virt_pbl;
-
-	/* Fill the PBL with physical addresses*/
-	for (i = 0; i < page_cnt; i++) {
-		*p_pbl_dma = p_phys_addr;
-		p_phys_addr += QED_CHAIN_PAGE_SIZE;
-		p_pbl_dma++;
-	}
+	p_chain->pbl.pp_virt_addr_tbl = pp_virt_addr_tbl;
 }
 
 /**
- * @brief qed_chain_set_prod - sets the prod to the given
- *        value
+ * @brief qed_chain_init_next_ptr_elem -
+ *
+ * Initalizes a next pointer element
+ *
+ * @param p_chain
+ * @param p_virt_curr	virtual address of a chain page of which the next
+ *                      pointer element is initialized
+ * @param p_virt_next	virtual address of the next chain page
+ * @param p_phys_next	physical address of the next chain page
  *
- * @param prod_idx
- * @param p_prod_elem
  */
-static inline void qed_chain_set_prod(struct qed_chain *p_chain,
-				      u16 prod_idx,
-				      void *p_prod_elem)
+static inline void
+qed_chain_init_next_ptr_elem(struct qed_chain *p_chain,
+			     void *p_virt_curr,
+			     void *p_virt_next, dma_addr_t p_phys_next)
 {
-	p_chain->prod_idx	= prod_idx;
-	p_chain->p_prod_elem	= p_prod_elem;
+	struct qed_chain_next *p_next;
+	u32 size;
+
+	size = p_chain->elem_size * p_chain->usable_per_page;
+	p_next = (struct qed_chain_next *)((u8 *)p_virt_curr + size);
+
+	DMA_REGPAIR_LE(p_next->next_phys, p_phys_next);
+
+	p_next->next_virt = p_virt_next;
 }
 
 /**
- * @brief qed_chain_get_elem -
+ * @brief qed_chain_get_last_elem -
  *
- * get a pointer to an element represented by absolute idx
+ * Returns a pointer to the last element of the chain
  *
  * @param p_chain
- * @assumption p_chain->size is a power of 2
  *
- * @return void*, a pointer to next element
+ * @return void*
  */
-static inline void *qed_chain_sge_get_elem(struct qed_chain *p_chain,
-					   u16 idx)
+static inline void *qed_chain_get_last_elem(struct qed_chain *p_chain)
 {
-	void *ret = NULL;
-
-	if (idx >= p_chain->size)
-		return NULL;
+	struct qed_chain_next *p_next = NULL;
+	void *p_virt_addr = NULL;
+	u32 size, last_page_idx;
 
-	ret = (u8 *)p_chain->p_virt_addr + p_chain->elem_size * idx;
+	if (!p_chain->p_virt_addr)
+		goto out;
 
-	return ret;
+	switch (p_chain->mode) {
+	case QED_CHAIN_MODE_NEXT_PTR:
+		size = p_chain->elem_size * p_chain->usable_per_page;
+		p_virt_addr = p_chain->p_virt_addr;
+		p_next = (struct qed_chain_next *)((u8 *)p_virt_addr + size);
+		while (p_next->next_virt != p_chain->p_virt_addr) {
+			p_virt_addr = p_next->next_virt;
+			p_next = (struct qed_chain_next *)((u8 *)p_virt_addr +
+							   size);
+		}
+		break;
+	case QED_CHAIN_MODE_SINGLE:
+		p_virt_addr = p_chain->p_virt_addr;
+		break;
+	case QED_CHAIN_MODE_PBL:
+		last_page_idx = p_chain->page_cnt - 1;
+		p_virt_addr = p_chain->pbl.pp_virt_addr_tbl[last_page_idx];
+		break;
+	}
+	/* p_virt_addr points at this stage to the last page of the chain */
+	size = p_chain->elem_size * (p_chain->usable_per_page - 1);
+	p_virt_addr = (u8 *)p_virt_addr + size;
+out:
+	return p_virt_addr;
 }
 
 /**
- * @brief qed_chain_sge_inc_cons_prod
+ * @brief qed_chain_set_prod - sets the prod to the given value
  *
- * for sge chains, producer isn't increased serially, the ring
- * is expected to be full at all times. Once elements are
- * consumed, they are immediately produced.
+ * @param prod_idx
+ * @param p_prod_elem
+ */
+static inline void qed_chain_set_prod(struct qed_chain *p_chain,
+				      u32 prod_idx, void *p_prod_elem)
+{
+	if (is_chain_u16(p_chain))
+		p_chain->u.chain16.prod_idx = (u16) prod_idx;
+	else
+		p_chain->u.chain32.prod_idx = prod_idx;
+	p_chain->p_prod_elem = p_prod_elem;
+}
+
+/**
+ * @brief qed_chain_pbl_zero_mem - set chain memory to 0
  *
  * @param p_chain
- * @param cnt
- *
- * @return inline void
  */
-static inline void
-qed_chain_sge_inc_cons_prod(struct qed_chain *p_chain,
-			    u16 cnt)
+static inline void qed_chain_pbl_zero_mem(struct qed_chain *p_chain)
 {
-	p_chain->prod_idx += cnt;
-	p_chain->cons_idx += cnt;
+	u32 i, page_cnt;
+
+	if (p_chain->mode != QED_CHAIN_MODE_PBL)
+		return;
+
+	page_cnt = qed_chain_get_page_cnt(p_chain);
+
+	for (i = 0; i < page_cnt; i++)
+		memset(p_chain->pbl.pp_virt_addr_tbl[i], 0,
+		       QED_CHAIN_PAGE_SIZE);
 }
 
 #endif
diff --git a/include/linux/qed/qed_if.h b/include/linux/qed/qed_if.h
index 4c29439..15efccf 100644
--- a/include/linux/qed/qed_if.h
+++ b/include/linux/qed/qed_if.h
@@ -325,7 +325,8 @@ struct qed_common_ops {
 	int		(*chain_alloc)(struct qed_dev *cdev,
 				       enum qed_chain_use_mode intended_use,
 				       enum qed_chain_mode mode,
-				       u16 num_elems,
+				       enum qed_chain_cnt_type cnt_type,
+				       u32 num_elems,
 				       size_t elem_size,
 				       struct qed_chain *p_chain);
 
-- 
1.9.3
