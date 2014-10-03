From: Joe Lawrence <joe.lawrence@stratus.com>
Subject: Re: [PATCH] team: add rescheduling jiffy delay on !rtnl_trylock
Date: Fri, 3 Oct 2014 15:37:01 -0400
Message-ID: <20141003153701.7c7da030@jlaw-desktop.mno.stratus.com>
References: <20140929115445.40221d8e@jlaw-desktop.mno.stratus.com>
	<20140929160601.GD15925@htj.dyndns.org>
	<20141002064308.GN5015@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Tejun Heo <tj@kernel.org>, <netdev@vger.kernel.org>,
	Jiri Pirko <jiri@resnulli.us>
To: <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p02c11o148.mxlogic.net ([208.65.144.81]:44479 "EHLO
	p02c11o148.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753288AbaJCTil (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 15:38:41 -0400
In-Reply-To: <20141002064308.GN5015@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 1 Oct 2014 23:43:08 -0700
"Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:

> On Mon, Sep 29, 2014 at 12:06:01PM -0400, Tejun Heo wrote:
> > (cc'ing Paul and quoting the whole body)
> > 
> > Paul, this is a fix for RCU sched stall observed w/ a work item
> > requeueing itself waiting for the RCU grace period.  As the self
> > requeueing work item ends up being executed by the same kworker, the
> > worker task never stops running in the absence of a higher priority
> > task and it seems to delay RCU grace period for a very long time on
> > !PREEMPT kernels.  As each work item denotes a boundary which no
> > synchronization construct stretches across, I wonder whether it'd be a
> > good idea to add a notification for the end of RCU critical section
> > between executions of work items.
> 
> It sounds like a great idea to me!  I suggest invoking
> rcu_note_context_switch() between executions of work items.
> 
> 							Thanx, Paul

I gave this a spin, probably inserting the call in the wrong place:

diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index 5dbe22a..77f128e 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -2045,7 +2045,8 @@ __acquires(&pool->lock)
         * indefinitely requeue itself while all other CPUs are trapped in
         * stop_machine.
         */
-       cond_resched();
+       if (!cond_resched())
+               rcu_note_context_switch(raw_smp_processor_id());
 
        spin_lock_irq(&pool->lock);

this results in RCU grace periods progressing (dyntick remains
fixed) as advertised, even with the test-module from [1] loaded:

Fri Oct  3 14:37:14 2014
  4 c=9635 g=9636 pq=1 qp=0 dt=51693/140000000000000/0 df=163 of=0 ql=0/1 qs=...D b=10 ci=0 nci=34184 co=0 ca=0

Fri Oct  3 14:50:24 2014
  4 c=13072 g=13073 pq=1 qp=0 dt=51693/140000000000000/0 df=163 of=0 ql=0/1 qs=...D b=10 ci=0 nci=34191 co=0 ca=0

I'll leave it up to Tejun to determine where/how that call should be
made.

Thanks!

-- Joe

[1] http://marc.info/?l=linux-kernel&m=141192244232345
