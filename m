From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Fri, 17 Aug 2007 09:48:39 -0700 (PDT)
Message-ID: <alpine.LFD.0.999.0708170929580.30176@woody.linux-foundation.org>
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
Cc: Satyam Sharma <satyam@infradead.org>,
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
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org
To: Nick Piggin <piggin@cyberone.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:40312 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753453AbXHQQvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 12:51:23 -0400
In-Reply-To: <46C59717.4020108@cyberone.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 17 Aug 2007, Nick Piggin wrote:
> 
> That's not obviously just taste to me. Not when the primitive has many
> (perhaps, the majority) of uses that do not require said barriers. And
> this is not solely about the code generation (which, as Paul says, is
> relatively minor even on x86). I prefer people to think explicitly
> about barriers in their lockless code.

Indeed.

I think the important issues are:

 - "volatile" itself is simply a badly/weakly defined issue. The semantics 
   of it as far as the compiler is concerned are really not very good, and 
   in practice tends to boil down to "I will generate so bad code that 
   nobody can accuse me of optimizing anything away".

 - "volatile" - regardless of how well or badly defined it is - is purely 
   a compiler thing. It has absolutely no meaning for the CPU itself, so 
   it at no point implies any CPU barriers. As a result, even if the 
   compiler generates crap code and doesn't re-order anything, there's 
   nothing that says what the CPU will do.

 - in other words, the *only* possible meaning for "volatile" is a purely 
   single-CPU meaning. And if you only have a single CPU involved in the 
   process, the "volatile" is by definition pointless (because even 
   without a volatile, the compiler is required to make the C code appear 
   consistent as far as a single CPU is concerned).

So, let's take the example *buggy* code where we use "volatile" to wait 
for other CPU's:

	atomic_set(&var, 0);
	while (!atomic_read(&var))
		/* nothing */;


which generates an endless loop if we don't have atomic_read() imply 
volatile.

The point here is that it's buggy whether the volatile is there or not! 
Exactly because the user expects multi-processing behaviour, but 
"volatile" doesn't actually give any real guarantees about it. Another CPU 
may have done:

	external_ptr = kmalloc(..);
	/* Setup is now complete, inform the waiter */
	atomic_inc(&var);

but the fact is, since the other CPU isn't serialized in any way, the 
"while-loop" (even in the presense of "volatile") doesn't actually work 
right! Whatever the "atomic_read()" was waiting for may not have 
completed, because we have no barriers!

So if "volatile" makes a difference, it is invariably a sign of a bug in 
serialization (the one exception is for IO - we use "volatile" to avoid 
having to use inline asm for IO on x86) - and for "random values" like 
jiffies).

So the question should *not* be whether "volatile" actually fixes bugs. It 
*never* fixes a bug. But what it can do is to hide the obvious ones. In 
other words, adding a volaile in the above kind of situation of 
"atomic_read()" will certainly turn an obvious bug into something that 
works "practically all of the time).

So anybody who argues for "volatile" fixing bugs is fundamentally 
incorrect. It does NO SUCH THING. By arguing that, such people only show 
that you have no idea what they are talking about.

So the only reason to add back "volatile" to the atomic_read() sequence is 
not to fix bugs, but to _hide_ the bugs better. They're still there, they 
are just a lot harder to trigger, and tend to be a lot subtler.

And hey, sometimes "hiding bugs well enough" is ok. In this case, I'd 
argue that we've successfully *not* had the volatile there for eight 
months on x86-64, and that should tell people something. 

(Does _removing_ the volatile fix bugs? No - callers still need to think 
about barriers etc, and lots of people don't. So I'm not claiming that 
removing volatile fixes any bugs either, but I *am* claiming that:

 - removing volatile makes some bugs easier to see (which is mostly a good 
   thing: they were there before, anyway).

 - removing volatile generates better code (which is a good thing, even if 
   it's just 0.1%)

 - removing volatile removes a huge mental *bug* that lots of people seem 
   to have, as shown by this whole thread. Anybody who thinks that 
   "volatile" actually fixes anything has a gaping hole in their head, and 
   we should remove volatile just to make sure that nobody thinks that it 
   means soemthign that it doesn't mean!

In other words, this whole discussion has just convinced me that we should 
*not* add back "volatile" to "atomic_read()" - I was willing to do it for 
practical and "hide the bugs" reasons, but having seen people argue for 
it, thinking that it actually fixes something, I'm now convinced that the 
*last* thing we should do is to encourage that kind of superstitious 
thinking.

"volatile" is like a black cat crossing the road. Sure, it affects 
*something* (at a minimum: before, the black cat was on one side of the 
road, afterwards it is on the other side of the road), but it has no 
bigger and longer-lasting direct affects. 

People who think "volatile" really matters are just fooling themselves.

		Linus
