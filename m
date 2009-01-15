From: Ira Snyder <iws@ovro.caltech.edu>
Subject: Re: [PATCH RFC v5] net: add PCINet driver
Date: Wed, 14 Jan 2009 16:12:51 -0800
Message-ID: <20090115001251.GA10745@ovro.caltech.edu>
References: <20090107195052.GA24981@ovro.caltech.edu> <200901131733.04341.arnd@arndb.de> <20090113164007.GA7434@ovro.caltech.edu> <200901131842.54688.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ovro.ovro.caltech.edu ([192.100.16.2]:47588 "EHLO
	ovro.ovro.caltech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757605AbZAOAMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 19:12:53 -0500
Content-Disposition: inline
In-Reply-To: <200901131842.54688.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 13, 2009 at 06:42:53PM +0100, Arnd Bergmann wrote:
> On Tuesday 13 January 2009, Ira Snyder wrote:
> > So do you program one channel of the DMA engine from the host side and
> > another channel from the guest side?
> 
> Yes.
> 
> > I tried to avoid having the host program the DMA controller at all.
> > Using the DMAEngine API on the guest did better than I could achieve by
> > programming the registers manually. I didn't use chaining or any of the
> > fancier features in my tests, though.
> 
> Our driver unfortunately does not use the DMA API, but it clearly
> should. What this means in your case is that you would need to port
> the freescale DMA engine driver to the host side, to operate on the
> PCI device. Not sure about how specifically this would work on fsl
> hardware, but it seems generally doable.
> 

The only problem with that is that you cannot route interrupts from the
DMA controller over PCI with the PowerPC core running. Which makes it
mostly useless for this case.

It /could/ work with polling mmio reads of the DMA controller register,
but as you said, mmio reads are slow, and that would be best avoided. I
don't think porting the driver is the right way to go.

If I haven't said it before, let me say it now: the DMA controller can
access all of the host's memory as well as all of the guest's memory.



I have been studying the virtio and virtio_ring systems, and I now have
a good idea about how to implement virtio-over-pci. I'm having trouble
coming up with a good scheme to use the DMA controller for all the data
transfers, though.

It is fairly easy to use the DMA controller in the virtio_net case,
since the virtio_net driver allocates all of the RX buffers ahead of
time. The guest can DMA directly from host TX into guest RX, then mark
the host TX buffers consumed. The same is true in reverse: the guest can
DMA directly from it's TX into the host RX, then mark the host RX
buffers consumed.

I'm not sure how to handle the bidirectional virtqueue case, though.
Such as the upcoming changes to virtio_net or virtio_blk. It seems like
you'd need to copy pages in this case, since you want to use the DMA to
transfer them.

I have come up with a nice scheme to maintain the buffer descriptor
tables in both host and guest memory without doing anything except mmio
writes. The scheme is almost identical to virtio_ring, with the
exception that both machines need a copy of vring->desc's flags and next
fields, to avoid the reads in virtio_rings detach_buf().

Maybe I'm overoptimistic in thinking that two instances of virtio_net
could talk to each other if the RX and TX queues were hooked up
accordingly in the find_vq() function. Has anyone actually tried this?



To anyone that is trying to learn virtio, I dummied up this mock driver
that registers a virtio_device for every MPC8349EMDS board in the
system. The virtqueues don't actually do anything, but they do print
messages so you know when they're used. It is almost certainly buggy and
horrible code. I'm only reproducing it here because it helped me get
started.

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/init.h>
#include <linux/pci.h>
#include <linux/virtio.h>
#include <linux/virtio_config.h>
#include <linux/virtio_net.h>

#include "pcinet_hw.h"

static const char driver_name[] = "vdev";

struct vpt_dev {
	struct virtio_device vdev;
	u8 status;

	void __iomem *immr;
	void __iomem *netregs;

	#define NUM_VQS 4
	struct virtqueue *vqs[NUM_VQS];

	unsigned int in;
	unsigned int out;
};

#define vdev_to_vpt(vdev) container_of(vdev, struct vpt_dev, vdev)

/*----------------------------------------------------------------------------*/
/* struct virtqueue_ops infrastructure                                        */
/*----------------------------------------------------------------------------*/

static int vpt_vq_add_buf(struct virtqueue *vq,
			   struct scatterlist sg[],
			   unsigned int out_num,
			   unsigned int in_num,
			   void *data)
{
	struct virtio_device *vdev = vq->vdev;
	struct vpt_dev *priv = vdev_to_vpt(vdev);

	pr_info("%s: vq=0x%p sg=0x%p, out=%u in=%d data=0x%p\n",
			__func__, vq, sg, out_num, in_num, data);

	priv->in += in_num;
	priv->out += out_num;

	if (priv->in > 10 || priv->out > 10) {
		pr_info("%s: vq=0x%p buffers filled\n", __func__, vq);
		return -ENOMEM;
	}

	return 0;
}

static void *vpt_vq_get_buf(struct virtqueue *vq, unsigned int *len)
{
	pr_info("%s: vq=0x%p\n", __func__, vq);
	return NULL;
}

static void vpt_vq_kick(struct virtqueue *vq)
{
	pr_info("%s: vq=0x%p\n", __func__, vq);
}

static void vpt_vq_disable_cb(struct virtqueue *vq)
{
	pr_info("%s: vq=0x%p\n", __func__, vq);
}

static bool vpt_vq_enable_cb(struct virtqueue *vq)
{
	pr_info("%s: vq=0x%p\n", __func__, vq);
	return true;
}

static struct virtqueue_ops vpt_vq_ops = {
	.add_buf	= vpt_vq_add_buf,
	.get_buf	= vpt_vq_get_buf,
	.kick		= vpt_vq_kick,
	.disable_cb	= vpt_vq_disable_cb,
	.enable_cb	= vpt_vq_enable_cb,
};

/*----------------------------------------------------------------------------*/
/* struct virtio_device infrastructure                                        */
/*----------------------------------------------------------------------------*/

static void vptc_get(struct virtio_device *vdev,
			    unsigned offset,
			    void *buf,
			    unsigned len)
{
	pr_info("%s: vdev=0x%p offset=%u buf=0x%p len=%u\n",
			__func__, vdev, offset, buf, len);
}

static void vptc_set(struct virtio_device *vdev,
			    unsigned offset,
			    const void *buf,
			    unsigned len)
{
	pr_info("%s: vdev=0x%p offset=%u buf=%p len=%u\n",
			__func__, vdev, offset, buf, len);
}

static u8 vptc_get_status(struct virtio_device *vdev)
{
	struct vpt_dev *priv = vdev_to_vpt(vdev);

	pr_info("%s: vdev=0x%p\n", __func__, vdev);

	return priv->status;
}

static void vptc_set_status(struct virtio_device *vdev, u8 status)
{
	struct vpt_dev *priv = vdev_to_vpt(vdev);

	pr_info("%s: vdev=0x%p status=0x%.2x\n", __func__, vdev, status);

	priv->status = status;
}

static void vptc_reset(struct virtio_device *vdev)
{
	struct vpt_dev *priv = vdev_to_vpt(vdev);

	pr_info("%s: vdev=0x%p\n", __func__, vdev);

	priv->status = 0;
}

static struct virtqueue *vptc_find_vq(struct virtio_device *vdev,
					     unsigned index,
					     void (*cb)(struct virtqueue *vq))
{
	struct vpt_dev *priv = vdev_to_vpt(vdev);
	struct virtqueue *vq = priv->vqs[index];

	pr_info("%s: vdev=0x%p index=%u cb=0x%p\n", __func__, vdev, index, cb);

	if (vq)
		return vq;

	vq = kzalloc(sizeof(*vq), GFP_KERNEL);
	if (!vq) {
		pr_info("%s: vdev=0x%p unable to allocate vq\n", __func__, vq);
		return ERR_PTR(-ENOMEM);
	}

	vq->callback = cb;
	vq->vdev = vdev;
	vq->vq_ops = &vpt_vq_ops;

	pr_info("%s: vdev=0x%p new vq=0x%p\n", __func__, vdev, vq);

	priv->vqs[index] = vq;
	return vq;
}

static void vptc_del_vq(struct virtqueue *vq)
{
	struct virtio_device *vdev = vq->vdev;
	struct vpt_dev *priv = vdev_to_vpt(vdev);
	int i;

	pr_info("%s: vq=0x%p\n", __func__, vq);

	for (i = 0; i < NUM_VQS; i++) {
		if (priv->vqs[i] == vq) {
			kfree(vq);
			priv->vqs[i] = NULL;
			return;
		}
	}

	pr_err("%s: vdev=0x%p unable to find vq=0x%p\n", __func__, vdev, vq);
}

static u32 vptc_get_features(struct virtio_device *vdev)
{
	pr_info("%s: vdev=0x%p\n", __func__, vdev);
	return 0;
}

static void vptc_finalize_features(struct virtio_device *vdev)
{
	pr_info("%s: vdev=0x%p\n", __func__, vdev);
}

static struct virtio_config_ops vpt_config_ops = {
	.get			= vptc_get,
	.set			= vptc_set,
	.get_status		= vptc_get_status,
	.set_status		= vptc_set_status,
	.reset			= vptc_reset,
	.find_vq		= vptc_find_vq,
	.del_vq			= vptc_del_vq,
	.get_features		= vptc_get_features,
	.finalize_features	= vptc_finalize_features,
};

/*----------------------------------------------------------------------------*/
/* PCI Subsystem                                                              */
/*----------------------------------------------------------------------------*/

static int vpt_probe(struct pci_dev *dev, const struct pci_device_id *id)
{
	struct vpt_dev *priv;
	int ret;

	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
	if (!priv) {
		ret = -ENOMEM;
		goto out_return;
	}

	pci_set_drvdata(dev, priv);

	/* Hardware Initialization */
	ret = pci_enable_device(dev);
	if (ret)
		goto out_pci_enable_dev;

	pci_set_master(dev);
	ret = pci_request_regions(dev, driver_name);
	if (ret)
		goto out_pci_request_regions;

	priv->immr = pci_ioremap_bar(dev, 0);
	if (!priv->immr) {
		ret = -ENOMEM;
		goto out_ioremap_immr;
	}

	priv->netregs = pci_ioremap_bar(dev, 1);
	if (!priv->netregs) {
		ret = -ENOMEM;
		goto out_ioremap_netregs;
	}

	ret = dma_set_mask(&dev->dev, DMA_BIT_MASK(30));
	if (ret) {
		dev_err(&dev->dev, "Unable to set DMA mask\n");
		ret = -ENODEV;
		goto out_set_dma_mask;
	}

	/* Mask all of the MBOX interrupts */
	iowrite32(0x1 | 0x2, priv->immr + OMIMR_OFFSET);

	/* Register the virtio_device corresponding to this PCI device */
	priv->vdev.dev.parent = &dev->dev;
	priv->vdev.id.device = VIRTIO_ID_NET;
	priv->vdev.config = &vpt_config_ops;

	ret = register_virtio_device(&priv->vdev);
	if (ret) {
		dev_err(&dev->dev, "Unable to register virtio device\n");
		goto out_register_virtio_device;
	}

	return 0;

out_register_virtio_device:
out_set_dma_mask:
	iounmap(priv->netregs);
out_ioremap_netregs:
	iounmap(priv->immr);
out_ioremap_immr:
	pci_release_regions(dev);
out_pci_request_regions:
	pci_disable_device(dev);
out_pci_enable_dev:
	kfree(priv);
out_return:
	return ret;
}

static void vpt_remove(struct pci_dev *dev)
{
	struct vpt_dev *priv = pci_get_drvdata(dev);

	unregister_virtio_device(&priv->vdev);
	iounmap(priv->netregs);
	iounmap(priv->immr);
	pci_release_regions(dev);
	pci_disable_device(dev);
	kfree(priv);
}

#define PCI_DEVID_FSL_MPC8349EMDS 0x0080

/* The list of devices that this module will support */
static struct pci_device_id vpt_ids[] = {
	{ PCI_DEVICE(PCI_VENDOR_ID_FREESCALE, PCI_DEVID_FSL_MPC8349EMDS), },
	{ 0, }
};
MODULE_DEVICE_TABLE(pci, vpt_ids);

static struct pci_driver vpt_pci_driver = {
	.name     = (char *)driver_name,
	.id_table = vpt_ids,
	.probe    = vpt_probe,
	.remove   = vpt_remove,
};

/*----------------------------------------------------------------------------*/
/* Module Init / Exit                                                         */
/*----------------------------------------------------------------------------*/

static int __init vpt_init(void)
{
	return pci_register_driver(&vpt_pci_driver);
}

static void __exit vpt_exit(void)
{
	pci_unregister_driver(&vpt_pci_driver);
}

MODULE_AUTHOR("Ira W. Snyder <iws@ovro.caltech.edu>");
MODULE_DESCRIPTION("Virtio PCI Test Driver");
MODULE_LICENSE("GPL");

module_init(vpt_init);
module_exit(vpt_exit);
