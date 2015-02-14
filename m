From: Joe Stringer <joestringer@nicira.com>
Subject: [RFC net-next 4/4] openvswitch: Allow matching on conntrack mark.
Date: Sat, 14 Feb 2015 00:13:53 -0800
Message-ID: <1423901633-53789-5-git-send-email-joestringer@nicira.com>
References: <1423901633-53789-1-git-send-email-joestringer@nicira.com>
Cc: Justin Pettit <jpettit@nicira.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Thomas Graf <tgraf@suug.ch>, dev@openvswitch.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aob139.obsmtp.com ([74.125.149.251]:40174 "HELO
	psmtp.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753917AbbBNIOL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Feb 2015 03:14:11 -0500
Received: by mail-ig0-f173.google.com with SMTP id a13so15157649igq.0
        for <netdev@vger.kernel.org>; Sat, 14 Feb 2015 00:14:05 -0800 (PST)
In-Reply-To: <1423901633-53789-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Justin Pettit <jpettit@nicira.com>

Allow matching and setting the conntrack mark field. As with conntrack
state and zone, these are populated by executing the conntrack() action.
Unlike these, the conntrack mark is also a writable field. The
set_field() action may be used to modify the mark, which will take
effect on the most recent conntrack entry.

E.g.: actions:conntrack(zone=0),conntrack(zone=1),set_field(1->conntrack_mark)

This will perform conntrack lookup in zone 0, then lookup in zone 1,
then modify the mark for the entry in zone 1. The mark for the entry in
zone 0 is unchanged.

Signed-off-by: Justin Pettit <jpettit@nicira.com>
Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
 include/uapi/linux/openvswitch.h |    1 +
 net/openvswitch/actions.c        |    5 ++
 net/openvswitch/conntrack.c      |   94 ++++++++++++++++++++++++++++++++++++--
 net/openvswitch/conntrack.h      |   14 ++++++
 net/openvswitch/flow.c           |    1 +
 net/openvswitch/flow.h           |    1 +
 net/openvswitch/flow_netlink.c   |   14 +++++-
 7 files changed, 126 insertions(+), 4 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 3c5cfef..de2f8a2 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -319,6 +319,7 @@ enum ovs_key_attr {
 				 * the accepted length of the array. */
 	OVS_KEY_ATTR_CONN_STATE,/* u8 of OVS_CS_F_* */
 	OVS_KEY_ATTR_CONN_ZONE, /* u16 connection tracking zone. */
+	OVS_KEY_ATTR_CONN_MARK, /* u32 connection tracking mark */
 
 #ifdef __KERNEL__
 	OVS_KEY_ATTR_TUNNEL_INFO,  /* struct ovs_tunnel_info */
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 2d801f6..9bd9f99 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -791,6 +791,11 @@ static int execute_masked_set_action(struct sk_buff *skb,
 		err = set_mpls(skb, flow_key, nla_data(a), get_mask(a,
 								    __be32 *));
 		break;
+
+	case OVS_KEY_ATTR_CONN_MARK:
+		err = ovs_ct_set_mark(skb, flow_key, nla_get_u32(a),
+				      *get_mask(a, u32 *));
+		break;
 	}
 
 	return err;
diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index a7c5203..660916d 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -106,14 +106,23 @@ u16 ovs_ct_get_zone(const struct sk_buff *skb)
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
 bool ovs_ct_state_valid(const struct sw_flow_key *key)
 {
 	return (key->phy.conn_state &&
 		key->phy.conn_state != OVS_CS_F_INVALID);
 }
 
-static int ovs_ct_lookup(struct nf_conn *tmpl, struct sw_flow_key *key,
-			 struct sk_buff *skb)
+static int ovs_ct_lookup__(struct nf_conn *tmpl, struct sw_flow_key *key,
+			   struct sk_buff *skb)
 {
 	struct net *net;
 	u16 zone = tmpl ? nf_ct_zone(tmpl) : NF_CT_DEFAULT_ZONE;
@@ -138,14 +147,37 @@ static int ovs_ct_lookup(struct nf_conn *tmpl, struct sw_flow_key *key,
 	if (skb->nfct) {
 		key->phy.conn_state = ovs_ct_get_state(skb);
 		key->phy.conn_zone = ovs_ct_get_zone(skb);
+		key->phy.conn_mark = ovs_ct_get_mark(skb);
 	} else {
 		key->phy.conn_state = OVS_CS_F_INVALID;
 		key->phy.conn_zone = zone;
+		key->phy.conn_mark = 0;
 	}
 
 	return 0;
 }
 
+static int ovs_ct_lookup(struct net *net, u16 zone, struct sw_flow_key *key,
+			 struct sk_buff *skb)
+{
+	struct nf_conntrack_tuple t;
+	struct nf_conn *tmpl = NULL;
+	int err;
+
+	if (zone != NF_CT_DEFAULT_ZONE) {
+		memset(&t, 0, sizeof(t));
+		tmpl = nf_conntrack_alloc(net, zone, &t, &t, GFP_KERNEL);
+		if (IS_ERR(tmpl))
+			return PTR_ERR(tmpl);
+	}
+
+	err = ovs_ct_lookup__(tmpl, key, skb);
+	if (tmpl)
+		nf_ct_put(tmpl);
+
+	return err;
+}
+
 int ovs_ct_execute(struct sk_buff *skb, struct sw_flow_key *key,
 		   const struct ovs_conntrack_info *info)
 {
@@ -156,7 +188,7 @@ int ovs_ct_execute(struct sk_buff *skb, struct sw_flow_key *key,
 	/* The conntrack module expects to be working at L3. */
 	skb_pull(skb, nh_ofs);
 
-	if (ovs_ct_lookup(tmpl, key, skb))
+	if (ovs_ct_lookup__(tmpl, key, skb))
 		goto err_push_skb;
 
 	if (!ovs_ct_state_valid(key))
@@ -173,6 +205,62 @@ err_push_skb:
 	return err;
 }
 
+/* If conntrack is performed on a packet which is subsequently sent to
+ * userspace, then on execute the returned packet won't have conntrack
+ * available in the skb. Initialize it if it is needed.
+ *
+ * Typically this should boil down to a no-op.
+ */
+int reinit_skb_nfct(struct sk_buff *skb, struct sw_flow_key *key)
+{
+	struct net *net;
+	int err;
+
+	if (!ovs_ct_state_valid(key))
+		return -EINVAL;
+
+	net = ovs_get_net(skb);
+	if (IS_ERR(net))
+		return PTR_ERR(net);
+
+	err = ovs_ct_lookup(net, key->phy.conn_zone, key, skb);
+	if (err)
+		return err;
+
+	return 0;
+}
+
+int ovs_ct_set_mark(struct sk_buff *skb, struct sw_flow_key *key,
+		    u32 conn_mark, u32 mask)
+{
+#ifdef CONFIG_NF_CONNTRACK_MARK
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn *ct;
+	u32 new_mark;
+	int err;
+
+	err = reinit_skb_nfct(skb, key);
+	if (err)
+		return err;
+
+	ct = nf_ct_get(skb, &ctinfo);
+	if (!ct)
+		return -EINVAL;
+
+	new_mark = ct->mark;
+	OVS_SET_MASKED(new_mark, conn_mark, mask);
+	if (ct->mark != new_mark) {
+		ct->mark = new_mark;
+		nf_conntrack_event_cache(IPCT_MARK, ct);
+		key->phy.conn_mark = conn_mark;
+	}
+
+	return 0;
+#else
+	return -ENOTSUPP;
+#endif
+}
+
 int ovs_ct_copy_action(struct net *net, const struct nlattr *attr,
 		       const struct sw_flow_key *key,
 		       struct sw_flow_actions **sfa,  bool log)
diff --git a/net/openvswitch/conntrack.h b/net/openvswitch/conntrack.h
index af7ec31..723f4a2 100644
--- a/net/openvswitch/conntrack.h
+++ b/net/openvswitch/conntrack.h
@@ -25,6 +25,9 @@ int ovs_ct_action_to_attr(const struct ovs_conntrack_info *, struct sk_buff *);
 int ovs_ct_execute(struct sk_buff *, struct sw_flow_key *,
 		   const struct ovs_conntrack_info *);
 
+int ovs_ct_set_mark(struct sk_buff *, struct sw_flow_key *, u32 conn_mark,
+		    u32 mask);
+u32 ovs_ct_get_mark(const struct sk_buff *skb);
 u8 ovs_ct_get_state(const struct sk_buff *skb);
 u16 ovs_ct_get_zone(const struct sk_buff *skb);
 bool ovs_ct_state_valid(const struct sw_flow_key *key);
@@ -61,11 +64,22 @@ static inline u16 ovs_ct_get_zone(const struct sk_buff *skb)
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
+				  u32 conn_mark, u32 mask)
+{
+	return -ENOTSUPP;
+}
+
 static inline void ovs_ct_free_acts(struct sw_flow_actions *sf_acts) { }
 #endif
 #endif /* ovs_conntrack.h */
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index c8544f5..be2cc7a 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -708,6 +708,7 @@ int ovs_flow_key_extract(const struct ovs_tunnel_info *tun_info,
 	key->phy.skb_mark = skb->mark;
 	key->phy.conn_state = ovs_ct_get_state(skb);
 	key->phy.conn_zone = ovs_ct_get_zone(skb);
+	key->phy.conn_mark = ovs_ct_get_mark(skb);
 	key->ovs_flow_hash = 0;
 	key->recirc_id = 0;
 
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index ad3779a..aa7eb1d 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -128,6 +128,7 @@ struct sw_flow_key {
 		u32	skb_mark;	/* SKB mark. */
 		u16	in_port;	/* Input switch port (or DP_MAX_PORTS). */
 		u16	conn_zone;	/* Conntrack zone. */
+		u32	conn_mark;	/* Conntrack mark. */
 		u8	conn_state;	/* Connection state. */
 	} __packed phy; /* Safe when right after 'tun_key'. */
 	u32 ovs_flow_hash;		/* Datapath computed hash value.  */
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 4c668c7..cd0d3ae 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -282,7 +282,7 @@ size_t ovs_key_attr_size(void)
 	/* Whenever adding new OVS_KEY_ FIELDS, we should consider
 	 * updating this function.
 	 */
-	BUILD_BUG_ON(OVS_KEY_ATTR_TUNNEL_INFO != 24);
+	BUILD_BUG_ON(OVS_KEY_ATTR_TUNNEL_INFO != 25);
 
 	return    nla_total_size(4)   /* OVS_KEY_ATTR_PRIORITY */
 		+ nla_total_size(0)   /* OVS_KEY_ATTR_TUNNEL */
@@ -293,6 +293,7 @@ size_t ovs_key_attr_size(void)
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_RECIRC_ID */
 		+ nla_total_size(1)   /* OVS_KEY_ATTR_CONN_STATE */
 		+ nla_total_size(2)   /* OVS_KEY_ATTR_CONN_ZONE */
+		+ nla_total_size(4)   /* OVS_KEY_ATTR_CONN_MARK */
 		+ nla_total_size(12)  /* OVS_KEY_ATTR_ETHERNET */
 		+ nla_total_size(2)   /* OVS_KEY_ATTR_ETHERTYPE */
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_VLAN */
@@ -344,6 +345,7 @@ static const struct ovs_len_tbl ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
 	[OVS_KEY_ATTR_MPLS]	 = { .len = sizeof(struct ovs_key_mpls) },
 	[OVS_KEY_ATTR_CONN_STATE] = { .len = sizeof(u8) },
 	[OVS_KEY_ATTR_CONN_ZONE] = { .len = sizeof(u16) },
+	[OVS_KEY_ATTR_CONN_MARK] = { .len = sizeof(u32) },
 };
 
 static bool is_all_zero(const u8 *fp, size_t size)
@@ -784,6 +786,12 @@ static int metadata_from_nlattrs(struct sw_flow_match *match,  u64 *attrs,
 		SW_FLOW_KEY_PUT(match, phy.conn_zone, conn_zone, is_mask);
 		*attrs &= ~(1ULL << OVS_KEY_ATTR_CONN_ZONE);
 	}
+	if (*attrs & (1ULL << OVS_KEY_ATTR_CONN_MARK)) {
+		uint32_t mark = nla_get_u32(a[OVS_KEY_ATTR_CONN_MARK]);
+
+		SW_FLOW_KEY_PUT(match, phy.conn_mark, mark, is_mask);
+		*attrs &= ~(1ULL << OVS_KEY_ATTR_CONN_MARK);
+	}
 	return 0;
 }
 
@@ -1336,6 +1344,9 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
 	if (nla_put_u16(skb, OVS_KEY_ATTR_CONN_ZONE, output->phy.conn_zone))
 		goto nla_put_failure;
 
+	if (nla_put_u32(skb, OVS_KEY_ATTR_CONN_MARK, output->phy.conn_mark))
+		goto nla_put_failure;
+
 	nla = nla_reserve(skb, OVS_KEY_ATTR_ETHERNET, sizeof(*eth_key));
 	if (!nla)
 		goto nla_put_failure;
@@ -1876,6 +1887,7 @@ static int validate_set(const struct nlattr *a,
 
 	case OVS_KEY_ATTR_PRIORITY:
 	case OVS_KEY_ATTR_SKB_MARK:
+	case OVS_KEY_ATTR_CONN_MARK:
 	case OVS_KEY_ATTR_ETHERNET:
 		break;
 
-- 
1.7.10.4
