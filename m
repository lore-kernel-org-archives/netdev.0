From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v3 net-next RFC] Generic XDP
Date: Tue, 18 Apr 2017 16:05:51 -0700
Message-ID: <20170418230549.GB65449@ast-mbp.thefacebook.com>
References: <20170416222601.671f037c@redhat.com>
 <20170417.154955.1624611510140672627.davem@davemloft.net>
 <20170417230436.GA96258@ast-mbp.thefacebook.com>
 <20170418.144625.406577615158455684.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: brouer@redhat.com, kubakici@wp.pl, netdev@vger.kernel.org,
        xdp-newbies@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:36012 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757924AbdDRXGA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 19:06:00 -0400
Content-Disposition: inline
In-Reply-To: <20170418.144625.406577615158455684.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 18, 2017 at 02:46:25PM -0400, David Miller wrote:
> From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
> Date: Mon, 17 Apr 2017 16:04:38 -0700
> 
> > On Mon, Apr 17, 2017 at 03:49:55PM -0400, David Miller wrote:
> >> From: Jesper Dangaard Brouer <brouer@redhat.com>
> >> Date: Sun, 16 Apr 2017 22:26:01 +0200
> >> 
> >> > The bpf tail-call use-case is a very good example of why the
> >> > verifier cannot deduct the needed HEADROOM upfront.
> >> 
> >> This brings up a very interesting question for me.
> >> 
> >> I notice that tail calls are implemented by JITs largely by skipping
> >> over the prologue of that destination program.
> >> 
> >> However, many JITs preload cached SKB values into fixed registers in
> >> the prologue.  But they only do this if the program being JITed needs
> >> those values.
> >> 
> >> So how can it work properly if a program that does not need the SKB
> >> values tail calls into one that does?
> > 
> > For x86 JIT it's fine, since caching of skb values is not part of the prologue:
> >   emit_prologue(&prog);
> >   if (seen_ld_abs)
> >           emit_load_skb_data_hlen(&prog);
> > and tail_call jumps into the next program as:
> >   EMIT4(0x48, 0x83, 0xC0, PROLOGUE_SIZE);   /* add rax, prologue_size */
> >   EMIT2(0xFF, 0xE0);                        /* jmp rax */
> > whereas inside emit_prologue() we have:
> > B  UILD_BUG_ON(cnt != PROLOGUE_SIZE);
> > 
> > arm64 has similar proplogue skipping code and it's even
> > simpler than x86, since it doesn't try to optimize LD_ABS/IND in assembler
> > and instead calls into bpf_load_pointer() from generated code,
> > so no caching of skb values at all.
> > 
> > s390 jit has partial skipping of prologue, since bunch
> > of registers are save/restored during tail_call and it looks fine
> > to me as well.
> 
> Ok, what about stack usage?
> 
> Currently if I don't see a reference to FP then I elide allocating
> MAX_BPF_STACK stack space.
> 
> What if, with tail calls, some programs need that stack space whilst
> other's done?
> 
> It looks like, for example, JITs like powerpc avoids this issue
> because they allocate the full MAX_BPF_STACK all the time.  That seems
> like overkill to me and bad for cache locality.

For x86 we also give proper stack frame always, since optimizing
for leaf functions is very rare. Most eBPF progs have at least
one helper call. Even cBPF often use SKF_AD_CPU or SKF_AD_RANDOM
which translate to function call as well and need stack frame.
I think stack frames on sparc are much more expensive than on x86
due to register window architecture, so there it may make sense
to squeeze these extra cycles, but it will be rarely exercised
in practice.

I was thinking to teach verifier to recognize required stack size,
so we can JIT with that size instead of 512, but that's mainly
to reduce kernel stack usage. I doubt it will make any performance
difference.

As far as big sparc and other archs JIT optimizations would be
great somehow to take advantage of extra registers that these
archs have. I think it will only be possible once we have
verifier 2.0 with proper register liveness and stuff, so
we can convert spill/fills into register copies and may be
even run simple regalloc pass after verifier. Crazy talk ;)
