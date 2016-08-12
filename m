From: Sargun Dhillon <sargun@sargun.me>
Subject: [PATCH net-next v5 2/3] bpf: Add bpf_current_task_under_cgroup helper
Date: Fri, 12 Aug 2016 08:56:52 -0700
Message-ID: <20160812155650.GA12886@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net, tj@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:32924 "EHLO
	mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752723AbcHLP4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 11:56:55 -0400
Received: by mail-io0-f173.google.com with SMTP id 38so28532368iol.0
        for <netdev@vger.kernel.org>; Fri, 12 Aug 2016 08:56:54 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds a bpf helper that's similar to the skb_in_cgroup helper to check
whether the probe is currently executing in the context of a specific
subset of the cgroupsv2 hierarchy. It does this based on membership test
for a cgroup arraymap. It is invalid to call this in an interrupt, and
it'll return an error. The helper is primarily to be used in debugging
activities for containers, where you may have multiple programs running in
a given top-level "container".

Signed-off-by: Sargun Dhillon <sargun@sargun.me>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Tejun Heo <tj@kernel.org>
Acked-by: Tejun Heo <tj@kernel.org>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/uapi/linux/bpf.h | 11 +++++++++++
 kernel/bpf/arraymap.c    |  2 +-
 kernel/bpf/verifier.c    |  4 +++-
 kernel/trace/bpf_trace.c | 30 ++++++++++++++++++++++++++++++
 4 files changed, 45 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index da218fe..bea0c4e 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -375,6 +375,17 @@ enum bpf_func_id {
 	 */
 	BPF_FUNC_probe_write_user,
 
+	/**
+	 * bpf_current_task_under_cgroup(map, index) - Check cgroup2 membership of current task
+	 * @map: pointer to bpf_map in BPF_MAP_TYPE_CGROUP_ARRAY type
+	 * @index: index of the cgroup in the bpf_map
+	 * Return:
+	 *   == 0 current failed the cgroup2 descendant test
+	 *   == 1 current succeeded the cgroup2 descendant test
+	 *    < 0 error
+	 */
+	BPF_FUNC_current_task_under_cgroup,
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
index 7094c69..d504722 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1053,7 +1053,8 @@ static int check_map_func_compatibility(struct bpf_map *map, int func_id)
 			goto error;
 		break;
 	case BPF_MAP_TYPE_CGROUP_ARRAY:
-		if (func_id != BPF_FUNC_skb_in_cgroup)
+		if (func_id != BPF_FUNC_skb_in_cgroup &&
+		    func_id != BPF_FUNC_current_task_under_cgroup)
 			goto error;
 		break;
 	default:
@@ -1075,6 +1076,7 @@ static int check_map_func_compatibility(struct bpf_map *map, int func_id)
 		if (map->map_type != BPF_MAP_TYPE_STACK_TRACE)
 			goto error;
 		break;
+	case BPF_FUNC_current_task_under_cgroup:
 	case BPF_FUNC_skb_in_cgroup:
 		if (map->map_type != BPF_MAP_TYPE_CGROUP_ARRAY)
 			goto error;
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index b20438f..6b794d6 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -376,6 +376,34 @@ static const struct bpf_func_proto bpf_get_current_task_proto = {
 	.ret_type	= RET_INTEGER,
 };
 
+static u64 bpf_current_task_under_cgroup(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	struct bpf_map *map = (struct bpf_map *)(long)r1;
+	struct bpf_array *array = container_of(map, struct bpf_array, map);
+	struct cgroup *cgrp;
+	u32 idx = (u32)r2;
+
+	if (unlikely(in_interrupt()))
+		return -EINVAL;
+
+	if (unlikely(idx >= array->map.max_entries))
+		return -E2BIG;
+
+	cgrp = READ_ONCE(array->ptrs[idx]);
+	if (unlikely(!cgrp))
+		return -EAGAIN;
+
+	return task_under_cgroup_hierarchy(current, cgrp);
+}
+
+static const struct bpf_func_proto bpf_current_task_under_cgroup_proto = {
+	.func           = bpf_current_task_under_cgroup,
+	.gpl_only       = false,
+	.ret_type       = RET_INTEGER,
+	.arg1_type      = ARG_CONST_MAP_PTR,
+	.arg2_type      = ARG_ANYTHING,
+};
+
 static const struct bpf_func_proto *tracing_func_proto(enum bpf_func_id func_id)
 {
 	switch (func_id) {
@@ -407,6 +435,8 @@ static const struct bpf_func_proto *tracing_func_proto(enum bpf_func_id func_id)
 		return &bpf_perf_event_read_proto;
 	case BPF_FUNC_probe_write_user:
 		return bpf_get_probe_write_proto();
+	case BPF_FUNC_current_task_under_cgroup:
+		return &bpf_current_task_under_cgroup_proto;
 	default:
 		return NULL;
 	}
-- 
2.7.4
