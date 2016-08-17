From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: [PATCH net-next V2 2/5] flow_dissector: Get vlan priority in addition to vlan id
Date: Wed, 17 Aug 2016 13:36:11 +0300
Message-ID: <1471430174-27740-3-git-send-email-hadarh@mellanox.com>
References: <1471430174-27740-1-git-send-email-hadarh@mellanox.com>
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
	Amir Vadai <amirva@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tom Herbert <tom@herbertland.com>,
	Hadar Hen Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34304 "EHLO
	mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752378AbcHQKh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 06:37:59 -0400
In-Reply-To: <1471430174-27740-1-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add vlan priority check to the flow dissector by adding new flow
dissector struct, flow_dissector_key_vlan which includes vlan tag
fields.

vlan_id and flow_label fields were under the same struct
(flow_dissector_key_tags). It was a convenient setting since struct
flow_dissector_key_tags is used by struct flow_keys and by setting
vlan_id and flow_label under the same struct, we get precisely 24 or 48
bytes in flow_keys from flow_dissector_key_basic.

Now, when adding vlan priority support, the code will be cleaner if
flow_label and vlan tag won't be under the same struct anymore.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
---
 include/linux/if_vlan.h      |  1 +
 include/net/flow_dissector.h | 12 +++++++++---
 net/core/flow_dissector.c    | 25 ++++++++++++++++---------
 3 files changed, 26 insertions(+), 12 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index a5f6ce6..49d4aef 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -81,6 +81,7 @@ static inline bool is_vlan_dev(const struct net_device *dev)
 #define skb_vlan_tag_present(__skb)	((__skb)->vlan_tci & VLAN_TAG_PRESENT)
 #define skb_vlan_tag_get(__skb)		((__skb)->vlan_tci & ~VLAN_TAG_PRESENT)
 #define skb_vlan_tag_get_id(__skb)	((__skb)->vlan_tci & VLAN_VID_MASK)
+#define skb_vlan_tag_get_prio(__skb)	((__skb)->vlan_tci & VLAN_PRIO_MASK)
 
 /**
  *	struct vlan_pcpu_stats - VLAN percpu rx/tx stats
diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index d3d60dc..f266b51 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -32,8 +32,13 @@ struct flow_dissector_key_basic {
 };
 
 struct flow_dissector_key_tags {
-	u32	vlan_id:12,
-		flow_label:20;
+	u32	flow_label;
+};
+
+struct flow_dissector_key_vlan {
+	u16	vlan_id:12,
+		vlan_priority:3;
+	u16	padding;
 };
 
 struct flow_dissector_key_keyid {
@@ -119,7 +124,7 @@ enum flow_dissector_key_id {
 	FLOW_DISSECTOR_KEY_PORTS, /* struct flow_dissector_key_ports */
 	FLOW_DISSECTOR_KEY_ETH_ADDRS, /* struct flow_dissector_key_eth_addrs */
 	FLOW_DISSECTOR_KEY_TIPC_ADDRS, /* struct flow_dissector_key_tipc_addrs */
-	FLOW_DISSECTOR_KEY_VLANID, /* struct flow_dissector_key_flow_tags */
+	FLOW_DISSECTOR_KEY_VLAN, /* struct flow_dissector_key_flow_vlan */
 	FLOW_DISSECTOR_KEY_FLOW_LABEL, /* struct flow_dissector_key_flow_tags */
 	FLOW_DISSECTOR_KEY_GRE_KEYID, /* struct flow_dissector_key_keyid */
 	FLOW_DISSECTOR_KEY_MPLS_ENTROPY, /* struct flow_dissector_key_keyid */
@@ -148,6 +153,7 @@ struct flow_keys {
 #define FLOW_KEYS_HASH_START_FIELD basic
 	struct flow_dissector_key_basic basic;
 	struct flow_dissector_key_tags tags;
+	struct flow_dissector_key_vlan vlan;
 	struct flow_dissector_key_keyid keyid;
 	struct flow_dissector_key_ports ports;
 	struct flow_dissector_key_addrs addrs;
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 362d693..a2879c0 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -118,6 +118,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 	struct flow_dissector_key_addrs *key_addrs;
 	struct flow_dissector_key_ports *key_ports;
 	struct flow_dissector_key_tags *key_tags;
+	struct flow_dissector_key_vlan *key_vlan;
 	struct flow_dissector_key_keyid *key_keyid;
 	bool skip_vlan = false;
 	u8 ip_proto = 0;
@@ -266,16 +267,22 @@ ipv6:
 
 		skip_vlan = true;
 		if (dissector_uses_key(flow_dissector,
-				       FLOW_DISSECTOR_KEY_VLANID)) {
-			key_tags = skb_flow_dissector_target(flow_dissector,
-							     FLOW_DISSECTOR_KEY_VLANID,
+				       FLOW_DISSECTOR_KEY_VLAN)) {
+			key_vlan = skb_flow_dissector_target(flow_dissector,
+							     FLOW_DISSECTOR_KEY_VLAN,
 							     target_container);
 
-			if (skb_vlan_tag_present(skb))
-				key_tags->vlan_id = skb_vlan_tag_get_id(skb);
-			else
-				key_tags->vlan_id = ntohs(vlan->h_vlan_TCI) &
+			if (skb_vlan_tag_present(skb)) {
+				key_vlan->vlan_id = skb_vlan_tag_get_id(skb);
+				key_vlan->vlan_priority =
+					(skb_vlan_tag_get_prio(skb) >> VLAN_PRIO_SHIFT);
+			} else {
+				key_vlan->vlan_id = ntohs(vlan->h_vlan_TCI) &
 					VLAN_VID_MASK;
+				key_vlan->vlan_priority =
+					(ntohs(vlan->h_vlan_TCI) &
+					 VLAN_PRIO_MASK) >> VLAN_PRIO_SHIFT;
+			}
 		}
 
 		goto again;
@@ -935,8 +942,8 @@ static const struct flow_dissector_key flow_keys_dissector_keys[] = {
 		.offset = offsetof(struct flow_keys, ports),
 	},
 	{
-		.key_id = FLOW_DISSECTOR_KEY_VLANID,
-		.offset = offsetof(struct flow_keys, tags),
+		.key_id = FLOW_DISSECTOR_KEY_VLAN,
+		.offset = offsetof(struct flow_keys, vlan),
 	},
 	{
 		.key_id = FLOW_DISSECTOR_KEY_FLOW_LABEL,
-- 
1.8.3.1
