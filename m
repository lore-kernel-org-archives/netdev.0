From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 09/11] net/mlx4_en: Add debugfs support
Date: Wed, 30 Jan 2013 12:34:25 +0200
Message-ID: <1359542067-10760-10-git-send-email-amirv@mellanox.com>
References: <1359542067-10760-1-git-send-email-amirv@mellanox.com>
Cc: Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	Shani Michaelli <shanim@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:43475 "HELO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754392Ab3A3Keu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 05:34:50 -0500
In-Reply-To: <1359542067-10760-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shani Michaelli <shanim@mellanox.com>

Add debugfs support to the mlx4_en driver such that users have the ability to access
kernel information which can be used by external tools e.g HW monitoring ones

The filesystem is set up in the following driver/interface hierarchy:
<debugfs>
    |-- mlx4_en
     |-- <interface>
      |-- queues
       |-- rx
        |-- indir_qp
	|-- qpn_base_rx
        |-- rx_[0-9]*
	 |-- qpn_rx
	 |-- irq_rx
	 |-- cqn_rx
	 |-- eqn_rx
       |-- tx
        |-- tx_[0-9]*
	 |-- qpn_tx
	 |-- irq_tx
	 |-- cqn_tx
	 |-- eqn_tx

Signed-off-by: Shani Michaeli <shanim@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/Makefile     |    3 +
 drivers/net/ethernet/mellanox/mlx4/cq.c         |    3 +
 drivers/net/ethernet/mellanox/mlx4/en_debugfs.c |  133 +++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_main.c    |    7 ++
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |    6 +
 drivers/net/ethernet/mellanox/mlx4/en_rx.c      |    7 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |    9 ++
 include/linux/mlx4/device.h                     |    2 +
 8 files changed, 167 insertions(+), 3 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx4/en_debugfs.c

diff --git a/drivers/net/ethernet/mellanox/mlx4/Makefile b/drivers/net/ethernet/mellanox/mlx4/Makefile
index 293127d..9800aa5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/Makefile
+++ b/drivers/net/ethernet/mellanox/mlx4/Makefile
@@ -7,4 +7,7 @@ obj-$(CONFIG_MLX4_EN)               += mlx4_en.o
 
 mlx4_en-y := 	en_main.o en_tx.o en_rx.o en_ethtool.o en_port.o en_cq.o \
 		en_resources.o en_netdev.o en_selftest.o
+
+mlx4_en-$(CONFIG_DEBUG_FS) += en_debugfs.o
+
 mlx4_en-$(CONFIG_MLX4_EN_DCB) += en_dcb_nl.o
diff --git a/drivers/net/ethernet/mellanox/mlx4/cq.c b/drivers/net/ethernet/mellanox/mlx4/cq.c
index 7e64033..e6eb492 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cq.c
@@ -296,6 +296,9 @@ int mlx4_cq_alloc(struct mlx4_dev *dev, int nent, struct mlx4_mtt *mtt,
 	atomic_set(&cq->refcount, 1);
 	init_completion(&cq->free);
 
+	cq->eqn = priv->eq_table.eq[cq->vector].eqn;
+	cq->irq = priv->eq_table.eq[cq->vector].irq;
+
 	return 0;
 
 err_radix:
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_debugfs.c b/drivers/net/ethernet/mellanox/mlx4/en_debugfs.c
new file mode 100644
index 0000000..05cb1e7
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx4/en_debugfs.c
@@ -0,0 +1,133 @@
+/*
+ * Copyright (c) 2013 Mellanox Technologies. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#include "mlx4_en.h"
+#include <linux/debugfs.h>
+#include <linux/slab.h>
+
+#define MAX_DIR_NAME 100
+
+static struct dentry *mlx4_en_root;
+void mlx4_en_create_debug_files(struct mlx4_en_priv *priv)
+{
+	int i;
+	char name[MAX_DIR_NAME];
+	struct dentry *queue_root;
+	struct dentry *rx_root;
+	struct dentry *tx_root;
+	struct dentry *rx_ring_root;
+	struct dentry *tx_ring_root;
+
+	if (!mlx4_en_root)
+		return;
+	priv->dev_root = debugfs_create_dir(priv->dev->name, mlx4_en_root);
+	if (!priv->dev_root)
+		goto error;
+	queue_root = debugfs_create_dir("queues", priv->dev_root);
+	if (!queue_root)
+		goto error;
+	rx_root = debugfs_create_dir("rx", queue_root);
+	if (!rx_root)
+		goto error;
+	tx_root = debugfs_create_dir("tx", queue_root);
+	if (!tx_root)
+		goto error;
+	if (!debugfs_create_x32("indir_qp", 0444,
+				rx_root, (u32 *)&priv->rss_map.indir_qp.qpn))
+		goto error;
+	if (!debugfs_create_x32("qpn_base_rx", 0444,
+				rx_root, (u32 *)&priv->rss_map.base_qpn))
+		goto error;
+
+	for (i = 0; i < priv->rx_ring_num; i++) {
+		snprintf(name, MAX_DIR_NAME, "rx-%d", i);
+		rx_ring_root = debugfs_create_dir(name, rx_root);
+		if (!rx_ring_root)
+			goto error;
+		if (!debugfs_create_u16("cqn_rx", 0444, rx_ring_root,
+					&priv->rx_ring[i].cqn))
+			goto error;
+		if (!debugfs_create_x32("qpn_rx", 0444, rx_ring_root,
+					(u32 *)&priv->rx_ring[i].qpn))
+			goto error;
+		if (!debugfs_create_u32("eqn_rx", 0444, rx_ring_root,
+					(u32 *)&priv->rx_cq[i].mcq.eqn))
+			goto error;
+		if (!debugfs_create_u16("irq_rx", 0444, rx_ring_root,
+					&priv->rx_cq[i].mcq.irq))
+			goto error;
+	}
+
+	for (i = 0; i < priv->tx_ring_num; i++) {
+		snprintf(name, MAX_DIR_NAME, "tx-%d", i);
+		tx_ring_root = debugfs_create_dir(name, tx_root);
+		if (!tx_ring_root)
+			goto error;
+		if (!debugfs_create_u16("cqn_tx", 0444, tx_ring_root,
+					&priv->tx_ring[i].cqn))
+			goto error;
+		if (!debugfs_create_x32("qpn_tx", 0444, tx_ring_root,
+					(u32 *)&priv->tx_ring[i].qpn))
+			goto error;
+		if (!debugfs_create_u32("eqn_tx", 0444, tx_ring_root,
+					(u32 *)&priv->tx_cq[i].mcq.eqn))
+			goto error;
+		if (!debugfs_create_u16("irq_tx", 0444, tx_ring_root,
+					&priv->tx_cq[i].mcq.irq))
+			goto error;
+	}
+
+	return;
+
+error:
+	mlx4_warn(priv->mdev, "Couldn't create debugfs for %s\n",
+		  priv->dev->name);
+	mlx4_en_delete_debug_files(priv);
+	return;
+}
+
+void mlx4_en_delete_debug_files(struct mlx4_en_priv *priv)
+{
+	debugfs_remove_recursive(priv->dev_root);
+	priv->dev_root = NULL;
+}
+
+int mlx4_en_register_debugfs(void)
+{
+	mlx4_en_root = debugfs_create_dir("mlx4_en", NULL);
+	return mlx4_en_root ? 0 : PTR_ERR(mlx4_en_root);
+}
+
+void mlx4_en_unregister_debugfs(void)
+{
+	debugfs_remove_recursive(mlx4_en_root);
+}
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_main.c b/drivers/net/ethernet/mellanox/mlx4/en_main.c
index 3a2b8c6..f147c91 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_main.c
@@ -307,12 +307,19 @@ static struct mlx4_interface mlx4_en_interface = {
 
 static int __init mlx4_en_init(void)
 {
+#ifdef CONFIG_DEBUG_FS
+	if (mlx4_en_register_debugfs())
+		pr_err(KERN_ERR "Failed to register debugfs\n");
+#endif
 	return mlx4_register_interface(&mlx4_en_interface);
 }
 
 static void __exit mlx4_en_cleanup(void)
 {
 	mlx4_unregister_interface(&mlx4_en_interface);
+#ifdef CONFIG_DEBUG_FS
+	mlx4_en_unregister_debugfs();
+#endif
 }
 
 module_init(mlx4_en_init);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 333a7a0..616c3a3 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1178,6 +1178,9 @@ int mlx4_en_start_port(struct net_device *dev)
 
 	priv->port_up = true;
 	netif_tx_start_all_queues(dev);
+#ifdef CONFIG_DEBUG_FS
+	mlx4_en_create_debug_files(priv);
+#endif
 	return 0;
 
 tx_err:
@@ -1214,6 +1217,9 @@ void mlx4_en_stop_port(struct net_device *dev)
 		return;
 	}
 
+#ifdef CONFIG_DEBUG_FS
+	mlx4_en_delete_debug_files(priv);
+#endif
 	/* Synchronize with tx routine */
 	netif_tx_lock_bh(dev);
 	netif_tx_stop_all_queues(dev);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index fed26d8..5f9c13f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -912,7 +912,7 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 	void *ptr;
 	u8 rss_mask = (MLX4_RSS_IPV4 | MLX4_RSS_TCP_IPV4 | MLX4_RSS_IPV6 |
 			MLX4_RSS_TCP_IPV6);
-	int i, qpn;
+	int i;
 	int err = 0;
 	int good_qps = 0;
 	static const u32 rsskey[10] = { 0xD181C62C, 0xF7F4DB5B, 0x1983A2FC,
@@ -929,8 +929,9 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 	}
 
 	for (i = 0; i < priv->rx_ring_num; i++) {
-		qpn = rss_map->base_qpn + i;
-		err = mlx4_en_config_rss_qp(priv, qpn, &priv->rx_ring[i],
+		priv->rx_ring[i].qpn = rss_map->base_qpn + i;
+		err = mlx4_en_config_rss_qp(priv, priv->rx_ring[i].qpn,
+					    &priv->rx_ring[i],
 					    &rss_map->state[i],
 					    &rss_map->qps[i]);
 		if (err)
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 4fb4a3e..8d7a3b2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -283,6 +283,7 @@ struct mlx4_en_rx_ring {
 	u32 cons;
 	u32 buf_size;
 	u8  fcs_del;
+	int qpn;
 	void *buf;
 	void *rx_info;
 	unsigned long bytes;
@@ -512,6 +513,7 @@ struct mlx4_en_priv {
 	int vids[128];
 	bool wol;
 	struct device *ddev;
+	struct dentry *dev_root;
 	int base_tx_qpn;
 
 #ifdef CONFIG_MLX4_EN_DCB
@@ -600,6 +602,13 @@ int mlx4_SET_VLAN_FLTR(struct mlx4_dev *dev, struct mlx4_en_priv *priv);
 int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset);
 int mlx4_en_QUERY_PORT(struct mlx4_en_dev *mdev, u8 port);
 
+#ifdef CONFIG_DEBUG_FS
+void mlx4_en_create_debug_files(struct mlx4_en_priv *priv);
+void mlx4_en_delete_debug_files(struct mlx4_en_priv *priv);
+int mlx4_en_register_debugfs(void);
+void mlx4_en_unregister_debugfs(void);
+#endif
+
 #ifdef CONFIG_MLX4_EN_DCB
 extern const struct dcbnl_rtnl_ops mlx4_en_dcbnl_ops;
 #endif
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 20ea939..ae9741b 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -547,6 +547,8 @@ struct mlx4_cq {
 
 	atomic_t		refcount;
 	struct completion	free;
+	int			eqn;
+	u16			irq;
 };
 
 struct mlx4_qp {
-- 
1.7.8.2
