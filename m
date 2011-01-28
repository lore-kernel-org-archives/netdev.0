From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/3] ipv4: Attach FIB info to dst_default_metrics when
 possible
Date: Fri, 28 Jan 2011 14:35:06 -0800 (PST)
Message-ID: <20110128.143506.28811911.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47166
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753623Ab1A1Wea (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jan 2011 17:34:30 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 25F7724C089
	for <netdev@vger.kernel.org>; Fri, 28 Jan 2011 14:35:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


If there are no explicit metrics attached to a route, hook
fi->fib_info up to dst_default_metrics.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/dst.h        |    1 +
 net/core/dst.c           |    2 +-
 net/ipv4/fib_semantics.c |   12 ++++++++----
 3 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 94a8c23..484f80b 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -97,6 +97,7 @@ struct dst_entry {
 #ifdef __KERNEL__
 
 extern u32 *dst_cow_metrics_generic(struct dst_entry *dst, unsigned long old);
+extern const u32 dst_default_metrics[RTAX_MAX];
 
 #define DST_METRICS_READ_ONLY	0x1UL
 #define __DST_METRICS_PTR(Y)	\
diff --git a/net/core/dst.c b/net/core/dst.c
index 5788935..c1674fd 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -164,7 +164,7 @@ int dst_discard(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(dst_discard);
 
-static const u32 dst_default_metrics[RTAX_MAX];
+const u32 dst_default_metrics[RTAX_MAX];
 
 void *dst_alloc(struct dst_ops *ops)
 {
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 363ec39..48e93a5 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -152,7 +152,8 @@ static void free_fib_info_rcu(struct rcu_head *head)
 {
 	struct fib_info *fi = container_of(head, struct fib_info, rcu);
 
-	kfree(fi->fib_metrics);
+	if (fi->fib_metrics != (u32 *) dst_default_metrics)
+		kfree(fi->fib_metrics);
 	kfree(fi);
 }
 
@@ -743,9 +744,12 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 	fi = kzalloc(sizeof(*fi)+nhs*sizeof(struct fib_nh), GFP_KERNEL);
 	if (fi == NULL)
 		goto failure;
-	fi->fib_metrics = kzalloc(sizeof(u32) * RTAX_MAX, GFP_KERNEL);
-	if (!fi->fib_metrics)
-		goto failure;
+	if (cfg->fc_mx) {
+		fi->fib_metrics = kzalloc(sizeof(u32) * RTAX_MAX, GFP_KERNEL);
+		if (!fi->fib_metrics)
+			goto failure;
+	} else
+		fi->fib_metrics = (u32 *) dst_default_metrics;
 	fib_info_cnt++;
 
 	fi->fib_net = hold_net(net);
-- 
1.7.3.4

