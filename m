From: Tejun Heo <teheo@suse.de>
Subject: Re: [patch 2/4] Update e100 driver to use devres.
Date: Thu, 16 Aug 2007 20:34:42 +0900
Message-ID: <46C43652.6030609@suse.de>
References: <20070815185949.GC7294@ifup.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Brandon Philips <bphilips@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jericho.provo.novell.com ([137.65.248.124]:1227 "EHLO
	jericho.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750747AbXHPLe6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2007 07:34:58 -0400
In-Reply-To: <20070815185949.GC7294@ifup.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brandon Philips wrote:
> @@ -2554,8 +2547,10 @@ static int __devinit e100_probe(struct p
>  	struct net_device *netdev;
>  	struct nic *nic;
>  	int err;
> +	void __iomem **iomap;
> +	int bar;
>  
> -	if(!(netdev = alloc_etherdev(sizeof(struct nic)))) {
> +	if (!(netdev = devm_alloc_etherdev(&pdev->dev, sizeof(struct nic)))) {
>  		if(((1 << debug) - 1) & NETIF_MSG_PROBE)
>  			printk(KERN_ERR PFX "Etherdev alloc failed, abort.\n");
>  		return -ENOMEM;
> @@ -2585,26 +2580,28 @@ static int __devinit e100_probe(struct p
>  	nic->msg_enable = (1 << debug) - 1;
>  	pci_set_drvdata(pdev, netdev);
>  
> -	if((err = pci_enable_device(pdev))) {
> +	if ((err = pcim_enable_device(pdev))) {
>  		DPRINTK(PROBE, ERR, "Cannot enable PCI device, aborting.\n");
> -		goto err_out_free_dev;
> +		return err;
>  	}
>  
>  	if(!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)) {
>  		DPRINTK(PROBE, ERR, "Cannot find proper PCI device "
>  			"base address, aborting.\n");
>  		err = -ENODEV;
> -		goto err_out_disable_pdev;
> +		return err;
>  	}
>  
> -	if((err = pci_request_regions(pdev, DRV_NAME))) {
> +	bar = use_io ? 1 : 0;
> +	if((err = pcim_iomap_regions(pdev, 1 << bar, DRV_NAME))) {
>  		DPRINTK(PROBE, ERR, "Cannot obtain PCI resources, aborting.\n");
> -		goto err_out_disable_pdev;
> +		return err;
>  	}
> +	iomap = pcim_iomap_table(pdev)[bar];

Type mismatch.  Didn't compiler warn about it?

>  
>  	if((err = pci_set_dma_mask(pdev, DMA_32BIT_MASK))) {
>  		DPRINTK(PROBE, ERR, "No usable DMA configuration, aborting.\n");
> -		goto err_out_free_res;
> +		return err;
>  	}
>  
>  	SET_MODULE_OWNER(netdev);
> @@ -2613,12 +2610,6 @@ static int __devinit e100_probe(struct p
>  	if (use_io)
>  		DPRINTK(PROBE, INFO, "using i/o access mode\n");
>  
> -	nic->csr = pci_iomap(pdev, (use_io ? 1 : 0), sizeof(struct csr));
> -	if(!nic->csr) {
> -		DPRINTK(PROBE, ERR, "Cannot map device registers, aborting.\n");
> -		err = -ENOMEM;
> -		goto err_out_free_res;
> -	}

nic->csr initialization seems missing.  Have you tested the patched code?

-- 
tejun
