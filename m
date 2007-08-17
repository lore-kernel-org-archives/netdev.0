From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Fri, 17 Aug 2007 19:06:20 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0708171836320.3666@enigma.security.iitk.ac.in>
References: <18115.52863.638655.658466@cargo.ozlabs.ibm.com>
 <20070816053945.GB32442@gondor.apana.org.au> <18115.62741.807704.969977@cargo.ozlabs.ibm.com>
 <20070816070907.GA964@gondor.apana.org.au>
 <Pine.LNX.4.64.0708161743500.13267@kivilampi-30.cs.helsinki.fi>
 <46C4ABA5.9010804@redhat.com> <Pine.LNX.4.64.0708161319000.17777@schroedinger.engr.sgi.com>
 <18117.1287.779351.836552@cargo.ozlabs.ibm.com>
 <alpine.LFD.0.999.0708161953310.30176@woody.linux-foundation.org>
 <18117.6495.397597.582736@cargo.ozlabs.ibm.com> <20070817035342.GA14744@gondor.apana.org.au>
 <alpine.LFD.0.999.0708171142550.3666@enigma.security.iitk.ac.in>
 <46C55E90.7010407@yahoo.com.au> <alpine.LFD.0.999.0708171431150.3666@enigma.security.iitk.ac.in>
 <46C56ADF.8010501@cyberone.com.au> <alpine.LFD.0.999.0708171612440.3666@enigma.security.iitk.ac.in>
 <46C59717.4020108@cyberone.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Paul Mackerras <paulus@samba.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Christoph Lameter <clameter@sgi.com>,
	Chris Snook <csnook@redhat.com>,
	Ilpo Jarvinen <ilpo.jarvinen@helsinki.fi>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org, Netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>, ak@suse.de,
	heiko.carstens@de.ibm.com, David Miller <davem@davemloft.net>,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org
To: Nick Piggin <piggin@cyberone.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:48315 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755404AbXHQNY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 09:24:27 -0400
In-Reply-To: <46C59717.4020108@cyberone.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 17 Aug 2007, Nick Piggin wrote:

> Satyam Sharma wrote:
> 
> > On Fri, 17 Aug 2007, Nick Piggin wrote:
> > 
> > > Because they should be thinking about them in terms of barriers, over
> > > which the compiler / CPU is not to reorder accesses or cache memory
> > > operations, rather than "special" "volatile" accesses.
> > 
> > This is obviously just a taste thing. Whether to have that forget(x)
> > barrier as something author should explicitly sprinkle appropriately
> > in appropriate places in the code by himself or use a primitive that
> > includes it itself.
> 
> That's not obviously just taste to me. Not when the primitive has many
> (perhaps, the majority) of uses that do not require said barriers. And
> this is not solely about the code generation (which, as Paul says, is
> relatively minor even on x86).

See, you do *require* people to have to repeat the same things to you!

As has been written about enough times already, and if you followed the
discussion on this thread, I am *not* proposing that atomic_read()'s
semantics be changed to have any extra barriers. What is proposed is a
different atomic_read_xxx() variant thereof, that those can use who do
want that.

Now whether to have a kind of barrier ("volatile", whatever) in the
atomic_read_xxx() itself, or whether to make the code writer himself to
explicitly write the order(x) appropriately in appropriate places in the
code _is_ a matter of taste.


> > That's definitely the point, why not. This is why "barrier()", being
> > heavy-handed, is not the best option.
> 
> That is _not_ the point [...]

Again, you're requiring me to repeat things that were already made evident
on this thread (if you follow it).

This _is_ the point, because a lot of loops out there (too many of them,
I WILL NOT bother citing file_name:line_number) end up having to use a
barrier just because they're using a loop-exit-condition that depends
on a value returned by atomic_read(). It would be good for them if they
used an atomic_read_xxx() primitive that gave these "volatility" semantics
without junking compiler optimizations for other memory references.

> because there has already been an alternative posted

Whether that alternative (explicitly using forget(x), or wrappers thereof,
such as the "order_atomic" you proposed) is better than other alternatives
(such as atomic_read_xxx() which includes the volatility behaviour in
itself) is still open, and precisely what we started discussing just one
mail back.

(The above was also mostly stuff I had to repeated for you, sadly.)

> that better conforms with Linux barrier
> API and is much more widely useful and more usable.

I don't think so.

(Now *this* _is_ the "taste-dependent matter" that I mentioned earlier.)

> If you are so worried
> about
> barrier() being too heavyweight, then you're off to a poor start by wanting to
> add a few K of kernel text by making atomic_read volatile.

Repeating myself, for the N'th time, NO, I DON'T want to make atomic_read
have "volatile" semantics.

> > > because as I also mentioned, the logical extention
> > > to Linux's barrier API to handle this is the order(x) macro. Again, not
> > > special volatile accessors.
> > 
> > Sure, that forget(x) macro _is_ proposed to be made part of the generic
> > API. Doesn't explain why not to define/use primitives that has volatility
         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> > semantics in itself, though (taste matters apart).
    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> If you follow the discussion.... You were thinking of a reason why the
> semantics *should* be changed or added, and I was rebutting your argument
> that it must be used when a full barrier() is too heavy (ie. by pointing
> out that order() has superior semantics anyway).

Amazing. Either you have reading comprehension problems, or else, please
try reading this thread (or at least this sub-thread) again. I don't want
_you_ blaming _me_ for having to repeat things to you all over again.
