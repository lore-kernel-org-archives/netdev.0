From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 076/115] sysctl: faster tree-based sysctl implementation
Date: Mon,  9 May 2011 00:39:28 +0200
Message-ID: <1304894407-32201-77-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:47346 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932544Ab1EHWmA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:42:00 -0400
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The old implementation used inefficient algorithms both at
lookup/readdir times and at registration. This patch introduces an
improved algorithm: lower memory consumption, better time complexity
for lookup/readdir/registration. Locking is a bit heavier in this
algorithm (in this patch: reader locks for lookup/readdir, writer
locks for register/unregister; in a later patch in this series: RCU +
spin-lock). I'll address this locking issue later in this commit.

I will shortly describe the previous algorithm, the new one and brag
at the end with an endless list of improvements and new limitations.

= Old algorithm =

== Description ==
We created a ctl_table_header for each registered sysctl table. The
header's role is to maintain sysctl internal data, reference counting
and as a token to unregister the table.

All headers were put in a list in the order of registration without
regard to the position of the tables in the sysctl tree. Headers were
also 'attached' one to another to (somewhat) speed up lookup/readdir.

Attachment meant looking at each other already registered header and
comparing the paths to the tables. A newly registered header would be
attached to the first header with which it would share most of it's
path.

e.g. paths registered: /, /a/b/c, /a/b/c/d, /a/x, /a/x/y, /a/z
     tree:
  /
  + /a/b/c
     |   + /a/b/c/d
     + /a/x
     | /a/x/y
     + /a/z

== Time complexity ==

- register N tables would take O(N^2) steps (see above)

- lookup: if the item searched for is not found in the current header,
  iterate the list of headers until you find another header that's
  attached to the current position in the header's table. Lookups for
  elements that are in a header registered under the current position
  or inexistent elements would take O(N) steps each.

- readdir: after searching the current headers table in the current
  position, always do an O(N) search for a header attached to the
  current table position.

== Memory ==

Each header was allocated some data and a variable-length path.
O(1) with kzalloc/kfree.

= New algorithm =

== Description ==

Reuses the 'ctl_table_header' concept but with two distinct meanings:
- as a wrapper of a table registered by the user
- as a directory entry.

Registering the paths from the above example gives this tree:
 paths: /, /a/b/c, /a/b/c/d, /a/x, /a/x/y, /a/z
 tree:
     /: .subdirs = a
       a: .subdirs = b x z
         b: subdirs = c
            c: subdirs = d
	      d:
         x: subdirs = y
	   y:
         z:

Each directory gets a header. Each header has a parent (except root)
and two lists:
 - ctl_subdirs: list of sub-directories - other headers
 - ctl_tables: list of headers that wrap a ctl_table array

Because the directory structure is now maintained as ctl_table_header
objects, we needed to remove the .child from ctl_tables (this explains
the previous patches). A ctl_table array represents a list of files.

== Time complexity ==

- registration of N headers. Registration means adding new directories
  at each level or incrementing an existing directory's refcount.

  - O(N * lnN) - if the paths to the headers are evenly distributed

  - O(N^2) - if most of the headers registered are children of the
    same parent directory (searching the list of subdirs takes O(N)).
    There are cases where this happens (e.g. registering sysctl
    entries for net devices under /proc/sys/net/ipv4|6/conf/device).

    A few later patches will add an optimisation, to fix locations
    that might trigger the O(N^2) issue.

- lookup: O(len(subdirs) + sum(len(tarr) for each tarr in ctl_tables)
  - could be made better:
     - sort ctl_subdirs (for binary search)
     - replace ctl_subdirs with a hash-table (increase memory footprint)
     - sort ctl_table entries at registration time (for binary search).
    Could be done, but I'm too lazy to do it now.

- readdir: O(len(subdirs) + sum(len(tarr) for each tarr in ctl_tables)
   - can't get any better than this :)

== Memory complexity ==

Although we create more ctl_table_header (one for each directory, one
for each table, and because we deleted the .child from ctl_table there
are more tables registered than before this patch) we remove the need
to store a full path (from too to the table) as was done in the old
solution => a O(N) small memory gain with report to the old algo.

= Limitations =

== ctl_table does not has .child => some code uglyfication  ==

Registering tables with multiple directories and files cannot be done
in a single operation: there must be at least a table registered for
each directory. This make code that registers sysctls uglier (see the
earlier patches that remove .child form sched_domain and the root
table). Other places e.g. the parport systls look much better now
without .child: I can now read and understand that code.

== Handling of netns specific paths is weirder ==

The algorithm descriptions from above are simplifications. In reality
the code needs to handle directories and files that must be visible in
some netns' only. E.g. the /proc/sys/net/ipv4/conf/DEVICENAME/
directory and it's files must be visible only in the netns of that
device.

The old algorithm used a secondary list that indexed all netns
specific headers. All algorithms remain the same, with the mention
that besides searching the global list, the algorithm would also look
into the current netns' list of headers. This scales perfectly in
rapport to the number of network namespaces.

The new algorithm does something similar, but a bit more complicated.
We also use netns specific lists of directories/tables and store them
in a special directory ctl_table_header (which I dubbed the
"netns-correspondent" of another directory - I'm not very pleased with
the name either).

When registering a net-ns specific table, we will create a
"netns-correspondent" to the last directory that is not net-ns
specific in that path.

E.g.: we're registering a netns specific table for 'lo':
      common path: /proc/sys/net/ipv4/
       netns path: /proc/sys/net/ipv4/conf/lo/

   We'll create an (unnamed) netns correspondent for 'ipv4' which will
   have 'conf' as it's subdir.

E.g.: We're registering a netns specific file in /proc/sys/net/core/somaxconn
      common path: /proc/sys/net/core/
       netns path: /proc/sys/net/core/

We'll create an (unnamed) netns correspondent for 'core' with the
table containing 'somaxconn' in ctl_tables.

All net-ns correspondents of one netns are held in a single list, and
each netns gets it own list. This keeps the algorithm complexity
indifferent of the number of network namespaces (as was the old one).

However, now only a smaller part of directories are members of this
list, improving register/lookup/readdir time complexity.

There is one ugly limitation that stems from this approach.
E.g.: register these files in this order:
 - register common         /dir1/file-common1
 - register netns specific /dir1/dir2/file-netns
 - register common         /dir1/dir2/file-common2

  We'll have this tree:
   'dir1' { .subdirs = ['dir2'], .tables = ['file-common1'] }
     ^                    |
     |                    -> { .subdirs = [], .tables = ['file-common2'] }
     |
     | (unnamed netns-corresp for dir1)
     -> { .subdir = ['dir2'] }
                        |
                        -> { .subdirs = [], .tables = ['file-netns'] }

readdir: when we list the contents of 'dir1' we'll see it has two
         sub-directories named 'dir2' each with a file in it.

lookup: lookup of /dir1/dir2/file-netns will not work because we find
        'dir2' as a subdir of 'dir1' and stick with it and never look
        into the netns correspondent of 'dir1'.

This can be fixed in two ways:

- A) by making sure to never register a netns specific directory and
  after that register that directory as a common one. From what I can
  tell there isn't such a problem in the kernel at the moment, but I
  did not study the source in detail.

- B) by increasing the complexity of the code:

  - readdir: looking at both lists and comparing if we have already
             listed a directory as common, so we don't list twice.
             -> For imbalanced trees this can make readdir O(N^2) :(

  - register: the netns 'dir2' from the example above needs to be
              connected to the common 'dir2' when 'dir2' is
              registered. I'm not even going to thing of how time
              complexity/ugliness is going to explode here.

= Change summary =

* include/linux/sysctl.h
  - removed _set and _root, replaced with _group

  - netns correspondent directories are held in each netns's
    group->corresp_list

  - reused the header structure to represent directories which don't
    use ctl_table_arg, but store the directory name directly.

  - each directory header also gets two lists: subdirs and tables

* fs/proc/proc_sysctl.c
  - a proc inode has ->sysctl_entry set only for files, not
    directories as these store the dirname directly

  - lookup:
     - take the dirs read-lock and iterate through subdirs and tables
     - if nothing is found, try the dir's netns-correspondent

  - scan: list every subdir and file that was not listed before

  - readdir: scan the current dir and it's netns correspondent

* kernel/sysctl.c
  - inlines the code of use_table/unuse_table as it is not used
    elsewhere (used to be called from __register, but aren't any more)

  - adds routines to get/set the netns-correspondent

  - adds routines to protect the subdirs/tables lists (rwsem)

  - __register_sysctl_paths:
    - preallocate ctl_table_header for every dir in 'path'
    - increase the ctl_header_refs of every existing directory
    - if the group needs a netns-correspondent it is created for the
      last existing directory that is part of the non-netns specific
      path.
    - all the non-existing directories are added as children of their
      parent's subdir lists.

   - unregister:
     - wait until no one uses the header
     - for normal directories and table-wrapper headers take the
       parent's write lock to be able to delete something from one of
       it's lists (ctl_subdir or ctl_tables).
     - netns-correspondent headers must take the netns group list lock
       before deleting.

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 fs/proc/proc_sysctl.c       |  159 ++++++++-----
 include/linux/sysctl.h      |  120 +++++------
 include/net/net_namespace.h |    2 +-
 kernel/sysctl.c             |  533 ++++++++++++++++++++++++++----------------
 kernel/sysctl_check.c       |  168 +--------------
 net/sysctl_net.c            |   41 +---
 6 files changed, 499 insertions(+), 524 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index 375d145..9337149 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -32,13 +32,14 @@ static struct inode *proc_sys_make_inode(struct super_block *sb,
 	ei->sysctl_entry = table;
 
 	inode->i_mtime = inode->i_atime = inode->i_ctime = CURRENT_TIME;
-	inode->i_mode = table->mode;
-	if (!table->child) {
-		inode->i_mode |= S_IFREG;
+
+	/* directories have table==NULL (thus ei->sysctl_entry is NULL too) */
+	if (table) {
+		inode->i_mode = S_IFREG | table->mode;
 		inode->i_op = &proc_sys_inode_operations;
 		inode->i_fop = &proc_sys_file_operations;
 	} else {
-		inode->i_mode |= S_IFDIR;
+		inode->i_mode = S_IFDIR | S_IRUGO | S_IWUSR;
 		inode->i_nlink = 0;
 		inode->i_op = &proc_sys_dir_operations;
 		inode->i_fop = &proc_sys_dir_file_operations;
@@ -66,42 +67,65 @@ static struct dentry *proc_sys_lookup(struct inode *dir, struct dentry *dentry,
 					struct nameidata *nd)
 {
 	struct ctl_table_header *head = sysctl_use_header(PROC_I(dir)->sysctl);
-	struct ctl_table *table = PROC_I(dir)->sysctl_entry;
-	struct ctl_table_header *h = NULL;
 	struct qstr *name = &dentry->d_name;
-	struct ctl_table *p;
+	struct ctl_table_header *h = NULL, *found_head = NULL;
+	struct ctl_table *table = NULL;
 	struct inode *inode;
 	struct dentry *err = ERR_PTR(-ENOENT);
 
+
 	if (IS_ERR(head))
 		return ERR_CAST(head);
 
-	if (table && !table->child) {
-		WARN_ON(1);
-		goto out;
+retry:
+	sysctl_read_lock_head(head);
+
+	/* first check whether a subdirectory has the searched-for name */
+	list_for_each_entry(h, &head->ctl_subdirs, ctl_entry) {
+		if (IS_ERR(sysctl_use_header(h)))
+			continue;
+
+		if (strcmp(name->name, h->ctl_dirname) == 0) {
+			found_head = h;
+			goto search_finished;
+		}
+		sysctl_unuse_header(h);
 	}
 
-	table = table ? table->child : head->ctl_table;
+	/* no subdir with that name, look for the file in the ctl_tables */
+	list_for_each_entry(h, &head->ctl_tables, ctl_entry) {
+		if (IS_ERR(sysctl_use_header(h)))
+			continue;
 
-	p = find_in_table(table, name);
-	if (!p) {
-		for (h = sysctl_use_next_header(NULL); h; h = sysctl_use_next_header(h)) {
-			if (h->attached_to != table)
-				continue;
-			p = find_in_table(h->attached_by, name);
-			if (p)
-				break;
+		table = find_in_table(h->ctl_table_arg, name);
+		if (table) {
+			found_head = h;
+			goto search_finished;
 		}
+		sysctl_unuse_header(h);
 	}
 
-	if (!p)
+search_finished:
+	sysctl_read_unlock_head(head);
+
+	if (!found_head) {
+		struct ctl_table_header *netns_corresp;
+		/* the item was not found in the dir's sub-directories
+		 * or tables. See if this dir has a netns
+		 * correspondent and restart the lookup in there. */
+		netns_corresp = sysctl_use_netns_corresp(head);
+		if (netns_corresp) {
+			sysctl_unuse_header(head);
+			head = netns_corresp;
+			goto retry;
+		}
+	}
+	if (!found_head)
 		goto out;
 
 	err = ERR_PTR(-ENOMEM);
-	inode = proc_sys_make_inode(dir->i_sb, h ? h : head, p);
-	if (h)
-		sysctl_unuse_header(h);
-
+	inode = proc_sys_make_inode(dir->i_sb, found_head, table);
+	sysctl_unuse_header(found_head);
 	if (!inode)
 		goto out;
 
@@ -174,8 +198,8 @@ static int proc_sys_fill_cache(struct file *filp, void *dirent,
 	ino_t ino = 0;
 	unsigned type = DT_UNKNOWN;
 
-	qname.name = table->procname;
-	qname.len  = strlen(table->procname);
+	qname.name = table ? table->procname : head->ctl_dirname;
+	qname.len  = strlen(qname.name);
 	qname.hash = full_name_hash(qname.name, qname.len);
 
 	child = d_lookup(dir, &qname);
@@ -201,28 +225,56 @@ static int proc_sys_fill_cache(struct file *filp, void *dirent,
 	return !!filldir(dirent, qname.name, qname.len, filp->f_pos, ino, type);
 }
 
-static int scan(struct ctl_table_header *head, ctl_table *table,
+static int scan(struct ctl_table_header *head,
 		unsigned long *pos, struct file *file,
 		void *dirent, filldir_t filldir)
 {
+	struct ctl_table_header *h;
+	int res = 0;
 
-	for (; table->procname; table++, (*pos)++) {
-		int res;
+	sysctl_read_lock_head(head);
 
-		/* Can't do anything without a proc name */
-		if (!table->procname)
+	list_for_each_entry(h, &head->ctl_subdirs, ctl_entry) {
+		if (*pos < file->f_pos) {
+			(*pos)++;
 			continue;
+		}
 
-		if (*pos < file->f_pos)
+		if (IS_ERR(sysctl_use_header(h)))
 			continue;
 
-		res = proc_sys_fill_cache(file, dirent, filldir, head, table);
+		res = proc_sys_fill_cache(file, dirent, filldir, h, NULL);
+		sysctl_unuse_header(h);
 		if (res)
-			return res;
+			goto out;
 
 		file->f_pos = *pos + 1;
+		(*pos)++;
 	}
-	return 0;
+
+	list_for_each_entry(h, &head->ctl_tables, ctl_entry) {
+		ctl_table *t;
+
+		if (IS_ERR(sysctl_use_header(h)))
+			continue;
+
+		for (t = h->ctl_table_arg; t->procname; t++, (*pos)++) {
+			if (*pos < file->f_pos)
+				continue;
+
+			res = proc_sys_fill_cache(file, dirent, filldir, h, t);
+			if (res) {
+				sysctl_unuse_header(h);
+				goto out;
+			}
+			file->f_pos = *pos + 1;
+		}
+		sysctl_unuse_header(h);
+	}
+
+out:
+	sysctl_read_unlock_head(head);
+	return res;
 }
 
 static int proc_sys_readdir(struct file *filp, void *dirent, filldir_t filldir)
@@ -230,21 +282,12 @@ static int proc_sys_readdir(struct file *filp, void *dirent, filldir_t filldir)
 	struct dentry *dentry = filp->f_path.dentry;
 	struct inode *inode = dentry->d_inode;
 	struct ctl_table_header *head = sysctl_use_header(PROC_I(inode)->sysctl);
-	struct ctl_table *table = PROC_I(inode)->sysctl_entry;
-	struct ctl_table_header *h = NULL;
 	unsigned long pos;
 	int ret = -EINVAL;
 
 	if (IS_ERR(head))
 		return PTR_ERR(head);
 
-	if (table && !table->child) {
-		WARN_ON(1);
-		goto out;
-	}
-
-	table = table ? table->child : head->ctl_table;
-
 	ret = 0;
 	/* Avoid a switch here: arm builds fail with missing __cmpdi2 */
 	if (filp->f_pos == 0) {
@@ -260,18 +303,20 @@ static int proc_sys_readdir(struct file *filp, void *dirent, filldir_t filldir)
 		filp->f_pos++;
 	}
 	pos = 2;
-
-	ret = scan(head, table, &pos, filp, dirent, filldir);
-	if (ret)
-		goto out;
-
-	for (h = sysctl_use_next_header(NULL); h; h = sysctl_use_next_header(h)) {
-		if (h->attached_to != table)
-			continue;
-		ret = scan(h, h->attached_by, &pos, filp, dirent, filldir);
-		if (ret) {
-			sysctl_unuse_header(h);
-			break;
+	ret = scan(head, &pos, filp, dirent, filldir);
+	if (!ret) {
+		/* the netns-correspondent contains only those
+		 * subdirectories that are netns-specific, and not
+		 * shared with the @head directory: there is no
+		 * possibility to list the same directory twice (once
+		 * for @head and once for @netns_corresp). Sibling
+		 * tables cannot contain the entries with the same
+		 * name, no need to worry about them either. */
+		struct ctl_table_header *netns_corresp;
+		netns_corresp = sysctl_use_netns_corresp(head);
+		if (netns_corresp) {
+			ret = scan(netns_corresp, &pos, filp, dirent, filldir);
+			sysctl_unuse_header(netns_corresp);
 		}
 	}
 	ret = 1;
@@ -302,7 +347,7 @@ static int proc_sys_permission(struct inode *inode, int mask,unsigned int flags)
 		return PTR_ERR(head);
 
 	table = PROC_I(inode)->sysctl_entry;
-	if (!table) /* global root - r-xr-xr-x */
+	if (!table) /* directory - r-xr-xr-x */
 		error = mask & MAY_WRITE ? -EACCES : 0;
 	else /* Use the permissions on the sysctl table entry */
 		error = sysctl_perm(head->ctl_group, table, mask);
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index a12ab12..b626271 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -937,18 +937,12 @@ struct ctl_table;
 struct ctl_table_header;
 struct ctl_table_group;
 struct ctl_table_group_ops;
-struct nsproxy;
-struct ctl_table_root;
-
-struct ctl_table_set {
-	struct list_head list;
-	struct ctl_table_set *parent;
-};
 
 extern __init int sysctl_init(void);
 
-extern void setup_sysctl_set(struct ctl_table_set *p,
-			     struct ctl_table_set *parent);
+extern void sysctl_init_group(struct ctl_table_group *group,
+			      const struct ctl_table_group_ops *ops,
+			      int has_netns_corresp);
 
 
 /* get/put a reference to this header that
@@ -957,14 +951,23 @@ extern void sysctl_proc_inode_get(struct ctl_table_header *);
 extern void sysctl_proc_inode_put(struct ctl_table_header *);
 
 extern int sysctl_is_seen(struct ctl_table_header *);
-extern struct ctl_table_header *sysctl_use_header(struct ctl_table_header *);
-extern struct ctl_table_header *sysctl_use_next_header(struct ctl_table_header *prev);
-extern struct ctl_table_header *__sysctl_use_next_header(struct nsproxy *namespaces,
-						struct ctl_table_header *prev);
-extern void sysctl_unuse_header(struct ctl_table_header *prev);
 extern int sysctl_perm(struct ctl_table_group *group,
 		       struct ctl_table *table, int op);
 
+/* proctect the ctl_subdirs/ctl_tables lists */
+extern void sysctl_write_lock_head(struct ctl_table_header *head);
+extern void sysctl_write_unlock_head(struct ctl_table_header *head);
+extern void sysctl_read_lock_head(struct ctl_table_header *head);
+extern void sysctl_read_unlock_head(struct ctl_table_header *head);
+
+/* get/put references to this header with the pourpose of using it's internals.
+ * As long as the use count is not zero, there may be items accessing it,
+ * so we can't even remove it from the lists (ctl_entry). */
+extern struct ctl_table_header *sysctl_use_header(struct ctl_table_header *);
+extern struct ctl_table_header *sysctl_use_netns_corresp(struct ctl_table_header *);
+extern void sysctl_unuse_header(struct ctl_table_header *prev);
+
+
 typedef struct ctl_table ctl_table;
 
 typedef int proc_handler (struct ctl_table *ctl, int write,
@@ -991,39 +994,29 @@ extern int proc_do_large_bitmap(struct ctl_table *, int,
 
 /*
  * Register a set of sysctl names by calling __register_sysctl_paths
- * with an initialised array of struct ctl_table's.  An entry with 
- * NULL procname terminates the table.  table->de will be
- * set up by the registration and need not be initialised in advance.
- *
- * sysctl names can be mirrored automatically under /proc/sys.  The
- * procname supplied controls /proc naming.
+ * with an initialised array of struct ctl_table's. An entry with a
+ * NULL procname terminates the table.
  *
  * The table's mode will be honoured both for sys_sysctl(2) and
- * proc-fs access.
+ * proc-fs access (sys_sysctl(2) uses procfs internally).
  *
- * Leaf nodes in the sysctl tree will be represented by a single file
- * under /proc; non-leaf nodes will be represented by directories.  A
- * null procname disables /proc mirroring at this node.
+ * Only files can be represented by ctl_table elements. Directories
+ * are implemented with ctl_table_header objects.
  *
- * sysctl(2) can automatically manage read and write requests through
- * the sysctl table.  The data and maxlen fields of the ctl_table
- * struct enable minimal validation of the values being written to be
- * performed, and the mode field allows minimal authentication.
- * 
- * There must be a proc_handler routine for any terminal nodes
- * mirrored under /proc/sys (non-terminals are handled by a built-in
- * directory handler).  Several default handlers are available to
- * cover common cases.
+ * The data and maxlen fields of the ctl_table struct enable minimal
+ * validation of the values being written to be performed, and the
+ * mode field allows minimal authentication.
+ *
+ * There must be a proc_handler routine for each ctl_table node.
+ * Several default handlers are available to cover common cases.
  */
 
 /* A sysctl table is an array of struct ctl_table: */
-struct ctl_table 
-{
+struct ctl_table {
 	const char *procname;		/* Text ID for /proc/sys, or zero */
 	void *data;
 	int maxlen;
 	mode_t mode;
-	struct ctl_table *child;
 	proc_handler *proc_handler;	/* Callback for text formatting */
 	void *extra1;
 	void *extra2;
@@ -1035,8 +1028,8 @@ struct ctl_table_group_ops {
 	 * netns in which that eth0 interface lives.
 	 *
 	 * If this hook is not set, then all the sysctl entries in
-	 * this set are always visible. */
-	int (*is_seen)(struct ctl_table_set *set);
+	 * this group are always visible. */
+	int (*is_seen)(struct ctl_table_group *group);
 
 	/* hook to alter permissions for some sysctl nodes at runtime */
 	int (*permissions)(struct ctl_table *table);
@@ -1044,22 +1037,24 @@ struct ctl_table_group_ops {
 
 struct ctl_table_group {
 	const struct ctl_table_group_ops *ctl_ops;
-};
-
-struct ctl_table_root {
-	struct list_head root_list;
-	struct ctl_table_set default_set;
-	struct ctl_table_set *(*lookup)(struct ctl_table_root *root,
-					   struct nsproxy *namespaces);
+	/* A list of ctl_table_header elements that represent the
+	 * netns-specific correspondents of some sysctl directories */
+	struct list_head corresp_list;
+	/* binary: whether this group uses the @corresp_list */
+	char has_netns_corresp;
 };
 
 /* struct ctl_table_header is used to maintain dynamic lists of
    struct ctl_table trees. */
-struct ctl_table_header
-{
+struct ctl_table_header {
 	union {
 		struct {
-			struct ctl_table *ctl_table;
+			/* a header is used either as a wraper for a
+			 * ctl_table array or as directory entry. */
+			union {
+				struct ctl_table *ctl_table_arg;
+				const char *ctl_dirname;
+			};
 			struct list_head ctl_entry;
 			/* references to this header from contexts that
 			 * can access fields of this header */
@@ -1075,12 +1070,13 @@ struct ctl_table_header
 		struct rcu_head rcu;
 	};
 	struct completion *unregistering;
-	struct ctl_table *ctl_table_arg;
-	struct ctl_table_root *root;
 	struct ctl_table_group *ctl_group;
-	struct ctl_table_set *set;
-	struct ctl_table *attached_by;
-	struct ctl_table *attached_to;
+
+	/* Lists of other ctl_table_headers that represent either
+	 * subdirectories or ctl_tables of files. Add/remove and walk
+	 * this list holding the header's read/write lock. */
+	struct list_head ctl_tables;
+	struct list_head ctl_subdirs;
 	struct ctl_table_header *parent;
 };
 
@@ -1089,18 +1085,12 @@ struct ctl_path {
 	const char *procname;
 };
 
-void register_sysctl_root(struct ctl_table_root *root);
-struct ctl_table_header *__register_sysctl_paths(
-	struct ctl_table_root *root,
-	struct ctl_table_group *group,
-	struct nsproxy *namespaces,
-	const struct ctl_path *path,
-	struct ctl_table *table);
-struct ctl_table_header *register_sysctl_paths(const struct ctl_path *path,
-						struct ctl_table *table);
-
-void unregister_sysctl_table(struct ctl_table_header * table);
-int sysctl_check_table(struct nsproxy *namespaces, struct ctl_table *table);
+extern struct ctl_table_header *__register_sysctl_paths(struct ctl_table_group *g,
+							const struct ctl_path *p,
+							struct ctl_table *table);
+extern struct ctl_table_header *register_sysctl_paths(const struct ctl_path *path,
+						      struct ctl_table *table);
+extern void unregister_sysctl_table(struct ctl_table_header *table);
 
 #endif /* __KERNEL__ */
 
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 3ae4919..871dd2b 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -52,7 +52,7 @@ struct net {
 	struct proc_dir_entry 	*proc_net_stat;
 
 #ifdef CONFIG_SYSCTL
-	struct ctl_table_set	sysctls;
+	struct ctl_table_group	netns_ctl_group;
 #endif
 
 	struct sock 		*rtnl;			/* rtnetlink socket */
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index a863b56..cbf33b1 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -56,6 +56,7 @@
 #include <linux/kprobes.h>
 #include <linux/pipe_fs_i.h>
 #include <linux/oom.h>
+#include <linux/rwsem.h>
 
 #include <asm/uaccess.h>
 #include <asm/processor.h>
@@ -201,23 +202,16 @@ static int sysrq_sysctl_handler(ctl_table *table, int write,
 static const struct ctl_table_group_ops root_table_group_ops = { };
 
 static struct ctl_table_group root_table_group = {
+	.has_netns_corresp = 0,
 	.ctl_ops = &root_table_group_ops,
 };
 
-static struct ctl_table root_table[];
-static struct ctl_table_root sysctl_table_root;
 static struct ctl_table_header root_table_header = {
 	{{.ctl_header_refs = 1,
-	.ctl_table = root_table,
-	.ctl_entry = LIST_HEAD_INIT(sysctl_table_root.default_set.list),}},
-	.root = &sysctl_table_root,
-	.ctl_group = &root_table_group,
-	.set = &sysctl_table_root.default_set,
-};
-
-static struct ctl_table_root sysctl_table_root = {
-	.root_list = LIST_HEAD_INIT(sysctl_table_root.root_list),
-	.default_set.list = LIST_HEAD_INIT(root_table_header.ctl_entry),
+	  .ctl_entry	= LIST_HEAD_INIT(root_table_header.ctl_entry),}},
+	.ctl_tables	= LIST_HEAD_INIT(root_table_header.ctl_tables),
+	.ctl_subdirs	= LIST_HEAD_INIT(root_table_header.ctl_subdirs),
+	.ctl_group	= &root_table_group,
 };
 
 #ifdef HAVE_ARCH_PICK_MMAP_LAYOUT
@@ -226,10 +220,6 @@ int sysctl_legacy_va_layout;
 
 /* The default sysctl tables: */
 
-static struct ctl_table root_table[] = {
-	{ }
-};
-
 #ifdef CONFIG_SCHED_DEBUG
 static int min_sched_granularity_ns = 100000;		/* 100 usecs */
 static int max_sched_granularity_ns = NSEC_PER_SEC;	/* 1 second */
@@ -1575,78 +1565,76 @@ void sysctl_proc_inode_put(struct ctl_table_header *head)
 	spin_unlock(&sysctl_lock);
 }
 
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
-struct ctl_table_header *__sysctl_use_next_header(struct nsproxy *namespaces,
-					    struct ctl_table_header *prev)
+/*
+ * Find the netns correspondent of @head. If it is not found and @dflt
+ * is != NULL, set dflt to be the netns correspondent of @head.
+ */
+static struct ctl_table_header *sysctl_use_netns_corresp_dflt(
+	struct ctl_table_group *group,
+	struct ctl_table_header *head,
+	struct ctl_table_header *dflt)
 {
-	struct ctl_table_root *root;
-	struct list_head *header_list;
-	struct ctl_table_header *head;
-	struct list_head *tmp;
+	struct ctl_table_header *h, *ret = NULL;
 
 	spin_lock(&sysctl_lock);
-	if (prev) {
-		head = prev;
-		tmp = &prev->ctl_entry;
-		__sysctl_unuse_header(prev);
-		goto next;
+	list_for_each_entry(h, &group->corresp_list, ctl_entry) {
+		if (h->parent != head)
+			continue;
+		if (IS_ERR(__sysctl_use_header(h)))
+			continue;
+		ret = h;
+		goto out;
 	}
-	tmp = &root_table_header.ctl_entry;
-	for (;;) {
-		head = list_entry(tmp, struct ctl_table_header, ctl_entry);
 
-		if (IS_ERR(__sysctl_use_header(head)))
-			goto next;
-		spin_unlock(&sysctl_lock);
-		return head;
-	next:
-		root = head->root;
-		tmp = tmp->next;
-		header_list = lookup_header_list(root, namespaces);
-		if (tmp != header_list)
-			continue;
+	if (!dflt)
+		goto out;
+
+	/* will not fail because dflt is a brand-new header that no
+	 * one has seen yet, so no one has started to unregister it */
+	dflt = __sysctl_use_header(dflt);
+	dflt->ctl_dirname = NULL; /* this marks the header as a netns-corresp */
+	dflt->parent = head;
+	list_add_tail(&dflt->ctl_entry, &group->corresp_list);
+	ret = dflt;
 
-		do {
-			root = list_entry(root->root_list.next,
-					struct ctl_table_root, root_list);
-			if (root == &sysctl_table_root)
-				goto out;
-			header_list = lookup_header_list(root, namespaces);
-		} while (list_empty(header_list));
-		tmp = header_list->next;
-	}
 out:
 	spin_unlock(&sysctl_lock);
-	return NULL;
+	return ret;
 }
 
-struct ctl_table_header *sysctl_use_next_header(struct ctl_table_header *prev)
+struct ctl_table_header *sysctl_use_netns_corresp(struct ctl_table_header *h)
 {
-	return __sysctl_use_next_header(current->nsproxy, prev);
+	struct ctl_table_group *g = &current->nsproxy->net_ns->netns_ctl_group;
+	/* dflt == NULL means: if there's a netns corresp return it,
+	 *                     if there isn't, just return NULL */
+	return sysctl_use_netns_corresp_dflt(g, h, NULL);
 }
 
-void register_sysctl_root(struct ctl_table_root *root)
+
+/* This semaphore protects the ctl_subdirs and ctl_tables lists. You
+ * must also have incremented the _use_refs of the header before
+ * accessing any field of the header including these lists. If it's
+ * deemed necessary, we can create a per-header rwsem. For now a
+ * global one will do. */
+static DECLARE_RWSEM(sysctl_rwsem);
+void sysctl_write_lock_head(struct ctl_table_header *head)
 {
-	spin_lock(&sysctl_lock);
-	list_add_tail(&root->root_list, &sysctl_table_root.root_list);
-	spin_unlock(&sysctl_lock);
+	down_write(&sysctl_rwsem);
+}
+void sysctl_write_unlock_head(struct ctl_table_header *head)
+{
+	up_write(&sysctl_rwsem);
+}
+void sysctl_read_lock_head(struct ctl_table_header *head)
+{
+	down_read(&sysctl_rwsem);
+}
+void sysctl_read_unlock_head(struct ctl_table_header *head)
+{
+	up_read(&sysctl_rwsem);
 }
 
+
 /*
  * sysctl_perm does NOT grant the superuser all rights automatically, because
  * some sysctl variables are readonly even to root.
@@ -1710,10 +1698,6 @@ __init int sysctl_init(void)
 		goto fail_register_binfmt_misc;
 #endif
 
-
-#ifdef CONFIG_SYSCTL_SYSCALL_CHECK
-	sysctl_check_table(current->nsproxy, root_table);
-#endif
 	return 0;
 
 
@@ -1734,57 +1718,214 @@ fail_register_kern:
 	return -ENOMEM;
 }
 
-static struct ctl_table *is_branch_in(struct ctl_table *branch,
-				      struct ctl_table *table)
+static void header_refs_inc(struct ctl_table_header*head)
 {
-	struct ctl_table *p;
-	const char *s = branch->procname;
+	spin_lock(&sysctl_lock);
+	head->ctl_header_refs ++;
+	spin_unlock(&sysctl_lock);
+}
 
-	/* branch should have named subdirectory as its first element */
-	if (!s || !branch->child)
-		return NULL;
+static int ctl_path_items(const struct ctl_path *path)
+{
+	int n = 0;
+	while (path->procname) {
+		path++;
+		n++;
+	}
+	return n;
+}
 
-	/* ... and nothing else */
-	if (branch[1].procname)
+
+static struct ctl_table_header *alloc_sysctl_header(struct ctl_table_group *group)
+{
+	struct ctl_table_header *h;
+
+	h = kzalloc(sizeof(*h), GFP_KERNEL);
+	if (!h)
 		return NULL;
 
-	/* table should contain subdirectory with the same name */
-	for (p = table; p->procname; p++) {
-		if (!p->child)
-			continue;
-		if (p->procname && strcmp(p->procname, s) == 0)
-			return p;
+	h->ctl_group = group;
+	INIT_LIST_HEAD(&h->ctl_entry);
+	INIT_LIST_HEAD(&h->ctl_subdirs);
+	INIT_LIST_HEAD(&h->ctl_tables);
+	return h;
+}
+
+/* Increment the references to an existing subdir of @parent with the name
+ * @name and return that subdir. If no such subdir exists, return NULL.
+ * Called under the write lock protecting parent's ctl_subdirs. */
+static struct ctl_table_header *mkdir_existing_dir(struct ctl_table_header *parent,
+						   const char *name)
+{
+	struct ctl_table_header *h;
+	list_for_each_entry(h, &parent->ctl_subdirs, ctl_entry) {
+		spin_lock(&sysctl_lock);
+		if (likely(!h->unregistering)) {
+			if (strcmp(name, h->ctl_dirname) == 0) {
+				h->ctl_header_refs ++;
+				spin_unlock(&sysctl_lock);
+				return h;
+			}
+		}
+		spin_unlock(&sysctl_lock);
 	}
 	return NULL;
 }
 
-/* see if attaching q to p would be an improvement */
-static void try_attach(struct ctl_table_header *p, struct ctl_table_header *q)
+/* Some sysctl paths are netns-specific. The last directory that in
+ * not net-ns specific will have a corespondent dir in the netns
+ * specific ctl_table_group. That corespondent will hold the lists of
+ * netns specific tables and subdirectories.
+ *
+ * E.g.: registering netns/interface specific directories:
+ *       common path: /proc/sys/net/ipv4/
+ *        netns path: /proc/sys/net/ipv4/conf/lo/
+ * We'll create an (unnamed) netns correspondent for 'ipv4' which will
+ * have 'conf' as it's subdir.
+ *
+ * E.g.: We're registering a netns specific file in /proc/sys/net/core/somaxconn
+ *       common path: /proc/sys/net/core/
+ *        netns path: /proc/sys/net/core/
+ * We'll create an (unnamed) netns correspondent for 'core'.
+ */
+static struct ctl_table_header *mkdir_netns_corresp(
+	struct ctl_table_header *parent,
+	struct ctl_table_group *group,
+	struct ctl_table_header **__netns_corresp)
+{
+	struct ctl_table_header *ret;
+
+	ret = sysctl_use_netns_corresp_dflt(group, parent, *__netns_corresp);
+
+	/* *__netns_corresp is a pre-allocated header. If we used it
+            here, we have to tell the caller so it won't free it. */
+	if (*__netns_corresp == ret)
+		*__netns_corresp = NULL;
+
+	header_refs_inc(ret);
+	sysctl_unuse_header(ret);
+	return ret;
+}
+
+/* Add @dir as a subdir of @parent.
+ * Called under the write lock protecting parent's ctl_subdirs. */
+static struct ctl_table_header *mkdir_new_dir(struct ctl_table_header *parent,
+					      struct ctl_table_header *dir)
+{
+	dir->parent = parent;
+	header_refs_inc(dir);
+	list_add_tail(&dir->ctl_entry, &parent->ctl_subdirs);
+	return dir;
+}
+
+/*
+ * Attach the branch denoted by @dirs (a series of directories that
+ * are children of their predecessor in the array) to @parent.
+ *
+ * If at a level there exist in the parent tree a node with the same
+ * name as the one we're trying to add, increment that nodes'
+ * @count. If not, add that dir as a subdir of it's parent.
+ *
+ * Nodes that remain non-NULL in @dirs must be freed by the caller as
+ * they were not added to the tree.
+ *
+ * Return the corresponding ctl_table_header for dirs[nr_dirs-1] from
+ * the tree (either one added by this function, or one already in the
+ * tree).
+ */
+static struct ctl_table_header *sysctl_mkdirs(struct ctl_table_header *parent,
+					      struct ctl_table_group *group,
+					      const struct ctl_path *path,
+					      int nr_dirs)
 {
-	struct ctl_table *to = p->ctl_table, *by = q->ctl_table;
-	struct ctl_table *next;
-	int is_better = 0;
-	int not_in_parent = !p->attached_by;
+	struct ctl_table_header *dirs[CTL_MAXNAME];
+	struct ctl_table_header *__netns_corresp = NULL;
+	int create_first_netns_corresp = group->has_netns_corresp;
+	int i;
+
+	/* We create excess ctl_table_header for directory entries.
+	 * We do so because we may need new headers while under a lock
+	 * where we will not be able to allocate entries (sleeping).
+	 * Also, this simplifies handling of ENOMEM: no need to remove
+	 * already allocated/added directories and unlink them from
+	 * their parent directories. Stuff that is not used will be
+	 * freed at the end. */
+	for (i = 0; i < nr_dirs; i++) {
+		dirs[i] = alloc_sysctl_header(group);
+		if (!dirs[i])
+			goto err_alloc_dir;
+		dirs[i]->ctl_dirname = path[i].procname;
+	}
 
-	while ((next = is_branch_in(by, to)) != NULL) {
-		if (by == q->attached_by)
-			is_better = 1;
-		if (to == p->attached_by)
-			not_in_parent = 1;
-		by = by->child;
-		to = next->child;
+	if (create_first_netns_corresp) {
+		/* The netns correspondent for the last common path
+		 * component migh exist.  However we will only know
+		 * this later while being under a lock. We
+		 * pre-allocate it just in case it might be needed and
+		 * free it at the end only if it wasn't used. */
+		__netns_corresp = alloc_sysctl_header(group);
+		if (!__netns_corresp)
+			goto err_alloc_coresp;
 	}
 
-	if (is_better && not_in_parent) {
-		q->attached_by = by;
-		q->attached_to = to;
-		q->parent = p;
+	header_refs_inc(parent);
+
+	for (i = 0; i < nr_dirs; i++) {
+		struct ctl_table_header *h;
+
+	retry:
+		sysctl_write_lock_head(parent);
+
+		h = mkdir_existing_dir(parent, dirs[i]->ctl_dirname);
+		if (h != NULL) {
+			sysctl_write_unlock_head(parent);
+			parent = h;
+			continue;
+		}
+
+		if (likely(!create_first_netns_corresp)) {
+			h = mkdir_new_dir(parent, dirs[i]);
+			sysctl_write_unlock_head(parent);
+			parent = h;
+			dirs[i] = NULL; /* I'm used, don't free me */
+			continue;
+		}
+
+		sysctl_write_unlock_head(parent);
+
+		create_first_netns_corresp = 0;
+		parent = mkdir_netns_corresp(parent, group, &__netns_corresp);
+		/* We still have to add the new subdirectory, but
+		 * instead of adding it into the common parent, add it
+		 * to it's netns correspondent. */
+		goto retry;
 	}
+
+	if (create_first_netns_corresp)
+		parent = mkdir_netns_corresp(parent, group, &__netns_corresp);
+
+	if (__netns_corresp)
+		kfree(__netns_corresp);
+
+	/* free unused pre-allocated entries */
+	for (i = 0; i < nr_dirs; i++)
+		if (dirs[i])
+			kfree(dirs[i]);
+
+	return parent;
+
+err_alloc_coresp:
+	i = nr_dirs;
+err_alloc_dir:
+	for (i--; i >= 0; i--)
+		kfree(dirs[i]);
+	return NULL;
+
 }
 
 /**
  * __register_sysctl_paths - register a sysctl hierarchy
- * @root: List of sysctl headers to register on
+ * @group: Group of sysctl headers to register on
  * @namespaces: Data to compute which lists of sysctl entries are visible
  * @path: The path to the directory the sysctl table is in.
  * @table: the top-level table structure
@@ -1803,9 +1944,6 @@ static void try_attach(struct ctl_table_header *p, struct ctl_table_header *q)
  *
  * mode - the file permissions for the /proc/sys file, and for sysctl(2)
  *
- * child - a pointer to the child sysctl table if this entry is a directory, or
- *         %NULL.
- *
  * proc_handler - the text handler routine (described below)
  *
  * de - for internal use by the sysctl routines
@@ -1835,78 +1973,28 @@ static void try_attach(struct ctl_table_header *p, struct ctl_table_header *q)
  * This routine returns %NULL on a failure to register, and a pointer
  * to the table header on success.
  */
-struct ctl_table_header *__register_sysctl_paths(
-	struct ctl_table_root *root,
-	struct ctl_table_group *group,
-	struct nsproxy *namespaces,
+struct ctl_table_header *__register_sysctl_paths(struct ctl_table_group *group,
 	const struct ctl_path *path, struct ctl_table *table)
 {
 	struct ctl_table_header *header;
-	struct ctl_table *new, **prevp;
-	unsigned int n, npath;
-	struct ctl_table_set *set;
-
-	/* Count the path components */
-	for (npath = 0; path[npath].procname; ++npath)
-		;
+	int nr_dirs = ctl_path_items(path);
 
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
+	header = alloc_sysctl_header(group);
 	if (!header)
 		return NULL;
 
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
-	header->unregistering = NULL;
-	header->root = root;
-	header->ctl_group = group;
-	header->ctl_header_refs = 1;
-#ifdef CONFIG_SYSCTL_SYSCALL_CHECK
-	if (sysctl_check_table(namespaces, header->ctl_table)) {
+	header->parent = sysctl_mkdirs(&root_table_header, group, path, nr_dirs);
+	if (!header->parent) {
 		kfree(header);
 		return NULL;
 	}
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
-	header->parent->ctl_header_refs++;
-	list_add_tail(&header->ctl_entry, &header->set->list);
-	spin_unlock(&sysctl_lock);
+
+	header->ctl_table_arg = table;
+	header->ctl_header_refs = 1;
+
+	sysctl_write_lock_head(header->parent);
+	list_add_tail(&header->ctl_entry, &header->parent->ctl_tables);
+	sysctl_write_unlock_head(header->parent);
 
 	return header;
 }
@@ -1924,8 +2012,7 @@ struct ctl_table_header *__register_sysctl_paths(
 struct ctl_table_header *register_sysctl_paths(const struct ctl_path *path,
 						struct ctl_table *table)
 {
-	return __register_sysctl_paths(&sysctl_table_root, &root_table_group,
-				       current->nsproxy, path, table);
+	return __register_sysctl_paths(&root_table_group, path, table);
 }
 
 /**
@@ -1935,31 +2022,67 @@ struct ctl_table_header *register_sysctl_paths(const struct ctl_path *path,
  * Unregisters the sysctl table and all children. proc entries may not
  * actually be removed until they are no longer used by anyone.
  */
-void unregister_sysctl_table(struct ctl_table_header * header)
+void unregister_sysctl_table(struct ctl_table_header *header)
 {
 	might_sleep();
 
-	if (header == NULL)
-		return;
+	while(header->parent) {
+		struct ctl_table_header *parent = header->parent;
 
-	spin_lock(&sysctl_lock);
-	start_unregistering(header);
-
-	/* after start_unregistering has finished no one holds a
-	 * ctl_use_refs or is able to acquire one => no one is going
-	 * to access internal fields of this object, so we can remove
-	 * it from the list and schedule it for deletion. */
-	list_del_init(&p->ctl_entry);
-
-	if (!--header->parent->ctl_header_refs) {
-		WARN_ON(1);
-		if (!header->parent->ctl_procfs_refs)
-			call_rcu(&header->parent->rcu, free_head);
-	}
-	if (!--header->ctl_header_refs)
+		/* the three counters (ctl_header_refs, ctl_procfs_refs
+		 * and ctl_use_refs) are protected by the spin lock. */
+		spin_lock(&sysctl_lock);
+		if (header->ctl_header_refs > 1) {
+			/* other headers need a reference to this one. Just
+			 * mark that we don't need it and leave it as it is. */
+			header->ctl_header_refs --;
+			spin_unlock(&sysctl_lock);
+
+			goto unregister_parent;
+		}
+
+		/* header->ctl_header_refs is 1. We hold the only
+		 * ctl_header_refs reference, but others may still
+		 * hold _use_refs and _procfs_refs. We first need to
+		 * wait until no one is actively using this object
+		 * (that means until ctl_use_refs==0). While waiting
+		 * no one will increase this header's refs because we
+		 * set ->unregistering. */
+		start_unregistering(header);
+		spin_unlock(&sysctl_lock);
+
+		if (!header->ctl_dirname) {
+			/* the header is a netns correspondent of it's
+			 * parent. It is a member of it's netns
+			 * specific ctl_table_group list. For not that
+			 * list is protected by sysctl_lock. */
+			spin_lock(&sysctl_lock);
+			list_del_init(&header->ctl_entry);
+			spin_unlock(&sysctl_lock);
+		} else {
+			/* ctl_entry is a member of the parent's
+			 * ctl_tables/subdirs lists which are
+			 * protected by the parent's write lock. */
+			sysctl_write_lock_head(parent);
+			list_del_init(&header->ctl_entry);
+			sysctl_write_unlock_head(parent);
+		}
+
+		spin_lock(&sysctl_lock);
+		/* something is wrong in the register/unregister code
+		 * if this BUG triggers. No one should have changed the
+		 * _header_refs of this header after start_unregistering */
+		BUG_ON(header->ctl_header_refs != 1);
+
+		header->ctl_header_refs --;
 		if (!header->ctl_procfs_refs)
 			call_rcu(&header->rcu, free_head);
-	spin_unlock(&sysctl_lock);
+
+		spin_unlock(&sysctl_lock);
+
+unregister_parent:
+		header = parent;
+	}
 }
 
 int sysctl_is_seen(struct ctl_table_header *p)
@@ -1972,16 +2095,19 @@ int sysctl_is_seen(struct ctl_table_header *p)
 	else if (!ops->is_seen)
 		res = 1;
 	else
-		res = ops->is_seen(p->set);
+		res = ops->is_seen(p->ctl_group);
 	spin_unlock(&sysctl_lock);
 	return res;
 }
 
-void setup_sysctl_set(struct ctl_table_set *p,
-		      struct ctl_table_set *parent)
+void sysctl_init_group(struct ctl_table_group *group,
+		       const struct ctl_table_group_ops *ops,
+		       int has_netns_corresp)
 {
-	INIT_LIST_HEAD(&p->list);
-	p->parent = parent ? parent : &sysctl_table_root.default_set;
+	group->ctl_ops = ops;
+	group->has_netns_corresp = has_netns_corresp;
+	if (has_netns_corresp)
+		INIT_LIST_HEAD(&group->corresp_list);
 }
 
 #else /* !CONFIG_SYSCTL */
@@ -1995,8 +2121,9 @@ void unregister_sysctl_table(struct ctl_table_header * table)
 {
 }
 
-void setup_sysctl_set(struct ctl_table_set *p,
-		      struct ctl_table_set *parent)
+void sysctl_init_group(struct ctl_table_group *group,
+		       const struct ctl_table_group_ops *ops,
+		       int has_netns_corresp)
 {
 }
 
diff --git a/kernel/sysctl_check.c b/kernel/sysctl_check.c
index 44c31f0..e9a7a58 100644
--- a/kernel/sysctl_check.c
+++ b/kernel/sysctl_check.c
@@ -1,167 +1 @@
-#include <linux/stat.h>
-#include <linux/sysctl.h>
-#include "../fs/xfs/linux-2.6/xfs_sysctl.h"
-#include <linux/sunrpc/debug.h>
-#include <linux/string.h>
-#include <net/ip_vs.h>
-
-
-static void sysctl_print_path(struct ctl_table *table,
-			      struct ctl_table **parents, int depth)
-{
-	struct ctl_table *p;
-	int i;
-	if (table->procname) {
-		for (i = 0; i < depth; i++) {
-			p = parents[i];
-			printk("/%s", p->procname ? p->procname : "");
-		}
-		printk("/%s", table->procname);
-	}
-	printk(" ");
-}
-
-static struct ctl_table *sysctl_check_lookup(struct nsproxy *namespaces,
-	     struct ctl_table *table, struct ctl_table **parents, int depth)
-{
-	struct ctl_table_header *head;
-	struct ctl_table *ref, *test;
-	int cur_depth;
-
-	for (head = __sysctl_use_next_header(namespaces, NULL); head;
-	     head = __sysctl_use_next_header(namespaces, head)) {
-		cur_depth = depth;
-		ref = head->ctl_table;
-repeat:
-		test = parents[depth - cur_depth];
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
-	sysctl_unuse_header(head);
-	return ref;
-}
-
-static void set_fail(const char **fail, struct ctl_table *table,
-	     const char *str, struct ctl_table **parents, int depth)
-{
-	if (*fail) {
-		printk(KERN_ERR "sysctl table check failed: ");
-		sysctl_print_path(table, parents, depth);
-		printk(" %s\n", *fail);
-		dump_stack();
-	}
-	*fail = str;
-}
-
-static void sysctl_check_leaf(struct nsproxy *namespaces,
-			      struct ctl_table *table, const char **fail,
-			      struct ctl_table **parents, int depth)
-{
-	struct ctl_table *ref;
-
-	ref = sysctl_check_lookup(namespaces, table, parents, depth);
-	if (ref && (ref != table))
-		set_fail(fail, table, "Sysctl already exists", parents, depth);
-}
-
-
-
-#define SET_FAIL(str) set_fail(&fail, table, str, parents, depth)
-
-static int __sysctl_check_table(struct nsproxy *namespaces,
-	struct ctl_table *table, struct ctl_table **parents, int depth)
-{
-	const char *fail = NULL;
-	int error = 0;
-
-	if (depth >= CTL_MAXNAME) {
-		SET_FAIL("Sysctl tree too deep");
-		return -EINVAL;
-	}
-
-	for (; table->procname; table++) {
-		fail = NULL;
-
-
-		if (depth != 0) { /* has parent */
-			if (!parents[depth - 1]->procname)
-				SET_FAIL("Parent without procname");
-		}
-		if (table->child) {
-			if (table->data)
-				SET_FAIL("Directory with data?");
-			if (table->maxlen)
-				SET_FAIL("Directory with maxlen?");
-			if ((table->mode & (S_IRUGO|S_IXUGO)) != table->mode)
-				SET_FAIL("Writable sysctl directory");
-			if (table->proc_handler)
-				SET_FAIL("Directory with proc_handler");
-			if (table->extra1)
-				SET_FAIL("Directory with extra1");
-			if (table->extra2)
-				SET_FAIL("Directory with extra2");
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
-					SET_FAIL("No data");
-				if (!table->maxlen)
-					SET_FAIL("No maxlen");
-			}
-#ifdef CONFIG_PROC_SYSCTL
-			if (!table->proc_handler)
-				SET_FAIL("No proc_handler");
-#endif
-			parents[depth] = table;
-			sysctl_check_leaf(namespaces, table, &fail,
-					  parents, depth);
-		}
-		if (table->mode > 0777)
-			SET_FAIL("bogus .mode");
-		if (fail) {
-			SET_FAIL(NULL);
-			error = -EINVAL;
-		}
-		if (table->child) {
-			parents[depth] = table;
-			error |= __sysctl_check_table(namespaces, table->child,
-						      parents, depth + 1);
-		}
-	}
-	return error;
-}
-
-
-int sysctl_check_table(struct nsproxy *namespaces, struct ctl_table *table)
-{
-	struct ctl_table *parents[CTL_MAXNAME];
-	/* Keep track of parents as we go down into the tree:
-	 * - the node at depth 'd' will have the parent at parents[d-1].
-	 * - the root node (depth=0) has no parent in this array.
-	 */
-	return __sysctl_check_table(namespaces, table, parents, 0);
-}
+/* will be rewritten */
diff --git a/net/sysctl_net.c b/net/sysctl_net.c
index 5009d4e..f610879 100644
--- a/net/sysctl_net.c
+++ b/net/sysctl_net.c
@@ -29,15 +29,9 @@
 #include <linux/if_tr.h>
 #endif
 
-static struct ctl_table_set *
-net_ctl_header_lookup(struct ctl_table_root *root, struct nsproxy *namespaces)
+static int is_seen(struct ctl_table_group *group)
 {
-	return &namespaces->net_ns->sysctls;
-}
-
-static int is_seen(struct ctl_table_set *set)
-{
-	return &current->nsproxy->net_ns->sysctls == set;
+	return &current->nsproxy->net_ns->netns_ctl_group == group;
 }
 
 /* Return standard mode bits for table entry. */
@@ -56,14 +50,6 @@ static const struct ctl_table_group_ops net_sysctl_group_ops = {
 	.permissions = net_ctl_permissions,
 };
 
-static struct ctl_table_group net_sysctl_group = {
-	.ctl_ops = &net_sysctl_group_ops,
-};
-
-static struct ctl_table_root net_sysctl_root = {
-	.lookup = net_ctl_header_lookup,
-};
-
 static int net_ctl_ro_header_permissions(ctl_table *table)
 {
 	if (net_eq(current->nsproxy->net_ns, &init_net))
@@ -77,21 +63,22 @@ static const struct ctl_table_group_ops net_sysctl_ro_group_ops = {
 };
 
 static struct ctl_table_group net_sysctl_ro_group = {
+	.has_netns_corresp = 0,
 	.ctl_ops = &net_sysctl_ro_group_ops,
 };
 
-static struct ctl_table_root net_sysctl_ro_root = { };
-
 static int __net_init sysctl_net_init(struct net *net)
 {
-	setup_sysctl_set(&net->sysctls,
-			 &net_sysctl_ro_root.default_set);
+	int has_netns_corresp = 1;
+
+	sysctl_init_group(&net->netns_ctl_group, &net_sysctl_group_ops,
+			  has_netns_corresp);
 	return 0;
 }
 
 static void __net_exit sysctl_net_exit(struct net *net)
 {
-	WARN_ON(!list_empty(&net->sysctls.list));
+	WARN_ON(!list_empty(&net->netns_ctl_group.corresp_list));
 }
 
 static struct pernet_operations sysctl_pernet_ops = {
@@ -105,9 +92,6 @@ static __init int net_sysctl_init(void)
 	ret = register_pernet_subsys(&sysctl_pernet_ops);
 	if (ret)
 		goto out;
-	register_sysctl_root(&net_sysctl_root);
-	setup_sysctl_set(&net_sysctl_ro_root.default_set, NULL);
-	register_sysctl_root(&net_sysctl_ro_root);
 out:
 	return ret;
 }
@@ -116,19 +100,14 @@ subsys_initcall(net_sysctl_init);
 struct ctl_table_header *register_net_sysctl_table(struct net *net,
 	const struct ctl_path *path, struct ctl_table *table)
 {
-	struct nsproxy namespaces;
-	namespaces = *current->nsproxy;
-	namespaces.net_ns = net;
-	return __register_sysctl_paths(&net_sysctl_root, &net_sysctl_group,
-					&namespaces, path, table);
+	return __register_sysctl_paths(&net->netns_ctl_group, path, table);
 }
 EXPORT_SYMBOL_GPL(register_net_sysctl_table);
 
 struct ctl_table_header *register_net_sysctl_rotable(const
 		struct ctl_path *path, struct ctl_table *table)
 {
-	return __register_sysctl_paths(&net_sysctl_ro_root, &net_sysctl_ro_group,
-			&init_nsproxy, path, table);
+	return __register_sysctl_paths(&net_sysctl_ro_group, path, table);
 }
 EXPORT_SYMBOL_GPL(register_net_sysctl_rotable);
 
-- 
1.7.5.134.g1c08b

