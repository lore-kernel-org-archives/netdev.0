From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 1/7] ns: proc files for namespace naming policy.
Date: Fri,  6 May 2011 19:24:55 -0700
Message-ID: <1304735101-1824-1-git-send-email-ebiederm@xmission.com>
References: <m1tyd7p7tq.fsf@fess.ebiederm.org>
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-fsdevel@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	Linux Containers <containers@lists.osdl.org>,
	Renato Westphal <renatowestphal@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: <linux-arch@vger.kernel.org>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <m1tyd7p7tq.fsf@fess.ebiederm.org>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Create files under /proc/<pid>/ns/ to allow controlling the
namespaces of a process.

This addresses three specific problems that can make namespaces hard to
work with.
- Namespaces require a dedicated process to pin them in memory.
- It is not possible to use a namespace unless you are the child
  of the original creator.
- Namespaces don't have names that userspace can use to talk about
  them.

The namespace files under /proc/<pid>/ns/ can be opened and the
file descriptor can be used to talk about a specific namespace, and
to keep the specified namespace alive.

A namespace can be kept alive by either holding the file descriptor
open or bind mounting the file someplace else.  aka:
mount --bind /proc/self/ns/net /some/filesystem/path
mount --bind /proc/self/fd/<N> /some/filesystem/path

This allows namespaces to be named with userspace policy.

It requires additional support to make use of these filedescriptors
and that will be comming in the following patches.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/proc/Makefile        |    1 +
 fs/proc/base.c          |   20 ++---
 fs/proc/inode.c         |    7 ++
 fs/proc/internal.h      |   18 +++++
 fs/proc/namespaces.c    |  188 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/proc_fs.h |   18 +++++
 6 files changed, 241 insertions(+), 11 deletions(-)
 create mode 100644 fs/proc/namespaces.c

diff --git a/fs/proc/Makefile b/fs/proc/Makefile
index df434c5..c1c7293 100644
--- a/fs/proc/Makefile
+++ b/fs/proc/Makefile
@@ -20,6 +20,7 @@ proc-y	+= stat.o
 proc-y	+= uptime.o
 proc-y	+= version.o
 proc-y	+= softirqs.o
+proc-y	+= namespaces.o
 proc-$(CONFIG_PROC_SYSCTL)	+= proc_sysctl.o
 proc-$(CONFIG_NET)		+= proc_net.o
 proc-$(CONFIG_PROC_KCORE)	+= kcore.o
diff --git a/fs/proc/base.c b/fs/proc/base.c
index dfa5327..dc8bca7 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -600,7 +600,7 @@ static int proc_fd_access_allowed(struct inode *inode)
 	return allowed;
 }
 
-static int proc_setattr(struct dentry *dentry, struct iattr *attr)
+int proc_setattr(struct dentry *dentry, struct iattr *attr)
 {
 	int error;
 	struct inode *inode = dentry->d_inode;
@@ -1736,8 +1736,7 @@ static int task_dumpable(struct task_struct *task)
 	return 0;
 }
 
-
-static struct inode *proc_pid_make_inode(struct super_block * sb, struct task_struct *task)
+struct inode *proc_pid_make_inode(struct super_block * sb, struct task_struct *task)
 {
 	struct inode * inode;
 	struct proc_inode *ei;
@@ -1779,7 +1778,7 @@ out_unlock:
 	return NULL;
 }
 
-static int pid_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
+int pid_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 {
 	struct inode *inode = dentry->d_inode;
 	struct task_struct *task;
@@ -1820,7 +1819,7 @@ static int pid_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat
  * made this apply to all per process world readable and executable
  * directories.
  */
-static int pid_revalidate(struct dentry *dentry, struct nameidata *nd)
+int pid_revalidate(struct dentry *dentry, struct nameidata *nd)
 {
 	struct inode *inode;
 	struct task_struct *task;
@@ -1862,7 +1861,7 @@ static int pid_delete_dentry(const struct dentry * dentry)
 	return !proc_pid(dentry->d_inode)->tasks[PIDTYPE_PID].first;
 }
 
-static const struct dentry_operations pid_dentry_operations =
+const struct dentry_operations pid_dentry_operations =
 {
 	.d_revalidate	= pid_revalidate,
 	.d_delete	= pid_delete_dentry,
@@ -1870,9 +1869,6 @@ static const struct dentry_operations pid_dentry_operations =
 
 /* Lookups */
 
-typedef struct dentry *instantiate_t(struct inode *, struct dentry *,
-				struct task_struct *, const void *);
-
 /*
  * Fill a directory entry.
  *
@@ -1885,8 +1881,8 @@ typedef struct dentry *instantiate_t(struct inode *, struct dentry *,
  * reported by readdir in sync with the inode numbers reported
  * by stat.
  */
-static int proc_fill_cache(struct file *filp, void *dirent, filldir_t filldir,
-	char *name, int len,
+int proc_fill_cache(struct file *filp, void *dirent, filldir_t filldir,
+	const char *name, int len,
 	instantiate_t instantiate, struct task_struct *task, const void *ptr)
 {
 	struct dentry *child, *dir = filp->f_path.dentry;
@@ -2820,6 +2816,7 @@ static const struct pid_entry tgid_base_stuff[] = {
 	DIR("task",       S_IRUGO|S_IXUGO, proc_task_inode_operations, proc_task_operations),
 	DIR("fd",         S_IRUSR|S_IXUSR, proc_fd_inode_operations, proc_fd_operations),
 	DIR("fdinfo",     S_IRUSR|S_IXUSR, proc_fdinfo_inode_operations, proc_fdinfo_operations),
+	DIR("ns",	  S_IRUSR|S_IXUGO, proc_ns_dir_inode_operations, proc_ns_dir_operations),
 #ifdef CONFIG_NET
 	DIR("net",        S_IRUGO|S_IXUGO, proc_net_inode_operations, proc_net_operations),
 #endif
@@ -3168,6 +3165,7 @@ out_no_task:
 static const struct pid_entry tid_base_stuff[] = {
 	DIR("fd",        S_IRUSR|S_IXUSR, proc_fd_inode_operations, proc_fd_operations),
 	DIR("fdinfo",    S_IRUSR|S_IXUSR, proc_fdinfo_inode_operations, proc_fdinfo_operations),
+	DIR("ns",	 S_IRUSR|S_IXUGO, proc_ns_dir_inode_operations, proc_ns_dir_operations),
 	REG("environ",   S_IRUSR, proc_environ_operations),
 	INF("auxv",      S_IRUSR, proc_pid_auxv),
 	ONE("status",    S_IRUGO, proc_pid_status),
diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index d15aa1b..74b48cf 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -28,6 +28,7 @@ static void proc_evict_inode(struct inode *inode)
 {
 	struct proc_dir_entry *de;
 	struct ctl_table_header *head;
+	const struct proc_ns_operations *ns_ops;
 
 	truncate_inode_pages(&inode->i_data, 0);
 	end_writeback(inode);
@@ -44,6 +45,10 @@ static void proc_evict_inode(struct inode *inode)
 		rcu_assign_pointer(PROC_I(inode)->sysctl, NULL);
 		sysctl_head_put(head);
 	}
+	/* Release any associated namespace */
+	ns_ops = PROC_I(inode)->ns_ops;
+	if (ns_ops && ns_ops->put)
+		ns_ops->put(PROC_I(inode)->ns);
 }
 
 static struct kmem_cache * proc_inode_cachep;
@@ -62,6 +67,8 @@ static struct inode *proc_alloc_inode(struct super_block *sb)
 	ei->pde = NULL;
 	ei->sysctl = NULL;
 	ei->sysctl_entry = NULL;
+	ei->ns = NULL;
+	ei->ns_ops = NULL;
 	inode = &ei->vfs_inode;
 	inode->i_mtime = inode->i_atime = inode->i_ctime = CURRENT_TIME;
 	return inode;
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index c03e8d3..96245a1 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -119,3 +119,21 @@ struct inode *proc_get_inode(struct super_block *, struct proc_dir_entry *);
  */
 int proc_readdir(struct file *, void *, filldir_t);
 struct dentry *proc_lookup(struct inode *, struct dentry *, struct nameidata *);
+
+
+
+/* Lookups */
+typedef struct dentry *instantiate_t(struct inode *, struct dentry *,
+				struct task_struct *, const void *);
+int proc_fill_cache(struct file *filp, void *dirent, filldir_t filldir,
+	const char *name, int len,
+	instantiate_t instantiate, struct task_struct *task, const void *ptr);
+int pid_revalidate(struct dentry *dentry, struct nameidata *nd);
+struct inode *proc_pid_make_inode(struct super_block * sb, struct task_struct *task);
+extern const struct dentry_operations pid_dentry_operations;
+int pid_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat);
+int proc_setattr(struct dentry *dentry, struct iattr *attr);
+
+extern const struct inode_operations proc_ns_dir_inode_operations;
+extern const struct file_operations proc_ns_dir_operations;
+
diff --git a/fs/proc/namespaces.c b/fs/proc/namespaces.c
new file mode 100644
index 0000000..6ae9f07
--- /dev/null
+++ b/fs/proc/namespaces.c
@@ -0,0 +1,188 @@
+#include <linux/proc_fs.h>
+#include <linux/nsproxy.h>
+#include <linux/sched.h>
+#include <linux/ptrace.h>
+#include <linux/fs_struct.h>
+#include <linux/mount.h>
+#include <linux/path.h>
+#include <linux/namei.h>
+#include <linux/file.h>
+#include <linux/utsname.h>
+#include <net/net_namespace.h>
+#include <linux/mnt_namespace.h>
+#include <linux/ipc_namespace.h>
+#include <linux/pid_namespace.h>
+#include "internal.h"
+
+
+static const struct proc_ns_operations *ns_entries[] = {
+};
+
+static const struct file_operations ns_file_operations = {
+	.llseek		= no_llseek,
+};
+
+static struct dentry *proc_ns_instantiate(struct inode *dir,
+	struct dentry *dentry, struct task_struct *task, const void *ptr)
+{
+	const struct proc_ns_operations *ns_ops = ptr;
+	struct inode *inode;
+	struct proc_inode *ei;
+	struct dentry *error = ERR_PTR(-ENOENT);
+
+	inode = proc_pid_make_inode(dir->i_sb, task);
+	if (!inode)
+		goto out;
+
+	ei = PROC_I(inode);
+	inode->i_mode = S_IFREG|S_IRUSR;
+	inode->i_fop  = &ns_file_operations;
+	ei->ns_ops    = ns_ops;
+	ei->ns	      = ns_ops->get(task);
+	if (!ei->ns)
+		goto out_iput;
+
+	dentry->d_op = &pid_dentry_operations;
+	d_add(dentry, inode);
+	/* Close the race of the process dying before we return the dentry */
+	if (pid_revalidate(dentry, NULL))
+		error = NULL;
+out:
+	return error;
+out_iput:
+	iput(inode);
+	goto out;
+}
+
+static int proc_ns_fill_cache(struct file *filp, void *dirent,
+	filldir_t filldir, struct task_struct *task,
+	const struct proc_ns_operations *ops)
+{
+	return proc_fill_cache(filp, dirent, filldir,
+				ops->name, strlen(ops->name),
+				proc_ns_instantiate, task, ops);
+}
+
+static int proc_ns_dir_readdir(struct file *filp, void *dirent,
+				filldir_t filldir)
+{
+	int i;
+	struct dentry *dentry = filp->f_path.dentry;
+	struct inode *inode = dentry->d_inode;
+	struct task_struct *task = get_proc_task(inode);
+	const struct proc_ns_operations **entry, **last;
+	ino_t ino;
+	int ret;
+
+	ret = -ENOENT;
+	if (!task)
+		goto out_no_task;
+
+	ret = -EPERM;
+	if (!ptrace_may_access(task, PTRACE_MODE_READ))
+		goto out;
+
+	ret = 0;
+	i = filp->f_pos;
+	switch (i) {
+	case 0:
+		ino = inode->i_ino;
+		if (filldir(dirent, ".", 1, i, ino, DT_DIR) < 0)
+			goto out;
+		i++;
+		filp->f_pos++;
+		/* fall through */
+	case 1:
+		ino = parent_ino(dentry);
+		if (filldir(dirent, "..", 2, i, ino, DT_DIR) < 0)
+			goto out;
+		i++;
+		filp->f_pos++;
+		/* fall through */
+	default:
+		i -= 2;
+		if (i >= ARRAY_SIZE(ns_entries)) {
+			ret = 1;
+			goto out;
+		}
+		entry = ns_entries + i;
+		last = &ns_entries[ARRAY_SIZE(ns_entries) - 1];
+		while (entry <= last) {
+			if (proc_ns_fill_cache(filp, dirent, filldir,
+						task, *entry) < 0)
+				goto out;
+			filp->f_pos++;
+			entry++;
+		}
+	}
+
+	ret = 1;
+out:
+	put_task_struct(task);
+out_no_task:
+	return ret;
+}
+
+const struct file_operations proc_ns_dir_operations = {
+	.read		= generic_read_dir,
+	.readdir	= proc_ns_dir_readdir,
+};
+
+static struct dentry *proc_ns_dir_lookup(struct inode *dir,
+				struct dentry *dentry, struct nameidata *nd)
+{
+	struct dentry *error;
+	struct task_struct *task = get_proc_task(dir);
+	const struct proc_ns_operations **entry, **last;
+	unsigned int len = dentry->d_name.len;
+
+	error = ERR_PTR(-ENOENT);
+
+	if (!task)
+		goto out_no_task;
+
+	error = ERR_PTR(-EPERM);
+	if (!ptrace_may_access(task, PTRACE_MODE_READ))
+		goto out;
+
+	last = &ns_entries[ARRAY_SIZE(ns_entries) - 1];
+	for (entry = ns_entries; entry <= last; entry++) {
+		if (strlen((*entry)->name) != len)
+			continue;
+		if (!memcmp(dentry->d_name.name, (*entry)->name, len))
+			break;
+	}
+	if (entry > last)
+		goto out;
+
+	error = proc_ns_instantiate(dir, dentry, task, *entry);
+out:
+	put_task_struct(task);
+out_no_task:
+	return error;
+}
+
+const struct inode_operations proc_ns_dir_inode_operations = {
+	.lookup		= proc_ns_dir_lookup,
+	.getattr	= pid_getattr,
+	.setattr	= proc_setattr,
+};
+
+struct file *proc_ns_fget(int fd)
+{
+	struct file *file;
+
+	file = fget(fd);
+	if (!file)
+		return ERR_PTR(-EBADF);
+
+	if (file->f_op != &ns_file_operations)
+		goto out_invalid;
+
+	return file;
+
+out_invalid:
+	fput(file);
+	return ERR_PTR(-EINVAL);
+}
+
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index 838c114..a6d2c6d 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -179,6 +179,8 @@ extern void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file);
 extern struct file *get_mm_exe_file(struct mm_struct *mm);
 extern void dup_mm_exe_file(struct mm_struct *oldmm, struct mm_struct *newmm);
 
+extern struct file *proc_ns_fget(int fd);
+
 #else
 
 #define proc_net_fops_create(net, name, mode, fops)  ({ (void)(mode), NULL; })
@@ -239,6 +241,11 @@ static inline void dup_mm_exe_file(struct mm_struct *oldmm,
 	       			   struct mm_struct *newmm)
 {}
 
+static inline struct file *proc_ns_fget(int fd)
+{
+	return ERR_PTR(-EINVAL);
+}
+
 #endif /* CONFIG_PROC_FS */
 
 #if !defined(CONFIG_PROC_KCORE)
@@ -250,6 +257,15 @@ kclist_add(struct kcore_list *new, void *addr, size_t size, int type)
 extern void kclist_add(struct kcore_list *, void *, size_t, int type);
 #endif
 
+struct nsproxy;
+struct proc_ns_operations {
+	const char *name;
+	int type;
+	void *(*get)(struct task_struct *task);
+	void (*put)(void *ns);
+	int (*install)(struct nsproxy *nsproxy, void *ns);
+};
+
 union proc_op {
 	int (*proc_get_link)(struct inode *, struct path *);
 	int (*proc_read)(struct task_struct *task, char *page);
@@ -268,6 +284,8 @@ struct proc_inode {
 	struct proc_dir_entry *pde;
 	struct ctl_table_header *sysctl;
 	struct ctl_table *sysctl_entry;
+	void *ns;
+	const struct proc_ns_operations *ns_ops;
 	struct inode vfs_inode;
 };
 
-- 
1.6.5.2.143.g8cc62
