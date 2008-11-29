From: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Subject: [PATCH v2 2/5] fs: Use a percpu_counter to track nr_inodes
Date: Sat, 29 Nov 2008 09:43:39 +0100
Message-ID: <493100BB.4000705@cosmosbay.com>
References: <Pine.LNX.4.64.0811201727070.9089@quilx.com> <20081121083044.GL16242@elte.hu> <49267694.1030506@cosmosbay.com> <20081121.010508.40225532.davem@davemloft.net> <4926AEDB.10007@cosmosbay.com> <4926D022.5060008@cosmosbay.com> <20081121152148.GA20388@elte.hu> <4926D39D.9050603@cosmosbay.com> <20081121153453.GA23713@elte.hu> <492DDB6A.8090806@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060706090907000009020308"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org >> Kernel Testers List"
	<kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
To: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <492DDB6A.8090806-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060706090907000009020308
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Avoids cache line ping pongs between cpus and prepare next patch,
because updates of nr_inodes dont need inode_lock anymore.

(socket8 bench result : no difference at this point)

Signed-off-by: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
---
 fs/fs-writeback.c   |    2 +-
 fs/inode.c          |   39 +++++++++++++++++++++++++++++++--------
 include/linux/fs.h  |    3 +++
 kernel/sysctl.c     |    4 ++--
 mm/page-writeback.c |    2 +-
 5 files changed, 38 insertions(+), 12 deletions(-)

--------------060706090907000009020308
Content-Type: text/plain;
 name="nr_inodes.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nr_inodes.patch"

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index d0ff0b8..b591cdd 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -608,7 +608,7 @@ void sync_inodes_sb(struct super_block *sb, int wait)
 	unsigned long nr_unstable = global_page_state(NR_UNSTABLE_NFS);
 
 	wbc.nr_to_write = nr_dirty + nr_unstable +
-			(inodes_stat.nr_inodes - inodes_stat.nr_unused) +
+			(get_nr_inodes() - inodes_stat.nr_unused) +
 			nr_dirty + nr_unstable;
 	wbc.nr_to_write += wbc.nr_to_write / 2;		/* Bit more for luck */
 	sync_sb_inodes(sb, &wbc);
diff --git a/fs/inode.c b/fs/inode.c
index 0487ddb..f94f889 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -96,9 +96,33 @@ static DEFINE_MUTEX(iprune_mutex);
  * Statistics gathering..
  */
 struct inodes_stat_t inodes_stat;
+static struct percpu_counter nr_inodes;
 
 static struct kmem_cache * inode_cachep __read_mostly;
 
+int get_nr_inodes(void)
+{
+	return percpu_counter_sum_positive(&nr_inodes);
+}
+
+/*
+ * Handle nr_dentry sysctl
+ */
+#if defined(CONFIG_SYSCTL) && defined(CONFIG_PROC_FS)
+int proc_nr_inodes(ctl_table *table, int write, struct file *filp,
+		   void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	inodes_stat.nr_inodes = get_nr_inodes();
+	return proc_dointvec(table, write, filp, buffer, lenp, ppos);
+}
+#else
+int proc_nr_inodes(ctl_table *table, int write, struct file *filp,
+		   void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	return -ENOSYS;
+}
+#endif
+
 static void wake_up_inode(struct inode *inode)
 {
 	/*
@@ -306,9 +330,7 @@ static void dispose_list(struct list_head *head)
 		destroy_inode(inode);
 		nr_disposed++;
 	}
-	spin_lock(&inode_lock);
-	inodes_stat.nr_inodes -= nr_disposed;
-	spin_unlock(&inode_lock);
+	percpu_counter_sub(&nr_inodes, nr_disposed);
 }
 
 /*
@@ -560,8 +582,8 @@ struct inode *new_inode(struct super_block *sb)
 	
 	inode = alloc_inode(sb);
 	if (inode) {
+		percpu_counter_inc(&nr_inodes);
 		spin_lock(&inode_lock);
-		inodes_stat.nr_inodes++;
 		list_add(&inode->i_list, &inode_in_use);
 		list_add(&inode->i_sb_list, &sb->s_inodes);
 		inode->i_ino = ++last_ino;
@@ -622,7 +644,7 @@ static struct inode * get_new_inode(struct super_block *sb, struct hlist_head *h
 			if (set(inode, data))
 				goto set_failed;
 
-			inodes_stat.nr_inodes++;
+			percpu_counter_inc(&nr_inodes);
 			list_add(&inode->i_list, &inode_in_use);
 			list_add(&inode->i_sb_list, &sb->s_inodes);
 			hlist_add_head(&inode->i_hash, head);
@@ -671,7 +693,7 @@ static struct inode * get_new_inode_fast(struct super_block *sb, struct hlist_he
 		old = find_inode_fast(sb, head, ino);
 		if (!old) {
 			inode->i_ino = ino;
-			inodes_stat.nr_inodes++;
+			percpu_counter_inc(&nr_inodes);
 			list_add(&inode->i_list, &inode_in_use);
 			list_add(&inode->i_sb_list, &sb->s_inodes);
 			hlist_add_head(&inode->i_hash, head);
@@ -1042,8 +1064,8 @@ void generic_delete_inode(struct inode *inode)
 	list_del_init(&inode->i_list);
 	list_del_init(&inode->i_sb_list);
 	inode->i_state |= I_FREEING;
-	inodes_stat.nr_inodes--;
 	spin_unlock(&inode_lock);
+	percpu_counter_dec(&nr_inodes);
 
 	security_inode_delete(inode);
 
@@ -1093,8 +1115,8 @@ static void generic_forget_inode(struct inode *inode)
 	list_del_init(&inode->i_list);
 	list_del_init(&inode->i_sb_list);
 	inode->i_state |= I_FREEING;
-	inodes_stat.nr_inodes--;
 	spin_unlock(&inode_lock);
+	percpu_counter_dec(&nr_inodes);
 	if (inode->i_data.nrpages)
 		truncate_inode_pages(&inode->i_data, 0);
 	clear_inode(inode);
@@ -1394,6 +1416,7 @@ void __init inode_init(void)
 {
 	int loop;
 
+	percpu_counter_init(&nr_inodes, 0);
 	/* inode slab cache */
 	inode_cachep = kmem_cache_create("inode_cache",
 					 sizeof(struct inode),
diff --git a/include/linux/fs.h b/include/linux/fs.h
index c5e7aa5..2482977 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -47,6 +47,7 @@ struct inodes_stat_t {
 	int dummy[5];		/* padding for sysctl ABI compatibility */
 };
 extern struct inodes_stat_t inodes_stat;
+extern int get_nr_inodes(void);
 
 extern int leases_enable, lease_break_time;
 
@@ -2218,6 +2219,8 @@ int proc_nr_files(struct ctl_table *table, int write, struct file *filp,
 		  void __user *buffer, size_t *lenp, loff_t *ppos);
 int proc_nr_dentry(struct ctl_table *table, int write, struct file *filp,
 		   void __user *buffer, size_t *lenp, loff_t *ppos);
+int proc_nr_inodes(struct ctl_table *table, int write, struct file *filp,
+		   void __user *buffer, size_t *lenp, loff_t *ppos);
 
 int get_filesystem_list(char * buf);
 
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index eebddef..eebed01 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1202,7 +1202,7 @@ static struct ctl_table fs_table[] = {
 		.data		= &inodes_stat,
 		.maxlen		= 2*sizeof(int),
 		.mode		= 0444,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= &proc_nr_inodes,
 	},
 	{
 		.ctl_name	= FS_STATINODE,
@@ -1210,7 +1210,7 @@ static struct ctl_table fs_table[] = {
 		.data		= &inodes_stat,
 		.maxlen		= 7*sizeof(int),
 		.mode		= 0444,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= &proc_nr_inodes,
 	},
 	{
 		.procname	= "file-nr",
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 2970e35..a71a922 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -705,7 +705,7 @@ static void wb_kupdate(unsigned long arg)
 	next_jif = start_jif + dirty_writeback_interval;
 	nr_to_write = global_page_state(NR_FILE_DIRTY) +
 			global_page_state(NR_UNSTABLE_NFS) +
-			(inodes_stat.nr_inodes - inodes_stat.nr_unused);
+			(get_nr_inodes() - inodes_stat.nr_unused);
 	while (nr_to_write > 0) {
 		wbc.more_io = 0;
 		wbc.encountered_congestion = 0;

--------------060706090907000009020308--
