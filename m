From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 6/7] bpf, verifier: add additional patterns to evaluate_reg_imm_alu
Date: Sun,  2 Jul 2017 02:13:30 +0200
Message-ID: <5460455050b0f4e00e1c0abdeba5fa50989539d1.1498952486.git.daniel@iogearbox.net>
References: <cover.1498952486.git.daniel@iogearbox.net>
Cc: ast@fb.com, john.fastabend@gmail.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57549 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752352AbdGBANq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Jul 2017 20:13:46 -0400
In-Reply-To: <cover.1498952486.git.daniel@iogearbox.net>
In-Reply-To: <cover.1498952486.git.daniel@iogearbox.net>
References: <cover.1498952486.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>

Currently the verifier does not track imm across alu operations when
the source register is of unknown type. This adds additional pattern
matching to catch this and track imm. We've seen LLVM generating this
pattern while working on cilium.

Signed-off-by: John Fastabend <john.fastabend@gmail.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/verifier.c | 62 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 62 insertions(+)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 6f820a0..6a86723 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1657,6 +1657,65 @@ static int evaluate_reg_alu(struct bpf_verifier_env *env, struct bpf_insn *insn)
 	return 0;
 }
 
+static int evaluate_reg_imm_alu_unknown(struct bpf_verifier_env *env,
+					struct bpf_insn *insn)
+{
+	struct bpf_reg_state *regs = env->cur_state.regs;
+	struct bpf_reg_state *dst_reg = &regs[insn->dst_reg];
+	struct bpf_reg_state *src_reg = &regs[insn->src_reg];
+	u8 opcode = BPF_OP(insn->code);
+	s64 imm_log2 = __ilog2_u64((long long)dst_reg->imm);
+
+	/* BPF_X code with src_reg->type UNKNOWN_VALUE here. */
+	if (src_reg->imm > 0 && dst_reg->imm) {
+		switch (opcode) {
+		case BPF_ADD:
+			/* dreg += sreg
+			 * where both have zero upper bits. Adding them
+			 * can only result making one more bit non-zero
+			 * in the larger value.
+			 * Ex. 0xffff (imm=48) + 1 (imm=63) = 0x10000 (imm=47)
+			 *     0xffff (imm=48) + 0xffff = 0x1fffe (imm=47)
+			 */
+			dst_reg->imm = min(src_reg->imm, 63 - imm_log2);
+			dst_reg->imm--;
+			break;
+		case BPF_AND:
+			/* dreg &= sreg
+			 * AND can not extend zero bits only shrink
+			 * Ex.  0x00..00ffffff
+			 *    & 0x0f..ffffffff
+			 *     ----------------
+			 *      0x00..00ffffff
+			 */
+			dst_reg->imm = max(src_reg->imm, 63 - imm_log2);
+			break;
+		case BPF_OR:
+			/* dreg |= sreg
+			 * OR can only extend zero bits
+			 * Ex.  0x00..00ffffff
+			 *    | 0x0f..ffffffff
+			 *     ----------------
+			 *      0x0f..00ffffff
+			 */
+			dst_reg->imm = min(src_reg->imm, 63 - imm_log2);
+			break;
+		case BPF_SUB:
+		case BPF_MUL:
+		case BPF_RSH:
+		case BPF_LSH:
+			/* These may be flushed out later */
+		default:
+			mark_reg_unknown_value(regs, insn->dst_reg);
+		}
+	} else {
+		mark_reg_unknown_value(regs, insn->dst_reg);
+	}
+
+	dst_reg->type = UNKNOWN_VALUE;
+	return 0;
+}
+
 static int evaluate_reg_imm_alu(struct bpf_verifier_env *env,
 				struct bpf_insn *insn)
 {
@@ -1666,6 +1725,9 @@ static int evaluate_reg_imm_alu(struct bpf_verifier_env *env,
 	u8 opcode = BPF_OP(insn->code);
 	u64 dst_imm = dst_reg->imm;
 
+	if (BPF_SRC(insn->code) == BPF_X && src_reg->type == UNKNOWN_VALUE)
+		return evaluate_reg_imm_alu_unknown(env, insn);
+
 	/* dst_reg->type == CONST_IMM here. Simulate execution of insns
 	 * containing ALU ops. Don't care about overflow or negative
 	 * values, just add/sub/... them; registers are in u64.
-- 
1.9.3
