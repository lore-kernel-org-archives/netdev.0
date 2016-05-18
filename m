From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v7 net-next 11/16] ip6_gre: Add support for fou/gue encapsulation
Date: Wed, 18 May 2016 09:06:19 -0700
Message-ID: <1463587584-2315623-12-git-send-email-tom@herbertland.com>
References: <1463587584-2315623-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:56432 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932767AbcERQGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 12:06:46 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u4IG6GKq030984
	for <netdev@vger.kernel.org>; Wed, 18 May 2016 09:06:45 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 230s3t8u9h-1
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 18 May 2016 09:06:45 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 844f01e61d1211e689100002c99293a0-3fbf2c50 for <netdev@vger.kernel.org>;	Wed,
 18 May 2016 09:06:44 -0700
In-Reply-To: <1463587584-2315623-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add netlink and setup for encapsulation

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv6/ip6_gre.c | 79 +++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 75 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 4541fa5..6fb1b89 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -729,7 +729,7 @@ static void ip6gre_tnl_link_config(struct ip6_tnl *t, int set_mtu)
 
 	t->tun_hlen = gre_calc_hlen(t->parms.o_flags);
 
-	t->hlen = t->tun_hlen;
+	t->hlen = t->encap_hlen + t->tun_hlen;
 
 	t_hlen = t->hlen + sizeof(struct ipv6hdr);
 
@@ -1022,9 +1022,7 @@ static int ip6gre_tunnel_init_common(struct net_device *dev)
 	}
 
 	tunnel->tun_hlen = gre_calc_hlen(tunnel->parms.o_flags);
-
-	tunnel->hlen = tunnel->tun_hlen;
-
+	tunnel->hlen = tunnel->tun_hlen + tunnel->encap_hlen;
 	t_hlen = tunnel->hlen + sizeof(struct ipv6hdr);
 
 	dev->hard_header_len = LL_MAX_HEADER + t_hlen;
@@ -1290,15 +1288,57 @@ static void ip6gre_tap_setup(struct net_device *dev)
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
@@ -1345,10 +1385,18 @@ static int ip6gre_changelink(struct net_device *dev, struct nlattr *tb[],
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
@@ -1400,6 +1448,14 @@ static size_t ip6gre_get_size(const struct net_device *dev)
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
 
@@ -1422,6 +1478,17 @@ static int ip6gre_fill_info(struct sk_buff *skb, const struct net_device *dev)
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
@@ -1440,6 +1507,10 @@ static const struct nla_policy ip6gre_policy[IFLA_GRE_MAX + 1] = {
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
