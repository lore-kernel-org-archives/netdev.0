From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: [PATCH 1/7] batman-adv: Move soft-interface
	initialization to ndo_init
Date: Sat, 24 Nov 2012 01:02:06 +0100
Message-ID: <1353715332-4284-1-git-send-email-sven@narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

The initialization of an net_device object should be done in the
init/constructor function and not from the outside after the register_netdevice
was done to avoid race conditions.

Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
---
 net/batman-adv/hard-interface.c |    5 ++
 net/batman-adv/soft-interface.c |  147 ++++++++++++++++++---------------------
 2 files changed, 73 insertions(+), 79 deletions(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 365ed74..50f4a5c 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -542,6 +542,11 @@ static int batadv_hard_if_event(struct notifier_block *this,
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
index 54800c7..b545595 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -407,9 +407,73 @@ static void batadv_set_lockdep_class(struct net_device *dev)
  */
 static int batadv_softif_init(struct net_device *dev)
 {
+	struct batadv_priv *bat_priv;
+	int ret;
+	size_t cnt_len = sizeof(uint64_t) * BATADV_CNT_NUM;
+
 	batadv_set_lockdep_class(dev);
 
+	bat_priv = netdev_priv(dev);
+
+	/* batadv_interface_stats() needs to be available as soon as
+	 * register_netdevice() has been called
+	 */
+	bat_priv->bat_counters = __alloc_percpu(cnt_len, __alignof__(uint64_t));
+	if (!bat_priv->bat_counters)
+		return -ENOMEM;
+
+	atomic_set(&bat_priv->aggregated_ogms, 1);
+	atomic_set(&bat_priv->bonding, 0);
+	atomic_set(&bat_priv->bridge_loop_avoidance, 0);
+#ifdef CONFIG_BATMAN_ADV_DAT
+	atomic_set(&bat_priv->distributed_arp_table, 1);
+#endif
+	atomic_set(&bat_priv->ap_isolation, 0);
+	atomic_set(&bat_priv->vis_mode, BATADV_VIS_TYPE_CLIENT_UPDATE);
+	atomic_set(&bat_priv->gw_mode, BATADV_GW_MODE_OFF);
+	atomic_set(&bat_priv->gw_sel_class, 20);
+	atomic_set(&bat_priv->gw_bandwidth, 41);
+	atomic_set(&bat_priv->orig_interval, 1000);
+	atomic_set(&bat_priv->hop_penalty, 30);
+	atomic_set(&bat_priv->log_level, 0);
+	atomic_set(&bat_priv->fragmentation, 1);
+	atomic_set(&bat_priv->bcast_queue_left, BATADV_BCAST_QUEUE_LEN);
+	atomic_set(&bat_priv->batman_queue_left, BATADV_BATMAN_QUEUE_LEN);
+
+	atomic_set(&bat_priv->mesh_state, BATADV_MESH_INACTIVE);
+	atomic_set(&bat_priv->bcast_seqno, 1);
+	atomic_set(&bat_priv->tt.vn, 0);
+	atomic_set(&bat_priv->tt.local_changes, 0);
+	atomic_set(&bat_priv->tt.ogm_append_cnt, 0);
+#ifdef CONFIG_BATMAN_ADV_BLA
+	atomic_set(&bat_priv->bla.num_requests, 0);
+#endif
+	bat_priv->tt.last_changeset = NULL;
+	bat_priv->tt.last_changeset_len = 0;
+
+	bat_priv->primary_if = NULL;
+	bat_priv->num_ifaces = 0;
+
+	ret = batadv_algo_select(bat_priv, batadv_routing_algo);
+	if (ret < 0)
+		goto free_bat_counters;
+
+	ret = batadv_debugfs_add_meshif(dev);
+	if (ret < 0)
+		goto free_bat_counters;
+
+	ret = batadv_mesh_init(dev);
+	if (ret < 0)
+		goto unreg_debugfs;
+
 	return 0;
+
+unreg_debugfs:
+	batadv_debugfs_del_meshif(dev);
+free_bat_counters:
+	free_percpu(bat_priv->bat_counters);
+
+	return ret;
 }
 
 static const struct net_device_ops batadv_netdev_ops = {
@@ -451,97 +515,22 @@ static void batadv_interface_setup(struct net_device *dev)
 struct net_device *batadv_softif_create(const char *name)
 {
 	struct net_device *soft_iface;
-	struct batadv_priv *bat_priv;
 	int ret;
-	size_t cnt_len = sizeof(uint64_t) * BATADV_CNT_NUM;
 
-	soft_iface = alloc_netdev(sizeof(*bat_priv), name,
+	soft_iface = alloc_netdev(sizeof(struct batadv_priv), name,
 				  batadv_interface_setup);
-
 	if (!soft_iface)
-		goto out;
-
-	bat_priv = netdev_priv(soft_iface);
-
-	/* batadv_interface_stats() needs to be available as soon as
-	 * register_netdevice() has been called
-	 */
-	bat_priv->bat_counters = __alloc_percpu(cnt_len, __alignof__(uint64_t));
-	if (!bat_priv->bat_counters)
-		goto free_soft_iface;
+		return NULL;
 
 	ret = register_netdevice(soft_iface);
 	if (ret < 0) {
 		pr_err("Unable to register the batman interface '%s': %i\n",
 		       name, ret);
-		goto free_bat_counters;
+		free_netdev(soft_iface);
+		return NULL;
 	}
 
-	atomic_set(&bat_priv->aggregated_ogms, 1);
-	atomic_set(&bat_priv->bonding, 0);
-	atomic_set(&bat_priv->bridge_loop_avoidance, 0);
-#ifdef CONFIG_BATMAN_ADV_DAT
-	atomic_set(&bat_priv->distributed_arp_table, 1);
-#endif
-	atomic_set(&bat_priv->ap_isolation, 0);
-	atomic_set(&bat_priv->vis_mode, BATADV_VIS_TYPE_CLIENT_UPDATE);
-	atomic_set(&bat_priv->gw_mode, BATADV_GW_MODE_OFF);
-	atomic_set(&bat_priv->gw_sel_class, 20);
-	atomic_set(&bat_priv->gw_bandwidth, 41);
-	atomic_set(&bat_priv->orig_interval, 1000);
-	atomic_set(&bat_priv->hop_penalty, 30);
-	atomic_set(&bat_priv->log_level, 0);
-	atomic_set(&bat_priv->fragmentation, 1);
-	atomic_set(&bat_priv->bcast_queue_left, BATADV_BCAST_QUEUE_LEN);
-	atomic_set(&bat_priv->batman_queue_left, BATADV_BATMAN_QUEUE_LEN);
-
-	atomic_set(&bat_priv->mesh_state, BATADV_MESH_INACTIVE);
-	atomic_set(&bat_priv->bcast_seqno, 1);
-	atomic_set(&bat_priv->tt.vn, 0);
-	atomic_set(&bat_priv->tt.local_changes, 0);
-	atomic_set(&bat_priv->tt.ogm_append_cnt, 0);
-#ifdef CONFIG_BATMAN_ADV_BLA
-	atomic_set(&bat_priv->bla.num_requests, 0);
-#endif
-	bat_priv->tt.last_changeset = NULL;
-	bat_priv->tt.last_changeset_len = 0;
-
-	bat_priv->primary_if = NULL;
-	bat_priv->num_ifaces = 0;
-
-	ret = batadv_algo_select(bat_priv, batadv_routing_algo);
-	if (ret < 0)
-		goto unreg_soft_iface;
-
-	ret = batadv_sysfs_add_meshif(soft_iface);
-	if (ret < 0)
-		goto unreg_soft_iface;
-
-	ret = batadv_debugfs_add_meshif(soft_iface);
-	if (ret < 0)
-		goto unreg_sysfs;
-
-	ret = batadv_mesh_init(soft_iface);
-	if (ret < 0)
-		goto unreg_debugfs;
-
 	return soft_iface;
-
-unreg_debugfs:
-	batadv_debugfs_del_meshif(soft_iface);
-unreg_sysfs:
-	batadv_sysfs_del_meshif(soft_iface);
-unreg_soft_iface:
-	free_percpu(bat_priv->bat_counters);
-	unregister_netdevice(soft_iface);
-	return NULL;
-
-free_bat_counters:
-	free_percpu(bat_priv->bat_counters);
-free_soft_iface:
-	free_netdev(soft_iface);
-out:
-	return NULL;
 }
 
 void batadv_softif_destroy(struct net_device *soft_iface)
-- 
1.7.10.4
