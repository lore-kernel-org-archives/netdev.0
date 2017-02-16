From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 03/13] xfrm: policy: xfrm_policy_unregister_afinfo can return void
Date: Thu, 16 Feb 2017 13:18:37 +0100
Message-ID: <1487247527-17925-4-git-send-email-steffen.klassert@secunet.com>
References: <1487247527-17925-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:49322 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754672AbdBPMS6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Feb 2017 07:18:58 -0500
In-Reply-To: <1487247527-17925-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Nothing checks the return value. Also, the errors returned on unregister
are impossible (we only support INET and INET6, so no way
xfrm_policy_afinfo[afinfo->family] can be anything other than 'afinfo'
itself).

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h     |  2 +-
 net/xfrm/xfrm_policy.c | 35 +++++++++++++----------------------
 2 files changed, 14 insertions(+), 23 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index da0e4dd..39037b1 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -304,7 +304,7 @@ struct xfrm_policy_afinfo {
 };
 
 int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo);
-int xfrm_policy_unregister_afinfo(struct xfrm_policy_afinfo *afinfo);
+void xfrm_policy_unregister_afinfo(struct xfrm_policy_afinfo *afinfo);
 void km_policy_notify(struct xfrm_policy *xp, int dir,
 		      const struct km_event *c);
 void km_state_notify(struct xfrm_state *x, const struct km_event *c);
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 6fffa2f..794148f7 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2883,34 +2883,25 @@ int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo)
 }
 EXPORT_SYMBOL(xfrm_policy_register_afinfo);
 
-int xfrm_policy_unregister_afinfo(struct xfrm_policy_afinfo *afinfo)
+void xfrm_policy_unregister_afinfo(struct xfrm_policy_afinfo *afinfo)
 {
-	int err = 0;
-	if (unlikely(afinfo == NULL))
-		return -EINVAL;
+	struct dst_ops *dst_ops = afinfo->dst_ops;
+
 	if (unlikely(afinfo->family >= NPROTO))
-		return -EAFNOSUPPORT;
-	spin_lock(&xfrm_policy_afinfo_lock);
-	if (likely(xfrm_policy_afinfo[afinfo->family] != NULL)) {
-		if (unlikely(xfrm_policy_afinfo[afinfo->family] != afinfo))
-			err = -EINVAL;
-		else
-			RCU_INIT_POINTER(xfrm_policy_afinfo[afinfo->family],
+		return;
+
+	if (likely(xfrm_policy_afinfo[afinfo->family] != afinfo)) {
+		RCU_INIT_POINTER(xfrm_policy_afinfo[afinfo->family],
 					 NULL);
 	}
-	spin_unlock(&xfrm_policy_afinfo_lock);
-	if (!err) {
-		struct dst_ops *dst_ops = afinfo->dst_ops;
 
-		synchronize_rcu();
+	synchronize_rcu();
 
-		dst_ops->kmem_cachep = NULL;
-		dst_ops->check = NULL;
-		dst_ops->negative_advice = NULL;
-		dst_ops->link_failure = NULL;
-		afinfo->garbage_collect = NULL;
-	}
-	return err;
+	dst_ops->kmem_cachep = NULL;
+	dst_ops->check = NULL;
+	dst_ops->negative_advice = NULL;
+	dst_ops->link_failure = NULL;
+	afinfo->garbage_collect = NULL;
 }
 EXPORT_SYMBOL(xfrm_policy_unregister_afinfo);
 
-- 
1.9.1
