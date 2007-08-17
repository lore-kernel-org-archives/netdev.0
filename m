From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Thu, 16 Aug 2007 22:18:11 -0700
Message-ID: <20070817051811.GB12232@linux.vnet.ibm.com>
References: <E1ILCgh-00052A-00@gondolin.me.apana.org.au> <46C32618.2080108@redhat.com> <20070815234021.GA28775@gondor.apana.org.au> <3694fb2e4ed1e4d9bf873c0d050c911e@kernel.crashing.org> <46C3B50E.7010702@yahoo.com.au> <194369f4c96ea0e24decf8f9197d5bad@kernel.crashing.org> <46C505B2.6030704@yahoo.com.au> <18117.4848.695269.72976@cargo.ozlabs.ibm.com> <alpine.LFD.0.999.0708162033400.30176@woody.linux-foundation.org>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Mackerras <paulus@samba.org>,
	Nick Piggin <nickpiggin@yahoo.com.au>,
	Segher Boessenkool <segher@kernel.crashing.org>,
	heiko.carstens@de.ibm.com, horms@verge.net.au,
	linux-kernel@vger.kernel.org, rpjday@mindspring.com, ak@suse.de,
	netdev@vger.kernel.org, cfriesen@nortel.com,
	akpm@linux-foundation.org, jesper.juhl@gmail.com,
	linux-arch@vger.kernel.org, zlynx@acm.org, satyam@infradead.org,
	clameter@sgi.com, schwidefsky@de.ibm.com,
	Chris Snook <csnook@redhat.com>,
	Herbert Xu <herbert.xu@redhat.com>, davem@davemloft.net,
	wensong@linux-vs.org, wjiang@resilience.com
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:49714 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752563AbXHQFSQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Aug 2007 01:18:16 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.999.0708162033400.30176@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 16, 2007 at 08:42:23PM -0700, Linus Torvalds wrote:
> 
> 
> On Fri, 17 Aug 2007, Paul Mackerras wrote:
> > 
> > I'm really surprised it's as much as a few K.  I tried it on powerpc
> > and it only saved 40 bytes (10 instructions) for a G5 config.
> 
> One of the things that "volatile" generally screws up is a simple
> 
> 	volatile int i;
> 
> 	i++;
> 
> which a compiler will generally get horribly, horribly wrong.
> 
> In a reasonable world, gcc should just make that be (on x86)
> 
> 	addl $1,i(%rip)
> 
> on x86-64, which is indeed what it does without the volatile. But with the 
> volatile, the compiler gets really nervous, and doesn't dare do it in one 
> instruction, and thus generates crap like
> 
>         movl    i(%rip), %eax
>         addl    $1, %eax
>         movl    %eax, i(%rip)

Blech.  Sounds like a chat with some gcc people is in order.  Will
see what I can do.

						Thanx, Paul

> instead. For no good reason, except that "volatile" just doesn't have any 
> good/clear semantics for the compiler, so most compilers will just make it 
> be "I will not touch this access in any way, shape, or form". Including 
> even trivially correct instruction optimization/combination.
> 
> This is one of the reasons why we should never use "volatile". It 
> pessimises code generation for no good reason - just because compilers 
> don't know what the heck it even means! 
> 
> Now, people don't do "i++" on atomics (you'd use "atomic_inc()" for that), 
> but people *do* do things like
> 
> 	if (atomic_read(..) <= 1)
> 		..
> 
> On ppc, things like that probably don't much matter. But on x86, it makes 
> a *huge* difference whether you do
> 
> 	movl i(%rip),%eax
> 	cmpl $1,%eax
> 
> or if you can just use the value directly for the operation, like this:
> 
> 	cmpl $1,i(%rip)
> 
> which is again a totally obvious and totally safe optimization, but is 
> (again) something that gcc doesn't dare do, since "i" is volatile.
> 
> In other words: "volatile" is a horribly horribly bad way of doing things, 
> because it generates *worse*code*, for no good reason. You just don't see 
> it on powerpc, because it's already a load-store architecture, so there is 
> no "good code" for doing direct-to-memory operations.
> 
> 		Linus
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
