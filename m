From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH v3 net-next 2/3] openvswitch: Use is_skb_forwardable() for length check.
Date: Tue, 29 Nov 2016 15:30:52 -0800
Message-ID: <1480462253-114713-2-git-send-email-jarno@ovn.org>
References: <1480462253-114713-1-git-send-email-jarno@ovn.org>
Cc: jarno@ovn.org, jbenc@redhat.com, pshelar@ovn.org, e@erig.me
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:49912 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754554AbcK2XbM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 18:31:12 -0500
In-Reply-To: <1480462253-114713-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use is_skb_forwardable() instead of an explicit length check.  This
gets around the apparent MTU check failure in OVS test cases when
skb->protocol is not properly set in case of non-accelerated VLAN
skbs.

Suggested-by: Pravin Shelar <pshelar@ovn.org>
Fixes: 5108bbaddc ("openvswitch: add processing of L3 packets")
Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
---
v3: New patch suggested by Pravin.

net/openvswitch/vport.c | 38 ++++++++++++++------------------------
 1 file changed, 14 insertions(+), 24 deletions(-)

diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index b6c8524..076b39f 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -464,27 +464,8 @@ int ovs_vport_receive(struct vport *vport, struct sk_buff *skb,
 	return 0;
 }
 
-static unsigned int packet_length(const struct sk_buff *skb,
-				  struct net_device *dev)
-{
-	unsigned int length = skb->len - dev->hard_header_len;
-
-	if (!skb_vlan_tag_present(skb) &&
-	    eth_type_vlan(skb->protocol))
-		length -= VLAN_HLEN;
-
-	/* Don't subtract for multiple VLAN tags. Most (all?) drivers allow
-	 * (ETH_LEN + VLAN_HLEN) in addition to the mtu value, but almost none
-	 * account for 802.1ad. e.g. is_skb_forwardable().
-	 */
-
-	return length;
-}
-
 void ovs_vport_send(struct vport *vport, struct sk_buff *skb, u8 mac_proto)
 {
-	int mtu = vport->dev->mtu;
-
 	switch (vport->dev->type) {
 	case ARPHRD_NONE:
 		if (mac_proto == MAC_PROTO_ETHERNET) {
@@ -504,11 +485,20 @@ void ovs_vport_send(struct vport *vport, struct sk_buff *skb, u8 mac_proto)
 		goto drop;
 	}
 
-	if (unlikely(packet_length(skb, vport->dev) > mtu &&
-		     !skb_is_gso(skb))) {
-		net_warn_ratelimited("%s: dropped over-mtu packet: %d > %d\n",
-				     vport->dev->name,
-				     packet_length(skb, vport->dev), mtu);
+	if (unlikely(!is_skb_forwardable(vport->dev, skb))) {
+		/* Log only if the device is up. */
+		if (vport->dev->flags & IFF_UP) {
+			unsigned int length = skb->len
+				- vport->dev->hard_header_len;
+
+			if (!skb_vlan_tag_present(skb)
+			    && eth_type_vlan(skb->protocol))
+				length -= VLAN_HLEN;
+
+			net_warn_ratelimited("%s: dropped over-mtu packet %d > %d\n",
+					     vport->dev->name, length,
+					     vport->dev->mtu);
+		}
 		vport->dev->stats.tx_errors++;
 		goto drop;
 	}
-- 
2.1.4
