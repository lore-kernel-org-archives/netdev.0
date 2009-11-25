From: Patrick McHardy <kaber@trash.net>
Subject: vlan: support "loose binding" to the underlying network device
Date: Wed, 25 Nov 2009 18:54:54 +0100
Message-ID: <4B0D6F6E.4090901@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010403090808060107020401"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34294 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758746AbZKYRyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 12:54:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010403090808060107020401
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------010403090808060107020401
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

commit 3cf29fff45d8671adf234c17e59681aab222a81d
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Nov 25 16:28:27 2009 +0100

    vlan: support "loose binding" to the underlying network device
    
    Currently the UP/DOWN state of VLANs is synchronized to the state of the
    underlying device, meaning all VLANs are set down once the underlying
    device is set down. This causes all routes to the VLAN devices to vanish.
    
    Add a flag to specify a "loose binding" mode, in which only the operstate
    is transfered, but the VLAN device state is independant.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 153f6b9..3d870fd 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -339,6 +339,7 @@ enum vlan_ioctl_cmds {
 enum vlan_flags {
 	VLAN_FLAG_REORDER_HDR	= 0x1,
 	VLAN_FLAG_GVRP		= 0x2,
+	VLAN_FLAG_LOOSE_BINDING	= 0x4,
 };
 
 enum vlan_name_types {
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 1483243..225aa2f 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -431,6 +431,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 	struct vlan_group *grp;
 	int i, flgs;
 	struct net_device *vlandev;
+	struct vlan_dev_info *vlan;
 	LIST_HEAD(list);
 
 	if (is_vlan_dev(dev))
@@ -507,7 +508,9 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 			if (!(flgs & IFF_UP))
 				continue;
 
-			dev_change_flags(vlandev, flgs & ~IFF_UP);
+			vlan = vlan_dev_info(vlandev);
+			if (!(vlan->flags & VLAN_FLAG_LOOSE_BINDING))
+				dev_change_flags(vlandev, flgs & ~IFF_UP);
 			vlan_transfer_operstate(dev, vlandev);
 		}
 		break;
@@ -523,7 +526,9 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 			if (flgs & IFF_UP)
 				continue;
 
-			dev_change_flags(vlandev, flgs | IFF_UP);
+			vlan = vlan_dev_info(vlandev);
+			if (!(vlan->flags & VLAN_FLAG_LOOSE_BINDING))
+				dev_change_flags(vlandev, flgs | IFF_UP);
 			vlan_transfer_operstate(dev, vlandev);
 		}
 		break;
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index de0dc6b..b788978 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -431,7 +431,8 @@ int vlan_dev_change_flags(const struct net_device *dev, u32 flags, u32 mask)
 	struct vlan_dev_info *vlan = vlan_dev_info(dev);
 	u32 old_flags = vlan->flags;
 
-	if (mask & ~(VLAN_FLAG_REORDER_HDR | VLAN_FLAG_GVRP))
+	if (mask & ~(VLAN_FLAG_REORDER_HDR | VLAN_FLAG_GVRP |
+		     VLAN_FLAG_LOOSE_BINDING))
 		return -EINVAL;
 
 	vlan->flags = (old_flags & ~mask) | (flags & mask);
@@ -456,7 +457,8 @@ static int vlan_dev_open(struct net_device *dev)
 	struct net_device *real_dev = vlan->real_dev;
 	int err;
 
-	if (!(real_dev->flags & IFF_UP))
+	if (!(real_dev->flags & IFF_UP) &&
+	    !(vlan->flags & VLAN_FLAG_LOOSE_BINDING))
 		return -ENETDOWN;
 
 	if (compare_ether_addr(dev->dev_addr, real_dev->dev_addr)) {
diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
index 3c9cf6a..ddc1057 100644
--- a/net/8021q/vlan_netlink.c
+++ b/net/8021q/vlan_netlink.c
@@ -60,7 +60,8 @@ static int vlan_validate(struct nlattr *tb[], struct nlattr *data[])
 	if (data[IFLA_VLAN_FLAGS]) {
 		flags = nla_data(data[IFLA_VLAN_FLAGS]);
 		if ((flags->flags & flags->mask) &
-		    ~(VLAN_FLAG_REORDER_HDR | VLAN_FLAG_GVRP))
+		    ~(VLAN_FLAG_REORDER_HDR | VLAN_FLAG_GVRP |
+		      VLAN_FLAG_LOOSE_BINDING))
 			return -EINVAL;
 	}
 

--------------010403090808060107020401--
