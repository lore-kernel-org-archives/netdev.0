From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH 2/2] tcp: cleanup tcp_try_coalesce
Date: Wed, 02 May 2012 21:58:47 -0700
Message-ID: <4FA21087.1080801@gmail.com>
References: <20120503033018.5482.89902.stgit@gitlad.jf.intel.com>	 <20120503033901.5482.27183.stgit@gitlad.jf.intel.com> <1336017985.12425.9.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	Eric Dumazet <edumazet@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:59991 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750968Ab2ECE64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 00:58:56 -0400
Received: by dady13 with SMTP id y13so1032123dad.5
        for <netdev@vger.kernel.org>; Wed, 02 May 2012 21:58:56 -0700 (PDT)
In-Reply-To: <1336017985.12425.9.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/2/2012 9:06 PM, Eric Dumazet wrote:
> On Wed, 2012-05-02 at 20:39 -0700, Alexander Duyck wrote:
>> This change is mostly meant to help improve the readability of
>> tcp_try_coalesce.  I had a few issues since there were several points when
>> the code would test for a conditional, fail, then succeed on another
>> conditional take some action, and then follow a goto back into the previous
>> conditional.  I just tore all of that apart and made the whole thing one
>> linear flow with a single goto.
>>
>> Also there were multiple ways of computing the delta, the one for head_frag
>> made the least amount of sense to me since we were only dropping the
>> sk_buff so I have updated the logic for the stolen head case so that delta
>> is only truesize - sizeof(skb_buff), and for the case where we are dropping
>> the head as well it is truesize - SKB_TRUESIZE(skb_end_pointer - head).
>> This way we can also account for the head_frag with headlen == 0.
>>
>> Signed-off-by: Alexander Duyck<alexander.h.duyck@intel.com>
>> Cc: Eric Dumazet<edumazet@google.com>
>> Cc: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
>> ---
>>
> Sorry I prefer you dont touch this code like this.
>
> The truesize bits must stay as is, since it'll track drivers that lies
> about truesize.

I can understand that.  But from what I can tell the only way they can 
lie about truesize is to actually change the value itself.  The code I 
modified was just tightening things up so we didn't do things like use 
the length to track the truesize like we were in the original code.  
 From what I can tell the new code should have been more accurate.

>>   net/ipv4/tcp_input.c |   80 +++++++++++++++++++++++++++-----------------------
>>   1 files changed, 43 insertions(+), 37 deletions(-)
>>
>> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
>> index c6f78e2..23bc3ff 100644
>> --- a/net/ipv4/tcp_input.c
>> +++ b/net/ipv4/tcp_input.c
>> @@ -4548,62 +4548,68 @@ static bool tcp_try_coalesce(struct sock *sk,
>>   	int i, delta, len = from->len;
>>
>>   	*fragstolen = false;
>> +
>>   	if (tcp_hdr(from)->fin || skb_cloned(to))
>>   		return false;
>> +
>>   	if (len<= skb_tailroom(to)) {
>>   		BUG_ON(skb_copy_bits(from, 0, skb_put(to, len), len));
>> -merge:
>> -		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPRCVCOALESCE);
>> -		TCP_SKB_CB(to)->end_seq = TCP_SKB_CB(from)->end_seq;
>> -		TCP_SKB_CB(to)->ack_seq = TCP_SKB_CB(from)->ack_seq;
>> -		return true;
>> +		goto merge;
>>   	}
>>
>>   	if (skb_has_frag_list(to) || skb_has_frag_list(from))
>>   		return false;
>>
>> -	if (skb_headlen(from) == 0&&
>> -	    (skb_shinfo(to)->nr_frags +
>> -	     skb_shinfo(from)->nr_frags<= MAX_SKB_FRAGS)) {
>> -		WARN_ON_ONCE(from->head_frag);
>> -		delta = from->truesize - ksize(from->head) -
>> -			SKB_DATA_ALIGN(sizeof(struct sk_buff));
>
> This delta was done on purpose. We want the ksize()
The question I have is how can you get into a case where the ksize is 
different from the end offset plus the aligned size of skb_shared_info?  
>From what I can tell it looks like the only place we can lie is if we 
use build_skb with the frag_size option, and in that case we are using a 
page, not kmalloc memory.  Otherwise in all other cases __alloc_skb or 
build_skb is using ksize(skb->head) - SKB_DATA_ALIGN(struct 
skb_shared_info) to set the end pointer, so reversing that should give 
us the same value as ksize(skb->head).

>> -
>> -		WARN_ON_ONCE(delta<  len);
>> -copyfrags:
>> -		memcpy(skb_shinfo(to)->frags + skb_shinfo(to)->nr_frags,
>> -		       skb_shinfo(from)->frags,
>> -		       skb_shinfo(from)->nr_frags * sizeof(skb_frag_t));
>> -		skb_shinfo(to)->nr_frags += skb_shinfo(from)->nr_frags;
>> -
>> -		if (skb_cloned(from))
>> -			for (i = 0; i<  skb_shinfo(from)->nr_frags; i++)
>> -				skb_frag_ref(from, i);
>> -		else
>> -			skb_shinfo(from)->nr_frags = 0;
>> -
>> -		to->truesize += delta;
>> -		atomic_add(delta,&sk->sk_rmem_alloc);
>> -		sk_mem_charge(sk, delta);
>> -		to->len += len;
>> -		to->data_len += len;
>> -		goto merge;
>> -	}
>> -	if (from->head_frag&&  !skb_cloned(from)) {
>> +	if (skb_headlen(from) != 0) {
>>   		struct page *page;
>>   		unsigned int offset;
>>
>> -		if (skb_shinfo(to)->nr_frags + skb_shinfo(from)->nr_frags>= MAX_SKB_FRAGS)
>> +		if (skb_shinfo(to)->nr_frags +
>> +		    skb_shinfo(from)->nr_frags>= MAX_SKB_FRAGS)
>> +			return false;
>> +
>> +		if (!from->head_frag || skb_cloned(from))
>>   			return false;
>> +
>> +		delta = from->truesize - sizeof(struct sk_buff);
>>
It looks like you were thinking of something here since the quote lines 
were broken.  This was the piece I saw in the original code that caught 
my eye as probably being wrong.  We are letting packets using head_frag 
just report length as the truesize.  This is why I favored using the end 
offset.  In the case of us using the head_frag we should only be 
deducting SKB_DATA_ALIGN(sizeof(struct sk_buff)) (I just relized the 
line above is incorrect), and in the case of us dropping the head_frag 
as well we should be able to also deduct the size of the shared_info and 
everything up to the offset of end.

>> +
>>   		page = virt_to_head_page(from->head);
>>   		offset = from->data - (unsigned char *)page_address(page);
>> +
>>   		skb_fill_page_desc(to, skb_shinfo(to)->nr_frags,
>>   				   page, offset, skb_headlen(from));
>>   		*fragstolen = true;
>> -		delta = len; /* we dont know real truesize... */
>> -		goto copyfrags;
>> +	} else {
>> +		if (skb_shinfo(to)->nr_frags +
>> +		    skb_shinfo(from)->nr_frags>  MAX_SKB_FRAGS)
>> +			return false;
>> +
>> +		delta = from->truesize -
>> +			SKB_TRUESIZE(skb_end_pointer(from) - from->head);
> No... SKB_TRUESIZE() doesnt account of power-of-two roundings in
> kmalloc()
You used ksize in alloc_skb or build_skb to set the end pointer.  All I 
am doing by using the end pointer is getting the value you had already 
extracted.  The end pointer should be unmovable once it is set so I 
wouldn't think it would be an issue to use it to compute the truesize 
for the section including the sk_buff and skb->head.


>>   	}
>> -	return false;
>> +
>> +	memcpy(skb_shinfo(to)->frags + skb_shinfo(to)->nr_frags,
>> +	       skb_shinfo(from)->frags,
>> +	       skb_shinfo(from)->nr_frags * sizeof(skb_frag_t));
>> +	skb_shinfo(to)->nr_frags += skb_shinfo(from)->nr_frags;
>> +
>> +	if (!skb_cloned(from))
>> +		skb_shinfo(from)->nr_frags = 0;
>> +
> You break the code here... we had an else.
Yes and no.  I just realized that I didn't need the else because the for 
loop below does nothing if nr_frags is 0.  I suspect gcc is probably 
smart enough to just skip the loop if the skb is cloned.  I should 
probably have added a one line comment explaining that above the loop.

>> +	for (i = 0; i<  skb_shinfo(from)->nr_frags; i++)
>> +		skb_frag_ref(from, i);
>> +
>> +	to->truesize += delta;
>> +	atomic_add(delta,&sk->sk_rmem_alloc);
>> +	sk_mem_charge(sk, delta);
>> +	to->len += len;
>> +	to->data_len += len;
>> +
>> +merge:
>> +	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPRCVCOALESCE);
>> +	TCP_SKB_CB(to)->end_seq = TCP_SKB_CB(from)->end_seq;
>> +	TCP_SKB_CB(to)->ack_seq = TCP_SKB_CB(from)->ack_seq;
>> +	return true;
>>   }
>>
>>   static void kfree_skb_partial(struct sk_buff *skb, bool head_stolen)
>>
> Really this patch is too hard to review.
Yeah, it is a bit difficult.  After Dave pulled your patches it ended up 
pushing most of the changes into this one.  I'll see if I can break this 
back up into smaller bits.  I just needed to flush the patches I had so 
I could get some feedback and stop talking in circles about the other patch.

Thanks,

Alex
