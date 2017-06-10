From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 1/8] bpf: avoid excessive stack usage for perf_sample_data
Date: Sun, 11 Jun 2017 00:50:40 +0200
Message-ID: <0839d8663c3d58cbaba010572c237286bdeae366.1497133948.git.daniel@iogearbox.net>
References: <cover.1497133948.git.daniel@iogearbox.net>
Cc: ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57817 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751633AbdFJWu6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 18:50:58 -0400
In-Reply-To: <cover.1497133948.git.daniel@iogearbox.net>
In-Reply-To: <cover.1497133948.git.daniel@iogearbox.net>
References: <cover.1497133948.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

perf_sample_data consumes 386 bytes on stack, reduce excessive stack
usage and move it to per cpu buffer. It's allowed due to preemption
being disabled for tracing, xdp and tc programs, thus at all times
only one program can run on a specific CPU and programs cannot run
from interrupt. We similarly also handle bpf_pt_regs.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/trace/bpf_trace.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 08eb072..051d7fc 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -266,14 +266,16 @@ const struct bpf_func_proto *bpf_get_trace_printk_proto(void)
 	.arg2_type	= ARG_ANYTHING,
 };
 
+static DEFINE_PER_CPU(struct perf_sample_data, bpf_sd);
+
 static __always_inline u64
 __bpf_perf_event_output(struct pt_regs *regs, struct bpf_map *map,
 			u64 flags, struct perf_raw_record *raw)
 {
 	struct bpf_array *array = container_of(map, struct bpf_array, map);
+	struct perf_sample_data *sd = this_cpu_ptr(&bpf_sd);
 	unsigned int cpu = smp_processor_id();
 	u64 index = flags & BPF_F_INDEX_MASK;
-	struct perf_sample_data sample_data;
 	struct bpf_event_entry *ee;
 	struct perf_event *event;
 
@@ -294,9 +296,9 @@ const struct bpf_func_proto *bpf_get_trace_printk_proto(void)
 	if (unlikely(event->oncpu != cpu))
 		return -EOPNOTSUPP;
 
-	perf_sample_data_init(&sample_data, 0, 0);
-	sample_data.raw = raw;
-	perf_event_output(event, &sample_data, regs);
+	perf_sample_data_init(sd, 0, 0);
+	sd->raw = raw;
+	perf_event_output(event, sd, regs);
 	return 0;
 }
 
-- 
1.9.3
