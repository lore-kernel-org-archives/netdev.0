From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Thu, 25 Feb 2010 12:57:02 -0800
Message-ID: <m1pr3t2fvl.fsf_-_@fess.ebiederm.org>
References: <4B4F24AC.70105@trash.net> <1263481549.23480.24.camel@bigi>
	<4B4F3A50.1050400@trash.net> <1263490403.23480.109.camel@bigi>
	<4B50403A.6010507@trash.net> <1263568754.23480.142.camel@bigi>
	<m13a0tf17t.fsf@fess.ebiederm.org> <1266875729.3673.12.camel@bigi>
	<m1wry46es9.fsf@fess.ebiederm.org> <1266931623.3973.643.camel@bigi>
	<m1iq9ocafv.fsf@fess.ebiederm.org> <1266934817.3973.654.camel@bigi>
	<m1r5obbu2w.fsf@fess.ebiederm.org> <1266966581.3973.675.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>,
	Serge Hallyn <serue@us.ibm.com>,
	Matt Helsley <matthltc@us.ibm.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:40271 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933525Ab0BYU5R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2010 15:57:17 -0500
In-Reply-To: <1266966581.3973.675.camel@bigi> (jamal's message of "Tue\, 23 Feb 2010 18\:09\:41 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Introduce two new system calls:
int nsfd(pid_t pid, unsigned long nstype);
int setns(unsigned long nstype, int fd);

These two new system calls address three specific problems that can
make namespaces hard to work with.
- Namespaces require a dedicated process to pin them in memory.
- It is not possible to use a namespace unless you are the
  child of the original creator.
- Namespaces don't have names that userspace can use to talk
  about them.

The nsfd() system call returns a file descriptor that can
be used to talk about a specific namespace, and to keep
the specified namespace alive.

The fd returned by nsfd() can be bind mounted as:
mount --bind /proc/self/fd/N /some/filesystem/path
to keep the namespace alive indefinitely as long as
it is mounted.

open works on the fd returned by nsfd() so another
process can get a hold of it and do interesting things.

Overall that allows for persistent naming of namespaces
according to userspace policy.

setns() allows changing the namespace of the current process
to a namespace that originates with nsfd().

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---

This is just my first pass at this, and not yet compiled tested.
I was pleasantly surprised at how easy all of this was to implement.

I have verified mount will let me bind mount /proc/self/fd/N so
there is nothing special needed for the mount case, except
getting the reference counting and lifetime rules correct for
my filesystem objects.

 arch/x86/ia32/ia32entry.S          |    2 +
 arch/x86/include/asm/unistd_32.h   |    4 +-
 arch/x86/include/asm/unistd_64.h   |    4 +
 arch/x86/kernel/syscall_table_32.S |    2 +
 fs/Makefile                        |    2 +-
 fs/nsfd.c                          |  278 ++++++++++++++++++++++++++++++++++++
 include/linux/magic.h              |    1 +
 include/linux/nsproxy.h            |    1 +
 include/linux/nstype.h             |    6 +
 kernel/nsproxy.c                   |   17 +++
 10 files changed, 315 insertions(+), 2 deletions(-)
 create mode 100644 fs/nsfd.c
 create mode 100644 include/linux/nstype.h

diff --git a/arch/x86/ia32/ia32entry.S b/arch/x86/ia32/ia32entry.S
index 53147ad..9fd33de 100644
--- a/arch/x86/ia32/ia32entry.S
+++ b/arch/x86/ia32/ia32entry.S
@@ -842,4 +842,6 @@ ia32_sys_call_table:
 	.quad compat_sys_rt_tgsigqueueinfo	/* 335 */
 	.quad sys_perf_event_open
 	.quad compat_sys_recvmmsg
+	.quad sys_nsfd
+	.quad sys_setns
 ia32_syscall_end:
diff --git a/arch/x86/include/asm/unistd_32.h b/arch/x86/include/asm/unistd_32.h
index 3baf379..5b7833c 100644
--- a/arch/x86/include/asm/unistd_32.h
+++ b/arch/x86/include/asm/unistd_32.h
@@ -343,10 +343,12 @@
 #define __NR_rt_tgsigqueueinfo	335
 #define __NR_perf_event_open	336
 #define __NR_recvmmsg		337
+#define __NR_nsfd		338
+#define __NR_setns		339
 
 #ifdef __KERNEL__
 
-#define NR_syscalls 338
+#define NR_syscalls 340
 
 #define __ARCH_WANT_IPC_PARSE_VERSION
 #define __ARCH_WANT_OLD_READDIR
diff --git a/arch/x86/include/asm/unistd_64.h b/arch/x86/include/asm/unistd_64.h
index 4843f7b..260d542 100644
--- a/arch/x86/include/asm/unistd_64.h
+++ b/arch/x86/include/asm/unistd_64.h
@@ -663,6 +663,10 @@ __SYSCALL(__NR_rt_tgsigqueueinfo, sys_rt_tgsigqueueinfo)
 __SYSCALL(__NR_perf_event_open, sys_perf_event_open)
 #define __NR_recvmmsg				299
 __SYSCALL(__NR_recvmmsg, sys_recvmmsg)
+#define __NR_nsfd				300
+__SYSCALL(__NR_nsfd, sys_nsfd)
+#define __NR_setns				301
+__SYSCALL(__NR_setns, sys_setns)
 
 #ifndef __NO_STUBS
 #define __ARCH_WANT_OLD_READDIR
diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/syscall_table_32.S
index 15228b5..e09a45b 100644
--- a/arch/x86/kernel/syscall_table_32.S
+++ b/arch/x86/kernel/syscall_table_32.S
@@ -337,3 +337,5 @@ ENTRY(sys_call_table)
 	.long sys_rt_tgsigqueueinfo	/* 335 */
 	.long sys_perf_event_open
 	.long sys_recvmmsg
+	.long sys_nsfd
+	.long sys_setns
diff --git a/fs/Makefile b/fs/Makefile
index af6d047..74d5091 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -11,7 +11,7 @@ obj-y :=	open.o read_write.o file_table.o super.o \
 		attr.o bad_inode.o file.o filesystems.o namespace.o \
 		seq_file.o xattr.o libfs.o fs-writeback.o \
 		pnode.o drop_caches.o splice.o sync.o utimes.o \
-		stack.o fs_struct.o
+		stack.o fs_struct.o nsfd.o
 
 ifeq ($(CONFIG_BLOCK),y)
 obj-y +=	buffer.o bio.o block_dev.o direct-io.o mpage.o ioprio.o
diff --git a/fs/nsfd.c b/fs/nsfd.c
new file mode 100644
index 0000000..71bcc55
--- /dev/null
+++ b/fs/nsfd.c
@@ -0,0 +1,278 @@
+#include <linux/nstype.h>
+#include <linux/fs.h>
+#include <linux/magic.h>
+#include <net/net_namespace.h>
+#include <linux/file.h>
+#include <linux/mount.h>
+#include <linux/cred.h>
+#include <linux/sched.h>
+#include <linux/ptrace.h>
+#include <linux/nsproxy.h>
+#include <linux/kernel.h>
+#include <linux/syscalls.h>
+
+static struct vfsmount *nsfd_mnt __read_mostly;
+static struct inode *nsfd_inode;
+
+static const struct file_operations nsfd_file_operations = {
+	.llseek = no_llseek,
+};
+
+
+static int nsfd_get_sb(struct file_system_type *fs_type, int flags,
+	const char *dev_name, void *data, struct vfsmount *mnt)
+{
+	return get_sb_pseudo(fs_type, "nsfd:", NULL, NSFD_FS_MAGIC, mnt);
+}
+
+static char *nsfd_dname(struct dentry *dentry, char *buffer, int buflen)
+{
+	static const char name[] = "nsfd";
+
+	if (sizeof(name) > buflen)
+		return ERR_PTR(-ENAMETOOLONG);
+
+	return memcpy(buffer, name, sizeof(name));
+}
+
+static const struct dentry_operations nsfd_dentry_operations = {
+	.d_dname		= nsfd_dname,
+};
+
+static struct file_system_type nsfd_fs_type = {
+	.name		= "nsfd",
+	.get_sb		= nsfd_get_sb,
+	.kill_sb	= kill_anon_super,
+	
+};
+
+static void netns_dentry_release(struct dentry *dentry)
+{
+	put_net(dentry->d_fsdata);
+	dentry->d_fsdata = NULL;
+}
+
+static const struct dentry_operations netns_dentry_operations = {
+	.d_dname	= nsfd_dname,
+	.d_release	= netns_dentry_release,
+};
+
+static const struct dentry_operations *nsfd_dops[] = {
+	[NSTYPE_NET] = &netns_dentry_operations,
+};
+
+static const struct dentry_operations *nstype_dops(unsigned long nstype)
+{
+	const struct dentry_operations *d_op = NULL;
+
+	if (nstype < sizeof(nsfd_dops)/sizeof(nsfd_dops[0]))
+		d_op = nsfd_dops[nstype];
+
+	return d_op;
+}
+
+static struct file *nsfd_fget(int fd, unsigned long nstype)
+{
+	const struct dentry_operations *d_op;
+	struct file *file;
+
+	d_op = nstype_dops(nstype);
+	if (!d_op)
+		return ERR_PTR(-EINVAL);
+
+	file = fget(fd);
+	if (!file)
+		return ERR_PTR(-EBADF);
+
+	if (file->f_op != &nsfd_file_operations)
+		goto out_invalid;
+
+	if (file->f_path.dentry->d_op != d_op)
+		goto out_invalid;
+
+	return file;
+
+out_invalid:
+	fput(file);
+	return ERR_PTR(-EINVAL);
+}
+
+static struct inode *nsfd_mkinode(void)
+{
+	struct inode *inode;
+	inode = new_inode(nsfd_mnt->mnt_sb);
+	if (!inode)
+		return ERR_PTR(-ENOMEM);
+
+	inode->i_fop = &nsfd_file_operations;
+
+	/*
+	 * Mark the inode dirty from the very beginning,
+	 * that way it will never be moved to the dirty
+	 * list because mark_inode_dirty() will think that
+	 * it already _is_ on the dirty list.
+	 */
+	inode->i_state = I_DIRTY;
+	inode->i_mode = S_IRUSR | S_IWUSR;
+	inode->i_uid = current_fsuid();
+	inode->i_gid = current_fsgid();
+	inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
+	return inode;
+}
+
+
+static struct file *nsfd_getfile(void)
+{
+	struct qstr name = { .name = "" };
+	struct path path;
+	struct file *file;
+
+	path.dentry = d_alloc(nsfd_mnt->mnt_sb->s_root, &name);
+	if (!path.dentry)
+		return ERR_PTR(-ENOMEM);
+
+	path.mnt = mntget(nsfd_mnt);
+
+	/*
+	 * We know the nsfd_inode inode count is always greater than zero,
+	 * so we can avoid doing an igrab() and we can use an open-coded
+	 * atomic_inc().
+	 */
+	atomic_inc(&nsfd_inode->i_count);
+	path.dentry->d_op = &nsfd_dentry_operations;
+	d_instantiate(path.dentry, nsfd_inode);
+
+	file = alloc_file(&path, FMODE_READ, &nsfd_file_operations);
+	if (!file) {
+		path_put(&path);
+		return ERR_PTR(-ENFILE);
+	}
+	file->f_mapping = nsfd_inode->i_mapping;
+
+	file->f_pos = 0;
+	file->f_flags = O_RDONLY;
+	file->f_version = 0;
+	file->private_data = NULL;
+
+	return file;
+}
+
+static void *nsfd_getns(pid_t pid, unsigned long nstype)
+{
+	struct task_struct *task;
+	struct nsproxy *nsproxy;
+	void *ns;
+
+	ns = ERR_PTR(-ESRCH);
+	rcu_read_lock();
+	if (pid == 0)
+		task = current;
+	else
+		task = find_task_by_vpid(pid);
+	if (!task)
+		goto out;
+
+	ns = ERR_PTR(-EPERM);
+	if (!ptrace_may_access(task, PTRACE_MODE_ATTACH))
+		goto out;
+
+	ns = ERR_PTR(-ESRCH);
+	nsproxy = task_nsproxy(task);
+	if (!nsproxy)
+		goto out;
+
+	ns = ERR_PTR(-EINVAL);
+	switch(nstype) {
+	case NSTYPE_NET:
+		ns = get_net(nsproxy->net_ns);
+		break;
+	}
+out:
+	rcu_read_unlock();
+	return ns;
+}
+
+SYSCALL_DEFINE2(nsfd, pid_t, pid, unsigned long, nstype)
+{
+	const struct dentry_operations *d_op;
+	struct file *file;
+	int fd;
+	void *ns;
+
+	d_op = nstype_dops(nstype);
+	if (!d_op)
+		return -EINVAL;
+
+	file = nsfd_getfile();
+	if (IS_ERR(file))
+		return PTR_ERR(file);
+
+	ns = nsfd_getns(pid, nstype);
+	if (IS_ERR(ns)) {
+		fput(file);
+		return PTR_ERR(ns);
+	}
+
+	file->f_dentry->d_fsdata = ns;
+	file->f_dentry->d_op = d_op;
+	
+	fd = get_unused_fd();
+	if (fd < 0) {
+		fput(file);
+		return fd;
+	}
+	fd_install(fd, file);
+
+	return fd;
+}
+
+
+SYSCALL_DEFINE2(setns, unsigned long, nstype, int, fd)
+{
+	struct file *file;
+
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	file = nsfd_fget(fd, nstype);
+	if (IS_ERR(file))
+		return PTR_ERR(file);
+
+	set_namespace(nstype, file->f_dentry->d_fsdata);
+
+	fput(file);
+	return 0;
+}
+
+
+static int __init nsfd_init(void)
+{
+	int error;
+
+	error = register_filesystem(&nsfd_fs_type);
+	if (error)
+		goto err_exit;
+
+	nsfd_mnt  = kern_mount(&nsfd_fs_type);
+	if (IS_ERR(nsfd_mnt)) {
+		error = PTR_ERR(nsfd_mnt);
+		goto err_unregister_filesystem;
+	}
+
+	nsfd_inode = nsfd_mkinode();
+	if (IS_ERR(nsfd_inode)) {
+		error = PTR_ERR(nsfd_inode);
+		goto err_mntput;
+	}
+
+	return 0;
+
+err_mntput:
+	mntput(nsfd_mnt);
+err_unregister_filesystem:
+	unregister_filesystem(&nsfd_fs_type);
+err_exit:
+	panic(KERN_ERR "nsfd_init() failed (%d)\n", error);
+}
+
+fs_initcall(nsfd_init);
diff --git a/include/linux/magic.h b/include/linux/magic.h
index 76285e0..a4fe6eb 100644
--- a/include/linux/magic.h
+++ b/include/linux/magic.h
@@ -26,6 +26,7 @@
 #define ISOFS_SUPER_MAGIC	0x9660
 #define JFFS2_SUPER_MAGIC	0x72b6
 #define ANON_INODE_FS_MAGIC	0x09041934
+#define NSFD_FS_MAGIC		0x6e736664
 
 #define MINIX_SUPER_MAGIC	0x137F		/* original minix fs */
 #define MINIX_SUPER_MAGIC2	0x138F		/* minix fs, 30 char names */
diff --git a/include/linux/nsproxy.h b/include/linux/nsproxy.h
index 7b370c7..45f1e07 100644
--- a/include/linux/nsproxy.h
+++ b/include/linux/nsproxy.h
@@ -65,6 +65,7 @@ static inline struct nsproxy *task_nsproxy(struct task_struct *tsk)
 int copy_namespaces(unsigned long flags, struct task_struct *tsk);
 void exit_task_namespaces(struct task_struct *tsk);
 void switch_task_namespaces(struct task_struct *tsk, struct nsproxy *new);
+void set_namespace(unsigned long nstype, void *ns);
 void free_nsproxy(struct nsproxy *ns);
 int unshare_nsproxy_namespaces(unsigned long, struct nsproxy **,
 	struct fs_struct *);
diff --git a/include/linux/nstype.h b/include/linux/nstype.h
new file mode 100644
index 0000000..3bdf856
--- /dev/null
+++ b/include/linux/nstype.h
@@ -0,0 +1,6 @@
+#ifndef _LINUX_NSTYPE_H
+#define _LINUX_NSTYPE_H
+
+#define NSTYPE_NET 0
+
+#endif /* _LINUX_NSTYPE_H */
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index 09b4ff9..574461c 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -21,6 +21,7 @@
 #include <linux/pid_namespace.h>
 #include <net/net_namespace.h>
 #include <linux/ipc_namespace.h>
+#include <linux/nstype.h>
 
 static struct kmem_cache *nsproxy_cachep;
 
@@ -221,6 +222,22 @@ void exit_task_namespaces(struct task_struct *p)
 	switch_task_namespaces(p, NULL);
 }
 
+void set_namespace(unsigned long nstype, void *ns)
+{
+	struct task_struct *tsk = current;
+	struct nsproxy *new_nsproxy;
+
+	new_nsproxy = create_new_namespaces(0, tsk, tsk->fs);
+	switch(nstype) {
+	case NSTYPE_NET:
+		put_net(new_nsproxy->net_ns);
+		new_nsproxy->net_ns = get_net(ns);
+		break;
+	}
+
+	switch_task_namespaces(tsk, new_nsproxy);
+}
+
 static int __init nsproxy_cache_init(void)
 {
 	nsproxy_cachep = KMEM_CACHE(nsproxy, SLAB_PANIC);
-- 
1.6.5.2.143.g8cc62

