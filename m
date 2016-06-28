From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 3/6] bpf, trace: add BPF_F_CURRENT_CPU flag for bpf_perf_event_read
Date: Tue, 28 Jun 2016 12:18:25 +0200
Message-ID: <e5ac092ac517c5fce9a50d16632f3e70136bdee5.1467106475.git.daniel@iogearbox.net>
References: <cover.1467106474.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54355 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752434AbcF1KsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 06:48:00 -0400
In-Reply-To: <cover.1467106474.git.daniel@iogearbox.net>
In-Reply-To: <cover.1467106474.git.daniel@iogearbox.net>
References: <cover.1467106474.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Follow-up commit to 1e33759c788c ("bpf, trace: add BPF_F_CURRENT_CPU
flag for bpf_perf_event_output") to add the same functionality into
bpf_perf_event_read() helper. The split of index into flags and index
component is also safe here, since such large maps are rejected during
map allocation time.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/uapi/linux/bpf.h |  2 +-
 kernel/trace/bpf_trace.c | 11 ++++++++---
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 406459b..58df2da 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -347,7 +347,7 @@ enum bpf_func_id {
 #define BPF_F_ZERO_CSUM_TX		(1ULL << 1)
 #define BPF_F_DONT_FRAGMENT		(1ULL << 2)
 
-/* BPF_FUNC_perf_event_output flags. */
+/* BPF_FUNC_perf_event_output and BPF_FUNC_perf_event_read flags. */
 #define BPF_F_INDEX_MASK		0xffffffffULL
 #define BPF_F_CURRENT_CPU		BPF_F_INDEX_MASK
 
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 505f9e9..19c5b4a 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -188,13 +188,19 @@ const struct bpf_func_proto *bpf_get_trace_printk_proto(void)
 	return &bpf_trace_printk_proto;
 }
 
-static u64 bpf_perf_event_read(u64 r1, u64 index, u64 r3, u64 r4, u64 r5)
+static u64 bpf_perf_event_read(u64 r1, u64 flags, u64 r3, u64 r4, u64 r5)
 {
 	struct bpf_map *map = (struct bpf_map *) (unsigned long) r1;
 	struct bpf_array *array = container_of(map, struct bpf_array, map);
+	unsigned int cpu = smp_processor_id();
+	u64 index = flags & BPF_F_INDEX_MASK;
 	struct bpf_event_entry *ee;
 	struct perf_event *event;
 
+	if (unlikely(flags & ~(BPF_F_INDEX_MASK)))
+		return -EINVAL;
+	if (index == BPF_F_CURRENT_CPU)
+		index = cpu;
 	if (unlikely(index >= array->map.max_entries))
 		return -E2BIG;
 
@@ -208,8 +214,7 @@ static u64 bpf_perf_event_read(u64 r1, u64 index, u64 r3, u64 r4, u64 r5)
 		return -EINVAL;
 
 	/* make sure event is local and doesn't have pmu::count */
-	if (event->oncpu != smp_processor_id() ||
-	    event->pmu->count)
+	if (unlikely(event->oncpu != cpu || event->pmu->count))
 		return -EINVAL;
 
 	/*
-- 
1.9.3
