From: Felix Fietkau <nbd@openwrt.org>
Subject: Re: [RFC] skb: avoid unnecessary reallocations in __skb_cow
Date: Tue, 29 May 2012 14:41:12 +0200
Message-ID: <4FC4C3E8.6080206@openwrt.org>
References: <1338132370-88299-1-git-send-email-nbd@openwrt.org> <1338294848.2840.15.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:36266 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750715Ab2E2MlO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 May 2012 08:41:14 -0400
In-Reply-To: <1338294848.2840.15.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2012-05-29 2:34 PM, Eric Dumazet wrote:
> On Sun, 2012-05-27 at 17:26 +0200, Felix Fietkau wrote:
>> At the beginning of __skb_cow, headroom gets set to a minimum of
>> NET_SKB_PAD. This causes unnecessary reallocations if the buffer was not
>> cloned and the headroom is just below NET_SKB_PAD, but still more than the
>> amount requested by the caller.
>> This was showing up frequently in my tests on VLAN tx, where
>> vlan_insert_tag calls skb_cow_head(skb, VLAN_HLEN).
>> 
>> Fix this by only setting the headroom delta if either there is less
>> headroom than specified by the caller, or if reallocation has to be done
>> anyway because the skb was cloned.
>> 
>> Signed-off-by: Felix Fietkau <nbd@openwrt.org>
>> ---
>>  include/linux/skbuff.h |    9 ++++++---
>>  1 files changed, 6 insertions(+), 3 deletions(-)
>> 
>> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
>> index 0e50171..1898471 100644
>> --- a/include/linux/skbuff.h
>> +++ b/include/linux/skbuff.h
>> @@ -1894,12 +1894,15 @@ static inline int skb_clone_writable(const struct sk_buff *skb, unsigned int len
>>  static inline int __skb_cow(struct sk_buff *skb, unsigned int headroom,
>>  			    int cloned)
>>  {
>> +	unsigned int alloc_headroom = headroom;
>>  	int delta = 0;
>>  
>>  	if (headroom < NET_SKB_PAD)
>> -		headroom = NET_SKB_PAD;
>> -	if (headroom > skb_headroom(skb))
>> -		delta = headroom - skb_headroom(skb);
>> +		alloc_headroom = NET_SKB_PAD;
>> +	if (headroom > skb_headroom(skb) ||
>> +	    (cloned && alloc_headroom > skb_headroom(skb))) {
>> +		delta = alloc_headroom - skb_headroom(skb);
>> +	}
>>  
>>  	if (delta || cloned)
>>  		return pskb_expand_head(skb, ALIGN(delta, NET_SKB_PAD), 0,
> 
> Nice catch.
> 
> Scratching my head on this one. Why not the obvious fix ?
If we're reallocating anyway, we might as well put in more headroom than
requested, in case something else needs even more than that.

- Felix
