From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next] net: introduce dev_set_forwarding()
Date: Sun, 03 Nov 2013 08:28:24 -0800
Message-ID: <1383496104.4291.69.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131029090849.GC5944@cpaasch-mac>
	 <1383051962.5464.25.camel@edumazet-glaptop.roam.corp.google.com>
	 <1383059555.5464.33.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131029.194446.2215574000648693370.davem@davemloft.net>
	 <1383091610.1534.29.camel@bwh-desktop.uk.level5networks.com>
	 <1383400897.4291.47.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131103122824.GA17394@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:48037 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751139Ab3KCQ21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Nov 2013 11:28:27 -0500
Received: by mail-pa0-f43.google.com with SMTP id hz1so5990678pad.16
        for <netdev@vger.kernel.org>; Sun, 03 Nov 2013 08:28:26 -0800 (PST)
In-Reply-To: <20131103122824.GA17394@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-11-03 at 20:28 +0800, Herbert Xu wrote:
> On Sat, Nov 02, 2013 at 07:01:37AM -0700, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Christoph Paasch and Jerry Chu reported crashes in skb_segment() caused
> > by commit 8a29111c7ca6 ("net: gro: allow to build full sized skb")
> > 
> > skb_segment() only deals with a frag_list chain containing MSS sized
> > fragments. Even if we fix this problem, its better if GRO layer
> > doesn't build skb with a frag_list in the first place, to let TSO
> > packets reaching output devices.
> >  
> > David Miller and Ben Hutchings suggested we keep track of number of
> > forwarding users to be able to :
> > 
> > - Disable LRO
> > - Make sure GRO layer do not use skb frag_list to extend skb capacity
> 
> Why are we still doing this instead of fixing skb_segment to
> deal with skb frag_list properly?
> 
> LRO is legacy code and we should not be adding similar cruft
> to GRO.

1) Because we should not call skb_segment() at all on a router ?

2) If you aggregate too much on a router, you increase latencies,
   or if you prefer the RTT of TCP flows.

3) Because skb_segment() layer only builds MSS sized skb, so this
   remove TSO ability on output path

Splitting a 45 MSS packet into 3 TSO packets (16 + 16 + X MSS) is going
to be quite complex, given the gso_segment() stuff is meant to segment
in MSS packets. Adding complexity in this already complex stuff is
simply not worth it.

For local TCP, its different, because if you receive such high
throughput, ability to build full size GRO packet helps to reduce number
of ACK segments and number of SKB in receive queue (or OFO queue),
without impacting ACK clocking and TCP dynamics.

And even if a router does not do this aggregation, the final receiver
will do.

So in conclusion, GRO is like TSO : Its not because they are able to use
64KB skbs you always _have_ to fill skb to max capacity.
