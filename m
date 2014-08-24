From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v5 net-next 14/29] bpf: verifier (add verifier core)
Date: Sun, 24 Aug 2014 13:21:15 -0700
Message-ID: <1408911690-7598-15-git-send-email-ast@plumgrid.com>
References: <1408911690-7598-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	Namhyung Kim <namhyung@kernel.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408911690-7598-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds verifier core which simulates execution of every insn and
records the state of registers and program stack. Every branch instruction seen
during simulation is pushed into state stack. When verifier reaches BPF_EXIT,
it pops the state from the stack and continues until it reaches BPF_EXIT again.
For program:
1: bpf_mov r1, xxx
2: if (r1 == 0) goto 5
3: bpf_mov r0, 1
4: goto 6
5: bpf_mov r0, 2
6: bpf_exit
The verifier will walk insns: 1, 2, 3, 4, 6
then it will pop the state recorded at insn#2 and will continue: 5, 6

This way it walks all possible paths through the program and checks all
possible values of registers. While doing so, it checks for:
- invalid instructions
- uninitialized register access
- uninitialized stack access
- misaligned stack access
- out of range stack access
- invalid calling convention
- BPF_LD_ABS|IND instructions are only used in socket filters
- instruction encoding is not using reserved fields

Kernel subsystem configures the verifier with two callbacks:

- bool (*is_valid_access)(int off, int size, enum bpf_access_type type);
  that provides information to the verifer which fields of 'ctx'
  are accessible (remember 'ctx' is the first argument to eBPF program)

- const struct bpf_func_proto *(*get_func_proto)(enum bpf_func_id func_id);
  returns argument constraints of kernel helper functions that eBPF program
  may call, so that verifier can checks that R1-R5 types match the prototype

More details in Documentation/networking/filter.txt and in kernel/bpf/verifier.c

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/linux/bpf.h      |   47 ++
 include/uapi/linux/bpf.h |    1 +
 kernel/bpf/verifier.c    | 1061 +++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 1108 insertions(+), 1 deletion(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index d818e473d12c..4d99c62c6cea 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -47,6 +47,31 @@ void bpf_register_map_type(struct bpf_map_type_list *tl);
 void bpf_map_put(struct bpf_map *map);
 struct bpf_map *bpf_map_get(struct fd f);
 
+/* function argument constraints */
+enum bpf_arg_type {
+	ARG_ANYTHING = 0,	/* any argument is ok */
+
+	/* the following constraints used to prototype
+	 * bpf_map_lookup/update/delete_elem() functions
+	 */
+	ARG_CONST_MAP_PTR,	/* const argument used as pointer to bpf_map */
+	ARG_PTR_TO_MAP_KEY,	/* pointer to stack used as map key */
+	ARG_PTR_TO_MAP_VALUE,	/* pointer to stack used as map value */
+
+	/* the following constraints used to prototype bpf_memcmp() and other
+	 * functions that access data on eBPF program stack
+	 */
+	ARG_PTR_TO_STACK,	/* any pointer to eBPF program stack */
+	ARG_CONST_STACK_SIZE,	/* number of bytes accessed from stack */
+};
+
+/* type of values returned from helper functions */
+enum bpf_return_type {
+	RET_INTEGER,			/* function returns integer */
+	RET_VOID,			/* function doesn't return anything */
+	RET_PTR_TO_MAP_VALUE_OR_NULL,	/* returns a pointer to map elem value or NULL */
+};
+
 /* eBPF function prototype used by verifier to allow BPF_CALLs from eBPF programs
  * to in-kernel helper functions and for adjusting imm32 field in BPF_CALL
  * instructions after verifying
@@ -54,11 +79,33 @@ struct bpf_map *bpf_map_get(struct fd f);
 struct bpf_func_proto {
 	u64 (*func)(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
 	bool gpl_only;
+	enum bpf_return_type ret_type;
+	enum bpf_arg_type arg1_type;
+	enum bpf_arg_type arg2_type;
+	enum bpf_arg_type arg3_type;
+	enum bpf_arg_type arg4_type;
+	enum bpf_arg_type arg5_type;
+};
+
+/* bpf_context is intentionally undefined structure. Pointer to bpf_context is
+ * the first argument to eBPF programs.
+ * For socket filters: 'struct bpf_context *' == 'struct sk_buff *'
+ */
+struct bpf_context;
+
+enum bpf_access_type {
+	BPF_READ = 1,
+	BPF_WRITE = 2
 };
 
 struct bpf_verifier_ops {
 	/* return eBPF function prototype for verification */
 	const struct bpf_func_proto *(*get_func_proto)(enum bpf_func_id func_id);
+
+	/* return true if 'size' wide access at offset 'off' within bpf_context
+	 * with 'type' (read or write) is allowed
+	 */
+	bool (*is_valid_access)(int off, int size, enum bpf_access_type type);
 };
 
 struct bpf_prog_type_list {
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 2f4d92df4fbe..63284088aa48 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -396,6 +396,7 @@ enum bpf_prog_attributes {
 
 enum bpf_prog_type {
 	BPF_PROG_TYPE_UNSPEC,
+	BPF_PROG_TYPE_SOCKET_FILTER,
 };
 
 /* integer value in 'imm' field of BPF_CALL instruction selects which helper
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 454079b145b2..14a0262b101c 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -144,6 +144,72 @@
  * load/store to bpf_context are checked against known fields
  */
 
+#define _(OP) ({ int ret = (OP); if (ret < 0) return ret; })
+
+/* types of values stored in eBPF registers */
+enum bpf_reg_type {
+	NOT_INIT = 0,		 /* nothing was written into register */
+	UNKNOWN_VALUE,		 /* reg doesn't contain a valid pointer */
+	PTR_TO_CTX,		 /* reg points to bpf_context */
+	CONST_PTR_TO_MAP,	 /* reg points to struct bpf_map */
+	PTR_TO_MAP_VALUE,	 /* reg points to map element value */
+	PTR_TO_MAP_VALUE_OR_NULL,/* points to map elem value or NULL */
+	FRAME_PTR,		 /* reg == frame_pointer */
+	PTR_TO_STACK,		 /* reg == frame_pointer + imm */
+	CONST_IMM,		 /* constant integer value */
+};
+
+struct reg_state {
+	enum bpf_reg_type type;
+	union {
+		/* valid when type == CONST_IMM | PTR_TO_STACK */
+		int imm;
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
+	STACK_SPILL,      /* 1st byte of register spilled into stack */
+	STACK_SPILL_PART, /* other 7 bytes of register spill */
+	STACK_MISC	  /* BPF program wrote some data into this slot */
+};
+
+struct bpf_stack_slot {
+	enum bpf_stack_slot_type stype;
+	struct reg_state reg_st;
+};
+
+/* state of the program:
+ * type of all registers and stack info
+ */
+struct verifier_state {
+	struct reg_state regs[MAX_BPF_REG];
+	struct bpf_stack_slot stack[MAX_BPF_STACK];
+};
+
+/* linked list of verifier states used to prune search */
+struct verifier_state_list {
+	struct verifier_state state;
+	struct verifier_state_list *next;
+};
+
+/* verifier_state + insn_idx are pushed to stack when branch is encountered */
+struct verifier_stack_elem {
+	/* verifer state is 'st'
+	 * before processing instruction 'insn_idx'
+	 * and after processing instruction 'prev_insn_idx'
+	 */
+	struct verifier_state st;
+	int insn_idx;
+	int prev_insn_idx;
+	struct verifier_stack_elem *next;
+};
+
 #define MAX_USED_MAPS 64 /* max number of maps accessed by one eBPF program */
 
 /* single container for all structs
@@ -151,6 +217,9 @@
  */
 struct verifier_env {
 	struct bpf_prog *prog;		/* eBPF program being verified */
+	struct verifier_stack_elem *head; /* stack of verifier states to be processed */
+	int stack_size;			/* number of states to be processed */
+	struct verifier_state cur_state; /* current verifier state */
 	struct bpf_map *used_maps[MAX_USED_MAPS]; /* array of map's used by eBPF program */
 	u32 used_map_cnt;		/* number of used maps */
 };
@@ -179,6 +248,45 @@ static void verbose(const char *fmt, ...)
 	va_end(args);
 }
 
+/* string representation of 'enum bpf_reg_type' */
+static const char * const reg_type_str[] = {
+	[NOT_INIT]		= "?",
+	[UNKNOWN_VALUE]		= "inv",
+	[PTR_TO_CTX]		= "ctx",
+	[CONST_PTR_TO_MAP]	= "map_ptr",
+	[PTR_TO_MAP_VALUE]	= "map_value",
+	[PTR_TO_MAP_VALUE_OR_NULL] = "map_value_or_null",
+	[FRAME_PTR]		= "fp",
+	[PTR_TO_STACK]		= "fp",
+	[CONST_IMM]		= "imm",
+};
+
+static void print_verifier_state(struct verifier_env *env)
+{
+	enum bpf_reg_type t;
+	int i;
+
+	for (i = 0; i < MAX_BPF_REG; i++) {
+		t = env->cur_state.regs[i].type;
+		if (t == NOT_INIT)
+			continue;
+		verbose(" R%d=%s", i, reg_type_str[t]);
+		if (t == CONST_IMM || t == PTR_TO_STACK)
+			verbose("%d", env->cur_state.regs[i].imm);
+		else if (t == CONST_PTR_TO_MAP || t == PTR_TO_MAP_VALUE ||
+			 t == PTR_TO_MAP_VALUE_OR_NULL)
+			verbose("(ks=%d,vs=%d)",
+				env->cur_state.regs[i].map_ptr->key_size,
+				env->cur_state.regs[i].map_ptr->value_size);
+	}
+	for (i = 0; i < MAX_BPF_STACK; i++) {
+		if (env->cur_state.stack[i].stype == STACK_SPILL)
+			verbose(" fp%d=%s", -MAX_BPF_STACK + i,
+				reg_type_str[env->cur_state.stack[i].reg_st.type]);
+	}
+	verbose("\n");
+}
+
 static const char *const bpf_class_string[] = {
 	[BPF_LD]    = "ld",
 	[BPF_LDX]   = "ldx",
@@ -324,6 +432,695 @@ static void print_bpf_insn(struct bpf_insn *insn)
 	}
 }
 
+static int pop_stack(struct verifier_env *env, int *prev_insn_idx)
+{
+	struct verifier_stack_elem *elem;
+	int insn_idx;
+
+	if (env->head == NULL)
+		return -1;
+
+	memcpy(&env->cur_state, &env->head->st, sizeof(env->cur_state));
+	insn_idx = env->head->insn_idx;
+	if (prev_insn_idx)
+		*prev_insn_idx = env->head->prev_insn_idx;
+	elem = env->head->next;
+	kfree(env->head);
+	env->head = elem;
+	env->stack_size--;
+	return insn_idx;
+}
+
+static struct verifier_state *push_stack(struct verifier_env *env, int insn_idx,
+					 int prev_insn_idx)
+{
+	struct verifier_stack_elem *elem;
+
+	elem = kmalloc(sizeof(struct verifier_stack_elem), GFP_KERNEL);
+	if (!elem)
+		goto err;
+
+	memcpy(&elem->st, &env->cur_state, sizeof(env->cur_state));
+	elem->insn_idx = insn_idx;
+	elem->prev_insn_idx = prev_insn_idx;
+	elem->next = env->head;
+	env->head = elem;
+	env->stack_size++;
+	if (env->stack_size > 1024) {
+		verbose("BPF program is too complex\n");
+		goto err;
+	}
+	return &elem->st;
+err:
+	/* pop all elements and return */
+	while (pop_stack(env, NULL) >= 0);
+	return NULL;
+}
+
+#define CALLER_SAVED_REGS 6
+static const int caller_saved[CALLER_SAVED_REGS] = {
+	BPF_REG_0, BPF_REG_1, BPF_REG_2, BPF_REG_3, BPF_REG_4, BPF_REG_5
+};
+
+static void init_reg_state(struct reg_state *regs)
+{
+	int i;
+
+	for (i = 0; i < MAX_BPF_REG; i++) {
+		regs[i].type = NOT_INIT;
+		regs[i].imm = 0;
+		regs[i].map_ptr = NULL;
+	}
+
+	/* frame pointer */
+	regs[BPF_REG_FP].type = FRAME_PTR;
+
+	/* 1st arg to a function */
+	regs[BPF_REG_1].type = PTR_TO_CTX;
+}
+
+static void mark_reg_unknown_value(struct reg_state *regs, u32 regno)
+{
+	BUG_ON(regno >= MAX_BPF_REG);
+	regs[regno].type = UNKNOWN_VALUE;
+	regs[regno].imm = 0;
+	regs[regno].map_ptr = NULL;
+}
+
+enum reg_arg_type {
+	SRC_OP,		/* register is used as source operand */
+	DST_OP,		/* register is used as destination operand */
+	DST_OP_NO_MARK	/* same as above, check only, don't mark */
+};
+
+static int check_reg_arg(struct reg_state *regs, u32 regno,
+			 enum reg_arg_type t)
+{
+	if (regno >= MAX_BPF_REG) {
+		verbose("R%d is invalid\n", regno);
+		return -EINVAL;
+	}
+
+	if (t == SRC_OP) {
+		/* check whether register used as source operand can be read */
+		if (regs[regno].type == NOT_INIT) {
+			verbose("R%d !read_ok\n", regno);
+			return -EACCES;
+		}
+	} else {
+		/* check whether register used as dest operand can be written to */
+		if (regno == BPF_REG_FP) {
+			verbose("frame pointer is read only\n");
+			return -EACCES;
+		}
+		if (t == DST_OP)
+			mark_reg_unknown_value(regs, regno);
+	}
+	return 0;
+}
+
+static int bpf_size_to_bytes(int bpf_size)
+{
+	if (bpf_size == BPF_W)
+		return 4;
+	else if (bpf_size == BPF_H)
+		return 2;
+	else if (bpf_size == BPF_B)
+		return 1;
+	else if (bpf_size == BPF_DW)
+		return 8;
+	else
+		return -EINVAL;
+}
+
+/* check_stack_read/write functions track spill/fill of registers,
+ * stack boundary and alignment are checked in check_mem_access()
+ */
+static int check_stack_write(struct verifier_state *state, int off, int size,
+			     int value_regno)
+{
+	struct bpf_stack_slot *slot;
+	int i;
+
+	if (value_regno >= 0 &&
+	    (state->regs[value_regno].type == PTR_TO_MAP_VALUE ||
+	     state->regs[value_regno].type == PTR_TO_STACK ||
+	     state->regs[value_regno].type == PTR_TO_CTX)) {
+
+		/* register containing pointer is being spilled into stack */
+		if (size != 8) {
+			verbose("invalid size of register spill\n");
+			return -EACCES;
+		}
+
+		slot = &state->stack[MAX_BPF_STACK + off];
+		slot->stype = STACK_SPILL;
+		/* save register state */
+		slot->reg_st = state->regs[value_regno];
+		for (i = 1; i < 8; i++) {
+			slot = &state->stack[MAX_BPF_STACK + off + i];
+			slot->stype = STACK_SPILL_PART;
+			slot->reg_st.type = UNKNOWN_VALUE;
+			slot->reg_st.map_ptr = NULL;
+		}
+	} else {
+
+		/* regular write of data into stack */
+		for (i = 0; i < size; i++) {
+			slot = &state->stack[MAX_BPF_STACK + off + i];
+			slot->stype = STACK_MISC;
+			slot->reg_st.type = UNKNOWN_VALUE;
+			slot->reg_st.map_ptr = NULL;
+		}
+	}
+	return 0;
+}
+
+static int check_stack_read(struct verifier_state *state, int off, int size,
+			    int value_regno)
+{
+	int i;
+	struct bpf_stack_slot *slot;
+
+	slot = &state->stack[MAX_BPF_STACK + off];
+
+	if (slot->stype == STACK_SPILL) {
+		if (size != 8) {
+			verbose("invalid size of register spill\n");
+			return -EACCES;
+		}
+		for (i = 1; i < 8; i++) {
+			if (state->stack[MAX_BPF_STACK + off + i].stype !=
+			    STACK_SPILL_PART) {
+				verbose("corrupted spill memory\n");
+				return -EACCES;
+			}
+		}
+
+		if (value_regno >= 0)
+			/* restore register state from stack */
+			state->regs[value_regno] = slot->reg_st;
+		return 0;
+	} else {
+		for (i = 0; i < size; i++) {
+			if (state->stack[MAX_BPF_STACK + off + i].stype !=
+			    STACK_MISC) {
+				verbose("invalid read from stack off %d+%d size %d\n",
+					off, i, size);
+				return -EACCES;
+			}
+		}
+		if (value_regno >= 0)
+			/* have read misc data from the stack */
+			mark_reg_unknown_value(state->regs, value_regno);
+		return 0;
+	}
+}
+
+/* check read/write into map element returned by bpf_map_lookup_elem() */
+static int check_map_access(struct verifier_env *env, u32 regno, int off,
+			    int size)
+{
+	struct bpf_map *map = env->cur_state.regs[regno].map_ptr;
+
+	if (off < 0 || off + size > map->value_size) {
+		verbose("invalid access to map value, value_size=%d off=%d size=%d\n",
+			map->value_size, off, size);
+		return -EACCES;
+	}
+	return 0;
+}
+
+/* check access to 'struct bpf_context' fields */
+static int check_ctx_access(struct verifier_env *env, int off, int size,
+			    enum bpf_access_type t)
+{
+	if (env->prog->info->ops->is_valid_access &&
+	    env->prog->info->ops->is_valid_access(off, size, t))
+		return 0;
+
+	verbose("invalid bpf_context access off=%d size=%d\n", off, size);
+	return -EACCES;
+}
+
+/* check whether memory at (regno + off) is accessible for t = (read | write)
+ * if t==write, value_regno is a register which value is stored into memory
+ * if t==read, value_regno is a register which will receive the value from memory
+ * if t==write && value_regno==-1, some unknown value is stored into memory
+ * if t==read && value_regno==-1, don't care what we read from memory
+ */
+static int check_mem_access(struct verifier_env *env, u32 regno, int off,
+			    int bpf_size, enum bpf_access_type t,
+			    int value_regno)
+{
+	struct verifier_state *state = &env->cur_state;
+	int size;
+
+	_(size = bpf_size_to_bytes(bpf_size));
+
+	if (off % size != 0) {
+		verbose("misaligned access off %d size %d\n", off, size);
+		return -EACCES;
+	}
+
+	if (state->regs[regno].type == PTR_TO_MAP_VALUE) {
+		_(check_map_access(env, regno, off, size));
+		if (t == BPF_READ && value_regno >= 0)
+			mark_reg_unknown_value(state->regs, value_regno);
+
+	} else if (state->regs[regno].type == PTR_TO_CTX) {
+		_(check_ctx_access(env, off, size, t));
+		if (t == BPF_READ && value_regno >= 0)
+			mark_reg_unknown_value(state->regs, value_regno);
+
+	} else if (state->regs[regno].type == FRAME_PTR) {
+		if (off >= 0 || off < -MAX_BPF_STACK) {
+			verbose("invalid stack off=%d size=%d\n", off, size);
+			return -EACCES;
+		}
+		if (t == BPF_WRITE)
+			_(check_stack_write(state, off, size, value_regno));
+		else
+			_(check_stack_read(state, off, size, value_regno));
+	} else {
+		verbose("R%d invalid mem access '%s'\n",
+			regno, reg_type_str[state->regs[regno].type]);
+		return -EACCES;
+	}
+	return 0;
+}
+
+static int check_xadd(struct verifier_env *env, struct bpf_insn *insn)
+{
+	struct reg_state *regs = env->cur_state.regs;
+
+	if ((BPF_SIZE(insn->code) != BPF_W && BPF_SIZE(insn->code) != BPF_DW) ||
+	    insn->imm != 0) {
+		verbose("BPF_XADD uses reserved fields\n");
+		return -EINVAL;
+	}
+
+	/* check src1 operand */
+	_(check_reg_arg(regs, insn->src_reg, SRC_OP));
+	/* check src2 operand */
+	_(check_reg_arg(regs, insn->dst_reg, SRC_OP));
+
+	/* check whether atomic_add can read the memory */
+	_(check_mem_access(env, insn->dst_reg, insn->off,
+			   BPF_SIZE(insn->code), BPF_READ, -1));
+
+	/* check whether atomic_add can write into the same memory */
+	_(check_mem_access(env, insn->dst_reg, insn->off,
+			   BPF_SIZE(insn->code), BPF_WRITE, -1));
+	return 0;
+}
+
+/* when register 'regno' is passed into function that will read 'access_size'
+ * bytes from that pointer, make sure that it's within stack boundary
+ * and all elements of stack are initialized
+ */
+static int check_stack_boundary(struct verifier_env *env,
+				int regno, int access_size)
+{
+	struct verifier_state *state = &env->cur_state;
+	struct reg_state *regs = state->regs;
+	int off, i;
+
+	if (regs[regno].type != PTR_TO_STACK)
+		return -EACCES;
+
+	off = regs[regno].imm;
+	if (off >= 0 || off < -MAX_BPF_STACK || off + access_size > 0 ||
+	    access_size <= 0) {
+		verbose("invalid stack type R%d off=%d access_size=%d\n",
+			regno, off, access_size);
+		return -EACCES;
+	}
+
+	for (i = 0; i < access_size; i++) {
+		if (state->stack[MAX_BPF_STACK + off + i].stype != STACK_MISC) {
+			verbose("invalid indirect read from stack off %d+%d size %d\n",
+				off, i, access_size);
+			return -EACCES;
+		}
+	}
+	return 0;
+}
+
+static int check_func_arg(struct verifier_env *env, u32 regno,
+			  enum bpf_arg_type arg_type, struct bpf_map **mapp)
+{
+	struct reg_state *reg = env->cur_state.regs + regno;
+	enum bpf_reg_type expected_type;
+
+	if (arg_type == ARG_ANYTHING)
+		return 0;
+
+	if (reg->type == NOT_INIT) {
+		verbose("R%d !read_ok\n", regno);
+		return -EACCES;
+	}
+
+	if (arg_type == ARG_PTR_TO_STACK || arg_type == ARG_PTR_TO_MAP_KEY ||
+	    arg_type == ARG_PTR_TO_MAP_VALUE) {
+		expected_type = PTR_TO_STACK;
+	} else if (arg_type == ARG_CONST_STACK_SIZE) {
+		expected_type = CONST_IMM;
+	} else if (arg_type == ARG_CONST_MAP_PTR) {
+		expected_type = CONST_PTR_TO_MAP;
+	} else {
+		verbose("unsupported arg_type %d\n", arg_type);
+		return -EFAULT;
+	}
+
+	if (reg->type != expected_type) {
+		verbose("R%d type=%s expected=%s\n", regno,
+			reg_type_str[reg->type], reg_type_str[expected_type]);
+		return -EACCES;
+	}
+
+	if (arg_type == ARG_CONST_MAP_PTR) {
+		/* bpf_map_xxx(map_ptr) call: remember that map_ptr */
+		*mapp = reg->map_ptr;
+
+	} else if (arg_type == ARG_PTR_TO_MAP_KEY) {
+		/* bpf_map_xxx(..., map_ptr, ..., key) call:
+		 * check that [key, key + map->key_size) are within
+		 * stack limits and initialized
+		 */
+		if (!*mapp) {
+			/* in function declaration map_ptr must come before
+			 * map_key or map_elem, so that it's verified
+			 * and known before we have to check map_key here.
+			 * It means that kernel subsystem misconfigured verifier
+			 */
+			verbose("invalid map_ptr to access map->key\n");
+			return -EACCES;
+		}
+		_(check_stack_boundary(env, regno, (*mapp)->key_size));
+
+	} else if (arg_type == ARG_PTR_TO_MAP_VALUE) {
+		/* bpf_map_xxx(..., map_ptr, ..., value) call:
+		 * check [value, value + map->value_size) validity
+		 */
+		if (!*mapp) {
+			/* kernel subsystem misconfigured verifier */
+			verbose("invalid map_ptr to access map->elem\n");
+			return -EACCES;
+		}
+		_(check_stack_boundary(env, regno, (*mapp)->value_size));
+
+	} else if (arg_type == ARG_CONST_STACK_SIZE) {
+		/* bpf_xxx(..., buf, len) call will access 'len' bytes
+		 * from stack pointer 'buf'. Check it
+		 * note: regno == len, regno - 1 == buf
+		 */
+		if (regno == 0) {
+			/* kernel subsystem misconfigured verifier */
+			verbose("ARG_CONST_STACK_SIZE cannot be first argument\n");
+			return -EACCES;
+		}
+		_(check_stack_boundary(env, regno - 1, reg->imm));
+	}
+
+	return 0;
+}
+
+static int check_call(struct verifier_env *env, int func_id)
+{
+	struct verifier_state *state = &env->cur_state;
+	const struct bpf_func_proto *fn = NULL;
+	struct reg_state *regs = state->regs;
+	struct bpf_map *map = NULL;
+	struct reg_state *reg;
+	int i;
+
+	/* find function prototype */
+	if (func_id <= 0 || func_id >= __BPF_FUNC_MAX_ID) {
+		verbose("invalid func %d\n", func_id);
+		return -EINVAL;
+	}
+
+	if (env->prog->info->ops->get_func_proto)
+		fn = env->prog->info->ops->get_func_proto(func_id);
+
+	if (!fn) {
+		verbose("unknown func %d\n", func_id);
+		return -EINVAL;
+	}
+
+	/* eBPF programs must be GPL compatible to use GPL-ed functions */
+	if (!env->prog->info->is_gpl_compatible && fn->gpl_only) {
+		verbose("cannot call GPL only function from proprietary program\n");
+		return -EINVAL;
+	}
+
+	/* check args */
+	_(check_func_arg(env, BPF_REG_1, fn->arg1_type, &map));
+	_(check_func_arg(env, BPF_REG_2, fn->arg2_type, &map));
+	_(check_func_arg(env, BPF_REG_3, fn->arg3_type, &map));
+	_(check_func_arg(env, BPF_REG_4, fn->arg4_type, &map));
+	_(check_func_arg(env, BPF_REG_5, fn->arg5_type, &map));
+
+	/* reset caller saved regs */
+	for (i = 0; i < CALLER_SAVED_REGS; i++) {
+		reg = regs + caller_saved[i];
+		reg->type = NOT_INIT;
+		reg->imm = 0;
+	}
+
+	/* update return register */
+	if (fn->ret_type == RET_INTEGER) {
+		regs[BPF_REG_0].type = UNKNOWN_VALUE;
+	} else if (fn->ret_type == RET_VOID) {
+		regs[BPF_REG_0].type = NOT_INIT;
+	} else if (fn->ret_type == RET_PTR_TO_MAP_VALUE_OR_NULL) {
+		regs[BPF_REG_0].type = PTR_TO_MAP_VALUE_OR_NULL;
+		/* remember map_ptr, so that check_map_access()
+		 * can check 'value_size' boundary of memory access
+		 * to map element returned from bpf_map_lookup_elem()
+		 */
+		if (map == NULL) {
+			verbose("kernel subsystem misconfigured verifier\n");
+			return -EINVAL;
+		}
+		regs[BPF_REG_0].map_ptr = map;
+	} else {
+		verbose("unknown return type %d of func %d\n",
+			fn->ret_type, func_id);
+		return -EINVAL;
+	}
+	return 0;
+}
+
+/* check validity of 32-bit and 64-bit arithmetic operations */
+static int check_alu_op(struct reg_state *regs, struct bpf_insn *insn)
+{
+	u8 opcode = BPF_OP(insn->code);
+
+	if (opcode == BPF_END || opcode == BPF_NEG) {
+		if (opcode == BPF_NEG) {
+			if (BPF_SRC(insn->code) != 0 ||
+			    insn->src_reg != BPF_REG_0 ||
+			    insn->off != 0 || insn->imm != 0) {
+				verbose("BPF_NEG uses reserved fields\n");
+				return -EINVAL;
+			}
+		} else {
+			if (insn->src_reg != BPF_REG_0 || insn->off != 0 ||
+			    (insn->imm != 16 && insn->imm != 32 && insn->imm != 64)) {
+				verbose("BPF_END uses reserved fields\n");
+				return -EINVAL;
+			}
+		}
+
+		/* check src operand */
+		_(check_reg_arg(regs, insn->dst_reg, SRC_OP));
+
+		/* check dest operand */
+		_(check_reg_arg(regs, insn->dst_reg, DST_OP));
+
+	} else if (opcode == BPF_MOV) {
+
+		if (BPF_SRC(insn->code) == BPF_X) {
+			if (insn->imm != 0 || insn->off != 0) {
+				verbose("BPF_MOV uses reserved fields\n");
+				return -EINVAL;
+			}
+
+			/* check src operand */
+			_(check_reg_arg(regs, insn->src_reg, SRC_OP));
+		} else {
+			if (insn->src_reg != BPF_REG_0 || insn->off != 0) {
+				verbose("BPF_MOV uses reserved fields\n");
+				return -EINVAL;
+			}
+		}
+
+		/* check dest operand */
+		_(check_reg_arg(regs, insn->dst_reg, DST_OP));
+
+		if (BPF_SRC(insn->code) == BPF_X) {
+			if (BPF_CLASS(insn->code) == BPF_ALU64) {
+				/* case: R1 = R2
+				 * copy register state to dest reg
+				 */
+				regs[insn->dst_reg] = regs[insn->src_reg];
+			} else {
+				regs[insn->dst_reg].type = UNKNOWN_VALUE;
+				regs[insn->dst_reg].map_ptr = NULL;
+			}
+		} else {
+			/* case: R = imm
+			 * remember the value we stored into this reg
+			 */
+			regs[insn->dst_reg].type = CONST_IMM;
+			regs[insn->dst_reg].imm = insn->imm;
+		}
+
+	} else if (opcode > BPF_END) {
+		verbose("invalid BPF_ALU opcode %x\n", opcode);
+		return -EINVAL;
+
+	} else {	/* all other ALU ops: and, sub, xor, add, ... */
+
+		bool stack_relative = false;
+
+		if (BPF_SRC(insn->code) == BPF_X) {
+			if (insn->imm != 0 || insn->off != 0) {
+				verbose("BPF_ALU uses reserved fields\n");
+				return -EINVAL;
+			}
+			/* check src1 operand */
+			_(check_reg_arg(regs, insn->src_reg, SRC_OP));
+		} else {
+			if (insn->src_reg != BPF_REG_0 || insn->off != 0) {
+				verbose("BPF_ALU uses reserved fields\n");
+				return -EINVAL;
+			}
+		}
+
+		/* check src2 operand */
+		_(check_reg_arg(regs, insn->dst_reg, SRC_OP));
+
+		if ((opcode == BPF_MOD || opcode == BPF_DIV) &&
+		    BPF_SRC(insn->code) == BPF_K && insn->imm == 0) {
+			verbose("div by zero\n");
+			return -EINVAL;
+		}
+
+		/* pattern match 'bpf_add Rx, imm' instruction */
+		if (opcode == BPF_ADD && BPF_CLASS(insn->code) == BPF_ALU64 &&
+		    regs[insn->dst_reg].type == FRAME_PTR &&
+		    BPF_SRC(insn->code) == BPF_K)
+			stack_relative = true;
+
+		/* check dest operand */
+		_(check_reg_arg(regs, insn->dst_reg, DST_OP));
+
+		if (stack_relative) {
+			regs[insn->dst_reg].type = PTR_TO_STACK;
+			regs[insn->dst_reg].imm = insn->imm;
+		}
+	}
+
+	return 0;
+}
+
+static int check_cond_jmp_op(struct verifier_env *env,
+			     struct bpf_insn *insn, int *insn_idx)
+{
+	struct reg_state *regs = env->cur_state.regs;
+	struct verifier_state *other_branch;
+	u8 opcode = BPF_OP(insn->code);
+
+	if (opcode > BPF_EXIT) {
+		verbose("invalid BPF_JMP opcode %x\n", opcode);
+		return -EINVAL;
+	}
+
+	if (BPF_SRC(insn->code) == BPF_X) {
+		if (insn->imm != 0) {
+			verbose("BPF_JMP uses reserved fields\n");
+			return -EINVAL;
+		}
+
+		/* check src1 operand */
+		_(check_reg_arg(regs, insn->src_reg, SRC_OP));
+	} else {
+		if (insn->src_reg != BPF_REG_0) {
+			verbose("BPF_JMP uses reserved fields\n");
+			return -EINVAL;
+		}
+	}
+
+	/* check src2 operand */
+	_(check_reg_arg(regs, insn->dst_reg, SRC_OP));
+
+	/* detect if R == 0 where R was initialized to zero earlier */
+	if (BPF_SRC(insn->code) == BPF_K &&
+	    (opcode == BPF_JEQ || opcode == BPF_JNE) &&
+	    regs[insn->dst_reg].type == CONST_IMM &&
+	    regs[insn->dst_reg].imm == insn->imm) {
+		if (opcode == BPF_JEQ) {
+			/* if (imm == imm) goto pc+off;
+			 * only follow the goto, ignore fall-through
+			 */
+			*insn_idx += insn->off;
+			return 0;
+		} else {
+			/* if (imm != imm) goto pc+off;
+			 * only follow fall-through branch, since
+			 * that's where the program will go
+			 */
+			return 0;
+		}
+	}
+
+	other_branch = push_stack(env, *insn_idx + insn->off + 1, *insn_idx);
+	if (!other_branch)
+		return -EFAULT;
+
+	/* detect if R == 0 where R is returned value from bpf_map_lookup_elem() */
+	if (BPF_SRC(insn->code) == BPF_K &&
+	    insn->imm == 0 && (opcode == BPF_JEQ ||
+			       opcode == BPF_JNE) &&
+	    regs[insn->dst_reg].type == PTR_TO_MAP_VALUE_OR_NULL) {
+		if (opcode == BPF_JEQ) {
+			/* next fallthrough insn can access memory via
+			 * this register
+			 */
+			regs[insn->dst_reg].type = PTR_TO_MAP_VALUE;
+			/* branch targer cannot access it, since reg == 0 */
+			other_branch->regs[insn->dst_reg].type = CONST_IMM;
+			other_branch->regs[insn->dst_reg].imm = 0;
+		} else {
+			other_branch->regs[insn->dst_reg].type = PTR_TO_MAP_VALUE;
+			regs[insn->dst_reg].type = CONST_IMM;
+			regs[insn->dst_reg].imm = 0;
+		}
+	} else if (BPF_SRC(insn->code) == BPF_K &&
+		   (opcode == BPF_JEQ || opcode == BPF_JNE)) {
+
+		if (opcode == BPF_JEQ) {
+			/* detect if (R == imm) goto
+			 * and in the target state recognize that R = imm
+			 */
+			other_branch->regs[insn->dst_reg].type = CONST_IMM;
+			other_branch->regs[insn->dst_reg].imm = insn->imm;
+		} else {
+			/* detect if (R != imm) goto
+			 * and in the fall-through state recognize that R = imm
+			 */
+			regs[insn->dst_reg].type = CONST_IMM;
+			regs[insn->dst_reg].imm = insn->imm;
+		}
+	}
+	if (log_level)
+		print_verifier_state(env);
+	return 0;
+}
+
 /* return the map pointer stored inside BPF_LD_IMM64 instruction */
 static struct bpf_map *ld_imm64_to_map_ptr(struct bpf_insn *insn)
 {
@@ -332,6 +1129,93 @@ static struct bpf_map *ld_imm64_to_map_ptr(struct bpf_insn *insn)
 	return (struct bpf_map *) (unsigned long) imm64;
 }
 
+/* verify BPF_LD_IMM64 instruction */
+static int check_ld_imm(struct verifier_env *env, struct bpf_insn *insn)
+{
+	struct reg_state *regs = env->cur_state.regs;
+
+	if (BPF_SIZE(insn->code) != BPF_DW) {
+		verbose("invalid BPF_LD_IMM insn\n");
+		return -EINVAL;
+	}
+	if (insn->off != 0) {
+		verbose("BPF_LD_IMM64 uses reserved fields\n");
+		return -EINVAL;
+	}
+
+	_(check_reg_arg(regs, insn->dst_reg, DST_OP));
+
+	if (insn->src_reg == 0)
+		/* generic move 64-bit immediate into a register */
+		return 0;
+
+	/* replace_map_fd_with_map_ptr() should have caught bad ld_imm64 */
+	BUG_ON(insn->src_reg != BPF_PSEUDO_MAP_FD);
+
+	regs[insn->dst_reg].type = CONST_PTR_TO_MAP;
+	regs[insn->dst_reg].map_ptr = ld_imm64_to_map_ptr(insn);
+	return 0;
+}
+
+/* verify safety of LD_ABS|LD_IND instructions:
+ * - they can only appear in the programs where ctx == skb
+ * - since they are wrappers of function calls, they scratch R1-R5 registers,
+ *   preserve R6-R9, and store return value into R0
+ *
+ * Implicit input:
+ *   ctx == skb == R6 == CTX
+ *
+ * Explicit input:
+ *   SRC == any register
+ *   IMM == 32-bit immediate
+ *
+ * Output:
+ *   R0 - 8/16/32-bit skb data converted to cpu endianness
+ */
+static int check_ld_abs(struct verifier_env *env, struct bpf_insn *insn)
+{
+	struct reg_state *regs = env->cur_state.regs;
+	u8 mode = BPF_MODE(insn->code);
+	struct reg_state *reg;
+	int i;
+
+	if (env->prog->info->prog_type != BPF_PROG_TYPE_SOCKET_FILTER) {
+		verbose("BPF_LD_ABS|IND instructions are only allowed in socket filters\n");
+		return -EINVAL;
+	}
+
+	if (insn->dst_reg != BPF_REG_0 || insn->off != 0 ||
+	    (mode == BPF_ABS && insn->src_reg != BPF_REG_0)) {
+		verbose("BPF_LD_ABS uses reserved fields\n");
+		return -EINVAL;
+	}
+
+	/* check whether implicit source operand (register R6) is readable */
+	_(check_reg_arg(regs, BPF_REG_6, SRC_OP));
+
+	if (regs[BPF_REG_6].type != PTR_TO_CTX) {
+		verbose("at the time of BPF_LD_ABS|IND R6 != pointer to skb\n");
+		return -EINVAL;
+	}
+
+	if (mode == BPF_IND)
+		/* check explicit source operand */
+		_(check_reg_arg(regs, insn->src_reg, SRC_OP));
+
+	/* reset caller saved regs to unreadable */
+	for (i = 0; i < CALLER_SAVED_REGS; i++) {
+		reg = regs + caller_saved[i];
+		reg->type = NOT_INIT;
+		reg->imm = 0;
+	}
+
+	/* mark destination R0 register as readable, since it contains
+	 * the value fetched from the packet
+	 */
+	regs[BPF_REG_0].type = UNKNOWN_VALUE;
+	return 0;
+}
+
 /* non-recursive DFS pseudo code
  * 1  procedure DFS-iterative(G,v):
  * 2      label v as discovered
@@ -511,6 +1395,180 @@ free_st:
 	return ret;
 }
 
+static int do_check(struct verifier_env *env)
+{
+	struct verifier_state *state = &env->cur_state;
+	struct bpf_insn *insns = env->prog->insnsi;
+	struct reg_state *regs = state->regs;
+	int insn_cnt = env->prog->len;
+	int insn_idx, prev_insn_idx = 0;
+	int insn_processed = 0;
+	bool do_print_state = false;
+
+	init_reg_state(regs);
+	insn_idx = 0;
+	for (;;) {
+		struct bpf_insn *insn;
+		u8 class;
+
+		if (insn_idx >= insn_cnt) {
+			verbose("invalid insn idx %d insn_cnt %d\n",
+				insn_idx, insn_cnt);
+			return -EFAULT;
+		}
+
+		insn = &insns[insn_idx];
+		class = BPF_CLASS(insn->code);
+
+		if (++insn_processed > 32768) {
+			verbose("BPF program is too large. Proccessed %d insn\n",
+				insn_processed);
+			return -E2BIG;
+		}
+
+		if (log_level && do_print_state) {
+			verbose("\nfrom %d to %d:", prev_insn_idx, insn_idx);
+			print_verifier_state(env);
+			do_print_state = false;
+		}
+
+		if (log_level) {
+			verbose("%d: ", insn_idx);
+			print_bpf_insn(insn);
+		}
+
+		if (class == BPF_ALU || class == BPF_ALU64) {
+			_(check_alu_op(regs, insn));
+
+		} else if (class == BPF_LDX) {
+			if (BPF_MODE(insn->code) != BPF_MEM ||
+			    insn->imm != 0) {
+				verbose("BPF_LDX uses reserved fields\n");
+				return -EINVAL;
+			}
+			/* check src operand */
+			_(check_reg_arg(regs, insn->src_reg, SRC_OP));
+
+			_(check_reg_arg(regs, insn->dst_reg, DST_OP_NO_MARK));
+
+			/* check that memory (src_reg + off) is readable,
+			 * the state of dst_reg will be updated by this func
+			 */
+			_(check_mem_access(env, insn->src_reg, insn->off,
+					   BPF_SIZE(insn->code), BPF_READ,
+					   insn->dst_reg));
+
+		} else if (class == BPF_STX) {
+			if (BPF_MODE(insn->code) == BPF_XADD) {
+				_(check_xadd(env, insn));
+				insn_idx++;
+				continue;
+			}
+
+			if (BPF_MODE(insn->code) != BPF_MEM ||
+			    insn->imm != 0) {
+				verbose("BPF_STX uses reserved fields\n");
+				return -EINVAL;
+			}
+			/* check src1 operand */
+			_(check_reg_arg(regs, insn->src_reg, SRC_OP));
+			/* check src2 operand */
+			_(check_reg_arg(regs, insn->dst_reg, SRC_OP));
+
+			/* check that memory (dst_reg + off) is writeable */
+			_(check_mem_access(env, insn->dst_reg, insn->off,
+					   BPF_SIZE(insn->code), BPF_WRITE,
+					   insn->src_reg));
+
+		} else if (class == BPF_ST) {
+			if (BPF_MODE(insn->code) != BPF_MEM ||
+			    insn->src_reg != BPF_REG_0) {
+				verbose("BPF_ST uses reserved fields\n");
+				return -EINVAL;
+			}
+			/* check src operand */
+			_(check_reg_arg(regs, insn->dst_reg, SRC_OP));
+
+			/* check that memory (dst_reg + off) is writeable */
+			_(check_mem_access(env, insn->dst_reg, insn->off,
+					   BPF_SIZE(insn->code), BPF_WRITE,
+					   -1));
+
+		} else if (class == BPF_JMP) {
+			u8 opcode = BPF_OP(insn->code);
+
+			if (opcode == BPF_CALL) {
+				if (BPF_SRC(insn->code) != BPF_K ||
+				    insn->off != 0 ||
+				    insn->src_reg != BPF_REG_0 ||
+				    insn->dst_reg != BPF_REG_0) {
+					verbose("BPF_CALL uses reserved fields\n");
+					return -EINVAL;
+				}
+
+				_(check_call(env, insn->imm));
+
+			} else if (opcode == BPF_JA) {
+				if (BPF_SRC(insn->code) != BPF_K ||
+				    insn->imm != 0 ||
+				    insn->src_reg != BPF_REG_0 ||
+				    insn->dst_reg != BPF_REG_0) {
+					verbose("BPF_JA uses reserved fields\n");
+					return -EINVAL;
+				}
+
+				insn_idx += insn->off + 1;
+				continue;
+
+			} else if (opcode == BPF_EXIT) {
+				if (BPF_SRC(insn->code) != BPF_K ||
+				    insn->imm != 0 ||
+				    insn->src_reg != BPF_REG_0 ||
+				    insn->dst_reg != BPF_REG_0) {
+					verbose("BPF_EXIT uses reserved fields\n");
+					return -EINVAL;
+				}
+
+				/* eBPF calling convetion is such that R0 is used
+				 * to return the value from eBPF program.
+				 * Make sure that it's readable at this time
+				 * of bpf_exit, which means that program wrote
+				 * something into it earlier
+				 */
+				_(check_reg_arg(regs, BPF_REG_0, SRC_OP));
+				insn_idx = pop_stack(env, &prev_insn_idx);
+				if (insn_idx < 0) {
+					break;
+				} else {
+					do_print_state = true;
+					continue;
+				}
+			} else {
+				_(check_cond_jmp_op(env, insn, &insn_idx));
+			}
+		} else if (class == BPF_LD) {
+			u8 mode = BPF_MODE(insn->code);
+
+			if (mode == BPF_ABS || mode == BPF_IND) {
+				_(check_ld_abs(env, insn));
+			} else if (mode == BPF_IMM) {
+				_(check_ld_imm(env, insn));
+				insn_idx++;
+			} else {
+				verbose("invalid BPF_LD mode\n");
+				return -EINVAL;
+			}
+		} else {
+			verbose("unknown insn class %d\n", class);
+			return -EINVAL;
+		}
+
+		insn_idx++;
+	}
+
+	return 0;
+}
+
 /* look for pseudo eBPF instructions that access map FDs and
  * replace them with actual map pointers
  */
@@ -665,9 +1723,10 @@ int bpf_check(struct bpf_prog *prog, struct nlattr *tb[BPF_PROG_ATTR_MAX + 1])
 	if (ret < 0)
 		goto skip_full_check;
 
-	/* ret = do_check(env); */
+	ret = do_check(env);
 
 skip_full_check:
+	while (pop_stack(env, NULL) >= 0);
 
 	if (log_level && log_len >= log_size - 1) {
 		BUG_ON(log_len >= log_size);
-- 
1.7.9.5
