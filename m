From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Optimizing instruction-cache, more packets at each stage
Date: Sun, 24 Jan 2016 16:44:14 +0200
Message-ID: <20160124163846-mutt-send-email-mst@redhat.com>
References: <1453330945.1223.329.camel@edumazet-glaptop2.roam.corp.google.com>
 <CALx6S34H67o64q3YoYiHQ+VSSuSsuSjBXmexSSXF_Hq8fcN0iw@mail.gmail.com>
 <20160121122730.6330a84b@redhat.com>
 <20160121.105401.1793719917762270884.davem@davemloft.net>
 <20160124152814.2ea5e99b@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, tom@herbertland.com,
	eric.dumazet@gmail.com, gerlitz.or@gmail.com, edumazet@google.com,
	netdev@vger.kernel.org, alexander.duyck@gmail.com,
	alexei.starovoitov@gmail.com, borkmann@iogearbox.net,
	marek@cloudflare.com, hannes@stressinduktion.org, fw@strlen.de,
	pabeni@redhat.com, john.r.fastabend@intel.com, amirva@gmail.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39848 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751954AbcAXOoW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Jan 2016 09:44:22 -0500
Content-Disposition: inline
In-Reply-To: <20160124152814.2ea5e99b@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 24, 2016 at 03:28:14PM +0100, Jesper Dangaard Brouer wrote:
> On Thu, 21 Jan 2016 10:54:01 -0800 (PST)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Jesper Dangaard Brouer <brouer@redhat.com>
> > Date: Thu, 21 Jan 2016 12:27:30 +0100
> > 
> > > eth_type_trans() does two things:
> > > 
> > > 1) determine skb->protocol
> > > 2) setup skb->pkt_type = PACKET_{BROADCAST,MULTICAST,OTHERHOST}
> > > 
> > > Could the HW descriptor deliver the "proto", or perhaps just some bits
> > > on the most common proto's?
> > > 
> > > The skb->pkt_type don't need many bits.  And I bet the HW already have
> > > the information.  The BROADCAST and MULTICAST indication are easy.  The
> > > PACKET_OTHERHOST, can be turned around, by instead set a PACKET_HOST
> > > indication, if the eth->h_dest match the devices dev->dev_addr (else a
> > > SW compare is required).
> > > 
> > > Is that doable in hardware?  
> > 
> > I feel like we've had this discussion before several years ago.
> > 
> > I think having just the protocol value would be enough.
> > 
> > skb->pkt_type we could deal with by using always an accessor and
> > evaluating it lazily.  Nothing needs it until we hit ip_rcv() or
> > similar.
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

OK, so you would build a new kind of rx handler, and then
e.g. macvtap could maybe get packets this way?
Sure - e.g. vhost expects an skb at the moment
but it won't be too hard to teach it that there's
some other option.

Or maybe some kind of stub skb that just has
the correct length but no data is easier,
I'm not sure.

> Taking Eric's idea, of remote CPUs, we could even send these
> packet-pages to a remote CPU (e.g. where the guest OS is running),
> without having touched a single cache-line in the packet-data.  I
> would still bundle them up first, to amortize the (100-133ns) cost of
> transferring something to another CPU.

This bundling would have to happen in a guest
specific way then, so in vhost.
I'd be curious to see what you come up with.

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
