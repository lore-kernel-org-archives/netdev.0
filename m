From: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Subject: [PATCH 1/6] fs: Introduce a per_cpu nr_dentry
Date: Thu, 27 Nov 2008 00:30:19 +0100
Message-ID: <492DDC0B.8060804@cosmosbay.com>
References: <Pine.LNX.4.64.0811201727070.9089@quilx.com> <20081121083044.GL16242@elte.hu> <49267694.1030506@cosmosbay.com> <20081121.010508.40225532.davem@davemloft.net> <4926AEDB.10007@cosmosbay.com> <4926D022.5060008@cosmosbay.com> <20081121152148.GA20388@elte.hu> <4926D39D.9050603@cosmosbay.com> <20081121153453.GA23713@elte.hu>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080405000100050008020707"
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
--------------080405000100050008020707
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Adding a per_cpu nr_dentry avoids cache line ping pongs between
cpus to maintain this metric.

We centralize decrements of nr_dentry in d_free(),
and increments in d_alloc().

d_alloc() can avoid taking dcache_lock if parent is NULL

Signed-off-by: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
---
 fs/dcache.c        |   55 ++++++++++++++++++++++++++++---------------
 include/linux/fs.h |    2 +
 kernel/sysctl.c    |    2 -
 3 files changed, 40 insertions(+), 19 deletions(-)

--------------080405000100050008020707
Content-Type: text/plain;
 name="per_cpu_nr_dentry.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="per_cpu_nr_dentry.patch"

diff --git a/fs/dcache.c b/fs/dcache.c
index a1d86c7..42ed9fc 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -61,12 +61,38 @@ static struct kmem_cache *dentry_cache __read_mostly;
 static unsigned int d_hash_mask __read_mostly;
 static unsigned int d_hash_shift __read_mostly;
 static struct hlist_head *dentry_hashtable __read_mostly;
+static DEFINE_PER_CPU(int, nr_dentry);
 
 /* Statistics gathering. */
 struct dentry_stat_t dentry_stat = {
 	.age_limit = 45,
 };
 
+/*
+ * Handle nr_dentry sysctl
+ */
+#if defined(CONFIG_SYSCTL) && defined(CONFIG_PROC_FS)
+int proc_nr_dentry(ctl_table *table, int write, struct file *filp,
+		   void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	int cpu;
+	int counter = 0;
+
+	for_each_possible_cpu(cpu)
+	    counter += per_cpu(nr_dentry, cpu);
+	if (counter < 0)
+		counter = 0;
+	dentry_stat.nr_dentry = counter;
+	return proc_dointvec(table, write, filp, buffer, lenp, ppos);
+}
+#else
+int proc_nr_dentry(ctl_table *table, int write, struct file *filp,
+		   void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	return -ENOSYS;
+}
+#endif
+
 static void __d_free(struct dentry *dentry)
 {
 	WARN_ON(!list_empty(&dentry->d_alias));
@@ -82,8 +108,7 @@ static void d_callback(struct rcu_head *head)
 }
 
 /*
- * no dcache_lock, please.  The caller must decrement dentry_stat.nr_dentry
- * inside dcache_lock.
+ * no dcache_lock, please.
  */
 static void d_free(struct dentry *dentry)
 {
@@ -94,6 +119,8 @@ static void d_free(struct dentry *dentry)
 		__d_free(dentry);
 	else
 		call_rcu(&dentry->d_u.d_rcu, d_callback);
+	get_cpu_var(nr_dentry)--;
+	put_cpu_var(nr_dentry);
 }
 
 /*
@@ -172,7 +199,6 @@ static struct dentry *d_kill(struct dentry *dentry)
 	struct dentry *parent;
 
 	list_del(&dentry->d_u.d_child);
-	dentry_stat.nr_dentry--;	/* For d_free, below */
 	/*drops the locks, at that point nobody can reach this dentry */
 	dentry_iput(dentry);
 	if (IS_ROOT(dentry))
@@ -619,7 +645,6 @@ void shrink_dcache_sb(struct super_block * sb)
 static void shrink_dcache_for_umount_subtree(struct dentry *dentry)
 {
 	struct dentry *parent;
-	unsigned detached = 0;
 
 	BUG_ON(!IS_ROOT(dentry));
 
@@ -678,7 +703,6 @@ static void shrink_dcache_for_umount_subtree(struct dentry *dentry)
 			}
 
 			list_del(&dentry->d_u.d_child);
-			detached++;
 
 			inode = dentry->d_inode;
 			if (inode) {
@@ -696,7 +720,7 @@ static void shrink_dcache_for_umount_subtree(struct dentry *dentry)
 			 * otherwise we ascend to the parent and move to the
 			 * next sibling if there is one */
 			if (!parent)
-				goto out;
+				return;
 
 			dentry = parent;
 
@@ -705,11 +729,6 @@ static void shrink_dcache_for_umount_subtree(struct dentry *dentry)
 		dentry = list_entry(dentry->d_subdirs.next,
 				    struct dentry, d_u.d_child);
 	}
-out:
-	/* several dentries were freed, need to correct nr_dentry */
-	spin_lock(&dcache_lock);
-	dentry_stat.nr_dentry -= detached;
-	spin_unlock(&dcache_lock);
 }
 
 /*
@@ -943,8 +962,6 @@ struct dentry *d_alloc(struct dentry * parent, const struct qstr *name)
 	dentry->d_flags = DCACHE_UNHASHED;
 	spin_lock_init(&dentry->d_lock);
 	dentry->d_inode = NULL;
-	dentry->d_parent = NULL;
-	dentry->d_sb = NULL;
 	dentry->d_op = NULL;
 	dentry->d_fsdata = NULL;
 	dentry->d_mounted = 0;
@@ -959,15 +976,17 @@ struct dentry *d_alloc(struct dentry * parent, const struct qstr *name)
 	if (parent) {
 		dentry->d_parent = dget(parent);
 		dentry->d_sb = parent->d_sb;
+		spin_lock(&dcache_lock);
+		list_add(&dentry->d_u.d_child, &parent->d_subdirs);
+		spin_unlock(&dcache_lock);
 	} else {
+		dentry->d_parent = NULL;
+		dentry->d_sb = NULL;
 		INIT_LIST_HEAD(&dentry->d_u.d_child);
 	}
 
-	spin_lock(&dcache_lock);
-	if (parent)
-		list_add(&dentry->d_u.d_child, &parent->d_subdirs);
-	dentry_stat.nr_dentry++;
-	spin_unlock(&dcache_lock);
+	get_cpu_var(nr_dentry)++;
+	put_cpu_var(nr_dentry);
 
 	return dentry;
 }
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 0dcdd94..c5e7aa5 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2216,6 +2216,8 @@ static inline void free_secdata(void *secdata)
 struct ctl_table;
 int proc_nr_files(struct ctl_table *table, int write, struct file *filp,
 		  void __user *buffer, size_t *lenp, loff_t *ppos);
+int proc_nr_dentry(struct ctl_table *table, int write, struct file *filp,
+		   void __user *buffer, size_t *lenp, loff_t *ppos);
 
 int get_filesystem_list(char * buf);
 
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 9d048fa..eebddef 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1243,7 +1243,7 @@ static struct ctl_table fs_table[] = {
 		.data		= &dentry_stat,
 		.maxlen		= 6*sizeof(int),
 		.mode		= 0444,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= &proc_nr_dentry,
 	},
 	{
 		.ctl_name	= FS_OVERFLOWUID,

--------------080405000100050008020707--
