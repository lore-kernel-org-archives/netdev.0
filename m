From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg/tcp: fix warning caused b res->usage go to negative.
Date: Tue, 10 Apr 2012 12:21:36 +0900
Message-ID: <4F83A740.4070109@jp.fujitsu.com>
References: <4F7408B7.9090706@jp.fujitsu.com> <4F740AEF.7090900@jp.fujitsu.com> <4F742983.1080402@parallels.com> <4F750FE8.2030800@jp.fujitsu.com> <4F7F1091.9040204@parallels.com> <4F839CF1.5050104@jp.fujitsu.com> <4F83A022.1000701@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Glauber Costa <glommer@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail6.fujitsu.co.jp ([192.51.44.36]:32819 "EHLO
	fgwmail6.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753389Ab2DJDXW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2012 23:23:22 -0400
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id A281A3EE0B6
	for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 12:23:20 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8A5CC45DE7E
	for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 12:23:20 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 679DE45DE7D
	for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 12:23:20 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 56C10E08001
	for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 12:23:20 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 10B7BE08004
	for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 12:23:20 +0900 (JST)
In-Reply-To: <4F83A022.1000701@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2012/04/10 11:51), Glauber Costa wrote:

> On 04/09/2012 11:37 PM, KAMEZAWA Hiroyuki wrote:
>> Hm. What happens in following sequence ?
>>
>>    1. a memcg is created
>>    2. put a task into the memcg, start tcp steam
>>    3. set tcp memory limit
>>
>> The resource used between 2 and 3 will cause the problem finally.
> 
> I don't get it. if a task is in memcg, but no limit is set,
> that socket will be assigned null memcg, and will stay like that
> forever. Only new sockets will have the new memcg pointer.
> 
> And previously, we could have the memcg pointer alive, but the jump
> labels to be disabled. With the patch I posted, this can't happen
> anymore, since the jump labels are guaranteed to live throughout the
> whole socket life.
> 
>> Then, Dave's request
>> ==
>> You must either:
>>
>> 1) Integrate the socket's existing usage when the limit is set.
>>
>> 2) Avoid accounting completely for a socket that started before
>>     the limit was set.
>> ==
>> are not satisfied. So, we need to have a state per sockets, it's accounted
>> or not. I'll look into this problem again, today.
>>
> 
> Of course they are.
> 
> Every socket created before we set the limit is not accounted.
> This is 2) that Dave mentioned, and it was *always* this way.
> 
> The problem here was the opposite: You could disable the jump labels
> with sockets still in flight, because we were disabling it based on
> the limit being set back to unlimited.
> 
> What this patch does, is defer that until the last socket limited dies.
> 

Thank you for explanation. Hmm, sk->cgrp check ?
Ah, yes it's updated by sock_update_memcg() under jump_label, which is
called by tcp_v4_init_sock().
Hm. and jump_label()'s atomic counter and mutex_lock will be a guard against
set/unset race. Ok.

BTW, what will happen in following case ?

Assume that the last memcg is destroyed and call jump_label_dec. And the
thread waits for jump_label_mutex for a while.

      CPU A                                           CPU B

    jump_label_dec() # mutex will be held        sock_update_memcg() is called
                                                 sk_cgrp is set.
    ...modify instructions                       some accounting is done.
    mutex_unlock()

I wonder you need some serialization somewhere OR disallow turning off accounting.                                              

Thanks,
-Kame
