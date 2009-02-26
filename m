From: Ira Snyder <iws@ovro.caltech.edu>
Subject: Re: [RFC v2] virtio: add virtio-over-PCI driver
Date: Thu, 26 Feb 2009 15:17:42 -0800
Message-ID: <20090226231742.GB19959@ovro.caltech.edu>
References: <20090224000002.GA578@ovro.caltech.edu> <200902262137.15169.arnd@arndb.de> <20090226214919.GA19959@ovro.caltech.edu> <200902262334.33778.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	Jan-Bernd Themann <THEMANN@de.ibm.com>,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ovro.ovro.caltech.edu ([192.100.16.2]:43976 "EHLO
	ovro.ovro.caltech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754208AbZBZXRp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 18:17:45 -0500
Content-Disposition: inline
In-Reply-To: <200902262334.33778.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 26, 2009 at 11:34:33PM +0100, Arnd Bergmann wrote:
> On Thursday 26 February 2009, Ira Snyder wrote:
> > On Thu, Feb 26, 2009 at 09:37:14PM +0100, Arnd Bergmann wrote:
> > 
> > The registers are part of the board control registers. They don't fit at
> > all in the message unit. Doing this in the bootloader seems like a
> > logical place, but that would require any testers to flash a new U-Boot
> > image into their mpc8349emds boards.
> > 
> > The first set of access is used to set up a 1GB region in the memory map
> > that accesses the host's memory. Any reads/writes to addresses
> > 0x80000000-0xc0000000 actually hit the host's memory.
> > 
> > The last access sets up PCI BAR1 to hit the memory from
> > dma_alloc_coherent(). The bootloader already sets up the window as 16K,
> > it just doesn't point it anywhere. Maybe this /should/ go into the
> > bootloader. Like above, it would require testers to flash a new U-Boot
> > image into their mpc8349emds boards.
> 
> Ok, I see.
> 
> I guess the best option for doing it in Linux then would be to have
> a board control driver (not sure if this already exists) that exports
> high-level functions to set up the inbound and outbound windows.
> 

Nothing like it exists. The OF device tree doesn't even describe these
registers. The code in arch/powerpc/sysdev/fsl_pci.c uses some registers
near these, but it gets their address by masking the low bits off the
addresses from the device tree and adding the offsets of the new
registers. Nasty.

I'll do this for now:
1) Get the message unit registers from my device tree
2) Encapsulate all use of get_immrbase() to a single function

That way it could be easily replaced in the future when something more
suitable comes along.

> > Yeah, virtio doesn't work that way.
> > 
> > The virtio drivers just call find_vq() with a different index for each
> > queue they want to use. You have no way of knowing how many queues each
> > virtio driver will want, unless you go read their source code.
> > 
> > virtio-net currently uses 3 queues, but we only support the first two.
> > The third is optional (for now...), and non-symmetric.
> 
> I mean the part of your driver that calls register_virtio_device()
> could make the decision, this is the one I was referring to
> as virtio_net glue because it is the only part that actually needs
> to know about the features etc.
> 
> Right now, you just call register_virtio_net from vop_probe(), which
> is absolutely appropriate for the specific use case. In the most
> general case though, you would have a user interface on one or
> both sides that allows a (root) user to trigger the creation of
> a virtio_net (or other virtio) device with specific characteristics
> such as MAC address or number of virtqueues.
> 

I didn't think about this at all. This driver could be used to boot a
(guest) system over NFS, so in that case there isn't a userspace running
yet, to allow configuration. This is essentially my use case, though I
haven't implemented it yet.

Also, I hate designing user interfaces :) Any concrete suggestions on
design would be most welcome.

> One idea I had earlier was that there could be a special device
> with just one virtqueue that is always present and that allows you
> do communicate configuration changes regarding the available devices
> to the remote VOP driver.
> 

That's an interesting idea that I didn't consider, either. It wouldn't
have to be fast, just reliable. When you're doing small transfers, the
CPU is just fine.

Ira
