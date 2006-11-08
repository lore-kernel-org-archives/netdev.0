From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [PATCH 1/3] labeled-ipsec: Various fixes
Date: Wed, 08 Nov 2006 17:03:44 -0600
Message-ID: <45526250.2030206@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, jmorris@namei.org, sds@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:25497 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1423881AbWKHXEI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Nov 2006 18:04:08 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since the upstreaming of the mlsxfrm modification a few months back,
testing has resulted in the identification of the following issues/bugs that
are resolved in this patch set.

1. Fix the security context used in the IKE negotiation to be the context
   of the socket as opposed to the context of the SPD rule.

2. Fix SO_PEERSEC for tcp sockets to return the security context of
   the peer as opposed to the source.

3. Fix the selection of an SA for an outgoing packet to be at the same
   context as the originating socket/flow.

The following would be the result of applying this patchset:

- SO_PEERSEC will now correctly return the peer's context.

- IKE deamons will receive the context of the source socket/flow
  as opposed to the SPD rule's context so that the negotiated SA
  will be at the same context as the source socket/flow.

- The SELinux policy will require one or more of the
  following for a socket to be able to communicate with/without SAs:

  1. To enable a socket to communicate without using labeled-IPSec SAs:

     allow socket_t unlabeled_t:association { sendto recvfrom }

  2. To enable a socket to communicate with labeled-IPSec SAs:

     allow socket_t self:association { sendto };
     allow socket_t peer_sa_t:association { recvfrom };


This Patch: Pass correct security context to IKE for use in negotiation

Fix the security context passed to IKE for use in negotiation to be the
context of the socket as opposed to the context of the SPD rule so that
the SA carries the label of the originating socket/flow.

Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
---
 include/linux/security.h        |   21 ++++++++----------
 security/dummy.c                |    4 +--
 security/selinux/include/xfrm.h |    4 +--
 security/selinux/xfrm.c         |   35 +++++++-----------------------
 4 files changed, 23 insertions(+), 41 deletions(-)

diff --git a/include/linux/security.h b/include/linux/security.h
index b200b98..a509329 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -836,10 +836,8 @@ #ifdef CONFIG_SECURITY
  *	used by the XFRM system.
  *	@sec_ctx contains the security context information being provided by
  *	the user-level policy update program (e.g., setkey).
- *	@sk refers to the sock from which to derive the security context.
  *	Allocate a security structure to the xp->security field; the security
- *	field is initialized to NULL when the xfrm_policy is allocated. Only
- *	one of sec_ctx or sock can be specified.
+ *	field is initialized to NULL when the xfrm_policy is allocated.
  *	Return 0 if operation was successful (memory to allocate, legal context)
  * @xfrm_policy_clone_security:
  *	@old contains an existing xfrm_policy in the SPD.
@@ -858,9 +856,6 @@ #ifdef CONFIG_SECURITY
  *	Database by the XFRM system.
  *	@sec_ctx contains the security context information being provided by
  *	the user-level SA generation program (e.g., setkey or racoon).
- *	@polsec contains the security context information associated with a xfrm
- *	policy rule from which to take the base context. polsec must be NULL
- *	when sec_ctx is specified.
  *	@secid contains the secid from which to take the mls portion of the context.
  *	Allocate a security structure to the x->security field; the security
  *	field is initialized to NULL when the xfrm_state is allocated. Set the
@@ -1378,12 +1373,12 @@ #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
 	int (*xfrm_policy_alloc_security) (struct xfrm_policy *xp,
-			struct xfrm_user_sec_ctx *sec_ctx, struct sock *sk);
+			struct xfrm_user_sec_ctx *sec_ctx);
 	int (*xfrm_policy_clone_security) (struct xfrm_policy *old, struct xfrm_policy *new);
 	void (*xfrm_policy_free_security) (struct xfrm_policy *xp);
 	int (*xfrm_policy_delete_security) (struct xfrm_policy *xp);
 	int (*xfrm_state_alloc_security) (struct xfrm_state *x,
-		struct xfrm_user_sec_ctx *sec_ctx, struct xfrm_sec_ctx *polsec,
+		struct xfrm_user_sec_ctx *sec_ctx,
 		u32 secid);
 	void (*xfrm_state_free_security) (struct xfrm_state *x);
 	int (*xfrm_state_delete_security) (struct xfrm_state *x);
@@ -3120,7 +3115,7 @@ #endif	/* CONFIG_SECURITY_NETWORK */
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
 static inline int security_xfrm_policy_alloc(struct xfrm_policy *xp, struct xfrm_user_sec_ctx *sec_ctx)
 {
-	return security_ops->xfrm_policy_alloc_security(xp, sec_ctx, NULL);
+	return security_ops->xfrm_policy_alloc_security(xp, sec_ctx);
 }
 
 static inline int security_xfrm_policy_clone(struct xfrm_policy *old, struct xfrm_policy *new)
@@ -3141,7 +3136,7 @@ static inline int security_xfrm_policy_d
 static inline int security_xfrm_state_alloc(struct xfrm_state *x,
 			struct xfrm_user_sec_ctx *sec_ctx)
 {
-	return security_ops->xfrm_state_alloc_security(x, sec_ctx, NULL, 0);
+	return security_ops->xfrm_state_alloc_security(x, sec_ctx, 0);
 }
 
 static inline int security_xfrm_state_alloc_acquire(struct xfrm_state *x,
@@ -3149,7 +3144,11 @@ static inline int security_xfrm_state_al
 {
 	if (!polsec)
 		return 0;
-	return security_ops->xfrm_state_alloc_security(x, NULL, polsec, secid);
+	/*
+	 * We want the context to be taken from secid which is usually
+	 * from the sock.
+	 */
+	return security_ops->xfrm_state_alloc_security(x, NULL, secid);
 }
 
 static inline int security_xfrm_state_delete(struct xfrm_state *x)
diff --git a/security/dummy.c b/security/dummy.c
index 43874c1..838d844 100644
--- a/security/dummy.c
+++ b/security/dummy.c
@@ -836,7 +836,7 @@ #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
 static int dummy_xfrm_policy_alloc_security(struct xfrm_policy *xp,
-		struct xfrm_user_sec_ctx *sec_ctx, struct sock *sk)
+		struct xfrm_user_sec_ctx *sec_ctx)
 {
 	return 0;
 }
@@ -856,7 +856,7 @@ static int dummy_xfrm_policy_delete_secu
 }
 
 static int dummy_xfrm_state_alloc_security(struct xfrm_state *x,
-	struct xfrm_user_sec_ctx *sec_ctx, struct xfrm_sec_ctx *pol, u32 secid)
+	struct xfrm_user_sec_ctx *sec_ctx, u32 secid)
 {
 	return 0;
 }
diff --git a/security/selinux/include/xfrm.h b/security/selinux/include/xfrm.h
index 526b280..8e329dd 100644
--- a/security/selinux/include/xfrm.h
+++ b/security/selinux/include/xfrm.h
@@ -8,12 +8,12 @@ #ifndef _SELINUX_XFRM_H_
 #define _SELINUX_XFRM_H_
 
 int selinux_xfrm_policy_alloc(struct xfrm_policy *xp,
-		struct xfrm_user_sec_ctx *sec_ctx, struct sock *sk);
+		struct xfrm_user_sec_ctx *sec_ctx);
 int selinux_xfrm_policy_clone(struct xfrm_policy *old, struct xfrm_policy *new);
 void selinux_xfrm_policy_free(struct xfrm_policy *xp);
 int selinux_xfrm_policy_delete(struct xfrm_policy *xp);
 int selinux_xfrm_state_alloc(struct xfrm_state *x,
-	struct xfrm_user_sec_ctx *sec_ctx, struct xfrm_sec_ctx *pol, u32 secid);
+	struct xfrm_user_sec_ctx *sec_ctx, u32 secid);
 void selinux_xfrm_state_free(struct xfrm_state *x);
 int selinux_xfrm_state_delete(struct xfrm_state *x);
 int selinux_xfrm_policy_lookup(struct xfrm_policy *xp, u32 fl_secid, u8 dir);
diff --git a/security/selinux/xfrm.c b/security/selinux/xfrm.c
index 675b995..4d5a043 100644
--- a/security/selinux/xfrm.c
+++ b/security/selinux/xfrm.c
@@ -226,16 +226,15 @@ int selinux_xfrm_decode_session(struct s
  * CTX does not have a meaningful value on input
  */
 static int selinux_xfrm_sec_ctx_alloc(struct xfrm_sec_ctx **ctxp,
-	struct xfrm_user_sec_ctx *uctx, struct xfrm_sec_ctx *pol, u32 sid)
+	struct xfrm_user_sec_ctx *uctx, u32 sid)
 {
 	int rc = 0;
 	struct task_security_struct *tsec = current->security;
 	struct xfrm_sec_ctx *ctx = NULL;
 	char *ctx_str = NULL;
 	u32 str_len;
-	u32 ctx_sid;
 
-	BUG_ON(uctx && pol);
+	BUG_ON(uctx && sid);
 
 	if (!uctx)
 		goto not_from_user;
@@ -279,15 +278,7 @@ static int selinux_xfrm_sec_ctx_alloc(st
 	return rc;
 
 not_from_user:
-	if (pol) {
-		rc = security_sid_mls_copy(pol->ctx_sid, sid, &ctx_sid);
-		if (rc)
-			goto out;
-	}
-	else
-		ctx_sid = sid;
-
-	rc = security_sid_to_context(ctx_sid, &ctx_str, &str_len);
+	rc = security_sid_to_context(sid, &ctx_str, &str_len);
 	if (rc)
 		goto out;
 
@@ -302,7 +293,7 @@ not_from_user:
 
 	ctx->ctx_doi = XFRM_SC_DOI_LSM;
 	ctx->ctx_alg = XFRM_SC_ALG_SELINUX;
-	ctx->ctx_sid = ctx_sid;
+	ctx->ctx_sid = sid;
 	ctx->ctx_len = str_len;
 	memcpy(ctx->ctx_str,
 	       ctx_str,
@@ -323,22 +314,14 @@ out2:
  * xfrm_policy.
  */
 int selinux_xfrm_policy_alloc(struct xfrm_policy *xp,
-		struct xfrm_user_sec_ctx *uctx, struct sock *sk)
+		struct xfrm_user_sec_ctx *uctx)
 {
 	int err;
-	u32 sid;
 
 	BUG_ON(!xp);
-	BUG_ON(uctx && sk);
-
-	if (sk) {
-		struct sk_security_struct *ssec = sk->sk_security;
-		sid = ssec->sid;
-	}
-	else
-		sid = SECSID_NULL;
+	BUG_ON(!uctx);
 
-	err = selinux_xfrm_sec_ctx_alloc(&xp->security, uctx, NULL, sid);
+	err = selinux_xfrm_sec_ctx_alloc(&xp->security, uctx, 0);
 	return err;
 }
 
@@ -399,13 +382,13 @@ int selinux_xfrm_policy_delete(struct xf
  * xfrm_state.
  */
 int selinux_xfrm_state_alloc(struct xfrm_state *x, struct xfrm_user_sec_ctx *uctx,
-		struct xfrm_sec_ctx *pol, u32 secid)
+		u32 secid)
 {
 	int err;
 
 	BUG_ON(!x);
 
-	err = selinux_xfrm_sec_ctx_alloc(&x->security, uctx, pol, secid);
+	err = selinux_xfrm_sec_ctx_alloc(&x->security, uctx, secid);
 	return err;
 }
 
