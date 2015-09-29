From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCH net 6/7] openvswitch: Extend ct_state match field to 32 bits
Date: Tue, 29 Sep 2015 15:39:39 -0700
Message-ID: <1443566380-22640-7-git-send-email-joestringer@nicira.com>
References: <1443566380-22640-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443566380-22640-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ct_state field was initially added as an 8-bit field, however six of
the bits are already being used and use cases are already starting to
appear that may push the limits of this field. This patch extends the
field to 32 bits while retaining the internal representation of 8 bits.
This should cover forward compatibility of the ABI for the foreseeable
future.

This patch also reorders the OVS_CS_F_* bits to be sequential.

Suggested-by: Jarno Rajahalme <jrajahalme@nicira.com>
Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
 include/uapi/linux/openvswitch.h | 8 ++++----
 net/openvswitch/conntrack.c      | 2 +-
 net/openvswitch/conntrack.h      | 4 ++--
 net/openvswitch/flow_netlink.c   | 8 ++++----
 4 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 7cbb9d5..f121af5 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -323,7 +323,7 @@ enum ovs_key_attr {
 	OVS_KEY_ATTR_MPLS,      /* array of struct ovs_key_mpls.
 				 * The implementation may restrict
 				 * the accepted length of the array. */
-	OVS_KEY_ATTR_CT_STATE,	/* u8 bitmask of OVS_CS_F_* */
+	OVS_KEY_ATTR_CT_STATE,	/* u32 bitmask of OVS_CS_F_* */
 	OVS_KEY_ATTR_CT_ZONE,	/* u16 connection tracking zone. */
 	OVS_KEY_ATTR_CT_MARK,	/* u32 connection tracking mark */
 	OVS_KEY_ATTR_CT_LABELS,	/* 16-octet connection tracking label */
@@ -449,9 +449,9 @@ struct ovs_key_ct_label {
 #define OVS_CS_F_ESTABLISHED       0x02 /* Part of an existing connection. */
 #define OVS_CS_F_RELATED           0x04 /* Related to an established
 					 * connection. */
-#define OVS_CS_F_INVALID           0x20 /* Could not track connection. */
-#define OVS_CS_F_REPLY_DIR         0x40 /* Flow is in the reply direction. */
-#define OVS_CS_F_TRACKED           0x80 /* Conntrack has occurred. */
+#define OVS_CS_F_REPLY_DIR         0x08 /* Flow is in the reply direction. */
+#define OVS_CS_F_INVALID           0x10 /* Could not track connection. */
+#define OVS_CS_F_TRACKED           0x20 /* Conntrack has occurred. */
 
 /**
  * enum ovs_flow_attr - attributes for %OVS_FLOW_* commands.
diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 8c5d482c..167cf43 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -167,7 +167,7 @@ void ovs_ct_fill_key(const struct sk_buff *skb, struct sw_flow_key *key)
 
 int ovs_ct_put_key(const struct sw_flow_key *key, struct sk_buff *skb)
 {
-	if (nla_put_u8(skb, OVS_KEY_ATTR_CT_STATE, key->ct.state))
+	if (nla_put_u32(skb, OVS_KEY_ATTR_CT_STATE, key->ct.state))
 		return -EMSGSIZE;
 
 	if (IS_ENABLED(CONFIG_NF_CONNTRACK_ZONES) &&
diff --git a/net/openvswitch/conntrack.h b/net/openvswitch/conntrack.h
index c658d95..7a125422 100644
--- a/net/openvswitch/conntrack.h
+++ b/net/openvswitch/conntrack.h
@@ -35,7 +35,7 @@ void ovs_ct_fill_key(const struct sk_buff *skb, struct sw_flow_key *key);
 int ovs_ct_put_key(const struct sw_flow_key *key, struct sk_buff *skb);
 void ovs_ct_free_action(const struct nlattr *a);
 
-static inline bool ovs_ct_state_supported(u8 state)
+static inline bool ovs_ct_state_supported(u32 state)
 {
 	return !(state & ~(OVS_CS_F_NEW | OVS_CS_F_ESTABLISHED |
 			 OVS_CS_F_RELATED | OVS_CS_F_REPLY_DIR |
@@ -53,7 +53,7 @@ static inline bool ovs_ct_verify(struct net *net, int attr)
 	return false;
 }
 
-static inline bool ovs_ct_state_supported(u8 state)
+static inline bool ovs_ct_state_supported(u32 state)
 {
 	return false;
 }
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index c4917c9..292eb13 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -291,7 +291,7 @@ size_t ovs_key_attr_size(void)
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_SKB_MARK */
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_DP_HASH */
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_RECIRC_ID */
-		+ nla_total_size(1)   /* OVS_KEY_ATTR_CT_STATE */
+		+ nla_total_size(4)   /* OVS_KEY_ATTR_CT_STATE */
 		+ nla_total_size(2)   /* OVS_KEY_ATTR_CT_ZONE */
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_CT_MARK */
 		+ nla_total_size(16)  /* OVS_KEY_ATTR_CT_LABELS */
@@ -349,7 +349,7 @@ static const struct ovs_len_tbl ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
 	[OVS_KEY_ATTR_TUNNEL]	 = { .len = OVS_ATTR_NESTED,
 				     .next = ovs_tunnel_key_lens, },
 	[OVS_KEY_ATTR_MPLS]	 = { .len = sizeof(struct ovs_key_mpls) },
-	[OVS_KEY_ATTR_CT_STATE]	 = { .len = sizeof(u8) },
+	[OVS_KEY_ATTR_CT_STATE]	 = { .len = sizeof(u32) },
 	[OVS_KEY_ATTR_CT_ZONE]	 = { .len = sizeof(u16) },
 	[OVS_KEY_ATTR_CT_MARK]	 = { .len = sizeof(u32) },
 	[OVS_KEY_ATTR_CT_LABELS] = { .len = sizeof(struct ovs_key_ct_label) },
@@ -814,10 +814,10 @@ static int metadata_from_nlattrs(struct net *net, struct sw_flow_match *match,
 
 	if (*attrs & (1 << OVS_KEY_ATTR_CT_STATE) &&
 	    ovs_ct_verify(net, OVS_KEY_ATTR_CT_STATE)) {
-		u8 ct_state = nla_get_u8(a[OVS_KEY_ATTR_CT_STATE]);
+		u32 ct_state = nla_get_u32(a[OVS_KEY_ATTR_CT_STATE]);
 
 		if (!is_mask && !ovs_ct_state_supported(ct_state)) {
-			OVS_NLERR(log, "ct_state flags %02x unsupported",
+			OVS_NLERR(log, "ct_state flags %08x unsupported",
 				  ct_state);
 			return -EINVAL;
 		}
-- 
2.1.4
