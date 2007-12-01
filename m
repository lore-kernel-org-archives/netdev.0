From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 01/10] sysfs: Make sysfs_mount static again.
Date: Sat, 01 Dec 2007 02:12:27 -0700
Message-ID: <m11wa693t0.fsf@ebiederm.dsl.xmission.com>
References: <m163zi9425.fsf@ebiederm.dsl.xmission.com>
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
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:46672 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750938AbXLAJOW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 04:14:22 -0500
In-Reply-To: <m163zi9425.fsf@ebiederm.dsl.xmission.com> (Eric W. Biederman's
	message of "Sat, 01 Dec 2007 02:06:58 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In preparation for supporting multiple mounts of sysfs I need to
remove all assumptions that we have a single mount of sysfs.  So this
patch modifies sysfs_open_file to use the vfsmount from the struct
file instead of fibbing and using the global vfsmount.

We get a little more noise this way but we should continue to get the
useful part of the debugging information.

This was the reason I made sysfs_mount static earlier.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/sysfs/file.c  |    2 +-
 fs/sysfs/mount.c |    2 +-
 fs/sysfs/sysfs.h |    1 -
 3 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/sysfs/file.c b/fs/sysfs/file.c
index 87e4a0e..ad13151 100644
--- a/fs/sysfs/file.c
+++ b/fs/sysfs/file.c
@@ -330,7 +330,7 @@ static int sysfs_open_file(struct inode *inode, struct file *file)
 	int error = -EACCES;
 	char *p;
 
-	p = d_path(file->f_dentry, sysfs_mount, last_sysfs_file,
+	p = d_path(file->f_dentry, file->f_vfsmnt, last_sysfs_file,
 		   sizeof(last_sysfs_file));
 	if (p)
 		memmove(last_sysfs_file, p, strlen(p) + 1);
diff --git a/fs/sysfs/mount.c b/fs/sysfs/mount.c
index a3410d6..7416826 100644
--- a/fs/sysfs/mount.c
+++ b/fs/sysfs/mount.c
@@ -22,7 +22,7 @@
 /* Random magic number */
 #define SYSFS_MAGIC 0x62656572
 
-struct vfsmount *sysfs_mount;
+static struct vfsmount *sysfs_mount;
 struct super_block * sysfs_sb = NULL;
 struct kmem_cache *sysfs_dir_cachep;
 
diff --git a/fs/sysfs/sysfs.h b/fs/sysfs/sysfs.h
index 52aaa8c..ff17f8d 100644
--- a/fs/sysfs/sysfs.h
+++ b/fs/sysfs/sysfs.h
@@ -91,7 +91,6 @@ struct sysfs_addrm_cxt {
 extern struct sysfs_dirent sysfs_root;
 extern struct super_block *sysfs_sb;
 extern struct kmem_cache *sysfs_dir_cachep;
-extern struct vfsmount *sysfs_mount;
 
 /*
  * dir.c
-- 
1.5.3.rc6.17.g1911

