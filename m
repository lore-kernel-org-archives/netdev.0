From: <gregkh@suse.de>
Subject: patch sysfs-sysfs_chmod_file-handle-multiple-superblocks.patch added to gregkh-2.6 tree
Date: Tue, 19 Aug 2008 19:16:35 -0700
Message-ID: <12191985952666@kroah.org>
References: <m14p76ih9a.fsf_-_@frodo.ebiederm.org>
To: ebiederm@xmission.com, akpm@linux-foundation.org,
	benjamin.thery@bull.net, containers@lists.osdl.org,
	dlezcano@fr.ibm.com, gregkh@suse.de, htejun@gmail.com,
	netdev@vger.kernel.org, tj
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:55405 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751260AbYHTCWb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Aug 2008 22:22:31 -0400
In-Reply-To: <m14p76ih9a.fsf_-_@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is a note to let you know that I've just added the patch titled

    Subject: sysfs: sysfs_chmod_file handle multiple superblocks

to my gregkh-2.6 tree.  Its filename is

    sysfs-sysfs_chmod_file-handle-multiple-superblocks.patch

This tree can be found at 
    http://www.kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/patches/


>From ebiederm@xmission.com Thu Jul  3 18:21:56 2008
From: Eric W. Biederman <ebiederm@xmission.com>
Date: Thu, 03 Jul 2008 18:13:05 -0700
Subject: sysfs: sysfs_chmod_file handle multiple superblocks
To: Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <htejun@gmail.com>, Daniel Lezcano <dlezcano@fr.ibm.com>, linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>, Linux Containers <containers@lists.osdl.org>, Benjamin Thery <benjamin.thery@bull.net>, <netdev@vger.kernel.org>
Message-ID: <m14p76ih9a.fsf_-_@frodo.ebiederm.org>


From: Eric W. Biederman <ebiederm@xmission.com>

Teach sysfs_chmod_file how to handle multiple sysfs superblocks.
Since we only have one inode per sd the only thing we have to deal
with is multiple dentries for sending fs notifications.  This might
dup the inode notifications oh well.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
Acked-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 fs/sysfs/file.c |   39 +++++++++++++++++++++++++--------------
 1 file changed, 25 insertions(+), 14 deletions(-)

--- a/fs/sysfs/file.c
+++ b/fs/sysfs/file.c
@@ -578,8 +578,8 @@ EXPORT_SYMBOL_GPL(sysfs_add_file_to_grou
 int sysfs_chmod_file(struct kobject *kobj, struct attribute *attr, mode_t mode)
 {
 	struct sysfs_dirent *victim_sd = NULL;
-	struct dentry *victim = NULL;
-	struct inode * inode;
+	struct super_block *sb;
+	struct inode * inode = NULL;
 	struct iattr newattrs;
 	int rc;
 
@@ -588,31 +588,42 @@ int sysfs_chmod_file(struct kobject *kob
 	if (!victim_sd)
 		goto out;
 
-	mutex_lock(&sysfs_rename_mutex);
-	victim = sysfs_get_dentry(sysfs_sb, victim_sd);
-	mutex_unlock(&sysfs_rename_mutex);
-	if (IS_ERR(victim)) {
-		rc = PTR_ERR(victim);
-		victim = NULL;
-		goto out;
-	}
-
-	inode = victim->d_inode;
+	rc = -ENOENT;
+	mutex_lock(&sysfs_mutex);
+	inode = sysfs_get_inode(victim_sd);
+	mutex_unlock(&sysfs_mutex);
+	if (!inode)
+ 		goto out;
 
+	mutex_lock(&sysfs_rename_mutex);
+	sysfs_grab_supers();
 	mutex_lock(&inode->i_mutex);
 
 	newattrs.ia_mode = (mode & S_IALLUGO) | (inode->i_mode & ~S_IALLUGO);
 	newattrs.ia_valid = ATTR_MODE | ATTR_CTIME;
 	newattrs.ia_ctime = current_fs_time(inode->i_sb);
 	rc = sysfs_sd_setattr(victim_sd, inode, &newattrs);
+	if (rc)
+		goto out_unlock;
+
+	list_for_each_entry(sb, &sysfs_fs_type.fs_supers, s_instances) {
+		/* Ignore it when the dentry does not exist on the
+		 * target superblock.
+		 */
+		struct dentry *	victim = sysfs_get_dentry(sb, victim_sd);
+		if (IS_ERR(victim))
+			continue;
 
-	if (rc == 0) {
 		fsnotify_change(victim, newattrs.ia_valid);
+		dput(victim);
 	}
 
+ out_unlock:
 	mutex_unlock(&inode->i_mutex);
+	sysfs_release_supers();
+	mutex_unlock(&sysfs_rename_mutex);
  out:
-	dput(victim);
+	iput(inode);
 	sysfs_put(victim_sd);
 	return rc;
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
