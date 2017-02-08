From: Peter Senna Tschudin <peter.senna@collabora.com>
Subject: Re: [RFC 13/19] scsi: mvsas: Replace PCI pool old API
Date: Wed, 8 Feb 2017 19:42:00 +0100
Message-ID: <20170208184200.GM16878@collabora.com>
References: <20170208163457.28853-1-romain.perier@collabora.com>
 <20170208163457.28853-14-romain.perier@collabora.com>
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
In-Reply-To: <20170208163457.28853-14-romain.perier@collabora.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 08, 2017 at 05:34:51PM +0100, Romain Perier wrote:
> The PCI pool API is deprecated. This commits replaces the PCI pool old
> API by the appropriated function with the DMA pool API.
> 
> Signed-off-by: Romain Perier <romain.perier@collabora.com>
> ---
>  drivers/scsi/mvsas/mv_init.c | 4 ++--
>  drivers/scsi/mvsas/mv_sas.c  | 6 +++---
>  2 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/scsi/mvsas/mv_init.c b/drivers/scsi/mvsas/mv_init.c
> index 8280046..451ba93 100644
> --- a/drivers/scsi/mvsas/mv_init.c
> +++ b/drivers/scsi/mvsas/mv_init.c
> @@ -126,7 +126,7 @@ static void mvs_free(struct mvs_info *mvi)
>  		slot_nr = MVS_CHIP_SLOT_SZ;
>  
>  	if (mvi->dma_pool)
dma_pool_destroy(NULL) is safe and this check is probably not required

> -		pci_pool_destroy(mvi->dma_pool);
> +		dma_pool_destroy(mvi->dma_pool);
>  
>  	if (mvi->tx)
>  		dma_free_coherent(mvi->dev,
> @@ -296,7 +296,7 @@ static int mvs_alloc(struct mvs_info *mvi, struct Scsi_Host *shost)
>  		goto err_out;
>  
>  	sprintf(pool_name, "%s%d", "mvs_dma_pool", mvi->id);
> -	mvi->dma_pool = pci_pool_create(pool_name, mvi->pdev, MVS_SLOT_BUF_SZ, 16, 0);
> +	mvi->dma_pool = dma_pool_create(pool_name, &mvi->pdev->dev, MVS_SLOT_BUF_SZ, 16, 0);
line over 80.

>  	if (!mvi->dma_pool) {
>  			printk(KERN_DEBUG "failed to create dma pool %s.\n", pool_name);
>  			goto err_out;
> diff --git a/drivers/scsi/mvsas/mv_sas.c b/drivers/scsi/mvsas/mv_sas.c
> index c7cc803..ee81d10 100644
> --- a/drivers/scsi/mvsas/mv_sas.c
> +++ b/drivers/scsi/mvsas/mv_sas.c
> @@ -790,7 +790,7 @@ static int mvs_task_prep(struct sas_task *task, struct mvs_info *mvi, int is_tmf
>  	slot->n_elem = n_elem;
>  	slot->slot_tag = tag;
>  
> -	slot->buf = pci_pool_alloc(mvi->dma_pool, GFP_ATOMIC, &slot->buf_dma);
> +	slot->buf = dma_pool_alloc(mvi->dma_pool, GFP_ATOMIC, &slot->buf_dma);
>  	if (!slot->buf) {
>  		rc = -ENOMEM;
>  		goto err_out_tag;
> @@ -840,7 +840,7 @@ static int mvs_task_prep(struct sas_task *task, struct mvs_info *mvi, int is_tmf
>  	return rc;
>  
>  err_out_slot_buf:
> -	pci_pool_free(mvi->dma_pool, slot->buf, slot->buf_dma);
> +	dma_pool_free(mvi->dma_pool, slot->buf, slot->buf_dma);
>  err_out_tag:
>  	mvs_tag_free(mvi, tag);
>  err_out:
> @@ -918,7 +918,7 @@ static void mvs_slot_task_free(struct mvs_info *mvi, struct sas_task *task,
>  	}
>  
>  	if (slot->buf) {
> -		pci_pool_free(mvi->dma_pool, slot->buf, slot->buf_dma);
> +		dma_pool_free(mvi->dma_pool, slot->buf, slot->buf_dma);
>  		slot->buf = NULL;
>  	}
>  	list_del_init(&slot->entry);
> -- 
> 2.9.3
> 
