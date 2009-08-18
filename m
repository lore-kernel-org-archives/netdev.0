From: "Ira W. Snyder" <iws@ovro.caltech.edu>
Subject: Re: [Alacrityvm-devel] [PATCH v3 3/6] vbus: add a "vbus-proxy" bus
	model for vbus_driver objects
Date: Tue, 18 Aug 2009 16:24:57 -0700
Message-ID: <20090818232457.GB1168@ovro.caltech.edu>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A870964.9090408@codemonkey.ws> <4A8965E0.8050608@gmail.com> <20090817174142.GA11140@redhat.com> <4A89BAC5.9040400@gmail.com> <20090818084606.GA13878@redhat.com> <20090818155329.GD31060@ovro.caltech.edu> <20090818205748.GC20393@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gregory Haskins <gregory.haskins@gmail.com>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	Avi Kivity <avi@redhat.com>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Ingo Molnar <mingo@elte.hu>,
	Gregory Haskins <ghaskins@novell.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090818205748.GC20393@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 18, 2009 at 11:57:48PM +0300, Michael S. Tsirkin wrote:
> On Tue, Aug 18, 2009 at 08:53:29AM -0700, Ira W. Snyder wrote:
> > I think Greg is referring to something like my virtio-over-PCI patch.
> > I'm pretty sure that vhost is completely useless for my situation. I'd
> > like to see vhost work for my use, so I'll try to explain what I'm
> > doing.
> > 
> > I've got a system where I have about 20 computers connected via PCI. The
> > PCI master is a normal x86 system, and the PCI agents are PowerPC
> > systems. The PCI agents act just like any other PCI card, except they
> > are running Linux, and have their own RAM and peripherals.
> > 
> > I wrote a custom driver which imitated a network interface and a serial
> > port. I tried to push it towards mainline, and DavidM rejected it, with
> > the argument, "use virtio, don't add another virtualization layer to the
> > kernel." I think he has a decent argument, so I wrote virtio-over-PCI.
> > 
> > Now, there are some things about virtio that don't work over PCI.
> > Mainly, memory is not truly shared. It is extremely slow to access
> > memory that is "far away", meaning "across the PCI bus." This can be
> > worked around by using a DMA controller to transfer all data, along with
> > an intelligent scheme to perform only writes across the bus. If you're
> > careful, reads are never needed.
> > 
> > So, in my system, copy_(to|from)_user() is completely wrong.
> > There is no userspace, only a physical system.
> 
> Can guests do DMA to random host memory? Or is there some kind of IOMMU
> and DMA API involved? If the later, then note that you'll still need
> some kind of driver for your device. The question we need to ask
> ourselves then is whether this driver can reuse bits from vhost.
> 

Mostly. All of my systems are 32 bit (both x86 and ppc). From the view
of the ppc (and DMAEngine), I can view the first 1GB of host memory.

This limited view is due to address space limitations on the ppc. The
view of PCI memory must live somewhere in the ppc address space, along
with the ppc's SDRAM, flash, and other peripherals. Since this is a
32bit processor, I only have 4GB of address space to work with.

The PCI address space could be up to 4GB in size. If I tried to allow
the ppc boards to view all 4GB of PCI address space, then they would
have no address space left for their onboard SDRAM, etc.

Hopefully that makes sense.

I use dma_set_mask(dev, DMA_BIT_MASK(30) on the host system to ensure
that when dma_map_sg() is called, it returns addresses that can be
accessed directly by the device.

The DMAEngine can access any local (ppc) memory without any restriction.

I have used the Linux DMAEngine API (include/linux/dmaengine.h) to
handle all data transfer across the PCI bus. The Intel I/OAT (and many
others) use the same API.

> > In fact, because normal x86 computers
> > do not have DMA controllers, the host system doesn't actually handle any
> > data transfer!
> 
> Is it true that PPC has to initiate all DMA then? How do you
> manage not to do DMA reads then?
> 

Yes, the ppc initiates all DMA. It handles all data transfer (both reads
and writes) across the PCI bus, for speed reasons. A CPU cannot create
burst transactions on the PCI bus. This is the reason that most (all?)
network cards (as a familiar example) use DMA to transfer packet
contents into RAM.

Sorry if I made a confusing statement ("no reads are necessary")
earlier. What I meant to say was: If you are very careful, it is not
necessary for the CPU to do any reads over the PCI bus to maintain
state. Writes are the only necessary CPU-initiated transaction.

I implemented this in my virtio-over-PCI patch, copying as much as
possible from the virtio vring structure. The descriptors in the rings
are only changed by one "side" of the connection, therefore they can be
cached as they are written (via the CPU) across the PCI bus, with the
knowledge that both sides will have a consistent view.

I'm sorry, this is hard to explain via email. It is much easier in a
room with a whiteboard. :)

> > I used virtio-net in both the guest and host systems in my example
> > virtio-over-PCI patch, and succeeded in getting them to communicate.
> > However, the lack of any setup interface means that the devices must be
> > hardcoded into both drivers, when the decision could be up to userspace.
> > I think this is a problem that vbus could solve.
> 
> What you describe (passing setup from host to guest) seems like
> a feature that guest devices need to support. It seems unlikely that
> vbus, being a transport layer, can address this.
> 

I think I explained this poorly as well.

Virtio needs two things to function:
1) a set of descriptor rings (1 or more)
2) a way to kick each ring.

With the amount of space available in the ppc's PCI BAR's (which point
at a small chunk of SDRAM), I could potentially make ~6 virtqueues + 6
kick interrupts available.

Right now, my virtio-over-PCI driver hardcoded the first and second
virtqueues to be for virtio-net only, and nothing else.

What if the user wanted 2 virtio-console and 2 virtio-net? They'd have
to change the driver, because virtio doesn't have much of a management
interface. Vbus does have a management interface: you create devices via
configfs. The vbus-connector on the guest notices new devices, and
triggers hotplug events on the guest.

As far as I understand it, vbus is a bus model, not just a transport
layer.

> > 
> > For my own selfish reasons (I don't want to maintain an out-of-tree
> > driver) I'd like to see *something* useful in mainline Linux. I'm happy
> > to answer questions about my setup, just ask.
> > 
> > Ira
> 
> Thanks Ira, I'll think about it.
> A couple of questions:
> - Could you please describe what kind of communication needs to happen?
> - I'm not familiar with DMA engine in question. I'm guessing it's the
>   usual thing: in/out buffers need to be kernel memory, interface is
>   asynchronous, small limited number of outstanding requests? Is there a
>   userspace interface for it and if yes how does it work?
> 

The DMA engine can handle transferring from any two physical addresses,
as seen from the ppc address map. The things of interest are:
1) ppc sdram
2) host sdram (first 1GB only, explained above)

The Linux DMAEngine API allows you to do sync or async requests with
callbacks, and an unlimited number of outstanding requests (until you
exhaust memory).

The interface is in-kernel only. See include/linux/dmaengine.h for the
details, but the most important part is dma_async_memcpy_buf_to_buf(),
which will copy between two kernel virtual addresses.

It is trivial to code up an implementation which will transfer between
physical addresses instead, which I found much more convenient in my
code. I'm happy to provide the function if/when needed.

Ira
