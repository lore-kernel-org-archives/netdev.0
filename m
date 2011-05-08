From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 068/115] sysctl: rename sysctl_head_next to sysctl_use_next_header
Date: Mon,  9 May 2011 00:39:20 +0200
Message-ID: <1304894407-32201-69-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:64326 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932554Ab1EHWlr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:41:47 -0400
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new names makes it clear that this increments ctl_use_refs and
that _unuse must be used on the header. No functional change.

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 fs/proc/proc_sysctl.c  |    4 ++--
 include/linux/sysctl.h |    4 ++--
 kernel/sysctl.c        |    6 +++---
 kernel/sysctl_check.c  |    4 ++--
 4 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index b4cde14..068d39c 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -85,7 +85,7 @@ static struct dentry *proc_sys_lookup(struct inode *dir, struct dentry *dentry,
 
 	p = find_in_table(table, name);
 	if (!p) {
-		for (h = sysctl_head_next(NULL); h; h = sysctl_head_next(h)) {
+		for (h = sysctl_use_next_header(NULL); h; h = sysctl_use_next_header(h)) {
 			if (h->attached_to != table)
 				continue;
 			p = find_in_table(h->attached_by, name);
@@ -265,7 +265,7 @@ static int proc_sys_readdir(struct file *filp, void *dirent, filldir_t filldir)
 	if (ret)
 		goto out;
 
-	for (h = sysctl_head_next(NULL); h; h = sysctl_head_next(h)) {
+	for (h = sysctl_use_next_header(NULL); h; h = sysctl_use_next_header(h)) {
 		if (h->attached_to != table)
 			continue;
 		ret = scan(h, h->attached_by, &pos, filp, dirent, filldir);
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 3ff0a9e..4ed5235 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -955,8 +955,8 @@ extern void sysctl_head_get(struct ctl_table_header *);
 extern void sysctl_head_put(struct ctl_table_header *);
 extern int sysctl_is_seen(struct ctl_table_header *);
 extern struct ctl_table_header *sysctl_use_header(struct ctl_table_header *);
-extern struct ctl_table_header *sysctl_head_next(struct ctl_table_header *prev);
-extern struct ctl_table_header *__sysctl_head_next(struct nsproxy *namespaces,
+extern struct ctl_table_header *sysctl_use_next_header(struct ctl_table_header *prev);
+extern struct ctl_table_header *__sysctl_use_next_header(struct nsproxy *namespaces,
 						struct ctl_table_header *prev);
 extern void sysctl_unuse_header(struct ctl_table_header *prev);
 extern int sysctl_perm(struct ctl_table_root *root,
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 5d52e7a..e4ec23e 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1587,7 +1587,7 @@ lookup_header_list(struct ctl_table_root *root, struct nsproxy *namespaces)
 	return &set->list;
 }
 
-struct ctl_table_header *__sysctl_head_next(struct nsproxy *namespaces,
+struct ctl_table_header *__sysctl_use_next_header(struct nsproxy *namespaces,
 					    struct ctl_table_header *prev)
 {
 	struct ctl_table_root *root;
@@ -1631,9 +1631,9 @@ out:
 	return NULL;
 }
 
-struct ctl_table_header *sysctl_head_next(struct ctl_table_header *prev)
+struct ctl_table_header *sysctl_use_next_header(struct ctl_table_header *prev)
 {
-	return __sysctl_head_next(current->nsproxy, prev);
+	return __sysctl_use_next_header(current->nsproxy, prev);
 }
 
 void register_sysctl_root(struct ctl_table_root *root)
diff --git a/kernel/sysctl_check.c b/kernel/sysctl_check.c
index a3a58b8..44c31f0 100644
--- a/kernel/sysctl_check.c
+++ b/kernel/sysctl_check.c
@@ -28,8 +28,8 @@ static struct ctl_table *sysctl_check_lookup(struct nsproxy *namespaces,
 	struct ctl_table *ref, *test;
 	int cur_depth;
 
-	for (head = __sysctl_head_next(namespaces, NULL); head;
-	     head = __sysctl_head_next(namespaces, head)) {
+	for (head = __sysctl_use_next_header(namespaces, NULL); head;
+	     head = __sysctl_use_next_header(namespaces, head)) {
 		cur_depth = depth;
 		ref = head->ctl_table;
 repeat:
-- 
1.7.5.134.g1c08b

