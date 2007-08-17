From: Nick Piggin <piggin@cyberone.com.au>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Fri, 17 Aug 2007 19:15:17 +1000
Message-ID: <46C56725.6000207@cyberone.com.au>
References: <E1ILCgh-00052A-00@gondolin.me.apana.org.au> <46C32618.2080108@redhat.com> <20070815234021.GA28775@gondor.apana.org.au> <3694fb2e4ed1e4d9bf873c0d050c911e@kernel.crashing.org> <46C3B50E.7010702@yahoo.com.au> <194369f4c96ea0e24decf8f9197d5bad@kernel.crashing.org> <46C505B2.6030704@yahoo.com.au> <18117.4848.695269.72976@cargo.ozlabs.ibm.com> <alpine.LFD.0.999.0708162033400.30176@woody.linux-foundation.org> <alpine.LFD.0.999.0708171016160.3666@enigma.security.iitk.ac.in> <46C54D94.5080803@yahoo.com.au> <alpine.LFD.0.999.0708171358520.3666@enigma.security.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
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
To: Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.icp-qv1-irony3.iinet.net.au ([203.59.1.108]:9800 "EHLO
	webmail.icp-qv1-irony3.iinet.net.au" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758326AbXHQJ0F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 05:26:05 -0400
In-Reply-To: <alpine.LFD.0.999.0708171358520.3666@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Satyam Sharma wrote:
> 
> On Fri, 17 Aug 2007, Nick Piggin wrote:

>>Also, why would you want to make these insane accessors for atomic_t
>>types? Just make sure everybody knows the basics of barriers, and they
>>can apply that knowledge to atomic_t and all other lockless memory
>>accesses as well.
> 
> 
> Code that looks like:
> 
> 	while (!atomic_read(&v)) {
> 		...
> 		cpu_relax_no_barrier();
> 		forget(v.counter);
> 		        ^^^^^^^^
> 	}
> 
> would be uglier. Also think about code such as:

I think they would both be equally ugly, but the atomic_read_volatile
variant would be more prone to subtle bugs because of the weird
implementation.

And it would be more ugly than introducing an order(x) statement for
all memory operations, and adding an order_atomic() wrapper for it
for atomic types.


> 	a = atomic_read();
> 	if (!a)
> 		do_something();
> 
> 	forget();
> 	a = atomic_read();
> 	... /* some code that depends on value of a, obviously */
> 
> 	forget();
> 	a = atomic_read();
> 	...
> 
> So much explicit sprinkling of "forget()" looks ugly.

Firstly, why is it ugly? It's nice because of those nice explicit
statements there that give us a good heads up and would have some
comments attached to them (also, lack of the word "volatile" is
always a plus).

Secondly, what sort of code would do such a thing? In most cases,
it is probably riddled with bugs anyway (unless it is doing a
really specific sequence of interrupts or something, but in that
case it is very likely to either require locking or busy waits
anyway -> ie. barriers).


> on the other hand, looks neater. The "_volatile()" suffix makes it also
> no less explicit than an explicit barrier-like macro that this primitive
> is something "special", for code clarity purposes.

Just don't use the word volatile, and have barriers both before
and after the memory operation, and I'm OK with it. I don't see
the point though, when you could just have a single barrier(x)
barrier function defined for all memory locations, rather than
this odd thing that only works for atomics (and would have to
be duplicated for atomic_set.
