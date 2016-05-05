From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 11/14] ip6_gre: Add support for fou/gue encapsulation
Date: Wed, 4 May 2016 18:02:41 -0700
Message-ID: <1462410164-1953217-12-git-send-email-tom@herbertland.com>
References: <1462410164-1953217-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:48322 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754043AbcEEBDD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 21:03:03 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u4511267032623
	for <netdev@vger.kernel.org>; Wed, 4 May 2016 18:03:02 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0089730.ppops.net with ESMTP id 22qjtybxrm-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 04 May 2016 18:03:02 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.103.99.99) with ESMTP	id
 1d471278125d11e6b1ad0002c9dfb610-b2eeac50 for <netdev@vger.kernel.org>;	Wed,
 04 May 2016 18:03:01 -0700
In-Reply-To: <1462410164-1953217-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add netlink and setup for encapsulation

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv6/ip6_gre.c | 75 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 75 insertions(+)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index c827ae8..2beb212 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -1026,6 +1026,8 @@ static int ip6gre_tunnel_init_common(struct net_device *dev)
 
 	tunnel->tun_hlen = gre_calc_hlen(tunnel->parms.o_flags);
 
+	tunnel->hlen = tunnel->tun_hlen + tunnel->encap_hlen;
+
 	t_hlen = tunnel->hlen + sizeof(struct ipv6hdr);
 
 	dev->needed_headroom	= LL_MAX_HEADER + t_hlen + 4;
@@ -1292,15 +1294,57 @@ static void ip6gre_tap_setup(struct net_device *dev)
 	dev->priv_flags &= ~IFF_TX_SKB_SHARING;
 }
 
+static bool ip6gre_netlink_encap_parms(struct nlattr *data[],
+				       struct ip_tunnel_encap *ipencap)
+{
+	bool ret = false;
+
+	memset(ipencap, 0, sizeof(*ipencap));
+
+	if (!data)
+		return ret;
+
+	if (data[IFLA_GRE_ENCAP_TYPE]) {
+		ret = true;
+		ipencap->type = nla_get_u16(data[IFLA_GRE_ENCAP_TYPE]);
+	}
+
+	if (data[IFLA_GRE_ENCAP_FLAGS]) {
+		ret = true;
+		ipencap->flags = nla_get_u16(data[IFLA_GRE_ENCAP_FLAGS]);
+	}
+
+	if (data[IFLA_GRE_ENCAP_SPORT]) {
+		ret = true;
+		ipencap->sport = nla_get_be16(data[IFLA_GRE_ENCAP_SPORT]);
+	}
+
+	if (data[IFLA_GRE_ENCAP_DPORT]) {
+		ret = true;
+		ipencap->dport = nla_get_be16(data[IFLA_GRE_ENCAP_DPORT]);
+	}
+
+	return ret;
+}
+
 static int ip6gre_newlink(struct net *src_net, struct net_device *dev,
 	struct nlattr *tb[], struct nlattr *data[])
 {
 	struct ip6_tnl *nt;
 	struct net *net = dev_net(dev);
 	struct ip6gre_net *ign = net_generic(net, ip6gre_net_id);
+	struct ip_tunnel_encap ipencap;
 	int err;
 
 	nt = netdev_priv(dev);
+
+	if (ip6gre_netlink_encap_parms(data, &ipencap)) {
+		int err = ip6_tnl_encap_setup(nt, &ipencap);
+
+		if (err < 0)
+			return err;
+	}
+
 	ip6gre_netlink_parms(data, &nt->parms);
 
 	if (ip6gre_tunnel_find(net, &nt->parms, dev->type))
@@ -1347,10 +1391,18 @@ static int ip6gre_changelink(struct net_device *dev, struct nlattr *tb[],
 	struct net *net = nt->net;
 	struct ip6gre_net *ign = net_generic(net, ip6gre_net_id);
 	struct __ip6_tnl_parm p;
+	struct ip_tunnel_encap ipencap;
 
 	if (dev == ign->fb_tunnel_dev)
 		return -EINVAL;
 
+	if (ip6gre_netlink_encap_parms(data, &ipencap)) {
+		int err = ip6_tnl_encap_setup(nt, &ipencap);
+
+		if (err < 0)
+			return err;
+	}
+
 	ip6gre_netlink_parms(data, &p);
 
 	t = ip6gre_tunnel_locate(net, &p, 0);
@@ -1404,6 +1456,14 @@ static size_t ip6gre_get_size(const struct net_device *dev)
 		nla_total_size(4) +
 		/* IFLA_GRE_FLAGS */
 		nla_total_size(4) +
+		/* IFLA_GRE_ENCAP_TYPE */
+		nla_total_size(2) +
+		/* IFLA_GRE_ENCAP_FLAGS */
+		nla_total_size(2) +
+		/* IFLA_GRE_ENCAP_SPORT */
+		nla_total_size(2) +
+		/* IFLA_GRE_ENCAP_DPORT */
+		nla_total_size(2) +
 		0;
 }
 
@@ -1427,6 +1487,17 @@ static int ip6gre_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	    nla_put_be32(skb, IFLA_GRE_FLOWINFO, p->flowinfo) ||
 	    nla_put_u32(skb, IFLA_GRE_FLAGS, p->flags))
 		goto nla_put_failure;
+
+	if (nla_put_u16(skb, IFLA_GRE_ENCAP_TYPE,
+			t->encap.type) ||
+	    nla_put_be16(skb, IFLA_GRE_ENCAP_SPORT,
+			 t->encap.sport) ||
+	    nla_put_be16(skb, IFLA_GRE_ENCAP_DPORT,
+			 t->encap.dport) ||
+	    nla_put_u16(skb, IFLA_GRE_ENCAP_FLAGS,
+			t->encap.flags))
+		goto nla_put_failure;
+
 	return 0;
 
 nla_put_failure:
@@ -1445,6 +1516,10 @@ static const struct nla_policy ip6gre_policy[IFLA_GRE_MAX + 1] = {
 	[IFLA_GRE_ENCAP_LIMIT] = { .type = NLA_U8 },
 	[IFLA_GRE_FLOWINFO]    = { .type = NLA_U32 },
 	[IFLA_GRE_FLAGS]       = { .type = NLA_U32 },
+	[IFLA_GRE_ENCAP_TYPE]   = { .type = NLA_U16 },
+	[IFLA_GRE_ENCAP_FLAGS]  = { .type = NLA_U16 },
+	[IFLA_GRE_ENCAP_SPORT]  = { .type = NLA_U16 },
+	[IFLA_GRE_ENCAP_DPORT]  = { .type = NLA_U16 },
 };
 
 static struct rtnl_link_ops ip6gre_link_ops __read_mostly = {
-- 
2.8.0.rc2
