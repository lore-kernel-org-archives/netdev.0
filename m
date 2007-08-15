From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Wed, 15 Aug 2007 07:25:16 -0700
Message-ID: <20070815142516.GB9645@linux.vnet.ibm.com>
References: <20070809131423.GA9927@shell.boston.redhat.com> <Pine.LNX.4.64.0708141529310.32693@schroedinger.engr.sgi.com> <alpine.LFD.0.999.0708150417240.6482@enigma.security.iitk.ac.in> <46C2D6F3.3070707@s5r6.in-berlin.de> <alpine.LFD.0.999.0708151713080.16414@enigma.security.iitk.ac.in> <46C2FADB.7020407@s5r6.in-berlin.de> <alpine.LFD.0.999.0708151906330.16414@enigma.security.iitk.ac.in>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stefan Richter <stefanr@s5r6.in-berlin.de>,
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
	segher@kernel.crashing.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:51438 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757874AbXHOOZU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 10:25:20 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.999.0708151906330.16414@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 15, 2007 at 07:17:29PM +0530, Satyam Sharma wrote:
> On Wed, 15 Aug 2007, Stefan Richter wrote:
> > Satyam Sharma wrote:
> > > On Wed, 15 Aug 2007, Stefan Richter wrote:
> > >> Doesn't "atomic WRT all processors" require volatility?
> > > 
> > > No, it definitely doesn't. Why should it?
> > > 
> > > "Atomic w.r.t. all processors" is just your normal, simple "atomicity"
> > > for SMP systems (ensure that that object is modified / set / replaced
> > > in main memory atomically) and has nothing to do with "volatile"
> > > behaviour.
> > > 
> > > "Volatile behaviour" itself isn't consistently defined (at least
> > > definitely not consistently implemented in various gcc versions across
> > > platforms), but it is /expected/ to mean something like: "ensure that
> > > every such access actually goes all the way to memory, and is not
> > > re-ordered w.r.t. to other accesses, as far as the compiler can take
> > > care of these". The last "as far as compiler can take care" disclaimer
> > > comes about due to CPUs doing their own re-ordering nowadays.
> > > 
> > > For example (say on i386):
> > 
> > [...]
> > 
> > > In (A) the compiler optimized "a = 10;" away, but the actual store
> > > of the final value "20" to "a" was still "atomic". (B) and (C) also
> > > exhibit "volatile" behaviour apart from the "atomicity".
> > > 
> > > But as others replied, it seems some callers out there depend upon
> > > atomic ops exhibiting "volatile" behaviour as well, so that answers
> > > my initial question, actually. I haven't looked at the code Paul
> > > pointed me at, but I wonder if that "forget(x)" macro would help
> > > those cases. I'd wish to avoid the "volatile" primitive, personally.
> > 
> > So, looking at load instead of store, understand I correctly that in
> > your opinion
> > 
> > 	int b;
> > 
> > 	b = atomic_read(&a);
> > 	if (b)
> > 		do_something_time_consuming();
> > 
> > 	b = atomic_read(&a);
> > 	if (b)
> > 		do_something_more();
> > 
> > should be changed to explicitly forget(&a) after
> > do_something_time_consuming?
> 
> No, I'd actually prefer something like what Christoph Lameter suggested,
> i.e. users (such as above) who want "volatile"-like behaviour from atomic
> ops can use alternative functions. How about something like:
> 
> #define atomic_read_volatile(v)			\
> 	({					\
> 		forget(&(v)->counter);		\
> 		((v)->counter);			\
> 	})

Wouldn't the above "forget" the value, throw it away, then forget
that it forgot it, giving non-volatile semantics?

> Or possibly, implement these "volatile" atomic ops variants in inline asm
> like the patch that Sebastian Siewior has submitted on another thread just
> a while back.

Given that you are advocating a change (please keep in mind that
atomic_read() and atomic_set() had volatile semantics on almost all
platforms), care to give some example where these historical volatile
semantics are causing a problem?

> Of course, if we find there are more callers in the kernel who want the
> volatility behaviour than those who don't care, we can re-define the
> existing ops to such variants, and re-name the existing definitions to
> somethine else, say "atomic_read_nonvolatile" for all I care.

Do we really need another set of APIs?  Can you give even one example
where the pre-existing volatile semantics are causing enough of a problem
to justify adding yet more atomic_*() APIs?

							Thanx, Paul
