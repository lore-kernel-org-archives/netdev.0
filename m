From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: [PATCH] bridge: use netstats in net_device structure
Date: Fri, 18 Jul 2008 18:27:32 +0300
Message-ID: <g5qcp4$clp$2@ger.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040302000402030203030901"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:41098 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751277AbYGRP1m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2008 11:27:42 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1KJrrx-0002zR-2q
	for netdev@vger.kernel.org; Fri, 18 Jul 2008 15:27:41 +0000
Received: from 82-135-208-232.static.zebra.lt ([82.135.208.232])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 18 Jul 2008 15:27:41 +0000
Received: from paulius.zaleckas by 82-135-208-232.static.zebra.lt with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 18 Jul 2008 15:27:41 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040302000402030203030901
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------040302000402030203030901
Content-Type: text/x-patch;
 name="bridge_netstats.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="bridge_netstats.patch"

Use net_device_stats from net_device structure instead of local.
Kill br_dev_get_stats function, because by default it is used identical
internal_stats function from net/core/dev.c

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>

Index: linux-2.6/net/bridge/br_device.c
===================================================================
--- linux-2.6.orig/net/bridge/br_device.c
+++ linux-2.6/net/bridge/br_device.c
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
@@ -161,7 +155,6 @@ void br_dev_setup(struct net_device *dev
 	ether_setup(dev);
 
 	dev->do_ioctl = br_dev_ioctl;
-	dev->get_stats = br_dev_get_stats;
 	dev->hard_start_xmit = br_dev_xmit;
 	dev->open = br_dev_open;
 	dev->set_multicast_list = br_dev_set_multicast_list;
Index: linux-2.6/net/bridge/br_private.h
===================================================================
--- linux-2.6.orig/net/bridge/br_private.h
+++ linux-2.6/net/bridge/br_private.h
@@ -90,7 +90,6 @@ struct net_bridge
 	spinlock_t			lock;
 	struct list_head		port_list;
 	struct net_device		*dev;
-	struct net_device_stats		statistics;
 	spinlock_t			hash_lock;
 	struct hlist_head		hash[BR_HASH_SIZE];
 	struct list_head		age_list;
Index: linux-2.6/net/bridge/br_forward.c
===================================================================
--- linux-2.6.orig/net/bridge/br_forward.c
+++ linux-2.6/net/bridge/br_forward.c
@@ -115,7 +115,7 @@ static void br_flood(struct net_bridge *
 				struct sk_buff *skb2;
 
 				if ((skb2 = skb_clone(skb, GFP_ATOMIC)) == NULL) {
-					br->statistics.tx_dropped++;
+					br->dev->stats.tx_dropped++;
 					kfree_skb(skb);
 					return;
 				}
Index: linux-2.6/net/bridge/br_input.c
===================================================================
--- linux-2.6.orig/net/bridge/br_input.c
+++ linux-2.6/net/bridge/br_input.c
@@ -26,8 +26,8 @@ static void br_pass_frame_up(struct net_
 {
 	struct net_device *indev;
 
-	br->statistics.rx_packets++;
-	br->statistics.rx_bytes += skb->len;
+	br->dev->stats.rx_packets++;
+	br->dev->stats.rx_bytes += skb->len;
 
 	indev = skb->dev;
 	skb->dev = br->dev;
@@ -64,7 +64,7 @@ int br_handle_frame_finish(struct sk_buf
 	dst = NULL;
 
 	if (is_multicast_ether_addr(dest)) {
-		br->statistics.multicast++;
+		br->dev->stats.multicast++;
 		skb2 = skb;
 	} else if ((dst = __br_fdb_get(br, dest)) && dst->is_local) {
 		skb2 = skb;

--------------040302000402030203030901--

