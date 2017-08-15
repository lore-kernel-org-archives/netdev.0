From: Edward Cree via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: [PATCH v3 net-next] bpf/verifier: track liveness for
	pruning
Date: Tue, 15 Aug 2017 20:34:35 +0100
Message-ID: <f40d3d54-c88a-7348-99ca-66db8075a8d5@solarflare.com>
Reply-To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org

State of a register doesn't matter if it wasn't read in reaching an exit;
 a write screens off all reads downstream of it from all explored_states
 upstream of it.
This allows us to prune many more branches; here are some processed insn
 counts for some Cilium programs:
Program                  before  after
bpf_lb_opt_-DLB_L3.o       6515   3361
bpf_lb_opt_-DLB_L4.o       8976   5176
bpf_lb_opt_-DUNKNOWN.o     2960   1137
bpf_lxc_opt_-DDROP_ALL.o  95412  48537
bpf_lxc_opt_-DUNKNOWN.o  141706  78718
bpf_netdev.o              24251  17995
bpf_overlay.o             10999   9385

The runtime is also improved; here are 'time' results in ms:
Program                  before  after
bpf_lb_opt_-DLB_L3.o         24      6
bpf_lb_opt_-DLB_L4.o         26     11
bpf_lb_opt_-DUNKNOWN.o       11      2
bpf_lxc_opt_-DDROP_ALL.o   1288    139
bpf_lxc_opt_-DUNKNOWN.o    1768    234
bpf_netdev.o                 62     31
bpf_overlay.o                15     13

Signed-off-by: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
---
v3: cleaner code around marking caller-saved regs, again spotted by Daniel
 Borkmann.  Should have no functional effect.

v2: update liveness in LD_ABS|IND, as pointed out by Daniel Borkmann.  The
 numbers are mostly unchanged; bpf_lxc_opt_-DUNKNOWN.o dropped about 300
 insns and 20ms, while bpf_lxc_opt_-DDROP_ALL.o (despite not changing its
 #insns) also dropped 13ms.

 include/linux/bpf_verifier.h |  11 ++-
 kernel/bpf/verifier.c        | 189 +++++++++++++++++++++++++++++++++----------
 2 files changed, 156 insertions(+), 44 deletions(-)

diff --git a/include/linux/bpf_verifier.h b/include/linux/bpf_verifier.h
index c61c3033..91d07ef 100644
--- a/include/linux/bpf_verifier.h
+++ b/include/linux/bpf_verifier.h
@@ -21,6 +21,12 @@
  */
 #define BPF_MAX_VAR_SIZ	INT_MAX
 
+enum bpf_reg_liveness {
+	REG_LIVE_NONE = 0, /* reg hasn't been read or written this branch */
+	REG_LIVE_READ, /* reg was read, so we're sensitive to initial value */
+	REG_LIVE_WRITTEN, /* reg was written first, screening off later reads */
+};
+
 struct bpf_reg_state {
 	enum bpf_reg_type type;
 	union {
@@ -40,7 +46,7 @@ struct bpf_reg_state {
 	 * came from, when one is tested for != NULL.
 	 */
 	u32 id;
-	/* These five fields must be last.  See states_equal() */
+	/* Ordering of fields matters.  See states_equal() */
 	/* For scalar types (SCALAR_VALUE), this represents our knowledge of
 	 * the actual value.
 	 * For pointer types, this represents the variable part of the offset
@@ -57,6 +63,8 @@ struct bpf_reg_state {
 	s64 smax_value; /* maximum possible (s64)value */
 	u64 umin_value; /* minimum possible (u64)value */
 	u64 umax_value; /* maximum possible (u64)value */
+	/* This field must be last, for states_equal() reasons. */
+	enum bpf_reg_liveness live;
 };
 
 enum bpf_stack_slot_type {
@@ -74,6 +82,7 @@ struct bpf_verifier_state {
 	struct bpf_reg_state regs[MAX_BPF_REG];
 	u8 stack_slot_type[MAX_BPF_STACK];
 	struct bpf_reg_state spilled_regs[MAX_BPF_STACK / BPF_REG_SIZE];
+	struct bpf_verifier_state *parent;
 };
 
 /* linked list of verifier states used to prune search */
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index ecc590e..7dd96d0 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -629,8 +629,10 @@ static void init_reg_state(struct bpf_reg_state *regs)
 {
 	int i;
 
-	for (i = 0; i < MAX_BPF_REG; i++)
+	for (i = 0; i < MAX_BPF_REG; i++) {
 		mark_reg_not_init(regs, i);
+		regs[i].live = REG_LIVE_NONE;
+	}
 
 	/* frame pointer */
 	regs[BPF_REG_FP].type = PTR_TO_STACK;
@@ -647,9 +649,26 @@ enum reg_arg_type {
 	DST_OP_NO_MARK	/* same as above, check only, don't mark */
 };
 
-static int check_reg_arg(struct bpf_reg_state *regs, u32 regno,
+static void mark_reg_read(const struct bpf_verifier_state *state, u32 regno)
+{
+	struct bpf_verifier_state *parent = state->parent;
+
+	while (parent) {
+		/* if read wasn't screened by an earlier write ... */
+		if (state->regs[regno].live & REG_LIVE_WRITTEN)
+			break;
+		/* ... then we depend on parent's value */
+		parent->regs[regno].live |= REG_LIVE_READ;
+		state = parent;
+		parent = state->parent;
+	}
+}
+
+static int check_reg_arg(struct bpf_verifier_env *env, u32 regno,
 			 enum reg_arg_type t)
 {
+	struct bpf_reg_state *regs = env->cur_state.regs;
+
 	if (regno >= MAX_BPF_REG) {
 		verbose("R%d is invalid\n", regno);
 		return -EINVAL;
@@ -661,12 +680,14 @@ static int check_reg_arg(struct bpf_reg_state *regs, u32 regno,
 			verbose("R%d !read_ok\n", regno);
 			return -EACCES;
 		}
+		mark_reg_read(&env->cur_state, regno);
 	} else {
 		/* check whether register used as dest operand can be written to */
 		if (regno == BPF_REG_FP) {
 			verbose("frame pointer is read only\n");
 			return -EACCES;
 		}
+		regs[regno].live |= REG_LIVE_WRITTEN;
 		if (t == DST_OP)
 			mark_reg_unknown(regs, regno);
 	}
@@ -695,7 +716,7 @@ static bool is_spillable_regtype(enum bpf_reg_type type)
 static int check_stack_write(struct bpf_verifier_state *state, int off,
 			     int size, int value_regno)
 {
-	int i;
+	int i, spi = (MAX_BPF_STACK + off) / BPF_REG_SIZE;
 	/* caller checked that off % size == 0 and -MAX_BPF_STACK <= off < 0,
 	 * so it's aligned access and [off, off + size) are within stack limits
 	 */
@@ -710,15 +731,14 @@ static int check_stack_write(struct bpf_verifier_state *state, int off,
 		}
 
 		/* save register state */
-		state->spilled_regs[(MAX_BPF_STACK + off) / BPF_REG_SIZE] =
-			state->regs[value_regno];
+		state->spilled_regs[spi] = state->regs[value_regno];
+		state->spilled_regs[spi].live |= REG_LIVE_WRITTEN;
 
 		for (i = 0; i < BPF_REG_SIZE; i++)
 			state->stack_slot_type[MAX_BPF_STACK + off + i] = STACK_SPILL;
 	} else {
 		/* regular write of data into stack */
-		state->spilled_regs[(MAX_BPF_STACK + off) / BPF_REG_SIZE] =
-			(struct bpf_reg_state) {};
+		state->spilled_regs[spi] = (struct bpf_reg_state) {};
 
 		for (i = 0; i < size; i++)
 			state->stack_slot_type[MAX_BPF_STACK + off + i] = STACK_MISC;
@@ -726,11 +746,26 @@ static int check_stack_write(struct bpf_verifier_state *state, int off,
 	return 0;
 }
 
+static void mark_stack_slot_read(const struct bpf_verifier_state *state, int slot)
+{
+	struct bpf_verifier_state *parent = state->parent;
+
+	while (parent) {
+		/* if read wasn't screened by an earlier write ... */
+		if (state->spilled_regs[slot].live & REG_LIVE_WRITTEN)
+			break;
+		/* ... then we depend on parent's value */
+		parent->spilled_regs[slot].live |= REG_LIVE_READ;
+		state = parent;
+		parent = state->parent;
+	}
+}
+
 static int check_stack_read(struct bpf_verifier_state *state, int off, int size,
 			    int value_regno)
 {
 	u8 *slot_type;
-	int i;
+	int i, spi;
 
 	slot_type = &state->stack_slot_type[MAX_BPF_STACK + off];
 
@@ -746,10 +781,13 @@ static int check_stack_read(struct bpf_verifier_state *state, int off, int size,
 			}
 		}
 
-		if (value_regno >= 0)
+		spi = (MAX_BPF_STACK + off) / BPF_REG_SIZE;
+
+		if (value_regno >= 0) {
 			/* restore register state from stack */
-			state->regs[value_regno] =
-				state->spilled_regs[(MAX_BPF_STACK + off) / BPF_REG_SIZE];
+			state->regs[value_regno] = state->spilled_regs[spi];
+			mark_stack_slot_read(state, spi);
+		}
 		return 0;
 	} else {
 		for (i = 0; i < size; i++) {
@@ -1167,7 +1205,6 @@ static int check_mem_access(struct bpf_verifier_env *env, int insn_idx, u32 regn
 
 static int check_xadd(struct bpf_verifier_env *env, int insn_idx, struct bpf_insn *insn)
 {
-	struct bpf_reg_state *regs = env->cur_state.regs;
 	int err;
 
 	if ((BPF_SIZE(insn->code) != BPF_W && BPF_SIZE(insn->code) != BPF_DW) ||
@@ -1177,12 +1214,12 @@ static int check_xadd(struct bpf_verifier_env *env, int insn_idx, struct bpf_ins
 	}
 
 	/* check src1 operand */
-	err = check_reg_arg(regs, insn->src_reg, SRC_OP);
+	err = check_reg_arg(env, insn->src_reg, SRC_OP);
 	if (err)
 		return err;
 
 	/* check src2 operand */
-	err = check_reg_arg(regs, insn->dst_reg, SRC_OP);
+	err = check_reg_arg(env, insn->dst_reg, SRC_OP);
 	if (err)
 		return err;
 
@@ -1297,10 +1334,9 @@ static int check_func_arg(struct bpf_verifier_env *env, u32 regno,
 	if (arg_type == ARG_DONTCARE)
 		return 0;
 
-	if (type == NOT_INIT) {
-		verbose("R%d !read_ok\n", regno);
-		return -EACCES;
-	}
+	err = check_reg_arg(env, regno, SRC_OP);
+	if (err)
+		return err;
 
 	if (arg_type == ARG_ANYTHING) {
 		if (is_pointer_value(env, regno)) {
@@ -1639,10 +1675,12 @@ static int check_call(struct bpf_verifier_env *env, int func_id, int insn_idx)
 	}
 
 	/* reset caller saved regs */
-	for (i = 0; i < CALLER_SAVED_REGS; i++)
+	for (i = 0; i < CALLER_SAVED_REGS; i++) {
 		mark_reg_not_init(regs, caller_saved[i]);
+		check_reg_arg(env, caller_saved[i], DST_OP_NO_MARK);
+	}
 
-	/* update return register */
+	/* update return register (already marked as written above) */
 	if (fn->ret_type == RET_INTEGER) {
 		/* sets type to SCALAR_VALUE */
 		mark_reg_unknown(regs, BPF_REG_0);
@@ -2250,7 +2288,7 @@ static int check_alu_op(struct bpf_verifier_env *env, struct bpf_insn *insn)
 		}
 
 		/* check src operand */
-		err = check_reg_arg(regs, insn->dst_reg, SRC_OP);
+		err = check_reg_arg(env, insn->dst_reg, SRC_OP);
 		if (err)
 			return err;
 
@@ -2261,7 +2299,7 @@ static int check_alu_op(struct bpf_verifier_env *env, struct bpf_insn *insn)
 		}
 
 		/* check dest operand */
-		err = check_reg_arg(regs, insn->dst_reg, DST_OP);
+		err = check_reg_arg(env, insn->dst_reg, DST_OP);
 		if (err)
 			return err;
 
@@ -2274,7 +2312,7 @@ static int check_alu_op(struct bpf_verifier_env *env, struct bpf_insn *insn)
 			}
 
 			/* check src operand */
-			err = check_reg_arg(regs, insn->src_reg, SRC_OP);
+			err = check_reg_arg(env, insn->src_reg, SRC_OP);
 			if (err)
 				return err;
 		} else {
@@ -2285,7 +2323,7 @@ static int check_alu_op(struct bpf_verifier_env *env, struct bpf_insn *insn)
 		}
 
 		/* check dest operand */
-		err = check_reg_arg(regs, insn->dst_reg, DST_OP);
+		err = check_reg_arg(env, insn->dst_reg, DST_OP);
 		if (err)
 			return err;
 
@@ -2328,7 +2366,7 @@ static int check_alu_op(struct bpf_verifier_env *env, struct bpf_insn *insn)
 				return -EINVAL;
 			}
 			/* check src1 operand */
-			err = check_reg_arg(regs, insn->src_reg, SRC_OP);
+			err = check_reg_arg(env, insn->src_reg, SRC_OP);
 			if (err)
 				return err;
 		} else {
@@ -2339,7 +2377,7 @@ static int check_alu_op(struct bpf_verifier_env *env, struct bpf_insn *insn)
 		}
 
 		/* check src2 operand */
-		err = check_reg_arg(regs, insn->dst_reg, SRC_OP);
+		err = check_reg_arg(env, insn->dst_reg, SRC_OP);
 		if (err)
 			return err;
 
@@ -2360,7 +2398,7 @@ static int check_alu_op(struct bpf_verifier_env *env, struct bpf_insn *insn)
 		}
 
 		/* check dest operand */
-		err = check_reg_arg(regs, insn->dst_reg, DST_OP_NO_MARK);
+		err = check_reg_arg(env, insn->dst_reg, DST_OP_NO_MARK);
 		if (err)
 			return err;
 
@@ -2717,7 +2755,7 @@ static int check_cond_jmp_op(struct bpf_verifier_env *env,
 		}
 
 		/* check src1 operand */
-		err = check_reg_arg(regs, insn->src_reg, SRC_OP);
+		err = check_reg_arg(env, insn->src_reg, SRC_OP);
 		if (err)
 			return err;
 
@@ -2734,7 +2772,7 @@ static int check_cond_jmp_op(struct bpf_verifier_env *env,
 	}
 
 	/* check src2 operand */
-	err = check_reg_arg(regs, insn->dst_reg, SRC_OP);
+	err = check_reg_arg(env, insn->dst_reg, SRC_OP);
 	if (err)
 		return err;
 
@@ -2851,7 +2889,7 @@ static int check_ld_imm(struct bpf_verifier_env *env, struct bpf_insn *insn)
 		return -EINVAL;
 	}
 
-	err = check_reg_arg(regs, insn->dst_reg, DST_OP);
+	err = check_reg_arg(env, insn->dst_reg, DST_OP);
 	if (err)
 		return err;
 
@@ -2917,7 +2955,7 @@ static int check_ld_abs(struct bpf_verifier_env *env, struct bpf_insn *insn)
 	}
 
 	/* check whether implicit source operand (register R6) is readable */
-	err = check_reg_arg(regs, BPF_REG_6, SRC_OP);
+	err = check_reg_arg(env, BPF_REG_6, SRC_OP);
 	if (err)
 		return err;
 
@@ -2928,17 +2966,20 @@ static int check_ld_abs(struct bpf_verifier_env *env, struct bpf_insn *insn)
 
 	if (mode == BPF_IND) {
 		/* check explicit source operand */
-		err = check_reg_arg(regs, insn->src_reg, SRC_OP);
+		err = check_reg_arg(env, insn->src_reg, SRC_OP);
 		if (err)
 			return err;
 	}
 
 	/* reset caller saved regs to unreadable */
-	for (i = 0; i < CALLER_SAVED_REGS; i++)
+	for (i = 0; i < CALLER_SAVED_REGS; i++) {
 		mark_reg_not_init(regs, caller_saved[i]);
+		check_reg_arg(env, caller_saved[i], DST_OP_NO_MARK);
+	}
 
 	/* mark destination R0 register as readable, since it contains
-	 * the value fetched from the packet
+	 * the value fetched from the packet.
+	 * Already marked as written above.
 	 */
 	mark_reg_unknown(regs, BPF_REG_0);
 	return 0;
@@ -3194,7 +3235,11 @@ static bool regsafe(struct bpf_reg_state *rold,
 		    struct bpf_reg_state *rcur,
 		    bool varlen_map_access, struct idpair *idmap)
 {
-	if (memcmp(rold, rcur, sizeof(*rold)) == 0)
+	if (!(rold->live & REG_LIVE_READ))
+		/* explored state didn't use this */
+		return true;
+
+	if (memcmp(rold, rcur, offsetof(struct bpf_reg_state, live)) == 0)
 		return true;
 
 	if (rold->type == NOT_INIT)
@@ -3372,10 +3417,56 @@ static bool states_equal(struct bpf_verifier_env *env,
 	return ret;
 }
 
+static bool do_propagate_liveness(const struct bpf_verifier_state *state,
+				  struct bpf_verifier_state *parent)
+{
+	bool touched = false; /* any changes made? */
+	int i;
+
+	if (!parent)
+		return touched;
+	/* Propagate read liveness of registers... */
+	BUILD_BUG_ON(BPF_REG_FP + 1 != MAX_BPF_REG);
+	/* We don't need to worry about FP liveness because it's read-only */
+	for (i = 0; i < BPF_REG_FP; i++) {
+		if (parent->regs[i].live & REG_LIVE_READ)
+			continue;
+		if (state->regs[i].live == REG_LIVE_READ) {
+			parent->regs[i].live |= REG_LIVE_READ;
+			touched = true;
+		}
+	}
+	/* ... and stack slots */
+	for (i = 0; i < MAX_BPF_STACK / BPF_REG_SIZE; i++) {
+		if (parent->stack_slot_type[i * BPF_REG_SIZE] != STACK_SPILL)
+			continue;
+		if (state->stack_slot_type[i * BPF_REG_SIZE] != STACK_SPILL)
+			continue;
+		if (parent->spilled_regs[i].live & REG_LIVE_READ)
+			continue;
+		if (state->spilled_regs[i].live == REG_LIVE_READ) {
+			parent->regs[i].live |= REG_LIVE_READ;
+			touched = true;
+		}
+	}
+	return touched;
+}
+
+static void propagate_liveness(const struct bpf_verifier_state *state,
+			       struct bpf_verifier_state *parent)
+{
+	while (do_propagate_liveness(state, parent)) {
+		/* Something changed, so we need to feed those changes onward */
+		state = parent;
+		parent = state->parent;
+	}
+}
+
 static int is_state_visited(struct bpf_verifier_env *env, int insn_idx)
 {
 	struct bpf_verifier_state_list *new_sl;
 	struct bpf_verifier_state_list *sl;
+	int i;
 
 	sl = env->explored_states[insn_idx];
 	if (!sl)
@@ -3385,11 +3476,14 @@ static int is_state_visited(struct bpf_verifier_env *env, int insn_idx)
 		return 0;
 
 	while (sl != STATE_LIST_MARK) {
-		if (states_equal(env, &sl->state, &env->cur_state))
+		if (states_equal(env, &sl->state, &env->cur_state)) {
 			/* reached equivalent register/stack state,
-			 * prune the search
+			 * prune the search.
+			 * Registers read by the continuation are read by us.
 			 */
+			propagate_liveness(&sl->state, &env->cur_state);
 			return 1;
+		}
 		sl = sl->next;
 	}
 
@@ -3407,6 +3501,14 @@ static int is_state_visited(struct bpf_verifier_env *env, int insn_idx)
 	memcpy(&new_sl->state, &env->cur_state, sizeof(env->cur_state));
 	new_sl->next = env->explored_states[insn_idx];
 	env->explored_states[insn_idx] = new_sl;
+	/* connect new state to parentage chain */
+	env->cur_state.parent = &new_sl->state;
+	/* clear liveness marks in current state */
+	for (i = 0; i < BPF_REG_FP; i++)
+		env->cur_state.regs[i].live = REG_LIVE_NONE;
+	for (i = 0; i < MAX_BPF_STACK / BPF_REG_SIZE; i++)
+		if (env->cur_state.stack_slot_type[i * BPF_REG_SIZE] == STACK_SPILL)
+			env->cur_state.spilled_regs[i].live = REG_LIVE_NONE;
 	return 0;
 }
 
@@ -3430,6 +3532,7 @@ static int do_check(struct bpf_verifier_env *env)
 	bool do_print_state = false;
 
 	init_reg_state(regs);
+	state->parent = NULL;
 	insn_idx = 0;
 	env->varlen_map_value_access = false;
 	for (;;) {
@@ -3500,11 +3603,11 @@ static int do_check(struct bpf_verifier_env *env)
 			/* check for reserved fields is already done */
 
 			/* check src operand */
-			err = check_reg_arg(regs, insn->src_reg, SRC_OP);
+			err = check_reg_arg(env, insn->src_reg, SRC_OP);
 			if (err)
 				return err;
 
-			err = check_reg_arg(regs, insn->dst_reg, DST_OP_NO_MARK);
+			err = check_reg_arg(env, insn->dst_reg, DST_OP_NO_MARK);
 			if (err)
 				return err;
 
@@ -3554,11 +3657,11 @@ static int do_check(struct bpf_verifier_env *env)
 			}
 
 			/* check src1 operand */
-			err = check_reg_arg(regs, insn->src_reg, SRC_OP);
+			err = check_reg_arg(env, insn->src_reg, SRC_OP);
 			if (err)
 				return err;
 			/* check src2 operand */
-			err = check_reg_arg(regs, insn->dst_reg, SRC_OP);
+			err = check_reg_arg(env, insn->dst_reg, SRC_OP);
 			if (err)
 				return err;
 
@@ -3589,7 +3692,7 @@ static int do_check(struct bpf_verifier_env *env)
 				return -EINVAL;
 			}
 			/* check src operand */
-			err = check_reg_arg(regs, insn->dst_reg, SRC_OP);
+			err = check_reg_arg(env, insn->dst_reg, SRC_OP);
 			if (err)
 				return err;
 
@@ -3643,7 +3746,7 @@ static int do_check(struct bpf_verifier_env *env)
 				 * of bpf_exit, which means that program wrote
 				 * something into it earlier
 				 */
-				err = check_reg_arg(regs, BPF_REG_0, SRC_OP);
+				err = check_reg_arg(env, BPF_REG_0, SRC_OP);
 				if (err)
 					return err;
