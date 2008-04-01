From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/6] IPV4 : use xor rather than multiple ands for route compare
Date: Mon, 31 Mar 2008 17:47:11 -0700
Message-ID: <20080401004724.601457403@vyatta.com>
References: <20080401004708.009204033@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:40014 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755417AbYDACbf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2008 22:31:35 -0400
Content-Disposition: inline; filename=route-compare
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The comparison in ip_route_input is a hot path, by recoding the C
"and" as bit operations, fewer conditional branches get generated
so the code should be faster. Maybe someday Gcc will be smart
enough to do this?

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv4/route.c	2008-03-31 10:57:30.000000000 -0700
+++ b/net/ipv4/route.c	2008-03-31 11:10:44.000000000 -0700
@@ -2079,14 +2079,14 @@ int ip_route_input(struct sk_buff *skb, 
 	rcu_read_lock();
 	for (rth = rcu_dereference(rt_hash_table[hash].chain); rth;
 	     rth = rcu_dereference(rth->u.dst.rt_next)) {
-		if (rth->fl.fl4_dst == daddr &&
-		    rth->fl.fl4_src == saddr &&
-		    rth->fl.iif == iif &&
-		    rth->fl.oif == 0 &&
-		    rth->fl.mark == skb->mark &&
-		    rth->fl.fl4_tos == tos &&
-		    net_eq(dev_net(rth->u.dst.dev), net) &&
-		    rth->rt_genid == atomic_read(&rt_genid)) {
+		if (((rth->fl.fl4_dst ^ daddr) |
+		     (rth->fl.fl4_src ^ saddr) |
+		     (rth->fl.iif ^ iif) |
+		     rth->fl.oif |
+		     (rth->fl.mark ^ skb->mark) |
+		     (rth->fl.fl4_tos ^ tos) |
+		     (rth->rt_genid ^ atomic_read(&rt_genid))) == 0 &&
+		    net_eq(dev_net(rth->u.dst.dev), net)) {
 			dst_use(&rth->u.dst, jiffies);
 			RT_CACHE_STAT_INC(in_hit);
 			rcu_read_unlock();

-- 

