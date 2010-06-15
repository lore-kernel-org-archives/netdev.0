From: kaber@trash.net
Subject: [PATCH 02/17] netfilter: xt_statistic: remove nth_lock spinlock
Date: Tue, 15 Jun 2010 17:38:28 +0200
Message-ID: <1276616323-20880-3-git-send-email-kaber@trash.net>
References: <1276616323-20880-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42167 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757671Ab0FOP3x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 11:29:53 -0400
In-Reply-To: <1276616323-20880-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>

Use atomic_cmpxchg() to avoid dirtying a shared location.

xt_statistic_priv smp aligned to avoid sharing same cache line with
other stuff.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/xt_statistic.c |   19 +++++++++----------
 1 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/net/netfilter/xt_statistic.c b/net/netfilter/xt_statistic.c
index 96e62b8..42ecb71 100644
--- a/net/netfilter/xt_statistic.c
+++ b/net/netfilter/xt_statistic.c
@@ -18,8 +18,8 @@
 #include <linux/netfilter/x_tables.h>
 
 struct xt_statistic_priv {
-	uint32_t count;
-};
+	atomic_t count;
+} ____cacheline_aligned_in_smp;
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
@@ -27,13 +27,12 @@ MODULE_DESCRIPTION("Xtables: statistics-based matching (\"Nth\", random)");
 MODULE_ALIAS("ipt_statistic");
 MODULE_ALIAS("ip6t_statistic");
 
-static DEFINE_SPINLOCK(nth_lock);
-
 static bool
 statistic_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_statistic_info *info = par->matchinfo;
 	bool ret = info->flags & XT_STATISTIC_INVERT;
+	int nval, oval;
 
 	switch (info->mode) {
 	case XT_STATISTIC_MODE_RANDOM:
@@ -41,12 +40,12 @@ statistic_mt(const struct sk_buff *skb, struct xt_action_param *par)
 			ret = !ret;
 		break;
 	case XT_STATISTIC_MODE_NTH:
-		spin_lock_bh(&nth_lock);
-		if (info->master->count++ == info->u.nth.every) {
-			info->master->count = 0;
+		do {
+			oval = atomic_read(&info->master->count);
+			nval = (oval == info->u.nth.every) ? 0 : oval + 1;
+		} while (atomic_cmpxchg(&info->master->count, oval, nval) != oval);
+		if (nval == 0)
 			ret = !ret;
-		}
-		spin_unlock_bh(&nth_lock);
 		break;
 	}
 
@@ -64,7 +63,7 @@ static int statistic_mt_check(const struct xt_mtchk_param *par)
 	info->master = kzalloc(sizeof(*info->master), GFP_KERNEL);
 	if (info->master == NULL)
 		return -ENOMEM;
-	info->master->count = info->u.nth.count;
+	atomic_set(&info->master->count, info->u.nth.count);
 
 	return 0;
 }
-- 
1.7.0.4

