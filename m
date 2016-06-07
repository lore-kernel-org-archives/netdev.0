From: Z Lim <zlim.lnx@gmail.com>
Subject: Re: [PATCH net-next 2/3] arm64: bpf: optimize JMP_CALL
Date: Mon, 6 Jun 2016 21:36:03 -0700
Message-ID: <CABg9mcvXxAvWxuXJbBbQEy5_nsgPjT6Y20CFNKMkOYJp4NrnFQ@mail.gmail.com>
References: <1465077630-633-1-git-send-email-zlim.lnx@gmail.com>
 <1465077630-633-2-git-send-email-zlim.lnx@gmail.com> <20160606170515.GK669@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Yang Shi <yang.shi@linaro.org>,
	Alexei Starovoitov <ast@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Network Development <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Will Deacon <will.deacon@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:35098 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751118AbcFGEgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 00:36:05 -0400
In-Reply-To: <20160606170515.GK669@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Will,

On Mon, Jun 6, 2016 at 10:05 AM, Will Deacon <will.deacon@arm.com> wrote:
> On Sat, Jun 04, 2016 at 03:00:29PM -0700, Zi Shen Lim wrote:
>> Remove superfluous stack frame, saving us 3 instructions for
>> every JMP_CALL.
>>
>> Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>
>> ---
>>  arch/arm64/net/bpf_jit_comp.c | 3 ---
>>  1 file changed, 3 deletions(-)
>>
>> diff --git a/arch/arm64/net/bpf_jit_comp.c b/arch/arm64/net/bpf_jit_comp.c
>> index 51abc97..7ae304e 100644
>> --- a/arch/arm64/net/bpf_jit_comp.c
>> +++ b/arch/arm64/net/bpf_jit_comp.c
>> @@ -578,11 +578,8 @@ emit_cond_jmp:
>>               const u64 func = (u64)__bpf_call_base + imm;
>>
>>               emit_a64_mov_i64(tmp, func, ctx);
>> -             emit(A64_PUSH(A64_FP, A64_LR, A64_SP), ctx);
>> -             emit(A64_MOV(1, A64_FP, A64_SP), ctx);
>>               emit(A64_BLR(tmp), ctx);
>>               emit(A64_MOV(1, r0, A64_R(0)), ctx);
>> -             emit(A64_POP(A64_FP, A64_LR, A64_SP), ctx);
>>               break;
>>       }
>
> Is the jitted code intended to be unwindable by standard tools?

Before this patch:
    bpf_prologue => push stack frame
    ...
    jmp_call => push stack frame, call bpf_helper*, pop stack frame
    ...
    bpf_epilogue => pop stack frame, ret

Now:
    bpf_prologue => push stack frame
    ...
    jmp_call => call bpf_helper*
    ...
    bpf_epilogue => pop stack frame, ret

*Note: bpf_helpers in kernel/bpf/helper.c

So yes, it's still unwindable.

>
> Will
