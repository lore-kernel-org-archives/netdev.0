From: "Dave Johnson" <djohnson+linux-kernel@sw.starentnetworks.com>
Subject: [PATCH 1/2] NET: Re-add VLAN tag for devices incapable of keeping it
Date: Mon, 5 Nov 2007 12:46:59 -0500
Message-ID: <18223.22291.622615.129374@zeus.sw.starentnetworks.com>
References: <472A49BD.6000802@hp.com>
	<20071101.145956.63020380.davem@davemloft.net>
	<472A4D5C.2070301@hp.com>
	<20071101.150723.30590053.davem@davemloft.net>
	<472A6089.7020104@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, jes@trained-monkey.org,
	mchan@broadcom.com, ram.vepa@neterion.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	bguo@sw.starentnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.starentnetworks.com ([12.38.223.203]:54163 "EHLO
	mx0.starentnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752782AbXKERrH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 12:47:07 -0500
In-Reply-To: <472A6089.7020104@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Some MACs are configured to remove VLAN tags on RX packets even if
the kernel isn't setup to use VLANs.

On these drivers it is bad to simply pass the packets with the VLAN
tag removed to the network stack.  This gives the network stack the
impression these packets arrived from the network without a VLAN tag
even though they had one.  This has 2 issues: 1, PF_PACKET sockets see
the packet without the VLAN tag when bound to the base device; and 2,
the L3 stacks will process these packets as if they had no tag to
begin with.

This patch changes vlan_hwaccel_rx() and vlan_hwaccel_receive_skb() to
accept a NULL vlan group.  This simplifies the drivers as they can
call vlan_hwaccel_rx()/vlan_hwaccel_receive_skb() if the MAC
has removed the VLAN tag, or netif_rx()/netif_receive_skb() if the
MAC hasn't removed a VLAN tag (or the packet arrived untagged).

If the vlan group is NULL or no device for the received VID exists,
vlan_hwaccel_rx()/vlan_hwaccel_receive_skb() will now re-add a VLAN
tag and pass the packet to the base device with tag intact.

It is still preferable for the drivers to disable VLAN tag removal in
the hardware if no vlan group is configured.  However for devices that
cannot do this the change will ensure tagged packets remain tagged in
the network stack.

Signed-off-by: Dave Johnson <djohnson@sw.starentnetworks.com>

---

Note, __vlan_hwaccel_rx() needed to move below __vlan_put_tag() so the
change really isn't as big as it may look below.

===== include/linux/if_vlan.h 1.25 vs edited =====
--- 1.25/include/linux/if_vlan.h	2007-07-14 21:53:28 -04:00
+++ edited/include/linux/if_vlan.h	2007-11-03 14:26:43 -04:00
@@ -164,71 +164,6 @@
 	(VLAN_TX_SKB_CB(__skb)->magic == VLAN_TX_COOKIE_MAGIC)
 #define vlan_tx_tag_get(__skb)	(VLAN_TX_SKB_CB(__skb)->vlan_tag)
 
-/* VLAN rx hw acceleration helper.  This acts like netif_{rx,receive_skb}(). */
-static inline int __vlan_hwaccel_rx(struct sk_buff *skb,
-				    struct vlan_group *grp,
-				    unsigned short vlan_tag, int polling)
-{
-	struct net_device_stats *stats;
-
-	if (skb_bond_should_drop(skb)) {
-		dev_kfree_skb_any(skb);
-		return NET_RX_DROP;
-	}
-
-	skb->dev = vlan_group_get_device(grp, vlan_tag & VLAN_VID_MASK);
-	if (skb->dev == NULL) {
-		dev_kfree_skb_any(skb);
-
-		/* Not NET_RX_DROP, this is not being dropped
-		 * due to congestion.
-		 */
-		return 0;
-	}
-
-	skb->dev->last_rx = jiffies;
-
-	stats = vlan_dev_get_stats(skb->dev);
-	stats->rx_packets++;
-	stats->rx_bytes += skb->len;
-
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
-
-	return (polling ? netif_receive_skb(skb) : netif_rx(skb));
-}
-
-static inline int vlan_hwaccel_rx(struct sk_buff *skb,
-				  struct vlan_group *grp,
-				  unsigned short vlan_tag)
-{
-	return __vlan_hwaccel_rx(skb, grp, vlan_tag, 0);
-}
-
-static inline int vlan_hwaccel_receive_skb(struct sk_buff *skb,
-					   struct vlan_group *grp,
-					   unsigned short vlan_tag)
-{
-	return __vlan_hwaccel_rx(skb, grp, vlan_tag, 1);
-}
-
 /**
  * __vlan_put_tag - regular VLAN tag inserting
  * @skb: skbuff to tag
@@ -243,10 +178,19 @@
 static inline struct sk_buff *__vlan_put_tag(struct sk_buff *skb, unsigned short tag)
 {
 	struct vlan_ethhdr *veth;
+	int new_mac_offset;
+
+	if (skb_mac_header_was_set(skb))
+		/* if the MAC header is not at skb->data we need to push to that
+		 * place then pull back before returning to the caller.
+		 */
+		new_mac_offset = VLAN_HLEN + skb->data - skb_mac_header(skb);
+	else
+		new_mac_offset = VLAN_HLEN;
 
-	if (skb_headroom(skb) < VLAN_HLEN) {
+	if (skb_headroom(skb) < new_mac_offset) {
 		struct sk_buff *sk_tmp = skb;
-		skb = skb_realloc_headroom(sk_tmp, VLAN_HLEN);
+		skb = skb_realloc_headroom(sk_tmp, new_mac_offset);
 		kfree_skb(sk_tmp);
 		if (!skb) {
 			printk(KERN_ERR "vlan: failed to realloc headroom\n");
@@ -260,7 +204,7 @@
 		}
 	}
 
-	veth = (struct vlan_ethhdr *)skb_push(skb, VLAN_HLEN);
+	veth = (struct vlan_ethhdr *)skb_push(skb, new_mac_offset);
 
 	/* Move the mac addresses to the beginning of the new header. */
 	memmove(skb->data, skb->data + VLAN_HLEN, 2 * VLAN_ETH_ALEN);
@@ -275,6 +219,8 @@
 	skb->mac_header -= VLAN_HLEN;
 	skb->network_header -= VLAN_HLEN;
 
+	/* back to where we started, minus the new vlan header */
+	skb_pull(skb, new_mac_offset-VLAN_HLEN);
 	return skb;
 }
 
@@ -372,6 +318,98 @@
 	} else {
 		return __vlan_get_tag(skb, tag);
 	}
+}
+
+/* VLAN rx hw acceleration helper.  This acts like netif_{rx,receive_skb}(). */
+static inline int __vlan_hwaccel_rx(struct sk_buff *skb,
+				    struct vlan_group *grp,
+				    unsigned short vlan_tag, int polling)
+{
+	struct net_device_stats *stats;
+	struct net_device *new_dev;
+
+	if (skb_bond_should_drop(skb)) {
+		dev_kfree_skb_any(skb);
+		return NET_RX_DROP;
+	}
+
+	if (grp)
+		new_dev = vlan_group_get_device(grp, vlan_tag & VLAN_VID_MASK);
+
+	if (!grp || !new_dev) {
+		/* Driver removed vlan tag from the packet, but we have no
+		 * vlan device for this VID.
+		 *
+		 * This can occur for 2 reasons:
+		 * 1) Have a vlan group, we want some VIDs, just not this VID.
+		 * 2) Have no vlan group, but hardware limitation requires it
+		 *    to remove vlan tags anyway.
+		 *
+		 * Normally if no vlan group is configured, the underlying
+		 * driver will configure the hardware to NOT strip out the
+		 * vlan tag.  It can then call netif_receive_skb/netif_rx
+		 * with the vlan tag still intact.  However some devices
+		 * cannot be configured to keep the vlan tag and must not
+		 * call netif_receive_skb/netif_rx with the vlan tag
+		 * missing.  This would allow the normal protocol handlers
+		 * to process this tagged packet as if it arived without a
+		 * vlan tag.
+		 *
+		 * We need to re-add the TAG and hand the packet off to the
+		 * base device with the TAG present so any protocol handlers
+		 * (PF_PACKET, etc...) will get a chance to see it.
+		 */
+
+		skb = __vlan_put_tag(skb, vlan_tag);
+
+		if (likely(skb))
+			return (polling ? netif_receive_skb(skb) : netif_rx(skb));
+		else
+			return NET_RX_DROP;
+	}
+
+	skb->dev = new_dev;
+	skb->dev->last_rx = jiffies;
+
+	stats = vlan_dev_get_stats(skb->dev);
+	stats->rx_packets++;
+	stats->rx_bytes += skb->len;
+
+	skb->priority = vlan_get_ingress_priority(skb->dev, vlan_tag);
+	switch (skb->pkt_type) {
+	case PACKET_BROADCAST:
+		break;
+
+	case PACKET_MULTICAST:
+		stats->multicast++;
+		break;
+
+	case PACKET_OTHERHOST:
+		/* Our lower layer thinks this is not local, let's make sure.
+		 * This allows the VLAN to have a different MAC than the underlying
+		 * device, and still route correctly.
+		 */
+		if (!compare_ether_addr(eth_hdr(skb)->h_dest,
+				       	skb->dev->dev_addr))
+			skb->pkt_type = PACKET_HOST;
+		break;
+	};
+
+	return (polling ? netif_receive_skb(skb) : netif_rx(skb));
+}
+
+static inline int vlan_hwaccel_rx(struct sk_buff *skb,
+				  struct vlan_group *grp,
+				  unsigned short vlan_tag)
+{
+	return __vlan_hwaccel_rx(skb, grp, vlan_tag, 0);
+}
+
+static inline int vlan_hwaccel_receive_skb(struct sk_buff *skb,
+					   struct vlan_group *grp,
+					   unsigned short vlan_tag)
+{
+	return __vlan_hwaccel_rx(skb, grp, vlan_tag, 1);
 }
 
 #endif /* __KERNEL__ */

