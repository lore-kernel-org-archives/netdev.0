From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: Optimizing instruction-cache, more packets at each stage
Date: Sun, 24 Jan 2016 09:28:36 -0800
Message-ID: <56A509C4.3030706@gmail.com>
References: <1453330945.1223.329.camel@edumazet-glaptop2.roam.corp.google.com> <CALx6S34H67o64q3YoYiHQ+VSSuSsuSjBXmexSSXF_Hq8fcN0iw@mail.gmail.com> <20160121122730.6330a84b@redhat.com> <20160121.105401.1793719917762270884.davem@davemloft.net> <20160124152814.2ea5e99b@redhat.com> <20160124163846-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, tom@herbertland.com,
	eric.dumazet@gmail.com, gerlitz.or@gmail.com, edumazet@google.com,
	netdev@vger.kernel.org, alexander.duyck@gmail.com,
	alexei.starovoitov@gmail.com, borkmann@iogearbox.net,
	marek@cloudflare.com, hannes@stressinduktion.org, fw@strlen.de,
	pabeni@redhat.com, john.r.fastabend@intel.com, amirva@gmail.com,
	Daniel Borkmann <daniel@iogearbox.net>, vyasevich@gmail.com
To: "Michael S. Tsirkin" <mst@redhat.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:33839 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752194AbcAXR3C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jan 2016 12:29:02 -0500
Received: by mail-pf0-f173.google.com with SMTP id q63so71197633pfb.1
        for <netdev@vger.kernel.org>; Sun, 24 Jan 2016 09:29:01 -0800 (PST)
In-Reply-To: <20160124163846-mutt-send-email-mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-01-24 06:44 AM, Michael S. Tsirkin wrote:
> On Sun, Jan 24, 2016 at 03:28:14PM +0100, Jesper Dangaard Brouer wrote:
>> On Thu, 21 Jan 2016 10:54:01 -0800 (PST)
>> David Miller <davem@davemloft.net> wrote:
>>
>>> From: Jesper Dangaard Brouer <brouer@redhat.com>
>>> Date: Thu, 21 Jan 2016 12:27:30 +0100
>>>
>>>> eth_type_trans() does two things:
>>>>
>>>> 1) determine skb->protocol
>>>> 2) setup skb->pkt_type = PACKET_{BROADCAST,MULTICAST,OTHERHOST}
>>>>
>>>> Could the HW descriptor deliver the "proto", or perhaps just some bits
>>>> on the most common proto's?
>>>>
>>>> The skb->pkt_type don't need many bits.  And I bet the HW already have
>>>> the information.  The BROADCAST and MULTICAST indication are easy.  The
>>>> PACKET_OTHERHOST, can be turned around, by instead set a PACKET_HOST
>>>> indication, if the eth->h_dest match the devices dev->dev_addr (else a
>>>> SW compare is required).
>>>>
>>>> Is that doable in hardware?  
>>>
>>> I feel like we've had this discussion before several years ago.
>>>
>>> I think having just the protocol value would be enough.
>>>
>>> skb->pkt_type we could deal with by using always an accessor and
>>> evaluating it lazily.  Nothing needs it until we hit ip_rcv() or
>>> similar.
>>
>> First I thought, I liked the idea delaying the eval of skb->pkt_type.
>>
>> BUT then I realized, what if we take this even further.  What if we
>> actually use this information, for something useful, at this very
>> early RX stage.
>>
>> The information I'm interested in, from the HW descriptor, is if this
>> packet is NOT for local delivery.  If so, we can send the packet on a
>> "fast-forward" code path.
>>
>> Think about bridging packets to a guest OS.  Because we know very
>> early at RX (from packet HW descriptor) we might even avoid allocating
>> a SKB.  We could just "forward" the packet-page to the guest OS.
> 
> OK, so you would build a new kind of rx handler, and then
> e.g. macvtap could maybe get packets this way?
> Sure - e.g. vhost expects an skb at the moment
> but it won't be too hard to teach it that there's
> some other option.

+ Daniel, Vlad

If you use the macvtap device with the offload features you can "know"
via mac address that all packets on a specific hardware queue set belong
to a specific guest. (the queues are bound to a new netdev) This works
well with the passthru mode of macvlan. So you can do hardware bridging
this way. Supporting similar L3 modes probably not via macvlan has been
on my todo list for awhile but I haven't got there yet. ixgbe and fm10k
intel drivers support this now maybe others but those are the two I've
worked with recently.

The idea here is you remove any overhead from running bridge code, etc.
but still allowing users to stick netfilter, qos, etc hooks in the
datapath.

Also Daniel and I started working on a zero-copy RX mode which would
further help this by letting vhost-net pass down a set of dma buffers
we should probably get this working and submit it. iirc Vlad also
had the same sort of idea. The initial data for this looked good but
not as good as the solution below. However it had a similar issue as
below in that you just jumped over netfilter, qos, etc. Our initial
implementation used af_packet.

> 
> Or maybe some kind of stub skb that just has
> the correct length but no data is easier,
> I'm not sure.
> 

Another option is to use perfect filters to push traffic to a VF and
then map the VF into user space and use the vhost dpdk bits. This
works fairly well and gets pkts into the guest with little hypervisor
overhead and no(?) kernel network stack overhead. But the trade-off is
you cut out netfilter, qos, etc. This is really slick if you "trust"
your guest or have enough ACLs/etc in your hardware to "trust' the
guest.

A compromise is to use a VF and do not unbind it from the OS then
you can use macvtap again and map the netdev 1:1 to a guest. With
this mode you can still use your netfilter, qos, etc. but do l2,l3,l4
hardware forwarding with perfect filters.

As an aside if you don't like ethtool perfect filters I have a set of
patches to control this via 'tc' that I'll submit when net-next opens
up again which would let you support filtering on more field options
using offset:mask:value notation.

>> Taking Eric's idea, of remote CPUs, we could even send these
>> packet-pages to a remote CPU (e.g. where the guest OS is running),
>> without having touched a single cache-line in the packet-data.  I
>> would still bundle them up first, to amortize the (100-133ns) cost of
>> transferring something to another CPU.
> 
> This bundling would have to happen in a guest
> specific way then, so in vhost.
> I'd be curious to see what you come up with.
> 
>> The data-cache trick, would be to instruct prefetcher only to start
>> prefetching to L3 or L2, when these packet are destined for a remote
>> CPU.  At-least Intel CPUs have prefetch operations that specify only
>> L2/L3 cache.
>>
>>
>> Maybe, we need a combined solution.  Lazy eval skb->pkt_type, for
>> local delivery, but set the information if avail from HW desc.  And
>> fast page-forward don't even need a SKB.
>>
>> -- 
>> Best regards,
>>   Jesper Dangaard Brouer
>>   MSc.CS, Principal Kernel Engineer at Red Hat
>>   Author of http://www.iptv-analyzer.org
>>   LinkedIn: http://www.linkedin.com/in/brouer
