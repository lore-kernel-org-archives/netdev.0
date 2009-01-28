From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] percpu: add optimized generic percpu accessors
Date: Wed, 28 Jan 2009 21:08:49 +1030
Message-ID: <200901282108.51864.rusty@rustcorp.com.au>
References: <20090115183942.GA6325@elte.hu> <200901271213.18605.rusty@rustcorp.com.au> <497E705B.5000302@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	akpm@linux-foundation.org, hpa@zytor.com, brgerst@gmail.com,
	ebiederm@xmission.com, cl@linux-foundation.org, travis@sgi.com,
	linux-kernel@vger.kernel.org, steiner@sgi.com, hugh@veritas.com,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:52440 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754781AbZA1KjA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jan 2009 05:39:00 -0500
In-Reply-To: <497E705B.5000302@kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 27 January 2009 12:54:27 Tejun Heo wrote:
> Hello, Rusty.

Hi Tejun!

> There actually were quite some places where atomic add ops would be
> useful, especially the places where statistics are collected.  For
> logical bitops, I don't think we'll have too many of them.

If the stats are only manipulated in one context, than an atomic requirement is overkill (and expensive on non-x86).

> > If they are worth doing generically, should the ops be atomic? To
> > extrapolate from x86 usages again, it seems to be happy with
> > non-atomic (tho of course it is atomic on x86).
> 
> If atomic rw/add/sub are implementible on most archs (and judging from
> local_t, I suppose it is), I think it should.  So that it can replace
> local_t and we won't need something else again in the future.

This is more like Christoph's CPU_OPS: they were special operators on normal per-cpu vars/ptrs.  Generic version was irqsave+op+irqrestore.

I actually like this idea, but Mathieu insists that the ops be NMI-safe, for ftrace.  Hence local_t needing to be atomic_t for generic code.

AFAICT we'll need a hybrid: HAVE_NMISAFE_CPUOPS, and if not, use atomic_t
in ftrace (which isn't NMI safe on parisc or sparc/32 anyway, but I don't think we care).

Other than the shouting, I liked Christoph's system:
- CPU_INC = always safe (eg. local_irq_save/per_cpu(i)++/local_irq_restore)
- _CPU_INC = not safe against interrupts (eg. get_cpu/per_cpu(i)++/put_cpu)
- __CPU_INC = not safe against anything (eg. per_cpu(i)++)

I prefer the name 'local' to the name 'cpu', but I'm not hugely fussed.

> >> Another question to ask is whether to keep using separate
> >> interfaces for static and dynamic percpu variables or migrate to
> >> something which can take both.
> >
> > Well, IA64 can do stuff with static percpus that it can't do with
> > dynamic (assuming we get expanding dynamic percpu areas
> > later). That's because they use TLB tricks for a static 64k per-cpu
> > area, but this doesn't scale.  That might not be vital: abandoning
> > that trick will mean they can't optimise read_percpu/read_percpu_var
> > etc as much.
> 
> Isn't something like the following possible?
> 
> #define pcpu_read(ptr)						\
> ({								\
> 	if (__builtin_constant_p(ptr) &&			\
> 	    ptr >= PCPU_STATIC_START && ptr < PCPU_STATIC_END)	\
> 		do 64k TLB trick for static pcpu;		\
> 	else							\
> 		do generic stuff;				\
> })

No, that will be "do generic stuff", since it's a link-time constant.  I don't know that this is a huge worry, to be honest.  We can leave the __ia64_per_cpu_var for their arch-specific code (I feel the same way about x86 to be honest).

> > Tejun, any chance of you updating the tj-percpu tree? My current
> > patches are against Linus's tree, and rebasing them on yours
> > involves some icky merging.
> 
> If Ingo is okay with it, I'm fine with it too.  Unless Ingo objects,
> I'll do it tomorrow-ish (still big holiday here).

Ah, I did not realize that you celebrated Australia day :)

Cheers!
Rusty.
