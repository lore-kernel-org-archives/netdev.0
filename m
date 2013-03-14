From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH] skb: Propagate pfmemalloc on skb from head page only
Date: Thu, 14 Mar 2013 18:23:46 +0400
Message-ID: <5141DD72.6030906@parallels.com>
References: <5141D0C4.70409@parallels.com> <1363270569.29475.11.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Mel Gorman <mgorman@suse.de>,
	Linux Netdev List <netdev@vger.kernel.org>,
	stable@kernel.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:21360 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751089Ab3CNOZM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Mar 2013 10:25:12 -0400
In-Reply-To: <1363270569.29475.11.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> That said, here's the proper page->pfmemalloc propagation onto socket: we
>> must check the huge-page's head page only, other pages' pfmemalloc and mapping
>> values do not contain what is expected in this place. However, I'm not sure
>> whether this fix is _complete_, since pfmemalloc propagation via lo also 
>> oesn't look great.
>>
>> Both, bit propagation from page to skb and this check in sk_filter, were 
>> introduced by c48a11c7 (netvm: propagate page->pfmemalloc to skb), in v3.5 so
>> Mel and stable@ are in Cc.
>>
>> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
>>
>> ---
>>
>> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
>> index eb2106f..4e525eb 100644
>> --- a/include/linux/skbuff.h
>> +++ b/include/linux/skbuff.h
>> @@ -1292,11 +1292,13 @@ static inline void __skb_fill_page_desc(struct sk_buff *skb, int i,
>>  	 * do not lose pfmemalloc information as the pages would not be
>>  	 * allocated using __GFP_MEMALLOC.
>>  	 */
>> -	if (page->pfmemalloc && !page->mapping)
>> -		skb->pfmemalloc	= true;
>>  	frag->page.p		  = page;
>>  	frag->page_offset	  = off;
>>  	skb_frag_size_set(frag, size);
>> +
>> +	page = compound_head(page);
>> +	if (page->pfmemalloc && !page->mapping)
>> +		skb->pfmemalloc	= true;
>>  }
>>  
>>  /**
>> --
> 
> This looks a nice finding.
> 
> Note this can trigger even without vmsplice() use but regular network
> receive.

Presumably you're right, but I don't understand how :( In order to trigger
this, we should have a huge page, that gets linked to an skb _before_ it
enters the TCP receive path. How can this happen when doing sendmsg/recvmsg?

> Acked-by: Eric Dumazet <edumazet@google.com>
> 
> When I discussed with David on this issue, I said that one possibility
> would be to accept a pfmemalloc skb on regular skb if no other packet is
> in a receive queue, to get a chance to make progress (and limit memory
> consumption to no more than one skb per TCP socket)

Thanks,
Pavel
