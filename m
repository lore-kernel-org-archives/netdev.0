From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 05/15] sysfs: Rename Support multiple superblocks
Date: Thu, 03 Jul 2008 18:10:05 -0700
Message-ID: <m1d4luihea.fsf_-_@frodo.ebiederm.org>
References: <20080618170729.808539948@theryb.frec.bull.fr>
	<486706C9.9040303@gmail.com> <m18wwmsqdv.fsf@frodo.ebiederm.org>
	<4869D314.5030403@gmail.com> <m1ej6enep7.fsf@frodo.ebiederm.org>
	<486A0751.9080602@gmail.com> <m1wsk5hjm0.fsf@frodo.ebiederm.org>
	<486AF4FA.8020805@gmail.com> <m1ej6d9c2r.fsf@frodo.ebiederm.org>
	<486B060C.7030607@gmail.com> <m14p78s02q.fsf@frodo.ebiederm.org>
	<486C4515.1070007@gmail.com> <m1hcb7o8lv.fsf@frodo.ebiederm.org>
	<486CB051.5000507@fr.ibm.com> <m14p77m9uy.fsf@frodo.ebiederm.org>
	<486CF71F.5090405@gmail.com> <m1y74iiidz.fsf_-_@frodo.ebiederm.org>
	<m1tzf6ihlz.fsf_-_@frodo.ebiederm.org>
	<m1prpuihjb.fsf_-_@frodo.ebiederm.org>
	<m1lk0iihhp.fsf_-_@frodo.ebiederm.org>
	<m1hcb6ihfz.fsf_-_@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <htejun@gmail.com>, Daniel Lezcano <dlezcano@fr.ibm.com>,
	linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>,
	Linux Containers <containers@lists.osdl.org>,
	Benjamin Thery <benjamin.thery@bull.net>,
	<netdev@vger.kernel.org>
To: Greg Kroah-Hartman <gregkh@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:38467 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755062AbYGDBLo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 21:11:44 -0400
In-Reply-To: <m1hcb6ihfz.fsf_-_@frodo.ebiederm.org> (Eric W. Biederman's
	message of "Thu, 03 Jul 2008 18:09:04 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch modifies the sysfs_rename_dir and sysfs_move_dir routines
to support multiple sysfs dentry tries rooted in different
sysfs superblocks.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Acked-by: Tejun Heo <tj@kernel.org>
---
 fs/sysfs/dir.c |  193 +++++++++++++++++++++++++++++++++++++++-----------------
 1 files changed, 136 insertions(+), 57 deletions(-)

diff --git a/fs/sysfs/dir.c b/fs/sysfs/dir.c
index df9934a..b2d92ea 100644
--- a/fs/sysfs/dir.c
+++ b/fs/sysfs/dir.c
@@ -803,43 +803,113 @@ static struct dentry *__sysfs_get_dentry(struct super_block *sb,
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
@@ -850,17 +920,21 @@ int sysfs_rename_dir(struct kobject * kobj, const char *new_name)
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
@@ -869,10 +943,12 @@ int sysfs_move_dir(struct kobject *kobj, struct kobject *new_parent_kobj)
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
@@ -881,26 +957,29 @@ int sysfs_move_dir(struct kobject *kobj, struct kobject *new_parent_kobj)
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
+	sysfs_grab_supers();
+	error = prep_rename(&todo, sd, new_parent_sd, sd->s_name);
+	if (error)
+		goto out_release;
 
-	new_parent = sysfs_get_dentry(sysfs_sb, new_parent_sd);
-	if (IS_ERR(new_parent)) {
-		error = PTR_ERR(new_parent);
-		new_parent = NULL;
-		goto out;
-	}
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
@@ -909,14 +988,11 @@ again:
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
@@ -925,14 +1001,17 @@ again:
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
-- 
1.5.3.rc6.17.g1911

