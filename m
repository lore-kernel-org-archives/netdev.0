From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCH net-next 8/9] openvswitch: Allow matching on conntrack label
Date: Thu, 30 Jul 2015 11:12:42 -0700
Message-ID: <1438279963-29563-9-git-send-email-joestringer@nicira.com>
References: <1438279963-29563-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org, pablo@netfilter.org, kaber@trash.net,
	jpettit@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	jesse@nicira.com, fwestpha@redhat.com, hannes@redhat.com,
	tgraf@noironetworks.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438279963-29563-1-git-send-email-joestringer@nicira.com>
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
 include/uapi/linux/openvswitch.h |   6 ++
 net/openvswitch/actions.c        |   4 ++
 net/openvswitch/conntrack.c      | 133 +++++++++++++++++++++++++++++++++++++++
 net/openvswitch/conntrack.h      |  32 ++++++++++
 net/openvswitch/datapath.c       |   6 ++
 net/openvswitch/datapath.h       |   2 +
 net/openvswitch/flow.c           |   1 +
 net/openvswitch/flow.h           |   1 +
 net/openvswitch/flow_netlink.c   |  18 +++++-
 9 files changed, 202 insertions(+), 1 deletion(-)

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
index 77b01f5..0d5a72a 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -950,6 +950,10 @@ static int execute_masked_set_action(struct sk_buff *skb,
 				      *get_mask(a, u32 *));
 		break;
 
+	case OVS_KEY_ATTR_CT_LABEL:
+		err = ovs_ct_set_label(skb, flow_key, nla_data(a),
+				get_mask(a, struct ovs_key_ct_label *));
+		break;
 	}
 
 	return err;
diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 6dc68dc..5acc59a 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -15,6 +15,7 @@
 #include <linux/openvswitch.h>
 #include <net/ip.h>
 #include <net/netfilter/nf_conntrack_core.h>
+#include <net/netfilter/nf_conntrack_labels.h>
 #include <net/netfilter/nf_conntrack_zones.h>
 #include <net/netfilter/ipv6/nf_defrag_ipv6.h>
 
@@ -123,6 +124,30 @@ u32 ovs_ct_get_mark(const struct sk_buff *skb)
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
@@ -217,6 +242,7 @@ static void __ovs_ct_update_key(struct sk_buff *skb, struct sw_flow_key *key,
 	key->ct.state = state;
 	key->ct.zone = zone;
 	key->ct.mark = ovs_ct_get_mark(skb);
+	ovs_ct_get_label(skb, &key->ct.label);
 }
 
 static void ovs_ct_update_key(struct sk_buff *skb, struct sw_flow_key *key,
@@ -376,6 +402,41 @@ int ovs_ct_set_mark(struct sk_buff *skb, struct sw_flow_key *key,
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
@@ -443,6 +504,10 @@ bool ovs_ct_verify(enum ovs_key_attr attr)
 	if (attr & OVS_KEY_ATTR_CT_MARK)
 		return true;
 #endif
+#ifdef CONFIG_NF_CONNTRACK_LABELS
+	if (attr & OVS_KEY_ATTR_CT_LABEL)
+		return true;
+#endif
 
 	return false;
 }
@@ -518,3 +583,71 @@ void ovs_ct_free_action(const struct nlattr *a)
 	if (ct_info->ct)
 		nf_ct_put(ct_info->ct);
 }
+
+/* Load connlabel and ensure it supports 128-bit labels */
+static struct xt_match *load_connlabel(struct net *net)
+{
+#ifdef CONFIG_NF_CONNTRACK_LABELS
+	struct xt_match *match;
+	struct xt_mtchk_param mtpar;
+	struct xt_connlabel_mtinfo info;
+	int err = -EINVAL;
+
+	match = xt_request_find_match(NFPROTO_UNSPEC, "connlabel", 0);
+	if (IS_ERR(match)) {
+		match = NULL;
+		goto exit;
+	}
+
+	info.bit = sizeof(struct ovs_key_ct_label) * 8 - 1;
+	info.options = 0;
+
+	mtpar.net	= net;
+	mtpar.table	= match->table;
+	mtpar.entryinfo = NULL;
+	mtpar.match	= match;
+	mtpar.matchinfo = &info;
+	mtpar.hook_mask = BIT(NF_INET_PRE_ROUTING);
+	mtpar.family	= NFPROTO_IPV4;
+
+	err = xt_check_match(&mtpar, XT_ALIGN(match->matchsize), match->proto,
+			     0);
+	if (err)
+		goto exit;
+
+	return match;
+
+exit:
+	OVS_NLERR(true, "Failed to set connlabel length");
+	if (match)
+		module_put(match->me);
+#endif
+	return NULL;
+}
+
+void ovs_ct_init(struct net *net, struct ovs_ct_perdp_data *data)
+{
+	data->xt_v4 = !nf_ct_l3proto_try_module_get(PF_INET);
+	data->xt_v6 = !nf_ct_l3proto_try_module_get(PF_INET6);
+	data->xt_label = load_connlabel(net);
+}
+
+void ovs_ct_exit(struct net *net, struct ovs_ct_perdp_data *data)
+{
+	if (data->xt_v4)
+		nf_ct_l3proto_module_put(PF_INET);
+	if (data->xt_v6)
+		nf_ct_l3proto_module_put(PF_INET6);
+	if (data->xt_label) {
+		const struct xt_match *match = data->xt_label;
+		struct xt_mtdtor_param mtd;
+
+		mtd.net = net;
+		mtd.match = match;
+		mtd.matchinfo = NULL;
+		mtd.family = NFPROTO_IPV4;
+
+		module_put(match->me);
+		mtd.match->destroy(&mtd);
+	}
+}
diff --git a/net/openvswitch/conntrack.h b/net/openvswitch/conntrack.h
index 03a1ec5..e85375e 100644
--- a/net/openvswitch/conntrack.h
+++ b/net/openvswitch/conntrack.h
@@ -14,6 +14,7 @@
 #ifndef OVS_CONNTRACK_H
 #define OVS_CONNTRACK_H 1
 
+struct xt_match;
 struct ovs_net;
 struct sw_flow_key;
 struct sw_flow_actions;
@@ -21,7 +22,15 @@ struct ovs_conntrack_info;
 struct ovs_key_ct_label;
 enum ovs_key_attr;
 
+struct ovs_ct_perdp_data {
+	bool xt_v4;
+	bool xt_v6;
+	struct xt_match *xt_label;
+};
+
 #if defined(CONFIG_OPENVSWITCH_CONNTRACK)
+void ovs_ct_init(struct net *, struct ovs_ct_perdp_data *data);
+void ovs_ct_exit(struct net *, struct ovs_ct_perdp_data *data);
 bool ovs_ct_verify(enum ovs_key_attr attr);
 int ovs_ct_copy_action(struct net *, const struct nlattr *,
 		       const struct sw_flow_key *, struct sw_flow_actions **,
@@ -34,6 +43,11 @@ int ovs_ct_execute(struct sk_buff *, struct sw_flow_key *,
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
@@ -41,6 +55,14 @@ void ovs_ct_free_action(const struct nlattr *a);
 #else
 #include <linux/errno.h>
 
+static inline void ovs_ct_init(struct net *net, struct ovs_ct_perdp_data *data)
+{
+}
+
+static inline void ovs_ct_exit(struct net *net, struct ovs_ct_perdp_data *data)
+{
+}
+
 static inline bool ovs_ct_verify(int attr)
 {
 	return false;
@@ -91,6 +113,16 @@ static inline int ovs_ct_set_mark(struct sk_buff *skb, struct sw_flow_key *key,
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
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 23717a3..1d1d675 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1583,6 +1583,9 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 
 	ovs_dp_change(dp, a);
 
+	/* Set up conntrack dependencies. */
+	ovs_ct_init(read_pnet(&dp->net), &dp->ct);
+
 	/* So far only local changes have been made, now need the lock. */
 	ovs_lock();
 
@@ -1619,6 +1622,7 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 err_destroy_ports_array:
 	ovs_unlock();
 	kfree(dp->ports);
+	ovs_ct_exit(read_pnet(&dp->net), &dp->ct);
 err_destroy_percpu:
 	free_percpu(dp->stats_percpu);
 err_destroy_table:
@@ -1652,6 +1656,8 @@ static void __dp_destroy(struct datapath *dp)
 	 */
 	ovs_dp_detach_port(ovs_vport_ovsl(dp, OVSP_LOCAL));
 
+	ovs_ct_exit(read_pnet(&dp->net), &dp->ct);
+
 	/* RCU destroy the flow table */
 	call_rcu(&dp->rcu, destroy_dp_rcu);
 }
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index fc808a2..fd8d146 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -90,6 +90,8 @@ struct datapath {
 	possible_net_t net;
 
 	u32 user_features;
+
+	struct ovs_ct_perdp_data ct;
 };
 
 /**
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
index 90e80a6..69ab7af 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -282,7 +282,7 @@ size_t ovs_key_attr_size(void)
 	/* Whenever adding new OVS_KEY_ FIELDS, we should consider
 	 * updating this function.
 	 */
-	BUILD_BUG_ON(OVS_KEY_ATTR_TUNNEL_INFO != 25);
+	BUILD_BUG_ON(OVS_KEY_ATTR_TUNNEL_INFO != 26);
 
 	return    nla_total_size(4)   /* OVS_KEY_ATTR_PRIORITY */
 		+ nla_total_size(0)   /* OVS_KEY_ATTR_TUNNEL */
@@ -294,6 +294,7 @@ size_t ovs_key_attr_size(void)
 		+ nla_total_size(1)   /* OVS_KEY_ATTR_CT_STATE */
 		+ nla_total_size(2)   /* OVS_KEY_ATTR_CT_ZONE */
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_CT_MARK */
+		+ nla_total_size(16)  /* OVS_KEY_ATTR_CT_LABEL */
 		+ nla_total_size(12)  /* OVS_KEY_ATTR_ETHERNET */
 		+ nla_total_size(2)   /* OVS_KEY_ATTR_ETHERTYPE */
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_VLAN */
@@ -346,6 +347,7 @@ static const struct ovs_len_tbl ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
 	[OVS_KEY_ATTR_CT_STATE]	 = { .len = sizeof(u8) },
 	[OVS_KEY_ATTR_CT_ZONE]	 = { .len = sizeof(u16) },
 	[OVS_KEY_ATTR_CT_MARK]	 = { .len = sizeof(u32) },
+	[OVS_KEY_ATTR_CT_LABEL]	 = { .len = sizeof(struct ovs_key_ct_label) },
 };
 
 static bool is_all_zero(const u8 *fp, size_t size)
@@ -797,6 +799,15 @@ static int metadata_from_nlattrs(struct sw_flow_match *match,  u64 *attrs,
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
 
@@ -1353,6 +1364,10 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
 	if (nla_put_u32(skb, OVS_KEY_ATTR_CT_MARK, output->ct.mark))
 		goto nla_put_failure;
 
+	if (nla_put(skb, OVS_KEY_ATTR_CT_LABEL,
+		    sizeof(output->ct.label), &output->ct.label))
+		goto nla_put_failure;
+
 	nla = nla_reserve(skb, OVS_KEY_ATTR_ETHERNET, sizeof(*eth_key));
 	if (!nla)
 		goto nla_put_failure;
@@ -1936,6 +1951,7 @@ static int validate_set(const struct nlattr *a,
 	case OVS_KEY_ATTR_PRIORITY:
 	case OVS_KEY_ATTR_SKB_MARK:
 	case OVS_KEY_ATTR_CT_MARK:
+	case OVS_KEY_ATTR_CT_LABEL:
 	case OVS_KEY_ATTR_ETHERNET:
 		break;
 
-- 
2.1.4
