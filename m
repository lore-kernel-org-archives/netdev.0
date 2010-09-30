From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next 2/2] ipv4: rcu conversion in ip_route_output_slow
Date: Thu, 30 Sep 2010 15:33:58 +0200
Message-ID: <1285853638.2615.520.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:42193 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752279Ab0I3NeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 09:34:04 -0400
Received: by fxm4 with SMTP id 4so680823fxm.19
        for <netdev@vger.kernel.org>; Thu, 30 Sep 2010 06:34:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip_route_output_slow() is enclosed in an rcu_read_lock() protected
section, so that no references are taken/released on device, thanks to
__ip_dev_find() & dev_get_by_index_rcu()

Tested with ip route cache disabled, and a stress test :

Before patch:

elapsed time :

real	1m38.347s
user	0m11.909s
sys	23m51.501s

Profile:

13788.00 22.7% ip_route_output_slow [kernel]
 7875.00 13.0% dst_destroy          [kernel]
 3925.00  6.5% fib_semantic_match   [kernel]
 3144.00  5.2% fib_rules_lookup     [kernel]
 3061.00  5.0% dst_alloc            [kernel]
 2276.00  3.7% rt_set_nexthop       [kernel]
 1762.00  2.9% fib_table_lookup     [kernel]
 1538.00  2.5% _raw_read_lock       [kernel]
 1358.00  2.2% ip_output            [kernel]

After patch:

real	1m28.808s
user	0m13.245s
sys	20m37.293s


10950.00 17.2% ip_route_output_slow [kernel]
10726.00 16.9% dst_destroy          [kernel]
 5170.00  8.1% fib_semantic_match   [kernel]
 3937.00  6.2% dst_alloc            [kernel]
 3635.00  5.7% rt_set_nexthop       [kernel]
 2900.00  4.6% fib_rules_lookup     [kernel]
 2240.00  3.5% fib_table_lookup     [kernel]
 1427.00  2.2% _raw_read_lock       [kernel]
 1157.00  1.8% kmem_cache_alloc     [kernel]

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/route.c |   38 ++++++++++++--------------------------
 1 files changed, 12 insertions(+), 26 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 98beda4..9b60129 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2490,6 +2490,7 @@ static int ip_mkroute_output(struct rtable **rp,
 
 /*
  * Major route resolver routine.
+ * called with rcu_read_lock();
  */
 
 static int ip_route_output_slow(struct net *net, struct rtable **rp,
@@ -2508,7 +2509,7 @@ static int ip_route_output_slow(struct net *net, struct rtable **rp,
 			    .iif = net->loopback_dev->ifindex,
 			    .oif = oldflp->oif };
 	struct fib_result res;
-	unsigned flags = 0;
+	unsigned int flags = 0;
 	struct net_device *dev_out = NULL;
 	int free_res = 0;
 	int err;
@@ -2538,7 +2539,7 @@ static int ip_route_output_slow(struct net *net, struct rtable **rp,
 		    (ipv4_is_multicast(oldflp->fl4_dst) ||
 		     oldflp->fl4_dst == htonl(0xFFFFFFFF))) {
 			/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
-			dev_out = ip_dev_find(net, oldflp->fl4_src);
+			dev_out = __ip_dev_find(net, oldflp->fl4_src, false);
 			if (dev_out == NULL)
 				goto out;
 
@@ -2563,26 +2564,21 @@ static int ip_route_output_slow(struct net *net, struct rtable **rp,
 
 		if (!(oldflp->flags & FLOWI_FLAG_ANYSRC)) {
 			/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
-			dev_out = ip_dev_find(net, oldflp->fl4_src);
-			if (dev_out == NULL)
+			if (!__ip_dev_find(net, oldflp->fl4_src, false))
 				goto out;
-			dev_put(dev_out);
-			dev_out = NULL;
 		}
 	}
 
 
 	if (oldflp->oif) {
-		dev_out = dev_get_by_index(net, oldflp->oif);
+		dev_out = dev_get_by_index_rcu(net, oldflp->oif);
 		err = -ENODEV;
 		if (dev_out == NULL)
 			goto out;
 
 		/* RACE: Check return value of inet_select_addr instead. */
-		if (rcu_dereference_raw(dev_out->ip_ptr) == NULL) {
-			dev_put(dev_out);
+		if (rcu_dereference(dev_out->ip_ptr) == NULL)
 			goto out;	/* Wrong error code */
-		}
 
 		if (ipv4_is_local_multicast(oldflp->fl4_dst) ||
 		    oldflp->fl4_dst == htonl(0xFFFFFFFF)) {
@@ -2605,10 +2601,7 @@ static int ip_route_output_slow(struct net *net, struct rtable **rp,
 		fl.fl4_dst = fl.fl4_src;
 		if (!fl.fl4_dst)
 			fl.fl4_dst = fl.fl4_src = htonl(INADDR_LOOPBACK);
-		if (dev_out)
-			dev_put(dev_out);
 		dev_out = net->loopback_dev;
-		dev_hold(dev_out);
 		fl.oif = net->loopback_dev->ifindex;
 		res.type = RTN_LOCAL;
 		flags |= RTCF_LOCAL;
@@ -2642,8 +2635,6 @@ static int ip_route_output_slow(struct net *net, struct rtable **rp,
 			res.type = RTN_UNICAST;
 			goto make_route;
 		}
-		if (dev_out)
-			dev_put(dev_out);
 		err = -ENETUNREACH;
 		goto out;
 	}
@@ -2652,10 +2643,7 @@ static int ip_route_output_slow(struct net *net, struct rtable **rp,
 	if (res.type == RTN_LOCAL) {
 		if (!fl.fl4_src)
 			fl.fl4_src = fl.fl4_dst;
-		if (dev_out)
-			dev_put(dev_out);
 		dev_out = net->loopback_dev;
-		dev_hold(dev_out);
 		fl.oif = dev_out->ifindex;
 		if (res.fi)
 			fib_info_put(res.fi);
@@ -2675,28 +2663,23 @@ static int ip_route_output_slow(struct net *net, struct rtable **rp,
 	if (!fl.fl4_src)
 		fl.fl4_src = FIB_RES_PREFSRC(res);
 
-	if (dev_out)
-		dev_put(dev_out);
 	dev_out = FIB_RES_DEV(res);
-	dev_hold(dev_out);
 	fl.oif = dev_out->ifindex;
 
 
 make_route:
 	err = ip_mkroute_output(rp, &res, &fl, oldflp, dev_out, flags);
 
-
 	if (free_res)
 		fib_res_put(&res);
-	if (dev_out)
-		dev_put(dev_out);
 out:	return err;
 }
 
 int __ip_route_output_key(struct net *net, struct rtable **rp,
 			  const struct flowi *flp)
 {
-	unsigned hash;
+	unsigned int hash;
+	int res;
 	struct rtable *rth;
 
 	if (!rt_caching(net))
@@ -2727,7 +2710,10 @@ int __ip_route_output_key(struct net *net, struct rtable **rp,
 	rcu_read_unlock_bh();
 
 slow_output:
-	return ip_route_output_slow(net, rp, flp);
+	rcu_read_lock();
+	res = ip_route_output_slow(net, rp, flp);
+	rcu_read_unlock();
+	return res;
 }
 EXPORT_SYMBOL_GPL(__ip_route_output_key);
 


