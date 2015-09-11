From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netlink, mmap: transform mmap skb into full skb on
 taps
Date: Fri, 11 Sep 2015 14:34:59 -0700 (PDT)
Message-ID: <20150911.143459.1484553569083753621.davem@davemloft.net>
References: <55F2AC29.3030209@iogearbox.net>
	<20150911.124205.1992250802389107845.davem@davemloft.net>
	<55F33AFC.1080206@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chamaken@gmail.com, fw@strlen.de, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50581 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752934AbbIKVfC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2015 17:35:02 -0400
In-Reply-To: <55F33AFC.1080206@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri, 11 Sep 2015 22:35:08 +0200

> On 09/11/2015 09:42 PM, David Miller wrote:
>> @@ -2220,7 +2221,8 @@ static inline void skb_orphan(struct sk_buff
>> *skb)
>>    */
>>   static inline int skb_orphan_frags(struct sk_buff *skb, gfp_t
>>   gfp_mask)
>>   {
>> -	if (likely(!(skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY)))
>> +	if (likely(!(skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) ||
>> +		   skb->private_buffers))
> 
> (These two would need to be swapped.)

Right, good catch.

>> -	n->destructor = NULL;
>> +	if (!skb->private_buffers)
>> +		n->destructor = NULL;
>> +	else
>> +		C(destructor);
>>   	C(tail);
>>   	C(end);
>>   	C(head);
> 
> We would also have to conditionally skip the __skb_clone()'s ...
> 
>   atomic_inc(&(skb_shinfo(skb)->dataref));

Sigh, the solution was too good to be true I guess. :-/ That's right,
we can't touch skb_shinfo for mmap skbs.

Another approach would be to put the mmap user data into a page frag,
but that obviously has some costs associated with it.  However,
nothing in netlink is ready for fragged skbs yet.  It's the reason why
we have the large skb via vmalloc facility.

Long term fixing that is probably the way to go, but that would be an
enormous project.

So for now I'm going to apply your patch Daniel, thanks.
