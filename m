From: Yonghong Song <yhs@fb.com>
Subject: [PATCH net-next v7 2/5] bpf: add helper bpf_perf_event_read_value for perf event array map
Date: Thu, 5 Oct 2017 09:19:20 -0700
Message-ID: <20171005161923.332790-3-yhs@fb.com>
References: <20171005161923.332790-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <peterz@infradead.org>, <rostedt@goodmis.org>, <ast@fb.com>,
        <daniel@iogearbox.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:47924 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751755AbdJEQTl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 12:19:41 -0400
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v95GJfed030049
        for <netdev@vger.kernel.org>; Thu, 5 Oct 2017 09:19:41 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2ddqv5g319-3
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 09:19:37 -0700
In-Reply-To: <20171005161923.332790-1-yhs@fb.com>
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
Acked-by: Alexei Starovoitov <ast@fb.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/uapi/linux/bpf.h | 21 +++++++++++++++++++--
 kernel/bpf/verifier.c    |  4 +++-
 kernel/trace/bpf_trace.c | 45 +++++++++++++++++++++++++++++++++++++++++----
 3 files changed, 63 insertions(+), 7 deletions(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index cb2b9f9..93f3d1f 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -641,6 +641,14 @@ union bpf_attr {
  *     @xdp_md: pointer to xdp_md
  *     @delta: An positive/negative integer to be added to xdp_md.data_meta
  *     Return: 0 on success or negative on error
+ *
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
@@ -697,7 +705,8 @@ union bpf_attr {
 	FN(redirect_map),		\
 	FN(sk_redirect_map),		\
 	FN(sock_map_update),		\
-	FN(xdp_adjust_meta),
+	FN(xdp_adjust_meta),		\
+	FN(perf_event_read_value),
 
 /* integer value in 'imm' field of BPF_CALL instruction selects which helper
  * function eBPF program intends to call
@@ -741,7 +750,9 @@ enum bpf_func_id {
 #define BPF_F_ZERO_CSUM_TX		(1ULL << 1)
 #define BPF_F_DONT_FRAGMENT		(1ULL << 2)
 
-/* BPF_FUNC_perf_event_output and BPF_FUNC_perf_event_read flags. */
+/* BPF_FUNC_perf_event_output, BPF_FUNC_perf_event_read and
+ * BPF_FUNC_perf_event_read_value flags.
+ */
 #define BPF_F_INDEX_MASK		0xffffffffULL
 #define BPF_F_CURRENT_CPU		BPF_F_INDEX_MASK
 /* BPF_FUNC_perf_event_output for sk_buff input context. */
@@ -934,4 +945,10 @@ enum {
 #define TCP_BPF_IW		1001	/* Set TCP initial congestion window */
 #define TCP_BPF_SNDCWND_CLAMP	1002	/* Set sndcwnd_clamp */
 
+struct bpf_perf_event_value {
+	__u64 counter;
+	__u64 enabled;
+	__u64 running;
+};
+
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 52b0223..590125e 100644
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
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 95888ae..0be86cc 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -255,14 +255,14 @@ const struct bpf_func_proto *bpf_get_trace_printk_proto(void)
 	return &bpf_trace_printk_proto;
 }
 
-BPF_CALL_2(bpf_perf_event_read, struct bpf_map *, map, u64, flags)
+static __always_inline int
+get_map_perf_counter(struct bpf_map *map, u64 flags,
+		     u64 *value, u64 *enabled, u64 *running)
 {
 	struct bpf_array *array = container_of(map, struct bpf_array, map);
 	unsigned int cpu = smp_processor_id();
 	u64 index = flags & BPF_F_INDEX_MASK;
 	struct bpf_event_entry *ee;
-	u64 value = 0;
-	int err;
 
 	if (unlikely(flags & ~(BPF_F_INDEX_MASK)))
 		return -EINVAL;
@@ -275,7 +275,15 @@ BPF_CALL_2(bpf_perf_event_read, struct bpf_map *, map, u64, flags)
 	if (!ee)
 		return -ENOENT;
 
-	err = perf_event_read_local(ee->event, &value, NULL, NULL);
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
@@ -293,6 +301,33 @@ static const struct bpf_func_proto bpf_perf_event_read_proto = {
 	.arg2_type	= ARG_ANYTHING,
 };
 
+BPF_CALL_4(bpf_perf_event_read_value, struct bpf_map *, map, u64, flags,
+	   struct bpf_perf_event_value *, buf, u32, size)
+{
+	int err = -EINVAL;
+
+	if (unlikely(size != sizeof(struct bpf_perf_event_value)))
+		goto clear;
+	err = get_map_perf_counter(map, flags, &buf->counter, &buf->enabled,
+				   &buf->running);
+	if (unlikely(err))
+		goto clear;
+	return 0;
+clear:
+	memset(buf, 0, size);
+	return err;
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
@@ -499,6 +534,8 @@ static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func
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
