From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] percpu: add optimized generic percpu accessors
Date: Tue, 27 Jan 2009 11:24:27 +0900
Message-ID: <497E705B.5000302@kernel.org>
References: <20090115183942.GA6325@elte.hu> <200901201328.24605.rusty@rustcorp.com.au> <49756E6E.2060409@kernel.org> <200901271213.18605.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	akpm@linux-foundation.org, hpa@zytor.com, brgerst@gmail.com,
	ebiederm@xmission.com, cl@linux-foundation.org, travis@sgi.com,
	linux-kernel@vger.kernel.org, steiner@sgi.com, hugh@veritas.com,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:47595 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751977AbZA0CZC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jan 2009 21:25:02 -0500
In-Reply-To: <200901271213.18605.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Rusty.

Rusty Russell wrote:

>> No, they're not. They're preempt safe as mentioned in the comment
>> and is basically just generalization of the original x86 versions
>> used by x86_64 on SMP before pda and percpu areas were merged. I
>> agree that it's something very close to local_t and it would be
>> nice to see those somehow unified (and I have patches which make
>> use of local_t in my queue waiting for dynamic percpu allocation).
> 
> Yes, which is one reason I dislike Ingo's patch:
> 1) Mine did just read because that covers the most common fast-path use
> and is easily atomic for word-sizes on all archs,
> 2) Didn't replace x86, just #defined generic one, so much less churn,
> 3) read_percpu_var and read_percpu_ptr variants following the convention
> reinforced by my other patches.
>
> Linus' tree had read/write/add/or counts at 22/13/0/0. Yours has
> more write usage, so I'm happy there, but still only one add and one
> or. If we assume that generic code will look a bit like that when
> converted, I'm not convinced that generic and/or/etc ops are worth
> it.

There actually were quite some places where atomic add ops would be
useful, especially the places where statistics are collected.  For
logical bitops, I don't think we'll have too many of them.

> If they are worth doing generically, should the ops be atomic? To
> extrapolate from x86 usages again, it seems to be happy with
> non-atomic (tho of course it is atomic on x86).

If atomic rw/add/sub are implementible on most archs (and judging from
local_t, I suppose it is), I think it should.  So that it can replace
local_t and we won't need something else again in the future.

>> Another question to ask is whether to keep using separate
>> interfaces for static and dynamic percpu variables or migrate to
>> something which can take both.
>
> Well, IA64 can do stuff with static percpus that it can't do with
> dynamic (assuming we get expanding dynamic percpu areas
> later). That's because they use TLB tricks for a static 64k per-cpu
> area, but this doesn't scale.  That might not be vital: abandoning
> that trick will mean they can't optimise read_percpu/read_percpu_var
> etc as much.

Isn't something like the following possible?

#define pcpu_read(ptr)						\
({								\
	if (__builtin_constant_p(ptr) &&			\
	    ptr >= PCPU_STATIC_START && ptr < PCPU_STATIC_END)	\
		do 64k TLB trick for static pcpu;		\
	else							\
		do generic stuff;				\
})

> Tejun, any chance of you updating the tj-percpu tree? My current
> patches are against Linus's tree, and rebasing them on yours
> involves some icky merging.

If Ingo is okay with it, I'm fine with it too.  Unless Ingo objects,
I'll do it tomorrow-ish (still big holiday here).

Thanks.

-- 
tejun
