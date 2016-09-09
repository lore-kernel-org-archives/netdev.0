From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 4/4] bpf: add BPF_CALL_x macros for declaring helpers
Date: Fri,  9 Sep 2016 02:45:31 +0200
Message-ID: <79e3de96c9cb3a41f28356b698474b504a3e203a.1473381476.git.daniel@iogearbox.net>
References: <cover.1473381476.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33187 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751292AbcIIApp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 20:45:45 -0400
In-Reply-To: <cover.1473381476.git.daniel@iogearbox.net>
In-Reply-To: <cover.1473381476.git.daniel@iogearbox.net>
References: <cover.1473381476.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This work adds BPF_CALL_<n>() macros and converts all the eBPF helper functions
to use them, in a similar fashion like we do with SYSCALL_DEFINE<n>() macros
that are used today. Motivation for this is to hide all the register handling
and all necessary casts from the user, so that it is done automatically in the
background when adding a BPF_CALL_<n>() call.

This makes current helpers easier to review, eases to write future helpers,
avoids getting the casting mess wrong, and allows for extending all helpers at
once (f.e. build time checks, etc). It also helps detecting more easily in
code reviews that unused registers are not instrumented in the code by accident,
breaking compatibility with existing programs.

BPF_CALL_<n>() internals are quite similar to SYSCALL_DEFINE<n>() ones with some
fundamental differences, for example, for generating the actual helper function
that carries all u64 regs, we need to fill unused regs, so that we always end up
with 5 u64 regs as an argument.

I reviewed several 0-5 generated BPF_CALL_<n>() variants of the .i results and
they look all as expected. No sparse issue spotted. We let this also sit for a
few days with Fengguang's kbuild test robot, and there were no issues seen. On
s390, it barked on the "uses dynamic stack allocation" notice, which is an old
one from bpf_perf_event_output{,_tp}() reappearing here due to the conversion
to the call wrapper, just telling that the perf raw record/frag sits on stack
(gcc with s390's -mwarn-dynamicstack), but that's all. Did various runtime tests
and they were fine as well. All eBPF helpers are now converted to use these
macros, getting rid of a good chunk of all the raw castings.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/filter.h   |  50 ++++++++++++++++++
 kernel/bpf/core.c        |   2 +-
 kernel/bpf/helpers.c     |  46 +++++------------
 kernel/bpf/stackmap.c    |   5 +-
 kernel/trace/bpf_trace.c |  75 +++++++++++++--------------
 net/core/filter.c        | 129 ++++++++++++++++++-----------------------------
 6 files changed, 149 insertions(+), 158 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 7fabad8..1f09c52 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -328,6 +328,56 @@ struct bpf_prog_aux;
 		__size;						\
 	})
 
+#define __BPF_MAP_0(m, v, ...) v
+#define __BPF_MAP_1(m, v, t, a, ...) m(t, a)
+#define __BPF_MAP_2(m, v, t, a, ...) m(t, a), __BPF_MAP_1(m, v, __VA_ARGS__)
+#define __BPF_MAP_3(m, v, t, a, ...) m(t, a), __BPF_MAP_2(m, v, __VA_ARGS__)
+#define __BPF_MAP_4(m, v, t, a, ...) m(t, a), __BPF_MAP_3(m, v, __VA_ARGS__)
+#define __BPF_MAP_5(m, v, t, a, ...) m(t, a), __BPF_MAP_4(m, v, __VA_ARGS__)
+
+#define __BPF_REG_0(...) __BPF_PAD(5)
+#define __BPF_REG_1(...) __BPF_MAP(1, __VA_ARGS__), __BPF_PAD(4)
+#define __BPF_REG_2(...) __BPF_MAP(2, __VA_ARGS__), __BPF_PAD(3)
+#define __BPF_REG_3(...) __BPF_MAP(3, __VA_ARGS__), __BPF_PAD(2)
+#define __BPF_REG_4(...) __BPF_MAP(4, __VA_ARGS__), __BPF_PAD(1)
+#define __BPF_REG_5(...) __BPF_MAP(5, __VA_ARGS__)
+
+#define __BPF_MAP(n, ...) __BPF_MAP_##n(__VA_ARGS__)
+#define __BPF_REG(n, ...) __BPF_REG_##n(__VA_ARGS__)
+
+#define __BPF_CAST(t, a)						       \
+	(__force t)							       \
+	(__force							       \
+	 typeof(__builtin_choose_expr(sizeof(t) == sizeof(unsigned long),      \
+				      (unsigned long)0, (t)0))) a
+#define __BPF_V void
+#define __BPF_N
+
+#define __BPF_DECL_ARGS(t, a) t   a
+#define __BPF_DECL_REGS(t, a) u64 a
+
+#define __BPF_PAD(n)							       \
+	__BPF_MAP(n, __BPF_DECL_ARGS, __BPF_N, u64, __ur_1, u64, __ur_2,       \
+		  u64, __ur_3, u64, __ur_4, u64, __ur_5)
+
+#define BPF_CALL_x(x, name, ...)					       \
+	static __always_inline						       \
+	u64 ____##name(__BPF_MAP(x, __BPF_DECL_ARGS, __BPF_V, __VA_ARGS__));   \
+	u64 name(__BPF_REG(x, __BPF_DECL_REGS, __BPF_N, __VA_ARGS__));	       \
+	u64 name(__BPF_REG(x, __BPF_DECL_REGS, __BPF_N, __VA_ARGS__))	       \
+	{								       \
+		return ____##name(__BPF_MAP(x,__BPF_CAST,__BPF_N,__VA_ARGS__));\
+	}								       \
+	static __always_inline						       \
+	u64 ____##name(__BPF_MAP(x, __BPF_DECL_ARGS, __BPF_V, __VA_ARGS__))
+
+#define BPF_CALL_0(name, ...)	BPF_CALL_x(0, name, __VA_ARGS__)
+#define BPF_CALL_1(name, ...)	BPF_CALL_x(1, name, __VA_ARGS__)
+#define BPF_CALL_2(name, ...)	BPF_CALL_x(2, name, __VA_ARGS__)
+#define BPF_CALL_3(name, ...)	BPF_CALL_x(3, name, __VA_ARGS__)
+#define BPF_CALL_4(name, ...)	BPF_CALL_x(4, name, __VA_ARGS__)
+#define BPF_CALL_5(name, ...)	BPF_CALL_x(5, name, __VA_ARGS__)
+
 #ifdef CONFIG_COMPAT
 /* A struct sock_filter is architecture independent. */
 struct compat_sock_fprog {
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 03fd23d..7b7baae 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -1018,7 +1018,7 @@ void bpf_user_rnd_init_once(void)
 	prandom_init_once(&bpf_user_rnd_state);
 }
 
-u64 bpf_user_rnd_u32(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+BPF_CALL_0(bpf_user_rnd_u32)
 {
 	/* Should someone ever have the rather unwise idea to use some
 	 * of the registers passed into this function, then note that
diff --git a/kernel/bpf/helpers.c b/kernel/bpf/helpers.c
index 6df73bd..a5b8bf8 100644
--- a/kernel/bpf/helpers.c
+++ b/kernel/bpf/helpers.c
@@ -16,6 +16,7 @@
 #include <linux/ktime.h>
 #include <linux/sched.h>
 #include <linux/uidgid.h>
+#include <linux/filter.h>
 
 /* If kernel subsystem is allowing eBPF programs to call this function,
  * inside its own verifier_ops->get_func_proto() callback it should return
@@ -26,24 +27,10 @@
  * if program is allowed to access maps, so check rcu_read_lock_held in
  * all three functions.
  */
-static u64 bpf_map_lookup_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+BPF_CALL_2(bpf_map_lookup_elem, struct bpf_map *, map, void *, key)
 {
-	/* verifier checked that R1 contains a valid pointer to bpf_map
-	 * and R2 points to a program stack and map->key_size bytes were
-	 * initialized
-	 */
-	struct bpf_map *map = (struct bpf_map *) (unsigned long) r1;
-	void *key = (void *) (unsigned long) r2;
-	void *value;
-
 	WARN_ON_ONCE(!rcu_read_lock_held());
-
-	value = map->ops->map_lookup_elem(map, key);
-
-	/* lookup() returns either pointer to element value or NULL
-	 * which is the meaning of PTR_TO_MAP_VALUE_OR_NULL type
-	 */
-	return (unsigned long) value;
+	return (unsigned long) map->ops->map_lookup_elem(map, key);
 }
 
 const struct bpf_func_proto bpf_map_lookup_elem_proto = {
@@ -54,15 +41,11 @@ const struct bpf_func_proto bpf_map_lookup_elem_proto = {
 	.arg2_type	= ARG_PTR_TO_MAP_KEY,
 };
 
-static u64 bpf_map_update_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+BPF_CALL_4(bpf_map_update_elem, struct bpf_map *, map, void *, key,
+	   void *, value, u64, flags)
 {
-	struct bpf_map *map = (struct bpf_map *) (unsigned long) r1;
-	void *key = (void *) (unsigned long) r2;
-	void *value = (void *) (unsigned long) r3;
-
 	WARN_ON_ONCE(!rcu_read_lock_held());
-
-	return map->ops->map_update_elem(map, key, value, r4);
+	return map->ops->map_update_elem(map, key, value, flags);
 }
 
 const struct bpf_func_proto bpf_map_update_elem_proto = {
@@ -75,13 +58,9 @@ const struct bpf_func_proto bpf_map_update_elem_proto = {
 	.arg4_type	= ARG_ANYTHING,
 };
 
-static u64 bpf_map_delete_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+BPF_CALL_2(bpf_map_delete_elem, struct bpf_map *, map, void *, key)
 {
-	struct bpf_map *map = (struct bpf_map *) (unsigned long) r1;
-	void *key = (void *) (unsigned long) r2;
-
 	WARN_ON_ONCE(!rcu_read_lock_held());
-
 	return map->ops->map_delete_elem(map, key);
 }
 
@@ -99,7 +78,7 @@ const struct bpf_func_proto bpf_get_prandom_u32_proto = {
 	.ret_type	= RET_INTEGER,
 };
 
-static u64 bpf_get_smp_processor_id(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+BPF_CALL_0(bpf_get_smp_processor_id)
 {
 	return smp_processor_id();
 }
@@ -110,7 +89,7 @@ const struct bpf_func_proto bpf_get_smp_processor_id_proto = {
 	.ret_type	= RET_INTEGER,
 };
 
-static u64 bpf_ktime_get_ns(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+BPF_CALL_0(bpf_ktime_get_ns)
 {
 	/* NMI safe access to clock monotonic */
 	return ktime_get_mono_fast_ns();
@@ -122,7 +101,7 @@ const struct bpf_func_proto bpf_ktime_get_ns_proto = {
 	.ret_type	= RET_INTEGER,
 };
 
-static u64 bpf_get_current_pid_tgid(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+BPF_CALL_0(bpf_get_current_pid_tgid)
 {
 	struct task_struct *task = current;
 
@@ -138,7 +117,7 @@ const struct bpf_func_proto bpf_get_current_pid_tgid_proto = {
 	.ret_type	= RET_INTEGER,
 };
 
-static u64 bpf_get_current_uid_gid(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+BPF_CALL_0(bpf_get_current_uid_gid)
 {
 	struct task_struct *task = current;
 	kuid_t uid;
@@ -158,10 +137,9 @@ const struct bpf_func_proto bpf_get_current_uid_gid_proto = {
 	.ret_type	= RET_INTEGER,
 };
 
-static u64 bpf_get_current_comm(u64 r1, u64 size, u64 r3, u64 r4, u64 r5)
+BPF_CALL_2(bpf_get_current_comm, char *, buf, u32, size)
 {
 	struct task_struct *task = current;
-	char *buf = (char *) (long) r1;
 
 	if (unlikely(!task))
 		goto err_clear;
diff --git a/kernel/bpf/stackmap.c b/kernel/bpf/stackmap.c
index bf4495f..732ae16 100644
--- a/kernel/bpf/stackmap.c
+++ b/kernel/bpf/stackmap.c
@@ -116,10 +116,9 @@ free_smap:
 	return ERR_PTR(err);
 }
 
-u64 bpf_get_stackid(u64 r1, u64 r2, u64 flags, u64 r4, u64 r5)
+BPF_CALL_3(bpf_get_stackid, struct pt_regs *, regs, struct bpf_map *, map,
+	   u64, flags)
 {
-	struct pt_regs *regs = (struct pt_regs *) (long) r1;
-	struct bpf_map *map = (struct bpf_map *) (long) r2;
 	struct bpf_stack_map *smap = container_of(map, struct bpf_stack_map, map);
 	struct perf_callchain_entry *trace;
 	struct stack_map_bucket *bucket, *new_bucket, *old_bucket;
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index e63d7d4..5dcb992 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -61,11 +61,9 @@ unsigned int trace_call_bpf(struct bpf_prog *prog, void *ctx)
 }
 EXPORT_SYMBOL_GPL(trace_call_bpf);
 
-static u64 bpf_probe_read(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+BPF_CALL_3(bpf_probe_read, void *, dst, u32, size, const void *, unsafe_ptr)
 {
-	void *dst = (void *) (long) r1;
-	int ret, size = (int) r2;
-	void *unsafe_ptr = (void *) (long) r3;
+	int ret;
 
 	ret = probe_kernel_read(dst, unsafe_ptr, size);
 	if (unlikely(ret < 0))
@@ -83,12 +81,9 @@ static const struct bpf_func_proto bpf_probe_read_proto = {
 	.arg3_type	= ARG_ANYTHING,
 };
 
-static u64 bpf_probe_write_user(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+BPF_CALL_3(bpf_probe_write_user, void *, unsafe_ptr, const void *, src,
+	   u32, size)
 {
-	void *unsafe_ptr = (void *) (long) r1;
-	void *src = (void *) (long) r2;
-	int size = (int) r3;
-
 	/*
 	 * Ensure we're in user context which is safe for the helper to
 	 * run. This helper has no business in a kthread.
@@ -130,9 +125,9 @@ static const struct bpf_func_proto *bpf_get_probe_write_proto(void)
  * limited trace_printk()
  * only %d %u %x %ld %lu %lx %lld %llu %llx %p %s conversion specifiers allowed
  */
-static u64 bpf_trace_printk(u64 r1, u64 fmt_size, u64 r3, u64 r4, u64 r5)
+BPF_CALL_5(bpf_trace_printk, char *, fmt, u32, fmt_size, u64, arg1,
+	   u64, arg2, u64, arg3)
 {
-	char *fmt = (char *) (long) r1;
 	bool str_seen = false;
 	int mod[3] = {};
 	int fmt_cnt = 0;
@@ -178,16 +173,16 @@ static u64 bpf_trace_printk(u64 r1, u64 fmt_size, u64 r3, u64 r4, u64 r5)
 
 				switch (fmt_cnt) {
 				case 1:
-					unsafe_addr = r3;
-					r3 = (long) buf;
+					unsafe_addr = arg1;
+					arg1 = (long) buf;
 					break;
 				case 2:
-					unsafe_addr = r4;
-					r4 = (long) buf;
+					unsafe_addr = arg2;
+					arg2 = (long) buf;
 					break;
 				case 3:
-					unsafe_addr = r5;
-					r5 = (long) buf;
+					unsafe_addr = arg3;
+					arg3 = (long) buf;
 					break;
 				}
 				buf[0] = 0;
@@ -209,9 +204,9 @@ static u64 bpf_trace_printk(u64 r1, u64 fmt_size, u64 r3, u64 r4, u64 r5)
 	}
 
 	return __trace_printk(1/* fake ip will not be printed */, fmt,
-			      mod[0] == 2 ? r3 : mod[0] == 1 ? (long) r3 : (u32) r3,
-			      mod[1] == 2 ? r4 : mod[1] == 1 ? (long) r4 : (u32) r4,
-			      mod[2] == 2 ? r5 : mod[2] == 1 ? (long) r5 : (u32) r5);
+			      mod[0] == 2 ? arg1 : mod[0] == 1 ? (long) arg1 : (u32) arg1,
+			      mod[1] == 2 ? arg2 : mod[1] == 1 ? (long) arg2 : (u32) arg2,
+			      mod[2] == 2 ? arg3 : mod[2] == 1 ? (long) arg3 : (u32) arg3);
 }
 
 static const struct bpf_func_proto bpf_trace_printk_proto = {
@@ -233,9 +228,8 @@ const struct bpf_func_proto *bpf_get_trace_printk_proto(void)
 	return &bpf_trace_printk_proto;
 }
 
-static u64 bpf_perf_event_read(u64 r1, u64 flags, u64 r3, u64 r4, u64 r5)
+BPF_CALL_2(bpf_perf_event_read, struct bpf_map *, map, u64, flags)
 {
-	struct bpf_map *map = (struct bpf_map *) (unsigned long) r1;
 	struct bpf_array *array = container_of(map, struct bpf_array, map);
 	unsigned int cpu = smp_processor_id();
 	u64 index = flags & BPF_F_INDEX_MASK;
@@ -312,11 +306,9 @@ __bpf_perf_event_output(struct pt_regs *regs, struct bpf_map *map,
 	return 0;
 }
 
-static u64 bpf_perf_event_output(u64 r1, u64 r2, u64 flags, u64 r4, u64 size)
+BPF_CALL_5(bpf_perf_event_output, struct pt_regs *, regs, struct bpf_map *, map,
+	   u64, flags, void *, data, u64, size)
 {
-	struct pt_regs *regs = (struct pt_regs *)(long) r1;
-	struct bpf_map *map  = (struct bpf_map *)(long) r2;
-	void *data = (void *)(long) r4;
 	struct perf_raw_record raw = {
 		.frag = {
 			.size = size,
@@ -367,7 +359,7 @@ u64 bpf_event_output(struct bpf_map *map, u64 flags, void *meta, u64 meta_size,
 	return __bpf_perf_event_output(regs, map, flags, &raw);
 }
 
-static u64 bpf_get_current_task(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+BPF_CALL_0(bpf_get_current_task)
 {
 	return (long) current;
 }
@@ -378,16 +370,13 @@ static const struct bpf_func_proto bpf_get_current_task_proto = {
 	.ret_type	= RET_INTEGER,
 };
 
-static u64 bpf_current_task_under_cgroup(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+BPF_CALL_2(bpf_current_task_under_cgroup, struct bpf_map *, map, u32, idx)
 {
-	struct bpf_map *map = (struct bpf_map *)(long)r1;
 	struct bpf_array *array = container_of(map, struct bpf_array, map);
 	struct cgroup *cgrp;
-	u32 idx = (u32)r2;
 
 	if (unlikely(in_interrupt()))
 		return -EINVAL;
-
 	if (unlikely(idx >= array->map.max_entries))
 		return -E2BIG;
 
@@ -481,16 +470,17 @@ static struct bpf_prog_type_list kprobe_tl = {
 	.type	= BPF_PROG_TYPE_KPROBE,
 };
 
-static u64 bpf_perf_event_output_tp(u64 r1, u64 r2, u64 index, u64 r4, u64 size)
+BPF_CALL_5(bpf_perf_event_output_tp, void *, tp_buff, struct bpf_map *, map,
+	   u64, flags, void *, data, u64, size)
 {
+	struct pt_regs *regs = *(struct pt_regs **)tp_buff;
+
 	/*
 	 * r1 points to perf tracepoint buffer where first 8 bytes are hidden
 	 * from bpf program and contain a pointer to 'struct pt_regs'. Fetch it
-	 * from there and call the same bpf_perf_event_output() helper
+	 * from there and call the same bpf_perf_event_output() helper inline.
 	 */
-	u64 ctx = *(long *)(uintptr_t)r1;
-
-	return bpf_perf_event_output(ctx, r2, index, r4, size);
+	return ____bpf_perf_event_output(regs, map, flags, data, size);
 }
 
 static const struct bpf_func_proto bpf_perf_event_output_proto_tp = {
@@ -504,11 +494,18 @@ static const struct bpf_func_proto bpf_perf_event_output_proto_tp = {
 	.arg5_type	= ARG_CONST_STACK_SIZE,
 };
 
-static u64 bpf_get_stackid_tp(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+BPF_CALL_3(bpf_get_stackid_tp, void *, tp_buff, struct bpf_map *, map,
+	   u64, flags)
 {
-	u64 ctx = *(long *)(uintptr_t)r1;
+	struct pt_regs *regs = *(struct pt_regs **)tp_buff;
 
-	return bpf_get_stackid(ctx, r2, r3, r4, r5);
+	/*
+	 * Same comment as in bpf_perf_event_output_tp(), only that this time
+	 * the other helper's function body cannot be inlined due to being
+	 * external, thus we need to call raw helper function.
+	 */
+	return bpf_get_stackid((unsigned long) regs, (unsigned long) map,
+			       flags, 0, 0);
 }
 
 static const struct bpf_func_proto bpf_get_stackid_proto_tp = {
diff --git a/net/core/filter.c b/net/core/filter.c
index d6d9bb8..298b146 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -94,14 +94,13 @@ int sk_filter_trim_cap(struct sock *sk, struct sk_buff *skb, unsigned int cap)
 }
 EXPORT_SYMBOL(sk_filter_trim_cap);
 
-static u64 __skb_get_pay_offset(u64 ctx, u64 a, u64 x, u64 r4, u64 r5)
+BPF_CALL_1(__skb_get_pay_offset, struct sk_buff *, skb)
 {
-	return skb_get_poff((struct sk_buff *)(unsigned long) ctx);
+	return skb_get_poff(skb);
 }
 
-static u64 __skb_get_nlattr(u64 ctx, u64 a, u64 x, u64 r4, u64 r5)
+BPF_CALL_3(__skb_get_nlattr, struct sk_buff *, skb, u32, a, u32, x)
 {
-	struct sk_buff *skb = (struct sk_buff *)(unsigned long) ctx;
 	struct nlattr *nla;
 
 	if (skb_is_nonlinear(skb))
@@ -120,9 +119,8 @@ static u64 __skb_get_nlattr(u64 ctx, u64 a, u64 x, u64 r4, u64 r5)
 	return 0;
 }
 
-static u64 __skb_get_nlattr_nest(u64 ctx, u64 a, u64 x, u64 r4, u64 r5)
+BPF_CALL_3(__skb_get_nlattr_nest, struct sk_buff *, skb, u32, a, u32, x)
 {
-	struct sk_buff *skb = (struct sk_buff *)(unsigned long) ctx;
 	struct nlattr *nla;
 
 	if (skb_is_nonlinear(skb))
@@ -145,7 +143,7 @@ static u64 __skb_get_nlattr_nest(u64 ctx, u64 a, u64 x, u64 r4, u64 r5)
 	return 0;
 }
 
-static u64 __get_raw_cpu_id(u64 ctx, u64 a, u64 x, u64 r4, u64 r5)
+BPF_CALL_0(__get_raw_cpu_id)
 {
 	return raw_smp_processor_id();
 }
@@ -1376,12 +1374,9 @@ static inline void bpf_pull_mac_rcsum(struct sk_buff *skb)
 		skb_postpull_rcsum(skb, skb_mac_header(skb), skb->mac_len);
 }
 
-static u64 bpf_skb_store_bytes(u64 r1, u64 r2, u64 r3, u64 r4, u64 flags)
+BPF_CALL_5(bpf_skb_store_bytes, struct sk_buff *, skb, u32, offset,
+	   const void *, from, u32, len, u64, flags)
 {
-	struct sk_buff *skb = (struct sk_buff *) (long) r1;
-	unsigned int offset = (unsigned int) r2;
-	void *from = (void *) (long) r3;
-	unsigned int len = (unsigned int) r4;
 	void *ptr;
 
 	if (unlikely(flags & ~(BPF_F_RECOMPUTE_CSUM | BPF_F_INVALIDATE_HASH)))
@@ -1416,12 +1411,9 @@ static const struct bpf_func_proto bpf_skb_store_bytes_proto = {
 	.arg5_type	= ARG_ANYTHING,
 };
 
-static u64 bpf_skb_load_bytes(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+BPF_CALL_4(bpf_skb_load_bytes, const struct sk_buff *, skb, u32, offset,
+	   void *, to, u32, len)
 {
-	const struct sk_buff *skb = (const struct sk_buff *)(unsigned long) r1;
-	unsigned int offset = (unsigned int) r2;
-	void *to = (void *)(unsigned long) r3;
-	unsigned int len = (unsigned int) r4;
 	void *ptr;
 
 	if (unlikely(offset > 0xffff))
@@ -1449,10 +1441,9 @@ static const struct bpf_func_proto bpf_skb_load_bytes_proto = {
 	.arg4_type	= ARG_CONST_STACK_SIZE,
 };
 
-static u64 bpf_l3_csum_replace(u64 r1, u64 r2, u64 from, u64 to, u64 flags)
+BPF_CALL_5(bpf_l3_csum_replace, struct sk_buff *, skb, u32, offset,
+	   u64, from, u64, to, u64, flags)
 {
-	struct sk_buff *skb = (struct sk_buff *) (long) r1;
-	unsigned int offset = (unsigned int) r2;
 	__sum16 *ptr;
 
 	if (unlikely(flags & ~(BPF_F_HDR_FIELD_MASK)))
@@ -1494,12 +1485,11 @@ static const struct bpf_func_proto bpf_l3_csum_replace_proto = {
 	.arg5_type	= ARG_ANYTHING,
 };
 
-static u64 bpf_l4_csum_replace(u64 r1, u64 r2, u64 from, u64 to, u64 flags)
+BPF_CALL_5(bpf_l4_csum_replace, struct sk_buff *, skb, u32, offset,
+	   u64, from, u64, to, u64, flags)
 {
-	struct sk_buff *skb = (struct sk_buff *) (long) r1;
 	bool is_pseudo = flags & BPF_F_PSEUDO_HDR;
 	bool is_mmzero = flags & BPF_F_MARK_MANGLED_0;
-	unsigned int offset = (unsigned int) r2;
 	__sum16 *ptr;
 
 	if (unlikely(flags & ~(BPF_F_MARK_MANGLED_0 | BPF_F_PSEUDO_HDR |
@@ -1547,12 +1537,11 @@ static const struct bpf_func_proto bpf_l4_csum_replace_proto = {
 	.arg5_type	= ARG_ANYTHING,
 };
 
-static u64 bpf_csum_diff(u64 r1, u64 from_size, u64 r3, u64 to_size, u64 seed)
+BPF_CALL_5(bpf_csum_diff, __be32 *, from, u32, from_size,
+	   __be32 *, to, u32, to_size, __wsum, seed)
 {
 	struct bpf_scratchpad *sp = this_cpu_ptr(&bpf_sp);
-	u64 diff_size = from_size + to_size;
-	__be32 *from = (__be32 *) (long) r1;
-	__be32 *to   = (__be32 *) (long) r3;
+	u32 diff_size = from_size + to_size;
 	int i, j = 0;
 
 	/* This is quite flexible, some examples:
@@ -1610,9 +1599,8 @@ static inline int __bpf_tx_skb(struct net_device *dev, struct sk_buff *skb)
 	return ret;
 }
 
-static u64 bpf_clone_redirect(u64 r1, u64 ifindex, u64 flags, u64 r4, u64 r5)
+BPF_CALL_3(bpf_clone_redirect, struct sk_buff *, skb, u32, ifindex, u64, flags)
 {
-	struct sk_buff *skb = (struct sk_buff *) (long) r1;
 	struct net_device *dev;
 
 	if (unlikely(flags & ~(BPF_F_INGRESS)))
@@ -1648,7 +1636,7 @@ struct redirect_info {
 
 static DEFINE_PER_CPU(struct redirect_info, redirect_info);
 
-static u64 bpf_redirect(u64 ifindex, u64 flags, u64 r3, u64 r4, u64 r5)
+BPF_CALL_2(bpf_redirect, u32, ifindex, u64, flags)
 {
 	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
 
@@ -1687,9 +1675,9 @@ static const struct bpf_func_proto bpf_redirect_proto = {
 	.arg2_type      = ARG_ANYTHING,
 };
 
-static u64 bpf_get_cgroup_classid(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+BPF_CALL_1(bpf_get_cgroup_classid, const struct sk_buff *, skb)
 {
-	return task_get_classid((struct sk_buff *) (unsigned long) r1);
+	return task_get_classid(skb);
 }
 
 static const struct bpf_func_proto bpf_get_cgroup_classid_proto = {
@@ -1699,9 +1687,9 @@ static const struct bpf_func_proto bpf_get_cgroup_classid_proto = {
 	.arg1_type      = ARG_PTR_TO_CTX,
 };
 
-static u64 bpf_get_route_realm(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+BPF_CALL_1(bpf_get_route_realm, const struct sk_buff *, skb)
 {
-	return dst_tclassid((struct sk_buff *) (unsigned long) r1);
+	return dst_tclassid(skb);
 }
 
 static const struct bpf_func_proto bpf_get_route_realm_proto = {
@@ -1711,14 +1699,14 @@ static const struct bpf_func_proto bpf_get_route_realm_proto = {
 	.arg1_type      = ARG_PTR_TO_CTX,
 };
 
-static u64 bpf_get_hash_recalc(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+BPF_CALL_1(bpf_get_hash_recalc, struct sk_buff *, skb)
 {
 	/* If skb_clear_hash() was called due to mangling, we can
 	 * trigger SW recalculation here. Later access to hash
 	 * can then use the inline skb->hash via context directly
 	 * instead of calling this helper again.
 	 */
-	return skb_get_hash((struct sk_buff *) (unsigned long) r1);
+	return skb_get_hash(skb);
 }
 
 static const struct bpf_func_proto bpf_get_hash_recalc_proto = {
@@ -1728,10 +1716,9 @@ static const struct bpf_func_proto bpf_get_hash_recalc_proto = {
 	.arg1_type	= ARG_PTR_TO_CTX,
 };
 
-static u64 bpf_skb_vlan_push(u64 r1, u64 r2, u64 vlan_tci, u64 r4, u64 r5)
+BPF_CALL_3(bpf_skb_vlan_push, struct sk_buff *, skb, __be16, vlan_proto,
+	   u16, vlan_tci)
 {
-	struct sk_buff *skb = (struct sk_buff *) (long) r1;
-	__be16 vlan_proto = (__force __be16) r2;
 	int ret;
 
 	if (unlikely(vlan_proto != htons(ETH_P_8021Q) &&
@@ -1756,9 +1743,8 @@ const struct bpf_func_proto bpf_skb_vlan_push_proto = {
 };
 EXPORT_SYMBOL_GPL(bpf_skb_vlan_push_proto);
 
-static u64 bpf_skb_vlan_pop(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+BPF_CALL_1(bpf_skb_vlan_pop, struct sk_buff *, skb)
 {
-	struct sk_buff *skb = (struct sk_buff *) (long) r1;
 	int ret;
 
 	bpf_push_mac_rcsum(skb);
@@ -1933,10 +1919,9 @@ static int bpf_skb_proto_xlat(struct sk_buff *skb, __be16 to_proto)
 	return -ENOTSUPP;
 }
 
-static u64 bpf_skb_change_proto(u64 r1, u64 r2, u64 flags, u64 r4, u64 r5)
+BPF_CALL_3(bpf_skb_change_proto, struct sk_buff *, skb, __be16, proto,
+	   u64, flags)
 {
-	struct sk_buff *skb = (struct sk_buff *) (long) r1;
-	__be16 proto = (__force __be16) r2;
 	int ret;
 
 	if (unlikely(flags))
@@ -1973,11 +1958,8 @@ static const struct bpf_func_proto bpf_skb_change_proto_proto = {
 	.arg3_type	= ARG_ANYTHING,
 };
 
-static u64 bpf_skb_change_type(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+BPF_CALL_2(bpf_skb_change_type, struct sk_buff *, skb, u32, pkt_type)
 {
-	struct sk_buff *skb = (struct sk_buff *) (long) r1;
-	u32 pkt_type = r2;
-
 	/* We only allow a restricted subset to be changed for now. */
 	if (unlikely(!skb_pkt_type_ok(skb->pkt_type) ||
 		     !skb_pkt_type_ok(pkt_type)))
@@ -2028,12 +2010,11 @@ static int bpf_skb_trim_rcsum(struct sk_buff *skb, unsigned int new_len)
 	return __skb_trim_rcsum(skb, new_len);
 }
 
-static u64 bpf_skb_change_tail(u64 r1, u64 r2, u64 flags, u64 r4, u64 r5)
+BPF_CALL_3(bpf_skb_change_tail, struct sk_buff *, skb, u32, new_len,
+	   u64, flags)
 {
-	struct sk_buff *skb = (struct sk_buff *)(long) r1;
 	u32 max_len = __bpf_skb_max_len(skb);
 	u32 min_len = __bpf_skb_min_len(skb);
-	u32 new_len = (u32) r2;
 	int ret;
 
 	if (unlikely(flags || new_len > max_len || new_len < min_len))
@@ -2113,13 +2094,10 @@ static unsigned long bpf_skb_copy(void *dst_buff, const void *skb,
 	return 0;
 }
 
-static u64 bpf_skb_event_output(u64 r1, u64 r2, u64 flags, u64 r4,
-				u64 meta_size)
+BPF_CALL_5(bpf_skb_event_output, struct sk_buff *, skb, struct bpf_map *, map,
+	   u64, flags, void *, meta, u64, meta_size)
 {
-	struct sk_buff *skb = (struct sk_buff *)(long) r1;
-	struct bpf_map *map = (struct bpf_map *)(long) r2;
 	u64 skb_size = (flags & BPF_F_CTXLEN_MASK) >> 32;
-	void *meta = (void *)(long) r4;
 
 	if (unlikely(flags & ~(BPF_F_CTXLEN_MASK | BPF_F_INDEX_MASK)))
 		return -EINVAL;
@@ -2146,10 +2124,9 @@ static unsigned short bpf_tunnel_key_af(u64 flags)
 	return flags & BPF_F_TUNINFO_IPV6 ? AF_INET6 : AF_INET;
 }
 
-static u64 bpf_skb_get_tunnel_key(u64 r1, u64 r2, u64 size, u64 flags, u64 r5)
+BPF_CALL_4(bpf_skb_get_tunnel_key, struct sk_buff *, skb, struct bpf_tunnel_key *, to,
+	   u32, size, u64, flags)
 {
-	struct sk_buff *skb = (struct sk_buff *) (long) r1;
-	struct bpf_tunnel_key *to = (struct bpf_tunnel_key *) (long) r2;
 	const struct ip_tunnel_info *info = skb_tunnel_info(skb);
 	u8 compat[sizeof(struct bpf_tunnel_key)];
 	void *to_orig = to;
@@ -2214,10 +2191,8 @@ static const struct bpf_func_proto bpf_skb_get_tunnel_key_proto = {
 	.arg4_type	= ARG_ANYTHING,
 };
 
-static u64 bpf_skb_get_tunnel_opt(u64 r1, u64 r2, u64 size, u64 r4, u64 r5)
+BPF_CALL_3(bpf_skb_get_tunnel_opt, struct sk_buff *, skb, u8 *, to, u32, size)
 {
-	struct sk_buff *skb = (struct sk_buff *) (long) r1;
-	u8 *to = (u8 *) (long) r2;
 	const struct ip_tunnel_info *info = skb_tunnel_info(skb);
 	int err;
 
@@ -2252,10 +2227,9 @@ static const struct bpf_func_proto bpf_skb_get_tunnel_opt_proto = {
 
 static struct metadata_dst __percpu *md_dst;
 
-static u64 bpf_skb_set_tunnel_key(u64 r1, u64 r2, u64 size, u64 flags, u64 r5)
+BPF_CALL_4(bpf_skb_set_tunnel_key, struct sk_buff *, skb,
+	   const struct bpf_tunnel_key *, from, u32, size, u64, flags)
 {
-	struct sk_buff *skb = (struct sk_buff *) (long) r1;
-	struct bpf_tunnel_key *from = (struct bpf_tunnel_key *) (long) r2;
 	struct metadata_dst *md = this_cpu_ptr(md_dst);
 	u8 compat[sizeof(struct bpf_tunnel_key)];
 	struct ip_tunnel_info *info;
@@ -2273,7 +2247,7 @@ static u64 bpf_skb_set_tunnel_key(u64 r1, u64 r2, u64 size, u64 flags, u64 r5)
 			 */
 			memcpy(compat, from, size);
 			memset(compat + size, 0, sizeof(compat) - size);
-			from = (struct bpf_tunnel_key *)compat;
+			from = (const struct bpf_tunnel_key *) compat;
 			break;
 		default:
 			return -EINVAL;
@@ -2323,10 +2297,9 @@ static const struct bpf_func_proto bpf_skb_set_tunnel_key_proto = {
 	.arg4_type	= ARG_ANYTHING,
 };
 
-static u64 bpf_skb_set_tunnel_opt(u64 r1, u64 r2, u64 size, u64 r4, u64 r5)
+BPF_CALL_3(bpf_skb_set_tunnel_opt, struct sk_buff *, skb,
+	   const u8 *, from, u32, size)
 {
-	struct sk_buff *skb = (struct sk_buff *) (long) r1;
-	u8 *from = (u8 *) (long) r2;
 	struct ip_tunnel_info *info = skb_tunnel_info(skb);
 	const struct metadata_dst *md = this_cpu_ptr(md_dst);
 
@@ -2372,23 +2345,20 @@ bpf_get_skb_set_tunnel_proto(enum bpf_func_id which)
 	}
 }
 
-static u64 bpf_skb_under_cgroup(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+BPF_CALL_3(bpf_skb_under_cgroup, struct sk_buff *, skb, struct bpf_map *, map,
+	   u32, idx)
 {
-	struct sk_buff *skb = (struct sk_buff *)(long)r1;
-	struct bpf_map *map = (struct bpf_map *)(long)r2;
 	struct bpf_array *array = container_of(map, struct bpf_array, map);
 	struct cgroup *cgrp;
 	struct sock *sk;
-	u32 i = (u32)r3;
 
 	sk = skb->sk;
 	if (!sk || !sk_fullsock(sk))
 		return -ENOENT;
-
-	if (unlikely(i >= array->map.max_entries))
+	if (unlikely(idx >= array->map.max_entries))
 		return -E2BIG;
 
-	cgrp = READ_ONCE(array->ptrs[i]);
+	cgrp = READ_ONCE(array->ptrs[idx]);
 	if (unlikely(!cgrp))
 		return -EAGAIN;
 
@@ -2411,13 +2381,10 @@ static unsigned long bpf_xdp_copy(void *dst_buff, const void *src_buff,
 	return 0;
 }
 
-static u64 bpf_xdp_event_output(u64 r1, u64 r2, u64 flags, u64 r4,
-				u64 meta_size)
+BPF_CALL_5(bpf_xdp_event_output, struct xdp_buff *, xdp, struct bpf_map *, map,
+	   u64, flags, void *, meta, u64, meta_size)
 {
-	struct xdp_buff *xdp = (struct xdp_buff *)(long) r1;
-	struct bpf_map *map = (struct bpf_map *)(long) r2;
 	u64 xdp_size = (flags & BPF_F_CTXLEN_MASK) >> 32;
-	void *meta = (void *)(long) r4;
 
 	if (unlikely(flags & ~(BPF_F_CTXLEN_MASK | BPF_F_INDEX_MASK)))
 		return -EINVAL;
-- 
1.9.3
