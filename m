From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 12/17] mlx4: Add an ability to attach to QPs to GIDS by priority.
Date: Mon, 7 Mar 2011 12:17:51 +0200
Message-ID: <4D74B0CF.5050904@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<nirmu@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:40418 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752329Ab1CGPBN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 10:01:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add an ability to attach to QPs to GIDS by priority.
The basic flow: Upon receiving a high priority attach request,
Make sure that it is put before all other low priority entries in the same
MGM hash bucket. if a low priority entry already exists for the given GID,
we'll have two entries with the same GID, which means that the low priority
entry will be ignored.

Signed-off-by: Nir Muchtar <nirmu@mellanox.co.il>
Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/infiniband/hw/mlx4/main.c |    6 +-
 drivers/net/mlx4/en_netdev.c      |   10 +-
 drivers/net/mlx4/mcg.c            |  248 +++++++++++++++++++++++++++++++++----
 drivers/net/mlx4/mlx4.h           |    4 +-
 drivers/net/mlx4/port.c           |    4 +-
 include/linux/mlx4/device.h       |    5 +-
 6 files changed, 241 insertions(+), 36 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index ecd7c95..dc6e686 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -633,7 +633,7 @@ static int mlx4_ib_mcg_attach(struct ib_qp *ibqp, union ib_gid *gid, u16 lid)
 	}
 	err = mlx4_multicast_attach(mdev->dev, &mqp->mqp, gid->raw,
 				    !!(mqp->flags & MLX4_IB_QP_BLOCK_MULTICAST_LOOPBACK),
-				    MLX4_PROT_IB_IPV6);
+				    MLX4_PROT_IB_IPV6, 0);
 	if (err)
 		return err;
 
@@ -644,7 +644,7 @@ static int mlx4_ib_mcg_attach(struct ib_qp *ibqp, union ib_gid *gid, u16 lid)
 	return 0;
 
 err_add:
-	mlx4_multicast_detach(mdev->dev, &mqp->mqp, gid->raw, MLX4_PROT_IB_IPV6);
+	mlx4_multicast_detach(mdev->dev, &mqp->mqp, gid->raw, MLX4_PROT_IB_IPV6, 0);
 	return err;
 }
 
@@ -682,7 +682,7 @@ static int mlx4_ib_mcg_detach(struct ib_qp *ibqp, union ib_gid *gid, u16 lid)
 		}
 	}
 	err = mlx4_multicast_detach(mdev->dev,
-				    &mqp->mqp, gid->raw, MLX4_PROT_IB_IPV6);
+				    &mqp->mqp, gid->raw, MLX4_PROT_IB_IPV6, 0);
 	if (err)
 		return err;
 
diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index 0da4b7b..4a30047 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -345,7 +345,7 @@ static void mlx4_en_do_set_multicast(struct work_struct *work)
 			memcpy(&mc_list[10], priv->mc_addrs + i * ETH_ALEN, ETH_ALEN);
 			mc_list[5] = priv->port;
 			mlx4_multicast_detach(mdev->dev, &priv->rss_map.indir_qp,
-					      mc_list, MLX4_PROT_ETH);
+					      mc_list, MLX4_PROT_ETH, 0);
 		}
 		/* Flush mcast filter and init it with broadcast address */
 		mlx4_SET_MCAST_FLTR(mdev->dev, priv->port, ETH_BCAST,
@@ -362,7 +362,7 @@ static void mlx4_en_do_set_multicast(struct work_struct *work)
 			memcpy(&mc_list[10], priv->mc_addrs + i * ETH_ALEN, ETH_ALEN);
 			mc_list[5] = priv->port;
 			mlx4_multicast_attach(mdev->dev, &priv->rss_map.indir_qp,
-					      mc_list, 0, MLX4_PROT_ETH);
+					      mc_list, 0, MLX4_PROT_ETH, 0);
 			mlx4_SET_MCAST_FLTR(mdev->dev, priv->port,
 					    mcast_addr, 0, MLX4_MCAST_CONFIG);
 		}
@@ -739,7 +739,7 @@ int mlx4_en_start_port(struct net_device *dev)
 	memset(&mc_list[10], 0xff, ETH_ALEN);
 	mc_list[5] = priv->port;
 	if (mlx4_multicast_attach(mdev->dev, &priv->rss_map.indir_qp, mc_list,
-				  0, MLX4_PROT_ETH))
+				  0, MLX4_PROT_ETH, 0))
 		mlx4_warn(mdev, "Failed Attaching Broadcast\n");
 
 	/* Schedule multicast task to populate multicast list */
@@ -792,12 +792,12 @@ void mlx4_en_stop_port(struct net_device *dev)
 	memset(&mc_list[10], 0xff, ETH_ALEN);
 	mc_list[5] = priv->port;
 	mlx4_multicast_detach(mdev->dev, &priv->rss_map.indir_qp, mc_list,
-			      MLX4_PROT_ETH);
+			      MLX4_PROT_ETH, 0);
 	for (i = 0; i < priv->mc_addrs_cnt; i++) {
 		memcpy(&mc_list[10], priv->mc_addrs + i * ETH_ALEN, ETH_ALEN);
 		mc_list[5] = priv->port;
 		mlx4_multicast_detach(mdev->dev, &priv->rss_map.indir_qp,
-				      mc_list, MLX4_PROT_ETH);
+				      mc_list, MLX4_PROT_ETH, 0);
 	}
 	mlx4_en_clear_list(dev);
 	/* Flush multicast filter */
diff --git a/drivers/net/mlx4/mcg.c b/drivers/net/mlx4/mcg.c
index e71372a..5b00b15 100644
--- a/drivers/net/mlx4/mcg.c
+++ b/drivers/net/mlx4/mcg.c
@@ -43,6 +43,12 @@
 
 static const u8 zero_gid[16];	/* automatically initialized to 0 */
 
+struct mlx4_steer_prio {
+	struct list_head list;
+	int hash;
+	u32 num_high_prio;
+};
+
 static int mlx4_READ_ENTRY(struct mlx4_dev *dev, int index,
 			   struct mlx4_cmd_mailbox *mailbox)
 {
@@ -331,6 +337,25 @@ out:
 	return ret;
 }
 
+/* Adjust the index of an existing steering entry*/
+static void adjust_steering_entry(struct mlx4_dev *dev, u8 vep_num, u8 port,
+				  enum mlx4_steer_type steer,
+				  unsigned int old_index, unsigned int new_index)
+{
+	struct mlx4_steer *s_steer;
+	u8 pf_num;
+	struct mlx4_steer_index *entry;
+
+	pf_num = (dev->caps.num_ports == 1) ? vep_num : (vep_num << 1) | (port - 1);
+	s_steer = &mlx4_priv(dev)->steer[pf_num];
+	list_for_each_entry(entry, &s_steer->steer_entries[steer], list) {
+		if (entry->index == old_index) {
+			entry->index = new_index;
+			return;
+		}
+	}
+}
+
 static int add_promisc_qp(struct mlx4_dev *dev, u8 vep_num, u8 port,
 			  enum mlx4_steer_type steer, u32 qpn)
 {
@@ -533,6 +558,125 @@ out_mutex:
 	return err;
 }
 
+static int set_num_high_prio(struct mlx4_dev *dev, u8 port, int hash, int val,
+			      enum mlx4_protocol prot)
+{
+	struct mlx4_steer_prio *high_prio, *prev_high_prio;
+	struct list_head *high_prios;
+
+	if (prot != MLX4_PROT_ETH || port > dev->caps.num_ports)
+		return -EINVAL;
+
+	high_prios = &mlx4_priv(dev)->steer[port - 1].high_prios;
+	list_for_each_entry_safe(high_prio, prev_high_prio, high_prios, list) {
+		if (high_prio->hash == hash) {
+			high_prio->num_high_prio += val;
+			if (!high_prio->num_high_prio) {
+				list_del(&high_prio->list);
+				kfree(high_prio);
+			}
+			return 0;
+		}
+	}
+	high_prio = kmalloc(sizeof *high_prio, GFP_KERNEL);
+	if (!high_prio)
+		return -ENOMEM;
+	high_prio->hash = hash;
+	high_prio->num_high_prio = val;
+	list_add_tail(&high_prio->list, high_prios);
+	return 0;
+}
+
+static int inc_num_high_prio(struct mlx4_dev *dev, u8 port, int hash,
+			      enum mlx4_protocol prot)
+{
+	return set_num_high_prio(dev, port, hash, 1, prot);
+}
+
+static int dec_num_high_prio(struct mlx4_dev *dev, u8 port, int hash,
+			      enum mlx4_protocol prot)
+{
+	return set_num_high_prio(dev, port, hash, -1, prot);
+}
+
+static u32 get_num_high_prio(struct mlx4_dev *dev, u8 port, int hash,
+			     enum mlx4_protocol prot)
+{
+	struct mlx4_steer_prio *high_prio;
+	struct list_head *high_prios;
+
+	if (prot != MLX4_PROT_ETH || port > dev->caps.num_ports)
+		return 0;
+	high_prios = &mlx4_priv(dev)->steer[port - 1].high_prios;
+	list_for_each_entry(high_prio, high_prios, list) {
+		if (high_prio->hash == hash)
+			return high_prio->num_high_prio;
+	}
+	return 0;
+}
+
+/* Find and return the first MGM/AMGM entry which is not of high priority */
+/* TODO merge with find_entry */
+static int find_first_low_entry(struct mlx4_dev *dev, u8 port,
+				u8 *gid, enum mlx4_protocol prot,
+				struct mlx4_cmd_mailbox *mgm_mailbox,
+				u16 *hash, int *prev, int *index)
+{
+	struct mlx4_cmd_mailbox *mailbox;
+	struct mlx4_mgm *mgm = mgm_mailbox->buf;
+	u8 *mgid;
+	int err;
+	u8 op_mod = (prot == MLX4_PROT_ETH) ? !!(dev->caps.vep_mc_steering) : 0;
+	int high_prio_left;
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox))
+		return -ENOMEM;
+	mgid = mailbox->buf;
+
+	memcpy(mgid, gid, 16);
+
+	err = mlx4_GID_HASH(dev, mailbox, hash, op_mod);
+	mlx4_free_cmd_mailbox(dev, mailbox);
+	if (err)
+		return err;
+
+	*index = *hash;
+	*prev  = -1;
+
+	high_prio_left = get_num_high_prio(dev, port, *index, prot);
+
+	do {
+		err = mlx4_READ_ENTRY(dev, *index, mgm_mailbox);
+		if (err)
+			return err;
+
+		if (!(be32_to_cpu(mgm->members_count) & 0xffffff)) {
+			if (*index != *hash) {
+				mlx4_err(dev, "Found zero MGID in AMGM.\n");
+				err = -EINVAL;
+			} else if (high_prio_left) {
+				mlx4_err(dev, "Invalid high prio entries.\n");
+				err = -EINVAL;
+			}
+			return err;
+		}
+
+		if (!high_prio_left)
+			return err;
+
+		*prev = *index;
+		*index = be32_to_cpu(mgm->next_gid_index) >> 6;
+		high_prio_left--;
+	} while (*index);
+	if (high_prio_left) {
+		mlx4_err(dev, "Not enough high prio MGIDs in MGM.\n");
+		return -EINVAL;
+	}
+	*index = -1;
+	return err;
+}
+
 /*
  * Caller must hold MCG table semaphore.  gid and mgm parameters must
  * be properly aligned for command interface.
@@ -550,7 +694,7 @@ out_mutex:
  */
 static int find_entry(struct mlx4_dev *dev, u8 port,
 		      u8 *gid, enum mlx4_protocol prot,
-		      enum mlx4_steer_type steer,
+		      enum mlx4_steer_type steer, u8 high_prio,
 		      struct mlx4_cmd_mailbox *mgm_mailbox,
 		      u16 *hash, int *prev, int *index)
 {
@@ -559,6 +703,7 @@ static int find_entry(struct mlx4_dev *dev, u8 port,
 	u8 *mgid;
 	int err;
 	u8 op_mod = (prot == MLX4_PROT_ETH) ? !!(dev->caps.vep_mc_steering) : 0;
+	int high_prio_left = 0;
 
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
 	if (IS_ERR(mailbox))
@@ -578,6 +723,11 @@ static int find_entry(struct mlx4_dev *dev, u8 port,
 	*index = *hash;
 	*prev  = -1;
 
+	/* We distinguish low from high priority entries by keeping the high
+	   entries before the low entries and saving their number */
+
+	high_prio_left = get_num_high_prio(dev, port, *hash, prot);
+
 	do {
 		err = mlx4_READ_ENTRY(dev, *index, mgm_mailbox);
 		if (err)
@@ -592,11 +742,14 @@ static int find_entry(struct mlx4_dev *dev, u8 port,
 		}
 
 		if (!memcmp(mgm->gid, gid, 16) &&
-		    be32_to_cpu(mgm->members_count) >> 30 == prot)
+		    (be32_to_cpu(mgm->members_count) >> 30 == prot) &&
+		    ((high_prio && high_prio_left > 0) ||
+		     (!high_prio && high_prio_left <= 0)))
 			return err;
 
 		*prev = *index;
 		*index = be32_to_cpu(mgm->next_gid_index) >> 6;
+		high_prio_left--;
 	} while (*index);
 
 	*index = -1;
@@ -605,19 +758,21 @@ static int find_entry(struct mlx4_dev *dev, u8 port,
 
 int mlx4_qp_attach_common(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 			  int block_mcast_loopback, enum mlx4_protocol prot,
-			  enum mlx4_steer_type steer)
+			  enum mlx4_steer_type steer, u8 high_prio)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
-	struct mlx4_cmd_mailbox *mailbox;
-	struct mlx4_mgm *mgm;
+	struct mlx4_cmd_mailbox *mailbox, *low_mailbox = NULL;
+	struct mlx4_mgm *mgm, *low_mgm;
 	u32 members_count;
 	u16 hash;
 	int index, prev;
+	int low_index = -1, low_prev;
 	int link = 0;
 	int i;
 	int err;
 	u8 port = gid[5];
 	u8 new_entry = 0;
+	u8 low_to_high = 0;
 
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
 	if (IS_ERR(mailbox))
@@ -625,7 +780,7 @@ int mlx4_qp_attach_common(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 	mgm = mailbox->buf;
 
 	mutex_lock(&priv->mcg_table.mutex);
-	err = find_entry(dev, port, gid, prot, steer,
+	err = find_entry(dev, port, gid, prot, steer, high_prio,
 			 mailbox, &hash, &prev, &index);
 	if (err)
 		goto out;
@@ -637,6 +792,7 @@ int mlx4_qp_attach_common(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 		}
 	} else {
 		link = 1;
+		new_entry = 1;
 
 		index = mlx4_bitmap_alloc(&priv->mcg_table.bitmap);
 		if (index == -1) {
@@ -648,31 +804,68 @@ int mlx4_qp_attach_common(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 
 		memset(mgm, 0, sizeof *mgm);
 		memcpy(mgm->gid, gid, 16);
+
+		/* if High priority attach was requested, we want to keep it
+		   before low entries, so we take the first low priority entry
+		   and swap it for our newly created entry (which is last) */
+		if (high_prio) {
+			mlx4_dbg(dev, "High priority steer was requested\n");
+			low_mailbox = mlx4_alloc_cmd_mailbox(dev);
+			if (IS_ERR(low_mailbox)) {
+				err = PTR_ERR(low_mailbox);
+				low_mailbox = NULL;
+				goto out;
+			}
+			err = find_first_low_entry(dev, port, gid, prot,
+						   low_mailbox, &hash,
+						   &low_prev, &low_index);
+			if (!err && low_index != -1) {
+				low_to_high = 1;
+				low_mgm = low_mailbox->buf;
+				mlx4_dbg(dev, "Found a low prio steering entry. Switching entries\n");
+				memcpy(mgm->gid, low_mgm->gid, 16);
+				mgm->members_count = low_mgm->members_count;
+				memcpy(mgm->qp, low_mgm->qp,
+				       (be32_to_cpu(mgm->members_count) & 0xffffff) * sizeof low_mgm->qp[0]);
+				low_mgm->members_count = 0;
+				memcpy(low_mgm->gid, gid, 16);
+				err = mlx4_WRITE_ENTRY(dev, index, mailbox);
+				if (err)
+					goto out;
+				adjust_steering_entry(dev, 0, port, steer, low_index, index);
+			}
+		}
 	}
 
-	members_count = be32_to_cpu(mgm->members_count) & 0xffffff;
+	if (!low_to_high) {
+		low_mgm = mgm;
+		low_index = index;
+		low_mailbox = mailbox;
+	}
+
+	members_count = be32_to_cpu(low_mgm->members_count) & 0xffffff;
 	if (members_count == MLX4_QP_PER_MGM) {
-		mlx4_err(dev, "MGM at index %x is full.\n", index);
+		mlx4_err(dev, "MGM at index %x is full.\n", low_index);
 		err = -ENOMEM;
 		goto out;
 	}
 
 	for (i = 0; i < members_count; ++i)
-		if ((be32_to_cpu(mgm->qp[i]) & MGM_QPN_MASK) == qp->qpn) {
+		if ((be32_to_cpu(low_mgm->qp[i]) & MGM_QPN_MASK) == qp->qpn) {
 			mlx4_dbg(dev, "QP %06x already a member of MGM\n", qp->qpn);
 			err = 0;
 			goto out;
 		}
 
 	if (block_mcast_loopback)
-		mgm->qp[members_count++] = cpu_to_be32((qp->qpn & MGM_QPN_MASK) |
+		low_mgm->qp[members_count++] = cpu_to_be32((qp->qpn & MGM_QPN_MASK) |
 						       (1U << MGM_BLCK_LB_BIT));
 	else
-		mgm->qp[members_count++] = cpu_to_be32(qp->qpn & MGM_QPN_MASK);
+		low_mgm->qp[members_count++] = cpu_to_be32(qp->qpn & MGM_QPN_MASK);
 
-	mgm->members_count = cpu_to_be32(members_count | (u32) prot << 30);
+	low_mgm->members_count = cpu_to_be32(members_count | (u32) prot << 30);
 
-	err = mlx4_WRITE_ENTRY(dev, index, mailbox);
+	err = mlx4_WRITE_ENTRY(dev, low_index, low_mailbox);
 	if (err)
 		goto out;
 
@@ -688,15 +881,19 @@ int mlx4_qp_attach_common(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 	err = mlx4_WRITE_ENTRY(dev, prev, mailbox);
 	if (err)
 		goto out;
+	if (high_prio)
+		err = inc_num_high_prio(dev, port, hash, prot);
+	if (err)
+		goto out;
 
 out:
 	if (prot == MLX4_PROT_ETH) {
 		/* manage the steering entry for promisc mode */
 		if (new_entry)
-			new_steering_entry(dev, 0, port, steer, index, qp->qpn);
+			new_steering_entry(dev, 0, port, steer, low_index, qp->qpn);
 		else
 			existing_steering_entry(dev, 0, port, steer,
-						index, qp->qpn);
+						low_index, qp->qpn);
 	}
 	if (err && link && index != -1) {
 		if (index < dev->caps.num_mgms)
@@ -709,11 +906,14 @@ out:
 	mutex_unlock(&priv->mcg_table.mutex);
 
 	mlx4_free_cmd_mailbox(dev, mailbox);
+	if (low_to_high && low_mailbox)
+		mlx4_free_cmd_mailbox(dev, low_mailbox);
 	return err;
 }
 
 int mlx4_qp_detach_common(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
-			  enum mlx4_protocol prot, enum mlx4_steer_type steer)
+			  enum mlx4_protocol prot, enum mlx4_steer_type steer,
+			  u8 high_prio)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	struct mlx4_cmd_mailbox *mailbox;
@@ -733,7 +933,7 @@ int mlx4_qp_detach_common(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 
 	mutex_lock(&priv->mcg_table.mutex);
 
-	err = find_entry(dev, port, gid, prot, steer,
+	err = find_entry(dev, port, gid, prot, steer, high_prio,
 			 mailbox, &hash, &prev, &index);
 	if (err)
 		goto out;
@@ -780,6 +980,8 @@ int mlx4_qp_detach_common(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 		int amgm_index = be32_to_cpu(mgm->next_gid_index) >> 6;
 		if (amgm_index) {
 			err = mlx4_READ_ENTRY(dev, amgm_index, mailbox);
+			if (!memcmp(mgm->gid, gid, 16))
+				adjust_steering_entry(dev, 0, port, steer, amgm_index, index);
 			if (err)
 				goto out;
 		} else
@@ -817,7 +1019,8 @@ int mlx4_qp_detach_common(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 			mlx4_bitmap_free(&priv->mcg_table.bitmap,
 					 index - dev->caps.num_mgms);
 	}
-
+	if (high_prio)
+		dec_num_high_prio(dev, port, hash, prot);
 out:
 	mutex_unlock(&priv->mcg_table.mutex);
 
@@ -827,7 +1030,8 @@ out:
 
 
 int mlx4_multicast_attach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
-			  int block_mcast_loopback, enum mlx4_protocol prot)
+			  int block_mcast_loopback, enum mlx4_protocol prot,
+			  u8 high_prio)
 {
 	enum mlx4_steer_type steer;
 
@@ -841,12 +1045,12 @@ int mlx4_multicast_attach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 
 	return mlx4_qp_attach_common(dev, qp, gid,
 				     block_mcast_loopback, prot,
-				     steer);
+				     steer, high_prio);
 }
 EXPORT_SYMBOL_GPL(mlx4_multicast_attach);
 
 int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
-			  enum mlx4_protocol prot)
+			  enum mlx4_protocol prot, u8 high_prio)
 {
 	enum mlx4_steer_type steer;
 
@@ -859,7 +1063,7 @@ int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 		gid[7] |= (steer << 1);
 	}
 
-	return mlx4_qp_detach_common(dev, qp, gid, prot, steer);
+	return mlx4_qp_detach_common(dev, qp, gid, prot, steer, high_prio);
 }
 EXPORT_SYMBOL_GPL(mlx4_multicast_detach);
 
diff --git a/drivers/net/mlx4/mlx4.h b/drivers/net/mlx4/mlx4.h
index d8bb441..a50923a 100644
--- a/drivers/net/mlx4/mlx4.h
+++ b/drivers/net/mlx4/mlx4.h
@@ -444,8 +444,8 @@ int mlx4_SET_PORT(struct mlx4_dev *dev, u8 port);
 int mlx4_get_port_ib_caps(struct mlx4_dev *dev, u8 port, __be32 *caps);
 
 int mlx4_qp_detach_common(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
-			  enum mlx4_protocol prot, enum mlx4_steer_type steer);
+			  enum mlx4_protocol prot, enum mlx4_steer_type steer, u8 high_prio);
 int mlx4_qp_attach_common(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 			  int block_mcast_loopback, enum mlx4_protocol prot,
-			  enum mlx4_steer_type steer);
+			  enum mlx4_steer_type steer, u8 high_prio);
 #endif /* MLX4_H */
diff --git a/drivers/net/mlx4/port.c b/drivers/net/mlx4/port.c
index eca7d85..6148195 100644
--- a/drivers/net/mlx4/port.c
+++ b/drivers/net/mlx4/port.c
@@ -113,7 +113,7 @@ static int mlx4_uc_steer_add(struct mlx4_dev *dev, u8 port,
 	gid[7] = MLX4_UC_STEER << 1;
 
 	err = mlx4_qp_attach_common(dev, &qp, gid, 0,
-				    MLX4_PROT_ETH, MLX4_UC_STEER);
+				    MLX4_PROT_ETH, MLX4_UC_STEER, 0);
 	if (err && reserve)
 		mlx4_qp_release_range(dev, *qpn, 1);
 
@@ -133,7 +133,7 @@ static void mlx4_uc_steer_release(struct mlx4_dev *dev, u8 port,
 	gid[5] = port;
 	gid[7] = MLX4_UC_STEER << 1;
 
-	mlx4_qp_detach_common(dev, &qp, gid, MLX4_PROT_ETH, MLX4_UC_STEER);
+	mlx4_qp_detach_common(dev, &qp, gid, MLX4_PROT_ETH, MLX4_UC_STEER, 0);
 	if (free)
 		mlx4_qp_release_range(dev, qpn, 1);
 }
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 56fa5e1..f1cb31b 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -522,9 +522,10 @@ int mlx4_INIT_PORT(struct mlx4_dev *dev, int port);
 int mlx4_CLOSE_PORT(struct mlx4_dev *dev, int port);
 
 int mlx4_multicast_attach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
-			  int block_mcast_loopback, enum mlx4_protocol protocol);
+			  int block_mcast_loopback, enum mlx4_protocol protocol,
+			  u8 high_prio);
 int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
-			  enum mlx4_protocol protocol);
+			  enum mlx4_protocol protocol, u8 high_prio);
 int mlx4_multicast_promisc_add(struct mlx4_dev *dev, u32 qpn, u8 port);
 int mlx4_multicast_promisc_remove(struct mlx4_dev *dev, u32 qpn, u8 port);
 int mlx4_unicast_promisc_add(struct mlx4_dev *dev, u32 qpn, u8 port);
-- 
1.6.0.2




