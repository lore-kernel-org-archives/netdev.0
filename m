From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 02/11] batman-adv: Move soft-interface initialization to ndo_init
Date: Thu, 28 Mar 2013 08:50:22 +0100
Message-ID: <1364457031-3194-3-git-send-email-ordex@autistici.org>
References: <1364457031-3194-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from diserzione.investici.org ([82.221.99.153]:33262 "EHLO
	diserzione.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756354Ab3C1HwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 03:52:08 -0400
In-Reply-To: <1364457031-3194-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The initialization of an net_device object should be done in the
init/constructor function and not from the outside after the register_netdevice
was done to avoid race conditions.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Acked-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/hard-interface.c |   5 ++
 net/batman-adv/soft-interface.c | 169 +++++++++++++++++++---------------------
 2 files changed, 86 insertions(+), 88 deletions(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 368219e..da000e9 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -563,6 +563,11 @@ static int batadv_hard_if_event(struct notifier_block *this,
 	struct batadv_hard_iface *primary_if = NULL;
 	struct batadv_priv *bat_priv;
 
+	if (batadv_softif_is_valid(net_dev) && event == NETDEV_REGISTER) {
+		batadv_sysfs_add_meshif(net_dev);
+		return NOTIFY_DONE;
+	}
+
 	hard_iface = batadv_hardif_get_by_netdev(net_dev);
 	if (!hard_iface && event == NETDEV_REGISTER)
 		hard_iface = batadv_hardif_add_interface(net_dev);
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index f93ae42..c5cb0a7 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -402,55 +402,6 @@ static void batadv_set_lockdep_class(struct net_device *dev)
 }
 
 /**
- * batadv_softif_init - Late stage initialization of soft interface
- * @dev: registered network device to modify
- *
- * Returns error code on failures
- */
-static int batadv_softif_init(struct net_device *dev)
-{
-	batadv_set_lockdep_class(dev);
-
-	return 0;
-}
-
-static const struct net_device_ops batadv_netdev_ops = {
-	.ndo_init = batadv_softif_init,
-	.ndo_open = batadv_interface_open,
-	.ndo_stop = batadv_interface_release,
-	.ndo_get_stats = batadv_interface_stats,
-	.ndo_set_mac_address = batadv_interface_set_mac_addr,
-	.ndo_change_mtu = batadv_interface_change_mtu,
-	.ndo_start_xmit = batadv_interface_tx,
-	.ndo_validate_addr = eth_validate_addr
-};
-
-static void batadv_interface_setup(struct net_device *dev)
-{
-	struct batadv_priv *priv = netdev_priv(dev);
-
-	ether_setup(dev);
-
-	dev->netdev_ops = &batadv_netdev_ops;
-	dev->destructor = free_netdev;
-	dev->tx_queue_len = 0;
-
-	/* can't call min_mtu, because the needed variables
-	 * have not been initialized yet
-	 */
-	dev->mtu = ETH_DATA_LEN;
-	/* reserve more space in the skbuff for our header */
-	dev->hard_header_len = BATADV_HEADER_LEN;
-
-	/* generate random address */
-	eth_hw_addr_random(dev);
-
-	SET_ETHTOOL_OPS(dev, &batadv_ethtool_ops);
-
-	memset(priv, 0, sizeof(*priv));
-}
-
-/**
  * batadv_softif_destroy_finish - cleans up the remains of a softif
  * @work: work queue item
  *
@@ -474,21 +425,22 @@ static void batadv_softif_destroy_finish(struct work_struct *work)
 	rtnl_unlock();
 }
 
-struct net_device *batadv_softif_create(const char *name)
+/**
+ * batadv_softif_init_late - late stage initialization of soft interface
+ * @dev: registered network device to modify
+ *
+ * Returns error code on failures
+ */
+static int batadv_softif_init_late(struct net_device *dev)
 {
-	struct net_device *soft_iface;
 	struct batadv_priv *bat_priv;
 	int ret;
 	size_t cnt_len = sizeof(uint64_t) * BATADV_CNT_NUM;
 
-	soft_iface = alloc_netdev(sizeof(*bat_priv), name,
-				  batadv_interface_setup);
+	batadv_set_lockdep_class(dev);
 
-	if (!soft_iface)
-		goto out;
-
-	bat_priv = netdev_priv(soft_iface);
-	bat_priv->soft_iface = soft_iface;
+	bat_priv = netdev_priv(dev);
+	bat_priv->soft_iface = dev;
 	INIT_WORK(&bat_priv->cleanup_work, batadv_softif_destroy_finish);
 
 	/* batadv_interface_stats() needs to be available as soon as
@@ -496,14 +448,7 @@ struct net_device *batadv_softif_create(const char *name)
 	 */
 	bat_priv->bat_counters = __alloc_percpu(cnt_len, __alignof__(uint64_t));
 	if (!bat_priv->bat_counters)
-		goto free_soft_iface;
-
-	ret = register_netdevice(soft_iface);
-	if (ret < 0) {
-		pr_err("Unable to register the batman interface '%s': %i\n",
-		       name, ret);
-		goto free_bat_counters;
-	}
+		return -ENOMEM;
 
 	atomic_set(&bat_priv->aggregated_ogms, 1);
 	atomic_set(&bat_priv->bonding, 0);
@@ -541,41 +486,89 @@ struct net_device *batadv_softif_create(const char *name)
 	bat_priv->primary_if = NULL;
 	bat_priv->num_ifaces = 0;
 
-	ret = batadv_algo_select(bat_priv, batadv_routing_algo);
-	if (ret < 0)
-		goto unreg_soft_iface;
-
 	batadv_nc_init_bat_priv(bat_priv);
 
-	ret = batadv_sysfs_add_meshif(soft_iface);
+	ret = batadv_algo_select(bat_priv, batadv_routing_algo);
 	if (ret < 0)
-		goto unreg_soft_iface;
+		goto free_bat_counters;
 
-	ret = batadv_debugfs_add_meshif(soft_iface);
+	ret = batadv_debugfs_add_meshif(dev);
 	if (ret < 0)
-		goto unreg_sysfs;
+		goto free_bat_counters;
 
-	ret = batadv_mesh_init(soft_iface);
+	ret = batadv_mesh_init(dev);
 	if (ret < 0)
 		goto unreg_debugfs;
 
-	return soft_iface;
+	return 0;
 
 unreg_debugfs:
-	batadv_debugfs_del_meshif(soft_iface);
-unreg_sysfs:
-	batadv_sysfs_del_meshif(soft_iface);
-unreg_soft_iface:
-	free_percpu(bat_priv->bat_counters);
-	unregister_netdevice(soft_iface);
-	return NULL;
-
+	batadv_debugfs_del_meshif(dev);
 free_bat_counters:
 	free_percpu(bat_priv->bat_counters);
-free_soft_iface:
-	free_netdev(soft_iface);
-out:
-	return NULL;
+
+	return ret;
+}
+
+static const struct net_device_ops batadv_netdev_ops = {
+	.ndo_init = batadv_softif_init_late,
+	.ndo_open = batadv_interface_open,
+	.ndo_stop = batadv_interface_release,
+	.ndo_get_stats = batadv_interface_stats,
+	.ndo_set_mac_address = batadv_interface_set_mac_addr,
+	.ndo_change_mtu = batadv_interface_change_mtu,
+	.ndo_start_xmit = batadv_interface_tx,
+	.ndo_validate_addr = eth_validate_addr
+};
+
+/**
+ * batadv_softif_init_early - early stage initialization of soft interface
+ * @dev: registered network device to modify
+ */
+static void batadv_softif_init_early(struct net_device *dev)
+{
+	struct batadv_priv *priv = netdev_priv(dev);
+
+	ether_setup(dev);
+
+	dev->netdev_ops = &batadv_netdev_ops;
+	dev->destructor = free_netdev;
+	dev->tx_queue_len = 0;
+
+	/* can't call min_mtu, because the needed variables
+	 * have not been initialized yet
+	 */
+	dev->mtu = ETH_DATA_LEN;
+	/* reserve more space in the skbuff for our header */
+	dev->hard_header_len = BATADV_HEADER_LEN;
+
+	/* generate random address */
+	eth_hw_addr_random(dev);
+
+	SET_ETHTOOL_OPS(dev, &batadv_ethtool_ops);
+
+	memset(priv, 0, sizeof(*priv));
+}
+
+struct net_device *batadv_softif_create(const char *name)
+{
+	struct net_device *soft_iface;
+	int ret;
+
+	soft_iface = alloc_netdev(sizeof(struct batadv_priv), name,
+				  batadv_softif_init_early);
+	if (!soft_iface)
+		return NULL;
+
+	ret = register_netdevice(soft_iface);
+	if (ret < 0) {
+		pr_err("Unable to register the batman interface '%s': %i\n",
+		       name, ret);
+		free_netdev(soft_iface);
+		return NULL;
+	}
+
+	return soft_iface;
 }
 
 void batadv_softif_destroy(struct net_device *soft_iface)
-- 
1.8.1.5
