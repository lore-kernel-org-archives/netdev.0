From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [Patch net 00/15] net_sched: remove RCU callbacks from TC
Date: Wed, 25 Oct 2017 17:19:16 -0700
Message-ID: <20171026001916.GU3659@linux.vnet.ibm.com>
References: <20171023220304.2268-1-xiyou.wangcong@gmail.com>
 <20171025.104353.1317026584880877750.davem@davemloft.net>
 <CAM_iQpVLHLx9eVgO0S--iq-XkhZE82Y30Z0REwU6qx8OGgm+mA@mail.gmail.com>
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
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:52940 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751893AbdJZAT1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 20:19:27 -0400
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9Q0JLRN051135
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 20:19:27 -0400
Received: from e16.ny.us.ibm.com (e16.ny.us.ibm.com [129.33.205.206])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2du0k4afr9-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 20:19:25 -0400
Received: from localhost
        by e16.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
        Wed, 25 Oct 2017 20:19:20 -0400
Content-Disposition: inline
In-Reply-To: <CAM_iQpVLHLx9eVgO0S--iq-XkhZE82Y30Z0REwU6qx8OGgm+mA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 25, 2017 at 03:37:40PM -0700, Cong Wang wrote:
> On Tue, Oct 24, 2017 at 6:43 PM, David Miller <davem@davemloft.net> wrote:
> > From: Cong Wang <xiyou.wangcong@gmail.com>
> > Date: Mon, 23 Oct 2017 15:02:49 -0700
> >
> >> Recently, the RCU callbacks used in TC filters and TC actions keep
> >> drawing my attention, they introduce at least 4 race condition bugs:
> >
> > Like Eric, I think doing a full RCU sync on every delete is too big
> > a pill to swallow.  This is a major control plane performance
> > regression.
> >
> > Please find another reasonable way to fix this.
> >
> 
> Alright... I finally find a way to make everyone happy.
> 
> My solution is introducing a workqueue for tc filters
> and let each RCU callback defer the work to this
> workqueue. I solve the flush_workqueue() deadlock
> by queuing another work in the same workqueue
> at the end, so the execution order should be as same
> as it is now. The ugly part is now tcf_block_put() which
> looks like below:
> 
> 
> static void tcf_block_put_final(struct work_struct *work)
> {
>         struct tcf_block *block = container_of(work, struct tcf_block, work);
>         struct tcf_chain *chain, *tmp;
> 
>         /* At this point, all the chains should have refcnt == 1. */
>         rtnl_lock();
>         list_for_each_entry_safe(chain, tmp, &block->chain_list, list)
>                 tcf_chain_put(chain);
>         rtnl_unlock();
>         kfree(block);
> }

I am guessing that tcf_chain_put() sometimes does a call_rcu(),
and the callback function in turn calls schedule_work(), and that
tcf_block_put_deferred() is the workqueue handler function.

> static void tcf_block_put_deferred(struct work_struct *work)
> {
>         struct tcf_block *block = container_of(work, struct tcf_block, work);
>         struct tcf_chain *chain;
> 
>         rtnl_lock();
>         /* Hold a refcnt for all chains, except 0, in case they are gone. */
>         list_for_each_entry(chain, &block->chain_list, list)
>                 if (chain->index)
>                         tcf_chain_hold(chain);
> 
>         /* No race on the list, because no chain could be destroyed. */
>         list_for_each_entry(chain, &block->chain_list, list)
>                 tcf_chain_flush(chain);
> 
>         INIT_WORK(&block->work, tcf_block_put_final);
>         /* Wait for RCU callbacks to release the reference count and make
>          * sure their works have been queued before this.
>          */
>         rcu_barrier();

This one can take awhile...  Though in recent kernels it will often
be a bit faster than synchronize_rcu().

Note that rcu_barrier() only waits for callbacks posted via call_rcu()
before the rcu_barrier() starts, if that matters.

>         tcf_queue_work(&block->work);
>         rtnl_unlock();
> }

And it looks like tcf_block_put_deferred() queues itself as work as well.
Or maybe instead?

> void tcf_block_put(struct tcf_block *block)
> {
>         if (!block)
>                 return;
> 
>         INIT_WORK(&block->work, tcf_block_put_deferred);
>         /* Wait for existing RCU callbacks to cool down, make sure their works
>          * have been queued before this. We can not flush pending works here
>          * because we are holding the RTNL lock.
>          */
>         rcu_barrier();
>         tcf_queue_work(&block->work);
> }
> 
> 
> Paul, does this make any sense to you? ;)

 would be surprised if I fully understand the problem to be solved,
but my current guess is that the constraints are as follows:

1.	Things removed must be processed in order.

2.	Things removes must not be processed until a grace period
	has elapsed.

3.	Things being processed after a grace period should not be
	processed concurrently with each other or with subsequent
	removals.

4.	A given removal is not finalized until its reference count
	reaches zero.

5.	RTNL might not be held when the reference count reaches zero.

Or did I lose the thread somewhere?

							Thanx, Paul
