From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 066/115] sysctl: rename ->used to ->ctl_use_refs
Date: Mon,  9 May 2011 00:39:18 +0200
Message-ID: <1304894407-32201-67-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In a later patch I will split the 'count' counter. We need to have a
clear distinction between the three counters to be able to understand
the code.

This counts the number of references to this object from places that
can tinker with it's internals (e.g. ctl_table, ctl_entry,
attached_to, attached_by, etc.).

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 include/linux/sysctl.h |    4 +++-
 kernel/sysctl.c        |    9 ++++-----
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 1c41dbd..fe13067 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -1043,7 +1043,9 @@ struct ctl_table_header
 		struct {
 			struct ctl_table *ctl_table;
 			struct list_head ctl_entry;
-			int used;
+			/* references to this header from contexts that
+			 * can access fields of this header */
+			int ctl_use_refs;
 			int count;
 		};
 		struct rcu_head rcu;
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 8b56695..ab242b4 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1494,14 +1494,14 @@ static int use_table(struct ctl_table_header *p)
 {
 	if (unlikely(p->unregistering))
 		return 0;
-	p->used++;
+	p->ctl_use_refs++;
 	return 1;
 }
 
 /* called under sysctl_lock */
 static void unuse_table(struct ctl_table_header *p)
 {
-	if (!--p->used)
+	if (!--p->ctl_use_refs)
 		if (unlikely(p->unregistering))
 			complete(p->unregistering);
 }
@@ -1510,10 +1510,10 @@ static void unuse_table(struct ctl_table_header *p)
 static void start_unregistering(struct ctl_table_header *p)
 {
 	/*
-	 * if p->used is 0, nobody will ever touch that entry again;
+	 * if p->ctl_use_refs is 0, nobody will ever touch that entry again;
 	 * we'll eliminate all paths to it before dropping sysctl_lock
 	 */
-	if (unlikely(p->used)) {
+	if (unlikely(p->ctl_use_refs)) {
 		struct completion wait;
 		init_completion(&wait);
 		p->unregistering = &wait;
@@ -1875,7 +1875,6 @@ struct ctl_table_header *__register_sysctl_paths(
 	header->ctl_table_arg = table;
 
 	INIT_LIST_HEAD(&header->ctl_entry);
-	header->used = 0;
 	header->unregistering = NULL;
 	header->root = root;
 	header->count = 1;
-- 
1.7.5.134.g1c08b
