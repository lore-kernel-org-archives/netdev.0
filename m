From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH ipsec 1/3] ipv6: wire up skb->encapsulation
Date: Sun, 18 Aug 2013 13:00:38 +0200
Message-ID: <20130818110038.GC7371@order.stressinduktion.org>
References: <20130817175116.GA7001@order.stressinduktion.org> <20130817180738.GA24518@order.stressinduktion.org> <20130818042416.GK30709@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com,
	yoshfuji@linux-ipv6.org, nicolas.dichtel@6wind.com
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:58852 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754069Ab3HRLAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Aug 2013 07:00:44 -0400
Content-Disposition: inline
In-Reply-To: <20130818042416.GK30709@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 18, 2013 at 02:24:16PM +1000, Simon Horman wrote:
> On Sat, Aug 17, 2013 at 08:07:38PM +0200, Hannes Frederic Sowa wrote:
> > Hi Simon!
> > 
> > On Sat, Aug 17, 2013 at 07:51:16PM +0200, Hannes Frederic Sowa wrote:
> > > When pushing a new header before current one call skb_reset_inner_headers
> > > to record the position of the inner headers in the various ipv6 tunnel
> > > protocols.
> > > 
> > > We later need this to correctly identify the addresses needed to send
> > > back an error in the xfrm layer.
> > > 
> > > This change is safe, because skb->protocol is always checked before
> > > dereferencing data from the inner protocol.
> > > 
> > > Cc: Steffen Klassert <steffen.klassert@secunet.com>
> > > Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> > > Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> > > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > > ---
> > > 
> > > This patch is based on Steffen Klassert's ipsec tree.
> > > 
> > >  net/ipv6/ip6_gre.c    | 5 +++++
> > >  net/ipv6/ip6_tunnel.c | 6 ++++++
> > >  net/ipv6/sit.c        | 5 +++++
> > >  3 files changed, 16 insertions(+)
> > > 
> > > diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
> > > index ecd6073..90747f1 100644
> > > --- a/net/ipv6/ip6_gre.c
> > > +++ b/net/ipv6/ip6_gre.c
> > > @@ -724,6 +724,11 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
> > >  		ipv6_push_nfrag_opts(skb, &opt.ops, &proto, NULL);
> > >  	}
> > >  
> > > +	if (likely(!skb->encapsulation)) {
> > > +		skb_reset_inner_headers(skb);
> > > +		skb->encapsulation = 1;
> > > +	}
> > > +
> > 
> > While doing these patches, I wondered how skb->inner_protocol will be
> > used in future (you added it in 0d89d2035fe063461a5ddb609b2c12e7fb006e44
> > ("MPLS: Add limited GSO support")). Current use by tunnels seems safe to
> > me, but I wondered how you would extend its use?
> 
> Hi,
> 
> I must confess that I'm not entirely sure that I understand the question.

Sorry to be not clear enough. I try to present my envisioned use case for
inner_protocol:

I do think there may be some other corner cases when reporting back
errors to a local socket when multiple tunnels+ipsecs are stacked into
each other. The first encapsulation sets skb->inner_network_header, so
that we can later extract the needed information for the error generation
via inner_ip{v6,}_hdr. It would be handy here to use inner_protocol to
mark the type of inner_network_header in advance (all this is because,
even if we still have a reference to the local socket and know its af,
it could also have emitted an IPv4 frame, so we have to jump to the ipv4
error handling path).

Thanks,

  Hannes
