From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Thu, 16 Aug 2007 10:06:31 +0200
Message-ID: <46C40587.7050708@s5r6.in-berlin.de>
References: <20070816003948.GY9645@linux.vnet.ibm.com> <Pine.LNX.4.64.0708151740570.10497@schroedinger.engr.sgi.com> <18115.44462.622801.683446@cargo.ozlabs.ibm.com> <20070816020042.GA30650@gondor.apana.org.au> <18115.45316.702491.681906@cargo.ozlabs.ibm.com> <alpine.LFD.0.999.0708160800130.24380@enigma.security.iitk.ac.in> <alpine.LFD.0.999.0708160815510.24380@enigma.security.iitk.ac.in> <18115.52863.638655.658466@cargo.ozlabs.ibm.com> <20070816053945.GB32442@gondor.apana.org.au> <18115.62741.807704.969977@cargo.ozlabs.ibm.com> <20070816070907.GA964@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Paul Mackerras <paulus@samba.org>,
	Satyam Sharma <satyam@infradead.org>,
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
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hp3.statik.tu-cottbus.de ([141.43.120.68]:40942 "EHLO
	hp3.statik.tu-cottbus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752082AbXHPIGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2007 04:06:34 -0400
In-Reply-To: <20070816070907.GA964@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Thu, Aug 16, 2007 at 04:56:21PM +1000, Paul Mackerras wrote:
>>
>> Note that I said these are the cases _where one might want to allow
>> caching_, so of course adding volatile doesn't help _these_ cases.
>> There are of course other cases where one definitely doesn't want to
>> allow the compiler to cache the value, such as when polling an atomic
>> variable waiting for another CPU to change it, and from my inspection
>> so far these cases seem to be the majority.
> 
> We've been through that already.  If it's a busy-wait it
> should use cpu_relax.  If it's scheduling away that already
> forces the compiler to reread anyway.
> 
> Do you have an actual example where volatile is needed?
> 
>> - It matches the normal expectation based on the name "atomic_read"
>> - It matches the behaviour of the other atomic_* primitives
> 
> Can't argue since you left out what those expectations
> or properties are.

We use atomic_t for data that is concurrently locklessly written and
read at arbitrary times.  My naive expectation as driver author (driver
maintainer) is that all atomic_t accessors, including atomic_read, (and
atomic bitops) work with the then current value of the atomic data.

>> - It avoids bugs in the cases where "volatile" behaviour is required
> 
> Do you (or anyone else for that matter) have an example of this?

The only code I somewhat know, the ieee1394 subsystem, was perhaps
authored and is currently maintained with the expectation that each
occurrence of atomic_read actually results in a load operation, i.e. is
not optimized away.  This means all atomic_t (bus generation, packet and
buffer refcounts, and some other state variables)* and likewise all
atomic bitops in that subsystem.

If that assumption is wrong, then what is the API or language primitive
to force a load operation to occur?


*)  Interesting what a quick LXR session in search for all atomic_t
usages in 'my' subsystem brings to light.  I now noticed an apparently
unused struct member in the bitrotting pcilynx driver, and more
importantly, a pairing of two atomic_t variables in raw1394 that should
be audited for race conditions and for possible replacement by plain int.
-- 
Stefan Richter
-=====-=-=== =--- =----
http://arcgraph.de/sr/
