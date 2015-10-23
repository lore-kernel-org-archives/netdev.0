From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v3 net-next] bpf: fix bpf_perf_event_read() helper
Date: Thu, 22 Oct 2015 17:10:14 -0700
Message-ID: <1445559014-4667-1-git-send-email-ast@kernel.org>
Cc: Ingo Molnar <mingo@kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Wang Nan <wangnan0@huawei.com>, He Kuang <hekuang@huawei.com>,
	Kaixu Xia <xiakaixu@huawei.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix safety checks for bpf_perf_event_read():
- only non-inherited events can be added to perf_event_array map
  (do this check statically at map insertion time)
- dynamically check that event is local and !pmu->count
Otherwise buggy bpf program can cause kernel splat.

Also fix error path after perf_event_attrs()
and remove redundant 'extern'.

Fixes: 35578d798400 ("bpf: Implement function bpf_perf_event_read() that get the selected hardware PMU conuter")
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
v2->v3:
. refactor checks based on Wangnan's and Peter's feedback
while refactoring realized that these two issues need fixes as well:
. fix perf_event_attrs() error path
. remove redundant extern

v1->v2: fix compile in case of !CONFIG_PERF_EVENTS

Even in the worst case the crash is not possible.
Only warn_on_once, so imo net-next is ok.

 include/linux/bpf.h      |    1 -
 kernel/bpf/arraymap.c    |   25 ++++++++++++++++---------
 kernel/trace/bpf_trace.c |    7 ++++++-
 3 files changed, 22 insertions(+), 11 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index e3a51b74e275..75718fa28260 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -194,7 +194,6 @@ extern const struct bpf_func_proto bpf_map_lookup_elem_proto;
 extern const struct bpf_func_proto bpf_map_update_elem_proto;
 extern const struct bpf_func_proto bpf_map_delete_elem_proto;
 
-extern const struct bpf_func_proto bpf_perf_event_read_proto;
 extern const struct bpf_func_proto bpf_get_prandom_u32_proto;
 extern const struct bpf_func_proto bpf_get_smp_processor_id_proto;
 extern const struct bpf_func_proto bpf_tail_call_proto;
diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index e3cfe46b074f..3f4c99e06c6b 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -292,16 +292,23 @@ static void *perf_event_fd_array_get_ptr(struct bpf_map *map, int fd)
 
 	attr = perf_event_attrs(event);
 	if (IS_ERR(attr))
-		return (void *)attr;
+		goto err;
 
-	if (attr->type != PERF_TYPE_RAW &&
-	    !(attr->type == PERF_TYPE_SOFTWARE &&
-	      attr->config == PERF_COUNT_SW_BPF_OUTPUT) &&
-	    attr->type != PERF_TYPE_HARDWARE) {
-		perf_event_release_kernel(event);
-		return ERR_PTR(-EINVAL);
-	}
-	return event;
+	if (attr->inherit)
+		goto err;
+
+	if (attr->type == PERF_TYPE_RAW)
+		return event;
+
+	if (attr->type == PERF_TYPE_HARDWARE)
+		return event;
+
+	if (attr->type == PERF_TYPE_SOFTWARE &&
+	    attr->config == PERF_COUNT_SW_BPF_OUTPUT)
+		return event;
+err:
+	perf_event_release_kernel(event);
+	return ERR_PTR(-EINVAL);
 }
 
 static void perf_event_fd_array_put_ptr(void *ptr)
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 47febbe7998e..003df3887287 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -199,6 +199,11 @@ static u64 bpf_perf_event_read(u64 r1, u64 index, u64 r3, u64 r4, u64 r5)
 	if (!event)
 		return -ENOENT;
 
+	/* make sure event is local and doesn't have pmu::count */
+	if (event->oncpu != smp_processor_id() ||
+	    event->pmu->count)
+		return -EINVAL;
+
 	/*
 	 * we don't know if the function is run successfully by the
 	 * return value. It can be judged in other places, such as
@@ -207,7 +212,7 @@ static u64 bpf_perf_event_read(u64 r1, u64 index, u64 r3, u64 r4, u64 r5)
 	return perf_event_read_local(event);
 }
 
-const struct bpf_func_proto bpf_perf_event_read_proto = {
+static const struct bpf_func_proto bpf_perf_event_read_proto = {
 	.func		= bpf_perf_event_read,
 	.gpl_only	= false,
 	.ret_type	= RET_INTEGER,
-- 
1.7.9.5
