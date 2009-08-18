From: Avi Kivity <avi@redhat.com>
Subject: Re: [Alacrityvm-devel] [PATCH v3 3/6] vbus: add a "vbus-proxy" bus
 model for vbus_driver objects
Date: Tue, 18 Aug 2009 21:52:48 +0300
Message-ID: <4A8AF880.6080704@redhat.com>
References: <20090815103243.GA26749@elte.hu> <4A870964.9090408@codemonkey.ws> <4A8965E0.8050608@gmail.com> <20090817174142.GA11140@redhat.com> <4A89BAC5.9040400@gmail.com> <20090818084606.GA13878@redhat.com> <20090818155329.GD31060@ovro.caltech.edu> <4A8ADC09.3030205@redhat.com> <20090818172752.GC17631@ovro.caltech.edu> <4A8AE918.5000109@redhat.com> <20090818182735.GD17631@ovro.caltech.edu>
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
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751375AbZHRSw7@vger.kernel.org>
In-Reply-To: <20090818182735.GD17631@ovro.caltech.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/18/2009 09:27 PM, Ira W. Snyder wrote:
>> I think in this case you want one side to be virtio-net (I'm guessing
>> the x86) and the other side vhost-net (the ppc boards with the dma
>> engine).  virtio-net on x86 would communicate with userspace on the ppc
>> board to negotiate features and get a mac address, the fast path would
>> be between virtio-net and vhost-net (which would use the dma engine to
>> push and pull data).
>>
>>      
>
> Ah, that seems backwards, but it should work after vhost-net learns how
> to use the DMAEngine API.
>
> I haven't studied vhost-net very carefully yet. As soon as I saw the
> copy_(to|from)_user() I stopped reading, because it seemed useless for
> my case. I'll look again and try to find where vhost-net supports
> setting MAC addresses and other features.
>    

It doesn't; all it does is pump the rings, leaving everything else to 
userspace.

> Also, in my case I'd like to boot Linux with my rootfs over NFS. Is
> vhost-net capable of this?
>    

It's just another network interface.  You'd need an initramfs though to 
contain the needed userspace.

> I've had Arnd, BenH, and Grant Likely (and others, privately) contact me
> about devices they are working with that would benefit from something
> like virtio-over-PCI. I'd like to see vhost-net be merged with the
> capability to support my use case. There are plenty of others that would
> benefit, not just myself.
>
> I'm not sure vhost-net is being written with this kind of future use in
> mind. I'd hate to see it get merged, and then have to change the ABI to
> support physical-device-to-device usage. It would be better to keep
> future use in mind now, rather than try and hack it in later.
>    

Please review and comment then.  I'm fairly confident there won't be any 
ABI issues since vhost-net does so little outside pumping the rings.

Note the signalling paths go through eventfd: when vhost-net wants the 
other side to look at its ring, it tickles an eventfd which is supposed 
to trigger an interrupt on the other side.  Conversely, when another 
eventfd is signalled, vhost-net will look at the ring and process any 
data there.  You'll need to wire your signalling to those eventfds, 
either in userspace or in the kernel.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.
