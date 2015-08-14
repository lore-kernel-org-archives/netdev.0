From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next] lwtunnel: rename ip lwtunnel attributes
Date: Fri, 14 Aug 2015 16:40:40 +0200
Message-ID: <f6abe6522e88ea21d2ccf6e50f9e563fdf8f3a37.1439563196.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41261 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754158AbbHNOlF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Aug 2015 10:41:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We already have IFLA_IPTUN_ netlink attributes. The IP_TUN_ attributes look
very similar, yet they serve very different purpose. This is confusing for
anyone trying to implement a user space tool supporting lwt.

As the IP_TUN_ attributes are used only for the lightweight tunnels, prefix
them with LWTUNNEL_IP_ instead to make their purpose clear. Also, it's more
logical to have them in lwtunnel.h together with the encap enum.

Fixes: 3093fbe7ff4b ("route: Per route IP tunnel metadata via lightweight tunnel")
Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
These are still in net-next only, thus it's safe to change them.

It's still a bit weird these attributes are in RTA_ENCAP, perhaps we should
also rename RTA_ENCAP to RTA_LWT_ENCAP or similar?
---
 include/uapi/linux/lwtunnel.h  | 14 +++++++
 include/uapi/linux/rtnetlink.h | 15 --------
 net/ipv4/ip_tunnel_core.c      | 86 +++++++++++++++++++++---------------------
 3 files changed, 57 insertions(+), 58 deletions(-)

diff --git a/include/uapi/linux/lwtunnel.h b/include/uapi/linux/lwtunnel.h
index 31377bbea3f8..3bf223bc2367 100644
--- a/include/uapi/linux/lwtunnel.h
+++ b/include/uapi/linux/lwtunnel.h
@@ -12,5 +12,19 @@ enum lwtunnel_encap_types {
 
 #define LWTUNNEL_ENCAP_MAX (__LWTUNNEL_ENCAP_MAX - 1)
 
+enum lwtunnel_ip_t {
+	LWTUNNEL_IP_UNSPEC,
+	LWTUNNEL_IP_ID,
+	LWTUNNEL_IP_DST,
+	LWTUNNEL_IP_SRC,
+	LWTUNNEL_IP_TTL,
+	LWTUNNEL_IP_TOS,
+	LWTUNNEL_IP_SPORT,
+	LWTUNNEL_IP_DPORT,
+	LWTUNNEL_IP_FLAGS,
+	__LWTUNNEL_IP_MAX,
+};
+
+#define LWTUNNEL_IP_MAX (__LWTUNNEL_IP_MAX - 1)
 
 #endif /* _UAPI_LWTUNNEL_H_ */
diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 47d24cb3fbc1..0d3d3cc43356 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -286,21 +286,6 @@ enum rt_class_t {
 
 /* Routing message attributes */
 
-enum ip_tunnel_t {
-	IP_TUN_UNSPEC,
-	IP_TUN_ID,
-	IP_TUN_DST,
-	IP_TUN_SRC,
-	IP_TUN_TTL,
-	IP_TUN_TOS,
-	IP_TUN_SPORT,
-	IP_TUN_DPORT,
-	IP_TUN_FLAGS,
-	__IP_TUN_MAX,
-};
-
-#define IP_TUN_MAX (__IP_TUN_MAX - 1)
-
 enum rtattr_type_t {
 	RTA_UNSPEC,
 	RTA_DST,
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 5512f4e4ec1b..fd6319681c50 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -192,15 +192,15 @@ struct rtnl_link_stats64 *ip_tunnel_get_stats64(struct net_device *dev,
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_get_stats64);
 
-static const struct nla_policy ip_tun_policy[IP_TUN_MAX + 1] = {
-	[IP_TUN_ID]		= { .type = NLA_U64 },
-	[IP_TUN_DST]		= { .type = NLA_U32 },
-	[IP_TUN_SRC]		= { .type = NLA_U32 },
-	[IP_TUN_TTL]		= { .type = NLA_U8 },
-	[IP_TUN_TOS]		= { .type = NLA_U8 },
-	[IP_TUN_SPORT]		= { .type = NLA_U16 },
-	[IP_TUN_DPORT]		= { .type = NLA_U16 },
-	[IP_TUN_FLAGS]		= { .type = NLA_U16 },
+static const struct nla_policy ip_tun_policy[LWTUNNEL_IP_MAX + 1] = {
+	[LWTUNNEL_IP_ID]	= { .type = NLA_U64 },
+	[LWTUNNEL_IP_DST]	= { .type = NLA_U32 },
+	[LWTUNNEL_IP_SRC]	= { .type = NLA_U32 },
+	[LWTUNNEL_IP_TTL]	= { .type = NLA_U8 },
+	[LWTUNNEL_IP_TOS]	= { .type = NLA_U8 },
+	[LWTUNNEL_IP_SPORT]	= { .type = NLA_U16 },
+	[LWTUNNEL_IP_DPORT]	= { .type = NLA_U16 },
+	[LWTUNNEL_IP_FLAGS]	= { .type = NLA_U16 },
 };
 
 static int ip_tun_build_state(struct net_device *dev, struct nlattr *attr,
@@ -208,10 +208,10 @@ static int ip_tun_build_state(struct net_device *dev, struct nlattr *attr,
 {
 	struct ip_tunnel_info *tun_info;
 	struct lwtunnel_state *new_state;
-	struct nlattr *tb[IP_TUN_MAX + 1];
+	struct nlattr *tb[LWTUNNEL_IP_MAX + 1];
 	int err;
 
-	err = nla_parse_nested(tb, IP_TUN_MAX, attr, ip_tun_policy);
+	err = nla_parse_nested(tb, LWTUNNEL_IP_MAX, attr, ip_tun_policy);
 	if (err < 0)
 		return err;
 
@@ -223,29 +223,29 @@ static int ip_tun_build_state(struct net_device *dev, struct nlattr *attr,
 
 	tun_info = lwt_tun_info(new_state);
 
-	if (tb[IP_TUN_ID])
-		tun_info->key.tun_id = nla_get_u64(tb[IP_TUN_ID]);
+	if (tb[LWTUNNEL_IP_ID])
+		tun_info->key.tun_id = nla_get_u64(tb[LWTUNNEL_IP_ID]);
 
-	if (tb[IP_TUN_DST])
-		tun_info->key.ipv4_dst = nla_get_be32(tb[IP_TUN_DST]);
+	if (tb[LWTUNNEL_IP_DST])
+		tun_info->key.ipv4_dst = nla_get_be32(tb[LWTUNNEL_IP_DST]);
 
-	if (tb[IP_TUN_SRC])
-		tun_info->key.ipv4_src = nla_get_be32(tb[IP_TUN_SRC]);
+	if (tb[LWTUNNEL_IP_SRC])
+		tun_info->key.ipv4_src = nla_get_be32(tb[LWTUNNEL_IP_SRC]);
 
-	if (tb[IP_TUN_TTL])
-		tun_info->key.ipv4_ttl = nla_get_u8(tb[IP_TUN_TTL]);
+	if (tb[LWTUNNEL_IP_TTL])
+		tun_info->key.ipv4_ttl = nla_get_u8(tb[LWTUNNEL_IP_TTL]);
 
-	if (tb[IP_TUN_TOS])
-		tun_info->key.ipv4_tos = nla_get_u8(tb[IP_TUN_TOS]);
+	if (tb[LWTUNNEL_IP_TOS])
+		tun_info->key.ipv4_tos = nla_get_u8(tb[LWTUNNEL_IP_TOS]);
 
-	if (tb[IP_TUN_SPORT])
-		tun_info->key.tp_src = nla_get_be16(tb[IP_TUN_SPORT]);
+	if (tb[LWTUNNEL_IP_SPORT])
+		tun_info->key.tp_src = nla_get_be16(tb[LWTUNNEL_IP_SPORT]);
 
-	if (tb[IP_TUN_DPORT])
-		tun_info->key.tp_dst = nla_get_be16(tb[IP_TUN_DPORT]);
+	if (tb[LWTUNNEL_IP_DPORT])
+		tun_info->key.tp_dst = nla_get_be16(tb[LWTUNNEL_IP_DPORT]);
 
-	if (tb[IP_TUN_FLAGS])
-		tun_info->key.tun_flags = nla_get_u16(tb[IP_TUN_FLAGS]);
+	if (tb[LWTUNNEL_IP_FLAGS])
+		tun_info->key.tun_flags = nla_get_u16(tb[LWTUNNEL_IP_FLAGS]);
 
 	tun_info->mode = IP_TUNNEL_INFO_TX;
 	tun_info->options = NULL;
@@ -261,14 +261,14 @@ static int ip_tun_fill_encap_info(struct sk_buff *skb,
 {
 	struct ip_tunnel_info *tun_info = lwt_tun_info(lwtstate);
 
-	if (nla_put_u64(skb, IP_TUN_ID, tun_info->key.tun_id) ||
-	    nla_put_be32(skb, IP_TUN_DST, tun_info->key.ipv4_dst) ||
-	    nla_put_be32(skb, IP_TUN_SRC, tun_info->key.ipv4_src) ||
-	    nla_put_u8(skb, IP_TUN_TOS, tun_info->key.ipv4_tos) ||
-	    nla_put_u8(skb, IP_TUN_TTL, tun_info->key.ipv4_ttl) ||
-	    nla_put_u16(skb, IP_TUN_SPORT, tun_info->key.tp_src) ||
-	    nla_put_u16(skb, IP_TUN_DPORT, tun_info->key.tp_dst) ||
-	    nla_put_u16(skb, IP_TUN_FLAGS, tun_info->key.tun_flags))
+	if (nla_put_u64(skb, LWTUNNEL_IP_ID, tun_info->key.tun_id) ||
+	    nla_put_be32(skb, LWTUNNEL_IP_DST, tun_info->key.ipv4_dst) ||
+	    nla_put_be32(skb, LWTUNNEL_IP_SRC, tun_info->key.ipv4_src) ||
+	    nla_put_u8(skb, LWTUNNEL_IP_TOS, tun_info->key.ipv4_tos) ||
+	    nla_put_u8(skb, LWTUNNEL_IP_TTL, tun_info->key.ipv4_ttl) ||
+	    nla_put_u16(skb, LWTUNNEL_IP_SPORT, tun_info->key.tp_src) ||
+	    nla_put_u16(skb, LWTUNNEL_IP_DPORT, tun_info->key.tp_dst) ||
+	    nla_put_u16(skb, LWTUNNEL_IP_FLAGS, tun_info->key.tun_flags))
 		return -ENOMEM;
 
 	return 0;
@@ -276,14 +276,14 @@ static int ip_tun_fill_encap_info(struct sk_buff *skb,
 
 static int ip_tun_encap_nlsize(struct lwtunnel_state *lwtstate)
 {
-	return nla_total_size(8)	/* IP_TUN_ID */
-		+ nla_total_size(4)	/* IP_TUN_DST */
-		+ nla_total_size(4)	/* IP_TUN_SRC */
-		+ nla_total_size(1)	/* IP_TUN_TOS */
-		+ nla_total_size(1)	/* IP_TUN_TTL */
-		+ nla_total_size(2)	/* IP_TUN_SPORT */
-		+ nla_total_size(2)	/* IP_TUN_DPORT */
-		+ nla_total_size(2);	/* IP_TUN_FLAGS */
+	return nla_total_size(8)	/* LWTUNNEL_IP_ID */
+		+ nla_total_size(4)	/* LWTUNNEL_IP_DST */
+		+ nla_total_size(4)	/* LWTUNNEL_IP_SRC */
+		+ nla_total_size(1)	/* LWTUNNEL_IP_TOS */
+		+ nla_total_size(1)	/* LWTUNNEL_IP_TTL */
+		+ nla_total_size(2)	/* LWTUNNEL_IP_SPORT */
+		+ nla_total_size(2)	/* LWTUNNEL_IP_DPORT */
+		+ nla_total_size(2);	/* LWTUNNEL_IP_FLAGS */
 }
 
 static const struct lwtunnel_encap_ops ip_tun_lwt_ops = {
-- 
1.8.3.1
