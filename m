From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg/tcp: fix warning caused b res->usage go to negative.
Date: Tue, 10 Apr 2012 13:15:57 +0900
Message-ID: <4F83B3FD.4010107@jp.fujitsu.com>
References: <4F7408B7.9090706@jp.fujitsu.com> <4F740AEF.7090900@jp.fujitsu.com> <4F742983.1080402@parallels.com> <4F750FE8.2030800@jp.fujitsu.com> <4F7F1091.9040204@parallels.com> <4F839CF1.5050104@jp.fujitsu.com> <4F83A022.1000701@parallels.com> <4F83A29D.1060402@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Glauber Costa <glommer@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:50422 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828Ab2DJERs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 00:17:48 -0400
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 0A84D3EE0AE
	for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 13:17:47 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E252245DD73
	for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 13:17:46 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BFE7645DE50
	for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 13:17:46 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B3BC21DB803A
	for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 13:17:46 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 623561DB803C
	for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 13:17:46 +0900 (JST)
In-Reply-To: <4F83A29D.1060402@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2012/04/10 12:01), Glauber Costa wrote:

> On 04/09/2012 11:51 PM, Glauber Costa wrote:
>> On 04/09/2012 11:37 PM, KAMEZAWA Hiroyuki wrote:
>>> Hm. What happens in following sequence ?
>>>
>>>     1. a memcg is created
>>>     2. put a task into the memcg, start tcp steam
>>>     3. set tcp memory limit
>>>
>>> The resource used between 2 and 3 will cause the problem finally.
>>
>> I don't get it. if a task is in memcg, but no limit is set,
>> that socket will be assigned null memcg, and will stay like that
>> forever. Only new sockets will have the new memcg pointer.
>>
>> And previously, we could have the memcg pointer alive, but the jump
>> labels to be disabled. With the patch I posted, this can't happen
>> anymore, since the jump labels are guaranteed to live throughout the
>> whole socket life.
>>
>>> Then, Dave's request
>>> ==
>>> You must either:
>>>
>>> 1) Integrate the socket's existing usage when the limit is set.
>>>
>>> 2) Avoid accounting completely for a socket that started before
>>>      the limit was set.
>>> ==
>>> are not satisfied. So, we need to have a state per sockets, it's accounted
>>> or not. I'll look into this problem again, today.
>>>
>>
>> Of course they are.
>>
>> Every socket created before we set the limit is not accounted.
>> This is 2) that Dave mentioned, and it was *always* this way.
>>
>> The problem here was the opposite: You could disable the jump labels
>> with sockets still in flight, because we were disabling it based on
>> the limit being set back to unlimited.
>>
>> What this patch does, is defer that until the last socket limited dies.
>>
> 
> Okay, there is an additional thing to be considered here:
> 
> Due to the nature of how jump label works, once they are enabled for one
> of the cgroups, they will be enabled for all of them. So the patch I
> sent may still break in some scenarios because of the way we record that
> the limit was set.
> 
> However, if my theory behind what is causing the problem is correct,
> this patch should fix the issue for you. 


Now, our issue is leak of accounting, regardless of warning.

> Let me know if it does, and

> I'll work on the final solution.
> 


The problem is that jump_label updating is not atomic_ops.

I'm _not_ sure the update order of the jump_label in sock_update_memcg()
and other jump instructions inserted at accounting.

For example, if the jump instruction in sock_update_memcg() is updated 1st
and others are updated later, it's unclear whether sockets which has _valid_
sock->sk_cgrp will be accounted or not because accounting jump instruction
may not be updated yet.

Hopefully, label in sock_update_memcg should be updated last...

Hm. If I do, I'll add one more key as:

atomic_t	sock_should_memcg_aware;

And update 2 keys in following order.

At enable
	static_key_slow_inc(&memcg_socket_limit_enabled)
	atomic_inc(&sock_should_memcg_aware);

At disable
	atomic_dec(&sock_should_memcg_aware);
	static_key_slow_dec(&memcg_socket_limit_enabled)

And
==
void sock_update_memcg(struct sock *sk)
{
        if (atomic_read(&sock_should_memcg_aware)) {

==


Thanks,
-Kame
