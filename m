From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Fri, 24 Aug 2007 10:19:50 -0700 (PDT)
Message-ID: <alpine.LFD.0.999.0708241001560.25853@woody.linux-foundation.org>
References: <20070815234021.GA28775@gondor.apana.org.au>
 <alpine.LFD.0.999.0708180709060.3666@enigma.security.iitk.ac.in>
 <alpine.LFD.0.999.0708172110400.30176@woody.linux-foundation.org>
 <200708241319.05760.vda.linux@googlemail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Satyam Sharma <satyam@infradead.org>,
	Christoph Lameter <clameter@sgi.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Nick Piggin <nickpiggin@yahoo.com.au>,
	Paul Mackerras <paulus@samba.org>,
	Segher Boessenkool <segher@kernel.crashing.org>,
	heiko.carstens@de.ibm.com, horms@verge.net.au,
	linux-kernel@vger.kernel.org, rpjday@mindspring.com, ak@suse.de,
	netdev@vger.kernel.org, cfriesen@nortel.com,
	akpm@linux-foundation.org, jesper.juhl@gmail.com,
	linux-arch@vger.kernel.org, zlynx@acm.org, schwidefsky@de.ibm.com,
	Chris Snook <csnook@redhat.com>, davem@davemloft.net,
	wensong@linux-vs.org, wjiang@resilience.com
To: Denys Vlasenko <vda.linux@googlemail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763610AbXHXR1J@vger.kernel.org>
In-Reply-To: <200708241319.05760.vda.linux@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 24 Aug 2007, Denys Vlasenko wrote:
>
> > No, you don't use "x.counter++". But you *do* use
> >
> > 	if (atomic_read(&x) <= 1)
> >
> > and loading into a register is stupid and pointless, when you could just
> > do it as a regular memory-operand to the cmp instruction.
> 
> It doesn't mean that (volatile int*) cast is bad, it means that current gcc
> is bad (or "not good enough"). IOW: instead of avoiding volatile cast,
> it's better to fix the compiler.

I would agree that fixing the compiler in this case would be a good thing, 
even quite regardless of any "atomic_read()" discussion.

I just have a strong suspicion that "volatile" performance is so low down 
the list of any C compiler persons interest, that it's never going to 
happen. And quite frankly, I cannot blame the gcc guys for it.

That's especially as "volatile" really isn't a very good feature of the C 
language, and is likely to get *less* interesting rather than more (as 
user space starts to be more and more threaded, "volatile" gets less and 
less useful.

[ Ie, currently, I think you can validly use "volatile" in a "sigatomic_t" 
  kind of way, where there is a single thread, but with asynchronous 
  events. In that kind of situation, I think it's probably useful. But 
  once you get multiple threads, it gets pointless.

  Sure: you could use "volatile" together with something like Dekker's or 
  Peterson's algorithm that doesn't depend on cache coherency (that's 
  basically what the C "volatile" keyword approximates: not atomic 
  accesses, but *uncached* accesses! But let's face it, that's way past 
  insane. ]

So I wouldn't expect "volatile" to ever really generate better code. It 
might happen as a side effect of other improvements (eg, I might hope that 
the SSA work would eventually lead to gcc having a much better defined 
model of valid optimizations, and maybe better code generation for 
volatile accesses fall out cleanly out of that), but in the end, it's such 
an ugly special case in C, and so seldom used, that I wouldn't depend on 
it.

> Linus, in all honesty gcc has many more cases of suboptimal code,
> case of "volatile" is just one of many.

Well, the thing is, quite often, many of those "suboptimal code" 
generations fall into two distinct classes:

 - complex C code. I can't really blame the compiler too much for this. 
   Some things are *hard* to optimize, and for various scalability 
   reasons, you often end up having limits in the compiler where it 
   doesn't even _try_ doing certain optimizations if you have excessive 
   complexity.

 - bad register allocation. Register allocation really is hard, and 
   sometimes gcc just does the "obviously wrong" thing, and you end up 
   having totally unnecessary spills.

> Off the top of my head:

Yes, "unsigned long long" with x86 has always generated atrocious code. In 
fact, I would say that historically it was really *really* bad. These 
days, gcc actually does a pretty good job, but I'm not surprised that it's 
still quite possible to find cases where it did some optimization (in this 
case, apparently noticing that "shift by >= 32 bits" causes the low 
register to be pointless) and then missed *another* optimization (better 
register use) because that optimization had been done *before* the first 
optimization was done.

That's a *classic* example of compiler code generation issues, and quite 
frankly, I think that's very different from the issue of "volatile".

Quite frankly, I'd like there to be more competition in the open source 
compiler game, and that might cause some upheavals, but on the whole, gcc 
actually does a pretty damn good job. 

			Linus
