From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 08/18] 3c59x: check return of pci_enable_device()
Date: Tue, 14 Aug 2007 01:33:26 -0400
Message-ID: <46C13EA6.9090301@garzik.org>
References: <200708102105.l7AL5Jje008968@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de
To: akpm@linux-foundation.org, mark@hindley.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56230 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S941549AbXHNFdb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 01:33:31 -0400
In-Reply-To: <200708102105.l7AL5Jje008968@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> From: Mark Hindley <mark@hindley.org.uk>
> 
> Check return of pci_enable_device in vortex_up().
> 
> Signed-off-by: Mark Hindley <mark@hindley.org.uk>
> Acked-by: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/3c59x.c |    8 ++++++--
>  1 files changed, 6 insertions(+), 2 deletions(-)
> 
> diff -puN drivers/net/3c59x.c~3c59x-check-return-of-pci_enable_device drivers/net/3c59x.c
> --- a/drivers/net/3c59x.c~3c59x-check-return-of-pci_enable_device
> +++ a/drivers/net/3c59x.c
> @@ -1490,13 +1490,17 @@ vortex_up(struct net_device *dev)
>  	struct vortex_private *vp = netdev_priv(dev);
>  	void __iomem *ioaddr = vp->ioaddr;
>  	unsigned int config;
> -	int i, mii_reg1, mii_reg5;
> +	int i, mii_reg1, mii_reg5, err;
>  
>  	if (VORTEX_PCI(vp)) {
>  		pci_set_power_state(VORTEX_PCI(vp), PCI_D0);	/* Go active */
>  		if (vp->pm_state_valid)
>  			pci_restore_state(VORTEX_PCI(vp));
> -		pci_enable_device(VORTEX_PCI(vp));
> +		err = pci_enable_device(VORTEX_PCI(vp));
> +		if (err) {
> +			printk(KERN_WARNING "%s: Could not enable device \n",
> +				dev->name);
> +		}

I would strongly prefer that vortex_up return a value, since all the 
important callers of this function can themselves return an error back 
to the system.

we can definitely return a meaningful return value here, if 
pci_enable_device() fails, and I would rather not apply a patch that 
fails to propagate a serious condition (pci_enable_device failure is 
indeed serious) when it is possible to do so

