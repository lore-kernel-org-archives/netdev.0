From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 4/4] enic: bug fix: don't set netdev->name too early
Date: Wed, 24 Sep 2008 20:51:29 -0400
Message-ID: <48DAE091.70507@pobox.com>
References: <20080924182154.22778.76605.stgit@palito_client100.nuovasystems.com> <20080924182353.22778.83553.stgit@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47064 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752777AbYIYAvf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2008 20:51:35 -0400
In-Reply-To: <20080924182353.22778.83553.stgit@palito_client100.nuovasystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Scott Feldman wrote:
> enic: bug fix: don't set netdev->name too early
> 
> Bug fix: don't set netdev->name early before netdev registration.  Setting
> netdev->name early with dev_alloc_name() would occasionally cause netdev
> registration to fail returning error that device was already registered.
> Since we're using netdev->name to name MSI-X vectors, we now need to 
> move the request_irq after netdev registartion, so move it to ->open.
> 
> Signed-off-by: Scott Feldman <scofeldm@cisco.com>
> ---
>  drivers/net/enic/enic.h      |    2 -
>  drivers/net/enic/enic_main.c |  121 ++++++++++++++++--------------------------
>  2 files changed, 47 insertions(+), 76 deletions(-)
> 
> diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
> index 9e0d484..7f677e8 100644
> --- a/drivers/net/enic/enic.h
> +++ b/drivers/net/enic/enic.h
> @@ -33,7 +33,7 @@
>  
>  #define DRV_NAME		"enic"
>  #define DRV_DESCRIPTION		"Cisco 10G Ethernet Driver"
> -#define DRV_VERSION		"0.0.1.18163.472"
> +#define DRV_VERSION		"0.0.1-18163.472-k1"
>  #define DRV_COPYRIGHT		"Copyright 2008 Cisco Systems, Inc"
>  #define PFX			DRV_NAME ": "
>  
> diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
> index 14e59a7..180e968 100644
> --- a/drivers/net/enic/enic_main.c
> +++ b/drivers/net/enic/enic_main.c
> @@ -1251,13 +1251,28 @@ static int enic_open(struct net_device *netdev)
>  	unsigned int i;
>  	int err;
>  
> +	err = enic_request_intr(enic);
> +	if (err) {
> +		printk(KERN_ERR PFX "%s: Unable to request irq.\n",
> +			netdev->name);
> +		return err;
> +	}
> +
> +	err = enic_notify_set(enic);
> +	if (err) {
> +		printk(KERN_ERR PFX
> +			"%s: Failed to alloc notify buffer, aborting.\n",
> +			netdev->name);
> +		goto err_out_free_intr;
> +	}
> +
>  	for (i = 0; i < enic->rq_count; i++) {
>  		err = vnic_rq_fill(&enic->rq[i], enic_rq_alloc_buf);
>  		if (err) {
>  			printk(KERN_ERR PFX
>  				"%s: Unable to alloc receive buffers.\n",
>  				netdev->name);
> -			return err;
> +			goto err_out_notify_unset;
>  		}
>  	}
>  
> @@ -1279,6 +1294,13 @@ static int enic_open(struct net_device *netdev)
>  	enic_notify_timer_start(enic);
>  
>  	return 0;
> +
> +err_out_notify_unset:
> +	vnic_dev_notify_unset(enic->vdev);
> +err_out_free_intr:
> +	enic_free_intr(enic);
> +
> +	return err;
>  }
>  
>  /* rtnl lock is held, process context */
> @@ -1308,6 +1330,9 @@ static int enic_stop(struct net_device *netdev)
>  			return err;
>  	}
>  
> +	vnic_dev_notify_unset(enic->vdev);
> +	enic_free_intr(enic);
> +
>  	(void)vnic_cq_service(&enic->cq[ENIC_CQ_RQ],
>  		-1, enic_rq_service_drop, NULL);
>  	(void)vnic_cq_service(&enic->cq[ENIC_CQ_WQ],
> @@ -1593,18 +1618,6 @@ static int __devinit enic_probe(struct pci_dev *pdev,
>  		return -ENOMEM;
>  	}
>  
> -	/* Set the netdev name early so intr vectors are properly
> -	 * named and any error msgs can include netdev->name
> -	 */
> -
> -	rtnl_lock();
> -	err = dev_alloc_name(netdev, netdev->name);
> -	rtnl_unlock();
> -	if (err < 0) {
> -		printk(KERN_ERR PFX "Unable to allocate netdev name.\n");
> -		goto err_out_free_netdev;
> -	}
> -
>  	pci_set_drvdata(pdev, netdev);
>  
>  	SET_NETDEV_DEV(netdev, &pdev->dev);
> @@ -1619,16 +1632,14 @@ static int __devinit enic_probe(struct pci_dev *pdev,
>  	err = pci_enable_device(pdev);
>  	if (err) {
>  		printk(KERN_ERR PFX
> -			"%s: Cannot enable PCI device, aborting.\n",
> -			netdev->name);
> +			"Cannot enable PCI device, aborting.\n");
>  		goto err_out_free_netdev;
>  	}
>  
>  	err = pci_request_regions(pdev, DRV_NAME);
>  	if (err) {
>  		printk(KERN_ERR PFX
> -			"%s: Cannot request PCI regions, aborting.\n",
> -			netdev->name);
> +			"Cannot request PCI regions, aborting.\n");
>  		goto err_out_disable_device;
>  	}
>  
> @@ -1644,25 +1655,22 @@ static int __devinit enic_probe(struct pci_dev *pdev,
>  		err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
>  		if (err) {
>  			printk(KERN_ERR PFX
> -				"%s: No usable DMA configuration, aborting.\n",
> -				netdev->name);
> +				"No usable DMA configuration, aborting.\n");
>  			goto err_out_release_regions;
>  		}
>  		err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
>  		if (err) {
>  			printk(KERN_ERR PFX
> -				"%s: Unable to obtain 32-bit DMA "
> -				"for consistent allocations, aborting.\n",
> -				netdev->name);
> +				"Unable to obtain 32-bit DMA "
> +				"for consistent allocations, aborting.\n");
>  			goto err_out_release_regions;
>  		}
>  	} else {
>  		err = pci_set_consistent_dma_mask(pdev, DMA_40BIT_MASK);
>  		if (err) {
>  			printk(KERN_ERR PFX
> -				"%s: Unable to obtain 40-bit DMA "
> -				"for consistent allocations, aborting.\n",
> -				netdev->name);
> +				"Unable to obtain 40-bit DMA "
> +				"for consistent allocations, aborting.\n");
>  			goto err_out_release_regions;
>  		}
>  		using_dac = 1;
> @@ -1673,8 +1681,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
>  
>  	if (!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)) {
>  		printk(KERN_ERR PFX
> -			"%s: BAR0 not memory-map'able, aborting.\n",
> -			netdev->name);
> +			"BAR0 not memory-map'able, aborting.\n");
>  		err = -ENODEV;
>  		goto err_out_release_regions;
>  	}
> @@ -1685,8 +1692,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
>  
>  	if (!enic->bar0.vaddr) {
>  		printk(KERN_ERR PFX
> -			"%s: Cannot memory-map BAR0 res hdr, aborting.\n",
> -			netdev->name);
> +			"Cannot memory-map BAR0 res hdr, aborting.\n");
>  		err = -ENODEV;
>  		goto err_out_release_regions;
>  	}
> @@ -1697,8 +1703,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
>  	enic->vdev = vnic_dev_register(NULL, enic, pdev, &enic->bar0);
>  	if (!enic->vdev) {
>  		printk(KERN_ERR PFX
> -			"%s: vNIC registration failed, aborting.\n",
> -			netdev->name);
> +			"vNIC registration failed, aborting.\n");
>  		err = -ENODEV;
>  		goto err_out_iounmap;
>  	}
> @@ -1709,8 +1714,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
>  	err = enic_dev_open(enic);
>  	if (err) {
>  		printk(KERN_ERR PFX
> -			"%s: vNIC dev open failed, aborting.\n",
> -			netdev->name);
> +			"vNIC dev open failed, aborting.\n");
>  		goto err_out_vnic_unregister;
>  	}
>  
> @@ -1727,8 +1731,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
>  	err = vnic_dev_init(enic->vdev, 0);
>  	if (err) {
>  		printk(KERN_ERR PFX
> -			"%s: vNIC dev init failed, aborting.\n",
> -			netdev->name);
> +			"vNIC dev init failed, aborting.\n");
>  		goto err_out_dev_close;
>  	}
>  
> @@ -1738,8 +1741,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
>  	err = enic_get_vnic_config(enic);
>  	if (err) {
>  		printk(KERN_ERR PFX
> -			"%s: Get vNIC configuration failed, aborting.\n",
> -			netdev->name);
> +			"Get vNIC configuration failed, aborting.\n");
>  		goto err_out_dev_close;
>  	}
>  
> @@ -1755,18 +1757,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
>  	err = enic_set_intr_mode(enic);
>  	if (err) {
>  		printk(KERN_ERR PFX
> -			"%s: Failed to set intr mode, aborting.\n",
> -			netdev->name);
> -		goto err_out_dev_close;
> -	}
> -
> -	/* Request interrupt vector(s)
> -	*/
> -
> -	err = enic_request_intr(enic);
> -	if (err) {
> -		printk(KERN_ERR PFX "%s: Unable to request irq.\n",
> -			netdev->name);
> +			"Failed to set intr mode, aborting.\n");
>  		goto err_out_dev_close;
>  	}
>  
> @@ -1776,8 +1767,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
>  	err = enic_alloc_vnic_resources(enic);
>  	if (err) {
>  		printk(KERN_ERR PFX
> -			"%s: Failed to alloc vNIC resources, aborting.\n",
> -			netdev->name);
> +			"Failed to alloc vNIC resources, aborting.\n");
>  		goto err_out_free_vnic_resources;
>  	}
>  
> @@ -1793,19 +1783,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
>  		ig_vlan_strip_en);
>  	if (err) {
>  		printk(KERN_ERR PFX
> -			"%s: Failed to config nic, aborting.\n",
> -			netdev->name);
> -		goto err_out_free_vnic_resources;
> -	}
> -
> -	/* Setup notification buffer area
> -	 */
> -
> -	err = enic_notify_set(enic);
> -	if (err) {
> -		printk(KERN_ERR PFX
> -			"%s: Failed to alloc notify buffer, aborting.\n",
> -			netdev->name);
> +			"Failed to config nic, aborting.\n");
>  		goto err_out_free_vnic_resources;
>  	}
>  
> @@ -1832,9 +1810,8 @@ static int __devinit enic_probe(struct pci_dev *pdev,
>  	err = enic_set_mac_addr(netdev, enic->mac_addr);
>  	if (err) {
>  		printk(KERN_ERR PFX
> -			"%s: Invalid MAC address, aborting.\n",
> -			netdev->name);
> -		goto err_out_notify_unset;
> +			"Invalid MAC address, aborting.\n");
> +		goto err_out_free_vnic_resources;
>  	}
>  
>  	netdev->open = enic_open;
> @@ -1888,18 +1865,14 @@ static int __devinit enic_probe(struct pci_dev *pdev,
>  	err = register_netdev(netdev);
>  	if (err) {
>  		printk(KERN_ERR PFX
> -			"%s: Cannot register net device, aborting.\n",
> -			netdev->name);
> -		goto err_out_notify_unset;
> +			"Cannot register net device, aborting.\n");
> +		goto err_out_free_vnic_resources;
>  	}
>  
>  	return 0;
>  
> -err_out_notify_unset:
> -	vnic_dev_notify_unset(enic->vdev);
>  err_out_free_vnic_resources:
>  	enic_free_vnic_resources(enic);
> -	enic_free_intr(enic);
>  err_out_dev_close:
>  	vnic_dev_close(enic->vdev);
>  err_out_vnic_unregister:
> @@ -1927,9 +1900,7 @@ static void __devexit enic_remove(struct pci_dev *pdev)
>  

applied 1-4


