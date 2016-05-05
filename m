From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 12/14] ip6_tunnel: Add support for fou/gue encapsulation
Date: Wed, 4 May 2016 18:02:42 -0700
Message-ID: <1462410164-1953217-13-git-send-email-tom@herbertland.com>
References: <1462410164-1953217-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:14763 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755554AbcEEBDE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 21:03:04 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u4511268032623
	for <netdev@vger.kernel.org>; Wed, 4 May 2016 18:03:03 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0089730.ppops.net with ESMTP id 22qjtybxrm-2
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 04 May 2016 18:03:03 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.103.99.99) with ESMTP	id
 1dc11f46125d11e6b1ad0002c9dfb610-b2eeac50 for <netdev@vger.kernel.org>;	Wed,
 04 May 2016 18:03:02 -0700
In-Reply-To: <1462410164-1953217-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add netlink and setup for encapsulation

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv6/ip6_tunnel.c | 89 +++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 83 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 2c096ab..0e72af4 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1067,7 +1067,8 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
 				     t->parms.name);
 		goto tx_err_dst_release;
 	}
-	mtu = dst_mtu(dst) - sizeof(*ipv6h);
+	mtu = dst_mtu(dst) - dev->hard_header_len -
+		sizeof(*ipv6h);
 	if (encap_limit >= 0) {
 		max_headroom += 8;
 		mtu -= 8;
@@ -1131,7 +1132,7 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
 	}
 
 	max_headroom = LL_RESERVED_SPACE(dst->dev) + sizeof(struct ipv6hdr)
-			+ dst->header_len;
+			+ dst->header_len + t->encap_hlen;
 	if (max_headroom > dev->needed_headroom)
 		dev->needed_headroom = max_headroom;
 
@@ -1322,9 +1323,10 @@ static void ip6_tnl_link_config(struct ip6_tnl *t)
 
 		if (rt->dst.dev) {
 			dev->hard_header_len = rt->dst.dev->hard_header_len +
-				sizeof(struct ipv6hdr);
+				sizeof(struct ipv6hdr) + t->hlen;
 
-			dev->mtu = rt->dst.dev->mtu - sizeof(struct ipv6hdr);
+			dev->mtu = rt->dst.dev->mtu - sizeof(struct ipv6hdr) -
+				t->hlen;
 			if (!(t->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
 				dev->mtu -= 8;
 
@@ -1598,12 +1600,13 @@ static void ip6_tnl_dev_setup(struct net_device *dev)
 
 	dev->type = ARPHRD_TUNNEL6;
 	dev->hard_header_len = LL_MAX_HEADER + sizeof(struct ipv6hdr);
-	dev->mtu = ETH_DATA_LEN - sizeof(struct ipv6hdr);
 	t = netdev_priv(dev);
+	dev->mtu = ETH_DATA_LEN - sizeof(struct ipv6hdr) - t->hlen;
 	if (!(t->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
 		dev->mtu -= 8;
 	dev->flags |= IFF_NOARP;
 	dev->addr_len = sizeof(struct in6_addr);
+	dev->features |= NETIF_F_LLTX;
 	netif_keep_dst(dev);
 	/* This perm addr will be used as interface identifier by IPv6 */
 	dev->addr_assign_type = NET_ADDR_RANDOM;
@@ -1621,6 +1624,7 @@ ip6_tnl_dev_init_gen(struct net_device *dev)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
 	int ret;
+	int t_hlen;
 
 	t->dev = dev;
 	t->net = dev_net(dev);
@@ -1636,8 +1640,9 @@ ip6_tnl_dev_init_gen(struct net_device *dev)
 	if (ret)
 		goto destroy_dst;
 
-	t->hlen = 0;
 	t->tun_hlen = 0;
+	t->hlen = t->tun_hlen + t->encap_hlen;
+	t_hlen = t->hlen + sizeof(struct ipv6hdr);
 
 	return 0;
 
@@ -1735,13 +1740,55 @@ static void ip6_tnl_netlink_parms(struct nlattr *data[],
 		parms->proto = nla_get_u8(data[IFLA_IPTUN_PROTO]);
 }
 
+static bool ip6_tnl_netlink_encap_parms(struct nlattr *data[],
+					struct ip_tunnel_encap *ipencap)
+{
+	bool ret = false;
+
+	memset(ipencap, 0, sizeof(*ipencap));
+
+	if (!data)
+		return ret;
+
+	if (data[IFLA_IPTUN_ENCAP_TYPE]) {
+		ret = true;
+		ipencap->type = nla_get_u16(data[IFLA_IPTUN_ENCAP_TYPE]);
+	}
+
+	if (data[IFLA_IPTUN_ENCAP_FLAGS]) {
+		ret = true;
+		ipencap->flags = nla_get_u16(data[IFLA_IPTUN_ENCAP_FLAGS]);
+	}
+
+	if (data[IFLA_IPTUN_ENCAP_SPORT]) {
+		ret = true;
+		ipencap->sport = nla_get_be16(data[IFLA_IPTUN_ENCAP_SPORT]);
+	}
+
+	if (data[IFLA_IPTUN_ENCAP_DPORT]) {
+		ret = true;
+		ipencap->dport = nla_get_be16(data[IFLA_IPTUN_ENCAP_DPORT]);
+	}
+
+	return ret;
+}
+
 static int ip6_tnl_newlink(struct net *src_net, struct net_device *dev,
 			   struct nlattr *tb[], struct nlattr *data[])
 {
 	struct net *net = dev_net(dev);
 	struct ip6_tnl *nt, *t;
+	struct ip_tunnel_encap ipencap;
 
 	nt = netdev_priv(dev);
+
+	if (ip6_tnl_netlink_encap_parms(data, &ipencap)) {
+		int err = ip6_tnl_encap_setup(nt, &ipencap);
+
+		if (err < 0)
+			return err;
+	}
+
 	ip6_tnl_netlink_parms(data, &nt->parms);
 
 	t = ip6_tnl_locate(net, &nt->parms, 0);
@@ -1758,10 +1805,17 @@ static int ip6_tnl_changelink(struct net_device *dev, struct nlattr *tb[],
 	struct __ip6_tnl_parm p;
 	struct net *net = t->net;
 	struct ip6_tnl_net *ip6n = net_generic(net, ip6_tnl_net_id);
+	struct ip_tunnel_encap ipencap;
 
 	if (dev == ip6n->fb_tnl_dev)
 		return -EINVAL;
 
+	if (ip6_tnl_netlink_encap_parms(data, &ipencap)) {
+		int err = ip6_tnl_encap_setup(t, &ipencap);
+
+		if (err < 0)
+			return err;
+	}
 	ip6_tnl_netlink_parms(data, &p);
 
 	t = ip6_tnl_locate(net, &p, 0);
@@ -1802,6 +1856,14 @@ static size_t ip6_tnl_get_size(const struct net_device *dev)
 		nla_total_size(4) +
 		/* IFLA_IPTUN_PROTO */
 		nla_total_size(1) +
+		/* IFLA_IPTUN_ENCAP_TYPE */
+		nla_total_size(2) +
+		/* IFLA_IPTUN_ENCAP_FLAGS */
+		nla_total_size(2) +
+		/* IFLA_IPTUN_ENCAP_SPORT */
+		nla_total_size(2) +
+		/* IFLA_IPTUN_ENCAP_DPORT */
+		nla_total_size(2) +
 		0;
 }
 
@@ -1819,6 +1881,17 @@ static int ip6_tnl_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	    nla_put_u32(skb, IFLA_IPTUN_FLAGS, parm->flags) ||
 	    nla_put_u8(skb, IFLA_IPTUN_PROTO, parm->proto))
 		goto nla_put_failure;
+
+	if (nla_put_u16(skb, IFLA_IPTUN_ENCAP_TYPE,
+			tunnel->encap.type) ||
+	nla_put_be16(skb, IFLA_IPTUN_ENCAP_SPORT,
+		     tunnel->encap.sport) ||
+	nla_put_be16(skb, IFLA_IPTUN_ENCAP_DPORT,
+		     tunnel->encap.dport) ||
+	nla_put_u16(skb, IFLA_IPTUN_ENCAP_FLAGS,
+		    tunnel->encap.flags))
+		goto nla_put_failure;
+
 	return 0;
 
 nla_put_failure:
@@ -1842,6 +1915,10 @@ static const struct nla_policy ip6_tnl_policy[IFLA_IPTUN_MAX + 1] = {
 	[IFLA_IPTUN_FLOWINFO]		= { .type = NLA_U32 },
 	[IFLA_IPTUN_FLAGS]		= { .type = NLA_U32 },
 	[IFLA_IPTUN_PROTO]		= { .type = NLA_U8 },
+	[IFLA_IPTUN_ENCAP_TYPE]		= { .type = NLA_U16 },
+	[IFLA_IPTUN_ENCAP_FLAGS]	= { .type = NLA_U16 },
+	[IFLA_IPTUN_ENCAP_SPORT]	= { .type = NLA_U16 },
+	[IFLA_IPTUN_ENCAP_DPORT]	= { .type = NLA_U16 },
 };
 
 static struct rtnl_link_ops ip6_link_ops __read_mostly = {
-- 
2.8.0.rc2
