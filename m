From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next v5 04/14] bridge: Verify that a vlan is allowed to egress on give port
Date: Wed,  9 Jan 2013 12:17:51 -0500
Message-ID: <1357751882-8619-5-git-send-email-vyasevic@redhat.com>
References: <1357751882-8619-1-git-send-email-vyasevic@redhat.com>
Cc: davem@davemloft.net, stephen@redhat.com,
	bridge@lists.linux-foundation.org, shmulik.ladkani@gmail.com,
	mst@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30897 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932208Ab3AIRSM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2013 12:18:12 -0500
In-Reply-To: <1357751882-8619-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When bridge forwards a frame, make sure that a frame is allowed
to egress on that port.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_forward.c |   18 ++++++++++++++++++
 net/bridge/br_input.c   |   10 ++++++++++
 net/bridge/br_private.h |    3 +++
 3 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 02015a5..3e9a705 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -26,11 +26,29 @@ static int deliver_clone(const struct net_bridge_port *prev,
 			 void (*__packet_hook)(const struct net_bridge_port *p,
 					       struct sk_buff *skb));
 
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
 /* Don't forward packets to originating port or forwarding diasabled */
 static inline int should_deliver(const struct net_bridge_port *p,
 				 const struct sk_buff *skb)
 {
 	return (((p->flags & BR_HAIRPIN_MODE) || skb->dev != p->dev) &&
+		br_allowed_egress(&p->vlan_info, skb) &&
 		p->state == BR_STATE_FORWARDING);
 }
 
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 306841d..72a333c 100644
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
index 514538d..cf5982e 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -219,6 +219,7 @@ static inline u16 br_get_vlan(const struct sk_buff *skb)
 	if (vlan_tx_tag_present(skb))
 		return vlan_tx_tag_get(skb) & VLAN_VID_MASK;
 
+	/* Untagged and VLAN 0 traffic is handled the same way */
 	if (vlan_get_tag(skb, &tag))
 		return 0;
 
@@ -453,6 +454,8 @@ extern int br_forward_finish(struct sk_buff *skb);
 extern void br_flood_deliver(struct net_bridge *br, struct sk_buff *skb);
 extern void br_flood_forward(struct net_bridge *br, struct sk_buff *skb,
 			     struct sk_buff *skb2);
+extern bool br_allowed_egress(const struct net_port_vlans *v,
+			      const struct sk_buff *skb);
 
 /* br_if.c */
 extern void br_port_carrier_check(struct net_bridge_port *p);
-- 
1.7.7.6
