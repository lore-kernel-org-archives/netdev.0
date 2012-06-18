From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 12/19] batman-adv: Return error codes instead of -1 on failures
Date: Mon, 18 Jun 2012 22:39:16 +0200
Message-ID: <1340051963-14836-13-git-send-email-ordex@autistici.org>
References: <1340051963-14836-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:41482 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753356Ab2FRUjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2012 16:39:13 -0400
In-Reply-To: <1340051963-14836-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_debugfs.c           |   11 +++++++----
 net/batman-adv/bat_iv_ogm.c            |    2 +-
 net/batman-adv/bat_sysfs.c             |    2 +-
 net/batman-adv/bridge_loop_avoidance.c |    6 +++---
 net/batman-adv/hard-interface.c        |    4 +---
 net/batman-adv/icmp_socket.c           |    4 ++--
 net/batman-adv/main.c                  |   27 ++++++++++++++++-----------
 net/batman-adv/originator.c            |   18 +++++++++---------
 net/batman-adv/translation-table.c     |   24 ++++++++++++++----------
 net/batman-adv/vis.c                   |    8 ++++----
 10 files changed, 58 insertions(+), 48 deletions(-)

diff --git a/net/batman-adv/bat_debugfs.c b/net/batman-adv/bat_debugfs.c
index 3b588f8..db8273c 100644
--- a/net/batman-adv/bat_debugfs.c
+++ b/net/batman-adv/bat_debugfs.c
@@ -195,13 +195,13 @@ static int debug_log_setup(struct bat_priv *bat_priv)
 
 	d = debugfs_create_file("log", S_IFREG | S_IRUSR,
 				bat_priv->debug_dir, bat_priv, &log_fops);
-	if (d)
+	if (!d)
 		goto err;
 
 	return 0;
 
 err:
-	return 1;
+	return -ENOMEM;
 }
 
 static void debug_log_cleanup(struct bat_priv *bat_priv)
@@ -348,8 +348,11 @@ int debugfs_add_meshif(struct net_device *dev)
 	if (!bat_priv->debug_dir)
 		goto out;
 
-	bat_socket_setup(bat_priv);
-	debug_log_setup(bat_priv);
+	if (bat_socket_setup(bat_priv) < 0)
+		goto rem_attr;
+
+	if (debug_log_setup(bat_priv) < 0)
+		goto rem_attr;
 
 	for (bat_debug = mesh_debuginfos; *bat_debug; ++bat_debug) {
 		file = debugfs_create_file(((*bat_debug)->attr).name,
diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 56b6d78..896287e 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -60,7 +60,7 @@ static int bat_iv_ogm_iface_enable(struct hard_iface *hard_iface)
 {
 	struct batman_ogm_packet *batman_ogm_packet;
 	uint32_t random_seqno;
-	int res = -1;
+	int res = -ENOMEM;
 
 	/* randomize initial seqno to avoid collision */
 	get_random_bytes(&random_seqno, sizeof(random_seqno));
diff --git a/net/batman-adv/bat_sysfs.c b/net/batman-adv/bat_sysfs.c
index 5bc7b66..62f4f6c 100644
--- a/net/batman-adv/bat_sysfs.c
+++ b/net/batman-adv/bat_sysfs.c
@@ -680,7 +680,7 @@ void sysfs_del_hardif(struct kobject **hardif_obj)
 int throw_uevent(struct bat_priv *bat_priv, enum uev_type type,
 		 enum uev_action action, const char *data)
 {
-	int ret = -1;
+	int ret = -ENOMEM;
 	struct hard_iface *primary_if = NULL;
 	struct kobject *bat_kobj;
 	char *uevent_env[4] = { NULL, NULL, NULL, NULL };
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 0355c48..314e37b 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -1164,13 +1164,13 @@ int bla_init(struct bat_priv *bat_priv)
 	bat_priv->bcast_duplist_curr = 0;
 
 	if (bat_priv->claim_hash)
-		return 1;
+		return 0;
 
 	bat_priv->claim_hash = hash_new(128);
 	bat_priv->backbone_hash = hash_new(32);
 
 	if (!bat_priv->claim_hash || !bat_priv->backbone_hash)
-		return -1;
+		return -ENOMEM;
 
 	batadv_hash_set_lock_class(bat_priv->claim_hash,
 				   &claim_hash_lock_class_key);
@@ -1180,7 +1180,7 @@ int bla_init(struct bat_priv *bat_priv)
 	bat_dbg(DBG_BLA, bat_priv, "bla hashes initialized\n");
 
 	bla_start_timer(bat_priv);
-	return 1;
+	return 0;
 }
 
 /**
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index dc334fa..ce78c6d 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -306,10 +306,8 @@ int hardif_enable_interface(struct hard_iface *hard_iface,
 	bat_priv = netdev_priv(hard_iface->soft_iface);
 
 	ret = bat_priv->bat_algo_ops->bat_iface_enable(hard_iface);
-	if (ret < 0) {
-		ret = -ENOMEM;
+	if (ret < 0)
 		goto err_dev;
-	}
 
 	hard_iface->if_num = bat_priv->num_ifaces;
 	bat_priv->num_ifaces++;
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index 2e98a57..d27db81 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -285,13 +285,13 @@ int bat_socket_setup(struct bat_priv *bat_priv)
 
 	d = debugfs_create_file(ICMP_SOCKET, S_IFREG | S_IWUSR | S_IRUSR,
 				bat_priv->debug_dir, bat_priv, &fops);
-	if (d)
+	if (!d)
 		goto err;
 
 	return 0;
 
 err:
-	return 1;
+	return -ENOMEM;
 }
 
 static void bat_socket_add_packet(struct socket_client *socket_client,
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 8610b5c..46ba302 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -92,6 +92,7 @@ static void __exit batman_exit(void)
 int mesh_init(struct net_device *soft_iface)
 {
 	struct bat_priv *bat_priv = netdev_priv(soft_iface);
+	int ret;
 
 	spin_lock_init(&bat_priv->forw_bat_list_lock);
 	spin_lock_init(&bat_priv->forw_bcast_list_lock);
@@ -110,30 +111,32 @@ int mesh_init(struct net_device *soft_iface)
 	INIT_LIST_HEAD(&bat_priv->tt_req_list);
 	INIT_LIST_HEAD(&bat_priv->tt_roam_list);
 
-	if (originator_init(bat_priv) < 1)
+	ret = originator_init(bat_priv);
+	if (ret < 0)
 		goto err;
 
-	if (tt_init(bat_priv) < 1)
+	ret = tt_init(bat_priv);
+	if (ret < 0)
 		goto err;
 
 	tt_local_add(soft_iface, soft_iface->dev_addr, NULL_IFINDEX);
 
-	if (vis_init(bat_priv) < 1)
+	ret = vis_init(bat_priv);
+	if (ret < 0)
 		goto err;
 
-	if (bla_init(bat_priv) < 1)
+	ret = bla_init(bat_priv);
+	if (ret < 0)
 		goto err;
 
 	atomic_set(&bat_priv->gw_reselect, 0);
 	atomic_set(&bat_priv->mesh_state, MESH_ACTIVE);
-	goto end;
+
+	return 0;
 
 err:
 	mesh_free(soft_iface);
-	return -1;
-
-end:
-	return 0;
+	return ret;
 }
 
 void mesh_free(struct net_device *soft_iface)
@@ -319,12 +322,13 @@ static struct bat_algo_ops *bat_algo_get(char *name)
 int bat_algo_register(struct bat_algo_ops *bat_algo_ops)
 {
 	struct bat_algo_ops *bat_algo_ops_tmp;
-	int ret = -1;
+	int ret;
 
 	bat_algo_ops_tmp = bat_algo_get(bat_algo_ops->name);
 	if (bat_algo_ops_tmp) {
 		pr_info("Trying to register already registered routing algorithm: %s\n",
 			bat_algo_ops->name);
+		ret = -EEXIST;
 		goto out;
 	}
 
@@ -337,6 +341,7 @@ int bat_algo_register(struct bat_algo_ops *bat_algo_ops)
 	    !bat_algo_ops->bat_ogm_emit) {
 		pr_info("Routing algo '%s' does not implement required ops\n",
 			bat_algo_ops->name);
+		ret = -EINVAL;
 		goto out;
 	}
 
@@ -351,7 +356,7 @@ out:
 int bat_algo_select(struct bat_priv *bat_priv, char *name)
 {
 	struct bat_algo_ops *bat_algo_ops;
-	int ret = -1;
+	int ret = -EINVAL;
 
 	bat_algo_ops = bat_algo_get(name);
 	if (!bat_algo_ops)
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 41147942..cf83c54 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -50,7 +50,7 @@ static int compare_orig(const struct hlist_node *node, const void *data2)
 int originator_init(struct bat_priv *bat_priv)
 {
 	if (bat_priv->orig_hash)
-		return 1;
+		return 0;
 
 	bat_priv->orig_hash = hash_new(1024);
 
@@ -58,10 +58,10 @@ int originator_init(struct bat_priv *bat_priv)
 		goto err;
 
 	start_purge_timer(bat_priv);
-	return 1;
+	return 0;
 
 err:
-	return 0;
+	return -ENOMEM;
 }
 
 void neigh_node_free_ref(struct neigh_node *neigh_node)
@@ -488,7 +488,7 @@ static int orig_node_add_if(struct orig_node *orig_node, int max_if_num)
 	data_ptr = kmalloc(max_if_num * sizeof(unsigned long) * NUM_WORDS,
 			   GFP_ATOMIC);
 	if (!data_ptr)
-		return -1;
+		return -ENOMEM;
 
 	memcpy(data_ptr, orig_node->bcast_own,
 	       (max_if_num - 1) * sizeof(unsigned long) * NUM_WORDS);
@@ -497,7 +497,7 @@ static int orig_node_add_if(struct orig_node *orig_node, int max_if_num)
 
 	data_ptr = kmalloc(max_if_num * sizeof(uint8_t), GFP_ATOMIC);
 	if (!data_ptr)
-		return -1;
+		return -ENOMEM;
 
 	memcpy(data_ptr, orig_node->bcast_own_sum,
 	       (max_if_num - 1) * sizeof(uint8_t));
@@ -528,7 +528,7 @@ int orig_hash_add_if(struct hard_iface *hard_iface, int max_if_num)
 			ret = orig_node_add_if(orig_node, max_if_num);
 			spin_unlock_bh(&orig_node->ogm_cnt_lock);
 
-			if (ret == -1)
+			if (ret == -ENOMEM)
 				goto err;
 		}
 		rcu_read_unlock();
@@ -554,7 +554,7 @@ static int orig_node_del_if(struct orig_node *orig_node,
 	chunk_size = sizeof(unsigned long) * NUM_WORDS;
 	data_ptr = kmalloc(max_if_num * chunk_size, GFP_ATOMIC);
 	if (!data_ptr)
-		return -1;
+		return -ENOMEM;
 
 	/* copy first part */
 	memcpy(data_ptr, orig_node->bcast_own, del_if_num * chunk_size);
@@ -573,7 +573,7 @@ free_bcast_own:
 
 	data_ptr = kmalloc(max_if_num * sizeof(uint8_t), GFP_ATOMIC);
 	if (!data_ptr)
-		return -1;
+		return -ENOMEM;
 
 	memcpy(data_ptr, orig_node->bcast_own_sum,
 	       del_if_num * sizeof(uint8_t));
@@ -612,7 +612,7 @@ int orig_hash_del_if(struct hard_iface *hard_iface, int max_if_num)
 					hard_iface->if_num);
 			spin_unlock_bh(&orig_node->ogm_cnt_lock);
 
-			if (ret == -1)
+			if (ret == -ENOMEM)
 				goto err;
 		}
 		rcu_read_unlock();
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index f9675b7..24e691d 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -181,14 +181,14 @@ int tt_len(int changes_num)
 static int tt_local_init(struct bat_priv *bat_priv)
 {
 	if (bat_priv->tt_local_hash)
-		return 1;
+		return 0;
 
 	bat_priv->tt_local_hash = hash_new(1024);
 
 	if (!bat_priv->tt_local_hash)
-		return 0;
+		return -ENOMEM;
 
-	return 1;
+	return 0;
 }
 
 void tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
@@ -491,14 +491,14 @@ static void tt_local_table_free(struct bat_priv *bat_priv)
 static int tt_global_init(struct bat_priv *bat_priv)
 {
 	if (bat_priv->tt_global_hash)
-		return 1;
+		return 0;
 
 	bat_priv->tt_global_hash = hash_new(1024);
 
 	if (!bat_priv->tt_global_hash)
-		return 0;
+		return -ENOMEM;
 
-	return 1;
+	return 0;
 }
 
 static void tt_changes_list_free(struct bat_priv *bat_priv)
@@ -1773,11 +1773,15 @@ out:
 
 int tt_init(struct bat_priv *bat_priv)
 {
-	if (!tt_local_init(bat_priv))
-		return 0;
+	int ret;
 
-	if (!tt_global_init(bat_priv))
-		return 0;
+	ret = tt_local_init(bat_priv);
+	if (ret < 0)
+		return ret;
+
+	ret = tt_global_init(bat_priv);
+	if (ret < 0)
+		return ret;
 
 	tt_start_timer(bat_priv);
 
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index cec216f..411c0e1 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -626,7 +626,7 @@ static int generate_vis_packet(struct bat_priv *bat_priv)
 		best_tq = find_best_vis_server(bat_priv, info);
 
 		if (best_tq < 0)
-			return -1;
+			return best_tq;
 	}
 
 	for (i = 0; i < hash->size; i++) {
@@ -878,7 +878,7 @@ int vis_init(struct bat_priv *bat_priv)
 	int hash_added;
 
 	if (bat_priv->vis_hash)
-		return 1;
+		return 0;
 
 	spin_lock_bh(&bat_priv->vis_hash_lock);
 
@@ -929,7 +929,7 @@ int vis_init(struct bat_priv *bat_priv)
 
 	spin_unlock_bh(&bat_priv->vis_hash_lock);
 	start_vis_timer(bat_priv);
-	return 1;
+	return 0;
 
 free_info:
 	kfree(bat_priv->my_vis_info);
@@ -937,7 +937,7 @@ free_info:
 err:
 	spin_unlock_bh(&bat_priv->vis_hash_lock);
 	vis_quit(bat_priv);
-	return 0;
+	return -ENOMEM;
 }
 
 /* Decrease the reference count on a hash item info */
-- 
1.7.9.4
