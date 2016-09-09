From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH] bnx2: Reset device during driver initialization
Date: Fri, 9 Sep 2016 16:22:25 +0800
Message-ID: <20160909082225.GE11356@x1.redhat.com>
References: <1473408667-7107-1-git-send-email-bhe@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sony.chacko@qlogic.com, Dept-HSGLinuxNICDev@qlogic.com,
        linux-kernel@vger.kernel.org, kexec@lists.infradead.org,
        netdev@vger.kernel.org, dyoung@redhat.com
To: joro@8bytes.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1473408667-7107-1-git-send-email-bhe@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Joreg,

Sorry, forget ccing to you.

Recently I tried to fix the kdump failure in amd iommu system again, and
now the latest code works, IO_PAGE_FAULT can't be seen any more. But on
several amd iommu system with bnx2 NIC, always IO_PAGE_FAULT will be
printed out. After investegating I found out bnx2 driver doesn't reset
hardware/reg like other pci device, it does the reset job in bnx2_open
which is the net device up stage. So with this patch the IO_PAGE_FAULT
is away too on the system with bnx2 NIC. I will 

However when I got a intel system with vt-d and bnx2 NIC, kdump works
well, and no any error message can be seen. From code it clearly shows
the domain assignment is done in __intel_map_single, at this time bnx2
driver hasn't reset device, the on-flight DMA should still exist. Do you
have any idea on this? Or I missed anything? I also deferred the
set_dte_entry calling to __map_single calling, the principal should be
similar.

Thanks
Baoquan

On 09/09/16 at 04:11pm, Baoquan He wrote:
> When system enters into kdump kernel because of kernel panic, it won't
> shutdown devices. On-flight DMA will continue transferring data until
> device driver initializes. All devices are supposed to reset during
> driver initialization. And this property is used to fix the kdump
> failure in system with intel iommu. Other systems with hardware iommu
> should be similar. Please check commit 091d42e ("iommu/vt-d: Copy
> translation tables from old kernel") and those commits around it.
> 
> But bnx2 driver doesn't reset device during driver initialization. The
> device resetting is deferred to net device up stage. This will cause
> hardware iommu handling failure on bnx2 device. And its resetting relies
> on firmware. So in this patch move the firmware requesting code to earlier
> bnx2_init_one(), then next call bnx2_reset_chip to reset device.
> 
> Signed-off-by: Baoquan He <bhe@redhat.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2.c | 11 +++++++----
>  1 file changed, 7 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
> index 8fc3f3c..d68a487 100644
> --- a/drivers/net/ethernet/broadcom/bnx2.c
> +++ b/drivers/net/ethernet/broadcom/bnx2.c
> @@ -6356,10 +6356,6 @@ bnx2_open(struct net_device *dev)
>  	struct bnx2 *bp = netdev_priv(dev);
>  	int rc;
>  
> -	rc = bnx2_request_firmware(bp);
> -	if (rc < 0)
> -		goto out;
> -
>  	netif_carrier_off(dev);
>  
>  	bnx2_disable_int(bp);
> @@ -8575,6 +8571,12 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  
>  	pci_set_drvdata(pdev, dev);
>  
> +	rc = bnx2_request_firmware(bp);
> +	if (rc < 0)
> +		goto error;
> +
> +
> +	bnx2_reset_chip(bp, BNX2_DRV_MSG_CODE_RESET);
>  	memcpy(dev->dev_addr, bp->mac_addr, ETH_ALEN);
>  
>  	dev->hw_features = NETIF_F_IP_CSUM | NETIF_F_SG |
> @@ -8607,6 +8609,7 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  	return 0;
>  
>  error:
> +	bnx2_release_firmware(bp);
>  	pci_iounmap(pdev, bp->regview);
>  	pci_release_regions(pdev);
>  	pci_disable_device(pdev);
> -- 
> 2.5.5
> 
