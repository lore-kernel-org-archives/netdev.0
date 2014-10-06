From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next PATCH v1 1/3] net: sched: af_packet support for direct
 ring access
Date: Mon, 06 Oct 2014 08:01:52 -0700
Message-ID: <5432AEE0.9000600@intel.com>
References: <20141006000629.32055.2295.stgit@nitbit.x32> <20141006002951.GA24376@breakpoint.cc> <5431EC82.7010305@gmail.com> <543265A5.8000606@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>, gerlitz.or@gmail.com,
	hannes@stressinduktion.org, netdev@vger.kernel.org,
	john.ronciak@intel.com, amirv@mellanox.com, eric.dumazet@gmail.com,
	danny.zhou@intel.com
To: Daniel Borkmann <dborkman@redhat.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Jesper Dangaard Brouer <jbrouer@redhat.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:2878 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752723AbaJFPEt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Oct 2014 11:04:49 -0400
In-Reply-To: <543265A5.8000606@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/06/2014 02:49 AM, Daniel Borkmann wrote:
> Hi John,
> 
> On 10/06/2014 03:12 AM, John Fastabend wrote:
>> On 10/05/2014 05:29 PM, Florian Westphal wrote:
>>> John Fastabend <john.fastabend@gmail.com> wrote:
>>>> There is one critical difference when running with these interfaces
>>>> vs running without them. In the normal case the af_packet module
>>>> uses a standard descriptor format exported by the af_packet user
>>>> space headers. In this model because we are working directly with
>>>> driver queues the descriptor format maps to the descriptor format
>>>> used by the device. User space applications can learn device
>>>> information from the socket option PACKET_DEV_DESC_INFO which
>>>> should provide enough details to extrapulate the descriptor formats.
>>>> Although this adds some complexity to user space it removes the
>>>> requirement to copy descriptor fields around.
>>>
>>> I find it very disappointing that we seem to have to expose such
>>> hardware specific details to userspace via hw-independent interface.
>>
>> Well it was only for convenience if it doesn't fit as a socket
>> option we can remove it. We can look up the device using the netdev
>> name from the bind call. I see your point though so if there is
>> consensus that this is not needed that is fine.
>>
>>> How big of a cost are we talking about when you say that it 'removes
>>> the requirement to copy descriptor fields'?
>>
>> This was likely a poor description. If you want to let user space
>> poll on the ring (without using system calls or interrupts) then
>> I don't see how you can _not_ expose the ring directly complete with
>> the vendor descriptor formats.
> 
> But how big is the concrete performance degradation you're seeing if you
> use an e.g. `netmap-alike` Linux-own variant as a hw-neutral interface
> that does *not* directly expose hw descriptor formats to user space?

If we don't directly expose the hardware descriptor formats then we
need to somehow kick the driver when we want it to do the copy from
the driver descriptor format to the common descriptor format.

This requires a system call as far as I can tell. Which has unwanted
overhead. I can micro-benchmark this if its helpful. But if we dredge
up Jesper's slides here we are really counting cycles so even small
numbers count if we want to hit line rate in a user space application
with 40Gpbs hardware.

> 
> With 1 core netmap does 10G line-rate on 64b; I don't know their numbers
> on 40G when run on decent hardware though.
> 
> It would really be great if we have something vendor neutral exposed as
> a stable ABI and could leverage emerging infrastructure we already have
> in the kernel such as eBPF and recent qdisc batching for raw sockets
> instead of reinventing the wheels. (Don't get me wrong, I would love to
> see AF_PACKET improved ...)

I don't think the interface is vendor specific. It does require some
knowledge of the hardware descriptor layout though. It is though vendor
neutral from my point of view. I provided the ixgbe patch simple because
I'm most familiar with it and have a NIC here. If someone wants to send me
a Mellanox NIC I can give it a try although I was hoping to recruit Or or
Amir? The only hardware feature required is flow classification to queues
which seems to be common across 10Gbps and 40/100Gbps devices. So most
of the drivers should be able to support this.

If your worried driver writers will implement the interface but not make
their descriptor formats easily available I considered putting the layout
in a header file in the uapi somewhere. Then we could just reject any
implementation that doesn't include the header file needed to use it
from user space.

With regards to leveraging eBPF and qdisc batching I don't see how this
works with direct DMA and polling. Needed to give the lowest overhead
between kernel and user space. In this case we want to use the hardware
to do the filtering that would normally be done for eBPF and for many
use cases the hardware flow classifiers is sufficient. 

We already added a qdisc bypass option I see this as taking this path
further. I believe there is room for a continuum here. For basic cases
use af_packet v1,v2 for mmap rings but using common descriptors use
af_packet v3 and set QOS_BYASS. For absolute lowest overhead and
specific applications that don't need QOS, eBPF use this interface.

Thanks.

> 
> Thanks,
> Daniel
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
