From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] bpf, arm64: implement jiting of BPF_XADD
Date: Tue, 06 Jun 2017 11:50:51 +0200
Message-ID: <59367AFB.6060703@iogearbox.net>
References: <47ce6fc238596120f02fb6c7116f05b30be2f377.1493599299.git.daniel@iogearbox.net> <20170602120212.GF6371@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, zlim.lnx@gmail.com, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, ast@fb.com,
        peterz@infradead.org
To: Will Deacon <will.deacon@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45999 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751274AbdFFJu5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 05:50:57 -0400
In-Reply-To: <20170602120212.GF6371@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Will,

(Sorry for the late reply, was offline for the last 6 days.)

> On Mon, May 01, 2017 at 02:57:20AM +0200, Daniel Borkmann wrote:
>> This work adds BPF_XADD for BPF_W/BPF_DW to the arm64 JIT and therefore
>> completes JITing of all BPF instructions, meaning we can thus also remove
>> the 'notyet' label and do not need to fall back to the interpreter when
>> BPF_XADD is used in a program!
>>
>> This now also brings arm64 JIT in line with x86_64, s390x, ppc64, sparc64,
>> where all current eBPF features are supported.
>>
>> BPF_W example from test_bpf:
>>
>>    .u.insns_int = {
>>      BPF_ALU32_IMM(BPF_MOV, R0, 0x12),
>>      BPF_ST_MEM(BPF_W, R10, -40, 0x10),
>>      BPF_STX_XADD(BPF_W, R10, R0, -40),
>>      BPF_LDX_MEM(BPF_W, R0, R10, -40),
>>      BPF_EXIT_INSN(),
>>    },
>>
>>    [...]
>>    00000020:  52800247  mov w7, #0x12 // #18
>>    00000024:  928004eb  mov x11, #0xffffffffffffffd8 // #-40
>>    00000028:  d280020a  mov x10, #0x10 // #16
>>    0000002c:  b82b6b2a  str w10, [x25,x11]
>>    // start of xadd mapping:
>>    00000030:  928004ea  mov x10, #0xffffffffffffffd8 // #-40
>>    00000034:  8b19014a  add x10, x10, x25
>>    00000038:  f9800151  prfm pstl1strm, [x10]
>>    0000003c:  885f7d4b  ldxr w11, [x10]
>>    00000040:  0b07016b  add w11, w11, w7
>>    00000044:  880b7d4b  stxr w11, w11, [x10]
>
> This form of STXR (where s == t) is CONSTRAINED UNPREDICTABLE per the
> architecture; you need to use separate registers for the data and the
> status flag. You might also be interested in the atomic instructions

Thanks! I tried to find some information on this in the reference
guide, but seems I must have overlooked something; should have been
conservative instead. I will send a fix for it later today.

> introduced in ARMv8.1, which includes the LDADD instruction. You can
> check elf_hwcap & HWCAP_ATOMICS to see if it's supported.

Will take a look on this as well, thanks for letting me know.

> Also, did we get a conclusion on the barrier semantics for this? Currently
> you don't have any here: is that ok?

As a basis I took the disasm back then for the atomic_add() /
atomic64_add(), which, iirc, was mapping to ATOMIC_OP() in
atomic_ll_sc.h. This should be equivalent to what the interpreter
does in __bpf_prog_run() for the insns BPF_STX | BPF_XADD | BPF_W
and BPF_STX | BPF_XADD | BPF_DW.

Thanks,
Daniel
