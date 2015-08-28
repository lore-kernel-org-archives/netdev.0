From: Weilong Chen <chenweilong@huawei.com>
Subject: Re: [PATCH net-next] net: Check frag_lists first to prevent data out
 of order
Date: Fri, 28 Aug 2015 11:35:40 +0800
Message-ID: <55DFD70C.2030001@huawei.com>
References: <1440636965-11552-1-git-send-email-chenweilong@huawei.com>
 <1440641561.8932.36.camel@edumazet-glaptop2.roam.corp.google.com>
 <1440642184.8932.37.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <edumazet@google.com>,
	<alexander.h.duyck@redhat.com>, <willemb@google.com>,
	<hannes@stressinduktion.org>, <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:8980 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751210AbbH1DgR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 23:36:17 -0400
In-Reply-To: <1440642184.8932.37.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for reply.

> On Wed, 2015-08-26 at 19:12 -0700, Eric Dumazet wrote:
>> On Thu, 2015-08-27 at 08:56 +0800, chenweilong@huawei.com wrote:
>>> From: Weilong Chen <chenweilong@huawei.com>
>>>
>>> When try to merge several skbs to prior one, if the frag_list is
>>> used and the the last one is a small packet, once the condition
>>> "len <= skb_tailroom(to)" is satisfied, we will get a wrong
>>> packet!
>>> This patch just check frag_lists before the condtion to prevent
>>> this from happening.
>>>
>>> Signed-off-by: Weilong Chen <chenweilong@huawei.com>
>>> ---
>>>   net/core/skbuff.c | 6 +++---
>>>   1 file changed, 3 insertions(+), 3 deletions(-)
>>>
>>> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
>>> index 8a725cc..d08edcb 100644
>>> --- a/net/core/skbuff.c
>>> +++ b/net/core/skbuff.c
>>> @@ -4133,6 +4133,9 @@ bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
>>>   	if (skb_cloned(to))
>>>   		return false;
>>>
>>> +	if (skb_has_frag_list(to) || skb_has_frag_list(from))
>>> +		return false;
>>> +
>>>   	if (len <= skb_tailroom(to)) {
>>>   		if (len)
>>>   			BUG_ON(skb_copy_bits(from, 0, skb_put(to, len), len));
>>> @@ -4140,9 +4143,6 @@ bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
>>>   		return true;
>>>   	}
>>>
>>> -	if (skb_has_frag_list(to) || skb_has_frag_list(from))
>>> -		return false;
>>> -
>>>   	if (skb_headlen(from) != 0) {
>>>   		struct page *page;
>>>   		unsigned int offset;
>>
>> Sigh.
>>
>> No idea what problem you tried to solve.
>>
>> This patch is not needed.
>>
>> If (len <= skb_tailroom()), then it is obviously correct to copy_bits()
>> the bytes.
>>
>> Hints :
>>
>> - If @to has a fraglist, then skb_tailroom(to) is 0 so the copy can not
>> be done.

How to make sure it?
In my test, @to has a fraglist, but skb_tailroom(to) is not 0!
The test is about tipc, the function tipc_buf_append will merge 3 skbs 
to one:
packet 1: len = 1420 skb_tailroom = 190
packet 2: len = 1420
	packet 2 will be add to 1' fraglist, but not update skb_tailroom
packet 3: len = 60
	Here's the error!

>>
>> - If @from has a fraglist, it is not relevant as we copy it into @to and
>> will free @from.
>
> This is going to be a FAQ
>
> http://www.spinics.net/lists/netdev/msg315090.html
>
>
>
>
>
> .
>
