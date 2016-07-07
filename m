From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next v2 2/4] sit: support MPLS over IPv4
Date: Thu,  7 Jul 2016 07:56:13 +0200
Message-ID: <1467870975-28003-3-git-send-email-simon.horman@netronome.com>
References: <1467870975-28003-1-git-send-email-simon.horman@netronome.com>
Cc: Tom Herbert <tom@herbertland.com>, netdev@vger.kernel.org,
	Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:36729 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751179AbcGGF4a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 01:56:30 -0400
Received: by mail-wm0-f47.google.com with SMTP id f126so196755158wma.1
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2016 22:56:29 -0700 (PDT)
In-Reply-To: <1467870975-28003-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend the SIT driver to support MPLS over IPv4. This implementation
extends existing support for IPv6 over IPv4 and IPv4 over IPv4.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
Reviewed-by: Dinan Gunawardena <dinan.gunawardena@netronome.com>
---
v2
* Correct inverted logic for IPIP in ipip6_valid_ip_proto()
---
 net/ipv6/sit.c | 93 ++++++++++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 77 insertions(+), 16 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 917a5cd4b8fc..182b6a9be29d 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -688,12 +688,19 @@ out:
 	return 0;
 }
 
-static const struct tnl_ptk_info tpi = {
+static const struct tnl_ptk_info ipip_tpi = {
 	/* no tunnel info required for ipip. */
 	.proto = htons(ETH_P_IP),
 };
 
-static int ipip_rcv(struct sk_buff *skb)
+#if IS_ENABLED(CONFIG_MPLS)
+static const struct tnl_ptk_info mplsip_tpi = {
+	/* no tunnel info required for mplsip. */
+	.proto = htons(ETH_P_MPLS_UC),
+};
+#endif
+
+static int sit_tunnel_rcv(struct sk_buff *skb, u8 ipproto)
 {
 	const struct iphdr *iph;
 	struct ip_tunnel *tunnel;
@@ -702,15 +709,23 @@ static int ipip_rcv(struct sk_buff *skb)
 	tunnel = ipip6_tunnel_lookup(dev_net(skb->dev), skb->dev,
 				     iph->saddr, iph->daddr);
 	if (tunnel) {
-		if (tunnel->parms.iph.protocol != IPPROTO_IPIP &&
+		const struct tnl_ptk_info *tpi;
+
+		if (tunnel->parms.iph.protocol != ipproto &&
 		    tunnel->parms.iph.protocol != 0)
 			goto drop;
 
 		if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb))
 			goto drop;
-		if (iptunnel_pull_header(skb, 0, tpi.proto, false))
+#if IS_ENABLED(CONFIG_MPLS)
+		if (ipproto == IPPROTO_MPLS)
+			tpi = &mplsip_tpi;
+		else
+#endif
+			tpi = &ipip_tpi;
+		if (iptunnel_pull_header(skb, 0, tpi->proto, false))
 			goto drop;
-		return ip_tunnel_rcv(tunnel, skb, &tpi, NULL, log_ecn_error);
+		return ip_tunnel_rcv(tunnel, skb, tpi, NULL, log_ecn_error);
 	}
 
 	return 1;
@@ -720,6 +735,18 @@ drop:
 	return 0;
 }
 
+static int ipip_rcv(struct sk_buff *skb)
+{
+	return sit_tunnel_rcv(skb, IPPROTO_IPIP);
+}
+
+#if IS_ENABLED(CONFIG_MPLS)
+static int mplsip_rcv(struct sk_buff *skb)
+{
+	return sit_tunnel_rcv(skb, IPPROTO_MPLS);
+}
+#endif
+
 /*
  * If the IPv6 address comes from 6rd / 6to4 (RFC 3056) addr space this function
  * stores the embedded IPv4 address in v4dst and returns true.
@@ -958,7 +985,8 @@ tx_error:
 	return NETDEV_TX_OK;
 }
 
-static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t sit_tunnel_xmit__(struct sk_buff *skb,
+				     struct net_device *dev, u8 ipproto)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	const struct iphdr  *tiph = &tunnel->parms.iph;
@@ -966,9 +994,9 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (iptunnel_handle_offloads(skb, SKB_GSO_IPXIP4))
 		goto tx_error;
 
-	skb_set_inner_ipproto(skb, IPPROTO_IPIP);
+	skb_set_inner_ipproto(skb, ipproto);
 
-	ip_tunnel_xmit(skb, dev, tiph, IPPROTO_IPIP);
+	ip_tunnel_xmit(skb, dev, tiph, ipproto);
 	return NETDEV_TX_OK;
 tx_error:
 	kfree_skb(skb);
@@ -981,11 +1009,16 @@ static netdev_tx_t sit_tunnel_xmit(struct sk_buff *skb,
 {
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
-		ipip_tunnel_xmit(skb, dev);
+		sit_tunnel_xmit__(skb, dev, IPPROTO_IPIP);
 		break;
 	case htons(ETH_P_IPV6):
 		ipip6_tunnel_xmit(skb, dev);
 		break;
+#if IS_ENABLED(CONFIG_MPLS)
+	case htons(ETH_P_MPLS_UC):
+		sit_tunnel_xmit__(skb, dev, IPPROTO_MPLS);
+		break;
+#endif
 	default:
 		goto tx_err;
 	}
@@ -1093,6 +1126,16 @@ static int ipip6_tunnel_update_6rd(struct ip_tunnel *t,
 }
 #endif
 
+bool ipip6_valid_ip_proto(u8 ipproto)
+{
+	return ipproto == IPPROTO_IPV6 ||
+		ipproto == IPPROTO_IPIP ||
+#if IS_ENABLED(CONFIG_MPLS)
+		ipproto == IPPROTO_MPLS ||
+#endif
+		ipproto == 0;
+}
+
 static int
 ipip6_tunnel_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
@@ -1152,9 +1195,7 @@ ipip6_tunnel_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			goto done;
 
 		err = -EINVAL;
-		if (p.iph.protocol != IPPROTO_IPV6 &&
-		    p.iph.protocol != IPPROTO_IPIP &&
-		    p.iph.protocol != 0)
+		if (!ipip6_valid_ip_proto(p.iph.protocol))
 			goto done;
 		if (p.iph.version != 4 ||
 		    p.iph.ihl != 5 || (p.iph.frag_off&htons(~IP_DF)))
@@ -1379,9 +1420,7 @@ static int ipip6_validate(struct nlattr *tb[], struct nlattr *data[])
 		return 0;
 
 	proto = nla_get_u8(data[IFLA_IPTUN_PROTO]);
-	if (proto != IPPROTO_IPV6 &&
-	    proto != IPPROTO_IPIP &&
-	    proto != 0)
+	if (!ipip6_valid_ip_proto(proto))
 		return -EINVAL;
 
 	return 0;
@@ -1723,6 +1762,14 @@ static struct xfrm_tunnel ipip_handler __read_mostly = {
 	.priority	=	2,
 };
 
+#if IS_ENABLED(CONFIG_MPLS)
+static struct xfrm_tunnel mplsip_handler __read_mostly = {
+	.handler	=	mplsip_rcv,
+	.err_handler	=	ipip6_err,
+	.priority	=	2,
+};
+#endif
+
 static void __net_exit sit_destroy_tunnels(struct net *net,
 					   struct list_head *head)
 {
@@ -1818,6 +1865,9 @@ static void __exit sit_cleanup(void)
 	rtnl_link_unregister(&sit_link_ops);
 	xfrm4_tunnel_deregister(&sit_handler, AF_INET6);
 	xfrm4_tunnel_deregister(&ipip_handler, AF_INET);
+#if IS_ENABLED(CONFIG_MPLS)
+	xfrm4_tunnel_deregister(&mplsip_handler, AF_MPLS);
+#endif
 
 	unregister_pernet_device(&sit_net_ops);
 	rcu_barrier(); /* Wait for completion of call_rcu()'s */
@@ -1827,7 +1877,7 @@ static int __init sit_init(void)
 {
 	int err;
 
-	pr_info("IPv6 over IPv4 tunneling driver\n");
+	pr_info("IPv6, IPv4 and MPLS over IPv4 tunneling driver\n");
 
 	err = register_pernet_device(&sit_net_ops);
 	if (err < 0)
@@ -1842,6 +1892,13 @@ static int __init sit_init(void)
 		pr_info("%s: can't register ip4ip4\n", __func__);
 		goto xfrm_tunnel4_failed;
 	}
+#if IS_ENABLED(CONFIG_MPLS)
+	err = xfrm4_tunnel_register(&mplsip_handler, AF_MPLS);
+	if (err < 0) {
+		pr_info("%s: can't register mplsip\n", __func__);
+		goto xfrm_tunnel_mpls_failed;
+	}
+#endif
 	err = rtnl_link_register(&sit_link_ops);
 	if (err < 0)
 		goto rtnl_link_failed;
@@ -1850,6 +1907,10 @@ out:
 	return err;
 
 rtnl_link_failed:
+#if IS_ENABLED(CONFIG_MPLS)
+	xfrm4_tunnel_deregister(&mplsip_handler, AF_MPLS);
+xfrm_tunnel_mpls_failed:
+#endif
 	xfrm4_tunnel_deregister(&ipip_handler, AF_INET);
 xfrm_tunnel4_failed:
 	xfrm4_tunnel_deregister(&sit_handler, AF_INET6);
-- 
2.7.0.rc3.207.g0ac5344
