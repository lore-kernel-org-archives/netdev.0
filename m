From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH][RFC take 2] Add support for the RDC R6040 Fast Ethernet
 controller
Date: Sat, 10 Nov 2007 14:33:32 -0500
Message-ID: <20071110143332.72b84119@shemminger-laptop>
References: <200710292251.43257.florian.fainelli@telecomint.eu>
	<200711101922.19004.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>
To: Florian Fainelli <florian.fainelli@telecomint.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:60212 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753153AbXKJTeR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Nov 2007 14:34:17 -0500
In-Reply-To: <200711101922.19004.florian.fainelli@telecomint.eu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> +static int __devinit r6040_init_one(struct pci_dev *pdev,
> +					 const struct pci_device_id *ent)
> +{
> +	struct net_device *dev;
> +	struct r6040_private *lp;
> +	void __iomem *ioaddr;
> +	int err, io_size = R6040_IO_SIZE;
> +	static int card_idx = -1;
> +	int bar = 0;
> +	long pioaddr;
> +
> +	printk(KERN_INFO "%s\n", version);
> +
> +	err = pci_enable_device(pdev);
> +	if (err)
> +		return err;
> +
> +	/* this should always be supported */
> +	if (pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {
> +		printk(KERN_ERR DRV_NAME "32-bit PCI DMA addresses"
> +				"not supported by the card\n");
> +		return -ENODEV;
> +	}
> +
> +	/* IO Size check */
> +	if (pci_resource_len(pdev, 0) < io_size) {
> +		printk(KERN_ERR "Insufficient PCI resources, aborting\n");
> +		return -EIO;
> +	}
> +
> +	pioaddr = pci_resource_start(pdev, 0);	/* IO map base address */
> +	pci_set_master(pdev);
> +
> +	dev = alloc_etherdev(sizeof(struct r6040_private));
> +	if (!dev) {
> +		printk(KERN_ERR "Failed to allocate etherdev\n");
> +		return -ENOMEM;
> +	}
> +	SET_NETDEV_DEV(dev, &pdev->dev);
> +	lp = netdev_priv(dev);
> +	lp->pdev = pdev;
> +
> +	if (pci_request_regions(pdev, DRV_NAME)) {
> +		printk(KERN_ERR DRV_NAME ": Failed to request PCI regions\n");
> +		err = -ENODEV;
> +		goto err_out_disable;
> +	}
> +
> +	ioaddr = pci_iomap(pdev, bar, io_size);
> +	if (!ioaddr) {
> +		printk(KERN_ERR "ioremap failed for device %s\n",
> +			pci_name(pdev));
> +		return -EIO;
> +	}
> +
> +	/* Init system & device */
> +	dev->base_addr = (unsigned long)ioaddr;
> +	lp->base = ioaddr;
> +	dev->irq = pdev->irq;
> +
> +	spin_lock_init(&lp->lock);
> +	pci_set_drvdata(pdev, dev);
> +
> +	/* Set MAC address */
> +	card_idx++;
> +
> +	/* Check if the MAC address is 0xFFFFFFFFFFFF or 0 */
> +	if (!is_valid_ether_addr(dev->dev_addr)) {
> +		u16 *adrp;
> +		adrp = (u16 *) dev->dev_addr;
> +		adrp[0] = ioread16(ioaddr + MID_0L);
> +		adrp[1] = ioread16(ioaddr + MID_0M);
> +		adrp[2] = ioread16(ioaddr + MID_0H);
> +	}


The is_valid_ether_addr is superflous.
 dev->dev_addr will always be zero (since it is part of just allocated structure).
