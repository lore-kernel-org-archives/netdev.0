From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 087/115] sysctl: check netns-specific registration order respected
Date: Mon,  9 May 2011 00:39:39 +0200
Message-ID: <1304894407-32201-88-git-send-email-lucian.grijincu@gmail.com>
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
 include/linux/sysctl.h |    2 +
 kernel/sysctl.c        |   15 ++++++++-
 kernel/sysctl_check.c  |   78 ++++++++++++++++++++++++++++++++++++++++++-----
 3 files changed, 85 insertions(+), 10 deletions(-)

diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index bdc8c97..036d1aa 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -1128,6 +1128,8 @@ extern int sysctl_check_table(const struct ctl_path *path,
 			      int nr_dirs,
 			      struct ctl_table *table);
 extern int sysctl_check_duplicates(struct ctl_table_header *header);
+extern int sysctl_check_netns_correspondents(struct ctl_table_header *header,
+					     struct ctl_table_group *group);
 #endif /* CONFIG_SYSCTL_SYSCALL_CHECK */
 
 #endif /* __KERNEL__ */
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 9b2c05a..9e50334 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1920,6 +1920,12 @@ static struct ctl_table_header *sysctl_mkdirs(struct ctl_table_header *parent,
 			sysctl_write_unlock_head(parent);
 			parent = h;
 			dirs[i] = NULL; /* I'm used, don't free me */
+#ifdef CONFIG_SYSCTL_SYSCALL_CHECK
+			if (sysctl_check_netns_correspondents(parent, group)) {
+				unregister_sysctl_table(h);
+				goto err_check_netns_correspondents;
+			}
+#endif
 			continue;
 		}
 
@@ -1946,11 +1952,18 @@ static struct ctl_table_header *sysctl_mkdirs(struct ctl_table_header *parent,
 
 	return parent;
 
+#ifdef CONFIG_SYSCTL_SYSCALL_CHECK
+err_check_netns_correspondents:
+	if (__netns_corresp)
+		kmem_cache_free(sysctl_header_cachep, __netns_corresp);
+#endif
+
 err_alloc_coresp:
 	i = nr_dirs;
 err_alloc_dir:
 	for (i--; i >= 0; i--)
-		kmem_cache_free(sysctl_header_cachep, dirs[i]);
+		if (dirs[i])
+			kmem_cache_free(sysctl_header_cachep, dirs[i]);
 	return NULL;
 
 }
diff --git a/kernel/sysctl_check.c b/kernel/sysctl_check.c
index 4e0bce5..55e797a 100644
--- a/kernel/sysctl_check.c
+++ b/kernel/sysctl_check.c
@@ -63,19 +63,14 @@ int sysctl_check_table(const struct ctl_path *path,
 	return error;
 }
 
-
-/*
- * @dir: the directory imediately above the offender
- * @offender is the name of a file or directory that violated some sysctl rules.
- */
-static void duplicate_error(struct ctl_table_header *dir,
-			    const char *offender)
+/* Print the path from to a sysctl directory. The header must *not*
+ * point to a ctl_table_header that wraps a ctl_table array, it must
+ * be a directory. */
+static void printk_sysctl_dir(struct ctl_table_header *dir)
 {
 	const char *names[CTL_MAXNAME];
 	int i = 0;
 
-	printk(KERN_ERR "sysctl duplicate check failed: ");
-
 	for (; dir->parent; dir = dir->parent)
 		/* ctl_dirname can be NULL: netns-correspondent
 		 * directories do not have a ctl_dirname. Their only
@@ -90,7 +85,18 @@ static void duplicate_error(struct ctl_table_header *dir,
 	/* Print the names in the normal path order, not reversed */
 	for(i--; i >= 0; i--)
 		printk("/%s", names[i]);
+}
+
+/*
+ * @dir: the directory imediately above the offender
+ * @offender is the name of a file or directory that violated some sysctl rules.
+ */
+static void duplicate_error(struct ctl_table_header *dir,
+			    const char *offender)
+{
 
+	printk(KERN_ERR "sysctl duplicate check failed: ");
+	printk_sysctl_dir(dir);
 	printk("/%s \n", offender);
 }
 
@@ -150,3 +156,57 @@ int sysctl_check_duplicates(struct ctl_table_header *header)
 
 	return has_duplicates;
 }
+
+/* Check whether adding this header respects the rule that no
+ * non-netns-specific directory will be registered after one with the
+ * same name, but netns-specific was registered before (and still is registered)
+ *
+ * E.g. This sequence of registrations is not valid:
+ *     - non-netns-specific: /net/ipv4/
+ *     -     netns-specific: /net/ipv4/conf/lo
+ *     - non-netns-specific: /net/ipv4/conf/
+
+ * because after first adding 'conf' as a netns specific directory,
+ * we're adding one non-netns specific.
+ *
+ * NOTE: in this example, the directory that has a netns-correspondent is 'ipv4'
+ */
+int sysctl_check_netns_correspondents(struct ctl_table_header *header,
+				      struct ctl_table_group *group)
+{
+	struct ctl_table_header *netns_corresp, *h;
+	int found = 0;
+	/* we're only checking registration of non-netns paths added,
+	 * because only those paths can violate the above rule. */
+	if (group->has_netns_corresp)
+		return 0;
+
+	netns_corresp = sysctl_use_netns_corresp(header->parent);
+	if (!netns_corresp)
+		return 0;
+
+	/* see if the netns_correspondent has a subdir
+	 * with the same as this non-netns specific header */
+	sysctl_read_lock_head(netns_corresp);
+	list_for_each_entry(h, &netns_corresp->ctl_subdirs, ctl_entry) {
+		if (IS_ERR(sysctl_use_header(h)))
+			continue;
+		if (strcmp(header->ctl_dirname, h->ctl_dirname) == 0) {
+			sysctl_unuse_header(h);
+			found = 1;
+			break;
+		}
+		sysctl_unuse_header(h);
+	}
+	sysctl_read_unlock_head(netns_corresp);
+
+	if (!found)
+		return 0;
+
+	printk(KERN_ERR "illegal sysctl registration of non-netns-specific "
+	       "directory after a netns-specific with the same name\n");
+	printk_sysctl_dir(header);
+	dump_stack();
+
+	return 1;
+}
-- 
1.7.5.134.g1c08b
