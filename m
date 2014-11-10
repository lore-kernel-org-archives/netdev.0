From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 6/6] openvswitch: Add support for OVS_FLOW_ATTR_PROBE.
Date: Sun,  9 Nov 2014 19:59:27 -0800
Message-ID: <1415591967-1709-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Jarno Rajahalme <jrajahalme@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog120.obsmtp.com ([74.125.149.140]:55969 "HELO
	na3sys009aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752088AbaKJD7b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Nov 2014 22:59:31 -0500
Received: by mail-pa0-f53.google.com with SMTP id kx10so7263827pab.26
        for <netdev@vger.kernel.org>; Sun, 09 Nov 2014 19:59:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarno Rajahalme <jrajahalme@nicira.com>

This new flag is useful for suppressing error logging while probing
for datapath features using flow commands.  For backwards
compatibility reasons the commands are executed normally, but error
logging is suppressed.

Signed-off-by: Jarno Rajahalme <jrajahalme@nicira.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 include/uapi/linux/openvswitch.h |   2 +
 net/openvswitch/datapath.c       |  49 ++++---
 net/openvswitch/datapath.h       |   6 +-
 net/openvswitch/flow.c           |   4 +-
 net/openvswitch/flow.h           |   2 +-
 net/openvswitch/flow_netlink.c   | 303 +++++++++++++++++++++------------------
 net/openvswitch/flow_netlink.h   |  10 +-
 7 files changed, 208 insertions(+), 168 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index cf81856..3a6dcaa 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -457,6 +457,8 @@ enum ovs_flow_attr {
 	OVS_FLOW_ATTR_USED,      /* u64 msecs last used in monotonic time. */
 	OVS_FLOW_ATTR_CLEAR,     /* Flag to clear stats, tcp_flags, used. */
 	OVS_FLOW_ATTR_MASK,      /* Sequence of OVS_KEY_ATTR_* attributes. */
+	OVS_FLOW_ATTR_PROBE,     /* Flow operation is a feature probe, error
+				  * logging should be suppressed. */
 	__OVS_FLOW_ATTR_MAX
 };
 
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 65561eb..ab141d4 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -526,6 +526,7 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	struct vport *input_vport;
 	int len;
 	int err;
+	bool log = !a[OVS_FLOW_ATTR_PROBE];
 
 	err = -EINVAL;
 	if (!a[OVS_PACKET_ATTR_PACKET] || !a[OVS_PACKET_ATTR_KEY] ||
@@ -559,12 +560,12 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 		goto err_kfree_skb;
 
 	err = ovs_flow_key_extract_userspace(a[OVS_PACKET_ATTR_KEY], packet,
-					     &flow->key);
+					     &flow->key, log);
 	if (err)
 		goto err_flow_free;
 
 	err = ovs_nla_copy_actions(a[OVS_PACKET_ATTR_ACTIONS],
-				   &flow->key, &acts);
+				   &flow->key, &acts, log);
 	if (err)
 		goto err_flow_free;
 
@@ -855,15 +856,16 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	struct sw_flow_actions *acts;
 	struct sw_flow_match match;
 	int error;
+	bool log = !a[OVS_FLOW_ATTR_PROBE];
 
 	/* Must have key and actions. */
 	error = -EINVAL;
 	if (!a[OVS_FLOW_ATTR_KEY]) {
-		OVS_NLERR("Flow key attribute not present in new flow.\n");
+		OVS_NLERR(log, "Flow key attr not present in new flow.");
 		goto error;
 	}
 	if (!a[OVS_FLOW_ATTR_ACTIONS]) {
-		OVS_NLERR("Flow actions attribute not present in new flow.\n");
+		OVS_NLERR(log, "Flow actions attr not present in new flow.");
 		goto error;
 	}
 
@@ -878,8 +880,8 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 
 	/* Extract key. */
 	ovs_match_init(&match, &new_flow->unmasked_key, &mask);
-	error = ovs_nla_get_match(&match,
-				  a[OVS_FLOW_ATTR_KEY], a[OVS_FLOW_ATTR_MASK]);
+	error = ovs_nla_get_match(&match, a[OVS_FLOW_ATTR_KEY],
+				  a[OVS_FLOW_ATTR_MASK], log);
 	if (error)
 		goto err_kfree_flow;
 
@@ -887,9 +889,9 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 
 	/* Validate actions. */
 	error = ovs_nla_copy_actions(a[OVS_FLOW_ATTR_ACTIONS], &new_flow->key,
-				     &acts);
+				     &acts, log);
 	if (error) {
-		OVS_NLERR("Flow actions may not be safe on all matching packets.\n");
+		OVS_NLERR(log, "Flow actions may not be safe on all matching packets.");
 		goto err_kfree_flow;
 	}
 
@@ -942,6 +944,7 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 		}
 		/* The unmasked key has to be the same for flow updates. */
 		if (unlikely(!ovs_flow_cmp_unmasked_key(flow, &match))) {
+			/* Look for any overlapping flow. */
 			flow = ovs_flow_tbl_lookup_exact(&dp->table, &match);
 			if (!flow) {
 				error = -ENOENT;
@@ -984,16 +987,18 @@ error:
 /* Factor out action copy to avoid "Wframe-larger-than=1024" warning. */
 static struct sw_flow_actions *get_flow_actions(const struct nlattr *a,
 						const struct sw_flow_key *key,
-						const struct sw_flow_mask *mask)
+						const struct sw_flow_mask *mask,
+						bool log)
 {
 	struct sw_flow_actions *acts;
 	struct sw_flow_key masked_key;
 	int error;
 
 	ovs_flow_mask_key(&masked_key, key, mask);
-	error = ovs_nla_copy_actions(a, &masked_key, &acts);
+	error = ovs_nla_copy_actions(a, &masked_key, &acts, log);
 	if (error) {
-		OVS_NLERR("Actions may not be safe on all matching packets.\n");
+		OVS_NLERR(log,
+			  "Actions may not be safe on all matching packets");
 		return ERR_PTR(error);
 	}
 
@@ -1012,23 +1017,25 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
 	struct sw_flow_actions *old_acts = NULL, *acts = NULL;
 	struct sw_flow_match match;
 	int error;
+	bool log = !a[OVS_FLOW_ATTR_PROBE];
 
 	/* Extract key. */
 	error = -EINVAL;
 	if (!a[OVS_FLOW_ATTR_KEY]) {
-		OVS_NLERR("Flow key attribute not present in set flow.\n");
+		OVS_NLERR(log, "Flow key attribute not present in set flow.");
 		goto error;
 	}
 
 	ovs_match_init(&match, &key, &mask);
-	error = ovs_nla_get_match(&match,
-				  a[OVS_FLOW_ATTR_KEY], a[OVS_FLOW_ATTR_MASK]);
+	error = ovs_nla_get_match(&match, a[OVS_FLOW_ATTR_KEY],
+				  a[OVS_FLOW_ATTR_MASK], log);
 	if (error)
 		goto error;
 
 	/* Validate actions. */
 	if (a[OVS_FLOW_ATTR_ACTIONS]) {
-		acts = get_flow_actions(a[OVS_FLOW_ATTR_ACTIONS], &key, &mask);
+		acts = get_flow_actions(a[OVS_FLOW_ATTR_ACTIONS], &key, &mask,
+					log);
 		if (IS_ERR(acts)) {
 			error = PTR_ERR(acts);
 			goto error;
@@ -1109,14 +1116,16 @@ static int ovs_flow_cmd_get(struct sk_buff *skb, struct genl_info *info)
 	struct datapath *dp;
 	struct sw_flow_match match;
 	int err;
+	bool log = !a[OVS_FLOW_ATTR_PROBE];
 
 	if (!a[OVS_FLOW_ATTR_KEY]) {
-		OVS_NLERR("Flow get message rejected, Key attribute missing.\n");
+		OVS_NLERR(log,
+			  "Flow get message rejected, Key attribute missing.");
 		return -EINVAL;
 	}
 
 	ovs_match_init(&match, &key, NULL);
-	err = ovs_nla_get_match(&match, a[OVS_FLOW_ATTR_KEY], NULL);
+	err = ovs_nla_get_match(&match, a[OVS_FLOW_ATTR_KEY], NULL, log);
 	if (err)
 		return err;
 
@@ -1157,10 +1166,12 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	struct datapath *dp;
 	struct sw_flow_match match;
 	int err;
+	bool log = !a[OVS_FLOW_ATTR_PROBE];
 
 	if (likely(a[OVS_FLOW_ATTR_KEY])) {
 		ovs_match_init(&match, &key, NULL);
-		err = ovs_nla_get_match(&match, a[OVS_FLOW_ATTR_KEY], NULL);
+		err = ovs_nla_get_match(&match, a[OVS_FLOW_ATTR_KEY], NULL,
+					log);
 		if (unlikely(err))
 			return err;
 	}
@@ -1250,8 +1261,10 @@ static int ovs_flow_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
 
 static const struct nla_policy flow_policy[OVS_FLOW_ATTR_MAX + 1] = {
 	[OVS_FLOW_ATTR_KEY] = { .type = NLA_NESTED },
+	[OVS_FLOW_ATTR_MASK] = { .type = NLA_NESTED },
 	[OVS_FLOW_ATTR_ACTIONS] = { .type = NLA_NESTED },
 	[OVS_FLOW_ATTR_CLEAR] = { .type = NLA_FLAG },
+	[OVS_FLOW_ATTR_PROBE] = { .type = NLA_FLAG },
 };
 
 static const struct genl_ops dp_flow_genl_ops[] = {
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 8389c1d..3ece945 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -199,9 +199,9 @@ void ovs_dp_notify_wq(struct work_struct *work);
 int action_fifos_init(void);
 void action_fifos_exit(void);
 
-#define OVS_NLERR(fmt, ...)					\
+#define OVS_NLERR(logging_allowed, fmt, ...)			\
 do {								\
-	if (net_ratelimit())					\
-		pr_info("netlink: " fmt, ##__VA_ARGS__);	\
+	if (logging_allowed && net_ratelimit())			\
+		pr_info("netlink: " fmt "\n", ##__VA_ARGS__);	\
 } while (0)
 #endif /* datapath.h */
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 25e9abc..70bef2a 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -712,12 +712,12 @@ int ovs_flow_key_extract(const struct ovs_tunnel_info *tun_info,
 
 int ovs_flow_key_extract_userspace(const struct nlattr *attr,
 				   struct sk_buff *skb,
-				   struct sw_flow_key *key)
+				   struct sw_flow_key *key, bool log)
 {
 	int err;
 
 	/* Extract metadata from netlink attributes. */
-	err = ovs_nla_get_flow_metadata(attr, key);
+	err = ovs_nla_get_flow_metadata(attr, key, log);
 	if (err)
 		return err;
 
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index 9e0a787..a8b30f3 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -257,6 +257,6 @@ int ovs_flow_key_extract(const struct ovs_tunnel_info *tun_info,
 /* Extract key from packet coming from userspace. */
 int ovs_flow_key_extract_userspace(const struct nlattr *attr,
 				   struct sk_buff *skb,
-				   struct sw_flow_key *key);
+				   struct sw_flow_key *key, bool log);
 
 #endif /* flow.h */
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 98a3e96..c0d066d 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -112,7 +112,7 @@ static void update_range(struct sw_flow_match *match,
 	} while (0)
 
 static bool match_validate(const struct sw_flow_match *match,
-			   u64 key_attrs, u64 mask_attrs)
+			   u64 key_attrs, u64 mask_attrs, bool log)
 {
 	u64 key_expected = 1 << OVS_KEY_ATTR_ETHERNET;
 	u64 mask_allowed = key_attrs;  /* At most allow all key attributes */
@@ -230,15 +230,17 @@ static bool match_validate(const struct sw_flow_match *match,
 
 	if ((key_attrs & key_expected) != key_expected) {
 		/* Key attributes check failed. */
-		OVS_NLERR("Missing expected key attributes (key_attrs=%llx, expected=%llx).\n",
-				(unsigned long long)key_attrs, (unsigned long long)key_expected);
+		OVS_NLERR(log, "Missing key (keys=%llx, expected=%llx)",
+			  (unsigned long long)key_attrs,
+			  (unsigned long long)key_expected);
 		return false;
 	}
 
 	if ((mask_attrs & mask_allowed) != mask_attrs) {
 		/* Mask attributes check failed. */
-		OVS_NLERR("Contain more than allowed mask fields (mask_attrs=%llx, mask_allowed=%llx).\n",
-				(unsigned long long)mask_attrs, (unsigned long long)mask_allowed);
+		OVS_NLERR(log, "Unexpected mask (mask=%llx, allowed=%llx)",
+			  (unsigned long long)mask_attrs,
+			  (unsigned long long)mask_allowed);
 		return false;
 	}
 
@@ -328,7 +330,7 @@ static bool is_all_zero(const u8 *fp, size_t size)
 
 static int __parse_flow_nlattrs(const struct nlattr *attr,
 				const struct nlattr *a[],
-				u64 *attrsp, bool nz)
+				u64 *attrsp, bool log, bool nz)
 {
 	const struct nlattr *nla;
 	u64 attrs;
@@ -340,21 +342,20 @@ static int __parse_flow_nlattrs(const struct nlattr *attr,
 		int expected_len;
 
 		if (type > OVS_KEY_ATTR_MAX) {
-			OVS_NLERR("Unknown key attribute (type=%d, max=%d).\n",
+			OVS_NLERR(log, "Key type %d is out of range max %d",
 				  type, OVS_KEY_ATTR_MAX);
 			return -EINVAL;
 		}
 
 		if (attrs & (1 << type)) {
-			OVS_NLERR("Duplicate key attribute (type %d).\n", type);
+			OVS_NLERR(log, "Duplicate key (type %d).", type);
 			return -EINVAL;
 		}
 
 		expected_len = ovs_key_lens[type];
 		if (nla_len(nla) != expected_len && expected_len != -1) {
-			OVS_NLERR("Key attribute has unexpected length (type=%d"
-				  ", length=%d, expected=%d).\n", type,
-				  nla_len(nla), expected_len);
+			OVS_NLERR(log, "Key %d has unexpected len %d expected %d",
+				  type, nla_len(nla), expected_len);
 			return -EINVAL;
 		}
 
@@ -364,7 +365,7 @@ static int __parse_flow_nlattrs(const struct nlattr *attr,
 		}
 	}
 	if (rem) {
-		OVS_NLERR("Message has %d unknown bytes.\n", rem);
+		OVS_NLERR(log, "Message has %d unknown bytes.", rem);
 		return -EINVAL;
 	}
 
@@ -373,28 +374,84 @@ static int __parse_flow_nlattrs(const struct nlattr *attr,
 }
 
 static int parse_flow_mask_nlattrs(const struct nlattr *attr,
-				   const struct nlattr *a[], u64 *attrsp)
+				   const struct nlattr *a[], u64 *attrsp,
+				   bool log)
 {
-	return __parse_flow_nlattrs(attr, a, attrsp, true);
+	return __parse_flow_nlattrs(attr, a, attrsp, log, true);
 }
 
 static int parse_flow_nlattrs(const struct nlattr *attr,
-			      const struct nlattr *a[], u64 *attrsp)
+			      const struct nlattr *a[], u64 *attrsp,
+			      bool log)
 {
-	return __parse_flow_nlattrs(attr, a, attrsp, false);
+	return __parse_flow_nlattrs(attr, a, attrsp, log, false);
+}
+
+static int genev_tun_opt_from_nlattr(const struct nlattr *a,
+				     struct sw_flow_match *match, bool is_mask,
+				     bool log)
+{
+	unsigned long opt_key_offset;
+
+	if (nla_len(a) > sizeof(match->key->tun_opts)) {
+		OVS_NLERR(log, "Geneve option length err (len %d, max %zu).",
+			  nla_len(a), sizeof(match->key->tun_opts));
+		return -EINVAL;
+	}
+
+	if (nla_len(a) % 4 != 0) {
+		OVS_NLERR(log, "Geneve opt len %d is not a multiple of 4.",
+			  nla_len(a));
+		return -EINVAL;
+	}
+
+	/* We need to record the length of the options passed
+	 * down, otherwise packets with the same format but
+	 * additional options will be silently matched.
+	 */
+	if (!is_mask) {
+		SW_FLOW_KEY_PUT(match, tun_opts_len, nla_len(a),
+				false);
+	} else {
+		/* This is somewhat unusual because it looks at
+		 * both the key and mask while parsing the
+		 * attributes (and by extension assumes the key
+		 * is parsed first). Normally, we would verify
+		 * that each is the correct length and that the
+		 * attributes line up in the validate function.
+		 * However, that is difficult because this is
+		 * variable length and we won't have the
+		 * information later.
+		 */
+		if (match->key->tun_opts_len != nla_len(a)) {
+			OVS_NLERR(log, "Geneve option len %d != mask len %d",
+				  match->key->tun_opts_len, nla_len(a));
+			return -EINVAL;
+		}
+
+		SW_FLOW_KEY_PUT(match, tun_opts_len, 0xff, true);
+	}
+
+	opt_key_offset = (unsigned long)GENEVE_OPTS((struct sw_flow_key *)0,
+						    nla_len(a));
+	SW_FLOW_KEY_MEMCPY_OFFSET(match, opt_key_offset, nla_data(a),
+				  nla_len(a), is_mask);
+	return 0;
 }
 
 static int ipv4_tun_from_nlattr(const struct nlattr *attr,
-				struct sw_flow_match *match, bool is_mask)
+				struct sw_flow_match *match, bool is_mask,
+				bool log)
 {
 	struct nlattr *a;
 	int rem;
 	bool ttl = false;
 	__be16 tun_flags = 0;
-	unsigned long opt_key_offset;
 
 	nla_for_each_nested(a, attr, rem) {
 		int type = nla_type(a);
+		int err;
+
 		static const u32 ovs_tunnel_key_lens[OVS_TUNNEL_KEY_ATTR_MAX + 1] = {
 			[OVS_TUNNEL_KEY_ATTR_ID] = sizeof(u64),
 			[OVS_TUNNEL_KEY_ATTR_IPV4_SRC] = sizeof(u32),
@@ -410,15 +467,14 @@ static int ipv4_tun_from_nlattr(const struct nlattr *attr,
 		};
 
 		if (type > OVS_TUNNEL_KEY_ATTR_MAX) {
-			OVS_NLERR("Unknown IPv4 tunnel attribute (type=%d, max=%d).\n",
-			type, OVS_TUNNEL_KEY_ATTR_MAX);
+			OVS_NLERR(log, "Tunnel attr %d out of range max %d",
+				  type, OVS_TUNNEL_KEY_ATTR_MAX);
 			return -EINVAL;
 		}
 
 		if (ovs_tunnel_key_lens[type] != nla_len(a) &&
 		    ovs_tunnel_key_lens[type] != -1) {
-			OVS_NLERR("IPv4 tunnel attribute type has unexpected "
-				  " length (type=%d, length=%d, expected=%d).\n",
+			OVS_NLERR(log, "Tunnel attr %d has unexpected len %d expected %d",
 				  type, nla_len(a), ovs_tunnel_key_lens[type]);
 			return -EINVAL;
 		}
@@ -464,58 +520,14 @@ static int ipv4_tun_from_nlattr(const struct nlattr *attr,
 			tun_flags |= TUNNEL_OAM;
 			break;
 		case OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS:
-			tun_flags |= TUNNEL_OPTIONS_PRESENT;
-			if (nla_len(a) > sizeof(match->key->tun_opts)) {
-				OVS_NLERR("Geneve option length exceeds maximum size (len %d, max %zu).\n",
-					  nla_len(a),
-					  sizeof(match->key->tun_opts));
-				return -EINVAL;
-			}
-
-			if (nla_len(a) % 4 != 0) {
-				OVS_NLERR("Geneve option length is not a multiple of 4 (len %d).\n",
-					  nla_len(a));
-				return -EINVAL;
-			}
-
-			/* We need to record the length of the options passed
-			 * down, otherwise packets with the same format but
-			 * additional options will be silently matched.
-			 */
-			if (!is_mask) {
-				SW_FLOW_KEY_PUT(match, tun_opts_len, nla_len(a),
-						false);
-			} else {
-				/* This is somewhat unusual because it looks at
-				 * both the key and mask while parsing the
-				 * attributes (and by extension assumes the key
-				 * is parsed first). Normally, we would verify
-				 * that each is the correct length and that the
-				 * attributes line up in the validate function.
-				 * However, that is difficult because this is
-				 * variable length and we won't have the
-				 * information later.
-				 */
-				if (match->key->tun_opts_len != nla_len(a)) {
-					OVS_NLERR("Geneve option key length (%d) is different from mask length (%d).",
-						  match->key->tun_opts_len,
-						  nla_len(a));
-					return -EINVAL;
-				}
-
-				SW_FLOW_KEY_PUT(match, tun_opts_len, 0xff,
-						true);
-			}
+			err = genev_tun_opt_from_nlattr(a, match, is_mask, log);
+			if (err)
+				return err;
 
-			opt_key_offset = (unsigned long)GENEVE_OPTS(
-					  (struct sw_flow_key *)0,
-					  nla_len(a));
-			SW_FLOW_KEY_MEMCPY_OFFSET(match, opt_key_offset,
-						  nla_data(a), nla_len(a),
-						  is_mask);
+			tun_flags |= TUNNEL_OPTIONS_PRESENT;
 			break;
 		default:
-			OVS_NLERR("Unknown IPv4 tunnel attribute (%d).\n",
+			OVS_NLERR(log, "Unknown IPv4 tunnel attribute %d",
 				  type);
 			return -EINVAL;
 		}
@@ -524,18 +536,19 @@ static int ipv4_tun_from_nlattr(const struct nlattr *attr,
 	SW_FLOW_KEY_PUT(match, tun_key.tun_flags, tun_flags, is_mask);
 
 	if (rem > 0) {
-		OVS_NLERR("IPv4 tunnel attribute has %d unknown bytes.\n", rem);
+		OVS_NLERR(log, "IPv4 tunnel attribute has %d unknown bytes.",
+			  rem);
 		return -EINVAL;
 	}
 
 	if (!is_mask) {
 		if (!match->key->tun_key.ipv4_dst) {
-			OVS_NLERR("IPv4 tunnel destination address is zero.\n");
+			OVS_NLERR(log, "IPv4 tunnel dst address is zero");
 			return -EINVAL;
 		}
 
 		if (!ttl) {
-			OVS_NLERR("IPv4 tunnel TTL not specified.\n");
+			OVS_NLERR(log, "IPv4 tunnel TTL not specified.");
 			return -EINVAL;
 		}
 	}
@@ -614,7 +627,8 @@ int ovs_nla_put_egress_tunnel_key(struct sk_buff *skb,
 }
 
 static int metadata_from_nlattrs(struct sw_flow_match *match,  u64 *attrs,
-				 const struct nlattr **a, bool is_mask)
+				 const struct nlattr **a, bool is_mask,
+				 bool log)
 {
 	if (*attrs & (1 << OVS_KEY_ATTR_DP_HASH)) {
 		u32 hash_val = nla_get_u32(a[OVS_KEY_ATTR_DP_HASH]);
@@ -642,7 +656,7 @@ static int metadata_from_nlattrs(struct sw_flow_match *match,  u64 *attrs,
 		if (is_mask) {
 			in_port = 0xffffffff; /* Always exact match in_port. */
 		} else if (in_port >= DP_MAX_PORTS) {
-			OVS_NLERR("Port (%d) exceeds maximum allowable (%d).\n",
+			OVS_NLERR(log, "Port %d exceeds max allowable %d",
 				  in_port, DP_MAX_PORTS);
 			return -EINVAL;
 		}
@@ -661,7 +675,7 @@ static int metadata_from_nlattrs(struct sw_flow_match *match,  u64 *attrs,
 	}
 	if (*attrs & (1 << OVS_KEY_ATTR_TUNNEL)) {
 		if (ipv4_tun_from_nlattr(a[OVS_KEY_ATTR_TUNNEL], match,
-					 is_mask))
+					 is_mask, log))
 			return -EINVAL;
 		*attrs &= ~(1 << OVS_KEY_ATTR_TUNNEL);
 	}
@@ -669,11 +683,12 @@ static int metadata_from_nlattrs(struct sw_flow_match *match,  u64 *attrs,
 }
 
 static int ovs_key_from_nlattrs(struct sw_flow_match *match, u64 attrs,
-				const struct nlattr **a, bool is_mask)
+				const struct nlattr **a, bool is_mask,
+				bool log)
 {
 	int err;
 
-	err = metadata_from_nlattrs(match, &attrs, a, is_mask);
+	err = metadata_from_nlattrs(match, &attrs, a, is_mask, log);
 	if (err)
 		return err;
 
@@ -694,9 +709,9 @@ static int ovs_key_from_nlattrs(struct sw_flow_match *match, u64 attrs,
 		tci = nla_get_be16(a[OVS_KEY_ATTR_VLAN]);
 		if (!(tci & htons(VLAN_TAG_PRESENT))) {
 			if (is_mask)
-				OVS_NLERR("VLAN TCI mask does not have exact match for VLAN_TAG_PRESENT bit.\n");
+				OVS_NLERR(log, "VLAN TCI mask does not have exact match for VLAN_TAG_PRESENT bit.");
 			else
-				OVS_NLERR("VLAN TCI does not have VLAN_TAG_PRESENT bit set.\n");
+				OVS_NLERR(log, "VLAN TCI does not have VLAN_TAG_PRESENT bit set.");
 
 			return -EINVAL;
 		}
@@ -713,8 +728,8 @@ static int ovs_key_from_nlattrs(struct sw_flow_match *match, u64 attrs,
 			/* Always exact match EtherType. */
 			eth_type = htons(0xffff);
 		} else if (ntohs(eth_type) < ETH_P_802_3_MIN) {
-			OVS_NLERR("EtherType is less than minimum (type=%x, min=%x).\n",
-					ntohs(eth_type), ETH_P_802_3_MIN);
+			OVS_NLERR(log, "EtherType %x is less than min %x",
+				  ntohs(eth_type), ETH_P_802_3_MIN);
 			return -EINVAL;
 		}
 
@@ -729,8 +744,8 @@ static int ovs_key_from_nlattrs(struct sw_flow_match *match, u64 attrs,
 
 		ipv4_key = nla_data(a[OVS_KEY_ATTR_IPV4]);
 		if (!is_mask && ipv4_key->ipv4_frag > OVS_FRAG_TYPE_MAX) {
-			OVS_NLERR("Unknown IPv4 fragment type (value=%d, max=%d).\n",
-				ipv4_key->ipv4_frag, OVS_FRAG_TYPE_MAX);
+			OVS_NLERR(log, "IPv4 frag type %d is out of range max %d",
+				  ipv4_key->ipv4_frag, OVS_FRAG_TYPE_MAX);
 			return -EINVAL;
 		}
 		SW_FLOW_KEY_PUT(match, ip.proto,
@@ -753,8 +768,8 @@ static int ovs_key_from_nlattrs(struct sw_flow_match *match, u64 attrs,
 
 		ipv6_key = nla_data(a[OVS_KEY_ATTR_IPV6]);
 		if (!is_mask && ipv6_key->ipv6_frag > OVS_FRAG_TYPE_MAX) {
-			OVS_NLERR("Unknown IPv6 fragment type (value=%d, max=%d).\n",
-				ipv6_key->ipv6_frag, OVS_FRAG_TYPE_MAX);
+			OVS_NLERR(log, "IPv6 frag type %d is out of range max %d",
+				  ipv6_key->ipv6_frag, OVS_FRAG_TYPE_MAX);
 			return -EINVAL;
 		}
 		SW_FLOW_KEY_PUT(match, ipv6.label,
@@ -784,7 +799,7 @@ static int ovs_key_from_nlattrs(struct sw_flow_match *match, u64 attrs,
 
 		arp_key = nla_data(a[OVS_KEY_ATTR_ARP]);
 		if (!is_mask && (arp_key->arp_op & htons(0xff00))) {
-			OVS_NLERR("Unknown ARP opcode (opcode=%d).\n",
+			OVS_NLERR(log, "Unknown ARP opcode (opcode=%d).",
 				  arp_key->arp_op);
 			return -EINVAL;
 		}
@@ -885,7 +900,7 @@ static int ovs_key_from_nlattrs(struct sw_flow_match *match, u64 attrs,
 	}
 
 	if (attrs != 0) {
-		OVS_NLERR("Unknown key attributes (%llx).\n",
+		OVS_NLERR(log, "Unknown key attributes %llx",
 			  (unsigned long long)attrs);
 		return -EINVAL;
 	}
@@ -926,10 +941,14 @@ static void mask_set_nlattr(struct nlattr *attr, u8 val)
  * of this flow.
  * @mask: Optional. Netlink attribute holding nested %OVS_KEY_ATTR_* Netlink
  * attribute specifies the mask field of the wildcarded flow.
+ * @log: Boolean to allow kernel error logging.  Normally true, but when
+ * probing for feature compatibility this should be passed in as false to
+ * suppress unnecessary error logging.
  */
 int ovs_nla_get_match(struct sw_flow_match *match,
 		      const struct nlattr *nla_key,
-		      const struct nlattr *nla_mask)
+		      const struct nlattr *nla_mask,
+		      bool log)
 {
 	const struct nlattr *a[OVS_KEY_ATTR_MAX + 1];
 	const struct nlattr *encap;
@@ -939,7 +958,7 @@ int ovs_nla_get_match(struct sw_flow_match *match,
 	bool encap_valid = false;
 	int err;
 
-	err = parse_flow_nlattrs(nla_key, a, &key_attrs);
+	err = parse_flow_nlattrs(nla_key, a, &key_attrs, log);
 	if (err)
 		return err;
 
@@ -950,7 +969,7 @@ int ovs_nla_get_match(struct sw_flow_match *match,
 
 		if (!((key_attrs & (1 << OVS_KEY_ATTR_VLAN)) &&
 		      (key_attrs & (1 << OVS_KEY_ATTR_ENCAP)))) {
-			OVS_NLERR("Invalid Vlan frame.\n");
+			OVS_NLERR(log, "Invalid Vlan frame.");
 			return -EINVAL;
 		}
 
@@ -961,22 +980,22 @@ int ovs_nla_get_match(struct sw_flow_match *match,
 		encap_valid = true;
 
 		if (tci & htons(VLAN_TAG_PRESENT)) {
-			err = parse_flow_nlattrs(encap, a, &key_attrs);
+			err = parse_flow_nlattrs(encap, a, &key_attrs, log);
 			if (err)
 				return err;
 		} else if (!tci) {
 			/* Corner case for truncated 802.1Q header. */
 			if (nla_len(encap)) {
-				OVS_NLERR("Truncated 802.1Q header has non-zero encap attribute.\n");
+				OVS_NLERR(log, "Truncated 802.1Q header has non-zero encap attribute.");
 				return -EINVAL;
 			}
 		} else {
-			OVS_NLERR("Encap attribute is set for a non-VLAN frame.\n");
+			OVS_NLERR(log, "Encap attr is set for non-VLAN frame");
 			return  -EINVAL;
 		}
 	}
 
-	err = ovs_key_from_nlattrs(match, key_attrs, a, false);
+	err = ovs_key_from_nlattrs(match, key_attrs, a, false, log);
 	if (err)
 		return err;
 
@@ -1010,7 +1029,7 @@ int ovs_nla_get_match(struct sw_flow_match *match,
 			nla_mask = newmask;
 		}
 
-		err = parse_flow_mask_nlattrs(nla_mask, a, &mask_attrs);
+		err = parse_flow_mask_nlattrs(nla_mask, a, &mask_attrs, log);
 		if (err)
 			goto free_newmask;
 
@@ -1022,7 +1041,7 @@ int ovs_nla_get_match(struct sw_flow_match *match,
 			__be16 tci = 0;
 
 			if (!encap_valid) {
-				OVS_NLERR("Encap mask attribute is set for non-VLAN frame.\n");
+				OVS_NLERR(log, "Encap mask attribute is set for non-VLAN frame.");
 				err = -EINVAL;
 				goto free_newmask;
 			}
@@ -1034,12 +1053,13 @@ int ovs_nla_get_match(struct sw_flow_match *match,
 			if (eth_type == htons(0xffff)) {
 				mask_attrs &= ~(1 << OVS_KEY_ATTR_ETHERTYPE);
 				encap = a[OVS_KEY_ATTR_ENCAP];
-				err = parse_flow_mask_nlattrs(encap, a, &mask_attrs);
+				err = parse_flow_mask_nlattrs(encap, a,
+							      &mask_attrs, log);
 				if (err)
 					goto free_newmask;
 			} else {
-				OVS_NLERR("VLAN frames must have an exact match on the TPID (mask=%x).\n",
-						ntohs(eth_type));
+				OVS_NLERR(log, "VLAN frames must have an exact match on the TPID (mask=%x).",
+					  ntohs(eth_type));
 				err = -EINVAL;
 				goto free_newmask;
 			}
@@ -1048,18 +1068,19 @@ int ovs_nla_get_match(struct sw_flow_match *match,
 				tci = nla_get_be16(a[OVS_KEY_ATTR_VLAN]);
 
 			if (!(tci & htons(VLAN_TAG_PRESENT))) {
-				OVS_NLERR("VLAN tag present bit must have an exact match (tci_mask=%x).\n", ntohs(tci));
+				OVS_NLERR(log, "VLAN tag present bit must have an exact match (tci_mask=%x).",
+					  ntohs(tci));
 				err = -EINVAL;
 				goto free_newmask;
 			}
 		}
 
-		err = ovs_key_from_nlattrs(match, mask_attrs, a, true);
+		err = ovs_key_from_nlattrs(match, mask_attrs, a, true, log);
 		if (err)
 			goto free_newmask;
 	}
 
-	if (!match_validate(match, key_attrs, mask_attrs))
+	if (!match_validate(match, key_attrs, mask_attrs, log))
 		err = -EINVAL;
 
 free_newmask:
@@ -1072,6 +1093,9 @@ free_newmask:
  * @key: Receives extracted in_port, priority, tun_key and skb_mark.
  * @attr: Netlink attribute holding nested %OVS_KEY_ATTR_* Netlink attribute
  * sequence.
+ * @log: Boolean to allow kernel error logging.  Normally true, but when
+ * probing for feature compatibility this should be passed in as false to
+ * suppress unnecessary error logging.
  *
  * This parses a series of Netlink attributes that form a flow key, which must
  * take the same form accepted by flow_from_nlattrs(), but only enough of it to
@@ -1080,14 +1104,15 @@ free_newmask:
  */
 
 int ovs_nla_get_flow_metadata(const struct nlattr *attr,
-			      struct sw_flow_key *key)
+			      struct sw_flow_key *key,
+			      bool log)
 {
 	const struct nlattr *a[OVS_KEY_ATTR_MAX + 1];
 	struct sw_flow_match match;
 	u64 attrs = 0;
 	int err;
 
-	err = parse_flow_nlattrs(attr, a, &attrs);
+	err = parse_flow_nlattrs(attr, a, &attrs, log);
 	if (err)
 		return -EINVAL;
 
@@ -1096,7 +1121,7 @@ int ovs_nla_get_flow_metadata(const struct nlattr *attr,
 
 	key->phy.in_port = DP_MAX_PORTS;
 
-	return metadata_from_nlattrs(&match, &attrs, a, false);
+	return metadata_from_nlattrs(&match, &attrs, a, false, log);
 }
 
 int ovs_nla_put_flow(const struct sw_flow_key *swkey,
@@ -1316,12 +1341,12 @@ nla_put_failure:
 
 #define MAX_ACTIONS_BUFSIZE	(32 * 1024)
 
-static struct sw_flow_actions *nla_alloc_flow_actions(int size)
+static struct sw_flow_actions *nla_alloc_flow_actions(int size, bool log)
 {
 	struct sw_flow_actions *sfa;
 
 	if (size > MAX_ACTIONS_BUFSIZE) {
-		OVS_NLERR("Flow action size (%u bytes) exceeds maximum", size);
+		OVS_NLERR(log, "Flow action size %u bytes exceeds max", size);
 		return ERR_PTR(-EINVAL);
 	}
 
@@ -1341,7 +1366,7 @@ void ovs_nla_free_flow_actions(struct sw_flow_actions *sf_acts)
 }
 
 static struct nlattr *reserve_sfa_size(struct sw_flow_actions **sfa,
-				       int attr_len)
+				       int attr_len, bool log)
 {
 
 	struct sw_flow_actions *acts;
@@ -1361,7 +1386,7 @@ static struct nlattr *reserve_sfa_size(struct sw_flow_actions **sfa,
 		new_acts_size = MAX_ACTIONS_BUFSIZE;
 	}
 
-	acts = nla_alloc_flow_actions(new_acts_size);
+	acts = nla_alloc_flow_actions(new_acts_size, log);
 	if (IS_ERR(acts))
 		return (void *)acts;
 
@@ -1376,11 +1401,11 @@ out:
 }
 
 static struct nlattr *__add_action(struct sw_flow_actions **sfa,
-				   int attrtype, void *data, int len)
+				   int attrtype, void *data, int len, bool log)
 {
 	struct nlattr *a;
 
-	a = reserve_sfa_size(sfa, nla_attr_size(len));
+	a = reserve_sfa_size(sfa, nla_attr_size(len), log);
 	if (IS_ERR(a))
 		return a;
 
@@ -1395,11 +1420,11 @@ static struct nlattr *__add_action(struct sw_flow_actions **sfa,
 }
 
 static int add_action(struct sw_flow_actions **sfa, int attrtype,
-		      void *data, int len)
+		      void *data, int len, bool log)
 {
 	struct nlattr *a;
 
-	a = __add_action(sfa, attrtype, data, len);
+	a = __add_action(sfa, attrtype, data, len, log);
 	if (IS_ERR(a))
 		return PTR_ERR(a);
 
@@ -1407,12 +1432,12 @@ static int add_action(struct sw_flow_actions **sfa, int attrtype,
 }
 
 static inline int add_nested_action_start(struct sw_flow_actions **sfa,
-					  int attrtype)
+					  int attrtype, bool log)
 {
 	int used = (*sfa)->actions_len;
 	int err;
 
-	err = add_action(sfa, attrtype, NULL, 0);
+	err = add_action(sfa, attrtype, NULL, 0, log);
 	if (err)
 		return err;
 
@@ -1431,12 +1456,12 @@ static inline void add_nested_action_end(struct sw_flow_actions *sfa,
 static int __ovs_nla_copy_actions(const struct nlattr *attr,
 				  const struct sw_flow_key *key,
 				  int depth, struct sw_flow_actions **sfa,
-				  __be16 eth_type, __be16 vlan_tci);
+				  __be16 eth_type, __be16 vlan_tci, bool log);
 
 static int validate_and_copy_sample(const struct nlattr *attr,
 				    const struct sw_flow_key *key, int depth,
 				    struct sw_flow_actions **sfa,
-				    __be16 eth_type, __be16 vlan_tci)
+				    __be16 eth_type, __be16 vlan_tci, bool log)
 {
 	const struct nlattr *attrs[OVS_SAMPLE_ATTR_MAX + 1];
 	const struct nlattr *probability, *actions;
@@ -1462,19 +1487,19 @@ static int validate_and_copy_sample(const struct nlattr *attr,
 		return -EINVAL;
 
 	/* validation done, copy sample action. */
-	start = add_nested_action_start(sfa, OVS_ACTION_ATTR_SAMPLE);
+	start = add_nested_action_start(sfa, OVS_ACTION_ATTR_SAMPLE, log);
 	if (start < 0)
 		return start;
 	err = add_action(sfa, OVS_SAMPLE_ATTR_PROBABILITY,
-			 nla_data(probability), sizeof(u32));
+			 nla_data(probability), sizeof(u32), log);
 	if (err)
 		return err;
-	st_acts = add_nested_action_start(sfa, OVS_SAMPLE_ATTR_ACTIONS);
+	st_acts = add_nested_action_start(sfa, OVS_SAMPLE_ATTR_ACTIONS, log);
 	if (st_acts < 0)
 		return st_acts;
 
 	err = __ovs_nla_copy_actions(actions, key, depth + 1, sfa,
-				     eth_type, vlan_tci);
+				     eth_type, vlan_tci, log);
 	if (err)
 		return err;
 
@@ -1511,7 +1536,7 @@ void ovs_match_init(struct sw_flow_match *match,
 }
 
 static int validate_and_copy_set_tun(const struct nlattr *attr,
-				     struct sw_flow_actions **sfa)
+				     struct sw_flow_actions **sfa, bool log)
 {
 	struct sw_flow_match match;
 	struct sw_flow_key key;
@@ -1520,7 +1545,7 @@ static int validate_and_copy_set_tun(const struct nlattr *attr,
 	int err, start;
 
 	ovs_match_init(&match, &key, NULL);
-	err = ipv4_tun_from_nlattr(nla_data(attr), &match, false);
+	err = ipv4_tun_from_nlattr(nla_data(attr), &match, false, log);
 	if (err)
 		return err;
 
@@ -1549,12 +1574,12 @@ static int validate_and_copy_set_tun(const struct nlattr *attr,
 		key.tun_key.tun_flags |= crit_opt ? TUNNEL_CRIT_OPT : 0;
 	};
 
-	start = add_nested_action_start(sfa, OVS_ACTION_ATTR_SET);
+	start = add_nested_action_start(sfa, OVS_ACTION_ATTR_SET, log);
 	if (start < 0)
 		return start;
 
 	a = __add_action(sfa, OVS_KEY_ATTR_TUNNEL_INFO, NULL,
-			 sizeof(*tun_info) + key.tun_opts_len);
+			 sizeof(*tun_info) + key.tun_opts_len, log);
 	if (IS_ERR(a))
 		return PTR_ERR(a);
 
@@ -1582,7 +1607,7 @@ static int validate_and_copy_set_tun(const struct nlattr *attr,
 static int validate_set(const struct nlattr *a,
 			const struct sw_flow_key *flow_key,
 			struct sw_flow_actions **sfa,
-			bool *set_tun, __be16 eth_type)
+			bool *set_tun, __be16 eth_type, bool log)
 {
 	const struct nlattr *ovs_key = nla_data(a);
 	int key_type = nla_type(ovs_key);
@@ -1611,7 +1636,7 @@ static int validate_set(const struct nlattr *a,
 			return -EINVAL;
 
 		*set_tun = true;
-		err = validate_and_copy_set_tun(a, sfa);
+		err = validate_and_copy_set_tun(a, sfa, log);
 		if (err)
 			return err;
 		break;
@@ -1704,12 +1729,12 @@ static int validate_userspace(const struct nlattr *attr)
 }
 
 static int copy_action(const struct nlattr *from,
-		       struct sw_flow_actions **sfa)
+		       struct sw_flow_actions **sfa, bool log)
 {
 	int totlen = NLA_ALIGN(from->nla_len);
 	struct nlattr *to;
 
-	to = reserve_sfa_size(sfa, from->nla_len);
+	to = reserve_sfa_size(sfa, from->nla_len, log);
 	if (IS_ERR(to))
 		return PTR_ERR(to);
 
@@ -1720,7 +1745,7 @@ static int copy_action(const struct nlattr *from,
 static int __ovs_nla_copy_actions(const struct nlattr *attr,
 				  const struct sw_flow_key *key,
 				  int depth, struct sw_flow_actions **sfa,
-				  __be16 eth_type, __be16 vlan_tci)
+				  __be16 eth_type, __be16 vlan_tci, bool log)
 {
 	const struct nlattr *a;
 	bool out_tnl_port = false;
@@ -1843,7 +1868,7 @@ static int __ovs_nla_copy_actions(const struct nlattr *attr,
 
 		case OVS_ACTION_ATTR_SET:
 			err = validate_set(a, key, sfa,
-					   &out_tnl_port, eth_type);
+					   &out_tnl_port, eth_type, log);
 			if (err)
 				return err;
 
@@ -1852,18 +1877,18 @@ static int __ovs_nla_copy_actions(const struct nlattr *attr,
 
 		case OVS_ACTION_ATTR_SAMPLE:
 			err = validate_and_copy_sample(a, key, depth, sfa,
-						       eth_type, vlan_tci);
+						       eth_type, vlan_tci, log);
 			if (err)
 				return err;
 			skip_copy = true;
 			break;
 
 		default:
-			OVS_NLERR("Unknown tunnel attribute (%d).\n", type);
+			OVS_NLERR(log, "Unknown Action type %d", type);
 			return -EINVAL;
 		}
 		if (!skip_copy) {
-			err = copy_action(a, sfa);
+			err = copy_action(a, sfa, log);
 			if (err)
 				return err;
 		}
@@ -1877,16 +1902,16 @@ static int __ovs_nla_copy_actions(const struct nlattr *attr,
 
 int ovs_nla_copy_actions(const struct nlattr *attr,
 			 const struct sw_flow_key *key,
-			 struct sw_flow_actions **sfa)
+			 struct sw_flow_actions **sfa, bool log)
 {
 	int err;
 
-	*sfa = nla_alloc_flow_actions(nla_len(attr));
+	*sfa = nla_alloc_flow_actions(nla_len(attr), log);
 	if (IS_ERR(*sfa))
 		return PTR_ERR(*sfa);
 
 	err = __ovs_nla_copy_actions(attr, key, 0, sfa, key->eth.type,
-				     key->eth.tci);
+				     key->eth.tci, log);
 	if (err)
 		kfree(*sfa);
 
diff --git a/net/openvswitch/flow_netlink.h b/net/openvswitch/flow_netlink.h
index 90bbe37..577f12b 100644
--- a/net/openvswitch/flow_netlink.h
+++ b/net/openvswitch/flow_netlink.h
@@ -45,17 +45,17 @@ void ovs_match_init(struct sw_flow_match *match,
 
 int ovs_nla_put_flow(const struct sw_flow_key *,
 		     const struct sw_flow_key *, struct sk_buff *);
-int ovs_nla_get_flow_metadata(const struct nlattr *, struct sw_flow_key *);
+int ovs_nla_get_flow_metadata(const struct nlattr *, struct sw_flow_key *,
+			      bool log);
 
-int ovs_nla_get_match(struct sw_flow_match *match,
-		      const struct nlattr *,
-		      const struct nlattr *);
+int ovs_nla_get_match(struct sw_flow_match *, const struct nlattr *key,
+		      const struct nlattr *mask, bool log);
 int ovs_nla_put_egress_tunnel_key(struct sk_buff *,
 				  const struct ovs_tunnel_info *);
 
 int ovs_nla_copy_actions(const struct nlattr *attr,
 			 const struct sw_flow_key *key,
-			 struct sw_flow_actions **sfa);
+			 struct sw_flow_actions **sfa, bool log);
 int ovs_nla_put_actions(const struct nlattr *attr,
 			int len, struct sk_buff *skb);
 
-- 
1.9.3
