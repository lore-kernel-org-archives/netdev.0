From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH RFC 47/48] Audit: make audit_log user namespace awared
Date: Tue, 7 May 2013 10:21:08 +0800
Message-ID: <1367893269-9308-48-git-send-email-gaofeng@cn.fujitsu.com>
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

This patch makes audit_log user namespace awared.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 include/linux/audit.h          | 12 ++++++------
 kernel/audit.c                 | 11 ++++++-----
 net/core/dev.c                 | 12 +++++++-----
 security/selinux/avc.c         |  3 ++-
 security/selinux/hooks.c       |  3 ++-
 security/selinux/selinuxfs.c   |  9 ++++++---
 security/selinux/ss/services.c | 24 +++++++++++++++---------
 security/smack/smack_lsm.c     |  3 ++-
 8 files changed, 46 insertions(+), 31 deletions(-)

diff --git a/include/linux/audit.h b/include/linux/audit.h
index 3f5dbe3..3af4d5d 100644
--- a/include/linux/audit.h
+++ b/include/linux/audit.h
@@ -395,9 +395,9 @@ static inline void audit_ptrace(struct task_struct *t)
 #ifdef CONFIG_AUDIT
 /* These are defined in audit.c */
 				/* Public API */
-extern __printf(4, 5)
-void audit_log(struct audit_context *ctx, gfp_t gfp_mask, int type,
-	       const char *fmt, ...);
+extern __printf(5, 6)
+void audit_log(struct user_namespace *ns, struct audit_context *ctx,
+	       gfp_t gfp_mask, int type, const char *fmt, ...);
 
 extern struct audit_buffer *
 audit_log_start(struct user_namespace *ns, struct audit_context *ctx,
@@ -448,9 +448,9 @@ extern int  audit_receive_filter(int type, int pid, int seq,
 				u32 sessionid, u32 sid);
 #define audit_enabled(ns) (ns->audit.enabled)
 #else /* CONFIG_AUDIT */
-static inline __printf(4, 5)
-void audit_log(struct audit_context *ctx, gfp_t gfp_mask, int type,
-	       const char *fmt, ...)
+static inline __printf(5, 6)
+void audit_log(struct user_namespace *ns, struct audit_context *ctx,
+	       gfp_t gfp_mask, int type, const char *fmt, ...)
 { }
 static inline
 struct audit_buffer *audit_log_start(struct user_namespace *ns,
diff --git a/kernel/audit.c b/kernel/audit.c
index da1c0ad..59e5cca 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -998,7 +998,8 @@ static int __init audit_init(void)
 
 	audit_set_user_ns(&init_user_ns);
 
-	audit_log(NULL, GFP_KERNEL, AUDIT_KERNEL, "initialized");
+	audit_log(&init_user_ns, NULL, GFP_KERNEL,
+		  AUDIT_KERNEL, "initialized");
 
 	return 0;
 }
@@ -1541,18 +1542,18 @@ void audit_log_end(struct user_namespace *ns, struct audit_buffer *ab)
  * audit_log_vformat, and audit_log_end.  It may be called
  * in any context.
  */
-void audit_log(struct audit_context *ctx, gfp_t gfp_mask, int type,
-	       const char *fmt, ...)
+void audit_log(struct user_namespace *ns, struct audit_context *ctx,
+	       gfp_t gfp_mask, int type, const char *fmt, ...)
 {
 	struct audit_buffer *ab;
 	va_list args;
 
-	ab = audit_log_start(&init_user_ns, ctx, gfp_mask, type);
+	ab = audit_log_start(ns, ctx, gfp_mask, type);
 	if (ab) {
 		va_start(args, fmt);
 		audit_log_vformat(ab, fmt, args);
 		va_end(args);
-		audit_log_end(&init_user_ns, ab);
+		audit_log_end(ns, ab);
 	}
 }
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 128ee39..53a4af7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4455,19 +4455,21 @@ static int __dev_set_promiscuity(struct net_device *dev, int inc)
 		}
 	}
 	if (dev->flags != old_flags) {
+		struct user_namespace *ns = current_user_ns();
 		pr_info("device %s %s promiscuous mode\n",
 			dev->name,
 			dev->flags & IFF_PROMISC ? "entered" : "left");
-		if (audit_enabled(current_user_ns())) {
+		if (audit_enabled(ns)) {
 			current_uid_gid(&uid, &gid);
-			audit_log(current->audit_context, GFP_ATOMIC,
+			audit_log(ns, current->audit_context,
+				GFP_ATOMIC,
 				AUDIT_ANOM_PROMISCUOUS,
 				"dev=%s prom=%d old_prom=%d auid=%u uid=%u gid=%u ses=%u",
 				dev->name, (dev->flags & IFF_PROMISC),
 				(old_flags & IFF_PROMISC),
-				from_kuid(&init_user_ns, audit_get_loginuid(current)),
-				from_kuid(&init_user_ns, uid),
-				from_kgid(&init_user_ns, gid),
+				from_kuid(ns, audit_get_loginuid(current)),
+				from_kuid(ns, uid),
+				from_kgid(ns, gid),
 				audit_get_sessionid(current));
 		}
 
diff --git a/security/selinux/avc.c b/security/selinux/avc.c
index dad36a6..5559be3 100644
--- a/security/selinux/avc.c
+++ b/security/selinux/avc.c
@@ -172,7 +172,8 @@ void __init avc_init(void)
 	avc_node_cachep = kmem_cache_create("avc_node", sizeof(struct avc_node),
 					     0, SLAB_PANIC, NULL);
 
-	audit_log(current->audit_context, GFP_KERNEL, AUDIT_KERNEL, "AVC INITIALIZED\n");
+	audit_log(current_user_ns(), current->audit_context,
+		  GFP_KERNEL, AUDIT_KERNEL, "AVC INITIALIZED\n");
 }
 
 int avc_get_hash_stats(char *page)
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 3e5a906..ac924af 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -4523,7 +4523,8 @@ static int selinux_nlmsg_perm(struct sock *sk, struct sk_buff *skb)
 	err = selinux_nlmsg_lookup(sksec->sclass, nlh->nlmsg_type, &perm);
 	if (err) {
 		if (err == -EINVAL) {
-			audit_log(current->audit_context, GFP_KERNEL, AUDIT_SELINUX_ERR,
+			audit_log(current_user_ns(), current->audit_context,
+				  GFP_KERNEL, AUDIT_SELINUX_ERR,
 				  "SELinux:  unrecognized netlink message"
 				  " type=%hu for sclass=%hu\n",
 				  nlh->nlmsg_type, sksec->sclass);
diff --git a/security/selinux/selinuxfs.c b/security/selinux/selinuxfs.c
index ff42773..4969a5d 100644
--- a/security/selinux/selinuxfs.c
+++ b/security/selinux/selinuxfs.c
@@ -171,7 +171,8 @@ static ssize_t sel_write_enforce(struct file *file, const char __user *buf,
 		length = task_has_security(current, SECURITY__SETENFORCE);
 		if (length)
 			goto out;
-		audit_log(current->audit_context, GFP_KERNEL, AUDIT_MAC_STATUS,
+		audit_log(current_user_ns(), current->audit_context,
+			GFP_KERNEL, AUDIT_MAC_STATUS,
 			"enforcing=%d old_enforcing=%d auid=%u ses=%u",
 			new_value, selinux_enforcing,
 			from_kuid(&init_user_ns, audit_get_loginuid(current)),
@@ -303,7 +304,8 @@ static ssize_t sel_write_disable(struct file *file, const char __user *buf,
 		length = selinux_disable();
 		if (length)
 			goto out;
-		audit_log(current->audit_context, GFP_KERNEL, AUDIT_MAC_STATUS,
+		audit_log(current_user_ns(), current->audit_context,
+			GFP_KERNEL, AUDIT_MAC_STATUS,
 			"selinux=0 auid=%u ses=%u",
 			from_kuid(&init_user_ns, audit_get_loginuid(current)),
 			audit_get_sessionid(current));
@@ -549,7 +551,8 @@ static ssize_t sel_write_load(struct file *file, const char __user *buf,
 	length = count;
 
 out1:
-	audit_log(current->audit_context, GFP_KERNEL, AUDIT_MAC_POLICY_LOAD,
+	audit_log(current_user_ns(), current->audit_context,
+		GFP_KERNEL, AUDIT_MAC_POLICY_LOAD,
 		"policy loaded auid=%u ses=%u",
 		from_kuid(&init_user_ns, audit_get_loginuid(current)),
 		audit_get_sessionid(current));
diff --git a/security/selinux/ss/services.c b/security/selinux/ss/services.c
index 9cdd1e5..81c6f71 100644
--- a/security/selinux/ss/services.c
+++ b/security/selinux/ss/services.c
@@ -728,7 +728,8 @@ static int security_validtrans_handle_fail(struct context *ocontext,
 		goto out;
 	if (context_struct_to_string(tcontext, &t, &tlen))
 		goto out;
-	audit_log(current->audit_context, GFP_ATOMIC, AUDIT_SELINUX_ERR,
+	audit_log(current_user_ns(), current->audit_context,
+		  GFP_ATOMIC, AUDIT_SELINUX_ERR,
 		  "security_validate_transition:  denied for"
 		  " oldcontext=%s newcontext=%s taskcontext=%s tclass=%s",
 		  o, n, t, sym_name(&policydb, SYM_CLASSES, tclass-1));
@@ -875,7 +876,7 @@ int security_bounded_transition(u32 old_sid, u32 new_sid)
 					      &old_name, &length) &&
 		    !context_struct_to_string(new_context,
 					      &new_name, &length)) {
-			audit_log(current->audit_context,
+			audit_log(current_user_ns(), current->audit_context,
 				  GFP_ATOMIC, AUDIT_SELINUX_ERR,
 				  "op=security_bounded_transition "
 				  "result=denied "
@@ -1345,7 +1346,8 @@ static int compute_sid_handle_invalid_context(
 		goto out;
 	if (context_struct_to_string(newcontext, &n, &nlen))
 		goto out;
-	audit_log(current->audit_context, GFP_ATOMIC, AUDIT_SELINUX_ERR,
+	audit_log(current_user_ns(), current->audit_context,
+		  GFP_ATOMIC, AUDIT_SELINUX_ERR,
 		  "security_compute_sid:  invalid context %s"
 		  " for scontext=%s"
 		  " tcontext=%s"
@@ -2436,8 +2438,8 @@ int security_set_bools(int len, int *values)
 
 	for (i = 0; i < len; i++) {
 		if (!!values[i] != policydb.bool_val_to_struct[i]->state) {
-			audit_log(current->audit_context, GFP_ATOMIC,
-				AUDIT_MAC_CONFIG_CHANGE,
+			audit_log(current_user_ns(), current->audit_context,
+				GFP_ATOMIC, AUDIT_MAC_CONFIG_CHANGE,
 				"bool=%s val=%d old_val=%d auid=%u ses=%u",
 				sym_name(&policydb, SYM_BOOLS, i),
 				!!values[i],
@@ -2570,7 +2572,8 @@ int security_sid_mls_copy(u32 sid, u32 mls_sid, u32 *new_sid)
 		rc = convert_context_handle_invalid_context(&newcon);
 		if (rc) {
 			if (!context_struct_to_string(&newcon, &s, &len)) {
-				audit_log(current->audit_context, GFP_ATOMIC, AUDIT_SELINUX_ERR,
+				audit_log(current_user_ns(), current->audit_context,
+					  GFP_ATOMIC, AUDIT_SELINUX_ERR,
 					  "security_sid_mls_copy: invalid context %s", s);
 				kfree(s);
 			}
@@ -2941,7 +2944,8 @@ int selinux_audit_rule_match(u32 sid, u32 field, u32 op, void *vrule,
 	int match = 0;
 
 	if (!rule) {
-		audit_log(actx, GFP_ATOMIC, AUDIT_SELINUX_ERR,
+		audit_log(current_user_ns(), actx,
+			  GFP_ATOMIC, AUDIT_SELINUX_ERR,
 			  "selinux_audit_rule_match: missing rule\n");
 		return -ENOENT;
 	}
@@ -2949,7 +2953,8 @@ int selinux_audit_rule_match(u32 sid, u32 field, u32 op, void *vrule,
 	read_lock(&policy_rwlock);
 
 	if (rule->au_seqno < latest_granting) {
-		audit_log(actx, GFP_ATOMIC, AUDIT_SELINUX_ERR,
+		audit_log(current_user_ns(), actx,
+			  GFP_ATOMIC, AUDIT_SELINUX_ERR,
 			  "selinux_audit_rule_match: stale rule\n");
 		match = -ESTALE;
 		goto out;
@@ -2957,7 +2962,8 @@ int selinux_audit_rule_match(u32 sid, u32 field, u32 op, void *vrule,
 
 	ctxt = sidtab_search(&sidtab, sid);
 	if (!ctxt) {
-		audit_log(actx, GFP_ATOMIC, AUDIT_SELINUX_ERR,
+		audit_log(current_user_ns(), actx,
+			  GFP_ATOMIC, AUDIT_SELINUX_ERR,
 			  "selinux_audit_rule_match: unrecognized SID %d\n",
 			  sid);
 		match = -ENOENT;
diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index d52c780..816d3bb 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -3292,7 +3292,8 @@ static int smack_audit_rule_match(u32 secid, u32 field, u32 op, void *vrule,
 	char *rule = vrule;
 
 	if (!rule) {
-		audit_log(actx, GFP_ATOMIC, AUDIT_SELINUX_ERR,
+		audit_log(current_user_ns(), actx,
+			  GFP_ATOMIC, AUDIT_SELINUX_ERR,
 			  "Smack: missing rule\n");
 		return -ENOENT;
 	}
-- 
1.8.1.4
