From: Romain Perier <romain.perier@collabora.com>
Subject: [PATCH v6 10/15] scsi: lpfc: Replace PCI pool old API
Date: Sun, 19 Mar 2017 18:03:59 +0100
Message-ID: <20170319170404.17362-11-romain.perier@collabora.com>
References: <20170319170404.17362-1-romain.perier@collabora.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org, linux-scsi@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Romain Perier <romain.perier@collabora.com>,
        Peter Senna Tschudin <peter.senna@collabora.co.uk>
To: Dan Williams <dan.j.williams@intel.com>,
        Doug Ledford <dledford@redhat.com>,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        jeffrey.t.kirsher@intel.com,
        "David S. Miller" <davem@davemloft.net>, stas.yakovlev@gmail.com,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        Felipe Balbi <balbi@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170319170404.17362-1-romain.perier@collabora.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The PCI pool API is deprecated. This commit replaces the PCI pool old
API by the appropriate function with the DMA pool API. It also updates
some comments, accordingly.

Signed-off-by: Romain Perier <romain.perier@collabora.com>
Reviewed-by: Peter Senna Tschudin <peter.senna@collabora.com>
---
 drivers/scsi/lpfc/lpfc.h       |  14 +++---
 drivers/scsi/lpfc/lpfc_init.c  |  16 +++----
 drivers/scsi/lpfc/lpfc_mem.c   | 106 ++++++++++++++++++++---------------------
 drivers/scsi/lpfc/lpfc_nvme.c  |   6 +--
 drivers/scsi/lpfc/lpfc_nvmet.c |   4 +-
 drivers/scsi/lpfc/lpfc_scsi.c  |  12 ++---
 6 files changed, 77 insertions(+), 81 deletions(-)

diff --git a/drivers/scsi/lpfc/lpfc.h b/drivers/scsi/lpfc/lpfc.h
index 257bbdd..c6f82db 100644
--- a/drivers/scsi/lpfc/lpfc.h
+++ b/drivers/scsi/lpfc/lpfc.h
@@ -935,13 +935,13 @@ struct lpfc_hba {
 	struct list_head active_rrq_list;
 	spinlock_t hbalock;
 
-	/* pci_mem_pools */
-	struct pci_pool *lpfc_sg_dma_buf_pool;
-	struct pci_pool *lpfc_mbuf_pool;
-	struct pci_pool *lpfc_hrb_pool;	/* header receive buffer pool */
-	struct pci_pool *lpfc_drb_pool; /* data receive buffer pool */
-	struct pci_pool *lpfc_hbq_pool;	/* SLI3 hbq buffer pool */
-	struct pci_pool *txrdy_payload_pool;
+	/* dma_mem_pools */
+	struct dma_pool *lpfc_sg_dma_buf_pool;
+	struct dma_pool *lpfc_mbuf_pool;
+	struct dma_pool *lpfc_hrb_pool;	/* header receive buffer pool */
+	struct dma_pool *lpfc_drb_pool; /* data receive buffer pool */
+	struct dma_pool *lpfc_hbq_pool;	/* SLI3 hbq buffer pool */
+	struct dma_pool *txrdy_payload_pool;
 	struct lpfc_dma_pool lpfc_mbuf_safety_pool;
 
 	mempool_t *mbox_mem_pool;
diff --git a/drivers/scsi/lpfc/lpfc_init.c b/drivers/scsi/lpfc/lpfc_init.c
index 2697d49..0ffdd722 100644
--- a/drivers/scsi/lpfc/lpfc_init.c
+++ b/drivers/scsi/lpfc/lpfc_init.c
@@ -3151,7 +3151,7 @@ lpfc_scsi_free(struct lpfc_hba *phba)
 	list_for_each_entry_safe(sb, sb_next, &phba->lpfc_scsi_buf_list_put,
 				 list) {
 		list_del(&sb->list);
-		pci_pool_free(phba->lpfc_sg_dma_buf_pool, sb->data,
+		dma_pool_free(phba->lpfc_sg_dma_buf_pool, sb->data,
 			      sb->dma_handle);
 		kfree(sb);
 		phba->total_scsi_bufs--;
@@ -3162,7 +3162,7 @@ lpfc_scsi_free(struct lpfc_hba *phba)
 	list_for_each_entry_safe(sb, sb_next, &phba->lpfc_scsi_buf_list_get,
 				 list) {
 		list_del(&sb->list);
-		pci_pool_free(phba->lpfc_sg_dma_buf_pool, sb->data,
+		dma_pool_free(phba->lpfc_sg_dma_buf_pool, sb->data,
 			      sb->dma_handle);
 		kfree(sb);
 		phba->total_scsi_bufs--;
@@ -3193,7 +3193,7 @@ lpfc_nvme_free(struct lpfc_hba *phba)
 	list_for_each_entry_safe(lpfc_ncmd, lpfc_ncmd_next,
 				 &phba->lpfc_nvme_buf_list_put, list) {
 		list_del(&lpfc_ncmd->list);
-		pci_pool_free(phba->lpfc_sg_dma_buf_pool, lpfc_ncmd->data,
+		dma_pool_free(phba->lpfc_sg_dma_buf_pool, lpfc_ncmd->data,
 			      lpfc_ncmd->dma_handle);
 		kfree(lpfc_ncmd);
 		phba->total_nvme_bufs--;
@@ -3204,7 +3204,7 @@ lpfc_nvme_free(struct lpfc_hba *phba)
 	list_for_each_entry_safe(lpfc_ncmd, lpfc_ncmd_next,
 				 &phba->lpfc_nvme_buf_list_get, list) {
 		list_del(&lpfc_ncmd->list);
-		pci_pool_free(phba->lpfc_sg_dma_buf_pool, lpfc_ncmd->data,
+		dma_pool_free(phba->lpfc_sg_dma_buf_pool, lpfc_ncmd->data,
 			      lpfc_ncmd->dma_handle);
 		kfree(lpfc_ncmd);
 		phba->total_nvme_bufs--;
@@ -3517,7 +3517,7 @@ lpfc_sli4_scsi_sgl_update(struct lpfc_hba *phba)
 			list_remove_head(&scsi_sgl_list, psb,
 					 struct lpfc_scsi_buf, list);
 			if (psb) {
-				pci_pool_free(phba->lpfc_sg_dma_buf_pool,
+				dma_pool_free(phba->lpfc_sg_dma_buf_pool,
 					      psb->data, psb->dma_handle);
 				kfree(psb);
 			}
@@ -3652,7 +3652,7 @@ lpfc_sli4_nvme_sgl_update(struct lpfc_hba *phba)
 			list_remove_head(&nvme_sgl_list, lpfc_ncmd,
 					 struct lpfc_nvme_buf, list);
 			if (lpfc_ncmd) {
-				pci_pool_free(phba->lpfc_sg_dma_buf_pool,
+				dma_pool_free(phba->lpfc_sg_dma_buf_pool,
 					      lpfc_ncmd->data,
 					      lpfc_ncmd->dma_handle);
 				kfree(lpfc_ncmd);
@@ -6673,8 +6673,8 @@ lpfc_create_shost(struct lpfc_hba *phba)
 	if (phba->nvmet_support) {
 		/* Only 1 vport (pport) will support NVME target */
 		if (phba->txrdy_payload_pool == NULL) {
-			phba->txrdy_payload_pool = pci_pool_create(
-				"txrdy_pool", phba->pcidev,
+			phba->txrdy_payload_pool = dma_pool_create(
+				"txrdy_pool", &phba->pcidev->dev,
 				TXRDY_PAYLOAD_LEN, 16, 0);
 			if (phba->txrdy_payload_pool) {
 				phba->targetport = NULL;
diff --git a/drivers/scsi/lpfc/lpfc_mem.c b/drivers/scsi/lpfc/lpfc_mem.c
index 5986c79..3bdd5d9 100644
--- a/drivers/scsi/lpfc/lpfc_mem.c
+++ b/drivers/scsi/lpfc/lpfc_mem.c
@@ -97,8 +97,8 @@ lpfc_mem_alloc(struct lpfc_hba *phba, int align)
 			i = SLI4_PAGE_SIZE;
 
 		phba->lpfc_sg_dma_buf_pool =
-			pci_pool_create("lpfc_sg_dma_buf_pool",
-					phba->pcidev,
+			dma_pool_create("lpfc_sg_dma_buf_pool",
+					&phba->pcidev->dev,
 					phba->cfg_sg_dma_buf_size,
 					i, 0);
 		if (!phba->lpfc_sg_dma_buf_pool)
@@ -106,17 +106,17 @@ lpfc_mem_alloc(struct lpfc_hba *phba, int align)
 
 	} else {
 		phba->lpfc_sg_dma_buf_pool =
-			pci_pool_create("lpfc_sg_dma_buf_pool",
-					phba->pcidev, phba->cfg_sg_dma_buf_size,
-					align, 0);
+			dma_pool_create("lpfc_sg_dma_buf_pool",
+					&phba->pcidev->dev,
+					phba->cfg_sg_dma_buf_size, align, 0);
 
 		if (!phba->lpfc_sg_dma_buf_pool)
 			goto fail;
 	}
 
-	phba->lpfc_mbuf_pool = pci_pool_create("lpfc_mbuf_pool", phba->pcidev,
-							LPFC_BPL_SIZE,
-							align, 0);
+	phba->lpfc_mbuf_pool = dma_pool_create("lpfc_mbuf_pool",
+					       &phba->pcidev->dev,
+					       LPFC_BPL_SIZE, align, 0);
 	if (!phba->lpfc_mbuf_pool)
 		goto fail_free_dma_buf_pool;
 
@@ -128,7 +128,7 @@ lpfc_mem_alloc(struct lpfc_hba *phba, int align)
 	pool->max_count = 0;
 	pool->current_count = 0;
 	for ( i = 0; i < LPFC_MBUF_POOL_SIZE; i++) {
-		pool->elements[i].virt = pci_pool_alloc(phba->lpfc_mbuf_pool,
+		pool->elements[i].virt = dma_pool_alloc(phba->lpfc_mbuf_pool,
 				       GFP_KERNEL, &pool->elements[i].phys);
 		if (!pool->elements[i].virt)
 			goto fail_free_mbuf_pool;
@@ -152,21 +152,21 @@ lpfc_mem_alloc(struct lpfc_hba *phba, int align)
 						sizeof(struct lpfc_node_rrq));
 		if (!phba->rrq_pool)
 			goto fail_free_nlp_mem_pool;
-		phba->lpfc_hrb_pool = pci_pool_create("lpfc_hrb_pool",
-					      phba->pcidev,
+		phba->lpfc_hrb_pool = dma_pool_create("lpfc_hrb_pool",
+					      &phba->pcidev->dev,
 					      LPFC_HDR_BUF_SIZE, align, 0);
 		if (!phba->lpfc_hrb_pool)
 			goto fail_free_rrq_mem_pool;
 
-		phba->lpfc_drb_pool = pci_pool_create("lpfc_drb_pool",
-					      phba->pcidev,
+		phba->lpfc_drb_pool = dma_pool_create("lpfc_drb_pool",
+					      &phba->pcidev->dev,
 					      LPFC_DATA_BUF_SIZE, align, 0);
 		if (!phba->lpfc_drb_pool)
 			goto fail_free_hrb_pool;
 		phba->lpfc_hbq_pool = NULL;
 	} else {
-		phba->lpfc_hbq_pool = pci_pool_create("lpfc_hbq_pool",
-			phba->pcidev, LPFC_BPL_SIZE, align, 0);
+		phba->lpfc_hbq_pool = dma_pool_create("lpfc_hbq_pool",
+			&phba->pcidev->dev, LPFC_BPL_SIZE, align, 0);
 		if (!phba->lpfc_hbq_pool)
 			goto fail_free_nlp_mem_pool;
 		phba->lpfc_hrb_pool = NULL;
@@ -185,10 +185,10 @@ lpfc_mem_alloc(struct lpfc_hba *phba, int align)
 
 	return 0;
 fail_free_drb_pool:
-	pci_pool_destroy(phba->lpfc_drb_pool);
+	dma_pool_destroy(phba->lpfc_drb_pool);
 	phba->lpfc_drb_pool = NULL;
  fail_free_hrb_pool:
-	pci_pool_destroy(phba->lpfc_hrb_pool);
+	dma_pool_destroy(phba->lpfc_hrb_pool);
 	phba->lpfc_hrb_pool = NULL;
  fail_free_rrq_mem_pool:
 	mempool_destroy(phba->rrq_pool);
@@ -201,14 +201,14 @@ lpfc_mem_alloc(struct lpfc_hba *phba, int align)
 	phba->mbox_mem_pool = NULL;
  fail_free_mbuf_pool:
 	while (i--)
-		pci_pool_free(phba->lpfc_mbuf_pool, pool->elements[i].virt,
+		dma_pool_free(phba->lpfc_mbuf_pool, pool->elements[i].virt,
 						 pool->elements[i].phys);
 	kfree(pool->elements);
  fail_free_lpfc_mbuf_pool:
-	pci_pool_destroy(phba->lpfc_mbuf_pool);
+	dma_pool_destroy(phba->lpfc_mbuf_pool);
 	phba->lpfc_mbuf_pool = NULL;
  fail_free_dma_buf_pool:
-	pci_pool_destroy(phba->lpfc_sg_dma_buf_pool);
+	dma_pool_destroy(phba->lpfc_sg_dma_buf_pool);
 	phba->lpfc_sg_dma_buf_pool = NULL;
  fail:
 	return -ENOMEM;
@@ -232,18 +232,14 @@ lpfc_mem_free(struct lpfc_hba *phba)
 
 	/* Free HBQ pools */
 	lpfc_sli_hbqbuf_free_all(phba);
-	if (phba->lpfc_drb_pool)
-		pci_pool_destroy(phba->lpfc_drb_pool);
+	dma_pool_destroy(phba->lpfc_drb_pool);
 	phba->lpfc_drb_pool = NULL;
-	if (phba->lpfc_hrb_pool)
-		pci_pool_destroy(phba->lpfc_hrb_pool);
+	dma_pool_destroy(phba->lpfc_hrb_pool);
 	phba->lpfc_hrb_pool = NULL;
-	if (phba->txrdy_payload_pool)
-		pci_pool_destroy(phba->txrdy_payload_pool);
+	dma_pool_destroy(phba->txrdy_payload_pool);
 	phba->txrdy_payload_pool = NULL;
 
-	if (phba->lpfc_hbq_pool)
-		pci_pool_destroy(phba->lpfc_hbq_pool);
+	dma_pool_destroy(phba->lpfc_hbq_pool);
 	phba->lpfc_hbq_pool = NULL;
 
 	if (phba->rrq_pool)
@@ -264,15 +260,15 @@ lpfc_mem_free(struct lpfc_hba *phba)
 
 	/* Free MBUF memory pool */
 	for (i = 0; i < pool->current_count; i++)
-		pci_pool_free(phba->lpfc_mbuf_pool, pool->elements[i].virt,
+		dma_pool_free(phba->lpfc_mbuf_pool, pool->elements[i].virt,
 			      pool->elements[i].phys);
 	kfree(pool->elements);
 
-	pci_pool_destroy(phba->lpfc_mbuf_pool);
+	dma_pool_destroy(phba->lpfc_mbuf_pool);
 	phba->lpfc_mbuf_pool = NULL;
 
 	/* Free DMA buffer memory pool */
-	pci_pool_destroy(phba->lpfc_sg_dma_buf_pool);
+	dma_pool_destroy(phba->lpfc_sg_dma_buf_pool);
 	phba->lpfc_sg_dma_buf_pool = NULL;
 
 	/* Free Device Data memory pool */
@@ -361,7 +357,7 @@ lpfc_mem_free_all(struct lpfc_hba *phba)
  * @handle: used to return the DMA-mapped address of the mbuf
  *
  * Description: Allocates a DMA-mapped buffer from the lpfc_mbuf_pool PCI pool.
- * Allocates from generic pci_pool_alloc function first and if that fails and
+ * Allocates from generic dma_pool_alloc function first and if that fails and
  * mem_flags has MEM_PRI set (the only defined flag), returns an mbuf from the
  * HBA's pool.
  *
@@ -379,7 +375,7 @@ lpfc_mbuf_alloc(struct lpfc_hba *phba, int mem_flags, dma_addr_t *handle)
 	unsigned long iflags;
 	void *ret;
 
-	ret = pci_pool_alloc(phba->lpfc_mbuf_pool, GFP_KERNEL, handle);
+	ret = dma_pool_alloc(phba->lpfc_mbuf_pool, GFP_KERNEL, handle);
 
 	spin_lock_irqsave(&phba->hbalock, iflags);
 	if (!ret && (mem_flags & MEM_PRI) && pool->current_count) {
@@ -415,7 +411,7 @@ __lpfc_mbuf_free(struct lpfc_hba * phba, void *virt, dma_addr_t dma)
 		pool->elements[pool->current_count].phys = dma;
 		pool->current_count++;
 	} else {
-		pci_pool_free(phba->lpfc_mbuf_pool, virt, dma);
+		dma_pool_free(phba->lpfc_mbuf_pool, virt, dma);
 	}
 	return;
 }
@@ -452,7 +448,7 @@ lpfc_mbuf_free(struct lpfc_hba * phba, void *virt, dma_addr_t dma)
  * @handle: used to return the DMA-mapped address of the nvmet_buf
  *
  * Description: Allocates a DMA-mapped buffer from the lpfc_sg_dma_buf_pool
- * PCI pool.  Allocates from generic pci_pool_alloc function.
+ * PCI pool.  Allocates from generic dma_pool_alloc function.
  *
  * Returns:
  *   pointer to the allocated nvmet_buf on success
@@ -463,7 +459,7 @@ lpfc_nvmet_buf_alloc(struct lpfc_hba *phba, int mem_flags, dma_addr_t *handle)
 {
 	void *ret;
 
-	ret = pci_pool_alloc(phba->lpfc_sg_dma_buf_pool, GFP_KERNEL, handle);
+	ret = dma_pool_alloc(phba->lpfc_sg_dma_buf_pool, GFP_KERNEL, handle);
 	return ret;
 }
 
@@ -479,7 +475,7 @@ lpfc_nvmet_buf_alloc(struct lpfc_hba *phba, int mem_flags, dma_addr_t *handle)
 void
 lpfc_nvmet_buf_free(struct lpfc_hba *phba, void *virt, dma_addr_t dma)
 {
-	pci_pool_free(phba->lpfc_sg_dma_buf_pool, virt, dma);
+	dma_pool_free(phba->lpfc_sg_dma_buf_pool, virt, dma);
 }
 
 /**
@@ -504,7 +500,7 @@ lpfc_els_hbq_alloc(struct lpfc_hba *phba)
 	if (!hbqbp)
 		return NULL;
 
-	hbqbp->dbuf.virt = pci_pool_alloc(phba->lpfc_hbq_pool, GFP_KERNEL,
+	hbqbp->dbuf.virt = dma_pool_alloc(phba->lpfc_hbq_pool, GFP_KERNEL,
 					  &hbqbp->dbuf.phys);
 	if (!hbqbp->dbuf.virt) {
 		kfree(hbqbp);
@@ -529,7 +525,7 @@ lpfc_els_hbq_alloc(struct lpfc_hba *phba)
 void
 lpfc_els_hbq_free(struct lpfc_hba *phba, struct hbq_dmabuf *hbqbp)
 {
-	pci_pool_free(phba->lpfc_hbq_pool, hbqbp->dbuf.virt, hbqbp->dbuf.phys);
+	dma_pool_free(phba->lpfc_hbq_pool, hbqbp->dbuf.virt, hbqbp->dbuf.phys);
 	kfree(hbqbp);
 	return;
 }
@@ -556,16 +552,16 @@ lpfc_sli4_rb_alloc(struct lpfc_hba *phba)
 	if (!dma_buf)
 		return NULL;
 
-	dma_buf->hbuf.virt = pci_pool_alloc(phba->lpfc_hrb_pool, GFP_KERNEL,
+	dma_buf->hbuf.virt = dma_pool_alloc(phba->lpfc_hrb_pool, GFP_KERNEL,
 					    &dma_buf->hbuf.phys);
 	if (!dma_buf->hbuf.virt) {
 		kfree(dma_buf);
 		return NULL;
 	}
-	dma_buf->dbuf.virt = pci_pool_alloc(phba->lpfc_drb_pool, GFP_KERNEL,
+	dma_buf->dbuf.virt = dma_pool_alloc(phba->lpfc_drb_pool, GFP_KERNEL,
 					    &dma_buf->dbuf.phys);
 	if (!dma_buf->dbuf.virt) {
-		pci_pool_free(phba->lpfc_hrb_pool, dma_buf->hbuf.virt,
+		dma_pool_free(phba->lpfc_hrb_pool, dma_buf->hbuf.virt,
 			      dma_buf->hbuf.phys);
 		kfree(dma_buf);
 		return NULL;
@@ -589,8 +585,8 @@ lpfc_sli4_rb_alloc(struct lpfc_hba *phba)
 void
 lpfc_sli4_rb_free(struct lpfc_hba *phba, struct hbq_dmabuf *dmab)
 {
-	pci_pool_free(phba->lpfc_hrb_pool, dmab->hbuf.virt, dmab->hbuf.phys);
-	pci_pool_free(phba->lpfc_drb_pool, dmab->dbuf.virt, dmab->dbuf.phys);
+	dma_pool_free(phba->lpfc_hrb_pool, dmab->hbuf.virt, dmab->hbuf.phys);
+	dma_pool_free(phba->lpfc_drb_pool, dmab->dbuf.virt, dmab->dbuf.phys);
 	kfree(dmab);
 }
 
@@ -618,16 +614,16 @@ lpfc_sli4_nvmet_alloc(struct lpfc_hba *phba)
 	if (!dma_buf)
 		return NULL;
 
-	dma_buf->hbuf.virt = pci_pool_alloc(phba->lpfc_hrb_pool, GFP_KERNEL,
+	dma_buf->hbuf.virt = dma_pool_alloc(phba->lpfc_hrb_pool, GFP_KERNEL,
 					    &dma_buf->hbuf.phys);
 	if (!dma_buf->hbuf.virt) {
 		kfree(dma_buf);
 		return NULL;
 	}
-	dma_buf->dbuf.virt = pci_pool_alloc(phba->lpfc_drb_pool, GFP_KERNEL,
+	dma_buf->dbuf.virt = dma_pool_alloc(phba->lpfc_drb_pool, GFP_KERNEL,
 					    &dma_buf->dbuf.phys);
 	if (!dma_buf->dbuf.virt) {
-		pci_pool_free(phba->lpfc_hrb_pool, dma_buf->hbuf.virt,
+		dma_pool_free(phba->lpfc_hrb_pool, dma_buf->hbuf.virt,
 			      dma_buf->hbuf.phys);
 		kfree(dma_buf);
 		return NULL;
@@ -637,9 +633,9 @@ lpfc_sli4_nvmet_alloc(struct lpfc_hba *phba)
 	dma_buf->context = kzalloc(sizeof(struct lpfc_nvmet_rcv_ctx),
 				   GFP_KERNEL);
 	if (!dma_buf->context) {
-		pci_pool_free(phba->lpfc_drb_pool, dma_buf->dbuf.virt,
+		dma_pool_free(phba->lpfc_drb_pool, dma_buf->dbuf.virt,
 			      dma_buf->dbuf.phys);
-		pci_pool_free(phba->lpfc_hrb_pool, dma_buf->hbuf.virt,
+		dma_pool_free(phba->lpfc_hrb_pool, dma_buf->hbuf.virt,
 			      dma_buf->hbuf.phys);
 		kfree(dma_buf);
 		return NULL;
@@ -648,9 +644,9 @@ lpfc_sli4_nvmet_alloc(struct lpfc_hba *phba)
 	dma_buf->iocbq = lpfc_sli_get_iocbq(phba);
 	if (!dma_buf->iocbq) {
 		kfree(dma_buf->context);
-		pci_pool_free(phba->lpfc_drb_pool, dma_buf->dbuf.virt,
+		dma_pool_free(phba->lpfc_drb_pool, dma_buf->dbuf.virt,
 			      dma_buf->dbuf.phys);
-		pci_pool_free(phba->lpfc_hrb_pool, dma_buf->hbuf.virt,
+		dma_pool_free(phba->lpfc_hrb_pool, dma_buf->hbuf.virt,
 			      dma_buf->hbuf.phys);
 		kfree(dma_buf);
 		lpfc_printf_log(phba, KERN_ERR, LOG_NVME,
@@ -678,9 +674,9 @@ lpfc_sli4_nvmet_alloc(struct lpfc_hba *phba)
 	if (!dma_buf->sglq) {
 		lpfc_sli_release_iocbq(phba, dma_buf->iocbq);
 		kfree(dma_buf->context);
-		pci_pool_free(phba->lpfc_drb_pool, dma_buf->dbuf.virt,
+		dma_pool_free(phba->lpfc_drb_pool, dma_buf->dbuf.virt,
 			      dma_buf->dbuf.phys);
-		pci_pool_free(phba->lpfc_hrb_pool, dma_buf->hbuf.virt,
+		dma_pool_free(phba->lpfc_hrb_pool, dma_buf->hbuf.virt,
 			      dma_buf->hbuf.phys);
 		kfree(dma_buf);
 		lpfc_printf_log(phba, KERN_ERR, LOG_NVME,
@@ -717,8 +713,8 @@ lpfc_sli4_nvmet_free(struct lpfc_hba *phba, struct rqb_dmabuf *dmab)
 
 	lpfc_sli_release_iocbq(phba, dmab->iocbq);
 	kfree(dmab->context);
-	pci_pool_free(phba->lpfc_hrb_pool, dmab->hbuf.virt, dmab->hbuf.phys);
-	pci_pool_free(phba->lpfc_drb_pool, dmab->dbuf.virt, dmab->dbuf.phys);
+	dma_pool_free(phba->lpfc_hrb_pool, dmab->hbuf.virt, dmab->hbuf.phys);
+	dma_pool_free(phba->lpfc_drb_pool, dmab->dbuf.virt, dmab->dbuf.phys);
 	kfree(dmab);
 }
 
diff --git a/drivers/scsi/lpfc/lpfc_nvme.c b/drivers/scsi/lpfc/lpfc_nvme.c
index 0a4c190..ac907377e 100644
--- a/drivers/scsi/lpfc/lpfc_nvme.c
+++ b/drivers/scsi/lpfc/lpfc_nvme.c
@@ -1942,7 +1942,7 @@ lpfc_new_nvme_buf(struct lpfc_vport *vport, int num_to_alloc)
 		 * pci bus space for an I/O. The DMA buffer includes the
 		 * number of SGE's necessary to support the sg_tablesize.
 		 */
-		lpfc_ncmd->data = pci_pool_alloc(phba->lpfc_sg_dma_buf_pool,
+		lpfc_ncmd->data = dma_pool_alloc(phba->lpfc_sg_dma_buf_pool,
 						 GFP_KERNEL,
 						 &lpfc_ncmd->dma_handle);
 		if (!lpfc_ncmd->data) {
@@ -1953,7 +1953,7 @@ lpfc_new_nvme_buf(struct lpfc_vport *vport, int num_to_alloc)
 
 		lxri = lpfc_sli4_next_xritag(phba);
 		if (lxri == NO_XRI) {
-			pci_pool_free(phba->lpfc_sg_dma_buf_pool,
+			dma_pool_free(phba->lpfc_sg_dma_buf_pool,
 				      lpfc_ncmd->data, lpfc_ncmd->dma_handle);
 			kfree(lpfc_ncmd);
 			break;
@@ -1964,7 +1964,7 @@ lpfc_new_nvme_buf(struct lpfc_vport *vport, int num_to_alloc)
 		/* Allocate iotag for lpfc_ncmd->cur_iocbq. */
 		iotag = lpfc_sli_next_iotag(phba, pwqeq);
 		if (iotag == 0) {
-			pci_pool_free(phba->lpfc_sg_dma_buf_pool,
+			dma_pool_free(phba->lpfc_sg_dma_buf_pool,
 				      lpfc_ncmd->data, lpfc_ncmd->dma_handle);
 			kfree(lpfc_ncmd);
 			lpfc_printf_log(phba, KERN_ERR, LOG_NVME_IOERR,
diff --git a/drivers/scsi/lpfc/lpfc_nvmet.c b/drivers/scsi/lpfc/lpfc_nvmet.c
index b7739a5..76c514e 100644
--- a/drivers/scsi/lpfc/lpfc_nvmet.c
+++ b/drivers/scsi/lpfc/lpfc_nvmet.c
@@ -140,7 +140,7 @@ lpfc_nvmet_rq_post(struct lpfc_hba *phba, struct lpfc_nvmet_rcv_ctx *ctxp,
 {
 	if (ctxp) {
 		if (ctxp->txrdy) {
-			pci_pool_free(phba->txrdy_payload_pool, ctxp->txrdy,
+			dma_pool_free(phba->txrdy_payload_pool, ctxp->txrdy,
 				      ctxp->txrdy_phys);
 			ctxp->txrdy = NULL;
 			ctxp->txrdy_phys = 0;
@@ -1381,7 +1381,7 @@ lpfc_nvmet_prep_fcp_wqe(struct lpfc_hba *phba,
 
 	case NVMET_FCOP_WRITEDATA:
 		/* Words 0 - 2 : The first sg segment */
-		txrdy = pci_pool_alloc(phba->txrdy_payload_pool,
+		txrdy = dma_pool_alloc(phba->txrdy_payload_pool,
 				       GFP_KERNEL, &physaddr);
 		if (!txrdy) {
 			lpfc_printf_log(phba, KERN_ERR, LOG_NVME_IOERR,
diff --git a/drivers/scsi/lpfc/lpfc_scsi.c b/drivers/scsi/lpfc/lpfc_scsi.c
index 54fd0c8..b6c1a6f 100644
--- a/drivers/scsi/lpfc/lpfc_scsi.c
+++ b/drivers/scsi/lpfc/lpfc_scsi.c
@@ -415,7 +415,7 @@ lpfc_new_scsi_buf_s3(struct lpfc_vport *vport, int num_to_alloc)
 		 * struct fcp_cmnd, struct fcp_rsp and the number of bde's
 		 * necessary to support the sg_tablesize.
 		 */
-		psb->data = pci_pool_zalloc(phba->lpfc_sg_dma_buf_pool,
+		psb->data = dma_pool_zalloc(phba->lpfc_sg_dma_buf_pool,
 					GFP_KERNEL, &psb->dma_handle);
 		if (!psb->data) {
 			kfree(psb);
@@ -426,7 +426,7 @@ lpfc_new_scsi_buf_s3(struct lpfc_vport *vport, int num_to_alloc)
 		/* Allocate iotag for psb->cur_iocbq. */
 		iotag = lpfc_sli_next_iotag(phba, &psb->cur_iocbq);
 		if (iotag == 0) {
-			pci_pool_free(phba->lpfc_sg_dma_buf_pool,
+			dma_pool_free(phba->lpfc_sg_dma_buf_pool,
 				      psb->data, psb->dma_handle);
 			kfree(psb);
 			break;
@@ -825,7 +825,7 @@ lpfc_new_scsi_buf_s4(struct lpfc_vport *vport, int num_to_alloc)
 		 * for the struct fcp_cmnd, struct fcp_rsp and the number
 		 * of bde's necessary to support the sg_tablesize.
 		 */
-		psb->data = pci_pool_zalloc(phba->lpfc_sg_dma_buf_pool,
+		psb->data = dma_pool_zalloc(phba->lpfc_sg_dma_buf_pool,
 						GFP_KERNEL, &psb->dma_handle);
 		if (!psb->data) {
 			kfree(psb);
@@ -838,7 +838,7 @@ lpfc_new_scsi_buf_s4(struct lpfc_vport *vport, int num_to_alloc)
 		 */
 		if (phba->cfg_enable_bg  && (((unsigned long)(psb->data) &
 		    (unsigned long)(SLI4_PAGE_SIZE - 1)) != 0)) {
-			pci_pool_free(phba->lpfc_sg_dma_buf_pool,
+			dma_pool_free(phba->lpfc_sg_dma_buf_pool,
 				      psb->data, psb->dma_handle);
 			kfree(psb);
 			break;
@@ -847,7 +847,7 @@ lpfc_new_scsi_buf_s4(struct lpfc_vport *vport, int num_to_alloc)
 
 		lxri = lpfc_sli4_next_xritag(phba);
 		if (lxri == NO_XRI) {
-			pci_pool_free(phba->lpfc_sg_dma_buf_pool,
+			dma_pool_free(phba->lpfc_sg_dma_buf_pool,
 				      psb->data, psb->dma_handle);
 			kfree(psb);
 			break;
@@ -856,7 +856,7 @@ lpfc_new_scsi_buf_s4(struct lpfc_vport *vport, int num_to_alloc)
 		/* Allocate iotag for psb->cur_iocbq. */
 		iotag = lpfc_sli_next_iotag(phba, &psb->cur_iocbq);
 		if (iotag == 0) {
-			pci_pool_free(phba->lpfc_sg_dma_buf_pool,
+			dma_pool_free(phba->lpfc_sg_dma_buf_pool,
 				      psb->data, psb->dma_handle);
 			kfree(psb);
 			lpfc_printf_log(phba, KERN_ERR, LOG_FCP,
-- 
2.9.3
