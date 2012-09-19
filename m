From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [RFC PATCHv2 bridge 1/7] bridge: Add vlan check to forwarding path
Date: Wed, 19 Sep 2012 08:42:10 -0400
Message-ID: <1348058536-22607-2-git-send-email-vyasevic@redhat.com>
References: <1348058536-22607-1-git-send-email-vyasevic@redhat.com>
Cc: shemminger@vyatta.com, Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7003 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756354Ab2ISMmT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2012 08:42:19 -0400
In-Reply-To: <1348058536-22607-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When forwarding packets make sure vlan matches any configured vlan for
the port.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_forward.c |   15 ++++++++++++++-
 net/bridge/br_input.c   |   12 ++++++++++++
 net/bridge/br_private.h |   17 +++++++++++++++++
 3 files changed, 43 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 02015a5..f917cb8 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -26,11 +26,24 @@ static int deliver_clone(const struct net_bridge_port *prev,
 			 void (*__packet_hook)(const struct net_bridge_port *p,
 					       struct sk_buff *skb));
 
-/* Don't forward packets to originating port or forwarding diasabled */
+/* check to see that the vlan is allowed to be forwarded on this interface */
+static inline int vlan_match(const struct net_bridge_port *p,
+			     const struct sk_buff *skb)
+{
+	unsigned long *vlan_map = rcu_dereference(p->vlan_map);
+	unsigned short vid = br_get_vlan(skb);
+
+	/* The map keeps the vlans off by 1 so adjust for that */
+	return vlan_map && test_bit(br_vid(vid), vlan_map);
+}
+
+/* Don't forward packets to originating port or forwarding diasabled.
+ */
 static inline int should_deliver(const struct net_bridge_port *p,
 				 const struct sk_buff *skb)
 {
 	return (((p->flags & BR_HAIRPIN_MODE) || skb->dev != p->dev) &&
+		vlan_match(p, skb) &&
 		p->state == BR_STATE_FORWARDING);
 }
 
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 76f15fd..44f352d 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -53,10 +53,22 @@ int br_handle_frame_finish(struct sk_buff *skb)
 	struct net_bridge_fdb_entry *dst;
 	struct net_bridge_mdb_entry *mdst;
 	struct sk_buff *skb2;
+	unsigned long *vlan_map;
+	u16 vid = 0;
 
 	if (!p || p->state == BR_STATE_DISABLED)
 		goto drop;
 
+	/* If VLAN filter is configured on the port, make sure we accept
+	 * only traffic matching the VLAN filter.
+	 */
+	vlan_map = rcu_dereference(p->vlan_map);
+	if (vlan_map) {
+		vid = br_get_vlan(skb);
+		if (!test_bit(br_vid(vid), vlan_map))
+			goto drop;
+	}
+
 	/* insert into forwarding database after filtering to avoid spoofing */
 	br = p->br;
 	br_fdb_update(br, p, eth_hdr(skb)->h_source);
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index f507d2a..baf1835 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -18,6 +18,7 @@
 #include <linux/netpoll.h>
 #include <linux/u64_stats_sync.h>
 #include <net/route.h>
+#include <linux/if_vlan.h>
 
 #define BR_HASH_BITS 8
 #define BR_HASH_SIZE (1 << BR_HASH_BITS)
@@ -152,10 +153,17 @@ struct net_bridge_port
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	struct netpoll			*np;
 #endif
+	/* VLAN map of all vlans allowed on this port.  Stored off by 1,
+	 * such at VLAN 0 (untagged) is stored in bit 1.
+	 */
+	unsigned long __rcu		*vlan_map;
 };
 
 #define br_port_exists(dev) (dev->priv_flags & IFF_BRIDGE_PORT)
 
+/* Use this macro to get the correct VLAN id */
+#define br_vid(vid)		((vid) + 1)
+
 static inline struct net_bridge_port *br_port_get_rcu(const struct net_device *dev)
 {
 	struct net_bridge_port *port = rcu_dereference(dev->rx_handler_data);
@@ -168,6 +176,15 @@ static inline struct net_bridge_port *br_port_get_rtnl(struct net_device *dev)
 		rtnl_dereference(dev->rx_handler_data) : NULL;
 }
 
+static inline u16 br_get_vlan(const struct sk_buff *skb)
+{
+	u16 uninitialized_var(tag);
+
+	if (vlan_get_tag(skb, &tag))
+		return 0;
+	return tag & VLAN_VID_MASK;
+}
+
 struct br_cpu_netstats {
 	u64			rx_packets;
 	u64			rx_bytes;
-- 
1.7.7.6
