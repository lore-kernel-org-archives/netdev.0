From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH RFC 20/48] Audit: introduce new audit logging interface for
	user namespace
Date: Tue, 7 May 2013 10:20:41 +0800
Message-ID: <1367893269-9308-21-git-send-email-gaofeng@cn.fujitsu.com>
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

This interface audit_log_start_ns and audit_log_end_ns
will be used for logging audit logs in user namespace.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/linux/audit.h | 25 ++++++++++++--
 kernel/audit.c        | 95 ++++++++++++++++++++++++++++++---------------------
 2 files changed, 78 insertions(+), 42 deletions(-)

diff --git a/include/linux/audit.h b/include/linux/audit.h
index 33e6584..f16db07 100644
--- a/include/linux/audit.h
+++ b/include/linux/audit.h
@@ -398,10 +398,18 @@ extern __printf(4, 5)
 void audit_log(struct audit_context *ctx, gfp_t gfp_mask, int type,
 	       const char *fmt, ...);
 
-extern struct audit_buffer *audit_log_start(struct audit_context *ctx, gfp_t gfp_mask, int type);
+extern struct audit_buffer *
+audit_log_start(struct audit_context *ctx, gfp_t gfp_mask, int type);
+
+extern struct audit_buffer *
+audit_log_start_ns(struct user_namespace *ns, struct audit_context *ctx,
+		   gfp_t gfp_mask, int type);
+
 extern __printf(2, 3)
 void audit_log_format(struct audit_buffer *ab, const char *fmt, ...);
 extern void		    audit_log_end(struct audit_buffer *ab);
+extern void		    audit_log_end_ns(struct user_namespace *ns,
+					     struct audit_buffer *ab);
 extern int		    audit_string_contains_control(const char *string,
 							  size_t len);
 extern void		    audit_log_n_hex(struct audit_buffer *ab,
@@ -448,8 +456,16 @@ static inline __printf(4, 5)
 void audit_log(struct audit_context *ctx, gfp_t gfp_mask, int type,
 	       const char *fmt, ...)
 { }
-static inline struct audit_buffer *audit_log_start(struct audit_context *ctx,
-						   gfp_t gfp_mask, int type)
+static inline
+struct audit_buffer *audit_log_start(struct audit_context *ctx,
+				     gfp_t gfp_mask, int type)
+{
+	return NULL;
+}
+static inline
+struct audit_buffer *audit_log_start_ns(struct user_namespace *ns,
+					struct audit_context *ctx,
+					gfp_t gfp_mask, int type)
 {
 	return NULL;
 }
@@ -458,6 +474,9 @@ void audit_log_format(struct audit_buffer *ab, const char *fmt, ...)
 { }
 static inline void audit_log_end(struct audit_buffer *ab)
 { }
+static inline void audit_log_end_ns(struct user_namespace *ns,
+				    struct audit_buffer *ab)
+{ }
 static inline void audit_log_n_hex(struct audit_buffer *ab,
 				   const unsigned char *buf, size_t len)
 { }
diff --git a/kernel/audit.c b/kernel/audit.c
index 5ac9acd..594e4e1 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -1139,47 +1139,35 @@ static inline void audit_get_stamp(struct audit_context *ctx,
 /*
  * Wait for auditd to drain the queue a little
  */
-static void wait_for_auditd(unsigned long sleep_time)
+static void wait_for_auditd(struct user_namespace *ns,
+			    unsigned long sleep_time)
 {
-	const struct sk_buff_head *queue = &init_user_ns.audit.queue;
+	const struct sk_buff_head *queue = &ns->audit.queue;
 	DECLARE_WAITQUEUE(wait, current);
 	set_current_state(TASK_INTERRUPTIBLE);
-	add_wait_queue(&init_user_ns.audit.backlog_wait, &wait);
+	add_wait_queue(&ns->audit.backlog_wait, &wait);
 
 	if (audit_backlog_limit &&
 	    skb_queue_len(queue) > audit_backlog_limit)
 		schedule_timeout(sleep_time);
 
 	__set_current_state(TASK_RUNNING);
-	remove_wait_queue(&init_user_ns.audit.backlog_wait, &wait);
+	remove_wait_queue(&ns->audit.backlog_wait, &wait);
 }
 
-/**
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
+struct audit_buffer *audit_log_start_ns(struct user_namespace *ns,
+					struct audit_context *ctx,
+					gfp_t gfp_mask,
+					int type)
 {
 	struct audit_buffer	*ab	= NULL;
 	struct timespec		t;
 	unsigned int		uninitialized_var(serial);
 	int reserve;
 	unsigned long timeout_start = jiffies;
-	struct sk_buff_head	*queue = &init_user_ns.audit.queue;
+	struct sk_buff_head	*queue = &ns->audit.queue;
 
-	if (init_user_ns.audit.initialized != AUDIT_INITIALIZED)
+	if (ns->audit.initialized != AUDIT_INITIALIZED)
 		return NULL;
 
 	if (unlikely(audit_filter_type(type)))
@@ -1199,7 +1187,7 @@ struct audit_buffer *audit_log_start(struct audit_context *ctx, gfp_t gfp_mask,
 			sleep_time = timeout_start + audit_backlog_wait_time -
 					jiffies;
 			if ((long)sleep_time > 0)
-				wait_for_auditd(sleep_time);
+				wait_for_auditd(ns, sleep_time);
 			continue;
 		}
 		if (audit_rate_check() && printk_ratelimit())
@@ -1210,7 +1198,7 @@ struct audit_buffer *audit_log_start(struct audit_context *ctx, gfp_t gfp_mask,
 			       audit_backlog_limit);
 		audit_log_lost("backlog limit exceeded");
 		audit_backlog_wait_time = audit_backlog_wait_overflow;
-		wake_up(&init_user_ns.audit.backlog_wait);
+		wake_up(&ns->audit.backlog_wait);
 		return NULL;
 	}
 
@@ -1227,6 +1215,28 @@ struct audit_buffer *audit_log_start(struct audit_context *ctx, gfp_t gfp_mask,
 	return ab;
 }
 
+
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
+struct audit_buffer *audit_log_start(struct audit_context *ctx, gfp_t gfp_mask,
+				     int type)
+{
+	return audit_log_start_ns(&init_user_ns, ctx, gfp_mask, type);
+}
+
 /**
  * audit_expand - expand skb in the audit buffer
  * @ab: audit_buffer
@@ -1496,16 +1506,7 @@ void audit_log_link_denied(const char *operation, struct path *link)
 	audit_log_end(ab);
 }
 
-/**
- * audit_log_end - end one audit record
- * @ab: the audit_buffer
- *
- * The netlink_* functions cannot be called inside an irq context, so
- * the audit buffer is placed on a queue and a tasklet is scheduled to
- * remove them from the queue outside the irq context.  May be called in
- * any context.
- */
-void audit_log_end(struct audit_buffer *ab)
+void audit_log_end_ns(struct user_namespace *ns, struct audit_buffer *ab)
 {
 	if (!ab)
 		return;
@@ -1515,12 +1516,12 @@ void audit_log_end(struct audit_buffer *ab)
 		struct nlmsghdr *nlh = nlmsg_hdr(ab->skb);
 		nlh->nlmsg_len = ab->skb->len - NLMSG_HDRLEN;
 
-		if (init_user_ns.audit.pid) {
-			skb_queue_tail(&init_user_ns.audit.queue,
+		if (ns->audit.pid) {
+			skb_queue_tail(&ns->audit.queue,
 				       ab->skb);
-			wake_up_interruptible(&init_user_ns.audit.kauditd_wait);
+			wake_up_interruptible(&ns->audit.kauditd_wait);
 		} else {
-			audit_printk_skb(&init_user_ns, ab->skb);
+			audit_printk_skb(ns, ab->skb);
 		}
 		ab->skb = NULL;
 	}
@@ -1528,6 +1529,20 @@ void audit_log_end(struct audit_buffer *ab)
 }
 
 /**
+ * audit_log_end - end one audit record
+ * @ab: the audit_buffer
+ *
+ * The netlink_* functions cannot be called inside an irq context, so
+ * the audit buffer is placed on a queue and a tasklet is scheduled to
+ * remove them from the queue outside the irq context.  May be called in
+ * any context.
+ */
+void audit_log_end(struct audit_buffer *ab)
+{
+	audit_log_end_ns(&init_user_ns, ab);
+}
+
+/**
  * audit_log - Log an audit record
  * @ctx: audit context
  * @gfp_mask: type of allocation
@@ -1614,7 +1629,9 @@ void audit_free_user_ns(struct user_namespace *ns)
 }
 
 EXPORT_SYMBOL(audit_log_start);
+EXPORT_SYMBOL(audit_log_start_ns);
 EXPORT_SYMBOL(audit_log_end);
+EXPORT_SYMBOL(audit_log_end_ns);
 EXPORT_SYMBOL(audit_log_format);
 EXPORT_SYMBOL(audit_log);
 EXPORT_SYMBOL(audit_set_user_ns);
-- 
1.8.1.4
