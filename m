From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Get rid of RCU callbacks in TC filters?
Date: Wed, 18 Oct 2017 12:35:48 -0700
Message-ID: <20171018193548.GM3521@linux.vnet.ibm.com>
References: <CAM_iQpU1hF9v1+bek9CQkdbjS_2nctwpaSXyiNLiBHPC6WEYKQ@mail.gmail.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Chris Mi <chrism@mellanox.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Jiri Pirko <jiri@resnulli.us>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:44764 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750730AbdJRTfy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 15:35:54 -0400
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9IJXpQU142918
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 15:35:54 -0400
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2dp9p4vb77-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 15:35:53 -0400
Received: from localhost
        by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
        Wed, 18 Oct 2017 15:35:52 -0400
Content-Disposition: inline
In-Reply-To: <CAM_iQpU1hF9v1+bek9CQkdbjS_2nctwpaSXyiNLiBHPC6WEYKQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 18, 2017 at 10:36:28AM -0700, Cong Wang wrote:
> Hi, all
> 
> Recently, the RCU callbacks used in TC filters and TC actions keep
> drawing my attention, they introduce at least 4 race condition bugs:
> 
> 1. A simple one fixed by Daniel:
> 
> commit c78e1746d3ad7d548bdf3fe491898cc453911a49
> Author: Daniel Borkmann <daniel@iogearbox.net>
> Date:   Wed May 20 17:13:33 2015 +0200
> 
>     net: sched: fix call_rcu() race on classifier module unloads
> 
> 2. A very nasty one fixed by me:
> 
> commit 1697c4bb5245649a23f06a144cc38c06715e1b65
> Author: Cong Wang <xiyou.wangcong@gmail.com>
> Date:   Mon Sep 11 16:33:32 2017 -0700
> 
>     net_sched: carefully handle tcf_block_put()
> 
> 3. Two more bugs found by Chris:
> https://patchwork.ozlabs.org/patch/826696/
> https://patchwork.ozlabs.org/patch/826695/
> 
> 
> Usually RCU callbacks are simple, however for TC filters and actions,
> they are complex because at least TC actions could be destroyed
> together with the TC filter in one callback. And RCU callbacks are
> invoked in BH context, without locking they are parallel too. All of
> these contribute to the cause of these nasty bugs. It looks like they
> bring us more problems than benefits.
> 
> Therefore, I have been thinking about getting rid of these callbacks,
> because they are not strictly necessary, callers of these call_rcu()
> are all on slow path and have RTNL lock, so blocking is permitted in
> their contexts, and _I think_ it does not harm to use
> synchronize_rcu() on slow paths, at least I can argue RTNL lock is
> already there and is a bottleneck if we really care. :)
> 
> There are 3 solutions here:
> 
> 1) Get rid of these RCU callbacks and use synchronize_rcu(). The
> downside is this could hurt the performance of deleting TC filters,
> but again it is slow path comparing to skb classification path. Note,
> it is _not_ merely replacing call_rcu() with synchronize_rcu(),
> because many call_rcu()'s are actually in list iterations, we have to
> use a local list and call list_del_rcu()+list_add() before
> synchronize_rcu() (Or is there any other API I am not aware of?). If
> people really hate synchronize_rcu() because of performance, we could
> also defer the work to a workqueue and callers could keep their
> performance as they are.
> 
> 2) Introduce a spinlock to serialize these RCU callbacks. But as I
> said in commit 1697c4bb5245 ("net_sched: carefully handle
> tcf_block_put()"), it is very hard to do because of tcf_chain_dump().
> Potentially we need to do a lot of work to make it possible, if not
> impossible.
> 
> 3) Keep these RCU callbacks and fix all race conditions. Like what
> Chris tries to do in his patchset, but my argument is that we can not
> prove we are really race-free even with Chris' patches and his patches
> are already large enough.
> 
> 
> What do you think? Any other ideas?

4) Move from call_rcu() to synchronize_rcu(), but if feasible use one
synchronize_rcu() for multiple deletions/iterations.

5) Keep call_rcu(), but have the RCU callback schedule a workqueue.
The workqueue could then use blocking primitives, for example, acquiring
RTNL.

6) As with #5, have the RCU callback schedule a workqueue, but aggregate
workqueue scheduling using a timer.  This would reduce the number of
RTNL acquisitions.

7) As with #5, have the RCU callback schedule a workqueue, but have each
iterator accumulate a list of things removed and do call_rcu() on the
list.  This is an alternative way of aggregating to reduce the number
of RTNL acquisitions.

There are many other ways to skin this cat.

							Thanx, Paul
