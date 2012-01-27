From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 28/29] sysctl: Index sysctl directories with rbtrees.
Date: Thu, 26 Jan 2012 20:50:09 -0800
Message-ID: <1327639810-12760-28-git-send-email-ebiederm@xmission.com>
References: <m1pqe5ah3z.fsf@fess.ebiederm.org>
Cc: <linux-fsdevel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Damien Millescamps <damien.millescamps@6wind.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1pqe5ah3z.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

One of the most important jobs of sysctl is to export network stack
tunables.  Several of those tunables are per network device.  In
several instances people are running with 1000+ network devices in
there network stacks, which makes the simple per directory linked list
in sysctl a scaling bottleneck.   Replace O(N^2) sysctl insertion and
lookup times with O(NlogN) by using an rbtree to index the sysctl
directories.

Benchmark before:
    make-dummies 0 999 -> 0.32s
    rmmod dummy        -> 0.12s
    make-dummies 0 9999 -> 1m17s
    rmmod dummy         -> 17s

Benchmark after:
    make-dummies 0 999 -> 0.074s
    rmmod dummy        -> 0.070s
    make-dummies 0 9999 -> 3.4s
    rmmod dummy         -> 0.44s

Benchmark after (without dev_snmp6):
    make-dummies 0 9999 -> 0.75s
    rmmod dummy         -> 0.44s
    make-dummies 0 99999 -> 11s
    rmmod dummy          -> 4.3s

At 10,000 dummy devices the bottleneck becomes the time to add and
remove the files under /proc/sys/net/dev_snmp6.  I have commented
out the code that adds and removes files under /proc/sys/net/dev_snmp6
and taken measurments of creating and destroying 100,000 dummies to
verify the sysctl continues to scale.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/proc/proc_sysctl.c  |  224 +++++++++++++++++++++++++++++-------------------
 include/linux/sysctl.h |   10 ++-
 2 files changed, 142 insertions(+), 92 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index e971ccc..05c393a 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -33,12 +33,10 @@ static struct ctl_table root_table[] = {
 	{ }
 };
 static struct ctl_table_root sysctl_table_root = {
-	.default_set.dir.list = LIST_HEAD_INIT(sysctl_table_root.default_set.dir.list),
 	.default_set.dir.header = {
 		{{.count = 1,
 		  .nreg = 1,
-		  .ctl_table = root_table,
-		  .ctl_entry = LIST_HEAD_INIT(sysctl_table_root.default_set.dir.header.ctl_entry),}},
+		  .ctl_table = root_table }},
 		.ctl_table_arg = root_table,
 		.root = &sysctl_table_root,
 		.set = &sysctl_table_root.default_set,
@@ -52,7 +50,6 @@ static int sysctl_follow_link(struct ctl_table_header **phead,
 	struct ctl_table **pentry, struct nsproxy *namespaces);
 static int insert_links(struct ctl_table_header *head);
 static void put_links(struct ctl_table_header *header);
-static int sysctl_check_dups(struct ctl_dir *dir, struct ctl_table *table);
 
 static void sysctl_print_dir(struct ctl_dir *dir)
 {
@@ -81,28 +78,83 @@ static struct ctl_table *find_entry(struct ctl_table_header **phead,
 {
 	struct ctl_table_header *head;
 	struct ctl_table *entry;
+	struct rb_node *node = dir->root.rb_node;
 
-	list_for_each_entry(head, &dir->list, ctl_entry) {
-		if (head->unregistering)
-			continue;
-		for (entry = head->ctl_table; entry->procname; entry++) {
-			const char *procname = entry->procname;
-			if (namecmp(procname, strlen(procname), name, namelen) == 0) {
-				*phead = head;
-				return entry;
-			}
+	while (node)
+	{
+		struct ctl_node *ctl_node;
+		const char *procname;
+		int cmp;
+
+		ctl_node = rb_entry(node, struct ctl_node, node);
+		head = ctl_node->header;
+		entry = &head->ctl_table[ctl_node - head->node];
+		procname = entry->procname;
+
+		cmp = namecmp(name, namelen, procname, strlen(procname));
+		if (cmp < 0)
+			node = node->rb_left;
+		else if (cmp > 0)
+			node = node->rb_right;
+		else {
+			*phead = head;
+			return entry;
 		}
 	}
 	return NULL;
 }
 
+static int insert_entry(struct ctl_table_header *head, struct ctl_table *entry)
+{
+	struct rb_node *node = &head->node[entry - head->ctl_table].node;
+	struct rb_node **p = &head->parent->root.rb_node;
+	struct rb_node *parent = NULL;
+	const char *name = entry->procname;
+	int namelen = strlen(name);
+
+	while (*p) {
+		struct ctl_table_header *parent_head;
+		struct ctl_table *parent_entry;
+		struct ctl_node *parent_node;
+		const char *parent_name;
+		int cmp;
+
+		parent = *p;
+		parent_node = rb_entry(parent, struct ctl_node, node);
+		parent_head = parent_node->header;
+		parent_entry = &parent_head->ctl_table[parent_node - parent_head->node];
+		parent_name = parent_entry->procname;
+
+		cmp = namecmp(name, namelen, parent_name, strlen(parent_name));
+		if (cmp < 0)
+			p = &(*p)->rb_left;
+		else if (cmp > 0)
+			p = &(*p)->rb_right;
+		else {
+			printk(KERN_ERR "sysctl duplicate entry: ");
+			sysctl_print_dir(head->parent);
+			printk(KERN_CONT "/%s\n", entry->procname);
+			return -EEXIST;
+		}
+	}
+
+	rb_link_node(node, parent, p);
+	return 0;
+}
+
+static void erase_entry(struct ctl_table_header *head, struct ctl_table *entry)
+{
+	struct rb_node *node = &head->node[entry - head->ctl_table].node;
+
+	rb_erase(node, &head->parent->root);
+}
+
 static void init_header(struct ctl_table_header *head,
 	struct ctl_table_root *root, struct ctl_table_set *set,
-	struct ctl_table *table)
+	struct ctl_node *node, struct ctl_table *table)
 {
 	head->ctl_table = table;
 	head->ctl_table_arg = table;
-	INIT_LIST_HEAD(&head->ctl_entry);
 	head->used = 0;
 	head->count = 1;
 	head->nreg = 1;
@@ -110,28 +162,42 @@ static void init_header(struct ctl_table_header *head,
 	head->root = root;
 	head->set = set;
 	head->parent = NULL;
+	head->node = node;
+	if (node) {
+		struct ctl_table *entry;
+		for (entry = table; entry->procname; entry++, node++) {
+			rb_init_node(&node->node);
+			node->header = head;
+		}
+	}
 }
 
 static void erase_header(struct ctl_table_header *head)
 {
-	list_del_init(&head->ctl_entry);
+	struct ctl_table *entry;
+	for (entry = head->ctl_table; entry->procname; entry++)
+		erase_entry(head, entry);
 }
 
 static int insert_header(struct ctl_dir *dir, struct ctl_table_header *header)
 {
+	struct ctl_table *entry;
 	int err;
 
-	err = sysctl_check_dups(dir, header->ctl_table);
-	if (err)
-		return err;
-
 	dir->header.nreg++;
 	header->parent = dir;
 	err = insert_links(header);
 	if (err)
 		goto fail_links;
-	list_add_tail(&header->ctl_entry, &header->parent->list);
+	for (entry = header->ctl_table; entry->procname; entry++) {
+		err = insert_entry(header, entry);
+		if (err)
+			goto fail;
+	}
 	return 0;
+fail:
+	erase_header(header);
+	put_links(header);
 fail_links:
 	header->parent = NULL;
 	drop_sysctl_table(&dir->header);
@@ -241,19 +307,14 @@ static struct ctl_table *lookup_entry(struct ctl_table_header **phead,
 	return entry;
 }
 
-static struct ctl_table_header *next_usable_entry(struct ctl_dir *dir,
-						  struct list_head *tmp)
+static struct ctl_node *first_usable_entry(struct rb_node *node)
 {
-	struct ctl_table_header *head;
-
-	for (tmp = tmp->next; tmp != &dir->list; tmp = tmp->next) {
-		head = list_entry(tmp, struct ctl_table_header, ctl_entry);
+	struct ctl_node *ctl_node;
 
-		if (!head->ctl_table->procname ||
-		    !use_table(head))
-			continue;
-
-		return head;
+	for (;node; node = rb_next(node)) {
+		ctl_node = rb_entry(node, struct ctl_node, node);
+		if (use_table(ctl_node->header))
+			return ctl_node;
 	}
 	return NULL;
 }
@@ -261,14 +322,17 @@ static struct ctl_table_header *next_usable_entry(struct ctl_dir *dir,
 static void first_entry(struct ctl_dir *dir,
 	struct ctl_table_header **phead, struct ctl_table **pentry)
 {
-	struct ctl_table_header *head;
+	struct ctl_table_header *head = NULL;
 	struct ctl_table *entry = NULL;
+	struct ctl_node *ctl_node;
 
 	spin_lock(&sysctl_lock);
-	head = next_usable_entry(dir, &dir->list);
+	ctl_node = first_usable_entry(rb_first(&dir->root));
 	spin_unlock(&sysctl_lock);
-	if (head)
-		entry = head->ctl_table;
+	if (ctl_node) {
+		head = ctl_node->header;
+		entry = &head->ctl_table[ctl_node - head->node];
+	}
 	*phead = head;
 	*pentry = entry;
 }
@@ -277,15 +341,17 @@ static void next_entry(struct ctl_table_header **phead, struct ctl_table **pentr
 {
 	struct ctl_table_header *head = *phead;
 	struct ctl_table *entry = *pentry;
+	struct ctl_node *ctl_node = &head->node[entry - head->ctl_table];
 
-	entry++;
-	if (!entry->procname) {
-		spin_lock(&sysctl_lock);
-		unuse_table(head);
-		head = next_usable_entry(head->parent, &head->ctl_entry);
-		spin_unlock(&sysctl_lock);
-		if (head)
-			entry = head->ctl_table;
+	spin_lock(&sysctl_lock);
+	unuse_table(head);
+
+	ctl_node = first_usable_entry(rb_next(&ctl_node->node));
+	spin_unlock(&sysctl_lock);
+	head = NULL;
+	if (ctl_node) {
+		head = ctl_node->header;
+		entry = &head->ctl_table[ctl_node - head->node];
 	}
 	*phead = head;
 	*pentry = entry;
@@ -777,21 +843,23 @@ static struct ctl_dir *new_dir(struct ctl_table_set *set,
 {
 	struct ctl_table *table;
 	struct ctl_dir *new;
+	struct ctl_node *node;
 	char *new_name;
 
-	new = kzalloc(sizeof(*new) + sizeof(struct ctl_table)*2 +
-		      namelen + 1, GFP_KERNEL);
+	new = kzalloc(sizeof(*new) + sizeof(struct ctl_node) +
+		      sizeof(struct ctl_table)*2 +  namelen + 1,
+		      GFP_KERNEL);
 	if (!new)
 		return NULL;
 
-	table = (struct ctl_table *)(new + 1);
+	node = (struct ctl_node *)(new + 1);
+	table = (struct ctl_table *)(node + 1);
 	new_name = (char *)(table + 2);
 	memcpy(new_name, name, namelen);
 	new_name[namelen] = '\0';
-	INIT_LIST_HEAD(&new->list);
 	table[0].procname = new_name;
 	table[0].mode = S_IFDIR|S_IRUGO|S_IXUGO;
-	init_header(&new->header, set->dir.header.root, set, table);
+	init_header(&new->header, set->dir.header.root, set, node, table);
 
 	return new;
 }
@@ -892,40 +960,6 @@ static int sysctl_follow_link(struct ctl_table_header **phead,
 	return ret;
 }
 
-static int sysctl_check_table_dups(struct ctl_dir *dir, struct ctl_table *old,
-	struct ctl_table *table)
-{
-	struct ctl_table *entry, *test;
-	int error = 0;
-
-	for (entry = old; entry->procname; entry++) {
-		for (test = table; test->procname; test++) {
-			if (strcmp(entry->procname, test->procname) == 0) {
-				printk(KERN_ERR "sysctl duplicate entry: ");
-				sysctl_print_dir(dir);
-				printk(KERN_CONT "/%s\n", test->procname);
-				error = -EEXIST;
-			}
-		}
-	}
-	return error;
-}
-
-static int sysctl_check_dups(struct ctl_dir *dir, struct ctl_table *table)
-{
-	struct ctl_table_header *head;
-	int error = 0;
-
-	list_for_each_entry(head, &dir->list, ctl_entry) {
-		if (head->unregistering)
-			continue;
-		if (head->parent != dir)
-			continue;
-		error = sysctl_check_table_dups(dir, head->ctl_table, table);
-	}
-	return error;
-}
-
 static int sysctl_err(const char *path, struct ctl_table *table, char *fmt, ...)
 {
 	struct va_format vaf;
@@ -977,6 +1011,7 @@ static struct ctl_table_header *new_links(struct ctl_dir *dir, struct ctl_table
 {
 	struct ctl_table *link_table, *entry, *link;
 	struct ctl_table_header *links;
+	struct ctl_node *node;
 	char *link_name;
 	int nr_entries, name_bytes;
 
@@ -988,6 +1023,7 @@ static struct ctl_table_header *new_links(struct ctl_dir *dir, struct ctl_table
 	}
 
 	links = kzalloc(sizeof(struct ctl_table_header) +
+			sizeof(struct ctl_node)*nr_entries +
 			sizeof(struct ctl_table)*(nr_entries + 1) +
 			name_bytes,
 			GFP_KERNEL);
@@ -995,7 +1031,8 @@ static struct ctl_table_header *new_links(struct ctl_dir *dir, struct ctl_table
 	if (!links)
 		return NULL;
 
-	link_table = (struct ctl_table *)(links + 1);
+	node = (struct ctl_node *)(links + 1);
+	link_table = (struct ctl_table *)(node + nr_entries);
 	link_name = (char *)&link_table[nr_entries + 1];
 
 	for (link = link_table, entry = table; entry->procname; link++, entry++) {
@@ -1006,7 +1043,7 @@ static struct ctl_table_header *new_links(struct ctl_dir *dir, struct ctl_table
 		link->data = link_root;
 		link_name += len;
 	}
-	init_header(links, dir->header.root, dir->header.set, link_table);
+	init_header(links, dir->header.root, dir->header.set, node, link_table);
 	links->nreg = nr_entries;
 
 	return links;
@@ -1132,12 +1169,20 @@ struct ctl_table_header *__register_sysctl_table(
 	struct ctl_table_header *header;
 	const char *name, *nextname;
 	struct ctl_dir *dir;
+	struct ctl_table *entry;
+	struct ctl_node *node;
+	int nr_entries = 0;
+
+	for (entry = table; entry->procname; entry++)
+		nr_entries++;
 
-	header = kzalloc(sizeof(struct ctl_table_header), GFP_KERNEL);
+	header = kzalloc(sizeof(struct ctl_table_header) +
+			 sizeof(struct ctl_node)*nr_entries, GFP_KERNEL);
 	if (!header)
 		return NULL;
 
-	init_header(header, root, set, table);
+	node = (struct ctl_node *)(header + 1);
+	init_header(header, root, set, node, table);
 	if (sysctl_check_table(path, table))
 		goto fail;
 
@@ -1489,13 +1534,12 @@ void setup_sysctl_set(struct ctl_table_set *set,
 {
 	memset(set, sizeof(*set), 0);
 	set->is_seen = is_seen;
-	INIT_LIST_HEAD(&set->dir.list);
-	init_header(&set->dir.header, root, set, root_table);
+	init_header(&set->dir.header, root, set, NULL, root_table);
 }
 
 void retire_sysctl_set(struct ctl_table_set *set)
 {
-	WARN_ON(!list_empty(&set->dir.list));
+	WARN_ON(!RB_EMPTY_ROOT(&set->dir.root));
 }
 
 int __init proc_sys_init(void)
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 36dec75..35c50ed 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -932,6 +932,7 @@ enum
 #include <linux/list.h>
 #include <linux/rcupdate.h>
 #include <linux/wait.h>
+#include <linux/rbtree.h>
 
 /* For the /proc/sys support */
 struct ctl_table;
@@ -1023,6 +1024,11 @@ struct ctl_table
 	void *extra2;
 };
 
+struct ctl_node {
+	struct rb_node node;
+	struct ctl_table_header *header;
+};
+
 /* struct ctl_table_header is used to maintain dynamic lists of
    struct ctl_table trees. */
 struct ctl_table_header
@@ -1030,7 +1036,6 @@ struct ctl_table_header
 	union {
 		struct {
 			struct ctl_table *ctl_table;
-			struct list_head ctl_entry;
 			int used;
 			int count;
 			int nreg;
@@ -1042,12 +1047,13 @@ struct ctl_table_header
 	struct ctl_table_root *root;
 	struct ctl_table_set *set;
 	struct ctl_dir *parent;
+	struct ctl_node *node;
 };
 
 struct ctl_dir {
 	/* Header must be at the start of ctl_dir */
 	struct ctl_table_header header;
-	struct list_head list;
+	struct rb_root root;
 };
 
 struct ctl_table_set {
-- 
1.7.2.5
