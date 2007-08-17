From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Fri, 17 Aug 2007 11:26:22 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0708171016160.3666@enigma.security.iitk.ac.in>
References: <E1ILCgh-00052A-00@gondolin.me.apana.org.au> <46C32618.2080108@redhat.com>
 <20070815234021.GA28775@gondor.apana.org.au> <3694fb2e4ed1e4d9bf873c0d050c911e@kernel.crashing.org>
 <46C3B50E.7010702@yahoo.com.au> <194369f4c96ea0e24decf8f9197d5bad@kernel.crashing.org>
 <46C505B2.6030704@yahoo.com.au> <18117.4848.695269.72976@cargo.ozlabs.ibm.com>
 <alpine.LFD.0.999.0708162033400.30176@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Paul Mackerras <paulus@samba.org>,
	Nick Piggin <nickpiggin@yahoo.com.au>,
	Segher Boessenkool <segher@kernel.crashing.org>,
	heiko.carstens@de.ibm.com, horms@verge.net.au,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	rpjday@mindspring.com, ak@suse.de, netdev@vger.kernel.org,
	cfriesen@nortel.com, Andrew Morton <akpm@linux-foundation.org>,
	jesper.juhl@gmail.com, linux-arch@vger.kernel.org, zlynx@acm.org,
	clameter@sgi.com, schwidefsky@de.ibm.com,
	Chris Snook <csnook@redhat.com>,
	Herbert Xu <herbert.xu@redhat.com>, davem@davemloft.net,
	wensong@linux-vs.org, wjiang@resilience.com
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:58581 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754886AbXHQFnz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 01:43:55 -0400
In-Reply-To: <alpine.LFD.0.999.0708162033400.30176@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Linus,

[ and others; I think there's a communication gap in a lot of this
  thread, and a little summary would be useful. Hence this posting. ]


On Thu, 16 Aug 2007, Linus Torvalds wrote:

> On Fri, 17 Aug 2007, Paul Mackerras wrote:
> > 
> > I'm really surprised it's as much as a few K.  I tried it on powerpc
> > and it only saved 40 bytes (10 instructions) for a G5 config.
> 
> One of the things that "volatile" generally screws up is a simple
> 
> 	volatile int i;
> 
> 	i++;
> 
> which a compiler will generally get horribly, horribly wrong.
> 
> [...] For no good reason, except that "volatile" just doesn't have any 
> good/clear semantics for the compiler, so most compilers will just make it 
> be "I will not touch this access in any way, shape, or form". Including 
> even trivially correct instruction optimization/combination.
> 
> This is one of the reasons why we should never use "volatile". It 
> pessimises code generation for no good reason - just because compilers 
> don't know what the heck it even means! 
> [...]
> In other words: "volatile" is a horribly horribly bad way of doing things, 
> because it generates *worse*code*, for no good reason. You just don't see 
> it on powerpc, because it's already a load-store architecture, so there is 
> no "good code" for doing direct-to-memory operations.


True, and I bet *everybody* on this list has already agreed for a very
long time that using "volatile" to type-qualify the _declaration_ of an
object itself as being horribly bad (taste-wise, code-generation-wise,
often even buggy for sitations where real CPU barriers should've been
used instead).

However, the discussion on this thread (IIRC) began with only "giving
volatility semantics" to atomic ops. Now that is different, and may not
require the use the "volatile" keyword (at least not in the declaration
of the object) itself.

Sadly, most arch's *still* do type-qualify the declaration of the
"counter" member of atomic_t as "volatile". This is probably a historic
hangover, and I suspect not yet rectified because of lethargy.

Anyway, some of the variants I can think of are:

[1]

#define atomic_read_volatile(v)				\
	({						\
		forget((v)->counter);			\
		((v)->counter);				\
	})

where:

#define forget(a)	__asm__ __volatile__ ("" :"=m" (a) :"m" (a))

[ This is exactly equivalent to using "+m" in the constraints, as recently
  explained on a GCC list somewhere, in response to the patch in my bitops
  series a few weeks back where I thought "+m" was bogus. ]

[2]

#define atomic_read_volatile(v)		(*(volatile int *)&(v)->counter)

This is something that does work. It has reasonably good semantics
guaranteed by the C standard in conjunction with how GCC currently
behaves (and how it has behaved for all supported versions). I haven't
checked if generates much different code than the first variant above,
(it probably will generate similar code to just declaring the object
as volatile, but would still be better in terms of code-clarity and
taste, IMHO), but in any case, we should pick whichever of these variants
works for us and generates good code.

[3]

static inline int atomic_read_volatile(atomic_t *v)
{
	... arch-dependent __asm__ __volatile__ stuff ...
}

I can reasonably bet this variant would often generate worse code than
at least the variant "[1]" above.


Now, why do we even require these "volatility" semantics variants?

Note, "volatility" semantics *know* / assume that it can have a meaning
_only_ as far as the compiler, so atomic_read_volatile() doesn't really
care reading stale values from the cache for certain non-x86 archs, etc.

The first argument is "safety":

Use of atomic_read() (possibly in conjunction with other atomic ops) in
a lot of code out there in the kernel *assumes* the compiler will not
optimize away those ops. (which is possible given current definitions
of atomic_set and atomic_read on archs such as x86 in present code).
An additional argument that builds on this one says that by ensuring
the compiler will not elid or coalesce these ops, we could even avoid
potential heisenbugs in the future.

However, there is a counter-argument:

As Herbert Xu has often been making the point, there is *no* bug out
there involving "atomic_read" in busy-while-loops that should not have
a compiler barrier (or cpu_relax() in fact) anyway. As for non-busy-loops,
they would invariable call schedule() at some point (possibly directly)
and thus have an "implicit" compiler barrier by virtue of calling out
a function that is not in scope of the current compilation unit (although
users in sched.c itself would probably require an explicit compiler
barrier).

The second pro-volatility-in-atomic-ops argument is performance:
(surprise!)

Using a full memory clobber compiler barrier in busy loops will disqualify
optimizations for loop invariants so it probably makes sense to *only*
make the compiler forget *that* particular address of the atomic counter
object, and none other. All 3 variants above would work nicely here.

So the final idea may be to have a cpu_relax_no_barrier() variant as a
rep;nop (pause) *without* an included full memory clobber, and replace
a lot of kernel busy-while-loops out there with:

-	cpu_relax();
+	cpu_relax_no_barrier();
+	forget(x);

or may be just:

-	cpu_relax();
+	cpu_relax_no_barrier();

because the "forget" / "volatility" / specific-variable-compiler-barrier
could be made implicit inside the atomic ops themselves.

This could especially make a difference for register-rich CPUs (probably
not x86) where using a full memory clobber will disqualify a hell lot of
compiler optimizations for loop-invariants.

On x86 itself, cpu_relax_no_barrier() could be:

#define cpu_relax_no_barrier()	__asm__ __volatile__ ("rep;nop":::);

and still continue to do its job as it is doing presently.

However, there is still a counter-argument:

As Herbert Xu and Christoph Lameter have often been saying, giving
"volatility" semantics to the atomic ops will disqualify compiler
optimizations such as eliding / coalescing of atomic ops, etc, and
probably some sections of code in the kernel (Christoph mentioned code
in SLUB, and I saw such code in sched) benefit from such optimizations.

Paul Mackerras has, otoh, mentioned that a lot of such places probably
don't need (or shouldn't use) atomic ops in the first place.
Alternatively, such callsites should probably just cache the atomic_read
in a local variable (which compiler could just as well make a register)
explicitly, and repeating atomic_read() isn't really necessary.

There could still be legitimate uses of atomic ops that don't care about
them being elided / coalesced, but given the loop-invariant-optimization
benefit, personally, I do see some benefit in the use of defining atomic
ops variants with "volatility" semantics (for only the atomic counter
object) but also having a non-volatile atomic ops API side-by-side for
performance critical users (probably sched, slub) that may require that.

Possibly, one of the two APIs above could turn out to be redundant, but
that's still very much the issue of debate presently.


Satyam

[ Sorry if I missed anything important, but this thread has been long
  and noisy, although I've tried to keep up ... ]
