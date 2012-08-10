From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC] NETDEV_UNREGISTER_BATCH seems unused nowaday ?
Date: Fri, 10 Aug 2012 07:45:48 -0700
Message-ID: <87vcgq955v.fsf@xmission.com>
References: <1344590824.31104.1953.camel@edumazet-glaptop>
	<20120810.034211.994338127277150687.davem@davemloft.net>
	<1344596809.31104.2358.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:41550 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756850Ab2HJOp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2012 10:45:56 -0400
In-Reply-To: <1344596809.31104.2358.camel@edumazet-glaptop> (Eric Dumazet's
	message of "Fri, 10 Aug 2012 13:06:49 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> On Fri, 2012-08-10 at 03:42 -0700, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Fri, 10 Aug 2012 11:27:04 +0200
>> 
>> > NETDEV_UNREGISTER_BATCH seems unused we can probably remove it.
>> 
>> Indeed, the routing cache was the final real user.
>> 
>> > I am tracking a device refcount issue, delaying net device dismantle by
>> > 1 second in netdev_wait_allrefs()
>> > 
>> > I guess we need to add a notifier called _after_ the final
>> > synchronize_net() in rollback_registered_many()
>> 
>> It's essentially caused by DST_GC_INC, right?
>
> No, we in fact need a rcu_barrier(), then another call to
> dst_dev_event().
>
> rcu_barrier() is needed so that in-flight call_rcu() of routes (from
> rt_free()) are completed. Or else we miss these dst in the
> dst_dev_event().

> I have a working patch, adding the rcu_barrier() and one additional
> NETDEV_UNREGISTER_FINAL event.

Can someone help bring me up to speed.  What has changed in the
dst ref counting that has invalidated our previous solutions?

As for the idea of putting an rcu_barrier inside of the rtnl_lock.  I
really don't like it. You are trading off a 1000ms singled threaded wait
without locks for extending the hold times of rtnl lock by 12ms or so.

We already have an rcu_barrier on that path in netdev_run_todo,
so we can reorganize things to use that barrier I would be much
happer.  Furthermore I talked to Paul McKenney a while ago
about creating an rcu_barrier expedited and he really did not
like the idea.

Reading through the code we really should get dst_rcu_free
out of the header and make it non-line.  dst_rcu_free can't
possibly be called from a location where it can be inlined.

Trying to understand your analysis I have stared at the code for
a while and I am definitely not seeing any rcu callbacks that
result in calling rt_free.  So one of us is missing something.

All I am seeing from your trace is one call of rtnetlink_dev_notifier
the refcount is at 7 and the next call of rtnetlink_dev_notifier the
refcnt has dropped to 1.

Eric
