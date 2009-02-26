From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC v2] virtio: add virtio-over-PCI driver
Date: Thu, 26 Feb 2009 23:34:33 +0100
Message-ID: <200902262334.33778.arnd@arndb.de>
References: <20090224000002.GA578@ovro.caltech.edu> <200902262137.15169.arnd@arndb.de> <20090226214919.GA19959@ovro.caltech.edu>
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
Received: from moutng.kundenserver.de ([212.227.126.171]:56538 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754290AbZBZWe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 17:34:56 -0500
In-Reply-To: <20090226214919.GA19959@ovro.caltech.edu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 26 February 2009, Ira Snyder wrote:
> On Thu, Feb 26, 2009 at 09:37:14PM +0100, Arnd Bergmann wrote:
> 
> The registers are part of the board control registers. They don't fit at
> all in the message unit. Doing this in the bootloader seems like a
> logical place, but that would require any testers to flash a new U-Boot
> image into their mpc8349emds boards.
> 
> The first set of access is used to set up a 1GB region in the memory map
> that accesses the host's memory. Any reads/writes to addresses
> 0x80000000-0xc0000000 actually hit the host's memory.
> 
> The last access sets up PCI BAR1 to hit the memory from
> dma_alloc_coherent(). The bootloader already sets up the window as 16K,
> it just doesn't point it anywhere. Maybe this /should/ go into the
> bootloader. Like above, it would require testers to flash a new U-Boot
> image into their mpc8349emds boards.

Ok, I see.

I guess the best option for doing it in Linux then would be to have
a board control driver (not sure if this already exists) that exports
high-level functions to set up the inbound and outbound windows.

> Yeah, virtio doesn't work that way.
> 
> The virtio drivers just call find_vq() with a different index for each
> queue they want to use. You have no way of knowing how many queues each
> virtio driver will want, unless you go read their source code.
> 
> virtio-net currently uses 3 queues, but we only support the first two.
> The third is optional (for now...), and non-symmetric.

I mean the part of your driver that calls register_virtio_device()
could make the decision, this is the one I was referring to
as virtio_net glue because it is the only part that actually needs
to know about the features etc.

Right now, you just call register_virtio_net from vop_probe(), which
is absolutely appropriate for the specific use case. In the most
general case though, you would have a user interface on one or
both sides that allows a (root) user to trigger the creation of
a virtio_net (or other virtio) device with specific characteristics
such as MAC address or number of virtqueues.

One idea I had earlier was that there could be a special device
with just one virtqueue that is always present and that allows you
do communicate configuration changes regarding the available devices
to the remote VOP driver.

	Arnd <><
