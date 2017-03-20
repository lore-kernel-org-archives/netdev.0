From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 14/22] netfilter: limit: use per-rule spinlock to improve the scalability
Date: Mon, 20 Mar 2017 11:08:42 +0100
Message-ID: <1490004530-9128-15-git-send-email-pablo@netfilter.org>
References: <1490004530-9128-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52146 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753915AbdCTKJp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Mar 2017 06:09:45 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id EDC01523FF
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:09:13 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id DCFC2DA877
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:09:13 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id A3E14DA87B
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:09:11 +0100 (CET)
In-Reply-To: <1490004530-9128-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <zlpnobody@gmail.com>

The limit token is independent between each rules, so there's no
need to use a global spinlock.

Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_limit.c | 10 +++++-----
 net/netfilter/xt_limit.c  | 11 ++++++-----
 2 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/net/netfilter/nft_limit.c b/net/netfilter/nft_limit.c
index c6baf412236d..18dd57a52651 100644
--- a/net/netfilter/nft_limit.c
+++ b/net/netfilter/nft_limit.c
@@ -17,9 +17,8 @@
 #include <linux/netfilter/nf_tables.h>
 #include <net/netfilter/nf_tables.h>
 
-static DEFINE_SPINLOCK(limit_lock);
-
 struct nft_limit {
+	spinlock_t	lock;
 	u64		last;
 	u64		tokens;
 	u64		tokens_max;
@@ -34,7 +33,7 @@ static inline bool nft_limit_eval(struct nft_limit *limit, u64 cost)
 	u64 now, tokens;
 	s64 delta;
 
-	spin_lock_bh(&limit_lock);
+	spin_lock_bh(&limit->lock);
 	now = ktime_get_ns();
 	tokens = limit->tokens + now - limit->last;
 	if (tokens > limit->tokens_max)
@@ -44,11 +43,11 @@ static inline bool nft_limit_eval(struct nft_limit *limit, u64 cost)
 	delta = tokens - cost;
 	if (delta >= 0) {
 		limit->tokens = delta;
-		spin_unlock_bh(&limit_lock);
+		spin_unlock_bh(&limit->lock);
 		return limit->invert;
 	}
 	limit->tokens = tokens;
-	spin_unlock_bh(&limit_lock);
+	spin_unlock_bh(&limit->lock);
 	return !limit->invert;
 }
 
@@ -86,6 +85,7 @@ static int nft_limit_init(struct nft_limit *limit,
 			limit->invert = true;
 	}
 	limit->last = ktime_get_ns();
+	spin_lock_init(&limit->lock);
 
 	return 0;
 }
diff --git a/net/netfilter/xt_limit.c b/net/netfilter/xt_limit.c
index dab962df1787..d27b5f1ea619 100644
--- a/net/netfilter/xt_limit.c
+++ b/net/netfilter/xt_limit.c
@@ -18,6 +18,7 @@
 #include <linux/netfilter/xt_limit.h>
 
 struct xt_limit_priv {
+	spinlock_t lock;
 	unsigned long prev;
 	uint32_t credit;
 };
@@ -32,8 +33,6 @@ MODULE_ALIAS("ip6t_limit");
  * see net/sched/sch_tbf.c in the linux source tree
  */
 
-static DEFINE_SPINLOCK(limit_lock);
-
 /* Rusty: This is my (non-mathematically-inclined) understanding of
    this algorithm.  The `average rate' in jiffies becomes your initial
    amount of credit `credit' and the most credit you can ever have
@@ -72,7 +71,7 @@ limit_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	struct xt_limit_priv *priv = r->master;
 	unsigned long now = jiffies;
 
-	spin_lock_bh(&limit_lock);
+	spin_lock_bh(&priv->lock);
 	priv->credit += (now - xchg(&priv->prev, now)) * CREDITS_PER_JIFFY;
 	if (priv->credit > r->credit_cap)
 		priv->credit = r->credit_cap;
@@ -80,11 +79,11 @@ limit_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	if (priv->credit >= r->cost) {
 		/* We're not limited. */
 		priv->credit -= r->cost;
-		spin_unlock_bh(&limit_lock);
+		spin_unlock_bh(&priv->lock);
 		return true;
 	}
 
-	spin_unlock_bh(&limit_lock);
+	spin_unlock_bh(&priv->lock);
 	return false;
 }
 
@@ -126,6 +125,8 @@ static int limit_mt_check(const struct xt_mtchk_param *par)
 		r->credit_cap = priv->credit; /* Credits full. */
 		r->cost = user2credits(r->avg);
 	}
+	spin_lock_init(&priv->lock);
+
 	return 0;
 }
 
-- 
2.1.4
