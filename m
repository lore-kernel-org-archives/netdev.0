From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 2/2] arm64: bpf: add BPF XADD instruction
Date: Thu, 12 Nov 2015 09:57:40 +0100
Message-ID: <20151112085740.GV17308@twins.programming.kicks-ass.net>
References: <20151111172659.GA86334@ast-mbp.thefacebook.com>
 <20151111.123548.1039494689070388545.davem@davemloft.net>
 <20151111175741.GR17308@twins.programming.kicks-ass.net>
 <20151111181132.GA90947@ast-mbp.thefacebook.com>
 <20151111183128.GS17308@twins.programming.kicks-ass.net>
 <20151111184427.GH11639@twins.programming.kicks-ass.net>
 <20151111185415.GI11639@twins.programming.kicks-ass.net>
 <20151111195558.GA4173@ast-mbp.thefacebook.com>
 <20151111222135.GU17308@twins.programming.kicks-ass.net>
 <20151111234014.GA17014@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, will.deacon@arm.com,
	daniel@iogearbox.net, arnd@arndb.de, yang.shi@linaro.org,
	linaro-kernel@lists.linaro.org, eric.dumazet@gmail.com,
	zlim.lnx@gmail.com, ast@kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, xi.wang@gmail.com, catalin.marinas@arm.com,
	linux-arm-kernel@lists.infradead.org, yhs@plumgrid.com,
	bblanco@plumgrid.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:50380 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753719AbbKLI5y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2015 03:57:54 -0500
Content-Disposition: inline
In-Reply-To: <20151111234014.GA17014@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 11, 2015 at 03:40:15PM -0800, Alexei Starovoitov wrote:
> On Wed, Nov 11, 2015 at 11:21:35PM +0100, Peter Zijlstra wrote:
> > On Wed, Nov 11, 2015 at 11:55:59AM -0800, Alexei Starovoitov wrote:
> > > Therefore things like memory barriers, full set of atomics are not applicable
> > > in bpf world.
> > 
> > There are still plenty of wait-free constructs one can make using them.
> 
> yes, but all such lock-free algos are typically based on cmpxchg8b and
> tight loop, so it would be very hard for verifier to proof termination
> of such loops. I think when we'd need to add something like this, we'll
> add new bpf insn that will be membarrier+cmpxhg8b+check+loop as
> a single insn, so it cannot be misused.
> I don't know of any concrete use case yet. All possible though.

So this is where the 'unconditional' atomic ops come in handy.

Like the x86: xchg, lock {xadd,add,sub,inc,dec,or,and,xor}

Those do not have a loop, and then you can create truly wait-free
things; even some applications of cmpxchg do not actually need the loop.

But this class of wait-free constructs is indeed significantly smaller
than the class of lock-less constructs.

> btw, support for mini loops was requested many times in the past.
> I guess we'd have to add something like this, but it's tricky.
> Mainly because control flow graph analysis becomes much more complicated.

Agreed, that does sound like an 'interesting' problem :-)

Something like:

atomic_op(ptr, f)
{
	for (;;) {
		val = *ptr;
		new = f(val)
		old = cmpxchg(ptr, val, new);
		if (old == val)
			break;

		cpu_relax();
	}
}

might be castable as an instruction I suppose, but I'm not sure you have
function references in (e)BPF.

The above is 'sane' if f is sane (although there is a
starvation case, which is why things like sparc (iirc) need an
increasing backoff instead of cpu_relax()).
