From: Patrick McHardy <kaber@trash.net>
Subject: net: only invoke dev->change_rx_flags when device is UP
Date: Tue, 07 Oct 2008 13:11:05 +0200
Message-ID: <48EB43C9.50601@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090904030607040002050606"
To: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41697 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753198AbYJGLLL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 07:11:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090904030607040002050606
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------090904030607040002050606
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit 0ba490b7259a39a405696215093b9a64eb52466b
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue Oct 7 13:10:33 2008 +0200

    net: only invoke dev->change_rx_flags when device is UP
    
    Jesper Dangaard Brouer <hawk@comx.dk> reported a bug when setting a VLAN
    device down that is in promiscous mode:
    
    When the VLAN device is set down, the promiscous count on the real
    device is decremented by one by vlan_dev_stop(). When removing the
    promiscous flag from the VLAN device afterwards, the promiscous
    count on the real device is decremented a second time by the
    vlan_change_rx_flags() callback.
    
    The root cause for this is that the ->change_rx_flags() callback is
    invoked while the device is down. The synchronization is meant to mirror
    the behaviour of the ->set_rx_mode callbacks, meaning the ->open function
    is responsible for doing a full sync on open, the ->close() function is
    responsible for doing full cleanup on ->stop() and ->change_rx_flags()
    is meant to do incremental changes while the device is UP.
    
    Only invoke ->change_rx_flags() while the device is UP to provide the
    intended behaviour.
    
    Tested-by: Jesper Dangaard Brouer <jdb@comx.dk>
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/core/dev.c b/net/core/dev.c
index e8eb2b4..fd992c0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2918,6 +2918,12 @@ int netdev_set_master(struct net_device *slave, struct net_device *master)
 	return 0;
 }
 
+static void dev_change_rx_flags(struct net_device *dev, int flags)
+{
+	if (dev->flags & IFF_UP && dev->change_rx_flags)
+		dev->change_rx_flags(dev, flags);
+}
+
 static int __dev_set_promiscuity(struct net_device *dev, int inc)
 {
 	unsigned short old_flags = dev->flags;
@@ -2955,8 +2961,7 @@ static int __dev_set_promiscuity(struct net_device *dev, int inc)
 				current->uid, current->gid,
 				audit_get_sessionid(current));
 
-		if (dev->change_rx_flags)
-			dev->change_rx_flags(dev, IFF_PROMISC);
+		dev_change_rx_flags(dev, IFF_PROMISC);
 	}
 	return 0;
 }
@@ -3022,8 +3027,7 @@ int dev_set_allmulti(struct net_device *dev, int inc)
 		}
 	}
 	if (dev->flags ^ old_flags) {
-		if (dev->change_rx_flags)
-			dev->change_rx_flags(dev, IFF_ALLMULTI);
+		dev_change_rx_flags(dev, IFF_ALLMULTI);
 		dev_set_rx_mode(dev);
 	}
 	return 0;
@@ -3347,8 +3351,8 @@ int dev_change_flags(struct net_device *dev, unsigned flags)
 	 *	Load in the correct multicast list now the flags have changed.
 	 */
 
-	if (dev->change_rx_flags && (old_flags ^ flags) & IFF_MULTICAST)
-		dev->change_rx_flags(dev, IFF_MULTICAST);
+	if ((old_flags ^ flags) & IFF_MULTICAST)
+		dev_change_rx_flags(dev, IFF_MULTICAST);
 
 	dev_set_rx_mode(dev);
 

--------------090904030607040002050606--
