From: kaber@trash.net
Subject: [PATCH 17/28] netfilter: xt_quota: use per-rule spin lock
Date: Mon,  2 Aug 2010 21:57:34 +0200
Message-ID: <1280779065-9333-18-git-send-email-kaber@trash.net>
References: <1280779065-9333-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35364 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754711Ab0HBT6B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 15:58:01 -0400
In-Reply-To: <1280779065-9333-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>

Use per-rule spin lock to improve the scalability.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/xt_quota.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/xt_quota.c b/net/netfilter/xt_quota.c
index b4f7dfe..304b1fd 100644
--- a/net/netfilter/xt_quota.c
+++ b/net/netfilter/xt_quota.c
@@ -11,7 +11,8 @@
 #include <linux/netfilter/xt_quota.h>
 
 struct xt_quota_priv {
-	uint64_t quota;
+	spinlock_t	lock;
+	uint64_t	quota;
 };
 
 MODULE_LICENSE("GPL");
@@ -20,8 +21,6 @@ MODULE_DESCRIPTION("Xtables: countdown quota match");
 MODULE_ALIAS("ipt_quota");
 MODULE_ALIAS("ip6t_quota");
 
-static DEFINE_SPINLOCK(quota_lock);
-
 static bool
 quota_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
@@ -29,7 +28,7 @@ quota_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	struct xt_quota_priv *priv = q->master;
 	bool ret = q->flags & XT_QUOTA_INVERT;
 
-	spin_lock_bh(&quota_lock);
+	spin_lock_bh(&priv->lock);
 	if (priv->quota >= skb->len) {
 		priv->quota -= skb->len;
 		ret = !ret;
@@ -39,7 +38,7 @@ quota_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	}
 	/* Copy quota back to matchinfo so that iptables can display it */
 	q->quota = priv->quota;
-	spin_unlock_bh(&quota_lock);
+	spin_unlock_bh(&priv->lock);
 
 	return ret;
 }
@@ -55,6 +54,7 @@ static int quota_mt_check(const struct xt_mtchk_param *par)
 	if (q->master == NULL)
 		return -ENOMEM;
 
+	spin_lock_init(&q->master->lock);
 	q->master->quota = q->quota;
 	return 0;
 }
-- 
1.7.1

