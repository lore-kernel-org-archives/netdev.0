From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/3] bpf, perf: split bpf_perf_event_output
Date: Wed, 13 Jul 2016 00:36:18 +0200
Message-ID: <efa00eb005d3e7655a2a0251ae3f82533d824821.1468362046.git.daniel@iogearbox.net>
References: <cover.1468362046.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, peterz@infradead.org, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44876 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784AbcGLWgv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 18:36:51 -0400
In-Reply-To: <cover.1468362046.git.daniel@iogearbox.net>
In-Reply-To: <cover.1468362046.git.daniel@iogearbox.net>
References: <cover.1468362046.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Split the bpf_perf_event_output() helper as a preparation into two
parts. The newly bpf_perf_event_output() will prepare the raw record
itself and test for unknown flags from BPF trace context, where the
__bpf_perf_event_output() does the core work and will be reused later
as well.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/trace/bpf_trace.c | 32 ++++++++++++++++++++------------
 1 file changed, 20 insertions(+), 12 deletions(-)

diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 8540bd5..4d3d5b8 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -233,25 +233,17 @@ static const struct bpf_func_proto bpf_perf_event_read_proto = {
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
-		.size = size,
-		.size_head = size,
-		.data = data,
-	};
 
-	if (unlikely(flags & ~(BPF_F_INDEX_MASK)))
-		return -EINVAL;
 	if (index == BPF_F_CURRENT_CPU)
 		index = cpu;
 	if (unlikely(index >= array->map.max_entries))
@@ -270,11 +262,27 @@ static u64 bpf_perf_event_output(u64 r1, u64 r2, u64 flags, u64 r4, u64 size)
 		return -EOPNOTSUPP;
 
 	perf_sample_data_init(&sample_data, 0, 0);
-	sample_data.raw = &raw;
+	sample_data.raw = raw;
 	perf_event_output(event, &sample_data, regs);
 	return 0;
 }
 
+static u64 bpf_perf_event_output(u64 r1, u64 r2, u64 flags, u64 r4, u64 size)
+{
+	struct perf_raw_record raw = {
+		.size		= size,
+		.size_head	= size,
+		.data		= (void *)(long) r4,
+	};
+
+	if (unlikely(flags & ~(BPF_F_INDEX_MASK)))
+		return -EINVAL;
+
+	return __bpf_perf_event_output((struct pt_regs *)(long) r1,
+				       (struct bpf_map *)(long) r2,
+				       flags, &raw);
+}
+
 static const struct bpf_func_proto bpf_perf_event_output_proto = {
 	.func		= bpf_perf_event_output,
 	.gpl_only	= true,
-- 
1.9.3
