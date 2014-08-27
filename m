From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH RFC v7 net-next 05/28] bpf: add lookup/update/delete/iterate methods to BPF maps
Date: Tue, 26 Aug 2014 19:29:19 -0700
Message-ID: <1409106582-10095-6-git-send-email-ast@plumgrid.com>
References: <1409106582-10095-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	Namhyung Kim <namhyung@kernel.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1409106582-10095-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

'maps' is a generic storage of different types for sharing data between kernel
and userspace.

The maps are accessed from user space via BPF syscall, which has commands:

- create a map with given type and attributes
  fd = bpf(BPF_MAP_CREATE, union bpf_attr *attr, u32 size)
  returns fd or negative error

- lookup key in a given map referenced by fd
  err = bpf(BPF_MAP_LOOKUP_ELEM, union bpf_attr *attr, u32 size)
  using attr->map_fd, attr->key, attr->value
  returns zero and stores found elem into value or negative error

- create or update key/value pair in a given map
  err = bpf(BPF_MAP_UPDATE_ELEM, union bpf_attr *attr, u32 size)
  using attr->map_fd, attr->key, attr->value
  returns zero or negative error

- find and delete element by key in a given map
  err = bpf(BPF_MAP_DELETE_ELEM, union bpf_attr *attr, u32 size)
  using attr->map_fd, attr->key

- iterate map elements (based on input key return next_key)
  err = bpf(BPF_MAP_GET_NEXT_KEY, union bpf_attr *attr, u32 size)
  using attr->map_fd, attr->key, attr->next_key

- close(fd) deletes the map

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/linux/bpf.h      |    8 ++
 include/uapi/linux/bpf.h |   42 +++++++++
 kernel/bpf/syscall.c     |  219 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 269 insertions(+)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 48014a71f0fe..2887f3f9da59 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -9,6 +9,7 @@
 
 #include <uapi/linux/bpf.h>
 #include <linux/workqueue.h>
+#include <linux/file.h>
 
 struct bpf_map;
 
@@ -17,6 +18,12 @@ struct bpf_map_ops {
 	/* funcs callable from userspace (via syscall) */
 	struct bpf_map *(*map_alloc)(union bpf_attr *attr);
 	void (*map_free)(struct bpf_map *);
+	int (*map_get_next_key)(struct bpf_map *map, void *key, void *next_key);
+
+	/* funcs callable from userspace and from eBPF programs */
+	void *(*map_lookup_elem)(struct bpf_map *map, void *key);
+	int (*map_update_elem)(struct bpf_map *map, void *key, void *value);
+	int (*map_delete_elem)(struct bpf_map *map, void *key);
 };
 
 struct bpf_map {
@@ -37,5 +44,6 @@ struct bpf_map_type_list {
 
 void bpf_register_map_type(struct bpf_map_type_list *tl);
 void bpf_map_put(struct bpf_map *map);
+struct bpf_map *bpf_map_get(struct fd f);
 
 #endif /* _LINUX_BPF_H */
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 51dc51c898c6..1602de6423b5 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -326,6 +326,35 @@ enum bpf_cmd {
 	 * map is deleted when fd is closed
 	 */
 	BPF_MAP_CREATE,
+
+	/* lookup key in a given map
+	 * err = bpf(BPF_MAP_LOOKUP_ELEM, union bpf_attr *attr, u32 size)
+	 * Using attr->map_fd, attr->key, attr->value
+	 * returns zero and stores found elem into value
+	 * or negative error
+	 */
+	BPF_MAP_LOOKUP_ELEM,
+
+	/* create or update key/value pair in a given map
+	 * err = bpf(BPF_MAP_UPDATE_ELEM, union bpf_attr *attr, u32 size)
+	 * Using attr->map_fd, attr->key, attr->value
+	 * returns zero or negative error
+	 */
+	BPF_MAP_UPDATE_ELEM,
+
+	/* find and delete elem by key in a given map
+	 * err = bpf(BPF_MAP_DELETE_ELEM, union bpf_attr *attr, u32 size)
+	 * Using attr->map_fd, attr->key
+	 * returns zero or negative error
+	 */
+	BPF_MAP_DELETE_ELEM,
+
+	/* lookup key in a given map and return next key
+	 * err = bpf(BPF_MAP_GET_NEXT_KEY, union bpf_attr *attr, u32 size)
+	 * Using attr->map_fd, attr->key, attr->next_key
+	 * returns zero and stores next key or negative error
+	 */
+	BPF_MAP_GET_NEXT_KEY,
 };
 
 enum bpf_map_type {
@@ -340,6 +369,19 @@ union bpf_attr {
 		__u32	max_entries;	/* max number of entries in a map */
 #define BPF_MAP_CREATE_LAST_FIELD max_entries
 	};
+
+	struct { /* anonymous struct used by BPF_MAP_*_ELEM commands */
+		int map_fd;
+		void __user *key;
+		union {
+			void __user *value;
+			void __user *next_key;
+		};
+#define BPF_MAP_LOOKUP_ELEM_LAST_FIELD value
+#define BPF_MAP_UPDATE_ELEM_LAST_FIELD value
+#define BPF_MAP_DELETE_ELEM_LAST_FIELD key
+#define BPF_MAP_GET_NEXT_KEY_LAST_FIELD next_key
+	};
 };
 
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 989c17c35a62..b863976741d4 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -13,6 +13,7 @@
 #include <linux/syscalls.h>
 #include <linux/slab.h>
 #include <linux/anon_inodes.h>
+#include <linux/file.h>
 
 static LIST_HEAD(bpf_map_types);
 
@@ -109,6 +110,212 @@ free_map:
 	return err;
 }
 
+/* if error is returned, fd is released.
+ * On success caller should complete fd access with matching fdput()
+ */
+struct bpf_map *bpf_map_get(struct fd f)
+{
+	struct bpf_map *map;
+
+	if (!f.file)
+		return ERR_PTR(-EBADF);
+
+	if (f.file->f_op != &bpf_map_fops) {
+		fdput(f);
+		return ERR_PTR(-EINVAL);
+	}
+
+	map = f.file->private_data;
+
+	return map;
+}
+
+static int map_lookup_elem(union bpf_attr *attr)
+{
+	void __user *ukey = attr->key;
+	void __user *uvalue = attr->value;
+	int ufd = attr->map_fd;
+	struct fd f = fdget(ufd);
+	struct bpf_map *map;
+	void *key, *value;
+	int err;
+
+	if (CHECK_ATTR(BPF_MAP_LOOKUP_ELEM))
+		return -EINVAL;
+
+	map = bpf_map_get(f);
+	if (IS_ERR(map))
+		return PTR_ERR(map);
+
+	err = -ENOMEM;
+	key = kmalloc(map->key_size, GFP_USER);
+	if (!key)
+		goto err_put;
+
+	err = -EFAULT;
+	if (copy_from_user(key, ukey, map->key_size) != 0)
+		goto free_key;
+
+	err = -ESRCH;
+	rcu_read_lock();
+	value = map->ops->map_lookup_elem(map, key);
+	if (!value)
+		goto err_unlock;
+
+	err = -EFAULT;
+	if (copy_to_user(uvalue, value, map->value_size) != 0)
+		goto err_unlock;
+
+	err = 0;
+
+err_unlock:
+	rcu_read_unlock();
+free_key:
+	kfree(key);
+err_put:
+	fdput(f);
+	return err;
+}
+
+static int map_update_elem(union bpf_attr *attr)
+{
+	void __user *ukey = attr->key;
+	void __user *uvalue = attr->value;
+	int ufd = attr->map_fd;
+	struct fd f = fdget(ufd);
+	struct bpf_map *map;
+	void *key, *value;
+	int err;
+
+	if (CHECK_ATTR(BPF_MAP_UPDATE_ELEM))
+		return -EINVAL;
+
+	map = bpf_map_get(f);
+	if (IS_ERR(map))
+		return PTR_ERR(map);
+
+	err = -ENOMEM;
+	key = kmalloc(map->key_size, GFP_USER);
+	if (!key)
+		goto err_put;
+
+	err = -EFAULT;
+	if (copy_from_user(key, ukey, map->key_size) != 0)
+		goto free_key;
+
+	err = -ENOMEM;
+	value = kmalloc(map->value_size, GFP_USER);
+	if (!value)
+		goto free_key;
+
+	err = -EFAULT;
+	if (copy_from_user(value, uvalue, map->value_size) != 0)
+		goto free_value;
+
+	/* eBPF program that use maps are running under rcu_read_lock(),
+	 * therefore all map accessors rely on this fact, so do the same here
+	 */
+	rcu_read_lock();
+	err = map->ops->map_update_elem(map, key, value);
+	rcu_read_unlock();
+
+free_value:
+	kfree(value);
+free_key:
+	kfree(key);
+err_put:
+	fdput(f);
+	return err;
+}
+
+static int map_delete_elem(union bpf_attr *attr)
+{
+	void __user *ukey = attr->key;
+	int ufd = attr->map_fd;
+	struct fd f = fdget(ufd);
+	struct bpf_map *map;
+	void *key;
+	int err;
+
+	if (CHECK_ATTR(BPF_MAP_DELETE_ELEM))
+		return -EINVAL;
+
+	map = bpf_map_get(f);
+	if (IS_ERR(map))
+		return PTR_ERR(map);
+
+	err = -ENOMEM;
+	key = kmalloc(map->key_size, GFP_USER);
+	if (!key)
+		goto err_put;
+
+	err = -EFAULT;
+	if (copy_from_user(key, ukey, map->key_size) != 0)
+		goto free_key;
+
+	rcu_read_lock();
+	err = map->ops->map_delete_elem(map, key);
+	rcu_read_unlock();
+
+free_key:
+	kfree(key);
+err_put:
+	fdput(f);
+	return err;
+}
+
+static int map_get_next_key(union bpf_attr *attr)
+{
+	void __user *ukey = attr->key;
+	void __user *unext_key = attr->next_key;
+	int ufd = attr->map_fd;
+	struct fd f = fdget(ufd);
+	struct bpf_map *map;
+	void *key, *next_key;
+	int err;
+
+	if (CHECK_ATTR(BPF_MAP_GET_NEXT_KEY))
+		return -EINVAL;
+
+	map = bpf_map_get(f);
+	if (IS_ERR(map))
+		return PTR_ERR(map);
+
+	err = -ENOMEM;
+	key = kmalloc(map->key_size, GFP_USER);
+	if (!key)
+		goto err_put;
+
+	err = -EFAULT;
+	if (copy_from_user(key, ukey, map->key_size) != 0)
+		goto free_key;
+
+	err = -ENOMEM;
+	next_key = kmalloc(map->key_size, GFP_USER);
+	if (!next_key)
+		goto free_key;
+
+	rcu_read_lock();
+	err = map->ops->map_get_next_key(map, key, next_key);
+	rcu_read_unlock();
+	if (err)
+		goto free_next_key;
+
+	err = -EFAULT;
+	if (copy_to_user(unext_key, next_key, map->key_size) != 0)
+		goto free_next_key;
+
+	err = 0;
+
+free_next_key:
+	kfree(next_key);
+free_key:
+	kfree(key);
+err_put:
+	fdput(f);
+	return err;
+}
+
 SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, size)
 {
 	union bpf_attr *attr;
@@ -140,6 +347,18 @@ SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, siz
 	case BPF_MAP_CREATE:
 		err = map_create(attr);
 		break;
+	case BPF_MAP_LOOKUP_ELEM:
+		err = map_lookup_elem(attr);
+		break;
+	case BPF_MAP_UPDATE_ELEM:
+		err = map_update_elem(attr);
+		break;
+	case BPF_MAP_DELETE_ELEM:
+		err = map_delete_elem(attr);
+		break;
+	case BPF_MAP_GET_NEXT_KEY:
+		err = map_get_next_key(attr);
+		break;
 	default:
 		err = -EINVAL;
 		break;
-- 
1.7.9.5
