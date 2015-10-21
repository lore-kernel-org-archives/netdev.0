From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next] bpf: fix bpf_perf_event_read() helper
Date: Wed, 21 Oct 2015 14:36:53 -0700
Message-ID: <1445463413-13293-1-git-send-email-ast@kernel.org>
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
- only !inherited and !pmu->count events can be added to perf_event_array map
  (do this check statically at map insertion time)
- dynamically check that event is local
Otherwise buggy bpf program can cause kernel splat.

Fixes: 35578d798400 ("bpf: Implement function bpf_perf_event_read() that get the selected hardware PMU conuter")
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
This patch is on top of
http://patchwork.ozlabs.org/patch/533585/
to avoid conflicts.
Even in the worst case the crash is not possible.
Only warn_on_once, so imo net-next is ok.

 kernel/bpf/arraymap.c |   10 ++++++----
 kernel/events/core.c  |   13 ++++++++-----
 2 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index e3cfe46b074f..4cd1287ea1a3 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -294,10 +294,12 @@ static void *perf_event_fd_array_get_ptr(struct bpf_map *map, int fd)
 	if (IS_ERR(attr))
 		return (void *)attr;
 
-	if (attr->type != PERF_TYPE_RAW &&
-	    !(attr->type == PERF_TYPE_SOFTWARE &&
-	      attr->config == PERF_COUNT_SW_BPF_OUTPUT) &&
-	    attr->type != PERF_TYPE_HARDWARE) {
+	if ((attr->type != PERF_TYPE_RAW &&
+	     !(attr->type == PERF_TYPE_SOFTWARE &&
+	       attr->config == PERF_COUNT_SW_BPF_OUTPUT) &&
+	     attr->type != PERF_TYPE_HARDWARE) ||
+	    event->attr.inherit ||
+	    event->pmu->count) {
 		perf_event_release_kernel(event);
 		return ERR_PTR(-EINVAL);
 	}
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 64754bfecd70..639392d2b5c9 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -3258,7 +3258,7 @@ static inline u64 perf_event_count(struct perf_event *event)
 u64 perf_event_read_local(struct perf_event *event)
 {
 	unsigned long flags;
-	u64 val;
+	u64 val = -EINVAL;
 
 	/*
 	 * Disabling interrupts avoids all counter scheduling (context
@@ -3267,12 +3267,14 @@ u64 perf_event_read_local(struct perf_event *event)
 	local_irq_save(flags);
 
 	/* If this is a per-task event, it must be for current */
-	WARN_ON_ONCE((event->attach_state & PERF_ATTACH_TASK) &&
-		     event->hw.target != current);
+	if ((event->attach_state & PERF_ATTACH_TASK) &&
+	    event->hw.target != current)
+		goto out;
 
 	/* If this is a per-CPU event, it must be for this CPU */
-	WARN_ON_ONCE(!(event->attach_state & PERF_ATTACH_TASK) &&
-		     event->cpu != smp_processor_id());
+	if (!(event->attach_state & PERF_ATTACH_TASK) &&
+	    event->cpu != smp_processor_id())
+		goto out;
 
 	/*
 	 * It must not be an event with inherit set, we cannot read
@@ -3295,6 +3297,7 @@ u64 perf_event_read_local(struct perf_event *event)
 		event->pmu->read(event);
 
 	val = local64_read(&event->count);
+out:
 	local_irq_restore(flags);
 
 	return val;
-- 
1.7.9.5
