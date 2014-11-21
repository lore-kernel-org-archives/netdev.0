From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH net] net: Revert "net: avoid one atomic operation in
 skb_clone()"
Date: Fri, 21 Nov 2014 19:05:10 +0100
Message-ID: <20141121180510.GA22112@kria>
References: <20141121160937.GA32608@ret.masoncoding.com>
 <1416587469.8629.106.camel@edumazet-glaptop2.roam.corp.google.com>
 <1416589451.8629.119.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Chris Mason <clm@fb.com>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:64725 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750704AbaKUSFT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2014 13:05:19 -0500
Content-Disposition: inline
In-Reply-To: <1416589451.8629.119.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Eric,

2014-11-21, 09:04:11 -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Not sure what I was thinking, but doing anything after
> releasing a refcount is suicidal or/and embarrassing.
> 
> By the time we set skb->fclone to SKB_FCLONE_FREE, another cpu
> could have released last reference and freed whole skb.
> 
> We potentially corrupt memory or trap if CONFIG_DEBUG_PAGEALLOC is set.
> 
> Reported-by: Chris Mason <clm@fb.com>
> Fixes: ce1a4ea3f1258 ("net: avoid one atomic operation in skb_clone()")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  net/core/skbuff.c |   23 ++++++-----------------
>  1 file changed, 6 insertions(+), 17 deletions(-)
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index c16615bfb61e..be4c7deed971 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -552,20 +552,13 @@ static void kfree_skbmem(struct sk_buff *skb)
>  	case SKB_FCLONE_CLONE:
>  		fclones = container_of(skb, struct sk_buff_fclones, skb2);
>  
> -		/* Warning : We must perform the atomic_dec_and_test() before
> -		 * setting skb->fclone back to SKB_FCLONE_FREE, otherwise
> -		 * skb_clone() could set clone_ref to 2 before our decrement.
> -		 * Anyway, if we are going to free the structure, no need to
> -		 * rewrite skb->fclone.
> +		/* The clone portion is available for
> +		 * fast-cloning again.
>  		 */
> -		if (atomic_dec_and_test(&fclones->fclone_ref)) {
> +		skb->fclone = SKB_FCLONE_UNAVAILABLE;

Shouldn't that be SKB_FCLONE_FREE ?

> +
> +		if (atomic_dec_and_test(&fclones->fclone_ref))
>  			kmem_cache_free(skbuff_fclone_cache, fclones);
> -		} else {
> -			/* The clone portion is available for
> -			 * fast-cloning again.
> -			 */
> -			skb->fclone = SKB_FCLONE_FREE;

like here                             ^^^^



Thanks,

-- 
Sabrina
