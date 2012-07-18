From: David Miller <davem@davemloft.net>
Subject: [PATCH 07/15] ipv4: Adjust semantics of rt->rt_gateway.
Date: Wed, 18 Jul 2012 11:23:46 -0700 (PDT)
Message-ID: <20120718.112346.920698833832945112.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36928 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755405Ab2GRSXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 14:23:47 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id BB5AC583FC7
	for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 11:23:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In order to allow prefixed routes, we have to adjust how rt_gateway
is set an interpreted.

The new interpretation is:

1) rt_gateway == 0, destination is on-link, nexthop is iph->daddr

2) rt_gateway != 0, destination requires a nexthop gateway

Signed-off-by: David S. Miller <davem@davemloft.net>
Tested-by: Vijay Subramanian <subramanian.vijay@gmail.com>
---
 net/ipv4/arp.c                      |    3 ++-
 net/ipv4/inet_connection_sock.c     |    4 ++--
 net/ipv4/ip_gre.c                   |    2 ++
 net/ipv4/ip_output.c                |    2 +-
 net/ipv4/ipip.c                     |    2 ++
 net/ipv4/netfilter/ipt_MASQUERADE.c |    7 +++++--
 net/ipv4/route.c                    |   18 ++++++++++--------
 7 files changed, 24 insertions(+), 14 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index c38293f..672d6f3 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -476,7 +476,8 @@ int arp_find(unsigned char *haddr, struct sk_buff *skb)
 	}
 
 	paddr = skb_rtable(skb)->rt_gateway;
-
+	if (!paddr)
+		paddr = ip_hdr(skb)->daddr;
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
index 42c44b1..1ff6bf8 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -767,6 +767,8 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 		if (skb->protocol == htons(ETH_P_IP)) {
 			rt = skb_rtable(skb);
 			dst = rt->rt_gateway;
+			if (!dst)
+				dst = old_iph->daddr;
 		}
 #if IS_ENABLED(CONFIG_IPV6)
 		else if (skb->protocol == htons(ETH_P_IPV6)) {
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index cc52679..6b805e0 100644
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
index 2c2c35b..59e0e95 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -488,6 +488,8 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 			goto tx_error;
 		}
 		dst = rt->rt_gateway;
+		if (!dst)
+			dst = old_iph->daddr;
 	}
 
 	rt = ip_route_output_ports(dev_net(dev), &fl4, NULL,
diff --git a/net/ipv4/netfilter/ipt_MASQUERADE.c b/net/ipv4/netfilter/ipt_MASQUERADE.c
index 2f210c7..b99746b 100644
--- a/net/ipv4/netfilter/ipt_MASQUERADE.c
+++ b/net/ipv4/netfilter/ipt_MASQUERADE.c
@@ -52,7 +52,7 @@ masquerade_tg(struct sk_buff *skb, const struct xt_action_param *par)
 	struct nf_nat_ipv4_range newrange;
 	const struct nf_nat_ipv4_multi_range_compat *mr;
 	const struct rtable *rt;
-	__be32 newsrc;
+	__be32 newsrc, nh;
 
 	NF_CT_ASSERT(par->hooknum == NF_INET_POST_ROUTING);
 
@@ -70,7 +70,10 @@ masquerade_tg(struct sk_buff *skb, const struct xt_action_param *par)
 
 	mr = par->targinfo;
 	rt = skb_rtable(skb);
-	newsrc = inet_select_addr(par->out, rt->rt_gateway, RT_SCOPE_UNIVERSE);
+	nh = rt->rt_gateway;
+	if (!nh)
+		nh = ip_hdr(skb)->daddr;
+	newsrc = inet_select_addr(par->out, nh, RT_SCOPE_UNIVERSE);
 	if (!newsrc) {
 		pr_info("%s ate my IP address\n", par->out->name);
 		return NF_DROP;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 76eb78e..7ebf788 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1079,8 +1079,10 @@ void ip_rt_get_source(u8 *addr, struct sk_buff *skb, struct rtable *rt)
 		if (fib_lookup(dev_net(rt->dst.dev), &fl4, &res) == 0)
 			src = FIB_RES_PREFSRC(dev_net(rt->dst.dev), res);
 		else
-			src = inet_select_addr(rt->dst.dev, rt->rt_gateway,
-					RT_SCOPE_UNIVERSE);
+			src = inet_select_addr(rt->dst.dev, (rt->rt_gateway ?
+							     rt->rt_gateway :
+							     iph->daddr),
+					       RT_SCOPE_UNIVERSE);
 		rcu_read_unlock();
 	}
 	memcpy(addr, &src, 4);
@@ -1126,7 +1128,7 @@ static unsigned int ipv4_mtu(const struct dst_entry *dst)
 	mtu = dst->dev->mtu;
 
 	if (unlikely(dst_metric_locked(dst, RTAX_MTU))) {
-		if (rt->rt_gateway != 0 && mtu > 576)
+		if (rt->rt_gateway && mtu > 576)
 			mtu = 576;
 	}
 
@@ -1256,7 +1258,7 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	rth->rt_iif	= dev->ifindex;
 	rth->rt_oif	= 0;
 	rth->rt_pmtu	= 0;
-	rth->rt_gateway	= daddr;
+	rth->rt_gateway	= 0;
 	rth->fi = NULL;
 	if (our) {
 		rth->dst.input= ip_local_deliver;
@@ -1374,7 +1376,7 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->rt_iif 	= in_dev->dev->ifindex;
 	rth->rt_oif 	= 0;
 	rth->rt_pmtu	= 0;
-	rth->rt_gateway	= daddr;
+	rth->rt_gateway	= 0;
 	rth->fi = NULL;
 
 	rth->dst.input = ip_forward;
@@ -1539,7 +1541,7 @@ local_input:
 	rth->rt_iif	= dev->ifindex;
 	rth->rt_oif	= 0;
 	rth->rt_pmtu	= 0;
-	rth->rt_gateway	= daddr;
+	rth->rt_gateway	= 0;
 	rth->fi = NULL;
 	if (res.type == RTN_UNREACHABLE) {
 		rth->dst.input= ip_error;
@@ -1689,7 +1691,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	rth->rt_iif	= orig_oif ? : dev_out->ifindex;
 	rth->rt_oif	= orig_oif;
 	rth->rt_pmtu	= 0;
-	rth->rt_gateway = fl4->daddr;
+	rth->rt_gateway = 0;
 	rth->fi = NULL;
 
 	RT_CACHE_STAT_INC(out_slow_tot);
@@ -2051,7 +2053,7 @@ static int rt_fill_info(struct net *net,  __be32 dst, __be32 src,
 		if (nla_put_be32(skb, RTA_PREFSRC, fl4->saddr))
 			goto nla_put_failure;
 	}
-	if (fl4->daddr != rt->rt_gateway &&
+	if (rt->rt_gateway &&
 	    nla_put_be32(skb, RTA_GATEWAY, rt->rt_gateway))
 		goto nla_put_failure;
 
-- 
1.7.10.4
