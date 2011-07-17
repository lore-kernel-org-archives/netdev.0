From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/5] net: Create and use new helper, neigh_output().
Date: Sun, 17 Jul 2011 12:30:07 -0700 (PDT)
Message-ID: <20110717.123007.1736899942069308447.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38795 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754797Ab1GQTaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jul 2011 15:30:08 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p6HJU79s028580
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Sun, 17 Jul 2011 12:30:07 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/neighbour.h |    9 +++++++++
 net/ipv4/ip_output.c    |   10 +++-------
 net/ipv6/ip6_output.c   |   10 +++-------
 3 files changed, 15 insertions(+), 14 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index bd8f9f0..337da24 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -344,6 +344,15 @@ static inline int neigh_hh_output(struct hh_cache *hh, struct sk_buff *skb)
 	return hh->hh_output(skb);
 }
 
+static inline int neigh_output(struct neighbour *n, struct sk_buff *skb)
+{
+	struct hh_cache *hh = &n->hh;
+	if (hh->hh_len)
+		return neigh_hh_output(hh, skb);
+	else
+		return n->output(skb);
+}
+
 static inline struct neighbour *
 __neigh_lookup(struct neigh_table *tbl, const void *pkey, struct net_device *dev, int creat)
 {
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 1ac674a..db296a9 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -205,13 +205,9 @@ static inline int ip_finish_output2(struct sk_buff *skb)
 	}
 
 	neigh = dst->neighbour;
-	if (neigh) {
-		struct hh_cache *hh = &neigh->hh;
-		if (hh->hh_len)
-			return neigh_hh_output(hh, skb);
-		else
-			return neigh->output(skb);
-	}
+	if (neigh)
+		return neigh_output(neigh, skb);
+
 	if (net_ratelimit())
 		printk(KERN_DEBUG "ip_finish_output2: No header cache and no neighbour!\n");
 	kfree_skb(skb);
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 36362e9..eb50bb0 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -136,13 +136,9 @@ static int ip6_finish_output2(struct sk_buff *skb)
 	}
 
 	neigh = dst->neighbour;
-	if (neigh) {
-		struct hh_cache *hh = &neigh->hh;
-		if (hh->hh_len)
-			return neigh_hh_output(hh, skb);
-		else
-			return neigh->output(skb);
-	}
+	if (neigh)
+		return neigh_output(neigh, skb);
+
 	IP6_INC_STATS_BH(dev_net(dst->dev),
 			 ip6_dst_idev(dst), IPSTATS_MIB_OUTNOROUTES);
 	kfree_skb(skb);
-- 
1.7.6

