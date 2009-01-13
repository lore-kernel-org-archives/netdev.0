From: Ira Snyder <iws@ovro.caltech.edu>
Subject: Re: [PATCH RFC v5] net: add PCINet driver
Date: Mon, 12 Jan 2009 19:34:20 -0800
Message-ID: <20090113033420.GA11065@ovro.caltech.edu>
References: <20090107195052.GA24981@ovro.caltech.edu> <20090108192716.GA19863@ovro.caltech.edu> <20090108215127.GA28935@ovro.caltech.edu> <200901131302.52754.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, shemminger@vyatta.com, arnd@arndb.de,
	netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ovro.ovro.caltech.edu ([192.100.16.2]:54465 "EHLO
	ovro.ovro.caltech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753649AbZAMDeW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 22:34:22 -0500
Content-Disposition: inline
In-Reply-To: <200901131302.52754.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 13, 2009 at 01:02:52PM +1030, Rusty Russell wrote:
> On Friday 09 January 2009 08:21:27 Ira Snyder wrote:
> > Rusty, since you wrote the virtio code, can you point me at the things I
> > would need to implement to use virtio over the PCI bus.
> > 
> > The guests (PowerPC computers running Linux) are PCI cards in the host
> > system (an Intel Pentium3-M system). The guest computers can access all
> > of the host's memory. The guests provide a 1MB (movable) window into
> > their memory.
> > 
> > The PowerPC computers also have a DMA controller, which I've used to get
> > better throughput from my driver. I have a way to create interrupts to
> > both the host and guest systems.
> > 
> > I've read your paper titled: "virtio: Towards a De-Facto Standard For
> > Virtual I/O Devices"
> > 
> > If I read that correctly, then I should implement all of the functions
> > in struct virtqueue_ops appropriately, and the existing virtio drivers
> > should just work. The only concern I have there is how to make guest ->
> > host transfer use the DMA controller. I've done all programming of it
> > from the guest kernel, using the Linux DMAEngine API.
> 
> Hi Ira,
> 
>    Interesting system: the guest being able to access the host's memory but not (fully) vice-versa makes this a little different from the current implementations where that was assumed.  virtio assumes that the guest will publish buffers and someone else (ie. the host) will access them.
> 

The guest system /could/ publish all of its RAM, but with 256MB per
board, 19 boards per cPCI crate, that's way too much for a 32-bit PC to
map into it's memory space. That's the real reason I use the 1MB
windows. I could make them bigger (16MB would be fine, I think), but I
doubt it would make much of a difference to the implementation.

>    > Are there any other implementations other than virtio_ring?
> 
>    There were some earlier implementations, but they were trivial.  And not particularly helpful in your case.
> 
> In summary, yes, it should work quite nicely, but rather than publishing the buffers to the host, the host will need to tell the guest where it wants them transferred (possibly using that 1M window, and a notification mechanism).  That will be the complex part I think.
> 

I've got a system like that right now in the driver that started this
thread. I tried to mimic the buffer descriptor rings in a network card.
The virtio system doesn't seem to be too different. I can probably work
something out.

What's keeping me from getting started is what to do with the
virtqueue_ops structure once I've got the functions to fill it in. There
isn't a register_virtqueue_ops() function. I'm not at all sure when to
use a struct virtio_driver or a struct virtio_device. I hunch I need one
of these.

If I've understood this whole thing correctly, then I should be able to
register a virtio_ops on both sides, and then insmod virtio_net and
virtio_console, and have them "just work".

I guess what I'm looking for is something trivial, something that'll
insmod and printk() whenever one of the virtqueue_ops pointers is
called. Something like a template. That's how I really learned when all
of the uart functions are called, for example.

Thanks,
Ira
