From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] bpf, arm64: use separate register for state in stxr
Date: Wed,  7 Jun 2017 13:45:37 +0200
Message-ID: <530443d87bd51b3682a1b60ea19b2030d7d21409.1496834547.git.daniel@iogearbox.net>
Cc: will.deacon@arm.com, ast@fb.com, zlim.lnx@gmail.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:32866 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751489AbdFGLps (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 07:45:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Will reported that in BPF_XADD we must use a different register in stxr
instruction for the status flag due to otherwise CONSTRAINED UNPREDICTABLE
behavior per architecture. Reference manual says [1]:

  If s == t, then one of the following behaviors must occur:

   * The instruction is UNDEFINED.
   * The instruction executes as a NOP.
   * The instruction performs the store to the specified address, but
     the value stored is UNKNOWN.

Thus, use a different temporary register for the status flag to fix it.

Disassembly extract from test 226/STX_XADD_DW from test_bpf.ko:

  [...]
  0000003c:  c85f7d4b  ldxr x11, [x10]
  00000040:  8b07016b  add x11, x11, x7
  00000044:  c80c7d4b  stxr w12, x11, [x10]
  00000048:  35ffffac  cbnz w12, 0x0000003c
  [...]

  [1] https://static.docs.arm.com/ddi0487/b/DDI0487B_a_armv8_arm.pdf, p.6132

Fixes: 85f68fe89832 ("bpf, arm64: implement jiting of BPF_XADD")
Reported-by: Will Deacon <will.deacon@arm.com>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 arch/arm64/net/bpf_jit_comp.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/arch/arm64/net/bpf_jit_comp.c b/arch/arm64/net/bpf_jit_comp.c
index 71f9305..c870d6f 100644
--- a/arch/arm64/net/bpf_jit_comp.c
+++ b/arch/arm64/net/bpf_jit_comp.c
@@ -36,6 +36,7 @@
 #define TMP_REG_1 (MAX_BPF_JIT_REG + 0)
 #define TMP_REG_2 (MAX_BPF_JIT_REG + 1)
 #define TCALL_CNT (MAX_BPF_JIT_REG + 2)
+#define TMP_REG_3 (MAX_BPF_JIT_REG + 3)
 
 /* Map BPF registers to A64 registers */
 static const int bpf2a64[] = {
@@ -57,6 +58,7 @@
 	/* temporary registers for internal BPF JIT */
 	[TMP_REG_1] = A64_R(10),
 	[TMP_REG_2] = A64_R(11),
+	[TMP_REG_3] = A64_R(12),
 	/* tail_call_cnt */
 	[TCALL_CNT] = A64_R(26),
 	/* temporary register for blinding constants */
@@ -319,6 +321,7 @@ static int build_insn(const struct bpf_insn *insn, struct jit_ctx *ctx)
 	const u8 src = bpf2a64[insn->src_reg];
 	const u8 tmp = bpf2a64[TMP_REG_1];
 	const u8 tmp2 = bpf2a64[TMP_REG_2];
+	const u8 tmp3 = bpf2a64[TMP_REG_3];
 	const s16 off = insn->off;
 	const s32 imm = insn->imm;
 	const int i = insn - ctx->prog->insnsi;
@@ -689,10 +692,10 @@ static int build_insn(const struct bpf_insn *insn, struct jit_ctx *ctx)
 		emit(A64_PRFM(tmp, PST, L1, STRM), ctx);
 		emit(A64_LDXR(isdw, tmp2, tmp), ctx);
 		emit(A64_ADD(isdw, tmp2, tmp2, src), ctx);
-		emit(A64_STXR(isdw, tmp2, tmp, tmp2), ctx);
+		emit(A64_STXR(isdw, tmp2, tmp, tmp3), ctx);
 		jmp_offset = -3;
 		check_imm19(jmp_offset);
-		emit(A64_CBNZ(0, tmp2, jmp_offset), ctx);
+		emit(A64_CBNZ(0, tmp3, jmp_offset), ctx);
 		break;
 
 	/* R0 = ntohx(*(size *)(((struct sk_buff *)R6)->data + imm)) */
-- 
1.9.3
