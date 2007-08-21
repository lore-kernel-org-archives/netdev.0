From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Tue, 21 Aug 2007 09:43:52 -0700 (PDT)
Message-ID: <alpine.LFD.0.999.0708210922290.30176@woody.linux-foundation.org>
References: <alpine.LFD.0.999.0708170929580.30176@woody.linux-foundation.org>
 <46C993DF.4080400@redhat.com> <alpine.LFD.0.999.0708202244520.30176@woody.linux-foundation.org>
 <20070821.000404.39159401.davem@davemloft.net>
 <46CAED8B.9030006@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, piggin@cyberone.com.au,
	satyam@infradead.org, herbert@gondor.apana.org.au,
	paulus@samba.org, clameter@sgi.com, ilpo.jarvinen@helsinki.fi,
	paulmck@linux.vnet.ibm.com, stefanr@s5r6.in-berlin.de,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org, ak@suse.de,
	heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com,
	wensong@linux-vs.org, horms@verge.net.au, wjiang@resilience.com,
	cfriesen@nortel.com, zlynx@acm.org, rpjday@mindspring.com,
	jesper.juhl@gmail.com, segher@kernel.crashing.org
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:35508 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759459AbXHUQvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2007 12:51:32 -0400
In-Reply-To: <46CAED8B.9030006@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Tue, 21 Aug 2007, Chris Snook wrote:
> 
> Moore's law is definitely working against us here.  Register counts, pipeline
> depths, core counts, and clock multipliers are all increasing in the long run.
> At some point in the future, barrier() will be universally regarded as a
> hammer too big for most purposes.

Note that "barrier()" is purely a compiler barrier. It has zero impact on 
the CPU pipeline itself, and also has zero impact on anything that gcc 
knows isn't visible in memory (ie local variables that don't have their 
address taken), so barrier() really is pretty cheap.

Now, it's possible that gcc messes up in some circumstances, and that the 
memory clobber will cause gcc to also do things like flush local registers 
unnecessarily to their stack slots, but quite frankly, if that happens, 
it's a gcc problem, and I also have to say that I've not seen that myself.

So in a very real sense, "barrier()" will just make sure that there is a 
stronger sequence point for the compiler where things are stable. In most 
cases it has absolutely zero performance impact - apart from the 
-intended- impact of making sure that the compiler doesn't re-order or 
cache stuff around it.

And sure, we could make it more finegrained, and also introduce a 
per-variable barrier, but the fact is, people _already_ have problems with 
thinking about these kinds of things, and adding new abstraction issues 
with subtle semantics is the last thing we want.

So I really think you'd want to show a real example of real code that 
actually gets noticeably slower or bigger.

In removing "volatile", we have shown that. It may not have made a big 
difference on powerpc, but it makes a real difference on x86 - and more 
importantly, it removes something that people clearly don't know how it 
works, and incorrectly expect to just fix bugs.

[ There are *other* barriers - the ones that actually add memory barriers 
  to the CPU - that really can be quite expensive. The good news is that 
  the expense is going down rather than up: both Intel and AMD are not 
  only removing the need for some of them (ie "smp_rmb()" will become a 
  compiler-only barrier), but we're _also_ seeing the whole "pipeline 
  flush" approach go away, and be replaced by the CPU itself actually 
  being better - so even the actual CPU pipeline barriers are getting
  cheaper, not more expensive. ]

For example, did anybody even _test_ how expensive "barrier()" is? Just 
as a lark, I did

	#undef barrier
	#define barrier() do { } while (0)

in kernel/sched.c (which only has three of them in it, but hey, that's 
more than most files), and there were _zero_ code generation downsides. 
One instruction was moved (and a few line numbers changed), so it wasn't 
like the assembly language was identical, but the point is, barrier() 
simply doesn't have the same kinds of downsides that "volatile" has.

(That may not be true on other architectures or in other source files, of 
course. This *does* depend on code generation details. But anybody who 
thinks that "barrier()" is fundamentally expensive is simply incorrect. It 
is *fundamnetally* a no-op).

		Linus
