From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 11/29] sysctl: register only tables of sysctl files
Date: Thu, 26 Jan 2012 20:49:52 -0800
Message-ID: <1327639810-12760-11-git-send-email-ebiederm@xmission.com>
References: <m1pqe5ah3z.fsf@fess.ebiederm.org>
Cc: <linux-fsdevel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Damien Millescamps <damien.millescamps@6wind.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1pqe5ah3z.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Split the registration of a complex ctl_table array which may have
arbitrary numbers of directories (->child != NULL) and tables of files
into a series of simpler registrations that only register tables of files.

Graphically:

   register('dir', { + file-a
                     + file-b
                     + subdir1
                       + file-c
                     + subdir2
                       + file-d
                       + file-e })

is transformed into:
   wrapper->subheaders[0] = register('dir', {file1-a, file1-b})
   wrapper->subheaders[1] = register('dir/subdir1', {file-c})
   wrapper->subheaders[2] = register('dir/subdir2', {file-d, file-e})
   return wrapper

This guarantees that __register_sysctl_table will only see a simple
ctl_table array with all entries having (->child == NULL).

Care was taken to pass the original simple ctl_table arrays to
__register_sysctl_table whenever possible.

This change is derived from a similar patch written
by Lucrian Grijincu.

Inspired-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/proc/proc_sysctl.c  |  165 ++++++++++++++++++++++++++++++++++++++++++-----
 include/linux/sysctl.h |    2 +-
 2 files changed, 148 insertions(+), 19 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index 9b91dee..6bab2ae 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -882,7 +882,7 @@ static int sysctl_check_table(struct nsproxy *namespaces, struct ctl_table *tabl
 #endif /* CONFIG_SYSCTL_SYSCALL_CHECK */
 
 /**
- * __register_sysctl_table - register a sysctl table
+ * __register_sysctl_table - register a leaf sysctl table
  * @root: List of sysctl headers to register on
  * @namespaces: Data to compute which lists of sysctl entries are visible
  * @path: The path to the directory the sysctl table is in.
@@ -900,29 +900,19 @@ static int sysctl_check_table(struct nsproxy *namespaces, struct ctl_table *tabl
  *
  * maxlen - the maximum size in bytes of the data
  *
- * mode - the file permissions for the /proc/sys file, and for sysctl(2)
+ * mode - the file permissions for the /proc/sys file
  *
- * child - a pointer to the child sysctl table if this entry is a directory, or
- *         %NULL.
+ * child - must be %NULL.
  *
  * proc_handler - the text handler routine (described below)
  *
- * de - for internal use by the sysctl routines
- *
  * extra1, extra2 - extra pointers usable by the proc handler routines
  *
  * Leaf nodes in the sysctl tree will be represented by a single file
  * under /proc; non-leaf nodes will be represented by directories.
  *
- * sysctl(2) can automatically manage read and write requests through
- * the sysctl table.  The data and maxlen fields of the ctl_table
- * struct enable minimal validation of the values being written to be
- * performed, and the mode field allows minimal authentication.
- *
- * There must be a proc_handler routine for any terminal nodes
- * mirrored under /proc/sys (non-terminals are handled by a built-in
- * directory handler).  Several default handlers are available to
- * cover common cases -
+ * There must be a proc_handler routine for any terminal nodes.
+ * Several default handlers are available to cover common cases -
  *
  * proc_dostring(), proc_dointvec(), proc_dointvec_jiffies(),
  * proc_dointvec_userhz_jiffies(), proc_dointvec_minmax(),
@@ -1059,6 +1049,100 @@ static char *append_path(const char *path, char *pos, const char *name)
 	return pos;
 }
 
+static int count_subheaders(struct ctl_table *table)
+{
+	int has_files = 0;
+	int nr_subheaders = 0;
+	struct ctl_table *entry;
+
+	/* special case: no directory and empty directory */
+	if (!table || !table->procname)
+		return 1;
+
+	for (entry = table; entry->procname; entry++) {
+		if (entry->child)
+			nr_subheaders += count_subheaders(entry->child);
+		else
+			has_files = 1;
+	}
+	return nr_subheaders + has_files;
+}
+
+static int register_leaf_sysctl_tables(const char *path, char *pos,
+	struct ctl_table_header ***subheader,
+	struct ctl_table_root *root, struct nsproxy *namespaces,
+	struct ctl_table *table)
+{
+	struct ctl_table *ctl_table_arg = NULL;
+	struct ctl_table *entry, *files;
+	int nr_files = 0;
+	int nr_dirs = 0;
+	int err = -ENOMEM;
+
+	for (entry = table; entry->procname; entry++) {
+		if (entry->child)
+			nr_dirs++;
+		else
+			nr_files++;
+	}
+
+	files = table;
+	/* If there are mixed files and directories we need a new table */
+	if (nr_dirs && nr_files) {
+		struct ctl_table *new;
+		files = kzalloc(sizeof(struct ctl_table) * (nr_files + 1),
+				GFP_KERNEL);
+		if (!files)
+			goto out;
+
+		ctl_table_arg = files;
+		for (new = files, entry = table; entry->procname; entry++) {
+			if (entry->child)
+				continue;
+			*new = *entry;
+			new++;
+		}
+	}
+
+	/* Register everything except a directory full of subdirectories */
+	if (nr_files || !nr_dirs) {
+		struct ctl_table_header *header;
+		header = __register_sysctl_table(root, namespaces, path, files);
+		if (!header) {
+			kfree(ctl_table_arg);
+			goto out;
+		}
+
+		/* Remember if we need to free the file table */
+		header->ctl_table_arg = ctl_table_arg;
+		**subheader = header;
+		(*subheader)++;
+	}
+
+	/* Recurse into the subdirectories. */
+	for (entry = table; entry->procname; entry++) {
+		char *child_pos;
+
+		if (!entry->child)
+			continue;
+
+		err = -ENAMETOOLONG;
+		child_pos = append_path(path, pos, entry->procname);
+		if (!child_pos)
+			goto out;
+
+		err = register_leaf_sysctl_tables(path, child_pos, subheader,
+						  root, namespaces, entry->child);
+		pos[0] = '\0';
+		if (err)
+			goto out;
+	}
+	err = 0;
+out:
+	/* On failure our caller will unregister all registered subheaders */
+	return err;
+}
+
 /**
  * __register_sysctl_paths - register a sysctl table hierarchy
  * @root: List of sysctl headers to register on
@@ -1077,7 +1161,8 @@ struct ctl_table_header *__register_sysctl_paths(
 	const struct ctl_path *path, struct ctl_table *table)
 {
 	struct ctl_table *ctl_table_arg = table;
-	struct ctl_table_header *header = NULL;
+	int nr_subheaders = count_subheaders(table);
+	struct ctl_table_header *header = NULL, **subheaders, **subheader;
 	const struct ctl_path *component;
 	char *new_path, *pos;
 
@@ -1097,12 +1182,39 @@ struct ctl_table_header *__register_sysctl_paths(
 			goto out;
 		table = table->child;
 	}
-	header = __register_sysctl_table(root, namespaces, new_path, table);
-	if (header)
+	if (nr_subheaders == 1) {
+		header = __register_sysctl_table(root, namespaces, new_path, table);
+		if (header)
+			header->ctl_table_arg = ctl_table_arg;
+	} else {
+		header = kzalloc(sizeof(*header) +
+				 sizeof(*subheaders)*nr_subheaders, GFP_KERNEL);
+		if (!header)
+			goto out;
+
+		subheaders = (struct ctl_table_header **) (header + 1);
+		subheader = subheaders;
 		header->ctl_table_arg = ctl_table_arg;
+
+		if (register_leaf_sysctl_tables(new_path, pos, &subheader,
+						root, namespaces, table))
+			goto err_register_leaves;
+	}
+
 out:
 	kfree(new_path);
 	return header;
+
+err_register_leaves:
+	while (subheader > subheaders) {
+		struct ctl_table_header *subh = *(--subheader);
+		struct ctl_table *table = subh->ctl_table_arg;
+		unregister_sysctl_table(subh);
+		kfree(table);
+	}
+	kfree(header);
+	header = NULL;
+	goto out;
 }
 
 /**
@@ -1149,11 +1261,28 @@ EXPORT_SYMBOL(register_sysctl_table);
  */
 void unregister_sysctl_table(struct ctl_table_header * header)
 {
+	int nr_subheaders;
 	might_sleep();
 
 	if (header == NULL)
 		return;
 
+	nr_subheaders = count_subheaders(header->ctl_table_arg);
+	if (unlikely(nr_subheaders > 1)) {
+		struct ctl_table_header **subheaders;
+		int i;
+
+		subheaders = (struct ctl_table_header **)(header + 1);
+		for (i = nr_subheaders -1; i >= 0; i--) {
+			struct ctl_table_header *subh = subheaders[i];
+			struct ctl_table *table = subh->ctl_table_arg;
+			unregister_sysctl_table(subh);
+			kfree(table);
+		}
+		kfree(header);
+		return;
+	}
+
 	spin_lock(&sysctl_lock);
 	start_unregistering(header);
 	if (!--header->parent->count) {
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index a514e0f..25c7dfe 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -1015,7 +1015,7 @@ struct ctl_table
 	void *data;
 	int maxlen;
 	umode_t mode;
-	struct ctl_table *child;
+	struct ctl_table *child;	/* Deprecated */
 	struct ctl_table *parent;	/* Automatically set */
 	proc_handler *proc_handler;	/* Callback for text formatting */
 	struct ctl_table_poll *poll;
-- 
1.7.2.5
