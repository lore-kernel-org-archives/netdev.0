From: Patrick McHardy <kaber@trash.net>
Subject: [RFC, VLAN]: Propagate selected feature bits to VLAN devices
Date: Tue, 20 May 2008 16:37:23 +0200
Message-ID: <4832E223.7020206@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040203000002020103010005"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Peter Warasin <peter@endian.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41491 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756889AbYETOh3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 10:37:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040203000002020103010005
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

This patch implements the TSO feature propagation we discussed.
Only compile-tested so far, testing and comments welcome.



--------------040203000002020103010005
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit b01a0b6b4a0463fe896e166d0782f0daca8c69ff
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue May 20 16:34:51 2008 +0200

    [VLAN]: Propagate selected feature bits to VLAN devices
    
    Propagate feature bits from the NETDEV_FEAT_CHANGE notifier. For now
    only TSO is propagated for devices that announce their ability to
    support TSO in combination with VLAN accel by setting the NETIF_F_VLAN_TSO
    flag.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b11e6e1..3be4559 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -514,10 +514,11 @@ struct net_device
 #define NETIF_F_NETNS_LOCAL	8192	/* Does not change network namespaces */
 #define NETIF_F_MULTI_QUEUE	16384	/* Has multiple TX/RX queues */
 #define NETIF_F_LRO		32768	/* large receive offload */
+#define NETIF_F_VLAN_TSO	65536	/* Supports TSO for VLANs */
 
 	/* Segmentation offload features */
-#define NETIF_F_GSO_SHIFT	16
-#define NETIF_F_GSO_MASK	0xffff0000
+#define NETIF_F_GSO_SHIFT	20
+#define NETIF_F_GSO_MASK	0xfff00000
 #define NETIF_F_TSO		(SKB_GSO_TCPV4 << NETIF_F_GSO_SHIFT)
 #define NETIF_F_UFO		(SKB_GSO_UDP << NETIF_F_GSO_SHIFT)
 #define NETIF_F_GSO_ROBUST	(SKB_GSO_DODGY << NETIF_F_GSO_SHIFT)
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 2a739ad..1f172f7 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -382,6 +382,19 @@ static void vlan_sync_address(struct net_device *dev,
 	memcpy(vlan->real_dev_addr, dev->dev_addr, ETH_ALEN);
 }
 
+static void vlan_transfer_features(struct net_device *dev,
+				   struct net_device *vlandev)
+{
+	unsigned long old_features = vlandev->features;
+
+	if (dev->features & NETIF_F_VLAN_TSO)
+		vlandev->features |= dev->features &
+				     (NETIF_F_TSO | NETIF_F_TSO6);
+
+	if (old_features != vlandev->features)
+		netdev_features_change(vlandev);
+}
+
 static void __vlan_device_event(struct net_device *dev, unsigned long event)
 {
 	switch (event) {
@@ -450,6 +463,18 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 		}
 		break;
 
+	case NETDEV_FEAT_CHANGE:
+		/* Propagate device features to underlying device */
+		for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
+			vlandev = vlan_group_get_device(grp, i);
+			if (!vlandev)
+				continue;
+
+			vlan_transfer_features(dev, vlandev);
+		}
+
+		break;
+
 	case NETDEV_DOWN:
 		/* Put all VLANs for this dev in the down state too.  */
 		for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index c961f08..3705d5a 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -662,6 +662,7 @@ static int vlan_dev_init(struct net_device *dev)
 	dev->state  = (real_dev->state & ((1<<__LINK_STATE_NOCARRIER) |
 					  (1<<__LINK_STATE_DORMANT))) |
 		      (1<<__LINK_STATE_PRESENT);
+	dev->features = real_dev->features & (NETIF_F_TSO | NETIF_F_TSO6);
 
 	/* ipv6 shared card related stuff */
 	dev->dev_id = real_dev->dev_id;

--------------040203000002020103010005--
