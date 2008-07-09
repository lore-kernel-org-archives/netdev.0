From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 07/08]: vlan: clean up hard_start_xmit functions
Date: Wed,  9 Jul 2008 14:09:55 +0200 (MEST)
Message-ID: <20080709120954.11669.71101.sendpatchset@localhost.localdomain>
References: <20080709120945.11669.42790.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58631 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753951AbYGIMJ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 08:09:56 -0400
In-Reply-To: <20080709120945.11669.42790.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vlan: clean up hard_start_xmit functions

Remove excessive comments and debugging, use NETDEV_TX codes,
remove some empty lines.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit a1f83d7cbe06c3c104cfa7cf298fb0ccb26cb5a8
tree e5d55d0d2cc56417cc00788215050ae4f371cfe8
parent 731075279c2229b454f9441da2b6bc82a39cde67
author Patrick McHardy <kaber@trash.net> Wed, 09 Jul 2008 13:57:01 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 09 Jul 2008 13:57:01 +0200

 net/8021q/vlan_dev.c |   41 ++++++-----------------------------------
 1 files changed, 6 insertions(+), 35 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 8cd57c4..c5290c6 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -307,53 +307,31 @@ static int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * NOTE: THIS ASSUMES DIX ETHERNET, SPECIFICALLY NOT SUPPORTING
 	 * OTHER THINGS LIKE FDDI/TokenRing/802.3 SNAPs...
 	 */
-
 	if (veth->h_vlan_proto != htons(ETH_P_8021Q) ||
-		vlan_dev_info(dev)->flags & VLAN_FLAG_REORDER_HDR) {
-		int orig_headroom = skb_headroom(skb);
+	    vlan_dev_info(dev)->flags & VLAN_FLAG_REORDER_HDR) {
+		unsigned int orig_headroom = skb_headroom(skb);
 		u16 vlan_tci;
 
-		/* This is not a VLAN frame...but we can fix that! */
 		vlan_dev_info(dev)->cnt_encap_on_xmit++;
 
-		pr_debug("%s: proto to encap: 0x%hx\n",
-			 __func__, ntohs(veth->h_vlan_proto));
-		/* Construct the second two bytes. This field looks something
-		 * like:
-		 * usr_priority: 3 bits	 (high bits)
-		 * CFI		 1 bit
-		 * VLAN ID	 12 bits (low bits)
-		 */
 		vlan_tci = vlan_dev_info(dev)->vlan_id;
 		vlan_tci |= vlan_dev_get_egress_qos_mask(dev, skb);
-
 		skb = __vlan_put_tag(skb, vlan_tci);
 		if (!skb) {
 			stats->tx_dropped++;
-			return 0;
+			return NETDEV_TX_OK;
 		}
 
 		if (orig_headroom < VLAN_HLEN)
 			vlan_dev_info(dev)->cnt_inc_headroom_on_tx++;
 	}
 
-	pr_debug("%s: about to send skb: %p to dev: %s\n",
-		__func__, skb, skb->dev->name);
-	pr_debug("  " MAC_FMT " " MAC_FMT " %4hx %4hx %4hx\n",
-		 veth->h_dest[0], veth->h_dest[1], veth->h_dest[2],
-		 veth->h_dest[3], veth->h_dest[4], veth->h_dest[5],
-		 veth->h_source[0], veth->h_source[1], veth->h_source[2],
-		 veth->h_source[3], veth->h_source[4], veth->h_source[5],
-		 veth->h_vlan_proto, veth->h_vlan_TCI,
-		 veth->h_vlan_encapsulated_proto);
-
-	stats->tx_packets++; /* for statics only */
+	stats->tx_packets++;
 	stats->tx_bytes += skb->len;
 
 	skb->dev = vlan_dev_info(dev)->real_dev;
 	dev_queue_xmit(skb);
-
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static int vlan_dev_hwaccel_hard_start_xmit(struct sk_buff *skb,
@@ -362,12 +340,6 @@ static int vlan_dev_hwaccel_hard_start_xmit(struct sk_buff *skb,
 	struct net_device_stats *stats = &dev->stats;
 	u16 vlan_tci;
 
-	/* Construct the second two bytes. This field looks something
-	 * like:
-	 * usr_priority: 3 bits	 (high bits)
-	 * CFI		 1 bit
-	 * VLAN ID	 12 bits (low bits)
-	 */
 	vlan_tci = vlan_dev_info(dev)->vlan_id;
 	vlan_tci |= vlan_dev_get_egress_qos_mask(dev, skb);
 	skb = __vlan_hwaccel_put_tag(skb, vlan_tci);
@@ -377,8 +349,7 @@ static int vlan_dev_hwaccel_hard_start_xmit(struct sk_buff *skb,
 
 	skb->dev = vlan_dev_info(dev)->real_dev;
 	dev_queue_xmit(skb);
-
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static int vlan_dev_change_mtu(struct net_device *dev, int new_mtu)
