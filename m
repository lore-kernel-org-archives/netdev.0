From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH v3 net-next 1/3] perf, bpf: Add BPF support to all perf_event types
Date: Thu, 1 Jun 2017 19:03:34 -0700
Message-ID: <20170602020336.1062853-2-ast@fb.com>
References: <20170602020336.1062853-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Zijlstra <peterz@infradead.org>,
        Brendan Gregg <bgregg@netflix.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Teng Qin <qinteng@fb.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170602020336.1062853-1-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow BPF_PROG_TYPE_PERF_EVENT program types to attach to all
perf_event types, including HW_CACHE, RAW, and dynamic pmu events.
Only tracepoint/kprobe events are treated differently which require
BPF_PROG_TYPE_TRACEPOINT/BPF_PROG_TYPE_KPROBE program types accordingly.

Also add support for reading all event counters using
bpf_perf_event_read() helper.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/perf_event.h |  7 +++++--
 kernel/bpf/arraymap.c      | 29 ++++------------------------
 kernel/events/core.c       | 47 +++++++++++++++++++++++++++-------------------
 kernel/trace/bpf_trace.c   | 21 ++++++++-------------
 4 files changed, 45 insertions(+), 59 deletions(-)

diff --git a/include/linux/perf_event.h b/include/linux/perf_event.h
index 24a635887f28..8fc5f0fada5e 100644
--- a/include/linux/perf_event.h
+++ b/include/linux/perf_event.h
@@ -896,7 +896,7 @@ perf_event_create_kernel_counter(struct perf_event_attr *attr,
 				void *context);
 extern void perf_pmu_migrate_context(struct pmu *pmu,
 				int src_cpu, int dst_cpu);
-extern u64 perf_event_read_local(struct perf_event *event);
+int perf_event_read_local(struct perf_event *event, u64 *value);
 extern u64 perf_event_read_value(struct perf_event *event,
 				 u64 *enabled, u64 *running);
 
@@ -1301,7 +1301,10 @@ static inline const struct perf_event_attr *perf_event_attrs(struct perf_event *
 {
 	return ERR_PTR(-EINVAL);
 }
-static inline u64 perf_event_read_local(struct perf_event *event)	{ return -EINVAL; }
+static inline int perf_event_read_local(struct perf_event *event, u64 *value)
+{
+	return -EINVAL;
+}
 static inline void perf_event_print_debug(void)				{ }
 static inline int perf_event_task_disable(void)				{ return -EINVAL; }
 static inline int perf_event_task_enable(void)				{ return -EINVAL; }
diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index 172dc8ee0e3b..ab93490d1a00 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -452,39 +452,18 @@ static void bpf_event_entry_free_rcu(struct bpf_event_entry *ee)
 static void *perf_event_fd_array_get_ptr(struct bpf_map *map,
 					 struct file *map_file, int fd)
 {
-	const struct perf_event_attr *attr;
 	struct bpf_event_entry *ee;
-	struct perf_event *event;
 	struct file *perf_file;
 
 	perf_file = perf_event_get(fd);
 	if (IS_ERR(perf_file))
 		return perf_file;
 
-	event = perf_file->private_data;
-	ee = ERR_PTR(-EINVAL);
-
-	attr = perf_event_attrs(event);
-	if (IS_ERR(attr) || attr->inherit)
-		goto err_out;
-
-	switch (attr->type) {
-	case PERF_TYPE_SOFTWARE:
-		if (attr->config != PERF_COUNT_SW_BPF_OUTPUT)
-			goto err_out;
-		/* fall-through */
-	case PERF_TYPE_RAW:
-	case PERF_TYPE_HARDWARE:
-		ee = bpf_event_entry_gen(perf_file, map_file);
-		if (ee)
-			return ee;
-		ee = ERR_PTR(-ENOMEM);
-		/* fall-through */
-	default:
-		break;
-	}
+	ee = bpf_event_entry_gen(perf_file, map_file);
+	if (ee)
+		return ee;
 
-err_out:
+	ee = ERR_PTR(-ENOMEM);
 	fput(perf_file);
 	return ee;
 }
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 6e75a5c9412d..51e40e4876c0 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -3636,10 +3636,10 @@ static inline u64 perf_event_count(struct perf_event *event)
  *     will not be local and we cannot read them atomically
  *   - must not have a pmu::count method
  */
-u64 perf_event_read_local(struct perf_event *event)
+int perf_event_read_local(struct perf_event *event, u64 *value)
 {
 	unsigned long flags;
-	u64 val;
+	int ret = 0;
 
 	/*
 	 * Disabling interrupts avoids all counter scheduling (context
@@ -3647,25 +3647,37 @@ u64 perf_event_read_local(struct perf_event *event)
 	 */
 	local_irq_save(flags);
 
-	/* If this is a per-task event, it must be for current */
-	WARN_ON_ONCE((event->attach_state & PERF_ATTACH_TASK) &&
-		     event->hw.target != current);
-
-	/* If this is a per-CPU event, it must be for this CPU */
-	WARN_ON_ONCE(!(event->attach_state & PERF_ATTACH_TASK) &&
-		     event->cpu != smp_processor_id());
-
 	/*
 	 * It must not be an event with inherit set, we cannot read
 	 * all child counters from atomic context.
 	 */
-	WARN_ON_ONCE(event->attr.inherit);
+	if (event->attr.inherit) {
+		ret = -EOPNOTSUPP;
+		goto out;
+	}
 
 	/*
 	 * It must not have a pmu::count method, those are not
 	 * NMI safe.
 	 */
-	WARN_ON_ONCE(event->pmu->count);
+	if (event->pmu->count) {
+		ret = -EOPNOTSUPP;
+		goto out;
+	}
+
+	/* If this is a per-task event, it must be for current */
+	if ((event->attach_state & PERF_ATTACH_TASK) &&
+	    event->hw.target != current) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	/* If this is a per-CPU event, it must be for this CPU */
+	if (!(event->attach_state & PERF_ATTACH_TASK) &&
+	    event->cpu != smp_processor_id()) {
+		ret = -EINVAL;
+		goto out;
+	}
 
 	/*
 	 * If the event is currently on this CPU, its either a per-task event,
@@ -3675,10 +3687,11 @@ u64 perf_event_read_local(struct perf_event *event)
 	if (event->oncpu == smp_processor_id())
 		event->pmu->read(event);
 
-	val = local64_read(&event->count);
+	*value = local64_read(&event->count);
+out:
 	local_irq_restore(flags);
 
-	return val;
+	return ret;
 }
 
 static int perf_event_read(struct perf_event *event, bool group)
@@ -8037,12 +8050,8 @@ static int perf_event_set_bpf_prog(struct perf_event *event, u32 prog_fd)
 	bool is_kprobe, is_tracepoint;
 	struct bpf_prog *prog;
 
-	if (event->attr.type == PERF_TYPE_HARDWARE ||
-	    event->attr.type == PERF_TYPE_SOFTWARE)
-		return perf_event_set_bpf_handler(event, prog_fd);
-
 	if (event->attr.type != PERF_TYPE_TRACEPOINT)
-		return -EINVAL;
+		return perf_event_set_bpf_handler(event, prog_fd);
 
 	if (event->tp_event->prog)
 		return -EEXIST;
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 460a031c77e5..957ab2d35d7b 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -235,6 +235,8 @@ BPF_CALL_2(bpf_perf_event_read, struct bpf_map *, map, u64, flags)
 	u64 index = flags & BPF_F_INDEX_MASK;
 	struct bpf_event_entry *ee;
 	struct perf_event *event;
+	u64 value = 0;
+	int err;
 
 	if (unlikely(flags & ~(BPF_F_INDEX_MASK)))
 		return -EINVAL;
@@ -247,21 +249,14 @@ BPF_CALL_2(bpf_perf_event_read, struct bpf_map *, map, u64, flags)
 	if (!ee)
 		return -ENOENT;
 
-	event = ee->event;
-	if (unlikely(event->attr.type != PERF_TYPE_HARDWARE &&
-		     event->attr.type != PERF_TYPE_RAW))
-		return -EINVAL;
-
-	/* make sure event is local and doesn't have pmu::count */
-	if (unlikely(event->oncpu != cpu || event->pmu->count))
-		return -EINVAL;
-
+	err = perf_event_read_local(ee->event, &value);
 	/*
-	 * we don't know if the function is run successfully by the
-	 * return value. It can be judged in other places, such as
-	 * eBPF programs.
+	 * this api is ugly since we miss [-95..-2] range of valid
+	 * counter values, but that's uapi
 	 */
-	return perf_event_read_local(event);
+	if (err)
+		return err;
+	return value;
 }
 
 static const struct bpf_func_proto bpf_perf_event_read_proto = {
-- 
2.9.3
