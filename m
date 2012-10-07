From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] ipv6: gro: IPV6_GRO_CB(skb)->proto problem
Date: Sun, 07 Oct 2012 07:56:17 +0200
Message-ID: <1349589377.21172.2000.camel@edumazet-glaptop>
References: <1349550927.21172.1759.camel@edumazet-glaptop>
	 <20121007042701.GB31839@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:43649 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750750Ab2JGF4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Oct 2012 01:56:22 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr13so2735917wgb.1
        for <netdev@vger.kernel.org>; Sat, 06 Oct 2012 22:56:21 -0700 (PDT)
In-Reply-To: <20121007042701.GB31839@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-10-07 at 12:27 +0800, Herbert Xu wrote:
> On Sat, Oct 06, 2012 at 09:15:27PM +0200, Eric Dumazet wrote:
> > It seems IPV6_GRO_CB(skb)->proto can be destroyed in skb_gro_receive()
> > if a new skb is allocated (to serve as an anchor for frag_list)
> > 
> > At line 3049 we copy NAPI_GRO_CB() only (not the IPV6 specific part)
> > 
> > *NAPI_GRO_CB(nskb) = *NAPI_GRO_CB(p);
> > 
> > So we leave IPV6_GRO_CB(nskb)->proto to 0 (fresh skb allocation) instead
> > of PROTO_TCP
> > 
> > So ipv6_gro_complete() wont be able to call ops->gro_complete()
> > [ tcp6_gro_complete() ]
> > 
> > I would fix this by moving proto in NAPI_GRO_CB() [ ie getting rid of
> > IPV6_GRO_CB ]
> > 
> > Am I missing something ?
> > 
> > (I'll submit a proper patch once/if prior GRO ones are accepted/merged
> > by David)
> 
> No I think you're absolutely right.
> 
> >  include/linux/netdevice.h |    2 ++
> >  net/ipv6/af_inet6.c       |   11 ++---------
> >  2 files changed, 4 insertions(+), 9 deletions(-)
> > 
> > diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> > index 01646aa..3f13441 100644
> > --- a/include/linux/netdevice.h
> > +++ b/include/linux/netdevice.h
> > @@ -1510,6 +1510,8 @@ struct napi_gro_cb {
> >  	int free;
> >  #define NAPI_GRO_FREE		  1
> >  #define NAPI_GRO_FREE_STOLEN_HEAD 2
> > +
> > +	u8 proto;
> 
> I'd prefer to keep it as an int since we're not really running
> short on space.
> 

Sure I can do that for stable anyway, but when net-next is open, I'll
submit the patch to use a hash table, and I'll need one more pointer in
this structure.

On 64bit we reach current cb[48] limit...

(skb->next/skb->prev will be used for the global chain, gro_list becomes
a list_head, and each hash chain will use a pointer in napi_gro_cb

(I'll probably use a u32 instead of "unsigned long" for the age)

Thanks
