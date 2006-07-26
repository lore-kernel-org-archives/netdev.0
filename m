From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/5] [IPV6]: Remove ndiscs rt6_lock dependency
Date: Thu, 27 Jul 2006 00:00:01 +0200
Message-ID: <20060726221849.188750063@postel.suug.ch>
References: <20060726221100.325687073@postel.suug.ch>
Cc: vnuorval@tcs.hut.fi, usagi-core@linux-ipv6.org,
	yoshfuji@linux-ipv6.org, davem@davemloft.net, anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:19894 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751234AbWGZWUB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 18:20:01 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=ip6_mrt_ndisc_lock
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Ab)using rt6_lock wouldn't work anymore if rt6_lock is
converted into a per table lock.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.git/net/ipv6/route.c
===================================================================
--- net-2.6.git.orig/net/ipv6/route.c
+++ net-2.6.git/net/ipv6/route.c
@@ -745,8 +745,6 @@ static void ip6_rt_update_pmtu(struct ds
 	}
 }
 
-/* Protected by rt6_lock.  */
-static struct dst_entry *ndisc_dst_gc_list;
 static int ipv6_get_mtu(struct net_device *dev);
 
 static inline unsigned int ipv6_advmss(unsigned int mtu)
@@ -767,6 +765,9 @@ static inline unsigned int ipv6_advmss(u
 	return mtu;
 }
 
+static struct dst_entry *ndisc_dst_gc_list;
+DEFINE_SPINLOCK(ndisc_lock);
+
 struct dst_entry *ndisc_dst_alloc(struct net_device *dev, 
 				  struct neighbour *neigh,
 				  struct in6_addr *addr,
@@ -807,10 +808,10 @@ struct dst_entry *ndisc_dst_alloc(struct
 	rt->rt6i_dst.plen = 128;
 #endif
 
-	write_lock_bh(&rt6_lock);
+	spin_lock_bh(&ndisc_lock);
 	rt->u.dst.next = ndisc_dst_gc_list;
 	ndisc_dst_gc_list = &rt->u.dst;
-	write_unlock_bh(&rt6_lock);
+	spin_unlock_bh(&ndisc_lock);
 
 	fib6_force_start_gc();
 
@@ -824,8 +825,11 @@ int ndisc_dst_gc(int *more)
 	int freed;
 
 	next = NULL;
+ 	freed = 0;
+
+	spin_lock_bh(&ndisc_lock);
 	pprev = &ndisc_dst_gc_list;
-	freed = 0;
+
 	while ((dst = *pprev) != NULL) {
 		if (!atomic_read(&dst->__refcnt)) {
 			*pprev = dst->next;
@@ -837,6 +841,8 @@ int ndisc_dst_gc(int *more)
 		}
 	}
 
+	spin_unlock_bh(&ndisc_lock);
+
 	return freed;
 }
 

