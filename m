From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [PATCH 16/24] sysctl: add support for private_children headers
Date: Sat,  2 Apr 2011 04:53:30 +0200
Message-ID: <066f77f771476421586d6fa1b7b786896c5cbd49.1301711868.git.lucian.grijincu__3266.00388293645$1301713061$gmane$org@gmail.com>
References: <cover.1301711868.git.lucian.grijincu@gmail.com>
Cc: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: "'David S . Miller'" <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	Octavian Purdila <tavi@cs.pub.ro>,
	linux-kernel@vger.
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:32917 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756229Ab1DBCys (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 22:54:48 -0400
In-Reply-To: <cover.1301711868.git.lucian.grijincu@gmail.com>
In-Reply-To: <cover.1301711868.git.lucian.grijincu@gmail.com>
References: <cover.1301711868.git.lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Problem:

- some subsystems register a lot of sysctl tables in a well known
  place.  e.g. all the '/proc/sys/net/ipv4/conf/$DEVNAME' headers
  under '/proc/sys/net/ipv4/conf/'.

- each time we look for a header we search the list of all headers in
  it's set (each network namespace specific headers gets it's own set)

When to use private_children:

- when you have registered the parent node of the table you're
  registering, and you know no other node with a path closer to the
  one you're registering will be registered.

- when you don't want to register another table underneath the header
  you're registering

- when you don't need to check for duplicate table names (you have
  external logic that prevents duplicates).

Advantages of private_children usage:

- the private children are not checked for duplicates

- the private children will be attached to the specified parent. We
  don't compute the parent by checking with all headers in the set.

- the private children list will only be accessed if the specified
  parent was accessed. All non-private headers in the set are iterated
  over when looking for headers attached to another header.

Private headers bring these benefits:

- fast insertion time: O(1) [no duplicate check, fixed parent]

- fast lookup time: only search the parent and it's private_children
  Not looking over the list of all headers.

- fewer headers in the per-set list of headers => overall reduced
  insertion/lookup times

Notes for reviewers: there is also room for improvement:

- The cost of checking the list of private children can be very low by
  limiting the cases where private children may be used:

For example:
	p = find_in_table(table, name);
	if (!p)
		for (h = sysctl_private_child_next(NULL, head); h;
		     h = sysctl_private_child_next(h, head)) { ... }

can be converted into:
	if (table->procname)
	   p = find_in_table(table, name);
	else
		for (h = sysctl_private_child_next(NULL, head); h;
		     h = sysctl_private_child_next(h, head)) { ... }

If only headers that point to empty directories are allowed to hold
private children, and all private children are located in the deepest
element of the path, we can use the second variant.

I didn't limit the usability of private children in this patch,
because someone else may find use for them in contexts that I have not
foreseen, but all of the patches that follow in this series respect
this restriction: e.g.:
- the parent header is an empty dir /proc/sys/net/ipv4/conf/
- all children are of the for /proc/sys/net/ipv4/conf/DEVNAME. No
  private child is registered at a level higher that 'conf'.

Another optimisation would be to replace the linked list of private
children with a hashtable: this would lower the lookup times, but
would cost more memory and complicate the disposal logic.

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 fs/proc/proc_sysctl.c  |   21 ++++++++++++++
 include/linux/sysctl.h |   12 +++++++-
 kernel/sysctl.c        |   72 +++++++++++++++++++++++++++++++++++++++++------
 net/sysctl_net.c       |    4 +-
 4 files changed, 96 insertions(+), 13 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index f1e91e7..5e79c0b 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -99,6 +99,16 @@ static struct dentry *proc_sys_lookup(struct inode *dir, struct dentry *dentry,
 
 	p = find_in_table(table, name);
 	if (!p) {
+		for (h = sysctl_private_child_next(NULL, head); h;
+		     h = sysctl_private_child_next(h, head)) {
+			if (h->attached_to != table)
+				continue;
+			p = find_in_table(h->attached_by, name);
+			if (p)
+				break;
+		}
+	}
+	if (!p) {
 		for (h = sysctl_head_next(NULL); h; h = sysctl_head_next(h)) {
 			if (h->attached_to != table)
 				continue;
@@ -280,6 +290,17 @@ static int proc_sys_readdir(struct file *filp, void *dirent, filldir_t filldir)
 	if (ret)
 		goto out;
 
+	for (h = sysctl_private_child_next(NULL, head); h;
+	     h = sysctl_private_child_next(h, head)) {
+		if (h->attached_to != table)
+			continue;
+		ret = scan(h, h->attached_by, &pos, filp, dirent, filldir);
+		if (ret) {
+			sysctl_head_finish(h);
+			break;
+		}
+	}
+
 	for (h = sysctl_head_next(NULL); h; h = sysctl_head_next(h)) {
 		if (h->attached_to != table)
 			continue;
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index f0eb817..f7addab 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -956,6 +956,8 @@ extern struct ctl_table_header *sysctl_head_grab(struct ctl_table_header *);
 extern struct ctl_table_header *sysctl_head_next(struct ctl_table_header *prev);
 extern struct ctl_table_header *__sysctl_head_next(struct nsproxy *namespaces,
 						struct ctl_table_header *prev);
+extern struct ctl_table_header *sysctl_private_child_next(
+	struct ctl_table_header *prev, struct ctl_table_header *parent);
 extern void sysctl_head_finish(struct ctl_table_header *prev);
 extern int sysctl_perm(struct ctl_table_root *root,
 		struct ctl_table *table, int op);
@@ -1067,6 +1069,13 @@ struct ctl_table_header
 	/* Pointer to data that outlives this ctl_table_header.
 	 * Caller responsible to free the cookie. */
 	void *ctl_header_cookie;
+
+	/* List of other headers that are 'children' of this header:
+	 * - the children must be freed before this header
+	 * - the children are assumed to be unique (no duplicate checks)
+	 * - the children are not listed under attached_to/attached_by
+	 * - you cannot attach another node under a private child. */
+	struct list_head private_children;
 };
 
 /* struct ctl_path describes where in the hierarchy a table is added */
@@ -1077,7 +1086,8 @@ struct ctl_path {
 void register_sysctl_root(struct ctl_table_root *root);
 struct ctl_table_header *__register_sysctl_paths(
 	struct ctl_table_root *root, struct nsproxy *namespaces,
-	const struct ctl_path *path, struct ctl_table *table, void *cookie);
+	const struct ctl_path *path, struct ctl_table *table,
+	void *cookie, struct ctl_table_header *private_parent);
 struct ctl_table_header *register_sysctl_table(struct ctl_table * table);
 struct ctl_table_header *register_sysctl_paths(const struct ctl_path *path,
 						struct ctl_table *table);
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index cd7340d..2639029 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -209,6 +209,7 @@ static struct ctl_table_header root_table_header = {
 	.root = &sysctl_table_root,
 	.set = &sysctl_table_root.default_set,
 	.ctl_header_cookie = NULL,
+	.private_children = LIST_HEAD_INIT(root_table_header.private_children),
 };
 static struct ctl_table_root sysctl_table_root = {
 	.root_list = LIST_HEAD_INIT(sysctl_table_root.root_list),
@@ -1676,6 +1677,38 @@ struct ctl_table_header *sysctl_head_next(struct ctl_table_header *prev)
 	return __sysctl_head_next(current->nsproxy, prev);
 }
 
+struct ctl_table_header *
+sysctl_private_child_next(struct ctl_table_header *prev,
+			  struct ctl_table_header *parent)
+{
+	struct list_head *tmp;
+
+	if (!parent)
+		return NULL;
+
+	spin_lock(&sysctl_lock);
+	if (prev) {
+		tmp = prev->ctl_entry.next;
+		unuse_table(prev);
+	} else {
+		tmp = parent->private_children.next;
+	}
+	for (;;) {
+		struct ctl_table_header *head;
+		if (tmp == &parent->private_children)
+			break; /* reached end-of-list sentinel */
+
+		head = list_entry(tmp, struct ctl_table_header, ctl_entry);
+		if (use_table(head)) {
+			spin_unlock(&sysctl_lock);
+			return head;
+		}
+		tmp = tmp->next;
+	}
+	spin_unlock(&sysctl_lock);
+	return NULL;
+}
+
 void register_sysctl_root(struct ctl_table_root *root)
 {
 	spin_lock(&sysctl_lock);
@@ -1788,6 +1821,16 @@ static void try_attach(struct ctl_table_header *p, struct ctl_table_header *q)
  * @cookie: Pointer to user provided data that must be accessible
  *  until unregister_sysctl_table. This cookie will be passed to the
  *  proc_handler.
+ * @private_parent: if NULL then the the created header will have as a
+ *  parent the first header registered with the closest matching path.
+ *  If not-NULL, the created header will be ca private child of
+ *  @private_parent. There will be no attempt to check whether there
+ *  is a better match for a parent (another header with a closer
+ *  matching path). To be used when you dynamically create a lot of
+ *  headers under the same path. E.g. when creating an entry for eth0
+ *  under '/proc/sys/net/ipv4/conf/eth0', set @private_parent to the
+ *  header corresponding to '/proc/sys/net/ipv4/conf/'
+ *
  *
  * Register a sysctl table hierarchy. @table should be a filled in ctl_table
  * array. A completely 0 filled entry terminates the table.
@@ -1837,7 +1880,8 @@ static void try_attach(struct ctl_table_header *p, struct ctl_table_header *q)
  */
 struct ctl_table_header *__register_sysctl_paths(
 	struct ctl_table_root *root, struct nsproxy *namespaces,
-	const struct ctl_path *path, struct ctl_table *table, void *cookie)
+	const struct ctl_path *path, struct ctl_table *table,
+	void *cookie, struct ctl_table_header *private_parent)
 {
 	struct ctl_table_header *header;
 	struct ctl_table *new, **prevp;
@@ -1879,6 +1923,7 @@ struct ctl_table_header *__register_sysctl_paths(
 	header->ctl_table_arg = table;
 
 	INIT_LIST_HEAD(&header->ctl_entry);
+	INIT_LIST_HEAD(&header->private_children);
 	header->used = 0;
 	header->unregistering = NULL;
 	header->root = root;
@@ -1886,26 +1931,33 @@ struct ctl_table_header *__register_sysctl_paths(
 	header->count = 1;
 	header->ctl_header_cookie = cookie;
 #ifdef CONFIG_SYSCTL_SYSCALL_CHECK
-	if (sysctl_check_table(namespaces, header->ctl_table)) {
+	if (!private_parent && sysctl_check_table(namespaces, header->ctl_table)) {
 		kfree(header);
 		return NULL;
 	}
 #endif
 	spin_lock(&sysctl_lock);
+
 	header->set = lookup_header_set(root, namespaces);
 	header->attached_by = header->ctl_table;
 	header->attached_to = root_table;
 	header->parent = &root_table_header;
-	for (set = header->set; set; set = set->parent) {
-		struct ctl_table_header *p;
-		list_for_each_entry(p, &set->list, ctl_entry) {
-			if (p->unregistering)
-				continue;
-			try_attach(p, header);
+
+	if (private_parent) {
+		try_attach(private_parent, header);
+		list_add_tail(&header->ctl_entry, &private_parent->private_children);
+	} else {
+		for (set = header->set; set; set = set->parent) {
+			struct ctl_table_header *p;
+			list_for_each_entry(p, &set->list, ctl_entry) {
+				if (p->unregistering)
+					continue;
+				try_attach(p, header);
+			}
 		}
+		list_add_tail(&header->ctl_entry, &header->set->list);
 	}
 	header->parent->count++;
-	list_add_tail(&header->ctl_entry, &header->set->list);
 	spin_unlock(&sysctl_lock);
 
 	return header;
@@ -1925,7 +1977,7 @@ struct ctl_table_header *register_sysctl_paths(const struct ctl_path *path,
 						struct ctl_table *table)
 {
 	return __register_sysctl_paths(&sysctl_table_root, current->nsproxy,
-				       path, table, NULL);
+				       path, table, NULL, NULL);
 }
 
 /**
diff --git a/net/sysctl_net.c b/net/sysctl_net.c
index 7447d6e..aa6c6f4 100644
--- a/net/sysctl_net.c
+++ b/net/sysctl_net.c
@@ -110,7 +110,7 @@ struct ctl_table_header *register_net_sysctl_table(struct net *net,
 	namespaces = *current->nsproxy;
 	namespaces.net_ns = net;
 	return __register_sysctl_paths(&net_sysctl_root, &namespaces, path,
-				       table, net);
+				       table, net, NULL);
 }
 EXPORT_SYMBOL_GPL(register_net_sysctl_table);
 
@@ -118,7 +118,7 @@ struct ctl_table_header *register_net_sysctl_rotable(const
 		struct ctl_path *path, struct ctl_table *table)
 {
 	return __register_sysctl_paths(&net_sysctl_ro_root,
-				       &init_nsproxy, path, table, NULL);
+				       &init_nsproxy, path, table, NULL, NULL);
 }
 EXPORT_SYMBOL_GPL(register_net_sysctl_rotable);
 
-- 
1.7.5.rc0

