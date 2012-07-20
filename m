From: David Miller <davem@davemloft.net>
Subject: [PATCH 07/16] ipv4: Adjust semantics of rt->rt_gateway.
Date: Fri, 20 Jul 2012 14:25:53 -0700 (PDT)
Message-ID: <20120720.142553.906121622547386252.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55681 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752268Ab2GTVZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 17:25:54 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 5E639583616
	for <netdev@vger.kernel.org>; Fri, 20 Jul 2012 14:25:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In order to allow prefixed routes, we have to adjust how rt_gateway
is set and interpreted.

The new interpretation is:

1) rt_gateway == 0, destination is on-link, nexthop is iph->daddr

2) rt_gateway != 0, destination requires a nexthop gateway

Abstract the fetching of the proper nexthop value using a new
inline helper, rt_nexthop(), as suggested by Joe Perches.

Signed-off-by: David S. Miller <davem@davemloft.net>
Tested-by: Vijay Subramanian <subramanian.vijay@gmail.com>
---
 include/net/route.h                 |    7 +++++++
 net/ipv4/arp.c                      |    3 +--
 net/ipv4/inet_connection_sock.c     |    4 ++--
 net/ipv4/ip_gre.c                   |    2 +-
 net/ipv4/ip_output.c                |    2 +-
 net/ipv4/ipip.c                     |    2 +-
 net/ipv4/netfilter/ipt_MASQUERADE.c |    5 +++--
 net/ipv4/route.c                    |   17 +++++++++--------
 8 files changed, 25 insertions(+), 17 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 6d111bc..3c1eeab 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -70,6 +70,13 @@ static inline bool rt_is_output_route(const struct rtable *rt)
 	return rt->rt_route_iif == 0;
 }
 
+static inline __be32 rt_nexthop(const struct rtable *rt, __be32 daddr)
+{
+	if (rt->rt_gateway)
+		return rt->rt_gateway;
+	return daddr;
+}
+
 struct ip_rt_acct {
 	__u32 	o_bytes;
 	__u32 	o_packets;
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index c38293f..a0124eb 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -475,8 +475,7 @@ int arp_find(unsigned char *haddr, struct sk_buff *skb)
 		return 1;
 	}
 
-	paddr = skb_rtable(skb)->rt_gateway;
-
+	paddr = rt_nexthop(skb_rtable(skb), ip_hdr(skb)->daddr);
 	if (arp_set_predefined(inet_addr_type(dev_net(dev), paddr), haddr,
 			       paddr, dev))
 		return 0;
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index c7a4de0..0a290d7 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -389,7 +389,7 @@ struct dst_entry *inet_csk_route_req(struct sock *sk,
 	rt = ip_route_output_flow(net, fl4, sk);
 	if (IS_ERR(rt))
 		goto no_route;
-	if (opt && opt->opt.is_strictroute && fl4->daddr != rt->rt_gateway)
+	if (opt && opt->opt.is_strictroute && rt->rt_gateway)
 		goto route_err;
 	return &rt->dst;
 
@@ -422,7 +422,7 @@ struct dst_entry *inet_csk_route_child_sock(struct sock *sk,
 	rt = ip_route_output_flow(net, fl4, sk);
 	if (IS_ERR(rt))
 		goto no_route;
-	if (opt && opt->opt.is_strictroute && fl4->daddr != rt->rt_gateway)
+	if (opt && opt->opt.is_strictroute && rt->rt_gateway)
 		goto route_err;
 	return &rt->dst;
 
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 42c44b1..b062a98 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -766,7 +766,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 
 		if (skb->protocol == htons(ETH_P_IP)) {
 			rt = skb_rtable(skb);
-			dst = rt->rt_gateway;
+			dst = rt_nexthop(rt, old_iph->daddr);
 		}
 #if IS_ENABLED(CONFIG_IPV6)
 		else if (skb->protocol == htons(ETH_P_IPV6)) {
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index c528f84..4494015 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -371,7 +371,7 @@ int ip_queue_xmit(struct sk_buff *skb, struct flowi *fl)
 	skb_dst_set_noref(skb, &rt->dst);
 
 packet_routed:
-	if (inet_opt && inet_opt->opt.is_strictroute && fl4->daddr != rt->rt_gateway)
+	if (inet_opt && inet_opt->opt.is_strictroute && rt->rt_gateway)
 		goto no_route;
 
 	/* OK, we know where to send it, allocate and build IP header. */
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 2c2c35b..99af1f0 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -487,7 +487,7 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 			dev->stats.tx_fifo_errors++;
 			goto tx_error;
 		}
-		dst = rt->rt_gateway;
+		dst = rt_nexthop(rt, old_iph->daddr);
 	}
 
 	rt = ip_route_output_ports(dev_net(dev), &fl4, NULL,
diff --git a/net/ipv4/netfilter/ipt_MASQUERADE.c b/net/ipv4/netfilter/ipt_MASQUERADE.c
index 2f210c7..cbb6a1a 100644
--- a/net/ipv4/netfilter/ipt_MASQUERADE.c
+++ b/net/ipv4/netfilter/ipt_MASQUERADE.c
@@ -52,7 +52,7 @@ masquerade_tg(struct sk_buff *skb, const struct xt_action_param *par)
 	struct nf_nat_ipv4_range newrange;
 	const struct nf_nat_ipv4_multi_range_compat *mr;
 	const struct rtable *rt;
-	__be32 newsrc;
+	__be32 newsrc, nh;
 
 	NF_CT_ASSERT(par->hooknum == NF_INET_POST_ROUTING);
 
@@ -70,7 +70,8 @@ masquerade_tg(struct sk_buff *skb, const struct xt_action_param *par)
 
 	mr = par->targinfo;
 	rt = skb_rtable(skb);
-	newsrc = inet_select_addr(par->out, rt->rt_gateway, RT_SCOPE_UNIVERSE);
+	nh = rt_nexthop(rt, ip_hdr(skb)->daddr);
+	newsrc = inet_select_addr(par->out, nh, RT_SCOPE_UNIVERSE);
 	if (!newsrc) {
 		pr_info("%s ate my IP address\n", par->out->name);
 		return NF_DROP;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 85d103f..d1d5796 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1085,8 +1085,9 @@ void ip_rt_get_source(u8 *addr, struct sk_buff *skb, struct rtable *rt)
 		if (fib_lookup(dev_net(rt->dst.dev), &fl4, &res) == 0)
 			src = FIB_RES_PREFSRC(dev_net(rt->dst.dev), res);
 		else
-			src = inet_select_addr(rt->dst.dev, rt->rt_gateway,
-					RT_SCOPE_UNIVERSE);
+			src = inet_select_addr(rt->dst.dev,
+					       rt_nexthop(rt, iph->daddr),
+					       RT_SCOPE_UNIVERSE);
 		rcu_read_unlock();
 	}
 	memcpy(addr, &src, 4);
@@ -1132,7 +1133,7 @@ static unsigned int ipv4_mtu(const struct dst_entry *dst)
 	mtu = dst->dev->mtu;
 
 	if (unlikely(dst_metric_locked(dst, RTAX_MTU))) {
-		if (rt->rt_gateway != 0 && mtu > 576)
+		if (rt->rt_gateway && mtu > 576)
 			mtu = 576;
 	}
 
@@ -1274,7 +1275,7 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	rth->rt_iif	= dev->ifindex;
 	rth->rt_oif	= 0;
 	rth->rt_pmtu	= 0;
-	rth->rt_gateway	= daddr;
+	rth->rt_gateway	= 0;
 	rth->fi = NULL;
 	if (our) {
 		rth->dst.input= ip_local_deliver;
@@ -1392,7 +1393,7 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->rt_iif 	= in_dev->dev->ifindex;
 	rth->rt_oif 	= 0;
 	rth->rt_pmtu	= 0;
-	rth->rt_gateway	= daddr;
+	rth->rt_gateway	= 0;
 	rth->fi = NULL;
 
 	rth->dst.input = ip_forward;
@@ -1557,7 +1558,7 @@ local_input:
 	rth->rt_iif	= dev->ifindex;
 	rth->rt_oif	= 0;
 	rth->rt_pmtu	= 0;
-	rth->rt_gateway	= daddr;
+	rth->rt_gateway	= 0;
 	rth->fi = NULL;
 	if (res.type == RTN_UNREACHABLE) {
 		rth->dst.input= ip_error;
@@ -1707,7 +1708,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	rth->rt_iif	= orig_oif ? : dev_out->ifindex;
 	rth->rt_oif	= orig_oif;
 	rth->rt_pmtu	= 0;
-	rth->rt_gateway = fl4->daddr;
+	rth->rt_gateway = 0;
 	rth->fi = NULL;
 
 	RT_CACHE_STAT_INC(out_slow_tot);
@@ -2070,7 +2071,7 @@ static int rt_fill_info(struct net *net,  __be32 dst, __be32 src,
 		if (nla_put_be32(skb, RTA_PREFSRC, fl4->saddr))
 			goto nla_put_failure;
 	}
-	if (fl4->daddr != rt->rt_gateway &&
+	if (rt->rt_gateway &&
 	    nla_put_be32(skb, RTA_GATEWAY, rt->rt_gateway))
 		goto nla_put_failure;
 
-- 
1.7.10.4
