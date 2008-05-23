From: Patrick McHardy <kaber@trash.net>
Subject: [VLAN]: Use bitmask of feature flags instead of seperate feature
 bits
Date: Fri, 23 May 2008 09:02:39 +0200
Message-ID: <48366C0F.4020905@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040201010304000802050706"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57471 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754341AbYEWHCn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2008 03:02:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040201010304000802050706
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Change the NETIF_F_VLAN flags to a bitmask of supported features,
as discussed with Herbert.

Tested by adding

+       netdev->vlan_features |= NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_SG | \
+                                NETIF_F_ALL_CSUM;
+

to e1000.


--------------040201010304000802050706
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit db2b989176f0e89f669ad8df34b2793ebbf0ab58
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri May 23 08:33:37 2008 +0200

    [VLAN]: Use bitmask of feature flags instead of seperate feature bits
    
    Herbert Xu points out that the use of seperate feature bits for features
    to be propagated to VLAN devices is going to get messy real soon.
    Replace the VLAN feature bits by a bitmask of feature flags to be
    propagated and restore the old GSO_SHIFT/MASK values.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 2b02664..f27fd20 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -514,12 +514,10 @@ struct net_device
 #define NETIF_F_NETNS_LOCAL	8192	/* Does not change network namespaces */
 #define NETIF_F_MULTI_QUEUE	16384	/* Has multiple TX/RX queues */
 #define NETIF_F_LRO		32768	/* large receive offload */
-#define NETIF_F_VLAN_TSO	65536	/* Supports TSO for VLANs */
-#define NETIF_F_VLAN_CSUM	131072	/* Supports TX checksumming for VLANs */
 
 	/* Segmentation offload features */
-#define NETIF_F_GSO_SHIFT	20
-#define NETIF_F_GSO_MASK	0xfff00000
+#define NETIF_F_GSO_SHIFT	16
+#define NETIF_F_GSO_MASK	0xffff0000
 #define NETIF_F_TSO		(SKB_GSO_TCPV4 << NETIF_F_GSO_SHIFT)
 #define NETIF_F_UFO		(SKB_GSO_UDP << NETIF_F_GSO_SHIFT)
 #define NETIF_F_GSO_ROBUST	(SKB_GSO_DODGY << NETIF_F_GSO_SHIFT)
@@ -747,6 +745,9 @@ struct net_device
 	/* rtnetlink link ops */
 	const struct rtnl_link_ops *rtnl_link_ops;
 
+	/* VLAN feature mask */
+	unsigned long vlan_features;
+
 	/* for setting kernel sock attribute on TCP connection setup */
 #define GSO_MAX_SIZE		65536
 	unsigned int		gso_max_size;
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 5196130..ab2225d 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -387,14 +387,8 @@ static void vlan_transfer_features(struct net_device *dev,
 {
 	unsigned long old_features = vlandev->features;
 
-	if (dev->features & NETIF_F_VLAN_TSO) {
-		vlandev->features &= ~VLAN_TSO_FEATURES;
-		vlandev->features |= dev->features & VLAN_TSO_FEATURES;
-	}
-	if (dev->features & NETIF_F_VLAN_CSUM) {
-		vlandev->features &= ~NETIF_F_ALL_CSUM;
-		vlandev->features |= dev->features & NETIF_F_ALL_CSUM;
-	}
+	vlandev->features &= ~dev->vlan_features;
+	vlandev->features |= dev->features & dev->vlan_features;
 
 	if (old_features != vlandev->features)
 		netdev_features_change(vlandev);
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index 7962569..5229a72 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -7,8 +7,6 @@
 #define VLAN_GRP_HASH_SIZE	(1 << VLAN_GRP_HASH_SHIFT)
 #define VLAN_GRP_HASH_MASK	(VLAN_GRP_HASH_SIZE - 1)
 
-#define VLAN_TSO_FEATURES	(NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_SG)
-
 /*  Find a VLAN device by the MAC address of its Ethernet device, and
  *  it's VLAN ID.  The default configuration is to have VLAN's scope
  *  to be box-wide, so the MAC will be ignored.  The mac will only be
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index b1cfbaa..5d055c2 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -663,10 +663,7 @@ static int vlan_dev_init(struct net_device *dev)
 					  (1<<__LINK_STATE_DORMANT))) |
 		      (1<<__LINK_STATE_PRESENT);
 
-	if (real_dev->features & NETIF_F_VLAN_TSO)
-		dev->features |= real_dev->features & VLAN_TSO_FEATURES;
-	if (real_dev->features & NETIF_F_VLAN_CSUM)
-		dev->features |= real_dev->features & NETIF_F_ALL_CSUM;
+	dev->features |= real_dev->features & real_dev->vlan_features;
 
 	/* ipv6 shared card related stuff */
 	dev->dev_id = real_dev->dev_id;

--------------040201010304000802050706--
