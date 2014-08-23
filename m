From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC net-next 1/2] net: skbuff: propagate pfmemalloc to
 skb
Date: Sat, 23 Aug 2014 16:51:53 -0700
Message-ID: <1408837913.5604.53.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1408829839-20742-1-git-send-email-_govind@gmx.com>
	 <1408829839-20742-2-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	mgorman@suse.de
To: Govindarajulu Varadarajan <_govind@gmx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:39439 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752060AbaHWXvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2014 19:51:54 -0400
Received: by mail-pd0-f171.google.com with SMTP id z10so17961901pdj.2
        for <netdev@vger.kernel.org>; Sat, 23 Aug 2014 16:51:54 -0700 (PDT)
In-Reply-To: <1408829839-20742-2-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-08-24 at 03:07 +0530, Govindarajulu Varadarajan wrote:
> In __netdev_alloc_skb, __netdev_alloc_frag might have allocated page with
> flag __GFP_MEMALLOC. But we do not propagate it to the skb.
> 
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
> ---
>  net/core/skbuff.c | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 163b673..51a3328 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -425,8 +425,14 @@ struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
>  
>  		if (likely(data)) {
>  			skb = build_skb(data, fragsz);
> -			if (unlikely(!skb))
> +			if (unlikely(!skb)) {
>  				put_page(virt_to_head_page(data));
> +			} else {
> +				struct page *page;
> +
> +				page = virt_to_head_page(data);
> +				skb_propagate_pfmemalloc(page, skb);
> +			}
>  		}
>  	} else {
>  		skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask,

Oh well...

We made everything we could to avoid touching the page head for every
frag allocation.

Just cache page->pfmemalloc into nc->frag.pfmemalloc

Think of how often asymmetric alloc/free happen in networking stack and
why we use NETDEV_PAGECNT_MAX_BIAS trick.

Thanks
