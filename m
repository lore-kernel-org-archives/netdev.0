From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-next 2/10][BRIDE]: Use on-device stats instead of private
 ones.
Date: Tue, 20 May 2008 20:32:39 +0400
Message-ID: <4832FD27.3090706@openvz.org>
References: <4832FBD7.7040209@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:33840 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751696AbYETQfH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2008 12:35:07 -0400
In-Reply-To: <4832FBD7.7040209@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Even though bridges require 6 fields from struct net_device_stats,
the on-device stats are always there, so we may just use them.

The br_dev_get_stats is no longer required after this.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/bridge/br_device.c  |   11 ++---------
 net/bridge/br_forward.c |    2 +-
 net/bridge/br_input.c   |   10 +++++-----
 net/bridge/br_private.h |    1 -
 4 files changed, 8 insertions(+), 16 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index bf77873..626c779 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
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
@@ -34,8 +28,8 @@ int br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	const unsigned char *dest = skb->data;
 	struct net_bridge_fdb_entry *dst;
 
-	br->statistics.tx_packets++;
-	br->statistics.tx_bytes += skb->len;
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
 
 	skb_reset_mac_header(skb);
 	skb_pull(skb, ETH_HLEN);
@@ -161,7 +155,6 @@ void br_dev_setup(struct net_device *dev)
 	ether_setup(dev);
 
 	dev->do_ioctl = br_dev_ioctl;
-	dev->get_stats = br_dev_get_stats;
 	dev->hard_start_xmit = br_dev_xmit;
 	dev->open = br_dev_open;
 	dev->set_multicast_list = br_dev_set_multicast_list;
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index bdd7c35..a471167 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -115,7 +115,7 @@ static void br_flood(struct net_bridge *br, struct sk_buff *skb,
 				struct sk_buff *skb2;
 
 				if ((skb2 = skb_clone(skb, GFP_ATOMIC)) == NULL) {
-					br->statistics.tx_dropped++;
+					br->dev->stats.tx_dropped++;
 					kfree_skb(skb);
 					return;
 				}
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 255c00f..fa0f571 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -24,13 +24,13 @@ const u8 br_group_address[ETH_ALEN] = { 0x01, 0x80, 0xc2, 0x00, 0x00, 0x00 };
 
 static void br_pass_frame_up(struct net_bridge *br, struct sk_buff *skb)
 {
-	struct net_device *indev;
+	struct net_device *indev, *brdev = br->dev;
 
-	br->statistics.rx_packets++;
-	br->statistics.rx_bytes += skb->len;
+	brdev->stats.rx_packets++;
+	brdev->stats.rx_bytes += skb->len;
 
 	indev = skb->dev;
-	skb->dev = br->dev;
+	skb->dev = brdev;
 
 	NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_IN, skb, indev, NULL,
 		netif_receive_skb);
@@ -64,7 +64,7 @@ int br_handle_frame_finish(struct sk_buff *skb)
 	dst = NULL;
 
 	if (is_multicast_ether_addr(dest)) {
-		br->statistics.multicast++;
+		br->dev->stats.multicast++;
 		skb2 = skb;
 	} else if ((dst = __br_fdb_get(br, dest)) && dst->is_local) {
 		skb2 = skb;
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index c11b554..0243cb4 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -90,7 +90,6 @@ struct net_bridge
 	spinlock_t			lock;
 	struct list_head		port_list;
 	struct net_device		*dev;
-	struct net_device_stats		statistics;
 	spinlock_t			hash_lock;
 	struct hlist_head		hash[BR_HASH_SIZE];
 	struct list_head		age_list;
-- 
1.5.3.4

