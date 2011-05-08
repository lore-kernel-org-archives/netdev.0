From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 089/115] RFC: sysctl: change type of ctl_procfs_refs to u8
Date: Mon,  9 May 2011 00:39:41 +0200
Message-ID: <1304894407-32201-90-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49055 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932666Ab1EHWmO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:42:14 -0400
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

255 files per registered header should be enough for everyone.
If not, either:
- register another header (and another, and another) each with max 255 files
- change the type of ctl_procfs_refs to something bigger (e.g. u16)

This patch makes two assumptions:

- there will be at max a single inode created for each sysctl
  file. That means that the ctl_table_header will be (at max)
  incremented once for each of it's files. For directories the counter
  will be incremented only once (when creating an inode for the
  directory itself).

- there are no sysctl tables in the kernel with more than 255 entries.

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 fs/proc/proc_sysctl.c  |   12 +++++++++---
 include/linux/sysctl.h |   11 +++++++----
 kernel/sysctl.c        |   10 +++++++++-
 kernel/sysctl_check.c  |   12 ++++++++++++
 4 files changed, 37 insertions(+), 8 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index b3e2453..9580794 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -20,13 +20,15 @@ static struct inode *proc_sys_make_inode(struct super_block *sb,
 	struct inode *inode;
 	struct proc_inode *ei;
 
+	if (sysctl_proc_inode_get(head))
+		goto err_get;
+
 	inode = new_inode(sb);
 	if (!inode)
-		goto out;
+		goto err_new_inode;
 
 	inode->i_ino = get_next_ino();
 
-	sysctl_proc_inode_get(head);
 	ei = PROC_I(inode);
 	ei->sysctl = head;
 	ei->sysctl_entry = table;
@@ -44,8 +46,12 @@ static struct inode *proc_sys_make_inode(struct super_block *sb,
 		inode->i_op = &proc_sys_dir_operations;
 		inode->i_fop = &proc_sys_dir_file_operations;
 	}
-out:
 	return inode;
+
+err_new_inode:
+	sysctl_proc_inode_put(head);
+err_get:
+	return NULL;
 }
 
 static struct ctl_table *find_in_table(struct ctl_table *p, struct qstr *name)
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 036d1aa..d5d9b66f 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -947,7 +947,7 @@ extern void sysctl_init_group(struct ctl_table_group *group,
 
 /* get/put a reference to this header that
  * will be/was embedded in a procfs proc_inode */
-extern void sysctl_proc_inode_get(struct ctl_table_header *);
+extern int  sysctl_proc_inode_get(struct ctl_table_header *);
 extern void sysctl_proc_inode_put(struct ctl_table_header *);
 
 extern int sysctl_is_seen(struct ctl_table_header *);
@@ -1059,13 +1059,16 @@ struct ctl_table_header {
 			/* references to this header from contexts that
 			 * can access fields of this header */
 			int ctl_use_refs;
-			/* references to this header from procfs inodes.
-			 * procfs embeds a pointer to the header in proc_inode */
-			int ctl_procfs_refs;
 			/* counts references to this header from other
 			 * headers (through ->parent) plus the reference
 			 * returned by __register_sysctl_paths */
 			int ctl_header_refs;
+			/* references to this header from procfs inodes.
+			 * procfs embeds a pointer to the header in proc_inode.
+			 * If there's at max one inode created per file then
+			 * the max value of this is the number of files in the
+			 * ctl_table array, or 1 for directories. */
+			u8 ctl_procfs_refs;
 		};
 		struct rcu_head rcu;
 	};
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 26c2bc6..3e30e78 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1546,11 +1546,19 @@ static void start_unregistering(struct ctl_table_header *p)
 	}
 }
 
-void sysctl_proc_inode_get(struct ctl_table_header *head)
+int sysctl_proc_inode_get(struct ctl_table_header *head)
 {
+	int err = 0;
 	spin_lock(&sysctl_lock);
 	head->ctl_procfs_refs++;
+	if (unlikely(head->ctl_procfs_refs == 0)) {
+		/* restore old value */
+		head->ctl_procfs_refs--;
+		err = 1;
+		WARN(head->ctl_procfs_refs == 0, "sysctl: ctl_procfs_refs overflow");
+	}
 	spin_unlock(&sysctl_lock);
+	return err;
 }
 
 static void free_head(struct rcu_head *rcu)
diff --git a/kernel/sysctl_check.c b/kernel/sysctl_check.c
index b9573e0..205f721 100644
--- a/kernel/sysctl_check.c
+++ b/kernel/sysctl_check.c
@@ -29,6 +29,8 @@ int sysctl_check_table(const struct ctl_path *path,
 		       struct ctl_table *table)
 {
 	struct ctl_table *t;
+	unsigned int max_bits, max_files;
+	unsigned int nr_files = 0;
 	int error = 0;
 
 	if (nr_dirs > CTL_MAXNAME - 1) {
@@ -37,6 +39,7 @@ int sysctl_check_table(const struct ctl_path *path,
 	}
 
 	for(t = table; t->procname; t++) {
+		nr_files ++;
 		if ((t->proc_handler == proc_dostring) ||
 		    (t->proc_handler == proc_dointvec) ||
 		    (t->proc_handler == proc_dointvec_minmax) ||
@@ -58,6 +61,15 @@ int sysctl_check_table(const struct ctl_path *path,
 			FAIL("bogus .mode");
 	}
 
+	/* make sure we can increment the header's ctl_procfs_refs
+	 * counter for each file in the table. If this fails we either
+	 * need to change the type of the ctl_procfs_refs variable, or
+	 * register more tables in the same directory. */
+	max_bits = 8 * sizeof(((struct ctl_table_header *) 0)->ctl_procfs_refs);
+	max_files = 1 << max_bits;
+	if (nr_files >= max_files)
+		FAIL("too many files in registered table");
+
 	if (error)
 		dump_stack();
 
-- 
1.7.5.134.g1c08b

