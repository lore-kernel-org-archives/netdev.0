From: Kaixu Xia <xiakaixu@huawei.com>
Subject: [PATCH v6 2/4] bpf: Add new bpf map type to store the pointer to struct perf_event
Date: Tue, 4 Aug 2015 08:58:14 +0000
Message-ID: <1438678696-88289-3-git-send-email-xiakaixu@huawei.com>
References: <1438678696-88289-1-git-send-email-xiakaixu@huawei.com>
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
In-Reply-To: <1438678696-88289-1-git-send-email-xiakaixu@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Introduce a new bpf map type 'BPF_MAP_TYPE_PERF_EVENT_ARRAY'.
This map only stores the pointer to struct perf_event. The
user space event FDs from perf_event_open() syscall are converted
to the pointer to struct perf_event and stored in map.

Signed-off-by: Kaixu Xia <xiakaixu@huawei.com>
---
 include/linux/bpf.h        |  1 +
 include/linux/perf_event.h |  8 +++++++
 include/uapi/linux/bpf.h   |  1 +
 kernel/bpf/arraymap.c      | 57 ++++++++++++++++++++++++++++++++++++++++++++++
 kernel/events/core.c       | 25 ++++++++++++++++++++
 5 files changed, 92 insertions(+)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index a8ce262..d0b394a 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -10,6 +10,7 @@
 #include <uapi/linux/bpf.h>
 #include <linux/workqueue.h>
 #include <linux/file.h>
+#include <linux/perf_event.h>
 
 struct bpf_map;
 
diff --git a/include/linux/perf_event.h b/include/linux/perf_event.h
index 2027809..81fc99e 100644
--- a/include/linux/perf_event.h
+++ b/include/linux/perf_event.h
@@ -641,6 +641,8 @@ extern int perf_event_init_task(struct task_struct *child);
 extern void perf_event_exit_task(struct task_struct *child);
 extern void perf_event_free_task(struct task_struct *task);
 extern void perf_event_delayed_put(struct task_struct *task);
+extern struct perf_event *perf_event_get(unsigned int fd);
+extern struct perf_event_attr *perf_event_attrs(struct perf_event *event);
 extern void perf_event_print_debug(void);
 extern void perf_pmu_disable(struct pmu *pmu);
 extern void perf_pmu_enable(struct pmu *pmu);
@@ -979,6 +981,11 @@ static inline int perf_event_init_task(struct task_struct *child)	{ return 0; }
 static inline void perf_event_exit_task(struct task_struct *child)	{ }
 static inline void perf_event_free_task(struct task_struct *task)	{ }
 static inline void perf_event_delayed_put(struct task_struct *task)	{ }
+static inline struct perf_event *perf_event_get(unsigned int fd)	{ return ERR_PTR(-EINVAL); }
+static inline struct perf_event_attr *perf_event_attrs(struct perf_event *event)
+{
+	return ERR_PTR(-EINVAL);
+}
 static inline void perf_event_print_debug(void)				{ }
 static inline int perf_event_task_disable(void)				{ return -EINVAL; }
 static inline int perf_event_task_enable(void)				{ return -EINVAL; }
@@ -1011,6 +1018,7 @@ static inline void perf_event_enable(struct perf_event *event)		{ }
 static inline void perf_event_disable(struct perf_event *event)		{ }
 static inline int __perf_event_disable(void *info)			{ return -1; }
 static inline void perf_event_task_tick(void)				{ }
+static inline int perf_event_release_kernel(struct perf_event *event)	{ return 0; }
 #endif
 
 #if defined(CONFIG_PERF_EVENTS) && defined(CONFIG_NO_HZ_FULL)
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 29ef6f9..69a1f6b 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -114,6 +114,7 @@ enum bpf_map_type {
 	BPF_MAP_TYPE_HASH,
 	BPF_MAP_TYPE_ARRAY,
 	BPF_MAP_TYPE_PROG_ARRAY,
+	BPF_MAP_TYPE_PERF_EVENT_ARRAY,
 };
 
 enum bpf_prog_type {
diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index 45df657..b1e98ff 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -273,3 +273,60 @@ static int __init register_prog_array_map(void)
 	return 0;
 }
 late_initcall(register_prog_array_map);
+
+static void perf_event_array_map_free(struct bpf_map *map)
+{
+	bpf_fd_array_map_clear(map);
+	fd_array_map_free(map);
+}
+
+static void *perf_event_fd_array_get_ptr(struct bpf_map *map, int fd)
+{
+	struct perf_event *event;
+	struct perf_event_attr *attr;
+
+	event = perf_event_get(fd);
+	if (IS_ERR(event))
+		return event;
+
+	attr = perf_event_attrs(event);
+	if (IS_ERR(attr))
+		return attr;
+
+	if (attr->type != PERF_TYPE_RAW &&
+	    attr->type != PERF_TYPE_HARDWARE) {
+		perf_event_release_kernel(event);
+		return ERR_PTR(-EINVAL);
+	}
+	return event;
+}
+
+static void perf_event_fd_array_put_ptr(void *ptr)
+{
+	struct perf_event *event = ptr;
+
+	perf_event_release_kernel(event);
+}
+
+static const struct bpf_map_ops perf_event_array_ops = {
+	.map_alloc = fd_array_map_alloc,
+	.map_free = perf_event_array_map_free,
+	.map_get_next_key = array_map_get_next_key,
+	.map_lookup_elem = fd_array_map_lookup_elem,
+	.map_update_elem = fd_array_map_update_elem,
+	.map_delete_elem = fd_array_map_delete_elem,
+	.map_fd_get_ptr = perf_event_fd_array_get_ptr,
+	.map_fd_put_ptr = perf_event_fd_array_put_ptr,
+};
+
+static struct bpf_map_type_list perf_event_array_type __read_mostly = {
+	.ops = &perf_event_array_ops,
+	.type = BPF_MAP_TYPE_PERF_EVENT_ARRAY,
+};
+
+static int __init register_perf_event_array_map(void)
+{
+	bpf_register_map_type(&perf_event_array_type);
+	return 0;
+}
+late_initcall(register_perf_event_array_map);
diff --git a/kernel/events/core.c b/kernel/events/core.c
index d3dae34..6251b53 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -8574,6 +8574,31 @@ void perf_event_delayed_put(struct task_struct *task)
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
+struct perf_event_attr *perf_event_attrs(struct perf_event *event)
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
