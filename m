From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC net-next 3/4] ipip: support MPLS over IPv4
Date: Wed,  6 Jul 2016 20:22:34 +0200
Message-ID: <1467829355-4498-4-git-send-email-simon.horman@netronome.com>
References: <1467829355-4498-1-git-send-email-simon.horman@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:35237 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751793AbcGFSW5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2016 14:22:57 -0400
Received: by mail-wm0-f51.google.com with SMTP id z126so121550857wme.0
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2016 11:22:56 -0700 (PDT)
Received: from penelope.isobedori.kobe.vergenet.net (dhcp-077-251-078-056.chello.nl. [77.251.78.56])
        by smtp.gmail.com with ESMTPSA id m5sm629757wmm.10.2016.07.06.11.22.53
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 06 Jul 2016 11:22:54 -0700 (PDT)
In-Reply-To: <1467829355-4498-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend the IPIP driver to support MPLS over IPv4. The implementation is an
extension of existing support for IPv4 over IPv4 and is based of multiple
inner-protocol support for the SIT driver.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
Reviewed-by: Dinan Gunawardena <dinan.gunawardena@netronome.com>
---
 net/ipv4/ipip.c | 137 +++++++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 121 insertions(+), 16 deletions(-)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 978370132f29..4ae3f8e6c6cc 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -148,14 +148,14 @@ static int ipip_err(struct sk_buff *skb, u32 info)
 
 	if (type == ICMP_DEST_UNREACH && code == ICMP_FRAG_NEEDED) {
 		ipv4_update_pmtu(skb, dev_net(skb->dev), info,
-				 t->parms.link, 0, IPPROTO_IPIP, 0);
+				 t->parms.link, 0, iph->protocol, 0);
 		err = 0;
 		goto out;
 	}
 
 	if (type == ICMP_REDIRECT) {
 		ipv4_redirect(skb, dev_net(skb->dev), t->parms.link, 0,
-			      IPPROTO_IPIP, 0);
+			      iph->protocol, 0);
 		err = 0;
 		goto out;
 	}
@@ -177,12 +177,19 @@ out:
 	return err;
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
+static int ipip_tunnel_rcv(struct sk_buff *skb, u8 ipproto)
 {
 	struct net *net = dev_net(skb->dev);
 	struct ip_tunnel_net *itn = net_generic(net, ipip_net_id);
@@ -193,11 +200,23 @@ static int ipip_rcv(struct sk_buff *skb)
 	tunnel = ip_tunnel_lookup(itn, skb->dev->ifindex, TUNNEL_NO_KEY,
 			iph->saddr, iph->daddr, 0);
 	if (tunnel) {
+		const struct tnl_ptk_info *tpi;
+
+		if (tunnel->parms.iph.protocol != ipproto &&
+		    tunnel->parms.iph.protocol != 0)
+			goto drop;
+
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
 
 	return -1;
@@ -207,24 +226,51 @@ drop:
 	return 0;
 }
 
+static int ipip_rcv(struct sk_buff *skb)
+{
+	return ipip_tunnel_rcv(skb, IPPROTO_IPIP);
+}
+
+#if IS_ENABLED(CONFIG_MPLS)
+static int mplsip_rcv(struct sk_buff *skb)
+{
+	return ipip_tunnel_rcv(skb, IPPROTO_MPLS);
+}
+#endif
+
 /*
  *	This function assumes it is being called from dev_queue_xmit()
  *	and that skb is filled properly by that function.
  */
-static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb,
+				    struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	const struct iphdr  *tiph = &tunnel->parms.iph;
+	u8 ipproto;
+
+	switch (skb->protocol) {
+	case htons(ETH_P_IP):
+		ipproto = IPPROTO_IPIP;
+		break;
+#if IS_ENABLED(CONFIG_MPLS)
+	case htons(ETH_P_MPLS_UC):
+		ipproto = IPPROTO_MPLS;
+		break;
+#endif
+	default:
+		goto tx_error;
+	}
 
-	if (unlikely(skb->protocol != htons(ETH_P_IP)))
+	if (tiph->protocol != ipproto && tiph->protocol != 0)
 		goto tx_error;
 
 	if (iptunnel_handle_offloads(skb, SKB_GSO_IPXIP4))
 		goto tx_error;
 
-	skb_set_inner_ipproto(skb, IPPROTO_IPIP);
+	skb_set_inner_ipproto(skb, ipproto);
 
-	ip_tunnel_xmit(skb, dev, tiph, tiph->protocol);
+	ip_tunnel_xmit(skb, dev, tiph, ipproto);
 	return NETDEV_TX_OK;
 
 tx_error:
@@ -234,6 +280,20 @@ tx_error:
 	return NETDEV_TX_OK;
 }
 
+static bool ipip_tunnel_ioctl_verify_protocol(u8 ipproto)
+{
+	switch (ipproto) {
+	case 0:
+	case IPPROTO_IPIP:
+#if IS_ENABLED(CONFIG_MPLS)
+	case IPPROTO_MPLS:
+#endif
+		return true;
+	}
+
+	return false;
+}
+
 static int
 ipip_tunnel_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
@@ -244,7 +304,8 @@ ipip_tunnel_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		return -EFAULT;
 
 	if (cmd == SIOCADDTUNNEL || cmd == SIOCCHGTUNNEL) {
-		if (p.iph.version != 4 || p.iph.protocol != IPPROTO_IPIP ||
+		if (p.iph.version != 4 ||
+		    !ipip_tunnel_ioctl_verify_protocol(p.iph.protocol) ||
 		    p.iph.ihl != 5 || (p.iph.frag_off&htons(~IP_DF)))
 			return -EINVAL;
 	}
@@ -301,10 +362,23 @@ static int ipip_tunnel_init(struct net_device *dev)
 
 	tunnel->tun_hlen = 0;
 	tunnel->hlen = tunnel->tun_hlen + tunnel->encap_hlen;
-	tunnel->parms.iph.protocol = IPPROTO_IPIP;
 	return ip_tunnel_init(dev);
 }
 
+static int ipip_tunnel_validate(struct nlattr *tb[], struct nlattr *data[])
+{
+	u8 proto;
+
+	if (!data || !data[IFLA_IPTUN_PROTO])
+		return 0;
+
+	proto = nla_get_u8(data[IFLA_IPTUN_PROTO]);
+	if (proto != IPPROTO_IPIP && proto != IPPROTO_MPLS && proto != 0)
+		return -EINVAL;
+
+	return 0;
+}
+
 static void ipip_netlink_parms(struct nlattr *data[],
 			       struct ip_tunnel_parm *parms)
 {
@@ -335,6 +409,9 @@ static void ipip_netlink_parms(struct nlattr *data[],
 	if (data[IFLA_IPTUN_TOS])
 		parms->iph.tos = nla_get_u8(data[IFLA_IPTUN_TOS]);
 
+	if (data[IFLA_IPTUN_PROTO])
+		parms->iph.protocol = nla_get_u8(data[IFLA_IPTUN_PROTO]);
+
 	if (!data[IFLA_IPTUN_PMTUDISC] || nla_get_u8(data[IFLA_IPTUN_PMTUDISC]))
 		parms->iph.frag_off = htons(IP_DF);
 }
@@ -427,6 +504,8 @@ static size_t ipip_get_size(const struct net_device *dev)
 		nla_total_size(1) +
 		/* IFLA_IPTUN_TOS */
 		nla_total_size(1) +
+		/* IFLA_IPTUN_PROTO */
+		nla_total_size(1) +
 		/* IFLA_IPTUN_PMTUDISC */
 		nla_total_size(1) +
 		/* IFLA_IPTUN_ENCAP_TYPE */
@@ -450,6 +529,7 @@ static int ipip_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	    nla_put_in_addr(skb, IFLA_IPTUN_REMOTE, parm->iph.daddr) ||
 	    nla_put_u8(skb, IFLA_IPTUN_TTL, parm->iph.ttl) ||
 	    nla_put_u8(skb, IFLA_IPTUN_TOS, parm->iph.tos) ||
+	    nla_put_u8(skb, IFLA_IPTUN_PROTO, parm->iph.protocol) ||
 	    nla_put_u8(skb, IFLA_IPTUN_PMTUDISC,
 		       !!(parm->iph.frag_off & htons(IP_DF))))
 		goto nla_put_failure;
@@ -476,6 +556,7 @@ static const struct nla_policy ipip_policy[IFLA_IPTUN_MAX + 1] = {
 	[IFLA_IPTUN_REMOTE]		= { .type = NLA_U32 },
 	[IFLA_IPTUN_TTL]		= { .type = NLA_U8 },
 	[IFLA_IPTUN_TOS]		= { .type = NLA_U8 },
+	[IFLA_IPTUN_PROTO]		= { .type = NLA_U8 },
 	[IFLA_IPTUN_PMTUDISC]		= { .type = NLA_U8 },
 	[IFLA_IPTUN_ENCAP_TYPE]		= { .type = NLA_U16 },
 	[IFLA_IPTUN_ENCAP_FLAGS]	= { .type = NLA_U16 },
@@ -489,6 +570,7 @@ static struct rtnl_link_ops ipip_link_ops __read_mostly = {
 	.policy		= ipip_policy,
 	.priv_size	= sizeof(struct ip_tunnel),
 	.setup		= ipip_tunnel_setup,
+	.validate	= ipip_tunnel_validate,
 	.newlink	= ipip_newlink,
 	.changelink	= ipip_changelink,
 	.dellink	= ip_tunnel_dellink,
@@ -503,6 +585,14 @@ static struct xfrm_tunnel ipip_handler __read_mostly = {
 	.priority	=	1,
 };
 
+#if IS_ENABLED(CONFIG_MPLS)
+static struct xfrm_tunnel mplsip_handler __read_mostly = {
+	.handler	=	mplsip_rcv,
+	.err_handler	=	ipip_err,
+	.priority	=	1,
+};
+#endif
+
 static int __net_init ipip_init_net(struct net *net)
 {
 	return ip_tunnel_init_net(net, ipip_net_id, &ipip_link_ops, "tunl0");
@@ -525,7 +615,7 @@ static int __init ipip_init(void)
 {
 	int err;
 
-	pr_info("ipip: IPv4 over IPv4 tunneling driver\n");
+	pr_info("ipip: IPv4 and MPLS over IPv4 tunneling driver\n");
 
 	err = register_pernet_device(&ipip_net_ops);
 	if (err < 0)
@@ -533,8 +623,15 @@ static int __init ipip_init(void)
 	err = xfrm4_tunnel_register(&ipip_handler, AF_INET);
 	if (err < 0) {
 		pr_info("%s: can't register tunnel\n", __func__);
-		goto xfrm_tunnel_failed;
+		goto xfrm_tunnel_ipip_failed;
+	}
+#if IS_ENABLED(CONFIG_MPLS)
+	err = xfrm4_tunnel_register(&mplsip_handler, AF_MPLS);
+	if (err < 0) {
+		pr_info("%s: can't register tunnel\n", __func__);
+		goto xfrm_tunnel_mplsip_failed;
 	}
+#endif
 	err = rtnl_link_register(&ipip_link_ops);
 	if (err < 0)
 		goto rtnl_link_failed;
@@ -543,8 +640,13 @@ out:
 	return err;
 
 rtnl_link_failed:
+#if IS_ENABLED(CONFIG_MPLS)
+	xfrm4_tunnel_deregister(&mplsip_handler, AF_INET);
+xfrm_tunnel_mplsip_failed:
+
+#endif
 	xfrm4_tunnel_deregister(&ipip_handler, AF_INET);
-xfrm_tunnel_failed:
+xfrm_tunnel_ipip_failed:
 	unregister_pernet_device(&ipip_net_ops);
 	goto out;
 }
@@ -554,7 +656,10 @@ static void __exit ipip_fini(void)
 	rtnl_link_unregister(&ipip_link_ops);
 	if (xfrm4_tunnel_deregister(&ipip_handler, AF_INET))
 		pr_info("%s: can't deregister tunnel\n", __func__);
-
+#if IS_ENABLED(CONFIG_MPLS)
+	if (xfrm4_tunnel_deregister(&mplsip_handler, AF_MPLS))
+		pr_info("%s: can't deregister tunnel\n", __func__);
+#endif
 	unregister_pernet_device(&ipip_net_ops);
 }
 
-- 
2.7.0.rc3.207.g0ac5344
