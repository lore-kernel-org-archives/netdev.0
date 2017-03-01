From: Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Subject: [PATCH v4 10/19] scsi: lpfc: Replace PCI pool old API
Date: Wed,  1 Mar 2017 16:55:12 +0100
Message-ID: <20170301155521.30281-11-romain.perier@collabora.com>
References: <20170301155521.30281-1-romain.perier@collabora.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>,
        Peter Senna Tschudin <peter.senna-ZGY8ohtN/8pPYcu2f3hruQ@public.gmane.org>
To: Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, stas.yakovlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        "James E.J. Bottomley" <jejb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
        "Martin K. Petersen" <martin.petersen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        Felipe Balbi <balbi-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170301155521.30281-1-romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The PCI pool API is deprecated. This commits replaces the PCI pool old
API by the appropriated function with the DMA pool API. It also updates
some comments, accordingly.

Signed-off-by: Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Reviewed-by: Peter Senna Tschudin <peter.senna-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
---
 drivers/scsi/lpfc/lpfc.h       |  12 ++---
 drivers/scsi/lpfc/lpfc_init.c  |  16 +++----
 drivers/scsi/lpfc/lpfc_mem.c   | 105 ++++++++++++++++++++---------------------
 drivers/scsi/lpfc/lpfc_nvme.c  |   6 +--
 drivers/scsi/lpfc/lpfc_nvmet.c |   4 +-
 drivers/scsi/lpfc/lpfc_scsi.c  |  12 ++---
 6 files changed, 76 insertions(+), 79 deletions(-)

diff --git a/drivers/scsi/lpfc/lpfc.h b/drivers/scsi/lpfc/lpfc.h
index 0bba2e3..29492bc 100644
--- a/drivers/scsi/lpfc/lpfc.h
+++ b/drivers/scsi/lpfc/lpfc.h
@@ -934,12 +934,12 @@ struct lpfc_hba {
 	spinlock_t hbalock;
 
 	/* pci_mem_pools */
-	struct pci_pool *lpfc_sg_dma_buf_pool;
-	struct pci_pool *lpfc_mbuf_pool;
-	struct pci_pool *lpfc_hrb_pool;	/* header receive buffer pool */
-	struct pci_pool *lpfc_drb_pool; /* data receive buffer pool */
-	struct pci_pool *lpfc_hbq_pool;	/* SLI3 hbq buffer pool */
-	struct pci_pool *txrdy_payload_pool;
+	struct dma_pool *lpfc_sg_dma_buf_pool;
+	struct dma_pool *lpfc_mbuf_pool;
+	struct dma_pool *lpfc_hrb_pool;	/* header receive buffer pool */
+	struct dma_pool *lpfc_drb_pool; /* data receive buffer pool */
+	struct dma_pool *lpfc_hbq_pool;	/* SLI3 hbq buffer pool */
+	struct dma_pool *txrdy_payload_pool;
 	struct lpfc_dma_pool lpfc_mbuf_safety_pool;
 
 	mempool_t *mbox_mem_pool;
diff --git a/drivers/scsi/lpfc/lpfc_init.c b/drivers/scsi/lpfc/lpfc_init.c
index 0ee429d..b856457 100644
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
@@ -3614,7 +3614,7 @@ lpfc_sli4_nvme_sgl_update(struct lpfc_hba *phba)
 			list_remove_head(&nvme_sgl_list, lpfc_ncmd,
 					 struct lpfc_nvme_buf, list);
 			if (lpfc_ncmd) {
-				pci_pool_free(phba->lpfc_sg_dma_buf_pool,
+				dma_pool_free(phba->lpfc_sg_dma_buf_pool,
 					      lpfc_ncmd->data,
 					      lpfc_ncmd->dma_handle);
 				kfree(lpfc_ncmd);
@@ -6629,8 +6629,8 @@ lpfc_create_shost(struct lpfc_hba *phba)
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
index c61d8d6..49dce0c 100644
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
@@ -106,17 +106,18 @@ lpfc_mem_alloc(struct lpfc_hba *phba, int align)
 
 	} else {
 		phba->lpfc_sg_dma_buf_pool =
-			pci_pool_create("lpfc_sg_dma_buf_pool",
-					phba->pcidev, phba->cfg_sg_dma_buf_size,
+			dma_pool_create("lpfc_sg_dma_buf_pool",
+					&phba->pcidev->dev,
+					phba->cfg_sg_dma_buf_size,
 					align, 0);
 
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
 
@@ -128,7 +129,7 @@ lpfc_mem_alloc(struct lpfc_hba *phba, int align)
 	pool->max_count = 0;
 	pool->current_count = 0;
 	for ( i = 0; i < LPFC_MBUF_POOL_SIZE; i++) {
-		pool->elements[i].virt = pci_pool_alloc(phba->lpfc_mbuf_pool,
+		pool->elements[i].virt = dma_pool_alloc(phba->lpfc_mbuf_pool,
 				       GFP_KERNEL, &pool->elements[i].phys);
 		if (!pool->elements[i].virt)
 			goto fail_free_mbuf_pool;
@@ -152,21 +153,21 @@ lpfc_mem_alloc(struct lpfc_hba *phba, int align)
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
@@ -185,10 +186,10 @@ lpfc_mem_alloc(struct lpfc_hba *phba, int align)
 
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
@@ -201,14 +202,14 @@ lpfc_mem_alloc(struct lpfc_hba *phba, int align)
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
@@ -232,18 +233,14 @@ lpfc_mem_free(struct lpfc_hba *phba)
 
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
@@ -264,15 +261,15 @@ lpfc_mem_free(struct lpfc_hba *phba)
 
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
@@ -361,7 +358,7 @@ lpfc_mem_free_all(struct lpfc_hba *phba)
  * @handle: used to return the DMA-mapped address of the mbuf
  *
  * Description: Allocates a DMA-mapped buffer from the lpfc_mbuf_pool PCI pool.
- * Allocates from generic pci_pool_alloc function first and if that fails and
+ * Allocates from generic dma_pool_alloc function first and if that fails and
  * mem_flags has MEM_PRI set (the only defined flag), returns an mbuf from the
  * HBA's pool.
  *
@@ -379,7 +376,7 @@ lpfc_mbuf_alloc(struct lpfc_hba *phba, int mem_flags, dma_addr_t *handle)
 	unsigned long iflags;
 	void *ret;
 
-	ret = pci_pool_alloc(phba->lpfc_mbuf_pool, GFP_KERNEL, handle);
+	ret = dma_pool_alloc(phba->lpfc_mbuf_pool, GFP_KERNEL, handle);
 
 	spin_lock_irqsave(&phba->hbalock, iflags);
 	if (!ret && (mem_flags & MEM_PRI) && pool->current_count) {
@@ -415,7 +412,7 @@ __lpfc_mbuf_free(struct lpfc_hba * phba, void *virt, dma_addr_t dma)
 		pool->elements[pool->current_count].phys = dma;
 		pool->current_count++;
 	} else {
-		pci_pool_free(phba->lpfc_mbuf_pool, virt, dma);
+		dma_pool_free(phba->lpfc_mbuf_pool, virt, dma);
 	}
 	return;
 }
@@ -452,7 +449,7 @@ lpfc_mbuf_free(struct lpfc_hba * phba, void *virt, dma_addr_t dma)
  * @handle: used to return the DMA-mapped address of the nvmet_buf
  *
  * Description: Allocates a DMA-mapped buffer from the lpfc_sg_dma_buf_pool
- * PCI pool.  Allocates from generic pci_pool_alloc function.
+ * PCI pool.  Allocates from generic dma_pool_alloc function.
  *
  * Returns:
  *   pointer to the allocated nvmet_buf on success
@@ -463,7 +460,7 @@ lpfc_nvmet_buf_alloc(struct lpfc_hba *phba, int mem_flags, dma_addr_t *handle)
 {
 	void *ret;
 
-	ret = pci_pool_alloc(phba->lpfc_sg_dma_buf_pool, GFP_KERNEL, handle);
+	ret = dma_pool_alloc(phba->lpfc_sg_dma_buf_pool, GFP_KERNEL, handle);
 	return ret;
 }
 
@@ -479,7 +476,7 @@ lpfc_nvmet_buf_alloc(struct lpfc_hba *phba, int mem_flags, dma_addr_t *handle)
 void
 lpfc_nvmet_buf_free(struct lpfc_hba *phba, void *virt, dma_addr_t dma)
 {
-	pci_pool_free(phba->lpfc_sg_dma_buf_pool, virt, dma);
+	dma_pool_free(phba->lpfc_sg_dma_buf_pool, virt, dma);
 }
 
 /**
@@ -504,7 +501,7 @@ lpfc_els_hbq_alloc(struct lpfc_hba *phba)
 	if (!hbqbp)
 		return NULL;
 
-	hbqbp->dbuf.virt = pci_pool_alloc(phba->lpfc_hbq_pool, GFP_KERNEL,
+	hbqbp->dbuf.virt = dma_pool_alloc(phba->lpfc_hbq_pool, GFP_KERNEL,
 					  &hbqbp->dbuf.phys);
 	if (!hbqbp->dbuf.virt) {
 		kfree(hbqbp);
@@ -529,7 +526,7 @@ lpfc_els_hbq_alloc(struct lpfc_hba *phba)
 void
 lpfc_els_hbq_free(struct lpfc_hba *phba, struct hbq_dmabuf *hbqbp)
 {
-	pci_pool_free(phba->lpfc_hbq_pool, hbqbp->dbuf.virt, hbqbp->dbuf.phys);
+	dma_pool_free(phba->lpfc_hbq_pool, hbqbp->dbuf.virt, hbqbp->dbuf.phys);
 	kfree(hbqbp);
 	return;
 }
@@ -556,16 +553,16 @@ lpfc_sli4_rb_alloc(struct lpfc_hba *phba)
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
@@ -589,8 +586,8 @@ lpfc_sli4_rb_alloc(struct lpfc_hba *phba)
 void
 lpfc_sli4_rb_free(struct lpfc_hba *phba, struct hbq_dmabuf *dmab)
 {
-	pci_pool_free(phba->lpfc_hrb_pool, dmab->hbuf.virt, dmab->hbuf.phys);
-	pci_pool_free(phba->lpfc_drb_pool, dmab->dbuf.virt, dmab->dbuf.phys);
+	dma_pool_free(phba->lpfc_hrb_pool, dmab->hbuf.virt, dmab->hbuf.phys);
+	dma_pool_free(phba->lpfc_drb_pool, dmab->dbuf.virt, dmab->dbuf.phys);
 	kfree(dmab);
 }
 
@@ -618,16 +615,16 @@ lpfc_sli4_nvmet_alloc(struct lpfc_hba *phba)
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
@@ -637,9 +634,9 @@ lpfc_sli4_nvmet_alloc(struct lpfc_hba *phba)
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
@@ -649,9 +646,9 @@ lpfc_sli4_nvmet_alloc(struct lpfc_hba *phba)
 	dma_buf->iocbq->iocb_flag = LPFC_IO_NVMET;
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
@@ -678,9 +675,9 @@ lpfc_sli4_nvmet_alloc(struct lpfc_hba *phba)
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
@@ -717,8 +714,8 @@ lpfc_sli4_nvmet_free(struct lpfc_hba *phba, struct rqb_dmabuf *dmab)
 
 	lpfc_sli_release_iocbq(phba, dmab->iocbq);
 	kfree(dmab->context);
-	pci_pool_free(phba->lpfc_hrb_pool, dmab->hbuf.virt, dmab->hbuf.phys);
-	pci_pool_free(phba->lpfc_drb_pool, dmab->dbuf.virt, dmab->dbuf.phys);
+	dma_pool_free(phba->lpfc_hrb_pool, dmab->hbuf.virt, dmab->hbuf.phys);
+	dma_pool_free(phba->lpfc_drb_pool, dmab->dbuf.virt, dmab->dbuf.phys);
 	kfree(dmab);
 }
 
diff --git a/drivers/scsi/lpfc/lpfc_nvme.c b/drivers/scsi/lpfc/lpfc_nvme.c
index 609a908..97cb080 100644
--- a/drivers/scsi/lpfc/lpfc_nvme.c
+++ b/drivers/scsi/lpfc/lpfc_nvme.c
@@ -1950,7 +1950,7 @@ lpfc_new_nvme_buf(struct lpfc_vport *vport, int num_to_alloc)
 		 * pci bus space for an I/O. The DMA buffer includes the
 		 * number of SGE's necessary to support the sg_tablesize.
 		 */
-		lpfc_ncmd->data = pci_pool_alloc(phba->lpfc_sg_dma_buf_pool,
+		lpfc_ncmd->data = dma_pool_alloc(phba->lpfc_sg_dma_buf_pool,
 						 GFP_KERNEL,
 						 &lpfc_ncmd->dma_handle);
 		if (!lpfc_ncmd->data) {
@@ -1961,7 +1961,7 @@ lpfc_new_nvme_buf(struct lpfc_vport *vport, int num_to_alloc)
 
 		lxri = lpfc_sli4_next_xritag(phba);
 		if (lxri == NO_XRI) {
-			pci_pool_free(phba->lpfc_sg_dma_buf_pool,
+			dma_pool_free(phba->lpfc_sg_dma_buf_pool,
 				      lpfc_ncmd->data, lpfc_ncmd->dma_handle);
 			kfree(lpfc_ncmd);
 			break;
@@ -1972,7 +1972,7 @@ lpfc_new_nvme_buf(struct lpfc_vport *vport, int num_to_alloc)
 		/* Allocate iotag for lpfc_ncmd->cur_iocbq. */
 		iotag = lpfc_sli_next_iotag(phba, pwqeq);
 		if (iotag == 0) {
-			pci_pool_free(phba->lpfc_sg_dma_buf_pool,
+			dma_pool_free(phba->lpfc_sg_dma_buf_pool,
 				      lpfc_ncmd->data, lpfc_ncmd->dma_handle);
 			kfree(lpfc_ncmd);
 			lpfc_printf_log(phba, KERN_ERR, LOG_NVME_IOERR,
diff --git a/drivers/scsi/lpfc/lpfc_nvmet.c b/drivers/scsi/lpfc/lpfc_nvmet.c
index c421e17..a446c52 100644
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
@@ -1353,7 +1353,7 @@ lpfc_nvmet_prep_fcp_wqe(struct lpfc_hba *phba,
 
 	case NVMET_FCOP_WRITEDATA:
 		/* Words 0 - 2 : The first sg segment */
-		txrdy = pci_pool_alloc(phba->txrdy_payload_pool,
+		txrdy = dma_pool_alloc(phba->txrdy_payload_pool,
 				       GFP_KERNEL, &physaddr);
 		if (!txrdy) {
 			lpfc_printf_log(phba, KERN_ERR, LOG_NVME_IOERR,
diff --git a/drivers/scsi/lpfc/lpfc_scsi.c b/drivers/scsi/lpfc/lpfc_scsi.c
index 9d6384a..b3a4238 100644
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

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
