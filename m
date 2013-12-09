From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH net v6 1/2] net: sched: tbf: fix the calculation of max_size
Date: Mon, 9 Dec 2013 20:21:45 +0800
Message-ID: <52A5B5D9.7000204@huawei.com>
References: <1386313205-87660-1-git-send-email-yangyingliang@huawei.com> <1386313205-87660-2-git-send-email-yangyingliang@huawei.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7468@saturn3.aculab.com> <52A5384A.8050106@huawei.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7471@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <eric.dumazet@gmail.com>, <brouer@redhat.com>, <jpirko@redhat.com>,
	<jbrouer@redhat.com>
To: David Laight <David.Laight@ACULAB.COM>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:26501 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932626Ab3LIMZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 07:25:13 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7471@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/9 18:07, David Laight wrote:
>> From: Yang Yingliang
>> On 2013/12/6 18:56, David Laight wrote:
>>>> From: Yang Yingliang
>>> ...
>>>
>>> You are multiplying two values then dividing by 10**9
>>> I'd guess that the intermediate value might exceed 2**64.
>>>
>>>> +	if (unlikely(r->linklayer == TC_LINKLAYER_ATM))
>>>> +		len = (len / 53) * 48;
>>>
>>> You probably want to do the multiply first.
>>> But why not scale rate_bytes_ps instead.
>>>
>>
>> When the linklayer is ATM, the formula to calculate tokens is:
>>
>> ((u64)(DIV_ROUND_UP(len,48)*53) * r->mult) >> r->shift
>>
>> So, I scale len here.
> 
> Seems to me that there are a lot of unnecessary multiplies and
> divides going on here.
> Looks to me like the code was originally written to require one
> multiply and one shift for each packet.

The way to calc tokens in psched_l2t_ns() means:
we got a payload which length is 'len'. To get the actual size we
need send, round len up to a multiple of 53. After getting the
size, we do multiply and shift to calculate tokens that we need.

> 
> In any case the latter code is allowing for more of the ATM cell
> overhead. I'm not at all sure the intent is to remove that when
> setting up the constants.
> 
> OTOH should this code be worrying about the packet overheads at all?
> Does it add in the ethernet pre-emable, CRC and inter packet gap?

This overhead is sent from userspace by tc.

> 
> I'd guess that the most the ATM code should do it round the length
> up to a multiple of 48 (user payload in a cell).

53 is ATM cell size include header, sending a header needs tokens as
well. I'd guess round the length up to a multiple of 53 in psched_l2t_ns()
is necessary.


Regards,
Yang
