From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] ipv6: gro: IPV6_GRO_CB(skb)->proto problem
Date: Sun, 7 Oct 2012 12:27:01 +0800
Message-ID: <20121007042701.GB31839@gondor.apana.org.au>
References: <1349550927.21172.1759.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sting.hengli.com.au ([178.18.18.71]:58858 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750851Ab2JGE1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Oct 2012 00:27:08 -0400
Content-Disposition: inline
In-Reply-To: <1349550927.21172.1759.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 06, 2012 at 09:15:27PM +0200, Eric Dumazet wrote:
> It seems IPV6_GRO_CB(skb)->proto can be destroyed in skb_gro_receive()
> if a new skb is allocated (to serve as an anchor for frag_list)
> 
> At line 3049 we copy NAPI_GRO_CB() only (not the IPV6 specific part)
> 
> *NAPI_GRO_CB(nskb) = *NAPI_GRO_CB(p);
> 
> So we leave IPV6_GRO_CB(nskb)->proto to 0 (fresh skb allocation) instead
> of PROTO_TCP
> 
> So ipv6_gro_complete() wont be able to call ops->gro_complete()
> [ tcp6_gro_complete() ]
> 
> I would fix this by moving proto in NAPI_GRO_CB() [ ie getting rid of
> IPV6_GRO_CB ]
> 
> Am I missing something ?
> 
> (I'll submit a proper patch once/if prior GRO ones are accepted/merged
> by David)

No I think you're absolutely right.

>  include/linux/netdevice.h |    2 ++
>  net/ipv6/af_inet6.c       |   11 ++---------
>  2 files changed, 4 insertions(+), 9 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 01646aa..3f13441 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1510,6 +1510,8 @@ struct napi_gro_cb {
>  	int free;
>  #define NAPI_GRO_FREE		  1
>  #define NAPI_GRO_FREE_STOLEN_HEAD 2
> +
> +	u8 proto;

I'd prefer to keep it as an int since we're not really running
short on space.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
