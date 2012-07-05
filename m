From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] rtcache remove respin
Date: Thu, 05 Jul 2012 14:32:56 -0700 (PDT)
Message-ID: <20120705.143256.492701560070811001.davem@davemloft.net>
References: <1341225841.5269.69.camel@edumazet-glaptop>
	<20120705.031539.2275742387594459652.davem@davemloft.net>
	<1341515017.3265.6.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59280 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753808Ab2GEVc5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2012 17:32:57 -0400
In-Reply-To: <1341515017.3265.6.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 05 Jul 2012 21:03:37 +0200

> If route cache is removed, I believe we can remove all paddings.
> 
> Each tcp session will have its own dst_entry, instead of being shared.

Not really, the routing cache removal patches have poor performance
and won't go-in as-is. :-) Once PMTU/redirect/TCP-metrics are reworked
I plan to do things like the patch below to make the performance loss
more acceptable.

And then I'll do the same for input routes too, at which point your
'noref' case can be put back.

So really, we have to consider how to rework the layout of this
structure.

Thanks.

====================
ipv4: Cache output routes in fib_info nexthops.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip_fib.h     |    3 +++
 net/ipv4/fib_semantics.c |    2 ++
 net/ipv4/route.c         |    9 +++++++++
 3 files changed, 14 insertions(+)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 3dc7c96..ff9f0c4 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -45,6 +45,7 @@ struct fib_config {
  };
 
 struct fib_info;
+struct rtable;
 
 struct fib_nh {
 	struct net_device	*nh_dev;
@@ -63,6 +64,8 @@ struct fib_nh {
 	__be32			nh_gw;
 	__be32			nh_saddr;
 	int			nh_saddr_genid;
+
+	struct rtable		*rth;
 };
 
 /*
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index c46c20b..f3ada74 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -148,6 +148,8 @@ static void free_fib_info_rcu(struct rcu_head *head)
 	change_nexthops(fi) {
 		if (nexthop_nh->nh_dev)
 			dev_put(nexthop_nh->nh_dev);
+		if (nexthop_nh->rth)
+			dst_release(&nexthop_nh->rth->dst);
 	} endfor_nexthops(fi);
 
 	release_net(fi->fib_net);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 9f68f74..35bfd98 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -914,6 +914,8 @@ static void rt_set_nexthop(struct rtable *rt, const struct flowi4 *fl4,
 #ifdef CONFIG_IP_ROUTE_CLASSID
 		dst->tclassid = FIB_RES_NH(*res).nh_tclassid;
 #endif
+		FIB_RES_NH(*res).rth = rt;
+		dst_clone(&rt->dst);
 	}
 
 	if (dst_mtu(dst) > IP_MAX_MTU)
@@ -1399,6 +1401,13 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 			fi = NULL;
 	}
 
+	if (fi) {
+		rth = FIB_RES_NH(*res).rth;
+		if (rth) {
+			dst_use(&rth->dst, jiffies);
+			return rth;
+		}
+	}
 	rth = rt_dst_alloc(dev_out,
 			   IN_DEV_CONF_GET(in_dev, NOPOLICY),
 			   IN_DEV_CONF_GET(in_dev, NOXFRM));
-- 
1.7.10
