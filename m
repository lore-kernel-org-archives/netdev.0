From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH RFC net-next 03/14] bpf: introduce syscall(BPF, ...) and BPF maps
Date: Fri, 27 Jun 2014 17:05:55 -0700
Message-ID: <1403913966-4927-4-git-send-email-ast@plumgrid.com>
References: <1403913966-4927-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403913966-4927-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

BPF syscall is a demux for different BPF releated commands.

'maps' is a generic storage of different types for sharing data between kernel
and userspace.

The maps can be created/deleted from user space via BPF syscall:
- create a map with given id, type and attributes
  map_id = bpf_map_create(int map_id, map_type, struct nlattr *attr, int len)
  returns positive map id or negative error

- delete map with given map id
  err = bpf_map_delete(int map_id)
  returns zero or negative error

Next patch allows userspace programs to populate/read maps that eBPF programs
are concurrently updating.

maps can have different types: hash, bloom filter, radix-tree, etc.

The map is defined by:
  . id
  . type
  . max number of elements
  . key size in bytes
  . value size in bytes

Next patches allow eBPF programs to access maps via API:
  void * bpf_map_lookup_elem(u32 map_id, void *key);
  int bpf_map_update_elem(u32 map_id, void *key, void *value);
  int bpf_map_delete_elem(u32 map_id, void *key);

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
 Documentation/networking/filter.txt |   69 ++++++++++
 arch/x86/syscalls/syscall_64.tbl    |    1 +
 include/linux/bpf.h                 |   44 +++++++
 include/linux/syscalls.h            |    2 +
 include/uapi/asm-generic/unistd.h   |    4 +-
 include/uapi/linux/bpf.h            |   29 +++++
 kernel/bpf/Makefile                 |    2 +-
 kernel/bpf/syscall.c                |  238 +++++++++++++++++++++++++++++++++++
 kernel/sys_ni.c                     |    3 +
 9 files changed, 390 insertions(+), 2 deletions(-)
 create mode 100644 include/linux/bpf.h
 create mode 100644 kernel/bpf/syscall.c

diff --git a/Documentation/networking/filter.txt b/Documentation/networking/filter.txt
index ee78eba78a9d..e14e486f69cd 100644
--- a/Documentation/networking/filter.txt
+++ b/Documentation/networking/filter.txt
@@ -995,6 +995,75 @@ BPF_XADD | BPF_DW | BPF_STX: lock xadd *(u64 *)(dst_reg + off16) += src_reg
 Where size is one of: BPF_B or BPF_H or BPF_W or BPF_DW. Note that 1 and
 2 byte atomic increments are not supported.
 
+eBPF maps
+---------
+'maps' is a generic storage of different types for sharing data between kernel
+and userspace.
+
+The maps are accessed from user space via BPF syscall, which has commands:
+- create a map with given id, type and attributes
+  map_id = bpf_map_create(int map_id, map_type, struct nlattr *attr, int len)
+  returns positive map id or negative error
+
+- delete map with given map id
+  err = bpf_map_delete(int map_id)
+  returns zero or negative error
+
+- lookup key in a given map referenced by map_id
+  err = bpf_map_lookup_elem(int map_id, void *key, void *value)
+  returns zero and stores found elem into value or negative error
+
+- create or update key/value pair in a given map
+  err = bpf_map_update_elem(int map_id, void *key, void *value)
+  returns zero or negative error
+
+- find and delete element by key in a given map
+  err = bpf_map_delete_elem(int map_id, void *key)
+
+userspace programs uses this API to create/populate/read maps that eBPF programs
+are concurrently updating.
+
+maps can have different types: hash, bloom filter, radix-tree, etc.
+
+The map is defined by:
+  . id
+  . type
+  . max number of elements
+  . key size in bytes
+  . value size in bytes
+
+The maps are accesible from eBPF program with API:
+  void * bpf_map_lookup_elem(u32 map_id, void *key);
+  int bpf_map_update_elem(u32 map_id, void *key, void *value);
+  int bpf_map_delete_elem(u32 map_id, void *key);
+
+If eBPF verifier is configured to recognize extra calls in the program
+bpf_map_lookup_elem() and bpf_map_update_elem() then access to maps looks like:
+  ...
+  ptr_to_value = map_lookup_elem(const_int_map_id, key)
+  access memory [ptr_to_value, ptr_to_value + value_size_in_bytes]
+  ...
+  prepare key2 and value2 on stack of key_size and value_size
+  err = map_update_elem(const_int_map_id2, key2, value2)
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
+bpf_map_lookup_elem() can return null or ptr_to_value
+ptr_to_value is read/write from the program point of view.
+
+The verifier will check that the program accesses map elements within specified
+size. It will not let programs pass junk values as 'key' and 'value' to
+bpf_map_*_elem() functions, so these functions (implemented in C inside kernel)
+can safely access the pointers in all cases.
+
 Testing
 -------
 
diff --git a/arch/x86/syscalls/syscall_64.tbl b/arch/x86/syscalls/syscall_64.tbl
index ec255a1646d2..edbb8460e1b5 100644
--- a/arch/x86/syscalls/syscall_64.tbl
+++ b/arch/x86/syscalls/syscall_64.tbl
@@ -323,6 +323,7 @@
 314	common	sched_setattr		sys_sched_setattr
 315	common	sched_getattr		sys_sched_getattr
 316	common	renameat2		sys_renameat2
+317	common	bpf			sys_bpf
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff --git a/include/linux/bpf.h b/include/linux/bpf.h
new file mode 100644
index 000000000000..6448b9beea89
--- /dev/null
+++ b/include/linux/bpf.h
@@ -0,0 +1,44 @@
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
+	bool deleted;
+	int map_id;
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
+struct bpf_map *bpf_map_get(u32 map_id);
+
+#endif /* _LINUX_BPF_H */
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index b0881a0ed322..2b524aeba262 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -866,4 +866,6 @@ asmlinkage long sys_process_vm_writev(pid_t pid,
 asmlinkage long sys_kcmp(pid_t pid1, pid_t pid2, int type,
 			 unsigned long idx1, unsigned long idx2);
 asmlinkage long sys_finit_module(int fd, const char __user *uargs, int flags);
+asmlinkage long sys_bpf(int cmd, unsigned long arg2, unsigned long arg3,
+			unsigned long arg4, unsigned long arg5);
 #endif
diff --git a/include/uapi/asm-generic/unistd.h b/include/uapi/asm-generic/unistd.h
index 333640608087..41e20f8fb87e 100644
--- a/include/uapi/asm-generic/unistd.h
+++ b/include/uapi/asm-generic/unistd.h
@@ -699,9 +699,11 @@ __SYSCALL(__NR_sched_setattr, sys_sched_setattr)
 __SYSCALL(__NR_sched_getattr, sys_sched_getattr)
 #define __NR_renameat2 276
 __SYSCALL(__NR_renameat2, sys_renameat2)
+#define __NR_bpf 277
+__SYSCALL(__NR_bpf, sys_bpf)
 
 #undef __NR_syscalls
-#define __NR_syscalls 277
+#define __NR_syscalls 278
 
 /*
  * All syscalls below here should go away really,
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 439d64a07eff..04374e57c290 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -302,4 +302,33 @@ struct sock_filter_int {
 	__s32	imm;		/* signed immediate constant */
 };
 
+/* BPF syscall commands */
+enum bpf_cmd {
+	/* create a map with given id, type and attributes
+	 * map_id = bpf_map_create(int map_id, bpf_map_type, struct nlattr *attr, int len)
+	 * returns positive map id or negative error
+	 */
+	BPF_MAP_CREATE,
+
+	/* delete map with given map id
+	 * err = bpf_map_delete(int map_id)
+	 * returns zero or negative error
+	 */
+	BPF_MAP_DELETE,
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
index 000000000000..b9509923b16f
--- /dev/null
+++ b/kernel/bpf/syscall.c
@@ -0,0 +1,238 @@
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
+
+/* mutex to protect insertion/deletion of map_id in IDR */
+static DEFINE_MUTEX(bpf_map_lock);
+static DEFINE_IDR(bpf_map_id_idr);
+
+/* maximum number of outstanding maps */
+#define MAX_BPF_MAP_CNT 1024
+static u32 bpf_map_cnt;
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
+static const struct nla_policy map_policy[BPF_MAP_ATTR_MAX + 1] = {
+	[BPF_MAP_KEY_SIZE]    = { .type = NLA_U32 },
+	[BPF_MAP_VALUE_SIZE]  = { .type = NLA_U32 },
+	[BPF_MAP_MAX_ENTRIES] = { .type = NLA_U32 },
+};
+
+/* called via syscall */
+static int map_create(int map_id, enum bpf_map_type type,
+		      struct nlattr __user *uattr, int len)
+{
+	struct nlattr *tb[BPF_MAP_ATTR_MAX + 1];
+	struct bpf_map *map;
+	struct nlattr *attr;
+	int err;
+
+	if (len <= 0 || len > BPF_MAP_MAX_ATTR_SIZE)
+		return -EINVAL;
+
+	if (map_id < 0)
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
+	map->deleted = false;
+
+	mutex_lock(&bpf_map_lock);
+
+	if (bpf_map_cnt >= MAX_BPF_MAP_CNT) {
+		mutex_unlock(&bpf_map_lock);
+		err = -ENOSPC;
+		goto free_map;
+	}
+	bpf_map_cnt++;
+
+	/* allocate map id */
+	err = idr_alloc(&bpf_map_id_idr, map, map_id, 0, GFP_USER);
+
+	map->map_id = err;
+
+	mutex_unlock(&bpf_map_lock);
+
+	if (err < 0)
+		/* failed to allocate map id */
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
+/* called from workqueue */
+static void bpf_map_free_deferred(struct work_struct *work)
+{
+	struct bpf_map *map = container_of(work, struct bpf_map, work);
+
+	/* grab the mutex and free the map */
+	mutex_lock(&bpf_map_lock);
+
+	bpf_map_cnt--;
+	idr_remove(&bpf_map_id_idr, map->map_id);
+
+	mutex_unlock(&bpf_map_lock);
+
+	/* implementation dependent freeing */
+	map->ops->map_free(map);
+}
+
+/* decrement map refcnt and schedule it for freeing via workqueue
+ * (unrelying map implementation ops->map_free() might sleep)
+ */
+static void __bpf_map_put(struct bpf_map *map)
+{
+	if (atomic_dec_and_test(&map->refcnt)) {
+		INIT_WORK(&map->work, bpf_map_free_deferred);
+		schedule_work(&map->work);
+	}
+}
+
+/* find map by id and decrement its refcnt
+ *
+ * can be called without any locks held
+ *
+ * returns true if map was found
+ */
+static bool bpf_map_put(u32 map_id)
+{
+	struct bpf_map *map;
+
+	rcu_read_lock();
+	map = idr_find(&bpf_map_id_idr, map_id);
+
+	if (!map) {
+		rcu_read_unlock();
+		return false;
+	}
+
+	__bpf_map_put(map);
+	rcu_read_unlock();
+
+	return true;
+}
+
+/* called with bpf_map_lock held */
+struct bpf_map *bpf_map_get(u32 map_id)
+{
+	BUG_ON(!mutex_is_locked(&bpf_map_lock));
+
+	return idr_find(&bpf_map_id_idr, map_id);
+}
+
+/* called via syscall */
+static int map_delete(int map_id)
+{
+	struct bpf_map *map;
+
+	if (map_id < 0)
+		return -EINVAL;
+
+	mutex_lock(&bpf_map_lock);
+	map = bpf_map_get(map_id);
+
+	if (!map) {
+		/* user is trying to delete map_id that doesn't exist */
+		mutex_unlock(&bpf_map_lock);
+		return -ENODEV;
+	}
+
+	if (map->deleted) {
+		/* this map was already deleted */
+		mutex_unlock(&bpf_map_lock);
+		return 0;
+	}
+
+	/* first time deleting the map
+	 * we cannot just remove this map_id from IDR, since program might
+	 * still be using this map_id, so just mark it deleted,
+	 * when refcnt goes to zero, it will be deleted from IDR
+	 */
+	map->deleted = true;
+	__bpf_map_put(map);
+	mutex_unlock(&bpf_map_lock);
+	return 0;
+}
+
+SYSCALL_DEFINE5(bpf, int, cmd, unsigned long, arg2, unsigned long, arg3,
+		unsigned long, arg4, unsigned long, arg5)
+{
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	switch (cmd) {
+	case BPF_MAP_CREATE:
+		return map_create((int) arg2, (enum bpf_map_type) arg3,
+				  (struct nlattr __user *) arg4, (int) arg5);
+	case BPF_MAP_DELETE:
+		return map_delete((int) arg2);
+
+	default:
+		return -EINVAL;
+	}
+}
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 36441b51b5df..877c9aafbfb4 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -213,3 +213,6 @@ cond_syscall(compat_sys_open_by_handle_at);
 
 /* compare kernel pointers */
 cond_syscall(sys_kcmp);
+
+/* access BPF programs and maps */
+cond_syscall(sys_bpf);
-- 
1.7.9.5
