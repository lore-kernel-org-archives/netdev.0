From: Peter Senna Tschudin <peter.senna@collabora.com>
Subject: Re: [RFC 09/19] scsi: csiostor: Replace PCI pool old API
Date: Wed, 8 Feb 2017 19:29:20 +0100
Message-ID: <20170208182920.GI16878@collabora.com>
References: <20170208163457.28853-1-romain.perier@collabora.com>
 <20170208163457.28853-10-romain.perier@collabora.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([46.235.227.227]:34180 "EHLO
        bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751000AbdBHS3l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 13:29:41 -0500
Content-Disposition: inline
In-Reply-To: <20170208163457.28853-10-romain.perier@collabora.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 08, 2017 at 05:34:47PM +0100, Romain Perier wrote:
> The PCI pool API is deprecated. This commits replaces the PCI pool old
> API by the appropriated function with the DMA pool API.
> 
> Signed-off-by: Romain Perier <romain.perier@collabora.com>
> ---
>  drivers/scsi/csiostor/csio_hw.h   | 2 +-
>  drivers/scsi/csiostor/csio_init.c | 4 ++--
>  drivers/scsi/csiostor/csio_scsi.c | 6 +++---
>  3 files changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/scsi/csiostor/csio_hw.h b/drivers/scsi/csiostor/csio_hw.h
> index 029bef8..c35c7bf 100644
> --- a/drivers/scsi/csiostor/csio_hw.h
> +++ b/drivers/scsi/csiostor/csio_hw.h
> @@ -465,7 +465,7 @@ struct csio_hw {
>  	struct csio_pport	pport[CSIO_MAX_PPORTS];	/* Ports (XGMACs) */
>  	struct csio_hw_params	params;			/* Hw parameters */
>  
> -	struct pci_pool		*scsi_pci_pool;		/* PCI pool for SCSI */
> +	struct dma_pool		*scsi_pci_pool;		/* PCI pool for SCSI */
>  	mempool_t		*mb_mempool;		/* Mailbox memory pool*/
>  	mempool_t		*rnode_mempool;		/* rnode memory pool */
>  
> diff --git a/drivers/scsi/csiostor/csio_init.c b/drivers/scsi/csiostor/csio_init.c
> index dbe416f..6206a72 100644
> --- a/drivers/scsi/csiostor/csio_init.c
> +++ b/drivers/scsi/csiostor/csio_init.c
> @@ -485,7 +485,7 @@ csio_resource_alloc(struct csio_hw *hw)
>  	if (!hw->rnode_mempool)
>  		goto err_free_mb_mempool;
>  
> -	hw->scsi_pci_pool = pci_pool_create("csio_scsi_pci_pool", hw->pdev,
> +	hw->scsi_pci_pool = dma_pool_create("csio_scsi_pci_pool", &hw->pdev->dev,
Introduces line over 80 characters warning. Please fix and resubmit.
Other than that looks good. Tested by compiling it.

>  					    CSIO_SCSI_RSP_LEN, 8, 0);
>  	if (!hw->scsi_pci_pool)
>  		goto err_free_rn_pool;
> @@ -505,7 +505,7 @@ csio_resource_alloc(struct csio_hw *hw)
>  static void
>  csio_resource_free(struct csio_hw *hw)
>  {
> -	pci_pool_destroy(hw->scsi_pci_pool);
> +	dma_pool_destroy(hw->scsi_pci_pool);
>  	hw->scsi_pci_pool = NULL;
>  	mempool_destroy(hw->rnode_mempool);
>  	hw->rnode_mempool = NULL;
> diff --git a/drivers/scsi/csiostor/csio_scsi.c b/drivers/scsi/csiostor/csio_scsi.c
> index a1ff75f..49b36b0 100644
> --- a/drivers/scsi/csiostor/csio_scsi.c
> +++ b/drivers/scsi/csiostor/csio_scsi.c
> @@ -2445,7 +2445,7 @@ csio_scsim_init(struct csio_scsim *scm, struct csio_hw *hw)
>  
>  		/* Allocate Dma buffers for Response Payload */
>  		dma_buf = &ioreq->dma_buf;
> -		dma_buf->vaddr = pci_pool_alloc(hw->scsi_pci_pool, GFP_KERNEL,
> +		dma_buf->vaddr = dma_pool_alloc(hw->scsi_pci_pool, GFP_KERNEL,
>  						&dma_buf->paddr);
>  		if (!dma_buf->vaddr) {
>  			csio_err(hw,
> @@ -2485,7 +2485,7 @@ csio_scsim_init(struct csio_scsim *scm, struct csio_hw *hw)
>  		ioreq = (struct csio_ioreq *)tmp;
>  
>  		dma_buf = &ioreq->dma_buf;
> -		pci_pool_free(hw->scsi_pci_pool, dma_buf->vaddr,
> +		dma_pool_free(hw->scsi_pci_pool, dma_buf->vaddr,
>  			      dma_buf->paddr);
>  
>  		kfree(ioreq);
> @@ -2516,7 +2516,7 @@ csio_scsim_exit(struct csio_scsim *scm)
>  		ioreq = (struct csio_ioreq *)tmp;
>  
>  		dma_buf = &ioreq->dma_buf;
> -		pci_pool_free(scm->hw->scsi_pci_pool, dma_buf->vaddr,
> +		dma_pool_free(scm->hw->scsi_pci_pool, dma_buf->vaddr,
>  			      dma_buf->paddr);
>  
>  		kfree(ioreq);
> -- 
> 2.9.3
> 
