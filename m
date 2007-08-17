From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Fri, 17 Aug 2007 19:48:41 +1000
Message-ID: <18117.28409.943948.355586@cargo.ozlabs.ibm.com>
References: <E1ILCgh-00052A-00@gondolin.me.apana.org.au>
	<46C32618.2080108@redhat.com>
	<20070815234021.GA28775@gondor.apana.org.au>
	<3694fb2e4ed1e4d9bf873c0d050c911e@kernel.crashing.org>
	<46C3B50E.7010702@yahoo.com.au>
	<194369f4c96ea0e24decf8f9197d5bad@kernel.crashing.org>
	<46C505B2.6030704@yahoo.com.au>
	<18117.4848.695269.72976@cargo.ozlabs.ibm.com>
	<alpine.LFD.0.999.0708162033400.30176@woody.linux-foundation.org>
	<alpine.LFD.0.999.0708171016160.3666@enigma.security.iitk.ac.in>
	<46C54D94.5080803@yahoo.com.au>
	<alpine.LFD.0.999.0708171358520.3666@enigma.security.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Nick Piggin <nickpiggin@yahoo.com.au>,
	Linus Torvalds <torvalds@linux-foundation.org>,
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
Received: from ozlabs.org ([203.10.76.45]:56124 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750950AbXHQJsr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Aug 2007 05:48:47 -0400
In-Reply-To: <alpine.LFD.0.999.0708171358520.3666@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Satyam Sharma writes:

> I wonder if this'll generate smaller and better code than _both_ the
> other atomic_read_volatile() variants. Would need to build allyesconfig
> on lots of diff arch's etc to test the theory though.

I'm sure it would be a tiny effect.

This whole thread is arguing about effects that are quite
insignificant.  On the one hand we have the non-volatile proponents,
who want to let the compiler do extra optimizations - which amounts to
letting it elide maybe a dozen loads in the whole kernel, loads which
would almost always be L1 cache hits.

On the other hand we have the volatile proponents, who are concerned
that some code somewhere in the kernel might be buggy without the
volatile behaviour, and who also want to be able to remove some
barriers and thus save a few bytes of code and a few loads here and
there (and possibly some stores too).

Either way the effect on code size and execution time is miniscule.

In the end the strongest argument is actually that gcc generates
unnecessarily verbose code on x86[-64] for volatile accesses.  Even
then we're only talking about ~2000 bytes, or less than 1 byte per
instance of atomic_read on average, about 0.06% of the kernel text
size.

The x86[-64] developers seem to be willing to bear the debugging cost
involved in having the non-volatile behaviour for atomic_read, in
order to save the 2kB.  That's fine with me.  Either way I think
somebody should audit all the uses of atomic_read, not just for
missing barriers, but also to find the places where it's used in a
racy manner.  Then we can work out where the races matter and fix them
if they do.

Paul.
