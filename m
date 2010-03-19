From: "Ira W. Snyder" <iws-lulEs6mt1IksTUYHLfqkUA@public.gmane.org>
Subject: Re: [PATCH 1/3] mfd: add support for Janz CMOD-IO PCI MODULbus
	Carrier Board
Date: Fri, 19 Mar 2010 11:22:09 -0700
Message-ID: <20100319182209.GD13672@ovro.caltech.edu>
References: <> <1268930324-29841-2-git-send-email-iws@ovro.caltech.edu>
	<20100319163849.GB30409@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100319163849.GB30409-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 19, 2010 at 05:38:51PM +0100, Samuel Ortiz wrote:
> Hi Ira,
> 
> Some comments below:
> 
> On Thu, Mar 18, 2010 at 09:38:42AM -0700, Ira W. Snyder wrote:
> > +/* Module Parameters */
> > +static unsigned int num_modules = CMODIO_MAX_MODULES;
> > +static unsigned char *modules[CMODIO_MAX_MODULES] = {
> > +	"janz-ican3",
> > +	"janz-ican3",
> > +	"",
> > +	"janz-ttl",
> > +};
> That's not very nice, but I honestly dont know how to make it less ugly...
> At least this should be all left blank by default, as Wolfgang hinted.
> 

Agreed, I've made the change in my tree.

> > +/*
> > + * Subdevice Support
> > + */
> Please use the mfd-core API for building and registering platform sub devices.
> The pieces of code below should shrink significantly.
> 

Using this framework, how is it possible to create  the devices that I
do down below. For each subdevice, I need three resources:

1) MODULbus registers -- PCI BAR3 + (0x200 * module_num)
2) PLX Control Registers -- PCI BAR4
3) IRQ

Specifically, the way IORESOURCE_MEM resources are copied seems wrong.
They start at the base address of only one resource and use the offsets
provided in the struct mfd_cell. See the if-statement at
drivers/mfd/mfd-core.c line 48.

I need two use two different parent resources. The mfd_add_devices()
function doesn't support this.

> > +static int cmodio_remove_subdev(struct device *dev, void *data)
> > +{
> > +	platform_device_unregister(to_platform_device(dev));
> > +	return 0;
> > +}
> > +
> > +static void cmodio_subdev_release(struct device *dev)
> > +{
> > +	kfree(to_platform_device(dev));
> > +}
> > +
> > +static struct platform_device *cmodio_create_subdev(struct cmodio_device *priv,
> > +						    char *name,
> > +						    unsigned int res_count,
> > +						    unsigned int pdata_size)
> > +{
> > +	struct platform_device *pdev;
> > +	size_t res_size;
> > +
> > +	res_size = sizeof(struct resource) * res_count;
> > +	pdev = kzalloc(sizeof(*pdev) + res_size + pdata_size, GFP_KERNEL);
> > +	if (!pdev)
> > +		return NULL;
> > +
> > +	pdev->dev.release = cmodio_subdev_release;
> > +	pdev->dev.parent = &priv->pdev->dev;
> > +	pdev->name = name;
> > +
> > +	if (res_count) {
> > +		pdev->resource = (struct resource *)(pdev + 1);
> > +		pdev->num_resources = res_count;
> > +	}
> > +
> > +	if (pdata_size)
> > +		pdev->dev.platform_data = (void *)(pdev + 1) + res_size;
> > +
> > +	return pdev;
> > +}
> > +
> > +/* Create a memory resource for a subdevice */
> > +static void cmodio_create_mem(struct resource *parent, struct resource *res,
> > +			      resource_size_t offset, resource_size_t size)
> > +{
> > +	res->flags = IORESOURCE_MEM;
> > +	res->parent = parent;
> > +	res->start = parent->start + offset;
> > +	res->end = parent->start + offset + size - 1;
> > +}
> > +
> > +/* Create an IRQ resource for a subdevice */
> > +static void cmodio_create_irq(struct resource *res, unsigned int irq)
> > +{
> > +	res->flags = IORESOURCE_IRQ;
> > +	res->parent = NULL;
> > +	res->start = irq;
> > +	res->end = irq;
> > +}
> > +
> > +static int __devinit cmodio_probe_subdevice(struct cmodio_device *priv,
> > +					    char *name, unsigned int modno)
> > +{
> > +	struct janz_platform_data *pdata;
> > +	struct platform_device *pdev;
> > +	resource_size_t offset, size;
> > +	struct pci_dev *pci;
> > +	int ret;
> > +
> > +	pci = priv->pdev;
> > +	pdev = cmodio_create_subdev(priv, name, 3, sizeof(*pdata));
> > +	if (!pdev) {
> > +		dev_err(&pci->dev, "MODULbus slot %d alloc failed\n", modno);
> > +		ret = -ENOMEM;
> > +		goto out_return;
> > +	}
> > +
> > +	pdata = pdev->dev.platform_data;
> > +	pdata->modno = modno;
> > +	pdev->id = priv->subdev_id++;
> > +
> > +	/* MODULbus registers -- PCI BAR3 is big-endian MODULbus access */
> > +	offset = CMODIO_MODULBUS_SIZE * modno;
> > +	size = CMODIO_MODULBUS_SIZE;
> > +	cmodio_create_mem(&pci->resource[3], &pdev->resource[0], offset, size);
> > +
> > +	/* PLX Control Registers -- PCI BAR4 is interrupt and other registers */
> > +	offset = 0;
> > +	size = resource_size(&pci->resource[4]);
> > +	cmodio_create_mem(&pci->resource[4], &pdev->resource[1], offset, size);
> > +
> > +	/* IRQ */
> > +	cmodio_create_irq(&pdev->resource[2], pci->irq);
> > +
> > +	/* Register the device */
> > +	ret = platform_device_register(pdev);
> > +	if (ret) {
> > +		dev_err(&pci->dev, "MODULbus slot %d register failed\n", modno);
> > +		goto out_free;
> > +	}
> > +
> > +	return 0;
> > +
> > +out_free:
> > +	cmodio_subdev_release(&pdev->dev);
> > +out_return:
> > +	return ret;
> > +}
> > +
> > +/* Probe each submodule using kernel parameters */
> > +static int __devinit cmodio_probe_submodules(struct cmodio_device *priv)
> > +{
> > +	char *name;
> > +	int i;
> > +
> > +	for (i = 0; i < num_modules; i++) {
> > +		name = modules[i];
> > +		if (!strcmp(name, ""))
> > +			continue;
> > +
> > +		dev_dbg(&priv->pdev->dev, "MODULbus %d: name %s\n", i, name);
> > +		cmodio_probe_subdevice(priv, name, i);
> > +	}
> > +
> > +	return 0;
> > +}
> 
> 
> > +/*
> > + * PCI Driver
> > + */
> > +
> > +static int __devinit cmodio_pci_probe(struct pci_dev *dev,
> > +				      const struct pci_device_id *id)
> > +{
> > +	struct cmodio_device *priv;
> > +	int ret;
> > +
> > +	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
> > +	if (!priv) {
> > +		dev_err(&dev->dev, "unable to allocate private data\n");
> > +		ret = -ENOMEM;
> > +		goto out_return;
> > +	}
> > +
> > +	pci_set_drvdata(dev, priv);
> > +	priv->pdev = dev;
> > +
> > +	/* Hardware Initialization */
> > +	ret = pci_enable_device(dev);
> > +	if (ret) {
> > +		dev_err(&dev->dev, "unable to enable device\n");
> > +		goto out_free_priv;
> > +	}
> > +
> > +	pci_set_master(dev);
> > +	ret = pci_request_regions(dev, DRV_NAME);
> > +	if (ret) {
> > +		dev_err(&dev->dev, "unable to request regions\n");
> > +		goto out_pci_disable_device;
> > +	}
> > +
> > +	/* Onboard configuration registers */
> > +	priv->ctrl = pci_ioremap_bar(dev, 4);
> Why 4 ?
> 
> 

Because that is how the device works ;) There is a comment up above that
describes them as the "PLX control registers". Are you suggesting that I
add a comment here too?

I think lots of other PCI devices just use hard-coded numbers here.
They're device specific. You won't be able to program for the device at
all if you don't know the meaning of each PCI BAR.

> > +#define PCI_VENDOR_ID_JANZ		0x13c3
> That probably belongs to pci_ids.h
> 

Should I add a patch to the series for this?

Thanks,
Ira
