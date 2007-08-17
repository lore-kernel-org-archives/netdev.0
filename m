From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Fri, 17 Aug 2007 13:58:14 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0708171331590.3666@enigma.security.iitk.ac.in>
References: <18115.45316.702491.681906@cargo.ozlabs.ibm.com>
 <alpine.LFD.0.999.0708160800130.24380@enigma.security.iitk.ac.in>
 <alpine.LFD.0.999.0708160815510.24380@enigma.security.iitk.ac.in>
 <18115.52863.638655.658466@cargo.ozlabs.ibm.com> <20070816053945.GB32442@gondor.apana.org.au>
 <18115.62741.807704.969977@cargo.ozlabs.ibm.com> <20070816070907.GA964@gondor.apana.org.au>
 <46C40587.7050708@s5r6.in-berlin.de> <20070816081049.GA1431@gondor.apana.org.au>
 <18117.11685.431347.996767@cargo.ozlabs.ibm.com> <20070817053200.GA15457@gondor.apana.org.au>
 <18117.13576.93583.222760@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Christoph Lameter <clameter@sgi.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
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
To: Paul Mackerras <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:34535 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752282AbXHQIQQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 04:16:16 -0400
In-Reply-To: <18117.13576.93583.222760@cargo.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 17 Aug 2007, Paul Mackerras wrote:

> Herbert Xu writes:
> 
> > On Fri, Aug 17, 2007 at 03:09:57PM +1000, Paul Mackerras wrote:
> > > Herbert Xu writes:
> > > 
> > > > Can you find an actual atomic_read code snippet there that is
> > > > broken without the volatile modifier?
> > > 
> > > There are some in arch-specific code, for example line 1073 of
> > > arch/mips/kernel/smtc.c.  On mips, cpu_relax() is just barrier(), so
> > > the empty loop body is ok provided that atomic_read actually does the
> > > load each time around the loop.
> > 
> > A barrier() is all you need to force the compiler to reread
> > the value.
> > 
> > The people advocating volatile in this thread are talking
> > about code that doesn't use barrier()/cpu_relax().
> 
> Did you look at it?  Here it is:
> 
> 	/* Someone else is initializing in parallel - let 'em finish */
> 	while (atomic_read(&idle_hook_initialized) < 1000)
> 		;


Honestly, this thread is suffering from HUGE communication gaps.

What Herbert (obviously) meant there was that "this loop could've
been okay _without_ using volatile-semantics-atomic_read() also, if
only it used cpu_relax()".

That does work, because cpu_relax() is _at least_ barrier() on all
archs (on some it also emits some arch-dependent "pause" kind of
instruction).

Now, saying that "MIPS does not have such an instruction so I won't
use cpu_relax() for arch-dependent-busy-while-loops in arch/mips/"
sounds like a wrong argument, because: tomorrow, such arch's _may_
introduce such an instruction, so naturally, at that time we'd
change cpu_relax() appropriately (in reality, we would actually
*re-define* cpu_relax() and ensure that the correct version gets
pulled in depending on whether the callsite code is legacy or only
for the newer such CPUs of said arch, whatever), but loops such as
this would remain un-changed, because they never used cpu_relax()!

OTOH an argument that said the following would've made a stronger case:

"I don't want to use cpu_relax() because that's a full memory
clobber barrier() and I have loop-invariants / other variables
around in that code that I *don't* want the compiler to forget
just because it used cpu_relax(), and hence I will not use
cpu_relax() but instead make my atomic_read() itself have
"volatility" semantics. Not just that, but I will introduce a
cpu_relax_no_barrier() on MIPS, that would be a no-op #define
for now, but which may not be so forever, and continue to use
that in such busy loops."

In general, please read the thread-summary I've tried to do at:
http://lkml.org/lkml/2007/8/17/25
Feel free to continue / comment / correct stuff from there, there's
too much confusion and circular-arguments happening on this thread
otherwise.

[ I might've made an incorrect statement there about
  "volatile" w.r.t. cache on non-x86 archs, I think. ]


Satyam
