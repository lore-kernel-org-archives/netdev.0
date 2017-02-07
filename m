From: Florian Westphal <fw@strlen.de>
Subject: [PATCH ipsec-next 2/6] xfrm: policy: xfrm_policy_unregister_afinfo can return void
Date: Tue,  7 Feb 2017 15:00:15 +0100
Message-ID: <20170207140019.20269-3-fw@strlen.de>
References: <20170207140019.20269-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:56638 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754435AbdBGOCD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 09:02:03 -0500
In-Reply-To: <20170207140019.20269-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nothing checks the return value. Also, the errors returned on unregister
are impossible (we only support INET and INET6, so no way
xfrm_policy_afinfo[afinfo->family] can be anything other than 'afinfo'
itself).

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/xfrm.h     |  2 +-
 net/xfrm/xfrm_policy.c | 35 +++++++++++++----------------------
 2 files changed, 14 insertions(+), 23 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index da0e4dd653e2..39037b1cce7a 100644
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
index 6fffa2fac607..794148f76ae2 100644
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
2.10.2
