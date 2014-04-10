From: Markos Chandras <Markos.Chandras@imgtec.com>
Subject: Re: [PATCH v2 13/14] MIPS: net: Add BPF JIT
Date: Thu, 10 Apr 2014 09:06:55 +0100
Message-ID: <5346511F.2020808@imgtec.com>
References: <1396957635-27071-14-git-send-email-markos.chandras@imgtec.com>	<1397059208-27096-1-git-send-email-markos.chandras@imgtec.com> <CAADnVQLUKnHOjz55s_W+aVZrsWcJ7-UavJTCnFF7PRzLLnwVyQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-mips@linux-mips.org>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Daniel Borkmann <dborkman@redhat.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailapp01.imgtec.com ([195.89.28.114]:47282 "EHLO
	mailapp01.imgtec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965323AbaDJIGk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2014 04:06:40 -0400
In-Reply-To: <CAADnVQLUKnHOjz55s_W+aVZrsWcJ7-UavJTCnFF7PRzLLnwVyQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alexei,

On 04/10/2014 04:40 AM, Alexei Starovoitov wrote:
> On Wed, Apr 9, 2014 at 9:00 AM, Markos Chandras
> <markos.chandras@imgtec.com> wrote:
>> This adds initial support for BPF-JIT on MIPS
>
> Great work!
>
> btw, net-next is closed and we're waiting to submit classic+internal
> BPF testsuite
> that would have helped in testing and benchmarking.

That would be very useful thanks.

>
>> Benchmarking:
>> - BPF-JIT Disabled
>> real    1m38.005s
>> - BPF-JIT Enabled
>> real    1m35.215s
>
> it's hard to see the difference in a such setup.
> In bpf only tests we see 4-20x speedup from jit.
> I think mips arch should see something similar.
>
> Few questions:
> - why did you implement only this small set of bpf extensions?
>    was there a use case or they were easier comparing to others?

I assume you are referring to the BPF_S_ANC_* opcodes? I may have 
overlooked something. I just compared that to ARM and it seems i 
implemented the same extensions, but it seems I lack a few compared to x86.

>
> - this patch set depends on 12 other patches.
>    would be easier to review if the whole set is cc-ed to netdev

The rest of the patches add uasm instructions so they are not netdev@ 
related. An example of such patch is here.
http://patchwork.linux-mips.org/patch/6725/

>
> - did you consider doing jit over internal bpf?
>    all bpf extensions support would have come for free and it would work
>    for seccomp and tracing filters in the future.
>
Is this the recommended way? (could you point me to some info about 
internal bpf+jit). I pretty much did that other architectures are doing 
at the moment.

> Few comments:
>
>> +#define RSIZE  (sizeof(unsigned long))
>> +#define ptr typeof(unsigned long)
>
> these are odd looking macros.
>
Indeed but the code is aimed to run in 32 and 64-bit processors so i 
needed some kind of abstraction. I open to suggestions.

>> +static inline void emit_bcond(int cond, unsigned int reg1, unsigned int reg2,
>> +                            unsigned int imm, struct jit_ctx *ctx)
>> +{
>> +       if (ctx->target != NULL) {
>> +               u32 *p = &ctx->target[ctx->idx];
>> +
>> +               switch (cond) {
>> +               case MIPS_COND_EQ:
>> +                       uasm_i_beq(&p, reg1, reg2, imm);
>> +                       break;
>> +               case MIPS_COND_NE:
>> +                       uasm_i_bne(&p, reg1, reg2, imm);
>> +                       break;
>> +               case MIPS_COND_ALL:
>> +                       uasm_i_b(&p, imm);
>> +                       break;
>> +               default:
>> +                       pr_warn("%s: Unhandled branch conditional: %d\n",
>> +                               __func__, cond);
>
> shouldn't it be BUG_ON instead?
> can it spam kernel logs?

BUG_ON() can be disabled (CONFIG_BUG) so spamming the log was 
intentional to make sure this will not go unnoticed.

>
>> +static bool is_load_to_a(u16 inst)
>> +{
>> +       switch (inst) {
>> +       case BPF_S_LD_W_LEN:
>> +       case BPF_S_LD_W_ABS:
>> +       case BPF_S_LD_H_ABS:
>> +       case BPF_S_LD_B_ABS:
>> +       case BPF_S_ANC_CPU:
>> +       case BPF_S_ANC_IFINDEX:
>> +       case BPF_S_ANC_MARK:
>> +       case BPF_S_ANC_PROTOCOL:
>> +       case BPF_S_ANC_RXHASH:
>> +       case BPF_S_ANC_VLAN_TAG:
>> +       case BPF_S_ANC_VLAN_TAG_PRESENT:
>> +       case BPF_S_ANC_QUEUE:
>
> it seems this switch() statement handles more extensions
> that actually jitted later. Future proofing?

It's likely i overlooked something again. I will double check.

>
>> +static void save_bpf_jit_regs(struct jit_ctx *ctx, unsigned offset)
>> +{
>> +       int i = 0, real_off = 0;
>> +       u32 sflags, tmp_flags;
>> +
>> +       /* Adjust the stack pointer */
>> +       emit_stack_offset(-align_sp(offset), ctx);
>> +
>> +       if (ctx->flags & SEEN_CALL) {
>> +               /* Argument save area */
>> +               if (config_enabled(CONFIG_64BIT))
>> +                       /* Bottom of current frame */
>> +                       real_off = align_sp(offset) - RSIZE;
>> +               else
>> +                       /* Top of previous frame */
>> +                       real_off = align_sp(offset) + RSIZE;
>> +               emit_store_stack_reg(MIPS_R_A0, r_sp, real_off, ctx);
>> +               emit_store_stack_reg(MIPS_R_A1, r_sp, real_off + RSIZE, ctx);
>> +
>> +               real_off = 0;
>> +       }
>> +
>> +       tmp_flags = sflags = ctx->flags >> SEEN_SREG_SFT;
>> +       /* sflags is essentially a bitmap */
>> +       pr_debug("%s: register flags: 0x%08x\n", __func__, tmp_flags);
>
> that will spam logs. please remove.

This will only spam the logs if you build with -DDEBUG. This is an 
unlikely build situation so spamming the logs is desired because if you 
added -DDEBUG yourself, you need to see as many details as you want 
(same for the rest of pr_debug() calls)


>
>> +static u64 jit_get_skb_b(struct sk_buff *skb, unsigned offset)
>> +{
>> +       u8 ret;
>> +       int err;
>> +
>> +       err = skb_copy_bits(skb, offset, &ret, 1);
>> +
>> +       return (u64)err << 32 | ret;
>> +}
>
> negative offsets are not supported intentionally?
I am sorry. I don't understand what you mean (and this code is identical 
to ARM)

>> +load_ind:
>> +                       update_on_xread(ctx);
>> +                       ctx->flags |= SEEN_OFF | SEEN_X;
>> +                       emit_addiu(r_off, r_X, k, ctx);
>> +               goto load_common;
>
> needs extra tab of formatting
Thanks. I will fix it.

>
>> +               case BPF_S_ANC_VLAN_TAG_PRESENT:
>> +                       ctx->flags |= SEEN_SKB | SEEN_S0 | SEEN_A;
>> +                       BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff,
>> +                                                 vlan_tci) != 2);
>> +                       off = offsetof(struct sk_buff, vlan_tci);
>> +                       emit_half_load(r_s0, r_skb, off, ctx);
>> +                       if (inst->code == BPF_S_ANC_VLAN_TAG)
>
> this branch can never be hit. Did you miss 'case VLAN_TAG' few lines above?

Indeed I did...


>> +
>> +       ctx.skf = fp;
>> +
>> +       if (unlikely(build_body(&ctx)))
>
> why 'unlikely'? this jit doesn't support all extensions
> so it may very well be 'likely' for some use cases.

I will remove it once I add the missing extensions.

>
>> +               goto out;
>> +
>> +       tmp_idx = ctx.idx;
>> +       build_prologue(&ctx);
>> +       ctx.prologue_bytes = (ctx.idx - tmp_idx) * 4;
>> +       /* just to complete the ctx.idx count */
>> +       build_epilogue(&ctx);
>> +
>> +       alloc_size = 4 * ctx.idx;
>> +       ctx.target = module_alloc(alloc_size);
>> +       if (ctx.target == NULL)
>> +               goto out;
>> +
>> +       /* Clean it */
>> +       memset(ctx.target, 0, alloc_size);
>> +
>> +       ctx.idx = 0;
>> +
>> +       /* Generate the actual JIT code */
>> +       build_prologue(&ctx);
>> +       build_body(&ctx);
>
> do you want to add BUG_ON to make sure that 2nd build_body() succeeds?
If the first one managed to succeed why would the second one fail?

Thanks for the review!

-- 
markos
