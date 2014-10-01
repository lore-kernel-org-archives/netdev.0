From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH net-next] et131x: Add PCIe gigabit ethernet driver et131x
 to drivers/net
Date: Wed, 1 Oct 2014 14:45:00 +0200
Message-ID: <20141001124500.GH3279@distanz.ch>
References: <1412112586-2194-1-git-send-email-mark.einon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Mark Einon <mark.einon@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1412112586-2194-1-git-send-email-mark.einon@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2014-09-30 at 23:29:46 +0200, Mark Einon <mark.einon@gmail.com> wrote:
> This adds the ethernet driver for Agere et131x devices to
> drivers/net/ethernet.
> 
> The driver being added has been in the staging tree for some time, and will be
> removed from there in a seperate patch. This one merely disables the staging
> version to prevent two instances being built.
> 
> Signed-off-by: Mark Einon <mark.einon@gmail.com>

> ---
>  MAINTAINERS                         |   10 +-
>  drivers/net/ethernet/Kconfig        |    1 +
>  drivers/net/ethernet/Makefile       |    1 +
>  drivers/net/ethernet/agere/Kconfig  |   31 +
>  drivers/net/ethernet/agere/Makefile |    5 +
>  drivers/net/ethernet/agere/et131x.c | 4121 +++++++++++++++++++++++++++++++++++
>  drivers/net/ethernet/agere/et131x.h | 1433 ++++++++++++
>  drivers/staging/Kconfig             |    2 -
>  drivers/staging/Makefile            |    1 -
>  9 files changed, 5597 insertions(+), 8 deletions(-)
>  create mode 100644 drivers/net/ethernet/agere/Kconfig
>  create mode 100644 drivers/net/ethernet/agere/Makefile
>  create mode 100644 drivers/net/ethernet/agere/et131x.c
>  create mode 100644 drivers/net/ethernet/agere/et131x.h

[...]

> diff --git a/drivers/net/ethernet/agere/et131x.c b/drivers/net/ethernet/agere/et131x.c
> new file mode 100644
> index 0000000..384dc16
> --- /dev/null
> +++ b/drivers/net/ethernet/agere/et131x.c

[...]

> +static int et131x_pci_setup(struct pci_dev *pdev,
> +			    const struct pci_device_id *ent)
> +{
> +	struct net_device *netdev;
> +	struct et131x_adapter *adapter;
> +	int rc;
> +	int ii;
> +
> +	rc = pci_enable_device(pdev);
> +	if (rc < 0) {
> +		dev_err(&pdev->dev, "pci_enable_device() failed\n");
> +		goto out;

Nit: Just return rc here.

> +	}
> +
> +	/* Perform some basic PCI checks */
> +	if (!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)) {
> +		dev_err(&pdev->dev, "Can't find PCI device's base address\n");
> +		rc = -ENODEV;
> +		goto err_disable;
> +	}
> +
> +	rc = pci_request_regions(pdev, DRIVER_NAME);
> +	if (rc < 0) {
> +		dev_err(&pdev->dev, "Can't get PCI resources\n");
> +		goto err_disable;
> +	}
> +
> +	pci_set_master(pdev);
> +
> +	/* Check the DMA addressing support of this device */
> +	if (dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(64)) &&
> +	    dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(32))) {
> +		dev_err(&pdev->dev, "No usable DMA addressing method\n");
> +		rc = -EIO;
> +		goto err_release_res;
> +	}
> +
> +	netdev = alloc_etherdev(sizeof(struct et131x_adapter));
> +	if (!netdev) {
> +		dev_err(&pdev->dev, "Couldn't alloc netdev struct\n");
> +		rc = -ENOMEM;
> +		goto err_release_res;
> +	}
> +
> +	netdev->watchdog_timeo = ET131X_TX_TIMEOUT;
> +	netdev->netdev_ops     = &et131x_netdev_ops;
> +
> +	SET_NETDEV_DEV(netdev, &pdev->dev);
> +	netdev->ethtool_ops = &et131x_ethtool_ops;
> +
> +	adapter = et131x_adapter_init(netdev, pdev);
> +
> +	rc = et131x_pci_init(adapter, pdev);
> +	if (rc < 0)
> +		goto err_free_dev;
> +
> +	/* Map the bus-relative registers to system virtual memory */
> +	adapter->regs = pci_ioremap_bar(pdev, 0);
> +	if (!adapter->regs) {
> +		dev_err(&pdev->dev, "Cannot map device registers\n");
> +		rc = -ENOMEM;
> +		goto err_free_dev;
> +	}
> +
> +	/* If Phy COMA mode was enabled when we went down, disable it here. */
> +	writel(ET_PMCSR_INIT,  &adapter->regs->global.pm_csr);
> +
> +	et131x_soft_reset(adapter);
> +	et131x_disable_interrupts(adapter);
> +
> +	rc = et131x_adapter_memory_alloc(adapter);
> +	if (rc < 0) {
> +		dev_err(&pdev->dev, "Could not alloc adapter memory (DMA)\n");
> +		goto err_iounmap;
> +	}
> +
> +	et131x_init_send(adapter);
> +
> +	netif_napi_add(netdev, &adapter->napi, et131x_poll, 64);
> +
> +	ether_addr_copy(netdev->dev_addr, adapter->addr);
> +
> +	rc = -ENOMEM;
> +
> +	adapter->mii_bus = mdiobus_alloc();
> +	if (!adapter->mii_bus) {
> +		dev_err(&pdev->dev, "Alloc of mii_bus struct failed\n");
> +		goto err_mem_free;
> +	}
> +
> +	adapter->mii_bus->name = "et131x_eth_mii";
> +	snprintf(adapter->mii_bus->id, MII_BUS_ID_SIZE, "%x",
> +		 (adapter->pdev->bus->number << 8) | adapter->pdev->devfn);
> +	adapter->mii_bus->priv = netdev;
> +	adapter->mii_bus->read = et131x_mdio_read;
> +	adapter->mii_bus->write = et131x_mdio_write;
> +	adapter->mii_bus->irq = kmalloc_array(PHY_MAX_ADDR, sizeof(int),
> +					      GFP_KERNEL);
> +	if (!adapter->mii_bus->irq)
> +		goto err_mdio_free;
> +
> +	for (ii = 0; ii < PHY_MAX_ADDR; ii++)
> +		adapter->mii_bus->irq[ii] = PHY_POLL;
> +
> +	rc = mdiobus_register(adapter->mii_bus);
> +	if (rc < 0) {
> +		dev_err(&pdev->dev, "failed to register MII bus\n");
> +		goto err_mdio_free_irq;
> +	}
> +
> +	rc = et131x_mii_probe(netdev);
> +	if (rc < 0) {
> +		dev_err(&pdev->dev, "failed to probe MII bus\n");
> +		goto err_mdio_unregister;
> +	}
> +
> +	et131x_adapter_setup(adapter);
> +
> +	/* Init variable for counting how long we do not have link status */
> +	adapter->boot_coma = 0;
> +	et1310_disable_phy_coma(adapter);
> +
> +	/* We can enable interrupts now
> +	 *
> +	 *  NOTE - Because registration of interrupt handler is done in the
> +	 *         device's open(), defer enabling device interrupts to that
> +	 *         point
> +	 */
> +
> +	rc = register_netdev(netdev);
> +	if (rc < 0) {
> +		dev_err(&pdev->dev, "register_netdev() failed\n");
> +		goto err_phy_disconnect;
> +	}
> +
> +	/* Register the net_device struct with the PCI subsystem. Save a copy
> +	 * of the PCI config space for this device now that the device has
> +	 * been initialized, just in case it needs to be quickly restored.
> +	 */
> +	pci_set_drvdata(pdev, netdev);
> +out:
> +	return rc;
> +
> +err_phy_disconnect:
> +	phy_disconnect(adapter->phydev);
> +err_mdio_unregister:
> +	mdiobus_unregister(adapter->mii_bus);
> +err_mdio_free_irq:
> +	kfree(adapter->mii_bus->irq);
> +err_mdio_free:
> +	mdiobus_free(adapter->mii_bus);
> +err_mem_free:
> +	et131x_adapter_memory_free(adapter);
> +err_iounmap:
> +	iounmap(adapter->regs);
> +err_free_dev:
> +	pci_dev_put(pdev);
> +	free_netdev(netdev);
> +err_release_res:
> +	pci_release_regions(pdev);
> +err_disable:
> +	pci_disable_device(pdev);
> +	goto out;

Same here, directly return rc. Then you can also get rid of the `out' label.

> +}
> +
> +static const struct pci_device_id et131x_pci_table[] = {
> +	{ PCI_VDEVICE(ATT, ET131X_PCI_DEVICE_ID_GIG), 0UL},
> +	{ PCI_VDEVICE(ATT, ET131X_PCI_DEVICE_ID_FAST), 0UL},
> +	{ 0,}
> +};
> +MODULE_DEVICE_TABLE(pci, et131x_pci_table);
> +
> +static struct pci_driver et131x_driver = {
> +	.name		= DRIVER_NAME,
> +	.id_table	= et131x_pci_table,
> +	.probe		= et131x_pci_setup,
> +	.remove		= et131x_pci_remove,
> +	.driver.pm	= &et131x_pm_ops,
> +};
> +
> +module_pci_driver(et131x_driver);
