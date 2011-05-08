From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 069/115] sysctl: split ->count into ctl_procfs_refs and ctl_header_refs
Date: Mon,  9 May 2011 00:39:21 +0200
Message-ID: <1304894407-32201-70-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is not necessary at this point, but will be later when we replace
the sysctl implementation with one that uses ctl_table_header objects
as directories.

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 include/linux/sysctl.h |    8 +++++++-
 kernel/sysctl.c        |   21 ++++++++++++---------
 2 files changed, 19 insertions(+), 10 deletions(-)

diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 4ed5235..0f41beb 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -1046,7 +1046,13 @@ struct ctl_table_header
 			/* references to this header from contexts that
 			 * can access fields of this header */
 			int ctl_use_refs;
-			int count;
+			/* references to this header from procfs inodes.
+			 * procfs embeds a pointer to the header in proc_inode */
+			int ctl_procfs_refs;
+			/* counts references to this header from other
+			 * headers (through ->parent) plus the reference
+			 * returned by __register_sysctl_paths */
+			int ctl_header_refs;
 		};
 		struct rcu_head rcu;
 	};
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index e4ec23e..48a1ffd 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -200,7 +200,7 @@ static int sysrq_sysctl_handler(ctl_table *table, int write,
 static struct ctl_table root_table[];
 static struct ctl_table_root sysctl_table_root;
 static struct ctl_table_header root_table_header = {
-	{{.count = 1,
+	{{.ctl_header_refs = 1,
 	.ctl_table = root_table,
 	.ctl_entry = LIST_HEAD_INIT(sysctl_table_root.default_set.list),}},
 	.root = &sysctl_table_root,
@@ -1554,7 +1554,7 @@ static void start_unregistering(struct ctl_table_header *p)
 void sysctl_head_get(struct ctl_table_header *head)
 {
 	spin_lock(&sysctl_lock);
-	head->count++;
+	head->ctl_procfs_refs++;
 	spin_unlock(&sysctl_lock);
 }
 
@@ -1566,7 +1566,8 @@ static void free_head(struct rcu_head *rcu)
 void sysctl_head_put(struct ctl_table_header *head)
 {
 	spin_lock(&sysctl_lock);
-	if (!--head->count)
+	head->ctl_procfs_refs--;
+	if ((head->ctl_procfs_refs == 0) && (head->ctl_header_refs == 0))
 		call_rcu(&head->rcu, free_head);
 	spin_unlock(&sysctl_lock);
 }
@@ -1877,7 +1878,7 @@ struct ctl_table_header *__register_sysctl_paths(
 	INIT_LIST_HEAD(&header->ctl_entry);
 	header->unregistering = NULL;
 	header->root = root;
-	header->count = 1;
+	header->ctl_header_refs = 1;
 #ifdef CONFIG_SYSCTL_SYSCALL_CHECK
 	if (sysctl_check_table(namespaces, header->ctl_table)) {
 		kfree(header);
@@ -1897,7 +1898,7 @@ struct ctl_table_header *__register_sysctl_paths(
 			try_attach(p, header);
 		}
 	}
-	header->parent->count++;
+	header->parent->ctl_header_refs++;
 	list_add_tail(&header->ctl_entry, &header->set->list);
 	spin_unlock(&sysctl_lock);
 
@@ -1937,12 +1938,14 @@ void unregister_sysctl_table(struct ctl_table_header * header)
 
 	spin_lock(&sysctl_lock);
 	start_unregistering(header);
-	if (!--header->parent->count) {
+	if (!--header->parent->ctl_header_refs) {
 		WARN_ON(1);
-		call_rcu(&header->parent->rcu, free_head);
+		if (!header->parent->ctl_procfs_refs)
+			call_rcu(&header->parent->rcu, free_head);
 	}
-	if (!--header->count)
-		call_rcu(&header->rcu, free_head);
+	if (!--header->ctl_header_refs)
+		if (!header->ctl_procfs_refs)
+			call_rcu(&header->rcu, free_head);
 	spin_unlock(&sysctl_lock);
 }
 
-- 
1.7.5.134.g1c08b
