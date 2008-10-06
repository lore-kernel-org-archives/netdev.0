From: Patrick McHardy <kaber@trash.net>
Subject: Re: Bisect'ed BUG in VLAN promisc mode (6c78dcbd47)
Date: Mon, 06 Oct 2008 13:03:26 +0200
Message-ID: <48E9F07E.9060609@trash.net>
References: <1222437636.7598.14.camel@localhost.localdomain>  <48DD0A4F.6020703@trash.net>  <1222456933.2381.3.camel@localhost.localdomain> <48DD36D2.90103@trash.net>  <48DD37E3.9090706@trash.net> <1222457670.2381.8.camel@localhost.localdomain> <48DD3AD5.80800@trash.net> <Pine.LNX.4.64.0810021835390.8590@tyr.diku.dk>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090405080901060904010604"
Cc: Jesper Dangaard Brouer <jdb@comx.dk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37318 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752927AbYJFLDe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 07:03:34 -0400
In-Reply-To: <Pine.LNX.4.64.0810021835390.8590@tyr.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090405080901060904010604
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Jesper Dangaard Brouer wrote:
> 
> Here is a quick fix for the bug...
> Patrick promised he would do a more clean fix later ;-)

And here it is. Could you verify that it also fixes the problem?
Thanks!



--------------090405080901060904010604
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit 79a95e393b63c26f270c676075b95c9421d3faba
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Oct 6 13:01:26 2008 +0200

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
 

--------------090405080901060904010604--
