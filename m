From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 net-next 7/7] gre: TX path for GRE/UDP foo-over-udp encapsulation
Date: Sun, 14 Sep 2014 20:08:03 -0700
Message-ID: <1410750483-3236-8-git-send-email-therbert@google.com>
References: <1410750483-3236-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:55004 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753288AbaIODIh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Sep 2014 23:08:37 -0400
Received: by mail-pa0-f51.google.com with SMTP id kx10so5388840pab.24
        for <netdev@vger.kernel.org>; Sun, 14 Sep 2014 20:08:37 -0700 (PDT)
In-Reply-To: <1410750483-3236-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/uapi/linux/if_tunnel.h |  4 ++
 net/ipv4/ip_gre.c              | 98 +++++++++++++++++++++++++++++++++++++++---
 2 files changed, 95 insertions(+), 7 deletions(-)

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
index 9b84254..5681344 100644
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
@@ -657,18 +696,40 @@ static int ipgre_newlink(struct net *src_net, struct net_device *dev,
 			 struct nlattr *tb[], struct nlattr *data[])
 {
 	struct ip_tunnel_parm p;
+	struct ip_tunnel *nt = netdev_priv(dev);
+	struct ip_tunnel_encap ipencap;
+	int err;
+
+	if (ipgre_netlink_encap_parms(data, &ipencap)) {
+		err = ip_tunnel_encap_setup(nt, &ipencap);
+		if (err < 0)
+			return err;
+	}
 
 	ipgre_netlink_parms(data, tb, &p);
-	return ip_tunnel_newlink(dev, tb, &p);
+	err = ip_tunnel_newlink(dev, tb, &p);
+
+	return err;
 }
 
 static int ipgre_changelink(struct net_device *dev, struct nlattr *tb[],
 			    struct nlattr *data[])
 {
+	struct ip_tunnel *t = netdev_priv(dev);
 	struct ip_tunnel_parm p;
+	struct ip_tunnel_encap ipencap;
+	int err;
+
+	if (ipgre_netlink_encap_parms(data, &ipencap)) {
+		err = ip_tunnel_encap_setup(t, &ipencap);
+		if (err < 0)
+			return err;
+	}
 
 	ipgre_netlink_parms(data, tb, &p);
-	return ip_tunnel_changelink(dev, tb, &p);
+	err = ip_tunnel_changelink(dev, tb, &p);
+
+	return err;
 }
 
 static size_t ipgre_get_size(const struct net_device *dev)
@@ -694,6 +755,14 @@ static size_t ipgre_get_size(const struct net_device *dev)
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
 
@@ -714,6 +783,17 @@ static int ipgre_fill_info(struct sk_buff *skb, const struct net_device *dev)
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
@@ -731,6 +811,10 @@ static const struct nla_policy ipgre_policy[IFLA_GRE_MAX + 1] = {
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
