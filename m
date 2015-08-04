From: Kaixu Xia <xiakaixu@huawei.com>
Subject: [PATCH v6 3/4] bpf: Implement function bpf_perf_event_read() that get the selected hardware PMU conuter
Date: Tue, 4 Aug 2015 08:58:15 +0000
Message-ID: <1438678696-88289-4-git-send-email-xiakaixu@huawei.com>
References: <1438678696-88289-1-git-send-email-xiakaixu@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <xiakaixu@huawei.com>, <wangnan0@huawei.com>,
	<linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<hekuang@huawei.com>, <netdev@vger.kernel.org>
To: <ast@plumgrid.com>, <davem@davemloft.net>, <acme@kernel.org>,
	<mingo@redhat.com>, <a.p.zijlstra@chello.nl>,
	<masami.hiramatsu.pt@hitachi.com>, <jolsa@kernel.org>,
	<daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:7599 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932673AbbHDI6v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 04:58:51 -0400
In-Reply-To: <1438678696-88289-1-git-send-email-xiakaixu@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According to the perf_event_map_fd and index, the function
bpf_perf_event_read() can convert the corresponding map
value to the pointer to struct perf_event and return the
Hardware PMU counter value.

Signed-off-by: Kaixu Xia <xiakaixu@huawei.com>
---
 include/linux/bpf.h        |  1 +
 include/linux/perf_event.h |  2 ++
 include/uapi/linux/bpf.h   |  1 +
 kernel/bpf/verifier.c      | 49 ++++++++++++++++++++++++++++++++--------------
 kernel/events/core.c       | 19 ++++++++++++++++++
 kernel/trace/bpf_trace.c   | 31 +++++++++++++++++++++++++++++
 6 files changed, 88 insertions(+), 15 deletions(-)

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
index 81fc99e..6f1e448 100644
--- a/include/linux/perf_event.h
+++ b/include/linux/perf_event.h
@@ -643,6 +643,7 @@ extern void perf_event_free_task(struct task_struct *task);
 extern void perf_event_delayed_put(struct task_struct *task);
 extern struct perf_event *perf_event_get(unsigned int fd);
 extern struct perf_event_attr *perf_event_attrs(struct perf_event *event);
+extern u64 perf_event_read_internal(struct perf_event *event);
 extern void perf_event_print_debug(void);
 extern void perf_pmu_disable(struct pmu *pmu);
 extern void perf_pmu_enable(struct pmu *pmu);
@@ -986,6 +987,7 @@ static inline struct perf_event_attr *perf_event_attrs(struct perf_event *event)
 {
 	return ERR_PTR(-EINVAL);
 }
+static inline u64 perf_event_read_internal(struct perf_event *event)	{ return -EINVAL; }
 static inline void perf_event_print_debug(void)				{ }
 static inline int perf_event_task_disable(void)				{ return -EINVAL; }
 static inline int perf_event_task_enable(void)				{ return -EINVAL; }
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
index 039d866..45fae14 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -238,6 +238,14 @@ static const char * const reg_type_str[] = {
 	[CONST_IMM]		= "imm",
 };
 
+static const struct {
+	int map_type;
+	int func_id;
+} func_limit[] = {
+	{BPF_MAP_TYPE_PROG_ARRAY, BPF_FUNC_tail_call},
+	{BPF_MAP_TYPE_PERF_EVENT_ARRAY, BPF_FUNC_perf_event_read},
+};
+
 static void print_verifier_state(struct verifier_env *env)
 {
 	enum bpf_reg_type t;
@@ -833,6 +841,29 @@ static int check_func_arg(struct verifier_env *env, u32 regno,
 	return err;
 }
 
+static int check_func_limit(struct bpf_map **mapp, int func_id)
+{
+	struct bpf_map *map = *mapp;
+	bool bool_map, bool_func;
+	int i;
+
+	if (!map)
+		return 0;
+
+	for (i = 0; i <= ARRAY_SIZE(func_limit); i++) {
+		bool_map = (map->map_type == func_limit[i].map_type);
+		bool_func = (func_id == func_limit[i].func_id);
+		/* only when map & func pair match it can continue.
+		 * don't allow any other map type to be passed into
+		 * the special func;
+		 */
+		if (bool_map != bool_func)
+			return -EINVAL;
+	}
+
+	return 0;
+}
+
 static int check_call(struct verifier_env *env, int func_id)
 {
 	struct verifier_state *state = &env->cur_state;
@@ -908,21 +939,9 @@ static int check_call(struct verifier_env *env, int func_id)
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
index 6251b53..726ca1b 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -8599,6 +8599,25 @@ struct perf_event_attr *perf_event_attrs(struct perf_event *event)
 	return &event->attr;
 }
 
+u64 perf_event_read_internal(struct perf_event *event)
+{
+	if (!event)
+		return -EINVAL;
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
 /*
  * inherit a event from parent task to child task:
  */
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 88a041a..7d7b724 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -158,6 +158,35 @@ const struct bpf_func_proto *bpf_get_trace_printk_proto(void)
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
+	/*
+	 * we don't know if the function is run successfully by the
+	 * return value. It can be judged in other places, such as
+	 * eBPF programs.
+	 */
+	return perf_event_read_internal(event);
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
@@ -183,6 +212,8 @@ static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func
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
