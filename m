From: Z Lim <zlim.lnx@gmail.com>
Subject: Re: [PATCH RFC] arm64: eBPF JIT compiler
Date: Wed, 2 Jul 2014 21:57:21 -0700
Message-ID: <CABg9mcsWia-RW9QfSKeiUeTrDJ_cr-gPY7QTmsFWradyB+1Uxg@mail.gmail.com>
References: <1404278424-31176-1-git-send-email-zlim.lnx@gmail.com>
	<CAMEtUuy8Dxzcn1svphvxVEGwSL1yvMuDN8uQC_4d-h3Cw33TfQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	LKML <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMEtUuy8Dxzcn1svphvxVEGwSL1yvMuDN8uQC_4d-h3Cw33TfQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 2, 2014 at 2:28 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> On Tue, Jul 1, 2014 at 10:20 PM, Zi Shen Lim <zlim.lnx@gmail.com> wrote:
>> The JIT compiler emits A64 instructions. It supports eBPF only.
>> Legacy BPF is supported thanks to conversion by BPF core.
>>
>> JIT is enabled in the same way as for other architectures:
>>
>>         echo 1 > /proc/sys/net/core/bpf_jit_enable
>>
>> Or for additional compiler output:
>>
>>         echo 2 > /proc/sys/net/core/bpf_jit_enable
>>
>> See Documentation/networking/filter.txt for more information.
>>
>> The implementation passes all 57 tests in lib/test_bpf.c
>> on ARMv8 Foundation Model :)
>
> Looks great. Comments below:

Thanks for the review :)

>
>> --- a/arch/arm64/Makefile
>> +++ b/arch/arm64/Makefile
>> @@ -43,6 +43,7 @@ TEXT_OFFSET := 0x00080000
>>  export TEXT_OFFSET GZFLAGS
>>
>>  core-y         += arch/arm64/kernel/ arch/arm64/mm/
>> +core-y         += arch/arm64/net/
>
> please use instead:
> core-$(CONFIG_NET)

Ok, will update.

>
>> +
>> +#define BITSMASK(bits) ((1 << (bits)) - 1)
>
> there is GENMASK macro already.

    #define GENMASK(h, l)           (((U32_C(1) << ((h) - (l) + 1)) - 1) << (l))

I guess I could replace everywhere with GENMASK(x, 0).

>
>> +/* Compare & branch (immediate) */
>> +static inline u32 A64_COMP_BRANCH_IMM(int sf, int op, int imm19, int Rt)
>
> odd function name. lower case it?

Sure, will update.

>
>> +/* Conditional branch (immediate) */
>> +static inline u32 A64_COND_BRANCH_IMM(int o1, int imm19, int o0, int cond)
>
> same and in several other places.
> I guess you're trying to make the usage look similar for macro and function
> calls. I don't think the look-alike is worth it. Functions should be lower case.

Ditto.

>
>> +#define EMIT(insn) emit(insn, ctx)
>
> extra macro just to save one argument? I would add ...,ctx) explicitly.

Ok, I'll consider it.

>
>> +#define EMIT_A64_MOV_I64(reg, val) emit_A64_MOV_I64(reg, val, ctx)
>
> same here and in other cases.

Ditto.

>
>> +static void build_prologue(struct jit_ctx *ctx)
>> +{
>> +       const u8 r6 = bpf2a64[BPF_REG_6];
>> +       const u8 r7 = bpf2a64[BPF_REG_7];
>> +       const u8 r8 = bpf2a64[BPF_REG_8];
>> +       const u8 r9 = bpf2a64[BPF_REG_9];
>> +       const u8 fp = bpf2a64[BPF_REG_FP];
>> +       const u8 ra = bpf2a64[BPF_REG_A];
>> +       const u8 rx = bpf2a64[BPF_REG_X];
>> +       const u8 tmp1 = bpf2a64[TMP_REG_1];
>> +       const u8 tmp2 = bpf2a64[TMP_REG_2];
>> +       int stack_size = MAX_BPF_STACK;
>> +
>> +       stack_size += 16; /* extra for skb_copy_bit buffer */
>
> why extra 16? skb_copy_bits is called with max len 4

The ARM Architecture Procedural Call Standard states that stack must
be quad-word (16B) aligned. I can add a comment here for clarity.

>
>> +       /* Save callee-saved register */
>> +       EMIT(A64_PUSH(r6, r7, A64_SP));
>
> simd style double push requires consecutive registers or not? Just curious.

For storing register pair, any two registers, doesn't have to be consecutive.

>
>> +/* From load_pointer in net/core/filter.c.
>> + * XXX: should we just export it? */
>> +extern void *bpf_internal_load_pointer_neg_helper(const struct sk_buff *skb,
>> +                                                 int k, unsigned int size);
>> +static void *load_pointer_helper(const struct sk_buff *skb, int k,
>> +                                unsigned int size, void *buffer)
>
> That's an interesting way of supporting negative offsets!

:)

> probably makes sense to move load_pointer() from net/core/filter.c into filter.h
> and export bpf_internal_load_pointer_neg_helper() in filter.h as well,

Sounds good, I'll do that.

> but I'm not sure which tree you want this stuff to go through.
> If it's arm tree, then it's better to keep things as you did and do a
> cleanup patch
> later. If net-next, then it's better to do it cleanly right away.

I'm thinking going through net-next makes more sense at this point, as
it's easier to keep up with BPF changes (I actually ran into renamed
variable when I rebased prior to posting RFC). Of course, we'd need
Ack's from arm64 maintainers.

Any advice on next steps for net-next?

>
>> +       case BPF_ALU | BPF_MOD | BPF_X:
>> +       case BPF_ALU64 | BPF_MOD | BPF_X:
>> +               ctx->tmp_used = 1;
>> +               EMIT(A64_UDIV(is64, tmp, dst, src));
>> +               EMIT(A64_MUL(is64, tmp, tmp, src));
>> +               EMIT(A64_SUB(is64, dst, dst, tmp));
>> +               break;
>
> there needs to be run-time check for src == 0

Are you concerned about divide-by-zero case?
AFAICT, based on comment in x86 code, when src==0, return 0.
This is in fact the behavior of the UDIV instruction in A64, so no
need for the additional comparison and branch :)

>
>> +       /* dst = dst OP imm */
>> +       case BPF_ALU | BPF_ADD | BPF_K:
>> +       case BPF_ALU64 | BPF_ADD | BPF_K:
>> +               ctx->tmp_used = 1;
>> +               EMIT_A64_MOV_I(is64, tmp, imm);
>> +               EMIT(A64_ADD(is64, dst, dst, tmp));
>> +               break;
>
> Potential for future optimizations on small immediate?

Yup. This can be part of the "phase 2 implementation" I mentioned
under "PENDING" :)

>
>> +       /* function call */
>> +       case BPF_JMP | BPF_CALL:
>> +       {
>> +               const u8 r0 = bpf2a64[BPF_REG_0];
>> +               const u64 func = (u64)__bpf_call_base + imm;
>> +
>> +               ctx->tmp_used = 1;
>> +               EMIT_A64_MOV_I64(tmp, func);
>> +               EMIT(A64_PUSH(A64_FP, A64_LR, A64_SP));
>> +               EMIT(A64_MOV(1, A64_FP, A64_SP));
>> +               EMIT(A64_BLR(tmp));
>
> Aren't on arm64 kernel and module_alloc() addresses in the same 32-bit range?

I don't know the answer OTOH, will need to double check.

> Do you really need 'jump by register' then? Regular 'bl' would be much faster.

We'll need BLR to cover all cases. BL instruction can only address
+/-128MB (28-bits).

BTW, what is the range of "imm" for JMP|CALL? I'm guessing since it's
s32, so +/-512MB?

>
>> +       /* R0 = ntohx(*(size *)(((struct sk_buff *)R6)->data + imm)) */
>> +       case BPF_LD | BPF_ABS | BPF_W:
>> +       case BPF_LD | BPF_ABS | BPF_H:
>> +       case BPF_LD | BPF_ABS | BPF_B:
>> +       case BPF_LD | BPF_ABS | BPF_DW:
>
> there is no such LD_ABS + DW instruction yet.
> Would be trivial to add, but let's not rush it in just because it's so easy.

Oops, I jumped the gun. Will remove it.

>
>> +       /* R0 = ntohx(*(size *)(((struct sk_buff *)R6)->data + src + imm)) */
>> +       case BPF_LD | BPF_IND | BPF_W:
>> +       case BPF_LD | BPF_IND | BPF_H:
>> +       case BPF_LD | BPF_IND | BPF_B:
>> +       case BPF_LD | BPF_IND | BPF_DW:
>> +       {
>> +               const u8 r0 = bpf2a64[BPF_REG_0]; /* r0 = return value */
>> +               const u8 r6 = bpf2a64[BPF_REG_6]; /* r6 = pointer to sk_buff */
>> +               const u8 fp = bpf2a64[BPF_REG_FP];
>> +               const u8 r1 = bpf2a64[BPF_REG_1]; /* r1: struct sk_buff *skb */
>> +               const u8 r2 = bpf2a64[BPF_REG_2]; /* r2: int k */
>> +               const u8 r3 = bpf2a64[BPF_REG_3]; /* r3: unsigned int size */
>> +               const u8 r4 = bpf2a64[BPF_REG_4]; /* r4: void *buffer */
>> +               const u8 r5 = bpf2a64[BPF_REG_5]; /* r5: void *(*func)(...) */
>> +               int size;
>> +
>> +               EMIT(A64_MOV(1, r1, r6));
>> +               EMIT_A64_MOV_I(0, r2, imm);
>> +               if (BPF_MODE(code) == BPF_IND)
>> +                       EMIT(A64_ADD(0, r2, r2, src));
>> +               switch (BPF_SIZE(code)) {
>> +               case BPF_W:
>> +                       size = 4;
>> +                       break;
>> +               case BPF_H:
>> +                       size = 2;
>> +                       break;
>> +               case BPF_B:
>> +                       size = 1;
>> +                       break;
>> +               case BPF_DW:
>> +                       size = 8;
>
> there is no DW in ld_abs/ld_ind. Let's not rush it in.

Ditto.

BTW, I didn't see a ALU64|END in x86 code. Curious if we'll only have ALU|END...

>
>> +notyet:
>> +               pr_info("*** NOT YET: opcode %02x ***\n", code);
>> +               return -EFAULT;
>
> It's ok to implement JIT support step by step.

Ok, in that case, I guess it's okay to delay implementation of
STX|XADD and ST|MEM as noted in my "TODO". I'll wait until
corresponding test cases gets added into test_bpf.

> Just change pr_info() to pr_info_once() not to spam the logs.

Sounds good. Will do.

>
>> +       default:
>> +               pr_err("unknown opcode %02x\n", code);
>
> same.

Ditto.

>
> Overall looks great. Thank you for doing all this work!

Thanks again for the quick review. It's a fun project for me :)
eBPF has great potential - thank you and other developers!

>
> Alexei
