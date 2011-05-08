From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 088/115] RFC: sysctl: convert read-write lock to RCU
Date: Mon,  9 May 2011 00:39:40 +0200
Message-ID: <1304894407-32201-89-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45747 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932620Ab1EHWmN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:42:13 -0400
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Apologies to reviewers who will feel insulted reading this. This patch
is just for kicks - and by kicks I mean ass-kicks for such an awful
misuse of the RCU API. I haven't done anything with RCUs until now and
I'm very unsure about the sanity of this patch.

This patch replaces the reader-writer lock protected lists ctl_subdirs
and ctl_tables with RCU protected lists.

Unlike in the RCU sniplets I found, where the Reader part only read
data from the object - Updates were done on a separate Copy (RCU ...),
here readers do change some data in the list elements (data access
protected by a separate spin lock), but does not touch the list_head.

read-side:
  - uses the for...rcu list traversal for DEC Alpha memory whatever
  - rcu_read_(un)lock make sure the grace period is as long as needed

write-site:
  - writers are synchronized with a spin-lock
  - list adding/removing is done with list_add_tail_rcu/list_del_rcu
  - freeing of elements is done after the grace period has ended (call_rcu)

Also note that there may be unwanted interactions with the RCU
protected VFS routines: ctl_table_header elements are scheduled to be
freed when all references to them have disappeared. This means after
removing the element from the list of at a later time (also with
call_rcu). I don't think that delaying free-ing some more would be a
problem, but I may be very wrong.

Free-ing of ctl_table_header is done with free_head.  This is
scheduled to be called with call_rcu in two places:

- sysctl_proc_inode_put() called from the VFS by proc_evict_inode which uses
       rcu_assign_pointer(PROC_I(inode)->sysctl, NULL)
   to delete the VFS's last reference to the object

- unregister_sysctl_table (no connection to the VFS).

Each of them determines if all references to that object have
disappeared, and if so, schedule the object to be freed with call_rcu.

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 fs/proc/proc_sysctl.c |    8 ++++----
 kernel/sysctl.c       |   29 ++++++++++++-----------------
 kernel/sysctl_check.c |    7 ++++---
 3 files changed, 20 insertions(+), 24 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index 9337149..b3e2453 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -81,7 +81,7 @@ retry:
 	sysctl_read_lock_head(head);
 
 	/* first check whether a subdirectory has the searched-for name */
-	list_for_each_entry(h, &head->ctl_subdirs, ctl_entry) {
+	list_for_each_entry_rcu(h, &head->ctl_subdirs, ctl_entry) {
 		if (IS_ERR(sysctl_use_header(h)))
 			continue;
 
@@ -93,7 +93,7 @@ retry:
 	}
 
 	/* no subdir with that name, look for the file in the ctl_tables */
-	list_for_each_entry(h, &head->ctl_tables, ctl_entry) {
+	list_for_each_entry_rcu(h, &head->ctl_tables, ctl_entry) {
 		if (IS_ERR(sysctl_use_header(h)))
 			continue;
 
@@ -234,7 +234,7 @@ static int scan(struct ctl_table_header *head,
 
 	sysctl_read_lock_head(head);
 
-	list_for_each_entry(h, &head->ctl_subdirs, ctl_entry) {
+	list_for_each_entry_rcu(h, &head->ctl_subdirs, ctl_entry) {
 		if (*pos < file->f_pos) {
 			(*pos)++;
 			continue;
@@ -252,7 +252,7 @@ static int scan(struct ctl_table_header *head,
 		(*pos)++;
 	}
 
-	list_for_each_entry(h, &head->ctl_tables, ctl_entry) {
+	list_for_each_entry_rcu(h, &head->ctl_tables, ctl_entry) {
 		ctl_table *t;
 
 		if (IS_ERR(sysctl_use_header(h)))
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 9e50334..26c2bc6 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -56,7 +56,6 @@
 #include <linux/kprobes.h>
 #include <linux/pipe_fs_i.h>
 #include <linux/oom.h>
-#include <linux/rwsem.h>
 
 #include <asm/uaccess.h>
 #include <asm/processor.h>
@@ -1616,30 +1615,25 @@ struct ctl_table_header *sysctl_use_netns_corresp(struct ctl_table_header *h)
 }
 
 
-/* This semaphore protects the ctl_subdirs and ctl_tables lists. You
- * must also have incremented the _use_refs of the header before
- * accessing any field of the header including these lists. If it's
- * deemed necessary, we can create a per-header rwsem. For now a
- * global one will do. */
-static DECLARE_RWSEM(sysctl_rwsem);
+/* protection for the headers' ctl_subdirs/ctl_tables lists */
+static DEFINE_SPINLOCK(sysctl_list_lock);
 void sysctl_write_lock_head(struct ctl_table_header *head)
 {
-	down_write(&sysctl_rwsem);
+	spin_lock(&sysctl_list_lock);
 }
 void sysctl_write_unlock_head(struct ctl_table_header *head)
 {
-	up_write(&sysctl_rwsem);
+	spin_unlock(&sysctl_list_lock);
 }
 void sysctl_read_lock_head(struct ctl_table_header *head)
 {
-	down_read(&sysctl_rwsem);
+	rcu_read_lock();
 }
 void sysctl_read_unlock_head(struct ctl_table_header *head)
 {
-	up_read(&sysctl_rwsem);
+	rcu_read_unlock();
 }
 
-
 /*
  * sysctl_perm does NOT grant the superuser all rights automatically, because
  * some sysctl variables are readonly even to root.
@@ -1777,6 +1771,7 @@ static struct ctl_table_header *alloc_sysctl_header(struct ctl_table_group *grou
 	h->ctl_table_arg = NULL;
 	h->unregistering = NULL;
 	h->ctl_group = group;
+	INIT_LIST_HEAD(&h->ctl_entry);
 
 	return h;
 }
@@ -1788,7 +1783,7 @@ static struct ctl_table_header *mkdir_existing_dir(struct ctl_table_header *pare
 						   const char *name)
 {
 	struct ctl_table_header *h;
-	list_for_each_entry(h, &parent->ctl_subdirs, ctl_entry) {
+	list_for_each_entry_rcu(h, &parent->ctl_subdirs, ctl_entry) {
 		spin_lock(&sysctl_lock);
 		if (likely(!h->unregistering)) {
 			if (strcmp(name, h->ctl_dirname) == 0) {
@@ -1844,7 +1839,7 @@ static struct ctl_table_header *mkdir_new_dir(struct ctl_table_header *parent,
 {
 	dir->parent = parent;
 	header_refs_inc(dir);
-	list_add_tail(&dir->ctl_entry, &parent->ctl_subdirs);
+	list_add_tail_rcu(&dir->ctl_entry, &parent->ctl_subdirs);
 	return dir;
 }
 
@@ -2049,7 +2044,7 @@ struct ctl_table_header *__register_sysctl_paths(struct ctl_table_group *group,
 	failed_duplicate_check = sysctl_check_duplicates(header);
 #endif
 	if (!failed_duplicate_check)
-		list_add_tail(&header->ctl_entry, &header->parent->ctl_tables);
+		list_add_tail_rcu(&header->ctl_entry, &header->parent->ctl_tables);
 
 	sysctl_write_unlock_head(header->parent);
 
@@ -2119,14 +2114,14 @@ void unregister_sysctl_table(struct ctl_table_header *header)
 			 * specific ctl_table_group list. For not that
 			 * list is protected by sysctl_lock. */
 			spin_lock(&sysctl_lock);
-			list_del_init(&header->ctl_entry);
+			list_del_rcu(&header->ctl_entry);
 			spin_unlock(&sysctl_lock);
 		} else {
 			/* ctl_entry is a member of the parent's
 			 * ctl_tables/subdirs lists which are
 			 * protected by the parent's write lock. */
 			sysctl_write_lock_head(parent);
-			list_del_init(&header->ctl_entry);
+			list_del_rcu(&header->ctl_entry);
 			sysctl_write_unlock_head(parent);
 		}
 
diff --git a/kernel/sysctl_check.c b/kernel/sysctl_check.c
index 55e797a..b9573e0 100644
--- a/kernel/sysctl_check.c
+++ b/kernel/sysctl_check.c
@@ -1,5 +1,6 @@
 #include <linux/sysctl.h>
 #include <linux/string.h>
+#include <linux/rculist.h>
 
 /*
  * @path: the path to the offender
@@ -124,7 +125,7 @@ int sysctl_check_duplicates(struct ctl_table_header *header)
 	struct ctl_table_header *dir = header->parent;
 	struct ctl_table_header *h;
 
-	list_for_each_entry(h, &dir->ctl_subdirs, ctl_entry) {
+	list_for_each_entry_rcu(h, &dir->ctl_subdirs, ctl_entry) {
 		if (IS_ERR(sysctl_use_header(h)))
 			continue;
 
@@ -136,7 +137,7 @@ int sysctl_check_duplicates(struct ctl_table_header *header)
 		sysctl_unuse_header(h);
 	}
 
-	list_for_each_entry(h, &dir->ctl_tables, ctl_entry) {
+	list_for_each_entry_rcu(h, &dir->ctl_tables, ctl_entry) {
 		ctl_table *t;
 
 		if (IS_ERR(sysctl_use_header(h)))
@@ -188,7 +189,7 @@ int sysctl_check_netns_correspondents(struct ctl_table_header *header,
 	/* see if the netns_correspondent has a subdir
 	 * with the same as this non-netns specific header */
 	sysctl_read_lock_head(netns_corresp);
-	list_for_each_entry(h, &netns_corresp->ctl_subdirs, ctl_entry) {
+	list_for_each_entry_rcu(h, &netns_corresp->ctl_subdirs, ctl_entry) {
 		if (IS_ERR(sysctl_use_header(h)))
 			continue;
 		if (strcmp(header->ctl_dirname, h->ctl_dirname) == 0) {
-- 
1.7.5.134.g1c08b

