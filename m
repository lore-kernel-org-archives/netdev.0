From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 1/2] veth:  Fix carrier detect
Date: Wed, 25 Feb 2009 21:47:29 -0800
Message-ID: <m1ljrtkavi.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:44689 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751316AbZBZFrA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 00:47:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The current implementation of carrier detect in veth is broken.
It reports the link is down until both sides of the veth pair
are administatively up and then forever after it reports link up.

So fix veth so that it only reports link up when both interfaces
of the pair are administratively up.

Signed-off-by: Eric Biederman <ebiederm@aristanetworks.com>
---
 drivers/net/veth.c |   51 +++++++++++----------------------------------------
 1 files changed, 11 insertions(+), 40 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 108bbbe..124fe75 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -239,6 +239,16 @@ static int veth_open(struct net_device *dev)
 	return 0;
 }
 
+static int veth_close(struct net_device *dev)
+{
+	struct veth_priv *priv = netdev_priv(dev);
+
+	netif_carrier_off(dev);
+	netif_carrier_off(priv->peer);
+
+	return 0;
+}
+
 static int veth_dev_init(struct net_device *dev)
 {
 	struct veth_net_stats *stats;
@@ -265,6 +275,7 @@ static void veth_dev_free(struct net_device *dev)
 static const struct net_device_ops veth_netdev_ops = {
 	.ndo_init            = veth_dev_init,
 	.ndo_open            = veth_open,
+	.ndo_stop            = veth_close,
 	.ndo_start_xmit      = veth_xmit,
 	.ndo_get_stats       = veth_get_stats,
 	.ndo_set_mac_address = eth_mac_addr,
@@ -280,44 +291,6 @@ static void veth_setup(struct net_device *dev)
 	dev->destructor = veth_dev_free;
 }
 
-static void veth_change_state(struct net_device *dev)
-{
-	struct net_device *peer;
-	struct veth_priv *priv;
-
-	priv = netdev_priv(dev);
-	peer = priv->peer;
-
-	if (netif_carrier_ok(peer)) {
-		if (!netif_carrier_ok(dev))
-			netif_carrier_on(dev);
-	} else {
-		if (netif_carrier_ok(dev))
-			netif_carrier_off(dev);
-	}
-}
-
-static int veth_device_event(struct notifier_block *unused,
-			     unsigned long event, void *ptr)
-{
-	struct net_device *dev = ptr;
-
-	if (dev->netdev_ops->ndo_open != veth_open)
-		goto out;
-
-	switch (event) {
-	case NETDEV_CHANGE:
-		veth_change_state(dev);
-		break;
-	}
-out:
-	return NOTIFY_DONE;
-}
-
-static struct notifier_block veth_notifier_block __read_mostly = {
-	.notifier_call	= veth_device_event,
-};
-
 /*
  * netlink interface
  */
@@ -468,14 +441,12 @@ static struct rtnl_link_ops veth_link_ops = {
 
 static __init int veth_init(void)
 {
-	register_netdevice_notifier(&veth_notifier_block);
 	return rtnl_link_register(&veth_link_ops);
 }
 
 static __exit void veth_exit(void)
 {
 	rtnl_link_unregister(&veth_link_ops);
-	unregister_netdevice_notifier(&veth_notifier_block);
 }
 
 module_init(veth_init);
-- 
1.6.1.2.350.g88cc

