From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Sat, 18 Aug 2007 07:26:30 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0708180556330.3666@enigma.security.iitk.ac.in>
References: <20070816003948.GY9645@linux.vnet.ibm.com>
 <18115.44462.622801.683446@cargo.ozlabs.ibm.com> <20070816020042.GA30650@gondor.apana.org.au>
 <18115.45316.702491.681906@cargo.ozlabs.ibm.com>
 <alpine.LFD.0.999.0708160800130.24380@enigma.security.iitk.ac.in>
 <alpine.LFD.0.999.0708160815510.24380@enigma.security.iitk.ac.in>
 <18115.52863.638655.658466@cargo.ozlabs.ibm.com> <20070816053945.GB32442@gondor.apana.org.au>
 <18115.62741.807704.969977@cargo.ozlabs.ibm.com> <20070816070907.GA964@gondor.apana.org.au>
 <Pine.LNX.4.64.0708161743500.13267@kivilampi-30.cs.helsinki.fi>
 <46C4ABA5.9010804@redhat.com> <Pine.LNX.4.64.0708161319000.17777@schroedinger.engr.sgi.com>
 <c298f0e3f9e49c9dd2d326115d156084@kernel.crashing.org>
 <alpine.LFD.0.999.0708180002290.3666@enigma.security.iitk.ac.in>
 <a51ab88dc00f8d7fd44f79400671d259@kernel.crashing.org>
 <alpine.LFD.0.999.0708180522120.3666@enigma.security.iitk.ac.in>
 <c0115c88da5d6756502e0c0499faa71f@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Christoph Lameter <clameter@sgi.com>,
	Paul Mackerras <paulus@samba.org>, heiko.carstens@de.ibm.com,
	horms@verge.net.au, Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	=?iso-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	ak@suse.de, cfriesen@nortel.com, rpjday@mindspring.com,
	Netdev <netdev@vger.kernel.org>, jesper.juhl@gmail.com,
	linux-arch@vger.kernel.org, zlynx@acm.org,
	Andrew Morton <akpm@linux-foundation.org>,
	schwidefsky@de.ibm.com, Chris Snook <csnook@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	wensong@linux-vs.org, wjiang@resilience.com
To: Segher Boessenkool <segher@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:33840 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751512AbXHRBn6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 21:43:58 -0400
In-Reply-To: <c0115c88da5d6756502e0c0499faa71f@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Sat, 18 Aug 2007, Segher Boessenkool wrote:

> > > > > atomic_dec() writes
> > > > > to memory, so it _does_ have "volatile semantics", implicitly, as
> > > > > long as the compiler cannot optimise the atomic variable away
> > > > > completely -- any store counts as a side effect.
> > > > 
> > > > I don't think an atomic_dec() implemented as an inline "asm volatile"
> > > > or one that uses a "forget" macro would have the same re-ordering
> > > > guarantees as an atomic_dec() that uses a volatile access cast.
> > > 
> > > The "asm volatile" implementation does have exactly the same
> > > reordering guarantees as the "volatile cast" thing,
> > 
> > I don't think so.
> 
> "asm volatile" creates a side effect.

Yeah.

> Side effects aren't
> allowed to be reordered wrt sequence points.

Yeah.

> This is exactly
> the same reason as why "volatile accesses" cannot be reordered.

No, the code in that sub-thread I earlier pointed you at *WAS* written
such that there was a sequence point after all the uses of that volatile
access cast macro, and _therefore_ we were safe from re-ordering
(behaviour guaranteed by the C standard).

But you seem to be missing the simple and basic fact that:

	(something_that_has_side_effects || statement)
			!= something_that_is_a_sequence_point

Now, one cannot fantasize that "volatile asms" are also sequence points.
In fact such an argument would be sadly mistaken, because "sequence
points" are defined by the C standard and it'd be horribly wrong to
even _try_ claiming that the C standard knows about "volatile asms".


> > > if that is
> > > implemented by GCC in the "obvious" way.  Even a "plain" asm()
> > > will do the same.
> > 
> > Read the relevant GCC documentation.
> 
> I did, yes.

No, you didn't read:

http://gcc.gnu.org/onlinedocs/gcc/Extended-Asm.html

Read the bit about the need for artificial dependencies, and the example
given there:

	asm volatile("mtfsf 255,%0" : : "f" (fpenv));
	sum = x + y;

The docs explicitly say the addition can be moved before the "volatile
asm". Hopefully, as you know, (x + y) is an C "expression" and hence
a "sequence point" as defined by the standard. So the "volatile asm"
should've happened before it, right? Wrong.

I know there is also stuff written about "side-effects" there which
_could_ give the same semantic w.r.t. sequence points as the volatile
access casts, but hey, it's GCC's own documentation, you obviously can't
find fault with _me_ if there's wrong stuff written in there. Say that
to GCC ...

See, "volatile" C keyword, for all it's ill-definition and dodgy
semantics, is still at least given somewhat of a treatment in the C
standard (whose quality is ... ummm, sadly not always good and clear,
but unsurprisingly, still about 5,482 orders-of-magnitude times
better than GCC docs). Semantics of "volatile" as applies to inline
asm, OTOH? You're completely relying on the compiler for that ...


> > [ of course, if the (latest) GCC documentation is *yet again*
> >   wrong, then alright, not much I can do about it, is there. ]
> 
> There was (and is) nothing wrong about the "+m" documentation, if
> that is what you are talking about.  It could be extended now, to
> allow "+m" -- but that takes more than just "fixing" the documentation.

No, there was (and is) _everything_ wrong about the "+" documentation as
applies to memory-constrained operands. I don't give a whit if it's
some workaround in their gimplifier, or the other, that makes it possible
to use "+m" (like the current kernel code does). The docs suggest
otherwise, so there's obviously a clear disconnect between the docs and
actual GCC behaviour.


[ You seem to often take issue with _amazingly_ petty and pedantic things,
  by the way :-) ]
