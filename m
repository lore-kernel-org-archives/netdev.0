From: Kaixu Xia <xiakaixu@huawei.com>
Subject: [PATCH v5 3/4] bpf: Implement function bpf_perf_event_read() that get the selected hardware PMU conuter
Date: Fri, 31 Jul 2015 11:59:29 +0000
Message-ID: <1438343970-11974-4-git-send-email-xiakaixu@huawei.com>
References: <1438343970-11974-1-git-send-email-xiakaixu@huawei.com>
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
In-Reply-To: <1438343970-11974-1-git-send-email-xiakaixu@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

According to the perf_event_map_fd and index, the function
bpf_perf_event_read() can convert the corresponding map
value to the pointer to struct perf_event and return the
Hardware PMU counter value.

Signed-off-by: Kaixu Xia <xiakaixu@huawei.com>
---
 include/linux/bpf.h        |  1 +
 include/linux/perf_event.h | 12 +++++++++-
 include/uapi/linux/bpf.h   |  1 +
 kernel/bpf/verifier.c      | 56 +++++++++++++++++++++++++++++++++-------------
 kernel/events/core.c       | 10 +--------
 kernel/trace/bpf_trace.c   | 37 ++++++++++++++++++++++++++++++
 6 files changed, 92 insertions(+), 25 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index d0b394a..db9f781 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -190,6 +190,7 @@ extern const struct bpf_func_proto bpf_map_lookup_elem_proto;
 extern const struct bpf_func_proto bpf_map_update_elem_proto;
 extern const struct bpf_func_proto bpf_map_delete_elem_proto;
 
+extern const struct bpf_func_proto bpf_perf_event_read_proto;
 extern const struct bpf_func_proto bpf_get_prandom_u32_proto;
 extern const struct bpf_func_proto bpf_get_smp_processor_id_proto;
 extern const struct bpf_func_proto bpf_tail_call_proto;
diff --git a/include/linux/perf_event.h b/include/linux/perf_event.h
index 27e05c1..c1a3f39 100644
--- a/include/linux/perf_event.h
+++ b/include/linux/perf_event.h
@@ -662,7 +662,7 @@ extern void perf_pmu_migrate_context(struct pmu *pmu,
 				int src_cpu, int dst_cpu);
 extern u64 perf_event_read_value(struct perf_event *event,
 				 u64 *enabled, u64 *running);
-
+extern void __perf_event_read(void *info);
 
 struct perf_sample_data {
 	/*
@@ -863,6 +863,14 @@ static inline u64 __perf_event_count(struct perf_event *event)
 	return local64_read(&event->count) + atomic64_read(&event->child_count);
 }
 
+static inline u64 perf_event_count(struct perf_event *event)
+{
+	if (event->pmu->count)
+		return event->pmu->count(event);
+
+	return __perf_event_count(event);
+}
+
 extern void perf_event_mmap(struct vm_area_struct *vma);
 extern struct perf_guest_info_callbacks *perf_guest_cbs;
 extern int perf_register_guest_info_callbacks(struct perf_guest_info_callbacks *callbacks);
@@ -984,6 +992,8 @@ static struct perf_event *perf_event_get(unsigned int fd)		{ return ERR_PTR(-EIN
 static inline void perf_event_print_debug(void)				{ }
 static inline int perf_event_task_disable(void)				{ return -EINVAL; }
 static inline int perf_event_task_enable(void)				{ return -EINVAL; }
+static inline void __perf_event_read(void *info)			{ }
+static inline u64 perf_event_count(struct perf_event *event)		{ return 0; }
 static inline int perf_event_refresh(struct perf_event *event, int refresh)
 {
 	return -EINVAL;
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 69a1f6b..b9b13ce 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -250,6 +250,7 @@ enum bpf_func_id {
 	 * Return: 0 on success
 	 */
 	BPF_FUNC_get_current_comm,
+	BPF_FUNC_perf_event_read,	/* u64 bpf_perf_event_read(&map, index) */
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 039d866..93b6624 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -833,6 +833,44 @@ static int check_func_arg(struct verifier_env *env, u32 regno,
 	return err;
 }
 
+static int check_func_limit(struct bpf_map **mapp, int func_id)
+{
+	struct bpf_map *map = *mapp;
+
+	if (map && map->map_type == BPF_MAP_TYPE_PROG_ARRAY &&
+	    func_id != BPF_FUNC_tail_call)
+		/* prog_array map type needs extra care:
+		 * only allow to pass it into bpf_tail_call() for now.
+		 * bpf_map_delete_elem() can be allowed in the future,
+		 * while bpf_map_update_elem() must only be done via syscall
+		 */
+		return -EINVAL;
+
+	if (func_id == BPF_FUNC_tail_call &&
+	    map->map_type != BPF_MAP_TYPE_PROG_ARRAY)
+		/* don't allow any other map type to be passed into
+		 * bpf_tail_call()
+		 */
+		return -EINVAL;
+
+	if (map && map->map_type == BPF_MAP_TYPE_PERF_EVENT_ARRAY &&
+	    func_id != BPF_FUNC_perf_event_read)
+		/* perf_event_array map type needs extra care:
+		 * only allow to pass it into bpf_perf_event_read() for now.
+		 * bpf_map_update/delete_elem() must only be done via syscall
+		 */
+		return -EINVAL;
+
+	if (func_id == BPF_FUNC_perf_event_read &&
+	    map->map_type != BPF_MAP_TYPE_PERF_EVENT_ARRAY)
+		/* don't allow any other map type to be passed into
+		 * bpf_perf_event_read()
+		 */
+		return -EINVAL;
+
+	return 0;
+}
+
 static int check_call(struct verifier_env *env, int func_id)
 {
 	struct verifier_state *state = &env->cur_state;
@@ -908,21 +946,9 @@ static int check_call(struct verifier_env *env, int func_id)
 		return -EINVAL;
 	}
 
-	if (map && map->map_type == BPF_MAP_TYPE_PROG_ARRAY &&
-	    func_id != BPF_FUNC_tail_call)
-		/* prog_array map type needs extra care:
-		 * only allow to pass it into bpf_tail_call() for now.
-		 * bpf_map_delete_elem() can be allowed in the future,
-		 * while bpf_map_update_elem() must only be done via syscall
-		 */
-		return -EINVAL;
-
-	if (func_id == BPF_FUNC_tail_call &&
-	    map->map_type != BPF_MAP_TYPE_PROG_ARRAY)
-		/* don't allow any other map type to be passed into
-		 * bpf_tail_call()
-		 */
-		return -EINVAL;
+	err = check_func_limit(&map, func_id);
+	if (err)
+		return err;
 
 	return 0;
 }
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 58f0d47..1e4d65a 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -3177,7 +3177,7 @@ void perf_event_exec(void)
 /*
  * Cross CPU call to read the hardware event
  */
-static void __perf_event_read(void *info)
+void __perf_event_read(void *info)
 {
 	struct perf_event *event = info;
 	struct perf_event_context *ctx = event->ctx;
@@ -3204,14 +3204,6 @@ static void __perf_event_read(void *info)
 	raw_spin_unlock(&ctx->lock);
 }
 
-static inline u64 perf_event_count(struct perf_event *event)
-{
-	if (event->pmu->count)
-		return event->pmu->count(event);
-
-	return __perf_event_count(event);
-}
-
 static u64 perf_event_read(struct perf_event *event)
 {
 	/*
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 88a041a..5b81da1 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -158,6 +158,41 @@ const struct bpf_func_proto *bpf_get_trace_printk_proto(void)
 	return &bpf_trace_printk_proto;
 }
 
+static u64 bpf_perf_event_read(u64 r1, u64 index, u64 r3, u64 r4, u64 r5)
+{
+	struct bpf_map *map = (struct bpf_map *) (unsigned long) r1;
+	struct bpf_array *array = container_of(map, struct bpf_array, map);
+	struct perf_event *event;
+
+	if (unlikely(index >= array->map.max_entries))
+		return -E2BIG;
+
+	event = (struct perf_event *)array->ptrs[index];
+	if (!event)
+		return -ENOENT;
+
+	if (unlikely(event->state != PERF_EVENT_STATE_ACTIVE))
+		return -EINVAL;
+
+	if (event->oncpu != raw_smp_processor_id() &&
+	    event->ctx->task != current)
+		return -EINVAL;
+
+	if (unlikely(event->attr.inherit))
+		return -EINVAL;
+
+	__perf_event_read(event);
+	return perf_event_count(event);
+}
+
+const struct bpf_func_proto bpf_perf_event_read_proto = {
+	.func		= bpf_perf_event_read,
+	.gpl_only	= false,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_CONST_MAP_PTR,
+	.arg2_type	= ARG_ANYTHING,
+};
+
 static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func_id)
 {
 	switch (func_id) {
@@ -183,6 +218,8 @@ static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func
 		return bpf_get_trace_printk_proto();
 	case BPF_FUNC_get_smp_processor_id:
 		return &bpf_get_smp_processor_id_proto;
+	case BPF_FUNC_perf_event_read:
+		return &bpf_perf_event_read_proto;
 	default:
 		return NULL;
 	}
-- 
1.8.3.4
