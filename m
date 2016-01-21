From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: Optimizing instruction-cache, more packets at each stage
Date: Fri, 22 Jan 2016 00:45:13 +0200
Message-ID: <CAJ3xEMjMg9fZGk-=F_nvx2Ta5z8fj9nrEEAm+xWYSm-hyUDDYg@mail.gmail.com>
References: <CALx6S34H67o64q3YoYiHQ+VSSuSsuSjBXmexSSXF_Hq8fcN0iw@mail.gmail.com>
	<20160121122730.6330a84b@redhat.com>
	<CAJ3xEMgPi-P6R39LOkBM67SehQE0MLxDXRB7qxCV5Y4WLORpXA@mail.gmail.com>
	<20160121.105608.180935122763399438.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Tom Herbert <tom@herbertland.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <borkmann@iogearbox.net>,
	Marek Majkowski <marek@cloudflare.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Paolo Abeni <pabeni@redhat.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Amir Vadai <amirva@gmail.com>,
	Matan Barak <matanb@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:34138 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750758AbcAUWpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 17:45:14 -0500
Received: by mail-ig0-f173.google.com with SMTP id ik10so134610021igb.1
        for <netdev@vger.kernel.org>; Thu, 21 Jan 2016 14:45:14 -0800 (PST)
In-Reply-To: <20160121.105608.180935122763399438.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 21, 2016 at 8:56 PM, David Miller <davem@davemloft.net> wrote:
> From: Or Gerlitz <gerlitz.or@gmail.com>
> Date: Thu, 21 Jan 2016 14:49:25 +0200
>
>> On Thu, Jan 21, 2016 at 1:27 PM, Jesper Dangaard Brouer
>> <brouer@redhat.com> wrote:
>>> On Wed, 20 Jan 2016 15:27:38 -0800 Tom Herbert <tom@herbertland.com> wrote:
>>>
>>>> eth_type_trans touches headers
>>>
>>> True, the eth_type_trans() call in the driver is a major bottleneck,
>>> because it touch the packet header and happens very early in the driver.
>>>
>>> In my experiments, where I extract several packet before calling
>>> napi_gro_receive(), and I also delay calling eth_type_trans().  Most of
>>> my speedup comes from this trick, as the prefetch() now that enough
>>> time.
>>>
>>>  while ((skb = __skb_dequeue(&rx_skb_list)) != NULL) {
>>>         skb->protocol = eth_type_trans(skb, rq->netdev);
>>>         napi_gro_receive(cq->napi, skb);
>>>  }
>>>
>>> What is the HW could provide the info we need in the descriptor?!?
>>>
>>>
>>> eth_type_trans() does two things:
>>>
>>> 1) determine skb->protocol
>>> 2) setup skb->pkt_type = PACKET_{BROADCAST,MULTICAST,OTHERHOST}
>>>
>>> Could the HW descriptor deliver the "proto", or perhaps just some bits
>>> on the most common proto's?
>>>
>>> The skb->pkt_type don't need many bits.  And I bet the HW already have
>>> the information.  The BROADCAST and MULTICAST indication are easy.  The
>>> PACKET_OTHERHOST, can be turned around, by instead set a PACKET_HOST
>>> indication, if the eth->h_dest match the devices dev->dev_addr (else a
>>> SW compare is required).
>>>
>>> Is that doable in hardware?
>>
>> As I wrote earlier, for determination of the eth-type HWs can do what you ask
>> here and more.
>>
>> Protocol being IP or not (and only then you look in the data) you could
>> get I guess from many NICs, e.g if the NIC sets PKT_HASH_TYPE_L4
>> or PKT_HASH_TYPE_L3 then we know it's an IP packets and only if
>> we don't see this indication we look into the data.
>
> This doesn't differentiate ipv4 vs. ipv6 which is critical here, so this
> mechanism is not sufficient.

Dave, at least in the ConnectX4 (mlx5e driver), as I commented earlier
on this thread, we can use programmed tags reported by the HW on the
completion of packets  whether the ethtype is ipv4 or ipv6 or
something else, and let the kernel
branch look into the packet memory on in the last case.

> We must know the exact ETH_P_* value.
