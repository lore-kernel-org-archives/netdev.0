From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 20/29] sysctl: Rewrite proc_sys_readdir in terms of first_entry and next_entry
Date: Thu, 26 Jan 2012 20:51:56 -0800
Message-ID: <1327639925-12920-20-git-send-email-ebiederm@xmission.com>
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

Replace sysctl_head_next with first_entry and next_entry.  These new
iterators operate at the level of sysctl table entries and filter
out any sysctl tables that should not be shown.

Utilizing two specialized functions instead of a single function removes
conditionals for handling awkward special cases that only come up
at the beginning of iteration, making the iterators easier to read
and understand.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/proc/proc_sysctl.c |   98 +++++++++++++++++++++++++++++++------------------
 1 files changed, 62 insertions(+), 36 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index 3b63f29..d9c3ae6 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -243,31 +243,25 @@ static struct ctl_table *lookup_entry(struct ctl_table_header **phead,
 	return entry;
 }
 
-static struct ctl_table_header *__sysctl_head_next(struct nsproxy *namespaces,
-						struct ctl_table_header *prev)
+static struct ctl_table_header *next_usable_entry(struct ctl_table *dir,
+	struct ctl_table_root *root, struct list_head *tmp)
 {
-	struct ctl_table_root *root;
+	struct nsproxy *namespaces = current->nsproxy;
 	struct list_head *header_list;
 	struct ctl_table_header *head;
-	struct list_head *tmp;
 
-	spin_lock(&sysctl_lock);
-	if (prev) {
-		head = prev;
-		tmp = &prev->ctl_entry;
-		unuse_table(prev);
-		goto next;
-	}
-	tmp = &root_table_header.ctl_entry;
+	goto next;
 	for (;;) {
 		head = list_entry(tmp, struct ctl_table_header, ctl_entry);
+		root = head->root;
 
-		if (!use_table(head))
+		if (head->attached_to != dir ||
+		    !head->attached_by->procname ||
+		    !use_table(head))
 			goto next;
-		spin_unlock(&sysctl_lock);
+
 		return head;
 	next:
-		root = head->root;
 		tmp = tmp->next;
 		header_list = lookup_header_list(root, namespaces);
 		if (tmp != header_list)
@@ -283,13 +277,53 @@ static struct ctl_table_header *__sysctl_head_next(struct nsproxy *namespaces,
 		tmp = header_list->next;
 	}
 out:
-	spin_unlock(&sysctl_lock);
 	return NULL;
 }
 
-static struct ctl_table_header *sysctl_head_next(struct ctl_table_header *prev)
+static void first_entry(
+	struct ctl_table_header *dir_head, struct ctl_table *dir,
+	struct ctl_table_header **phead, struct ctl_table **pentry)
 {
-	return __sysctl_head_next(current->nsproxy, prev);
+	struct ctl_table_header *head = dir_head;
+	struct ctl_table *entry = dir;
+
+	spin_lock(&sysctl_lock);
+	if (entry->procname) {
+		use_table(head);
+	} else {
+		head = next_usable_entry(dir, &sysctl_table_root,
+					 &sysctl_table_root.default_set.list);
+		if (head)
+			entry = head->attached_by;
+	}
+	spin_unlock(&sysctl_lock);
+	*phead = head;
+	*pentry = entry;
+}
+
+static void next_entry(struct ctl_table *dir,
+	struct ctl_table_header **phead, struct ctl_table **pentry)
+{
+	struct ctl_table_header *head = *phead;
+	struct ctl_table *entry = *pentry;
+
+	entry++;
+	if (!entry->procname) {
+		struct ctl_table_root *root = head->root;
+		struct list_head *tmp = &head->ctl_entry;
+		if (head->attached_to != dir) {
+			root = &sysctl_table_root;
+			tmp = &sysctl_table_root.default_set.list;
+		}
+		spin_lock(&sysctl_lock);
+		unuse_table(head);
+		head = next_usable_entry(dir, root, tmp);
+		spin_unlock(&sysctl_lock);
+		if (head)
+			entry = head->attached_by;
+	}
+	*phead = head;
+	*pentry = entry;
 }
 
 void register_sysctl_root(struct ctl_table_root *root)
@@ -533,20 +567,17 @@ static int scan(struct ctl_table_header *head, ctl_table *table,
 		unsigned long *pos, struct file *file,
 		void *dirent, filldir_t filldir)
 {
+	int res;
 
-	for (; table->procname; table++, (*pos)++) {
-		int res;
+	if ((*pos)++ < file->f_pos)
+		return 0;
 
-		if (*pos < file->f_pos)
-			continue;
+	res = proc_sys_fill_cache(file, dirent, filldir, head, table);
 
-		res = proc_sys_fill_cache(file, dirent, filldir, head, table);
-		if (res)
-			return res;
+	if (res == 0)
+		file->f_pos = *pos;
 
-		file->f_pos = *pos + 1;
-	}
-	return 0;
+	return res;
 }
 
 static int proc_sys_readdir(struct file *filp, void *dirent, filldir_t filldir)
@@ -556,6 +587,7 @@ static int proc_sys_readdir(struct file *filp, void *dirent, filldir_t filldir)
 	struct ctl_table_header *head = grab_header(inode);
 	struct ctl_table *table = PROC_I(inode)->sysctl_entry;
 	struct ctl_table_header *h = NULL;
+	struct ctl_table *entry;
 	unsigned long pos;
 	int ret = -EINVAL;
 
@@ -585,14 +617,8 @@ static int proc_sys_readdir(struct file *filp, void *dirent, filldir_t filldir)
 	}
 	pos = 2;
 
-	ret = scan(head, table, &pos, filp, dirent, filldir);
-	if (ret)
-		goto out;
-
-	for (h = sysctl_head_next(NULL); h; h = sysctl_head_next(h)) {
-		if (h->attached_to != table)
-			continue;
-		ret = scan(h, h->attached_by, &pos, filp, dirent, filldir);
+	for (first_entry(head, table, &h, &entry); h; next_entry(table, &h, &entry)) {
+		ret = scan(h, entry, &pos, filp, dirent, filldir);
 		if (ret) {
 			sysctl_head_finish(h);
 			break;
-- 
1.7.2.5
