From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net 00/15] net_sched: remove RCU callbacks from TC
Date: Wed, 25 Oct 2017 15:37:40 -0700
Message-ID: <CAM_iQpVLHLx9eVgO0S--iq-XkhZE82Y30Z0REwU6qx8OGgm+mA@mail.gmail.com>
References: <20171023220304.2268-1-xiyou.wangcong@gmail.com> <20171025.104353.1317026584880877750.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Chris Mi <chrism@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:49631 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751753AbdJYWiB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 18:38:01 -0400
Received: by mail-pg0-f67.google.com with SMTP id g6so1101072pgn.6
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 15:38:01 -0700 (PDT)
In-Reply-To: <20171025.104353.1317026584880877750.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 24, 2017 at 6:43 PM, David Miller <davem@davemloft.net> wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> Date: Mon, 23 Oct 2017 15:02:49 -0700
>
>> Recently, the RCU callbacks used in TC filters and TC actions keep
>> drawing my attention, they introduce at least 4 race condition bugs:
>
> Like Eric, I think doing a full RCU sync on every delete is too big
> a pill to swallow.  This is a major control plane performance
> regression.
>
> Please find another reasonable way to fix this.
>

Alright... I finally find a way to make everyone happy.

My solution is introducing a workqueue for tc filters
and let each RCU callback defer the work to this
workqueue. I solve the flush_workqueue() deadlock
by queuing another work in the same workqueue
at the end, so the execution order should be as same
as it is now. The ugly part is now tcf_block_put() which
looks like below:


static void tcf_block_put_final(struct work_struct *work)
{
        struct tcf_block *block = container_of(work, struct tcf_block, work);
        struct tcf_chain *chain, *tmp;

        /* At this point, all the chains should have refcnt == 1. */
        rtnl_lock();
        list_for_each_entry_safe(chain, tmp, &block->chain_list, list)
                tcf_chain_put(chain);
        rtnl_unlock();
        kfree(block);
}

static void tcf_block_put_deferred(struct work_struct *work)
{
        struct tcf_block *block = container_of(work, struct tcf_block, work);
        struct tcf_chain *chain;

        rtnl_lock();
        /* Hold a refcnt for all chains, except 0, in case they are gone. */
        list_for_each_entry(chain, &block->chain_list, list)
                if (chain->index)
                        tcf_chain_hold(chain);

        /* No race on the list, because no chain could be destroyed. */
        list_for_each_entry(chain, &block->chain_list, list)
                tcf_chain_flush(chain);

        INIT_WORK(&block->work, tcf_block_put_final);
        /* Wait for RCU callbacks to release the reference count and make
         * sure their works have been queued before this.
         */
        rcu_barrier();
        tcf_queue_work(&block->work);
        rtnl_unlock();
}

void tcf_block_put(struct tcf_block *block)
{
        if (!block)
                return;

        INIT_WORK(&block->work, tcf_block_put_deferred);
        /* Wait for existing RCU callbacks to cool down, make sure their works
         * have been queued before this. We can not flush pending works here
         * because we are holding the RTNL lock.
         */
        rcu_barrier();
        tcf_queue_work(&block->work);
}


Paul, does this make any sense to you? ;)
