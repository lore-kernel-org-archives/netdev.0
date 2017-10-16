From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 1/4] bpf: split verifier and program ops
Date: Mon, 16 Oct 2017 16:40:53 -0700
Message-ID: <20171016234056.1964-2-jakub.kicinski@netronome.com>
References: <20171016234056.1964-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:49903 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932483AbdJPXlJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 19:41:09 -0400
Received: by mail-pg0-f44.google.com with SMTP id g6so6647517pgn.6
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 16:41:09 -0700 (PDT)
In-Reply-To: <20171016234056.1964-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct bpf_verifier_ops contains both verifier ops and operations
used later during program's lifetime (test_run).  Split the runtime
ops into a different structure.

BPF_PROG_TYPE() will now append ## _prog_ops or ## _verifier_ops
to the names.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 include/linux/bpf.h       | 15 ++++++++++-----
 include/linux/bpf_types.h | 28 ++++++++++++++--------------
 kernel/bpf/syscall.c      | 16 +++++++++++++---
 kernel/bpf/verifier.c     | 12 ++++++------
 kernel/trace/bpf_trace.c  | 15 ++++++++++++---
 net/core/filter.c         | 45 ++++++++++++++++++++++++++++++++++++---------
 6 files changed, 91 insertions(+), 40 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 4373125de1f3..010bb48fb1d8 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -157,6 +157,11 @@ bpf_ctx_record_field_size(struct bpf_insn_access_aux *aux, u32 size)
 	aux->ctx_field_size = size;
 }
 
+struct bpf_prog_ops {
+	int (*test_run)(struct bpf_prog *prog, const union bpf_attr *kattr,
+			union bpf_attr __user *uattr);
+};
+
 struct bpf_verifier_ops {
 	/* return eBPF function prototype for verification */
 	const struct bpf_func_proto *(*get_func_proto)(enum bpf_func_id func_id);
@@ -172,8 +177,6 @@ struct bpf_verifier_ops {
 				  const struct bpf_insn *src,
 				  struct bpf_insn *dst,
 				  struct bpf_prog *prog, u32 *target_size);
-	int (*test_run)(struct bpf_prog *prog, const union bpf_attr *kattr,
-			union bpf_attr __user *uattr);
 };
 
 struct bpf_prog_aux {
@@ -184,7 +187,8 @@ struct bpf_prog_aux {
 	u32 id;
 	struct latch_tree_node ksym_tnode;
 	struct list_head ksym_lnode;
-	const struct bpf_verifier_ops *ops;
+	const struct bpf_prog_ops *ops;
+	const struct bpf_verifier_ops *vops;
 	struct bpf_map **used_maps;
 	struct bpf_prog *prog;
 	struct user_struct *user;
@@ -279,8 +283,9 @@ int bpf_prog_array_copy_to_user(struct bpf_prog_array __rcu *progs,
 #ifdef CONFIG_BPF_SYSCALL
 DECLARE_PER_CPU(int, bpf_prog_active);
 
-#define BPF_PROG_TYPE(_id, _ops) \
-	extern const struct bpf_verifier_ops _ops;
+#define BPF_PROG_TYPE(_id, _name) \
+	extern const struct bpf_prog_ops _name ## _prog_ops; \
+	extern const struct bpf_verifier_ops _name ## _verifier_ops;
 #define BPF_MAP_TYPE(_id, _ops) \
 	extern const struct bpf_map_ops _ops;
 #include <linux/bpf_types.h>
diff --git a/include/linux/bpf_types.h b/include/linux/bpf_types.h
index 6f1a567667b8..eeed0e1c3ea4 100644
--- a/include/linux/bpf_types.h
+++ b/include/linux/bpf_types.h
@@ -1,22 +1,22 @@
 /* internal file - do not include directly */
 
 #ifdef CONFIG_NET
-BPF_PROG_TYPE(BPF_PROG_TYPE_SOCKET_FILTER, sk_filter_prog_ops)
-BPF_PROG_TYPE(BPF_PROG_TYPE_SCHED_CLS, tc_cls_act_prog_ops)
-BPF_PROG_TYPE(BPF_PROG_TYPE_SCHED_ACT, tc_cls_act_prog_ops)
-BPF_PROG_TYPE(BPF_PROG_TYPE_XDP, xdp_prog_ops)
-BPF_PROG_TYPE(BPF_PROG_TYPE_CGROUP_SKB, cg_skb_prog_ops)
-BPF_PROG_TYPE(BPF_PROG_TYPE_CGROUP_SOCK, cg_sock_prog_ops)
-BPF_PROG_TYPE(BPF_PROG_TYPE_LWT_IN, lwt_inout_prog_ops)
-BPF_PROG_TYPE(BPF_PROG_TYPE_LWT_OUT, lwt_inout_prog_ops)
-BPF_PROG_TYPE(BPF_PROG_TYPE_LWT_XMIT, lwt_xmit_prog_ops)
-BPF_PROG_TYPE(BPF_PROG_TYPE_SOCK_OPS, sock_ops_prog_ops)
-BPF_PROG_TYPE(BPF_PROG_TYPE_SK_SKB, sk_skb_prog_ops)
+BPF_PROG_TYPE(BPF_PROG_TYPE_SOCKET_FILTER, sk_filter)
+BPF_PROG_TYPE(BPF_PROG_TYPE_SCHED_CLS, tc_cls_act)
+BPF_PROG_TYPE(BPF_PROG_TYPE_SCHED_ACT, tc_cls_act)
+BPF_PROG_TYPE(BPF_PROG_TYPE_XDP, xdp)
+BPF_PROG_TYPE(BPF_PROG_TYPE_CGROUP_SKB, cg_skb)
+BPF_PROG_TYPE(BPF_PROG_TYPE_CGROUP_SOCK, cg_sock)
+BPF_PROG_TYPE(BPF_PROG_TYPE_LWT_IN, lwt_inout)
+BPF_PROG_TYPE(BPF_PROG_TYPE_LWT_OUT, lwt_inout)
+BPF_PROG_TYPE(BPF_PROG_TYPE_LWT_XMIT, lwt_xmit)
+BPF_PROG_TYPE(BPF_PROG_TYPE_SOCK_OPS, sock_ops)
+BPF_PROG_TYPE(BPF_PROG_TYPE_SK_SKB, sk_skb)
 #endif
 #ifdef CONFIG_BPF_EVENTS
-BPF_PROG_TYPE(BPF_PROG_TYPE_KPROBE, kprobe_prog_ops)
-BPF_PROG_TYPE(BPF_PROG_TYPE_TRACEPOINT, tracepoint_prog_ops)
-BPF_PROG_TYPE(BPF_PROG_TYPE_PERF_EVENT, perf_event_prog_ops)
+BPF_PROG_TYPE(BPF_PROG_TYPE_KPROBE, kprobe)
+BPF_PROG_TYPE(BPF_PROG_TYPE_TRACEPOINT, tracepoint)
+BPF_PROG_TYPE(BPF_PROG_TYPE_PERF_EVENT, perf_event)
 #endif
 
 BPF_MAP_TYPE(BPF_MAP_TYPE_ARRAY, array_map_ops)
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index d124e702e040..714c3b758aa7 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -733,9 +733,18 @@ static int map_get_next_key(union bpf_attr *attr)
 	return err;
 }
 
-static const struct bpf_verifier_ops * const bpf_prog_types[] = {
-#define BPF_PROG_TYPE(_id, _ops) \
-	[_id] = &_ops,
+static const struct bpf_prog_ops * const bpf_prog_types[] = {
+#define BPF_PROG_TYPE(_id, _name) \
+	[_id] = & _name ## _prog_ops,
+#define BPF_MAP_TYPE(_id, _ops)
+#include <linux/bpf_types.h>
+#undef BPF_PROG_TYPE
+#undef BPF_MAP_TYPE
+};
+
+static const struct bpf_verifier_ops * const bpf_verifier_ops[] = {
+#define BPF_PROG_TYPE(_id, _name) \
+	[_id] = & _name ## _verifier_ops,
 #define BPF_MAP_TYPE(_id, _ops)
 #include <linux/bpf_types.h>
 #undef BPF_PROG_TYPE
@@ -748,6 +757,7 @@ static int find_prog_type(enum bpf_prog_type type, struct bpf_prog *prog)
 		return -EINVAL;
 
 	prog->aux->ops = bpf_prog_types[type];
+	prog->aux->vops = bpf_verifier_ops[type];
 	prog->type = type;
 	return 0;
 }
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 9755279d94cb..6fd5edce5fa8 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -856,8 +856,8 @@ static int check_ctx_access(struct bpf_verifier_env *env, int insn_idx, int off,
 			*reg_type = info.reg_type;
 			return 0;
 		}
-	} else if (env->prog->aux->ops->is_valid_access &&
-		   env->prog->aux->ops->is_valid_access(off, size, t, &info)) {
+	} else if (env->prog->aux->vops->is_valid_access &&
+		   env->prog->aux->vops->is_valid_access(off, size, t, &info)) {
 		/* A non zero info.ctx_field_size indicates that this field is a
 		 * candidate for later verifier transformation to load the whole
 		 * field and then apply a mask when accessed with a narrower
@@ -1559,8 +1559,8 @@ static int check_call(struct bpf_verifier_env *env, int func_id, int insn_idx)
 		return -EINVAL;
 	}
 
-	if (env->prog->aux->ops->get_func_proto)
-		fn = env->prog->aux->ops->get_func_proto(func_id);
+	if (env->prog->aux->vops->get_func_proto)
+		fn = env->prog->aux->vops->get_func_proto(func_id);
 
 	if (!fn) {
 		verbose(env, "unknown func %s#%d\n", func_id_name(func_id),
@@ -4029,7 +4029,7 @@ static struct bpf_prog *bpf_patch_insn_data(struct bpf_verifier_env *env, u32 of
  */
 static int convert_ctx_accesses(struct bpf_verifier_env *env)
 {
-	const struct bpf_verifier_ops *ops = env->prog->aux->ops;
+	const struct bpf_verifier_ops *ops = env->prog->aux->vops;
 	int i, cnt, size, ctx_field_size, delta = 0;
 	const int insn_cnt = env->prog->len;
 	struct bpf_insn insn_buf[16], *insn;
@@ -4230,7 +4230,7 @@ static int fixup_bpf_calls(struct bpf_verifier_env *env)
 			insn      = new_prog->insnsi + i + delta;
 		}
 patch_call_imm:
-		fn = prog->aux->ops->get_func_proto(insn->imm);
+		fn = prog->aux->vops->get_func_proto(insn->imm);
 		/* all functions that have prototype and verifier allowed
 		 * programs to call them, must be real in-kernel functions
 		 */
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 04ea5314f2bc..3126da2f468a 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -561,11 +561,14 @@ static bool kprobe_prog_is_valid_access(int off, int size, enum bpf_access_type
 	return true;
 }
 
-const struct bpf_verifier_ops kprobe_prog_ops = {
+const struct bpf_verifier_ops kprobe_verifier_ops = {
 	.get_func_proto  = kprobe_prog_func_proto,
 	.is_valid_access = kprobe_prog_is_valid_access,
 };
 
+const struct bpf_prog_ops kprobe_prog_ops = {
+};
+
 BPF_CALL_5(bpf_perf_event_output_tp, void *, tp_buff, struct bpf_map *, map,
 	   u64, flags, void *, data, u64, size)
 {
@@ -667,11 +670,14 @@ static bool tp_prog_is_valid_access(int off, int size, enum bpf_access_type type
 	return true;
 }
 
-const struct bpf_verifier_ops tracepoint_prog_ops = {
+const struct bpf_verifier_ops tracepoint_verifier_ops = {
 	.get_func_proto  = tp_prog_func_proto,
 	.is_valid_access = tp_prog_is_valid_access,
 };
 
+const struct bpf_prog_ops tracepoint_prog_ops = {
+};
+
 static bool pe_prog_is_valid_access(int off, int size, enum bpf_access_type type,
 				    struct bpf_insn_access_aux *info)
 {
@@ -727,8 +733,11 @@ static u32 pe_prog_convert_ctx_access(enum bpf_access_type type,
 	return insn - insn_buf;
 }
 
-const struct bpf_verifier_ops perf_event_prog_ops = {
+const struct bpf_verifier_ops perf_event_verifier_ops = {
 	.get_func_proto		= tp_prog_func_proto,
 	.is_valid_access	= pe_prog_is_valid_access,
 	.convert_ctx_access	= pe_prog_convert_ctx_access,
 };
+
+const struct bpf_prog_ops perf_event_prog_ops = {
+};
diff --git a/net/core/filter.c b/net/core/filter.c
index 140fa9f9c0f4..8cffd1585451 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -4313,68 +4313,95 @@ static u32 sock_ops_convert_ctx_access(enum bpf_access_type type,
 	return insn - insn_buf;
 }
 
-const struct bpf_verifier_ops sk_filter_prog_ops = {
+const struct bpf_verifier_ops sk_filter_verifier_ops = {
 	.get_func_proto		= sk_filter_func_proto,
 	.is_valid_access	= sk_filter_is_valid_access,
 	.convert_ctx_access	= bpf_convert_ctx_access,
 };
 
-const struct bpf_verifier_ops tc_cls_act_prog_ops = {
+const struct bpf_prog_ops sk_filter_prog_ops = {
+};
+
+const struct bpf_verifier_ops tc_cls_act_verifier_ops = {
 	.get_func_proto		= tc_cls_act_func_proto,
 	.is_valid_access	= tc_cls_act_is_valid_access,
 	.convert_ctx_access	= tc_cls_act_convert_ctx_access,
 	.gen_prologue		= tc_cls_act_prologue,
+};
+
+const struct bpf_prog_ops tc_cls_act_prog_ops = {
 	.test_run		= bpf_prog_test_run_skb,
 };
 
-const struct bpf_verifier_ops xdp_prog_ops = {
+const struct bpf_verifier_ops xdp_verifier_ops = {
 	.get_func_proto		= xdp_func_proto,
 	.is_valid_access	= xdp_is_valid_access,
 	.convert_ctx_access	= xdp_convert_ctx_access,
+};
+
+const struct bpf_prog_ops xdp_prog_ops = {
 	.test_run		= bpf_prog_test_run_xdp,
 };
 
-const struct bpf_verifier_ops cg_skb_prog_ops = {
+const struct bpf_verifier_ops cg_skb_verifier_ops = {
 	.get_func_proto		= sk_filter_func_proto,
 	.is_valid_access	= sk_filter_is_valid_access,
 	.convert_ctx_access	= bpf_convert_ctx_access,
+};
+
+const struct bpf_prog_ops cg_skb_prog_ops = {
 	.test_run		= bpf_prog_test_run_skb,
 };
 
-const struct bpf_verifier_ops lwt_inout_prog_ops = {
+const struct bpf_verifier_ops lwt_inout_verifier_ops = {
 	.get_func_proto		= lwt_inout_func_proto,
 	.is_valid_access	= lwt_is_valid_access,
 	.convert_ctx_access	= bpf_convert_ctx_access,
+};
+
+const struct bpf_prog_ops lwt_inout_prog_ops = {
 	.test_run		= bpf_prog_test_run_skb,
 };
 
-const struct bpf_verifier_ops lwt_xmit_prog_ops = {
+const struct bpf_verifier_ops lwt_xmit_verifier_ops = {
 	.get_func_proto		= lwt_xmit_func_proto,
 	.is_valid_access	= lwt_is_valid_access,
 	.convert_ctx_access	= bpf_convert_ctx_access,
 	.gen_prologue		= tc_cls_act_prologue,
+};
+
+const struct bpf_prog_ops lwt_xmit_prog_ops = {
 	.test_run		= bpf_prog_test_run_skb,
 };
 
-const struct bpf_verifier_ops cg_sock_prog_ops = {
+const struct bpf_verifier_ops cg_sock_verifier_ops = {
 	.get_func_proto		= sock_filter_func_proto,
 	.is_valid_access	= sock_filter_is_valid_access,
 	.convert_ctx_access	= sock_filter_convert_ctx_access,
 };
 
-const struct bpf_verifier_ops sock_ops_prog_ops = {
+const struct bpf_prog_ops cg_sock_prog_ops = {
+};
+
+const struct bpf_verifier_ops sock_ops_verifier_ops = {
 	.get_func_proto		= sock_ops_func_proto,
 	.is_valid_access	= sock_ops_is_valid_access,
 	.convert_ctx_access	= sock_ops_convert_ctx_access,
 };
 
-const struct bpf_verifier_ops sk_skb_prog_ops = {
+const struct bpf_prog_ops sock_ops_prog_ops = {
+};
+
+const struct bpf_verifier_ops sk_skb_verifier_ops = {
 	.get_func_proto		= sk_skb_func_proto,
 	.is_valid_access	= sk_skb_is_valid_access,
 	.convert_ctx_access	= bpf_convert_ctx_access,
 	.gen_prologue		= sk_skb_prologue,
 };
 
+const struct bpf_prog_ops sk_skb_prog_ops = {
+};
+
 int sk_detach_filter(struct sock *sk)
 {
 	int ret = -ENOENT;
-- 
2.14.1
