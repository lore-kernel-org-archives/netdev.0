From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [RFC] bonding: fix workqueue re-arming races
Date: Wed, 01 Sep 2010 13:00:38 -0700
Message-ID: <12656.1283371238@death>
References: <20100831170752.GA9743@midget.suse.cz> <20136.1283288063@death> <20100901131626.GA12447@midget.suse.cz> <24764.1283361274@death> <20100901183113.GA25227@midget.suse.cz>
Cc: bonding-devel@lists.sourceforge.net, markine@google.com,
	jarkao2@gmail.com, chavey@google.com, netdev@vger.kernel.org
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:56744 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752841Ab0IAUAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 16:00:45 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o81JqKtx013446
	for <netdev@vger.kernel.org>; Wed, 1 Sep 2010 13:52:20 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o81K0geL121414
	for <netdev@vger.kernel.org>; Wed, 1 Sep 2010 14:00:42 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o81K0ffq031116
	for <netdev@vger.kernel.org>; Wed, 1 Sep 2010 14:00:41 -0600
In-reply-to: <20100901183113.GA25227@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Bohac <jbohac@suse.cz> wrote:

>On Wed, Sep 01, 2010 at 10:14:34AM -0700, Jay Vosburgh wrote:
>> 	I also thought a bit more, and in the current code, the mode
>> shouldn't change in the middle of one of the work functions, because a
>> mode change requires the bond to be closed, so the various work things
>> will be stopped (more or less; excepting the race under disucssion
>> here).
>>
>> 	I don't think this is true for the new wq_rtnl functions,
>> however, because its work items are not canceled until the workqueue
>> itself is freed in bond_destructor.  Does the wq_rtnl open new races,
>> because it's work items are not synchronized with other activities
>> (close in particular)?  It's possible for its work functions (which may
>> do things like set the active slave, carrier, etc) to be invoked after
>> the bond has closed, and possibly reopened, or been otherwise adjusted.
>
>I don't think this patch opens new races. The current race
>scenario is:
>
>1) schedule_delayed_work(foo)
>2) foo's timer expires and foo is queued on bond->wq
>  (possibly, foo starts to run and either gets preempted or
>  sleeps on rtnl)
>3) bond_close() sets kill_timers=1 and calls
>  cancel_delayed_work() which accomplishes nothing
>4) bond_open() sets kill_timers=0
>5) bond_open() calls schedule_delayed_work(bar)
>6) foo may run the "commit" work that should not be run
>7) foo re-arms
>8) if (foo == bar) -> BUG	/* bond->mode did not change */
>
>With this patch, it is:
>
>1) schedule_delayed_work(foo)
>2) foo's timer expires and foo is queued on bond->wq
>3) foo may have queued foo_commit on bond->wq_rtnl
>4) bond_close() cancels foo
>5) bond_open()
>6) foo_commit may run and it should not be run
>
>The patch avoids the problem of 7) and 8)

	But the "with patch" #6 is a bigger window; it doesn't require
step 5; the foo_commit, et al, can always run after bond_close (because
nothing ever cancels the foo_commit except for unregistration).  That's
the part that makes me nervous.

	The current race, as I understand it, requires a "close then
open" sequence with little delay between the two.

>I think the race in 6) remains the same. It is now easier to fix.
>This could even be done with a flag (similar to kill_timers),
>which would be set each time the "commit" work is queued on wq_rtnl and
>cleared by bond_close(). This should avoid the races completely,
>I think. The trick is that, unlike kill_timers, bond_open() would
>not touch this flag.

	I'm chewing on whether or not it's feasible to introduce some
kind of generation count into bond_open/close, so that, e.g., at
bond_close, the generation is incremented.  Each time any of the work
items is queued, the current generation is stashed somewhere private to
that work item (in struct bonding, probably).  Then, when it runs, it
compares the current generation to the stored one.  If they don't match,
then the work item does nothing.

	It's still a "kill_timers," but perhaps not subject to the
close/open issue that a boolean flag has.  It's also not all that
elegant, either, but maybe is less bad than the other alternatives.

>> 	I'm not sure this is better than one of the alternatives I
>> believe we discussed the last time around: having the rtnl-acquiring
>> work functions do a conditional acquire of rtnl, and if that fails,
>> reschedule themselves.
>
>[...]
>
>> 		if (rtnl_trylock()) {
>> 			read_lock(&bond->lock);
>> 
>> 			bond_miimon_commit(bond);
>> 
>> 			read_unlock(&bond->lock);
>> 			rtnl_unlock();	/* might sleep, hold no other locks */
>> 			read_lock(&bond->lock);
>> 		} else {
>> 			read_lock(&bond->lock);
>> 			queue_work(bond->wq, &bond->mii_work);
>> 			read_unlock(&bond->lock);
>> 			return;
>> 		}
>
>I actually tried the other variant suggested last time
>(basically:
>
>while (!rtnl_trylock()) {
>	read_lock(&bond->lock)
>	kill = bond->kill_timers;
>	read_unlock(&bond->lock)
>	if (kill)
>		return;
>})
>
>and gave that to a customer experiencing this problem (I cannot
>reproduce it myself). It was reported to lock up. I suspect some
>kind of live-lock on bond->lock caused by the active waiting, but
>I did not spend too much time debugging this.
>[BTW, this is https://bugzilla.novell.com/show_bug.cgi?id=602969
>,Novell BZ account needeed]

	My BZ account is unworthy to access that bug; can you provide
any information as to how they're hitting the problem?  Presumably
they're doing something that's doing a fast down/up cycle on the bond,
but anything else?

>FWIW  this would be the only use of rtnl_trylock() in the kernel,
>besides a few places that do:
>	if (!rtnl_trylock()) return restart_syscall();
>I think it is plain ugly -- semaphores are just not supposed to be
>spinned on.
>
>Your re-scheduling variant is more or less equivalent to active
>spinning, isn't it? Anyway, if you really think it is a better approach,
>are you going to apply it? I can supply the patch. (Although I
>kinda don't like people seeing my name next to it ;))

	Well, it could have a queue_delayed_work() with a bit of real
time in there, and it's not a simple spin loop, there's actually a
scheduling step in the middle.  I'm relucant to call it "better,"
though, as that kind of implies it's inherently "good."  "Less bad,"
perhaps.

	Anyway, maybe there are other ways to accomplish the end goal
(no executing of "stuff" after close) without resorting to either of
these strategies (since what we're really discussing here is relative
awfulness; neither is what I'd call a really good option).

	I'm wondering if there's any utility in the "generation count"
idea I mention above.  It's still a sentinel, but if that can be worked
out to reliably stop the work items after close, then maybe it's the
least bad option.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com


