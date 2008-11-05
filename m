From: Ira Snyder <iws@ovro.caltech.edu>
Subject: Re: [PATCH RFC v2] net: add PCINet driver
Date: Wed, 5 Nov 2008 11:32:50 -0800
Message-ID: <20081105193250.GC31188@ovro.caltech.edu>
References: <20081029202027.GH12879@ovro.caltech.edu> <200811042123.03819.arnd@arndb.de> <20081104212528.GD4641@ovro.caltech.edu> <200811051451.00065.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@ozlabs.org, Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jan-Bernd Themann <THEMANN@de.ibm.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ovro.ovro.caltech.edu ([192.100.16.2]:41248 "EHLO
	ovro.ovro.caltech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754752AbYKETcw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 14:32:52 -0500
Content-Disposition: inline
In-Reply-To: <200811051451.00065.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 05, 2008 at 02:50:59PM +0100, Arnd Bergmann wrote:
> On Tuesday 04 November 2008, Ira Snyder wrote:
> > On Tue, Nov 04, 2008 at 09:23:03PM +0100, Arnd Bergmann wrote:
> > > On Tuesday 04 November 2008, Ira Snyder wrote:
> > > > I don't really know how to do that. I got a warning here from sparse
> > > > telling me something about expensive pointer subtraction. Adding a dummy
> > > > 32bit padding variable got rid of the warning, but I didn't change the
> > > > driver.
> > > 
> > > Ok, I see. However, adding the packed attribute makes it more expensive
> > > to use.
> > > 
> > 
> > Ok. Is there any way to make sure that the structure compiles to the
> > same representation on the host and agent system without using packed?
> 
> Only knowledge about the alignment on all the possible architectures ;-)
> As a simplified rule, always pad every struct member to the largest
> other member in the struct and always use explicitly sized types like
> __u8 or __le32.
>  

Ok, I tried using:
struct circ_buf_desc {
	__le32 sc;
	__le32 len;
	__le32 addr;
	__le32 padding;
};

The structure came out the same size on both x86 and powerpc, and the
driver still works. I'll put this change in the driver.

> > Hopefully that's a good description. :) It seems to me that both sides
> > of the connection need to read the descriptors (to get packet length,
> > clean up dirty packets, etc.) and write them (to set packet length, mark
> > packets dirty, etc.) I just can't come up with something that is
> > local-read / remote-write only.
> 
> If I understand your description correctly, the only remote read is
> when the host accesses the buffer descriptors to find free space.
> Avoiding this read access may improve the latency a bit. In our ring
> buffer concept, both host and endpoint allocate a memory buffer that
> gets ioremapped into the remote side. Since you always need to read
> the descriptors from powerpc, you should probably keep them in powerpc
> memory, but you can change the code so that for finding the next
> free entry, the host will look in its own memory for the number of the
> next entry, and the powerpc side will write that when it consumes a
> descriptor to mark it as free.
> 

There are a few remote reads (from the host).

1) in hard_start_xmit() to make sure the queue is stopped
2) in wqt_tx_complete() to find the buffer descriptors that have been
   consumed
3) in wqt_rx_napi() to find the buffer descriptors that have been
   dirtied
4) in wqt_rx_napi() to get the actual packet length of a dirty buffer

I /could/ come up with a scheme to use only writes, but it seems much
too complicated for a little performance.

I'll keep it in mind, and change it during performance tuning (if
needed).

> > > Which side allocates them anyway? Since you use ioread32/iowrite32
> > > on the ppc side, it looks like they are on the PCI host, which does
> > > not seem to make much sense, because the ppc memory is much closer
> > > to the DMA engine?
> > > 
> > 
> > The PowerPC allocates them. They are accessible via PCI BAR1. They live
> > in regular RAM on the PowerPC. I can't remember why I used
> > ioread32/iowrite32 anymore. I'll try again with in_le32()/out_le32() on
> > the PowerPC system, and see what happens.
> 
> Actually, if they are in powerpc RAM, you must not neither in_le32 nor
> ioread32. Both are only well-defined on I/O devices (local bus or PCI,
> respectively). Instead, you should use directly access the buffer using
> pointer dereferences, and use rmb()/wmb() to make sure anything you
> access is synchronized with the host.
> 

I've changed it to just do pointer dereferences, and it works just fine.
I added appropriate wmb() (I think...)

> > > Obviously, you want the DMA engine to do the data transfers, but here, you
> > > use ioread32 for mmio transfers to the descriptors, which is slow.
> > > 
> > 
> > I didn't know it was slow :) Maybe this is why I had to make the MTU
> > very large to get good speed. Using a standard 1500 byte MTU I get
> > <10 MB/sec transfer speed. Using a 64K MTU, I get ~45MB/sec transfer
> > speed.
> > 
> > Do I need to do any sort of flushing to make sure that the read has
> > actually gone out of cache and into memory? When the host accesses the
> > buffer descriptors over PCI, it can only view memory. If a write is
> > still in the PowerPC cache, the host will get stale data.
> 
> The access over the bus is cache-coherent, unless you are on one of the
> more obscure powerpc implementations. This means you do not have a
> problem with data still being in cache. However, you need to make
> sure that data arrives in the right order. DMA read accesses over PCI
> may be reordered, and you need a wmb() between two memory stores if you
> want to be sure that the host sees them in the correct order.
> 

Ok.

> > > > Yep, I tried to do this. I couldn't figure out a sane ordering that
> > > > would work. I tried to keep the network and uart as seperate as possible
> > > > in the code.
> > > 
> > > I'd suggest splitting the uart code into a separate driver then.
> > > 
> > 
> > How? In Linux we can only have one driver for a certain set of hardware.
> > I use the messaging unit to do both network (interrupts and status bits)
> > and uart (interrupts and message transfer).
> > 
> > Both the network and uart _must_ run at the same time. This way I can
> > type into the bootloader prompt to start a network transfer, and watch
> > it complete.
> > 
> > Remember, I can't have a real serial console plugged into this board.
> > I'll be using this with about 150 boards in 8 separate chassis, which
> > makes cabling a nightmare. I'm trying to do as much as possible with the
> > PCI backplane.
>  
> When splitting out the hardware specific parts, I would write a device
> driver for the messaging unit that knows about neither the uart nor the
> network (or any other high-level protocol). It's a bit more complicated to
> load the two high-level drivers in that case, but one clean way to do
> it would be to instantiate a new bus-type from the MU driver and have
> that driver register devices for itself. Then you can load the high-level
> driver through udev or have them built into the kernel.
> 
> To get really fancy, you could find a way for the host to announce what
> protocols are supported on though the MU. A use case for that, which I
> have been thinking about before, would be to allow the host to set up
> direct virtual point-to-point networks between two endpoints, not involving
> the host at all once the device is up.
> 

This is getting pretty complicated, especially for someone just getting
started writing drivers. :)

It seems like you'd need a set of functions to access specific
interrupts / message boxes, maybe something like the gpio interface
(where each gpio pin has an integer number).

Both sides have to agree on what each interrupt means, and which mailbox
data transfer happens in. So each driver would still be pretty closely
tied to the hardware.

It seems like too much for someone like me to design. I'll leave it up
to the pro's.

Ira
