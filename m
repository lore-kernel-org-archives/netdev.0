From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC] NETDEV_UNREGISTER_BATCH seems unused nowaday ?
Date: Fri, 10 Aug 2012 10:55:16 -0700
Message-ID: <20120810175516.GE2371@linux.vnet.ibm.com>
References: <1344590824.31104.1953.camel@edumazet-glaptop>
 <20120810.034211.994338127277150687.davem@davemloft.net>
 <1344596809.31104.2358.camel@edumazet-glaptop>
 <87vcgq955v.fsf@xmission.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:51664 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758318Ab2HJRzk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2012 13:55:40 -0400
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 10 Aug 2012 11:55:40 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id E303219D8047
	for <netdev@vger.kernel.org>; Fri, 10 Aug 2012 17:55:30 +0000 (WET)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7AHtIdL176628
	for <netdev@vger.kernel.org>; Fri, 10 Aug 2012 11:55:19 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7AHtHZB005479
	for <netdev@vger.kernel.org>; Fri, 10 Aug 2012 11:55:18 -0600
Content-Disposition: inline
In-Reply-To: <87vcgq955v.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 10, 2012 at 07:45:48AM -0700, Eric W. Biederman wrote:
> Eric Dumazet <eric.dumazet@gmail.com> writes:
> 
> > On Fri, 2012-08-10 at 03:42 -0700, David Miller wrote:
> >> From: Eric Dumazet <eric.dumazet@gmail.com>
> >> Date: Fri, 10 Aug 2012 11:27:04 +0200
> >> 
> >> > NETDEV_UNREGISTER_BATCH seems unused we can probably remove it.
> >> 
> >> Indeed, the routing cache was the final real user.
> >> 
> >> > I am tracking a device refcount issue, delaying net device dismantle by
> >> > 1 second in netdev_wait_allrefs()
> >> > 
> >> > I guess we need to add a notifier called _after_ the final
> >> > synchronize_net() in rollback_registered_many()
> >> 
> >> It's essentially caused by DST_GC_INC, right?
> >
> > No, we in fact need a rcu_barrier(), then another call to
> > dst_dev_event().
> >
> > rcu_barrier() is needed so that in-flight call_rcu() of routes (from
> > rt_free()) are completed. Or else we miss these dst in the
> > dst_dev_event().
> 
> > I have a working patch, adding the rcu_barrier() and one additional
> > NETDEV_UNREGISTER_FINAL event.
> 
> Can someone help bring me up to speed.  What has changed in the
> dst ref counting that has invalidated our previous solutions?
> 
> As for the idea of putting an rcu_barrier inside of the rtnl_lock.  I
> really don't like it. You are trading off a 1000ms singled threaded wait
> without locks for extending the hold times of rtnl lock by 12ms or so.
> 
> We already have an rcu_barrier on that path in netdev_run_todo,
> so we can reorganize things to use that barrier I would be much
> happer.  Furthermore I talked to Paul McKenney a while ago
> about creating an rcu_barrier expedited and he really did not
> like the idea.

For whatever it is worth, I do have rcu_barrier_expedited() on my list
of things that at least one person has expressed interest in, but that
I do not yet have a good solution for.  Obstacles include the following:

1.	If a given CPU has lots of callbacks, but is running a real-time
	process, what do you do?  (a) Hammer the real-time process?
	(b) Make rcu_barrier_expedited() wait (current likely choice)?
	(c) Handle via a set priority for callback processing (which
	might be the case for BOOST_RCU builds)?  (d) Force migration
	of the callbacks (mmmaybe...)?  (e) Force migration of the
	real-time process (ouch!)?

2.	Ditto, but huge numbers of callbacks and non-realtime processes.
	Similar solution space.

3.	There will be some real-time disruption from any reasonable
	implementation of rcu_barrier_expedited().  Maybe the RT
	guys choose to map it to rcu_barrier()?

On the other hand, in the same email thread back in May you were also
looking for a kmem_cache_free_rcu().  At the time I didn't have a
good solution for this, but I do believe that I have one now.  ;-)

							Thanx, Paul

> Reading through the code we really should get dst_rcu_free
> out of the header and make it non-line.  dst_rcu_free can't
> possibly be called from a location where it can be inlined.
> 
> Trying to understand your analysis I have stared at the code for
> a while and I am definitely not seeing any rcu callbacks that
> result in calling rt_free.  So one of us is missing something.
> 
> All I am seeing from your trace is one call of rtnetlink_dev_notifier
> the refcount is at 7 and the next call of rtnetlink_dev_notifier the
> refcnt has dropped to 1.
> 
> Eric
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
