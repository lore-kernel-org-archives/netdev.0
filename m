From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv3 net-next 06/10] openvswitch: Allow matching on conntrack mark
Date: Tue, 11 Aug 2015 15:59:17 -0700
Message-ID: <1439333961-24474-7-git-send-email-joestringer@nicira.com>
References: <1439333961-24474-1-git-send-email-joestringer@nicira.com>
Cc: Justin Pettit <jpettit@nicira.com>, linux-kernel@vger.kernel.org,
	pablo@netfilter.org, kaber@trash.net, pshelar@nicira.com,
	azhou@nicira.com, jesse@nicira.com, fwestpha@redhat.com,
	hannes@redhat.com, tgraf@noironetworks.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439333961-24474-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Justin Pettit <jpettit@nicira.com>

Allow matching and setting the conntrack mark field. As with conntrack
state and zone, these are populated by executing the ct() action. Unlike
these, the ct_mark is also a writable field. The set_field() action may
be used to modify the mark, which will take effect on the most recent
conntrack entry.

E.g.: actions:ct(zone=0),ct(zone=1),set_field(1->ct_mark)

This will perform conntrack lookup in zone 0, then lookup in zone 1,
then modify the mark for the entry in zone 1. The mark for the entry in
zone 0 is unchanged. The conntrack entry itself must be committed using
the "commit" flag in the conntrack action flags for this change to persist.

Signed-off-by: Justin Pettit <jpettit@nicira.com>
Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
 include/uapi/linux/openvswitch.h |  1 +
 net/openvswitch/actions.c        |  6 ++++++
 net/openvswitch/conntrack.c      | 40 ++++++++++++++++++++++++++++++++++++++++
 net/openvswitch/conntrack.h      | 14 ++++++++++++++
 net/openvswitch/flow.c           |  1 +
 net/openvswitch/flow.h           |  1 +
 net/openvswitch/flow_netlink.c   | 15 ++++++++++++++-
 7 files changed, 77 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 1dae30a..207788c 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -325,6 +325,7 @@ enum ovs_key_attr {
 				 * the accepted length of the array. */
 	OVS_KEY_ATTR_CT_STATE,	/* u8 bitmask of OVS_CS_F_* */
 	OVS_KEY_ATTR_CT_ZONE,	/* u16 connection tracking zone. */
+	OVS_KEY_ATTR_CT_MARK,	/* u32 connection tracking mark */
 
 #ifdef __KERNEL__
 	OVS_KEY_ATTR_TUNNEL_INFO,  /* struct ip_tunnel_info */
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 5e1ed86..5acd7e7 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -957,6 +957,12 @@ static int execute_masked_set_action(struct sk_buff *skb,
 		err = set_mpls(skb, flow_key, nla_data(a), get_mask(a,
 								    __be32 *));
 		break;
+
+	case OVS_KEY_ATTR_CT_MARK:
+		err = ovs_ct_set_mark(skb, flow_key, nla_get_u32(a),
+				      *get_mask(a, u32 *));
+		break;
+
 	}
 
 	return err;
diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 586ce66..81b80da 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -101,6 +101,15 @@ u16 ovs_ct_get_zone(const struct sk_buff *skb)
 	return ct ? nf_ct_zone(ct) : NF_CT_DEFAULT_ZONE;
 }
 
+u32 ovs_ct_get_mark(const struct sk_buff *skb)
+{
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn *ct;
+
+	ct = nf_ct_get(skb, &ctinfo);
+	return ct ? ct->mark : 0;
+}
+
 static bool __ovs_ct_state_valid(u8 state)
 {
 	return (state && !(state & OVS_CS_F_INVALID));
@@ -192,6 +201,7 @@ static void __ovs_ct_update_key(struct sk_buff *skb, struct sw_flow_key *key,
 {
 	key->ct.state = state;
 	key->ct.zone = zone;
+	key->ct.mark = ovs_ct_get_mark(skb);
 }
 
 static void ovs_ct_update_key(struct sk_buff *skb, struct sw_flow_key *key,
@@ -323,6 +333,32 @@ int ovs_ct_execute(struct net *net, struct sk_buff *skb,
 	return err;
 }
 
+int ovs_ct_set_mark(struct sk_buff *skb, struct sw_flow_key *key,
+		    u32 ct_mark, u32 mask)
+{
+#ifdef CONFIG_NF_CONNTRACK_MARK
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn *ct;
+	u32 new_mark;
+
+	/* This must happen directly after lookup/commit. */
+	ct = nf_ct_get(skb, &ctinfo);
+	if (!ct)
+		return -EINVAL;
+
+	new_mark = ct_mark | (ct->mark & ~(mask));
+	if (ct->mark != new_mark) {
+		ct->mark = new_mark;
+		nf_conntrack_event_cache(IPCT_MARK, ct);
+		key->ct.mark = ct_mark;
+	}
+
+	return 0;
+#else
+	return -ENOTSUPP;
+#endif
+}
+
 static const struct ovs_ct_len_tbl ovs_ct_attr_lens[OVS_CT_ATTR_MAX + 1] = {
 	[OVS_CT_ATTR_FLAGS]	= { .minlen = sizeof(u32),
 				    .maxlen = sizeof(u32) },
@@ -386,6 +422,10 @@ bool ovs_ct_verify(enum ovs_key_attr attr)
 	if (attr & OVS_KEY_ATTR_CT_ZONE)
 		return true;
 #endif
+#ifdef CONFIG_NF_CONNTRACK_MARK
+	if (attr & OVS_KEY_ATTR_CT_MARK)
+		return true;
+#endif
 
 	return false;
 }
diff --git a/net/openvswitch/conntrack.h b/net/openvswitch/conntrack.h
index 0e09a6d..b0f06b4 100644
--- a/net/openvswitch/conntrack.h
+++ b/net/openvswitch/conntrack.h
@@ -37,6 +37,9 @@ int ovs_ct_action_to_attr(const struct ovs_conntrack_info *, struct sk_buff *);
 int ovs_ct_execute(struct net *, struct sk_buff *, struct sw_flow_key *,
 		   const struct ovs_conntrack_info *);
 
+int ovs_ct_set_mark(struct sk_buff *, struct sw_flow_key *, u32 ct_mark,
+		    u32 mask);
+u32 ovs_ct_get_mark(const struct sk_buff *skb);
 u8 ovs_ct_get_state(const struct sk_buff *skb);
 u16 ovs_ct_get_zone(const struct sk_buff *skb);
 bool ovs_ct_state_valid(const struct sw_flow_key *key);
@@ -87,11 +90,22 @@ static inline u16 ovs_ct_get_zone(const struct sk_buff *skb)
 	return 0;
 }
 
+static inline u32 ovs_ct_get_mark(const struct sk_buff *skb)
+{
+	return 0;
+}
+
 static inline bool ovs_ct_state_valid(const struct sw_flow_key *key)
 {
 	return false;
 }
 
+static inline int ovs_ct_set_mark(struct sk_buff *skb, struct sw_flow_key *key,
+				  u32 ct_mark, u32 mask)
+{
+	return -ENOTSUPP;
+}
+
 static inline void ovs_ct_free_action(const struct nlattr *a) { }
 #endif
 #endif /* ovs_conntrack.h */
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 131b807..05ce284 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -710,6 +710,7 @@ int ovs_flow_key_extract(const struct ip_tunnel_info *tun_info,
 	key->phy.skb_mark = skb->mark;
 	key->ct.state = ovs_ct_get_state(skb);
 	key->ct.zone = ovs_ct_get_zone(skb);
+	key->ct.mark = ovs_ct_get_mark(skb);
 	key->ovs_flow_hash = 0;
 	key->recirc_id = 0;
 
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index 312c7d7..e05e697 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -114,6 +114,7 @@ struct sw_flow_key {
 	struct {
 		/* Connection tracking fields. */
 		u16 zone;
+		u32 mark;
 		u8 state;
 	} ct;
 
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index ec64463..e54de9b 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -281,7 +281,7 @@ size_t ovs_key_attr_size(void)
 	/* Whenever adding new OVS_KEY_ FIELDS, we should consider
 	 * updating this function.
 	 */
-	BUILD_BUG_ON(OVS_KEY_ATTR_TUNNEL_INFO != 24);
+	BUILD_BUG_ON(OVS_KEY_ATTR_TUNNEL_INFO != 25);
 
 	return    nla_total_size(4)   /* OVS_KEY_ATTR_PRIORITY */
 		+ nla_total_size(0)   /* OVS_KEY_ATTR_TUNNEL */
@@ -292,6 +292,7 @@ size_t ovs_key_attr_size(void)
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_RECIRC_ID */
 		+ nla_total_size(1)   /* OVS_KEY_ATTR_CT_STATE */
 		+ nla_total_size(2)   /* OVS_KEY_ATTR_CT_ZONE */
+		+ nla_total_size(4)   /* OVS_KEY_ATTR_CT_MARK */
 		+ nla_total_size(12)  /* OVS_KEY_ATTR_ETHERNET */
 		+ nla_total_size(2)   /* OVS_KEY_ATTR_ETHERTYPE */
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_VLAN */
@@ -343,6 +344,7 @@ static const struct ovs_len_tbl ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
 	[OVS_KEY_ATTR_MPLS]	 = { .len = sizeof(struct ovs_key_mpls) },
 	[OVS_KEY_ATTR_CT_STATE]	 = { .len = sizeof(u8) },
 	[OVS_KEY_ATTR_CT_ZONE]	 = { .len = sizeof(u16) },
+	[OVS_KEY_ATTR_CT_MARK]	 = { .len = sizeof(u32) },
 };
 
 static bool is_all_zero(const u8 *fp, size_t size)
@@ -787,6 +789,13 @@ static int metadata_from_nlattrs(struct sw_flow_match *match,  u64 *attrs,
 		SW_FLOW_KEY_PUT(match, ct.zone, ct_zone, is_mask);
 		*attrs &= ~(1ULL << OVS_KEY_ATTR_CT_ZONE);
 	}
+	if (*attrs & (1 << OVS_KEY_ATTR_CT_MARK) &&
+	    ovs_ct_verify(OVS_KEY_ATTR_CT_MARK)) {
+		u32 mark = nla_get_u32(a[OVS_KEY_ATTR_CT_MARK]);
+
+		SW_FLOW_KEY_PUT(match, ct.mark, mark, is_mask);
+		*attrs &= ~(1ULL << OVS_KEY_ATTR_CT_MARK);
+	}
 	return 0;
 }
 
@@ -1340,6 +1349,9 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
 	if (nla_put_u16(skb, OVS_KEY_ATTR_CT_ZONE, output->ct.zone))
 		goto nla_put_failure;
 
+	if (nla_put_u32(skb, OVS_KEY_ATTR_CT_MARK, output->ct.mark))
+		goto nla_put_failure;
+
 	nla = nla_reserve(skb, OVS_KEY_ATTR_ETHERNET, sizeof(*eth_key));
 	if (!nla)
 		goto nla_put_failure;
@@ -1922,6 +1934,7 @@ static int validate_set(const struct nlattr *a,
 
 	case OVS_KEY_ATTR_PRIORITY:
 	case OVS_KEY_ATTR_SKB_MARK:
+	case OVS_KEY_ATTR_CT_MARK:
 	case OVS_KEY_ATTR_ETHERNET:
 		break;
 
-- 
2.1.4
