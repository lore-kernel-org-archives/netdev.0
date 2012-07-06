From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH] gianfar: fix potential sk_wmem_alloc imbalance
Date: Fri, 6 Jul 2012 14:09:47 -0400
Message-ID: <20120706180947.GI1817@windriver.com>
References: <1341524713.3265.41.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Manfred Rudigier <manfred.rudigier@omicron.at>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	Jiajun Wu <b06378@freescale.com>,
	Andy Fleming <afleming@freescale.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:62586 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751222Ab2GFSKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 14:10:06 -0400
Content-Disposition: inline
In-Reply-To: <1341524713.3265.41.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[[PATCH] gianfar: fix potential sk_wmem_alloc imbalance] On 05/07/2012 (Thu 23:45) Eric Dumazet wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> commit db83d136d7f753 (gianfar: Fix missing sock reference when
> processing TX time stamps) added a potential sk_wmem_alloc imbalance
> 
> If the new skb has a different truesize than old one, we can get a
> negative sk_wmem_alloc once new skb is orphaned at TX completion.
> 
> Now we no longer early orphan skbs in dev_hard_start_xmit(), this
> probably can lead to fatal bugs.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Manfred Rudigier <manfred.rudigier@omicron.at>
> Cc: Claudiu Manoil <claudiu.manoil@freescale.com>
> Cc: Jiajun Wu <b06378@freescale.com>
> Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
> Cc: Andy Fleming <afleming@freescale.com>
> ---
> 
> Note : I don't have the hardware and discovered this problem by code
> analysis. So please compile and run this patch before Acking it,
> thanks !

I can do that on Monday when I'm back in the office if nobody else has
already done it by then.

> 
> BTW, dev->needed_headroom should be set to GMAC_FCB_LEN + GMAC_TXPAL_LEN
> to avoid reallocations...

Aside from the one line change at driver init, is there more to it than
that?  More specifically, it currently does:

fcb_length = GMAC_FCB_LEN;

if (...timestamps...)
	fcb_length = GMAC_FCB_LEN + GMAC_TXPAL_LEN;

if (... && (skb_headroom(skb) < fcb_length))
	...
	skb_new = skb_realloc_headroom(skb, fcb_length);

and I don't know the code well enough to know if setting the
needed_headroom value _guarantees_ the above fcb_length comparison
will always be false, and hence can be deleted.  It kind of looks
like it via LL_RESERVED_SPACE, but I'm not 100% sure...

Thanks,
Paul.
--

> 
>  drivers/net/ethernet/freescale/gianfar.c |    7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
> index f2db8fc..ab1d80f 100644
> --- a/drivers/net/ethernet/freescale/gianfar.c
> +++ b/drivers/net/ethernet/freescale/gianfar.c
> @@ -2063,10 +2063,9 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  			return NETDEV_TX_OK;
>  		}
>  
> -		/* Steal sock reference for processing TX time stamps */
> -		swap(skb_new->sk, skb->sk);
> -		swap(skb_new->destructor, skb->destructor);
> -		kfree_skb(skb);
> +		if (skb->sk)
> +			skb_set_owner_w(skb_new, skb->sk);
> +		consume_skb(skb);
>  		skb = skb_new;
>  	}
>  
> 
> 
