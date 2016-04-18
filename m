From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2 2/2] bpf: add event output helper for notifications/sampling/logging
Date: Mon, 18 Apr 2016 21:01:24 +0200
Message-ID: <0a779688ae07a9a7dec50a4abc2b0dfa6246263e.1461005139.git.daniel@iogearbox.net>
References: <cover.1461005139.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@kernel.org>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1461005139.git.daniel@iogearbox.net>
In-Reply-To: <cover.1461005139.git.daniel@iogearbox.net>
References: <cover.1461005139.git.daniel@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
 kernel/bpf/core.c        |  7 +++++++
 kernel/trace/bpf_trace.c | 27 +++++++++++++++++++++++++++
 net/core/filter.c        |  2 ++
 4 files changed, 38 insertions(+)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 5fb3c61..f63afdc 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -169,7 +169,9 @@ u64 bpf_tail_call(u64 ctx, u64 r2, u64 index, u64 r4, u64 r5);
 u64 bpf_get_stackid(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
 void bpf_fd_array_map_clear(struct bpf_map *map);
 bool bpf_prog_array_compatible(struct bpf_array *array, const struct bpf_prog *fp);
+
 const struct bpf_func_proto *bpf_get_trace_printk_proto(void);
+const struct bpf_func_proto *bpf_get_event_output_proto(void);
 
 #ifdef CONFIG_BPF_SYSCALL
 DECLARE_PER_CPU(int, bpf_prog_active);
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index be0abf6..e4248fe 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -764,14 +764,21 @@ const struct bpf_func_proto bpf_map_delete_elem_proto __weak;
 const struct bpf_func_proto bpf_get_prandom_u32_proto __weak;
 const struct bpf_func_proto bpf_get_smp_processor_id_proto __weak;
 const struct bpf_func_proto bpf_ktime_get_ns_proto __weak;
+
 const struct bpf_func_proto bpf_get_current_pid_tgid_proto __weak;
 const struct bpf_func_proto bpf_get_current_uid_gid_proto __weak;
 const struct bpf_func_proto bpf_get_current_comm_proto __weak;
+
 const struct bpf_func_proto * __weak bpf_get_trace_printk_proto(void)
 {
 	return NULL;
 }
 
+const struct bpf_func_proto * __weak bpf_get_event_output_proto(void)
+{
+	return NULL;
+}
+
 /* Always built-in helper functions. */
 const struct bpf_func_proto bpf_tail_call_proto = {
 	.func		= NULL,
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 6bfe55c..75cb154 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -277,6 +277,33 @@ static const struct bpf_func_proto bpf_perf_event_output_proto = {
 	.arg5_type	= ARG_CONST_STACK_SIZE,
 };
 
+static DEFINE_PER_CPU(struct pt_regs, bpf_pt_regs);
+
+static u64 bpf_event_output(u64 r1, u64 r2, u64 flags, u64 r4, u64 size)
+{
+	struct pt_regs *regs = this_cpu_ptr(&bpf_pt_regs);
+
+	perf_fetch_caller_regs(regs);
+
+	return bpf_perf_event_output((long)regs, r2, flags, r4, size);
+}
+
+static const struct bpf_func_proto bpf_event_output_proto = {
+	.func		= bpf_event_output,
+	.gpl_only	= true,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_PTR_TO_CTX,
+	.arg2_type	= ARG_CONST_MAP_PTR,
+	.arg3_type	= ARG_ANYTHING,
+	.arg4_type	= ARG_PTR_TO_STACK,
+	.arg5_type	= ARG_CONST_STACK_SIZE,
+};
+
+const struct bpf_func_proto *bpf_get_event_output_proto(void)
+{
+	return &bpf_event_output_proto;
+}
+
 static const struct bpf_func_proto *tracing_func_proto(enum bpf_func_id func_id)
 {
 	switch (func_id) {
diff --git a/net/core/filter.c b/net/core/filter.c
index 5d2ac2b..218e5de 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2039,6 +2039,8 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
 		return &bpf_redirect_proto;
 	case BPF_FUNC_get_route_realm:
 		return &bpf_get_route_realm_proto;
+	case BPF_FUNC_perf_event_output:
+		return bpf_get_event_output_proto();
 	default:
 		return sk_filter_func_proto(func_id);
 	}
-- 
1.9.3
