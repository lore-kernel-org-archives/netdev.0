From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv2 1/7] openvswitch: Rename LABEL->LABELS
Date: Thu,  1 Oct 2015 13:53:24 -0700
Message-ID: <1443732810-38746-2-git-send-email-joestringer@nicira.com>
References: <1443732810-38746-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org, jesse@nicira.com
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34676 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757042AbbJAUxi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 16:53:38 -0400
Received: by padhy16 with SMTP id hy16so84921339pad.1
        for <netdev@vger.kernel.org>; Thu, 01 Oct 2015 13:53:37 -0700 (PDT)
In-Reply-To: <1443732810-38746-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Conntrack LABELS (plural) are exposed by conntrack; rename the OVS name
for these to be consistent with conntrack.

Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
v2: Change ct_label struct names as well as constants.
---
 include/uapi/linux/openvswitch.h | 12 +++----
 net/openvswitch/actions.c        |  2 +-
 net/openvswitch/conntrack.c      | 74 ++++++++++++++++++++--------------------
 net/openvswitch/flow.h           |  2 +-
 net/openvswitch/flow_netlink.c   | 18 +++++-----
 5 files changed, 54 insertions(+), 54 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 32e07d8..c736344 100644
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
@@ -439,9 +439,9 @@ struct ovs_key_nd {
 	__u8	nd_tll[ETH_ALEN];
 };
 
-#define OVS_CT_LABEL_LEN	16
-struct ovs_key_ct_label {
-	__u8	ct_label[OVS_CT_LABEL_LEN];
+#define OVS_CT_LABELS_LEN	16
+struct ovs_key_ct_labels {
+	__u8	ct_labels[OVS_CT_LABELS_LEN];
 };
 
 /* OVS_KEY_ATTR_CT_STATE flags */
@@ -623,7 +623,7 @@ struct ovs_action_hash {
  * @OVS_CT_ATTR_MARK: u32 value followed by u32 mask. For each bit set in the
  * mask, the corresponding bit in the value is copied to the connection
  * tracking mark field in the connection.
- * @OVS_CT_ATTR_LABEL: %OVS_CT_LABEL_LEN value followed by %OVS_CT_LABEL_LEN
+ * @OVS_CT_ATTR_LABEL: %OVS_CT_LABELS_LEN value followed by %OVS_CT_LABELS_LEN
  * mask. For each bit set in the mask, the corresponding bit in the value is
  * copied to the connection tracking label field in the connection.
  * @OVS_CT_ATTR_HELPER: variable length string defining conntrack ALG.
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
index 002a755..7d80acf 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -37,9 +37,9 @@ struct md_mark {
 };
 
 /* Metadata label for masked write to conntrack label. */
-struct md_label {
-	struct ovs_key_ct_label value;
-	struct ovs_key_ct_label mask;
+struct md_labels {
+	struct ovs_key_ct_labels value;
+	struct ovs_key_ct_labels mask;
 };
 
 /* Conntrack action context for execution. */
@@ -50,7 +50,7 @@ struct ovs_conntrack_info {
 	u32 flags;
 	u16 family;
 	struct md_mark mark;
-	struct md_label label;
+	struct md_labels labels;
 };
 
 static u16 key_to_nfproto(const struct sw_flow_key *key)
@@ -109,21 +109,21 @@ static u32 ovs_ct_get_mark(const struct nf_conn *ct)
 #endif
 }
 
-static void ovs_ct_get_label(const struct nf_conn *ct,
-			     struct ovs_key_ct_label *label)
+static void ovs_ct_get_labels(const struct nf_conn *ct,
+			      struct ovs_key_ct_labels *labels)
 {
 	struct nf_conn_labels *cl = ct ? nf_ct_labels_find(ct) : NULL;
 
 	if (cl) {
 		size_t len = cl->words * sizeof(long);
 
-		if (len > OVS_CT_LABEL_LEN)
-			len = OVS_CT_LABEL_LEN;
-		else if (len < OVS_CT_LABEL_LEN)
-			memset(label, 0, OVS_CT_LABEL_LEN);
-		memcpy(label, cl->bits, len);
+		if (len > OVS_CT_LABELS_LEN)
+			len = OVS_CT_LABELS_LEN;
+		else if (len < OVS_CT_LABELS_LEN)
+			memset(labels, 0, OVS_CT_LABELS_LEN);
+		memcpy(labels, cl->bits, len);
 	} else {
-		memset(label, 0, OVS_CT_LABEL_LEN);
+		memset(labels, 0, OVS_CT_LABELS_LEN);
 	}
 }
 
@@ -134,7 +134,7 @@ static void __ovs_ct_update_key(struct sw_flow_key *key, u8 state,
 	key->ct.state = state;
 	key->ct.zone = zone->id;
 	key->ct.mark = ovs_ct_get_mark(ct);
-	ovs_ct_get_label(ct, &key->ct.label);
+	ovs_ct_get_labels(ct, &key->ct.labels);
 }
 
 /* Update 'key' based on skb->nfct. If 'post_ct' is true, then OVS has
@@ -179,8 +179,8 @@ int ovs_ct_put_key(const struct sw_flow_key *key, struct sk_buff *skb)
 		return -EMSGSIZE;
 
 	if (IS_ENABLED(CONFIG_NF_CONNTRACK_LABELS) &&
-	    nla_put(skb, OVS_KEY_ATTR_CT_LABEL, sizeof(key->ct.label),
-		    &key->ct.label))
+	    nla_put(skb, OVS_KEY_ATTR_CT_LABELS, sizeof(key->ct.labels),
+		    &key->ct.labels))
 		return -EMSGSIZE;
 
 	return 0;
@@ -213,9 +213,9 @@ static int ovs_ct_set_mark(struct sk_buff *skb, struct sw_flow_key *key,
 #endif
 }
 
-static int ovs_ct_set_label(struct sk_buff *skb, struct sw_flow_key *key,
-			    const struct ovs_key_ct_label *label,
-			    const struct ovs_key_ct_label *mask)
+static int ovs_ct_set_labels(struct sk_buff *skb, struct sw_flow_key *key,
+			     const struct ovs_key_ct_labels *labels,
+			     const struct ovs_key_ct_labels *mask)
 {
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn_labels *cl;
@@ -235,15 +235,15 @@ static int ovs_ct_set_label(struct sk_buff *skb, struct sw_flow_key *key,
 		nf_ct_labels_ext_add(ct);
 		cl = nf_ct_labels_find(ct);
 	}
-	if (!cl || cl->words * sizeof(long) < OVS_CT_LABEL_LEN)
+	if (!cl || cl->words * sizeof(long) < OVS_CT_LABELS_LEN)
 		return -ENOSPC;
 
-	err = nf_connlabels_replace(ct, (u32 *)label, (u32 *)mask,
-				    OVS_CT_LABEL_LEN / sizeof(u32));
+	err = nf_connlabels_replace(ct, (u32 *)labels, (u32 *)mask,
+				    OVS_CT_LABELS_LEN / sizeof(u32));
 	if (err)
 		return err;
 
-	ovs_ct_get_label(ct, &key->ct.label);
+	ovs_ct_get_labels(ct, &key->ct.labels);
 	return 0;
 }
 
@@ -465,12 +465,12 @@ static int ovs_ct_commit(struct net *net, struct sw_flow_key *key,
 	return 0;
 }
 
-static bool label_nonzero(const struct ovs_key_ct_label *label)
+static bool labels_nonzero(const struct ovs_key_ct_labels *labels)
 {
 	size_t i;
 
-	for (i = 0; i < sizeof(*label); i++)
-		if (label->ct_label[i])
+	for (i = 0; i < sizeof(*labels); i++)
+		if (labels->ct_labels[i])
 			return true;
 
 	return false;
@@ -506,9 +506,9 @@ int ovs_ct_execute(struct net *net, struct sk_buff *skb,
 		if (err)
 			goto err;
 	}
-	if (label_nonzero(&info->label.mask))
-		err = ovs_ct_set_label(skb, key, &info->label.value,
-				       &info->label.mask);
+	if (labels_nonzero(&info->labels.mask))
+		err = ovs_ct_set_labels(skb, key, &info->labels.value,
+					&info->labels.mask);
 err:
 	skb_push(skb, nh_ofs);
 	return err;
@@ -545,8 +545,8 @@ static const struct ovs_ct_len_tbl ovs_ct_attr_lens[OVS_CT_ATTR_MAX + 1] = {
 				    .maxlen = sizeof(u16) },
 	[OVS_CT_ATTR_MARK]	= { .minlen = sizeof(struct md_mark),
 				    .maxlen = sizeof(struct md_mark) },
-	[OVS_CT_ATTR_LABEL]	= { .minlen = sizeof(struct md_label),
-				    .maxlen = sizeof(struct md_label) },
+	[OVS_CT_ATTR_LABELS]	= { .minlen = sizeof(struct md_labels),
+				    .maxlen = sizeof(struct md_labels) },
 	[OVS_CT_ATTR_HELPER]	= { .minlen = 1,
 				    .maxlen = NF_CT_HELPER_NAME_LEN }
 };
@@ -593,10 +593,10 @@ static int parse_ct(const struct nlattr *attr, struct ovs_conntrack_info *info,
 		}
 #endif
 #ifdef CONFIG_NF_CONNTRACK_LABELS
-		case OVS_CT_ATTR_LABEL: {
-			struct md_label *label = nla_data(a);
+		case OVS_CT_ATTR_LABELS: {
+			struct md_labels *labels = nla_data(a);
 
-			info->label = *label;
+			info->labels = *labels;
 			break;
 		}
 #endif
@@ -633,7 +633,7 @@ bool ovs_ct_verify(struct net *net, enum ovs_key_attr attr)
 	    attr == OVS_KEY_ATTR_CT_MARK)
 		return true;
 	if (IS_ENABLED(CONFIG_NF_CONNTRACK_LABELS) &&
-	    attr == OVS_KEY_ATTR_CT_LABEL) {
+	    attr == OVS_KEY_ATTR_CT_LABELS) {
 		struct ovs_net *ovs_net = net_generic(net, ovs_net_id);
 
 		return ovs_net->xt_label;
@@ -711,8 +711,8 @@ int ovs_ct_action_to_attr(const struct ovs_conntrack_info *ct_info,
 		    &ct_info->mark))
 		return -EMSGSIZE;
 	if (IS_ENABLED(CONFIG_NF_CONNTRACK_LABELS) &&
-	    nla_put(skb, OVS_CT_ATTR_LABEL, sizeof(ct_info->label),
-		    &ct_info->label))
+	    nla_put(skb, OVS_CT_ATTR_LABELS, sizeof(ct_info->labels),
+		    &ct_info->labels))
 		return -EMSGSIZE;
 	if (ct_info->helper) {
 		if (nla_put_string(skb, OVS_CT_ATTR_HELPER,
@@ -737,7 +737,7 @@ void ovs_ct_free_action(const struct nlattr *a)
 
 void ovs_ct_init(struct net *net)
 {
-	unsigned int n_bits = sizeof(struct ovs_key_ct_label) * BITS_PER_BYTE;
+	unsigned int n_bits = sizeof(struct ovs_key_ct_labels) * BITS_PER_BYTE;
 	struct ovs_net *ovs_net = net_generic(net, ovs_net_id);
 
 	if (nf_connlabels_get(net, n_bits)) {
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index fe527d2..8cfa15a 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -116,7 +116,7 @@ struct sw_flow_key {
 		u16 zone;
 		u32 mark;
 		u8 state;
-		struct ovs_key_ct_label label;
+		struct ovs_key_ct_labels labels;
 	} ct;
 
 } __aligned(BITS_PER_LONG/8); /* Ensure that we can do comparisons as longs. */
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 5c030a4..a60e3b7 100644
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
+	[OVS_KEY_ATTR_CT_LABELS] = { .len = sizeof(struct ovs_key_ct_labels) },
 };
 
 static bool check_attr_len(unsigned int attr_len, unsigned int expected_len)
@@ -833,14 +833,14 @@ static int metadata_from_nlattrs(struct net *net, struct sw_flow_match *match,
 		SW_FLOW_KEY_PUT(match, ct.mark, mark, is_mask);
 		*attrs &= ~(1ULL << OVS_KEY_ATTR_CT_MARK);
 	}
-	if (*attrs & (1 << OVS_KEY_ATTR_CT_LABEL) &&
-	    ovs_ct_verify(net, OVS_KEY_ATTR_CT_LABEL)) {
-		const struct ovs_key_ct_label *cl;
+	if (*attrs & (1 << OVS_KEY_ATTR_CT_LABELS) &&
+	    ovs_ct_verify(net, OVS_KEY_ATTR_CT_LABELS)) {
+		const struct ovs_key_ct_labels *cl;
 
-		cl = nla_data(a[OVS_KEY_ATTR_CT_LABEL]);
-		SW_FLOW_KEY_MEMCPY(match, ct.label, cl->ct_label,
+		cl = nla_data(a[OVS_KEY_ATTR_CT_LABELS]);
+		SW_FLOW_KEY_MEMCPY(match, ct.labels, cl->ct_labels,
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
