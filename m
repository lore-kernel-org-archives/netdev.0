From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/3] ipv4: Always invalidate or update the route on pmtu
 events
Date: Mon, 8 Oct 2012 10:47:25 +0200
Message-ID: <20121008084725.GC15622@secunet.com>
References: <20121008084642.GB15622@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:46765 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753383Ab2JHIrb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Oct 2012 04:47:31 -0400
Content-Disposition: inline
In-Reply-To: <20121008084642.GB15622@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some protocols, like IPsec still cache routes. So we need to invalidate
the old route on pmtu events to avoid the reuse of stale routes.
We also need to update the mtu and expire time of the route if we already
use a nh exeption route, otherwise we ignore newly learned pmtu values
after the first expiration.

With this patch we always invalidate or update the route on pmtu events.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/route.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index ff62206..90ba835 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -904,22 +904,29 @@ out:	kfree_skb(skb);
 	return 0;
 }
 
-static u32 __ip_rt_update_pmtu(struct rtable *rt, struct flowi4 *fl4, u32 mtu)
+static void __ip_rt_update_pmtu(struct rtable *rt, struct flowi4 *fl4, u32 mtu)
 {
+	struct dst_entry *dst = &rt->dst;
 	struct fib_result res;
 
 	if (mtu < ip_rt_min_pmtu)
 		mtu = ip_rt_min_pmtu;
 
+	if (!rt->rt_pmtu) {
+		dst->obsolete = DST_OBSOLETE_KILL;
+	} else {
+		rt->rt_pmtu = mtu;
+		dst->expires = max(1UL, jiffies + ip_rt_mtu_expires);
+	}
+
 	rcu_read_lock();
-	if (fib_lookup(dev_net(rt->dst.dev), fl4, &res) == 0) {
+	if (fib_lookup(dev_net(dst->dev), fl4, &res) == 0) {
 		struct fib_nh *nh = &FIB_RES_NH(res);
 
 		update_or_create_fnhe(nh, fl4->daddr, 0, mtu,
 				      jiffies + ip_rt_mtu_expires);
 	}
 	rcu_read_unlock();
-	return mtu;
 }
 
 static void ip_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
@@ -929,14 +936,7 @@ static void ip_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
 	struct flowi4 fl4;
 
 	ip_rt_build_flow_key(&fl4, sk, skb);
-	mtu = __ip_rt_update_pmtu(rt, &fl4, mtu);
-
-	if (!rt->rt_pmtu) {
-		dst->obsolete = DST_OBSOLETE_KILL;
-	} else {
-		rt->rt_pmtu = mtu;
-		rt->dst.expires = max(1UL, jiffies + ip_rt_mtu_expires);
-	}
+	__ip_rt_update_pmtu(rt, &fl4, mtu);
 }
 
 void ipv4_update_pmtu(struct sk_buff *skb, struct net *net, u32 mtu,
-- 
1.7.0.4
