From: Joonwoo Park <joonwpark81@gmail.com>
Subject: [PATCH 1/5] [VLAN]: Unclassified vlan packet
Date: Fri, 11 Apr 2008 22:57:14 +0900
Message-ID: <20080411135714.GA8137@tp64>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.174]:3081 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758793AbYDKN50 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 09:57:26 -0400
Received: by wf-out-1314.google.com with SMTP id 28so498992wff.4
        for <netdev@vger.kernel.org>; Fri, 11 Apr 2008 06:57:26 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To be polite to the PACKET,
Don't kill the unclassified & hardware accelerated vlan packets if netdev
is in promiscuous, set packet type with PACKET_OTHERHOST. 
Put the vlan tag into skb->cb for all hardware accelerated vlan packets.

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
 include/linux/if_vlan.h |   56 +++++++++++++++++++++++++++++-----------------
 1 files changed, 35 insertions(+), 21 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 79504b2..e400141 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -62,6 +62,9 @@ struct vlan_ethhdr {
 
 #include <linux/skbuff.h>
 
+static inline struct sk_buff *__vlan_hwaccel_put_tag(struct sk_buff *skb,
+						     unsigned short tag);
+
 static inline struct vlan_ethhdr *vlan_eth_hdr(const struct sk_buff *skb)
 {
 	return (struct vlan_ethhdr *)skb_mac_header(skb);
@@ -175,14 +178,19 @@ static inline int __vlan_hwaccel_rx(struct sk_buff *skb,
 				    unsigned short vlan_tag, int polling)
 {
 	struct net_device_stats *stats;
+	struct net_device *vlan_dev;
 
 	if (skb_bond_should_drop(skb)) {
 		dev_kfree_skb_any(skb);
 		return NET_RX_DROP;
 	}
 
-	skb->dev = vlan_group_get_device(grp, vlan_tag & VLAN_VID_MASK);
-	if (skb->dev == NULL) {
+	vlan_dev = vlan_group_get_device(grp, vlan_tag & VLAN_VID_MASK);
+	if (vlan_dev)
+		skb->dev = vlan_dev;
+	else if (skb->dev->flags & IFF_PROMISC)
+		skb->pkt_type = PACKET_OTHERHOST;
+	else {
 		dev_kfree_skb_any(skb);
 
 		/* Not NET_RX_DROP, this is not being dropped
@@ -191,31 +199,37 @@ static inline int __vlan_hwaccel_rx(struct sk_buff *skb,
 		return 0;
 	}
 
+	/* Deliever vlan_tag to PACKET */
+	__vlan_hwaccel_put_tag(skb, vlan_tag);
+
 	skb->dev->last_rx = jiffies;
 
 	stats = &skb->dev->stats;
 	stats->rx_packets++;
 	stats->rx_bytes += skb->len;
 
-	skb->priority = vlan_get_ingress_priority(skb->dev, vlan_tag);
-	switch (skb->pkt_type) {
-	case PACKET_BROADCAST:
-		break;
-
-	case PACKET_MULTICAST:
-		stats->multicast++;
-		break;
-
-	case PACKET_OTHERHOST:
-		/* Our lower layer thinks this is not local, let's make sure.
-		 * This allows the VLAN to have a different MAC than the underlying
-		 * device, and still route correctly.
-		 */
-		if (!compare_ether_addr(eth_hdr(skb)->h_dest,
-				       	skb->dev->dev_addr))
-			skb->pkt_type = PACKET_HOST;
-		break;
-	};
+	if (vlan_dev) {
+		skb->priority = vlan_get_ingress_priority(skb->dev, vlan_tag);
+		switch (skb->pkt_type) {
+		case PACKET_BROADCAST:
+			break;
+
+		case PACKET_MULTICAST:
+			stats->multicast++;
+			break;
+
+		case PACKET_OTHERHOST:
+			/* Our lower layer thinks this is not local, let's
+			 * make sure.
+			 * This allows the VLAN to have a different MAC than
+			 * the underlying device, and still route correctly.
+			 */
+			if (!compare_ether_addr(eth_hdr(skb)->h_dest,
+							skb->dev->dev_addr))
+				skb->pkt_type = PACKET_HOST;
+			break;
+		};
+	}
 
 	return (polling ? netif_receive_skb(skb) : netif_rx(skb));
 }
-- 
1.5.4.3


