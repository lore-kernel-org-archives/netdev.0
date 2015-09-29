From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCH net 1/7] openvswitch: Make LABELS name more consistent
Date: Tue, 29 Sep 2015 15:39:34 -0700
Message-ID: <1443566380-22640-2-git-send-email-joestringer@nicira.com>
References: <1443566380-22640-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35525 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751167AbbI2WkB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 18:40:01 -0400
Received: by pacfv12 with SMTP id fv12so18820300pac.2
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 15:40:01 -0700 (PDT)
In-Reply-To: <1443566380-22640-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Conntrack LABELS (plural) are exposed by conntrack; rename the OVS name
for these to be consistent with conntrack.

Fixes: c2ac667 "openvswitch: Allow matching on conntrack label"
Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
 include/uapi/linux/openvswitch.h |  4 ++--
 net/openvswitch/actions.c        |  2 +-
 net/openvswitch/conntrack.c      | 10 +++++-----
 net/openvswitch/flow_netlink.c   | 14 +++++++-------
 4 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 32e07d8..9afcd60 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -326,7 +326,7 @@ enum ovs_key_attr {
 	OVS_KEY_ATTR_CT_STATE,	/* u8 bitmask of OVS_CS_F_* */
 	OVS_KEY_ATTR_CT_ZONE,	/* u16 connection tracking zone. */
 	OVS_KEY_ATTR_CT_MARK,	/* u32 connection tracking mark */
-	OVS_KEY_ATTR_CT_LABEL,	/* 16-octet connection tracking label */
+	OVS_KEY_ATTR_CT_LABELS,	/* 16-octet connection tracking label */
 
 #ifdef __KERNEL__
 	OVS_KEY_ATTR_TUNNEL_INFO,  /* struct ip_tunnel_info */
@@ -633,7 +633,7 @@ enum ovs_ct_attr {
 	OVS_CT_ATTR_FLAGS,      /* u8 bitmask of OVS_CT_F_*. */
 	OVS_CT_ATTR_ZONE,       /* u16 zone id. */
 	OVS_CT_ATTR_MARK,       /* mark to associate with this connection. */
-	OVS_CT_ATTR_LABEL,      /* label to associate with this connection. */
+	OVS_CT_ATTR_LABELS,     /* labels to associate with this connection. */
 	OVS_CT_ATTR_HELPER,     /* netlink helper to assist detection of
 				   related connections. */
 	__OVS_CT_ATTR_MAX
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 315f533..e23a61c 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -968,7 +968,7 @@ static int execute_masked_set_action(struct sk_buff *skb,
 	case OVS_KEY_ATTR_CT_STATE:
 	case OVS_KEY_ATTR_CT_ZONE:
 	case OVS_KEY_ATTR_CT_MARK:
-	case OVS_KEY_ATTR_CT_LABEL:
+	case OVS_KEY_ATTR_CT_LABELS:
 		err = -EINVAL;
 		break;
 	}
diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 002a755..8c5d482c 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -179,7 +179,7 @@ int ovs_ct_put_key(const struct sw_flow_key *key, struct sk_buff *skb)
 		return -EMSGSIZE;
 
 	if (IS_ENABLED(CONFIG_NF_CONNTRACK_LABELS) &&
-	    nla_put(skb, OVS_KEY_ATTR_CT_LABEL, sizeof(key->ct.label),
+	    nla_put(skb, OVS_KEY_ATTR_CT_LABELS, sizeof(key->ct.label),
 		    &key->ct.label))
 		return -EMSGSIZE;
 
@@ -545,7 +545,7 @@ static const struct ovs_ct_len_tbl ovs_ct_attr_lens[OVS_CT_ATTR_MAX + 1] = {
 				    .maxlen = sizeof(u16) },
 	[OVS_CT_ATTR_MARK]	= { .minlen = sizeof(struct md_mark),
 				    .maxlen = sizeof(struct md_mark) },
-	[OVS_CT_ATTR_LABEL]	= { .minlen = sizeof(struct md_label),
+	[OVS_CT_ATTR_LABELS]	= { .minlen = sizeof(struct md_label),
 				    .maxlen = sizeof(struct md_label) },
 	[OVS_CT_ATTR_HELPER]	= { .minlen = 1,
 				    .maxlen = NF_CT_HELPER_NAME_LEN }
@@ -593,7 +593,7 @@ static int parse_ct(const struct nlattr *attr, struct ovs_conntrack_info *info,
 		}
 #endif
 #ifdef CONFIG_NF_CONNTRACK_LABELS
-		case OVS_CT_ATTR_LABEL: {
+		case OVS_CT_ATTR_LABELS: {
 			struct md_label *label = nla_data(a);
 
 			info->label = *label;
@@ -633,7 +633,7 @@ bool ovs_ct_verify(struct net *net, enum ovs_key_attr attr)
 	    attr == OVS_KEY_ATTR_CT_MARK)
 		return true;
 	if (IS_ENABLED(CONFIG_NF_CONNTRACK_LABELS) &&
-	    attr == OVS_KEY_ATTR_CT_LABEL) {
+	    attr == OVS_KEY_ATTR_CT_LABELS) {
 		struct ovs_net *ovs_net = net_generic(net, ovs_net_id);
 
 		return ovs_net->xt_label;
@@ -711,7 +711,7 @@ int ovs_ct_action_to_attr(const struct ovs_conntrack_info *ct_info,
 		    &ct_info->mark))
 		return -EMSGSIZE;
 	if (IS_ENABLED(CONFIG_NF_CONNTRACK_LABELS) &&
-	    nla_put(skb, OVS_CT_ATTR_LABEL, sizeof(ct_info->label),
+	    nla_put(skb, OVS_CT_ATTR_LABELS, sizeof(ct_info->label),
 		    &ct_info->label))
 		return -EMSGSIZE;
 	if (ct_info->helper) {
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 5c030a4..ea82cd5 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -294,7 +294,7 @@ size_t ovs_key_attr_size(void)
 		+ nla_total_size(1)   /* OVS_KEY_ATTR_CT_STATE */
 		+ nla_total_size(2)   /* OVS_KEY_ATTR_CT_ZONE */
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_CT_MARK */
-		+ nla_total_size(16)  /* OVS_KEY_ATTR_CT_LABEL */
+		+ nla_total_size(16)  /* OVS_KEY_ATTR_CT_LABELS */
 		+ nla_total_size(12)  /* OVS_KEY_ATTR_ETHERNET */
 		+ nla_total_size(2)   /* OVS_KEY_ATTR_ETHERTYPE */
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_VLAN */
@@ -352,7 +352,7 @@ static const struct ovs_len_tbl ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
 	[OVS_KEY_ATTR_CT_STATE]	 = { .len = sizeof(u8) },
 	[OVS_KEY_ATTR_CT_ZONE]	 = { .len = sizeof(u16) },
 	[OVS_KEY_ATTR_CT_MARK]	 = { .len = sizeof(u32) },
-	[OVS_KEY_ATTR_CT_LABEL]	 = { .len = sizeof(struct ovs_key_ct_label) },
+	[OVS_KEY_ATTR_CT_LABELS] = { .len = sizeof(struct ovs_key_ct_label) },
 };
 
 static bool check_attr_len(unsigned int attr_len, unsigned int expected_len)
@@ -833,14 +833,14 @@ static int metadata_from_nlattrs(struct net *net, struct sw_flow_match *match,
 		SW_FLOW_KEY_PUT(match, ct.mark, mark, is_mask);
 		*attrs &= ~(1ULL << OVS_KEY_ATTR_CT_MARK);
 	}
-	if (*attrs & (1 << OVS_KEY_ATTR_CT_LABEL) &&
-	    ovs_ct_verify(net, OVS_KEY_ATTR_CT_LABEL)) {
+	if (*attrs & (1 << OVS_KEY_ATTR_CT_LABELS) &&
+	    ovs_ct_verify(net, OVS_KEY_ATTR_CT_LABELS)) {
 		const struct ovs_key_ct_label *cl;
 
-		cl = nla_data(a[OVS_KEY_ATTR_CT_LABEL]);
+		cl = nla_data(a[OVS_KEY_ATTR_CT_LABELS]);
 		SW_FLOW_KEY_MEMCPY(match, ct.label, cl->ct_label,
 				   sizeof(*cl), is_mask);
-		*attrs &= ~(1ULL << OVS_KEY_ATTR_CT_LABEL);
+		*attrs &= ~(1ULL << OVS_KEY_ATTR_CT_LABELS);
 	}
 	return 0;
 }
@@ -1973,7 +1973,7 @@ static int validate_set(const struct nlattr *a,
 	case OVS_KEY_ATTR_PRIORITY:
 	case OVS_KEY_ATTR_SKB_MARK:
 	case OVS_KEY_ATTR_CT_MARK:
-	case OVS_KEY_ATTR_CT_LABEL:
+	case OVS_KEY_ATTR_CT_LABELS:
 	case OVS_KEY_ATTR_ETHERNET:
 		break;
 
-- 
2.1.4
