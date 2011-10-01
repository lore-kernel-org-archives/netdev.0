From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/2] bridge: fix ordering of NEWLINK and NEWNEIGH events
Date: Fri, 30 Sep 2011 17:37:26 -0700
Message-ID: <20111001003835.282462632@vyatta.com>
References: <20111001003725.449204345@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sfca-50.vyatta.com ([76.74.103.50]:51638 "EHLO fiji.vyatta.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751093Ab1JAAkw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Sep 2011 20:40:52 -0400
Content-Disposition: inline; filename=bridge-fix-event-order.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When port is added to a bridge, the old code would send the new neighbor
netlink message before the subsequent new link message. This bug makes
it difficult to use the monitoring API in an application.

This code changes the ordering to add the forwarding entry
after the port is setup. One of the error checks (for invalid address)
is moved earlier in the process to avoid having to do unwind.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 net/bridge/br_if.c |   15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

--- a/net/bridge/br_if.c	2011-09-22 21:59:11.515091624 -0700
+++ b/net/bridge/br_if.c	2011-09-30 10:31:32.877957572 -0700
@@ -13,6 +13,7 @@
 
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
+#include <linux/etherdevice.h>
 #include <linux/netpoll.h>
 #include <linux/ethtool.h>
 #include <linux/if_arp.h>
@@ -322,7 +323,8 @@ int br_add_if(struct net_bridge *br, str
 
 	/* Don't allow bridging non-ethernet like devices */
 	if ((dev->flags & IFF_LOOPBACK) ||
-	    dev->type != ARPHRD_ETHER || dev->addr_len != ETH_ALEN)
+	    dev->type != ARPHRD_ETHER || dev->addr_len != ETH_ALEN ||
+	    !is_valid_ether_addr(dev->dev_addr))
 		return -EINVAL;
 
 	/* No bridging of bridges */
@@ -350,10 +352,6 @@ int br_add_if(struct net_bridge *br, str
 	err = kobject_init_and_add(&p->kobj, &brport_ktype, &(dev->dev.kobj),
 				   SYSFS_BRIDGE_PORT_ATTR);
 	if (err)
-		goto err0;
-
-	err = br_fdb_insert(br, p, dev->dev_addr);
-	if (err)
 		goto err1;
 
 	err = br_sysfs_addif(p);
@@ -394,6 +392,9 @@ int br_add_if(struct net_bridge *br, str
 
 	dev_set_mtu(br->dev, br_min_mtu(br));
 
+	if (br_fdb_insert(br, p, dev->dev_addr))
+		netdev_err(dev, "failed insert local address bridge forwarding table\n");
+
 	kobject_uevent(&p->kobj, KOBJ_ADD);
 
 	return 0;
@@ -403,11 +404,9 @@ err4:
 err3:
 	sysfs_remove_link(br->ifobj, p->dev->name);
 err2:
-	br_fdb_delete_by_port(br, p, 1);
-err1:
 	kobject_put(&p->kobj);
 	p = NULL; /* kobject_put frees */
-err0:
+err1:
 	dev_set_promiscuity(dev, -1);
 put_back:
 	dev_put(dev);
