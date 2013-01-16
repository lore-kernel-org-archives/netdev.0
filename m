From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next V6 03/14] bridge: Validate that vlan is permitted on ingress
Date: Wed, 16 Jan 2013 13:17:58 -0500
Message-ID: <1358360289-23249-4-git-send-email-vyasevic@redhat.com>
References: <1358360289-23249-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, davem@davemloft.net,
	shemminger@vyatta.com, mst@redhat.com, shmulik.ladkani@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43203 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756238Ab3APSSR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2013 13:18:17 -0500
In-Reply-To: <1358360289-23249-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a frame arrives on a port or transmitted by the bridge,
if we have VLANs configured, validate that a given VLAN is allowed
to enter the bridge.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_device.c  |    3 +++
 net/bridge/br_input.c   |    4 ++++
 net/bridge/br_private.h |   25 +++++++++++++++++++++++++
 net/bridge/br_vlan.c    |   20 ++++++++++++++++++++
 4 files changed, 52 insertions(+), 0 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index b64b5c8..6b8f816 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -45,6 +45,9 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	brstats->tx_bytes += skb->len;
 	u64_stats_update_end(&brstats->syncp);
 
+	if (!br_allowed_ingress(&br->vlan_info, skb))
+		goto out;
+
 	BR_INPUT_SKB_CB(skb)->brdev = dev;
 
 	skb_reset_mac_header(skb);
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 4b34207..cc959fa 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -17,6 +17,7 @@
 #include <linux/etherdevice.h>
 #include <linux/netfilter_bridge.h>
 #include <linux/export.h>
+#include <linux/rculist.h>
 #include "br_private.h"
 
 /* Hook for brouter */
@@ -54,6 +55,9 @@ int br_handle_frame_finish(struct sk_buff *skb)
 	if (!p || p->state == BR_STATE_DISABLED)
 		goto drop;
 
+	if (!br_allowed_ingress(&p->vlan_info, skb))
+		goto drop;
+
 	/* insert into forwarding database after filtering to avoid spoofing */
 	br = p->br;
 	br_fdb_update(br, p, eth_hdr(skb)->h_source);
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 615f10c..7018546 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -582,6 +582,7 @@ static inline bool br_multicast_is_router(struct net_bridge *br)
 
 /* br_vlan.c */
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
+extern bool br_allowed_ingress(struct net_port_vlans *v, struct sk_buff *skb);
 extern struct net_bridge_vlan *br_vlan_find(struct net_bridge *br, u16 vid);
 extern void br_vlan_flush(struct net_bridge *br);
 extern int nbp_vlan_add(struct net_port_vlans *v, u16 vid);
@@ -589,7 +590,27 @@ extern int nbp_vlan_delete(struct net_port_vlans *v, u16 vid);
 extern struct net_port_vlan *nbp_vlan_find(const struct net_port_vlans *v,
 					   u16 vid);
 extern void nbp_vlan_flush(struct net_port_vlans *vlans);
+
+static inline u16 br_get_vlan(const struct sk_buff *skb)
+{
+	u16 tag;
+
+	if (vlan_tx_tag_present(skb))
+		return vlan_tx_tag_get(skb) & VLAN_VID_MASK;
+
+	if (vlan_get_tag(skb, &tag))
+		return 0;
+
+	return tag & VLAN_VID_MASK;
+}
+
 #else
+static inline bool br_allowed_ingress(struct net_port_vlans *v,
+				      struct sk_buff *skb)
+{
+	return true;
+}
+
 static inline struct net_bridge_vlan *br_vlan_find(struct net_bridge *br,
 						   u16 vid)
 {
@@ -621,6 +642,10 @@ static inline void nbp_vlan_flush(struct net_port_vlans *vlans)
 {
 }
 
+static inline u16 br_get_vlan(const struct sk_buff *skb)
+{
+	return 0;
+}
 #endif
 
 /* br_netfilter.c */
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 816e85e..72b4892 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -5,6 +5,26 @@
 
 #include "br_private.h"
 
+/* Called under RCU */
+bool br_allowed_ingress(struct net_port_vlans *v, struct sk_buff *skb)
+{
+	struct net_port_vlan *pve;
+	u16 vid;
+
+	/* If there are no vlan in the permitted list, all packets are
+	 * permitted.
+	 */
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
