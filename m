From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/3] bpf: also improve pattern matches for meta access
Date: Wed,  1 Nov 2017 23:58:10 +0100
Message-ID: <60854045d7986fc5997d38a95fec6426f8f9fdd7.1509576758.git.daniel@iogearbox.net>
References: <cover.1509576758.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, john.r.fastabend@gmail.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:55618 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754922AbdKAW61 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 18:58:27 -0400
In-Reply-To: <cover.1509576758.git.daniel@iogearbox.net>
In-Reply-To: <cover.1509576758.git.daniel@iogearbox.net>
References: <cover.1509576758.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Follow-up to 0fd4759c5515 ("bpf: fix pattern matches for direct
packet access") to cover also the remaining data_meta/data matches
in the verifier. The matches are also refactored a bit to simplify
handling of all the cases.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: John Fastabend <john.fastabend@gmail.com>
---
 kernel/bpf/verifier.c | 165 +++++++++++++++++++++++++++++---------------------
 1 file changed, 96 insertions(+), 69 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 2cc3e94..530b685 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -2787,6 +2787,99 @@ static void mark_map_regs(struct bpf_verifier_state *state, u32 regno,
 	}
 }
 
+static bool try_match_pkt_pointers(const struct bpf_insn *insn,
+				   struct bpf_reg_state *dst_reg,
+				   struct bpf_reg_state *src_reg,
+				   struct bpf_verifier_state *this_branch,
+				   struct bpf_verifier_state *other_branch)
+{
+	if (BPF_SRC(insn->code) != BPF_X)
+		return false;
+
+	switch (BPF_OP(insn->code)) {
+	case BPF_JGT:
+		if ((dst_reg->type == PTR_TO_PACKET &&
+		     src_reg->type == PTR_TO_PACKET_END) ||
+		    (dst_reg->type == PTR_TO_PACKET_META &&
+		     reg_is_init_pkt_pointer(src_reg, PTR_TO_PACKET))) {
+			/* pkt_data' > pkt_end, pkt_meta' > pkt_data */
+			find_good_pkt_pointers(this_branch, dst_reg,
+					       dst_reg->type, false);
+		} else if ((dst_reg->type == PTR_TO_PACKET_END &&
+			    src_reg->type == PTR_TO_PACKET) ||
+			   (reg_is_init_pkt_pointer(dst_reg, PTR_TO_PACKET) &&
+			    src_reg->type == PTR_TO_PACKET_META)) {
+			/* pkt_end > pkt_data', pkt_data > pkt_meta' */
+			find_good_pkt_pointers(other_branch, src_reg,
+					       src_reg->type, true);
+		} else {
+			return false;
+		}
+		break;
+	case BPF_JLT:
+		if ((dst_reg->type == PTR_TO_PACKET &&
+		     src_reg->type == PTR_TO_PACKET_END) ||
+		    (dst_reg->type == PTR_TO_PACKET_META &&
+		     reg_is_init_pkt_pointer(src_reg, PTR_TO_PACKET))) {
+			/* pkt_data' < pkt_end, pkt_meta' < pkt_data */
+			find_good_pkt_pointers(other_branch, dst_reg,
+					       dst_reg->type, true);
+		} else if ((dst_reg->type == PTR_TO_PACKET_END &&
+			    src_reg->type == PTR_TO_PACKET) ||
+			   (reg_is_init_pkt_pointer(dst_reg, PTR_TO_PACKET) &&
+			    src_reg->type == PTR_TO_PACKET_META)) {
+			/* pkt_end < pkt_data', pkt_data > pkt_meta' */
+			find_good_pkt_pointers(this_branch, src_reg,
+					       src_reg->type, false);
+		} else {
+			return false;
+		}
+		break;
+	case BPF_JGE:
+		if ((dst_reg->type == PTR_TO_PACKET &&
+		     src_reg->type == PTR_TO_PACKET_END) ||
+		    (dst_reg->type == PTR_TO_PACKET_META &&
+		     reg_is_init_pkt_pointer(src_reg, PTR_TO_PACKET))) {
+			/* pkt_data' >= pkt_end, pkt_meta' >= pkt_data */
+			find_good_pkt_pointers(this_branch, dst_reg,
+					       dst_reg->type, true);
+		} else if ((dst_reg->type == PTR_TO_PACKET_END &&
+			    src_reg->type == PTR_TO_PACKET) ||
+			   (reg_is_init_pkt_pointer(dst_reg, PTR_TO_PACKET) &&
+			    src_reg->type == PTR_TO_PACKET_META)) {
+			/* pkt_end >= pkt_data', pkt_data >= pkt_meta' */
+			find_good_pkt_pointers(other_branch, src_reg,
+					       src_reg->type, false);
+		} else {
+			return false;
+		}
+		break;
+	case BPF_JLE:
+		if ((dst_reg->type == PTR_TO_PACKET &&
+		     src_reg->type == PTR_TO_PACKET_END) ||
+		    (dst_reg->type == PTR_TO_PACKET_META &&
+		     reg_is_init_pkt_pointer(src_reg, PTR_TO_PACKET))) {
+			/* pkt_data' <= pkt_end, pkt_meta' <= pkt_data */
+			find_good_pkt_pointers(other_branch, dst_reg,
+					       dst_reg->type, false);
+		} else if ((dst_reg->type == PTR_TO_PACKET_END &&
+			    src_reg->type == PTR_TO_PACKET) ||
+			   (reg_is_init_pkt_pointer(dst_reg, PTR_TO_PACKET) &&
+			    src_reg->type == PTR_TO_PACKET_META)) {
+			/* pkt_end <= pkt_data', pkt_data <= pkt_meta' */
+			find_good_pkt_pointers(this_branch, src_reg,
+					       src_reg->type, true);
+		} else {
+			return false;
+		}
+		break;
+	default:
+		return false;
+	}
+
+	return true;
+}
+
 static int check_cond_jmp_op(struct bpf_verifier_env *env,
 			     struct bpf_insn *insn, int *insn_idx)
 {
@@ -2893,75 +2986,9 @@ static int check_cond_jmp_op(struct bpf_verifier_env *env,
 		 */
 		mark_map_regs(this_branch, insn->dst_reg, opcode == BPF_JNE);
 		mark_map_regs(other_branch, insn->dst_reg, opcode == BPF_JEQ);
-	} else if (BPF_SRC(insn->code) == BPF_X && opcode == BPF_JGT &&
-		   dst_reg->type == PTR_TO_PACKET &&
-		   regs[insn->src_reg].type == PTR_TO_PACKET_END) {
-		/* pkt_data' > pkt_end */
-		find_good_pkt_pointers(this_branch, dst_reg,
-				       PTR_TO_PACKET, false);
-	} else if (BPF_SRC(insn->code) == BPF_X && opcode == BPF_JGT &&
-		   dst_reg->type == PTR_TO_PACKET_END &&
-		   regs[insn->src_reg].type == PTR_TO_PACKET) {
-		/* pkt_end > pkt_data' */
-		find_good_pkt_pointers(other_branch, &regs[insn->src_reg],
-				       PTR_TO_PACKET, true);
-	} else if (BPF_SRC(insn->code) == BPF_X && opcode == BPF_JLT &&
-		   dst_reg->type == PTR_TO_PACKET &&
-		   regs[insn->src_reg].type == PTR_TO_PACKET_END) {
-		/* pkt_data' < pkt_end */
-		find_good_pkt_pointers(other_branch, dst_reg, PTR_TO_PACKET,
-				       true);
-	} else if (BPF_SRC(insn->code) == BPF_X && opcode == BPF_JLT &&
-		   dst_reg->type == PTR_TO_PACKET_END &&
-		   regs[insn->src_reg].type == PTR_TO_PACKET) {
-		/* pkt_end < pkt_data' */
-		find_good_pkt_pointers(this_branch, &regs[insn->src_reg],
-				       PTR_TO_PACKET, false);
-	} else if (BPF_SRC(insn->code) == BPF_X && opcode == BPF_JGE &&
-		   dst_reg->type == PTR_TO_PACKET &&
-		   regs[insn->src_reg].type == PTR_TO_PACKET_END) {
-		/* pkt_data' >= pkt_end */
-		find_good_pkt_pointers(this_branch, dst_reg,
-				       PTR_TO_PACKET, true);
-	} else if (BPF_SRC(insn->code) == BPF_X && opcode == BPF_JGE &&
-		   dst_reg->type == PTR_TO_PACKET_END &&
-		   regs[insn->src_reg].type == PTR_TO_PACKET) {
-		/* pkt_end >= pkt_data' */
-		find_good_pkt_pointers(other_branch, &regs[insn->src_reg],
-				       PTR_TO_PACKET, false);
-	} else if (BPF_SRC(insn->code) == BPF_X && opcode == BPF_JLE &&
-		   dst_reg->type == PTR_TO_PACKET &&
-		   regs[insn->src_reg].type == PTR_TO_PACKET_END) {
-		/* pkt_data' <= pkt_end */
-		find_good_pkt_pointers(other_branch, dst_reg,
-				       PTR_TO_PACKET, false);
-	} else if (BPF_SRC(insn->code) == BPF_X && opcode == BPF_JLE &&
-		   dst_reg->type == PTR_TO_PACKET_END &&
-		   regs[insn->src_reg].type == PTR_TO_PACKET) {
-		/* pkt_end <= pkt_data' */
-		find_good_pkt_pointers(this_branch, &regs[insn->src_reg],
-				       PTR_TO_PACKET, true);
-	} else if (BPF_SRC(insn->code) == BPF_X && opcode == BPF_JGT &&
-		   dst_reg->type == PTR_TO_PACKET_META &&
-		   reg_is_init_pkt_pointer(&regs[insn->src_reg], PTR_TO_PACKET)) {
-		find_good_pkt_pointers(this_branch, dst_reg,
-				       PTR_TO_PACKET_META, false);
-	} else if (BPF_SRC(insn->code) == BPF_X && opcode == BPF_JLT &&
-		   dst_reg->type == PTR_TO_PACKET_META &&
-		   reg_is_init_pkt_pointer(&regs[insn->src_reg], PTR_TO_PACKET)) {
-		find_good_pkt_pointers(other_branch, dst_reg,
-				       PTR_TO_PACKET_META, false);
-	} else if (BPF_SRC(insn->code) == BPF_X && opcode == BPF_JGE &&
-		   reg_is_init_pkt_pointer(dst_reg, PTR_TO_PACKET) &&
-		   regs[insn->src_reg].type == PTR_TO_PACKET_META) {
-		find_good_pkt_pointers(other_branch, &regs[insn->src_reg],
-				       PTR_TO_PACKET_META, false);
-	} else if (BPF_SRC(insn->code) == BPF_X && opcode == BPF_JLE &&
-		   reg_is_init_pkt_pointer(dst_reg, PTR_TO_PACKET) &&
-		   regs[insn->src_reg].type == PTR_TO_PACKET_META) {
-		find_good_pkt_pointers(this_branch, &regs[insn->src_reg],
-				       PTR_TO_PACKET_META, false);
-	} else if (is_pointer_value(env, insn->dst_reg)) {
+	} else if (!try_match_pkt_pointers(insn, dst_reg, &regs[insn->src_reg],
+					   this_branch, other_branch) &&
+		   is_pointer_value(env, insn->dst_reg)) {
 		verbose(env, "R%d pointer comparison prohibited\n",
 			insn->dst_reg);
 		return -EACCES;
-- 
1.9.3
