From: Paul Moore <pmoore@redhat.com>
Subject: [RFC PATCH 1/2] selinux: fix the labeled xfrm/IPsec reference count
 handling
Date: Thu, 23 May 2013 15:07:39 -0400
Message-ID: <20130523190739.19212.25214.stgit@localhost>
References: <20130523185659.19212.56853.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: omoris@redhat.com, pwouters@redhat.com
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62679 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759026Ab3EWTHm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 May 2013 15:07:42 -0400
In-Reply-To: <20130523185659.19212.56853.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SELinux labeled IPsec code was improperly handling its reference
counting, dropping a reference on a delete operation instead of on a
free/release operation.  This patch resolves this issue as well as
some other related issues:

* Change the name of the xfrm LSM security_operations field members
  to match the LSM hook names, like most everywhere else
* Don't reuse security_operations member functions across
  security_xfrm_state_alloc() and security_xfrm_state_alloc_acquire()
* Move the xfrm_sec_ctx check into the LSM specific function
* General cleanup/janitorial work in security/selinux/xfrm.c

Reported-by: Ondrej Moris <omoris@redhat.com>
Signed-off-by: Paul Moore <pmoore@redhat.com>
---
 include/linux/security.h        |   26 ++-
 security/capability.c           |   15 +-
 security/security.c             |   13 -
 security/selinux/hooks.c        |    5 -
 security/selinux/include/xfrm.h |    8 +
 security/selinux/xfrm.c         |  384 ++++++++++++++++++---------------------
 6 files changed, 217 insertions(+), 234 deletions(-)

diff --git a/include/linux/security.h b/include/linux/security.h
index 4686491..e5a5e8a 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -1039,17 +1039,25 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
  * @xfrm_policy_delete_security:
  *	@ctx contains the xfrm_sec_ctx.
  *	Authorize deletion of xp->security.
- * @xfrm_state_alloc_security:
+ * @xfrm_state_alloc:
  *	@x contains the xfrm_state being added to the Security Association
  *	Database by the XFRM system.
  *	@sec_ctx contains the security context information being provided by
  *	the user-level SA generation program (e.g., setkey or racoon).
- *	@secid contains the secid from which to take the mls portion of the context.
  *	Allocate a security structure to the x->security field; the security
  *	field is initialized to NULL when the xfrm_state is allocated. Set the
- *	context to correspond to either sec_ctx or polsec, with the mls portion
- *	taken from secid in the latter case.
- *	Return 0 if operation was successful (memory to allocate, legal context).
+ *	context to correspond to sec_ctx. Return 0 if operation was successful
+ *	(memory to allocate, legal context).
+ * @xfrm_state_alloc_acquire:
+ *	@x contains the xfrm_state being added to the Security Association
+ *	Database by the XFRM system.
+ *	@polsec contains the policy's security context.
+ *	@secid contains the secid from which to take the mls portion of the
+ *	context.
+ *	Allocate a security structure to the x->security field; the security
+ *	field is initialized to NULL when the xfrm_state is allocated. Set the
+ *	context to correspond to secid. Return 0 if operation was successful
+ *	(memory to allocate, legal context).
  * @xfrm_state_free_security:
  *	@x contains the xfrm_state.
  *	Deallocate x->security.
@@ -1651,9 +1659,11 @@ struct security_operations {
 	int (*xfrm_policy_clone_security) (struct xfrm_sec_ctx *old_ctx, struct xfrm_sec_ctx **new_ctx);
 	void (*xfrm_policy_free_security) (struct xfrm_sec_ctx *ctx);
 	int (*xfrm_policy_delete_security) (struct xfrm_sec_ctx *ctx);
-	int (*xfrm_state_alloc_security) (struct xfrm_state *x,
-		struct xfrm_user_sec_ctx *sec_ctx,
-		u32 secid);
+	int (*xfrm_state_alloc) (struct xfrm_state *x,
+				 struct xfrm_user_sec_ctx *sec_ctx);
+	int (*xfrm_state_alloc_acquire) (struct xfrm_state *x,
+					 struct xfrm_sec_ctx *polsec,
+					 u32 secid);
 	void (*xfrm_state_free_security) (struct xfrm_state *x);
 	int (*xfrm_state_delete_security) (struct xfrm_state *x);
 	int (*xfrm_policy_lookup) (struct xfrm_sec_ctx *ctx, u32 fl_secid, u8 dir);
diff --git a/security/capability.c b/security/capability.c
index 1728d4e..67afc67 100644
--- a/security/capability.c
+++ b/security/capability.c
@@ -767,9 +767,15 @@ static int cap_xfrm_policy_delete_security(struct xfrm_sec_ctx *ctx)
 	return 0;
 }
 
-static int cap_xfrm_state_alloc_security(struct xfrm_state *x,
-					 struct xfrm_user_sec_ctx *sec_ctx,
-					 u32 secid)
+static int cap_xfrm_state_alloc(struct xfrm_state *x,
+				struct xfrm_user_sec_ctx *sec_ctx)
+{
+	return 0;
+}
+
+static int cap_xfrm_state_alloc_acquire(struct xfrm_state *x,
+					struct xfrm_sec_ctx *polsec,
+					u32 secid)
 {
 	return 0;
 }
@@ -1084,7 +1090,8 @@ void __init security_fixup_ops(struct security_operations *ops)
 	set_to_cap_if_null(ops, xfrm_policy_clone_security);
 	set_to_cap_if_null(ops, xfrm_policy_free_security);
 	set_to_cap_if_null(ops, xfrm_policy_delete_security);
-	set_to_cap_if_null(ops, xfrm_state_alloc_security);
+	set_to_cap_if_null(ops, xfrm_state_alloc);
+	set_to_cap_if_null(ops, xfrm_state_alloc_acquire);
 	set_to_cap_if_null(ops, xfrm_state_free_security);
 	set_to_cap_if_null(ops, xfrm_state_delete_security);
 	set_to_cap_if_null(ops, xfrm_policy_lookup);
diff --git a/security/security.c b/security/security.c
index a3dce87..57e25c9 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1322,22 +1322,17 @@ int security_xfrm_policy_delete(struct xfrm_sec_ctx *ctx)
 	return security_ops->xfrm_policy_delete_security(ctx);
 }
 
-int security_xfrm_state_alloc(struct xfrm_state *x, struct xfrm_user_sec_ctx *sec_ctx)
+int security_xfrm_state_alloc(struct xfrm_state *x,
+			      struct xfrm_user_sec_ctx *sec_ctx)
 {
-	return security_ops->xfrm_state_alloc_security(x, sec_ctx, 0);
+	return security_ops->xfrm_state_alloc(x, sec_ctx);
 }
 EXPORT_SYMBOL(security_xfrm_state_alloc);
 
 int security_xfrm_state_alloc_acquire(struct xfrm_state *x,
 				      struct xfrm_sec_ctx *polsec, u32 secid)
 {
-	if (!polsec)
-		return 0;
-	/*
-	 * We want the context to be taken from secid which is usually
-	 * from the sock.
-	 */
-	return security_ops->xfrm_state_alloc_security(x, NULL, secid);
+	return security_ops->xfrm_state_alloc_acquire(x, polsec, secid);
 }
 
 int security_xfrm_state_delete(struct xfrm_state *x)
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 5c6f2cd..e364504 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -5705,10 +5705,11 @@ static struct security_operations selinux_ops = {
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
 	.xfrm_policy_alloc_security =	selinux_xfrm_policy_alloc,
-	.xfrm_policy_clone_security =	selinux_xfrm_policy_clone,
+	.xfrm_policy_clone_security =	selinux_xfrm_clone,
 	.xfrm_policy_free_security =	selinux_xfrm_policy_free,
 	.xfrm_policy_delete_security =	selinux_xfrm_policy_delete,
-	.xfrm_state_alloc_security =	selinux_xfrm_state_alloc,
+	.xfrm_state_alloc =		selinux_xfrm_state_alloc,
+	.xfrm_state_alloc_acquire =	selinux_xfrm_state_alloc_acquire,
 	.xfrm_state_free_security =	selinux_xfrm_state_free,
 	.xfrm_state_delete_security =	selinux_xfrm_state_delete,
 	.xfrm_policy_lookup =		selinux_xfrm_policy_lookup,
diff --git a/security/selinux/include/xfrm.h b/security/selinux/include/xfrm.h
index 65f67cb..5afd8f9 100644
--- a/security/selinux/include/xfrm.h
+++ b/security/selinux/include/xfrm.h
@@ -9,14 +9,16 @@
 
 #include <net/flow.h>
 
+int selinux_xfrm_clone(struct xfrm_sec_ctx *old_ctx,
+		       struct xfrm_sec_ctx **new_ctxp);
 int selinux_xfrm_policy_alloc(struct xfrm_sec_ctx **ctxp,
 			      struct xfrm_user_sec_ctx *sec_ctx);
-int selinux_xfrm_policy_clone(struct xfrm_sec_ctx *old_ctx,
-			      struct xfrm_sec_ctx **new_ctxp);
 void selinux_xfrm_policy_free(struct xfrm_sec_ctx *ctx);
 int selinux_xfrm_policy_delete(struct xfrm_sec_ctx *ctx);
 int selinux_xfrm_state_alloc(struct xfrm_state *x,
-	struct xfrm_user_sec_ctx *sec_ctx, u32 secid);
+			     struct xfrm_user_sec_ctx *sec_ctx);
+int selinux_xfrm_state_alloc_acquire(struct xfrm_state *x,
+				     struct xfrm_sec_ctx *polsec, u32 secid);
 void selinux_xfrm_state_free(struct xfrm_state *x);
 int selinux_xfrm_state_delete(struct xfrm_state *x);
 int selinux_xfrm_policy_lookup(struct xfrm_sec_ctx *ctx, u32 fl_secid, u8 dir);
diff --git a/security/selinux/xfrm.c b/security/selinux/xfrm.c
index 8ab2951..3ff74fc 100644
--- a/security/selinux/xfrm.c
+++ b/security/selinux/xfrm.c
@@ -74,21 +74,111 @@ static inline int selinux_authorizable_xfrm(struct xfrm_state *x)
 }
 
 /*
+ * Allocates and transfers the xfrm_user_sec_ctx context to a new xfrm_sec_ctx
+ * structure.
+ */
+static int selinux_xfrm_alloc_user(struct xfrm_sec_ctx **ctxp,
+				   struct xfrm_user_sec_ctx *uctx)
+{
+	int rc;
+	const struct task_security_struct *tsec = current_security();
+	struct xfrm_sec_ctx *ctx;
+	int str_len;
+
+	if (!uctx ||
+	    uctx->ctx_doi != XFRM_SC_DOI_LSM ||
+	    uctx->ctx_alg != XFRM_SC_ALG_SELINUX)
+		return -EINVAL;
+	str_len = uctx->ctx_len;
+	if (str_len >= PAGE_SIZE)
+		return -ENOMEM;
+
+	ctx = kmalloc(sizeof(*ctx) + str_len + 1, GFP_KERNEL);
+	if (!ctx)
+		return -ENOMEM;
+
+	ctx->ctx_doi = XFRM_SC_DOI_LSM;
+	ctx->ctx_alg = XFRM_SC_ALG_SELINUX;
+	ctx->ctx_len = str_len;
+	memcpy(ctx->ctx_str, uctx + 1, str_len);
+	ctx->ctx_str[str_len] = 0;
+	rc = security_context_to_sid(ctx->ctx_str, str_len, &ctx->ctx_sid);
+	if (rc)
+		goto err;
+
+	rc = avc_has_perm(tsec->sid, ctx->ctx_sid,
+			  SECCLASS_ASSOCIATION, ASSOCIATION__SETCONTEXT, NULL);
+	if (rc)
+		goto err;
+
+	*ctxp = ctx;
+	atomic_inc(&selinux_xfrm_refcount);
+	return 0;
+
+err:
+	kfree(ctx);
+	return rc;
+}
+
+/*
+ * Free the xfrm_sec_ctx structure.
+ */
+static void selinux_xfrm_free(struct xfrm_sec_ctx *ctx)
+{
+	if (!ctx)
+		return;
+
+	BUG_ON(atomic_read(&selinux_xfrm_refcount) == 0);
+	atomic_dec(&selinux_xfrm_refcount);
+	kfree(ctx);
+}
+
+ /*
+  * Authorize the deletion of a labeled SA or policy rule.
+  */
+static int selinux_xfrm_delete(struct xfrm_sec_ctx *ctx)
+{
+	const struct task_security_struct *tsec = current_security();
+
+	if (!ctx)
+		return 0;
+
+	return avc_has_perm(tsec->sid, ctx->ctx_sid,
+			    SECCLASS_ASSOCIATION, ASSOCIATION__SETCONTEXT,
+			    NULL);
+}
+
+/*
+ * LSM hook implementation that copies security data structure from old to
+ * new for policy cloning.
+ */
+int selinux_xfrm_clone(struct xfrm_sec_ctx *old_ctx,
+		       struct xfrm_sec_ctx **new_ctxp)
+{
+	struct xfrm_sec_ctx *new_ctx;
+
+	if (!old_ctx)
+		return 0;
+
+	new_ctx = kmalloc(sizeof(*old_ctx) + old_ctx->ctx_len, GFP_ATOMIC);
+	if (!new_ctx)
+		return -ENOMEM;
+	memcpy(new_ctx, old_ctx, sizeof(*old_ctx) + old_ctx->ctx_len);
+
+	*new_ctxp = new_ctx;
+	atomic_inc(&selinux_xfrm_refcount);
+	return 0;
+}
+
+/*
  * LSM hook implementation that authorizes that a flow can use
  * a xfrm policy rule.
  */
 int selinux_xfrm_policy_lookup(struct xfrm_sec_ctx *ctx, u32 fl_secid, u8 dir)
 {
 	int rc;
-	u32 sel_sid;
 
-	/* Context sid is either set to label or ANY_ASSOC */
-	if (ctx) {
-		if (!selinux_authorizable_ctx(ctx))
-			return -EINVAL;
-
-		sel_sid = ctx->ctx_sid;
-	} else
+	if (!ctx)
 		/*
 		 * All flows should be treated as polmatch'ing an
 		 * otherwise applicable "non-labeled" policy. This
@@ -96,13 +186,14 @@ int selinux_xfrm_policy_lookup(struct xfrm_sec_ctx *ctx, u32 fl_secid, u8 dir)
 		 */
 		return 0;
 
-	rc = avc_has_perm(fl_secid, sel_sid, SECCLASS_ASSOCIATION,
-			  ASSOCIATION__POLMATCH,
-			  NULL);
+	/* Context sid is either set to label or ANY_ASSOC */
+	if (!selinux_authorizable_ctx(ctx))
+		return -EINVAL;
 
+	rc = avc_has_perm(fl_secid, ctx->ctx_sid,
+			  SECCLASS_ASSOCIATION, ASSOCIATION__POLMATCH, NULL);
 	if (rc == -EACCES)
 		return -ESRCH;
-
 	return rc;
 }
 
@@ -111,11 +202,11 @@ int selinux_xfrm_policy_lookup(struct xfrm_sec_ctx *ctx, u32 fl_secid, u8 dir)
  * the given policy, flow combo.
  */
 
-int selinux_xfrm_state_pol_flow_match(struct xfrm_state *x, struct xfrm_policy *xp,
-			const struct flowi *fl)
+int selinux_xfrm_state_pol_flow_match(struct xfrm_state *x,
+				      struct xfrm_policy *xp,
+				      const struct flowi *fl)
 {
 	u32 state_sid;
-	int rc;
 
 	if (!xp->security)
 		if (x->security)
@@ -138,10 +229,6 @@ int selinux_xfrm_state_pol_flow_match(struct xfrm_state *x, struct xfrm_policy *
 	if (fl->flowi_secid != state_sid)
 		return 0;
 
-	rc = avc_has_perm(fl->flowi_secid, state_sid, SECCLASS_ASSOCIATION,
-			  ASSOCIATION__SENDTO,
-			  NULL)? 0:1;
-
 	/*
 	 * We don't need a separate SA Vs. policy polmatch check
 	 * since the SA is now of the same label as the flow and
@@ -149,7 +236,9 @@ int selinux_xfrm_state_pol_flow_match(struct xfrm_state *x, struct xfrm_policy *
 	 * in selinux_xfrm_policy_lookup() above.
 	 */
 
-	return rc;
+	return avc_has_perm(fl->flowi_secid, state_sid,
+			    SECCLASS_ASSOCIATION, ASSOCIATION__SENDTO,
+			    NULL) ? 0 : 1;
 }
 
 /*
@@ -191,134 +280,13 @@ int selinux_xfrm_decode_session(struct sk_buff *skb, u32 *sid, int ckall)
 }
 
 /*
- * Security blob allocation for xfrm_policy and xfrm_state
- * CTX does not have a meaningful value on input
- */
-static int selinux_xfrm_sec_ctx_alloc(struct xfrm_sec_ctx **ctxp,
-	struct xfrm_user_sec_ctx *uctx, u32 sid)
-{
-	int rc = 0;
-	const struct task_security_struct *tsec = current_security();
-	struct xfrm_sec_ctx *ctx = NULL;
-	char *ctx_str = NULL;
-	u32 str_len;
-
-	BUG_ON(uctx && sid);
-
-	if (!uctx)
-		goto not_from_user;
-
-	if (uctx->ctx_alg != XFRM_SC_ALG_SELINUX)
-		return -EINVAL;
-
-	str_len = uctx->ctx_len;
-	if (str_len >= PAGE_SIZE)
-		return -ENOMEM;
-
-	*ctxp = ctx = kmalloc(sizeof(*ctx) +
-			      str_len + 1,
-			      GFP_KERNEL);
-
-	if (!ctx)
-		return -ENOMEM;
-
-	ctx->ctx_doi = uctx->ctx_doi;
-	ctx->ctx_len = str_len;
-	ctx->ctx_alg = uctx->ctx_alg;
-
-	memcpy(ctx->ctx_str,
-	       uctx+1,
-	       str_len);
-	ctx->ctx_str[str_len] = 0;
-	rc = security_context_to_sid(ctx->ctx_str,
-				     str_len,
-				     &ctx->ctx_sid);
-
-	if (rc)
-		goto out;
-
-	/*
-	 * Does the subject have permission to set security context?
-	 */
-	rc = avc_has_perm(tsec->sid, ctx->ctx_sid,
-			  SECCLASS_ASSOCIATION,
-			  ASSOCIATION__SETCONTEXT, NULL);
-	if (rc)
-		goto out;
-
-	return rc;
-
-not_from_user:
-	rc = security_sid_to_context(sid, &ctx_str, &str_len);
-	if (rc)
-		goto out;
-
-	*ctxp = ctx = kmalloc(sizeof(*ctx) +
-			      str_len,
-			      GFP_ATOMIC);
-
-	if (!ctx) {
-		rc = -ENOMEM;
-		goto out;
-	}
-
-	ctx->ctx_doi = XFRM_SC_DOI_LSM;
-	ctx->ctx_alg = XFRM_SC_ALG_SELINUX;
-	ctx->ctx_sid = sid;
-	ctx->ctx_len = str_len;
-	memcpy(ctx->ctx_str,
-	       ctx_str,
-	       str_len);
-
-	goto out2;
-
-out:
-	*ctxp = NULL;
-	kfree(ctx);
-out2:
-	kfree(ctx_str);
-	return rc;
-}
-
-/*
  * LSM hook implementation that allocs and transfers uctx spec to
  * xfrm_policy.
  */
 int selinux_xfrm_policy_alloc(struct xfrm_sec_ctx **ctxp,
 			      struct xfrm_user_sec_ctx *uctx)
 {
-	int err;
-
-	BUG_ON(!uctx);
-
-	err = selinux_xfrm_sec_ctx_alloc(ctxp, uctx, 0);
-	if (err == 0)
-		atomic_inc(&selinux_xfrm_refcount);
-
-	return err;
-}
-
-
-/*
- * LSM hook implementation that copies security data structure from old to
- * new for policy cloning.
- */
-int selinux_xfrm_policy_clone(struct xfrm_sec_ctx *old_ctx,
-			      struct xfrm_sec_ctx **new_ctxp)
-{
-	struct xfrm_sec_ctx *new_ctx;
-
-	if (old_ctx) {
-		new_ctx = kmalloc(sizeof(*old_ctx) + old_ctx->ctx_len,
-				  GFP_ATOMIC);
-		if (!new_ctx)
-			return -ENOMEM;
-
-		memcpy(new_ctx, old_ctx, sizeof(*new_ctx));
-		memcpy(new_ctx->ctx_str, old_ctx->ctx_str, new_ctx->ctx_len);
-		*new_ctxp = new_ctx;
-	}
-	return 0;
+	return selinux_xfrm_alloc_user(ctxp, uctx);
 }
 
 /*
@@ -326,7 +294,7 @@ int selinux_xfrm_policy_clone(struct xfrm_sec_ctx *old_ctx,
  */
 void selinux_xfrm_policy_free(struct xfrm_sec_ctx *ctx)
 {
-	kfree(ctx);
+	selinux_xfrm_free(ctx);
 }
 
 /*
@@ -334,35 +302,56 @@ void selinux_xfrm_policy_free(struct xfrm_sec_ctx *ctx)
  */
 int selinux_xfrm_policy_delete(struct xfrm_sec_ctx *ctx)
 {
-	const struct task_security_struct *tsec = current_security();
-	int rc = 0;
-
-	if (ctx) {
-		rc = avc_has_perm(tsec->sid, ctx->ctx_sid,
-				  SECCLASS_ASSOCIATION,
-				  ASSOCIATION__SETCONTEXT, NULL);
-		if (rc == 0)
-			atomic_dec(&selinux_xfrm_refcount);
-	}
+	return selinux_xfrm_delete(ctx);
+}
 
-	return rc;
+/*
+ * LSM hook implementation that allocs and transfers the xfrm_user_sec_ctx
+ * context to the xfrm_state.
+ */
+int selinux_xfrm_state_alloc(struct xfrm_state *x,
+			     struct xfrm_user_sec_ctx *uctx)
+{
+	return selinux_xfrm_alloc_user(&x->security, uctx);
 }
 
 /*
- * LSM hook implementation that allocs and transfers sec_ctx spec to
- * xfrm_state.
+ * LSM hook implementation that allocs and transfers the secid context to
+ * the xfrm_state.
  */
-int selinux_xfrm_state_alloc(struct xfrm_state *x, struct xfrm_user_sec_ctx *uctx,
-		u32 secid)
+int selinux_xfrm_state_alloc_acquire(struct xfrm_state *x,
+				     struct xfrm_sec_ctx *polsec, u32 secid)
 {
-	int err;
+	int rc;
+	struct xfrm_sec_ctx *ctx;
+	char *ctx_str = NULL;
+	int str_len;
+
+	if (!polsec)
+		return 0;
 
-	BUG_ON(!x);
+	BUG_ON(secid == 0);
+	if (secid == 0)
+		return -EINVAL;
 
-	err = selinux_xfrm_sec_ctx_alloc(&x->security, uctx, secid);
-	if (err == 0)
-		atomic_inc(&selinux_xfrm_refcount);
-	return err;
+	rc = security_sid_to_context(secid, &ctx_str, &str_len);
+	if (rc)
+		return rc;
+
+	ctx = kmalloc(sizeof(*ctx) + str_len, GFP_ATOMIC);
+	if (!ctx)
+		return -ENOMEM;
+
+	ctx->ctx_doi = XFRM_SC_DOI_LSM;
+	ctx->ctx_alg = XFRM_SC_ALG_SELINUX;
+	ctx->ctx_sid = secid;
+	ctx->ctx_len = str_len;
+	memcpy(ctx->ctx_str, ctx_str, str_len);
+	kfree(ctx_str);
+
+	x->security = ctx;
+	atomic_inc(&selinux_xfrm_refcount);
+	return 0;
 }
 
 /*
@@ -370,8 +359,7 @@ int selinux_xfrm_state_alloc(struct xfrm_state *x, struct xfrm_user_sec_ctx *uct
  */
 void selinux_xfrm_state_free(struct xfrm_state *x)
 {
-	struct xfrm_sec_ctx *ctx = x->security;
-	kfree(ctx);
+	selinux_xfrm_free(x->security);
 }
 
  /*
@@ -379,19 +367,7 @@ void selinux_xfrm_state_free(struct xfrm_state *x)
   */
 int selinux_xfrm_state_delete(struct xfrm_state *x)
 {
-	const struct task_security_struct *tsec = current_security();
-	struct xfrm_sec_ctx *ctx = x->security;
-	int rc = 0;
-
-	if (ctx) {
-		rc = avc_has_perm(tsec->sid, ctx->ctx_sid,
-				  SECCLASS_ASSOCIATION,
-				  ASSOCIATION__SETCONTEXT, NULL);
-		if (rc == 0)
-			atomic_dec(&selinux_xfrm_refcount);
-	}
-
-	return rc;
+	return selinux_xfrm_delete(x->security);
 }
 
 /*
@@ -402,14 +378,12 @@ int selinux_xfrm_state_delete(struct xfrm_state *x)
  * gone thru the IPSec process.
  */
 int selinux_xfrm_sock_rcv_skb(u32 isec_sid, struct sk_buff *skb,
-				struct common_audit_data *ad)
+			      struct common_audit_data *ad)
 {
-	int i, rc = 0;
-	struct sec_path *sp;
+	int i;
+	struct sec_path *sp = skb->sp;
 	u32 sel_sid = SECINITSID_UNLABELED;
 
-	sp = skb->sp;
-
 	if (sp) {
 		for (i = 0; i < sp->len; i++) {
 			struct xfrm_state *x = sp->xvec[i];
@@ -429,10 +403,8 @@ int selinux_xfrm_sock_rcv_skb(u32 isec_sid, struct sk_buff *skb,
 	 * explicitly allowed by policy.
 	 */
 
-	rc = avc_has_perm(isec_sid, sel_sid, SECCLASS_ASSOCIATION,
-			  ASSOCIATION__RECVFROM, ad);
-
-	return rc;
+	return avc_has_perm(isec_sid, sel_sid,
+			    SECCLASS_ASSOCIATION, ASSOCIATION__RECVFROM, ad);
 }
 
 /*
@@ -446,21 +418,6 @@ int selinux_xfrm_postroute_last(u32 isec_sid, struct sk_buff *skb,
 					struct common_audit_data *ad, u8 proto)
 {
 	struct dst_entry *dst;
-	int rc = 0;
-
-	dst = skb_dst(skb);
-
-	if (dst) {
-		struct dst_entry *dst_test;
-
-		for (dst_test = dst; dst_test != NULL;
-		     dst_test = dst_test->child) {
-			struct xfrm_state *x = dst_test->xfrm;
-
-			if (x && selinux_authorizable_xfrm(x))
-				goto out;
-		}
-	}
 
 	switch (proto) {
 	case IPPROTO_AH:
@@ -471,11 +428,24 @@ int selinux_xfrm_postroute_last(u32 isec_sid, struct sk_buff *skb,
 		 * it underwent xfrm(s). No need to subject it to the
 		 * unlabeled check.
 		 */
-		goto out;
+		return 0;
 	default:
 		break;
 	}
 
+	dst = skb_dst(skb);
+	if (dst) {
+		struct dst_entry *dst_test;
+
+		for (dst_test = dst; dst_test != NULL;
+		     dst_test = dst_test->child) {
+			struct xfrm_state *x = dst_test->xfrm;
+
+			if (x && selinux_authorizable_xfrm(x))
+				return 0;
+		}
+	}
+
 	/*
 	 * This check even when there's no association involved is
 	 * intended, according to Trent Jaeger, to make sure a
@@ -483,8 +453,6 @@ int selinux_xfrm_postroute_last(u32 isec_sid, struct sk_buff *skb,
 	 * explicitly allowed by policy.
 	 */
 
-	rc = avc_has_perm(isec_sid, SECINITSID_UNLABELED, SECCLASS_ASSOCIATION,
-			  ASSOCIATION__SENDTO, ad);
-out:
-	return rc;
+	return avc_has_perm(isec_sid, SECINITSID_UNLABELED,
+			    SECCLASS_ASSOCIATION, ASSOCIATION__SENDTO, ad);
 }
