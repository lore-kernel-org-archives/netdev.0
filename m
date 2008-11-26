From: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Subject: [PATCH 5/6] fs: Introduce special inodes
Date: Thu, 27 Nov 2008 00:32:41 +0100
Message-ID: <492DDC99.5060106@cosmosbay.com>
References: <Pine.LNX.4.64.0811201727070.9089@quilx.com> <20081121083044.GL16242@elte.hu> <49267694.1030506@cosmosbay.com> <20081121.010508.40225532.davem@davemloft.net> <4926AEDB.10007@cosmosbay.com> <4926D022.5060008@cosmosbay.com> <20081121152148.GA20388@elte.hu> <4926D39D.9050603@cosmosbay.com> <20081121153453.GA23713@elte.hu>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070309070800050207000506"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
To: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20081121153453.GA23713-X9Un+BFzKDI@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070309070800050207000506
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Goal of this patch is to not touch inode_lock for socket/pipes/anonfd
 inodes allocation/freeing.

 In new_inode(), we test if super block has MS_SPECIAL flag set.
 If yes, we dont put inode in "inode_in_use" list nor "sb->s_inodes" list
 As inode_lock was taken only to protect these lists, we avoid it as well

 Using iput_special() from dput_special() avoids taking inode_lock
 at freeing time.

 This patch has a very noticeable effect, because we avoid dirtying 
 of three contended cache lines in new_inode(), and five cache lines
 in iput()

Note: Not sure if we can use MS_SPECIAL=MS_NOUSER, or if we
really need a different flag.

(socket8 bench result : from 20.5s to 2.94s) 

Signed-off-by: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
---

 fs/anon_inodes.c   |    1 +
 fs/dcache.c        |    2 +-
 fs/inode.c         |   25 ++++++++++++++++++-------
 fs/pipe.c          |    3 ++-
 include/linux/fs.h |    2 ++
 net/socket.c       |    1 +
 6 files changed, 25 insertions(+), 9 deletions(-)

--------------070309070800050207000506
Content-Type: text/plain;
 name="special_inodes.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="special_inodes.patch"

diff --git a/fs/anon_inodes.c b/fs/anon_inodes.c
index 4f20d48..a0212b3 100644
--- a/fs/anon_inodes.c
+++ b/fs/anon_inodes.c
@@ -158,6 +158,7 @@ static int __init anon_inode_init(void)
 		error = PTR_ERR(anon_inode_mnt);
 		goto err_unregister_filesystem;
 	}
+	anon_inode_mnt->mnt_sb->s_flags |= MS_SPECIAL;
 	anon_inode_inode = anon_inode_mkinode();
 	if (IS_ERR(anon_inode_inode)) {
 		error = PTR_ERR(anon_inode_inode);
diff --git a/fs/dcache.c b/fs/dcache.c
index d73763b..bade7d7 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -239,7 +239,7 @@ static void dput_special(struct dentry *dentry)
 		return;
 	inode = dentry->d_inode;
 	if (inode)
-		iput(inode);
+		iput_special(inode);
 	d_free(dentry);
 }
 
diff --git a/fs/inode.c b/fs/inode.c
index 8d8d40e..1bb6553 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -228,6 +228,14 @@ void destroy_inode(struct inode *inode)
 		kmem_cache_free(inode_cachep, (inode));
 }
 
+void iput_special(struct inode *inode)
+{
+	if (atomic_dec_and_test(&inode->i_count)) {
+		destroy_inode(inode);
+		get_cpu_var(nr_inodes)--;
+		put_cpu_var(nr_inodes);
+	}
+}
 
 /*
  * These are initializations that only need to be done
@@ -609,18 +617,21 @@ struct inode *new_inode(struct super_block *sb)
 	 */
 	struct inode * inode;
 
-	spin_lock_prefetch(&inode_lock);
-	
 	inode = alloc_inode(sb);
 	if (inode) {
-		spin_lock(&inode_lock);
-		list_add(&inode->i_list, &inode_in_use);
-		list_add(&inode->i_sb_list, &sb->s_inodes);
+		inode->i_state = 0;
+		if (sb->s_flags & MS_SPECIAL) {
+ 			INIT_LIST_HEAD(&inode->i_list);
+ 			INIT_LIST_HEAD(&inode->i_sb_list);
+		} else {
+			spin_lock(&inode_lock);
+			list_add(&inode->i_list, &inode_in_use);
+			list_add(&inode->i_sb_list, &sb->s_inodes);
+			spin_unlock(&inode_lock);
+		}
 		get_cpu_var(nr_inodes)--;
 		inode->i_ino = last_ino_get();
 		put_cpu_var(nr_inodes);
-		inode->i_state = 0;
-		spin_unlock(&inode_lock);
 	}
 	return inode;
 }
diff --git a/fs/pipe.c b/fs/pipe.c
index 5cc132a..6fca681 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -1078,7 +1078,8 @@ static int __init init_pipe_fs(void)
 		if (IS_ERR(pipe_mnt)) {
 			err = PTR_ERR(pipe_mnt);
 			unregister_filesystem(&pipe_fs_type);
-		}
+		} else
+			pipe_mnt->mnt_sb->s_flags |= MS_SPECIAL;
 	}
 	return err;
 }
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 2482977..dd0e8a5 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -136,6 +136,7 @@ extern int dir_notify_enable;
 #define MS_RELATIME	(1<<21)	/* Update atime relative to mtime/ctime. */
 #define MS_KERNMOUNT	(1<<22) /* this is a kern_mount call */
 #define MS_I_VERSION	(1<<23) /* Update inode I_version field */
+#define MS_SPECIAL	(1<<24) /* special fs (inodes not in sb->s_inodes) */
 #define MS_ACTIVE	(1<<30)
 #define MS_NOUSER	(1<<31)
 
@@ -1898,6 +1899,7 @@ extern void __iget(struct inode * inode);
 extern void iget_failed(struct inode *);
 extern void clear_inode(struct inode *);
 extern void destroy_inode(struct inode *);
+extern void iput_special(struct inode *inode);
 extern struct inode *new_inode(struct super_block *);
 extern int should_remove_suid(struct dentry *);
 extern int file_remove_suid(struct file *);
diff --git a/net/socket.c b/net/socket.c
index f41b6c6..4177456 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -2205,6 +2205,7 @@ static int __init sock_init(void)
 	init_inodecache();
 	register_filesystem(&sock_fs_type);
 	sock_mnt = kern_mount(&sock_fs_type);
+	sock_mnt->mnt_sb->s_flags |= MS_SPECIAL;
 
 	/* The real protocol initialization is performed in later initcalls.
 	 */

--------------070309070800050207000506--
