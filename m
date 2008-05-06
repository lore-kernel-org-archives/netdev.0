From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH 03/11] sysfs: Implement __sysfs_get_dentry
Date: Tue, 06 May 2008 19:31:00 +0200
Message-ID: <20080506173334.874538157@theryb.frec.bull.fr>
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
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:50136 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760367AbYEFRg4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 13:36:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sysfs: Implement __sysfs_get_dentry

This function is similar but much simpler to sysfs_get_dentry
returns a sysfs dentry if one curently exists.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
Acked-by: Benjamin Thery <benjamin.thery@bull.net>
---
 fs/sysfs/dir.c |   39 +++++++++++++++++++++++++++++++++++++++
 1 file changed, 39 insertions(+)

Index: linux-vanilla/fs/sysfs/dir.c
===================================================================
--- linux-vanilla.orig/fs/sysfs/dir.c
+++ linux-vanilla/fs/sysfs/dir.c
@@ -768,6 +768,45 @@ void sysfs_remove_dir(struct kobject * k
 	__sysfs_remove_dir(sd);
 }
 
+/**
+ *	__sysfs_get_dentry - get dentry for the given sysfs_dirent
+ *	@sb: superblock of the dentry to return
+ *	@sd: sysfs_dirent of interest
+ *
+ *	Get dentry for @sd.  Only return a dentry if one currently
+ *	exists.
+ *
+ *	LOCKING:
+ *	Kernel thread context (may sleep)
+ *
+ *	RETURNS:
+ *	Pointer to found dentry on success, NULL on failure.
+ */
+static struct dentry *__sysfs_get_dentry(struct super_block *sb,
+					 struct sysfs_dirent *sd)
+{
+	struct inode *inode;
+	struct dentry *dentry = NULL;
+
+	inode = ilookup5_nowait(sysfs_sb, sd->s_ino, sysfs_ilookup_test, sd);
+	if (inode && !(inode->i_state & I_NEW)) {
+		struct dentry *alias;
+		spin_lock(&dcache_lock);
+		list_for_each_entry(alias, &inode->i_dentry, d_alias) {
+			if (!IS_ROOT(alias) && d_unhashed(alias))
+				continue;
+			if (alias->d_sb != sb)
+				continue;
+			dentry = alias;
+			dget_locked(dentry);
+			break;
+		}
+		spin_unlock(&dcache_lock);
+	}
+	iput(inode);
+	return dentry;
+}
+
 int sysfs_rename_dir(struct kobject * kobj, const char *new_name)
 {
 	struct sysfs_dirent *sd = kobj->sd;

-- 
