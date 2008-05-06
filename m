From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH 05/11] sysfs: sysfs_chmod_file handle multiple superblocks
Date: Tue, 06 May 2008 19:31:20 +0200
Message-ID: <20080506173335.166635429@theryb.frec.bull.fr>
References: <20080506173030.653828076@theryb.frec.bull.fr>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Tejun Heo <htejun@gmail.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Al Viro <viro@ftp.linux.org.uk>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>, netdev@vger.kernel.org,
	Benjamin Thery <benjamin.thery@bull.net>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:50170 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760582AbYEFRhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 13:37:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sysfs: sysfs_chmod_file handle multiple superblocks

Teach sysfs_chmod_file how to handle multiple sysfs
superblocks.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
Acked-by: Benjamin Thery <benjamin.thery@bull.net>
---
 fs/sysfs/file.c |   54 ++++++++++++++++++++++++++++++------------------------
 1 file changed, 30 insertions(+), 24 deletions(-)

Index: linux-vanilla/fs/sysfs/file.c
===================================================================
--- linux-vanilla.orig/fs/sysfs/file.c
+++ linux-vanilla/fs/sysfs/file.c
@@ -560,7 +560,8 @@ EXPORT_SYMBOL_GPL(sysfs_add_file_to_grou
 int sysfs_chmod_file(struct kobject *kobj, struct attribute *attr, mode_t mode)
 {
 	struct sysfs_dirent *victim_sd = NULL;
-	struct dentry *victim = NULL;
+	struct super_block *sb;
+	struct dentry *victim;
 	struct inode * inode;
 	struct iattr newattrs;
 	int rc;
@@ -571,31 +572,36 @@ int sysfs_chmod_file(struct kobject *kob
 		goto out;
 
 	mutex_lock(&sysfs_rename_mutex);
-	victim = sysfs_get_dentry(sysfs_sb, victim_sd);
-	mutex_unlock(&sysfs_rename_mutex);
-	if (IS_ERR(victim)) {
-		rc = PTR_ERR(victim);
-		victim = NULL;
-		goto out;
-	}
-
-	inode = victim->d_inode;
+	sysfs_grab_supers();
+	list_for_each_entry(sb, &sysfs_fs_type.fs_supers, s_instances) {
+		victim = sysfs_get_dentry(sb, victim_sd);
+		if (victim == ERR_PTR(-EXDEV))
+			continue;
+		if (IS_ERR(victim)) {
+			rc = PTR_ERR(victim);
+			victim = NULL;
+			goto out_unlock;
+		}
+
+		inode = victim->d_inode;
+		mutex_lock(&inode->i_mutex);
+		newattrs.ia_mode = (mode & S_IALLUGO) |
+				   (inode->i_mode & ~S_IALLUGO);
+		newattrs.ia_valid = ATTR_MODE | ATTR_CTIME;
+		rc = notify_change(victim, &newattrs);
+		if (rc == 0) {
+			mutex_lock(&sysfs_mutex);
+			victim_sd->s_mode = newattrs.ia_mode;
+			mutex_unlock(&sysfs_mutex);
+		}
+		mutex_unlock(&inode->i_mutex);
 
-	mutex_lock(&inode->i_mutex);
-
-	newattrs.ia_mode = (mode & S_IALLUGO) | (inode->i_mode & ~S_IALLUGO);
-	newattrs.ia_valid = ATTR_MODE | ATTR_CTIME;
-	rc = notify_change(victim, &newattrs);
-
-	if (rc == 0) {
-		mutex_lock(&sysfs_mutex);
-		victim_sd->s_mode = newattrs.ia_mode;
-		mutex_unlock(&sysfs_mutex);
+		dput(victim);
 	}
-
-	mutex_unlock(&inode->i_mutex);
- out:
-	dput(victim);
+out_unlock:
+	sysfs_release_supers();
+	mutex_unlock(&sysfs_rename_mutex);
+out:
 	sysfs_put(victim_sd);
 	return rc;
 }

-- 
