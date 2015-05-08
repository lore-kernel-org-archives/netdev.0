From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC PATCH net-next 01/11] netns: Fix race between put_net() and netlink_kernel_create()
Date: Fri, 08 May 2015 06:20:10 -0500
Message-ID: <87bnhv9uz9.fsf@x220.int.ebiederm.org>
References: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>
	<1430988770-28907-2-git-send-email-ying.xue@windriver.com>
	<20150507090450.GA31792@gondor.apana.org.au>
	<CAHA+R7Mc==jHi-vtyNwboYW-ysacgbA-yAG+tetx8HJFUrrf9Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Ying Xue <ying.xue@windriver.com>,
	netdev <netdev@vger.kernel.org>, xemul@openvz.org,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, maxk@qti.qualcomm.com,
	Stephen Hemminger <stephen@networkplumber.org>,
	Thomas Graf <tgraf@suug.ch>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Tom Herbert <tom@herbertland.com>,
	James Chapman <jchapman@katalix.com>,
	Erik Hugne <erik.hugne@ericsson.com>, jon.maloy@ericsson.com,
	horms@verge.net.au
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:51344 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753129AbbEHLYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 07:24:43 -0400
In-Reply-To: <CAHA+R7Mc==jHi-vtyNwboYW-ysacgbA-yAG+tetx8HJFUrrf9Q@mail.gmail.com>
	(Cong Wang's message of "Thu, 7 May 2015 10:19:12 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <cwang@twopensource.com> writes:

> On Thu, May 7, 2015 at 2:04 AM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
>> On Thu, May 07, 2015 at 04:52:40PM +0800, Ying Xue wrote:
>>>
>>> @@ -409,12 +410,17 @@ void __put_net(struct net *net)
>>>  {
>>>       /* Cleanup the network namespace in process context */
>>>       unsigned long flags;
>>> +     bool added = false;
>>>
>>>       spin_lock_irqsave(&cleanup_list_lock, flags);
>>> -     list_add(&net->cleanup_list, &cleanup_list);
>>> +     if (list_empty(&net->cleanup_list)) {
>>> +             list_add(&net->cleanup_list, &cleanup_list);
>>> +             added = true;
>>> +     }
>>
>> Stop right there.  If a ref count is hitting zero twice you've
>> got big problems.  Because it means that after hitting zero the
>> first time it'll become positive again (if only briefly) which
>> opens you up to a race against the cleanup.
>
> That is true.
>
>>
>> So this idea is a non-starter.
>>
>> The rules for ref counts are really simple, if you hit zero then
>> you're dead.  Can someone explain to me in simple terms why this
>> ref count is special and needs to hit zero twice?
>
> Because after it hits zero, it queues the final cleanup to a workqueue,
> which could be delayed (depends on when the worker will be scheduled),
> therefore there is a small window that new ->init() could come in.

The bad case in all of this is if we hit that window and increment the
count.  The namespace could be removed from the lists ->exit() methods
could run.  Then the reference count could drop to zero again.

Having a network namespace alive with cleanup methods having already run
is too nasty to think about.  We really don't want to do that.

Eric
