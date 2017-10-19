From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: Get rid of RCU callbacks in TC filters?
Date: Thu, 19 Oct 2017 08:34:11 -0700
Message-ID: <52808e54-2f59-49c8-37be-d226e79fe286@gmail.com>
References: <CAM_iQpU1hF9v1+bek9CQkdbjS_2nctwpaSXyiNLiBHPC6WEYKQ@mail.gmail.com>
 <20171018193548.GM3521@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Chris Mi <chrism@mellanox.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Jiri Pirko <jiri@resnulli.us>
To: paulmck@linux.vnet.ibm.com, Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:53208 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751760AbdJSPeb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 11:34:31 -0400
Received: by mail-pf0-f195.google.com with SMTP id e64so6824360pfk.9
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 08:34:31 -0700 (PDT)
In-Reply-To: <20171018193548.GM3521@linux.vnet.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/18/2017 12:35 PM, Paul E. McKenney wrote:
> On Wed, Oct 18, 2017 at 10:36:28AM -0700, Cong Wang wrote:
>> Hi, all
>>
>> Recently, the RCU callbacks used in TC filters and TC actions keep
>> drawing my attention, they introduce at least 4 race condition bugs:
>>
>> 1. A simple one fixed by Daniel:
>>
>> commit c78e1746d3ad7d548bdf3fe491898cc453911a49
>> Author: Daniel Borkmann <daniel@iogearbox.net>
>> Date:   Wed May 20 17:13:33 2015 +0200
>>
>>     net: sched: fix call_rcu() race on classifier module unloads
>>
>> 2. A very nasty one fixed by me:
>>
>> commit 1697c4bb5245649a23f06a144cc38c06715e1b65
>> Author: Cong Wang <xiyou.wangcong@gmail.com>
>> Date:   Mon Sep 11 16:33:32 2017 -0700
>>
>>     net_sched: carefully handle tcf_block_put()
>>
>> 3. Two more bugs found by Chris:
>> https://patchwork.ozlabs.org/patch/826696/
>> https://patchwork.ozlabs.org/patch/826695/
>>
>>
>> Usually RCU callbacks are simple, however for TC filters and actions,
>> they are complex because at least TC actions could be destroyed
>> together with the TC filter in one callback. And RCU callbacks are
>> invoked in BH context, without locking they are parallel too. All of
>> these contribute to the cause of these nasty bugs. It looks like they
>> bring us more problems than benefits.
>>
>> Therefore, I have been thinking about getting rid of these callbacks,
>> because they are not strictly necessary, callers of these call_rcu()
>> are all on slow path and have RTNL lock, so blocking is permitted in
>> their contexts, and _I think_ it does not harm to use
>> synchronize_rcu() on slow paths, at least I can argue RTNL lock is
>> already there and is a bottleneck if we really care. :)
>>
>> There are 3 solutions here:
>>
>> 1) Get rid of these RCU callbacks and use synchronize_rcu(). The
>> downside is this could hurt the performance of deleting TC filters,
>> but again it is slow path comparing to skb classification path. Note,
>> it is _not_ merely replacing call_rcu() with synchronize_rcu(),
>> because many call_rcu()'s are actually in list iterations, we have to
>> use a local list and call list_del_rcu()+list_add() before
>> synchronize_rcu() (Or is there any other API I am not aware of?). If
>> people really hate synchronize_rcu() because of performance, we could
>> also defer the work to a workqueue and callers could keep their
>> performance as they are.
>>
>> 2) Introduce a spinlock to serialize these RCU callbacks. But as I
>> said in commit 1697c4bb5245 ("net_sched: carefully handle
>> tcf_block_put()"), it is very hard to do because of tcf_chain_dump().
>> Potentially we need to do a lot of work to make it possible, if not
>> impossible.
>>
>> 3) Keep these RCU callbacks and fix all race conditions. Like what
>> Chris tries to do in his patchset, but my argument is that we can not
>> prove we are really race-free even with Chris' patches and his patches
>> are already large enough.
>>

My take on this would be to stay with the current RCU callbacks and try
to simplify the implementation. Falling back to sync operations seems
like a step backwards to me. I know update/delete of filters is currently
a pain point for some use cases so getting the RTNL out of the way may
become a requirement to support those (alternatively maybe batching is
good enough).

I guess at a high level with Cris' patches actions are now doing reference
counting correctly. If shared filters also do reference counting similarly
we should be OK right? (yes I know simplifying maybe too much to be
meaningful)

Are we aware of any outstanding problem areas?

>>
>> What do you think? Any other ideas?
> 
> 4) Move from call_rcu() to synchronize_rcu(), but if feasible use one
> synchronize_rcu() for multiple deletions/iterations.
> 
> 5) Keep call_rcu(), but have the RCU callback schedule a workqueue.
> The workqueue could then use blocking primitives, for example, acquiring
> RTNL.
> 
> 6) As with #5, have the RCU callback schedule a workqueue, but aggregate
> workqueue scheduling using a timer.  This would reduce the number of
> RTNL acquisitions.
> 
> 7) As with #5, have the RCU callback schedule a workqueue, but have each
> iterator accumulate a list of things removed and do call_rcu() on the
> list.  This is an alternative way of aggregating to reduce the number
> of RTNL acquisitions.
> 
> There are many other ways to skin this cat.
> 
> 							Thanx, Paul
> 
Batching will probably be needed soon regardless for the hardware offload
folks. 

Thanks,
John
