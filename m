From: Wei Wang <tracywwnj@gmail.com>
Subject: [PATCH net-next 14/21] ipv6: get rid of icmp6 dst garbage collector
Date: Fri, 16 Jun 2017 10:47:37 -0700
Message-ID: <20170616174744.139688-15-tracywwnj@gmail.com>
References: <20170616174744.139688-1-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35381 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752548AbdFPRsc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 13:48:32 -0400
Received: by mail-pg0-f67.google.com with SMTP id f127so7263792pgc.2
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 10:48:32 -0700 (PDT)
In-Reply-To: <20170616174744.139688-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

icmp6 dst route is currently ref counted during creation and will be
freed by user during its call of dst_release(). So no need of a garbage
collector for it.
Remove all icmp6 dst garbage collector related code.

Signed-off-by: Wei Wang <weiwan@google.com>
Acked-by: Martin KaFai Lau <kafai@fb.com>
---
 include/net/ip6_route.h |  1 -
 net/ipv6/ip6_fib.c      |  3 +--
 net/ipv6/route.c        | 46 ----------------------------------------------
 3 files changed, 1 insertion(+), 49 deletions(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index f3da9dd2a8db..0fbf73dd531a 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -116,7 +116,6 @@ struct rt6_info *rt6_lookup(struct net *net, const struct in6_addr *daddr,
 			    const struct in6_addr *saddr, int oif, int flags);
 
 struct dst_entry *icmp6_dst_alloc(struct net_device *dev, struct flowi6 *fl6);
-int icmp6_dst_gc(void);
 
 void fib6_force_start_gc(struct net *net);
 
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index e3b35e146eef..c67ec79bf0da 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1822,8 +1822,7 @@ void fib6_run_gc(unsigned long expires, struct net *net, bool force)
 	}
 	gc_args.timeout = expires ? (int)expires :
 			  net->ipv6.sysctl.ip6_rt_gc_interval;
-
-	gc_args.more = icmp6_dst_gc();
+	gc_args.more = 0;
 
 	fib6_clean_all(net, fib6_age, &gc_args);
 	now = jiffies;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 5f859ee67172..c88044b8fa7c 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1657,9 +1657,6 @@ static unsigned int ip6_mtu(const struct dst_entry *dst)
 	return mtu - lwtunnel_headroom(dst->lwtstate, mtu);
 }
 
-static struct dst_entry *icmp6_dst_gc_list;
-static DEFINE_SPINLOCK(icmp6_dst_lock);
-
 struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 				  struct flowi6 *fl6)
 {
@@ -1697,48 +1694,6 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 	return dst;
 }
 
-int icmp6_dst_gc(void)
-{
-	struct dst_entry *dst, **pprev;
-	int more = 0;
-
-	spin_lock_bh(&icmp6_dst_lock);
-	pprev = &icmp6_dst_gc_list;
-
-	while ((dst = *pprev) != NULL) {
-		if (!atomic_read(&dst->__refcnt)) {
-			*pprev = dst->next;
-			dst_free(dst);
-		} else {
-			pprev = &dst->next;
-			++more;
-		}
-	}
-
-	spin_unlock_bh(&icmp6_dst_lock);
-
-	return more;
-}
-
-static void icmp6_clean_all(int (*func)(struct rt6_info *rt, void *arg),
-			    void *arg)
-{
-	struct dst_entry *dst, **pprev;
-
-	spin_lock_bh(&icmp6_dst_lock);
-	pprev = &icmp6_dst_gc_list;
-	while ((dst = *pprev) != NULL) {
-		struct rt6_info *rt = (struct rt6_info *) dst;
-		if (func(rt, arg)) {
-			*pprev = dst->next;
-			dst_free(dst);
-		} else {
-			pprev = &dst->next;
-		}
-	}
-	spin_unlock_bh(&icmp6_dst_lock);
-}
-
 static int ip6_dst_gc(struct dst_ops *ops)
 {
 	struct net *net = container_of(ops, struct net, ipv6.ip6_dst_ops);
@@ -2856,7 +2811,6 @@ void rt6_ifdown(struct net *net, struct net_device *dev)
 	};
 
 	fib6_clean_all(net, fib6_ifdown, &adn);
-	icmp6_clean_all(fib6_ifdown, &adn);
 	if (dev)
 		rt6_uncached_list_flush_dev(net, dev);
 }
-- 
2.13.1.518.g3df882009-goog
