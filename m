From: Sargun Dhillon <sargun@sargun.me>
Subject: [net-next RFC v2 3/9] bpf: move tracing helpers (probe_read,
 get_current_task) to shared helpers
Date: Mon, 29 Aug 2016 04:46:21 -0700
Message-ID: <20160829114620.GA20854@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cgroups@vger.kernel.org, linux-security-module@vger.kernel.org,
        daniel@iogearbox.net, ast@fb.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f45.google.com ([209.85.214.45]:34890 "EHLO
        mail-it0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932868AbcH2LqY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 07:46:24 -0400
Received: by mail-it0-f45.google.com with SMTP id x131so97784125ite.0
        for <netdev@vger.kernel.org>; Mon, 29 Aug 2016 04:46:23 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch moves bpf_probe_read and bpf_get_current_task to be the shared
cgroup infrastructure. These are useful outside of the context of just
tracing, but also inspection of a process memory during security
policy enforcement.

Signed-off-by: Sargun Dhillon <sargun@sargun.me>
---
 include/linux/bpf.h      |  2 ++
 kernel/bpf/helpers.c     | 34 ++++++++++++++++++++++++++++++++++
 kernel/trace/bpf_trace.c | 33 ---------------------------------
 3 files changed, 36 insertions(+), 33 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 1113423..4e1fa57 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -314,6 +314,8 @@ extern const struct bpf_func_proto bpf_get_current_comm_proto;
 extern const struct bpf_func_proto bpf_skb_vlan_push_proto;
 extern const struct bpf_func_proto bpf_skb_vlan_pop_proto;
 extern const struct bpf_func_proto bpf_get_stackid_proto;
+extern const struct bpf_func_proto bpf_get_current_task_proto;
+extern const struct bpf_func_proto bpf_probe_read_proto;
 
 /* Shared helpers among cBPF and eBPF. */
 void bpf_user_rnd_init_once(void);
diff --git a/kernel/bpf/helpers.c b/kernel/bpf/helpers.c
index 1ea3afb..c439afc 100644
--- a/kernel/bpf/helpers.c
+++ b/kernel/bpf/helpers.c
@@ -16,6 +16,7 @@
 #include <linux/ktime.h>
 #include <linux/sched.h>
 #include <linux/uidgid.h>
+#include <linux/uaccess.h>
 
 /* If kernel subsystem is allowing eBPF programs to call this function,
  * inside its own verifier_ops->get_func_proto() callback it should return
@@ -186,3 +187,36 @@ const struct bpf_func_proto bpf_get_current_comm_proto = {
 	.arg1_type	= ARG_PTR_TO_RAW_STACK,
 	.arg2_type	= ARG_CONST_STACK_SIZE,
 };
+
+static u64 bpf_get_current_task(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	return (long) current;
+}
+
+const struct bpf_func_proto bpf_get_current_task_proto = {
+	.func           = bpf_get_current_task,
+	.gpl_only       = true,
+	.ret_type       = RET_INTEGER,
+};
+
+static u64 bpf_probe_read(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	void *dst = (void *) (long) r1;
+	int ret, size = (int) r2;
+	void *unsafe_ptr = (void *) (long) r3;
+
+	ret = probe_kernel_read(dst, unsafe_ptr, size);
+	if (unlikely(ret < 0))
+		memset(dst, 0, size);
+
+	return ret;
+}
+
+const struct bpf_func_proto bpf_probe_read_proto = {
+	.func		= bpf_probe_read,
+	.gpl_only	= true,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_PTR_TO_RAW_STACK,
+	.arg2_type	= ARG_CONST_STACK_SIZE,
+	.arg3_type	= ARG_ANYTHING,
+};
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index ad35213..cb96eda 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -59,28 +59,6 @@ unsigned int trace_call_bpf(struct bpf_prog *prog, void *ctx)
 }
 EXPORT_SYMBOL_GPL(trace_call_bpf);
 
-static u64 bpf_probe_read(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
-{
-	void *dst = (void *) (long) r1;
-	int ret, size = (int) r2;
-	void *unsafe_ptr = (void *) (long) r3;
-
-	ret = probe_kernel_read(dst, unsafe_ptr, size);
-	if (unlikely(ret < 0))
-		memset(dst, 0, size);
-
-	return ret;
-}
-
-static const struct bpf_func_proto bpf_probe_read_proto = {
-	.func		= bpf_probe_read,
-	.gpl_only	= true,
-	.ret_type	= RET_INTEGER,
-	.arg1_type	= ARG_PTR_TO_RAW_STACK,
-	.arg2_type	= ARG_CONST_STACK_SIZE,
-	.arg3_type	= ARG_ANYTHING,
-};
-
 static u64 bpf_probe_write_user(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 {
 	void *unsafe_ptr = (void *) (long) r1;
@@ -365,17 +343,6 @@ u64 bpf_event_output(struct bpf_map *map, u64 flags, void *meta, u64 meta_size,
 	return __bpf_perf_event_output(regs, map, flags, &raw);
 }
 
-static u64 bpf_get_current_task(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
-{
-	return (long) current;
-}
-
-static const struct bpf_func_proto bpf_get_current_task_proto = {
-	.func		= bpf_get_current_task,
-	.gpl_only	= true,
-	.ret_type	= RET_INTEGER,
-};
-
 static u64 bpf_current_task_under_cgroup(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 {
 	struct bpf_map *map = (struct bpf_map *)(long)r1;
-- 
2.7.4
