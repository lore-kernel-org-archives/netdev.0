From: Ira Snyder <iws@ovro.caltech.edu>
Subject: Re: [PATCH RFC v2] net: add PCINet driver
Date: Tue, 4 Nov 2008 13:25:28 -0800
Message-ID: <20081104212528.GD4641@ovro.caltech.edu>
References: <20081029202027.GH12879@ovro.caltech.edu> <200811041309.25869.arnd@arndb.de> <20081104173414.GB4641@ovro.caltech.edu> <200811042123.03819.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@ozlabs.org, Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jan-Bernd Themann <THEMANN@de.ibm.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ovro.ovro.caltech.edu ([192.100.16.2]:57111 "EHLO
	ovro.ovro.caltech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753353AbYKDVZb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 16:25:31 -0500
Content-Disposition: inline
In-Reply-To: <200811042123.03819.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 04, 2008 at 09:23:03PM +0100, Arnd Bergmann wrote:
> On Tuesday 04 November 2008, Ira Snyder wrote:
> > On Tue, Nov 04, 2008 at 01:09:25PM +0100, Arnd Bergmann wrote:
> > >
> > > Why 'depends on !PCI'? This means that you cannot build a kernel that
> > > is able to run both as host and endpoint for PCInet, right?
> > > 
> > 
> > Yes, that is correct. I did this because the Linux PCI code does some
> > relatively nasty things in agent mode. One thing that consistently
> > crashed my box was running through the quirks list and trying to
> > re-initialize an e100 that was in my box.
> > 
> > Remember, this is a PCI agent. It shouldn't be re-initializing the other
> > hardware on the PCI bus.
> 
> Yes, that makes sense. However, you should still be able to have the
> PCI code built into the kernel, as long as you prevent it from scanning
> the bus on the machine that is in agent/endpoint mode.
> 
> This should be made clear in the device tree. On the QS22 machine, we
> remove the "pci" device from the device tree, and add a "pcie-ep"
> device.
> 

Ok, that makes perfect sense. I'll test it at some point and make sure
that the kernel doesn't go through the quirks list, but it sounds
reasonable to assume it doesn't.

> > I left it optional so I could turn it on and off easily. I have no
> > strong feelings on keeping it optional.
> > 
> > Does the PCI bus reliably transfer data? I'm not sure. I left it there
> > so that we could at least turn on checksumming if there was a problem.
> 
> Yes, PCI guarantees reliable transfers.
>  

Great, I didn't know that. I'll turn it off unconditionally. Disabling
the checksumming gave me a few extra MB/sec.

> > > > +struct circ_buf_desc {
> > > > +	__le32 sc;
> > > > +	__le32 len;
> > > > +	__le32 addr;
> > > > +} __attribute__((__packed__));
> > > 
> > > It would be useful to always force aligning the desciptors to the whole
> > > 32 bit and avoid the packing here. Unaligned accesses are inefficient on
> > > many systems.
> > > 
> > 
> > I don't really know how to do that. I got a warning here from sparse
> > telling me something about expensive pointer subtraction. Adding a dummy
> > 32bit padding variable got rid of the warning, but I didn't change the
> > driver.
> 
> Ok, I see. However, adding the packed attribute makes it more expensive
> to use.
> 

Ok. Is there any way to make sure that the structure compiles to the
same representation on the host and agent system without using packed?

> > > > +typedef struct circ_buf_desc cbd_t;
> > > 
> > > Also, don't pass structures by value if they don't fit into one or
> > > two registers.
> > > 
> > 
> > These are only used for pointers to the buffer descriptors (in RAM on
> > the Freescale) that hold packet information. I never copy them directly.
> 
> Ok, then you should not have a typedef.
> 

Ok, it is gone in my latest version.

> > > > +/* Buffer Descriptor Accessors */
> > > > +#define CBDW_SC(_cbd, _sc) iowrite32((_sc), &(_cbd)->sc)
> > > > +#define CBDW_LEN(_cbd, _len) iowrite32((_len), &(_cbd)->len)
> > > > +#define CBDW_ADDR(_cbd, _addr) iowrite32((_addr), &(_cbd)->addr)
> > > > +
> > > > +#define CBDR_SC(_cbd) ioread32(&(_cbd)->sc)
> > > > +#define CBDR_LEN(_cbd) ioread32(&(_cbd)->len)
> > > > +#define CBDR_ADDR(_cbd) ioread32(&(_cbd)->addr)
> > > 
> > > We have found that accessing remote descriptors using mmio read is
> > > rather slow, and changed the code to always do local reads and
> > > remote writes.
> > > 
> > Interesting. I don't know how you would get network speed doing this.
> > X86 systems don't have a DMA conttroller. The entire purpose of making
> > the Freescale do all the copying was to use its DMA controller.
> > 
> > Using the DMA controller to transfer all of the data took my transfer
> > speed from ~3MB/sec to ~45MB/sec. While that is a good increase, it
> > could be better. I should be able to hit close to 133MB/sec (the limit
> > of PCI)
> 
> Then I think I misunderstood something about this driver. Are these
> descriptors accessed by the DMA engine, or by software? If it's the
> DMA engine accessing them, can you put the descriptors on both sides
> of the bus rather than just on one side?
> 

I access the descriptors in software, and program the DMA controller to
transfer the data. They are not directly used by the hardware.

I used the DMAEngine API to interact with the DMA controller. I tried
programming them manually, but the DMAEngine API was about 10 MB/sec
faster than I could achieve by hand.

See dma_async_copy_raw_to_buf() and dma_async_copy_buf_to_raw() in the
PowerPC code.

The basics of the network driver are as follows:
1) PowerPC allocates 4k of RAM for buffer descriptors, and
   exposes it over PCI in BAR 1
2) Host initializes all buffer descriptors to zero
3) Host allocates RING_SIZE 64K skb's, and puts them in the RX ring

On PowerPC hard_start_xmit():
1) Find the next free buffer in the RX ring, get the address stored
   inside it
2) DMA the packet given to us by the network stack to that address
3) Mark the buffer descriptor used
4) Interrupt the host

On Host hard_start_xmit():
1) Find the next free buffer descriptor in the TX ring
2) dma_map_single() and put the address into the buffer descriptor
3) Mark the buffer descriptor as used
4) Interrupt the PowerPC

On PowerPC rx_napi(): (scheduled by interrupt)
1) Find the next dirty buffer in the TX ring, get the address and len
2) Allocate an skb of this len
3) DMA the data into the new skb
4) Pass the new skb up into the kernel
5) Mark the buffer as freeable
6) Loop until done

On Host rx_napi():
1) Find the next dirty buffer in the RX ring, get the pointer to it in
   the list of allocated skbs
2) Allocate a new 64K skb
3) Put the new skb into the buffer descriptors, mark it as clean
4) Push the skb (from the RX ring) into the kernel
5) Loop until done

So, you'll notice that I only copy the data over the PCI bus once,
directly into the skb it is supposed to be going into. The buffer
descriptors are there so I know where to find the skb in host memory
across the PCI bus.

Hopefully that's a good description. :) It seems to me that both sides
of the connection need to read the descriptors (to get packet length,
clean up dirty packets, etc.) and write them (to set packet length, mark
packets dirty, etc.) I just can't come up with something that is
local-read / remote-write only.

> Which side allocates them anyway? Since you use ioread32/iowrite32
> on the ppc side, it looks like they are on the PCI host, which does
> not seem to make much sense, because the ppc memory is much closer
> to the DMA engine?
> 

The PowerPC allocates them. They are accessible via PCI BAR1. They live
in regular RAM on the PowerPC. I can't remember why I used
ioread32/iowrite32 anymore. I'll try again with in_le32()/out_le32() on
the PowerPC system, and see what happens.

> Obviously, you want the DMA engine to do the data transfers, but here, you
> use ioread32 for mmio transfers to the descriptors, which is slow.
> 

I didn't know it was slow :) Maybe this is why I had to make the MTU
very large to get good speed. Using a standard 1500 byte MTU I get
<10 MB/sec transfer speed. Using a 64K MTU, I get ~45MB/sec transfer
speed.

Do I need to do any sort of flushing to make sure that the read has
actually gone out of cache and into memory? When the host accesses the
buffer descriptors over PCI, it can only view memory. If a write is
still in the PowerPC cache, the host will get stale data.

> > Correct. This was done to make both sides as identical as possible. The
> > Freescale exports the entire 1MB block of IMMR registers at PCI BAR0. So
> > I have to use the offsets on the host side.
> > 
> > From the client side, I could just map what I need, but that would make
> > the two drivers diverge. I was trying to keep them the same.
> 
> Ah, I see. We had the same problem on Axon, and I'm still looking for a
> good solution. The best option is probably to abstract the immr access
> in some way and provide a driver that implements them on top of PCI.
> > 
> > > > +static void wqtuart_rx_char(struct uart_port *port, const char ch);
> > > > +static void wqtuart_stop_tx(struct uart_port *port);
> > > 
> > > You should try to avoid forward declarations for static functions.
> > > If you order the function implementation correctly, that will
> > > also give you the expected reading order in the driver.
> > > 
> > 
> > Yep, I tried to do this. I couldn't figure out a sane ordering that
> > would work. I tried to keep the network and uart as seperate as possible
> > in the code.
> 
> I'd suggest splitting the uart code into a separate driver then.
> 

How? In Linux we can only have one driver for a certain set of hardware.
I use the messaging unit to do both network (interrupts and status bits)
and uart (interrupts and message transfer).

Both the network and uart _must_ run at the same time. This way I can
type into the bootloader prompt to start a network transfer, and watch
it complete.

Remember, I can't have a real serial console plugged into this board.
I'll be using this with about 150 boards in 8 separate chassis, which
makes cabling a nightmare. I'm trying to do as much as possible with the
PCI backplane.

> > > > +struct wqt_dev {
> > > > +	/*--------------------------------------------------------------------*/
> > > > +	/* OpenFirmware Infrastructure                                        */
> > > > +	/*--------------------------------------------------------------------*/
> > > > +	struct of_device *op;
> > > > +	struct device *dev;
> > > 
> > > Why the dev? You can always get that from the of_device, right?
> > > 
> > 
> > Yes. I stored it there to make it identical to the host driver. By doing
> > this, both drivers have code that says "dev_debug(priv->dev, ...)"
> > rather than:
> > 
> > Host:
> > dev_debug(&priv->pdev->dev, ...)
> > 
> > Freescale:
> > dev_debug(&priv->op->dev, ...)
> 
> Ok. You can just store the dev pointer then, and leave out the op pointer.
> You can always do a container_of() to get back to it.
>  

True, I didn't think of that. I'll make that change.

> > Yes, I agree. How do you make two Linux drivers that can be loaded for
> > the same hardware at the same time? :) AFAIK, you cannot.
> > 
> > I NEED two functions accessible at the same time, network (to transfer
> > data) and uart (to control my bootloader).
> > 
> > I use the uart to interact with the bootloader (U-Boot) and tell it
> > where to tftp a kernel. I use the network to transfer the kernel.
> > 
> > So you see, I really do need them both at the same time. If you know a
> > better way to do this, please let me know!
> > 
> > It was possible to write seperate U-Boot drivers, but only by being
> > careful to not conflict in my usage of the hardware.
> 
> Ok, I see. I fear any nice solution would make the u-boot drivers much
> more complex.
>  

Perhaps. I'm perfectly willing to port things to U-Boot. Especially if
we can make something generic enough to be re-used by many different
boards. Recently, another person on the U-Boot list has shown a need for
this kind of solution.

> > > > +	/*--------------------------------------------------------------------*/
> > > > +	/* Ethernet Device Infrastructure                                     */
> > > > +	/*--------------------------------------------------------------------*/
> > > > +	struct net_device *ndev;
> > > 
> > > Why make this a separate structure? If you have one of these per net_device,
> > > you should embed the net_device into your own structure.
> > > 
> > 
> > This structure is embedded in struct net_device! Look at how
> > alloc_etherdev() works. You pass it the size of your private data
> > structure and it allocates the space for you.
> 
> right, I remember now. Unfortunately, alloc_etherdev is a little bit
> different from many other kernel interfaces.
> 

Yep. It sure is :)

> > > > +	struct tasklet_struct tx_complete_tasklet;
> > > 
> > > Using a tasklet for tx processing sounds fishy because most of the
> > > network code already runs at softirq time. You do not gain anything
> > > by another softirq context.
> > > 
> > 
> > I didn't want to run the TX cleanup routine at hard irq time, because it
> > can potentially take some time to run. I would rather run it with hard
> > interrupts enabled.
> 
> sure.
> 
> > This DOES NOT do TX processing, it only frees skbs that have been
> > transferred. I used the network stack to do as much as possible, of
> > course.
> 
> Most drivers now do that from the *rx* poll function, and call
> netif_rx_schedule when they get a tx interrupt.
> 

That is an interesting concept. I'll look around the drivers/net tree
and try to find one that works this way. It should be pretty easy to
implement, though. I'll try it out.

> > > If this is in an interrupt handler, why disable the interrupts again?
> > > The same comment applies to many of the other places where you
> > > use spin_lock_irqsave rather than spin_lock or spin_lock_irq.
> > > 
> > 
> > I tried to make the locking do only what was needed. I just couldn't get
> > it correct unless I used spin_lock_irqsave(). I was able to get the
> > system to deadlock otherwise. This is why I posted the driver for
> > review, I could use some help here.
> > 
> > It isn't critical anyway. You can always use spin_lock_irqsave(), it is
> > just a little slower, but it will always work :)
> 
> I like the documenting character of the spinlock functions. E.g. if you
> use spin_lock_irq() in a function, it is obvious that interrupts are enabled,
> and if you use spin_lock() on a lock that requires disabling interrupts,
> you know that interrupts are already off.
>  

True. I just couldn't seem to get it right. I'll try again. Perhaps it
was another bug in the driver that I hadn't found at the time.

> > Thanks so much for the review! I hope we can work together to get
> > something that can be merged into mainline Linux. I'm willing to write
> > code, I just need some direction from more experienced kernel
> > developers.
> 
> Great, I can certainly help with that. Please CC me on anything related
> to this driver.

Will do. Please CC me on anything similar that you run across as well.
:)

Ira
