From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] team: add rescheduling jiffy delay on !rtnl_trylock
Date: Sat, 4 Oct 2014 01:37:32 -0700
Message-ID: <20141004083732.GG5015@linux.vnet.ibm.com>
References: <20140929115445.40221d8e@jlaw-desktop.mno.stratus.com>
 <20140929160601.GD15925@htj.dyndns.org>
 <20141002064308.GN5015@linux.vnet.ibm.com>
 <20141003153701.7c7da030@jlaw-desktop.mno.stratus.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org,
	Jiri Pirko <jiri@resnulli.us>
To: Joe Lawrence <joe.lawrence@stratus.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:51355 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751312AbaJDIwP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Oct 2014 04:52:15 -0400
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Sat, 4 Oct 2014 02:52:14 -0600
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 03D331FF0040
	for <netdev@vger.kernel.org>; Sat,  4 Oct 2014 02:40:57 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08027.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s948qB9u54394936
	for <netdev@vger.kernel.org>; Sat, 4 Oct 2014 10:52:11 +0200
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s948ulDZ025203
	for <netdev@vger.kernel.org>; Sat, 4 Oct 2014 02:56:47 -0600
Content-Disposition: inline
In-Reply-To: <20141003153701.7c7da030@jlaw-desktop.mno.stratus.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 03, 2014 at 03:37:01PM -0400, Joe Lawrence wrote:
> On Wed, 1 Oct 2014 23:43:08 -0700
> "Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:
> 
> > On Mon, Sep 29, 2014 at 12:06:01PM -0400, Tejun Heo wrote:
> > > (cc'ing Paul and quoting the whole body)
> > > 
> > > Paul, this is a fix for RCU sched stall observed w/ a work item
> > > requeueing itself waiting for the RCU grace period.  As the self
> > > requeueing work item ends up being executed by the same kworker, the
> > > worker task never stops running in the absence of a higher priority
> > > task and it seems to delay RCU grace period for a very long time on
> > > !PREEMPT kernels.  As each work item denotes a boundary which no
> > > synchronization construct stretches across, I wonder whether it'd be a
> > > good idea to add a notification for the end of RCU critical section
> > > between executions of work items.
> > 
> > It sounds like a great idea to me!  I suggest invoking
> > rcu_note_context_switch() between executions of work items.
> > 
> > 							Thanx, Paul
> 
> I gave this a spin, probably inserting the call in the wrong place:
> 
> diff --git a/kernel/workqueue.c b/kernel/workqueue.c
> index 5dbe22a..77f128e 100644
> --- a/kernel/workqueue.c
> +++ b/kernel/workqueue.c
> @@ -2045,7 +2045,8 @@ __acquires(&pool->lock)
>          * indefinitely requeue itself while all other CPUs are trapped in
>          * stop_machine.
>          */
> -       cond_resched();
> +       if (!cond_resched())
> +               rcu_note_context_switch(raw_smp_processor_id());
> 
>         spin_lock_irq(&pool->lock);

If the cond_resched() is in the right place, then you should be good.

FWIW, there is a cond_resched_rcu_qs() that should be going into the next
merge window that could be used in place of the above two lines.  This is
commit bde6c3aa9930 in -tip.

> this results in RCU grace periods progressing (dyntick remains
> fixed) as advertised, even with the test-module from [1] loaded:
> 
> Fri Oct  3 14:37:14 2014
>   4 c=9635 g=9636 pq=1 qp=0 dt=51693/140000000000000/0 df=163 of=0 ql=0/1 qs=...D b=10 ci=0 nci=34184 co=0 ca=0
> 
> Fri Oct  3 14:50:24 2014
>   4 c=13072 g=13073 pq=1 qp=0 dt=51693/140000000000000/0 df=163 of=0 ql=0/1 qs=...D b=10 ci=0 nci=34191 co=0 ca=0

Nice!

							Thanx, Paul

> I'll leave it up to Tejun to determine where/how that call should be
> made.
> 
> Thanks!
> 
> -- Joe
> 
> [1] http://marc.info/?l=linux-kernel&m=141192244232345
> 
