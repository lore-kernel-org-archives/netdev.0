From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: 2.6.24-rc3: find complains about /proc/net
Date: Tue, 20 Nov 2007 23:36:52 -0700
Message-ID: <m1hcjgp0jf.fsf@ebiederm.dsl.xmission.com>
References: <20071119191000.GA1560@elf.ucw.cz>
	<200711192304.25087.rjw@sisk.pl> <4743026B.2020907@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Pavel Machek <pavel@ucw.cz>,
	kernel list <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:39032 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751604AbXKUGiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 01:38:06 -0500
In-Reply-To: <4743026B.2020907@openvz.org> (Pavel Emelyanov's message of "Tue,
	20 Nov 2007 18:51:07 +0300")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Below is a preliminary patch.  It solves the directory issue but it doesn't
play well with proc_mnt and proc_flush_task.  It works by simply caching the
network namespace when we mount proc so we don't have to be fancy and dynamic.

Something for the discussion anyway.

I will start sorting out what makes sense tomorrow.

Eric


>From f359fde2469ba8be2123a465e788a83c7e6831e9 Mon Sep 17 00:00:00 2001
From: Eric W. Biederman <ebiederm@xmission.com>
Date: Tue, 20 Nov 2007 19:36:05 -0700
Subject: [PATCH] proc: Fix /proc/net directory listings.

Having proc dynamically display the contents of /proc/net is
hard.  So make life simpler by capturing the network namespace
when we mount proc and only displaying that network namespace.

---
 fs/proc/base.c          |    8 ++--
 fs/proc/generic.c       |    4 ++-
 fs/proc/internal.h      |   13 +++++++
 fs/proc/proc_net.c      |   89 ++++-------------------------------------------
 fs/proc/root.c          |   50 ++++++++++++++++++--------
 include/linux/proc_fs.h |    4 ++
 6 files changed, 66 insertions(+), 102 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index aeaf0d0..9d4f06a 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -2395,7 +2395,7 @@ struct dentry *proc_pid_lookup(struct inode *dir, struct dentry * dentry, struct
 	if (tgid == ~0U)
 		goto out;
 
-	ns = dentry->d_sb->s_fs_info;
+	ns = proc_sbi(dentry->d_sb)->pid_ns;
 	rcu_read_lock();
 	task = find_task_by_pid_ns(tgid, ns);
 	if (task)
@@ -2476,7 +2476,7 @@ int proc_pid_readdir(struct file * filp, void * dirent, filldir_t filldir)
 			goto out;
 	}
 
-	ns = filp->f_dentry->d_sb->s_fs_info;
+	ns = proc_sbi(filp->f_dentry->d_sb)->pid_ns;
 	tgid = filp->f_pos - TGID_OFFSET;
 	for (task = next_tgid(tgid, ns);
 	     task;
@@ -2615,7 +2615,7 @@ static struct dentry *proc_task_lookup(struct inode *dir, struct dentry * dentry
 	if (tid == ~0U)
 		goto out;
 
-	ns = dentry->d_sb->s_fs_info;
+	ns = proc_sbi(dentry->d_sb)->pid_ns;
 	rcu_read_lock();
 	task = find_task_by_pid_ns(tid, ns);
 	if (task)
@@ -2758,7 +2758,7 @@ static int proc_task_readdir(struct file * filp, void * dirent, filldir_t filldi
 	/* f_version caches the tgid value that the last readdir call couldn't
 	 * return. lseek aka telldir automagically resets f_version to 0.
 	 */
-	ns = filp->f_dentry->d_sb->s_fs_info;
+	ns = proc_sbi(filp->f_dentry->d_sb)->pid_ns;
 	tid = (int)filp->f_version;
 	filp->f_version = 0;
 	for (task = first_tid(leader, tid, pos - 2, ns);
diff --git a/fs/proc/generic.c b/fs/proc/generic.c
index 1bdb624..b58f0ec 100644
--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -398,7 +398,9 @@ struct dentry *proc_lookup(struct inode * dir, struct dentry *dentry, struct nam
 				continue;
 			if (!memcmp(dentry->d_name.name, de->name, de->namelen)) {
 				unsigned int ino = de->low_ino;
-
+				
+				if (de->shadow_proc)
+					de = de->shadow_proc(dentry->d_sb, de);
 				de_get(de);
 				spin_unlock(&proc_subdir_lock);
 				error = -EINVAL;
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index 1820eb2..a26f115 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -11,6 +11,18 @@
 
 #include <linux/proc_fs.h>
 
+struct pid_namespace;
+struct net;
+struct proc_sb_info {
+	struct pid_namespace *pid_ns;
+	struct net	     *net_ns;
+};
+
+static inline struct proc_sb_info *proc_sbi(struct super_block *sb)
+{
+	return sb->s_fs_info;
+}
+
 #ifdef CONFIG_PROC_SYSCTL
 extern int proc_sys_init(void);
 #else
@@ -78,3 +90,4 @@ static inline int proc_fd(struct inode *inode)
 {
 	return PROC_I(inode)->fd;
 }
+
diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
index 131f9c6..8a82e29 100644
--- a/fs/proc/proc_net.c
+++ b/fs/proc/proc_net.c
@@ -50,89 +50,15 @@ struct net *get_proc_net(const struct inode *inode)
 }
 EXPORT_SYMBOL_GPL(get_proc_net);
 
-static struct proc_dir_entry *proc_net_shadow;
+static struct proc_dir_entry *shadow_pde;
 
-static struct dentry *proc_net_shadow_dentry(struct dentry *parent,
-						struct proc_dir_entry *de)
+static struct proc_dir_entry *proc_net_shadow(struct super_block *sb,
+					      struct proc_dir_entry *de)
 {
-	struct dentry *shadow = NULL;
-	struct inode *inode;
-	if (!de)
-		goto out;
-	de_get(de);
-	inode = proc_get_inode(parent->d_inode->i_sb, de->low_ino, de);
-	if (!inode)
-		goto out_de_put;
-	shadow = d_alloc_name(parent, de->name);
-	if (!shadow)
-		goto out_iput;
-	shadow->d_op = parent->d_op; /* proc_dentry_operations */
-	d_instantiate(shadow, inode);
-out:
-	return shadow;
-out_iput:
-	iput(inode);
-out_de_put:
-	de_put(de);
-	goto out;
-}
-
-static void *proc_net_follow_link(struct dentry *parent, struct nameidata *nd)
-{
-	struct net *net = current->nsproxy->net_ns;
-	struct dentry *shadow;
-	shadow = proc_net_shadow_dentry(parent, net->proc_net);
-	if (!shadow)
-		return ERR_PTR(-ENOENT);
-
-	dput(nd->dentry);
-	/* My dentry count is 1 and that should be enough as the
-	 * shadow dentry is thrown away immediately.
-	 */
-	nd->dentry = shadow;
-	return NULL;
+	struct proc_sb_info *sbi = proc_sbi(sb);
+	return sbi->net_ns->proc_net;
 }
 
-static struct dentry *proc_net_lookup(struct inode *dir, struct dentry *dentry,
-				      struct nameidata *nd)
-{
-	struct net *net = current->nsproxy->net_ns;
-	struct dentry *shadow;
-
-	shadow = proc_net_shadow_dentry(nd->dentry, net->proc_net);
-	if (!shadow)
-		return ERR_PTR(-ENOENT);
-
-	dput(nd->dentry);
-	nd->dentry = shadow;
-
-	return shadow->d_inode->i_op->lookup(shadow->d_inode, dentry, nd);
-}
-
-static int proc_net_setattr(struct dentry *dentry, struct iattr *iattr)
-{
-	struct net *net = current->nsproxy->net_ns;
-	struct dentry *shadow;
-	int ret;
-
-	shadow = proc_net_shadow_dentry(dentry->d_parent, net->proc_net);
-	if (!shadow)
-		return -ENOENT;
-	ret = shadow->d_inode->i_op->setattr(shadow, iattr);
-	dput(shadow);
-	return ret;
-}
-
-static const struct file_operations proc_net_dir_operations = {
-	.read			= generic_read_dir,
-};
-
-static struct inode_operations proc_net_dir_inode_operations = {
-	.follow_link	= proc_net_follow_link,
-	.lookup		= proc_net_lookup,
-	.setattr	= proc_net_setattr,
-};
-
 static __net_init int proc_net_ns_init(struct net *net)
 {
 	struct proc_dir_entry *root, *netd, *net_statd;
@@ -185,9 +111,8 @@ static struct pernet_operations __net_initdata proc_net_ns_ops = {
 
 int __init proc_net_init(void)
 {
-	proc_net_shadow = proc_mkdir("net", NULL);
-	proc_net_shadow->proc_iops = &proc_net_dir_inode_operations;
-	proc_net_shadow->proc_fops = &proc_net_dir_operations;
+	shadow_pde = proc_mkdir("net", NULL);
+	shadow_pde->shadow_proc = proc_net_shadow;
 
 	return register_pernet_subsys(&proc_net_ns_ops);
 }
diff --git a/fs/proc/root.c b/fs/proc/root.c
index ec9cb3b..e60ac83 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -19,6 +19,7 @@
 #include <linux/smp_lock.h>
 #include <linux/mount.h>
 #include <linux/pid_namespace.h>
+#include <net/net_namespace.h>
 
 #include "internal.h"
 
@@ -26,15 +27,23 @@ struct proc_dir_entry *proc_bus, *proc_root_fs, *proc_root_driver;
 
 static int proc_test_super(struct super_block *sb, void *data)
 {
-	return sb->s_fs_info == data;
+	struct proc_sb_info *sbi = proc_sbi(sb), *info = data;
+	return	(sbi->pid_ns == info->pid_ns) &&
+		(sbi->net_ns == info->net_ns);
 }
 
 static int proc_set_super(struct super_block *sb, void *data)
 {
-	struct pid_namespace *ns;
-
-	ns = (struct pid_namespace *)data;
-	sb->s_fs_info = get_pid_ns(ns);
+	
+	struct proc_sb_info *new, *info = data;
+	
+	new = kzalloc(sizeof(*new), GFP_KERNEL);
+	if (!new)
+		return -ENOMEM;
+	*new = *info;
+	get_pid_ns(new->pid_ns);
+	get_net(new->net_ns);
+	sb->s_fs_info = new;
 	return set_anon_super(sb, NULL);
 }
 
@@ -43,7 +52,7 @@ static int proc_get_sb(struct file_system_type *fs_type,
 {
 	int err;
 	struct super_block *sb;
-	struct pid_namespace *ns;
+	struct proc_sb_info info, *sbi;
 	struct proc_inode *ei;
 
 	if (proc_mnt) {
@@ -57,12 +66,14 @@ static int proc_get_sb(struct file_system_type *fs_type,
 			ei->pid = find_get_pid(1);
 	}
 
+	info.pid_ns = current->nsproxy->pid_ns;
+	info.net_ns = current->nsproxy->net_ns;
 	if (flags & MS_KERNMOUNT)
-		ns = (struct pid_namespace *)data;
+		sbi = data;
 	else
-		ns = current->nsproxy->pid_ns;
+		sbi = &info;
 
-	sb = sget(fs_type, proc_test_super, proc_set_super, ns);
+	sb = sget(fs_type, proc_test_super, proc_set_super, sbi);
 	if (IS_ERR(sb))
 		return PTR_ERR(sb);
 
@@ -78,12 +89,13 @@ static int proc_get_sb(struct file_system_type *fs_type,
 		ei = PROC_I(sb->s_root->d_inode);
 		if (!ei->pid) {
 			rcu_read_lock();
-			ei->pid = get_pid(find_pid_ns(1, ns));
+			ei->pid = get_pid(find_pid_ns(1, sbi->pid_ns));
 			rcu_read_unlock();
 		}
 
 		sb->s_flags |= MS_ACTIVE;
-		ns->proc_mnt = mnt;
+		if (!sbi->pid_ns->proc_mnt)
+			sbi->pid_ns->proc_mnt = mnt;
 	}
 
 	return simple_set_mnt(mnt, sb);
@@ -91,11 +103,13 @@ static int proc_get_sb(struct file_system_type *fs_type,
 
 static void proc_kill_sb(struct super_block *sb)
 {
-	struct pid_namespace *ns;
+	struct proc_sb_info *sbi;
 
-	ns = (struct pid_namespace *)sb->s_fs_info;
+	sbi = proc_sbi(sb);
 	kill_anon_super(sb);
-	put_pid_ns(ns);
+	put_pid_ns(sbi->pid_ns);
+	put_net(sbi->net_ns);
+	kfree(sbi);
 }
 
 static struct file_system_type proc_fs_type = {
@@ -106,13 +120,16 @@ static struct file_system_type proc_fs_type = {
 
 void __init proc_root_init(void)
 {
+	struct proc_sb_info info;
 	int err = proc_init_inodecache();
 	if (err)
 		return;
 	err = register_filesystem(&proc_fs_type);
 	if (err)
 		return;
-	proc_mnt = kern_mount_data(&proc_fs_type, &init_pid_ns);
+	info.pid_ns = &init_pid_ns;
+	info.net_ns = current->nsproxy->net_ns;
+	proc_mnt = kern_mount_data(&proc_fs_type, &info);
 	err = PTR_ERR(proc_mnt);
 	if (IS_ERR(proc_mnt)) {
 		unregister_filesystem(&proc_fs_type);
@@ -214,8 +231,11 @@ struct proc_dir_entry proc_root = {
 
 int pid_ns_prepare_proc(struct pid_namespace *ns)
 {
+	struct proc_sb_info info;
 	struct vfsmount *mnt;
 
+	info.pid_ns = ns;
+	info.net_ns = current->nsproxy->net_ns;
 	mnt = kern_mount_data(&proc_fs_type, ns);
 	if (IS_ERR(mnt))
 		return PTR_ERR(mnt);
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index 2b3c1d8..c22c558 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -48,6 +48,9 @@ typedef	int (read_proc_t)(char *page, char **start, off_t off,
 typedef	int (write_proc_t)(struct file *file, const char __user *buffer,
 			   unsigned long count, void *data);
 typedef int (get_info_t)(char *, char **, off_t, int);
+struct proc_dir_entry;
+typedef struct proc_dir_entry *(shadow_proc_t)(struct super_block *sb,
+						  struct proc_dir_entry *pde);
 
 struct proc_dir_entry {
 	unsigned int low_ino;
@@ -79,6 +82,7 @@ struct proc_dir_entry {
 	int pde_users;	/* number of callers into module in progress */
 	spinlock_t pde_unload_lock; /* proc_fops checks and pde_users bumps */
 	struct completion *pde_unload_completion;
+	shadow_proc_t *shadow_proc;
 };
 
 struct kcore_list {
-- 
1.5.3.rc6.17.g1911

