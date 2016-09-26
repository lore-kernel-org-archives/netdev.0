From: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v5 13/16] IB/pvrdma: Add the main driver module for PVRDMA
Date: Mon, 26 Sep 2016 10:27:40 +0300
Message-ID: <20160926072739.GB6352@yuval-lap.Home>
References: <cover.1474759181.git.aditr@vmware.com>
 <8db982c37a0a96b37df02826564474a216922f25.1474759181.git.aditr@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        pv-drivers-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jhansen-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org, asarwade-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org,
        georgezhang-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org, bryantan-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org
To: Adit Ranadive <aditr-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <8db982c37a0a96b37df02826564474a216922f25.1474759181.git.aditr-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 24, 2016 at 04:21:37PM -0700, Adit Ranadive wrote:
> +
> +	/* Currently, the driver only supports RoCE mode. */
> +	if (dev->dsr->caps.mode != PVRDMA_DEVICE_MODE_ROCE) {
> +		dev_err(&pdev->dev, "unsupported transport %d\n",
> +			dev->dsr->caps.mode);
> +		ret = -EINVAL;

This is some fatal error with the device, not that something wrong with the
function's argument.
Suggesting to replace with -EFAULT.

> +		goto err_free_cq_ring;
> +	}
> +
> +	/* Currently, the driver only supports RoCE V1. */
> +	if (!(dev->dsr->caps.gid_types & PVRDMA_GID_TYPE_FLAG_ROCE_V1)) {
> +		dev_err(&pdev->dev, "driver needs RoCE v1 support\n");
> +		ret = -EINVAL;

Ditto.

> +		goto err_free_cq_ring;
> +	}
> +
> +	/* Paired vmxnet3 will have same bus, slot. But func will be 0 */
> +	pdev_net = pci_get_slot(pdev->bus, PCI_DEVFN(PCI_SLOT(pdev->devfn), 0));
> +	if (!pdev_net) {
> +		dev_err(&pdev->dev, "failed to find paired net device\n");
> +		ret = -ENODEV;
> +		goto err_free_cq_ring;
> +	}
> +
> +	if (pdev_net->vendor != PCI_VENDOR_ID_VMWARE ||
> +	    pdev_net->device != PCI_DEVICE_ID_VMWARE_VMXNET3) {
> +		dev_err(&pdev->dev, "failed to find paired vmxnet3 device\n");
> +		pci_dev_put(pdev_net);
> +		ret = -ENODEV;
> +		goto err_free_cq_ring;
> +	}
> +
> +	dev->netdev = pci_get_drvdata(pdev_net);
> +	pci_dev_put(pdev_net);
> +	if (!dev->netdev) {
> +		dev_err(&pdev->dev, "failed to get vmxnet3 device\n");
> +		ret = -ENODEV;
> +		goto err_free_cq_ring;
> +	}
> +
> +	dev_info(&pdev->dev, "paired device to %s\n", dev->netdev->name);
> +
> +	/* Interrupt setup */
> +	ret = pvrdma_alloc_intrs(dev);
> +	if (ret) {
> +		dev_err(&pdev->dev, "failed to allocate interrupts\n");
> +		ret = -ENOMEM;
> +		goto err_netdevice;
> +	}
> +
> +	/* Allocate UAR table. */
> +	ret = pvrdma_uar_table_init(dev);
> +	if (ret) {
> +		dev_err(&pdev->dev, "failed to allocate UAR table\n");
> +		ret = -ENOMEM;
> +		goto err_free_intrs;
> +	}
> +
> +	/* Allocate GID table */
> +	dev->sgid_tbl = kcalloc(dev->dsr->caps.gid_tbl_len,
> +				sizeof(union ib_gid), GFP_KERNEL);
> +	if (!dev->sgid_tbl) {
> +		ret = -ENOMEM;
> +		goto err_free_uar_table;
> +	}
> +	dev_dbg(&pdev->dev, "gid table len %d\n", dev->dsr->caps.gid_tbl_len);
> +
> +	pvrdma_enable_intrs(dev);
> +
> +	/* Activate pvrdma device */
> +	pvrdma_write_reg(dev, PVRDMA_REG_CTL, PVRDMA_DEVICE_CTL_ACTIVATE);
> +
> +	/* Make sure the write is complete before reading status. */
> +	mb();
> +
> +	/* Check if device was successfully activated */
> +	ret = pvrdma_read_reg(dev, PVRDMA_REG_ERR);
> +	if (ret != 0) {
> +		dev_err(&pdev->dev, "failed to activate device\n");
> +		ret = -EINVAL;

Suggesting -EFAULT.

> +		goto err_disable_intr;
> +	}
> +
> +	/* Register IB device */
> +	ret = pvrdma_register_device(dev);
> +	if (ret) {
> +		dev_err(&pdev->dev, "failed to register IB device\n");
> +		goto err_disable_intr;
> +	}
> +
> +	dev->nb_netdev.notifier_call = pvrdma_netdevice_event;
> +	ret = register_netdevice_notifier(&dev->nb_netdev);
> +	if (ret) {
> +		dev_err(&pdev->dev, "failed to register netdevice events\n");
> +		goto err_unreg_ibdev;
> +	}
> +
> +	dev_info(&pdev->dev, "attached to device\n");
> +	return 0;
> +
> +err_unreg_ibdev:
> +	ib_unregister_device(&dev->ib_dev);
> +err_disable_intr:
> +	pvrdma_disable_intrs(dev);
> +	kfree(dev->sgid_tbl);
> +err_free_uar_table:
> +	pvrdma_uar_table_cleanup(dev);
> +err_free_intrs:
> +	pvrdma_free_irq(dev);
> +	pvrdma_disable_msi_all(dev);
> +err_netdevice:
> +	unregister_netdevice_notifier(&dev->nb_netdev);
> +err_free_cq_ring:
> +	pvrdma_page_dir_cleanup(dev, &dev->cq_pdir);
> +err_free_async_ring:
> +	pvrdma_page_dir_cleanup(dev, &dev->async_pdir);
> +err_free_slots:
> +	pvrdma_free_slots(dev);
> +err_free_dsr:
> +	dma_free_coherent(&pdev->dev, sizeof(*dev->dsr), dev->dsr,
> +			  dev->dsrbase);
> +err_uar_unmap:
> +	iounmap(dev->driver_uar.map);
> +err_unmap_regs:
> +	iounmap(dev->regs);
> +err_free_resource:
> +	pci_release_regions(pdev);
> +err_disable_pdev:
> +	pci_disable_device(pdev);
> +	pci_set_drvdata(pdev, NULL);
> +err_free_device:
> +	mutex_lock(&pvrdma_device_list_lock);
> +	list_del(&dev->device_link);
> +	mutex_unlock(&pvrdma_device_list_lock);
> +	ib_dealloc_device(&dev->ib_dev);
> +	return ret;
> +}
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
