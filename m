From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH] gianfar: fix potential sk_wmem_alloc imbalance
Date: Mon, 9 Jul 2012 17:38:42 -0400
Message-ID: <4FFB4F62.9010506@windriver.com>
References: <1341524713.3265.41.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Manfred Rudigier <manfred.rudigier@omicron.at>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	Jiajun Wu <b06378@freescale.com>,
	Andy Fleming <afleming@freescale.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:64313 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751900Ab2GIVjA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 17:39:00 -0400
In-Reply-To: <1341524713.3265.41.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12-07-05 05:45 PM, Eric Dumazet wrote:
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

Compiles clean and boot tested with NFS rootfs on mpc8315erdb board
defconfig on net-next [5c9df5fed19 "small cleanup in ax25_addr_parse"]

> 
> BTW, dev->needed_headroom should be set to GMAC_FCB_LEN + GMAC_TXPAL_LEN
> to avoid reallocations...

I also layered on the patch you sent for this and rebuilt, and it
too passes the same basic sanity test, so feel free to add a
Tested-by or similar to your headroom fix as well.

Paul.

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
