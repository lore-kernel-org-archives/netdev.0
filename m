From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next V6 08/14] bridge: Implement vlan ingress/egress policy
Date: Wed, 16 Jan 2013 13:18:03 -0500
Message-ID: <1358360289-23249-9-git-send-email-vyasevic@redhat.com>
References: <1358360289-23249-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, davem@davemloft.net,
	shemminger@vyatta.com, mst@redhat.com, shmulik.ladkani@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13612 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756955Ab3APSSY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2013 13:18:24 -0500
In-Reply-To: <1358360289-23249-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements the ingress/egress policy.  At ingress,
any untagged traffic is assigned to the PVID.  Any tagged
traffic is filtered according to membership bitmap.  The vlan
is cached in the skb.

At egress, if we haven't cached the vlan (traffic arrived on vlan
unaware interface), we try to find the vlan for egress port and
cache it.  If the egress port is vlan unaware, packet is forwared
as is.

When we do have the vlan cached, we check to see the "untagged"
bitmap to see if the traffic is supposed to leave untagged.  Otherwise
the traffic will leave with the vlan tag set.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/8021q/vlan_core.c   |    1 +
 net/bridge/br_device.c  |    4 +-
 net/bridge/br_forward.c |    8 ++++
 net/bridge/br_input.c   |    8 +++-
 net/bridge/br_private.h |   34 +++++++++++----
 net/bridge/br_vlan.c    |  105 ++++++++++++++++++++++++++++++++++++++++++----
 6 files changed, 138 insertions(+), 22 deletions(-)

diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index d044dd3..99dffa6 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -144,6 +144,7 @@ err_free:
 	kfree_skb(skb);
 	return NULL;
 }
+EXPORT_SYMBOL(vlan_untag);
 
 /**
  * vlan_hw_buggy - Check to see if VLAN hw acceleration is supported.
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 0802f86..2d5b63d 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -30,6 +30,7 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct net_bridge_fdb_entry *dst;
 	struct net_bridge_mdb_entry *mdst;
 	struct br_cpu_netstats *brstats = this_cpu_ptr(br->stats);
+	u16 vid = 0;
 
 	rcu_read_lock();
 #ifdef CONFIG_BRIDGE_NETFILTER
@@ -45,7 +46,8 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	brstats->tx_bytes += skb->len;
 	u64_stats_update_end(&brstats->syncp);
 
-	if (!br_allowed_ingress(&br->vlan_info, skb))
+	memset(BR_INPUT_SKB_CB(skb), 0, sizeof(struct br_input_skb_cb));
+	if (!br_allowed_ingress(&br->vlan_info, skb, &vid))
 		goto out;
 
 	BR_INPUT_SKB_CB(skb)->brdev = dev;
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index d740b52..6dc9f39 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -64,6 +64,10 @@ int br_forward_finish(struct sk_buff *skb)
 
 static void __br_deliver(const struct net_bridge_port *to, struct sk_buff *skb)
 {
+	skb = br_handle_vlan(&to->vlan_info, skb);
+	if (!skb)
+		return;
+
 	skb->dev = to->dev;
 
 	if (unlikely(netpoll_tx_running(to->br->dev))) {
@@ -89,6 +93,10 @@ static void __br_forward(const struct net_bridge_port *to, struct sk_buff *skb)
 		return;
 	}
 
+	skb = br_handle_vlan(&to->vlan_info, skb);
+	if (!skb)
+		return;
+
 	indev = skb->dev;
 	skb->dev = to->dev;
 	skb_forward_csum(skb);
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 9a1c4e3..10f8467 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -45,6 +45,10 @@ static int br_pass_frame_up(struct sk_buff *skb)
 		return NET_RX_DROP;
 	}
 
+	skb = br_handle_vlan(&br->vlan_info, skb);
+	if (!skb)
+		return NET_RX_DROP;
+
 	indev = skb->dev;
 	skb->dev = brdev;
 
@@ -61,11 +65,13 @@ int br_handle_frame_finish(struct sk_buff *skb)
 	struct net_bridge_fdb_entry *dst;
 	struct net_bridge_mdb_entry *mdst;
 	struct sk_buff *skb2;
+	u16 vid = 0;
 
 	if (!p || p->state == BR_STATE_DISABLED)
 		goto drop;
 
-	if (!br_allowed_ingress(&p->vlan_info, skb))
+	memset(BR_INPUT_SKB_CB(skb), 0, sizeof(struct br_input_skb_cb));
+	if (!br_allowed_ingress(&p->vlan_info, skb, &vid))
 		goto drop;
 
 	/* insert into forwarding database after filtering to avoid spoofing */
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index ecf5f34..573dfab 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -76,6 +76,7 @@ struct net_bridge_vlan {
 	struct rcu_head			rcu;
 	u16				vid;
 	unsigned long			port_bitmap[PORT_BITMAP_LEN];
+	unsigned long			untagged_bitmap[PORT_BITMAP_LEN];
 };
 
 struct net_port_vlan {
@@ -318,6 +319,7 @@ static inline struct net_bridge *vlans_to_bridge(struct net_port_vlans *vlans)
 struct br_input_skb_cb {
 	struct net_device *brdev;
 	struct net_bridge_vlan *vlan;
+	int untagged;
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	int igmp;
 	int mrouters_only;
@@ -584,9 +586,12 @@ static inline bool br_multicast_is_router(struct net_bridge *br)
 
 /* br_vlan.c */
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
-extern bool br_allowed_ingress(struct net_port_vlans *v, struct sk_buff *skb);
+extern bool br_allowed_ingress(struct net_port_vlans *v, struct sk_buff *skb,
+			       u16 *vid);
 extern bool br_allowed_egress(const struct net_port_vlans *v,
 			      const struct sk_buff *skb);
+extern struct sk_buff *br_handle_vlan(const struct net_port_vlans *v,
+				      struct sk_buff *skb);
 extern struct net_bridge_vlan *br_vlan_find(struct net_bridge *br, u16 vid);
 extern void br_vlan_flush(struct net_bridge *br);
 extern int nbp_vlan_add(struct net_port_vlans *v, u16 vid, u16 flags);
@@ -595,23 +600,26 @@ extern struct net_port_vlan *nbp_vlan_find(const struct net_port_vlans *v,
 					   u16 vid);
 extern void nbp_vlan_flush(struct net_port_vlans *vlans);
 
-static inline u16 br_get_vlan(const struct sk_buff *skb)
+static inline int br_get_vlan(const struct sk_buff *skb, u16 *tag)
 {
-	u16 tag;
+	int rc = 0;
 
-	if (vlan_tx_tag_present(skb))
-		return vlan_tx_tag_get(skb) & VLAN_VID_MASK;
+	if (vlan_tx_tag_present(skb)) {
+		*tag = vlan_tx_tag_get(skb) & VLAN_VID_MASK;
+		return rc;
+	}
 
 	/* Untagged and VLAN 0 traffic is handled the same way */
-	if (vlan_get_tag(skb, &tag))
-		return 0;
+	rc = vlan_get_tag(skb, tag);
+	*tag = *tag & VLAN_VID_MASK;
 
-	return tag & VLAN_VID_MASK;
+	return rc;
 }
 
 #else
 static inline bool br_allowed_ingress(struct net_port_vlans *v,
-				      struct sk_buff *skb)
+				      struct sk_buff *skb,
+				      u16 *vid)
 {
 	return true;
 }
@@ -622,6 +630,12 @@ static inline bool br_allowed_egress(const struct net_port_vlans *v,
 	return true;
 }
 
+static inline struct sk_buff *br_handle_vlan(const struct net_port_vlans *v,
+					     struct sk_buff *skb)
+{
+	return skb;
+}
+
 static inline struct net_bridge_vlan *br_vlan_find(struct net_bridge *br,
 						   u16 vid)
 {
@@ -653,7 +667,7 @@ static inline void nbp_vlan_flush(struct net_port_vlans *vlans)
 {
 }
 
-static inline u16 br_get_vlan(const struct sk_buff *skb)
+static inline u16 br_get_vlan(const struct sk_buff *skb, u16 *tag)
 {
 	return 0;
 }
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index f6dc8a7..cbaa6b5 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -6,12 +6,9 @@
 #include "br_private.h"
 
 /* Called under RCU */
-bool br_allowed_ingress(struct net_port_vlans *v, struct sk_buff *skb)
+bool br_allowed_ingress(struct net_port_vlans *v, struct sk_buff *skb, u16 *vid)
 {
 	struct net_port_vlan *pve;
-	u16 vid;
-
-	BR_INPUT_SKB_CB(skb)->vlan = NULL;
 
 	/* If there are no vlan in the permitted list, all packets are
 	 * permitted.
@@ -19,8 +16,28 @@ bool br_allowed_ingress(struct net_port_vlans *v, struct sk_buff *skb)
 	if (list_empty(&v->vlan_list))
 		return true;
 
-	vid = br_get_vlan(skb);
-	pve = nbp_vlan_find(v, vid);
+	if (br_get_vlan(skb, vid)) {
+		struct net_bridge_vlan *pvlan = rcu_dereference(v->pvlan);
+		u16 pvid;
+
+		/* Frame did not have a tag.  See if pvid is set
+		 * on this port.  That tells us which vlan untagged
+		 * traffic belongs to.
+		 */
+		if (!pvlan || (pvid = pvlan->vid) == BR_INVALID_VID)
+			return false;
+
+		/* PVID is set on this port.  Any untagged ingress
+		 * frame is considered to belong to this vlan.
+		 */
+		__vlan_hwaccel_put_tag(skb, pvid);
+		BR_INPUT_SKB_CB(skb)->vlan = pvlan;
+		BR_INPUT_SKB_CB(skb)->untagged = 1;
+		return true;
+	}
+
+	/* Frame had a valid vlan tag.  Find the VLAN it belongs to */
+	pve = nbp_vlan_find(v, *vid);
 	if (pve) {
 		BR_INPUT_SKB_CB(skb)->vlan = rcu_dereference(pve->vlan);
 		return true;
@@ -35,7 +52,7 @@ bool br_allowed_egress(const struct net_port_vlans *v,
 {
 	struct net_port_vlan *pve;
 	struct net_bridge_vlan *vlan = NULL;
-	u16 vid;
+	u16 vid = 0;
 
 	if (list_empty(&v->vlan_list))
 		return true;
@@ -51,16 +68,84 @@ bool br_allowed_egress(const struct net_port_vlans *v,
 	}
 
 	/* We don't have cached vlan information, so we need to do
-	 * it the hard way.
+	 * it the hard way.  Cache the vlan so we can check egress
+	 * policy later.
 	 */
-	vid = br_get_vlan(skb);
+	br_get_vlan(skb, &vid);
 	pve = nbp_vlan_find(v, vid);
-	if (pve)
+	if (pve) {
+		BR_INPUT_SKB_CB(skb)->vlan = rcu_dereference(pve->vlan);
 		return true;
+	}
 
 	return false;
 }
 
+/* Almost an exact copy of vlan_untag.  Needed here since it's not exported
+ * and not available if vlan support isn't built in.
+ */
+static struct sk_buff *br_vlan_untag(struct sk_buff *skb)
+{
+	if (skb->protocol != htons(ETH_P_8021Q)) {
+		skb->vlan_tci = 0;
+		return skb;
+	}
+
+	skb->vlan_tci = 0;
+	skb = vlan_untag(skb);
+	if (skb)
+		skb->vlan_tci = 0;
+
+	return skb;
+}
+
+struct sk_buff *br_handle_vlan(const struct net_port_vlans *pv,
+			       struct sk_buff *skb)
+{
+	struct net_bridge_vlan *skb_vlan = BR_INPUT_SKB_CB(skb)->vlan;
+
+	/* If there is no vlan policy on the egress port,
+	 * leave according to ingress policy.
+	 */
+	if (list_empty(&pv->vlan_list)) {
+		if (BR_INPUT_SKB_CB(skb)->untagged)
+			skb->vlan_tci = 0;
+		goto out;
+	}
+
+	/* Egress policy is provided by the vlan bitmaps.  We
+	 * are here since we are allowed to egress according to
+	 * the vlan membership.  Now consult the untagged bitmap to
+	 * see if we should be leaving untagged.
+	 */
+	if (test_bit(pv->port_idx, skb_vlan->untagged_bitmap))
+		skb = br_vlan_untag(skb);
+	else {
+		/* Egress policy says "send tagged".  If output device is the
+		 * bridge, we need to add the VLAN header ourselves since we'll
+		 * be going through the RX path.  Sending to ports puts
+		 * the frame on the TX path and  we let dev_hard_start_xmit()
+		 * add the header.
+		 */
+		if (skb->protocol != htons(ETH_P_8021Q) &&
+		    pv->port_idx == 0) {
+			/* vlan_put_tag expects skb->data to point to mac
+			 * header.
+			 */
+			skb_push(skb, ETH_HLEN);
+			skb = __vlan_put_tag(skb, skb->vlan_tci);
+			if (!skb)
+				goto out;
+			/* put skb->data back to where it was */
+			skb_pull(skb, ETH_HLEN);
+			skb->vlan_tci = 0;
+		}
+	}
+
+out:
+	return skb;
+}
+
 static void br_vlan_destroy(struct net_bridge_vlan *vlan)
 {
 	if (!bitmap_empty(vlan->port_bitmap, PORT_BITMAP_LEN)) {
-- 
1.7.7.6
