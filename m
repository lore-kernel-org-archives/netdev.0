From: Sandipan Das <sandipan@linux.vnet.ibm.com>
Subject: [PATCH 1/1] bpf: take advantage of stack_depth tracking in powerpc JIT
Date: Sat,  2 Sep 2017 00:23:01 +0530
Message-ID: <20170901185301.17978-1-sandipan@linux.vnet.ibm.com>
Cc: naveen.n.rao@linux.vnet.ibm.com, daniel@iogearbox.net, ast@fb.com,
        netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: mpe@ellerman.id.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:41320 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752355AbdIASxQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 14:53:16 -0400
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v81IoGef126929
        for <netdev@vger.kernel.org>; Fri, 1 Sep 2017 14:53:15 -0400
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com [202.81.31.145])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2cq9gb5yeh-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2017 14:53:15 -0400
Received: from localhost
        by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <sandipan@linux.vnet.ibm.com>;
        Sat, 2 Sep 2017 04:53:12 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
        by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v81Ir8if24183026
        for <netdev@vger.kernel.org>; Sat, 2 Sep 2017 04:53:08 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
        by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v81Ir0ID029405
        for <netdev@vger.kernel.org>; Sat, 2 Sep 2017 04:53:00 +1000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Take advantage of stack_depth tracking, originally introduced for
x64, in powerpc JIT as well. Round up allocated stack by 16 bytes
to make sure it stays aligned for functions called from JITed bpf
program.

Signed-off-by: Sandipan Das <sandipan@linux.vnet.ibm.com>
---
 arch/powerpc/net/bpf_jit64.h      |  7 ++++---
 arch/powerpc/net/bpf_jit_comp64.c | 16 ++++++++++------
 2 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/arch/powerpc/net/bpf_jit64.h b/arch/powerpc/net/bpf_jit64.h
index 62fa7589db2b..8bdef7ed28a8 100644
--- a/arch/powerpc/net/bpf_jit64.h
+++ b/arch/powerpc/net/bpf_jit64.h
@@ -23,7 +23,7 @@
  *		[   nv gpr save area	] 8*8		|
  *		[    tail_call_cnt	] 8		|
  *		[    local_tmp_var	] 8		|
- * fp (r31) -->	[   ebpf stack space	] 512		|
+ * fp (r31) -->	[   ebpf stack space	] upto 512	|
  *		[     frame header	] 32/112	|
  * sp (r1) --->	[    stack pointer	] --------------
  */
@@ -32,8 +32,8 @@
 #define BPF_PPC_STACK_SAVE	(8*8)
 /* for bpf JIT code internal usage */
 #define BPF_PPC_STACK_LOCALS	16
-/* Ensure this is quadword aligned */
-#define BPF_PPC_STACKFRAME	(STACK_FRAME_MIN_SIZE + MAX_BPF_STACK + \
+/* stack frame excluding BPF stack, ensure this is quadword aligned */
+#define BPF_PPC_STACKFRAME	(STACK_FRAME_MIN_SIZE + \
 				 BPF_PPC_STACK_LOCALS + BPF_PPC_STACK_SAVE)
 
 #ifndef __ASSEMBLY__
@@ -103,6 +103,7 @@ struct codegen_context {
 	 */
 	unsigned int seen;
 	unsigned int idx;
+	unsigned int stack_size;
 };
 
 #endif /* !__ASSEMBLY__ */
diff --git a/arch/powerpc/net/bpf_jit_comp64.c b/arch/powerpc/net/bpf_jit_comp64.c
index 6ba5d253e857..a01362c88f6a 100644
--- a/arch/powerpc/net/bpf_jit_comp64.c
+++ b/arch/powerpc/net/bpf_jit_comp64.c
@@ -69,7 +69,7 @@ static inline bool bpf_has_stack_frame(struct codegen_context *ctx)
 static int bpf_jit_stack_local(struct codegen_context *ctx)
 {
 	if (bpf_has_stack_frame(ctx))
-		return STACK_FRAME_MIN_SIZE + MAX_BPF_STACK;
+		return STACK_FRAME_MIN_SIZE + ctx->stack_size;
 	else
 		return -(BPF_PPC_STACK_SAVE + 16);
 }
@@ -82,8 +82,9 @@ static int bpf_jit_stack_tailcallcnt(struct codegen_context *ctx)
 static int bpf_jit_stack_offsetof(struct codegen_context *ctx, int reg)
 {
 	if (reg >= BPF_PPC_NVR_MIN && reg < 32)
-		return (bpf_has_stack_frame(ctx) ? BPF_PPC_STACKFRAME : 0)
-							- (8 * (32 - reg));
+		return (bpf_has_stack_frame(ctx) ?
+			(BPF_PPC_STACKFRAME + ctx->stack_size) : 0)
+				- (8 * (32 - reg));
 
 	pr_err("BPF JIT is asking about unknown registers");
 	BUG();
@@ -134,7 +135,7 @@ static void bpf_jit_build_prologue(u32 *image, struct codegen_context *ctx)
 			PPC_BPF_STL(0, 1, PPC_LR_STKOFF);
 		}
 
-		PPC_BPF_STLU(1, 1, -BPF_PPC_STACKFRAME);
+		PPC_BPF_STLU(1, 1, -(BPF_PPC_STACKFRAME + ctx->stack_size));
 	}
 
 	/*
@@ -161,7 +162,7 @@ static void bpf_jit_build_prologue(u32 *image, struct codegen_context *ctx)
 	/* Setup frame pointer to point to the bpf stack area */
 	if (bpf_is_seen_register(ctx, BPF_REG_FP))
 		PPC_ADDI(b2p[BPF_REG_FP], 1,
-				STACK_FRAME_MIN_SIZE + MAX_BPF_STACK);
+				STACK_FRAME_MIN_SIZE + ctx->stack_size);
 }
 
 static void bpf_jit_emit_common_epilogue(u32 *image, struct codegen_context *ctx)
@@ -183,7 +184,7 @@ static void bpf_jit_emit_common_epilogue(u32 *image, struct codegen_context *ctx
 
 	/* Tear down our stack frame */
 	if (bpf_has_stack_frame(ctx)) {
-		PPC_ADDI(1, 1, BPF_PPC_STACKFRAME);
+		PPC_ADDI(1, 1, BPF_PPC_STACKFRAME + ctx->stack_size);
 		if (ctx->seen & SEEN_FUNC) {
 			PPC_BPF_LL(0, 1, PPC_LR_STKOFF);
 			PPC_MTLR(0);
@@ -993,6 +994,9 @@ struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *fp)
 
 	memset(&cgctx, 0, sizeof(struct codegen_context));
 
+	/* Make sure that the stack is quadword aligned. */
+	cgctx.stack_size = round_up(fp->aux->stack_depth, 16);
+
 	/* Scouting faux-generate pass 0 */
 	if (bpf_jit_build_body(fp, 0, &cgctx, addrs)) {
 		/* We hit something illegal or unsupported. */
-- 
2.13.5
