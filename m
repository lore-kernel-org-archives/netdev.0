From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 12/29] sysctl: Improve the sysctl sanity checks
Date: Thu, 26 Jan 2012 20:49:53 -0800
Message-ID: <1327639810-12760-12-git-send-email-ebiederm@xmission.com>
References: <m1pqe5ah3z.fsf@fess.ebiederm.org>
Cc: <linux-fsdevel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Damien Millescamps <damien.millescamps@6wind.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1pqe5ah3z.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- Stop validating subdirectories now that we only register leaf tables

- Cleanup and improve the duplicate filename check.
  * Run the duplicate filename check under the sysctl_lock to guarantee
    we never add duplicate names.
  * Reduce the duplicate filename check to nearly O(M*N) where M is the
    number of entries in tthe table we are registering and N is the
    number of entries in the directory before we got there.

- Move the duplicate filename check into it's own function and call
  it directtly from __register_sysctl_table

- Kill the config option as the sanity checks are now cheap enough
  the config option is unnecessary. The original reason for the config
  option was because we had a huge table used to verify the proc filename
  to binary sysctl mapping.  That table has now evolved into the binary_sysctl
  translation layer and is no longer part of the sysctl_check code.

- Tighten up the permission checks.  Guarnateeing that files only have read
  or write permissions.

- Removed redudant check for parents having a procname as now everything has
  a procname.

- Generalize the backtrace logic so that we print a backtrace from
  any failure of __register_sysctl_table that was not caused by
  a memmory allocation failure.  The backtrace allows us to track
  down who erroneously registered a sysctl table.

Bechmark before (CONFIG_SYSCTL_CHECK=y):
    make-dummies 0 999 -> 12s
    rmmod dummy        -> 0.08s

Bechmark before (CONFIG_SYSCTL_CHECK=n):
    make-dummies 0 999 -> 0.7s
    rmmod dummy        -> 0.06s
    make-dummies 0 99999 -> 1m13s
    rmmod dummy          -> 0.38s

Benchmark after:
    make-dummies 0 999 -> 0.65s
    rmmod dummy        -> 0.055s
    make-dummies 0 9999 -> 1m10s
    rmmod dummy         -> 0.39s

The sysctl sanity checks now impose no measurable cost.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/proc/proc_sysctl.c |  222 +++++++++++++++++++------------------------------
 lib/Kconfig.debug     |    8 --
 2 files changed, 86 insertions(+), 144 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index 6bab2ae..a492ff6 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -726,160 +726,106 @@ static void try_attach(struct ctl_table_header *p, struct ctl_table_header *q)
 	}
 }
 
-#ifdef CONFIG_SYSCTL_SYSCALL_CHECK
-static int sysctl_depth(struct ctl_table *table)
+static int sysctl_check_table_dups(const char *path, struct ctl_table *old,
+	struct ctl_table *table)
 {
-	struct ctl_table *tmp;
-	int depth;
-
-	depth = 0;
-	for (tmp = table; tmp->parent; tmp = tmp->parent)
-		depth++;
+	struct ctl_table *entry, *test;
+	int error = 0;
 
-	return depth;
+	for (entry = old; entry->procname; entry++) {
+		for (test = table; test->procname; test++) {
+			if (strcmp(entry->procname, test->procname) == 0) {
+				printk(KERN_ERR "sysctl duplicate entry: %s/%s\n",
+					path, test->procname);
+				error = -EEXIST;
+			}
+		}
+	}
+	return error;
 }
 
-static struct ctl_table *sysctl_parent(struct ctl_table *table, int n)
+static int sysctl_check_dups(struct nsproxy *namespaces,
+	struct ctl_table_header *header,
+	const char *path, struct ctl_table *table)
 {
-	int i;
+	struct ctl_table_root *root;
+	struct ctl_table_set *set;
+	struct ctl_table_header *dir_head, *head;
+	struct ctl_table *dir_table;
+	int error = 0;
 
-	for (i = 0; table && i < n; i++)
-		table = table->parent;
+	/* No dups if we are the only member of our directory */
+	if (header->attached_by != table)
+		return 0;
 
-	return table;
-}
+	dir_head = header->parent;
+	dir_table = header->attached_to;
 
+	error = sysctl_check_table_dups(path, dir_table, table);
 
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
+	root = &sysctl_table_root;
+	do {
+		set = lookup_header_set(root, namespaces);
 
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
+		list_for_each_entry(head, &set->list, ctl_entry) {
+			if (head->unregistering)
 				continue;
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
+			if (head->attached_to != dir_table)
+				continue;
+			error = sysctl_check_table_dups(path, head->attached_by,
+							table);
 		}
-	}
-	ref = NULL;
-out:
-	sysctl_head_finish(head);
-	return ref;
+		root = list_entry(root->root_list.next,
+				  struct ctl_table_root, root_list);
+	} while (root != &sysctl_table_root);
+	return error;
 }
 
-static void set_fail(const char **fail, struct ctl_table *table, const char *str)
+static int sysctl_err(const char *path, struct ctl_table *table, char *fmt, ...)
 {
-	if (*fail) {
-		printk(KERN_ERR "sysctl table check failed: ");
-		sysctl_print_path(table);
-		printk(" %s\n", *fail);
-		dump_stack();
-	}
-	*fail = str;
-}
+	struct va_format vaf;
+	va_list args;
 
-static void sysctl_check_leaf(struct nsproxy *namespaces,
-				struct ctl_table *table, const char **fail)
-{
-	struct ctl_table *ref;
+	va_start(args, fmt);
+	vaf.fmt = fmt;
+	vaf.va = &args;
+
+	printk(KERN_ERR "sysctl table check failed: %s/%s %pV\n",
+		path, table->procname, &vaf);
 
-	ref = sysctl_check_lookup(namespaces, table);
-	if (ref && (ref != table))
-		set_fail(fail, table, "Sysctl already exists");
+	va_end(args);
+	return -EINVAL;
 }
 
-static int sysctl_check_table(struct nsproxy *namespaces, struct ctl_table *table)
+static int sysctl_check_table(const char *path, struct ctl_table *table)
 {
-	int error = 0;
+	int err = 0;
 	for (; table->procname; table++) {
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
 		if (table->child)
-			error |= sysctl_check_table(namespaces, table->child);
+			err = sysctl_err(path, table, "Not a file");
+
+		if ((table->proc_handler == proc_dostring) ||
+		    (table->proc_handler == proc_dointvec) ||
+		    (table->proc_handler == proc_dointvec_minmax) ||
+		    (table->proc_handler == proc_dointvec_jiffies) ||
+		    (table->proc_handler == proc_dointvec_userhz_jiffies) ||
+		    (table->proc_handler == proc_dointvec_ms_jiffies) ||
+		    (table->proc_handler == proc_doulongvec_minmax) ||
+		    (table->proc_handler == proc_doulongvec_ms_jiffies_minmax)) {
+			if (!table->data)
+				err = sysctl_err(path, table, "No data");
+			if (!table->maxlen)
+				err = sysctl_err(path, table, "No maxlen");
+		}
+		if (!table->proc_handler)
+			err = sysctl_err(path, table, "No proc_handler");
+
+		if ((table->mode & (S_IRUGO|S_IWUGO)) != table->mode)
+			err = sysctl_err(path, table, "bogus .mode 0%o",
+				table->mode);
 	}
-	return error;
+	return err;
 }
-#endif /* CONFIG_SYSCTL_SYSCALL_CHECK */
 
 /**
  * __register_sysctl_table - register a leaf sysctl table
@@ -1003,12 +949,8 @@ struct ctl_table_header *__register_sysctl_table(
 	header->root = root;
 	sysctl_set_parent(NULL, header->ctl_table);
 	header->count = 1;
-#ifdef CONFIG_SYSCTL_SYSCALL_CHECK
-	if (sysctl_check_table(namespaces, header->ctl_table)) {
-		kfree(header);
-		return NULL;
-	}
-#endif
+	if (sysctl_check_table(path, table))
+		goto fail;
 	spin_lock(&sysctl_lock);
 	header->set = lookup_header_set(root, namespaces);
 	header->attached_by = header->ctl_table;
@@ -1029,11 +971,19 @@ struct ctl_table_header *__register_sysctl_table(
 				  struct ctl_table_root, root_list);
 		set = lookup_header_set(root, namespaces);
 	}
+	if (sysctl_check_dups(namespaces, header, path, table))
+		goto fail_locked;
 	header->parent->count++;
 	list_add_tail(&header->ctl_entry, &header->set->list);
 	spin_unlock(&sysctl_lock);
 
 	return header;
+fail_locked:
+	spin_unlock(&sysctl_lock);
+fail:
+	kfree(header);
+	dump_stack();
+	return NULL;
 }
 
 static char *append_path(const char *path, char *pos, const char *name)
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 8745ac7..943a618 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1113,14 +1113,6 @@ config LATENCYTOP
 	  Enable this option if you want to use the LatencyTOP tool
 	  to find out which userspace is blocking on what kernel operations.
 
-config SYSCTL_SYSCALL_CHECK
-	bool "Sysctl checks"
-	depends on SYSCTL
-	---help---
-	  sys_sysctl uses binary paths that have been found challenging
-	  to properly maintain and use. This enables checks that help
-	  you to keep things correct.
-
 source mm/Kconfig.debug
 source kernel/trace/Kconfig
 
-- 
1.7.2.5
