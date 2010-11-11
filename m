From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: get rid of rtable->idev
Date: Thu, 11 Nov 2010 18:14:07 +0100
Message-ID: <1289495647.17691.1536.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Roland Dreier <rolandd@cisco.com>,
	Sean Hefty <sean.hefty@intel.com>,
	Hal Rosenstock <hal.rosenstock@gmail.com>
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:46151 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752492Ab0KKROL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 12:14:11 -0500
Received: by gyh4 with SMTP id 4so1327596gyh.19
        for <netdev@vger.kernel.org>; Thu, 11 Nov 2010 09:14:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems idev field in struct rtable has no special purpose, but adding
extra atomic ops.

We hold refcounts on the device itself (using percpu data, so pretty
cheap in current kernel).

infiniband case is solved using dst.dev instead of idev->dev

Removal of this field means routing without route cache is now using
shared data, percpu data, and only potential contention is a pair of
atomic ops on struct neighbour per forwarded packet.

About 5% speedup on routing test.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Roland Dreier <rolandd@cisco.com>
Cc: Sean Hefty <sean.hefty@intel.com>
Cc: Hal Rosenstock <hal.rosenstock@gmail.com>
---
 drivers/infiniband/core/addr.c |    8 +++---
 include/net/route.h            |    2 -
 net/ipv4/route.c               |   37 +++----------------------------
 net/ipv4/xfrm4_policy.c        |   24 --------------------
 4 files changed, 8 insertions(+), 63 deletions(-)

diff --git a/drivers/infiniband/core/addr.c b/drivers/infiniband/core/addr.c
index a5ea1bc..c15fd2e 100644
--- a/drivers/infiniband/core/addr.c
+++ b/drivers/infiniband/core/addr.c
@@ -200,7 +200,7 @@ static int addr4_resolve(struct sockaddr_in *src_in,
 	src_in->sin_family = AF_INET;
 	src_in->sin_addr.s_addr = rt->rt_src;
 
-	if (rt->idev->dev->flags & IFF_LOOPBACK) {
+	if (rt->dst.dev->flags & IFF_LOOPBACK) {
 		ret = rdma_translate_ip((struct sockaddr *) dst_in, addr);
 		if (!ret)
 			memcpy(addr->dst_dev_addr, addr->src_dev_addr, MAX_ADDR_LEN);
@@ -208,12 +208,12 @@ static int addr4_resolve(struct sockaddr_in *src_in,
 	}
 
 	/* If the device does ARP internally, return 'done' */
-	if (rt->idev->dev->flags & IFF_NOARP) {
-		rdma_copy_addr(addr, rt->idev->dev, NULL);
+	if (rt->dst.dev->flags & IFF_NOARP) {
+		rdma_copy_addr(addr, rt->dst.dev, NULL);
 		goto put;
 	}
 
-	neigh = neigh_lookup(&arp_tbl, &rt->rt_gateway, rt->idev->dev);
+	neigh = neigh_lookup(&arp_tbl, &rt->rt_gateway, rt->dst.dev);
 	if (!neigh || !(neigh->nud_state & NUD_VALID)) {
 		neigh_event_send(rt->dst.neighbour, NULL);
 		ret = -ENODATA;
diff --git a/include/net/route.h b/include/net/route.h
index 7e5e73b..cea533e 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -55,8 +55,6 @@ struct rtable {
 	/* Cache lookup keys */
 	struct flowi		fl;
 
-	struct in_device	*idev;
-	
 	int			rt_genid;
 	unsigned		rt_flags;
 	__u16			rt_type;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 987bf9a..5955965 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -140,13 +140,15 @@ static unsigned long expires_ljiffies;
 
 static struct dst_entry *ipv4_dst_check(struct dst_entry *dst, u32 cookie);
 static void		 ipv4_dst_destroy(struct dst_entry *dst);
-static void		 ipv4_dst_ifdown(struct dst_entry *dst,
-					 struct net_device *dev, int how);
 static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst);
 static void		 ipv4_link_failure(struct sk_buff *skb);
 static void		 ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu);
 static int rt_garbage_collect(struct dst_ops *ops);
 
+static void ipv4_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
+			    int how)
+{
+}
 
 static struct dst_ops ipv4_dst_ops = {
 	.family =		AF_INET,
@@ -1433,8 +1435,6 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 				rt->dst.child		= NULL;
 				if (rt->dst.dev)
 					dev_hold(rt->dst.dev);
-				if (rt->idev)
-					in_dev_hold(rt->idev);
 				rt->dst.obsolete	= -1;
 				rt->dst.lastuse	= jiffies;
 				rt->dst.path		= &rt->dst;
@@ -1728,33 +1728,13 @@ static void ipv4_dst_destroy(struct dst_entry *dst)
 {
 	struct rtable *rt = (struct rtable *) dst;
 	struct inet_peer *peer = rt->peer;
-	struct in_device *idev = rt->idev;
 
 	if (peer) {
 		rt->peer = NULL;
 		inet_putpeer(peer);
 	}
-
-	if (idev) {
-		rt->idev = NULL;
-		in_dev_put(idev);
-	}
 }
 
-static void ipv4_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
-			    int how)
-{
-	struct rtable *rt = (struct rtable *) dst;
-	struct in_device *idev = rt->idev;
-	if (dev != dev_net(dev)->loopback_dev && idev && idev->dev == dev) {
-		struct in_device *loopback_idev =
-			in_dev_get(dev_net(dev)->loopback_dev);
-		if (loopback_idev) {
-			rt->idev = loopback_idev;
-			in_dev_put(idev);
-		}
-	}
-}
 
 static void ipv4_link_failure(struct sk_buff *skb)
 {
@@ -1910,7 +1890,6 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	rth->fl.iif	= dev->ifindex;
 	rth->dst.dev	= init_net.loopback_dev;
 	dev_hold(rth->dst.dev);
-	rth->idev	= in_dev_get(rth->dst.dev);
 	rth->fl.oif	= 0;
 	rth->rt_gateway	= daddr;
 	rth->rt_spec_dst= spec_dst;
@@ -2050,7 +2029,6 @@ static int __mkroute_input(struct sk_buff *skb,
 		rth->fl.iif	= in_dev->dev->ifindex;
 	rth->dst.dev	= (out_dev)->dev;
 	dev_hold(rth->dst.dev);
-	rth->idev	= in_dev_get(rth->dst.dev);
 	rth->fl.oif 	= 0;
 	rth->rt_spec_dst= spec_dst;
 
@@ -2231,7 +2209,6 @@ local_input:
 	rth->fl.iif	= dev->ifindex;
 	rth->dst.dev	= net->loopback_dev;
 	dev_hold(rth->dst.dev);
-	rth->idev	= in_dev_get(rth->dst.dev);
 	rth->rt_gateway	= daddr;
 	rth->rt_spec_dst= spec_dst;
 	rth->dst.input= ip_local_deliver;
@@ -2417,9 +2394,6 @@ static int __mkroute_output(struct rtable **result,
 	if (!rth)
 		return -ENOBUFS;
 
-	in_dev_hold(in_dev);
-	rth->idev = in_dev;
-
 	atomic_set(&rth->dst.__refcnt, 1);
 	rth->dst.flags= DST_HOST;
 	if (IN_DEV_CONF_GET(in_dev, NOXFRM))
@@ -2759,9 +2733,6 @@ static int ipv4_dst_blackhole(struct net *net, struct rtable **rp, struct flowi
 
 		rt->fl = ort->fl;
 
-		rt->idev = ort->idev;
-		if (rt->idev)
-			in_dev_hold(rt->idev);
 		rt->rt_genid = rt_genid(net);
 		rt->rt_flags = ort->rt_flags;
 		rt->rt_type = ort->rt_type;
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 4464f3b..dd1fd8c 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -80,10 +80,6 @@ static int xfrm4_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 	xdst->u.dst.dev = dev;
 	dev_hold(dev);
 
-	xdst->u.rt.idev = in_dev_get(dev);
-	if (!xdst->u.rt.idev)
-		return -ENODEV;
-
 	xdst->u.rt.peer = rt->peer;
 	if (rt->peer)
 		atomic_inc(&rt->peer->refcnt);
@@ -189,8 +185,6 @@ static void xfrm4_dst_destroy(struct dst_entry *dst)
 {
 	struct xfrm_dst *xdst = (struct xfrm_dst *)dst;
 
-	if (likely(xdst->u.rt.idev))
-		in_dev_put(xdst->u.rt.idev);
 	if (likely(xdst->u.rt.peer))
 		inet_putpeer(xdst->u.rt.peer);
 	xfrm_dst_destroy(xdst);
@@ -199,27 +193,9 @@ static void xfrm4_dst_destroy(struct dst_entry *dst)
 static void xfrm4_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 			     int unregister)
 {
-	struct xfrm_dst *xdst;
-
 	if (!unregister)
 		return;
 
-	xdst = (struct xfrm_dst *)dst;
-	if (xdst->u.rt.idev->dev == dev) {
-		struct in_device *loopback_idev =
-			in_dev_get(dev_net(dev)->loopback_dev);
-		BUG_ON(!loopback_idev);
-
-		do {
-			in_dev_put(xdst->u.rt.idev);
-			xdst->u.rt.idev = loopback_idev;
-			in_dev_hold(loopback_idev);
-			xdst = (struct xfrm_dst *)xdst->u.dst.child;
-		} while (xdst->u.dst.xfrm);
-
-		__in_dev_put(loopback_idev);
-	}
-
 	xfrm_dst_ifdown(dst, dev);
 }
 


