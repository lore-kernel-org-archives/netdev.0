From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv4 net-next 09/10] openvswitch: Allow matching on conntrack label
Date: Tue, 18 Aug 2015 16:39:47 -0700
Message-ID: <1439941188-19293-10-git-send-email-joestringer@nicira.com>
References: <1439941188-19293-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org, pablo@netfilter.org,
	fwestpha@redhat.com, hannes@redhat.com, tgraf@suug.ch,
	jpettit@nicira.com, jesse@nicira.com
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439941188-19293-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow matching and setting the conntrack label field. As with ct_mark,
this is populated by executing the CT action, and is a writable field.
Specifying a label and optional mask allows the label to be modified,
which takes effect on the entry found by the lookup of the CT action.

E.g.: actions:ct(zone=1,label=1)

This will perform conntrack lookup in zone 1, then modify the label for
that entry. The conntrack entry itself must be committed using the
"commit" flag in the conntrack action flags for this change to persist.

Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
v2: Split out setting the connlabel size for the current namespace.
v3: No change.
v4: Only allow setting label via ct action.
    Update documentation.
---
 include/uapi/linux/openvswitch.h |  10 ++++
 net/openvswitch/actions.c        |   1 +
 net/openvswitch/conntrack.c      | 100 ++++++++++++++++++++++++++++++++++++++-
 net/openvswitch/conntrack.h      |   1 +
 net/openvswitch/flow.h           |   1 +
 net/openvswitch/flow_netlink.c   |  18 ++++++-
 6 files changed, 129 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 7a185b5..9d52058 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -326,6 +326,7 @@ enum ovs_key_attr {
 	OVS_KEY_ATTR_CT_STATE,	/* u8 bitmask of OVS_CS_F_* */
 	OVS_KEY_ATTR_CT_ZONE,	/* u16 connection tracking zone. */
 	OVS_KEY_ATTR_CT_MARK,	/* u32 connection tracking mark */
+	OVS_KEY_ATTR_CT_LABEL,	/* 16-octet connection tracking label */
 
 #ifdef __KERNEL__
 	OVS_KEY_ATTR_TUNNEL_INFO,  /* struct ip_tunnel_info */
@@ -438,6 +439,11 @@ struct ovs_key_nd {
 	__u8	nd_tll[ETH_ALEN];
 };
 
+#define OVS_CT_LABEL_LEN	16
+struct ovs_key_ct_label {
+	__u8	ct_label[OVS_CT_LABEL_LEN];
+};
+
 /* OVS_KEY_ATTR_CT_STATE flags */
 #define OVS_CS_F_NEW               0x01 /* Beginning of a new connection. */
 #define OVS_CS_F_ESTABLISHED       0x02 /* Part of an existing connection. */
@@ -617,12 +623,16 @@ struct ovs_action_hash {
  * @OVS_CT_ATTR_MARK: u32 value followed by u32 mask. For each bit set in the
  * mask, the corresponding bit in the value is copied to the connection
  * tracking mark field in the connection.
+ * @OVS_CT_ATTR_LABEL: %OVS_CT_LABEL_LEN value followed by %OVS_CT_LABEL_LEN
+ * mask. For each bit set in the mask, the corresponding bit in the value is
+ * copied to the connection tracking label field in the connection.
  */
 enum ovs_ct_attr {
 	OVS_CT_ATTR_UNSPEC,
 	OVS_CT_ATTR_FLAGS,      /* u8 bitmask of OVS_CT_F_*. */
 	OVS_CT_ATTR_ZONE,       /* u16 zone id. */
 	OVS_CT_ATTR_MARK,       /* mark to associate with this connection. */
+	OVS_CT_ATTR_LABEL,      /* label to associate with this connection. */
 	__OVS_CT_ATTR_MAX
 };
 
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 083dcf9..862a3d2 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -969,6 +969,7 @@ static int execute_masked_set_action(struct sk_buff *skb,
 	case OVS_KEY_ATTR_CT_STATE:
 	case OVS_KEY_ATTR_CT_ZONE:
 	case OVS_KEY_ATTR_CT_MARK:
+	case OVS_KEY_ATTR_CT_LABEL:
 		err = -EINVAL;
 		break;
 	}
diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index bdd1a28..caa9a46 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -15,6 +15,7 @@
 #include <linux/openvswitch.h>
 #include <net/ip.h>
 #include <net/netfilter/nf_conntrack_core.h>
+#include <net/netfilter/nf_conntrack_labels.h>
 #include <net/netfilter/nf_conntrack_zones.h>
 #include <net/netfilter/ipv6/nf_defrag_ipv6.h>
 
@@ -34,6 +35,12 @@ struct md_mark {
 	u32 mask;
 };
 
+/* Metadata label for masked write to conntrack label. */
+struct md_label {
+	struct ovs_key_ct_label value;
+	struct ovs_key_ct_label mask;
+};
+
 /* Conntrack action context for execution. */
 struct ovs_conntrack_info {
 	struct nf_conn *ct;
@@ -41,6 +48,7 @@ struct ovs_conntrack_info {
 	u16 zone;
 	u16 family;
 	struct md_mark mark;
+	struct md_label label;
 };
 
 static u16 key_to_nfproto(const struct sw_flow_key *key)
@@ -90,12 +98,31 @@ static u8 ovs_ct_get_state(enum ip_conntrack_info ctinfo)
 	return ct_state;
 }
 
+static void ovs_ct_get_label(const struct nf_conn *ct,
+			     struct ovs_key_ct_label *label)
+{
+	struct nf_conn_labels *cl = ct ? nf_ct_labels_find(ct) : NULL;
+
+	if (cl) {
+		size_t len = cl->words * sizeof(long);
+
+		if (len > OVS_CT_LABEL_LEN)
+			len = OVS_CT_LABEL_LEN;
+		else if (len < OVS_CT_LABEL_LEN)
+			memset(label, 0, OVS_CT_LABEL_LEN);
+		memcpy(label, cl->bits, len);
+	} else {
+		memset(label, 0, OVS_CT_LABEL_LEN);
+	}
+}
+
 static void __ovs_ct_update_key(struct sw_flow_key *key, u8 state, u16 zone,
 				const struct nf_conn *ct)
 {
 	key->ct.state = state;
 	key->ct.zone = zone;
 	key->ct.mark = ct ? ct->mark : 0;
+	ovs_ct_get_label(ct, &key->ct.label);
 }
 
 /* Update 'key' based on skb->nfct. If 'post_ct' is true, then OVS has
@@ -154,6 +181,41 @@ static int ovs_ct_set_mark(struct sk_buff *skb, struct sw_flow_key *key,
 #endif
 }
 
+static int ovs_ct_set_label(struct sk_buff *skb, struct sw_flow_key *key,
+			    const struct ovs_key_ct_label *label,
+			    const struct ovs_key_ct_label *mask)
+{
+#ifdef CONFIG_NF_CONNTRACK_LABELS
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn_labels *cl;
+	struct nf_conn *ct;
+	int err;
+
+	/* The connection could be invalid, in which case set_label is no-op.*/
+	ct = nf_ct_get(skb, &ctinfo);
+	if (!ct)
+		return 0;
+
+	cl = nf_ct_labels_find(ct);
+	if (!cl) {
+		nf_ct_labels_ext_add(ct);
+		cl = nf_ct_labels_find(ct);
+	}
+	if (!cl || cl->words * sizeof(long) < OVS_CT_LABEL_LEN)
+		return -ENOSPC;
+
+	err = nf_connlabels_replace(ct, (u32 *)label, (u32 *)mask,
+				    OVS_CT_LABEL_LEN / sizeof(u32));
+	if (err)
+		return err;
+
+	ovs_ct_get_label(ct, &key->ct.label);
+	return 0;
+#else
+	return -ENOTSUPP;
+#endif
+}
+
 static bool __ovs_ct_state_valid(u8 state)
 {
 	return (state && !(state & OVS_CS_F_INVALID));
@@ -323,6 +385,17 @@ static int ovs_ct_commit(struct net *net, struct sw_flow_key *key,
 	return 0;
 }
 
+static bool label_nonzero(const struct ovs_key_ct_label *label)
+{
+	size_t i;
+
+	for (i = 0; i < sizeof(*label); i++)
+		if (label->ct_label[i])
+			return true;
+
+	return false;
+}
+
 int ovs_ct_execute(struct net *net, struct sk_buff *skb,
 		   struct sw_flow_key *key,
 		   const struct ovs_conntrack_info *info)
@@ -347,9 +420,15 @@ int ovs_ct_execute(struct net *net, struct sk_buff *skb,
 	if (err)
 		goto err;
 
-	if (info->mark.mask)
+	if (info->mark.mask) {
 		err = ovs_ct_set_mark(skb, key, info->mark.value,
 				      info->mark.mask);
+		if (err)
+			goto err;
+	}
+	if (label_nonzero(&info->label.mask))
+		err = ovs_ct_set_label(skb, key, &info->label.value,
+				       &info->label.mask);
 err:
 	skb_push(skb, nh_ofs);
 	return err;
@@ -362,6 +441,8 @@ static const struct ovs_ct_len_tbl ovs_ct_attr_lens[OVS_CT_ATTR_MAX + 1] = {
 				    .maxlen = sizeof(u16) },
 	[OVS_CT_ATTR_MARK]	= { .minlen = sizeof(struct md_mark),
 				    .maxlen = sizeof(struct md_mark) },
+	[OVS_CT_ATTR_LABEL]	= { .minlen = sizeof(struct md_label),
+				    .maxlen = sizeof(struct md_label) },
 };
 
 static int parse_ct(const struct nlattr *attr, struct ovs_conntrack_info *info,
@@ -405,6 +486,14 @@ static int parse_ct(const struct nlattr *attr, struct ovs_conntrack_info *info,
 			break;
 		}
 #endif
+#ifdef CONFIG_NF_CONNTRACK_LABELS
+		case OVS_CT_ATTR_LABEL: {
+			struct md_label *label = nla_data(a);
+
+			info->label = *label;
+			break;
+		}
+#endif
 		default:
 			OVS_NLERR(log, "Unknown conntrack attr (%d)",
 				  type);
@@ -432,6 +521,10 @@ bool ovs_ct_verify(enum ovs_key_attr attr)
 	if (attr & OVS_KEY_ATTR_CT_MARK)
 		return true;
 #endif
+#ifdef CONFIG_NF_CONNTRACK_LABELS
+	if (attr & OVS_KEY_ATTR_CT_LABEL)
+		return true;
+#endif
 
 	return false;
 }
@@ -508,8 +601,12 @@ void ovs_ct_free_action(const struct nlattr *a)
 
 void ovs_ct_init(struct net *net, struct ovs_ct_perdp_data *data)
 {
+	unsigned int n_bits = sizeof(struct ovs_key_ct_label) * BITS_PER_BYTE;
+
 	data->xt_v4 = !nf_ct_l3proto_try_module_get(PF_INET);
 	data->xt_v6 = !nf_ct_l3proto_try_module_get(PF_INET6);
+	if (nf_connlabels_get(net, n_bits);
+		OVS_NLERR(true, "Failed to set connlabel length");
 }
 
 void ovs_ct_exit(struct net *net, struct ovs_ct_perdp_data *data)
@@ -518,4 +615,5 @@ void ovs_ct_exit(struct net *net, struct ovs_ct_perdp_data *data)
 		nf_ct_l3proto_module_put(PF_INET);
 	if (data->xt_v6)
 		nf_ct_l3proto_module_put(PF_INET6);
+	nf_connlabels_put(net);
 }
diff --git a/net/openvswitch/conntrack.h b/net/openvswitch/conntrack.h
index 4cc35b7..21e1da1 100644
--- a/net/openvswitch/conntrack.h
+++ b/net/openvswitch/conntrack.h
@@ -85,6 +85,7 @@ void ovs_ct_fill_key(const struct sk_buff *skb, struct sw_flow_key *key)
 	key->ct.state = 0;
 	key->ct.zone = 0;
 	key->ct.mark = 0;
+	memset(&key->ct.label, 0, sizeof(key->ct.label));
 }
 
 static inline void ovs_ct_free_action(const struct nlattr *a) { }
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index e05e697..c57994b 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -116,6 +116,7 @@ struct sw_flow_key {
 		u16 zone;
 		u32 mark;
 		u8 state;
+		struct ovs_key_ct_label label;
 	} ct;
 
 } __aligned(BITS_PER_LONG/8); /* Ensure that we can do comparisons as longs. */
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index e54de9b..0a8e626 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -281,7 +281,7 @@ size_t ovs_key_attr_size(void)
 	/* Whenever adding new OVS_KEY_ FIELDS, we should consider
 	 * updating this function.
 	 */
-	BUILD_BUG_ON(OVS_KEY_ATTR_TUNNEL_INFO != 25);
+	BUILD_BUG_ON(OVS_KEY_ATTR_TUNNEL_INFO != 26);
 
 	return    nla_total_size(4)   /* OVS_KEY_ATTR_PRIORITY */
 		+ nla_total_size(0)   /* OVS_KEY_ATTR_TUNNEL */
@@ -293,6 +293,7 @@ size_t ovs_key_attr_size(void)
 		+ nla_total_size(1)   /* OVS_KEY_ATTR_CT_STATE */
 		+ nla_total_size(2)   /* OVS_KEY_ATTR_CT_ZONE */
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_CT_MARK */
+		+ nla_total_size(16)  /* OVS_KEY_ATTR_CT_LABEL */
 		+ nla_total_size(12)  /* OVS_KEY_ATTR_ETHERNET */
 		+ nla_total_size(2)   /* OVS_KEY_ATTR_ETHERTYPE */
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_VLAN */
@@ -345,6 +346,7 @@ static const struct ovs_len_tbl ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
 	[OVS_KEY_ATTR_CT_STATE]	 = { .len = sizeof(u8) },
 	[OVS_KEY_ATTR_CT_ZONE]	 = { .len = sizeof(u16) },
 	[OVS_KEY_ATTR_CT_MARK]	 = { .len = sizeof(u32) },
+	[OVS_KEY_ATTR_CT_LABEL]	 = { .len = sizeof(struct ovs_key_ct_label) },
 };
 
 static bool is_all_zero(const u8 *fp, size_t size)
@@ -796,6 +798,15 @@ static int metadata_from_nlattrs(struct sw_flow_match *match,  u64 *attrs,
 		SW_FLOW_KEY_PUT(match, ct.mark, mark, is_mask);
 		*attrs &= ~(1ULL << OVS_KEY_ATTR_CT_MARK);
 	}
+	if (*attrs & (1 << OVS_KEY_ATTR_CT_LABEL) &&
+	    ovs_ct_verify(OVS_KEY_ATTR_CT_LABEL)) {
+		const struct ovs_key_ct_label *cl;
+
+		cl = nla_data(a[OVS_KEY_ATTR_CT_LABEL]);
+		SW_FLOW_KEY_MEMCPY(match, ct.label, cl->ct_label,
+				   sizeof(*cl), is_mask);
+		*attrs &= ~(1ULL << OVS_KEY_ATTR_CT_LABEL);
+	}
 	return 0;
 }
 
@@ -1352,6 +1363,10 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
 	if (nla_put_u32(skb, OVS_KEY_ATTR_CT_MARK, output->ct.mark))
 		goto nla_put_failure;
 
+	if (nla_put(skb, OVS_KEY_ATTR_CT_LABEL,
+		    sizeof(output->ct.label), &output->ct.label))
+		goto nla_put_failure;
+
 	nla = nla_reserve(skb, OVS_KEY_ATTR_ETHERNET, sizeof(*eth_key));
 	if (!nla)
 		goto nla_put_failure;
@@ -1935,6 +1950,7 @@ static int validate_set(const struct nlattr *a,
 	case OVS_KEY_ATTR_PRIORITY:
 	case OVS_KEY_ATTR_SKB_MARK:
 	case OVS_KEY_ATTR_CT_MARK:
+	case OVS_KEY_ATTR_CT_LABEL:
 	case OVS_KEY_ATTR_ETHERNET:
 		break;
 
-- 
2.1.4
