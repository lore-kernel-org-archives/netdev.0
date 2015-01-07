From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 5/6] openvswitch: Rename GENEVE_TUN_OPTS() to TUN_METADATA_OPTS()
Date: Wed,  7 Jan 2015 03:05:40 +0100
Message-ID: <10cbd42aca443d862b8b62017b5a4356326e026f.1420594925.git.tgraf@suug.ch>
References: <cover.1420594925.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: davem@davemloft.net, jesse@nicira.com, stephen@networkplumber.org,
	pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:42859 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756370AbbAGCF4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 21:05:56 -0500
In-Reply-To: <cover.1420594925.git.tgraf@suug.ch>
In-Reply-To: <cover.1420594925.git.tgraf@suug.ch>
References: <cover.1420594925.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A subsequent patch will introduce VXLAN options. Rename the existing
GENEVE_TUN_OPTS() to reflect its extended purpose of carrying generic
tunnel metadata options.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/openvswitch/flow.c         |  2 +-
 net/openvswitch/flow.h         | 14 +++++++-------
 net/openvswitch/flow_netlink.c | 37 +++++++++++++++++--------------------
 3 files changed, 25 insertions(+), 28 deletions(-)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 70bef2a..bfc74ac 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -690,7 +690,7 @@ int ovs_flow_key_extract(const struct ovs_tunnel_info *tun_info,
 			BUILD_BUG_ON((1 << (sizeof(tun_info->options_len) *
 						   8)) - 1
 					> sizeof(key->tun_opts));
-			memcpy(GENEVE_OPTS(key, tun_info->options_len),
+			memcpy(TUN_METADATA_OPTS(key, tun_info->options_len),
 			       tun_info->options, tun_info->options_len);
 			key->tun_opts_len = tun_info->options_len;
 		} else {
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index a8b30f3..d3d0a40 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -53,7 +53,7 @@ struct ovs_key_ipv4_tunnel {
 
 struct ovs_tunnel_info {
 	struct ovs_key_ipv4_tunnel tunnel;
-	const struct geneve_opt *options;
+	const void *options;
 	u8 options_len;
 };
 
@@ -61,10 +61,10 @@ struct ovs_tunnel_info {
  * maximum size. This allows us to get the benefits of variable length
  * matching for small options.
  */
-#define GENEVE_OPTS(flow_key, opt_len)	\
-	((struct geneve_opt *)((flow_key)->tun_opts + \
-			       FIELD_SIZEOF(struct sw_flow_key, tun_opts) - \
-			       opt_len))
+#define TUN_METADATA_OFFSET(opt_len) \
+	(FIELD_SIZEOF(struct sw_flow_key, tun_opts) - opt_len)
+#define TUN_METADATA_OPTS(flow_key, opt_len) \
+	((void *)((flow_key)->tun_opts + TUN_METADATA_OFFSET(opt_len)))
 
 static inline void __ovs_flow_tun_info_init(struct ovs_tunnel_info *tun_info,
 					    __be32 saddr, __be32 daddr,
@@ -73,7 +73,7 @@ static inline void __ovs_flow_tun_info_init(struct ovs_tunnel_info *tun_info,
 					    __be16 tp_dst,
 					    __be64 tun_id,
 					    __be16 tun_flags,
-					    const struct geneve_opt *opts,
+					    const void *opts,
 					    u8 opts_len)
 {
 	tun_info->tunnel.tun_id = tun_id;
@@ -105,7 +105,7 @@ static inline void ovs_flow_tun_info_init(struct ovs_tunnel_info *tun_info,
 					  __be16 tp_dst,
 					  __be64 tun_id,
 					  __be16 tun_flags,
-					  const struct geneve_opt *opts,
+					  const void *opts,
 					  u8 opts_len)
 {
 	__ovs_flow_tun_info_init(tun_info, iph->saddr, iph->daddr,
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index d1eecf7..c60ae3f 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -387,20 +387,20 @@ static int parse_flow_nlattrs(const struct nlattr *attr,
 	return __parse_flow_nlattrs(attr, a, attrsp, log, false);
 }
 
-static int genev_tun_opt_from_nlattr(const struct nlattr *a,
-				     struct sw_flow_match *match, bool is_mask,
-				     bool log)
+static int tun_md_opt_from_nlattr(const struct nlattr *a,
+				  struct sw_flow_match *match, bool is_mask,
+				  bool log)
 {
 	unsigned long opt_key_offset;
 
 	if (nla_len(a) > sizeof(match->key->tun_opts)) {
-		OVS_NLERR(log, "Geneve option length err (len %d, max %zu).",
+		OVS_NLERR(log, "Tunnel metadata option length err (len %d, max %zu).",
 			  nla_len(a), sizeof(match->key->tun_opts));
 		return -EINVAL;
 	}
 
 	if (nla_len(a) % 4 != 0) {
-		OVS_NLERR(log, "Geneve opt len %d is not a multiple of 4.",
+		OVS_NLERR(log, "Tunnel metadata opt len %d is not a multiple of 4.",
 			  nla_len(a));
 		return -EINVAL;
 	}
@@ -424,7 +424,7 @@ static int genev_tun_opt_from_nlattr(const struct nlattr *a,
 		 * information later.
 		 */
 		if (match->key->tun_opts_len != nla_len(a)) {
-			OVS_NLERR(log, "Geneve option len %d != mask len %d",
+			OVS_NLERR(log, "Tunnel metadata option len %d != mask len %d",
 				  match->key->tun_opts_len, nla_len(a));
 			return -EINVAL;
 		}
@@ -432,8 +432,7 @@ static int genev_tun_opt_from_nlattr(const struct nlattr *a,
 		SW_FLOW_KEY_PUT(match, tun_opts_len, 0xff, true);
 	}
 
-	opt_key_offset = (unsigned long)GENEVE_OPTS((struct sw_flow_key *)0,
-						    nla_len(a));
+	opt_key_offset = TUN_METADATA_OFFSET(nla_len(a));
 	SW_FLOW_KEY_MEMCPY_OFFSET(match, opt_key_offset, nla_data(a),
 				  nla_len(a), is_mask);
 	return 0;
@@ -520,7 +519,7 @@ static int ipv4_tun_from_nlattr(const struct nlattr *attr,
 			tun_flags |= TUNNEL_OAM;
 			break;
 		case OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS:
-			err = genev_tun_opt_from_nlattr(a, match, is_mask, log);
+			err = tun_md_opt_from_nlattr(a, match, is_mask, log);
 			if (err)
 				return err;
 
@@ -558,8 +557,7 @@ static int ipv4_tun_from_nlattr(const struct nlattr *attr,
 
 static int __ipv4_tun_to_nlattr(struct sk_buff *skb,
 				const struct ovs_key_ipv4_tunnel *output,
-				const struct geneve_opt *tun_opts,
-				int swkey_tun_opts_len)
+				const void *tun_opts, int swkey_tun_opts_len)
 {
 	if (output->tun_flags & TUNNEL_KEY &&
 	    nla_put_be64(skb, OVS_TUNNEL_KEY_ATTR_ID, output->tun_id))
@@ -600,8 +598,7 @@ static int __ipv4_tun_to_nlattr(struct sk_buff *skb,
 
 static int ipv4_tun_to_nlattr(struct sk_buff *skb,
 			      const struct ovs_key_ipv4_tunnel *output,
-			      const struct geneve_opt *tun_opts,
-			      int swkey_tun_opts_len)
+			      const void *tun_opts, int swkey_tun_opts_len)
 {
 	struct nlattr *nla;
 	int err;
@@ -1148,10 +1145,10 @@ int ovs_nla_put_flow(const struct sw_flow_key *swkey,
 		goto nla_put_failure;
 
 	if ((swkey->tun_key.ipv4_dst || is_mask)) {
-		const struct geneve_opt *opts = NULL;
+		const void *opts = NULL;
 
 		if (output->tun_key.tun_flags & TUNNEL_OPTIONS_PRESENT)
-			opts = GENEVE_OPTS(output, swkey->tun_opts_len);
+			opts = TUN_METADATA_OPTS(output, swkey->tun_opts_len);
 
 		if (ipv4_tun_to_nlattr(skb, &output->tun_key, opts,
 				       swkey->tun_opts_len))
@@ -1555,11 +1552,11 @@ static int validate_and_copy_set_tun(const struct nlattr *attr,
 		return err;
 
 	if (key.tun_opts_len) {
-		struct geneve_opt *option = GENEVE_OPTS(&key,
-							key.tun_opts_len);
+		struct geneve_opt *option;
 		int opts_len = key.tun_opts_len;
 		bool crit_opt = false;
 
+		option = (struct geneve_opt *) TUN_METADATA_OPTS(&key, key.tun_opts_len);
 		while (opts_len > 0) {
 			int len;
 
@@ -1597,9 +1594,9 @@ static int validate_and_copy_set_tun(const struct nlattr *attr,
 		 * everything else will go away after flow setup. We can append
 		 * it to tun_info and then point there.
 		 */
-		memcpy((tun_info + 1), GENEVE_OPTS(&key, key.tun_opts_len),
-		       key.tun_opts_len);
-		tun_info->options = (struct geneve_opt *)(tun_info + 1);
+		memcpy((tun_info + 1), TUN_METADATA_OPTS(&key,
+		       key.tun_opts_len), key.tun_opts_len);
+		tun_info->options = (tun_info + 1);
 	} else {
 		tun_info->options = NULL;
 	}
-- 
1.9.3
