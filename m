From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next RFC] Generic XDP
Date: Tue, 18 Apr 2017 14:46:25 -0400 (EDT)
Message-ID: <20170418.144625.406577615158455684.davem@davemloft.net>
References: <20170416222601.671f037c@redhat.com>
        <20170417.154955.1624611510140672627.davem@davemloft.net>
        <20170417230436.GA96258@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, kubakici@wp.pl, netdev@vger.kernel.org,
        xdp-newbies@vger.kernel.org
To: alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43218 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751424AbdDRSqa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 14:46:30 -0400
In-Reply-To: <20170417230436.GA96258@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Mon, 17 Apr 2017 16:04:38 -0700

> On Mon, Apr 17, 2017 at 03:49:55PM -0400, David Miller wrote:
>> From: Jesper Dangaard Brouer <brouer@redhat.com>
>> Date: Sun, 16 Apr 2017 22:26:01 +0200
>> 
>> > The bpf tail-call use-case is a very good example of why the
>> > verifier cannot deduct the needed HEADROOM upfront.
>> 
>> This brings up a very interesting question for me.
>> 
>> I notice that tail calls are implemented by JITs largely by skipping
>> over the prologue of that destination program.
>> 
>> However, many JITs preload cached SKB values into fixed registers in
>> the prologue.  But they only do this if the program being JITed needs
>> those values.
>> 
>> So how can it work properly if a program that does not need the SKB
>> values tail calls into one that does?
> 
> For x86 JIT it's fine, since caching of skb values is not part of the prologue:
>   emit_prologue(&prog);
>   if (seen_ld_abs)
>           emit_load_skb_data_hlen(&prog);
> and tail_call jumps into the next program as:
>   EMIT4(0x48, 0x83, 0xC0, PROLOGUE_SIZE);   /* add rax, prologue_size */
>   EMIT2(0xFF, 0xE0);                        /* jmp rax */
> whereas inside emit_prologue() we have:
> B  UILD_BUG_ON(cnt != PROLOGUE_SIZE);
> 
> arm64 has similar proplogue skipping code and it's even
> simpler than x86, since it doesn't try to optimize LD_ABS/IND in assembler
> and instead calls into bpf_load_pointer() from generated code,
> so no caching of skb values at all.
> 
> s390 jit has partial skipping of prologue, since bunch
> of registers are save/restored during tail_call and it looks fine
> to me as well.

Ok, what about stack usage?

Currently if I don't see a reference to FP then I elide allocating
MAX_BPF_STACK stack space.

What if, with tail calls, some programs need that stack space whilst
other's done?

It looks like, for example, JITs like powerpc avoids this issue
because they allocate the full MAX_BPF_STACK all the time.  That seems
like overkill to me and bad for cache locality.
