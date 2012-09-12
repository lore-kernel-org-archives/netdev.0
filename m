From: roy.qing.li@gmail.com
Subject: [PATCH v2] ipv6: replace write lock with read lock when get route info
Date: Wed, 12 Sep 2012 15:59:01 +0800
Message-ID: <1347436741-344-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:38603 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751308Ab2ILH7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2012 03:59:07 -0400
Received: by pbbrr13 with SMTP id rr13so1904153pbb.19
        for <netdev@vger.kernel.org>; Wed, 12 Sep 2012 00:59:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

geting route info does not write rt->rt6i_table, so replace
write lock with read lock

Suggested-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv6/addrconf.c |    4 ++--
 net/ipv6/route.c    |    8 ++++----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 1237d5d..061c100 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1706,7 +1706,7 @@ static struct rt6_info *addrconf_get_prefix_route(const struct in6_addr *pfx,
 	if (table == NULL)
 		return NULL;
 
-	write_lock_bh(&table->tb6_lock);
+	read_lock_bh(&table->tb6_lock);
 	fn = fib6_locate(&table->tb6_root, pfx, plen, NULL, 0);
 	if (!fn)
 		goto out;
@@ -1721,7 +1721,7 @@ static struct rt6_info *addrconf_get_prefix_route(const struct in6_addr *pfx,
 		break;
 	}
 out:
-	write_unlock_bh(&table->tb6_lock);
+	read_unlock_bh(&table->tb6_lock);
 	return rt;
 }
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 399613b..8be1d86 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1837,7 +1837,7 @@ static struct rt6_info *rt6_get_route_info(struct net *net,
 	if (!table)
 		return NULL;
 
-	write_lock_bh(&table->tb6_lock);
+	read_lock_bh(&table->tb6_lock);
 	fn = fib6_locate(&table->tb6_root, prefix ,prefixlen, NULL, 0);
 	if (!fn)
 		goto out;
@@ -1853,7 +1853,7 @@ static struct rt6_info *rt6_get_route_info(struct net *net,
 		break;
 	}
 out:
-	write_unlock_bh(&table->tb6_lock);
+	read_unlock_bh(&table->tb6_lock);
 	return rt;
 }
 
@@ -1896,7 +1896,7 @@ struct rt6_info *rt6_get_dflt_router(const struct in6_addr *addr, struct net_dev
 	if (!table)
 		return NULL;
 
-	write_lock_bh(&table->tb6_lock);
+	read_lock_bh(&table->tb6_lock);
 	for (rt = table->tb6_root.leaf; rt; rt=rt->dst.rt6_next) {
 		if (dev == rt->dst.dev &&
 		    ((rt->rt6i_flags & (RTF_ADDRCONF | RTF_DEFAULT)) == (RTF_ADDRCONF | RTF_DEFAULT)) &&
@@ -1905,7 +1905,7 @@ struct rt6_info *rt6_get_dflt_router(const struct in6_addr *addr, struct net_dev
 	}
 	if (rt)
 		dst_hold(&rt->dst);
-	write_unlock_bh(&table->tb6_lock);
+	read_unlock_bh(&table->tb6_lock);
 	return rt;
 }
 
-- 
1.7.4.1
