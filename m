From: Yonghong Song <yhs@fb.com>
Subject: [PATCH net-next 1/4] bpf: add helper bpf_perf_read_counter_time for perf event array map
Date: Fri, 1 Sep 2017 09:53:54 -0700
Message-ID: <20170901165357.465121-2-yhs@fb.com>
References: <20170901165357.465121-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <peterz@infradead.org>, <rostedt@goodmis.org>, <ast@fb.com>,
        <daniel@iogearbox.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:35592 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752281AbdIAQx7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 12:53:59 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v81Gnwnm027275
        for <netdev@vger.kernel.org>; Fri, 1 Sep 2017 09:53:58 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2cq9aurp32-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2017 09:53:58 -0700
In-Reply-To: <20170901165357.465121-1-yhs@fb.com>
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

This patch adds helper bpf_perf_read_counter_time for kprobed based perf
event array map, to read perf counter and enabled/running time.
The enabled/running time is accumulated since the perf event open.
To achieve scaling factor between two bpf invocations, users
can can use cpu_id as the key (which is typical for perf array usage model)
to remember the previous value and do the calculation inside the
bpf program.

Signed-off-by: Yonghong Song <yhs@fb.com>
---
 include/linux/perf_event.h |  2 ++
 include/uapi/linux/bpf.h   | 21 +++++++++++++++++++-
 kernel/bpf/verifier.c      |  4 +++-
 kernel/events/core.c       |  2 +-
 kernel/trace/bpf_trace.c   | 49 ++++++++++++++++++++++++++++++++++++++++++----
 5 files changed, 71 insertions(+), 7 deletions(-)

diff --git a/include/linux/perf_event.h b/include/linux/perf_event.h
index b14095b..7fd5e94 100644
--- a/include/linux/perf_event.h
+++ b/include/linux/perf_event.h
@@ -901,6 +901,8 @@ extern void perf_pmu_migrate_context(struct pmu *pmu,
 int perf_event_read_local(struct perf_event *event, u64 *value);
 extern u64 perf_event_read_value(struct perf_event *event,
 				 u64 *enabled, u64 *running);
+extern void calc_timer_values(struct perf_event *event, u64 *now,
+         u64 *enabled, u64 *running);
 
 
 struct perf_sample_data {
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index ba848b7..9c23bef 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -582,6 +582,14 @@ union bpf_attr {
  *	@map: pointer to sockmap to update
  *	@key: key to insert/update sock in map
  *	@flags: same flags as map update elem
+ *
+ * int bpf_perf_read_counter_time(map, flags, counter_time_buf, buf_size)
+ *     read perf event counter value and perf event enabled/running time
+ *     @map: pointer to perf_event_array map
+ *     @flags: index of event in the map or bitmask flags
+ *     @counter_time_buf: buf to fill
+ *     @buf_size: size of the counter_time_buf
+ *     Return: 0 on success or negative error code
  */
 #define __BPF_FUNC_MAPPER(FN)		\
 	FN(unspec),			\
@@ -638,6 +646,7 @@ union bpf_attr {
 	FN(redirect_map),		\
 	FN(sk_redirect_map),		\
 	FN(sock_map_update),		\
+	FN(perf_read_counter_time),		\
 
 /* integer value in 'imm' field of BPF_CALL instruction selects which helper
  * function eBPF program intends to call
@@ -681,7 +690,8 @@ enum bpf_func_id {
 #define BPF_F_ZERO_CSUM_TX		(1ULL << 1)
 #define BPF_F_DONT_FRAGMENT		(1ULL << 2)
 
-/* BPF_FUNC_perf_event_output and BPF_FUNC_perf_event_read flags. */
+/* BPF_FUNC_perf_event_output, BPF_FUNC_perf_event_read and
+ * BPF_FUNC_perf_read_counter_time flags. */
 #define BPF_F_INDEX_MASK		0xffffffffULL
 #define BPF_F_CURRENT_CPU		BPF_F_INDEX_MASK
 /* BPF_FUNC_perf_event_output for sk_buff input context. */
@@ -864,4 +874,13 @@ enum {
 #define TCP_BPF_IW		1001	/* Set TCP initial congestion window */
 #define TCP_BPF_SNDCWND_CLAMP	1002	/* Set sndcwnd_clamp */
 
+struct bpf_perf_time {
+	__u64 enabled;
+	__u64 running;
+};
+struct bpf_perf_counter_time {
+	__u64 counter;
+	struct bpf_perf_time time;
+};
+
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index d690c7d..c4d29e3 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1494,7 +1494,8 @@ static int check_map_func_compatibility(struct bpf_map *map, int func_id)
 		break;
 	case BPF_MAP_TYPE_PERF_EVENT_ARRAY:
 		if (func_id != BPF_FUNC_perf_event_read &&
-		    func_id != BPF_FUNC_perf_event_output)
+		    func_id != BPF_FUNC_perf_event_output &&
+		    func_id != BPF_FUNC_perf_read_counter_time)
 			goto error;
 		break;
 	case BPF_MAP_TYPE_STACK_TRACE:
@@ -1537,6 +1538,7 @@ static int check_map_func_compatibility(struct bpf_map *map, int func_id)
 		break;
 	case BPF_FUNC_perf_event_read:
 	case BPF_FUNC_perf_event_output:
+	case BPF_FUNC_perf_read_counter_time:
 		if (map->map_type != BPF_MAP_TYPE_PERF_EVENT_ARRAY)
 			goto error;
 		break;
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 8c01572..ef5c7fb 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -4883,7 +4883,7 @@ static int perf_event_index(struct perf_event *event)
 	return event->pmu->event_idx(event);
 }
 
-static void calc_timer_values(struct perf_event *event,
+void calc_timer_values(struct perf_event *event,
 				u64 *now,
 				u64 *enabled,
 				u64 *running)
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index dc498b6..b807b1a 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -255,13 +255,13 @@ const struct bpf_func_proto *bpf_get_trace_printk_proto(void)
 	return &bpf_trace_printk_proto;
 }
 
-BPF_CALL_2(bpf_perf_event_read, struct bpf_map *, map, u64, flags)
-{
+static __always_inline int
+get_map_perf_counter(struct bpf_map *map, u64 flags,
+		u64 *value, struct perf_event **pe) {
 	struct bpf_array *array = container_of(map, struct bpf_array, map);
 	unsigned int cpu = smp_processor_id();
 	u64 index = flags & BPF_F_INDEX_MASK;
 	struct bpf_event_entry *ee;
-	u64 value = 0;
 	int err;
 
 	if (unlikely(flags & ~(BPF_F_INDEX_MASK)))
@@ -275,7 +275,19 @@ BPF_CALL_2(bpf_perf_event_read, struct bpf_map *, map, u64, flags)
 	if (!ee)
 		return -ENOENT;
 
-	err = perf_event_read_local(ee->event, &value);
+	err = perf_event_read_local(ee->event, value);
+	if (!err && pe)
+		*pe = ee->event;
+	return err;
+}
+
+
+BPF_CALL_2(bpf_perf_event_read, struct bpf_map *, map, u64, flags)
+{
+	u64 value = 0;
+	int err;
+
+	err = get_map_perf_counter(map, flags, &value, NULL);
 	/*
 	 * this api is ugly since we miss [-22..-2] range of valid
 	 * counter values, but that's uapi
@@ -285,6 +297,23 @@ BPF_CALL_2(bpf_perf_event_read, struct bpf_map *, map, u64, flags)
 	return value;
 }
 
+BPF_CALL_4(bpf_perf_read_counter_time, struct bpf_map *, map, u64, flags,
+	struct bpf_perf_counter_time *, buf, u32, size)
+{
+	struct perf_event *pe;
+	u64 now;
+	int err;
+
+	if (unlikely(size != sizeof(struct bpf_perf_counter_time)))
+		return -EINVAL;
+	err = get_map_perf_counter(map, flags, &buf->counter, &pe);
+	if (err)
+		return err;
+
+	calc_timer_values(pe, &now, &buf->time.enabled, &buf->time.running);
+	return 0;
+}
+
 static const struct bpf_func_proto bpf_perf_event_read_proto = {
 	.func		= bpf_perf_event_read,
 	.gpl_only	= true,
@@ -293,6 +322,16 @@ static const struct bpf_func_proto bpf_perf_event_read_proto = {
 	.arg2_type	= ARG_ANYTHING,
 };
 
+static const struct bpf_func_proto bpf_perf_read_counter_time_proto = {
+	.func		= bpf_perf_read_counter_time,
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
@@ -499,6 +538,8 @@ static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func
 		return &bpf_perf_event_output_proto;
 	case BPF_FUNC_get_stackid:
 		return &bpf_get_stackid_proto;
+	case BPF_FUNC_perf_read_counter_time:
+		return &bpf_perf_read_counter_time_proto;
 	default:
 		return tracing_func_proto(func_id);
 	}
-- 
2.9.5
