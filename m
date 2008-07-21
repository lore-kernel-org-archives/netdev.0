From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 6/6] ipv6: icmp6_dst_gc return change
Date: Mon, 21 Jul 2008 12:28:40 -0700
Message-ID: <20080721192920.399771703@vyatta.com>
References: <20080721192834.221648982@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:38870 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754344AbYGUTb2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2008 15:31:28 -0400
Content-Disposition: inline; filename=ipv6-icmp-dst.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change icmp6_dst_gc to return the one value the caller cares about rather
than using call by reference.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/include/net/ip6_route.h	2008-07-21 12:15:35.000000000 -0700
+++ b/include/net/ip6_route.h	2008-07-21 12:15:41.000000000 -0700
@@ -68,7 +68,7 @@ extern struct rt6_info		*rt6_lookup(stru
 extern struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 					 struct neighbour *neigh,
 					 const struct in6_addr *addr);
-extern int icmp6_dst_gc(int *more);
+extern int icmp6_dst_gc(void);
 
 extern void fib6_force_start_gc(struct net *net);
 
--- a/net/ipv6/ip6_fib.c	2008-07-21 12:13:41.000000000 -0700
+++ b/net/ipv6/ip6_fib.c	2008-07-21 12:14:35.000000000 -0700
@@ -1453,9 +1453,8 @@ void fib6_run_gc(unsigned long expires, 
 		}
 		gc_args.timeout = net->ipv6.sysctl.ip6_rt_gc_interval;
 	}
-	gc_args.more = 0;
 
-	icmp6_dst_gc(&gc_args.more);
+	gc_args.more = icmp6_dst_gc();
 
 	fib6_clean_all(net, fib6_age, 0, NULL);
 
--- a/net/ipv6/route.c	2008-07-21 12:14:06.000000000 -0700
+++ b/net/ipv6/route.c	2008-07-21 12:15:14.000000000 -0700
@@ -978,13 +978,12 @@ out:
 	return &rt->u.dst;
 }
 
-int icmp6_dst_gc(int *more)
+int icmp6_dst_gc(void)
 {
 	struct dst_entry *dst, *next, **pprev;
-	int freed;
+	int more = 0;
 
 	next = NULL;
-	freed = 0;
 
 	spin_lock_bh(&icmp6_dst_lock);
 	pprev = &icmp6_dst_gc_list;
@@ -993,16 +992,15 @@ int icmp6_dst_gc(int *more)
 		if (!atomic_read(&dst->__refcnt)) {
 			*pprev = dst->next;
 			dst_free(dst);
-			freed++;
 		} else {
 			pprev = &dst->next;
-			(*more)++;
+			++more;
 		}
 	}
 
 	spin_unlock_bh(&icmp6_dst_lock);
 
-	return freed;
+	return more;
 }
 
 static int ip6_dst_gc(struct dst_ops *ops)

-- 

