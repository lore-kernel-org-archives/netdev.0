From: Ira Snyder <iws@ovro.caltech.edu>
Subject: Re: [RFC v2] virtio: add virtio-over-PCI driver
Date: Thu, 26 Feb 2009 12:01:10 -0800
Message-ID: <20090226200110.GA19523@ovro.caltech.edu>
References: <20090224000002.GA578@ovro.caltech.edu> <200902261715.28440.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	Jan-Bernd Themann <THEMANN@de.ibm.com>,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ovro.ovro.caltech.edu ([192.100.16.2]:48754 "EHLO
	ovro.ovro.caltech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752484AbZBZUBR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 15:01:17 -0500
Content-Disposition: inline
In-Reply-To: <200902261715.28440.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 26, 2009 at 05:15:27PM +0100, Arnd Bergmann wrote:
> On Tuesday 24 February 2009, Ira Snyder wrote:
> > This adds support to Linux for using virtio between two computers linked by
> > a PCI interface. This allows the use of virtio_net to create a familiar,
> > fast interface for communication. It should be possible to use other virtio
> > devices in the future, but this has not been tested.
> 
> Wonderful, I like it a lot!
> 
> One major aspect that I hope can be improved is the layering
> of the driver to make it easier to reuse parts for other
> hardware implementations and also for sharing code between
> the two sides. Most of my comments below are about this.
> 
> A better split I can imagine would be:
> 
> 1. of_device hardware specific probing, and creation of virtqueues
> 2. pci hardware specific probing, and detection of virtqueues
> 3. library with common code, hardware independent
> 4. library with common code, hardware specific but used by both of_device
>    and pci.
> 5. interface to virtio-net on top of that (symmetric)
> 

I think so too. I was just getting something working, and thought it
would be better to have it "out there" rather than be working on it
forever. I'll try to break things up as I have time.

For the "libraries", would you suggest breaking things into seperate
code files, and using EXPORT_SYMBOL_GPL()? I'm not very familiar with
doing that, I've mostly been writing code within the existing device
driver frameworks. Or do I need export symbol at all? I'm not sure...

> > +/* Virtio-over-PCI descriptors: 12 bytes. These can chain together via "next" */
> > +struct vop_desc {
> > +	/* Address (host physical) */
> > +	__le32 addr;
> > +	/* Length (bytes) */
> > +	__le32 len;
> > +	/* Flags */
> > +	__le16 flags;
> > +	/* Chaining for descriptors */
> > +	__le16 next;
> > +} __attribute__((packed));
> 
> I would drop the "packed" attribute in the structure definitions.
> It would imply that only byte accesses are allowed on these
> data structures, because the attribute invalidates any assumptions
> about alignment. None of your structures require padding, so
> the attribute does not have any positive effect either.
> 

I always thought you were supposed to use packed for data structures
that are external to the system. I purposely designed the structures so
they wouldn't need padding.

I'll drop it and check for any problems.

> > +/* MPC8349EMDS specific get_immrbase() */
> > +#include <sysdev/fsl_soc.h>
> 
> Do you really need get_immrbase? I would expect that you can find
> all the registers you need in the device tree, or exported from
> other low-level drivers per subsystem.
> 
> immrbase is a concept from the time before our device trees.
> 

I mostly don't need it. In fact, the only place I'm using registers not
specific to the messaging unit is in the probe routine, where I setup
the 1GB window into host memory and setting up access to the guest
memory on the PCI bus.

Now, I wouldn't need to access these registers at all if the bootloader
could handle it. I just don't know if it is possible to have Linux not
use some memory that the bootloader allocated, other than with the
mem=XXX trick, which I'm sure wouldn't be acceptable. I've just used
regular RAM so this is portable to my custom board (mpc8349emds based)
and a regular mpc8349emds. I didn't want to change anything board
specific.

I would love to have the bootloader allocate (or reserve somewhere in
the memory map) 16K of RAM, and not be required to allocate it with
dma_alloc_coherent(). It would save me plenty of headaches.

> > +/*
> > + * These are internal use only versions of the structures that
> > + * are exported over PCI by this driver
> > + *
> > + * They are used internally to keep track of the PowerPC queues so that
> > + * we don't have to keep flipping endianness all the time
> > + */
> > +struct vop_loc_desc {
> > +	u32 addr;
> > +	u32 len;
> > +	u16 flags;
> > +	u16 next;
> > +};
> > +
> > +struct vop_loc_avail {
> > +	u16 index;
> > +	u16 ring[VOP_RING_SIZE];
> > +};
> > +
> > +struct vop_loc_used_elem {
> > +	u32 id;
> > +	u32 len;
> > +};
> > +
> > +struct vop_loc_used {
> > +	u16 index;
> > +	struct vop_loc_used_elem ring[VOP_RING_SIZE];
> > +};
> 
> Are you worried about the overhead of having to do byte flips,
> or the code complexity? I would guess that the overhead is
> near zero, but I'm not sure about the source code complexity.
> Generally, I'd expect that you'd be better off just using the
> wire-level data structures directly.
> 

Code complexity only. Also, it was easier to write 80-char lines with
something like:

vop_get_desc(vq, idx, &desc);
if (desc.flags & VOP_DESC_F_NEXT) {
	/* do something */
}

Instead of:
if (le16_to_cpu(vq->desc[idx].flags) & VOP_DESC_F_NEXT) {
	/* do something */
}

Plus, I didn't have to remember how many bits were in each field. I just
thought it made everything simpler to understand. Suggestions?

> > +/*
> > + * DMA Resolver state information
> > + */
> > +struct vop_dma_info {
> > +	struct dma_chan *chan;
> > +
> > +	/* The currently processing avail entry */
> > +	u16 loc_avail;
> > +	u16 rem_avail;
> > +
> > +	/* The currently processing used entries */
> > +	u16 loc_used;
> > +	u16 rem_used;
> > +};
> > +
> > +struct vop_vq {
> > +
> > +	/* The actual virtqueue itself */
> > +	struct virtqueue vq;
> > +	struct device *dev;
> > +
> > +	/* The host ring address */
> > +	struct vop_host_ring __iomem *host;
> > +
> > +	/* The guest ring address */
> > +	struct vop_guest_ring *guest;
> > +
> > +	/* Our own memory descriptors */
> > +	struct vop_loc_desc desc[VOP_RING_SIZE];
> > +	struct vop_loc_avail avail;
> > +	struct vop_loc_used used;
> > +	unsigned int flags;
> > +
> > +	/* Data tokens from add_buf() */
> > +	void *data[VOP_RING_SIZE];
> > +
> > +	unsigned int num_free;	/* number of free descriptors in desc */
> > +	unsigned int free_head;	/* start of the free descriptors in desc */
> > +	unsigned int num_added;	/* number of entries added to desc */
> > +
> > +	u16 loc_last_used;	/* the last local used entry processed */
> > +	u16 rem_last_used;	/* the current value of remote used_idx */
> > +
> > +	/* DMA resolver state */
> > +	struct vop_dma_info dma;
> > +	struct work_struct work;
> > +	int (*resolve)(struct vop_vq *vq);
> > +
> > +	void __iomem *immr;
> > +	int kick_val;
> > +};
> 
> This data structure mixes generic information with fsl-834x specific
> members. I think you should try to split this better into a common
> part (also common for host and guest) to allow sharing the code
> across other low-level implementations:
> 
> struct vop_vq {
> 	struct virtqueue vq;
> 	struct vop_host_ring __iomem *host;
> 	struct vop_guest_ring *guest;
> 	...
> };
> 
> and in another file:
> 
> struct fsl834x_vq {
> 	struct vop_vq;
> 	struct fsl834x_vop_regs __iomem *regs; /* instead of immr */
> }
> 
> If you split the structures this way, the abstraction should
> come naturally.
> 

Looks good to me. I'll work towards this in my next version.

> > +/*
> > + * This represents a virtio_device for our driver. It follows the memory
> > + * layout shown above. It has pointers to all of the host and guest memory
> > + * areas that we need to access
> > + */
> > +struct vop_vdev {
> > +
> > +	/* The specific virtio device (console, net, blk) */
> > +	struct virtio_device vdev;
> > +
> > +	#define VOP_DEVICE_REGISTERED 1
> > +	int status;
> > +
> > +	/* Start address of local and remote memory */
> > +	void *loc;
> > +	void __iomem *rem;
> > +
> > +	/*
> > +	 * These are the status, feature, and configuration information
> > +	 * for this virtio device. They are exposed in our memory block
> > +	 * starting at offset 0.
> > +	 */
> > +	struct vop_status __iomem *host_status;
> > +
> > +	/*
> > +	 * These are the status, feature, and configuration information
> > +	 * for the guest virtio device. They are exposed in the guest
> > +	 * memory block starting at offset 0.
> > +	 */
> > +	struct vop_status *guest_status;
> > +
> > +	/*
> > +	 * These are the virtqueues for the virtio driver running this
> > +	 * device to use. The host portions are exposed in our memory block
> > +	 * starting at offset 1024. The exposed areas are aligned to 1024 byte
> > +	 * boundaries, so they appear at offets 1024, 2048, and 3072
> > +	 * respectively.
> > +	 */
> > +	struct vop_vq virtqueues[3];
> > +};
> 
> Unfortunately, that structure layout implies an extra pointer level here:
> 
> 	struct vop_vq *virtqueues[3];
> 
> I also wonder if the number of virtqueues should be variable here.
> 

I used 3 so they would would align to 1024 byte boundaries within a 4K
page. Then the layout was 16K on the bus, each 4K page is a single
virtio-device, and each 1K block is a single virtqueue. The first 1K is
for virtio-device status and feature bits, etc.

Packing them differently isn't a problem. It was just easier to code
because setting up a window with the correct size is so platform
specific.

> > +struct vop_dev {
> > +
> > +	struct of_device *op;
> > +	struct device *dev;
> > +
> > +	/* Reset and start */
> > +	struct mutex mutex;
> > +	struct work_struct reset_work;
> > +	struct work_struct start_work;
> > +
> > +	int irq;
> > +
> > +	/* Our board control registers */
> > +	void __iomem *immr;
> > +
> > +	/* The guest memory, exposed at PCI BAR1 */
> > +	#define VOP_GUEST_MEM_SIZE 16384
> > +	void *guest_mem;
> > +	dma_addr_t guest_mem_addr;
> > +
> > +	/* Host memory, given to us by host in OMR0 */
> > +	#define VOP_HOST_MEM_SIZE 16384
> > +	void __iomem *host_mem;
> > +
> > +	/* The virtio devices */
> > +	struct vop_vdev devices[4];
> > +	struct dma_chan *chan;
> > +};
> 
> This one again is hardware specific, right? If so, it should go
> together with what I call fsl834x_vq above.
> 

Yeah. It is the per-device private data, setup in the probe() routine.
Some of the data isn't needed in each virtqueue, so I left it seperate.

> > +/*----------------------------------------------------------------------------*/
> > +/* Local descriptor ring access helpers                                       */
> > +/*----------------------------------------------------------------------------*/
> > +
> > +static void vop_set_desc_addr(struct vop_vq *vq, unsigned int idx, u32 addr)
> > +{
> > +	vq->desc[idx].addr = addr;
> > +}
> > +
> > +static void vop_set_desc_len(struct vop_vq *vq, unsigned int idx, u32 len)
> > +{
> > +	vq->desc[idx].len = len;
> > +}
> > +
> > +static void vop_set_desc_flags(struct vop_vq *vq, unsigned int idx, u16 flags)
> > +{
> > +	vq->desc[idx].flags = flags;
> > +}
> > +
> > +static void vop_set_desc_next(struct vop_vq *vq, unsigned int idx, u16 next)
> > +{
> > +	vq->desc[idx].next = next;
> > +}
> > +
> > +static u16 vop_get_desc_flags(struct vop_vq *vq, unsigned int idx)
> > +{
> > +	return vq->desc[idx].flags;
> > +}
> > +
> > +static u16 vop_get_desc_next(struct vop_vq *vq, unsigned int idx)
> > +{
> > +	return vq->desc[idx].next;
> > +}
> 
> I don't quite get the point in these accessors. Calling one of these
> functions would be longer than open-coding the content.
> 

They're leftovers from the host code. I'll get rid of them. It would be
even better if I just returned pointers into the vq->desc array rather
than copying the descriptors out of them.

> > +/*----------------------------------------------------------------------------*/
> > +/* Scatterlist DMA helpers                                                    */
> > +/*----------------------------------------------------------------------------*/
> > +
> > +/*
> > + * This function abuses some of the scatterlist code and implements
> > + * dma_map_sg() in such a way that we don't need to keep the scatterlist
> > + * around in order to unmap it.
> > + *
> > + * It is also designed to never merge scatterlist entries, which is
> > + * never what we want for virtio.
> > + *
> > + * When it is time to unmap the buffer, you can use dma_unmap_single() to
> > + * unmap each entry in the chain. Get the address, length, and direction
> > + * from the descriptors! (keep a local copy for speed)
> > + */
> 
> Why is that an advantage over dma_unmap_sg?
> 

When running dma_map_sg(), the scatterlist code is allowed to alter the
scatterlist to store data it needs for dma_unmap_sg(), along with
merging adjacent buffers, etc.

I don't want any of that behavior. The generic virtio code does not
handle merging of buffers.

Also, all of the generic virtio code allocates its scatterlists on the
stack. This means I cannot save the pointers between add_buf() and
get_buf(). If I used dma_map_sg(), I'd have to allocate memory to copy
the scatterlist, map it, and save the pointer. Later, retrieve the
pointer, unmap it, and free the memory.

This is simpler than all of that.

> > +static int vop_dma_map_sg(struct device *dev, struct scatterlist sg[],
> > +			  unsigned int out, unsigned int in)
> > +{
> > +	dma_addr_t addr;
> > +	enum dma_data_direction dir;
> > +	struct scatterlist *start;
> > +	unsigned int i, failure;
> > +
> > +	start = sg;
> > +
> > +	for (i = 0; i < out + in; i++) {
> > +
> > +		/* Check for scatterlist chaining abuse */
> > +		BUG_ON(sg == NULL);
> > +
> > +		dir = (i < out) ? DMA_TO_DEVICE : DMA_FROM_DEVICE;
> > +		addr = dma_map_single(dev, sg_virt(sg), sg->length, dir);
> > +
> > +		if (dma_mapping_error(dev, addr))
> > +			goto unwind;
> > +
> > +		sg_dma_address(sg) = addr;
> > +		sg = sg_next(sg);
> > +	}
> 
> I believe this kind of loop can be simplified using for_each_sg().
> 
> 

Yep, you're right. The scatterlists that the virtio_net driver sent used
to be improperly terminated (they ended early, according to the
scatterlist chaining code). This caused me some null pointer oopses. I
submitted a patch to fix virtio_net, so I can use for_each_sg() now.

I'll make the change for my next version.

> > +	/* Remap IMMR */
> > +	priv->immr = ioremap(get_immrbase(), 0x100000);
> > +	if (!priv->immr) {
> > +		dev_err(&op->dev, "Unable to remap IMMR registers\n");
> > +		ret = -ENOMEM;
> > +		goto out_dma_release_channel;
> > +	}
> 
> As mentioned above, this should be something like an of_iomap(op, ...)
> 

Yep. See my comments above.

> > +struct vop_vq {
> > +
> > +	/* The actual virtqueue itself */
> > +	struct virtqueue vq;
> > +
> > +	struct device *dev;
> > +
> > +	/* The host ring address */
> > +	struct vop_host_ring *host;
> > +
> > +	/* The guest ring address */
> > +	struct vop_guest_ring __iomem *guest;
> > +
> > +	/* Local copy of the descriptors for fast access */
> > +	struct vop_loc_desc desc[VOP_RING_SIZE];
> > +
> > +	/* The data token from add_buf() */
> > +	void *data[VOP_RING_SIZE];
> > +
> > +	unsigned int num_free;
> > +	unsigned int free_head;
> > +	unsigned int num_added;
> > +
> > +	u16 avail_idx;
> > +	u16 last_used_idx;
> > +
> > +	/* The doorbell to kick() */
> > +	unsigned int kick_val;
> > +	void __iomem *immr;
> > +};
> 
> I find it very confusing to have almost-identical data structures by the
> same name in two files. Obviously, you have a lot of common code between
> the two sides, but rather than making the implementation files *look*
> similar, it would be better to focus on splitting out the shared code
> into a common file and keep the different/duplicated code small.
> 

I kept the names the same because they served the same purpose on both
sides. When the sides use common code, they'll mostly go away.

> > +	switch (index) {
> > +	case 0: /* x86 recv virtqueue -- ppc xmit virtqueue */
> > +		vq->guest = vdev->rem + 1024;
> > +		vq->host  = vdev->loc + 1024;
> > +		break;
> > +	case 1: /* x86 xmit virtqueue -- ppc recv virtqueue */
> > +		vq->guest = vdev->rem + 2048;
> > +		vq->host  = vdev->loc + 2048;
> > +		break;
> > +	default:
> > +		dev_err(vq->dev, "unknown virtqueue %d\n", index);
> > +		return ERR_PTR(-ENODEV);
> > +	}
> 
> I'd avoid making assumptions or comments about the architectures.
> Rather than "x86" and "ppc", I'd write "local" and "remote".
> 

Yep, just artifacts of my design here. I'll change it.


Thanks for the review. I really appreciate it.
Ira
