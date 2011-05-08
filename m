From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 091/115] sysctl: add register_sysctl_dir: register an empty sysctl directory
Date: Mon,  9 May 2011 00:39:43 +0200
Message-ID: <1304894407-32201-92-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 include/linux/sysctl.h |    5 +++--
 kernel/sysctl.c        |   37 +++++++++++++++++++++++++++++++++++++
 kernel/sysctl_check.c  |   15 +++++++++++----
 3 files changed, 51 insertions(+), 6 deletions(-)

diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 322246d..03842cc 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -1133,11 +1133,12 @@ extern struct ctl_table_header *__register_sysctl_paths(struct ctl_table_group *
 							struct ctl_table *table);
 extern struct ctl_table_header *register_sysctl_paths(const struct ctl_path *path,
 						      struct ctl_table *table);
+struct ctl_table_header *register_sysctl_dir(const struct ctl_path *path);
 extern void unregister_sysctl_table(struct ctl_table_header *table);
 
 #ifdef CONFIG_SYSCTL_SYSCALL_CHECK
-extern int sysctl_check_table(const struct ctl_path *path,
-			      int nr_dirs,
+extern int sysctl_check_path(const struct ctl_path *path, int nr_dirs);
+extern int sysctl_check_table(const struct ctl_path *path, int nr_dirs,
 			      struct ctl_table *table);
 extern int sysctl_check_duplicates(struct ctl_table_header *header);
 extern int sysctl_check_netns_correspondents(struct ctl_table_header *header,
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 94fff4e..7cf0242 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -2045,6 +2045,9 @@ struct ctl_table_header *__register_sysctl_paths(struct ctl_table_group *group,
 	int dirs_created = 0;
 
 #ifdef CONFIG_SYSCTL_SYSCALL_CHECK
+	if (sysctl_check_path(path, nr_dirs))
+		return NULL;
+
 	if (sysctl_check_table(path, nr_dirs, table))
 		return NULL;
 #endif
@@ -2098,6 +2101,39 @@ struct ctl_table_header *register_sysctl_paths(const struct ctl_path *path,
 	return __register_sysctl_paths(&root_table_group, path, table);
 }
 
+/* Register an empty sysctl directory. */
+static struct ctl_table_header *__register_sysctl_dir(
+	struct ctl_table_group *group, const struct ctl_path *path)
+{
+	struct ctl_table_header *dir;
+	int nr_dirs = ctl_path_items(path);
+	int dirs_created = 0;
+
+#ifdef CONFIG_SYSCTL_SYSCALL_CHECK
+	if (sysctl_check_path(path, nr_dirs))
+		return NULL;
+#endif
+
+	dir = sysctl_mkdirs(&root_table_header, group, path,
+			    nr_dirs, &dirs_created);
+	if (!dir)
+		return NULL;
+
+	/* -1 because we don't want to count ourselves in the list of
+         * directory headers owned by @dir. NOTE: if all of the dirs
+         * in the path are already registered dirs_created will be 0. */
+	if (dirs_created > 0)
+		dir->ctl_owned_dirs_refs = dirs_created - 1;
+	else
+		dir->ctl_owned_dirs_refs = 0;
+	return dir;
+}
+
+struct ctl_table_header *register_sysctl_dir(const struct ctl_path *path)
+{
+	return __register_sysctl_dir(&root_table_group, path);
+}
+
 /**
  * unregister_sysctl_table - unregister a sysctl table hierarchy
  * @header: the header returned from __register_sysctl_paths
@@ -3193,4 +3229,5 @@ EXPORT_SYMBOL(proc_dostring);
 EXPORT_SYMBOL(proc_doulongvec_minmax);
 EXPORT_SYMBOL(proc_doulongvec_ms_jiffies_minmax);
 EXPORT_SYMBOL(register_sysctl_paths);
+EXPORT_SYMBOL(register_sysctl_dir);
 EXPORT_SYMBOL(unregister_sysctl_table);
diff --git a/kernel/sysctl_check.c b/kernel/sysctl_check.c
index 205f721..20c1948 100644
--- a/kernel/sysctl_check.c
+++ b/kernel/sysctl_check.c
@@ -24,6 +24,17 @@ static void fail(const struct ctl_path *path,
 
 #define FAIL(str) do { fail(path, t->procname, str); error = -EINVAL;} while (0)
 
+
+int sysctl_check_path(const struct ctl_path *path,
+		      int nr_dirs)
+{
+	if (nr_dirs <= CTL_MAXNAME - 1)
+		return 0;
+	fail(path, NULL, "tree too deep");
+	return -EINVAL;
+}
+
+
 int sysctl_check_table(const struct ctl_path *path,
 		       int nr_dirs,
 		       struct ctl_table *table)
@@ -33,10 +44,6 @@ int sysctl_check_table(const struct ctl_path *path,
 	unsigned int nr_files = 0;
 	int error = 0;
 
-	if (nr_dirs > CTL_MAXNAME - 1) {
-		fail(path, NULL, "tree too deep");
-		error = -EINVAL;
-	}
 
 	for(t = table; t->procname; t++) {
 		nr_files ++;
-- 
1.7.5.134.g1c08b
