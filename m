From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: [PATCH] bnx2: Fix IRQ failures during kdump.
Date: Sat, 29 May 2010 00:45:12 -0600
Message-ID: <20100529064512.GA21336@lackof.org>
References: <1275103462-8527-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1275103462-8527-1-git-send-email-mchan@broadcom.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 28, 2010 at 08:24:22PM -0700, Michael Chan wrote:
> When switching from the crashed kernel to the kdump kernel without going
> through PCI reset, IRQs may not work if a different IRQ mode is used on
> the kdump kernel.  The original IRQ mode used in the crashed kernel may
> still be enabled and the new IRQ mode may not work.  For example, it
> will fail when going from MSI-X mode to MSI mode.
> 
> We fix this by disabling MSI/MSI-X and enabling INTX in bnx2_init_board().
> 
> pci_save_state() is also moved to the end of bnx2_init_board() after
> all config register fixups (including the new IRQ fixups) have been done.
> 
> Export pci_msi_off() from drivers/pci/pci.c for this purpose.
> 
> Update bnx2 version to 2.0.16.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> ---
>  drivers/net/bnx2.c |   17 ++++++++++++++---
>  drivers/pci/pci.c  |    1 +
>  2 files changed, 15 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> index 188e356..1b8ba14 100644
> --- a/drivers/net/bnx2.c
> +++ b/drivers/net/bnx2.c
> @@ -58,8 +58,8 @@
>  #include "bnx2_fw.h"
>  
>  #define DRV_MODULE_NAME		"bnx2"
> -#define DRV_MODULE_VERSION	"2.0.15"
> -#define DRV_MODULE_RELDATE	"May 4, 2010"
> +#define DRV_MODULE_VERSION	"2.0.16"
> +#define DRV_MODULE_RELDATE	"May 28, 2010"
>  #define FW_MIPS_FILE_06		"bnx2/bnx2-mips-06-5.0.0.j6.fw"
>  #define FW_RV2P_FILE_06		"bnx2/bnx2-rv2p-06-5.0.0.j3.fw"
>  #define FW_MIPS_FILE_09		"bnx2/bnx2-mips-09-5.0.0.j15.fw"
> @@ -7877,7 +7877,6 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
>  	}
>  
>  	pci_set_master(pdev);
> -	pci_save_state(pdev);
>  
>  	bp->pm_cap = pci_find_capability(pdev, PCI_CAP_ID_PM);
>  	if (bp->pm_cap == 0) {
> @@ -7953,6 +7952,16 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
>  			bp->flags |= BNX2_FLAG_MSI_CAP;
>  	}
>  
> +	/* When going from a crashed kernel to a kdump kernel without PCI
> +	 * reset, MSI/MSI-X may still be enabled.  We need to disable
> +	 * MSI/MSI-X and enable INTX because the kdump driver may operate
> +	 * the device in a different IRQ mode.
> +	 */
> +	if (bp->flags & (BNX2_FLAG_MSI_CAP | BNX2_FLAG_MSIX_CAP)) {
> +		pci_msi_off(pdev);
> +		pci_intx(pdev, 1);

Does the driver have to register a different Interrupt handler when
switching from MSI(-X) to IRQ interrupts?

(I'm thinking of IRQ interrupts might have DMA vs IRQ ordering dependency)

If that's true, then this can't be handled in the generic PCI layer (as
suggested by davem) unless the device driver could register multiple interrupt
handlers even if only one is active at a time.

thanks,
grant

> +	}
> +
>  	/* 5708 cannot support DMA addresses > 40-bit.  */
>  	if (CHIP_NUM(bp) == CHIP_NUM_5708)
>  		persist_dma_mask = dma_mask = DMA_BIT_MASK(40);
> @@ -8188,6 +8197,8 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
>  	bp->timer.data = (unsigned long) bp;
>  	bp->timer.function = bnx2_timer;
>  
> +	pci_save_state(pdev);
> +
>  	return 0;
>  
>  err_out_unmap:
> diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
> index 1df7c50..a46b49d 100644
> --- a/drivers/pci/pci.c
> +++ b/drivers/pci/pci.c
> @@ -2294,6 +2294,7 @@ void pci_msi_off(struct pci_dev *dev)
>  		pci_write_config_word(dev, pos + PCI_MSIX_FLAGS, control);
>  	}
>  }
> +EXPORT_SYMBOL(pci_msi_off);
>  
>  #ifndef HAVE_ARCH_PCI_SET_DMA_MAX_SEGMENT_SIZE
>  int pci_set_dma_max_seg_size(struct pci_dev *dev, unsigned int size)
> -- 
> 1.6.4.GIT
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-pci" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
