From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH RFC 44/48] Audit: rename audit_log_start_ns to audit_log_start
Date: Tue, 7 May 2013 10:21:05 +0800
Message-ID: <1367893269-9308-45-git-send-email-gaofeng@cn.fujitsu.com>
References: <1367893269-9308-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-audit@redhat.com,
	Gao feng <gaofeng@cn.fujitsu.com>
To: viro@zeniv.linux.org.uk, eparis@redhat.com, ebiederm@xmission.com,
	sgrubb@redhat.com, akpm@linux-foundation.org,
	serge.hallyn@ubuntu.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1367893269-9308-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now all of the audit caller have been namespace aware,
we can rename audit_log_start_ns to audit_log_start,
we just need a namespace awared audit interface.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 drivers/tty/tty_audit.c             |  4 +-
 include/linux/audit.h               | 28 ++++-------
 include/net/xfrm.h                  |  4 +-
 kernel/audit.c                      | 94 ++++++++++++++++---------------------
 kernel/audit_tree.c                 |  4 +-
 kernel/audit_watch.c                |  4 +-
 kernel/auditfilter.c                |  4 +-
 kernel/auditsc.c                    | 56 +++++++++++-----------
 net/ipv4/cipso_ipv4.c               |  4 +-
 net/netfilter/x_tables.c            |  4 +-
 net/netfilter/xt_AUDIT.c            |  4 +-
 net/netlabel/netlabel_domainhash.c  |  4 +-
 net/netlabel/netlabel_unlabeled.c   |  8 ++--
 net/netlabel/netlabel_user.c        |  4 +-
 net/xfrm/xfrm_policy.c              |  4 +-
 net/xfrm/xfrm_state.c               | 14 +++---
 security/integrity/ima/ima_api.c    |  6 +--
 security/integrity/ima/ima_audit.c  |  6 +--
 security/integrity/ima/ima_policy.c |  4 +-
 security/lsm_audit.c                |  6 +--
 security/selinux/hooks.c            | 16 +++----
 security/selinux/ss/services.c      |  6 +--
 22 files changed, 131 insertions(+), 157 deletions(-)

diff --git a/drivers/tty/tty_audit.c b/drivers/tty/tty_audit.c
index b20ef14..7dfa931 100644
--- a/drivers/tty/tty_audit.c
+++ b/drivers/tty/tty_audit.c
@@ -67,7 +67,7 @@ static void tty_audit_log(const char *description, struct task_struct *tsk,
 	struct audit_buffer *ab;
 	struct user_namespace *ns = task_cred_xxx(tsk, user_ns);
 
-	ab = audit_log_start_ns(ns, NULL, GFP_KERNEL, AUDIT_TTY);
+	ab = audit_log_start(ns, NULL, GFP_KERNEL, AUDIT_TTY);
 	if (ab) {
 		char name[sizeof(tsk->comm)];
 		kuid_t uid = task_uid(tsk);
@@ -83,7 +83,7 @@ static void tty_audit_log(const char *description, struct task_struct *tsk,
 		audit_log_untrustedstring(ab, name);
 		audit_log_format(ab, " data=");
 		audit_log_n_hex(ab, data, size);
-		audit_log_end_ns(ns, ab);
+		audit_log_end(ns, ab);
 	}
 }
 
diff --git a/include/linux/audit.h b/include/linux/audit.h
index 885e842..a46efa3 100644
--- a/include/linux/audit.h
+++ b/include/linux/audit.h
@@ -400,17 +400,13 @@ void audit_log(struct audit_context *ctx, gfp_t gfp_mask, int type,
 	       const char *fmt, ...);
 
 extern struct audit_buffer *
-audit_log_start(struct audit_context *ctx, gfp_t gfp_mask, int type);
-
-extern struct audit_buffer *
-audit_log_start_ns(struct user_namespace *ns, struct audit_context *ctx,
-		   gfp_t gfp_mask, int type);
+audit_log_start(struct user_namespace *ns, struct audit_context *ctx,
+		gfp_t gfp_mask, int type);
 
 extern __printf(2, 3)
 void audit_log_format(struct audit_buffer *ab, const char *fmt, ...);
-extern void		    audit_log_end(struct audit_buffer *ab);
-extern void		    audit_log_end_ns(struct user_namespace *ns,
-					     struct audit_buffer *ab);
+extern void		    audit_log_end(struct user_namespace *ns,
+					  struct audit_buffer *ab);
 extern int		    audit_string_contains_control(const char *string,
 							  size_t len);
 extern void		    audit_log_n_hex(struct audit_buffer *ab,
@@ -458,25 +454,17 @@ void audit_log(struct audit_context *ctx, gfp_t gfp_mask, int type,
 	       const char *fmt, ...)
 { }
 static inline
-struct audit_buffer *audit_log_start(struct audit_context *ctx,
+struct audit_buffer *audit_log_start(struct user_namespace *ns,
+				     struct audit_context *ctx,
 				     gfp_t gfp_mask, int type)
 {
 	return NULL;
 }
-static inline
-struct audit_buffer *audit_log_start_ns(struct user_namespace *ns,
-					struct audit_context *ctx,
-					gfp_t gfp_mask, int type)
-{
-	return NULL;
-}
 static inline __printf(2, 3)
 void audit_log_format(struct audit_buffer *ab, const char *fmt, ...)
 { }
-static inline void audit_log_end(struct audit_buffer *ab)
-{ }
-static inline void audit_log_end_ns(struct user_namespace *ns,
-				    struct audit_buffer *ab)
+static inline void audit_log_end(struct user_namespace *ns,
+				 struct audit_buffer *ab)
 { }
 static inline void audit_log_n_hex(struct audit_buffer *ab,
 				   const unsigned char *buf, size_t len)
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 1a99744..bb4d6b2 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -687,8 +687,8 @@ static inline struct audit_buffer *xfrm_audit_start(const char *op)
 
 	if (audit_enabled_ns(ns) == 0)
 		return NULL;
-	audit_buf = audit_log_start_ns(ns, current->audit_context,
-				       GFP_ATOMIC, AUDIT_MAC_IPSEC_EVENT);
+	audit_buf = audit_log_start(ns, current->audit_context,
+				    GFP_ATOMIC, AUDIT_MAC_IPSEC_EVENT);
 	if (audit_buf == NULL)
 		return NULL;
 	audit_log_format(audit_buf, "op=%s", op);
diff --git a/kernel/audit.c b/kernel/audit.c
index 926d59b..da1c0ad 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -249,7 +249,7 @@ static int audit_log_config_change(char *function_name, int new, int old,
 	struct user_namespace *ns = current_user_ns();
 	int rc = 0;
 
-	ab = audit_log_start_ns(ns, NULL, GFP_KERNEL, AUDIT_CONFIG_CHANGE);
+	ab = audit_log_start(ns, NULL, GFP_KERNEL, AUDIT_CONFIG_CHANGE);
 	if (unlikely(!ab))
 		return rc;
 	audit_log_format(ab, "%s=%d old=%d auid=%u ses=%u", function_name, new,
@@ -268,7 +268,7 @@ static int audit_log_config_change(char *function_name, int new, int old,
 		}
 	}
 	audit_log_format(ab, " res=%d", allow_changes);
-	audit_log_end_ns(ns, ab);
+	audit_log_end(ns, ab);
 	return rc;
 }
 
@@ -619,7 +619,7 @@ static int audit_log_common_recv_msg(struct user_namespace *ns,
 		return rc;
 	}
 
-	*ab = audit_log_start_ns(ns, NULL, GFP_KERNEL, msg_type);
+	*ab = audit_log_start(ns, NULL, GFP_KERNEL, msg_type);
 	if (unlikely(!*ab))
 		return rc;
 	audit_log_format(*ab, "pid=%d uid=%u auid=%u ses=%u",
@@ -759,7 +759,7 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 				audit_log_n_untrustedstring(ab, data, size);
 			}
 			audit_set_pid(ab, NETLINK_CB(skb).portid);
-			audit_log_end_ns(ns, ab);
+			audit_log_end(ns, ab);
 		}
 		break;
 	case AUDIT_ADD:
@@ -772,7 +772,7 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 			audit_log_format(ab, " audit_enabled=%d res=0",
 					 ns->audit.enabled);
-			audit_log_end_ns(ns, ab);
+			audit_log_end(ns, ab);
 			return -EPERM;
 		}
 		/* fallthrough */
@@ -791,7 +791,7 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 			audit_log_format(ab, " audit_enabled=%d res=0",
 					 ns->audit.enabled);
-			audit_log_end_ns(ns, ab);
+			audit_log_end(ns, ab);
 			return -EPERM;
 		}
 		/* fallthrough */
@@ -807,7 +807,7 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 					  loginuid, sessionid, sid);
 
 		audit_log_format(ab, " op=trim res=1");
-		audit_log_end_ns(ns, ab);
+		audit_log_end(ns, ab);
 		break;
 	case AUDIT_MAKE_EQUIV: {
 		void *bufp = data;
@@ -843,7 +843,7 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		audit_log_format(ab, " new=");
 		audit_log_untrustedstring(ab, new);
 		audit_log_format(ab, " res=%d", !err);
-		audit_log_end_ns(ns, ab);
+		audit_log_end(ns, ab);
 		kfree(old);
 		kfree(new);
 		break;
@@ -1153,10 +1153,24 @@ static void wait_for_auditd(struct user_namespace *ns,
 	remove_wait_queue(&ns->audit.backlog_wait, &wait);
 }
 
-struct audit_buffer *audit_log_start_ns(struct user_namespace *ns,
-					struct audit_context *ctx,
-					gfp_t gfp_mask,
-					int type)
+/**
+ * audit_log_start - obtain an audit buffer
+ * @ctx: audit_context (may be NULL)
+ * @gfp_mask: type of allocation
+ * @type: audit message type
+ *
+ * Returns audit_buffer pointer on success or NULL on error.
+ *
+ * Obtain an audit buffer.  This routine does locking to obtain the
+ * audit buffer, but then no locking is required for calls to
+ * audit_log_*format.  If the task (ctx) is a task that is currently in a
+ * syscall, then the syscall is marked as auditable and an audit record
+ * will be written at syscall exit.  If there is no associated task, then
+ * task context (ctx) should be NULL.
+ */
+struct audit_buffer *audit_log_start(struct user_namespace *ns,
+				     struct audit_context *ctx,
+				     gfp_t gfp_mask, int type)
 {
 	struct audit_buffer	*ab	= NULL;
 	struct timespec		t;
@@ -1215,27 +1229,6 @@ struct audit_buffer *audit_log_start_ns(struct user_namespace *ns,
 
 
 /**
- * audit_log_start - obtain an audit buffer
- * @ctx: audit_context (may be NULL)
- * @gfp_mask: type of allocation
- * @type: audit message type
- *
- * Returns audit_buffer pointer on success or NULL on error.
- *
- * Obtain an audit buffer.  This routine does locking to obtain the
- * audit buffer, but then no locking is required for calls to
- * audit_log_*format.  If the task (ctx) is a task that is currently in a
- * syscall, then the syscall is marked as auditable and an audit record
- * will be written at syscall exit.  If there is no associated task, then
- * task context (ctx) should be NULL.
- */
-struct audit_buffer *audit_log_start(struct audit_context *ctx, gfp_t gfp_mask,
-				     int type)
-{
-	return audit_log_start_ns(&init_user_ns, ctx, gfp_mask, type);
-}
-
-/**
  * audit_expand - expand skb in the audit buffer
  * @ab: audit_buffer
  * @extra: space to add at tail of the skb
@@ -1491,7 +1484,7 @@ void audit_log_link_denied(const char *operation, struct path *link)
 	struct audit_buffer *ab;
 	struct user_namespace *ns = current_user_ns();
 
-	ab = audit_log_start_ns(ns, current->audit_context, GFP_KERNEL,
+	ab = audit_log_start(ns, current->audit_context, GFP_KERNEL,
 				AUDIT_ANOM_LINK);
 	if (!ab)
 		return;
@@ -1502,10 +1495,19 @@ void audit_log_link_denied(const char *operation, struct path *link)
 	audit_log_format(ab, " dev=");
 	audit_log_untrustedstring(ab, link->dentry->d_inode->i_sb->s_id);
 	audit_log_format(ab, " ino=%lu", link->dentry->d_inode->i_ino);
-	audit_log_end_ns(ns, ab);
+	audit_log_end(ns, ab);
 }
 
-void audit_log_end_ns(struct user_namespace *ns, struct audit_buffer *ab)
+/**
+ * audit_log_end - end one audit record
+ * @ab: the audit_buffer
+ *
+ * The netlink_* functions cannot be called inside an irq context, so
+ * the audit buffer is placed on a queue and a tasklet is scheduled to
+ * remove them from the queue outside the irq context.  May be called in
+ * any context.
+ */
+void audit_log_end(struct user_namespace *ns, struct audit_buffer *ab)
 {
 	if (!ab)
 		return;
@@ -1528,20 +1530,6 @@ void audit_log_end_ns(struct user_namespace *ns, struct audit_buffer *ab)
 }
 
 /**
- * audit_log_end - end one audit record
- * @ab: the audit_buffer
- *
- * The netlink_* functions cannot be called inside an irq context, so
- * the audit buffer is placed on a queue and a tasklet is scheduled to
- * remove them from the queue outside the irq context.  May be called in
- * any context.
- */
-void audit_log_end(struct audit_buffer *ab)
-{
-	audit_log_end_ns(&init_user_ns, ab);
-}
-
-/**
  * audit_log - Log an audit record
  * @ctx: audit context
  * @gfp_mask: type of allocation
@@ -1559,12 +1547,12 @@ void audit_log(struct audit_context *ctx, gfp_t gfp_mask, int type,
 	struct audit_buffer *ab;
 	va_list args;
 
-	ab = audit_log_start_ns(&init_user_ns, ctx, gfp_mask, type);
+	ab = audit_log_start(&init_user_ns, ctx, gfp_mask, type);
 	if (ab) {
 		va_start(args, fmt);
 		audit_log_vformat(ab, fmt, args);
 		va_end(args);
-		audit_log_end_ns(&init_user_ns, ab);
+		audit_log_end(&init_user_ns, ab);
 	}
 }
 
@@ -1639,9 +1627,7 @@ void audit_free_user_ns(struct user_namespace *ns)
 }
 
 EXPORT_SYMBOL(audit_log_start);
-EXPORT_SYMBOL(audit_log_start_ns);
 EXPORT_SYMBOL(audit_log_end);
-EXPORT_SYMBOL(audit_log_end_ns);
 EXPORT_SYMBOL(audit_log_format);
 EXPORT_SYMBOL(audit_log);
 EXPORT_SYMBOL(audit_set_user_ns);
diff --git a/kernel/audit_tree.c b/kernel/audit_tree.c
index 521766d..20ffef8 100644
--- a/kernel/audit_tree.c
+++ b/kernel/audit_tree.c
@@ -453,7 +453,7 @@ static void audit_log_remove_rule(struct user_namespace *ns,
 {
 	struct audit_buffer *ab;
 
-	ab = audit_log_start_ns(ns, NULL, GFP_KERNEL, AUDIT_CONFIG_CHANGE);
+	ab = audit_log_start(ns, NULL, GFP_KERNEL, AUDIT_CONFIG_CHANGE);
 	if (unlikely(!ab))
 		return;
 	audit_log_format(ab, "op=");
@@ -462,7 +462,7 @@ static void audit_log_remove_rule(struct user_namespace *ns,
 	audit_log_untrustedstring(ab, rule->tree->pathname);
 	audit_log_key(ab, rule->filterkey);
 	audit_log_format(ab, " list=%d res=1", rule->listnr);
-	audit_log_end_ns(ns, ab);
+	audit_log_end(ns, ab);
 }
 
 static void kill_rules(struct user_namespace *ns, struct audit_tree *tree)
diff --git a/kernel/audit_watch.c b/kernel/audit_watch.c
index 1bac505..4dcc331 100644
--- a/kernel/audit_watch.c
+++ b/kernel/audit_watch.c
@@ -242,7 +242,7 @@ static void audit_watch_log_rule_change(struct audit_krule *r,
 
 	if (audit_enabled_ns(ns)) {
 		struct audit_buffer *ab;
-		ab = audit_log_start_ns(ns, NULL, GFP_NOFS,
+		ab = audit_log_start(ns, NULL, GFP_NOFS,
 					AUDIT_CONFIG_CHANGE);
 		if (unlikely(!ab))
 			return;
@@ -254,7 +254,7 @@ static void audit_watch_log_rule_change(struct audit_krule *r,
 		audit_log_untrustedstring(ab, w->path);
 		audit_log_key(ab, r->filterkey);
 		audit_log_format(ab, " list=%d res=1", r->listnr);
-		audit_log_end_ns(ns, ab);
+		audit_log_end(ns, ab);
 	}
 }
 
diff --git a/kernel/auditfilter.c b/kernel/auditfilter.c
index 8af148b..6052f57 100644
--- a/kernel/auditfilter.c
+++ b/kernel/auditfilter.c
@@ -1125,7 +1125,7 @@ static void audit_log_rule_change(kuid_t loginuid, u32 sessionid, u32 sid,
 	if (!ns->audit.enabled)
 		return;
 
-	ab = audit_log_start_ns(ns, NULL, GFP_KERNEL, AUDIT_CONFIG_CHANGE);
+	ab = audit_log_start(ns, NULL, GFP_KERNEL, AUDIT_CONFIG_CHANGE);
 	if (!ab)
 		return;
 	audit_log_format(ab, "auid=%u ses=%u",
@@ -1144,7 +1144,7 @@ static void audit_log_rule_change(kuid_t loginuid, u32 sessionid, u32 sid,
 	audit_log_string(ab, action);
 	audit_log_key(ab, rule->filterkey);
 	audit_log_format(ab, " list=%d res=%d", rule->listnr, res);
-	audit_log_end_ns(ns, ab);
+	audit_log_end(ns, ab);
 }
 
 /**
diff --git a/kernel/auditsc.c b/kernel/auditsc.c
index 3c5ced9..a65020a 100644
--- a/kernel/auditsc.c
+++ b/kernel/auditsc.c
@@ -1195,7 +1195,7 @@ static int audit_log_pid_context(struct user_namespace *ns,
 	u32 len;
 	int rc = 0;
 
-	ab = audit_log_start_ns(ns, context, GFP_KERNEL, AUDIT_OBJ_PID);
+	ab = audit_log_start(ns, context, GFP_KERNEL, AUDIT_OBJ_PID);
 	if (!ab)
 		return rc;
 
@@ -1211,7 +1211,7 @@ static int audit_log_pid_context(struct user_namespace *ns,
 	}
 	audit_log_format(ab, " ocomm=");
 	audit_log_untrustedstring(ab, comm);
-	audit_log_end_ns(ns, ab);
+	audit_log_end(ns, ab);
 
 	return rc;
 }
@@ -1313,8 +1313,8 @@ static int audit_log_single_execve_arg(struct audit_context *context,
 			room_left -= to_send;
 		if (room_left < 0) {
 			*len_sent = 0;
-			audit_log_end_ns(ns, *ab);
-			*ab = audit_log_start_ns(ns, context,
+			audit_log_end(ns, *ab);
+			*ab = audit_log_start(ns, context,
 						 GFP_KERNEL, AUDIT_EXECVE);
 			if (!*ab)
 				return 0;
@@ -1439,7 +1439,7 @@ static void show_special(struct user_namespace *ns,
 	struct audit_buffer *ab;
 	int i;
 
-	ab = audit_log_start_ns(ns, context, GFP_KERNEL, context->type);
+	ab = audit_log_start(ns, context, GFP_KERNEL, context->type);
 	if (!ab)
 		return;
 
@@ -1470,8 +1470,8 @@ static void show_special(struct user_namespace *ns,
 			}
 		}
 		if (context->ipc.has_perm) {
-			audit_log_end_ns(ns, ab);
-			ab = audit_log_start_ns(ns, context, GFP_KERNEL,
+			audit_log_end(ns, ab);
+			ab = audit_log_start(ns, context, GFP_KERNEL,
 						AUDIT_IPC_SET_PERM);
 			if (unlikely(!ab))
 				return;
@@ -1528,7 +1528,7 @@ static void show_special(struct user_namespace *ns,
 				 context->mmap.flags);
 		break; }
 	}
-	audit_log_end_ns(ns, ab);
+	audit_log_end(ns, ab);
 }
 
 static void audit_log_name(struct user_namespace *ns,
@@ -1536,7 +1536,7 @@ static void audit_log_name(struct user_namespace *ns,
 			   int record_num, int *call_panic)
 {
 	struct audit_buffer *ab;
-	ab = audit_log_start_ns(ns, context, GFP_KERNEL, AUDIT_PATH);
+	ab = audit_log_start(ns, context, GFP_KERNEL, AUDIT_PATH);
 	if (!ab)
 		return; /* audit_panic has been called */
 
@@ -1591,7 +1591,7 @@ static void audit_log_name(struct user_namespace *ns,
 
 	audit_log_fcaps(ab, n);
 
-	audit_log_end_ns(ns, ab);
+	audit_log_end(ns, ab);
 }
 
 static void audit_log_exit(struct audit_context *context, struct task_struct *tsk)
@@ -1605,7 +1605,7 @@ static void audit_log_exit(struct audit_context *context, struct task_struct *ts
 	/* tsk == current */
 	context->personality = tsk->personality;
 
-	ab = audit_log_start_ns(ns, context, GFP_KERNEL, AUDIT_SYSCALL);
+	ab = audit_log_start(ns, context, GFP_KERNEL, AUDIT_SYSCALL);
 	if (!ab)
 		return;		/* audit_panic has been called */
 	audit_log_format(ab, "arch=%x syscall=%d",
@@ -1627,11 +1627,11 @@ static void audit_log_exit(struct audit_context *context, struct task_struct *ts
 
 	audit_log_task_info(ab, tsk);
 	audit_log_key(ab, context->filterkey);
-	audit_log_end_ns(ns, ab);
+	audit_log_end(ns, ab);
 
 	for (aux = context->aux; aux; aux = aux->next) {
 
-		ab = audit_log_start_ns(ns, context, GFP_KERNEL, aux->type);
+		ab = audit_log_start(ns, context, GFP_KERNEL, aux->type);
 		if (!ab)
 			continue; /* audit_panic has been called */
 
@@ -1657,28 +1657,28 @@ static void audit_log_exit(struct audit_context *context, struct task_struct *ts
 			break; }
 
 		}
-		audit_log_end_ns(ns, ab);
+		audit_log_end(ns, ab);
 	}
 
 	if (context->type)
 		show_special(ns, context, &call_panic);
 
 	if (context->fds[0] >= 0) {
-		ab = audit_log_start_ns(ns, context, GFP_KERNEL, AUDIT_FD_PAIR);
+		ab = audit_log_start(ns, context, GFP_KERNEL, AUDIT_FD_PAIR);
 		if (ab) {
 			audit_log_format(ab, "fd0=%d fd1=%d",
 					context->fds[0], context->fds[1]);
-			audit_log_end_ns(ns, ab);
+			audit_log_end(ns, ab);
 		}
 	}
 
 	if (context->sockaddr_len) {
-		ab = audit_log_start_ns(ns, context, GFP_KERNEL, AUDIT_SOCKADDR);
+		ab = audit_log_start(ns, context, GFP_KERNEL, AUDIT_SOCKADDR);
 		if (ab) {
 			audit_log_format(ab, "saddr=");
 			audit_log_n_hex(ab, (void *)context->sockaddr,
 					context->sockaddr_len);
-			audit_log_end_ns(ns, ab);
+			audit_log_end(ns, ab);
 		}
 	}
 
@@ -1704,10 +1704,10 @@ static void audit_log_exit(struct audit_context *context, struct task_struct *ts
 			call_panic = 1;
 
 	if (context->pwd.dentry && context->pwd.mnt) {
-		ab = audit_log_start_ns(ns, context, GFP_KERNEL, AUDIT_CWD);
+		ab = audit_log_start(ns, context, GFP_KERNEL, AUDIT_CWD);
 		if (ab) {
 			audit_log_d_path(ab, " cwd=", &context->pwd);
-			audit_log_end_ns(ns, ab);
+			audit_log_end(ns, ab);
 		}
 	}
 
@@ -1716,9 +1716,9 @@ static void audit_log_exit(struct audit_context *context, struct task_struct *ts
 		audit_log_name(ns, context, n, i++, &call_panic);
 
 	/* Send end of event record to help user space know we are finished */
-	ab = audit_log_start_ns(ns, context, GFP_KERNEL, AUDIT_EOE);
+	ab = audit_log_start(ns, context, GFP_KERNEL, AUDIT_EOE);
 	if (ab)
-		audit_log_end_ns(ns, ab);
+		audit_log_end(ns, ab);
 	if (call_panic)
 		audit_panic("error converting sid to string");
 }
@@ -2337,7 +2337,7 @@ int audit_set_loginuid(kuid_t loginuid)
 		struct audit_buffer *ab;
 		struct user_namespace *ns = current_user_ns();
 
-		ab = audit_log_start_ns(ns, NULL, GFP_KERNEL, AUDIT_LOGIN);
+		ab = audit_log_start(ns, NULL, GFP_KERNEL, AUDIT_LOGIN);
 		if (ab) {
 			audit_log_format(ab, "login pid=%d uid=%u "
 				"old auid=%u new auid=%u"
@@ -2347,7 +2347,7 @@ int audit_set_loginuid(kuid_t loginuid)
 				from_kuid(&init_user_ns, task->loginuid),
 				from_kuid(&init_user_ns, loginuid),
 				task->sessionid, sessionid);
-			audit_log_end_ns(ns, ab);
+			audit_log_end(ns, ab);
 		}
 	}
 	task->sessionid = sessionid;
@@ -2740,11 +2740,11 @@ void audit_core_dumps(long signr)
 	if (signr == SIGQUIT)	/* don't care for those */
 		return;
 
-	ab = audit_log_start_ns(ns, NULL, GFP_KERNEL, AUDIT_ANOM_ABEND);
+	ab = audit_log_start(ns, NULL, GFP_KERNEL, AUDIT_ANOM_ABEND);
 	if (unlikely(!ab))
 		return;
 	audit_log_abend(ns, ab, "memory violation", signr);
-	audit_log_end_ns(ns, ab);
+	audit_log_end(ns, ab);
 }
 
 void __audit_seccomp(unsigned long syscall, long signr, int code)
@@ -2752,7 +2752,7 @@ void __audit_seccomp(unsigned long syscall, long signr, int code)
 	struct audit_buffer *ab;
 	struct user_namespace *ns = current_user_ns();
 
-	ab = audit_log_start_ns(ns, NULL, GFP_KERNEL, AUDIT_SECCOMP);
+	ab = audit_log_start(ns, NULL, GFP_KERNEL, AUDIT_SECCOMP);
 	if (unlikely(!ab))
 		return;
 	audit_log_task(ns, ab);
@@ -2761,7 +2761,7 @@ void __audit_seccomp(unsigned long syscall, long signr, int code)
 	audit_log_format(ab, " compat=%d", is_compat_task());
 	audit_log_format(ab, " ip=0x%lx", KSTK_EIP(current));
 	audit_log_format(ab, " code=0x%x", code);
-	audit_log_end_ns(ns, ab);
+	audit_log_end(ns, ab);
 }
 
 struct list_head *audit_killed_trees(void)
diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
index b021445..d365d84 100644
--- a/net/ipv4/cipso_ipv4.c
+++ b/net/ipv4/cipso_ipv4.c
@@ -532,7 +532,7 @@ doi_add_return:
 		audit_log_format(audit_buf,
 				 " cipso_doi=%u cipso_type=%s res=%u",
 				 doi, type_str, ret_val == 0 ? 1 : 0);
-		audit_log_end_ns(current_user_ns(), audit_buf);
+		audit_log_end(current_user_ns(), audit_buf);
 	}
 
 	return ret_val;
@@ -622,7 +622,7 @@ doi_remove_return:
 		audit_log_format(audit_buf,
 				 " cipso_doi=%u res=%u",
 				 doi, ret_val == 0 ? 1 : 0);
-		audit_log_end_ns(current_user_ns(), audit_buf);
+		audit_log_end(current_user_ns(), audit_buf);
 	}
 
 	return ret_val;
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index ba90a1b..8be219e 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -861,13 +861,13 @@ xt_replace_table(struct xt_table *table,
 	if (audit_enabled_ns(ns)) {
 		struct audit_buffer *ab;
 
-		ab = audit_log_start_ns(ns, current->audit_context,
+		ab = audit_log_start(ns, current->audit_context,
 					GFP_KERNEL, AUDIT_NETFILTER_CFG);
 		if (ab) {
 			audit_log_format(ab, "table=%s family=%u entries=%u",
 					 table->name, table->af,
 					 private->number);
-			audit_log_end_ns(ns, ab);
+			audit_log_end(ns, ab);
 		}
 	}
 #endif
diff --git a/net/netfilter/xt_AUDIT.c b/net/netfilter/xt_AUDIT.c
index b1ffba2..a0b102a 100644
--- a/net/netfilter/xt_AUDIT.c
+++ b/net/netfilter/xt_AUDIT.c
@@ -129,7 +129,7 @@ audit_tg(struct sk_buff *skb, const struct xt_action_param *par)
 	if (audit_enabled_ns(ns) == 0)
 		goto errout;
 
-	ab = audit_log_start_ns(ns, NULL, GFP_ATOMIC, AUDIT_NETFILTER_PKT);
+	ab = audit_log_start(ns, NULL, GFP_ATOMIC, AUDIT_NETFILTER_PKT);
 	if (ab == NULL)
 		goto errout;
 
@@ -174,7 +174,7 @@ audit_tg(struct sk_buff *skb, const struct xt_action_param *par)
 		audit_log_secctx(ab, skb->secmark);
 #endif
 
-	audit_log_end_ns(ns, ab);
+	audit_log_end(ns, ab);
 
 errout:
 	return XT_CONTINUE;
diff --git a/net/netlabel/netlabel_domainhash.c b/net/netlabel/netlabel_domainhash.c
index 7fab4b8..7c5d381 100644
--- a/net/netlabel/netlabel_domainhash.c
+++ b/net/netlabel/netlabel_domainhash.c
@@ -241,7 +241,7 @@ static void netlbl_domhsh_audit_add(struct netlbl_dom_map *entry,
 			break;
 		}
 		audit_log_format(audit_buf, " res=%u", result == 0 ? 1 : 0);
-		audit_log_end_ns(current_user_ns(), audit_buf);
+		audit_log_end(current_user_ns(), audit_buf);
 	}
 }
 
@@ -462,7 +462,7 @@ int netlbl_domhsh_remove_entry(struct netlbl_dom_map *entry,
 				 " nlbl_domain=%s res=%u",
 				 entry->domain ? entry->domain : "(default)",
 				 ret_val == 0 ? 1 : 0);
-		audit_log_end_ns(current_user_ns(), audit_buf);
+		audit_log_end(current_user_ns(), audit_buf);
 	}
 
 	if (ret_val == 0) {
diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index 7708078..4d62cb7 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -465,7 +465,7 @@ unlhsh_add_return:
 			security_release_secctx(secctx, secctx_len);
 		}
 		audit_log_format(audit_buf, " res=%u", ret_val == 0 ? 1 : 0);
-		audit_log_end_ns(current_user_ns(), audit_buf);
+		audit_log_end(current_user_ns(), audit_buf);
 	}
 	return ret_val;
 }
@@ -521,7 +521,7 @@ static int netlbl_unlhsh_remove_addr4(struct net *net,
 			security_release_secctx(secctx, secctx_len);
 		}
 		audit_log_format(audit_buf, " res=%u", entry != NULL ? 1 : 0);
-		audit_log_end_ns(current_user_ns(), audit_buf);
+		audit_log_end(current_user_ns(), audit_buf);
 	}
 
 	if (entry == NULL)
@@ -582,7 +582,7 @@ static int netlbl_unlhsh_remove_addr6(struct net *net,
 			security_release_secctx(secctx, secctx_len);
 		}
 		audit_log_format(audit_buf, " res=%u", entry != NULL ? 1 : 0);
-		audit_log_end_ns(current_user_ns(), audit_buf);
+		audit_log_end(current_user_ns(), audit_buf);
 	}
 
 	if (entry == NULL)
@@ -766,7 +766,7 @@ static void netlbl_unlabel_acceptflg_set(u8 value,
 	if (audit_buf != NULL) {
 		audit_log_format(audit_buf,
 				 " unlbl_accept=%u old=%u", value, old_val);
-		audit_log_end_ns(current_user_ns(), audit_buf);
+		audit_log_end(current_user_ns(), audit_buf);
 	}
 }
 
diff --git a/net/netlabel/netlabel_user.c b/net/netlabel/netlabel_user.c
index d7550a2..e9e4e84 100644
--- a/net/netlabel/netlabel_user.c
+++ b/net/netlabel/netlabel_user.c
@@ -105,8 +105,8 @@ struct audit_buffer *netlbl_audit_start_common(int type,
 	if (audit_enabled_ns(ns) == 0)
 		return NULL;
 
-	audit_buf = audit_log_start_ns(ns, current->audit_context,
-				       GFP_ATOMIC, type);
+	audit_buf = audit_log_start(ns, current->audit_context,
+				    GFP_ATOMIC, type);
 	if (audit_buf == NULL)
 		return NULL;
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index f3cc1b9..6aaa5a7 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -3008,7 +3008,7 @@ void xfrm_audit_policy_add(struct xfrm_policy *xp, int result,
 	xfrm_audit_helper_usrinfo(auid, sessionid, secid, audit_buf);
 	audit_log_format(audit_buf, " res=%u", result);
 	xfrm_audit_common_policyinfo(xp, audit_buf);
-	audit_log_end_ns(current_user_ns(), audit_buf);
+	audit_log_end(current_user_ns(), audit_buf);
 }
 EXPORT_SYMBOL_GPL(xfrm_audit_policy_add);
 
@@ -3023,7 +3023,7 @@ void xfrm_audit_policy_delete(struct xfrm_policy *xp, int result,
 	xfrm_audit_helper_usrinfo(auid, sessionid, secid, audit_buf);
 	audit_log_format(audit_buf, " res=%u", result);
 	xfrm_audit_common_policyinfo(xp, audit_buf);
-	audit_log_end_ns(current_user_ns(), audit_buf);
+	audit_log_end(current_user_ns(), audit_buf);
 }
 EXPORT_SYMBOL_GPL(xfrm_audit_policy_delete);
 #endif
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 50115d9..9c824e7 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -2119,7 +2119,7 @@ void xfrm_audit_state_add(struct xfrm_state *x, int result,
 	xfrm_audit_helper_usrinfo(auid, sessionid, secid, audit_buf);
 	xfrm_audit_helper_sainfo(x, audit_buf);
 	audit_log_format(audit_buf, " res=%u", result);
-	audit_log_end_ns(current_user_ns(), audit_buf);
+	audit_log_end(current_user_ns(), audit_buf);
 }
 EXPORT_SYMBOL_GPL(xfrm_audit_state_add);
 
@@ -2134,7 +2134,7 @@ void xfrm_audit_state_delete(struct xfrm_state *x, int result,
 	xfrm_audit_helper_usrinfo(auid, sessionid, secid, audit_buf);
 	xfrm_audit_helper_sainfo(x, audit_buf);
 	audit_log_format(audit_buf, " res=%u", result);
-	audit_log_end_ns(current_user_ns(), audit_buf);
+	audit_log_end(current_user_ns(), audit_buf);
 }
 EXPORT_SYMBOL_GPL(xfrm_audit_state_delete);
 
@@ -2152,7 +2152,7 @@ void xfrm_audit_state_replay_overflow(struct xfrm_state *x,
 	 * of audit message */
 	spi = ntohl(x->id.spi);
 	audit_log_format(audit_buf, " spi=%u(0x%x)", spi, spi);
-	audit_log_end_ns(current_user_ns(), audit_buf);
+	audit_log_end(current_user_ns(), audit_buf);
 }
 EXPORT_SYMBOL_GPL(xfrm_audit_state_replay_overflow);
 
@@ -2169,7 +2169,7 @@ void xfrm_audit_state_replay(struct xfrm_state *x,
 	spi = ntohl(x->id.spi);
 	audit_log_format(audit_buf, " spi=%u(0x%x) seqno=%u",
 			 spi, spi, ntohl(net_seq));
-	audit_log_end_ns(current_user_ns(), audit_buf);
+	audit_log_end(current_user_ns(), audit_buf);
 }
 EXPORT_SYMBOL_GPL(xfrm_audit_state_replay);
 
@@ -2181,7 +2181,7 @@ void xfrm_audit_state_notfound_simple(struct sk_buff *skb, u16 family)
 	if (audit_buf == NULL)
 		return;
 	xfrm_audit_helper_pktinfo(skb, family, audit_buf);
-	audit_log_end_ns(current_user_ns(), audit_buf);
+	audit_log_end(current_user_ns(), audit_buf);
 }
 EXPORT_SYMBOL_GPL(xfrm_audit_state_notfound_simple);
 
@@ -2198,7 +2198,7 @@ void xfrm_audit_state_notfound(struct sk_buff *skb, u16 family,
 	spi = ntohl(net_spi);
 	audit_log_format(audit_buf, " spi=%u(0x%x) seqno=%u",
 			 spi, spi, ntohl(net_seq));
-	audit_log_end_ns(current_user_ns(), audit_buf);
+	audit_log_end(current_user_ns(), audit_buf);
 }
 EXPORT_SYMBOL_GPL(xfrm_audit_state_notfound);
 
@@ -2218,7 +2218,7 @@ void xfrm_audit_state_icvfail(struct xfrm_state *x,
 		audit_log_format(audit_buf, " spi=%u(0x%x) seqno=%u",
 				 spi, spi, ntohl(net_seq));
 	}
-	audit_log_end_ns(current_user_ns(), audit_buf);
+	audit_log_end(current_user_ns(), audit_buf);
 }
 EXPORT_SYMBOL_GPL(xfrm_audit_state_icvfail);
 #endif /* CONFIG_AUDITSYSCALL */
diff --git a/security/integrity/ima/ima_api.c b/security/integrity/ima/ima_api.c
index a94b54e..e60147f 100644
--- a/security/integrity/ima/ima_api.c
+++ b/security/integrity/ima/ima_api.c
@@ -223,8 +223,8 @@ void ima_audit_measurement(struct integrity_iint_cache *iint,
 		hex_byte_pack(hash + (i * 2), iint->ima_xattr.digest[i]);
 	hash[i * 2] = '\0';
 
-	ab = audit_log_start_ns(ns, current->audit_context, GFP_KERNEL,
-				AUDIT_INTEGRITY_RULE);
+	ab = audit_log_start(ns, current->audit_context, GFP_KERNEL,
+			     AUDIT_INTEGRITY_RULE);
 	if (!ab)
 		return;
 
@@ -234,7 +234,7 @@ void ima_audit_measurement(struct integrity_iint_cache *iint,
 	audit_log_untrustedstring(ab, hash);
 
 	audit_log_task_info(ab, current);
-	audit_log_end_ns(ns, ab);
+	audit_log_end(ns, ab);
 
 	iint->flags |= IMA_AUDITED;
 }
diff --git a/security/integrity/ima/ima_audit.c b/security/integrity/ima/ima_audit.c
index e7a205b..91e559e 100644
--- a/security/integrity/ima/ima_audit.c
+++ b/security/integrity/ima/ima_audit.c
@@ -39,8 +39,8 @@ void integrity_audit_msg(int audit_msgno, struct inode *inode,
 		return;
 
 	ns = current_user_ns();
-	ab = audit_log_start_ns(ns, current->audit_context,
-				GFP_KERNEL, audit_msgno);
+	ab = audit_log_start(ns, current->audit_context,
+			     GFP_KERNEL, audit_msgno);
 	audit_log_format(ab, "pid=%d uid=%u auid=%u ses=%u",
 			 current->pid,
 			 from_kuid(ns, current_cred()->uid),
@@ -63,5 +63,5 @@ void integrity_audit_msg(int audit_msgno, struct inode *inode,
 		audit_log_format(ab, " ino=%lu", inode->i_ino);
 	}
 	audit_log_format(ab, " res=%d", !result);
-	audit_log_end_ns(ns, ab);
+	audit_log_end(ns, ab);
 }
diff --git a/security/integrity/ima/ima_policy.c b/security/integrity/ima/ima_policy.c
index c817d35..43e9af6 100644
--- a/security/integrity/ima/ima_policy.c
+++ b/security/integrity/ima/ima_policy.c
@@ -416,7 +416,7 @@ static int ima_parse_rule(char *rule, struct ima_rule_entry *entry)
 	int result = 0;
 	struct user_namespace *ns = current_user_ns();
 
-	ab = audit_log_start_ns(ns, NULL, GFP_KERNEL, AUDIT_INTEGRITY_RULE);
+	ab = audit_log_start(ns, NULL, GFP_KERNEL, AUDIT_INTEGRITY_RULE);
 
 	entry->uid = INVALID_UID;
 	entry->fowner = INVALID_UID;
@@ -634,7 +634,7 @@ static int ima_parse_rule(char *rule, struct ima_rule_entry *entry)
 	else if (entry->func == MODULE_CHECK)
 		ima_appraise |= IMA_APPRAISE_MODULES;
 	audit_log_format(ab, "res=%d", !result);
-	audit_log_end_ns(ns, ab);
+	audit_log_end(ns, ab);
 	return result;
 }
 
diff --git a/security/lsm_audit.c b/security/lsm_audit.c
index 90fcd08..ace11d3 100644
--- a/security/lsm_audit.c
+++ b/security/lsm_audit.c
@@ -399,8 +399,8 @@ void common_lsm_audit(struct common_audit_data *a,
 
 	ns = current_user_ns();
 	/* we use GFP_ATOMIC so we won't sleep */
-	ab = audit_log_start_ns(ns, current->audit_context,
-				GFP_ATOMIC, AUDIT_AVC);
+	ab = audit_log_start(ns, current->audit_context,
+			     GFP_ATOMIC, AUDIT_AVC);
 
 	if (ab == NULL)
 		return;
@@ -413,5 +413,5 @@ void common_lsm_audit(struct common_audit_data *a,
 	if (post_audit)
 		post_audit(ab, a);
 
-	audit_log_end_ns(ns, ab);
+	audit_log_end(ns, ab);
 }
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 93b6c72..3e5a906 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -2799,11 +2799,11 @@ static int selinux_inode_setxattr(struct dentry *dentry, const char *name,
 				str = "";
 				audit_size = 0;
 			}
-			ab = audit_log_start_ns(ns, current->audit_context,
-						GFP_ATOMIC, AUDIT_SELINUX_ERR);
+			ab = audit_log_start(ns, current->audit_context,
+					     GFP_ATOMIC, AUDIT_SELINUX_ERR);
 			audit_log_format(ab, "op=setxattr invalid_context=");
 			audit_log_n_untrustedstring(ab, value, audit_size);
-			audit_log_end_ns(ns, ab);
+			audit_log_end(ns, ab);
 
 			return rc;
 		}
@@ -5338,13 +5338,13 @@ static int selinux_setprocattr(struct task_struct *p,
 					audit_size = size - 1;
 				else
 					audit_size = size;
-				ab = audit_log_start_ns(ns,
-							current->audit_context,
-							GFP_ATOMIC,
-							AUDIT_SELINUX_ERR);
+				ab = audit_log_start(ns,
+						     current->audit_context,
+						     GFP_ATOMIC,
+						     AUDIT_SELINUX_ERR);
 				audit_log_format(ab, "op=fscreate invalid_context=");
 				audit_log_n_untrustedstring(ab, value, audit_size);
-				audit_log_end_ns(ns, ab);
+				audit_log_end(ns, ab);
 
 				return error;
 			}
diff --git a/security/selinux/ss/services.c b/security/selinux/ss/services.c
index 140a383..9cdd1e5 100644
--- a/security/selinux/ss/services.c
+++ b/security/selinux/ss/services.c
@@ -503,8 +503,8 @@ static void security_dump_masked_av(struct context *scontext,
 
 	/* audit a message */
 	ns = current_user_ns();
-	ab = audit_log_start_ns(ns, current->audit_context,
-				GFP_ATOMIC, AUDIT_SELINUX_ERR);
+	ab = audit_log_start(ns, current->audit_context,
+			     GFP_ATOMIC, AUDIT_SELINUX_ERR);
 	if (!ab)
 		goto out;
 
@@ -524,7 +524,7 @@ static void security_dump_masked_av(struct context *scontext,
 				 ? permission_names[index] : "????");
 		need_comma = true;
 	}
-	audit_log_end_ns(ns, ab);
+	audit_log_end(ns, ab);
 out:
 	/* release scontext/tcontext */
 	kfree(tcontext_name);
-- 
1.8.1.4
