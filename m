From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: [RFC] bonding: fix workqueue re-arming races
Date: Wed, 1 Sep 2010 22:56:57 +0200
Message-ID: <20100901205656.GA14982@smudla-wifi.bakulak.kosire.czf>
References: <20100831170752.GA9743@midget.suse.cz>
 <20136.1283288063@death>
 <20100901131626.GA12447@midget.suse.cz>
 <24764.1283361274@death>
 <20100901183113.GA25227@midget.suse.cz>
 <12656.1283371238@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Bohac <jbohac@suse.cz>, bonding-devel@lists.sourceforge.net,
	markine@google.com, jarkao2@gmail.com, chavey@google.com,
	netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:50785 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751762Ab0IAUzk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Sep 2010 16:55:40 -0400
Content-Disposition: inline
In-Reply-To: <12656.1283371238@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 01, 2010 at 01:00:38PM -0700, Jay Vosburgh wrote:
> Jiri Bohac <jbohac@suse.cz> wrote:
> >I don't think this patch opens new races. The current race
> >scenario is:
> >
> >1) schedule_delayed_work(foo)
> >2) foo's timer expires and foo is queued on bond->wq
> >  (possibly, foo starts to run and either gets preempted or
> >  sleeps on rtnl)
> >3) bond_close() sets kill_timers=1 and calls
> >  cancel_delayed_work() which accomplishes nothing
> >4) bond_open() sets kill_timers=0
> >5) bond_open() calls schedule_delayed_work(bar)
> >6) foo may run the "commit" work that should not be run
> >7) foo re-arms
> >8) if (foo == bar) -> BUG	/* bond->mode did not change */
> >
> >With this patch, it is:
> >
> >1) schedule_delayed_work(foo)
> >2) foo's timer expires and foo is queued on bond->wq
> >3) foo may have queued foo_commit on bond->wq_rtnl
> >4) bond_close() cancels foo
> >5) bond_open()
> >6) foo_commit may run and it should not be run
> >
> >The patch avoids the problem of 7) and 8)
> 
> 	But the "with patch" #6 is a bigger window; it doesn't require
> step 5; the foo_commit, et al, can always run after bond_close (because
> nothing ever cancels the foo_commit except for unregistration).  That's
> the part that makes me nervous.

We can always call cancel_work(foo_commit) in bond_close. This
should make the race window the same size it is now.
I didn't do that because I was thinking we'd avoid the race
somehow completely. Perhaps we can do cancel_work() now and solve
it cleanly later.

> 	The current race, as I understand it, requires a "close then
> open" sequence with little delay between the two.

Yeah, not sure how small the delay has to be. With releasing
bond->lock, acquiring rtnl and re-acquiring bond->lock in most of
the work items it may be pretty long. Putting an extra check for
kill_timers after bond->lock is re-acquired will make the window
much smaller ...  just in case this is the way we want to "fix"
race conditions ;-)

> >I think the race in 6) remains the same. It is now easier to fix.
> >This could even be done with a flag (similar to kill_timers),
> >which would be set each time the "commit" work is queued on wq_rtnl and
> >cleared by bond_close(). This should avoid the races completely,
> >I think. The trick is that, unlike kill_timers, bond_open() would
> >not touch this flag.
> 
> 	I'm chewing on whether or not it's feasible to introduce some
> kind of generation count into bond_open/close, so that, e.g., at
> bond_close, the generation is incremented.  Each time any of the work
> items is queued, the current generation is stashed somewhere private to
> that work item (in struct bonding, probably).  Then, when it runs, it
> compares the current generation to the stored one.  If they don't match,
> then the work item does nothing.

I thought about the generation count as well before I did this
patch. I don't think you can put the counter in struct bonding --
because that would be overwritten with the new value if the work
item is re-scheduled by bond_open.

I think you would have to create a new dynamic structure on each
work schedule and pass it to the work item in the "data" pointer.
The structure would contain the counter and the bond pointer. It
would be freed by thework item. I did not like this too much.

> >[BTW, this is https://bugzilla.novell.com/show_bug.cgi?id=602969
> >,Novell BZ account needeed]
> 
> 	My BZ account is unworthy to access that bug; can you provide
> any information as to how they're hitting the problem?  Presumably
> they're doing something that's doing a fast down/up cycle on the bond,
> but anything else?

They are doing "rcnetwork restart", which will do the
close->open. Perhaps all the contention on the rtnl (lots of work
with other network interfaces) makes the race window longer. I
couldn't reproduce this.

> 	I'm wondering if there's any utility in the "generation count"
> idea I mention above.  It's still a sentinel, but if that can be worked
> out to reliably stop the work items after close, then maybe it's the
> least bad option.

Not without the dynamic allocation, I think.
How about the "kill_timers" on top of this patch (see my
previous e-mail) -- a flag that would be set when queuing the
"commit" work and cleared by bond_close()?

While this can not stop the re-arming race it is trying to stop
now, it should be able to stop the "commit" work items (where it
does not matter if you try to queue them on the workqueue for a
second time, since it is not a delayed work).

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

