From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH v3 5/7] fs: new_inode_single() and iput_single()
Date: Thu, 11 Dec 2008 23:40:07 +0100
Message-ID: <494196C7.2050005@cosmosbay.com>
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
Received: from gw1.cosmosbay.com ([86.65.150.130]:54042 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758052AbYLKWkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 17:40:33 -0500
In-Reply-To: <493100B0.6090104@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Goal of this patch is to not touch inode_lock for socket/pipes/anonfd
inodes allocation/freeing.

SINGLE dentries are attached to inodes that dont need to be linked
in a list of inodes, being "inode_in_use" or "sb->s_inodes"
As inode_lock was taken only to protect these lists, we avoid taking it
as well.

Using iput_single() from dput_single() avoids taking inode_lock
at freeing time.

This patch has a very noticeable effect, because we avoid dirtying of
three contended cache lines in new_inode(), and five cache lines in iput()

("socketallocbench -n 8" result : from 19.9s to 3.01s)

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 fs/anon_inodes.c   |    2 +-
 fs/dcache.c        |    2 +-
 fs/inode.c         |   29 ++++++++++++++++++++---------
 fs/pipe.c          |    2 +-
 include/linux/fs.h |   12 +++++++++++-
 net/socket.c       |    2 +-
 6 files changed, 35 insertions(+), 14 deletions(-)

diff --git a/fs/anon_inodes.c b/fs/anon_inodes.c
index 8bf83cb..89fd36d 100644
--- a/fs/anon_inodes.c
+++ b/fs/anon_inodes.c
@@ -125,7 +125,7 @@ EXPORT_SYMBOL_GPL(anon_inode_getfd);
  */
 static struct inode *anon_inode_mkinode(void)
 {
-	struct inode *inode = new_inode(anon_inode_mnt->mnt_sb);
+	struct inode *inode = new_inode_single(anon_inode_mnt->mnt_sb);
 
 	if (!inode)
 		return ERR_PTR(-ENOMEM);
diff --git a/fs/dcache.c b/fs/dcache.c
index af3bfb3..3363853 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -231,7 +231,7 @@ static void dput_single(struct dentry *dentry)
 		return;
 	inode = dentry->d_inode;
 	if (inode)
-		iput(inode);
+		iput_single(inode);
 	d_free(dentry);
 }
 
diff --git a/fs/inode.c b/fs/inode.c
index dc8e72a..0fdfe1b 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -221,6 +221,13 @@ void destroy_inode(struct inode *inode)
 		kmem_cache_free(inode_cachep, (inode));
 }
 
+void iput_single(struct inode *inode)
+{
+	if (atomic_dec_and_test(&inode->i_count)) {
+		destroy_inode(inode);
+		percpu_counter_dec(&nr_inodes);
+	}
+}
 
 /*
  * These are initializations that only need to be done
@@ -587,8 +594,9 @@ static int last_ino_get(void)
 #endif
 
 /**
- *	new_inode 	- obtain an inode
+ *	__new_inode 	- obtain an inode
  *	@sb: superblock
+ *  @single: if true, dont link new inode in a list
  *
  *	Allocates a new inode for given superblock. The default gfp_mask
  *	for allocations related to inode->i_mapping is GFP_HIGHUSER_PAGECACHE.
@@ -598,7 +606,7 @@ static int last_ino_get(void)
  *	newly created inode's mapping
  *
  */
-struct inode *new_inode(struct super_block *sb)
+struct inode *__new_inode(struct super_block *sb, int single)
 {
 	/*
 	 * On a 32bit, non LFS stat() call, glibc will generate an EOVERFLOW
@@ -607,22 +615,25 @@ struct inode *new_inode(struct super_block *sb)
 	 */
 	struct inode * inode;
 
-	spin_lock_prefetch(&inode_lock);
-	
 	inode = alloc_inode(sb);
 	if (inode) {
 		percpu_counter_inc(&nr_inodes);
 		inode->i_state = 0;
 		inode->i_ino = last_ino_get();
-		spin_lock(&inode_lock);
-		list_add(&inode->i_list, &inode_in_use);
-		list_add(&inode->i_sb_list, &sb->s_inodes);
-		spin_unlock(&inode_lock);
+ 		if (single) {
+  			INIT_LIST_HEAD(&inode->i_list);
+  			INIT_LIST_HEAD(&inode->i_sb_list);
+ 		} else {
+			spin_lock(&inode_lock);
+			list_add(&inode->i_list, &inode_in_use);
+			list_add(&inode->i_sb_list, &sb->s_inodes);
+			spin_unlock(&inode_lock);
+		}
 	}
 	return inode;
 }
 
-EXPORT_SYMBOL(new_inode);
+EXPORT_SYMBOL(__new_inode);
 
 void unlock_new_inode(struct inode *inode)
 {
diff --git a/fs/pipe.c b/fs/pipe.c
index 4de6dd5..8c51a0d 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -865,7 +865,7 @@ static struct dentry_operations pipefs_dentry_operations = {
 
 static struct inode * get_pipe_inode(void)
 {
-	struct inode *inode = new_inode(pipe_mnt->mnt_sb);
+	struct inode *inode = new_inode_single(pipe_mnt->mnt_sb);
 	struct pipe_inode_info *pipe;
 
 	if (!inode)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index a789346..a702d81 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1899,7 +1899,17 @@ extern void __iget(struct inode * inode);
 extern void iget_failed(struct inode *);
 extern void clear_inode(struct inode *);
 extern void destroy_inode(struct inode *);
-extern struct inode *new_inode(struct super_block *);
+extern struct inode *__new_inode(struct super_block *, int);
+static inline struct inode *new_inode(struct super_block *sb)
+{
+	return __new_inode(sb, 0);
+}
+static inline struct inode *new_inode_single(struct super_block *sb)
+{
+	return __new_inode(sb, 1);
+}
+extern void iput_single(struct inode *);
+
 extern int should_remove_suid(struct dentry *);
 extern int file_remove_suid(struct file *);
 
diff --git a/net/socket.c b/net/socket.c
index 353c928..4017409 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -464,7 +464,7 @@ static struct socket *sock_alloc(void)
 	struct inode *inode;
 	struct socket *sock;
 
-	inode = new_inode(sock_mnt->mnt_sb);
+	inode = new_inode_single(sock_mnt->mnt_sb);
 	if (!inode)
 		return NULL;
 
