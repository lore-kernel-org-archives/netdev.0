From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH RFC ipsec-next 5/5] esp: Add a software GRO codepath
Date: Wed, 8 Feb 2017 12:43:11 +0100
Message-ID: <20170208114311.GU30338@gauss.secunet.com>
References: <1486458851-4920-1-git-send-email-steffen.klassert@secunet.com>
 <1486458851-4920-6-git-send-email-steffen.klassert@secunet.com>
 <1486496706.7793.66.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
        "Sowmini Varadhan" <sowmini.varadhan@oracle.com>,
        Ilan Tayari <ilant@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:52680 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752949AbdBHLom (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 8 Feb 2017 06:44:42 -0500
Content-Disposition: inline
In-Reply-To: <1486496706.7793.66.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 07, 2017 at 11:45:06AM -0800, Eric Dumazet wrote:
> On Tue, 2017-02-07 at 10:14 +0100, Steffen Klassert wrote:
> > This patch adds GRO ifrastructure and callbacks for ESP on
> > ipv4 and ipv6.
> > 
> 
> 
> I am a bit confused.
> 
> >  
> > -struct xfrm_tunnel_skb_cb {
> > +/*
> > + * This structure is used if we get the packet from the gro layer.
> > + */
> > +struct xfrm_gro_skb_cb {
> >  	union {
> >  		struct inet_skb_parm h4;
> >  		struct inet6_skb_parm h6;
> > -	} header;
> > +
> > +		struct {
> > +			__be32 seq;
> > +			bool skb_is_gro;
> > +		} input;
> > +	} gro;
> > +};
> > +
> > +#define XFRM_GRO_SKB_CB(__skb) ((struct xfrm_gro_skb_cb *)&((__skb)->cb[0]))
> > +
> 
> Then :
> 
> > +
> > +	x = xfrm_state_lookup(dev_net(skb->dev), skb->mark,
> > +			      (xfrm_address_t *)&ip_hdr(skb)->daddr,
> > +			      spi, IPPROTO_ESP, AF_INET);
> > +	if (!x)
> > +		goto out;
> > +
> > +	XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip4 = NULL;
> > +	XFRM_SPI_SKB_CB(skb)->family = AF_INET;
> > +	XFRM_SPI_SKB_CB(skb)->daddroff = offsetof(struct iphdr, daddr);
> > +	XFRM_GRO_SKB_CB(skb)->gro.input.seq = seq;
> > +	skb->sp->xvec[skb->sp->len++] = x;
> > +
> > +	/* We don't need to handle errors from xfrm_input, it does all
> > +	 * the error handling and frees the resources on error. */
> > +	xfrm_input(skb, IPPROTO_ESP, spi, -2);
> > +
> > +	return ERR_PTR(-EINPROGRESS);
> > +out:
> > +	skb_push(skb, offset);
> > +	NAPI_GRO_CB(skb)->same_flow = 0;
> > +	NAPI_GRO_CB(skb)->flush = 1;
> > +
> 
> 
> How can you mix XFRM_SPI_SKB_CB(), XFRM_GRO_SKB_CB() and NAPI_GRO_CB()
> at the same time on one skb ?

The fields of XFRM_SPI_SKB_CB start behind XFRM_GRO_SKB_CB, it is
stacked.

I hope not to mix NAPI_GRO_CB with XFRM_*_SKB_CB. If I don't find a
xfrm_state, I use only NAPI_GRO_CB and return to the calling GRO handlers.

If I find a xfrm_state, I use only the XFRM_*_SKB_CB and notify the calling
GRO handlers that the packet is consumed. Patch 3 changed the potential
callers to not touch the skb anymore in this case.

Anyway, I think I can remove xfrm_gro_skb_cb, the sequence number fits
on xfrm_spi_skb_cb, and the skb_is_gro flag can be added to the secpath.
We have to extend the secpath anyway to carry HW offloading informations,
so this flag could be there too.
