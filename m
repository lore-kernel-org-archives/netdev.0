From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv6 net-next 06/10] openvswitch: Allow matching on conntrack mark
Date: Wed, 26 Aug 2015 11:31:49 -0700
Message-ID: <1440613913-10141-7-git-send-email-joestringer@nicira.com>
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

Allow matching and setting the ct_mark field. As with ct_state and
ct_zone, these fields are populated when the CT action is executed. To
write to this field, a value and mask can be specified as a nested
attribute under the CT action. This data is stored with the conntrack
entry, and is executed after the lookup occurs for the CT action. The
conntrack entry itself must be committed using the COMMIT flag in the CT
action flags for this change to persist.

Signed-off-by: Justin Pettit <jpettit@nicira.com>
Signed-off-by: Joe Stringer <joestringer@nicira.com>
Acked-by: Thomas Graf <tgraf@suug.ch>
Acked-by: Pravin B Shelar <pshelar@nicira.com>
---
v1-v3: No change.
v4: Only allow setting conntrack mark via ct action.
    Documentation tweaks.
v5: Rebase against conntrack zone changes.
    Add ct_mark to ct action serialization
    Replace some #ifdefs with IS_ENABLED.
v6: Add acks.
---
 include/uapi/linux/openvswitch.h |  5 +++
 net/openvswitch/actions.c        |  1 +
 net/openvswitch/conntrack.c      | 67 ++++++++++++++++++++++++++++++++++++++--
 net/openvswitch/conntrack.h      |  1 +
 net/openvswitch/flow.h           |  1 +
 net/openvswitch/flow_netlink.c   | 12 ++++++-
 6 files changed, 83 insertions(+), 4 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 55f5997..7a185b5 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -325,6 +325,7 @@ enum ovs_key_attr {
 				 * the accepted length of the array. */
 	OVS_KEY_ATTR_CT_STATE,	/* u8 bitmask of OVS_CS_F_* */
 	OVS_KEY_ATTR_CT_ZONE,	/* u16 connection tracking zone. */
+	OVS_KEY_ATTR_CT_MARK,	/* u32 connection tracking mark */
 
 #ifdef __KERNEL__
 	OVS_KEY_ATTR_TUNNEL_INFO,  /* struct ip_tunnel_info */
@@ -613,11 +614,15 @@ struct ovs_action_hash {
  * enum ovs_ct_attr - Attributes for %OVS_ACTION_ATTR_CT action.
  * @OVS_CT_ATTR_FLAGS: u32 connection tracking flags.
  * @OVS_CT_ATTR_ZONE: u16 connection tracking zone.
+ * @OVS_CT_ATTR_MARK: u32 value followed by u32 mask. For each bit set in the
+ * mask, the corresponding bit in the value is copied to the connection
+ * tracking mark field in the connection.
  */
 enum ovs_ct_attr {
 	OVS_CT_ATTR_UNSPEC,
 	OVS_CT_ATTR_FLAGS,      /* u8 bitmask of OVS_CT_F_*. */
 	OVS_CT_ATTR_ZONE,       /* u16 zone id. */
+	OVS_CT_ATTR_MARK,       /* mark to associate with this connection. */
 	__OVS_CT_ATTR_MAX
 };
 
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 72ca2c4..9741d2c 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -968,6 +968,7 @@ static int execute_masked_set_action(struct sk_buff *skb,
 
 	case OVS_KEY_ATTR_CT_STATE:
 	case OVS_KEY_ATTR_CT_ZONE:
+	case OVS_KEY_ATTR_CT_MARK:
 		err = -EINVAL;
 		break;
 	}
diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 1189fd5..e53dafc 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -28,12 +28,19 @@ struct ovs_ct_len_tbl {
 	size_t minlen;
 };
 
+/* Metadata mark for masked write to conntrack mark */
+struct md_mark {
+	u32 value;
+	u32 mask;
+};
+
 /* Conntrack action context for execution. */
 struct ovs_conntrack_info {
 	struct nf_conntrack_zone zone;
 	struct nf_conn *ct;
 	u32 flags;
 	u16 family;
+	struct md_mark mark;
 };
 
 static u16 key_to_nfproto(const struct sw_flow_key *key)
@@ -84,10 +91,12 @@ static u8 ovs_ct_get_state(enum ip_conntrack_info ctinfo)
 }
 
 static void __ovs_ct_update_key(struct sw_flow_key *key, u8 state,
-				const struct nf_conntrack_zone *zone)
+				const struct nf_conntrack_zone *zone,
+				const struct nf_conn *ct)
 {
 	key->ct.state = state;
 	key->ct.zone = zone->id;
+	key->ct.mark = ct ? ct->mark : 0;
 }
 
 /* Update 'key' based on skb->nfct. If 'post_ct' is true, then OVS has
@@ -110,7 +119,7 @@ static void ovs_ct_update_key(const struct sk_buff *skb,
 	} else if (post_ct) {
 		state = OVS_CS_F_TRACKED | OVS_CS_F_INVALID;
 	}
-	__ovs_ct_update_key(key, state, zone);
+	__ovs_ct_update_key(key, state, zone, ct);
 }
 
 void ovs_ct_fill_key(const struct sk_buff *skb, struct sw_flow_key *key)
@@ -127,6 +136,35 @@ int ovs_ct_put_key(const struct sw_flow_key *key, struct sk_buff *skb)
 	    nla_put_u16(skb, OVS_KEY_ATTR_CT_ZONE, key->ct.zone))
 		return -EMSGSIZE;
 
+	if (IS_ENABLED(CONFIG_NF_CONNTRACK_MARK) &&
+	    nla_put_u32(skb, OVS_KEY_ATTR_CT_MARK, key->ct.mark))
+		return -EMSGSIZE;
+
+	return 0;
+}
+
+static int ovs_ct_set_mark(struct sk_buff *skb, struct sw_flow_key *key,
+			   u32 ct_mark, u32 mask)
+{
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn *ct;
+	u32 new_mark;
+
+	if (!IS_ENABLED(CONFIG_NF_CONNTRACK_MARK))
+		return -ENOTSUPP;
+
+	/* The connection could be invalid, in which case set_mark is no-op. */
+	ct = nf_ct_get(skb, &ctinfo);
+	if (!ct)
+		return 0;
+
+	new_mark = ct_mark | (ct->mark & ~(mask));
+	if (ct->mark != new_mark) {
+		ct->mark = new_mark;
+		nf_conntrack_event_cache(IPCT_MARK, ct);
+		key->ct.mark = new_mark;
+	}
+
 	return 0;
 }
 
@@ -247,7 +285,7 @@ static int ovs_ct_lookup(struct net *net, struct sw_flow_key *key,
 		u8 state;
 
 		state = OVS_CS_F_TRACKED | OVS_CS_F_NEW | OVS_CS_F_RELATED;
-		__ovs_ct_update_key(key, state, &info->zone);
+		__ovs_ct_update_key(key, state, &info->zone, exp->master);
 	} else {
 		int err;
 
@@ -310,7 +348,13 @@ int ovs_ct_execute(struct net *net, struct sk_buff *skb,
 		err = ovs_ct_commit(net, key, info, skb);
 	else
 		err = ovs_ct_lookup(net, key, info, skb);
+	if (err)
+		goto err;
 
+	if (info->mark.mask)
+		err = ovs_ct_set_mark(skb, key, info->mark.value,
+				      info->mark.mask);
+err:
 	skb_push(skb, nh_ofs);
 	return err;
 }
@@ -320,6 +364,8 @@ static const struct ovs_ct_len_tbl ovs_ct_attr_lens[OVS_CT_ATTR_MAX + 1] = {
 				    .maxlen = sizeof(u32) },
 	[OVS_CT_ATTR_ZONE]	= { .minlen = sizeof(u16),
 				    .maxlen = sizeof(u16) },
+	[OVS_CT_ATTR_MARK]	= { .minlen = sizeof(struct md_mark),
+				    .maxlen = sizeof(struct md_mark) },
 };
 
 static int parse_ct(const struct nlattr *attr, struct ovs_conntrack_info *info,
@@ -355,6 +401,14 @@ static int parse_ct(const struct nlattr *attr, struct ovs_conntrack_info *info,
 			info->zone.id = nla_get_u16(a);
 			break;
 #endif
+#ifdef CONFIG_NF_CONNTRACK_MARK
+		case OVS_CT_ATTR_MARK: {
+			struct md_mark *mark = nla_data(a);
+
+			info->mark = *mark;
+			break;
+		}
+#endif
 		default:
 			OVS_NLERR(log, "Unknown conntrack attr (%d)",
 				  type);
@@ -377,6 +431,9 @@ bool ovs_ct_verify(enum ovs_key_attr attr)
 	if (IS_ENABLED(CONFIG_NF_CONNTRACK_ZONES) &&
 	    attr == OVS_KEY_ATTR_CT_ZONE)
 		return true;
+	if (IS_ENABLED(CONFIG_NF_CONNTRACK_MARK) &&
+	    attr == OVS_KEY_ATTR_CT_MARK)
+		return true;
 
 	return false;
 }
@@ -439,6 +496,10 @@ int ovs_ct_action_to_attr(const struct ovs_conntrack_info *ct_info,
 	if (IS_ENABLED(CONFIG_NF_CONNTRACK_ZONES) &&
 	    nla_put_u16(skb, OVS_CT_ATTR_ZONE, ct_info->zone.id))
 		return -EMSGSIZE;
+	if (IS_ENABLED(CONFIG_NF_CONNTRACK_MARK) &&
+	    nla_put(skb, OVS_CT_ATTR_MARK, sizeof(ct_info->mark),
+		    &ct_info->mark))
+		return -EMSGSIZE;
 
 	nla_nest_end(skb, start);
 
diff --git a/net/openvswitch/conntrack.h b/net/openvswitch/conntrack.h
index e812ee6..87b289c 100644
--- a/net/openvswitch/conntrack.h
+++ b/net/openvswitch/conntrack.h
@@ -65,6 +65,7 @@ static inline void ovs_ct_fill_key(const struct sk_buff *skb,
 {
 	key->ct.state = 0;
 	key->ct.zone = 0;
+	key->ct.mark = 0;
 }
 
 static inline int ovs_ct_put_key(const struct sw_flow_key *key,
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
index 4e795b2..b17a4ec 100644
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
 
@@ -1919,6 +1928,7 @@ static int validate_set(const struct nlattr *a,
 
 	case OVS_KEY_ATTR_PRIORITY:
 	case OVS_KEY_ATTR_SKB_MARK:
+	case OVS_KEY_ATTR_CT_MARK:
 	case OVS_KEY_ATTR_ETHERNET:
 		break;
 
-- 
2.1.4
