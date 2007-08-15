From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Wed, 15 Aug 2007 12:07:22 -0700
Message-ID: <20070815190722.GI9645@linux.vnet.ibm.com>
References: <20070809131423.GA9927@shell.boston.redhat.com> <Pine.LNX.4.64.0708141529310.32693@schroedinger.engr.sgi.com> <alpine.LFD.0.999.0708150417240.6482@enigma.security.iitk.ac.in> <46C2D6F3.3070707@s5r6.in-berlin.de> <alpine.LFD.0.999.0708151713080.16414@enigma.security.iitk.ac.in> <46C2FADB.7020407@s5r6.in-berlin.de> <alpine.LFD.0.999.0708151906330.16414@enigma.security.iitk.ac.in> <20070815142516.GB9645@linux.vnet.ibm.com> <alpine.LFD.0.999.0708152048270.16414@enigma.security.iitk.ac.in>
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
Received: from e3.ny.us.ibm.com ([32.97.182.143]:41108 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754102AbXHOTH0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 15:07:26 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.999.0708152048270.16414@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 15, 2007 at 11:25:05PM +0530, Satyam Sharma wrote:
> Hi Paul,
> On Wed, 15 Aug 2007, Paul E. McKenney wrote:
> 
> > On Wed, Aug 15, 2007 at 07:17:29PM +0530, Satyam Sharma wrote:
> > > [...]
> > > No, I'd actually prefer something like what Christoph Lameter suggested,
> > > i.e. users (such as above) who want "volatile"-like behaviour from atomic
> > > ops can use alternative functions. How about something like:
> > > 
> > > #define atomic_read_volatile(v)			\
> > > 	({					\
> > > 		forget(&(v)->counter);		\
> > > 		((v)->counter);			\
> > > 	})
> > 
> > Wouldn't the above "forget" the value, throw it away, then forget
> > that it forgot it, giving non-volatile semantics?
> 
> Nope, I don't think so. I wrote the following trivial testcases:
> [ See especially tp4.c and tp4.s (last example). ]

Right.  I should have said "wouldn't the compiler be within its rights
to forget the value, throw it away, then forget that it forgot it".
The value coming out of the #define above is an unadorned ((v)->counter),
which has no volatile semantics.

> ==============================================================================
> $ cat tp1.c # Using volatile access casts
> 
> #define atomic_read(a)	(*(volatile int *)&a)
> 
> int a;
> 
> void func(void)
> {
> 	a = 0;
> 	while (atomic_read(a))
> 		;
> }
> ==============================================================================
> $ gcc -Os -S tp1.c; cat tp1.s
> 
> func:
> 	pushl	%ebp
> 	movl	%esp, %ebp
> 	movl	$0, a
> .L2:
> 	movl	a, %eax
> 	testl	%eax, %eax
> 	jne	.L2
> 	popl	%ebp
> 	ret
> ==============================================================================
> $ cat tp2.c # Using nothing; gcc will optimize the whole loop away
> 
> #define forget(x)
> 
> #define atomic_read(a)		\
> 	({			\
> 		forget(&(a));	\
> 		(a);		\
> 	})
> 
> int a;
> 
> void func(void)
> {
> 	a = 0;
> 	while (atomic_read(a))
> 		;
> }
> ==============================================================================
> $ gcc -Os -S tp2.c; cat tp2.s
> 
> func:
> 	pushl	%ebp
> 	movl	%esp, %ebp
> 	popl	%ebp
> 	movl	$0, a
> 	ret
> ==============================================================================
> $ cat tp3.c # Using a full memory clobber barrier
> 
> #define forget(x)	asm volatile ("":::"memory")
> 
> #define atomic_read(a)		\
> 	({			\
> 		forget(&(a));	\
> 		(a);		\
> 	})
> 
> int a;
> 
> void func(void)
> {
> 	a = 0;
> 	while (atomic_read(a))
> 		;
> }
> ==============================================================================
> $ gcc -Os -S tp3.c; cat tp3.s
> 
> func:
> 	pushl	%ebp
> 	movl	%esp, %ebp
> 	movl	$0, a
> .L2:
> 	cmpl	$0, a
> 	jne	.L2
> 	popl	%ebp
> 	ret
> ==============================================================================
> $ cat tp4.c # Using a forget(var) macro
> 
> #define forget(a)	__asm__ __volatile__ ("" :"=m" (a) :"m" (a))
> 
> #define atomic_read(a)		\
> 	({			\
> 		forget(a);	\
> 		(a);		\
> 	})
> 
> int a;
> 
> void func(void)
> {
> 	a = 0;
> 	while (atomic_read(a))
> 		;
> }
> ==============================================================================
> $ gcc -Os -S tp4.c; cat tp4.s
> 
> func:
> 	pushl	%ebp
> 	movl	%esp, %ebp
> 	movl	$0, a
> .L2:
> 	cmpl	$0, a
> 	jne	.L2
> 	popl	%ebp
> 	ret
> ==============================================================================
> 
> Possibly these were too trivial to expose any potential problems that you
> may have been referring to, so would be helpful if you could write a more
> concrete example / sample code.

The trick is to have a sufficiently complicated expression to force
the compiler to run out of registers.  If the value is non-volatile,
it will refetch it (and expect it not to have changed, possibly being
disappointed by an interrupt handler running on that same CPU).

> > > Or possibly, implement these "volatile" atomic ops variants in inline asm
> > > like the patch that Sebastian Siewior has submitted on another thread just
> > > a while back.
> > 
> > Given that you are advocating a change (please keep in mind that
> > atomic_read() and atomic_set() had volatile semantics on almost all
> > platforms), care to give some example where these historical volatile
> > semantics are causing a problem?
> > [...]
> > Can you give even one example
> > where the pre-existing volatile semantics are causing enough of a problem
> > to justify adding yet more atomic_*() APIs?
> 
> Will take this to the other sub-thread ...

OK.

> > > Of course, if we find there are more callers in the kernel who want the
> > > volatility behaviour than those who don't care, we can re-define the
> > > existing ops to such variants, and re-name the existing definitions to
> > > somethine else, say "atomic_read_nonvolatile" for all I care.
> > 
> > Do we really need another set of APIs?
> 
> Well, if there's one set of users who do care about volatile behaviour,
> and another set that doesn't, it only sounds correct to provide both
> those APIs, instead of forcing one behaviour on all users.

Well, if the second set doesn't care, they should be OK with the volatile
behavior in this case.

							Thanx, Paul
