From: Kaixu Xia <xiakaixu@huawei.com>
Subject: [RFC PATCH 1/2] perf: Add the flag sample_disable not to output data on samples
Date: Mon, 12 Oct 2015 09:02:42 +0000
Message-ID: <1444640563-159175-2-git-send-email-xiakaixu@huawei.com>
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

In some scenarios we don't want to output trace data when sampling
to reduce overhead. This patch adds the flag sample_disable to
implement this function. By setting this flag and integrating with
ebpf, we can control the data output process and get the samples we
are most interested in.

Signed-off-by: Kaixu Xia <xiakaixu@huawei.com>
---
 include/linux/bpf.h        | 1 +
 include/linux/perf_event.h | 2 ++
 kernel/bpf/arraymap.c      | 5 +++++
 kernel/events/core.c       | 3 +++
 4 files changed, 11 insertions(+)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index f57d7fe..25e073d 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -39,6 +39,7 @@ struct bpf_map {
 	u32 max_entries;
 	const struct bpf_map_ops *ops;
 	struct work_struct work;
+	atomic_t perf_sample_disable;
 };
 
 struct bpf_map_type_list {
diff --git a/include/linux/perf_event.h b/include/linux/perf_event.h
index 092a0e8..0606d1d 100644
--- a/include/linux/perf_event.h
+++ b/include/linux/perf_event.h
@@ -483,6 +483,8 @@ struct perf_event {
 	perf_overflow_handler_t		overflow_handler;
 	void				*overflow_handler_context;
 
+	atomic_t			*sample_disable;
+
 #ifdef CONFIG_EVENT_TRACING
 	struct trace_event_call		*tp_event;
 	struct event_filter		*filter;
diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index 29ace10..4ae82c9 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -51,6 +51,9 @@ static struct bpf_map *array_map_alloc(union bpf_attr *attr)
 
 	array->elem_size = elem_size;
 
+	if (attr->map_type == BPF_MAP_TYPE_PERF_EVENT_ARRAY)
+		atomic_set(&array->map.perf_sample_disable, 1);
+
 	return &array->map;
 }
 
@@ -298,6 +301,8 @@ static void *perf_event_fd_array_get_ptr(struct bpf_map *map, int fd)
 		perf_event_release_kernel(event);
 		return ERR_PTR(-EINVAL);
 	}
+
+	event->sample_disable = &map->perf_sample_disable;
 	return event;
 }
 
diff --git a/kernel/events/core.c b/kernel/events/core.c
index b11756f..f6ef45c 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -6337,6 +6337,9 @@ static int __perf_event_overflow(struct perf_event *event,
 		irq_work_queue(&event->pending);
 	}
 
+	if ((event->sample_disable) && atomic_read(event->sample_disable))
+		return ret;
+
 	if (event->overflow_handler)
 		event->overflow_handler(event, data, regs);
 	else
-- 
1.8.3.4
