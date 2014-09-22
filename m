From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v14 net-next 01/11] bpf: introduce BPF syscall and maps
Date: Sun, 21 Sep 2014 17:06:41 -0700
Message-ID: <1411344411-3824-2-git-send-email-ast@plumgrid.com>
References: <1411344411-3824-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1411344411-3824-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

BPF syscall is a multiplexor for a range of different operations on eBPF.
This patch introduces syscall with single command to create a map.
Next patch adds commands to access maps.

'maps' is a generic storage of different types for sharing data between kernel
and userspace.

Userspace example:
/* this syscall wrapper creates a map with given type and attributes
 * and returns map_fd on success.
 * use close(map_fd) to delete the map
 */
int bpf_create_map(enum bpf_map_type map_type, int key_size,
                   int value_size, int max_entries)
{
    union bpf_attr attr = {
        .map_type = map_type,
        .key_size = key_size,
        .value_size = value_size,
        .max_entries = max_entries
    };

    return bpf(BPF_MAP_CREATE, &attr, sizeof(attr));
}

'union bpf_attr' is backwards compatible with future extensions.

More details in Documentation/networking/filter.txt and in manpage

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 Documentation/networking/filter.txt |   39 ++++++++
 include/linux/bpf.h                 |   41 +++++++++
 include/uapi/linux/bpf.h            |   23 +++++
 kernel/bpf/Makefile                 |    2 +-
 kernel/bpf/syscall.c                |  169 +++++++++++++++++++++++++++++++++++
 5 files changed, 273 insertions(+), 1 deletion(-)
 create mode 100644 include/linux/bpf.h
 create mode 100644 kernel/bpf/syscall.c

diff --git a/Documentation/networking/filter.txt b/Documentation/networking/filter.txt
index 81916ab5d96f..1900d29518f1 100644
--- a/Documentation/networking/filter.txt
+++ b/Documentation/networking/filter.txt
@@ -1001,6 +1001,45 @@ instruction that loads 64-bit immediate value into a dst_reg.
 Classic BPF has similar instruction: BPF_LD | BPF_W | BPF_IMM which loads
 32-bit immediate value into a register.
 
+eBPF maps
+---------
+'maps' is a generic storage of different types for sharing data between kernel
+and userspace.
+
+The maps are accessed from user space via BPF syscall, which has commands:
+- create a map with given type and attributes
+  map_fd = bpf(BPF_MAP_CREATE, union bpf_attr *attr, u32 size)
+  using attr->map_type, attr->key_size, attr->value_size, attr->max_entries
+  returns process-local file descriptor or negative error
+
+- lookup key in a given map
+  err = bpf(BPF_MAP_LOOKUP_ELEM, union bpf_attr *attr, u32 size)
+  using attr->map_fd, attr->key, attr->value
+  returns zero and stores found elem into value or negative error
+
+- create or update key/value pair in a given map
+  err = bpf(BPF_MAP_UPDATE_ELEM, union bpf_attr *attr, u32 size)
+  using attr->map_fd, attr->key, attr->value
+  returns zero or negative error
+
+- find and delete element by key in a given map
+  err = bpf(BPF_MAP_DELETE_ELEM, union bpf_attr *attr, u32 size)
+  using attr->map_fd, attr->key
+
+- to delete map: close(fd)
+  Exiting process will delete maps automatically
+
+userspace programs use this syscall to create/access maps that eBPF programs
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
 Testing
 -------
 
diff --git a/include/linux/bpf.h b/include/linux/bpf.h
new file mode 100644
index 000000000000..48014a71f0fe
--- /dev/null
+++ b/include/linux/bpf.h
@@ -0,0 +1,41 @@
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
+
+/* map is generic key/value storage optionally accesible by eBPF programs */
+struct bpf_map_ops {
+	/* funcs callable from userspace (via syscall) */
+	struct bpf_map *(*map_alloc)(union bpf_attr *attr);
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
index 479ed0b6be16..f58a10f9670c 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -62,4 +62,27 @@ struct bpf_insn {
 	__s32	imm;		/* signed immediate constant */
 };
 
+/* BPF syscall commands */
+enum bpf_cmd {
+	/* create a map with given type and attributes
+	 * fd = bpf(BPF_MAP_CREATE, union bpf_attr *, u32 size)
+	 * returns fd or negative error
+	 * map is deleted when fd is closed
+	 */
+	BPF_MAP_CREATE,
+};
+
+enum bpf_map_type {
+	BPF_MAP_TYPE_UNSPEC,
+};
+
+union bpf_attr {
+	struct { /* anonymous struct used by BPF_MAP_CREATE command */
+		__u32	map_type;	/* one of enum bpf_map_type */
+		__u32	key_size;	/* size of key in bytes */
+		__u32	value_size;	/* size of value in bytes */
+		__u32	max_entries;	/* max number of entries in a map */
+	};
+} __attribute__((aligned(8)));
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
index 000000000000..428a0e23adc0
--- /dev/null
+++ b/kernel/bpf/syscall.c
@@ -0,0 +1,169 @@
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
+#include <linux/slab.h>
+#include <linux/anon_inodes.h>
+
+static LIST_HEAD(bpf_map_types);
+
+static struct bpf_map *find_and_alloc_map(union bpf_attr *attr)
+{
+	struct bpf_map_type_list *tl;
+	struct bpf_map *map;
+
+	list_for_each_entry(tl, &bpf_map_types, list_node) {
+		if (tl->type == attr->map_type) {
+			map = tl->ops->map_alloc(attr);
+			if (IS_ERR(map))
+				return map;
+			map->ops = tl->ops;
+			map->map_type = attr->map_type;
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
+	.release = bpf_map_release,
+};
+
+/* helper macro to check that unused fields 'union bpf_attr' are zero */
+#define CHECK_ATTR(CMD) \
+	memchr_inv((void *) &attr->CMD##_LAST_FIELD + \
+		   sizeof(attr->CMD##_LAST_FIELD), 0, \
+		   sizeof(*attr) - \
+		   offsetof(union bpf_attr, CMD##_LAST_FIELD) - \
+		   sizeof(attr->CMD##_LAST_FIELD)) != NULL
+
+#define BPF_MAP_CREATE_LAST_FIELD max_entries
+/* called via syscall */
+static int map_create(union bpf_attr *attr)
+{
+	struct bpf_map *map;
+	int err;
+
+	err = CHECK_ATTR(BPF_MAP_CREATE);
+	if (err)
+		return -EINVAL;
+
+	/* find map type and init map: hashtable vs rbtree vs bloom vs ... */
+	map = find_and_alloc_map(attr);
+	if (IS_ERR(map))
+		return PTR_ERR(map);
+
+	atomic_set(&map->refcnt, 1);
+
+	err = anon_inode_getfd("bpf-map", &bpf_map_fops, map, O_RDWR | O_CLOEXEC);
+
+	if (err < 0)
+		/* failed to allocate fd */
+		goto free_map;
+
+	return err;
+
+free_map:
+	map->ops->map_free(map);
+	return err;
+}
+
+SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, size)
+{
+	union bpf_attr attr = {};
+	int err;
+
+	/* the syscall is limited to root temporarily. This restriction will be
+	 * lifted when security audit is clean. Note that eBPF+tracing must have
+	 * this restriction, since it may pass kernel data to user space
+	 */
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	if (!access_ok(VERIFY_READ, uattr, 1))
+		return -EFAULT;
+
+	if (size > PAGE_SIZE)	/* silly large */
+		return -E2BIG;
+
+	/* If we're handed a bigger struct than we know of,
+	 * ensure all the unknown bits are 0 - i.e. new
+	 * user-space does not rely on any kernel feature
+	 * extensions we dont know about yet.
+	 */
+	if (size > sizeof(attr)) {
+		unsigned char __user *addr;
+		unsigned char __user *end;
+		unsigned char val;
+
+		addr = (void __user *)uattr + sizeof(attr);
+		end  = (void __user *)uattr + size;
+
+		for (; addr < end; addr++) {
+			err = get_user(val, addr);
+			if (err)
+				return err;
+			if (val)
+				return -E2BIG;
+		}
+		size = sizeof(attr);
+	}
+
+	/* copy attributes from user space, may be less than sizeof(bpf_attr) */
+	if (copy_from_user(&attr, uattr, size) != 0)
+		return -EFAULT;
+
+	switch (cmd) {
+	case BPF_MAP_CREATE:
+		err = map_create(&attr);
+		break;
+	default:
+		err = -EINVAL;
+		break;
+	}
+
+	return err;
+}
-- 
1.7.9.5
