From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 07/13] net/mlx4_core: Allocate default counter per port
Date: Mon, 15 Jun 2015 17:59:02 +0300
Message-ID: <1434380348-19005-8-git-send-email-ogerlitz@mellanox.com>
References: <1434380348-19005-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:45031 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755932AbbFOPAD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jun 2015 11:00:03 -0400
In-Reply-To: <1434380348-19005-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

Default counter per port will be allocated at the mlx4 core driver load.

Every QP opened by the Ethernet driver will be attached to the port's default
counter.  This is an infrastructure step to collect VF statistics from the PF.

Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c    |    5 ++
 drivers/net/ethernet/mellanox/mlx4/en_resources.c |    2 +-
 drivers/net/ethernet/mellanox/mlx4/main.c         |   71 ++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h         |    1 +
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h      |    1 +
 include/linux/mlx4/device.h                       |    1 +
 6 files changed, 77 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 98efb58..048fca0 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1597,6 +1597,9 @@ int mlx4_en_start_port(struct net_device *dev)
 	}
 	mdev->mac_removed[priv->port] = 0;
 
+	priv->counter_index =
+			mlx4_get_default_counter_index(mdev->dev, priv->port);
+
 	err = mlx4_en_config_rss_steer(priv);
 	if (err) {
 		en_err(priv, "Failed configuring rss steering\n");
@@ -1755,6 +1758,7 @@ void mlx4_en_stop_port(struct net_device *dev, int detach)
 
 	/* Set port as not active */
 	priv->port_up = false;
+	priv->counter_index = MLX4_SINK_COUNTER_INDEX(mdev->dev);
 
 	/* Promsicuous mode */
 	if (mdev->dev->caps.steering_mode ==
@@ -2778,6 +2782,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 
 	priv = netdev_priv(dev);
 	memset(priv, 0, sizeof(struct mlx4_en_priv));
+	priv->counter_index = MLX4_SINK_COUNTER_INDEX(mdev->dev);
 	spin_lock_init(&priv->stats_lock);
 	INIT_WORK(&priv->rx_mode_task, mlx4_en_do_set_rx_mode);
 	INIT_WORK(&priv->watchdog_task, mlx4_en_restart);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_resources.c b/drivers/net/ethernet/mellanox/mlx4/en_resources.c
index 97bcb91..e482fa1 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_resources.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_resources.c
@@ -66,7 +66,7 @@ void mlx4_en_fill_qp_context(struct mlx4_en_priv *priv, int size, int stride,
 		context->pri_path.sched_queue |= user_prio << 3;
 		context->pri_path.feup = MLX4_FEUP_FORCE_ETH_UP;
 	}
-	context->pri_path.counter_index = MLX4_SINK_COUNTER_INDEX(mdev->dev);
+	context->pri_path.counter_index = priv->counter_index;
 	context->cqn_send = cpu_to_be32(cqn);
 	context->cqn_recv = cpu_to_be32(cqn);
 	context->db_rec_addr = cpu_to_be64(priv->res.db.dma << 2);
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 8b27bfc..4e69cf5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2219,6 +2219,47 @@ static void mlx4_cleanup_counters_table(struct mlx4_dev *dev)
 	mlx4_bitmap_cleanup(&mlx4_priv(dev)->counters_bitmap);
 }
 
+static void mlx4_cleanup_default_counters(struct mlx4_dev *dev)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	int port;
+
+	for (port = 0; port < dev->caps.num_ports; port++)
+		if (priv->def_counter[port] != -1)
+			mlx4_counter_free(dev,  priv->def_counter[port]);
+}
+
+static int mlx4_allocate_default_counters(struct mlx4_dev *dev)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	int port, err = 0;
+	u32 idx;
+
+	for (port = 0; port < dev->caps.num_ports; port++)
+		priv->def_counter[port] = -1;
+
+	for (port = 0; port < dev->caps.num_ports; port++) {
+		err = mlx4_counter_alloc(dev, &idx);
+
+		if (!err || err == -ENOSPC) {
+			priv->def_counter[port] = idx;
+		} else if (err == -ENOENT) {
+			err = 0;
+			continue;
+		} else {
+			mlx4_err(dev, "%s: failed to allocate default counter port %d err %d\n",
+				 __func__, port + 1, err);
+			mlx4_cleanup_default_counters(dev);
+			return err;
+		}
+
+		mlx4_dbg(dev, "%s: default counter index %d for port %d\n",
+			 __func__, priv->def_counter[port], port + 1);
+	}
+
+	return err;
+}
+
 int __mlx4_counter_alloc(struct mlx4_dev *dev, u32 *idx)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
@@ -2227,8 +2268,10 @@ int __mlx4_counter_alloc(struct mlx4_dev *dev, u32 *idx)
 		return -ENOENT;
 
 	*idx = mlx4_bitmap_alloc(&priv->counters_bitmap);
-	if (*idx == -1)
-		return -ENOMEM;
+	if (*idx == -1) {
+		*idx = MLX4_SINK_COUNTER_INDEX(dev);
+		return -ENOSPC;
+	}
 
 	return 0;
 }
@@ -2275,6 +2318,9 @@ void __mlx4_counter_free(struct mlx4_dev *dev, u32 idx)
 	if (!(dev->caps.flags & MLX4_DEV_CAP_FLAG_COUNTERS))
 		return;
 
+	if (idx == MLX4_SINK_COUNTER_INDEX(dev))
+		return;
+
 	__mlx4_clear_if_stat(dev, idx);
 
 	mlx4_bitmap_free(&mlx4_priv(dev)->counters_bitmap, idx, MLX4_USE_RR);
@@ -2296,6 +2342,14 @@ void mlx4_counter_free(struct mlx4_dev *dev, u32 idx)
 }
 EXPORT_SYMBOL_GPL(mlx4_counter_free);
 
+int mlx4_get_default_counter_index(struct mlx4_dev *dev, int port)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+
+	return priv->def_counter[port - 1];
+}
+EXPORT_SYMBOL_GPL(mlx4_get_default_counter_index);
+
 void mlx4_set_admin_guid(struct mlx4_dev *dev, __be64 guid, int entry, int port)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
@@ -2439,6 +2493,12 @@ static int mlx4_setup_hca(struct mlx4_dev *dev)
 		}
 	}
 
+	err = mlx4_allocate_default_counters(dev);
+	if (err) {
+		mlx4_err(dev, "Failed to allocate default counters, aborting\n");
+		goto err_counters_table_free;
+	}
+
 	if (!mlx4_is_slave(dev)) {
 		for (port = 1; port <= dev->caps.num_ports; port++) {
 			ib_port_default_caps = 0;
@@ -2470,13 +2530,16 @@ static int mlx4_setup_hca(struct mlx4_dev *dev)
 			if (err) {
 				mlx4_err(dev, "Failed to set port %d, aborting\n",
 					 port);
-				goto err_counters_table_free;
+				goto err_default_countes_free;
 			}
 		}
 	}
 
 	return 0;
 
+err_default_countes_free:
+	mlx4_cleanup_default_counters(dev);
+
 err_counters_table_free:
 	if (!mlx4_is_slave(dev))
 		mlx4_cleanup_counters_table(dev);
@@ -3212,6 +3275,7 @@ err_port:
 	for (--port; port >= 1; --port)
 		mlx4_cleanup_port_info(&priv->port[port]);
 
+	mlx4_cleanup_default_counters(dev);
 	if (!mlx4_is_slave(dev))
 		mlx4_cleanup_counters_table(dev);
 	mlx4_cleanup_qp_table(dev);
@@ -3511,6 +3575,7 @@ static void mlx4_unload_one(struct pci_dev *pdev)
 		mlx4_free_resource_tracker(dev,
 					   RES_TR_FREE_SLAVES_ONLY);
 
+	mlx4_cleanup_default_counters(dev);
 	if (!mlx4_is_slave(dev))
 		mlx4_cleanup_counters_table(dev);
 	mlx4_cleanup_qp_table(dev);
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 8d2d359..e9e94bc 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -876,6 +876,7 @@ struct mlx4_priv {
 	struct mlx4_qp_table	qp_table;
 	struct mlx4_mcg_table	mcg_table;
 	struct mlx4_bitmap	counters_bitmap;
+	int			def_counter[MLX4_MAX_PORTS];
 
 	struct mlx4_catas_err	catas_err;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index edd8fd6..f6c3e12 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -582,6 +582,7 @@ struct mlx4_en_priv {
 	int base_tx_qpn;
 	struct hlist_head mac_hash[MLX4_EN_MAC_HASH_SIZE];
 	struct hwtstamp_config hwtstamp_config;
+	u32 counter_index;
 
 #ifdef CONFIG_MLX4_EN_DCB
 	struct ieee_ets ets;
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 312c504..4820080 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -1348,6 +1348,7 @@ int mlx4_wol_write(struct mlx4_dev *dev, u64 config, int port);
 
 int mlx4_counter_alloc(struct mlx4_dev *dev, u32 *idx);
 void mlx4_counter_free(struct mlx4_dev *dev, u32 idx);
+int mlx4_get_default_counter_index(struct mlx4_dev *dev, int port);
 
 void mlx4_set_admin_guid(struct mlx4_dev *dev, __be64 guid, int entry,
 			 int port);
-- 
1.7.1
