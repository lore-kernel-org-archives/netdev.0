From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH linux v2 1/1] fs/proc: use a rb tree for the directory entries
Date: Mon,  6 Oct 2014 16:30:34 +0200
Message-ID: <1412605834-4417-2-git-send-email-nicolas.dichtel@6wind.com>
References: <542EA009.4060009@6wind.com>
 <1412605834-4417-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, ebiederm@xmission.com,
	akpm@linux-foundation.org, adobriyan@gmail.com,
	rui.xiang@huawei.com, viro@zeniv.linux.org.uk, oleg@redhat.com,
	gorcunov@openvz.org, kirill.shutemov@linux.intel.com,
	grant.likely@secretlab.ca, tytso@mit.edu,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412605834-4417-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current implementation for the directories in /proc is using a single
linked list. This is slow when handling directories with large numbers of
entries (eg netdevice-related entries when lots of tunnels are opened).

This patch replaces this linked list by a red-black tree.

Here are some numbers:

dummy30000.batch contains 30 000 times 'link add type dummy'.

Before the patch:
$ time ip -b dummy30000.batch
real	2m31.950s
user	0m0.440s
sys	2m21.440s
$ time rmmod dummy
real	1m35.764s
user	0m0.000s
sys	1m24.088s

After the patch:
$ time ip -b dummy30000.batch
real	2m0.874s
user	0m0.448s
sys	1m49.720s
$ time rmmod dummy
real	1m13.988s
user	0m0.000s
sys	1m1.008s

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 fs/proc/generic.c  | 164 ++++++++++++++++++++++++++++++++++-------------------
 fs/proc/internal.h |  11 ++--
 fs/proc/proc_net.c |   1 +
 fs/proc/root.c     |   1 +
 4 files changed, 113 insertions(+), 64 deletions(-)

diff --git a/fs/proc/generic.c b/fs/proc/generic.c
index 317b72641ebf..9f8fa1e5e8aa 100644
--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -31,9 +31,81 @@ static DEFINE_SPINLOCK(proc_subdir_lock);
 
 static int proc_match(unsigned int len, const char *name, struct proc_dir_entry *de)
 {
-	if (de->namelen != len)
-		return 0;
-	return !memcmp(name, de->name, len);
+	if (len < de->namelen)
+		return -1;
+	if (len > de->namelen)
+		return 1;
+
+	return memcmp(name, de->name, len);
+}
+
+static struct proc_dir_entry *pde_subdir_first(struct proc_dir_entry *dir)
+{
+	struct rb_node *node = rb_first(&dir->subdir);
+
+	if (node == NULL)
+		return NULL;
+
+	return rb_entry(node, struct proc_dir_entry, subdir_node);
+}
+
+static struct proc_dir_entry *pde_subdir_next(struct proc_dir_entry *dir)
+{
+	struct rb_node *node = rb_next(&dir->subdir_node);
+
+	if (node == NULL)
+		return NULL;
+
+	return rb_entry(node, struct proc_dir_entry, subdir_node);
+}
+
+static struct proc_dir_entry *pde_subdir_find(struct proc_dir_entry *dir,
+					      const char *name,
+					      unsigned int len)
+{
+	struct rb_node *node = dir->subdir.rb_node;
+
+	while (node) {
+		struct proc_dir_entry *de = container_of(node,
+							 struct proc_dir_entry,
+							 subdir_node);
+		int result = proc_match(len, name, de);
+
+		if (result < 0)
+			node = node->rb_left;
+		else if (result > 0)
+			node = node->rb_right;
+		else
+			return de;
+	}
+	return NULL;
+}
+
+static bool pde_subdir_insert(struct proc_dir_entry *dir,
+			      struct proc_dir_entry *de)
+{
+	struct rb_root *root = &dir->subdir;
+	struct rb_node **new = &root->rb_node, *parent = NULL;
+
+	/* Figure out where to put new node */
+	while (*new) {
+		struct proc_dir_entry *this =
+			container_of(*new, struct proc_dir_entry, subdir_node);
+		int result = proc_match(de->namelen, de->name, this);
+
+		parent = *new;
+		if (result < 0)
+			new = &(*new)->rb_left;
+		else if (result > 0)
+			new = &(*new)->rb_right;
+		else
+			return false;
+	}
+
+	/* Add new node and rebalance tree. */
+	rb_link_node(&de->subdir_node, parent, new);
+	rb_insert_color(&de->subdir_node, root);
+	return true;
 }
 
 static int proc_notify_change(struct dentry *dentry, struct iattr *iattr)
@@ -92,10 +164,7 @@ static int __xlate_proc_name(const char *name, struct proc_dir_entry **ret,
 			break;
 
 		len = next - cp;
-		for (de = de->subdir; de ; de = de->next) {
-			if (proc_match(len, cp, de))
-				break;
-		}
+		de = pde_subdir_find(de, cp, len);
 		if (!de) {
 			WARN(1, "name '%s'\n", name);
 			return -ENOENT;
@@ -183,19 +252,16 @@ struct dentry *proc_lookup_de(struct proc_dir_entry *de, struct inode *dir,
 	struct inode *inode;
 
 	spin_lock(&proc_subdir_lock);
-	for (de = de->subdir; de ; de = de->next) {
-		if (de->namelen != dentry->d_name.len)
-			continue;
-		if (!memcmp(dentry->d_name.name, de->name, de->namelen)) {
-			pde_get(de);
-			spin_unlock(&proc_subdir_lock);
-			inode = proc_get_inode(dir->i_sb, de);
-			if (!inode)
-				return ERR_PTR(-ENOMEM);
-			d_set_d_op(dentry, &simple_dentry_operations);
-			d_add(dentry, inode);
-			return NULL;
-		}
+	de = pde_subdir_find(de, dentry->d_name.name, dentry->d_name.len);
+	if (de) {
+		pde_get(de);
+		spin_unlock(&proc_subdir_lock);
+		inode = proc_get_inode(dir->i_sb, de);
+		if (!inode)
+			return ERR_PTR(-ENOMEM);
+		d_set_d_op(dentry, &simple_dentry_operations);
+		d_add(dentry, inode);
+		return NULL;
 	}
 	spin_unlock(&proc_subdir_lock);
 	return ERR_PTR(-ENOENT);
@@ -225,7 +291,7 @@ int proc_readdir_de(struct proc_dir_entry *de, struct file *file,
 		return 0;
 
 	spin_lock(&proc_subdir_lock);
-	de = de->subdir;
+	de = pde_subdir_first(de);
 	i = ctx->pos - 2;
 	for (;;) {
 		if (!de) {
@@ -234,7 +300,7 @@ int proc_readdir_de(struct proc_dir_entry *de, struct file *file,
 		}
 		if (!i)
 			break;
-		de = de->next;
+		de = pde_subdir_next(de);
 		i--;
 	}
 
@@ -249,7 +315,7 @@ int proc_readdir_de(struct proc_dir_entry *de, struct file *file,
 		}
 		spin_lock(&proc_subdir_lock);
 		ctx->pos++;
-		next = de->next;
+		next = pde_subdir_next(de);
 		pde_put(de);
 		de = next;
 	} while (de);
@@ -286,9 +352,8 @@ static const struct inode_operations proc_dir_inode_operations = {
 
 static int proc_register(struct proc_dir_entry * dir, struct proc_dir_entry * dp)
 {
-	struct proc_dir_entry *tmp;
 	int ret;
-	
+
 	ret = proc_alloc_inum(&dp->low_ino);
 	if (ret)
 		return ret;
@@ -308,17 +373,10 @@ static int proc_register(struct proc_dir_entry * dir, struct proc_dir_entry * dp
 	}
 
 	spin_lock(&proc_subdir_lock);
-
-	for (tmp = dir->subdir; tmp; tmp = tmp->next)
-		if (strcmp(tmp->name, dp->name) == 0) {
-			WARN(1, "proc_dir_entry '%s/%s' already registered\n",
-				dir->name, dp->name);
-			break;
-		}
-
-	dp->next = dir->subdir;
 	dp->parent = dir;
-	dir->subdir = dp;
+	if (pde_subdir_insert(dir, dp) == false)
+		WARN(1, "proc_dir_entry '%s/%s' already registered\n",
+		     dir->name, dp->name);
 	spin_unlock(&proc_subdir_lock);
 
 	return 0;
@@ -354,6 +412,7 @@ static struct proc_dir_entry *__proc_create(struct proc_dir_entry **parent,
 	ent->namelen = qstr.len;
 	ent->mode = mode;
 	ent->nlink = nlink;
+	ent->subdir = RB_ROOT;
 	atomic_set(&ent->count, 1);
 	spin_lock_init(&ent->pde_unload_lock);
 	INIT_LIST_HEAD(&ent->pde_openers);
@@ -485,7 +544,6 @@ void pde_put(struct proc_dir_entry *pde)
  */
 void remove_proc_entry(const char *name, struct proc_dir_entry *parent)
 {
-	struct proc_dir_entry **p;
 	struct proc_dir_entry *de = NULL;
 	const char *fn = name;
 	unsigned int len;
@@ -497,14 +555,9 @@ void remove_proc_entry(const char *name, struct proc_dir_entry *parent)
 	}
 	len = strlen(fn);
 
-	for (p = &parent->subdir; *p; p=&(*p)->next ) {
-		if (proc_match(len, fn, *p)) {
-			de = *p;
-			*p = de->next;
-			de->next = NULL;
-			break;
-		}
-	}
+	de = pde_subdir_find(parent, fn, len);
+	if (de)
+		rb_erase(&de->subdir_node, &parent->subdir);
 	spin_unlock(&proc_subdir_lock);
 	if (!de) {
 		WARN(1, "name '%s'\n", name);
@@ -516,16 +569,15 @@ void remove_proc_entry(const char *name, struct proc_dir_entry *parent)
 	if (S_ISDIR(de->mode))
 		parent->nlink--;
 	de->nlink = 0;
-	WARN(de->subdir, "%s: removing non-empty directory "
-			 "'%s/%s', leaking at least '%s'\n", __func__,
-			 de->parent->name, de->name, de->subdir->name);
+	WARN(pde_subdir_first(de),
+	     "%s: removing non-empty directory '%s/%s', leaking at least '%s'\n",
+	     __func__, de->parent->name, de->name, pde_subdir_first(de)->name);
 	pde_put(de);
 }
 EXPORT_SYMBOL(remove_proc_entry);
 
 int remove_proc_subtree(const char *name, struct proc_dir_entry *parent)
 {
-	struct proc_dir_entry **p;
 	struct proc_dir_entry *root = NULL, *de, *next;
 	const char *fn = name;
 	unsigned int len;
@@ -537,24 +589,18 @@ int remove_proc_subtree(const char *name, struct proc_dir_entry *parent)
 	}
 	len = strlen(fn);
 
-	for (p = &parent->subdir; *p; p=&(*p)->next ) {
-		if (proc_match(len, fn, *p)) {
-			root = *p;
-			*p = root->next;
-			root->next = NULL;
-			break;
-		}
-	}
+	root = pde_subdir_find(parent, fn, len);
 	if (!root) {
 		spin_unlock(&proc_subdir_lock);
 		return -ENOENT;
 	}
+	rb_erase(&root->subdir_node, &parent->subdir);
+
 	de = root;
 	while (1) {
-		next = de->subdir;
+		next = pde_subdir_first(de);
 		if (next) {
-			de->subdir = next->next;
-			next->next = NULL;
+			rb_erase(&next->subdir_node, &de->subdir);
 			de = next;
 			continue;
 		}
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index 7da13e49128a..433557634c1b 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -24,10 +24,9 @@ struct mempolicy;
  * tree) of these proc_dir_entries, so that we can dynamically
  * add new files to /proc.
  *
- * The "next" pointer creates a linked list of one /proc directory,
- * while parent/subdir create the directory structure (every
- * /proc file has a parent, but "subdir" is NULL for all
- * non-directory entries).
+ * parent/subdir are used for the directory structure (every /proc file has a
+ * parent, but "subdir" is empty for all non-directory entries).
+ * subdir_node is used to build the rb tree "subdir" of the parent.
  */
 struct proc_dir_entry {
 	unsigned int low_ino;
@@ -38,7 +37,9 @@ struct proc_dir_entry {
 	loff_t size;
 	const struct inode_operations *proc_iops;
 	const struct file_operations *proc_fops;
-	struct proc_dir_entry *next, *parent, *subdir;
+	struct proc_dir_entry *parent;
+	struct rb_root subdir;
+	struct rb_node subdir_node;
 	void *data;
 	atomic_t count;		/* use count */
 	atomic_t in_use;	/* number of callers into module in progress; */
diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
index a63af3e0a612..1bde894bc624 100644
--- a/fs/proc/proc_net.c
+++ b/fs/proc/proc_net.c
@@ -192,6 +192,7 @@ static __net_init int proc_net_ns_init(struct net *net)
 	if (!netd)
 		goto out;
 
+	netd->subdir = RB_ROOT;
 	netd->data = net;
 	netd->nlink = 2;
 	netd->namelen = 3;
diff --git a/fs/proc/root.c b/fs/proc/root.c
index 094e44d4a6be..4eae849baedd 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -166,6 +166,7 @@ void __init proc_root_init(void)
 {
 	int err;
 
+	proc_root.subdir = RB_ROOT;
 	proc_init_inodecache();
 	err = register_filesystem(&proc_fs_type);
 	if (err)
-- 
2.1.0
