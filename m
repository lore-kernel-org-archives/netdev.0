From: WANG Cong <xiyou.wangcong@gmail.com>
Subject: [Patch] xfrm_policy_destroy: rename and relative fixes
Date: Thu, 3 Jan 2008 20:05:50 +0800
Message-ID: <20080103120550.GB2498@hacking>
Reply-To: WANG Cong <xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from po-out-1718.google.com ([72.14.252.155]:29201 "EHLO
	po-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752813AbYACMFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2008 07:05:55 -0500
Received: by po-out-1718.google.com with SMTP id c31so4682169poi.1
        for <netdev@vger.kernel.org>; Thu, 03 Jan 2008 04:05:55 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Since __xfrm_policy_destroy is used to destory the resources
allocated by xfrm_policy_alloc. So using the name
__xfrm_policy_destroy is not correspond with xfrm_policy_alloc.
Rename it to xfrm_policy_destroy.

And along with some instances that call xfrm_policy_alloc
but not using xfrm_policy_destroy to destroy the resource,
fix them.

Cc: David Miller <davem@davemloft.net>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: WANG Cong <xiyou.wangcong@gmail.com>

---

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 58dfa82..6eff085 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -505,12 +505,12 @@ static inline void xfrm_pol_hold(struct xfrm_policy *policy)
 		atomic_inc(&policy->refcnt);
 }
 
-extern void __xfrm_policy_destroy(struct xfrm_policy *policy);
+extern void xfrm_policy_destroy(struct xfrm_policy *policy);
 
 static inline void xfrm_pol_put(struct xfrm_policy *policy)
 {
 	if (atomic_dec_and_test(&policy->refcnt))
-		__xfrm_policy_destroy(policy);
+		xfrm_policy_destroy(policy);
 }
 
 #ifdef CONFIG_XFRM_SUB_POLICY
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 26d5e63..3667f44 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -2291,8 +2291,7 @@ static int pfkey_spdadd(struct sock *sk, struct sk_buff *skb, struct sadb_msg *h
 	return 0;
 
 out:
-	security_xfrm_policy_free(xp);
-	kfree(xp);
+	xfrm_policy_destroy(xp);
 	return err;
 }
 
@@ -3236,8 +3235,7 @@ static struct xfrm_policy *pfkey_compile_policy(struct sock *sk, int opt,
 	return xp;
 
 out:
-	security_xfrm_policy_free(xp);
-	kfree(xp);
+	xfrm_policy_destroy(xp);
 	return NULL;
 }
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 26b846e..087484e 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -206,7 +206,7 @@ EXPORT_SYMBOL(xfrm_policy_alloc);
 
 /* Destroy xfrm_policy: descendant resources must be released to this moment. */
 
-void __xfrm_policy_destroy(struct xfrm_policy *policy)
+void xfrm_policy_destroy(struct xfrm_policy *policy)
 {
 	BUG_ON(!policy->dead);
 
@@ -218,7 +218,7 @@ void __xfrm_policy_destroy(struct xfrm_policy *policy)
 	security_xfrm_policy_free(policy);
 	kfree(policy);
 }
-EXPORT_SYMBOL(__xfrm_policy_destroy);
+EXPORT_SYMBOL(xfrm_policy_destroy);
 
 static void xfrm_policy_gc_kill(struct xfrm_policy *policy)
 {
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index e75dbdc..73cc755 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1048,7 +1048,7 @@ static struct xfrm_policy *xfrm_policy_construct(struct xfrm_userpolicy_info *p,
 	return xp;
  error:
 	*errp = err;
-	kfree(xp);
+	xfrm_policy_destroy(xp);
 	return NULL;
 }
 
