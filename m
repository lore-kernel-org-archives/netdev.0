From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] udp: avoid ufo handling on IP payload compression packets
Date: Tue, 7 Mar 2017 08:53:24 +0100
Message-ID: <20170307075324.GF694@gauss.secunet.com>
References: <1488544652-28475-1-git-send-email-alexey.kodanev@oracle.com>
 <20170306061657.GY694@gauss.secunet.com>
 <20170307070150.GA25144@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Alexey Kodanev <alexey.kodanev@oracle.com>,
        <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:42790 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754933AbdCGIRW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 7 Mar 2017 03:17:22 -0500
Content-Disposition: inline
In-Reply-To: <20170307070150.GA25144@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 07, 2017 at 03:01:50PM +0800, Herbert Xu wrote:
> On Mon, Mar 06, 2017 at 07:16:57AM +0100, Steffen Klassert wrote:
> >
> > > diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> > > index b67719f..18383ef 100644
> > > --- a/net/ipv4/ip_output.c
> > > +++ b/net/ipv4/ip_output.c
> > > @@ -960,7 +960,10 @@ static int __ip_append_data(struct sock *sk,
> > >  	cork->length += length;
> > >  	if ((((length + fragheaderlen) > mtu) || (skb && skb_is_gso(skb))) &&
> > >  	    (sk->sk_protocol == IPPROTO_UDP) &&
> > > -	    (rt->dst.dev->features & NETIF_F_UFO) && !rt->dst.header_len &&
> > > +	    (rt->dst.dev->features & NETIF_F_UFO) &&
> > > +#ifdef CONFIG_XFRM
> > > +	    !rt->dst.xfrm &&
> > > +#endif
> > 
> > Please fix IPcomp to use rt->dst.header_len instead off adding
> > this ifdef to the generic networking code.
> 
> It's not that simple though.  IPComp's header_len is set to zero
> because we opportunistically drop the IPComp header when the total
> compressed length exceeds the original packet length.  That is,
> we only ever do IPComp when it does not cause the packet to expand.

Yes, indeed. And it makes sense of course.

> 
> So it seems that we need another way of indicating the presence of
> XFRM.

Then we probably have to use the !rt->dst.xfrm check. But then
we should use dst_xfrm() accessor, this avoids the ifdef here.
