From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Thu, 16 Aug 2007 16:56:21 +1000
Message-ID: <18115.62741.807704.969977@cargo.ozlabs.ibm.com>
References: <18115.35524.56393.347841@cargo.ozlabs.ibm.com>
	<Pine.LNX.4.64.0708151725130.10497@schroedinger.engr.sgi.com>
	<20070816003948.GY9645@linux.vnet.ibm.com>
	<Pine.LNX.4.64.0708151740570.10497@schroedinger.engr.sgi.com>
	<18115.44462.622801.683446@cargo.ozlabs.ibm.com>
	<20070816020042.GA30650@gondor.apana.org.au>
	<18115.45316.702491.681906@cargo.ozlabs.ibm.com>
	<alpine.LFD.0.999.0708160800130.24380@enigma.security.iitk.ac.in>
	<alpine.LFD.0.999.0708160815510.24380@enigma.security.iitk.ac.in>
	<18115.52863.638655.658466@cargo.ozlabs.ibm.com>
	<20070816053945.GB32442@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Satyam Sharma <satyam@infradead.org>,
	Christoph Lameter <clameter@sgi.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
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
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760824AbXHPG4m@vger.kernel.org>
In-Reply-To: <20070816053945.GB32442@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu writes:

> On Thu, Aug 16, 2007 at 02:11:43PM +1000, Paul Mackerras wrote:
> >
> > The uses of atomic_read where one might want it to allow caching of
> > the result seem to me to fall into 3 categories:
> > 
> > 1. Places that are buggy because of a race arising from the way it's
> >    used.
> > 
> > 2. Places where there is a race but it doesn't matter because we're
> >    doing some clever trick.
> > 
> > 3. Places where there is some locking in place that eliminates any
> >    potential race.
> 
> Agreed.
> 
> > In case 1, adding volatile won't solve the race, of course, but it's
> > hard to argue that we shouldn't do something because it will slow down
> > buggy code.  Case 2 is hopefully pretty rare and accompanied by large
> > comment blocks, and in those cases caching the result of atomic_read
> > explicitly in a local variable would probably make the code clearer.
> > And in case 3 there is no reason to use atomic_t at all; we might as
> > well just use an int.
> 
> Since adding volatile doesn't help any of the 3 cases, and
> takes away optimisations from both 2 and 3, I wonder what
> is the point of the addition after all?

Note that I said these are the cases _where one might want to allow
caching_, so of course adding volatile doesn't help _these_ cases.
There are of course other cases where one definitely doesn't want to
allow the compiler to cache the value, such as when polling an atomic
variable waiting for another CPU to change it, and from my inspection
so far these cases seem to be the majority.

The reasons for having "volatile" behaviour of atomic_read (whether or
not that is achieved by use of the "volatile" C keyword) are

- It matches the normal expectation based on the name "atomic_read"
- It matches the behaviour of the other atomic_* primitives
- It avoids bugs in the cases where "volatile" behaviour is required

To my mind these outweigh the small benefit for some code of the
non-volatile (caching-allowed) behaviour.  In fact it's pretty minor
either way, and since x86[-64] has this behaviour, one can expect the
potential bugs in generic code to have mostly been found, although
perhaps not all of them since x86[-64] has less aggressive reordering
of memory accesses and fewer registers in which to cache things than
some other architectures.

Paul.
