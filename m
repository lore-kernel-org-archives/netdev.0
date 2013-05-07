From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH RFC 29/48] Audit: make audit_krule belongs to user namespace
Date: Tue, 7 May 2013 10:20:50 +0800
Message-ID: <1367893269-9308-30-git-send-email-gaofeng@cn.fujitsu.com>
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

Since update_lsm_rules will update all audit_krule, we still
have to make audit_rules_list global. this patch add a field
user_ns to struct audit_krule to point out which user namespace
this audit rule belongs to.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/linux/audit.h |  1 +
 kernel/auditfilter.c  | 19 +++++++++++++++----
 2 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/include/linux/audit.h b/include/linux/audit.h
index f16db07..885e842 100644
--- a/include/linux/audit.h
+++ b/include/linux/audit.h
@@ -59,6 +59,7 @@ struct audit_krule {
 	struct audit_field	*inode_f; /* quick access to an inode field */
 	struct audit_watch	*watch;	/* associated watch */
 	struct audit_tree	*tree;	/* associated watched tree */
+	struct user_namespace   *user_ns; /* belongs to this user namespace */
 	struct list_head	rlist;	/* entry in audit_{watch,tree}.rules list */
 	struct list_head	list;	/* for AUDIT_LIST* purposes only */
 	u64			prio;
diff --git a/kernel/auditfilter.c b/kernel/auditfilter.c
index dbf05a9..cf7fe98 100644
--- a/kernel/auditfilter.c
+++ b/kernel/auditfilter.c
@@ -822,6 +822,7 @@ struct audit_entry *audit_dupe_rule(struct audit_krule *old)
 	new->buflen = old->buflen;
 	new->inode_f = old->inode_f;
 	new->field_count = old->field_count;
+	new->user_ns = old->user_ns;
 
 	/*
 	 * note that we are OK with not refcounting here; audit_match_tree()
@@ -965,6 +966,7 @@ static inline int audit_add_rule(struct user_namespace *ns,
 			entry->rule.prio = --prio_low;
 	}
 
+	entry->rule.user_ns = get_user_ns(ns);
 	if (entry->rule.flags & AUDIT_FILTER_PREPEND) {
 		list_add(&entry->rule.list,
 			 &audit_rules_list[entry->rule.listnr]);
@@ -1026,6 +1028,7 @@ static inline int audit_del_rule(struct user_namespace *ns,
 
 	list_del_rcu(&e->list);
 	list_del(&e->rule.list);
+	put_user_ns(e->rule.user_ns);
 	call_rcu(&e->rcu, audit_free_rule_rcu);
 
 #ifdef CONFIG_AUDITSYSCALL
@@ -1048,7 +1051,8 @@ out:
 
 /* List rules using struct audit_rule.  Exists for backward
  * compatibility with userspace. */
-static void audit_list(int pid, int seq, struct sk_buff_head *q)
+static void audit_list(struct user_namespace *ns,
+		       int pid, int seq, struct sk_buff_head *q)
 {
 	struct sk_buff *skb;
 	struct audit_krule *r;
@@ -1060,6 +1064,9 @@ static void audit_list(int pid, int seq, struct sk_buff_head *q)
 		list_for_each_entry(r, &audit_rules_list[i], list) {
 			struct audit_rule *rule;
 
+			if (r->user_ns != ns)
+				continue;
+
 			rule = audit_krule_to_rule(r);
 			if (unlikely(!rule))
 				break;
@@ -1076,7 +1083,8 @@ static void audit_list(int pid, int seq, struct sk_buff_head *q)
 }
 
 /* List rules using struct audit_rule_data. */
-static void audit_list_rules(int pid, int seq, struct sk_buff_head *q)
+static void audit_list_rules(struct user_namespace *ns,
+			     int pid, int seq, struct sk_buff_head *q)
 {
 	struct sk_buff *skb;
 	struct audit_krule *r;
@@ -1088,6 +1096,9 @@ static void audit_list_rules(int pid, int seq, struct sk_buff_head *q)
 		list_for_each_entry(r, &audit_rules_list[i], list) {
 			struct audit_rule_data *data;
 
+			if (r->user_ns != ns)
+				continue;
+
 			data = audit_krule_to_data(r);
 			if (unlikely(!data))
 				break;
@@ -1172,9 +1183,9 @@ int audit_receive_filter(int type, int pid, int seq, void *data,
 
 		mutex_lock(&audit_filter_mutex);
 		if (type == AUDIT_LIST)
-			audit_list(pid, seq, &dest->q);
+			audit_list(ns, pid, seq, &dest->q);
 		else
-			audit_list_rules(pid, seq, &dest->q);
+			audit_list_rules(ns, pid, seq, &dest->q);
 		mutex_unlock(&audit_filter_mutex);
 
 		tsk = kthread_run(audit_send_list, dest, "audit_send_list");
-- 
1.8.1.4
