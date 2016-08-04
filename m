From: Sargun Dhillon <sargun@sargun.me>
Subject: [RFC 1/4] bpf: move tracing helpers to shared helpers
Date: Thu, 4 Aug 2016 00:11:30 -0700
Message-ID: <20160804071128.GA19115@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net,
	linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move bpf_probe_read and bpf_get_current_task to the shared helpers
so that Checmate can use them.

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
index b20438f..f7a107b 100644
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
 static const struct bpf_func_proto *tracing_func_proto(enum bpf_func_id func_id)
 {
 	switch (func_id) {
-- 
2.7.4
