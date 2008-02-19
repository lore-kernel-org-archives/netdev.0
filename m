From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [net-2.6][DRIVER][VETH] fix dev refcount race
Date: Tue, 19 Feb 2008 17:18:00 +0100
Message-ID: <47BB0138.1000104@fr.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000509060704010805070706"
Cc: Pavel Emelianov <xemul@openvz.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:1314 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751994AbYBSQ0d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2008 11:26:33 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.8/8.13.8) with ESMTP id m1JGQWUb053494
	for <netdev@vger.kernel.org>; Tue, 19 Feb 2008 16:26:32 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1JGQVFU2375820
	for <netdev@vger.kernel.org>; Tue, 19 Feb 2008 17:26:31 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1JGQVEG007589
	for <netdev@vger.kernel.org>; Tue, 19 Feb 2008 16:26:31 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000509060704010805070706
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



--------------000509060704010805070706
Content-Type: text/x-patch;
 name="veth-delete-fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="veth-delete-fix.patch"

Subject: veth fix dev refcount race
From: Daniel Lezcano <dlezcano@fr.ibm.com>

When deleting the veth driver, veth_close calls netif_carrier_off
for the two extremities of the network device. netif_carrier_off on
the peer device will fire an event and hold a reference on the peer
device. Just after, the peer is unregistered taking the rtnl_lock while
the linkwatch_event is scheduled. If __linkwatch_run_queue does not
occurs before the unregistering, unregister_netdevice will wait for
the dev refcount to reach zero holding the rtnl_lock and linkwatch_event
will wait for the rtnl_lock and hold the dev refcount.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 drivers/net/veth.c |   53 ++++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 40 insertions(+), 13 deletions(-)

Index: net-2.6/drivers/net/veth.c
===================================================================
--- net-2.6.orig/drivers/net/veth.c
+++ net-2.6/drivers/net/veth.c
@@ -244,18 +244,6 @@ static int veth_open(struct net_device *
 	return 0;
 }
 
-static int veth_close(struct net_device *dev)
-{
-	struct veth_priv *priv;
-
-	if (netif_carrier_ok(dev)) {
-		priv = netdev_priv(dev);
-		netif_carrier_off(dev);
-		netif_carrier_off(priv->peer);
-	}
-	return 0;
-}
-
 static int veth_dev_init(struct net_device *dev)
 {
 	struct veth_net_stats *stats;
@@ -286,13 +274,50 @@ static void veth_setup(struct net_device
 	dev->hard_start_xmit = veth_xmit;
 	dev->get_stats = veth_get_stats;
 	dev->open = veth_open;
-	dev->stop = veth_close;
 	dev->ethtool_ops = &veth_ethtool_ops;
 	dev->features |= NETIF_F_LLTX;
 	dev->init = veth_dev_init;
 	dev->destructor = veth_dev_free;
 }
 
+static void veth_change_state(struct net_device *dev)
+{
+	struct net_device *peer;
+	struct veth_priv *priv;
+
+	priv = netdev_priv(dev);
+	peer = priv->peer;
+
+	if (netif_carrier_ok(peer)) {
+		if (!netif_carrier_ok(dev))
+			netif_carrier_on(dev);
+	} else {
+		if (netif_carrier_ok(dev))
+			netif_carrier_off(dev);
+	}
+}
+
+static int veth_device_event(struct notifier_block *unused,
+			     unsigned long event, void *ptr)
+{
+	struct net_device *dev = ptr;
+
+	if (dev->open != veth_open)
+		goto out;
+
+	switch (event) {
+	case NETDEV_CHANGE:
+		veth_change_state(dev);
+		break;
+	}
+out:
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block veth_notifier_block __read_mostly = {
+	.notifier_call	= veth_device_event,
+};
+
 /*
  * netlink interface
  */
@@ -454,12 +479,14 @@ static struct rtnl_link_ops veth_link_op
 
 static __init int veth_init(void)
 {
+	register_netdevice_notifier(&veth_notifier_block);
 	return rtnl_link_register(&veth_link_ops);
 }
 
 static __exit void veth_exit(void)
 {
 	rtnl_link_unregister(&veth_link_ops);
+	unregister_netdevice_notifier(&veth_notifier_block);
 }
 
 module_init(veth_init);

--------------000509060704010805070706--
