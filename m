From: Kaixu Xia <xiakaixu@huawei.com>
Subject: [PATCH v7 3/5] bpf: Add new bpf map type to store the pointer to struct perf_event
Date: Thu, 6 Aug 2015 07:02:34 +0000
Message-ID: <1438844556-27064-4-git-send-email-xiakaixu@huawei.com>
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

Introduce a new bpf map type 'BPF_MAP_TYPE_PERF_EVENT_ARRAY'.
This map only stores the pointer to struct perf_event. The
user space event FDs from perf_event_open() syscall are converted
to the pointer to struct perf_event and stored in map.

Signed-off-by: Kaixu Xia <xiakaixu@huawei.com>
---
 include/linux/bpf.h      |  1 +
 include/uapi/linux/bpf.h |  1 +
 kernel/bpf/arraymap.c    | 57 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 59 insertions(+)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index d495211..4fc1f40 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -10,6 +10,7 @@
 #include <uapi/linux/bpf.h>
 #include <linux/workqueue.h>
 #include <linux/file.h>
+#include <linux/perf_event.h>
 
 struct bpf_map;
 
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 2ce13c1..a1814e8 100644
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
index 45df657..29ace10 100644
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
+	const struct perf_event_attr *attr;
+
+	event = perf_event_get(fd);
+	if (IS_ERR(event))
+		return event;
+
+	attr = perf_event_attrs(event);
+	if (IS_ERR(attr))
+		return (void *)attr;
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
-- 
1.8.3.4
