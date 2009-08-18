From: Avi Kivity <avi@redhat.com>
Subject: Re: [Alacrityvm-devel] [PATCH v3 3/6] vbus: add a "vbus-proxy" bus
 model for vbus_driver objects
Date: Wed, 19 Aug 2009 00:26:23 +0300
Message-ID: <4A8B1C7F.4060008@redhat.com>
References: <4A8965E0.8050608@gmail.com> <20090817174142.GA11140@redhat.com> <4A89BAC5.9040400@gmail.com> <20090818084606.GA13878@redhat.com> <20090818155329.GD31060@ovro.caltech.edu> <4A8ADC09.3030205@redhat.com> <20090818172752.GC17631@ovro.caltech.edu> <4A8AE918.5000109@redhat.com> <20090818182735.GD17631@ovro.caltech.edu> <4A8AF880.6080704@redhat.com> <20090818205919.GA1168@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Gregory Haskins <gregory.haskins@gmail.com>,
	kvm@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	Anthony Liguori <anthony@codemonkey.ws>,
	Ingo Molnar <mingo@elte.hu>,
	Gregory Haskins <ghaskins@novell.com>
To: "Ira W. Snyder" <iws@ovro.caltech.edu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751049AbZHRV00@vger.kernel.org>
In-Reply-To: <20090818205919.GA1168@ovro.caltech.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/18/2009 11:59 PM, Ira W. Snyder wrote:
> On a non shared-memory system (where the guest's RAM is not just a chunk
> of userspace RAM in the host system), virtio's management model seems to
> fall apart. Feature negotiation doesn't work as one would expect.
>    

In your case, virtio-net on the main board accesses PCI config space 
registers to perform the feature negotiation; software on your PCI cards 
needs to trap these config space accesses and respond to them according 
to virtio ABI.

(There's no real guest on your setup, right?  just a kernel running on 
and x86 system and other kernels running on the PCI cards?)

> This does appear to be solved by vbus, though I haven't written a
> vbus-over-PCI implementation, so I cannot be completely sure.
>    

Even if virtio-pci doesn't work out for some reason (though it should), 
you can write your own virtio transport and implement its config space 
however you like.

> I'm not at all clear on how to get feature negotiation to work on a
> system like mine. From my study of lguest and kvm (see below) it looks
> like userspace will need to be involved, via a miscdevice.
>    

I don't see why.  Is the kernel on the PCI cards in full control of all 
accesses?

> Ok. I thought I should at least express my concerns while we're
> discussing this, rather than being too late after finding the time to
> study the driver.
>
> Off the top of my head, I would think that transporting userspace
> addresses in the ring (for copy_(to|from)_user()) vs. physical addresses
> (for DMAEngine) might be a problem. Pinning userspace pages into memory
> for DMA is a bit of a pain, though it is possible.
>    

Oh, the ring doesn't transport userspace addresses.  It transports guest 
addresses, and it's up to vhost to do something with them.

Currently vhost supports two translation modes:

1. virtio address == host virtual address (using copy_to_user)
2. virtio address == offsetted host virtual address (using copy_to_user)

The latter mode is used for kvm guests (with multiple offsets, skipping 
some details).

I think you need to add a third mode, virtio address == host physical 
address (using dma engine).  Once you do that, and wire up the 
signalling, things should work.

> There is also the problem of different endianness between host and guest
> in virtio-net. The struct virtio_net_hdr (include/linux/virtio_net.h)
> defines fields in host byte order. Which totally breaks if the guest has
> a different endianness. This is a virtio-net problem though, and is not
> transport specific.
>    

Yeah.  You'll need to add byteswaps.

> I've browsed over both the kvm and lguest code, and it looks like they
> each re-invent a mechanism for transporting interrupts between the host
> and guest, using eventfd. They both do this by implementing a
> miscdevice, which is basically their management interface.
>
> See drivers/lguest/lguest_user.c (see write() and LHREQ_EVENTFD) and
> kvm-kmod-devel-88/x86/kvm_main.c (see kvm_vm_ioctl(), called via
> kvm_dev_ioctl()) for how they hook up eventfd's.
>
> I can now imagine how two userspace programs (host and guest) could work
> together to implement a management interface, including hotplug of
> devices, etc. Of course, this would basically reinvent the vbus
> management interface into a specific driver.
>    

You don't need anything in the guest userspace (virtio-net) side.

> I think this is partly what Greg is trying to abstract out into generic
> code. I haven't studied the actual data transport mechanisms in vbus,
> though I have studied virtio's transport mechanism. I think a generic
> management interface for virtio might be a good thing to consider,
> because it seems there are at least two implementations already: kvm and
> lguest.
>    

Management code in the kernel doesn't really help unless you plan to 
manage things with echo and cat.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.
