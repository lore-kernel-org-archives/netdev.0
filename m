From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 03/11] batman-adv: Move deinitialization of soft-interface to destructor
Date: Thu, 28 Mar 2013 08:50:23 +0100
Message-ID: <1364457031-3194-4-git-send-email-ordex@autistici.org>
References: <1364457031-3194-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from diserzione.investici.org ([82.221.99.153]:33284 "EHLO
	diserzione.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756527Ab3C1HwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 03:52:08 -0400
In-Reply-To: <1364457031-3194-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The deinitialization of the soft-interface created in ndo_init/constructor
should be done in the destructor and not directly before calling
unregister_netdevice

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Acked-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/soft-interface.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index c5cb0a7..e889bfb 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -417,7 +417,6 @@ static void batadv_softif_destroy_finish(struct work_struct *work)
 				cleanup_work);
 	soft_iface = bat_priv->soft_iface;
 
-	batadv_debugfs_del_meshif(soft_iface);
 	batadv_sysfs_del_meshif(soft_iface);
 
 	rtnl_lock();
@@ -522,6 +521,17 @@ static const struct net_device_ops batadv_netdev_ops = {
 };
 
 /**
+ * batadv_softif_free - Deconstructor of batadv_soft_interface
+ * @dev: Device to cleanup and remove
+ */
+static void batadv_softif_free(struct net_device *dev)
+{
+	batadv_debugfs_del_meshif(dev);
+	batadv_mesh_free(dev);
+	free_netdev(dev);
+}
+
+/**
  * batadv_softif_init_early - early stage initialization of soft interface
  * @dev: registered network device to modify
  */
@@ -532,7 +542,7 @@ static void batadv_softif_init_early(struct net_device *dev)
 	ether_setup(dev);
 
 	dev->netdev_ops = &batadv_netdev_ops;
-	dev->destructor = free_netdev;
+	dev->destructor = batadv_softif_free;
 	dev->tx_queue_len = 0;
 
 	/* can't call min_mtu, because the needed variables
@@ -575,7 +585,6 @@ void batadv_softif_destroy(struct net_device *soft_iface)
 {
 	struct batadv_priv *bat_priv = netdev_priv(soft_iface);
 
-	batadv_mesh_free(soft_iface);
 	queue_work(batadv_event_workqueue, &bat_priv->cleanup_work);
 }
 
-- 
1.8.1.5
