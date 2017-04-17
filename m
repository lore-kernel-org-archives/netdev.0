From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v3 net-next RFC] Generic XDP
Date: Tue, 18 Apr 2017 01:33:48 +0200
Message-ID: <58F550DC.3050200@iogearbox.net>
References: <20170414153032.2b3e1a5c@cakuba.lan> <20170415004642.GA73685@ast-mbp.thefacebook.com> <20170416222601.671f037c@redhat.com> <20170417.154955.1624611510140672627.davem@davemloft.net> <20170417230436.GA96258@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, kubakici@wp.pl, netdev@vger.kernel.org,
        xdp-newbies@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46807 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752050AbdDQXdz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 19:33:55 -0400
In-Reply-To: <20170417230436.GA96258@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/18/2017 01:04 AM, Alexei Starovoitov wrote:
> On Mon, Apr 17, 2017 at 03:49:55PM -0400, David Miller wrote:
>> From: Jesper Dangaard Brouer <brouer@redhat.com>
>> Date: Sun, 16 Apr 2017 22:26:01 +0200
>>
>>> The bpf tail-call use-case is a very good example of why the
>>> verifier cannot deduct the needed HEADROOM upfront.
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
>    emit_prologue(&prog);
>    if (seen_ld_abs)
>            emit_load_skb_data_hlen(&prog);
> and tail_call jumps into the next program as:
>    EMIT4(0x48, 0x83, 0xC0, PROLOGUE_SIZE);   /* add rax, prologue_size */
>    EMIT2(0xFF, 0xE0);                        /* jmp rax */
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

And ppc64 does unwinding/tearing down the stack of the prog before
jumping into the other program. Thus, no skipping of others prologue;
looks fine, too.

> It's very hard to extend test_bpf.ko with tail_calls, since maps need
> to be allocated and populated with file descriptors which are
> not feasible to do from .ko. Instead we need a user space based test for it.
> We've started building one in tools/testing/selftests/bpf/test_progs.c
> much more tests need to be added. Thorough testing of tail_calls
> is on the todo list.
