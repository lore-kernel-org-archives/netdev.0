From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH RFC 09/48] Audit: make audit_enabled per user namespace
Date: Tue, 7 May 2013 10:20:30 +0800
Message-ID: <1367893269-9308-10-git-send-email-gaofeng@cn.fujitsu.com>
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

This patch makes audit_enabled per user namespace,
Right now,use audit_enabled of init user namespace to
decide if audit is enabled no matter which user namespace
we belong to.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/linux/audit.h          |  4 +++-
 include/linux/user_namespace.h |  1 +
 kernel/audit.c                 | 37 ++++++++++++++++++-------------------
 3 files changed, 22 insertions(+), 20 deletions(-)

diff --git a/include/linux/audit.h b/include/linux/audit.h
index 684599b..33e6584 100644
--- a/include/linux/audit.h
+++ b/include/linux/audit.h
@@ -441,7 +441,8 @@ extern int audit_filter_type(int type);
 extern int  audit_receive_filter(int type, int pid, int seq,
 				void *data, size_t datasz, kuid_t loginuid,
 				u32 sessionid, u32 sid);
-extern int audit_enabled;
+#define audit_enabled (init_user_ns.audit.enabled)
+#define audit_enabled_ns (ns->audit.enabled)
 #else /* CONFIG_AUDIT */
 static inline __printf(4, 5)
 void audit_log(struct audit_context *ctx, gfp_t gfp_mask, int type,
@@ -487,6 +488,7 @@ static inline void audit_set_user_ns(struct user_namespace *ns)
 static inline void audit_free_user_ns(struct user_namespace *ns)
 { }
 #define audit_enabled 0
+#define audit_enabled_ns(ns) 0
 #endif /* CONFIG_AUDIT */
 static inline void audit_log_string(struct audit_buffer *ab, const char *buf)
 {
diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index 769a12b..3b2ed90 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -21,6 +21,7 @@ struct uid_gid_map {	/* 64 bytes -- 1 cache line */
 #ifdef CONFIG_AUDIT
 struct audit_ctrl {
 	struct sock		*sock;
+	int			enabled;
 	int			pid;
 	int			portid;
 	struct sk_buff_head	queue;
diff --git a/kernel/audit.c b/kernel/audit.c
index b946b29..4595a9e 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -76,11 +76,8 @@ static int	audit_initialized;
 #define AUDIT_OFF	0
 #define AUDIT_ON	1
 #define AUDIT_LOCKED	2
-int		audit_enabled;
 int		audit_ever_enabled;
 
-EXPORT_SYMBOL_GPL(audit_enabled);
-
 /* Default state when kernel boots without any parameters. */
 static int	audit_default;
 
@@ -285,14 +282,15 @@ static int audit_do_config_change(char *function_name, int *to_change,
 				  u32 sid)
 {
 	int allow_changes, rc = 0, old = *to_change;
+	struct user_namespace *ns = current_user_ns();
 
 	/* check if we are locked */
-	if (audit_enabled == AUDIT_LOCKED)
+	if (ns->audit.enabled == AUDIT_LOCKED)
 		allow_changes = 0;
 	else
 		allow_changes = 1;
 
-	if (audit_enabled != AUDIT_OFF) {
+	if (ns->audit.enabled != AUDIT_OFF) {
 		rc = audit_log_config_change(function_name, new, old, loginuid,
 					     sessionid, sid, allow_changes);
 		if (rc)
@@ -322,14 +320,15 @@ static int audit_set_backlog_limit(int limit, kuid_t loginuid, u32 sessionid,
 				      limit, loginuid, sessionid, sid);
 }
 
-static int audit_set_enabled(int state, kuid_t loginuid, u32 sessionid, u32 sid)
+static int audit_set_enabled(struct user_namespace *ns, int state,
+			     kuid_t loginuid, u32 sessionid, u32 sid)
 {
 	int rc;
 	if (state < AUDIT_OFF || state > AUDIT_LOCKED)
 		return -EINVAL;
 
-	rc =  audit_do_config_change("audit_enabled", &audit_enabled, state,
-				     loginuid, sessionid, sid);
+	rc =  audit_do_config_change("audit_enabled", &ns->audit.enabled,
+				     state, loginuid, sessionid, sid);
 
 	if (!rc)
 		audit_ever_enabled |= !!state;
@@ -609,7 +608,7 @@ static int audit_log_common_recv_msg(struct audit_buffer **ab, u16 msg_type,
 	char *ctx = NULL;
 	u32 len;
 
-	if (!audit_enabled) {
+	if (!init_user_ns.audit.enabled) {
 		*ab = NULL;
 		return rc;
 	}
@@ -674,7 +673,7 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 	switch (msg_type) {
 	case AUDIT_GET:
-		status_set.enabled	 = audit_enabled;
+		status_set.enabled	 = ns->audit.enabled;
 		status_set.failure	 = audit_failure;
 		status_set.pid		 = ns->audit.pid;
 		status_set.rate_limit	 = audit_rate_limit;
@@ -690,7 +689,7 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 			return -EINVAL;
 		status_get   = (struct audit_status *)data;
 		if (status_get->mask & AUDIT_STATUS_ENABLED) {
-			err = audit_set_enabled(status_get->enabled,
+			err = audit_set_enabled(ns, status_get->enabled,
 						loginuid, sessionid, sid);
 			if (err < 0)
 				return err;
@@ -704,7 +703,7 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		if (status_get->mask & AUDIT_STATUS_PID) {
 			int new_pid = status_get->pid;
 
-			if (audit_enabled != AUDIT_OFF)
+			if (ns->audit.enabled != AUDIT_OFF)
 				audit_log_config_change("audit_pid", new_pid,
 							ns->audit.pid, loginuid,
 							sessionid, sid, 1);
@@ -725,7 +724,7 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	case AUDIT_USER:
 	case AUDIT_FIRST_USER_MSG ... AUDIT_LAST_USER_MSG:
 	case AUDIT_FIRST_USER_MSG2 ... AUDIT_LAST_USER_MSG2:
-		if (!audit_enabled && msg_type != AUDIT_USER_AVC)
+		if (!ns->audit.enabled && msg_type != AUDIT_USER_AVC)
 			return 0;
 
 		err = audit_filter_user();
@@ -761,12 +760,12 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	case AUDIT_DEL:
 		if (nlmsg_len(nlh) < sizeof(struct audit_rule))
 			return -EINVAL;
-		if (audit_enabled == AUDIT_LOCKED) {
+		if (ns->audit.enabled == AUDIT_LOCKED) {
 			audit_log_common_recv_msg(&ab, AUDIT_CONFIG_CHANGE,
 						  loginuid, sessionid, sid);
 
 			audit_log_format(ab, " audit_enabled=%d res=0",
-					 audit_enabled);
+					 ns->audit.enabled);
 			audit_log_end(ab);
 			return -EPERM;
 		}
@@ -780,12 +779,12 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	case AUDIT_DEL_RULE:
 		if (nlmsg_len(nlh) < sizeof(struct audit_rule_data))
 			return -EINVAL;
-		if (audit_enabled == AUDIT_LOCKED) {
+		if (ns->audit.enabled == AUDIT_LOCKED) {
 			audit_log_common_recv_msg(&ab, AUDIT_CONFIG_CHANGE,
 						  loginuid, sessionid, sid);
 
 			audit_log_format(ab, " audit_enabled=%d res=0",
-					 audit_enabled);
+					 ns->audit.enabled);
 			audit_log_end(ab);
 			return -EPERM;
 		}
@@ -995,7 +994,6 @@ static int __init audit_init(void)
 
 	audit_set_user_ns(&init_user_ns);
 	audit_initialized = AUDIT_INITIALIZED;
-	audit_enabled = audit_default;
 	audit_ever_enabled |= !!audit_default;
 
 	audit_log(NULL, GFP_KERNEL, AUDIT_KERNEL, "initialized");
@@ -1017,7 +1015,7 @@ static int __init audit_enable(char *str)
 	printk(KERN_INFO "audit: %s", audit_default ? "enabled" : "disabled");
 
 	if (audit_initialized == AUDIT_INITIALIZED) {
-		audit_enabled = audit_default;
+		init_user_ns.audit.enabled = audit_default;
 		audit_ever_enabled |= !!audit_default;
 	} else if (audit_initialized == AUDIT_UNINITIALIZED) {
 		printk(" (after initialization)");
@@ -1595,6 +1593,7 @@ void audit_set_user_ns(struct user_namespace *ns)
 
 	skb_queue_head_init(&ns->audit.queue);
 	skb_queue_head_init(&ns->audit.hold_queue);
+	ns->audit.enabled = audit_default;
 }
 
 void audit_free_user_ns(struct user_namespace *ns)
-- 
1.8.1.4
