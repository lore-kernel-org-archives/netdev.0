From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: iptables very slow after commit
	784544739a25c30637397ace5489eeb6e15d7d49
Date: Sat, 11 Apr 2009 10:43:50 -0700
Message-ID: <20090411174350.GF6822@linux.vnet.ibm.com>
References: <Pine.LNX.4.64.0904101656190.2093@boston.corp.fedex.com> <20090410095246.4fdccb56@s6510> <20090410.182507.140306636.davem@davemloft.net> <alpine.LFD.2.00.0904101828490.4583@localhost.localdomain> <20090411041533.GB6822@linux.vnet.ibm.com> <20090411085009.13d5a349@nehalam>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Ingo Molnar <mingo@elte.hu>,
	Lai Jiangshan <laijs@cn.fujitsu.com>,
	jeff.chua.linux@gmail.com, dada1@cosmosbay.com, jengelh@medozas.de,
	kaber@trash.net, r000n@r000n.net,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090411085009.13d5a349@nehalam>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 11, 2009 at 08:50:09AM -0700, Stephen Hemminger wrote:
> On Fri, 10 Apr 2009 21:15:33 -0700
> "Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:
> 
> > On Fri, Apr 10, 2009 at 06:39:18PM -0700, Linus Torvalds wrote:
> > > 
> > > 
> > > On Fri, 10 Apr 2009, David Miller wrote:
> > > > 
> > > > [ CC:'ing netfilter-devel and netdev... ]
> > > 
> > > I wonder if we should bring in the RCU people too, for them to tell you 
> > > that the networking people are beign silly, and should not synchronize 
> > > with the very heavy-handed
> > > 
> > > 	synchronize_net()
> > > 
> > > but instead of doing synchronization (which is probably why adding a few 
> > > hundred rules then takes several seconds - each synchronizes and that 
> > > takes a timer tick or so), add the rules to be free'd on some rcu-freeing 
> > > list for later freeing.
> > > 
> > > Or whatever. Paul? synchronize_net() just calls synchronize_rcu(), and 
> > > with that knowledge and a simple
> > > 
> > > 	git show 784544739a25c30637397ace5489eeb6e15d7d49
> > > 
> > > I bet you can already tell people how to fix their performance issue.
> > 
> > Well, I am certainly happy to demonstrate my ignorance of the networking
> > code by throwing out a few suggestions.
> > 
> > So, Dave and Steve, you might want to get out your barf bag before
> > reading further.  You have been warned!  ;-)
> > 
> > 1.	Assuming that the synchronize_net() is intended to guarantee
> > 	that the new rules will be in effect before returning to
> > 	user space:
> 
> In this case it is to make sure that the old counter table is no
> longer being used by other cpu's receiving. 
> 
> > 	a.	Split this functionality, so that there is a new
> > 		user-space primitive that installs a new rule, but
> > 		without waiting.  They provide an additional user-space
> > 		primitive that waits for the rules to take effect.
> > 		Then, when loading a long list of rules, load them
> > 		using the non-waiting primitive, and wait at the end.
> > 
> > 	b.	As above, but provide a flag that says whether or not
> > 		to wait.  Same general effect.
> > 
> > 	But I am not seeing the direct connection between this patch
> > 	and netfilter, so...
> 
> > 2.	For the xt_replace_table() case, it would be necessary to add an
> > 	rcu_head to the xt_table_info, and replace each caller's direct
> > 	calls to xt_free_table_info() with call_rcu().
> > 
> > 	Now this has an issue in that the caller wants to return the
> > 	final counter values.  My assumption is that these values do
> > 	not in fact need to be exact.  If I am wrong about that, then
> > 	my suggestion would lose the counts from late readers.
> > 	I must defer to the networking guys as to whether this is
> > 	acceptable or not.  If not, more head-scratching would be
> > 	required.  (But it looks to me that the rule is being trashed,
> > 	so who cares about the extra counts?)
> 
> The problem is that users want to account for every byte. 

Ah!!!

Is this particular code path one of the ones responsible for the
slowdown?

> > 	In addition, a malicious user might be able to force this to
> > 	happen extremely frequently, running the system out of memory.
> > 	One way to fix this is to invoke synchronize_net() one out of
> > 	20 times or some such.
> 
> Malicious user == root, therefore don't care.

Sometimes things work out OK.  ;-)

> > 3.	For the alloc_counters() case, the comments indicate that we
> > 	really truly do want an atomic sampling of the counters.
> > 	The counters are 64-bit entities, which is a bit inconvenient.
> > 	Though people using this functionality are no doubt quite happy
> > 	to never have to worry about overflow, I hasten to add!
> 
> And we need snapshot of all counters (which are not even an array but
> a skip list).

OK.  However, the code seems to swap in a new set of counters intended
to account for subsequent packets.  So I was assuming that "snapshot"
meant that a given packet had to be accounted for precisely, but that
it was OK to do so either in the old set or the new set, as long as it
appeared in exactly one of the two sets.

If this assumption is accurate, then something like the following should
work.

If my assumption is wrong, what exactly does this snapshot need to do?

							Thanx, Paul

> > 	I will nevertheless suggest the following egregious hack to
> > 	get a consistent sample of one counter for some other CPU:
> > 
> > 	a.	Disable interrupts
> > 	b.	Atomically exchange the bottom 32 bits of the
> > 		counter with the value zero.
> > 	c.	Atomically exchange the top 32 bits of the counter
> > 		with the value zero.
> > 	d.	Concatenate the values obtained in (b) and (c), which
> > 		is the snapshot value.
> > 	e.	Re-enable interrupts.  Yes, for each counter.  Do it
> > 		for the honor of the -rt patchset.  ;-)
> > 
> > 		Disabling interrupts should make it impossible for
> > 		the low-order 32 bits of the counter to overflow before
> > 		we get around to zeroing the upper 32 bits.  Yes, this
> > 		is horribly paranoid, but please keep in mind that even
> > 		my level of paranoia is not always sufficient to keep
> > 		RCU working correctly.  :-/
> > 
> > 		Architectures with 64-bit atomics can simply do a 64-bit
> > 		exchange (or cmpxchg(), for that matter).
> > 
> > 	Now we still have the possibility that the other CPU is still
> > 	hammering away on the counter that we just zeroed from a
> > 	long-running RCU read-side critical section.
> > 
> > 	So, we also need to add an rcu_head somewhere, perhaps reuse
> > 	the one in xt_table_info, create a second one, or squirrel one
> > 	away somewhere else.  As long as there is a way to get to the
> > 	old counter values.  And a flag to indicate that the rcu_head
> > 	is in use.  It is socially irresponsible to pass a given
> > 	rcu_head to call_rcu() before it has been invoked after the
> > 	previous time it was passed to call_rcu().  But you guys all
> > 	knew that already.
> > 
> > 	We replace the synchronize_net() with call_rcu(), more or less.
> > 	The call_rcu() probably needs to be under the lock -- or at the
> > 	very least, setting the flag saying that it is in use needs to
> > 	be under the lock.
> > 
> > 	The RCU callback function traverses the old counters one last
> > 	time, adding their values to the new set of counters.  No
> > 	atomic exchange tricks are required this time, since all the
> > 	RCU readers that could possibly have held a reference to the
> > 	old set of counters must now be done.  We now clear the flag,
> > 	allowing the next counter snapshot to proceed.
> > 
> > OK, OK, Dave and Steve, I should have suggested that you get two
> > barf bags.  Maybe three.  ;-)
> > 
> > Additional caveat: coward that I am, I looked only at the IPv4 code.
> > There might well be additional complications in the arp and IPv6 code.
> > 
> > However, I do believe that something like this might actually work.
> > 
> > Thoughts?
> > 
> > 						Thanx, Paul
> > 
> > > 		Linus
> > > 
> > > ---
> > > > > On Fri, 10 Apr 2009 17:15:52 +0800 (SGT)
> > > > > Jeff Chua <jeff.chua.linux@gmail.com> wrote:
> > > > >> 
> > > > >> Adding 200 records in iptables took 6.0sec in 2.6.30-rc1 compared to 
> > > > >> 0.2sec in 2.6.29. I've bisected down this commit.
> > > > >> 
> > > > >> There are a few patches on top of the original patch. When I reverted the 
> > > > >> original commit + changing rcu_read() to rcu_read_bh(), it speeds up the 
> > > > >> inserts back to .2sec again.
> > > > >> 
> > > > >> I'm loading all the firewall rules during boot-up and this 6 secs slowness 
> > > > >> is really not very nice to wait for.
> > > > > 
> > > > > The performance benefit during operation is more important. The load
> > > > > time is fixable. The problem is probably generic to any set of rules,
> > > > > but could you post some info about your configuration (like the rule
> > > > > set), and the system configuration (# of cpu's, config etc).
> > > > > --
> > > > > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > > > > the body of a message to majordomo@vger.kernel.org
> > > > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > > > > Please read the FAQ at  http://www.tux.org/lkml/
> > > > 
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
