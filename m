From: David Miller <davem@davemloft.net>
Subject: [PATCH 6/6] ipv4: Remove 'rt_dst' from 'struct rtable'
Date: Thu, 12 Jul 2012 10:43:33 -0700 (PDT)
Message-ID: <20120712.104333.1447391981502978184.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58769 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934172Ab2GLRnd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 13:43:33 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id C0BEF5834FF
	for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 10:43:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/route.h     |    1 -
 net/ipv4/route.c        |   45 +++++++++------------------------------------
 net/ipv4/xfrm4_policy.c |    1 -
 3 files changed, 9 insertions(+), 38 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 757fe40..6d111bc 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -48,7 +48,6 @@ struct rtable {
 	unsigned int		rt_flags;
 	__u16			rt_type;
 
-	__be32			rt_dst;	/* Path destination	*/
 	int			rt_route_iif;
 	int			rt_iif;
 	int			rt_oif;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 266d1bc..c4b2df6 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -690,7 +690,7 @@ void ip_rt_send_redirect(struct sk_buff *skb)
 		    peer->rate_tokens == ip_rt_redirect_number)
 			net_warn_ratelimited("host %pI4/if%d ignores redirects for %pI4 to %pI4\n",
 					     &ip_hdr(skb)->saddr, rt->rt_iif,
-					     &rt->rt_dst, &rt->rt_gateway);
+					     &ip_hdr(skb)->daddr, &rt->rt_gateway);
 #endif
 	}
 out_put_peer:
@@ -951,8 +951,7 @@ static unsigned int ipv4_mtu(const struct dst_entry *dst)
 	mtu = dst->dev->mtu;
 
 	if (unlikely(dst_metric_locked(dst, RTAX_MTU))) {
-
-		if (rt->rt_gateway != rt->rt_dst && mtu > 576)
+		if (rt->rt_gateway != 0 && mtu > 576)
 			mtu = 576;
 	}
 
@@ -1047,7 +1046,6 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	rth->rt_genid	= rt_genid(dev_net(dev));
 	rth->rt_flags	= RTCF_MULTICAST;
 	rth->rt_type	= RTN_MULTICAST;
-	rth->rt_dst	= daddr;
 	rth->rt_route_iif = dev->ifindex;
 	rth->rt_iif	= dev->ifindex;
 	rth->rt_oif	= 0;
@@ -1166,7 +1164,6 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->rt_genid = rt_genid(dev_net(rth->dst.dev));
 	rth->rt_flags = flags;
 	rth->rt_type = res->type;
-	rth->rt_dst	= daddr;
 	rth->rt_route_iif = in_dev->dev->ifindex;
 	rth->rt_iif 	= in_dev->dev->ifindex;
 	rth->rt_oif 	= 0;
@@ -1332,7 +1329,6 @@ local_input:
 	rth->rt_genid = rt_genid(net);
 	rth->rt_flags 	= flags|RTCF_LOCAL;
 	rth->rt_type	= res.type;
-	rth->rt_dst	= daddr;
 	rth->rt_route_iif = dev->ifindex;
 	rth->rt_iif	= dev->ifindex;
 	rth->rt_oif	= 0;
@@ -1483,7 +1479,6 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	rth->rt_genid = rt_genid(dev_net(dev_out));
 	rth->rt_flags	= flags;
 	rth->rt_type	= type;
-	rth->rt_dst	= fl4->daddr;
 	rth->rt_route_iif = 0;
 	rth->rt_iif	= orig_oif ? : dev_out->ifindex;
 	rth->rt_oif	= orig_oif;
@@ -1771,7 +1766,6 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 		rt->rt_genid = rt_genid(net);
 		rt->rt_flags = ort->rt_flags;
 		rt->rt_type = ort->rt_type;
-		rt->rt_dst = ort->rt_dst;
 		rt->rt_gateway = ort->rt_gateway;
 		rt->fi = ort->fi;
 		if (rt->fi)
@@ -1802,9 +1796,9 @@ struct rtable *ip_route_output_flow(struct net *net, struct flowi4 *flp4,
 }
 EXPORT_SYMBOL_GPL(ip_route_output_flow);
 
-static int rt_fill_info(struct net *net,  __be32 src, struct flowi4 *fl4,
-			struct sk_buff *skb, u32 pid, u32 seq, int event,
-			int nowait, unsigned int flags)
+static int rt_fill_info(struct net *net,  __be32 dst, __be32 src,
+			struct flowi4 *fl4, struct sk_buff *skb, u32 pid,
+			u32 seq, int event, int nowait, unsigned int flags)
 {
 	struct rtable *rt = skb_rtable(skb);
 	struct rtmsg *r;
@@ -1831,7 +1825,7 @@ static int rt_fill_info(struct net *net,  __be32 src, struct flowi4 *fl4,
 	if (rt->rt_flags & RTCF_NOTIFY)
 		r->rtm_flags |= RTM_F_NOTIFY;
 
-	if (nla_put_be32(skb, RTA_DST, rt->rt_dst))
+	if (nla_put_be32(skb, RTA_DST, dst))
 		goto nla_put_failure;
 	if (src) {
 		r->rtm_src_len = 32;
@@ -1872,29 +1866,8 @@ static int rt_fill_info(struct net *net,  __be32 src, struct flowi4 *fl4,
 	}
 
 	if (rt_is_input_route(rt)) {
-#ifdef CONFIG_IP_MROUTE
-		__be32 dst = rt->rt_dst;
-
-		if (ipv4_is_multicast(dst) && !ipv4_is_local_multicast(dst) &&
-		    IPV4_DEVCONF_ALL(net, MC_FORWARDING)) {
-			int err = ipmr_get_route(net, skb,
-						 fl4->saddr, fl4->daddr,
-						 r, nowait);
-			if (err <= 0) {
-				if (!nowait) {
-					if (err == 0)
-						return 0;
-					goto nla_put_failure;
-				} else {
-					if (err == -EMSGSIZE)
-						goto nla_put_failure;
-					error = err;
-				}
-			}
-		} else
-#endif
-			if (nla_put_u32(skb, RTA_IIF, rt->rt_iif))
-				goto nla_put_failure;
+		if (nla_put_u32(skb, RTA_IIF, rt->rt_iif))
+			goto nla_put_failure;
 	}
 
 	if (rtnl_put_cacheinfo(skb, &rt->dst, 0, expires, error) < 0)
@@ -1989,7 +1962,7 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh, void
 	if (rtm->rtm_flags & RTM_F_NOTIFY)
 		rt->rt_flags |= RTCF_NOTIFY;
 
-	err = rt_fill_info(net, src, &fl4, skb,
+	err = rt_fill_info(net, dst, src, &fl4, skb,
 			   NETLINK_CB(in_skb).pid, nlh->nlmsg_seq,
 			   RTM_NEWROUTE, 0, 0);
 	if (err <= 0)
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index dbaf7bc..7c1e410 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -91,7 +91,6 @@ static int xfrm4_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 	xdst->u.rt.rt_flags = rt->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST |
 					      RTCF_LOCAL);
 	xdst->u.rt.rt_type = rt->rt_type;
-	xdst->u.rt.rt_dst = rt->rt_dst;
 	xdst->u.rt.rt_gateway = rt->rt_gateway;
 	xdst->u.rt.rt_pmtu = rt->rt_pmtu;
 
-- 
1.7.10.4
