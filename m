From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 03/10] sysfs: sysfs_get_dentry add a sb parameter
Date: Sat, 01 Dec 2007 02:16:47 -0700
Message-ID: <m1sl2m7p1c.fsf_-_@ebiederm.dsl.xmission.com>
References: <m163zi9425.fsf@ebiederm.dsl.xmission.com>
	<m11wa693t0.fsf@ebiederm.dsl.xmission.com>
	<m1wsry7p60.fsf_-_@ebiederm.dsl.xmission.com>
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
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:47529 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751240AbXLAJSo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 04:18:44 -0500
In-Reply-To: <m1wsry7p60.fsf_-_@ebiederm.dsl.xmission.com> (Eric
	W. Biederman's message of "Sat, 01 Dec 2007 02:13:59 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In preparation for multiple mounts of sysfs add a superblock parameter to
sysfs_get_dentry.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/sysfs/dir.c   |   11 ++++++-----
 fs/sysfs/file.c  |    2 +-
 fs/sysfs/sysfs.h |    2 +-
 3 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/fs/sysfs/dir.c b/fs/sysfs/dir.c
index 3371629..cff2b12 100644
--- a/fs/sysfs/dir.c
+++ b/fs/sysfs/dir.c
@@ -84,6 +84,7 @@ static void sysfs_unlink_sibling(struct sysfs_dirent *sd)
 
 /**
  *	sysfs_get_dentry - get dentry for the given sysfs_dirent
+ *	@sb: superblock of the dentry to return
  *	@sd: sysfs_dirent of interest
  *
  *	Get dentry for @sd.  Dentry is looked up if currently not
@@ -96,9 +97,9 @@ static void sysfs_unlink_sibling(struct sysfs_dirent *sd)
  *	RETURNS:
  *	Pointer to found dentry on success, ERR_PTR() value on error.
  */
-struct dentry *sysfs_get_dentry(struct sysfs_dirent *sd)
+struct dentry *sysfs_get_dentry(struct super_block *sb, struct sysfs_dirent *sd)
 {
-	struct dentry *dentry = dget(sysfs_sb->s_root);
+	struct dentry *dentry = dget(sb->s_root);
 
 	while (dentry->d_fsdata != sd) {
 		struct sysfs_dirent *cur;
@@ -778,7 +779,7 @@ int sysfs_rename_dir(struct kobject * kobj, const char *new_name)
 		goto out;	/* nothing to rename */
 
 	/* get the original dentry */
-	old_dentry = sysfs_get_dentry(sd);
+	old_dentry = sysfs_get_dentry(sysfs_sb, sd);
 	if (IS_ERR(old_dentry)) {
 		error = PTR_ERR(old_dentry);
 		goto out;
@@ -845,14 +846,14 @@ int sysfs_move_dir(struct kobject *kobj, struct kobject *new_parent_kobj)
 		goto out;	/* nothing to move */
 
 	/* get dentries */
-	old_dentry = sysfs_get_dentry(sd);
+	old_dentry = sysfs_get_dentry(sysfs_sb, sd);
 	if (IS_ERR(old_dentry)) {
 		error = PTR_ERR(old_dentry);
 		goto out;
 	}
 	old_parent = old_dentry->d_parent;
 
-	new_parent = sysfs_get_dentry(new_parent_sd);
+	new_parent = sysfs_get_dentry(sysfs_sb, new_parent_sd);
 	if (IS_ERR(new_parent)) {
 		error = PTR_ERR(new_parent);
 		goto out;
diff --git a/fs/sysfs/file.c b/fs/sysfs/file.c
index ad13151..8c7bba0 100644
--- a/fs/sysfs/file.c
+++ b/fs/sysfs/file.c
@@ -569,7 +569,7 @@ int sysfs_chmod_file(struct kobject *kobj, struct attribute *attr, mode_t mode)
 		goto out;
 
 	mutex_lock(&sysfs_rename_mutex);
-	victim = sysfs_get_dentry(victim_sd);
+	victim = sysfs_get_dentry(sysfs_sb, victim_sd);
 	mutex_unlock(&sysfs_rename_mutex);
 	if (IS_ERR(victim)) {
 		rc = PTR_ERR(victim);
diff --git a/fs/sysfs/sysfs.h b/fs/sysfs/sysfs.h
index 3308759..d4269ba 100644
--- a/fs/sysfs/sysfs.h
+++ b/fs/sysfs/sysfs.h
@@ -112,7 +112,7 @@ extern spinlock_t sysfs_assoc_lock;
 extern const struct file_operations sysfs_dir_operations;
 extern const struct inode_operations sysfs_dir_inode_operations;
 
-struct dentry *sysfs_get_dentry(struct sysfs_dirent *sd);
+struct dentry *sysfs_get_dentry(struct super_block *sb, struct sysfs_dirent *sd);
 struct sysfs_dirent *sysfs_get_active_two(struct sysfs_dirent *sd);
 void sysfs_put_active_two(struct sysfs_dirent *sd);
 void sysfs_addrm_start(struct sysfs_addrm_cxt *acxt,
-- 
1.5.3.rc6.17.g1911

