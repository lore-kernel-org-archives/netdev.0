From: <gregkh@suse.de>
Subject: patch sysfs-sysfs_get_dentry-add-a-sb-parameter.patch added to gregkh-2.6 tree
Date: Tue, 19 Aug 2008 19:16:42 -0700
Message-ID: <12191986022763@kroah.org>
References: <m1lk0iihhp.fsf_-_@frodo.ebiederm.org>
To: ebiederm@xmission.com, akpm@linux-foundation.org,
	benjamin.thery@bull.net, containers@lists.osdl.org,
	dlezcano@fr.ibm.com, gregkh@suse.de, htejun@gmail.com,
	netdev@vger.kernel.org, tj
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:55433 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750926AbYHTCWz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Aug 2008 22:22:55 -0400
In-Reply-To: <m1lk0iihhp.fsf_-_@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is a note to let you know that I've just added the patch titled

    Subject: sysfs: sysfs_get_dentry add a sb parameter

to my gregkh-2.6 tree.  Its filename is

    sysfs-sysfs_get_dentry-add-a-sb-parameter.patch

This tree can be found at 
    http://www.kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/patches/


>From ebiederm@xmission.com Thu Jul  3 18:11:49 2008
From: Eric W. Biederman <ebiederm@xmission.com>
Date: Thu, 03 Jul 2008 18:08:02 -0700
Subject: sysfs: sysfs_get_dentry add a sb parameter
To: Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <htejun@gmail.com>, Daniel Lezcano <dlezcano@fr.ibm.com>, linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>, Linux Containers <containers@lists.osdl.org>, Benjamin Thery <benjamin.thery@bull.net>, <netdev@vger.kernel.org>
Message-ID: <m1lk0iihhp.fsf_-_@frodo.ebiederm.org>

From: Eric W. Biederman <ebiederm@xmission.com>


In preparation for multiple mounts of sysfs add a superblock parameter to
sysfs_get_dentry.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Acked-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 fs/sysfs/dir.c   |   12 +++++++-----
 fs/sysfs/file.c  |    2 +-
 fs/sysfs/sysfs.h |    3 ++-
 3 files changed, 10 insertions(+), 7 deletions(-)

--- a/fs/sysfs/dir.c
+++ b/fs/sysfs/dir.c
@@ -85,6 +85,7 @@ static void sysfs_unlink_sibling(struct 
 
 /**
  *	sysfs_get_dentry - get dentry for the given sysfs_dirent
+ *	@sb: superblock of the dentry to return
  *	@sd: sysfs_dirent of interest
  *
  *	Get dentry for @sd.  Dentry is looked up if currently not
@@ -97,9 +98,10 @@ static void sysfs_unlink_sibling(struct 
  *	RETURNS:
  *	Pointer to found dentry on success, ERR_PTR() value on error.
  */
-struct dentry *sysfs_get_dentry(struct sysfs_dirent *sd)
+struct dentry *sysfs_get_dentry(struct super_block *sb,
+				struct sysfs_dirent *sd)
 {
-	struct dentry *dentry = dget(sysfs_sb->s_root);
+	struct dentry *dentry = dget(sb->s_root);
 
 	while (dentry->d_fsdata != sd) {
 		struct sysfs_dirent *cur;
@@ -808,7 +810,7 @@ int sysfs_rename_dir(struct kobject * ko
 		goto out;	/* nothing to rename */
 
 	/* get the original dentry */
-	old_dentry = sysfs_get_dentry(sd);
+	old_dentry = sysfs_get_dentry(sysfs_sb, sd);
 	if (IS_ERR(old_dentry)) {
 		error = PTR_ERR(old_dentry);
 		old_dentry = NULL;
@@ -872,7 +874,7 @@ int sysfs_move_dir(struct kobject *kobj,
 		goto out;	/* nothing to move */
 
 	/* get dentries */
-	old_dentry = sysfs_get_dentry(sd);
+	old_dentry = sysfs_get_dentry(sysfs_sb, sd);
 	if (IS_ERR(old_dentry)) {
 		error = PTR_ERR(old_dentry);
 		old_dentry = NULL;
@@ -880,7 +882,7 @@ int sysfs_move_dir(struct kobject *kobj,
 	}
 	old_parent = old_dentry->d_parent;
 
-	new_parent = sysfs_get_dentry(new_parent_sd);
+	new_parent = sysfs_get_dentry(sysfs_sb, new_parent_sd);
 	if (IS_ERR(new_parent)) {
 		error = PTR_ERR(new_parent);
 		new_parent = NULL;
--- a/fs/sysfs/file.c
+++ b/fs/sysfs/file.c
@@ -589,7 +589,7 @@ int sysfs_chmod_file(struct kobject *kob
 		goto out;
 
 	mutex_lock(&sysfs_rename_mutex);
-	victim = sysfs_get_dentry(victim_sd);
+	victim = sysfs_get_dentry(sysfs_sb, victim_sd);
 	mutex_unlock(&sysfs_rename_mutex);
 	if (IS_ERR(victim)) {
 		rc = PTR_ERR(victim);
--- a/fs/sysfs/sysfs.h
+++ b/fs/sysfs/sysfs.h
@@ -112,7 +112,8 @@ extern spinlock_t sysfs_assoc_lock;
 extern const struct file_operations sysfs_dir_operations;
 extern const struct inode_operations sysfs_dir_inode_operations;
 
-struct dentry *sysfs_get_dentry(struct sysfs_dirent *sd);
+struct dentry *sysfs_get_dentry(struct super_block *sb,
+				struct sysfs_dirent *sd);
 struct sysfs_dirent *sysfs_get_active_two(struct sysfs_dirent *sd);
 void sysfs_put_active_two(struct sysfs_dirent *sd);
 void sysfs_addrm_start(struct sysfs_addrm_cxt *acxt,


Patches currently in gregkh-2.6 which might be from ebiederm@xmission.com are

driver-core/kobject-fix-kobject_rename-and-config_sysfs.patch
driver-core/kobject-cleanup-kobject_rename-and-config_sysfs.patch
driver-core/sysfs-implement-__sysfs_get_dentry.patch
driver-core/sysfs-introduce-sysfs_sd_setattr-and-fix-sysfs_chmod.patch
driver-core/sysfs-sysfs_get_dentry-add-a-sb-parameter.patch
driver-core/sysfs-rename-support-multiple-superblocks.patch
driver-core/sysfs-support-for-preventing-unmounts.patch
driver-core/sysfs-sysfs_chmod_file-handle-multiple-superblocks.patch
