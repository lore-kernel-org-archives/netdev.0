From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] xt_quota: use per-rule spin lock
Date: Fri, 23 Jul 2010 12:07:33 +0800
Message-ID: <1279858053-14732-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:58178 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750778Ab0GWEH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 00:07:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

xt_quota: use per-rule spin lock

use per-rule spin lock to improve the scalability.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/netfilter/xt_quota.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)
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
