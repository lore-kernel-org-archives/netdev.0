From: Tom Herbert <therbert@google.com>
Subject: [PATCH v4 net-next 7/7] gre: Setup and TX path for gre/UDP foo-over-udp encapsulation
Date: Wed, 17 Sep 2014 12:26:01 -0700
Message-ID: <1410981961-15545-8-git-send-email-therbert@google.com>
References: <1410981961-15545-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:51834 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756698AbaIQT0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 15:26:39 -0400
Received: by mail-pd0-f179.google.com with SMTP id g10so2755925pdj.24
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 12:26:38 -0700 (PDT)
In-Reply-To: <1410981961-15545-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added netlink attrs to configure FOU encapsulation for GRE, netlink
handling of these flags, and properly adjust MTU for encapsulation.
ip_tunnel_encap is called from ip_tunnel_xmit to actually perform FOU
encapsulation.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/uapi/linux/if_tunnel.h |  4 ++
 net/ipv4/ip_gre.c              | 90 +++++++++++++++++++++++++++++++++++++++---
 2 files changed, 89 insertions(+), 5 deletions(-)

diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_tunnel.h
index 9fedca7..7c832af 100644
--- a/include/uapi/linux/if_tunnel.h
+++ b/include/uapi/linux/if_tunnel.h
@@ -106,6 +106,10 @@ enum {
 	IFLA_GRE_ENCAP_LIMIT,
 	IFLA_GRE_FLOWINFO,
 	IFLA_GRE_FLAGS,
+	IFLA_GRE_ENCAP_TYPE,
+	IFLA_GRE_ENCAP_FLAGS,
+	IFLA_GRE_ENCAP_SPORT,
+	IFLA_GRE_ENCAP_DPORT,
 	__IFLA_GRE_MAX,
 };
 
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 9b84254..829aff8b 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -239,7 +239,7 @@ static void __gre_xmit(struct sk_buff *skb, struct net_device *dev,
 	tpi.seq = htonl(tunnel->o_seqno);
 
 	/* Push GRE header. */
-	gre_build_header(skb, &tpi, tunnel->hlen);
+	gre_build_header(skb, &tpi, tunnel->tun_hlen);
 
 	ip_tunnel_xmit(skb, dev, tnl_params, tnl_params->protocol);
 }
@@ -310,7 +310,7 @@ out:
 static int ipgre_tunnel_ioctl(struct net_device *dev,
 			      struct ifreq *ifr, int cmd)
 {
-	int err = 0;
+	int err;
 	struct ip_tunnel_parm p;
 
 	if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p)))
@@ -470,13 +470,18 @@ static void ipgre_tunnel_setup(struct net_device *dev)
 static void __gre_tunnel_init(struct net_device *dev)
 {
 	struct ip_tunnel *tunnel;
+	int t_hlen;
 
 	tunnel = netdev_priv(dev);
-	tunnel->hlen = ip_gre_calc_hlen(tunnel->parms.o_flags);
+	tunnel->tun_hlen = ip_gre_calc_hlen(tunnel->parms.o_flags);
 	tunnel->parms.iph.protocol = IPPROTO_GRE;
 
-	dev->needed_headroom	= LL_MAX_HEADER + sizeof(struct iphdr) + 4;
-	dev->mtu		= ETH_DATA_LEN - sizeof(struct iphdr) - 4;
+	tunnel->hlen = tunnel->tun_hlen + tunnel->encap_hlen;
+
+	t_hlen = tunnel->hlen + sizeof(struct iphdr);
+
+	dev->needed_headroom	= LL_MAX_HEADER + t_hlen + 4;
+	dev->mtu		= ETH_DATA_LEN - t_hlen - 4;
 
 	dev->features		|= GRE_FEATURES;
 	dev->hw_features	|= GRE_FEATURES;
@@ -628,6 +633,40 @@ static void ipgre_netlink_parms(struct nlattr *data[], struct nlattr *tb[],
 		parms->iph.frag_off = htons(IP_DF);
 }
 
+/* This function returns true when ENCAP attributes are present in the nl msg */
+static bool ipgre_netlink_encap_parms(struct nlattr *data[],
+				      struct ip_tunnel_encap *ipencap)
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
+		ipencap->sport = nla_get_u16(data[IFLA_GRE_ENCAP_SPORT]);
+	}
+
+	if (data[IFLA_GRE_ENCAP_DPORT]) {
+		ret = true;
+		ipencap->dport = nla_get_u16(data[IFLA_GRE_ENCAP_DPORT]);
+	}
+
+	return ret;
+}
+
 static int gre_tap_init(struct net_device *dev)
 {
 	__gre_tunnel_init(dev);
@@ -657,6 +696,15 @@ static int ipgre_newlink(struct net *src_net, struct net_device *dev,
 			 struct nlattr *tb[], struct nlattr *data[])
 {
 	struct ip_tunnel_parm p;
+	struct ip_tunnel_encap ipencap;
+
+	if (ipgre_netlink_encap_parms(data, &ipencap)) {
+		struct ip_tunnel *t = netdev_priv(dev);
+		int err = ip_tunnel_encap_setup(t, &ipencap);
+
+		if (err < 0)
+			return err;
+	}
 
 	ipgre_netlink_parms(data, tb, &p);
 	return ip_tunnel_newlink(dev, tb, &p);
@@ -666,6 +714,15 @@ static int ipgre_changelink(struct net_device *dev, struct nlattr *tb[],
 			    struct nlattr *data[])
 {
 	struct ip_tunnel_parm p;
+	struct ip_tunnel_encap ipencap;
+
+	if (ipgre_netlink_encap_parms(data, &ipencap)) {
+		struct ip_tunnel *t = netdev_priv(dev);
+		int err = ip_tunnel_encap_setup(t, &ipencap);
+
+		if (err < 0)
+			return err;
+	}
 
 	ipgre_netlink_parms(data, tb, &p);
 	return ip_tunnel_changelink(dev, tb, &p);
@@ -694,6 +751,14 @@ static size_t ipgre_get_size(const struct net_device *dev)
 		nla_total_size(1) +
 		/* IFLA_GRE_PMTUDISC */
 		nla_total_size(1) +
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
 
@@ -714,6 +779,17 @@ static int ipgre_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	    nla_put_u8(skb, IFLA_GRE_PMTUDISC,
 		       !!(p->iph.frag_off & htons(IP_DF))))
 		goto nla_put_failure;
+
+	if (nla_put_u16(skb, IFLA_GRE_ENCAP_TYPE,
+			t->encap.type) ||
+	    nla_put_u16(skb, IFLA_GRE_ENCAP_SPORT,
+			t->encap.sport) ||
+	    nla_put_u16(skb, IFLA_GRE_ENCAP_DPORT,
+			t->encap.dport) ||
+	    nla_put_u16(skb, IFLA_GRE_ENCAP_FLAGS,
+			t->encap.dport))
+		goto nla_put_failure;
+
 	return 0;
 
 nla_put_failure:
@@ -731,6 +807,10 @@ static const struct nla_policy ipgre_policy[IFLA_GRE_MAX + 1] = {
 	[IFLA_GRE_TTL]		= { .type = NLA_U8 },
 	[IFLA_GRE_TOS]		= { .type = NLA_U8 },
 	[IFLA_GRE_PMTUDISC]	= { .type = NLA_U8 },
+	[IFLA_GRE_ENCAP_TYPE]	= { .type = NLA_U16 },
+	[IFLA_GRE_ENCAP_FLAGS]	= { .type = NLA_U16 },
+	[IFLA_GRE_ENCAP_SPORT]	= { .type = NLA_U16 },
+	[IFLA_GRE_ENCAP_DPORT]	= { .type = NLA_U16 },
 };
 
 static struct rtnl_link_ops ipgre_link_ops __read_mostly = {
-- 
2.1.0.rc2.206.gedb03e5
