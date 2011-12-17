From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH] 9p: Don't use ATTR_* values from fs.h in userspace facing  structs
Date: Sat, 17 Dec 2011 17:07:02 +0200
Message-ID: <1324134422-16642-1-git-send-email-levinsasha928@gmail.com>
Cc: v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>
To: ericvh@gmail.com, rminnich@sandia.gov, lucho@ionkov.net,
	davem@davemloft.net, aneesh.kumar@linux.vnet.ibm.com,
	jvrao@linux.vnet.ibm.com, viro@ZenIV.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:52457 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752443Ab1LQPIC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2011 10:08:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct p9_iattr_dotl is userspace facing, but the 'valid' field is documented
as follows:

	 * @valid: bitfield specifying which fields are valid
	 *         same as in struct iattr

Which means that the user has to know about kernel internal ATTR_* values.

On Fri, 2011-12-16 at 23:30 +0000, Al Viro wrote:
> They *are* kernel internal values and 9P is asking for trouble exposing
> them.  Translation: tomorrow we might reassign those as we bloody wish
> and any userland code that happens to rely on their values will break.
> At which point we'll handle complaints by pointing and laughing.
>
> It's a 9P bug; fix it there.  Turning random internal constants into a part
> of ABI is not going to work.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 fs/9p/vfs_inode_dotl.c |   31 ++++++++++++++++++++++++++++++-
 include/net/9p/9p.h    |   18 ++++++++++++++++++
 2 files changed, 48 insertions(+), 1 deletions(-)

diff --git a/fs/9p/vfs_inode_dotl.c b/fs/9p/vfs_inode_dotl.c
index 0b5745e..a948214 100644
--- a/fs/9p/vfs_inode_dotl.c
+++ b/fs/9p/vfs_inode_dotl.c
@@ -523,6 +523,35 @@ v9fs_vfs_getattr_dotl(struct vfsmount *mnt, struct dentry *dentry,
 	return 0;
 }
 
+int v9fs_vfs_iattr_to_9p_valid(u32 ia_valid)
+{
+	u32 valid = 0, i;
+	static u32 attr_map[][2] = {
+		{ATTR_MODE,		P9_ATTR_MODE},
+		{ATTR_UID,		P9_ATTR_UID},
+		{ATTR_SIZE,		P9_ATTR_SIZE},
+		{ATTR_ATIME,		P9_ATTR_ATIME},
+		{ATTR_MTIME,		P9_ATTR_MTIME},
+		{ATTR_CTIME,		P9_ATTR_CTIME},
+		{ATTR_ATIME_SET,	P9_ATTR_ATIME_SET},
+		{ATTR_MTIME_SET,	P9_ATTR_MTIME_SET},
+		{ATTR_FORCE,		P9_ATTR_FORCE},
+		{ATTR_ATTR_FLAG,	P9_ATTR_ATTR_FLAG},
+		{ATTR_KILL_SUID,	P9_ATTR_KILL_SUID},
+		{ATTR_KILL_SGID,	P9_ATTR_KILL_SGID},
+		{ATTR_FILE,		P9_ATTR_FILE},
+		{ATTR_KILL_PRIV,	P9_ATTR_KILL_PRIV},
+		{ATTR_OPEN,		P9_ATTR_OPEN},
+		{ATTR_TIMES_SET,	P9_ATTR_TIMES_SET},
+	};
+
+	for (i = 0; i < ARRAY_SIZE(attr_map); i++)
+		if (ia_valid & attr_map[i][0])
+			valid |= attr_map[i][1];
+
+	return valid;
+}
+
 /**
  * v9fs_vfs_setattr_dotl - set file metadata
  * @dentry: file whose metadata to set
@@ -543,7 +572,7 @@ int v9fs_vfs_setattr_dotl(struct dentry *dentry, struct iattr *iattr)
 	if (retval)
 		return retval;
 
-	p9attr.valid = iattr->ia_valid;
+	p9attr.valid = v9fs_vfs_iattr_to_9p_valid(iattr->ia_valid);
 	p9attr.mode = iattr->ia_mode;
 	p9attr.uid = iattr->ia_uid;
 	p9attr.gid = iattr->ia_gid;
diff --git a/include/net/9p/9p.h b/include/net/9p/9p.h
index 2d70b95..98b3f71 100644
--- a/include/net/9p/9p.h
+++ b/include/net/9p/9p.h
@@ -468,6 +468,24 @@ struct p9_stat_dotl {
 #define P9_STATS_BASIC		0x000007ffULL /* Mask for fields up to BLOCKS */
 #define P9_STATS_ALL		0x00003fffULL /* Mask for All fields above */
 
+#define P9_ATTR_MODE		(1 << 0)
+#define P9_ATTR_UID		(1 << 1)
+#define P9_ATTR_GID		(1 << 2)
+#define P9_ATTR_SIZE		(1 << 3)
+#define P9_ATTR_ATIME		(1 << 4)
+#define P9_ATTR_MTIME		(1 << 5)
+#define P9_ATTR_CTIME		(1 << 6)
+#define P9_ATTR_ATIME_SET	(1 << 7)
+#define P9_ATTR_MTIME_SET	(1 << 8)
+#define P9_ATTR_FORCE		(1 << 9) /* Not a change, but a change it */
+#define P9_ATTR_ATTR_FLAG	(1 << 10)
+#define P9_ATTR_KILL_SUID	(1 << 11)
+#define P9_ATTR_KILL_SGID	(1 << 12)
+#define P9_ATTR_FILE		(1 << 13)
+#define P9_ATTR_KILL_PRIV	(1 << 14)
+#define P9_ATTR_OPEN		(1 << 15) /* Truncating from open(O_TRUNC) */
+#define P9_ATTR_TIMES_SET	(1 << 16)
+
 /**
  * struct p9_iattr_dotl - P9 inode attribute for setattr
  * @valid: bitfield specifying which fields are valid
-- 
1.7.8
