From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 06/16] batman-adv: Set special lockdep classes to avoid lockdep warning
Date: Mon, 29 Oct 2012 09:58:07 +0100
Message-ID: <1351501097-1289-7-git-send-email-ordex@autistici.org>
References: <1351501097-1289-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:54159 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756605Ab2J2I7C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2012 04:59:02 -0400
In-Reply-To: <1351501097-1289-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Transmissions over batman-adv devices always start another nested transmission
over devices attached to the batman-adv interface. These devices usually use
the ethernet lockdep class for the tx_queue lock which is also set by default
for all batman-adv devices. Lockdep will detect a nested locking attempt of two
locks with the same class and warn about a possible deadlock.

This is the default and expected behavior and should not alarm the locking
correctness prove mechanism. Therefore, the locks for all netdevice specific tx
queues get a special batman-adv lock class to avoid a false positive for each
transmission.

Reported-by: Linus Luessing <linus.luessing@web.de>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/soft-interface.c | 44 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 44 insertions(+)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index b9a28d2..948860a 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -347,7 +347,51 @@ out:
 	return;
 }
 
+/* batman-adv network devices have devices nesting below it and are a special
+ * "super class" of normal network devices; split their locks off into a
+ * separate class since they always nest.
+ */
+static struct lock_class_key batadv_netdev_xmit_lock_key;
+static struct lock_class_key batadv_netdev_addr_lock_key;
+
+/**
+ * batadv_set_lockdep_class_one - Set lockdep class for a single tx queue
+ * @dev: device which owns the tx queue
+ * @txq: tx queue to modify
+ * @_unused: always NULL
+ */
+static void batadv_set_lockdep_class_one(struct net_device *dev,
+					 struct netdev_queue *txq,
+					 void *_unused)
+{
+	lockdep_set_class(&txq->_xmit_lock, &batadv_netdev_xmit_lock_key);
+}
+
+/**
+ * batadv_set_lockdep_class - Set txq and addr_list lockdep class
+ * @dev: network device to modify
+ */
+static void batadv_set_lockdep_class(struct net_device *dev)
+{
+	lockdep_set_class(&dev->addr_list_lock, &batadv_netdev_addr_lock_key);
+	netdev_for_each_tx_queue(dev, batadv_set_lockdep_class_one, NULL);
+}
+
+/**
+ * batadv_softif_init - Late stage initialization of soft interface
+ * @dev: registered network device to modify
+ *
+ * Returns error code on failures
+ */
+static int batadv_softif_init(struct net_device *dev)
+{
+	batadv_set_lockdep_class(dev);
+
+	return 0;
+}
+
 static const struct net_device_ops batadv_netdev_ops = {
+	.ndo_init = batadv_softif_init,
 	.ndo_open = batadv_interface_open,
 	.ndo_stop = batadv_interface_release,
 	.ndo_get_stats = batadv_interface_stats,
-- 
1.7.12.4
