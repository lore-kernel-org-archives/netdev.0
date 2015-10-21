From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next 2/3] bpf: introduce bpf_perf_event_output() helper
Date: Tue, 20 Oct 2015 20:02:34 -0700
Message-ID: <1445396556-4854-3-git-send-email-ast@kernel.org>
References: <1445396556-4854-1-git-send-email-ast@kernel.org>
Cc: Ingo Molnar <mingo@kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Wang Nan <wangnan0@huawei.com>, He Kuang <hekuang@huawei.com>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445396556-4854-1-git-send-email-ast@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This helper is used to send raw data from eBPF program into
special PERF_TYPE_SOFTWARE/PERF_COUNT_SW_BPF_OUTPUT perf_event.
User space needs to perf_event_open() it (either for one or all cpus) and
store FD into perf_event_array (similar to bpf_perf_event_read() helper)
before eBPF program can send data into it.

Today the programs triggered by kprobe collect the data and either store
it into the maps or print it via bpf_trace_printk() where latter is the debug
facility and not suitable to stream the data. This new helper replaces
such bpf_trace_printk() usage and allows programs to have dedicated
channel into user space for post-processing of the raw data collected.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 include/uapi/linux/bpf.h        |   11 ++++++++++
 include/uapi/linux/perf_event.h |    1 +
 kernel/bpf/arraymap.c           |    2 ++
 kernel/bpf/verifier.c           |    3 ++-
 kernel/trace/bpf_trace.c        |   46 +++++++++++++++++++++++++++++++++++++++
 5 files changed, 62 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 564f1f091991..2e032426cfb7 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -287,6 +287,17 @@ enum bpf_func_id {
 	 * Return: realm if != 0
 	 */
 	BPF_FUNC_get_route_realm,
+
+	/**
+	 * bpf_perf_event_output(ctx, map, index, data, size) - output perf raw sample
+	 * @ctx: struct pt_regs*
+	 * @map: pointer to perf_event_array map
+	 * @index: index of event in the map
+	 * @data: data on stack to be output as raw data
+	 * @size: size of data
+	 * Return: 0 on success
+	 */
+	BPF_FUNC_perf_event_output,
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/include/uapi/linux/perf_event.h b/include/uapi/linux/perf_event.h
index 2881145cda86..d3c417615361 100644
--- a/include/uapi/linux/perf_event.h
+++ b/include/uapi/linux/perf_event.h
@@ -110,6 +110,7 @@ enum perf_sw_ids {
 	PERF_COUNT_SW_ALIGNMENT_FAULTS		= 7,
 	PERF_COUNT_SW_EMULATION_FAULTS		= 8,
 	PERF_COUNT_SW_DUMMY			= 9,
+	PERF_COUNT_SW_BPF_OUTPUT		= 10,
 
 	PERF_COUNT_SW_MAX,			/* non-ABI */
 };
diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index f2d9e698c753..e3cfe46b074f 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -295,6 +295,8 @@ static void *perf_event_fd_array_get_ptr(struct bpf_map *map, int fd)
 		return (void *)attr;
 
 	if (attr->type != PERF_TYPE_RAW &&
+	    !(attr->type == PERF_TYPE_SOFTWARE &&
+	      attr->config == PERF_COUNT_SW_BPF_OUTPUT) &&
 	    attr->type != PERF_TYPE_HARDWARE) {
 		perf_event_release_kernel(event);
 		return ERR_PTR(-EINVAL);
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 1d6b97be79e1..b56cf51f8d42 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -245,6 +245,7 @@ static const struct {
 } func_limit[] = {
 	{BPF_MAP_TYPE_PROG_ARRAY, BPF_FUNC_tail_call},
 	{BPF_MAP_TYPE_PERF_EVENT_ARRAY, BPF_FUNC_perf_event_read},
+	{BPF_MAP_TYPE_PERF_EVENT_ARRAY, BPF_FUNC_perf_event_output},
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
 
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 0fe96c7c8803..47febbe7998e 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -215,6 +215,50 @@ const struct bpf_func_proto bpf_perf_event_read_proto = {
 	.arg2_type	= ARG_ANYTHING,
 };
 
+static u64 bpf_perf_event_output(u64 r1, u64 r2, u64 index, u64 r4, u64 size)
+{
+	struct pt_regs *regs = (struct pt_regs *) (long) r1;
+	struct bpf_map *map = (struct bpf_map *) (long) r2;
+	struct bpf_array *array = container_of(map, struct bpf_array, map);
+	void *data = (void *) (long) r4;
+	struct perf_sample_data sample_data;
+	struct perf_event *event;
+	struct perf_raw_record raw = {
+		.size = size,
+		.data = data,
+	};
+
+	if (unlikely(index >= array->map.max_entries))
+		return -E2BIG;
+
+	event = (struct perf_event *)array->ptrs[index];
+	if (unlikely(!event))
+		return -ENOENT;
+
+	if (unlikely(event->attr.type != PERF_TYPE_SOFTWARE ||
+		     event->attr.config != PERF_COUNT_SW_BPF_OUTPUT))
+		return -EINVAL;
+
+	if (unlikely(event->oncpu != smp_processor_id()))
+		return -EOPNOTSUPP;
+
+	perf_sample_data_init(&sample_data, 0, 0);
+	sample_data.raw = &raw;
+	perf_event_output(event, &sample_data, regs);
+	return 0;
+}
+
+static const struct bpf_func_proto bpf_perf_event_output_proto = {
+	.func		= bpf_perf_event_output,
+	.gpl_only	= false,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_PTR_TO_CTX,
+	.arg2_type	= ARG_CONST_MAP_PTR,
+	.arg3_type	= ARG_ANYTHING,
+	.arg4_type	= ARG_PTR_TO_STACK,
+	.arg5_type	= ARG_CONST_STACK_SIZE,
+};
+
 static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func_id)
 {
 	switch (func_id) {
@@ -242,6 +286,8 @@ static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func
 		return &bpf_get_smp_processor_id_proto;
 	case BPF_FUNC_perf_event_read:
 		return &bpf_perf_event_read_proto;
+	case BPF_FUNC_perf_event_output:
+		return &bpf_perf_event_output_proto;
 	default:
 		return NULL;
 	}
-- 
1.7.9.5
