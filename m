From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [Patch net 00/15] net_sched: remove RCU callbacks from TC
Date: Thu, 26 Oct 2017 06:58:12 -0700
Message-ID: <20171026135812.GY3659@linux.vnet.ibm.com>
References: <20171023220304.2268-1-xiyou.wangcong@gmail.com>
 <20171025.104353.1317026584880877750.davem@davemloft.net>
 <CAM_iQpVLHLx9eVgO0S--iq-XkhZE82Y30Z0REwU6qx8OGgm+mA@mail.gmail.com>
 <20171026001916.GU3659@linux.vnet.ibm.com>
 <CAM_iQpXQAeXeVtUNBTsF6VxR6OiGFbQgXiRFzrRrTQ72_6fxCA@mail.gmail.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Chris Mi <chrism@mellanox.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:58864 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932231AbdJZN6T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 09:58:19 -0400
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9QDuMfo016625
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 09:58:18 -0400
Received: from e13.ny.us.ibm.com (e13.ny.us.ibm.com [129.33.205.203])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2dufeu5kd3-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 09:58:18 -0400
Received: from localhost
        by e13.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
        Thu, 26 Oct 2017 09:58:16 -0400
Content-Disposition: inline
In-Reply-To: <CAM_iQpXQAeXeVtUNBTsF6VxR6OiGFbQgXiRFzrRrTQ72_6fxCA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 25, 2017 at 09:49:09PM -0700, Cong Wang wrote:
> On Wed, Oct 25, 2017 at 5:19 PM, Paul E. McKenney
> <paulmck@linux.vnet.ibm.com> wrote:
> > On Wed, Oct 25, 2017 at 03:37:40PM -0700, Cong Wang wrote:
> >> My solution is introducing a workqueue for tc filters
> >> and let each RCU callback defer the work to this
> >> workqueue. I solve the flush_workqueue() deadlock
> >> by queuing another work in the same workqueue
> >> at the end, so the execution order should be as same
> >> as it is now. The ugly part is now tcf_block_put() which
> >> looks like below:
> >>
> >>
> >> static void tcf_block_put_final(struct work_struct *work)
> >> {
> >>         struct tcf_block *block = container_of(work, struct tcf_block, work);
> >>         struct tcf_chain *chain, *tmp;
> >>
> >>         /* At this point, all the chains should have refcnt == 1. */
> >>         rtnl_lock();
> >>         list_for_each_entry_safe(chain, tmp, &block->chain_list, list)
> >>                 tcf_chain_put(chain);
> >>         rtnl_unlock();
> >>         kfree(block);
> >> }
> >
> > I am guessing that tcf_chain_put() sometimes does a call_rcu(),
> > and the callback function in turn calls schedule_work(), and that
> > tcf_block_put_deferred() is the workqueue handler function.
> 
> Yes, tcf_chain_put() triggers call_rcu() indirectly during flush,
> this is why we have rcu_barrier()'s in current code base.

OK, got it.

> >> static void tcf_block_put_deferred(struct work_struct *work)
> >> {
> >>         struct tcf_block *block = container_of(work, struct tcf_block, work);
> >>         struct tcf_chain *chain;
> >>
> >>         rtnl_lock();
> >>         /* Hold a refcnt for all chains, except 0, in case they are gone. */
> >>         list_for_each_entry(chain, &block->chain_list, list)
> >>                 if (chain->index)
> >>                         tcf_chain_hold(chain);
> >>
> >>         /* No race on the list, because no chain could be destroyed. */
> >>         list_for_each_entry(chain, &block->chain_list, list)
> >>                 tcf_chain_flush(chain);
> >>
> >>         INIT_WORK(&block->work, tcf_block_put_final);
> >>         /* Wait for RCU callbacks to release the reference count and make
> >>          * sure their works have been queued before this.
> >>          */
> >>         rcu_barrier();
> >
> > This one can take awhile...  Though in recent kernels it will often
> > be a bit faster than synchronize_rcu().
> 
> It is already in current code base, so it is not introduced here.

Very good, then no problems with added overhead from rcu_barrier().  ;-)

> > Note that rcu_barrier() only waits for callbacks posted via call_rcu()
> > before the rcu_barrier() starts, if that matters.
> 
> Yes, this is exactly what I expect.

Good.

> >>         tcf_queue_work(&block->work);
> >>         rtnl_unlock();
> >> }
> >
> > And it looks like tcf_block_put_deferred() queues itself as work as well.
> > Or maybe instead?
> 
> Yes, it queues itself after all the works queued via call_rcu(),
> to ensure it is the last.

OK.

> >> void tcf_block_put(struct tcf_block *block)
> >> {
> >>         if (!block)
> >>                 return;
> >>
> >>         INIT_WORK(&block->work, tcf_block_put_deferred);
> >>         /* Wait for existing RCU callbacks to cool down, make sure their works
> >>          * have been queued before this. We can not flush pending works here
> >>          * because we are holding the RTNL lock.
> >>          */
> >>         rcu_barrier();
> >>         tcf_queue_work(&block->work);
> >> }
> >>
> >>
> >> Paul, does this make any sense to you? ;)
> >
> >  would be surprised if I fully understand the problem to be solved,
> > but my current guess is that the constraints are as follows:
> >
> > 1.      Things removed must be processed in order.
> 
> Sort of, RCU callbacks themselves don't have any order, they only
> need to be serialized with RTNL lock, so we have to defer it to a
> workqeueue.

OK, got it.

> What needs a strict order is tcf_block_put() vs. flying works. Before
> tcf_block_put() finishes, all the flying works must be done otherwise
> use-after-free. :-/

So when removing an entire chain, you flush any queued workqueue handlers
to make sure that any operations using elements on that chain have also
completed, correct?  This might also motivate the rcu_barrier() calls.

> > 2.      Things removes must not be processed until a grace period
> >         has elapsed.
> 
> For these RCU callbacks yes, but for tcf_block_put() no, it uses
> refcnt not RCU.

OK, got it, give or take.

> > 3.      Things being processed after a grace period should not be
> >         processed concurrently with each other or with subsequent
> >         removals.
> 
> Yeah, this is the cause of the problem. They have to be serialized
> with each other and with other tc action paths (holding RTNL) too.

OK, makes sense.

> > 4.      A given removal is not finalized until its reference count
> >         reaches zero.
> 
> There are two kinds of removal here:
> 
> 1) Filter removal. This is not reference counted, it needs RCU grace
> period.
> 
> 2) Filter chain removal. This is refcount'ed and filters hold its refcnt,
> the actions attached to filters could hold its refcnt too
> 
> So when we remove a filter chain, it flushes all the filters and actions
> attached, so RCU callbacks will be flying, tcf_block_put() needs to wait
> for refcnt hits zero, especially by those actions, before freeing it.

Very good, and I wasn't aware of the distinction between individual
filters and full filter chains before, thank you!

> > 5.      RTNL might not be held when the reference count reaches zero.
> 
> Without my patch, no, RTNL is not held in RCU callbacks where actions
> are destroyed and releasing refcnt.
> 
> With my patch, RTNL will be always held, RCU callbacks will be merely
> schedule_work(), RTNL is held is each work.

OK, got it.

> > Or did I lose the thread somewhere?
> 
> I don't think you miss anything.

Seems to me that your proposed patch is at least worth a try, then.

							Thanx, Paul
