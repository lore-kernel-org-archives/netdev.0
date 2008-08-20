From: <gregkh@suse.de>
Subject: patch sysfs-rename-support-multiple-superblocks.patch added to gregkh-2.6 tree
Date: Tue, 19 Aug 2008 19:16:16 -0700
Message-ID: <12191985763290@kroah.org>
References: <m1d4luihea.fsf_-_@frodo.ebiederm.org>
To: ebiederm@xmission.com, akpm@linux-foundation.org,
	benjamin.thery@bull.net, containers@lists.osdl.org,
	dlezcano@fr.ibm.com, gregkh@suse.de, htejun@gmail.com,
	netdev@vger.kernel.org, tj
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:36589 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752104AbYHTCVn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Aug 2008 22:21:43 -0400
In-Reply-To: <m1d4luihea.fsf_-_@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is a note to let you know that I've just added the patch titled

    Subject: sysfs: Rename Support multiple superblocks

to my gregkh-2.6 tree.  Its filename is

    sysfs-rename-support-multiple-superblocks.patch

This tree can be found at 
    http://www.kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/patches/


>From ebiederm@xmission.com Thu Jul  3 18:11:52 2008
From: Eric W. Biederman <ebiederm@xmission.com>
Date: Thu, 03 Jul 2008 18:10:05 -0700
Subject: sysfs: Rename Support multiple superblocks
To: Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <htejun@gmail.com>, Daniel Lezcano <dlezcano@fr.ibm.com>, linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>, Linux Containers <containers@lists.osdl.org>, Benjamin Thery <benjamin.thery@bull.net>, <netdev@vger.kernel.org>
Message-ID: <m1d4luihea.fsf_-_@frodo.ebiederm.org>

From: Eric W. Biederman <ebiederm@xmission.com>


This patch modifies the sysfs_rename_dir and sysfs_move_dir routines
to support multiple sysfs dentry tries rooted in different
sysfs superblocks.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Acked-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 fs/sysfs/dir.c |  195 ++++++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 137 insertions(+), 58 deletions(-)

--- a/fs/sysfs/dir.c
+++ b/fs/sysfs/dir.c
@@ -834,43 +834,113 @@ static struct dentry *__sysfs_get_dentry
 	return dentry;
 }
 
+struct sysfs_rename_struct {
+	struct list_head list;
+	struct dentry *old_dentry;
+	struct dentry *new_dentry;
+	struct dentry *old_parent;
+	struct dentry *new_parent;
+};
+
+static void post_rename(struct list_head *head)
+{
+	struct sysfs_rename_struct *srs;
+	while (!list_empty(head)) {
+		srs = list_entry(head->next, struct sysfs_rename_struct, list);
+		dput(srs->old_dentry);
+		dput(srs->new_dentry);
+		dput(srs->old_parent);
+		dput(srs->new_parent);
+		list_del(&srs->list);
+		kfree(srs);
+	}
+}
+
+static int prep_rename(struct list_head *head,
+	struct sysfs_dirent *sd, struct sysfs_dirent *new_parent_sd,
+	const char *name)
+{
+	struct sysfs_rename_struct *srs;
+	struct super_block *sb;
+	struct dentry *dentry;
+	int error;
+
+	list_for_each_entry(sb, &sysfs_fs_type.fs_supers, s_instances) {
+		dentry = sysfs_get_dentry(sb, sd);
+		if (dentry == ERR_PTR(-EXDEV))
+			continue;
+		if (IS_ERR(dentry)) {
+			error = PTR_ERR(dentry);
+			goto err_out;
+		}
+
+		srs = kzalloc(sizeof(*srs), GFP_KERNEL);
+		if (!srs) {
+			error = -ENOMEM;
+			dput(dentry);
+			goto err_out;
+		}
+
+		INIT_LIST_HEAD(&srs->list);
+		list_add(head, &srs->list);
+		srs->old_dentry = dentry;
+		srs->old_parent = dget(dentry->d_parent);
+
+		dentry = sysfs_get_dentry(sb, new_parent_sd);
+		if (IS_ERR(dentry)) {
+			error = PTR_ERR(dentry);
+			goto err_out;
+		}
+		srs->new_parent = dentry;
+
+		error = -ENOMEM;
+		dentry = d_alloc_name(srs->new_parent, name);
+		if (!dentry)
+			goto err_out;
+		srs->new_dentry = dentry;
+	}
+	return 0;
+
+err_out:
+	post_rename(head);
+	return error;
+}
+
 int sysfs_rename_dir(struct kobject * kobj, const char *new_name)
 {
 	struct sysfs_dirent *sd = kobj->sd;
-	struct dentry *parent = NULL;
-	struct dentry *old_dentry = NULL, *new_dentry = NULL;
+	struct list_head todo;
+	struct sysfs_rename_struct *srs;
+	struct inode *parent_inode = NULL;
 	const char *dup_name = NULL;
 	int error;
 
+	INIT_LIST_HEAD(&todo);
 	mutex_lock(&sysfs_rename_mutex);
 
 	error = 0;
 	if (strcmp(sd->s_name, new_name) == 0)
 		goto out;	/* nothing to rename */
 
-	/* get the original dentry */
-	old_dentry = sysfs_get_dentry(sysfs_sb, sd);
-	if (IS_ERR(old_dentry)) {
-		error = PTR_ERR(old_dentry);
-		old_dentry = NULL;
-		goto out;
-	}
+	sysfs_grab_supers();
+	error = prep_rename(&todo, sd, sd->s_parent, new_name);
+	if (error)
+		goto out_release;
 
-	parent = old_dentry->d_parent;
+	error = -ENOMEM;
+	mutex_lock(&sysfs_mutex);
+	parent_inode = sysfs_get_inode(sd->s_parent);
+	mutex_unlock(&sysfs_mutex);
+	if (!parent_inode)
+		goto out_release;
 
-	/* lock parent and get dentry for new name */
-	mutex_lock(&parent->d_inode->i_mutex);
+	mutex_lock(&parent_inode->i_mutex);
 	mutex_lock(&sysfs_mutex);
 
 	error = -EEXIST;
 	if (sysfs_find_dirent(sd->s_parent, new_name))
 		goto out_unlock;
 
-	error = -ENOMEM;
-	new_dentry = d_alloc_name(parent, new_name);
-	if (!new_dentry)
-		goto out_unlock;
-
 	/* rename sysfs_dirent */
 	error = -ENOMEM;
 	new_name = dup_name = kstrdup(new_name, GFP_KERNEL);
@@ -881,17 +951,21 @@ int sysfs_rename_dir(struct kobject * ko
 	sd->s_name = new_name;
 
 	/* rename */
-	d_add(new_dentry, NULL);
-	d_move(old_dentry, new_dentry);
+	list_for_each_entry(srs, &todo, list) {
+		d_add(srs->new_dentry, NULL);
+		d_move(srs->old_dentry, srs->new_dentry);
+	}
 
 	error = 0;
- out_unlock:
+out_unlock:
 	mutex_unlock(&sysfs_mutex);
-	mutex_unlock(&parent->d_inode->i_mutex);
+	mutex_unlock(&parent_inode->i_mutex);
 	kfree(dup_name);
-	dput(old_dentry);
-	dput(new_dentry);
- out:
+out_release:
+	iput(parent_inode);
+	post_rename(&todo);
+	sysfs_release_supers();
+out:
 	mutex_unlock(&sysfs_rename_mutex);
 	return error;
 }
@@ -900,10 +974,12 @@ int sysfs_move_dir(struct kobject *kobj,
 {
 	struct sysfs_dirent *sd = kobj->sd;
 	struct sysfs_dirent *new_parent_sd;
-	struct dentry *old_parent, *new_parent = NULL;
-	struct dentry *old_dentry = NULL, *new_dentry = NULL;
+	struct list_head todo;
+	struct sysfs_rename_struct *srs;
+	struct inode *old_parent_inode = NULL, *new_parent_inode = NULL;
 	int error;
 
+	INIT_LIST_HEAD(&todo);
 	mutex_lock(&sysfs_rename_mutex);
 	BUG_ON(!sd->s_parent);
 	new_parent_sd = new_parent_kobj->sd ? new_parent_kobj->sd : &sysfs_root;
@@ -912,26 +988,29 @@ int sysfs_move_dir(struct kobject *kobj,
 	if (sd->s_parent == new_parent_sd)
 		goto out;	/* nothing to move */
 
-	/* get dentries */
-	old_dentry = sysfs_get_dentry(sysfs_sb, sd);
-	if (IS_ERR(old_dentry)) {
-		error = PTR_ERR(old_dentry);
-		old_dentry = NULL;
-		goto out;
-	}
-	old_parent = old_dentry->d_parent;
-
-	new_parent = sysfs_get_dentry(sysfs_sb, new_parent_sd);
-	if (IS_ERR(new_parent)) {
-		error = PTR_ERR(new_parent);
-		new_parent = NULL;
-		goto out;
-	}
+	sysfs_grab_supers();
+	error = prep_rename(&todo, sd, new_parent_sd, sd->s_name);
+	if (error)
+		goto out_release;
+
+	error = -ENOMEM;
+	mutex_lock(&sysfs_mutex);
+	old_parent_inode = sysfs_get_inode(sd->s_parent);
+	mutex_unlock(&sysfs_mutex);
+	if (!old_parent_inode)
+		goto out_release;
+
+	error = -ENOMEM;
+	mutex_lock(&sysfs_mutex);
+	new_parent_inode = sysfs_get_inode(new_parent_sd);
+	mutex_unlock(&sysfs_mutex);
+	if (!new_parent_inode)
+		goto out_release;
 
 again:
-	mutex_lock(&old_parent->d_inode->i_mutex);
-	if (!mutex_trylock(&new_parent->d_inode->i_mutex)) {
-		mutex_unlock(&old_parent->d_inode->i_mutex);
+	mutex_lock(&old_parent_inode->i_mutex);
+	if (!mutex_trylock(&new_parent_inode->i_mutex)) {
+		mutex_unlock(&old_parent_inode->i_mutex);
 		goto again;
 	}
 	mutex_lock(&sysfs_mutex);
@@ -940,14 +1019,11 @@ again:
 	if (sysfs_find_dirent(new_parent_sd, sd->s_name))
 		goto out_unlock;
 
-	error = -ENOMEM;
-	new_dentry = d_alloc_name(new_parent, sd->s_name);
-	if (!new_dentry)
-		goto out_unlock;
-
 	error = 0;
-	d_add(new_dentry, NULL);
-	d_move(old_dentry, new_dentry);
+	list_for_each_entry(srs, &todo, list) {
+		d_add(srs->new_dentry, NULL);
+		d_move(srs->old_dentry, srs->new_dentry);
+	}
 
 	/* Remove from old parent's list and insert into new parent's list. */
 	sysfs_unlink_sibling(sd);
@@ -956,14 +1032,17 @@ again:
 	sd->s_parent = new_parent_sd;
 	sysfs_link_sibling(sd);
 
- out_unlock:
+out_unlock:
 	mutex_unlock(&sysfs_mutex);
-	mutex_unlock(&new_parent->d_inode->i_mutex);
-	mutex_unlock(&old_parent->d_inode->i_mutex);
- out:
-	dput(new_parent);
-	dput(old_dentry);
-	dput(new_dentry);
+	mutex_unlock(&new_parent_inode->i_mutex);
+	mutex_unlock(&old_parent_inode->i_mutex);
+
+out_release:
+	iput(new_parent_inode);
+	iput(old_parent_inode);
+	post_rename(&todo);
+	sysfs_release_supers();
+out:
 	mutex_unlock(&sysfs_rename_mutex);
 	return error;
 }


Patches currently in gregkh-2.6 which might be from ebiederm@xmission.com are

driver-core/kobject-fix-kobject_rename-and-config_sysfs.patch
driver-core/kobject-cleanup-kobject_rename-and-config_sysfs.patch
driver-core/sysfs-implement-__sysfs_get_dentry.patch
driver-core/sysfs-introduce-sysfs_sd_setattr-and-fix-sysfs_chmod.patch
driver-core/sysfs-sysfs_get_dentry-add-a-sb-parameter.patch
driver-core/sysfs-rename-support-multiple-superblocks.patch
driver-core/sysfs-support-for-preventing-unmounts.patch
driver-core/sysfs-sysfs_chmod_file-handle-multiple-superblocks.patch
