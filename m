From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] udp: avoid ufo handling on IP payload compression packets
Date: Tue, 7 Mar 2017 15:01:50 +0800
Message-ID: <20170307070150.GA25144@gondor.apana.org.au>
References: <1488544652-28475-1-git-send-email-alexey.kodanev@oracle.com>
 <20170306061657.GY694@gauss.secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kodanev <alexey.kodanev@oracle.com>, netdev@vger.kernel.org,
        David Miller <davem@davemloft.net>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:34295 "EHLO
        helcar.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751838AbdCGH2y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 02:28:54 -0500
Content-Disposition: inline
In-Reply-To: <20170306061657.GY694@gauss.secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 06, 2017 at 07:16:57AM +0100, Steffen Klassert wrote:
>
> > diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> > index b67719f..18383ef 100644
> > --- a/net/ipv4/ip_output.c
> > +++ b/net/ipv4/ip_output.c
> > @@ -960,7 +960,10 @@ static int __ip_append_data(struct sock *sk,
> >  	cork->length += length;
> >  	if ((((length + fragheaderlen) > mtu) || (skb && skb_is_gso(skb))) &&
> >  	    (sk->sk_protocol == IPPROTO_UDP) &&
> > -	    (rt->dst.dev->features & NETIF_F_UFO) && !rt->dst.header_len &&
> > +	    (rt->dst.dev->features & NETIF_F_UFO) &&
> > +#ifdef CONFIG_XFRM
> > +	    !rt->dst.xfrm &&
> > +#endif
> 
> Please fix IPcomp to use rt->dst.header_len instead off adding
> this ifdef to the generic networking code.

It's not that simple though.  IPComp's header_len is set to zero
because we opportunistically drop the IPComp header when the total
compressed length exceeds the original packet length.  That is,
we only ever do IPComp when it does not cause the packet to expand.

So it seems that we need another way of indicating the presence of
XFRM.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
