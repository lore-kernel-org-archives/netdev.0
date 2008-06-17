From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] bridge: use statistics in net_device
Date: Tue, 17 Jun 2008 16:14:09 -0700 (PDT)
Message-ID: <20080617.161409.132612527.davem@davemloft.net>
References: <20080617165211.615620784@vyatta.com>
	<20080617165223.258482526@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38440
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757075AbYFQXOJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 19:14:09 -0400
In-Reply-To: <20080617165223.258482526@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 17 Jun 2008 09:52:14 -0700

> Move statistics to net_device structure. Also, update last_rx on bridge
> device (even though only bonding seems to use it).
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

This patch doesn't apply even remotely to anything I have in my tree.
What did you generate this against?

For example:

> --- a/net/bridge/br_device.c	2008-06-17 09:31:24.000000000 -0700
> +++ b/net/bridge/br_device.c	2008-06-17 09:34:01.000000000 -0700
> @@ -21,12 +21,6 @@
>  #include <asm/uaccess.h>
>  #include "br_private.h"
>  
> -static struct net_device_stats *br_dev_get_stats(struct net_device *dev)
> -{
> -	struct net_bridge *br = netdev_priv(dev);
> -	return &br->statistics;
> -}
> -
>  /* net device transmit always called with no BH (preempt_disabled) */
>  int br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
>  {

In my tree that function does not exist.

I see, Pavel already made this conversion already.  Stephen, please
actually generate your patches against the tree you claim they should
be applied to, thanks :-)

commit a339f1c881fdb8092ef9b118610307e10e885fc8
Author: Pavel Emelyanov <xemul@openvz.org>
Date:   Wed May 21 14:13:47 2008 -0700

    bridge: Use on-device stats instead of private ones.
    
    Even though bridges require 6 fields from struct net_device_stats,
    the on-device stats are always there, so we may just use them.
    
    The br_dev_get_stats is no longer required after this.
    
    Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
    Signed-off-by: David S. Miller <davem@davemloft.net>

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


