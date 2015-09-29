From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 2/2] openvswitch: netlink attributes for IPv6 tunneling
Date: Tue, 29 Sep 2015 19:52:26 +0200
Message-ID: <ac7ce77d8104dca2c8378096575276984dd2a11e.1443548447.git.jbenc@redhat.com>
References: <cover.1443548447.git.jbenc@redhat.com>
Cc: dev@openvswitch.org, Pravin Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41689 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934925AbbI2Rwu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Sep 2015 13:52:50 -0400
In-Reply-To: <cover.1443548447.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add netlink attributes for IPv6 tunnel addresses. This enables IPv6 support
for tunnels.

When compat code for tunnel configuration is used, IPv6 tun_info will be
rejected by ovs_tunnel_get_egress_info. As the consequence, only the new way
of tunnel config supports IPv6.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 include/uapi/linux/openvswitch.h |   2 +
 net/openvswitch/flow_netlink.c   | 120 +++++++++++++++++++++++++++------------
 2 files changed, 85 insertions(+), 37 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 32e07d8cbaf4..4036e1b1980f 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -349,6 +349,8 @@ enum ovs_tunnel_key_attr {
 	OVS_TUNNEL_KEY_ATTR_TP_SRC,		/* be16 src Transport Port. */
 	OVS_TUNNEL_KEY_ATTR_TP_DST,		/* be16 dst Transport Port. */
 	OVS_TUNNEL_KEY_ATTR_VXLAN_OPTS,		/* Nested OVS_VXLAN_EXT_* */
+	OVS_TUNNEL_KEY_ATTR_IPV6_SRC,		/* struct in6_addr src IPv6 address. */
+	OVS_TUNNEL_KEY_ATTR_IPV6_DST,		/* struct in6_addr dst IPv6 address. */
 	__OVS_TUNNEL_KEY_ATTR_MAX
 };
 
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 03ba070c3256..73df3cda1070 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -262,8 +262,8 @@ size_t ovs_tun_key_attr_size(void)
 	 * updating this function.
 	 */
 	return    nla_total_size(8)    /* OVS_TUNNEL_KEY_ATTR_ID */
-		+ nla_total_size(4)    /* OVS_TUNNEL_KEY_ATTR_IPV4_SRC */
-		+ nla_total_size(4)    /* OVS_TUNNEL_KEY_ATTR_IPV4_DST */
+		+ nla_total_size(16)   /* OVS_TUNNEL_KEY_ATTR_IPV[46]_SRC */
+		+ nla_total_size(16)   /* OVS_TUNNEL_KEY_ATTR_IPV[46]_DST */
 		+ nla_total_size(1)    /* OVS_TUNNEL_KEY_ATTR_TOS */
 		+ nla_total_size(1)    /* OVS_TUNNEL_KEY_ATTR_TTL */
 		+ nla_total_size(0)    /* OVS_TUNNEL_KEY_ATTR_DONT_FRAGMENT */
@@ -323,6 +323,8 @@ static const struct ovs_len_tbl ovs_tunnel_key_lens[OVS_TUNNEL_KEY_ATTR_MAX + 1]
 	[OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS]   = { .len = OVS_ATTR_VARIABLE },
 	[OVS_TUNNEL_KEY_ATTR_VXLAN_OPTS]    = { .len = OVS_ATTR_NESTED,
 						.next = ovs_vxlan_ext_key_lens },
+	[OVS_TUNNEL_KEY_ATTR_IPV6_SRC]      = { .len = sizeof(struct in6_addr) },
+	[OVS_TUNNEL_KEY_ATTR_IPV6_DST]      = { .len = sizeof(struct in6_addr) },
 };
 
 /* The size of the argument for each %OVS_KEY_ATTR_* Netlink attribute.  */
@@ -542,14 +544,14 @@ static int vxlan_tun_opt_from_nlattr(const struct nlattr *attr,
 	return 0;
 }
 
-static int ipv4_tun_from_nlattr(const struct nlattr *attr,
-				struct sw_flow_match *match, bool is_mask,
-				bool log)
+static int ip_tun_from_nlattr(const struct nlattr *attr,
+			      struct sw_flow_match *match, bool is_mask,
+			      bool log)
 {
 	struct nlattr *a;
 	int rem;
 	bool ttl = false;
-	__be16 tun_flags = 0;
+	__be16 tun_flags = 0, ipv4 = false, ipv6 = false;
 	int opts_type = 0;
 
 	nla_for_each_nested(a, attr, rem) {
@@ -578,10 +580,22 @@ static int ipv4_tun_from_nlattr(const struct nlattr *attr,
 		case OVS_TUNNEL_KEY_ATTR_IPV4_SRC:
 			SW_FLOW_KEY_PUT(match, tun_key.u.ipv4.src,
 					nla_get_in_addr(a), is_mask);
+			ipv4 = true;
 			break;
 		case OVS_TUNNEL_KEY_ATTR_IPV4_DST:
 			SW_FLOW_KEY_PUT(match, tun_key.u.ipv4.dst,
 					nla_get_in_addr(a), is_mask);
+			ipv4 = true;
+			break;
+		case OVS_TUNNEL_KEY_ATTR_IPV6_SRC:
+			SW_FLOW_KEY_PUT(match, tun_key.u.ipv6.dst,
+					nla_get_in6_addr(a), is_mask);
+			ipv6 = true;
+			break;
+		case OVS_TUNNEL_KEY_ATTR_IPV6_DST:
+			SW_FLOW_KEY_PUT(match, tun_key.u.ipv6.dst,
+					nla_get_in6_addr(a), is_mask);
+			ipv6 = true;
 			break;
 		case OVS_TUNNEL_KEY_ATTR_TOS:
 			SW_FLOW_KEY_PUT(match, tun_key.tos,
@@ -636,29 +650,42 @@ static int ipv4_tun_from_nlattr(const struct nlattr *attr,
 			opts_type = type;
 			break;
 		default:
-			OVS_NLERR(log, "Unknown IPv4 tunnel attribute %d",
+			OVS_NLERR(log, "Unknown IP tunnel attribute %d",
 				  type);
 			return -EINVAL;
 		}
 	}
 
 	SW_FLOW_KEY_PUT(match, tun_key.tun_flags, tun_flags, is_mask);
-	SW_FLOW_KEY_PUT(match, tun_proto, AF_INET, is_mask);
+	SW_FLOW_KEY_PUT(match, tun_proto, ipv6 ? AF_INET6 : AF_INET, is_mask);
 
 	if (rem > 0) {
-		OVS_NLERR(log, "IPv4 tunnel attribute has %d unknown bytes.",
+		OVS_NLERR(log, "IP tunnel attribute has %d unknown bytes.",
 			  rem);
 		return -EINVAL;
 	}
 
+	if (ipv4 && ipv6) {
+		OVS_NLERR(log, "Mixed IPv4 and IPv6 tunnel attributes");
+		return -EINVAL;
+	}
+
 	if (!is_mask) {
-		if (!match->key->tun_key.u.ipv4.dst) {
+		if (!ipv4 && !ipv6) {
+			OVS_NLERR(log, "IP tunnel dst address not specified");
+			return -EINVAL;
+		}
+		if (ipv4 && !match->key->tun_key.u.ipv4.dst) {
 			OVS_NLERR(log, "IPv4 tunnel dst address is zero");
 			return -EINVAL;
 		}
+		if (ipv6 && ipv6_addr_any(&match->key->tun_key.u.ipv6.dst)) {
+			OVS_NLERR(log, "IPv6 tunnel dst address is zero");
+			return -EINVAL;
+		}
 
 		if (!ttl) {
-			OVS_NLERR(log, "IPv4 tunnel TTL not specified.");
+			OVS_NLERR(log, "IP tunnel TTL not specified.");
 			return -EINVAL;
 		}
 	}
@@ -683,21 +710,36 @@ static int vxlan_opt_to_nlattr(struct sk_buff *skb,
 	return 0;
 }
 
-static int __ipv4_tun_to_nlattr(struct sk_buff *skb,
-				const struct ip_tunnel_key *output,
-				const void *tun_opts, int swkey_tun_opts_len)
+static int __ip_tun_to_nlattr(struct sk_buff *skb,
+			      const struct ip_tunnel_key *output,
+			      const void *tun_opts, int swkey_tun_opts_len,
+			      unsigned short tun_proto)
 {
 	if (output->tun_flags & TUNNEL_KEY &&
 	    nla_put_be64(skb, OVS_TUNNEL_KEY_ATTR_ID, output->tun_id))
 		return -EMSGSIZE;
-	if (output->u.ipv4.src &&
-	    nla_put_in_addr(skb, OVS_TUNNEL_KEY_ATTR_IPV4_SRC,
-			    output->u.ipv4.src))
-		return -EMSGSIZE;
-	if (output->u.ipv4.dst &&
-	    nla_put_in_addr(skb, OVS_TUNNEL_KEY_ATTR_IPV4_DST,
-			    output->u.ipv4.dst))
-		return -EMSGSIZE;
+	switch (tun_proto) {
+	case AF_INET:
+		if (output->u.ipv4.src &&
+		    nla_put_in_addr(skb, OVS_TUNNEL_KEY_ATTR_IPV4_SRC,
+				    output->u.ipv4.src))
+			return -EMSGSIZE;
+		if (output->u.ipv4.dst &&
+		    nla_put_in_addr(skb, OVS_TUNNEL_KEY_ATTR_IPV4_DST,
+				    output->u.ipv4.dst))
+			return -EMSGSIZE;
+		break;
+	case AF_INET6:
+		if (!ipv6_addr_any(&output->u.ipv6.src) &&
+		    nla_put_in6_addr(skb, OVS_TUNNEL_KEY_ATTR_IPV6_SRC,
+				     &output->u.ipv6.src))
+			return -EMSGSIZE;
+		if (!ipv6_addr_any(&output->u.ipv6.dst) &&
+		    nla_put_in6_addr(skb, OVS_TUNNEL_KEY_ATTR_IPV6_DST,
+				     &output->u.ipv6.dst))
+			return -EMSGSIZE;
+		break;
+	}
 	if (output->tos &&
 	    nla_put_u8(skb, OVS_TUNNEL_KEY_ATTR_TOS, output->tos))
 		return -EMSGSIZE;
@@ -731,9 +773,10 @@ static int __ipv4_tun_to_nlattr(struct sk_buff *skb,
 	return 0;
 }
 
-static int ipv4_tun_to_nlattr(struct sk_buff *skb,
-			      const struct ip_tunnel_key *output,
-			      const void *tun_opts, int swkey_tun_opts_len)
+static int ip_tun_to_nlattr(struct sk_buff *skb,
+			    const struct ip_tunnel_key *output,
+			    const void *tun_opts, int swkey_tun_opts_len,
+			    unsigned short tun_proto)
 {
 	struct nlattr *nla;
 	int err;
@@ -742,7 +785,8 @@ static int ipv4_tun_to_nlattr(struct sk_buff *skb,
 	if (!nla)
 		return -EMSGSIZE;
 
-	err = __ipv4_tun_to_nlattr(skb, output, tun_opts, swkey_tun_opts_len);
+	err = __ip_tun_to_nlattr(skb, output, tun_opts, swkey_tun_opts_len,
+				 tun_proto);
 	if (err)
 		return err;
 
@@ -754,9 +798,10 @@ int ovs_nla_put_egress_tunnel_key(struct sk_buff *skb,
 				  const struct ip_tunnel_info *egress_tun_info,
 				  const void *egress_tun_opts)
 {
-	return __ipv4_tun_to_nlattr(skb, &egress_tun_info->key,
-				    egress_tun_opts,
-				    egress_tun_info->options_len);
+	return __ip_tun_to_nlattr(skb, &egress_tun_info->key,
+				  egress_tun_opts,
+				  egress_tun_info->options_len,
+				  ip_tunnel_info_af(egress_tun_info));
 }
 
 static int metadata_from_nlattrs(struct net *net, struct sw_flow_match *match,
@@ -807,8 +852,8 @@ static int metadata_from_nlattrs(struct net *net, struct sw_flow_match *match,
 		*attrs &= ~(1 << OVS_KEY_ATTR_SKB_MARK);
 	}
 	if (*attrs & (1 << OVS_KEY_ATTR_TUNNEL)) {
-		if (ipv4_tun_from_nlattr(a[OVS_KEY_ATTR_TUNNEL], match,
-					 is_mask, log) < 0)
+		if (ip_tun_from_nlattr(a[OVS_KEY_ATTR_TUNNEL], match,
+				       is_mask, log) < 0)
 			return -EINVAL;
 		*attrs &= ~(1 << OVS_KEY_ATTR_TUNNEL);
 	}
@@ -1374,8 +1419,8 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
 		if (output->tun_key.tun_flags & TUNNEL_OPTIONS_PRESENT)
 			opts = TUN_METADATA_OPTS(output, swkey->tun_opts_len);
 
-		if (ipv4_tun_to_nlattr(skb, &output->tun_key, opts,
-				       swkey->tun_opts_len))
+		if (ip_tun_to_nlattr(skb, &output->tun_key, opts,
+				     swkey->tun_opts_len, swkey->tun_proto))
 			goto nla_put_failure;
 	}
 
@@ -1878,7 +1923,7 @@ static int validate_and_copy_set_tun(const struct nlattr *attr,
 	int err = 0, start, opts_type;
 
 	ovs_match_init(&match, &key, NULL);
-	opts_type = ipv4_tun_from_nlattr(nla_data(attr), &match, false, log);
+	opts_type = ip_tun_from_nlattr(nla_data(attr), &match, false, log);
 	if (opts_type < 0)
 		return opts_type;
 
@@ -2377,10 +2422,11 @@ static int set_action_to_attr(const struct nlattr *a, struct sk_buff *skb)
 		if (!start)
 			return -EMSGSIZE;
 
-		err = ipv4_tun_to_nlattr(skb, &tun_info->key,
-					 tun_info->options_len ?
+		err = ip_tun_to_nlattr(skb, &tun_info->key,
+				       tun_info->options_len ?
 					     ip_tunnel_info_opts(tun_info) : NULL,
-					 tun_info->options_len);
+				       tun_info->options_len,
+				       ip_tunnel_info_af(tun_info));
 		if (err)
 			return err;
 		nla_nest_end(skb, start);
-- 
1.8.3.1
