From: Kaixu Xia <xiakaixu@huawei.com>
Subject: [PATCH V4 1/1] bpf: control events stored in PERF_EVENT_ARRAY maps trace data output when perf sampling
Date: Mon, 19 Oct 2015 10:37:40 +0000
Message-ID: <1445251060-114617-2-git-send-email-xiakaixu@huawei.com>
References: <1445251060-114617-1-git-send-email-xiakaixu@huawei.com>
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
In-Reply-To: <1445251060-114617-1-git-send-email-xiakaixu@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds the flag soft_enable to control the trace data
output process when perf sampling. By setting this flag and
integrating with ebpf, we can control the data output process and
get the samples we are most interested in.

The bpf helper bpf_perf_event_control() can control either the perf
event on current cpu or all the perf events stored in the maps by
checking the third parameter 'flag'.

Signed-off-by: Kaixu Xia <xiakaixu@huawei.com>
---
 include/linux/perf_event.h      |  1 +
 include/uapi/linux/bpf.h        | 19 +++++++++++++++
 include/uapi/linux/perf_event.h |  3 ++-
 kernel/bpf/verifier.c           |  3 ++-
 kernel/events/core.c            | 13 +++++++++++
 kernel/trace/bpf_trace.c        | 51 +++++++++++++++++++++++++++++++++++++++++
 6 files changed, 88 insertions(+), 2 deletions(-)

diff --git a/include/linux/perf_event.h b/include/linux/perf_event.h
index 092a0e8..bb3bf87 100644
--- a/include/linux/perf_event.h
+++ b/include/linux/perf_event.h
@@ -472,6 +472,7 @@ struct perf_event {
 	struct irq_work			pending;
 
 	atomic_t			event_limit;
+	atomic_t			soft_enable;
 
 	void (*destroy)(struct perf_event *);
 	struct rcu_head			rcu_head;
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 564f1f0..a2b0d9d 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -132,6 +132,20 @@ enum bpf_prog_type {
 #define BPF_NOEXIST	1 /* create new element if it didn't exist */
 #define BPF_EXIST	2 /* update existing element */
 
+/* flags for PERF_EVENT_ARRAY maps*/
+enum {
+	BPF_EVENT_CTL_BIT_CUR = 0,
+	BPF_EVENT_CTL_BIT_ALL = 1,
+	__NR_BPF_EVENT_CTL_BITS,
+};
+
+#define	BPF_CTL_BIT_FLAG_MASK \
+	((1ULL << __NR_BPF_EVENT_CTL_BITS) - 1)
+#define	BPF_CTL_BIT_DUMP_CUR \
+	(1ULL << BPF_EVENT_CTL_BIT_CUR)
+#define	BPF_CTL_BIT_DUMP_ALL \
+	(1ULL << BPF_EVENT_CTL_BIT_ALL)
+
 union bpf_attr {
 	struct { /* anonymous struct used by BPF_MAP_CREATE command */
 		__u32	map_type;	/* one of enum bpf_map_type */
@@ -287,6 +301,11 @@ enum bpf_func_id {
 	 * Return: realm if != 0
 	 */
 	BPF_FUNC_get_route_realm,
+
+	/**
+	 * u64 bpf_perf_event_control(&map, index, flag)
+	 */
+	BPF_FUNC_perf_event_control,
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/include/uapi/linux/perf_event.h b/include/uapi/linux/perf_event.h
index 2881145..a791b03 100644
--- a/include/uapi/linux/perf_event.h
+++ b/include/uapi/linux/perf_event.h
@@ -331,7 +331,8 @@ struct perf_event_attr {
 				comm_exec      :  1, /* flag comm events that are due to an exec */
 				use_clockid    :  1, /* use @clockid for time fields */
 				context_switch :  1, /* context switch data */
-				__reserved_1   : 37;
+				soft_disable   :  1, /* output data on samples by default */
+				__reserved_1   : 36;
 
 	union {
 		__u32		wakeup_events;	  /* wakeup every n events */
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 1d6b97b..ffec14b 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -245,6 +245,7 @@ static const struct {
 } func_limit[] = {
 	{BPF_MAP_TYPE_PROG_ARRAY, BPF_FUNC_tail_call},
 	{BPF_MAP_TYPE_PERF_EVENT_ARRAY, BPF_FUNC_perf_event_read},
+	{BPF_MAP_TYPE_PERF_EVENT_ARRAY, BPF_FUNC_perf_event_control},
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
index b11756f..5219635 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -6337,6 +6337,9 @@ static int __perf_event_overflow(struct perf_event *event,
 		irq_work_queue(&event->pending);
 	}
 
+	if (unlikely(!atomic_read(&event->soft_enable)))
+		return 0;
+
 	if (event->overflow_handler)
 		event->overflow_handler(event, data, regs);
 	else
@@ -7709,6 +7712,14 @@ static void account_event(struct perf_event *event)
 	account_event_cpu(event, event->cpu);
 }
 
+static void perf_event_check_dump_flag(struct perf_event *event)
+{
+	if (event->attr.soft_disable == 1)
+		atomic_set(&event->soft_enable, 0);
+	else
+		atomic_set(&event->soft_enable, 1);
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
index 0fe96c7..d26f3d4 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -215,6 +215,55 @@ const struct bpf_func_proto bpf_perf_event_read_proto = {
 	.arg2_type	= ARG_ANYTHING,
 };
 
+static u64 bpf_perf_event_control(u64 r1, u64 index, u64 flag, u64 r4, u64 r5)
+{
+	struct bpf_map *map = (struct bpf_map *) (unsigned long) r1;
+	struct bpf_array *array = container_of(map, struct bpf_array, map);
+	struct perf_event *event;
+	int i;
+
+	if (unlikely(index >= array->map.max_entries))
+		return -E2BIG;
+
+	if (flag & (~BPF_CTL_BIT_FLAG_MASK))
+		return -EINVAL;
+
+	if (flag & BPF_CTL_BIT_DUMP_ALL) {
+		bool dump_control = flag & BPF_CTL_BIT_DUMP_CUR;
+
+		for (i = 0; i < array->map.max_entries; i++) {
+			event = (struct perf_event *)array->ptrs[i];
+			if (!event)
+				continue;
+
+			if (dump_control)
+				atomic_dec_if_positive(&event->soft_enable);
+			else
+				atomic_inc_unless_negative(&event->soft_enable);
+		}
+		return 0;
+	}
+
+	event = (struct perf_event *)array->ptrs[index];
+	if (!event)
+		return -ENOENT;
+
+	if (flag & BPF_CTL_BIT_DUMP_CUR)
+		atomic_dec_if_positive(&event->soft_enable);
+	else
+		atomic_inc_unless_negative(&event->soft_enable);
+	return 0;
+}
+
+static const struct bpf_func_proto bpf_perf_event_control_proto = {
+	.func		= bpf_perf_event_control,
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
@@ -242,6 +291,8 @@ static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func
 		return &bpf_get_smp_processor_id_proto;
 	case BPF_FUNC_perf_event_read:
 		return &bpf_perf_event_read_proto;
+	case BPF_FUNC_perf_event_control:
+		return &bpf_perf_event_control_proto;
 	default:
 		return NULL;
 	}
-- 
1.8.3.4
