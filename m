From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [PATCH v5 net-next 06/29] bpf: add lookup/update/delete/iterate methods to BPF maps
Date: Sun, 24 Aug 2014 13:21:07 -0700
Message-ID: <1408911690-7598-7-git-send-email-ast@plumgrid.com>
References: <1408911690-7598-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Brendan Gregg <brendan.d.gregg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1408911690-7598-1-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

'maps' is a generic storage of different types for sharing data between kernel
and userspace.

The maps are accessed from user space via BPF syscall, which has commands:

- create a map with given type and attributes
  fd = bpf_map_create(map_type, struct nlattr *attr, int len)
  returns fd or negative error

- lookup key in a given map referenced by fd
  err = bpf_map_lookup_elem(int fd, void *key, void *value)
  returns zero and stores found elem into value or negative error

- create or update key/value pair in a given map
  err = bpf_map_update_elem(int fd, void *key, void *value)
  returns zero or negative error

- find and delete element by key in a given map
  err = bpf_map_delete_elem(int fd, void *key)

- iterate map elements (based on input key return next_key)
  err = bpf_map_get_next_key(int fd, void *key, void *next_key)

- close(fd) deletes the map

Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
---
 include/linux/bpf.h      |    8 ++
 include/uapi/linux/bpf.h |   25 ++++++
 kernel/bpf/syscall.c     |  198 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 231 insertions(+)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 607ca53fe2af..fd1ac4b5ba8b 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -9,6 +9,7 @@
 
 #include <uapi/linux/bpf.h>
 #include <linux/workqueue.h>
+#include <linux/file.h>
 
 struct bpf_map;
 struct nlattr;
@@ -18,6 +19,12 @@ struct bpf_map_ops {
 	/* funcs callable from userspace (via syscall) */
 	struct bpf_map *(*map_alloc)(struct nlattr *attrs[BPF_MAP_ATTR_MAX + 1]);
 	void (*map_free)(struct bpf_map *);
+	int (*map_get_next_key)(struct bpf_map *map, void *key, void *next_key);
+
+	/* funcs callable from userspace and from eBPF programs */
+	void *(*map_lookup_elem)(struct bpf_map *map, void *key);
+	int (*map_update_elem)(struct bpf_map *map, void *key, void *value);
+	int (*map_delete_elem)(struct bpf_map *map, void *key);
 };
 
 struct bpf_map {
@@ -38,5 +45,6 @@ struct bpf_map_type_list {
 
 void bpf_register_map_type(struct bpf_map_type_list *tl);
 void bpf_map_put(struct bpf_map *map);
+struct bpf_map *bpf_map_get(struct fd f);
 
 #endif /* _LINUX_BPF_H */
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index de21c8ecf0bb..f68edb2681f8 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -326,6 +326,31 @@ enum bpf_cmd {
 	 * map is deleted when fd is closed
 	 */
 	BPF_MAP_CREATE,
+
+	/* lookup key in a given map
+	 * err = bpf_map_lookup_elem(int fd, void *key, void *value)
+	 * returns zero and stores found elem into value
+	 * or negative error
+	 */
+	BPF_MAP_LOOKUP_ELEM,
+
+	/* create or update key/value pair in a given map
+	 * err = bpf_map_update_elem(int fd, void *key, void *value)
+	 * returns zero or negative error
+	 */
+	BPF_MAP_UPDATE_ELEM,
+
+	/* find and delete elem by key in a given map
+	 * err = bpf_map_delete_elem(int fd, void *key)
+	 * returns zero or negative error
+	 */
+	BPF_MAP_DELETE_ELEM,
+
+	/* lookup key in a given map and return next key
+	 * err = bpf_map_get_elem(int fd, void *key, void *next_key)
+	 * returns zero and stores next key or negative error
+	 */
+	BPF_MAP_GET_NEXT_KEY,
 };
 
 enum bpf_map_attributes {
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 04cdf7948f8f..45e100ece1b7 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -13,6 +13,7 @@
 #include <linux/syscalls.h>
 #include <net/netlink.h>
 #include <linux/anon_inodes.h>
+#include <linux/file.h>
 
 static LIST_HEAD(bpf_map_types);
 
@@ -131,6 +132,189 @@ free_attr:
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
+static int map_lookup_elem(int ufd, void __user *ukey, void __user *uvalue)
+{
+	struct fd f = fdget(ufd);
+	struct bpf_map *map;
+	void *key, *value;
+	int err;
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
+static int map_update_elem(int ufd, void __user *ukey, void __user *uvalue)
+{
+	struct fd f = fdget(ufd);
+	struct bpf_map *map;
+	void *key, *value;
+	int err;
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
+static int map_delete_elem(int ufd, void __user *ukey)
+{
+	struct fd f = fdget(ufd);
+	struct bpf_map *map;
+	void *key;
+	int err;
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
+static int map_get_next_key(int ufd, void __user *ukey, void __user *unext_key)
+{
+	struct fd f = fdget(ufd);
+	struct bpf_map *map;
+	void *key, *next_key;
+	int err;
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
 SYSCALL_DEFINE5(bpf, int, cmd, unsigned long, arg2, unsigned long, arg3,
 		unsigned long, arg4, unsigned long, arg5)
 {
@@ -150,6 +334,20 @@ SYSCALL_DEFINE5(bpf, int, cmd, unsigned long, arg2, unsigned long, arg3,
 	case BPF_MAP_CREATE:
 		return map_create((enum bpf_map_type) arg2,
 				  (struct nlattr __user *) arg3, (int) arg4);
+	case BPF_MAP_LOOKUP_ELEM:
+		return map_lookup_elem((int) arg2, (void __user *) arg3,
+				       (void __user *) arg4);
+	case BPF_MAP_UPDATE_ELEM:
+		return map_update_elem((int) arg2, (void __user *) arg3,
+				       (void __user *) arg4);
+	case BPF_MAP_DELETE_ELEM:
+		if (arg4 != 0)
+			return -EINVAL;
+		return map_delete_elem((int) arg2, (void __user *) arg3);
+
+	case BPF_MAP_GET_NEXT_KEY:
+		return map_get_next_key((int) arg2, (void __user *) arg3,
+					(void __user *) arg4);
 	default:
 		return -EINVAL;
 	}
-- 
1.7.9.5
