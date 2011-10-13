From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] net: more accurate skb truesize
Date: Thu, 13 Oct 2011 17:05:01 +0100
Message-ID: <1318521901.2745.18.camel@bwh-desktop>
References: <1318519581.2393.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:19570 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755556Ab1JMQFE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 12:05:04 -0400
In-Reply-To: <1318519581.2393.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-10-13 at 17:26 +0200, Eric Dumazet wrote:
> skb truesize currently accounts for sk_buff struct and part of skb head.
> 
> Considering that skb_shared_info is larger than sk_buff, its time to
> take it into account for better memory accounting.
> 
> This patch introduces SKB_TRUESIZE(X) macro to centralize various
> assumptions into a single place.
> 
> At skb alloc phase, we put skb_shared_info struct at the exact end of
> skb head, to allow a better use of memory (lowering number of
> reallocations), since kmalloc() gives us power-of-two memory blocks.
[...]
> index 5b2c5f1..be66154 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -184,11 +184,15 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
>  		goto out;
>  	prefetchw(skb);
>  
> -	size = SKB_DATA_ALIGN(size);
> -	data = kmalloc_node_track_caller(size + sizeof(struct skb_shared_info),
> -			gfp_mask, node);
> +	size += SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
[...]

If we want to put the data and skb_shared_info on separate cache-lines
then we should use:
	size = SKB_DATA_ALIGN(size) + sizeof(struct skb_shared_info);
(which is effectively what we're doing now).

If that's not important, and we just want to be sure that the allocation
occupies at least a whole cache line, then it should be:
	size = SKB_DATA_ALIGN(size + sizeof(struct skb_shared_info));

But I don't think it makes sense to use SKB_DATA_ALIGN(sizeof(struct
skb_shared_info)).

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
