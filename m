From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH RFC 26/48] Audit: make audit_inode_hash per user namespace
Date: Tue, 7 May 2013 10:20:47 +0800
Message-ID: <1367893269-9308-27-git-send-email-gaofeng@cn.fujitsu.com>
References: <1367893269-9308-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
	sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1367893269-9308-1-git-send-email-gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

audit_inode_hash is used to hash inode related audit rules,
and the audit rule should be per user namespace. So we
should make audit_inode_hash per user namespace too.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/linux/user_namespace.h |  2 ++
 kernel/audit.c                 | 13 +++++--------
 kernel/audit.h                 |  5 ++---
 kernel/audit_watch.c           |  5 +++--
 kernel/auditfilter.c           | 22 +++++++++++++---------
 kernel/auditsc.c               |  2 +-
 6 files changed, 26 insertions(+), 23 deletions(-)

diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index 5a778f8..c56e276 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -30,6 +30,8 @@ struct audit_ctrl {
 	struct task_struct	*kauditd_task;
 	wait_queue_head_t	kauditd_wait;
 	wait_queue_head_t	backlog_wait;
+#define AUDIT_INODE_BUCKETS	32
+	struct list_head	inode_hash[AUDIT_INODE_BUCKETS];
 	bool			ever_enabled;
 };
 #endif
diff --git a/kernel/audit.c b/kernel/audit.c
index ca9e046..d254827 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -107,9 +107,6 @@ u32		audit_sig_sid = 0;
 */
 static atomic_t    audit_lost = ATOMIC_INIT(0);
 
-/* Hash for inode-based rules */
-struct list_head audit_inode_hash[AUDIT_INODE_BUCKETS];
-
 /* The audit_freelist is a list of pre-allocated audit buffers (if more
  * than AUDIT_MAXFREE are in use, the audit buffer is freed instead of
  * being placed on the freelist). */
@@ -989,8 +986,6 @@ static struct pernet_operations audit_net_ops = {
 /* Initialize audit support at boot time. */
 static int __init audit_init(void)
 {
-	int i;
-
 	if (init_user_ns.audit.initialized == AUDIT_DISABLED)
 		return 0;
 
@@ -1004,9 +999,6 @@ static int __init audit_init(void)
 
 	audit_log(NULL, GFP_KERNEL, AUDIT_KERNEL, "initialized");
 
-	for (i = 0; i < AUDIT_INODE_BUCKETS; i++)
-		INIT_LIST_HEAD(&audit_inode_hash[i]);
-
 	return 0;
 }
 __initcall(audit_init);
@@ -1602,6 +1594,8 @@ EXPORT_SYMBOL(audit_log_secctx);
 
 void audit_set_user_ns(struct user_namespace *ns)
 {
+	int i;
+
 	if (init_user_ns.audit.initialized == AUDIT_DISABLED)
 		return;
 
@@ -1612,6 +1606,9 @@ void audit_set_user_ns(struct user_namespace *ns)
 	init_waitqueue_head(&ns->audit.kauditd_wait);
 	init_waitqueue_head(&ns->audit.backlog_wait);
 
+	for (i = 0; i < AUDIT_INODE_BUCKETS; i++)
+		INIT_LIST_HEAD(&ns->audit.inode_hash[i]);
+
 	ns->audit.initialized = AUDIT_INITIALIZED;
 }
 
diff --git a/kernel/audit.h b/kernel/audit.h
index ced93fe..a01c892 100644
--- a/kernel/audit.h
+++ b/kernel/audit.h
@@ -61,13 +61,12 @@ struct audit_entry {
 
 extern int audit_ever_enabled;
 
-#define AUDIT_INODE_BUCKETS	32
-extern struct list_head audit_inode_hash[AUDIT_INODE_BUCKETS];
-
+#ifdef CONFIG_AUDIT
 static inline int audit_hash_ino(u32 ino)
 {
 	return (ino & (AUDIT_INODE_BUCKETS-1));
 }
+#endif
 
 /* Indicates that audit should log the full pathname. */
 #define AUDIT_NAME_FULL -1
diff --git a/kernel/audit_watch.c b/kernel/audit_watch.c
index 22831c4..27c7a3b 100644
--- a/kernel/audit_watch.c
+++ b/kernel/audit_watch.c
@@ -309,7 +309,8 @@ static void audit_update_watch(struct audit_parent *parent,
 				audit_get_watch(nwatch);
 				nentry->rule.watch = nwatch;
 				list_add(&nentry->rule.rlist, &nwatch->rules);
-				list_add_rcu(&nentry->list, &audit_inode_hash[h]);
+				list_add_rcu(&nentry->list,
+					&init_user_ns.audit.inode_hash[h]);
 				list_replace(&oentry->rule.list,
 					     &nentry->rule.list);
 			}
@@ -441,7 +442,7 @@ int audit_add_watch(struct audit_krule *krule, struct list_head **list)
 	audit_put_parent(parent);
 
 	h = audit_hash_ino((u32)watch->ino);
-	*list = &audit_inode_hash[h];
+	*list = &init_user_ns.audit.inode_hash[h];
 error:
 	path_put(&parent_path);
 	return ret;
diff --git a/kernel/auditfilter.c b/kernel/auditfilter.c
index 2674368..573385b 100644
--- a/kernel/auditfilter.c
+++ b/kernel/auditfilter.c
@@ -885,7 +885,8 @@ struct audit_entry *audit_dupe_rule(struct audit_krule *old)
 
 /* Find an existing audit rule.
  * Caller must hold audit_filter_mutex to prevent stale rule data. */
-static struct audit_entry *audit_find_rule(struct audit_entry *entry,
+static struct audit_entry *audit_find_rule(struct user_namespace *ns,
+					   struct audit_entry *entry,
 					   struct list_head **p)
 {
 	struct audit_entry *e, *found = NULL;
@@ -894,11 +895,11 @@ static struct audit_entry *audit_find_rule(struct audit_entry *entry,
 
 	if (entry->rule.inode_f) {
 		h = audit_hash_ino(entry->rule.inode_f->val);
-		*p = list = &audit_inode_hash[h];
+		*p = list = &ns->audit.inode_hash[h];
 	} else if (entry->rule.watch) {
 		/* we don't know the inode number, so must walk entire hash */
 		for (h = 0; h < AUDIT_INODE_BUCKETS; h++) {
-			list = &audit_inode_hash[h];
+			list = &ns->audit.inode_hash[h];
 			list_for_each_entry(e, list, list)
 				if (!audit_compare_rule(&entry->rule, &e->rule)) {
 					found = e;
@@ -924,7 +925,8 @@ static u64 prio_low = ~0ULL/2;
 static u64 prio_high = ~0ULL/2 - 1;
 
 /* Add rule to given filterlist if not a duplicate. */
-static inline int audit_add_rule(struct audit_entry *entry)
+static inline int audit_add_rule(struct user_namespace *ns,
+				 struct audit_entry *entry)
 {
 	struct audit_entry *e;
 	struct audit_watch *watch = entry->rule.watch;
@@ -941,7 +943,7 @@ static inline int audit_add_rule(struct audit_entry *entry)
 #endif
 
 	mutex_lock(&audit_filter_mutex);
-	e = audit_find_rule(entry, &list);
+	e = audit_find_rule(ns, entry, &list);
 	if (e) {
 		mutex_unlock(&audit_filter_mutex);
 		err = -EEXIST;
@@ -1003,7 +1005,8 @@ error:
 }
 
 /* Remove an existing rule from filterlist. */
-static inline int audit_del_rule(struct audit_entry *entry)
+static inline int audit_del_rule(struct user_namespace *ns,
+				 struct audit_entry *entry)
 {
 	struct audit_entry  *e;
 	struct audit_watch *watch = entry->rule.watch;
@@ -1020,7 +1023,7 @@ static inline int audit_del_rule(struct audit_entry *entry)
 #endif
 
 	mutex_lock(&audit_filter_mutex);
-	e = audit_find_rule(entry, &list);
+	e = audit_find_rule(ns, entry, &list);
 	if (!e) {
 		mutex_unlock(&audit_filter_mutex);
 		ret = -ENOENT;
@@ -1162,6 +1165,7 @@ int audit_receive_filter(int type, int pid, int seq, void *data,
 	struct audit_netlink_list *dest;
 	int err = 0;
 	struct audit_entry *entry;
+	struct user_namespace *ns = current_user_ns();
 
 	switch (type) {
 	case AUDIT_LIST:
@@ -1201,7 +1205,7 @@ int audit_receive_filter(int type, int pid, int seq, void *data,
 		if (IS_ERR(entry))
 			return PTR_ERR(entry);
 
-		err = audit_add_rule(entry);
+		err = audit_add_rule(ns, entry);
 		audit_log_rule_change(loginuid, sessionid, sid, "add rule",
 				      &entry->rule, !err);
 
@@ -1217,7 +1221,7 @@ int audit_receive_filter(int type, int pid, int seq, void *data,
 		if (IS_ERR(entry))
 			return PTR_ERR(entry);
 
-		err = audit_del_rule(entry);
+		err = audit_del_rule(ns, entry);
 		audit_log_rule_change(loginuid, sessionid, sid, "remove rule",
 				      &entry->rule, !err);
 
diff --git a/kernel/auditsc.c b/kernel/auditsc.c
index 290cce6..55bd99e 100644
--- a/kernel/auditsc.c
+++ b/kernel/auditsc.c
@@ -902,7 +902,7 @@ static int audit_filter_inode_name(struct task_struct *tsk,
 				   struct audit_context *ctx) {
 	int word, bit;
 	int h = audit_hash_ino((u32)n->ino);
-	struct list_head *list = &audit_inode_hash[h];
+	struct list_head *list = &init_user_ns.audit.inode_hash[h];
 	struct audit_entry *e;
 	enum audit_state state;
 
-- 
1.8.1.4
