From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH RFC v4 net-next 03/26] bpf: introduce syscall(BPF, ...) and BPF maps
Date: Wed, 13 Aug 2014 00:57:14 -0700
Message-ID: <1407916658-8731-4-git-send-email-ast@plumgrid.com>
References: <1407916658-8731-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407916658-8731-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

BPF syscall is a demux for different BPF releated commands.

'maps' is a generic storage of different types for sharing data between kernel
and userspace.

The maps can be created from user space via BPF syscall:
- create a map with given type and attributes
  fd = bpf_map_create(map_type, struct nlattr *attr, int len)
  returns fd or negative error

- close(fd) deletes the map

Next patch allows userspace programs to populate/read maps that eBPF programs
are concurrently updating.

maps can have different types: hash, bloom filter, radix-tree, etc.

The map is defined by:
  . type
  . max number of elements
  . key size in bytes
  . value size in bytes

This patch establishes core infrastructure for BPF maps.
Next patches implement lookup/update and hashtable type.
More map types can be added in the future.

syscall is using type-length-value style of passing arguments to be backwards
compatible with future extensions to map attributes. Different map types may
use different attributes as well.
The concept of type-lenght-value is borrowed from netlink, but netlink itself
is not applicable here, since BPF programs and maps can be used in NET-less
configurations.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 Documentation/networking/filter.txt |   71 ++++++++++++++++
 include/linux/bpf.h                 |   42 ++++++++++
 include/uapi/linux/bpf.h            |   24 ++++++
 kernel/bpf/Makefile                 |    2 +-
 kernel/bpf/syscall.c                |  156 +++++++++++++++++++++++++++++++++++
 5 files changed, 294 insertions(+), 1 deletion(-)
 create mode 100644 include/linux/bpf.h
 create mode 100644 kernel/bpf/syscall.c

diff --git a/Documentation/networking/filter.txt b/Documentation/networking/filter.txt
index 81916ab5d96f..27a0a6c6acb4 100644
--- a/Documentation/networking/filter.txt
+++ b/Documentation/networking/filter.txt
@@ -1001,6 +1001,77 @@ instruction that loads 64-bit immediate value into a dst_reg.
 Classic BPF has similar instruction: BPF_LD | BPF_W | BPF_IMM which loads
 32-bit immediate value into a register.
 
+eBPF maps
+---------
+'maps' is a generic storage of different types for sharing data between kernel
+and userspace.
+
+The maps are accessed from user space via BPF syscall, which has commands:
+- create a map with given type and attributes
+  map_fd = bpf_map_create(map_type, struct nlattr *attr, int len)
+  returns process-local file descriptor or negative error
+
+- lookup key in a given map
+  err = bpf_map_lookup_elem(int fd, void *key, void *value)
+  returns zero and stores found elem into value or negative error
+
+- create or update key/value pair in a given map
+  err = bpf_map_update_elem(int fd, void *key, void *value)
+  returns zero or negative error
+
+- find and delete element by key in a given map
+  err = bpf_map_delete_elem(int fd, void *key)
+
+- to delete map: close(fd)
+  Exiting process will delete maps automatically
+
+userspace programs uses this API to create/populate/read maps that eBPF programs
+are concurrently updating.
+
+maps can have different types: hash, array, bloom filter, radix-tree, etc.
+
+The map is defined by:
+  . type
+  . max number of elements
+  . key size in bytes
+  . value size in bytes
+
+The maps are accesible from eBPF program with API:
+  void * bpf_map_lookup_elem(u32 map_fd, void *key);
+  int bpf_map_update_elem(u32 map_fd, void *key, void *value);
+  int bpf_map_delete_elem(u32 map_fd, void *key);
+
+The kernel replaces process-local map_fd with kernel internal map pointer,
+while loading eBPF program.
+
+If eBPF verifier is configured to recognize extra calls in the program
+bpf_map_lookup_elem() and bpf_map_update_elem() then access to maps looks like:
+  ...
+  ptr_to_value = bpf_map_lookup_elem(map_fd, key)
+  access memory range [ptr_to_value, ptr_to_value + value_size_in_bytes)
+  ...
+  prepare key2 and value2 on stack of key_size and value_size
+  err = bpf_map_update_elem(map_fd, key2, value2)
+  ...
+
+eBPF program cannot create or delete maps
+(such calls will be unknown to verifier)
+
+During program loading the refcnt of used maps is incremented, so they don't get
+deleted while program is running
+
+bpf_map_update_elem() can fail if maximum number of elements reached.
+if key2 already exists, bpf_map_update_elem() replaces it with value2 atomically
+
+bpf_map_lookup_elem() returns NULL or ptr_to_value, so program must do
+if (ptr_to_value != NULL) check before accessing it.
+NULL means that element with given 'key' was not found.
+
+The verifier will check that the program accesses map elements within specified
+size. It will not let programs pass junk values to bpf_map_*_elem() functions,
+so these functions (implemented in C inside kernel) can safely access
+the pointers in all cases.
+
 Testing
 -------
 
diff --git a/include/linux/bpf.h b/include/linux/bpf.h
new file mode 100644
index 000000000000..607ca53fe2af
--- /dev/null
+++ b/include/linux/bpf.h
@@ -0,0 +1,42 @@
+/* Copyright (c) 2011-2014 PLUMgrid, http://plumgrid.com
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#ifndef _LINUX_BPF_H
+#define _LINUX_BPF_H 1
+
+#include <uapi/linux/bpf.h>
+#include <linux/workqueue.h>
+
+struct bpf_map;
+struct nlattr;
+
+/* map is generic key/value storage optionally accesible by eBPF programs */
+struct bpf_map_ops {
+	/* funcs callable from userspace (via syscall) */
+	struct bpf_map *(*map_alloc)(struct nlattr *attrs[BPF_MAP_ATTR_MAX + 1]);
+	void (*map_free)(struct bpf_map *);
+};
+
+struct bpf_map {
+	atomic_t refcnt;
+	enum bpf_map_type map_type;
+	u32 key_size;
+	u32 value_size;
+	u32 max_entries;
+	struct bpf_map_ops *ops;
+	struct work_struct work;
+};
+
+struct bpf_map_type_list {
+	struct list_head list_node;
+	struct bpf_map_ops *ops;
+	enum bpf_map_type type;
+};
+
+void bpf_register_map_type(struct bpf_map_type_list *tl);
+void bpf_map_put(struct bpf_map *map);
+
+#endif /* _LINUX_BPF_H */
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 6f6e10875e95..88b703d59b8c 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -311,4 +311,28 @@ struct bpf_insn {
 	__s32	imm;		/* signed immediate constant */
 };
 
+/* BPF syscall commands */
+enum bpf_cmd {
+	/* create a map with given type and attributes
+	 * fd = bpf_map_create(bpf_map_type, struct nlattr *attr, int len)
+	 * returns fd or negative error
+	 * map is deleted when fd is closed
+	 */
+	BPF_MAP_CREATE,
+};
+
+enum bpf_map_attributes {
+	BPF_MAP_UNSPEC,
+	BPF_MAP_KEY_SIZE,	/* size of key in bytes */
+	BPF_MAP_VALUE_SIZE,	/* size of value in bytes */
+	BPF_MAP_MAX_ENTRIES,	/* maximum number of entries in a map */
+	__BPF_MAP_ATTR_MAX,
+};
+#define BPF_MAP_ATTR_MAX (__BPF_MAP_ATTR_MAX - 1)
+#define BPF_MAP_MAX_ATTR_SIZE 65535
+
+enum bpf_map_type {
+	BPF_MAP_TYPE_UNSPEC,
+};
+
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/kernel/bpf/Makefile b/kernel/bpf/Makefile
index 6a71145e2769..e9f7334ed07a 100644
--- a/kernel/bpf/Makefile
+++ b/kernel/bpf/Makefile
@@ -1 +1 @@
-obj-y := core.o
+obj-y := core.o syscall.o
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
new file mode 100644
index 000000000000..04cdf7948f8f
--- /dev/null
+++ b/kernel/bpf/syscall.c
@@ -0,0 +1,156 @@
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
+#include <linux/syscalls.h>
+#include <net/netlink.h>
+#include <linux/anon_inodes.h>
+
+static LIST_HEAD(bpf_map_types);
+
+static struct bpf_map *find_and_alloc_map(enum bpf_map_type type,
+					  struct nlattr *tb[BPF_MAP_ATTR_MAX + 1])
+{
+	struct bpf_map_type_list *tl;
+	struct bpf_map *map;
+
+	list_for_each_entry(tl, &bpf_map_types, list_node) {
+		if (tl->type == type) {
+			map = tl->ops->map_alloc(tb);
+			if (IS_ERR(map))
+				return map;
+			map->ops = tl->ops;
+			map->map_type = type;
+			return map;
+		}
+	}
+	return ERR_PTR(-EINVAL);
+}
+
+/* boot time registration of different map implementations */
+void bpf_register_map_type(struct bpf_map_type_list *tl)
+{
+	list_add(&tl->list_node, &bpf_map_types);
+}
+
+/* called from workqueue */
+static void bpf_map_free_deferred(struct work_struct *work)
+{
+	struct bpf_map *map = container_of(work, struct bpf_map, work);
+
+	/* implementation dependent freeing */
+	map->ops->map_free(map);
+}
+
+/* decrement map refcnt and schedule it for freeing via workqueue
+ * (unrelying map implementation ops->map_free() might sleep)
+ */
+void bpf_map_put(struct bpf_map *map)
+{
+	if (atomic_dec_and_test(&map->refcnt)) {
+		INIT_WORK(&map->work, bpf_map_free_deferred);
+		schedule_work(&map->work);
+	}
+}
+
+static int bpf_map_release(struct inode *inode, struct file *filp)
+{
+	struct bpf_map *map = filp->private_data;
+
+	bpf_map_put(map);
+	return 0;
+}
+
+static const struct file_operations bpf_map_fops = {
+        .release = bpf_map_release,
+};
+
+static const struct nla_policy map_policy[BPF_MAP_ATTR_MAX + 1] = {
+	[BPF_MAP_KEY_SIZE]    = { .type = NLA_U32 },
+	[BPF_MAP_VALUE_SIZE]  = { .type = NLA_U32 },
+	[BPF_MAP_MAX_ENTRIES] = { .type = NLA_U32 },
+};
+
+/* called via syscall */
+static int map_create(enum bpf_map_type type, struct nlattr __user *uattr, int len)
+{
+	struct nlattr *tb[BPF_MAP_ATTR_MAX + 1];
+	struct bpf_map *map;
+	struct nlattr *attr;
+	int err;
+
+	if (len <= 0 || len > BPF_MAP_MAX_ATTR_SIZE)
+		return -EINVAL;
+
+	attr = kmalloc(len, GFP_USER);
+	if (!attr)
+		return -ENOMEM;
+
+	/* copy map attributes from user space */
+	err = -EFAULT;
+	if (copy_from_user(attr, uattr, len) != 0)
+		goto free_attr;
+
+	/* perform basic validation */
+	err = nla_parse(tb, BPF_MAP_ATTR_MAX, attr, len, map_policy);
+	if (err < 0)
+		goto free_attr;
+
+	/* find map type and init map: hashtable vs rbtree vs bloom vs ... */
+	map = find_and_alloc_map(type, tb);
+	if (IS_ERR(map)) {
+		err = PTR_ERR(map);
+		goto free_attr;
+	}
+
+	atomic_set(&map->refcnt, 1);
+
+	err = anon_inode_getfd("bpf-map", &bpf_map_fops, map, O_RDWR | O_CLOEXEC);
+
+	if (err < 0)
+		/* failed to allocate fd */
+		goto free_map;
+
+	/* user supplied array of map attributes is no longer needed */
+	kfree(attr);
+
+	return err;
+
+free_map:
+	map->ops->map_free(map);
+free_attr:
+	kfree(attr);
+	return err;
+}
+
+SYSCALL_DEFINE5(bpf, int, cmd, unsigned long, arg2, unsigned long, arg3,
+		unsigned long, arg4, unsigned long, arg5)
+{
+	/* eBPF syscall is limited to root temporarily. This restriction will
+	 * be lifted when verifier has enough mileage and security audit is
+	 * clean. Note that tracing/networking analytics use cases will be
+	 * turning off 'secure' mode of verifier, since they need to pass
+	 * kernel data back to user space
+	 */
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	if (arg5 != 0)
+		return -EINVAL;
+
+	switch (cmd) {
+	case BPF_MAP_CREATE:
+		return map_create((enum bpf_map_type) arg2,
+				  (struct nlattr __user *) arg3, (int) arg4);
+	default:
+		return -EINVAL;
+	}
+}
-- 
1.7.9.5
