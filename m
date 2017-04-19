From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH net-next 1/2] ip6_tunnel: Allow policy-based routing through tunnels
Date: Wed, 19 Apr 2017 12:30:53 -0400
Message-ID: <20170419163054.31173-2-kraigatgoog@gmail.com>
References: <20170419163054.31173-1-kraigatgoog@gmail.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f179.google.com ([209.85.216.179]:35095 "EHLO
        mail-qt0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S937925AbdDSQa5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 12:30:57 -0400
Received: by mail-qt0-f179.google.com with SMTP id y33so23637122qta.2
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 09:30:57 -0700 (PDT)
In-Reply-To: <20170419163054.31173-1-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>

This feature allows the administrator to set an fwmark for
packets traversing a tunnel.  This allows the use of independent
routing tables for tunneled packets without the use of iptables.

Signed-off-by: Craig Gallek <kraig@google.com>
---
 include/net/ip6_tunnel.h       |  2 ++
 include/uapi/linux/if_tunnel.h |  3 +++
 net/ipv6/ip6_gre.c             | 14 +++++++++++++-
 net/ipv6/ip6_tunnel.c          | 15 ++++++++++++++-
 net/ipv6/ip6_vti.c             | 10 +++++++++-
 5 files changed, 41 insertions(+), 3 deletions(-)

diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index 1b1cf33cbfb0..08fbc7f7d8d7 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -33,6 +33,8 @@ struct __ip6_tnl_parm {
 	__be16			o_flags;
 	__be32			i_key;
 	__be32			o_key;
+
+	__u32			fwmark;
 };
 
 /* IPv6 tunnel */
diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_tunnel.h
index 92f3c8677523..6792d1967d31 100644
--- a/include/uapi/linux/if_tunnel.h
+++ b/include/uapi/linux/if_tunnel.h
@@ -75,6 +75,7 @@ enum {
 	IFLA_IPTUN_ENCAP_SPORT,
 	IFLA_IPTUN_ENCAP_DPORT,
 	IFLA_IPTUN_COLLECT_METADATA,
+	IFLA_IPTUN_FWMARK,
 	__IFLA_IPTUN_MAX,
 };
 #define IFLA_IPTUN_MAX	(__IFLA_IPTUN_MAX - 1)
@@ -132,6 +133,7 @@ enum {
 	IFLA_GRE_ENCAP_DPORT,
 	IFLA_GRE_COLLECT_METADATA,
 	IFLA_GRE_IGNORE_DF,
+	IFLA_GRE_FWMARK,
 	__IFLA_GRE_MAX,
 };
 
@@ -147,6 +149,7 @@ enum {
 	IFLA_VTI_OKEY,
 	IFLA_VTI_LOCAL,
 	IFLA_VTI_REMOTE,
+	IFLA_VTI_FWMARK,
 	__IFLA_VTI_MAX,
 };
 
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 6fcb7cb49bb2..8d128ba79b66 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -544,6 +544,8 @@ static inline int ip6gre_xmit_ipv4(struct sk_buff *skb, struct net_device *dev)
 					  & IPV6_TCLASS_MASK;
 	if (t->parms.flags & IP6_TNL_F_USE_ORIG_FWMARK)
 		fl6.flowi6_mark = skb->mark;
+	else
+		fl6.flowi6_mark = t->parms.fwmark;
 
 	fl6.flowi6_uid = sock_net_uid(dev_net(dev), NULL);
 
@@ -603,6 +605,8 @@ static inline int ip6gre_xmit_ipv6(struct sk_buff *skb, struct net_device *dev)
 		fl6.flowlabel |= ip6_flowlabel(ipv6h);
 	if (t->parms.flags & IP6_TNL_F_USE_ORIG_FWMARK)
 		fl6.flowi6_mark = skb->mark;
+	else
+		fl6.flowi6_mark = t->parms.fwmark;
 
 	fl6.flowi6_uid = sock_net_uid(dev_net(dev), NULL);
 
@@ -780,6 +784,7 @@ static int ip6gre_tnl_change(struct ip6_tnl *t,
 	t->parms.o_key = p->o_key;
 	t->parms.i_flags = p->i_flags;
 	t->parms.o_flags = p->o_flags;
+	t->parms.fwmark = p->fwmark;
 	dst_cache_reset(&t->dst_cache);
 	ip6gre_tnl_link_config(t, set_mtu);
 	return 0;
@@ -1249,6 +1254,9 @@ static void ip6gre_netlink_parms(struct nlattr *data[],
 
 	if (data[IFLA_GRE_FLAGS])
 		parms->flags = nla_get_u32(data[IFLA_GRE_FLAGS]);
+
+	if (data[IFLA_GRE_FWMARK])
+		parms->fwmark = nla_get_u32(data[IFLA_GRE_FWMARK]);
 }
 
 static int ip6gre_tap_init(struct net_device *dev)
@@ -1470,6 +1478,8 @@ static size_t ip6gre_get_size(const struct net_device *dev)
 		nla_total_size(2) +
 		/* IFLA_GRE_ENCAP_DPORT */
 		nla_total_size(2) +
+		/* IFLA_GRE_FWMARK */
+		nla_total_size(4) +
 		0;
 }
 
@@ -1490,7 +1500,8 @@ static int ip6gre_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	    nla_put_u8(skb, IFLA_GRE_TTL, p->hop_limit) ||
 	    nla_put_u8(skb, IFLA_GRE_ENCAP_LIMIT, p->encap_limit) ||
 	    nla_put_be32(skb, IFLA_GRE_FLOWINFO, p->flowinfo) ||
-	    nla_put_u32(skb, IFLA_GRE_FLAGS, p->flags))
+	    nla_put_u32(skb, IFLA_GRE_FLAGS, p->flags) ||
+	    nla_put_u32(skb, IFLA_GRE_FWMARK, p->fwmark))
 		goto nla_put_failure;
 
 	if (nla_put_u16(skb, IFLA_GRE_ENCAP_TYPE,
@@ -1525,6 +1536,7 @@ static const struct nla_policy ip6gre_policy[IFLA_GRE_MAX + 1] = {
 	[IFLA_GRE_ENCAP_FLAGS]  = { .type = NLA_U16 },
 	[IFLA_GRE_ENCAP_SPORT]  = { .type = NLA_U16 },
 	[IFLA_GRE_ENCAP_DPORT]  = { .type = NLA_U16 },
+	[IFLA_GRE_FWMARK]       = { .type = NLA_U32 },
 };
 
 static struct rtnl_link_ops ip6gre_link_ops __read_mostly = {
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 75fac933c209..ad15d38b41e8 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1256,6 +1256,8 @@ ip4ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 					 & IPV6_TCLASS_MASK;
 		if (t->parms.flags & IP6_TNL_F_USE_ORIG_FWMARK)
 			fl6.flowi6_mark = skb->mark;
+		else
+			fl6.flowi6_mark = t->parms.fwmark;
 	}
 
 	fl6.flowi6_uid = sock_net_uid(dev_net(dev), NULL);
@@ -1338,6 +1340,8 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 			fl6.flowlabel |= ip6_flowlabel(ipv6h);
 		if (t->parms.flags & IP6_TNL_F_USE_ORIG_FWMARK)
 			fl6.flowi6_mark = skb->mark;
+		else
+			fl6.flowi6_mark = t->parms.fwmark;
 	}
 
 	fl6.flowi6_uid = sock_net_uid(dev_net(dev), NULL);
@@ -1467,6 +1471,7 @@ ip6_tnl_change(struct ip6_tnl *t, const struct __ip6_tnl_parm *p)
 	t->parms.flowinfo = p->flowinfo;
 	t->parms.link = p->link;
 	t->parms.proto = p->proto;
+	t->parms.fwmark = p->fwmark;
 	dst_cache_reset(&t->dst_cache);
 	ip6_tnl_link_config(t);
 	return 0;
@@ -1918,6 +1923,9 @@ static void ip6_tnl_netlink_parms(struct nlattr *data[],
 
 	if (data[IFLA_IPTUN_COLLECT_METADATA])
 		parms->collect_md = true;
+
+	if (data[IFLA_IPTUN_FWMARK])
+		parms->fwmark = nla_get_u32(data[IFLA_IPTUN_FWMARK]);
 }
 
 static bool ip6_tnl_netlink_encap_parms(struct nlattr *data[],
@@ -2054,6 +2062,8 @@ static size_t ip6_tnl_get_size(const struct net_device *dev)
 		nla_total_size(2) +
 		/* IFLA_IPTUN_COLLECT_METADATA */
 		nla_total_size(0) +
+		/* IFLA_IPTUN_FWMARK */
+		nla_total_size(4) +
 		0;
 }
 
@@ -2069,7 +2079,8 @@ static int ip6_tnl_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	    nla_put_u8(skb, IFLA_IPTUN_ENCAP_LIMIT, parm->encap_limit) ||
 	    nla_put_be32(skb, IFLA_IPTUN_FLOWINFO, parm->flowinfo) ||
 	    nla_put_u32(skb, IFLA_IPTUN_FLAGS, parm->flags) ||
-	    nla_put_u8(skb, IFLA_IPTUN_PROTO, parm->proto))
+	    nla_put_u8(skb, IFLA_IPTUN_PROTO, parm->proto) ||
+	    nla_put_u32(skb, IFLA_IPTUN_FWMARK, parm->fwmark))
 		goto nla_put_failure;
 
 	if (nla_put_u16(skb, IFLA_IPTUN_ENCAP_TYPE, tunnel->encap.type) ||
@@ -2081,6 +2092,7 @@ static int ip6_tnl_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	if (parm->collect_md)
 		if (nla_put_flag(skb, IFLA_IPTUN_COLLECT_METADATA))
 			goto nla_put_failure;
+
 	return 0;
 
 nla_put_failure:
@@ -2109,6 +2121,7 @@ static const struct nla_policy ip6_tnl_policy[IFLA_IPTUN_MAX + 1] = {
 	[IFLA_IPTUN_ENCAP_SPORT]	= { .type = NLA_U16 },
 	[IFLA_IPTUN_ENCAP_DPORT]	= { .type = NLA_U16 },
 	[IFLA_IPTUN_COLLECT_METADATA]	= { .type = NLA_FLAG },
+	[IFLA_IPTUN_FWMARK]		= { .type = NLA_U32 },
 };
 
 static struct rtnl_link_ops ip6_link_ops __read_mostly = {
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index 3d8a3b63b4fd..d67ef56454b2 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -657,6 +657,7 @@ vti6_tnl_change(struct ip6_tnl *t, const struct __ip6_tnl_parm *p)
 	t->parms.i_key = p->i_key;
 	t->parms.o_key = p->o_key;
 	t->parms.proto = p->proto;
+	t->parms.fwmark = p->fwmark;
 	dst_cache_reset(&t->dst_cache);
 	vti6_link_config(t);
 	return 0;
@@ -933,6 +934,9 @@ static void vti6_netlink_parms(struct nlattr *data[],
 
 	if (data[IFLA_VTI_OKEY])
 		parms->o_key = nla_get_be32(data[IFLA_VTI_OKEY]);
+
+	if (data[IFLA_VTI_FWMARK])
+		parms->fwmark = nla_get_u32(data[IFLA_VTI_FWMARK]);
 }
 
 static int vti6_newlink(struct net *src_net, struct net_device *dev,
@@ -998,6 +1002,8 @@ static size_t vti6_get_size(const struct net_device *dev)
 		nla_total_size(4) +
 		/* IFLA_VTI_OKEY */
 		nla_total_size(4) +
+		/* IFLA_VTI_FWMARK */
+		nla_total_size(4) +
 		0;
 }
 
@@ -1010,7 +1016,8 @@ static int vti6_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	    nla_put_in6_addr(skb, IFLA_VTI_LOCAL, &parm->laddr) ||
 	    nla_put_in6_addr(skb, IFLA_VTI_REMOTE, &parm->raddr) ||
 	    nla_put_be32(skb, IFLA_VTI_IKEY, parm->i_key) ||
-	    nla_put_be32(skb, IFLA_VTI_OKEY, parm->o_key))
+	    nla_put_be32(skb, IFLA_VTI_OKEY, parm->o_key) ||
+	    nla_put_u32(skb, IFLA_VTI_FWMARK, parm->fwmark))
 		goto nla_put_failure;
 	return 0;
 
@@ -1024,6 +1031,7 @@ static const struct nla_policy vti6_policy[IFLA_VTI_MAX + 1] = {
 	[IFLA_VTI_REMOTE]	= { .len = sizeof(struct in6_addr) },
 	[IFLA_VTI_IKEY]		= { .type = NLA_U32 },
 	[IFLA_VTI_OKEY]		= { .type = NLA_U32 },
+	[IFLA_VTI_FWMARK]	= { .type = NLA_U32 },
 };
 
 static struct rtnl_link_ops vti6_link_ops __read_mostly = {
-- 
2.12.2.816.g2cccc81164-goog
