From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] team: add rescheduling jiffy delay on !rtnl_trylock
Date: Wed, 1 Oct 2014 23:43:08 -0700
Message-ID: <20141002064308.GN5015@linux.vnet.ibm.com>
References: <20140929115445.40221d8e@jlaw-desktop.mno.stratus.com>
 <20140929160601.GD15925@htj.dyndns.org>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Lawrence <joe.lawrence@stratus.com>, netdev@vger.kernel.org,
	Jiri Pirko <jiri@resnulli.us>
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:58919 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750934AbaJBGnO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 02:43:14 -0400
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 2 Oct 2014 00:43:14 -0600
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 53BEC3E4003E
	for <netdev@vger.kernel.org>; Thu,  2 Oct 2014 00:43:11 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s926hBc242467502
	for <netdev@vger.kernel.org>; Thu, 2 Oct 2014 08:43:11 +0200
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s926lkVb008681
	for <netdev@vger.kernel.org>; Thu, 2 Oct 2014 00:47:46 -0600
Content-Disposition: inline
In-Reply-To: <20140929160601.GD15925@htj.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 29, 2014 at 12:06:01PM -0400, Tejun Heo wrote:
> (cc'ing Paul and quoting the whole body)
> 
> Paul, this is a fix for RCU sched stall observed w/ a work item
> requeueing itself waiting for the RCU grace period.  As the self
> requeueing work item ends up being executed by the same kworker, the
> worker task never stops running in the absence of a higher priority
> task and it seems to delay RCU grace period for a very long time on
> !PREEMPT kernels.  As each work item denotes a boundary which no
> synchronization construct stretches across, I wonder whether it'd be a
> good idea to add a notification for the end of RCU critical section
> between executions of work items.

It sounds like a great idea to me!  I suggest invoking
rcu_note_context_switch() between executions of work items.

							Thanx, Paul

> Thanks.
> 
> On Mon, Sep 29, 2014 at 11:54:45AM -0400, Joe Lawrence wrote:
> > Hello Jiri,
> > 
> > I've been debugging a hang on RHEL7 that seems to originate in the
> > teaming driver and the team_notify_peers_work/team_mcast_rejoin_work
> > rtnl_trylock rescheduling logic.  Running a stand-alone minimal driver
> > mimicing the same schedule_delayed_work(.., 0) reproduces the problem on
> > RHEL7 and upstream kernels [1].
> > 
> > A quick summary of the hang:
> > 
> > 1 - systemd-udevd issues an ioctl that heads down dev_ioctl (grabs the
> >     rtnl_mutex), dev_ifsioc, dev_change_name and finally
> >     synchronize_sched.  In every vmcore I've taken of the hang, this
> >     thread is waiting on the RCU.
> > 
> > 2 - A kworker thread goes to 100% CPU.
> > 
> > 3 - Inspecting the running thread on the CPU that rcusched reported as
> >     holding up the RCU grace period usually shows it in either
> >     team_notify_peers_work, team_mcast_rejoin_work, or somewhere in the
> >     workqueue code (process_one_work).  This is the same CPU/thread as
> >     #2.
> > 
> > 4 - team_notify_peers_work and team_mcast_rejoin_work want the rtnl_lock
> >     that systemd-udevd in #1 has, so they try to play nice by calling
> >     rtnl_trylock and rescheduling on failure.  Unfortunately with 0
> >     jiffy delay, process_one_work will "execute immediately" (ie, after
> >     others already in queue, but before the next tick).  With the stock
> >     RHEL7 !CONFIG_PREEMPT at least, this creates a tight loop on
> >     process_one_work + rtnl_trylock that spins the CPU in #2.
> > 
> > 5 - Sometime minutes later, RCU seems to be kicked by a side effect of
> >     a smp_apic_timer_interrupt.  (This was the only other interesting
> >     function reported by ftrace function tracer).
> > 
> > See the patch below for a potential workaround.  Giving at least 1 jiffy
> > should give process_one_work some breathing room before calling back
> > into team_notify_peers_work/team_mcast_rejoin_work and attempting to
> > acquire the rtnl_lock mutex.
> > 
> > Regards,
> > 
> > -- Joe
> > 
> > [1] http://marc.info/?l=linux-kernel&m=141192244232345&w=2
> > 
> > -->8--- -->8--- -->8--- -->8---
> > 
> > From fc5bbf5771b5732f7479ac6e84bbfdde05710023 Mon Sep 17 00:00:00 2001
> > From: Joe Lawrence <joe.lawrence@stratus.com>
> > Date: Mon, 29 Sep 2014 11:09:05 -0400
> > Subject: [PATCH] team: add rescheduling jiffy delay on !rtnl_trylock
> > 
> > Give the CPU running the kworker handling team_notify_peers_work and
> > team_mcast_rejoin_work functions some scheduling air by specifying a
> > non-zero delay.
> > 
> > Signed-off-by: Joe Lawrence <joe.lawrence@stratus.com>
> > ---
> >  drivers/net/team/team.c |    4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
> > index ef10302..d46df38 100644
> > --- a/drivers/net/team/team.c
> > +++ b/drivers/net/team/team.c
> > @@ -633,7 +633,7 @@ static void team_notify_peers_work(struct work_struct *work)
> >  	team = container_of(work, struct team, notify_peers.dw.work);
> >  
> >  	if (!rtnl_trylock()) {
> > -		schedule_delayed_work(&team->notify_peers.dw, 0);
> > +		schedule_delayed_work(&team->notify_peers.dw, 1);
> >  		return;
> >  	}
> >  	call_netdevice_notifiers(NETDEV_NOTIFY_PEERS, team->dev);
> > @@ -673,7 +673,7 @@ static void team_mcast_rejoin_work(struct work_struct *work)
> >  	team = container_of(work, struct team, mcast_rejoin.dw.work);
> >  
> >  	if (!rtnl_trylock()) {
> > -		schedule_delayed_work(&team->mcast_rejoin.dw, 0);
> > +		schedule_delayed_work(&team->mcast_rejoin.dw, 1);
> >  		return;
> >  	}
> >  	call_netdevice_notifiers(NETDEV_RESEND_IGMP, team->dev);
> > -- 
> > 1.7.10.4
> > 
> 
> -- 
> tejun
> 
