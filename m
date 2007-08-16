From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Thu, 16 Aug 2007 09:34:41 -0700
Message-ID: <20070816163441.GB16957@linux.vnet.ibm.com>
References: <alpine.LFD.0.999.0708160815510.24380@enigma.security.iitk.ac.in> <18115.52863.638655.658466@cargo.ozlabs.ibm.com> <20070816053945.GB32442@gondor.apana.org.au> <18115.62741.807704.969977@cargo.ozlabs.ibm.com> <20070816070907.GA964@gondor.apana.org.au> <46C40587.7050708@s5r6.in-berlin.de> <20070816081049.GA1431@gondor.apana.org.au> <46C41EE4.9090806@s5r6.in-berlin.de> <46C42767.4070104@s5r6.in-berlin.de> <20070816104250.GB2927@gondor.apana.org.au>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Paul Mackerras <paulus@samba.org>,
	Satyam Sharma <satyam@infradead.org>,
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
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:44431 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760136AbXHPQer (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Aug 2007 12:34:47 -0400
Content-Disposition: inline
In-Reply-To: <20070816104250.GB2927@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 16, 2007 at 06:42:50PM +0800, Herbert Xu wrote:
> On Thu, Aug 16, 2007 at 12:31:03PM +0200, Stefan Richter wrote:
> > 
> > PS:  Just to clarify, I'm not speaking for the volatile modifier.  I'm
> > not speaking for any particular implementation of atomic_t and its
> > accessors at all.  All I am saying is that
> >   - we use atomically accessed data types because we concurrently but
> >     locklessly access this data,
> >   - hence a read access to this data that could be optimized away
> >     makes *no sense at all*.
> 
> No sane compiler can optimise away an atomic_read per se.
> That's only possible if there's a preceding atomic_set or
> atomic_read, with no barriers in the middle.
> 
> If that's the case, then one has to conclude that doing
> away with the second read is acceptable, as otherwise
> a memory (or at least a compiler) barrier should have been
> used.

The compiler can also reorder non-volatile accesses.  For an example
patch that cares about this, please see:

	http://lkml.org/lkml/2007/8/7/280

This patch uses an ORDERED_WRT_IRQ() in rcu_read_lock() and
rcu_read_unlock() to ensure that accesses aren't reordered with respect
to interrupt handlers and NMIs/SMIs running on that same CPU.

> In fact, volatile doesn't guarantee that the memory gets
> read anyway.  You might be reading some stale value out
> of the cache.  Granted this doesn't happen on x86 but
> when you're coding for the kernel you can't make such
> assumptions.
> 
> So the point here is that if you don't mind getting a stale
> value from the CPU cache when doing an atomic_read, then
> surely you won't mind getting a stale value from the compiler
> "cache".

Absolutely disagree.  An interrupt/NMI/SMI handler running on the CPU
will see the same value (whether in cache or in store buffer) that
the mainline code will see.  In this case, we don't care about CPU
misordering, only about compiler misordering.  It is easy to see
other uses that combine communication with handlers on the current
CPU with communication among CPUs -- again, see prior messages in
this thread.

> > So, the architecture guys can implement atomic_read however they want
> > --- as long as it cannot be optimized away.*
> 
> They can implement it however they want as long as it stays
> atomic.

Precisely.  And volatility is a key property of "atomic".  Let's please
not throw it away.

						Thanx, Paul
