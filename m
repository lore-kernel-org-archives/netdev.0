From: olof@lixom.net (Olof Johansson)
Subject: Re: [PATCH] PA Semi PWRficient Ethernet driver
Date: Mon, 29 Jan 2007 19:41:16 -0600
Message-ID: <20070130014116.GB18935@lixom.net>
References: <20070129060852.GA7814@lixom.net> <20070129223506.GA29068@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:49970 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752649AbXA3Ben (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jan 2007 20:34:43 -0500
Content-Disposition: inline
In-Reply-To: <20070129223506.GA29068@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Thanks for the comments. In general I have applied them, with some specific
comments below.

I'll repost a new version of the driver based on this and other feedback
later tonight.

On Mon, Jan 29, 2007 at 11:35:06PM +0100, Francois Romieu wrote:
> Olof Johansson <olof@lixom.net> :
> > Driver for the PA Semi PWRficient on-chip Ethernet (1/10G)
> > 
> > Basic enablement, will be complemented with performance enhancements
> > over time. PHY support will be added as well.
> 
> - The driver does not contain a single SMP locking instruction but
>   http://www.pasemi.com claims the platform to be multicore.
>   Is the driver really designed to be lockless ?

Unless I misunderstood something, NAPI drivers that don't set NETIF_F_LLTX
will have all locking taken care of by higher layers, no?

> - Is there really no other choice than constantly accessing the
>   registers of the device through pci_write_config_dword() ?
>   No PCI BAR remappable area ?

Maybe a bit of introduction could be useful (also regarding the
pci_map/alloc comments below).

Our devices are on-chip, and while they're not on a PCI(e) bus internally,
they do have config headers and will show up as devices on a pseudo-bus
(the root one, in fact).

Also, while the driver could go through the IOMMU layers, there's no
real use in doing so at this time.

When it comes to register access -- it would probably make sense to
remap them separately and use normal accessors instead of going through
the quite heavyweight PCI config accessors. I used them right now for
convenience.

As I already mentioned, there's not been a whole lot of performance work
done on this driver yet; I expect to address this when I get started
on that.

> - Is there a volunteer to maintain the driver ? If so the MAINTAINERS
>   file should be updated (hint, hint).

Yep, forgot to include it.

> - No known public documentation for the hardware ?

Not at this time, but the driver will be actively maintained so it
shouldn't be an issue.

> Inlined remarks below.

Comments to some of them below.





> > +#define BUF_SIZE 2048
> 
> Is there a specific reason for this rather unusual size ?

A nice and round and large enough number. But no, no real reason. Fixed.

(And yes, large MTU support is also on the todo list. :-)

> > +	ring->buffers = (void *)__get_free_pages(GFP_KERNEL,
> > +					 get_order(ring->count * sizeof(u64)));
> > +	ring->buf_dma = virt_to_phys(ring->buffers);
> > +	memset(ring->buffers, 0, ring->count * sizeof(u64));
> 
> Use pci_alloc_consistent() ?

Nope, for reasons above.

> > +static noinline void pasemi_mac_free_resources(struct net_device *dev)
> > +{
> > +	struct pasemi_mac *mac = netdev_priv(dev);
> > +	int i;
> 
> unsigned int is supposed to save some cycles on ppc.

Who told you that? That's not true.
Still, there's no need for the iterator to be signed.

> > +	if (ret)
> > +		printk("request_irq of irq %d failed: %d\n",
> > +		       mac->dma_pdev->irq + mac->dma_txch, ret);
> 
> 
> Missing KERN_XYZ.

Changed all the printk's to be dev_*() instead based on Stephen's comments.

> > +static void pasemi_mac_set_rx_mode(struct net_device *dev)
> > +{
> > +	struct pasemi_mac *mac = netdev_priv(dev);
> > +	unsigned int flags;
> > +
> > +	return;
> 
> Huh ?

Yeah, forgot it there from debugging. Can't even remember why I added
it and I obviously missed it when going through before posting.

> > +
> > +	for (i = start; i < start+mac->rx->count && count < limit; i++) {
>                                 ^^^
> I would not protest against a few parenthesis here and there.
> 
> > +		rmb();
> > +		mb();
> 
> rmb() _and_ mb() ?
> 
> Btw a scroll of ancient incantation is available in
> Documentation/memory-barriers.txt btw.

Not sure why they were still left in there. Only rmb is needed. Same
for the barrier at the bottom of the loop.

> > +static int __devinit
> > +pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
> > +{
> [..]
> > +	/* The dma status structure is located in the I/O bridge, and
> > +	 * is cache coherent.
> > +	 */
> > +	if (!dma_status)
> > +		/* XXXOJN This should come from the device tree */
> > +		dma_status = __ioremap(0xfd800000, 0x1000, 0);
> 
> Is this address really set in stone or can it be retrieved after some
> pci_get_device(...) practice ?

As the comment says -- one day it should come out of the device tree. It's
a well-known and not dynamic address on the current chips; but it might be
located somewhere else on future products.

> > +	mac->rx_status = &dma_status->rx_sta[mac->dma_rxch];
> > +	mac->tx_status = &dma_status->tx_sta[mac->dma_txch];
> 
> Addresses returned from ioremap are not guaranteed to be dereferencable
> like that.

That's why I'm using __ioremap instead, to get a cacheable regular area
to just reference.

Is there another preferred method of doing this? Note that it is a
cache-coherent status area, so regular ioremap() is not the solution.

> > +	{ PCI_DEVICE(0x1959, 0xa005) },
> > +	{ PCI_DEVICE(0x1959, 0xa006) },
> 
> Minor nit: just use a #define for the vendor ID and you will simply
> submit a one-line removal the day pci_ids is updated.

I'll just include the vendor ID in this patch instead.

> > +#define DESCR(ring, i) ((ring)->desc[i % ((ring)->count)])
> > +#define BUFF(ring, i) ((ring)->buffers[i % ((ring)->count)])
> > +#define INFO(ring, i) ((ring)->desc_info[i % ((ring)->count)])
> 
> A bit ugly/obfuscating/name clash prone imvho.
> 
> Use local variables ?

I'm open for suggestions here, not sure how local variables will help though?


-Olof
