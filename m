From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 1/4] bpf: allow bpf programs to tail-call other bpf programs
Date: Tue, 19 May 2015 16:59:03 -0700
Message-ID: <1432079946-9878-2-git-send-email-ast@plumgrid.com>
References: <1432079946-9878-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Michael Holzheu <holzheu-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	Zi Shen Lim <zlim.lnx-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1432079946-9878-1-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

introduce bpf_tail_call(ctx, &jmp_table, index) helper function
which can be used from BPF programs like:
int bpf_prog(struct pt_regs *ctx)
{
  ...
  bpf_tail_call(ctx, &jmp_table, index);
  ...
}
that is roughly equivalent to:
int bpf_prog(struct pt_regs *ctx)
{
  ...
  if (jmp_table[index])
    return (*jmp_table[index])(ctx);
  ...
}
The important detail that it's not a normal call, but a tail call.
The kernel stack is precious, so this helper reuses the current
stack frame and jumps into another BPF program without adding
extra call frame.
It's trivially done in interpreter and a bit trickier in JITs.
In case of x64 JIT the bigger part of generated assembler prologue
is common for all programs, so it is simply skipped while jumping.
Other JITs can do similar prologue-skipping optimization or
do stack unwind before jumping into the next program.

bpf_tail_call() arguments:
ctx - context pointer
jmp_table - one of BPF_MAP_TYPE_PROG_ARRAY maps used as the jump table
index - index in the jump table

Since all BPF programs are idenitified by file descriptor, user space
need to populate the jmp_table with FDs of other BPF programs.
If jmp_table[index] is empty the bpf_tail_call() doesn't jump anywhere
and program execution continues as normal.

New BPF_MAP_TYPE_PROG_ARRAY map type is introduced so that user space can
populate this jmp_table array with FDs of other bpf programs.
Programs can share the same jmp_table array or use multiple jmp_tables.

The chain of tail calls can form unpredictable dynamic loops therefore
tail_call_cnt is used to limit the number of calls and currently is set to 32.

Use cases:
==========
- simplify complex programs by splitting them into a sequence of small programs

- dispatch routine
  For tracing and future seccomp the program may be triggered on all system
  calls, but processing of syscall arguments will be different. It's more
  efficient to implement them as:
  int syscall_entry(struct seccomp_data *ctx)
  {
     bpf_tail_call(ctx, &syscall_jmp_table, ctx->nr /* syscall number */);
     ... default: process unknown syscall ...
  }
  int sys_write_event(struct seccomp_data *ctx) {...}
  int sys_read_event(struct seccomp_data *ctx) {...}
  syscall_jmp_table[__NR_write] = sys_write_event;
  syscall_jmp_table[__NR_read] = sys_read_event;

  For networking the program may call into different parsers depending on
  packet format, like:
  int packet_parser(struct __sk_buff *skb)
  {
     ... parse L2, L3 here ...
     __u8 ipproto = load_byte(skb, ... offsetof(struct iphdr, protocol));
     bpf_tail_call(skb, &ipproto_jmp_table, ipproto);
     ... default: process unknown protocol ...
  }
  int parse_tcp(struct __sk_buff *skb) {...}
  int parse_udp(struct __sk_buff *skb) {...}
  ipproto_jmp_table[IPPROTO_TCP] = parse_tcp;
  ipproto_jmp_table[IPPROTO_UDP] = parse_udp;

- for TC use case, bpf_tail_call() allows to implement reclassify-like logic

- bpf_map_update_elem/delete calls into BPF_MAP_TYPE_PROG_ARRAY jump table
  are atomic, so user space can build chains of BPF programs on the fly

Implementation details:
=======================
- high performance of bpf_tail_call() is the goal.
  It could have been implemented without JIT changes as a wrapper on top of
  BPF_PROG_RUN() macro, but with two downsides:
  . all programs would have to pay performance penalty for this feature and
    tail call itself would be slower, since mandatory stack unwind, return,
    stack allocate would be done for every tailcall.
  . tailcall would be limited to programs running preempt_disabled, since
    generic 'void *ctx' doesn't have room for 'tail_call_cnt' and it would
    need to be either global per_cpu variable accessed by helper and by wrapper
    or global variable protected by locks.

  In this implementation x64 JIT bypasses stack unwind and jumps into the
  callee program after prologue.

- bpf_prog_array_compatible() ensures that prog_type of callee and caller
  are the same and JITed/non-JITed flag is the same, since calling JITed
  program from non-JITed is invalid, since stack frames are different.
  Similarly calling kprobe type program from socket type program is invalid.

- jump table is implemented as BPF_MAP_TYPE_PROG_ARRAY to reuse 'map'
  abstraction, its user space API and all of verifier logic.
  It's in the existing arraymap.c file, since several functions are
  shared with regular array map.

Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
---
 include/linux/bpf.h      |   22 +++++++++
 include/linux/filter.h   |    2 +-
 include/uapi/linux/bpf.h |   10 ++++
 kernel/bpf/arraymap.c    |  113 +++++++++++++++++++++++++++++++++++++++++++---
 kernel/bpf/core.c        |   73 +++++++++++++++++++++++++++++-
 kernel/bpf/syscall.c     |   23 +++++++++-
 kernel/bpf/verifier.c    |   17 +++++++
 kernel/trace/bpf_trace.c |    2 +
 net/core/filter.c        |    2 +
 9 files changed, 255 insertions(+), 9 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index d5cda067115a..8821b9a8689e 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -126,6 +126,27 @@ struct bpf_prog_aux {
 	struct work_struct work;
 };
 
+struct bpf_array {
+	struct bpf_map map;
+	u32 elem_size;
+	/* 'ownership' of prog_array is claimed by the first program that
+	 * is going to use this map or by the first program which FD is stored
+	 * in the map to make sure that all callers and callees have the same
+	 * prog_type and JITed flag
+	 */
+	enum bpf_prog_type owner_prog_type;
+	bool owner_jited;
+	union {
+		char value[0] __aligned(8);
+		struct bpf_prog *prog[0] __aligned(8);
+	};
+};
+#define MAX_TAIL_CALL_CNT 32
+
+u64 bpf_tail_call(u64 ctx, u64 r2, u64 index, u64 r4, u64 r5);
+void bpf_prog_array_map_clear(struct bpf_map *map);
+bool bpf_prog_array_compatible(struct bpf_array *array, const struct bpf_prog *fp);
+
 #ifdef CONFIG_BPF_SYSCALL
 void bpf_register_prog_type(struct bpf_prog_type_list *tl);
 void bpf_register_map_type(struct bpf_map_type_list *tl);
@@ -160,5 +181,6 @@ extern const struct bpf_func_proto bpf_map_delete_elem_proto;
 
 extern const struct bpf_func_proto bpf_get_prandom_u32_proto;
 extern const struct bpf_func_proto bpf_get_smp_processor_id_proto;
+extern const struct bpf_func_proto bpf_tail_call_proto;
 
 #endif /* _LINUX_BPF_H */
diff --git a/include/linux/filter.h b/include/linux/filter.h
index 200be4a74a33..17724f6ea983 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -378,7 +378,7 @@ static inline void bpf_prog_unlock_ro(struct bpf_prog *fp)
 
 int sk_filter(struct sock *sk, struct sk_buff *skb);
 
-void bpf_prog_select_runtime(struct bpf_prog *fp);
+int bpf_prog_select_runtime(struct bpf_prog *fp);
 void bpf_prog_free(struct bpf_prog *fp);
 
 struct bpf_prog *bpf_prog_alloc(unsigned int size, gfp_t gfp_extra_flags);
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index a9ebdf5701e8..f0a9af8b4dae 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -113,6 +113,7 @@ enum bpf_map_type {
 	BPF_MAP_TYPE_UNSPEC,
 	BPF_MAP_TYPE_HASH,
 	BPF_MAP_TYPE_ARRAY,
+	BPF_MAP_TYPE_PROG_ARRAY,
 };
 
 enum bpf_prog_type {
@@ -210,6 +211,15 @@ enum bpf_func_id {
 	 * Return: 0 on success
 	 */
 	BPF_FUNC_l4_csum_replace,
+
+	/**
+	 * bpf_tail_call(ctx, prog_array_map, index) - jump into another BPF program
+	 * @ctx: context pointer passed to next program
+	 * @prog_array_map: pointer to map which type is BPF_MAP_TYPE_PROG_ARRAY
+	 * @index: index inside array that selects specific program to run
+	 * Return: 0 on success
+	 */
+	BPF_FUNC_tail_call,
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index 8a6616583f38..614bcd4c1d74 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -14,12 +14,7 @@
 #include <linux/vmalloc.h>
 #include <linux/slab.h>
 #include <linux/mm.h>
-
-struct bpf_array {
-	struct bpf_map map;
-	u32 elem_size;
-	char value[0] __aligned(8);
-};
+#include <linux/filter.h>
 
 /* Called from syscall */
 static struct bpf_map *array_map_alloc(union bpf_attr *attr)
@@ -154,3 +149,109 @@ static int __init register_array_map(void)
 	return 0;
 }
 late_initcall(register_array_map);
+
+static struct bpf_map *prog_array_map_alloc(union bpf_attr *attr)
+{
+	/* only bpf_prog file descriptors can be stored in prog_array map */
+	if (attr->value_size != sizeof(u32))
+		return ERR_PTR(-EINVAL);
+	return array_map_alloc(attr);
+}
+
+static void prog_array_map_free(struct bpf_map *map)
+{
+	struct bpf_array *array = container_of(map, struct bpf_array, map);
+	int i;
+
+	synchronize_rcu();
+
+	/* make sure it's empty */
+	for (i = 0; i < array->map.max_entries; i++)
+		BUG_ON(array->prog[i] != NULL);
+	kvfree(array);
+}
+
+static void *prog_array_map_lookup_elem(struct bpf_map *map, void *key)
+{
+	return NULL;
+}
+
+/* only called from syscall */
+static int prog_array_map_update_elem(struct bpf_map *map, void *key,
+				      void *value, u64 map_flags)
+{
+	struct bpf_array *array = container_of(map, struct bpf_array, map);
+	struct bpf_prog *prog, *old_prog;
+	u32 index = *(u32 *)key, ufd;
+
+	if (map_flags != BPF_ANY)
+		return -EINVAL;
+
+	if (index >= array->map.max_entries)
+		return -E2BIG;
+
+	ufd = *(u32 *)value;
+	prog = bpf_prog_get(ufd);
+	if (IS_ERR(prog))
+		return PTR_ERR(prog);
+
+	if (!bpf_prog_array_compatible(array, prog)) {
+		bpf_prog_put(prog);
+		return -EINVAL;
+	}
+
+	old_prog = xchg(array->prog + index, prog);
+	if (old_prog)
+		bpf_prog_put(old_prog);
+
+	return 0;
+}
+
+static int prog_array_map_delete_elem(struct bpf_map *map, void *key)
+{
+	struct bpf_array *array = container_of(map, struct bpf_array, map);
+	struct bpf_prog *old_prog;
+	u32 index = *(u32 *)key;
+
+	if (index >= array->map.max_entries)
+		return -E2BIG;
+
+	old_prog = xchg(array->prog + index, NULL);
+	if (old_prog) {
+		bpf_prog_put(old_prog);
+		return 0;
+	} else {
+		return -ENOENT;
+	}
+}
+
+/* decrement refcnt of all bpf_progs that are stored in this map */
+void bpf_prog_array_map_clear(struct bpf_map *map)
+{
+	struct bpf_array *array = container_of(map, struct bpf_array, map);
+	int i;
+
+	for (i = 0; i < array->map.max_entries; i++)
+		prog_array_map_delete_elem(map, &i);
+}
+
+static const struct bpf_map_ops prog_array_ops = {
+	.map_alloc = prog_array_map_alloc,
+	.map_free = prog_array_map_free,
+	.map_get_next_key = array_map_get_next_key,
+	.map_lookup_elem = prog_array_map_lookup_elem,
+	.map_update_elem = prog_array_map_update_elem,
+	.map_delete_elem = prog_array_map_delete_elem,
+};
+
+static struct bpf_map_type_list prog_array_type __read_mostly = {
+	.ops = &prog_array_ops,
+	.type = BPF_MAP_TYPE_PROG_ARRAY,
+};
+
+static int __init register_prog_array_map(void)
+{
+	bpf_register_map_type(&prog_array_type);
+	return 0;
+}
+late_initcall(register_prog_array_map);
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 54f0e7fcd0e2..d44b25cbe460 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -176,6 +176,15 @@ noinline u64 __bpf_call_base(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 	return 0;
 }
 
+const struct bpf_func_proto bpf_tail_call_proto = {
+	.func = NULL,
+	.gpl_only = false,
+	.ret_type = RET_VOID,
+	.arg1_type = ARG_PTR_TO_CTX,
+	.arg2_type = ARG_CONST_MAP_PTR,
+	.arg3_type = ARG_ANYTHING,
+};
+
 /**
  *	__bpf_prog_run - run eBPF program on a given context
  *	@ctx: is the data we are operating on
@@ -244,6 +253,7 @@ static unsigned int __bpf_prog_run(void *ctx, const struct bpf_insn *insn)
 		[BPF_ALU64 | BPF_NEG] = &&ALU64_NEG,
 		/* Call instruction */
 		[BPF_JMP | BPF_CALL] = &&JMP_CALL,
+		[BPF_JMP | BPF_CALL | BPF_X] = &&JMP_TAIL_CALL,
 		/* Jumps */
 		[BPF_JMP | BPF_JA] = &&JMP_JA,
 		[BPF_JMP | BPF_JEQ | BPF_X] = &&JMP_JEQ_X,
@@ -286,6 +296,7 @@ static unsigned int __bpf_prog_run(void *ctx, const struct bpf_insn *insn)
 		[BPF_LD | BPF_IND | BPF_B] = &&LD_IND_B,
 		[BPF_LD | BPF_IMM | BPF_DW] = &&LD_IMM_DW,
 	};
+	u32 tail_call_cnt = 0;
 	void *ptr;
 	int off;
 
@@ -431,6 +442,30 @@ select_insn:
 						       BPF_R4, BPF_R5);
 		CONT;
 
+	JMP_TAIL_CALL: {
+		struct bpf_map *map = (struct bpf_map *) (unsigned long) BPF_R2;
+		struct bpf_array *array = container_of(map, struct bpf_array, map);
+		struct bpf_prog *prog;
+		u64 index = BPF_R3;
+
+		if (unlikely(index >= array->map.max_entries))
+			goto out;
+
+		if (unlikely(tail_call_cnt > MAX_TAIL_CALL_CNT))
+			goto out;
+
+		tail_call_cnt++;
+
+		prog = READ_ONCE(array->prog[index]);
+		if (unlikely(!prog))
+			goto out;
+
+		ARG1 = BPF_R1;
+		insn = prog->insnsi;
+		goto select_insn;
+out:
+		CONT;
+	}
 	/* JMP */
 	JMP_JA:
 		insn += insn->off;
@@ -619,6 +654,40 @@ void __weak bpf_int_jit_compile(struct bpf_prog *prog)
 {
 }
 
+bool bpf_prog_array_compatible(struct bpf_array *array, const struct bpf_prog *fp)
+{
+	if (array->owner_prog_type) {
+		if (array->owner_prog_type != fp->type)
+			return false;
+		if (array->owner_jited != fp->jited)
+			return false;
+	} else {
+		array->owner_prog_type = fp->type;
+		array->owner_jited = fp->jited;
+	}
+	return true;
+}
+
+static int check_tail_call(const struct bpf_prog *fp)
+{
+	struct bpf_prog_aux *aux = fp->aux;
+	int i;
+
+	for (i = 0; i < aux->used_map_cnt; i++) {
+		struct bpf_array *array;
+		struct bpf_map *map;
+
+		map = aux->used_maps[i];
+		if (map->map_type != BPF_MAP_TYPE_PROG_ARRAY)
+			continue;
+		array = container_of(map, struct bpf_array, map);
+		if (!bpf_prog_array_compatible(array, fp))
+			return -EINVAL;
+	}
+
+	return 0;
+}
+
 /**
  *	bpf_prog_select_runtime - select execution runtime for BPF program
  *	@fp: bpf_prog populated with internal BPF program
@@ -626,7 +695,7 @@ void __weak bpf_int_jit_compile(struct bpf_prog *prog)
  * try to JIT internal BPF program, if JIT is not available select interpreter
  * BPF program will be executed via BPF_PROG_RUN() macro
  */
-void bpf_prog_select_runtime(struct bpf_prog *fp)
+int bpf_prog_select_runtime(struct bpf_prog *fp)
 {
 	fp->bpf_func = (void *) __bpf_prog_run;
 
@@ -634,6 +703,8 @@ void bpf_prog_select_runtime(struct bpf_prog *fp)
 	bpf_int_jit_compile(fp);
 	/* Lock whole bpf_prog as read-only */
 	bpf_prog_lock_ro(fp);
+
+	return check_tail_call(fp);
 }
 EXPORT_SYMBOL_GPL(bpf_prog_select_runtime);
 
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 3bae6c591914..98a69bd83069 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -68,6 +68,12 @@ static int bpf_map_release(struct inode *inode, struct file *filp)
 {
 	struct bpf_map *map = filp->private_data;
 
+	if (map->map_type == BPF_MAP_TYPE_PROG_ARRAY)
+		/* prog_array stores refcnt-ed bpf_prog pointers
+		 * release them all when user space closes prog_array_fd
+		 */
+		bpf_prog_array_map_clear(map);
+
 	bpf_map_put(map);
 	return 0;
 }
@@ -392,6 +398,19 @@ static void fixup_bpf_calls(struct bpf_prog *prog)
 			 */
 			BUG_ON(!prog->aux->ops->get_func_proto);
 
+			if (insn->imm == BPF_FUNC_tail_call) {
+				/* mark bpf_tail_call as different opcode
+				 * to avoid conditional branch in
+				 * interpeter for every normal call
+				 * and to prevent accidental JITing by
+				 * JIT compiler that doesn't support
+				 * bpf_tail_call yet
+				 */
+				insn->imm = 0;
+				insn->code |= BPF_X;
+				continue;
+			}
+
 			fn = prog->aux->ops->get_func_proto(insn->imm);
 			/* all functions that have prototype and verifier allowed
 			 * programs to call them, must be real in-kernel functions
@@ -532,7 +551,9 @@ static int bpf_prog_load(union bpf_attr *attr)
 	fixup_bpf_calls(prog);
 
 	/* eBPF program is ready to be JITed */
-	bpf_prog_select_runtime(prog);
+	err = bpf_prog_select_runtime(prog);
+	if (err < 0)
+		goto free_used_maps;
 
 	err = anon_inode_getfd("bpf-prog", &bpf_prog_fops, prog, O_RDWR | O_CLOEXEC);
 	if (err < 0)
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 47dcd3aa6e23..cfd9a40b9a5a 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -907,6 +907,23 @@ static int check_call(struct verifier_env *env, int func_id)
 			fn->ret_type, func_id);
 		return -EINVAL;
 	}
+
+	if (map && map->map_type == BPF_MAP_TYPE_PROG_ARRAY &&
+	    func_id != BPF_FUNC_tail_call)
+		/* prog_array map type needs extra care:
+		 * only allow to pass it into bpf_tail_call() for now.
+		 * bpf_map_delete_elem() can be allowed in the future,
+		 * while bpf_map_update_elem() must only be done via syscall
+		 */
+		return -EINVAL;
+
+	if (func_id == BPF_FUNC_tail_call &&
+	    map->map_type != BPF_MAP_TYPE_PROG_ARRAY)
+		/* don't allow any other map type to be passed into
+		 * bpf_tail_call()
+		 */
+		return -EINVAL;
+
 	return 0;
 }
 
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 2d56ce501632..646445e41bd4 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -172,6 +172,8 @@ static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func
 		return &bpf_probe_read_proto;
 	case BPF_FUNC_ktime_get_ns:
 		return &bpf_ktime_get_ns_proto;
+	case BPF_FUNC_tail_call:
+		return &bpf_tail_call_proto;
 
 	case BPF_FUNC_trace_printk:
 		/*
diff --git a/net/core/filter.c b/net/core/filter.c
index 6805717be614..3adcca6f17a4 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1421,6 +1421,8 @@ sk_filter_func_proto(enum bpf_func_id func_id)
 		return &bpf_get_prandom_u32_proto;
 	case BPF_FUNC_get_smp_processor_id:
 		return &bpf_get_smp_processor_id_proto;
+	case BPF_FUNC_tail_call:
+		return &bpf_tail_call_proto;
 	default:
 		return NULL;
 	}
-- 
1.7.9.5
