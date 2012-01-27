From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 27/29] sysctl: Make the header lists per directory.
Date: Thu, 26 Jan 2012 20:50:08 -0800
Message-ID: <1327639810-12760-27-git-send-email-ebiederm@xmission.com>
References: <m1pqe5ah3z.fsf@fess.ebiederm.org>
Cc: <linux-fsdevel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Damien Millescamps <damien.millescamps@6wind.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1pqe5ah3z.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Slightly enhance efficiency and clarity of the code by making the
header list per directory instead of per set.

Benchmark before:
    make-dummies 0 999 -> 0.63s
    rmmod dummy        -> 0.12s
    make-dummies 0 9999 -> 2m35s
    rmmod dummy         -> 18s

Benchmark after:
    make-dummies 0 999 -> 0.32s
    rmmod dummy        -> 0.12s
    make-dummies 0 9999 -> 1m17s
    rmmod dummy         -> 17s

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/proc/proc_sysctl.c  |   28 +++++++++++-----------------
 include/linux/sysctl.h |    2 +-
 2 files changed, 12 insertions(+), 18 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index 160d578..e971ccc 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -33,12 +33,12 @@ static struct ctl_table root_table[] = {
 	{ }
 };
 static struct ctl_table_root sysctl_table_root = {
-	.default_set.list = LIST_HEAD_INIT(sysctl_table_root.default_set.dir.header.ctl_entry),
+	.default_set.dir.list = LIST_HEAD_INIT(sysctl_table_root.default_set.dir.list),
 	.default_set.dir.header = {
 		{{.count = 1,
 		  .nreg = 1,
 		  .ctl_table = root_table,
-		  .ctl_entry = LIST_HEAD_INIT(sysctl_table_root.default_set.list),}},
+		  .ctl_entry = LIST_HEAD_INIT(sysctl_table_root.default_set.dir.header.ctl_entry),}},
 		.ctl_table_arg = root_table,
 		.root = &sysctl_table_root,
 		.set = &sysctl_table_root.default_set,
@@ -79,15 +79,12 @@ static int namecmp(const char *name1, int len1, const char *name2, int len2)
 static struct ctl_table *find_entry(struct ctl_table_header **phead,
 	struct ctl_dir *dir, const char *name, int namelen)
 {
-	struct ctl_table_set *set = dir->header.set;
 	struct ctl_table_header *head;
 	struct ctl_table *entry;
 
-	list_for_each_entry(head, &set->list, ctl_entry) {
+	list_for_each_entry(head, &dir->list, ctl_entry) {
 		if (head->unregistering)
 			continue;
-		if (head->parent != dir)
-			continue;
 		for (entry = head->ctl_table; entry->procname; entry++) {
 			const char *procname = entry->procname;
 			if (namecmp(procname, strlen(procname), name, namelen) == 0) {
@@ -133,7 +130,7 @@ static int insert_header(struct ctl_dir *dir, struct ctl_table_header *header)
 	err = insert_links(header);
 	if (err)
 		goto fail_links;
-	list_add_tail(&header->ctl_entry, &header->set->list);
+	list_add_tail(&header->ctl_entry, &header->parent->list);
 	return 0;
 fail_links:
 	header->parent = NULL;
@@ -247,14 +244,12 @@ static struct ctl_table *lookup_entry(struct ctl_table_header **phead,
 static struct ctl_table_header *next_usable_entry(struct ctl_dir *dir,
 						  struct list_head *tmp)
 {
-	struct ctl_table_set *set = dir->header.set;
 	struct ctl_table_header *head;
 
-	for (tmp = tmp->next; tmp != &set->list; tmp = tmp->next) {
+	for (tmp = tmp->next; tmp != &dir->list; tmp = tmp->next) {
 		head = list_entry(tmp, struct ctl_table_header, ctl_entry);
 
-		if (head->parent != dir ||
-		    !head->ctl_table->procname ||
+		if (!head->ctl_table->procname ||
 		    !use_table(head))
 			continue;
 
@@ -270,7 +265,7 @@ static void first_entry(struct ctl_dir *dir,
 	struct ctl_table *entry = NULL;
 
 	spin_lock(&sysctl_lock);
-	head = next_usable_entry(dir, &dir->header.set->list);
+	head = next_usable_entry(dir, &dir->list);
 	spin_unlock(&sysctl_lock);
 	if (head)
 		entry = head->ctl_table;
@@ -793,6 +788,7 @@ static struct ctl_dir *new_dir(struct ctl_table_set *set,
 	new_name = (char *)(table + 2);
 	memcpy(new_name, name, namelen);
 	new_name[namelen] = '\0';
+	INIT_LIST_HEAD(&new->list);
 	table[0].procname = new_name;
 	table[0].mode = S_IFDIR|S_IRUGO|S_IXUGO;
 	init_header(&new->header, set->dir.header.root, set, table);
@@ -917,12 +913,10 @@ static int sysctl_check_table_dups(struct ctl_dir *dir, struct ctl_table *old,
 
 static int sysctl_check_dups(struct ctl_dir *dir, struct ctl_table *table)
 {
-	struct ctl_table_set *set;
 	struct ctl_table_header *head;
 	int error = 0;
 
-	set = dir->header.set;
-	list_for_each_entry(head, &set->list, ctl_entry) {
+	list_for_each_entry(head, &dir->list, ctl_entry) {
 		if (head->unregistering)
 			continue;
 		if (head->parent != dir)
@@ -1494,14 +1488,14 @@ void setup_sysctl_set(struct ctl_table_set *set,
 	int (*is_seen)(struct ctl_table_set *))
 {
 	memset(set, sizeof(*set), 0);
-	INIT_LIST_HEAD(&set->list);
 	set->is_seen = is_seen;
+	INIT_LIST_HEAD(&set->dir.list);
 	init_header(&set->dir.header, root, set, root_table);
 }
 
 void retire_sysctl_set(struct ctl_table_set *set)
 {
-	WARN_ON(!list_empty(&set->list));
+	WARN_ON(!list_empty(&set->dir.list));
 }
 
 int __init proc_sys_init(void)
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index cec5941..36dec75 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -1047,10 +1047,10 @@ struct ctl_table_header
 struct ctl_dir {
 	/* Header must be at the start of ctl_dir */
 	struct ctl_table_header header;
+	struct list_head list;
 };
 
 struct ctl_table_set {
-	struct list_head list;
 	int (*is_seen)(struct ctl_table_set *);
 	struct ctl_dir dir;
 };
-- 
1.7.2.5
