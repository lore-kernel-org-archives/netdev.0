From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 2/2] dsa: fix master interface allmulti/promisc handling
Date: Mon, 10 Nov 2008 00:23:09 +0100
Message-ID: <20081109232309.GE32552@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:54009 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756485AbYKIXXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Nov 2008 18:23:12 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before commit b6c40d68ff6498b7f63ddf97cf0aa818d748dee7 ("net: only
invoke dev->change_rx_flags when device is UP"), the dsa driver could
sort-of get away with only fiddling with the master interface's
allmulti/promisc counts in ->change_rx_flags() and not touching them
in ->open() or ->stop().  After this commit (note that it was merged
almost simultaneously with the dsa patches, which is why this wasn't
caught initially), the breakage that was already there became more
apparent.

Since it makes no sense to keep the master interface's allmulti or
promisc count pinned for a slave interface that is down, copy the vlan
driver's sync logic (which does exactly what we want) over to dsa to
fix this.

Bug report from Dirk Teurlings <dirk@upexia.nl> and Peter van Valderen
<linux@ddcrew.com>.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
Tested-by: Dirk Teurlings <dirk@upexia.nl>
Tested-by: Peter van Valderen <linux@ddcrew.com>

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 5a4ff68..e8b7a01 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -10,6 +10,7 @@
 
 #include <linux/list.h>
 #include <linux/netdevice.h>
+#include <linux/etherdevice.h>
 #include <linux/phy.h>
 #include "dsa_priv.h"
 
@@ -49,11 +50,57 @@ void dsa_slave_mii_bus_init(struct dsa_switch *ds)
 /* slave device handling ****************************************************/
 static int dsa_slave_open(struct net_device *dev)
 {
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct net_device *master = p->parent->master_netdev;
+	int err;
+
+	if (!(master->flags & IFF_UP))
+		return -ENETDOWN;
+
+	if (compare_ether_addr(dev->dev_addr, master->dev_addr)) {
+		err = dev_unicast_add(master, dev->dev_addr, ETH_ALEN);
+		if (err < 0)
+			goto out;
+	}
+
+	if (dev->flags & IFF_ALLMULTI) {
+		err = dev_set_allmulti(master, 1);
+		if (err < 0)
+			goto del_unicast;
+	}
+	if (dev->flags & IFF_PROMISC) {
+		err = dev_set_promiscuity(master, 1);
+		if (err < 0)
+			goto clear_allmulti;
+	}
+
 	return 0;
+
+clear_allmulti:
+	if (dev->flags & IFF_ALLMULTI)
+		dev_set_allmulti(master, -1);
+del_unicast:
+	if (compare_ether_addr(dev->dev_addr, master->dev_addr))
+		dev_unicast_delete(master, dev->dev_addr, ETH_ALEN);
+out:
+	return err;
 }
 
 static int dsa_slave_close(struct net_device *dev)
 {
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct net_device *master = p->parent->master_netdev;
+
+	dev_mc_unsync(master, dev);
+	dev_unicast_unsync(master, dev);
+	if (dev->flags & IFF_ALLMULTI)
+		dev_set_allmulti(master, -1);
+	if (dev->flags & IFF_PROMISC)
+		dev_set_promiscuity(master, -1);
+
+	if (compare_ether_addr(dev->dev_addr, master->dev_addr))
+		dev_unicast_delete(master, dev->dev_addr, ETH_ALEN);
+
 	return 0;
 }
 
@@ -77,9 +124,30 @@ static void dsa_slave_set_rx_mode(struct net_device *dev)
 	dev_unicast_sync(master, dev);
 }
 
-static int dsa_slave_set_mac_address(struct net_device *dev, void *addr)
+static int dsa_slave_set_mac_address(struct net_device *dev, void *a)
 {
-	memcpy(dev->dev_addr, addr + 2, 6);
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct net_device *master = p->parent->master_netdev;
+	struct sockaddr *addr = a;
+	int err;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
+	if (!(dev->flags & IFF_UP))
+		goto out;
+
+	if (compare_ether_addr(addr->sa_data, master->dev_addr)) {
+		err = dev_unicast_add(master, addr->sa_data, ETH_ALEN);
+		if (err < 0)
+			return err;
+	}
+
+	if (compare_ether_addr(dev->dev_addr, master->dev_addr))
+		dev_unicast_delete(master, dev->dev_addr, ETH_ALEN);
+
+out:
+	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
 
 	return 0;
 }
