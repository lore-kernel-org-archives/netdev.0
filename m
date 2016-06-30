From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next v3 2/4] cgroup: bpf: Add BPF_MAP_TYPE_CGROUP_ARRAY
Date: Thu, 30 Jun 2016 10:28:43 -0700
Message-ID: <1467307725-1948415-3-git-send-email-kafai@fb.com>
References: <1467307725-1948415-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tejun Heo <tj@kernel.org>, <kernel-team@fb.com>
To: <cgroups@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467307725-1948415-1-git-send-email-kafai@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a BPF_MAP_TYPE_CGROUP_ARRAY and its bpf_map_ops's implementations.
To update an element, the caller is expected to obtain a cgroup2 backed
fd by open(cgroup2_dir) and then update the array with that fd.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Alexei Starovoitov <ast@fb.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Tejun Heo <tj@kernel.org>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/uapi/linux/bpf.h |  1 +
 kernel/bpf/arraymap.c    | 43 +++++++++++++++++++++++++++++++++++++++++++
 kernel/bpf/syscall.c     |  3 ++-
 kernel/bpf/verifier.c    |  2 ++
 4 files changed, 48 insertions(+), 1 deletion(-)

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
index 5af3073..588d66e 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -539,3 +539,46 @@ static int __init register_perf_event_array_map(void)
 	return 0;
 }
 late_initcall(register_perf_event_array_map);
+
+#ifdef CONFIG_SOCK_CGROUP_DATA
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
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 668e079..0f6db58 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1062,6 +1062,8 @@ static int check_map_func_compatibility(struct bpf_map *map, int func_id)
 		if (func_id != BPF_FUNC_get_stackid)
 			goto error;
 		break;
+	case BPF_MAP_TYPE_CGROUP_ARRAY:
+		goto error;
 	default:
 		break;
 	}
-- 
2.5.1
