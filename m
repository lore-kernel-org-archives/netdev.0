From: Tom Herbert <tom@herbertland.com>
Subject: Re: Optimizing instruction-cache, more packets at each stage
Date: Sun, 24 Jan 2016 15:50:46 -0800
Message-ID: <CALx6S37Gu+vb8+771q+2y6Tkrh_fVMU_XEAXynRQ1O=BhxvLwA@mail.gmail.com>
References: <1453330945.1223.329.camel@edumazet-glaptop2.roam.corp.google.com>
	<CALx6S34H67o64q3YoYiHQ+VSSuSsuSjBXmexSSXF_Hq8fcN0iw@mail.gmail.com>
	<20160121122730.6330a84b@redhat.com>
	<20160121.105401.1793719917762270884.davem@davemloft.net>
	<20160124152814.2ea5e99b@redhat.com>
	<CALx6S36Tq+4wwC5Z=6cuBt6k3beb_d7gy_ofdWf86KCxLjSaew@mail.gmail.com>
	<56A544F9.9000501@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <borkmann@iogearbox.net>,
	Marek Majkowski <marek@cloudflare.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Paolo Abeni <pabeni@redhat.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Amir Vadai <amirva@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:36636 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751501AbcAXXur (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jan 2016 18:50:47 -0500
Received: by mail-ig0-f175.google.com with SMTP id z14so24643367igp.1
        for <netdev@vger.kernel.org>; Sun, 24 Jan 2016 15:50:46 -0800 (PST)
In-Reply-To: <56A544F9.9000501@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 24, 2016 at 1:41 PM, John Fastabend
<john.fastabend@gmail.com> wrote:
> On 16-01-24 12:09 PM, Tom Herbert wrote:
>> On Sun, Jan 24, 2016 at 6:28 AM, Jesper Dangaard Brouer
>> <brouer@redhat.com> wrote:
>>> On Thu, 21 Jan 2016 10:54:01 -0800 (PST)
>>> David Miller <davem@davemloft.net> wrote:
>>>
>>>> From: Jesper Dangaard Brouer <brouer@redhat.com>
>>>> Date: Thu, 21 Jan 2016 12:27:30 +0100
>>>>
>>>>> eth_type_trans() does two things:
>>>>>
>>>>> 1) determine skb->protocol
>>>>> 2) setup skb->pkt_type = PACKET_{BROADCAST,MULTICAST,OTHERHOST}
>>>>>
>>>>> Could the HW descriptor deliver the "proto", or perhaps just some bits
>>>>> on the most common proto's?
>>>>>
>>>>> The skb->pkt_type don't need many bits.  And I bet the HW already have
>>>>> the information.  The BROADCAST and MULTICAST indication are easy.  The
>>>>> PACKET_OTHERHOST, can be turned around, by instead set a PACKET_HOST
>>>>> indication, if the eth->h_dest match the devices dev->dev_addr (else a
>>>>> SW compare is required).
>>>>>
>>>>> Is that doable in hardware?
>>>>
>>>> I feel like we've had this discussion before several years ago.
>>>>
>>>> I think having just the protocol value would be enough.
>>>>
>>>> skb->pkt_type we could deal with by using always an accessor and
>>>> evaluating it lazily.  Nothing needs it until we hit ip_rcv() or
>>>> similar.
>>>
>>> First I thought, I liked the idea delaying the eval of skb->pkt_type.
>>>
>>> BUT then I realized, what if we take this even further.  What if we
>>> actually use this information, for something useful, at this very
>>> early RX stage.
>>>
>>> The information I'm interested in, from the HW descriptor, is if this
>>> packet is NOT for local delivery.  If so, we can send the packet on a
>>> "fast-forward" code path.
>>>
>>> Think about bridging packets to a guest OS.  Because we know very
>>> early at RX (from packet HW descriptor) we might even avoid allocating
>>> a SKB.  We could just "forward" the packet-page to the guest OS.
>>>
>>> Taking Eric's idea, of remote CPUs, we could even send these
>>> packet-pages to a remote CPU (e.g. where the guest OS is running),
>>> without having touched a single cache-line in the packet-data.  I
>>> would still bundle them up first, to amortize the (100-133ns) cost of
>>> transferring something to another CPU.
>>>
>> You mean like RPS/RFS/aRFS/flow_director already does (except for the
>> zero-touch part)?
>>
>
> You could also look at ATR in the ixgbe/i40e drivers which on xmit
> uses a tuple to try and force the hardware to recv on the same queue
> pair as the sending side. The idea being you can bind tx/rx queue
> pairs to a core and send/recv on the same core which tends to be an
> OK strategy although not always. It is sometimes better to tx and rx
> on separate cores.
>
Right, we have seen cases where HW attempting to autonomously bind
tx/rx to the same CPU does nothing more than create a whole bunch of
OOO packets and a big mess otherwise.  The better approach is to allow
the stack to indicate to HW where *it* wants received packets for each
flow to go. If it wants to bind tx/rx it can do that, if it wants to
split that's fine to. This is possible with aRFS, and in fact I don't
see any reason why virtual drivers shouldn't support also aRFS to
allow guests control over steering within their CPUs.

>>> The data-cache trick, would be to instruct prefetcher only to start
>>> prefetching to L3 or L2, when these packet are destined for a remote
>>> CPU.  At-least Intel CPUs have prefetch operations that specify only
>>> L2/L3 cache.
>>>
>>>
>>> Maybe, we need a combined solution.  Lazy eval skb->pkt_type, for
>>> local delivery, but set the information if avail from HW desc.  And
>>> fast page-forward don't even need a SKB.
>>>
>>> --
>>> Best regards,
>>>   Jesper Dangaard Brouer
>>>   MSc.CS, Principal Kernel Engineer at Red Hat
>>>   Author of http://www.iptv-analyzer.org
>>>   LinkedIn: http://www.linkedin.com/in/brouer
>
