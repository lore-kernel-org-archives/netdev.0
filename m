From: "Ira W. Snyder" <iws@ovro.caltech.edu>
Subject: Re: [Alacrityvm-devel] [PATCH v3 3/6] vbus: add a "vbus-proxy" bus
	model for vbus_driver objects
Date: Tue, 18 Aug 2009 17:38:12 -0700
Message-ID: <20090819003812.GA11168@ovro.caltech.edu>
References: <4A89BAC5.9040400@gmail.com> <20090818084606.GA13878@redhat.com> <20090818155329.GD31060@ovro.caltech.edu> <4A8ADC09.3030205@redhat.com> <20090818172752.GC17631@ovro.caltech.edu> <4A8AE918.5000109@redhat.com> <20090818182735.GD17631@ovro.caltech.edu> <4A8AF880.6080704@redhat.com> <20090818205919.GA1168@ovro.caltech.edu> <4A8B1C7F.4060008@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Gregory Haskins <gregory.haskins@gmail.com>,
	kvm@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	Anthony Liguori <anthony@codemonkey.ws>,
	Ingo Molnar <mingo@elte.hu>,
	Gregory Haskins <ghaskins@novell.com>
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ovro.ovro.caltech.edu ([192.100.16.2]:53454 "EHLO
	ovro.ovro.caltech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750853AbZHSAiM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2009 20:38:12 -0400
Content-Disposition: inline
In-Reply-To: <4A8B1C7F.4060008@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 19, 2009 at 12:26:23AM +0300, Avi Kivity wrote:
> On 08/18/2009 11:59 PM, Ira W. Snyder wrote:
>> On a non shared-memory system (where the guest's RAM is not just a chunk
>> of userspace RAM in the host system), virtio's management model seems to
>> fall apart. Feature negotiation doesn't work as one would expect.
>>    
>
> In your case, virtio-net on the main board accesses PCI config space  
> registers to perform the feature negotiation; software on your PCI cards  
> needs to trap these config space accesses and respond to them according  
> to virtio ABI.
>

Is this "real PCI" (physical hardware) or "fake PCI" (software PCI
emulation) that you are describing?

The host (x86, PCI master) must use "real PCI" to actually configure the
boards, enable bus mastering, etc. Just like any other PCI device, such
as a network card.

On the guests (ppc, PCI agents) I cannot add/change PCI functions (the
last .[0-9] in the PCI address) nor can I change PCI BAR's once the
board has started. I'm pretty sure that would violate the PCI spec,
since the PCI master would need to re-scan the bus, and re-assign
addresses, which is a task for the BIOS.

> (There's no real guest on your setup, right?  just a kernel running on  
> and x86 system and other kernels running on the PCI cards?)
>

Yes, the x86 (PCI master) runs Linux (booted via PXELinux). The ppc's
(PCI agents) also run Linux (booted via U-Boot). They are independent
Linux systems, with a physical PCI interconnect.

The x86 has CONFIG_PCI=y, however the ppc's have CONFIG_PCI=n. Linux's
PCI stack does bad things as a PCI agent. It always assumes it is a PCI
master.

It is possible for me to enable CONFIG_PCI=y on the ppc's by removing
the PCI bus from their list of devices provided by OpenFirmware. They
can not access PCI via normal methods. PCI drivers cannot work on the
ppc's, because Linux assumes it is a PCI master.

To the best of my knowledge, I cannot trap configuration space accesses
on the PCI agents. I haven't needed that for anything I've done thus
far.

>> This does appear to be solved by vbus, though I haven't written a
>> vbus-over-PCI implementation, so I cannot be completely sure.
>>    
>
> Even if virtio-pci doesn't work out for some reason (though it should),  
> you can write your own virtio transport and implement its config space  
> however you like.
>

This is what I did with virtio-over-PCI. The way virtio-net negotiates
features makes this work non-intuitively.

>> I'm not at all clear on how to get feature negotiation to work on a
>> system like mine. From my study of lguest and kvm (see below) it looks
>> like userspace will need to be involved, via a miscdevice.
>>    
>
> I don't see why.  Is the kernel on the PCI cards in full control of all  
> accesses?
>

I'm not sure what you mean by this. Could you be more specific? This is
a normal, unmodified vanilla Linux kernel running on the PCI agents.

>> Ok. I thought I should at least express my concerns while we're
>> discussing this, rather than being too late after finding the time to
>> study the driver.
>>
>> Off the top of my head, I would think that transporting userspace
>> addresses in the ring (for copy_(to|from)_user()) vs. physical addresses
>> (for DMAEngine) might be a problem. Pinning userspace pages into memory
>> for DMA is a bit of a pain, though it is possible.
>>    
>
> Oh, the ring doesn't transport userspace addresses.  It transports guest  
> addresses, and it's up to vhost to do something with them.
>
> Currently vhost supports two translation modes:
>
> 1. virtio address == host virtual address (using copy_to_user)
> 2. virtio address == offsetted host virtual address (using copy_to_user)
>
> The latter mode is used for kvm guests (with multiple offsets, skipping  
> some details).
>
> I think you need to add a third mode, virtio address == host physical  
> address (using dma engine).  Once you do that, and wire up the  
> signalling, things should work.
>

Ok.

In my virtio-over-PCI patch, I hooked two virtio-net's together. I wrote
an algorithm to pair the tx/rx queues together. Since virtio-net
pre-fills its rx queues with buffers, I was able to use the DMA engine
to copy from the tx queue into the pre-allocated memory in the rx queue.

I have an intuitive idea about how I think vhost-net works in this case.

>> There is also the problem of different endianness between host and guest
>> in virtio-net. The struct virtio_net_hdr (include/linux/virtio_net.h)
>> defines fields in host byte order. Which totally breaks if the guest has
>> a different endianness. This is a virtio-net problem though, and is not
>> transport specific.
>>    
>
> Yeah.  You'll need to add byteswaps.
>

I wonder if Rusty would accept a new feature:
VIRTIO_F_NET_LITTLE_ENDIAN, which would allow the virtio-net driver to
use LE for all of it's multi-byte fields.

I don't think the transport should have to care about the endianness.

>> I've browsed over both the kvm and lguest code, and it looks like they
>> each re-invent a mechanism for transporting interrupts between the host
>> and guest, using eventfd. They both do this by implementing a
>> miscdevice, which is basically their management interface.
>>
>> See drivers/lguest/lguest_user.c (see write() and LHREQ_EVENTFD) and
>> kvm-kmod-devel-88/x86/kvm_main.c (see kvm_vm_ioctl(), called via
>> kvm_dev_ioctl()) for how they hook up eventfd's.
>>
>> I can now imagine how two userspace programs (host and guest) could work
>> together to implement a management interface, including hotplug of
>> devices, etc. Of course, this would basically reinvent the vbus
>> management interface into a specific driver.
>>    
>
> You don't need anything in the guest userspace (virtio-net) side.
>
>> I think this is partly what Greg is trying to abstract out into generic
>> code. I haven't studied the actual data transport mechanisms in vbus,
>> though I have studied virtio's transport mechanism. I think a generic
>> management interface for virtio might be a good thing to consider,
>> because it seems there are at least two implementations already: kvm and
>> lguest.
>>    
>
> Management code in the kernel doesn't really help unless you plan to  
> manage things with echo and cat.
>

True. It's slowpath setup, so I don't care how fast it is. For reasons
outside my control, the x86 (PCI master) is running a RHEL5 system. This
means glibc-2.5, which doesn't have eventfd support, AFAIK. I could try
and push for an upgrade. This obviously makes cat/echo really nice, it
doesn't depend on glibc, only the kernel version.

I don't give much weight to the above, because I can use the eventfd
syscalls directly, without glibc support. It is just more painful.

Ira
