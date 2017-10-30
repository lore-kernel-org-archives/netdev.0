From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next] bpf: reduce verifier memory consumption
Date: Mon, 30 Oct 2017 14:51:47 -0700
Message-ID: <20171030215147.579702-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Martin KaFai Lau <kafai@fb.com>,
        Edward Cree <ecree@solarflare.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:41082 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932876AbdJ3VwG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 17:52:06 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9ULivIN023865
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 14:52:06 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2dxam38h5f-6
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 14:52:06 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

the verifier got progressively smarter over time and size of its internal
state grew as well. Time to reduce the memory consumption.

Before:
sizeof(struct bpf_verifier_state) = 6520
After:
sizeof(struct bpf_verifier_state) = 896

It's done by observing that majority of BPF programs use little to
no stack whereas verifier kept all of 512 stack slots ready always.
Instead dynamically reallocate struct verifier state when stack
access is detected.
Besides memory savings such approach gives few % runtime perf
improvement as well and small reduction in number of processed insns:
                     before  after
bpf_lb-DLB_L3.o        2285   2043
bpf_lb-DLB_L4.o        3723   3570
bpf_lb-DUNKNOWN.o      1110   1109
bpf_lxc-DDROP_ALL.o   27954  27849
bpf_lxc-DUNKNOWN.o    38954  38724
bpf_netdev.o          16943  16131
bpf_overlay.o          7929   7733

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 drivers/net/ethernet/netronome/nfp/bpf/verifier.c |   8 +-
 include/linux/bpf_verifier.h                      |  18 +-
 kernel/bpf/verifier.c                             | 390 ++++++++++++++--------
 3 files changed, 268 insertions(+), 148 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/bpf/verifier.c b/drivers/net/ethernet/netronome/nfp/bpf/verifier.c
index 3d3dcac1c942..a8c7615546a9 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/verifier.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/verifier.c
@@ -76,9 +76,9 @@ nfp_bpf_goto_meta(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
 
 static int
 nfp_bpf_check_exit(struct nfp_prog *nfp_prog,
-		   const struct bpf_verifier_env *env)
+		   struct bpf_verifier_env *env)
 {
-	const struct bpf_reg_state *reg0 = &env->cur_state.regs[0];
+	const struct bpf_reg_state *reg0 = cur_regs(env) + BPF_REG_0;
 	u64 imm;
 
 	if (nfp_prog->act == NN_ACT_XDP)
@@ -144,9 +144,9 @@ nfp_bpf_check_stack_access(struct nfp_prog *nfp_prog,
 
 static int
 nfp_bpf_check_ptr(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
-		  const struct bpf_verifier_env *env, u8 reg_no)
+		  struct bpf_verifier_env *env, u8 reg_no)
 {
-	const struct bpf_reg_state *reg = &env->cur_state.regs[reg_no];
+	const struct bpf_reg_state *reg = cur_regs(env) + reg_no;
 	int err;
 
 	if (reg->type != PTR_TO_CTX &&
diff --git a/include/linux/bpf_verifier.h b/include/linux/bpf_verifier.h
index feeaea93d959..c1430701742c 100644
--- a/include/linux/bpf_verifier.h
+++ b/include/linux/bpf_verifier.h
@@ -88,20 +88,25 @@ enum bpf_stack_slot_type {
 
 #define BPF_REG_SIZE 8	/* size of eBPF register in bytes */
 
+struct bpf_verifier_stack {
+	struct bpf_reg_state spilled_ptr;
+	u8 slot_type[BPF_REG_SIZE];
+};
+
 /* state of the program:
  * type of all registers and stack info
  */
 struct bpf_verifier_state {
 	struct bpf_reg_state regs[MAX_BPF_REG];
-	u8 stack_slot_type[MAX_BPF_STACK];
-	struct bpf_reg_state spilled_regs[MAX_BPF_STACK / BPF_REG_SIZE];
 	struct bpf_verifier_state *parent;
+	int allocated_stack;
+	struct bpf_verifier_stack stack[0];
 };
 
 /* linked list of verifier states used to prune search */
 struct bpf_verifier_state_list {
-	struct bpf_verifier_state state;
 	struct bpf_verifier_state_list *next;
+	struct bpf_verifier_state state;
 };
 
 struct bpf_insn_aux_data {
@@ -145,7 +150,7 @@ struct bpf_verifier_env {
 	struct bpf_verifier_stack_elem *head; /* stack of verifier states to be processed */
 	int stack_size;			/* number of states to be processed */
 	bool strict_alignment;		/* perform strict pointer alignment checks */
-	struct bpf_verifier_state cur_state; /* current verifier state */
+	struct bpf_verifier_state *cur_state; /* current verifier state */
 	struct bpf_verifier_state_list **explored_states; /* search pruning optimization */
 	const struct bpf_ext_analyzer_ops *analyzer_ops; /* external analyzer ops */
 	void *analyzer_priv; /* pointer to external analyzer's private data */
@@ -159,6 +164,11 @@ struct bpf_verifier_env {
 	struct bpf_verifer_log log;
 };
 
+static inline struct bpf_reg_state *cur_regs(struct bpf_verifier_env *env)
+{
+	return env->cur_state->regs;
+}
+
 int bpf_analyzer(struct bpf_prog *prog, const struct bpf_ext_analyzer_ops *ops,
 		 void *priv);
 
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index d906775e12c1..a9fbcf9812d0 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -145,10 +145,10 @@ struct bpf_verifier_stack_elem {
 	 * before processing instruction 'insn_idx'
 	 * and after processing instruction 'prev_insn_idx'
 	 */
-	struct bpf_verifier_state st;
 	int insn_idx;
 	int prev_insn_idx;
 	struct bpf_verifier_stack_elem *next;
+	struct bpf_verifier_state st;
 };
 
 #define BPF_COMPLEXITY_LIMIT_INSNS	131072
@@ -276,28 +276,78 @@ static void print_verifier_state(struct bpf_verifier_env *env,
 			verbose(env, ")");
 		}
 	}
-	for (i = 0; i < MAX_BPF_STACK; i += BPF_REG_SIZE) {
-		if (state->stack_slot_type[i] == STACK_SPILL)
-			verbose(env, " fp%d=%s", -MAX_BPF_STACK + i,
-				reg_type_str[state->spilled_regs[i / BPF_REG_SIZE].type]);
+	for (i = 0; i < state->allocated_stack / BPF_REG_SIZE; i++) {
+		if (state->stack[i].slot_type[0] == STACK_SPILL)
+			verbose(env, " fp%d=%s",
+				-MAX_BPF_STACK + i * BPF_REG_SIZE,
+				reg_type_str[state->stack[i].spilled_ptr.type]);
 	}
 	verbose(env, "\n");
 }
 
+static void copy_verifier_state(struct bpf_verifier_state *dst,
+				const struct bpf_verifier_state *src)
+{
+	int stack = dst->allocated_stack;
+
+	if (stack < src->allocated_stack) {
+		WARN_ON_ONCE(stack < src->allocated_stack);
+		/* internal bug, make state invalid to reject the program */
+		memset(dst, 0, sizeof(*dst));
+		return;
+	}
+	memcpy(dst, src, offsetof(struct bpf_verifier_state,
+				  stack[src->allocated_stack / BPF_REG_SIZE]));
+	dst->allocated_stack = stack;
+}
+
+/* do_check() starts with zero-sized stack in struct bpf_verifier_state to
+ * make it consume minimal amount of memory. check_stack_write() access from
+ * the program calls into realloc_verifier_state() to grow the stack size.
+ * Note there is a non-zero 'parent' pointer inside bpf_verifier_state
+ * which this function copies over. It points to previous bpf_verifier_state
+ * which is never reallocated
+ */
+static struct bpf_verifier_state *
+realloc_verifier_state(struct bpf_verifier_state *state, int size)
+{
+	struct bpf_verifier_state *new_state;
+	int slot = size / BPF_REG_SIZE;
+
+	new_state = kzalloc(offsetof(struct bpf_verifier_state, stack[slot]),
+			    GFP_KERNEL);
+	if (!new_state)
+		return NULL;
+	new_state->allocated_stack = slot * BPF_REG_SIZE;
+	if (state) {
+		copy_verifier_state(new_state, state);
+		kfree(state);
+	}
+	return new_state;
+}
+
 static int pop_stack(struct bpf_verifier_env *env, int *prev_insn_idx)
 {
-	struct bpf_verifier_stack_elem *elem;
+	struct bpf_verifier_state *cur = env->cur_state;
+	struct bpf_verifier_stack_elem *elem, *head = env->head;
 	int insn_idx;
 
 	if (env->head == NULL)
 		return -1;
 
-	memcpy(&env->cur_state, &env->head->st, sizeof(env->cur_state));
-	insn_idx = env->head->insn_idx;
+	if (cur && cur->allocated_stack < head->st.allocated_stack) {
+		cur = realloc_verifier_state(cur, head->st.allocated_stack);
+		if (!cur)
+			return -ENOMEM;
+		env->cur_state = cur;
+	}
+	if (cur)
+		copy_verifier_state(cur, &head->st);
+	insn_idx = head->insn_idx;
 	if (prev_insn_idx)
-		*prev_insn_idx = env->head->prev_insn_idx;
-	elem = env->head->next;
-	kfree(env->head);
+		*prev_insn_idx = head->prev_insn_idx;
+	elem = head->next;
+	kfree(head);
 	env->head = elem;
 	env->stack_size--;
 	return insn_idx;
@@ -306,13 +356,17 @@ static int pop_stack(struct bpf_verifier_env *env, int *prev_insn_idx)
 static struct bpf_verifier_state *push_stack(struct bpf_verifier_env *env,
 					     int insn_idx, int prev_insn_idx)
 {
+	struct bpf_verifier_state *cur = env->cur_state;
 	struct bpf_verifier_stack_elem *elem;
 
-	elem = kmalloc(sizeof(struct bpf_verifier_stack_elem), GFP_KERNEL);
+	elem = kzalloc(offsetof(struct bpf_verifier_stack_elem,
+				st.stack[cur->allocated_stack / BPF_REG_SIZE]),
+		       GFP_KERNEL);
 	if (!elem)
 		goto err;
 
-	memcpy(&elem->st, &env->cur_state, sizeof(env->cur_state));
+	elem->st.allocated_stack = cur->allocated_stack;
+	copy_verifier_state(&elem->st, cur);
 	elem->insn_idx = insn_idx;
 	elem->prev_insn_idx = prev_insn_idx;
 	elem->next = env->head;
@@ -550,7 +604,7 @@ static void mark_reg_read(const struct bpf_verifier_state *state, u32 regno)
 static int check_reg_arg(struct bpf_verifier_env *env, u32 regno,
 			 enum reg_arg_type t)
 {
-	struct bpf_reg_state *regs = env->cur_state.regs;
+	struct bpf_reg_state *regs = env->cur_state->regs;
 
 	if (regno >= MAX_BPF_REG) {
 		verbose(env, "R%d is invalid\n", regno);
@@ -563,7 +617,7 @@ static int check_reg_arg(struct bpf_verifier_env *env, u32 regno,
 			verbose(env, "R%d !read_ok\n", regno);
 			return -EACCES;
 		}
-		mark_reg_read(&env->cur_state, regno);
+		mark_reg_read(env->cur_state, regno);
 	} else {
 		/* check whether register used as dest operand can be written to */
 		if (regno == BPF_REG_FP) {
@@ -601,10 +655,24 @@ static int check_stack_write(struct bpf_verifier_env *env,
 			     struct bpf_verifier_state *state, int off,
 			     int size, int value_regno)
 {
-	int i, spi = (MAX_BPF_STACK + off) / BPF_REG_SIZE;
+	int i, slot = -off - 1, spi = slot / BPF_REG_SIZE;
+
+	if (state->allocated_stack <= slot) {
+		state = realloc_verifier_state(state,
+					       round_up(slot + 1, BPF_REG_SIZE));
+		if (!state)
+			return -ENOMEM;
+		env->cur_state = state;
+	}
 	/* caller checked that off % size == 0 and -MAX_BPF_STACK <= off < 0,
 	 * so it's aligned access and [off, off + size) are within stack limits
 	 */
+	if (!env->allow_ptr_leaks &&
+	    state->stack[spi].slot_type[0] == STACK_SPILL &&
+	    size != BPF_REG_SIZE) {
+		verbose(env, "attempt to corrupt spilled pointer on stack\n");
+		return -EACCES;
+	}
 
 	if (value_regno >= 0 &&
 	    is_spillable_regtype(state->regs[value_regno].type)) {
@@ -616,17 +684,18 @@ static int check_stack_write(struct bpf_verifier_env *env,
 		}
 
 		/* save register state */
-		state->spilled_regs[spi] = state->regs[value_regno];
-		state->spilled_regs[spi].live |= REG_LIVE_WRITTEN;
+		state->stack[spi].spilled_ptr = state->regs[value_regno];
+		state->stack[spi].spilled_ptr.live |= REG_LIVE_WRITTEN;
 
 		for (i = 0; i < BPF_REG_SIZE; i++)
-			state->stack_slot_type[MAX_BPF_STACK + off + i] = STACK_SPILL;
+			state->stack[spi].slot_type[i] = STACK_SPILL;
 	} else {
 		/* regular write of data into stack */
-		state->spilled_regs[spi] = (struct bpf_reg_state) {};
+		state->stack[spi].spilled_ptr = (struct bpf_reg_state) {};
 
 		for (i = 0; i < size; i++)
-			state->stack_slot_type[MAX_BPF_STACK + off + i] = STACK_MISC;
+			state->stack[spi].slot_type[(slot - i) % BPF_REG_SIZE] =
+				STACK_MISC;
 	}
 	return 0;
 }
@@ -637,10 +706,10 @@ static void mark_stack_slot_read(const struct bpf_verifier_state *state, int slo
 
 	while (parent) {
 		/* if read wasn't screened by an earlier write ... */
-		if (state->spilled_regs[slot].live & REG_LIVE_WRITTEN)
+		if (state->stack[slot].spilled_ptr.live & REG_LIVE_WRITTEN)
 			break;
 		/* ... then we depend on parent's value */
-		parent->spilled_regs[slot].live |= REG_LIVE_READ;
+		parent->stack[slot].spilled_ptr.live |= REG_LIVE_READ;
 		state = parent;
 		parent = state->parent;
 	}
@@ -650,34 +719,37 @@ static int check_stack_read(struct bpf_verifier_env *env,
 			    struct bpf_verifier_state *state, int off, int size,
 			    int value_regno)
 {
-	u8 *slot_type;
-	int i, spi;
+	u8 *stype;
+	int i, slot = -off - 1, spi = slot / BPF_REG_SIZE;
 
-	slot_type = &state->stack_slot_type[MAX_BPF_STACK + off];
+	if (state->allocated_stack <= slot) {
+		verbose(env, "invalid read from stack off %d+0 size %d\n",
+			off, size);
+		return -EACCES;
+	}
+	stype = state->stack[spi].slot_type;
 
-	if (slot_type[0] == STACK_SPILL) {
+	if (stype[0] == STACK_SPILL) {
 		if (size != BPF_REG_SIZE) {
 			verbose(env, "invalid size of register spill\n");
 			return -EACCES;
 		}
 		for (i = 1; i < BPF_REG_SIZE; i++) {
-			if (slot_type[i] != STACK_SPILL) {
+			if (stype[(slot - i) % BPF_REG_SIZE] != STACK_SPILL) {
 				verbose(env, "corrupted spill memory\n");
 				return -EACCES;
 			}
 		}
 
-		spi = (MAX_BPF_STACK + off) / BPF_REG_SIZE;
-
 		if (value_regno >= 0) {
 			/* restore register state from stack */
-			state->regs[value_regno] = state->spilled_regs[spi];
+			state->regs[value_regno] = state->stack[spi].spilled_ptr;
 			mark_stack_slot_read(state, spi);
 		}
 		return 0;
 	} else {
 		for (i = 0; i < size; i++) {
-			if (slot_type[i] != STACK_MISC) {
+			if (stype[(slot - i) % BPF_REG_SIZE] != STACK_MISC) {
 				verbose(env, "invalid read from stack off %d+%d size %d\n",
 					off, i, size);
 				return -EACCES;
@@ -694,7 +766,8 @@ static int check_stack_read(struct bpf_verifier_env *env,
 static int __check_map_access(struct bpf_verifier_env *env, u32 regno, int off,
 			    int size)
 {
-	struct bpf_map *map = env->cur_state.regs[regno].map_ptr;
+	struct bpf_reg_state *regs = cur_regs(env);
+	struct bpf_map *map = regs[regno].map_ptr;
 
 	if (off < 0 || size <= 0 || off + size > map->value_size) {
 		verbose(env, "invalid access to map value, value_size=%d off=%d size=%d\n",
@@ -706,9 +779,9 @@ static int __check_map_access(struct bpf_verifier_env *env, u32 regno, int off,
 
 /* check read/write into a map element with possible variable offset */
 static int check_map_access(struct bpf_verifier_env *env, u32 regno,
-				int off, int size)
+			    int off, int size)
 {
-	struct bpf_verifier_state *state = &env->cur_state;
+	struct bpf_verifier_state *state = env->cur_state;
 	struct bpf_reg_state *reg = &state->regs[regno];
 	int err;
 
@@ -783,7 +856,7 @@ static bool may_access_direct_pkt_data(struct bpf_verifier_env *env,
 static int __check_packet_access(struct bpf_verifier_env *env, u32 regno,
 				 int off, int size)
 {
-	struct bpf_reg_state *regs = env->cur_state.regs;
+	struct bpf_reg_state *regs = cur_regs(env);
 	struct bpf_reg_state *reg = &regs[regno];
 
 	if (off < 0 || size <= 0 || (u64)off + size > reg->range) {
@@ -797,7 +870,7 @@ static int __check_packet_access(struct bpf_verifier_env *env, u32 regno,
 static int check_packet_access(struct bpf_verifier_env *env, u32 regno, int off,
 			       int size)
 {
-	struct bpf_reg_state *regs = env->cur_state.regs;
+	struct bpf_reg_state *regs = cur_regs(env);
 	struct bpf_reg_state *reg = &regs[regno];
 	int err;
 
@@ -866,7 +939,7 @@ static bool __is_pointer_value(bool allow_ptr_leaks,
 
 static bool is_pointer_value(struct bpf_verifier_env *env, int regno)
 {
-	return __is_pointer_value(env->allow_ptr_leaks, &env->cur_state.regs[regno]);
+	return __is_pointer_value(env->allow_ptr_leaks, cur_regs(env) + regno);
 }
 
 static int check_pkt_ptr_alignment(struct bpf_verifier_env *env,
@@ -968,8 +1041,9 @@ static int check_mem_access(struct bpf_verifier_env *env, int insn_idx, u32 regn
 			    int bpf_size, enum bpf_access_type t,
 			    int value_regno)
 {
-	struct bpf_verifier_state *state = &env->cur_state;
-	struct bpf_reg_state *reg = &state->regs[regno];
+	struct bpf_verifier_state *state = env->cur_state;
+	struct bpf_reg_state *regs = cur_regs(env);
+	struct bpf_reg_state *reg = regs + regno;
 	int size, err = 0;
 
 	size = bpf_size_to_bytes(bpf_size);
@@ -993,7 +1067,7 @@ static int check_mem_access(struct bpf_verifier_env *env, int insn_idx, u32 regn
 
 		err = check_map_access(env, regno, off, size);
 		if (!err && t == BPF_READ && value_regno >= 0)
-			mark_reg_unknown(env, state->regs, value_regno);
+			mark_reg_unknown(env, regs, value_regno);
 
 	} else if (reg->type == PTR_TO_CTX) {
 		enum bpf_reg_type reg_type = SCALAR_VALUE;
@@ -1028,14 +1102,14 @@ static int check_mem_access(struct bpf_verifier_env *env, int insn_idx, u32 regn
 			 * case, we know the offset is zero.
 			 */
 			if (reg_type == SCALAR_VALUE)
-				mark_reg_unknown(env, state->regs, value_regno);
+				mark_reg_unknown(env, regs, value_regno);
 			else
-				mark_reg_known_zero(env, state->regs,
+				mark_reg_known_zero(env, regs,
 						    value_regno);
-			state->regs[value_regno].id = 0;
-			state->regs[value_regno].off = 0;
-			state->regs[value_regno].range = 0;
-			state->regs[value_regno].type = reg_type;
+			regs[value_regno].id = 0;
+			regs[value_regno].off = 0;
+			regs[value_regno].range = 0;
+			regs[value_regno].type = reg_type;
 		}
 
 	} else if (reg->type == PTR_TO_STACK) {
@@ -1062,14 +1136,9 @@ static int check_mem_access(struct bpf_verifier_env *env, int insn_idx, u32 regn
 			env->prog->aux->stack_depth = -off;
 
 		if (t == BPF_WRITE) {
-			if (!env->allow_ptr_leaks &&
-			    state->stack_slot_type[MAX_BPF_STACK + off] == STACK_SPILL &&
-			    size != BPF_REG_SIZE) {
-				verbose(env, "attempt to corrupt spilled pointer on stack\n");
-				return -EACCES;
-			}
 			err = check_stack_write(env, state, off, size,
 						value_regno);
+			regs = cur_regs(env);
 		} else {
 			err = check_stack_read(env, state, off, size,
 					       value_regno);
@@ -1087,7 +1156,7 @@ static int check_mem_access(struct bpf_verifier_env *env, int insn_idx, u32 regn
 		}
 		err = check_packet_access(env, regno, off, size);
 		if (!err && t == BPF_READ && value_regno >= 0)
-			mark_reg_unknown(env, state->regs, value_regno);
+			mark_reg_unknown(env, regs, value_regno);
 	} else {
 		verbose(env, "R%d invalid mem access '%s'\n", regno,
 			reg_type_str[reg->type]);
@@ -1095,11 +1164,11 @@ static int check_mem_access(struct bpf_verifier_env *env, int insn_idx, u32 regn
 	}
 
 	if (!err && size < BPF_REG_SIZE && value_regno >= 0 && t == BPF_READ &&
-	    state->regs[value_regno].type == SCALAR_VALUE) {
+	    regs[value_regno].type == SCALAR_VALUE) {
 		/* b/h/w load zero-extends, mark upper bits as known 0 */
-		state->regs[value_regno].var_off = tnum_cast(
-					state->regs[value_regno].var_off, size);
-		__update_reg_bounds(&state->regs[value_regno]);
+		regs[value_regno].var_off =
+			tnum_cast(regs[value_regno].var_off, size);
+		__update_reg_bounds(&regs[value_regno]);
 	}
 	return err;
 }
@@ -1156,9 +1225,9 @@ static int check_stack_boundary(struct bpf_verifier_env *env, int regno,
 				int access_size, bool zero_size_allowed,
 				struct bpf_call_arg_meta *meta)
 {
-	struct bpf_verifier_state *state = &env->cur_state;
+	struct bpf_verifier_state *state = env->cur_state;
 	struct bpf_reg_state *regs = state->regs;
-	int off, i;
+	int off, i, slot, spi;
 
 	if (regs[regno].type != PTR_TO_STACK) {
 		/* Allow zero-byte read from NULL, regardless of pointer type */
@@ -1198,7 +1267,11 @@ static int check_stack_boundary(struct bpf_verifier_env *env, int regno,
 	}
 
 	for (i = 0; i < access_size; i++) {
-		if (state->stack_slot_type[MAX_BPF_STACK + off + i] != STACK_MISC) {
+		slot = -(off + i) - 1;
+		spi = slot / BPF_REG_SIZE;
+		if (state->allocated_stack <= slot ||
+		    state->stack[spi].slot_type[slot % BPF_REG_SIZE] !=
+			STACK_MISC) {
 			verbose(env, "invalid indirect read from stack off %d+%d size %d\n",
 				off, i, access_size);
 			return -EACCES;
@@ -1211,7 +1284,7 @@ static int check_helper_mem_access(struct bpf_verifier_env *env, int regno,
 				   int access_size, bool zero_size_allowed,
 				   struct bpf_call_arg_meta *meta)
 {
-	struct bpf_reg_state *regs = env->cur_state.regs, *reg = &regs[regno];
+	struct bpf_reg_state *regs = cur_regs(env), *reg = &regs[regno];
 
 	switch (reg->type) {
 	case PTR_TO_PACKET:
@@ -1229,7 +1302,7 @@ static int check_func_arg(struct bpf_verifier_env *env, u32 regno,
 			  enum bpf_arg_type arg_type,
 			  struct bpf_call_arg_meta *meta)
 {
-	struct bpf_reg_state *regs = env->cur_state.regs, *reg = &regs[regno];
+	struct bpf_reg_state *regs = cur_regs(env), *reg = &regs[regno];
 	enum bpf_reg_type expected_type, type = reg->type;
 	int err = 0;
 
@@ -1514,7 +1587,7 @@ static int check_raw_mode(const struct bpf_func_proto *fn)
  */
 static void clear_all_pkt_pointers(struct bpf_verifier_env *env)
 {
-	struct bpf_verifier_state *state = &env->cur_state;
+	struct bpf_verifier_state *state = env->cur_state;
 	struct bpf_reg_state *regs = state->regs, *reg;
 	int i;
 
@@ -1522,10 +1595,10 @@ static void clear_all_pkt_pointers(struct bpf_verifier_env *env)
 		if (reg_is_pkt_pointer_any(&regs[i]))
 			mark_reg_unknown(env, regs, i);
 
-	for (i = 0; i < MAX_BPF_STACK; i += BPF_REG_SIZE) {
-		if (state->stack_slot_type[i] != STACK_SPILL)
+	for (i = 0; i < state->allocated_stack / BPF_REG_SIZE; i++) {
+		if (state->stack[i].slot_type[0] != STACK_SPILL)
 			continue;
-		reg = &state->spilled_regs[i / BPF_REG_SIZE];
+		reg = &state->stack[i].spilled_ptr;
 		if (reg_is_pkt_pointer_any(reg))
 			__mark_reg_unknown(reg);
 	}
@@ -1533,9 +1606,8 @@ static void clear_all_pkt_pointers(struct bpf_verifier_env *env)
 
 static int check_call(struct bpf_verifier_env *env, int func_id, int insn_idx)
 {
-	struct bpf_verifier_state *state = &env->cur_state;
 	const struct bpf_func_proto *fn = NULL;
-	struct bpf_reg_state *regs = state->regs;
+	struct bpf_reg_state *regs;
 	struct bpf_call_arg_meta meta;
 	bool changes_data;
 	int i, err;
@@ -1603,6 +1675,7 @@ static int check_call(struct bpf_verifier_env *env, int func_id, int insn_idx)
 			return err;
 	}
 
+	regs = env->cur_state->regs;
 	/* reset caller saved regs */
 	for (i = 0; i < CALLER_SAVED_REGS; i++) {
 		mark_reg_not_init(env, regs, caller_saved[i]);
@@ -1691,7 +1764,7 @@ static int adjust_ptr_min_max_vals(struct bpf_verifier_env *env,
 				   const struct bpf_reg_state *ptr_reg,
 				   const struct bpf_reg_state *off_reg)
 {
-	struct bpf_reg_state *regs = env->cur_state.regs, *dst_reg;
+	struct bpf_reg_state *regs = cur_regs(env), *dst_reg;
 	bool known = tnum_is_const(off_reg->var_off);
 	s64 smin_val = off_reg->smin_value, smax_val = off_reg->smax_value,
 	    smin_ptr = ptr_reg->smin_value, smax_ptr = ptr_reg->smax_value;
@@ -1703,13 +1776,13 @@ static int adjust_ptr_min_max_vals(struct bpf_verifier_env *env,
 	dst_reg = &regs[dst];
 
 	if (WARN_ON_ONCE(known && (smin_val != smax_val))) {
-		print_verifier_state(env, &env->cur_state);
+		print_verifier_state(env, env->cur_state);
 		verbose(env,
 			"verifier internal error: known but bad sbounds\n");
 		return -EINVAL;
 	}
 	if (WARN_ON_ONCE(known && (umin_val != umax_val))) {
-		print_verifier_state(env, &env->cur_state);
+		print_verifier_state(env, env->cur_state);
 		verbose(env,
 			"verifier internal error: known but bad ubounds\n");
 		return -EINVAL;
@@ -1890,7 +1963,7 @@ static int adjust_scalar_min_max_vals(struct bpf_verifier_env *env,
 				      struct bpf_reg_state *dst_reg,
 				      struct bpf_reg_state src_reg)
 {
-	struct bpf_reg_state *regs = env->cur_state.regs;
+	struct bpf_reg_state *regs = cur_regs(env);
 	u8 opcode = BPF_OP(insn->code);
 	bool src_known, dst_known;
 	s64 smin_val, smax_val;
@@ -2111,7 +2184,7 @@ static int adjust_scalar_min_max_vals(struct bpf_verifier_env *env,
 static int adjust_reg_min_max_vals(struct bpf_verifier_env *env,
 				   struct bpf_insn *insn)
 {
-	struct bpf_reg_state *regs = env->cur_state.regs, *dst_reg, *src_reg;
+	struct bpf_reg_state *regs = cur_regs(env), *dst_reg, *src_reg;
 	struct bpf_reg_state *ptr_reg = NULL, off_reg = {0};
 	u8 opcode = BPF_OP(insn->code);
 	int rc;
@@ -2185,12 +2258,12 @@ static int adjust_reg_min_max_vals(struct bpf_verifier_env *env,
 
 	/* Got here implies adding two SCALAR_VALUEs */
 	if (WARN_ON_ONCE(ptr_reg)) {
-		print_verifier_state(env, &env->cur_state);
+		print_verifier_state(env, env->cur_state);
 		verbose(env, "verifier internal error: unexpected ptr_reg\n");
 		return -EINVAL;
 	}
 	if (WARN_ON(!src_reg)) {
-		print_verifier_state(env, &env->cur_state);
+		print_verifier_state(env, env->cur_state);
 		verbose(env, "verifier internal error: no src_reg\n");
 		return -EINVAL;
 	}
@@ -2200,7 +2273,7 @@ static int adjust_reg_min_max_vals(struct bpf_verifier_env *env,
 /* check validity of 32-bit and 64-bit arithmetic operations */
 static int check_alu_op(struct bpf_verifier_env *env, struct bpf_insn *insn)
 {
-	struct bpf_reg_state *regs = env->cur_state.regs;
+	struct bpf_reg_state *regs = cur_regs(env);
 	u8 opcode = BPF_OP(insn->code);
 	int err;
 
@@ -2421,10 +2494,10 @@ static void find_good_pkt_pointers(struct bpf_verifier_state *state,
 			/* keep the maximum range already checked */
 			regs[i].range = max(regs[i].range, new_range);
 
-	for (i = 0; i < MAX_BPF_STACK; i += BPF_REG_SIZE) {
-		if (state->stack_slot_type[i] != STACK_SPILL)
+	for (i = 0; i < state->allocated_stack / BPF_REG_SIZE; i++) {
+		if (state->stack[i].slot_type[0] != STACK_SPILL)
 			continue;
-		reg = &state->spilled_regs[i / BPF_REG_SIZE];
+		reg = &state->stack[i].spilled_ptr;
 		if (reg->type == type && reg->id == dst_reg->id)
 			reg->range = max_t(u16, reg->range, new_range);
 	}
@@ -2674,17 +2747,17 @@ static void mark_map_regs(struct bpf_verifier_state *state, u32 regno,
 	for (i = 0; i < MAX_BPF_REG; i++)
 		mark_map_reg(regs, i, id, is_null);
 
-	for (i = 0; i < MAX_BPF_STACK; i += BPF_REG_SIZE) {
-		if (state->stack_slot_type[i] != STACK_SPILL)
+	for (i = 0; i < state->allocated_stack / BPF_REG_SIZE; i++) {
+		if (state->stack[i].slot_type[0] != STACK_SPILL)
 			continue;
-		mark_map_reg(state->spilled_regs, i / BPF_REG_SIZE, id, is_null);
+		mark_map_reg(&state->stack[i].spilled_ptr, 0, id, is_null);
 	}
 }
 
 static int check_cond_jmp_op(struct bpf_verifier_env *env,
 			     struct bpf_insn *insn, int *insn_idx)
 {
-	struct bpf_verifier_state *other_branch, *this_branch = &env->cur_state;
+	struct bpf_verifier_state *other_branch, *this_branch = env->cur_state;
 	struct bpf_reg_state *regs = this_branch->regs, *dst_reg;
 	u8 opcode = BPF_OP(insn->code);
 	int err;
@@ -2876,7 +2949,7 @@ static struct bpf_map *ld_imm64_to_map_ptr(struct bpf_insn *insn)
 /* verify BPF_LD_IMM64 instruction */
 static int check_ld_imm(struct bpf_verifier_env *env, struct bpf_insn *insn)
 {
-	struct bpf_reg_state *regs = env->cur_state.regs;
+	struct bpf_reg_state *regs = cur_regs(env);
 	int err;
 
 	if (BPF_SIZE(insn->code) != BPF_DW) {
@@ -2937,7 +3010,7 @@ static bool may_access_skb(enum bpf_prog_type type)
  */
 static int check_ld_abs(struct bpf_verifier_env *env, struct bpf_insn *insn)
 {
-	struct bpf_reg_state *regs = env->cur_state.regs;
+	struct bpf_reg_state *regs = cur_regs(env);
 	u8 mode = BPF_MODE(insn->code);
 	int i, err;
 
@@ -2999,7 +3072,7 @@ static int check_return_code(struct bpf_verifier_env *env)
 		return 0;
 	}
 
-	reg = &env->cur_state.regs[BPF_REG_0];
+	reg = cur_regs(env) + BPF_REG_0;
 	if (reg->type != SCALAR_VALUE) {
 		verbose(env, "At program exit the register R0 is not a known value (%s)\n",
 			reg_type_str[reg->type]);
@@ -3363,6 +3436,57 @@ static bool regsafe(struct bpf_reg_state *rold, struct bpf_reg_state *rcur,
 	return false;
 }
 
+static bool stacksafe(struct bpf_verifier_state *old,
+		      struct bpf_verifier_state *cur,
+		      struct idpair *idmap)
+{
+	int i, spi;
+
+	/* if explored stack has more populated slots than current stack
+	 * such stacks are not equivalent
+	 */
+	if (old->allocated_stack > cur->allocated_stack)
+		return false;
+
+	/* walk slots of the explored stack and ignore any additional
+	 * slots in the current stack, since explored(safe) state
+	 * didn't use them
+	 */
+	for (i = 0; i < old->allocated_stack; i++) {
+		spi = i / BPF_REG_SIZE;
+
+		if (old->stack[spi].slot_type[i % BPF_REG_SIZE] == STACK_INVALID)
+			continue;
+		if (old->stack[spi].slot_type[i % BPF_REG_SIZE] !=
+		    cur->stack[spi].slot_type[i % BPF_REG_SIZE])
+			/* Ex: old explored (safe) state has STACK_SPILL in
+			 * this stack slot, but current has has STACK_MISC ->
+			 * this verifier states are not equivalent,
+			 * return false to continue verification of this path
+			 */
+			return false;
+		if (i % BPF_REG_SIZE)
+			continue;
+		if (old->stack[spi].slot_type[0] != STACK_SPILL)
+			continue;
+		if (!regsafe(&old->stack[spi].spilled_ptr,
+			     &cur->stack[spi].spilled_ptr,
+			     idmap))
+			/* when explored and current stack slot are both storing
+			 * spilled registers, check that stored pointers types
+			 * are the same as well.
+			 * Ex: explored safe path could have stored
+			 * (bpf_reg_state) {.type = PTR_TO_STACK, .off = -8}
+			 * but current path has stored:
+			 * (bpf_reg_state) {.type = PTR_TO_STACK, .off = -16}
+			 * such verifier states are not equivalent.
+			 * return false to continue verification of this path
+			 */
+			return false;
+	}
+	return true;
+}
+
 /* compare two verifier states
  *
  * all states stored in state_list are known to be valid, since
@@ -3407,37 +3531,8 @@ static bool states_equal(struct bpf_verifier_env *env,
 			goto out_free;
 	}
 
-	for (i = 0; i < MAX_BPF_STACK; i++) {
-		if (old->stack_slot_type[i] == STACK_INVALID)
-			continue;
-		if (old->stack_slot_type[i] != cur->stack_slot_type[i])
-			/* Ex: old explored (safe) state has STACK_SPILL in
-			 * this stack slot, but current has has STACK_MISC ->
-			 * this verifier states are not equivalent,
-			 * return false to continue verification of this path
-			 */
-			goto out_free;
-		if (i % BPF_REG_SIZE)
-			continue;
-		if (old->stack_slot_type[i] != STACK_SPILL)
-			continue;
-		if (!regsafe(&old->spilled_regs[i / BPF_REG_SIZE],
-			     &cur->spilled_regs[i / BPF_REG_SIZE],
-			     idmap))
-			/* when explored and current stack slot are both storing
-			 * spilled registers, check that stored pointers types
-			 * are the same as well.
-			 * Ex: explored safe path could have stored
-			 * (bpf_reg_state) {.type = PTR_TO_STACK, .off = -8}
-			 * but current path has stored:
-			 * (bpf_reg_state) {.type = PTR_TO_STACK, .off = -16}
-			 * such verifier states are not equivalent.
-			 * return false to continue verification of this path
-			 */
-			goto out_free;
-		else
-			continue;
-	}
+	if (!stacksafe(old, cur, idmap))
+		goto out_free;
 	ret = true;
 out_free:
 	kfree(idmap);
@@ -3473,17 +3568,20 @@ static bool do_propagate_liveness(const struct bpf_verifier_state *state,
 		}
 	}
 	/* ... and stack slots */
-	for (i = 0; i < MAX_BPF_STACK / BPF_REG_SIZE; i++) {
-		if (parent->stack_slot_type[i * BPF_REG_SIZE] != STACK_SPILL)
+	for (i = 0; i < state->allocated_stack / BPF_REG_SIZE; i++) {
+		if (parent->allocated_stack <= i * BPF_REG_SIZE)
+			continue;
+		if (parent->stack[i].slot_type[0] != STACK_SPILL)
 			continue;
-		if (state->stack_slot_type[i * BPF_REG_SIZE] != STACK_SPILL)
+		if (state->stack[i].slot_type[0] != STACK_SPILL)
 			continue;
-		if (parent->spilled_regs[i].live & REG_LIVE_READ)
+		if (parent->stack[i].spilled_ptr.live & REG_LIVE_READ)
 			continue;
-		if (writes && (state->spilled_regs[i].live & REG_LIVE_WRITTEN))
+		if (writes &&
+		    (state->stack[i].spilled_ptr.live & REG_LIVE_WRITTEN))
 			continue;
-		if (state->spilled_regs[i].live & REG_LIVE_READ) {
-			parent->spilled_regs[i].live |= REG_LIVE_READ;
+		if (state->stack[i].spilled_ptr.live & REG_LIVE_READ) {
+			parent->stack[i].spilled_ptr.live |= REG_LIVE_READ;
 			touched = true;
 		}
 	}
@@ -3513,6 +3611,7 @@ static int is_state_visited(struct bpf_verifier_env *env, int insn_idx)
 {
 	struct bpf_verifier_state_list *new_sl;
 	struct bpf_verifier_state_list *sl;
+	struct bpf_verifier_state *cur = env->cur_state;
 	int i;
 
 	sl = env->explored_states[insn_idx];
@@ -3523,7 +3622,7 @@ static int is_state_visited(struct bpf_verifier_env *env, int insn_idx)
 		return 0;
 
 	while (sl != STATE_LIST_MARK) {
-		if (states_equal(env, &sl->state, &env->cur_state)) {
+		if (states_equal(env, &sl->state, cur)) {
 			/* reached equivalent register/stack state,
 			 * prune the search.
 			 * Registers read by the continuation are read by us.
@@ -3534,7 +3633,7 @@ static int is_state_visited(struct bpf_verifier_env *env, int insn_idx)
 			 * they'll be immediately forgotten as we're pruning
 			 * this state and will pop a new one.
 			 */
-			propagate_liveness(&sl->state, &env->cur_state);
+			propagate_liveness(&sl->state, cur);
 			return 1;
 		}
 		sl = sl->next;
@@ -3546,16 +3645,19 @@ static int is_state_visited(struct bpf_verifier_env *env, int insn_idx)
 	 * it will be rejected. Since there are no loops, we won't be
 	 * seeing this 'insn_idx' instruction again on the way to bpf_exit
 	 */
-	new_sl = kmalloc(sizeof(struct bpf_verifier_state_list), GFP_USER);
+	new_sl = kzalloc(offsetof(struct bpf_verifier_state_list,
+				  state.stack[cur->allocated_stack / BPF_REG_SIZE]),
+			 GFP_USER);
 	if (!new_sl)
 		return -ENOMEM;
 
+	new_sl->state.allocated_stack = cur->allocated_stack;
 	/* add new state to the head of linked list */
-	memcpy(&new_sl->state, &env->cur_state, sizeof(env->cur_state));
+	copy_verifier_state(&new_sl->state, cur);
 	new_sl->next = env->explored_states[insn_idx];
 	env->explored_states[insn_idx] = new_sl;
 	/* connect new state to parentage chain */
-	env->cur_state.parent = &new_sl->state;
+	cur->parent = &new_sl->state;
 	/* clear write marks in current state: the writes we did are not writes
 	 * our child did, so they don't screen off its reads from us.
 	 * (There are no read marks in current state, because reads always mark
@@ -3563,10 +3665,10 @@ static int is_state_visited(struct bpf_verifier_env *env, int insn_idx)
 	 * explored_states can get read marks.)
 	 */
 	for (i = 0; i < BPF_REG_FP; i++)
-		env->cur_state.regs[i].live = REG_LIVE_NONE;
-	for (i = 0; i < MAX_BPF_STACK / BPF_REG_SIZE; i++)
-		if (env->cur_state.stack_slot_type[i * BPF_REG_SIZE] == STACK_SPILL)
-			env->cur_state.spilled_regs[i].live = REG_LIVE_NONE;
+		cur->regs[i].live = REG_LIVE_NONE;
+	for (i = 0; i < cur->allocated_stack / BPF_REG_SIZE; i++)
+		if (cur->stack[i].slot_type[0] == STACK_SPILL)
+			cur->stack[i].spilled_ptr.live = REG_LIVE_NONE;
 	return 0;
 }
 
@@ -3581,15 +3683,18 @@ static int ext_analyzer_insn_hook(struct bpf_verifier_env *env,
 
 static int do_check(struct bpf_verifier_env *env)
 {
-	struct bpf_verifier_state *state = &env->cur_state;
+	struct bpf_verifier_state *state;
 	struct bpf_insn *insns = env->prog->insnsi;
-	struct bpf_reg_state *regs = state->regs;
 	int insn_cnt = env->prog->len;
 	int insn_idx, prev_insn_idx = 0;
 	int insn_processed = 0;
 	bool do_print_state = false;
 
-	init_reg_state(env, regs);
+	state = realloc_verifier_state(NULL, 0);
+	if (!state)
+		return -ENOMEM;
+	env->cur_state = state;
+	init_reg_state(env, state->regs);
 	state->parent = NULL;
 	insn_idx = 0;
 	for (;;) {
@@ -3631,13 +3736,14 @@ static int do_check(struct bpf_verifier_env *env)
 		if (need_resched())
 			cond_resched();
 
+		state = env->cur_state;
 		if (env->log.level > 1 || (env->log.level && do_print_state)) {
 			if (env->log.level > 1)
 				verbose(env, "%d:", insn_idx);
 			else
 				verbose(env, "\nfrom %d to %d:",
 					prev_insn_idx, insn_idx);
-			print_verifier_state(env, &env->cur_state);
+			print_verifier_state(env, state);
 			do_print_state = false;
 		}
 
@@ -3670,7 +3776,7 @@ static int do_check(struct bpf_verifier_env *env)
 			if (err)
 				return err;
 
-			src_reg_type = regs[insn->src_reg].type;
+			src_reg_type = state->regs[insn->src_reg].type;
 
 			/* check that memory (src_reg + off) is readable,
 			 * the state of dst_reg will be updated by this func
@@ -3724,7 +3830,7 @@ static int do_check(struct bpf_verifier_env *env)
 			if (err)
 				return err;
 
-			dst_reg_type = regs[insn->dst_reg].type;
+			dst_reg_type = state->regs[insn->dst_reg].type;
 
 			/* check that memory (dst_reg + off) is writeable */
 			err = check_mem_access(env, insn_idx, insn->dst_reg, insn->off,
@@ -4359,6 +4465,8 @@ int bpf_check(struct bpf_prog **prog, union bpf_attr *attr)
 	env->allow_ptr_leaks = capable(CAP_SYS_ADMIN);
 
 	ret = do_check(env);
+	kfree(env->cur_state);
+	env->cur_state = NULL;
 
 skip_full_check:
 	while (pop_stack(env, NULL) >= 0);
@@ -4464,6 +4572,8 @@ int bpf_analyzer(struct bpf_prog *prog, const struct bpf_ext_analyzer_ops *ops,
 	env->allow_ptr_leaks = capable(CAP_SYS_ADMIN);
 
 	ret = do_check(env);
+	kfree(env->cur_state);
+	env->cur_state = NULL;
 
 skip_full_check:
 	while (pop_stack(env, NULL) >= 0);
-- 
2.9.5
