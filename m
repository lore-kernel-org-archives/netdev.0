From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH RFC 46/48] Audit: rename audit_enabled_ns to audit_enabled
Date: Tue, 7 May 2013 10:21:07 +0800
Message-ID: <1367893269-9308-47-git-send-email-gaofeng@cn.fujitsu.com>
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

Now,all the callers of audit_enabled is user namespace
awared, we can rename audit_enable_ns to audit_enabled.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 drivers/tty/tty_audit.c      | 4 ++--
 include/linux/audit.h        | 6 ++----
 include/net/xfrm.h           | 2 +-
 kernel/audit_watch.c         | 2 +-
 kernel/auditsc.c             | 4 ++--
 net/core/dev.c               | 2 +-
 net/netfilter/x_tables.c     | 2 +-
 net/netfilter/xt_AUDIT.c     | 2 +-
 net/netlabel/netlabel_user.c | 2 +-
 security/apparmor/lib.c      | 2 +-
 10 files changed, 13 insertions(+), 15 deletions(-)

diff --git a/drivers/tty/tty_audit.c b/drivers/tty/tty_audit.c
index f2d6811..8bb92bb 100644
--- a/drivers/tty/tty_audit.c
+++ b/drivers/tty/tty_audit.c
@@ -99,7 +99,7 @@ static void tty_audit_buf_push(struct task_struct *tsk, kuid_t loginuid,
 {
 	if (buf->valid == 0)
 		return;
-	if (audit_enabled_ns(task_cred_xxx(tsk, user_ns)) == 0) {
+	if (audit_enabled(task_cred_xxx(tsk, user_ns)) == 0) {
 		buf->valid = 0;
 		return;
 	}
@@ -182,7 +182,7 @@ void tty_audit_tiocsti(struct tty_struct *tty, char ch)
 		tty_audit_buf_put(buf);
 	}
 
-	if (should_audit && audit_enabled_ns(current_user_ns())) {
+	if (should_audit && audit_enabled(current_user_ns())) {
 		kuid_t auid;
 		unsigned int sessionid;
 
diff --git a/include/linux/audit.h b/include/linux/audit.h
index a46efa3..3f5dbe3 100644
--- a/include/linux/audit.h
+++ b/include/linux/audit.h
@@ -446,8 +446,7 @@ extern int audit_filter_type(int type);
 extern int  audit_receive_filter(int type, int pid, int seq,
 				void *data, size_t datasz, kuid_t loginuid,
 				u32 sessionid, u32 sid);
-#define audit_enabled (init_user_ns.audit.enabled)
-#define audit_enabled_ns (ns->audit.enabled)
+#define audit_enabled(ns) (ns->audit.enabled)
 #else /* CONFIG_AUDIT */
 static inline __printf(4, 5)
 void audit_log(struct audit_context *ctx, gfp_t gfp_mask, int type,
@@ -495,8 +494,7 @@ static inline void audit_set_user_ns(struct user_namespace *ns)
 
 static inline void audit_free_user_ns(struct user_namespace *ns)
 { }
-#define audit_enabled 0
-#define audit_enabled_ns(ns) 0
+#define audit_enabled(ns) 0
 #endif /* CONFIG_AUDIT */
 static inline void audit_log_string(struct audit_buffer *ab, const char *buf)
 {
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index bb4d6b2..e625ae9 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -685,7 +685,7 @@ static inline struct audit_buffer *xfrm_audit_start(const char *op)
 	struct audit_buffer *audit_buf = NULL;
 	struct user_namespace *ns = current_user_ns();
 
-	if (audit_enabled_ns(ns) == 0)
+	if (audit_enabled(ns) == 0)
 		return NULL;
 	audit_buf = audit_log_start(ns, current->audit_context,
 				    GFP_ATOMIC, AUDIT_MAC_IPSEC_EVENT);
diff --git a/kernel/audit_watch.c b/kernel/audit_watch.c
index 4dcc331..f82edc7 100644
--- a/kernel/audit_watch.c
+++ b/kernel/audit_watch.c
@@ -240,7 +240,7 @@ static void audit_watch_log_rule_change(struct audit_krule *r,
 {
 	struct user_namespace *ns = current_user_ns();
 
-	if (audit_enabled_ns(ns)) {
+	if (audit_enabled(ns)) {
 		struct audit_buffer *ab;
 		ab = audit_log_start(ns, NULL, GFP_NOFS,
 					AUDIT_CONFIG_CHANGE);
diff --git a/kernel/auditsc.c b/kernel/auditsc.c
index e579b75..8930158 100644
--- a/kernel/auditsc.c
+++ b/kernel/auditsc.c
@@ -1782,7 +1782,7 @@ void __audit_syscall_entry(int arch, int major,
 
 	BUG_ON(context->in_syscall || context->name_count);
 
-	if (!audit_enabled_ns(ns))
+	if (!audit_enabled(ns))
 		return;
 
 	context->arch	    = arch;
@@ -2734,7 +2734,7 @@ void audit_core_dumps(long signr)
 	struct audit_buffer *ab;
 	struct user_namespace *ns = current_user_ns();
 
-	if (!audit_enabled_ns(ns))
+	if (!audit_enabled(ns))
 		return;
 
 	if (signr == SIGQUIT)	/* don't care for those */
diff --git a/net/core/dev.c b/net/core/dev.c
index 651ad69..128ee39 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4458,7 +4458,7 @@ static int __dev_set_promiscuity(struct net_device *dev, int inc)
 		pr_info("device %s %s promiscuous mode\n",
 			dev->name,
 			dev->flags & IFF_PROMISC ? "entered" : "left");
-		if (audit_enabled_ns(current_user_ns())) {
+		if (audit_enabled(current_user_ns())) {
 			current_uid_gid(&uid, &gid);
 			audit_log(current->audit_context, GFP_ATOMIC,
 				AUDIT_ANOM_PROMISCUOUS,
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 8be219e..9571d7e 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -858,7 +858,7 @@ xt_replace_table(struct xt_table *table,
 	local_bh_enable();
 
 #ifdef CONFIG_AUDIT
-	if (audit_enabled_ns(ns)) {
+	if (audit_enabled(ns)) {
 		struct audit_buffer *ab;
 
 		ab = audit_log_start(ns, current->audit_context,
diff --git a/net/netfilter/xt_AUDIT.c b/net/netfilter/xt_AUDIT.c
index a0b102a..1079a1ac 100644
--- a/net/netfilter/xt_AUDIT.c
+++ b/net/netfilter/xt_AUDIT.c
@@ -126,7 +126,7 @@ audit_tg(struct sk_buff *skb, const struct xt_action_param *par)
 	struct user_namespace *ns = net->user_ns;
 	struct audit_buffer *ab;
 
-	if (audit_enabled_ns(ns) == 0)
+	if (audit_enabled(ns) == 0)
 		goto errout;
 
 	ab = audit_log_start(ns, NULL, GFP_ATOMIC, AUDIT_NETFILTER_PKT);
diff --git a/net/netlabel/netlabel_user.c b/net/netlabel/netlabel_user.c
index e9e4e84..098eaa2 100644
--- a/net/netlabel/netlabel_user.c
+++ b/net/netlabel/netlabel_user.c
@@ -102,7 +102,7 @@ struct audit_buffer *netlbl_audit_start_common(int type,
 	u32 secctx_len;
 	struct user_namespace *ns = current_user_ns();
 
-	if (audit_enabled_ns(ns) == 0)
+	if (audit_enabled(ns) == 0)
 		return NULL;
 
 	audit_buf = audit_log_start(ns, current->audit_context,
diff --git a/security/apparmor/lib.c b/security/apparmor/lib.c
index 9cae5ce..3058bb1d 100644
--- a/security/apparmor/lib.c
+++ b/security/apparmor/lib.c
@@ -63,7 +63,7 @@ char *aa_split_fqname(char *fqname, char **ns_name)
  */
 void aa_info_message(const char *str)
 {
-	if (audit_enabled_ns(current_user_ns())) {
+	if (audit_enabled(current_user_ns())) {
 		struct common_audit_data sa;
 		struct apparmor_audit_data aad = {0,};
 		sa.type = LSM_AUDIT_DATA_NONE;
-- 
1.8.1.4
