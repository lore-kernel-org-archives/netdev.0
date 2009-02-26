From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC v2] virtio: add virtio-over-PCI driver
Date: Thu, 26 Feb 2009 21:37:14 +0100
Message-ID: <200902262137.15169.arnd@arndb.de>
References: <20090224000002.GA578@ovro.caltech.edu> <200902261715.28440.arnd@arndb.de> <20090226200110.GA19523@ovro.caltech.edu>
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
Received: from moutng.kundenserver.de ([212.227.126.187]:56285 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755576AbZBZUhv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 15:37:51 -0500
In-Reply-To: <20090226200110.GA19523@ovro.caltech.edu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 26 February 2009, Ira Snyder wrote:
> On Thu, Feb 26, 2009 at 05:15:27PM +0100, Arnd Bergmann wrote:
>
> I think so too. I was just getting something working, and thought it
> would be better to have it "out there" rather than be working on it
> forever. I'll try to break things up as I have time.

Ok, perfect!
 
> For the "libraries", would you suggest breaking things into seperate
> code files, and using EXPORT_SYMBOL_GPL()? I'm not very familiar with
> doing that, I've mostly been writing code within the existing device
> driver frameworks. Or do I need export symbol at all? I'm not sure...

You have both options. When you list each file as a separate module
in the Makefile, you use EXPORT_SYMBOL_GPL to mark functions that
get called by dependent modules, but this will work only in one way.

You can also link multiple files together into one module, although
it is less common to link a single source file into multiple modules.

> I always thought you were supposed to use packed for data structures
> that are external to the system. I purposely designed the structures so
> they wouldn't need padding.

That would only make sense for structures that are explicitly unaligned,
like a register layout using

struct my_registers {
	__le16 first;
	__le32 second __attribute__((packed));
	__le16 third;
};

Even here, I'd recommend listing the individual members as packed
rather than the entire struct. Obviously if you layout the members
in a sane way, you don't need either.

> I mostly don't need it. In fact, the only place I'm using registers not
> specific to the messaging unit is in the probe routine, where I setup
> the 1GB window into host memory and setting up access to the guest
> memory on the PCI bus.

You could add the registers you need for this to the "reg" property
of your device, to be mapped with of_iomap.

If the registers for setting up this window don't logically fit
into the same device as the one you already use, the cleanest
solution would be to have another device just for this and then
make a function call into that driver to set up the window.

> Now, I wouldn't need to access these registers at all if the bootloader
> could handle it. I just don't know if it is possible to have Linux not
> use some memory that the bootloader allocated, other than with the
> mem=XXX trick, which I'm sure wouldn't be acceptable. I've just used
> regular RAM so this is portable to my custom board (mpc8349emds based)
> and a regular mpc8349emds. I didn't want to change anything board
> specific.
> 
> I would love to have the bootloader allocate (or reserve somewhere in
> the memory map) 16K of RAM, and not be required to allocate it with
> dma_alloc_coherent(). It would save me plenty of headaches.

I believe you can do that through the "memory" devices in the
device tree, by leaving out a small part of the description of
main memory, at putting it into the "reg" property of your own
device.

> Code complexity only. Also, it was easier to write 80-char lines with
> something like:
> 
> vop_get_desc(vq, idx, &desc);
> if (desc.flags & VOP_DESC_F_NEXT) {
> 	/* do something */
> }
> 
> Instead of:
> if (le16_to_cpu(vq->desc[idx].flags) & VOP_DESC_F_NEXT) {
> 	/* do something */
> }
> 
> Plus, I didn't have to remember how many bits were in each field. I just
> thought it made everything simpler to understand. Suggestions?

hmm, in this particular case, you could change the definition
of VOP_DESC_F_NEXT to

#define VOP_DESC_F_NEXT cpu_to_le16(1)

and then do the code as the even simpler (source and object code wise)

if (vq->desc[idx].flags) & VOP_DESC_F_NEXT)

I'm not sure if you can do something along these lines for the other
cases as well though.

> I used 3 so they would would align to 1024 byte boundaries within a 4K
> page. Then the layout was 16K on the bus, each 4K page is a single
> virtio-device, and each 1K block is a single virtqueue. The first 1K is
> for virtio-device status and feature bits, etc.
> 
> Packing them differently isn't a problem. It was just easier to code
> because setting up a window with the correct size is so platform
> specific.

Ok. I guess the important question is what part of the code makes
this decision. Ideally, the virtio-net glue would instantiate
the device with the right number of queues.

> > > +/*
> > > + * This function abuses some of the scatterlist code and implements
> > > + * dma_map_sg() in such a way that we don't need to keep the scatterlist
> > > + * around in order to unmap it.
> > > + *
> > > + * It is also designed to never merge scatterlist entries, which is
> > > + * never what we want for virtio.
> > > + *
> > > + * When it is time to unmap the buffer, you can use dma_unmap_single() to
> > > + * unmap each entry in the chain. Get the address, length, and direction
> > > + * from the descriptors! (keep a local copy for speed)
> > > + */
> > 
> > Why is that an advantage over dma_unmap_sg?
> > 
> 
> When running dma_map_sg(), the scatterlist code is allowed to alter the
> scatterlist to store data it needs for dma_unmap_sg(), along with
> merging adjacent buffers, etc.
> 
> I don't want any of that behavior. The generic virtio code does not
> handle merging of buffers.
> 
> Also, all of the generic virtio code allocates its scatterlists on the
> stack. This means I cannot save the pointers between add_buf() and
> get_buf(). If I used dma_map_sg(), I'd have to allocate memory to copy
> the scatterlist, map it, and save the pointer. Later, retrieve the
> pointer, unmap it, and free the memory.
> 
> This is simpler than all of that.

Not sure if I'm following, but you seem to have put enough thought
into it ;-)

	Arnd <><
