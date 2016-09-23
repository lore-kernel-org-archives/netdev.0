From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Subject: [PATCH 1/3] bpf powerpc: introduce accessors for using the tmp local stack space
Date: Sat, 24 Sep 2016 02:05:00 +0530
Message-ID: <40b65ab2bb3a48837ab047a70887de3ccd70c56b.1474661927.git.naveen.n.rao@linux.vnet.ibm.com>
Cc: "Alexei Starovoitov" <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S. Miller" <davem@davemloft.net>,
        "Ananth N Mavinakayanahalli" <ananth@in.ibm.com>
To: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        netdev@vger.kernel.org, "Michael Ellerman" <mpe@ellerman.id.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

While at it, ensure that the location of the local save area is
consistent whether or not we setup our own stackframe. This property is
utilised in the next patch that adds support for tail calls.

Signed-off-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>
---
 arch/powerpc/net/bpf_jit64.h      | 16 +++++---
 arch/powerpc/net/bpf_jit_comp64.c | 79 ++++++++++++++++++++++-----------------
 2 files changed, 55 insertions(+), 40 deletions(-)

diff --git a/arch/powerpc/net/bpf_jit64.h b/arch/powerpc/net/bpf_jit64.h
index 5046d6f..a1645d7 100644
--- a/arch/powerpc/net/bpf_jit64.h
+++ b/arch/powerpc/net/bpf_jit64.h
@@ -16,22 +16,25 @@
 
 /*
  * Stack layout:
+ * Ensure the top half (upto local_tmp_var) stays consistent
+ * with our redzone usage.
  *
  *		[	prev sp		] <-------------
  *		[   nv gpr save area	] 8*8		|
+ *		[    tail_call_cnt	] 8		|
+ *		[    local_tmp_var	] 8		|
  * fp (r31) -->	[   ebpf stack space	] 512		|
- *		[  local/tmp var space	] 16		|
  *		[     frame header	] 32/112	|
  * sp (r1) --->	[    stack pointer	] --------------
  */
 
-/* for bpf JIT code internal usage */
-#define BPF_PPC_STACK_LOCALS	16
 /* for gpr non volatile registers BPG_REG_6 to 10, plus skb cache registers */
 #define BPF_PPC_STACK_SAVE	(8*8)
+/* for bpf JIT code internal usage */
+#define BPF_PPC_STACK_LOCALS	16
 /* Ensure this is quadword aligned */
-#define BPF_PPC_STACKFRAME	(STACK_FRAME_MIN_SIZE + BPF_PPC_STACK_LOCALS + \
-				 MAX_BPF_STACK + BPF_PPC_STACK_SAVE)
+#define BPF_PPC_STACKFRAME	(STACK_FRAME_MIN_SIZE + MAX_BPF_STACK + \
+				 BPF_PPC_STACK_LOCALS + BPF_PPC_STACK_SAVE)
 
 #ifndef __ASSEMBLY__
 
@@ -65,6 +68,9 @@ static const int b2p[] = {
 	[TMP_REG_2] = 10
 };
 
+/* PPC NVR range -- update this if we ever use NVRs below r24 */
+#define BPF_PPC_NVR_MIN		24
+
 /* Assembly helpers */
 #define DECLARE_LOAD_FUNC(func)	u64 func(u64 r3, u64 r4);			\
 				u64 func##_negative_offset(u64 r3, u64 r4);	\
diff --git a/arch/powerpc/net/bpf_jit_comp64.c b/arch/powerpc/net/bpf_jit_comp64.c
index 6073b78..5f8c91f 100644
--- a/arch/powerpc/net/bpf_jit_comp64.c
+++ b/arch/powerpc/net/bpf_jit_comp64.c
@@ -58,6 +58,35 @@ static inline bool bpf_has_stack_frame(struct codegen_context *ctx)
 	return ctx->seen & SEEN_FUNC || bpf_is_seen_register(ctx, BPF_REG_FP);
 }
 
+/*
+ * When not setting up our own stackframe, the redzone usage is:
+ *
+ *		[	prev sp		] <-------------
+ *		[	  ...       	] 		|
+ * sp (r1) --->	[    stack pointer	] --------------
+ *		[   nv gpr save area	] 8*8
+ *		[    tail_call_cnt	] 8
+ *		[    local_tmp_var	] 8
+ *		[   unused red zone	] 208 bytes protected
+ */
+static int bpf_jit_stack_local(struct codegen_context *ctx)
+{
+	if (bpf_has_stack_frame(ctx))
+		return STACK_FRAME_MIN_SIZE + MAX_BPF_STACK;
+	else
+		return -(BPF_PPC_STACK_SAVE + 16);
+}
+
+static int bpf_jit_stack_offsetof(struct codegen_context *ctx, int reg)
+{
+	if (reg >= BPF_PPC_NVR_MIN && reg < 32)
+		return (bpf_has_stack_frame(ctx) ? BPF_PPC_STACKFRAME : 0)
+							- (8 * (32 - reg));
+
+	pr_err("BPF JIT is asking about unknown registers");
+	BUG();
+}
+
 static void bpf_jit_emit_skb_loads(u32 *image, struct codegen_context *ctx)
 {
 	/*
@@ -100,9 +129,8 @@ static void bpf_jit_emit_func_call(u32 *image, struct codegen_context *ctx, u64
 static void bpf_jit_build_prologue(u32 *image, struct codegen_context *ctx)
 {
 	int i;
-	bool new_stack_frame = bpf_has_stack_frame(ctx);
 
-	if (new_stack_frame) {
+	if (bpf_has_stack_frame(ctx)) {
 		/*
 		 * We need a stack frame, but we don't necessarily need to
 		 * save/restore LR unless we call other functions
@@ -122,9 +150,7 @@ static void bpf_jit_build_prologue(u32 *image, struct codegen_context *ctx)
 	 */
 	for (i = BPF_REG_6; i <= BPF_REG_10; i++)
 		if (bpf_is_seen_register(ctx, i))
-			PPC_BPF_STL(b2p[i], 1,
-				(new_stack_frame ? BPF_PPC_STACKFRAME : 0) -
-					(8 * (32 - b2p[i])));
+			PPC_BPF_STL(b2p[i], 1, bpf_jit_stack_offsetof(ctx, b2p[i]));
 
 	/*
 	 * Save additional non-volatile regs if we cache skb
@@ -132,22 +158,21 @@ static void bpf_jit_build_prologue(u32 *image, struct codegen_context *ctx)
 	 */
 	if (ctx->seen & SEEN_SKB) {
 		PPC_BPF_STL(b2p[SKB_HLEN_REG], 1,
-			BPF_PPC_STACKFRAME - (8 * (32 - b2p[SKB_HLEN_REG])));
+				bpf_jit_stack_offsetof(ctx, b2p[SKB_HLEN_REG]));
 		PPC_BPF_STL(b2p[SKB_DATA_REG], 1,
-			BPF_PPC_STACKFRAME - (8 * (32 - b2p[SKB_DATA_REG])));
+				bpf_jit_stack_offsetof(ctx, b2p[SKB_DATA_REG]));
 		bpf_jit_emit_skb_loads(image, ctx);
 	}
 
 	/* Setup frame pointer to point to the bpf stack area */
 	if (bpf_is_seen_register(ctx, BPF_REG_FP))
 		PPC_ADDI(b2p[BPF_REG_FP], 1,
-				BPF_PPC_STACKFRAME - BPF_PPC_STACK_SAVE);
+				STACK_FRAME_MIN_SIZE + MAX_BPF_STACK);
 }
 
 static void bpf_jit_build_epilogue(u32 *image, struct codegen_context *ctx)
 {
 	int i;
-	bool new_stack_frame = bpf_has_stack_frame(ctx);
 
 	/* Move result to r3 */
 	PPC_MR(3, b2p[BPF_REG_0]);
@@ -155,20 +180,18 @@ static void bpf_jit_build_epilogue(u32 *image, struct codegen_context *ctx)
 	/* Restore NVRs */
 	for (i = BPF_REG_6; i <= BPF_REG_10; i++)
 		if (bpf_is_seen_register(ctx, i))
-			PPC_BPF_LL(b2p[i], 1,
-				(new_stack_frame ? BPF_PPC_STACKFRAME : 0) -
-					(8 * (32 - b2p[i])));
+			PPC_BPF_LL(b2p[i], 1, bpf_jit_stack_offsetof(ctx, b2p[i]));
 
 	/* Restore non-volatile registers used for skb cache */
 	if (ctx->seen & SEEN_SKB) {
 		PPC_BPF_LL(b2p[SKB_HLEN_REG], 1,
-			BPF_PPC_STACKFRAME - (8 * (32 - b2p[SKB_HLEN_REG])));
+				bpf_jit_stack_offsetof(ctx, b2p[SKB_HLEN_REG]));
 		PPC_BPF_LL(b2p[SKB_DATA_REG], 1,
-			BPF_PPC_STACKFRAME - (8 * (32 - b2p[SKB_DATA_REG])));
+				bpf_jit_stack_offsetof(ctx, b2p[SKB_DATA_REG]));
 	}
 
 	/* Tear down our stack frame */
-	if (new_stack_frame) {
+	if (bpf_has_stack_frame(ctx)) {
 		PPC_ADDI(1, 1, BPF_PPC_STACKFRAME);
 		if (ctx->seen & SEEN_FUNC) {
 			PPC_BPF_LL(0, 1, PPC_LR_STKOFF);
@@ -200,7 +223,6 @@ static int bpf_jit_build_body(struct bpf_prog *fp, u32 *image,
 		u64 imm64;
 		u8 *func;
 		u32 true_cond;
-		int stack_local_off;
 
 		/*
 		 * addrs[] maps a BPF bytecode address into a real offset from
@@ -219,9 +241,9 @@ static int bpf_jit_build_body(struct bpf_prog *fp, u32 *image,
 		 * optimization but everything else should work without
 		 * any issues.
 		 */
-		if (dst_reg >= 24 && dst_reg <= 31)
+		if (dst_reg >= BPF_PPC_NVR_MIN && dst_reg < 32)
 			bpf_set_seen_register(ctx, insn[i].dst_reg);
-		if (src_reg >= 24 && src_reg <= 31)
+		if (src_reg >= BPF_PPC_NVR_MIN && src_reg < 32)
 			bpf_set_seen_register(ctx, insn[i].src_reg);
 
 		switch (code) {
@@ -490,25 +512,12 @@ bpf_alu32_trunc:
 				 * Way easier and faster(?) to store the value
 				 * into stack and then use ldbrx
 				 *
-				 * First, determine where in stack we can store
-				 * this:
-				 * - if we have allotted a stack frame, then we
-				 *   will utilize the area set aside by
-				 *   BPF_PPC_STACK_LOCALS
-				 * - else, we use the area beneath the NV GPR
-				 *   save area
-				 *
 				 * ctx->seen will be reliable in pass2, but
 				 * the instructions generated will remain the
 				 * same across all passes
 				 */
-				if (bpf_has_stack_frame(ctx))
-					stack_local_off = STACK_FRAME_MIN_SIZE;
-				else
-					stack_local_off = -(BPF_PPC_STACK_SAVE + 8);
-
-				PPC_STD(dst_reg, 1, stack_local_off);
-				PPC_ADDI(b2p[TMP_REG_1], 1, stack_local_off);
+				PPC_STD(dst_reg, 1, bpf_jit_stack_local(ctx));
+				PPC_ADDI(b2p[TMP_REG_1], 1, bpf_jit_stack_local(ctx));
 				PPC_LDBRX(dst_reg, 0, b2p[TMP_REG_1]);
 				break;
 			}
@@ -668,7 +677,7 @@ emit_clear:
 
 			/* Save skb pointer if we need to re-cache skb data */
 			if (bpf_helper_changes_skb_data(func))
-				PPC_BPF_STL(3, 1, STACK_FRAME_MIN_SIZE);
+				PPC_BPF_STL(3, 1, bpf_jit_stack_local(ctx));
 
 			bpf_jit_emit_func_call(image, ctx, (u64)func);
 
@@ -678,7 +687,7 @@ emit_clear:
 			/* refresh skb cache */
 			if (bpf_helper_changes_skb_data(func)) {
 				/* reload skb pointer to r3 */
-				PPC_BPF_LL(3, 1, STACK_FRAME_MIN_SIZE);
+				PPC_BPF_LL(3, 1, bpf_jit_stack_local(ctx));
 				bpf_jit_emit_skb_loads(image, ctx);
 			}
 			break;
-- 
2.9.3
