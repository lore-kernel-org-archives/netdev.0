From: Kaixu Xia <xiakaixu@huawei.com>
Subject: [PATCH V3 1/2] bpf: control the trace data output on current cpu when perf sampling
Date: Fri, 16 Oct 2015 07:42:12 +0000
Message-ID: <1444981333-70429-2-git-send-email-xiakaixu@huawei.com>
References: <1444981333-70429-1-git-send-email-xiakaixu@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <xiakaixu@huawei.com>, <wangnan0@huawei.com>,
	<linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<hekuang@huawei.com>, <netdev@vger.kernel.org>
To: <ast@plumgrid.com>, <davem@davemloft.net>, <acme@kernel.org>,
	<mingo@redhat.com>, <a.p.zijlstra@chello.nl>,
	<masami.hiramatsu.pt@hitachi.com>, <jolsa@kernel.org>,
	<daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444981333-70429-1-git-send-email-xiakaixu@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds the flag dump_enable to control the trace data
output process when perf sampling. By setting this flag and
integrating with ebpf, we can control the data output process and
get the samples we are most interested in.

The bpf helper bpf_perf_event_dump_control() can control the
perf_event on current cpu.

Signed-off-by: Kaixu Xia <xiakaixu@huawei.com>
---
 include/linux/perf_event.h      |  1 +
 include/uapi/linux/bpf.h        |  5 +++++
 include/uapi/linux/perf_event.h |  3 ++-
 kernel/bpf/verifier.c           |  3 ++-
 kernel/events/core.c            | 13 ++++++++++++
 kernel/trace/bpf_trace.c        | 44 +++++++++++++++++++++++++++++++++++++++++
 6 files changed, 67 insertions(+), 2 deletions(-)

diff --git a/include/linux/perf_event.h b/include/linux/perf_event.h
index 092a0e8..2af527e 100644
--- a/include/linux/perf_event.h
+++ b/include/linux/perf_event.h
@@ -472,6 +472,7 @@ struct perf_event {
 	struct irq_work			pending;
 
 	atomic_t			event_limit;
+	atomic_t			dump_enable;
 
 	void (*destroy)(struct perf_event *);
 	struct rcu_head			rcu_head;
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 564f1f0..ba08034 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -287,6 +287,11 @@ enum bpf_func_id {
 	 * Return: realm if != 0
 	 */
 	BPF_FUNC_get_route_realm,
+
+	/**
+	 * u64 bpf_perf_event_dump_control(&map, index, flag)
+	 */
+	BPF_FUNC_perf_event_dump_control,
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/include/uapi/linux/perf_event.h b/include/uapi/linux/perf_event.h
index 2881145..f4b8f08 100644
--- a/include/uapi/linux/perf_event.h
+++ b/include/uapi/linux/perf_event.h
@@ -331,7 +331,8 @@ struct perf_event_attr {
 				comm_exec      :  1, /* flag comm events that are due to an exec */
 				use_clockid    :  1, /* use @clockid for time fields */
 				context_switch :  1, /* context switch data */
-				__reserved_1   : 37;
+				dump_enable    :  1, /* don't output data on samples */
+				__reserved_1   : 36;
 
 	union {
 		__u32		wakeup_events;	  /* wakeup every n events */
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 1d6b97b..26b55f2 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -245,6 +245,7 @@ static const struct {
 } func_limit[] = {
 	{BPF_MAP_TYPE_PROG_ARRAY, BPF_FUNC_tail_call},
 	{BPF_MAP_TYPE_PERF_EVENT_ARRAY, BPF_FUNC_perf_event_read},
+	{BPF_MAP_TYPE_PERF_EVENT_ARRAY, BPF_FUNC_perf_event_dump_control},
 };
 
 static void print_verifier_state(struct verifier_env *env)
@@ -910,7 +911,7 @@ static int check_map_func_compatibility(struct bpf_map *map, int func_id)
 		 * don't allow any other map type to be passed into
 		 * the special func;
 		 */
-		if (bool_map != bool_func)
+		if (bool_func && bool_map != bool_func)
 			return -EINVAL;
 	}
 
diff --git a/kernel/events/core.c b/kernel/events/core.c
index b11756f..74a16af 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -6337,6 +6337,9 @@ static int __perf_event_overflow(struct perf_event *event,
 		irq_work_queue(&event->pending);
 	}
 
+	if (!atomic_read(&event->dump_enable))
+		return ret;
+
 	if (event->overflow_handler)
 		event->overflow_handler(event, data, regs);
 	else
@@ -7709,6 +7712,14 @@ static void account_event(struct perf_event *event)
 	account_event_cpu(event, event->cpu);
 }
 
+static void perf_event_check_dump_flag(struct perf_event *event)
+{
+	if (event->attr.dump_enable == 1)
+		atomic_set(&event->dump_enable, 1);
+	else
+		atomic_set(&event->dump_enable, 0);
+}
+
 /*
  * Allocate and initialize a event structure
  */
@@ -7840,6 +7851,8 @@ perf_event_alloc(struct perf_event_attr *attr, int cpu,
 		}
 	}
 
+	perf_event_check_dump_flag(event);
+
 	return event;
 
 err_per_task:
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 0fe96c7..3175600 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -215,6 +215,48 @@ const struct bpf_func_proto bpf_perf_event_read_proto = {
 	.arg2_type	= ARG_ANYTHING,
 };
 
+/* flags for PERF_EVENT_ARRAY maps*/
+enum {
+	PERF_EVENT_CTL_BIT_DUMP = 0,
+	_NR_PERF_EVENT_CTL_BITS,
+};
+
+#define	BIT_FLAG_CHECK	GENMASK_ULL(63, _NR_PERF_EVENT_CTL_BITS)
+#define	BIT_DUMP_CTL	BIT_ULL(PERF_EVENT_CTL_BIT_DUMP)
+
+static u64 bpf_perf_event_dump_control(u64 r1, u64 index, u64 flag, u64 r4, u64 r5)
+{
+	struct bpf_map *map = (struct bpf_map *) (unsigned long) r1;
+	struct bpf_array *array = container_of(map, struct bpf_array, map);
+	struct perf_event *event;
+
+	if (unlikely(index >= array->map.max_entries))
+		return -E2BIG;
+
+	if (flag & BIT_FLAG_CHECK)
+		return -EINVAL;
+
+	event = (struct perf_event *)array->ptrs[index];
+	if (!event)
+		return -ENOENT;
+
+	if (flag & BIT_DUMP_CTL)
+		atomic_dec_if_positive(&event->dump_enable);
+	else
+		atomic_inc_unless_negative(&event->dump_enable);
+
+	return 0;
+}
+
+static const struct bpf_func_proto bpf_perf_event_dump_control_proto = {
+	.func		= bpf_perf_event_dump_control,
+	.gpl_only	= false,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_CONST_MAP_PTR,
+	.arg2_type	= ARG_ANYTHING,
+	.arg3_type	= ARG_ANYTHING,
+};
+
 static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func_id)
 {
 	switch (func_id) {
@@ -242,6 +284,8 @@ static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func
 		return &bpf_get_smp_processor_id_proto;
 	case BPF_FUNC_perf_event_read:
 		return &bpf_perf_event_read_proto;
+	case BPF_FUNC_perf_event_dump_control:
+		return &bpf_perf_event_dump_control_proto;
 	default:
 		return NULL;
 	}
-- 
1.8.3.4
