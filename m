From: Paul Moore <pmoore@redhat.com>
Subject: [PATCH v3 2/2] selinux: fix the labeled xfrm/IPsec reference count
 handling
Date: Wed, 29 May 2013 13:36:32 -0400
Message-ID: <20130529173632.31888.39884.stgit@localhost>
References: <20130529173336.31888.29695.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: omoris@redhat.com, pwouters@redhat.com
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23093 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932934Ab3E2Rge (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 May 2013 13:36:34 -0400
In-Reply-To: <20130529173336.31888.29695.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SELinux labeled IPsec code was improperly handling its reference
counting, dropping a reference on a delete operation instead of on a
free/release operation.

Reported-by: Ondrej Moris <omoris@redhat.com>
Signed-off-by: Paul Moore <pmoore@redhat.com>
---
 security/selinux/xfrm.c |   34 ++++++++++++++--------------------
 1 file changed, 14 insertions(+), 20 deletions(-)

diff --git a/security/selinux/xfrm.c b/security/selinux/xfrm.c
index 8ab2951..d030818 100644
--- a/security/selinux/xfrm.c
+++ b/security/selinux/xfrm.c
@@ -316,6 +316,7 @@ int selinux_xfrm_policy_clone(struct xfrm_sec_ctx *old_ctx,
 
 		memcpy(new_ctx, old_ctx, sizeof(*new_ctx));
 		memcpy(new_ctx->ctx_str, old_ctx->ctx_str, new_ctx->ctx_len);
+		atomic_inc(&selinux_xfrm_refcount);
 		*new_ctxp = new_ctx;
 	}
 	return 0;
@@ -326,6 +327,7 @@ int selinux_xfrm_policy_clone(struct xfrm_sec_ctx *old_ctx,
  */
 void selinux_xfrm_policy_free(struct xfrm_sec_ctx *ctx)
 {
+	atomic_dec(&selinux_xfrm_refcount);
 	kfree(ctx);
 }
 
@@ -335,17 +337,13 @@ void selinux_xfrm_policy_free(struct xfrm_sec_ctx *ctx)
 int selinux_xfrm_policy_delete(struct xfrm_sec_ctx *ctx)
 {
 	const struct task_security_struct *tsec = current_security();
-	int rc = 0;
 
-	if (ctx) {
-		rc = avc_has_perm(tsec->sid, ctx->ctx_sid,
-				  SECCLASS_ASSOCIATION,
-				  ASSOCIATION__SETCONTEXT, NULL);
-		if (rc == 0)
-			atomic_dec(&selinux_xfrm_refcount);
-	}
+	if (!ctx)
+		return 0;
 
-	return rc;
+	return avc_has_perm(tsec->sid, ctx->ctx_sid,
+			    SECCLASS_ASSOCIATION, ASSOCIATION__SETCONTEXT,
+			    NULL);
 }
 
 /*
@@ -370,8 +368,8 @@ int selinux_xfrm_state_alloc(struct xfrm_state *x, struct xfrm_user_sec_ctx *uct
  */
 void selinux_xfrm_state_free(struct xfrm_state *x)
 {
-	struct xfrm_sec_ctx *ctx = x->security;
-	kfree(ctx);
+	atomic_dec(&selinux_xfrm_refcount);
+	kfree(x->security);
 }
 
  /*
@@ -381,17 +379,13 @@ int selinux_xfrm_state_delete(struct xfrm_state *x)
 {
 	const struct task_security_struct *tsec = current_security();
 	struct xfrm_sec_ctx *ctx = x->security;
-	int rc = 0;
 
-	if (ctx) {
-		rc = avc_has_perm(tsec->sid, ctx->ctx_sid,
-				  SECCLASS_ASSOCIATION,
-				  ASSOCIATION__SETCONTEXT, NULL);
-		if (rc == 0)
-			atomic_dec(&selinux_xfrm_refcount);
-	}
+	if (!ctx)
+		return 0;
 
-	return rc;
+	return avc_has_perm(tsec->sid, ctx->ctx_sid,
+			    SECCLASS_ASSOCIATION, ASSOCIATION__SETCONTEXT,
+			    NULL);
 }
 
 /*
