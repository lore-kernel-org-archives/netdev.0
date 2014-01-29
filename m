From: Andre Naujoks <nautsch2@gmail.com>
Subject: Re: [PATCH stable 3.11+] can: bcm: add skb destructor
Date: Wed, 29 Jan 2014 08:40:03 +0100
Message-ID: <52E8B053.2030808@gmail.com>
References: <52E81631.50607@hartkopp.net>	 <1390948108.28432.20.camel@edumazet-glaptop2.roam.corp.google.com>	 <52E833ED.4080006@hartkopp.net> <1390953066.28432.26.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:57241 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750834AbaA2HkG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jan 2014 02:40:06 -0500
Received: by mail-ee0-f43.google.com with SMTP id c41so687780eek.30
        for <netdev@vger.kernel.org>; Tue, 28 Jan 2014 23:40:05 -0800 (PST)
In-Reply-To: <1390953066.28432.26.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29.01.2014 00:51, schrieb Eric Dumazet:
> On Tue, 2014-01-28 at 23:49 +0100, Oliver Hartkopp wrote:
> 
>> The sbk->sk reference is used to make sure in AF_CAN to identify the
>> originating socket (if any) to not deliver echoed CAN frames to the
>> originating application.
>>
>> See first check in raw_rcv() in net/can/raw.c
> 
> Nice, this is buggy.
> 
>>
>>>
>>> Instead of understanding the issue, it seems this patch exactly shutup
>>> the useful warning.
>>
>> I would have been happy to have this a warning and not a bug as you
>> implemented it.
>>
> 
> Yes, I understand you are not happy of our work to discover CAN bugs.
> 
>> I don't need this warning as I'm using skb_alloc in the cases where CAN frames
>> are generated autonomously. They are not triggered through a direct socket
>> write operation nor do they need to take case about any sock wmem.
>>
>> The useful warning/bug might be nice for common use cases. I'm using plain
>> skb_alloc here for fire-and-forget skbs.
>>
>> So I need to shutup the useful warning or revert the two commits at
>> skb_orphan(). I would prefer the latter.
>>
>>>
>>> If you set skb->sk, then you expect a future reader of skb->sk to be
>>> 100% sure the socket did not disappear.
>>
>> It's a fire-and-forget skb. I don't need to care if the socket disappears.
>> If it disappears no new traffic is generated. That's enough.
>>
>>>
>>> I do not see this explained in the changelog.
>>>
>>
>> I hopefully was able to make it more clearly.
>> See Documentation/networking/can.txt
>>
> 
> 
> Just take a reference on the damn socket, and we do not have to worry.
> 
> bcm_tx_send() suffers from the same problem
> 
> can_send() is buggy as well :
> 
> newskb->sk = skb->sk; // line 293
> 
> dev_queue_xmit() can queue a packet a long time, and some packet qdisc
> even look at skb->sk.
> 
> So this is really wrong to assume only net/can can assume things about
> skb->sk, and not care of net/core or net/sched users.
> 
> I absolutely disagree with your patch. You need quite different _real_
> fixes.

Hi.

Even if this is a bug in the CAN BCM implementation. Your "fix" just
enabled a user space application to shut down any machine with a kernel
containing the BUG_ON patch.

If the BCM implementation is broken, it needs to be fixed. But this is a
regression that causes Kernel crashes, where there were none before.

As I am using the BCM, I would rather have a flawed but working
implementation than an unusable one. If the empty socket destructor
enables the system to work again, then I would like to see it. But, like
Oliver, I would prefer the BUG_ON patch reverted at least until this
issue is resolved.

Regards
  Andre

> 
> 
> 
