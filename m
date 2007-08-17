From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Fri, 17 Aug 2007 13:09:08 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0708171232380.3666@enigma.security.iitk.ac.in>
References: <20070816053945.GB32442@gondor.apana.org.au>
 <18115.62741.807704.969977@cargo.ozlabs.ibm.com> <20070816070907.GA964@gondor.apana.org.au>
 <46C40587.7050708@s5r6.in-berlin.de> <20070816081049.GA1431@gondor.apana.org.au>
 <46C41EE4.9090806@s5r6.in-berlin.de> <46C42767.4070104@s5r6.in-berlin.de>
 <20070816104250.GB2927@gondor.apana.org.au> <20070816163441.GB16957@linux.vnet.ibm.com>
 <20070816235902.GB11594@gondor.apana.org.au>
 <20070817010108.GJ16957@linux.vnet.ibm.com>
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
Received: from pentafluge.infradead.org ([213.146.154.40]:39136 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239AbXHQH1H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 03:27:07 -0400
In-Reply-To: <20070817010108.GJ16957@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Thu, 16 Aug 2007, Paul E. McKenney wrote:

> On Fri, Aug 17, 2007 at 07:59:02AM +0800, Herbert Xu wrote:
> > On Thu, Aug 16, 2007 at 09:34:41AM -0700, Paul E. McKenney wrote:
> > >
> > > The compiler can also reorder non-volatile accesses.  For an example
> > > patch that cares about this, please see:
> > > 
> > > 	http://lkml.org/lkml/2007/8/7/280
> > > 
> > > This patch uses an ORDERED_WRT_IRQ() in rcu_read_lock() and
> > > rcu_read_unlock() to ensure that accesses aren't reordered with respect
> > > to interrupt handlers and NMIs/SMIs running on that same CPU.
> > 
> > Good, finally we have some code to discuss (even though it's
> > not actually in the kernel yet).
> 
> There was some earlier in this thread as well.

Hmm, I never quite got what all this interrupt/NMI/SMI handling and
RCU business you mentioned earlier was all about, but now that you've
pointed to the actual code and issues with it ...


> > First of all, I think this illustrates that what you want
> > here has nothing to do with atomic ops.  The ORDERED_WRT_IRQ
> > macro occurs a lot more times in your patch than atomic
> > reads/sets.  So *assuming* that it was necessary at all,
> > then having an ordered variant of the atomic_read/atomic_set
> > ops could do just as well.
> 
> Indeed.  If I could trust atomic_read()/atomic_set() to cause the compiler
> to maintain ordering, then I could just use them instead of having to
> create an  ORDERED_WRT_IRQ().  (Or ACCESS_ONCE(), as it is called in a
> different patch.)

+#define WHATEVER(x)	(*(volatile typeof(x) *)&(x))

I suppose one could want volatile access semantics for stuff that's
a bit-field too, no?

Also, this gives *zero* "re-ordering" guarantees that your code wants
as you've explained it below) -- neither w.r.t. CPU re-ordering (which
probably you don't care about) *nor* w.r.t. compiler re-ordering
(which you definitely _do_ care about).


> > However, I still don't know which atomic_read/atomic_set in
> > your patch would be broken if there were no volatile.  Could
> > you please point them out?
> 
> Suppose I tried replacing the ORDERED_WRT_IRQ() calls with
> atomic_read() and atomic_set().  Starting with __rcu_read_lock():
> 
> o	If "ORDERED_WRT_IRQ(__get_cpu_var(rcu_flipctr)[idx])++"
> 	was ordered by the compiler after
> 	"ORDERED_WRT_IRQ(me->rcu_read_lock_nesting) = nesting + 1", then
> 	suppose an NMI/SMI happened after the rcu_read_lock_nesting but
> 	before the rcu_flipctr.
> 
> 	Then if there was an rcu_read_lock() in the SMI/NMI
> 	handler (which is perfectly legal), the nested rcu_read_lock()
> 	would believe that it could take the then-clause of the
> 	enclosing "if" statement.  But because the rcu_flipctr per-CPU
> 	variable had not yet been incremented, an RCU updater would
> 	be within its rights to assume that there were no RCU reads
> 	in progress, thus possibly yanking a data structure out from
> 	under the reader in the SMI/NMI function.
> 
> 	Fatal outcome.  Note that only one CPU is involved here
> 	because these are all either per-CPU or per-task variables.

Ok, so you don't care about CPU re-ordering. Still, I should let you know
that your ORDERED_WRT_IRQ() -- bad name, btw -- is still buggy. What you
want is a full compiler optimization barrier().

[ Your code probably works now, and emits correct code, but that's
  just because of gcc did what it did. Nothing in any standard,
  or in any documented behaviour of gcc, or anything about the real
  (or expected) semantics of "volatile" is protecting the code here. ]


> o	If "ORDERED_WRT_IRQ(me->rcu_read_lock_nesting) = nesting + 1"
> 	was ordered by the compiler to follow the
> 	"ORDERED_WRT_IRQ(me->rcu_flipctr_idx) = idx", and an NMI/SMI
> 	happened between the two, then an __rcu_read_lock() in the NMI/SMI
> 	would incorrectly take the "else" clause of the enclosing "if"
> 	statement.  If some other CPU flipped the rcu_ctrlblk.completed
> 	in the meantime, then the __rcu_read_lock() would (correctly)
> 	write the new value into rcu_flipctr_idx.
> 
> 	Well and good so far.  But the problem arises in
> 	__rcu_read_unlock(), which then decrements the wrong counter.
> 	Depending on exactly how subsequent events played out, this could
> 	result in either prematurely ending grace periods or never-ending
> 	grace periods, both of which are fatal outcomes.
> 
> And the following are not needed in the current version of the
> patch, but will be in a future version that either avoids disabling
> irqs or that dispenses with the smp_read_barrier_depends() that I
> have 99% convinced myself is unneeded:
> 
> o	nesting = ORDERED_WRT_IRQ(me->rcu_read_lock_nesting);
> 
> o	idx = ORDERED_WRT_IRQ(rcu_ctrlblk.completed) & 0x1;
> 
> Furthermore, in that future version, irq handlers can cause the same
> mischief that SMI/NMI handlers can in this version.
> 
> Next, looking at __rcu_read_unlock():
> 
> o	If "ORDERED_WRT_IRQ(me->rcu_read_lock_nesting) = nesting - 1"
> 	was reordered by the compiler to follow the
> 	"ORDERED_WRT_IRQ(__get_cpu_var(rcu_flipctr)[idx])--",
> 	then if an NMI/SMI containing an rcu_read_lock() occurs between
> 	the two, this nested rcu_read_lock() would incorrectly believe
> 	that it was protected by an enclosing RCU read-side critical
> 	section as described in the first reversal discussed for
> 	__rcu_read_lock() above.  Again, fatal outcome.
> 
> This is what we have now.  It is not hard to imagine situations that
> interact with -both- interrupt handlers -and- other CPUs, as described
> earlier.

It's not about interrupt/SMI/NMI handlers at all! What you clearly want,
simply put, is that a certain stream of C statements must be emitted
by the compiler _as they are_ with no re-ordering optimizations! You must
*definitely* use barrier(), IMHO.


Satyam
