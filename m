From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [RFC PATCH linux 2/2] fs/proc: use a hash table for the directory entries
Date: Thu,  2 Oct 2014 17:25:01 +0200
Message-ID: <1412263501-6572-3-git-send-email-nicolas.dichtel@6wind.com>
References: <20131003.150947.2179820478039260398.davem@davemloft.net>
 <1412263501-6572-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, ebiederm@xmission.com,
	akpm@linux-foundation.org, adobriyan@gmail.com,
	rui.xiang@huawei.com, viro@zeniv.linux.org.uk, oleg@redhat.com,
	gorcunov@openvz.org, kirill.shutemov@linux.intel.com,
	grant.likely@secretlab.ca, tytso@mit.edu,
	Thierry Herbelot <thierry.herbelot@6wind.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412263501-6572-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thierry Herbelot <thierry.herbelot@6wind.com>

The current implementation for the directories in /proc is using a single
linked list. This is slow when handling directories with large numbers of
entries (eg netdevice-related entries when lots of tunnels are opened).

This patch enables multiple linked lists. A hash based on the entry name is
used to select the linked list for one given entry.

The speed creation of netdevices is faster as shorter linked lists must be
scanned when adding a new netdevice.

Here are some numbers:

dummy30000.batch contains 30 000 times 'link add type dummy'.

Before the patch:
time ip -b dummy30000.batch
real    2m32.221s
user    0m0.380s
sys     2m30.610s

After the patch:
time ip -b dummy30000.batch
real    1m57.190s
user    0m0.350s
sys     1m56.120s

The single 'subdir' list head is replaced by a subdir hash table. The subdir
hash buckets are only allocated for directories. The number of hash buckets
is a compile-time parameter.

For all functions which handle directory entries, an additional check on the
directory nature of the dir entry ensures that pde_hash_buckets was allocated.
This check was not needed as subdir was present for all dir entries, whether
actual directories or simple files.

Signed-off-by: Thierry Herbelot <thierry.herbelot@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 fs/proc/generic.c  | 100 +++++++++++++++++++++++++++++++++++++++++------------
 fs/proc/internal.h |  49 +++++++++++++++++++++++---
 fs/proc/proc_net.c |   7 ++++
 fs/proc/root.c     |   5 +++
 4 files changed, 134 insertions(+), 27 deletions(-)

diff --git a/fs/proc/generic.c b/fs/proc/generic.c
index 317b72641ebf..c3af8c289c7e 100644
--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -81,10 +81,13 @@ static int __xlate_proc_name(const char *name, struct proc_dir_entry **ret,
 	const char     		*cp = name, *next;
 	struct proc_dir_entry	*de;
 	unsigned int		len;
+	unsigned int		name_hash;
 
 	de = *ret;
 	if (!de)
 		de = &proc_root;
+	if (!S_ISDIR(de->mode))
+		return -EINVAL;
 
 	while (1) {
 		next = strchr(cp, '/');
@@ -92,7 +95,9 @@ static int __xlate_proc_name(const char *name, struct proc_dir_entry **ret,
 			break;
 
 		len = next - cp;
-		for (de = de->subdir; de ; de = de->next) {
+		name_hash = proc_pde_name_hash(cp, len);
+		for (de = de->pde_hash_buckets[name_hash]; de;
+		     de = de->next) {
 			if (proc_match(len, cp, de))
 				break;
 		}
@@ -180,10 +185,15 @@ static const struct inode_operations proc_link_inode_operations = {
 struct dentry *proc_lookup_de(struct proc_dir_entry *de, struct inode *dir,
 		struct dentry *dentry)
 {
+	unsigned int name_hash;
 	struct inode *inode;
 
+	if (!S_ISDIR(de->mode))
+		return NULL;
 	spin_lock(&proc_subdir_lock);
-	for (de = de->subdir; de ; de = de->next) {
+	name_hash = proc_pde_name_hash(dentry->d_name.name,
+				       dentry->d_name.len);
+	for (de = de->pde_hash_buckets[name_hash]; de ; de = de->next) {
 		if (de->namelen != dentry->d_name.len)
 			continue;
 		if (!memcmp(dentry->d_name.name, de->name, de->namelen)) {
@@ -219,18 +229,30 @@ struct dentry *proc_lookup(struct inode *dir, struct dentry *dentry,
 int proc_readdir_de(struct proc_dir_entry *de, struct file *file,
 		    struct dir_context *ctx)
 {
+	struct proc_dir_entry *dir;
+	unsigned int hash_idx = 0;
 	int i;
 
+	dir = de;
+	if (!S_ISDIR(dir->mode))
+		return -EINVAL;
 	if (!dir_emit_dots(file, ctx))
 		return 0;
 
 	spin_lock(&proc_subdir_lock);
-	de = de->subdir;
+	/* try first hash bucket */
+	de = de->pde_hash_buckets[0];
+
 	i = ctx->pos - 2;
 	for (;;) {
 		if (!de) {
-			spin_unlock(&proc_subdir_lock);
-			return 0;
+			/* try next hash bucket if one is availalable */
+			hash_idx = find_next_hash_bucket(dir, hash_idx + 1);
+			if (hash_idx == PROC_PDE_HASH_BUCKETS) {
+				spin_unlock(&proc_subdir_lock);
+				return 0;
+			}
+			de = dir->pde_hash_buckets[hash_idx];
 		}
 		if (!i)
 			break;
@@ -250,6 +272,12 @@ int proc_readdir_de(struct proc_dir_entry *de, struct file *file,
 		spin_lock(&proc_subdir_lock);
 		ctx->pos++;
 		next = de->next;
+		if (!next) {
+			/* try next hash bucket if one is availalable */
+			hash_idx = find_next_hash_bucket(dir, hash_idx + 1);
+			if (hash_idx != PROC_PDE_HASH_BUCKETS)
+				next = dir->pde_hash_buckets[hash_idx];
+		}
 		pde_put(de);
 		de = next;
 	} while (de);
@@ -287,8 +315,12 @@ static const struct inode_operations proc_dir_inode_operations = {
 static int proc_register(struct proc_dir_entry * dir, struct proc_dir_entry * dp)
 {
 	struct proc_dir_entry *tmp;
+	unsigned int name_hash;
 	int ret;
-	
+
+	if (!S_ISDIR(dir->mode))
+		return -EINVAL;
+
 	ret = proc_alloc_inum(&dp->low_ino);
 	if (ret)
 		return ret;
@@ -309,16 +341,17 @@ static int proc_register(struct proc_dir_entry * dir, struct proc_dir_entry * dp
 
 	spin_lock(&proc_subdir_lock);
 
-	for (tmp = dir->subdir; tmp; tmp = tmp->next)
+	name_hash = proc_pde_name_hash(dp->name, strlen(dp->name));
+	for (tmp = dir->pde_hash_buckets[name_hash]; tmp; tmp = tmp->next)
 		if (strcmp(tmp->name, dp->name) == 0) {
 			WARN(1, "proc_dir_entry '%s/%s' already registered\n",
 				dir->name, dp->name);
 			break;
 		}
 
-	dp->next = dir->subdir;
+	dp->next = dir->pde_hash_buckets[name_hash];
 	dp->parent = dir;
-	dir->subdir = dp;
+	dir->pde_hash_buckets[name_hash] = dp;
 	spin_unlock(&proc_subdir_lock);
 
 	return 0;
@@ -349,6 +382,14 @@ static struct proc_dir_entry *__proc_create(struct proc_dir_entry **parent,
 	ent = kzalloc(sizeof(struct proc_dir_entry) + qstr.len + 1, GFP_KERNEL);
 	if (!ent)
 		goto out;
+	if (S_ISDIR(mode)) {
+		ent->pde_hash_buckets = kzalloc(PROC_PDE_HASH_SIZE, GFP_KERNEL);
+		if (!ent->pde_hash_buckets) {
+			kfree(ent);
+			ent = NULL;
+			goto out;
+		}
+	}
 
 	memcpy(ent->name, fn, qstr.len + 1);
 	ent->namelen = qstr.len;
@@ -471,6 +512,8 @@ static void free_proc_entry(struct proc_dir_entry *de)
 
 	if (S_ISLNK(de->mode))
 		kfree(de->data);
+	if (S_ISDIR(de->mode))
+		kfree(de->pde_hash_buckets);
 	kfree(de);
 }
 
@@ -488,7 +531,10 @@ void remove_proc_entry(const char *name, struct proc_dir_entry *parent)
 	struct proc_dir_entry **p;
 	struct proc_dir_entry *de = NULL;
 	const char *fn = name;
-	unsigned int len;
+	unsigned int len, name_hash;
+
+	if (!S_ISDIR(parent->mode))
+		return;
 
 	spin_lock(&proc_subdir_lock);
 	if (__xlate_proc_name(name, &parent, &fn) != 0) {
@@ -497,7 +543,8 @@ void remove_proc_entry(const char *name, struct proc_dir_entry *parent)
 	}
 	len = strlen(fn);
 
-	for (p = &parent->subdir; *p; p=&(*p)->next ) {
+	name_hash = proc_pde_name_hash(fn, len);
+	for (p = &parent->pde_hash_buckets[name_hash]; *p; p = &(*p)->next) {
 		if (proc_match(len, fn, *p)) {
 			de = *p;
 			*p = de->next;
@@ -516,9 +563,11 @@ void remove_proc_entry(const char *name, struct proc_dir_entry *parent)
 	if (S_ISDIR(de->mode))
 		parent->nlink--;
 	de->nlink = 0;
-	WARN(de->subdir, "%s: removing non-empty directory "
-			 "'%s/%s', leaking at least '%s'\n", __func__,
-			 de->parent->name, de->name, de->subdir->name);
+	if (S_ISDIR(de->mode))
+		WARN(de->pde_hash_buckets[name_hash],
+		     "%s: removing non-empty directory '%s/%s', leaking at least '%s'\n",
+		     __func__, de->parent->name, de->name,
+		     de->pde_hash_buckets[name_hash]->name);
 	pde_put(de);
 }
 EXPORT_SYMBOL(remove_proc_entry);
@@ -528,7 +577,10 @@ int remove_proc_subtree(const char *name, struct proc_dir_entry *parent)
 	struct proc_dir_entry **p;
 	struct proc_dir_entry *root = NULL, *de, *next;
 	const char *fn = name;
-	unsigned int len;
+	unsigned int len, name_hash, hash_idx;
+
+	if (!S_ISDIR(parent->mode))
+		return -EINVAL;
 
 	spin_lock(&proc_subdir_lock);
 	if (__xlate_proc_name(name, &parent, &fn) != 0) {
@@ -536,8 +588,9 @@ int remove_proc_subtree(const char *name, struct proc_dir_entry *parent)
 		return -ENOENT;
 	}
 	len = strlen(fn);
+	name_hash = proc_pde_name_hash(fn, len);
 
-	for (p = &parent->subdir; *p; p=&(*p)->next ) {
+	for (p = &parent->pde_hash_buckets[name_hash]; *p; p = &(*p)->next) {
 		if (proc_match(len, fn, *p)) {
 			root = *p;
 			*p = root->next;
@@ -551,12 +604,15 @@ int remove_proc_subtree(const char *name, struct proc_dir_entry *parent)
 	}
 	de = root;
 	while (1) {
-		next = de->subdir;
-		if (next) {
-			de->subdir = next->next;
-			next->next = NULL;
-			de = next;
-			continue;
+		if (S_ISDIR(de->mode)) {
+			hash_idx = find_first_hash_bucket(de);
+			if (hash_idx < PROC_PDE_HASH_BUCKETS) {
+				next = de->pde_hash_buckets[hash_idx];
+				de->pde_hash_buckets[hash_idx] = next->next;
+				next->next = NULL;
+				de = next;
+				continue;
+			}
 		}
 		spin_unlock(&proc_subdir_lock);
 
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index 7da13e49128a..7c32e7821453 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -18,16 +18,28 @@
 struct ctl_table_header;
 struct mempolicy;
 
+#define PROC_PDE_SHIFT		6
+#define PROC_PDE_HASH_BUCKETS	(1 << PROC_PDE_SHIFT)
+#define PROC_PDE_HASH_MASK	(PROC_PDE_HASH_BUCKETS - 1)
+#define PROC_PDE_HASH_SIZE	(PROC_PDE_HASH_BUCKETS * \
+				 sizeof(struct proc_dir_entry *))
+
+static inline unsigned int proc_pde_name_hash(const unsigned char *name,
+					      const unsigned int len)
+{
+	return full_name_hash(name, len) & PROC_PDE_HASH_MASK;
+}
+
 /*
  * This is not completely implemented yet. The idea is to
  * create an in-memory tree (like the actual /proc filesystem
  * tree) of these proc_dir_entries, so that we can dynamically
  * add new files to /proc.
  *
- * The "next" pointer creates a linked list of one /proc directory,
- * while parent/subdir create the directory structure (every
- * /proc file has a parent, but "subdir" is NULL for all
- * non-directory entries).
+ * The "pde_hash_buckets" pointer is a hash table of linked lists for
+ * one /proc directory (every /proc file has a parent, but it is NULL
+ * for all non-directory entries). The linked lists are implemented using
+ * the "next" fields of the proc_dir_entry.
  */
 struct proc_dir_entry {
 	unsigned int low_ino;
@@ -38,7 +50,7 @@ struct proc_dir_entry {
 	loff_t size;
 	const struct inode_operations *proc_iops;
 	const struct file_operations *proc_fops;
-	struct proc_dir_entry *next, *parent, *subdir;
+	struct proc_dir_entry *next, *parent;
 	void *data;
 	atomic_t count;		/* use count */
 	atomic_t in_use;	/* number of callers into module in progress; */
@@ -46,10 +58,37 @@ struct proc_dir_entry {
 	struct completion *pde_unload_completion;
 	struct list_head pde_openers;	/* who did ->open, but not ->release */
 	spinlock_t pde_unload_lock; /* proc_fops checks and pde_users bumps */
+	struct proc_dir_entry **pde_hash_buckets; /* hash table for dirs */
 	u8 namelen;
 	char name[];
 };
 
+/* index for the next non-NULL bucket in the hash table */
+static inline unsigned int find_next_hash_bucket(const struct proc_dir_entry *pde,
+						 const unsigned int start)
+{
+	unsigned int i;
+
+	if (start >= PROC_PDE_HASH_BUCKETS)
+		return PROC_PDE_HASH_BUCKETS;
+
+	for (i = start;
+	     (i < PROC_PDE_HASH_BUCKETS) && (!pde->pde_hash_buckets[i]);
+	     i++)
+		;
+
+	if (!pde->pde_hash_buckets[i])
+		i = PROC_PDE_HASH_BUCKETS;
+
+	return i;
+}
+
+/* index for the first non-NULL bucket in the hash table */
+static inline int find_first_hash_bucket(const struct proc_dir_entry *pde)
+{
+	return find_next_hash_bucket(pde, 0);
+}
+
 union proc_op {
 	int (*proc_get_link)(struct dentry *, struct path *);
 	int (*proc_show)(struct seq_file *m,
diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
index 6fc308ec105c..da2e9f4533ed 100644
--- a/fs/proc/proc_net.c
+++ b/fs/proc/proc_net.c
@@ -191,6 +191,12 @@ static __net_init int proc_net_ns_init(struct net *net)
 	netd = kzalloc(sizeof(*netd) + 4, GFP_KERNEL);
 	if (!netd)
 		goto out;
+	netd->pde_hash_buckets = kzalloc(PROC_PDE_HASH_SIZE, GFP_KERNEL);
+	if (!netd->pde_hash_buckets) {
+		kfree(netd);
+		netd = NULL;
+		goto out;
+	}
 
 	netd->data = net;
 	netd->mode = S_IFDIR | S_IRUGO | S_IXUGO;
@@ -217,6 +223,7 @@ out:
 static __net_exit void proc_net_ns_exit(struct net *net)
 {
 	remove_proc_entry("stat", net->proc_net);
+	kfree(net->proc_net->pde_hash_buckets);
 	kfree(net->proc_net);
 }
 
diff --git a/fs/proc/root.c b/fs/proc/root.c
index 094e44d4a6be..bcd830465871 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -20,6 +20,7 @@
 #include <linux/mount.h>
 #include <linux/pid_namespace.h>
 #include <linux/parser.h>
+#include <linux/slab.h>
 
 #include "internal.h"
 
@@ -166,6 +167,10 @@ void __init proc_root_init(void)
 {
 	int err;
 
+	proc_root.pde_hash_buckets = kzalloc(PROC_PDE_HASH_SIZE, GFP_KERNEL);
+	if (!proc_root.pde_hash_buckets)
+		return;
+
 	proc_init_inodecache();
 	err = register_filesystem(&proc_fs_type);
 	if (err)
-- 
2.1.0
