From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/3] ipv4: Allocate fib metrics dynamically.
Date: Fri, 28 Jan 2011 14:35:03 -0800 (PST)
Message-ID: <20110128.143503.246531914.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47163
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753489Ab1A1We2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jan 2011 17:34:28 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id B0B6924C089
	for <netdev@vger.kernel.org>; Fri, 28 Jan 2011 14:35:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is the initial gateway towards super-sharing metrics
if they are all set to zero for a route.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip_fib.h     |    2 +-
 net/ipv4/fib_semantics.c |    4 ++++
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 65d1fcd..2c0508a 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -77,7 +77,7 @@ struct fib_info {
 	int			fib_protocol;
 	__be32			fib_prefsrc;
 	u32			fib_priority;
-	u32			fib_metrics[RTAX_MAX];
+	u32			*fib_metrics;
 #define fib_mtu fib_metrics[RTAX_MTU-1]
 #define fib_window fib_metrics[RTAX_WINDOW-1]
 #define fib_rtt fib_metrics[RTAX_RTT-1]
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 9aff11d7..363ec39 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -152,6 +152,7 @@ static void free_fib_info_rcu(struct rcu_head *head)
 {
 	struct fib_info *fi = container_of(head, struct fib_info, rcu);
 
+	kfree(fi->fib_metrics);
 	kfree(fi);
 }
 
@@ -742,6 +743,9 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 	fi = kzalloc(sizeof(*fi)+nhs*sizeof(struct fib_nh), GFP_KERNEL);
 	if (fi == NULL)
 		goto failure;
+	fi->fib_metrics = kzalloc(sizeof(u32) * RTAX_MAX, GFP_KERNEL);
+	if (!fi->fib_metrics)
+		goto failure;
 	fib_info_cnt++;
 
 	fi->fib_net = hold_net(net);
-- 
1.7.3.4

