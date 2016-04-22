From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 3/9] libnl: nla_put_be64(): align on a 64-bit area
Date: Fri, 22 Apr 2016 17:31:18 +0200
Message-ID: <1461339084-3849-4-git-send-email-nicolas.dichtel@6wind.com>
References: <1461339084-3849-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	linux-wpan@vger.kernel.org, aar@pengutronix.de,
	pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	pshelar@nicira.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, netfilter-devel@vger.kernel.org,
	dev@openvswitch.org, steffen.klassert@secunet.com,
	herbert@gondor.apana.org.au, bsingharora@gmail.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:53536 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753913AbcDVPcD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 11:32:03 -0400
In-Reply-To: <1461339084-3849-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nla_data() is now aligned on a 64-bit area.

A temporary version (nla_put_be64_32bit()) is added for nla_put_net64().
This function is removed in the next patch.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/net/netlink.h                              | 15 ++++++++++----
 include/uapi/linux/fib_rules.h                     |  1 +
 include/uapi/linux/lwtunnel.h                      |  2 ++
 include/uapi/linux/netfilter/nf_tables.h           |  8 ++++++++
 include/uapi/linux/netfilter/nfnetlink_acct.h      |  1 +
 include/uapi/linux/netfilter/nfnetlink_conntrack.h |  3 +++
 include/uapi/linux/openvswitch.h                   |  1 +
 net/core/fib_rules.c                               |  4 ++--
 net/ipv4/ip_tunnel_core.c                          | 10 +++++----
 net/netfilter/nf_conntrack_netlink.c               | 18 +++++++++-------
 net/netfilter/nf_conntrack_proto_dccp.c            |  4 +++-
 net/netfilter/nf_tables_api.c                      | 24 ++++++++++++++--------
 net/netfilter/nf_tables_trace.c                    |  5 +++--
 net/netfilter/nfnetlink_acct.c                     |  9 +++++---
 net/netfilter/nft_counter.c                        |  6 ++++--
 net/netfilter/nft_dynset.c                         |  3 ++-
 net/netfilter/nft_limit.c                          |  6 ++++--
 net/openvswitch/flow_netlink.c                     |  5 +++--
 18 files changed, 87 insertions(+), 38 deletions(-)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index 7f6b99483ab7..47d7d1356fa3 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -856,16 +856,23 @@ static inline int nla_put_u64(struct sk_buff *skb, int attrtype, u64 value)
 }
 
 /**
- * nla_put_be64 - Add a __be64 netlink attribute to a socket buffer
+ * nla_put_be64 - Add a __be64 netlink attribute to a socket buffer and align it
  * @skb: socket buffer to add attribute to
  * @attrtype: attribute type
  * @value: numeric value
+ * @padattr: attribute type for the padding
  */
-static inline int nla_put_be64(struct sk_buff *skb, int attrtype, __be64 value)
+static inline int nla_put_be64(struct sk_buff *skb, int attrtype, __be64 value,
+			       int padattr)
 {
-	return nla_put(skb, attrtype, sizeof(__be64), &value);
+	return nla_put_64bit(skb, attrtype, sizeof(__be64), &value, padattr);
 }
 
+static inline int nla_put_be64_32bit(struct sk_buff *skb, int attrtype,
+				     __be64 value)
+{
+	return nla_put(skb, attrtype, sizeof(__be64), &value);
+}
 /**
  * nla_put_net64 - Add 64-bit network byte order netlink attribute to a socket buffer
  * @skb: socket buffer to add attribute to
@@ -874,7 +881,7 @@ static inline int nla_put_be64(struct sk_buff *skb, int attrtype, __be64 value)
  */
 static inline int nla_put_net64(struct sk_buff *skb, int attrtype, __be64 value)
 {
-	return nla_put_be64(skb, attrtype | NLA_F_NET_BYTEORDER, value);
+	return nla_put_be64_32bit(skb, attrtype | NLA_F_NET_BYTEORDER, value);
 }
 
 /**
diff --git a/include/uapi/linux/fib_rules.h b/include/uapi/linux/fib_rules.h
index 96161b8202b5..620c8a5ddc00 100644
--- a/include/uapi/linux/fib_rules.h
+++ b/include/uapi/linux/fib_rules.h
@@ -49,6 +49,7 @@ enum {
 	FRA_TABLE,	/* Extended table id */
 	FRA_FWMASK,	/* mask for netfilter mark */
 	FRA_OIFNAME,
+	FRA_PAD,
 	__FRA_MAX
 };
 
diff --git a/include/uapi/linux/lwtunnel.h b/include/uapi/linux/lwtunnel.h
index f8b01887a495..a478fe80e203 100644
--- a/include/uapi/linux/lwtunnel.h
+++ b/include/uapi/linux/lwtunnel.h
@@ -22,6 +22,7 @@ enum lwtunnel_ip_t {
 	LWTUNNEL_IP_TTL,
 	LWTUNNEL_IP_TOS,
 	LWTUNNEL_IP_FLAGS,
+	LWTUNNEL_IP_PAD,
 	__LWTUNNEL_IP_MAX,
 };
 
@@ -35,6 +36,7 @@ enum lwtunnel_ip6_t {
 	LWTUNNEL_IP6_HOPLIMIT,
 	LWTUNNEL_IP6_TC,
 	LWTUNNEL_IP6_FLAGS,
+	LWTUNNEL_IP6_PAD,
 	__LWTUNNEL_IP6_MAX,
 };
 
diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index eeffde196f80..660231363bb5 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -182,6 +182,7 @@ enum nft_chain_attributes {
 	NFTA_CHAIN_USE,
 	NFTA_CHAIN_TYPE,
 	NFTA_CHAIN_COUNTERS,
+	NFTA_CHAIN_PAD,
 	__NFTA_CHAIN_MAX
 };
 #define NFTA_CHAIN_MAX		(__NFTA_CHAIN_MAX - 1)
@@ -206,6 +207,7 @@ enum nft_rule_attributes {
 	NFTA_RULE_COMPAT,
 	NFTA_RULE_POSITION,
 	NFTA_RULE_USERDATA,
+	NFTA_RULE_PAD,
 	__NFTA_RULE_MAX
 };
 #define NFTA_RULE_MAX		(__NFTA_RULE_MAX - 1)
@@ -308,6 +310,7 @@ enum nft_set_attributes {
 	NFTA_SET_TIMEOUT,
 	NFTA_SET_GC_INTERVAL,
 	NFTA_SET_USERDATA,
+	NFTA_SET_PAD,
 	__NFTA_SET_MAX
 };
 #define NFTA_SET_MAX		(__NFTA_SET_MAX - 1)
@@ -341,6 +344,7 @@ enum nft_set_elem_attributes {
 	NFTA_SET_ELEM_EXPIRATION,
 	NFTA_SET_ELEM_USERDATA,
 	NFTA_SET_ELEM_EXPR,
+	NFTA_SET_ELEM_PAD,
 	__NFTA_SET_ELEM_MAX
 };
 #define NFTA_SET_ELEM_MAX	(__NFTA_SET_ELEM_MAX - 1)
@@ -584,6 +588,7 @@ enum nft_dynset_attributes {
 	NFTA_DYNSET_SREG_DATA,
 	NFTA_DYNSET_TIMEOUT,
 	NFTA_DYNSET_EXPR,
+	NFTA_DYNSET_PAD,
 	__NFTA_DYNSET_MAX,
 };
 #define NFTA_DYNSET_MAX		(__NFTA_DYNSET_MAX - 1)
@@ -806,6 +811,7 @@ enum nft_limit_attributes {
 	NFTA_LIMIT_BURST,
 	NFTA_LIMIT_TYPE,
 	NFTA_LIMIT_FLAGS,
+	NFTA_LIMIT_PAD,
 	__NFTA_LIMIT_MAX
 };
 #define NFTA_LIMIT_MAX		(__NFTA_LIMIT_MAX - 1)
@@ -820,6 +826,7 @@ enum nft_counter_attributes {
 	NFTA_COUNTER_UNSPEC,
 	NFTA_COUNTER_BYTES,
 	NFTA_COUNTER_PACKETS,
+	NFTA_COUNTER_PAD,
 	__NFTA_COUNTER_MAX
 };
 #define NFTA_COUNTER_MAX	(__NFTA_COUNTER_MAX - 1)
@@ -1055,6 +1062,7 @@ enum nft_trace_attibutes {
 	NFTA_TRACE_MARK,
 	NFTA_TRACE_NFPROTO,
 	NFTA_TRACE_POLICY,
+	NFTA_TRACE_PAD,
 	__NFTA_TRACE_MAX
 };
 #define NFTA_TRACE_MAX (__NFTA_TRACE_MAX - 1)
diff --git a/include/uapi/linux/netfilter/nfnetlink_acct.h b/include/uapi/linux/netfilter/nfnetlink_acct.h
index f3e34dbbf966..36047ec70f37 100644
--- a/include/uapi/linux/netfilter/nfnetlink_acct.h
+++ b/include/uapi/linux/netfilter/nfnetlink_acct.h
@@ -29,6 +29,7 @@ enum nfnl_acct_type {
 	NFACCT_FLAGS,
 	NFACCT_QUOTA,
 	NFACCT_FILTER,
+	NFACCT_PAD,
 	__NFACCT_MAX
 };
 #define NFACCT_MAX (__NFACCT_MAX - 1)
diff --git a/include/uapi/linux/netfilter/nfnetlink_conntrack.h b/include/uapi/linux/netfilter/nfnetlink_conntrack.h
index c1a4e1441a25..9df789709abe 100644
--- a/include/uapi/linux/netfilter/nfnetlink_conntrack.h
+++ b/include/uapi/linux/netfilter/nfnetlink_conntrack.h
@@ -116,6 +116,7 @@ enum ctattr_protoinfo_dccp {
 	CTA_PROTOINFO_DCCP_STATE,
 	CTA_PROTOINFO_DCCP_ROLE,
 	CTA_PROTOINFO_DCCP_HANDSHAKE_SEQ,
+	CTA_PROTOINFO_DCCP_PAD,
 	__CTA_PROTOINFO_DCCP_MAX,
 };
 #define CTA_PROTOINFO_DCCP_MAX (__CTA_PROTOINFO_DCCP_MAX - 1)
@@ -135,6 +136,7 @@ enum ctattr_counters {
 	CTA_COUNTERS_BYTES,		/* 64bit counters */
 	CTA_COUNTERS32_PACKETS,		/* old 32bit counters, unused */
 	CTA_COUNTERS32_BYTES,		/* old 32bit counters, unused */
+	CTA_COUNTERS_PAD,
 	__CTA_COUNTERS_MAX
 };
 #define CTA_COUNTERS_MAX (__CTA_COUNTERS_MAX - 1)
@@ -143,6 +145,7 @@ enum ctattr_tstamp {
 	CTA_TIMESTAMP_UNSPEC,
 	CTA_TIMESTAMP_START,
 	CTA_TIMESTAMP_STOP,
+	CTA_TIMESTAMP_PAD,
 	__CTA_TIMESTAMP_MAX
 };
 #define CTA_TIMESTAMP_MAX (__CTA_TIMESTAMP_MAX - 1)
diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 616d04761730..0358f94af86e 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -351,6 +351,7 @@ enum ovs_tunnel_key_attr {
 	OVS_TUNNEL_KEY_ATTR_VXLAN_OPTS,		/* Nested OVS_VXLAN_EXT_* */
 	OVS_TUNNEL_KEY_ATTR_IPV6_SRC,		/* struct in6_addr src IPv6 address. */
 	OVS_TUNNEL_KEY_ATTR_IPV6_DST,		/* struct in6_addr dst IPv6 address. */
+	OVS_TUNNEL_KEY_ATTR_PAD,
 	__OVS_TUNNEL_KEY_ATTR_MAX
 };
 
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 365de66436ac..840acebbb80c 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -549,7 +549,7 @@ static inline size_t fib_rule_nlmsg_size(struct fib_rules_ops *ops,
 			 + nla_total_size(4) /* FRA_SUPPRESS_IFGROUP */
 			 + nla_total_size(4) /* FRA_FWMARK */
 			 + nla_total_size(4) /* FRA_FWMASK */
-			 + nla_total_size(8); /* FRA_TUN_ID */
+			 + nla_total_size_64bit(8); /* FRA_TUN_ID */
 
 	if (ops->nlmsg_payload)
 		payload += ops->nlmsg_payload(rule);
@@ -607,7 +607,7 @@ static int fib_nl_fill_rule(struct sk_buff *skb, struct fib_rule *rule,
 	    (rule->target &&
 	     nla_put_u32(skb, FRA_GOTO, rule->target)) ||
 	    (rule->tun_id &&
-	     nla_put_be64(skb, FRA_TUN_ID, rule->tun_id)))
+	     nla_put_be64(skb, FRA_TUN_ID, rule->tun_id, FRA_PAD)))
 		goto nla_put_failure;
 
 	if (rule->suppress_ifgroup != -1) {
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index f46c5c873831..786fa7ca28e0 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -271,7 +271,8 @@ static int ip_tun_fill_encap_info(struct sk_buff *skb,
 {
 	struct ip_tunnel_info *tun_info = lwt_tun_info(lwtstate);
 
-	if (nla_put_be64(skb, LWTUNNEL_IP_ID, tun_info->key.tun_id) ||
+	if (nla_put_be64(skb, LWTUNNEL_IP_ID, tun_info->key.tun_id,
+			 LWTUNNEL_IP_PAD) ||
 	    nla_put_in_addr(skb, LWTUNNEL_IP_DST, tun_info->key.u.ipv4.dst) ||
 	    nla_put_in_addr(skb, LWTUNNEL_IP_SRC, tun_info->key.u.ipv4.src) ||
 	    nla_put_u8(skb, LWTUNNEL_IP_TOS, tun_info->key.tos) ||
@@ -284,7 +285,7 @@ static int ip_tun_fill_encap_info(struct sk_buff *skb,
 
 static int ip_tun_encap_nlsize(struct lwtunnel_state *lwtstate)
 {
-	return nla_total_size(8)	/* LWTUNNEL_IP_ID */
+	return nla_total_size_64bit(8)	/* LWTUNNEL_IP_ID */
 		+ nla_total_size(4)	/* LWTUNNEL_IP_DST */
 		+ nla_total_size(4)	/* LWTUNNEL_IP_SRC */
 		+ nla_total_size(1)	/* LWTUNNEL_IP_TOS */
@@ -366,7 +367,8 @@ static int ip6_tun_fill_encap_info(struct sk_buff *skb,
 {
 	struct ip_tunnel_info *tun_info = lwt_tun_info(lwtstate);
 
-	if (nla_put_be64(skb, LWTUNNEL_IP6_ID, tun_info->key.tun_id) ||
+	if (nla_put_be64(skb, LWTUNNEL_IP6_ID, tun_info->key.tun_id,
+			 LWTUNNEL_IP6_PAD) ||
 	    nla_put_in6_addr(skb, LWTUNNEL_IP6_DST, &tun_info->key.u.ipv6.dst) ||
 	    nla_put_in6_addr(skb, LWTUNNEL_IP6_SRC, &tun_info->key.u.ipv6.src) ||
 	    nla_put_u8(skb, LWTUNNEL_IP6_TC, tun_info->key.tos) ||
@@ -379,7 +381,7 @@ static int ip6_tun_fill_encap_info(struct sk_buff *skb,
 
 static int ip6_tun_encap_nlsize(struct lwtunnel_state *lwtstate)
 {
-	return nla_total_size(8)	/* LWTUNNEL_IP6_ID */
+	return nla_total_size_64bit(8)	/* LWTUNNEL_IP6_ID */
 		+ nla_total_size(16)	/* LWTUNNEL_IP6_DST */
 		+ nla_total_size(16)	/* LWTUNNEL_IP6_SRC */
 		+ nla_total_size(1)	/* LWTUNNEL_IP6_HOPLIMIT */
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 355e8552fd5b..3362d65f3285 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -245,8 +245,10 @@ dump_counters(struct sk_buff *skb, struct nf_conn_acct *acct,
 	if (!nest_count)
 		goto nla_put_failure;
 
-	if (nla_put_be64(skb, CTA_COUNTERS_PACKETS, cpu_to_be64(pkts)) ||
-	    nla_put_be64(skb, CTA_COUNTERS_BYTES, cpu_to_be64(bytes)))
+	if (nla_put_be64(skb, CTA_COUNTERS_PACKETS, cpu_to_be64(pkts),
+			 CTA_COUNTERS_PAD) ||
+	    nla_put_be64(skb, CTA_COUNTERS_BYTES, cpu_to_be64(bytes),
+			 CTA_COUNTERS_PAD))
 		goto nla_put_failure;
 
 	nla_nest_end(skb, nest_count);
@@ -287,9 +289,11 @@ ctnetlink_dump_timestamp(struct sk_buff *skb, const struct nf_conn *ct)
 	if (!nest_count)
 		goto nla_put_failure;
 
-	if (nla_put_be64(skb, CTA_TIMESTAMP_START, cpu_to_be64(tstamp->start)) ||
+	if (nla_put_be64(skb, CTA_TIMESTAMP_START, cpu_to_be64(tstamp->start),
+			 CTA_TIMESTAMP_PAD) ||
 	    (tstamp->stop != 0 && nla_put_be64(skb, CTA_TIMESTAMP_STOP,
-					       cpu_to_be64(tstamp->stop))))
+					       cpu_to_be64(tstamp->stop),
+					       CTA_TIMESTAMP_PAD)))
 		goto nla_put_failure;
 	nla_nest_end(skb, nest_count);
 
@@ -562,8 +566,8 @@ ctnetlink_acct_size(const struct nf_conn *ct)
 	if (!nf_ct_ext_exist(ct, NF_CT_EXT_ACCT))
 		return 0;
 	return 2 * nla_total_size(0) /* CTA_COUNTERS_ORIG|REPL */
-	       + 2 * nla_total_size(sizeof(uint64_t)) /* CTA_COUNTERS_PACKETS */
-	       + 2 * nla_total_size(sizeof(uint64_t)) /* CTA_COUNTERS_BYTES */
+	       + 2 * nla_total_size_64bit(sizeof(uint64_t)) /* CTA_COUNTERS_PACKETS */
+	       + 2 * nla_total_size_64bit(sizeof(uint64_t)) /* CTA_COUNTERS_BYTES */
 	       ;
 }
 
@@ -590,7 +594,7 @@ ctnetlink_timestamp_size(const struct nf_conn *ct)
 #ifdef CONFIG_NF_CONNTRACK_TIMESTAMP
 	if (!nf_ct_ext_exist(ct, NF_CT_EXT_TSTAMP))
 		return 0;
-	return nla_total_size(0) + 2 * nla_total_size(sizeof(uint64_t));
+	return nla_total_size(0) + 2 * nla_total_size_64bit(sizeof(uint64_t));
 #else
 	return 0;
 #endif
diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index fce1b1cca32d..399a38fd685a 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -645,7 +645,8 @@ static int dccp_to_nlattr(struct sk_buff *skb, struct nlattr *nla,
 	    nla_put_u8(skb, CTA_PROTOINFO_DCCP_ROLE,
 		       ct->proto.dccp.role[IP_CT_DIR_ORIGINAL]) ||
 	    nla_put_be64(skb, CTA_PROTOINFO_DCCP_HANDSHAKE_SEQ,
-			 cpu_to_be64(ct->proto.dccp.handshake_seq)))
+			 cpu_to_be64(ct->proto.dccp.handshake_seq),
+			 CTA_PROTOINFO_DCCP_PAD))
 		goto nla_put_failure;
 	nla_nest_end(skb, nest_parms);
 	spin_unlock_bh(&ct->lock);
@@ -660,6 +661,7 @@ static const struct nla_policy dccp_nla_policy[CTA_PROTOINFO_DCCP_MAX + 1] = {
 	[CTA_PROTOINFO_DCCP_STATE]	= { .type = NLA_U8 },
 	[CTA_PROTOINFO_DCCP_ROLE]	= { .type = NLA_U8 },
 	[CTA_PROTOINFO_DCCP_HANDSHAKE_SEQ] = { .type = NLA_U64 },
+	[CTA_PROTOINFO_DCCP_PAD]	= { .type = NLA_UNSPEC },
 };
 
 static int nlattr_to_dccp(struct nlattr *cda[], struct nf_conn *ct)
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 2011977cd79d..7a85a9dd37ad 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -944,8 +944,10 @@ static int nft_dump_stats(struct sk_buff *skb, struct nft_stats __percpu *stats)
 	if (nest == NULL)
 		goto nla_put_failure;
 
-	if (nla_put_be64(skb, NFTA_COUNTER_PACKETS, cpu_to_be64(total.pkts)) ||
-	    nla_put_be64(skb, NFTA_COUNTER_BYTES, cpu_to_be64(total.bytes)))
+	if (nla_put_be64(skb, NFTA_COUNTER_PACKETS, cpu_to_be64(total.pkts),
+			 NFTA_COUNTER_PAD) ||
+	    nla_put_be64(skb, NFTA_COUNTER_BYTES, cpu_to_be64(total.bytes),
+			 NFTA_COUNTER_PAD))
 		goto nla_put_failure;
 
 	nla_nest_end(skb, nest);
@@ -975,7 +977,8 @@ static int nf_tables_fill_chain_info(struct sk_buff *skb, struct net *net,
 
 	if (nla_put_string(skb, NFTA_CHAIN_TABLE, table->name))
 		goto nla_put_failure;
-	if (nla_put_be64(skb, NFTA_CHAIN_HANDLE, cpu_to_be64(chain->handle)))
+	if (nla_put_be64(skb, NFTA_CHAIN_HANDLE, cpu_to_be64(chain->handle),
+			 NFTA_CHAIN_PAD))
 		goto nla_put_failure;
 	if (nla_put_string(skb, NFTA_CHAIN_NAME, chain->name))
 		goto nla_put_failure;
@@ -1803,13 +1806,15 @@ static int nf_tables_fill_rule_info(struct sk_buff *skb, struct net *net,
 		goto nla_put_failure;
 	if (nla_put_string(skb, NFTA_RULE_CHAIN, chain->name))
 		goto nla_put_failure;
-	if (nla_put_be64(skb, NFTA_RULE_HANDLE, cpu_to_be64(rule->handle)))
+	if (nla_put_be64(skb, NFTA_RULE_HANDLE, cpu_to_be64(rule->handle),
+			 NFTA_RULE_PAD))
 		goto nla_put_failure;
 
 	if ((event != NFT_MSG_DELRULE) && (rule->list.prev != &chain->rules)) {
 		prule = list_entry(rule->list.prev, struct nft_rule, list);
 		if (nla_put_be64(skb, NFTA_RULE_POSITION,
-				 cpu_to_be64(prule->handle)))
+				 cpu_to_be64(prule->handle),
+				 NFTA_RULE_PAD))
 			goto nla_put_failure;
 	}
 
@@ -2473,7 +2478,8 @@ static int nf_tables_fill_set(struct sk_buff *skb, const struct nft_ctx *ctx,
 	}
 
 	if (set->timeout &&
-	    nla_put_be64(skb, NFTA_SET_TIMEOUT, cpu_to_be64(set->timeout)))
+	    nla_put_be64(skb, NFTA_SET_TIMEOUT, cpu_to_be64(set->timeout),
+			 NFTA_SET_PAD))
 		goto nla_put_failure;
 	if (set->gc_int &&
 	    nla_put_be32(skb, NFTA_SET_GC_INTERVAL, htonl(set->gc_int)))
@@ -3076,7 +3082,8 @@ static int nf_tables_fill_setelem(struct sk_buff *skb,
 
 	if (nft_set_ext_exists(ext, NFT_SET_EXT_TIMEOUT) &&
 	    nla_put_be64(skb, NFTA_SET_ELEM_TIMEOUT,
-			 cpu_to_be64(*nft_set_ext_timeout(ext))))
+			 cpu_to_be64(*nft_set_ext_timeout(ext)),
+			 NFTA_SET_ELEM_PAD))
 		goto nla_put_failure;
 
 	if (nft_set_ext_exists(ext, NFT_SET_EXT_EXPIRATION)) {
@@ -3089,7 +3096,8 @@ static int nf_tables_fill_setelem(struct sk_buff *skb,
 			expires = 0;
 
 		if (nla_put_be64(skb, NFTA_SET_ELEM_EXPIRATION,
-				 cpu_to_be64(jiffies_to_msecs(expires))))
+				 cpu_to_be64(jiffies_to_msecs(expires)),
+				 NFTA_SET_ELEM_PAD))
 			goto nla_put_failure;
 	}
 
diff --git a/net/netfilter/nf_tables_trace.c b/net/netfilter/nf_tables_trace.c
index e9e959f65d91..39eb1cc62e91 100644
--- a/net/netfilter/nf_tables_trace.c
+++ b/net/netfilter/nf_tables_trace.c
@@ -156,7 +156,8 @@ static int nf_trace_fill_rule_info(struct sk_buff *nlskb,
 		return 0;
 
 	return nla_put_be64(nlskb, NFTA_TRACE_RULE_HANDLE,
-			    cpu_to_be64(info->rule->handle));
+			    cpu_to_be64(info->rule->handle),
+			    NFTA_TRACE_PAD);
 }
 
 void nft_trace_notify(struct nft_traceinfo *info)
@@ -174,7 +175,7 @@ void nft_trace_notify(struct nft_traceinfo *info)
 	size = nlmsg_total_size(sizeof(struct nfgenmsg)) +
 		nla_total_size(NFT_TABLE_MAXNAMELEN) +
 		nla_total_size(NFT_CHAIN_MAXNAMELEN) +
-		nla_total_size(sizeof(__be64)) +	/* rule handle */
+		nla_total_size_64bit(sizeof(__be64)) +	/* rule handle */
 		nla_total_size(sizeof(__be32)) +	/* trace type */
 		nla_total_size(0) +			/* VERDICT, nested */
 			nla_total_size(sizeof(u32)) +	/* verdict code */
diff --git a/net/netfilter/nfnetlink_acct.c b/net/netfilter/nfnetlink_acct.c
index 4c2b4c0c4d5f..d016066a25e3 100644
--- a/net/netfilter/nfnetlink_acct.c
+++ b/net/netfilter/nfnetlink_acct.c
@@ -160,15 +160,18 @@ nfnl_acct_fill_info(struct sk_buff *skb, u32 portid, u32 seq, u32 type,
 		pkts = atomic64_read(&acct->pkts);
 		bytes = atomic64_read(&acct->bytes);
 	}
-	if (nla_put_be64(skb, NFACCT_PKTS, cpu_to_be64(pkts)) ||
-	    nla_put_be64(skb, NFACCT_BYTES, cpu_to_be64(bytes)) ||
+	if (nla_put_be64(skb, NFACCT_PKTS, cpu_to_be64(pkts),
+			 NFACCT_PAD) ||
+	    nla_put_be64(skb, NFACCT_BYTES, cpu_to_be64(bytes),
+			 NFACCT_PAD) ||
 	    nla_put_be32(skb, NFACCT_USE, htonl(atomic_read(&acct->refcnt))))
 		goto nla_put_failure;
 	if (acct->flags & NFACCT_F_QUOTA) {
 		u64 *quota = (u64 *)acct->data;
 
 		if (nla_put_be32(skb, NFACCT_FLAGS, htonl(old_flags)) ||
-		    nla_put_be64(skb, NFACCT_QUOTA, cpu_to_be64(*quota)))
+		    nla_put_be64(skb, NFACCT_QUOTA, cpu_to_be64(*quota),
+				 NFACCT_PAD))
 			goto nla_put_failure;
 	}
 	nlmsg_end(skb, nlh);
diff --git a/net/netfilter/nft_counter.c b/net/netfilter/nft_counter.c
index c9743f78f219..77db8358ab14 100644
--- a/net/netfilter/nft_counter.c
+++ b/net/netfilter/nft_counter.c
@@ -76,8 +76,10 @@ static int nft_counter_dump(struct sk_buff *skb, const struct nft_expr *expr)
 
 	nft_counter_fetch(priv->counter, &total);
 
-	if (nla_put_be64(skb, NFTA_COUNTER_BYTES, cpu_to_be64(total.bytes)) ||
-	    nla_put_be64(skb, NFTA_COUNTER_PACKETS, cpu_to_be64(total.packets)))
+	if (nla_put_be64(skb, NFTA_COUNTER_BYTES, cpu_to_be64(total.bytes),
+			 NFTA_COUNTER_PAD) ||
+	    nla_put_be64(skb, NFTA_COUNTER_PACKETS, cpu_to_be64(total.packets),
+			 NFTA_COUNTER_PAD))
 		goto nla_put_failure;
 	return 0;
 
diff --git a/net/netfilter/nft_dynset.c b/net/netfilter/nft_dynset.c
index 9dec3bd1b63c..78d4914fb39c 100644
--- a/net/netfilter/nft_dynset.c
+++ b/net/netfilter/nft_dynset.c
@@ -227,7 +227,8 @@ static int nft_dynset_dump(struct sk_buff *skb, const struct nft_expr *expr)
 		goto nla_put_failure;
 	if (nla_put_string(skb, NFTA_DYNSET_SET_NAME, priv->set->name))
 		goto nla_put_failure;
-	if (nla_put_be64(skb, NFTA_DYNSET_TIMEOUT, cpu_to_be64(priv->timeout)))
+	if (nla_put_be64(skb, NFTA_DYNSET_TIMEOUT, cpu_to_be64(priv->timeout),
+			 NFTA_DYNSET_PAD))
 		goto nla_put_failure;
 	if (priv->expr && nft_expr_dump(skb, NFTA_DYNSET_EXPR, priv->expr))
 		goto nla_put_failure;
diff --git a/net/netfilter/nft_limit.c b/net/netfilter/nft_limit.c
index 99d18578afc6..070b98938e02 100644
--- a/net/netfilter/nft_limit.c
+++ b/net/netfilter/nft_limit.c
@@ -97,8 +97,10 @@ static int nft_limit_dump(struct sk_buff *skb, const struct nft_limit *limit,
 	u64 secs = div_u64(limit->nsecs, NSEC_PER_SEC);
 	u64 rate = limit->rate - limit->burst;
 
-	if (nla_put_be64(skb, NFTA_LIMIT_RATE, cpu_to_be64(rate)) ||
-	    nla_put_be64(skb, NFTA_LIMIT_UNIT, cpu_to_be64(secs)) ||
+	if (nla_put_be64(skb, NFTA_LIMIT_RATE, cpu_to_be64(rate),
+			 NFTA_LIMIT_PAD) ||
+	    nla_put_be64(skb, NFTA_LIMIT_UNIT, cpu_to_be64(secs),
+			 NFTA_LIMIT_PAD) ||
 	    nla_put_be32(skb, NFTA_LIMIT_BURST, htonl(limit->burst)) ||
 	    nla_put_be32(skb, NFTA_LIMIT_TYPE, htonl(type)) ||
 	    nla_put_be32(skb, NFTA_LIMIT_FLAGS, htonl(flags)))
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 689c17264221..0bb650f4f219 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -261,7 +261,7 @@ size_t ovs_tun_key_attr_size(void)
 	/* Whenever adding new OVS_TUNNEL_KEY_ FIELDS, we should consider
 	 * updating this function.
 	 */
-	return    nla_total_size(8)    /* OVS_TUNNEL_KEY_ATTR_ID */
+	return    nla_total_size_64bit(8) /* OVS_TUNNEL_KEY_ATTR_ID */
 		+ nla_total_size(16)   /* OVS_TUNNEL_KEY_ATTR_IPV[46]_SRC */
 		+ nla_total_size(16)   /* OVS_TUNNEL_KEY_ATTR_IPV[46]_DST */
 		+ nla_total_size(1)    /* OVS_TUNNEL_KEY_ATTR_TOS */
@@ -720,7 +720,8 @@ static int __ip_tun_to_nlattr(struct sk_buff *skb,
 			      unsigned short tun_proto)
 {
 	if (output->tun_flags & TUNNEL_KEY &&
-	    nla_put_be64(skb, OVS_TUNNEL_KEY_ATTR_ID, output->tun_id))
+	    nla_put_be64(skb, OVS_TUNNEL_KEY_ATTR_ID, output->tun_id,
+			 OVS_TUNNEL_KEY_ATTR_PAD))
 		return -EMSGSIZE;
 	switch (tun_proto) {
 	case AF_INET:
-- 
2.8.1
