From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/2] sparc64: Add eBPF JIT.
Date: Fri, 21 Apr 2017 20:17:11 -0700 (PDT)
Message-ID: <20170421.201711.317784995765325131.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@kernel.org, daniel@iogearbox.net
To: sparclinux@vger.kernel.org
Return-path: <sparclinux-owner@vger.kernel.org>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This is an eBPF JIT for sparc64.  All major features are supported.

All tests under tools/testing/selftests/bpf/ pass.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 arch/sparc/Kconfig                            |    3 +-
 arch/sparc/net/bpf_jit_32.h                   |    2 +-
 arch/sparc/net/{bpf_jit_32.h => bpf_jit_64.h} |   56 +-
 arch/sparc/net/bpf_jit_asm_32.S               |    7 -
 arch/sparc/net/bpf_jit_asm_64.S               |  162 +++-
 arch/sparc/net/bpf_jit_comp_32.c              |   49 -
 arch/sparc/net/bpf_jit_comp_64.c              | 1194 ++++++++++++++++++++++++-
 7 files changed, 1384 insertions(+), 89 deletions(-)
 copy arch/sparc/net/{bpf_jit_32.h => bpf_jit_64.h} (53%)

diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index a59deae..7b16251 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -31,7 +31,8 @@ config SPARC
 	select ARCH_WANT_IPC_PARSE_VERSION
 	select GENERIC_PCI_IOMAP
 	select HAVE_NMI_WATCHDOG if SPARC64
-	select HAVE_CBPF_JIT
+	select HAVE_CBPF_JIT if SPARC32
+	select HAVE_EBPF_JIT if SPARC64
 	select HAVE_DEBUG_BUGVERBOSE
 	select GENERIC_SMP_IDLE_THREAD
 	select GENERIC_CLOCKEVENTS
diff --git a/arch/sparc/net/bpf_jit_32.h b/arch/sparc/net/bpf_jit_32.h
index 33d6b37..d5c069b 100644
--- a/arch/sparc/net/bpf_jit_32.h
+++ b/arch/sparc/net/bpf_jit_32.h
@@ -39,7 +39,7 @@
 #define r_TMP2		G2
 #define r_OFF		G3
 
-/* assembly code in arch/sparc/net/bpf_jit_asm.S */
+/* assembly code in arch/sparc/net/bpf_jit_asm_32.S */
 extern u32 bpf_jit_load_word[];
 extern u32 bpf_jit_load_half[];
 extern u32 bpf_jit_load_byte[];
diff --git a/arch/sparc/net/bpf_jit_32.h b/arch/sparc/net/bpf_jit_64.h
similarity index 53%
copy from arch/sparc/net/bpf_jit_32.h
copy to arch/sparc/net/bpf_jit_64.h
index 33d6b37..74abd45 100644
--- a/arch/sparc/net/bpf_jit_32.h
+++ b/arch/sparc/net/bpf_jit_64.h
@@ -1,24 +1,13 @@
 #ifndef _BPF_JIT_H
 #define _BPF_JIT_H
 
-/* Conventions:
- *  %g1 : temporary
- *  %g2 : Secondary temporary used by SKB data helper stubs.
- *  %g3 : packet offset passed into SKB data helper stubs.
- *  %o0 : pointer to skb (first argument given to JIT function)
- *  %o1 : BPF A accumulator
- *  %o2 : BPF X accumulator
- *  %o3 : Holds saved %o7 so we can call helper functions without needing
- *        to allocate a register window.
- *  %o4 : skb->len - skb->data_len
- *  %o5 : skb->data
- */
-
 #ifndef __ASSEMBLER__
 #define G0		0x00
 #define G1		0x01
+#define G2		0x02
 #define G3		0x03
 #define G6		0x06
+#define G7		0x07
 #define O0		0x08
 #define O1		0x09
 #define O2		0x0a
@@ -27,19 +16,30 @@
 #define O5		0x0d
 #define SP		0x0e
 #define O7		0x0f
+#define L0		0x10
+#define L1		0x11
+#define L2		0x12
+#define L3		0x13
+#define L4		0x14
+#define L5		0x15
+#define L6		0x16
+#define L7		0x17
+#define I0		0x18
+#define I1		0x19
+#define I2		0x1a
+#define I3		0x1b
+#define I4		0x1c
+#define I5		0x1d
 #define FP		0x1e
+#define I7		0x1f
 
-#define r_SKB		O0
-#define r_A		O1
-#define r_X		O2
-#define r_saved_O7	O3
-#define r_HEADLEN	O4
-#define r_SKB_DATA	O5
+#define r_SKB		L0
+#define r_HEADLEN	L4
+#define r_SKB_DATA	L5
 #define r_TMP		G1
-#define r_TMP2		G2
-#define r_OFF		G3
+#define r_TMP2		G3
 
-/* assembly code in arch/sparc/net/bpf_jit_asm.S */
+/* assembly code in arch/sparc/net/bpf_jit_asm_64.S */
 extern u32 bpf_jit_load_word[];
 extern u32 bpf_jit_load_half[];
 extern u32 bpf_jit_load_byte[];
@@ -54,15 +54,13 @@ extern u32 bpf_jit_load_byte_negative_offset[];
 extern u32 bpf_jit_load_byte_msh_negative_offset[];
 
 #else
+#define r_RESULT	%o0
 #define r_SKB		%o0
-#define r_A		%o1
-#define r_X		%o2
-#define r_saved_O7	%o3
-#define r_HEADLEN	%o4
-#define r_SKB_DATA	%o5
+#define r_OFF		%o1
+#define r_HEADLEN	%l4
+#define r_SKB_DATA	%l5
 #define r_TMP		%g1
-#define r_TMP2		%g2
-#define r_OFF		%g3
+#define r_TMP2		%g3
 #endif
 
 #endif /* _BPF_JIT_H */
diff --git a/arch/sparc/net/bpf_jit_asm_32.S b/arch/sparc/net/bpf_jit_asm_32.S
index 5632cdc..dcc402f 100644
--- a/arch/sparc/net/bpf_jit_asm_32.S
+++ b/arch/sparc/net/bpf_jit_asm_32.S
@@ -2,17 +2,10 @@
 
 #include "bpf_jit_32.h"
 
-#ifdef CONFIG_SPARC64
-#define SAVE_SZ		176
-#define SCRATCH_OFF	STACK_BIAS + 128
-#define BE_PTR(label)	be,pn %xcc, label
-#define SIGN_EXTEND(reg)	sra reg, 0, reg
-#else
 #define SAVE_SZ		96
 #define SCRATCH_OFF	72
 #define BE_PTR(label)	be label
 #define SIGN_EXTEND(reg)
-#endif
 
 #define SKF_MAX_NEG_OFF	(-0x200000) /* SKF_LL_OFF from filter.h */
 
diff --git a/arch/sparc/net/bpf_jit_asm_64.S b/arch/sparc/net/bpf_jit_asm_64.S
index 6fb023f..3b3f146 100644
--- a/arch/sparc/net/bpf_jit_asm_64.S
+++ b/arch/sparc/net/bpf_jit_asm_64.S
@@ -1 +1,161 @@
-#include "bpf_jit_asm_32.S"
+#include <asm/ptrace.h>
+
+#include "bpf_jit_64.h"
+
+#define SAVE_SZ		176
+#define SCRATCH_OFF	STACK_BIAS + 128
+#define BE_PTR(label)	be,pn %xcc, label
+#define SIGN_EXTEND(reg)	sra reg, 0, reg
+
+#define SKF_MAX_NEG_OFF	(-0x200000) /* SKF_LL_OFF from filter.h */
+
+	.text
+	.globl	bpf_jit_load_word
+bpf_jit_load_word:
+	cmp	r_OFF, 0
+	bl	bpf_slow_path_word_neg
+	 nop
+	.globl	bpf_jit_load_word_positive_offset
+bpf_jit_load_word_positive_offset:
+	sub	r_HEADLEN, r_OFF, r_TMP
+	cmp	r_TMP, 3
+	ble	bpf_slow_path_word
+	 add	r_SKB_DATA, r_OFF, r_TMP
+	andcc	r_TMP, 3, %g0
+	bne	load_word_unaligned
+	 nop
+	retl
+	 ld	[r_TMP], r_RESULT
+load_word_unaligned:
+	ldub	[r_TMP + 0x0], r_OFF
+	ldub	[r_TMP + 0x1], r_TMP2
+	sll	r_OFF, 8, r_OFF
+	or	r_OFF, r_TMP2, r_OFF
+	ldub	[r_TMP + 0x2], r_TMP2
+	sll	r_OFF, 8, r_OFF
+	or	r_OFF, r_TMP2, r_OFF
+	ldub	[r_TMP + 0x3], r_TMP2
+	sll	r_OFF, 8, r_OFF
+	retl
+	 or	r_OFF, r_TMP2, r_RESULT
+
+	.globl	bpf_jit_load_half
+bpf_jit_load_half:
+	cmp	r_OFF, 0
+	bl	bpf_slow_path_half_neg
+	 nop
+	.globl	bpf_jit_load_half_positive_offset
+bpf_jit_load_half_positive_offset:
+	sub	r_HEADLEN, r_OFF, r_TMP
+	cmp	r_TMP, 1
+	ble	bpf_slow_path_half
+	 add	r_SKB_DATA, r_OFF, r_TMP
+	andcc	r_TMP, 1, %g0
+	bne	load_half_unaligned
+	 nop
+	retl
+	 lduh	[r_TMP], r_RESULT
+load_half_unaligned:
+	ldub	[r_TMP + 0x0], r_OFF
+	ldub	[r_TMP + 0x1], r_TMP2
+	sll	r_OFF, 8, r_OFF
+	retl
+	 or	r_OFF, r_TMP2, r_RESULT
+
+	.globl	bpf_jit_load_byte
+bpf_jit_load_byte:
+	cmp	r_OFF, 0
+	bl	bpf_slow_path_byte_neg
+	 nop
+	.globl	bpf_jit_load_byte_positive_offset
+bpf_jit_load_byte_positive_offset:
+	cmp	r_OFF, r_HEADLEN
+	bge	bpf_slow_path_byte
+	 nop
+	retl
+	 ldub	[r_SKB_DATA + r_OFF], r_RESULT
+
+#define bpf_slow_path_common(LEN)	\
+	save	%sp, -SAVE_SZ, %sp;	\
+	mov	%i0, %o0;		\
+	mov	%i1, %o1;		\
+	add	%fp, SCRATCH_OFF, %o2;	\
+	call	skb_copy_bits;		\
+	 mov	(LEN), %o3;		\
+	cmp	%o0, 0;			\
+	restore;
+
+bpf_slow_path_word:
+	bpf_slow_path_common(4)
+	bl	bpf_error
+	 ld	[%sp + SCRATCH_OFF], r_RESULT
+	retl
+	 nop
+bpf_slow_path_half:
+	bpf_slow_path_common(2)
+	bl	bpf_error
+	 lduh	[%sp + SCRATCH_OFF], r_RESULT
+	retl
+	 nop
+bpf_slow_path_byte:
+	bpf_slow_path_common(1)
+	bl	bpf_error
+	 ldub	[%sp + SCRATCH_OFF], r_RESULT
+	retl
+	 nop
+
+#define bpf_negative_common(LEN)			\
+	save	%sp, -SAVE_SZ, %sp;			\
+	mov	%i0, %o0;				\
+	mov	%i1, %o1;				\
+	SIGN_EXTEND(%o1);				\
+	call	bpf_internal_load_pointer_neg_helper;	\
+	 mov	(LEN), %o2;				\
+	mov	%o0, r_TMP;				\
+	cmp	%o0, 0;					\
+	BE_PTR(bpf_error);				\
+	 restore;
+
+bpf_slow_path_word_neg:
+	sethi	%hi(SKF_MAX_NEG_OFF), r_TMP
+	cmp	r_OFF, r_TMP
+	bl	bpf_error
+	 nop
+	.globl	bpf_jit_load_word_negative_offset
+bpf_jit_load_word_negative_offset:
+	bpf_negative_common(4)
+	andcc	r_TMP, 3, %g0
+	bne	load_word_unaligned
+	 nop
+	retl
+	 ld	[r_TMP], r_RESULT
+
+bpf_slow_path_half_neg:
+	sethi	%hi(SKF_MAX_NEG_OFF), r_TMP
+	cmp	r_OFF, r_TMP
+	bl	bpf_error
+	 nop
+	.globl	bpf_jit_load_half_negative_offset
+bpf_jit_load_half_negative_offset:
+	bpf_negative_common(2)
+	andcc	r_TMP, 1, %g0
+	bne	load_half_unaligned
+	 nop
+	retl
+	 lduh	[r_TMP], r_RESULT
+
+bpf_slow_path_byte_neg:
+	sethi	%hi(SKF_MAX_NEG_OFF), r_TMP
+	cmp	r_OFF, r_TMP
+	bl	bpf_error
+	 nop
+	.globl	bpf_jit_load_byte_negative_offset
+bpf_jit_load_byte_negative_offset:
+	bpf_negative_common(1)
+	retl
+	 ldub	[r_TMP], r_RESULT
+
+bpf_error:
+	/* Make the JIT program itself return zero. */
+	ret
+	restore	%g0, %g0, %o0
diff --git a/arch/sparc/net/bpf_jit_comp_32.c b/arch/sparc/net/bpf_jit_comp_32.c
index 83fc41d..d193748 100644
--- a/arch/sparc/net/bpf_jit_comp_32.c
+++ b/arch/sparc/net/bpf_jit_comp_32.c
@@ -17,24 +17,6 @@ static inline bool is_simm13(unsigned int value)
 	return value + 0x1000 < 0x2000;
 }
 
-static void bpf_flush_icache(void *start_, void *end_)
-{
-#ifdef CONFIG_SPARC64
-	/* Cheetah's I-cache is fully coherent.  */
-	if (tlb_type == spitfire) {
-		unsigned long start = (unsigned long) start_;
-		unsigned long end = (unsigned long) end_;
-
-		start &= ~7UL;
-		end = (end + 7UL) & ~7UL;
-		while (start < end) {
-			flushi(start);
-			start += 32;
-		}
-	}
-#endif
-}
-
 #define SEEN_DATAREF 1 /* might call external helpers */
 #define SEEN_XREG    2 /* ebx is used */
 #define SEEN_MEM     4 /* use mem[] for temporary storage */
@@ -82,11 +64,7 @@ static void bpf_flush_icache(void *start_, void *end_)
 #define BE		(F2(0, 2) | CONDE)
 #define BNE		(F2(0, 2) | CONDNE)
 
-#ifdef CONFIG_SPARC64
-#define BE_PTR		(F2(0, 1) | CONDE | (2 << 20))
-#else
 #define BE_PTR		BE
-#endif
 
 #define SETHI(K, REG)	\
 	(F2(0, 0x4) | RD(REG) | (((K) >> 10) & 0x3fffff))
@@ -116,13 +94,8 @@ static void bpf_flush_icache(void *start_, void *end_)
 #define LD64		F3(3, 0x0b)
 #define ST32		F3(3, 0x04)
 
-#ifdef CONFIG_SPARC64
-#define LDPTR		LD64
-#define BASE_STACKFRAME	176
-#else
 #define LDPTR		LD32
 #define BASE_STACKFRAME	96
-#endif
 
 #define LD32I		(LD32 | IMMED)
 #define LD8I		(LD8 | IMMED)
@@ -234,11 +207,7 @@ do {	BUILD_BUG_ON(FIELD_SIZEOF(STRUCT, FIELD) != sizeof(u8));	\
 	__emit_load8(BASE, STRUCT, FIELD, DEST);			\
 } while (0)
 
-#ifdef CONFIG_SPARC64
-#define BIAS (STACK_BIAS - 4)
-#else
 #define BIAS (-4)
-#endif
 
 #define emit_ldmem(OFF, DEST)						\
 do {	*prog++ = LD32I | RS1(SP) | S13(BIAS - (OFF)) | RD(DEST);	\
@@ -249,13 +218,8 @@ do {	*prog++ = ST32I | RS1(SP) | S13(BIAS - (OFF)) | RD(SRC);	\
 } while (0)
 
 #ifdef CONFIG_SMP
-#ifdef CONFIG_SPARC64
-#define emit_load_cpu(REG)						\
-	emit_load16(G6, struct thread_info, cpu, REG)
-#else
 #define emit_load_cpu(REG)						\
 	emit_load32(G6, struct thread_info, cpu, REG)
-#endif
 #else
 #define emit_load_cpu(REG)	emit_clear(REG)
 #endif
@@ -486,7 +450,6 @@ void bpf_jit_compile(struct bpf_prog *fp)
 				if (K == 1)
 					break;
 				emit_write_y(G0);
-#ifdef CONFIG_SPARC32
 				/* The Sparc v8 architecture requires
 				 * three instructions between a %y
 				 * register write and the first use.
@@ -494,31 +457,21 @@ void bpf_jit_compile(struct bpf_prog *fp)
 				emit_nop();
 				emit_nop();
 				emit_nop();
-#endif
 				emit_alu_K(DIV, K);
 				break;
 			case BPF_ALU | BPF_DIV | BPF_X:	/* A /= X; */
 				emit_cmpi(r_X, 0);
 				if (pc_ret0 > 0) {
 					t_offset = addrs[pc_ret0 - 1];
-#ifdef CONFIG_SPARC32
 					emit_branch(BE, t_offset + 20);
-#else
-					emit_branch(BE, t_offset + 8);
-#endif
 					emit_nop(); /* delay slot */
 				} else {
 					emit_branch_off(BNE, 16);
 					emit_nop();
-#ifdef CONFIG_SPARC32
 					emit_jump(cleanup_addr + 20);
-#else
-					emit_jump(cleanup_addr + 8);
-#endif
 					emit_clear(r_A);
 				}
 				emit_write_y(G0);
-#ifdef CONFIG_SPARC32
 				/* The Sparc v8 architecture requires
 				 * three instructions between a %y
 				 * register write and the first use.
@@ -526,7 +479,6 @@ void bpf_jit_compile(struct bpf_prog *fp)
 				emit_nop();
 				emit_nop();
 				emit_nop();
-#endif
 				emit_alu_X(DIV);
 				break;
 			case BPF_ALU | BPF_NEG:
@@ -797,7 +749,6 @@ cond_branch:			f_offset = addrs[i + filter[i].jf];
 		bpf_jit_dump(flen, proglen, pass + 1, image);
 
 	if (image) {
-		bpf_flush_icache(image, image + proglen);
 		fp->bpf_func = (void *)image;
 		fp->jited = 1;
 	}
diff --git a/arch/sparc/net/bpf_jit_comp_64.c b/arch/sparc/net/bpf_jit_comp_64.c
index 49b5f65..4c59087 100644
--- a/arch/sparc/net/bpf_jit_comp_64.c
+++ b/arch/sparc/net/bpf_jit_comp_64.c
@@ -1 +1,1193 @@
-#include "bpf_jit_comp_32.c"
+#include <linux/moduleloader.h>
+#include <linux/workqueue.h>
+#include <linux/netdevice.h>
+#include <linux/filter.h>
+#include <linux/bpf.h>
+#include <linux/cache.h>
+#include <linux/if_vlan.h>
+
+#include <asm/cacheflush.h>
+#include <asm/ptrace.h>
+
+#include "bpf_jit_64.h"
+
+int bpf_jit_enable __read_mostly;
+
+static inline bool is_simm13(unsigned int value)
+{
+	return value + 0x1000 < 0x2000;
+}
+
+static void bpf_flush_icache(void *start_, void *end_)
+{
+	/* Cheetah's I-cache is fully coherent.  */
+	if (tlb_type == spitfire) {
+		unsigned long start = (unsigned long) start_;
+		unsigned long end = (unsigned long) end_;
+
+		start &= ~7UL;
+		end = (end + 7UL) & ~7UL;
+		while (start < end) {
+			flushi(start);
+			start += 32;
+		}
+	}
+}
+
+#define SEEN_DATAREF 1 /* might call external helpers */
+#define SEEN_XREG    2 /* ebx is used */
+#define SEEN_MEM     4 /* use mem[] for temporary storage */
+
+#define S13(X)		((X) & 0x1fff)
+#define IMMED		0x00002000
+#define RD(X)		((X) << 25)
+#define RS1(X)		((X) << 14)
+#define RS2(X)		((X))
+#define OP(X)		((X) << 30)
+#define OP2(X)		((X) << 22)
+#define OP3(X)		((X) << 19)
+#define COND(X)		((X) << 25)
+#define F1(X)		OP(X)
+#define F2(X, Y)	(OP(X) | OP2(Y))
+#define F3(X, Y)	(OP(X) | OP3(Y))
+#define ASI(X)		(((X) & 0xff) << 5)
+
+#define CONDN		COND(0x0)
+#define CONDE		COND(0x1)
+#define CONDLE		COND(0x2)
+#define CONDL		COND(0x3)
+#define CONDLEU		COND(0x4)
+#define CONDCS		COND(0x5)
+#define CONDNEG		COND(0x6)
+#define CONDVC		COND(0x7)
+#define CONDA		COND(0x8)
+#define CONDNE		COND(0x9)
+#define CONDG		COND(0xa)
+#define CONDGE		COND(0xb)
+#define CONDGU		COND(0xc)
+#define CONDCC		COND(0xd)
+#define CONDPOS		COND(0xe)
+#define CONDVS		COND(0xf)
+
+#define CONDGEU		CONDCC
+#define CONDLU		CONDCS
+
+#define WDISP22(X)	(((X) >> 2) & 0x3fffff)
+#define WDISP19(X)	(((X) >> 2) & 0x7ffff)
+
+#define ANNUL		(1 << 29)
+#define XCC		(1 << 21)
+
+#define BRANCH		(F2(0, 1) | XCC)
+
+#define BA		(BRANCH | CONDA)
+#define BG		(BRANCH | CONDG)
+#define BGU		(BRANCH | CONDGU)
+#define BLEU		(BRANCH | CONDLEU)
+#define BGE		(BRANCH | CONDGE)
+#define BGEU		(BRANCH | CONDGEU)
+#define BLU		(BRANCH | CONDLU)
+#define BE		(BRANCH | CONDE)
+#define BNE		(BRANCH | CONDNE)
+
+#define SETHI(K, REG)	\
+	(F2(0, 0x4) | RD(REG) | (((K) >> 10) & 0x3fffff))
+#define OR_LO(K, REG)	\
+	(F3(2, 0x02) | IMMED | RS1(REG) | ((K) & 0x3ff) | RD(REG))
+
+#define ADD		F3(2, 0x00)
+#define AND		F3(2, 0x01)
+#define ANDCC		F3(2, 0x11)
+#define OR		F3(2, 0x02)
+#define XOR		F3(2, 0x03)
+#define SUB		F3(2, 0x04)
+#define SUBCC		F3(2, 0x14)
+#define MUL		F3(2, 0x0a)
+#define MULX		F3(2, 0x09)
+#define UDIVX		F3(2, 0x0d)
+#define DIV		F3(2, 0x0e)
+#define SLL		F3(2, 0x25)
+#define SLLX		(F3(2, 0x25)|(1<<12))
+#define SRA		F3(2, 0x27)
+#define SRAX		(F3(2, 0x27)|(1<<12))
+#define SRL		F3(2, 0x26)
+#define SRLX		(F3(2, 0x26)|(1<<12))
+#define JMPL		F3(2, 0x38)
+#define SAVE		F3(2, 0x3c)
+#define RESTORE		F3(2, 0x3d)
+#define CALL		F1(1)
+#define BR		F2(0, 0x01)
+#define RD_Y		F3(2, 0x28)
+#define WR_Y		F3(2, 0x30)
+
+#define LD32		F3(3, 0x00)
+#define LD8		F3(3, 0x01)
+#define LD16		F3(3, 0x02)
+#define LD64		F3(3, 0x0b)
+#define LD64A		F3(3, 0x1b)
+#define ST8		F3(3, 0x05)
+#define ST16		F3(3, 0x06)
+#define ST32		F3(3, 0x04)
+#define ST64		F3(3, 0x0e)
+
+#define CAS		F3(3, 0x3c)
+#define CASX		F3(3, 0x3e)
+
+#define LDPTR		LD64
+#define BASE_STACKFRAME	176
+
+#define LD32I		(LD32 | IMMED)
+#define LD8I		(LD8 | IMMED)
+#define LD16I		(LD16 | IMMED)
+#define LD64I		(LD64 | IMMED)
+#define LDPTRI		(LDPTR | IMMED)
+#define ST32I		(ST32 | IMMED)
+
+struct jit_ctx {
+	struct bpf_prog		*prog;
+	unsigned int		*offset;
+	int			idx;
+	int			epilogue_offset;
+	bool 			tmp_1_used;
+	bool 			tmp_2_used;
+	bool 			tmp_3_used;
+	bool			saw_ld_abs_ind;
+	bool			saw_frame_pointer;
+	bool			saw_call;
+	bool			saw_tail_call;
+	u32			*image;
+};
+
+#define TMP_REG_1	(MAX_BPF_JIT_REG + 0)
+#define TMP_REG_2	(MAX_BPF_JIT_REG + 1)
+#define SKB_HLEN_REG	(MAX_BPF_JIT_REG + 2)
+#define SKB_DATA_REG	(MAX_BPF_JIT_REG + 3)
+#define TMP_REG_3	(MAX_BPF_JIT_REG + 4)
+
+/* Map BPF registers to SPARC registers */
+static const int bpf2sparc[] = {
+	/* return value from in-kernel function, and exit value from eBPF */
+	[BPF_REG_0] = O5,
+
+	/* arguments from eBPF program to in-kernel function */
+	[BPF_REG_1] = O0,
+	[BPF_REG_2] = O1,
+	[BPF_REG_3] = O2,
+	[BPF_REG_4] = O3,
+	[BPF_REG_5] = O4,
+
+	/* callee saved registers that in-kernel function will preserve */
+	[BPF_REG_6] = L0,
+	[BPF_REG_7] = L1,
+	[BPF_REG_8] = L2,
+	[BPF_REG_9] = L3,
+
+	/* read-only frame pointer to access stack */
+	[BPF_REG_FP] = L6,
+
+	[BPF_REG_AX] = G7,
+
+	/* temporary register for internal BPF JIT */
+	[TMP_REG_1] = G1,
+	[TMP_REG_2] = G2,
+	[TMP_REG_3] = G3,
+
+	[SKB_HLEN_REG] = L4,
+	[SKB_DATA_REG] = L5,
+};
+
+static void emit(const u32 insn, struct jit_ctx *ctx)
+{
+	if (ctx->image != NULL)
+		ctx->image[ctx->idx] = insn;
+
+	ctx->idx++;
+}
+
+static void emit_call(u32 *func, struct jit_ctx *ctx)
+{
+	if (ctx->image != NULL) {
+		void *here = &ctx->image[ctx->idx];
+		unsigned int off;
+
+		off = (void *)func - here;
+		ctx->image[ctx->idx] = CALL | ((off >> 2) & 0x3fffffff);
+	}
+	ctx->idx++;
+}
+
+static void emit_nop(struct jit_ctx *ctx)
+{
+	emit(SETHI(0, G0), ctx);
+}
+
+static void emit_reg_move(u32 from, u32 to, struct jit_ctx *ctx)
+{
+	emit(OR | RS1(G0) | RS2(from) | RD(to), ctx);
+}
+
+/* Emit 32-bit constant, zero extended. */
+static void emit_set_const(s32 K, u32 reg, struct jit_ctx *ctx)
+{
+	emit(SETHI(K, reg), ctx);
+	emit(OR_LO(K, reg), ctx);
+}
+
+/* Emit 32-bit constant, sign extended. */
+static void emit_set_const_sext(s32 K, u32 reg, struct jit_ctx *ctx)
+{
+	if (K >= 0) {
+		emit(SETHI(K, reg), ctx);
+		emit(OR_LO(K, reg), ctx);
+	} else {
+		u32 hbits = ~(u32) K;
+		u32 lbits = -0x400 | (u32) K;
+
+		emit(SETHI(hbits, reg), ctx);
+		emit(XOR | IMMED | RS1(reg) | S13(lbits) | RD(reg), ctx);
+	}
+}
+
+static void emit_alu(u32 opcode, u32 src, u32 dst, struct jit_ctx *ctx)
+{
+	emit(opcode | RS1(dst) | RS2(src) | RD(dst), ctx);
+}
+
+static void emit_alu3(u32 opcode, u32 a, u32 b, u32 c, struct jit_ctx *ctx)
+{
+	emit(opcode | RS1(a) | RS2(b) | RD(c), ctx);
+}
+
+static void emit_alu_K(unsigned int opcode, unsigned int dst, unsigned int imm,
+		       struct jit_ctx *ctx)
+{
+	bool small_immed = is_simm13(imm);
+	unsigned int insn = opcode;
+
+	insn |= RS1(dst) | RD(dst);
+	if (small_immed) {
+		emit(insn | IMMED | S13(imm), ctx);
+	} else {
+		unsigned int tmp = bpf2sparc[TMP_REG_1];
+
+		ctx->tmp_1_used = true;
+
+		emit_set_const_sext(imm, tmp, ctx);
+		emit(insn | RS2(tmp), ctx);
+	}
+}
+
+static void emit_alu3_K(unsigned int opcode, unsigned int src, unsigned int imm,
+			unsigned int dst, struct jit_ctx *ctx)
+{
+	bool small_immed = is_simm13(imm);
+	unsigned int insn = opcode;
+
+	insn |= RS1(src) | RD(dst);
+	if (small_immed) {
+		emit(insn | IMMED | S13(imm), ctx);
+	} else {
+		unsigned int tmp = bpf2sparc[TMP_REG_1];
+
+		ctx->tmp_1_used = true;
+
+		emit_set_const_sext(imm, tmp, ctx);
+		emit(insn | RS2(tmp), ctx);
+	}
+}
+
+static void emit_loadimm32(s32 K, unsigned int dest, struct jit_ctx *ctx)
+{
+	if (K >= 0 && is_simm13(K)) {
+		/* or %g0, K, DEST */
+		emit(OR | IMMED | RS1(G0) | S13(K) | RD(dest), ctx);
+	} else {
+		emit_set_const(K, dest, ctx);
+	}
+}
+
+static void emit_loadimm(s32 K, unsigned int dest, struct jit_ctx *ctx)
+{
+	if (is_simm13(K)) {
+		/* or %g0, K, DEST */
+		emit(OR | IMMED | RS1(G0) | S13(K) | RD(dest), ctx);
+	} else {
+		emit_set_const(K, dest, ctx);
+	}
+}
+
+static void emit_loadimm_sext(s32 K, unsigned int dest, struct jit_ctx *ctx)
+{
+	if (is_simm13(K)) {
+		/* or %g0, K, DEST */
+		emit(OR | IMMED | RS1(G0) | S13(K) | RD(dest), ctx);
+	} else {
+		emit_set_const_sext(K, dest, ctx);
+	}
+}
+
+static void emit_loadimm64(u64 K, unsigned int dest, struct jit_ctx *ctx)
+{
+	unsigned int tmp = bpf2sparc[TMP_REG_1];
+	u32 high_part = (K >> 32);
+	u32 low_part = (K & 0xffffffff);
+
+	ctx->tmp_1_used = true;
+
+	emit_set_const(high_part, tmp, ctx);
+	emit_set_const(low_part, dest, ctx);
+	emit_alu_K(SLLX, tmp, 32, ctx);
+	emit(OR | RS1(dest) | RS2(tmp) | RD(dest), ctx);
+}
+
+static void emit_branch(unsigned int br_opc, unsigned int from_idx, unsigned int to_idx,
+			struct jit_ctx *ctx)
+{
+	unsigned int off = to_idx - from_idx;
+
+	if (br_opc & XCC)
+		emit(br_opc | WDISP19(off << 2), ctx);
+	else
+		emit(br_opc | WDISP22(off << 2), ctx);
+}
+
+#define emit_read_y(REG, CTX)	emit(RD_Y | RD(REG), CTX)
+#define emit_write_y(REG, CTX)	emit(WR_Y | IMMED | RS1(REG) | S13(0), CTX)
+
+#define emit_cmp(R1, R2, CTX)				\
+	emit(SUBCC | RS1(R1) | RS2(R2) | RD(G0), CTX)
+
+#define emit_cmpi(R1, IMM, CTX)				\
+	emit(SUBCC | IMMED | RS1(R1) | S13(IMM) | RD(G0), CTX);
+
+#define emit_btst(R1, R2, CTX)				\
+	emit(ANDCC | RS1(R1) | RS2(R2) | RD(G0), CTX)
+
+#define emit_btsti(R1, IMM, CTX)			\
+	emit(ANDCC | IMMED | RS1(R1) | S13(IMM) | RD(G0), CTX)
+
+static void load_skb_regs(struct jit_ctx *ctx, u8 r_skb)
+{
+	const u8 r_headlen = bpf2sparc[SKB_HLEN_REG];
+	const u8 r_data = bpf2sparc[SKB_DATA_REG];
+	const u8 r_tmp = bpf2sparc[TMP_REG_1];
+	unsigned int off;
+
+	off = offsetof(struct sk_buff, len);
+	emit(LD32I | RS1(r_skb) | S13(off) | RD(r_headlen), ctx);
+
+	off = offsetof(struct sk_buff, data_len);
+	emit(LD32I | RS1(r_skb) | S13(off) | RD(r_tmp), ctx);
+
+	emit(SUB | RS1(r_headlen) | RS2(r_tmp) | RD(r_headlen), ctx);
+
+	off = offsetof(struct sk_buff, data);
+	emit(LDPTRI | RS1(r_skb) | S13(off) | RD(r_data), ctx);
+}
+
+/* Just skip the save instruction and the ctx register move.  */
+#define BPF_TAILCALL_PROLOGUE_SKIP	16
+#define BPF_TAILCALL_CNT_SP_OFF		(STACK_BIAS + 128)
+
+static void build_prologue(struct jit_ctx *ctx)
+{
+	s32 stack_needed = BASE_STACKFRAME;
+
+	if (ctx->saw_frame_pointer || ctx->saw_tail_call)
+		stack_needed += MAX_BPF_STACK;
+
+	if (ctx->saw_tail_call)
+		stack_needed += 8;
+
+	/* save %sp, -176, %sp */
+	emit(SAVE | IMMED | RS1(SP) | S13(-stack_needed) | RD(SP), ctx);
+
+	/* tail_call_cnt = 0 */
+	if (ctx->saw_tail_call) {
+		u32 off = BPF_TAILCALL_CNT_SP_OFF;
+
+		emit(ST32 | IMMED | RS1(SP) | S13(off) | RD(G0), ctx);
+	} else {
+		emit_nop(ctx);
+	}
+	if (ctx->saw_frame_pointer) {
+		const u8 vfp = bpf2sparc[BPF_REG_FP];
+
+		emit(ADD | IMMED | RS1(FP) | S13(STACK_BIAS) | RD(vfp), ctx);
+	}
+
+	emit_reg_move(I0, O0, ctx);
+	/* If you add anything here, adjust BPF_TAILCALL_PROLOGUE_SKIP above. */
+
+	if (ctx->saw_ld_abs_ind)
+		load_skb_regs(ctx, bpf2sparc[BPF_REG_1]);
+}
+
+static void build_epilogue(struct jit_ctx *ctx)
+{
+	ctx->epilogue_offset = ctx->idx;
+
+	/* ret (jmpl %i7 + 8, %g0) */
+	emit(JMPL | IMMED | RS1(I7) | S13(8) | RD(G0), ctx);
+
+	/* restore %i5, %g0, %o0 */
+	emit(RESTORE | RS1(bpf2sparc[BPF_REG_0]) | RS2(G0) | RD(O0), ctx);
+}
+
+static void emit_tail_call(struct jit_ctx *ctx)
+{
+	const u8 bpf_array = bpf2sparc[BPF_REG_2];
+	const u8 bpf_index = bpf2sparc[BPF_REG_3];
+	const u8 tmp = bpf2sparc[TMP_REG_1];
+	u32 off;
+
+	ctx->saw_tail_call = true;
+
+	off = offsetof(struct bpf_array, map.max_entries);
+	emit(LD32 | IMMED | RS1(bpf_array) | S13(off) | RD(tmp), ctx);
+	emit_cmp(bpf_index, tmp, ctx);
+#define OFFSET1 17
+	emit_branch(BGEU, ctx->idx, ctx->idx + OFFSET1, ctx);
+	emit_nop(ctx);
+
+	off = BPF_TAILCALL_CNT_SP_OFF;
+	emit(LD32 | IMMED | RS1(SP) | S13(off) | RD(tmp), ctx);
+	emit_cmpi(tmp, MAX_TAIL_CALL_CNT, ctx);
+#define OFFSET2 13
+	emit_branch(BGU, ctx->idx, ctx->idx + OFFSET2, ctx);
+	emit_nop(ctx);
+
+	emit_alu_K(ADD, tmp, 1, ctx);
+	off = BPF_TAILCALL_CNT_SP_OFF;
+	emit(ST32 | IMMED | RS1(SP) | S13(off) | RD(tmp), ctx);
+
+	emit_alu3_K(SLL, bpf_index, 3, tmp, ctx);
+	emit_alu(ADD, bpf_array, tmp, ctx);
+	off = offsetof(struct bpf_array, ptrs);
+	emit(LD64 | IMMED | RS1(tmp) | S13(off) | RD(tmp), ctx);
+
+	emit_cmpi(tmp, 0, ctx);
+#define OFFSET3 5
+	emit_branch(BE, ctx->idx, ctx->idx + OFFSET3, ctx);
+	emit_nop(ctx);
+
+	off = offsetof(struct bpf_prog, bpf_func);
+	emit(LD64 | IMMED | RS1(tmp) | S13(off) | RD(tmp), ctx);
+
+	off = BPF_TAILCALL_PROLOGUE_SKIP;
+	emit(JMPL | IMMED | RS1(tmp) | S13(off) | RD(G0), ctx);
+	emit_nop(ctx);
+}
+
+static int build_insn(const struct bpf_insn *insn, struct jit_ctx *ctx)
+{
+	const u8 code = insn->code;
+	const u8 dst = bpf2sparc[insn->dst_reg];
+	const u8 src = bpf2sparc[insn->src_reg];
+	const int i = insn - ctx->prog->insnsi;
+	const s16 off = insn->off;
+	const s32 imm = insn->imm;
+	u32 *func;
+
+	if (insn->src_reg == BPF_REG_FP)
+		ctx->saw_frame_pointer = true;
+
+	switch (code) {
+	/* dst = src */
+	case BPF_ALU | BPF_MOV | BPF_X:
+		emit_alu3_K(SRL, src, 0, dst, ctx);
+		break;
+	case BPF_ALU64 | BPF_MOV | BPF_X:
+		emit_reg_move(src, dst, ctx);
+		break;
+	/* dst = dst OP src */
+	case BPF_ALU | BPF_ADD | BPF_X:
+	case BPF_ALU64 | BPF_ADD | BPF_X:
+		emit_alu(ADD, src, dst, ctx);
+		goto do_alu32_trunc;
+	case BPF_ALU | BPF_SUB | BPF_X:
+	case BPF_ALU64 | BPF_SUB | BPF_X:
+		emit_alu(SUB, src, dst, ctx);
+		goto do_alu32_trunc;
+	case BPF_ALU | BPF_AND | BPF_X:
+	case BPF_ALU64 | BPF_AND | BPF_X:
+		emit_alu(AND, src, dst, ctx);
+		goto do_alu32_trunc;
+	case BPF_ALU | BPF_OR | BPF_X:
+	case BPF_ALU64 | BPF_OR | BPF_X:
+		emit_alu(OR, src, dst, ctx);
+		goto do_alu32_trunc;
+	case BPF_ALU | BPF_XOR | BPF_X:
+	case BPF_ALU64 | BPF_XOR | BPF_X:
+		emit_alu(XOR, src, dst, ctx);
+		goto do_alu32_trunc;
+	case BPF_ALU | BPF_MUL | BPF_X:
+		emit_alu(MUL, src, dst, ctx);
+		goto do_alu32_trunc;
+	case BPF_ALU64 | BPF_MUL | BPF_X:
+		emit_alu(MULX, src, dst, ctx);
+		break;
+	case BPF_ALU | BPF_DIV | BPF_X:
+		emit_cmp(src, G0, ctx);
+		emit_branch(BE|ANNUL, ctx->idx, ctx->epilogue_offset, ctx);
+		emit_loadimm(0, bpf2sparc[BPF_REG_0], ctx);
+
+		emit_write_y(G0, ctx);
+		emit_alu(DIV, src, dst, ctx);
+		break;
+
+	case BPF_ALU64 | BPF_DIV | BPF_X:
+		emit_cmp(src, G0, ctx);
+		emit_branch(BE|ANNUL, ctx->idx, ctx->epilogue_offset, ctx);
+		emit_loadimm(0, bpf2sparc[BPF_REG_0], ctx);
+
+		emit_alu(UDIVX, src, dst, ctx);
+		break;
+
+	case BPF_ALU | BPF_MOD | BPF_X: {
+		const u8 tmp = bpf2sparc[TMP_REG_1];
+
+		ctx->tmp_1_used = true;
+
+		emit_cmp(src, G0, ctx);
+		emit_branch(BE|ANNUL, ctx->idx, ctx->epilogue_offset, ctx);
+		emit_loadimm(0, bpf2sparc[BPF_REG_0], ctx);
+
+		emit_write_y(G0, ctx);
+		emit_alu3(DIV, dst, src, tmp, ctx);
+		emit_alu3(MULX, tmp, src, tmp, ctx);
+		emit_alu3(SUB, dst, tmp, dst, ctx);
+		goto do_alu32_trunc;
+	}
+	case BPF_ALU64 | BPF_MOD | BPF_X: {
+		const u8 tmp = bpf2sparc[TMP_REG_1];
+
+		ctx->tmp_1_used = true;
+
+		emit_cmp(src, G0, ctx);
+		emit_branch(BE|ANNUL, ctx->idx, ctx->epilogue_offset, ctx);
+		emit_loadimm(0, bpf2sparc[BPF_REG_0], ctx);
+
+		emit_alu3(UDIVX, dst, src, tmp, ctx);
+		emit_alu3(MULX, tmp, src, tmp, ctx);
+		emit_alu3(SUB, dst, tmp, dst, ctx);
+		break;
+	}
+	case BPF_ALU | BPF_LSH | BPF_X:
+		emit_alu(SLL, src, dst, ctx);
+		goto do_alu32_trunc;
+	case BPF_ALU64 | BPF_LSH | BPF_X:
+		emit_alu(SLLX, src, dst, ctx);
+		break;
+	case BPF_ALU | BPF_RSH | BPF_X:
+		emit_alu(SRL, src, dst, ctx);
+		break;
+	case BPF_ALU64 | BPF_RSH | BPF_X:
+		emit_alu(SRLX, src, dst, ctx);
+		break;
+	case BPF_ALU | BPF_ARSH | BPF_X:
+		emit_alu(SRA, src, dst, ctx);
+		goto do_alu32_trunc;
+	case BPF_ALU64 | BPF_ARSH | BPF_X:
+		emit_alu(SRAX, src, dst, ctx);
+		break;
+
+	/* dst = -dst */
+	case BPF_ALU | BPF_NEG:
+	case BPF_ALU64 | BPF_NEG:
+		emit(SUB | RS1(0) | RS2(dst) | RD(dst), ctx);
+		goto do_alu32_trunc;
+
+	case BPF_ALU | BPF_END | BPF_FROM_BE:
+		switch (imm) {
+		case 16:
+			emit_alu_K(SLL, dst, 16, ctx);
+			emit_alu_K(SRL, dst, 16, ctx);
+			break;
+		case 32:
+			emit_alu_K(SRL, dst, 0, ctx);
+			break;
+		case 64:
+			/* nop */
+			break;
+
+		}
+		break;
+
+	/* dst = BSWAP##imm(dst) */
+	case BPF_ALU | BPF_END | BPF_FROM_LE: {
+		const u8 tmp = bpf2sparc[TMP_REG_1];
+		const u8 tmp2 = bpf2sparc[TMP_REG_2];
+
+		ctx->tmp_1_used = true;
+		switch (imm) {
+		case 16:
+			emit_alu3_K(AND, dst, 0xff, tmp, ctx);
+			emit_alu3_K(SRL, dst, 8, dst, ctx);
+			emit_alu3_K(AND, dst, 0xff, dst, ctx);
+			emit_alu3_K(SLL, tmp, 8, tmp, ctx);
+			emit_alu(OR, tmp, dst, ctx);
+			break;
+
+		case 32:
+			ctx->tmp_2_used = true;
+			emit_alu3_K(SRL, dst, 24, tmp, ctx);	/* tmp  = dst >> 24 */
+			emit_alu3_K(SRL, dst, 16, tmp2, ctx);	/* tmp2 = dst >> 16 */
+			emit_alu3_K(AND, tmp2, 0xff, tmp2, ctx);/* tmp2 = tmp2 & 0xff */
+			emit_alu3_K(SLL, tmp2, 8, tmp2, ctx);	/* tmp2 = tmp2 << 8 */
+			emit_alu(OR, tmp2, tmp, ctx);		/* tmp  = tmp | tmp2 */
+			emit_alu3_K(SRL, dst, 8, tmp2, ctx);	/* tmp2 = dst >> 8 */
+			emit_alu3_K(AND, tmp2, 0xff, tmp2, ctx);/* tmp2 = tmp2 & 0xff */
+			emit_alu3_K(SLL, tmp2, 16, tmp2, ctx);	/* tmp2 = tmp2 << 16 */
+			emit_alu(OR, tmp2, tmp, ctx);		/* tmp  = tmp | tmp2 */
+			emit_alu3_K(AND, dst, 0xff, dst, ctx);	/* dst	= dst & 0xff */
+			emit_alu3_K(SLL, dst, 24, dst, ctx);	/* dst  = dst << 24 */
+			emit_alu(OR, tmp, dst, ctx);		/* dst  = dst | tmp */
+			break;
+
+		case 64:
+			emit_alu3_K(ADD, SP, STACK_BIAS + 128, tmp, ctx);
+			emit(ST64 | RS1(tmp) | RS2(G0) | RD(dst), ctx);
+			emit(LD64A | ASI(ASI_PL) | RS1(tmp) | RS2(G0) | RD(dst), ctx);
+			break;
+		}
+		break;
+	}
+	/* dst = imm */
+	case BPF_ALU | BPF_MOV | BPF_K:
+		emit_loadimm32(imm, dst, ctx);
+		break;
+	case BPF_ALU64 | BPF_MOV | BPF_K:
+		emit_loadimm_sext(imm, dst, ctx);
+		break;
+	/* dst = dst OP imm */
+	case BPF_ALU | BPF_ADD | BPF_K:
+	case BPF_ALU64 | BPF_ADD | BPF_K:
+		emit_alu_K(ADD, dst, imm, ctx);
+		goto do_alu32_trunc;
+	case BPF_ALU | BPF_SUB | BPF_K:
+	case BPF_ALU64 | BPF_SUB | BPF_K:
+		emit_alu_K(SUB, dst, imm, ctx);
+		goto do_alu32_trunc;
+	case BPF_ALU | BPF_AND | BPF_K:
+	case BPF_ALU64 | BPF_AND | BPF_K:
+		emit_alu_K(AND, dst, imm, ctx);
+		goto do_alu32_trunc;
+	case BPF_ALU | BPF_OR | BPF_K:
+	case BPF_ALU64 | BPF_OR | BPF_K:
+		emit_alu_K(OR, dst, imm, ctx);
+		goto do_alu32_trunc;
+	case BPF_ALU | BPF_XOR | BPF_K:
+	case BPF_ALU64 | BPF_XOR | BPF_K:
+		emit_alu_K(XOR, dst, imm, ctx);
+		goto do_alu32_trunc;
+	case BPF_ALU | BPF_MUL | BPF_K:
+		emit_alu_K(MUL, dst, imm, ctx);
+		goto do_alu32_trunc;
+	case BPF_ALU64 | BPF_MUL | BPF_K:
+		emit_alu_K(MULX, dst, imm, ctx);
+		break;
+	case BPF_ALU | BPF_DIV | BPF_K:
+		if (imm == 0)
+			return -EINVAL;
+
+		emit_write_y(G0, ctx);
+		emit_alu_K(DIV, dst, imm, ctx);
+		goto do_alu32_trunc;
+	case BPF_ALU64 | BPF_DIV | BPF_K:
+		if (imm == 0)
+			return -EINVAL;
+
+		emit_alu_K(UDIVX, dst, imm, ctx);
+		break;
+	case BPF_ALU64 | BPF_MOD | BPF_K:
+	case BPF_ALU | BPF_MOD | BPF_K: {
+		const u8 tmp = bpf2sparc[TMP_REG_2];
+		unsigned int div;
+
+		if (imm == 0)
+			return -EINVAL;
+
+		div = (BPF_CLASS(code) == BPF_ALU64) ? UDIVX : DIV;
+
+		ctx->tmp_2_used = true;
+
+		if (BPF_CLASS(code) != BPF_ALU64)
+			emit_write_y(G0, ctx);
+		if (is_simm13(imm)) {
+			emit(div | IMMED | RS1(dst) | S13(imm) | RD(tmp), ctx);
+			emit(MULX | IMMED | RS1(tmp) | S13(imm) | RD(tmp), ctx);
+			emit(SUB | RS1(dst) | RS2(tmp) | RD(dst), ctx);
+		} else {
+			const u8 tmp1 = bpf2sparc[TMP_REG_1];
+
+			ctx->tmp_1_used = true;
+
+			emit_set_const_sext(imm, tmp1, ctx);
+			emit(div | RS1(dst) | RS2(tmp1) | RD(tmp), ctx);
+			emit(MULX | RS1(tmp) | RS2(tmp1) | RD(tmp), ctx);
+			emit(SUB | RS1(dst) | RS2(tmp) | RD(dst), ctx);
+		}
+		goto do_alu32_trunc;
+	}
+	case BPF_ALU | BPF_LSH | BPF_K:
+		emit_alu_K(SLL, dst, imm, ctx);
+		goto do_alu32_trunc;
+	case BPF_ALU64 | BPF_LSH | BPF_K:
+		emit_alu_K(SLLX, dst, imm, ctx);
+		break;
+	case BPF_ALU | BPF_RSH | BPF_K:
+		emit_alu_K(SRL, dst, imm, ctx);
+		break;
+	case BPF_ALU64 | BPF_RSH | BPF_K:
+		emit_alu_K(SRLX, dst, imm, ctx);
+		break;
+	case BPF_ALU | BPF_ARSH | BPF_K:
+		emit_alu_K(SRA, dst, imm, ctx);
+		goto do_alu32_trunc;
+	case BPF_ALU64 | BPF_ARSH | BPF_K:
+		emit_alu_K(SRAX, dst, imm, ctx);
+		break;
+
+	do_alu32_trunc:
+		if (BPF_CLASS(code) == BPF_ALU)
+			emit_alu_K(SRL, dst, 0, ctx);
+		break;
+
+	/* JUMP off */
+	case BPF_JMP | BPF_JA:
+		emit_branch(BA, ctx->idx, ctx->offset[i + off], ctx);
+		emit_nop(ctx);
+		break;
+	/* IF (dst COND src) JUMP off */
+	case BPF_JMP | BPF_JEQ | BPF_X:
+	case BPF_JMP | BPF_JGT | BPF_X:
+	case BPF_JMP | BPF_JGE | BPF_X:
+	case BPF_JMP | BPF_JNE | BPF_X:
+	case BPF_JMP | BPF_JSGT | BPF_X:
+	case BPF_JMP | BPF_JSGE | BPF_X: {
+		u32 br_opcode;
+
+		emit_cmp(dst, src, ctx);
+emit_cond_jmp:
+		switch (BPF_OP(code)) {
+		case BPF_JEQ:
+			br_opcode = BE;
+			break;
+		case BPF_JGT:
+			br_opcode = BGU;
+			break;
+		case BPF_JGE:
+			br_opcode = BGEU;
+			break;
+		case BPF_JSET:
+		case BPF_JNE:
+			br_opcode = BNE;
+			break;
+		case BPF_JSGT:
+			br_opcode = BG;
+			break;
+		case BPF_JSGE:
+			br_opcode = BGE;
+			break;
+		default:
+			/* Make sure we dont leak kernel information to the
+			 * user.
+			 */
+			return -EFAULT;
+		}
+		emit_branch(br_opcode, ctx->idx, ctx->offset[i + off], ctx);
+		emit_nop(ctx);
+		break;
+	}
+	case BPF_JMP | BPF_JSET | BPF_X:
+		emit_btst(dst, src, ctx);
+		goto emit_cond_jmp;
+	/* IF (dst COND imm) JUMP off */
+	case BPF_JMP | BPF_JEQ | BPF_K:
+	case BPF_JMP | BPF_JGT | BPF_K:
+	case BPF_JMP | BPF_JGE | BPF_K:
+	case BPF_JMP | BPF_JNE | BPF_K:
+	case BPF_JMP | BPF_JSGT | BPF_K:
+	case BPF_JMP | BPF_JSGE | BPF_K:
+		if (is_simm13(imm)) {
+			emit_cmpi(dst, imm, ctx);
+		} else {
+			ctx->tmp_1_used = true;
+			emit_loadimm_sext(imm, bpf2sparc[TMP_REG_1], ctx);
+			emit_cmp(dst, bpf2sparc[TMP_REG_1], ctx);
+		}
+		goto emit_cond_jmp;
+	case BPF_JMP | BPF_JSET | BPF_K:
+		if (is_simm13(imm)) {
+			emit_btsti(dst, imm, ctx);
+		} else {
+			ctx->tmp_1_used = true;
+			emit_loadimm_sext(imm, bpf2sparc[TMP_REG_1], ctx);
+			emit_btst(dst, bpf2sparc[TMP_REG_1], ctx);
+		}
+		goto emit_cond_jmp;
+
+	/* function call */
+	case BPF_JMP | BPF_CALL:
+	{
+		u8 *func = ((u8 *)__bpf_call_base) + imm;
+
+		ctx->saw_call = true;
+
+		emit_call((u32 *)func, ctx);
+		emit_nop(ctx);
+
+		emit_reg_move(O0, bpf2sparc[BPF_REG_0], ctx);
+
+		if (bpf_helper_changes_pkt_data(func) && ctx->saw_ld_abs_ind)
+			load_skb_regs(ctx, bpf2sparc[BPF_REG_6]);
+		break;
+	}
+
+	/* tail call */
+	case BPF_JMP | BPF_CALL |BPF_X:
+		emit_tail_call(ctx);
+
+	/* function return */
+	case BPF_JMP | BPF_EXIT:
+		/* Optimization: when last instruction is EXIT,
+		   simply fallthrough to epilogue. */
+		if (i == ctx->prog->len - 1)
+			break;
+		emit_branch(BA, ctx->idx, ctx->epilogue_offset, ctx);
+		emit_nop(ctx);
+		break;
+
+	/* dst = imm64 */
+	case BPF_LD | BPF_IMM | BPF_DW:
+	{
+		const struct bpf_insn insn1 = insn[1];
+		u64 imm64;
+
+		imm64 = (u64)insn1.imm << 32 | (u32)imm;
+		emit_loadimm64(imm64, dst, ctx);
+
+		return 1;
+	}
+
+	/* LDX: dst = *(size *)(src + off) */
+	case BPF_LDX | BPF_MEM | BPF_W:
+	case BPF_LDX | BPF_MEM | BPF_H:
+	case BPF_LDX | BPF_MEM | BPF_B:
+	case BPF_LDX | BPF_MEM | BPF_DW: {
+		const u8 tmp = bpf2sparc[TMP_REG_1];
+		u32 opcode = 0, rs2;
+
+		ctx->tmp_1_used = true;
+		switch (BPF_SIZE(code)) {
+		case BPF_W:
+			opcode = LD32;
+			break;
+		case BPF_H:
+			opcode = LD16;
+			break;
+		case BPF_B:
+			opcode = LD8;
+			break;
+		case BPF_DW:
+			opcode = LD64;
+			break;
+		}
+
+		if (is_simm13(off)) {
+			opcode |= IMMED;
+			rs2 = S13(off);
+		} else {
+			emit_loadimm(off, tmp, ctx);
+			rs2 = RS2(tmp);
+		}
+		emit(opcode | RS1(src) | rs2 | RD(dst), ctx);
+		break;
+	}
+	/* ST: *(size *)(dst + off) = imm */
+	case BPF_ST | BPF_MEM | BPF_W:
+	case BPF_ST | BPF_MEM | BPF_H:
+	case BPF_ST | BPF_MEM | BPF_B:
+	case BPF_ST | BPF_MEM | BPF_DW: {
+		const u8 tmp = bpf2sparc[TMP_REG_1];
+		const u8 tmp2 = bpf2sparc[TMP_REG_2];
+		u32 opcode = 0, rs2;
+
+		ctx->tmp_2_used = true;
+		emit_loadimm(imm, tmp2, ctx);
+
+		switch (BPF_SIZE(code)) {
+		case BPF_W:
+			opcode = ST32;
+			break;
+		case BPF_H:
+			opcode = ST16;
+			break;
+		case BPF_B:
+			opcode = ST8;
+			break;
+		case BPF_DW:
+			opcode = ST64;
+			break;
+		}
+
+		if (is_simm13(off)) {
+			opcode |= IMMED;
+			rs2 = S13(off);
+		} else {
+			ctx->tmp_1_used = true;
+			emit_loadimm(off, tmp, ctx);
+			rs2 = RS2(tmp);
+		}
+		emit(opcode | RS1(dst) | rs2 | RD(tmp2), ctx);
+		break;
+	}
+
+	/* STX: *(size *)(dst + off) = src */
+	case BPF_STX | BPF_MEM | BPF_W:
+	case BPF_STX | BPF_MEM | BPF_H:
+	case BPF_STX | BPF_MEM | BPF_B:
+	case BPF_STX | BPF_MEM | BPF_DW: {
+		const u8 tmp = bpf2sparc[TMP_REG_1];
+		u32 opcode = 0, rs2;
+
+		switch (BPF_SIZE(code)) {
+		case BPF_W:
+			opcode = ST32;
+			break;
+		case BPF_H:
+			opcode = ST16;
+			break;
+		case BPF_B:
+			opcode = ST8;
+			break;
+		case BPF_DW:
+			opcode = ST64;
+			break;
+		}
+		if (is_simm13(off)) {
+			opcode |= IMMED;
+			rs2 = S13(off);
+		} else {
+			ctx->tmp_1_used = true;
+			emit_loadimm(off, tmp, ctx);
+			rs2 = RS2(tmp);
+		}
+		emit(opcode | RS1(dst) | rs2 | RD(src), ctx);
+		break;
+	}
+
+	/* STX XADD: lock *(u32 *)(dst + off) += src */
+	case BPF_STX | BPF_XADD | BPF_W: {
+		const u8 tmp = bpf2sparc[TMP_REG_1];
+		const u8 tmp2 = bpf2sparc[TMP_REG_2];
+		const u8 tmp3 = bpf2sparc[TMP_REG_3];
+
+		ctx->tmp_1_used = true;
+		ctx->tmp_2_used = true;
+		ctx->tmp_3_used = true;
+		emit_loadimm(off, tmp, ctx);
+		emit_alu3(ADD, dst, tmp, tmp, ctx);
+
+		emit(LD32 | RS1(tmp) | RS2(G0) | RD(tmp2), ctx);
+		emit_alu3(ADD, tmp2, src, tmp3, ctx);
+		emit(CAS | ASI(ASI_P) | RS1(tmp) | RS2(tmp2) | RD(tmp3), ctx);
+		emit_cmp(tmp2, tmp3, ctx);
+		emit_branch(BNE, 4, 0, ctx);
+		emit_nop(ctx);
+		break;
+	}
+	/* STX XADD: lock *(u64 *)(dst + off) += src */
+	case BPF_STX | BPF_XADD | BPF_DW: {
+		const u8 tmp = bpf2sparc[TMP_REG_1];
+		const u8 tmp2 = bpf2sparc[TMP_REG_2];
+		const u8 tmp3 = bpf2sparc[TMP_REG_3];
+
+		ctx->tmp_1_used = true;
+		ctx->tmp_2_used = true;
+		ctx->tmp_3_used = true;
+		emit_loadimm(off, tmp, ctx);
+		emit_alu3(ADD, dst, tmp, tmp, ctx);
+
+		emit(LD64 | RS1(tmp) | RS2(G0) | RD(tmp2), ctx);
+		emit_alu3(ADD, tmp2, src, tmp3, ctx);
+		emit(CASX | ASI(ASI_P) | RS1(tmp) | RS2(tmp2) | RD(tmp3), ctx);
+		emit_cmp(tmp2, tmp3, ctx);
+		emit_branch(BNE, 4, 0, ctx);
+		emit_nop(ctx);
+		break;
+	}
+#define CHOOSE_LOAD_FUNC(K, func) \
+		((int)K < 0 ? ((int)K >= SKF_LL_OFF ? func##_negative_offset : func) : func##_positive_offset)
+
+	/* R0 = ntohx(*(size *)(((struct sk_buff *)R6)->data + imm)) */
+	case BPF_LD | BPF_ABS | BPF_W:
+		func = CHOOSE_LOAD_FUNC(imm, bpf_jit_load_word);
+		goto common_load;
+	case BPF_LD | BPF_ABS | BPF_H:
+		func = CHOOSE_LOAD_FUNC(imm, bpf_jit_load_half);
+		goto common_load;
+	case BPF_LD | BPF_ABS | BPF_B:
+		func = CHOOSE_LOAD_FUNC(imm, bpf_jit_load_byte);
+		goto common_load;
+	/* R0 = ntohx(*(size *)(((struct sk_buff *)R6)->data + src + imm)) */
+	case BPF_LD | BPF_IND | BPF_W:
+		func = bpf_jit_load_word;
+		goto common_load;
+	case BPF_LD | BPF_IND | BPF_H:
+		func = bpf_jit_load_half;
+		goto common_load;
+
+	case BPF_LD | BPF_IND | BPF_B:
+		func = bpf_jit_load_byte;
+	common_load:
+		ctx->saw_ld_abs_ind = true;
+
+		emit_reg_move(bpf2sparc[BPF_REG_6], O0, ctx);
+		emit_loadimm(imm, O1, ctx);
+
+		if (BPF_MODE(code) == BPF_IND)
+			emit_alu(ADD, src, O1, ctx);
+
+		emit_call(func, ctx);
+		emit_alu_K(SRA, O1, 0, ctx);
+
+		emit_reg_move(O0, bpf2sparc[BPF_REG_0], ctx);
+		break;
+
+	default:
+		pr_err_once("unknown opcode %02x\n", code);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int build_body(struct jit_ctx *ctx)
+{
+	const struct bpf_prog *prog = ctx->prog;
+	int i;
+
+	for (i = 0; i < prog->len; i++) {
+		const struct bpf_insn *insn = &prog->insnsi[i];
+		int ret;
+
+		ret = build_insn(insn, ctx);
+		ctx->offset[i] = ctx->idx;
+
+		if (ret > 0) {
+			i++;
+			continue;
+		}
+		if (ret)
+			return ret;
+	}
+	return 0;
+}
+
+static void jit_fill_hole(void *area, unsigned int size)
+{
+	u32 *ptr;
+	/* We are guaranteed to have aligned memory. */
+	for (ptr = area; size >= sizeof(u32); size -= sizeof(u32))
+		*ptr++ = 0x91d02005; /* ta 5 */
+}
+
+struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *prog)
+{
+	struct bpf_prog *tmp, *orig_prog = prog;
+	struct bpf_binary_header *header;
+	bool tmp_blinded = false;
+	struct jit_ctx ctx;
+	u32 image_size;
+	u8 *image_ptr;
+	int pass;
+
+	if (!bpf_jit_enable)
+		return orig_prog;
+
+	tmp = bpf_jit_blind_constants(prog);
+	/* If blinding was requested and we failed during blinding,
+	 * we must fall back to the interpreter.
+	 */
+	if (IS_ERR(tmp))
+		return orig_prog;
+	if (tmp != prog) {
+		tmp_blinded = true;
+		prog = tmp;
+	}
+
+	memset(&ctx, 0, sizeof(ctx));
+	ctx.prog = prog;
+
+	ctx.offset = kcalloc(prog->len, sizeof(unsigned int), GFP_KERNEL);
+	if (ctx.offset == NULL) {
+		prog = orig_prog;
+		goto out;
+	}
+
+	/* Fake pass to detect features used, and get an accurate assessment
+	 * of what the final image size will be.
+	 */
+	if (build_body(&ctx)) {
+		prog = orig_prog;
+		goto out_off;
+	}
+	build_prologue(&ctx);
+	build_epilogue(&ctx);
+
+	/* Now we know the actual image size. */
+	image_size = sizeof(u32) * ctx.idx;
+	header = bpf_jit_binary_alloc(image_size, &image_ptr,
+				      sizeof(u32), jit_fill_hole);
+	if (header == NULL) {
+		prog = orig_prog;
+		goto out_off;
+	}
+
+	ctx.image = (u32 *)image_ptr;
+
+	for (pass = 1; pass < 3; pass++) {
+		ctx.idx = 0;
+
+		build_prologue(&ctx);
+
+		if (build_body(&ctx)) {
+			bpf_jit_binary_free(header);
+			prog = orig_prog;
+			goto out_off;
+		}
+
+		build_epilogue(&ctx);
+
+		if (bpf_jit_enable > 1)
+			pr_info("Pass %d: shrink = %d, seen = [%c%c%c%c%c%c%c]\n", pass,
+				image_size - (ctx.idx * 4),
+				ctx.tmp_1_used ? '1' : ' ',
+				ctx.tmp_2_used ? '2' : ' ',
+				ctx.tmp_3_used ? '3' : ' ',
+				ctx.saw_ld_abs_ind ? 'L' : ' ',
+				ctx.saw_frame_pointer ? 'F' : ' ',
+				ctx.saw_call ? 'C' : ' ',
+				ctx.saw_tail_call ? 'T' : ' ');
+	}
+
+	if (bpf_jit_enable > 1)
+		bpf_jit_dump(prog->len, image_size, pass, ctx.image);
+
+	bpf_flush_icache(header, (u8 *)header + (header->pages * PAGE_SIZE));
+
+	bpf_jit_binary_lock_ro(header);
+
+	prog->bpf_func = (void *)ctx.image;
+	prog->jited = 1;
+
+out_off:
+	kfree(ctx.offset);
+out:
+	if (tmp_blinded)
+		bpf_jit_prog_release_other(prog, prog == orig_prog ?
+					   tmp : orig_prog);
+	return prog;
+}
-- 
2.1.2.532.g19b5d50

