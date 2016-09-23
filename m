From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Subject: [PATCH 2/3] bpf powerpc: implement support for tail calls
Date: Sat, 24 Sep 2016 02:05:01 +0530
Message-ID: <c7c16b999694b2851705d79da939988e521bda3a.1474661927.git.naveen.n.rao@linux.vnet.ibm.com>
References: <40b65ab2bb3a48837ab047a70887de3ccd70c56b.1474661927.git.naveen.n.rao@linux.vnet.ibm.com>
Cc: "Alexei Starovoitov" <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S. Miller" <davem@davemloft.net>,
        "Ananth N Mavinakayanahalli" <ananth@in.ibm.com>
To: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        netdev@vger.kernel.org, "Michael Ellerman" <mpe@ellerman.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:34204 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1760443AbcIWUff (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 16:35:35 -0400
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8NKWpSU013693
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 16:35:34 -0400
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com [202.81.31.140])
        by mx0a-001b2d01.pphosted.com with ESMTP id 25mqb7rw6c-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 16:35:33 -0400
Received: from localhost
        by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <naveen.n.rao@linux.vnet.ibm.com>;
        Sat, 24 Sep 2016 06:35:31 +1000
In-Reply-To: <40b65ab2bb3a48837ab047a70887de3ccd70c56b.1474661927.git.naveen.n.rao@linux.vnet.ibm.com>
In-Reply-To: <40b65ab2bb3a48837ab047a70887de3ccd70c56b.1474661927.git.naveen.n.rao@linux.vnet.ibm.com>
References: <40b65ab2bb3a48837ab047a70887de3ccd70c56b.1474661927.git.naveen.n.rao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tail calls allow JIT'ed eBPF programs to call into other JIT'ed eBPF
programs. This can be achieved either by:
(1) retaining the stack setup by the first eBPF program and having all
subsequent eBPF programs re-using it, or,
(2) by unwinding/tearing down the stack and having each eBPF program
deal with its own stack as it sees fit.

To ensure that this does not create loops, there is a limit to how many
tail calls can be done (currently 32). This requires the JIT'ed code to
maintain a count of the number of tail calls done so far.

Approach (1) is simple, but requires every eBPF program to have (almost)
the same prologue/epilogue, regardless of whether they need it. This is
inefficient for small eBPF programs which may not sometimes need a
prologue at all. As such, to minimize impact of tail call
implementation, we use approach (2) here which needs each eBPF program
in the chain to use its own prologue/epilogue. This is not ideal when
many tail calls are involved and when all the eBPF programs in the chain
have similar prologue/epilogue. However, the impact is restricted to
programs that do tail calls. Individual eBPF programs are not affected.

We maintain the tail call count in a fixed location on the stack and
updated tail call count values are passed in through this. The very
first eBPF program in a chain sets this up to 0 (the first 2
instructions). Subsequent tail calls skip the first two eBPF JIT
instructions to maintain the count. For programs that don't do tail
calls themselves, the first two instructions are NOPs.

Signed-off-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/ppc-opcode.h |   2 +
 arch/powerpc/net/bpf_jit.h            |   2 +
 arch/powerpc/net/bpf_jit64.h          |   1 +
 arch/powerpc/net/bpf_jit_comp64.c     | 149 +++++++++++++++++++++++++++-------
 4 files changed, 126 insertions(+), 28 deletions(-)

diff --git a/arch/powerpc/include/asm/ppc-opcode.h b/arch/powerpc/include/asm/ppc-opcode.h
index 127ebf5..54ff8ce 100644
--- a/arch/powerpc/include/asm/ppc-opcode.h
+++ b/arch/powerpc/include/asm/ppc-opcode.h
@@ -236,6 +236,7 @@
 #define PPC_INST_STWU			0x94000000
 #define PPC_INST_MFLR			0x7c0802a6
 #define PPC_INST_MTLR			0x7c0803a6
+#define PPC_INST_MTCTR			0x7c0903a6
 #define PPC_INST_CMPWI			0x2c000000
 #define PPC_INST_CMPDI			0x2c200000
 #define PPC_INST_CMPW			0x7c000000
@@ -250,6 +251,7 @@
 #define PPC_INST_SUB			0x7c000050
 #define PPC_INST_BLR			0x4e800020
 #define PPC_INST_BLRL			0x4e800021
+#define PPC_INST_BCTR			0x4e800420
 #define PPC_INST_MULLD			0x7c0001d2
 #define PPC_INST_MULLW			0x7c0001d6
 #define PPC_INST_MULHWU			0x7c000016
diff --git a/arch/powerpc/net/bpf_jit.h b/arch/powerpc/net/bpf_jit.h
index d5301b6..89f7007 100644
--- a/arch/powerpc/net/bpf_jit.h
+++ b/arch/powerpc/net/bpf_jit.h
@@ -40,6 +40,8 @@
 #define PPC_BLR()		EMIT(PPC_INST_BLR)
 #define PPC_BLRL()		EMIT(PPC_INST_BLRL)
 #define PPC_MTLR(r)		EMIT(PPC_INST_MTLR | ___PPC_RT(r))
+#define PPC_BCTR()		EMIT(PPC_INST_BCTR)
+#define PPC_MTCTR(r)		EMIT(PPC_INST_MTCTR | ___PPC_RT(r))
 #define PPC_ADDI(d, a, i)	EMIT(PPC_INST_ADDI | ___PPC_RT(d) |	      \
 				     ___PPC_RA(a) | IMM_L(i))
 #define PPC_MR(d, a)		PPC_OR(d, a, a)
diff --git a/arch/powerpc/net/bpf_jit64.h b/arch/powerpc/net/bpf_jit64.h
index a1645d7..038e00b 100644
--- a/arch/powerpc/net/bpf_jit64.h
+++ b/arch/powerpc/net/bpf_jit64.h
@@ -88,6 +88,7 @@ DECLARE_LOAD_FUNC(sk_load_byte);
 #define SEEN_FUNC	0x1000 /* might call external helpers */
 #define SEEN_STACK	0x2000 /* uses BPF stack */
 #define SEEN_SKB	0x4000 /* uses sk_buff */
+#define SEEN_TAILCALL	0x8000 /* uses tail calls */
 
 struct codegen_context {
 	/*
diff --git a/arch/powerpc/net/bpf_jit_comp64.c b/arch/powerpc/net/bpf_jit_comp64.c
index 5f8c91f..3ec29d6 100644
--- a/arch/powerpc/net/bpf_jit_comp64.c
+++ b/arch/powerpc/net/bpf_jit_comp64.c
@@ -17,6 +17,7 @@
 #include <linux/filter.h>
 #include <linux/if_vlan.h>
 #include <asm/kprobes.h>
+#include <linux/bpf.h>
 
 #include "bpf_jit64.h"
 
@@ -77,6 +78,11 @@ static int bpf_jit_stack_local(struct codegen_context *ctx)
 		return -(BPF_PPC_STACK_SAVE + 16);
 }
 
+static int bpf_jit_stack_tailcallcnt(struct codegen_context *ctx)
+{
+	return bpf_jit_stack_local(ctx) + 8;
+}
+
 static int bpf_jit_stack_offsetof(struct codegen_context *ctx, int reg)
 {
 	if (reg >= BPF_PPC_NVR_MIN && reg < 32)
@@ -102,33 +108,25 @@ static void bpf_jit_emit_skb_loads(u32 *image, struct codegen_context *ctx)
 	PPC_BPF_LL(b2p[SKB_DATA_REG], 3, offsetof(struct sk_buff, data));
 }
 
-static void bpf_jit_emit_func_call(u32 *image, struct codegen_context *ctx, u64 func)
+static void bpf_jit_build_prologue(u32 *image, struct codegen_context *ctx)
 {
-#ifdef PPC64_ELF_ABI_v1
-	/* func points to the function descriptor */
-	PPC_LI64(b2p[TMP_REG_2], func);
-	/* Load actual entry point from function descriptor */
-	PPC_BPF_LL(b2p[TMP_REG_1], b2p[TMP_REG_2], 0);
-	/* ... and move it to LR */
-	PPC_MTLR(b2p[TMP_REG_1]);
+	int i;
+
 	/*
-	 * Load TOC from function descriptor at offset 8.
-	 * We can clobber r2 since we get called through a
-	 * function pointer (so caller will save/restore r2)
-	 * and since we don't use a TOC ourself.
+	 * Initialize tail_call_cnt if we do tail calls.
+	 * Otherwise, put in NOPs so that it can be skipped when we are
+	 * invoked through a tail call.
 	 */
-	PPC_BPF_LL(2, b2p[TMP_REG_2], 8);
-#else
-	/* We can clobber r12 */
-	PPC_FUNC_ADDR(12, func);
-	PPC_MTLR(12);
-#endif
-	PPC_BLRL();
-}
+	if (ctx->seen & SEEN_TAILCALL) {
+		PPC_LI(b2p[TMP_REG_1], 0);
+		/* this goes in the redzone */
+		PPC_BPF_STL(b2p[TMP_REG_1], 1, -(BPF_PPC_STACK_SAVE + 8));
+	} else {
+		PPC_NOP();
+		PPC_NOP();
+	}
 
-static void bpf_jit_build_prologue(u32 *image, struct codegen_context *ctx)
-{
-	int i;
+#define BPF_TAILCALL_PROLOGUE_SIZE	8
 
 	if (bpf_has_stack_frame(ctx)) {
 		/*
@@ -170,13 +168,10 @@ static void bpf_jit_build_prologue(u32 *image, struct codegen_context *ctx)
 				STACK_FRAME_MIN_SIZE + MAX_BPF_STACK);
 }
 
-static void bpf_jit_build_epilogue(u32 *image, struct codegen_context *ctx)
+static void bpf_jit_emit_common_epilogue(u32 *image, struct codegen_context *ctx)
 {
 	int i;
 
-	/* Move result to r3 */
-	PPC_MR(3, b2p[BPF_REG_0]);
-
 	/* Restore NVRs */
 	for (i = BPF_REG_6; i <= BPF_REG_10; i++)
 		if (bpf_is_seen_register(ctx, i))
@@ -198,10 +193,105 @@ static void bpf_jit_build_epilogue(u32 *image, struct codegen_context *ctx)
 			PPC_MTLR(0);
 		}
 	}
+}
+
+static void bpf_jit_build_epilogue(u32 *image, struct codegen_context *ctx)
+{
+	bpf_jit_emit_common_epilogue(image, ctx);
+
+	/* Move result to r3 */
+	PPC_MR(3, b2p[BPF_REG_0]);
 
 	PPC_BLR();
 }
 
+static void bpf_jit_emit_func_call(u32 *image, struct codegen_context *ctx, u64 func)
+{
+#ifdef PPC64_ELF_ABI_v1
+	/* func points to the function descriptor */
+	PPC_LI64(b2p[TMP_REG_2], func);
+	/* Load actual entry point from function descriptor */
+	PPC_BPF_LL(b2p[TMP_REG_1], b2p[TMP_REG_2], 0);
+	/* ... and move it to LR */
+	PPC_MTLR(b2p[TMP_REG_1]);
+	/*
+	 * Load TOC from function descriptor at offset 8.
+	 * We can clobber r2 since we get called through a
+	 * function pointer (so caller will save/restore r2)
+	 * and since we don't use a TOC ourself.
+	 */
+	PPC_BPF_LL(2, b2p[TMP_REG_2], 8);
+#else
+	/* We can clobber r12 */
+	PPC_FUNC_ADDR(12, func);
+	PPC_MTLR(12);
+#endif
+	PPC_BLRL();
+}
+
+static void bpf_jit_emit_tail_call(u32 *image, struct codegen_context *ctx, u32 out)
+{
+	/*
+	 * By now, the eBPF program has already setup parameters in r3, r4 and r5
+	 * r3/BPF_REG_1 - pointer to ctx -- passed as is to the next bpf program
+	 * r4/BPF_REG_2 - pointer to bpf_array
+	 * r5/BPF_REG_3 - index in bpf_array
+	 */
+	int b2p_bpf_array = b2p[BPF_REG_2];
+	int b2p_index = b2p[BPF_REG_3];
+
+	/*
+	 * if (index >= array->map.max_entries)
+	 *   goto out;
+	 */
+	PPC_LWZ(b2p[TMP_REG_1], b2p_bpf_array, offsetof(struct bpf_array, map.max_entries));
+	PPC_CMPLW(b2p_index, b2p[TMP_REG_1]);
+	PPC_BCC(COND_GE, out);
+
+	/*
+	 * if (tail_call_cnt > MAX_TAIL_CALL_CNT)
+	 *   goto out;
+	 */
+	PPC_LD(b2p[TMP_REG_1], 1, bpf_jit_stack_tailcallcnt(ctx));
+	PPC_CMPLWI(b2p[TMP_REG_1], MAX_TAIL_CALL_CNT);
+	PPC_BCC(COND_GT, out);
+
+	/*
+	 * tail_call_cnt++;
+	 */
+	PPC_ADDI(b2p[TMP_REG_1], b2p[TMP_REG_1], 1);
+	PPC_BPF_STL(b2p[TMP_REG_1], 1, bpf_jit_stack_tailcallcnt(ctx));
+
+	/* prog = array->ptrs[index]; */
+	PPC_MULI(b2p[TMP_REG_1], b2p_index, 8);
+	PPC_ADD(b2p[TMP_REG_1], b2p[TMP_REG_1], b2p_bpf_array);
+	PPC_LD(b2p[TMP_REG_1], b2p[TMP_REG_1], offsetof(struct bpf_array, ptrs));
+
+	/*
+	 * if (prog == NULL)
+	 *   goto out;
+	 */
+	PPC_CMPLDI(b2p[TMP_REG_1], 0);
+	PPC_BCC(COND_EQ, out);
+
+	/* goto *(prog->bpf_func + prologue_size); */
+	PPC_LD(b2p[TMP_REG_1], b2p[TMP_REG_1], offsetof(struct bpf_prog, bpf_func));
+#ifdef PPC64_ELF_ABI_v1
+	/* skip past the function descriptor */
+	PPC_ADDI(b2p[TMP_REG_1], b2p[TMP_REG_1],
+			FUNCTION_DESCR_SIZE + BPF_TAILCALL_PROLOGUE_SIZE);
+#else
+	PPC_ADDI(b2p[TMP_REG_1], b2p[TMP_REG_1], BPF_TAILCALL_PROLOGUE_SIZE);
+#endif
+	PPC_MTCTR(b2p[TMP_REG_1]);
+
+	/* tear down stack, restore NVRs, ... */
+	bpf_jit_emit_common_epilogue(image, ctx);
+
+	PPC_BCTR();
+	/* out: */
+}
+
 /* Assemble the body code between the prologue & epilogue */
 static int bpf_jit_build_body(struct bpf_prog *fp, u32 *image,
 			      struct codegen_context *ctx,
@@ -846,9 +936,12 @@ common_load:
 			break;
 
 		/*
-		 * TODO: Tail call
+		 * Tail call
 		 */
 		case BPF_JMP | BPF_CALL | BPF_X:
+			ctx->seen |= SEEN_TAILCALL;
+			bpf_jit_emit_tail_call(image, ctx, addrs[i + 1]);
+			break;
 
 		default:
 			/*
-- 
2.9.3
