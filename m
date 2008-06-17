From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/3] bridge: use statistics in net_device
Date: Tue, 17 Jun 2008 09:52:14 -0700
Message-ID: <20080617165223.258482526@vyatta.com>
References: <20080617165211.615620784@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:56910 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754330AbYFQQwz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 12:52:55 -0400
Content-Disposition: inline; filename=br-stats.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move statistics to net_device structure. Also, update last_rx on bridge
device (even though only bonding seems to use it).

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/bridge/br_device.c	2008-06-17 09:31:24.000000000 -0700
+++ b/net/bridge/br_device.c	2008-06-17 09:34:01.000000000 -0700
@@ -21,12 +21,6 @@
 #include <asm/uaccess.h>
 #include "br_private.h"
 
-static struct net_device_stats *br_dev_get_stats(struct net_device *dev)
-{
-	struct net_bridge *br = netdev_priv(dev);
-	return &br->statistics;
-}
-
 /* net device transmit always called with no BH (preempt_disabled) */
 int br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 {
@@ -34,8 +28,8 @@ int br_dev_xmit(struct sk_buff *skb, str
 	const unsigned char *dest = skb->data;
 	struct net_bridge_fdb_entry *dst;
 
-	br->statistics.tx_packets++;
-	br->statistics.tx_bytes += skb->len;
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
 
 	skb_reset_mac_header(skb);
 	skb_pull(skb, ETH_HLEN);
@@ -162,7 +156,6 @@ void br_dev_setup(struct net_device *dev
 	ether_setup(dev);
 
 	dev->do_ioctl = br_dev_ioctl;
-	dev->get_stats = br_dev_get_stats;
 	dev->hard_start_xmit = br_dev_xmit;
 	dev->open = br_dev_open;
 	dev->set_multicast_list = br_dev_set_multicast_list;
--- a/net/bridge/br_forward.c	2008-06-17 09:32:32.000000000 -0700
+++ b/net/bridge/br_forward.c	2008-06-17 09:34:37.000000000 -0700
@@ -115,7 +115,7 @@ static void br_flood(struct net_bridge *
 				struct sk_buff *skb2;
 
 				if ((skb2 = skb_clone(skb, GFP_ATOMIC)) == NULL) {
-					br->statistics.tx_dropped++;
+					br->dev->stats.tx_dropped++;
 					kfree_skb(skb);
 					return;
 				}
--- a/net/bridge/br_input.c	2008-06-17 09:32:52.000000000 -0700
+++ b/net/bridge/br_input.c	2008-06-17 09:35:49.000000000 -0700
@@ -24,13 +24,15 @@ const u8 br_group_address[ETH_ALEN] = { 
 
 static void br_pass_frame_up(struct net_bridge *br, struct sk_buff *skb)
 {
+	struct net_device *brdev = br->dev;
 	struct net_device *indev;
 
-	br->statistics.rx_packets++;
-	br->statistics.rx_bytes += skb->len;
+	brdev->stats.rx_packets++;
+	brdev->stats.rx_bytes += skb->len;
+	brdev->last_rx = jiffies;
 
 	indev = skb->dev;
-	skb->dev = br->dev;
+	skb->dev = brdev;
 
 	NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_IN, skb, indev, NULL,
 		netif_receive_skb);
@@ -64,7 +66,7 @@ int br_handle_frame_finish(struct sk_buf
 	dst = NULL;
 
 	if (is_multicast_ether_addr(dest)) {
-		br->statistics.multicast++;
+		br->dev->stats.multicast++;
 		skb2 = skb;
 	} else if ((dst = __br_fdb_get(br, dest)) && dst->is_local) {
 		skb2 = skb;
--- a/net/bridge/br_private.h	2008-06-17 09:21:43.000000000 -0700
+++ b/net/bridge/br_private.h	2008-06-17 09:21:58.000000000 -0700
@@ -90,7 +90,7 @@ struct net_bridge
 	spinlock_t			lock;
 	struct list_head		port_list;
 	struct net_device		*dev;
-	struct net_device_stats		statistics;
+
 	spinlock_t			hash_lock;
 	struct hlist_head		hash[BR_HASH_SIZE];
 	struct list_head		age_list;

-- 

