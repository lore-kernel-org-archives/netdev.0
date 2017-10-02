From: Yonghong Song <yhs@fb.com>
Subject: [PATCH net-next v6 1/4] bpf: add helper bpf_perf_event_read_value for perf event array map
Date: Mon, 2 Oct 2017 15:42:15 -0700
Message-ID: <20171002224218.3181418-2-yhs@fb.com>
References: <20171002224218.3181418-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <peterz@infradead.org>, <rostedt@goodmis.org>, <ast@fb.com>,
        <daniel@iogearbox.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:56652 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751204AbdJBWnF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 18:43:05 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
        by mx0b-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v92MfiRY006210
        for <netdev@vger.kernel.org>; Mon, 2 Oct 2017 15:43:04 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0b-00082601.pphosted.com with ESMTP id 2dbvwf8fec-8
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 15:43:04 -0700
In-Reply-To: <20171002224218.3181418-1-yhs@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hardware pmu counters are limited resources. When there are more
pmu based perf events opened than available counters, kernel will
multiplex these events so each event gets certain percentage
(but not 100%) of the pmu time. In case that multiplexing happens,
the number of samples or counter value will not reflect the
case compared to no multiplexing. This makes comparison between
different runs difficult.

Typically, the number of samples or counter value should be
normalized before comparing to other experiments. The typical
normalization is done like:
  normalized_num_samples = num_samples * time_enabled / time_running
  normalized_counter_value = counter_value * time_enabled / time_running
where time_enabled is the time enabled for event and time_running is
the time running for event since last normalization.

This patch adds helper bpf_perf_event_read_value for kprobed based perf
event array map, to read perf counter and enabled/running time.
The enabled/running time is accumulated since the perf event open.
To achieve scaling factor between two bpf invocations, users
can can use cpu_id as the key (which is typical for perf array usage model)
to remember the previous value and do the calculation inside the
bpf program.

Signed-off-by: Yonghong Song <yhs@fb.com>
---
 include/linux/perf_event.h |  6 ++++--
 include/uapi/linux/bpf.h   | 20 ++++++++++++++++++--
 kernel/bpf/arraymap.c      |  2 +-
 kernel/bpf/verifier.c      |  4 +++-
 kernel/events/core.c       | 15 ++++++++++++---
 kernel/trace/bpf_trace.c   | 46 +++++++++++++++++++++++++++++++++++++++++-----
 6 files changed, 79 insertions(+), 14 deletions(-)

diff --git a/include/linux/perf_event.h b/include/linux/perf_event.h
index 8e22f24..21d8c12 100644
--- a/include/linux/perf_event.h
+++ b/include/linux/perf_event.h
@@ -884,7 +884,8 @@ perf_event_create_kernel_counter(struct perf_event_attr *attr,
 				void *context);
 extern void perf_pmu_migrate_context(struct pmu *pmu,
 				int src_cpu, int dst_cpu);
-int perf_event_read_local(struct perf_event *event, u64 *value);
+int perf_event_read_local(struct perf_event *event, u64 *value,
+			  u64 *enabled, u64 *running);
 extern u64 perf_event_read_value(struct perf_event *event,
 				 u64 *enabled, u64 *running);
 
@@ -1286,7 +1287,8 @@ static inline const struct perf_event_attr *perf_event_attrs(struct perf_event *
 {
 	return ERR_PTR(-EINVAL);
 }
-static inline int perf_event_read_local(struct perf_event *event, u64 *value)
+static inline int perf_event_read_local(struct perf_event *event, u64 *value,
+					u64 *enabled, u64 *running)
 {
 	return -EINVAL;
 }
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 6d2137b..4bdd4b2 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -592,6 +592,13 @@ union bpf_attr {
  *     @xdp_md: pointer to xdp_md
  *     @delta: An positive/negative integer to be added to xdp_md.data_meta
  *     Return: 0 on success or negative on error
+ * int bpf_perf_event_read_value(map, flags, buf, buf_size)
+ *     read perf event counter value and perf event enabled/running time
+ *     @map: pointer to perf_event_array map
+ *     @flags: index of event in the map or bitmask flags
+ *     @buf: buf to fill
+ *     @buf_size: size of the buf
+ *     Return: 0 on success or negative error code
  */
 #define __BPF_FUNC_MAPPER(FN)		\
 	FN(unspec),			\
@@ -648,7 +655,8 @@ union bpf_attr {
 	FN(redirect_map),		\
 	FN(sk_redirect_map),		\
 	FN(sock_map_update),		\
-	FN(xdp_adjust_meta),
+	FN(xdp_adjust_meta),		\
+	FN(perf_event_read_value),
 
 /* integer value in 'imm' field of BPF_CALL instruction selects which helper
  * function eBPF program intends to call
@@ -692,7 +700,9 @@ enum bpf_func_id {
 #define BPF_F_ZERO_CSUM_TX		(1ULL << 1)
 #define BPF_F_DONT_FRAGMENT		(1ULL << 2)
 
-/* BPF_FUNC_perf_event_output and BPF_FUNC_perf_event_read flags. */
+/* BPF_FUNC_perf_event_output, BPF_FUNC_perf_event_read and
+ * BPF_FUNC_perf_event_read_value flags.
+ */
 #define BPF_F_INDEX_MASK		0xffffffffULL
 #define BPF_F_CURRENT_CPU		BPF_F_INDEX_MASK
 /* BPF_FUNC_perf_event_output for sk_buff input context. */
@@ -885,4 +895,10 @@ enum {
 #define TCP_BPF_IW		1001	/* Set TCP initial congestion window */
 #define TCP_BPF_SNDCWND_CLAMP	1002	/* Set sndcwnd_clamp */
 
+struct bpf_perf_event_value {
+	__u64 counter;
+	__u64 enabled;
+	__u64 running;
+};
+
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index 98c0f00..68d8666 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -492,7 +492,7 @@ static void *perf_event_fd_array_get_ptr(struct bpf_map *map,
 
 	ee = ERR_PTR(-EOPNOTSUPP);
 	event = perf_file->private_data;
-	if (perf_event_read_local(event, &value) == -EOPNOTSUPP)
+	if (perf_event_read_local(event, &value, NULL, NULL) == -EOPNOTSUPP)
 		goto err_out;
 
 	ee = bpf_event_entry_gen(perf_file, map_file);
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 4cf9b72..b0cbc2d 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1552,7 +1552,8 @@ static int check_map_func_compatibility(struct bpf_map *map, int func_id)
 		break;
 	case BPF_MAP_TYPE_PERF_EVENT_ARRAY:
 		if (func_id != BPF_FUNC_perf_event_read &&
-		    func_id != BPF_FUNC_perf_event_output)
+		    func_id != BPF_FUNC_perf_event_output &&
+		    func_id != BPF_FUNC_perf_event_read_value)
 			goto error;
 		break;
 	case BPF_MAP_TYPE_STACK_TRACE:
@@ -1595,6 +1596,7 @@ static int check_map_func_compatibility(struct bpf_map *map, int func_id)
 		break;
 	case BPF_FUNC_perf_event_read:
 	case BPF_FUNC_perf_event_output:
+	case BPF_FUNC_perf_event_read_value:
 		if (map->map_type != BPF_MAP_TYPE_PERF_EVENT_ARRAY)
 			goto error;
 		break;
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 6bc21e2..c761ef4 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -3684,10 +3684,12 @@ static inline u64 perf_event_count(struct perf_event *event)
  *     will not be local and we cannot read them atomically
  *   - must not have a pmu::count method
  */
-int perf_event_read_local(struct perf_event *event, u64 *value)
+int perf_event_read_local(struct perf_event *event, u64 *value,
+			  u64 *enabled, u64 *running)
 {
 	unsigned long flags;
 	int ret = 0;
+	u64 now;
 
 	/*
 	 * Disabling interrupts avoids all counter scheduling (context
@@ -3718,14 +3720,21 @@ int perf_event_read_local(struct perf_event *event, u64 *value)
 		goto out;
 	}
 
+	now = event->shadow_ctx_time + perf_clock();
+	if (enabled)
+		*enabled = now - event->tstamp_enabled;
 	/*
 	 * If the event is currently on this CPU, its either a per-task event,
 	 * or local to this CPU. Furthermore it means its ACTIVE (otherwise
 	 * oncpu == -1).
 	 */
-	if (event->oncpu == smp_processor_id())
+	if (event->oncpu == smp_processor_id()) {
 		event->pmu->read(event);
-
+		if (running)
+			*running = now - event->tstamp_running;
+	} else if (running) {
+		*running = event->total_time_running;
+	}
 	*value = local64_read(&event->count);
 out:
 	local_irq_restore(flags);
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index dc498b6..686dfa1 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -255,14 +255,13 @@ const struct bpf_func_proto *bpf_get_trace_printk_proto(void)
 	return &bpf_trace_printk_proto;
 }
 
-BPF_CALL_2(bpf_perf_event_read, struct bpf_map *, map, u64, flags)
-{
+static __always_inline int
+get_map_perf_counter(struct bpf_map *map, u64 flags,
+		     u64 *value, u64 *enabled, u64 *running) {
 	struct bpf_array *array = container_of(map, struct bpf_array, map);
 	unsigned int cpu = smp_processor_id();
 	u64 index = flags & BPF_F_INDEX_MASK;
 	struct bpf_event_entry *ee;
-	u64 value = 0;
-	int err;
 
 	if (unlikely(flags & ~(BPF_F_INDEX_MASK)))
 		return -EINVAL;
@@ -275,7 +274,15 @@ BPF_CALL_2(bpf_perf_event_read, struct bpf_map *, map, u64, flags)
 	if (!ee)
 		return -ENOENT;
 
-	err = perf_event_read_local(ee->event, &value);
+	return perf_event_read_local(ee->event, value, enabled, running);
+}
+
+BPF_CALL_2(bpf_perf_event_read, struct bpf_map *, map, u64, flags)
+{
+	u64 value = 0;
+	int err;
+
+	err = get_map_perf_counter(map, flags, &value, NULL, NULL);
 	/*
 	 * this api is ugly since we miss [-22..-2] range of valid
 	 * counter values, but that's uapi
@@ -293,6 +300,33 @@ static const struct bpf_func_proto bpf_perf_event_read_proto = {
 	.arg2_type	= ARG_ANYTHING,
 };
 
+BPF_CALL_4(bpf_perf_event_read_value, struct bpf_map *, map, u64, flags,
+	   struct bpf_perf_event_value *, buf, u32, size)
+{
+	int err;
+
+	if (unlikely(size != sizeof(struct bpf_perf_event_value)))
+		return -EINVAL;
+
+	err = get_map_perf_counter(map, flags, &buf->counter, &buf->enabled,
+				   &buf->running);
+	if (unlikely(err)) {
+		memset(buf, 0, size);
+		return err;
+	}
+	return 0;
+}
+
+static const struct bpf_func_proto bpf_perf_event_read_value_proto = {
+	.func		= bpf_perf_event_read_value,
+	.gpl_only	= true,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_CONST_MAP_PTR,
+	.arg2_type	= ARG_ANYTHING,
+	.arg3_type	= ARG_PTR_TO_UNINIT_MEM,
+	.arg4_type	= ARG_CONST_SIZE,
+};
+
 static DEFINE_PER_CPU(struct perf_sample_data, bpf_sd);
 
 static __always_inline u64
@@ -499,6 +533,8 @@ static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func
 		return &bpf_perf_event_output_proto;
 	case BPF_FUNC_get_stackid:
 		return &bpf_get_stackid_proto;
+	case BPF_FUNC_perf_event_read_value:
+		return &bpf_perf_event_read_value_proto;
 	default:
 		return tracing_func_proto(func_id);
 	}
-- 
2.9.5
