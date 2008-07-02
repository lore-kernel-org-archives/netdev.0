From: Patrick McHardy <kaber@trash.net>
Subject: bridge: fix use-after-free in br_cleanup_bridges()
Date: Wed, 02 Jul 2008 15:04:14 +0200
Message-ID: <486B7CCE.2@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030601090400060801020405"
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36917 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752924AbYGBNES (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2008 09:04:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030601090400060801020405
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------030601090400060801020405
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit 96f1dd78dad10d61bdd487edadea6adda5425e4c
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Jul 2 15:02:23 2008 +0200

    bridge: fix use-after-free in br_cleanup_bridges()

    Unregistering a bridge device may cause virtual devices stacked on the
    bridge, like vlan or macvlan devices, to be unregistered as well.
    br_cleanup_bridges() uses for_each_netdev_safe() to iterate over all
    devices during cleanup. This is not enough however, if one of the
    additionally unregistered devices is next in the list to the bridge
    device, it will get freed as well and the iteration continues on
    the freed element.

    Restart iteration after each bridge device removal from the beginning to
    fix this, similar to what rtnl_link_unregister() does.

    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index c2397f5..f38cc53 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -442,12 +442,16 @@ int br_del_if(struct net_bridge *br, struct net_device *dev)
 
 void __exit br_cleanup_bridges(void)
 {
-	struct net_device *dev, *nxt;
+	struct net_device *dev;
 
 	rtnl_lock();
-	for_each_netdev_safe(&init_net, dev, nxt)
-		if (dev->priv_flags & IFF_EBRIDGE)
+restart:
+	for_each_netdev(&init_net, dev) {
+		if (dev->priv_flags & IFF_EBRIDGE) {
 			del_br(dev->priv);
+			goto restart;
+		}
+	}
 	rtnl_unlock();
 
 }

--------------030601090400060801020405--
