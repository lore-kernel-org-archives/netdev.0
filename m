From: Sargun Dhillon <sargun@sargun.me>
Subject: [net-next 1/2] bpf: Add bpf_current_in_cgroup helper
Date: Sat, 6 Aug 2016 21:07:03 -0700
Message-ID: <20160807040702.GA9279@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f45.google.com ([209.85.214.45]:37927 "EHLO
	mail-it0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751029AbcHGEHH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Aug 2016 00:07:07 -0400
Received: by mail-it0-f45.google.com with SMTP id j124so56949197ith.1
        for <netdev@vger.kernel.org>; Sat, 06 Aug 2016 21:07:06 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds a kprobe helper that's similar to the skb_in_cgroup helper. It
checks whether the probe is currently executing in the context of the
cgroup at the given index a CGROUP_ARRAY.

Signed-off-by: Sargun Dhillon <sargun@sargun.me>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/bpf.h      | 24 ++++++++++++++++++++++++
 include/uapi/linux/bpf.h | 11 +++++++++++
 kernel/bpf/arraymap.c    |  2 +-
 kernel/bpf/verifier.c    |  4 +++-
 kernel/trace/bpf_trace.c | 34 ++++++++++++++++++++++++++++++++++
 net/core/filter.c        | 11 ++++-------
 6 files changed, 77 insertions(+), 9 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 1113423..9adf712 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -319,4 +319,28 @@ extern const struct bpf_func_proto bpf_get_stackid_proto;
 void bpf_user_rnd_init_once(void);
 u64 bpf_user_rnd_u32(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
 
+#ifdef CONFIG_CGROUPS
+/* Helper to fetch a cgroup pointer based on index.
+ * @map: a cgroup arraymap
+ * @idx: index of the item you want to fetch
+ *
+ * Returns pointer on success,
+ * Error code if item not found, or out-of-bounds access
+ */
+static inline struct cgroup *fetch_arraymap_ptr(struct bpf_map *map, int idx)
+{
+	struct cgroup *cgrp;
+	struct bpf_array *array = container_of(map, struct bpf_array, map);
+
+	if (unlikely(idx >= array->map.max_entries))
+		return ERR_PTR(-E2BIG);
+
+	cgrp = READ_ONCE(array->ptrs[idx]);
+	if (unlikely(!cgrp))
+		return ERR_PTR(-EAGAIN);
+
+	return cgrp;
+}
+#endif /* CONFIG_CGROUPS */
+
 #endif /* _LINUX_BPF_H */
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index da218fe..23a5b99 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -375,6 +375,17 @@ enum bpf_func_id {
 	 */
 	BPF_FUNC_probe_write_user,
 
+	/**
+	 * bpf_current_in_cgroup(map, index) - Check cgroup2 membership of skb
+	 * @map: pointer to bpf_map in BPF_MAP_TYPE_CGROUP_ARRAY type
+	 * @index: index of the cgroup in the bpf_map
+	 * Return:
+	 *   == 0 current failed the cgroup2 descendant test
+	 *   == 1 current succeeded the cgroup2 descendant test
+	 *    < 0 error
+	 */
+	BPF_FUNC_current_in_cgroup,
+
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index 633a650..a2ac051 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -538,7 +538,7 @@ static int __init register_perf_event_array_map(void)
 }
 late_initcall(register_perf_event_array_map);
 
-#ifdef CONFIG_SOCK_CGROUP_DATA
+#ifdef CONFIG_CGROUPS
 static void *cgroup_fd_array_get_ptr(struct bpf_map *map,
 				     struct file *map_file /* not used */,
 				     int fd)
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index f72f23b..e16559b 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1052,7 +1052,8 @@ static int check_map_func_compatibility(struct bpf_map *map, int func_id)
 			goto error;
 		break;
 	case BPF_MAP_TYPE_CGROUP_ARRAY:
-		if (func_id != BPF_FUNC_skb_in_cgroup)
+		if (func_id != BPF_FUNC_skb_in_cgroup &&
+		    func_id != BPF_FUNC_current_in_cgroup)
 			goto error;
 		break;
 	default:
@@ -1074,6 +1075,7 @@ static int check_map_func_compatibility(struct bpf_map *map, int func_id)
 		if (map->map_type != BPF_MAP_TYPE_STACK_TRACE)
 			goto error;
 		break;
+	case BPF_FUNC_current_in_cgroup:
 	case BPF_FUNC_skb_in_cgroup:
 		if (map->map_type != BPF_MAP_TYPE_CGROUP_ARRAY)
 			goto error;
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index b20438f..f2a6bc5 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -376,6 +376,36 @@ static const struct bpf_func_proto bpf_get_current_task_proto = {
 	.ret_type	= RET_INTEGER,
 };
 
+#ifdef CONFIG_CGROUPS
+static u64 bpf_current_in_cgroup(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	struct bpf_map *map = (struct bpf_map *)(long)r1;
+	struct css_set *cset;
+	struct cgroup *cgrp;
+	u32 idx = (u32)r2;
+
+	if (unlikely(in_interrupt()))
+		return -EINVAL;
+
+	cgrp = fetch_arraymap_ptr(map, idx);
+
+	if (unlikely(IS_ERR(cgrp)))
+		return PTR_ERR(cgrp);
+
+	cset = task_css_set(current);
+
+	return cgroup_is_descendant(cset->dfl_cgrp, cgrp);
+}
+
+static const struct bpf_func_proto bpf_current_in_cgroup_proto = {
+	.func           = bpf_current_in_cgroup,
+	.gpl_only       = false,
+	.ret_type       = RET_INTEGER,
+	.arg1_type      = ARG_CONST_MAP_PTR,
+	.arg2_type      = ARG_ANYTHING,
+};
+#endif /* CONFIG_CGROUPS */
+
 static const struct bpf_func_proto *tracing_func_proto(enum bpf_func_id func_id)
 {
 	switch (func_id) {
@@ -407,6 +437,10 @@ static const struct bpf_func_proto *tracing_func_proto(enum bpf_func_id func_id)
 		return &bpf_perf_event_read_proto;
 	case BPF_FUNC_probe_write_user:
 		return bpf_get_probe_write_proto();
+#ifdef CONFIG_CGROUPS
+	case BPF_FUNC_current_in_cgroup:
+		return &bpf_current_in_cgroup_proto;
+#endif
 	default:
 		return NULL;
 	}
diff --git a/net/core/filter.c b/net/core/filter.c
index 5708999..922fdb4 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2302,21 +2302,18 @@ static u64 bpf_skb_in_cgroup(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 {
 	struct sk_buff *skb = (struct sk_buff *)(long)r1;
 	struct bpf_map *map = (struct bpf_map *)(long)r2;
-	struct bpf_array *array = container_of(map, struct bpf_array, map);
 	struct cgroup *cgrp;
 	struct sock *sk;
-	u32 i = (u32)r3;
+	u32 idx = (u32)r3;
 
 	sk = skb->sk;
 	if (!sk || !sk_fullsock(sk))
 		return -ENOENT;
 
-	if (unlikely(i >= array->map.max_entries))
-		return -E2BIG;
+	cgrp = fetch_arraymap_ptr(map, idx);
 
-	cgrp = READ_ONCE(array->ptrs[i]);
-	if (unlikely(!cgrp))
-		return -EAGAIN;
+	if (unlikely(IS_ERR(cgrp)))
+		return PTR_ERR(cgrp);
 
 	return cgroup_is_descendant(sock_cgroup_ptr(&sk->sk_cgrp_data), cgrp);
 }
-- 
2.7.4
