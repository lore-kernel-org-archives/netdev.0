From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/7] ipv4: Simplify output route creation call sequence.
Date: Thu, 17 Feb 2011 16:11:57 -0800 (PST)
Message-ID: <20110217.161157.02286288.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57115
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752840Ab1BRALV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 19:11:21 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 7890C24C087
	for <netdev@vger.kernel.org>; Thu, 17 Feb 2011 16:11:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


There's a lot of redundancy and unnecessary stack frames
in the output route creation path.

1) Make __mkroute_output() return error pointers.

2) Eliminate ip_mkroute_output() entirely, made possible by #1.

3) Call __mkroute_output() directly and handling the returning error
   pointers in ip_route_output_slow().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/route.c |   58 +++++++++++++++++++++--------------------------------
 1 files changed, 23 insertions(+), 35 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 756f544..849be48 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2323,33 +2323,32 @@ skip_cache:
 EXPORT_SYMBOL(ip_route_input_common);
 
 /* called with rcu_read_lock() */
-static int __mkroute_output(struct rtable **result,
-			    struct fib_result *res,
-			    const struct flowi *fl,
-			    const struct flowi *oldflp,
-			    struct net_device *dev_out,
-			    unsigned flags)
+static struct rtable *__mkroute_output(struct fib_result *res,
+				       const struct flowi *fl,
+				       const struct flowi *oldflp,
+				       struct net_device *dev_out,
+				       unsigned int flags)
 {
-	struct rtable *rth;
-	struct in_device *in_dev;
 	u32 tos = RT_FL_TOS(oldflp);
+	struct in_device *in_dev;
+	struct rtable *rth;
 
 	if (ipv4_is_loopback(fl->fl4_src) && !(dev_out->flags & IFF_LOOPBACK))
-		return -EINVAL;
+		return ERR_PTR(-EINVAL);
 
 	if (ipv4_is_lbcast(fl->fl4_dst))
 		res->type = RTN_BROADCAST;
 	else if (ipv4_is_multicast(fl->fl4_dst))
 		res->type = RTN_MULTICAST;
 	else if (ipv4_is_zeronet(fl->fl4_dst))
-		return -EINVAL;
+		return ERR_PTR(-EINVAL);
 
 	if (dev_out->flags & IFF_LOOPBACK)
 		flags |= RTCF_LOCAL;
 
 	in_dev = __in_dev_get_rcu(dev_out);
 	if (!in_dev)
-		return -EINVAL;
+		return ERR_PTR(-EINVAL);
 
 	if (res->type == RTN_BROADCAST) {
 		flags |= RTCF_BROADCAST | RTCF_LOCAL;
@@ -2370,7 +2369,7 @@ static int __mkroute_output(struct rtable **result,
 
 	rth = dst_alloc(&ipv4_dst_ops);
 	if (!rth)
-		return -ENOBUFS;
+		return ERR_PTR(-ENOBUFS);
 
 	atomic_set(&rth->dst.__refcnt, 1);
 	rth->dst.flags= DST_HOST;
@@ -2425,28 +2424,7 @@ static int __mkroute_output(struct rtable **result,
 	rt_set_nexthop(rth, res, 0);
 
 	rth->rt_flags = flags;
-	*result = rth;
-	return 0;
-}
-
-/* called with rcu_read_lock() */
-static int ip_mkroute_output(struct rtable **rp,
-			     struct fib_result *res,
-			     const struct flowi *fl,
-			     const struct flowi *oldflp,
-			     struct net_device *dev_out,
-			     unsigned flags)
-{
-	struct rtable *rth = NULL;
-	int err = __mkroute_output(&rth, res, fl, oldflp, dev_out, flags);
-	unsigned hash;
-	if (err == 0) {
-		hash = rt_hash(oldflp->fl4_dst, oldflp->fl4_src, oldflp->oif,
-			       rt_genid(dev_net(dev_out)));
-		err = rt_intern_hash(hash, rth, rp, NULL, oldflp->oif);
-	}
-
-	return err;
+	return rth;
 }
 
 /*
@@ -2469,6 +2447,7 @@ static int ip_route_output_slow(struct net *net, struct rtable **rp,
 	struct fib_result res;
 	unsigned int flags = 0;
 	struct net_device *dev_out = NULL;
+	struct rtable *rth;
 	int err;
 
 
@@ -2627,7 +2606,16 @@ static int ip_route_output_slow(struct net *net, struct rtable **rp,
 
 
 make_route:
-	err = ip_mkroute_output(rp, &res, &fl, oldflp, dev_out, flags);
+	rth = __mkroute_output(&res, &fl, oldflp, dev_out, flags);
+	if (IS_ERR(rth))
+		err = PTR_ERR(rth);
+	else {
+		unsigned int hash;
+
+		hash = rt_hash(oldflp->fl4_dst, oldflp->fl4_src, oldflp->oif,
+			       rt_genid(dev_net(dev_out)));
+		err = rt_intern_hash(hash, rth, rp, NULL, oldflp->oif);
+	}
 
 out:	return err;
 }
-- 
1.7.4.1

