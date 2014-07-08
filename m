From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH RFCv2] arm64: eBPF JIT compiler
Date: Tue, 8 Jul 2014 02:24:17 -0700
Message-ID: <CAMEtUuydrYMGdg2zNDYX4vKL0_-reF+yOPKx5hpUvy4guuVeBg@mail.gmail.com>
References: <1404803213-10653-1-git-send-email-zlim.lnx@gmail.com>
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
To: Zi Shen Lim <zlim.lnx@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404803213-10653-1-git-send-email-zlim.lnx@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 8, 2014 at 12:06 AM, Zi Shen Lim <zlim.lnx@gmail.com> wrote:
> The JIT compiler emits A64 instructions. It supports eBPF only.
> Legacy BPF is supported thanks to conversion by BPF core.
>
> JIT is enabled in the same way as for other architectures:
>
>         echo 1 > /proc/sys/net/core/bpf_jit_enable
>
> Or for additional compiler output:
>
>         echo 2 > /proc/sys/net/core/bpf_jit_enable
>
> See Documentation/networking/filter.txt for more information.
>
> The implementation passes all 57 tests in lib/test_bpf.c
> on ARMv8 Foundation Model :)
>
> Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>
>
> ---
> RFCv1->RFCv2:
>
>   Addressed review comments from Alexei:
>   - use core-$(CONFIG_NET)
>   - use GENMASK
>   - lower-case function names in header file
>   - drop LD_ABS+DW and LD_IND+DW, which do not exist in eBPF yet
>   - use pr_xxx_once() to prevent spamming logs
>   - clarify 16B stack alignment requirement
>   - drop usage of EMIT macro which was saving just one argument,
>     turns out having additional argument wasn't too much of an eyesore
>
>   Also, per discussion with Alexei, and additional suggestion from
>   Daniel:
>   - moved load_pointer() from net/core/filter.c into filter.h
>     as bpf_load_pointer()
>   which is done as a separate preparatory patch. [1]
>
> [1] http://patchwork.ozlabs.org/patch/366906/

Just to clarify. This patch is on top of [1]

> +       /* R0 = ntohx(*(size *)(((struct sk_buff *)R6)->data + src + imm)) */
> +       case BPF_LD | BPF_IND | BPF_W:
> +       case BPF_LD | BPF_IND | BPF_H:
> +       case BPF_LD | BPF_IND | BPF_B:
> +       {
> +               const u8 r0 = bpf2a64[BPF_REG_0]; /* r0 = return value */
> +               const u8 r6 = bpf2a64[BPF_REG_6]; /* r6 = pointer to sk_buff */
> +               const u8 fp = bpf2a64[BPF_REG_FP];
> +               const u8 r1 = bpf2a64[BPF_REG_1]; /* r1: struct sk_buff *skb */
> +               const u8 r2 = bpf2a64[BPF_REG_2]; /* r2: int k */
> +               const u8 r3 = bpf2a64[BPF_REG_3]; /* r3: unsigned int size */
> +               const u8 r4 = bpf2a64[BPF_REG_4]; /* r4: void *buffer */
> +               const u8 r5 = bpf2a64[BPF_REG_5]; /* r5: void *(*func)(...) */
> +               int size;
> +
> +               emit(A64_MOV(1, r1, r6), ctx);
> +               emit_a64_mov_i(0, r2, imm, ctx);
> +               if (BPF_MODE(code) == BPF_IND)
> +                       emit(A64_ADD(0, r2, r2, src), ctx);
> +               switch (BPF_SIZE(code)) {
> +               case BPF_W:
> +                       size = 4;
> +                       break;
> +               case BPF_H:
> +                       size = 2;
> +                       break;
> +               case BPF_B:
> +                       size = 1;
> +                       break;
> +               default:
> +                       return -EINVAL;
> +               }
> +               emit_a64_mov_i64(r3, size, ctx);
> +               emit(A64_ADD_I(1, r4, fp, MAX_BPF_STACK), ctx);
> +               emit_a64_mov_i64(r5, (unsigned long)bpf_load_pointer, ctx);
> +               emit(A64_PUSH(A64_FP, A64_LR, A64_SP), ctx);
> +               emit(A64_MOV(1, A64_FP, A64_SP), ctx);
> +               emit(A64_BLR(r5), ctx);
> +               emit(A64_MOV(1, r0, A64_R(0)), ctx);
> +               emit(A64_POP(A64_FP, A64_LR, A64_SP), ctx);
> +
> +               jmp_offset = epilogue_offset(ctx);
> +               check_imm19(jmp_offset);
> +               emit(A64_CBZ(1, r0, jmp_offset), ctx);
> +               emit(A64_MOV(1, r5, r0), ctx);
> +               switch (BPF_SIZE(code)) {
> +               case BPF_W:
> +                       emit(A64_LDR32(r0, r5, A64_ZR), ctx);
> +#ifndef CONFIG_CPU_BIG_ENDIAN
> +                       emit(A64_REV32(0, r0, r0), ctx);
> +#endif
> +                       break;
> +               case BPF_H:
> +                       emit(A64_LDRH(r0, r5, A64_ZR), ctx);
> +#ifndef CONFIG_CPU_BIG_ENDIAN
> +                       emit(A64_REV16(0, r0, r0), ctx);
> +#endif
> +                       break;
> +               case BPF_B:
> +                       emit(A64_LDRB(r0, r5, A64_ZR), ctx);
> +                       break;
> +               case BPF_DW:

this case can be removed too.

Acked-by: Alexei Starovoitov <ast@plumgrid.com>

Great work. Thanks.

> +                       emit(A64_LDR64(r0, r5, A64_ZR), ctx);
> +#ifndef CONFIG_CPU_BIG_ENDIAN
> +                       emit(A64_REV64(r0, r0), ctx);
> +#endif
> +                       break;
> +               }
> +               break;
> +       }
