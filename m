From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Fri, 17 Aug 2007 14:17:36 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0708171358520.3666@enigma.security.iitk.ac.in>
References: <E1ILCgh-00052A-00@gondolin.me.apana.org.au> <46C32618.2080108@redhat.com>
 <20070815234021.GA28775@gondor.apana.org.au> <3694fb2e4ed1e4d9bf873c0d050c911e@kernel.crashing.org>
 <46C3B50E.7010702@yahoo.com.au> <194369f4c96ea0e24decf8f9197d5bad@kernel.crashing.org>
 <46C505B2.6030704@yahoo.com.au> <18117.4848.695269.72976@cargo.ozlabs.ibm.com>
 <alpine.LFD.0.999.0708162033400.30176@woody.linux-foundation.org>
 <alpine.LFD.0.999.0708171016160.3666@enigma.security.iitk.ac.in>
 <46C54D94.5080803@yahoo.com.au>
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
To: Nick Piggin <nickpiggin@yahoo.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:34060 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756283AbXHQIfK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 04:35:10 -0400
In-Reply-To: <46C54D94.5080803@yahoo.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 17 Aug 2007, Nick Piggin wrote:

> Satyam Sharma wrote:
> 
> > #define atomic_read_volatile(v)				\
> > 	({						\
> > 		forget((v)->counter);			\
> > 		((v)->counter);				\
> > 	})
> > 
> > where:
> 
> *vomit* :)

I wonder if this'll generate smaller and better code than _both_ the
other atomic_read_volatile() variants. Would need to build allyesconfig
on lots of diff arch's etc to test the theory though.


> Not only do I hate the keyword volatile, but the barrier is only a
> one-sided affair so its probable this is going to have slightly
> different allowed reorderings than a real volatile access.

True ...


> Also, why would you want to make these insane accessors for atomic_t
> types? Just make sure everybody knows the basics of barriers, and they
> can apply that knowledge to atomic_t and all other lockless memory
> accesses as well.

Code that looks like:

	while (!atomic_read(&v)) {
		...
		cpu_relax_no_barrier();
		forget(v.counter);
		        ^^^^^^^^
	}

would be uglier. Also think about code such as:

	a = atomic_read();
	if (!a)
		do_something();

	forget();
	a = atomic_read();
	... /* some code that depends on value of a, obviously */

	forget();
	a = atomic_read();
	...

So much explicit sprinkling of "forget()" looks ugly.

	atomic_read_volatile()

on the other hand, looks neater. The "_volatile()" suffix makes it also
no less explicit than an explicit barrier-like macro that this primitive
is something "special", for code clarity purposes.


> > #define forget(a)	__asm__ __volatile__ ("" :"=m" (a) :"m" (a))
> 
> I like order(x) better, but it's not the most perfect name either.

forget(x) is just a stupid-placeholder-for-a-better-name. order(x) sounds
good but we could leave quibbling about function or macro names for later,
this thread is noisy as it is :-)
