From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/24] make atomic_read() behave consistently on alpha
Date: Fri, 10 Aug 2007 13:26:46 -0700
Message-ID: <20070810202646.GD8511@linux.vnet.ibm.com>
References: <20070809161024.GC8424@linux.vnet.ibm.com> <46BB4281.7010803@redhat.com> <20070809165853.GD8424@linux.vnet.ibm.com> <46BB4B7B.4070007@redhat.com> <20070809174150.GE8424@linux.vnet.ibm.com> <46BB5960.9040009@redhat.com> <20070809184531.GH8424@linux.vnet.ibm.com> <46BB69F8.5000502@redhat.com> <20070810012848.GJ8424@linux.vnet.ibm.com> <46BCC12F.9020803@redhat.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	torvalds@linux-foundation.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, ak@suse.de, heiko.carstens@de.ibm.com,
	davem@davemloft.net, schwidefsky@de.ibm.com, wensong@linux-vs.org,
	horms@verge.net.au, wjiang@resilience.com, cfriesen@nortel.com,
	zlynx@acm.org, rpjday@mindspring.com, jesper.juhl@gmail.com
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:46730 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966031AbXHJU0x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 16:26:53 -0400
Content-Disposition: inline
In-Reply-To: <46BCC12F.9020803@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 10, 2007 at 03:49:03PM -0400, Chris Snook wrote:
> Paul E. McKenney wrote:
> >On Thu, Aug 09, 2007 at 03:24:40PM -0400, Chris Snook wrote:
> >>Paul E. McKenney wrote:
> >>>On Thu, Aug 09, 2007 at 02:13:52PM -0400, Chris Snook wrote:
> >>>>Paul E. McKenney wrote:
> >>>>>On Thu, Aug 09, 2007 at 01:14:35PM -0400, Chris Snook wrote:
> >>>>>>                              If you're depending on volatile writes 
> >>>>>>being visible to other CPUs, you're screwed either way, because the 
> >>>>>>CPU can hold that data in cache as long as it wants before it writes 
> >>>>>>it to memory.  When this finally does happen, it will happen 
> >>>>>>atomically, which is all that atomic_set guarantees.  If you need to 
> >>>>>>guarantee that the value is written to memory at a particular time in 
> >>>>>>your execution sequence, you either have to read it from memory to 
> >>>>>>force the compiler to store it first (and a volatile cast in 
> >>>>>>atomic_read will suffice for this) or you have to use LOCK_PREFIX 
> >>>>>>instructions which will invalidate remote cache lines containing the 
> >>>>>>same variable.  This patch doesn't change either of these cases.
> >>>>>The case that it -can- change is interactions with interrupt handlers.
> >>>>>And NMI/SMI handlers, for that matter.
> >>>>You have a point here, but only if you can guarantee that the interrupt 
> >>>>handler is running on a processor sharing the cache that has the 
> >>>>not-yet-written volatile value.  That implies a strictly non-SMP 
> >>>>architecture.  At the moment, none of those have volatile in their 
> >>>>declaration of atomic_t, so this patch can't break any of them.
> >>>This can also happen when using per-CPU variables.  And there are a
> >>>number of per-CPU variables that are either atomic themselves or are
> >>>structures containing atomic fields.
> >>Accessing per-CPU variables in this fashion reliably already requires a 
> >>suitable smp/non-smp read/write memory barrier.  I maintain that if we 
> >>break anything with this change, it was really already broken, if less 
> >>obviously.  Can you give a real or synthetic example of legitimate code 
> >>that could break?
> >
> >My main concern is actually the lack of symmetry -- I would expect
> >that an atomic_set() would have the same properties as atomic_read().
> >It is easy and cheap to provide them with similar properties, so why not?
> >Debugging even a single problem would consume far more time than simply
> >giving them corresponding semantics.
> >
> >But you asked for examples.  These are synthetic, and of course legitimacy
> >is in the eye of the beholder.
> >
> >1.  Watchdog variable.
> >
> >	atomic_t watchdog = ATOMIC_INIT(0);
> >
> >	...
> >
> >	int i;
> >	while (!done) {
> >
> >		/* Do so stuff that doesn't take more than a few us. */
> >		/* Could do atomic increment, but throughput penalty. */
> >
> >		i++;
> >		atomic_set(&watchdog, i);
> >	}
> >	do_something_with(&watchdog);
> >
> >
> >	/* Every so often on some other CPU... */
> >
> >	if ((new_watchdog = atomic_read(&watchdog)) == old_watchdog)
> >		die_horribly();
> >	old_watchdog = new_watchdog;
> >
> >
> >	If atomic_set() did not have volatile semantics, the compiler
> >	would be within its rights optimizing it to simply get the
> >	final value of "i" after exit from the loop.  This would cause
> >	the watchdog check to fail spuriously.  Memory barriers are
> >	not required in this case, because the CPU cannot hang onto
> >	the value for very long -- we don't care about the exact value,
> >	or about exact synchronization, but rather about whether or
> >	not the value is changing.
> >
> >	In this (toy) example, one might replace the atomic_set() with
> >	an atomic increment (though that might be too expensive in some
> >	cases) or with something like:
> >
> >		atomic_set(&watchdog, atomic_read(&watchdog) + 1);
> >
> >	However, other cases might not permit this transformation,
> >	for example, an existing heavily used API might take int rather
> >	than atomic_t.
> >
> >	Some will no doubt argue that this example should use a
> >	macro or an asm similar to the "forget()" asm put forward
> >	elsewhere in this thread.
> >
> >2.  Communicating both with interrupt handler and with other CPUs.
> >    For example, data elements that are built up in a location visible
> >    to interrupts and NMIs, and then added as a unit to a data structure
> >    visible to other CPUs.  This more-realistic example is abbreviated
> >    to the point of pointlessness as follows:
> >
> >	struct foo {
> >		atomic_t a;
> >		atomic_t b;
> >	};
> >
> >	DEFINE_PER_CPU(struct foo *, staging) = NULL;
> >
> >	/* Create element in staging area. */
> >
> >	__get_cpu_var(staging) = kzalloc(sizeof(*p), GFP_WHATEVER);
> >	if (__get_cpu_var(staging) == NULL)
> >		die_horribly();
> >	/* allocate an element of some per-CPU array, get the result in "i" 
> >	*/
> >	atomic_set(__get_cpu_var(staging).a, i);
> >	/* allocate another element of a per-CPU array, with result in "i" */
> >	atomic_set(__get_cpu_var(staging).b, i);
> >	rcu_assign_pointer(some_global_place, __get_cpu_var(staging));
> >
> >	If atomic_set() didn't have volatile semantics, then an interrupt
> >	or NMI handler could see the atomic_set() to .a and .b out of
> >	order due to compiler optimizations.
> >
> >Remember, you -did- ask for these!!!  ;-)
> 
> Ok, I'm convinced.  Part of the motivation here is to avoid heisenbugs, 
> so if people expect volatile atomic_set behavior, I'm inclined to give 
> it to them.  I don't really feel like indulging the compiler bug 
> paranoiacs, but developer expectations are a legitimate motivation, and 
> a major part of why I posted this in the first place.  I'll resubmit the 
> patchset with a volatile cast in atomic_set.  Before I do, is there 
> anything *else* that desperately needs such a cast?  As far as I can 
> tell, all the other functions are implemented with __asm__ __volatile__, 
> or with spinlocks that use that under the hood.

Sounds good!!!

The only other API that I am aware of needing volatile semantics is
rcu_dereference(), but I already sent a patch in for it.  So as far
as I know, atomic_read() and atomic_set() should cover it.

							Thanx, Paul
