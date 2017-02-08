From: Peter Senna Tschudin <peter.senna@collabora.com>
Subject: Re: [RFC 18/19] PCI: Remove PCI pool macro functions
Date: Wed, 8 Feb 2017 19:49:45 +0100
Message-ID: <20170208184945.GR16878@collabora.com>
References: <20170208163457.28853-1-romain.perier@collabora.com>
 <20170208163457.28853-19-romain.perier@collabora.com>
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
In-Reply-To: <20170208163457.28853-19-romain.perier@collabora.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 08, 2017 at 05:34:56PM +0100, Romain Perier wrote:
> Now that all the drivers use dma pool API, we can remove the macro
> functions for PCI pool.

Good news: make allyesconfig;make succeed after the changes until this
point, but:

$ grep -R pci_pool
...
drivers/usb/gadget/udc/pch_udc.c: *	-ENOMEM:	pci_pool_alloc
invocation fails
drivers/usb/host/oxu210hp-hcd.c:	 * pci_pool consistent memory
always uses segment zero.
drivers/usb/host/fotg210-hcd.c:	 * pci_pool consistent memory always
uses segment zero.
drivers/usb/host/ehci-hcd.c:	 * pci_pool consistent memory always
uses segment zero.
drivers/scsi/lpfc/lpfc_mem.c: * Allocates from generic pci_pool_alloc
function first and if that fails and
drivers/scsi/csiostor/csio_init.c:	hw->scsi_pci_pool =
dma_pool_create("csio_scsi_pci_pool", &hw->pdev->dev,
drivers/scsi/csiostor/csio_init.c:	if (!hw->scsi_pci_pool)
drivers/scsi/csiostor/csio_init.c:
dma_pool_destroy(hw->scsi_pci_pool);
drivers/scsi/csiostor/csio_init.c:	hw->scsi_pci_pool = NULL;
drivers/scsi/csiostor/csio_scsi.c:		dma_buf->vaddr =
dma_pool_alloc(hw->scsi_pci_pool, GFP_KERNEL,
drivers/scsi/csiostor/csio_scsi.c:
dma_pool_free(hw->scsi_pci_pool, dma_buf->vaddr,
drivers/scsi/csiostor/csio_scsi.c:
dma_pool_free(scm->hw->scsi_pci_pool, dma_buf->vaddr,
drivers/scsi/csiostor/csio_hw.h:	struct dma_pool
*scsi_pci_pool;		/* PCI pool for SCSI */

this can be updated or removed, needs to check:
scripts/coccinelle/api/alloc/pool_zalloc-simple.cocci

> 
> Signed-off-by: Romain Perier <romain.perier@collabora.com>
> ---
>  include/linux/pci.h | 9 ---------
>  1 file changed, 9 deletions(-)
> 
> diff --git a/include/linux/pci.h b/include/linux/pci.h
> index 11d15d4..c3a93e4 100644
> --- a/include/linux/pci.h
> +++ b/include/linux/pci.h
> @@ -1284,15 +1284,6 @@ int pci_set_vga_state(struct pci_dev *pdev, bool decode,
>  #include <linux/pci-dma.h>
>  #include <linux/dmapool.h>
>  
> -#define	pci_pool dma_pool
> -#define pci_pool_create(name, pdev, size, align, allocation) \
> -		dma_pool_create(name, &pdev->dev, size, align, allocation)
> -#define	pci_pool_destroy(pool) dma_pool_destroy(pool)
> -#define	pci_pool_alloc(pool, flags, handle) dma_pool_alloc(pool, flags, handle)
> -#define	pci_pool_zalloc(pool, flags, handle) \
> -		dma_pool_zalloc(pool, flags, handle)
> -#define	pci_pool_free(pool, vaddr, addr) dma_pool_free(pool, vaddr, addr)
> -
>  struct msix_entry {
>  	u32	vector;	/* kernel uses to write allocated vector */
>  	u16	entry;	/* driver uses to specify entry, OS writes */
> -- 
> 2.9.3
> 
