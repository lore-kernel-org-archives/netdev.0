From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Fri, 17 Aug 2007 15:42:26 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0708171505200.3666@enigma.security.iitk.ac.in>
References: <E1ILCgh-00052A-00@gondolin.me.apana.org.au> <46C32618.2080108@redhat.com>
 <20070815234021.GA28775@gondor.apana.org.au> <3694fb2e4ed1e4d9bf873c0d050c911e@kernel.crashing.org>
 <46C3B50E.7010702@yahoo.com.au> <194369f4c96ea0e24decf8f9197d5bad@kernel.crashing.org>
 <46C505B2.6030704@yahoo.com.au> <18117.4848.695269.72976@cargo.ozlabs.ibm.com>
 <alpine.LFD.0.999.0708162033400.30176@woody.linux-foundation.org>
 <alpine.LFD.0.999.0708171016160.3666@enigma.security.iitk.ac.in>
 <46C54D94.5080803@yahoo.com.au> <alpine.LFD.0.999.0708171358520.3666@enigma.security.iitk.ac.in>
 <46C56725.6000207@cyberone.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Mackerras <paulus@samba.org>,
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
To: Nick Piggin <piggin@cyberone.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:52307 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756174AbXHQJ7w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 05:59:52 -0400
In-Reply-To: <46C56725.6000207@cyberone.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 17 Aug 2007, Nick Piggin wrote:

> Satyam Sharma wrote:
> > 
> > On Fri, 17 Aug 2007, Nick Piggin wrote:
> 
> > > Also, why would you want to make these insane accessors for atomic_t
> > > types? Just make sure everybody knows the basics of barriers, and they
> > > can apply that knowledge to atomic_t and all other lockless memory
> > > accesses as well.
> > 
> > 
> > Code that looks like:
> > 
> > 	while (!atomic_read(&v)) {
> > 		...
> > 		cpu_relax_no_barrier();
> > 		forget(v.counter);
> > 		        ^^^^^^^^
> > 	}
> > 
> > would be uglier. Also think about code such as:
> 
> I think they would both be equally ugly,

You think both these are equivalent in terms of "looks":

					|
while (!atomic_read(&v)) {		|	while (!atomic_read_xxx(&v)) {
	...				|		...
	cpu_relax_no_barrier();		|		cpu_relax_no_barrier();
	order_atomic(&v);		|	}
}					|

(where order_atomic() is an atomic_t
specific wrapper as you mentioned below)

?

Well, taste varies, but ...

> but the atomic_read_volatile
> variant would be more prone to subtle bugs because of the weird
> implementation.

What bugs?

> And it would be more ugly than introducing an order(x) statement for
> all memory operations, and adding an order_atomic() wrapper for it
> for atomic types.

Oh, that order() / forget() macro [forget() was named such by Chuck Ebbert
earlier in this thread where he first mentioned it, btw] could definitely
be generically introduced for any memory operations.

> > 	a = atomic_read();
> > 	if (!a)
> > 		do_something();
> > 
> > 	forget();
> > 	a = atomic_read();
> > 	... /* some code that depends on value of a, obviously */
> > 
> > 	forget();
> > 	a = atomic_read();
> > 	...
> > 
> > So much explicit sprinkling of "forget()" looks ugly.
> 
> Firstly, why is it ugly? It's nice because of those nice explicit
> statements there that give us a good heads up and would have some
> comments attached to them

atomic_read_xxx (where xxx = whatever naming sounds nice to you) would
obviously also give a heads up, and could also have some comments
attached to it.

> (also, lack of the word "volatile" is always a plus).

Ok, xxx != volatile.

> Secondly, what sort of code would do such a thing?

See the nodemgr_host_thread() that does something similar, though not
exactly same.

> > on the other hand, looks neater. The "_volatile()" suffix makes it also
> > no less explicit than an explicit barrier-like macro that this primitive
> > is something "special", for code clarity purposes.
> 
> Just don't use the word volatile,

That sounds amazingly frivolous, but hey, why not. As I said, ok,
xxx != volatile.

> and have barriers both before and after the memory operation,

How could that lead to bugs? (if you can point to existing code,
but just some testcase / sample code would be fine as well).

> [...] I don't see
> the point though, when you could just have a single barrier(x)
> barrier function defined for all memory locations,

As I said, barrier() is too heavy-handed.

> rather than
> this odd thing that only works for atomics

Why would it work only for atomics? You could use that generic macro
for anything you well damn please.

> (and would have to
> be duplicated for atomic_set.

#define atomic_set_xxx for something similar. Big deal ... NOT.
