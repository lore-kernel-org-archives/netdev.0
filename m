From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 1/2] ebpf: allow bpf_ktime_get_ns_proto also for networking
Date: Fri, 29 May 2015 23:23:06 +0200
Message-ID: <e37891545f298ab82d1bd7b62c16ff8f3f166534.1432912637.git.daniel@iogearbox.net>
References: <cover.1432912637.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Ingo Molnar <mingo@kernel.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39924 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030241AbbE2VXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 17:23:13 -0400
In-Reply-To: <cover.1432912637.git.daniel@iogearbox.net>
In-Reply-To: <cover.1432912637.git.daniel@iogearbox.net>
References: <cover.1432912637.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As this is already exported from tracing side via commit d9847d310ab4
("tracing: Allow BPF programs to call bpf_ktime_get_ns()"), we might
as well want to move it to the core, so also networking users can make
use of it, e.g. to measure diffs for certain flows from ingress/egress.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>
---
 include/linux/bpf.h      |  1 +
 kernel/bpf/core.c        |  1 +
 kernel/bpf/helpers.c     | 13 +++++++++++++
 kernel/trace/bpf_trace.c | 12 ------------
 net/core/filter.c        |  2 ++
 5 files changed, 17 insertions(+), 12 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 8821b9a..0fb0e72 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -182,5 +182,6 @@ extern const struct bpf_func_proto bpf_map_delete_elem_proto;
 extern const struct bpf_func_proto bpf_get_prandom_u32_proto;
 extern const struct bpf_func_proto bpf_get_smp_processor_id_proto;
 extern const struct bpf_func_proto bpf_tail_call_proto;
+extern const struct bpf_func_proto bpf_ktime_get_ns_proto;
 
 #endif /* _LINUX_BPF_H */
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index d44b25c..4548422 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -734,6 +734,7 @@ const struct bpf_func_proto bpf_map_delete_elem_proto __weak;
 
 const struct bpf_func_proto bpf_get_prandom_u32_proto __weak;
 const struct bpf_func_proto bpf_get_smp_processor_id_proto __weak;
+const struct bpf_func_proto bpf_ktime_get_ns_proto __weak;
 
 /* To execute LD_ABS/LD_IND instructions __bpf_prog_run() may call
  * skb_copy_bits(), so provide a weak definition of it for NET-less config.
diff --git a/kernel/bpf/helpers.c b/kernel/bpf/helpers.c
index bd7f598..b3aaabd 100644
--- a/kernel/bpf/helpers.c
+++ b/kernel/bpf/helpers.c
@@ -13,6 +13,7 @@
 #include <linux/rcupdate.h>
 #include <linux/random.h>
 #include <linux/smp.h>
+#include <linux/ktime.h>
 
 /* If kernel subsystem is allowing eBPF programs to call this function,
  * inside its own verifier_ops->get_func_proto() callback it should return
@@ -111,3 +112,15 @@ const struct bpf_func_proto bpf_get_smp_processor_id_proto = {
 	.gpl_only	= false,
 	.ret_type	= RET_INTEGER,
 };
+
+static u64 bpf_ktime_get_ns(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	/* NMI safe access to clock monotonic */
+	return ktime_get_mono_fast_ns();
+}
+
+const struct bpf_func_proto bpf_ktime_get_ns_proto = {
+	.func		= bpf_ktime_get_ns,
+	.gpl_only	= true,
+	.ret_type	= RET_INTEGER,
+};
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 646445e..50c4015 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -79,18 +79,6 @@ static const struct bpf_func_proto bpf_probe_read_proto = {
 	.arg3_type	= ARG_ANYTHING,
 };
 
-static u64 bpf_ktime_get_ns(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
-{
-	/* NMI safe access to clock monotonic */
-	return ktime_get_mono_fast_ns();
-}
-
-static const struct bpf_func_proto bpf_ktime_get_ns_proto = {
-	.func		= bpf_ktime_get_ns,
-	.gpl_only	= true,
-	.ret_type	= RET_INTEGER,
-};
-
 /*
  * limited trace_printk()
  * only %d %u %x %ld %lu %lx %lld %llu %llx %p conversion specifiers allowed
diff --git a/net/core/filter.c b/net/core/filter.c
index 3adcca6..2a7c70f 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1423,6 +1423,8 @@ sk_filter_func_proto(enum bpf_func_id func_id)
 		return &bpf_get_smp_processor_id_proto;
 	case BPF_FUNC_tail_call:
 		return &bpf_tail_call_proto;
+	case BPF_FUNC_ktime_get_ns:
+		return &bpf_ktime_get_ns_proto;
 	default:
 		return NULL;
 	}
-- 
1.9.3
