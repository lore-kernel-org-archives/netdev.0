From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC v2] virtio: add virtio-over-PCI driver
Date: Thu, 26 Feb 2009 17:15:27 +0100
Message-ID: <200902261715.28440.arnd@arndb.de>
References: <20090224000002.GA578@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	Jan-Bernd Themann <THEMANN@de.ibm.com>,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Ira Snyder <iws@ovro.caltech.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:50746 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754960AbZBZQQD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 11:16:03 -0500
In-Reply-To: <20090224000002.GA578@ovro.caltech.edu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 24 February 2009, Ira Snyder wrote:
> This adds support to Linux for using virtio between two computers linked by
> a PCI interface. This allows the use of virtio_net to create a familiar,
> fast interface for communication. It should be possible to use other virtio
> devices in the future, but this has not been tested.

Wonderful, I like it a lot!

One major aspect that I hope can be improved is the layering
of the driver to make it easier to reuse parts for other
hardware implementations and also for sharing code between
the two sides. Most of my comments below are about this.

A better split I can imagine would be:

1. of_device hardware specific probing, and creation of virtqueues
2. pci hardware specific probing, and detection of virtqueues
3. library with common code, hardware independent
4. library with common code, hardware specific but used by both of_device
   and pci.
5. interface to virtio-net on top of that (symmetric)

> +/* Virtio-over-PCI descriptors: 12 bytes. These can chain together via "next" */
> +struct vop_desc {
> +	/* Address (host physical) */
> +	__le32 addr;
> +	/* Length (bytes) */
> +	__le32 len;
> +	/* Flags */
> +	__le16 flags;
> +	/* Chaining for descriptors */
> +	__le16 next;
> +} __attribute__((packed));

I would drop the "packed" attribute in the structure definitions.
It would imply that only byte accesses are allowed on these
data structures, because the attribute invalidates any assumptions
about alignment. None of your structures require padding, so
the attribute does not have any positive effect either.

> +/* MPC8349EMDS specific get_immrbase() */
> +#include <sysdev/fsl_soc.h>

Do you really need get_immrbase? I would expect that you can find
all the registers you need in the device tree, or exported from
other low-level drivers per subsystem.

immrbase is a concept from the time before our device trees.

> +/*
> + * These are internal use only versions of the structures that
> + * are exported over PCI by this driver
> + *
> + * They are used internally to keep track of the PowerPC queues so that
> + * we don't have to keep flipping endianness all the time
> + */
> +struct vop_loc_desc {
> +	u32 addr;
> +	u32 len;
> +	u16 flags;
> +	u16 next;
> +};
> +
> +struct vop_loc_avail {
> +	u16 index;
> +	u16 ring[VOP_RING_SIZE];
> +};
> +
> +struct vop_loc_used_elem {
> +	u32 id;
> +	u32 len;
> +};
> +
> +struct vop_loc_used {
> +	u16 index;
> +	struct vop_loc_used_elem ring[VOP_RING_SIZE];
> +};

Are you worried about the overhead of having to do byte flips,
or the code complexity? I would guess that the overhead is
near zero, but I'm not sure about the source code complexity.
Generally, I'd expect that you'd be better off just using the
wire-level data structures directly.

> +/*
> + * DMA Resolver state information
> + */
> +struct vop_dma_info {
> +	struct dma_chan *chan;
> +
> +	/* The currently processing avail entry */
> +	u16 loc_avail;
> +	u16 rem_avail;
> +
> +	/* The currently processing used entries */
> +	u16 loc_used;
> +	u16 rem_used;
> +};
> +
> +struct vop_vq {
> +
> +	/* The actual virtqueue itself */
> +	struct virtqueue vq;
> +	struct device *dev;
> +
> +	/* The host ring address */
> +	struct vop_host_ring __iomem *host;
> +
> +	/* The guest ring address */
> +	struct vop_guest_ring *guest;
> +
> +	/* Our own memory descriptors */
> +	struct vop_loc_desc desc[VOP_RING_SIZE];
> +	struct vop_loc_avail avail;
> +	struct vop_loc_used used;
> +	unsigned int flags;
> +
> +	/* Data tokens from add_buf() */
> +	void *data[VOP_RING_SIZE];
> +
> +	unsigned int num_free;	/* number of free descriptors in desc */
> +	unsigned int free_head;	/* start of the free descriptors in desc */
> +	unsigned int num_added;	/* number of entries added to desc */
> +
> +	u16 loc_last_used;	/* the last local used entry processed */
> +	u16 rem_last_used;	/* the current value of remote used_idx */
> +
> +	/* DMA resolver state */
> +	struct vop_dma_info dma;
> +	struct work_struct work;
> +	int (*resolve)(struct vop_vq *vq);
> +
> +	void __iomem *immr;
> +	int kick_val;
> +};

This data structure mixes generic information with fsl-834x specific
members. I think you should try to split this better into a common
part (also common for host and guest) to allow sharing the code
across other low-level implementations:

struct vop_vq {
	struct virtqueue vq;
	struct vop_host_ring __iomem *host;
	struct vop_guest_ring *guest;
	...
};

and in another file:

struct fsl834x_vq {
	struct vop_vq;
	struct fsl834x_vop_regs __iomem *regs; /* instead of immr */
}

If you split the structures this way, the abstraction should
come naturally.

> +/*
> + * This represents a virtio_device for our driver. It follows the memory
> + * layout shown above. It has pointers to all of the host and guest memory
> + * areas that we need to access
> + */
> +struct vop_vdev {
> +
> +	/* The specific virtio device (console, net, blk) */
> +	struct virtio_device vdev;
> +
> +	#define VOP_DEVICE_REGISTERED 1
> +	int status;
> +
> +	/* Start address of local and remote memory */
> +	void *loc;
> +	void __iomem *rem;
> +
> +	/*
> +	 * These are the status, feature, and configuration information
> +	 * for this virtio device. They are exposed in our memory block
> +	 * starting at offset 0.
> +	 */
> +	struct vop_status __iomem *host_status;
> +
> +	/*
> +	 * These are the status, feature, and configuration information
> +	 * for the guest virtio device. They are exposed in the guest
> +	 * memory block starting at offset 0.
> +	 */
> +	struct vop_status *guest_status;
> +
> +	/*
> +	 * These are the virtqueues for the virtio driver running this
> +	 * device to use. The host portions are exposed in our memory block
> +	 * starting at offset 1024. The exposed areas are aligned to 1024 byte
> +	 * boundaries, so they appear at offets 1024, 2048, and 3072
> +	 * respectively.
> +	 */
> +	struct vop_vq virtqueues[3];
> +};

Unfortunately, that structure layout implies an extra pointer level here:

	struct vop_vq *virtqueues[3];

I also wonder if the number of virtqueues should be variable here.

> +struct vop_dev {
> +
> +	struct of_device *op;
> +	struct device *dev;
> +
> +	/* Reset and start */
> +	struct mutex mutex;
> +	struct work_struct reset_work;
> +	struct work_struct start_work;
> +
> +	int irq;
> +
> +	/* Our board control registers */
> +	void __iomem *immr;
> +
> +	/* The guest memory, exposed at PCI BAR1 */
> +	#define VOP_GUEST_MEM_SIZE 16384
> +	void *guest_mem;
> +	dma_addr_t guest_mem_addr;
> +
> +	/* Host memory, given to us by host in OMR0 */
> +	#define VOP_HOST_MEM_SIZE 16384
> +	void __iomem *host_mem;
> +
> +	/* The virtio devices */
> +	struct vop_vdev devices[4];
> +	struct dma_chan *chan;
> +};

This one again is hardware specific, right? If so, it should go
together with what I call fsl834x_vq above.

> +/*----------------------------------------------------------------------------*/
> +/* Local descriptor ring access helpers                                       */
> +/*----------------------------------------------------------------------------*/
> +
> +static void vop_set_desc_addr(struct vop_vq *vq, unsigned int idx, u32 addr)
> +{
> +	vq->desc[idx].addr = addr;
> +}
> +
> +static void vop_set_desc_len(struct vop_vq *vq, unsigned int idx, u32 len)
> +{
> +	vq->desc[idx].len = len;
> +}
> +
> +static void vop_set_desc_flags(struct vop_vq *vq, unsigned int idx, u16 flags)
> +{
> +	vq->desc[idx].flags = flags;
> +}
> +
> +static void vop_set_desc_next(struct vop_vq *vq, unsigned int idx, u16 next)
> +{
> +	vq->desc[idx].next = next;
> +}
> +
> +static u16 vop_get_desc_flags(struct vop_vq *vq, unsigned int idx)
> +{
> +	return vq->desc[idx].flags;
> +}
> +
> +static u16 vop_get_desc_next(struct vop_vq *vq, unsigned int idx)
> +{
> +	return vq->desc[idx].next;
> +}

I don't quite get the point in these accessors. Calling one of these
functions would be longer than open-coding the content.

> +/*----------------------------------------------------------------------------*/
> +/* Scatterlist DMA helpers                                                    */
> +/*----------------------------------------------------------------------------*/
> +
> +/*
> + * This function abuses some of the scatterlist code and implements
> + * dma_map_sg() in such a way that we don't need to keep the scatterlist
> + * around in order to unmap it.
> + *
> + * It is also designed to never merge scatterlist entries, which is
> + * never what we want for virtio.
> + *
> + * When it is time to unmap the buffer, you can use dma_unmap_single() to
> + * unmap each entry in the chain. Get the address, length, and direction
> + * from the descriptors! (keep a local copy for speed)
> + */

Why is that an advantage over dma_unmap_sg?

> +static int vop_dma_map_sg(struct device *dev, struct scatterlist sg[],
> +			  unsigned int out, unsigned int in)
> +{
> +	dma_addr_t addr;
> +	enum dma_data_direction dir;
> +	struct scatterlist *start;
> +	unsigned int i, failure;
> +
> +	start = sg;
> +
> +	for (i = 0; i < out + in; i++) {
> +
> +		/* Check for scatterlist chaining abuse */
> +		BUG_ON(sg == NULL);
> +
> +		dir = (i < out) ? DMA_TO_DEVICE : DMA_FROM_DEVICE;
> +		addr = dma_map_single(dev, sg_virt(sg), sg->length, dir);
> +
> +		if (dma_mapping_error(dev, addr))
> +			goto unwind;
> +
> +		sg_dma_address(sg) = addr;
> +		sg = sg_next(sg);
> +	}

I believe this kind of loop can be simplified using for_each_sg().


> +	/* Remap IMMR */
> +	priv->immr = ioremap(get_immrbase(), 0x100000);
> +	if (!priv->immr) {
> +		dev_err(&op->dev, "Unable to remap IMMR registers\n");
> +		ret = -ENOMEM;
> +		goto out_dma_release_channel;
> +	}

As mentioned above, this should be something like an of_iomap(op, ...)

> +struct vop_vq {
> +
> +	/* The actual virtqueue itself */
> +	struct virtqueue vq;
> +
> +	struct device *dev;
> +
> +	/* The host ring address */
> +	struct vop_host_ring *host;
> +
> +	/* The guest ring address */
> +	struct vop_guest_ring __iomem *guest;
> +
> +	/* Local copy of the descriptors for fast access */
> +	struct vop_loc_desc desc[VOP_RING_SIZE];
> +
> +	/* The data token from add_buf() */
> +	void *data[VOP_RING_SIZE];
> +
> +	unsigned int num_free;
> +	unsigned int free_head;
> +	unsigned int num_added;
> +
> +	u16 avail_idx;
> +	u16 last_used_idx;
> +
> +	/* The doorbell to kick() */
> +	unsigned int kick_val;
> +	void __iomem *immr;
> +};

I find it very confusing to have almost-identical data structures by the
same name in two files. Obviously, you have a lot of common code between
the two sides, but rather than making the implementation files *look*
similar, it would be better to focus on splitting out the shared code
into a common file and keep the different/duplicated code small.

> +	switch (index) {
> +	case 0: /* x86 recv virtqueue -- ppc xmit virtqueue */
> +		vq->guest = vdev->rem + 1024;
> +		vq->host  = vdev->loc + 1024;
> +		break;
> +	case 1: /* x86 xmit virtqueue -- ppc recv virtqueue */
> +		vq->guest = vdev->rem + 2048;
> +		vq->host  = vdev->loc + 2048;
> +		break;
> +	default:
> +		dev_err(vq->dev, "unknown virtqueue %d\n", index);
> +		return ERR_PTR(-ENODEV);
> +	}

I'd avoid making assumptions or comments about the architectures.
Rather than "x86" and "ppc", I'd write "local" and "remote".

	Arnd <><
