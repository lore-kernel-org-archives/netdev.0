From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH net-next 2/2] ip_tunnel: Allow policy-based routing through tunnels
Date: Wed, 19 Apr 2017 12:30:54 -0400
Message-ID: <20170419163054.31173-3-kraigatgoog@gmail.com>
References: <20170419163054.31173-1-kraigatgoog@gmail.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f174.google.com ([209.85.216.174]:36264 "EHLO
        mail-qt0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S937957AbdDSQa7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 12:30:59 -0400
Received: by mail-qt0-f174.google.com with SMTP id g60so23660239qtd.3
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 09:30:58 -0700 (PDT)
In-Reply-To: <20170419163054.31173-1-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>

This feature allows the administrator to set an fwmark for
packets traversing a tunnel.  This allows the use of independent
routing tables for tunneled packets without the use of iptables.

There is no concept of per-packet routing decisions through IPv4
tunnels, so this implementation does not need to work with
per-packet route lookups as the v6 implementation may
(with IP6_TNL_F_USE_ORIG_FWMARK).

Further, since the v4 tunnel ioctls share datastructures
(which can not be trivially modified) with the kernel's internal
tunnel configuration structures, the mark attribute must be stored
in the tunnel structure itself and passed as a parameter when
creating or changing tunnel attributes.

Signed-off-by: Craig Gallek <kraig@google.com>
---
 include/net/ip_tunnels.h |  5 +++--
 net/ipv4/ip_gre.c        | 24 +++++++++++++++++-------
 net/ipv4/ip_tunnel.c     | 27 +++++++++++++++++----------
 net/ipv4/ip_vti.c        | 20 +++++++++++++++-----
 net/ipv4/ipip.c          | 24 +++++++++++++++++-------
 net/ipv6/sit.c           | 37 ++++++++++++++++++++++++-------------
 6 files changed, 93 insertions(+), 44 deletions(-)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 95056796657c..520809912f03 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -132,6 +132,7 @@ struct ip_tunnel {
 	unsigned int		prl_count;	/* # of entries in PRL */
 	unsigned int		ip_tnl_net_id;
 	struct gro_cells	gro_cells;
+	__u32			fwmark;
 	bool			collect_md;
 	bool			ignore_df;
 };
@@ -273,9 +274,9 @@ int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct sk_buff *skb,
 		  const struct tnl_ptk_info *tpi, struct metadata_dst *tun_dst,
 		  bool log_ecn_error);
 int ip_tunnel_changelink(struct net_device *dev, struct nlattr *tb[],
-			 struct ip_tunnel_parm *p);
+			 struct ip_tunnel_parm *p, __u32 fwmark);
 int ip_tunnel_newlink(struct net_device *dev, struct nlattr *tb[],
-		      struct ip_tunnel_parm *p);
+		      struct ip_tunnel_parm *p, __u32 fwmark);
 void ip_tunnel_setup(struct net_device *dev, unsigned int net_id);
 
 struct ip_tunnel_encap_ops {
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index c9c1cb635d9a..e90c80a548ad 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -829,7 +829,8 @@ static int ipgre_tap_validate(struct nlattr *tb[], struct nlattr *data[])
 static int ipgre_netlink_parms(struct net_device *dev,
 				struct nlattr *data[],
 				struct nlattr *tb[],
-				struct ip_tunnel_parm *parms)
+				struct ip_tunnel_parm *parms,
+				__u32 *fwmark)
 {
 	struct ip_tunnel *t = netdev_priv(dev);
 
@@ -886,6 +887,9 @@ static int ipgre_netlink_parms(struct net_device *dev,
 		t->ignore_df = !!nla_get_u8(data[IFLA_GRE_IGNORE_DF]);
 	}
 
+	if (data[IFLA_GRE_FWMARK])
+		*fwmark = nla_get_u32(data[IFLA_GRE_FWMARK]);
+
 	return 0;
 }
 
@@ -957,6 +961,7 @@ static int ipgre_newlink(struct net *src_net, struct net_device *dev,
 {
 	struct ip_tunnel_parm p;
 	struct ip_tunnel_encap ipencap;
+	__u32 fwmark = 0;
 	int err;
 
 	if (ipgre_netlink_encap_parms(data, &ipencap)) {
@@ -967,31 +972,32 @@ static int ipgre_newlink(struct net *src_net, struct net_device *dev,
 			return err;
 	}
 
-	err = ipgre_netlink_parms(dev, data, tb, &p);
+	err = ipgre_netlink_parms(dev, data, tb, &p, &fwmark);
 	if (err < 0)
 		return err;
-	return ip_tunnel_newlink(dev, tb, &p);
+	return ip_tunnel_newlink(dev, tb, &p, fwmark);
 }
 
 static int ipgre_changelink(struct net_device *dev, struct nlattr *tb[],
 			    struct nlattr *data[])
 {
+	struct ip_tunnel *t = netdev_priv(dev);
 	struct ip_tunnel_parm p;
 	struct ip_tunnel_encap ipencap;
+	__u32 fwmark = t->fwmark;
 	int err;
 
 	if (ipgre_netlink_encap_parms(data, &ipencap)) {
-		struct ip_tunnel *t = netdev_priv(dev);
 		err = ip_tunnel_encap_setup(t, &ipencap);
 
 		if (err < 0)
 			return err;
 	}
 
-	err = ipgre_netlink_parms(dev, data, tb, &p);
+	err = ipgre_netlink_parms(dev, data, tb, &p, &fwmark);
 	if (err < 0)
 		return err;
-	return ip_tunnel_changelink(dev, tb, &p);
+	return ip_tunnel_changelink(dev, tb, &p, fwmark);
 }
 
 static size_t ipgre_get_size(const struct net_device *dev)
@@ -1029,6 +1035,8 @@ static size_t ipgre_get_size(const struct net_device *dev)
 		nla_total_size(0) +
 		/* IFLA_GRE_IGNORE_DF */
 		nla_total_size(1) +
+		/* IFLA_GRE_FWMARK */
+		nla_total_size(4) +
 		0;
 }
 
@@ -1049,7 +1057,8 @@ static int ipgre_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	    nla_put_u8(skb, IFLA_GRE_TTL, p->iph.ttl) ||
 	    nla_put_u8(skb, IFLA_GRE_TOS, p->iph.tos) ||
 	    nla_put_u8(skb, IFLA_GRE_PMTUDISC,
-		       !!(p->iph.frag_off & htons(IP_DF))))
+		       !!(p->iph.frag_off & htons(IP_DF))) ||
+	    nla_put_u32(skb, IFLA_GRE_FWMARK, t->fwmark))
 		goto nla_put_failure;
 
 	if (nla_put_u16(skb, IFLA_GRE_ENCAP_TYPE,
@@ -1093,6 +1102,7 @@ static const struct nla_policy ipgre_policy[IFLA_GRE_MAX + 1] = {
 	[IFLA_GRE_ENCAP_DPORT]	= { .type = NLA_U16 },
 	[IFLA_GRE_COLLECT_METADATA]	= { .type = NLA_FLAG },
 	[IFLA_GRE_IGNORE_DF]	= { .type = NLA_U8 },
+	[IFLA_GRE_FWMARK]	= { .type = NLA_U32 },
 };
 
 static struct rtnl_link_ops ipgre_link_ops __read_mostly = {
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 823abaef006b..b878ecbc0608 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -293,7 +293,8 @@ static struct net_device *__ip_tunnel_create(struct net *net,
 static inline void init_tunnel_flow(struct flowi4 *fl4,
 				    int proto,
 				    __be32 daddr, __be32 saddr,
-				    __be32 key, __u8 tos, int oif)
+				    __be32 key, __u8 tos, int oif,
+				    __u32 mark)
 {
 	memset(fl4, 0, sizeof(*fl4));
 	fl4->flowi4_oif = oif;
@@ -302,6 +303,7 @@ static inline void init_tunnel_flow(struct flowi4 *fl4,
 	fl4->flowi4_tos = tos;
 	fl4->flowi4_proto = proto;
 	fl4->fl4_gre_key = key;
+	fl4->flowi4_mark = mark;
 }
 
 static int ip_tunnel_bind_dev(struct net_device *dev)
@@ -322,7 +324,8 @@ static int ip_tunnel_bind_dev(struct net_device *dev)
 
 		init_tunnel_flow(&fl4, iph->protocol, iph->daddr,
 				 iph->saddr, tunnel->parms.o_key,
-				 RT_TOS(iph->tos), tunnel->parms.link);
+				 RT_TOS(iph->tos), tunnel->parms.link,
+				 tunnel->fwmark);
 		rt = ip_route_output_key(tunnel->net, &fl4);
 
 		if (!IS_ERR(rt)) {
@@ -578,7 +581,7 @@ void ip_md_tunnel_xmit(struct sk_buff *skb, struct net_device *dev, u8 proto)
 			tos = ipv6_get_dsfield((const struct ipv6hdr *)inner_iph);
 	}
 	init_tunnel_flow(&fl4, proto, key->u.ipv4.dst, key->u.ipv4.src, 0,
-			 RT_TOS(tos), tunnel->parms.link);
+			 RT_TOS(tos), tunnel->parms.link, tunnel->fwmark);
 	if (tunnel->encap.type != TUNNEL_ENCAP_NONE)
 		goto tx_error;
 	rt = ip_route_output_key(tunnel->net, &fl4);
@@ -707,7 +710,8 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 	}
 
 	init_tunnel_flow(&fl4, protocol, dst, tnl_params->saddr,
-			 tunnel->parms.o_key, RT_TOS(tos), tunnel->parms.link);
+			 tunnel->parms.o_key, RT_TOS(tos), tunnel->parms.link,
+			 tunnel->fwmark);
 
 	if (ip_tunnel_encap(skb, tunnel, &protocol, &fl4) < 0)
 		goto tx_error;
@@ -795,7 +799,8 @@ static void ip_tunnel_update(struct ip_tunnel_net *itn,
 			     struct ip_tunnel *t,
 			     struct net_device *dev,
 			     struct ip_tunnel_parm *p,
-			     bool set_mtu)
+			     bool set_mtu,
+			     __u32 fwmark)
 {
 	ip_tunnel_del(itn, t);
 	t->parms.iph.saddr = p->iph.saddr;
@@ -812,10 +817,11 @@ static void ip_tunnel_update(struct ip_tunnel_net *itn,
 	t->parms.iph.tos = p->iph.tos;
 	t->parms.iph.frag_off = p->iph.frag_off;
 
-	if (t->parms.link != p->link) {
+	if (t->parms.link != p->link || t->fwmark != fwmark) {
 		int mtu;
 
 		t->parms.link = p->link;
+		t->fwmark = fwmark;
 		mtu = ip_tunnel_bind_dev(dev);
 		if (set_mtu)
 			dev->mtu = mtu;
@@ -893,7 +899,7 @@ int ip_tunnel_ioctl(struct net_device *dev, struct ip_tunnel_parm *p, int cmd)
 
 		if (t) {
 			err = 0;
-			ip_tunnel_update(itn, t, dev, p, true);
+			ip_tunnel_update(itn, t, dev, p, true, 0);
 		} else {
 			err = -ENOENT;
 		}
@@ -1066,7 +1072,7 @@ void ip_tunnel_delete_net(struct ip_tunnel_net *itn, struct rtnl_link_ops *ops)
 EXPORT_SYMBOL_GPL(ip_tunnel_delete_net);
 
 int ip_tunnel_newlink(struct net_device *dev, struct nlattr *tb[],
-		      struct ip_tunnel_parm *p)
+		      struct ip_tunnel_parm *p, __u32 fwmark)
 {
 	struct ip_tunnel *nt;
 	struct net *net = dev_net(dev);
@@ -1087,6 +1093,7 @@ int ip_tunnel_newlink(struct net_device *dev, struct nlattr *tb[],
 
 	nt->net = net;
 	nt->parms = *p;
+	nt->fwmark = fwmark;
 	err = register_netdevice(dev);
 	if (err)
 		goto out;
@@ -1105,7 +1112,7 @@ int ip_tunnel_newlink(struct net_device *dev, struct nlattr *tb[],
 EXPORT_SYMBOL_GPL(ip_tunnel_newlink);
 
 int ip_tunnel_changelink(struct net_device *dev, struct nlattr *tb[],
-			 struct ip_tunnel_parm *p)
+			 struct ip_tunnel_parm *p, __u32 fwmark)
 {
 	struct ip_tunnel *t;
 	struct ip_tunnel *tunnel = netdev_priv(dev);
@@ -1137,7 +1144,7 @@ int ip_tunnel_changelink(struct net_device *dev, struct nlattr *tb[],
 		}
 	}
 
-	ip_tunnel_update(itn, t, dev, p, !tb[IFLA_MTU]);
+	ip_tunnel_update(itn, t, dev, p, !tb[IFLA_MTU], fwmark);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_changelink);
diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 8b14f1404c8f..40977413fd48 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -471,7 +471,8 @@ static int vti_tunnel_validate(struct nlattr *tb[], struct nlattr *data[])
 }
 
 static void vti_netlink_parms(struct nlattr *data[],
-			      struct ip_tunnel_parm *parms)
+			      struct ip_tunnel_parm *parms,
+			      __u32 *fwmark)
 {
 	memset(parms, 0, sizeof(*parms));
 
@@ -497,24 +498,29 @@ static void vti_netlink_parms(struct nlattr *data[],
 	if (data[IFLA_VTI_REMOTE])
 		parms->iph.daddr = nla_get_in_addr(data[IFLA_VTI_REMOTE]);
 
+	if (data[IFLA_VTI_FWMARK])
+		*fwmark = nla_get_u32(data[IFLA_VTI_FWMARK]);
 }
 
 static int vti_newlink(struct net *src_net, struct net_device *dev,
 		       struct nlattr *tb[], struct nlattr *data[])
 {
 	struct ip_tunnel_parm parms;
+	__u32 fwmark = 0;
 
-	vti_netlink_parms(data, &parms);
-	return ip_tunnel_newlink(dev, tb, &parms);
+	vti_netlink_parms(data, &parms, &fwmark);
+	return ip_tunnel_newlink(dev, tb, &parms, fwmark);
 }
 
 static int vti_changelink(struct net_device *dev, struct nlattr *tb[],
 			  struct nlattr *data[])
 {
+	struct ip_tunnel *t = netdev_priv(dev);
+	__u32 fwmark = t->fwmark;
 	struct ip_tunnel_parm p;
 
-	vti_netlink_parms(data, &p);
-	return ip_tunnel_changelink(dev, tb, &p);
+	vti_netlink_parms(data, &p, &fwmark);
+	return ip_tunnel_changelink(dev, tb, &p, fwmark);
 }
 
 static size_t vti_get_size(const struct net_device *dev)
@@ -530,6 +536,8 @@ static size_t vti_get_size(const struct net_device *dev)
 		nla_total_size(4) +
 		/* IFLA_VTI_REMOTE */
 		nla_total_size(4) +
+		/* IFLA_VTI_FWMARK */
+		nla_total_size(4) +
 		0;
 }
 
@@ -543,6 +551,7 @@ static int vti_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	nla_put_be32(skb, IFLA_VTI_OKEY, p->o_key);
 	nla_put_in_addr(skb, IFLA_VTI_LOCAL, p->iph.saddr);
 	nla_put_in_addr(skb, IFLA_VTI_REMOTE, p->iph.daddr);
+	nla_put_u32(skb, IFLA_VTI_FWMARK, t->fwmark);
 
 	return 0;
 }
@@ -553,6 +562,7 @@ static const struct nla_policy vti_policy[IFLA_VTI_MAX + 1] = {
 	[IFLA_VTI_OKEY]		= { .type = NLA_U32 },
 	[IFLA_VTI_LOCAL]	= { .len = FIELD_SIZEOF(struct iphdr, saddr) },
 	[IFLA_VTI_REMOTE]	= { .len = FIELD_SIZEOF(struct iphdr, daddr) },
+	[IFLA_VTI_FWMARK]	= { .type = NLA_U32 },
 };
 
 static struct rtnl_link_ops vti_link_ops __read_mostly = {
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 00d4229b6954..1e441c6f2160 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -390,7 +390,8 @@ static int ipip_tunnel_validate(struct nlattr *tb[], struct nlattr *data[])
 }
 
 static void ipip_netlink_parms(struct nlattr *data[],
-			       struct ip_tunnel_parm *parms, bool *collect_md)
+			       struct ip_tunnel_parm *parms, bool *collect_md,
+			       __u32 *fwmark)
 {
 	memset(parms, 0, sizeof(*parms));
 
@@ -428,6 +429,9 @@ static void ipip_netlink_parms(struct nlattr *data[],
 
 	if (data[IFLA_IPTUN_COLLECT_METADATA])
 		*collect_md = true;
+
+	if (data[IFLA_IPTUN_FWMARK])
+		*fwmark = nla_get_u32(data[IFLA_IPTUN_FWMARK]);
 }
 
 /* This function returns true when ENCAP attributes are present in the nl msg */
@@ -470,6 +474,7 @@ static int ipip_newlink(struct net *src_net, struct net_device *dev,
 	struct ip_tunnel *t = netdev_priv(dev);
 	struct ip_tunnel_parm p;
 	struct ip_tunnel_encap ipencap;
+	__u32 fwmark = 0;
 
 	if (ipip_netlink_encap_parms(data, &ipencap)) {
 		int err = ip_tunnel_encap_setup(t, &ipencap);
@@ -478,26 +483,27 @@ static int ipip_newlink(struct net *src_net, struct net_device *dev,
 			return err;
 	}
 
-	ipip_netlink_parms(data, &p, &t->collect_md);
-	return ip_tunnel_newlink(dev, tb, &p);
+	ipip_netlink_parms(data, &p, &t->collect_md, &fwmark);
+	return ip_tunnel_newlink(dev, tb, &p, fwmark);
 }
 
 static int ipip_changelink(struct net_device *dev, struct nlattr *tb[],
 			   struct nlattr *data[])
 {
+	struct ip_tunnel *t = netdev_priv(dev);
 	struct ip_tunnel_parm p;
 	struct ip_tunnel_encap ipencap;
 	bool collect_md;
+	__u32 fwmark = t->fwmark;
 
 	if (ipip_netlink_encap_parms(data, &ipencap)) {
-		struct ip_tunnel *t = netdev_priv(dev);
 		int err = ip_tunnel_encap_setup(t, &ipencap);
 
 		if (err < 0)
 			return err;
 	}
 
-	ipip_netlink_parms(data, &p, &collect_md);
+	ipip_netlink_parms(data, &p, &collect_md, &fwmark);
 	if (collect_md)
 		return -EINVAL;
 
@@ -505,7 +511,7 @@ static int ipip_changelink(struct net_device *dev, struct nlattr *tb[],
 	    (!(dev->flags & IFF_POINTOPOINT) && p.iph.daddr))
 		return -EINVAL;
 
-	return ip_tunnel_changelink(dev, tb, &p);
+	return ip_tunnel_changelink(dev, tb, &p, fwmark);
 }
 
 static size_t ipip_get_size(const struct net_device *dev)
@@ -535,6 +541,8 @@ static size_t ipip_get_size(const struct net_device *dev)
 		nla_total_size(2) +
 		/* IFLA_IPTUN_COLLECT_METADATA */
 		nla_total_size(0) +
+		/* IFLA_IPTUN_FWMARK */
+		nla_total_size(4) +
 		0;
 }
 
@@ -550,7 +558,8 @@ static int ipip_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	    nla_put_u8(skb, IFLA_IPTUN_TOS, parm->iph.tos) ||
 	    nla_put_u8(skb, IFLA_IPTUN_PROTO, parm->iph.protocol) ||
 	    nla_put_u8(skb, IFLA_IPTUN_PMTUDISC,
-		       !!(parm->iph.frag_off & htons(IP_DF))))
+		       !!(parm->iph.frag_off & htons(IP_DF))) ||
+	    nla_put_u32(skb, IFLA_IPTUN_FWMARK, tunnel->fwmark))
 		goto nla_put_failure;
 
 	if (nla_put_u16(skb, IFLA_IPTUN_ENCAP_TYPE,
@@ -585,6 +594,7 @@ static const struct nla_policy ipip_policy[IFLA_IPTUN_MAX + 1] = {
 	[IFLA_IPTUN_ENCAP_SPORT]	= { .type = NLA_U16 },
 	[IFLA_IPTUN_ENCAP_DPORT]	= { .type = NLA_U16 },
 	[IFLA_IPTUN_COLLECT_METADATA]	= { .type = NLA_FLAG },
+	[IFLA_IPTUN_FWMARK]		= { .type = NLA_U32 },
 };
 
 static struct rtnl_link_ops ipip_link_ops __read_mostly = {
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 99853c6e33a8..61e5902f0687 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -881,11 +881,12 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 			goto tx_error;
 	}
 
-	rt = ip_route_output_ports(tunnel->net, &fl4, NULL,
-				   dst, tiph->saddr,
-				   0, 0,
-				   IPPROTO_IPV6, RT_TOS(tos),
-				   tunnel->parms.link);
+	flowi4_init_output(&fl4, tunnel->parms.link, tunnel->fwmark,
+			   RT_TOS(tos), RT_SCOPE_UNIVERSE, IPPROTO_IPV6,
+			   0, dst, tiph->saddr, 0, 0,
+			   sock_net_uid(tunnel->net, NULL));
+	rt = ip_route_output_flow(tunnel->net, &fl4, NULL);
+
 	if (IS_ERR(rt)) {
 		dev->stats.tx_carrier_errors++;
 		goto tx_error_icmp;
@@ -1071,7 +1072,8 @@ static void ipip6_tunnel_bind_dev(struct net_device *dev)
 	}
 }
 
-static void ipip6_tunnel_update(struct ip_tunnel *t, struct ip_tunnel_parm *p)
+static void ipip6_tunnel_update(struct ip_tunnel *t, struct ip_tunnel_parm *p,
+				__u32 fwmark)
 {
 	struct net *net = t->net;
 	struct sit_net *sitn = net_generic(net, sit_net_id);
@@ -1085,8 +1087,9 @@ static void ipip6_tunnel_update(struct ip_tunnel *t, struct ip_tunnel_parm *p)
 	ipip6_tunnel_link(sitn, t);
 	t->parms.iph.ttl = p->iph.ttl;
 	t->parms.iph.tos = p->iph.tos;
-	if (t->parms.link != p->link) {
+	if (t->parms.link != p->link || t->fwmark != fwmark) {
 		t->parms.link = p->link;
+		t->fwmark = fwmark;
 		ipip6_tunnel_bind_dev(t->dev);
 	}
 	dst_cache_reset(&t->dst_cache);
@@ -1220,7 +1223,7 @@ ipip6_tunnel_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 				t = netdev_priv(dev);
 			}
 
-			ipip6_tunnel_update(t, &p);
+			ipip6_tunnel_update(t, &p, t->fwmark);
 		}
 
 		if (t) {
@@ -1418,7 +1421,8 @@ static int ipip6_validate(struct nlattr *tb[], struct nlattr *data[])
 }
 
 static void ipip6_netlink_parms(struct nlattr *data[],
-				struct ip_tunnel_parm *parms)
+				struct ip_tunnel_parm *parms,
+				__u32 *fwmark)
 {
 	memset(parms, 0, sizeof(*parms));
 
@@ -1457,6 +1461,8 @@ static void ipip6_netlink_parms(struct nlattr *data[],
 	if (data[IFLA_IPTUN_PROTO])
 		parms->iph.protocol = nla_get_u8(data[IFLA_IPTUN_PROTO]);
 
+	if (data[IFLA_IPTUN_FWMARK])
+		*fwmark = nla_get_u32(data[IFLA_IPTUN_FWMARK]);
 }
 
 /* This function returns true when ENCAP attributes are present in the nl msg */
@@ -1549,7 +1555,7 @@ static int ipip6_newlink(struct net *src_net, struct net_device *dev,
 			return err;
 	}
 
-	ipip6_netlink_parms(data, &nt->parms);
+	ipip6_netlink_parms(data, &nt->parms, &nt->fwmark);
 
 	if (ipip6_tunnel_locate(net, &nt->parms, 0))
 		return -EEXIST;
@@ -1577,6 +1583,7 @@ static int ipip6_changelink(struct net_device *dev, struct nlattr *tb[],
 #ifdef CONFIG_IPV6_SIT_6RD
 	struct ip_tunnel_6rd ip6rd;
 #endif
+	__u32 fwmark = t->fwmark;
 	int err;
 
 	if (dev == sitn->fb_tunnel_dev)
@@ -1588,7 +1595,7 @@ static int ipip6_changelink(struct net_device *dev, struct nlattr *tb[],
 			return err;
 	}
 
-	ipip6_netlink_parms(data, &p);
+	ipip6_netlink_parms(data, &p, &fwmark);
 
 	if (((dev->flags & IFF_POINTOPOINT) && !p.iph.daddr) ||
 	    (!(dev->flags & IFF_POINTOPOINT) && p.iph.daddr))
@@ -1602,7 +1609,7 @@ static int ipip6_changelink(struct net_device *dev, struct nlattr *tb[],
 	} else
 		t = netdev_priv(dev);
 
-	ipip6_tunnel_update(t, &p);
+	ipip6_tunnel_update(t, &p, fwmark);
 
 #ifdef CONFIG_IPV6_SIT_6RD
 	if (ipip6_netlink_6rd_parms(data, &ip6rd))
@@ -1649,6 +1656,8 @@ static size_t ipip6_get_size(const struct net_device *dev)
 		nla_total_size(2) +
 		/* IFLA_IPTUN_ENCAP_DPORT */
 		nla_total_size(2) +
+		/* IFLA_IPTUN_FWMARK */
+		nla_total_size(4) +
 		0;
 }
 
@@ -1665,7 +1674,8 @@ static int ipip6_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	    nla_put_u8(skb, IFLA_IPTUN_PMTUDISC,
 		       !!(parm->iph.frag_off & htons(IP_DF))) ||
 	    nla_put_u8(skb, IFLA_IPTUN_PROTO, parm->iph.protocol) ||
-	    nla_put_be16(skb, IFLA_IPTUN_FLAGS, parm->i_flags))
+	    nla_put_be16(skb, IFLA_IPTUN_FLAGS, parm->i_flags) ||
+	    nla_put_u32(skb, IFLA_IPTUN_FWMARK, tunnel->fwmark))
 		goto nla_put_failure;
 
 #ifdef CONFIG_IPV6_SIT_6RD
@@ -1715,6 +1725,7 @@ static const struct nla_policy ipip6_policy[IFLA_IPTUN_MAX + 1] = {
 	[IFLA_IPTUN_ENCAP_FLAGS]	= { .type = NLA_U16 },
 	[IFLA_IPTUN_ENCAP_SPORT]	= { .type = NLA_U16 },
 	[IFLA_IPTUN_ENCAP_DPORT]	= { .type = NLA_U16 },
+	[IFLA_IPTUN_FWMARK]		= { .type = NLA_U32 },
 };
 
 static void ipip6_dellink(struct net_device *dev, struct list_head *head)
-- 
2.12.2.816.g2cccc81164-goog
