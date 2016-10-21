From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2 1/2] bpf: add helper for retrieving current numa node id
Date: Fri, 21 Oct 2016 12:46:33 +0200
Message-ID: <46dd208fee014c0837d750ffa13e625c6f4ee53c.1477043972.git.daniel@iogearbox.net>
References: <cover.1477043972.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, edumazet@google.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33306 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753751AbcJUKqo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 06:46:44 -0400
In-Reply-To: <cover.1477043972.git.daniel@iogearbox.net>
In-Reply-To: <cover.1477043972.git.daniel@iogearbox.net>
References: <cover.1477043972.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use case is mainly for soreuseport to select sockets for the local
numa node, but since generic, lets also add this for other networking
and tracing program types.

Suggested-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/bpf.h      |  1 +
 include/uapi/linux/bpf.h |  6 ++++++
 kernel/bpf/core.c        |  1 +
 kernel/bpf/helpers.c     | 12 ++++++++++++
 kernel/trace/bpf_trace.c |  2 ++
 net/core/filter.c        |  2 ++
 6 files changed, 24 insertions(+)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index c201017..edcd96d 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -319,6 +319,7 @@ static inline struct bpf_prog *bpf_prog_inc(struct bpf_prog *prog)
 
 extern const struct bpf_func_proto bpf_get_prandom_u32_proto;
 extern const struct bpf_func_proto bpf_get_smp_processor_id_proto;
+extern const struct bpf_func_proto bpf_get_numa_node_id_proto;
 extern const struct bpf_func_proto bpf_tail_call_proto;
 extern const struct bpf_func_proto bpf_ktime_get_ns_proto;
 extern const struct bpf_func_proto bpf_get_current_pid_tgid_proto;
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index f09c70b..374ef58 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -426,6 +426,12 @@ enum bpf_func_id {
 	 */
 	BPF_FUNC_set_hash_invalid,
 
+	/**
+	 * bpf_get_numa_node_id()
+	 * Returns the id of the current NUMA node.
+	 */
+	BPF_FUNC_get_numa_node_id,
+
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index aa6d981..82a0414 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -1043,6 +1043,7 @@ void bpf_user_rnd_init_once(void)
 
 const struct bpf_func_proto bpf_get_prandom_u32_proto __weak;
 const struct bpf_func_proto bpf_get_smp_processor_id_proto __weak;
+const struct bpf_func_proto bpf_get_numa_node_id_proto __weak;
 const struct bpf_func_proto bpf_ktime_get_ns_proto __weak;
 
 const struct bpf_func_proto bpf_get_current_pid_tgid_proto __weak;
diff --git a/kernel/bpf/helpers.c b/kernel/bpf/helpers.c
index 3991840..045cbe6 100644
--- a/kernel/bpf/helpers.c
+++ b/kernel/bpf/helpers.c
@@ -13,6 +13,7 @@
 #include <linux/rcupdate.h>
 #include <linux/random.h>
 #include <linux/smp.h>
+#include <linux/topology.h>
 #include <linux/ktime.h>
 #include <linux/sched.h>
 #include <linux/uidgid.h>
@@ -92,6 +93,17 @@
 	.ret_type	= RET_INTEGER,
 };
 
+BPF_CALL_0(bpf_get_numa_node_id)
+{
+	return numa_node_id();
+}
+
+const struct bpf_func_proto bpf_get_numa_node_id_proto = {
+	.func		= bpf_get_numa_node_id,
+	.gpl_only	= false,
+	.ret_type	= RET_INTEGER,
+};
+
 BPF_CALL_0(bpf_ktime_get_ns)
 {
 	/* NMI safe access to clock monotonic */
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 5dcb992..fa77311 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -422,6 +422,8 @@ static const struct bpf_func_proto *tracing_func_proto(enum bpf_func_id func_id)
 		return bpf_get_trace_printk_proto();
 	case BPF_FUNC_get_smp_processor_id:
 		return &bpf_get_smp_processor_id_proto;
+	case BPF_FUNC_get_numa_node_id:
+		return &bpf_get_numa_node_id_proto;
 	case BPF_FUNC_perf_event_read:
 		return &bpf_perf_event_read_proto;
 	case BPF_FUNC_probe_write_user:
diff --git a/net/core/filter.c b/net/core/filter.c
index 00351cd..cd9e2ba 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2492,6 +2492,8 @@ static unsigned long bpf_xdp_copy(void *dst_buff, const void *src_buff,
 		return &bpf_get_prandom_u32_proto;
 	case BPF_FUNC_get_smp_processor_id:
 		return &bpf_get_raw_smp_processor_id_proto;
+	case BPF_FUNC_get_numa_node_id:
+		return &bpf_get_numa_node_id_proto;
 	case BPF_FUNC_tail_call:
 		return &bpf_tail_call_proto;
 	case BPF_FUNC_ktime_get_ns:
-- 
1.9.3
