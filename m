From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 07/15] sysfs: sysfs_chmod_file handle multiple superblocks
Date: Thu, 03 Jul 2008 18:13:05 -0700
Message-ID: <m14p76ih9a.fsf_-_@frodo.ebiederm.org>
References: <20080618170729.808539948@theryb.frec.bull.fr>
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
	<m1d4luihea.fsf_-_@frodo.ebiederm.org>
	<m18wwiihbn.fsf_-_@frodo.ebiederm.org>
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
Received: from out01.mta.xmission.com ([166.70.13.231]:57929 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754104AbYGDBVr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 21:21:47 -0400
In-Reply-To: <m18wwiihbn.fsf_-_@frodo.ebiederm.org> (Eric W. Biederman's
	message of "Thu, 03 Jul 2008 18:11:40 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Teach sysfs_chmod_file how to handle multiple sysfs superblocks.
Since we only have one inode per sd the only thing we have to deal
with is multiple dentries for sending fs notifications.  This might
dup the inode notifications oh well.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/sysfs/file.c |   39 +++++++++++++++++++++++++--------------
 1 files changed, 25 insertions(+), 14 deletions(-)

diff --git a/fs/sysfs/file.c b/fs/sysfs/file.c
index 1304b3a..5955ae9 100644
--- a/fs/sysfs/file.c
+++ b/fs/sysfs/file.c
@@ -574,8 +574,8 @@ EXPORT_SYMBOL_GPL(sysfs_add_file_to_group);
 int sysfs_chmod_file(struct kobject *kobj, struct attribute *attr, mode_t mode)
 {
 	struct sysfs_dirent *victim_sd = NULL;
-	struct dentry *victim = NULL;
-	struct inode * inode;
+	struct super_block *sb;
+	struct inode * inode = NULL;
 	struct iattr newattrs;
 	int rc;
 
@@ -584,31 +584,42 @@ int sysfs_chmod_file(struct kobject *kobj, struct attribute *attr, mode_t mode)
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
-- 
1.5.3.rc6.17.g1911

