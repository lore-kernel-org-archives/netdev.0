From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2 2/3] bpf, perf: split bpf_perf_event_output
Date: Thu, 14 Jul 2016 18:08:04 +0200
Message-ID: <1b1dc7c67e726d7bf14662c353b4a0854e214674.1468511632.git.daniel@iogearbox.net>
References: <cover.1468511632.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, peterz@infradead.org, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1468511632.git.daniel@iogearbox.net>
In-Reply-To: <cover.1468511632.git.daniel@iogearbox.net>
References: <cover.1468511632.git.daniel@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Split the bpf_perf_event_output() helper as a preparation into
two parts. The new bpf_perf_event_output() will prepare the raw
record itself and test for unknown flags from BPF trace context,
where the __bpf_perf_event_output() does the core work. The
latter will be reused later on from bpf_event_output() directly.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/trace/bpf_trace.c | 35 ++++++++++++++++++++++-------------
 1 file changed, 22 insertions(+), 13 deletions(-)

diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 35ab1b2..c35883a 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -233,26 +233,17 @@ static const struct bpf_func_proto bpf_perf_event_read_proto = {
 	.arg2_type	= ARG_ANYTHING,
 };
 
-static u64 bpf_perf_event_output(u64 r1, u64 r2, u64 flags, u64 r4, u64 size)
+static __always_inline u64
+__bpf_perf_event_output(struct pt_regs *regs, struct bpf_map *map,
+			u64 flags, struct perf_raw_record *raw)
 {
-	struct pt_regs *regs = (struct pt_regs *) (long) r1;
-	struct bpf_map *map = (struct bpf_map *) (long) r2;
 	struct bpf_array *array = container_of(map, struct bpf_array, map);
 	unsigned int cpu = smp_processor_id();
 	u64 index = flags & BPF_F_INDEX_MASK;
-	void *data = (void *) (long) r4;
 	struct perf_sample_data sample_data;
 	struct bpf_event_entry *ee;
 	struct perf_event *event;
-	struct perf_raw_record raw = {
-		.frag = {
-			.size = size,
-			.data = data,
-		},
-	};
 
-	if (unlikely(flags & ~(BPF_F_INDEX_MASK)))
-		return -EINVAL;
 	if (index == BPF_F_CURRENT_CPU)
 		index = cpu;
 	if (unlikely(index >= array->map.max_entries))
@@ -271,11 +262,29 @@ static u64 bpf_perf_event_output(u64 r1, u64 r2, u64 flags, u64 r4, u64 size)
 		return -EOPNOTSUPP;
 
 	perf_sample_data_init(&sample_data, 0, 0);
-	sample_data.raw = &raw;
+	sample_data.raw = raw;
 	perf_event_output(event, &sample_data, regs);
 	return 0;
 }
 
+static u64 bpf_perf_event_output(u64 r1, u64 r2, u64 flags, u64 r4, u64 size)
+{
+	struct pt_regs *regs = (struct pt_regs *)(long) r1;
+	struct bpf_map *map  = (struct bpf_map *)(long) r2;
+	void *data = (void *)(long) r4;
+	struct perf_raw_record raw = {
+		.frag = {
+			.size = size,
+			.data = data,
+		},
+	};
+
+	if (unlikely(flags & ~(BPF_F_INDEX_MASK)))
+		return -EINVAL;
+
+	return __bpf_perf_event_output(regs, map, flags, &raw);
+}
+
 static const struct bpf_func_proto bpf_perf_event_output_proto = {
 	.func		= bpf_perf_event_output,
 	.gpl_only	= true,
-- 
1.9.3
