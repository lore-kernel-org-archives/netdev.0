From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 07/11] batman-adv: Allow to modify slaves of soft-interfaces through rntl_link
Date: Thu, 28 Mar 2013 08:50:27 +0100
Message-ID: <1364457031-3194-8-git-send-email-ordex@autistici.org>
References: <1364457031-3194-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from diserzione.investici.org ([82.221.99.153]:33323 "EHLO
	diserzione.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755957Ab3C1HwL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 03:52:11 -0400
In-Reply-To: <1364457031-3194-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The sysfs configuration interface of batman-adv to add/remove slaves of an
soft-iface is not deadlock free and doesn't follow the currently common way to
modify slaves of an interface.

An additional configuration interface though rtnl_link is introduced which
provides easy device adding/removing with tools like "ip":
$ ip link set dev eth0 master bat0
$ ip link set dev eth0 nomaster

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Acked-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/hard-interface.c | 12 +++++++--
 net/batman-adv/soft-interface.c | 56 ++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 65 insertions(+), 3 deletions(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 6c32607..f33ced8 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -350,9 +350,13 @@ int batadv_hardif_enable_interface(struct batadv_hard_iface *hard_iface,
 	hard_iface->soft_iface = soft_iface;
 	bat_priv = netdev_priv(hard_iface->soft_iface);
 
+	ret = netdev_master_upper_dev_link(hard_iface->net_dev, soft_iface);
+	if (ret)
+		goto err_dev;
+
 	ret = bat_priv->bat_algo_ops->bat_iface_enable(hard_iface);
 	if (ret < 0)
-		goto err_dev;
+		goto err_upper;
 
 	hard_iface->if_num = bat_priv->num_ifaces;
 	bat_priv->num_ifaces++;
@@ -362,7 +366,7 @@ int batadv_hardif_enable_interface(struct batadv_hard_iface *hard_iface,
 		bat_priv->bat_algo_ops->bat_iface_disable(hard_iface);
 		bat_priv->num_ifaces--;
 		hard_iface->if_status = BATADV_IF_NOT_IN_USE;
-		goto err_dev;
+		goto err_upper;
 	}
 
 	hard_iface->batman_adv_ptype.type = ethertype;
@@ -401,7 +405,10 @@ int batadv_hardif_enable_interface(struct batadv_hard_iface *hard_iface,
 out:
 	return 0;
 
+err_upper:
+	netdev_upper_dev_unlink(hard_iface->net_dev, soft_iface);
 err_dev:
+	hard_iface->soft_iface = NULL;
 	dev_put(soft_iface);
 err:
 	batadv_hardif_free_ref(hard_iface);
@@ -450,6 +457,7 @@ void batadv_hardif_disable_interface(struct batadv_hard_iface *hard_iface,
 	if (!bat_priv->num_ifaces && autodel == BATADV_IF_CLEANUP_AUTO)
 		batadv_softif_destroy_sysfs(hard_iface->soft_iface);
 
+	netdev_upper_dev_unlink(hard_iface->net_dev, hard_iface->soft_iface);
 	hard_iface->soft_iface = NULL;
 	batadv_hardif_free_ref(hard_iface);
 
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 545c863..403b8c4 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -509,6 +509,58 @@ free_bat_counters:
 	return ret;
 }
 
+/**
+ * batadv_softif_slave_add - Add a slave interface to a batadv_soft_interface
+ * @dev: batadv_soft_interface used as master interface
+ * @slave_dev: net_device which should become the slave interface
+ *
+ * Return 0 if successful or error otherwise.
+ */
+static int batadv_softif_slave_add(struct net_device *dev,
+				   struct net_device *slave_dev)
+{
+	struct batadv_hard_iface *hard_iface;
+	int ret = -EINVAL;
+
+	hard_iface = batadv_hardif_get_by_netdev(slave_dev);
+	if (!hard_iface || hard_iface->soft_iface != NULL)
+		goto out;
+
+	ret = batadv_hardif_enable_interface(hard_iface, dev->name);
+
+out:
+	if (hard_iface)
+		batadv_hardif_free_ref(hard_iface);
+	return ret;
+}
+
+/**
+ * batadv_softif_slave_del - Delete a slave iface from a batadv_soft_interface
+ * @dev: batadv_soft_interface used as master interface
+ * @slave_dev: net_device which should be removed from the master interface
+ *
+ * Return 0 if successful or error otherwise.
+ */
+static int batadv_softif_slave_del(struct net_device *dev,
+				   struct net_device *slave_dev)
+{
+	struct batadv_hard_iface *hard_iface;
+	int ret = -EINVAL;
+
+	hard_iface = batadv_hardif_get_by_netdev(slave_dev);
+
+	if (!hard_iface || hard_iface->soft_iface != dev)
+		goto out;
+
+	batadv_hardif_disable_interface(hard_iface, BATADV_IF_CLEANUP_KEEP);
+	ret = 0;
+
+out:
+	if (hard_iface)
+		batadv_hardif_free_ref(hard_iface);
+	return ret;
+}
+
 static const struct net_device_ops batadv_netdev_ops = {
 	.ndo_init = batadv_softif_init_late,
 	.ndo_open = batadv_interface_open,
@@ -517,7 +569,9 @@ static const struct net_device_ops batadv_netdev_ops = {
 	.ndo_set_mac_address = batadv_interface_set_mac_addr,
 	.ndo_change_mtu = batadv_interface_change_mtu,
 	.ndo_start_xmit = batadv_interface_tx,
-	.ndo_validate_addr = eth_validate_addr
+	.ndo_validate_addr = eth_validate_addr,
+	.ndo_add_slave = batadv_softif_slave_add,
+	.ndo_del_slave = batadv_softif_slave_del,
 };
 
 /**
-- 
1.8.1.5
