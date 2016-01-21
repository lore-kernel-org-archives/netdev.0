From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Optimizing instruction-cache, more packets at each stage
Date: Thu, 21 Jan 2016 14:57:14 +0100
Message-ID: <20160121145714.0afa2293@redhat.com>
References: <20160115142223.1e92be75@redhat.com>
	<20160115.154721.458450438918273509.davem@davemloft.net>
	<20160118112703.6eac71ca@redhat.com>
	<20160118.112455.212265265553435873.davem@davemloft.net>
	<CAJ3xEMiOAdu7ghRoc6ZEMG78Z9xyh1M=5Egc3ydh+97bT3_9fw@mail.gmail.com>
	<1453330945.1223.329.camel@edumazet-glaptop2.roam.corp.google.com>
	<CALx6S34H67o64q3YoYiHQ+VSSuSsuSjBXmexSSXF_Hq8fcN0iw@mail.gmail.com>
	<20160121122730.6330a84b@redhat.com>
	<CAJ3xEMgPi-P6R39LOkBM67SehQE0MLxDXRB7qxCV5Y4WLORpXA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
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
	Matan Barak <matanb@mellanox.com>, brouer@redhat.com
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48566 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759234AbcAUN5Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jan 2016 08:57:24 -0500
In-Reply-To: <CAJ3xEMgPi-P6R39LOkBM67SehQE0MLxDXRB7qxCV5Y4WLORpXA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 21 Jan 2016 14:49:25 +0200 Or Gerlitz <gerlitz.or@gmail.com> wrote:

> On Thu, Jan 21, 2016 at 1:27 PM, Jesper Dangaard Brouer
> <brouer@redhat.com> wrote:
> > On Wed, 20 Jan 2016 15:27:38 -0800 Tom Herbert <tom@herbertland.com> wrote:
> >  
> >> eth_type_trans touches headers  
> >
> > True, the eth_type_trans() call in the driver is a major bottleneck,
> > because it touch the packet header and happens very early in the driver.
> >
> > In my experiments, where I extract several packet before calling
> > napi_gro_receive(), and I also delay calling eth_type_trans().  Most of
> > my speedup comes from this trick, as the prefetch() now that enough
> > time.
> >
> >  while ((skb = __skb_dequeue(&rx_skb_list)) != NULL) {
> >         skb->protocol = eth_type_trans(skb, rq->netdev);
> >         napi_gro_receive(cq->napi, skb);
> >  }
> >
> > What is the HW could provide the info we need in the descriptor?!?
> >
> >
> > eth_type_trans() does two things:
> >
> > 1) determine skb->protocol
> > 2) setup skb->pkt_type = PACKET_{BROADCAST,MULTICAST,OTHERHOST}
> >
> > Could the HW descriptor deliver the "proto", or perhaps just some bits
> > on the most common proto's?
> >
> > The skb->pkt_type don't need many bits.  And I bet the HW already have
> > the information.  The BROADCAST and MULTICAST indication are easy.  The
> > PACKET_OTHERHOST, can be turned around, by instead set a PACKET_HOST
> > indication, if the eth->h_dest match the devices dev->dev_addr (else a
> > SW compare is required).
> >
> > Is that doable in hardware?  
> 
> As I wrote earlier, for determination of the eth-type HWs can do what
> you ask here and more.

That is great! Is this already being delivered in the descriptor?

> Protocol being IP or not (and only then you look in the data) you
> could get I guess from many NICs, e.g if the NIC sets PKT_HASH_TYPE_L4
> or PKT_HASH_TYPE_L3 then we know it's an IP packets and only if
> we don't see this indication we look into the data.

It is a good trick. But at this very early stage we only need the
eth-proto/type.  Once we get to processing the IP layer, then
packet-data will have been pulled / prefetched into L1 cache, thus cost
of determining that should be almost free.


> As for pkt_type we can use NIC steering HW to provide us a tag saying
> if it was our broadcast, other multicast or "our" unicast.

That would be good. Does that conflict with other programming of the
NIC HW, or can we always have it turned on?

If we can pull this off, then we can do some very interesting cache
latency hiding! :-)  (In my perf top eth_type_trans() is one of the top
contenders, especially for your mlx5 driver).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
