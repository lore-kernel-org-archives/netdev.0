From: Rabin Vincent <rabin@rab.in>
Subject: Re: [PATCH v5] ARM: net: JIT compiler for packet filters
Date: Tue, 27 Dec 2011 22:59:45 +0530
Message-ID: <CAH+eYFAaxcmc-SZtXJUCUrhfRe+qKSW6ieY5jkxAALQmzHwAOw@mail.gmail.com>
References: <1324601625-20351-1-git-send-email-mgherzan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel@lists.infradead.org, linux@arm.linux.org.uk,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Mircea Gherzan <mgherzan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:54904 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754645Ab1L0Ra1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 12:30:27 -0500
Received: by iaeh11 with SMTP id h11so20669907iae.19
        for <netdev@vger.kernel.org>; Tue, 27 Dec 2011 09:30:26 -0800 (PST)
In-Reply-To: <1324601625-20351-1-git-send-email-mgherzan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 23, 2011 at 06:23, Mircea Gherzan <mgherzan@gmail.com> wrot=
e:
> Based of Matt Evans's PPC64 implementation.
>
> The compiler generates ARM instructions but interworking is
> supported for Thumb2 kernels.
>
> Supports both little and big endian. Unaligned loads are emitted
> for ARMv6+. Not all the BPF opcodes that deal with ancillary data
> are supported. The scratch memory of the filter lives on the stack.
> Hardware integer division is used if it is available.
>
> Enabled in the same way as for x86-64 and PPC64:
>
> =A0 =A0 =A0 =A0echo 1 > /proc/sys/net/core/bpf_jit_enable
>
> A value greater than 1 enables opcode output.
>
> Signed-off-by: Mircea Gherzan <mgherzan@gmail.com>
> ---

I've had a somewhat incomplete version of this (supporting ARMV6+ only,
but Thumb-2 too) sitting around for a while since I wasn't happy with
the amount of testing I gave it.

Anyway, I was able to use the tests I did already have to find some bug=
s
in this patch.

The failures are from test code which generates packets to cover all
possible paths for some test filters and then compares the result (only
the final return value) against the interpreter.  I only ran it for
ARMv7 with no frame pointers.

> +/*
> + * Emit an instruction that will be executed unconditionally.
> + */
> +static inline void emit(u32 inst, struct jit_ctx *ctx)
> +{
> + =A0 =A0 =A0 _emit(ARM_COND_AL, inst, ctx);
> +}
> +
> +static u16 saved_regs(struct jit_ctx *ctx)
> +{
> + =A0 =A0 =A0 u16 ret =3D 0;
> +
> + =A0 =A0 =A0 if (ctx->skf->len > 1)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret |=3D 1 << r_A;
> +

TEST 6 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
BPF_STMT(BPF_RET+BPF_A, 0),
Code: e3a04000 e1a00004 e12fff1e (0000000000)
(0) retinterp 0 retjit 0
+OK
qemu: uncaught target signal 11 (Segmentation fault) - core dumped

All code
=3D=3D=3D=3D=3D=3D=3D=3D
   0:	e3a04000 	mov	r4, #0	<- clobber
   4:	e1a00004 	mov	r0, r4
   8:	e12fff1e 	bx	lr

> +#ifdef CONFIG_FRAME_POINTER
> + =A0 =A0 =A0 ret |=3D (1 << ARM_FP) | (1 << ARM_IP) | (1 << ARM_LR) =
| (1 << ARM_PC);
> +#else
> + =A0 =A0 =A0 if (ctx->seen & SEEN_CALL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret |=3D 1 << ARM_LR;
> +#endif
> + =A0 =A0 =A0 if (ctx->seen & (SEEN_DATA | SEEN_SKB))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret |=3D 1 << r_skb;
> + =A0 =A0 =A0 if (ctx->seen & SEEN_DATA)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret |=3D (1 << r_skb_data) | (1 << r_sk=
b_hl);
> + =A0 =A0 =A0 if (ctx->seen & SEEN_X)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret |=3D 1 << r_X;
> +
> + =A0 =A0 =A0 return ret;
> +}
> +
> +static inline int mem_words_used(struct jit_ctx *ctx)
> +{
> + =A0 =A0 =A0 u32 words =3D ctx->seen & SEEN_MEM;
> + =A0 =A0 =A0 /* yes, we do waste some stack space IF there are "hole=
s" in the set" */
> + =A0 =A0 =A0 return 32 - __builtin_clz(words);

You could use fls(words) here.

> +}
> +
> +static inline bool is_load_to_a(u16 inst)
> +{
> + =A0 =A0 =A0 switch (inst) {
> + =A0 =A0 =A0 case BPF_S_LD_W_LEN:
> + =A0 =A0 =A0 case BPF_S_LD_W_ABS:
> + =A0 =A0 =A0 case BPF_S_LD_H_ABS:
> + =A0 =A0 =A0 case BPF_S_LD_B_ABS:
> + =A0 =A0 =A0 case BPF_S_ANC_CPU:
> + =A0 =A0 =A0 case BPF_S_ANC_IFINDEX:
> + =A0 =A0 =A0 case BPF_S_ANC_MARK:
> + =A0 =A0 =A0 case BPF_S_ANC_PROTOCOL:
> + =A0 =A0 =A0 case BPF_S_ANC_RXHASH:
> + =A0 =A0 =A0 case BPF_S_ANC_QUEUE:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return true;
> + =A0 =A0 =A0 default:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;
> + =A0 =A0 =A0 }
> +}
> +
> +static void build_prologue(struct jit_ctx *ctx)
> +{
> + =A0 =A0 =A0 u16 reg_set =3D saved_regs(ctx);
> + =A0 =A0 =A0 u16 first_inst =3D ctx->skf->insns[0].code;
> + =A0 =A0 =A0 u16 off;
> +
> +#ifdef CONFIG_FRAME_POINTER
> + =A0 =A0 =A0 emit(ARM_MOV_R(ARM_IP, ARM_SP), ctx);
> + =A0 =A0 =A0 emit(ARM_PUSH(reg_set), ctx);
> + =A0 =A0 =A0 emit(ARM_SUB_I(ARM_FP, ARM_IP, 4), ctx);
> +#else
> + =A0 =A0 =A0 if (reg_set)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(ARM_PUSH(reg_set), ctx);
> +#endif
> +
> + =A0 =A0 =A0 if (ctx->seen & (SEEN_DATA | SEEN_SKB))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(ARM_MOV_R(r_skb, ARM_R0), ctx);
> +
> + =A0 =A0 =A0 if (ctx->seen & SEEN_DATA) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 off =3D offsetof(struct sk_buff, data);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(ARM_LDR_I(r_skb_data, r_skb, off),=
 ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* headlen =3D len - data_len */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 off =3D offsetof(struct sk_buff, len);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(ARM_LDR_I(r_skb_hl, r_skb, off), c=
tx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 off =3D offsetof(struct sk_buff, data_l=
en);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(ARM_LDR_I(r_scratch, r_skb, off), =
ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(ARM_SUB_R(r_skb_hl, r_skb_hl, r_sc=
ratch), ctx);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (ctx->seen & SEEN_X)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(ARM_MOV_I(r_X, 0), ctx);
> +
> + =A0 =A0 =A0 /* do not leak kernel data to userspace */
> + =A0 =A0 =A0 if ((first_inst !=3D BPF_S_RET_K) && !(is_load_to_a(fir=
st_inst)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(ARM_MOV_I(r_A, 0), ctx);
> +
> + =A0 =A0 =A0 /* stack space for the BPF_MEM words */
> + =A0 =A0 =A0 if (ctx->seen & SEEN_MEM)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(ARM_SUB_I(ARM_SP, ARM_SP, mem_word=
s_used(ctx) * 4), ctx);
> +}
> +
> +static void build_epilogue(struct jit_ctx *ctx)
> +{
> + =A0 =A0 =A0 u16 reg_set =3D saved_regs(ctx);
> +
> + =A0 =A0 =A0 if (ctx->seen & SEEN_MEM)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(ARM_ADD_I(ARM_SP, ARM_SP, mem_word=
s_used(ctx) * 4), ctx);
> +
> + =A0 =A0 =A0 reg_set &=3D ~(1 << ARM_LR);
> +
> +#ifdef CONFIG_FRAME_POINTER
> + =A0 =A0 =A0 /* the first instruction of the prologue was: mov ip, s=
p */
> + =A0 =A0 =A0 reg_set &=3D ~(1 << ARM_IP);
> + =A0 =A0 =A0 reg_set |=3D (1 << ARM_SP);
> + =A0 =A0 =A0 emit(ARM_LDM(ARM_SP, reg_set), ctx);
> +#else
> + =A0 =A0 =A0 if (ctx->seen) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ctx->seen & SEEN_CALL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 reg_set |=3D 1 << ARM_P=
C;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(ARM_POP(reg_set), ctx);
> + =A0 =A0 =A0 }

TEST 9 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
BPF_STMT(BPF_ALU+BPF_ADD+BPF_K, 1000),
BPF_STMT(BPF_RET+BPF_A, 0)
Code: e92d0010 e3a04000 e2844ffa e1a00004 e12fff1e (0000000000)
(0) retinterp 0x3e8 retjit 0x3e8
+OK
qemu: uncaught target signal 11 (Segmentation fault) - core dumped

All code
=3D=3D=3D=3D=3D=3D=3D=3D
   0:	e92d0010 	push	{r4}
   4:	e3a04000 	mov	r4, #0
   8:	e2844ffa 	add	r4, r4, #1000	; 0x3e8
   c:	e1a00004 	mov	r0, r4
  10:	e12fff1e 	bx	lr		<-- no pop

I added a || ctx->skf->len > 1 condition (still not correct because
of the earlier failure) to the if above since I had several tests that
would hit this bug.

> +
> + =A0 =A0 =A0 if (!(ctx->seen & SEEN_CALL))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(ARM_BX(ARM_LR), ctx);
> +#endif
> +}
> +
=2E..
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_LD_B_ABS:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 load_order =3D 0;
> +load:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit_mov_i(r_off, k, ct=
x);
> +load_common:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ctx->seen |=3D SEEN_DAT=
A | SEEN_CALL;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (load_order > 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(AR=
M_SUB_I(r_scratch, r_skb_hl,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A01 << load_order), ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(AR=
M_CMP_R(r_scratch, r_off), ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 condt =3D=
 ARM_COND_HS;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(AR=
M_CMP_R(r_skb_hl, r_off), ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 condt =3D=
 ARM_COND_HI;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 _emit(condt, ARM_ADD_R(=
r_scratch, r_off, r_skb_data),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ctx);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (load_order =3D=3D 0=
)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 _emit(c=
ondt, ARM_LDRB_I(r_A, r_scratch, 0),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else if (load_order =3D=
=3D 1)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit_lo=
ad_be16(condt, r_A, r_scratch, ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else if (load_order =3D=
=3D 2)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit_lo=
ad_be32(condt, r_A, r_scratch, ctx);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 _emit(condt, ARM_B(b_im=
m(i + 1, ctx)), ctx);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* the slowpath */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit_mov_i(ARM_R3, (u32=
)load_func[load_order], ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(ARM_MOV_R(ARM_R0, =
r_skb), ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* the offset is alread=
y in R1 */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit_blx_r(ARM_R3, ctx)=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(ARM_MOV_R(r_A, ARM=
_R0), ctx);

You're missing the "if (invalid data reference) return 0" behaviour.

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_LD_W_IND:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 load_order =3D 2;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto load_ind;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_LD_H_IND:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 load_order =3D 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto load_ind;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_LD_B_IND:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 load_order =3D 0;
> +load_ind:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 OP_IMM3(ARM_ADD, r_off,=
 r_X, k, ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto load_common;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_LDX_IMM:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ctx->seen |=3D SEEN_X;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit_mov_i(r_X, k, ctx)=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_LDX_W_LEN:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ctx->seen |=3D SEEN_X |=
 SEEN_SKB;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(ARM_LDR_I(r_X, r_s=
kb,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0offsetof(struct sk_buff, len)), ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_LDX_MEM:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ctx->seen |=3D SEEN_X |=
 SEEN_MEM_WORD(k);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(ARM_LDR_I(r_X, ARM=
_SP, SCRATCH_OFF(k)), ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_LDX_B_MSH:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* x =3D ((*(frame + k)=
) & 0xf) << 2; */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ctx->seen |=3D SEEN_X |=
 SEEN_DATA | SEEN_CALL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* offset in r1: we mig=
ht have to take the slow path */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit_mov_i(r_off, k, ct=
x);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(ARM_CMP_R(r_skb_hl=
, r_off), ctx);

You don't appear to be performing the "punt to interpreter" handling fo=
r
the negative K values.

> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* load in r0: common w=
ith the slowpath */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 _emit(ARM_COND_HI, ARM_=
LDRB_R(ARM_R0, r_skb_data,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ARM_R1), ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* emit_mov_i() might=
 generate one or two instructions,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* the same holds for=
 emit_blx_r()
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 _emit(ARM_COND_HI, ARM_=
B(b_imm(i + 1, ctx) - 2), ctx);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(ARM_MOV_R(ARM_R0, =
r_skb), ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* r_off is r1 */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit_mov_i(ARM_R3, (u32=
)jit_get_skb_b, ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit_blx_r(ARM_R3, ctx)=
;

"if (invalid address) return 0" behaviour needed here too.

> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(ARM_ORR_I(r_X, ARM=
_R0, 0x00f), ctx);

This should be AND, not ORR.

TEST 67 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
(tcp[0:2] > 1500 and tcp[0:2] < 1550) or (tcp[2:2] > 1500 and tcp[2:2] =
< 1550)
(0) retinterp 0 retjit 0
+OK
(1) retinterp 0 retjit 0
+OK
(2) retinterp 0 retjit 0
+OK
(3) retinterp 0 retjit 0
+OK
(4) retinterp 0 retjit 0
+OK
(5) retinterp 0 retjit 0
+OK
(6) retinterp 0 retjit 0
+OK
(7) retinterp 0 retjit 0
+OK
(8) retinterp 0 retjit 0
+OK
(9) retinterp 0xffff retjit 0
-ERROR different rets

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(ARM_LSL_I(r_X, r_X=
, 2), ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_ST:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ctx->seen |=3D SEEN_MEM=
_WORD(k);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(ARM_STR_I(r_A, ARM=
_SP, SCRATCH_OFF(k)), ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_STX:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ctx->seen |=3D SEEN_MEM=
_WORD(k) | SEEN_X;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(ARM_STR_I(r_X, ARM=
_SP, SCRATCH_OFF(k)), ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_ALU_ADD_K:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* A +=3D K */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 OP_IMM3(ARM_ADD, r_A, r=
_A, k, ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_ALU_ADD_X:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ctx->seen |=3D SEEN_X;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(ARM_ADD_R(r_A, r_A=
, r_X), ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_ALU_SUB_K:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* A -=3D K */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 OP_IMM3(ARM_SUB, r_A, r=
_A, k, ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_ALU_SUB_X:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ctx->seen |=3D SEEN_X;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(ARM_SUB_R(r_A, r_A=
, r_X), ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_ALU_MUL_K:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* A *=3D K */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit_mov_i(r_scratch, k=
, ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(ARM_MUL(r_A, r_A, =
r_scratch), ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_ALU_MUL_X:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ctx->seen |=3D SEEN_X;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(ARM_MUL(r_A, r_A, =
r_X), ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_ALU_DIV_K:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* current k =3D=3D rec=
iprocal_value(userspace k) */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit_mov_i(r_scratch, k=
, ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* A =3D top 32 bits of=
 the product */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(ARM_UMULL(r_scratc=
h, r_A, r_A, r_scratch), ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_ALU_DIV_X:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ctx->seen |=3D SEEN_X;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(ARM_CMP_I(r_X, 0),=
 ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit_err_ret(ARM_COND_E=
Q, ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit_udiv(r_A, r_A, r_X=
, ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_ALU_OR_K:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* A |=3D K */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 OP_IMM3(ARM_ORR, r_A, r=
_A, k, ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_ALU_OR_X:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ctx->seen |=3D SEEN_X;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(ARM_ORR_I(r_A, r_A=
, r_X), ctx);

TEST 19 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
BPF_STMT(BPF_ALU+BPF_OR+BPF_X, 0),
BPF_STMT(BPF_RET+BPF_A, 0)
Code: e92d0030 e3a05000 e3a04000 e3844005 e1a00004 e8bd0030 e12fff1e
(0000000000)
(0) retinterp 0 retjit 0x5
-ERROR different rets

All code
=3D=3D=3D=3D=3D=3D=3D=3D
   0:	e92d0030 	push	{r4, r5}
   4:	e3a05000 	mov	r5, #0
   8:	e3a04000 	mov	r4, #0
   c:	e3844005 	orr	r4, r4, #5	<-- should be register
  10:	e1a00004 	mov	r0, r4
  14:	e8bd0030 	pop	{r4, r5}
  18:	e12fff1e 	bx	lr

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_ALU_AND_K:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* A &=3D K */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 OP_IMM3(ARM_AND, r_A, r=
_A, k, ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_ALU_AND_X:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ctx->seen |=3D SEEN_X;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(ARM_AND_R(r_A, r_A=
, r_X), ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_ALU_LSH_K:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(k > 31))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return =
-1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(ARM_LSL_I(r_A, r_A=
, k), ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;

TEST 23 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
BPF_STMT(BPF_ALU+BPF_LSH+BPF_K, 5),
BPF_STMT(BPF_RET+BPF_A, 0)
Code: e92d0010 e3a04000 e1a04294 e1a00004 e8bd0010 e12fff1e (0000000000=
)
(0) retinterp 0 retjit 0x1
-ERROR different rets

All code
=3D=3D=3D=3D=3D=3D=3D=3D
   0:	e92d0010 	push	{r4}
   4:	e3a04000 	mov	r4, #0
   8:	e1a04294 	lsl	r4, r4, r2	<-- should be immediate
   c:	e1a00004 	mov	r0, r4
  10:	e8bd0010 	pop	{r4}
  14:	e12fff1e 	bx	lr

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_ALU_LSH_X:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ctx->seen |=3D SEEN_X;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(ARM_LSL_R(r_A, r_A=
, r_X), ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_ALU_RSH_K:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(k > 31))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return =
-1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(ARM_LSR_I(r_A, r_A=
, k), ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;

TEST 91 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
(ip[24] >> 1) + ip[25] =3D=3D 1
(0) retinterp 0 retjit 0
+OK
(1) retinterp 0 retjit 0
+OK
(2) retinterp 0xffff retjit 0
-ERROR different rets

All code
=3D=3D=3D=3D=3D=3D=3D=3D
  ...
  78:	e1a040b4 	strh	r4, [r0, r4]!	<-- rsh #1
  ...

(register/imm mixup)

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_ALU_RSH_X:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ctx->seen |=3D SEEN_X;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(ARM_LSR_R(r_A, r_A=
, r_X), ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;

You're missing NEG, which should be straightforward to implement.

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_JMP_JA:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* pc +=3D K */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(ARM_B(b_imm(i + k,=
 ctx)), ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;

TEST 39 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
BPF_STMT(BPF_JMP+BPF_JA, 0),
BPF_STMT(BPF_LD+BPF_IMM, 0x123)
BPF_STMT(BPF_RET+BPF_A, 0)
Code: e92d0010 e3a04000 fffffffe e3004123 e1a00004 e8bd0010 e12fff1e
(0000000000)
qemu: uncaught target signal 4 (Illegal instruction) - core dumped
Illegal instruction

All code
=3D=3D=3D=3D=3D=3D=3D=3D
   0:	e92d0010 	push	{r4}
   4:	e3a04000 	mov	r4, #0
   8:	fffffffe 	undefined instruction 0xfffffffe
   c:	e3004123 	movw	r4, #291	; 0x123
  10:	e1a00004 	mov	r0, r4
  14:	e8bd0010 	pop	{r4}
  18:	e12fff1e 	bx	lr

(1) ARM_B doesn't mask off the relevant bits
(2) b_imm should be passed i + k + 1, not i + k

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_JMP_JEQ_K:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* pc +=3D (A =3D=3D K)=
 ? pc->jt : pc->jf */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 condt =A0 =3D ARM_COND_=
EQ;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 condf =A0=3D ARM_COND_N=
E;

Since condf =3D=3D condt ^ 1, you can just do that in cond_jump and rem=
ove
the explicit assignments to it.

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto cmp_imm;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_JMP_JGT_K:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* pc +=3D (A > K) ? pc=
->jt : pc->jf */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 condt =A0 =3D ARM_COND_=
HI;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 condf =A0=3D ARM_COND_L=
S;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto cmp_imm;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_JMP_JGE_K:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* pc +=3D (A >=3D K) ?=
 pc->jt : pc->jf */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 condt =A0 =3D ARM_COND_=
HI;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 condf =A0=3D ARM_COND_L=
S;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* (x >=3D y) IFF (x > =
y - 1) */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(k =3D=3D 0=
))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return =
-1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 k--;

Why don't you just use ARM_COND_HS here?

> +cmp_imm:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 imm12 =3D imm8m(k);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (imm12 < 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit_mo=
v_i_no8m(r_scratch, k, ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(AR=
M_CMP_R(r_A, r_scratch), ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(AR=
M_CMP_I(r_A, imm12), ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +cond_jump:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (inst->jt)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 _emit(c=
ondt, ARM_B(b_imm(i + inst->jt + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ctx)), ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (inst->jf)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 _emit(c=
ondf, ARM_B(b_imm(i + inst->jf + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ctx)), ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_JMP_JEQ_X:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* pc +=3D (A =3D=3D X)=
 ? pc->jt : pc->jf */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 condt =A0 =3D ARM_COND_=
EQ;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 condf =A0=3D ARM_COND_N=
E;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto cmp_x;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_JMP_JGT_X:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* pc +=3D (A > X) ? pc=
->jt : pc->jf */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 condt =A0 =3D ARM_COND_=
HI;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 condf =A0=3D ARM_COND_L=
S;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto cmp_x;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_JMP_JGE_X:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* pc +=3D (A >=3D X) ?=
 pc->jt : pc->jf */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 condt =A0 =3D ARM_COND_=
CS;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 condf =A0=3D ARM_COND_C=
C;
> +cmp_x:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ctx->seen |=3D SEEN_X;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(ARM_CMP_R(r_A, r_X=
), ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto cond_jump;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_JMP_JSET_K:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* pc +=3D (A & K) ? pc=
->jt : pc->jf */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 condt =A0=3D ARM_COND_N=
E;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* not set iff all zero=
es iff Z=3D=3D1 iff EQ */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 condf =A0=3D ARM_COND_E=
Q;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 imm12 =3D imm8m(k);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (imm12 < 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit_mo=
v_i_no8m(r_scratch, k, ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(AR=
M_TST_R(r_A, r_scratch), ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(AR=
M_TST_I(r_A, imm12), ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto cond_jump;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_JMP_JSET_X:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* pc +=3D (A & X) ? pc=
->jt : pc->jf */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 condt =A0=3D ARM_COND_N=
E;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 condf =A0=3D ARM_COND_E=
Q;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(ARM_TST_R(r_A, r_X=
), ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto cond_jump;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_RET_A:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(ARM_MOV_R(ARM_R0, =
r_A), ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto b_epilogue;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_RET_K:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((k =3D=3D 0) && (ct=
x->ret0_fp_idx < 0))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ctx->re=
t0_fp_idx =3D i;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit_mov_i(ARM_R0, k, c=
tx);
> +b_epilogue:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (i !=3D ctx->skf->le=
n - 1)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(AR=
M_B(b_imm(prog->len, ctx)), ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_MISC_TAX:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* X =3D A */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(ARM_MOV_R(r_X, r_A=
), ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;

TEST 37 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
BPF_STMT(BPF_MISC+BPF_TAX, 0),
BPF_STMT(BPF_RET+BPF_A, 0)
Code: e92d0010 e3a04000 e1a05004 e1a00004 e8bd0010 e12fff1e (0000000000=
)
(0) retinterp 0 retjit 0
+OK
qemu: uncaught target signal 11 (Segmentation fault) - core dumped

All code
=3D=3D=3D=3D=3D=3D=3D=3D
   0:	e92d0010 	push	{r4}
   4:	e3a04000 	mov	r4, #0
   8:	e1a05004 	mov	r5, r4	<- clobber
   c:	e1a00004 	mov	r0, r4
  10:	e8bd0010 	pop	{r4}
  14:	e12fff1e 	bx	lr

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_MISC_TXA:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* A =3D X */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 emit(ARM_MOV_R(r_A, r_X=
), ctx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;

TEST 38 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
BPF_STMT(BPF_MISC+BPF_TXA, 0),
BPF_STMT(BPF_RET+BPF_A, 0)
Code: e92d0010 e3a04000 e1a04005 e1a00004 e8bd0010 e12fff1e (0000000000=
)
(0) retinterp 0 retjit 0
+OK
(1) retinterp 0 retjit 0x1
-ERROR different rets

All code
=3D=3D=3D=3D=3D=3D=3D=3D
   0:	e92d0010 	push	{r4}
   4:	e3a04000 	mov	r4, #0
   8:	e1a04005 	mov	r4, r5	<- uninitialized
   c:	e1a00004 	mov	r0, r4
  10:	e8bd0010 	pop	{r4}
  14:	e12fff1e 	bx	lr

=2E..
> +void bpf_jit_compile(struct sk_filter *fp)
> +{
> + =A0 =A0 =A0 struct jit_ctx ctx;
> + =A0 =A0 =A0 unsigned tmp_idx;
> + =A0 =A0 =A0 unsigned alloc_size;
> +
> + =A0 =A0 =A0 if (!bpf_jit_enable)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 memset(&ctx, 0, sizeof(ctx));
> + =A0 =A0 =A0 ctx.skf =A0 =A0 =A0 =A0 =3D fp;
> + =A0 =A0 =A0 ctx.ret0_fp_idx =3D -1;
> +
> + =A0 =A0 =A0 ctx.offsets =3D kzalloc(GFP_KERNEL, 4 * (ctx.skf->len +=
 1));
> + =A0 =A0 =A0 if (ctx.offsets =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 /* fake pass to fill in the ctx->seen */
> + =A0 =A0 =A0 if (unlikely(build_body(&ctx)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> +
> + =A0 =A0 =A0 tmp_idx =3D ctx.idx;
> + =A0 =A0 =A0 build_prologue(&ctx);
> + =A0 =A0 =A0 ctx.prologue_bytes =3D (ctx.idx - tmp_idx) * 4;
> +
> +#if __LINUX_ARM_ARCH__ < 7
> + =A0 =A0 =A0 tmp_idx =3D ctx.idx;
> + =A0 =A0 =A0 build_epilogue(&ctx);
> + =A0 =A0 =A0 ctx.epilogue_bytes =3D (ctx.idx - tmp_idx) * 4;
> +
> + =A0 =A0 =A0 ctx.idx +=3D ctx.imm_count;
> + =A0 =A0 =A0 if (ctx.imm_count) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ctx.imms =3D kzalloc(GFP_KERNEL, 4 * ct=
x.imm_count);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ctx.imms =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> + =A0 =A0 =A0 }
> +#else
> + =A0 =A0 =A0 /* there's nothing after the epilogue on ARMv7 */
> + =A0 =A0 =A0 build_epilogue(&ctx);
> +#endif
> +
> + =A0 =A0 =A0 alloc_size =3D 4 * ctx.idx;
> + =A0 =A0 =A0 ctx.target =3D module_alloc(alloc_size > sizeof(struct =
work_struct) ?
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 all=
oc_size : sizeof(struct work_struct));

max()
