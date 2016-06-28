From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/6] bpf, trace: fetch current cpu only once
Date: Tue, 28 Jun 2016 12:18:24 +0200
Message-ID: <a6118cc34edd338143f92d5218611638aade286f.1467106475.git.daniel@iogearbox.net>
References: <cover.1467106474.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54534 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753154AbcF1KuS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 06:50:18 -0400
In-Reply-To: <cover.1467106474.git.daniel@iogearbox.net>
In-Reply-To: <cover.1467106474.git.daniel@iogearbox.net>
References: <cover.1467106474.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We currently have two invocations, which is unnecessary. Fetch it only
once and use the smp_processor_id() variant, so we also get preemption
checks along with it when DEBUG_PREEMPT is set.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/trace/bpf_trace.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 4e61f74..505f9e9 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -233,6 +233,7 @@ static u64 bpf_perf_event_output(u64 r1, u64 r2, u64 flags, u64 r4, u64 size)
 	struct pt_regs *regs = (struct pt_regs *) (long) r1;
 	struct bpf_map *map = (struct bpf_map *) (long) r2;
 	struct bpf_array *array = container_of(map, struct bpf_array, map);
+	unsigned int cpu = smp_processor_id();
 	u64 index = flags & BPF_F_INDEX_MASK;
 	void *data = (void *) (long) r4;
 	struct perf_sample_data sample_data;
@@ -246,7 +247,7 @@ static u64 bpf_perf_event_output(u64 r1, u64 r2, u64 flags, u64 r4, u64 size)
 	if (unlikely(flags & ~(BPF_F_INDEX_MASK)))
 		return -EINVAL;
 	if (index == BPF_F_CURRENT_CPU)
-		index = raw_smp_processor_id();
+		index = cpu;
 	if (unlikely(index >= array->map.max_entries))
 		return -E2BIG;
 
@@ -259,7 +260,7 @@ static u64 bpf_perf_event_output(u64 r1, u64 r2, u64 flags, u64 r4, u64 size)
 		     event->attr.config != PERF_COUNT_SW_BPF_OUTPUT))
 		return -EINVAL;
 
-	if (unlikely(event->oncpu != smp_processor_id()))
+	if (unlikely(event->oncpu != cpu))
 		return -EOPNOTSUPP;
 
 	perf_sample_data_init(&sample_data, 0, 0);
-- 
1.9.3
