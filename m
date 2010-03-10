From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next-2.6] bridge: ensure to unlock in error path in br_multicast_query().
Date: Thu, 11 Mar 2010 00:07:34 +0900
Message-ID: <201003101524.o2AFO75x027843@94.43.138.210.xn.2iij.net>
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:46981 "EHLO
	94.43.138.210.xn.2iij.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754024Ab0CJPZR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Mar 2010 10:25:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/bridge/br_multicast.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 2559fb5..2326a34 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -823,6 +823,7 @@ static int br_multicast_query(struct net_bridge *br,
 	unsigned long max_delay;
 	unsigned long now = jiffies;
 	__be32 group;
+	int err = 0;
 
 	spin_lock(&br->multicast_lock);
 	if (!netif_running(br->dev) ||
@@ -841,12 +842,14 @@ static int br_multicast_query(struct net_bridge *br,
 			group = 0;
 		}
 	} else {
-		if (!pskb_may_pull(skb, sizeof(struct igmpv3_query)))
-			return -EINVAL;
+		if (!pskb_may_pull(skb, sizeof(struct igmpv3_query))) {
+			err = -EINVAL;
+			goto out;
+		}
 
 		ih3 = igmpv3_query_hdr(skb);
 		if (ih3->nsrcs)
-			return 0;
+			goto out;
 
 		max_delay = ih3->code ? 1 :
 			    IGMPV3_MRC(ih3->code) * (HZ / IGMP_TIMER_SCALE);
@@ -876,7 +879,7 @@ static int br_multicast_query(struct net_bridge *br,
 
 out:
 	spin_unlock(&br->multicast_lock);
-	return 0;
+	return err;
 }
 
 static void br_multicast_leave_group(struct net_bridge *br,
-- 
1.5.6.5

