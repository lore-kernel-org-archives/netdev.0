From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v2 net-next 6/7] bpf: allow eBPF programs to use maps
Date: Thu, 13 Nov 2014 17:36:49 -0800
Message-ID: <1415929010-9361-7-git-send-email-ast@plumgrid.com>
References: <1415929010-9361-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415929010-9361-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

expose bpf_map_lookup_elem(), bpf_map_update_elem(), bpf_map_delete_elem()
map accessors to eBPF programs

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
Note, these helpers are exposed as '.gpl_only = false', so non-GPL eBPF programs
can use them. That was requested by AndyL and DavidL before.

 include/linux/bpf.h      |    5 +++
 include/uapi/linux/bpf.h |    3 ++
 kernel/bpf/Makefile      |    2 +-
 kernel/bpf/helpers.c     |   89 ++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 98 insertions(+), 1 deletion(-)
 create mode 100644 kernel/bpf/helpers.c

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 51e9242e4803..75e94eaa228b 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -133,4 +133,9 @@ struct bpf_prog *bpf_prog_get(u32 ufd);
 /* verify correctness of eBPF program */
 int bpf_check(struct bpf_prog *fp, union bpf_attr *attr);
 
+/* verifier prototypes for helper functions called from eBPF programs */
+extern struct bpf_func_proto bpf_map_lookup_elem_proto;
+extern struct bpf_func_proto bpf_map_update_elem_proto;
+extern struct bpf_func_proto bpf_map_delete_elem_proto;
+
 #endif /* _LINUX_BPF_H */
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 0d662fe75df5..4a3d0f84f178 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -158,6 +158,9 @@ union bpf_attr {
  */
 enum bpf_func_id {
 	BPF_FUNC_unspec,
+	BPF_FUNC_map_lookup_elem, /* void *map_lookup_elem(&map, &key) */
+	BPF_FUNC_map_update_elem, /* int map_update_elem(&map, &key, &value, flags) */
+	BPF_FUNC_map_delete_elem, /* int map_delete_elem(&map, &key) */
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/kernel/bpf/Makefile b/kernel/bpf/Makefile
index 72ec98ba2d42..a5ae60f0b0a2 100644
--- a/kernel/bpf/Makefile
+++ b/kernel/bpf/Makefile
@@ -1,5 +1,5 @@
 obj-y := core.o
-obj-$(CONFIG_BPF_SYSCALL) += syscall.o verifier.o hashtab.o arraymap.o
+obj-$(CONFIG_BPF_SYSCALL) += syscall.o verifier.o hashtab.o arraymap.o helpers.o
 ifdef CONFIG_TEST_BPF
 obj-$(CONFIG_BPF_SYSCALL) += test_stub.o
 endif
diff --git a/kernel/bpf/helpers.c b/kernel/bpf/helpers.c
new file mode 100644
index 000000000000..9e3414d85459
--- /dev/null
+++ b/kernel/bpf/helpers.c
@@ -0,0 +1,89 @@
+/* Copyright (c) 2011-2014 PLUMgrid, http://plumgrid.com
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ */
+#include <linux/bpf.h>
+#include <linux/rcupdate.h>
+
+/* If kernel subsystem is allowing eBPF programs to call this function,
+ * inside its own verifier_ops->get_func_proto() callback it should return
+ * bpf_map_lookup_elem_proto, so that verifier can properly check the arguments
+ *
+ * Different map implementations will rely on rcu in map methods
+ * lookup/update/delete, therefore eBPF programs must run under rcu lock
+ * if program is allowed to access maps, so check rcu_read_lock_held in
+ * all three functions.
+ */
+static u64 bpf_map_lookup_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	/* verifier checked that R1 contains a valid pointer to bpf_map
+	 * and R2 points to a program stack and map->key_size bytes were
+	 * initialized
+	 */
+	struct bpf_map *map = (struct bpf_map *) (unsigned long) r1;
+	void *key = (void *) (unsigned long) r2;
+	void *value;
+
+	WARN_ON_ONCE(!rcu_read_lock_held());
+
+	value = map->ops->map_lookup_elem(map, key);
+
+	/* lookup() returns either pointer to element value or NULL
+	 * which is the meaning of PTR_TO_MAP_VALUE_OR_NULL type
+	 */
+	return (unsigned long) value;
+}
+
+struct bpf_func_proto bpf_map_lookup_elem_proto = {
+	.func = bpf_map_lookup_elem,
+	.gpl_only = false,
+	.ret_type = RET_PTR_TO_MAP_VALUE_OR_NULL,
+	.arg1_type = ARG_CONST_MAP_PTR,
+	.arg2_type = ARG_PTR_TO_MAP_KEY,
+};
+
+static u64 bpf_map_update_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	struct bpf_map *map = (struct bpf_map *) (unsigned long) r1;
+	void *key = (void *) (unsigned long) r2;
+	void *value = (void *) (unsigned long) r3;
+
+	WARN_ON_ONCE(!rcu_read_lock_held());
+
+	return map->ops->map_update_elem(map, key, value, r4);
+}
+
+struct bpf_func_proto bpf_map_update_elem_proto = {
+	.func = bpf_map_update_elem,
+	.gpl_only = false,
+	.ret_type = RET_INTEGER,
+	.arg1_type = ARG_CONST_MAP_PTR,
+	.arg2_type = ARG_PTR_TO_MAP_KEY,
+	.arg3_type = ARG_PTR_TO_MAP_VALUE,
+	.arg4_type = ARG_ANYTHING,
+};
+
+static u64 bpf_map_delete_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	struct bpf_map *map = (struct bpf_map *) (unsigned long) r1;
+	void *key = (void *) (unsigned long) r2;
+
+	WARN_ON_ONCE(!rcu_read_lock_held());
+
+	return map->ops->map_delete_elem(map, key);
+}
+
+struct bpf_func_proto bpf_map_delete_elem_proto = {
+	.func = bpf_map_delete_elem,
+	.gpl_only = false,
+	.ret_type = RET_INTEGER,
+	.arg1_type = ARG_CONST_MAP_PTR,
+	.arg2_type = ARG_PTR_TO_MAP_KEY,
+};
-- 
1.7.9.5
