From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2 4/5] bpf: add support for persistent maps/progs
Date: Thu, 29 Oct 2015 14:58:09 +0100
Message-ID: <4a49d42b6f4e3bd122a76c7bc98ca1ae454ee34c.1446126105.git.daniel@iogearbox.net>
References: <cover.1446126105.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, hannes@stressinduktion.org, tgraf@suug.ch,
	viro@ZenIV.linux.org.uk, ebiederm@xmission.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@kernel.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:43123 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755607AbbJ2N6S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 09:58:18 -0400
In-Reply-To: <cover.1446126105.git.daniel@iogearbox.net>
In-Reply-To: <cover.1446126105.git.daniel@iogearbox.net>
References: <cover.1446126105.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This work adds support for "persistent" eBPF maps/programs. The term
"persistent" is to be understood that maps/programs have a facility
that lets them survive process termination. This is desired by various
eBPF subsystem users.

Just to name one example: tc classifier/action. Whenever tc parses
the ELF object, extracts and loads maps/progs into the kernel, these
file descriptors will be out of reach after the tc instance exits.
So a subsequent tc invocation won't be able to access/relocate on this
resource, and therefore maps cannot easily be shared, f.e. between the
ingress and egress networking data path.

The current workaround is that Unix domain sockets (UDS) need to be
instrumented in order to pass the created eBPF map/program file
descriptors to a third party management daemon through UDS' socket
passing facility. This makes it a bit complicated to deploy shared
eBPF maps or programs (programs f.e. for tail calls) among various
processes.

We've been brainstorming on how we could tackle this issue and various
approches have been tried out so far, which can be read up further in
the below reference.

The architecture we eventually ended up with is a minimal file system
that can hold map/prog objects. The file system is a per mount namespace
singleton, and the default mount point is /sys/fs/bpf/. Any subsequent
mounts within a given namespace will point to the same instance. The
file system allows for creating a user-defined directory structure.
The objects for maps/progs are created/fetched through bpf(2) with
two new commands (BPF_OBJ_PIN/BPF_OBJ_GET). I.e. a bpf file descriptor
along with a pathname is being passed to bpf(2) that in turn creates
(we call it eBPF object pinning) the file system nodes. Only the pathname
is being passed to bpf(2) for getting a new BPF file descriptor to an
existing node. The user can use that to access maps and progs later on,
through bpf(2). Removal of file system nodes is being managed through
normal VFS functions such as unlink(2), etc. The file system code is
kept to a very minimum and can be further extended later on.

The next step I'm working on is to add dump eBPF map/prog commands
to bpf(2), so that a specification from a given file descriptor can
be retrieved. This can be used by things like CRIU but also applications
can inspect the meta data after calling BPF_OBJ_GET.

Big thanks also to Alexei and Hannes who significantly contributed
in the design discussion that eventually let us end up with this
architecture here.

Reference: https://lkml.org/lkml/2015/10/15/925
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/linux/bpf.h        |   7 +
 include/uapi/linux/bpf.h   |  45 +-----
 include/uapi/linux/magic.h |   1 +
 kernel/bpf/Makefile        |   4 +-
 kernel/bpf/inode.c         | 387 +++++++++++++++++++++++++++++++++++++++++++++
 kernel/bpf/syscall.c       |  30 +++-
 6 files changed, 433 insertions(+), 41 deletions(-)
 create mode 100644 kernel/bpf/inode.c

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 0b5fb6a..de464e6 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -167,11 +167,18 @@ struct bpf_prog *bpf_prog_get(u32 ufd);
 void bpf_prog_put(struct bpf_prog *prog);
 void bpf_prog_put_rcu(struct bpf_prog *prog);
 
+struct bpf_map *bpf_map_get(u32 ufd);
 struct bpf_map *__bpf_map_get(struct fd f);
 void bpf_map_put(struct bpf_map *map);
 
 extern int sysctl_unprivileged_bpf_disabled;
 
+int bpf_map_new_fd(struct bpf_map *map);
+int bpf_prog_new_fd(struct bpf_prog *prog);
+
+int bpf_obj_pin_user(u32 ufd, const char __user *pathname);
+int bpf_obj_get_user(const char __user *pathname);
+
 /* verify correctness of eBPF program */
 int bpf_check(struct bpf_prog **fp, union bpf_attr *attr);
 #else
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 2e03242..9ea2d22 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -63,50 +63,16 @@ struct bpf_insn {
 	__s32	imm;		/* signed immediate constant */
 };
 
-/* BPF syscall commands */
+/* BPF syscall commands, see bpf(2) man-page for details. */
 enum bpf_cmd {
-	/* create a map with given type and attributes
-	 * fd = bpf(BPF_MAP_CREATE, union bpf_attr *, u32 size)
-	 * returns fd or negative error
-	 * map is deleted when fd is closed
-	 */
 	BPF_MAP_CREATE,
-
-	/* lookup key in a given map
-	 * err = bpf(BPF_MAP_LOOKUP_ELEM, union bpf_attr *attr, u32 size)
-	 * Using attr->map_fd, attr->key, attr->value
-	 * returns zero and stores found elem into value
-	 * or negative error
-	 */
 	BPF_MAP_LOOKUP_ELEM,
-
-	/* create or update key/value pair in a given map
-	 * err = bpf(BPF_MAP_UPDATE_ELEM, union bpf_attr *attr, u32 size)
-	 * Using attr->map_fd, attr->key, attr->value, attr->flags
-	 * returns zero or negative error
-	 */
 	BPF_MAP_UPDATE_ELEM,
-
-	/* find and delete elem by key in a given map
-	 * err = bpf(BPF_MAP_DELETE_ELEM, union bpf_attr *attr, u32 size)
-	 * Using attr->map_fd, attr->key
-	 * returns zero or negative error
-	 */
 	BPF_MAP_DELETE_ELEM,
-
-	/* lookup key in a given map and return next key
-	 * err = bpf(BPF_MAP_GET_NEXT_KEY, union bpf_attr *attr, u32 size)
-	 * Using attr->map_fd, attr->key, attr->next_key
-	 * returns zero and stores next key or negative error
-	 */
 	BPF_MAP_GET_NEXT_KEY,
-
-	/* verify and load eBPF program
-	 * prog_fd = bpf(BPF_PROG_LOAD, union bpf_attr *attr, u32 size)
-	 * Using attr->prog_type, attr->insns, attr->license
-	 * returns fd or negative error
-	 */
 	BPF_PROG_LOAD,
+	BPF_OBJ_PIN,
+	BPF_OBJ_GET,
 };
 
 enum bpf_map_type {
@@ -160,6 +126,11 @@ union bpf_attr {
 		__aligned_u64	log_buf;	/* user supplied buffer */
 		__u32		kern_version;	/* checked when prog_type=kprobe */
 	};
+
+	struct { /* anonymous struct used by BPF_OBJ_* commands */
+		__aligned_u64	pathname;
+		__u32		bpf_fd;
+	};
 } __attribute__((aligned(8)));
 
 /* integer value in 'imm' field of BPF_CALL instruction selects which helper
diff --git a/include/uapi/linux/magic.h b/include/uapi/linux/magic.h
index 7b1425a..accb036 100644
--- a/include/uapi/linux/magic.h
+++ b/include/uapi/linux/magic.h
@@ -75,5 +75,6 @@
 #define ANON_INODE_FS_MAGIC	0x09041934
 #define BTRFS_TEST_MAGIC	0x73727279
 #define NSFS_MAGIC		0x6e736673
+#define BPF_FS_MAGIC		0xcafe4a11
 
 #endif /* __LINUX_MAGIC_H__ */
diff --git a/kernel/bpf/Makefile b/kernel/bpf/Makefile
index e6983be..1327258 100644
--- a/kernel/bpf/Makefile
+++ b/kernel/bpf/Makefile
@@ -1,2 +1,4 @@
 obj-y := core.o
-obj-$(CONFIG_BPF_SYSCALL) += syscall.o verifier.o hashtab.o arraymap.o helpers.o
+
+obj-$(CONFIG_BPF_SYSCALL) += syscall.o verifier.o inode.o helpers.o
+obj-$(CONFIG_BPF_SYSCALL) += hashtab.o arraymap.o
diff --git a/kernel/bpf/inode.c b/kernel/bpf/inode.c
new file mode 100644
index 0000000..be6d726
--- /dev/null
+++ b/kernel/bpf/inode.c
@@ -0,0 +1,387 @@
+/*
+ * Minimal file system backend for holding eBPF maps and programs,
+ * used by bpf(2) object pinning.
+ *
+ * Authors:
+ *
+ *	Daniel Borkmann <daniel@iogearbox.net>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * version 2 as published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/magic.h>
+#include <linux/major.h>
+#include <linux/mount.h>
+#include <linux/namei.h>
+#include <linux/fs.h>
+#include <linux/kdev_t.h>
+#include <linux/filter.h>
+#include <linux/bpf.h>
+
+enum bpf_type {
+	BPF_TYPE_UNSPEC	= 0,
+	BPF_TYPE_PROG,
+	BPF_TYPE_MAP,
+};
+
+static void *bpf_any_get(void *raw, enum bpf_type type)
+{
+	switch (type) {
+	case BPF_TYPE_PROG:
+		atomic_inc(&((struct bpf_prog *)raw)->aux->refcnt);
+		break;
+	case BPF_TYPE_MAP:
+		atomic_inc(&((struct bpf_map *)raw)->refcnt);
+		break;
+	default:
+		WARN_ON_ONCE(1);
+		break;
+	}
+
+	return raw;
+}
+
+static void bpf_any_put(void *raw, enum bpf_type type)
+{
+	switch (type) {
+	case BPF_TYPE_PROG:
+		bpf_prog_put(raw);
+		break;
+	case BPF_TYPE_MAP:
+		bpf_map_put(raw);
+		break;
+	default:
+		WARN_ON_ONCE(1);
+		break;
+	}
+}
+
+static void *bpf_fd_probe_obj(u32 ufd, enum bpf_type *type)
+{
+	void *raw;
+
+	*type = BPF_TYPE_MAP;
+	raw = bpf_map_get(ufd);
+	if (IS_ERR(raw)) {
+		*type = BPF_TYPE_PROG;
+		raw = bpf_prog_get(ufd);
+	}
+
+	return raw;
+}
+
+static const struct inode_operations bpf_dir_iops;
+
+static const struct inode_operations bpf_prog_iops = { };
+static const struct inode_operations bpf_map_iops  = { };
+
+static struct inode *bpf_get_inode(struct super_block *sb,
+				   const struct inode *dir,
+				   umode_t mode)
+{
+	struct inode *inode;
+
+	switch (mode & S_IFMT) {
+	case S_IFDIR:
+	case S_IFREG:
+		break;
+	default:
+		return ERR_PTR(-EINVAL);
+	}
+
+	inode = new_inode(sb);
+	if (!inode)
+		return ERR_PTR(-ENOSPC);
+
+	inode->i_ino = get_next_ino();
+	inode->i_atime = CURRENT_TIME;
+	inode->i_mtime = inode->i_atime;
+	inode->i_ctime = inode->i_atime;
+
+	inode_init_owner(inode, dir, mode);
+
+	return inode;
+}
+
+static int bpf_inode_type(const struct inode *inode, enum bpf_type *type)
+{
+	*type = BPF_TYPE_UNSPEC;
+	if (inode->i_op == &bpf_prog_iops)
+		*type = BPF_TYPE_PROG;
+	else if (inode->i_op == &bpf_map_iops)
+		*type = BPF_TYPE_MAP;
+	else
+		return -EACCES;
+
+	return 0;
+}
+
+static bool bpf_dname_reserved(const struct dentry *dentry)
+{
+	return strchr(dentry->d_name.name, '.');
+}
+
+static int bpf_mkdir(struct inode *dir, struct dentry *dentry, umode_t mode)
+{
+	struct inode *inode;
+
+	if (bpf_dname_reserved(dentry))
+		return -EPERM;
+
+	inode = bpf_get_inode(dir->i_sb, dir, mode | S_IFDIR);
+	if (IS_ERR(inode))
+		return PTR_ERR(inode);
+
+	inode->i_op = &bpf_dir_iops;
+	inode->i_fop = &simple_dir_operations;
+
+	inc_nlink(inode);
+	inc_nlink(dir);
+
+	d_instantiate(dentry, inode);
+	dget(dentry);
+
+	return 0;
+}
+
+static int bpf_mkobj_ops(struct inode *dir, struct dentry *dentry,
+			 umode_t mode, const struct inode_operations *iops)
+{
+	struct inode *inode;
+
+	if (bpf_dname_reserved(dentry))
+		return -EPERM;
+
+	inode = bpf_get_inode(dir->i_sb, dir, mode | S_IFREG);
+	if (IS_ERR(inode))
+		return PTR_ERR(inode);
+
+	inode->i_op = iops;
+	inode->i_private = dentry->d_fsdata;
+
+	d_instantiate(dentry, inode);
+	dget(dentry);
+
+	return 0;
+}
+
+static int bpf_mkobj(struct inode *dir, struct dentry *dentry, umode_t mode,
+		     dev_t devt)
+{
+	enum bpf_type type = MINOR(devt);
+
+	if (MAJOR(devt) != UNNAMED_MAJOR || !S_ISREG(mode) ||
+	    dentry->d_fsdata == NULL)
+		return -EPERM;
+
+	switch (type) {
+	case BPF_TYPE_PROG:
+		return bpf_mkobj_ops(dir, dentry, mode, &bpf_prog_iops);
+	case BPF_TYPE_MAP:
+		return bpf_mkobj_ops(dir, dentry, mode, &bpf_map_iops);
+	default:
+		return -EPERM;
+	}
+}
+
+static const struct inode_operations bpf_dir_iops = {
+	.lookup		= simple_lookup,
+	.mknod		= bpf_mkobj,
+	.mkdir		= bpf_mkdir,
+	.rmdir		= simple_rmdir,
+	.unlink		= simple_unlink,
+};
+
+static int bpf_obj_do_pin(const struct filename *pathname, void *raw,
+			  enum bpf_type type)
+{
+	struct dentry *dentry;
+	struct inode *dir;
+	struct path path;
+	umode_t mode;
+	dev_t devt;
+	int ret;
+
+	dentry = kern_path_create(AT_FDCWD, pathname->name, &path, 0);
+	if (IS_ERR(dentry))
+		return PTR_ERR(dentry);
+
+	mode = S_IFREG | ((S_IRUSR | S_IWUSR) & ~current_umask());
+	devt = MKDEV(UNNAMED_MAJOR, type);
+
+	ret = security_path_mknod(&path, dentry, mode, devt);
+	if (ret)
+		goto out;
+
+	dir = d_inode(path.dentry);
+	if (dir->i_op != &bpf_dir_iops) {
+		ret = -EPERM;
+		goto out;
+	}
+
+	dentry->d_fsdata = raw;
+	ret = vfs_mknod(dir, dentry, mode, devt);
+	dentry->d_fsdata = NULL;
+out:
+	done_path_create(&path, dentry);
+	return ret;
+}
+
+int bpf_obj_pin_user(u32 ufd, const char __user *pathname)
+{
+	struct filename *pname;
+	enum bpf_type type;
+	void *raw;
+	int ret;
+
+	pname = getname(pathname);
+	if (IS_ERR(pname))
+		return PTR_ERR(pname);
+
+	raw = bpf_fd_probe_obj(ufd, &type);
+	if (IS_ERR(raw)) {
+		ret = PTR_ERR(raw);
+		goto out;
+	}
+
+	ret = bpf_obj_do_pin(pname, raw, type);
+	if (ret != 0)
+		bpf_any_put(raw, type);
+out:
+	putname(pname);
+	return ret;
+}
+
+static void *bpf_obj_do_get(const struct filename *pathname,
+			    enum bpf_type *type)
+{
+	struct inode *inode;
+	struct path path;
+	void *raw;
+	int ret;
+
+	ret = kern_path(pathname->name, LOOKUP_FOLLOW, &path);
+	if (ret)
+		return ERR_PTR(ret);
+
+	inode = d_backing_inode(path.dentry);
+	ret = inode_permission(inode, MAY_WRITE);
+	if (ret)
+		goto out;
+
+	ret = bpf_inode_type(inode, type);
+	if (ret)
+		goto out;
+
+	raw = bpf_any_get(inode->i_private, *type);
+	touch_atime(&path);
+
+	path_put(&path);
+	return raw;
+out:
+	path_put(&path);
+	return ERR_PTR(ret);
+}
+
+int bpf_obj_get_user(const char __user *pathname)
+{
+	enum bpf_type type = BPF_TYPE_UNSPEC;
+	struct filename *pname;
+	int ret = -ENOENT;
+	void *raw;
+
+	pname = getname(pathname);
+	if (IS_ERR(pname))
+		return PTR_ERR(pname);
+
+	raw = bpf_obj_do_get(pname, &type);
+	if (IS_ERR(raw)) {
+		ret = PTR_ERR(raw);
+		goto out;
+	}
+
+	if (type == BPF_TYPE_PROG)
+		ret = bpf_prog_new_fd(raw);
+	else if (type == BPF_TYPE_MAP)
+		ret = bpf_map_new_fd(raw);
+	else
+		goto out;
+
+	if (ret < 0)
+		bpf_any_put(raw, type);
+out:
+	putname(pname);
+	return ret;
+}
+
+static void bpf_evict_inode(struct inode *inode)
+{
+	enum bpf_type type;
+
+	truncate_inode_pages_final(&inode->i_data);
+	clear_inode(inode);
+
+	if (!bpf_inode_type(inode, &type))
+		bpf_any_put(inode->i_private, type);
+}
+
+static const struct super_operations bpf_super_ops = {
+	.statfs		= simple_statfs,
+	.drop_inode	= generic_delete_inode,
+	.evict_inode	= bpf_evict_inode,
+};
+
+static int bpf_fill_super(struct super_block *sb, void *data, int silent)
+{
+	static struct tree_descr bpf_rfiles[] = { { "" } };
+	struct inode *inode;
+	int ret;
+
+	ret = simple_fill_super(sb, BPF_FS_MAGIC, bpf_rfiles);
+	if (ret)
+		return ret;
+
+	sb->s_op = &bpf_super_ops;
+
+	inode = sb->s_root->d_inode;
+	inode->i_op = &bpf_dir_iops;
+	inode->i_mode &= ~S_IALLUGO;
+	inode->i_mode |= S_ISVTX | S_IRWXUGO;
+
+	return 0;
+}
+
+static struct dentry *bpf_mount(struct file_system_type *type, int flags,
+				const char *dev_name, void *data)
+{
+	return mount_ns(type, flags, current->nsproxy->mnt_ns, bpf_fill_super);
+}
+
+static struct file_system_type bpf_fs_type = {
+	.owner		= THIS_MODULE,
+	.name		= "bpf",
+	.mount		= bpf_mount,
+	.kill_sb	= kill_litter_super,
+	.fs_flags	= FS_USERNS_MOUNT,
+};
+
+MODULE_ALIAS_FS("bpf");
+
+static int __init bpf_init(void)
+{
+	int ret;
+
+	ret = sysfs_create_mount_point(fs_kobj, "bpf");
+	if (ret)
+		return ret;
+
+	ret = register_filesystem(&bpf_fs_type);
+	if (ret)
+		sysfs_remove_mount_point(fs_kobj, "bpf");
+
+	return ret;
+}
+fs_initcall(bpf_init);
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index d7783cb..0d3313d 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -111,7 +111,7 @@ static const struct file_operations bpf_map_fops = {
 	.release = bpf_map_release,
 };
 
-static int bpf_map_new_fd(struct bpf_map *map)
+int bpf_map_new_fd(struct bpf_map *map)
 {
 	return anon_inode_getfd("bpf-map", &bpf_map_fops, map,
 				O_RDWR | O_CLOEXEC);
@@ -174,7 +174,7 @@ struct bpf_map *__bpf_map_get(struct fd f)
 	return f.file->private_data;
 }
 
-static struct bpf_map *bpf_map_get(u32 ufd)
+struct bpf_map *bpf_map_get(u32 ufd)
 {
 	struct fd f = fdget(ufd);
 	struct bpf_map *map;
@@ -548,7 +548,7 @@ static const struct file_operations bpf_prog_fops = {
         .release = bpf_prog_release,
 };
 
-static int bpf_prog_new_fd(struct bpf_prog *prog)
+int bpf_prog_new_fd(struct bpf_prog *prog)
 {
 	return anon_inode_getfd("bpf-prog", &bpf_prog_fops, prog,
 				O_RDWR | O_CLOEXEC);
@@ -674,6 +674,24 @@ free_prog_nouncharge:
 	return err;
 }
 
+#define BPF_OBJ_LAST_FIELD bpf_fd
+
+static int bpf_obj_pin(const union bpf_attr *attr)
+{
+	if (CHECK_ATTR(BPF_OBJ))
+		return -EINVAL;
+
+	return bpf_obj_pin_user(attr->bpf_fd, u64_to_ptr(attr->pathname));
+}
+
+static int bpf_obj_get(const union bpf_attr *attr)
+{
+	if (CHECK_ATTR(BPF_OBJ) || attr->bpf_fd != 0)
+		return -EINVAL;
+
+	return bpf_obj_get_user(u64_to_ptr(attr->pathname));
+}
+
 SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, size)
 {
 	union bpf_attr attr = {};
@@ -734,6 +752,12 @@ SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, siz
 	case BPF_PROG_LOAD:
 		err = bpf_prog_load(&attr);
 		break;
+	case BPF_OBJ_PIN:
+		err = bpf_obj_pin(&attr);
+		break;
+	case BPF_OBJ_GET:
+		err = bpf_obj_get(&attr);
+		break;
 	default:
 		err = -EINVAL;
 		break;
-- 
1.9.3
