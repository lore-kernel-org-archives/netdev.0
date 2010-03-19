From: Samuel Ortiz <sameo@linux.intel.com>
Subject: Re: [PATCH 1/3] mfd: add support for Janz CMOD-IO PCI MODULbus
 Carrier Board
Date: Fri, 19 Mar 2010 17:38:51 +0100
Message-ID: <20100319163849.GB30409@sortiz.org>
References: <>
 <1268930324-29841-2-git-send-email-iws@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	socketcan-core@lists.berlios.de
To: "Ira W. Snyder" <iws@ovro.caltech.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1268930324-29841-2-git-send-email-iws@ovro.caltech.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Ira,

Some comments below:

On Thu, Mar 18, 2010 at 09:38:42AM -0700, Ira W. Snyder wrote:
> +/* Module Parameters */
> +static unsigned int num_modules = CMODIO_MAX_MODULES;
> +static unsigned char *modules[CMODIO_MAX_MODULES] = {
> +	"janz-ican3",
> +	"janz-ican3",
> +	"",
> +	"janz-ttl",
> +};
That's not very nice, but I honestly dont know how to make it less ugly...
At least this should be all left blank by default, as Wolfgang hinted.

> +/*
> + * Subdevice Support
> + */
Please use the mfd-core API for building and registering platform sub devices.
The pieces of code below should shrink significantly.

> +static int cmodio_remove_subdev(struct device *dev, void *data)
> +{
> +	platform_device_unregister(to_platform_device(dev));
> +	return 0;
> +}
> +
> +static void cmodio_subdev_release(struct device *dev)
> +{
> +	kfree(to_platform_device(dev));
> +}
> +
> +static struct platform_device *cmodio_create_subdev(struct cmodio_device *priv,
> +						    char *name,
> +						    unsigned int res_count,
> +						    unsigned int pdata_size)
> +{
> +	struct platform_device *pdev;
> +	size_t res_size;
> +
> +	res_size = sizeof(struct resource) * res_count;
> +	pdev = kzalloc(sizeof(*pdev) + res_size + pdata_size, GFP_KERNEL);
> +	if (!pdev)
> +		return NULL;
> +
> +	pdev->dev.release = cmodio_subdev_release;
> +	pdev->dev.parent = &priv->pdev->dev;
> +	pdev->name = name;
> +
> +	if (res_count) {
> +		pdev->resource = (struct resource *)(pdev + 1);
> +		pdev->num_resources = res_count;
> +	}
> +
> +	if (pdata_size)
> +		pdev->dev.platform_data = (void *)(pdev + 1) + res_size;
> +
> +	return pdev;
> +}
> +
> +/* Create a memory resource for a subdevice */
> +static void cmodio_create_mem(struct resource *parent, struct resource *res,
> +			      resource_size_t offset, resource_size_t size)
> +{
> +	res->flags = IORESOURCE_MEM;
> +	res->parent = parent;
> +	res->start = parent->start + offset;
> +	res->end = parent->start + offset + size - 1;
> +}
> +
> +/* Create an IRQ resource for a subdevice */
> +static void cmodio_create_irq(struct resource *res, unsigned int irq)
> +{
> +	res->flags = IORESOURCE_IRQ;
> +	res->parent = NULL;
> +	res->start = irq;
> +	res->end = irq;
> +}
> +
> +static int __devinit cmodio_probe_subdevice(struct cmodio_device *priv,
> +					    char *name, unsigned int modno)
> +{
> +	struct janz_platform_data *pdata;
> +	struct platform_device *pdev;
> +	resource_size_t offset, size;
> +	struct pci_dev *pci;
> +	int ret;
> +
> +	pci = priv->pdev;
> +	pdev = cmodio_create_subdev(priv, name, 3, sizeof(*pdata));
> +	if (!pdev) {
> +		dev_err(&pci->dev, "MODULbus slot %d alloc failed\n", modno);
> +		ret = -ENOMEM;
> +		goto out_return;
> +	}
> +
> +	pdata = pdev->dev.platform_data;
> +	pdata->modno = modno;
> +	pdev->id = priv->subdev_id++;
> +
> +	/* MODULbus registers -- PCI BAR3 is big-endian MODULbus access */
> +	offset = CMODIO_MODULBUS_SIZE * modno;
> +	size = CMODIO_MODULBUS_SIZE;
> +	cmodio_create_mem(&pci->resource[3], &pdev->resource[0], offset, size);
> +
> +	/* PLX Control Registers -- PCI BAR4 is interrupt and other registers */
> +	offset = 0;
> +	size = resource_size(&pci->resource[4]);
> +	cmodio_create_mem(&pci->resource[4], &pdev->resource[1], offset, size);
> +
> +	/* IRQ */
> +	cmodio_create_irq(&pdev->resource[2], pci->irq);
> +
> +	/* Register the device */
> +	ret = platform_device_register(pdev);
> +	if (ret) {
> +		dev_err(&pci->dev, "MODULbus slot %d register failed\n", modno);
> +		goto out_free;
> +	}
> +
> +	return 0;
> +
> +out_free:
> +	cmodio_subdev_release(&pdev->dev);
> +out_return:
> +	return ret;
> +}
> +
> +/* Probe each submodule using kernel parameters */
> +static int __devinit cmodio_probe_submodules(struct cmodio_device *priv)
> +{
> +	char *name;
> +	int i;
> +
> +	for (i = 0; i < num_modules; i++) {
> +		name = modules[i];
> +		if (!strcmp(name, ""))
> +			continue;
> +
> +		dev_dbg(&priv->pdev->dev, "MODULbus %d: name %s\n", i, name);
> +		cmodio_probe_subdevice(priv, name, i);
> +	}
> +
> +	return 0;
> +}


> +/*
> + * PCI Driver
> + */
> +
> +static int __devinit cmodio_pci_probe(struct pci_dev *dev,
> +				      const struct pci_device_id *id)
> +{
> +	struct cmodio_device *priv;
> +	int ret;
> +
> +	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
> +	if (!priv) {
> +		dev_err(&dev->dev, "unable to allocate private data\n");
> +		ret = -ENOMEM;
> +		goto out_return;
> +	}
> +
> +	pci_set_drvdata(dev, priv);
> +	priv->pdev = dev;
> +
> +	/* Hardware Initialization */
> +	ret = pci_enable_device(dev);
> +	if (ret) {
> +		dev_err(&dev->dev, "unable to enable device\n");
> +		goto out_free_priv;
> +	}
> +
> +	pci_set_master(dev);
> +	ret = pci_request_regions(dev, DRV_NAME);
> +	if (ret) {
> +		dev_err(&dev->dev, "unable to request regions\n");
> +		goto out_pci_disable_device;
> +	}
> +
> +	/* Onboard configuration registers */
> +	priv->ctrl = pci_ioremap_bar(dev, 4);
Why 4 ?


> +#define PCI_VENDOR_ID_JANZ		0x13c3
That probably belongs to pci_ids.h

Cheers,
Samuel.
-- 
Intel Open Source Technology Centre
http://oss.intel.com/
