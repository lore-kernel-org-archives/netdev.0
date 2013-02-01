From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH v9 net-next 03/12] bridge: Verify that a vlan is allowed to egress on give port
Date: Fri,  1 Feb 2013 15:02:01 -0500
Message-ID: <1359748930-31475-4-git-send-email-vyasevic@redhat.com>
References: <1359748930-31475-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55738 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757578Ab3BAVQC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2013 16:16:02 -0500
In-Reply-To: <1359748930-31475-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When bridge forwards a frame, make sure that a frame is allowed
to egress on that port.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_forward.c |    1 +
 net/bridge/br_input.c   |   10 ++++++++++
 net/bridge/br_private.h |   10 ++++++++++
 net/bridge/br_vlan.c    |   20 ++++++++++++++++++++
 4 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 02015a5..35b0671 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -31,6 +31,7 @@ static inline int should_deliver(const struct net_bridge_port *p,
 				 const struct sk_buff *skb)
 {
 	return (((p->flags & BR_HAIRPIN_MODE) || skb->dev != p->dev) &&
+		br_allowed_egress(p->br, nbp_get_vlan_info(p), skb) &&
 		p->state == BR_STATE_FORWARDING);
 }
 
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 4ef3f6b..787d7da 100644
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
+	    !br_allowed_egress(br, br_get_vlan_info(br), skb)) {
+		kfree_skb(skb);
+		return NET_RX_DROP;
+	}
+
 	indev = skb->dev;
 	skb->dev = brdev;
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 6db6822..5e7bc90 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -553,6 +553,9 @@ static inline void br_mdb_uninit(void)
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
 extern bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
 			       struct sk_buff *skb);
+extern bool br_allowed_egress(struct net_bridge *br,
+			      const struct net_port_vlans *v,
+			      const struct sk_buff *skb);
 extern int br_vlan_add(struct net_bridge *br, u16 vid);
 extern int br_vlan_delete(struct net_bridge *br, u16 vid);
 extern void br_vlan_flush(struct net_bridge *br);
@@ -592,6 +595,13 @@ static inline bool br_allowed_ingress(struct net_bridge *br,
 	return true;
 }
 
+static inline bool br_allowed_egress(struct net_bridge *br,
+				     const struct net_port_vlans *v,
+				     const struct sk_buff *skb)
+{
+	return true;
+}
+
 static inline int br_vlan_add(struct net_bridge *br, u16 vid)
 {
 	return -EOPNOTSUPP;
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index c3ae3f9..a291bca 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -113,6 +113,26 @@ bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
 	return false;
 }
 
+/* Called under RCU. */
+bool br_allowed_egress(struct net_bridge *br,
+		       const struct net_port_vlans *v,
+		       const struct sk_buff *skb)
+{
+	u16 vid;
+
+	if (!br->vlan_enabled)
+		return true;
+
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
