From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 2/3] cnic: Don't take cnic_dev_lock in
 cnic_alloc_uio_rings()
Date: Sat, 31 May 2014 09:07:00 -0400
Message-ID: <20140531130700.GB27590@localhost.localdomain>
References: <1401491923-5480-1-git-send-email-mchan@broadcom.com>
 <1401491923-5480-2-git-send-email-mchan@broadcom.com>
 <1401491923-5480-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44231 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756383AbaEaNHN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 May 2014 09:07:13 -0400
Content-Disposition: inline
In-Reply-To: <1401491923-5480-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 30, 2014 at 04:18:42PM -0700, Michael Chan wrote:
> We are allocating memory with GFP_KERNEL under spinlock.  Since this is
> the only call manipulating the cnic_udev_list and it is always under
> rtnl_lock, cnic_dev_lock can be safely removed.
> 
 I don't think this is accurate.  cnic_alloc_uio_rings seems to protect the list
with cnic_dev_lock, but has several paths (those calling ->alloc_resc()), that
never hold the rtnl_lock.

Neil

> Signed-off-by: Michael Chan <mchan@broadcom.com>
> ---
>  drivers/net/ethernet/broadcom/cnic.c |    6 ------
>  1 files changed, 0 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
> index 7f40a2c..4ebab75 100644
> --- a/drivers/net/ethernet/broadcom/cnic.c
> +++ b/drivers/net/ethernet/broadcom/cnic.c
> @@ -1039,21 +1039,17 @@ static int cnic_alloc_uio_rings(struct cnic_dev *dev, int pages)
>  	struct cnic_local *cp = dev->cnic_priv;
>  	struct cnic_uio_dev *udev;
>  
> -	read_lock(&cnic_dev_lock);
>  	list_for_each_entry(udev, &cnic_udev_list, list) {
>  		if (udev->pdev == dev->pcidev) {
>  			udev->dev = dev;
>  			if (__cnic_alloc_uio_rings(udev, pages)) {
>  				udev->dev = NULL;
> -				read_unlock(&cnic_dev_lock);
>  				return -ENOMEM;
>  			}
>  			cp->udev = udev;
> -			read_unlock(&cnic_dev_lock);
>  			return 0;
>  		}
>  	}
> -	read_unlock(&cnic_dev_lock);
>  
>  	udev = kzalloc(sizeof(struct cnic_uio_dev), GFP_ATOMIC);
>  	if (!udev)
> @@ -1067,9 +1063,7 @@ static int cnic_alloc_uio_rings(struct cnic_dev *dev, int pages)
>  	if (__cnic_alloc_uio_rings(udev, pages))
>  		goto err_udev;
>  
> -	write_lock(&cnic_dev_lock);
>  	list_add(&udev->list, &cnic_udev_list);
> -	write_unlock(&cnic_dev_lock);
>  
>  	pci_dev_get(udev->pdev);
>  
> -- 
> 1.7.1
> 
> 
