From: <gregkh@suse.de>
Subject: patch sysfs-introduce-sysfs_sd_setattr-and-fix-sysfs_chmod.patch added to gregkh-2.6 tree
Date: Tue, 19 Aug 2008 19:16:11 -0700
Message-ID: <12191985712817@kroah.org>
References: <m18wwiihbn.fsf_-_@frodo.ebiederm.org>
To: ebiederm@xmission.com, akpm@linux-foundation.org,
	benjamin.thery@bull.net, containers@lists.osdl.org,
	dlezcano@fr.ibm.com, gregkh@suse.de, htejun@gmail.com,
	netdev@vger.kernel.org, tj
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:36553 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751992AbYHTCVT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Aug 2008 22:21:19 -0400
In-Reply-To: <m18wwiihbn.fsf_-_@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is a note to let you know that I've just added the patch titled

    Subject: sysfs: Introduce sysfs_sd_setattr and fix sysfs_chmod

to my gregkh-2.6 tree.  Its filename is

    sysfs-introduce-sysfs_sd_setattr-and-fix-sysfs_chmod.patch

This tree can be found at 
    http://www.kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/patches/


>From ebiederm@xmission.com Thu Jul  3 18:21:56 2008
From: Eric W. Biederman <ebiederm@xmission.com>
Date: Thu, 03 Jul 2008 18:11:40 -0700
Subject: sysfs: Introduce sysfs_sd_setattr and fix sysfs_chmod
To: Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <htejun@gmail.com>, Daniel Lezcano <dlezcano@fr.ibm.com>, linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>, Linux Containers <containers@lists.osdl.org>, Benjamin Thery <benjamin.thery@bull.net>, <netdev@vger.kernel.org>
Message-ID: <m18wwiihbn.fsf_-_@frodo.ebiederm.org>

From: Eric W. Biederman <ebiederm@xmission.com>


Currently sysfs_chmod calls sys_setattr which in turn calls
inode_change_ok which checks to see if it is ok for the current user
space process to change tha attributes. Since sysfs_chmod_file has
only kernel mode clients denying them permission if user space is the
problem is completely inappropriate.

Therefore factor out sysfs_sd_setattr which does not call
inode_change_ok and modify sysfs_chmod_file to call it.

In addition setting victim_sd->s_mode explicitly in sysfs_chmod_file
is redundant so remove that as well.

Thanks to Tejun Heo <htejun@gmail.com>, and
Daniel Lezcano <dlezcano@fr.ibm.com> for working on this
and spotting this case.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
Acked-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 fs/sysfs/file.c  |    5 +----
 fs/sysfs/inode.c |   23 ++++++++++++++++-------
 fs/sysfs/sysfs.h |    1 +
 3 files changed, 18 insertions(+), 11 deletions(-)

--- a/fs/sysfs/file.c
+++ b/fs/sysfs/file.c
@@ -604,13 +604,10 @@ int sysfs_chmod_file(struct kobject *kob
 	newattrs.ia_mode = (mode & S_IALLUGO) | (inode->i_mode & ~S_IALLUGO);
 	newattrs.ia_valid = ATTR_MODE | ATTR_CTIME;
 	newattrs.ia_ctime = current_fs_time(inode->i_sb);
-	rc = sysfs_setattr(victim, &newattrs);
+	rc = sysfs_sd_setattr(victim_sd, inode, &newattrs);
 
 	if (rc == 0) {
 		fsnotify_change(victim, newattrs.ia_valid);
-		mutex_lock(&sysfs_mutex);
-		victim_sd->s_mode = newattrs.ia_mode;
-		mutex_unlock(&sysfs_mutex);
 	}
 
 	mutex_unlock(&inode->i_mutex);
--- a/fs/sysfs/inode.c
+++ b/fs/sysfs/inode.c
@@ -42,10 +42,9 @@ int __init sysfs_inode_init(void)
 	return bdi_init(&sysfs_backing_dev_info);
 }
 
-int sysfs_setattr(struct dentry * dentry, struct iattr * iattr)
+int sysfs_sd_setattr(struct sysfs_dirent *sd, struct inode *inode,
+			struct iattr * iattr)
 {
-	struct inode * inode = dentry->d_inode;
-	struct sysfs_dirent * sd = dentry->d_fsdata;
 	struct iattr * sd_iattr;
 	unsigned int ia_valid = iattr->ia_valid;
 	int error;
@@ -55,10 +54,6 @@ int sysfs_setattr(struct dentry * dentry
 
 	sd_iattr = sd->s_iattr;
 
-	error = inode_change_ok(inode, iattr);
-	if (error)
-		return error;
-
 	iattr->ia_valid &= ~ATTR_SIZE; /* ignore size changes */
 
 	error = inode_setattr(inode, iattr);
@@ -104,6 +99,20 @@ int sysfs_setattr(struct dentry * dentry
 	return error;
 }
 
+int sysfs_setattr(struct dentry *dentry, struct iattr *iattr)
+{
+	struct inode * inode = dentry->d_inode;
+	struct sysfs_dirent * sd = dentry->d_fsdata;
+	int error;
+
+	error = inode_change_ok(inode, iattr);
+	if (error)
+		return error;
+
+	return sysfs_sd_setattr(sd, inode, iattr);
+}
+
+
 static inline void set_default_inode_attr(struct inode * inode, mode_t mode)
 {
 	inode->i_mode = mode;
--- a/fs/sysfs/sysfs.h
+++ b/fs/sysfs/sysfs.h
@@ -156,6 +156,7 @@ static inline void __sysfs_put(struct sy
  * inode.c
  */
 struct inode *sysfs_get_inode(struct sysfs_dirent *sd);
+int sysfs_sd_setattr(struct sysfs_dirent *sd, struct inode *inode, struct iattr *iattr);
 int sysfs_setattr(struct dentry *dentry, struct iattr *iattr);
 int sysfs_hash_and_remove(struct sysfs_dirent *dir_sd, const char *name);
 int sysfs_inode_init(void);


Patches currently in gregkh-2.6 which might be from ebiederm@xmission.com are

driver-core/kobject-fix-kobject_rename-and-config_sysfs.patch
driver-core/kobject-cleanup-kobject_rename-and-config_sysfs.patch
driver-core/sysfs-implement-__sysfs_get_dentry.patch
driver-core/sysfs-introduce-sysfs_sd_setattr-and-fix-sysfs_chmod.patch
driver-core/sysfs-sysfs_get_dentry-add-a-sb-parameter.patch
driver-core/sysfs-rename-support-multiple-superblocks.patch
driver-core/sysfs-support-for-preventing-unmounts.patch
driver-core/sysfs-sysfs_chmod_file-handle-multiple-superblocks.patch
