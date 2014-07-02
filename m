From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH RFC] arm64: eBPF JIT compiler
Date: Tue, 1 Jul 2014 22:38:50 -0700
Message-ID: <CAMEtUuwpOMY75CD3WZoQpZ=nge-L0rmo5kGC-wm1tj0oKUW=6g@mail.gmail.com>
References: <1404278424-31176-1-git-send-email-zlim.lnx@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
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
In-Reply-To: <1404278424-31176-1-git-send-email-zlim.lnx@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 1, 2014 at 10:20 PM, Zi Shen Lim <zlim.lnx@gmail.com> wrote=
:
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

Wow. This is awesome!
Haven't studied the patch in detail yet=E2=80=A6

> NOTES:
>
> * This patch applies on top of current net-next @ 763e0ecd72fe
>   ("bonding: allow to add vlans on top of empty bond").
>
> * bpf_jit_comp.c is checkpatch clean.
>
> * Checkpatch warns about long lines for bpf_jit.h, but those
>   lines are actually more readable as is.
>
> * The following sparse warning is not applicable:
>   warning: symbol 'bpf_jit_enable' was not declared. Should it be sta=
tic?
>
> PENDING:
>
> 1. Implement remaining classes of eBPF instructions: ST|MEM, STX|XADD
>    which currently do not have corresponding test cases in test_bpf.
>
> 2. Move out of arch/arm64/net/, when appropriate, in line with BPF
>    infra split.
>
> 3. Further compiler optimization is possible and can be targetted
>    for phase 2 implementation.
> ---
>  Documentation/networking/filter.txt |   2 +-
>  arch/arm64/Kconfig                  |   1 +
>  arch/arm64/Makefile                 |   1 +
>  arch/arm64/net/Makefile             |   4 +
>  arch/arm64/net/bpf_jit.h            | 315 ++++++++++++++++
>  arch/arm64/net/bpf_jit_comp.c       | 698 ++++++++++++++++++++++++++=
++++++++++
>  6 files changed, 1020 insertions(+), 1 deletion(-)
>  create mode 100644 arch/arm64/net/Makefile
>  create mode 100644 arch/arm64/net/bpf_jit.h
>  create mode 100644 arch/arm64/net/bpf_jit_comp.c
>
> diff --git a/Documentation/networking/filter.txt b/Documentation/netw=
orking/filter.txt
> index ee78eba..d71e616 100644
> --- a/Documentation/networking/filter.txt
> +++ b/Documentation/networking/filter.txt
> @@ -462,7 +462,7 @@ JIT compiler
>  ------------
>
>  The Linux kernel has a built-in BPF JIT compiler for x86_64, SPARC, =
PowerPC,
> -ARM and s390 and can be enabled through CONFIG_BPF_JIT. The JIT comp=
iler is
> +ARM, ARM64 and s390 and can be enabled through CONFIG_BPF_JIT. The J=
IT compiler is
>  transparently invoked for each attached filter from user space or fo=
r internal
>  kernel users if it has been previously enabled by root:
>
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index a474de34..b0a4ff8 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -32,6 +32,7 @@ config ARM64
>         select HAVE_ARCH_KGDB
>         select HAVE_ARCH_TRACEHOOK
>         select HAVE_C_RECORDMCOUNT
> +       select HAVE_BPF_JIT
>         select HAVE_DEBUG_BUGVERBOSE
>         select HAVE_DEBUG_KMEMLEAK
>         select HAVE_DMA_API_DEBUG
> diff --git a/arch/arm64/Makefile b/arch/arm64/Makefile
> index 8185a91..0cd6b9c 100644
> --- a/arch/arm64/Makefile
> +++ b/arch/arm64/Makefile
> @@ -43,6 +43,7 @@ TEXT_OFFSET :=3D 0x00080000
>  export TEXT_OFFSET GZFLAGS
>
>  core-y         +=3D arch/arm64/kernel/ arch/arm64/mm/
> +core-y         +=3D arch/arm64/net/
>  core-$(CONFIG_KVM) +=3D arch/arm64/kvm/
>  core-$(CONFIG_XEN) +=3D arch/arm64/xen/
>  core-$(CONFIG_CRYPTO) +=3D arch/arm64/crypto/
> diff --git a/arch/arm64/net/Makefile b/arch/arm64/net/Makefile
> new file mode 100644
> index 0000000..da97633
> --- /dev/null
> +++ b/arch/arm64/net/Makefile
> @@ -0,0 +1,4 @@
> +#
> +# ARM64 networking code
> +#
> +obj-$(CONFIG_BPF_JIT) +=3D bpf_jit_comp.o
> diff --git a/arch/arm64/net/bpf_jit.h b/arch/arm64/net/bpf_jit.h
> new file mode 100644
> index 0000000..5013969
> --- /dev/null
> +++ b/arch/arm64/net/bpf_jit.h
> @@ -0,0 +1,315 @@
> +/*
> + * BPF JIT compiler for ARM64
> + *
> + * Copyright (C) 2014 Zi Shen Lim <zlim.lnx@gmail.com>
> + *
> + * This program is free software; you can redistribute it and/or mod=
ify
> + * it under the terms of the GNU General Public License version 2 as
> + * published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program.  If not, see <http://www.gnu.org/license=
s/>.
> + */
> +#ifndef _BPF_JIT_H
> +#define _BPF_JIT_H
> +
> +/* 5-bit Register Operand */
> +#define A64_R(x)       x               /* R0-R30: General purpose */
> +#define A64_FP         A64_R(29)       /* Frame pointer */
> +#define A64_LR         A64_R(30)       /* Link register */
> +#define A64_ZR         31              /* As source register operand=
 */
> +#define A64_SP         31              /* As load/store base registe=
r */
> +
> +#define BITSMASK(bits) ((1 << (bits)) - 1)
> +
> +/* Compare & branch (immediate) */
> +static inline u32 A64_COMP_BRANCH_IMM(int sf, int op, int imm19, int=
 Rt)
> +{
> +       sf &=3D BITSMASK(1);
> +       op &=3D BITSMASK(1);
> +       imm19 &=3D BITSMASK(19);
> +       Rt &=3D BITSMASK(5);
> +       return 0x34000000 | sf << 31 | op << 24 | imm19 << 5 | Rt;
> +}
> +#define A64_CBZ(sf, Rt, imm19)  A64_COMP_BRANCH_IMM(sf, 0, imm19, Rt=
)
> +#define A64_CBNZ(sf, Rt, imm19) A64_COMP_BRANCH_IMM(sf, 1, imm19, Rt=
)
> +
> +/* Conditional branch (immediate) */
> +static inline u32 A64_COND_BRANCH_IMM(int o1, int imm19, int o0, int=
 cond)
> +{
> +       o1 &=3D BITSMASK(1);
> +       imm19 &=3D BITSMASK(19);
> +       o0 &=3D BITSMASK(1);
> +       cond &=3D BITSMASK(4);
> +       return 0x54000000 | o1 << 24 | imm19 << 5 | o0 << 4 | cond;
> +}
> +#define A64_COND_EQ 0x0 /* =3D=3D */
> +#define A64_COND_NE 0x1 /* !=3D */
> +#define A64_COND_CS 0x2 /* unsigned >=3D */
> +#define A64_COND_HI 0x8 /* unsigned > */
> +#define A64_COND_GE 0xa /* signed >=3D */
> +#define A64_COND_GT 0xc /* signed > */
> +#define A64_B_(cond, imm19) A64_COND_BRANCH_IMM(0, imm19, 0, cond)
> +
> +/* Unconditional branch (immediate) */
> +static inline u32 A64_BRANCH_IMM(int op, int imm26)
> +{
> +       op &=3D BITSMASK(1);
> +       imm26 &=3D BITSMASK(26);
> +       return 0x14000000 | op << 31 | imm26;
> +}
> +#define A64_B(imm26)  A64_BRANCH_IMM(0, imm26)
> +#define A64_BL(imm26) A64_BRANCH_IMM(1, imm26)
> +
> +/* Unconditional branch (register) */
> +static inline u32 A64_BRANCH_REG(int opc, int op2, int op3, int Rn, =
int op4)
> +{
> +       opc &=3D BITSMASK(4);
> +       op2 &=3D BITSMASK(5);
> +       op3 &=3D BITSMASK(6);
> +       Rn &=3D BITSMASK(5);
> +       op4 &=3D BITSMASK(5);
> +       return 0xd6000000 | opc << 21 | op2 << 16 | op3 << 10 | Rn <<=
 5 | op4;
> +}
> +#define A64_BR(Rn)  A64_BRANCH_REG(0, 0x1f, 0, Rn, 0)
> +#define A64_BLR(Rn) A64_BRANCH_REG(1, 0x1f, 0, Rn, 0)
> +#define A64_RET(Rn) A64_BRANCH_REG(2, 0x1f, 0, Rn, 0)
> +
> +/* Load/store register (register offset) */
> +static inline u32 A64_LS_REG(int size, int V, int opc, int Rm, int o=
ption, int S, int Rn, int Rt)
> +{
> +       size &=3D BITSMASK(2);
> +       V &=3D BITSMASK(1);
> +       opc &=3D BITSMASK(2);
> +       Rm &=3D BITSMASK(5);
> +       option &=3D BITSMASK(3);
> +       S &=3D BITSMASK(1);
> +       Rn &=3D BITSMASK(5);
> +       Rt &=3D BITSMASK(5);
> +       return 0x38200800 | size << 30 | V << 26 | opc << 22 | Rm << =
16 | option << 13 | S << 12 | Rn << 5 | Rt;
> +}
> +#define A64_STRB(Wt, Xn, Xm)  A64_LS_REG(0, 0, 0, Xm, 3, 0, Xn, Wt)
> +#define A64_LDRB(Wt, Xn, Xm)  A64_LS_REG(0, 0, 1, Xm, 3, 0, Xn, Wt)
> +#define A64_STRH(Wt, Xn, Xm)  A64_LS_REG(1, 0, 0, Xm, 3, 0, Xn, Wt)
> +#define A64_LDRH(Wt, Xn, Xm)  A64_LS_REG(1, 0, 1, Xm, 3, 0, Xn, Wt)
> +#define A64_STR32(Wt, Xn, Xm) A64_LS_REG(2, 0, 0, Xm, 3, 0, Xn, Wt)
> +#define A64_LDR32(Wt, Xn, Xm) A64_LS_REG(2, 0, 1, Xm, 3, 0, Xn, Wt)
> +#define A64_STR64(Xt, Xn, Xm) A64_LS_REG(3, 0, 0, Xm, 3, 0, Xn, Xt)
> +#define A64_LDR64(Xt, Xn, Xm) A64_LS_REG(3, 0, 1, Xm, 3, 0, Xn, Xt)
> +
> +/* Load/store register pair */
> +static inline u32 A64_LS_PAIR(int opc, int V, int mode, int L, int i=
mm7, int Rt2, int Rn, int Rt)
> +{
> +       opc &=3D BITSMASK(2);
> +       V &=3D BITSMASK(1);
> +       mode &=3D BITSMASK(3);
> +       L &=3D BITSMASK(1);
> +       imm7 &=3D BITSMASK(7);
> +       Rt2 &=3D BITSMASK(5);
> +       Rn &=3D BITSMASK(5);
> +       Rt &=3D BITSMASK(5);
> +       return 0x28000000 | opc << 30 | V << 26 | mode << 23 | L << 2=
2 | imm7 << 15 | Rt2 << 10 | Rn << 5 | Rt;
> +}
> +#define lspPostIndexed 1
> +#define lspOffset 2
> +#define lspPreIndexed 3
> +/* Non-SIMD, 64-bit variant. imm =3D [-512, 504] */
> +#define A64_STP64(Rt, Rt2, Rn, imm, mode) A64_LS_PAIR(2, 0, mode, 0,=
 imm >> 3, Rt2, Rn, Rt)
> +#define A64_LDP64(Rt, Rt2, Rn, imm, mode) A64_LS_PAIR(2, 0, mode, 1,=
 imm >> 3, Rt2, Rn, Rt)
> +
> +/* Rn -=3D 16; Rn[0] =3D Rt; Rn[8] =3D Rt2; */
> +#define A64_PUSH(Rt, Rt2, Rn) A64_STP64(Rt, Rt2, Rn, -16, lspPreInde=
xed)
> +/* Rt =3D Rn[0]; Rt2 =3D Rn[8]; Rn +=3D 16; */
> +#define A64_POP(Rt, Rt2, Rn)  A64_LDP64(Rt, Rt2, Rn, 16, lspPostInde=
xed)
> +
> +/* Add/subtract (immediate) */
> +static inline u32 A64_ADDSUB_IMM(int sf, int op, int S, int shift, i=
nt imm12, int Rn, int Rd)
> +{
> +       sf &=3D BITSMASK(1);
> +       op &=3D BITSMASK(1);
> +       S &=3D BITSMASK(1);
> +       shift &=3D BITSMASK(2);
> +       imm12 &=3D BITSMASK(12);
> +       Rn &=3D BITSMASK(5);
> +       Rd &=3D BITSMASK(5);
> +       return 0x11000000 | sf << 31 | op << 30 | S << 29 | shift << =
22 | imm12 << 10 | Rn << 5 | Rd;
> +}
> +#define A64_ADD_IMM(sf, shift, imm12, Rn, Rd)  A64_ADDSUB_IMM(sf, 0,=
 0, shift, imm12, Rn, Rd)
> +#define A64_ADDS_IMM(sf, shift, imm12, Rn, Rd) A64_ADDSUB_IMM(sf, 0,=
 1, shift, imm12, Rn, Rd)
> +#define A64_SUB_IMM(sf, shift, imm12, Rn, Rd)  A64_ADDSUB_IMM(sf, 1,=
 0, shift, imm12, Rn, Rd)
> +#define A64_SUBS_IMM(sf, shift, imm12, Rn, Rd) A64_ADDSUB_IMM(sf, 1,=
 1, shift, imm12, Rn, Rd)
> +
> +/* Rd =3D Rn OP imm12 */
> +#define A64_ADD_I(sf, Rd, Rn, imm12) A64_ADD_IMM(sf, 0, imm12, Rn, R=
d)
> +#define A64_SUB_I(sf, Rd, Rn, imm12) A64_SUB_IMM(sf, 0, imm12, Rn, R=
d)
> +/* Rd =3D Rn */
> +#define A64_MOV(sf, Rd, Rn) A64_ADD_I(sf, Rd, Rn, 0)
> +
> +/* Bitfield move */
> +static inline u32 A64_BITFIELD(int sf, int opc, int N, int immr, int=
 imms, int Rn, int Rd)
> +{
> +       sf &=3D BITSMASK(1);
> +       opc &=3D BITSMASK(2);
> +       N &=3D BITSMASK(1);
> +       immr &=3D BITSMASK(6);
> +       imms &=3D BITSMASK(6);
> +       Rn &=3D BITSMASK(5);
> +       Rd &=3D BITSMASK(5);
> +       return 0x13000000 | sf << 31 | opc << 29 | N << 22 | immr << =
16 | imms << 10 | Rn << 5 | Rd;
> +}
> +/* Signed, with sign replication to left and zeros to right */
> +#define A64_SBFM(sf, Rd, Rn, immr, imms) A64_BITFIELD(sf, 0, sf, imm=
r, imms, Rn, Rd)
> +/* Leave other bits unchanged */
> +#define A64_BFM(sf, Rd, Rn, immr, imms)  A64_BITFIELD(sf, 1, sf, imm=
r, imms, Rn, Rd)
> +/* Unsigned, with zeros to left and right */
> +#define A64_UBFM(sf, Rd, Rn, immr, imms) A64_BITFIELD(sf, 2, sf, imm=
r, imms, Rn, Rd)
> +
> +/* Rd =3D Rn << shift */
> +#define A64_LSL(sf, Rd, Rn, shift) ({  \
> +       int sz =3D (sf) ? 64 : 32;        \
> +       A64_UBFM(sf, Rd, Rn, (unsigned)-(shift) % sz, sz - 1 - (shift=
)); \
> +})
> +/* Rd =3D Rn >> shift */
> +#define A64_LSR(sf, Rd, Rn, shift) A64_UBFM(sf, Rd, Rn, shift, (sf) =
? 63 : 31)
> +/* Rd =3D Rn >> shift; signed */
> +#define A64_ASR(sf, Rd, Rn, shift) A64_SBFM(sf, Rd, Rn, shift, (sf) =
? 63 : 31)
> +
> +/* Move wide (immediate) */
> +static inline u32 A64_MOVE_IMM(int sf, int opc, int hw, int imm16, i=
nt Rd)
> +{
> +       sf &=3D BITSMASK(1);
> +       opc &=3D BITSMASK(2);
> +       hw &=3D BITSMASK(2);
> +       imm16 &=3D BITSMASK(16);
> +       Rd &=3D BITSMASK(5);
> +       return 0x12800000 | sf << 31 | opc << 29 | hw << 21 | imm16 <=
< 5 | Rd;
> +}
> +#define A64_MOVN_IMM(sf, hw, imm16, Rd) A64_MOVE_IMM(sf, 0, hw, imm1=
6, Rd)
> +#define A64_MOVZ_IMM(sf, hw, imm16, Rd) A64_MOVE_IMM(sf, 2, hw, imm1=
6, Rd)
> +#define A64_MOVK_IMM(sf, hw, imm16, Rd) A64_MOVE_IMM(sf, 3, hw, imm1=
6, Rd)
> +
> +/* Rd =3D Zeros (for MOVZ);
> + * Rd |=3D imm16 << shift (where shift is {0, 16, 32, 48});
> + * Rd =3D ~Rd; (for MOVN); */
> +#define A64_MOVN(sf, Rd, imm16, shift) A64_MOVN_IMM(sf, shift >> 4, =
imm16, Rd)
> +#define A64_MOVZ(sf, Rd, imm16, shift) A64_MOVZ_IMM(sf, shift >> 4, =
imm16, Rd)
> +#define A64_MOVK(sf, Rd, imm16, shift) A64_MOVK_IMM(sf, shift >> 4, =
imm16, Rd)
> +
> +/* Add/subtract (shifted register) */
> +static inline u32 A64_ADDSUB_SREG(int sf, int op, int S, int shift, =
int Rm, int imm6, int Rn, int Rd)
> +{
> +       sf &=3D BITSMASK(1);
> +       op &=3D BITSMASK(1);
> +       S &=3D BITSMASK(1);
> +       shift &=3D BITSMASK(2);
> +       Rm &=3D BITSMASK(5);
> +       imm6 &=3D BITSMASK(6);
> +       Rn &=3D BITSMASK(5);
> +       Rd &=3D BITSMASK(5);
> +       return 0x0b000000 | sf << 31 | op << 30 | S << 29 | shift << =
22 | Rm << 16 | imm6 << 10 | Rn << 5 | Rd;
> +}
> +#define A64_ADD_SREG(sf, shift, Rm, imm6, Rn, Rd)  A64_ADDSUB_SREG(s=
f, 0, 0, shift, Rm, imm6, Rn, Rd)
> +#define A64_ADDS_SREG(sf, shift, Rm, imm6, Rn, Rd) A64_ADDSUB_SREG(s=
f, 0, 1, shift, Rm, imm6, Rn, Rd)
> +#define A64_SUB_SREG(sf, shift, Rm, imm6, Rn, Rd)  A64_ADDSUB_SREG(s=
f, 1, 0, shift, Rm, imm6, Rn, Rd)
> +#define A64_SUBS_SREG(sf, shift, Rm, imm6, Rn, Rd) A64_ADDSUB_SREG(s=
f, 1, 1, shift, Rm, imm6, Rn, Rd)
> +
> +/* Rd =3D Rn OP Rm */
> +#define A64_ADD(sf, Rd, Rn, Rm)  A64_ADD_SREG(sf, 0, Rm, 0, Rn, Rd)
> +#define A64_SUB(sf, Rd, Rn, Rm)  A64_SUB_SREG(sf, 0, Rm, 0, Rn, Rd)
> +#define A64_SUBS(sf, Rd, Rn, Rm) A64_SUBS_SREG(sf, 0, Rm, 0, Rn, Rd)
> +/* Rd =3D -Rm */
> +#define A64_NEG(sf, Rd, Rm) A64_SUB(sf, Rd, A64_ZR, Rm)
> +/* Rn - Rm; set condition flags */
> +#define A64_CMP(sf, Rn, Rm) A64_SUBS(sf, A64_ZR, Rn, Rm)
> +
> +/* Data-processing (1 source) */
> +static inline u32 A64_DATA1(int sf, int S, int opcode2, int opcode, =
int Rn, int Rd)
> +{
> +       sf &=3D BITSMASK(1);
> +       S &=3D BITSMASK(1);
> +       opcode2 &=3D BITSMASK(5);
> +       opcode &=3D BITSMASK(6);
> +       Rn &=3D BITSMASK(5);
> +       Rd &=3D BITSMASK(5);
> +       return 0x5ac00000 | sf << 31 | S << 29 | opcode2 << 16 | opco=
de << 10 | Rn << 5 | Rd;
> +}
> +/* Rd =3D BSWAPx(Rn) */
> +#define A64_REV16(sf, Rd, Rn) A64_DATA1(sf, 0, 0, 1, Rn, Rd)
> +#define A64_REV32(sf, Rd, Rn) A64_DATA1(sf, 0, 0, 2, Rn, Rd)
> +#define A64_REV64(Rd, Rn)     A64_DATA1(1, 0, 0, 3, Rn, Rd)
> +
> +/* Data-processing (2 source) */
> +static inline u32 A64_DATA2(int sf, int S, int Rm, int opcode, int R=
n, int Rd)
> +{
> +       sf &=3D BITSMASK(1);
> +       S &=3D BITSMASK(1);
> +       Rm &=3D BITSMASK(5);
> +       opcode &=3D BITSMASK(6);
> +       Rn &=3D BITSMASK(5);
> +       Rd &=3D BITSMASK(5);
> +       return 0x1ac00000 | sf << 31 | S << 29 | Rm << 16 | opcode <<=
 10 | Rn << 5 | Rd;
> +}
> +/* Rd =3D Rn OP Rm */
> +#define A64_UDIV(sf, Rd, Rn, Rm) A64_DATA2(sf, 0, Rm, 0x2, Rn, Rd)
> +#define A64_SDIV(sf, Rd, Rn, Rm) A64_DATA2(sf, 0, Rm, 0x3, Rn, Rd)
> +#define A64_LSLV(sf, Rd, Rn, Rm) A64_DATA2(sf, 0, Rm, 0x8, Rn, Rd)
> +#define A64_LSRV(sf, Rd, Rn, Rm) A64_DATA2(sf, 0, Rm, 0x9, Rn, Rd)
> +#define A64_ASRV(sf, Rd, Rn, Rm) A64_DATA2(sf, 0, Rm, 0xa, Rn, Rd)
> +#define A64_RORV(sf, Rd, Rn, Rm) A64_DATA2(sf, 0, Rm, 0xb, Rn, Rd)
> +
> +/* Data-processing (3 source) */
> +static inline u32 A64_DATA3(int sf, int op54, int op31, int Rm, int =
o0, int Ra, int Rn, int Rd)
> +{
> +       sf &=3D BITSMASK(1);
> +       op54 &=3D BITSMASK(2);
> +       op31 &=3D BITSMASK(3);
> +       Rm &=3D BITSMASK(5);
> +       o0 &=3D BITSMASK(1);
> +       Ra &=3D BITSMASK(5);
> +       Rn &=3D BITSMASK(5);
> +       Rd &=3D BITSMASK(5);
> +       return 0x1b000000 | sf << 31 | op54 << 29 | op31 << 21 | Rm <=
< 16 | o0 << 15 | Ra << 10 | Rn << 5 | Rd;
> +}
> +#define A64_MADD(sf, Rm, Ra, Rn, Rd) A64_DATA3(sf, 0, 0, Rm, 0, Ra, =
Rn, Rd)
> +#define A64_MSUB(sf, Rm, Ra, Rn, Rd) A64_DATA3(sf, 0, 0, Rm, 1, Ra, =
Rn, Rd)
> +
> +/* Rd =3D Rn * Rm */
> +#define A64_MUL(sf, Rd, Rn, Rm) A64_MADD(sf, Rm, A64_ZR, Rn, Rd)
> +
> +/* Logical (shifted register) */
> +static inline u32 A64_LOGICAL_SREG(int sf, int opc, int shift, int N=
, int Rm, int imm6, int Rn, int Rd)
> +{
> +       sf &=3D BITSMASK(1);
> +       opc &=3D BITSMASK(2);
> +       shift &=3D BITSMASK(2);
> +       N &=3D BITSMASK(1);
> +       Rm &=3D BITSMASK(5);
> +       imm6 &=3D BITSMASK(6);
> +       Rn &=3D BITSMASK(5);
> +       Rd &=3D BITSMASK(5);
> +       return 0x0a000000 | sf << 31 | opc << 29 | shift << 22 | N <<=
 21 | Rm << 16 | imm6 << 10 | Rn << 5 | Rd;
> +}
> +#define A64_AND_SREG(sf, shift, Rm, imm6, Rn, Rd)  A64_LOGICAL_SREG(=
sf, 0, shift, 0, Rm, imm6, Rn, Rd)
> +#define A64_BIC_SREG(sf, shift, Rm, imm6, Rn, Rd)  A64_LOGICAL_SREG(=
sf, 0, shift, 1, Rm, imm6, Rn, Rd)
> +#define A64_ORR_SREG(sf, shift, Rm, imm6, Rn, Rd)  A64_LOGICAL_SREG(=
sf, 1, shift, 0, Rm, imm6, Rn, Rd)
> +#define A64_ORN_SREG(sf, shift, Rm, imm6, Rn, Rd)  A64_LOGICAL_SREG(=
sf, 1, shift, 1, Rm, imm6, Rn, Rd)
> +#define A64_EOR_SREG(sf, shift, Rm, imm6, Rn, Rd)  A64_LOGICAL_SREG(=
sf, 2, shift, 0, Rm, imm6, Rn, Rd)
> +#define A64_EON_SREG(sf, shift, Rm, imm6, Rn, Rd)  A64_LOGICAL_SREG(=
sf, 2, shift, 1, Rm, imm6, Rn, Rd)
> +#define A64_ANDS_SREG(sf, shift, Rm, imm6, Rn, Rd) A64_LOGICAL_SREG(=
sf, 3, shift, 0, Rm, imm6, Rn, Rd)
> +#define A64_BICS_SREG(sf, shift, Rm, imm6, Rn, Rd) A64_LOGICAL_SREG(=
sf, 3, shift, 1, Rm, imm6, Rn, Rd)
> +
> +/* Rd =3D Rn OP Rm */
> +#define A64_AND(sf, Rd, Rn, Rm) A64_AND_SREG(sf, 0, Rm, 0, Rn, Rd)
> +#define A64_ORR(sf, Rd, Rn, Rm) A64_ORR_SREG(sf, 0, Rm, 0, Rn, Rd)
> +#define A64_EOR(sf, Rd, Rn, Rm) A64_EOR_SREG(sf, 0, Rm, 0, Rn, Rd)
> +/* Rn & Rm; set condition flags */
> +#define A64_TST(sf, Rn, Rm) A64_ANDS_SREG(sf, 0, Rm, 0, Rn, A64_ZR)
> +
> +#undef BITSMASK
> +
> +#endif /* _BPF_JIT_H */
> diff --git a/arch/arm64/net/bpf_jit_comp.c b/arch/arm64/net/bpf_jit_c=
omp.c
> new file mode 100644
> index 0000000..45ca50e
> --- /dev/null
> +++ b/arch/arm64/net/bpf_jit_comp.c
> @@ -0,0 +1,698 @@
> +/*
> + * BPF JIT compiler for ARM64
> + *
> + * Copyright (C) 2014 Zi Shen Lim <zlim.lnx@gmail.com>
> + *
> + * This program is free software; you can redistribute it and/or mod=
ify
> + * it under the terms of the GNU General Public License version 2 as
> + * published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program.  If not, see <http://www.gnu.org/license=
s/>.
> + */
> +
> +#define pr_fmt(fmt) "bpf_jit: " fmt
> +
> +#include <linux/filter.h>
> +#include <linux/moduleloader.h>
> +#include <linux/printk.h>
> +#include <linux/skbuff.h>
> +#include <linux/slab.h>
> +#include <asm/byteorder.h>
> +#include <asm/cacheflush.h>
> +
> +#include "bpf_jit.h"
> +
> +int bpf_jit_enable __read_mostly;
> +
> +#define TMP_REG_1 (MAX_BPF_REG + 0)
> +#define TMP_REG_2 (MAX_BPF_REG + 1)
> +
> +/* Map BPF registers to A64 registers */
> +static const int bpf2a64[] =3D {
> +       /* return value from in-kernel function, and exit value from =
eBPF */
> +       [BPF_REG_0] =3D A64_R(7),
> +       /* arguments from eBPF program to in-kernel function */
> +       [BPF_REG_1] =3D A64_R(0),
> +       [BPF_REG_2] =3D A64_R(1),
> +       [BPF_REG_3] =3D A64_R(2),
> +       [BPF_REG_4] =3D A64_R(3),
> +       [BPF_REG_5] =3D A64_R(4),
> +       /* callee saved registers that in-kernel function will preser=
ve */
> +       [BPF_REG_6] =3D A64_R(19),
> +       [BPF_REG_7] =3D A64_R(20),
> +       [BPF_REG_8] =3D A64_R(21),
> +       [BPF_REG_9] =3D A64_R(22),
> +       /* read-only frame pointer to access stack */
> +       [BPF_REG_FP] =3D A64_FP,
> +       /* temporary register for internal BPF JIT */
> +       [TMP_REG_1] =3D A64_R(23),
> +       [TMP_REG_2] =3D A64_R(24),
> +};
> +
> +struct jit_ctx {
> +       const struct sk_filter *prog;
> +       int idx;
> +       int tmp_used;
> +       int body_offset;
> +       int *offset;
> +       u32 *image;
> +};
> +
> +static inline void emit(const u32 insn, struct jit_ctx *ctx)
> +{
> +       if (ctx->image !=3D NULL)
> +               ctx->image[ctx->idx] =3D cpu_to_le32(insn);
> +
> +       ctx->idx++;
> +}
> +#define EMIT(insn) emit(insn, ctx)
> +
> +static inline void emit_A64_MOV_I64(const int reg, const u64 val,
> +                                   struct jit_ctx *ctx)
> +{
> +       u64 tmp =3D val;
> +       int shift =3D 0;
> +
> +       EMIT(A64_MOVZ(1, reg, tmp & 0xffff, shift));
> +       tmp >>=3D 16;
> +       shift +=3D 16;
> +       while (tmp) {
> +               if (tmp & 0xffff)
> +                       EMIT(A64_MOVK(1, reg, tmp & 0xffff, shift));
> +               tmp >>=3D 16;
> +               shift +=3D 16;
> +       }
> +}
> +#define EMIT_A64_MOV_I64(reg, val) emit_A64_MOV_I64(reg, val, ctx)
> +
> +static inline void emit_A64_MOV_I(const int is64, const int reg,
> +                                 const s32 val, struct jit_ctx *ctx)
> +{
> +       u16 hi =3D val >> 16;
> +       u16 lo =3D val & 0xffff;
> +
> +       if (hi & 0x8000) {
> +               if (hi =3D=3D 0xffff) {
> +                       EMIT(A64_MOVN(is64, reg, ~lo, 0));
> +               } else {
> +                       EMIT(A64_MOVN(is64, reg, ~hi, 16));
> +                       EMIT(A64_MOVK(is64, reg, lo, 0));
> +               }
> +       } else {
> +               EMIT(A64_MOVZ(is64, reg, lo, 0));
> +               if (hi)
> +                       EMIT(A64_MOVK(is64, reg, hi, 16));
> +       }
> +}
> +#define EMIT_A64_MOV_I(is64, reg, val) emit_A64_MOV_I(is64, reg, val=
, ctx)
> +
> +static inline int bpf2a64_offset(int bpf_to, int bpf_from,
> +                                const struct jit_ctx *ctx)
> +{
> +       int to =3D ctx->offset[bpf_to + 1];
> +       /* -1 to account for the Branch instruction */
> +       int from =3D ctx->offset[bpf_from + 1] - 1;
> +
> +       return to - from;
> +}
> +
> +static inline int epilogue_offset(const struct jit_ctx *ctx)
> +{
> +       int to =3D ctx->offset[ctx->prog->len - 1];
> +       int from =3D ctx->idx - ctx->body_offset;
> +
> +       return to - from;
> +}
> +
> +static void build_prologue(struct jit_ctx *ctx)
> +{
> +       const u8 r6 =3D bpf2a64[BPF_REG_6];
> +       const u8 r7 =3D bpf2a64[BPF_REG_7];
> +       const u8 r8 =3D bpf2a64[BPF_REG_8];
> +       const u8 r9 =3D bpf2a64[BPF_REG_9];
> +       const u8 fp =3D bpf2a64[BPF_REG_FP];
> +       const u8 ra =3D bpf2a64[BPF_REG_A];
> +       const u8 rx =3D bpf2a64[BPF_REG_X];
> +       const u8 tmp1 =3D bpf2a64[TMP_REG_1];
> +       const u8 tmp2 =3D bpf2a64[TMP_REG_2];
> +       int stack_size =3D MAX_BPF_STACK;
> +
> +       stack_size +=3D 16; /* extra for skb_copy_bit buffer */
> +
> +       /* Save callee-saved register */
> +       EMIT(A64_PUSH(r6, r7, A64_SP));
> +       EMIT(A64_PUSH(r8, r9, A64_SP));
> +       if (ctx->tmp_used)
> +               EMIT(A64_PUSH(tmp1, tmp2, A64_SP));
> +
> +       /* Set up BPF stack */
> +       EMIT(A64_SUB_I(1, A64_SP, A64_SP, stack_size));
> +
> +       /* Set up frame pointer */
> +       EMIT(A64_MOV(1, fp, A64_SP));
> +
> +       /* Clear registers A and X */
> +       EMIT_A64_MOV_I64(ra, 0);
> +       EMIT_A64_MOV_I64(rx, 0);
> +}
> +
> +static void build_epilogue(struct jit_ctx *ctx)
> +{
> +       const u8 r0 =3D bpf2a64[BPF_REG_0];
> +       const u8 r6 =3D bpf2a64[BPF_REG_6];
> +       const u8 r7 =3D bpf2a64[BPF_REG_7];
> +       const u8 r8 =3D bpf2a64[BPF_REG_8];
> +       const u8 r9 =3D bpf2a64[BPF_REG_9];
> +       const u8 fp =3D bpf2a64[BPF_REG_FP];
> +       const u8 tmp1 =3D bpf2a64[TMP_REG_1];
> +       const u8 tmp2 =3D bpf2a64[TMP_REG_2];
> +       int stack_size =3D MAX_BPF_STACK;
> +
> +       stack_size +=3D 16; /* extra for skb_copy_bit buffer */
> +
> +       /* We're done with BPF stack */
> +       EMIT(A64_ADD_I(1, A64_SP, A64_SP, stack_size));
> +
> +       /* Restore callee-saved register */
> +       if (ctx->tmp_used)
> +               EMIT(A64_POP(tmp1, tmp2, A64_SP));
> +       EMIT(A64_POP(r8, r9, A64_SP));
> +       EMIT(A64_POP(r6, r7, A64_SP));
> +
> +       /* Restore frame pointer */
> +       EMIT(A64_MOV(1, fp, A64_SP));
> +
> +       /* Set return value */
> +       EMIT(A64_MOV(1, A64_R(0), r0));
> +
> +       EMIT(A64_RET(A64_LR));
> +}
> +
> +/* From load_pointer in net/core/filter.c.
> + * XXX: should we just export it? */
> +extern void *bpf_internal_load_pointer_neg_helper(const struct sk_bu=
ff *skb,
> +                                                 int k, unsigned int=
 size);
> +static void *load_pointer_helper(const struct sk_buff *skb, int k,
> +                                unsigned int size, void *buffer)
> +{
> +       if (k >=3D 0)
> +               return skb_header_pointer(skb, k, size, buffer);
> +
> +       return bpf_internal_load_pointer_neg_helper(skb, k, size);
> +}
> +
> +static int build_insn(const struct sock_filter_int *insn, struct jit=
_ctx *ctx)
> +{
> +       const u8 code =3D insn->code;
> +       const u8 dst =3D bpf2a64[insn->dst_reg];
> +       const u8 src =3D bpf2a64[insn->src_reg];
> +       const u8 tmp =3D bpf2a64[TMP_REG_1];
> +       const u8 tmp2 =3D bpf2a64[TMP_REG_2];
> +       const s16 off =3D insn->off;
> +       const s32 imm =3D insn->imm;
> +       const int i =3D insn - ctx->prog->insnsi;
> +       const bool is64 =3D BPF_CLASS(code) =3D=3D BPF_ALU64;
> +       u8 jmp_cond;
> +       s32 jmp_offset;
> +
> +       switch (code) {
> +       /* dst =3D src */
> +       case BPF_ALU | BPF_MOV | BPF_X:
> +       case BPF_ALU64 | BPF_MOV | BPF_X:
> +               EMIT(A64_MOV(is64, dst, src));
> +               break;
> +       /* dst =3D dst OP src */
> +       case BPF_ALU | BPF_ADD | BPF_X:
> +       case BPF_ALU64 | BPF_ADD | BPF_X:
> +               EMIT(A64_ADD(is64, dst, dst, src));
> +               break;
> +       case BPF_ALU | BPF_SUB | BPF_X:
> +       case BPF_ALU64 | BPF_SUB | BPF_X:
> +               EMIT(A64_SUB(is64, dst, dst, src));
> +               break;
> +       case BPF_ALU | BPF_AND | BPF_X:
> +       case BPF_ALU64 | BPF_AND | BPF_X:
> +               EMIT(A64_AND(is64, dst, dst, src));
> +               break;
> +       case BPF_ALU | BPF_OR | BPF_X:
> +       case BPF_ALU64 | BPF_OR | BPF_X:
> +               EMIT(A64_ORR(is64, dst, dst, src));
> +               break;
> +       case BPF_ALU | BPF_XOR | BPF_X:
> +       case BPF_ALU64 | BPF_XOR | BPF_X:
> +               EMIT(A64_EOR(is64, dst, dst, src));
> +               break;
> +       case BPF_ALU | BPF_MUL | BPF_X:
> +       case BPF_ALU64 | BPF_MUL | BPF_X:
> +               EMIT(A64_MUL(is64, dst, dst, src));
> +               break;
> +       case BPF_ALU | BPF_DIV | BPF_X:
> +       case BPF_ALU64 | BPF_DIV | BPF_X:
> +               EMIT(A64_UDIV(is64, dst, dst, src));
> +               break;
> +       case BPF_ALU | BPF_MOD | BPF_X:
> +       case BPF_ALU64 | BPF_MOD | BPF_X:
> +               ctx->tmp_used =3D 1;
> +               EMIT(A64_UDIV(is64, tmp, dst, src));
> +               EMIT(A64_MUL(is64, tmp, tmp, src));
> +               EMIT(A64_SUB(is64, dst, dst, tmp));
> +               break;
> +       /* dst =3D -dst */
> +       case BPF_ALU | BPF_NEG:
> +       case BPF_ALU64 | BPF_NEG:
> +               EMIT(A64_NEG(is64, dst, dst));
> +               break;
> +       /* dst =3D BSWAP##imm(dst) */
> +       case BPF_ALU | BPF_END | BPF_FROM_LE:
> +       case BPF_ALU | BPF_END | BPF_FROM_BE:
> +#ifdef CONFIG_CPU_BIG_ENDIAN
> +               if (BPF_SRC(code) =3D=3D BPF_FROM_BE)
> +                       break;
> +#else /* !CONFIG_CPU_BIG_ENDIAN */
> +               if (BPF_SRC(code) =3D=3D BPF_FROM_LE)
> +                       break;
> +#endif
> +               switch (imm) {
> +               case 16:
> +                       EMIT(A64_REV16(is64, dst, dst));
> +                       break;
> +               case 32:
> +                       EMIT(A64_REV32(is64, dst, dst));
> +                       break;
> +               case 64:
> +                       EMIT(A64_REV64(dst, dst));
> +                       break;
> +               }
> +               break;
> +       /* dst =3D imm */
> +       case BPF_ALU | BPF_MOV | BPF_K:
> +       case BPF_ALU64 | BPF_MOV | BPF_K:
> +               EMIT_A64_MOV_I(is64, dst, imm);
> +               break;
> +       /* dst =3D dst OP imm */
> +       case BPF_ALU | BPF_ADD | BPF_K:
> +       case BPF_ALU64 | BPF_ADD | BPF_K:
> +               ctx->tmp_used =3D 1;
> +               EMIT_A64_MOV_I(is64, tmp, imm);
> +               EMIT(A64_ADD(is64, dst, dst, tmp));
> +               break;
> +       case BPF_ALU | BPF_SUB | BPF_K:
> +       case BPF_ALU64 | BPF_SUB | BPF_K:
> +               ctx->tmp_used =3D 1;
> +               EMIT_A64_MOV_I(is64, tmp, imm);
> +               EMIT(A64_SUB(is64, dst, dst, tmp));
> +               break;
> +       case BPF_ALU | BPF_AND | BPF_K:
> +       case BPF_ALU64 | BPF_AND | BPF_K:
> +               ctx->tmp_used =3D 1;
> +               EMIT_A64_MOV_I(is64, tmp, imm);
> +               EMIT(A64_AND(is64, dst, dst, tmp));
> +               break;
> +       case BPF_ALU | BPF_OR | BPF_K:
> +       case BPF_ALU64 | BPF_OR | BPF_K:
> +               ctx->tmp_used =3D 1;
> +               EMIT_A64_MOV_I(is64, tmp, imm);
> +               EMIT(A64_ORR(is64, dst, dst, tmp));
> +               break;
> +       case BPF_ALU | BPF_XOR | BPF_K:
> +       case BPF_ALU64 | BPF_XOR | BPF_K:
> +               ctx->tmp_used =3D 1;
> +               EMIT_A64_MOV_I(is64, tmp, imm);
> +               EMIT(A64_EOR(is64, dst, dst, tmp));
> +               break;
> +       case BPF_ALU | BPF_MUL | BPF_K:
> +       case BPF_ALU64 | BPF_MUL | BPF_K:
> +               ctx->tmp_used =3D 1;
> +               EMIT_A64_MOV_I(is64, tmp, imm);
> +               EMIT(A64_MUL(is64, dst, dst, tmp));
> +               break;
> +       case BPF_ALU | BPF_DIV | BPF_K:
> +       case BPF_ALU64 | BPF_DIV | BPF_K:
> +               ctx->tmp_used =3D 1;
> +               EMIT_A64_MOV_I(is64, tmp, imm);
> +               EMIT(A64_UDIV(is64, dst, dst, tmp));
> +               break;
> +       case BPF_ALU | BPF_MOD | BPF_K:
> +       case BPF_ALU64 | BPF_MOD | BPF_K:
> +               ctx->tmp_used =3D 1;
> +               EMIT_A64_MOV_I(is64, tmp2, imm);
> +               EMIT(A64_UDIV(is64, tmp, dst, tmp2));
> +               EMIT(A64_MUL(is64, tmp, tmp, tmp2));
> +               EMIT(A64_SUB(is64, dst, dst, tmp));
> +               break;
> +       case BPF_ALU | BPF_LSH | BPF_K:
> +       case BPF_ALU64 | BPF_LSH | BPF_K:
> +               EMIT(A64_LSL(is64, dst, dst, imm));
> +               break;
> +       case BPF_ALU | BPF_RSH | BPF_K:
> +       case BPF_ALU64 | BPF_RSH | BPF_K:
> +               EMIT(A64_LSR(is64, dst, dst, imm));
> +               break;
> +       case BPF_ALU | BPF_ARSH | BPF_K:
> +       case BPF_ALU64 | BPF_ARSH | BPF_K:
> +               EMIT(A64_ASR(is64, dst, dst, imm));
> +               break;
> +
> +#define check_imm19(imm) do {                                  \
> +       if (((imm > 0) && (imm >> 19)) ||                       \
> +           ((imm < 0) && (~imm >> 19))) {                      \
> +               pr_info("[%2d] imm=3D%d(0x%x) out of range\n",    \
> +                       i, imm, imm);                           \
> +               return -EINVAL;                                 \
> +       }                                                       \
> +} while (0)
> +
> +       /* JUMP off */
> +       case BPF_JMP | BPF_JA:
> +               jmp_offset =3D bpf2a64_offset(i + off, i, ctx);
> +               check_imm19(jmp_offset);
> +               EMIT(A64_B(jmp_offset));
> +               break;
> +       /* IF (dst COND src) JUMP off */
> +       case BPF_JMP | BPF_JEQ | BPF_X:
> +       case BPF_JMP | BPF_JGT | BPF_X:
> +       case BPF_JMP | BPF_JGE | BPF_X:
> +       case BPF_JMP | BPF_JNE | BPF_X:
> +       case BPF_JMP | BPF_JSGT | BPF_X:
> +       case BPF_JMP | BPF_JSGE | BPF_X:
> +               EMIT(A64_CMP(1, dst, src));
> +emit_cond_jmp:
> +               jmp_offset =3D bpf2a64_offset(i + off, i, ctx);
> +               check_imm19(jmp_offset);
> +               switch (BPF_OP(code)) {
> +               case BPF_JEQ:
> +                       jmp_cond =3D A64_COND_EQ;
> +                       break;
> +               case BPF_JGT:
> +                       jmp_cond =3D A64_COND_HI;
> +                       break;
> +               case BPF_JGE:
> +                       jmp_cond =3D A64_COND_CS;
> +                       break;
> +               case BPF_JNE:
> +                       jmp_cond =3D A64_COND_NE;
> +                       break;
> +               case BPF_JSGT:
> +                       jmp_cond =3D A64_COND_GT;
> +                       break;
> +               case BPF_JSGE:
> +                       jmp_cond =3D A64_COND_GE;
> +                       break;
> +               default:
> +                       return -EFAULT;
> +               }
> +               EMIT(A64_B_(jmp_cond, jmp_offset));
> +               break;
> +       case BPF_JMP | BPF_JSET | BPF_X:
> +               EMIT(A64_TST(1, dst, src));
> +               goto emit_cond_jmp;
> +       /* IF (dst COND imm) JUMP off */
> +       case BPF_JMP | BPF_JEQ | BPF_K:
> +       case BPF_JMP | BPF_JGT | BPF_K:
> +       case BPF_JMP | BPF_JGE | BPF_K:
> +       case BPF_JMP | BPF_JNE | BPF_K:
> +       case BPF_JMP | BPF_JSGT | BPF_K:
> +       case BPF_JMP | BPF_JSGE | BPF_K:
> +               ctx->tmp_used =3D 1;
> +               EMIT_A64_MOV_I(1, tmp, imm);
> +               EMIT(A64_CMP(1, dst, tmp));
> +               goto emit_cond_jmp;
> +       case BPF_JMP | BPF_JSET | BPF_K:
> +               ctx->tmp_used =3D 1;
> +               EMIT_A64_MOV_I(1, tmp, imm);
> +               EMIT(A64_TST(1, dst, tmp));
> +               goto emit_cond_jmp;
> +       /* function call */
> +       case BPF_JMP | BPF_CALL:
> +       {
> +               const u8 r0 =3D bpf2a64[BPF_REG_0];
> +               const u64 func =3D (u64)__bpf_call_base + imm;
> +
> +               ctx->tmp_used =3D 1;
> +               EMIT_A64_MOV_I64(tmp, func);
> +               EMIT(A64_PUSH(A64_FP, A64_LR, A64_SP));
> +               EMIT(A64_MOV(1, A64_FP, A64_SP));
> +               EMIT(A64_BLR(tmp));
> +               EMIT(A64_MOV(1, r0, A64_R(0)));
> +               EMIT(A64_POP(A64_FP, A64_LR, A64_SP));
> +               break;
> +       }
> +       /* function return */
> +       case BPF_JMP | BPF_EXIT:
> +               if (i =3D=3D ctx->prog->len - 1)
> +                       break;
> +               jmp_offset =3D epilogue_offset(ctx);
> +               check_imm19(jmp_offset);
> +               EMIT(A64_B(jmp_offset));
> +               break;
> +
> +       /* LDX: dst =3D *(size *)(src + off) */
> +       case BPF_LDX | BPF_MEM | BPF_W:
> +       case BPF_LDX | BPF_MEM | BPF_H:
> +       case BPF_LDX | BPF_MEM | BPF_B:
> +       case BPF_LDX | BPF_MEM | BPF_DW:
> +               ctx->tmp_used =3D 1;
> +               EMIT_A64_MOV_I(1, tmp, off);
> +               switch (BPF_SIZE(code)) {
> +               case BPF_W:
> +                       EMIT(A64_LDR32(dst, src, tmp));
> +                       break;
> +               case BPF_H:
> +                       EMIT(A64_LDRH(dst, src, tmp));
> +                       break;
> +               case BPF_B:
> +                       EMIT(A64_LDRB(dst, src, tmp));
> +                       break;
> +               case BPF_DW:
> +                       EMIT(A64_LDR64(dst, src, tmp));
> +                       break;
> +               }
> +               break;
> +
> +       /* ST: *(size *)(dst + off) =3D imm */
> +       case BPF_ST | BPF_MEM | BPF_W:
> +       case BPF_ST | BPF_MEM | BPF_H:
> +       case BPF_ST | BPF_MEM | BPF_B:
> +       case BPF_ST | BPF_MEM | BPF_DW:
> +               goto notyet;
> +
> +       /* STX: *(size *)(dst + off) =3D src */
> +       case BPF_STX | BPF_MEM | BPF_W:
> +       case BPF_STX | BPF_MEM | BPF_H:
> +       case BPF_STX | BPF_MEM | BPF_B:
> +       case BPF_STX | BPF_MEM | BPF_DW:
> +               ctx->tmp_used =3D 1;
> +               EMIT_A64_MOV_I(1, tmp, off);
> +               switch (BPF_SIZE(code)) {
> +               case BPF_W:
> +                       EMIT(A64_STR32(src, dst, tmp));
> +                       break;
> +               case BPF_H:
> +                       EMIT(A64_STRH(src, dst, tmp));
> +                       break;
> +               case BPF_B:
> +                       EMIT(A64_STRB(src, dst, tmp));
> +                       break;
> +               case BPF_DW:
> +                       EMIT(A64_STR64(src, dst, tmp));
> +                       break;
> +               }
> +               break;
> +       /* STX XADD: lock *(u32 *)(dst + off) +=3D src */
> +       case BPF_STX | BPF_XADD | BPF_W:
> +       /* STX XADD: lock *(u64 *)(dst + off) +=3D src */
> +       case BPF_STX | BPF_XADD | BPF_DW:
> +               goto notyet;
> +
> +       /* R0 =3D ntohx(*(size *)(((struct sk_buff *)R6)->data + imm)=
) */
> +       case BPF_LD | BPF_ABS | BPF_W:
> +       case BPF_LD | BPF_ABS | BPF_H:
> +       case BPF_LD | BPF_ABS | BPF_B:
> +       case BPF_LD | BPF_ABS | BPF_DW:
> +       /* R0 =3D ntohx(*(size *)(((struct sk_buff *)R6)->data + src =
+ imm)) */
> +       case BPF_LD | BPF_IND | BPF_W:
> +       case BPF_LD | BPF_IND | BPF_H:
> +       case BPF_LD | BPF_IND | BPF_B:
> +       case BPF_LD | BPF_IND | BPF_DW:
> +       {
> +               const u8 r0 =3D bpf2a64[BPF_REG_0]; /* r0 =3D return =
value */
> +               const u8 r6 =3D bpf2a64[BPF_REG_6]; /* r6 =3D pointer=
 to sk_buff */
> +               const u8 fp =3D bpf2a64[BPF_REG_FP];
> +               const u8 r1 =3D bpf2a64[BPF_REG_1]; /* r1: struct sk_=
buff *skb */
> +               const u8 r2 =3D bpf2a64[BPF_REG_2]; /* r2: int k */
> +               const u8 r3 =3D bpf2a64[BPF_REG_3]; /* r3: unsigned i=
nt size */
> +               const u8 r4 =3D bpf2a64[BPF_REG_4]; /* r4: void *buff=
er */
> +               const u8 r5 =3D bpf2a64[BPF_REG_5]; /* r5: void *(*fu=
nc)(...) */
> +               int size;
> +
> +               EMIT(A64_MOV(1, r1, r6));
> +               EMIT_A64_MOV_I(0, r2, imm);
> +               if (BPF_MODE(code) =3D=3D BPF_IND)
> +                       EMIT(A64_ADD(0, r2, r2, src));
> +               switch (BPF_SIZE(code)) {
> +               case BPF_W:
> +                       size =3D 4;
> +                       break;
> +               case BPF_H:
> +                       size =3D 2;
> +                       break;
> +               case BPF_B:
> +                       size =3D 1;
> +                       break;
> +               case BPF_DW:
> +                       size =3D 8;
> +                       break;
> +               default: /* Silence compiler warning about uninitiali=
zed size */
> +                       return -EINVAL;
> +               }
> +               EMIT_A64_MOV_I64(r3, size);
> +               EMIT(A64_ADD_I(1, r4, fp, MAX_BPF_STACK));
> +               EMIT_A64_MOV_I64(r5, (unsigned long)load_pointer_help=
er);
> +               EMIT(A64_PUSH(A64_FP, A64_LR, A64_SP));
> +               EMIT(A64_MOV(1, A64_FP, A64_SP));
> +               EMIT(A64_BLR(r5));
> +               EMIT(A64_MOV(1, r0, A64_R(0)));
> +               EMIT(A64_POP(A64_FP, A64_LR, A64_SP));
> +
> +               jmp_offset =3D epilogue_offset(ctx);
> +               check_imm19(jmp_offset);
> +               EMIT(A64_CBZ(1, r0, jmp_offset));
> +               EMIT(A64_MOV(1, r5, r0));
> +               switch (BPF_SIZE(code)) {
> +               case BPF_W:
> +                       EMIT(A64_LDR32(r0, r5, A64_ZR));
> +#ifndef CONFIG_CPU_BIG_ENDIAN
> +                       EMIT(A64_REV32(0, r0, r0));
> +#endif
> +                       break;
> +               case BPF_H:
> +                       EMIT(A64_LDRH(r0, r5, A64_ZR));
> +#ifndef CONFIG_CPU_BIG_ENDIAN
> +                       EMIT(A64_REV16(0, r0, r0));
> +#endif
> +                       break;
> +               case BPF_B:
> +                       EMIT(A64_LDRB(r0, r5, A64_ZR));
> +                       break;
> +               case BPF_DW:
> +                       EMIT(A64_LDR64(r0, r5, A64_ZR));
> +#ifndef CONFIG_CPU_BIG_ENDIAN
> +                       EMIT(A64_REV64(r0, r0));
> +#endif
> +                       break;
> +               }
> +               break;
> +       }
> +notyet:
> +               pr_info("*** NOT YET: opcode %02x ***\n", code);
> +               return -EFAULT;
> +
> +       default:
> +               pr_err("unknown opcode %02x\n", code);
> +               return -EINVAL;
> +       }
> +
> +       return 0;
> +}
> +
> +static int build_body(struct jit_ctx *ctx)
> +{
> +       const struct sk_filter *prog =3D ctx->prog;
> +       int i;
> +
> +       for (i =3D 0; i < prog->len; i++) {
> +               const struct sock_filter_int *insn =3D &prog->insnsi[=
i];
> +               int ret;
> +
> +               if (ctx->image =3D=3D NULL)
> +                       ctx->offset[i] =3D ctx->idx;
> +
> +               ret =3D build_insn(insn, ctx);
> +               if (ret)
> +                       return ret;
> +       }
> +
> +       return 0;
> +}
> +
> +static inline void bpf_flush_icache(void *start, void *end)
> +{
> +       flush_icache_range((unsigned long)start, (unsigned long)end);
> +}
> +
> +void bpf_jit_compile(struct sk_filter *prog)
> +{
> +       /* Nothing to do here. We support Internal BPF. */
> +}
> +
> +void bpf_int_jit_compile(struct sk_filter *prog)
> +{
> +       struct jit_ctx ctx;
> +       int image_size;
> +
> +       if (!bpf_jit_enable)
> +               return;
> +
> +       if (!prog || !prog->len)
> +               return;
> +
> +       memset(&ctx, 0, sizeof(ctx));
> +       ctx.prog =3D prog;
> +
> +       ctx.offset =3D kcalloc(prog->len, sizeof(int), GFP_KERNEL);
> +       if (ctx.offset =3D=3D NULL)
> +               return;
> +
> +       /* 1. Initial fake pass to compute ctx->idx. */
> +
> +       /* Fake pass to fill in ctx->offset. */
> +       if (build_body(&ctx))
> +               goto out;
> +
> +       build_prologue(&ctx);
> +
> +       build_epilogue(&ctx);
> +
> +       /* Now we know the actual image size. */
> +       image_size =3D sizeof(u32) * ctx.idx;
> +       ctx.image =3D module_alloc(image_size);
> +       if (unlikely(ctx.image =3D=3D NULL))
> +               goto out;
> +
> +       /* 2. Now, the actual pass. */
> +
> +       ctx.idx =3D 0;
> +       build_prologue(&ctx);
> +
> +       ctx.body_offset =3D ctx.idx;
> +       if (build_body(&ctx))
> +               goto out;
> +
> +       build_epilogue(&ctx);
> +
> +       /* And we're done. */
> +       if (bpf_jit_enable > 1)
> +               bpf_jit_dump(prog->len, image_size, 2, ctx.image);
> +
> +       bpf_flush_icache(ctx.image, ctx.image + ctx.idx);
> +       prog->bpf_func =3D (void *)ctx.image;
> +       prog->jited =3D 1;
> +
> +out:
> +       kfree(ctx.offset);
> +}
> +
> +void bpf_jit_free(struct sk_filter *prog)
> +{
> +       if (prog->jited)
> +               module_free(NULL, prog->bpf_func);
> +
> +       kfree(prog);
> +}
> +
> --
> 1.9.1
>
