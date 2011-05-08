From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 062/115] sysctl: remove useless ctl_table->parent field
Date: Mon,  9 May 2011 00:39:14 +0200
Message-ID: <1304894407-32201-63-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The 'parent' field was added for selinux in:
    commit d912b0cc1a617d7c590d57b7ea971d50c7f02503
    [PATCH] sysctl: add a parent entry to ctl_table and set the parent entry

and then was used for sysctl_check_table.

Both of the users have found other implementations.

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 include/linux/sysctl.h |    1 -
 kernel/sysctl.c        |   12 ------------
 kernel/sysctl_check.c  |    5 +++--
 3 files changed, 3 insertions(+), 15 deletions(-)

diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 095df3a..1c41dbd 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -1021,7 +1021,6 @@ struct ctl_table
 	int maxlen;
 	mode_t mode;
 	struct ctl_table *child;
-	struct ctl_table *parent;	/* Automatically set */
 	proc_handler *proc_handler;	/* Callback for text formatting */
 	void *extra1;
 	void *extra2;
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index edacbdc..0450d3d 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1671,15 +1671,6 @@ int sysctl_perm(struct ctl_table_root *root, struct ctl_table *table, int op)
 	return test_perm(mode, op);
 }
 
-static void sysctl_set_parent(struct ctl_table *parent, struct ctl_table *table)
-{
-	for (; table->procname; table++) {
-		table->parent = parent;
-		if (table->child)
-			sysctl_set_parent(table, table->child);
-	}
-}
-
 __init int sysctl_init(void)
 {
 	struct ctl_table_header *kern_header, *vm_header, *fs_header,
@@ -1688,8 +1679,6 @@ __init int sysctl_init(void)
 	struct ctl_table_header *binfmt_misc_header;
 #endif
 
-	sysctl_set_parent(NULL, root_table);
-
 	kern_header = register_sysctl_paths(kern_path, kern_table);
 	if (kern_header == NULL)
 		goto fail_register_kern;
@@ -1889,7 +1878,6 @@ struct ctl_table_header *__register_sysctl_paths(
 	header->used = 0;
 	header->unregistering = NULL;
 	header->root = root;
-	sysctl_set_parent(NULL, header->ctl_table);
 	header->count = 1;
 #ifdef CONFIG_SYSCTL_SYSCALL_CHECK
 	if (sysctl_check_table(namespaces, header->ctl_table)) {
diff --git a/kernel/sysctl_check.c b/kernel/sysctl_check.c
index cc26490..52f4810 100644
--- a/kernel/sysctl_check.c
+++ b/kernel/sysctl_check.c
@@ -100,8 +100,9 @@ static int __sysctl_check_table(struct nsproxy *namespaces,
 	for (; table->procname; table++) {
 		fail = NULL;
 
-		if (table->parent) {
-			if (!table->parent->procname)
+
+		if (depth != 0) { /* has parent */
+			if (!parents[depth - 1]->procname)
 				SET_FAIL("Parent without procname");
 		}
 		if (table->child) {
-- 
1.7.5.134.g1c08b
