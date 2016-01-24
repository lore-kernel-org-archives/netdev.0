From: Tom Herbert <tom@herbertland.com>
Subject: Re: Optimizing instruction-cache, more packets at each stage
Date: Sun, 24 Jan 2016 12:09:00 -0800
Message-ID: <CALx6S36Tq+4wwC5Z=6cuBt6k3beb_d7gy_ofdWf86KCxLjSaew@mail.gmail.com>
References: <1453330945.1223.329.camel@edumazet-glaptop2.roam.corp.google.com>
	<CALx6S34H67o64q3YoYiHQ+VSSuSsuSjBXmexSSXF_Hq8fcN0iw@mail.gmail.com>
	<20160121122730.6330a84b@redhat.com>
	<20160121.105401.1793719917762270884.davem@davemloft.net>
	<20160124152814.2ea5e99b@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
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
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:35309 "EHLO
	mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751582AbcAXUJC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jan 2016 15:09:02 -0500
Received: by mail-io0-f176.google.com with SMTP id 77so133208297ioc.2
        for <netdev@vger.kernel.org>; Sun, 24 Jan 2016 12:09:01 -0800 (PST)
In-Reply-To: <20160124152814.2ea5e99b@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 24, 2016 at 6:28 AM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> On Thu, 21 Jan 2016 10:54:01 -0800 (PST)
> David Miller <davem@davemloft.net> wrote:
>
>> From: Jesper Dangaard Brouer <brouer@redhat.com>
>> Date: Thu, 21 Jan 2016 12:27:30 +0100
>>
>> > eth_type_trans() does two things:
>> >
>> > 1) determine skb->protocol
>> > 2) setup skb->pkt_type = PACKET_{BROADCAST,MULTICAST,OTHERHOST}
>> >
>> > Could the HW descriptor deliver the "proto", or perhaps just some bits
>> > on the most common proto's?
>> >
>> > The skb->pkt_type don't need many bits.  And I bet the HW already have
>> > the information.  The BROADCAST and MULTICAST indication are easy.  The
>> > PACKET_OTHERHOST, can be turned around, by instead set a PACKET_HOST
>> > indication, if the eth->h_dest match the devices dev->dev_addr (else a
>> > SW compare is required).
>> >
>> > Is that doable in hardware?
>>
>> I feel like we've had this discussion before several years ago.
>>
>> I think having just the protocol value would be enough.
>>
>> skb->pkt_type we could deal with by using always an accessor and
>> evaluating it lazily.  Nothing needs it until we hit ip_rcv() or
>> similar.
>
> First I thought, I liked the idea delaying the eval of skb->pkt_type.
>
> BUT then I realized, what if we take this even further.  What if we
> actually use this information, for something useful, at this very
> early RX stage.
>
> The information I'm interested in, from the HW descriptor, is if this
> packet is NOT for local delivery.  If so, we can send the packet on a
> "fast-forward" code path.
>
> Think about bridging packets to a guest OS.  Because we know very
> early at RX (from packet HW descriptor) we might even avoid allocating
> a SKB.  We could just "forward" the packet-page to the guest OS.
>
> Taking Eric's idea, of remote CPUs, we could even send these
> packet-pages to a remote CPU (e.g. where the guest OS is running),
> without having touched a single cache-line in the packet-data.  I
> would still bundle them up first, to amortize the (100-133ns) cost of
> transferring something to another CPU.
>
You mean like RPS/RFS/aRFS/flow_director already does (except for the
zero-touch part)?

> The data-cache trick, would be to instruct prefetcher only to start
> prefetching to L3 or L2, when these packet are destined for a remote
> CPU.  At-least Intel CPUs have prefetch operations that specify only
> L2/L3 cache.
>
>
> Maybe, we need a combined solution.  Lazy eval skb->pkt_type, for
> local delivery, but set the information if avail from HW desc.  And
> fast page-forward don't even need a SKB.
>
> --
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Principal Kernel Engineer at Red Hat
>   Author of http://www.iptv-analyzer.org
>   LinkedIn: http://www.linkedin.com/in/brouer
