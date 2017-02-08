From: Peter Senna Tschudin <peter.senna@collabora.com>
Subject: Re: [RFC 10/19] scsi: lpfc: Replace PCI pool old API
Date: Wed, 8 Feb 2017 19:32:11 +0100
Message-ID: <20170208183211.GJ16878@collabora.com>
References: <20170208163457.28853-1-romain.perier@collabora.com>
 <20170208163457.28853-11-romain.perier@collabora.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dan.j.williams@intel.com>,
        Doug Ledford <dledford@redhat.com>,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        jeffrey.t.kirsher@intel.com,
        "David S. Miller" <davem@davemloft.net>, stas.yakovlev@gmail.com,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        Felipe Balbi <balbi@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org, linux-scsi@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Peter Senna Tschudin <peter.senna@collabora.co.uk>
To: Romain Perier <romain.perier@collabora.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170208163457.28853-11-romain.perier@collabora.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 08, 2017 at 05:34:48PM +0100, Romain Perier wrote:
> The PCI pool API is deprecated. This commits replaces the PCI pool old
> API by the appropriated function with the DMA pool API.
> 
> Signed-off-by: Romain Perier <romain.perier@collabora.com>
> ---
>  drivers/scsi/lpfc/lpfc.h      | 10 +++----
>  drivers/scsi/lpfc/lpfc_init.c |  6 ++---
>  drivers/scsi/lpfc/lpfc_mem.c  | 62 +++++++++++++++++++++----------------------
>  drivers/scsi/lpfc/lpfc_scsi.c | 12 ++++-----
>  4 files changed, 45 insertions(+), 45 deletions(-)
> 
> diff --git a/drivers/scsi/lpfc/lpfc.h b/drivers/scsi/lpfc/lpfc.h
> index 6593b07..c391352 100644
> --- a/drivers/scsi/lpfc/lpfc.h
> +++ b/drivers/scsi/lpfc/lpfc.h
> @@ -862,11 +862,11 @@ struct lpfc_hba {
>  	spinlock_t hbalock;
>  
>  	/* pci_mem_pools */
> -	struct pci_pool *lpfc_scsi_dma_buf_pool;
> -	struct pci_pool *lpfc_mbuf_pool;
> -	struct pci_pool *lpfc_hrb_pool;	/* header receive buffer pool */
> -	struct pci_pool *lpfc_drb_pool; /* data receive buffer pool */
> -	struct pci_pool *lpfc_hbq_pool;	/* SLI3 hbq buffer pool */
> +	struct dma_pool *lpfc_scsi_dma_buf_pool;
> +	struct dma_pool *lpfc_mbuf_pool;
> +	struct dma_pool *lpfc_hrb_pool;	/* header receive buffer pool */
> +	struct dma_pool *lpfc_drb_pool; /* data receive buffer pool */
> +	struct dma_pool *lpfc_hbq_pool;	/* SLI3 hbq buffer pool */
>  	struct lpfc_dma_pool lpfc_mbuf_safety_pool;
>  
>  	mempool_t *mbox_mem_pool;
> diff --git a/drivers/scsi/lpfc/lpfc_init.c b/drivers/scsi/lpfc/lpfc_init.c
> index 64717c1..c38bc0b 100644
> --- a/drivers/scsi/lpfc/lpfc_init.c
> +++ b/drivers/scsi/lpfc/lpfc_init.c
> @@ -3108,7 +3108,7 @@ lpfc_scsi_free(struct lpfc_hba *phba)
>  	list_for_each_entry_safe(sb, sb_next, &phba->lpfc_scsi_buf_list_put,
>  				 list) {
>  		list_del(&sb->list);
> -		pci_pool_free(phba->lpfc_scsi_dma_buf_pool, sb->data,
> +		dma_pool_free(phba->lpfc_scsi_dma_buf_pool, sb->data,
>  			      sb->dma_handle);
>  		kfree(sb);
>  		phba->total_scsi_bufs--;
> @@ -3119,7 +3119,7 @@ lpfc_scsi_free(struct lpfc_hba *phba)
>  	list_for_each_entry_safe(sb, sb_next, &phba->lpfc_scsi_buf_list_get,
>  				 list) {
>  		list_del(&sb->list);
> -		pci_pool_free(phba->lpfc_scsi_dma_buf_pool, sb->data,
> +		dma_pool_free(phba->lpfc_scsi_dma_buf_pool, sb->data,
>  			      sb->dma_handle);
>  		kfree(sb);
>  		phba->total_scsi_bufs--;
> @@ -3283,7 +3283,7 @@ lpfc_sli4_xri_sgl_update(struct lpfc_hba *phba)
>  			list_remove_head(&scsi_sgl_list, psb,
>  					 struct lpfc_scsi_buf, list);
>  			if (psb) {
> -				pci_pool_free(phba->lpfc_scsi_dma_buf_pool,
> +				dma_pool_free(phba->lpfc_scsi_dma_buf_pool,
>  					      psb->data, psb->dma_handle);
>  				kfree(psb);
>  			}
> diff --git a/drivers/scsi/lpfc/lpfc_mem.c b/drivers/scsi/lpfc/lpfc_mem.c
> index 3fa6533..c87f64c 100644
> --- a/drivers/scsi/lpfc/lpfc_mem.c
> +++ b/drivers/scsi/lpfc/lpfc_mem.c
> @@ -91,22 +91,22 @@ lpfc_mem_alloc(struct lpfc_hba *phba, int align)
>  			i = SLI4_PAGE_SIZE;
>  
>  		phba->lpfc_scsi_dma_buf_pool =
> -			pci_pool_create("lpfc_scsi_dma_buf_pool",
> -				phba->pcidev,
> +			dma_pool_create("lpfc_scsi_dma_buf_pool",
> +				&phba->pcidev->dev,
>  				phba->cfg_sg_dma_buf_size,
>  				i,
>  				0);
>  	} else {
>  		phba->lpfc_scsi_dma_buf_pool =
> -			pci_pool_create("lpfc_scsi_dma_buf_pool",
> -				phba->pcidev, phba->cfg_sg_dma_buf_size,
> +			dma_pool_create("lpfc_scsi_dma_buf_pool",
> +				&phba->pcidev->dev, phba->cfg_sg_dma_buf_size,
>  				align, 0);
>  	}
>  
>  	if (!phba->lpfc_scsi_dma_buf_pool)
>  		goto fail;
>  
> -	phba->lpfc_mbuf_pool = pci_pool_create("lpfc_mbuf_pool", phba->pcidev,
> +	phba->lpfc_mbuf_pool = dma_pool_create("lpfc_mbuf_pool", &phba->pcidev->dev,
Introduces line over 80 characters warning. Please fix and resubmit.

>  							LPFC_BPL_SIZE,
>  							align, 0);
>  	if (!phba->lpfc_mbuf_pool)
> @@ -120,7 +120,7 @@ lpfc_mem_alloc(struct lpfc_hba *phba, int align)
>  	pool->max_count = 0;
>  	pool->current_count = 0;
>  	for ( i = 0; i < LPFC_MBUF_POOL_SIZE; i++) {
> -		pool->elements[i].virt = pci_pool_alloc(phba->lpfc_mbuf_pool,
> +		pool->elements[i].virt = dma_pool_alloc(phba->lpfc_mbuf_pool,
>  				       GFP_KERNEL, &pool->elements[i].phys);
>  		if (!pool->elements[i].virt)
>  			goto fail_free_mbuf_pool;
> @@ -144,21 +144,21 @@ lpfc_mem_alloc(struct lpfc_hba *phba, int align)
>  						sizeof(struct lpfc_node_rrq));
>  		if (!phba->rrq_pool)
>  			goto fail_free_nlp_mem_pool;
> -		phba->lpfc_hrb_pool = pci_pool_create("lpfc_hrb_pool",
> -					      phba->pcidev,
> +		phba->lpfc_hrb_pool = dma_pool_create("lpfc_hrb_pool",
> +					      &phba->pcidev->dev,
>  					      LPFC_HDR_BUF_SIZE, align, 0);
>  		if (!phba->lpfc_hrb_pool)
>  			goto fail_free_rrq_mem_pool;
>  
> -		phba->lpfc_drb_pool = pci_pool_create("lpfc_drb_pool",
> -					      phba->pcidev,
> +		phba->lpfc_drb_pool = dma_pool_create("lpfc_drb_pool",
> +					      &phba->pcidev->dev,
>  					      LPFC_DATA_BUF_SIZE, align, 0);
>  		if (!phba->lpfc_drb_pool)
>  			goto fail_free_hrb_pool;
>  		phba->lpfc_hbq_pool = NULL;
>  	} else {
> -		phba->lpfc_hbq_pool = pci_pool_create("lpfc_hbq_pool",
> -			phba->pcidev, LPFC_BPL_SIZE, align, 0);
> +		phba->lpfc_hbq_pool = dma_pool_create("lpfc_hbq_pool",
> +			&phba->pcidev->dev, LPFC_BPL_SIZE, align, 0);
>  		if (!phba->lpfc_hbq_pool)
>  			goto fail_free_nlp_mem_pool;
>  		phba->lpfc_hrb_pool = NULL;
> @@ -177,7 +177,7 @@ lpfc_mem_alloc(struct lpfc_hba *phba, int align)
>  
>  	return 0;
>   fail_free_hrb_pool:
> -	pci_pool_destroy(phba->lpfc_hrb_pool);
> +	dma_pool_destroy(phba->lpfc_hrb_pool);
>  	phba->lpfc_hrb_pool = NULL;
>   fail_free_rrq_mem_pool:
>  	mempool_destroy(phba->rrq_pool);
> @@ -190,14 +190,14 @@ lpfc_mem_alloc(struct lpfc_hba *phba, int align)
>  	phba->mbox_mem_pool = NULL;
>   fail_free_mbuf_pool:
>  	while (i--)
> -		pci_pool_free(phba->lpfc_mbuf_pool, pool->elements[i].virt,
> +		dma_pool_free(phba->lpfc_mbuf_pool, pool->elements[i].virt,
>  						 pool->elements[i].phys);
>  	kfree(pool->elements);
>   fail_free_lpfc_mbuf_pool:
> -	pci_pool_destroy(phba->lpfc_mbuf_pool);
> +	dma_pool_destroy(phba->lpfc_mbuf_pool);
>  	phba->lpfc_mbuf_pool = NULL;
>   fail_free_dma_buf_pool:
> -	pci_pool_destroy(phba->lpfc_scsi_dma_buf_pool);
> +	dma_pool_destroy(phba->lpfc_scsi_dma_buf_pool);
>  	phba->lpfc_scsi_dma_buf_pool = NULL;
>   fail:
>  	return -ENOMEM;
> @@ -222,14 +222,14 @@ lpfc_mem_free(struct lpfc_hba *phba)
>  	/* Free HBQ pools */
>  	lpfc_sli_hbqbuf_free_all(phba);
>  	if (phba->lpfc_drb_pool)
dma_pool_destroy(NULL) is safe and this check is probably not required

> -		pci_pool_destroy(phba->lpfc_drb_pool);
> +		dma_pool_destroy(phba->lpfc_drb_pool);
>  	phba->lpfc_drb_pool = NULL;
>  	if (phba->lpfc_hrb_pool)
dma_pool_destroy(NULL) is safe and this check is probably not required

> -		pci_pool_destroy(phba->lpfc_hrb_pool);
> +		dma_pool_destroy(phba->lpfc_hrb_pool);
>  	phba->lpfc_hrb_pool = NULL;
>  
>  	if (phba->lpfc_hbq_pool)
dma_pool_destroy(NULL) is safe and this check is probably not required

> -		pci_pool_destroy(phba->lpfc_hbq_pool);
> +		dma_pool_destroy(phba->lpfc_hbq_pool);
>  	phba->lpfc_hbq_pool = NULL;
>  
>  	if (phba->rrq_pool)
> @@ -250,15 +250,15 @@ lpfc_mem_free(struct lpfc_hba *phba)
>  
>  	/* Free MBUF memory pool */
>  	for (i = 0; i < pool->current_count; i++)
> -		pci_pool_free(phba->lpfc_mbuf_pool, pool->elements[i].virt,
> +		dma_pool_free(phba->lpfc_mbuf_pool, pool->elements[i].virt,
>  			      pool->elements[i].phys);
>  	kfree(pool->elements);
>  
> -	pci_pool_destroy(phba->lpfc_mbuf_pool);
> +	dma_pool_destroy(phba->lpfc_mbuf_pool);
>  	phba->lpfc_mbuf_pool = NULL;
>  
>  	/* Free DMA buffer memory pool */
> -	pci_pool_destroy(phba->lpfc_scsi_dma_buf_pool);
> +	dma_pool_destroy(phba->lpfc_scsi_dma_buf_pool);
>  	phba->lpfc_scsi_dma_buf_pool = NULL;
>  
>  	/* Free Device Data memory pool */
> @@ -365,7 +365,7 @@ lpfc_mbuf_alloc(struct lpfc_hba *phba, int mem_flags, dma_addr_t *handle)
>  	unsigned long iflags;
>  	void *ret;
>  
> -	ret = pci_pool_alloc(phba->lpfc_mbuf_pool, GFP_KERNEL, handle);
> +	ret = dma_pool_alloc(phba->lpfc_mbuf_pool, GFP_KERNEL, handle);
>  
>  	spin_lock_irqsave(&phba->hbalock, iflags);
>  	if (!ret && (mem_flags & MEM_PRI) && pool->current_count) {
> @@ -401,7 +401,7 @@ __lpfc_mbuf_free(struct lpfc_hba * phba, void *virt, dma_addr_t dma)
>  		pool->elements[pool->current_count].phys = dma;
>  		pool->current_count++;
>  	} else {
> -		pci_pool_free(phba->lpfc_mbuf_pool, virt, dma);
> +		dma_pool_free(phba->lpfc_mbuf_pool, virt, dma);
>  	}
>  	return;
>  }
> @@ -452,7 +452,7 @@ lpfc_els_hbq_alloc(struct lpfc_hba *phba)
>  	if (!hbqbp)
>  		return NULL;
>  
> -	hbqbp->dbuf.virt = pci_pool_alloc(phba->lpfc_hbq_pool, GFP_KERNEL,
> +	hbqbp->dbuf.virt = dma_pool_alloc(phba->lpfc_hbq_pool, GFP_KERNEL,
>  					  &hbqbp->dbuf.phys);
>  	if (!hbqbp->dbuf.virt) {
>  		kfree(hbqbp);
> @@ -477,7 +477,7 @@ lpfc_els_hbq_alloc(struct lpfc_hba *phba)
>  void
>  lpfc_els_hbq_free(struct lpfc_hba *phba, struct hbq_dmabuf *hbqbp)
>  {
> -	pci_pool_free(phba->lpfc_hbq_pool, hbqbp->dbuf.virt, hbqbp->dbuf.phys);
> +	dma_pool_free(phba->lpfc_hbq_pool, hbqbp->dbuf.virt, hbqbp->dbuf.phys);
>  	kfree(hbqbp);
>  	return;
>  }
> @@ -504,16 +504,16 @@ lpfc_sli4_rb_alloc(struct lpfc_hba *phba)
>  	if (!dma_buf)
>  		return NULL;
>  
> -	dma_buf->hbuf.virt = pci_pool_alloc(phba->lpfc_hrb_pool, GFP_KERNEL,
> +	dma_buf->hbuf.virt = dma_pool_alloc(phba->lpfc_hrb_pool, GFP_KERNEL,
>  					    &dma_buf->hbuf.phys);
>  	if (!dma_buf->hbuf.virt) {
>  		kfree(dma_buf);
>  		return NULL;
>  	}
> -	dma_buf->dbuf.virt = pci_pool_alloc(phba->lpfc_drb_pool, GFP_KERNEL,
> +	dma_buf->dbuf.virt = dma_pool_alloc(phba->lpfc_drb_pool, GFP_KERNEL,
>  					    &dma_buf->dbuf.phys);
>  	if (!dma_buf->dbuf.virt) {
> -		pci_pool_free(phba->lpfc_hrb_pool, dma_buf->hbuf.virt,
> +		dma_pool_free(phba->lpfc_hrb_pool, dma_buf->hbuf.virt,
>  			      dma_buf->hbuf.phys);
>  		kfree(dma_buf);
>  		return NULL;
> @@ -537,8 +537,8 @@ lpfc_sli4_rb_alloc(struct lpfc_hba *phba)
>  void
>  lpfc_sli4_rb_free(struct lpfc_hba *phba, struct hbq_dmabuf *dmab)
>  {
> -	pci_pool_free(phba->lpfc_hrb_pool, dmab->hbuf.virt, dmab->hbuf.phys);
> -	pci_pool_free(phba->lpfc_drb_pool, dmab->dbuf.virt, dmab->dbuf.phys);
> +	dma_pool_free(phba->lpfc_hrb_pool, dmab->hbuf.virt, dmab->hbuf.phys);
> +	dma_pool_free(phba->lpfc_drb_pool, dmab->dbuf.virt, dmab->dbuf.phys);
>  	kfree(dmab);
>  	return;
>  }
> diff --git a/drivers/scsi/lpfc/lpfc_scsi.c b/drivers/scsi/lpfc/lpfc_scsi.c
> index 1180a22..31b14b7 100644
> --- a/drivers/scsi/lpfc/lpfc_scsi.c
> +++ b/drivers/scsi/lpfc/lpfc_scsi.c
> @@ -413,7 +413,7 @@ lpfc_new_scsi_buf_s3(struct lpfc_vport *vport, int num_to_alloc)
>  		 * struct fcp_cmnd, struct fcp_rsp and the number of bde's
>  		 * necessary to support the sg_tablesize.
>  		 */
> -		psb->data = pci_pool_zalloc(phba->lpfc_scsi_dma_buf_pool,
> +		psb->data = dma_pool_zalloc(phba->lpfc_scsi_dma_buf_pool,
>  					GFP_KERNEL, &psb->dma_handle);
>  		if (!psb->data) {
>  			kfree(psb);
> @@ -424,7 +424,7 @@ lpfc_new_scsi_buf_s3(struct lpfc_vport *vport, int num_to_alloc)
>  		/* Allocate iotag for psb->cur_iocbq. */
>  		iotag = lpfc_sli_next_iotag(phba, &psb->cur_iocbq);
>  		if (iotag == 0) {
> -			pci_pool_free(phba->lpfc_scsi_dma_buf_pool,
> +			dma_pool_free(phba->lpfc_scsi_dma_buf_pool,
>  					psb->data, psb->dma_handle);
>  			kfree(psb);
>  			break;
> @@ -819,7 +819,7 @@ lpfc_new_scsi_buf_s4(struct lpfc_vport *vport, int num_to_alloc)
>  		 * for the struct fcp_cmnd, struct fcp_rsp and the number
>  		 * of bde's necessary to support the sg_tablesize.
>  		 */
> -		psb->data = pci_pool_zalloc(phba->lpfc_scsi_dma_buf_pool,
> +		psb->data = dma_pool_zalloc(phba->lpfc_scsi_dma_buf_pool,
>  						GFP_KERNEL, &psb->dma_handle);
>  		if (!psb->data) {
>  			kfree(psb);
> @@ -832,7 +832,7 @@ lpfc_new_scsi_buf_s4(struct lpfc_vport *vport, int num_to_alloc)
>  		 */
>  		if (phba->cfg_enable_bg  && (((unsigned long)(psb->data) &
>  		    (unsigned long)(SLI4_PAGE_SIZE - 1)) != 0)) {
> -			pci_pool_free(phba->lpfc_scsi_dma_buf_pool,
> +			dma_pool_free(phba->lpfc_scsi_dma_buf_pool,
>  				      psb->data, psb->dma_handle);
>  			kfree(psb);
>  			break;
> @@ -841,7 +841,7 @@ lpfc_new_scsi_buf_s4(struct lpfc_vport *vport, int num_to_alloc)
>  
>  		lxri = lpfc_sli4_next_xritag(phba);
>  		if (lxri == NO_XRI) {
> -			pci_pool_free(phba->lpfc_scsi_dma_buf_pool,
> +			dma_pool_free(phba->lpfc_scsi_dma_buf_pool,
>  			      psb->data, psb->dma_handle);
>  			kfree(psb);
>  			break;
> @@ -850,7 +850,7 @@ lpfc_new_scsi_buf_s4(struct lpfc_vport *vport, int num_to_alloc)
>  		/* Allocate iotag for psb->cur_iocbq. */
>  		iotag = lpfc_sli_next_iotag(phba, &psb->cur_iocbq);
>  		if (iotag == 0) {
> -			pci_pool_free(phba->lpfc_scsi_dma_buf_pool,
> +			dma_pool_free(phba->lpfc_scsi_dma_buf_pool,
>  				psb->data, psb->dma_handle);
>  			kfree(psb);
>  			lpfc_printf_log(phba, KERN_ERR, LOG_FCP,
> -- 
> 2.9.3
> 
