From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 11/17] mlx4_en: Enabling new steering
Date: Mon, 7 Mar 2011 12:17:45 +0200
Message-ID: <4D74B0C9.9020108@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<vlad@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:45006 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752546Ab1CGOPo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 09:15:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The mlx4_en module now uses the new steering mechanism.
The RX packets are now steered through the MCG table instead
of Mac table for unicast, and default entry for multicast.
The feature is enabled through INIT_HCA

Signed-off-by: Vladimir Sokolovsky <vlad@mellanox.co.il>
Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/infiniband/hw/mlx4/main.c |   16 ++++
 drivers/net/mlx4/en_netdev.c      |  133 ++++++++++++++++++++++++------
 drivers/net/mlx4/en_port.c        |   11 ++-
 drivers/net/mlx4/en_port.h        |   19 +++-
 drivers/net/mlx4/en_rx.c          |   11 +--
 drivers/net/mlx4/fw.c             |    3 +
 drivers/net/mlx4/mlx4.h           |    6 ++
 drivers/net/mlx4/mlx4_en.h        |    1 +
 drivers/net/mlx4/port.c           |  165 +++++++++++++++++++++++++++++++++---
 include/linux/mlx4/device.h       |   12 ++-
 10 files changed, 316 insertions(+), 61 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index fbe1973..ecd7c95 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -623,6 +623,14 @@ static int mlx4_ib_mcg_attach(struct ib_qp *ibqp, union ib_gid *gid, u16 lid)
 	struct mlx4_ib_dev *mdev = to_mdev(ibqp->device);
 	struct mlx4_ib_qp *mqp = to_mqp(ibqp);
 
+	if (mdev->dev->caps.vep_mc_steering && ibqp->qp_type == IB_QPT_RAW_ETHERTYPE) {
+		gid->raw[5] = mqp->port;
+
+		if (!gid->raw[5]) {
+			printk(KERN_WARNING "0 port num for raw_eth attach\n");
+			return -EINVAL;
+		}
+	}
 	err = mlx4_multicast_attach(mdev->dev, &mqp->mqp, gid->raw,
 				    !!(mqp->flags & MLX4_IB_QP_BLOCK_MULTICAST_LOOPBACK),
 				    MLX4_PROT_IB_IPV6);
@@ -665,6 +673,14 @@ static int mlx4_ib_mcg_detach(struct ib_qp *ibqp, union ib_gid *gid, u16 lid)
 	struct net_device *ndev;
 	struct mlx4_ib_gid_entry *ge;
 
+	if (mdev->dev->caps.vep_mc_steering && ibqp->qp_type == IB_QPT_RAW_ETHERTYPE) {
+		gid->raw[5] = mqp->port;
+
+		if (!gid->raw[5]) {
+			printk(KERN_WARNING "0 port num for raw_eth attach\n");
+			return -EINVAL;
+		}
+	}
 	err = mlx4_multicast_detach(mdev->dev,
 				    &mqp->mqp, gid->raw, MLX4_PROT_IB_IPV6);
 	if (err)
diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index f0d06a0..0da4b7b 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -156,9 +156,8 @@ static void mlx4_en_do_set_mac(struct work_struct *work)
 	mutex_lock(&mdev->state_lock);
 	if (priv->port_up) {
 		/* Remove old MAC and insert the new one */
-		mlx4_unregister_mac(mdev->dev, priv->port, priv->mac_index);
-		err = mlx4_register_mac(mdev->dev, priv->port,
-					priv->mac, &priv->mac_index);
+		err = mlx4_replace_mac(mdev->dev, priv->port,
+				       priv->base_qpn, priv->mac, 0);
 		if (err)
 			en_err(priv, "Failed changing HW MAC address\n");
 	} else
@@ -214,6 +213,7 @@ static void mlx4_en_do_set_multicast(struct work_struct *work)
 	struct mlx4_en_dev *mdev = priv->mdev;
 	struct net_device *dev = priv->dev;
 	u64 mcast_addr = 0;
+	u8 mc_list[16] = {0};
 	int err;
 
 	mutex_lock(&mdev->state_lock);
@@ -239,8 +239,12 @@ static void mlx4_en_do_set_multicast(struct work_struct *work)
 			priv->flags |= MLX4_EN_FLAG_PROMISC;
 
 			/* Enable promiscouos mode */
-			err = mlx4_SET_PORT_qpn_calc(mdev->dev, priv->port,
-						     priv->base_qpn, 1);
+			if (!mdev->dev->caps.vep_uc_steering)
+				err = mlx4_SET_PORT_qpn_calc(mdev->dev, priv->port,
+							     priv->base_qpn, 1);
+			else
+				err = mlx4_unicast_promisc_add(mdev->dev, priv->base_qpn,
+							       priv->port);
 			if (err)
 				en_err(priv, "Failed enabling "
 					     "promiscous mode\n");
@@ -252,10 +256,21 @@ static void mlx4_en_do_set_multicast(struct work_struct *work)
 				en_err(priv, "Failed disabling "
 					     "multicast filter\n");
 
-			/* Disable port VLAN filter */
-			err = mlx4_SET_VLAN_FLTR(mdev->dev, priv->port, NULL);
-			if (err)
-				en_err(priv, "Failed disabling VLAN filter\n");
+			/* Add the default qp number as multicast promisc */
+			if (!(priv->flags & MLX4_EN_FLAG_MC_PROMISC)) {
+				err = mlx4_multicast_promisc_add(mdev->dev, priv->base_qpn,
+								 priv->port);
+				if (err)
+					en_err(priv, "Failed entering multicast promisc mode\n");
+				priv->flags |= MLX4_EN_FLAG_MC_PROMISC;
+			}
+
+			if (priv->vlgrp) {
+				/* Disable port VLAN filter */
+				err = mlx4_SET_VLAN_FLTR(mdev->dev, priv->port, NULL);
+				if (err)
+					en_err(priv, "Failed disabling VLAN filter\n");
+			}
 		}
 		goto out;
 	}
@@ -270,11 +285,24 @@ static void mlx4_en_do_set_multicast(struct work_struct *work)
 		priv->flags &= ~MLX4_EN_FLAG_PROMISC;
 
 		/* Disable promiscouos mode */
-		err = mlx4_SET_PORT_qpn_calc(mdev->dev, priv->port,
-					     priv->base_qpn, 0);
+		if (!mdev->dev->caps.vep_uc_steering)
+			err = mlx4_SET_PORT_qpn_calc(mdev->dev, priv->port,
+						     priv->base_qpn, 0);
+		else
+			err = mlx4_unicast_promisc_remove(mdev->dev, priv->base_qpn,
+							  priv->port);
 		if (err)
 			en_err(priv, "Failed disabling promiscous mode\n");
 
+		/* Disable Multicast promisc */
+		if (priv->flags & MLX4_EN_FLAG_MC_PROMISC) {
+			err = mlx4_multicast_promisc_remove(mdev->dev, priv->base_qpn,
+							    priv->port);
+			if (err)
+				en_err(priv, "Failed disabling multicast promiscous mode\n");
+			priv->flags &= ~MLX4_EN_FLAG_MC_PROMISC;
+		}
+
 		/* Enable port VLAN filter */
 		err = mlx4_SET_VLAN_FLTR(mdev->dev, priv->port, priv->vlgrp);
 		if (err)
@@ -287,14 +315,38 @@ static void mlx4_en_do_set_multicast(struct work_struct *work)
 					  0, MLX4_MCAST_DISABLE);
 		if (err)
 			en_err(priv, "Failed disabling multicast filter\n");
+
+		/* Add the default qp number as multicast promisc */
+		if (!(priv->flags & MLX4_EN_FLAG_MC_PROMISC)) {
+			err = mlx4_multicast_promisc_add(mdev->dev, priv->base_qpn,
+							 priv->port);
+			if (err)
+				en_err(priv, "Failed entering multicast promisc mode\n");
+			priv->flags |= MLX4_EN_FLAG_MC_PROMISC;
+		}
 	} else {
 		int i;
+		/* Disable Multicast promisc */
+		if (priv->flags & MLX4_EN_FLAG_MC_PROMISC) {
+			err = mlx4_multicast_promisc_remove(mdev->dev, priv->base_qpn,
+							    priv->port);
+			if (err)
+				en_err(priv, "Failed disabling multicast promiscous mode\n");
+			priv->flags &= ~MLX4_EN_FLAG_MC_PROMISC;
+		}
 
 		err = mlx4_SET_MCAST_FLTR(mdev->dev, priv->port, 0,
 					  0, MLX4_MCAST_DISABLE);
 		if (err)
 			en_err(priv, "Failed disabling multicast filter\n");
 
+		/* Detach our qp from all the multicast addresses */
+		for (i = 0; i < priv->mc_addrs_cnt; i++) {
+			memcpy(&mc_list[10], priv->mc_addrs + i * ETH_ALEN, ETH_ALEN);
+			mc_list[5] = priv->port;
+			mlx4_multicast_detach(mdev->dev, &priv->rss_map.indir_qp,
+					      mc_list, MLX4_PROT_ETH);
+		}
 		/* Flush mcast filter and init it with broadcast address */
 		mlx4_SET_MCAST_FLTR(mdev->dev, priv->port, ETH_BCAST,
 				    1, MLX4_MCAST_CONFIG);
@@ -307,6 +359,10 @@ static void mlx4_en_do_set_multicast(struct work_struct *work)
 		for (i = 0; i < priv->mc_addrs_cnt; i++) {
 			mcast_addr =
 			      mlx4_en_mac_to_u64(priv->mc_addrs + i * ETH_ALEN);
+			memcpy(&mc_list[10], priv->mc_addrs + i * ETH_ALEN, ETH_ALEN);
+			mc_list[5] = priv->port;
+			mlx4_multicast_attach(mdev->dev, &priv->rss_map.indir_qp,
+					      mc_list, 0, MLX4_PROT_ETH);
 			mlx4_SET_MCAST_FLTR(mdev->dev, priv->port,
 					    mcast_addr, 0, MLX4_MCAST_CONFIG);
 		}
@@ -314,8 +370,6 @@ static void mlx4_en_do_set_multicast(struct work_struct *work)
 					  0, MLX4_MCAST_ENABLE);
 		if (err)
 			en_err(priv, "Failed enabling multicast filter\n");
-
-		mlx4_en_clear_list(dev);
 	}
 out:
 	mutex_unlock(&mdev->state_lock);
@@ -557,6 +611,7 @@ int mlx4_en_start_port(struct net_device *dev)
 	int err = 0;
 	int i;
 	int j;
+	u8 mc_list[16] = {0};
 	char name[32];
 
 	if (priv->port_up) {
@@ -596,10 +651,20 @@ int mlx4_en_start_port(struct net_device *dev)
 		++rx_index;
 	}
 
+	/* Set port mac number */
+	en_dbg(DRV, priv, "Setting mac for port %d\n", priv->port);
+	err = mlx4_register_mac(mdev->dev, priv->port,
+				priv->mac, &priv->base_qpn, 0);
+	if (err) {
+		en_err(priv, "Failed setting port mac\n");
+		goto cq_err;
+	}
+	mdev->mac_removed[priv->port] = 0;
+
 	err = mlx4_en_config_rss_steer(priv);
 	if (err) {
 		en_err(priv, "Failed configuring rss steering\n");
-		goto cq_err;
+		goto mac_err;
 	}
 
 	if (mdev->dev->caps.comp_pool && !priv->tx_vector) {
@@ -661,24 +726,22 @@ int mlx4_en_start_port(struct net_device *dev)
 		en_err(priv, "Failed setting default qp numbers\n");
 		goto tx_err;
 	}
-	/* Set port mac number */
-	en_dbg(DRV, priv, "Setting mac for port %d\n", priv->port);
-	err = mlx4_register_mac(mdev->dev, priv->port,
-				priv->mac, &priv->mac_index);
-	if (err) {
-		en_err(priv, "Failed setting port mac\n");
-		goto tx_err;
-	}
-	mdev->mac_removed[priv->port] = 0;
 
 	/* Init port */
 	en_dbg(HW, priv, "Initializing port\n");
 	err = mlx4_INIT_PORT(mdev->dev, priv->port);
 	if (err) {
 		en_err(priv, "Failed Initializing port\n");
-		goto mac_err;
+		goto tx_err;
 	}
 
+	/* Attach rx QP to bradcast address */
+	memset(&mc_list[10], 0xff, ETH_ALEN);
+	mc_list[5] = priv->port;
+	if (mlx4_multicast_attach(mdev->dev, &priv->rss_map.indir_qp, mc_list,
+				  0, MLX4_PROT_ETH))
+		mlx4_warn(mdev, "Failed Attaching Broadcast\n");
+
 	/* Schedule multicast task to populate multicast list */
 	queue_work(mdev->workqueue, &priv->mcast_task);
 
@@ -686,8 +749,6 @@ int mlx4_en_start_port(struct net_device *dev)
 	netif_tx_start_all_queues(dev);
 	return 0;
 
-mac_err:
-	mlx4_unregister_mac(mdev->dev, priv->port, priv->mac_index);
 tx_err:
 	while (tx_index--) {
 		mlx4_en_deactivate_tx_ring(priv, &priv->tx_ring[tx_index]);
@@ -695,6 +756,8 @@ tx_err:
 	}
 
 	mlx4_en_release_rss_steer(priv);
+mac_err:
+	mlx4_unregister_mac(mdev->dev, priv->port, priv->base_qpn);
 cq_err:
 	while (rx_index--)
 		mlx4_en_deactivate_cq(priv, &priv->rx_cq[rx_index]);
@@ -710,6 +773,7 @@ void mlx4_en_stop_port(struct net_device *dev)
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_en_dev *mdev = priv->mdev;
 	int i;
+	u8 mc_list[16] = {0};
 
 	if (!priv->port_up) {
 		en_dbg(DRV, priv, "stop port called while port already down\n");
@@ -724,8 +788,23 @@ void mlx4_en_stop_port(struct net_device *dev)
 	/* Set port as not active */
 	priv->port_up = false;
 
+	/* Detach All multicasts */
+	memset(&mc_list[10], 0xff, ETH_ALEN);
+	mc_list[5] = priv->port;
+	mlx4_multicast_detach(mdev->dev, &priv->rss_map.indir_qp, mc_list,
+			      MLX4_PROT_ETH);
+	for (i = 0; i < priv->mc_addrs_cnt; i++) {
+		memcpy(&mc_list[10], priv->mc_addrs + i * ETH_ALEN, ETH_ALEN);
+		mc_list[5] = priv->port;
+		mlx4_multicast_detach(mdev->dev, &priv->rss_map.indir_qp,
+				      mc_list, MLX4_PROT_ETH);
+	}
+	mlx4_en_clear_list(dev);
+	/* Flush multicast filter */
+	mlx4_SET_MCAST_FLTR(mdev->dev, priv->port, 0, 1, MLX4_MCAST_CONFIG);
+
 	/* Unregister Mac address for the port */
-	mlx4_unregister_mac(mdev->dev, priv->port, priv->mac_index);
+	mlx4_unregister_mac(mdev->dev, priv->port, priv->base_qpn);
 	mdev->mac_removed[priv->port] = 1;
 
 	/* Free TX Rings */
diff --git a/drivers/net/mlx4/en_port.c b/drivers/net/mlx4/en_port.c
index a2b0bc4..f2a4f5d 100644
--- a/drivers/net/mlx4/en_port.c
+++ b/drivers/net/mlx4/en_port.c
@@ -119,6 +119,10 @@ int mlx4_SET_PORT_qpn_calc(struct mlx4_dev *dev, u8 port, u32 base_qpn,
 	struct mlx4_set_port_rqp_calc_context *context;
 	int err;
 	u32 in_mod;
+	u32 m_promisc = (dev->caps.vep_mc_steering) ? MCAST_DIRECT : MCAST_DEFAULT;
+
+	if (dev->caps.vep_mc_steering && dev->caps.vep_uc_steering)
+		return 0;
 
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
 	if (IS_ERR(mailbox))
@@ -127,8 +131,11 @@ int mlx4_SET_PORT_qpn_calc(struct mlx4_dev *dev, u8 port, u32 base_qpn,
 	memset(context, 0, sizeof *context);
 
 	context->base_qpn = cpu_to_be32(base_qpn);
-	context->promisc = cpu_to_be32(promisc << SET_PORT_PROMISC_EN_SHIFT | base_qpn);
-	context->mcast = cpu_to_be32(1 << SET_PORT_PROMISC_MODE_SHIFT | base_qpn);
+	context->n_mac = 0x7;
+	context->promisc = cpu_to_be32(promisc << SET_PORT_PROMISC_SHIFT |
+				       base_qpn);
+	context->mcast = cpu_to_be32(m_promisc << SET_PORT_MC_PROMISC_SHIFT |
+				     base_qpn);
 	context->intra_no_vlan = 0;
 	context->no_vlan = MLX4_NO_VLAN_IDX;
 	context->intra_vlan_miss = 0;
diff --git a/drivers/net/mlx4/en_port.h b/drivers/net/mlx4/en_port.h
index 092e814..e3d73e4 100644
--- a/drivers/net/mlx4/en_port.h
+++ b/drivers/net/mlx4/en_port.h
@@ -36,8 +36,8 @@
 
 
 #define SET_PORT_GEN_ALL_VALID	0x7
-#define SET_PORT_PROMISC_EN_SHIFT	31
-#define SET_PORT_PROMISC_MODE_SHIFT	30
+#define SET_PORT_PROMISC_SHIFT	31
+#define SET_PORT_MC_PROMISC_SHIFT	30
 
 enum {
 	MLX4_CMD_SET_VLAN_FLTR  = 0x47,
@@ -45,6 +45,12 @@ enum {
 	MLX4_CMD_DUMP_ETH_STATS = 0x49,
 };
 
+enum {
+	MCAST_DIRECT_ONLY       = 0,
+	MCAST_DIRECT            = 1,
+	MCAST_DEFAULT           = 2
+};
+
 struct mlx4_set_port_general_context {
 	u8 reserved[3];
 	u8 flags;
@@ -60,14 +66,17 @@ struct mlx4_set_port_general_context {
 
 struct mlx4_set_port_rqp_calc_context {
 	__be32 base_qpn;
-	__be32 flags;
-	u8 reserved[3];
+	u8 rererved;
+	u8 n_mac;
+	u8 n_vlan;
+	u8 n_prio;
+	u8 reserved2[3];
 	u8 mac_miss;
 	u8 intra_no_vlan;
 	u8 no_vlan;
 	u8 intra_vlan_miss;
 	u8 vlan_miss;
-	u8 reserved2[3];
+	u8 reserved3[3];
 	u8 no_vlan_prio;
 	__be32 promisc;
 	__be32 mcast;
diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
index 570f250..05998ee 100644
--- a/drivers/net/mlx4/en_rx.c
+++ b/drivers/net/mlx4/en_rx.c
@@ -845,16 +845,10 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 	}
 
 	/* Configure RSS indirection qp */
-	err = mlx4_qp_reserve_range(mdev->dev, 1, 1, &priv->base_qpn);
-	if (err) {
-		en_err(priv, "Failed to reserve range for RSS "
-			     "indirection qp\n");
-		goto rss_err;
-	}
 	err = mlx4_qp_alloc(mdev->dev, priv->base_qpn, &rss_map->indir_qp);
 	if (err) {
 		en_err(priv, "Failed to allocate RSS indirection QP\n");
-		goto reserve_err;
+		goto rss_err;
 	}
 	rss_map->indir_qp.event = mlx4_en_sqp_event;
 	mlx4_en_fill_qp_context(priv, 0, 0, 0, 1, priv->base_qpn,
@@ -881,8 +875,6 @@ indir_err:
 		       MLX4_QP_STATE_RST, NULL, 0, 0, &rss_map->indir_qp);
 	mlx4_qp_remove(mdev->dev, &rss_map->indir_qp);
 	mlx4_qp_free(mdev->dev, &rss_map->indir_qp);
-reserve_err:
-	mlx4_qp_release_range(mdev->dev, priv->base_qpn, 1);
 rss_err:
 	for (i = 0; i < good_qps; i++) {
 		mlx4_qp_modify(mdev->dev, NULL, rss_map->state[i],
@@ -904,7 +896,6 @@ void mlx4_en_release_rss_steer(struct mlx4_en_priv *priv)
 		       MLX4_QP_STATE_RST, NULL, 0, 0, &rss_map->indir_qp);
 	mlx4_qp_remove(mdev->dev, &rss_map->indir_qp);
 	mlx4_qp_free(mdev->dev, &rss_map->indir_qp);
-	mlx4_qp_release_range(mdev->dev, priv->base_qpn, 1);
 
 	for (i = 0; i < priv->rx_ring_num; i++) {
 		mlx4_qp_modify(mdev->dev, NULL, rss_map->state[i],
diff --git a/drivers/net/mlx4/fw.c b/drivers/net/mlx4/fw.c
index 7813913..67a209b 100644
--- a/drivers/net/mlx4/fw.c
+++ b/drivers/net/mlx4/fw.c
@@ -740,6 +740,7 @@ int mlx4_INIT_HCA(struct mlx4_dev *dev, struct mlx4_init_hca_param *param)
 #define	 INIT_HCA_MC_BASE_OFFSET	 (INIT_HCA_MCAST_OFFSET + 0x00)
 #define	 INIT_HCA_LOG_MC_ENTRY_SZ_OFFSET (INIT_HCA_MCAST_OFFSET + 0x12)
 #define	 INIT_HCA_LOG_MC_HASH_SZ_OFFSET	 (INIT_HCA_MCAST_OFFSET + 0x16)
+#define  INIT_HCA_UC_STEERING_OFFSET	 (INIT_HCA_MCAST_OFFSET + 0x18)
 #define	 INIT_HCA_LOG_MC_TABLE_SZ_OFFSET (INIT_HCA_MCAST_OFFSET + 0x1b)
 #define INIT_HCA_TPT_OFFSET		 0x0f0
 #define	 INIT_HCA_DMPT_BASE_OFFSET	 (INIT_HCA_TPT_OFFSET + 0x00)
@@ -800,6 +801,8 @@ int mlx4_INIT_HCA(struct mlx4_dev *dev, struct mlx4_init_hca_param *param)
 	MLX4_PUT(inbox, param->mc_base,		INIT_HCA_MC_BASE_OFFSET);
 	MLX4_PUT(inbox, param->log_mc_entry_sz, INIT_HCA_LOG_MC_ENTRY_SZ_OFFSET);
 	MLX4_PUT(inbox, param->log_mc_hash_sz,  INIT_HCA_LOG_MC_HASH_SZ_OFFSET);
+	if (dev->caps.vep_mc_steering)
+		MLX4_PUT(inbox, (u8) (1 << 3),	INIT_HCA_UC_STEERING_OFFSET);
 	MLX4_PUT(inbox, param->log_mc_table_sz, INIT_HCA_LOG_MC_TABLE_SZ_OFFSET);
 
 	/* TPT attributes */
diff --git a/drivers/net/mlx4/mlx4.h b/drivers/net/mlx4/mlx4.h
index 1513a91..d8bb441 100644
--- a/drivers/net/mlx4/mlx4.h
+++ b/drivers/net/mlx4/mlx4.h
@@ -286,6 +286,10 @@ struct mlx4_vlan_table {
 	int			max;
 };
 
+struct mlx4_mac_entry {
+	u64 mac;
+};
+
 struct mlx4_port_info {
 	struct mlx4_dev	       *dev;
 	int			port;
@@ -293,7 +297,9 @@ struct mlx4_port_info {
 	struct device_attribute port_attr;
 	enum mlx4_port_type	tmp_type;
 	struct mlx4_mac_table	mac_table;
+	struct radix_tree_root	mac_tree;
 	struct mlx4_vlan_table	vlan_table;
+	int			base_qpn;
 };
 
 struct mlx4_sense {
diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index ad4df66..5a2c560 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -458,6 +458,7 @@ struct mlx4_en_priv {
 	struct mlx4_en_rss_map rss_map;
 	u32 flags;
 #define MLX4_EN_FLAG_PROMISC	0x1
+#define MLX4_EN_FLAG_MC_PROMISC	0x2
 	u32 tx_ring_num;
 	u32 rx_ring_num;
 	u32 rx_skb_size;
diff --git a/drivers/net/mlx4/port.c b/drivers/net/mlx4/port.c
index 4513395..eca7d85 100644
--- a/drivers/net/mlx4/port.c
+++ b/drivers/net/mlx4/port.c
@@ -90,12 +90,79 @@ static int mlx4_set_port_mac_table(struct mlx4_dev *dev, u8 port,
 	return err;
 }
 
-int mlx4_register_mac(struct mlx4_dev *dev, u8 port, u64 mac, int *index)
+static int mlx4_uc_steer_add(struct mlx4_dev *dev, u8 port,
+			     u64 mac, int *qpn, u8 reserve)
 {
-	struct mlx4_mac_table *table = &mlx4_priv(dev)->port[port].mac_table;
+	struct mlx4_qp qp;
+	u8 gid[16] = {0};
+	int err;
+
+	if (reserve) {
+		err = mlx4_qp_reserve_range(dev, 1, 1, qpn);
+		if (err) {
+			mlx4_err(dev, "Failed to reserve qp for mac registration\n");
+			return err;
+		}
+	}
+	qp.qpn = *qpn;
+
+	mac &= 0xffffffffffffULL;
+	mac = cpu_to_be64(mac << 16);
+	memcpy(&gid[10], &mac, ETH_ALEN);
+	gid[5] = port;
+	gid[7] = MLX4_UC_STEER << 1;
+
+	err = mlx4_qp_attach_common(dev, &qp, gid, 0,
+				    MLX4_PROT_ETH, MLX4_UC_STEER);
+	if (err && reserve)
+		mlx4_qp_release_range(dev, *qpn, 1);
+
+	return err;
+}
+
+static void mlx4_uc_steer_release(struct mlx4_dev *dev, u8 port,
+				  u64 mac, int qpn, u8 free)
+{
+	struct mlx4_qp qp;
+	u8 gid[16] = {0};
+
+	qp.qpn = qpn;
+	mac &= 0xffffffffffffULL;
+	mac = cpu_to_be64(mac << 16);
+	memcpy(&gid[10], &mac, ETH_ALEN);
+	gid[5] = port;
+	gid[7] = MLX4_UC_STEER << 1;
+
+	mlx4_qp_detach_common(dev, &qp, gid, MLX4_PROT_ETH, MLX4_UC_STEER);
+	if (free)
+		mlx4_qp_release_range(dev, qpn, 1);
+}
+
+int mlx4_register_mac(struct mlx4_dev *dev, u8 port, u64 mac, int *qpn, u8 wrap)
+{
+	struct mlx4_port_info *info = &mlx4_priv(dev)->port[port];
+	struct mlx4_mac_table *table = &info->mac_table;
+	struct mlx4_mac_entry *entry;
 	int i, err = 0;
 	int free = -1;
 
+	if (dev->caps.vep_uc_steering) {
+		err = mlx4_uc_steer_add(dev, port, mac, qpn, 1);
+		if (!err) {
+			entry = kmalloc(sizeof *entry, GFP_KERNEL);
+			if (!entry) {
+				mlx4_uc_steer_release(dev, port, mac, *qpn, 1);
+				return -ENOMEM;
+			}
+			entry->mac = mac;
+			err = radix_tree_insert(&info->mac_tree, *qpn, entry);
+			if (err) {
+				mlx4_uc_steer_release(dev, port, mac, *qpn, 1);
+				return err;
+			}
+		} else
+			return err;
+	}
 	mlx4_dbg(dev, "Registering MAC: 0x%llx\n", (unsigned long long) mac);
 	mutex_lock(&table->mutex);
 	for (i = 0; i < MLX4_MAX_MAC_NUM - 1; i++) {
@@ -106,7 +173,6 @@ int mlx4_register_mac(struct mlx4_dev *dev, u8 port, u64 mac, int *index)
 
 		if (mac == (MLX4_MAC_MASK & be64_to_cpu(table->entries[i]))) {
 			/* MAC already registered, increase refernce count */
-			*index = i;
 			++table->refs[i];
 			goto out;
 		}
@@ -137,7 +203,8 @@ int mlx4_register_mac(struct mlx4_dev *dev, u8 port, u64 mac, int *index)
 		goto out;
 	}
 
-	*index = free;
+	if (!dev->caps.vep_uc_steering)
+		*qpn = info->base_qpn + free;
 	++table->total;
 out:
 	mutex_unlock(&table->mutex);
@@ -145,20 +212,52 @@ out:
 }
 EXPORT_SYMBOL_GPL(mlx4_register_mac);
 
-void mlx4_unregister_mac(struct mlx4_dev *dev, u8 port, int index)
+static int validate_index(struct mlx4_dev *dev,
+			  struct mlx4_mac_table *table, int index)
 {
-	struct mlx4_mac_table *table = &mlx4_priv(dev)->port[port].mac_table;
+	int err = 0;
 
-	mutex_lock(&table->mutex);
-	if (!table->refs[index]) {
-		mlx4_warn(dev, "No MAC entry for index %d\n", index);
-		goto out;
+	if (index < 0 || index >= table->max || !table->entries[index]) {
+		mlx4_warn(dev, "No valid Mac entry for the given index\n");
+		err = -EINVAL;
 	}
-	if (--table->refs[index]) {
-		mlx4_warn(dev, "Have more references for index %d,"
-			  "no need to modify MAC table\n", index);
-		goto out;
+	return err;
+}
+
+static int find_index(struct mlx4_dev *dev,
+		      struct mlx4_mac_table *table, u64 mac)
+{
+	int i;
+	for (i = 0; i < MLX4_MAX_MAC_NUM; i++) {
+		if (mac == (MLX4_MAC_MASK & be64_to_cpu(table->entries[i])))
+			return i;
 	}
+	/* Mac not found */
+	return -EINVAL;
+}
+
+void mlx4_unregister_mac(struct mlx4_dev *dev, u8 port, int qpn)
+{
+	struct mlx4_port_info *info = &mlx4_priv(dev)->port[port];
+	struct mlx4_mac_table *table = &info->mac_table;
+	int index = qpn - info->base_qpn;
+	struct mlx4_mac_entry *entry;
+
+	if (dev->caps.vep_uc_steering) {
+		entry = radix_tree_lookup(&info->mac_tree, qpn);
+		if (entry) {
+			mlx4_uc_steer_release(dev, port, entry->mac, qpn, 1);
+			radix_tree_delete(&info->mac_tree, qpn);
+			index = find_index(dev, table, entry->mac);
+			kfree(entry);
+		}
+	}
+
+	mutex_lock(&table->mutex);
+
+	if (validate_index(dev, table, index))
+		goto out;
+
 	table->entries[index] = 0;
 	mlx4_set_port_mac_table(dev, port, table->entries);
 	--table->total;
@@ -167,6 +266,44 @@ out:
 }
 EXPORT_SYMBOL_GPL(mlx4_unregister_mac);
 
+int mlx4_replace_mac(struct mlx4_dev *dev, u8 port, int qpn, u64 new_mac, u8 wrap)
+{
+	struct mlx4_port_info *info = &mlx4_priv(dev)->port[port];
+	struct mlx4_mac_table *table = &info->mac_table;
+	int index = qpn - info->base_qpn;
+	struct mlx4_mac_entry *entry;
+	int err;
+
+	if (dev->caps.vep_uc_steering) {
+		entry = radix_tree_lookup(&info->mac_tree, qpn);
+		if (!entry)
+			return -EINVAL;
+		index = find_index(dev, table, entry->mac);
+		mlx4_uc_steer_release(dev, port, entry->mac, qpn, 0);
+		entry->mac = new_mac;
+		err = mlx4_uc_steer_add(dev, port, entry->mac, &qpn, 0);
+		if (err || index < 0)
+			return err;
+	}
+
+	mutex_lock(&table->mutex);
+
+	err = validate_index(dev, table, index);
+	if (err)
+		goto out;
+
+	table->entries[index] = cpu_to_be64(new_mac | MLX4_MAC_VALID);
+
+	err = mlx4_set_port_mac_table(dev, port, table->entries);
+	if (unlikely(err)) {
+		mlx4_err(dev, "Failed adding MAC: 0x%llx\n", (unsigned long long) new_mac);
+		table->entries[index] = 0;
+	}
+out:
+	mutex_unlock(&table->mutex);
+	return err;
+}
+EXPORT_SYMBOL_GPL(mlx4_replace_mac);
 static int mlx4_set_port_vlan_table(struct mlx4_dev *dev, u8 port,
 				    __be32 *entries)
 {
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index ebda939..56fa5e1 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -525,9 +525,15 @@ int mlx4_multicast_attach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 			  int block_mcast_loopback, enum mlx4_protocol protocol);
 int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 			  enum mlx4_protocol protocol);
-
-int mlx4_register_mac(struct mlx4_dev *dev, u8 port, u64 mac, int *index);
-void mlx4_unregister_mac(struct mlx4_dev *dev, u8 port, int index);
+int mlx4_multicast_promisc_add(struct mlx4_dev *dev, u32 qpn, u8 port);
+int mlx4_multicast_promisc_remove(struct mlx4_dev *dev, u32 qpn, u8 port);
+int mlx4_unicast_promisc_add(struct mlx4_dev *dev, u32 qpn, u8 port);
+int mlx4_unicast_promisc_remove(struct mlx4_dev *dev, u32 qpn, u8 port);
+int mlx4_SET_MCAST_FLTR(struct mlx4_dev *dev, u8 port, u64 mac, u64 clear, u8 mode);
+
+int mlx4_register_mac(struct mlx4_dev *dev, u8 port, u64 mac, int *qpn, u8 wrap);
+void mlx4_unregister_mac(struct mlx4_dev *dev, u8 port, int qpn);
+int mlx4_replace_mac(struct mlx4_dev *dev, u8 port, int qpn, u64 new_mac, u8 wrap);
 
 int mlx4_find_cached_vlan(struct mlx4_dev *dev, u8 port, u16 vid, int *idx);
 int mlx4_register_vlan(struct mlx4_dev *dev, u8 port, u16 vlan, int *index);
-- 
1.6.0.2




