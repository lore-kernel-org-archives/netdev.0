From: Oleg Nesterov <oleg@tv-sign.ru>
Subject: Re: 2.6.25rc7 lockdep trace
Date: Wed, 2 Apr 2008 12:51:26 +0400
Message-ID: <20080402085126.GA96@tv-sign.ru>
References: <20080328.173414.22278840.davem@davemloft.net> <1206752049.22530.105.camel@johannes.berg> <1206752485.22530.108.camel@johannes.berg> <20080328.180924.154907485.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes@sipsolutions.net, davej@codemonkey.org.uk,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from x346.tv-sign.ru ([89.108.83.215]:50910 "EHLO mail.screens.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751890AbYDBJvw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Apr 2008 05:51:52 -0400
Content-Disposition: inline
In-Reply-To: <20080328.180924.154907485.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/28, David Miller wrote:
>
> From: Johannes Berg <johannes@sipsolutions.net>
> Date: Sat, 29 Mar 2008 02:01:25 +0100
> 
> > 
> > > > You can't flush a workqueue in the device close handler
> > > > exactly because of this locking conflict.
> > > > 
> > > > Nobody has come up with a suitable way to fix this yet.
> > > 
> > > Maybe we should check which schedule_work users actually lock the rtnl
> > > within the work function and move them to a uses-rtnl-in-work workqueue
> > > so that everybody else can have rtnl around flush.
> > 
> > On the other hand, most drivers don't actually care that their work has
> > run, they just care that it won't run in the future after they give up
> > resources or similar, hence they can and should use cancel_work_sync()
> > which doesn't suffer from the deadlock. But that needs actual inspection
> > because it does change behaviour from "run and wait for it if scheduled"
> > to "cancel if scheduled".
> 
> I don't see how you can not race with the transition from
> scheduled to "executing" without taking the runqueue lock
> for the testing.

Yes, cancel_work_sync() takes cwq->lock but this is fine (unless it is buggy ;)
Please note that run_workqueue() drops this lock before calling work->func().

If the caller of cancel_work_sync(work) doesn't share locks with work->func()
we can't deadlock, even if there are other pending/running work_structs which
need the same locks as the caller (say, RTNL).

But, perhaps, you mean wq->lockdep_map? As Johannes pointed out this lock is
fake, but I think this doesn't matter, from the correctness POV it is "real"
lock. What does matter is that cancel_work_sync() doesn't use this lock at all.

(again, Johannes has already explained this all).

> And it is crucial that the workqueue function doesn't
> execute "accidently" due to such a race before the module
> and thus the workqueue code is about to get potentially
> unloaded.

Which race? Unless explicitly queued afterwards, work->func() can't execute
after return from cancel_work_sync(work).


David, I think you misunderstood Johannes, or perhaps I missed something.

Oleg.

