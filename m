From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCHv6 net-next 05/15] bpf: expose internal verfier structures
Date: Sun, 18 Sep 2016 16:09:15 +0100
Message-ID: <1474211365-20088-6-git-send-email-jakub.kicinski@netronome.com>
References: <1474211365-20088-1-git-send-email-jakub.kicinski@netronome.com>
Cc: ast@kernel.org, daniel@iogearbox.net,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:36829 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932392AbcIRPJw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 11:09:52 -0400
Received: by mail-wm0-f41.google.com with SMTP id w84so37324594wmg.1
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2016 08:09:51 -0700 (PDT)
In-Reply-To: <1474211365-20088-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move verifier's internal structures to a header file and
prefix their names with bpf_ to avoid potential namespace
conflicts.  Those structures will soon be used by external
analyzers.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Acked-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
v5:
 - fix name of guard defines.
v4:
 - separate from adding the analyzer;
 - squash with the prefixing patch.
---
 include/linux/bpf_verifier.h |  78 +++++++++++++
 kernel/bpf/verifier.c        | 263 +++++++++++++++++--------------------------
 2 files changed, 180 insertions(+), 161 deletions(-)
 create mode 100644 include/linux/bpf_verifier.h

diff --git a/include/linux/bpf_verifier.h b/include/linux/bpf_verifier.h
new file mode 100644
index 000000000000..9056117b4a81
--- /dev/null
+++ b/include/linux/bpf_verifier.h
@@ -0,0 +1,78 @@
+/* Copyright (c) 2011-2014 PLUMgrid, http://plumgrid.com
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#ifndef _LINUX_BPF_VERIFIER_H
+#define _LINUX_BPF_VERIFIER_H 1
+
+#include <linux/bpf.h> /* for enum bpf_reg_type */
+#include <linux/filter.h> /* for MAX_BPF_STACK */
+
+struct bpf_reg_state {
+	enum bpf_reg_type type;
+	union {
+		/* valid when type == CONST_IMM | PTR_TO_STACK | UNKNOWN_VALUE */
+		s64 imm;
+
+		/* valid when type == PTR_TO_PACKET* */
+		struct {
+			u32 id;
+			u16 off;
+			u16 range;
+		};
+
+		/* valid when type == CONST_PTR_TO_MAP | PTR_TO_MAP_VALUE |
+		 *   PTR_TO_MAP_VALUE_OR_NULL
+		 */
+		struct bpf_map *map_ptr;
+	};
+};
+
+enum bpf_stack_slot_type {
+	STACK_INVALID,    /* nothing was stored in this stack slot */
+	STACK_SPILL,      /* register spilled into stack */
+	STACK_MISC	  /* BPF program wrote some data into this slot */
+};
+
+#define BPF_REG_SIZE 8	/* size of eBPF register in bytes */
+
+/* state of the program:
+ * type of all registers and stack info
+ */
+struct bpf_verifier_state {
+	struct bpf_reg_state regs[MAX_BPF_REG];
+	u8 stack_slot_type[MAX_BPF_STACK];
+	struct bpf_reg_state spilled_regs[MAX_BPF_STACK / BPF_REG_SIZE];
+};
+
+/* linked list of verifier states used to prune search */
+struct bpf_verifier_state_list {
+	struct bpf_verifier_state state;
+	struct bpf_verifier_state_list *next;
+};
+
+struct bpf_insn_aux_data {
+	enum bpf_reg_type ptr_type;	/* pointer type for load/store insns */
+};
+
+#define MAX_USED_MAPS 64 /* max number of maps accessed by one eBPF program */
+
+/* single container for all structs
+ * one verifier_env per bpf_check() call
+ */
+struct bpf_verifier_env {
+	struct bpf_prog *prog;		/* eBPF program being verified */
+	struct bpf_verifier_stack_elem *head; /* stack of verifier states to be processed */
+	int stack_size;			/* number of states to be processed */
+	struct bpf_verifier_state cur_state; /* current verifier state */
+	struct bpf_verifier_state_list **explored_states; /* search pruning optimization */
+	struct bpf_map *used_maps[MAX_USED_MAPS]; /* array of map's used by eBPF program */
+	u32 used_map_cnt;		/* number of used maps */
+	u32 id_gen;			/* used to generate unique reg IDs */
+	bool allow_ptr_leaks;
+	struct bpf_insn_aux_data *insn_aux_data; /* array of per-insn state */
+};
+
+#endif /* _LINUX_BPF_VERIFIER_H */
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index f5c1a4571331..9e0cd3fadf74 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -14,6 +14,7 @@
 #include <linux/types.h>
 #include <linux/slab.h>
 #include <linux/bpf.h>
+#include <linux/bpf_verifier.h>
 #include <linux/filter.h>
 #include <net/netlink.h>
 #include <linux/file.h>
@@ -126,81 +127,16 @@
  * are set to NOT_INIT to indicate that they are no longer readable.
  */
 
-struct reg_state {
-	enum bpf_reg_type type;
-	union {
-		/* valid when type == CONST_IMM | PTR_TO_STACK | UNKNOWN_VALUE */
-		s64 imm;
-
-		/* valid when type == PTR_TO_PACKET* */
-		struct {
-			u32 id;
-			u16 off;
-			u16 range;
-		};
-
-		/* valid when type == CONST_PTR_TO_MAP | PTR_TO_MAP_VALUE |
-		 *   PTR_TO_MAP_VALUE_OR_NULL
-		 */
-		struct bpf_map *map_ptr;
-	};
-};
-
-enum bpf_stack_slot_type {
-	STACK_INVALID,    /* nothing was stored in this stack slot */
-	STACK_SPILL,      /* register spilled into stack */
-	STACK_MISC	  /* BPF program wrote some data into this slot */
-};
-
-#define BPF_REG_SIZE 8	/* size of eBPF register in bytes */
-
-/* state of the program:
- * type of all registers and stack info
- */
-struct verifier_state {
-	struct reg_state regs[MAX_BPF_REG];
-	u8 stack_slot_type[MAX_BPF_STACK];
-	struct reg_state spilled_regs[MAX_BPF_STACK / BPF_REG_SIZE];
-};
-
-/* linked list of verifier states used to prune search */
-struct verifier_state_list {
-	struct verifier_state state;
-	struct verifier_state_list *next;
-};
-
 /* verifier_state + insn_idx are pushed to stack when branch is encountered */
-struct verifier_stack_elem {
+struct bpf_verifier_stack_elem {
 	/* verifer state is 'st'
 	 * before processing instruction 'insn_idx'
 	 * and after processing instruction 'prev_insn_idx'
 	 */
-	struct verifier_state st;
+	struct bpf_verifier_state st;
 	int insn_idx;
 	int prev_insn_idx;
-	struct verifier_stack_elem *next;
-};
-
-struct bpf_insn_aux_data {
-	enum bpf_reg_type ptr_type;	/* pointer type for load/store insns */
-};
-
-#define MAX_USED_MAPS 64 /* max number of maps accessed by one eBPF program */
-
-/* single container for all structs
- * one verifier_env per bpf_check() call
- */
-struct verifier_env {
-	struct bpf_prog *prog;		/* eBPF program being verified */
-	struct verifier_stack_elem *head; /* stack of verifier states to be processed */
-	int stack_size;			/* number of states to be processed */
-	struct verifier_state cur_state; /* current verifier state */
-	struct verifier_state_list **explored_states; /* search pruning optimization */
-	struct bpf_map *used_maps[MAX_USED_MAPS]; /* array of map's used by eBPF program */
-	u32 used_map_cnt;		/* number of used maps */
-	u32 id_gen;			/* used to generate unique reg IDs */
-	bool allow_ptr_leaks;
-	struct bpf_insn_aux_data *insn_aux_data; /* array of per-insn state */
+	struct bpf_verifier_stack_elem *next;
 };
 
 #define BPF_COMPLEXITY_LIMIT_INSNS	65536
@@ -252,9 +188,9 @@ static const char * const reg_type_str[] = {
 	[PTR_TO_PACKET_END]	= "pkt_end",
 };
 
-static void print_verifier_state(struct verifier_state *state)
+static void print_verifier_state(struct bpf_verifier_state *state)
 {
-	struct reg_state *reg;
+	struct bpf_reg_state *reg;
 	enum bpf_reg_type t;
 	int i;
 
@@ -430,9 +366,9 @@ static void print_bpf_insn(struct bpf_insn *insn)
 	}
 }
 
-static int pop_stack(struct verifier_env *env, int *prev_insn_idx)
+static int pop_stack(struct bpf_verifier_env *env, int *prev_insn_idx)
 {
-	struct verifier_stack_elem *elem;
+	struct bpf_verifier_stack_elem *elem;
 	int insn_idx;
 
 	if (env->head == NULL)
@@ -449,12 +385,12 @@ static int pop_stack(struct verifier_env *env, int *prev_insn_idx)
 	return insn_idx;
 }
 
-static struct verifier_state *push_stack(struct verifier_env *env, int insn_idx,
-					 int prev_insn_idx)
+static struct bpf_verifier_state *push_stack(struct bpf_verifier_env *env,
+					     int insn_idx, int prev_insn_idx)
 {
-	struct verifier_stack_elem *elem;
+	struct bpf_verifier_stack_elem *elem;
 
-	elem = kmalloc(sizeof(struct verifier_stack_elem), GFP_KERNEL);
+	elem = kmalloc(sizeof(struct bpf_verifier_stack_elem), GFP_KERNEL);
 	if (!elem)
 		goto err;
 
@@ -480,7 +416,7 @@ static const int caller_saved[CALLER_SAVED_REGS] = {
 	BPF_REG_0, BPF_REG_1, BPF_REG_2, BPF_REG_3, BPF_REG_4, BPF_REG_5
 };
 
-static void init_reg_state(struct reg_state *regs)
+static void init_reg_state(struct bpf_reg_state *regs)
 {
 	int i;
 
@@ -496,7 +432,7 @@ static void init_reg_state(struct reg_state *regs)
 	regs[BPF_REG_1].type = PTR_TO_CTX;
 }
 
-static void mark_reg_unknown_value(struct reg_state *regs, u32 regno)
+static void mark_reg_unknown_value(struct bpf_reg_state *regs, u32 regno)
 {
 	BUG_ON(regno >= MAX_BPF_REG);
 	regs[regno].type = UNKNOWN_VALUE;
@@ -509,7 +445,7 @@ enum reg_arg_type {
 	DST_OP_NO_MARK	/* same as above, check only, don't mark */
 };
 
-static int check_reg_arg(struct reg_state *regs, u32 regno,
+static int check_reg_arg(struct bpf_reg_state *regs, u32 regno,
 			 enum reg_arg_type t)
 {
 	if (regno >= MAX_BPF_REG) {
@@ -569,8 +505,8 @@ static bool is_spillable_regtype(enum bpf_reg_type type)
 /* check_stack_read/write functions track spill/fill of registers,
  * stack boundary and alignment are checked in check_mem_access()
  */
-static int check_stack_write(struct verifier_state *state, int off, int size,
-			     int value_regno)
+static int check_stack_write(struct bpf_verifier_state *state, int off,
+			     int size, int value_regno)
 {
 	int i;
 	/* caller checked that off % size == 0 and -MAX_BPF_STACK <= off < 0,
@@ -595,7 +531,7 @@ static int check_stack_write(struct verifier_state *state, int off, int size,
 	} else {
 		/* regular write of data into stack */
 		state->spilled_regs[(MAX_BPF_STACK + off) / BPF_REG_SIZE] =
-			(struct reg_state) {};
+			(struct bpf_reg_state) {};
 
 		for (i = 0; i < size; i++)
 			state->stack_slot_type[MAX_BPF_STACK + off + i] = STACK_MISC;
@@ -603,7 +539,7 @@ static int check_stack_write(struct verifier_state *state, int off, int size,
 	return 0;
 }
 
-static int check_stack_read(struct verifier_state *state, int off, int size,
+static int check_stack_read(struct bpf_verifier_state *state, int off, int size,
 			    int value_regno)
 {
 	u8 *slot_type;
@@ -644,7 +580,7 @@ static int check_stack_read(struct verifier_state *state, int off, int size,
 }
 
 /* check read/write into map element returned by bpf_map_lookup_elem() */
-static int check_map_access(struct verifier_env *env, u32 regno, int off,
+static int check_map_access(struct bpf_verifier_env *env, u32 regno, int off,
 			    int size)
 {
 	struct bpf_map *map = env->cur_state.regs[regno].map_ptr;
@@ -669,11 +605,11 @@ static bool may_write_pkt_data(enum bpf_prog_type type)
 	}
 }
 
-static int check_packet_access(struct verifier_env *env, u32 regno, int off,
+static int check_packet_access(struct bpf_verifier_env *env, u32 regno, int off,
 			       int size)
 {
-	struct reg_state *regs = env->cur_state.regs;
-	struct reg_state *reg = &regs[regno];
+	struct bpf_reg_state *regs = env->cur_state.regs;
+	struct bpf_reg_state *reg = &regs[regno];
 
 	off += reg->off;
 	if (off < 0 || off + size > reg->range) {
@@ -685,7 +621,7 @@ static int check_packet_access(struct verifier_env *env, u32 regno, int off,
 }
 
 /* check access to 'struct bpf_context' fields */
-static int check_ctx_access(struct verifier_env *env, int off, int size,
+static int check_ctx_access(struct bpf_verifier_env *env, int off, int size,
 			    enum bpf_access_type t, enum bpf_reg_type *reg_type)
 {
 	if (env->prog->aux->ops->is_valid_access &&
@@ -700,7 +636,7 @@ static int check_ctx_access(struct verifier_env *env, int off, int size,
 	return -EACCES;
 }
 
-static bool is_pointer_value(struct verifier_env *env, int regno)
+static bool is_pointer_value(struct bpf_verifier_env *env, int regno)
 {
 	if (env->allow_ptr_leaks)
 		return false;
@@ -714,12 +650,13 @@ static bool is_pointer_value(struct verifier_env *env, int regno)
 	}
 }
 
-static int check_ptr_alignment(struct verifier_env *env, struct reg_state *reg,
-			       int off, int size)
+static int check_ptr_alignment(struct bpf_verifier_env *env,
+			       struct bpf_reg_state *reg, int off, int size)
 {
 	if (reg->type != PTR_TO_PACKET) {
 		if (off % size != 0) {
-			verbose("misaligned access off %d size %d\n", off, size);
+			verbose("misaligned access off %d size %d\n",
+				off, size);
 			return -EACCES;
 		} else {
 			return 0;
@@ -760,12 +697,12 @@ static int check_ptr_alignment(struct verifier_env *env, struct reg_state *reg,
  * if t==write && value_regno==-1, some unknown value is stored into memory
  * if t==read && value_regno==-1, don't care what we read from memory
  */
-static int check_mem_access(struct verifier_env *env, u32 regno, int off,
+static int check_mem_access(struct bpf_verifier_env *env, u32 regno, int off,
 			    int bpf_size, enum bpf_access_type t,
 			    int value_regno)
 {
-	struct verifier_state *state = &env->cur_state;
-	struct reg_state *reg = &state->regs[regno];
+	struct bpf_verifier_state *state = &env->cur_state;
+	struct bpf_reg_state *reg = &state->regs[regno];
 	int size, err = 0;
 
 	if (reg->type == PTR_TO_STACK)
@@ -851,9 +788,9 @@ static int check_mem_access(struct verifier_env *env, u32 regno, int off,
 	return err;
 }
 
-static int check_xadd(struct verifier_env *env, struct bpf_insn *insn)
+static int check_xadd(struct bpf_verifier_env *env, struct bpf_insn *insn)
 {
-	struct reg_state *regs = env->cur_state.regs;
+	struct bpf_reg_state *regs = env->cur_state.regs;
 	int err;
 
 	if ((BPF_SIZE(insn->code) != BPF_W && BPF_SIZE(insn->code) != BPF_DW) ||
@@ -887,12 +824,12 @@ static int check_xadd(struct verifier_env *env, struct bpf_insn *insn)
  * bytes from that pointer, make sure that it's within stack boundary
  * and all elements of stack are initialized
  */
-static int check_stack_boundary(struct verifier_env *env, int regno,
+static int check_stack_boundary(struct bpf_verifier_env *env, int regno,
 				int access_size, bool zero_size_allowed,
 				struct bpf_call_arg_meta *meta)
 {
-	struct verifier_state *state = &env->cur_state;
-	struct reg_state *regs = state->regs;
+	struct bpf_verifier_state *state = &env->cur_state;
+	struct bpf_reg_state *regs = state->regs;
 	int off, i;
 
 	if (regs[regno].type != PTR_TO_STACK) {
@@ -931,11 +868,11 @@ static int check_stack_boundary(struct verifier_env *env, int regno,
 	return 0;
 }
 
-static int check_func_arg(struct verifier_env *env, u32 regno,
+static int check_func_arg(struct bpf_verifier_env *env, u32 regno,
 			  enum bpf_arg_type arg_type,
 			  struct bpf_call_arg_meta *meta)
 {
-	struct reg_state *regs = env->cur_state.regs, *reg = &regs[regno];
+	struct bpf_reg_state *regs = env->cur_state.regs, *reg = &regs[regno];
 	enum bpf_reg_type expected_type, type = reg->type;
 	int err = 0;
 
@@ -1140,10 +1077,10 @@ static int check_raw_mode(const struct bpf_func_proto *fn)
 	return count > 1 ? -EINVAL : 0;
 }
 
-static void clear_all_pkt_pointers(struct verifier_env *env)
+static void clear_all_pkt_pointers(struct bpf_verifier_env *env)
 {
-	struct verifier_state *state = &env->cur_state;
-	struct reg_state *regs = state->regs, *reg;
+	struct bpf_verifier_state *state = &env->cur_state;
+	struct bpf_reg_state *regs = state->regs, *reg;
 	int i;
 
 	for (i = 0; i < MAX_BPF_REG; i++)
@@ -1163,12 +1100,12 @@ static void clear_all_pkt_pointers(struct verifier_env *env)
 	}
 }
 
-static int check_call(struct verifier_env *env, int func_id)
+static int check_call(struct bpf_verifier_env *env, int func_id)
 {
-	struct verifier_state *state = &env->cur_state;
+	struct bpf_verifier_state *state = &env->cur_state;
 	const struct bpf_func_proto *fn = NULL;
-	struct reg_state *regs = state->regs;
-	struct reg_state *reg;
+	struct bpf_reg_state *regs = state->regs;
+	struct bpf_reg_state *reg;
 	struct bpf_call_arg_meta meta;
 	bool changes_data;
 	int i, err;
@@ -1270,12 +1207,13 @@ static int check_call(struct verifier_env *env, int func_id)
 	return 0;
 }
 
-static int check_packet_ptr_add(struct verifier_env *env, struct bpf_insn *insn)
+static int check_packet_ptr_add(struct bpf_verifier_env *env,
+				struct bpf_insn *insn)
 {
-	struct reg_state *regs = env->cur_state.regs;
-	struct reg_state *dst_reg = &regs[insn->dst_reg];
-	struct reg_state *src_reg = &regs[insn->src_reg];
-	struct reg_state tmp_reg;
+	struct bpf_reg_state *regs = env->cur_state.regs;
+	struct bpf_reg_state *dst_reg = &regs[insn->dst_reg];
+	struct bpf_reg_state *src_reg = &regs[insn->src_reg];
+	struct bpf_reg_state tmp_reg;
 	s32 imm;
 
 	if (BPF_SRC(insn->code) == BPF_K) {
@@ -1343,10 +1281,10 @@ static int check_packet_ptr_add(struct verifier_env *env, struct bpf_insn *insn)
 	return 0;
 }
 
-static int evaluate_reg_alu(struct verifier_env *env, struct bpf_insn *insn)
+static int evaluate_reg_alu(struct bpf_verifier_env *env, struct bpf_insn *insn)
 {
-	struct reg_state *regs = env->cur_state.regs;
-	struct reg_state *dst_reg = &regs[insn->dst_reg];
+	struct bpf_reg_state *regs = env->cur_state.regs;
+	struct bpf_reg_state *dst_reg = &regs[insn->dst_reg];
 	u8 opcode = BPF_OP(insn->code);
 	s64 imm_log2;
 
@@ -1356,7 +1294,7 @@ static int evaluate_reg_alu(struct verifier_env *env, struct bpf_insn *insn)
 	 */
 
 	if (BPF_SRC(insn->code) == BPF_X) {
-		struct reg_state *src_reg = &regs[insn->src_reg];
+		struct bpf_reg_state *src_reg = &regs[insn->src_reg];
 
 		if (src_reg->type == UNKNOWN_VALUE && src_reg->imm > 0 &&
 		    dst_reg->imm && opcode == BPF_ADD) {
@@ -1445,11 +1383,12 @@ static int evaluate_reg_alu(struct verifier_env *env, struct bpf_insn *insn)
 	return 0;
 }
 
-static int evaluate_reg_imm_alu(struct verifier_env *env, struct bpf_insn *insn)
+static int evaluate_reg_imm_alu(struct bpf_verifier_env *env,
+				struct bpf_insn *insn)
 {
-	struct reg_state *regs = env->cur_state.regs;
-	struct reg_state *dst_reg = &regs[insn->dst_reg];
-	struct reg_state *src_reg = &regs[insn->src_reg];
+	struct bpf_reg_state *regs = env->cur_state.regs;
+	struct bpf_reg_state *dst_reg = &regs[insn->dst_reg];
+	struct bpf_reg_state *src_reg = &regs[insn->src_reg];
 	u8 opcode = BPF_OP(insn->code);
 
 	/* dst_reg->type == CONST_IMM here, simulate execution of 'add' insn.
@@ -1466,9 +1405,9 @@ static int evaluate_reg_imm_alu(struct verifier_env *env, struct bpf_insn *insn)
 }
 
 /* check validity of 32-bit and 64-bit arithmetic operations */
-static int check_alu_op(struct verifier_env *env, struct bpf_insn *insn)
+static int check_alu_op(struct bpf_verifier_env *env, struct bpf_insn *insn)
 {
-	struct reg_state *regs = env->cur_state.regs, *dst_reg;
+	struct bpf_reg_state *regs = env->cur_state.regs, *dst_reg;
 	u8 opcode = BPF_OP(insn->code);
 	int err;
 
@@ -1642,10 +1581,10 @@ static int check_alu_op(struct verifier_env *env, struct bpf_insn *insn)
 	return 0;
 }
 
-static void find_good_pkt_pointers(struct verifier_state *state,
-				   const struct reg_state *dst_reg)
+static void find_good_pkt_pointers(struct bpf_verifier_state *state,
+				   struct bpf_reg_state *dst_reg)
 {
-	struct reg_state *regs = state->regs, *reg;
+	struct bpf_reg_state *regs = state->regs, *reg;
 	int i;
 
 	/* LLVM can generate two kind of checks:
@@ -1691,11 +1630,11 @@ static void find_good_pkt_pointers(struct verifier_state *state,
 	}
 }
 
-static int check_cond_jmp_op(struct verifier_env *env,
+static int check_cond_jmp_op(struct bpf_verifier_env *env,
 			     struct bpf_insn *insn, int *insn_idx)
 {
-	struct verifier_state *other_branch, *this_branch = &env->cur_state;
-	struct reg_state *regs = this_branch->regs, *dst_reg;
+	struct bpf_verifier_state *other_branch, *this_branch = &env->cur_state;
+	struct bpf_reg_state *regs = this_branch->regs, *dst_reg;
 	u8 opcode = BPF_OP(insn->code);
 	int err;
 
@@ -1757,7 +1696,7 @@ static int check_cond_jmp_op(struct verifier_env *env,
 	if (!other_branch)
 		return -EFAULT;
 
-	/* detect if R == 0 where R is returned value from bpf_map_lookup_elem() */
+	/* detect if R == 0 where R is returned from bpf_map_lookup_elem() */
 	if (BPF_SRC(insn->code) == BPF_K &&
 	    insn->imm == 0 && (opcode == BPF_JEQ || opcode == BPF_JNE) &&
 	    dst_reg->type == PTR_TO_MAP_VALUE_OR_NULL) {
@@ -1799,9 +1738,9 @@ static struct bpf_map *ld_imm64_to_map_ptr(struct bpf_insn *insn)
 }
 
 /* verify BPF_LD_IMM64 instruction */
-static int check_ld_imm(struct verifier_env *env, struct bpf_insn *insn)
+static int check_ld_imm(struct bpf_verifier_env *env, struct bpf_insn *insn)
 {
-	struct reg_state *regs = env->cur_state.regs;
+	struct bpf_reg_state *regs = env->cur_state.regs;
 	int err;
 
 	if (BPF_SIZE(insn->code) != BPF_DW) {
@@ -1856,11 +1795,11 @@ static bool may_access_skb(enum bpf_prog_type type)
  * Output:
  *   R0 - 8/16/32-bit skb data converted to cpu endianness
  */
-static int check_ld_abs(struct verifier_env *env, struct bpf_insn *insn)
+static int check_ld_abs(struct bpf_verifier_env *env, struct bpf_insn *insn)
 {
-	struct reg_state *regs = env->cur_state.regs;
+	struct bpf_reg_state *regs = env->cur_state.regs;
 	u8 mode = BPF_MODE(insn->code);
-	struct reg_state *reg;
+	struct bpf_reg_state *reg;
 	int i, err;
 
 	if (!may_access_skb(env->prog->type)) {
@@ -1946,7 +1885,7 @@ enum {
 	BRANCH = 2,
 };
 
-#define STATE_LIST_MARK ((struct verifier_state_list *) -1L)
+#define STATE_LIST_MARK ((struct bpf_verifier_state_list *) -1L)
 
 static int *insn_stack;	/* stack of insns to process */
 static int cur_stack;	/* current stack index */
@@ -1957,7 +1896,7 @@ static int *insn_state;
  * w - next instruction
  * e - edge
  */
-static int push_insn(int t, int w, int e, struct verifier_env *env)
+static int push_insn(int t, int w, int e, struct bpf_verifier_env *env)
 {
 	if (e == FALLTHROUGH && insn_state[t] >= (DISCOVERED | FALLTHROUGH))
 		return 0;
@@ -1998,7 +1937,7 @@ static int push_insn(int t, int w, int e, struct verifier_env *env)
 /* non-recursive depth-first-search to detect loops in BPF program
  * loop == back-edge in directed graph
  */
-static int check_cfg(struct verifier_env *env)
+static int check_cfg(struct bpf_verifier_env *env)
 {
 	struct bpf_insn *insns = env->prog->insnsi;
 	int insn_cnt = env->prog->len;
@@ -2107,7 +2046,8 @@ static int check_cfg(struct verifier_env *env)
 /* the following conditions reduce the number of explored insns
  * from ~140k to ~80k for ultra large programs that use a lot of ptr_to_packet
  */
-static bool compare_ptrs_to_packet(struct reg_state *old, struct reg_state *cur)
+static bool compare_ptrs_to_packet(struct bpf_reg_state *old,
+				   struct bpf_reg_state *cur)
 {
 	if (old->id != cur->id)
 		return false;
@@ -2182,9 +2122,10 @@ static bool compare_ptrs_to_packet(struct reg_state *old, struct reg_state *cur)
  * whereas register type in current state is meaningful, it means that
  * the current state will reach 'bpf_exit' instruction safely
  */
-static bool states_equal(struct verifier_state *old, struct verifier_state *cur)
+static bool states_equal(struct bpf_verifier_state *old,
+			 struct bpf_verifier_state *cur)
 {
-	struct reg_state *rold, *rcur;
+	struct bpf_reg_state *rold, *rcur;
 	int i;
 
 	for (i = 0; i < MAX_BPF_REG; i++) {
@@ -2224,9 +2165,9 @@ static bool states_equal(struct verifier_state *old, struct verifier_state *cur)
 			 * the same, check that stored pointers types
 			 * are the same as well.
 			 * Ex: explored safe path could have stored
-			 * (struct reg_state) {.type = PTR_TO_STACK, .imm = -8}
+			 * (bpf_reg_state) {.type = PTR_TO_STACK, .imm = -8}
 			 * but current path has stored:
-			 * (struct reg_state) {.type = PTR_TO_STACK, .imm = -16}
+			 * (bpf_reg_state) {.type = PTR_TO_STACK, .imm = -16}
 			 * such verifier states are not equivalent.
 			 * return false to continue verification of this path
 			 */
@@ -2237,10 +2178,10 @@ static bool states_equal(struct verifier_state *old, struct verifier_state *cur)
 	return true;
 }
 
-static int is_state_visited(struct verifier_env *env, int insn_idx)
+static int is_state_visited(struct bpf_verifier_env *env, int insn_idx)
 {
-	struct verifier_state_list *new_sl;
-	struct verifier_state_list *sl;
+	struct bpf_verifier_state_list *new_sl;
+	struct bpf_verifier_state_list *sl;
 
 	sl = env->explored_states[insn_idx];
 	if (!sl)
@@ -2264,7 +2205,7 @@ static int is_state_visited(struct verifier_env *env, int insn_idx)
 	 * it will be rejected. Since there are no loops, we won't be
 	 * seeing this 'insn_idx' instruction again on the way to bpf_exit
 	 */
-	new_sl = kmalloc(sizeof(struct verifier_state_list), GFP_USER);
+	new_sl = kmalloc(sizeof(struct bpf_verifier_state_list), GFP_USER);
 	if (!new_sl)
 		return -ENOMEM;
 
@@ -2275,11 +2216,11 @@ static int is_state_visited(struct verifier_env *env, int insn_idx)
 	return 0;
 }
 
-static int do_check(struct verifier_env *env)
+static int do_check(struct bpf_verifier_env *env)
 {
-	struct verifier_state *state = &env->cur_state;
+	struct bpf_verifier_state *state = &env->cur_state;
 	struct bpf_insn *insns = env->prog->insnsi;
-	struct reg_state *regs = state->regs;
+	struct bpf_reg_state *regs = state->regs;
 	int insn_cnt = env->prog->len;
 	int insn_idx, prev_insn_idx = 0;
 	int insn_processed = 0;
@@ -2562,7 +2503,7 @@ static int check_map_prog_compatibility(struct bpf_map *map,
 /* look for pseudo eBPF instructions that access map FDs and
  * replace them with actual map pointers
  */
-static int replace_map_fd_with_map_ptr(struct verifier_env *env)
+static int replace_map_fd_with_map_ptr(struct bpf_verifier_env *env)
 {
 	struct bpf_insn *insn = env->prog->insnsi;
 	int insn_cnt = env->prog->len;
@@ -2659,7 +2600,7 @@ static int replace_map_fd_with_map_ptr(struct verifier_env *env)
 }
 
 /* drop refcnt of maps used by the rejected program */
-static void release_maps(struct verifier_env *env)
+static void release_maps(struct bpf_verifier_env *env)
 {
 	int i;
 
@@ -2668,7 +2609,7 @@ static void release_maps(struct verifier_env *env)
 }
 
 /* convert pseudo BPF_LD_IMM64 into generic BPF_LD_IMM64 */
-static void convert_pseudo_ld_imm64(struct verifier_env *env)
+static void convert_pseudo_ld_imm64(struct bpf_verifier_env *env)
 {
 	struct bpf_insn *insn = env->prog->insnsi;
 	int insn_cnt = env->prog->len;
@@ -2682,7 +2623,7 @@ static void convert_pseudo_ld_imm64(struct verifier_env *env)
 /* convert load instructions that access fields of 'struct __sk_buff'
  * into sequence of instructions that access fields of 'struct sk_buff'
  */
-static int convert_ctx_accesses(struct verifier_env *env)
+static int convert_ctx_accesses(struct bpf_verifier_env *env)
 {
 	struct bpf_insn *insn = env->prog->insnsi;
 	int insn_cnt = env->prog->len;
@@ -2734,9 +2675,9 @@ static int convert_ctx_accesses(struct verifier_env *env)
 	return 0;
 }
 
-static void free_states(struct verifier_env *env)
+static void free_states(struct bpf_verifier_env *env)
 {
-	struct verifier_state_list *sl, *sln;
+	struct bpf_verifier_state_list *sl, *sln;
 	int i;
 
 	if (!env->explored_states)
@@ -2759,16 +2700,16 @@ static void free_states(struct verifier_env *env)
 int bpf_check(struct bpf_prog **prog, union bpf_attr *attr)
 {
 	char __user *log_ubuf = NULL;
-	struct verifier_env *env;
+	struct bpf_verifier_env *env;
 	int ret = -EINVAL;
 
 	if ((*prog)->len <= 0 || (*prog)->len > BPF_MAXINSNS)
 		return -E2BIG;
 
-	/* 'struct verifier_env' can be global, but since it's not small,
+	/* 'struct bpf_verifier_env' can be global, but since it's not small,
 	 * allocate/free it every time bpf_check() is called
 	 */
-	env = kzalloc(sizeof(struct verifier_env), GFP_KERNEL);
+	env = kzalloc(sizeof(struct bpf_verifier_env), GFP_KERNEL);
 	if (!env)
 		return -ENOMEM;
 
@@ -2810,7 +2751,7 @@ int bpf_check(struct bpf_prog **prog, union bpf_attr *attr)
 		goto skip_full_check;
 
 	env->explored_states = kcalloc(env->prog->len,
-				       sizeof(struct verifier_state_list *),
+				       sizeof(struct bpf_verifier_state_list *),
 				       GFP_USER);
 	ret = -ENOMEM;
 	if (!env->explored_states)
-- 
1.9.1
