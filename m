From: Ben Greear <greearb@candelatech.com>
Subject: Re: How to best consolidate list of skbs (msdu) for receive?
Date: Thu, 27 Feb 2014 14:38:09 -0800
Message-ID: <530FBE51.8040905@candelatech.com>
References: <530F85AE.8060002@candelatech.com>   <CAGVrzcajmuGQRi84WqWrxyUK2+xG1+b7EMTwRk4WpsDnp0B7qQ@mail.gmail.com>  <1393536113.26794.41.camel@edumazet-glaptop2.roam.corp.google.com>  <530FB348.2070701@candelatech.com> <1393540305.26794.47.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:49719 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751232AbaB0WiQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 17:38:16 -0500
In-Reply-To: <1393540305.26794.47.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/27/2014 02:31 PM, Eric Dumazet wrote:
> On Thu, 2014-02-27 at 13:51 -0800, Ben Greear wrote:
> 
>> That said, the code below appears to work, even if it is
>> not as efficient as it might be?
>>
>> 			if (msdu_chaining) {
>> 				struct sk_buff *next = msdu_head->next;
>> 				struct sk_buff *to_free = next;
>> 				int space;
>> 				static int do_once = 1;
>> 				msdu_head->next = NULL;
>>
>> 				if (unlikely(do_once)) {
>> 					ath10k_warn("htt rx msdu_chaining detected %d\n",
>> 						    msdu_chaining);
>> 					do_once = 0;
>> 				}
>>
>> 				while (next) {
>> 					space = next->len - skb_tailroom(msdu_head);
>>
>> 					if ((space > 0) &&
>> 					    (pskb_expand_head(msdu_head, 0, space, GFP_ATOMIC) < 0)) {
>> 						/* TODO:  bump some rx-oom error stat */
>> 						goto outside_continue;
>> 					}
>> 					skb_copy_from_linear_data(next, skb_put(msdu_head, next->len),
>> 								  next->len);
>> 					next = next->next;
>> 				}
> 
> Yep, this is very inefficient , you might copy data very often in
> pskb_expand_head(), then in skb_copy_from_linear_data()

Based on the code above, do you think skb_try_coalesce() is
the best option for this logic?

> Also, if total length is big, you end up doing high order allocations,
> since you generate a linear skb. This might fail under memory pressure.
> 
> What is the maximal skb->len of resulting skb ?

According to the page below, msdu are limited to 7935 total.  In my testing, I have seen a maximum
of 2 chained skbs (3 total).  I do not know the average total combined skb size...but since it
has upper bound of 8k, perhaps that doesn't matter so much?

http://ergodicthoughts.blogspot.com/2012/02/difference-between-mpdu-msdu-ampdu-and.html

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
