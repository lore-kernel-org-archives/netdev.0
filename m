From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 067/115] sysctl: rename sysctl_head_grab/finish to sysctl_use_header/unuse
Date: Mon,  9 May 2011 00:39:19 +0200
Message-ID: <1304894407-32201-68-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:47696 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932446Ab1EHWlq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:41:46 -0400
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function names are clearer and they reflect the reference counter
that is being inc/decremented. No functional change, just aesthetics.

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 fs/proc/proc_sysctl.c  |   24 ++++++++++++------------
 include/linux/sysctl.h |    4 ++--
 kernel/sysctl.c        |   40 ++++++++++++++++++++--------------------
 kernel/sysctl_check.c  |    2 +-
 4 files changed, 35 insertions(+), 35 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index 64665e0..b4cde14 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -65,7 +65,7 @@ static struct ctl_table *find_in_table(struct ctl_table *p, struct qstr *name)
 static struct dentry *proc_sys_lookup(struct inode *dir, struct dentry *dentry,
 					struct nameidata *nd)
 {
-	struct ctl_table_header *head = sysctl_head_grab(PROC_I(dir)->sysctl);
+	struct ctl_table_header *head = sysctl_use_header(PROC_I(dir)->sysctl);
 	struct ctl_table *table = PROC_I(dir)->sysctl_entry;
 	struct ctl_table_header *h = NULL;
 	struct qstr *name = &dentry->d_name;
@@ -100,7 +100,7 @@ static struct dentry *proc_sys_lookup(struct inode *dir, struct dentry *dentry,
 	err = ERR_PTR(-ENOMEM);
 	inode = proc_sys_make_inode(dir->i_sb, h ? h : head, p);
 	if (h)
-		sysctl_head_finish(h);
+		sysctl_unuse_header(h);
 
 	if (!inode)
 		goto out;
@@ -110,7 +110,7 @@ static struct dentry *proc_sys_lookup(struct inode *dir, struct dentry *dentry,
 	d_add(dentry, inode);
 
 out:
-	sysctl_head_finish(head);
+	sysctl_unuse_header(head);
 	return err;
 }
 
@@ -118,7 +118,7 @@ static ssize_t proc_sys_call_handler(struct file *filp, void __user *buf,
 		size_t count, loff_t *ppos, int write)
 {
 	struct inode *inode = filp->f_path.dentry->d_inode;
-	struct ctl_table_header *head = sysctl_head_grab(PROC_I(inode)->sysctl);
+	struct ctl_table_header *head = sysctl_use_header(PROC_I(inode)->sysctl);
 	struct ctl_table *table = PROC_I(inode)->sysctl_entry;
 	ssize_t error;
 	size_t res;
@@ -145,7 +145,7 @@ static ssize_t proc_sys_call_handler(struct file *filp, void __user *buf,
 	if (!error)
 		error = res;
 out:
-	sysctl_head_finish(head);
+	sysctl_unuse_header(head);
 
 	return error;
 }
@@ -229,7 +229,7 @@ static int proc_sys_readdir(struct file *filp, void *dirent, filldir_t filldir)
 {
 	struct dentry *dentry = filp->f_path.dentry;
 	struct inode *inode = dentry->d_inode;
-	struct ctl_table_header *head = sysctl_head_grab(PROC_I(inode)->sysctl);
+	struct ctl_table_header *head = sysctl_use_header(PROC_I(inode)->sysctl);
 	struct ctl_table *table = PROC_I(inode)->sysctl_entry;
 	struct ctl_table_header *h = NULL;
 	unsigned long pos;
@@ -270,13 +270,13 @@ static int proc_sys_readdir(struct file *filp, void *dirent, filldir_t filldir)
 			continue;
 		ret = scan(h, h->attached_by, &pos, filp, dirent, filldir);
 		if (ret) {
-			sysctl_head_finish(h);
+			sysctl_unuse_header(h);
 			break;
 		}
 	}
 	ret = 1;
 out:
-	sysctl_head_finish(head);
+	sysctl_unuse_header(head);
 	return ret;
 }
 
@@ -297,7 +297,7 @@ static int proc_sys_permission(struct inode *inode, int mask,unsigned int flags)
 	if ((mask & MAY_EXEC) && S_ISREG(inode->i_mode))
 		return -EACCES;
 
-	head = sysctl_head_grab(PROC_I(inode)->sysctl);
+	head = sysctl_use_header(PROC_I(inode)->sysctl);
 	if (IS_ERR(head))
 		return PTR_ERR(head);
 
@@ -307,7 +307,7 @@ static int proc_sys_permission(struct inode *inode, int mask,unsigned int flags)
 	else /* Use the permissions on the sysctl table entry */
 		error = sysctl_perm(head->root, table, mask);
 
-	sysctl_head_finish(head);
+	sysctl_unuse_header(head);
 	return error;
 }
 
@@ -338,7 +338,7 @@ static int proc_sys_setattr(struct dentry *dentry, struct iattr *attr)
 static int proc_sys_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 {
 	struct inode *inode = dentry->d_inode;
-	struct ctl_table_header *head = sysctl_head_grab(PROC_I(inode)->sysctl);
+	struct ctl_table_header *head = sysctl_use_header(PROC_I(inode)->sysctl);
 	struct ctl_table *table = PROC_I(inode)->sysctl_entry;
 
 	if (IS_ERR(head))
@@ -348,7 +348,7 @@ static int proc_sys_getattr(struct vfsmount *mnt, struct dentry *dentry, struct
 	if (table)
 		stat->mode = (stat->mode & S_IFMT) | table->mode;
 
-	sysctl_head_finish(head);
+	sysctl_unuse_header(head);
 	return 0;
 }
 
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index fe13067..3ff0a9e 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -954,11 +954,11 @@ struct ctl_table_header;
 extern void sysctl_head_get(struct ctl_table_header *);
 extern void sysctl_head_put(struct ctl_table_header *);
 extern int sysctl_is_seen(struct ctl_table_header *);
-extern struct ctl_table_header *sysctl_head_grab(struct ctl_table_header *);
+extern struct ctl_table_header *sysctl_use_header(struct ctl_table_header *);
 extern struct ctl_table_header *sysctl_head_next(struct ctl_table_header *prev);
 extern struct ctl_table_header *__sysctl_head_next(struct nsproxy *namespaces,
 						struct ctl_table_header *prev);
-extern void sysctl_head_finish(struct ctl_table_header *prev);
+extern void sysctl_unuse_header(struct ctl_table_header *prev);
 extern int sysctl_perm(struct ctl_table_root *root,
 		struct ctl_table *table, int op);
 
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index ab242b4..5d52e7a 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1506,6 +1506,26 @@ static void unuse_table(struct ctl_table_header *p)
 			complete(p->unregistering);
 }
 
+struct ctl_table_header *sysctl_use_header(struct ctl_table_header *head)
+{
+	if (!head)
+		head = &root_table_header;
+	spin_lock(&sysctl_lock);
+	if (!use_table(head))
+		head = ERR_PTR(-ENOENT);
+	spin_unlock(&sysctl_lock);
+	return head;
+}
+
+void sysctl_unuse_header(struct ctl_table_header *head)
+{
+	if (!head)
+		return;
+	spin_lock(&sysctl_lock);
+	unuse_table(head);
+	spin_unlock(&sysctl_lock);
+}
+
 /* called under sysctl_lock, will reacquire if has to wait */
 static void start_unregistering(struct ctl_table_header *p)
 {
@@ -1551,26 +1571,6 @@ void sysctl_head_put(struct ctl_table_header *head)
 	spin_unlock(&sysctl_lock);
 }
 
-struct ctl_table_header *sysctl_head_grab(struct ctl_table_header *head)
-{
-	if (!head)
-		head = &root_table_header;
-	spin_lock(&sysctl_lock);
-	if (!use_table(head))
-		head = ERR_PTR(-ENOENT);
-	spin_unlock(&sysctl_lock);
-	return head;
-}
-
-void sysctl_head_finish(struct ctl_table_header *head)
-{
-	if (!head)
-		return;
-	spin_lock(&sysctl_lock);
-	unuse_table(head);
-	spin_unlock(&sysctl_lock);
-}
-
 static struct ctl_table_set *
 lookup_header_set(struct ctl_table_root *root, struct nsproxy *namespaces)
 {
diff --git a/kernel/sysctl_check.c b/kernel/sysctl_check.c
index 52f4810..a3a58b8 100644
--- a/kernel/sysctl_check.c
+++ b/kernel/sysctl_check.c
@@ -55,7 +55,7 @@ repeat:
 	}
 	ref = NULL;
 out:
-	sysctl_head_finish(head);
+	sysctl_unuse_header(head);
 	return ref;
 }
 
-- 
1.7.5.134.g1c08b

