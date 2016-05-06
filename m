From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 1/7] bpf: cleanup verifier code
Date: Thu, 5 May 2016 19:49:09 -0700
Message-ID: <1462502955-1731797-2-git-send-email-ast@fb.com>
References: <1462502955-1731797-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
	<kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:33084 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756693AbcEFCtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2016 22:49:21 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u462jjsl027658
	for <netdev@vger.kernel.org>; Thu, 5 May 2016 19:49:18 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22rh7ugj8u-3
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 05 May 2016 19:49:18 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 1f8dd638133511e697780002c95209d8-9cffbc50 for <netdev@vger.kernel.org>;	Thu,
 05 May 2016 19:49:16 -0700
In-Reply-To: <1462502955-1731797-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cleanup verifier code and prepare it for addition of "pointer to packet" logic

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/verifier.c | 100 ++++++++++++++++++++++++++------------------------
 1 file changed, 53 insertions(+), 47 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 63554b6d4e25..afeb62808902 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -249,28 +249,30 @@ static const char * const reg_type_str[] = {
 	[CONST_IMM]		= "imm",
 };
 
-static void print_verifier_state(struct verifier_env *env)
+static void print_verifier_state(struct verifier_state *state)
 {
+	struct reg_state *reg;
 	enum bpf_reg_type t;
 	int i;
 
 	for (i = 0; i < MAX_BPF_REG; i++) {
-		t = env->cur_state.regs[i].type;
+		reg = &state->regs[i];
+		t = reg->type;
 		if (t == NOT_INIT)
 			continue;
 		verbose(" R%d=%s", i, reg_type_str[t]);
 		if (t == CONST_IMM || t == PTR_TO_STACK)
-			verbose("%ld", env->cur_state.regs[i].imm);
+			verbose("%ld", reg->imm);
 		else if (t == CONST_PTR_TO_MAP || t == PTR_TO_MAP_VALUE ||
 			 t == PTR_TO_MAP_VALUE_OR_NULL)
 			verbose("(ks=%d,vs=%d)",
-				env->cur_state.regs[i].map_ptr->key_size,
-				env->cur_state.regs[i].map_ptr->value_size);
+				reg->map_ptr->key_size,
+				reg->map_ptr->value_size);
 	}
 	for (i = 0; i < MAX_BPF_STACK; i += BPF_REG_SIZE) {
-		if (env->cur_state.stack_slot_type[i] == STACK_SPILL)
+		if (state->stack_slot_type[i] == STACK_SPILL)
 			verbose(" fp%d=%s", -MAX_BPF_STACK + i,
-				reg_type_str[env->cur_state.spilled_regs[i / BPF_REG_SIZE].type]);
+				reg_type_str[state->spilled_regs[i / BPF_REG_SIZE].type]);
 	}
 	verbose("\n");
 }
@@ -686,10 +688,11 @@ static int check_mem_access(struct verifier_env *env, u32 regno, int off,
 			    int value_regno)
 {
 	struct verifier_state *state = &env->cur_state;
+	struct reg_state *reg = &state->regs[regno];
 	int size, err = 0;
 
-	if (state->regs[regno].type == PTR_TO_STACK)
-		off += state->regs[regno].imm;
+	if (reg->type == PTR_TO_STACK)
+		off += reg->imm;
 
 	size = bpf_size_to_bytes(bpf_size);
 	if (size < 0)
@@ -700,7 +703,7 @@ static int check_mem_access(struct verifier_env *env, u32 regno, int off,
 		return -EACCES;
 	}
 
-	if (state->regs[regno].type == PTR_TO_MAP_VALUE) {
+	if (reg->type == PTR_TO_MAP_VALUE) {
 		if (t == BPF_WRITE && value_regno >= 0 &&
 		    is_pointer_value(env, value_regno)) {
 			verbose("R%d leaks addr into map\n", value_regno);
@@ -710,7 +713,7 @@ static int check_mem_access(struct verifier_env *env, u32 regno, int off,
 		if (!err && t == BPF_READ && value_regno >= 0)
 			mark_reg_unknown_value(state->regs, value_regno);
 
-	} else if (state->regs[regno].type == PTR_TO_CTX) {
+	} else if (reg->type == PTR_TO_CTX) {
 		if (t == BPF_WRITE && value_regno >= 0 &&
 		    is_pointer_value(env, value_regno)) {
 			verbose("R%d leaks addr into ctx\n", value_regno);
@@ -720,8 +723,7 @@ static int check_mem_access(struct verifier_env *env, u32 regno, int off,
 		if (!err && t == BPF_READ && value_regno >= 0)
 			mark_reg_unknown_value(state->regs, value_regno);
 
-	} else if (state->regs[regno].type == FRAME_PTR ||
-		   state->regs[regno].type == PTR_TO_STACK) {
+	} else if (reg->type == FRAME_PTR || reg->type == PTR_TO_STACK) {
 		if (off >= 0 || off < -MAX_BPF_STACK) {
 			verbose("invalid stack off=%d size=%d\n", off, size);
 			return -EACCES;
@@ -739,7 +741,7 @@ static int check_mem_access(struct verifier_env *env, u32 regno, int off,
 		}
 	} else {
 		verbose("R%d invalid mem access '%s'\n",
-			regno, reg_type_str[state->regs[regno].type]);
+			regno, reg_type_str[reg->type]);
 		return -EACCES;
 	}
 	return err;
@@ -1104,7 +1106,7 @@ static int check_call(struct verifier_env *env, int func_id)
 /* check validity of 32-bit and 64-bit arithmetic operations */
 static int check_alu_op(struct verifier_env *env, struct bpf_insn *insn)
 {
-	struct reg_state *regs = env->cur_state.regs;
+	struct reg_state *regs = env->cur_state.regs, *dst_reg;
 	u8 opcode = BPF_OP(insn->code);
 	int err;
 
@@ -1193,8 +1195,6 @@ static int check_alu_op(struct verifier_env *env, struct bpf_insn *insn)
 
 	} else {	/* all other ALU ops: and, sub, xor, add, ... */
 
-		bool stack_relative = false;
-
 		if (BPF_SRC(insn->code) == BPF_X) {
 			if (insn->imm != 0 || insn->off != 0) {
 				verbose("BPF_ALU uses reserved fields\n");
@@ -1232,11 +1232,19 @@ static int check_alu_op(struct verifier_env *env, struct bpf_insn *insn)
 			}
 		}
 
+		/* check dest operand */
+		err = check_reg_arg(regs, insn->dst_reg, DST_OP_NO_MARK);
+		if (err)
+			return err;
+
+		dst_reg = &regs[insn->dst_reg];
+
 		/* pattern match 'bpf_add Rx, imm' instruction */
 		if (opcode == BPF_ADD && BPF_CLASS(insn->code) == BPF_ALU64 &&
-		    regs[insn->dst_reg].type == FRAME_PTR &&
-		    BPF_SRC(insn->code) == BPF_K) {
-			stack_relative = true;
+		    dst_reg->type == FRAME_PTR && BPF_SRC(insn->code) == BPF_K) {
+			dst_reg->type = PTR_TO_STACK;
+			dst_reg->imm = insn->imm;
+			return 0;
 		} else if (is_pointer_value(env, insn->dst_reg)) {
 			verbose("R%d pointer arithmetic prohibited\n",
 				insn->dst_reg);
@@ -1248,15 +1256,8 @@ static int check_alu_op(struct verifier_env *env, struct bpf_insn *insn)
 			return -EACCES;
 		}
 
-		/* check dest operand */
-		err = check_reg_arg(regs, insn->dst_reg, DST_OP);
-		if (err)
-			return err;
-
-		if (stack_relative) {
-			regs[insn->dst_reg].type = PTR_TO_STACK;
-			regs[insn->dst_reg].imm = insn->imm;
-		}
+		/* mark dest operand */
+		mark_reg_unknown_value(regs, insn->dst_reg);
 	}
 
 	return 0;
@@ -1265,7 +1266,7 @@ static int check_alu_op(struct verifier_env *env, struct bpf_insn *insn)
 static int check_cond_jmp_op(struct verifier_env *env,
 			     struct bpf_insn *insn, int *insn_idx)
 {
-	struct reg_state *regs = env->cur_state.regs;
+	struct reg_state *regs = env->cur_state.regs, *dst_reg;
 	struct verifier_state *other_branch;
 	u8 opcode = BPF_OP(insn->code);
 	int err;
@@ -1303,11 +1304,12 @@ static int check_cond_jmp_op(struct verifier_env *env,
 	if (err)
 		return err;
 
+	dst_reg = &regs[insn->dst_reg];
+
 	/* detect if R == 0 where R was initialized to zero earlier */
 	if (BPF_SRC(insn->code) == BPF_K &&
 	    (opcode == BPF_JEQ || opcode == BPF_JNE) &&
-	    regs[insn->dst_reg].type == CONST_IMM &&
-	    regs[insn->dst_reg].imm == insn->imm) {
+	    dst_reg->type == CONST_IMM && dst_reg->imm == insn->imm) {
 		if (opcode == BPF_JEQ) {
 			/* if (imm == imm) goto pc+off;
 			 * only follow the goto, ignore fall-through
@@ -1329,9 +1331,8 @@ static int check_cond_jmp_op(struct verifier_env *env,
 
 	/* detect if R == 0 where R is returned value from bpf_map_lookup_elem() */
 	if (BPF_SRC(insn->code) == BPF_K &&
-	    insn->imm == 0 && (opcode == BPF_JEQ ||
-			       opcode == BPF_JNE) &&
-	    regs[insn->dst_reg].type == PTR_TO_MAP_VALUE_OR_NULL) {
+	    insn->imm == 0 && (opcode == BPF_JEQ || opcode == BPF_JNE) &&
+	    dst_reg->type == PTR_TO_MAP_VALUE_OR_NULL) {
 		if (opcode == BPF_JEQ) {
 			/* next fallthrough insn can access memory via
 			 * this register
@@ -1366,7 +1367,7 @@ static int check_cond_jmp_op(struct verifier_env *env,
 		}
 	}
 	if (log_level)
-		print_verifier_state(env);
+		print_verifier_state(&env->cur_state);
 	return 0;
 }
 
@@ -1444,14 +1445,14 @@ static int check_ld_abs(struct verifier_env *env, struct bpf_insn *insn)
 	int i, err;
 
 	if (!may_access_skb(env->prog->type)) {
-		verbose("BPF_LD_ABS|IND instructions not allowed for this program type\n");
+		verbose("BPF_LD_[ABS|IND] instructions not allowed for this program type\n");
 		return -EINVAL;
 	}
 
 	if (insn->dst_reg != BPF_REG_0 || insn->off != 0 ||
 	    BPF_SIZE(insn->code) == BPF_DW ||
 	    (mode == BPF_ABS && insn->src_reg != BPF_REG_0)) {
-		verbose("BPF_LD_ABS uses reserved fields\n");
+		verbose("BPF_LD_[ABS|IND] uses reserved fields\n");
 		return -EINVAL;
 	}
 
@@ -1712,17 +1713,21 @@ err_free:
  */
 static bool states_equal(struct verifier_state *old, struct verifier_state *cur)
 {
+	struct reg_state *rold, *rcur;
 	int i;
 
 	for (i = 0; i < MAX_BPF_REG; i++) {
-		if (memcmp(&old->regs[i], &cur->regs[i],
-			   sizeof(old->regs[0])) != 0) {
-			if (old->regs[i].type == NOT_INIT ||
-			    (old->regs[i].type == UNKNOWN_VALUE &&
-			     cur->regs[i].type != NOT_INIT))
-				continue;
-			return false;
-		}
+		rold = &old->regs[i];
+		rcur = &cur->regs[i];
+
+		if (memcmp(rold, rcur, sizeof(*rold)) == 0)
+			continue;
+
+		if (rold->type == NOT_INIT ||
+		    (rold->type == UNKNOWN_VALUE && rcur->type != NOT_INIT))
+			continue;
+
+		return false;
 	}
 
 	for (i = 0; i < MAX_BPF_STACK; i++) {
@@ -1844,7 +1849,7 @@ static int do_check(struct verifier_env *env)
 
 		if (log_level && do_print_state) {
 			verbose("\nfrom %d to %d:", prev_insn_idx, insn_idx);
-			print_verifier_state(env);
+			print_verifier_state(&env->cur_state);
 			do_print_state = false;
 		}
 
@@ -2056,6 +2061,7 @@ process_bpf_exit:
 		insn_idx++;
 	}
 
+	verbose("processed %d insns\n", insn_processed);
 	return 0;
 }
 
-- 
2.8.0
