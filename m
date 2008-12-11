From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH v3 7/7] fs: MS_NOREFCOUNT
Date: Thu, 11 Dec 2008 23:41:03 +0100
Message-ID: <494196FF.3030407@cosmosbay.com>
References: <Pine.LNX.4.64.0811201727070.9089@quilx.com> <20081121083044.GL16242@elte.hu> <49267694.1030506@cosmosbay.com> <20081121.010508.40225532.davem@davemloft.net> <4926AEDB.10007@cosmosbay.com> <4926D022.5060008@cosmosbay.com> <20081121152148.GA20388@elte.hu> <4926D39D.9050603@cosmosbay.com> <20081121153453.GA23713@elte.hu> <492DDB6A.8090806@cosmosbay.com> <493100B0.6090104@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, Christoph Hellwig <hch@infradead.org>,
	David Miller <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, linux-kernel@vger.kernel.org,
	"kernel-testers@vger.kernel.org >> Kernel Testers List"
	<kernel-testers@vger.kernel.org>, Mike Galbraith <efault@gmx.de>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	linux-fsdevel@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:54064 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759268AbYLKWl3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 17:41:29 -0500
In-Reply-To: <493100B0.6090104@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some fs are hardwired into kernel, and mntput()/mntget() hit a contended
cache line. We define a new superblock flag, MS_NOREFCOUNT, that is set
on socket, pipes and anonymous fd superblocks. mntput()/mntget() become
null ops on these fs.

("socketallocbench -n 8" result : from 2.20s to 1.64s)

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 fs/anon_inodes.c      |    1 +
 fs/pipe.c             |    3 ++-
 include/linux/fs.h    |    2 ++
 include/linux/mount.h |    8 +++-----
 net/socket.c          |    1 +
 5 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/fs/anon_inodes.c b/fs/anon_inodes.c
index 89fd36d..de0ec3b 100644
--- a/fs/anon_inodes.c
+++ b/fs/anon_inodes.c
@@ -158,6 +158,7 @@ static int __init anon_inode_init(void)
 		error = PTR_ERR(anon_inode_mnt);
 		goto err_unregister_filesystem;
 	}
+	anon_inode_mnt->mnt_sb->s_flags |= MS_NOREFCOUNT;
 	anon_inode_inode = anon_inode_mkinode();
 	if (IS_ERR(anon_inode_inode)) {
 		error = PTR_ERR(anon_inode_inode);
diff --git a/fs/pipe.c b/fs/pipe.c
index 8c51a0d..f547432 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -1078,7 +1078,8 @@ static int __init init_pipe_fs(void)
 		if (IS_ERR(pipe_mnt)) {
 			err = PTR_ERR(pipe_mnt);
 			unregister_filesystem(&pipe_fs_type);
-		}
+		} else
+			pipe_mnt->mnt_sb->s_flags |= MS_NOREFCOUNT;
 	}
 	return err;
 }
diff --git a/include/linux/fs.h b/include/linux/fs.h
index a1f56d4..11b0452 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -137,6 +137,8 @@ extern int dir_notify_enable;
 #define MS_RELATIME	(1<<21)	/* Update atime relative to mtime/ctime. */
 #define MS_KERNMOUNT	(1<<22) /* this is a kern_mount call */
 #define MS_I_VERSION	(1<<23) /* Update inode I_version field */
+
+#define MS_NOREFCOUNT	(1<<29) /* kernel static mnt : no refcounting needed */
 #define MS_ACTIVE	(1<<30)
 #define MS_NOUSER	(1<<31)
 
diff --git a/include/linux/mount.h b/include/linux/mount.h
index cab2a85..51418b5 100644
--- a/include/linux/mount.h
+++ b/include/linux/mount.h
@@ -14,10 +14,8 @@
 #include <linux/nodemask.h>
 #include <linux/spinlock.h>
 #include <asm/atomic.h>
+#include <linux/fs.h>
 
-struct super_block;
-struct vfsmount;
-struct dentry;
 struct mnt_namespace;
 
 #define MNT_NOSUID	0x01
@@ -73,7 +71,7 @@ struct vfsmount {
 
 static inline struct vfsmount *mntget(struct vfsmount *mnt)
 {
-	if (mnt)
+	if (mnt && !(mnt->mnt_sb->s_flags & MS_NOREFCOUNT))
 		atomic_inc(&mnt->mnt_count);
 	return mnt;
 }
@@ -87,7 +85,7 @@ extern int __mnt_is_readonly(struct vfsmount *mnt);
 
 static inline void mntput(struct vfsmount *mnt)
 {
-	if (mnt) {
+	if (mnt && !(mnt->mnt_sb->s_flags & MS_NOREFCOUNT)) {
 		mnt->mnt_expiry_mark = 0;
 		mntput_no_expire(mnt);
 	}
diff --git a/net/socket.c b/net/socket.c
index 4017409..2534dbc 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -2206,6 +2206,7 @@ static int __init sock_init(void)
 	init_inodecache();
 	register_filesystem(&sock_fs_type);
 	sock_mnt = kern_mount(&sock_fs_type);
+	sock_mnt->mnt_sb->s_flags |= MS_NOREFCOUNT;
 
 	/* The real protocol initialization is performed in later initcalls.
 	 */
