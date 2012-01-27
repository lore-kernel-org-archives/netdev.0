From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 09/29] sysctl: Add support for register sysctl tables with a normal cstring path.
Date: Thu, 26 Jan 2012 20:51:45 -0800
Message-ID: <1327639925-12920-9-git-send-email-ebiederm@xmission.com>
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

Make __register_sysctl_table the core sysctl registration operation and
make it take a char * string as path.

Now that binary paths have been banished into the real of backwards
compatibility in kernel/binary_sysctl.c where they can be safely
ignored there is no longer a need to use struct ctl_path to represent
path names when registering ctl_tables.

Start the transition to using normal char * strings to represent
pathnames when registering sysctl tables.  Normal strings are easier
to deal with both in the internal sysctl implementation and for
programmers registering sysctl tables.

__register_sysctl_paths is turned into a backwards compatibility wrapper
that converts a ctl_path array into a normal char * string.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/proc/proc_sysctl.c  |   94 ++++++++++++++++++++++++++++++++++++++++++-----
 include/linux/sysctl.h |    3 ++
 2 files changed, 87 insertions(+), 10 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index bcf60fb..5704ff0 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -882,7 +882,7 @@ static int sysctl_check_table(struct nsproxy *namespaces, struct ctl_table *tabl
 #endif /* CONFIG_SYSCTL_SYSCALL_CHECK */
 
 /**
- * __register_sysctl_paths - register a sysctl hierarchy
+ * __register_sysctl_table - register a sysctl table
  * @root: List of sysctl headers to register on
  * @namespaces: Data to compute which lists of sysctl entries are visible
  * @path: The path to the directory the sysctl table is in.
@@ -934,21 +934,34 @@ static int sysctl_check_table(struct nsproxy *namespaces, struct ctl_table *tabl
  * This routine returns %NULL on a failure to register, and a pointer
  * to the table header on success.
  */
-struct ctl_table_header *__register_sysctl_paths(
+struct ctl_table_header *__register_sysctl_table(
 	struct ctl_table_root *root,
 	struct nsproxy *namespaces,
-	const struct ctl_path *path, struct ctl_table *table)
+	const char *path, struct ctl_table *table)
 {
 	struct ctl_table_header *header;
 	struct ctl_table *new, **prevp;
-	unsigned int n, npath;
+	const char *name, *nextname;
+	unsigned int npath = 0;
 	struct ctl_table_set *set;
 	size_t path_bytes = 0;
 	char *new_name;
 
 	/* Count the path components */
-	for (npath = 0; path[npath].procname; ++npath)
-		path_bytes += strlen(path[npath].procname) + 1;
+	for (name = path; name; name = nextname) {
+		int namelen;
+		nextname = strchr(name, '/');
+		if (nextname) {
+			namelen = nextname - name;
+			nextname++;
+		} else {
+			namelen = strlen(name);
+		}
+		if (namelen == 0)
+			continue;
+		path_bytes += namelen + 1;
+		npath++;
+	}
 
 	/*
 	 * For each path component, allocate a 2-element ctl_table array.
@@ -968,9 +981,20 @@ struct ctl_table_header *__register_sysctl_paths(
 
 	/* Now connect the dots */
 	prevp = &header->ctl_table;
-	for (n = 0; n < npath; ++n, ++path) {
-		/* Copy the procname */
-		strcpy(new_name, path->procname);
+	for (name = path; name; name = nextname) {
+		int namelen;
+		nextname = strchr(name, '/');
+		if (nextname) {
+			namelen = nextname - name;
+			nextname++;
+		} else {
+			namelen = strlen(name);
+		}
+		if (namelen == 0)
+			continue;
+		memcpy(new_name, name, namelen);
+		new_name[namelen] = '\0';
+
 		new->procname = new_name;
 		new->mode     = 0555;
 
@@ -978,7 +1002,7 @@ struct ctl_table_header *__register_sysctl_paths(
 		prevp = &new->child;
 
 		new += 2;
-		new_name += strlen(new_name) + 1;
+		new_name += namelen + 1;
 	}
 	*prevp = table;
 	header->ctl_table_arg = table;
@@ -1022,6 +1046,56 @@ struct ctl_table_header *__register_sysctl_paths(
 	return header;
 }
 
+static char *append_path(const char *path, char *pos, const char *name)
+{
+	int namelen;
+	namelen = strlen(name);
+	if (((pos - path) + namelen + 2) >= PATH_MAX)
+		return NULL;
+	memcpy(pos, name, namelen);
+	pos[namelen] = '/';
+	pos[namelen + 1] = '\0';
+	pos += namelen + 1;
+	return pos;
+}
+
+/**
+ * __register_sysctl_paths - register a sysctl table hierarchy
+ * @root: List of sysctl headers to register on
+ * @namespaces: Data to compute which lists of sysctl entries are visible
+ * @path: The path to the directory the sysctl table is in.
+ * @table: the top-level table structure
+ *
+ * Register a sysctl table hierarchy. @table should be a filled in ctl_table
+ * array. A completely 0 filled entry terminates the table.
+ *
+ * See __register_sysctl_table for more details.
+ */
+struct ctl_table_header *__register_sysctl_paths(
+	struct ctl_table_root *root,
+	struct nsproxy *namespaces,
+	const struct ctl_path *path, struct ctl_table *table)
+{
+	struct ctl_table_header *header = NULL;
+	const struct ctl_path *component;
+	char *new_path, *pos;
+
+	pos = new_path = kmalloc(PATH_MAX, GFP_KERNEL);
+	if (!new_path)
+		return NULL;
+
+	pos[0] = '\0';
+	for (component = path; component->procname; component++) {
+		pos = append_path(new_path, pos, component->procname);
+		if (!pos)
+			goto out;
+	}
+	header = __register_sysctl_table(root, namespaces, new_path, table);
+out:
+	kfree(new_path);
+	return header;
+}
+
 /**
  * register_sysctl_table_path - register a sysctl table hierarchy
  * @path: The path to the directory the sysctl table is in.
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 43c36ac..a514e0f 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -1073,6 +1073,9 @@ extern void setup_sysctl_set(struct ctl_table_set *p,
 extern void retire_sysctl_set(struct ctl_table_set *set);
 
 void register_sysctl_root(struct ctl_table_root *root);
+struct ctl_table_header *__register_sysctl_table(
+	struct ctl_table_root *root, struct nsproxy *namespaces,
+	const char *path, struct ctl_table *table);
 struct ctl_table_header *__register_sysctl_paths(
 	struct ctl_table_root *root, struct nsproxy *namespaces,
 	const struct ctl_path *path, struct ctl_table *table);
-- 
1.7.2.5
