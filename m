From: Patrick McHardy <kaber@trash.net>
Subject: vlan: update vlan carrier state for admin up/down
Date: Fri, 24 Apr 2009 17:44:47 +0200
Message-ID: <49F1DE6F.1030606@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090905010505030603010402"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48006 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751882AbZDXPox (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2009 11:44:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090905010505030603010402
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------090905010505030603010402
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

commit fcfdf9ecbaf759b658a9722af2862e595f2dec6b
Author: Jay Vosburgh <fubar@us.ibm.com>
Date:   Fri Apr 24 17:22:08 2009 +0200

    vlan: update vlan carrier state for admin up/down
    
    	Currently, the VLAN event handler does not adjust the VLAN
    device's carrier state when the real device or the VLAN device is set
    administratively up or down.
    
    	The following patch adds a transfer of operating state from the
    real device to the VLAN device when the real device is administratively
    set up or down, and sets the carrier state up or down during init, open
    and close of the VLAN device.
    
    	This permits observers above the VLAN device that care about the
    carrier state (bonding's link monitor, for example) to receive updates
    for administrative changes by more closely mimicing the behavior of real
    devices.
    
    Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 2b7390e..d1e1054 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -492,6 +492,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 				continue;
 
 			dev_change_flags(vlandev, flgs & ~IFF_UP);
+			vlan_transfer_operstate(dev, vlandev);
 		}
 		break;
 
@@ -507,6 +508,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 				continue;
 
 			dev_change_flags(vlandev, flgs | IFF_UP);
+			vlan_transfer_operstate(dev, vlandev);
 		}
 		break;
 
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 1b34135..2ce6658 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -462,6 +462,7 @@ static int vlan_dev_open(struct net_device *dev)
 	if (vlan->flags & VLAN_FLAG_GVRP)
 		vlan_gvrp_request_join(dev);
 
+	netif_carrier_on(dev);
 	return 0;
 
 clear_allmulti:
@@ -471,6 +472,7 @@ del_unicast:
 	if (compare_ether_addr(dev->dev_addr, real_dev->dev_addr))
 		dev_unicast_delete(real_dev, dev->dev_addr, ETH_ALEN);
 out:
+	netif_carrier_off(dev);
 	return err;
 }
 
@@ -492,6 +494,7 @@ static int vlan_dev_stop(struct net_device *dev)
 	if (compare_ether_addr(dev->dev_addr, real_dev->dev_addr))
 		dev_unicast_delete(real_dev, dev->dev_addr, dev->addr_len);
 
+	netif_carrier_off(dev);
 	return 0;
 }
 
@@ -612,6 +615,8 @@ static int vlan_dev_init(struct net_device *dev)
 	struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
 	int subclass = 0;
 
+	netif_carrier_off(dev);
+
 	/* IFF_BROADCAST|IFF_MULTICAST; ??? */
 	dev->flags  = real_dev->flags & ~(IFF_UP | IFF_PROMISC | IFF_ALLMULTI);
 	dev->iflink = real_dev->ifindex;

--------------090905010505030603010402--
