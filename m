From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: Re: [PATCH v7 1/1] Driver for Beckhoff CX5020 EtherCAT master module.
Date: Mon, 05 May 2014 16:32:49 +0200
Message-ID: <6140861.bbEgARIqZU@amdc1032>
References: <20140504200800.GH1156@newterm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7Bit
Cc: davem@davemloft.net, romieu@fr.zoreil.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Darek Marcinkiewicz <reksio@newterm.pl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <20140504200800.GH1156@newterm.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

On Sunday, May 04, 2014 10:08:00 PM Darek Marcinkiewicz wrote:
> 
> This driver adds support for EtherCAT master module located on CCAT
> FPGA found on Beckhoff CX series industrial PCs. The driver exposes
> EtherCAT master as an ethernet interface.
> 
> EtherCAT is a fieldbus protocol defined on top of ethernet and Beckhoff
> CX5020 PCs come with built-in EtherCAT master module located on a FPGA,
> which in turn is connected to a PCI bus.
> 
> Signed-off-by: Dariusz Marcinkiewicz <reksio@newterm.pl>
> ---
> 
> Changes from v6:
>   * added memory barriers to avoid race between timer handler and xmit routine 
>   * includes formatting/indeting changes from Francois Romieu
> 
> Changes from v5:
>   * removal of needless locking on tx path
>   * driver makes actual use of tx fifo
>   * driver uses descriptors' array instead of descriptor list
> 
> Changes from v4: 
>   * incorporates Francois Romieu comments
>   * fixes typo spotted by Jesper Brouer
> 
> Changes from v3:
>   * some clarificatoins around buffer allocations
> 
> Changes from v2:
>   * removed all checkpatch warnings
>   * driver makes use of device rx fifo
> 
> Changes from v1:
>   * added endianess annotation to descriptors' structures
>   * killed checkpath warnings about string literals being split into multiple
>     lines
> 
>  drivers/net/ethernet/Kconfig  |   11 +
>  drivers/net/ethernet/Makefile |    1 +
>  drivers/net/ethernet/ec_bhf.c |  705 +++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 717 insertions(+)
>  create mode 100644 drivers/net/ethernet/ec_bhf.c
> 
> diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
> index 39b26fe..a93ea15 100644
> --- a/drivers/net/ethernet/Kconfig
> +++ b/drivers/net/ethernet/Kconfig
> @@ -35,6 +35,17 @@ source "drivers/net/ethernet/calxeda/Kconfig"
>  source "drivers/net/ethernet/chelsio/Kconfig"
>  source "drivers/net/ethernet/cirrus/Kconfig"
>  source "drivers/net/ethernet/cisco/Kconfig"
> +
> +config CX_ECAT
> +	tristate "Beckhoff CX5020 EtherCAT master support"

There needs to be at least

	depends on PCI

here or the driver will break build on platforms that doesn't have PCI
(i.e. ARM EXYNOS).

> +	---help---
> +	  Driver for EtherCAT master module located on CCAT FPGA
> +	  that can be found on Beckhoff CX5020, and possibly other of CX
> +	  Beckhoff CX series industrial PCs.
> +
> +	  To compile this driver as a module, choose M here. The module
> +	  will be called ec_bhf.
> +
>  source "drivers/net/ethernet/davicom/Kconfig"
>  
>  config DNET
> diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
> index 545d0b3..35190e3 100644
> --- a/drivers/net/ethernet/Makefile
> +++ b/drivers/net/ethernet/Makefile
> @@ -21,6 +21,7 @@ obj-$(CONFIG_NET_CALXEDA_XGMAC) += calxeda/
>  obj-$(CONFIG_NET_VENDOR_CHELSIO) += chelsio/
>  obj-$(CONFIG_NET_VENDOR_CIRRUS) += cirrus/
>  obj-$(CONFIG_NET_VENDOR_CISCO) += cisco/
> +obj-$(CONFIG_CX_ECAT) += ec_bhf.o
>  obj-$(CONFIG_DM9000) += davicom/
>  obj-$(CONFIG_DNET) += dnet.o
>  obj-$(CONFIG_NET_VENDOR_DEC) += dec/
> diff --git a/drivers/net/ethernet/ec_bhf.c b/drivers/net/ethernet/ec_bhf.c
> new file mode 100644
> index 0000000..9763cd6
> --- /dev/null
> +++ b/drivers/net/ethernet/ec_bhf.c

[...]

> +static int ec_bhf_probe(struct pci_dev *dev, const struct pci_device_id *id)
> +{
> +	struct net_device *net_dev;
> +	struct ec_bhf_priv *priv;
> +	void * __iomem dma_io;
> +	void * __iomem io;
> +	int err = 0;
> +
> +	err = pci_enable_device(dev);
> +	if (err)
> +		return err;
> +
> +	pci_set_master(dev);
> +
> +	err = pci_set_dma_mask(dev, DMA_BIT_MASK(32));
> +	if (err) {
> +		dev_err(&dev->dev,
> +			"Required dma mask not supported, failed to initialize device\n");
> +		err = -EIO;
> +		goto err_disable_dev;
> +	}
> +
> +	err = pci_set_consistent_dma_mask(dev, DMA_BIT_MASK(32));
> +	if (err) {
> +		dev_err(&dev->dev,
> +			"Required dma mask not supported, failed to initialize device\n");
> +		goto err_disable_dev;
> +	}
> +
> +	err = pci_request_regions(dev, "ec_bhf");
> +	if (err) {
> +		dev_err(&dev->dev, "Failed to request pci memory regions\n");
> +		goto err_disable_dev;
> +	}
> +
> +	io = pci_iomap(dev, 0, 0);
> +	if (!io) {
> +		dev_err(&dev->dev, "Failed to map pci card memory bar 0");
> +		err = -EIO;
> +		goto err_release_regions;
> +	}
> +
> +	dma_io = pci_iomap(dev, 2, 0);
> +	if (!dma_io) {
> +		dev_err(&dev->dev, "Failed to map pci card memory bar 2");
> +		err = -EIO;
> +		goto err_unmap;
> +	}
> +
> +	net_dev = alloc_etherdev(sizeof(struct ec_bhf_priv));
> +	if (net_dev == 0) {
> +		err = -ENOMEM;
> +		goto err_unmap_dma_io;
> +	}
> +
> +	pci_set_drvdata(dev, net_dev);
> +	SET_NETDEV_DEV(net_dev, &dev->dev);
> +
> +	net_dev->features = 0;
> +	net_dev->flags |= IFF_NOARP;
> +
> +	net_dev->netdev_ops = &ec_bhf_netdev_ops;
> +
> +	priv = netdev_priv(net_dev);
> +	priv->net_dev = net_dev;
> +	priv->io = io;
> +	priv->dma_io = dma_io;
> +	priv->dev = dev;
> +
> +	err = ec_bhf_setup_offsets(priv);
> +	if (err < 0)
> +		goto err_free_net_dev;
> +
> +	memcpy_fromio(net_dev->dev_addr, priv->mii_io + MII_MAC_ADDR, 6);
> +
> +	dev_info(&dev->dev, "CX5020 Ethercat master address: %pM\n",
> +		 net_dev->dev_addr);
> +
> +	err = register_netdev(net_dev);
> +	if (err < 0)
> +		goto err_free_net_dev;
> +
> +	return 0;
> +
> +err_free_net_dev:
> +	free_netdev(net_dev);
> +err_unmap_dma_io:
> +	pci_iounmap(dev, dma_io);
> +err_unmap:
> +	pci_iounmap(dev, io);
> +err_release_regions:
> +	pci_release_regions(dev);
> +err_disable_dev:
> +	pci_clear_master(dev);
> +	pci_disable_device(dev);
> +
> +	return err;
> +}
> +
> +static void ec_bhf_remove(struct pci_dev *dev)
> +{
> +	struct net_device *net_dev = pci_get_drvdata(dev);
> +	struct ec_bhf_priv *priv = netdev_priv(net_dev);
> +
> +	unregister_netdev(net_dev);
> +	free_netdev(net_dev);
> +
> +	pci_iounmap(dev, priv->dma_io);
> +	pci_iounmap(dev, priv->io);
> +	pci_release_regions(dev);
> +	pci_clear_master(dev);
> +	pci_disable_device(dev);
> +}
> +
> +static struct pci_driver pci_driver = {
> +	.name		= "ec_bhf",
> +	.id_table	= ids,
> +	.probe		= ec_bhf_probe,
> +	.remove		= ec_bhf_remove,
> +};
> +
> +static int __init ec_bhf_init(void)
> +{
> +	return pci_register_driver(&pci_driver);
> +}
> +
> +static void __exit ec_bhf_exit(void)
> +{
> +	pci_unregister_driver(&pci_driver);
> +}
> +
> +module_init(ec_bhf_init);
> +module_exit(ec_bhf_exit);
> +
> +module_param(polling_frequency, long, S_IRUGO);
> +MODULE_PARM_DESC(polling_frequency, "Polling timer frequency in ns");
> +
> +MODULE_LICENSE("GPL");
> +MODULE_AUTHOR("Dariusz Marcinkiewicz <reksio@newterm.pl>");

Best regards,
--
Bartlomiej Zolnierkiewicz
Samsung R&D Institute Poland
Samsung Electronics
