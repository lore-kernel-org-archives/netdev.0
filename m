From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Subject: [PATCH net-next 1/4] bpf: Add file mode configuration into bpf maps
Date: Wed,  4 Oct 2017 11:29:29 -0700
Message-ID: <20171004182932.140028-2-chenbofeng.kernel@gmail.com>
References: <20171004182932.140028-1-chenbofeng.kernel@gmail.com>
Cc: Jeffrey Vander Stoep <jeffv@google.com>,
        Lorenzo Colitti <lorenzo@google.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Chenbo Feng <fengc@google.com>
To: netdev@vger.kernel.org, SELinux <Selinux@tycho.nsa.gov>,
        linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20171004182932.140028-1-chenbofeng.kernel@gmail.com>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chenbo Feng <fengc@google.com>

Introduce the map read/write flags to the eBPF syscalls that returns the
map fd. The flags is used to set up the file mode when construct a new
file descriptor for bpf maps. To not break the backward capability, the
f_flags is set to O_RDWR if the flag passed by syscall is 0. Otherwise
it should be O_RDONLY or O_WRONLY. When the userspace want to modify or
read the map content, it will check the file mode to see if it is
allowed to make the change.

Signed-off-by: Chenbo Feng <fengc@google.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/bpf.h      |  6 ++--
 include/uapi/linux/bpf.h |  6 ++++
 kernel/bpf/inode.c       | 15 ++++++---
 kernel/bpf/syscall.c     | 80 +++++++++++++++++++++++++++++++++++++++++++-----
 4 files changed, 92 insertions(+), 15 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 252f4bc9eb25..d826be859589 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -273,11 +273,11 @@ void bpf_map_area_free(void *base);
 
 extern int sysctl_unprivileged_bpf_disabled;
 
-int bpf_map_new_fd(struct bpf_map *map);
+int bpf_map_new_fd(struct bpf_map *map, int flags);
 int bpf_prog_new_fd(struct bpf_prog *prog);
 
 int bpf_obj_pin_user(u32 ufd, const char __user *pathname);
-int bpf_obj_get_user(const char __user *pathname);
+int bpf_obj_get_user(const char __user *pathname, int flags);
 
 int bpf_percpu_hash_copy(struct bpf_map *map, void *key, void *value);
 int bpf_percpu_array_copy(struct bpf_map *map, void *key, void *value);
@@ -296,6 +296,8 @@ int bpf_fd_htab_map_update_elem(struct bpf_map *map, struct file *map_file,
 				void *key, void *value, u64 map_flags);
 int bpf_fd_htab_map_lookup_elem(struct bpf_map *map, void *key, u32 *value);
 
+int bpf_get_file_flag(int flags);
+
 /* memcpy that is used with 8-byte aligned pointers, power-of-8 size and
  * forced to use 'long' read/writes to try to atomically copy long counters.
  * Best-effort only.  No barriers here, since it _will_ race with concurrent
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 6d2137b4cf38..e812be5946a6 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -177,6 +177,10 @@ enum bpf_attach_type {
 
 #define BPF_OBJ_NAME_LEN 16U
 
+/* Flags for accessing BPF object */
+#define BPF_F_RDONLY		(1U << 3)
+#define BPF_F_WRONLY		(1U << 4)
+
 union bpf_attr {
 	struct { /* anonymous struct used by BPF_MAP_CREATE command */
 		__u32	map_type;	/* one of enum bpf_map_type */
@@ -219,6 +223,7 @@ union bpf_attr {
 	struct { /* anonymous struct used by BPF_OBJ_* commands */
 		__aligned_u64	pathname;
 		__u32		bpf_fd;
+		__u32		file_flags;
 	};
 
 	struct { /* anonymous struct used by BPF_PROG_ATTACH/DETACH commands */
@@ -246,6 +251,7 @@ union bpf_attr {
 			__u32		map_id;
 		};
 		__u32		next_id;
+		__u32		open_flags;
 	};
 
 	struct { /* anonymous struct used by BPF_OBJ_GET_INFO_BY_FD */
diff --git a/kernel/bpf/inode.c b/kernel/bpf/inode.c
index e833ed914358..7d8c6dd8dd5d 100644
--- a/kernel/bpf/inode.c
+++ b/kernel/bpf/inode.c
@@ -295,7 +295,7 @@ int bpf_obj_pin_user(u32 ufd, const char __user *pathname)
 }
 
 static void *bpf_obj_do_get(const struct filename *pathname,
-			    enum bpf_type *type)
+			    enum bpf_type *type, int flags)
 {
 	struct inode *inode;
 	struct path path;
@@ -307,7 +307,7 @@ static void *bpf_obj_do_get(const struct filename *pathname,
 		return ERR_PTR(ret);
 
 	inode = d_backing_inode(path.dentry);
-	ret = inode_permission(inode, MAY_WRITE);
+	ret = inode_permission(inode, ACC_MODE(flags));
 	if (ret)
 		goto out;
 
@@ -326,18 +326,23 @@ static void *bpf_obj_do_get(const struct filename *pathname,
 	return ERR_PTR(ret);
 }
 
-int bpf_obj_get_user(const char __user *pathname)
+int bpf_obj_get_user(const char __user *pathname, int flags)
 {
 	enum bpf_type type = BPF_TYPE_UNSPEC;
 	struct filename *pname;
 	int ret = -ENOENT;
+	int f_flags;
 	void *raw;
 
+	f_flags = bpf_get_file_flag(flags);
+	if (f_flags < 0)
+		return f_flags;
+
 	pname = getname(pathname);
 	if (IS_ERR(pname))
 		return PTR_ERR(pname);
 
-	raw = bpf_obj_do_get(pname, &type);
+	raw = bpf_obj_do_get(pname, &type, f_flags);
 	if (IS_ERR(raw)) {
 		ret = PTR_ERR(raw);
 		goto out;
@@ -346,7 +351,7 @@ int bpf_obj_get_user(const char __user *pathname)
 	if (type == BPF_TYPE_PROG)
 		ret = bpf_prog_new_fd(raw);
 	else if (type == BPF_TYPE_MAP)
-		ret = bpf_map_new_fd(raw);
+		ret = bpf_map_new_fd(raw, f_flags);
 	else
 		goto out;
 
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index b927da66f653..7c8a9964a41d 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -294,17 +294,48 @@ static void bpf_map_show_fdinfo(struct seq_file *m, struct file *filp)
 }
 #endif
 
+static ssize_t bpf_dummy_read(struct file *filp, char __user *buf, size_t siz,
+			      loff_t *ppos)
+{
+	/* We need this handler such that alloc_file() enables
+	 * f_mode with FMODE_CAN_READ.
+	 */
+	return -EINVAL;
+}
+
+static ssize_t bpf_dummy_write(struct file *filp, const char __user *buf,
+			       size_t siz, loff_t *ppos)
+{
+	/* We need this handler such that alloc_file() enables
+	 * f_mode with FMODE_CAN_WRITE.
+	 */
+	return -EINVAL;
+}
+
 static const struct file_operations bpf_map_fops = {
 #ifdef CONFIG_PROC_FS
 	.show_fdinfo	= bpf_map_show_fdinfo,
 #endif
 	.release	= bpf_map_release,
+	.read		= bpf_dummy_read,
+	.write		= bpf_dummy_write,
 };
 
-int bpf_map_new_fd(struct bpf_map *map)
+int bpf_map_new_fd(struct bpf_map *map, int flags)
 {
 	return anon_inode_getfd("bpf-map", &bpf_map_fops, map,
-				O_RDWR | O_CLOEXEC);
+				flags | O_CLOEXEC);
+}
+
+int bpf_get_file_flag(int flags)
+{
+	if ((flags & BPF_F_RDONLY) && (flags & BPF_F_WRONLY))
+		return -EINVAL;
+	if (flags & BPF_F_RDONLY)
+		return O_RDONLY;
+	if (flags & BPF_F_WRONLY)
+		return O_WRONLY;
+	return O_RDWR;
 }
 
 /* helper macro to check that unused fields 'union bpf_attr' are zero */
@@ -345,12 +376,17 @@ static int map_create(union bpf_attr *attr)
 {
 	int numa_node = bpf_map_attr_numa_node(attr);
 	struct bpf_map *map;
+	int f_flags;
 	int err;
 
 	err = CHECK_ATTR(BPF_MAP_CREATE);
 	if (err)
 		return -EINVAL;
 
+	f_flags = bpf_get_file_flag(attr->map_flags);
+	if (f_flags < 0)
+		return f_flags;
+
 	if (numa_node != NUMA_NO_NODE &&
 	    ((unsigned int)numa_node >= nr_node_ids ||
 	     !node_online(numa_node)))
@@ -376,7 +412,7 @@ static int map_create(union bpf_attr *attr)
 	if (err)
 		goto free_map;
 
-	err = bpf_map_new_fd(map);
+	err = bpf_map_new_fd(map, f_flags);
 	if (err < 0) {
 		/* failed to allocate fd.
 		 * bpf_map_put() is needed because the above
@@ -491,6 +527,11 @@ static int map_lookup_elem(union bpf_attr *attr)
 	if (IS_ERR(map))
 		return PTR_ERR(map);
 
+	if (!(f.file->f_mode & FMODE_CAN_READ)) {
+		err = -EPERM;
+		goto err_put;
+	}
+
 	key = memdup_user(ukey, map->key_size);
 	if (IS_ERR(key)) {
 		err = PTR_ERR(key);
@@ -571,6 +612,11 @@ static int map_update_elem(union bpf_attr *attr)
 	if (IS_ERR(map))
 		return PTR_ERR(map);
 
+	if (!(f.file->f_mode & FMODE_CAN_WRITE)) {
+		err = -EPERM;
+		goto err_put;
+	}
+
 	key = memdup_user(ukey, map->key_size);
 	if (IS_ERR(key)) {
 		err = PTR_ERR(key);
@@ -654,6 +700,11 @@ static int map_delete_elem(union bpf_attr *attr)
 	if (IS_ERR(map))
 		return PTR_ERR(map);
 
+	if (!(f.file->f_mode & FMODE_CAN_WRITE)) {
+		err = -EPERM;
+		goto err_put;
+	}
+
 	key = memdup_user(ukey, map->key_size);
 	if (IS_ERR(key)) {
 		err = PTR_ERR(key);
@@ -697,6 +748,11 @@ static int map_get_next_key(union bpf_attr *attr)
 	if (IS_ERR(map))
 		return PTR_ERR(map);
 
+	if (!(f.file->f_mode & FMODE_CAN_READ)) {
+		err = -EPERM;
+		goto err_put;
+	}
+
 	if (ukey) {
 		key = memdup_user(ukey, map->key_size);
 		if (IS_ERR(key)) {
@@ -903,6 +959,8 @@ static const struct file_operations bpf_prog_fops = {
 	.show_fdinfo	= bpf_prog_show_fdinfo,
 #endif
 	.release	= bpf_prog_release,
+	.read		= bpf_dummy_read,
+	.write		= bpf_dummy_write,
 };
 
 int bpf_prog_new_fd(struct bpf_prog *prog)
@@ -1112,11 +1170,11 @@ static int bpf_prog_load(union bpf_attr *attr)
 	return err;
 }
 
-#define BPF_OBJ_LAST_FIELD bpf_fd
+#define BPF_OBJ_LAST_FIELD file_flags
 
 static int bpf_obj_pin(const union bpf_attr *attr)
 {
-	if (CHECK_ATTR(BPF_OBJ))
+	if (CHECK_ATTR(BPF_OBJ) || attr->file_flags != 0)
 		return -EINVAL;
 
 	return bpf_obj_pin_user(attr->bpf_fd, u64_to_user_ptr(attr->pathname));
@@ -1127,7 +1185,8 @@ static int bpf_obj_get(const union bpf_attr *attr)
 	if (CHECK_ATTR(BPF_OBJ) || attr->bpf_fd != 0)
 		return -EINVAL;
 
-	return bpf_obj_get_user(u64_to_user_ptr(attr->pathname));
+	return bpf_obj_get_user(u64_to_user_ptr(attr->pathname),
+				attr->file_flags);
 }
 
 #ifdef CONFIG_CGROUP_BPF
@@ -1341,12 +1400,13 @@ static int bpf_prog_get_fd_by_id(const union bpf_attr *attr)
 	return fd;
 }
 
-#define BPF_MAP_GET_FD_BY_ID_LAST_FIELD map_id
+#define BPF_MAP_GET_FD_BY_ID_LAST_FIELD open_flags
 
 static int bpf_map_get_fd_by_id(const union bpf_attr *attr)
 {
 	struct bpf_map *map;
 	u32 id = attr->map_id;
+	int f_flags;
 	int fd;
 
 	if (CHECK_ATTR(BPF_MAP_GET_FD_BY_ID))
@@ -1355,6 +1415,10 @@ static int bpf_map_get_fd_by_id(const union bpf_attr *attr)
 	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
 
+	f_flags = bpf_get_file_flag(attr->open_flags);
+	if (f_flags < 0)
+		return f_flags;
+
 	spin_lock_bh(&map_idr_lock);
 	map = idr_find(&map_idr, id);
 	if (map)
@@ -1366,7 +1430,7 @@ static int bpf_map_get_fd_by_id(const union bpf_attr *attr)
 	if (IS_ERR(map))
 		return PTR_ERR(map);
 
-	fd = bpf_map_new_fd(map);
+	fd = bpf_map_new_fd(map, f_flags);
 	if (fd < 0)
 		bpf_map_put(map);
 
-- 
2.14.2.920.gcf0c67979c-goog

