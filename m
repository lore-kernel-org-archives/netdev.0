From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net 1/2] xfrm: add rcu grace period in xfrm_policy_destroy()
Date: Tue,  8 Dec 2015 07:22:01 -0800
Message-ID: <1449588122-13941-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33851 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756123AbbLHPWH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 10:22:07 -0500
Received: by pacwq6 with SMTP id wq6so13436758pac.1
        for <netdev@vger.kernel.org>; Tue, 08 Dec 2015 07:22:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We will soon switch sk->sk_policy[] to RCU protection,
as SYNACK packets are sent while listener socket is not locked.

This patch simply adds RCU grace period before struct xfrm_policy
freeing, and the corresponding rcu_head in struct xfrm_policy.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/xfrm.h     |  1 +
 net/xfrm/xfrm_policy.c | 11 +++++++++--
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 4a9c21f9b4ea..8bae1ef647cd 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -548,6 +548,7 @@ struct xfrm_policy {
 	u16			family;
 	struct xfrm_sec_ctx	*security;
 	struct xfrm_tmpl       	xfrm_vec[XFRM_MAX_DEPTH];
+	struct rcu_head		rcu;
 };
 
 static inline struct net *xp_net(const struct xfrm_policy *xp)
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 18276f0cc32b..f57a5712cedd 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -303,6 +303,14 @@ struct xfrm_policy *xfrm_policy_alloc(struct net *net, gfp_t gfp)
 }
 EXPORT_SYMBOL(xfrm_policy_alloc);
 
+static void xfrm_policy_destroy_rcu(struct rcu_head *head)
+{
+	struct xfrm_policy *policy = container_of(head, struct xfrm_policy, rcu);
+
+	security_xfrm_policy_free(policy->security);
+	kfree(policy);
+}
+
 /* Destroy xfrm_policy: descendant resources must be released to this moment. */
 
 void xfrm_policy_destroy(struct xfrm_policy *policy)
@@ -312,8 +320,7 @@ void xfrm_policy_destroy(struct xfrm_policy *policy)
 	if (del_timer(&policy->timer) || del_timer(&policy->polq.hold_timer))
 		BUG();
 
-	security_xfrm_policy_free(policy->security);
-	kfree(policy);
+	call_rcu(&policy->rcu, xfrm_policy_destroy_rcu);
 }
 EXPORT_SYMBOL(xfrm_policy_destroy);
 
-- 
2.6.0.rc2.230.g3dd15c0
