From: Ira Snyder <iws@ovro.caltech.edu>
Subject: Re: [RFC v1] virtio: add virtio-over-PCI driver
Date: Thu, 19 Feb 2009 08:49:57 -0800
Message-ID: <20090219164956.GB12795@ovro.caltech.edu>
References: <20090217222425.GA18801@ovro.caltech.edu> <200902181713.03820.rusty@rustcorp.com.au> <20090218163835.GA29728@ovro.caltech.edu> <200902192148.05651.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
	Jan-Bernd Themann <THEMANN@de.ibm.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ovro.ovro.caltech.edu ([192.100.16.2]:43222 "EHLO
	ovro.ovro.caltech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751659AbZBSQt6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2009 11:49:58 -0500
Content-Disposition: inline
In-Reply-To: <200902192148.05651.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 19, 2009 at 09:48:04PM +1030, Rusty Russell wrote:
> On Thursday 19 February 2009 03:08:35 Ira Snyder wrote:
> > On Wed, Feb 18, 2009 at 05:13:03PM +1030, Rusty Russell wrote:
> > > don't restrict yourself to 32 feature bits (only PCI does this, and they're
> > > going to have to hack when we reach feature 32).
> > 
> > There isn't any problem adding more feature bits. Do you think 128 bits
> > is enough?
> 
> Probably.  We have unlimited bits in lguest and s390, but 128 is reasonable
> for the forseeable future (if not, you end up using bit 128 to mean "look
> somewhere else for the rest of the bits).
> 

Ok. There currently isn't an interface to access more than 32 bits
anyway.

> > > How about prepending a 4 byte length on the host buffers?  Allows host to
> > > specify length (for host->guest), and guest writes it to allow truncated
> > > buffers on guest->host.
> > > 
> > > That won't allow you to transfer *more* than one buffersize to the host, but
> > > you could use a different method (perhaps the 4 bytes indicates the *total*
> > > length?).
> > 
> > I don't understand how this will help.
> > 
> > I looked at virtio_net's implemention with VIRTIO_NET_F_MRG_RXBUF, which
> > seems like it could really help performance. The problems with that are:
> > 1) virtio_net doesn't write the merged header's num_buffers field
> > 2) virtio_net doesn't actually split packets in xmit
> ...
> > I'm using two instances of virtio_net to talk to each other, rather than
> > a special userspace implementation like lguest and kvm use. Is this a
> > good approach?
> 
> Well, virtio in general is guest-host asymmetric.  I originally explored
> symmetry, but it didn't seem to offer any concrete advantages, so we didn't
> require it.  You aren't actually directly connecting two guests, are you?
> So this is just a simplification for your implementation?
> 

I'm not connecting two guests directly. My eventual setup will have a
single x86 computer (the host) and many guest systems. I don't care if
the guests cannot communicate between each other, just that they can
communicate with the host.

I wanted to avoid the extra trip to userspace, so I just connected two
instances of virtio_net together. This way you just recv packets in the
kernel, rather than jumping to userspace and then using TAP/TUN to drive
packets back into the kernel. Plus, I have no idea how I would do a
userspace interface. I'd definitely need help.

> You could always add a VIRTIO_NET_F_MRG_TXBUF which did what you want, but
> note that symmetry breaks down for other virtio uses, too: block definitely
> isn't symmetric of course, but I haven't audited the others.
> 

I have no need to use virtio_blk, so I pretty much ignored it. In fact, I
didn't make any attempt to support RO and WO buffers in the same queue.
Virtio_net only uses queues this way, and it was much easier for me to
wrap my head around.

I don't think that virtio_console is symmetric either, but I haven't
really studied it. I was thinking about implementing a virtio_uart which
would be symmetric. That would be plenty for my needs.

> So I'd recommend asymmetry; hack your host to understand chained buffers.
> 

It's not that virtio_net doesn't understand chained buffers, it just
doesn't write them. Grep for uses of the num_buffers field in
virtio_net. It uses them in recv, it just doesn't write them in xmit.

It assumes that add_buf() can accept something like:
idx address  len flags next
0   XXXXXXX   12     N    1
1   XXXXXXX 8000     -    2

That would mean it can shove an 8000 byte packet into the virtqueue. It
doesn't have any way of knowing to split packets up into chunks, nor how
many chunks are available. It assumes that the receiver can read from
any address on the sender.

I think that this is a perfectly reasonable assumption in a shared
memory system, but it breaks down in my case. I cannot just tell the
host "the packet data is at this address" because it cannot do DMA. I
have to use the guest system to do DMA. The host has to have
pre-allocated the recv memory so the DMA engine has somewhere to copy
the data to.

Maybe I'm explaining this poorly, but try to think about it this way:
1) Unlike a virtual machine, both systems are NOT sharing memory
2) Both systems have some limited access to each other's memory
3) Both systems can write descriptors equally fast
4) Copying payload data is extremely slow for the host
5) Copying payload data is extremely fast for the guest


It would be possible to just alter virtio_net's headers in-flight to set
the number of buffers actually used. This would split the 8000 byte
packet up into two chunks, 4096 byte and 3904 byte, then set num_buffers
to 2. This would add some complexity, but I think it is probably
reasonable.

Ira
