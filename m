From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 04/29] sysctl: Move the implementation into fs/proc/proc_sysctl.c
Date: Thu, 26 Jan 2012 20:51:40 -0800
Message-ID: <1327639925-12920-4-git-send-email-ebiederm@xmission.com>
References: <m1pqe5ah3z.fsf@fess.ebiederm.org>
Cc: <linux-fsdevel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>,
	Damien Millescamps <damien.millescamps@6wind.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1pqe5ah3z.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move the core sysctl code from kernel/sysctl.c and kernel/sysctl_check.c
into fs/proc/proc_sysctl.c.

Currently sysctl maintenance is hampered by the sysctl implementation
being split across 3 files with artificial layering between them.
Consolidate the entire sysctl implementation into 1 file so that
it is easier to see what is going on and hopefully allowing for
simpler maintenance.

For functions that are now only used in fs/proc/proc_sysctl.c remove
their declarations from sysctl.h and make them static in fs/proc/proc_sysctl.c

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/proc/internal.h     |    3 +
 fs/proc/proc_sysctl.c  |  622 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/sysctl.h |   16 --
 kernel/Makefile        |    1 -
 kernel/sysctl.c        |  464 ------------------------------------
 kernel/sysctl_check.c  |  160 -------------
 6 files changed, 625 insertions(+), 641 deletions(-)
 delete mode 100644 kernel/sysctl_check.c

diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index 2925775..3b5ecd9 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -10,12 +10,15 @@
  */
 
 #include <linux/proc_fs.h>
+struct  ctl_table_header;
 
 extern struct proc_dir_entry proc_root;
 #ifdef CONFIG_PROC_SYSCTL
 extern int proc_sys_init(void);
+extern void sysctl_head_put(struct ctl_table_header *head);
 #else
 static inline void proc_sys_init(void) { }
+static inline void sysctl_head_put(struct ctl_table_header *head) { }
 #endif
 #ifdef CONFIG_NET
 extern int proc_net_init(void);
diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index 9d29d28..06e6f10 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -7,6 +7,7 @@
 #include <linux/proc_fs.h>
 #include <linux/security.h>
 #include <linux/namei.h>
+#include <linux/module.h>
 #include "internal.h"
 
 static const struct dentry_operations proc_sys_dentry_operations;
@@ -24,6 +25,209 @@ void proc_sys_poll_notify(struct ctl_table_poll *poll)
 	wake_up_interruptible(&poll->wait);
 }
 
+static struct ctl_table root_table[1];
+static struct ctl_table_root sysctl_table_root;
+static struct ctl_table_header root_table_header = {
+	{{.count = 1,
+	.ctl_table = root_table,
+	.ctl_entry = LIST_HEAD_INIT(sysctl_table_root.default_set.list),}},
+	.root = &sysctl_table_root,
+	.set = &sysctl_table_root.default_set,
+};
+static struct ctl_table_root sysctl_table_root = {
+	.root_list = LIST_HEAD_INIT(sysctl_table_root.root_list),
+	.default_set.list = LIST_HEAD_INIT(root_table_header.ctl_entry),
+};
+
+static DEFINE_SPINLOCK(sysctl_lock);
+
+/* called under sysctl_lock */
+static int use_table(struct ctl_table_header *p)
+{
+	if (unlikely(p->unregistering))
+		return 0;
+	p->used++;
+	return 1;
+}
+
+/* called under sysctl_lock */
+static void unuse_table(struct ctl_table_header *p)
+{
+	if (!--p->used)
+		if (unlikely(p->unregistering))
+			complete(p->unregistering);
+}
+
+/* called under sysctl_lock, will reacquire if has to wait */
+static void start_unregistering(struct ctl_table_header *p)
+{
+	/*
+	 * if p->used is 0, nobody will ever touch that entry again;
+	 * we'll eliminate all paths to it before dropping sysctl_lock
+	 */
+	if (unlikely(p->used)) {
+		struct completion wait;
+		init_completion(&wait);
+		p->unregistering = &wait;
+		spin_unlock(&sysctl_lock);
+		wait_for_completion(&wait);
+		spin_lock(&sysctl_lock);
+	} else {
+		/* anything non-NULL; we'll never dereference it */
+		p->unregistering = ERR_PTR(-EINVAL);
+	}
+	/*
+	 * do not remove from the list until nobody holds it; walking the
+	 * list in do_sysctl() relies on that.
+	 */
+	list_del_init(&p->ctl_entry);
+}
+
+static void sysctl_head_get(struct ctl_table_header *head)
+{
+	spin_lock(&sysctl_lock);
+	head->count++;
+	spin_unlock(&sysctl_lock);
+}
+
+void sysctl_head_put(struct ctl_table_header *head)
+{
+	spin_lock(&sysctl_lock);
+	if (!--head->count)
+		kfree_rcu(head, rcu);
+	spin_unlock(&sysctl_lock);
+}
+
+static struct ctl_table_header *sysctl_head_grab(struct ctl_table_header *head)
+{
+	if (!head)
+		BUG();
+	spin_lock(&sysctl_lock);
+	if (!use_table(head))
+		head = ERR_PTR(-ENOENT);
+	spin_unlock(&sysctl_lock);
+	return head;
+}
+
+static void sysctl_head_finish(struct ctl_table_header *head)
+{
+	if (!head)
+		return;
+	spin_lock(&sysctl_lock);
+	unuse_table(head);
+	spin_unlock(&sysctl_lock);
+}
+
+static struct ctl_table_set *
+lookup_header_set(struct ctl_table_root *root, struct nsproxy *namespaces)
+{
+	struct ctl_table_set *set = &root->default_set;
+	if (root->lookup)
+		set = root->lookup(root, namespaces);
+	return set;
+}
+
+static struct list_head *
+lookup_header_list(struct ctl_table_root *root, struct nsproxy *namespaces)
+{
+	struct ctl_table_set *set = lookup_header_set(root, namespaces);
+	return &set->list;
+}
+
+static struct ctl_table_header *__sysctl_head_next(struct nsproxy *namespaces,
+						struct ctl_table_header *prev)
+{
+	struct ctl_table_root *root;
+	struct list_head *header_list;
+	struct ctl_table_header *head;
+	struct list_head *tmp;
+
+	spin_lock(&sysctl_lock);
+	if (prev) {
+		head = prev;
+		tmp = &prev->ctl_entry;
+		unuse_table(prev);
+		goto next;
+	}
+	tmp = &root_table_header.ctl_entry;
+	for (;;) {
+		head = list_entry(tmp, struct ctl_table_header, ctl_entry);
+
+		if (!use_table(head))
+			goto next;
+		spin_unlock(&sysctl_lock);
+		return head;
+	next:
+		root = head->root;
+		tmp = tmp->next;
+		header_list = lookup_header_list(root, namespaces);
+		if (tmp != header_list)
+			continue;
+
+		do {
+			root = list_entry(root->root_list.next,
+					struct ctl_table_root, root_list);
+			if (root == &sysctl_table_root)
+				goto out;
+			header_list = lookup_header_list(root, namespaces);
+		} while (list_empty(header_list));
+		tmp = header_list->next;
+	}
+out:
+	spin_unlock(&sysctl_lock);
+	return NULL;
+}
+
+static struct ctl_table_header *sysctl_head_next(struct ctl_table_header *prev)
+{
+	return __sysctl_head_next(current->nsproxy, prev);
+}
+
+void register_sysctl_root(struct ctl_table_root *root)
+{
+	spin_lock(&sysctl_lock);
+	list_add_tail(&root->root_list, &sysctl_table_root.root_list);
+	spin_unlock(&sysctl_lock);
+}
+
+/*
+ * sysctl_perm does NOT grant the superuser all rights automatically, because
+ * some sysctl variables are readonly even to root.
+ */
+
+static int test_perm(int mode, int op)
+{
+	if (!current_euid())
+		mode >>= 6;
+	else if (in_egroup_p(0))
+		mode >>= 3;
+	if ((op & ~mode & (MAY_READ|MAY_WRITE|MAY_EXEC)) == 0)
+		return 0;
+	return -EACCES;
+}
+
+static int sysctl_perm(struct ctl_table_root *root, struct ctl_table *table, int op)
+{
+	int mode;
+
+	if (root->permissions)
+		mode = root->permissions(root, current->nsproxy, table);
+	else
+		mode = table->mode;
+
+	return test_perm(mode, op);
+}
+
+static void sysctl_set_parent(struct ctl_table *parent, struct ctl_table *table)
+{
+	for (; table->procname; table++) {
+		table->parent = parent;
+		if (table->child)
+			sysctl_set_parent(table, table->child);
+	}
+}
+
+
 static struct inode *proc_sys_make_inode(struct super_block *sb,
 		struct ctl_table_header *head, struct ctl_table *table)
 {
@@ -435,6 +639,21 @@ static int proc_sys_delete(const struct dentry *dentry)
 	return !!PROC_I(dentry->d_inode)->sysctl->unregistering;
 }
 
+static int sysctl_is_seen(struct ctl_table_header *p)
+{
+	struct ctl_table_set *set = p->set;
+	int res;
+	spin_lock(&sysctl_lock);
+	if (p->unregistering)
+		res = 0;
+	else if (!set->is_seen)
+		res = 1;
+	else
+		res = set->is_seen(set);
+	spin_unlock(&sysctl_lock);
+	return res;
+}
+
 static int proc_sys_compare(const struct dentry *parent,
 		const struct inode *pinode,
 		const struct dentry *dentry, const struct inode *inode,
@@ -460,6 +679,409 @@ static const struct dentry_operations proc_sys_dentry_operations = {
 	.d_compare	= proc_sys_compare,
 };
 
+static struct ctl_table *is_branch_in(struct ctl_table *branch,
+				      struct ctl_table *table)
+{
+	struct ctl_table *p;
+	const char *s = branch->procname;
+
+	/* branch should have named subdirectory as its first element */
+	if (!s || !branch->child)
+		return NULL;
+
+	/* ... and nothing else */
+	if (branch[1].procname)
+		return NULL;
+
+	/* table should contain subdirectory with the same name */
+	for (p = table; p->procname; p++) {
+		if (!p->child)
+			continue;
+		if (p->procname && strcmp(p->procname, s) == 0)
+			return p;
+	}
+	return NULL;
+}
+
+/* see if attaching q to p would be an improvement */
+static void try_attach(struct ctl_table_header *p, struct ctl_table_header *q)
+{
+	struct ctl_table *to = p->ctl_table, *by = q->ctl_table;
+	struct ctl_table *next;
+	int is_better = 0;
+	int not_in_parent = !p->attached_by;
+
+	while ((next = is_branch_in(by, to)) != NULL) {
+		if (by == q->attached_by)
+			is_better = 1;
+		if (to == p->attached_by)
+			not_in_parent = 1;
+		by = by->child;
+		to = next->child;
+	}
+
+	if (is_better && not_in_parent) {
+		q->attached_by = by;
+		q->attached_to = to;
+		q->parent = p;
+	}
+}
+
+#ifdef CONFIG_SYSCTL_SYSCALL_CHECK
+static int sysctl_depth(struct ctl_table *table)
+{
+	struct ctl_table *tmp;
+	int depth;
+
+	depth = 0;
+	for (tmp = table; tmp->parent; tmp = tmp->parent)
+		depth++;
+
+	return depth;
+}
+
+static struct ctl_table *sysctl_parent(struct ctl_table *table, int n)
+{
+	int i;
+
+	for (i = 0; table && i < n; i++)
+		table = table->parent;
+
+	return table;
+}
+
+
+static void sysctl_print_path(struct ctl_table *table)
+{
+	struct ctl_table *tmp;
+	int depth, i;
+	depth = sysctl_depth(table);
+	if (table->procname) {
+		for (i = depth; i >= 0; i--) {
+			tmp = sysctl_parent(table, i);
+			printk("/%s", tmp->procname?tmp->procname:"");
+		}
+	}
+	printk(" ");
+}
+
+static struct ctl_table *sysctl_check_lookup(struct nsproxy *namespaces,
+						struct ctl_table *table)
+{
+	struct ctl_table_header *head;
+	struct ctl_table *ref, *test;
+	int depth, cur_depth;
+
+	depth = sysctl_depth(table);
+
+	for (head = __sysctl_head_next(namespaces, NULL); head;
+	     head = __sysctl_head_next(namespaces, head)) {
+		cur_depth = depth;
+		ref = head->ctl_table;
+repeat:
+		test = sysctl_parent(table, cur_depth);
+		for (; ref->procname; ref++) {
+			int match = 0;
+			if (cur_depth && !ref->child)
+				continue;
+
+			if (test->procname && ref->procname &&
+			    (strcmp(test->procname, ref->procname) == 0))
+					match++;
+
+			if (match) {
+				if (cur_depth != 0) {
+					cur_depth--;
+					ref = ref->child;
+					goto repeat;
+				}
+				goto out;
+			}
+		}
+	}
+	ref = NULL;
+out:
+	sysctl_head_finish(head);
+	return ref;
+}
+
+static void set_fail(const char **fail, struct ctl_table *table, const char *str)
+{
+	if (*fail) {
+		printk(KERN_ERR "sysctl table check failed: ");
+		sysctl_print_path(table);
+		printk(" %s\n", *fail);
+		dump_stack();
+	}
+	*fail = str;
+}
+
+static void sysctl_check_leaf(struct nsproxy *namespaces,
+				struct ctl_table *table, const char **fail)
+{
+	struct ctl_table *ref;
+
+	ref = sysctl_check_lookup(namespaces, table);
+	if (ref && (ref != table))
+		set_fail(fail, table, "Sysctl already exists");
+}
+
+static int sysctl_check_table(struct nsproxy *namespaces, struct ctl_table *table)
+{
+	int error = 0;
+	for (; table->procname; table++) {
+		const char *fail = NULL;
+
+		if (table->parent) {
+			if (!table->parent->procname)
+				set_fail(&fail, table, "Parent without procname");
+		}
+		if (table->child) {
+			if (table->data)
+				set_fail(&fail, table, "Directory with data?");
+			if (table->maxlen)
+				set_fail(&fail, table, "Directory with maxlen?");
+			if ((table->mode & (S_IRUGO|S_IXUGO)) != table->mode)
+				set_fail(&fail, table, "Writable sysctl directory");
+			if (table->proc_handler)
+				set_fail(&fail, table, "Directory with proc_handler");
+			if (table->extra1)
+				set_fail(&fail, table, "Directory with extra1");
+			if (table->extra2)
+				set_fail(&fail, table, "Directory with extra2");
+		} else {
+			if ((table->proc_handler == proc_dostring) ||
+			    (table->proc_handler == proc_dointvec) ||
+			    (table->proc_handler == proc_dointvec_minmax) ||
+			    (table->proc_handler == proc_dointvec_jiffies) ||
+			    (table->proc_handler == proc_dointvec_userhz_jiffies) ||
+			    (table->proc_handler == proc_dointvec_ms_jiffies) ||
+			    (table->proc_handler == proc_doulongvec_minmax) ||
+			    (table->proc_handler == proc_doulongvec_ms_jiffies_minmax)) {
+				if (!table->data)
+					set_fail(&fail, table, "No data");
+				if (!table->maxlen)
+					set_fail(&fail, table, "No maxlen");
+			}
+#ifdef CONFIG_PROC_SYSCTL
+			if (!table->proc_handler)
+				set_fail(&fail, table, "No proc_handler");
+#endif
+			sysctl_check_leaf(namespaces, table, &fail);
+		}
+		if (table->mode > 0777)
+			set_fail(&fail, table, "bogus .mode");
+		if (fail) {
+			set_fail(&fail, table, NULL);
+			error = -EINVAL;
+		}
+		if (table->child)
+			error |= sysctl_check_table(namespaces, table->child);
+	}
+	return error;
+}
+#endif /* CONFIG_SYSCTL_SYSCALL_CHECK */
+
+/**
+ * __register_sysctl_paths - register a sysctl hierarchy
+ * @root: List of sysctl headers to register on
+ * @namespaces: Data to compute which lists of sysctl entries are visible
+ * @path: The path to the directory the sysctl table is in.
+ * @table: the top-level table structure
+ *
+ * Register a sysctl table hierarchy. @table should be a filled in ctl_table
+ * array. A completely 0 filled entry terminates the table.
+ *
+ * The members of the &struct ctl_table structure are used as follows:
+ *
+ * procname - the name of the sysctl file under /proc/sys. Set to %NULL to not
+ *            enter a sysctl file
+ *
+ * data - a pointer to data for use by proc_handler
+ *
+ * maxlen - the maximum size in bytes of the data
+ *
+ * mode - the file permissions for the /proc/sys file, and for sysctl(2)
+ *
+ * child - a pointer to the child sysctl table if this entry is a directory, or
+ *         %NULL.
+ *
+ * proc_handler - the text handler routine (described below)
+ *
+ * de - for internal use by the sysctl routines
+ *
+ * extra1, extra2 - extra pointers usable by the proc handler routines
+ *
+ * Leaf nodes in the sysctl tree will be represented by a single file
+ * under /proc; non-leaf nodes will be represented by directories.
+ *
+ * sysctl(2) can automatically manage read and write requests through
+ * the sysctl table.  The data and maxlen fields of the ctl_table
+ * struct enable minimal validation of the values being written to be
+ * performed, and the mode field allows minimal authentication.
+ *
+ * There must be a proc_handler routine for any terminal nodes
+ * mirrored under /proc/sys (non-terminals are handled by a built-in
+ * directory handler).  Several default handlers are available to
+ * cover common cases -
+ *
+ * proc_dostring(), proc_dointvec(), proc_dointvec_jiffies(),
+ * proc_dointvec_userhz_jiffies(), proc_dointvec_minmax(),
+ * proc_doulongvec_ms_jiffies_minmax(), proc_doulongvec_minmax()
+ *
+ * It is the handler's job to read the input buffer from user memory
+ * and process it. The handler should return 0 on success.
+ *
+ * This routine returns %NULL on a failure to register, and a pointer
+ * to the table header on success.
+ */
+struct ctl_table_header *__register_sysctl_paths(
+	struct ctl_table_root *root,
+	struct nsproxy *namespaces,
+	const struct ctl_path *path, struct ctl_table *table)
+{
+	struct ctl_table_header *header;
+	struct ctl_table *new, **prevp;
+	unsigned int n, npath;
+	struct ctl_table_set *set;
+
+	/* Count the path components */
+	for (npath = 0; path[npath].procname; ++npath)
+		;
+
+	/*
+	 * For each path component, allocate a 2-element ctl_table array.
+	 * The first array element will be filled with the sysctl entry
+	 * for this, the second will be the sentinel (procname == 0).
+	 *
+	 * We allocate everything in one go so that we don't have to
+	 * worry about freeing additional memory in unregister_sysctl_table.
+	 */
+	header = kzalloc(sizeof(struct ctl_table_header) +
+			 (2 * npath * sizeof(struct ctl_table)), GFP_KERNEL);
+	if (!header)
+		return NULL;
+
+	new = (struct ctl_table *) (header + 1);
+
+	/* Now connect the dots */
+	prevp = &header->ctl_table;
+	for (n = 0; n < npath; ++n, ++path) {
+		/* Copy the procname */
+		new->procname = path->procname;
+		new->mode     = 0555;
+
+		*prevp = new;
+		prevp = &new->child;
+
+		new += 2;
+	}
+	*prevp = table;
+	header->ctl_table_arg = table;
+
+	INIT_LIST_HEAD(&header->ctl_entry);
+	header->used = 0;
+	header->unregistering = NULL;
+	header->root = root;
+	sysctl_set_parent(NULL, header->ctl_table);
+	header->count = 1;
+#ifdef CONFIG_SYSCTL_SYSCALL_CHECK
+	if (sysctl_check_table(namespaces, header->ctl_table)) {
+		kfree(header);
+		return NULL;
+	}
+#endif
+	spin_lock(&sysctl_lock);
+	header->set = lookup_header_set(root, namespaces);
+	header->attached_by = header->ctl_table;
+	header->attached_to = root_table;
+	header->parent = &root_table_header;
+	for (set = header->set; set; set = set->parent) {
+		struct ctl_table_header *p;
+		list_for_each_entry(p, &set->list, ctl_entry) {
+			if (p->unregistering)
+				continue;
+			try_attach(p, header);
+		}
+	}
+	header->parent->count++;
+	list_add_tail(&header->ctl_entry, &header->set->list);
+	spin_unlock(&sysctl_lock);
+
+	return header;
+}
+
+/**
+ * register_sysctl_table_path - register a sysctl table hierarchy
+ * @path: The path to the directory the sysctl table is in.
+ * @table: the top-level table structure
+ *
+ * Register a sysctl table hierarchy. @table should be a filled in ctl_table
+ * array. A completely 0 filled entry terminates the table.
+ *
+ * See __register_sysctl_paths for more details.
+ */
+struct ctl_table_header *register_sysctl_paths(const struct ctl_path *path,
+						struct ctl_table *table)
+{
+	return __register_sysctl_paths(&sysctl_table_root, current->nsproxy,
+					path, table);
+}
+EXPORT_SYMBOL(register_sysctl_paths);
+
+/**
+ * register_sysctl_table - register a sysctl table hierarchy
+ * @table: the top-level table structure
+ *
+ * Register a sysctl table hierarchy. @table should be a filled in ctl_table
+ * array. A completely 0 filled entry terminates the table.
+ *
+ * See register_sysctl_paths for more details.
+ */
+struct ctl_table_header *register_sysctl_table(struct ctl_table *table)
+{
+	static const struct ctl_path null_path[] = { {} };
+
+	return register_sysctl_paths(null_path, table);
+}
+EXPORT_SYMBOL(register_sysctl_table);
+
+/**
+ * unregister_sysctl_table - unregister a sysctl table hierarchy
+ * @header: the header returned from register_sysctl_table
+ *
+ * Unregisters the sysctl table and all children. proc entries may not
+ * actually be removed until they are no longer used by anyone.
+ */
+void unregister_sysctl_table(struct ctl_table_header * header)
+{
+	might_sleep();
+
+	if (header == NULL)
+		return;
+
+	spin_lock(&sysctl_lock);
+	start_unregistering(header);
+	if (!--header->parent->count) {
+		WARN_ON(1);
+		kfree_rcu(header->parent, rcu);
+	}
+	if (!--header->count)
+		kfree_rcu(header, rcu);
+	spin_unlock(&sysctl_lock);
+}
+EXPORT_SYMBOL(unregister_sysctl_table);
+
+void setup_sysctl_set(struct ctl_table_set *p,
+	struct ctl_table_set *parent,
+	int (*is_seen)(struct ctl_table_set *))
+{
+	INIT_LIST_HEAD(&p->list);
+	p->parent = parent ? parent : &sysctl_table_root.default_set;
+	p->is_seen = is_seen;
+}
+
+
 int __init proc_sys_init(void)
 {
 	struct proc_dir_entry *proc_sys_root;
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 5e3532e..08cabbf 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -1073,17 +1073,6 @@ extern void setup_sysctl_set(struct ctl_table_set *p,
 	struct ctl_table_set *parent,
 	int (*is_seen)(struct ctl_table_set *));
 
-extern void sysctl_head_get(struct ctl_table_header *);
-extern void sysctl_head_put(struct ctl_table_header *);
-extern int sysctl_is_seen(struct ctl_table_header *);
-extern struct ctl_table_header *sysctl_head_grab(struct ctl_table_header *);
-extern struct ctl_table_header *sysctl_head_next(struct ctl_table_header *prev);
-extern struct ctl_table_header *__sysctl_head_next(struct nsproxy *namespaces,
-						struct ctl_table_header *prev);
-extern void sysctl_head_finish(struct ctl_table_header *prev);
-extern int sysctl_perm(struct ctl_table_root *root,
-		struct ctl_table *table, int op);
-
 void register_sysctl_root(struct ctl_table_root *root);
 struct ctl_table_header *__register_sysctl_paths(
 	struct ctl_table_root *root, struct nsproxy *namespaces,
@@ -1093,7 +1082,6 @@ struct ctl_table_header *register_sysctl_paths(const struct ctl_path *path,
 						struct ctl_table *table);
 
 void unregister_sysctl_table(struct ctl_table_header * table);
-int sysctl_check_table(struct nsproxy *namespaces, struct ctl_table *table);
 
 extern int sysctl_init(void);
 #else /* CONFIG_SYSCTL */
@@ -1118,10 +1106,6 @@ static inline void setup_sysctl_set(struct ctl_table_set *p,
 {
 }
 
-static inline void sysctl_head_put(struct ctl_table_header *head)
-{
-}
-
 #endif /* CONFIG_SYSCTL */
 
 #endif /* __KERNEL__ */
diff --git a/kernel/Makefile b/kernel/Makefile
index 2d9de86..cb41b95 100644
--- a/kernel/Makefile
+++ b/kernel/Makefile
@@ -27,7 +27,6 @@ obj-y += power/
 
 obj-$(CONFIG_FREEZER) += freezer.o
 obj-$(CONFIG_PROFILING) += profile.o
-obj-$(CONFIG_SYSCTL_SYSCALL_CHECK) += sysctl_check.o
 obj-$(CONFIG_STACKTRACE) += stacktrace.o
 obj-y += time/
 obj-$(CONFIG_DEBUG_MUTEXES) += mutex-debug.o
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index ad46024..b774909 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -192,20 +192,6 @@ static int sysrq_sysctl_handler(ctl_table *table, int write,
 
 #endif
 
-static struct ctl_table root_table[1];
-static struct ctl_table_root sysctl_table_root;
-static struct ctl_table_header root_table_header = {
-	{{.count = 1,
-	.ctl_table = root_table,
-	.ctl_entry = LIST_HEAD_INIT(sysctl_table_root.default_set.list),}},
-	.root = &sysctl_table_root,
-	.set = &sysctl_table_root.default_set,
-};
-static struct ctl_table_root sysctl_table_root = {
-	.root_list = LIST_HEAD_INIT(sysctl_table_root.root_list),
-	.default_set.list = LIST_HEAD_INIT(root_table_header.ctl_entry),
-};
-
 static struct ctl_table kern_table[];
 static struct ctl_table vm_table[];
 static struct ctl_table fs_table[];
@@ -1559,459 +1545,12 @@ static struct ctl_table dev_table[] = {
 	{ }
 };
 
-static DEFINE_SPINLOCK(sysctl_lock);
-
-/* called under sysctl_lock */
-static int use_table(struct ctl_table_header *p)
-{
-	if (unlikely(p->unregistering))
-		return 0;
-	p->used++;
-	return 1;
-}
-
-/* called under sysctl_lock */
-static void unuse_table(struct ctl_table_header *p)
-{
-	if (!--p->used)
-		if (unlikely(p->unregistering))
-			complete(p->unregistering);
-}
-
-/* called under sysctl_lock, will reacquire if has to wait */
-static void start_unregistering(struct ctl_table_header *p)
-{
-	/*
-	 * if p->used is 0, nobody will ever touch that entry again;
-	 * we'll eliminate all paths to it before dropping sysctl_lock
-	 */
-	if (unlikely(p->used)) {
-		struct completion wait;
-		init_completion(&wait);
-		p->unregistering = &wait;
-		spin_unlock(&sysctl_lock);
-		wait_for_completion(&wait);
-		spin_lock(&sysctl_lock);
-	} else {
-		/* anything non-NULL; we'll never dereference it */
-		p->unregistering = ERR_PTR(-EINVAL);
-	}
-	/*
-	 * do not remove from the list until nobody holds it; walking the
-	 * list in do_sysctl() relies on that.
-	 */
-	list_del_init(&p->ctl_entry);
-}
-
-void sysctl_head_get(struct ctl_table_header *head)
-{
-	spin_lock(&sysctl_lock);
-	head->count++;
-	spin_unlock(&sysctl_lock);
-}
-
-void sysctl_head_put(struct ctl_table_header *head)
-{
-	spin_lock(&sysctl_lock);
-	if (!--head->count)
-		kfree_rcu(head, rcu);
-	spin_unlock(&sysctl_lock);
-}
-
-struct ctl_table_header *sysctl_head_grab(struct ctl_table_header *head)
-{
-	if (!head)
-		BUG();
-	spin_lock(&sysctl_lock);
-	if (!use_table(head))
-		head = ERR_PTR(-ENOENT);
-	spin_unlock(&sysctl_lock);
-	return head;
-}
-
-void sysctl_head_finish(struct ctl_table_header *head)
-{
-	if (!head)
-		return;
-	spin_lock(&sysctl_lock);
-	unuse_table(head);
-	spin_unlock(&sysctl_lock);
-}
-
-static struct ctl_table_set *
-lookup_header_set(struct ctl_table_root *root, struct nsproxy *namespaces)
-{
-	struct ctl_table_set *set = &root->default_set;
-	if (root->lookup)
-		set = root->lookup(root, namespaces);
-	return set;
-}
-
-static struct list_head *
-lookup_header_list(struct ctl_table_root *root, struct nsproxy *namespaces)
-{
-	struct ctl_table_set *set = lookup_header_set(root, namespaces);
-	return &set->list;
-}
-
-struct ctl_table_header *__sysctl_head_next(struct nsproxy *namespaces,
-					    struct ctl_table_header *prev)
-{
-	struct ctl_table_root *root;
-	struct list_head *header_list;
-	struct ctl_table_header *head;
-	struct list_head *tmp;
-
-	spin_lock(&sysctl_lock);
-	if (prev) {
-		head = prev;
-		tmp = &prev->ctl_entry;
-		unuse_table(prev);
-		goto next;
-	}
-	tmp = &root_table_header.ctl_entry;
-	for (;;) {
-		head = list_entry(tmp, struct ctl_table_header, ctl_entry);
-
-		if (!use_table(head))
-			goto next;
-		spin_unlock(&sysctl_lock);
-		return head;
-	next:
-		root = head->root;
-		tmp = tmp->next;
-		header_list = lookup_header_list(root, namespaces);
-		if (tmp != header_list)
-			continue;
-
-		do {
-			root = list_entry(root->root_list.next,
-					struct ctl_table_root, root_list);
-			if (root == &sysctl_table_root)
-				goto out;
-			header_list = lookup_header_list(root, namespaces);
-		} while (list_empty(header_list));
-		tmp = header_list->next;
-	}
-out:
-	spin_unlock(&sysctl_lock);
-	return NULL;
-}
-
-struct ctl_table_header *sysctl_head_next(struct ctl_table_header *prev)
-{
-	return __sysctl_head_next(current->nsproxy, prev);
-}
-
-void register_sysctl_root(struct ctl_table_root *root)
-{
-	spin_lock(&sysctl_lock);
-	list_add_tail(&root->root_list, &sysctl_table_root.root_list);
-	spin_unlock(&sysctl_lock);
-}
-
-/*
- * sysctl_perm does NOT grant the superuser all rights automatically, because
- * some sysctl variables are readonly even to root.
- */
-
-static int test_perm(int mode, int op)
-{
-	if (!current_euid())
-		mode >>= 6;
-	else if (in_egroup_p(0))
-		mode >>= 3;
-	if ((op & ~mode & (MAY_READ|MAY_WRITE|MAY_EXEC)) == 0)
-		return 0;
-	return -EACCES;
-}
-
-int sysctl_perm(struct ctl_table_root *root, struct ctl_table *table, int op)
-{
-	int mode;
-
-	if (root->permissions)
-		mode = root->permissions(root, current->nsproxy, table);
-	else
-		mode = table->mode;
-
-	return test_perm(mode, op);
-}
-
-static void sysctl_set_parent(struct ctl_table *parent, struct ctl_table *table)
-{
-	for (; table->procname; table++) {
-		table->parent = parent;
-		if (table->child)
-			sysctl_set_parent(table, table->child);
-	}
-}
-
 int __init sysctl_init(void)
 {
 	register_sysctl_table(sysctl_base_table);
 	return 0;
 }
 
-static struct ctl_table *is_branch_in(struct ctl_table *branch,
-				      struct ctl_table *table)
-{
-	struct ctl_table *p;
-	const char *s = branch->procname;
-
-	/* branch should have named subdirectory as its first element */
-	if (!s || !branch->child)
-		return NULL;
-
-	/* ... and nothing else */
-	if (branch[1].procname)
-		return NULL;
-
-	/* table should contain subdirectory with the same name */
-	for (p = table; p->procname; p++) {
-		if (!p->child)
-			continue;
-		if (p->procname && strcmp(p->procname, s) == 0)
-			return p;
-	}
-	return NULL;
-}
-
-/* see if attaching q to p would be an improvement */
-static void try_attach(struct ctl_table_header *p, struct ctl_table_header *q)
-{
-	struct ctl_table *to = p->ctl_table, *by = q->ctl_table;
-	struct ctl_table *next;
-	int is_better = 0;
-	int not_in_parent = !p->attached_by;
-
-	while ((next = is_branch_in(by, to)) != NULL) {
-		if (by == q->attached_by)
-			is_better = 1;
-		if (to == p->attached_by)
-			not_in_parent = 1;
-		by = by->child;
-		to = next->child;
-	}
-
-	if (is_better && not_in_parent) {
-		q->attached_by = by;
-		q->attached_to = to;
-		q->parent = p;
-	}
-}
-
-/**
- * __register_sysctl_paths - register a sysctl hierarchy
- * @root: List of sysctl headers to register on
- * @namespaces: Data to compute which lists of sysctl entries are visible
- * @path: The path to the directory the sysctl table is in.
- * @table: the top-level table structure
- *
- * Register a sysctl table hierarchy. @table should be a filled in ctl_table
- * array. A completely 0 filled entry terminates the table.
- *
- * The members of the &struct ctl_table structure are used as follows:
- *
- * procname - the name of the sysctl file under /proc/sys. Set to %NULL to not
- *            enter a sysctl file
- *
- * data - a pointer to data for use by proc_handler
- *
- * maxlen - the maximum size in bytes of the data
- *
- * mode - the file permissions for the /proc/sys file, and for sysctl(2)
- *
- * child - a pointer to the child sysctl table if this entry is a directory, or
- *         %NULL.
- *
- * proc_handler - the text handler routine (described below)
- *
- * de - for internal use by the sysctl routines
- *
- * extra1, extra2 - extra pointers usable by the proc handler routines
- *
- * Leaf nodes in the sysctl tree will be represented by a single file
- * under /proc; non-leaf nodes will be represented by directories.
- *
- * sysctl(2) can automatically manage read and write requests through
- * the sysctl table.  The data and maxlen fields of the ctl_table
- * struct enable minimal validation of the values being written to be
- * performed, and the mode field allows minimal authentication.
- *
- * There must be a proc_handler routine for any terminal nodes
- * mirrored under /proc/sys (non-terminals are handled by a built-in
- * directory handler).  Several default handlers are available to
- * cover common cases -
- *
- * proc_dostring(), proc_dointvec(), proc_dointvec_jiffies(),
- * proc_dointvec_userhz_jiffies(), proc_dointvec_minmax(), 
- * proc_doulongvec_ms_jiffies_minmax(), proc_doulongvec_minmax()
- *
- * It is the handler's job to read the input buffer from user memory
- * and process it. The handler should return 0 on success.
- *
- * This routine returns %NULL on a failure to register, and a pointer
- * to the table header on success.
- */
-struct ctl_table_header *__register_sysctl_paths(
-	struct ctl_table_root *root,
-	struct nsproxy *namespaces,
-	const struct ctl_path *path, struct ctl_table *table)
-{
-	struct ctl_table_header *header;
-	struct ctl_table *new, **prevp;
-	unsigned int n, npath;
-	struct ctl_table_set *set;
-
-	/* Count the path components */
-	for (npath = 0; path[npath].procname; ++npath)
-		;
-
-	/*
-	 * For each path component, allocate a 2-element ctl_table array.
-	 * The first array element will be filled with the sysctl entry
-	 * for this, the second will be the sentinel (procname == 0).
-	 *
-	 * We allocate everything in one go so that we don't have to
-	 * worry about freeing additional memory in unregister_sysctl_table.
-	 */
-	header = kzalloc(sizeof(struct ctl_table_header) +
-			 (2 * npath * sizeof(struct ctl_table)), GFP_KERNEL);
-	if (!header)
-		return NULL;
-
-	new = (struct ctl_table *) (header + 1);
-
-	/* Now connect the dots */
-	prevp = &header->ctl_table;
-	for (n = 0; n < npath; ++n, ++path) {
-		/* Copy the procname */
-		new->procname = path->procname;
-		new->mode     = 0555;
-
-		*prevp = new;
-		prevp = &new->child;
-
-		new += 2;
-	}
-	*prevp = table;
-	header->ctl_table_arg = table;
-
-	INIT_LIST_HEAD(&header->ctl_entry);
-	header->used = 0;
-	header->unregistering = NULL;
-	header->root = root;
-	sysctl_set_parent(NULL, header->ctl_table);
-	header->count = 1;
-#ifdef CONFIG_SYSCTL_SYSCALL_CHECK
-	if (sysctl_check_table(namespaces, header->ctl_table)) {
-		kfree(header);
-		return NULL;
-	}
-#endif
-	spin_lock(&sysctl_lock);
-	header->set = lookup_header_set(root, namespaces);
-	header->attached_by = header->ctl_table;
-	header->attached_to = root_table;
-	header->parent = &root_table_header;
-	for (set = header->set; set; set = set->parent) {
-		struct ctl_table_header *p;
-		list_for_each_entry(p, &set->list, ctl_entry) {
-			if (p->unregistering)
-				continue;
-			try_attach(p, header);
-		}
-	}
-	header->parent->count++;
-	list_add_tail(&header->ctl_entry, &header->set->list);
-	spin_unlock(&sysctl_lock);
-
-	return header;
-}
-
-/**
- * register_sysctl_table_path - register a sysctl table hierarchy
- * @path: The path to the directory the sysctl table is in.
- * @table: the top-level table structure
- *
- * Register a sysctl table hierarchy. @table should be a filled in ctl_table
- * array. A completely 0 filled entry terminates the table.
- *
- * See __register_sysctl_paths for more details.
- */
-struct ctl_table_header *register_sysctl_paths(const struct ctl_path *path,
-						struct ctl_table *table)
-{
-	return __register_sysctl_paths(&sysctl_table_root, current->nsproxy,
-					path, table);
-}
-
-/**
- * register_sysctl_table - register a sysctl table hierarchy
- * @table: the top-level table structure
- *
- * Register a sysctl table hierarchy. @table should be a filled in ctl_table
- * array. A completely 0 filled entry terminates the table.
- *
- * See register_sysctl_paths for more details.
- */
-struct ctl_table_header *register_sysctl_table(struct ctl_table *table)
-{
-	static const struct ctl_path null_path[] = { {} };
-
-	return register_sysctl_paths(null_path, table);
-}
-
-/**
- * unregister_sysctl_table - unregister a sysctl table hierarchy
- * @header: the header returned from register_sysctl_table
- *
- * Unregisters the sysctl table and all children. proc entries may not
- * actually be removed until they are no longer used by anyone.
- */
-void unregister_sysctl_table(struct ctl_table_header * header)
-{
-	might_sleep();
-
-	if (header == NULL)
-		return;
-
-	spin_lock(&sysctl_lock);
-	start_unregistering(header);
-	if (!--header->parent->count) {
-		WARN_ON(1);
-		kfree_rcu(header->parent, rcu);
-	}
-	if (!--header->count)
-		kfree_rcu(header, rcu);
-	spin_unlock(&sysctl_lock);
-}
-
-int sysctl_is_seen(struct ctl_table_header *p)
-{
-	struct ctl_table_set *set = p->set;
-	int res;
-	spin_lock(&sysctl_lock);
-	if (p->unregistering)
-		res = 0;
-	else if (!set->is_seen)
-		res = 1;
-	else
-		res = set->is_seen(set);
-	spin_unlock(&sysctl_lock);
-	return res;
-}
-
-void setup_sysctl_set(struct ctl_table_set *p,
-	struct ctl_table_set *parent,
-	int (*is_seen)(struct ctl_table_set *))
-{
-	INIT_LIST_HEAD(&p->list);
-	p->parent = parent ? parent : &sysctl_table_root.default_set;
-	p->is_seen = is_seen;
-}
-
 #endif /* CONFIG_SYSCTL */
 
 /*
@@ -2977,6 +2516,3 @@ EXPORT_SYMBOL(proc_dointvec_ms_jiffies);
 EXPORT_SYMBOL(proc_dostring);
 EXPORT_SYMBOL(proc_doulongvec_minmax);
 EXPORT_SYMBOL(proc_doulongvec_ms_jiffies_minmax);
-EXPORT_SYMBOL(register_sysctl_table);
-EXPORT_SYMBOL(register_sysctl_paths);
-EXPORT_SYMBOL(unregister_sysctl_table);
diff --git a/kernel/sysctl_check.c b/kernel/sysctl_check.c
deleted file mode 100644
index 362da65..0000000
--- a/kernel/sysctl_check.c
+++ /dev/null
@@ -1,160 +0,0 @@
-#include <linux/stat.h>
-#include <linux/sysctl.h>
-#include "../fs/xfs/xfs_sysctl.h"
-#include <linux/sunrpc/debug.h>
-#include <linux/string.h>
-#include <net/ip_vs.h>
-
-
-static int sysctl_depth(struct ctl_table *table)
-{
-	struct ctl_table *tmp;
-	int depth;
-
-	depth = 0;
-	for (tmp = table; tmp->parent; tmp = tmp->parent)
-		depth++;
-
-	return depth;
-}
-
-static struct ctl_table *sysctl_parent(struct ctl_table *table, int n)
-{
-	int i;
-
-	for (i = 0; table && i < n; i++)
-		table = table->parent;
-
-	return table;
-}
-
-
-static void sysctl_print_path(struct ctl_table *table)
-{
-	struct ctl_table *tmp;
-	int depth, i;
-	depth = sysctl_depth(table);
-	if (table->procname) {
-		for (i = depth; i >= 0; i--) {
-			tmp = sysctl_parent(table, i);
-			printk("/%s", tmp->procname?tmp->procname:"");
-		}
-	}
-	printk(" ");
-}
-
-static struct ctl_table *sysctl_check_lookup(struct nsproxy *namespaces,
-						struct ctl_table *table)
-{
-	struct ctl_table_header *head;
-	struct ctl_table *ref, *test;
-	int depth, cur_depth;
-
-	depth = sysctl_depth(table);
-
-	for (head = __sysctl_head_next(namespaces, NULL); head;
-	     head = __sysctl_head_next(namespaces, head)) {
-		cur_depth = depth;
-		ref = head->ctl_table;
-repeat:
-		test = sysctl_parent(table, cur_depth);
-		for (; ref->procname; ref++) {
-			int match = 0;
-			if (cur_depth && !ref->child)
-				continue;
-
-			if (test->procname && ref->procname &&
-			    (strcmp(test->procname, ref->procname) == 0))
-					match++;
-
-			if (match) {
-				if (cur_depth != 0) {
-					cur_depth--;
-					ref = ref->child;
-					goto repeat;
-				}
-				goto out;
-			}
-		}
-	}
-	ref = NULL;
-out:
-	sysctl_head_finish(head);
-	return ref;
-}
-
-static void set_fail(const char **fail, struct ctl_table *table, const char *str)
-{
-	if (*fail) {
-		printk(KERN_ERR "sysctl table check failed: ");
-		sysctl_print_path(table);
-		printk(" %s\n", *fail);
-		dump_stack();
-	}
-	*fail = str;
-}
-
-static void sysctl_check_leaf(struct nsproxy *namespaces,
-				struct ctl_table *table, const char **fail)
-{
-	struct ctl_table *ref;
-
-	ref = sysctl_check_lookup(namespaces, table);
-	if (ref && (ref != table))
-		set_fail(fail, table, "Sysctl already exists");
-}
-
-int sysctl_check_table(struct nsproxy *namespaces, struct ctl_table *table)
-{
-	int error = 0;
-	for (; table->procname; table++) {
-		const char *fail = NULL;
-
-		if (table->parent) {
-			if (!table->parent->procname)
-				set_fail(&fail, table, "Parent without procname");
-		}
-		if (table->child) {
-			if (table->data)
-				set_fail(&fail, table, "Directory with data?");
-			if (table->maxlen)
-				set_fail(&fail, table, "Directory with maxlen?");
-			if ((table->mode & (S_IRUGO|S_IXUGO)) != table->mode)
-				set_fail(&fail, table, "Writable sysctl directory");
-			if (table->proc_handler)
-				set_fail(&fail, table, "Directory with proc_handler");
-			if (table->extra1)
-				set_fail(&fail, table, "Directory with extra1");
-			if (table->extra2)
-				set_fail(&fail, table, "Directory with extra2");
-		} else {
-			if ((table->proc_handler == proc_dostring) ||
-			    (table->proc_handler == proc_dointvec) ||
-			    (table->proc_handler == proc_dointvec_minmax) ||
-			    (table->proc_handler == proc_dointvec_jiffies) ||
-			    (table->proc_handler == proc_dointvec_userhz_jiffies) ||
-			    (table->proc_handler == proc_dointvec_ms_jiffies) ||
-			    (table->proc_handler == proc_doulongvec_minmax) ||
-			    (table->proc_handler == proc_doulongvec_ms_jiffies_minmax)) {
-				if (!table->data)
-					set_fail(&fail, table, "No data");
-				if (!table->maxlen)
-					set_fail(&fail, table, "No maxlen");
-			}
-#ifdef CONFIG_PROC_SYSCTL
-			if (!table->proc_handler)
-				set_fail(&fail, table, "No proc_handler");
-#endif
-			sysctl_check_leaf(namespaces, table, &fail);
-		}
-		if (table->mode > 0777)
-			set_fail(&fail, table, "bogus .mode");
-		if (fail) {
-			set_fail(&fail, table, NULL);
-			error = -EINVAL;
-		}
-		if (table->child)
-			error |= sysctl_check_table(namespaces, table->child);
-	}
-	return error;
-}
-- 
1.7.2.5
