From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Tue, 21 Aug 2007 22:01:03 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0708212006340.2774@enigma.security.iitk.ac.in>
References: <alpine.LFD.0.999.0708170929580.30176@woody.linux-foundation.org>
 <46C993DF.4080400@redhat.com> <alpine.LFD.0.999.0708202244520.30176@woody.linux-foundation.org>
 <20070821.000404.39159401.davem@davemloft.net>
 <46CAED8B.9030006@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	piggin@cyberone.com.au, herbert@gondor.apana.org.au,
	paulus@samba.org, clameter@sgi.com, ilpo.jarvinen@helsinki.fi,
	paulmck@linux.vnet.ibm.com, stefanr@s5r6.in-berlin.de,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>, ak@suse.de,
	heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com,
	wensong@linux-vs.org, horms@verge.net.au, wjiang@resilience.com,
	cfriesen@nortel.com, zlynx@acm.org, rpjday@mindspring.com,
	jesper.juhl@gmail.com, segher@kernel.crashing.org
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:46694 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751701AbXHUQX7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2007 12:23:59 -0400
In-Reply-To: <46CAED8B.9030006@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Tue, 21 Aug 2007, Chris Snook wrote:

> David Miller wrote:
> > From: Linus Torvalds <torvalds@linux-foundation.org>
> > Date: Mon, 20 Aug 2007 22:46:47 -0700 (PDT)
> > 
> > > Ie a "barrier()" is likely _cheaper_ than the code generation downside
> > > from using "volatile".
> > 
> > Assuming GCC were ever better about the code generation badness
> > with volatile that has been discussed here, I much prefer
> > we tell GCC "this memory piece changed" rather than "every
> > piece of memory has changed" which is what the barrier() does.
> > 
> > I happened to have been scanning a lot of assembler lately to
> > track down a gcc-4.2 miscompilation on sparc64, and the barriers
> > do hurt quite a bit in some places.  Instead of keeping unrelated
> > variables around cached in local registers, it reloads everything.
> 
> Moore's law is definitely working against us here.  Register counts, pipeline
> depths, core counts, and clock multipliers are all increasing in the long run.
> At some point in the future, barrier() will be universally regarded as a
> hammer too big for most purposes.

I do agree, and the important point to note is that the benefits of a
/lighter/ compiler barrier, such as what David referred to above, _can_
be had without having to do anything with the "volatile" keyword at all.
And such a primitive has already been mentioned/proposed on this thread.


But this is all tangential to the core question at hand -- whether to have
implicit (compiler, possibly "light-weight" of the kind referred above)
barrier semantics in atomic ops that do not have them, or not.

I was lately looking in the kernel for _actual_ code that uses atomic_t
and benefits from the lack of any implicit barrier, with the compiler
being free to cache the atomic_t in a register. Now that often does _not_
happen, because all other ops (implemented in asm with LOCK prefix on x86)
_must_ therefore constrain the atomic_t to memory anyway. So typically all
atomic ops code sequences end up operating on memory.

Then I did locate sched.c:select_nohz_load_balancer() -- it repeatedly
references the same atomic_t object, and the code that I saw generated
(with CC_OPTIMIZE_FOR_SIZE=y) did cache it in a register for a sequence of
instructions. It uses atomic_cmpxchg, thereby not requiring explicit
memory barriers anywhere in the code, and is an example of an atomic_t
user that is safe, and yet benefits from its memory loads/stores being
elided/coalesced by the compiler.


# at this point, %%eax holds num_online_cpus() and
# %%ebx holds cpus_weight(nohz.cpu_mask)
# the variable "cpu" is in %esi

0xc1018e1d:      cmp    %eax,%ebx		# if No.A.
0xc1018e1f:      mov    0xc134d900,%eax		# first atomic_read()
0xc1018e24:      jne    0xc1018e36
0xc1018e26:      cmp    %esi,%eax		# if No.B.
0xc1018e28:      jne    0xc1018e80		# returns with 0
0xc1018e2a:      movl   $0xffffffff,0xc134d900	# atomic_set(-1), and ...
0xc1018e34:      jmp    0xc1018e80		# ... returns with 0
0xc1018e36:      cmp    $0xffffffff,%eax	# if No.C. (NOTE!)
0xc1018e39:      jne    0xc1018e46
0xc1018e3b:      lock cmpxchg %esi,0xc134d900	# atomic_cmpxchg()
0xc1018e43:      inc    %eax
0xc1018e44:      jmp    0xc1018e48
0xc1018e46:      cmp    %esi,%eax		# if No.D. (NOTE!)
0xc1018e48:      jne    0xc1018e80		# if !=, default return 0 (if No.E.)
0xc1018e4a:      jmp    0xc1018e84		# otherwise (==) returns with 1

The above is:

	if (cpus_weight(nohz.cpu_mask) == num_online_cpus()) {	/* if No.A. */
		if (atomic_read(&nohz.load_balancer) == cpu)	/* if No.B. */
			atomic_set(&nohz.load_balancer, -1);	/* XXX */
		return 0;
	}
	if (atomic_read(&nohz.load_balancer) == -1) {		/* if No.C. */
		/* make me the ilb owner */
		if (atomic_cmpxchg(&nohz.load_balancer, -1, cpu) == -1)	/* if No.E. */
			return 1;
	} else if (atomic_read(&nohz.load_balancer) == cpu)	/* if No.D. */
		return 1;
	...
	...
	return 0; /* default return from function */

As you can see, the atomic_read()'s of "if"s Nos. B, C, and D, were _all_
coalesced into a single memory reference "mov    0xc134d900,%eax" at the
top of the function, and then "if"s Nos. C and D simply used the value
from %%eax itself. But that's perfectly safe, such is the logic of this
function. It uses cmpxchg _whenever_ updating the value in the memory
atomic_t and then returns appropriately. The _only_ point that a casual
reader may find racy is that marked /* XXX */ above -- atomic_read()
followed by atomic_set() with no barrier in between. But even that is ok,
because if one thread ever finds that condition to succeed, it is 100%
guaranteed no other thread on any other CPU will find _any_ condition
to be true, thereby avoiding any race in the modification of that value.


BTW it does sound reasonable that a lot of atomic_t users that want a
compiler barrier probably also want a memory barrier. Do we make _that_
implicit too? Quite clearly, making _either_ one of those implicit in
atomic_{read,set} (in any form of implementation -- a forget() macro
based, *(volatile int *)& based, or inline asm based) would end up
harming code such as that cited above.

Lastly, the most obvious reason that should be considered against implicit
barriers in atomic ops is that it isn't "required" -- atomicity does not
imply any barrier after all, and making such a distinction would actually
be a healthy separation that helps people think more clearly when writing
lockless code.

[ But the "authors' expectations" / heisenbugs argument also holds some
  water ... for that, we can have a _variant_ in the API for atomic ops
  that has implicit compiler/memory barriers, to make it easier on those
  who want that behaviour. But let us not penalize code that knows what
  it is doing by changing the default to that, please. ]


Satyam
