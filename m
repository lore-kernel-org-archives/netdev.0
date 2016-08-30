From: Josef Bacik <jbacik@fb.com>
Subject: [PATCH] Bpf: allow access into map value arrays
Date: Tue, 30 Aug 2016 09:26:44 -0400
Message-ID: <1472563604-8548-1-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <ast@fb.com>, <tgraf@suug.ch>, <daniel@iogearbox.net>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <kernel-team@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Suppose you have a map array value that is somethihng like this

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
SOME_CONSTANT-1.

The limitation of this patch is it only works with unsigned.  With signed values
the llvm compiler generates code that can't easily be adapted to this approach,
so simply making unsigned index = 0 an int index = 0 will still cause the
verifier to reject the program.  This will be fixed in an upcoming patch.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 include/linux/bpf.h   |   7 ++
 kernel/bpf/verifier.c | 297 +++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 298 insertions(+), 6 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 1113423..ed747f3 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -138,6 +138,13 @@ enum bpf_reg_type {
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
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index f72f23b..a7a4678 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -128,6 +128,13 @@
 
 struct reg_state {
 	enum bpf_reg_type type;
+
+	/*
+	 * Used to determine if any memory access using this register will
+	 * result in a bad access.
+	 */
+	u64 min_value, max_value;
+	bool min_set, max_set;
 	union {
 		/* valid when type == CONST_IMM | PTR_TO_STACK | UNKNOWN_VALUE */
 		s64 imm;
@@ -195,6 +202,7 @@ struct verifier_env {
 	struct bpf_map *used_maps[MAX_USED_MAPS]; /* array of map's used by eBPF program */
 	u32 used_map_cnt;		/* number of used maps */
 	bool allow_ptr_leaks;
+	bool memory_access;
 };
 
 #define BPF_COMPLEXITY_LIMIT_INSNS	65536
@@ -239,6 +247,7 @@ static const char * const reg_type_str[] = {
 	[CONST_PTR_TO_MAP]	= "map_ptr",
 	[PTR_TO_MAP_VALUE]	= "map_value",
 	[PTR_TO_MAP_VALUE_OR_NULL] = "map_value_or_null",
+	[PTR_TO_MAP_VALUE_ADJ]	= "map_value_adj",
 	[FRAME_PTR]		= "fp",
 	[PTR_TO_STACK]		= "fp",
 	[CONST_IMM]		= "imm",
@@ -266,10 +275,17 @@ static void print_verifier_state(struct verifier_state *state)
 		else if (t == UNKNOWN_VALUE && reg->imm)
 			verbose("%lld", reg->imm);
 		else if (t == CONST_PTR_TO_MAP || t == PTR_TO_MAP_VALUE ||
-			 t == PTR_TO_MAP_VALUE_OR_NULL)
+			 t == PTR_TO_MAP_VALUE_OR_NULL ||
+			 t == PTR_TO_MAP_VALUE_ADJ)
 			verbose("(ks=%d,vs=%d)",
 				reg->map_ptr->key_size,
 				reg->map_ptr->value_size);
+		if (reg->min_set)
+			verbose(",min_value=%llu",
+				(unsigned long long)reg->min_value);
+		if (reg->max_set)
+			verbose(",max_value=%llu",
+				(unsigned long long)reg->max_value);
 	}
 	for (i = 0; i < MAX_BPF_STACK; i += BPF_REG_SIZE) {
 		if (state->stack_slot_type[i] == STACK_SPILL)
@@ -481,6 +497,10 @@ static void init_reg_state(struct reg_state *regs)
 	for (i = 0; i < MAX_BPF_REG; i++) {
 		regs[i].type = NOT_INIT;
 		regs[i].imm = 0;
+		regs[i].min_value = 0;
+		regs[i].max_value = (u64)-1;
+		regs[i].min_set = false;
+		regs[i].max_set = false;
 	}
 
 	/* frame pointer */
@@ -497,6 +517,14 @@ static void mark_reg_unknown_value(struct reg_state *regs, u32 regno)
 	regs[regno].imm = 0;
 }
 
+static void reset_reg_range_values(struct reg_state *regs, u32 regno)
+{
+	regs[regno].min_value = 0;
+	regs[regno].max_value = (u64)-1;
+	regs[regno].min_set = false;
+	regs[regno].max_set = false;
+}
+
 enum reg_arg_type {
 	SRC_OP,		/* register is used as source operand */
 	DST_OP,		/* register is used as destination operand */
@@ -773,12 +801,46 @@ static int check_mem_access(struct verifier_env *env, u32 regno, int off,
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
+			env->memory_access = true;
+			/* The minimum value is only important with signed
+			 * comparisons where we can't assume the floor of a
+			 * value is 0.  If we are using signed variables for our
+			 * index'es we need to make sure that whatever we use
+			 * will have a set floor within our range.
+			 */
+			if (reg->min_set) {
+				err = check_map_access(env, regno,
+						       reg->min_value, size);
+				if (err)
+					return err;
+			}
+
+			/* If we haven't set a max value then we need to bail
+			 * since we can't be sure we won't do bad things.
+			 */
+			if (!reg->max_set) {
+				verbose("R%d unbounded memory access\n",
+					value_regno);
+				return -EACCES;
+			}
+			off = reg->max_value;
+		}
 		err = check_map_access(env, regno, off, size);
 		if (!err && t == BPF_READ && value_regno >= 0)
 			mark_reg_unknown_value(state->regs, value_regno);
@@ -1213,6 +1275,8 @@ static int check_call(struct verifier_env *env, int func_id)
 		regs[BPF_REG_0].type = NOT_INIT;
 	} else if (fn->ret_type == RET_PTR_TO_MAP_VALUE_OR_NULL) {
 		regs[BPF_REG_0].type = PTR_TO_MAP_VALUE_OR_NULL;
+		regs[BPF_REG_0].max_set = regs[BPF_REG_0].min_set = true;
+		regs[BPF_REG_0].max_value = regs[BPF_REG_0].min_value = 0;
 		/* remember map_ptr, so that check_map_access()
 		 * can check 'value_size' boundary of memory access
 		 * to map element returned from bpf_map_lookup_elem()
@@ -1432,6 +1496,119 @@ static int evaluate_reg_imm_alu(struct verifier_env *env, struct bpf_insn *insn)
 	return 0;
 }
 
+static void adjust_reg_min_max_vals(struct verifier_env *env,
+				    struct bpf_insn *insn)
+{
+	struct reg_state *regs = env->cur_state.regs, *dst_reg;
+	u64 min_val, max_val;
+	bool min_set = false, max_set = false;
+	u8 opcode = BPF_OP(insn->code);
+
+	dst_reg = &regs[insn->dst_reg];
+
+	if (BPF_SRC(insn->code) == BPF_X) {
+		if (regs[insn->src_reg].min_set) {
+			min_set = true;
+			min_val = regs[insn->src_reg].min_value;
+		}
+		if (regs[insn->src_reg].max_set) {
+			max_set = true;
+			max_val = regs[insn->src_reg].max_value;
+		}
+	} else {
+		min_val = max_val = insn->imm;
+		min_set = max_set = true;
+	}
+
+	/* We don't know anything about what was done to this register, mark it
+	 * as unknown.
+	 */
+	if (!min_set && !max_set) {
+		reset_reg_range_values(regs, insn->dst_reg);
+		return;
+	}
+
+	switch (opcode) {
+	case BPF_ADD:
+		if (min_set && dst_reg->min_set)
+			dst_reg->min_value += min_val;
+		if (max_set && dst_reg->max_set)
+			dst_reg->max_value += max_val;
+		break;
+	case BPF_SUB:
+		if (min_set && dst_reg->min_set)
+			dst_reg->min_value -= min_val;
+		if (max_set && dst_reg->max_set)
+			dst_reg->max_value -= max_val;
+		break;
+	case BPF_MUL:
+		if (min_set && dst_reg->min_set)
+			dst_reg->min_value *= min_val;
+		if (max_set && dst_reg->max_set)
+			dst_reg->max_value *= max_val;
+		break;
+	case BPF_DIV:
+		if (min_val != 0 && min_set && dst_reg->min_set)
+			dst_reg->min_value /= min_val;
+		if (max_val != 0 && max_set && dst_reg->max_set)
+			dst_reg->max_value /= max_val;
+		break;
+	case BPF_OR:
+		if (min_set && dst_reg->min_set)
+			dst_reg->min_value |= min_val;
+		if (max_set && dst_reg->max_set)
+			dst_reg->max_value |= max_val;
+
+		/* If min_set isn't set then we can assume that the minimum
+		 * value will at least be min_val.
+		 */
+		if (min_set && !dst_reg->min_set) {
+			dst_reg->min_value = min_val;
+			dst_reg->min_set = true;
+		}
+		break;
+	case BPF_AND:
+		/* & is special since it could end up with 0 bits set. */
+		dst_reg->min_value = 0;
+		dst_reg->min_set = true;
+		dst_reg->max_value = max_val;
+		dst_reg->max_set = true;
+		break;
+	case BPF_LSH:
+		if (min_set && dst_reg->min_set)
+			dst_reg->min_value <<= min_val;
+		if (max_set && dst_reg->max_set)
+			dst_reg->max_value <<= max_val;
+		break;
+	case BPF_RSH:
+		if (min_set && dst_reg->min_set)
+			dst_reg->min_value >>= min_val;
+		if (max_set && dst_reg->max_set)
+			dst_reg->max_value >>= max_val;
+		break;
+	case BPF_MOD:
+		/* % is special, we can end up with 0 as a minimum. */
+		dst_reg->min_value = 0;
+		dst_reg->min_set = true;
+		dst_reg->max_value = (u64)-1;
+		dst_reg->max_set = true;
+		if (max_set) {
+			dst_reg->max_value = max_val - 1;
+			dst_reg->max_set = true;
+		}
+		break;
+	case BPF_XOR:
+		if (min_set && dst_reg->min_set)
+			dst_reg->min_value ^= min_val;
+		if (max_set && dst_reg->max_set)
+			dst_reg->max_value ^= max_val;
+		break;
+	default:
+		reset_reg_range_values(regs, insn->dst_reg);
+		break;
+	}
+}
+
 /* check validity of 32-bit and 64-bit arithmetic operations */
 static int check_alu_op(struct verifier_env *env, struct bpf_insn *insn)
 {
@@ -1495,6 +1672,11 @@ static int check_alu_op(struct verifier_env *env, struct bpf_insn *insn)
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
@@ -1516,6 +1698,10 @@ static int check_alu_op(struct verifier_env *env, struct bpf_insn *insn)
 			 */
 			regs[insn->dst_reg].type = CONST_IMM;
 			regs[insn->dst_reg].imm = insn->imm;
+			regs[insn->dst_reg].max_value = insn->imm;
+			regs[insn->dst_reg].min_value = insn->imm;
+			regs[insn->dst_reg].min_set = true;
+			regs[insn->dst_reg].max_set = true;
 		}
 
 	} else if (opcode > BPF_END) {
@@ -1568,6 +1754,9 @@ static int check_alu_op(struct verifier_env *env, struct bpf_insn *insn)
 
 		dst_reg = &regs[insn->dst_reg];
 
+		/* first we want to adjust our ranges. */
+		adjust_reg_min_max_vals(env, insn);
+
 		/* pattern match 'bpf_add Rx, imm' instruction */
 		if (opcode == BPF_ADD && BPF_CLASS(insn->code) == BPF_ALU64 &&
 		    dst_reg->type == FRAME_PTR && BPF_SRC(insn->code) == BPF_K) {
@@ -1602,8 +1791,17 @@ static int check_alu_op(struct verifier_env *env, struct bpf_insn *insn)
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
@@ -1642,7 +1840,9 @@ static int check_cond_jmp_op(struct verifier_env *env,
 {
 	struct reg_state *regs = env->cur_state.regs, *dst_reg;
 	struct verifier_state *other_branch;
+	u64 val = 0;
 	u8 opcode = BPF_OP(insn->code);
+	bool set_min_max = false;
 	int err;
 
 	if (opcode > BPF_EXIT) {
@@ -1703,6 +1903,82 @@ static int check_cond_jmp_op(struct verifier_env *env,
 	if (!other_branch)
 		return -EFAULT;
 
+	/* detect if we are comparing against a constant value so we can adjust
+	 * our min/max vlues for our dst register.
+	 */
+	if (BPF_SRC(insn->code) == BPF_X) {
+		if (regs[insn->src_reg].type == CONST_IMM) {
+			set_min_max = true;
+			val = regs[insn->src_reg].imm;
+		}
+	} else {
+		set_min_max = true;
+		val = insn->imm;
+	}
+
+	if (set_min_max) {
+		struct reg_state *other_dst;
+
+		/* dst_reg will be what happens if the statement evaluates as
+		 * false, other_dst will be what happens if the statement
+		 * evalulates as true.
+		 */
+		other_dst = &other_branch->regs[insn->dst_reg];
+		switch (opcode) {
+		case BPF_JEQ:
+			/* If this is false then we know nothing Jon Snow, but
+			 * the other branch we can know for sure.
+			 */
+			if (!other_dst->max_set || val > other_dst->max_value)
+				other_dst->max_value = val;
+			if (!other_dst->min_set || val < other_dst->min_value)
+				other_dst->min_value = val;
+			other_dst->max_set = true;
+			other_dst->min_set = true;
+			break;
+		case BPF_JGT:
+		case BPF_JSGT:
+			/* If this is false then we know the maxmimum val is
+			 * val, otherwise we know the min val is val+1.
+			 */
+			if (!dst_reg->max_set || val > dst_reg->max_value)
+				dst_reg->max_value = val;
+			if (!other_dst->min_set ||
+			    (val + 1) < other_dst->min_value)
+				other_dst->min_value = val + 1;
+			dst_reg->max_set = true;
+			other_dst->min_set = true;
+			break;
+		case BPF_JGE:
+		case BPF_JSGE:
+			/* If this is false then we know the maximum value is
+			 * val - 1, otherwise we know the mimimum value is val.
+			 */
+			if (!dst_reg->max_set ||
+			    (val - 1) > dst_reg->max_value)
+				dst_reg->max_value = val - 1;
+			if (!other_dst->min_set || val < other_dst->min_value)
+				other_dst->min_value = val;
+			dst_reg->max_set = true;
+			other_dst->min_set = true;
+			break;
+		default:
+			break;
+		}
+
+		/* If we are doing a signed comparison then this register is
+		 * signed and we cannot go along with the unset min_value of
+		 * being 0, as it could be any value less than zero.  So if we
+		 * don't have min_set then set it to -1 to catch the case that
+		 * there is some negative number in our register.
+		 */
+		if ((opcode == BPF_JSGE || opcode == BPF_JSGT) &&
+		    !dst_reg->min_set) {
+			dst_reg->min_set = true;
+			dst_reg->min_value = (u64)-1;
+		}
+	}
+
 	/* detect if R == 0 where R is returned value from bpf_map_lookup_elem() */
 	if (BPF_SRC(insn->code) == BPF_K &&
 	    insn->imm == 0 && (opcode == BPF_JEQ || opcode == BPF_JNE) &&
@@ -2124,7 +2400,8 @@ static bool compare_ptrs_to_packet(struct reg_state *old, struct reg_state *cur)
  * whereas register type in current state is meaningful, it means that
  * the current state will reach 'bpf_exit' instruction safely
  */
-static bool states_equal(struct verifier_state *old, struct verifier_state *cur)
+static bool states_equal(struct verifier_env *env, struct verifier_state *old,
+			 struct verifier_state *cur)
 {
 	struct reg_state *rold, *rcur;
 	int i;
@@ -2136,6 +2413,13 @@ static bool states_equal(struct verifier_state *old, struct verifier_state *cur)
 		if (memcmp(rold, rcur, sizeof(*rold)) == 0)
 			continue;
 
+		if (env->memory_access &&
+		    (rold->max_set != rcur->max_set ||
+		     rold->min_set != rcur->min_set ||
+		     rold->max_value != rcur->max_value ||
+		     rold->min_value != rcur->min_value))
+			return false;
+
 		if (rold->type == NOT_INIT ||
 		    (rold->type == UNKNOWN_VALUE && rcur->type != NOT_INIT))
 			continue;
@@ -2192,7 +2476,7 @@ static int is_state_visited(struct verifier_env *env, int insn_idx)
 		return 0;
 
 	while (sl != STATE_LIST_MARK) {
-		if (states_equal(&sl->state, &env->cur_state))
+		if (states_equal(env, &sl->state, &env->cur_state))
 			/* reached equivalent register/stack state,
 			 * prune the search
 			 */
@@ -2229,6 +2513,7 @@ static int do_check(struct verifier_env *env)
 
 	init_reg_state(regs);
 	insn_idx = 0;
+	env->memory_access = false;
 	for (;;) {
 		struct bpf_insn *insn;
 		u8 class;
-- 
2.7.4
