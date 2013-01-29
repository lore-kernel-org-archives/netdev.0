From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH 03/13] bridge: Validate that vlan is permitted on ingress
Date: Tue, 29 Jan 2013 14:52:50 -0500
Message-ID: <1359489180-10012-4-git-send-email-vyasevic@redhat.com>
References: <1359489180-10012-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, davem@davemloft.net,
	netdev@vger.kernel.org, shmulik.ladkani@gmail.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25219 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752475Ab3A2TxI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2013 14:53:08 -0500
In-Reply-To: <1359489180-10012-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a frame arrives on a port or transmitted by the bridge,
if we have VLANs configured, validate that a given VLAN is allowed
to enter the bridge.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_device.c  |    3 +++
 net/bridge/br_input.c   |    4 ++++
 net/bridge/br_private.h |   44 ++++++++++++++++++++++++++++++++++++++++++++
 net/bridge/br_vlan.c    |   25 +++++++++++++++++++++++++
 4 files changed, 76 insertions(+), 0 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index e1bc090..92b5b18 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -45,6 +45,9 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	brstats->tx_bytes += skb->len;
 	u64_stats_update_end(&brstats->syncp);
 
+	if (!br_allowed_ingress(br, br_get_vlan_info(br), skb))
+		goto out;
+
 	BR_INPUT_SKB_CB(skb)->brdev = dev;
 
 	skb_reset_mac_header(skb);
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 4b34207..4ef3f6b 100644
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
 
+	if (!br_allowed_ingress(p->br, nbp_get_vlan_info(p), skb))
+		goto drop;
+
 	/* insert into forwarding database after filtering to avoid spoofing */
 	br = p->br;
 	br_fdb_update(br, p, eth_hdr(skb)->h_source);
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 1c1b2f1..be9ba73 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -551,6 +551,8 @@ static inline void br_mdb_uninit(void)
 
 /* br_vlan.c */
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
+extern bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
+			       struct sk_buff *skb);
 extern int br_vlan_add(struct net_bridge *br, u16 vid);
 extern int br_vlan_delete(struct net_bridge *br, u16 vid);
 extern void br_vlan_flush(struct net_bridge *br);
@@ -558,7 +560,36 @@ extern int br_vlan_filter_toggle(struct net_bridge *br, unsigned long val);
 extern int nbp_vlan_add(struct net_bridge_port *port, u16 vid);
 extern int nbp_vlan_delete(struct net_bridge_port *port, u16 vid);
 extern void nbp_vlan_flush(struct net_bridge_port *port);
+
+static inline struct net_port_vlans *br_get_vlan_info(struct net_bridge *br)
+{
+	return rcu_dereference(br->vlan_info);
+}
+
+static inline struct net_port_vlans *nbp_get_vlan_info(struct net_bridge_port *p)
+{
+	return rcu_dereference(p->vlan_info);
+}
+
+static inline u16 br_vlan_get_tag(const struct sk_buff *skb)
+{
+	u16 tag;
+
+	if (vlan_tx_tag_present(skb))
+		tag = vlan_tx_tag_get(skb);
+	else if (vlan_get_tag(skb, &tag))
+		tag = 0;
+
+	return tag & VLAN_VID_MASK;
+}
 #else
+static inline bool br_allowed_ingress(struct net_bridge *br,
+				      struct net_port_vlans *v,
+				      struct sk_buff *skb)
+{
+	return true;
+}
+
 static inline int br_vlan_add(struct net_bridge *br, u16 vid)
 {
 	return -EOPNOTSUPP;
@@ -587,6 +618,19 @@ static inline void nbp_vlan_flush(struct net_bridge_port *port)
 {
 }
 
+static inline struct net_port_vlans *br_get_vlan_info(struct net_bridge *br)
+{
+	return NULL;
+}
+static inline struct net_port_vlans *nbp_get_vlan_info(struct net_bridge_port *p)
+{
+	return NULL;
+}
+
+static inline u16 br_vlan_get_tag(const struct sk_buff *skb)
+{
+	return 0;
+}
 #endif
 
 /* br_netfilter.c */
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 1c7ae56..d8174e3 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -97,6 +97,31 @@ static void __vlan_flush(struct net_port_vlans *v)
 	kfree_rcu(v, rcu);
 }
 
+/* Called under RCU */
+bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
+			struct sk_buff *skb)
+{
+	u16 vid;
+
+	/* If VLAN filtering is disabled on the bridge, all packets are
+	 * permitted.
+	 */
+	if (!br->vlan_enabled)
+		return true;
+
+	/* If there are no vlan in the permitted list, all packets are
+	 * rejected.
+	 */
+	if (!v)
+		return false;
+
+	vid = br_vlan_get_tag(skb);
+	if (test_bit(vid, v->vlan_bitmap))
+		return true;
+
+	return false;
+}
+
 /* Must be protected by RTNL */
 int br_vlan_add(struct net_bridge *br, u16 vid)
 {
-- 
1.7.7.6
