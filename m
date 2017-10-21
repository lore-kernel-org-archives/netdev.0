From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 1/3] bpf: fix off by one for range markings with L{T,E} patterns
Date: Sat, 21 Oct 2017 02:34:21 +0200
Message-ID: <3df9cce096b139eb0efb3b0c7bf9fcc5c5dc6629.1508545543.git.daniel@iogearbox.net>
References: <cover.1508545543.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, john.r.fastabend@gmail.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:47360 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752671AbdJUAew (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 20:34:52 -0400
In-Reply-To: <cover.1508545543.git.daniel@iogearbox.net>
In-Reply-To: <cover.1508545543.git.daniel@iogearbox.net>
References: <cover.1508545543.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During review I noticed that the current logic for direct packet
access marking in check_cond_jmp_op() has an off by one for the
upper right range border when marking in find_good_pkt_pointers()
with BPF_JLT and BPF_JLE. It's not really harmful given access
up to pkt_end is always safe, but we should nevertheless correct
the range marking before it becomes ABI. If pkt_data' denotes a
pkt_data derived pointer (pkt_data + X), then for pkt_data' < pkt_end
in the true branch as well as for pkt_end <= pkt_data' in the false
branch we mark the range with X although it should really be X - 1
in these cases. For example, X could be pkt_end - pkt_data, then
when testing for pkt_data' < pkt_end the verifier simulation cannot
deduce that a byte load of pkt_data' - 1 would succeed in this
branch.

Fixes: b4e432f1000a ("bpf: enable BPF_J{LT, LE, SLT, SLE} opcodes in verifier")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/verifier.c | 33 +++++++++++++++++++++------------
 1 file changed, 21 insertions(+), 12 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 20f3889..49cb5ad 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -2430,12 +2430,15 @@ static int check_alu_op(struct bpf_verifier_env *env, struct bpf_insn *insn)
 }
 
 static void find_good_pkt_pointers(struct bpf_verifier_state *state,
-				   struct bpf_reg_state *dst_reg)
+				   struct bpf_reg_state *dst_reg,
+				   bool range_right_open)
 {
 	struct bpf_reg_state *regs = state->regs, *reg;
+	u16 new_range;
 	int i;
 
-	if (dst_reg->off < 0)
+	if (dst_reg->off < 0 ||
+	    (dst_reg->off == 0 && range_right_open))
 		/* This doesn't give us any range */
 		return;
 
@@ -2446,9 +2449,13 @@ static void find_good_pkt_pointers(struct bpf_verifier_state *state,
 		 */
 		return;
 
-	/* LLVM can generate four kind of checks:
+	new_range = dst_reg->off;
+	if (range_right_open)
+		new_range--;
+
+	/* Examples for register markings:
 	 *
-	 * Type 1/2:
+	 * pkt_data in dst register:
 	 *
 	 *   r2 = r3;
 	 *   r2 += 8;
@@ -2465,7 +2472,7 @@ static void find_good_pkt_pointers(struct bpf_verifier_state *state,
 	 *     r2=pkt(id=n,off=8,r=0)
 	 *     r3=pkt(id=n,off=0,r=0)
 	 *
-	 * Type 3/4:
+	 * pkt_data in src register:
 	 *
 	 *   r2 = r3;
 	 *   r2 += 8;
@@ -2483,7 +2490,9 @@ static void find_good_pkt_pointers(struct bpf_verifier_state *state,
 	 *     r3=pkt(id=n,off=0,r=0)
 	 *
 	 * Find register r3 and mark its range as r3=pkt(id=n,off=0,r=8)
-	 * so that range of bytes [r3, r3 + 8) is safe to access.
+	 * or r3=pkt(id=n,off=0,r=8-1), so that range of bytes [r3, r3 + 8)
+	 * and [r3, r3 + 8-1) respectively is safe to access depending on
+	 * the check.
 	 */
 
 	/* If our ids match, then we must have the same max_value.  And we
@@ -2494,14 +2503,14 @@ static void find_good_pkt_pointers(struct bpf_verifier_state *state,
 	for (i = 0; i < MAX_BPF_REG; i++)
 		if (regs[i].type == PTR_TO_PACKET && regs[i].id == dst_reg->id)
 			/* keep the maximum range already checked */
-			regs[i].range = max_t(u16, regs[i].range, dst_reg->off);
+			regs[i].range = max(regs[i].range, new_range);
 
 	for (i = 0; i < MAX_BPF_STACK; i += BPF_REG_SIZE) {
 		if (state->stack_slot_type[i] != STACK_SPILL)
 			continue;
 		reg = &state->spilled_regs[i / BPF_REG_SIZE];
 		if (reg->type == PTR_TO_PACKET && reg->id == dst_reg->id)
-			reg->range = max_t(u16, reg->range, dst_reg->off);
+			reg->range = max(reg->range, new_range);
 	}
 }
 
@@ -2865,19 +2874,19 @@ static int check_cond_jmp_op(struct bpf_verifier_env *env,
 	} else if (BPF_SRC(insn->code) == BPF_X && opcode == BPF_JGT &&
 		   dst_reg->type == PTR_TO_PACKET &&
 		   regs[insn->src_reg].type == PTR_TO_PACKET_END) {
-		find_good_pkt_pointers(this_branch, dst_reg);
+		find_good_pkt_pointers(this_branch, dst_reg, false);
 	} else if (BPF_SRC(insn->code) == BPF_X && opcode == BPF_JLT &&
 		   dst_reg->type == PTR_TO_PACKET &&
 		   regs[insn->src_reg].type == PTR_TO_PACKET_END) {
-		find_good_pkt_pointers(other_branch, dst_reg);
+		find_good_pkt_pointers(other_branch, dst_reg, true);
 	} else if (BPF_SRC(insn->code) == BPF_X && opcode == BPF_JGE &&
 		   dst_reg->type == PTR_TO_PACKET_END &&
 		   regs[insn->src_reg].type == PTR_TO_PACKET) {
-		find_good_pkt_pointers(other_branch, &regs[insn->src_reg]);
+		find_good_pkt_pointers(other_branch, &regs[insn->src_reg], false);
 	} else if (BPF_SRC(insn->code) == BPF_X && opcode == BPF_JLE &&
 		   dst_reg->type == PTR_TO_PACKET_END &&
 		   regs[insn->src_reg].type == PTR_TO_PACKET) {
-		find_good_pkt_pointers(this_branch, &regs[insn->src_reg]);
+		find_good_pkt_pointers(this_branch, &regs[insn->src_reg], true);
 	} else if (is_pointer_value(env, insn->dst_reg)) {
 		verbose("R%d pointer comparison prohibited\n", insn->dst_reg);
 		return -EACCES;
-- 
1.9.3
