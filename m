From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 16/23 v3] mlx4_core: Multi-Function MCG support
Date: Thu, 04 Feb 2010 17:56:32 +0200
Message-ID: <4B6AEE30.30202@mellanox.co.il>
References: <49BFC313.1030901@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: general@lists.openfabrics.org, netdev@vger.kernel.org,
	liranl@mellanox.co.il, tziporet@mellanox.co.il
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:49830 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933121Ab0BDP4f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2010 10:56:35 -0500
In-Reply-To: <49BFC313.1030901@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The multicast attachment mechanism is used both by IB and Ethernet,
so we need to specify for each multicast address (whether it is gid or mac)
its protocol.
For Ethernet addresses, their VEP number should be specified. This field is
set according device capabilities. Search and hash calculation is also done
according to this field.
A Ethernet ports now need to register to the multicast groups, we can not longer
use the default multicast queue per port because of the multiple "clients" per port.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/infiniband/hw/mlx4/main.c |    6 +-
 drivers/net/mlx4/en_netdev.c      |   33 +++++++-
 drivers/net/mlx4/en_port.c        |    7 +-
 drivers/net/mlx4/en_port.h        |   11 ++-
 drivers/net/mlx4/fw.c             |    2 +
 drivers/net/mlx4/fw.h             |    2 +
 drivers/net/mlx4/main.c           |    2 +
 drivers/net/mlx4/mcg.c            |  176 +++++++++++++++++++++++--------------
 drivers/net/mlx4/port.c           |    4 +-
 include/linux/mlx4/device.h       |   14 +++-
 10 files changed, 180 insertions(+), 77 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index e596537..9fa8e1b 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -450,13 +450,15 @@ static int mlx4_ib_mcg_attach(struct ib_qp *ibqp, union ib_gid *gid, u16 lid)
 	return mlx4_multicast_attach(to_mdev(ibqp->device)->dev,
 				     &to_mqp(ibqp)->mqp, gid->raw,
 				     !!(to_mqp(ibqp)->flags &
-					MLX4_IB_QP_BLOCK_MULTICAST_LOOPBACK));
+					MLX4_IB_QP_BLOCK_MULTICAST_LOOPBACK),
+				     MLX4_PROT_IB_IPV6);
 }
 
 static int mlx4_ib_mcg_detach(struct ib_qp *ibqp, union ib_gid *gid, u16 lid)
 {
 	return mlx4_multicast_detach(to_mdev(ibqp->device)->dev,
-				     &to_mqp(ibqp)->mqp, gid->raw);
+				     &to_mqp(ibqp)->mqp, gid->raw,
+				     MLX4_PROT_IB_IPV6);
 }
 
 static int init_node_data(struct mlx4_ib_dev *dev)
diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index 2987ada..751c79d 100644
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
index c099cb4..2d55c1a 100644
--- a/drivers/net/mlx4/en_port.c
+++ b/drivers/net/mlx4/en_port.c
@@ -119,6 +119,7 @@ int mlx4_SET_PORT_qpn_calc(struct mlx4_dev *dev, u8 port, u32 base_qpn,
 	struct mlx4_set_port_rqp_calc_context *context;
 	int err;
 	u32 in_mod;
+	u32 m_promisc = (dev->caps.vep_mc_steering) ? MCAST_DIRECT : MCAST_DEFAULT;
 
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
 	if (IS_ERR(mailbox))
@@ -128,8 +129,10 @@ int mlx4_SET_PORT_qpn_calc(struct mlx4_dev *dev, u8 port, u32 base_qpn,
 
 	context->base_qpn = cpu_to_be32(base_qpn);
 	context->n_mac = 0x7;
-	context->promisc = cpu_to_be32(promisc << SET_PORT_PROMISC_SHIFT | base_qpn);
-	context->mcast = cpu_to_be32(1 << SET_PORT_PROMISC_SHIFT | base_qpn);
+	context->promisc = cpu_to_be32(promisc << SET_PORT_PROMISC_SHIFT |
+				       base_qpn);
+	context->mcast = cpu_to_be32(m_promisc << SET_PORT_MC_PROMISC_SHIFT |
+				     base_qpn);
 	context->intra_no_vlan = 0;
 	context->no_vlan = MLX4_NO_VLAN_IDX;
 	context->intra_vlan_miss = 0;
diff --git a/drivers/net/mlx4/en_port.h b/drivers/net/mlx4/en_port.h
index fc49733..f7a367b 100644
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
diff --git a/drivers/net/mlx4/fw.c b/drivers/net/mlx4/fw.c
index f797a43..6e3e1d1 100644
--- a/drivers/net/mlx4/fw.c
+++ b/drivers/net/mlx4/fw.c
@@ -329,6 +329,8 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	dev_cap->stat_rate_support = stat_rate;
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_ETH_UC_LOOPBACK_OFFSET);
 	dev_cap->loopback_support = field & 0x1;
+	dev_cap->vep_uc_steering = field & 0x4;
+	dev_cap->vep_mc_steering = field & 0x8;
 	MLX4_GET(dev_cap->flags, outbox, QUERY_DEV_CAP_FLAGS_OFFSET);
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_RSVD_UAR_OFFSET);
 	dev_cap->reserved_uars = field >> 4;
diff --git a/drivers/net/mlx4/fw.h b/drivers/net/mlx4/fw.h
index 59acfd0..e033d26 100644
--- a/drivers/net/mlx4/fw.h
+++ b/drivers/net/mlx4/fw.h
@@ -76,6 +76,8 @@ struct mlx4_dev_cap {
 	u16 eth_mtu[MLX4_MAX_PORTS + 1];
 	u16 stat_rate_support;
 	int loopback_support;
+	int vep_uc_steering;
+	int vep_mc_steering;
 	u32 flags;
 	int reserved_uars;
 	int uar_size;
diff --git a/drivers/net/mlx4/main.c b/drivers/net/mlx4/main.c
index 41e622e..d825cc1 100644
--- a/drivers/net/mlx4/main.c
+++ b/drivers/net/mlx4/main.c
@@ -245,6 +245,8 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	dev->caps.reserved_lkey	     = dev_cap->reserved_lkey;
 	dev->caps.stat_rate_support  = dev_cap->stat_rate_support;
 	dev->caps.loopback_support   = dev_cap->loopback_support;
+	dev->caps.vep_uc_steering    = dev_cap->vep_uc_steering;
+	dev->caps.vep_mc_steering    = dev_cap->vep_mc_steering;
 	dev->caps.max_gso_sz	     = dev_cap->max_gso_sz;
 
 	dev->caps.log_num_macs  = log_num_mac;
diff --git a/drivers/net/mlx4/mcg.c b/drivers/net/mlx4/mcg.c
index daa08f1..9a678d2 100644
--- a/drivers/net/mlx4/mcg.c
+++ b/drivers/net/mlx4/mcg.c
@@ -66,12 +66,12 @@ static int mlx4_WRITE_MCG(struct mlx4_dev *dev, int index,
 }
 
 static int mlx4_MGID_HASH(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox,
-			  u16 *hash)
+			  u16 *hash, u8 op_mod)
 {
 	u64 imm;
 	int err;
 
-	err = mlx4_cmd_imm(dev, mailbox->dma, &imm, 0, 0, MLX4_CMD_MGID_HASH,
+	err = mlx4_cmd_imm(dev, mailbox->dma, &imm, 0, op_mod, MLX4_CMD_MGID_HASH,
 			   MLX4_CMD_TIME_CLASS_A);
 
 	if (!err)
@@ -96,13 +96,15 @@ static int mlx4_MGID_HASH(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox
  * entry in hash chain and *mgm holds end of hash chain.
  */
 static int find_mgm(struct mlx4_dev *dev,
-		    u8 *gid, struct mlx4_cmd_mailbox *mgm_mailbox,
+		    u8 *gid, enum mlx4_protocol prot,
+		    struct mlx4_cmd_mailbox *mgm_mailbox,
 		    u16 *hash, int *prev, int *index)
 {
 	struct mlx4_cmd_mailbox *mailbox;
 	struct mlx4_mgm *mgm = mgm_mailbox->buf;
 	u8 *mgid;
 	int err;
+	u8 op_mod = (prot == MLX4_PROT_ETH) ? !!(dev->caps.vep_mc_steering) : 0;
 
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
 	if (IS_ERR(mailbox))
@@ -111,7 +113,7 @@ static int find_mgm(struct mlx4_dev *dev,
 
 	memcpy(mgid, gid, 16);
 
-	err = mlx4_MGID_HASH(dev, mailbox, hash);
+	err = mlx4_MGID_HASH(dev, mailbox, hash, op_mod);
 	mlx4_free_cmd_mailbox(dev, mailbox);
 	if (err)
 		return err;
@@ -135,8 +137,9 @@ static int find_mgm(struct mlx4_dev *dev,
 			return err;
 		}
 
-		if (!memcmp(mgm->gid, gid, 16))
-			return err;
+		if (!memcmp(mgm->gid, gid, 16) &&
+				(prot == be32_to_cpu(mgm->members_count) >> 30))
+				return err;
 
 		*prev = *index;
 		*index = be32_to_cpu(mgm->next_gid_index) >> 6;
@@ -146,47 +149,10 @@ static int find_mgm(struct mlx4_dev *dev,
 	return err;
 }
 
-int mlx4_MCAST_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
-						     struct mlx4_cmd_mailbox *inbox,
-						     struct mlx4_cmd_mailbox *outbox)
-{
-	struct mlx4_qp qp; /* dummy for calling attach/detach */
-
-	qp.qpn = vhcr->in_modifier & 0xffffff;
-	if (vhcr->op_modifier)
-		return mlx4_multicast_attach(dev, &qp, inbox->buf, vhcr->in_modifier >> 31);
-	else
-		return mlx4_multicast_detach(dev, &qp, inbox->buf);
-}
-
-static int mlx4_MCAST(struct mlx4_dev *dev, struct mlx4_qp *qp,
-					    u8 gid[16], u8 attach,
-					    u8 block_loopback)
-{
-	struct mlx4_cmd_mailbox *mailbox;
-	int err;
-	int qpn;
-
-	if (!mlx4_is_slave(dev))
-		return -EBADF;
-
-	mailbox = mlx4_alloc_cmd_mailbox(dev);
-	if (IS_ERR(mailbox))
-		return PTR_ERR(mailbox);
-
-	memcpy(mailbox->buf, gid, 16);
-	qpn = qp->qpn;
-	if (attach && block_loopback)
-		qpn |= (1 << 31);
-
-	err = mlx4_cmd(dev, mailbox->dma, qpn, attach, MLX4_CMD_MCAST_ATTACH,
-						       MLX4_CMD_TIME_CLASS_A);
-	mlx4_free_cmd_mailbox(dev, mailbox);
-	return err;
-}
-
-int mlx4_multicast_attach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
-			  int block_mcast_loopback)
+static int mlx4_multicast_attach_common(struct mlx4_dev *dev,
+					struct mlx4_qp *qp, u8 gid[16],
+					int block_mcast_loopback,
+					enum mlx4_protocol prot)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	struct mlx4_cmd_mailbox *mailbox;
@@ -198,9 +164,6 @@ int mlx4_multicast_attach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 	int i;
 	int err;
 
-	if (mlx4_is_slave(dev))
-		return mlx4_MCAST(dev, qp, gid, 1, block_mcast_loopback);
-
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
 	if (IS_ERR(mailbox))
 		return PTR_ERR(mailbox);
@@ -208,7 +171,7 @@ int mlx4_multicast_attach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 
 	mutex_lock(&priv->mcg_table.mutex);
 
-	err = find_mgm(dev, gid, mailbox, &hash, &prev, &index);
+	err = find_mgm(dev, gid, prot, mailbox, &hash, &prev, &index);
 	if (err)
 		goto out;
 
@@ -230,7 +193,7 @@ int mlx4_multicast_attach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 		memcpy(mgm->gid, gid, 16);
 	}
 
-	members_count = be32_to_cpu(mgm->members_count);
+	members_count = be32_to_cpu(mgm->members_count) & 0xffffff;
 	if (members_count == MLX4_QP_PER_MGM) {
 		mlx4_err(dev, "MGM at index %x is full.\n", index);
 		err = -ENOMEM;
@@ -250,7 +213,8 @@ int mlx4_multicast_attach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 	else
 		mgm->qp[members_count++] = cpu_to_be32(qp->qpn & MGM_QPN_MASK);
 
-	mgm->members_count       = cpu_to_be32(members_count);
+	mgm->members_count       = cpu_to_be32(members_count | ((u32) prot << 30));
+	mgm->next_gid_index	 = cpu_to_be32(!!(dev->caps.vep_mc_steering) << 4);
 
 	err = mlx4_WRITE_MCG(dev, index, mailbox);
 	if (err)
@@ -263,7 +227,8 @@ int mlx4_multicast_attach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 	if (err)
 		goto out;
 
-	mgm->next_gid_index = cpu_to_be32(index << 6);
+	mgm->next_gid_index = cpu_to_be32((index << 6) |
+					  (!!(dev->caps.vep_mc_steering) << 4));
 
 	err = mlx4_WRITE_MCG(dev, prev, mailbox);
 	if (err)
@@ -283,9 +248,10 @@ out:
 	mlx4_free_cmd_mailbox(dev, mailbox);
 	return err;
 }
-EXPORT_SYMBOL_GPL(mlx4_multicast_attach);
 
-int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16])
+static int mlx4_multicast_detach_common(struct mlx4_dev *dev,
+					struct mlx4_qp *qp, u8 gid[16],
+					enum mlx4_protocol prot)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	struct mlx4_cmd_mailbox *mailbox;
@@ -295,9 +261,7 @@ int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16])
 	int prev, index;
 	int i, loc;
 	int err;
-
-	if (mlx4_is_slave(dev))
-		return mlx4_MCAST(dev, qp, gid, 0, 0);
+	u8 pf_num = gid[7] >> 4;
 
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
 	if (IS_ERR(mailbox))
@@ -306,7 +270,7 @@ int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16])
 
 	mutex_lock(&priv->mcg_table.mutex);
 
-	err = find_mgm(dev, gid, mailbox, &hash, &prev, &index);
+	err = find_mgm(dev, gid, prot, mailbox, &hash, &prev, &index);
 	if (err)
 		goto out;
 
@@ -316,7 +280,7 @@ int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16])
 		goto out;
 	}
 
-	members_count = be32_to_cpu(mgm->members_count);
+	members_count = be32_to_cpu(mgm->members_count) & 0xffffff;
 	for (loc = -1, i = 0; i < members_count; ++i)
 		if ((be32_to_cpu(mgm->qp[i]) & MGM_QPN_MASK) == qp->qpn)
 			loc = i;
@@ -328,7 +292,7 @@ int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16])
 	}
 
 
-	mgm->members_count = cpu_to_be32(--members_count);
+	mgm->members_count = cpu_to_be32(--members_count | ((u32) prot << 30));
 	mgm->qp[loc]       = mgm->qp[i - 1];
 	mgm->qp[i - 1]     = 0;
 
@@ -344,8 +308,11 @@ int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16])
 			err = mlx4_READ_MCG(dev, amgm_index, mailbox);
 			if (err)
 				goto out;
-		} else
+		} else {
 			memset(mgm->gid, 0, 16);
+			if (prot == MLX4_PROT_ETH)
+				mgm->gid[7] = pf_num << 4;
+		}
 
 		err = mlx4_WRITE_MCG(dev, index, mailbox);
 		if (err)
@@ -361,12 +328,12 @@ int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16])
 		}
 	} else {
 		/* Remove entry from AMGM */
-		int cur_next_index = be32_to_cpu(mgm->next_gid_index) >> 6;
+		int cur_next_index = be32_to_cpu(mgm->next_gid_index);
 		err = mlx4_READ_MCG(dev, prev, mailbox);
 		if (err)
 			goto out;
 
-		mgm->next_gid_index = cpu_to_be32(cur_next_index << 6);
+		mgm->next_gid_index = cpu_to_be32(cur_next_index);
 
 		err = mlx4_WRITE_MCG(dev, prev, mailbox);
 		if (err)
@@ -386,6 +353,85 @@ out:
 	mlx4_free_cmd_mailbox(dev, mailbox);
 	return err;
 }
+
+int mlx4_MCAST_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
+						     struct mlx4_cmd_mailbox *inbox,
+						     struct mlx4_cmd_mailbox *outbox)
+{
+	struct mlx4_qp qp; /* dummy for calling attach/detach */
+	u8 *gid = inbox->buf;
+	enum mlx4_protocol prot = (vhcr->in_modifier >> 28) & 0x7;
+
+	if (prot == MLX4_PROT_ETH)
+		gid[7] = slave << 4;
+
+	qp.qpn = vhcr->in_modifier & 0xffffff;
+	if (vhcr->op_modifier)
+		return mlx4_multicast_attach_common(dev, &qp, gid,
+					     vhcr->in_modifier >> 31, prot);
+	else
+		return mlx4_multicast_detach_common(dev, &qp, gid, prot);
+}
+
+static int mlx4_MCAST(struct mlx4_dev *dev, struct mlx4_qp *qp,
+		      u8 gid[16], u8 attach, u8 block_loopback,
+		      enum mlx4_protocol prot)
+{
+	struct mlx4_cmd_mailbox *mailbox;
+	int err;
+	int qpn;
+
+	if (!mlx4_is_slave(dev))
+		return -EBADF;
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox))
+		return PTR_ERR(mailbox);
+
+	memcpy(mailbox->buf, gid, 16);
+	qpn = qp->qpn;
+	qpn |= (prot << 28);
+	if (attach && block_loopback)
+		qpn |= (1 << 31);
+
+	err = mlx4_cmd(dev, mailbox->dma, qpn, attach, MLX4_CMD_MCAST_ATTACH,
+						       MLX4_CMD_TIME_CLASS_A);
+	mlx4_free_cmd_mailbox(dev, mailbox);
+	return err;
+}
+
+
+int mlx4_multicast_attach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
+			  int block_mcast_loopback, enum mlx4_protocol prot)
+{
+	if (prot == MLX4_PROT_ETH && !dev->caps.vep_mc_steering)
+		return 0;
+
+	if (mlx4_is_slave(dev))
+		return mlx4_MCAST(dev, qp, gid, 1, block_mcast_loopback, prot);
+
+	if (mlx4_is_master(dev) && prot == MLX4_PROT_ETH)
+		gid[7] = dev->caps.function << 4;
+
+	return mlx4_multicast_attach_common(dev, qp, gid,
+					    block_mcast_loopback, prot);
+}
+EXPORT_SYMBOL_GPL(mlx4_multicast_attach);
+
+int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
+						enum mlx4_protocol prot)
+{
+	if (prot == MLX4_PROT_ETH && !dev->caps.vep_mc_steering)
+		return 0;
+
+	if (mlx4_is_slave(dev))
+		return mlx4_MCAST(dev, qp, gid, 0, 0, prot);
+
+	if (mlx4_is_master(dev) && prot == MLX4_PROT_ETH)
+		gid[7] = dev->caps.function << 4;
+
+	return mlx4_multicast_detach_common(dev, qp, gid, prot);
+}
 EXPORT_SYMBOL_GPL(mlx4_multicast_detach);
 
 int mlx4_init_mcg_table(struct mlx4_dev *dev)
diff --git a/drivers/net/mlx4/port.c b/drivers/net/mlx4/port.c
index dcbfd72..5654fff 100644
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
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 563679b..9bdfbab 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -174,6 +174,13 @@ enum mlx4_special_vlan_idx {
 	MLX4_VLAN_REGULAR
 };
 
+enum mlx4_protocol {
+	MLX4_PROT_IB_IPV6 = 0,
+	MLX4_PROT_ETH,
+	MLX4_PROT_IB_IPV4,
+	MLX4_PROT_FCOE
+};
+
 enum {
 	MLX4_NUM_FEXCH          = 64 * 1024,
 };
@@ -243,6 +250,8 @@ struct mlx4_caps {
 	u32			reserved_lkey;
 	u16			stat_rate_support;
 	int			loopback_support;
+	int			vep_uc_steering;
+	int			vep_mc_steering;
 	u8			port_width_cap[MLX4_MAX_PORTS + 1];
 	int			max_gso_sz;
 	int                     reserved_qps_cnt[MLX4_NUM_QP_REGION];
@@ -493,8 +502,9 @@ int mlx4_INIT_PORT(struct mlx4_dev *dev, int port);
 int mlx4_CLOSE_PORT(struct mlx4_dev *dev, int port);
 
 int mlx4_multicast_attach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
-			  int block_mcast_loopback);
-int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16]);
+			  int block_mcast_loopback, enum mlx4_protocol prot);
+int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
+			  enum mlx4_protocol prot);
 
 int mlx4_register_mac(struct mlx4_dev *dev, u8 port, u64 mac, int *qpn);
 void mlx4_unregister_mac(struct mlx4_dev *dev, u8 port, int qpn);
-- 
1.6.1.3


