From: David Miller <davem@davemloft.net>
Subject: [DANGER 8/7]: ipv4: Cache output routes in fib_info nexthops.
Date: Thu, 12 Jul 2012 10:47:58 -0700 (PDT)
Message-ID: <20120712.104758.253504708560401123.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58808 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932762Ab2GLRr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 13:47:59 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 1849F58351A
	for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 10:48:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---

If you really feel like playing with fire, try this patch
on top of the routing cache removal patches.

It gets the output route lookup down to 888 cycles for me.

Something is flaky about it, when I ssh into my test system
for the first time after a boot there is a strange delay of
some sort.  It's as if the SYN-ACK is dropped on the way out
of the test machine, and my desktop has to retry the initial
SYN.  I plan to investigate this after some sleep.

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index e91fedd..d133110 100644
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
index d71bfbd..d1240a0 100644
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
index c4b2df6..53b006a 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -983,6 +983,8 @@ static void rt_set_nexthop(struct rtable *rt, const struct flowi4 *fl4,
 #ifdef CONFIG_IP_ROUTE_CLASSID
 		rt->dst.tclassid = FIB_RES_NH(*res).nh_tclassid;
 #endif
+		FIB_RES_NH(*res).rth = rt;
+		dst_clone(&rt->dst);
 	}
 
 #ifdef CONFIG_IP_ROUTE_CLASSID
@@ -1468,6 +1470,13 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
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
