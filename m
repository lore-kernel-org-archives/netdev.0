From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] percpu: add optimized generic percpu accessors
Date: Fri, 16 Jan 2009 23:08:32 +0100
Message-ID: <20090116220832.GB20653@elte.hu>
References: <20090115183942.GA6325@elte.hu> <20090116001544.GA11073@elte.hu> <20090116001824.GA9221@gondor.apana.org.au> <200901170827.33729.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	akpm@linux-foundation.org, tj@kernel.org, hpa@zytor.com,
	brgerst@gmail.com, ebiederm@xmission.com, cl@linux-foundation.org,
	travis@sgi.com, linux-kernel@vger.kernel.org, steiner@sgi.com,
	hugh@veritas.com, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:42542 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762480AbZAPWJp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jan 2009 17:09:45 -0500
Content-Disposition: inline
In-Reply-To: <200901170827.33729.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Rusty Russell <rusty@rustcorp.com.au> wrote:

> On Friday 16 January 2009 10:48:24 Herbert Xu wrote:
> > On Fri, Jan 16, 2009 at 01:15:44AM +0100, Ingo Molnar wrote:
> > >
> > > > So if you could design the API such that we have a variant of add/inc 
> > > > that automatically disables/enables preemption then we can optimise that 
> > > > away on x86.
> > > 
> > > Yeah. percpu_add(var, 1) does exactly that on x86.
> 
> <sigh>.  No it doesn't.

What do you mean by "No it doesn't". It does exactly what i claimed it 
does.

> It's really nice that everyone's excited about this, but it's more 
> complex than this.  Unf. I'm too busy preparing for linux.conf.au to 
> explain it all properly right now, but here's the highlights:
> 
> 1) This only works on static per-cpu vars.
>    - We are working on fixing this, but it's non-trivial for large allocs like
>      those in networking.  Small allocs, we have patches for.

How do difficulties of dynamic percpu-alloc make my above suggestion 
unsuitable for SNMP stats in networking? Most of those stats are not 
dynamically allocated - they are plain straightforward percpu variables.

Plus the majority of percpu usage is static - just like the majority of 
local variables is static, not dynamic. So any percpu-alloc complication 
is a non-issue.

> 2) The generic versions of these as posted by Tejun are unsuitable for
>    networking; they need to bh_disable.  That would make networking less
>    efficient than it is now for non-x86, and to be generic it would have
>    to be local_irq_save/restore anyway.

The generic versions will not be used on 95%+ of the active Linux systems 
out there, as they run on x86. If you worry about the remaining 5%, those 
can be optimized too.

> 3) local_t was designed to do exactly this: a fast cpu-local counter
>    implemented optimally for each arch.  For sparc64, doing a trivalue version
>    seems optimal, for s390 atomics, for x86 single-insn, for powerpc
>    irq_save/restore, etc.

But local_t does not actually solve this problem at all - because one 
still has to have per-cpu-ness.

> 4) Unfortunately, local_t has been extended beyond a simple counter, meaning
>    it now has more complex requirements (eg. Mathieu wants nmi-safe, even
>    though that's impossible on sparc and parisc, and percpu_counter wants
>    local_add_return, which makes trival less desirable).  These discussions
>    are on the back burner at the moment, but ongoing.

In reality local_t has almost zero users in the kernel - despite being 
with us at least since v2.6.12. That pretty much tells us all about its 
utility.

The thing is, local_t without proper percpu integration is a toothless 
tiger in the jungle. And our APIS do exactly that kind of integration and 
i expect them to be more popular than local_t. There's already a dozen 
usage sites of it in arch/x86.

	Ingo
