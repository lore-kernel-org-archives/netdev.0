From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 29/47] starfire: do vlan cleanup
Date: Wed, 20 Jul 2011 16:54:31 +0200
Message-ID: <1311173689-17419-30-git-send-email-jpirko@redhat.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com,
	ionut@badula.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54962 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751543Ab1GTO4A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 10:56:00 -0400
In-Reply-To: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- unify vlan and nonvlan rx path
- kill np->vlgrp and netdev_vlan_rx_register

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/starfire.c |   89 +++++++++++++++++++++---------------------------
 1 files changed, 39 insertions(+), 50 deletions(-)

diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index 860a508..7ae1f99 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -561,7 +561,7 @@ struct netdev_private {
 	struct net_device *dev;
 	struct pci_dev *pci_dev;
 #ifdef VLAN_SUPPORT
-	struct vlan_group *vlgrp;
+	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
 #endif
 	void *queue_mem;
 	dma_addr_t queue_mem_dma;
@@ -607,18 +607,6 @@ static const struct ethtool_ops ethtool_ops;
 
 
 #ifdef VLAN_SUPPORT
-static void netdev_vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
-{
-        struct netdev_private *np = netdev_priv(dev);
-
-        spin_lock(&np->lock);
-	if (debug > 2)
-		printk("%s: Setting vlgrp to %p\n", dev->name, grp);
-        np->vlgrp = grp;
-	set_rx_mode(dev);
-        spin_unlock(&np->lock);
-}
-
 static void netdev_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
 {
 	struct netdev_private *np = netdev_priv(dev);
@@ -626,6 +614,7 @@ static void netdev_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
 	spin_lock(&np->lock);
 	if (debug > 1)
 		printk("%s: Adding vlanid %d to vlan filter\n", dev->name, vid);
+	set_bit(vid, np->active_vlans);
 	set_rx_mode(dev);
 	spin_unlock(&np->lock);
 }
@@ -637,7 +626,7 @@ static void netdev_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
 	spin_lock(&np->lock);
 	if (debug > 1)
 		printk("%s: removing vlanid %d from vlan filter\n", dev->name, vid);
-	vlan_group_set_device(np->vlgrp, vid, NULL);
+	clear_bit(vid, np->active_vlans);
 	set_rx_mode(dev);
 	spin_unlock(&np->lock);
 }
@@ -648,15 +637,14 @@ static const struct net_device_ops netdev_ops = {
 	.ndo_open		= netdev_open,
 	.ndo_stop		= netdev_close,
 	.ndo_start_xmit		= start_tx,
-	.ndo_tx_timeout 	= tx_timeout,
-	.ndo_get_stats 		= get_stats,
+	.ndo_tx_timeout		= tx_timeout,
+	.ndo_get_stats		= get_stats,
 	.ndo_set_multicast_list = &set_rx_mode,
-	.ndo_do_ioctl 		= netdev_ioctl,
+	.ndo_do_ioctl		= netdev_ioctl,
 	.ndo_change_mtu		= eth_change_mtu,
-	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 #ifdef VLAN_SUPPORT
-	.ndo_vlan_rx_register	= netdev_vlan_rx_register,
 	.ndo_vlan_rx_add_vid	= netdev_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= netdev_vlan_rx_kill_vid,
 #endif
@@ -1528,21 +1516,17 @@ static int __netdev_rx(struct net_device *dev, int *quota)
 			printk(KERN_DEBUG "%s: checksum_hw, status2 = %#x\n", dev->name, le16_to_cpu(desc->status2));
 		}
 #ifdef VLAN_SUPPORT
-		if (np->vlgrp && le16_to_cpu(desc->status2) & 0x0200) {
+		if (le16_to_cpu(desc->status2) & 0x0200) {
 			u16 vlid = le16_to_cpu(desc->vlanid);
 
 			if (debug > 4) {
 				printk(KERN_DEBUG "  netdev_rx() vlanid = %d\n",
 				       vlid);
 			}
-			/*
-			 * vlan_hwaccel_rx expects a packet with the VLAN tag
-			 * stripped out.
-			 */
-			vlan_hwaccel_rx(skb, np->vlgrp, vlid);
-		} else
+			__vlan_hwaccel_put_tag(skb, vlid);
+		}
 #endif /* VLAN_SUPPORT */
-			netif_receive_skb(skb);
+		netif_receive_skb(skb);
 		dev->stats.rx_packets++;
 
 	next_rx:
@@ -1752,6 +1736,32 @@ static struct net_device_stats *get_stats(struct net_device *dev)
 	return &dev->stats;
 }
 
+#ifdef VLAN_SUPPORT
+static u32 set_vlan_mode(struct netdev_private *np)
+{
+	u32 ret = VlanMode;
+	u16 vid;
+	void __iomem *filter_addr = np->base + HashTable + 8;
+	int vlan_count = 0;
+
+	for_each_set_bit(vid, np->active_vlans, VLAN_N_VID) {
+		if (vlan_count == 32)
+			break;
+		writew(vid, filter_addr);
+		filter_addr += 16;
+		vlan_count++;
+	}
+	if (vlan_count == 32) {
+		ret |= PerfectFilterVlan;
+		while (vlan_count < 32) {
+			writew(0, filter_addr);
+			filter_addr += 16;
+			vlan_count++;
+		}
+	}
+	return ret;
+}
+#endif /* VLAN_SUPPORT */
 
 static void set_rx_mode(struct net_device *dev)
 {
@@ -1760,30 +1770,9 @@ static void set_rx_mode(struct net_device *dev)
 	u32 rx_mode = MinVLANPrio;
 	struct netdev_hw_addr *ha;
 	int i;
-#ifdef VLAN_SUPPORT
 
-	rx_mode |= VlanMode;
-	if (np->vlgrp) {
-		int vlan_count = 0;
-		void __iomem *filter_addr = ioaddr + HashTable + 8;
-		for (i = 0; i < VLAN_VID_MASK; i++) {
-			if (vlan_group_get_device(np->vlgrp, i)) {
-				if (vlan_count >= 32)
-					break;
-				writew(i, filter_addr);
-				filter_addr += 16;
-				vlan_count++;
-			}
-		}
-		if (i == VLAN_VID_MASK) {
-			rx_mode |= PerfectFilterVlan;
-			while (vlan_count < 32) {
-				writew(0, filter_addr);
-				filter_addr += 16;
-				vlan_count++;
-			}
-		}
-	}
+#ifdef VLAN_SUPPORT
+	rx_mode |= set_vlan_mode(np);
 #endif /* VLAN_SUPPORT */
 
 	if (dev->flags & IFF_PROMISC) {	/* Set promiscuous. */
-- 
1.7.6

