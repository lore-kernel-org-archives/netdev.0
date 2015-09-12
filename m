From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net v2] openvswitch: Fix mask generation for nested attributes.
Date: Fri, 11 Sep 2015 18:38:28 -0700
Message-ID: <1442021908-47034-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:36315 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752820AbbILBid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2015 21:38:33 -0400
Received: by padhk3 with SMTP id hk3so89265384pad.3
        for <netdev@vger.kernel.org>; Fri, 11 Sep 2015 18:38:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Masks were added to OVS flows in a way that was backwards compatible
with userspace programs that did not generate masks. As a result, it is
possible that we may receive flows that do not have a mask and we need
to synthesize one.

Generating a mask requires iterating over attributes and descending into
nested attributes. For each level we need to know the size to generate the
correct mask. We do this with a linked table of attribute types.

Although the logic to handle these nested attributes was there in concept,
there are a number of bugs in practice. Examples include incomplete links
between tables, variable length attributes being treated as nested and
missing sanity checks.

Signed-off-by: Jesse Gross <jesse@nicira.com>
---
v2: Fix whitespace errors.
    Add check for unknown bytes in VXLAN extensions.
    Factor out check for nested or variable attributes.
---
 net/openvswitch/flow_netlink.c | 82 ++++++++++++++++++++++++++++++------------
 1 file changed, 59 insertions(+), 23 deletions(-)

diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index c92d6a2..5c030a4 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -57,6 +57,7 @@ struct ovs_len_tbl {
 };
 
 #define OVS_ATTR_NESTED -1
+#define OVS_ATTR_VARIABLE -2
 
 static void update_range(struct sw_flow_match *match,
 			 size_t offset, size_t size, bool is_mask)
@@ -304,6 +305,10 @@ size_t ovs_key_attr_size(void)
 		+ nla_total_size(28); /* OVS_KEY_ATTR_ND */
 }
 
+static const struct ovs_len_tbl ovs_vxlan_ext_key_lens[OVS_VXLAN_EXT_MAX + 1] = {
+	[OVS_VXLAN_EXT_GBP]	    = { .len = sizeof(u32) },
+};
+
 static const struct ovs_len_tbl ovs_tunnel_key_lens[OVS_TUNNEL_KEY_ATTR_MAX + 1] = {
 	[OVS_TUNNEL_KEY_ATTR_ID]	    = { .len = sizeof(u64) },
 	[OVS_TUNNEL_KEY_ATTR_IPV4_SRC]	    = { .len = sizeof(u32) },
@@ -315,8 +320,9 @@ static const struct ovs_len_tbl ovs_tunnel_key_lens[OVS_TUNNEL_KEY_ATTR_MAX + 1]
 	[OVS_TUNNEL_KEY_ATTR_TP_SRC]	    = { .len = sizeof(u16) },
 	[OVS_TUNNEL_KEY_ATTR_TP_DST]	    = { .len = sizeof(u16) },
 	[OVS_TUNNEL_KEY_ATTR_OAM]	    = { .len = 0 },
-	[OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS]   = { .len = OVS_ATTR_NESTED },
-	[OVS_TUNNEL_KEY_ATTR_VXLAN_OPTS]    = { .len = OVS_ATTR_NESTED },
+	[OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS]   = { .len = OVS_ATTR_VARIABLE },
+	[OVS_TUNNEL_KEY_ATTR_VXLAN_OPTS]    = { .len = OVS_ATTR_NESTED,
+						.next = ovs_vxlan_ext_key_lens },
 };
 
 /* The size of the argument for each %OVS_KEY_ATTR_* Netlink attribute.  */
@@ -349,6 +355,13 @@ static const struct ovs_len_tbl ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
 	[OVS_KEY_ATTR_CT_LABEL]	 = { .len = sizeof(struct ovs_key_ct_label) },
 };
 
+static bool check_attr_len(unsigned int attr_len, unsigned int expected_len)
+{
+	return expected_len == attr_len ||
+	       expected_len == OVS_ATTR_NESTED ||
+	       expected_len == OVS_ATTR_VARIABLE;
+}
+
 static bool is_all_zero(const u8 *fp, size_t size)
 {
 	int i;
@@ -388,7 +401,7 @@ static int __parse_flow_nlattrs(const struct nlattr *attr,
 		}
 
 		expected_len = ovs_key_lens[type].len;
-		if (nla_len(nla) != expected_len && expected_len != OVS_ATTR_NESTED) {
+		if (!check_attr_len(nla_len(nla), expected_len)) {
 			OVS_NLERR(log, "Key %d has unexpected len %d expected %d",
 				  type, nla_len(nla), expected_len);
 			return -EINVAL;
@@ -473,29 +486,50 @@ static int genev_tun_opt_from_nlattr(const struct nlattr *a,
 	return 0;
 }
 
-static const struct nla_policy vxlan_opt_policy[OVS_VXLAN_EXT_MAX + 1] = {
-	[OVS_VXLAN_EXT_GBP]	= { .type = NLA_U32 },
-};
-
-static int vxlan_tun_opt_from_nlattr(const struct nlattr *a,
+static int vxlan_tun_opt_from_nlattr(const struct nlattr *attr,
 				     struct sw_flow_match *match, bool is_mask,
 				     bool log)
 {
-	struct nlattr *tb[OVS_VXLAN_EXT_MAX+1];
+	struct nlattr *a;
+	int rem;
 	unsigned long opt_key_offset;
 	struct vxlan_metadata opts;
-	int err;
 
 	BUILD_BUG_ON(sizeof(opts) > sizeof(match->key->tun_opts));
 
-	err = nla_parse_nested(tb, OVS_VXLAN_EXT_MAX, a, vxlan_opt_policy);
-	if (err < 0)
-		return err;
-
 	memset(&opts, 0, sizeof(opts));
+	nla_for_each_nested(a, attr, rem) {
+		int type = nla_type(a);
 
-	if (tb[OVS_VXLAN_EXT_GBP])
-		opts.gbp = nla_get_u32(tb[OVS_VXLAN_EXT_GBP]);
+		if (type > OVS_VXLAN_EXT_MAX) {
+			OVS_NLERR(log, "VXLAN extension %d out of range max %d",
+				  type, OVS_VXLAN_EXT_MAX);
+			return -EINVAL;
+		}
+
+		if (!check_attr_len(nla_len(a),
+				    ovs_vxlan_ext_key_lens[type].len)) {
+			OVS_NLERR(log, "VXLAN extension %d has unexpected len %d expected %d",
+				  type, nla_len(a),
+				  ovs_vxlan_ext_key_lens[type].len);
+			return -EINVAL;
+		}
+
+		switch (type) {
+		case OVS_VXLAN_EXT_GBP:
+			opts.gbp = nla_get_u32(a);
+			break;
+		default:
+			OVS_NLERR(log, "Unknown VXLAN extension attribute %d",
+				  type);
+			return -EINVAL;
+		}
+	}
+	if (rem) {
+		OVS_NLERR(log, "VXLAN extension message has %d unknown bytes.",
+			  rem);
+		return -EINVAL;
+	}
 
 	if (!is_mask)
 		SW_FLOW_KEY_PUT(match, tun_opts_len, sizeof(opts), false);
@@ -528,8 +562,8 @@ static int ipv4_tun_from_nlattr(const struct nlattr *attr,
 			return -EINVAL;
 		}
 
-		if (ovs_tunnel_key_lens[type].len != nla_len(a) &&
-		    ovs_tunnel_key_lens[type].len != OVS_ATTR_NESTED) {
+		if (!check_attr_len(nla_len(a),
+				    ovs_tunnel_key_lens[type].len)) {
 			OVS_NLERR(log, "Tunnel attr %d has unexpected len %d expected %d",
 				  type, nla_len(a), ovs_tunnel_key_lens[type].len);
 			return -EINVAL;
@@ -1052,10 +1086,13 @@ static void nlattr_set(struct nlattr *attr, u8 val,
 
 	/* The nlattr stream should already have been validated */
 	nla_for_each_nested(nla, attr, rem) {
-		if (tbl && tbl[nla_type(nla)].len == OVS_ATTR_NESTED)
-			nlattr_set(nla, val, tbl[nla_type(nla)].next);
-		else
+		if (tbl[nla_type(nla)].len == OVS_ATTR_NESTED) {
+			if (tbl[nla_type(nla)].next)
+				tbl = tbl[nla_type(nla)].next;
+			nlattr_set(nla, val, tbl);
+		} else {
 			memset(nla_data(nla), val, nla_len(nla));
+		}
 	}
 }
 
@@ -1922,8 +1959,7 @@ static int validate_set(const struct nlattr *a,
 		key_len /= 2;
 
 	if (key_type > OVS_KEY_ATTR_MAX ||
-	    (ovs_key_lens[key_type].len != key_len &&
-	     ovs_key_lens[key_type].len != OVS_ATTR_NESTED))
+	    !check_attr_len(key_len, ovs_key_lens[key_type].len))
 		return -EINVAL;
 
 	if (masked && !validate_masked(nla_data(ovs_key), key_len))
-- 
2.1.4
