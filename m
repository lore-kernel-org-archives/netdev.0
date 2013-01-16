From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next V6 04/14] bridge: Verify that a vlan is allowed to egress on give port
Date: Wed, 16 Jan 2013 13:17:59 -0500
Message-ID: <1358360289-23249-5-git-send-email-vyasevic@redhat.com>
References: <1358360289-23249-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, davem@davemloft.net,
	shemminger@vyatta.com, mst@redhat.com, shmulik.ladkani@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44984 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756672Ab3APSSS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2013 13:18:18 -0500
In-Reply-To: <1358360289-23249-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When bridge forwards a frame, make sure that a frame is allowed
to egress on that port.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_forward.c |    1 +
 net/bridge/br_input.c   |   10 ++++++++++
 net/bridge/br_private.h |    9 +++++++++
 net/bridge/br_vlan.c    |   18 ++++++++++++++++++
 4 files changed, 38 insertions(+), 0 deletions(-)

diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 02015a5..d740b52 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -31,6 +31,7 @@ static inline int should_deliver(const struct net_bridge_port *p,
 				 const struct sk_buff *skb)
 {
 	return (((p->flags & BR_HAIRPIN_MODE) || skb->dev != p->dev) &&
+		br_allowed_egress(&p->vlan_info, skb) &&
 		p->state == BR_STATE_FORWARDING);
 }
 
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index cc959fa..9a1c4e3 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -35,6 +35,16 @@ static int br_pass_frame_up(struct sk_buff *skb)
 	brstats->rx_bytes += skb->len;
 	u64_stats_update_end(&brstats->syncp);
 
+	/* Bridge is just like any other port.  Make sure the
+	 * packet is allowed except in promisc modue when someone
+	 * may be running packet capture.
+	 */
+	if (!(brdev->flags & IFF_PROMISC) &&
+	    !br_allowed_egress(&br->vlan_info, skb)) {
+		kfree_skb(skb);
+		return NET_RX_DROP;
+	}
+
 	indev = skb->dev;
 	skb->dev = brdev;
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 7018546..39e70af 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -583,6 +583,8 @@ static inline bool br_multicast_is_router(struct net_bridge *br)
 /* br_vlan.c */
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
 extern bool br_allowed_ingress(struct net_port_vlans *v, struct sk_buff *skb);
+extern bool br_allowed_egress(const struct net_port_vlans *v,
+			      const struct sk_buff *skb);
 extern struct net_bridge_vlan *br_vlan_find(struct net_bridge *br, u16 vid);
 extern void br_vlan_flush(struct net_bridge *br);
 extern int nbp_vlan_add(struct net_port_vlans *v, u16 vid);
@@ -598,6 +600,7 @@ static inline u16 br_get_vlan(const struct sk_buff *skb)
 	if (vlan_tx_tag_present(skb))
 		return vlan_tx_tag_get(skb) & VLAN_VID_MASK;
 
+	/* Untagged and VLAN 0 traffic is handled the same way */
 	if (vlan_get_tag(skb, &tag))
 		return 0;
 
@@ -611,6 +614,12 @@ static inline bool br_allowed_ingress(struct net_port_vlans *v,
 	return true;
 }
 
+static inline bool br_allowed_egress(const struct net_port_vlans *v,
+				     const struct sk_buff *skb)
+{
+	return true;
+}
+
 static inline struct net_bridge_vlan *br_vlan_find(struct net_bridge *br,
 						   u16 vid)
 {
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 72b4892..a4f7c15 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -25,6 +25,24 @@ bool br_allowed_ingress(struct net_port_vlans *v, struct sk_buff *skb)
 	return false;
 }
 
+/* Called under RCU. */
+bool br_allowed_egress(const struct net_port_vlans *v,
+		       const struct sk_buff *skb)
+{
+	struct net_port_vlan *pve;
+	u16 vid;
+
+	if (list_empty(&v->vlan_list))
+		return true;
+
+	vid = br_get_vlan(skb);
+	pve = nbp_vlan_find(v, vid);
+	if (pve)
+		return true;
+
+	return false;
+}
+
 static void br_vlan_destroy(struct net_bridge_vlan *vlan)
 {
 	if (!bitmap_empty(vlan->port_bitmap, PORT_BITMAP_LEN)) {
-- 
1.7.7.6
