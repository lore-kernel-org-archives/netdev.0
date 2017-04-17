From: David Miller <davem@davemloft.net>
Subject: [PATCH RFC] sparc64: eBPF JIT
Date: Sun, 16 Apr 2017 23:38:25 -0400 (EDT)
Message-ID: <20170416.233825.1748421481008153466.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@kernel.org, daniel@iogearbox.net
To: sparclinux@vger.kernel.org
Return-path: <sparclinux-owner@vger.kernel.org>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


There are a bunch of things I want to do still, and I know that I have
to attend to sparc32 more cleanly, but I wanted to post this now that
I have it passing the BPF testsuite completely:

[24174.315421] test_bpf: Summary: 305 PASSED, 0 FAILED, [297/297 JIT'ed]

Only major unimplemented feature is tail calls, which I am very sure I
can do simply but until something easy to use like test_bpf can
exercise it I probably won't do it.

>From my side, what I need to do to turn this into a non-RFC is to sort
out sparc32.  My plan is to take the existing cBPF JIT, rip out all of
the sparc64 specific bits, and have sparc32 use that.  And do it in
such a way that git bisection is not broken.

As a future optimization I'd like to add support for emitting cbcond
instructions on newer chips.

This implementation grabs a register window all the time, and we could
avoid that and use a leaf function in certatin situations.  The
register layout is also not optimal, and one side effect is that we
have to move the argument registers over during function calls.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/arch/sparc/net/bpf_jit.h b/arch/sparc/net/bpf_jit.h
index 33d6b37..cd0efad 100644
--- a/arch/sparc/net/bpf_jit.h
+++ b/arch/sparc/net/bpf_jit.h
@@ -27,17 +27,28 @@
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
 
 /* assembly code in arch/sparc/net/bpf_jit_asm.S */
 extern u32 bpf_jit_load_word[];
@@ -54,15 +65,13 @@ extern u32 bpf_jit_load_byte_negative_offset[];
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
diff --git a/arch/sparc/net/bpf_jit_asm.S b/arch/sparc/net/bpf_jit_asm.S
index 8c83f4b..7d68731 100644
--- a/arch/sparc/net/bpf_jit_asm.S
+++ b/arch/sparc/net/bpf_jit_asm.S
@@ -32,7 +32,7 @@ bpf_jit_load_word_positive_offset:
 	bne	load_word_unaligned
 	 nop
 	retl
-	 ld	[r_TMP], r_A
+	 ld	[r_TMP], r_RESULT
 load_word_unaligned:
 	ldub	[r_TMP + 0x0], r_OFF
 	ldub	[r_TMP + 0x1], r_TMP2
@@ -44,7 +44,7 @@ load_word_unaligned:
 	ldub	[r_TMP + 0x3], r_TMP2
 	sll	r_OFF, 8, r_OFF
 	retl
-	 or	r_OFF, r_TMP2, r_A
+	 or	r_OFF, r_TMP2, r_RESULT
 
 	.globl	bpf_jit_load_half
 bpf_jit_load_half:
@@ -61,13 +61,13 @@ bpf_jit_load_half_positive_offset:
 	bne	load_half_unaligned
 	 nop
 	retl
-	 lduh	[r_TMP], r_A
+	 lduh	[r_TMP], r_RESULT
 load_half_unaligned:
 	ldub	[r_TMP + 0x0], r_OFF
 	ldub	[r_TMP + 0x1], r_TMP2
 	sll	r_OFF, 8, r_OFF
 	retl
-	 or	r_OFF, r_TMP2, r_A
+	 or	r_OFF, r_TMP2, r_RESULT
 
 	.globl	bpf_jit_load_byte
 bpf_jit_load_byte:
@@ -80,27 +80,12 @@ bpf_jit_load_byte_positive_offset:
 	bge	bpf_slow_path_byte
 	 nop
 	retl
-	 ldub	[r_SKB_DATA + r_OFF], r_A
-
-	.globl	bpf_jit_load_byte_msh
-bpf_jit_load_byte_msh:
-	cmp	r_OFF, 0
-	bl	bpf_slow_path_byte_msh_neg
-	 nop
-	.globl	bpf_jit_load_byte_msh_positive_offset
-bpf_jit_load_byte_msh_positive_offset:
-	cmp	r_OFF, r_HEADLEN
-	bge	bpf_slow_path_byte_msh
-	 nop
-	ldub	[r_SKB_DATA + r_OFF], r_OFF
-	and	r_OFF, 0xf, r_OFF
-	retl
-	 sll	r_OFF, 2, r_X
+	 ldub	[r_SKB_DATA + r_OFF], r_RESULT
 
 #define bpf_slow_path_common(LEN)	\
 	save	%sp, -SAVE_SZ, %sp;	\
 	mov	%i0, %o0;		\
-	mov	r_OFF, %o1;		\
+	mov	%i1, %o1;		\
 	add	%fp, SCRATCH_OFF, %o2;	\
 	call	skb_copy_bits;		\
 	 mov	(LEN), %o3;		\
@@ -110,33 +95,26 @@ bpf_jit_load_byte_msh_positive_offset:
 bpf_slow_path_word:
 	bpf_slow_path_common(4)
 	bl	bpf_error
-	 ld	[%sp + SCRATCH_OFF], r_A
+	 ld	[%sp + SCRATCH_OFF], r_RESULT
 	retl
 	 nop
 bpf_slow_path_half:
 	bpf_slow_path_common(2)
 	bl	bpf_error
-	 lduh	[%sp + SCRATCH_OFF], r_A
+	 lduh	[%sp + SCRATCH_OFF], r_RESULT
 	retl
 	 nop
 bpf_slow_path_byte:
 	bpf_slow_path_common(1)
 	bl	bpf_error
-	 ldub	[%sp + SCRATCH_OFF], r_A
+	 ldub	[%sp + SCRATCH_OFF], r_RESULT
 	retl
 	 nop
-bpf_slow_path_byte_msh:
-	bpf_slow_path_common(1)
-	bl	bpf_error
-	 ldub	[%sp + SCRATCH_OFF], r_A
-	and	r_OFF, 0xf, r_OFF
-	retl
-	 sll	r_OFF, 2, r_X
 
 #define bpf_negative_common(LEN)			\
 	save	%sp, -SAVE_SZ, %sp;			\
 	mov	%i0, %o0;				\
-	mov	r_OFF, %o1;				\
+	mov	%i1, %o1;				\
 	SIGN_EXTEND(%o1);				\
 	call	bpf_internal_load_pointer_neg_helper;	\
 	 mov	(LEN), %o2;				\
@@ -157,7 +135,7 @@ bpf_jit_load_word_negative_offset:
 	bne	load_word_unaligned
 	 nop
 	retl
-	 ld	[r_TMP], r_A
+	 ld	[r_TMP], r_RESULT
 
 bpf_slow_path_half_neg:
 	sethi	%hi(SKF_MAX_NEG_OFF), r_TMP
@@ -171,7 +149,7 @@ bpf_jit_load_half_negative_offset:
 	bne	load_half_unaligned
 	 nop
 	retl
-	 lduh	[r_TMP], r_A
+	 lduh	[r_TMP], r_RESULT
 
 bpf_slow_path_byte_neg:
 	sethi	%hi(SKF_MAX_NEG_OFF), r_TMP
@@ -182,27 +160,9 @@ bpf_slow_path_byte_neg:
 bpf_jit_load_byte_negative_offset:
 	bpf_negative_common(1)
 	retl
-	 ldub	[r_TMP], r_A
-
-bpf_slow_path_byte_msh_neg:
-	sethi	%hi(SKF_MAX_NEG_OFF), r_TMP
-	cmp	r_OFF, r_TMP
-	bl	bpf_error
-	 nop
-	.globl	bpf_jit_load_byte_msh_negative_offset
-bpf_jit_load_byte_msh_negative_offset:
-	bpf_negative_common(1)
-	ldub	[r_TMP], r_OFF
-	and	r_OFF, 0xf, r_OFF
-	retl
-	 sll	r_OFF, 2, r_X
+	 ldub	[r_TMP], r_RESULT
 
 bpf_error:
-	/* Make the JIT program return zero.  The JIT epilogue
-	 * stores away the original %o7 into r_saved_O7.  The
-	 * normal leaf function return is to use "retl" which
-	 * would evalute to "jmpl %o7 + 8, %g0" but we want to
-	 * use the saved value thus the sequence you see here.
-	 */
-	jmpl	r_saved_O7 + 8, %g0
-	 clr	%o0
+	/* Make the JIT program itself return zero. */
+	ret
+	restore	%g0, %g0, %o0
diff --git a/arch/sparc/net/bpf_jit_comp.c b/arch/sparc/net/bpf_jit_comp.c
index a6d9204..a43d686 100644
--- a/arch/sparc/net/bpf_jit_comp.c
+++ b/arch/sparc/net/bpf_jit_comp.c
@@ -51,6 +51,7 @@ static void bpf_flush_icache(void *start_, void *end_)
 #define F1(X)		OP(X)
 #define F2(X, Y)	(OP(X) | OP2(Y))
 #define F3(X, Y)	(OP(X) | OP3(Y))
+#define ASI(X)		(((X) & 0xff) << 5)
 
 #define CONDN		COND(0x0)
 #define CONDE		COND(0x1)
@@ -73,14 +74,22 @@ static void bpf_flush_icache(void *start_, void *end_)
 #define CONDLU		CONDCS
 
 #define WDISP22(X)	(((X) >> 2) & 0x3fffff)
+#define WDISP19(X)	(((X) >> 2) & 0x7ffff)
 
-#define BA		(F2(0, 2) | CONDA)
-#define BGU		(F2(0, 2) | CONDGU)
-#define BLEU		(F2(0, 2) | CONDLEU)
-#define BGEU		(F2(0, 2) | CONDGEU)
-#define BLU		(F2(0, 2) | CONDLU)
-#define BE		(F2(0, 2) | CONDE)
-#define BNE		(F2(0, 2) | CONDNE)
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
 
 #ifdef CONFIG_SPARC64
 #define BE_PTR		(F2(0, 1) | CONDE | (2 << 20))
@@ -100,11 +109,19 @@ static void bpf_flush_icache(void *start_, void *end_)
 #define XOR		F3(2, 0x03)
 #define SUB		F3(2, 0x04)
 #define SUBCC		F3(2, 0x14)
-#define MUL		F3(2, 0x0a)	/* umul */
-#define DIV		F3(2, 0x0e)	/* udiv */
+#define MUL		F3(2, 0x0a)
+#define MULX		F3(2, 0x09)
+#define UDIVX		F3(2, 0x0d)
+#define DIV		F3(2, 0x0e)
 #define SLL		F3(2, 0x25)
+#define SLLX		(F3(2, 0x25)|(1<<12))
+#define SRA		F3(2, 0x27)
+#define SRAX		(F3(2, 0x27)|(1<<12))
 #define SRL		F3(2, 0x26)
+#define SRLX		(F3(2, 0x26)|(1<<12))
 #define JMPL		F3(2, 0x38)
+#define SAVE		F3(2, 0x3c)
+#define RESTORE		F3(2, 0x3d)
 #define CALL		F1(1)
 #define BR		F2(0, 0x01)
 #define RD_Y		F3(2, 0x28)
@@ -114,7 +131,14 @@ static void bpf_flush_icache(void *start_, void *end_)
 #define LD8		F3(3, 0x01)
 #define LD16		F3(3, 0x02)
 #define LD64		F3(3, 0x0b)
+#define LD64A		F3(3, 0x1b)
+#define ST8		F3(3, 0x05)
+#define ST16		F3(3, 0x06)
 #define ST32		F3(3, 0x04)
+#define ST64		F3(3, 0x0e)
+
+#define CAS		F3(3, 0x3c)
+#define CASX		F3(3, 0x3e)
 
 #ifdef CONFIG_SPARC64
 #define LDPTR		LD64
@@ -131,685 +155,1030 @@ static void bpf_flush_icache(void *start_, void *end_)
 #define LDPTRI		(LDPTR | IMMED)
 #define ST32I		(ST32 | IMMED)
 
-#define emit_nop()		\
-do {				\
-	*prog++ = SETHI(0, G0);	\
-} while (0)
-
-#define emit_neg()					\
-do {	/* sub %g0, r_A, r_A */				\
-	*prog++ = SUB | RS1(G0) | RS2(r_A) | RD(r_A);	\
-} while (0)
-
-#define emit_reg_move(FROM, TO)				\
-do {	/* or %g0, FROM, TO */				\
-	*prog++ = OR | RS1(G0) | RS2(FROM) | RD(TO);	\
-} while (0)
-
-#define emit_clear(REG)					\
-do {	/* or %g0, %g0, REG */				\
-	*prog++ = OR | RS1(G0) | RS2(G0) | RD(REG);	\
-} while (0)
-
-#define emit_set_const(K, REG)					\
-do {	/* sethi %hi(K), REG */					\
-	*prog++ = SETHI(K, REG);				\
-	/* or REG, %lo(K), REG */				\
-	*prog++ = OR_LO(K, REG);				\
-} while (0)
-
-	/* Emit
-	 *
-	 *	OP	r_A, r_X, r_A
-	 */
-#define emit_alu_X(OPCODE)					\
-do {								\
-	seen |= SEEN_XREG;					\
-	*prog++ = OPCODE | RS1(r_A) | RS2(r_X) | RD(r_A);	\
-} while (0)
-
-	/* Emit either:
-	 *
-	 *	OP	r_A, K, r_A
-	 *
-	 * or
-	 *
-	 *	sethi	%hi(K), r_TMP
-	 *	or	r_TMP, %lo(K), r_TMP
-	 *	OP	r_A, r_TMP, r_A
-	 *
-	 * depending upon whether K fits in a signed 13-bit
-	 * immediate instruction field.  Emit nothing if K
-	 * is zero.
-	 */
-#define emit_alu_K(OPCODE, K)					\
-do {								\
-	if (K || OPCODE == AND || OPCODE == MUL) {		\
-		unsigned int _insn = OPCODE;			\
-		_insn |= RS1(r_A) | RD(r_A);			\
-		if (is_simm13(K)) {				\
-			*prog++ = _insn | IMMED | S13(K);	\
-		} else {					\
-			emit_set_const(K, r_TMP);		\
-			*prog++ = _insn | RS2(r_TMP);		\
-		}						\
-	}							\
-} while (0)
-
-#define emit_loadimm(K, DEST)						\
-do {									\
-	if (is_simm13(K)) {						\
-		/* or %g0, K, DEST */					\
-		*prog++ = OR | IMMED | RS1(G0) | S13(K) | RD(DEST);	\
-	} else {							\
-		emit_set_const(K, DEST);				\
-	}								\
-} while (0)
-
-#define emit_loadptr(BASE, STRUCT, FIELD, DEST)				\
-do {	unsigned int _off = offsetof(STRUCT, FIELD);			\
-	BUILD_BUG_ON(FIELD_SIZEOF(STRUCT, FIELD) != sizeof(void *));	\
-	*prog++ = LDPTRI | RS1(BASE) | S13(_off) | RD(DEST);		\
-} while (0)
-
-#define emit_load32(BASE, STRUCT, FIELD, DEST)				\
-do {	unsigned int _off = offsetof(STRUCT, FIELD);			\
-	BUILD_BUG_ON(FIELD_SIZEOF(STRUCT, FIELD) != sizeof(u32));	\
-	*prog++ = LD32I | RS1(BASE) | S13(_off) | RD(DEST);		\
-} while (0)
-
-#define emit_load16(BASE, STRUCT, FIELD, DEST)				\
-do {	unsigned int _off = offsetof(STRUCT, FIELD);			\
-	BUILD_BUG_ON(FIELD_SIZEOF(STRUCT, FIELD) != sizeof(u16));	\
-	*prog++ = LD16I | RS1(BASE) | S13(_off) | RD(DEST);		\
-} while (0)
-
-#define __emit_load8(BASE, STRUCT, FIELD, DEST)				\
-do {	unsigned int _off = offsetof(STRUCT, FIELD);			\
-	*prog++ = LD8I | RS1(BASE) | S13(_off) | RD(DEST);		\
-} while (0)
-
-#define emit_load8(BASE, STRUCT, FIELD, DEST)				\
-do {	BUILD_BUG_ON(FIELD_SIZEOF(STRUCT, FIELD) != sizeof(u8));	\
-	__emit_load8(BASE, STRUCT, FIELD, DEST);			\
-} while (0)
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
+	[BPF_REG_0] = I5,
+
+	/* arguments from eBPF program to in-kernel function */
+	[BPF_REG_1] = I0,
+	[BPF_REG_2] = I1,
+	[BPF_REG_3] = I2,
+	[BPF_REG_4] = I3,
+	[BPF_REG_5] = I4,
+
+	/* callee saved registers that in-kernel function will preserve */
+	[BPF_REG_6] = L0,
+	[BPF_REG_7] = L1,
+	[BPF_REG_8] = L2,
+	[BPF_REG_9] = L3,
+
+	/* read-only frame pointer to access stack */
+	[BPF_REG_FP] = FP,
+
+	/* temporary register for internal BPF JIT */
+	[TMP_REG_1] = G1,
+	[TMP_REG_2] = G3,
+	[TMP_REG_3] = L6,
+
+	[SKB_HLEN_REG] = L4,
+	[SKB_DATA_REG] = L5,
+};
+
+static void emit(const u32 insn, struct jit_ctx *ctx)
+{
+	if (ctx->image != NULL)
+		ctx->image[ctx->idx] = insn;
 
-#ifdef CONFIG_SPARC64
-#define BIAS (STACK_BIAS - 4)
-#else
-#define BIAS (-4)
-#endif
+	ctx->idx++;
+}
 
-#define emit_ldmem(OFF, DEST)						\
-do {	*prog++ = LD32I | RS1(SP) | S13(BIAS - (OFF)) | RD(DEST);	\
-} while (0)
+static void emit_call(u32 *func, struct jit_ctx *ctx)
+{
+	if (ctx->image != NULL) {
+		void *here = &ctx->image[ctx->idx];
+		unsigned int off;
 
-#define emit_stmem(OFF, SRC)						\
-do {	*prog++ = ST32I | RS1(SP) | S13(BIAS - (OFF)) | RD(SRC);	\
-} while (0)
+		off = (void *)func - here;
+		ctx->image[ctx->idx] = CALL | ((off >> 2) & 0x3fffffff);
+	}
+	ctx->idx++;
+}
 
-#ifdef CONFIG_SMP
-#ifdef CONFIG_SPARC64
-#define emit_load_cpu(REG)						\
-	emit_load16(G6, struct thread_info, cpu, REG)
-#else
-#define emit_load_cpu(REG)						\
-	emit_load32(G6, struct thread_info, cpu, REG)
-#endif
-#else
-#define emit_load_cpu(REG)	emit_clear(REG)
-#endif
+static void emit_nop(struct jit_ctx *ctx)
+{
+	emit(SETHI(0, G0), ctx);
+}
 
-#define emit_skb_loadptr(FIELD, DEST) \
-	emit_loadptr(r_SKB, struct sk_buff, FIELD, DEST)
-#define emit_skb_load32(FIELD, DEST) \
-	emit_load32(r_SKB, struct sk_buff, FIELD, DEST)
-#define emit_skb_load16(FIELD, DEST) \
-	emit_load16(r_SKB, struct sk_buff, FIELD, DEST)
-#define __emit_skb_load8(FIELD, DEST) \
-	__emit_load8(r_SKB, struct sk_buff, FIELD, DEST)
-#define emit_skb_load8(FIELD, DEST) \
-	emit_load8(r_SKB, struct sk_buff, FIELD, DEST)
+static void emit_reg_move(u32 from, u32 to, struct jit_ctx *ctx)
+{
+	emit(OR | RS1(G0) | RS2(from) | RD(to), ctx);
+}
 
-#define emit_jmpl(BASE, IMM_OFF, LREG) \
-	*prog++ = (JMPL | IMMED | RS1(BASE) | S13(IMM_OFF) | RD(LREG))
+/* Emit 32-bit constant, zero extended. */
+static void emit_set_const(s32 K, u32 reg, struct jit_ctx *ctx)
+{
+	emit(SETHI(K, reg), ctx);
+	emit(OR_LO(K, reg), ctx);
+}
 
-#define emit_call(FUNC)					\
-do {	void *_here = image + addrs[i] - 8;		\
-	unsigned int _off = (void *)(FUNC) - _here;	\
-	*prog++ = CALL | (((_off) >> 2) & 0x3fffffff);	\
-	emit_nop();					\
-} while (0)
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
 
-#define emit_branch(BR_OPC, DEST)			\
-do {	unsigned int _here = addrs[i] - 8;		\
-	*prog++ = BR_OPC | WDISP22((DEST) - _here);	\
-} while (0)
+/* Emit:	OP	DST, SRC, DST */
+static void emit_alu(u32 opcode, u32 src, u32 dst, struct jit_ctx *ctx)
+{
+	emit(opcode | RS1(dst) | RS2(src) | RD(dst), ctx);
+}
 
-#define emit_branch_off(BR_OPC, OFF)			\
-do {	*prog++ = BR_OPC | WDISP22(OFF);		\
-} while (0)
+/* Emit:	OP	A, B, C */
+static void emit_alu3(u32 opcode, u32 a, u32 b, u32 c, struct jit_ctx *ctx)
+{
+	emit(opcode | RS1(a) | RS2(b) | RD(c), ctx);
+}
 
-#define emit_jump(DEST)		emit_branch(BA, DEST)
+/* Emit either:
+ *
+ *	OP	DST, K, DST
+ *
+ * or
+ *
+ *	sethi	%hi(K), r_TMP
+ *	or	r_TMP, %lo(K), r_TMP
+ *	OP	DST, r_TMP, DST
+ *
+ * depending upon whether K fits in a signed 13-bit
+ * immediate instruction field.
+ */
+static void emit_alu_K(unsigned int opcode, unsigned int dst, unsigned int imm,
+		       struct jit_ctx *ctx)
+{
+	bool small_immed = is_simm13(imm);
+	unsigned int insn = opcode;
 
-#define emit_read_y(REG)	*prog++ = RD_Y | RD(REG)
-#define emit_write_y(REG)	*prog++ = WR_Y | IMMED | RS1(REG) | S13(0)
+	insn |= RS1(dst) | RD(dst);
+	if (small_immed) {
+		emit(insn | IMMED | S13(imm), ctx);
+	} else {
+		unsigned int tmp = bpf2sparc[TMP_REG_1];
 
-#define emit_cmp(R1, R2) \
-	*prog++ = (SUBCC | RS1(R1) | RS2(R2) | RD(G0))
+		ctx->tmp_1_used = true;
 
-#define emit_cmpi(R1, IMM) \
-	*prog++ = (SUBCC | IMMED | RS1(R1) | S13(IMM) | RD(G0));
+		emit_set_const_sext(imm, tmp, ctx);
+		emit(insn | RS2(tmp), ctx);
+	}
+}
 
-#define emit_btst(R1, R2) \
-	*prog++ = (ANDCC | RS1(R1) | RS2(R2) | RD(G0))
+/* Emit either:
+ *
+ *	OP	SRC, K, DST
+ *
+ * or
+ *
+ *	sethi	%hi(K), r_TMP
+ *	or	r_TMP, %lo(K), r_TMP
+ *	OP	SRC, r_TMP, DST
+ *
+ * depending upon whether K fits in a signed 13-bit
+ * immediate instruction field.
+ */
+static void emit_alu3_K(unsigned int opcode, unsigned int src, unsigned int imm,
+			unsigned int dst, struct jit_ctx *ctx)
+{
+	bool small_immed = is_simm13(imm);
+	unsigned int insn = opcode;
 
-#define emit_btsti(R1, IMM) \
-	*prog++ = (ANDCC | IMMED | RS1(R1) | S13(IMM) | RD(G0));
+	insn |= RS1(src) | RD(dst);
+	if (small_immed) {
+		emit(insn | IMMED | S13(imm), ctx);
+	} else {
+		unsigned int tmp = bpf2sparc[TMP_REG_1];
 
-#define emit_sub(R1, R2, R3) \
-	*prog++ = (SUB | RS1(R1) | RS2(R2) | RD(R3))
+		ctx->tmp_1_used = true;
 
-#define emit_subi(R1, IMM, R3) \
-	*prog++ = (SUB | IMMED | RS1(R1) | S13(IMM) | RD(R3))
+		emit_set_const_sext(imm, tmp, ctx);
+		emit(insn | RS2(tmp), ctx);
+	}
+}
 
-#define emit_add(R1, R2, R3) \
-	*prog++ = (ADD | RS1(R1) | RS2(R2) | RD(R3))
+static void emit_loadimm32(s32 K, unsigned int dest, struct jit_ctx *ctx)
+{
+	if (K >= 0 && is_simm13(K)) {
+		/* or %g0, K, DEST */
+		emit(OR | IMMED | RS1(G0) | S13(K) | RD(dest), ctx);
+	} else {
+		emit_set_const(K, dest, ctx);
+	}
+}
 
-#define emit_addi(R1, IMM, R3) \
-	*prog++ = (ADD | IMMED | RS1(R1) | S13(IMM) | RD(R3))
+static void emit_loadimm(s32 K, unsigned int dest, struct jit_ctx *ctx)
+{
+	if (is_simm13(K)) {
+		/* or %g0, K, DEST */
+		emit(OR | IMMED | RS1(G0) | S13(K) | RD(dest), ctx);
+	} else {
+		emit_set_const(K, dest, ctx);
+	}
+}
 
-#define emit_and(R1, R2, R3) \
-	*prog++ = (AND | RS1(R1) | RS2(R2) | RD(R3))
+static void emit_loadimm_sext(s32 K, unsigned int dest, struct jit_ctx *ctx)
+{
+	if (is_simm13(K)) {
+		/* or %g0, K, DEST */
+		emit(OR | IMMED | RS1(G0) | S13(K) | RD(dest), ctx);
+	} else {
+		emit_set_const_sext(K, dest, ctx);
+	}
+}
 
-#define emit_andi(R1, IMM, R3) \
-	*prog++ = (AND | IMMED | RS1(R1) | S13(IMM) | RD(R3))
+static void emit_loadimm64(u64 K, unsigned int dest, struct jit_ctx *ctx)
+{
+	unsigned int tmp = bpf2sparc[TMP_REG_1];
+	u32 high_part = (K >> 32);
+	u32 low_part = (K & 0xffffffff);
 
-#define emit_alloc_stack(SZ) \
-	*prog++ = (SUB | IMMED | RS1(SP) | S13(SZ) | RD(SP))
+	ctx->tmp_1_used = true;
 
-#define emit_release_stack(SZ) \
-	*prog++ = (ADD | IMMED | RS1(SP) | S13(SZ) | RD(SP))
+	emit_set_const(high_part, tmp, ctx);
+	emit_set_const(low_part, dest, ctx);
+	emit_alu_K(SLLX, tmp, 32, ctx);
+	emit(OR | RS1(dest) | RS2(tmp) | RD(dest), ctx);
+}
 
-/* A note about branch offset calculations.  The addrs[] array,
- * indexed by BPF instruction, records the address after all the
- * sparc instructions emitted for that BPF instruction.
- *
- * The most common case is to emit a branch at the end of such
- * a code sequence.  So this would be two instructions, the
- * branch and it's delay slot.
- *
- * Therefore by default the branch emitters calculate the branch
- * offset field as:
- *
- *	destination - (addrs[i] - 8)
- *
- * This "addrs[i] - 8" is the address of the branch itself or
- * what "." would be in assembler notation.  The "8" part is
- * how we take into consideration the branch and it's delay
- * slot mentioned above.
- *
- * Sometimes we need to emit a branch earlier in the code
- * sequence.  And in these situations we adjust "destination"
- * to accommodate this difference.  For example, if we needed
- * to emit a branch (and it's delay slot) right before the
- * final instruction emitted for a BPF opcode, we'd use
- * "destination + 4" instead of just plain "destination" above.
- *
- * This is why you see all of these funny emit_branch() and
- * emit_jump() calls with adjusted offsets.
- */
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
 
-void bpf_jit_compile(struct bpf_prog *fp)
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
 {
-	unsigned int cleanup_addr, proglen, oldproglen = 0;
-	u32 temp[8], *prog, *func, seen = 0, pass;
-	const struct sock_filter *filter = fp->insns;
-	int i, flen = fp->len, pc_ret0 = -1;
-	unsigned int *addrs;
-	void *image;
+	const u8 r_headlen = bpf2sparc[SKB_HLEN_REG];
+	const u8 r_data = bpf2sparc[SKB_DATA_REG];
+	const u8 r_tmp = bpf2sparc[TMP_REG_1];
+	unsigned int off;
 
-	if (!bpf_jit_enable)
-		return;
+	off = offsetof(struct sk_buff, len);
+	emit(LD32I | RS1(r_skb) | S13(off) | RD(r_headlen), ctx);
 
-	addrs = kmalloc(flen * sizeof(*addrs), GFP_KERNEL);
-	if (addrs == NULL)
-		return;
+	off = offsetof(struct sk_buff, data_len);
+	emit(LD32I | RS1(r_skb) | S13(off) | RD(r_tmp), ctx);
 
-	/* Before first pass, make a rough estimation of addrs[]
-	 * each bpf instruction is translated to less than 64 bytes
-	 */
-	for (proglen = 0, i = 0; i < flen; i++) {
-		proglen += 64;
-		addrs[i] = proglen;
+	emit(SUB | RS1(r_headlen) | RS2(r_tmp) | RD(r_headlen), ctx);
+
+	off = offsetof(struct sk_buff, data);
+	emit(LDPTRI | RS1(r_skb) | S13(off) | RD(r_data), ctx);
+}
+
+static void build_prologue(struct jit_ctx *ctx)
+{
+	s32 stack_needed = 176;
+
+	if (ctx->saw_frame_pointer)
+		stack_needed += MAX_BPF_STACK;
+
+	/* save %sp, -176, %sp */
+	emit(SAVE | IMMED | RS1(SP) | S13(-stack_needed) | RD(SP), ctx);
+
+	if (ctx->saw_ld_abs_ind) {
+		load_skb_regs(ctx, bpf2sparc[BPF_REG_1]);
+	} else {
+		emit_nop(ctx);
+		emit_nop(ctx);
+		emit_nop(ctx);
+		emit_nop(ctx);
 	}
-	cleanup_addr = proglen; /* epilogue address */
-	image = NULL;
-	for (pass = 0; pass < 10; pass++) {
-		u8 seen_or_pass0 = (pass == 0) ? (SEEN_XREG | SEEN_DATAREF | SEEN_MEM) : seen;
-
-		/* no prologue/epilogue for trivial filters (RET something) */
-		proglen = 0;
-		prog = temp;
-
-		/* Prologue */
-		if (seen_or_pass0) {
-			if (seen_or_pass0 & SEEN_MEM) {
-				unsigned int sz = BASE_STACKFRAME;
-				sz += BPF_MEMWORDS * sizeof(u32);
-				emit_alloc_stack(sz);
-			}
-
-			/* Make sure we dont leek kernel memory. */
-			if (seen_or_pass0 & SEEN_XREG)
-				emit_clear(r_X);
-
-			/* If this filter needs to access skb data,
-			 * load %o4 and %o5 with:
-			 *  %o4 = skb->len - skb->data_len
-			 *  %o5 = skb->data
-			 * And also back up %o7 into r_saved_O7 so we can
-			 * invoke the stubs using 'call'.
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
+	emit(RESTORE | RS1(I5) | RS2(G0) | RD(O0), ctx);
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
+	if (insn->src_reg == BPF_REG_FP || insn->dst_reg == BPF_REG_FP) {
+		ctx->saw_frame_pointer = true;
+		if (BPF_CLASS(code) == BPF_ALU ||
+		    BPF_CLASS(code) == BPF_ALU64) {
+			pr_err_once("ALU op on FP not supported by JIT\n");
+			return -EINVAL;
+		}		
+	}
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
+		unsigned int tmp = bpf2sparc[TMP_REG_1];
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
+		unsigned int tmp = bpf2sparc[TMP_REG_1];
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
+		emit_loadimm(imm, dst, ctx);
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
+	case BPF_ALU | BPF_MOD | BPF_K: {
+		unsigned int tmp = bpf2sparc[TMP_REG_2];
+
+		if (imm == 0)
+			return -EINVAL;
+
+		/* XXX Emit non-simm13 constants only once... */
+		ctx->tmp_2_used = true;
+
+		emit_write_y(G0, ctx);
+		emit_alu3_K(DIV, dst, imm, tmp, ctx);
+		emit_alu3_K(MULX, tmp, imm, tmp, ctx);
+		emit_alu3(SUB, dst, tmp, dst, ctx);
+		goto do_alu32_trunc;
+	}
+	case BPF_ALU64 | BPF_MOD | BPF_K: {
+		unsigned int tmp = bpf2sparc[TMP_REG_2];
+
+		if (imm == 0)
+			return -EINVAL;
+
+		/* XXX Emit non-simm13 constants only once... */
+		ctx->tmp_2_used = true;
+
+		emit_alu3_K(UDIVX, dst, imm, tmp, ctx);
+		emit_alu3_K(MULX, tmp, imm, tmp, ctx);
+		emit_alu3(SUB, dst, tmp, dst, ctx);
+		break;
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
 			 */
-			if (seen_or_pass0 & SEEN_DATAREF) {
-				emit_load32(r_SKB, struct sk_buff, len, r_HEADLEN);
-				emit_load32(r_SKB, struct sk_buff, data_len, r_TMP);
-				emit_sub(r_HEADLEN, r_TMP, r_HEADLEN);
-				emit_loadptr(r_SKB, struct sk_buff, data, r_SKB_DATA);
-			}
+			return -EFAULT;
 		}
-		emit_reg_move(O7, r_saved_O7);
-
-		/* Make sure we dont leak kernel information to the user. */
-		if (bpf_needs_clear_a(&filter[0]))
-			emit_clear(r_A); /* A = 0 */
-
-		for (i = 0; i < flen; i++) {
-			unsigned int K = filter[i].k;
-			unsigned int t_offset;
-			unsigned int f_offset;
-			u32 t_op, f_op;
-			u16 code = bpf_anc_helper(&filter[i]);
-			int ilen;
-
-			switch (code) {
-			case BPF_ALU | BPF_ADD | BPF_X:	/* A += X; */
-				emit_alu_X(ADD);
-				break;
-			case BPF_ALU | BPF_ADD | BPF_K:	/* A += K; */
-				emit_alu_K(ADD, K);
-				break;
-			case BPF_ALU | BPF_SUB | BPF_X:	/* A -= X; */
-				emit_alu_X(SUB);
-				break;
-			case BPF_ALU | BPF_SUB | BPF_K:	/* A -= K */
-				emit_alu_K(SUB, K);
-				break;
-			case BPF_ALU | BPF_AND | BPF_X:	/* A &= X */
-				emit_alu_X(AND);
-				break;
-			case BPF_ALU | BPF_AND | BPF_K:	/* A &= K */
-				emit_alu_K(AND, K);
-				break;
-			case BPF_ALU | BPF_OR | BPF_X:	/* A |= X */
-				emit_alu_X(OR);
-				break;
-			case BPF_ALU | BPF_OR | BPF_K:	/* A |= K */
-				emit_alu_K(OR, K);
-				break;
-			case BPF_ANC | SKF_AD_ALU_XOR_X: /* A ^= X; */
-			case BPF_ALU | BPF_XOR | BPF_X:
-				emit_alu_X(XOR);
-				break;
-			case BPF_ALU | BPF_XOR | BPF_K:	/* A ^= K */
-				emit_alu_K(XOR, K);
-				break;
-			case BPF_ALU | BPF_LSH | BPF_X:	/* A <<= X */
-				emit_alu_X(SLL);
-				break;
-			case BPF_ALU | BPF_LSH | BPF_K:	/* A <<= K */
-				emit_alu_K(SLL, K);
-				break;
-			case BPF_ALU | BPF_RSH | BPF_X:	/* A >>= X */
-				emit_alu_X(SRL);
-				break;
-			case BPF_ALU | BPF_RSH | BPF_K:	/* A >>= K */
-				emit_alu_K(SRL, K);
-				break;
-			case BPF_ALU | BPF_MUL | BPF_X:	/* A *= X; */
-				emit_alu_X(MUL);
-				break;
-			case BPF_ALU | BPF_MUL | BPF_K:	/* A *= K */
-				emit_alu_K(MUL, K);
-				break;
-			case BPF_ALU | BPF_DIV | BPF_K:	/* A /= K with K != 0*/
-				if (K == 1)
-					break;
-				emit_write_y(G0);
-#ifdef CONFIG_SPARC32
-				/* The Sparc v8 architecture requires
-				 * three instructions between a %y
-				 * register write and the first use.
-				 */
-				emit_nop();
-				emit_nop();
-				emit_nop();
-#endif
-				emit_alu_K(DIV, K);
-				break;
-			case BPF_ALU | BPF_DIV | BPF_X:	/* A /= X; */
-				emit_cmpi(r_X, 0);
-				if (pc_ret0 > 0) {
-					t_offset = addrs[pc_ret0 - 1];
-#ifdef CONFIG_SPARC32
-					emit_branch(BE, t_offset + 20);
-#else
-					emit_branch(BE, t_offset + 8);
-#endif
-					emit_nop(); /* delay slot */
-				} else {
-					emit_branch_off(BNE, 16);
-					emit_nop();
-#ifdef CONFIG_SPARC32
-					emit_jump(cleanup_addr + 20);
-#else
-					emit_jump(cleanup_addr + 8);
-#endif
-					emit_clear(r_A);
-				}
-				emit_write_y(G0);
-#ifdef CONFIG_SPARC32
-				/* The Sparc v8 architecture requires
-				 * three instructions between a %y
-				 * register write and the first use.
-				 */
-				emit_nop();
-				emit_nop();
-				emit_nop();
-#endif
-				emit_alu_X(DIV);
-				break;
-			case BPF_ALU | BPF_NEG:
-				emit_neg();
-				break;
-			case BPF_RET | BPF_K:
-				if (!K) {
-					if (pc_ret0 == -1)
-						pc_ret0 = i;
-					emit_clear(r_A);
-				} else {
-					emit_loadimm(K, r_A);
-				}
-				/* Fallthrough */
-			case BPF_RET | BPF_A:
-				if (seen_or_pass0) {
-					if (i != flen - 1) {
-						emit_jump(cleanup_addr);
-						emit_nop();
-						break;
-					}
-					if (seen_or_pass0 & SEEN_MEM) {
-						unsigned int sz = BASE_STACKFRAME;
-						sz += BPF_MEMWORDS * sizeof(u32);
-						emit_release_stack(sz);
-					}
-				}
-				/* jmpl %r_saved_O7 + 8, %g0 */
-				emit_jmpl(r_saved_O7, 8, G0);
-				emit_reg_move(r_A, O0); /* delay slot */
-				break;
-			case BPF_MISC | BPF_TAX:
-				seen |= SEEN_XREG;
-				emit_reg_move(r_A, r_X);
-				break;
-			case BPF_MISC | BPF_TXA:
-				seen |= SEEN_XREG;
-				emit_reg_move(r_X, r_A);
-				break;
-			case BPF_ANC | SKF_AD_CPU:
-				emit_load_cpu(r_A);
-				break;
-			case BPF_ANC | SKF_AD_PROTOCOL:
-				emit_skb_load16(protocol, r_A);
-				break;
-			case BPF_ANC | SKF_AD_PKTTYPE:
-				__emit_skb_load8(__pkt_type_offset, r_A);
-				emit_andi(r_A, PKT_TYPE_MAX, r_A);
-				emit_alu_K(SRL, 5);
-				break;
-			case BPF_ANC | SKF_AD_IFINDEX:
-				emit_skb_loadptr(dev, r_A);
-				emit_cmpi(r_A, 0);
-				emit_branch(BE_PTR, cleanup_addr + 4);
-				emit_nop();
-				emit_load32(r_A, struct net_device, ifindex, r_A);
-				break;
-			case BPF_ANC | SKF_AD_MARK:
-				emit_skb_load32(mark, r_A);
-				break;
-			case BPF_ANC | SKF_AD_QUEUE:
-				emit_skb_load16(queue_mapping, r_A);
-				break;
-			case BPF_ANC | SKF_AD_HATYPE:
-				emit_skb_loadptr(dev, r_A);
-				emit_cmpi(r_A, 0);
-				emit_branch(BE_PTR, cleanup_addr + 4);
-				emit_nop();
-				emit_load16(r_A, struct net_device, type, r_A);
-				break;
-			case BPF_ANC | SKF_AD_RXHASH:
-				emit_skb_load32(hash, r_A);
-				break;
-			case BPF_ANC | SKF_AD_VLAN_TAG:
-			case BPF_ANC | SKF_AD_VLAN_TAG_PRESENT:
-				emit_skb_load16(vlan_tci, r_A);
-				if (code != (BPF_ANC | SKF_AD_VLAN_TAG)) {
-					emit_alu_K(SRL, 12);
-					emit_andi(r_A, 1, r_A);
-				} else {
-					emit_loadimm(~VLAN_TAG_PRESENT, r_TMP);
-					emit_and(r_A, r_TMP, r_A);
-				}
-				break;
-			case BPF_LD | BPF_W | BPF_LEN:
-				emit_skb_load32(len, r_A);
-				break;
-			case BPF_LDX | BPF_W | BPF_LEN:
-				emit_skb_load32(len, r_X);
-				break;
-			case BPF_LD | BPF_IMM:
-				emit_loadimm(K, r_A);
-				break;
-			case BPF_LDX | BPF_IMM:
-				emit_loadimm(K, r_X);
-				break;
-			case BPF_LD | BPF_MEM:
-				seen |= SEEN_MEM;
-				emit_ldmem(K * 4, r_A);
-				break;
-			case BPF_LDX | BPF_MEM:
-				seen |= SEEN_MEM | SEEN_XREG;
-				emit_ldmem(K * 4, r_X);
-				break;
-			case BPF_ST:
-				seen |= SEEN_MEM;
-				emit_stmem(K * 4, r_A);
-				break;
-			case BPF_STX:
-				seen |= SEEN_MEM | SEEN_XREG;
-				emit_stmem(K * 4, r_X);
-				break;
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
 
-#define CHOOSE_LOAD_FUNC(K, func) \
-	((int)K < 0 ? ((int)K >= SKF_LL_OFF ? func##_negative_offset : func) : func##_positive_offset)
-
-			case BPF_LD | BPF_W | BPF_ABS:
-				func = CHOOSE_LOAD_FUNC(K, bpf_jit_load_word);
-common_load:			seen |= SEEN_DATAREF;
-				emit_loadimm(K, r_OFF);
-				emit_call(func);
-				break;
-			case BPF_LD | BPF_H | BPF_ABS:
-				func = CHOOSE_LOAD_FUNC(K, bpf_jit_load_half);
-				goto common_load;
-			case BPF_LD | BPF_B | BPF_ABS:
-				func = CHOOSE_LOAD_FUNC(K, bpf_jit_load_byte);
-				goto common_load;
-			case BPF_LDX | BPF_B | BPF_MSH:
-				func = CHOOSE_LOAD_FUNC(K, bpf_jit_load_byte_msh);
-				goto common_load;
-			case BPF_LD | BPF_W | BPF_IND:
-				func = bpf_jit_load_word;
-common_load_ind:		seen |= SEEN_DATAREF | SEEN_XREG;
-				if (K) {
-					if (is_simm13(K)) {
-						emit_addi(r_X, K, r_OFF);
-					} else {
-						emit_loadimm(K, r_TMP);
-						emit_add(r_X, r_TMP, r_OFF);
-					}
-				} else {
-					emit_reg_move(r_X, r_OFF);
-				}
-				emit_call(func);
-				break;
-			case BPF_LD | BPF_H | BPF_IND:
-				func = bpf_jit_load_half;
-				goto common_load_ind;
-			case BPF_LD | BPF_B | BPF_IND:
-				func = bpf_jit_load_byte;
-				goto common_load_ind;
-			case BPF_JMP | BPF_JA:
-				emit_jump(addrs[i + K]);
-				emit_nop();
-				break;
-
-#define COND_SEL(CODE, TOP, FOP)	\
-	case CODE:			\
-		t_op = TOP;		\
-		f_op = FOP;		\
-		goto cond_branch
-
-			COND_SEL(BPF_JMP | BPF_JGT | BPF_K, BGU, BLEU);
-			COND_SEL(BPF_JMP | BPF_JGE | BPF_K, BGEU, BLU);
-			COND_SEL(BPF_JMP | BPF_JEQ | BPF_K, BE, BNE);
-			COND_SEL(BPF_JMP | BPF_JSET | BPF_K, BNE, BE);
-			COND_SEL(BPF_JMP | BPF_JGT | BPF_X, BGU, BLEU);
-			COND_SEL(BPF_JMP | BPF_JGE | BPF_X, BGEU, BLU);
-			COND_SEL(BPF_JMP | BPF_JEQ | BPF_X, BE, BNE);
-			COND_SEL(BPF_JMP | BPF_JSET | BPF_X, BNE, BE);
-
-cond_branch:			f_offset = addrs[i + filter[i].jf];
-				t_offset = addrs[i + filter[i].jt];
-
-				/* same targets, can avoid doing the test :) */
-				if (filter[i].jt == filter[i].jf) {
-					emit_jump(t_offset);
-					emit_nop();
-					break;
-				}
-
-				switch (code) {
-				case BPF_JMP | BPF_JGT | BPF_X:
-				case BPF_JMP | BPF_JGE | BPF_X:
-				case BPF_JMP | BPF_JEQ | BPF_X:
-					seen |= SEEN_XREG;
-					emit_cmp(r_A, r_X);
-					break;
-				case BPF_JMP | BPF_JSET | BPF_X:
-					seen |= SEEN_XREG;
-					emit_btst(r_A, r_X);
-					break;
-				case BPF_JMP | BPF_JEQ | BPF_K:
-				case BPF_JMP | BPF_JGT | BPF_K:
-				case BPF_JMP | BPF_JGE | BPF_K:
-					if (is_simm13(K)) {
-						emit_cmpi(r_A, K);
-					} else {
-						emit_loadimm(K, r_TMP);
-						emit_cmp(r_A, r_TMP);
-					}
-					break;
-				case BPF_JMP | BPF_JSET | BPF_K:
-					if (is_simm13(K)) {
-						emit_btsti(r_A, K);
-					} else {
-						emit_loadimm(K, r_TMP);
-						emit_btst(r_A, r_TMP);
-					}
-					break;
-				}
-				if (filter[i].jt != 0) {
-					if (filter[i].jf)
-						t_offset += 8;
-					emit_branch(t_op, t_offset);
-					emit_nop(); /* delay slot */
-					if (filter[i].jf) {
-						emit_jump(f_offset);
-						emit_nop();
-					}
-					break;
-				}
-				emit_branch(f_op, f_offset);
-				emit_nop(); /* delay slot */
-				break;
-
-			default:
-				/* hmm, too complex filter, give up with jit compiler */
-				goto out;
-			}
-			ilen = (void *) prog - (void *) temp;
-			if (image) {
-				if (unlikely(proglen + ilen > oldproglen)) {
-					pr_err("bpb_jit_compile fatal error\n");
-					kfree(addrs);
-					module_memfree(image);
-					return;
-				}
-				memcpy(image + proglen, temp, ilen);
-			}
-			proglen += ilen;
-			addrs[i] = proglen;
-			prog = temp;
+	/* function call */
+	case BPF_JMP | BPF_CALL:
+	{
+		u8 *func = ((u8 *)__bpf_call_base) + imm;
+
+		emit_reg_move(bpf2sparc[BPF_REG_1], O0, ctx);
+		emit_reg_move(bpf2sparc[BPF_REG_2], O1, ctx);
+		emit_reg_move(bpf2sparc[BPF_REG_3], O2, ctx);
+		emit_reg_move(bpf2sparc[BPF_REG_4], O3, ctx);
+		emit_call((u32 *)func, ctx);
+		emit_reg_move(bpf2sparc[BPF_REG_5], O4, ctx);	/* delay slot */
+
+		emit_reg_move(O0, bpf2sparc[BPF_REG_0], ctx);
+
+		if (bpf_helper_changes_pkt_data(func) && ctx->saw_ld_abs_ind)
+			load_skb_regs(ctx, bpf2sparc[BPF_REG_6]);
+		break;
+	}
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
+		if (insn1.code != 0 || insn1.src_reg != 0 ||
+		    insn1.dst_reg != 0 || insn1.off != 0) {
+			/* Note: verifier in BPF core must catch invalid
+			 * instructions.
+			 */
+			pr_err_once("Invalid BPF_LD_IMM64 instruction\n");
+			return -EINVAL;
 		}
-		/* last bpf instruction is always a RET :
-		 * use it to give the cleanup instruction(s) addr
-		 */
-		cleanup_addr = proglen - 8; /* jmpl; mov r_A,%o0; */
-		if (seen_or_pass0 & SEEN_MEM)
-			cleanup_addr -= 4; /* add %sp, X, %sp; */
-
-		if (image) {
-			if (proglen != oldproglen)
-				pr_err("bpb_jit_compile proglen=%u != oldproglen=%u\n",
-				       proglen, oldproglen);
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
+		s32 real_off = off;
+
+		ctx->tmp_1_used = true;
+		if (src == FP)
+			real_off += STACK_BIAS;
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
 			break;
 		}
-		if (proglen == oldproglen) {
-			image = module_alloc(proglen);
-			if (!image)
-				goto out;
+
+		if (is_simm13(real_off)) {
+			opcode |= IMMED;
+			rs2 = S13(real_off);
+		} else {
+			emit_loadimm(real_off, tmp, ctx);
+			rs2 = RS2(tmp);
 		}
-		oldproglen = proglen;
+		emit(opcode | RS1(src) | rs2 | RD(dst), ctx);
+		break;
 	}
+	/* ST: *(size *)(dst + off) = imm */
+	case BPF_ST | BPF_MEM | BPF_W:
+	case BPF_ST | BPF_MEM | BPF_H:
+	case BPF_ST | BPF_MEM | BPF_B:
+	case BPF_ST | BPF_MEM | BPF_DW: {
+		const u8 tmp = bpf2sparc[TMP_REG_1];
+		const u8 tmp2 = bpf2sparc[TMP_REG_2];
+		u32 opcode = 0, rs2;
+		s32 real_off = off;
+
+		if (dst == FP)
+			real_off += STACK_BIAS;
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
 
-	if (bpf_jit_enable > 1)
-		bpf_jit_dump(flen, proglen, pass + 1, image);
+		if (is_simm13(real_off)) {
+			opcode |= IMMED;
+			rs2 = S13(real_off);
+		} else {
+			ctx->tmp_1_used = true;
+			emit_loadimm(real_off, tmp, ctx);
+			rs2 = RS2(tmp);
+		}
+		emit(opcode | RS1(dst) | rs2 | RD(tmp2), ctx);
+		break;
+	}
 
-	if (image) {
-		bpf_flush_icache(image, image + proglen);
-		fp->bpf_func = (void *)image;
-		fp->jited = 1;
+	/* STX: *(size *)(dst + off) = src */
+	case BPF_STX | BPF_MEM | BPF_W:
+	case BPF_STX | BPF_MEM | BPF_H:
+	case BPF_STX | BPF_MEM | BPF_B:
+	case BPF_STX | BPF_MEM | BPF_DW: {
+		const u8 tmp = bpf2sparc[TMP_REG_1];
+		u32 opcode = 0, rs2;
+		s32 real_off = off;
+
+		if (dst == FP)
+			real_off += STACK_BIAS;
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
+		if (is_simm13(real_off)) {
+			opcode |= IMMED;
+			rs2 = S13(real_off);
+		} else {
+			ctx->tmp_1_used = true;
+			emit_loadimm(real_off, tmp, ctx);
+			rs2 = RS2(tmp);
+		}
+		emit(opcode | RS1(dst) | rs2 | RD(src), ctx);
+		break;
 	}
-out:
-	kfree(addrs);
-	return;
+
+	/* STX XADD: lock *(u32 *)(dst + off) += src */
+	case BPF_STX | BPF_XADD | BPF_W: {
+		const u8 tmp = bpf2sparc[TMP_REG_1];
+		const u8 tmp2 = bpf2sparc[TMP_REG_2];
+		const u8 tmp3 = bpf2sparc[TMP_REG_3];
+		s32 real_off = off;
+
+		ctx->tmp_1_used = true;
+		ctx->tmp_2_used = true;
+		ctx->tmp_3_used = true;
+		if (dst == FP)
+			real_off += STACK_BIAS;
+		emit_loadimm(real_off, tmp, ctx);
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
+		s32 real_off = off;
+
+		ctx->tmp_1_used = true;
+		ctx->tmp_2_used = true;
+		ctx->tmp_3_used = true;
+		if (dst == FP)
+			real_off += STACK_BIAS;
+		emit_loadimm(real_off, tmp, ctx);
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
+		emit_reg_move(O0, I5, ctx);
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
+		if (ctx->image == NULL)
+			ctx->offset[i] = ctx->idx;
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
 }
 
-void bpf_jit_free(struct bpf_prog *fp)
+struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *prog)
 {
-	if (fp->jited)
-		module_memfree(fp->bpf_func);
+	struct bpf_prog *tmp, *orig_prog = prog;
+	bool tmp_blinded = false;
+	struct jit_ctx ctx;
+	struct bpf_binary_header *header;
+	int image_size;
+	u8 *image_ptr;
+
+	if (!bpf_jit_enable)
+		return orig_prog;
+
+	if (!prog || !prog->len)
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
 
-	bpf_prog_unlock_free(fp);
+	memset(&ctx, 0, sizeof(ctx));
+	ctx.prog = prog;
+
+	ctx.offset = kcalloc(prog->len, sizeof(unsigned int), GFP_KERNEL);
+	if (ctx.offset == NULL) {
+		prog = orig_prog;
+		goto out;
+	}
+
+	/* 1. Initial fake pass to compute ctx->idx. */
+
+	/* Fake pass to fill in ctx->offset and ctx->tmp_{1,2}_used. */
+	build_prologue(&ctx);
+	if (build_body(&ctx)) {
+		prog = orig_prog;
+		goto out_off;
+	}
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
+	/* 2. Now, the actual pass. */
+
+	ctx.image = (u32 *)image_ptr;
+	ctx.idx = 0;
+
+	build_prologue(&ctx);
+
+	if (build_body(&ctx)) {
+		bpf_jit_binary_free(header);
+		prog = orig_prog;
+		goto out_off;
+	}
+
+	build_epilogue(&ctx);
+
+	if (bpf_jit_enable > 1)
+		bpf_jit_dump(prog->len, image_size, 2, ctx.image);
+	bpf_flush_icache(ctx.image, ctx.image + image_size);
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
 }
