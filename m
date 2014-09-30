From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] net: cleanup and document skb fclone layout
Date: Mon, 29 Sep 2014 18:30:18 -0700
Message-ID: <1412040618.30721.49.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411860341.15768.55.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1412022555.30721.40.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:43665 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754199AbaI3BaW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 21:30:22 -0400
Received: by mail-pd0-f179.google.com with SMTP id r10so3601828pdi.24
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 18:30:21 -0700 (PDT)
In-Reply-To: <1412022555.30721.40.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-09-29 at 13:29 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 

>  struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
>  {
> -	struct sk_buff *n;
> +	struct sk_buff_fclones *fclones = container_of(skb,
> +						       struct sk_buff_fclones,
> +						       skb1);
> +	struct sk_buff *n = &fclones->skb2;
>  
>  	if (skb_orphan_frags(skb, gfp_mask))
>  		return NULL;
>  
> -	n = skb + 1;
>  	if (skb->fclone == SKB_FCLONE_ORIG &&
>  	    n->fclone == SKB_FCLONE_UNAVAILABLE) {
> -		atomic_t *fclone_ref = (atomic_t *) (n + 1);
>  		n->fclone = SKB_FCLONE_CLONE;
> -		atomic_inc(fclone_ref);
> +		atomic_inc(&fclones->fclone_ref);
>  	} else {
>  		if (skb_pfmemalloc(skb))
>  			gfp_mask |= __GFP_MEMALLOC;

Note : 

The "atomic_inc(&fclones->fclone_ref)" here can be replaced by an
atomic_set(&fclones->fclone_ref, 2), to avoid a locked operation.


I'll cook a patch for this, after you merged this cleanup

Thanks
