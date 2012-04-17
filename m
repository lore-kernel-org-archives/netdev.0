From: Richard Mortimer <richm@oldelvet.org.uk>
Subject: Re: [PATCH] net: filter: Just In Time compiler for sparc
Date: Tue, 17 Apr 2012 19:59:57 +0100
Message-ID: <4F8DBDAD.50507@oldelvet.org.uk>
References: <20120416.225823.1395194623649559124.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sparclinux@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <20120416.225823.1395194623649559124.davem@davemloft.net>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A few points below. Mainly a couple of comments that do not match the 
code itself. I didn't spot any errors in the assembler generation itself.

Richard

On 17/04/2012 03:58, David Miller wrote:
>
> Signed-off-by: David S. Miller<davem@davemloft.net>
> ---
>
> I think I'll commit this to net-next so it's easier to track
> any BPF changes we make there.
>
>   arch/sparc/Kconfig            |    1 +
>   arch/sparc/Makefile           |    1 +
>   arch/sparc/net/Makefile       |    4 +
>   arch/sparc/net/bpf_jit.h      |   52 +++
>   arch/sparc/net/bpf_jit_asm.S  |  199 +++++++++++
>   arch/sparc/net/bpf_jit_comp.c |  785 +++++++++++++++++++++++++++++++++++++++++
>   6 files changed, 1042 insertions(+)
>   create mode 100644 arch/sparc/net/Makefile
>   create mode 100644 arch/sparc/net/bpf_jit.h
>   create mode 100644 arch/sparc/net/bpf_jit_asm.S
>   create mode 100644 arch/sparc/net/bpf_jit_comp.c
>
> diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
> index db4e821..9f9afd9 100644
> --- a/arch/sparc/Kconfig
> +++ b/arch/sparc/Kconfig
> @@ -30,6 +30,7 @@ config SPARC
>   	select USE_GENERIC_SMP_HELPERS if SMP
>   	select GENERIC_PCI_IOMAP
>   	select HAVE_NMI_WATCHDOG if SPARC64
> +	select HAVE_BPF_JIT
>
>   config SPARC32
>   	def_bool !64BIT
> diff --git a/arch/sparc/Makefile b/arch/sparc/Makefile
> index eddcfb3..0e5de13 100644
> --- a/arch/sparc/Makefile
> +++ b/arch/sparc/Makefile
> @@ -66,6 +66,7 @@ head-y                 += arch/sparc/kernel/init_task.o
>
>   core-y                 += arch/sparc/kernel/
>   core-y                 += arch/sparc/mm/ arch/sparc/math-emu/
> +core-y                 += arch/sparc/net/
>
>   libs-y                 += arch/sparc/prom/
>   libs-y                 += arch/sparc/lib/
> diff --git a/arch/sparc/net/Makefile b/arch/sparc/net/Makefile
> new file mode 100644
> index 0000000..1306a58
> --- /dev/null
> +++ b/arch/sparc/net/Makefile
> @@ -0,0 +1,4 @@
> +#
> +# Arch-specific network modules
> +#
> +obj-$(CONFIG_BPF_JIT) += bpf_jit_asm.o bpf_jit_comp.o
> diff --git a/arch/sparc/net/bpf_jit.h b/arch/sparc/net/bpf_jit.h
> new file mode 100644
> index 0000000..74f048b
> --- /dev/null
> +++ b/arch/sparc/net/bpf_jit.h
> @@ -0,0 +1,52 @@
> +#ifndef _BPF_JIT_H
> +#define _BPF_JIT_H
> +
> +/* Conventions:
> + *  %g1 : temporary
> + *  %g2 : Secondary temporary used by SKB data helper stubs.
> + *  %o0 : pointer to skb (first argument given to JIT function)
> + *  %o1 : BPF A accumulator
> + *  %o2 : BPF X accumulator
> + *  %o3 : Holds saved %o7 so we can call helper functions without needing
> + *        to allocate a register window.
> + *  %o4 : skb->data
> + *  %o5 : skb->len - skb->data_len

%o4 and %o5 are inconsistent with r_HEADLEN and r_SKBDATA below

%g3 defined as r_OFF below but not listed in conventions.

> + */
> +
> +#ifndef __ASSEMBLER__
> +#define G0		0x00
> +#define G1		0x01
> +#define G3		0x03
> +#define G6		0x06
> +#define O0		0x08
> +#define O1		0x09
> +#define O2		0x0a
> +#define O3		0x0b
> +#define O4		0x0c
> +#define O5		0x0d
> +#define SP		0x0e
> +#define O7		0x0f
> +#define FP		0x1e
> +
> +#define r_SKB		O0
> +#define r_A		O1
> +#define r_X		O2
> +#define r_saved_O7	O3
> +#define r_HEADLEN	O4
> +#define r_SKB_DATA	O5
> +#define r_TMP		G1
> +#define r_TMP2		G2
> +#define r_OFF		G3
> +#else
> +#define r_SKB		%o0
> +#define r_A		%o1
> +#define r_X		%o2
> +#define r_saved_O7	%o3
> +#define r_HEADLEN	%o4
> +#define r_SKB_DATA	%o5
> +#define r_TMP		%g1
> +#define r_TMP2		%g2
> +#define r_OFF		%g3
> +#endif
> +
> +#endif /* _BPF_JIT_H */
> diff --git a/arch/sparc/net/bpf_jit_asm.S b/arch/sparc/net/bpf_jit_asm.S
> new file mode 100644
> index 0000000..fdc6932
> --- /dev/null
> +++ b/arch/sparc/net/bpf_jit_asm.S
> @@ -0,0 +1,199 @@
> +#include<asm/ptrace.h>
> +
> +#include "bpf_jit.h"
> +
> +#ifdef CONFIG_SPARC64
> +#define SAVE_SZ		176
> +#define SCRATCH_OFF	STACK_BIAS + 128
> +#define BE_PTR(label)	be,pn %xcc, label
> +#else
> +#define SAVE_SZ		96
> +#define SCRATCH_OFF	72
> +#define BE_PTR(label)	be label
> +#endif
> +
> +#define SKF_MAX_NEG_OFF	(-0x200000) /* SKF_LL_OFF from filter.h */
> +
> +	.text
> +	.globl	bpf_jit_load_word
> +bpf_jit_load_word:
> +	cmp	r_OFF, 0
> +	bl	bpf_slow_path_word_neg
> +	 nop
> +	.globl	bpf_jit_load_word_positive_offset
> +bpf_jit_load_word_positive_offset:
> +	sub	r_HEADLEN, r_OFF, r_TMP
> +	cmp	r_TMP, 3
> +	ble	bpf_slow_path_word
> +	 add	r_SKB_DATA, r_OFF, r_TMP
> +	andcc	r_TMP, 3, %g0
> +	bne	load_word_unaligned
> +	 nop
> +	retl
> +	 ld	[r_SKB_DATA + r_OFF], r_A

This could be

ld [r_TMP], r_A

to be consistent with the use of r_TMP below.
But otherwise correct.

> +load_word_unaligned:
> +	ldub	[r_TMP + 0x0], r_OFF
> +	ldub	[r_TMP + 0x1], r_TMP2
> +	sll	r_OFF, 8, r_OFF
> +	or	r_OFF, r_TMP2, r_OFF
> +	ldub	[r_TMP + 0x2], r_TMP2
> +	sll	r_OFF, 8, r_OFF
> +	or	r_OFF, r_TMP2, r_OFF
> +	ldub	[r_TMP + 0x3], r_TMP2
> +	sll	r_OFF, 8, r_OFF
> +	retl
> +	 or	r_OFF, r_TMP2, r_A
> +
> +	.globl	bpf_jit_load_half
> +bpf_jit_load_half:
> +	cmp	r_OFF, 0
> +	bl	bpf_slow_path_half_neg
> +	 nop
> +	.globl	bpf_jit_load_half_positive_offset
> +bpf_jit_load_half_positive_offset:
> +	sub	r_HEADLEN, r_OFF, r_TMP
> +	cmp	r_TMP, 1
> +	ble	bpf_slow_path_half
> +	 add	r_SKB_DATA, r_OFF, r_TMP
> +	andcc	r_TMP, 1, %g0
> +	bne	load_half_unaligned
> +	 nop
> +	retl
> +	 lduh	[r_SKB_DATA + r_OFF], r_A

ditto for use of r_TMP

> +load_half_unaligned:
> +	ldub	[r_TMP + 0x0], r_OFF
> +	ldub	[r_TMP + 0x1], r_TMP2
> +	sll	r_OFF, 8, r_OFF
> +	retl
> +	 or	r_OFF, r_TMP2, r_A
> +
> +	.globl	bpf_jit_load_byte
> +bpf_jit_load_byte:
> +	cmp	r_OFF, 0
> +	bl	bpf_slow_path_byte_neg
> +	 nop
> +	.globl	bpf_jit_load_byte_positive_offset
> +bpf_jit_load_byte_positive_offset:
> +	cmp	r_OFF, r_HEADLEN
> +	bge	bpf_slow_path_byte
> +	 nop
> +	retl
> +	 ldub	[r_SKB_DATA + r_OFF], r_A
> +
> +	.globl	bpf_jit_load_byte_msh
> +bpf_jit_load_byte_msh:
> +	cmp	r_OFF, 0
> +	bl	bpf_slow_path_byte_msh_neg
> +	 nop
> +	.globl	bpf_jit_load_byte_msh_positive_offset
> +bpf_jit_load_byte_msh_positive_offset:
> +	cmp	r_OFF, r_HEADLEN
> +	bge	bpf_slow_path_byte_msh
> +	 nop
> +	ldub	[r_SKB_DATA + r_OFF], r_OFF
> +	and	r_OFF, 0xf, r_OFF
> +	retl
> +	 sll	r_OFF, 2, r_X
> +
> +#define bpf_slow_path_common(LEN)	\
> +	save	%sp, -SAVE_SZ, %sp;	\
> +	mov	%i0, %o0;		\
> +	mov	r_OFF, %o1;		\
> +	add	%fp, SCRATCH_OFF, %o2;	\
> +	call	skb_copy_bits;		\
> +	 mov	(LEN), %o3;		\
> +	cmp	%o0, 0;			\
> +	restore;
> +
> +bpf_slow_path_word:
> +	bpf_slow_path_common(4)
> +	bl	bpf_error
> +	 ld	[%sp + SCRATCH_OFF], r_A
> +	retl
> +	 nop
> +bpf_slow_path_half:
> +	bpf_slow_path_common(2)
> +	bl	bpf_error
> +	 lduh	[%sp + SCRATCH_OFF], r_A
> +	retl
> +	 nop
> +bpf_slow_path_byte:
> +	bpf_slow_path_common(1)
> +	bl	bpf_error
> +	 ldub	[%sp + SCRATCH_OFF], r_A
> +	retl
> +	 nop
> +bpf_slow_path_byte_msh:
> +	bpf_slow_path_common(1)
> +	bl	bpf_error
> +	 ldub	[%sp + SCRATCH_OFF], r_A
> +	and	r_OFF, 0xf, r_OFF
> +	retl
> +	 sll	r_OFF, 2, r_X
> +
> +#define bpf_negative_common(LEN)			\
> +	save	%sp, -SAVE_SZ, %sp;			\
> +	mov	%i0, %o0;				\
> +	mov	r_OFF, %o1;				\
> +	call	bpf_internal_load_pointer_neg_helper;	\
> +	 mov	(LEN), %o2;				\
> +	mov	%o0, r_TMP;				\
> +	cmp	%o0, 0;					\
> +	BE_PTR(bpf_error);				\
> +	 restore;
> +
> +bpf_slow_path_word_neg:
> +	sethi	%hi(SKF_MAX_NEG_OFF), r_TMP
> +	cmp	r_OFF, r_TMP
> +	bl	bpf_error
> +	 nop
> +	.globl	bpf_jit_load_word_negative_offset
> +bpf_jit_load_word_negative_offset:
> +	bpf_negative_common(4)
> +	andcc	r_TMP, 3, %g0
> +	bne	load_word_unaligned
> +	 nop
> +	retl
> +	 ld	[r_TMP], r_A
> +
> +bpf_slow_path_half_neg:
> +	sethi	%hi(SKF_MAX_NEG_OFF), r_TMP
> +	cmp	r_OFF, r_TMP
> +	bl	bpf_error
> +	 nop
> +	.globl	bpf_jit_load_half_negative_offset
> +bpf_jit_load_half_negative_offset:
> +	bpf_negative_common(2)
> +	andcc	r_TMP, 1, %g0
> +	bne	load_half_unaligned
> +	 nop
> +	retl
> +	 lduh	[r_TMP], r_A
> +
> +bpf_slow_path_byte_neg:
> +	sethi	%hi(SKF_MAX_NEG_OFF), r_TMP
> +	cmp	r_OFF, r_TMP
> +	bl	bpf_error
> +	 nop
> +	.globl	bpf_jit_load_byte_negative_offset
> +bpf_jit_load_byte_negative_offset:
> +	bpf_negative_common(1)
> +	retl
> +	 ldub	[r_TMP], r_A
> +
> +bpf_slow_path_byte_msh_neg:
> +	sethi	%hi(SKF_MAX_NEG_OFF), r_TMP
> +	cmp	r_OFF, r_TMP
> +	bl	bpf_error
> +	 nop
> +	.globl	bpf_jit_load_byte_msh_negative_offset
> +bpf_jit_load_byte_msh_negative_offset:
> +	bpf_negative_common(1)
> +	ldub	[r_TMP], r_OFF
> +	and	r_OFF, 0xf, r_OFF
> +	retl
> +	 sll	r_OFF, 2, r_X
> +
> +bpf_error:
> +	jmpl	r_saved_O7 + 8, %g0
> +	 clr	%o0
> diff --git a/arch/sparc/net/bpf_jit_comp.c b/arch/sparc/net/bpf_jit_comp.c
> new file mode 100644
> index 0000000..86349ca
> --- /dev/null
> +++ b/arch/sparc/net/bpf_jit_comp.c
> @@ -0,0 +1,785 @@
> +#include<linux/moduleloader.h>
> +#include<linux/workqueue.h>
> +#include<linux/netdevice.h>
> +#include<linux/filter.h>
> +#include<linux/cache.h>
> +
> +#include<asm/cacheflush.h>
> +#include<asm/ptrace.h>
> +
> +#include "bpf_jit.h"
> +
> +int bpf_jit_enable __read_mostly;
> +
> +/* assembly code in arch/sparc/net/bpf_jit_asm.S */
> +extern u32 bpf_jit_load_word[];
> +extern u32 bpf_jit_load_half[];
> +extern u32 bpf_jit_load_byte[];
> +extern u32 bpf_jit_load_byte_msh[];
> +extern u32 bpf_jit_load_word_positive_offset[];
> +extern u32 bpf_jit_load_half_positive_offset[];
> +extern u32 bpf_jit_load_byte_positive_offset[];
> +extern u32 bpf_jit_load_byte_msh_positive_offset[];
> +extern u32 bpf_jit_load_word_negative_offset[];
> +extern u32 bpf_jit_load_half_negative_offset[];
> +extern u32 bpf_jit_load_byte_negative_offset[];
> +extern u32 bpf_jit_load_byte_msh_negative_offset[];
> +
> +static inline bool is_simm13(unsigned int value)
> +{
> +	return value + 0x1000<  0x2000;
> +}
> +
> +static void bpf_flush_icache(void *start_, void *end_)
> +{
> +#ifdef CONFIG_SPARC64
> +	/* Cheetah's I-cache is fully coherent.  */
> +	if (tlb_type == spitfire) {
> +		unsigned long start = (unsigned long) start_;
> +		unsigned long end = (unsigned long) end_;
> +
> +		start&= ~7UL;
> +		end = (end + 7UL)&  ~7UL;
> +		while (start<  end) {
> +			flushi(start);
> +			start += 32;
> +		}
> +	}
> +#endif
> +}
> +
> +#define SEEN_DATAREF 1 /* might call external helpers */
> +#define SEEN_XREG    2 /* ebx is used */
> +#define SEEN_MEM     4 /* use mem[] for temporary storage */
> +
> +#define S13(X)		((X)&  0x1fff)
> +#define IMMED		0x00002000
> +#define RD(X)		((X)<<  25)
> +#define RS1(X)		((X)<<  14)
> +#define RS2(X)		((X))
> +#define OP(X)		((X)<<  30)
> +#define OP2(X)		((X)<<  22)
> +#define OP3(X)		((X)<<  19)
> +#define COND(X)		((X)<<  25)
> +#define F1(X)		OP(X)
> +#define F2(X, Y)	(OP(X) | OP2(Y))
> +#define F3(X, Y)	(OP(X) | OP3(Y))
> +
> +#define CONDN		COND (0x0)
> +#define CONDE		COND (0x1)
> +#define CONDLE		COND (0x2)
> +#define CONDL		COND (0x3)
> +#define CONDLEU		COND (0x4)
> +#define CONDCS		COND (0x5)
> +#define CONDNEG		COND (0x6)
> +#define CONDVC		COND (0x7)
> +#define CONDA		COND (0x8)
> +#define CONDNE		COND (0x9)
> +#define CONDG		COND (0xa)
> +#define CONDGE		COND (0xb)
> +#define CONDGU		COND (0xc)
> +#define CONDCC		COND (0xd)
> +#define CONDPOS		COND (0xe)
> +#define CONDVS		COND (0xf)
> +
> +#define CONDGEU		CONDCC
> +#define CONDLU		CONDCS
> +
> +#define WDISP22(X)	(((X)>>  2)&  0x3fffff)
> +
> +#define BA		(F2(0, 2) | CONDA)
> +#define BGU		(F2(0, 2) | CONDGU)
> +#define BLEU		(F2(0, 2) | CONDLEU)
> +#define BGEU		(F2(0, 2) | CONDGEU)
> +#define BLU		(F2(0, 2) | CONDLU)
> +#define BE		(F2(0, 2) | CONDE)
> +#define BNE		(F2(0, 2) | CONDNE)
> +
> +#ifdef CONFIG_SPARC64
> +#define BNE_PTR		(F2(0, 1) | CONDNE | (2<<  20))
> +#else
> +#define BNE_PTR		BNE
> +#endif
> +
> +#define SETHI(K, REG)	\
> +	(F2(0, 0x4) | RD(REG) | (((K)>>  10)&  0x3fffff))
> +#define OR_LO(K, REG)	\
> +	(F3(2, 0x02) | IMMED | RS1(REG) | ((K)&  0x3ff) | RD(REG))
> +
> +#define ADD		F3(2, 0x00)
> +#define AND		F3(2, 0x01)
> +#define ANDCC		F3(2, 0x11)
> +#define OR		F3(2, 0x02)
> +#define SUB		F3(2, 0x04)
> +#define SUBCC		F3(2, 0x14)
> +#define MUL		F3(2, 0x0a)	/* umul */
> +#define DIV		F3(2, 0x0e)	/* udiv */
> +#define SLL		F3(2, 0x25)
> +#define SRL		F3(2, 0x26)
> +#define JMPL		F3(2, 0x38)
> +#define CALL		F1(1)
> +#define BR		F2(0, 0x01)
> +#define RD_Y		F3(2, 0x28)
> +#define WR_Y		F3(2, 0x30)
> +
> +#define LD32		F3(3, 0x00)
> +#define LD8		F3(3, 0x01)
> +#define LD16		F3(3, 0x02)
> +#define LD64		F3(3, 0x0b)
> +#define ST32		F3(3, 0x04)
> +
> +#ifdef CONFIG_SPARC64
> +#define LDPTR		LD64
> +#define BASE_STACKFRAME	176
> +#else
> +#define LDPTR		LD32
> +#define BASE_STACKFRAME	96
> +#endif
> +
> +#define LD32I		(LD32 | IMMED)
> +#define LD8I		(LD8 | IMMED)
> +#define LD16I		(LD16 | IMMED)
> +#define LD64I		(LD64 | IMMED)
> +#define LDPTRI		(LDPTR | IMMED)
> +#define ST32I		(ST32 | IMMED)
> +
> +#define emit_nop()		\
> +do {				\
> +	*prog++ = SETHI(0, G0);	\
> +} while (0)
> +
> +#define emit_neg()					\
> +do {	/* sub %g0, r_A, r_A */				\
> +	*prog++ = SUB | RS1(G0) | RS2(r_A) | RD(r_A);	\
> +} while (0)
> +
> +#define emit_reg_move(FROM, TO)				\
> +do {	/* or %g0, FROM, TO */				\
> +	*prog++ = OR | RS1(G0) | RS2(FROM) | RD(TO);	\
> +} while (0)
> +
> +#define emit_clear(REG)					\
> +do {	/* or %g0, %g0, REG */				\
> +	*prog++ = OR | RS1(G0) | RS2(G0) | RD(REG);	\
> +} while (0)
> +
> +#define emit_set_const(K, REG)					\
> +do {	/* sethi %hi(K), REG */					\
> +	*prog++ = SETHI(K, REG);				\
> +	/* or REG, %lo(K), REG */				\
> +	*prog++ = OR_LO(K, REG);				\
> +} while (0)
> +
> +	/* Emit
> +	 *
> +	 * 	OP	r_A, r_X, r_A
> +	 */
> +#define emit_alu_X(OPCODE)					\
> +do {								\
> +	seen |= SEEN_XREG;					\
> +	*prog++ = OPCODE | RS1(r_A) | RS2(r_X) | RD(r_A);	\
> +} while (0)
> +
> +	/* Emit either:
> +	 *
> +	 *	OP	r_A, K, r_A
> +	 *
> +	 * or
> +	 *
> +	 *	sethi	%hi(K), r_TMP
> +	 *	or	r_TMP, %lo(K), r_TMP
> +	 *	OP	r_A, r_TMP, r_A
> +	 *
> +	 * depending upon whether K fits in a signed 13-bit
> +	 * immediate instruction field.  Emit nothing if K
> +	 * is zero.
> +	 */
> +#define emit_alu_K(OPCODE, K)					\
> +do {			   					\
> +	if (K) {						\
> +		unsigned int _insn = OPCODE;			\
> +		_insn |= RS1(r_A) | RD(r_A);			\
> +		if (is_simm13(K)) {				\
> +			*prog++ = _insn | IMMED | S13(K);	\
> +		} else {					\
> +			emit_set_const(K, r_TMP);		\
> +			*prog++ = _insn | RS2(r_TMP);		\
> +		}		  	  			\
> +	}							\
> +} while (0)
> +
> +#define emit_loadimm(K, DEST)						\
> +do {									\
> +	if (is_simm13(K)) {						\
> +		/* or %g0, K, DEST */					\
> +		*prog++ = OR | IMMED | RS1(G0) | S13(K) | RD(DEST);	\
> +	} else {							\
> +		emit_set_const(K, DEST);				\
> +	}								\
> +} while (0)
> +
> +#define emit_loadptr(BASE, STRUCT, FIELD, DEST)				\
> +do {	unsigned int _off = offsetof(STRUCT, FIELD);			\
> +	BUILD_BUG_ON(FIELD_SIZEOF(STRUCT, FIELD) != sizeof(void *));	\
> +	*prog++ = LDPTRI | RS1(BASE) | S13(_off) | RD(DEST);		\
> +} while(0)
> +
> +#define emit_load32(BASE, STRUCT, FIELD, DEST)				\
> +do {	unsigned int _off = offsetof(STRUCT, FIELD);			\
> +	BUILD_BUG_ON(FIELD_SIZEOF(STRUCT, FIELD) != sizeof(u32));	\
> +	*prog++ = LD32I | RS1(BASE) | S13(_off) | RD(DEST);		\
> +} while(0)
> +
> +#define emit_load16(BASE, STRUCT, FIELD, DEST)				\
> +do {	unsigned int _off = offsetof(STRUCT, FIELD);			\
> +	BUILD_BUG_ON(FIELD_SIZEOF(STRUCT, FIELD) != sizeof(u16));	\
> +	*prog++ = LD16I | RS1(BASE) | S13(_off) | RD(DEST);		\
> +} while(0)
> +
> +#define __emit_load8(BASE, STRUCT, FIELD, DEST)				\
> +do {	unsigned int _off = offsetof(STRUCT, FIELD);			\
> +	*prog++ = LD8I | RS1(BASE) | S13(_off) | RD(DEST);		\
> +} while(0)
> +
> +#define emit_load8(BASE, STRUCT, FIELD, DEST)				\
> +do {	BUILD_BUG_ON(FIELD_SIZEOF(STRUCT, FIELD) != sizeof(u8));	\
> +	__emit_load8(BASE, STRUCT, FIELD, DEST);			\
> +} while(0)
> +
> +#define emit_ldmem(OFF, DEST)					\
> +do {	*prog++ = LD32I | RS1(FP) | S13(-(OFF)) | RD(DEST);	\
> +} while(0)
> +
> +#define emit_stmem(OFF, SRC)					\
> +do {	*prog++ = LD32I | RS1(FP) | S13(-(OFF)) | RD(SRC);	\
> +} while(0)
> +
> +#define cpu_off		offsetof(struct thread_info, cpu)
> +
> +#ifdef CONFIG_SMP
> +#ifdef CONFIG_SPARC64
> +#define emit_load_cpu(REG)						\
> +	emit_load16(G6, struct thread_info, cpu, REG)
> +#else
> +#define emit_load_cpu(REG)						\
> +	emit_load32(G6, struct thread_info, cpu, REG)
> +#endif
> +#else
> +#define emit_load_cpu(REG)	emit_clear(REG)
> +#endif
> +
> +#define emit_skb_loadptr(FIELD, DEST) \
> +	emit_loadptr(r_SKB, struct sk_buff, FIELD, DEST)
> +#define emit_skb_load32(FIELD, DEST) \
> +	emit_load32(r_SKB, struct sk_buff, FIELD, DEST)
> +#define emit_skb_load16(FIELD, DEST) \
> +	emit_load16(r_SKB, struct sk_buff, FIELD, DEST)
> +#define __emit_skb_load8(FIELD, DEST) \
> +	__emit_load8(r_SKB, struct sk_buff, FIELD, DEST)
> +#define emit_skb_load8(FIELD, DEST) \
> +	emit_load8(r_SKB, struct sk_buff, FIELD, DEST)
> +
> +#define emit_jmpl(BASE, IMM_OFF, LREG) \
> +	*prog++ = (JMPL | IMMED | RS1(BASE) | S13(IMM_OFF) | RD(LREG))
> +
> +#define emit_call(FUNC)					\
> +do {	void *_here = image + addrs[i] - 8;		\
> +	unsigned int _off = (void *)(FUNC) - _here;	\
> +	*prog++ = CALL | (((_off)>>  2)&  0x3fffffff);	\
> +	emit_nop();					\
> +} while (0)
> +
> +#define emit_branch(BR_OPC, DEST)			\
> +do {	unsigned int _here = addrs[i] - 8;		\
> +	*prog++ = BR_OPC | WDISP22((DEST) - _here);	\
> +} while(0)
> +
> +#define emit_branch_off(BR_OPC, OFF)			\
> +do {	*prog++ = BR_OPC | WDISP22(OFF);		\
> +} while(0)
> +
> +#define emit_jump(DEST)		emit_branch(BA, DEST)
> +
> +#define emit_read_y(REG) 	*prog++ = RD_Y | RD(REG);
> +#define emit_write_y(REG) 	*prog++ = WR_Y | IMMED | RS1(REG) | S13(0);
> +
> +#define emit_cmp(R1, R2) \
> +	*prog++ = (SUBCC | RS1(R1) | RS2(R2) | RD(G0))
> +
> +#define emit_cmpi(R1, IMM) \
> +	*prog++ = (SUBCC | IMMED | RS1(R1) | S13(IMM) | RD(G0));
> +
> +#define emit_btst(R1, R2) \
> +	*prog++ = (ANDCC | RS1(R1) | RS2(R2) | RD(G0))
> +
> +#define emit_btsti(R1, IMM) \
> +	*prog++ = (ANDCC | IMMED | RS1(R1) | S13(IMM) | RD(G0));
> +
> +#define emit_sub(R1, R2, R3) \
> +	*prog++ = (SUB | RS1(R1) | RS2(R2) | RD(R3))
> +
> +#define emit_subi(R1, IMM, R3) \
> +	*prog++ = (SUB | IMMED | RS1(R1) | S13(IMM) | RD(R3))
> +
> +#define emit_add(R1, R2, R3) \
> +	*prog++ = (ADD | RS1(R1) | RS2(R2) | RD(R3))
> +
> +#define emit_addi(R1, IMM, R3) \
> +	*prog++ = (ADD | IMMED | RS1(R1) | S13(IMM) | RD(R3))
> +
> +#define emit_alloc_stack(SZ) \
> +	*prog++ = (SUB | IMMED | RS1(SP) | S13(SZ) | RD(SP))
> +
> +#define emit_release_stack(SZ) \
> +	*prog++ = (ADD | IMMED | RS1(SP) | S13(SZ) | RD(SP))
> +
> +void bpf_jit_compile(struct sk_filter *fp)
> +{
> +	unsigned int cleanup_addr, proglen, oldproglen = 0;
> +	u32 temp[8], *prog, *func, seen = 0, pass;
> +	const struct sock_filter *filter = fp->insns;
> +	int i, flen = fp->len, pc_ret0 = -1;
> +	unsigned int *addrs;
> +	void *image;
> +
> +	if (!bpf_jit_enable)
> +		return;
> +
> +	addrs = kmalloc(flen * sizeof(*addrs), GFP_KERNEL);
> +	if (addrs == NULL)
> +		return;
> +
> +	/* Before first pass, make a rough estimation of addrs[]
> +	 * each bpf instruction is translated to less than 64 bytes
> +	 */
> +	for (proglen = 0, i = 0; i<  flen; i++) {
> +		proglen += 64;
> +		addrs[i] = proglen;
> +	}
> +	cleanup_addr = proglen; /* epilogue address */
> +	image = NULL;
> +	for (pass = 0; pass<  10; pass++) {
> +		u8 seen_or_pass0 = (pass == 0) ? (SEEN_XREG | SEEN_DATAREF | SEEN_MEM) : seen;
> +
> +		/* no prologue/epilogue for trivial filters (RET something) */
> +		proglen = 0;
> +		prog = temp;
> +
> +		/* Prologue */
> +		if (seen_or_pass0) {
> +			if (seen_or_pass0&  SEEN_MEM) {
> +				unsigned int sz = BASE_STACKFRAME;
> +				sz += BPF_MEMWORDS * sizeof(u32);
> +				emit_alloc_stack(sz);
> +			}
> +
> +			/* Make sure we dont leek kernel memory. */
> +			if (seen_or_pass0&  SEEN_XREG)
> +				emit_clear(r_X);
> +
> +			/* If this filter needs to access skb data,
> +			 * load %o4 and %o4 with:

2nd %o4 should be %o5

> +			 *  %o4 = skb->len - skb->data_len
> +			 *  %o5 = skb->data
> +			 * And also back up %o7 into r_saved_O7 so we can
> +			 * invoke the stubs using 'call'.
> +			 */
> +			if (seen_or_pass0&  SEEN_DATAREF) {
> +				emit_load32(r_SKB, struct sk_buff, len, r_HEADLEN);
> +				emit_load32(r_SKB, struct sk_buff, data_len, r_TMP);
> +				emit_sub(r_HEADLEN, r_TMP, r_HEADLEN);
> +				emit_loadptr(r_SKB, struct sk_buff, data, r_SKB_DATA);
> +			}
> +		}
> +		emit_reg_move(O7, r_saved_O7);
> +
> +		switch (filter[0].code) {
> +		case BPF_S_RET_K:
> +		case BPF_S_LD_W_LEN:
> +		case BPF_S_ANC_PROTOCOL:
> +		case BPF_S_ANC_PKTTYPE:
> +		case BPF_S_ANC_IFINDEX:
> +		case BPF_S_ANC_MARK:
> +		case BPF_S_ANC_RXHASH:
> +		case BPF_S_ANC_CPU:
> +		case BPF_S_ANC_QUEUE:
> +		case BPF_S_LD_W_ABS:
> +		case BPF_S_LD_H_ABS:
> +		case BPF_S_LD_B_ABS:
> +			/* The first instruction sets the A register (or is
> +			 * a "RET 'constant'")
> +			 */
> +			break;
> +		default:
> +			/* Make sure we dont leak kernel information to the
> +			 * user.
> +			 */
> +			emit_clear(r_A); /* A = 0 */
> +		}
> +
> +		for (i = 0; i<  flen; i++) {
> +			unsigned int K = filter[i].k;
> +			unsigned int t_offset;
> +			unsigned int f_offset;
> +			u32 t_op, f_op;
> +			int ilen;
> +
> +			switch (filter[i].code) {
> +			case BPF_S_ALU_ADD_X:	/* A += X; */
> +				emit_alu_X(ADD);
> +				break;
> +			case BPF_S_ALU_ADD_K:	/* A += K; */
> +				emit_alu_K(ADD, K);
> +				break;
> +			case BPF_S_ALU_SUB_X:	/* A -= X; */
> +				emit_alu_X(SUB);
> +				break;
> +			case BPF_S_ALU_SUB_K:	/* A -= K */
> +				emit_alu_K(SUB, K);
> +				break;
> +			case BPF_S_ALU_AND_X:	/* A&= X */
> +				emit_alu_X(AND);
> +				break;
> +			case BPF_S_ALU_AND_K:	/* A&= K */
> +				emit_alu_K(AND, K);
> +				break;
> +			case BPF_S_ALU_OR_X:	/* A |= X */
> +				emit_alu_X(OR);
> +				break;
> +			case BPF_S_ALU_OR_K:	/* A |= K */
> +				emit_alu_K(OR, K);
> +				break;
> +			case BPF_S_ALU_LSH_X:	/* A<<= X */
> +				emit_alu_X(SLL);
> +				break;
> +			case BPF_S_ALU_LSH_K:	/* A<<= K */
> +				emit_alu_K(SLL, K);
> +				break;
> +			case BPF_S_ALU_RSH_X:	/* A>>= X */
> +				emit_alu_X(SRL);
> +				break;
> +			case BPF_S_ALU_RSH_K:	/* A>>= K */
> +				emit_alu_K(SRL, K);
> +				break;
> +			case BPF_S_ALU_MUL_X:	/* A *= X; */
> +				emit_alu_X(MUL);
> +				break;
> +			case BPF_S_ALU_MUL_K:	/* A *= K */
> +				emit_alu_K(MUL, K);
> +				break;
> +			case BPF_S_ALU_DIV_K:	/* A /= K */
> +				emit_alu_K(MUL, K);
> +				emit_read_y(r_A);
> +				break;
> +			case BPF_S_ALU_DIV_X:	/* A /= X; */
> +				emit_cmpi(r_X, 0);
> +				if (pc_ret0>  0) {
> +					t_offset = addrs[pc_ret0 - 1];
> +#ifdef CONFIG_SPARC32
> +					emit_branch(BE, t_offset + 20);
> +#else
> +					emit_branch(BE, t_offset + 8);
> +#endif
> +					emit_nop(); /* delay slot */
> +				} else {
> +					emit_branch_off(BNE, 16);
> +					emit_nop();
> +#ifdef CONFIG_SPARC32
> +					emit_jump(cleanup_addr + 20);
> +#else
> +					emit_jump(cleanup_addr + 8);
> +#endif
> +					emit_clear(r_A);
> +				}
> +				emit_write_y(G0);
> +#ifdef CONFIG_SPARC32
> +				emit_nop();
> +				emit_nop();
> +				emit_nop();
> +#endif
> +				emit_alu_X(DIV);
> +				break;
> +			case BPF_S_ALU_NEG:
> +				emit_neg();
> +				break;
> +			case BPF_S_RET_K:
> +				if (!K) {
> +					if (pc_ret0 == -1)
> +						pc_ret0 = i;
> +					emit_clear(r_A);
> +				} else {
> +					emit_loadimm(K, r_A);
> +				}
> +				/* Fallthrough */
> +			case BPF_S_RET_A:
> +				if (seen_or_pass0) {
> +					if (i != flen - 1) {
> +						emit_jump(cleanup_addr);
> +						emit_nop();
> +						break;
> +					}
> +					if (seen_or_pass0&  SEEN_MEM) {
> +						unsigned int sz = BASE_STACKFRAME;
> +						sz += BPF_MEMWORDS * sizeof(u32);
> +						emit_release_stack(sz);
> +					}
> +				}
> +				/* jmpl %r_saved_O7 + 8, %g0 */
> +				emit_jmpl(r_saved_O7, 8, G0);
> +				emit_reg_move(r_A, O0); /* delay slot */
> +				break;
> +			case BPF_S_MISC_TAX:
> +				seen |= SEEN_XREG;
> +				emit_reg_move(r_A, r_X);
> +				break;
> +			case BPF_S_MISC_TXA:
> +				seen |= SEEN_XREG;
> +				emit_reg_move(r_X, r_A);
> +				break;
> +			case BPF_S_ANC_CPU:
> +				emit_load_cpu(r_A);
> +				break;
> +			case BPF_S_ANC_PROTOCOL:
> +				emit_skb_load16(protocol, r_A);
> +				break;
> +#if 0
> +				/* GCC won't let us take the address of
> +				 * a bit field even though we very much
> +				 * know what we are doing here.
> +				 */
> +			case BPF_S_ANC_PKTTYPE:
> +				__emit_skb_load8(pkt_type, r_A);
> +				emit_alu_K(SRL, 5);
> +				break;
> +#endif
> +			case BPF_S_ANC_IFINDEX:
> +				emit_skb_loadptr(dev, r_A);
> +				emit_cmpi(r_A, 0);
> +				emit_branch(BNE_PTR, cleanup_addr + 4);
> +				emit_nop();
> +				emit_load32(r_A, struct net_device, ifindex, r_A);
> +				break;
> +			case BPF_S_ANC_MARK:
> +				emit_skb_load32(mark, r_A);
> +				break;
> +			case BPF_S_ANC_QUEUE:
> +				emit_skb_load16(queue_mapping, r_A);
> +				break;
> +			case BPF_S_ANC_HATYPE:
> +				emit_skb_loadptr(dev, r_A);
> +				emit_cmpi(r_A, 0);
> +				emit_branch(BNE_PTR, cleanup_addr + 4);
> +				emit_nop();
> +				emit_load16(r_A, struct net_device, type, r_A);
> +				break;
> +			case BPF_S_ANC_RXHASH:
> +				emit_skb_load32(rxhash, r_A);
> +				break;
> +
> +			case BPF_S_LD_IMM:
> +				emit_loadimm(K, r_A);
> +				break;
> +			case BPF_S_LDX_IMM:
> +				emit_loadimm(K, r_X);
> +				break;
> +			case BPF_S_LD_MEM:
> +				emit_ldmem(K * 4, r_A);
> +				break;
> +			case BPF_S_LDX_MEM:
> +				emit_ldmem(K * 4, r_X);
> +				break;
> +			case BPF_S_ST:
> +				emit_stmem(K * 4, r_A);
> +				break;
> +			case BPF_S_STX:
> +				emit_stmem(K * 4, r_X);
> +				break;
> +
> +#define CHOOSE_LOAD_FUNC(K, func) \
> +	((int)K<  0 ? ((int)K>= SKF_LL_OFF ? func##_negative_offset : func) : func##_positive_offset)
> +
> +			case BPF_S_LD_W_ABS:
> +				func = CHOOSE_LOAD_FUNC(K, bpf_jit_load_word);
> +common_load:			seen |= SEEN_DATAREF;
> +				emit_loadimm(K, r_OFF);
> +				emit_call(func);
> +				break;
> +			case BPF_S_LD_H_ABS:
> +				func = CHOOSE_LOAD_FUNC(K, bpf_jit_load_half);
> +				goto common_load;
> +			case BPF_S_LD_B_ABS:
> +				func = CHOOSE_LOAD_FUNC(K, bpf_jit_load_byte);
> +				goto common_load;
> +			case BPF_S_LDX_B_MSH:
> +				func = CHOOSE_LOAD_FUNC(K, bpf_jit_load_byte_msh);
> +				goto common_load;
> +			case BPF_S_LD_W_IND:
> +				func = bpf_jit_load_word;
> +common_load_ind:		seen |= SEEN_DATAREF | SEEN_XREG;
> +				if (K) {
> +					if (is_simm13(K)) {
> +						emit_addi(r_X, K, r_OFF);
> +					} else {
> +						emit_loadimm(K, r_TMP);
> +						emit_add(r_X, r_TMP, r_OFF);
> +					}
> +				} else {
> +					emit_reg_move(r_X, r_OFF);
> +				}
> +				emit_call(func);
> +				break;
> +			case BPF_S_LD_H_IND:
> +				func = bpf_jit_load_half;
> +				goto common_load_ind;
> +			case BPF_S_LD_B_IND:
> +				func = bpf_jit_load_byte;
> +				goto common_load_ind;
> +			case BPF_S_JMP_JA:
> +				emit_jump(addrs[i + K]);
> +				emit_nop();
> +				break;
> +
> +#define COND_SEL(CODE, TOP, FOP)	\
> +	case CODE:			\
> +		t_op = TOP;		\
> +		f_op = FOP;		\
> +		goto cond_branch
> +
> +			COND_SEL(BPF_S_JMP_JGT_K, BGU, BLEU);
> +			COND_SEL(BPF_S_JMP_JGE_K, BGEU, BLU);
> +			COND_SEL(BPF_S_JMP_JEQ_K, BE, BNE);
> +			COND_SEL(BPF_S_JMP_JSET_K, BNE, BE);
> +			COND_SEL(BPF_S_JMP_JGT_X, BGU, BLEU);
> +			COND_SEL(BPF_S_JMP_JGE_X, BGEU, BLU);
> +			COND_SEL(BPF_S_JMP_JEQ_X, BE, BNE);
> +			COND_SEL(BPF_S_JMP_JSET_X, BNE, BE);
> +
> +cond_branch:			f_offset = addrs[i + filter[i].jf];
> +				t_offset = addrs[i + filter[i].jt];
> +
> +				/* same targets, can avoid doing the test :) */
> +				if (filter[i].jt == filter[i].jf) {
> +					emit_jump(t_offset);
> +					emit_nop();
> +					break;
> +				}
> +
> +				switch (filter[i].code) {
> +				case BPF_S_JMP_JGT_X:
> +				case BPF_S_JMP_JGE_X:
> +				case BPF_S_JMP_JEQ_X:
> +					seen |= SEEN_XREG;
> +					emit_cmp(r_A, r_X);
> +					break;
> +				case BPF_S_JMP_JSET_X:
> +					seen |= SEEN_XREG;
> +					emit_btst(r_A, r_X);
> +					break;
> +				case BPF_S_JMP_JEQ_K:
> +				case BPF_S_JMP_JGT_K:
> +				case BPF_S_JMP_JGE_K:
> +					if (is_simm13(K)) {
> +						emit_cmpi(r_A, K);
> +					} else {
> +						emit_loadimm(K, r_TMP);
> +						emit_cmp(r_A, r_TMP);
> +					}
> +					break;
> +				case BPF_S_JMP_JSET_K:
> +					if (is_simm13(K)) {
> +						emit_btsti(r_A, K);
> +					} else {
> +						emit_loadimm(K, r_TMP);
> +						emit_btst(r_A, r_TMP);
> +					}
> +					break;
> +				}
> +				if (filter[i].jt != 0) {
> +					if (filter[i].jf)
> +						t_offset += 8;
> +					emit_branch(t_op, t_offset);
> +					emit_nop(); /* delay slot */
> +					if (filter[i].jf) {
> +						emit_jump(f_offset);
> +						emit_nop();
> +					}
> +					break;
> +				}
> +				emit_branch(f_op, f_offset);
> +				emit_nop(); /* delay slot */
> +				break;
> +
> +			default:
> +				/* hmm, too complex filter, give up with jit compiler */
> +				goto out;
> +			}
> +			ilen = (void *) prog - (void *) temp;
> +			if (image) {
> +				if (unlikely(proglen + ilen>  oldproglen)) {
> +					pr_err("bpb_jit_compile fatal error\n");
> +					kfree(addrs);
> +					module_free(NULL, image);
> +					return;
> +				}
> +				memcpy(image + proglen, temp, ilen);
> +			}
> +			proglen += ilen;
> +			addrs[i] = proglen;
> +			prog = temp;
> +		}
> +		/* last bpf instruction is always a RET :
> +		 * use it to give the cleanup instruction(s) addr
> +		 */
> +		cleanup_addr = proglen - 8; /* jmpl; mov r_A,%o0; */
> +		if (seen_or_pass0&  SEEN_MEM)
> +			cleanup_addr -= 4; /* add %sp, X, %sp; */
> +
> +		if (image) {
> +			if (proglen != oldproglen)
> +				pr_err("bpb_jit_compile proglen=%u != oldproglen=%u\n",
> +				       proglen, oldproglen);
> +			break;
> +		}
> +		if (proglen == oldproglen) {
> +			image = module_alloc(max_t(unsigned int,
> +						   proglen,
> +						   sizeof(struct work_struct)));
> +			if (!image)
> +				goto out;
> +		}
> +		oldproglen = proglen;
> +	}
> +
> +	if (bpf_jit_enable>  1)
> +		pr_err("flen=%d proglen=%u pass=%d image=%p\n",
> +		       flen, proglen, pass, image);
> +
> +	if (image) {
> +		if (bpf_jit_enable>  1)
> +			print_hex_dump(KERN_ERR, "JIT code: ", DUMP_PREFIX_ADDRESS,
> +				       16, 1, image, proglen, false);
> +		bpf_flush_icache(image, image + proglen);
> +		fp->bpf_func = (void *)image;
> +	}
> +out:
> +	kfree(addrs);
> +	return;
> +}
> +
> +static void jit_free_defer(struct work_struct *arg)
> +{
> +	module_free(NULL, arg);
> +}
> +
> +/* run from softirq, we must use a work_struct to call
> + * module_free() from process context
> + */
> +void bpf_jit_free(struct sk_filter *fp)
> +{
> +	if (fp->bpf_func != sk_run_filter) {
> +		struct work_struct *work = (struct work_struct *)fp->bpf_func;
> +
> +		INIT_WORK(work, jit_free_defer);
> +		schedule_work(work);
> +	}
> +}
