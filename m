From: Martin KaFai Lau <kafai-b10kYP2dOMg@public.gmane.org>
Subject: [PATCH net-next v2 2/4] cgroup: bpf: Add BPF_MAP_TYPE_CGROUP_ARRAY
Date: Wed, 22 Jun 2016 14:17:30 -0700
Message-ID: <1466630252-3822277-3-git-send-email-kafai@fb.com>
References: <1466630252-3822277-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <kernel-team-b10kYP2dOMg@public.gmane.org>
To: <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1466630252-3822277-1-git-send-email-kafai-b10kYP2dOMg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add a BPF_MAP_TYPE_CGROUP_ARRAY and its bpf_map_ops's implementations.
To update an element, the caller is expected to obtain a cgroup2 backed
fd by open(cgroup2_dir) and then update the array with that fd.

Signed-off-by: Martin KaFai Lau <kafai-b10kYP2dOMg@public.gmane.org>
Cc: Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>
Cc: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Acked-by: Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/uapi/linux/bpf.h |  1 +
 kernel/bpf/arraymap.c    | 43 +++++++++++++++++++++++++++++++++++++++++++
 kernel/bpf/syscall.c     |  3 ++-
 3 files changed, 46 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 406459b..ef4e386 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -84,6 +84,7 @@ enum bpf_map_type {
 	BPF_MAP_TYPE_PERCPU_HASH,
 	BPF_MAP_TYPE_PERCPU_ARRAY,
 	BPF_MAP_TYPE_STACK_TRACE,
+	BPF_MAP_TYPE_CGROUP_ARRAY,
 };
 
 enum bpf_prog_type {
diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index 5af3073..aacd40b 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -539,3 +539,46 @@ static int __init register_perf_event_array_map(void)
 	return 0;
 }
 late_initcall(register_perf_event_array_map);
+
+#ifdef CONFIG_CGROUPS
+static void *cgroup_fd_array_get_ptr(struct bpf_map *map,
+				     struct file *map_file /* not used */,
+				     int fd)
+{
+	return cgroup_get_from_fd(fd);
+}
+
+static void cgroup_fd_array_put_ptr(void *ptr)
+{
+	/* cgroup_put free cgrp after a rcu grace period */
+	cgroup_put(ptr);
+}
+
+static void cgroup_fd_array_free(struct bpf_map *map)
+{
+	bpf_fd_array_map_clear(map);
+	fd_array_map_free(map);
+}
+
+static const struct bpf_map_ops cgroup_array_ops = {
+	.map_alloc = fd_array_map_alloc,
+	.map_free = cgroup_fd_array_free,
+	.map_get_next_key = array_map_get_next_key,
+	.map_lookup_elem = fd_array_map_lookup_elem,
+	.map_delete_elem = fd_array_map_delete_elem,
+	.map_fd_get_ptr = cgroup_fd_array_get_ptr,
+	.map_fd_put_ptr = cgroup_fd_array_put_ptr,
+};
+
+static struct bpf_map_type_list cgroup_array_type __read_mostly = {
+	.ops = &cgroup_array_ops,
+	.type = BPF_MAP_TYPE_CGROUP_ARRAY,
+};
+
+static int __init register_cgroup_array_map(void)
+{
+	bpf_register_map_type(&cgroup_array_type);
+	return 0;
+}
+late_initcall(register_cgroup_array_map);
+#endif
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index c23a4e93..cac13f1 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -393,7 +393,8 @@ static int map_update_elem(union bpf_attr *attr)
 	} else if (map->map_type == BPF_MAP_TYPE_PERCPU_ARRAY) {
 		err = bpf_percpu_array_update(map, key, value, attr->flags);
 	} else if (map->map_type == BPF_MAP_TYPE_PERF_EVENT_ARRAY ||
-		   map->map_type == BPF_MAP_TYPE_PROG_ARRAY) {
+		   map->map_type == BPF_MAP_TYPE_PROG_ARRAY ||
+		   map->map_type == BPF_MAP_TYPE_CGROUP_ARRAY) {
 		rcu_read_lock();
 		err = bpf_fd_array_map_update_elem(map, f.file, key, value,
 						   attr->flags);
-- 
2.5.1
