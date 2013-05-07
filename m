From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH RFC 07/48] Audit: make audit_pid per user namespace
Date: Tue, 7 May 2013 10:20:28 +0800
Message-ID: <1367893269-9308-8-git-send-email-gaofeng@cn.fujitsu.com>
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

After this patch, audit_pid is per user namespace.
Since we havn't prepared to enable audit for uninit
user namespace now, use the audit_pid of init_user_ns
instead of the audit_pid of per user namespace.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/linux/audit.h          |  1 +
 include/linux/user_namespace.h |  1 +
 kernel/audit.c                 | 22 +++++++++++-----------
 kernel/audit.h                 |  5 ++---
 kernel/auditsc.c               |  6 +++---
 5 files changed, 18 insertions(+), 17 deletions(-)

diff --git a/include/linux/audit.h b/include/linux/audit.h
index 78f51ae..684599b 100644
--- a/include/linux/audit.h
+++ b/include/linux/audit.h
@@ -26,6 +26,7 @@
 #include <linux/sched.h>
 #include <linux/ptrace.h>
 #include <uapi/linux/audit.h>
+#include <linux/user_namespace.h>
 
 struct audit_sig_info {
 	uid_t		uid;
diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index 24f7c2f..a6c6174 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -21,6 +21,7 @@ struct uid_gid_map {	/* 64 bytes -- 1 cache line */
 #ifdef CONFIG_AUDIT
 struct audit_ctrl {
 	struct sock		*sock;
+	int			pid;
 	struct sk_buff_head	queue;
 	struct sk_buff_head	hold_queue;
 	struct task_struct	*kauditd_task;
diff --git a/kernel/audit.c b/kernel/audit.c
index 839c4c0..2ce7a21 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -92,7 +92,6 @@ static int	audit_failure = AUDIT_FAIL_PRINTK;
  * contains the pid of the auditd process and audit_nlk_portid contains
  * the portid to use to send netlink messages to that process.
  */
-int		audit_pid;
 static int	audit_nlk_portid;
 
 /* If audit_rate_limit is non-zero, limit the rate of sending audit records
@@ -181,7 +180,7 @@ void audit_panic(const char *message)
 		break;
 	case AUDIT_FAIL_PANIC:
 		/* test audit_pid since printk is always losey, why bother? */
-		if (audit_pid)
+		if (&init_user_ns.audit.pid)
 			panic("audit: %s\n", message);
 		break;
 	}
@@ -404,9 +403,10 @@ static void kauditd_send_skb(struct sk_buff *skb)
 			      audit_nlk_portid, 0);
 	if (err < 0) {
 		BUG_ON(err != -ECONNREFUSED); /* Shouldn't happen */
-		printk(KERN_ERR "audit: *NO* daemon at audit_pid=%d\n", audit_pid);
+		printk(KERN_ERR "audit: *NO* daemon at audit_pid=%d\n",
+		       init_user_ns.audit.pid);
 		audit_log_lost("auditd disappeared\n");
-		audit_pid = 0;
+		init_user_ns.audit.pid = 0;
 		/* we might get lucky and get this in the next auditd */
 		audit_hold_skb(skb);
 	} else
@@ -436,10 +436,10 @@ static int kauditd_thread(void *dummy)
 		 * in 5 years when I want to play with this again I'll see this
 		 * note and still have no friggin idea what i'm thinking today.
 		 */
-		if (audit_default && audit_pid) {
+		if (audit_default && ns->audit.pid) {
 			skb = skb_dequeue(hold_queue);
 			if (unlikely(skb)) {
-				while (skb && audit_pid) {
+				while (skb && ns->audit.pid) {
 					kauditd_send_skb(skb);
 					skb = skb_dequeue(hold_queue);
 				}
@@ -449,7 +449,7 @@ static int kauditd_thread(void *dummy)
 		skb = skb_dequeue(queue);
 		wake_up(&audit_backlog_wait);
 		if (skb) {
-			if (audit_pid)
+			if (ns->audit.pid)
 				kauditd_send_skb(skb);
 			else
 				audit_printk_skb(skb);
@@ -683,7 +683,7 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	case AUDIT_GET:
 		status_set.enabled	 = audit_enabled;
 		status_set.failure	 = audit_failure;
-		status_set.pid		 = audit_pid;
+		status_set.pid		 = ns->audit.pid;
 		status_set.rate_limit	 = audit_rate_limit;
 		status_set.backlog_limit = audit_backlog_limit;
 		status_set.lost		 = atomic_read(&audit_lost);
@@ -713,10 +713,10 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 			if (audit_enabled != AUDIT_OFF)
 				audit_log_config_change("audit_pid", new_pid,
-							audit_pid, loginuid,
+							ns->audit.pid, loginuid,
 							sessionid, sid, 1);
 
-			audit_pid = new_pid;
+			ns->audit.pid = new_pid;
 			audit_nlk_portid = NETLINK_CB(skb).portid;
 		}
 		if (status_get->mask & AUDIT_STATUS_RATE_LIMIT) {
@@ -1530,7 +1530,7 @@ void audit_log_end(struct audit_buffer *ab)
 		struct nlmsghdr *nlh = nlmsg_hdr(ab->skb);
 		nlh->nlmsg_len = ab->skb->len - NLMSG_HDRLEN;
 
-		if (audit_pid) {
+		if (init_user_ns.audit.pid) {
 			skb_queue_tail(&init_user_ns.audit.queue,
 				       ab->skb);
 			wake_up_interruptible(&kauditd_wait);
diff --git a/kernel/audit.h b/kernel/audit.h
index 11468d9..ced93fe 100644
--- a/kernel/audit.h
+++ b/kernel/audit.h
@@ -61,8 +61,6 @@ struct audit_entry {
 
 extern int audit_ever_enabled;
 
-extern int audit_pid;
-
 #define AUDIT_INODE_BUCKETS	32
 extern struct list_head audit_inode_hash[AUDIT_INODE_BUCKETS];
 
@@ -153,7 +151,8 @@ extern u32 audit_sig_sid;
 extern int __audit_signal_info(int sig, struct task_struct *t);
 static inline int audit_signal_info(int sig, struct task_struct *t)
 {
-	if (unlikely((audit_pid && t->tgid == audit_pid) ||
+	if (unlikely((init_user_ns.audit.pid &&
+		      t->tgid == init_user_ns.audit.pid) ||
 		     (audit_signals && !audit_dummy_context())))
 		return __audit_signal_info(sig, t);
 	return 0;
diff --git a/kernel/auditsc.c b/kernel/auditsc.c
index c682294..6c97f36 100644
--- a/kernel/auditsc.c
+++ b/kernel/auditsc.c
@@ -871,7 +871,7 @@ static enum audit_state audit_filter_syscall(struct task_struct *tsk,
 	struct audit_entry *e;
 	enum audit_state state;
 
-	if (audit_pid && tsk->tgid == audit_pid)
+	if (init_user_ns.audit.pid && tsk->tgid == init_user_ns.audit.pid)
 		return AUDIT_DISABLED;
 
 	rcu_read_lock();
@@ -932,7 +932,7 @@ void audit_filter_inodes(struct task_struct *tsk, struct audit_context *ctx)
 {
 	struct audit_names *n;
 
-	if (audit_pid && tsk->tgid == audit_pid)
+	if (init_user_ns.audit.pid && tsk->tgid == init_user_ns.audit.pid)
 		return;
 
 	rcu_read_lock();
@@ -2547,7 +2547,7 @@ int __audit_signal_info(int sig, struct task_struct *t)
 	struct audit_context *ctx = tsk->audit_context;
 	kuid_t uid = current_uid(), t_uid = task_uid(t);
 
-	if (audit_pid && t->tgid == audit_pid) {
+	if (init_user_ns.audit.pid && t->tgid == init_user_ns.audit.pid) {
 		if (sig == SIGTERM || sig == SIGHUP || sig == SIGUSR1 || sig == SIGUSR2) {
 			audit_sig_pid = tsk->pid;
 			if (uid_valid(tsk->loginuid))
-- 
1.8.1.4
