From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/5] bpf: move clearing of A/X into classic to eBPF migration prologue
Date: Thu, 17 Dec 2015 23:51:54 +0100
Message-ID: <59015f2db8fe71c235fe2c19714448601136d5f9.1450391511.git.daniel@iogearbox.net>
References: <cover.1450391511.git.daniel@iogearbox.net>
Cc: ast@kernel.org, holzheu@linux.vnet.ibm.com, zlim.lnx@gmail.com,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>,
	Yang Shi <yang.shi@linaro.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:53875 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753133AbbLQWwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 17:52:03 -0500
In-Reply-To: <cover.1450391511.git.daniel@iogearbox.net>
In-Reply-To: <cover.1450391511.git.daniel@iogearbox.net>
References: <cover.1450391511.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Back in the days where eBPF (or back then "internal BPF" ;->) was not
exposed to user space, and only the classic BPF programs internally
translated into eBPF programs, we missed the fact that for classic BPF
A and X needed to be cleared. It was fixed back then via 83d5b7ef99c9
("net: filter: initialize A and X registers"), and thus classic BPF
specifics were added to the eBPF interpreter core to work around it.

This added some confusion for JIT developers later on that take the
eBPF interpreter code as an example for deriving their JIT. F.e. in
f75298f5c3fe ("s390/bpf: clear correct BPF accumulator register"), at
least X could leak stack memory. Furthermore, since this is only needed
for classic BPF translations and not for eBPF (verifier takes care
that read access to regs cannot be done uninitialized), more complexity
is added to JITs as they need to determine whether they deal with
migrations or native eBPF where they can just omit clearing A/X in
their prologue and thus reduce image size a bit, see f.e. cde66c2d88da
("s390/bpf: Only clear A and X for converted BPF programs"). In other
cases (x86, arm64), A and X is being cleared in the prologue also for
eBPF case, which is unnecessary.

Lets move this into the BPF migration in bpf_convert_filter() where it
actually belongs as long as the number of eBPF JITs are still few. It
can thus be done generically; allowing us to remove the quirk from
__bpf_prog_run() and to slightly reduce JIT image size in case of eBPF,
while reducing code duplication on this matter in current(/future) eBPF
JITs.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
Reviewed-by: Michael Holzheu <holzheu@linux.vnet.ibm.com>
Tested-by: Michael Holzheu <holzheu@linux.vnet.ibm.com>
Cc: Zi Shen Lim <zlim.lnx@gmail.com>
Cc: Yang Shi <yang.shi@linaro.org>
---
 arch/arm64/net/bpf_jit_comp.c |  6 ------
 arch/s390/net/bpf_jit_comp.c  | 13 ++-----------
 arch/x86/net/bpf_jit_comp.c   | 14 +++++++++-----
 kernel/bpf/core.c             |  4 ----
 net/core/filter.c             | 19 ++++++++++++++++---
 5 files changed, 27 insertions(+), 29 deletions(-)

diff --git a/arch/arm64/net/bpf_jit_comp.c b/arch/arm64/net/bpf_jit_comp.c
index b162ad7..7658612 100644
--- a/arch/arm64/net/bpf_jit_comp.c
+++ b/arch/arm64/net/bpf_jit_comp.c
@@ -152,8 +152,6 @@ static void build_prologue(struct jit_ctx *ctx)
 	const u8 r8 = bpf2a64[BPF_REG_8];
 	const u8 r9 = bpf2a64[BPF_REG_9];
 	const u8 fp = bpf2a64[BPF_REG_FP];
-	const u8 ra = bpf2a64[BPF_REG_A];
-	const u8 rx = bpf2a64[BPF_REG_X];
 	const u8 tmp1 = bpf2a64[TMP_REG_1];
 	const u8 tmp2 = bpf2a64[TMP_REG_2];
 
@@ -200,10 +198,6 @@ static void build_prologue(struct jit_ctx *ctx)
 
 	/* Set up function call stack */
 	emit(A64_SUB_I(1, A64_SP, A64_SP, STACK_SIZE), ctx);
-
-	/* Clear registers A and X */
-	emit_a64_mov_i64(ra, 0, ctx);
-	emit_a64_mov_i64(rx, 0, ctx);
 }
 
 static void build_epilogue(struct jit_ctx *ctx)
diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
index 9a0c4c2..3c0bfc1 100644
--- a/arch/s390/net/bpf_jit_comp.c
+++ b/arch/s390/net/bpf_jit_comp.c
@@ -408,7 +408,7 @@ static void emit_load_skb_data_hlen(struct bpf_jit *jit)
  * Save registers and create stack frame if necessary.
  * See stack frame layout desription in "bpf_jit.h"!
  */
-static void bpf_jit_prologue(struct bpf_jit *jit, bool is_classic)
+static void bpf_jit_prologue(struct bpf_jit *jit)
 {
 	if (jit->seen & SEEN_TAIL_CALL) {
 		/* xc STK_OFF_TCCNT(4,%r15),STK_OFF_TCCNT(%r15) */
@@ -448,15 +448,6 @@ static void bpf_jit_prologue(struct bpf_jit *jit, bool is_classic)
 		/* stg %b1,ST_OFF_SKBP(%r0,%r15) */
 		EMIT6_DISP_LH(0xe3000000, 0x0024, REG_W1, REG_0, REG_15,
 			      STK_OFF_SKBP);
-	/* Clear A (%b0) and X (%b7) registers for converted BPF programs */
-	if (is_classic) {
-		if (REG_SEEN(BPF_REG_A))
-			/* lghi %ba,0 */
-			EMIT4_IMM(0xa7090000, BPF_REG_A, 0);
-		if (REG_SEEN(BPF_REG_X))
-			/* lghi %bx,0 */
-			EMIT4_IMM(0xa7090000, BPF_REG_X, 0);
-	}
 }
 
 /*
@@ -1245,7 +1236,7 @@ static int bpf_jit_prog(struct bpf_jit *jit, struct bpf_prog *fp)
 	jit->lit = jit->lit_start;
 	jit->prg = 0;
 
-	bpf_jit_prologue(jit, bpf_prog_was_classic(fp));
+	bpf_jit_prologue(jit);
 	for (i = 0; i < fp->len; i += insn_count) {
 		insn_count = bpf_jit_insn(jit, fp, i);
 		if (insn_count < 0)
diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 7599197..c080e81 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -193,7 +193,7 @@ struct jit_context {
 	 32 /* space for rbx, r13, r14, r15 */ + \
 	 8 /* space for skb_copy_bits() buffer */)
 
-#define PROLOGUE_SIZE 51
+#define PROLOGUE_SIZE 48
 
 /* emit x64 prologue code for BPF program and check it's size.
  * bpf_tail_call helper will skip it while jumping into another program
@@ -229,11 +229,15 @@ static void emit_prologue(u8 **pprog)
 	/* mov qword ptr [rbp-X],r15 */
 	EMIT3_off32(0x4C, 0x89, 0xBD, -STACKSIZE + 24);
 
-	/* clear A and X registers */
-	EMIT2(0x31, 0xc0); /* xor eax, eax */
-	EMIT3(0x4D, 0x31, 0xED); /* xor r13, r13 */
+	/* Clear the tail call counter (tail_call_cnt): for eBPF tail calls
+	 * we need to reset the counter to 0. It's done in two instructions,
+	 * resetting rax register to 0 (xor on eax gets 0 extended), and
+	 * moving it to the counter location.
+	 */
 
-	/* clear tail_cnt: mov qword ptr [rbp-X], rax */
+	/* xor eax, eax */
+	EMIT2(0x31, 0xc0);
+	/* mov qword ptr [rbp-X], rax */
 	EMIT3_off32(0x48, 0x89, 0x85, -STACKSIZE + 32);
 
 	BUILD_BUG_ON(cnt != PROLOGUE_SIZE);
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 334b1bd..972d9a8 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -306,10 +306,6 @@ static unsigned int __bpf_prog_run(void *ctx, const struct bpf_insn *insn)
 	FP = (u64) (unsigned long) &stack[ARRAY_SIZE(stack)];
 	ARG1 = (u64) (unsigned long) ctx;
 
-	/* Registers used in classic BPF programs need to be reset first. */
-	regs[BPF_REG_A] = 0;
-	regs[BPF_REG_X] = 0;
-
 select_insn:
 	goto *jumptable[insn->code];
 
diff --git a/net/core/filter.c b/net/core/filter.c
index 34bf6fc..b513eb8 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -381,9 +381,22 @@ do_pass:
 	new_insn = new_prog;
 	fp = prog;
 
-	if (new_insn)
-		*new_insn = BPF_MOV64_REG(BPF_REG_CTX, BPF_REG_ARG1);
-	new_insn++;
+	/* Classic BPF related prologue emission. */
+	if (new_insn) {
+		/* Classic BPF expects A and X to be reset first. These need
+		 * to be guaranteed to be the first two instructions.
+		 */
+		*new_insn++ = BPF_ALU64_REG(BPF_XOR, BPF_REG_A, BPF_REG_A);
+		*new_insn++ = BPF_ALU64_REG(BPF_XOR, BPF_REG_X, BPF_REG_X);
+
+		/* All programs must keep CTX in callee saved BPF_REG_CTX.
+		 * In eBPF case it's done by the compiler, here we need to
+		 * do this ourself. Initial CTX is present in BPF_REG_ARG1.
+		 */
+		*new_insn++ = BPF_MOV64_REG(BPF_REG_CTX, BPF_REG_ARG1);
+	} else {
+		new_insn += 3;
+	}
 
 	for (i = 0; i < len; fp++, i++) {
 		struct bpf_insn tmp_insns[6] = { };
-- 
1.9.3
