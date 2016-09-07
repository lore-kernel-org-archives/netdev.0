From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] bpf: fix range propagation on direct packet access
Date: Thu,  8 Sep 2016 01:03:42 +0200
Message-ID: <114cf30cb121f3b246d5e1dd436208b6dd675e32.1473288722.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48677 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752425AbcIGXDs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 19:03:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

LLVM can generate code that tests for direct packet access via
skb->data/data_end in a way that currently gets rejected by the
verifier, example:

  [...]
   7: (61) r3 = *(u32 *)(r6 +80)
   8: (61) r9 = *(u32 *)(r6 +76)
   9: (bf) r2 = r9
  10: (07) r2 += 54
  11: (3d) if r3 >= r2 goto pc+12
   R1=inv R2=pkt(id=0,off=54,r=0) R3=pkt_end R4=inv R6=ctx
   R9=pkt(id=0,off=0,r=0) R10=fp
  12: (18) r4 = 0xffffff7a
  14: (05) goto pc+430
  [...]

  from 11 to 24: R1=inv R2=pkt(id=0,off=54,r=0) R3=pkt_end R4=inv
                 R6=ctx R9=pkt(id=0,off=0,r=0) R10=fp
  24: (7b) *(u64 *)(r10 -40) = r1
  25: (b7) r1 = 0
  26: (63) *(u32 *)(r6 +56) = r1
  27: (b7) r2 = 40
  28: (71) r8 = *(u8 *)(r9 +20)
  invalid access to packet, off=20 size=1, R9(id=0,off=0,r=0)

The reason why this gets rejected despite a proper test is that we
currently call find_good_pkt_pointers() only in case where we detect
tests like rX > pkt_end, where rX is of type pkt(id=Y,off=Z,r=0) and
derived, for example, from a register of type pkt(id=Y,off=0,r=0)
pointing to skb->data. find_good_pkt_pointers() then fills the range
in the current branch to pkt(id=Y,off=0,r=Z) on success.

For above case, we need to extend that to recognize pkt_end >= rX
pattern and mark the other branch that is taken on success with the
appropriate pkt(id=Y,off=0,r=Z) type via find_good_pkt_pointers().
Since eBPF operates on BPF_JGT (>) and BPF_JGE (>=), these are the
only two practical options to test for from what LLVM could have
generated, since there's no such thing as BPF_JLT (<) or BPF_JLE (<=)
that we would need to take into account as well.

After the fix:

  [...]
   7: (61) r3 = *(u32 *)(r6 +80)
   8: (61) r9 = *(u32 *)(r6 +76)
   9: (bf) r2 = r9
  10: (07) r2 += 54
  11: (3d) if r3 >= r2 goto pc+12
   R1=inv R2=pkt(id=0,off=54,r=0) R3=pkt_end R4=inv R6=ctx
   R9=pkt(id=0,off=0,r=0) R10=fp
  12: (18) r4 = 0xffffff7a
  14: (05) goto pc+430
  [...]

  from 11 to 24: R1=inv R2=pkt(id=0,off=54,r=54) R3=pkt_end R4=inv
                 R6=ctx R9=pkt(id=0,off=0,r=54) R10=fp
  24: (7b) *(u64 *)(r10 -40) = r1
  25: (b7) r1 = 0
  26: (63) *(u32 *)(r6 +56) = r1
  27: (b7) r2 = 40
  28: (71) r8 = *(u8 *)(r9 +20)
  29: (bf) r1 = r8
  30: (25) if r8 > 0x3c goto pc+47
   R1=inv56 R2=imm40 R3=pkt_end R4=inv R6=ctx R8=inv56
   R9=pkt(id=0,off=0,r=54) R10=fp
  31: (b7) r1 = 1
  [...]

Verifier test cases are also added in this work, one that demonstrates
the mentioned example here and one that tries a bad packet access for
the current/fall-through branch (the one with types pkt(id=X,off=Y,r=0),
pkt(id=X,off=0,r=0)), then a case with good and bad accesses, and two
with both test variants (>, >=).

Fixes: 969bf05eb3ce ("bpf: direct packet access")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 Targetting at net-next as this should be just fine.

 kernel/bpf/verifier.c       |  55 +++++++++++++++++-------
 samples/bpf/test_verifier.c | 102 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 142 insertions(+), 15 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 48c2705..90493a6 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1637,21 +1637,42 @@ static int check_alu_op(struct verifier_env *env, struct bpf_insn *insn)
 	return 0;
 }
 
-static void find_good_pkt_pointers(struct verifier_env *env,
-				   struct reg_state *dst_reg)
+static void find_good_pkt_pointers(struct verifier_state *state,
+				   const struct reg_state *dst_reg)
 {
-	struct verifier_state *state = &env->cur_state;
 	struct reg_state *regs = state->regs, *reg;
 	int i;
-	/* r2 = r3;
-	 * r2 += 8
-	 * if (r2 > pkt_end) goto somewhere
-	 * r2 == dst_reg, pkt_end == src_reg,
-	 * r2=pkt(id=n,off=8,r=0)
-	 * r3=pkt(id=n,off=0,r=0)
-	 * find register r3 and mark its range as r3=pkt(id=n,off=0,r=8)
-	 * so that range of bytes [r3, r3 + 8) is safe to access
+
+	/* LLVM can generate two kind of checks:
+	 *
+	 * Type 1:
+	 *
+	 *   r2 = r3;
+	 *   r2 += 8;
+	 *   if (r2 > pkt_end) goto <handle exception>
+	 *   <access okay>
+	 *
+	 *   Where:
+	 *     r2 == dst_reg, pkt_end == src_reg
+	 *     r2=pkt(id=n,off=8,r=0)
+	 *     r3=pkt(id=n,off=0,r=0)
+	 *
+	 * Type 2:
+	 *
+	 *   r2 = r3;
+	 *   r2 += 8;
+	 *   if (pkt_end >= r2) goto <access okay>
+	 *   <handle exception>
+	 *
+	 *   Where:
+	 *     pkt_end == dst_reg, r2 == src_reg
+	 *     r2=pkt(id=n,off=8,r=0)
+	 *     r3=pkt(id=n,off=0,r=0)
+	 *
+	 * Find register r3 and mark its range as r3=pkt(id=n,off=0,r=8)
+	 * so that range of bytes [r3, r3 + 8) is safe to access.
 	 */
+
 	for (i = 0; i < MAX_BPF_REG; i++)
 		if (regs[i].type == PTR_TO_PACKET && regs[i].id == dst_reg->id)
 			regs[i].range = dst_reg->off;
@@ -1668,8 +1689,8 @@ static void find_good_pkt_pointers(struct verifier_env *env,
 static int check_cond_jmp_op(struct verifier_env *env,
 			     struct bpf_insn *insn, int *insn_idx)
 {
-	struct reg_state *regs = env->cur_state.regs, *dst_reg;
-	struct verifier_state *other_branch;
+	struct verifier_state *other_branch, *this_branch = &env->cur_state;
+	struct reg_state *regs = this_branch->regs, *dst_reg;
 	u8 opcode = BPF_OP(insn->code);
 	int err;
 
@@ -1750,13 +1771,17 @@ static int check_cond_jmp_op(struct verifier_env *env,
 	} else if (BPF_SRC(insn->code) == BPF_X && opcode == BPF_JGT &&
 		   dst_reg->type == PTR_TO_PACKET &&
 		   regs[insn->src_reg].type == PTR_TO_PACKET_END) {
-		find_good_pkt_pointers(env, dst_reg);
+		find_good_pkt_pointers(this_branch, dst_reg);
+	} else if (BPF_SRC(insn->code) == BPF_X && opcode == BPF_JGE &&
+		   dst_reg->type == PTR_TO_PACKET_END &&
+		   regs[insn->src_reg].type == PTR_TO_PACKET) {
+		find_good_pkt_pointers(other_branch, &regs[insn->src_reg]);
 	} else if (is_pointer_value(env, insn->dst_reg)) {
 		verbose("R%d pointer comparison prohibited\n", insn->dst_reg);
 		return -EACCES;
 	}
 	if (log_level)
-		print_verifier_state(&env->cur_state);
+		print_verifier_state(this_branch);
 	return 0;
 }
 
diff --git a/samples/bpf/test_verifier.c b/samples/bpf/test_verifier.c
index 78c6f13..1f6cc9b 100644
--- a/samples/bpf/test_verifier.c
+++ b/samples/bpf/test_verifier.c
@@ -1529,6 +1529,108 @@ static struct bpf_test tests[] = {
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 	},
 	{
+		"direct packet access: test5 (pkt_end >= reg, good access)",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8),
+			BPF_JMP_REG(BPF_JGE, BPF_REG_3, BPF_REG_0, 2),
+			BPF_MOV64_IMM(BPF_REG_0, 1),
+			BPF_EXIT_INSN(),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"direct packet access: test6 (pkt_end >= reg, bad access)",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8),
+			BPF_JMP_REG(BPF_JGE, BPF_REG_3, BPF_REG_0, 3),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 1),
+			BPF_EXIT_INSN(),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid access to packet",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"direct packet access: test7 (pkt_end >= reg, both accesses)",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8),
+			BPF_JMP_REG(BPF_JGE, BPF_REG_3, BPF_REG_0, 3),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 1),
+			BPF_EXIT_INSN(),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid access to packet",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"direct packet access: test8 (double test, variant 1)",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8),
+			BPF_JMP_REG(BPF_JGE, BPF_REG_3, BPF_REG_0, 4),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_0, BPF_REG_3, 1),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 1),
+			BPF_EXIT_INSN(),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"direct packet access: test9 (double test, variant 2)",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8),
+			BPF_JMP_REG(BPF_JGE, BPF_REG_3, BPF_REG_0, 2),
+			BPF_MOV64_IMM(BPF_REG_0, 1),
+			BPF_EXIT_INSN(),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_0, BPF_REG_3, 1),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
 		"helper access to packet: test1, valid packet_ptr range",
 		.insns = {
 			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
-- 
1.9.3
