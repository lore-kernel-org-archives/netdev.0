From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Sat, 18 Aug 2007 00:01:38 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0708172040370.3666@enigma.security.iitk.ac.in>
References: <20070816070907.GA964@gondor.apana.org.au> <46C40587.7050708@s5r6.in-berlin.de>
 <20070816081049.GA1431@gondor.apana.org.au> <46C41EE4.9090806@s5r6.in-berlin.de>
 <46C42767.4070104@s5r6.in-berlin.de> <20070816104250.GB2927@gondor.apana.org.au>
 <20070816163441.GB16957@linux.vnet.ibm.com> <20070816235902.GB11594@gondor.apana.org.au>
 <20070817010108.GJ16957@linux.vnet.ibm.com>
 <alpine.LFD.0.999.0708171232380.3666@enigma.security.iitk.ac.in>
 <20070817143101.GA8464@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Paul Mackerras <paulus@samba.org>,
	Christoph Lameter <clameter@sgi.com>,
	Chris Snook <csnook@redhat.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	ak@suse.de, heiko.carstens@de.ibm.com, davem@davemloft.net,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:33098 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750716AbXHQSWc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 14:22:32 -0400
In-Reply-To: <20070817143101.GA8464@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 17 Aug 2007, Paul E. McKenney wrote:

> On Fri, Aug 17, 2007 at 01:09:08PM +0530, Satyam Sharma wrote:
> > 
> > On Thu, 16 Aug 2007, Paul E. McKenney wrote:
> > 
> > > On Fri, Aug 17, 2007 at 07:59:02AM +0800, Herbert Xu wrote:
> > > > 
> > > > First of all, I think this illustrates that what you want
> > > > here has nothing to do with atomic ops.  The ORDERED_WRT_IRQ
> > > > macro occurs a lot more times in your patch than atomic
> > > > reads/sets.  So *assuming* that it was necessary at all,
> > > > then having an ordered variant of the atomic_read/atomic_set
> > > > ops could do just as well.
> > > 
> > > Indeed.  If I could trust atomic_read()/atomic_set() to cause the compiler
> > > to maintain ordering, then I could just use them instead of having to
> > > create an  ORDERED_WRT_IRQ().  (Or ACCESS_ONCE(), as it is called in a
> > > different patch.)
> > 
> > +#define WHATEVER(x)	(*(volatile typeof(x) *)&(x))
> > [...]
> > Also, this gives *zero* "re-ordering" guarantees that your code wants
> > as you've explained it below) -- neither w.r.t. CPU re-ordering (which
> > probably you don't care about) *nor* w.r.t. compiler re-ordering
> > (which you definitely _do_ care about).
> 
> You are correct about CPU re-ordering (and about the fact that this
> example doesn't care about it), but not about compiler re-ordering.
> 
> The compiler is prohibited from moving a volatile access across a sequence
> point.  One example of a sequence point is a statement boundary.  Because
> all of the volatile accesses in this code are separated by statement
> boundaries, a conforming compiler is prohibited from reordering them.

Yes, you're right, and I believe precisely this was discussed elsewhere
as well today.

But I'd call attention to what Herbert mentioned there. You're using
ORDERED_WRT_IRQ() on stuff that is _not_ defined to be an atomic_t at all:

* Member "completed" of struct rcu_ctrlblk is a long.
* Per-cpu variable rcu_flipctr is an array of ints.
* Members "rcu_read_lock_nesting" and "rcu_flipctr_idx" of
  struct task_struct are ints.

So are you saying you're "having to use" this volatile-access macro
because you *couldn't* declare all the above as atomic_t and thus just
expect the right thing to happen by using the atomic ops API by default,
because it lacks volatile access semantics (on x86)?

If so, then I wonder if using the volatile access cast is really the
best way to achieve (at least in terms of code clarity) the kind of
re-ordering guarantees it wants there. (there could be alternative
solutions, such as using barrier(), or that at bottom of this mail)

What I mean is this: If you switch to atomic_t, and x86 switched to
make atomic_t have "volatile" semantics by default, the statements
would be simply a string of: atomic_inc(), atomic_add(), atomic_set(),
and atomic_read() statements, and nothing in there that clearly makes
it *explicit* that the code is correct (and not buggy) simply because
of the re-ordering guarantees that the C "volatile" type-qualifier
keyword gives us as per the standard. But now we're firmly in
"subjective" territory, so you or anybody could legitimately disagree.


> > > Suppose I tried replacing the ORDERED_WRT_IRQ() calls with
> > > atomic_read() and atomic_set().  Starting with __rcu_read_lock():
> > > 
> > > o	If "ORDERED_WRT_IRQ(__get_cpu_var(rcu_flipctr)[idx])++"
> > > 	was ordered by the compiler after
> > > 	"ORDERED_WRT_IRQ(me->rcu_read_lock_nesting) = nesting + 1", then
> > > 	suppose an NMI/SMI happened after the rcu_read_lock_nesting but
> > > 	before the rcu_flipctr.
> > > 
> > > 	Then if there was an rcu_read_lock() in the SMI/NMI
> > > 	handler (which is perfectly legal), the nested rcu_read_lock()
> > > 	would believe that it could take the then-clause of the
> > > 	enclosing "if" statement.  But because the rcu_flipctr per-CPU
> > > 	variable had not yet been incremented, an RCU updater would
> > > 	be within its rights to assume that there were no RCU reads
> > > 	in progress, thus possibly yanking a data structure out from
> > > 	under the reader in the SMI/NMI function.
> > > 
> > > 	Fatal outcome.  Note that only one CPU is involved here
> > > 	because these are all either per-CPU or per-task variables.
> > 
> > Ok, so you don't care about CPU re-ordering. Still, I should let you know
> > that your ORDERED_WRT_IRQ() -- bad name, btw -- is still buggy. What you
> > want is a full compiler optimization barrier().
> 
> No.  See above.

True, *(volatile foo *)& _will_ work for this case.

But multiple calls to barrier() (granted, would invalidate all other
optimizations also) would work as well, would it not?

[ Interestingly, if you declared all those objects mentioned earlier as
  atomic_t, and x86(-64) switched to an __asm__ __volatile__ based variant
  for atomic_{read,set}_volatile(), the bugs you want to avoid would still
  be there. "volatile" the C language type-qualifier does have compiler
  re-ordering semantics you mentioned earlier, but the "volatile" that
  applies to inline asm()s gives no re-ordering guarantees. ]


> > > o	If "ORDERED_WRT_IRQ(me->rcu_read_lock_nesting) = nesting + 1"
> > > 	was ordered by the compiler to follow the
> > > 	"ORDERED_WRT_IRQ(me->rcu_flipctr_idx) = idx", and an NMI/SMI
> > > 	happened between the two, then an __rcu_read_lock() in the NMI/SMI
> > > 	would incorrectly take the "else" clause of the enclosing "if"
> > > 	statement.  If some other CPU flipped the rcu_ctrlblk.completed
> > > 	in the meantime, then the __rcu_read_lock() would (correctly)
> > > 	write the new value into rcu_flipctr_idx.
> > > 
> > > 	Well and good so far.  But the problem arises in
> > > 	__rcu_read_unlock(), which then decrements the wrong counter.
> > > 	Depending on exactly how subsequent events played out, this could
> > > 	result in either prematurely ending grace periods or never-ending
> > > 	grace periods, both of which are fatal outcomes.
> > > 
> > > And the following are not needed in the current version of the
> > > patch, but will be in a future version that either avoids disabling
> > > irqs or that dispenses with the smp_read_barrier_depends() that I
> > > have 99% convinced myself is unneeded:
> > > 
> > > o	nesting = ORDERED_WRT_IRQ(me->rcu_read_lock_nesting);
> > > 
> > > o	idx = ORDERED_WRT_IRQ(rcu_ctrlblk.completed) & 0x1;
> > > 
> > > Furthermore, in that future version, irq handlers can cause the same
> > > mischief that SMI/NMI handlers can in this version.

So don't remove the local_irq_save/restore, which is well-established and
well-understood for such cases (it doesn't help you with SMI/NMI,
admittedly). This isn't really about RCU or per-cpu vars as such, it's
just about racy code where you don't want to get hit by a concurrent
interrupt (it does turn out that doing things in a _particular order_ will
not cause fatal/buggy behaviour, but it's still a race issue, after all).


> > > Next, looking at __rcu_read_unlock():
> > > 
> > > o	If "ORDERED_WRT_IRQ(me->rcu_read_lock_nesting) = nesting - 1"
> > > 	was reordered by the compiler to follow the
> > > 	"ORDERED_WRT_IRQ(__get_cpu_var(rcu_flipctr)[idx])--",
> > > 	then if an NMI/SMI containing an rcu_read_lock() occurs between
> > > 	the two, this nested rcu_read_lock() would incorrectly believe
> > > 	that it was protected by an enclosing RCU read-side critical
> > > 	section as described in the first reversal discussed for
> > > 	__rcu_read_lock() above.  Again, fatal outcome.
> > > 
> > > This is what we have now.  It is not hard to imagine situations that
> > > interact with -both- interrupt handlers -and- other CPUs, as described
> > > earlier.

Unless somebody's going for a lockless implementation, such situations
normally use spin_lock_irqsave() based locking (or local_irq_save for
those who care only for current CPU) -- problem with the patch in question,
is that you want to prevent races with concurrent SMI/NMIs as well, which
is not something that a lot of code needs to consider.

[ Curiously, another thread is discussing something similar also:
  http://lkml.org/lkml/2007/8/15/393 "RFC: do get_rtc_time() correctly" ]

Anyway, I didn't look at the code in that patch very much in detail, but
why couldn't you implement some kind of synchronization variable that lets
rcu_read_lock() or rcu_read_unlock() -- when being called from inside an
NMI or SMI handler -- know that it has concurrently interrupted an ongoing
rcu_read_{un}lock() and so must do things differently ... (?)

I'm also wondering if there's other code that's not using locking in the
kernel that faces similar issues, and what they've done to deal with it
(if anything). Such bugs would be subtle, and difficult to diagnose.


Satyam
