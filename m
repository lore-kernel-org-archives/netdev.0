From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] ipv6: probe routes asynchronous in rt6_probe
Date: Mon, 21 Oct 2013 06:17:15 +0200
Message-ID: <20131021041715.GH27787@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: ja@ssi.bg
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:47292 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082Ab3JUERQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 00:17:16 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Routes need to be probed asynchronous otherwise the call stack gets
exhausted when the kernel attemps to deliver another skb inline, like
e.g. xt_TEE does, and we probe at the same time.

We update neigh->updated still at once, otherwise we would send to
many probes.

Cc: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/route.c | 38 +++++++++++++++++++++++++++++++-------
 1 file changed, 31 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c3130ff..38c9418 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -476,6 +476,24 @@ out:
 }
 
 #ifdef CONFIG_IPV6_ROUTER_PREF
+struct __rt6_probe_work {
+	struct work_struct work;
+	struct in6_addr target;
+	struct net_device *dev;
+};
+
+static void rt6_probe_deferred(struct work_struct *w)
+{
+	struct in6_addr mcaddr;
+	struct __rt6_probe_work *work =
+		container_of(w, struct __rt6_probe_work, work);
+
+	addrconf_addr_solict_mult(&work->target, &mcaddr);
+	ndisc_send_ns(work->dev, NULL, &work->target, &mcaddr, NULL);
+	dev_put(work->dev);
+	kfree(w);
+}
+
 static void rt6_probe(struct rt6_info *rt)
 {
 	struct neighbour *neigh;
@@ -499,17 +517,23 @@ static void rt6_probe(struct rt6_info *rt)
 
 	if (!neigh ||
 	    time_after(jiffies, neigh->updated + rt->rt6i_idev->cnf.rtr_probe_interval)) {
-		struct in6_addr mcaddr;
-		struct in6_addr *target;
+		struct __rt6_probe_work *work;
+
+		work = kmalloc(sizeof(*work), GFP_ATOMIC);
 
-		if (neigh) {
+		if (neigh && work)
 			neigh->updated = jiffies;
+
+		if (neigh)
 			write_unlock(&neigh->lock);
-		}
 
-		target = (struct in6_addr *)&rt->rt6i_gateway;
-		addrconf_addr_solict_mult(target, &mcaddr);
-		ndisc_send_ns(rt->dst.dev, NULL, target, &mcaddr, NULL);
+		if (work) {
+			INIT_WORK(&work->work, rt6_probe_deferred);
+			work->target = rt->rt6i_gateway;
+			dev_hold(rt->dst.dev);
+			work->dev = rt->dst.dev;
+			schedule_work(&work->work);
+		}
 	} else {
 out:
 		write_unlock(&neigh->lock);
-- 
1.8.3.1
