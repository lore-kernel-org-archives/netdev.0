From: Paul Moore <paul.moore@hp.com>
Subject: [RFC PATCH 2/2] LSM: Make the Labeled IPsec hooks more stack friendly
Date: Mon, 07 Apr 2008 19:16:35 -0400
Message-ID: <20080407231635.8087.42161.stgit@flek.lan>
References: <20080407231143.8087.77531.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20080407231143.8087.77531.stgit@flek.lan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The xfrm_get_policy() and xfrm_add_pol_expire() put some rather large structs
on the stack to work around the LSM API.  This patch attempts to fix that
problem by changing the LSM API to require only the relevant "security"
pointers instead of the entire SPD entry; we do this for all of the
security_xfrm_policy*() functions to keep things consistent.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---

 include/linux/security.h        |   48 ++++++++++++++++++++-------------------
 net/xfrm/xfrm_policy.c          |   24 ++++++++++++--------
 net/xfrm/xfrm_user.c            |   33 ++++++++++++++-------------
 security/dummy.c                |   14 +++++++----
 security/security.c             |   21 +++++++++--------
 security/selinux/include/xfrm.h |   13 ++++++-----
 security/selinux/xfrm.c         |   39 +++++++++++++-------------------
 7 files changed, 98 insertions(+), 94 deletions(-)

diff --git a/include/linux/security.h b/include/linux/security.h
index c673dfd..f5eb9ff 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -910,24 +910,24 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
  * Security hooks for XFRM operations.
  *
  * @xfrm_policy_alloc_security:
- *	@xp contains the xfrm_policy being added to Security Policy Database
- *	used by the XFRM system.
+ *	@ctxp is a pointer to the xfrm_sec_ctx being added to Security Policy
+ *	Database used by the XFRM system.
  *	@sec_ctx contains the security context information being provided by
  *	the user-level policy update program (e.g., setkey).
  *	Allocate a security structure to the xp->security field; the security
  *	field is initialized to NULL when the xfrm_policy is allocated.
  *	Return 0 if operation was successful (memory to allocate, legal context)
  * @xfrm_policy_clone_security:
- *	@old contains an existing xfrm_policy in the SPD.
- *	@new contains a new xfrm_policy being cloned from old.
- *	Allocate a security structure to the new->security field
- *	that contains the information from the old->security field.
+ *	@old_ctx contains an existing xfrm_sec_ctx.
+ *	@new_ctxp contains a new xfrm_sec_ctx being cloned from old.
+ *	Allocate a security structure in new_ctxp that contains the
+ *	information from the old_ctx structure.
  *	Return 0 if operation was successful (memory to allocate).
  * @xfrm_policy_free_security:
- *	@xp contains the xfrm_policy
+ *	@ctx contains the xfrm_sec_ctx
  *	Deallocate xp->security.
  * @xfrm_policy_delete_security:
- *	@xp contains the xfrm_policy.
+ *	@ctx contains the xfrm_sec_ctx.
  *	Authorize deletion of xp->security.
  * @xfrm_state_alloc_security:
  *	@x contains the xfrm_state being added to the Security Association
@@ -947,7 +947,7 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
  *	@x contains the xfrm_state.
  *	Authorize deletion of x->security.
  * @xfrm_policy_lookup:
- *	@xp contains the xfrm_policy for which the access control is being
+ *	@ctx contains the xfrm_sec_ctx for which the access control is being
  *	checked.
  *	@fl_secid contains the flow security label that is used to authorize
  *	access to the policy xp.
@@ -1454,17 +1454,17 @@ struct security_operations {
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
-	int (*xfrm_policy_alloc_security) (struct xfrm_policy *xp,
+	int (*xfrm_policy_alloc_security) (struct xfrm_sec_ctx **ctxp,
 			struct xfrm_user_sec_ctx *sec_ctx);
-	int (*xfrm_policy_clone_security) (struct xfrm_policy *old, struct xfrm_policy *new);
-	void (*xfrm_policy_free_security) (struct xfrm_policy *xp);
-	int (*xfrm_policy_delete_security) (struct xfrm_policy *xp);
+	int (*xfrm_policy_clone_security) (struct xfrm_sec_ctx *old_ctx, struct xfrm_sec_ctx **new_ctx);
+	void (*xfrm_policy_free_security) (struct xfrm_sec_ctx *ctx);
+	int (*xfrm_policy_delete_security) (struct xfrm_sec_ctx *ctx);
 	int (*xfrm_state_alloc_security) (struct xfrm_state *x,
 		struct xfrm_user_sec_ctx *sec_ctx,
 		u32 secid);
 	void (*xfrm_state_free_security) (struct xfrm_state *x);
 	int (*xfrm_state_delete_security) (struct xfrm_state *x);
-	int (*xfrm_policy_lookup)(struct xfrm_policy *xp, u32 fl_secid, u8 dir);
+	int (*xfrm_policy_lookup)(struct xfrm_sec_ctx *ctx, u32 fl_secid, u8 dir);
 	int (*xfrm_state_pol_flow_match)(struct xfrm_state *x,
 			struct xfrm_policy *xp, struct flowi *fl);
 	int (*xfrm_decode_session)(struct sk_buff *skb, u32 *secid, int ckall);
@@ -2562,16 +2562,16 @@ static inline void security_inet_conn_established(struct sock *sk,
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
 
-int security_xfrm_policy_alloc(struct xfrm_policy *xp, struct xfrm_user_sec_ctx *sec_ctx);
-int security_xfrm_policy_clone(struct xfrm_policy *old, struct xfrm_policy *new);
-void security_xfrm_policy_free(struct xfrm_policy *xp);
-int security_xfrm_policy_delete(struct xfrm_policy *xp);
+int security_xfrm_policy_alloc(struct xfrm_sec_ctx **ctxp, struct xfrm_user_sec_ctx *sec_ctx);
+int security_xfrm_policy_clone(struct xfrm_sec_ctx *old_ctx, struct xfrm_sec_ctx **new_ctxp);
+void security_xfrm_policy_free(struct xfrm_sec_ctx *ctx);
+int security_xfrm_policy_delete(struct xfrm_sec_ctx *ctx);
 int security_xfrm_state_alloc(struct xfrm_state *x, struct xfrm_user_sec_ctx *sec_ctx);
 int security_xfrm_state_alloc_acquire(struct xfrm_state *x,
 				      struct xfrm_sec_ctx *polsec, u32 secid);
 int security_xfrm_state_delete(struct xfrm_state *x);
 void security_xfrm_state_free(struct xfrm_state *x);
-int security_xfrm_policy_lookup(struct xfrm_policy *xp, u32 fl_secid, u8 dir);
+int security_xfrm_policy_lookup(struct xfrm_sec_ctx *ctx, u32 fl_secid, u8 dir);
 int security_xfrm_state_pol_flow_match(struct xfrm_state *x,
 				       struct xfrm_policy *xp, struct flowi *fl);
 int security_xfrm_decode_session(struct sk_buff *skb, u32 *secid);
@@ -2579,21 +2579,21 @@ void security_skb_classify_flow(struct sk_buff *skb, struct flowi *fl);
 
 #else	/* CONFIG_SECURITY_NETWORK_XFRM */
 
-static inline int security_xfrm_policy_alloc(struct xfrm_policy *xp, struct xfrm_user_sec_ctx *sec_ctx)
+static inline int security_xfrm_policy_alloc(struct xfrm_sec_ctx **ctxp, struct xfrm_user_sec_ctx *sec_ctx)
 {
 	return 0;
 }
 
-static inline int security_xfrm_policy_clone(struct xfrm_policy *old, struct xfrm_policy *new)
+static inline int security_xfrm_policy_clone(struct xfrm_sec_ctx *old, struct xfrm_sec_ctx **new_ctxp)
 {
 	return 0;
 }
 
-static inline void security_xfrm_policy_free(struct xfrm_policy *xp)
+static inline void security_xfrm_policy_free(struct xfrm_sec_ctx *ctx)
 {
 }
 
-static inline int security_xfrm_policy_delete(struct xfrm_policy *xp)
+static inline int security_xfrm_policy_delete(struct xfrm_sec_ctx *ctx)
 {
 	return 0;
 }
@@ -2619,7 +2619,7 @@ static inline int security_xfrm_state_delete(struct xfrm_state *x)
 	return 0;
 }
 
-static inline int security_xfrm_policy_lookup(struct xfrm_policy *xp, u32 fl_secid, u8 dir)
+static inline int security_xfrm_policy_lookup(struct xfrm_sec_ctx *ctx, u32 fl_secid, u8 dir)
 {
 	return 0;
 }
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 9fc4c31..b8cb3e8 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -230,7 +230,7 @@ void xfrm_policy_destroy(struct xfrm_policy *policy)
 	if (del_timer(&policy->timer))
 		BUG();
 
-	security_xfrm_policy_free(policy);
+	security_xfrm_policy_free(policy->security);
 	kfree(policy);
 }
 EXPORT_SYMBOL(xfrm_policy_destroy);
@@ -642,7 +642,8 @@ struct xfrm_policy *xfrm_policy_bysel_ctx(u8 type, int dir,
 		    xfrm_sec_ctx_match(ctx, pol->security)) {
 			xfrm_pol_hold(pol);
 			if (delete) {
-				*err = security_xfrm_policy_delete(pol);
+				*err = security_xfrm_policy_delete(
+								pol->security);
 				if (*err) {
 					write_unlock_bh(&xfrm_policy_lock);
 					return pol;
@@ -684,7 +685,8 @@ struct xfrm_policy *xfrm_policy_byid(u8 type, int dir, u32 id, int delete,
 		if (pol->type == type && pol->index == id) {
 			xfrm_pol_hold(pol);
 			if (delete) {
-				*err = security_xfrm_policy_delete(pol);
+				*err = security_xfrm_policy_delete(
+								pol->security);
 				if (*err) {
 					write_unlock_bh(&xfrm_policy_lock);
 					return pol;
@@ -722,7 +724,7 @@ xfrm_policy_flush_secctx_check(u8 type, struct xfrm_audit *audit_info)
 				     &xfrm_policy_inexact[dir], bydst) {
 			if (pol->type != type)
 				continue;
-			err = security_xfrm_policy_delete(pol);
+			err = security_xfrm_policy_delete(pol->security);
 			if (err) {
 				xfrm_audit_policy_delete(pol, 0,
 							 audit_info->loginuid,
@@ -736,7 +738,8 @@ xfrm_policy_flush_secctx_check(u8 type, struct xfrm_audit *audit_info)
 					     bydst) {
 				if (pol->type != type)
 					continue;
-				err = security_xfrm_policy_delete(pol);
+				err = security_xfrm_policy_delete(
+								pol->security);
 				if (err) {
 					xfrm_audit_policy_delete(pol, 0,
 							audit_info->loginuid,
@@ -894,7 +897,8 @@ static int xfrm_policy_match(struct xfrm_policy *pol, struct flowi *fl,
 
 	match = xfrm_selector_match(sel, fl, family);
 	if (match)
-		ret = security_xfrm_policy_lookup(pol, fl->secid, dir);
+		ret = security_xfrm_policy_lookup(pol->security, fl->secid,
+						  dir);
 
 	return ret;
 }
@@ -1011,8 +1015,9 @@ static struct xfrm_policy *xfrm_sk_policy_lookup(struct sock *sk, int dir, struc
 		int err = 0;
 
 		if (match) {
-			err = security_xfrm_policy_lookup(pol, fl->secid,
-					policy_to_flow_dir(dir));
+			err = security_xfrm_policy_lookup(pol->security,
+						      fl->secid,
+						      policy_to_flow_dir(dir));
 			if (!err)
 				xfrm_pol_hold(pol);
 			else if (err == -ESRCH)
@@ -1101,7 +1106,8 @@ static struct xfrm_policy *clone_policy(struct xfrm_policy *old, int dir)
 
 	if (newp) {
 		newp->selector = old->selector;
-		if (security_xfrm_policy_clone(old, newp)) {
+		if (security_xfrm_policy_clone(old->security,
+					       &newp->security)) {
 			kfree(newp);
 			return NULL;  /* ENOMEM */
 		}
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 5d96f27..91d6974 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -953,7 +953,7 @@ static int copy_from_user_sec_ctx(struct xfrm_policy *pol, struct nlattr **attrs
 		return 0;
 
 	uctx = nla_data(rt);
-	return security_xfrm_policy_alloc(pol, uctx);
+	return security_xfrm_policy_alloc(&pol->security, uctx);
 }
 
 static void copy_templates(struct xfrm_policy *xp, struct xfrm_user_tmpl *ut,
@@ -1137,7 +1137,7 @@ static int xfrm_add_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 			      NETLINK_CB(skb).sid);
 
 	if (err) {
-		security_xfrm_policy_free(xp);
+		security_xfrm_policy_free(xp->security);
 		kfree(xp);
 		return err;
 	}
@@ -1325,22 +1325,23 @@ static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 		xp = xfrm_policy_byid(type, p->dir, p->index, delete, &err);
 	else {
 		struct nlattr *rt = attrs[XFRMA_SEC_CTX];
-		struct xfrm_policy tmp;
+		struct xfrm_sec_ctx *ctx;
 
 		err = verify_sec_ctx_len(attrs);
 		if (err)
 			return err;
 
-		memset(&tmp, 0, sizeof(struct xfrm_policy));
 		if (rt) {
 			struct xfrm_user_sec_ctx *uctx = nla_data(rt);
 
-			if ((err = security_xfrm_policy_alloc(&tmp, uctx)))
+			err = security_xfrm_policy_alloc(&ctx, uctx);
+			if (err)
 				return err;
-		}
-		xp = xfrm_policy_bysel_ctx(type, p->dir, &p->sel, tmp.security,
+		} else
+			ctx = NULL;
+		xp = xfrm_policy_bysel_ctx(type, p->dir, &p->sel, ctx,
 					   delete, &err);
-		security_xfrm_policy_free(&tmp);
+		security_xfrm_policy_free(ctx);
 	}
 	if (xp == NULL)
 		return -ENOENT;
@@ -1560,26 +1561,26 @@ static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 		xp = xfrm_policy_byid(type, p->dir, p->index, 0, &err);
 	else {
 		struct nlattr *rt = attrs[XFRMA_SEC_CTX];
-		struct xfrm_policy tmp;
+		struct xfrm_sec_ctx *ctx;
 
 		err = verify_sec_ctx_len(attrs);
 		if (err)
 			return err;
 
-		memset(&tmp, 0, sizeof(struct xfrm_policy));
 		if (rt) {
 			struct xfrm_user_sec_ctx *uctx = nla_data(rt);
 
-			if ((err = security_xfrm_policy_alloc(&tmp, uctx)))
+			err = security_xfrm_policy_alloc(&ctx, uctx);
+			if (err)
 				return err;
-		}
-		xp = xfrm_policy_bysel_ctx(type, p->dir, &p->sel, tmp.security,
-					   0, &err);
-		security_xfrm_policy_free(&tmp);
+		} else
+			ctx = NULL;
+		xp = xfrm_policy_bysel_ctx(type, p->dir, &p->sel, ctx, 0, &err);
+		security_xfrm_policy_free(ctx);
 	}
-
 	if (xp == NULL)
 		return -ENOENT;
+
 	read_lock(&xp->lock);
 	if (xp->dead) {
 		read_unlock(&xp->lock);
diff --git a/security/dummy.c b/security/dummy.c
index 78d8f92..480366f 100644
--- a/security/dummy.c
+++ b/security/dummy.c
@@ -876,22 +876,23 @@ static inline void dummy_req_classify_flow(const struct request_sock *req,
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
-static int dummy_xfrm_policy_alloc_security(struct xfrm_policy *xp,
-		struct xfrm_user_sec_ctx *sec_ctx)
+static int dummy_xfrm_policy_alloc_security(struct xfrm_sec_ctx **ctxp,
+					    struct xfrm_user_sec_ctx *sec_ctx)
 {
 	return 0;
 }
 
-static inline int dummy_xfrm_policy_clone_security(struct xfrm_policy *old, struct xfrm_policy *new)
+static inline int dummy_xfrm_policy_clone_security(struct xfrm_sec_ctx *old_ctx,
+					   struct xfrm_sec_ctx **new_ctxp)
 {
 	return 0;
 }
 
-static void dummy_xfrm_policy_free_security(struct xfrm_policy *xp)
+static void dummy_xfrm_policy_free_security(struct xfrm_sec_ctx *ctx)
 {
 }
 
-static int dummy_xfrm_policy_delete_security(struct xfrm_policy *xp)
+static int dummy_xfrm_policy_delete_security(struct xfrm_sec_ctx *ctx)
 {
 	return 0;
 }
@@ -911,7 +912,8 @@ static int dummy_xfrm_state_delete_security(struct xfrm_state *x)
 	return 0;
 }
 
-static int dummy_xfrm_policy_lookup(struct xfrm_policy *xp, u32 sk_sid, u8 dir)
+static int dummy_xfrm_policy_lookup(struct xfrm_sec_ctx *ctx,
+				    u32 sk_sid, u8 dir)
 {
 	return 0;
 }
diff --git a/security/security.c b/security/security.c
index b1387a6..c9ff7d1 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1014,26 +1014,27 @@ void security_inet_conn_established(struct sock *sk,
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
 
-int security_xfrm_policy_alloc(struct xfrm_policy *xp, struct xfrm_user_sec_ctx *sec_ctx)
+int security_xfrm_policy_alloc(struct xfrm_sec_ctx **ctxp, struct xfrm_user_sec_ctx *sec_ctx)
 {
-	return security_ops->xfrm_policy_alloc_security(xp, sec_ctx);
+	return security_ops->xfrm_policy_alloc_security(ctxp, sec_ctx);
 }
 EXPORT_SYMBOL(security_xfrm_policy_alloc);
 
-int security_xfrm_policy_clone(struct xfrm_policy *old, struct xfrm_policy *new)
+int security_xfrm_policy_clone(struct xfrm_sec_ctx *old_ctx,
+			      struct xfrm_sec_ctx **new_ctxp)
 {
-	return security_ops->xfrm_policy_clone_security(old, new);
+	return security_ops->xfrm_policy_clone_security(old_ctx, new_ctxp);
 }
 
-void security_xfrm_policy_free(struct xfrm_policy *xp)
+void security_xfrm_policy_free(struct xfrm_sec_ctx *ctx)
 {
-	security_ops->xfrm_policy_free_security(xp);
+	security_ops->xfrm_policy_free_security(ctx);
 }
 EXPORT_SYMBOL(security_xfrm_policy_free);
 
-int security_xfrm_policy_delete(struct xfrm_policy *xp)
+int security_xfrm_policy_delete(struct xfrm_sec_ctx *ctx)
 {
-	return security_ops->xfrm_policy_delete_security(xp);
+	return security_ops->xfrm_policy_delete_security(ctx);
 }
 
 int security_xfrm_state_alloc(struct xfrm_state *x, struct xfrm_user_sec_ctx *sec_ctx)
@@ -1065,9 +1066,9 @@ void security_xfrm_state_free(struct xfrm_state *x)
 	security_ops->xfrm_state_free_security(x);
 }
 
-int security_xfrm_policy_lookup(struct xfrm_policy *xp, u32 fl_secid, u8 dir)
+int security_xfrm_policy_lookup(struct xfrm_sec_ctx *ctx, u32 fl_secid, u8 dir)
 {
-	return security_ops->xfrm_policy_lookup(xp, fl_secid, dir);
+	return security_ops->xfrm_policy_lookup(ctx, fl_secid, dir);
 }
 
 int security_xfrm_state_pol_flow_match(struct xfrm_state *x,
diff --git a/security/selinux/include/xfrm.h b/security/selinux/include/xfrm.h
index 36b0510..289e24b 100644
--- a/security/selinux/include/xfrm.h
+++ b/security/selinux/include/xfrm.h
@@ -7,16 +7,17 @@
 #ifndef _SELINUX_XFRM_H_
 #define _SELINUX_XFRM_H_
 
-int selinux_xfrm_policy_alloc(struct xfrm_policy *xp,
-		struct xfrm_user_sec_ctx *sec_ctx);
-int selinux_xfrm_policy_clone(struct xfrm_policy *old, struct xfrm_policy *new);
-void selinux_xfrm_policy_free(struct xfrm_policy *xp);
-int selinux_xfrm_policy_delete(struct xfrm_policy *xp);
+int selinux_xfrm_policy_alloc(struct xfrm_sec_ctx **ctxp,
+			      struct xfrm_user_sec_ctx *sec_ctx);
+int selinux_xfrm_policy_clone(struct xfrm_sec_ctx *old_ctx,
+			      struct xfrm_sec_ctx **new_ctxp);
+void selinux_xfrm_policy_free(struct xfrm_sec_ctx *ctx);
+int selinux_xfrm_policy_delete(struct xfrm_sec_ctx *ctx);
 int selinux_xfrm_state_alloc(struct xfrm_state *x,
 	struct xfrm_user_sec_ctx *sec_ctx, u32 secid);
 void selinux_xfrm_state_free(struct xfrm_state *x);
 int selinux_xfrm_state_delete(struct xfrm_state *x);
-int selinux_xfrm_policy_lookup(struct xfrm_policy *xp, u32 fl_secid, u8 dir);
+int selinux_xfrm_policy_lookup(struct xfrm_sec_ctx *ctx, u32 fl_secid, u8 dir);
 int selinux_xfrm_state_pol_flow_match(struct xfrm_state *x,
 			struct xfrm_policy *xp, struct flowi *fl);
 
diff --git a/security/selinux/xfrm.c b/security/selinux/xfrm.c
index 7e15820..874d17c 100644
--- a/security/selinux/xfrm.c
+++ b/security/selinux/xfrm.c
@@ -77,20 +77,18 @@ static inline int selinux_authorizable_xfrm(struct xfrm_state *x)
  * LSM hook implementation that authorizes that a flow can use
  * a xfrm policy rule.
  */
-int selinux_xfrm_policy_lookup(struct xfrm_policy *xp, u32 fl_secid, u8 dir)
+int selinux_xfrm_policy_lookup(struct xfrm_sec_ctx *ctx, u32 fl_secid, u8 dir)
 {
 	int rc;
 	u32 sel_sid;
-	struct xfrm_sec_ctx *ctx;
 
 	/* Context sid is either set to label or ANY_ASSOC */
-	if ((ctx = xp->security)) {
+	if (ctx) {
 		if (!selinux_authorizable_ctx(ctx))
 			return -EINVAL;
 
 		sel_sid = ctx->ctx_sid;
-	}
-	else
+	} else
 		/*
 		 * All flows should be treated as polmatch'ing an
 		 * otherwise applicable "non-labeled" policy. This
@@ -103,7 +101,7 @@ int selinux_xfrm_policy_lookup(struct xfrm_policy *xp, u32 fl_secid, u8 dir)
 			  NULL);
 
 	if (rc == -EACCES)
-		rc = -ESRCH;
+		return -ESRCH;
 
 	return rc;
 }
@@ -287,15 +285,14 @@ out2:
  * LSM hook implementation that allocs and transfers uctx spec to
  * xfrm_policy.
  */
-int selinux_xfrm_policy_alloc(struct xfrm_policy *xp,
-		struct xfrm_user_sec_ctx *uctx)
+int selinux_xfrm_policy_alloc(struct xfrm_sec_ctx **ctxp,
+			      struct xfrm_user_sec_ctx *uctx)
 {
 	int err;
 
-	BUG_ON(!xp);
 	BUG_ON(!uctx);
 
-	err = selinux_xfrm_sec_ctx_alloc(&xp->security, uctx, 0);
+	err = selinux_xfrm_sec_ctx_alloc(ctxp, uctx, 0);
 	if (err == 0)
 		atomic_inc(&selinux_xfrm_refcount);
 
@@ -307,32 +304,29 @@ int selinux_xfrm_policy_alloc(struct xfrm_policy *xp,
  * LSM hook implementation that copies security data structure from old to
  * new for policy cloning.
  */
-int selinux_xfrm_policy_clone(struct xfrm_policy *old, struct xfrm_policy *new)
+int selinux_xfrm_policy_clone(struct xfrm_sec_ctx *old_ctx,
+			      struct xfrm_sec_ctx **new_ctxp)
 {
-	struct xfrm_sec_ctx *old_ctx, *new_ctx;
-
-	old_ctx = old->security;
+	struct xfrm_sec_ctx *new_ctx;
 
 	if (old_ctx) {
-		new_ctx = new->security = kmalloc(sizeof(*new_ctx) +
-						  old_ctx->ctx_len,
-						  GFP_KERNEL);
-
+		new_ctx = kmalloc(sizeof(*old_ctx) + old_ctx->ctx_len,
+				  GFP_KERNEL);
 		if (!new_ctx)
 			return -ENOMEM;
 
 		memcpy(new_ctx, old_ctx, sizeof(*new_ctx));
 		memcpy(new_ctx->ctx_str, old_ctx->ctx_str, new_ctx->ctx_len);
+		*new_ctxp = new_ctx;
 	}
 	return 0;
 }
 
 /*
- * LSM hook implementation that frees xfrm_policy security information.
+ * LSM hook implementation that frees xfrm_sec_ctx security information.
  */
-void selinux_xfrm_policy_free(struct xfrm_policy *xp)
+void selinux_xfrm_policy_free(struct xfrm_sec_ctx *ctx)
 {
-	struct xfrm_sec_ctx *ctx = xp->security;
 	if (ctx)
 		kfree(ctx);
 }
@@ -340,10 +334,9 @@ void selinux_xfrm_policy_free(struct xfrm_policy *xp)
 /*
  * LSM hook implementation that authorizes deletion of labeled policies.
  */
-int selinux_xfrm_policy_delete(struct xfrm_policy *xp)
+int selinux_xfrm_policy_delete(struct xfrm_sec_ctx *ctx)
 {
 	struct task_security_struct *tsec = current->security;
-	struct xfrm_sec_ctx *ctx = xp->security;
 	int rc = 0;
 
 	if (ctx) {

