From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net] bpf: x86: fix epilogue generation for eBPF programs
Date: Thu, 27 Nov 2014 21:55:40 -0800
Message-ID: <CAMEtUuyzDs2Nz8WHdEZXmY9JOZx=w2UwUF06Kq5qcgkaaRKs3A@mail.gmail.com>
References: <1417064546-4129-1-git-send-email-ast@plumgrid.com>
	<5476F471.80500@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Zi Shen Lim <zlim.lnx@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:55415 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750832AbaK1Fzl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2014 00:55:41 -0500
Received: by mail-qg0-f42.google.com with SMTP id z107so4391618qgd.15
        for <netdev@vger.kernel.org>; Thu, 27 Nov 2014 21:55:41 -0800 (PST)
In-Reply-To: <5476F471.80500@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 27, 2014 at 1:52 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> On 11/27/2014 06:02 AM, Alexei Starovoitov wrote:
>>
>> classic BPF has a restriction that last insn is always BPF_RET.
>> eBPF doesn't have BPF_RET instruction and this restriction.
>> It has BPF_EXIT insn which can appear anywhere in the program
>> one or more times and it doesn't have to be last insn.
>> Fix eBPF JIT to emit epilogue when first BPF_EXIT is seen
>> and all other BPF_EXIT instructions will be emitted as jump.
>>
>> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
>> ---
>> Note, this bug is applicable only to native eBPF programs
>> which first were introduced in 3.18, so no need to send it
>> to stable and therefore no 'Fixes' tag.
>
>
> Btw, even if it's not sent to -stable, a 'Fixes:' tag is useful
> information for backporting and regression tracking, preferably
> always mentioned where it can clearly be identified.

Well I didn't mention it, as I said, because I don't think it
needs backporting. Otherwise with the tag the tools might
pick it up automatically? Just a guess.
Anyway:
Fixes: 622582786c9e ("net: filter: x86: internal BPF JIT")

>> arm64 JIT has the same problem, but the fix is not as trivial,
>> so will be done as separate patch.
>>
>> Since 3.18 can only load eBPF programs and cannot execute them,
>> this patch can even be done in net-next only, but I think it's worth
>> to apply it to 3.18(net), so that JITed output for native eBPF
>> programs is correct when bpf syscall loads it with
>> net.core.bpf_jit_enable=2
>
>
> Yes, sounds good to me, the condition insn_cnt - 1 is still held
> with BPF to eBPF transformations.

Correct. That's what I meant that prior to 3.18 it's not needed.
and 'insn_cnt - 1' condition will still hold for classic in the future.

>>   arch/x86/net/bpf_jit_comp.c |    6 ++++--
>>   1 file changed, 4 insertions(+), 2 deletions(-)
>>
>> diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
>> index 3f62734..7e90244 100644
>> --- a/arch/x86/net/bpf_jit_comp.c
>> +++ b/arch/x86/net/bpf_jit_comp.c
>> @@ -178,7 +178,7 @@ static void jit_fill_hole(void *area, unsigned int
>> size)
>>   }
>>
>>   struct jit_context {
>> -       unsigned int cleanup_addr; /* epilogue code offset */
>> +       int cleanup_addr; /* epilogue code offset */
>
>
> Why this type change here? This seems a bit out of context (I would
> have expected a mention of this in the commit message, otherwise).

Ok. Will respin with updated commit msg.
The reason for signed is the following:
jmp offset to epilogue is computed as:
jmp_offset = ctx->cleanup_addr - addrs[i]
when cleanup_addr was always last insn it wasn't a problem,
since result of subtraction was positive.
Now, since epilogue will be in the middle of JITed
code the jmps to epilogue may be negative, so
signed int is need to do the math correctly.
In other words, it should be:
(long long) ((int)20 - (int)30)
instead of:
(long long) ((unsigned int)20 - (int)30)
