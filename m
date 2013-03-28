From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 08/11] batman-adv: free an hard-interface before adding it
Date: Thu, 28 Mar 2013 08:50:28 +0100
Message-ID: <1364457031-3194-9-git-send-email-ordex@autistici.org>
References: <1364457031-3194-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from diserzione.investici.org ([82.221.99.153]:33342 "EHLO
	diserzione.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756391Ab3C1HwM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 03:52:12 -0400
In-Reply-To: <1364457031-3194-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When adding a new hard interface (e.g. wlan0) to a soft interface (e.g. bat0)
and the former is already enslaved in another virtual interface (e.g. a software
bridge) batman-adv has to free it first and then continue with the adding
mechanism.

In this way the behaviour becomes consistent with what "ip link set master"
does. At the moment batman-adv enslaves the hard interface without checking for
the master device, possibly causing strange behaviours which are never wanted by
the users.

Reported-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/hard-interface.c | 39 +++++++++++++++++++++++++++++++++------
 1 file changed, 33 insertions(+), 6 deletions(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index f33ced8..522243a 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -307,11 +307,35 @@ batadv_hardif_deactivate_interface(struct batadv_hard_iface *hard_iface)
 	batadv_update_min_mtu(hard_iface->soft_iface);
 }
 
+/**
+ * batadv_master_del_slave - remove hard_iface from the current master interface
+ * @slave: the interface enslaved in another master
+ * @master: the master from which slave has to be removed
+ *
+ * Invoke ndo_del_slave on master passing slave as argument. In this way slave
+ * is free'd and master can correctly change its internal state.
+ * Return 0 on success, a negative value representing the error otherwise
+ */
+static int batadv_master_del_slave(struct batadv_hard_iface *slave,
+				   struct net_device *master)
+{
+	int ret;
+
+	if (!master)
+		return 0;
+
+	ret = -EBUSY;
+	if (master->netdev_ops->ndo_del_slave)
+		ret = master->netdev_ops->ndo_del_slave(master, slave->net_dev);
+
+	return ret;
+}
+
 int batadv_hardif_enable_interface(struct batadv_hard_iface *hard_iface,
 				   const char *iface_name)
 {
 	struct batadv_priv *bat_priv;
-	struct net_device *soft_iface;
+	struct net_device *soft_iface, *master;
 	__be16 ethertype = __constant_htons(ETH_P_BATMAN);
 	int ret;
 
@@ -321,11 +345,6 @@ int batadv_hardif_enable_interface(struct batadv_hard_iface *hard_iface,
 	if (!atomic_inc_not_zero(&hard_iface->refcount))
 		goto out;
 
-	/* hard-interface is part of a bridge */
-	if (hard_iface->net_dev->priv_flags & IFF_BRIDGE_PORT)
-		pr_err("You are about to enable batman-adv on '%s' which already is part of a bridge. Unless you know exactly what you are doing this is probably wrong and won't work the way you think it would.\n",
-		       hard_iface->net_dev->name);
-
 	soft_iface = dev_get_by_name(&init_net, iface_name);
 
 	if (!soft_iface) {
@@ -347,6 +366,14 @@ int batadv_hardif_enable_interface(struct batadv_hard_iface *hard_iface,
 		goto err_dev;
 	}
 
+	/* check if the interface is enslaved in another virtual one and
+	 * in that case unlink it first
+	 */
+	master = netdev_master_upper_dev_get(hard_iface->net_dev);
+	ret = batadv_master_del_slave(hard_iface, master);
+	if (ret)
+		goto err_dev;
+
 	hard_iface->soft_iface = soft_iface;
 	bat_priv = netdev_priv(hard_iface->soft_iface);
 
-- 
1.8.1.5
