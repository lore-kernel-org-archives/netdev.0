From: "Ira W. Snyder" <iws@ovro.caltech.edu>
Subject: Re: [Alacrityvm-devel] [PATCH v3 3/6] vbus: add a "vbus-proxy" bus
	model for vbus_driver objects
Date: Tue, 18 Aug 2009 13:59:19 -0700
Message-ID: <20090818205919.GA1168@ovro.caltech.edu>
References: <4A8965E0.8050608@gmail.com> <20090817174142.GA11140@redhat.com> <4A89BAC5.9040400@gmail.com> <20090818084606.GA13878@redhat.com> <20090818155329.GD31060@ovro.caltech.edu> <4A8ADC09.3030205@redhat.com> <20090818172752.GC17631@ovro.caltech.edu> <4A8AE918.5000109@redhat.com> <20090818182735.GD17631@ovro.caltech.edu> <4A8AF880.6080704@redhat.com>
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
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4A8AF880.6080704@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 18, 2009 at 09:52:48PM +0300, Avi Kivity wrote:
> On 08/18/2009 09:27 PM, Ira W. Snyder wrote:
>>> I think in this case you want one side to be virtio-net (I'm guessing
>>> the x86) and the other side vhost-net (the ppc boards with the dma
>>> engine).  virtio-net on x86 would communicate with userspace on the ppc
>>> board to negotiate features and get a mac address, the fast path would
>>> be between virtio-net and vhost-net (which would use the dma engine to
>>> push and pull data).
>>>
>>>      
>>
>> Ah, that seems backwards, but it should work after vhost-net learns how
>> to use the DMAEngine API.
>>
>> I haven't studied vhost-net very carefully yet. As soon as I saw the
>> copy_(to|from)_user() I stopped reading, because it seemed useless for
>> my case. I'll look again and try to find where vhost-net supports
>> setting MAC addresses and other features.
>>    
>
> It doesn't; all it does is pump the rings, leaving everything else to  
> userspace.
>

Ok.

On a non shared-memory system (where the guest's RAM is not just a chunk
of userspace RAM in the host system), virtio's management model seems to
fall apart. Feature negotiation doesn't work as one would expect.

This does appear to be solved by vbus, though I haven't written a
vbus-over-PCI implementation, so I cannot be completely sure.

I'm not at all clear on how to get feature negotiation to work on a
system like mine. From my study of lguest and kvm (see below) it looks
like userspace will need to be involved, via a miscdevice.

>> Also, in my case I'd like to boot Linux with my rootfs over NFS. Is
>> vhost-net capable of this?
>>    
>
> It's just another network interface.  You'd need an initramfs though to  
> contain the needed userspace.
>

Ok. I'm using an initramfs already, so adding some more userspace to it
isn't a problem.

>> I've had Arnd, BenH, and Grant Likely (and others, privately) contact me
>> about devices they are working with that would benefit from something
>> like virtio-over-PCI. I'd like to see vhost-net be merged with the
>> capability to support my use case. There are plenty of others that would
>> benefit, not just myself.
>>
>> I'm not sure vhost-net is being written with this kind of future use in
>> mind. I'd hate to see it get merged, and then have to change the ABI to
>> support physical-device-to-device usage. It would be better to keep
>> future use in mind now, rather than try and hack it in later.
>>    
>
> Please review and comment then.  I'm fairly confident there won't be any  
> ABI issues since vhost-net does so little outside pumping the rings.
>

Ok. I thought I should at least express my concerns while we're
discussing this, rather than being too late after finding the time to
study the driver.

Off the top of my head, I would think that transporting userspace
addresses in the ring (for copy_(to|from)_user()) vs. physical addresses
(for DMAEngine) might be a problem. Pinning userspace pages into memory
for DMA is a bit of a pain, though it is possible.

There is also the problem of different endianness between host and guest
in virtio-net. The struct virtio_net_hdr (include/linux/virtio_net.h)
defines fields in host byte order. Which totally breaks if the guest has
a different endianness. This is a virtio-net problem though, and is not
transport specific.

> Note the signalling paths go through eventfd: when vhost-net wants the  
> other side to look at its ring, it tickles an eventfd which is supposed  
> to trigger an interrupt on the other side.  Conversely, when another  
> eventfd is signalled, vhost-net will look at the ring and process any  
> data there.  You'll need to wire your signalling to those eventfds,  
> either in userspace or in the kernel.
>

Ok. I've never used eventfd before, so that'll take yet more studying.

I've browsed over both the kvm and lguest code, and it looks like they
each re-invent a mechanism for transporting interrupts between the host
and guest, using eventfd. They both do this by implementing a
miscdevice, which is basically their management interface.

See drivers/lguest/lguest_user.c (see write() and LHREQ_EVENTFD) and
kvm-kmod-devel-88/x86/kvm_main.c (see kvm_vm_ioctl(), called via
kvm_dev_ioctl()) for how they hook up eventfd's.

I can now imagine how two userspace programs (host and guest) could work
together to implement a management interface, including hotplug of
devices, etc. Of course, this would basically reinvent the vbus
management interface into a specific driver.

I think this is partly what Greg is trying to abstract out into generic
code. I haven't studied the actual data transport mechanisms in vbus,
though I have studied virtio's transport mechanism. I think a generic
management interface for virtio might be a good thing to consider,
because it seems there are at least two implementations already: kvm and
lguest.

Thanks for answering my questions. It helps to talk with someone more
familiar with the issues than I am.

Ira
