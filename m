From: Eric Garver <e@erig.me>
Subject: [PATCH net-next v22 2/3] vlan: Check for vlan ethernet types for 8021.q or 802.1ad
Date: Wed,  7 Sep 2016 12:56:58 -0400
Message-ID: <1473267419-6825-3-git-send-email-e@erig.me>
References: <1473267419-6825-1-git-send-email-e@erig.me>
Cc: dev@openvswitch.org, Thomas F Herbert <thomasfherbert@gmail.com>,
        Xiao Liang <shaw.leon@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45548 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933159AbcIGQ5C (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Sep 2016 12:57:02 -0400
In-Reply-To: <1473267419-6825-1-git-send-email-e@erig.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is to simplify using double tagged vlans. This function allows all
valid vlan ethertypes to be checked in a single function call.
Also replace some instances that check for both ETH_P_8021Q and
ETH_P_8021AD.

Patch based on one originally by Thomas F Herbert.

Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>
Signed-off-by: Eric Garver <e@erig.me>
---
 include/linux/if_vlan.h | 33 +++++++++++++++++++++++----------
 1 file changed, 23 insertions(+), 10 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 49d4aef1f789..3319d97d789d 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -272,6 +272,23 @@ static inline int vlan_get_encap_level(struct net_device *dev)
 }
 #endif
 
+/**
+ * eth_type_vlan - check for valid vlan ether type.
+ * @ethertype: ether type to check
+ *
+ * Returns true if the ether type is a vlan ether type.
+ */
+static inline bool eth_type_vlan(__be16 ethertype)
+{
+	switch (ethertype) {
+	case htons(ETH_P_8021Q):
+	case htons(ETH_P_8021AD):
+		return true;
+	default:
+		return false;
+	}
+}
+
 static inline bool vlan_hw_offload_capable(netdev_features_t features,
 					   __be16 proto)
 {
@@ -425,8 +442,7 @@ static inline int __vlan_get_tag(const struct sk_buff *skb, u16 *vlan_tci)
 {
 	struct vlan_ethhdr *veth = (struct vlan_ethhdr *)skb->data;
 
-	if (veth->h_vlan_proto != htons(ETH_P_8021Q) &&
-	    veth->h_vlan_proto != htons(ETH_P_8021AD))
+	if (!eth_type_vlan(veth->h_vlan_proto))
 		return -EINVAL;
 
 	*vlan_tci = ntohs(veth->h_vlan_TCI);
@@ -488,7 +504,7 @@ static inline __be16 __vlan_get_protocol(struct sk_buff *skb, __be16 type,
 	 * present at mac_len - VLAN_HLEN (if mac_len > 0), or at
 	 * ETH_HLEN otherwise
 	 */
-	if (type == htons(ETH_P_8021Q) || type == htons(ETH_P_8021AD)) {
+	if (eth_type_vlan(type)) {
 		if (vlan_depth) {
 			if (WARN_ON(vlan_depth < VLAN_HLEN))
 				return 0;
@@ -506,8 +522,7 @@ static inline __be16 __vlan_get_protocol(struct sk_buff *skb, __be16 type,
 			vh = (struct vlan_hdr *)(skb->data + vlan_depth);
 			type = vh->h_vlan_encapsulated_proto;
 			vlan_depth += VLAN_HLEN;
-		} while (type == htons(ETH_P_8021Q) ||
-			 type == htons(ETH_P_8021AD));
+		} while (eth_type_vlan(type));
 	}
 
 	if (depth)
@@ -572,8 +587,7 @@ static inline void vlan_set_encap_proto(struct sk_buff *skb,
 static inline bool skb_vlan_tagged(const struct sk_buff *skb)
 {
 	if (!skb_vlan_tag_present(skb) &&
-	    likely(skb->protocol != htons(ETH_P_8021Q) &&
-		   skb->protocol != htons(ETH_P_8021AD)))
+	    likely(!eth_type_vlan(skb->protocol)))
 		return false;
 
 	return true;
@@ -593,15 +607,14 @@ static inline bool skb_vlan_tagged_multi(const struct sk_buff *skb)
 	if (!skb_vlan_tag_present(skb)) {
 		struct vlan_ethhdr *veh;
 
-		if (likely(protocol != htons(ETH_P_8021Q) &&
-			   protocol != htons(ETH_P_8021AD)))
+		if (likely(!eth_type_vlan(protocol)))
 			return false;
 
 		veh = (struct vlan_ethhdr *)skb->data;
 		protocol = veh->h_vlan_encapsulated_proto;
 	}
 
-	if (protocol != htons(ETH_P_8021Q) && protocol != htons(ETH_P_8021AD))
+	if (!eth_type_vlan(protocol))
 		return false;
 
 	return true;
-- 
2.5.5
