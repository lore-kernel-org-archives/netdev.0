From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next] xen-netfront: try linearizing SKB if it occupies
 too many slots
Date: Mon, 19 May 2014 17:47:47 +0100
Message-ID: <537A35B3.1000500@citrix.com>
References: <1400238496-2471-1-git-send-email-wei.liu2@citrix.com> <1400245474.7973.154.camel@edumazet-glaptop2.roam.corp.google.com> <20140516131145.GK18551@zion.uk.xensource.com> <1400250068.7973.171.camel@edumazet-glaptop2.roam.corp.google.com> <20140516143653.GL18551@zion.uk.xensource.com> <1400253739.7973.183.camel@edumazet-glaptop2.roam.corp.google.com> <20140516153452.GM18551@zion.uk.xensource.com> <53763CD1.6060500@citrix.com> <20140516165406.GN18551@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xen.org>, David Vrabel <david.vrabel@citrix.com>,
	Konrad Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Stefan Bader <stefan.bader@canonical.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:55444 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932755AbaESQru (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2014 12:47:50 -0400
In-Reply-To: <20140516165406.GN18551@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/05/14 17:54, Wei Liu wrote:
>> I just had an idea: a modified version of xenvif_handle_frag_list function from netback would be useful for us here. It recreates the frags array on fully utilized 4k pages. Plus we can use pskb_expand_head to reduce the page number on the linear buffer (although it might not work, see my comment in the patch)
>> The worst case linear buffer then spans N+1 pages, and has N*PAGE_SIZE+1 bytes. Then the frags after this coalescing should have 16*PAGE_SIZE - (N*PAGE_SIZE+2) bytes at most, which is 16-N pages. Altogether that's 16+1 page, which should definitely fit!
>> This is what I mean:
>>
>> 8<--------------
>> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
>> index 158b5e6..b1133d6 100644
>> --- a/drivers/net/xen-netfront.c
>> +++ b/drivers/net/xen-netfront.c
>> @@ -544,6 +544,73 @@ static int xennet_count_skb_frag_slots(struct sk_buff *skb)
>>   	return pages;
>>   }
>>
>> +int xenvif_reduce_pages(struct sk_buff *skb, int target)
>> +{
>> +	unsigned int offset = skb_headlen(skb);
>> +	skb_frag_t frags[MAX_SKB_FRAGS];
>> +	int newfrags, oldfrags;
>> +	unsigned int pages, optimal;
>> +
>> +	BUG_ON(!target);
>> +
>> +	pages = DIV_ROUND_UP(offset_in_page(skb->data) + skb_headlen(skb), PAGE_SIZE);
>> +	optimal = DIV_ROUND_UP(skb_headlen(skb), PAGE_SIZE);
>> +	if (pages - optimal) {
>> +		int err;
>> +/* FIXME: we should check if pskb_expand_head really allocates on page boundary,
>> + *  otherwise we can still have suboptimal page layout */
>> +		if (unlikely(err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
>
> I'm a bit lost. What do you expect from the call to pskb_expand_head?
>
> I'm sorry I cannot see immediate result from the comment of
> pskb_expand_head. If you call with nhead and ntail equal to 0 it creates
> identical copy, but I don't see guarantee on page alignment. Did I miss
> something?
Yep, indeed, it doesn't guarantee directly that new allocation won't 
span across page boundaries unnecessarily. And actually we are still OK, 
as the skb shouldn't be more than 18 slots, so netback should be able to 
handle that.

>
>> +			return err;
>> +		target -= pages - optimal;
>> +		if (!target)
>> +			return 0;
>> +	}
>> +
>> +	/* Subtract frags size, we will correct it later */
>> +	skb->truesize -= skb->data_len;
>> +
>> +	/* Create a brand new frags array and coalesce there */
>> +	for (newfrags = 0; offset < skb->len; newfrags++) {
>> +		struct page *page;
>> +		unsigned int len;
>> +
>> +		BUG_ON(newfrags >= MAX_SKB_FRAGS);
>> +		page = alloc_page(GFP_ATOMIC);
>
> And the ammount of memory allocation is a bit overkill I think (though
> it's still better than the order-5 allocation in skb_linearize). Can you
> not just memmove all paged data to first few frags and release other
> frags?
>
> Anyway, this method might still work, just a bit overkill IMHO.

Yep, it's quite suboptimal, and anyone can come up with a better (and 
probably more complex) solution, however:
- this should be a rarely used thing, so performance doesn't matter that 
much at the moment (however who knows under which workload you can end 
up with skbs often fragmented so badly that you see this function called 
...)
- it would be good to create a fix for this soon, and let it backported 
to major distro kernels where compound pages are enabled

Zoli
