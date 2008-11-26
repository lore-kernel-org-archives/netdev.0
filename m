From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH 6/6] fs: Introduce kern_mount_special() to mount special vfs
Date: Thu, 27 Nov 2008 00:32:59 +0100
Message-ID: <492DDCAB.1070204@cosmosbay.com>
References: <Pine.LNX.4.64.0811201727070.9089@quilx.com> <20081121083044.GL16242@elte.hu> <49267694.1030506@cosmosbay.com> <20081121.010508.40225532.davem@davemloft.net> <4926AEDB.10007@cosmosbay.com> <4926D022.5060008@cosmosbay.com> <20081121152148.GA20388@elte.hu> <4926D39D.9050603@cosmosbay.com> <20081121153453.GA23713@elte.hu>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080807060404030309070807"
Cc: David Miller <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, linux-kernel@vger.kernel.org,
	kernel-testers@vger.kernel.org, Mike Galbraith <efault@gmx.de>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:42606 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755786AbYKZXdd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 18:33:33 -0500
In-Reply-To: <20081121153453.GA23713@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080807060404030309070807
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This function arms a flag (MNT_SPECIAL) on the vfs, to avoid
refcounting on permanent system vfs.
Use this function for sockets, pipes, anonymous fds.

(socket8 bench result : from 2.94s to 2.23s)

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 fs/anon_inodes.c      |    2 +-
 fs/pipe.c             |    2 +-
 fs/super.c            |    9 +++++++++
 include/linux/fs.h    |    1 +
 include/linux/mount.h |    5 +++--
 net/socket.c          |    2 +-
 6 files changed, 16 insertions(+), 5 deletions(-)


--------------080807060404030309070807
Content-Type: text/plain;
 name="mnt_special.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mnt_special.patch"

diff --git a/fs/anon_inodes.c b/fs/anon_inodes.c
index a0212b3..42dfe28 100644
--- a/fs/anon_inodes.c
+++ b/fs/anon_inodes.c
@@ -153,7 +153,7 @@ static int __init anon_inode_init(void)
 	error = register_filesystem(&anon_inode_fs_type);
 	if (error)
 		goto err_exit;
-	anon_inode_mnt = kern_mount(&anon_inode_fs_type);
+	anon_inode_mnt = kern_mount_special(&anon_inode_fs_type);
 	if (IS_ERR(anon_inode_mnt)) {
 		error = PTR_ERR(anon_inode_mnt);
 		goto err_unregister_filesystem;
diff --git a/fs/pipe.c b/fs/pipe.c
index 6fca681..391d4fe 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -1074,7 +1074,7 @@ static int __init init_pipe_fs(void)
 	int err = register_filesystem(&pipe_fs_type);
 
 	if (!err) {
-		pipe_mnt = kern_mount(&pipe_fs_type);
+		pipe_mnt = kern_mount_special(&pipe_fs_type);
 		if (IS_ERR(pipe_mnt)) {
 			err = PTR_ERR(pipe_mnt);
 			unregister_filesystem(&pipe_fs_type);
diff --git a/fs/super.c b/fs/super.c
index 400a760..a8e14f7 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -982,3 +982,12 @@ struct vfsmount *kern_mount_data(struct file_system_type *type, void *data)
 }
 
 EXPORT_SYMBOL_GPL(kern_mount_data);
+
+struct vfsmount *kern_mount_special(struct file_system_type *type)
+{
+	struct vfsmount *res = kern_mount_data(type, NULL);
+
+	if (!IS_ERR(res))
+		res->mnt_flags |= MNT_SPECIAL;
+	return res;
+}
diff --git a/include/linux/fs.h b/include/linux/fs.h
index dd0e8a5..a92544a 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1591,6 +1591,7 @@ extern int register_filesystem(struct file_system_type *);
 extern int unregister_filesystem(struct file_system_type *);
 extern struct vfsmount *kern_mount_data(struct file_system_type *, void *data);
 #define kern_mount(type) kern_mount_data(type, NULL)
+extern struct vfsmount *kern_mount_special(struct file_system_type *);
 extern int may_umount_tree(struct vfsmount *);
 extern int may_umount(struct vfsmount *);
 extern long do_mount(char *, char *, char *, unsigned long, void *);
diff --git a/include/linux/mount.h b/include/linux/mount.h
index cab2a85..cb4fa90 100644
--- a/include/linux/mount.h
+++ b/include/linux/mount.h
@@ -30,6 +30,7 @@ struct mnt_namespace;
 
 #define MNT_SHRINKABLE	0x100
 #define MNT_IMBALANCED_WRITE_COUNT	0x200 /* just for debugging */
+#define MNT_SPECIAL	0x400	/* special mount (pipes,sockets,...) */
 
 #define MNT_SHARED	0x1000	/* if the vfsmount is a shared mount */
 #define MNT_UNBINDABLE	0x2000	/* if the vfsmount is a unbindable mount */
@@ -73,7 +74,7 @@ struct vfsmount {
 
 static inline struct vfsmount *mntget(struct vfsmount *mnt)
 {
-	if (mnt)
+	if (mnt && !(mnt->mnt_flags & MNT_SPECIAL))
 		atomic_inc(&mnt->mnt_count);
 	return mnt;
 }
@@ -87,7 +88,7 @@ extern int __mnt_is_readonly(struct vfsmount *mnt);
 
 static inline void mntput(struct vfsmount *mnt)
 {
-	if (mnt) {
+	if (mnt && !(mnt->mnt_flags & MNT_SPECIAL)) {
 		mnt->mnt_expiry_mark = 0;
 		mntput_no_expire(mnt);
 	}
diff --git a/net/socket.c b/net/socket.c
index 4177456..2857d70 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -2204,7 +2204,7 @@ static int __init sock_init(void)
 
 	init_inodecache();
 	register_filesystem(&sock_fs_type);
-	sock_mnt = kern_mount(&sock_fs_type);
+	sock_mnt = kern_mount_special(&sock_fs_type);
 	sock_mnt->mnt_sb->s_flags |= MS_SPECIAL;
 
 	/* The real protocol initialization is performed in later initcalls.

--------------080807060404030309070807--
