From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: udp packets following an UFO enqueued packet need also be handled by UFO
Date: Wed, 2 Oct 2013 15:03:29 +0200
Message-ID: <20131002130329.GP10771@order.stressinduktion.org>
References: <20130930114343.GA6356@minipsycho.brq.redhat.com> <20130930172312.GE10771@order.stressinduktion.org> <20131001105837.GA1424@minipsycho.brq.redhat.com> <20131001120907.GH10771@order.stressinduktion.org> <20131001123214.GI10771@order.stressinduktion.org> <20131001214721.GJ10771@order.stressinduktion.org> <20131001232534.GM10771@order.stressinduktion.org> <20131002085842.GA1528@minipsycho.brq.redhat.com> <1380710488.19002.67.camel@edumazet-glaptop.roam.corp.google.com> <20131002121207.GO10771@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, kaber@trash.net, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:36077 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754027Ab3JBNDb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 09:03:31 -0400
Content-Disposition: inline
In-Reply-To: <20131002121207.GO10771@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 02, 2013 at 02:12:07PM +0200, Hannes Frederic Sowa wrote:
> Hi Eric!
> 
> On Wed, Oct 02, 2013 at 03:41:28AM -0700, Eric Dumazet wrote:
> > On Wed, 2013-10-02 at 10:58 +0200, Jiri Pirko wrote:
> > > Wed, Oct 02, 2013 at 01:25:34AM CEST, hannes@stressinduktion.org wrote:
> > > >-	if (((length > mtu) || (skb && skb_is_gso(skb))) &&
> > > >+	if (((length > mtu) || (skb && skb_has_frags(skb))) &&
> > 
> > > 
> > > This seems correct to me. sk_is_gso would work as well is you apply my
> > > patch "[patch net] ip6_output: do skb ufo init for peeked non ufo skb as
> > > well" which does the setting of gso_size.
> > 
> > Well, skb having frags or not should not be a concern :
> > Thats an allocation choice (lets say to avoid high order allocations). 
> > 
> > Setting gso_size is probably better.
> 
> e89e9cf539a28df7d0eb1d0a545368e9920b34ac ("[IPv4/IPv6]: UFO Scatter-gather
> approach") states:
> 
> "
> skb->data will contain MAC/IP/UDP header and skb_shinfo(skb)->frags[]
> contains the data payload. The skb->ip_summed will be set to CHECKSUM_HW
> indicating that hardware has to do checksum calculation. Hardware should
> compute the UDP checksum of complete datagram and also ip header checksum of
> each fragmented IP packet.
> "
> 
> This is the reason why I tried not to update the gso_size. If it is ok, I am
> fine with that.

Especially, drivers/net/ethernet/neterion/s2io.c states that the first dma
mapping (skb->data with skb_headlen, which is fine) is used as the inband
header:

        if (offload_type == SKB_GSO_UDP)
                frg_cnt++; /* as Txd0 was used for inband header */

That is my only other hint that we maybe should not update gso_size and
gso_type. I guess software fallback does not have this problem, but I won't
have time to check until this evening.

I am really not sure if just setting gso_size does not break neterion UFO
offloading. :/

Greetings,

  Hannes
