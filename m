From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH RFC 32/48] Audit: pass proper user namespace to
	audit_filter_inode_name
Date: Tue, 7 May 2013 10:20:53 +0800
Message-ID: <1367893269-9308-33-git-send-email-gaofeng@cn.fujitsu.com>
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

We should use the right inode_hash list to filter the
task.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/audit.h       |  5 +++--
 kernel/audit_watch.c |  3 ++-
 kernel/auditsc.c     | 14 ++++++++------
 3 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/kernel/audit.h b/kernel/audit.h
index 7934598..0079cdd 100644
--- a/kernel/audit.h
+++ b/kernel/audit.h
@@ -157,11 +157,12 @@ static inline int audit_signal_info(int sig, struct task_struct *t)
 		return __audit_signal_info(sig, t);
 	return 0;
 }
-extern void audit_filter_inodes(struct task_struct *, struct audit_context *);
+extern void audit_filter_inodes(struct user_namespace *ns,
+				struct task_struct *, struct audit_context *);
 extern struct list_head *audit_killed_trees(void);
 #else
 #define audit_signal_info(s,t) AUDIT_DISABLED
-#define audit_filter_inodes(t,c) AUDIT_DISABLED
+#define audit_filter_inodes(n, t, c) AUDIT_DISABLED
 #endif
 
 extern struct mutex audit_cmd_mutex;
diff --git a/kernel/audit_watch.c b/kernel/audit_watch.c
index 27c7a3b..6be4cbe 100644
--- a/kernel/audit_watch.c
+++ b/kernel/audit_watch.c
@@ -274,7 +274,8 @@ static void audit_update_watch(struct audit_parent *parent,
 		/* If the update involves invalidating rules, do the inode-based
 		 * filtering now, so we don't omit records. */
 		if (invalidating && !audit_dummy_context())
-			audit_filter_inodes(current, current->audit_context);
+			audit_filter_inodes(current_user_ns(), current,
+					    current->audit_context);
 
 		/* updating ino will likely change which audit_hash_list we
 		 * are on so we need a new watch for the new list */
diff --git a/kernel/auditsc.c b/kernel/auditsc.c
index 5401d21..3e3e7c7 100644
--- a/kernel/auditsc.c
+++ b/kernel/auditsc.c
@@ -900,12 +900,13 @@ static enum audit_state audit_filter_syscall(struct user_namespace *ns,
  * Given an audit_name check the inode hash table to see if they match.
  * Called holding the rcu read lock to protect the use of audit_inode_hash
  */
-static int audit_filter_inode_name(struct task_struct *tsk,
+static int audit_filter_inode_name(struct user_namespace *ns,
+				   struct task_struct *tsk,
 				   struct audit_names *n,
 				   struct audit_context *ctx) {
 	int word, bit;
 	int h = audit_hash_ino((u32)n->ino);
-	struct list_head *list = &init_user_ns.audit.inode_hash[h];
+	struct list_head *list = &ns->audit.inode_hash[h];
 	struct audit_entry *e;
 	enum audit_state state;
 
@@ -931,17 +932,18 @@ static int audit_filter_inode_name(struct task_struct *tsk,
  * buckets applicable to the inode numbers in audit_names.
  * Regarding audit_state, same rules apply as for audit_filter_syscall().
  */
-void audit_filter_inodes(struct task_struct *tsk, struct audit_context *ctx)
+void audit_filter_inodes(struct user_namespace *ns,
+			 struct task_struct *tsk, struct audit_context *ctx)
 {
 	struct audit_names *n;
 
-	if (init_user_ns.audit.pid && tsk->tgid == init_user_ns.audit.pid)
+	if (ns->audit.pid && tsk->tgid == ns->audit.pid)
 		return;
 
 	rcu_read_lock();
 
 	list_for_each_entry(n, &ctx->names_list, list) {
-		if (audit_filter_inode_name(tsk, n, ctx))
+		if (audit_filter_inode_name(ns, tsk, n, ctx))
 			break;
 	}
 	rcu_read_unlock();
@@ -979,7 +981,7 @@ static inline struct audit_context *audit_get_context(struct task_struct *tsk,
 	if (context->in_syscall && !context->dummy) {
 		audit_filter_syscall(ns, tsk, context,
 				&ns->audit.filter_list[AUDIT_FILTER_EXIT]);
-		audit_filter_inodes(tsk, context);
+		audit_filter_inodes(ns, tsk, context);
 	}
 
 	tsk->audit_context = NULL;
-- 
1.8.1.4
