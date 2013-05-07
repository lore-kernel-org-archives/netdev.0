From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH RFC 04/48] Audit: make audit_skb_queue per user namespace
Date: Tue, 7 May 2013 10:20:25 +0800
Message-ID: <1367893269-9308-5-git-send-email-gaofeng@cn.fujitsu.com>
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

After this patch, ervery user namespace has one
audit_skb_queue. Since we havn't finish the preparations,
only allow user to operate the skb queue of init user
namespace.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/linux/audit.h          |  4 ++++
 include/linux/user_namespace.h |  2 ++
 kernel/audit.c                 | 35 ++++++++++++++++++++++++++---------
 kernel/user_namespace.c        |  1 +
 4 files changed, 33 insertions(+), 9 deletions(-)

diff --git a/include/linux/audit.h b/include/linux/audit.h
index 690d7d8..78f51ae 100644
--- a/include/linux/audit.h
+++ b/include/linux/audit.h
@@ -429,6 +429,7 @@ static inline void	    audit_log_secctx(struct audit_buffer *ab, u32 secid)
 { }
 #endif
 
+extern void		    audit_set_user_ns(struct user_namespace *ns);
 extern void		    audit_free_user_ns(struct user_namespace *ns);
 
 extern int		    audit_update_lsm_rules(void);
@@ -479,6 +480,9 @@ static inline void audit_log_link_denied(const char *string,
 static inline void audit_log_secctx(struct audit_buffer *ab, u32 secid)
 { }
 
+static inline void audit_set_user_ns(struct user_namespace *ns)
+{ }
+
 static inline void audit_free_user_ns(struct user_namespace *ns)
 { }
 #define audit_enabled 0
diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index 8797421..e322f20 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -5,6 +5,7 @@
 #include <linux/nsproxy.h>
 #include <linux/sched.h>
 #include <linux/err.h>
+#include <linux/skbuff.h>
 
 #define UID_GID_MAP_MAX_EXTENTS 5
 
@@ -20,6 +21,7 @@ struct uid_gid_map {	/* 64 bytes -- 1 cache line */
 #ifdef CONFIG_AUDIT
 struct audit_ctrl {
 	struct sock		*sock;
+	struct sk_buff_head	queue;
 };
 #endif
 
diff --git a/kernel/audit.c b/kernel/audit.c
index 3ae8793..2a727af 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -129,7 +129,6 @@ static DEFINE_SPINLOCK(audit_freelist_lock);
 static int	   audit_freelist_count;
 static LIST_HEAD(audit_freelist);
 
-static struct sk_buff_head audit_skb_queue;
 /* queue of skbs to send to auditd when/if it comes back */
 static struct sk_buff_head audit_skb_hold_queue;
 static struct task_struct *kauditd_task;
@@ -419,6 +418,7 @@ static void kauditd_send_skb(struct sk_buff *skb)
 static int kauditd_thread(void *dummy)
 {
 	struct sk_buff *skb;
+	struct sk_buff_head *queue = &init_user_ns.audit.queue;
 
 	set_freezable();
 	while (!kthread_should_stop()) {
@@ -445,7 +445,7 @@ static int kauditd_thread(void *dummy)
 			}
 		}
 
-		skb = skb_dequeue(&audit_skb_queue);
+		skb = skb_dequeue(queue);
 		wake_up(&audit_backlog_wait);
 		if (skb) {
 			if (audit_pid)
@@ -457,7 +457,7 @@ static int kauditd_thread(void *dummy)
 			set_current_state(TASK_INTERRUPTIBLE);
 			add_wait_queue(&kauditd_wait, &wait);
 
-			if (!skb_queue_len(&audit_skb_queue)) {
+			if (!skb_queue_len(queue)) {
 				try_to_freeze();
 				schedule();
 			}
@@ -653,11 +653,13 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	struct audit_sig_info   *sig_data;
 	char			*ctx = NULL;
 	u32			len;
+	struct user_namespace	*ns;
 
 	err = audit_netlink_ok(skb, msg_type);
 	if (err)
 		return err;
 
+	ns = current_user_ns();
 	/* As soon as there's any sign of userspace auditd,
 	 * start kauditd to talk to it */
 	if (!kauditd_task) {
@@ -682,7 +684,8 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		status_set.rate_limit	 = audit_rate_limit;
 		status_set.backlog_limit = audit_backlog_limit;
 		status_set.lost		 = atomic_read(&audit_lost);
-		status_set.backlog	 = skb_queue_len(&audit_skb_queue);
+		status_set.backlog	 =
+			skb_queue_len(&ns->audit.queue);
 		audit_send_reply(NETLINK_CB(skb).portid, seq, AUDIT_GET, 0, 0,
 				 &status_set, sizeof(status_set));
 		break;
@@ -994,7 +997,7 @@ static int __init audit_init(void)
 	if (register_pernet_subsys(&audit_net_ops) < 0)
 		return -1;
 
-	skb_queue_head_init(&audit_skb_queue);
+	audit_set_user_ns(&init_user_ns);
 	skb_queue_head_init(&audit_skb_hold_queue);
 	audit_initialized = AUDIT_INITIALIZED;
 	audit_enabled = audit_default;
@@ -1144,12 +1147,13 @@ static inline void audit_get_stamp(struct audit_context *ctx,
  */
 static void wait_for_auditd(unsigned long sleep_time)
 {
+	const struct sk_buff_head *queue = &init_user_ns.audit.queue;
 	DECLARE_WAITQUEUE(wait, current);
 	set_current_state(TASK_INTERRUPTIBLE);
 	add_wait_queue(&audit_backlog_wait, &wait);
 
 	if (audit_backlog_limit &&
-	    skb_queue_len(&audit_skb_queue) > audit_backlog_limit)
+	    skb_queue_len(queue) > audit_backlog_limit)
 		schedule_timeout(sleep_time);
 
 	__set_current_state(TASK_RUNNING);
@@ -1186,6 +1190,7 @@ struct audit_buffer *audit_log_start(struct audit_context *ctx, gfp_t gfp_mask,
 	unsigned int		uninitialized_var(serial);
 	int reserve;
 	unsigned long timeout_start = jiffies;
+	struct sk_buff_head	*queue = &init_user_ns.audit.queue;
 
 	if (audit_initialized != AUDIT_INITIALIZED)
 		return NULL;
@@ -1200,7 +1205,7 @@ struct audit_buffer *audit_log_start(struct audit_context *ctx, gfp_t gfp_mask,
 				entries over the normal backlog limit */
 
 	while (audit_backlog_limit
-	       && skb_queue_len(&audit_skb_queue) > audit_backlog_limit + reserve) {
+	       && skb_queue_len(queue) > audit_backlog_limit + reserve) {
 		if (gfp_mask & __GFP_WAIT && audit_backlog_wait_time) {
 			unsigned long sleep_time;
 
@@ -1214,7 +1219,7 @@ struct audit_buffer *audit_log_start(struct audit_context *ctx, gfp_t gfp_mask,
 			printk(KERN_WARNING
 			       "audit: audit_backlog=%d > "
 			       "audit_backlog_limit=%d\n",
-			       skb_queue_len(&audit_skb_queue),
+			       skb_queue_len(queue),
 			       audit_backlog_limit);
 		audit_log_lost("backlog limit exceeded");
 		audit_backlog_wait_time = audit_backlog_wait_overflow;
@@ -1524,7 +1529,8 @@ void audit_log_end(struct audit_buffer *ab)
 		nlh->nlmsg_len = ab->skb->len - NLMSG_HDRLEN;
 
 		if (audit_pid) {
-			skb_queue_tail(&audit_skb_queue, ab->skb);
+			skb_queue_tail(&init_user_ns.audit.queue,
+				       ab->skb);
 			wake_up_interruptible(&kauditd_wait);
 		} else {
 			audit_printk_skb(ab->skb);
@@ -1587,6 +1593,14 @@ void audit_log_secctx(struct audit_buffer *ab, u32 secid)
 EXPORT_SYMBOL(audit_log_secctx);
 #endif
 
+void audit_set_user_ns(struct user_namespace *ns)
+{
+	if (audit_initialized == AUDIT_DISABLED)
+		return;
+
+	skb_queue_head_init(&ns->audit.queue);
+}
+
 void audit_free_user_ns(struct user_namespace *ns)
 {
 	if (audit_initialized == AUDIT_DISABLED)
@@ -1597,10 +1611,13 @@ void audit_free_user_ns(struct user_namespace *ns)
 		netlink_kernel_release(ns->audit.sock);
 		net_drop_ns(net);
 	}
+
+	skb_queue_purge(&ns->audit.queue);
 }
 
 EXPORT_SYMBOL(audit_log_start);
 EXPORT_SYMBOL(audit_log_end);
 EXPORT_SYMBOL(audit_log_format);
 EXPORT_SYMBOL(audit_log);
+EXPORT_SYMBOL(audit_set_user_ns);
 EXPORT_SYMBOL(audit_free_user_ns);
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 99de920..047921a 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -100,6 +100,7 @@ int create_user_ns(struct cred *new)
 
 	update_mnt_policy(ns);
 
+	audit_set_user_ns(ns);
 	return 0;
 }
 
-- 
1.8.1.4
