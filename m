From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [PATCH 1/5] sysctl: faster reimplementation of sysctl_check_table
Date: Fri,  4 Feb 2011 06:37:04 +0200
Message-ID: <fd576ffbfb960548a5a9969ee9161ec22f2fd167.1296793770.git.lucian.grijincu@gmail.com>
References: <cover.1296793770.git.lucian.grijincu@gmail.com>
Cc: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Oct
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1296793770.git.lucian.grijincu@gmail.com>
In-Reply-To: <cover.1296793770.git.lucian.grijincu@gmail.com>
References: <cover.1296793770.git.lucian.grijincu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Determining the parent of a node at depth d
- previous implementation: O(d)
- current  implementation: O(1)

Printing the path to a node at depth d
- previous implementation: O(d^2)
- current  implementation: O(d)

This comes to a cost: we use an array ('parents') holding as many
pointers as there can be sysctl levels (currently CTL_MAXNAME=10).

The 'parents' array of pointers holds the same values as the
ctl_table->parents field because the function that updates ->parents
(sysctl_set_parent) is called with either NULL (for root nodes) or
with sysctl_set_parent(table, table->child).

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 kernel/sysctl_check.c |  121 ++++++++++++++++++++++++-------------------------
 1 files changed, 60 insertions(+), 61 deletions(-)

diff --git a/kernel/sysctl_check.c b/kernel/sysctl_check.c
index 10b90d8..9b4fecd 100644
--- a/kernel/sysctl_check.c
+++ b/kernel/sysctl_check.c
@@ -6,58 +6,34 @@
 #include <net/ip_vs.h>
 
 
-static int sysctl_depth(struct ctl_table *table)
-{
-	struct ctl_table *tmp;
-	int depth;
-
-	depth = 0;
-	for (tmp = table; tmp->parent; tmp = tmp->parent)
-		depth++;
-
-	return depth;
-}
-
-static struct ctl_table *sysctl_parent(struct ctl_table *table, int n)
+static void sysctl_print_path(struct ctl_table *table,
+			      struct ctl_table **parents, int depth)
 {
+	struct ctl_table *p;
 	int i;
-
-	for (i = 0; table && i < n; i++)
-		table = table->parent;
-
-	return table;
-}
-
-
-static void sysctl_print_path(struct ctl_table *table)
-{
-	struct ctl_table *tmp;
-	int depth, i;
-	depth = sysctl_depth(table);
 	if (table->procname) {
-		for (i = depth; i >= 0; i--) {
-			tmp = sysctl_parent(table, i);
-			printk("/%s", tmp->procname?tmp->procname:"");
+		for (i = 0; i < depth; i++) {
+			p = parents[i];
+			printk("/%s", p->procname ? p->procname : "");
 		}
+		printk("/%s", table->procname);
 	}
 	printk(" ");
 }
 
 static struct ctl_table *sysctl_check_lookup(struct nsproxy *namespaces,
-						struct ctl_table *table)
+	     struct ctl_table *table, struct ctl_table **parents, int depth)
 {
 	struct ctl_table_header *head;
 	struct ctl_table *ref, *test;
-	int depth, cur_depth;
-
-	depth = sysctl_depth(table);
+	int cur_depth;
 
 	for (head = __sysctl_head_next(namespaces, NULL); head;
 	     head = __sysctl_head_next(namespaces, head)) {
 		cur_depth = depth;
 		ref = head->ctl_table;
 repeat:
-		test = sysctl_parent(table, cur_depth);
+		test = parents[depth - cur_depth];
 		for (; ref->procname; ref++) {
 			int match = 0;
 			if (cur_depth && !ref->child)
@@ -83,11 +59,12 @@ out:
 	return ref;
 }
 
-static void set_fail(const char **fail, struct ctl_table *table, const char *str)
+static void set_fail(const char **fail, struct ctl_table *table,
+	     const char *str, struct ctl_table **parents, int depth)
 {
 	if (*fail) {
 		printk(KERN_ERR "sysctl table check failed: ");
-		sysctl_print_path(table);
+		sysctl_print_path(table, parents, depth);
 		printk(" %s\n", *fail);
 		dump_stack();
 	}
@@ -95,16 +72,24 @@ static void set_fail(const char **fail, struct ctl_table *table, const char *str
 }
 
 static void sysctl_check_leaf(struct nsproxy *namespaces,
-				struct ctl_table *table, const char **fail)
+			      struct ctl_table *table, const char **fail,
+			      struct ctl_table **parents, int depth)
 {
 	struct ctl_table *ref;
 
-	ref = sysctl_check_lookup(namespaces, table);
-	if (ref && (ref != table))
-		set_fail(fail, table, "Sysctl already exists");
+	ref = sysctl_check_lookup(namespaces, table, parents, depth);
+	if (ref && (ref != table)) {
+		printk(KERN_ALERT "sysctl_check_leaf ref[%s], table[%s]\n", ref->procname, table->procname);
+		set_fail(fail, table, "Sysctl already exists", parents, depth);
+	}
 }
 
-int sysctl_check_table(struct nsproxy *namespaces, struct ctl_table *table)
+
+
+#define SET_FAIL(str) set_fail(&fail, table, str, parents, depth)
+
+static int __sysctl_check_table(struct nsproxy *namespaces,
+	struct ctl_table *table, struct ctl_table **parents, int depth)
 {
 	int error = 0;
 	for (; table->procname; table++) {
@@ -112,23 +97,23 @@ int sysctl_check_table(struct nsproxy *namespaces, struct ctl_table *table)
 
 		if (table->parent) {
 			if (table->procname && !table->parent->procname)
-				set_fail(&fail, table, "Parent without procname");
+				SET_FAIL("Parent without procname");
 		}
 		if (!table->procname)
-			set_fail(&fail, table, "No procname");
+			SET_FAIL("No procname");
 		if (table->child) {
 			if (table->data)
-				set_fail(&fail, table, "Directory with data?");
+				SET_FAIL("Directory with data?");
 			if (table->maxlen)
-				set_fail(&fail, table, "Directory with maxlen?");
+				SET_FAIL("Directory with maxlen?");
 			if ((table->mode & (S_IRUGO|S_IXUGO)) != table->mode)
-				set_fail(&fail, table, "Writable sysctl directory");
+				SET_FAIL("Writable sysctl directory");
 			if (table->proc_handler)
-				set_fail(&fail, table, "Directory with proc_handler");
+				SET_FAIL("Directory with proc_handler");
 			if (table->extra1)
-				set_fail(&fail, table, "Directory with extra1");
+				SET_FAIL("Directory with extra1");
 			if (table->extra2)
-				set_fail(&fail, table, "Directory with extra2");
+				SET_FAIL("Directory with extra2");
 		} else {
 			if ((table->proc_handler == proc_dostring) ||
 			    (table->proc_handler == proc_dointvec) ||
@@ -139,28 +124,42 @@ int sysctl_check_table(struct nsproxy *namespaces, struct ctl_table *table)
 			    (table->proc_handler == proc_doulongvec_minmax) ||
 			    (table->proc_handler == proc_doulongvec_ms_jiffies_minmax)) {
 				if (!table->data)
-					set_fail(&fail, table, "No data");
+					SET_FAIL("No data");
 				if (!table->maxlen)
-					set_fail(&fail, table, "No maxlen");
+					SET_FAIL("No maxlen");
 			}
 #ifdef CONFIG_PROC_SYSCTL
 			if (table->procname && !table->proc_handler)
-				set_fail(&fail, table, "No proc_handler");
-#endif
-#if 0
-			if (!table->procname && table->proc_handler)
-				set_fail(&fail, table, "proc_handler without procname");
+				SET_FAIL("No proc_handler");
 #endif
-			sysctl_check_leaf(namespaces, table, &fail);
+			parents[depth] = table;
+			sysctl_check_leaf(namespaces, table, &fail,
+					  parents, depth);
 		}
 		if (table->mode > 0777)
-			set_fail(&fail, table, "bogus .mode");
+			SET_FAIL("bogus .mode");
 		if (fail) {
-			set_fail(&fail, table, NULL);
+			SET_FAIL(NULL);
 			error = -EINVAL;
 		}
-		if (table->child)
-			error |= sysctl_check_table(namespaces, table->child);
+		if (table->child) {
+			parents[depth] = table;
+			error |= __sysctl_check_table(namespaces, table->child,
+						      parents, depth + 1);
+		}
 	}
 	return error;
 }
+
+
+int sysctl_check_table(struct nsproxy *namespaces, struct ctl_table *table)
+{
+	struct ctl_table *parents[CTL_MAXNAME];
+	/* Keep track of parents as we go down into the tree.
+	 *
+	 * parents[i-1] will be the parent for parents[i].
+	 * The node at depth 'd' will have the parent at parents[d-1].
+	 * The root node (depth=0) has no parent in this array.
+	 */
+	return __sysctl_check_table(namespaces, table, parents, 0);
+}
-- 
1.7.4.rc1.7.g2cf08.dirty
