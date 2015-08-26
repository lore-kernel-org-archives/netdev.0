From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv6 net-next 09/10] openvswitch: Allow matching on conntrack label
Date: Wed, 26 Aug 2015 11:31:52 -0700
Message-ID: <1440613913-10141-10-git-send-email-joestringer@nicira.com>
References: <1440613913-10141-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org, pablo@netfilter.org,
	fwestpha@redhat.com, hannes@redhat.com, tgraf@suug.ch,
	jpettit@nicira.com, jesse@nicira.com,
	netfilter-devel@vger.kernel.org
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440613913-10141-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow matching and setting the ct_label field. As with ct_mark, this is
populated by executing the CT action. The label field may be modified by
specifying a label and mask nested under the CT action. It is stored as
metadata attached to the connection. Label modification occurs after
lookup, and will only persist when the conntrack entry is committed by
providing the COMMIT flag to the CT action. Labels are currently fixed
to 128 bits in size.

Signed-off-by: Joe Stringer <joestringer@nicira.com>
Acked-by: Thomas Graf <tgraf@suug.ch>
Acked-by: Pravin B Shelar <pshelar@nicira.com>
---
v2: Split out setting the connlabel size for the current namespace.
v3: No change.
v4: Only allow setting label via ct action.
    Update documentation.
v5: Fix ovs_ct_verify().
    Add label to ct action serialization.
    Free label bit length/reference properly.
    Configure OVS label length per-netns, not per-dp.
    Reject ct actions with label length longer than supported.
    Replace some #ifdefs with IS_ENABLED.
    Rebase.
v6: Add acks.
---
 include/uapi/linux/openvswitch.h |  10 +++
 net/openvswitch/actions.c        |   1 +
 net/openvswitch/conntrack.c      | 128 ++++++++++++++++++++++++++++++++++++++-
 net/openvswitch/conntrack.h      |  11 +++-
 net/openvswitch/datapath.c       |  18 +++---
 net/openvswitch/datapath.h       |   3 +
 net/openvswitch/flow.c           |   4 +-
 net/openvswitch/flow.h           |   3 +-
 net/openvswitch/flow_netlink.c   |  46 +++++++++-----
 net/openvswitch/flow_netlink.h   |   9 +--
 10 files changed, 199 insertions(+), 34 deletions(-)

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
index 9741d2c..736a113 100644
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
index e53dafc..a0417fb 100644
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
 	struct nf_conntrack_zone zone;
@@ -41,6 +48,7 @@ struct ovs_conntrack_info {
 	u32 flags;
 	u16 family;
 	struct md_mark mark;
+	struct md_label label;
 };
 
 static u16 key_to_nfproto(const struct sw_flow_key *key)
@@ -90,6 +98,24 @@ static u8 ovs_ct_get_state(enum ip_conntrack_info ctinfo)
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
 static void __ovs_ct_update_key(struct sw_flow_key *key, u8 state,
 				const struct nf_conntrack_zone *zone,
 				const struct nf_conn *ct)
@@ -97,6 +123,7 @@ static void __ovs_ct_update_key(struct sw_flow_key *key, u8 state,
 	key->ct.state = state;
 	key->ct.zone = zone->id;
 	key->ct.mark = ct ? ct->mark : 0;
+	ovs_ct_get_label(ct, &key->ct.label);
 }
 
 /* Update 'key' based on skb->nfct. If 'post_ct' is true, then OVS has
@@ -140,6 +167,11 @@ int ovs_ct_put_key(const struct sw_flow_key *key, struct sk_buff *skb)
 	    nla_put_u32(skb, OVS_KEY_ATTR_CT_MARK, key->ct.mark))
 		return -EMSGSIZE;
 
+	if (IS_ENABLED(CONFIG_NF_CONNTRACK_LABEL) &&
+	    nla_put(skb, OVS_KEY_ATTR_CT_LABEL, sizeof(key->ct.label),
+		    &key->ct.label))
+		return -EMSGSIZE;
+
 	return 0;
 }
 
@@ -168,6 +200,40 @@ static int ovs_ct_set_mark(struct sk_buff *skb, struct sw_flow_key *key,
 	return 0;
 }
 
+static int ovs_ct_set_label(struct sk_buff *skb, struct sw_flow_key *key,
+			    const struct ovs_key_ct_label *label,
+			    const struct ovs_key_ct_label *mask)
+{
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn_labels *cl;
+	struct nf_conn *ct;
+	int err;
+
+	if (!IS_ENABLED(CONFIG_NF_CONNTRACK_LABELS))
+		return -ENOTSUPP;
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
+}
+
 static int handle_fragments(struct net *net, struct sw_flow_key *key,
 			    u16 zone, struct sk_buff *skb)
 {
@@ -327,6 +393,17 @@ static int ovs_ct_commit(struct net *net, struct sw_flow_key *key,
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
@@ -351,9 +428,15 @@ int ovs_ct_execute(struct net *net, struct sk_buff *skb,
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
@@ -366,6 +449,8 @@ static const struct ovs_ct_len_tbl ovs_ct_attr_lens[OVS_CT_ATTR_MAX + 1] = {
 				    .maxlen = sizeof(u16) },
 	[OVS_CT_ATTR_MARK]	= { .minlen = sizeof(struct md_mark),
 				    .maxlen = sizeof(struct md_mark) },
+	[OVS_CT_ATTR_LABEL]	= { .minlen = sizeof(struct md_label),
+				    .maxlen = sizeof(struct md_label) },
 };
 
 static int parse_ct(const struct nlattr *attr, struct ovs_conntrack_info *info,
@@ -409,6 +494,14 @@ static int parse_ct(const struct nlattr *attr, struct ovs_conntrack_info *info,
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
@@ -424,7 +517,7 @@ static int parse_ct(const struct nlattr *attr, struct ovs_conntrack_info *info,
 	return 0;
 }
 
-bool ovs_ct_verify(enum ovs_key_attr attr)
+bool ovs_ct_verify(struct net *net, enum ovs_key_attr attr)
 {
 	if (attr == OVS_KEY_ATTR_CT_STATE)
 		return true;
@@ -434,6 +527,12 @@ bool ovs_ct_verify(enum ovs_key_attr attr)
 	if (IS_ENABLED(CONFIG_NF_CONNTRACK_MARK) &&
 	    attr == OVS_KEY_ATTR_CT_MARK)
 		return true;
+	if (IS_ENABLED(CONFIG_NF_CONNTRACK_LABELS) &&
+	    attr == OVS_KEY_ATTR_CT_LABEL) {
+		struct ovs_net *ovs_net = net_generic(net, ovs_net_id);
+
+		return ovs_net->xt_label;
+	}
 
 	return false;
 }
@@ -500,6 +599,10 @@ int ovs_ct_action_to_attr(const struct ovs_conntrack_info *ct_info,
 	    nla_put(skb, OVS_CT_ATTR_MARK, sizeof(ct_info->mark),
 		    &ct_info->mark))
 		return -EMSGSIZE;
+	if (IS_ENABLED(CONFIG_NF_CONNTRACK_LABELS) &&
+	    nla_put(skb, OVS_CT_ATTR_LABEL, sizeof(ct_info->label),
+		    &ct_info->label))
+		return -EMSGSIZE;
 
 	nla_nest_end(skb, start);
 
@@ -513,3 +616,24 @@ void ovs_ct_free_action(const struct nlattr *a)
 	if (ct_info->ct)
 		nf_ct_put(ct_info->ct);
 }
+
+void ovs_ct_init(struct net *net)
+{
+	unsigned int n_bits = sizeof(struct ovs_key_ct_label) * BITS_PER_BYTE;
+	struct ovs_net *ovs_net = net_generic(net, ovs_net_id);
+
+	if (nf_connlabels_get(net, n_bits)) {
+		ovs_net->xt_label = false;
+		OVS_NLERR(true, "Failed to set connlabel length");
+	} else {
+		ovs_net->xt_label = true;
+	}
+}
+
+void ovs_ct_exit(struct net *net)
+{
+	struct ovs_net *ovs_net = net_generic(net, ovs_net_id);
+
+	if (ovs_net->xt_label)
+		nf_connlabels_put(net);
+}
diff --git a/net/openvswitch/conntrack.h b/net/openvswitch/conntrack.h
index 87b289c..3cb3066 100644
--- a/net/openvswitch/conntrack.h
+++ b/net/openvswitch/conntrack.h
@@ -20,7 +20,9 @@ struct ovs_conntrack_info;
 enum ovs_key_attr;
 
 #if defined(CONFIG_OPENVSWITCH_CONNTRACK)
-bool ovs_ct_verify(enum ovs_key_attr attr);
+void ovs_ct_init(struct net *);
+void ovs_ct_exit(struct net *);
+bool ovs_ct_verify(struct net *, enum ovs_key_attr attr);
 int ovs_ct_copy_action(struct net *, const struct nlattr *,
 		       const struct sw_flow_key *, struct sw_flow_actions **,
 		       bool log);
@@ -35,7 +37,11 @@ void ovs_ct_free_action(const struct nlattr *a);
 #else
 #include <linux/errno.h>
 
-static inline bool ovs_ct_verify(int attr)
+static inline void ovs_ct_init(struct net *net) { }
+
+static inline void ovs_ct_exit(struct net *net) { }
+
+static inline bool ovs_ct_verify(struct net *net, int attr)
 {
 	return false;
 }
@@ -66,6 +72,7 @@ static inline void ovs_ct_fill_key(const struct sk_buff *skb,
 	key->ct.state = 0;
 	key->ct.zone = 0;
 	key->ct.mark = 0;
+	memset(&key->ct.label, 0, sizeof(key->ct.label));
 }
 
 static inline int ovs_ct_put_key(const struct sw_flow_key *key,
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 72e6372..ec0f8d9 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -599,8 +599,8 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	if (IS_ERR(flow))
 		goto err_kfree_skb;
 
-	err = ovs_flow_key_extract_userspace(a[OVS_PACKET_ATTR_KEY], packet,
-					     &flow->key, log);
+	err = ovs_flow_key_extract_userspace(net, a[OVS_PACKET_ATTR_KEY],
+					     packet, &flow->key, log);
 	if (err)
 		goto err_flow_free;
 
@@ -947,7 +947,7 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 
 	/* Extract key. */
 	ovs_match_init(&match, &key, &mask);
-	error = ovs_nla_get_match(&match, a[OVS_FLOW_ATTR_KEY],
+	error = ovs_nla_get_match(net, &match, a[OVS_FLOW_ATTR_KEY],
 				  a[OVS_FLOW_ATTR_MASK], log);
 	if (error)
 		goto err_kfree_flow;
@@ -1118,7 +1118,7 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
 
 	ufid_present = ovs_nla_get_ufid(&sfid, a[OVS_FLOW_ATTR_UFID], log);
 	ovs_match_init(&match, &key, &mask);
-	error = ovs_nla_get_match(&match, a[OVS_FLOW_ATTR_KEY],
+	error = ovs_nla_get_match(net, &match, a[OVS_FLOW_ATTR_KEY],
 				  a[OVS_FLOW_ATTR_MASK], log);
 	if (error)
 		goto error;
@@ -1208,6 +1208,7 @@ static int ovs_flow_cmd_get(struct sk_buff *skb, struct genl_info *info)
 {
 	struct nlattr **a = info->attrs;
 	struct ovs_header *ovs_header = info->userhdr;
+	struct net *net = sock_net(skb->sk);
 	struct sw_flow_key key;
 	struct sk_buff *reply;
 	struct sw_flow *flow;
@@ -1222,7 +1223,7 @@ static int ovs_flow_cmd_get(struct sk_buff *skb, struct genl_info *info)
 	ufid_present = ovs_nla_get_ufid(&ufid, a[OVS_FLOW_ATTR_UFID], log);
 	if (a[OVS_FLOW_ATTR_KEY]) {
 		ovs_match_init(&match, &key, NULL);
-		err = ovs_nla_get_match(&match, a[OVS_FLOW_ATTR_KEY], NULL,
+		err = ovs_nla_get_match(net, &match, a[OVS_FLOW_ATTR_KEY], NULL,
 					log);
 	} else if (!ufid_present) {
 		OVS_NLERR(log,
@@ -1266,6 +1267,7 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
 {
 	struct nlattr **a = info->attrs;
 	struct ovs_header *ovs_header = info->userhdr;
+	struct net *net = sock_net(skb->sk);
 	struct sw_flow_key key;
 	struct sk_buff *reply;
 	struct sw_flow *flow = NULL;
@@ -1280,8 +1282,8 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	ufid_present = ovs_nla_get_ufid(&ufid, a[OVS_FLOW_ATTR_UFID], log);
 	if (a[OVS_FLOW_ATTR_KEY]) {
 		ovs_match_init(&match, &key, NULL);
-		err = ovs_nla_get_match(&match, a[OVS_FLOW_ATTR_KEY], NULL,
-					log);
+		err = ovs_nla_get_match(net, &match, a[OVS_FLOW_ATTR_KEY],
+					NULL, log);
 		if (unlikely(err))
 			return err;
 	}
@@ -2237,6 +2239,7 @@ static int __net_init ovs_init_net(struct net *net)
 
 	INIT_LIST_HEAD(&ovs_net->dps);
 	INIT_WORK(&ovs_net->dp_notify_work, ovs_dp_notify_wq);
+	ovs_ct_init(net);
 	return 0;
 }
 
@@ -2271,6 +2274,7 @@ static void __net_exit ovs_exit_net(struct net *dnet)
 	struct net *net;
 	LIST_HEAD(head);
 
+	ovs_ct_exit(dnet);
 	ovs_lock();
 	list_for_each_entry_safe(dp, dp_next, &ovs_net->dps, list_node)
 		__dp_destroy(dp);
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index d24ba98..4e785ab 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -138,6 +138,9 @@ struct ovs_net {
 	struct list_head dps;
 	struct work_struct dp_notify_work;
 	struct vport_net vport_net;
+
+	/* Module reference for configuring conntrack. */
+	bool xt_label;
 };
 
 extern int ovs_net_id;
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 376ca87..5a3195e 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -715,7 +715,7 @@ int ovs_flow_key_extract(const struct ip_tunnel_info *tun_info,
 	return key_extract(skb, key);
 }
 
-int ovs_flow_key_extract_userspace(const struct nlattr *attr,
+int ovs_flow_key_extract_userspace(struct net *net, const struct nlattr *attr,
 				   struct sk_buff *skb,
 				   struct sw_flow_key *key, bool log)
 {
@@ -724,7 +724,7 @@ int ovs_flow_key_extract_userspace(const struct nlattr *attr,
 	memset(key, 0, OVS_SW_FLOW_KEY_METADATA_SIZE);
 
 	/* Extract metadata from netlink attributes. */
-	err = ovs_nla_get_flow_metadata(attr, key, log);
+	err = ovs_nla_get_flow_metadata(net, attr, key, log);
 	if (err)
 		return err;
 
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index e05e697..fe527d2 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -116,6 +116,7 @@ struct sw_flow_key {
 		u16 zone;
 		u32 mark;
 		u8 state;
+		struct ovs_key_ct_label label;
 	} ct;
 
 } __aligned(BITS_PER_LONG/8); /* Ensure that we can do comparisons as longs. */
@@ -220,7 +221,7 @@ int ovs_flow_key_extract(const struct ip_tunnel_info *tun_info,
 			 struct sk_buff *skb,
 			 struct sw_flow_key *key);
 /* Extract key from packet coming from userspace. */
-int ovs_flow_key_extract_userspace(const struct nlattr *attr,
+int ovs_flow_key_extract_userspace(struct net *net, const struct nlattr *attr,
 				   struct sk_buff *skb,
 				   struct sw_flow_key *key, bool log);
 
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index b17a4ec..e22c5bf 100644
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
@@ -721,9 +723,9 @@ int ovs_nla_put_egress_tunnel_key(struct sk_buff *skb,
 				    egress_tun_info->options_len);
 }
 
-static int metadata_from_nlattrs(struct sw_flow_match *match,  u64 *attrs,
-				 const struct nlattr **a, bool is_mask,
-				 bool log)
+static int metadata_from_nlattrs(struct net *net, struct sw_flow_match *match,
+				 u64 *attrs, const struct nlattr **a,
+				 bool is_mask, bool log)
 {
 	if (*attrs & (1 << OVS_KEY_ATTR_DP_HASH)) {
 		u32 hash_val = nla_get_u32(a[OVS_KEY_ATTR_DP_HASH]);
@@ -776,36 +778,45 @@ static int metadata_from_nlattrs(struct sw_flow_match *match,  u64 *attrs,
 	}
 
 	if (*attrs & (1 << OVS_KEY_ATTR_CT_STATE) &&
-	    ovs_ct_verify(OVS_KEY_ATTR_CT_STATE)) {
+	    ovs_ct_verify(net, OVS_KEY_ATTR_CT_STATE)) {
 		u8 ct_state = nla_get_u8(a[OVS_KEY_ATTR_CT_STATE]);
 
 		SW_FLOW_KEY_PUT(match, ct.state, ct_state, is_mask);
 		*attrs &= ~(1ULL << OVS_KEY_ATTR_CT_STATE);
 	}
 	if (*attrs & (1 << OVS_KEY_ATTR_CT_ZONE) &&
-	    ovs_ct_verify(OVS_KEY_ATTR_CT_ZONE)) {
+	    ovs_ct_verify(net, OVS_KEY_ATTR_CT_ZONE)) {
 		u16 ct_zone = nla_get_u16(a[OVS_KEY_ATTR_CT_ZONE]);
 
 		SW_FLOW_KEY_PUT(match, ct.zone, ct_zone, is_mask);
 		*attrs &= ~(1ULL << OVS_KEY_ATTR_CT_ZONE);
 	}
 	if (*attrs & (1 << OVS_KEY_ATTR_CT_MARK) &&
-	    ovs_ct_verify(OVS_KEY_ATTR_CT_MARK)) {
+	    ovs_ct_verify(net, OVS_KEY_ATTR_CT_MARK)) {
 		u32 mark = nla_get_u32(a[OVS_KEY_ATTR_CT_MARK]);
 
 		SW_FLOW_KEY_PUT(match, ct.mark, mark, is_mask);
 		*attrs &= ~(1ULL << OVS_KEY_ATTR_CT_MARK);
 	}
+	if (*attrs & (1 << OVS_KEY_ATTR_CT_LABEL) &&
+	    ovs_ct_verify(net, OVS_KEY_ATTR_CT_LABEL)) {
+		const struct ovs_key_ct_label *cl;
+
+		cl = nla_data(a[OVS_KEY_ATTR_CT_LABEL]);
+		SW_FLOW_KEY_MEMCPY(match, ct.label, cl->ct_label,
+				   sizeof(*cl), is_mask);
+		*attrs &= ~(1ULL << OVS_KEY_ATTR_CT_LABEL);
+	}
 	return 0;
 }
 
-static int ovs_key_from_nlattrs(struct sw_flow_match *match, u64 attrs,
-				const struct nlattr **a, bool is_mask,
-				bool log)
+static int ovs_key_from_nlattrs(struct net *net, struct sw_flow_match *match,
+				u64 attrs, const struct nlattr **a,
+				bool is_mask, bool log)
 {
 	int err;
 
-	err = metadata_from_nlattrs(match, &attrs, a, is_mask, log);
+	err = metadata_from_nlattrs(net, match, &attrs, a, is_mask, log);
 	if (err)
 		return err;
 
@@ -1057,6 +1068,7 @@ static void mask_set_nlattr(struct nlattr *attr, u8 val)
  * mask. In case the 'mask' is NULL, the flow is treated as exact match
  * flow. Otherwise, it is treated as a wildcarded flow, except the mask
  * does not include any don't care bit.
+ * @net: Used to determine per-namespace field support.
  * @match: receives the extracted flow match information.
  * @key: Netlink attribute holding nested %OVS_KEY_ATTR_* Netlink attribute
  * sequence. The fields should of the packet that triggered the creation
@@ -1067,7 +1079,7 @@ static void mask_set_nlattr(struct nlattr *attr, u8 val)
  * probing for feature compatibility this should be passed in as false to
  * suppress unnecessary error logging.
  */
-int ovs_nla_get_match(struct sw_flow_match *match,
+int ovs_nla_get_match(struct net *net, struct sw_flow_match *match,
 		      const struct nlattr *nla_key,
 		      const struct nlattr *nla_mask,
 		      bool log)
@@ -1117,7 +1129,7 @@ int ovs_nla_get_match(struct sw_flow_match *match,
 		}
 	}
 
-	err = ovs_key_from_nlattrs(match, key_attrs, a, false, log);
+	err = ovs_key_from_nlattrs(net, match, key_attrs, a, false, log);
 	if (err)
 		return err;
 
@@ -1197,7 +1209,8 @@ int ovs_nla_get_match(struct sw_flow_match *match,
 			}
 		}
 
-		err = ovs_key_from_nlattrs(match, mask_attrs, a, true, log);
+		err = ovs_key_from_nlattrs(net, match, mask_attrs, a, true,
+					   log);
 		if (err)
 			goto free_newmask;
 	}
@@ -1278,7 +1291,7 @@ u32 ovs_nla_get_ufid_flags(const struct nlattr *attr)
  * extracted from the packet itself.
  */
 
-int ovs_nla_get_flow_metadata(const struct nlattr *attr,
+int ovs_nla_get_flow_metadata(struct net *net, const struct nlattr *attr,
 			      struct sw_flow_key *key,
 			      bool log)
 {
@@ -1297,7 +1310,7 @@ int ovs_nla_get_flow_metadata(const struct nlattr *attr,
 	memset(&key->ct, 0, sizeof(key->ct));
 	key->phy.in_port = DP_MAX_PORTS;
 
-	return metadata_from_nlattrs(&match, &attrs, a, false, log);
+	return metadata_from_nlattrs(net, &match, &attrs, a, false, log);
 }
 
 static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
@@ -1929,6 +1942,7 @@ static int validate_set(const struct nlattr *a,
 	case OVS_KEY_ATTR_PRIORITY:
 	case OVS_KEY_ATTR_SKB_MARK:
 	case OVS_KEY_ATTR_CT_MARK:
+	case OVS_KEY_ATTR_CT_LABEL:
 	case OVS_KEY_ATTR_ETHERNET:
 		break;
 
diff --git a/net/openvswitch/flow_netlink.h b/net/openvswitch/flow_netlink.h
index c0b484b..07878e2 100644
--- a/net/openvswitch/flow_netlink.h
+++ b/net/openvswitch/flow_netlink.h
@@ -45,15 +45,16 @@ void ovs_match_init(struct sw_flow_match *match,
 
 int ovs_nla_put_key(const struct sw_flow_key *, const struct sw_flow_key *,
 		    int attr, bool is_mask, struct sk_buff *);
-int ovs_nla_get_flow_metadata(const struct nlattr *, struct sw_flow_key *,
-			      bool log);
+int ovs_nla_get_flow_metadata(struct net *, const struct nlattr *,
+			      struct sw_flow_key *, bool log);
 
 int ovs_nla_put_identifier(const struct sw_flow *flow, struct sk_buff *skb);
 int ovs_nla_put_masked_key(const struct sw_flow *flow, struct sk_buff *skb);
 int ovs_nla_put_mask(const struct sw_flow *flow, struct sk_buff *skb);
 
-int ovs_nla_get_match(struct sw_flow_match *, const struct nlattr *key,
-		      const struct nlattr *mask, bool log);
+int ovs_nla_get_match(struct net *, struct sw_flow_match *,
+		      const struct nlattr *key, const struct nlattr *mask,
+		      bool log);
 int ovs_nla_put_egress_tunnel_key(struct sk_buff *,
 				  const struct ip_tunnel_info *);
 
-- 
2.1.4
