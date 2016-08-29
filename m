From: Sargun Dhillon <sargun@sargun.me>
Subject: [net-next RFC v2 6/9] bpf: Share current_task_under_cgroup helper
 and expose to Checmate programs
Date: Mon, 29 Aug 2016 04:47:25 -0700
Message-ID: <20160829114723.GA20889@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cgroups@vger.kernel.org, linux-security-module@vger.kernel.org,
        daniel@iogearbox.net, ast@fb.com
To: netdev@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch exposes the current_task_under_cgroup helper to Checmate
programs. It can be used to implement exemptions for certain policies
when using Checmate programs by wrapping a pre-compiled policy
in a tail call along with this helper.

Signed-off-by: Sargun Dhillon <sargun@sargun.me>
---
 include/linux/bpf.h              |  1 +
 kernel/bpf/helpers.c             | 29 +++++++++++++++++++++++++++++
 kernel/trace/bpf_trace.c         | 28 ----------------------------
 security/checmate/checmate_bpf.c |  2 ++
 4 files changed, 32 insertions(+), 28 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 4e1fa57..5c5ed16 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -316,6 +316,7 @@ extern const struct bpf_func_proto bpf_skb_vlan_pop_proto;
 extern const struct bpf_func_proto bpf_get_stackid_proto;
 extern const struct bpf_func_proto bpf_get_current_task_proto;
 extern const struct bpf_func_proto bpf_probe_read_proto;
+extern const struct bpf_func_proto bpf_current_task_under_cgroup_proto;
 
 /* Shared helpers among cBPF and eBPF. */
 void bpf_user_rnd_init_once(void);
diff --git a/kernel/bpf/helpers.c b/kernel/bpf/helpers.c
index c439afc..ffaaa4b 100644
--- a/kernel/bpf/helpers.c
+++ b/kernel/bpf/helpers.c
@@ -17,6 +17,7 @@
 #include <linux/sched.h>
 #include <linux/uidgid.h>
 #include <linux/uaccess.h>
+#include <linux/cgroup.h>
 
 /* If kernel subsystem is allowing eBPF programs to call this function,
  * inside its own verifier_ops->get_func_proto() callback it should return
@@ -212,6 +213,34 @@ static u64 bpf_probe_read(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 	return ret;
 }
 
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
+const struct bpf_func_proto bpf_current_task_under_cgroup_proto = {
+	.func           = bpf_current_task_under_cgroup,
+	.gpl_only       = false,
+	.ret_type       = RET_INTEGER,
+	.arg1_type      = ARG_CONST_MAP_PTR,
+	.arg2_type      = ARG_ANYTHING,
+};
+
 const struct bpf_func_proto bpf_probe_read_proto = {
 	.func		= bpf_probe_read,
 	.gpl_only	= true,
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index cb96eda..3725df2 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -343,34 +343,6 @@ u64 bpf_event_output(struct bpf_map *map, u64 flags, void *meta, u64 meta_size,
 	return __bpf_perf_event_output(regs, map, flags, &raw);
 }
 
-static u64 bpf_current_task_under_cgroup(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
-{
-	struct bpf_map *map = (struct bpf_map *)(long)r1;
-	struct bpf_array *array = container_of(map, struct bpf_array, map);
-	struct cgroup *cgrp;
-	u32 idx = (u32)r2;
-
-	if (unlikely(in_interrupt()))
-		return -EINVAL;
-
-	if (unlikely(idx >= array->map.max_entries))
-		return -E2BIG;
-
-	cgrp = READ_ONCE(array->ptrs[idx]);
-	if (unlikely(!cgrp))
-		return -EAGAIN;
-
-	return task_under_cgroup_hierarchy(current, cgrp);
-}
-
-static const struct bpf_func_proto bpf_current_task_under_cgroup_proto = {
-	.func           = bpf_current_task_under_cgroup,
-	.gpl_only       = false,
-	.ret_type       = RET_INTEGER,
-	.arg1_type      = ARG_CONST_MAP_PTR,
-	.arg2_type      = ARG_ANYTHING,
-};
-
 static const struct bpf_func_proto *tracing_func_proto(enum bpf_func_id func_id)
 {
 	switch (func_id) {
diff --git a/security/checmate/checmate_bpf.c b/security/checmate/checmate_bpf.c
index 24d6935..37ea609 100644
--- a/security/checmate/checmate_bpf.c
+++ b/security/checmate/checmate_bpf.c
@@ -91,6 +91,8 @@ checmate_prog_func_proto(enum bpf_func_id func_id)
 		return &bpf_probe_write_user_proto;
 	case BPF_FUNC_trace_printk:
 		return bpf_get_trace_printk_proto();
+	case BPF_FUNC_current_task_under_cgroup:
+		return &bpf_current_task_under_cgroup_proto;
 	default:
 		return NULL;
 	}
-- 
2.7.4

