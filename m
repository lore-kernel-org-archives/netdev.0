From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: [PATCH 3/3] pci: gt96100eth avoid pci_find_device
Date: Mon, 05 Jun 2006 22:56:04 +0159
Message-ID: <44849A7B.10307@gmail.com>
References: <448491ab.7fb59b32.690f.01c1SMTPIN_ADDED@mx.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Cc: Greg KH <gregkh@suse.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-pci@atrey.karlin.mff.cuni.cz, jgarzik@pobox.com,
	netdev@vger.kernel.org, stevel@mvista.com, source@mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:25014 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1750701AbWFEU40 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jun 2006 16:56:26 -0400
Received: by nf-out-0910.google.com with SMTP id c31so1865936nfb
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2006 13:56:25 -0700 (PDT)
To: Jiri Slaby <jirislaby@gmail.com>
In-Reply-To: <448491ab.7fb59b32.690f.01c1SMTPIN_ADDED@mx.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri Slaby napsal(a):
> gt96100eth avoid pci_find_device
> 
> Change pci_find_device to safer pci_get_device with support for more
> bridges.
> 
> Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
> 
> ---
> commit fd863b81ac491faf783ff7f2dcf6032177c5ab7f
> tree d7eb59f897505230023754f19ad7227eec39e676
> parent 4b73c16f5411d97360d5f26f292ffddeb670ff75
> author Jiri Slaby <ku@bellona.localdomain> Mon, 05 Jun 2006 22:01:20 +0159
> committer Jiri Slaby <ku@bellona.localdomain> Mon, 05 Jun 2006 22:01:20 +0159
> 
>  drivers/net/gt96100eth.c |   23 ++++++++++++++++++-----
>  1 files changed, 18 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/gt96100eth.c b/drivers/net/gt96100eth.c
> index 2d24354..3066c86 100644
> --- a/drivers/net/gt96100eth.c
> +++ b/drivers/net/gt96100eth.c
> @@ -600,6 +600,11 @@ disable_ether_irq(struct net_device *dev
>  	GT96100ETH_WRITE(gp, GT96100_ETH_INT_MASK, 0);
>  }
>  
> +static struct pci_device_id gt96100_ids[] = {
> +	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, PCI_DEVICE_ID_MARVELL_GT96100) },
> +	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, PCI_DEVICE_ID_MARVELL_GT96100A) },
> +	{ 0 }
> +};
>  
>  /*
>   * Init GT96100 ethernet controller driver
> @@ -607,16 +612,20 @@ disable_ether_irq(struct net_device *dev
>  static int gt96100_init_module(void)
>  {
>  	struct pci_dev *pci;
> +	struct pci_device_id *id;
>  	int i, retval=0;
>  	u32 cpuConfig;
>  
>  	/*
>  	 * Stupid probe because this really isn't a PCI device
>  	 */
> -	if (!(pci = pci_find_device(PCI_VENDOR_ID_MARVELL,
> -	                            PCI_DEVICE_ID_MARVELL_GT96100, NULL)) &&
> -	    !(pci = pci_find_device(PCI_VENDOR_ID_MARVELL,
> -		                    PCI_DEVICE_ID_MARVELL_GT96100A, NULL))) {
> +	for (id = gt96100_ids; id->vendor; id++) {
> +		pci = pci_get_device(id->vendor, id->device, NULL);
> +		if (pci != NULL)
> +			break;
> +	}
I wonder if this is even better:
while ((pci = pci_get_device(PCI_ANY_ID, PCI_ANY_ID, pci)) != NULL)
    if (pci_match_id(gt96100_ids, pci) != NULL)
         break;
What do you think?
> +
> +	if (!id->vendor) {
>  		printk(KERN_ERR __FILE__ ": GT96100 not found!\n");
>  		return -ENODEV;
>  	}
> @@ -625,12 +634,16 @@ static int gt96100_init_module(void)
>  	if (cpuConfig & (1<<12)) {
>  		printk(KERN_ERR __FILE__
>  		       ": must be in Big Endian mode!\n");
> -		return -ENODEV;
> +		retval = -ENODEV;
> +		goto err_pput;
>  	}
>  
>  	for (i=0; i < NUM_INTERFACES; i++)
>  		retval |= gt96100_probe1(pci, i);
>  
> +err_pput:
> +	pci_dev_put(pci);
> +
>  	return retval;
>  }
>  
> 


-- 
Jiri Slaby         www.fi.muni.cz/~xslaby
\_.-^-._   jirislaby@gmail.com   _.-^-._/
B67499670407CE62ACC8 22A032CC55C339D47A7E
