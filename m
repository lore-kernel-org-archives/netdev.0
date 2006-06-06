From: Catherine Zhang <cxzhang@watson.ibm.com>
Subject: [PATCH 1/1] LSM-IPsec SELinux Authorize (with minor fix)
Date: Tue, 6 Jun 2006 00:38:18 -0400
Message-ID: <20060606043818.GA4125@jiayuguan.watson.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: latten@austin.ibm.com, sergeh@us.ibm.com, gcwilson@us.ibm.com,
	czhang.us@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from igw2.watson.ibm.com ([129.34.20.6]:32987 "EHLO
	igw2.watson.ibm.com") by vger.kernel.org with ESMTP id S932083AbWFFEet
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jun 2006 00:34:49 -0400
To: James Morris <jmorris@namei.org>, netdev@vger.kernel.org,
	davem@davemloft.net, chrisw@osdl.org, herbert@gondor.apana.org.au,
	sds@tycho.nsa.gov, tjaeger@cse.psu.edu
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Minor fix per James' comment.

thanks,
Catherine

--
This patch contains a fix for the previous patch that adds security
contexts to IPsec policies and security associations.  In the previous
patch, no authorization (besides the check for write permissions to
SAD and SPD) is required to delete IPsec policies and security
assocations with security contexts.  Thus a user authorized to change
SAD and SPD can bypass the IPsec policy authorization by simply
deleteing policies with security contexts.  To fix this security hole,
an additional authorization check is added for removing security
policies and security associations with security contexts.

Note that if no security context is supplied on add or present on
policy to be deleted, the SELinux module allows the change
unconditionally.  The hook is called on deletion when no context is
present, which we may want to change.  At present, I left it up to the
module.

LSM changes:

The patch adds two new LSM hooks: xfrm_policy_delete and
xfrm_state_delete.  The new hooks are necessary to authorize deletion
of IPsec policies that have security contexts.  The existing hooks
xfrm_policy_free and xfrm_state_free lack the context to do the
authorization, so I decided to split authorization of deletion and
memory management of security data, as is typical in the LSM
interface.

Use:

The new delete hooks are checked when xfrm_policy or xfrm_state are
deleted by either the xfrm_user interface (xfrm_get_policy,
xfrm_del_sa) or the pfkey interface (pfkey_spddelete, pfkey_delete).

SELinux changes:

The new policy_delete and state_delete functions are added.

Signed-off-by: Trent Jaeger <tjaeger@cse.psu.edu>

---

 include/linux/security.h        |   40 ++++++++++++++++++++++++++++++++++------
 net/key/af_key.c                |   17 +++++++++++------
 net/xfrm/xfrm_user.c            |   19 ++++++++++++-------
 security/dummy.c                |   12 ++++++++++++
 security/selinux/hooks.c        |    2 ++
 security/selinux/include/xfrm.h |    2 ++
 security/selinux/xfrm.c         |   39 +++++++++++++++++++++++++++++++++++----
 7 files changed, 108 insertions(+), 23 deletions(-)

diff -puN include/linux/security.h~lsm-secpeer-fix include/linux/security.h
--- linux-2.6.17-rc4-mm3/include/linux/security.h~lsm-secpeer-fix	2006-05-31 00:01:35.000000000 -0400
+++ linux-2.6.17-rc4-mm3-cxzhang/include/linux/security.h	2006-05-31 00:46:13.000000000 -0400
@@ -805,31 +805,37 @@ struct swap_info_struct;
  *	used by the XFRM system.
  *	@sec_ctx contains the security context information being provided by
  *	the user-level policy update program (e.g., setkey).
- *	Allocate a security structure to the xp->selector.security field.
+ *	Allocate a security structure to the xp->security field.
  *	The security field is initialized to NULL when the xfrm_policy is
  *	allocated.
  *	Return 0 if operation was successful (memory to allocate, legal context)
  * @xfrm_policy_clone_security:
  *	@old contains an existing xfrm_policy in the SPD.
  *	@new contains a new xfrm_policy being cloned from old.
- *	Allocate a security structure to the new->selector.security field
- *	that contains the information from the old->selector.security field.
+ *	Allocate a security structure to the new->security field
+ *	that contains the information from the old->security field.
  *	Return 0 if operation was successful (memory to allocate).
  * @xfrm_policy_free_security:
  *	@xp contains the xfrm_policy
- *	Deallocate xp->selector.security.
+ *	Deallocate xp->security.
+ * @xfrm_policy_delete_security:
+ *	@xp contains the xfrm_policy.
+ *	Authorize deletion of xp->security.
  * @xfrm_state_alloc_security:
  *	@x contains the xfrm_state being added to the Security Association
  *	Database by the XFRM system.
  *	@sec_ctx contains the security context information being provided by
  *	the user-level SA generation program (e.g., setkey or racoon).
- *	Allocate a security structure to the x->sel.security field.  The
+ *	Allocate a security structure to the x->security field.  The
  *	security field is initialized to NULL when the xfrm_state is
  *	allocated.
  *	Return 0 if operation was successful (memory to allocate, legal context).
  * @xfrm_state_free_security:
  *	@x contains the xfrm_state.
- *	Deallocate x>sel.security.
+ *	Deallocate x->security.
+ * @xfrm_state_delete_security:
+ *	@x contains the xfrm_state.
+ *	Authorize deletion of x->security.
  * @xfrm_policy_lookup:
  *	@xp contains the xfrm_policy for which the access control is being
  *	checked.
@@ -1298,8 +1304,10 @@ struct security_operations {
 	int (*xfrm_policy_alloc_security) (struct xfrm_policy *xp, struct xfrm_user_sec_ctx *sec_ctx);
 	int (*xfrm_policy_clone_security) (struct xfrm_policy *old, struct xfrm_policy *new);
 	void (*xfrm_policy_free_security) (struct xfrm_policy *xp);
+	int (*xfrm_policy_delete_security) (struct xfrm_policy *xp);
 	int (*xfrm_state_alloc_security) (struct xfrm_state *x, struct xfrm_user_sec_ctx *sec_ctx);
 	void (*xfrm_state_free_security) (struct xfrm_state *x);
+	int (*xfrm_state_delete_security) (struct xfrm_state *x);
 	int (*xfrm_policy_lookup)(struct xfrm_policy *xp, u32 sk_sid, u8 dir);
 #endif	/* CONFIG_SECURITY_NETWORK_XFRM */
 
@@ -2934,11 +2942,21 @@ static inline void security_xfrm_policy_
 	security_ops->xfrm_policy_free_security(xp);
 }
 
+static inline int security_xfrm_policy_delete(struct xfrm_policy *xp)
+{
+	return security_ops->xfrm_policy_delete_security(xp);
+}
+
 static inline int security_xfrm_state_alloc(struct xfrm_state *x, struct xfrm_user_sec_ctx *sec_ctx)
 {
 	return security_ops->xfrm_state_alloc_security(x, sec_ctx);
 }
 
+static inline int security_xfrm_state_delete(struct xfrm_state *x)
+{
+	return security_ops->xfrm_state_delete_security(x);
+}
+
 static inline void security_xfrm_state_free(struct xfrm_state *x)
 {
 	security_ops->xfrm_state_free_security(x);
@@ -2963,6 +2981,11 @@ static inline void security_xfrm_policy_
 {
 }
 
+static inline int security_xfrm_policy_delete(struct xfrm_policy *xp)
+{
+	return 0;
+}
+
 static inline int security_xfrm_state_alloc(struct xfrm_state *x, struct xfrm_user_sec_ctx *sec_ctx)
 {
 	return 0;
@@ -2972,6 +2995,11 @@ static inline void security_xfrm_state_f
 {
 }
 
+static inline int security_xfrm_state_delete(struct xfrm_policy *xp)
+{
+	return 0;
+}
+
 static inline int security_xfrm_policy_lookup(struct xfrm_policy *xp, u32 sk_sid, u8 dir)
 {
 	return 0;
diff -puN net/key/af_key.c~lsm-secpeer-fix net/key/af_key.c
--- linux-2.6.17-rc4-mm3/net/key/af_key.c~lsm-secpeer-fix	2006-05-31 00:01:46.000000000 -0400
+++ linux-2.6.17-rc4-mm3-cxzhang/net/key/af_key.c	2006-05-31 00:04:22.000000000 -0400
@@ -1454,21 +1454,23 @@ static int pfkey_delete(struct sock *sk,
 	if (x == NULL)
 		return -ESRCH;
 
+	if ((err = security_xfrm_state_delete(x)))
+		goto out;
+
 	if (xfrm_state_kern(x)) {
-		xfrm_state_put(x);
-		return -EPERM;
+		err = -EPERM;
+		goto out;
 	}
 	
 	err = xfrm_state_delete(x);
-	if (err < 0) {
-		xfrm_state_put(x);
-		return err;
-	}
+	if (err < 0)
+		goto out;
 
 	c.seq = hdr->sadb_msg_seq;
 	c.pid = hdr->sadb_msg_pid;
 	c.event = XFRM_MSG_DELSA;
 	km_state_notify(x, &c);
+out:
 	xfrm_state_put(x);
 
 	return err;
@@ -2274,11 +2276,14 @@ static int pfkey_spddelete(struct sock *
 
 	err = 0;
 
+	if ((err = security_xfrm_policy_delete(xp)))
+		goto out;
 	c.seq = hdr->sadb_msg_seq;
 	c.pid = hdr->sadb_msg_pid;
 	c.event = XFRM_MSG_DELPOLICY;
 	km_policy_notify(xp, pol->sadb_x_policy_dir-1, &c);
 
+out:
 	xfrm_pol_put(xp);
 	return err;
 }
diff -puN net/xfrm/xfrm_user.c~lsm-secpeer-fix net/xfrm/xfrm_user.c
--- linux-2.6.17-rc4-mm3/net/xfrm/xfrm_user.c~lsm-secpeer-fix	2006-05-31 00:01:54.000000000 -0400
+++ linux-2.6.17-rc4-mm3-cxzhang/net/xfrm/xfrm_user.c	2006-05-31 00:04:22.000000000 -0400
@@ -427,23 +427,25 @@ static int xfrm_del_sa(struct sk_buff *s
 	if (x == NULL)
 		return -ESRCH;
 
+	if (err = security_xfrm_state_delete(x))
+		goto out;
+
 	if (xfrm_state_kern(x)) {
-		xfrm_state_put(x);
-		return -EPERM;
+		err = -EPERM;
+		goto out;
 	}
 
 	err = xfrm_state_delete(x);
-	if (err < 0) {
-		xfrm_state_put(x);
-		return err;
-	}
+	if (err < 0)
+		goto out;
 
 	c.seq = nlh->nlmsg_seq;
 	c.pid = nlh->nlmsg_pid;
 	c.event = nlh->nlmsg_type;
 	km_state_notify(x, &c);
-	xfrm_state_put(x);
 
+out:
+	xfrm_state_put(x);
 	return err;
 }
 
@@ -1055,6 +1057,8 @@ static int xfrm_get_policy(struct sk_buf
 					      MSG_DONTWAIT);
 		}
 	} else {
+		if (err = security_xfrm_policy_delete(xp))
+			goto out;
 		c.data.byid = p->index;
 		c.event = nlh->nlmsg_type;
 		c.seq = nlh->nlmsg_seq;
@@ -1064,6 +1068,7 @@ static int xfrm_get_policy(struct sk_buf
 
 	xfrm_pol_put(xp);
 
+out:
 	return err;
 }
 
diff -puN security/dummy.c~lsm-secpeer-fix security/dummy.c
--- linux-2.6.17-rc4-mm3/security/dummy.c~lsm-secpeer-fix	2006-05-31 00:02:04.000000000 -0400
+++ linux-2.6.17-rc4-mm3-cxzhang/security/dummy.c	2006-05-31 00:04:22.000000000 -0400
@@ -810,6 +810,11 @@ static void dummy_xfrm_policy_free_secur
 {
 }
 
+static int dummy_xfrm_policy_delete_security(struct xfrm_policy *xp)
+{
+	return 0;
+}
+
 static int dummy_xfrm_state_alloc_security(struct xfrm_state *x, struct xfrm_user_sec_ctx *sec_ctx)
 {
 	return 0;
@@ -819,6 +824,11 @@ static void dummy_xfrm_state_free_securi
 {
 }
 
+static int dummy_xfrm_state_delete_security(struct xfrm_state *x)
+{
+	return 0;
+}
+
 static int dummy_xfrm_policy_lookup(struct xfrm_policy *xp, u32 sk_sid, u8 dir)
 {
 	return 0;
@@ -1024,8 +1034,10 @@ void security_fixup_ops (struct security
 	set_to_dummy_if_null(ops, xfrm_policy_alloc_security);
 	set_to_dummy_if_null(ops, xfrm_policy_clone_security);
 	set_to_dummy_if_null(ops, xfrm_policy_free_security);
+	set_to_dummy_if_null(ops, xfrm_policy_delete_security);
 	set_to_dummy_if_null(ops, xfrm_state_alloc_security);
 	set_to_dummy_if_null(ops, xfrm_state_free_security);
+	set_to_dummy_if_null(ops, xfrm_state_delete_security);
 	set_to_dummy_if_null(ops, xfrm_policy_lookup);
 #endif	/* CONFIG_SECURITY_NETWORK_XFRM */
 #ifdef CONFIG_KEYS
diff -puN security/selinux/hooks.c~lsm-secpeer-fix security/selinux/hooks.c
--- linux-2.6.17-rc4-mm3/security/selinux/hooks.c~lsm-secpeer-fix	2006-05-31 00:02:11.000000000 -0400
+++ linux-2.6.17-rc4-mm3-cxzhang/security/selinux/hooks.c	2006-05-31 00:04:22.000000000 -0400
@@ -4400,8 +4400,10 @@ static struct security_operations selinu
 	.xfrm_policy_alloc_security =	selinux_xfrm_policy_alloc,
 	.xfrm_policy_clone_security =	selinux_xfrm_policy_clone,
 	.xfrm_policy_free_security =	selinux_xfrm_policy_free,
+	.xfrm_policy_delete_security =	selinux_xfrm_policy_delete,
 	.xfrm_state_alloc_security =	selinux_xfrm_state_alloc,
 	.xfrm_state_free_security =	selinux_xfrm_state_free,
+	.xfrm_state_delete_security =	selinux_xfrm_state_delete,
 	.xfrm_policy_lookup = 		selinux_xfrm_policy_lookup,
 #endif
 };
diff -puN security/selinux/include/xfrm.h~lsm-secpeer-fix security/selinux/include/xfrm.h
--- linux-2.6.17-rc4-mm3/security/selinux/include/xfrm.h~lsm-secpeer-fix	2006-05-31 00:02:19.000000000 -0400
+++ linux-2.6.17-rc4-mm3-cxzhang/security/selinux/include/xfrm.h	2006-05-31 00:04:22.000000000 -0400
@@ -9,8 +9,10 @@
 int selinux_xfrm_policy_alloc(struct xfrm_policy *xp, struct xfrm_user_sec_ctx *sec_ctx);
 int selinux_xfrm_policy_clone(struct xfrm_policy *old, struct xfrm_policy *new);
 void selinux_xfrm_policy_free(struct xfrm_policy *xp);
+int selinux_xfrm_policy_delete(struct xfrm_policy *xp);
 int selinux_xfrm_state_alloc(struct xfrm_state *x, struct xfrm_user_sec_ctx *sec_ctx);
 void selinux_xfrm_state_free(struct xfrm_state *x);
+int selinux_xfrm_state_delete(struct xfrm_state *x);
 int selinux_xfrm_policy_lookup(struct xfrm_policy *xp, u32 sk_sid, u8 dir);
 
 /*
diff -puN security/selinux/xfrm.c~lsm-secpeer-fix security/selinux/xfrm.c
--- linux-2.6.17-rc4-mm3/security/selinux/xfrm.c~lsm-secpeer-fix	2006-05-31 00:02:28.000000000 -0400
+++ linux-2.6.17-rc4-mm3-cxzhang/security/selinux/xfrm.c	2006-06-06 00:24:37.000000000 -0400
@@ -132,10 +132,7 @@ static int selinux_xfrm_sec_ctx_alloc(st
 		goto out;
 
 	/*
-	 * Does the subject have permission to set security or permission to
-	 * do the relabel?
-	 * Must be permitted to relabel from default socket type (process type)
-	 * to specified context
+	 * Does the subject have permission to set security context?
 	 */
 	rc = avc_has_perm(tsec->sid, ctx->ctx_sid,
 			  SECCLASS_ASSOCIATION,
@@ -201,6 +198,23 @@ void selinux_xfrm_policy_free(struct xfr
 }
 
 /*
+ * LSM hook implementation that authorizes deletion of labeled policies.
+ */
+int selinux_xfrm_policy_delete(struct xfrm_policy *xp)
+{
+	struct task_security_struct *tsec = current->security;
+	struct xfrm_sec_ctx *ctx = xp->security;
+	int rc = 0;
+
+	if (ctx)
+		rc = avc_has_perm(tsec->sid, ctx->ctx_sid,
+				  SECCLASS_ASSOCIATION,
+				  ASSOCIATION__SETCONTEXT, NULL);
+
+	return rc;
+}
+
+/*
  * LSM hook implementation that allocs and transfers sec_ctx spec to
  * xfrm_state.
  */
@@ -292,6 +306,23 @@ u32 selinux_socket_getpeer_dgram(struct 
 	return SECSID_NULL;
 }
 
+ /*
+  * LSM hook implementation that authorizes deletion of labeled SAs.
+  */
+int selinux_xfrm_state_delete(struct xfrm_state *x)
+{
+	struct task_security_struct *tsec = current->security;
+	struct xfrm_sec_ctx *ctx = x->security;
+	int rc = 0;
+
+	if (ctx)
+		rc = avc_has_perm(tsec->sid, ctx->ctx_sid,
+				  SECCLASS_ASSOCIATION,
+				  ASSOCIATION__SETCONTEXT, NULL);
+
+	return rc;
+}
+
 /*
  * LSM hook that controls access to unlabelled packets.  If
  * a xfrm_state is authorizable (defined by macro) then it was
_
