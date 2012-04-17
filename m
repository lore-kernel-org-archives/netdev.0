From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: filter: Just In Time compiler for sparc
Date: Tue, 17 Apr 2012 16:44:00 -0400 (EDT)
Message-ID: <20120417.164400.89608576188768018.davem@davemloft.net>
References: <20120416.225823.1395194623649559124.davem@davemloft.net>
	<20120417195716.GA26750@merkur.ravnborg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sparclinux@vger.kernel.org
To: sam@ravnborg.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58475 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753555Ab2DQUoF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 16:44:05 -0400
In-Reply-To: <20120417195716.GA26750@merkur.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sam Ravnborg <sam@ravnborg.org>
Date: Tue, 17 Apr 2012 21:57:16 +0200

> I hope you had some fun doing this work - it does not look simple!

Like most programming tasks, it was just like solving a sudoku
puzzle. :-)

>> +	select HAVE_BPF_JIT
> If we sorted this block of select then the chances
> for merge conflict would be smaller.
> But this is not this patch to do so.

I also think we should create an arch/sparc/Kbuild for sparc
too, just like x86 has.

> Nice helpers - they made it easier for me to follow the assembler.
> r_SKB is not used in assembler?

It is used, but indirectly.  When we call the super slow paths
we have to pass r_SKB in, but we first temporarily allocate a
register window for the function call.  As a side effect
r_SKB (%o0) becomes %i0 so we can't just use r_SKB in this case.

>> +#ifdef CONFIG_SPARC64
>> +#define SAVE_SZ		176
>> +#define SCRATCH_OFF	STACK_BIAS + 128
>> +#define BE_PTR(label)	be,pn %xcc, label
>> +#else
>> +#define SAVE_SZ		96
>> +#define SCRATCH_OFF	72
>> +#define BE_PTR(label)	be label
>> +#endif
> 
> Is it coincidentally that SAVE_SZ has same value as BASE_STACKFRAME?
> From my quick browse of the code I think this is two distinct things,
> but if not we should move the definition to the header file and use the same.

They are identical values but used in two different situations and
thus best to keep them different in case we want to adjust one in the
future.

BASE_STACKFRAME is used to compute the stack space to allocate for the
whole JIT program if it makes use of the scratch memory area.

SAVE_SZ is used for the register window allocate we make in the stubs
when calling the slow path SKB helper functions.

>> +bpf_error:
>> +	jmpl	r_saved_O7 + 8, %g0
>> +	 clr	%o0
> 
> I wondered about this - because this is the only reference to %03 aka r_saved_O7
> And then the + 8 also puzzeled me.
> 
> A small comment would be nice.

I'll add a comment, but not a small one :-)

>> +/* assembly code in arch/sparc/net/bpf_jit_asm.S */
>> +extern u32 bpf_jit_load_word[];
>> +extern u32 bpf_jit_load_half[];
>> +extern u32 bpf_jit_load_byte[];
>> +extern u32 bpf_jit_load_byte_msh[];
>> +extern u32 bpf_jit_load_word_positive_offset[];
>> +extern u32 bpf_jit_load_half_positive_offset[];
>> +extern u32 bpf_jit_load_byte_positive_offset[];
>> +extern u32 bpf_jit_load_byte_msh_positive_offset[];
>> +extern u32 bpf_jit_load_word_negative_offset[];
>> +extern u32 bpf_jit_load_half_negative_offset[];
>> +extern u32 bpf_jit_load_byte_negative_offset[];
>> +extern u32 bpf_jit_load_byte_msh_negative_offset[];
> 
> I know this is from assembler files - but I hate externs in .c files.
> sparse did not complain though.

I'll put these into bpf_jit.h

>> +#define CONDN		COND (0x0)
>> +#define CONDE		COND (0x1)
>> +#define CONDLE		COND (0x2)
>> +#define CONDL		COND (0x3)
>> +#define CONDLEU		COND (0x4)
>> +#define CONDCS		COND (0x5)
>> +#define CONDNEG		COND (0x6)
>> +#define CONDVC		COND (0x7)
>> +#define CONDA		COND (0x8)
>> +#define CONDNE		COND (0x9)
>> +#define CONDG		COND (0xa)
>> +#define CONDGE		COND (0xb)
>> +#define CONDGU		COND (0xc)
>> +#define CONDCC		COND (0xd)
>> +#define CONDPOS		COND (0xe)
>> +#define CONDVS		COND (0xf)
> 
> The added space between COND and (0x..) looks strange to me.

Sorry, too must binutils hacking lately, I'll fix this.

>> +} while (0)
>> +
>> +	/* Emit
>> +	 *
>> +	 * 	OP	r_A, r_X, r_A
>> +	 */
> My vim marks the mixed spaces/tabs before OP with red.

I've fixed up all of these cases, thanks.

>> +} while(0)
>           ^
> Missing space. Repeats in the following macros.

And I've fixed these too.

>> #define emit_read_y(REG)        *prog++ = RD_Y | RD(REG);
>> #define emit_write_y(REG)       *prog++ = WR_Y | IMMED | RS1(REG) | S13(0);
> Mixed spaces and tabs, (The above is pasted).

Fixed, and erroneous trailing semicolon removed.

>> +#ifdef CONFIG_SPARC32
>> +					emit_branch(BE, t_offset + 20);
>> +#else
>> +					emit_branch(BE, t_offset + 8);
>> +#endif
> 
> What are these magic 8 and 20?

I've added a huge comment explaining the branch offset calculations.

Actually this was the hardest area to understand in the x86 JIT :)

--------------------
net: filter: Fix some more small issues in sparc JIT.

Fix mixed space and tabs.

Put bpf_jit_load_*[] externs into bpf_jit.h

"while(0)" --> "while (0)"
"COND (X)" --> "COND(X)"
Document branch offset calculations, and bpf_error's return
sequence.

Document the reason we need to emit three nops between the
%y register write and the divide instruction.

Remove erroneous trailing semicolons from emit_read_y() and
emit_write_y().

Based upon feedback from Sam Ravnborg.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 arch/sparc/net/bpf_jit.h      |   15 ++++++
 arch/sparc/net/bpf_jit_asm.S  |    6 +++
 arch/sparc/net/bpf_jit_comp.c |  107 ++++++++++++++++++++++++-----------------
 3 files changed, 84 insertions(+), 44 deletions(-)

diff --git a/arch/sparc/net/bpf_jit.h b/arch/sparc/net/bpf_jit.h
index 05175be..33d6b37 100644
--- a/arch/sparc/net/bpf_jit.h
+++ b/arch/sparc/net/bpf_jit.h
@@ -38,6 +38,21 @@
 #define r_TMP		G1
 #define r_TMP2		G2
 #define r_OFF		G3
+
+/* assembly code in arch/sparc/net/bpf_jit_asm.S */
+extern u32 bpf_jit_load_word[];
+extern u32 bpf_jit_load_half[];
+extern u32 bpf_jit_load_byte[];
+extern u32 bpf_jit_load_byte_msh[];
+extern u32 bpf_jit_load_word_positive_offset[];
+extern u32 bpf_jit_load_half_positive_offset[];
+extern u32 bpf_jit_load_byte_positive_offset[];
+extern u32 bpf_jit_load_byte_msh_positive_offset[];
+extern u32 bpf_jit_load_word_negative_offset[];
+extern u32 bpf_jit_load_half_negative_offset[];
+extern u32 bpf_jit_load_byte_negative_offset[];
+extern u32 bpf_jit_load_byte_msh_negative_offset[];
+
 #else
 #define r_SKB		%o0
 #define r_A		%o1
diff --git a/arch/sparc/net/bpf_jit_asm.S b/arch/sparc/net/bpf_jit_asm.S
index 46d8f59..9d016c7 100644
--- a/arch/sparc/net/bpf_jit_asm.S
+++ b/arch/sparc/net/bpf_jit_asm.S
@@ -195,5 +195,11 @@ bpf_jit_load_byte_msh_negative_offset:
 	 sll	r_OFF, 2, r_X
 
 bpf_error:
+	/* Make the JIT program return zero.  The JIT epilogue
+	 * stores away the original %o7 into r_saved_O7.  The
+	 * normal leaf function return is to use "retl" which
+	 * would evalute to "jmpl %o7 + 8, %g0" but we want to
+	 * use the saved value thus the sequence you see here.
+	 */
 	jmpl	r_saved_O7 + 8, %g0
 	 clr	%o0
diff --git a/arch/sparc/net/bpf_jit_comp.c b/arch/sparc/net/bpf_jit_comp.c
index ebc8980..2314eeb 100644
--- a/arch/sparc/net/bpf_jit_comp.c
+++ b/arch/sparc/net/bpf_jit_comp.c
@@ -11,20 +11,6 @@
 
 int bpf_jit_enable __read_mostly;
 
-/* assembly code in arch/sparc/net/bpf_jit_asm.S */
-extern u32 bpf_jit_load_word[];
-extern u32 bpf_jit_load_half[];
-extern u32 bpf_jit_load_byte[];
-extern u32 bpf_jit_load_byte_msh[];
-extern u32 bpf_jit_load_word_positive_offset[];
-extern u32 bpf_jit_load_half_positive_offset[];
-extern u32 bpf_jit_load_byte_positive_offset[];
-extern u32 bpf_jit_load_byte_msh_positive_offset[];
-extern u32 bpf_jit_load_word_negative_offset[];
-extern u32 bpf_jit_load_half_negative_offset[];
-extern u32 bpf_jit_load_byte_negative_offset[];
-extern u32 bpf_jit_load_byte_msh_negative_offset[];
-
 static inline bool is_simm13(unsigned int value)
 {
 	return value + 0x1000 < 0x2000;
@@ -65,22 +51,22 @@ static void bpf_flush_icache(void *start_, void *end_)
 #define F2(X, Y)	(OP(X) | OP2(Y))
 #define F3(X, Y)	(OP(X) | OP3(Y))
 
-#define CONDN		COND (0x0)
-#define CONDE		COND (0x1)
-#define CONDLE		COND (0x2)
-#define CONDL		COND (0x3)
-#define CONDLEU		COND (0x4)
-#define CONDCS		COND (0x5)
-#define CONDNEG		COND (0x6)
-#define CONDVC		COND (0x7)
-#define CONDA		COND (0x8)
-#define CONDNE		COND (0x9)
-#define CONDG		COND (0xa)
-#define CONDGE		COND (0xb)
-#define CONDGU		COND (0xc)
-#define CONDCC		COND (0xd)
-#define CONDPOS		COND (0xe)
-#define CONDVS		COND (0xf)
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
 
 #define CONDGEU		CONDCC
 #define CONDLU		CONDCS
@@ -172,7 +158,7 @@ do {	/* sethi %hi(K), REG */					\
 
 	/* Emit
 	 *
-	 * 	OP	r_A, r_X, r_A
+	 *	OP	r_A, r_X, r_A
 	 */
 #define emit_alu_X(OPCODE)					\
 do {								\
@@ -195,7 +181,7 @@ do {								\
 	 * is zero.
 	 */
 #define emit_alu_K(OPCODE, K)					\
-do {			   					\
+do {								\
 	if (K) {						\
 		unsigned int _insn = OPCODE;			\
 		_insn |= RS1(r_A) | RD(r_A);			\
@@ -204,7 +190,7 @@ do {			   					\
 		} else {					\
 			emit_set_const(K, r_TMP);		\
 			*prog++ = _insn | RS2(r_TMP);		\
-		}		  	  			\
+		}						\
 	}							\
 } while (0)
 
@@ -222,37 +208,37 @@ do {									\
 do {	unsigned int _off = offsetof(STRUCT, FIELD);			\
 	BUILD_BUG_ON(FIELD_SIZEOF(STRUCT, FIELD) != sizeof(void *));	\
 	*prog++ = LDPTRI | RS1(BASE) | S13(_off) | RD(DEST);		\
-} while(0)
+} while (0)
 
 #define emit_load32(BASE, STRUCT, FIELD, DEST)				\
 do {	unsigned int _off = offsetof(STRUCT, FIELD);			\
 	BUILD_BUG_ON(FIELD_SIZEOF(STRUCT, FIELD) != sizeof(u32));	\
 	*prog++ = LD32I | RS1(BASE) | S13(_off) | RD(DEST);		\
-} while(0)
+} while (0)
 
 #define emit_load16(BASE, STRUCT, FIELD, DEST)				\
 do {	unsigned int _off = offsetof(STRUCT, FIELD);			\
 	BUILD_BUG_ON(FIELD_SIZEOF(STRUCT, FIELD) != sizeof(u16));	\
 	*prog++ = LD16I | RS1(BASE) | S13(_off) | RD(DEST);		\
-} while(0)
+} while (0)
 
 #define __emit_load8(BASE, STRUCT, FIELD, DEST)				\
 do {	unsigned int _off = offsetof(STRUCT, FIELD);			\
 	*prog++ = LD8I | RS1(BASE) | S13(_off) | RD(DEST);		\
-} while(0)
+} while (0)
 
 #define emit_load8(BASE, STRUCT, FIELD, DEST)				\
 do {	BUILD_BUG_ON(FIELD_SIZEOF(STRUCT, FIELD) != sizeof(u8));	\
 	__emit_load8(BASE, STRUCT, FIELD, DEST);			\
-} while(0)
+} while (0)
 
 #define emit_ldmem(OFF, DEST)					\
 do {	*prog++ = LD32I | RS1(FP) | S13(-(OFF)) | RD(DEST);	\
-} while(0)
+} while (0)
 
 #define emit_stmem(OFF, SRC)					\
 do {	*prog++ = LD32I | RS1(FP) | S13(-(OFF)) | RD(SRC);	\
-} while(0)
+} while (0)
 
 #define cpu_off		offsetof(struct thread_info, cpu)
 
@@ -292,16 +278,16 @@ do {	void *_here = image + addrs[i] - 8;		\
 #define emit_branch(BR_OPC, DEST)			\
 do {	unsigned int _here = addrs[i] - 8;		\
 	*prog++ = BR_OPC | WDISP22((DEST) - _here);	\
-} while(0)
+} while (0)
 
 #define emit_branch_off(BR_OPC, OFF)			\
 do {	*prog++ = BR_OPC | WDISP22(OFF);		\
-} while(0)
+} while (0)
 
 #define emit_jump(DEST)		emit_branch(BA, DEST)
 
-#define emit_read_y(REG) 	*prog++ = RD_Y | RD(REG);
-#define emit_write_y(REG) 	*prog++ = WR_Y | IMMED | RS1(REG) | S13(0);
+#define emit_read_y(REG)	*prog++ = RD_Y | RD(REG)
+#define emit_write_y(REG)	*prog++ = WR_Y | IMMED | RS1(REG) | S13(0)
 
 #define emit_cmp(R1, R2) \
 	*prog++ = (SUBCC | RS1(R1) | RS2(R2) | RD(G0))
@@ -333,6 +319,35 @@ do {	*prog++ = BR_OPC | WDISP22(OFF);		\
 #define emit_release_stack(SZ) \
 	*prog++ = (ADD | IMMED | RS1(SP) | S13(SZ) | RD(SP))
 
+/* A note about branch offset calculations.  The addrs[] array,
+ * indexed by BPF instruction, records the address after all the
+ * sparc instructions emitted for that BPF instruction.
+ *
+ * The most common case is to emit a branch at the end of such
+ * a code sequence.  So this would be two instructions, the
+ * branch and it's delay slot.
+ *
+ * Therefore by default the branch emitters calculate the branch
+ * offset field as:
+ *
+ *	destination - (addrs[i] - 8)
+ *
+ * This "addrs[i] - 8" is the address of the branch itself or
+ * what "." would be in assembler notation.  The "8" part is
+ * how we take into consideration the branch and it's delay
+ * slot mentioned above.
+ *
+ * Sometimes we need to emit a branch earlier in the code
+ * sequence.  And in these situations we adjust "destination"
+ * to accomodate this difference.  For example, if we needed
+ * to emit a branch (and it's delay slot) right before the
+ * final instruction emitted for a BPF opcode, we'd use
+ * "destination + 4" instead of just plain "destination" above.
+ *
+ * This is why you see all of these funny emit_branch() and
+ * emit_jump() calls with adjusted offsets.
+ */
+
 void bpf_jit_compile(struct sk_filter *fp)
 {
 	unsigned int cleanup_addr, proglen, oldproglen = 0;
@@ -493,6 +508,10 @@ void bpf_jit_compile(struct sk_filter *fp)
 				}
 				emit_write_y(G0);
 #ifdef CONFIG_SPARC32
+				/* The Sparc v8 architecture requires
+				 * three instructions between a %y
+				 * register write and the first use.
+				 */
 				emit_nop();
 				emit_nop();
 				emit_nop();
-- 
1.7.10
