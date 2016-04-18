From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2 1/2] bpf, trace: add BPF_F_CURRENT_CPU flag for bpf_perf_event_output
Date: Mon, 18 Apr 2016 21:01:23 +0200
Message-ID: <1ac610a73de124f26d417dcdb8e79fd81ac333b8.1461005139.git.daniel@iogearbox.net>
References: <cover.1461005139.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@kernel.org>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1461005139.git.daniel@iogearbox.net>
In-Reply-To: <cover.1461005139.git.daniel@iogearbox.net>
References: <cover.1461005139.git.daniel@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a BPF_F_CURRENT_CPU flag to optimize the use-case where user space has
per-CPU ring buffers and the eBPF program pushes the data into the current
CPU's ring buffer which saves us an extra helper function call in eBPF.
Also, make sure to properly reserve the remaining flags which are not used.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 include/uapi/linux/bpf.h | 4 ++++
 kernel/trace/bpf_trace.c | 7 ++++++-
 2 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 70eda5a..b7b0fb1 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -347,6 +347,10 @@ enum bpf_func_id {
 #define BPF_F_ZERO_CSUM_TX		(1ULL << 1)
 #define BPF_F_DONT_FRAGMENT		(1ULL << 2)
 
+/* BPF_FUNC_perf_event_output flags. */
+#define BPF_F_INDEX_MASK		0xffffffffULL
+#define BPF_F_CURRENT_CPU		BPF_F_INDEX_MASK
+
 /* user accessible mirror of in-kernel sk_buff.
  * new fields can only be added to the end of this structure
  */
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 6855878..6bfe55c 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -225,11 +225,12 @@ static const struct bpf_func_proto bpf_perf_event_read_proto = {
 	.arg2_type	= ARG_ANYTHING,
 };
 
-static u64 bpf_perf_event_output(u64 r1, u64 r2, u64 index, u64 r4, u64 size)
+static u64 bpf_perf_event_output(u64 r1, u64 r2, u64 flags, u64 r4, u64 size)
 {
 	struct pt_regs *regs = (struct pt_regs *) (long) r1;
 	struct bpf_map *map = (struct bpf_map *) (long) r2;
 	struct bpf_array *array = container_of(map, struct bpf_array, map);
+	u64 index = flags & BPF_F_INDEX_MASK;
 	void *data = (void *) (long) r4;
 	struct perf_sample_data sample_data;
 	struct perf_event *event;
@@ -239,6 +240,10 @@ static u64 bpf_perf_event_output(u64 r1, u64 r2, u64 index, u64 r4, u64 size)
 		.data = data,
 	};
 
+	if (unlikely(flags & ~(BPF_F_INDEX_MASK)))
+		return -EINVAL;
+	if (index == BPF_F_CURRENT_CPU)
+		index = raw_smp_processor_id();
 	if (unlikely(index >= array->map.max_entries))
 		return -E2BIG;
 
-- 
1.9.3
