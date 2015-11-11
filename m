From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 2/2] arm64: bpf: add BPF XADD instruction
Date: Wed, 11 Nov 2015 18:46:54 +0000
Message-ID: <20151111184654.GQ9562@arm.com>
References: <56436420.9090401@iogearbox.net>
 <20151111162341.GN9562@arm.com>
 <20151111172659.GA86334@ast-mbp.thefacebook.com>
 <20151111.123548.1039494689070388545.davem@davemloft.net>
 <20151111175741.GR17308@twins.programming.kicks-ass.net>
 <20151111181132.GA90947@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <peterz@infradead.org>,
	David Miller <davem@davemloft.net>, daniel@iogearbox.net,
	arnd@arndb.de, yang.shi@linaro.org, linaro-kernel@lists.linaro.org,
	eric.dumazet@gmail.com, zlim.lnx@gmail.com, ast@kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	xi.wang@gmail.com, catalin.marinas@arm.com,
	linux-arm-kernel@lists.infradead.org, yhs@plumgrid.com,
	bblanco@plumgrid.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:33005 "EHLO foss.arm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751013AbbKKSqx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Nov 2015 13:46:53 -0500
Content-Disposition: inline
In-Reply-To: <20151111181132.GA90947@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 11, 2015 at 10:11:33AM -0800, Alexei Starovoitov wrote:
> On Wed, Nov 11, 2015 at 06:57:41PM +0100, Peter Zijlstra wrote:
> > On Wed, Nov 11, 2015 at 12:35:48PM -0500, David Miller wrote:
> > > From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
> > > Date: Wed, 11 Nov 2015 09:27:00 -0800
> > > 
> > > > BPF_XADD == atomic_add() in kernel. period.
> > > > we are not going to deprecate it or introduce something else.
> > > 
> > > Agreed, it makes no sense to try and tie C99 or whatever atomic
> > > semantics to something that is already clearly defined to have
> > > exactly kernel atomic_add() semantics.
> > 
> > Dave, this really doesn't make any sense to me. __sync primitives have
> > well defined semantics and (e)BPF is violating this.
> 
> bpf_xadd was never meant to be __sync_fetch_and_add equivalent.
> From the day one it meant to be atomic_add() as kernel does it.
> I did piggy back on __sync in the llvm backend because it was the quick
> and dirty way to move forward.
> In retrospect I should have introduced a clean intrinstic for that instead,
> but it's not too late to do it now. user space we can change at any time
> unlike kernel.

But it's not just "user space", it's the source language definition!
I also don't see how you can change it now, without simply rejecting
the __sync primitives outright.

> > Furthermore, the fetch_and_add (or XADD) name has well defined
> > semantics, which (e)BPF also violates.
> 
> bpf_xadd also didn't meant to be 'fetch'. It was void return from the beginning.

Right, so it's just a misnomer.

> > Atomicy is hard enough as it is, backends giving random interpretations
> > to them isn't helping anybody.
> 
> no randomness. bpf_xadd == atomic_add() in kernel.
> imo that is the simplest and cleanest intepretantion one can have, no?

I don't really mind, as long as there is a semantic that everybody agrees
on. Really, I just want this to be consistent because memory models are
a PITA enough without having multiple interpretations flying around.

> > It also baffles me that Alexei is seemingly unwilling to change/rev the
> > (e)BPF instructions, which would be invisible to the regular user, he
> > does want to change the language itself, which will impact all
> > 'scripts'.
> 
> well, we cannot change it in kernel because it's ABI.
> I'm not against adding new insns. We definitely can, but let's figure out why?
> Is anything broken? No. So what new insns make sense?

If you end up needing a suite of atomics, I would suggest the __atomic
builtins because they are likely to be more portable and more flexible
than trying to use the kernel memory model outside of the environment
for which it was developed. However, I agree with you that we can cross
that bridge when we get there.

> Adding new intrinsic to llvm is not a big deal. I'll add it as soon
> as I have time to work on it or if somebody beats me to it I would be
> glad to test it and apply it.

I'm more interested in what you do about the existing intrinsic. Anyway,
I'll raise a ticket against LLVM so that they're aware (and maybe
somebody else will fix it :).

Will
