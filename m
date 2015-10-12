From: Kaixu Xia <xiakaixu@huawei.com>
Subject: [RFC PATCH 2/2] bpf: Implement bpf_perf_event_sample_enable/disable() helpers
Date: Mon, 12 Oct 2015 09:02:43 +0000
Message-ID: <1444640563-159175-3-git-send-email-xiakaixu@huawei.com>
References: <1444640563-159175-1-git-send-email-xiakaixu@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <xiakaixu@huawei.com>, <wangnan0@huawei.com>,
	<linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<hekuang@huawei.com>, <netdev@vger.kernel.org>
To: <ast@plumgrid.com>, <davem@davemloft.net>, <acme@kernel.org>,
	<mingo@redhat.com>, <a.p.zijlstra@chello.nl>,
	<masami.hiramatsu.pt@hitachi.com>, <jolsa@kernel.org>,
	<daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444640563-159175-1-git-send-email-xiakaixu@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The functions bpf_perf_event_sample_enable/disable() can set the
flag sample_disable to enable/disable output trace data on samples.

Signed-off-by: Kaixu Xia <xiakaixu@huawei.com>
---
 include/linux/bpf.h      |  2 ++
 include/uapi/linux/bpf.h |  2 ++
 kernel/bpf/verifier.c    |  4 +++-
 kernel/trace/bpf_trace.c | 34 ++++++++++++++++++++++++++++++++++
 4 files changed, 41 insertions(+), 1 deletion(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 25e073d..09148ff 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -192,6 +192,8 @@ extern const struct bpf_func_proto bpf_map_update_elem_proto;
 extern const struct bpf_func_proto bpf_map_delete_elem_proto;
 
 extern const struct bpf_func_proto bpf_perf_event_read_proto;
+extern const struct bpf_func_proto bpf_perf_event_sample_enable_proto;
+extern const struct bpf_func_proto bpf_perf_event_sample_disable_proto;
 extern const struct bpf_func_proto bpf_get_prandom_u32_proto;
 extern const struct bpf_func_proto bpf_get_smp_processor_id_proto;
 extern const struct bpf_func_proto bpf_tail_call_proto;
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 92a48e2..5229c550 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -272,6 +272,8 @@ enum bpf_func_id {
 	BPF_FUNC_skb_get_tunnel_key,
 	BPF_FUNC_skb_set_tunnel_key,
 	BPF_FUNC_perf_event_read,	/* u64 bpf_perf_event_read(&map, index) */
+	BPF_FUNC_perf_event_sample_enable,	/* u64 bpf_perf_event_enable(&map) */
+	BPF_FUNC_perf_event_sample_disable,	/* u64 bpf_perf_event_disable(&map) */
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index b074b23..6428daf 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -244,6 +244,8 @@ static const struct {
 } func_limit[] = {
 	{BPF_MAP_TYPE_PROG_ARRAY, BPF_FUNC_tail_call},
 	{BPF_MAP_TYPE_PERF_EVENT_ARRAY, BPF_FUNC_perf_event_read},
+	{BPF_MAP_TYPE_PERF_EVENT_ARRAY, BPF_FUNC_perf_event_sample_enable},
+	{BPF_MAP_TYPE_PERF_EVENT_ARRAY, BPF_FUNC_perf_event_sample_disable},
 };
 
 static void print_verifier_state(struct verifier_env *env)
@@ -860,7 +862,7 @@ static int check_map_func_compatibility(struct bpf_map *map, int func_id)
 		 * don't allow any other map type to be passed into
 		 * the special func;
 		 */
-		if (bool_map != bool_func)
+		if (bool_func && bool_map != bool_func)
 			return -EINVAL;
 	}
 
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 0fe96c7..abe943a 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -215,6 +215,36 @@ const struct bpf_func_proto bpf_perf_event_read_proto = {
 	.arg2_type	= ARG_ANYTHING,
 };
 
+static u64 bpf_perf_event_sample_enable(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	struct bpf_map *map = (struct bpf_map *) (unsigned long) r1;
+
+	atomic_set(&map->perf_sample_disable, 0);
+	return 0;
+}
+
+const struct bpf_func_proto bpf_perf_event_sample_enable_proto = {
+       .func           = bpf_perf_event_sample_enable,
+       .gpl_only       = false,
+       .ret_type       = RET_INTEGER,
+       .arg1_type      = ARG_CONST_MAP_PTR,
+};
+
+static u64 bpf_perf_event_sample_disable(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+       struct bpf_map *map = (struct bpf_map *) (unsigned long) r1;
+
+       atomic_set(&map->perf_sample_disable, 1);
+       return 0;
+}
+
+const struct bpf_func_proto bpf_perf_event_sample_disable_proto = {
+       .func           = bpf_perf_event_sample_disable,
+       .gpl_only       = false,
+       .ret_type       = RET_INTEGER,
+       .arg1_type      = ARG_CONST_MAP_PTR,
+};
+
 static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func_id)
 {
 	switch (func_id) {
@@ -242,6 +272,10 @@ static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func
 		return &bpf_get_smp_processor_id_proto;
 	case BPF_FUNC_perf_event_read:
 		return &bpf_perf_event_read_proto;
+	case BPF_FUNC_perf_event_sample_enable:
+		return &bpf_perf_event_sample_enable_proto;
+	case BPF_FUNC_perf_event_sample_disable:
+		return &bpf_perf_event_sample_disable_proto;
 	default:
 		return NULL;
 	}
-- 
1.8.3.4
