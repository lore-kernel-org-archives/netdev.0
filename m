From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] bcm43xx: Check error returns in initialization routines
Date: Mon, 22 Jan 2007 19:11:20 +0100
Message-ID: <200701221911.20544.mb@bu3sch.de>
References: <45b043e3.NGzJyc7WBaqk9U0D%Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org,
	Bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:43787
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932148AbXAVSMv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jan 2007 13:12:51 -0500
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <45b043e3.NGzJyc7WBaqk9U0D%Larry.Finger@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 19 January 2007 05:06, Larry Finger wrote:
> A number of the calls in the initialization routines fail to check the returned value for
> errors. This patch adds the necessary checks and logs any errors found when appropriate.

ACK

> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> ---
> 
> To be applied to wireless-2.6.
> 
> 
> Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> ===================================================================
> --- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> +++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> @@ -2980,8 +2980,10 @@ static int bcm43xx_chipset_attach(struct
>  	err = bcm43xx_pctl_set_crystal(bcm, 1);
>  	if (err)
>  		goto out;
> -	bcm43xx_pci_read_config16(bcm, PCI_STATUS, &pci_status);
> -	bcm43xx_pci_write_config16(bcm, PCI_STATUS, pci_status & ~PCI_STATUS_SIG_TARGET_ABORT);
> +	err = bcm43xx_pci_read_config16(bcm, PCI_STATUS, &pci_status);
> +	if (err)
> +		goto out;
> +	err = bcm43xx_pci_write_config16(bcm, PCI_STATUS, pci_status & ~PCI_STATUS_SIG_TARGET_ABORT);
>  
>  out:
>  	return err;
> @@ -3793,12 +3795,18 @@ static int bcm43xx_attach_board(struct b
>  	}
>  	net_dev->base_addr = (unsigned long)bcm->mmio_addr;
>  
> -	bcm43xx_pci_read_config16(bcm, PCI_SUBSYSTEM_VENDOR_ID,
> +	err = bcm43xx_pci_read_config16(bcm, PCI_SUBSYSTEM_VENDOR_ID,
>  	                          &bcm->board_vendor);
> -	bcm43xx_pci_read_config16(bcm, PCI_SUBSYSTEM_ID,
> +	if (err)
> +		goto err_iounmap;
> +	err = bcm43xx_pci_read_config16(bcm, PCI_SUBSYSTEM_ID,
>  	                          &bcm->board_type);
> -	bcm43xx_pci_read_config16(bcm, PCI_REVISION_ID,
> +	if (err)
> +		goto err_iounmap;
> +	err = bcm43xx_pci_read_config16(bcm, PCI_REVISION_ID,
>  	                          &bcm->board_revision);
> +	if (err)
> +		goto err_iounmap;
>  
>  	err = bcm43xx_chipset_attach(bcm);
>  	if (err)
> @@ -3889,6 +3897,7 @@ err_pci_release:
>  	pci_release_regions(pci_dev);
>  err_pci_disable:
>  	pci_disable_device(pci_dev);
> +	printk(KERN_ERR PFX "Unable to attach board\n");
>  	goto out;
>  }
> 
> --- 
> 
> 

-- 
Greetings Michael.
