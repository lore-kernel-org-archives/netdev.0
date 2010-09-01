From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: [RFC] bonding: fix workqueue re-arming races
Date: Wed, 1 Sep 2010 20:31:14 +0200
Message-ID: <20100901183113.GA25227@midget.suse.cz>
References: <20100831170752.GA9743@midget.suse.cz>
 <20136.1283288063@death>
 <20100901131626.GA12447@midget.suse.cz>
 <24764.1283361274@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Bohac <jbohac@suse.cz>, bonding-devel@lists.sourceforge.net,
	markine@google.com, jarkao2@gmail.com, chavey@google.com,
	netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:47510 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753622Ab0IAS3l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Sep 2010 14:29:41 -0400
Content-Disposition: inline
In-Reply-To: <24764.1283361274@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 01, 2010 at 10:14:34AM -0700, Jay Vosburgh wrote:
> 	I also thought a bit more, and in the current code, the mode
> shouldn't change in the middle of one of the work functions, because a
> mode change requires the bond to be closed, so the various work things
> will be stopped (more or less; excepting the race under disucssion
> here).
>
> 	I don't think this is true for the new wq_rtnl functions,
> however, because its work items are not canceled until the workqueue
> itself is freed in bond_destructor.  Does the wq_rtnl open new races,
> because it's work items are not synchronized with other activities
> (close in particular)?  It's possible for its work functions (which may
> do things like set the active slave, carrier, etc) to be invoked after
> the bond has closed, and possibly reopened, or been otherwise adjusted.

I don't think this patch opens new races. The current race
scenario is:

1) schedule_delayed_work(foo)
2) foo's timer expires and foo is queued on bond->wq
  (possibly, foo starts to run and either gets preempted or
  sleeps on rtnl)
3) bond_close() sets kill_timers=1 and calls
  cancel_delayed_work() which accomplishes nothing
4) bond_open() sets kill_timers=0
5) bond_open() calls schedule_delayed_work(bar)
6) foo may run the "commit" work that should not be run
7) foo re-arms
8) if (foo == bar) -> BUG	/* bond->mode did not change */

With this patch, it is:

1) schedule_delayed_work(foo)
2) foo's timer expires and foo is queued on bond->wq
3) foo may have queued foo_commit on bond->wq_rtnl
4) bond_close() cancels foo
5) bond_open()
6) foo_commit may run and it should not be run

The patch avoids the problem of 7) and 8)

I think the race in 6) remains the same. It is now easier to fix.
This could even be done with a flag (similar to kill_timers),
which would be set each time the "commit" work is queued on wq_rtnl and
cleared by bond_close(). This should avoid the races completely,
I think. The trick is that, unlike kill_timers, bond_open() would
not touch this flag.

> 	I'm not sure this is better than one of the alternatives I
> believe we discussed the last time around: having the rtnl-acquiring
> work functions do a conditional acquire of rtnl, and if that fails,
> reschedule themselves.

[...]

> 		if (rtnl_trylock()) {
> 			read_lock(&bond->lock);
> 
> 			bond_miimon_commit(bond);
> 
> 			read_unlock(&bond->lock);
> 			rtnl_unlock();	/* might sleep, hold no other locks */
> 			read_lock(&bond->lock);
> 		} else {
> 			read_lock(&bond->lock);
> 			queue_work(bond->wq, &bond->mii_work);
> 			read_unlock(&bond->lock);
> 			return;
> 		}

I actually tried the other variant suggested last time
(basically:

while (!rtnl_trylock()) {
	read_lock(&bond->lock)
	kill = bond->kill_timers;
	read_unlock(&bond->lock)
	if (kill)
		return;
})

and gave that to a customer experiencing this problem (I cannot
reproduce it myself). It was reported to lock up. I suspect some
kind of live-lock on bond->lock caused by the active waiting, but
I did not spend too much time debugging this.
[BTW, this is https://bugzilla.novell.com/show_bug.cgi?id=602969
,Novell BZ account needeed]

FWIW  this would be the only use of rtnl_trylock() in the kernel,
besides a few places that do:
	if (!rtnl_trylock()) return restart_syscall();
I think it is plain ugly -- semaphores are just not supposed to be
spinned on.

Your re-scheduling variant is more or less equivalent to active
spinning, isn't it? Anyway, if you really think it is a better approach,
are you going to apply it? I can supply the patch. (Although I
kinda don't like people seeing my name next to it ;))

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

