From: Z Lim <zlim.lnx@gmail.com>
Subject: Re: [PATCH] arm64: bpf: fix JIT stack setup
Date: Sun, 8 Nov 2015 14:29:48 -0800
Message-ID: <CABg9mcv8W4_pvkEQKtjBPi5ycMgLPksYoPtYnGr6tdcb5ER8YQ@mail.gmail.com>
References: <1446874577-14539-1-git-send-email-yang.shi@linaro.org>
	<20151108022726.GB39441@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <ast@kernel.org>, daniel@iogearbox.net,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>, Xi Wang <xi.wang@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	linaro-kernel@lists.linaro.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Yang Shi <yang.shi@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:35282 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750894AbbKHW3t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2015 17:29:49 -0500
In-Reply-To: <20151108022726.GB39441@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 7, 2015 at 6:27 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Fri, Nov 06, 2015 at 09:36:17PM -0800, Yang Shi wrote:
>> ARM64 JIT used FP (x29) as eBPF fp register, but FP is subjected to
>> change during function call so it may cause the BPF prog stack base address
>> change too. Whenever, it pointed to the bottom of BPF prog stack instead of
>> the top.
>>
>> So, when copying data via bpf_probe_read, it will be copied to (SP - offset),
>> then it may overwrite the saved FP/LR.
>>
>> Use x25 to replace FP as BPF stack base register (fp). Since x25 is callee
>> saved register, so it will keep intact during function call.
>> It is initialized in BPF prog prologue when BPF prog is started to run
>> everytime. When BPF prog exits, it could be just tossed.
>>
>> Other than this the BPf prog stack base need to be setup before function
>> call stack.
>>
>> So, the BPF stack layout looks like:
>>
>>                                  high
>>          original A64_SP =>   0:+-----+ BPF prologue
>>                                 |     | FP/LR and callee saved registers
>>          BPF fp register => +64:+-----+
>>                                 |     |
>>                                 | ... | BPF prog stack
>>                                 |     |
>>                                 |     |
>>          current A64_SP =>      +-----+
>>                                 |     |
>>                                 | ... | Function call stack
>>                                 |     |
>>                                 +-----+
>>                                   low
>>
>> Signed-off-by: Yang Shi <yang.shi@linaro.org>
>> CC: Zi Shen Lim <zlim.lnx@gmail.com>
>> CC: Xi Wang <xi.wang@gmail.com>
>
> Thanks for tracking it down.
> That looks like fundamental bug in arm64 jit. I'm surprised function calls worked at all.
> Zi please review.
>

For function calls (BPF_JMP | BPF_CALL), we are compliant with AAPCS64
[1]. That part is okay.


bpf_probe_read accesses the BPF program stack, which is based on BPF_REG_FP.

This exposes an issue with how BPF_REG_FP was setup, as Yang pointed out.
Instead of having BPF_REG_FP point to top of stack, we erroneously
point it to the bottom of stack. When there are function calls, we run
the risk of clobbering of BPF stack. Bad idea.

Otherwise, since BPF_REG_FP is read-only, and is setup exactly once in
prologue, it remains consistent throughout lifetime of the BPF
program.


Yang, can you please try the following?

8<-----
--- a/arch/arm64/net/bpf_jit_comp.c
+++ b/arch/arm64/net/bpf_jit_comp.c
@@ -161,12 +161,12 @@ static void build_prologue(struct jit_ctx *ctx)
        if (ctx->tmp_used)
                emit(A64_PUSH(tmp1, tmp2, A64_SP), ctx);

-       /* Set up BPF stack */
-       emit(A64_SUB_I(1, A64_SP, A64_SP, stack_size), ctx);
-
        /* Set up frame pointer */
        emit(A64_MOV(1, fp, A64_SP), ctx);

+       /* Set up BPF stack */
+       emit(A64_SUB_I(1, A64_SP, A64_SP, stack_size), ctx);
+
        /* Clear registers A and X */
        emit_a64_mov_i64(ra, 0, ctx);
        emit_a64_mov_i64(rx, 0, ctx);
----->8

[1] http://infocenter.arm.com/help/topic/com.arm.doc.ihi0055b/IHI0055B_aapcs64.pdf
