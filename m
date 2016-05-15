From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v5 net-next 12/14] ip6_tunnel: Add support for fou/gue encapsulation
Date: Sun, 15 May 2016 16:42:33 -0700
Message-ID: <1463355755-3481375-13-git-send-email-tom@herbertland.com>
References: <1463355755-3481375-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:61056 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752821AbcEOXnB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2016 19:43:01 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u4FNernh021254
	for <netdev@vger.kernel.org>; Sun, 15 May 2016 16:43:00 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0089730.ppops.net with ESMTP id 22wygmd10a-2
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Sun, 15 May 2016 16:43:00 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 c15b7c0e1af611e6a12624be0595f910-d34ebc50 for <netdev@vger.kernel.org>;	Sun,
 15 May 2016 16:42:59 -0700
In-Reply-To: <1463355755-3481375-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add netlink and setup for encapsulation

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv6/ip6_tunnel.c | 72 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 72 insertions(+)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 9f0ea85..093bdba 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1796,13 +1796,55 @@ static void ip6_tnl_netlink_parms(struct nlattr *data[],
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
@@ -1819,10 +1861,17 @@ static int ip6_tnl_changelink(struct net_device *dev, struct nlattr *tb[],
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
@@ -1863,6 +1912,14 @@ static size_t ip6_tnl_get_size(const struct net_device *dev)
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
 
@@ -1880,6 +1937,17 @@ static int ip6_tnl_fill_info(struct sk_buff *skb, const struct net_device *dev)
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
@@ -1903,6 +1971,10 @@ static const struct nla_policy ip6_tnl_policy[IFLA_IPTUN_MAX + 1] = {
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
