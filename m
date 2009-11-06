From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 22/25 v2] mlx4_en: Attaching Multicast addresses
Date: Fri, 06 Nov 2009 05:10:19 +0200
Message-ID: <4AF3939B.4000407@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	liranl@mellanox.co.il, tziporet@mellanox.co.il,
	yevgenyp@mellanox.co.il
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:43278 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759079AbZKFAMo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Nov 2009 19:12:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The device attaches all the multicast addresses to it indirection QP
The multicast steering is now done through the multicast table.
If there is no match, the packet will arrive to the indirection QP
of the first function.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_netdev.c |   33 +++++++++++++++++++++++++++++++--
 drivers/net/mlx4/en_port.c   |    6 ++++--
 drivers/net/mlx4/en_port.h   |   11 +++++++++--
 drivers/net/mlx4/port.c      |    4 ++--
 4 files changed, 46 insertions(+), 8 deletions(-)

diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index 488f967..8406fbb 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -177,6 +177,7 @@ static void mlx4_en_cache_mclist(struct net_device *dev)
 	struct dev_mc_list *tmp;
 	struct dev_mc_list *plist = NULL;
 
+	mlx4_en_clear_list(dev);
 	for (mclist = dev->mc_list; mclist; mclist = mclist->next) {
 		tmp = kmalloc(sizeof(struct dev_mc_list), GFP_ATOMIC);
 		if (!tmp) {
@@ -213,6 +214,7 @@ static void mlx4_en_do_set_multicast(struct work_struct *work)
 	struct net_device *dev = priv->dev;
 	struct dev_mc_list *mclist;
 	u64 mcast_addr = 0;
+	u8 mc_list[16] = {0};
 	int err;
 
 	mutex_lock(&mdev->state_lock);
@@ -292,6 +294,12 @@ static void mlx4_en_do_set_multicast(struct work_struct *work)
 		if (err)
 			en_err(priv, "Failed disabling multicast filter\n");
 
+		/* Detach our qp from all the multicast addresses */
+		for (mclist = priv->mc_list; mclist; mclist = mclist->next) {
+			memcpy(&mc_list[10], mclist->dmi_addr, ETH_ALEN);
+			mlx4_multicast_detach(mdev->dev, &priv->rss_map.indir_qp,
+					      mc_list, MLX4_PROT_ETH);
+		}
 		/* Flush mcast filter and init it with broadcast address */
 		mlx4_SET_MCAST_FLTR(mdev->dev, priv->port, ETH_BCAST,
 				    1, MLX4_MCAST_CONFIG);
@@ -302,6 +310,9 @@ static void mlx4_en_do_set_multicast(struct work_struct *work)
 		mlx4_en_cache_mclist(dev);
 		netif_tx_unlock_bh(dev);
 		for (mclist = priv->mc_list; mclist; mclist = mclist->next) {
+			memcpy(&mc_list[10], mclist->dmi_addr, ETH_ALEN);
+			mlx4_multicast_attach(mdev->dev, &priv->rss_map.indir_qp,
+					      mc_list, 0, MLX4_PROT_ETH);
 			mcast_addr = mlx4_en_mac_to_u64(mclist->dmi_addr);
 			mlx4_SET_MCAST_FLTR(mdev->dev, priv->port,
 					    mcast_addr, 0, MLX4_MCAST_CONFIG);
@@ -310,8 +321,6 @@ static void mlx4_en_do_set_multicast(struct work_struct *work)
 					  0, MLX4_MCAST_ENABLE);
 		if (err)
 			en_err(priv, "Failed enabling multicast filter\n");
-
-		mlx4_en_clear_list(dev);
 	}
 out:
 	mutex_unlock(&mdev->state_lock);
@@ -557,6 +566,7 @@ int mlx4_en_start_port(struct net_device *dev)
 	int err = 0;
 	int i;
 	int j;
+	u8 mc_list[16] = {0};
 
 	if (priv->port_up) {
 		en_dbg(DRV, priv, "start port called while port already up\n");
@@ -669,6 +679,12 @@ int mlx4_en_start_port(struct net_device *dev)
 		goto tx_err;
 	}
 
+	/* Attach rx QP to bradcast address */
+	memset(&mc_list[10], 0xff, ETH_ALEN);
+	if (mlx4_multicast_attach(mdev->dev, &priv->rss_map.indir_qp, mc_list,
+				  0, MLX4_PROT_ETH))
+		mlx4_warn(mdev, "Failed Attaching Broadcast\n");
+
 	/* Schedule multicast task to populate multicast list */
 	queue_work(mdev->workqueue, &priv->mcast_task);
 
@@ -699,7 +715,9 @@ void mlx4_en_stop_port(struct net_device *dev)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_en_dev *mdev = priv->mdev;
+	struct dev_mc_list *mclist;
 	int i;
+	u8 mc_list[16] = {0};
 
 	if (!priv->port_up) {
 		en_dbg(DRV, priv, "stop port called while port already down\n");
@@ -715,6 +733,17 @@ void mlx4_en_stop_port(struct net_device *dev)
 	priv->port_up = false;
 	mlx4_CLOSE_PORT(mdev->dev, priv->port);
 
+	/* Detach All multicasts */
+	memset(&mc_list[10], 0xff, ETH_ALEN);
+	mlx4_multicast_detach(mdev->dev, &priv->rss_map.indir_qp, mc_list,
+			      MLX4_PROT_ETH);
+	for (mclist = priv->mc_list; mclist; mclist = mclist->next) {
+		memcpy(&mc_list[10], mclist->dmi_addr, ETH_ALEN);
+		mlx4_multicast_detach(mdev->dev, &priv->rss_map.indir_qp,
+				      mc_list, MLX4_PROT_ETH);
+	}
+	mlx4_en_clear_list(dev);
+
 	/* Unregister Mac address for the port */
 	mlx4_unregister_mac(mdev->dev, priv->port, priv->base_qpn);
 
diff --git a/drivers/net/mlx4/en_port.c b/drivers/net/mlx4/en_port.c
index c099cb4..c7aa86e 100644
--- a/drivers/net/mlx4/en_port.c
+++ b/drivers/net/mlx4/en_port.c
@@ -128,8 +128,10 @@ int mlx4_SET_PORT_qpn_calc(struct mlx4_dev *dev, u8 port, u32 base_qpn,
 
 	context->base_qpn = cpu_to_be32(base_qpn);
 	context->n_mac = 0x7;
-	context->promisc = cpu_to_be32(promisc << SET_PORT_PROMISC_SHIFT | base_qpn);
-	context->mcast = cpu_to_be32(1 << SET_PORT_PROMISC_SHIFT | base_qpn);
+	context->promisc = cpu_to_be32(promisc << SET_PORT_PROMISC_SHIFT |
+				       base_qpn);
+	context->mcast = cpu_to_be32(MCAST_DIRECT << SET_PORT_MC_PROMISC_SHIFT |
+				     base_qpn);
 	context->intra_no_vlan = 0;
 	context->no_vlan = MLX4_NO_VLAN_IDX;
 	context->intra_vlan_miss = 0;
diff --git a/drivers/net/mlx4/en_port.h b/drivers/net/mlx4/en_port.h
index 62c9135..1e65749 100644
--- a/drivers/net/mlx4/en_port.h
+++ b/drivers/net/mlx4/en_port.h
@@ -35,8 +35,15 @@
 #define _MLX4_EN_PORT_H_
 
 
-#define SET_PORT_GEN_ALL_VALID	0x7
-#define SET_PORT_PROMISC_SHIFT	31
+#define SET_PORT_GEN_ALL_VALID		0x7
+#define SET_PORT_PROMISC_SHIFT		31
+#define SET_PORT_MC_PROMISC_SHIFT	30
+
+enum {
+	MCAST_DIRECT_ONLY	= 0,
+	MCAST_DIRECT		= 1,
+	MCAST_DEFAULT		= 2
+};
 
 
 struct mlx4_set_port_general_context {
diff --git a/drivers/net/mlx4/port.c b/drivers/net/mlx4/port.c
index 02b56ba..7317d0f 100644
--- a/drivers/net/mlx4/port.c
+++ b/drivers/net/mlx4/port.c
@@ -388,9 +388,9 @@ int mlx4_SET_PORT_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhc
 				promisc << SET_PORT_PROMISC_SHIFT |
 				port_info->base_qpn);
 			promisc = be32_to_cpu(qpn_context->mcast) >>
-				SET_PORT_PROMISC_SHIFT;
+				SET_PORT_MC_PROMISC_SHIFT;
 			qpn_context->mcast = cpu_to_be32(
-				promisc << SET_PORT_PROMISC_SHIFT |
+				promisc << SET_PORT_MC_PROMISC_SHIFT |
 				port_info->base_qpn);
 			break;
 		case MLX4_SET_PORT_GENERAL:
-- 
1.5.3.7

From: Liran Liss <liranl@mellanox.co.il>





