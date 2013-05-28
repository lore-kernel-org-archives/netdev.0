From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 2/2] sit: add IPv4 over IPv4 support
Date: Tue, 28 May 2013 11:48:16 +0200
Message-ID: <1369734496-21961-3-git-send-email-nicolas.dichtel@6wind.com>
References: <1369734496-21961-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:42077 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933813Ab3E1JtG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 05:49:06 -0400
In-Reply-To: <1369734496-21961-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the support of IPv4 over Ipv4 for the module sit. The gain of
this feature is to be able to have 4in4 and 6in4 over the same interface
instead of having one interface for 6in4 and another for 4in4 even if
encapsulation addresses are the same.

To avoid conflicting with ipip module, sit IPv4 over IPv4 protocol is
registered with a smaller priority.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv4/xfrm4_tunnel.c |   2 +-
 net/ipv6/sit.c          | 119 ++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 117 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/xfrm4_tunnel.c b/net/ipv4/xfrm4_tunnel.c
index 05a5df2..06347db 100644
--- a/net/ipv4/xfrm4_tunnel.c
+++ b/net/ipv4/xfrm4_tunnel.c
@@ -63,7 +63,7 @@ static int xfrm_tunnel_err(struct sk_buff *skb, u32 info)
 static struct xfrm_tunnel xfrm_tunnel_handler __read_mostly = {
 	.handler	=	xfrm_tunnel_rcv,
 	.err_handler	=	xfrm_tunnel_err,
-	.priority	=	2,
+	.priority	=	3,
 };
 
 #if IS_ENABLED(CONFIG_IPV6)
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 3353634..6b9c1f12 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -577,6 +577,10 @@ static int ipip6_rcv(struct sk_buff *skb)
 	if (tunnel != NULL) {
 		struct pcpu_tstats *tstats;
 
+		if (tunnel->parms.iph.protocol != IPPROTO_IPV6 &&
+		    tunnel->parms.iph.protocol != 0)
+			goto out;
+
 		secpath_reset(skb);
 		skb->mac_header = skb->network_header;
 		skb_reset_network_header(skb);
@@ -629,6 +633,35 @@ out:
 	return 0;
 }
 
+static const struct tnl_ptk_info tpi = {
+	/* no tunnel info required for ipip. */
+	.proto = htons(ETH_P_IP),
+};
+
+static int ipip_rcv(struct sk_buff *skb)
+{
+	const struct iphdr *iph = ip_hdr(skb);
+	struct ip_tunnel *tunnel;
+
+	tunnel = ipip6_tunnel_lookup(dev_net(skb->dev), skb->dev,
+				     iph->saddr, iph->daddr);
+	if (tunnel != NULL) {
+		if (tunnel->parms.iph.protocol != IPPROTO_IPIP &&
+		    tunnel->parms.iph.protocol != 0)
+			goto drop;
+
+		if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb))
+			goto drop;
+		return ip_tunnel_rcv(tunnel, skb, &tpi, log_ecn_error);
+	}
+
+	return 1;
+
+drop:
+	kfree_skb(skb);
+	return 0;
+}
+
 /*
  * If the IPv6 address comes from 6rd / 6to4 (RFC 3056) addr space this function
  * stores the embedded IPv4 address in v4dst and returns true.
@@ -877,6 +910,43 @@ tx_error:
 	return NETDEV_TX_OK;
 }
 
+static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+	const struct iphdr  *tiph = &tunnel->parms.iph;
+
+	if (likely(!skb->encapsulation)) {
+		skb_reset_inner_headers(skb);
+		skb->encapsulation = 1;
+	}
+
+	ip_tunnel_xmit(skb, dev, tiph, IPPROTO_IPIP);
+	return NETDEV_TX_OK;
+}
+
+static netdev_tx_t sit_tunnel_xmit(struct sk_buff *skb,
+				   struct net_device *dev)
+{
+	switch (skb->protocol) {
+	case htons(ETH_P_IP):
+		ipip_tunnel_xmit(skb, dev);
+		break;
+	case htons(ETH_P_IPV6):
+		ipip6_tunnel_xmit(skb, dev);
+		break;
+	default:
+		goto tx_err;
+	}
+
+	return NETDEV_TX_OK;
+
+tx_err:
+	dev->stats.tx_errors++;
+	dev_kfree_skb(skb);
+	return NETDEV_TX_OK;
+
+}
+
 static void ipip6_tunnel_bind_dev(struct net_device *dev)
 {
 	struct net_device *tdev = NULL;
@@ -1027,7 +1097,11 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 			goto done;
 
 		err = -EINVAL;
-		if (p.iph.version != 4 || p.iph.protocol != IPPROTO_IPV6 ||
+		if (p.iph.protocol != IPPROTO_IPV6 &&
+		    p.iph.protocol != IPPROTO_IPIP &&
+		    p.iph.protocol != 0)
+			goto done;
+		if (p.iph.version != 4 ||
 		    p.iph.ihl != 5 || (p.iph.frag_off&htons(~IP_DF)))
 			goto done;
 		if (p.iph.ttl)
@@ -1164,7 +1238,7 @@ static int ipip6_tunnel_change_mtu(struct net_device *dev, int new_mtu)
 
 static const struct net_device_ops ipip6_netdev_ops = {
 	.ndo_uninit	= ipip6_tunnel_uninit,
-	.ndo_start_xmit	= ipip6_tunnel_xmit,
+	.ndo_start_xmit	= sit_tunnel_xmit,
 	.ndo_do_ioctl	= ipip6_tunnel_ioctl,
 	.ndo_change_mtu	= ipip6_tunnel_change_mtu,
 	.ndo_get_stats64 = ip_tunnel_get_stats64,
@@ -1232,6 +1306,22 @@ static int __net_init ipip6_fb_tunnel_init(struct net_device *dev)
 	return 0;
 }
 
+static int ipip6_validate(struct nlattr *tb[], struct nlattr *data[])
+{
+	u8 proto;
+
+	if (!data)
+		return 0;
+
+	proto = nla_get_u8(data[IFLA_IPTUN_PROTO]);
+	if (proto != IPPROTO_IPV6 &&
+	    proto != IPPROTO_IPIP &&
+	    proto != 0)
+		return -EINVAL;
+
+	return 0;
+}
+
 static void ipip6_netlink_parms(struct nlattr *data[],
 				struct ip_tunnel_parm *parms)
 {
@@ -1268,6 +1358,10 @@ static void ipip6_netlink_parms(struct nlattr *data[],
 
 	if (data[IFLA_IPTUN_FLAGS])
 		parms->i_flags = nla_get_be16(data[IFLA_IPTUN_FLAGS]);
+
+	if (data[IFLA_IPTUN_PROTO])
+		parms->iph.protocol = nla_get_u8(data[IFLA_IPTUN_PROTO]);
+
 }
 
 #ifdef CONFIG_IPV6_SIT_6RD
@@ -1391,6 +1485,8 @@ static size_t ipip6_get_size(const struct net_device *dev)
 		nla_total_size(1) +
 		/* IFLA_IPTUN_FLAGS */
 		nla_total_size(2) +
+		/* IFLA_IPTUN_PROTO */
+		nla_total_size(1) +
 #ifdef CONFIG_IPV6_SIT_6RD
 		/* IFLA_IPTUN_6RD_PREFIX */
 		nla_total_size(sizeof(struct in6_addr)) +
@@ -1416,6 +1512,7 @@ static int ipip6_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	    nla_put_u8(skb, IFLA_IPTUN_TOS, parm->iph.tos) ||
 	    nla_put_u8(skb, IFLA_IPTUN_PMTUDISC,
 		       !!(parm->iph.frag_off & htons(IP_DF))) ||
+	    nla_put_u8(skb, IFLA_IPTUN_PROTO, parm->iph.protocol) ||
 	    nla_put_be16(skb, IFLA_IPTUN_FLAGS, parm->i_flags))
 		goto nla_put_failure;
 
@@ -1445,6 +1542,7 @@ static const struct nla_policy ipip6_policy[IFLA_IPTUN_MAX + 1] = {
 	[IFLA_IPTUN_TOS]		= { .type = NLA_U8 },
 	[IFLA_IPTUN_PMTUDISC]		= { .type = NLA_U8 },
 	[IFLA_IPTUN_FLAGS]		= { .type = NLA_U16 },
+	[IFLA_IPTUN_PROTO]		= { .type = NLA_U8 },
 #ifdef CONFIG_IPV6_SIT_6RD
 	[IFLA_IPTUN_6RD_PREFIX]		= { .len = sizeof(struct in6_addr) },
 	[IFLA_IPTUN_6RD_RELAY_PREFIX]	= { .type = NLA_U32 },
@@ -1459,6 +1557,7 @@ static struct rtnl_link_ops sit_link_ops __read_mostly = {
 	.policy		= ipip6_policy,
 	.priv_size	= sizeof(struct ip_tunnel),
 	.setup		= ipip6_tunnel_setup,
+	.validate	= ipip6_validate,
 	.newlink	= ipip6_newlink,
 	.changelink	= ipip6_changelink,
 	.get_size	= ipip6_get_size,
@@ -1471,6 +1570,12 @@ static struct xfrm_tunnel sit_handler __read_mostly = {
 	.priority	=	1,
 };
 
+static struct xfrm_tunnel ipip_handler __read_mostly = {
+	.handler	=	ipip_rcv,
+	.err_handler	=	ipip6_err,
+	.priority	=	2,
+};
+
 static void __net_exit sit_destroy_tunnels(struct sit_net *sitn, struct list_head *head)
 {
 	int prio;
@@ -1553,6 +1658,7 @@ static void __exit sit_cleanup(void)
 {
 	rtnl_link_unregister(&sit_link_ops);
 	xfrm4_tunnel_deregister(&sit_handler, AF_INET6);
+	xfrm4_tunnel_deregister(&ipip_handler, AF_INET);
 
 	unregister_pernet_device(&sit_net_ops);
 	rcu_barrier(); /* Wait for completion of call_rcu()'s */
@@ -1569,9 +1675,14 @@ static int __init sit_init(void)
 		return err;
 	err = xfrm4_tunnel_register(&sit_handler, AF_INET6);
 	if (err < 0) {
-		pr_info("%s: can't add protocol\n", __func__);
+		pr_info("%s: can't register ip6ip4\n", __func__);
 		goto xfrm_tunnel_failed;
 	}
+	err = xfrm4_tunnel_register(&ipip_handler, AF_INET);
+	if (err < 0) {
+		pr_info("%s: can't register ip4ip4\n", __func__);
+		goto xfrm_tunnel4_failed;
+	}
 	err = rtnl_link_register(&sit_link_ops);
 	if (err < 0)
 		goto rtnl_link_failed;
@@ -1580,6 +1691,8 @@ out:
 	return err;
 
 rtnl_link_failed:
+	xfrm4_tunnel_deregister(&ipip_handler, AF_INET);
+xfrm_tunnel4_failed:
 	xfrm4_tunnel_deregister(&sit_handler, AF_INET6);
 xfrm_tunnel_failed:
 	unregister_pernet_device(&sit_net_ops);
-- 
1.8.2.1
