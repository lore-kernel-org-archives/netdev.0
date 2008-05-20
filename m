From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC, VLAN]: Propagate selected feature bits to VLAN devices
Date: Tue, 20 May 2008 20:31:48 +0200
Message-ID: <48331914.7050501@trash.net>
References: <4832E223.7020206@trash.net> <20080520180528.GU28241@solarflare.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050404080908020104060205"
Cc: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47064 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755869AbYETSdP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 14:33:15 -0400
In-Reply-To: <20080520180528.GU28241@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050404080908020104060205
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Ben Hutchings wrote:
> Patrick McHardy wrote:
>> +	if (dev->features & NETIF_F_VLAN_TSO)
>> +		vlandev->features |= dev->features &
>> +				     (NETIF_F_TSO | NETIF_F_TSO6);
>>     
>
> Shouldn't this mask the flags out of vlandev->features first?
>   
Yes, thanks.
>> +	dev->features = real_dev->features & (NETIF_F_TSO | NETIF_F_TSO6);
>>     
> This should also test the NETIF_F_VLAN_TSO flag and should copy the
> NETIF_F_ALL_CSUM and NETIF_F_SG flags since TSO requires those (see
> register_netdevice() feature fix-up).  Peter pointed out that TX checksum
> offload for VLANs might be available even without TSO; the same goes for
> scatter-gather but I don't know whether it's worth adding a flag for that.
>   

Thanks, I added NETIF_F_SG to the VLAN TSO flags and added a
NETIF_F_VLAN_CSUM flag for TX checksums. I didn't change
GSO_SHIFT so far.



--------------050404080908020104060205
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit fd467a0422c9c8ddd05c53c4f91d4af71c8fb9ff
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue May 20 20:31:40 2008 +0200

    [VLAN]: Propagate selected feature bits to VLAN devices
    
    Propagate feature bits from the NETDEV_FEAT_CHANGE notifier. For now
    only TSO is propagated for devices that announce their ability to
    support TSO in combination with VLAN accel by setting the NETIF_F_VLAN_TSO
    flag.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b11e6e1..2b02664 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -514,10 +514,12 @@ struct net_device
 #define NETIF_F_NETNS_LOCAL	8192	/* Does not change network namespaces */
 #define NETIF_F_MULTI_QUEUE	16384	/* Has multiple TX/RX queues */
 #define NETIF_F_LRO		32768	/* large receive offload */
+#define NETIF_F_VLAN_TSO	65536	/* Supports TSO for VLANs */
+#define NETIF_F_VLAN_CSUM	131072	/* Supports TX checksumming for VLANs */
 
 	/* Segmentation offload features */
-#define NETIF_F_GSO_SHIFT	16
-#define NETIF_F_GSO_MASK	0xffff0000
+#define NETIF_F_GSO_SHIFT	20
+#define NETIF_F_GSO_MASK	0xfff00000
 #define NETIF_F_TSO		(SKB_GSO_TCPV4 << NETIF_F_GSO_SHIFT)
 #define NETIF_F_UFO		(SKB_GSO_UDP << NETIF_F_GSO_SHIFT)
 #define NETIF_F_GSO_ROBUST	(SKB_GSO_DODGY << NETIF_F_GSO_SHIFT)
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 2a739ad..20fb6fd 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -382,6 +382,24 @@ static void vlan_sync_address(struct net_device *dev,
 	memcpy(vlan->real_dev_addr, dev->dev_addr, ETH_ALEN);
 }
 
+static void vlan_transfer_features(struct net_device *dev,
+				   struct net_device *vlandev)
+{
+	unsigned long old_features = vlandev->features;
+
+	if (dev->features & NETIF_F_VLAN_TSO) {
+		vlandev->features &= ~VLAN_TSO_FEATURES;
+		vlandev->features |= dev->features & VLAN_TSO_FEATURES;
+	}
+	if (dev->features & NETIF_F_VLAN_CSUM) {
+		vlandev->features &= ~NETIF_F_ALL_CSUM;
+		vlandev->features |= dev->features & NETIF_F_ALL_CSUM;
+	}
+
+	if (old_features != vlandev->features)
+		netdev_features_change(vlandev);
+}
+
 static void __vlan_device_event(struct net_device *dev, unsigned long event)
 {
 	switch (event) {
@@ -450,6 +468,18 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
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
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index 5229a72..7962569 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -7,6 +7,8 @@
 #define VLAN_GRP_HASH_SIZE	(1 << VLAN_GRP_HASH_SHIFT)
 #define VLAN_GRP_HASH_MASK	(VLAN_GRP_HASH_SIZE - 1)
 
+#define VLAN_TSO_FEATURES	(NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_SG)
+
 /*  Find a VLAN device by the MAC address of its Ethernet device, and
  *  it's VLAN ID.  The default configuration is to have VLAN's scope
  *  to be box-wide, so the MAC will be ignored.  The mac will only be
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index c961f08..b1cfbaa 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -663,6 +663,11 @@ static int vlan_dev_init(struct net_device *dev)
 					  (1<<__LINK_STATE_DORMANT))) |
 		      (1<<__LINK_STATE_PRESENT);
 
+	if (real_dev->features & NETIF_F_VLAN_TSO)
+		dev->features |= real_dev->features & VLAN_TSO_FEATURES;
+	if (real_dev->features & NETIF_F_VLAN_CSUM)
+		dev->features |= real_dev->features & NETIF_F_ALL_CSUM;
+
 	/* ipv6 shared card related stuff */
 	dev->dev_id = real_dev->dev_id;
 

--------------050404080908020104060205--
