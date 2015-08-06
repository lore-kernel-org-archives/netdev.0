From: Kaixu Xia <xiakaixu@huawei.com>
Subject: [PATCH v7 1/5] perf: add the necessary core perf APIs when accessing events counters in eBPF programs
Date: Thu, 6 Aug 2015 07:02:32 +0000
Message-ID: <1438844556-27064-2-git-send-email-xiakaixu@huawei.com>
References: <1438844556-27064-1-git-send-email-xiakaixu@huawei.com>
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
In-Reply-To: <1438844556-27064-1-git-send-email-xiakaixu@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch add three core perf APIs:
 - perf_event_attrs(): export the struct perf_event_attr from struct
   perf_event;
 - perf_event_get(): get the struct perf_event from the given fd;
 - perf_event_read_local(): read the events counters active on the
   current CPU;
These APIs are needed when accessing events counters in eBPF programs.

The API perf_event_read_local() comes from Peter and I add the
corresponding SOB. 

Signed-off-by: Kaixu Xia <xiakaixu@huawei.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/perf_event.h | 10 ++++++
 kernel/events/core.c       | 78 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 88 insertions(+)

diff --git a/include/linux/perf_event.h b/include/linux/perf_event.h
index 2027809..092a0e8 100644
--- a/include/linux/perf_event.h
+++ b/include/linux/perf_event.h
@@ -641,6 +641,8 @@ extern int perf_event_init_task(struct task_struct *child);
 extern void perf_event_exit_task(struct task_struct *child);
 extern void perf_event_free_task(struct task_struct *task);
 extern void perf_event_delayed_put(struct task_struct *task);
+extern struct perf_event *perf_event_get(unsigned int fd);
+extern const struct perf_event_attr *perf_event_attrs(struct perf_event *event);
 extern void perf_event_print_debug(void);
 extern void perf_pmu_disable(struct pmu *pmu);
 extern void perf_pmu_enable(struct pmu *pmu);
@@ -659,6 +661,7 @@ perf_event_create_kernel_counter(struct perf_event_attr *attr,
 				void *context);
 extern void perf_pmu_migrate_context(struct pmu *pmu,
 				int src_cpu, int dst_cpu);
+extern u64 perf_event_read_local(struct perf_event *event);
 extern u64 perf_event_read_value(struct perf_event *event,
 				 u64 *enabled, u64 *running);
 
@@ -979,6 +982,12 @@ static inline int perf_event_init_task(struct task_struct *child)	{ return 0; }
 static inline void perf_event_exit_task(struct task_struct *child)	{ }
 static inline void perf_event_free_task(struct task_struct *task)	{ }
 static inline void perf_event_delayed_put(struct task_struct *task)	{ }
+static inline struct perf_event *perf_event_get(unsigned int fd)	{ return ERR_PTR(-EINVAL); }
+static inline const struct perf_event_attr *perf_event_attrs(struct perf_event *event)
+{
+	return ERR_PTR(-EINVAL);
+}
+static inline u64 perf_event_read_local(struct perf_event *event)	{ return -EINVAL; }
 static inline void perf_event_print_debug(void)				{ }
 static inline int perf_event_task_disable(void)				{ return -EINVAL; }
 static inline int perf_event_task_enable(void)				{ return -EINVAL; }
@@ -1011,6 +1020,7 @@ static inline void perf_event_enable(struct perf_event *event)		{ }
 static inline void perf_event_disable(struct perf_event *event)		{ }
 static inline int __perf_event_disable(void *info)			{ return -1; }
 static inline void perf_event_task_tick(void)				{ }
+static inline int perf_event_release_kernel(struct perf_event *event)	{ return 0; }
 #endif
 
 #if defined(CONFIG_PERF_EVENTS) && defined(CONFIG_NO_HZ_FULL)
diff --git a/kernel/events/core.c b/kernel/events/core.c
index d3dae34..e2c6a88 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -3212,6 +3212,59 @@ static inline u64 perf_event_count(struct perf_event *event)
 	return __perf_event_count(event);
 }
 
+/*
+ * NMI-safe method to read a local event, that is an event that
+ * is:
+ *   - either for the current task, or for this CPU
+ *   - does not have inherit set, for inherited task events
+ *     will not be local and we cannot read them atomically
+ *   - must not have a pmu::count method
+ */
+u64 perf_event_read_local(struct perf_event *event)
+{
+	unsigned long flags;
+	u64 val;
+
+	/*
+	 * Disabling interrupts avoids all counter scheduling (context
+	 * switches, timer based rotation and IPIs).
+	 */
+	local_irq_save(flags);
+
+	/* If this is a per-task event, it must be for current */
+	WARN_ON_ONCE((event->attach_state & PERF_ATTACH_TASK) &&
+		     event->hw.target != current);
+
+	/* If this is a per-CPU event, it must be for this CPU */
+	WARN_ON_ONCE(!(event->attach_state & PERF_ATTACH_TASK) &&
+		     event->cpu != smp_processor_id());
+
+	/*
+	 * It must not be an event with inherit set, we cannot read
+	 * all child counters from atomic context.
+	 */
+	WARN_ON_ONCE(event->attr.inherit);
+
+	/*
+	 * It must not have a pmu::count method, those are not
+	 * NMI safe.
+	 */
+	WARN_ON_ONCE(event->pmu->count);
+
+	/*
+	 * If the event is currently on this CPU, its either a per-task event,
+	 * or local to this CPU. Furthermore it means its ACTIVE (otherwise
+	 * oncpu == -1).
+	 */
+	if (event->oncpu == smp_processor_id())
+		event->pmu->read(event);
+
+	val = local64_read(&event->count);
+	local_irq_restore(flags);
+
+	return val;
+}
+
 static u64 perf_event_read(struct perf_event *event)
 {
 	/*
@@ -8574,6 +8627,31 @@ void perf_event_delayed_put(struct task_struct *task)
 		WARN_ON_ONCE(task->perf_event_ctxp[ctxn]);
 }
 
+struct perf_event *perf_event_get(unsigned int fd)
+{
+	int err;
+	struct fd f;
+	struct perf_event *event;
+
+	err = perf_fget_light(fd, &f);
+	if (err)
+		return ERR_PTR(err);
+
+	event = f.file->private_data;
+	atomic_long_inc(&event->refcount);
+	fdput(f);
+
+	return event;
+}
+
+const struct perf_event_attr *perf_event_attrs(struct perf_event *event)
+{
+	if (!event)
+		return ERR_PTR(-EINVAL);
+
+	return &event->attr;
+}
+
 /*
  * inherit a event from parent task to child task:
  */
-- 
1.8.3.4
