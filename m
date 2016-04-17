From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/2] bpf: add event output helper for notifications/sampling/logging
Date: Mon, 18 Apr 2016 00:29:08 +0200
Message-ID: <3f0cdec313dfaefcc5254a10a58c4e1a380ad79c.1460931309.git.daniel@iogearbox.net>
References: <cover.1460931309.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@kernel.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33890 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751519AbcDQW33 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2016 18:29:29 -0400
In-Reply-To: <cover.1460931309.git.daniel@iogearbox.net>
In-Reply-To: <cover.1460931309.git.daniel@iogearbox.net>
References: <cover.1460931309.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a new helper for cls/act programs that can push events
to user space applications. For networking, this can be f.e. for sampling,
debugging, logging purposes or pushing of arbitrary wake-up events. The
idea is similar to a43eec304259 ("bpf: introduce bpf_perf_event_output()
helper") and 39111695b1b8 ("samples: bpf: add bpf_perf_event_output example").

The eBPF program utilizes a perf event array map that user space populates
with fds from perf_event_open(), the eBPF program calls into the helper
f.e. as skb_event_output(skb, &my_map, BPF_F_CURRENT_CPU, raw, sizeof(raw))
so that the raw data is pushed into the fd f.e. at the map index of the
current CPU.

User space can poll/mmap/etc on this and has a data channel for receiving
events that can be post-processed. The nice thing is that since the eBPF
program and user space application making use of it are tightly coupled,
they can define their own arbitrary raw data format and what/when they
want to push.

While f.e. packet headers could be one part of the meta data that is being
pushed, this is not a substitute for things like packet sockets as whole
packet is not being pushed and push is only done in a single direction.
Intention is more of a generically usable, efficient event pipe to applications.
Workflow is that tc can pin the map and applications can attach themselves
e.g. after cls/act setup to one or multiple map slots, demuxing is done by
the eBPF program.

Adding this facility is with minimal effort, it reuses the helper
introduced in a43eec304259 ("bpf: introduce bpf_perf_event_output() helper")
and we get its functionality for free by overloading its BPF_FUNC_ identifier
for cls/act programs, ctx is currently unused, but will be made use of in
future. Example will be added to iproute2's BPF example files.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/bpf.h      |  2 ++
 kernel/trace/bpf_trace.c |  2 +-
 net/core/filter.c        | 30 ++++++++++++++++++++++++++++++
 3 files changed, 33 insertions(+), 1 deletion(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 5fb3c61..2116924 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -167,6 +167,8 @@ struct bpf_array {
 
 u64 bpf_tail_call(u64 ctx, u64 r2, u64 index, u64 r4, u64 r5);
 u64 bpf_get_stackid(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
+u64 bpf_perf_event_output(u64 r1, u64 r2, u64 flags, u64 r4, u64 size);
+
 void bpf_fd_array_map_clear(struct bpf_map *map);
 bool bpf_prog_array_compatible(struct bpf_array *array, const struct bpf_prog *fp);
 const struct bpf_func_proto *bpf_get_trace_printk_proto(void);
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 6bfe55c..7fe2f22 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -225,7 +225,7 @@ static const struct bpf_func_proto bpf_perf_event_read_proto = {
 	.arg2_type	= ARG_ANYTHING,
 };
 
-static u64 bpf_perf_event_output(u64 r1, u64 r2, u64 flags, u64 r4, u64 size)
+u64 bpf_perf_event_output(u64 r1, u64 r2, u64 flags, u64 r4, u64 size)
 {
 	struct pt_regs *regs = (struct pt_regs *) (long) r1;
 	struct bpf_map *map = (struct bpf_map *) (long) r2;
diff --git a/net/core/filter.c b/net/core/filter.c
index 5d2ac2b..3521252 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -46,6 +46,7 @@
 #include <linux/seccomp.h>
 #include <linux/if_vlan.h>
 #include <linux/bpf.h>
+#include <linux/perf_event.h>
 #include <net/sch_generic.h>
 #include <net/cls_cgroup.h>
 #include <net/dst_metadata.h>
@@ -1584,6 +1585,33 @@ static const struct bpf_func_proto bpf_csum_diff_proto = {
 	.arg5_type	= ARG_ANYTHING,
 };
 
+u64 __weak bpf_perf_event_output(u64 r1, u64 r2, u64 flags, u64 r4, u64 size)
+{
+	return -EACCES;
+}
+
+static DEFINE_PER_CPU(struct pt_regs, bpf_pt_regs);
+
+static u64 bpf_skb_event_output(u64 r1, u64 r2, u64 flags, u64 r4, u64 size)
+{
+	struct pt_regs *regs = this_cpu_ptr(&bpf_pt_regs);
+
+	perf_fetch_caller_regs(regs);
+
+	return bpf_perf_event_output((long)regs, r2, flags, r4, size);
+}
+
+static const struct bpf_func_proto bpf_skb_event_output_proto = {
+	.func		= bpf_skb_event_output,
+	.gpl_only	= true,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_PTR_TO_CTX,
+	.arg2_type	= ARG_CONST_MAP_PTR,
+	.arg3_type	= ARG_ANYTHING,
+	.arg4_type	= ARG_PTR_TO_STACK,
+	.arg5_type	= ARG_CONST_STACK_SIZE,
+};
+
 static u64 bpf_clone_redirect(u64 r1, u64 ifindex, u64 flags, u64 r4, u64 r5)
 {
 	struct sk_buff *skb = (struct sk_buff *) (long) r1, *skb2;
@@ -2039,6 +2067,8 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
 		return &bpf_redirect_proto;
 	case BPF_FUNC_get_route_realm:
 		return &bpf_get_route_realm_proto;
+	case BPF_FUNC_perf_event_output:
+		return &bpf_skb_event_output_proto;
 	default:
 		return sk_filter_func_proto(func_id);
 	}
-- 
1.9.3
