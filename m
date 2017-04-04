From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 1/2] bpf: remove struct bpf_prog_type_list
Date: Tue,  4 Apr 2017 19:27:10 +0200
Message-ID: <20170404172711.4088-1-johannes@sipsolutions.net>
Cc: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:37814 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754453AbdDDR1V (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Apr 2017 13:27:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

There's no need to have struct bpf_prog_type_list since
it just contains a list_head, the type, and the ops
pointer. Since the types are densely packed and not
actually dynamically registered, it's much easier and
smaller to have an array of type->ops pointer.

This doesn't really change the image size much, but in
the running image it saves a few hundred bytes because
the structs are removed and traded against __init code.

While at it, also mark bpf_register_prog_type() __init
since it's only called from code already marked so.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
So I'm not sure about this - I looked at this code since
I wanted to see if we could even register prog_types from
modules, but that seems to be impossible right now ...
---
 include/linux/bpf.h      | 12 +++------
 include/uapi/linux/bpf.h |  2 ++
 kernel/bpf/syscall.c     | 26 ++++++++++----------
 kernel/trace/bpf_trace.c | 21 +++-------------
 net/core/filter.c        | 63 +++++++-----------------------------------------
 5 files changed, 31 insertions(+), 93 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 909fc033173a..891a76aaccaa 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -169,12 +169,6 @@ struct bpf_verifier_ops {
 				  struct bpf_prog *prog);
 };
 
-struct bpf_prog_type_list {
-	struct list_head list_node;
-	const struct bpf_verifier_ops *ops;
-	enum bpf_prog_type type;
-};
-
 struct bpf_prog_aux {
 	atomic_t refcnt;
 	u32 used_map_cnt;
@@ -234,7 +228,8 @@ u64 bpf_event_output(struct bpf_map *map, u64 flags, void *meta, u64 meta_size,
 #ifdef CONFIG_BPF_SYSCALL
 DECLARE_PER_CPU(int, bpf_prog_active);
 
-void bpf_register_prog_type(struct bpf_prog_type_list *tl);
+void bpf_register_prog_type(enum bpf_prog_type type,
+			    const struct bpf_verifier_ops *ops);
 void bpf_register_map_type(struct bpf_map_type_list *tl);
 
 struct bpf_prog *bpf_prog_get(u32 ufd);
@@ -295,7 +290,8 @@ static inline void bpf_long_memcpy(void *dst, const void *src, u32 size)
 /* verify correctness of eBPF program */
 int bpf_check(struct bpf_prog **fp, union bpf_attr *attr);
 #else
-static inline void bpf_register_prog_type(struct bpf_prog_type_list *tl)
+static inline void bpf_register_prog_type(enum bpf_prog_type type,
+					  const struct bpf_verifier_ops *ops)
 {
 }
 
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 0539a0ceef38..cc68f5bbf458 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -112,6 +112,8 @@ enum bpf_prog_type {
 	BPF_PROG_TYPE_LWT_IN,
 	BPF_PROG_TYPE_LWT_OUT,
 	BPF_PROG_TYPE_LWT_XMIT,
+
+	NUM_BPF_PROG_TYPES,
 };
 
 enum bpf_attach_type {
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 7af0dcc5d755..1156eccf36a5 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -564,26 +564,26 @@ static int map_get_next_key(union bpf_attr *attr)
 	return err;
 }
 
-static LIST_HEAD(bpf_prog_types);
+static const struct bpf_verifier_ops *
+bpf_prog_types[NUM_BPF_PROG_TYPES] __ro_after_init;
 
 static int find_prog_type(enum bpf_prog_type type, struct bpf_prog *prog)
 {
-	struct bpf_prog_type_list *tl;
-
-	list_for_each_entry(tl, &bpf_prog_types, list_node) {
-		if (tl->type == type) {
-			prog->aux->ops = tl->ops;
-			prog->type = type;
-			return 0;
-		}
-	}
+	if (type >= NUM_BPF_PROG_TYPES || !bpf_prog_types[type])
+		return -EINVAL;
 
-	return -EINVAL;
+	prog->aux->ops = bpf_prog_types[type];
+	prog->type = type;
+	return 0;
 }
 
-void bpf_register_prog_type(struct bpf_prog_type_list *tl)
+void __init bpf_register_prog_type(enum bpf_prog_type type,
+				   const struct bpf_verifier_ops *ops)
 {
-	list_add(&tl->list_node, &bpf_prog_types);
+	if (WARN_ON(bpf_prog_types[type]))
+		return;
+
+	bpf_prog_types[type] = ops;
 }
 
 /* fixup insn->imm field of bpf_call instructions:
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index cee9802cf3e0..1e45e1cd0174 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -506,11 +506,6 @@ static const struct bpf_verifier_ops kprobe_prog_ops = {
 	.is_valid_access = kprobe_prog_is_valid_access,
 };
 
-static struct bpf_prog_type_list kprobe_tl __ro_after_init = {
-	.ops	= &kprobe_prog_ops,
-	.type	= BPF_PROG_TYPE_KPROBE,
-};
-
 BPF_CALL_5(bpf_perf_event_output_tp, void *, tp_buff, struct bpf_map *, map,
 	   u64, flags, void *, data, u64, size)
 {
@@ -589,11 +584,6 @@ static const struct bpf_verifier_ops tracepoint_prog_ops = {
 	.is_valid_access = tp_prog_is_valid_access,
 };
 
-static struct bpf_prog_type_list tracepoint_tl __ro_after_init = {
-	.ops	= &tracepoint_prog_ops,
-	.type	= BPF_PROG_TYPE_TRACEPOINT,
-};
-
 static bool pe_prog_is_valid_access(int off, int size, enum bpf_access_type type,
 				    enum bpf_reg_type *reg_type)
 {
@@ -648,16 +638,11 @@ static const struct bpf_verifier_ops perf_event_prog_ops = {
 	.convert_ctx_access	= pe_prog_convert_ctx_access,
 };
 
-static struct bpf_prog_type_list perf_event_tl __ro_after_init = {
-	.ops	= &perf_event_prog_ops,
-	.type	= BPF_PROG_TYPE_PERF_EVENT,
-};
-
 static int __init register_kprobe_prog_ops(void)
 {
-	bpf_register_prog_type(&kprobe_tl);
-	bpf_register_prog_type(&tracepoint_tl);
-	bpf_register_prog_type(&perf_event_tl);
+	bpf_register_prog_type(BPF_PROG_TYPE_KPROBE, &kprobe_prog_ops);
+	bpf_register_prog_type(BPF_PROG_TYPE_TRACEPOINT, &tracepoint_prog_ops);
+	bpf_register_prog_type(BPF_PROG_TYPE_PERF_EVENT, &perf_event_prog_ops);
 	return 0;
 }
 late_initcall(register_kprobe_prog_ops);
diff --git a/net/core/filter.c b/net/core/filter.c
index ebaeaf2e46e8..d5218c891d43 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -3296,62 +3296,17 @@ static const struct bpf_verifier_ops cg_sock_ops = {
 	.convert_ctx_access	= sock_filter_convert_ctx_access,
 };
 
-static struct bpf_prog_type_list sk_filter_type __ro_after_init = {
-	.ops	= &sk_filter_ops,
-	.type	= BPF_PROG_TYPE_SOCKET_FILTER,
-};
-
-static struct bpf_prog_type_list sched_cls_type __ro_after_init = {
-	.ops	= &tc_cls_act_ops,
-	.type	= BPF_PROG_TYPE_SCHED_CLS,
-};
-
-static struct bpf_prog_type_list sched_act_type __ro_after_init = {
-	.ops	= &tc_cls_act_ops,
-	.type	= BPF_PROG_TYPE_SCHED_ACT,
-};
-
-static struct bpf_prog_type_list xdp_type __ro_after_init = {
-	.ops	= &xdp_ops,
-	.type	= BPF_PROG_TYPE_XDP,
-};
-
-static struct bpf_prog_type_list cg_skb_type __ro_after_init = {
-	.ops	= &cg_skb_ops,
-	.type	= BPF_PROG_TYPE_CGROUP_SKB,
-};
-
-static struct bpf_prog_type_list lwt_in_type __ro_after_init = {
-	.ops	= &lwt_inout_ops,
-	.type	= BPF_PROG_TYPE_LWT_IN,
-};
-
-static struct bpf_prog_type_list lwt_out_type __ro_after_init = {
-	.ops	= &lwt_inout_ops,
-	.type	= BPF_PROG_TYPE_LWT_OUT,
-};
-
-static struct bpf_prog_type_list lwt_xmit_type __ro_after_init = {
-	.ops	= &lwt_xmit_ops,
-	.type	= BPF_PROG_TYPE_LWT_XMIT,
-};
-
-static struct bpf_prog_type_list cg_sock_type __ro_after_init = {
-	.ops	= &cg_sock_ops,
-	.type	= BPF_PROG_TYPE_CGROUP_SOCK
-};
-
 static int __init register_sk_filter_ops(void)
 {
-	bpf_register_prog_type(&sk_filter_type);
-	bpf_register_prog_type(&sched_cls_type);
-	bpf_register_prog_type(&sched_act_type);
-	bpf_register_prog_type(&xdp_type);
-	bpf_register_prog_type(&cg_skb_type);
-	bpf_register_prog_type(&cg_sock_type);
-	bpf_register_prog_type(&lwt_in_type);
-	bpf_register_prog_type(&lwt_out_type);
-	bpf_register_prog_type(&lwt_xmit_type);
+	bpf_register_prog_type(BPF_PROG_TYPE_SOCKET_FILTER, &sk_filter_ops);
+	bpf_register_prog_type(BPF_PROG_TYPE_SCHED_CLS, &tc_cls_act_ops);
+	bpf_register_prog_type(BPF_PROG_TYPE_SCHED_ACT, &tc_cls_act_ops);
+	bpf_register_prog_type(BPF_PROG_TYPE_XDP, &xdp_ops);
+	bpf_register_prog_type(BPF_PROG_TYPE_CGROUP_SKB, &cg_skb_ops);
+	bpf_register_prog_type(BPF_PROG_TYPE_CGROUP_SOCK, &cg_sock_ops);
+	bpf_register_prog_type(BPF_PROG_TYPE_LWT_IN, &lwt_inout_ops);
+	bpf_register_prog_type(BPF_PROG_TYPE_LWT_OUT, &lwt_inout_ops);
+	bpf_register_prog_type(BPF_PROG_TYPE_LWT_XMIT, &lwt_xmit_ops);
 
 	return 0;
 }
-- 
2.11.0
