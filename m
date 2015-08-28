From: Weilong Chen <chenweilong@huawei.com>
Subject: Re: [PATCH net-next] net: Check frag_lists first to prevent data out
 of order
Date: Fri, 28 Aug 2015 13:33:14 +0800
Message-ID: <55DFF29A.1090208@huawei.com>
References: <1440636965-11552-1-git-send-email-chenweilong@huawei.com>
 <1440641561.8932.36.camel@edumazet-glaptop2.roam.corp.google.com>
 <1440642184.8932.37.camel@edumazet-glaptop2.roam.corp.google.com>
 <55DFD70C.2030001@huawei.com>
 <1440736631.8932.43.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <edumazet@google.com>,
	<alexander.h.duyck@redhat.com>, <willemb@google.com>,
	<hannes@stressinduktion.org>, <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:20523 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751005AbbH1Fdv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 01:33:51 -0400
In-Reply-To: <1440736631.8932.43.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



=E5=9C=A8 2015/8/28 12:37, Eric Dumazet =E5=86=99=E9=81=93:
> On Fri, 2015-08-28 at 11:35 +0800, Weilong Chen wrote:
>> Thanks for reply.
>>
>>> On Wed, 2015-08-26 at 19:12 -0700, Eric Dumazet wrote:
>>>> On Thu, 2015-08-27 at 08:56 +0800, chenweilong@huawei.com wrote:
>>>>> From: Weilong Chen <chenweilong@huawei.com>
>>>>>
>>>>> When try to merge several skbs to prior one, if the frag_list is
>>>>> used and the the last one is a small packet, once the condition
>>>>> "len <=3D skb_tailroom(to)" is satisfied, we will get a wrong
>>>>> packet!
>>>>> This patch just check frag_lists before the condtion to prevent
>>>>> this from happening.
>>>>>
>>>>> Signed-off-by: Weilong Chen <chenweilong@huawei.com>
>>>>> ---
>>>>>    net/core/skbuff.c | 6 +++---
>>>>>    1 file changed, 3 insertions(+), 3 deletions(-)
>>>>>
>>>>> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
>>>>> index 8a725cc..d08edcb 100644
>>>>> --- a/net/core/skbuff.c
>>>>> +++ b/net/core/skbuff.c
>>>>> @@ -4133,6 +4133,9 @@ bool skb_try_coalesce(struct sk_buff *to, s=
truct sk_buff *from,
>>>>>    	if (skb_cloned(to))
>>>>>    		return false;
>>>>>
>>>>> +	if (skb_has_frag_list(to) || skb_has_frag_list(from))
>>>>> +		return false;
>>>>> +
>>>>>    	if (len <=3D skb_tailroom(to)) {
>>>>>    		if (len)
>>>>>    			BUG_ON(skb_copy_bits(from, 0, skb_put(to, len), len));
>>>>> @@ -4140,9 +4143,6 @@ bool skb_try_coalesce(struct sk_buff *to, s=
truct sk_buff *from,
>>>>>    		return true;
>>>>>    	}
>>>>>
>>>>> -	if (skb_has_frag_list(to) || skb_has_frag_list(from))
>>>>> -		return false;
>>>>> -
>>>>>    	if (skb_headlen(from) !=3D 0) {
>>>>>    		struct page *page;
>>>>>    		unsigned int offset;
>>>>
>>>> Sigh.
>>>>
>>>> No idea what problem you tried to solve.
>>>>
>>>> This patch is not needed.
>>>>
>>>> If (len <=3D skb_tailroom()), then it is obviously correct to copy=
_bits()
>>>> the bytes.
>>>>
>>>> Hints :
>>>>
>>>> - If @to has a fraglist, then skb_tailroom(to) is 0 so the copy ca=
n not
>>>> be done.
>>
>> How to make sure it?
>> In my test, @to has a fraglist, but skb_tailroom(to) is not 0!
>> The test is about tipc, the function tipc_buf_append will merge 3 sk=
bs
>> to one:
>> packet 1: len =3D 1420 skb_tailroom =3D 190
>> packet 2: len =3D 1420
>> 	packet 2 will be add to 1' fraglist, but not update skb_tailroom
>> packet 3: len =3D 60
>> 	Here's the error!
>
> Then fix tipc, or make sure you read and understood the code.
>
> By definition, if one skb has something in fraglist, it is non linear=
=2E
>
> If you read skb_tailroom(), you'll see this function returns 0 if skb=
 is
> non linear.

Yes you'er right, when packet 2 is add to 1' fraglist, tipc should

update the packet 1' 'len' and 'data_len'. In my kernel(v3.10), it

doesn't do that, which was corrected in commit 5074a (v3.16).

Thanks for your patience

>
> include/linux/skbuff.h-/**
> include/linux/skbuff.h: *       skb_tailroom - bytes at buffer end
> include/linux/skbuff.h- *       @skb: buffer to check
> include/linux/skbuff.h- *
> include/linux/skbuff.h- *       Return the number of bytes of free sp=
ace at the tail of an sk_buff
> include/linux/skbuff.h- */
> include/linux/skbuff.h:static inline int skb_tailroom(const struct sk=
_buff *skb)
> include/linux/skbuff.h-{
> include/linux/skbuff.h- return skb_is_nonlinear(skb) ? 0 : skb->end -=
 skb->tail;
> include/linux/skbuff.h-}
>
>
>
>
> .
>
