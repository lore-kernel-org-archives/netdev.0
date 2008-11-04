From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH RFC v2] net: add PCINet driver
Date: Tue, 4 Nov 2008 21:23:03 +0100
Message-ID: <200811042123.03819.arnd@arndb.de>
References: <20081029202027.GH12879@ovro.caltech.edu> <200811041309.25869.arnd@arndb.de> <20081104173414.GB4641@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ira Snyder <iws@ovro.caltech.edu>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jan-Bernd Themann <THEMANN@de.ibm.com>
To: linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:54440 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752501AbYKDUXP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 15:23:15 -0500
In-Reply-To: <20081104173414.GB4641@ovro.caltech.edu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 04 November 2008, Ira Snyder wrote:
> On Tue, Nov 04, 2008 at 01:09:25PM +0100, Arnd Bergmann wrote:
> >
> > Why 'depends on !PCI'? This means that you cannot build a kernel that
> > is able to run both as host and endpoint for PCInet, right?
> > 
> 
> Yes, that is correct. I did this because the Linux PCI code does some
> relatively nasty things in agent mode. One thing that consistently
> crashed my box was running through the quirks list and trying to
> re-initialize an e100 that was in my box.
> 
> Remember, this is a PCI agent. It shouldn't be re-initializing the other
> hardware on the PCI bus.

Yes, that makes sense. However, you should still be able to have the
PCI code built into the kernel, as long as you prevent it from scanning
the bus on the machine that is in agent/endpoint mode.

This should be made clear in the device tree. On the QS22 machine, we
remove the "pci" device from the device tree, and add a "pcie-ep"
device.

> I left it optional so I could turn it on and off easily. I have no
> strong feelings on keeping it optional.
> 
> Does the PCI bus reliably transfer data? I'm not sure. I left it there
> so that we could at least turn on checksumming if there was a problem.

Yes, PCI guarantees reliable transfers.
 
> > > +struct circ_buf_desc {
> > > +	__le32 sc;
> > > +	__le32 len;
> > > +	__le32 addr;
> > > +} __attribute__((__packed__));
> > 
> > It would be useful to always force aligning the desciptors to the whole
> > 32 bit and avoid the packing here. Unaligned accesses are inefficient on
> > many systems.
> > 
> 
> I don't really know how to do that. I got a warning here from sparse
> telling me something about expensive pointer subtraction. Adding a dummy
> 32bit padding variable got rid of the warning, but I didn't change the
> driver.

Ok, I see. However, adding the packed attribute makes it more expensive
to use.

> > > +typedef struct circ_buf_desc cbd_t;
> > 
> > Also, don't pass structures by value if they don't fit into one or
> > two registers.
> > 
> 
> These are only used for pointers to the buffer descriptors (in RAM on
> the Freescale) that hold packet information. I never copy them directly.

Ok, then you should not have a typedef.

> > > +/* Buffer Descriptor Accessors */
> > > +#define CBDW_SC(_cbd, _sc) iowrite32((_sc), &(_cbd)->sc)
> > > +#define CBDW_LEN(_cbd, _len) iowrite32((_len), &(_cbd)->len)
> > > +#define CBDW_ADDR(_cbd, _addr) iowrite32((_addr), &(_cbd)->addr)
> > > +
> > > +#define CBDR_SC(_cbd) ioread32(&(_cbd)->sc)
> > > +#define CBDR_LEN(_cbd) ioread32(&(_cbd)->len)
> > > +#define CBDR_ADDR(_cbd) ioread32(&(_cbd)->addr)
> > 
> > We have found that accessing remote descriptors using mmio read is
> > rather slow, and changed the code to always do local reads and
> > remote writes.
> > 
> Interesting. I don't know how you would get network speed doing this.
> X86 systems don't have a DMA conttroller. The entire purpose of making
> the Freescale do all the copying was to use its DMA controller.
> 
> Using the DMA controller to transfer all of the data took my transfer
> speed from ~3MB/sec to ~45MB/sec. While that is a good increase, it
> could be better. I should be able to hit close to 133MB/sec (the limit
> of PCI)

Then I think I misunderstood something about this driver. Are these
descriptors accessed by the DMA engine, or by software? If it's the
DMA engine accessing them, can you put the descriptors on both sides
of the bus rather than just on one side?

Which side allocates them anyway? Since you use ioread32/iowrite32
on the ppc side, it looks like they are on the PCI host, which does
not seem to make much sense, because the ppc memory is much closer
to the DMA engine?

Obviously, you want the DMA engine to do the data transfers, but here, you
use ioread32 for mmio transfers to the descriptors, which is slow.

> Correct. This was done to make both sides as identical as possible. The
> Freescale exports the entire 1MB block of IMMR registers at PCI BAR0. So
> I have to use the offsets on the host side.
> 
> From the client side, I could just map what I need, but that would make
> the two drivers diverge. I was trying to keep them the same.

Ah, I see. We had the same problem on Axon, and I'm still looking for a
good solution. The best option is probably to abstract the immr access
in some way and provide a driver that implements them on top of PCI.
> 
> > > +static void wqtuart_rx_char(struct uart_port *port, const char ch);
> > > +static void wqtuart_stop_tx(struct uart_port *port);
> > 
> > You should try to avoid forward declarations for static functions.
> > If you order the function implementation correctly, that will
> > also give you the expected reading order in the driver.
> > 
> 
> Yep, I tried to do this. I couldn't figure out a sane ordering that
> would work. I tried to keep the network and uart as seperate as possible
> in the code.

I'd suggest splitting the uart code into a separate driver then.

> > > +struct wqt_dev {
> > > +	/*--------------------------------------------------------------------*/
> > > +	/* OpenFirmware Infrastructure                                        */
> > > +	/*--------------------------------------------------------------------*/
> > > +	struct of_device *op;
> > > +	struct device *dev;
> > 
> > Why the dev? You can always get that from the of_device, right?
> > 
> 
> Yes. I stored it there to make it identical to the host driver. By doing
> this, both drivers have code that says "dev_debug(priv->dev, ...)"
> rather than:
> 
> Host:
> dev_debug(&priv->pdev->dev, ...)
> 
> Freescale:
> dev_debug(&priv->op->dev, ...)

Ok. You can just store the dev pointer then, and leave out the op pointer.
You can always do a container_of() to get back to it.
 
> Yes, I agree. How do you make two Linux drivers that can be loaded for
> the same hardware at the same time? :) AFAIK, you cannot.
> 
> I NEED two functions accessible at the same time, network (to transfer
> data) and uart (to control my bootloader).
> 
> I use the uart to interact with the bootloader (U-Boot) and tell it
> where to tftp a kernel. I use the network to transfer the kernel.
> 
> So you see, I really do need them both at the same time. If you know a
> better way to do this, please let me know!
> 
> It was possible to write seperate U-Boot drivers, but only by being
> careful to not conflict in my usage of the hardware.

Ok, I see. I fear any nice solution would make the u-boot drivers much
more complex.
 
> > > +	struct workqueue_struct *wq;
> > 
> > A per-device pointer to a workqueue_struct is unusual. What are you doing
> > this for? How about using the system work queue?
> > 
> 
> Look through the code carefully, especially at uart_tx_work_fn(), which
> calls do_send_message().
> 
> do_send_message() can sleep for a long time. If I use the shared
> workqueue, I block ALL OTHER USERS of the queue for the time I am
> asleep. They cannot run.

ok.

> The LDD3 book says not to use the shared workqueue if you are going to
> sleep for long periods. I followed their advice.

ok.

> > > +	/*--------------------------------------------------------------------*/
> > > +	/* Ethernet Device Infrastructure                                     */
> > > +	/*--------------------------------------------------------------------*/
> > > +	struct net_device *ndev;
> > 
> > Why make this a separate structure? If you have one of these per net_device,
> > you should embed the net_device into your own structure.
> > 
> 
> This structure is embedded in struct net_device! Look at how
> alloc_etherdev() works. You pass it the size of your private data
> structure and it allocates the space for you.

right, I remember now. Unfortunately, alloc_etherdev is a little bit
different from many other kernel interfaces.

> > > +	struct tasklet_struct tx_complete_tasklet;
> > 
> > Using a tasklet for tx processing sounds fishy because most of the
> > network code already runs at softirq time. You do not gain anything
> > by another softirq context.
> > 
> 
> I didn't want to run the TX cleanup routine at hard irq time, because it
> can potentially take some time to run. I would rather run it with hard
> interrupts enabled.

sure.

> This DOES NOT do TX processing, it only frees skbs that have been
> transferred. I used the network stack to do as much as possible, of
> course.

Most drivers now do that from the *rx* poll function, and call
netif_rx_schedule when they get a tx interrupt.

> > If this is in an interrupt handler, why disable the interrupts again?
> > The same comment applies to many of the other places where you
> > use spin_lock_irqsave rather than spin_lock or spin_lock_irq.
> > 
> 
> I tried to make the locking do only what was needed. I just couldn't get
> it correct unless I used spin_lock_irqsave(). I was able to get the
> system to deadlock otherwise. This is why I posted the driver for
> review, I could use some help here.
> 
> It isn't critical anyway. You can always use spin_lock_irqsave(), it is
> just a little slower, but it will always work :)

I like the documenting character of the spinlock functions. E.g. if you
use spin_lock_irq() in a function, it is obvious that interrupts are enabled,
and if you use spin_lock() on a lock that requires disabling interrupts,
you know that interrupts are already off.
 
> Thanks so much for the review! I hope we can work together to get
> something that can be merged into mainline Linux. I'm willing to write
> code, I just need some direction from more experienced kernel
> developers.

Great, I can certainly help with that. Please CC me on anything related
to this driver.

	Arnd <><
