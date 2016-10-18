From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next] bpf: Detect identical PTR_TO_MAP_VALUE_OR_NULL registers
Date: Tue, 18 Oct 2016 19:51:19 +0200
Message-ID: <c678e43377187d72c87a030ad27afbcd7748e1e3.1476812715.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, jbacik@fb.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:42141 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932230AbcJRRv1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 13:51:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A BPF program is required to check the return register of a
map_elem_lookup() call before accessing memory. The verifier keeps
track of this by converting the type of the result register from
PTR_TO_MAP_VALUE_OR_NULL to PTR_TO_MAP_VALUE after a conditional
jump ensures safety. This check is currently exclusively performed
for the result register 0.

In the event the compiler reorders instructions, BPF_MOV64_REG
instructions may be moved before the conditional jump which causes
them to keep their type PTR_TO_MAP_VALUE_OR_NULL to which the
verifier objects when the register is accessed:

0: (b7) r1 = 10
1: (7b) *(u64 *)(r10 -8) = r1
2: (bf) r2 = r10
3: (07) r2 += -8
4: (18) r1 = 0x59c00000
6: (85) call 1
7: (bf) r4 = r0
8: (15) if r0 == 0x0 goto pc+1
 R0=map_value(ks=8,vs=8) R4=map_value_or_null(ks=8,vs=8) R10=fp
9: (7a) *(u64 *)(r4 +0) = 0
R4 invalid mem access 'map_value_or_null'

This commit extends the verifier to keep track of all identical
PTR_TO_MAP_VALUE_OR_NULL registers after a map_elem_lookup() by
assigning them an ID and then marking them all when the conditional
jump is observed.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
Reviewed-by: Josef Bacik <jbacik@fb.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/bpf_verifier.h                |  2 +-
 kernel/bpf/verifier.c                       | 61 +++++++++++++++++-------
 tools/testing/selftests/bpf/test_verifier.c | 72 +++++++++++++++++++++++++++++
 3 files changed, 118 insertions(+), 17 deletions(-)

diff --git a/include/linux/bpf_verifier.h b/include/linux/bpf_verifier.h
index 7035b99..ac5b393 100644
--- a/include/linux/bpf_verifier.h
+++ b/include/linux/bpf_verifier.h
@@ -23,13 +23,13 @@ struct bpf_reg_state {
 	 * result in a bad access.
 	 */
 	u64 min_value, max_value;
+	u32 id;
 	union {
 		/* valid when type == CONST_IMM | PTR_TO_STACK | UNKNOWN_VALUE */
 		s64 imm;
 
 		/* valid when type == PTR_TO_PACKET* */
 		struct {
-			u32 id;
 			u16 off;
 			u16 range;
 		};
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 99a7e5b..846d7ce 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -212,9 +212,10 @@ static void print_verifier_state(struct bpf_verifier_state *state)
 		else if (t == CONST_PTR_TO_MAP || t == PTR_TO_MAP_VALUE ||
 			 t == PTR_TO_MAP_VALUE_OR_NULL ||
 			 t == PTR_TO_MAP_VALUE_ADJ)
-			verbose("(ks=%d,vs=%d)",
+			verbose("(ks=%d,vs=%d,id=%u)",
 				reg->map_ptr->key_size,
-				reg->map_ptr->value_size);
+				reg->map_ptr->value_size,
+				reg->id);
 		if (reg->min_value != BPF_REGISTER_MIN_RANGE)
 			verbose(",min_value=%llu",
 				(unsigned long long)reg->min_value);
@@ -447,6 +448,7 @@ static void mark_reg_unknown_value(struct bpf_reg_state *regs, u32 regno)
 {
 	BUG_ON(regno >= MAX_BPF_REG);
 	regs[regno].type = UNKNOWN_VALUE;
+	regs[regno].id = 0;
 	regs[regno].imm = 0;
 }
 
@@ -1252,6 +1254,7 @@ static int check_call(struct bpf_verifier_env *env, int func_id)
 			return -EINVAL;
 		}
 		regs[BPF_REG_0].map_ptr = meta.map_ptr;
+		regs[BPF_REG_0].id = ++env->id_gen;
 	} else {
 		verbose("unknown return type %d of func %d\n",
 			fn->ret_type, func_id);
@@ -1644,8 +1647,7 @@ static int check_alu_op(struct bpf_verifier_env *env, struct bpf_insn *insn)
 						insn->src_reg);
 					return -EACCES;
 				}
-				regs[insn->dst_reg].type = UNKNOWN_VALUE;
-				regs[insn->dst_reg].map_ptr = NULL;
+				mark_reg_unknown_value(regs, insn->dst_reg);
 			}
 		} else {
 			/* case: R = imm
@@ -1907,6 +1909,38 @@ static void reg_set_min_max_inv(struct bpf_reg_state *true_reg,
 	check_reg_overflow(true_reg);
 }
 
+static void mark_map_reg(struct bpf_reg_state *regs, u32 regno, u32 id,
+			 enum bpf_reg_type type)
+{
+	struct bpf_reg_state *reg = &regs[regno];
+
+	if (reg->type == PTR_TO_MAP_VALUE_OR_NULL && reg->id == id) {
+		reg->type = type;
+		if (type == UNKNOWN_VALUE)
+			mark_reg_unknown_value(regs, regno);
+	}
+}
+
+/* The logic is similar to find_good_pkt_pointers(), both could eventually
+ * be folded together at some point.
+ */
+static void mark_map_regs(struct bpf_verifier_state *state, u32 regno,
+			  enum bpf_reg_type type)
+{
+	struct bpf_reg_state *regs = state->regs;
+	int i;
+
+	for (i = 0; i < MAX_BPF_REG; i++)
+		mark_map_reg(regs, i, regs[regno].id, type);
+
+	for (i = 0; i < MAX_BPF_STACK; i += BPF_REG_SIZE) {
+		if (state->stack_slot_type[i] != STACK_SPILL)
+			continue;
+		mark_map_reg(state->spilled_regs, i / BPF_REG_SIZE,
+			     regs[regno].id, type);
+	}
+}
+
 static int check_cond_jmp_op(struct bpf_verifier_env *env,
 			     struct bpf_insn *insn, int *insn_idx)
 {
@@ -1994,18 +2028,13 @@ static int check_cond_jmp_op(struct bpf_verifier_env *env,
 	if (BPF_SRC(insn->code) == BPF_K &&
 	    insn->imm == 0 && (opcode == BPF_JEQ || opcode == BPF_JNE) &&
 	    dst_reg->type == PTR_TO_MAP_VALUE_OR_NULL) {
-		if (opcode == BPF_JEQ) {
-			/* next fallthrough insn can access memory via
-			 * this register
-			 */
-			regs[insn->dst_reg].type = PTR_TO_MAP_VALUE;
-			/* branch targer cannot access it, since reg == 0 */
-			mark_reg_unknown_value(other_branch->regs,
-					       insn->dst_reg);
-		} else {
-			other_branch->regs[insn->dst_reg].type = PTR_TO_MAP_VALUE;
-			mark_reg_unknown_value(regs, insn->dst_reg);
-		}
+		/* Mark all identical map registers in each branch as either
+		 * safe or unknown depending R == 0 or R != 0 conditional.
+		 */
+		mark_map_regs(this_branch, insn->dst_reg,
+			      opcode == BPF_JEQ ? PTR_TO_MAP_VALUE : UNKNOWN_VALUE);
+		mark_map_regs(other_branch, insn->dst_reg,
+			      opcode == BPF_JEQ ? UNKNOWN_VALUE : PTR_TO_MAP_VALUE);
 	} else if (BPF_SRC(insn->code) == BPF_X && opcode == BPF_JGT &&
 		   dst_reg->type == PTR_TO_PACKET &&
 		   regs[insn->src_reg].type == PTR_TO_PACKET_END) {
diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index ff5df12..0ef8eaf 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -2588,6 +2588,78 @@ static struct bpf_test tests[] = {
 		.result_unpriv = REJECT,
 		.result = REJECT,
 	},
+	{
+		"multiple registers share map_lookup_elem result",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_1, 10),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_1, -8),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_0),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_4, 0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map1 = { 4 },
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS
+	},
+	{
+		"invalid memory access with multiple map_lookup_elem calls",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_1, 10),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_1, -8),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_MOV64_REG(BPF_REG_8, BPF_REG_1),
+			BPF_MOV64_REG(BPF_REG_7, BPF_REG_2),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_0),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_8),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_7),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_4, 0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map1 = { 4 },
+		.result = REJECT,
+		.errstr = "R4 !read_ok",
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS
+	},
+	{
+		"valid indirect map_lookup_elem access with 2nd lookup in branch",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_1, 10),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_1, -8),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_MOV64_REG(BPF_REG_8, BPF_REG_1),
+			BPF_MOV64_REG(BPF_REG_7, BPF_REG_2),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_MOV64_IMM(BPF_REG_2, 10),
+			BPF_JMP_IMM(BPF_JNE, BPF_REG_2, 0, 3),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_8),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_7),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_0),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_4, 0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map1 = { 4 },
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS
+	},
 };
 
 static int probe_filter_length(const struct bpf_insn *fp)
-- 
2.7.4
