From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 06/10] sysfs: sysfs_chmod_file handle multiple superblocks
Date: Sat, 01 Dec 2007 02:25:44 -0700
Message-ID: <m1fxym7omf.fsf_-_@ebiederm.dsl.xmission.com>
References: <m163zi9425.fsf@ebiederm.dsl.xmission.com>
	<m11wa693t0.fsf@ebiederm.dsl.xmission.com>
	<m1wsry7p60.fsf_-_@ebiederm.dsl.xmission.com>
	<m1sl2m7p1c.fsf_-_@ebiederm.dsl.xmission.com>
	<m1odda7oxs.fsf_-_@ebiederm.dsl.xmission.com>
	<m1k5ny7oqb.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <htejun@gmail.com>,
	Linux Containers <containers@lists.osdl.org>,
	<netdev@vger.kernel.org>, cornelia.huck@de.ibm.com,
	stern@rowland.harvard.edu, kay.sievers@vrfy.org,
	<linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
To: Greg Kroah-Hartman <gregkh@suse.de>, Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:49293 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751059AbXLAJ1k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 04:27:40 -0500
In-Reply-To: <m1k5ny7oqb.fsf_-_@ebiederm.dsl.xmission.com> (Eric
	W. Biederman's message of "Sat, 01 Dec 2007 02:23:24 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Teach sysfs_chmod_file how to handle multiple sysfs superblocks.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/sysfs/file.c |   51 ++++++++++++++++++++++++++++-----------------------
 1 files changed, 28 insertions(+), 23 deletions(-)

diff --git a/fs/sysfs/file.c b/fs/sysfs/file.c
index 8c7bba0..ade6140 100644
--- a/fs/sysfs/file.c
+++ b/fs/sysfs/file.c
@@ -558,7 +558,8 @@ EXPORT_SYMBOL_GPL(sysfs_add_file_to_group);
 int sysfs_chmod_file(struct kobject *kobj, struct attribute *attr, mode_t mode)
 {
 	struct sysfs_dirent *victim_sd = NULL;
-	struct dentry *victim = NULL;
+	struct super_block *sb;
+	struct dentry *victim;
 	struct inode * inode;
 	struct iattr newattrs;
 	int rc;
@@ -569,31 +570,35 @@ int sysfs_chmod_file(struct kobject *kobj, struct attribute *attr, mode_t mode)
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
-
-	mutex_lock(&inode->i_mutex);
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
 
-	newattrs.ia_mode = (mode & S_IALLUGO) | (inode->i_mode & ~S_IALLUGO);
-	newattrs.ia_valid = ATTR_MODE | ATTR_CTIME;
-	rc = notify_change(victim, &newattrs);
+		inode = victim->d_inode;
+		mutex_lock(&inode->i_mutex);
+		newattrs.ia_mode = (mode & S_IALLUGO) | (inode->i_mode & ~S_IALLUGO);
+		newattrs.ia_valid = ATTR_MODE | ATTR_CTIME;
+		rc = notify_change(victim, &newattrs);
+		if (rc == 0) {
+			mutex_lock(&sysfs_mutex);
+			victim_sd->s_mode = newattrs.ia_mode;
+			mutex_unlock(&sysfs_mutex);
+		}
+		mutex_unlock(&inode->i_mutex);
 
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
1.5.3.rc6.17.g1911

