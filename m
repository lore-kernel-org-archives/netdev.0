From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv3 net-next 09/10] openvswitch: Allow matching on conntrack label
Date: Tue, 11 Aug 2015 15:59:20 -0700
Message-ID: <1439333961-24474-10-git-send-email-joestringer@nicira.com>
References: <1439333961-24474-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org, pablo@netfilter.org, kaber@trash.net,
	jpettit@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	jesse@nicira.com, fwestpha@redhat.com, hannes@redhat.com,
	tgraf@noironetworks.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439333961-24474-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow matching and setting the conntrack label field. As with ct_mark,
this is populated by executing the ct() action, and is a writable field.
The set_field() action may be used to modify the label, which will take
effect on the most recent conntrack entry.

E.g.: actions:ct(zone=1),set_field(1->ct_label)

This will perform conntrack lookup in zone 1, then modify the label for
that entry. The conntrack entry itself must be committed using the
"commit" flag in the conntrack action flags for this change to persist.

Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
v2: Split out setting the connlabel size for the current namespace.
---
 include/uapi/linux/openvswitch.h |  6 ++++
 net/openvswitch/actions.c        |  4 +++
 net/openvswitch/conntrack.c      | 68 ++++++++++++++++++++++++++++++++++++++++
 net/openvswitch/conntrack.h      | 15 +++++++++
 net/openvswitch/flow.c           |  1 +
 net/openvswitch/flow.h           |  1 +
 net/openvswitch/flow_netlink.c   | 18 ++++++++++-
 7 files changed, 112 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 207788c..f360dc9 100644
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
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 5acd7e7..74524e4 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -963,6 +963,10 @@ static int execute_masked_set_action(struct sk_buff *skb,
 				      *get_mask(a, u32 *));
 		break;
 
+	case OVS_KEY_ATTR_CT_LABEL:
+		err = ovs_ct_set_label(skb, flow_key, nla_data(a),
+				get_mask(a, struct ovs_key_ct_label *));
+		break;
 	}
 
 	return err;
diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 81b80da..6a64a32 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -15,6 +15,7 @@
 #include <linux/openvswitch.h>
 #include <net/ip.h>
 #include <net/netfilter/nf_conntrack_core.h>
+#include <net/netfilter/nf_conntrack_labels.h>
 #include <net/netfilter/nf_conntrack_zones.h>
 #include <net/netfilter/ipv6/nf_defrag_ipv6.h>
 
@@ -110,6 +111,30 @@ u32 ovs_ct_get_mark(const struct sk_buff *skb)
 	return ct ? ct->mark : 0;
 }
 
+void ovs_ct_get_label(const struct sk_buff *skb,
+		      struct ovs_key_ct_label *label)
+{
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn_labels *cl = NULL;
+	struct nf_conn *ct;
+
+	ct = nf_ct_get(skb, &ctinfo);
+	if (ct)
+		cl = nf_ct_labels_find(ct);
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
 static bool __ovs_ct_state_valid(u8 state)
 {
 	return (state && !(state & OVS_CS_F_INVALID));
@@ -202,6 +227,7 @@ static void __ovs_ct_update_key(struct sk_buff *skb, struct sw_flow_key *key,
 	key->ct.state = state;
 	key->ct.zone = zone;
 	key->ct.mark = ovs_ct_get_mark(skb);
+	ovs_ct_get_label(skb, &key->ct.label);
 }
 
 static void ovs_ct_update_key(struct sk_buff *skb, struct sw_flow_key *key,
@@ -359,6 +385,41 @@ int ovs_ct_set_mark(struct sk_buff *skb, struct sw_flow_key *key,
 #endif
 }
 
+int ovs_ct_set_label(struct sk_buff *skb, struct sw_flow_key *key,
+		     const struct ovs_key_ct_label *label,
+		     const struct ovs_key_ct_label *mask)
+{
+#ifdef CONFIG_NF_CONNTRACK_LABELS
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn_labels *cl;
+	struct nf_conn *ct;
+	int err;
+
+	/* This must happen directly after lookup/commit. */
+	ct = nf_ct_get(skb, &ctinfo);
+	if (!ct)
+		return -EINVAL;
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
+	ovs_ct_get_label(skb, &key->ct.label);
+	return 0;
+#else
+	return -ENOTSUPP;
+#endif
+}
+
 static const struct ovs_ct_len_tbl ovs_ct_attr_lens[OVS_CT_ATTR_MAX + 1] = {
 	[OVS_CT_ATTR_FLAGS]	= { .minlen = sizeof(u32),
 				    .maxlen = sizeof(u32) },
@@ -426,6 +487,10 @@ bool ovs_ct_verify(enum ovs_key_attr attr)
 	if (attr & OVS_KEY_ATTR_CT_MARK)
 		return true;
 #endif
+#ifdef CONFIG_NF_CONNTRACK_LABELS
+	if (attr & OVS_KEY_ATTR_CT_LABEL)
+		return true;
+#endif
 
 	return false;
 }
@@ -504,6 +569,8 @@ void ovs_ct_init(struct net *net, struct ovs_ct_perdp_data *data)
 {
 	data->xt_v4 = !nf_ct_l3proto_try_module_get(PF_INET);
 	data->xt_v6 = !nf_ct_l3proto_try_module_get(PF_INET6);
+	if (nf_connlabels_get(net, sizeof(struct ovs_key_ct_label) * BITS_PER_BYTE))
+		OVS_NLERR(true, "Failed to set connlabel length");
 }
 
 void ovs_ct_exit(struct net *net, struct ovs_ct_perdp_data *data)
@@ -512,4 +579,5 @@ void ovs_ct_exit(struct net *net, struct ovs_ct_perdp_data *data)
 		nf_ct_l3proto_module_put(PF_INET);
 	if (data->xt_v6)
 		nf_ct_l3proto_module_put(PF_INET6);
+	nf_connlabels_put(net);
 }
diff --git a/net/openvswitch/conntrack.h b/net/openvswitch/conntrack.h
index b0f06b4..333aaa5 100644
--- a/net/openvswitch/conntrack.h
+++ b/net/openvswitch/conntrack.h
@@ -40,6 +40,11 @@ int ovs_ct_execute(struct net *, struct sk_buff *, struct sw_flow_key *,
 int ovs_ct_set_mark(struct sk_buff *, struct sw_flow_key *, u32 ct_mark,
 		    u32 mask);
 u32 ovs_ct_get_mark(const struct sk_buff *skb);
+void ovs_ct_get_label(const struct sk_buff *skb,
+		      struct ovs_key_ct_label *label);
+int ovs_ct_set_label(struct sk_buff *, struct sw_flow_key *,
+		     const struct ovs_key_ct_label *label,
+		     const struct ovs_key_ct_label *mask);
 u8 ovs_ct_get_state(const struct sk_buff *skb);
 u16 ovs_ct_get_zone(const struct sk_buff *skb);
 bool ovs_ct_state_valid(const struct sw_flow_key *key);
@@ -106,6 +111,16 @@ static inline int ovs_ct_set_mark(struct sk_buff *skb, struct sw_flow_key *key,
 	return -ENOTSUPP;
 }
 
+static inline void ovs_ct_get_label(const struct sk_buff *skb,
+				    struct ovs_key_ct_label *label) { }
+static inline int ovs_ct_set_label(struct sk_buff *skb,
+				   struct sw_flow_key *key,
+				   const struct ovs_key_ct_label *label,
+				   const struct ovs_key_ct_label *mask)
+{
+	return -ENOTSUPP;
+}
+
 static inline void ovs_ct_free_action(const struct nlattr *a) { }
 #endif
 #endif /* ovs_conntrack.h */
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 05ce284..301eb41 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -711,6 +711,7 @@ int ovs_flow_key_extract(const struct ip_tunnel_info *tun_info,
 	key->ct.state = ovs_ct_get_state(skb);
 	key->ct.zone = ovs_ct_get_zone(skb);
 	key->ct.mark = ovs_ct_get_mark(skb);
+	ovs_ct_get_label(skb, &key->ct.label);
 	key->ovs_flow_hash = 0;
 	key->recirc_id = 0;
 
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
