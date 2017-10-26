From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net 00/15] net_sched: remove RCU callbacks from TC
Date: Wed, 25 Oct 2017 21:49:09 -0700
Message-ID: <CAM_iQpXQAeXeVtUNBTsF6VxR6OiGFbQgXiRFzrRrTQ72_6fxCA@mail.gmail.com>
References: <20171023220304.2268-1-xiyou.wangcong@gmail.com>
 <20171025.104353.1317026584880877750.davem@davemloft.net> <CAM_iQpVLHLx9eVgO0S--iq-XkhZE82Y30Z0REwU6qx8OGgm+mA@mail.gmail.com>
 <20171026001916.GU3659@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Chris Mi <chrism@mellanox.com>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:50032 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750859AbdJZEta (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 00:49:30 -0400
Received: by mail-pf0-f193.google.com with SMTP id i5so1636473pfe.6
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 21:49:29 -0700 (PDT)
In-Reply-To: <20171026001916.GU3659@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 25, 2017 at 5:19 PM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
> On Wed, Oct 25, 2017 at 03:37:40PM -0700, Cong Wang wrote:
>> My solution is introducing a workqueue for tc filters
>> and let each RCU callback defer the work to this
>> workqueue. I solve the flush_workqueue() deadlock
>> by queuing another work in the same workqueue
>> at the end, so the execution order should be as same
>> as it is now. The ugly part is now tcf_block_put() which
>> looks like below:
>>
>>
>> static void tcf_block_put_final(struct work_struct *work)
>> {
>>         struct tcf_block *block = container_of(work, struct tcf_block, work);
>>         struct tcf_chain *chain, *tmp;
>>
>>         /* At this point, all the chains should have refcnt == 1. */
>>         rtnl_lock();
>>         list_for_each_entry_safe(chain, tmp, &block->chain_list, list)
>>                 tcf_chain_put(chain);
>>         rtnl_unlock();
>>         kfree(block);
>> }
>
> I am guessing that tcf_chain_put() sometimes does a call_rcu(),
> and the callback function in turn calls schedule_work(), and that
> tcf_block_put_deferred() is the workqueue handler function.


Yes, tcf_chain_put() triggers call_rcu() indirectly during flush,
this is why we have rcu_barrier()'s in current code base.


>
>> static void tcf_block_put_deferred(struct work_struct *work)
>> {
>>         struct tcf_block *block = container_of(work, struct tcf_block, work);
>>         struct tcf_chain *chain;
>>
>>         rtnl_lock();
>>         /* Hold a refcnt for all chains, except 0, in case they are gone. */
>>         list_for_each_entry(chain, &block->chain_list, list)
>>                 if (chain->index)
>>                         tcf_chain_hold(chain);
>>
>>         /* No race on the list, because no chain could be destroyed. */
>>         list_for_each_entry(chain, &block->chain_list, list)
>>                 tcf_chain_flush(chain);
>>
>>         INIT_WORK(&block->work, tcf_block_put_final);
>>         /* Wait for RCU callbacks to release the reference count and make
>>          * sure their works have been queued before this.
>>          */
>>         rcu_barrier();
>
> This one can take awhile...  Though in recent kernels it will often
> be a bit faster than synchronize_rcu().
>

It is already in current code base, so it is not introduced here.


> Note that rcu_barrier() only waits for callbacks posted via call_rcu()
> before the rcu_barrier() starts, if that matters.
>

Yes, this is exactly what I expect.


>>         tcf_queue_work(&block->work);
>>         rtnl_unlock();
>> }
>
> And it looks like tcf_block_put_deferred() queues itself as work as well.
> Or maybe instead?

Yes, it queues itself after all the works queued via call_rcu(),
to ensure it is the last.


>
>> void tcf_block_put(struct tcf_block *block)
>> {
>>         if (!block)
>>                 return;
>>
>>         INIT_WORK(&block->work, tcf_block_put_deferred);
>>         /* Wait for existing RCU callbacks to cool down, make sure their works
>>          * have been queued before this. We can not flush pending works here
>>          * because we are holding the RTNL lock.
>>          */
>>         rcu_barrier();
>>         tcf_queue_work(&block->work);
>> }
>>
>>
>> Paul, does this make any sense to you? ;)
>
>  would be surprised if I fully understand the problem to be solved,
> but my current guess is that the constraints are as follows:
>
> 1.      Things removed must be processed in order.
>

Sort of, RCU callbacks themselves don't have any order, they only
need to be serialized with RTNL lock, so we have to defer it to a
workqeueue.

What needs a strict order is tcf_block_put() vs. flying works. Before
tcf_block_put() finishes, all the flying works must be done otherwise
use-after-free. :-/



> 2.      Things removes must not be processed until a grace period
>         has elapsed.
>

For these RCU callbacks yes, but for tcf_block_put() no, it uses
refcnt not RCU.


> 3.      Things being processed after a grace period should not be
>         processed concurrently with each other or with subsequent
>         removals.


Yeah, this is the cause of the problem. They have to be serialized
with each other and with other tc action paths (holding RTNL) too.


>
> 4.      A given removal is not finalized until its reference count
>         reaches zero.

There are two kinds of removal here:

1) Filter removal. This is not reference counted, it needs RCU grace
period.

2) Filter chain removal. This is refcount'ed and filters hold its refcnt,
the actions attached to filters could hold its refcnt too

So when we remove a filter chain, it flushes all the filters and actions
attached, so RCU callbacks will be flying, tcf_block_put() needs to wait
for refcnt hits zero, especially by those actions, before freeing it.


>
> 5.      RTNL might not be held when the reference count reaches zero.
>

Without my patch, no, RTNL is not held in RCU callbacks where actions
are destroyed and releasing refcnt.

With my patch, RTNL will be always held, RCU callbacks will be merely
schedule_work(), RTNL is held is each work.


> Or did I lose the thread somewhere?
>

I don't think you miss anything.

Thanks!
