From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/5] ipv4: Pass explicit saddr/daddr args to
 ipmr_get_route().
Date: Wed, 04 May 2011 13:19:39 -0700 (PDT)
Message-ID: <20110504.131939.179929254.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60205
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755506Ab1EDUUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 16:20:12 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 14AFF24C088
	for <netdev@vger.kernel.org>; Wed,  4 May 2011 13:19:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This eliminates the need to use rt->rt_{src,dst}.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/mroute.h |    1 +
 net/ipv4/ipmr.c        |   16 ++++++++--------
 net/ipv4/route.c       |    4 +++-
 3 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/include/linux/mroute.h b/include/linux/mroute.h
index b21d567..46caaf4 100644
--- a/include/linux/mroute.h
+++ b/include/linux/mroute.h
@@ -244,6 +244,7 @@ struct mfc_cache {
 #ifdef __KERNEL__
 struct rtmsg;
 extern int ipmr_get_route(struct net *net, struct sk_buff *skb,
+			  __be32 saddr, __be32 daddr,
 			  struct rtmsg *rtm, int nowait);
 #endif
 
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 86033b7..30a7763 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -2041,20 +2041,20 @@ rtattr_failure:
 	return -EMSGSIZE;
 }
 
-int ipmr_get_route(struct net *net,
-		   struct sk_buff *skb, struct rtmsg *rtm, int nowait)
+int ipmr_get_route(struct net *net, struct sk_buff *skb,
+		   __be32 saddr, __be32 daddr,
+		   struct rtmsg *rtm, int nowait)
 {
-	int err;
-	struct mr_table *mrt;
 	struct mfc_cache *cache;
-	struct rtable *rt = skb_rtable(skb);
+	struct mr_table *mrt;
+	int err;
 
 	mrt = ipmr_get_table(net, RT_TABLE_DEFAULT);
 	if (mrt == NULL)
 		return -ENOENT;
 
 	rcu_read_lock();
-	cache = ipmr_cache_find(mrt, rt->rt_src, rt->rt_dst);
+	cache = ipmr_cache_find(mrt, saddr, daddr);
 
 	if (cache == NULL) {
 		struct sk_buff *skb2;
@@ -2087,8 +2087,8 @@ int ipmr_get_route(struct net *net,
 		skb_reset_network_header(skb2);
 		iph = ip_hdr(skb2);
 		iph->ihl = sizeof(struct iphdr) >> 2;
-		iph->saddr = rt->rt_src;
-		iph->daddr = rt->rt_dst;
+		iph->saddr = saddr;
+		iph->daddr = daddr;
 		iph->version = 0;
 		err = ipmr_cache_unresolved(mrt, vif, skb2);
 		read_unlock(&mrt_lock);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 3bc6854..6a83840 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2857,7 +2857,9 @@ static int rt_fill_info(struct net *net,
 
 		if (ipv4_is_multicast(dst) && !ipv4_is_local_multicast(dst) &&
 		    IPV4_DEVCONF_ALL(net, MC_FORWARDING)) {
-			int err = ipmr_get_route(net, skb, r, nowait);
+			int err = ipmr_get_route(net, skb,
+						 rt->rt_src, rt->rt_dst,
+						 r, nowait);
 			if (err <= 0) {
 				if (!nowait) {
 					if (err == 0)
-- 
1.7.4.5

