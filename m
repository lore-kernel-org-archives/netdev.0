From: Josef Bacik <jbacik@fb.com>
Subject: [PATCH net-next v5] bpf: allow access into map value arrays
Date: Wed, 28 Sep 2016 10:54:32 -0400
Message-ID: <1475074472-23538-1-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <daniel@iogearbox.net>, <tgraf@suug.ch>,
        <netdev@vger.kernel.org>, <kernel-team@fb.com>,
        <u9012063@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:39870 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932319AbcI1OzL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 10:55:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Suppose you have a map array value that is something like this

struct foo {
	unsigned iter;
	int array[SOME_CONSTANT];
};

You can easily insert this into an array, but you cannot modify the contents of
foo->array[] after the fact.  This is because we have no way to verify we won't
go off the end of the array at verification time.  This patch provides a start
for this work.  We accomplish this by keeping track of a minimum and maximum
value a register could be while we're checking the code.  Then at the time we
try to do an access into a MAP_VALUE we verify that the maximum offset into that
region is a valid access into that memory region.  So in practice, code such as
this

unsigned index = 0;

if (foo->iter >= SOME_CONSTANT)
	foo->iter = index;
else
	index = foo->iter++;
foo->array[index] = bar;

would be allowed, as we can verify that index will always be between 0 and
SOME_CONSTANT-1.  If you wish to use signed values you'll have to have an extra
check to make sure the index isn't less than 0, or do something like index %=
SOME_CONSTANT.

Signed-off-by: Josef Bacik <jbacik@fb.com>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
V4->V5:
-rebased onto net-next.
-dealt with adding map values to other map values, made it so we only adjust
 min/max if we are messing with CONST or INV variables, otherwise we set it to
 RANGE_MIN/RANGE_MAX.
-added a new testcase for the adding map values to map values case.
-moved a reset of the register values until after the register validation checks
 for BPF_LD

V3->V4:
-fixed the alignment check to deal with MAP_VALUE_ADJ properly.
-updated the error messages for invalid ranges to be more clear.
-fixed test_verifier.c to work with the updated error messages.
-fixed a couple of typos.

V2->V3:
-added testcases to test_verifier.c
-fixed a problem where we wouldn't adjust min/max values if the val == *_RANGE
  values, which would cause us to think any access to the map was a-ok.
-Handle the case where the CONST_IMM register is the dst_reg instead of the
  src_reg.
-Deal with overflows from the jmp handling.
-Fixed the states_equal logic to make more sense.

V1->V2:
-Instead of using (u64)-1 as the limit which could overflow in some cases
 and give us weird behavior, make the limit 1gib so that any math doesn't
 overflow and it's still outside of the realm of reasonable offsets.

 include/linux/bpf.h          |   7 +
 include/linux/bpf_verifier.h |  12 ++
 kernel/bpf/verifier.c        | 329 ++++++++++++++++++++++++++++++++++++++++---
 samples/bpf/libbpf.h         |   8 ++
 samples/bpf/test_verifier.c  | 243 +++++++++++++++++++++++++++++++-
 5 files changed, 577 insertions(+), 22 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 5691fdc..c201017 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -139,6 +139,13 @@ enum bpf_reg_type {
 	 */
 	PTR_TO_PACKET,
 	PTR_TO_PACKET_END,	 /* skb->data + headlen */
+
+	/* PTR_TO_MAP_VALUE_ADJ is used for doing pointer math inside of a map
+	 * elem value.  We only allow this if we can statically verify that
+	 * access from this register are going to fall within the size of the
+	 * map element.
+	 */
+	PTR_TO_MAP_VALUE_ADJ,
 };
 
 struct bpf_prog;
diff --git a/include/linux/bpf_verifier.h b/include/linux/bpf_verifier.h
index c5cb661..7035b99 100644
--- a/include/linux/bpf_verifier.h
+++ b/include/linux/bpf_verifier.h
@@ -10,8 +10,19 @@
 #include <linux/bpf.h> /* for enum bpf_reg_type */
 #include <linux/filter.h> /* for MAX_BPF_STACK */
 
+ /* Just some arbitrary values so we can safely do math without overflowing and
+  * are obviously wrong for any sort of memory access.
+  */
+#define BPF_REGISTER_MAX_RANGE (1024 * 1024 * 1024)
+#define BPF_REGISTER_MIN_RANGE -(1024 * 1024 * 1024)
+
 struct bpf_reg_state {
 	enum bpf_reg_type type;
+	/*
+	 * Used to determine if any memory access using this register will
+	 * result in a bad access.
+	 */
+	u64 min_value, max_value;
 	union {
 		/* valid when type == CONST_IMM | PTR_TO_STACK | UNKNOWN_VALUE */
 		s64 imm;
@@ -81,6 +92,7 @@ struct bpf_verifier_env {
 	u32 id_gen;			/* used to generate unique reg IDs */
 	bool allow_ptr_leaks;
 	bool seen_direct_write;
+	bool varlen_map_value_access;
 	struct bpf_insn_aux_data *insn_aux_data; /* array of per-insn state */
 };
 
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 7ada315..99a7e5b 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -182,6 +182,7 @@ static const char * const reg_type_str[] = {
 	[CONST_PTR_TO_MAP]	= "map_ptr",
 	[PTR_TO_MAP_VALUE]	= "map_value",
 	[PTR_TO_MAP_VALUE_OR_NULL] = "map_value_or_null",
+	[PTR_TO_MAP_VALUE_ADJ]	= "map_value_adj",
 	[FRAME_PTR]		= "fp",
 	[PTR_TO_STACK]		= "fp",
 	[CONST_IMM]		= "imm",
@@ -209,10 +210,17 @@ static void print_verifier_state(struct bpf_verifier_state *state)
 		else if (t == UNKNOWN_VALUE && reg->imm)
 			verbose("%lld", reg->imm);
 		else if (t == CONST_PTR_TO_MAP || t == PTR_TO_MAP_VALUE ||
-			 t == PTR_TO_MAP_VALUE_OR_NULL)
+			 t == PTR_TO_MAP_VALUE_OR_NULL ||
+			 t == PTR_TO_MAP_VALUE_ADJ)
 			verbose("(ks=%d,vs=%d)",
 				reg->map_ptr->key_size,
 				reg->map_ptr->value_size);
+		if (reg->min_value != BPF_REGISTER_MIN_RANGE)
+			verbose(",min_value=%llu",
+				(unsigned long long)reg->min_value);
+		if (reg->max_value != BPF_REGISTER_MAX_RANGE)
+			verbose(",max_value=%llu",
+				(unsigned long long)reg->max_value);
 	}
 	for (i = 0; i < MAX_BPF_STACK; i += BPF_REG_SIZE) {
 		if (state->stack_slot_type[i] == STACK_SPILL)
@@ -424,6 +432,8 @@ static void init_reg_state(struct bpf_reg_state *regs)
 	for (i = 0; i < MAX_BPF_REG; i++) {
 		regs[i].type = NOT_INIT;
 		regs[i].imm = 0;
+		regs[i].min_value = BPF_REGISTER_MIN_RANGE;
+		regs[i].max_value = BPF_REGISTER_MAX_RANGE;
 	}
 
 	/* frame pointer */
@@ -440,6 +450,12 @@ static void mark_reg_unknown_value(struct bpf_reg_state *regs, u32 regno)
 	regs[regno].imm = 0;
 }
 
+static void reset_reg_range_values(struct bpf_reg_state *regs, u32 regno)
+{
+	regs[regno].min_value = BPF_REGISTER_MIN_RANGE;
+	regs[regno].max_value = BPF_REGISTER_MAX_RANGE;
+}
+
 enum reg_arg_type {
 	SRC_OP,		/* register is used as source operand */
 	DST_OP,		/* register is used as destination operand */
@@ -665,7 +681,7 @@ static bool is_pointer_value(struct bpf_verifier_env *env, int regno)
 static int check_ptr_alignment(struct bpf_verifier_env *env,
 			       struct bpf_reg_state *reg, int off, int size)
 {
-	if (reg->type != PTR_TO_PACKET) {
+	if (reg->type != PTR_TO_PACKET && reg->type != PTR_TO_MAP_VALUE_ADJ) {
 		if (off % size != 0) {
 			verbose("misaligned access off %d size %d\n",
 				off, size);
@@ -675,16 +691,6 @@ static int check_ptr_alignment(struct bpf_verifier_env *env,
 		}
 	}
 
-	switch (env->prog->type) {
-	case BPF_PROG_TYPE_SCHED_CLS:
-	case BPF_PROG_TYPE_SCHED_ACT:
-	case BPF_PROG_TYPE_XDP:
-		break;
-	default:
-		verbose("verifier is misconfigured\n");
-		return -EACCES;
-	}
-
 	if (IS_ENABLED(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS))
 		/* misaligned access to packet is ok on x86,arm,arm64 */
 		return 0;
@@ -695,7 +701,8 @@ static int check_ptr_alignment(struct bpf_verifier_env *env,
 	}
 
 	/* skb->data is NET_IP_ALIGN-ed */
-	if ((NET_IP_ALIGN + reg->off + off) % size != 0) {
+	if (reg->type == PTR_TO_PACKET &&
+	    (NET_IP_ALIGN + reg->off + off) % size != 0) {
 		verbose("misaligned packet access off %d+%d+%d size %d\n",
 			NET_IP_ALIGN, reg->off, off, size);
 		return -EACCES;
@@ -728,12 +735,52 @@ static int check_mem_access(struct bpf_verifier_env *env, u32 regno, int off,
 	if (err)
 		return err;
 
-	if (reg->type == PTR_TO_MAP_VALUE) {
+	if (reg->type == PTR_TO_MAP_VALUE ||
+	    reg->type == PTR_TO_MAP_VALUE_ADJ) {
 		if (t == BPF_WRITE && value_regno >= 0 &&
 		    is_pointer_value(env, value_regno)) {
 			verbose("R%d leaks addr into map\n", value_regno);
 			return -EACCES;
 		}
+
+		/* If we adjusted the register to this map value at all then we
+		 * need to change off and size to min_value and max_value
+		 * respectively to make sure our theoretical access will be
+		 * safe.
+		 */
+		if (reg->type == PTR_TO_MAP_VALUE_ADJ) {
+			if (log_level)
+				print_verifier_state(state);
+			env->varlen_map_value_access = true;
+			/* The minimum value is only important with signed
+			 * comparisons where we can't assume the floor of a
+			 * value is 0.  If we are using signed variables for our
+			 * index'es we need to make sure that whatever we use
+			 * will have a set floor within our range.
+			 */
+			if ((s64)reg->min_value < 0) {
+				verbose("R%d min value is negative, either use unsigned index or do a if (index >=0) check.\n",
+					regno);
+				return -EACCES;
+			}
+			err = check_map_access(env, regno, reg->min_value + off,
+					       size);
+			if (err) {
+				verbose("R%d min value is outside of the array range\n",
+					regno);
+				return err;
+			}
+
+			/* If we haven't set a max value then we need to bail
+			 * since we can't be sure we won't do bad things.
+			 */
+			if (reg->max_value == BPF_REGISTER_MAX_RANGE) {
+				verbose("R%d unbounded memory access, make sure to bounds check any array access into a map\n",
+					regno);
+				return -EACCES;
+			}
+			off += reg->max_value;
+		}
 		err = check_map_access(env, regno, off, size);
 		if (!err && t == BPF_READ && value_regno >= 0)
 			mark_reg_unknown_value(state->regs, value_regno);
@@ -1195,6 +1242,7 @@ static int check_call(struct bpf_verifier_env *env, int func_id)
 		regs[BPF_REG_0].type = NOT_INIT;
 	} else if (fn->ret_type == RET_PTR_TO_MAP_VALUE_OR_NULL) {
 		regs[BPF_REG_0].type = PTR_TO_MAP_VALUE_OR_NULL;
+		regs[BPF_REG_0].max_value = regs[BPF_REG_0].min_value = 0;
 		/* remember map_ptr, so that check_map_access()
 		 * can check 'value_size' boundary of memory access
 		 * to map element returned from bpf_map_lookup_elem()
@@ -1416,6 +1464,106 @@ static int evaluate_reg_imm_alu(struct bpf_verifier_env *env,
 	return 0;
 }
 
+static void check_reg_overflow(struct bpf_reg_state *reg)
+{
+	if (reg->max_value > BPF_REGISTER_MAX_RANGE)
+		reg->max_value = BPF_REGISTER_MAX_RANGE;
+	if ((s64)reg->min_value < BPF_REGISTER_MIN_RANGE)
+		reg->min_value = BPF_REGISTER_MIN_RANGE;
+}
+
+static void adjust_reg_min_max_vals(struct bpf_verifier_env *env,
+				    struct bpf_insn *insn)
+{
+	struct bpf_reg_state *regs = env->cur_state.regs, *dst_reg;
+	u64 min_val = BPF_REGISTER_MIN_RANGE, max_val = BPF_REGISTER_MAX_RANGE;
+	bool min_set = false, max_set = false;
+	u8 opcode = BPF_OP(insn->code);
+
+	dst_reg = &regs[insn->dst_reg];
+	if (BPF_SRC(insn->code) == BPF_X) {
+		check_reg_overflow(&regs[insn->src_reg]);
+		min_val = regs[insn->src_reg].min_value;
+		max_val = regs[insn->src_reg].max_value;
+
+		/* If the source register is a random pointer then the
+		 * min_value/max_value values represent the range of the known
+		 * accesses into that value, not the actual min/max value of the
+		 * register itself.  In this case we have to reset the reg range
+		 * values so we know it is not safe to look at.
+		 */
+		if (regs[insn->src_reg].type != CONST_IMM &&
+		    regs[insn->src_reg].type != UNKNOWN_VALUE) {
+			min_val = BPF_REGISTER_MIN_RANGE;
+			max_val = BPF_REGISTER_MAX_RANGE;
+		}
+	} else if (insn->imm < BPF_REGISTER_MAX_RANGE &&
+		   (s64)insn->imm > BPF_REGISTER_MIN_RANGE) {
+		min_val = max_val = insn->imm;
+		min_set = max_set = true;
+	}
+
+	/* We don't know anything about what was done to this register, mark it
+	 * as unknown.
+	 */
+	if (min_val == BPF_REGISTER_MIN_RANGE &&
+	    max_val == BPF_REGISTER_MAX_RANGE) {
+		reset_reg_range_values(regs, insn->dst_reg);
+		return;
+	}
+
+	switch (opcode) {
+	case BPF_ADD:
+		dst_reg->min_value += min_val;
+		dst_reg->max_value += max_val;
+		break;
+	case BPF_SUB:
+		dst_reg->min_value -= min_val;
+		dst_reg->max_value -= max_val;
+		break;
+	case BPF_MUL:
+		dst_reg->min_value *= min_val;
+		dst_reg->max_value *= max_val;
+		break;
+	case BPF_AND:
+		/* & is special since it could end up with 0 bits set. */
+		dst_reg->min_value &= min_val;
+		dst_reg->max_value = max_val;
+		break;
+	case BPF_LSH:
+		/* Gotta have special overflow logic here, if we're shifting
+		 * more than MAX_RANGE then just assume we have an invalid
+		 * range.
+		 */
+		if (min_val > ilog2(BPF_REGISTER_MAX_RANGE))
+			dst_reg->min_value = BPF_REGISTER_MIN_RANGE;
+		else
+			dst_reg->min_value <<= min_val;
+
+		if (max_val > ilog2(BPF_REGISTER_MAX_RANGE))
+			dst_reg->max_value = BPF_REGISTER_MAX_RANGE;
+		else
+			dst_reg->max_value <<= max_val;
+		break;
+	case BPF_RSH:
+		dst_reg->min_value >>= min_val;
+		dst_reg->max_value >>= max_val;
+		break;
+	case BPF_MOD:
+		/* % is special since it is an unsigned modulus, so the floor
+		 * will always be 0.
+		 */
+		dst_reg->min_value = 0;
+		dst_reg->max_value = max_val - 1;
+		break;
+	default:
+		reset_reg_range_values(regs, insn->dst_reg);
+		break;
+	}
+
+	check_reg_overflow(dst_reg);
+}
+
 /* check validity of 32-bit and 64-bit arithmetic operations */
 static int check_alu_op(struct bpf_verifier_env *env, struct bpf_insn *insn)
 {
@@ -1479,6 +1627,11 @@ static int check_alu_op(struct bpf_verifier_env *env, struct bpf_insn *insn)
 		if (err)
 			return err;
 
+		/* we are setting our register to something new, we need to
+		 * reset its range values.
+		 */
+		reset_reg_range_values(regs, insn->dst_reg);
+
 		if (BPF_SRC(insn->code) == BPF_X) {
 			if (BPF_CLASS(insn->code) == BPF_ALU64) {
 				/* case: R1 = R2
@@ -1500,6 +1653,8 @@ static int check_alu_op(struct bpf_verifier_env *env, struct bpf_insn *insn)
 			 */
 			regs[insn->dst_reg].type = CONST_IMM;
 			regs[insn->dst_reg].imm = insn->imm;
+			regs[insn->dst_reg].max_value = insn->imm;
+			regs[insn->dst_reg].min_value = insn->imm;
 		}
 
 	} else if (opcode > BPF_END) {
@@ -1552,6 +1707,9 @@ static int check_alu_op(struct bpf_verifier_env *env, struct bpf_insn *insn)
 
 		dst_reg = &regs[insn->dst_reg];
 
+		/* first we want to adjust our ranges. */
+		adjust_reg_min_max_vals(env, insn);
+
 		/* pattern match 'bpf_add Rx, imm' instruction */
 		if (opcode == BPF_ADD && BPF_CLASS(insn->code) == BPF_ALU64 &&
 		    dst_reg->type == FRAME_PTR && BPF_SRC(insn->code) == BPF_K) {
@@ -1586,8 +1744,17 @@ static int check_alu_op(struct bpf_verifier_env *env, struct bpf_insn *insn)
 			return -EACCES;
 		}
 
-		/* mark dest operand */
-		mark_reg_unknown_value(regs, insn->dst_reg);
+		/* If we did pointer math on a map value then just set it to our
+		 * PTR_TO_MAP_VALUE_ADJ type so we can deal with any stores or
+		 * loads to this register appropriately, otherwise just mark the
+		 * register as unknown.
+		 */
+		if (env->allow_ptr_leaks &&
+		    (dst_reg->type == PTR_TO_MAP_VALUE ||
+		     dst_reg->type == PTR_TO_MAP_VALUE_ADJ))
+			dst_reg->type = PTR_TO_MAP_VALUE_ADJ;
+		else
+			mark_reg_unknown_value(regs, insn->dst_reg);
 	}
 
 	return 0;
@@ -1642,6 +1809,104 @@ static void find_good_pkt_pointers(struct bpf_verifier_state *state,
 	}
 }
 
+/* Adjusts the register min/max values in the case that the dst_reg is the
+ * variable register that we are working on, and src_reg is a constant or we're
+ * simply doing a BPF_K check.
+ */
+static void reg_set_min_max(struct bpf_reg_state *true_reg,
+			    struct bpf_reg_state *false_reg, u64 val,
+			    u8 opcode)
+{
+	switch (opcode) {
+	case BPF_JEQ:
+		/* If this is false then we know nothing Jon Snow, but if it is
+		 * true then we know for sure.
+		 */
+		true_reg->max_value = true_reg->min_value = val;
+		break;
+	case BPF_JNE:
+		/* If this is true we know nothing Jon Snow, but if it is false
+		 * we know the value for sure;
+		 */
+		false_reg->max_value = false_reg->min_value = val;
+		break;
+	case BPF_JGT:
+		/* Unsigned comparison, the minimum value is 0. */
+		false_reg->min_value = 0;
+	case BPF_JSGT:
+		/* If this is false then we know the maximum val is val,
+		 * otherwise we know the min val is val+1.
+		 */
+		false_reg->max_value = val;
+		true_reg->min_value = val + 1;
+		break;
+	case BPF_JGE:
+		/* Unsigned comparison, the minimum value is 0. */
+		false_reg->min_value = 0;
+	case BPF_JSGE:
+		/* If this is false then we know the maximum value is val - 1,
+		 * otherwise we know the mimimum value is val.
+		 */
+		false_reg->max_value = val - 1;
+		true_reg->min_value = val;
+		break;
+	default:
+		break;
+	}
+
+	check_reg_overflow(false_reg);
+	check_reg_overflow(true_reg);
+}
+
+/* Same as above, but for the case that dst_reg is a CONST_IMM reg and src_reg
+ * is the variable reg.
+ */
+static void reg_set_min_max_inv(struct bpf_reg_state *true_reg,
+				struct bpf_reg_state *false_reg, u64 val,
+				u8 opcode)
+{
+	switch (opcode) {
+	case BPF_JEQ:
+		/* If this is false then we know nothing Jon Snow, but if it is
+		 * true then we know for sure.
+		 */
+		true_reg->max_value = true_reg->min_value = val;
+		break;
+	case BPF_JNE:
+		/* If this is true we know nothing Jon Snow, but if it is false
+		 * we know the value for sure;
+		 */
+		false_reg->max_value = false_reg->min_value = val;
+		break;
+	case BPF_JGT:
+		/* Unsigned comparison, the minimum value is 0. */
+		true_reg->min_value = 0;
+	case BPF_JSGT:
+		/*
+		 * If this is false, then the val is <= the register, if it is
+		 * true the register <= to the val.
+		 */
+		false_reg->min_value = val;
+		true_reg->max_value = val - 1;
+		break;
+	case BPF_JGE:
+		/* Unsigned comparison, the minimum value is 0. */
+		true_reg->min_value = 0;
+	case BPF_JSGE:
+		/* If this is false then constant < register, if it is true then
+		 * the register < constant.
+		 */
+		false_reg->min_value = val + 1;
+		true_reg->max_value = val;
+		break;
+	default:
+		break;
+	}
+
+	check_reg_overflow(false_reg);
+	check_reg_overflow(true_reg);
+}
+
 static int check_cond_jmp_op(struct bpf_verifier_env *env,
 			     struct bpf_insn *insn, int *insn_idx)
 {
@@ -1708,6 +1973,23 @@ static int check_cond_jmp_op(struct bpf_verifier_env *env,
 	if (!other_branch)
 		return -EFAULT;
 
+	/* detect if we are comparing against a constant value so we can adjust
+	 * our min/max values for our dst register.
+	 */
+	if (BPF_SRC(insn->code) == BPF_X) {
+		if (regs[insn->src_reg].type == CONST_IMM)
+			reg_set_min_max(&other_branch->regs[insn->dst_reg],
+					dst_reg, regs[insn->src_reg].imm,
+					opcode);
+		else if (dst_reg->type == CONST_IMM)
+			reg_set_min_max_inv(&other_branch->regs[insn->src_reg],
+					    &regs[insn->src_reg], dst_reg->imm,
+					    opcode);
+	} else {
+		reg_set_min_max(&other_branch->regs[insn->dst_reg],
+					dst_reg, insn->imm, opcode);
+	}
+
 	/* detect if R == 0 where R is returned from bpf_map_lookup_elem() */
 	if (BPF_SRC(insn->code) == BPF_K &&
 	    insn->imm == 0 && (opcode == BPF_JEQ || opcode == BPF_JNE) &&
@@ -2144,7 +2426,8 @@ static bool compare_ptrs_to_packet(struct bpf_reg_state *old,
  * whereas register type in current state is meaningful, it means that
  * the current state will reach 'bpf_exit' instruction safely
  */
-static bool states_equal(struct bpf_verifier_state *old,
+static bool states_equal(struct bpf_verifier_env *env,
+			 struct bpf_verifier_state *old,
 			 struct bpf_verifier_state *cur)
 {
 	struct bpf_reg_state *rold, *rcur;
@@ -2157,6 +2440,13 @@ static bool states_equal(struct bpf_verifier_state *old,
 		if (memcmp(rold, rcur, sizeof(*rold)) == 0)
 			continue;
 
+		/* If the ranges were not the same, but everything else was and
+		 * we didn't do a variable access into a map then we are a-ok.
+		 */
+		if (!env->varlen_map_value_access &&
+		    rold->type == rcur->type && rold->imm == rcur->imm)
+			continue;
+
 		if (rold->type == NOT_INIT ||
 		    (rold->type == UNKNOWN_VALUE && rcur->type != NOT_INIT))
 			continue;
@@ -2213,7 +2503,7 @@ static int is_state_visited(struct bpf_verifier_env *env, int insn_idx)
 		return 0;
 
 	while (sl != STATE_LIST_MARK) {
-		if (states_equal(&sl->state, &env->cur_state))
+		if (states_equal(env, &sl->state, &env->cur_state))
 			/* reached equivalent register/stack state,
 			 * prune the search
 			 */
@@ -2259,6 +2549,7 @@ static int do_check(struct bpf_verifier_env *env)
 
 	init_reg_state(regs);
 	insn_idx = 0;
+	env->varlen_map_value_access = false;
 	for (;;) {
 		struct bpf_insn *insn;
 		u8 class;
@@ -2339,6 +2630,7 @@ static int do_check(struct bpf_verifier_env *env)
 			if (err)
 				return err;
 
+			reset_reg_range_values(regs, insn->dst_reg);
 			if (BPF_SIZE(insn->code) != BPF_W &&
 			    BPF_SIZE(insn->code) != BPF_DW) {
 				insn_idx++;
@@ -2509,6 +2801,7 @@ process_bpf_exit:
 				verbose("invalid BPF_LD mode\n");
 				return -EINVAL;
 			}
+			reset_reg_range_values(regs, insn->dst_reg);
 		} else {
 			verbose("unknown insn class %d\n", class);
 			return -EINVAL;
diff --git a/samples/bpf/libbpf.h b/samples/bpf/libbpf.h
index 364582b..ac6edb6 100644
--- a/samples/bpf/libbpf.h
+++ b/samples/bpf/libbpf.h
@@ -85,6 +85,14 @@ extern char bpf_log_buf[LOG_BUF_SIZE];
 		.off   = 0,					\
 		.imm   = IMM })
 
+#define BPF_MOV32_IMM(DST, IMM)					\
+	((struct bpf_insn) {					\
+		.code  = BPF_ALU | BPF_MOV | BPF_K,		\
+		.dst_reg = DST,					\
+		.src_reg = 0,					\
+		.off   = 0,					\
+		.imm   = IMM })
+
 /* BPF_LD_IMM64 macro encodes single 'load 64-bit immediate' insn */
 #define BPF_LD_IMM64(DST, IMM)					\
 	BPF_LD_IMM64_RAW(DST, 0, IMM)
diff --git a/samples/bpf/test_verifier.c b/samples/bpf/test_verifier.c
index ac590d4..369ffaa 100644
--- a/samples/bpf/test_verifier.c
+++ b/samples/bpf/test_verifier.c
@@ -29,6 +29,7 @@ struct bpf_test {
 	struct bpf_insn	insns[MAX_INSNS];
 	int fixup[MAX_FIXUPS];
 	int prog_array_fixup[MAX_FIXUPS];
+	int test_val_map_fixup[MAX_FIXUPS];
 	const char *errstr;
 	const char *errstr_unpriv;
 	enum {
@@ -39,6 +40,19 @@ struct bpf_test {
 	enum bpf_prog_type prog_type;
 };
 
+/* Note we want this to be 64 bit aligned so that the end of our array is
+ * actually the end of the structure.
+ */
+#define MAX_ENTRIES 11
+struct test_val {
+	unsigned index;
+	int foo[MAX_ENTRIES];
+};
+
+struct other_val {
+	unsigned int action[32];
+};
+
 static struct bpf_test tests[] = {
 	{
 		"add+sub+mul",
@@ -2163,6 +2177,212 @@ static struct bpf_test tests[] = {
 		.errstr = "invalid access to packet",
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 	},
+	{
+		"valid map access into an array with a constant",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, offsetof(struct test_val, foo)),
+			BPF_EXIT_INSN(),
+		},
+		.test_val_map_fixup = {3},
+		.errstr_unpriv = "R0 leaks addr",
+		.result_unpriv = REJECT,
+		.result = ACCEPT,
+	},
+	{
+		"valid map access into an array with a register",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 4),
+			BPF_MOV64_IMM(BPF_REG_1, 4),
+			BPF_ALU64_IMM(BPF_LSH, BPF_REG_1, 2),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, offsetof(struct test_val, foo)),
+			BPF_EXIT_INSN(),
+		},
+		.test_val_map_fixup = {3},
+		.errstr_unpriv = "R0 leaks addr",
+		.result_unpriv = REJECT,
+		.result = ACCEPT,
+	},
+	{
+		"valid map access into an array with a variable",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 5),
+			BPF_LDX_MEM(BPF_W, BPF_REG_1, BPF_REG_0, 0),
+			BPF_JMP_IMM(BPF_JGE, BPF_REG_1, MAX_ENTRIES, 3),
+			BPF_ALU64_IMM(BPF_LSH, BPF_REG_1, 2),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, offsetof(struct test_val, foo)),
+			BPF_EXIT_INSN(),
+		},
+		.test_val_map_fixup = {3},
+		.errstr_unpriv = "R0 leaks addr",
+		.result_unpriv = REJECT,
+		.result = ACCEPT,
+	},
+	{
+		"valid map access into an array with a signed variable",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 9),
+			BPF_LDX_MEM(BPF_W, BPF_REG_1, BPF_REG_0, 0),
+			BPF_JMP_IMM(BPF_JSGT, BPF_REG_1, 0xffffffff, 1),
+			BPF_MOV32_IMM(BPF_REG_1, 0),
+			BPF_MOV32_IMM(BPF_REG_2, MAX_ENTRIES),
+			BPF_JMP_REG(BPF_JSGT, BPF_REG_2, BPF_REG_1, 1),
+			BPF_MOV32_IMM(BPF_REG_1, 0),
+			BPF_ALU32_IMM(BPF_LSH, BPF_REG_1, 2),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, offsetof(struct test_val, foo)),
+			BPF_EXIT_INSN(),
+		},
+		.test_val_map_fixup = {3},
+		.errstr_unpriv = "R0 leaks addr",
+		.result_unpriv = REJECT,
+		.result = ACCEPT,
+	},
+	{
+		"invalid map access into an array with a constant",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, (MAX_ENTRIES + 1) << 2,
+				   offsetof(struct test_val, foo)),
+			BPF_EXIT_INSN(),
+		},
+		.test_val_map_fixup = {3},
+		.errstr = "invalid access to map value, value_size=48 off=48 size=8",
+		.result = REJECT,
+	},
+	{
+		"invalid map access into an array with a register",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 4),
+			BPF_MOV64_IMM(BPF_REG_1, MAX_ENTRIES + 1),
+			BPF_ALU64_IMM(BPF_LSH, BPF_REG_1, 2),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, offsetof(struct test_val, foo)),
+			BPF_EXIT_INSN(),
+		},
+		.test_val_map_fixup = {3},
+		.errstr = "R0 min value is outside of the array range",
+		.result = REJECT,
+	},
+	{
+		"invalid map access into an array with a variable",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 4),
+			BPF_LDX_MEM(BPF_W, BPF_REG_1, BPF_REG_0, 0),
+			BPF_ALU64_IMM(BPF_LSH, BPF_REG_1, 2),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, offsetof(struct test_val, foo)),
+			BPF_EXIT_INSN(),
+		},
+		.test_val_map_fixup = {3},
+		.errstr = "R0 min value is negative, either use unsigned index or do a if (index >=0) check.",
+		.result = REJECT,
+	},
+	{
+		"invalid map access into an array with no floor check",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 7),
+			BPF_LDX_MEM(BPF_W, BPF_REG_1, BPF_REG_0, 0),
+			BPF_MOV32_IMM(BPF_REG_2, MAX_ENTRIES),
+			BPF_JMP_REG(BPF_JSGT, BPF_REG_2, BPF_REG_1, 1),
+			BPF_MOV32_IMM(BPF_REG_1, 0),
+			BPF_ALU32_IMM(BPF_LSH, BPF_REG_1, 2),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, offsetof(struct test_val, foo)),
+			BPF_EXIT_INSN(),
+		},
+		.test_val_map_fixup = {3},
+		.errstr = "R0 min value is negative, either use unsigned index or do a if (index >=0) check.",
+		.result = REJECT,
+	},
+	{
+		"invalid map access into an array with a invalid max check",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 7),
+			BPF_LDX_MEM(BPF_W, BPF_REG_1, BPF_REG_0, 0),
+			BPF_MOV32_IMM(BPF_REG_2, MAX_ENTRIES + 1),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_2, BPF_REG_1, 1),
+			BPF_MOV32_IMM(BPF_REG_1, 0),
+			BPF_ALU32_IMM(BPF_LSH, BPF_REG_1, 2),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, offsetof(struct test_val, foo)),
+			BPF_EXIT_INSN(),
+		},
+		.test_val_map_fixup = {3},
+		.errstr = "invalid access to map value, value_size=48 off=44 size=8",
+		.result = REJECT,
+	},
+	{
+		"invalid map access into an array with a invalid max check",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 10),
+			BPF_MOV64_REG(BPF_REG_8, BPF_REG_0),
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 2),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_8),
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_0, offsetof(struct test_val, foo)),
+			BPF_EXIT_INSN(),
+		},
+		.test_val_map_fixup = {3, 11},
+		.errstr = "R0 min value is negative, either use unsigned index or do a if (index >=0) check.",
+		.result = REJECT,
+	},
 };
 
 static int probe_filter_length(struct bpf_insn *fp)
@@ -2176,12 +2396,12 @@ static int probe_filter_length(struct bpf_insn *fp)
 	return len + 1;
 }
 
-static int create_map(void)
+static int create_map(size_t val_size, int num)
 {
 	int map_fd;
 
 	map_fd = bpf_create_map(BPF_MAP_TYPE_HASH,
-				sizeof(long long), sizeof(long long), 1024, 0);
+				sizeof(long long), val_size, num, 0);
 	if (map_fd < 0)
 		printf("failed to create map '%s'\n", strerror(errno));
 
@@ -2211,12 +2431,13 @@ static int test(void)
 		int prog_len = probe_filter_length(prog);
 		int *fixup = tests[i].fixup;
 		int *prog_array_fixup = tests[i].prog_array_fixup;
+		int *test_val_map_fixup = tests[i].test_val_map_fixup;
 		int expected_result;
 		const char *expected_errstr;
-		int map_fd = -1, prog_array_fd = -1;
+		int map_fd = -1, prog_array_fd = -1, test_val_map_fd = -1;
 
 		if (*fixup) {
-			map_fd = create_map();
+			map_fd = create_map(sizeof(long long), 1024);
 
 			do {
 				prog[*fixup].imm = map_fd;
@@ -2231,6 +2452,18 @@ static int test(void)
 				prog_array_fixup++;
 			} while (*prog_array_fixup);
 		}
+		if (*test_val_map_fixup) {
+			/* Unprivileged can't create a hash map.*/
+			if (unpriv)
+				continue;
+			test_val_map_fd = create_map(sizeof(struct test_val),
+						     256);
+			do {
+				prog[*test_val_map_fixup].imm = test_val_map_fd;
+				test_val_map_fixup++;
+			} while (*test_val_map_fixup);
+		}
+
 		printf("#%d %s ", i, tests[i].descr);
 
 		prog_fd = bpf_prog_load(prog_type ?: BPF_PROG_TYPE_SOCKET_FILTER,
@@ -2277,6 +2510,8 @@ fail:
 			close(map_fd);
 		if (prog_array_fd >= 0)
 			close(prog_array_fd);
+		if (test_val_map_fd >= 0)
+			close(test_val_map_fd);
 		close(prog_fd);
 
 	}
-- 
2.7.4
