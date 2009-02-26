From: Ira Snyder <iws@ovro.caltech.edu>
Subject: Re: [RFC v2] virtio: add virtio-over-PCI driver
Date: Thu, 26 Feb 2009 13:49:19 -0800
Message-ID: <20090226214919.GA19959@ovro.caltech.edu>
References: <20090224000002.GA578@ovro.caltech.edu> <200902261715.28440.arnd@arndb.de> <20090226200110.GA19523@ovro.caltech.edu> <200902262137.15169.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	Jan-Bernd Themann <THEMANN@de.ibm.com>,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ovro.ovro.caltech.edu ([192.100.16.2]:55488 "EHLO
	ovro.ovro.caltech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751896AbZBZVtW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 16:49:22 -0500
Content-Disposition: inline
In-Reply-To: <200902262137.15169.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 26, 2009 at 09:37:14PM +0100, Arnd Bergmann wrote:
> On Thursday 26 February 2009, Ira Snyder wrote:
> > On Thu, Feb 26, 2009 at 05:15:27PM +0100, Arnd Bergmann wrote:
> >
> > I think so too. I was just getting something working, and thought it
> > would be better to have it "out there" rather than be working on it
> > forever. I'll try to break things up as I have time.
> 
> Ok, perfect!
>  
> > For the "libraries", would you suggest breaking things into seperate
> > code files, and using EXPORT_SYMBOL_GPL()? I'm not very familiar with
> > doing that, I've mostly been writing code within the existing device
> > driver frameworks. Or do I need export symbol at all? I'm not sure...
> 
> You have both options. When you list each file as a separate module
> in the Makefile, you use EXPORT_SYMBOL_GPL to mark functions that
> get called by dependent modules, but this will work only in one way.
> 
> You can also link multiple files together into one module, although
> it is less common to link a single source file into multiple modules.
> 

Ok. I'm more familiar with the EXPORT_SYMBOL_GPL interface, so I'll do
that. If we decide it sucks later, we'll change it.

> > I always thought you were supposed to use packed for data structures
> > that are external to the system. I purposely designed the structures so
> > they wouldn't need padding.
> 
> That would only make sense for structures that are explicitly unaligned,
> like a register layout using
> 
> struct my_registers {
> 	__le16 first;
> 	__le32 second __attribute__((packed));
> 	__le16 third;
> };
> 
> Even here, I'd recommend listing the individual members as packed
> rather than the entire struct. Obviously if you layout the members
> in a sane way, you don't need either.
> 

Ok. I'll drop the __attribute__((packed)) and make sure there aren't
problems. I don't suspect any, though.

> > I mostly don't need it. In fact, the only place I'm using registers not
> > specific to the messaging unit is in the probe routine, where I setup
> > the 1GB window into host memory and setting up access to the guest
> > memory on the PCI bus.
> 
> You could add the registers you need for this to the "reg" property
> of your device, to be mapped with of_iomap.
> 
> If the registers for setting up this window don't logically fit
> into the same device as the one you already use, the cleanest
> solution would be to have another device just for this and then
> make a function call into that driver to set up the window.
> 

The registers are part of the board control registers. They don't fit at
all in the message unit. Doing this in the bootloader seems like a
logical place, but that would require any testers to flash a new U-Boot
image into their mpc8349emds boards.

The first set of access is used to set up a 1GB region in the memory map
that accesses the host's memory. Any reads/writes to addresses
0x80000000-0xc0000000 actually hit the host's memory.

The last access sets up PCI BAR1 to hit the memory from
dma_alloc_coherent(). The bootloader already sets up the window as 16K,
it just doesn't point it anywhere. Maybe this /should/ go into the
bootloader. Like above, it would require testers to flash a new U-Boot
image into their mpc8349emds boards.

> > Now, I wouldn't need to access these registers at all if the bootloader
> > could handle it. I just don't know if it is possible to have Linux not
> > use some memory that the bootloader allocated, other than with the
> > mem=XXX trick, which I'm sure wouldn't be acceptable. I've just used
> > regular RAM so this is portable to my custom board (mpc8349emds based)
> > and a regular mpc8349emds. I didn't want to change anything board
> > specific.
> > 
> > I would love to have the bootloader allocate (or reserve somewhere in
> > the memory map) 16K of RAM, and not be required to allocate it with
> > dma_alloc_coherent(). It would save me plenty of headaches.
> 
> I believe you can do that through the "memory" devices in the
> device tree, by leaving out a small part of the description of
> main memory, at putting it into the "reg" property of your own
> device.
> 

I'll explore this option. I didn't even know you could do this.  Is a
driver that requires the trick acceptable for mainline inclusion? Just
like setting up the 16K PCI window, this is very platform specific.

This limits the guest driver to systems which are able to change Linux's
view of their memory somehow. Maybe this isn't a problem.

> > Code complexity only. Also, it was easier to write 80-char lines with
> > something like:
> > 
> > vop_get_desc(vq, idx, &desc);
> > if (desc.flags & VOP_DESC_F_NEXT) {
> > 	/* do something */
> > }
> > 
> > Instead of:
> > if (le16_to_cpu(vq->desc[idx].flags) & VOP_DESC_F_NEXT) {
> > 	/* do something */
> > }
> > 
> > Plus, I didn't have to remember how many bits were in each field. I just
> > thought it made everything simpler to understand. Suggestions?
> 
> hmm, in this particular case, you could change the definition
> of VOP_DESC_F_NEXT to
> 
> #define VOP_DESC_F_NEXT cpu_to_le16(1)
> 
> and then do the code as the even simpler (source and object code wise)
> 
> if (vq->desc[idx].flags) & VOP_DESC_F_NEXT)
> 
> I'm not sure if you can do something along these lines for the other
> cases as well though.
> 

That's a good idea. It wouldn't fix the addresses, lengths, and next
fields, though. I'll make the change and see how bad it is, then report
back. It may not be so bad after all.

> > I used 3 so they would would align to 1024 byte boundaries within a 4K
> > page. Then the layout was 16K on the bus, each 4K page is a single
> > virtio-device, and each 1K block is a single virtqueue. The first 1K is
> > for virtio-device status and feature bits, etc.
> > 
> > Packing them differently isn't a problem. It was just easier to code
> > because setting up a window with the correct size is so platform
> > specific.
> 
> Ok. I guess the important question is what part of the code makes
> this decision. Ideally, the virtio-net glue would instantiate
> the device with the right number of queues.
> 

Yeah, virtio doesn't work that way.

The virtio drivers just call find_vq() with a different index for each
queue they want to use. You have no way of knowing how many queues each
virtio driver will want, unless you go read their source code.

virtio-net currently uses 3 queues, but we only support the first two.
The third is optional (for now...), and non-symmetric.

Thanks again,
Ira
