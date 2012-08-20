From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 02/11] net: add function to allocate skbuff head without
 data area
Date: Mon, 20 Aug 2012 08:41:40 +0200 (MEST)
Message-ID: <Pine.GSO.4.63.1208200841010.6655@stinky-local.trash.net>
References: <1345443532-3707-1-git-send-email-kaber@trash.net>
 <1345443532-3707-3-git-send-email-kaber@trash.net> <1345444774.5158.241.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Florian.Westphal@Sophos.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36177 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751333Ab2HTGlm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2012 02:41:42 -0400
In-Reply-To: <1345444774.5158.241.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 20 Aug 2012, Eric Dumazet wrote:

> On Mon, 2012-08-20 at 08:18 +0200, Patrick McHardy wrote:
>> Add a function to allocate a skbuff head without any data. This will be
>> used by memory mapped netlink to attached data from the mmaped area to
>> the skb.
>>
>> Additionally change skb_release_all() to check whether the skb has a
>> data area to allow the skb destructor to clear the data pointer in
>> case only a head has been allocated.
>
>      * ...
>
>>
>> +struct sk_buff *__alloc_skb_head(gfp_t gfp_mask, int node)
>> +{
>> +	struct sk_buff *skb;
>> +
>> +	/* Get the HEAD */
>> +	skb = kmem_cache_alloc_node(skbuff_head_cache,
>> +				    gfp_mask & ~__GFP_DMA, node);
>> +	if (!skb)
>> +		goto out;
>> +	prefetchw(skb);
>> +
>
> This prefetch is probably not worth it, since you write on skb on the
> following memset(). Cpu wont have enough 'time' to take benefit from
> this hint.

Right, I remember we talked about that before and I already removed it.
Must have forgotten to actually commit that change, thanks!

>
>> +	/*
>> +	 * Only clear those fields we need to clear, not those that we will
>> +	 * actually initialise below. Hence, don't put any more fields after
>> +	 * the tail pointer in struct sk_buff!
>> +	 */
>> +	memset(skb, 0, offsetof(struct sk_buff, tail));
