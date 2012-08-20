From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 02/11] net: add function to allocate skbuff head
 without data area
Date: Mon, 20 Aug 2012 08:39:34 +0200
Message-ID: <1345444774.5158.241.camel@edumazet-glaptop>
References: <1345443532-3707-1-git-send-email-kaber@trash.net>
	 <1345443532-3707-3-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Florian.Westphal@Sophos.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:34984 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751333Ab2HTGjj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2012 02:39:39 -0400
In-Reply-To: <1345443532-3707-3-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-08-20 at 08:18 +0200, Patrick McHardy wrote:
> Add a function to allocate a skbuff head without any data. This will be
> used by memory mapped netlink to attached data from the mmaped area to
> the skb.
> 
> Additionally change skb_release_all() to check whether the skb has a
> data area to allow the skb destructor to clear the data pointer in
> case only a head has been allocated.

      * ...

>  
> +struct sk_buff *__alloc_skb_head(gfp_t gfp_mask, int node)
> +{
> +	struct sk_buff *skb;
> +
> +	/* Get the HEAD */
> +	skb = kmem_cache_alloc_node(skbuff_head_cache,
> +				    gfp_mask & ~__GFP_DMA, node);
> +	if (!skb)
> +		goto out;
> +	prefetchw(skb);
> +

This prefetch is probably not worth it, since you write on skb on the
following memset(). Cpu wont have enough 'time' to take benefit from
this hint.

> +	/*
> +	 * Only clear those fields we need to clear, not those that we will
> +	 * actually initialise below. Hence, don't put any more fields after
> +	 * the tail pointer in struct sk_buff!
> +	 */
> +	memset(skb, 0, offsetof(struct sk_buff, tail));
