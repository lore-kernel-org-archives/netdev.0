From: Avi Kivity <avi@redhat.com>
Subject: Re: [Alacrityvm-devel] [PATCH v3 3/6] vbus: add a "vbus-proxy" bus
 model for vbus_driver objects
Date: Wed, 19 Aug 2009 08:40:33 +0300
Message-ID: <4A8B9051.3020505@redhat.com>
References: <4A89BAC5.9040400@gmail.com> <20090818084606.GA13878@redhat.com> <20090818155329.GD31060@ovro.caltech.edu> <4A8ADC09.3030205@redhat.com> <20090818172752.GC17631@ovro.caltech.edu> <4A8AE918.5000109@redhat.com> <20090818182735.GD17631@ovro.caltech.edu> <4A8AF880.6080704@redhat.com> <20090818205919.GA1168@ovro.caltech.edu> <4A8B1C7F.4060008@redhat.com> <20090819003812.GA11168@ovro.caltech.edu>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:53154 "EHLO mx2.redhat.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750753AbZHSFkd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2009 01:40:33 -0400
In-Reply-To: <20090819003812.GA11168@ovro.caltech.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/19/2009 03:38 AM, Ira W. Snyder wrote:
> On Wed, Aug 19, 2009 at 12:26:23AM +0300, Avi Kivity wrote:
>    
>> On 08/18/2009 11:59 PM, Ira W. Snyder wrote:
>>      
>>> On a non shared-memory system (where the guest's RAM is not just a chunk
>>> of userspace RAM in the host system), virtio's management model seems to
>>> fall apart. Feature negotiation doesn't work as one would expect.
>>>
>>>        
>> In your case, virtio-net on the main board accesses PCI config space
>> registers to perform the feature negotiation; software on your PCI cards
>> needs to trap these config space accesses and respond to them according
>> to virtio ABI.
>>
>>      
> Is this "real PCI" (physical hardware) or "fake PCI" (software PCI
> emulation) that you are describing?
>
>    

Real PCI.

> The host (x86, PCI master) must use "real PCI" to actually configure the
> boards, enable bus mastering, etc. Just like any other PCI device, such
> as a network card.
>
> On the guests (ppc, PCI agents) I cannot add/change PCI functions (the
> last .[0-9] in the PCI address) nor can I change PCI BAR's once the
> board has started. I'm pretty sure that would violate the PCI spec,
> since the PCI master would need to re-scan the bus, and re-assign
> addresses, which is a task for the BIOS.
>    

Yes.  Can the boards respond to PCI config space cycles coming from the 
host, or is the config space implemented in silicon and immutable?  
(reading on, I see the answer is no).  virtio-pci uses the PCI config 
space to configure the hardware.

>> (There's no real guest on your setup, right?  just a kernel running on
>> and x86 system and other kernels running on the PCI cards?)
>>
>>      
> Yes, the x86 (PCI master) runs Linux (booted via PXELinux). The ppc's
> (PCI agents) also run Linux (booted via U-Boot). They are independent
> Linux systems, with a physical PCI interconnect.
>
> The x86 has CONFIG_PCI=y, however the ppc's have CONFIG_PCI=n. Linux's
> PCI stack does bad things as a PCI agent. It always assumes it is a PCI
> master.
>
> It is possible for me to enable CONFIG_PCI=y on the ppc's by removing
> the PCI bus from their list of devices provided by OpenFirmware. They
> can not access PCI via normal methods. PCI drivers cannot work on the
> ppc's, because Linux assumes it is a PCI master.
>
> To the best of my knowledge, I cannot trap configuration space accesses
> on the PCI agents. I haven't needed that for anything I've done thus
> far.
>
>    

Well, if you can't do that, you can't use virtio-pci on the host.  
You'll need another virtio transport (equivalent to "fake pci" you 
mentioned above).

>>> This does appear to be solved by vbus, though I haven't written a
>>> vbus-over-PCI implementation, so I cannot be completely sure.
>>>
>>>        
>> Even if virtio-pci doesn't work out for some reason (though it should),
>> you can write your own virtio transport and implement its config space
>> however you like.
>>
>>      
> This is what I did with virtio-over-PCI. The way virtio-net negotiates
> features makes this work non-intuitively.
>    

I think you tried to take two virtio-nets and make them talk together?  
That won't work.  You need the code from qemu to talk to virtio-net 
config space, and vhost-net to pump the rings.

>>> I'm not at all clear on how to get feature negotiation to work on a
>>> system like mine. From my study of lguest and kvm (see below) it looks
>>> like userspace will need to be involved, via a miscdevice.
>>>
>>>        
>> I don't see why.  Is the kernel on the PCI cards in full control of all
>> accesses?
>>
>>      
> I'm not sure what you mean by this. Could you be more specific? This is
> a normal, unmodified vanilla Linux kernel running on the PCI agents.
>    

I meant, does board software implement the config space accesses issued 
from the host, and it seems the answer is no.


> In my virtio-over-PCI patch, I hooked two virtio-net's together. I wrote
> an algorithm to pair the tx/rx queues together. Since virtio-net
> pre-fills its rx queues with buffers, I was able to use the DMA engine
> to copy from the tx queue into the pre-allocated memory in the rx queue.
>
>    

Please find a name other than virtio-over-PCI since it conflicts with 
virtio-pci.  You're tunnelling virtio config cycles (which are usually 
done on pci config cycles) on a new protocol which is itself tunnelled 
over PCI shared memory.

>>>
>>>        
>> Yeah.  You'll need to add byteswaps.
>>
>>      
> I wonder if Rusty would accept a new feature:
> VIRTIO_F_NET_LITTLE_ENDIAN, which would allow the virtio-net driver to
> use LE for all of it's multi-byte fields.
>
> I don't think the transport should have to care about the endianness.
>    

Given this is not mainstream use, it would have to have zero impact when 
configured out.

> True. It's slowpath setup, so I don't care how fast it is. For reasons
> outside my control, the x86 (PCI master) is running a RHEL5 system. This
> means glibc-2.5, which doesn't have eventfd support, AFAIK. I could try
> and push for an upgrade. This obviously makes cat/echo really nice, it
> doesn't depend on glibc, only the kernel version.
>
> I don't give much weight to the above, because I can use the eventfd
> syscalls directly, without glibc support. It is just more painful.
>    

The x86 side only needs to run virtio-net, which is present in RHEL 
5.3.  You'd only need to run virtio-tunnel or however it's called.  All 
the eventfd magic takes place on the PCI agents.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

