From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 13/13] ipv6: route: per route IP tunnel metadata via lightweight tunnel
Date: Tue, 18 Aug 2015 22:33:22 +0200
Message-ID: <290267a07c2a34e2c51af673e04a727bd0baaebc.1439929916.git.jbenc@redhat.com>
References: <cover.1439929916.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46944 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753471AbbHRUdz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 16:33:55 -0400
In-Reply-To: <cover.1439929916.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow specification of per route IP tunnel instructions also for IPv6.
This complements commit 3093fbe7ff4b ("route: Per route IP tunnel metadata
via lightweight tunnel").

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 include/uapi/linux/lwtunnel.h |  16 +++++++
 net/ipv4/ip_tunnel_core.c     | 102 ++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 118 insertions(+)

diff --git a/include/uapi/linux/lwtunnel.h b/include/uapi/linux/lwtunnel.h
index aa84ca396bcb..32a149571417 100644
--- a/include/uapi/linux/lwtunnel.h
+++ b/include/uapi/linux/lwtunnel.h
@@ -7,6 +7,7 @@ enum lwtunnel_encap_types {
 	LWTUNNEL_ENCAP_NONE,
 	LWTUNNEL_ENCAP_MPLS,
 	LWTUNNEL_ENCAP_IP,
+	LWTUNNEL_ENCAP_IP6,
 	LWTUNNEL_ENCAP_ILA,
 	__LWTUNNEL_ENCAP_MAX,
 };
@@ -28,4 +29,19 @@ enum lwtunnel_ip_t {
 
 #define LWTUNNEL_IP_MAX (__LWTUNNEL_IP_MAX - 1)
 
+enum lwtunnel_ip6_t {
+	LWTUNNEL_IP6_UNSPEC,
+	LWTUNNEL_IP6_ID,
+	LWTUNNEL_IP6_DST,
+	LWTUNNEL_IP6_SRC,
+	LWTUNNEL_IP6_HOPLIMIT,
+	LWTUNNEL_IP6_TC,
+	LWTUNNEL_IP6_SPORT,
+	LWTUNNEL_IP6_DPORT,
+	LWTUNNEL_IP6_FLAGS,
+	__LWTUNNEL_IP6_MAX,
+};
+
+#define LWTUNNEL_IP6_MAX (__LWTUNNEL_IP6_MAX - 1)
+
 #endif /* _UAPI_LWTUNNEL_H_ */
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index f0514e39e57c..289b6c26ce37 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -299,9 +299,111 @@ static const struct lwtunnel_encap_ops ip_tun_lwt_ops = {
 	.cmp_encap = ip_tun_cmp_encap,
 };
 
+static const struct nla_policy ip6_tun_policy[LWTUNNEL_IP6_MAX + 1] = {
+	[LWTUNNEL_IP6_ID]		= { .type = NLA_U64 },
+	[LWTUNNEL_IP6_DST]		= { .len = sizeof(struct in6_addr) },
+	[LWTUNNEL_IP6_SRC]		= { .len = sizeof(struct in6_addr) },
+	[LWTUNNEL_IP6_HOPLIMIT]		= { .type = NLA_U8 },
+	[LWTUNNEL_IP6_TC]		= { .type = NLA_U8 },
+	[LWTUNNEL_IP6_SPORT]		= { .type = NLA_U16 },
+	[LWTUNNEL_IP6_DPORT]		= { .type = NLA_U16 },
+	[LWTUNNEL_IP6_FLAGS]		= { .type = NLA_U16 },
+};
+
+static int ip6_tun_build_state(struct net_device *dev, struct nlattr *attr,
+			       struct lwtunnel_state **ts)
+{
+	struct ip_tunnel_info *tun_info;
+	struct lwtunnel_state *new_state;
+	struct nlattr *tb[LWTUNNEL_IP6_MAX + 1];
+	int err;
+
+	err = nla_parse_nested(tb, LWTUNNEL_IP6_MAX, attr, ip6_tun_policy);
+	if (err < 0)
+		return err;
+
+	new_state = lwtunnel_state_alloc(sizeof(*tun_info));
+	if (!new_state)
+		return -ENOMEM;
+
+	new_state->type = LWTUNNEL_ENCAP_IP6;
+
+	tun_info = lwt_tun_info(new_state);
+
+	if (tb[LWTUNNEL_IP6_ID])
+		tun_info->key.tun_id = nla_get_u64(tb[LWTUNNEL_IP6_ID]);
+
+	if (tb[LWTUNNEL_IP6_DST])
+		tun_info->key.u.ipv6.dst = nla_get_in6_addr(tb[LWTUNNEL_IP6_DST]);
+
+	if (tb[LWTUNNEL_IP6_SRC])
+		tun_info->key.u.ipv6.src = nla_get_in6_addr(tb[LWTUNNEL_IP6_SRC]);
+
+	if (tb[LWTUNNEL_IP6_HOPLIMIT])
+		tun_info->key.ttl = nla_get_u8(tb[LWTUNNEL_IP6_HOPLIMIT]);
+
+	if (tb[LWTUNNEL_IP6_TC])
+		tun_info->key.tos = nla_get_u8(tb[LWTUNNEL_IP6_TC]);
+
+	if (tb[LWTUNNEL_IP6_SPORT])
+		tun_info->key.tp_src = nla_get_be16(tb[LWTUNNEL_IP6_SPORT]);
+
+	if (tb[LWTUNNEL_IP6_DPORT])
+		tun_info->key.tp_dst = nla_get_be16(tb[LWTUNNEL_IP6_DPORT]);
+
+	if (tb[LWTUNNEL_IP6_FLAGS])
+		tun_info->key.tun_flags = nla_get_u16(tb[LWTUNNEL_IP6_FLAGS]);
+
+	tun_info->mode = IP_TUNNEL_INFO_TX;
+	tun_info->options = NULL;
+	tun_info->options_len = 0;
+
+	*ts = new_state;
+
+	return 0;
+}
+
+static int ip6_tun_fill_encap_info(struct sk_buff *skb,
+				   struct lwtunnel_state *lwtstate)
+{
+	struct ip_tunnel_info *tun_info = lwt_tun_info(lwtstate);
+
+	if (nla_put_u64(skb, LWTUNNEL_IP6_ID, tun_info->key.tun_id) ||
+	    nla_put_in6_addr(skb, LWTUNNEL_IP6_DST, &tun_info->key.u.ipv6.dst) ||
+	    nla_put_in6_addr(skb, LWTUNNEL_IP6_SRC, &tun_info->key.u.ipv6.src) ||
+	    nla_put_u8(skb, LWTUNNEL_IP6_HOPLIMIT, tun_info->key.tos) ||
+	    nla_put_u8(skb, LWTUNNEL_IP6_TC, tun_info->key.ttl) ||
+	    nla_put_u16(skb, LWTUNNEL_IP6_SPORT, tun_info->key.tp_src) ||
+	    nla_put_u16(skb, LWTUNNEL_IP6_DPORT, tun_info->key.tp_dst) ||
+	    nla_put_u16(skb, LWTUNNEL_IP6_FLAGS, tun_info->key.tun_flags))
+		return -ENOMEM;
+
+	return 0;
+}
+
+static int ip6_tun_encap_nlsize(struct lwtunnel_state *lwtstate)
+{
+	return nla_total_size(8)	/* LWTUNNEL_IP6_ID */
+		+ nla_total_size(16)	/* LWTUNNEL_IP6_DST */
+		+ nla_total_size(16)	/* LWTUNNEL_IP6_SRC */
+		+ nla_total_size(1)	/* LWTUNNEL_IP6_HOPLIMIT */
+		+ nla_total_size(1)	/* LWTUNNEL_IP6_TC */
+		+ nla_total_size(2)	/* LWTUNNEL_IP6_SPORT */
+		+ nla_total_size(2)	/* LWTUNNEL_IP6_DPORT */
+		+ nla_total_size(2);	/* LWTUNNEL_IP6_FLAGS */
+}
+
+static const struct lwtunnel_encap_ops ip6_tun_lwt_ops = {
+	.build_state = ip6_tun_build_state,
+	.fill_encap = ip6_tun_fill_encap_info,
+	.get_encap_size = ip6_tun_encap_nlsize,
+	.cmp_encap = ip_tun_cmp_encap,
+};
+
 void __init ip_tunnel_core_init(void)
 {
 	lwtunnel_encap_add_ops(&ip_tun_lwt_ops, LWTUNNEL_ENCAP_IP);
+	lwtunnel_encap_add_ops(&ip6_tun_lwt_ops, LWTUNNEL_ENCAP_IP6);
 }
 
 struct static_key ip_tunnel_metadata_cnt = STATIC_KEY_INIT_FALSE;
-- 
1.8.3.1
