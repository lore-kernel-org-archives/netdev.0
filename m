From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Fri, 17 Aug 2007 12:08:31 -0700 (PDT)
Message-ID: <alpine.LFD.0.999.0708171201130.30176@woody.linux-foundation.org>
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
 <46C59717.4020108@cyberone.com.au> <alpine.LFD.0.999.0708170929580.30176@woody.linux-foundation.org>
 <46C5EDF9.3090507@nortel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Nick Piggin <piggin@cyberone.com.au>,
	Satyam Sharma <satyam@infradead.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Paul Mackerras <paulus@samba.org>,
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
	wjiang@resilience.com, zlynx@acm.org, rpjday@mindspring.com,
	jesper.juhl@gmail.com, segher@kernel.crashing.org
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:56091 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750834AbXHQTLT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 15:11:19 -0400
In-Reply-To: <46C5EDF9.3090507@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 17 Aug 2007, Chris Friesen wrote:
> 
> I assume you mean "except for IO-related code and 'random' values like
> jiffies" as you mention later on?

Yes. There *are* valid uses for "volatile", but they have remained the 
same for the last few years:
 - "jiffies"
 - internal per-architecture IO implementations that can do them as normal 
   stores.

> I assume other values set in interrupt handlers would count as "random" 
> from a volatility perspective?

I don't really see any valid case. I can imagine that you have your own 
"jiffy" counter in a driver, but what's the point, really? I'd suggest not 
using volatile, and using barriers instead.

> 
> > So anybody who argues for "volatile" fixing bugs is fundamentally 
> > incorrect. It does NO SUCH THING. By arguing that, such people only 
> > show that you have no idea what they are talking about.

> What about reading values modified in interrupt handlers, as in your 
> "random" case?  Or is this a bug where the user of atomic_read() is 
> invalidly expecting a read each time it is called?

Quite frankly, the biggest reason for using "volatile" on jiffies was 
really historic. So even the "random" case is not really a very strong 
one. You'll notice that anybody who is actually careful will be using 
sequence locks for the jiffy accesses, if only because the *full* jiffy 
count is actually a 64-bit value, and so you cannot get it atomically on a 
32-bit architecture even on a single CPU (ie a timer interrupt might 
happen in between reading the low and the high word, so "volatile" is only 
used for the low 32 bits).

So even for jiffies, we actually have:

	extern u64 __jiffy_data jiffies_64;
	extern unsigned long volatile __jiffy_data jiffies;

where the *real* jiffies is not volatile: the volatile one is using linker 
tricks to alias the low 32 bits:

 - arch/i386/kernel/vmlinux.lds.S:

	...
	jiffies = jiffies_64;
	...

and the only reason we do all these games is (a) it works and (b) it's 
legacy.

Note how I do *not* say "(c) it's a good idea".

			Linus

