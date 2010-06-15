From: kaber@trash.net
Subject: [PATCH 04/17] netfilter: xt_rateest: Better struct xt_rateest layout
Date: Tue, 15 Jun 2010 17:38:30 +0200
Message-ID: <1276616323-20880-5-git-send-email-kaber@trash.net>
References: <1276616323-20880-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1276616323-20880-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>

We currently dirty two cache lines in struct xt_rateest, this hurts SMP
performance.

This patch moves lock/bstats/rstats at beginning of structure so that
they share a single cache line.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/netfilter/xt_rateest.h |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/include/net/netfilter/xt_rateest.h b/include/net/netfilter/xt_rateest.h
index ddbf37e..b1d780e 100644
--- a/include/net/netfilter/xt_rateest.h
+++ b/include/net/netfilter/xt_rateest.h
@@ -2,13 +2,17 @@
 #define _XT_RATEEST_H
 
 struct xt_rateest {
+	/* keep lock and bstats on same cache line to speedup xt_rateest_tg() */
+	struct gnet_stats_basic_packed	bstats;
+	spinlock_t			lock;
+	/* keep rstats and lock on same cache line to speedup xt_rateest_mt() */
+	struct gnet_stats_rate_est	rstats;
+
+	/* following fields not accessed in hot path */
 	struct hlist_node		list;
 	char				name[IFNAMSIZ];
 	unsigned int			refcnt;
-	spinlock_t			lock;
 	struct gnet_estimator		params;
-	struct gnet_stats_rate_est	rstats;
-	struct gnet_stats_basic_packed	bstats;
 };
 
 extern struct xt_rateest *xt_rateest_lookup(const char *name);
-- 
1.7.0.4

