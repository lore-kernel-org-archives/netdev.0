From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/3] skb: Drop bad code from pskb_expand_head
Date: Sat, 05 May 2012 07:35:30 +0200
Message-ID: <1336196130.3752.483.camel@edumazet-glaptop>
References: <20120505001059.21292.31647.stgit@gitlad.jf.intel.com>
	 <20120505002645.21292.38368.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:57316 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752025Ab2EEFff (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 May 2012 01:35:35 -0400
Received: by wibhj6 with SMTP id hj6so1911212wib.1
        for <netdev@vger.kernel.org>; Fri, 04 May 2012 22:35:34 -0700 (PDT)
In-Reply-To: <20120505002645.21292.38368.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-05-04 at 17:26 -0700, Alexander Duyck wrote:
> The fast-path for pskb_expand_head contains a check where the size plus the
> unaligned size of skb_shared_info is compared against the size of the data
> buffer.  This code path has two issues.  First is the fact that after the
> recent changes by Eric Dumazet to __alloc_skb and build_skb the shared info
> is always placed in the optimal spot for a buffer size making this check
> unnecessary.  The second issue is the fact that the check doesn't take into
> account the aligned size of shared info.  As a result the code burns cycles
> doing a memcpy with nothing actually being shifted.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---
> 
>  net/core/skbuff.c |   12 ------------
>  1 files changed, 0 insertions(+), 12 deletions(-)
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index c199aa4..4d085d4 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -951,17 +951,6 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
>  		fastpath = atomic_read(&skb_shinfo(skb)->dataref) == delta;
>  	}
>  
> -	if (fastpath && !skb->head_frag &&
> -	    size + sizeof(struct skb_shared_info) <= ksize(skb->head)) {
> -		memmove(skb->head + size, skb_shinfo(skb),
> -			offsetof(struct skb_shared_info,
> -				 frags[skb_shinfo(skb)->nr_frags]));
> -		memmove(skb->head + nhead, skb->head,
> -			skb_tail_pointer(skb) - skb->head);
> -		off = nhead;
> -		goto adjust_others;
> -	}
> -
>  	data = kmalloc(size + SKB_DATA_ALIGN(sizeof(struct skb_shared_info)),
>  		       gfp_mask);
>  	if (!data)
> @@ -997,7 +986,6 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
>  
>  	skb->head     = data;
>  	skb->head_frag = 0;
> -adjust_others:
>  	skb->data    += off;
>  #ifdef NET_SKBUFF_DATA_USES_OFFSET
>  	skb->end      = size;
> 

I totally agree this code is no longer needed, we already have the
skb_shared_info at the end of the buffer.

Acked-by: Eric Dumazet <edumazet@google.com>
